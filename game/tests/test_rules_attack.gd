extends GutTest
## Đòn Nguyễn Khoái (Story 2.1): đánh ô kề có quân Nguyên, 2 sát thương, đẩy 1 ô theo hướng đánh; bảng từ chối;
## đánh một lần mỗi lượt. Lao của Phạm Ngũ Lão (Story 2.3): thẳng hàng, bay qua ô kề, trúng quân đầu tiên ở ô 2–4,
## 1 sát thương, không đẩy. Kéo của Trần Khánh Dư (Story 2.4): vật đầu tiên trong 3 ô, kéo 2 ô, 0 sát thương.
## Chỉ số tự đặt (BoardFixture).


func _attack(state: BattleState, id: int, cell: Vector2i) -> Array[String]:
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(id, cell))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đánh")
	return BoardFixture.describe(events)


func test_strike_damages_then_pushes_away() -> void:
	var cases: Array = [[Vector2i(3, 2), Vector2i(3, 1)], [Vector2i(4, 3), Vector2i(5, 3)],
		[Vector2i(3, 4), Vector2i(3, 5)], [Vector2i(2, 3), Vector2i(1, 3)]]
	for c: Array in cases:
		var target: Vector2i = c[0] as Vector2i
		var pushed_to: Vector2i = c[1] as Vector2i
		var state: BattleState = BoardFixture.state({Vector2i(3, 3): "1", target: "B"})
		assert_eq(_attack(state, 1, target), ["ATTACKED 1 %s" % BoardText.cell_text(target), "DAMAGED 101 -2 STRIKE",
			"MOVED 101 %s>%s PUSH" % [BoardText.cell_text(target), BoardText.cell_text(pushed_to)]] as Array[String])
		assert_eq(state.unit_by_id(101).cell, pushed_to)
		assert_eq(state.unit_by_id(101).hp, 1)
		assert_true(state.unit_by_id(1).has_attacked)
		assert_false(state.unit_by_id(1).has_moved, "đánh không tính là đi")


func test_killed_target_is_not_pushed() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "K", Vector2i(3, 2): "B"})
	# Bộ binh ở hàng trên nên là 101, Kỵ binh là 102.
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 102 -2 STRIKE",
		"DIED 102 3,3"] as Array[String])
	assert_eq(state.unit_by_id(101).hp, 3, "quân đứng sau không bị va")


## Story 2.2 (AC 4): chết đuối không có DAMAGED va chạm, không có DIED.
func test_strike_pushes_into_river_drowns() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(2, 3): "1", Vector2i(3, 3): "B"}, {Vector2i(4, 3): "~"})
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -2 STRIKE",
		"MOVED 101 3,3>4,3 PUSH", "DROWNED 101 4,3"] as Array[String])
	assert_null(state.unit_by_id(101))


func test_rejections_keep_state() -> void:
	var units: Dictionary = {Vector2i(3, 4): "1", Vector2i(4, 4): "2", Vector2i(4, 3): "B", Vector2i(3, 2): "K",
		Vector2i(5, 3): "3"}
	var cases: Array = [
		[9, Vector2i(3, 3), "NO_UNIT"],
		[101, Vector2i(3, 4), "NOT_GENERAL"],
		[1, Vector2i(4, 3), "NOT_ADJACENT"],
		[1, Vector2i(3, 2), "NOT_ADJACENT"],
		[1, Vector2i(3, 7), "NOT_ADJACENT"],
		[1, Vector2i(2, 4), "NO_TARGET"],
		[1, Vector2i(4, 4), "NO_TARGET"],
		[2, Vector2i(4, 3), "NOT_IN_RANGE"],
		[3, Vector2i(4, 3), "NOT_IN_RANGE"],
	]
	for c: Array in cases:
		var state: BattleState = BoardFixture.state(units)
		var before: Array[String] = BoardFixture.picture(state)
		assert_eq(_attack(state, c[0] as int, c[1] as Vector2i), ["REJECTED %s" % c[2]] as Array[String], str(c))
		assert_eq(BoardFixture.picture(state), before, "state giữ nguyên: %s" % str(c))


func test_adjacent_cell_off_board_is_not_adjacent() -> void:
	for c: Array in [[Vector2i(0, 3), Vector2i(-1, 3)], [Vector2i(3, 6), Vector2i(3, 7)], [Vector2i(6, 0), Vector2i(6, -1)]]:
		var state: BattleState = BoardFixture.state({c[0] as Vector2i: "1"})
		assert_eq(_attack(state, 1, c[1] as Vector2i), ["REJECTED NOT_ADJACENT"] as Array[String], str(c))


