class_name BattleController
extends RefCounted
## Nơi duy nhất giữ trạng thái trận đang sống. Phần hiển thị chỉ nhận bản chụp (snapshot(), events_resolved).
## Lệnh của người chơi đi qua submit(); hủy nước đi khôi phục bản chụp (ADR-002), không phải lệnh luật.
## UI hỏi ô đi được qua reachable/path_to, ô đánh được qua attack_targets (chỉ đọc).

## Sau mỗi lệnh chạy được và sau mỗi lần hủy. snapshot là bản sao, không phải state sống.
signal events_resolved(events: Array[BattleEvent], snapshot: BattleState)
## Lệnh làm hỏng bất biến: đã quay về bản chụp trước lệnh. Thông báo cho người chơi: E2 (notice.gd).
signal rolled_back(problems: Array[String])

const NOTHING_TO_UNDO_REASON: String = "không còn nước đi nào để hủy"

var _state: BattleState = null
## Bản chụp ngay trước nước đi gần nhất; null là không có gì để hủy. Chỉ giữ một (tác giả chốt 2026-10-18).
var _undo_snapshot: BattleState = null
## Bàn đầu hiệp và các lệnh từ đó tới giờ, cho báo cáo F2 (Story 2.13). Phát lại hai thứ này ra đúng bàn đang sống.
## Mục lệnh: {"lenh": "di"|"danh"|"ket_thuc_luot"|"huy", "tuong": int, "o": Vector2i, "tu_choi": Reject}.
var _round_start: BattleState = null
var _round_commands: Array[Dictionary] = []
## Hiệp trước, giữ lại khi vừa kết thúc lượt: F2 rơi đúng lúc pha địch vừa chạy xong (chưa ra lệnh nào ở hiệp mới)
## thì báo cáo vẫn phải phát lại được pha địch, nên dùng bàn đầu hiệp cũ + lệnh, gồm cả `ket_thuc_luot`.
var _prev_round_start: BattleState = null
var _prev_round_commands: Array[Dictionary] = []
## Bàn đầu LƯỢT NGƯỜI CHƠI của hiệp hiện tại (sau pha chuẩn bị của địch); null khi chưa mở trận hoặc trận đã hết.
var _turn_start: BattleState = null
## Chơi lại hiệp chỉ được một lần mỗi trận (FR39).
var _replay_used: bool = false


## telegraphs: đòn đã báo sẵn (chỉ bộ chạy kịch bản dùng, "truoc.bao_don", Story 2.8); chép sâu, theo số thứ tự.
func start(level: LevelData, stats: Stats, telegraphs: Array[Telegraph] = []) -> void:
	_state = BattleState.from_level(level, stats)
	for t: Telegraph in telegraphs:
		_state.telegraphs.append(t.clone())
	_undo_snapshot = null
	# Đầu hiệp 1 là bàn "truoc" của trận; begin() sẽ dời mốc sang bàn sau pha chuẩn bị (Story 2.13).
	_round_start = _state.clone()
	_round_commands = []
	_prev_round_start = null
	_prev_round_commands = []
	_turn_start = null
	_replay_used = false
	# Bộ nạp đã chặn các lỗi này; đây chỉ là lưới an toàn.
	for problem: String in _state.validate():
		Log.error("battle", problem)


## Mở trận: pha địch chuẩn bị của hiệp 1 (quân Nguyên đi và báo đòn), qua cùng đường với lệnh của người chơi.
## start() không tự gọi để bộ chạy kịch bản dựng được bàn "truoc" là đầu lượt người chơi (Story 2.6).
func begin() -> Array[BattleEvent]:
	return submit(Command.begin_battle())


func snapshot() -> BattleState:
	return _state.clone()


