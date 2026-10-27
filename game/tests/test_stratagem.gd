extends GutTest
## Mưu kế Vườn không nhà trống (Story 3.12): thứ tự sự kiện, tiếp viện, chơi lại hiệp, báo lỗi F2.
## Luật chính đã khóa bằng kịch bản muu_ke/; ở đây là những gì kịch bản không so được.

const VKNT: int = Stratagem.Kind.VUON_KHONG_NHA_TRONG


func _state(units: Dictionary, terrain: Dictionary = {}, hp: Dictionary = {}) -> BattleState:
	var state: BattleState = BoardFixture.state(units, terrain, hp)
	state.stratagems = [VKNT] as Array[int]
	return state


func _types(events: Array[BattleEvent]) -> Array[String]:
	var out: Array[String] = []
	for e: BattleEvent in events:
		out.append(BattleEvent.Type.find_key(e.type))
	return out


## Đốt kho trước (theo thứ tự đọc bàn), rồi trừ máu theo thứ tự hành động; DIED ngay sau DAMAGED của quân đó.
func test_events_burn_granaries_then_damage_in_order() -> void:
	var state: BattleState = _state(
		{Vector2i(6, 0): "B", Vector2i(0, 2): "C", Vector2i(3, 6): "1"},
		{Vector2i(5, 4): "L", Vector2i(1, 1): "L"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.use_stratagem(VKNT))
	assert_eq(state.validate(), [] as Array[String])
	assert_eq(_types(events), ["STRATAGEM_USED", "GRANARY_BURNED", "GRANARY_BURNED", "DAMAGED", "DAMAGED", "DIED"])
	assert_eq(events[0].amount, VKNT)
	assert_eq(events[1].to_cell, Vector2i(1, 1), "kho phía trên đốt trước")
	assert_eq(events[2].to_cell, Vector2i(5, 4))
	assert_eq(events[3].unit_id, 101, "Bộ binh (id nhỏ hơn) mất máu trước")
	assert_eq(events[3].cause, BattleEvent.Cause.STRATAGEM)
	assert_eq(events[4].unit_id, 102)
	assert_eq(state.stratagems_used, [VKNT] as Array[int])


## Quân tiếp viện (id lớn hơn) mất máu sau quân cũ.
func test_reinforcement_damaged_after_original_units() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	var newcomer: Unit = UnitFactory.create(state.next_enemy_id, UnitType.BO_BINH, Vector2i(0, 0), state.stats)
	state.units.insert(0, newcomer)  # đứng đầu danh sách mà vẫn phải sau quân cũ
	state.next_enemy_id += 1
	var events: Array[BattleEvent] = Rules.resolve(state, Command.use_stratagem(VKNT))
	var damaged: Array[int] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.DAMAGED:
			damaged.append(e.unit_id)
	assert_eq(damaged, [101, newcomer.id] as Array[int])


## Tham số lấy từ chi_so.json, không viết cứng.
func test_damage_comes_from_stats() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"}, {}, {},
		BoardFixture.DEFAULT_SIZE, Stats.new(BoardFixture.values(), {VKNT: {"sat_thuong": 2}}))
	state.stratagems = [VKNT] as Array[int]
	Rules.resolve(state, Command.use_stratagem(VKNT))
	assert_eq(state.unit_by_id(101).hp, 1)


func test_rejected_command_changes_nothing() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"}, {Vector2i(1, 1): "L"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.use_stratagem(VKNT))
	assert_eq(_types(events), ["REJECTED"])
	assert_eq(events[0].reject, BattleEvent.Reject.STRATAGEM_LOCKED)
	assert_eq(state.terrain_at(Vector2i(1, 1)), Terrain.GRANARY)
	assert_eq(state.stratagems_used, [] as Array[int])


