extends GutTest
## Thắng và thua của trận Tiêu diệt (Story 2.5, FR36, FR38): kiểm sau mỗi lệnh có quân gục, thắng trước thua,
## số tướng lấy từ bàn, khóa mọi lệnh khi hết trận. Chỉ số tự đặt (BoardFixture).
## Tướng cuối không tự gục bằng lệnh của người chơi (chưa có đòn địch, Story 2.8), nên ca thua dựng thẳng bằng
## Effects.damage rồi gọi RulesVictory.check như Rules.resolve sẽ gọi.


func _attack(state: BattleState, id: int, cell: Vector2i) -> Array[String]:
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(id, cell))
	assert_eq(state.validate(), [] as Array[String], "bất biến sau lệnh đánh")
	return BoardFixture.describe(events)


## Giết quân unit_id bằng Effects.damage (ghi sự kiện vào events), chưa kiểm kết cục.
func _kill(state: BattleState, id: int, events: Array[BattleEvent]) -> void:
	var unit: Unit = state.unit_by_id(id)
	Effects.damage(state, unit, unit.hp, BattleEvent.Cause.STRIKE, events)


func _check(state: BattleState, events: Array[BattleEvent]) -> Array[String]:
	RulesVictory.check(state, events)
	return BoardFixture.describe(events)


func _last(events: Array[String]) -> String:
	return events[events.size() - 1] if not events.is_empty() else ""


func test_last_enemy_dies_by_damage_wins() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"}, {},
		{Vector2i(3, 3): 1})
	assert_eq(state.phase, BattleState.Phase.PLAYER, "trước: đang chơi")
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -1 STRIKE", "DIED 101 3,3",
		"VICTORY"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.WON)


func test_last_enemy_drowns_by_push_wins() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(2, 3): "1", Vector2i(3, 3): "B"}, {Vector2i(4, 3): "~"})
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -2 STRIKE",
		"MOVED 101 3,3>4,3 PUSH", "DROWNED 101 4,3", "VICTORY"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.WON)


func test_last_enemy_drowns_by_pull_next_to_du_wins() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 3): "3", Vector2i(4, 3): "B"}, {Vector2i(2, 3): "~"})
	assert_eq(_attack(state, 3, Vector2i(4, 3)), ["ATTACKED 3 4,3", "MOVED 101 4,3>3,3 PULL",
		"MOVED 101 3,3>2,3 PULL", "DROWNED 101 2,3", "VICTORY"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.WON)


func test_two_enemies_die_in_one_collision_wins() -> void:
	# Bộ binh 3,3 (1 máu) là 101, Bộ binh 3,4 là 102.
	var state: BattleState = BoardFixture.state({Vector2i(3, 5): "1", Vector2i(3, 4): "B", Vector2i(3, 3): "B"}, {},
		{Vector2i(3, 3): 1})
	var events: Array[String] = _attack(state, 1, Vector2i(3, 4))
	assert_eq(_last(events), "VICTORY")
	assert_eq(events.count("VICTORY"), 1, "chỉ một sự kiện kết cục")
	assert_eq(state.phase, BattleState.Phase.WON)
	assert_eq(state.units.size(), 1, "chỉ còn Khoái")


func test_other_enemy_left_means_no_outcome() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B", Vector2i(6, 6): "B"}, {},
		{Vector2i(3, 3): 1})
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -1 STRIKE",
		"DIED 101 3,3"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.PLAYER)