func test_attack_once_per_turn() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B", Vector2i(4, 4): "B"})
	_attack(state, 1, Vector2i(3, 3))
	var before: Array[String] = BoardFixture.picture(state)
	assert_eq(_attack(state, 1, Vector2i(4, 4)), ["REJECTED ALREADY_ATTACKED"] as Array[String])
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(2, 4)))
	assert_eq(BoardFixture.describe(events), ["REJECTED ALREADY_ATTACKED"] as Array[String], "đánh rồi không đi được")
	assert_eq(BoardFixture.picture(state), before)
	assert_eq(RulesMove.reachable(state, state.unit_by_id(1)), [] as Array[Vector2i])
	assert_eq(RulesMove.path_to(state, state.unit_by_id(1), Vector2i(2, 4)), [] as Array[Vector2i])


func test_move_then_attack() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 6): "1", Vector2i(3, 3): "B"})
	Rules.resolve(state, Command.move(1, Vector2i(3, 4)))
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -2 STRIKE",
		"MOVED 101 3,3>3,2 PUSH"] as Array[String])
	assert_true(state.unit_by_id(1).has_moved)
	assert_true(state.unit_by_id(1).has_attacked)


func test_targets_are_adjacent_nguyen_units_in_direction_order() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "1", Vector2i(2, 3): "B", Vector2i(3, 4): "K",
		Vector2i(3, 2): "C", Vector2i(4, 3): "2", Vector2i(4, 4): "B"})
	var khoai: Unit = state.unit_by_id(1)
	assert_eq(RulesAttack.targets(state, khoai), [Vector2i(3, 2), Vector2i(3, 4), Vector2i(2, 3)] as Array[Vector2i],
		"B→Đ→N→T, không có tướng mình, không có ô chéo")
	assert_eq(RulesAttack.targets(state, state.unit_by_id(2)), [Vector2i(2, 3)] as Array[Vector2i],
		"Lão: bay qua Khoái kề ở 3,3 tới Bộ binh 2,3; Bộ binh 4,4 kề thì không")
	var du_state: BattleState = BoardFixture.state({Vector2i(3, 3): "3", Vector2i(3, 2): "B"})
	assert_eq(RulesAttack.targets(du_state, du_state.unit_by_id(3)), [] as Array[Vector2i],
		"Dư: Bộ binh kề 3,2 không có viền (Story 2.4)")
	_attack(state, 1, Vector2i(3, 2))
	assert_eq(RulesAttack.targets(state, khoai), [] as Array[Vector2i], "đã đánh")


func test_end_turn_clears_attacked() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"})
	_attack(state, 1, Vector2i(3, 3))
	Rules.resolve(state, Command.end_turn())
	assert_false(state.unit_by_id(1).has_attacked)
	assert_eq(RulesAttack.targets(state, state.unit_by_id(1)), [] as Array[Vector2i], "Bộ binh đã bị đẩy ra xa")


func test_stats_read_damage_and_push_distance() -> void:
	var stats: Stats = BoardFixture.stats()
	assert_eq(stats.damage(UnitType.NGUYEN_KHOAI), 2)
	assert_eq(stats.push_distance(UnitType.NGUYEN_KHOAI), 1)
	assert_eq(stats.damage(UnitType.PHAM_NGU_LAO), 1)
	assert_eq(stats.min_range(UnitType.PHAM_NGU_LAO), 2)
	assert_eq(stats.max_range(UnitType.PHAM_NGU_LAO), 4)
	assert_eq(stats.pull_range(UnitType.TRAN_KHANH_DU), 3)
	assert_eq(stats.pull_distance(UnitType.TRAN_KHANH_DU), 2)


func test_grid_direction_helpers() -> void:
	assert_eq(Grid.dir_between(Vector2i(3, 3), Vector2i(3, 2)), Vector2i(0, -1))
	assert_true(Grid.is_adjacent(Vector2i(3, 3), Vector2i(4, 3)))
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(4, 4)), "chéo không kề")
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(3, 3)))
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(3, 5)))
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(3, 0)), Vector2i(0, -1))
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(6, 3)), Vector2i(1, 0))
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(3, 4)), Vector2i(0, 1))
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(0, 3)), Vector2i(-1, 0))
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(5, 5)), Vector2i.ZERO, "chéo")
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(4, 5)), Vector2i.ZERO, "lệch hàng")
	assert_eq(Grid.straight_dir(Vector2i(3, 3), Vector2i(3, 3)), Vector2i.ZERO, "cùng ô")
	assert_eq(Grid.distance(Vector2i(3, 3), Vector2i(3, 0)), 3)
	assert_eq(Grid.distance(Vector2i(3, 3), Vector2i(5, 4)), 3)


