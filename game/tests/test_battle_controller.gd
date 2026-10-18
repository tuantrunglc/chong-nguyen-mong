extends GutTest
## BattleController (Story 1.5): submit, hủy một nước, kết thúc lượt, quay lại khi lệnh làm hỏng bất biến.
## Trận nhỏ dựng tay, không dựa vào file trận hay chi_so.json.


## Lệnh nào cũng làm hỏng bất biến (đặt Lão chồng lên Khoái), để thử đường cứu trận.
class BrokenController:
	extends BattleController

	func _resolve(state: BattleState, _command: Command) -> Array[BattleEvent]:
		state.units[1] = Unit.new(2, UnitType.PHAM_NGU_LAO, state.units[0].cell, 3)
		return [] as Array[BattleEvent]


var _events_seen: Array = []
var _rolled_back_seen: Array = []


func before_each() -> void:
	_events_seen = []
	_rolled_back_seen = []


func after_each() -> void:
	Log.clear()


func _level() -> LevelData:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(7, 7)
	for i: int in range(49):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(0, 6)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.PHAM_NGU_LAO, Vector2i(1, 6)))
	return level


func _stats() -> Stats:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": 3}
	return Stats.new(values)


func _controller(controller: BattleController = BattleController.new()) -> BattleController:
	controller.start(_level(), _stats())
	controller.events_resolved.connect(func(events: Array[BattleEvent], snapshot: BattleState) -> void:
		_events_seen.append([events, snapshot]))
	controller.rolled_back.connect(func(problems: Array[String]) -> void: _rolled_back_seen.append(problems))
	return controller


func _cell(c: BattleController, id: int) -> Vector2i:
	return c.snapshot().unit_by_id(id).cell


func test_submit_move_changes_state_and_allows_undo() -> void:
	var c: BattleController = _controller()
	assert_false(c.can_undo(), "chưa đi thì không có gì để hủy")
	var events: Array[BattleEvent] = c.submit(Command.move(1, Vector2i(0, 4)))
	assert_eq(events.size(), 2)
	assert_eq(_cell(c, 1), Vector2i(0, 4))
	assert_true(c.can_undo())
	assert_eq(_events_seen.size(), 1, "phát events_resolved một lần")
	assert_eq(c.snapshot().validate(), [] as Array[String])


func test_events_resolved_carries_a_copy() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(0, 4)))
	var snapshot: BattleState = _events_seen[0][1] as BattleState
	assert_eq(snapshot.unit_by_id(1).cell, Vector2i(0, 4))
	snapshot.units.clear()
	snapshot.round_number = 9
	assert_eq(_cell(c, 1), Vector2i(0, 4), "sửa bản chụp không đổi state sống")
	assert_eq(c.snapshot().round_number, 1)


func test_rejected_submit_keeps_undo_and_emits_nothing() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(0, 4)))
	_events_seen.clear()
	var events: Array[BattleEvent] = c.submit(Command.move(2, Vector2i(5, 6)))
	assert_eq(events.size(), 1)
	assert_eq(events[0].reject, BattleEvent.Reject.UNREACHABLE)
	assert_eq(_events_seen.size(), 0, "bị từ chối thì không phát signal")
	assert_true(c.can_undo(), "nước đi trước đó vẫn hủy được")
	c.undo()
	assert_eq(_cell(c, 1), Vector2i(0, 6))


func test_undo_restores_cell_and_moved_flag() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(3, 6)))
	_events_seen.clear()
	var events: Array[BattleEvent] = c.undo()
	assert_eq(events, [] as Array[BattleEvent])
	assert_eq(_cell(c, 1), Vector2i(0, 6))
	assert_false(c.snapshot().unit_by_id(1).has_moved)
	assert_false(c.can_undo())
	assert_eq(_events_seen.size(), 1, "hủy cũng phát events_resolved để vẽ lại")
	assert_eq((_events_seen[0][1] as BattleState).unit_by_id(1).cell, Vector2i(0, 6))
	assert_eq(c.reachable(1).size() > 0, true, "đi lại được")


## Tác giả chốt 2026-10-18: chỉ hủy được một nước.
func test_only_one_move_can_be_undone() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(0, 4)))
	c.submit(Command.move(2, Vector2i(1, 3)))
	c.undo()
	assert_eq(_cell(c, 2), Vector2i(1, 6), "Lão về chỗ cũ")
	assert_eq(_cell(c, 1), Vector2i(0, 4), "Khoái vẫn ở ô mới")
	_events_seen.clear()
	var events: Array[BattleEvent] = c.undo()
	assert_eq(events.size(), 1)
	assert_eq(events[0].type, BattleEvent.Type.REJECTED)
	assert_eq(events[0].reject, BattleEvent.Reject.NOTHING_TO_UNDO)
	assert_eq(_events_seen.size(), 0)
	assert_eq(_cell(c, 1), Vector2i(0, 4), "hủy lần hai không làm gì")
	c.submit(Command.move(2, Vector2i(2, 4)))
	assert_true(c.can_undo(), "đi nước mới thì hủy được nước mới")


func test_undo_with_nothing_to_undo() -> void:
	var c: BattleController = _controller()
	var events: Array[BattleEvent] = c.undo()
	assert_eq(events.size(), 1)
	assert_eq(events[0].reject, BattleEvent.Reject.NOTHING_TO_UNDO)
	assert_eq(events[0].reason, "không còn nước đi nào để hủy")
	assert_eq(_events_seen.size(), 0)


func test_end_turn_advances_round_and_clears_undo() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(0, 4)))
	var events: Array[BattleEvent] = c.submit(Command.end_turn())
	assert_eq(events[0].type, BattleEvent.Type.ROUND_STARTED)
	assert_eq(c.snapshot().round_number, 2)
	assert_false(c.can_undo(), "không hủy được nước đi của lượt trước")
	assert_false(c.snapshot().unit_by_id(1).has_moved)
	assert_eq(c.undo()[0].reject, BattleEvent.Reject.NOTHING_TO_UNDO)
	assert_eq(_cell(c, 1), Vector2i(0, 4))


func test_start_again_clears_undo() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(0, 4)))
	c.start(_level(), _stats())
	assert_false(c.can_undo())
	assert_eq(_cell(c, 1), Vector2i(0, 6))
	assert_eq(c.snapshot().round_number, 1)


func test_invariant_violation_rolls_back() -> void:
	var c: BattleController = _controller(BrokenController.new())
	var before: BattleState = c.snapshot()
	var events: Array[BattleEvent] = c.submit(Command.move(1, Vector2i(0, 4)))
	assert_eq(events, [] as Array[BattleEvent])
	assert_eq(_rolled_back_seen.size(), 1, "phát rolled_back")
	assert_eq(_rolled_back_seen[0], ["quân 2 ở ô 0,6 đứng chung ô với quân 1"] as Array[String])
	assert_eq(_events_seen.size(), 0, "không phát events_resolved")
	assert_false(c.can_undo(), "bản chụp hủy không đổi")
	var after: BattleState = c.snapshot()
	for i: int in range(before.units.size()):
		assert_eq(after.units[i].cell, before.units[i].cell, "quay về ô trước lệnh")
	assert_eq(after.validate(), [] as Array[String])
	var logged: bool = false
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR][battle]"):
			logged = true
	assert_true(logged, "có dòng log ERROR")