func test_no_death_means_no_check() -> void:
	# Bàn không có quân Nguyên từ đầu: một lệnh đi không làm ai gục thì không kiểm, không thắng ngay.
	var state: BattleState = BoardFixture.state({Vector2i(3, 6): "1"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(3, 5)))
	assert_eq(BoardFixture.describe(events), ["MOVED 1 3,6>3,5 WALK"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_eq(_check(state, [] as Array[BattleEvent]), [] as Array[String], "danh sách không có quân gục")
	assert_eq(state.phase, BattleState.Phase.PLAYER)


func test_defeat_when_every_general_is_gone() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 5): "1", Vector2i(2, 5): "2", Vector2i(6, 0): "B"})
	var events: Array[BattleEvent] = []
	_kill(state, 1, events)
	assert_eq(_check(state, events), ["DAMAGED 1 -3 STRIKE", "DIED 1 1,5"] as Array[String], "còn Lão: chưa thua")
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	var more: Array[BattleEvent] = []
	_kill(state, 2, more)
	assert_eq(_check(state, more), ["DAMAGED 2 -3 STRIKE", "DIED 2 2,5", "DEFEAT"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.LOST)
	assert_eq(state.validate(), [] as Array[String])


## Số tướng lấy từ bàn, không viết cứng: 1, 2 hay 3 tướng đều thua đúng lúc tướng cuối gục.
func test_defeat_counts_generals_on_the_board() -> void:
	var layouts: Array = [
		{Vector2i(1, 5): "1"},
		{Vector2i(1, 5): "1", Vector2i(2, 5): "2"},
		{Vector2i(1, 5): "1", Vector2i(2, 5): "2", Vector2i(3, 5): "3"},
	]
	for layout: Dictionary in layouts:
		var units: Dictionary = layout.duplicate()
		units[Vector2i(6, 0)] = "B"
		var state: BattleState = BoardFixture.state(units)
		var generals: Array[int] = []
		for u: Unit in state.units:
			if u.faction == Unit.Faction.DAI_VIET:
				generals.append(u.id)
		for i: int in range(generals.size()):
			var events: Array[BattleEvent] = []
			_kill(state, generals[i], events)
			var shown: Array[String] = _check(state, events)
			if i < generals.size() - 1:
				assert_ne(_last(shown), "DEFEAT", "%d tướng: còn tướng thì chưa thua" % generals.size())
				assert_eq(state.phase, BattleState.Phase.PLAYER)
			else:
				assert_eq(_last(shown), "DEFEAT", "%d tướng: tướng cuối gục thì thua" % generals.size())
				assert_eq(state.phase, BattleState.Phase.LOST)


## Thắng được ưu tiên (FR38): quân Nguyên cuối và tướng cuối gục cùng một lệnh, thứ tự nào cũng vậy.
func test_victory_beats_defeat_in_either_order() -> void:
	for enemy_first: bool in [true, false]:
		var state: BattleState = BoardFixture.state({Vector2i(1, 5): "1", Vector2i(5, 1): "B"})
		var events: Array[BattleEvent] = []
		if enemy_first:
			_kill(state, 101, events)
			_kill(state, 1, events)
		else:
			_kill(state, 1, events)
			_kill(state, 101, events)
		var shown: Array[String] = _check(state, events)
		assert_eq(_last(shown), "VICTORY", "kết cục cuối (quân Nguyên trước: %s)" % enemy_first)
		assert_false(shown.has("DEFEAT"), "không có DEFEAT (quân Nguyên trước: %s)" % enemy_first)
		assert_eq(state.phase, BattleState.Phase.WON)
		assert_eq(state.validate(), [] as Array[String])


func test_check_does_not_repeat_the_outcome() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"}, {}, {Vector2i(3, 3): 1})
	var events: Array[BattleEvent] = []
	_kill(state, 101, events)
	RulesVictory.check(state, events)
	var count: int = events.size()
	RulesVictory.check(state, events)
	assert_eq(events.size(), count, "trận đã hết thì check không làm gì")
	assert_eq(BoardFixture.describe(events).count("VICTORY"), 1)


## Giữ ải (Story 3.11 viết luật thắng): hết quân Nguyên không thắng, nhưng hết tướng vẫn thua.
func test_hold_pass_is_not_won_by_clearing_enemies() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"}, {}, {Vector2i(3, 3): 1})
	state.mission = LevelData.Mission.HOLD_PASS
	assert_eq(_attack(state, 1, Vector2i(3, 3)), ["ATTACKED 1 3,3", "DAMAGED 101 -1 STRIKE",
		"DIED 101 3,3"] as Array[String])
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	var events: Array[BattleEvent] = []
	_kill(state, 1, events)
	assert_eq(_last(_check(state, events)), "DEFEAT")
	assert_eq(state.phase, BattleState.Phase.LOST)


func test_commands_are_locked_after_victory() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(0, 6): "2", Vector2i(3, 3): "B"}, {},
		{Vector2i(3, 3): 1})
	_attack(state, 1, Vector2i(3, 3))
	assert_eq(state.phase, BattleState.Phase.WON, "điều kiện trước")
	_assert_locked(state, BattleState.Phase.WON)


func test_commands_are_locked_after_defeat() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"})
	var events: Array[BattleEvent] = []
	_kill(state, 1, events)
	RulesVictory.check(state, events)
	assert_eq(state.phase, BattleState.Phase.LOST, "điều kiện trước")
	_assert_locked(state, BattleState.Phase.LOST)


func _assert_locked(state: BattleState, phase: BattleState.Phase) -> void:
	var before: Array[String] = BoardFixture.picture(state)
	var commands: Array[Command] = [Command.move(2, Vector2i(1, 6)), Command.attack(2, Vector2i(3, 3)),
		Command.attack(1, Vector2i(3, 3)), Command.end_turn()]
	for command: Command in commands:
		var events: Array[BattleEvent] = Rules.resolve(state, command)
		assert_eq(BoardFixture.describe(events), ["REJECTED BATTLE_OVER"] as Array[String], str(command.kind))
		assert_eq(BoardFixture.picture(state), before, "bàn giữ nguyên: %s" % str(command.kind))
		assert_eq(state.phase, phase, "kết cục giữ nguyên")
		assert_eq(state.round_number, 1, "không sang hiệp mới")
	assert_eq(state.validate(), [] as Array[String])


## Tướng hết máu bị nhấc khỏi bàn như quân Nguyên (FR38): ô trống ra, không chiếm chỗ.
func test_dead_general_leaves_the_board() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "1", Vector2i(2, 5): "2", Vector2i(6, 0): "B"})
	var events: Array[BattleEvent] = []
	_kill(state, 1, events)
	assert_null(state.unit_by_id(1))
	assert_null(state.unit_at(Vector2i(3, 3)), "ô trống")
	assert_eq(state.validate(), [] as Array[String])
	assert_eq(BoardFixture.describe(events), ["DAMAGED 1 -3 STRIKE", "DIED 1 3,3"] as Array[String])


## Bất biến: đã thắng (Tiêu diệt) thì không còn quân Nguyên.
func test_validate_flags_won_with_enemies_left() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 4): "1", Vector2i(3, 3): "B"})
	assert_eq(state.validate(), [] as Array[String])
	state.phase = BattleState.Phase.WON
	assert_eq(state.validate().size(), 1, "thắng mà còn quân Nguyên là sai")
	state.mission = LevelData.Mission.HOLD_PASS
	assert_eq(state.validate(), [] as Array[String], "Giữ ải không có bất biến này")