func test_clone_and_validate_keep_stratagem_flags() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	state.stratagems_used = [VKNT] as Array[int]
	var copy: BattleState = state.clone()
	assert_eq(copy.stratagems, [VKNT] as Array[int])
	assert_eq(copy.stratagems_used, [VKNT] as Array[int])
	copy.stratagems_used.clear()
	assert_eq(state.stratagems_used, [VKNT] as Array[int], "bản sao không dùng chung mảng")
	state.stratagems = [] as Array[int]
	assert_eq(state.validate(), ["mưu kế vuon_khong_nha_trong đã dùng mà không mở trong trận"] as Array[String])


## Ghi đã dùng trùng: báo đúng một câu, dù trùng mấy lần.
func test_validate_reports_duplicate_used_once() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	state.stratagems_used = [VKNT, VKNT, VKNT] as Array[int]
	assert_eq(state.validate(), ["mưu kế vuon_khong_nha_trong bị ghi đã dùng hai lần"] as Array[String])


## Trận Tiêu diệt: mưu kế diệt hết quân trên bàn nhưng còn tiếp viện chưa ra thì chưa thắng.
func test_clearing_board_with_reinforcements_pending_is_not_victory() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"}, {}, {Vector2i(6, 0): 1})
	state.reinforcements.append(LevelData.Reinforcement.new(2, Vector2i(0, 0), UnitType.BO_BINH))
	var events: Array[BattleEvent] = Rules.resolve(state, Command.use_stratagem(VKNT))
	assert_eq(state.validate(), [] as Array[String])
	assert_true(_types(events).has("DIED"), "quân trên bàn gục")
	assert_false(_types(events).has("VICTORY"))
	assert_eq(state.phase, BattleState.Phase.PLAYER, "còn tiếp viện nên chưa thắng")


## HUD xếp nút theo thứ tự phím (Stratagem.SLOTS), không theo thứ tự "muu_ke_mo" (tác giả chốt 2026-10-27).
func test_key_order_follows_slots() -> void:
	var slot_order: Array[int] = []
	for slot: Array in Stratagem.SLOTS:
		slot_order.append(slot[0] as int)
	var reversed: Array[int] = slot_order.duplicate()
	reversed.reverse()
	assert_eq(Stratagem.in_key_order(reversed), slot_order)
	assert_eq(Stratagem.in_key_order([] as Array[int]), [] as Array[int])
	assert_eq(Stratagem.SLOTS[0], [VKNT, "stratagem_1", KEY_Q], "Vườn không nhà trống là phím Q")


func _level() -> LevelData:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(5, 5)
	for i: int in range(level.size.x * level.size.y):
		level.terrain.append(Terrain.PLAIN)
	level.terrain[0] = Terrain.GRANARY
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(1, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(2, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(4, 4)))
	level.stratagems = [VKNT] as Array[int]
	return level


func _controller() -> BattleController:
	var c: BattleController = BattleController.new()
	c.start(_level(), BoardFixture.stats())
	c.begin()
	return c


## AC 7 (FR39): chơi lại hiệp trả lại mưu kế dùng trong lượt; kho và máu cũng về như đầu lượt.
func test_replay_gives_back_stratagem_used_this_turn() -> void:
	var c: BattleController = _controller()
	assert_true(c.can_use_stratagem(VKNT))
	c.submit(Command.use_stratagem(VKNT))
	assert_false(c.can_use_stratagem(VKNT), "dùng rồi")
	assert_eq(c.stratagems_used(), [VKNT] as Array[int])
	assert_true(c.replay_round())
	assert_true(c.can_use_stratagem(VKNT), "được trả lại")
	var after: BattleState = c.snapshot()
	assert_eq(after.terrain_at(Vector2i(0, 0)), Terrain.GRANARY, "kho về như cũ")
	assert_eq(after.unit_by_id(101).hp, 3)


## Mưu kế dùng ở hiệp trước thì chơi lại hiệp này không trả lại.
func test_replay_keeps_stratagem_used_in_earlier_round() -> void:
	var c: BattleController = _controller()
	c.submit(Command.use_stratagem(VKNT))
	c.submit(Command.end_turn())
	assert_true(c.replay_round())
	assert_false(c.can_use_stratagem(VKNT))
	assert_eq(c.stratagems_used(), [VKNT] as Array[int])


