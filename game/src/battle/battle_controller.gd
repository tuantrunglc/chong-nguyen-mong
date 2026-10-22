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


## telegraphs: đòn đã báo sẵn (chỉ bộ chạy kịch bản dùng, "truoc.bao_don", Story 2.8); chép sâu, theo số thứ tự.
func start(level: LevelData, stats: Stats, telegraphs: Array[Telegraph] = []) -> void:
	_state = BattleState.from_level(level, stats)
	for t: Telegraph in telegraphs:
		_state.telegraphs.append(t.clone())
	_undo_snapshot = null
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
	if not copy.validate().is_empty():
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
	events_resolved.emit(events, _state.clone())
	return events


## Hủy nước đi gần nhất. Không có gì để hủy thì một sự kiện REJECTED (NOTHING_TO_UNDO), không phát signal.
## Trận đã kết thúc thì REJECTED (BATTLE_OVER): đánh đã xóa bản chụp hủy, nhưng khóa rõ ràng cho mọi lệnh về sau.
func undo() -> Array[BattleEvent]:
	if Rules.is_battle_over(_state):
		Log.debug("battle", "hủy: trận đã kết thúc")
		return [BattleEvent.rejected(BattleEvent.Reject.BATTLE_OVER, "trận đã kết thúc")]
	if _undo_snapshot == null:
		Log.debug("battle", "hủy: %s" % NOTHING_TO_UNDO_REASON)
		return [BattleEvent.rejected(BattleEvent.Reject.NOTHING_TO_UNDO, NOTHING_TO_UNDO_REASON)]
	# Bản chụp là bản riêng, không ai khác giữ, nên gán thẳng được.
	_state = _undo_snapshot
	_undo_snapshot = null
	Log.debug("battle", "hủy nước đi gần nhất")
	var events: Array[BattleEvent] = []
	events_resolved.emit(events, _state.clone())
	return events


func can_undo() -> bool:
	return _undo_snapshot != null


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
