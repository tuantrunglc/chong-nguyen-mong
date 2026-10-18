extends GutTest
## Đòn Nguyễn Khoái (Story 2.1): đánh ô kề có quân Nguyên, 2 sát thương, đẩy 1 ô theo hướng đánh; bảng từ chối;
## đánh một lần mỗi lượt. Chỉ số tự đặt (BoardFixture).


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
		[2, Vector2i(4, 3), "NO_TARGET"],
		[3, Vector2i(4, 3), "NO_TARGET"],
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
	assert_eq(RulesAttack.targets(state, state.unit_by_id(2)), [] as Array[Vector2i], "Lão chưa có đòn (2.3)")
	var du_state: BattleState = BoardFixture.state({Vector2i(3, 3): "3", Vector2i(3, 2): "B"})
	assert_eq(RulesAttack.targets(du_state, du_state.unit_by_id(3)), [] as Array[Vector2i], "Dư chưa có đòn (2.4)")
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


func test_grid_direction_helpers() -> void:
	assert_eq(Grid.dir_between(Vector2i(3, 3), Vector2i(3, 2)), Vector2i(0, -1))
	assert_true(Grid.is_adjacent(Vector2i(3, 3), Vector2i(4, 3)))
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(4, 4)), "chéo không kề")
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(3, 3)))
	assert_false(Grid.is_adjacent(Vector2i(3, 3), Vector2i(3, 5)))
