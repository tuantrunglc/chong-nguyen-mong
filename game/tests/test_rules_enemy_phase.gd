extends GutTest
## Kết thúc lượt người chơi (Story 1.5): sang hiệp mới, mọi tướng đi lại được. Pha địch thêm ở E2.


func _state() -> BattleState:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": 3}
	values[UnitType.BO_BINH] = {"mau": 3, "tam_di": 2}
	var level: LevelData = LevelData.new()
	level.size = Vector2i(7, 7)
	for i: int in range(level.size.x * level.size.y):
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
	assert_eq(events[0].type, BattleEvent.Type.ROUND_STARTED, "sang hiệp trước, rồi mới tới pha địch chuẩn bị")
	assert_eq(events[0].round_number, 2)
	Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 3)
	assert_eq(state.validate(), [] as Array[String])


func test_end_turn_lets_every_general_move_again() -> void:
	var state: BattleState = _state()
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	Rules.resolve(state, Command.move(2, Vector2i(1, 3)))
	var before: Array = _picture(state).slice(0, 2)
	Rules.resolve(state, Command.end_turn())
	for u: Unit in state.units:
		assert_false(u.has_moved, "quân %d đi lại được" % u.id)
	assert_eq(_picture(state).slice(0, 2), before, "tướng không đổi ô, máu (quân Nguyên thì đi, Story 2.6)")
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


# ---------- Pha địch chuẩn bị (Story 2.6) ----------

func test_prepare_moves_then_telegraphs_in_order() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(5, 2): "B", Vector2i(3, 3): "1"})
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(BoardFixture.describe(events), [
		"MOVED 101 3,0>3,1 WALK", "MOVED 101 3,1>3,2 WALK", "TELEGRAPHED 101 3,2>3,3 #1",
		"MOVED 102 5,2>5,3 WALK", "MOVED 102 5,3>4,3 WALK", "TELEGRAPHED 102 4,3>3,3 #2",
	] as Array[String])
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_eq(state.telegraphs.size(), 2)
	assert_eq(state.telegraphs[0].owner_id, 101)
	assert_eq(state.telegraphs[0].kind, Telegraph.Kind.CELL)
	assert_eq(state.telegraphs[0].offset, Vector2i(0, 1), "lưu tương đối so với chủ đòn")
	assert_eq(state.telegraphs[1].target_cell(state), Vector2i(3, 3))
	assert_eq(state.enemy_intents.size(), 2)
	assert_eq(state.enemy_intents[1].order, 2)
	assert_eq(state.validate(), [] as Array[String])


func test_prepare_clears_old_telegraphs() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(3, 6): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.telegraphs.size(), 0, "quân xa không báo đòn, đòn cũ bị xóa")
	assert_eq(state.enemy_intents.size(), 1)


func test_end_turn_runs_prepare_after_new_round() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(BoardFixture.describe(events), ["ROUND_STARTED", "TELEGRAPHED 101 3,3>3,4 #1"] as Array[String])
	assert_eq(state.round_number, 2)


func test_begin_battle_prepares_round_one() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 1): "B", Vector2i(3, 4): "1"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.begin_battle())
	assert_eq(BoardFixture.describe(events), [
		"MOVED 101 3,1>3,2 WALK", "MOVED 101 3,2>3,3 WALK", "TELEGRAPHED 101 3,3>3,4 #1",
	] as Array[String], "không sang hiệp, không ROUND_STARTED")
	assert_eq(state.round_number, 1)
	assert_eq(state.phase, BattleState.Phase.PLAYER)


func test_prepare_is_deterministic() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "K", Vector2i(6, 0): "B", Vector2i(3, 6): "B",
		Vector2i(2, 3): "1", Vector2i(4, 3): "2"})
	var a: BattleState = state.clone()
	var b: BattleState = state.clone()
	var ea: Array[BattleEvent] = []
	var eb: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(a, ea)
	RulesEnemyPhase.prepare(b, eb)
	assert_eq(BoardFixture.describe(ea), BoardFixture.describe(eb))
	assert_eq(BoardFixture.picture(a), BoardFixture.picture(b))
	assert_eq(a.telegraphs.size(), b.telegraphs.size())
	assert_eq(a.validate(), [] as Array[String])
