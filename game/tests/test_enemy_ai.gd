extends GutTest
## Enemy AI (Story 2.6): chọn mục tiêu, chọn ô đứng, đi và báo đòn. Ca chính nằm trong kịch bản tests/kich_ban/ai/;
## ở đây là các ca biên kịch bản không có. Chỉ số của BoardFixture: Bộ binh đi 2, Kỵ binh đi 3.


func _plan(state: BattleState, id: int) -> EnemyIntent:
	var before: Array[String] = BoardFixture.picture(state)
	var intent: EnemyIntent = EnemyAI.plan(state, state.unit_by_id(id))
	assert_eq(BoardFixture.picture(state), before, "plan không đổi state")
	return intent


func _assert_intent(intent: EnemyIntent, target_id: int, steps: int, stand: Vector2i,
		reason: EnemyIntent.Reason) -> void:
	assert_eq(intent.target_id, target_id, "mục tiêu")
	assert_eq(intent.target_steps, steps, "số bước tới mục tiêu")
	assert_eq(intent.stand_cell, stand, "ô đứng")
	assert_eq(intent.reason, reason, "lý do")


func test_tie_in_steps_and_hp_same_row_picks_east() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(0, 3): "1", Vector2i(6, 3): "2"})
	_assert_intent(_plan(state, 101), 2, 3, Vector2i(5, 3), EnemyIntent.Reason.CAN_HIT)


func test_steps_follow_the_path_not_straight_line() -> void:
	# Khoái cách 2 ô theo đường chim bay nhưng sông chắn giữa: đi vòng 8 bước. Lão cách 4 bước, đường trống.
	var state: BattleState = BoardFixture.state({Vector2i(3, 1): "B", Vector2i(3, 3): "1", Vector2i(6, 2): "2"},
		{Vector2i(1, 2): "~", Vector2i(2, 2): "~", Vector2i(3, 2): "~", Vector2i(4, 2): "~", Vector2i(5, 2): "~",
			Vector2i(0, 2): "~"})
	var intent: EnemyIntent = _plan(state, 101)
	assert_eq(intent.target_id, 2, "nhắm Lão: gần hơn theo đường đi")
	assert_eq(intent.target_steps, 4)


func test_general_walled_in_by_river_is_ignored() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "B", Vector2i(6, 6): "1", Vector2i(3, 3): "2"},
		{Vector2i(5, 6): "~", Vector2i(6, 5): "~"})
	_assert_intent(_plan(state, 101), 2, 6, Vector2i(2, 0), EnemyIntent.Reason.CLOSEST)


func test_no_reachable_general_stands_still() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "B", Vector2i(6, 6): "1"},
		{Vector2i(1, 0): "~", Vector2i(0, 1): "~"})
	_assert_intent(_plan(state, 101), 0, 0, Vector2i(0, 0), EnemyIntent.Reason.NO_PATH)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(BoardFixture.describe(events), [] as Array[String], "không đi, không báo đòn")
	assert_eq(state.telegraphs.size(), 0)


func test_walks_through_ally_but_never_stops_on_it() -> void:
	# Bộ binh 3,2 đi xuyên Bộ binh 3,3 để tới 3,4, kề Khoái 3,5.
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B", Vector2i(3, 3): "B", Vector2i(3, 5): "1"})
	_assert_intent(_plan(state, 101), 1, 3, Vector2i(3, 4), EnemyIntent.Reason.CAN_HIT)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(BoardFixture.describe(events), [
		"MOVED 101 3,2>3,3 WALK", "MOVED 101 3,3>3,4 WALK", "TELEGRAPHED 101 3,4>3,5 #1",
	] as Array[String], "quân sau (3,3) không tới được ô kề Khoái nào còn trống: đứng yên, không báo đòn")
	# Quân sau: ô đang đứng và ô 2,4 cùng cách Khoái 2 bước (đếm xuyên đồng đội 3,4): hòa thì ít bước đi hơn.
	_assert_intent(state.enemy_intents[1], 1, 2, Vector2i(3, 3), EnemyIntent.Reason.CLOSEST)
	assert_eq(state.validate(), [] as Array[String])