# ---------- Lao của Phạm Ngũ Lão (Story 2.3) ----------

func test_lance_hits_cells_two_to_four_in_every_direction() -> void:
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	for dir: Vector2i in dirs:
		for d: int in [2, 3, 4]:
			# Lão ở góc ngược hướng để đủ 4 ô trong bàn.
			var lao_cell: Vector2i = Vector2i(3, 3) - dir * 3
			var target: Vector2i = lao_cell + dir * d
			var state: BattleState = BoardFixture.state({lao_cell: "2", target: "B"})
			var at: String = BoardText.cell_text(target)
			assert_eq(_attack(state, 2, target), ["ATTACKED 2 %s" % at, "DAMAGED 101 -1 STRIKE"] as Array[String],
				"%s ô %d" % [dir, d])
			assert_eq(state.unit_by_id(101).cell, target, "lao không đẩy")
			assert_eq(state.unit_by_id(101).hp, 2)
			assert_true(state.unit_by_id(2).has_attacked)
			assert_false(state.unit_by_id(2).has_moved, "phóng không tính là đi")


func test_lance_flies_over_adjacent_unit_of_any_side() -> void:
	for adjacent: String in ["B", "1"]:
		var state: BattleState = BoardFixture.state({Vector2i(3, 5): "2", Vector2i(3, 4): adjacent, Vector2i(3, 2): "K"})
		var adjacent_unit: Unit = state.unit_at(Vector2i(3, 4))
		assert_eq(_attack(state, 2, Vector2i(3, 2)), ["ATTACKED 2 3,2", "DAMAGED %d -1 STRIKE" % state.unit_at(
			Vector2i(3, 2)).id] as Array[String], adjacent)
		assert_eq(adjacent_unit.hp, 3, "quân kề không bị gì: %s" % adjacent)


func test_lance_hits_nearest_of_two_enemies() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 2): "2", Vector2i(2, 2): "B", Vector2i(4, 2): "B"})
	assert_eq(_attack(state, 2, Vector2i(2, 2)), ["ATTACKED 2 2,2", "DAMAGED 101 -1 STRIKE"] as Array[String])
	assert_eq(state.unit_by_id(102).hp, 3, "con xa không bị gì")


## Bấm quân Nguyên đứng sau tướng mình: lao trúng tướng mình; ATTACKED ghi ô quân trúng.
func test_lance_hits_blocking_general() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 6): "2", Vector2i(3, 4): "1", Vector2i(3, 3): "B"})
	assert_eq(_attack(state, 2, Vector2i(3, 3)), ["ATTACKED 2 3,4", "DAMAGED 1 -1 STRIKE"] as Array[String])
	assert_eq(state.unit_by_id(1).hp, 2)
	assert_eq(state.unit_by_id(101).hp, 3)


func test_lance_can_kill_blocking_general() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 6): "2", Vector2i(3, 4): "1", Vector2i(3, 3): "B"}, {},
		{Vector2i(3, 4): 1})
	assert_eq(_attack(state, 2, Vector2i(3, 3)), ["ATTACKED 2 3,4", "DAMAGED 1 -1 STRIKE", "DIED 1 3,4"] as Array[String])
	assert_null(state.unit_by_id(1))


func test_lance_kills_at_max_range_without_moving_anyone() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(5, 6): "2", Vector2i(5, 2): "C", Vector2i(0, 0): "B"})
	assert_eq(_attack(state, 2, Vector2i(5, 2)), ["ATTACKED 2 5,2", "DAMAGED 102 -1 STRIKE", "DIED 102 5,2"] as Array[String])


func test_lance_flies_over_river() -> void:
	for river: Array in [[Vector2i(2, 5)], [Vector2i(3, 5)], [Vector2i(2, 5), Vector2i(3, 5)]]:
		var terrain: Dictionary = {}
		for cell: Vector2i in river:
			terrain[cell] = "~"
		var state: BattleState = BoardFixture.state({Vector2i(1, 5): "2", Vector2i(4, 5): "B"}, terrain)
		assert_eq(_attack(state, 2, Vector2i(4, 5)), ["ATTACKED 2 4,5", "DAMAGED 101 -1 STRIKE"] as Array[String],
			str(river))


