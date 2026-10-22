extends GutTest
## BattleController (Story 1.5): submit, hủy một nước, kết thúc lượt, quay lại khi lệnh làm hỏng bất biến.
## Trận nhỏ dựng tay, không dựa vào file trận hay chi_so.json.


## Khi broken: lệnh nào cũng làm hỏng bất biến (đặt Lão chồng lên Khoái và đổi cả hiệp, máu, dấu đã đi),
## để thử đường cứu trận. Tắt broken thì chạy luật thật.
class BrokenController:
	extends BattleController

	var broken: bool = true

	func _resolve(state: BattleState, command: Command) -> Array[BattleEvent]:
		if not broken:
			return super(state, command)
		state.units[1] = Unit.new(2, UnitType.PHAM_NGU_LAO, state.units[0].cell, 1, true)
		state.units[0].has_moved = not state.units[0].has_moved
		state.round_number += 1
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
	for i: int in range(level.size.x * level.size.y):
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
	(c as BrokenController).broken = false
	c.submit(Command.move(1, Vector2i(0, 4)))
	(c as BrokenController).broken = true
	_events_seen = []
	var before: BattleState = c.snapshot()
	var events: Array[BattleEvent] = c.submit(Command.move(2, Vector2i(1, 4)))
	assert_eq(events, [] as Array[BattleEvent])
	assert_eq(_rolled_back_seen.size(), 1, "phát rolled_back")
	assert_eq(_rolled_back_seen[0], ["quân 2 ở ô 0,4 đứng chung ô với quân 1"] as Array[String])
	assert_eq(_events_seen.size(), 0, "không phát events_resolved")
	_assert_same_state(c.snapshot(), before)
	assert_eq(c.snapshot().validate(), [] as Array[String])
	assert_true(c.can_undo(), "bản chụp hủy của nước đi trước vẫn còn")
	c.undo()
	assert_eq(_cell(c, 1), Vector2i(0, 6), "hủy vẫn trả Khoái về ô cũ")
	var logged: bool = false
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR][battle]"):
			logged = true
	assert_true(logged, "có dòng log ERROR")


## Giống hệt: cùng hiệp, cùng số quân, từng quân cùng id, loại, ô, máu, dấu đã đi.
func _assert_same_state(got: BattleState, want: BattleState) -> void:
	assert_eq(got.round_number, want.round_number, "cùng hiệp")
	assert_eq(got.units.size(), want.units.size(), "cùng số quân")
	for i: int in range(mini(got.units.size(), want.units.size())):
		var g: Unit = got.units[i]
		var w: Unit = want.units[i]
		assert_eq([g.id, g.type, g.cell, g.hp, g.has_moved, g.has_attacked],
			[w.id, w.type, w.cell, w.hp, w.has_moved, w.has_attacked],
			"quân %d giống trước lệnh" % w.id)


# ---------- Đánh (Story 2.1) ----------

## Khoái ở 3,4 kề Bộ binh 3,3; Lão ở 0,6; thêm một Bộ binh sát mép phải ở 6,4.
func _attack_controller() -> BattleController:
	return _controller_for({Vector2i(3, 4): "1", Vector2i(0, 6): "2", Vector2i(3, 3): "B", Vector2i(6, 4): "B"})


func _controller_for(units: Dictionary) -> BattleController:
	var controller: BattleController = BattleController.new()
	var state: BattleState = BoardFixture.state(units)
	var level: LevelData = LevelData.new()
	level.size = state.size
	level.terrain = state.terrain
	for u: Unit in state.units:
		level.units.append(LevelData.UnitPlacement.new(u.type, u.cell))
	controller.start(level, BoardFixture.stats())
	controller.events_resolved.connect(func(events: Array[BattleEvent], snapshot: BattleState) -> void:
		_events_seen.append([events, snapshot]))
	return controller


func test_attack_clears_undo() -> void:
	var c: BattleController = _attack_controller()
	c.submit(Command.move(2, Vector2i(0, 5)))
	assert_true(c.can_undo())
	c.submit(Command.attack(1, Vector2i(3, 3)))
	assert_false(c.can_undo(), "đánh xóa lịch sử hủy")
	var events: Array[BattleEvent] = c.undo()
	assert_eq(events.size(), 1)
	assert_eq(events[0].reject, BattleEvent.Reject.NOTHING_TO_UNDO)
	assert_eq(_cell(c, 2), Vector2i(0, 5), "Lão vẫn ở ô mới")
	assert_eq(c.snapshot().unit_at(Vector2i(3, 2)).hp, 1, "đòn đánh không bị hủy")


func test_rejected_attack_keeps_undo() -> void:
	var c: BattleController = _attack_controller()
	c.submit(Command.move(2, Vector2i(0, 5)))
	_events_seen = []
	var events: Array[BattleEvent] = c.submit(Command.attack(1, Vector2i(2, 4)))
	assert_eq(events[0].reject, BattleEvent.Reject.NO_TARGET)
	assert_true(c.can_undo(), "nước đi trước vẫn hủy được")
	assert_eq(_events_seen.size(), 0, "không phát signal")