## Chạy thử lệnh trên bản sao (Story 2.12, ADR-005). Trả `{"state", "events"}` — view cần cả nhật ký để biết
## quân chết ở ô nào; `{}` khi lệnh bị từ chối, chưa có trận, hoặc bản sao làm hỏng bất biến (cùng lưới an toàn
## như `submit`). Không đụng trạng thái sống, không phát signal, không đổi bản chụp hủy.
func preview_result(command: Command) -> Dictionary:
	if _state == null:
		return {}
	var copy: BattleState = _state.clone()
	var events: Array[BattleEvent] = _resolve(copy, command)
	if _rejection(events) != null:
		return {}
	# Lưới an toàn như `submit`, nhưng không phát signal: một `clone()` thiếu field mới sẽ làm mọi lần rê mất bóng.
	# Ghi log để lỗi đó còn dấu vết, thay vì im lặng.
	var problems: Array[String] = copy.validate()
	if not problems.is_empty():
		for problem: String in problems:
			Log.error("battle", "xem trước vi phạm bất biến: %s" % problem)
		return {}
	return {"state": copy, "events": events}


## Bản chụp sau lệnh nếu lệnh chạy được, null nếu không — dạng tiện dụng của `preview_result`.
func preview(command: Command) -> BattleState:
	var result: Dictionary = preview_result(command)
	if result.is_empty():
		return null
	return result["state"] as BattleState


## Chạy lệnh. Bị từ chối: state không đổi, bản chụp hủy giữ nguyên, không phát signal.
## Làm hỏng bất biến: ghi log ERROR, quay về trước lệnh, phát rolled_back, trả [].
func submit(command: Command) -> Array[BattleEvent]:
	Log.debug("battle", "nhận lệnh: %s" % _describe(command))
	var before: BattleState = _state.clone()
	var events: Array[BattleEvent] = _resolve(_state, command)
	var rejected: BattleEvent = _rejection(events)
	if rejected != null:
		Log.debug("battle", "lệnh bị từ chối: %s" % rejected.reason)
		_record(command, rejected.reject)
		return events
	var problems: Array[String] = _state.validate()
	if not problems.is_empty():
		for problem: String in problems:
			Log.error("battle", "vi phạm bất biến: %s" % problem)
		_state = before
		rolled_back.emit(problems)
		return []
	match command.kind:
		Command.Kind.MOVE:
			_undo_snapshot = before  # thay bản cũ: chỉ hủy được nước gần nhất
		Command.Kind.ATTACK:
			_undo_snapshot = null  # đánh xóa lịch sử hủy (FR10); E3: mưu kế cũng xóa
		Command.Kind.END_TURN:
			Log.debug("battle", "sang hiệp %d" % _state.round_number)
			_undo_snapshot = null
		Command.Kind.BEGIN_BATTLE:
			_undo_snapshot = null
	_record(command, BattleEvent.Reject.NONE)
	# Sang hiệp (hoặc mở trận): mốc "đầu hiệp" dời sang bàn mới. Mở trận không giữ hiệp trước (bàn trước khi quân
	# Nguyên đi không phải thứ người chơi báo lỗi).
	if command.kind == Command.Kind.BEGIN_BATTLE or command.kind == Command.Kind.END_TURN:
		_start_round(command.kind == Command.Kind.END_TURN)
		# Bàn người chơi thấy khi hiệp bắt đầu: sau pha chuẩn bị (quân Nguyên đã đi, đòn đã báo).
		_turn_start = null if Rules.is_battle_over(_state) else _state.clone()
	events_resolved.emit(events, _state.clone())
	return events