func test_lance_rejections_keep_state() -> void:
	var units: Dictionary = {Vector2i(1, 1): "2", Vector2i(2, 1): "B", Vector2i(3, 1): "B", Vector2i(4, 1): "B",
		Vector2i(1, 6): "B", Vector2i(3, 3): "K", Vector2i(1, 4): "1"}
	var cases: Array = [
		[Vector2i(2, 1), "NOT_IN_RANGE"],  # kề
		[Vector2i(3, 3), "NOT_IN_RANGE"],  # chéo
		[Vector2i(1, 6), "NOT_IN_RANGE"],  # cách 5
		[Vector2i(1, -1), "NOT_IN_RANGE"],  # ngoài bàn, thẳng hàng, cách 2
		[Vector2i(-2, 1), "NOT_IN_RANGE"],  # ngoài bàn, cách 3
		[Vector2i(1, 3), "NO_TARGET"],  # ô trống trong tầm
		[Vector2i(1, 4), "NO_TARGET"],  # tướng mình
		[Vector2i(4, 1), "NO_TARGET"],  # Bộ binh đứng sau Bộ binh 3,1
	]
	for c: Array in cases:
		var state: BattleState = BoardFixture.state(units)
		var before: Array[String] = BoardFixture.picture(state)
		assert_eq(_attack(state, 2, c[0] as Vector2i), ["REJECTED %s" % c[1]] as Array[String], str(c))
		assert_eq(BoardFixture.picture(state), before, "state giữ nguyên: %s" % str(c))
		assert_false(state.unit_by_id(2).has_attacked, str(c))


func test_lance_once_per_turn_and_no_move_after() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 3): "2", Vector2i(4, 3): "B", Vector2i(1, 0): "B"})
	_attack(state, 2, Vector2i(4, 3))
	var before: Array[String] = BoardFixture.picture(state)
	assert_eq(_attack(state, 2, Vector2i(1, 0)), ["REJECTED ALREADY_ATTACKED"] as Array[String])
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(2, Vector2i(1, 4)))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đi")
	assert_eq(BoardFixture.describe(events), ["REJECTED ALREADY_ATTACKED"] as Array[String])
	assert_eq(BoardFixture.picture(state), before)


func test_move_then_lance() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 5): "2", Vector2i(4, 3): "B"})
	Rules.resolve(state, Command.move(2, Vector2i(1, 3)))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đi")
	assert_eq(_attack(state, 2, Vector2i(4, 3)), ["ATTACKED 2 4,3", "DAMAGED 101 -1 STRIKE"] as Array[String])
	assert_true(state.unit_by_id(2).has_moved)


func test_lance_targets() -> void:
	# Bắc: Bộ binh kề 3,2 bay qua, 3,1 có viền. Đông: 6,3 cách 3. Nam: Khoái 3,5 chắn, Bộ binh 3,6 vẫn có viền.
	# Tây: Cung kỵ kề 2,3 bay qua, phía sau trống: không có viền.
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "2", Vector2i(3, 2): "B", Vector2i(3, 1): "B",
		Vector2i(3, 0): "B", Vector2i(6, 3): "K", Vector2i(3, 5): "1", Vector2i(3, 6): "B", Vector2i(2, 3): "C"})
	var lao: Unit = state.unit_by_id(2)
	assert_eq(RulesAttack.targets(state, lao), [Vector2i(3, 1), Vector2i(6, 3), Vector2i(3, 6)] as Array[Vector2i],
		"B→Đ→N→T, mỗi hướng quân Nguyên gần nhất ở ô 2–4")
	var only_general: BattleState = BoardFixture.state({Vector2i(3, 6): "2", Vector2i(3, 4): "1"})
	assert_eq(RulesAttack.targets(only_general, only_general.unit_by_id(2)), [] as Array[Vector2i],
		"chỉ có tướng mình trong tầm: không có viền")
	var far: BattleState = BoardFixture.state({Vector2i(0, 6): "2", Vector2i(0, 1): "B", Vector2i(5, 6): "B"})
	assert_eq(RulesAttack.targets(far, far.unit_by_id(2)), [] as Array[Vector2i], "cách 5: ngoài tầm")
	# Lão ở 1,5: ô thứ 2 về Nam (1,7) và về Tây (-1,5) đã ra ngoài bàn, dừng hướng đó.
	var edge: BattleState = BoardFixture.state({Vector2i(1, 5): "2", Vector2i(1, 3): "B", Vector2i(4, 5): "B"})
	assert_eq(RulesAttack.targets(edge, edge.unit_by_id(2)), [Vector2i(1, 3), Vector2i(4, 5)] as Array[Vector2i],
		"dừng ở mép bàn")
	_attack(state, 2, Vector2i(3, 1))
	assert_eq(RulesAttack.targets(state, lao), [] as Array[Vector2i], "đã phóng")


