extends GutTest
## Kết thúc lượt người chơi (Story 1.5): sang hiệp mới, mọi tướng đi lại được. Pha địch thêm ở E2.


func _state() -> BattleState:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": 3}
	values[UnitType.BO_BINH] = {"mau": 3, "tam_di": 2}
	var level: LevelData = LevelData.new()
	level.size = Vector2i(7, 7)
	for i: int in range(49):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(0, 6)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.PHAM_NGU_LAO, Vector2i(1, 6)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(5, 1), 2))
	return BattleState.from_level(level, Stats.new(values))


func _picture(state: BattleState) -> Array:
	var out: Array = []
	for u: Unit in state.units:
		out.append([u.id, u.cell, u.hp])
	return out


func test_end_turn_starts_next_round() -> void:
	var state: BattleState = _state()
	assert_eq(state.round_number, 1)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 2)
	assert_eq(events.size(), 1)
	assert_eq(events[0].type, BattleEvent.Type.ROUND_STARTED)
	assert_eq(events[0].round_number, 2)
	Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 3)
	assert_eq(state.validate(), [] as Array[String])


func test_end_turn_lets_every_general_move_again() -> void:
	var state: BattleState = _state()
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	Rules.resolve(state, Command.move(2, Vector2i(1, 3)))
	var before: Array = _picture(state)
	Rules.resolve(state, Command.end_turn())
	for u: Unit in state.units:
		assert_false(u.has_moved, "quân %d đi lại được" % u.id)
	assert_eq(_picture(state), before, "không đổi ô, máu")
	assert_eq(RulesMove.reachable(state, state.unit_by_id(1)).is_empty(), false)
	assert_eq(state.validate(), [] as Array[String])


func test_end_turn_is_deterministic() -> void:
	var state: BattleState = _state()
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	var a: BattleState = state.clone()
	var b: BattleState = state.clone()
	var ea: Array[BattleEvent] = Rules.resolve(a, Command.end_turn())
	var eb: Array[BattleEvent] = Rules.resolve(b, Command.end_turn())
	assert_eq(ea.size(), eb.size())
	assert_eq(ea[0].round_number, eb[0].round_number)
	assert_eq(_picture(a), _picture(b))
	assert_eq(a.round_number, b.round_number)