## Hủy nước đi gần nhất. Không có gì để hủy thì một sự kiện REJECTED (NOTHING_TO_UNDO), không phát signal.
## Trận đã kết thúc thì REJECTED (BATTLE_OVER): đánh đã xóa bản chụp hủy, nhưng khóa rõ ràng cho mọi lệnh về sau.
func undo() -> Array[BattleEvent]:
	if Rules.is_battle_over(_state):
		Log.debug("battle", "hủy: trận đã kết thúc")
		_record_undo(BattleEvent.Reject.BATTLE_OVER)
		return [BattleEvent.rejected(BattleEvent.Reject.BATTLE_OVER, "trận đã kết thúc")]
	if _undo_snapshot == null:
		Log.debug("battle", "hủy: %s" % NOTHING_TO_UNDO_REASON)
		_record_undo(BattleEvent.Reject.NOTHING_TO_UNDO)
		return [BattleEvent.rejected(BattleEvent.Reject.NOTHING_TO_UNDO, NOTHING_TO_UNDO_REASON)]
	# Bản chụp là bản riêng, không ai khác giữ, nên gán thẳng được.
	_state = _undo_snapshot
	_undo_snapshot = null
	_record_undo(BattleEvent.Reject.NONE)
	Log.debug("battle", "hủy nước đi gần nhất")
	var events: Array[BattleEvent] = []
	events_resolved.emit(events, _state.clone())
	return events


func can_undo() -> bool:
	return _undo_snapshot != null


## Chơi lại hiệp được không (FR39): chưa dùng lần nào trong trận, đang ở lượt người chơi, trận chưa hết.
func can_replay() -> bool:
	return _state != null and _turn_start != null and not _replay_used \
		and _state.phase == BattleState.Phase.PLAYER and not Rules.is_battle_over(_state)


## Số lần chơi lại còn lại trong trận: 1 hoặc 0. Giao diện hiện số này (Story 3.2).
func replay_left() -> int:
	return 0 if _replay_used else 1


## Chơi lại hiệp (FR39): về đúng bàn đầu lượt người chơi của hiệp này, mỗi trận một lần.
## Không chơi lại được thì trả false và không đổi gì (nút đã mờ; phím R im lặng).
func replay_round() -> bool:
	if not can_replay():
		return false
	var copy: BattleState = _turn_start.clone()
	# Lưới an toàn như submit()/preview_result(): clone() thiếu trường mới thì bàn hỏng không được phát ra UI.
	var problems: Array[String] = copy.validate()
	if not problems.is_empty():
		for problem: String in problems:
			Log.error("battle", "chơi lại vi phạm bất biến: %s" % problem)
		return false
	_state = copy
	_replay_used = true
	_undo_snapshot = null  # AC 4: Hủy sau khi chơi lại không quay về trước đó
	# F2: mốc mới là bàn vừa khôi phục; lệnh cũ không phát lại được vì bàn đã đổi.
	_start_round(false)
	Log.debug("battle", "chơi lại hiệp %d" % _state.round_number)
	var no_events: Array[BattleEvent] = []
	events_resolved.emit(no_events, _state.clone())
	return true


## Đầu hiệp để báo cáo F2 phát lại được (Story 2.13): bàn đầu hiệp hiện tại, hoặc bàn đầu hiệp trước khi vừa kết
## thúc lượt mà chưa ra lệnh nào (giữ được pha địch vừa chạy). Null khi chưa mở trận.
func round_start_snapshot() -> BattleState:
	if _use_previous_round():
		return _prev_round_start.clone()
	return _round_start.clone() if _round_start != null else null


## Các lệnh của hiệp tương ứng với `round_start_snapshot()`, theo thứ tự đã bấm (đã chép sâu).
func round_commands() -> Array[Dictionary]:
	var source: Array[Dictionary] = []
	if _use_previous_round():
		# Hiệp mới chưa có lệnh chạy được: giữ lệnh hiệp trước, rồi nối các lệnh bị từ chối vừa bấm ở hiệp mới
		# (chúng không đổi bàn cờ nên phát lại vẫn khớp, mà người báo lỗi vẫn thấy mình đã bấm gì).
		source.append_array(_prev_round_commands)
	source.append_array(_round_commands)
	var out: Array[Dictionary] = []
	for entry: Dictionary in source:
		out.append(entry.duplicate(true))
	return out