func test_attack_targets_query() -> void:
	var c: BattleController = _attack_controller()
	assert_eq(c.attack_targets(1), [Vector2i(3, 3)] as Array[Vector2i])
	assert_eq(c.attack_targets(2), [] as Array[Vector2i], "Lão không có quân Nguyên thẳng hàng trong tầm")
	assert_eq(c.attack_targets(99), [] as Array[Vector2i])
	c.submit(Command.attack(1, Vector2i(3, 3)))
	assert_eq(c.attack_targets(1), [] as Array[Vector2i], "đã đánh")


## Lão ở 1,5 cách Bộ binh 4,5 ba ô (Story 2.3).
func test_lance_targets_and_clears_undo() -> void:
	var c: BattleController = _controller_for({Vector2i(1, 5): "2", Vector2i(4, 5): "B", Vector2i(0, 0): "1"})
	assert_eq(c.attack_targets(2), [Vector2i(4, 5)] as Array[Vector2i])
	c.submit(Command.move(1, Vector2i(1, 0)))
	assert_true(c.can_undo())
	c.submit(Command.attack(2, Vector2i(4, 5)))
	assert_false(c.can_undo(), "phóng lao xóa lịch sử hủy")
	assert_eq(c.snapshot().unit_at(Vector2i(4, 5)).hp, 2)
	assert_eq(c.attack_targets(2), [] as Array[Vector2i], "đã phóng")


## Dư ở 3,5 cách Bộ binh 3,2 ba ô (Story 2.4).
func test_pull_targets_and_clears_undo() -> void:
	var c: BattleController = _controller_for({Vector2i(3, 5): "3", Vector2i(3, 2): "B", Vector2i(0, 0): "1"})
	assert_eq(c.attack_targets(3), [Vector2i(3, 2)] as Array[Vector2i])
	c.submit(Command.move(1, Vector2i(1, 0)))
	assert_true(c.can_undo())
	c.submit(Command.attack(3, Vector2i(3, 2)))
	assert_false(c.can_undo(), "kéo xóa lịch sử hủy")
	assert_eq(c.snapshot().unit_at(Vector2i(3, 4)).hp, 3, "Bộ binh bị kéo sát Dư, không mất máu")
	assert_eq(c.attack_targets(3), [] as Array[Vector2i], "đã kéo")


## Đòn làm gục (va mép bàn): quân bị nhấc khỏi bàn, validate() rỗng nên không bị quay lại.
func test_lethal_attack_is_not_rolled_back() -> void:
	var c: BattleController = _attack_controller()
	c.submit(Command.move(1, Vector2i(5, 4)))
	var rolled: Array = []
	c.rolled_back.connect(func(problems: Array[String]) -> void: rolled.append(problems))
	c.submit(Command.attack(1, Vector2i(6, 4)))
	assert_eq(rolled, [], "không quay lại")
	assert_null(c.snapshot().unit_at(Vector2i(6, 4)), "Bộ binh va mép bàn, gục")
	assert_eq(c.snapshot().units.size(), 3)


## Story 2.5: hết trận thì khóa lệnh và cả hủy; lệnh bị khóa không phát signal, không đổi gì.
func test_battle_over_locks_submit_and_undo() -> void:
	var c: BattleController = _controller_for({Vector2i(3, 1): "1", Vector2i(3, 0): "B", Vector2i(0, 6): "2"})
	c.submit(Command.move(2, Vector2i(0, 5)))
	assert_true(c.can_undo(), "điều kiện trước: còn hủy được")
	c.submit(Command.attack(1, Vector2i(3, 0)))
	assert_eq(c.snapshot().phase, BattleState.Phase.WON, "Bộ binh cuối va mép bàn và gục")
	assert_false(c.can_undo())
	_events_seen = []
	var rolled: Array = []
	c.rolled_back.connect(func(problems: Array[String]) -> void: rolled.append(problems))
	var undone: Array[BattleEvent] = c.undo()
	assert_eq(BoardFixture.describe(undone), ["REJECTED BATTLE_OVER"] as Array[String])
	var moved: Array[BattleEvent] = c.submit(Command.move(2, Vector2i(0, 4)))
	assert_eq(BoardFixture.describe(moved), ["REJECTED BATTLE_OVER"] as Array[String])
	var ended: Array[BattleEvent] = c.submit(Command.end_turn())
	assert_eq(BoardFixture.describe(ended), ["REJECTED BATTLE_OVER"] as Array[String])
	assert_eq(_events_seen.size(), 0, "không phát signal")
	assert_eq(rolled, [], "không quay lại")
	assert_eq(_cell(c, 2), Vector2i(0, 5), "Lão không dời")
	assert_eq(c.snapshot().round_number, 1, "không sang hiệp mới")
	assert_false(c.can_undo())