# ---------- Kéo của Trần Khánh Dư (Story 2.4) ----------

func _cell(c: Vector2i) -> String:
	return BoardText.cell_text(c)


func test_pull_three_cells_away_moves_two_in_every_direction() -> void:
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	for dir: Vector2i in dirs:
		var du_cell: Vector2i = Vector2i(3, 3)
		var target: Vector2i = du_cell + dir * 3
		var state: BattleState = BoardFixture.state({du_cell: "3", target: "B"})
		assert_eq(_attack(state, 3, target), ["ATTACKED 3 %s" % _cell(target),
			"MOVED 101 %s>%s PULL" % [_cell(target), _cell(du_cell + dir * 2)],
			"MOVED 101 %s>%s PULL" % [_cell(du_cell + dir * 2), _cell(du_cell + dir)]] as Array[String], str(dir))
		assert_eq(state.unit_by_id(101).cell, du_cell + dir, "đứng kề Dư")
		assert_eq(state.unit_by_id(101).hp, 3, "kéo không mất máu")
		assert_true(state.unit_by_id(3).has_attacked)
		assert_false(state.unit_by_id(3).has_moved, "kéo không tính là đi")


func test_pull_at_two_cells_stops_next_to_du() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 3): "3", Vector2i(3, 3): "B"})
	assert_eq(_attack(state, 3, Vector2i(3, 3)), ["ATTACKED 3 3,3", "MOVED 101 3,3>2,3 PULL"] as Array[String])
	assert_eq(state.unit_by_id(101).hp, 3, "không va Dư")
	assert_eq(state.unit_by_id(3).hp, 3, "Dư không mất máu")


func test_pull_into_river_drowns() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 3): "3", Vector2i(4, 3): "K", Vector2i(6, 6): "B"},
		{Vector2i(3, 3): "~"})
	assert_eq(_attack(state, 3, Vector2i(4, 3)), ["ATTACKED 3 4,3", "MOVED 101 4,3>3,3 PULL",
		"DROWNED 101 3,3"] as Array[String])
	assert_null(state.unit_by_id(101), "bị nhấc khỏi bàn")
	assert_eq(state.unit_by_id(102).cell, Vector2i(6, 6))


func test_pull_does_not_damage_one_hp_unit() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "3", Vector2i(3, 2): "C", Vector2i(0, 0): "B"})
	# Bộ binh 0,0 là 101, Cung kỵ là 102.
	assert_eq(_attack(state, 3, Vector2i(3, 2)), ["ATTACKED 3 3,2", "MOVED 102 3,2>3,3 PULL",
		"MOVED 102 3,3>3,4 PULL"] as Array[String])
	assert_eq(state.unit_by_id(102).hp, 1)


func test_pull_leaves_unit_behind_target_alone() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "3", Vector2i(3, 2): "B", Vector2i(3, 1): "K"})
	_attack(state, 3, Vector2i(3, 2))
	assert_eq(state.unit_at(Vector2i(3, 1)).type, UnitType.KY_BINH, "quân sau mục tiêu đứng yên")
	assert_eq(state.unit_at(Vector2i(3, 1)).hp, 2)


func test_pull_blocked_by_forest_collides_before_story_3_1() -> void:
	# Story 3.1 đổi ca này: rừng là vật đầu tiên trên hàng thì không kéo được. Trước đó rừng chỉ chặn đường kéo.
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "3", Vector2i(3, 2): "B"}, {Vector2i(3, 3): "#"})
	assert_eq(_attack(state, 3, Vector2i(3, 2)), ["ATTACKED 3 3,2", "COLLIDED 101 0 3,3",
		"DAMAGED 101 -1 COLLISION"] as Array[String])
	assert_eq(state.unit_by_id(101).cell, Vector2i(3, 2))