func test_other_general_blocks_the_way() -> void:
	# Lão chắn khe sông duy nhất: Bộ binh không đi xuyên tướng, nên chỉ Lão có đường tới.
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(3, 2): "2", Vector2i(3, 5): "1"},
		{Vector2i(0, 2): "~", Vector2i(1, 2): "~", Vector2i(2, 2): "~", Vector2i(4, 2): "~", Vector2i(5, 2): "~",
			Vector2i(6, 2): "~"})
	_assert_intent(_plan(state, 101), 2, 2, Vector2i(3, 1), EnemyIntent.Reason.CAN_HIT)


func test_cavalry_line_blocked_by_forest_but_not_river() -> void:
	var forest: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 3): "1"}, {Vector2i(2, 3): "#"})
	assert_false(EnemyAI.can_hit_from(forest, forest.unit_by_id(101), Vector2i(0, 3), Vector2i(4, 3)), "rừng chắn")
	assert_true(EnemyAI.can_hit_from(forest, forest.unit_by_id(101), Vector2i(4, 0), Vector2i(4, 3)), "cột trống")
	# Cột 4 quá tầm đi (5 bước): không có ô xung phong được, đi vòng rừng về phía Khoái.
	_assert_intent(_plan(forest, 101), 1, 6, Vector2i(2, 2), EnemyIntent.Reason.CLOSEST)
	var river: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 3): "1"}, {Vector2i(2, 3): "~"})
	_assert_intent(_plan(river, 101), 1, 6, Vector2i(0, 3), EnemyIntent.Reason.CAN_HIT)


func test_cavalry_next_to_target_still_charges() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "K", Vector2i(4, 3): "1"})
	_assert_intent(_plan(state, 101), 1, 1, Vector2i(3, 3), EnemyIntent.Reason.CAN_HIT)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.telegraphs[0].kind, Telegraph.Kind.DIRECTION)
	assert_eq(state.telegraphs[0].offset, Vector2i(1, 0))


func test_infantry_cannot_stand_on_river_next_to_target() -> void:
	# Ô kề Khoái phía Bắc (3,3) là sông; các ô kề khác cần 3 bước (quá tầm): đi tới ô gần nhất, hòa 2,3 và 4,3 thì
	# phía Đông.
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B", Vector2i(3, 4): "1"}, {Vector2i(3, 3): "~"})
	_assert_intent(_plan(state, 101), 1, 4, Vector2i(4, 3), EnemyIntent.Reason.CLOSEST)


## Story 2.15: Cung kỵ bắn ô thẳng hàng cách 2–3 ô, tên bay qua quân.
func test_archer_shoots_from_three_cells_away() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "C", Vector2i(3, 6): "1"})
	_assert_intent(_plan(state, 101), 1, 3, Vector2i(3, 3), EnemyIntent.Reason.CAN_HIT)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.telegraphs.size(), 1, "báo đúng một đòn")
	assert_eq(state.telegraphs[0].kind, Telegraph.Kind.CELL)
	assert_eq(state.telegraphs[0].offset, Vector2i(0, 3), "ô 3,6 so với chỗ đứng 3,3")
	assert_eq(state.validate(), [] as Array[String])


func test_archer_walks_into_shooting_range() -> void:
	# Cách 6 bước: ô duy nhất trong tầm đi bắn được là 3,3 (3,4 ở bước thứ 4).
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "C", Vector2i(3, 6): "1"})
	_assert_intent(_plan(state, 101), 1, 6, Vector2i(3, 3), EnemyIntent.Reason.CAN_HIT)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.unit_by_id(101).cell, Vector2i(3, 3), "prepare cho quân đi thật")
	assert_eq(state.telegraphs.size(), 1, "và báo đòn sau khi đi")
	assert_eq(state.telegraphs[0].offset, Vector2i(0, 3))
	assert_eq(state.validate(), [] as Array[String])