func test_battle_over_shows_no_cells() -> void:
	var c: BattleController = _controller_for({Vector2i(3, 1): "1", Vector2i(3, 0): "B", Vector2i(0, 6): "2"})
	assert_false(c.reachable(2).is_empty(), "điều kiện trước: Lão đi được")
	c.submit(Command.attack(1, Vector2i(3, 0)))
	assert_eq(c.snapshot().phase, BattleState.Phase.WON, "điều kiện trước: đã thắng")
	assert_eq(c.reachable(2), [] as Array[Vector2i], "hết trận: không còn ô đi")
	assert_eq(c.attack_targets(2), [] as Array[Vector2i], "hết trận: không còn ô đánh")


# ---------- Mở trận (Story 2.6) ----------

func _enemy_level() -> LevelData:
	var level: LevelData = _level()
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(0, 3)))
	return level


func test_start_does_not_run_enemy_prepare() -> void:
	var controller: BattleController = BattleController.new()
	controller.start(_enemy_level(), BoardFixture.stats())
	assert_eq(_cell(controller, 101), Vector2i(0, 3), "start() không cho quân Nguyên đi (bàn kịch bản giữ nguyên)")
	assert_eq(controller.snapshot().telegraphs.size(), 0)


func test_begin_runs_enemy_prepare_once_and_emits() -> void:
	var controller: BattleController = BattleController.new()
	controller.start(_enemy_level(), BoardFixture.stats())
	var seen: Array = []
	controller.events_resolved.connect(func(events: Array[BattleEvent], snapshot: BattleState) -> void:
		seen.append([events, snapshot]))
	controller.begin()
	assert_eq(seen.size(), 1, "phát events_resolved một lần")
	if seen.size() != 1:
		return
	var snapshot: BattleState = seen[0][1] as BattleState
	assert_eq(snapshot.unit_by_id(101).cell, Vector2i(0, 5), "Bộ binh đi 2 bước tới ô kề Khoái 0,6")
	assert_eq(snapshot.telegraphs.size(), 1, "bản chụp đã có đòn")
	assert_eq(snapshot.round_number, 1)
	assert_false(controller.can_undo(), "mở trận không để lại gì để hủy")
	assert_eq(BattleController._describe(Command.begin_battle()), "mở trận", "câu log của lệnh")



## Xem trước chạy trên bản sao: không đổi trạng thái sống, không phát signal, không tạo bản chụp hủy (Story 2.12).
func test_preview_does_not_touch_live_state() -> void:
	var c: BattleController = _attack_controller()
	var before: Array[String] = BoardFixture.picture(c.snapshot())
	var preview: BattleState = c.preview(Command.attack(1, Vector2i(3, 3)))
	assert_not_null(preview, "đòn hợp lệ thì có bản xem trước")
	assert_eq(BoardFixture.picture(c.snapshot()), before, "trạng thái sống không đổi")
	assert_false(c.can_undo(), "xem trước không tạo bản chụp hủy")
	assert_eq(_events_seen.size(), 0, "xem trước không phát signal")


## Xem trước không đụng bản chụp hủy đang có: hủy sau khi xem vẫn trả về đúng trạng thái trước nước đi
## (Story 2.12 review, LOW-1 — test cũ chỉ kiểm `can_undo()` khi nó vốn đã false nên không chứng minh được gì).
func test_preview_keeps_existing_undo_snapshot() -> void:
	var c: BattleController = _attack_controller()
	var before: Array[String] = BoardFixture.picture(c.snapshot())
	c.submit(Command.move(2, Vector2i(0, 5)))
	assert_true(c.can_undo(), "đi xong thì hủy được")
	assert_not_null(c.preview(Command.attack(1, Vector2i(3, 3))), "vẫn xem trước được đòn của Khoái")
	assert_true(c.can_undo(), "xem trước không xóa bản chụp hủy")
	c.undo()
	assert_eq(BoardFixture.picture(c.snapshot()), before, "hủy vẫn trả về trạng thái trước khi đi")


## Bản xem trước khớp đúng kết quả khi thật sự ra đòn (Story 2.12, AC 2).
func test_preview_matches_real_attack() -> void:
	var c: BattleController = _attack_controller()
	var preview: BattleState = c.preview(Command.attack(1, Vector2i(3, 3)))
	assert_not_null(preview)
	var expected: Array[String] = BoardFixture.picture(preview)
	c.submit(Command.attack(1, Vector2i(3, 3)))
	assert_eq(BoardFixture.picture(c.snapshot()), expected, "kết quả thật khớp bản xem trước")


## Đòn không hợp lệ thì không có bản xem trước (Story 2.12).
func test_preview_returns_null_for_rejected_command() -> void:
	var c: BattleController = _attack_controller()
	assert_null(c.preview(Command.attack(1, Vector2i(6, 4))), "ngoài tầm thì không xem trước")
	assert_null(c.preview(Command.attack(2, Vector2i(3, 3))), "tướng ở xa cũng vậy")