func test_pull_rejections_keep_state() -> void:
	var units: Dictionary = {Vector2i(0, 3): "B", Vector2i(1, 3): "3", Vector2i(3, 3): "2", Vector2i(4, 3): "B",
		Vector2i(5, 3): "B", Vector2i(2, 4): "K", Vector2i(1, 5): "B", Vector2i(1, 6): "B"}
	var cases: Array = [
		[Vector2i(0, 3), "NOT_IN_RANGE"],  # kề
		[Vector2i(2, 4), "NOT_IN_RANGE"],  # chéo
		[Vector2i(5, 3), "NOT_IN_RANGE"],  # cách 4
		[Vector2i(1, -1), "NOT_IN_RANGE"],  # ngoài bàn, thẳng hàng
		[Vector2i(1, 3), "NOT_IN_RANGE"],  # chính ô Dư
		[Vector2i(1, 1), "NO_TARGET"],  # ô trống trong tầm
		[Vector2i(3, 3), "NO_TARGET"],  # tướng mình
		[Vector2i(4, 3), "NO_TARGET"],  # sau tướng mình
		[Vector2i(1, 6), "NO_TARGET"],  # Bộ binh sau Bộ binh 1,5
	]
	for c: Array in cases:
		var state: BattleState = BoardFixture.state(units)
		var before: Array[String] = BoardFixture.picture(state)
		assert_eq(_attack(state, 3, c[0] as Vector2i), ["REJECTED %s" % c[1]] as Array[String], str(c))
		assert_eq(BoardFixture.picture(state), before, "state giữ nguyên: %s" % str(c))
		assert_false(state.unit_by_id(3).has_attacked, str(c))


func test_pull_once_per_turn_and_no_move_after() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "3", Vector2i(3, 2): "B", Vector2i(6, 5): "B"})
	_attack(state, 3, Vector2i(3, 2))
	var before: Array[String] = BoardFixture.picture(state)
	assert_eq(_attack(state, 3, Vector2i(6, 5)), ["REJECTED ALREADY_ATTACKED"] as Array[String])
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(3, Vector2i(2, 5)))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đi")
	assert_eq(BoardFixture.describe(events), ["REJECTED ALREADY_ATTACKED"] as Array[String])
	assert_eq(BoardFixture.picture(state), before)


func test_move_then_pull() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 6): "3", Vector2i(3, 2): "B"})
	Rules.resolve(state, Command.move(3, Vector2i(3, 5)))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đi")
	assert_eq(_attack(state, 3, Vector2i(3, 2)), ["ATTACKED 3 3,2", "MOVED 101 3,2>3,3 PULL",
		"MOVED 101 3,3>3,4 PULL"] as Array[String])
	assert_true(state.unit_by_id(3).has_moved)


func test_pull_targets() -> void:
	# Bắc: 3,0 cách 3 có viền. Đông: sông 4,3 không chặn, 6,3 cách 3 có viền. Nam: Khoái kề chắn, Bộ binh 3,6
	# phía sau không có viền. Tây: Bộ binh kề 2,3 chắn, Cung kỵ 1,3 sau nó không có viền.
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "3", Vector2i(3, 0): "B", Vector2i(6, 3): "K",
		Vector2i(3, 4): "1", Vector2i(3, 6): "B", Vector2i(2, 3): "B", Vector2i(1, 3): "C"}, {Vector2i(4, 3): "~"})
	var du: Unit = state.unit_by_id(3)
	assert_eq(RulesAttack.targets(state, du), [Vector2i(3, 0), Vector2i(6, 3)] as Array[Vector2i],
		"B→Đ→N→T; Nam: tướng mình chắn; Tây: quân kề chắn")
	var gap: BattleState = BoardFixture.state({Vector2i(3, 3): "3", Vector2i(3, 1): "B", Vector2i(3, 0): "B"})
	assert_eq(RulesAttack.targets(gap, gap.unit_by_id(3)), [Vector2i(3, 1)] as Array[Vector2i],
		"cách 2 ô có viền; con sau nó thì không")
	var far: BattleState = BoardFixture.state({Vector2i(0, 6): "3", Vector2i(0, 1): "B", Vector2i(4, 6): "B"})
	assert_eq(RulesAttack.targets(far, far.unit_by_id(3)), [] as Array[Vector2i], "cách 5 và cách 4: ngoài tầm")
	var edge: BattleState = BoardFixture.state({Vector2i(1, 5): "3", Vector2i(1, 2): "B", Vector2i(4, 5): "B"})
	assert_eq(RulesAttack.targets(edge, edge.unit_by_id(3)), [Vector2i(1, 2), Vector2i(4, 5)] as Array[Vector2i],
		"dừng ở mép bàn (Nam và Tây ra ngoài bàn)")
	_attack(state, 3, Vector2i(3, 0))
	assert_eq(RulesAttack.targets(state, du), [] as Array[Vector2i], "đã kéo")