## Ghi lại một lệnh cho báo cáo F2. Bị từ chối vẫn ghi (kèm mã `tu_choi`) vì đó thường chính là lỗi đang báo.
func _record(command: Command, reject: BattleEvent.Reject) -> void:
	# BEGIN_BATTLE không phải lệnh người chơi và `hanh_dong` không có nó. END_TURN bị từ chối cũng không có chỗ ghi
	# `tu_choi` trong định dạng kịch bản (`"ket_thuc_luot": []`).
	if command.kind == Command.Kind.BEGIN_BATTLE:
		return
	if command.kind == Command.Kind.END_TURN and reject != BattleEvent.Reject.NONE:
		return
	_round_commands.append({"lenh": _command_code(command), "tuong": command.unit_id,
		"o": command.cell, "tu_choi": reject})


func _record_undo(reject: BattleEvent.Reject) -> void:
	_round_commands.append({"lenh": "huy", "tuong": 0, "o": Vector2i.ZERO, "tu_choi": reject})


static func _command_code(command: Command) -> String:
	match command.kind:
		Command.Kind.MOVE:
			return "di"
		Command.Kind.ATTACK:
			return "danh"
		Command.Kind.END_TURN:
			return "ket_thuc_luot"
	return ""


## Dời mốc đầu hiệp sang bàn hiện tại (sau BEGIN_BATTLE/END_TURN). keep_previous giữ hiệp vừa xong cho báo cáo F2.
func _start_round(keep_previous: bool) -> void:
	if keep_previous:
		_prev_round_start = _round_start
		_prev_round_commands = _round_commands
	else:
		_prev_round_start = null
		_prev_round_commands = []
	_round_start = _state.clone()
	_round_commands = []


## Báo cáo dùng hiệp trước khi hiệp này chưa có lệnh nào CHẠY ĐƯỢC — đúng cửa sổ ngay sau khi kết thúc lượt.
## Lệnh bị từ chối (kể cả Hủy khi không còn gì để hủy) không tính: chúng không đổi bàn cờ, nên không được đóng
## cửa sổ giữ pha địch (Story 2.13 review).
func _use_previous_round() -> bool:
	return _prev_round_start != null and not _has_accepted_command()


func _has_accepted_command() -> bool:
	for entry: Dictionary in _round_commands:
		if int(entry.get("tu_choi", BattleEvent.Reject.NONE)) == BattleEvent.Reject.NONE:
			return true
	return false


## Các ô quân unit_id dừng được, theo thứ tự đọc bàn. Không có quân đó, hoặc trận đã hết, thì [].
func reachable(unit_id: int) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null or Rules.is_battle_over(_state):
		return []
	return RulesMove.reachable(_state, unit)


## Đường đi của quân unit_id tới cell (không gồm ô đang đứng); không tới được thì [].
func path_to(unit_id: int, cell: Vector2i) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null:
		return []
	return RulesMove.path_to(_state, unit, cell)


## Các ô quân unit_id đánh được, theo thứ tự B→Đ→N→T. Không có quân đó, hoặc trận đã hết, thì [].
func attack_targets(unit_id: int) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null or Rules.is_battle_over(_state):
		return []
	return RulesAttack.targets(_state, unit)


## Chỉ gọi Rules.resolve. Tách ra để test thay được (ca cứu trận).
func _resolve(state: BattleState, command: Command) -> Array[BattleEvent]:
	return Rules.resolve(state, command)


## Câu cho log: "quân 1 đi tới 0,4", "quân 1 đánh ô 3,3", "kết thúc lượt".
static func _describe(command: Command) -> String:
	match command.kind:
		Command.Kind.MOVE:
			return "quân %d đi tới %d,%d" % [command.unit_id, command.cell.x, command.cell.y]
		Command.Kind.ATTACK:
			return "quân %d đánh ô %d,%d" % [command.unit_id, command.cell.x, command.cell.y]
		Command.Kind.END_TURN:
			return "kết thúc lượt"
		Command.Kind.BEGIN_BATTLE:
			return "mở trận"
	return str(command.kind)


static func _rejection(events: Array[BattleEvent]) -> BattleEvent:
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.REJECTED:
			return event
	return null