## FR10: dùng mưu kế xóa bản chụp hủy; không tốn hành động của tướng.
func test_stratagem_clears_undo_and_keeps_general_actions() -> void:
	var c: BattleController = _controller()
	c.submit(Command.move(1, Vector2i(1, 2)))
	assert_true(c.can_undo())
	c.submit(Command.use_stratagem(VKNT))
	assert_false(c.can_undo())
	var khoai: Unit = c.snapshot().unit_by_id(1)
	assert_true(khoai.has_moved)
	assert_false(khoai.has_attacked)


func test_cannot_use_when_locked_or_battle_over() -> void:
	var level: LevelData = _level()
	level.stratagems = [] as Array[int]
	var c: BattleController = BattleController.new()
	c.start(level, BoardFixture.stats())
	c.begin()
	assert_false(c.can_use_stratagem(VKNT), "trận không mở")
	# Một quân Nguyên 1 máu kề Khoái: đánh gục là thắng.
	var one_enemy: LevelData = _level()
	one_enemy.units.remove_at(2)
	one_enemy.units[1] = LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(2, 1), 1)
	var won: BattleController = BattleController.new()
	won.start(one_enemy, BoardFixture.stats())
	won.begin()
	won.submit(Command.attack(1, Vector2i(2, 1)))
	assert_eq(won.snapshot().phase, BattleState.Phase.WON)
	assert_false(won.can_use_stratagem(VKNT), "hết trận")
	var events: Array[BattleEvent] = won.submit(Command.use_stratagem(VKNT))
	assert_eq(events[0].reject, BattleEvent.Reject.BATTLE_OVER)


## F2: báo cáo có lệnh mưu kế phát lại ra đúng bàn đang chơi.
func test_bug_report_replays_stratagem() -> void:
	var c: BattleController = _controller()
	c.submit(Command.use_stratagem(VKNT))
	c.submit(Command.use_stratagem(VKNT))  # bị từ chối, vẫn ghi
	var data: Dictionary = BugReport.scenario_data(c.snapshot(), c.round_start_snapshot(), c.round_commands(), {})
	var truoc: Dictionary = data["truoc"] as Dictionary
	assert_eq(truoc["muu_ke_mo"], ["vuon_khong_nha_trong"])
	assert_false(truoc.has("muu_ke_da_dung"))
	assert_eq(data["hanh_dong"], [{"lenh": "muu_ke", "ten": "vuon_khong_nha_trong"},
		{"lenh": "muu_ke", "ten": "vuon_khong_nha_trong", "tu_choi": "muu_ke_da_dung"}])
	assert_eq((data["sau"] as Dictionary)["muu_ke_da_dung"], ["vuon_khong_nha_trong"])
	var result: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(data, "  "), "user://bao_loi_f2.json",
		"res://", BoardFixture.stats())
	assert_eq(result.errors, [] as Array[String])
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(result.data as ScenarioData, BoardFixture.stats())
	assert_true(run.passed, str(run.problems))


## F2 ở hiệp sau: bàn đầu hiệp ghi mưu kế đã dùng từ trước.
func test_bug_report_records_stratagem_used_before_round() -> void:
	var c: BattleController = _controller()
	c.submit(Command.use_stratagem(VKNT))
	c.submit(Command.end_turn())
	# Cần một lệnh chạy được ở hiệp 2, nếu không báo cáo còn dùng hiệp 1 (Story 2.13).
	assert_false(c.submit(Command.move(1, Vector2i(1, 0))).is_empty())
	c.submit(Command.use_stratagem(VKNT))
	var data: Dictionary = BugReport.scenario_data(c.snapshot(), c.round_start_snapshot(), c.round_commands(), {})
	assert_eq((data["truoc"] as Dictionary)["muu_ke_da_dung"], ["vuon_khong_nha_trong"])
	var result: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(data, "  "), "user://bao_loi_f2.json",
		"res://", BoardFixture.stats())
	assert_eq(result.errors, [] as Array[String])
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(result.data as ScenarioData, BoardFixture.stats())
	assert_true(run.passed, str(run.problems))
