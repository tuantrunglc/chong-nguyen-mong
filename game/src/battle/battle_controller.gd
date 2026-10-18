class_name BattleController
extends RefCounted
## Nơi duy nhất giữ trạng thái trận đang sống. Phần hiển thị chỉ nhận bản chụp (snapshot(), events_resolved).
## Lệnh của người chơi đi qua submit(); hủy nước đi khôi phục bản chụp (ADR-002), không phải lệnh luật.
## UI hỏi ô đi được qua reachable/path_to (chỉ đọc).

## Sau mỗi lệnh chạy được và sau mỗi lần hủy. snapshot là bản sao, không phải state sống.
signal events_resolved(events: Array[BattleEvent], snapshot: BattleState)
## Lệnh làm hỏng bất biến: đã quay về bản chụp trước lệnh. Thông báo cho người chơi: E2 (notice.gd).
signal rolled_back(problems: Array[String])

const NOTHING_TO_UNDO_REASON: String = "không còn nước đi nào để hủy"

var _state: BattleState = null
## Bản chụp ngay trước nước đi gần nhất; null là không có gì để hủy. Chỉ giữ một (tác giả chốt 2026-10-18).
var _undo_snapshot: BattleState = null


func start(level: LevelData, stats: Stats) -> void:
	_state = BattleState.from_level(level, stats)
	_undo_snapshot = null
	# Bộ nạp đã chặn các lỗi này; đây chỉ là lưới an toàn.
	for problem: String in _state.validate():
		Log.error("battle", problem)


func snapshot() -> BattleState:
	return _state.clone()


## Chạy lệnh. Bị từ chối: state không đổi, bản chụp hủy giữ nguyên, không phát signal.
## Làm hỏng bất biến: ghi log ERROR, quay về trước lệnh, phát rolled_back, trả [].
func submit(command: Command) -> Array[BattleEvent]:
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
			Log.debug("battle", "quân %d đi tới %d,%d" % [command.unit_id, command.cell.x, command.cell.y])
			_undo_snapshot = before  # thay bản cũ: chỉ hủy được nước gần nhất
		Command.Kind.END_TURN:
			Log.debug("battle", "kết thúc lượt, sang hiệp %d" % _state.round_number)
			_undo_snapshot = null  # Story 2.1: đánh cũng xóa; E3: mưu kế cũng xóa
	events_resolved.emit(events, _state.clone())
	return events


## Hủy nước đi gần nhất. Không có gì để hủy thì một sự kiện REJECTED (NOTHING_TO_UNDO), không phát signal.
func undo() -> Array[BattleEvent]:
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


## Các ô quân unit_id dừng được, theo thứ tự đọc bàn. Không có quân đó thì [].
func reachable(unit_id: int) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null:
		return []
	return RulesMove.reachable(_state, unit)


## Đường đi của quân unit_id tới cell (không gồm ô đang đứng); không tới được thì [].
func path_to(unit_id: int, cell: Vector2i) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null:
		return []
	return RulesMove.path_to(_state, unit, cell)


## Chỉ gọi Rules.resolve. Tách ra để test thay được (ca cứu trận).
func _resolve(state: BattleState, command: Command) -> Array[BattleEvent]:
	return Rules.resolve(state, command)


static func _rejection(events: Array[BattleEvent]) -> BattleEvent:
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.REJECTED:
			return event
	return null