## Tầm bắn đọc từ chi_so.json, không hard-code 2–3: đổi tam_ban_gan thành 3 thì 2 ô không bắn được nữa.
## Story 3.1: rừng hoặc kho lương nằm giữa chủ đòn và ô đích thì tên bị chặn; sông thì không.
func test_archer_arrow_blocked_by_terrain() -> void:
	var forest: BattleState = BoardFixture.state({Vector2i(3, 3): "C", Vector2i(3, 6): "1"},
		{Vector2i(3, 4): "#"})
	assert_false(EnemyAI.can_hit_from(forest, forest.unit_by_id(101), Vector2i(3, 3), Vector2i(3, 6)),
		"rừng chắn tên")
	var granary: BattleState = BoardFixture.state({Vector2i(3, 3): "C", Vector2i(3, 6): "1"},
		{Vector2i(3, 5): "L"})
	assert_false(EnemyAI.can_hit_from(granary, granary.unit_by_id(101), Vector2i(3, 3), Vector2i(3, 6)),
		"kho lương chắn tên")
	var next_door: BattleState = BoardFixture.state({Vector2i(3, 0): "C", Vector2i(3, 3): "1"},
		{Vector2i(3, 1): "#"})
	assert_false(EnemyAI.can_hit_from(next_door, next_door.unit_by_id(101), Vector2i(3, 0), Vector2i(3, 3)),
		"vật cản ngay sau chủ đòn cũng chặn")
	var behind: BattleState = BoardFixture.state({Vector2i(3, 0): "C", Vector2i(3, 2): "1"},
		{Vector2i(3, 4): "#"})
	assert_true(EnemyAI.can_hit_from(behind, behind.unit_by_id(101), Vector2i(3, 0), Vector2i(3, 2)),
		"vật cản sau ô đích không chặn")
	var river: BattleState = BoardFixture.state({Vector2i(3, 3): "C", Vector2i(3, 6): "1"},
		{Vector2i(3, 5): "~"})
	assert_true(EnemyAI.can_hit_from(river, river.unit_by_id(101), Vector2i(3, 3), Vector2i(3, 6)),
		"sông không chặn tên")


func test_archer_range_comes_from_stats() -> void:
	var stats: Stats = BoardFixture.stats_with(UnitType.CUNG_KY, "tam_ban_gan", 3)
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "C", Vector2i(3, 3): "1"}, {}, {},
		BoardFixture.DEFAULT_SIZE, stats)
	var archer: Unit = state.unit_by_id(101)
	assert_false(EnemyAI.can_hit_from(state, archer, Vector2i(3, 0), Vector2i(3, 2)),
		"cách 2 ô, dưới tầm gần 3")
	assert_true(EnemyAI.can_hit_from(state, archer, Vector2i(3, 0), Vector2i(3, 3)), "cách 3 ô, đúng tầm")
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 2), 1))
	assert_eq(state.validate(), ["đòn của quân 101 đánh ô cách 0,2, Cung kỵ chỉ bắn thẳng hàng 3–3 ô"]
		as Array[String], "validate cũng đọc tầm từ stats")


func test_archer_next_to_target_cannot_shoot() -> void:
	# Sông vây bốn phía (3,5): không đi được, cách 1 ô nên không bắn.
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "C", Vector2i(3, 6): "1"},
		{Vector2i(3, 4): "~", Vector2i(2, 5): "~", Vector2i(4, 5): "~"})
	_assert_intent(_plan(state, 101), 1, 1, Vector2i(3, 5), EnemyIntent.Reason.CLOSEST)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(BoardFixture.describe(events), [] as Array[String], "không báo đòn")
	assert_eq(state.validate(), [] as Array[String])


func test_archer_arrow_flies_over_units() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "C", Vector2i(3, 4): "B", Vector2i(3, 6): "1"})
	var archer: Unit = state.unit_by_id(101)
	assert_true(EnemyAI.can_hit_from(state, archer, Vector2i(3, 3), Vector2i(3, 6)),
		"Bộ binh đứng giữa không chặn tên")
	assert_false(EnemyAI.can_hit_from(state, archer, Vector2i(3, 5), Vector2i(3, 6)), "ô kề không bắn được")
	assert_false(EnemyAI.can_hit_from(state, archer, Vector2i(3, 2), Vector2i(3, 6)), "4 ô không bắn được")
	assert_false(EnemyAI.can_hit_from(state, archer, Vector2i(2, 4), Vector2i(3, 6)), "chéo không bắn được")


func test_large_board_uses_its_own_size() -> void:
	var size: Vector2i = Vector2i(10, 8)
	var state: BattleState = BoardFixture.state({Vector2i(9, 0): "K", Vector2i(2, 7): "1"}, {}, {}, size)
	# Cách 14 bước; đi 3 bước, mọi ô cách Khoái 11 hòa nhau: chọn ô phía Bắc nhất (6,0).
	_assert_intent(_plan(state, 101), 1, 14, Vector2i(6, 0), EnemyIntent.Reason.CLOSEST)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.unit_by_id(101).cell, Vector2i(6, 0))
	assert_eq(state.validate(), [] as Array[String])
