extends GutTest
## Kiểm thử cơ chế quân tiếp viện (Story 3.10, FR35).

const STATS_PATH: String = "res://data/chi_so.json"


func _stats() -> Stats:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(r.errors, [] as Array[String], "chi_so.json nạp được")
	return r.data as Stats


func _base_level_dict() -> Dictionary:
	return {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử tiếp viện",
		"kieu": "tieu_diet",
		"dia_hinh": [
			". . . . .",
			". . . . .",
			". . . . .",
			". . . . .",
			". . . . ."
		],
		"quan": [
			"B . . . .",
			". . . . .",
			". . . . .",
			". . . . .",
			". . . 1 ."
		],
		"thu_tu_dich": ["0,0"],
		"tiep_vien": [
			{ "hiep": 2, "o": "3,0", "loai": "K" }
		],
		"muu_ke_mo": []
	}


func test_level_loader_reads_valid_reinforcements() -> void:
	var dict: Dictionary = _base_level_dict()
	dict["tiep_vien"] = [
		{ "hiep": 2, "o": "3,0", "loai": "K" },
		{ "hiep": 3, "o": "1,1", "loai": "B", "mau": 2 }
	]
	var text: String = JSON.stringify(dict)
	var r: LoadResult = LevelLoader.parse_level(text, "test.json")
	assert_true(r.ok, "Nạp level có tiếp viện thành công: " + "; ".join(r.errors))
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	assert_eq(level.reinforcements.size(), 2, "Có đúng 2 đợt tiếp viện")
	assert_eq(level.reinforcements[0].round, 2)
	assert_eq(level.reinforcements[0].cell, Vector2i(3, 0))
	assert_eq(level.reinforcements[0].type, UnitType.KY_BINH)
	assert_eq(level.reinforcements[0].hp, 0)

	assert_eq(level.reinforcements[1].round, 3)
	assert_eq(level.reinforcements[1].cell, Vector2i(1, 1))
	assert_eq(level.reinforcements[1].type, UnitType.BO_BINH)
	assert_eq(level.reinforcements[1].hp, 2)


func test_level_loader_rejects_invalid_reinforcements() -> void:
	# 1. tiep_vien không phải array
	var d1: Dictionary = _base_level_dict()
	d1["tiep_vien"] = "khong_phai_mang"
	var r1: LoadResult = LevelLoader.parse_level(JSON.stringify(d1), "test.json")
	assert_false(r1.ok)
	assert_string_contains("; ".join(r1.errors), '"tiep_vien" phải là một danh sách')

	# 2. mục không phải object
	var d2: Dictionary = _base_level_dict()
	d2["tiep_vien"] = [123]
	var r2: LoadResult = LevelLoader.parse_level(JSON.stringify(d2), "test.json")
	assert_false(r2.ok)
	assert_string_contains("; ".join(r2.errors), 'phải là một object')

	# 3. thiếu hiep hoặc hiep < 2
	var d3: Dictionary = _base_level_dict()
	d3["tiep_vien"] = [{ "o": "3,0", "loai": "K" }]
	var r3: LoadResult = LevelLoader.parse_level(JSON.stringify(d3), "test.json")
	assert_false(r3.ok)
	assert_string_contains("; ".join(r3.errors), 'thiếu khóa "hiep"')

	var d4: Dictionary = _base_level_dict()
	d4["tiep_vien"] = [{ "hiep": 1, "o": "3,0", "loai": "K" }]
	var r4: LoadResult = LevelLoader.parse_level(JSON.stringify(d4), "test.json")
	assert_false(r4.ok)
	assert_string_contains("; ".join(r4.errors), '"hiep" phải là số nguyên từ 2 trở lên')

	# 4. o ngoài bàn hoặc ô không đi vào được
	var d5: Dictionary = _base_level_dict()
	d5["tiep_vien"] = [{ "hiep": 2, "o": "10,10", "loai": "K" }]
	var r5: LoadResult = LevelLoader.parse_level(JSON.stringify(d5), "test.json")
	assert_false(r5.ok)
	assert_string_contains("; ".join(r5.errors), 'không phải ô trong bàn')

	var d6: Dictionary = _base_level_dict()
	d6["dia_hinh"] = [
		"# . . . .",
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	d6["tiep_vien"] = [{ "hiep": 2, "o": "0,0", "loai": "K" }]
	var r6: LoadResult = LevelLoader.parse_level(JSON.stringify(d6), "test.json")
	assert_false(r6.ok)
	assert_string_contains("; ".join(r6.errors), 'là ô không đi vào được')

	# 5. loai không hợp lệ
	var d7: Dictionary = _base_level_dict()
	d7["tiep_vien"] = [{ "hiep": 2, "o": "3,0", "loai": "1" }]
	var r7: LoadResult = LevelLoader.parse_level(JSON.stringify(d7), "test.json")
	assert_false(r7.ok)
	assert_string_contains("; ".join(r7.errors), '"loai" là "1", chỉ được "B", "K", "C"')


func test_battle_state_clone_and_validate_reinforcements() -> void:
	var stats: Stats = _stats()
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(_base_level_dict()), "test.json")
	assert_true(r.ok)
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	assert_eq(state.reinforcements.size(), 1)
	assert_eq(state.next_enemy_id, 102)

	var problems: Array[String] = state.validate()
	assert_eq(problems, [] as Array[String], "State ban đầu hợp lệ: " + "; ".join(problems))

	var copy: BattleState = state.clone()
	assert_eq(copy.reinforcements.size(), 1)
	assert_eq(copy.next_enemy_id, 102)
	assert_ne(copy.reinforcements[0], state.reinforcements[0], "Reinforcement được sao chép sâu")
	assert_eq(copy.reinforcements[0].round, state.reinforcements[0].round)
	assert_eq(copy.reinforcements[0].cell, state.reinforcements[0].cell)


func test_reinforcement_warned_at_end_of_round() -> void:
	var stats: Stats = _stats()
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(_base_level_dict()), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var warned: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.REINFORCEMENT_WARNED:
			warned.append(e)
	assert_eq(warned.size(), 1, "Có đúng 1 sự kiện REINFORCEMENT_WARNED được phát ở cuối hiệp")
	assert_eq(warned[0].to_cell, Vector2i(3, 0))
	assert_eq(warned[0].amount, UnitType.KY_BINH)
	assert_eq(warned[0].round_number, 2)


func test_reinforcement_spawns_on_empty_cell() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["dia_hinh"] = [
		". # . . .",
		"# # . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var spawned: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.REINFORCEMENT_SPAWNED:
			spawned.append(e)
	assert_eq(spawned.size(), 1, "Có sự kiện REINFORCEMENT_SPAWNED")
	assert_eq(spawned[0].unit_id, 102)
	assert_eq(spawned[0].to_cell, Vector2i(3, 0))
	assert_eq(spawned[0].amount, UnitType.KY_BINH)

	var new_unit: Unit = state.unit_by_id(102)
	assert_not_null(new_unit, "Quân tiếp viện có mặt trong state.units")
	assert_eq(new_unit.type, UnitType.KY_BINH)
	assert_eq(new_unit.hp, stats.max_hp(UnitType.KY_BINH))

	assert_true(state.reinforcements.is_empty(), "reinforcements của hiệp 2 đã được dọn sạch")
	assert_true(state.reinforcement_warnings.is_empty(), "reinforcement_warnings đã được làm sạch")
	assert_eq(state.validate(), [] as Array[String])


func test_reinforcement_blocked_by_hero_damages_hero_and_cancels() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["dia_hinh"] = [
		". # . . .",
		"# # . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["quan"] = [
		"B . . 1 .",
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["tiep_vien"] = [{ "hiep": 2, "o": "3,0", "loai": "K" }]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	var hero: Unit = state.unit_by_id(1)
	assert_eq(hero.cell, Vector2i(3, 0))
	assert_eq(hero.hp, 3)

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var blocked: Array[BattleEvent] = []
	var hero_damaged: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.REINFORCEMENT_BLOCKED:
			blocked.append(e)
		elif e.type == BattleEvent.Type.DAMAGED and e.unit_id == 1:
			hero_damaged.append(e)

	assert_eq(blocked.size(), 1, "Phát sự kiện REINFORCEMENT_BLOCKED")
	assert_eq(blocked[0].to_cell, Vector2i(3, 0))
	assert_eq(blocked[0].amount, UnitType.KY_BINH)
	assert_eq(blocked[0].other_id, 1)

	assert_eq(hero_damaged.size(), 1, "Tướng nhận sát thương do bị tiếp viện đè")
	assert_eq(hero_damaged[0].amount, 1)
	assert_eq(hero_damaged[0].cause, BattleEvent.Cause.REINFORCEMENT)

	assert_eq(hero.hp, 2, "Máu tướng còn 2")
	assert_null(state.unit_by_id(102), "Tiếp viện bị hủy, không có quân 102 trên bàn")
	assert_eq(state.validate(), [] as Array[String])


func test_reinforcement_blocked_by_enemy_damages_enemy() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["dia_hinh"] = [
		". . # . .",
		". . # . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["quan"] = [
		". . . B .",
		". . . 1 .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["3,0"]
	dict["tiep_vien"] = [{ "hiep": 2, "o": "3,0", "loai": "K" }]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	assert_true(r.ok, "; ".join(r.errors))
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	var b: Unit = state.unit_by_id(101)
	assert_eq(b.cell, Vector2i(3, 0))
	assert_eq(b.hp, 3)

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var blocked: Array[BattleEvent] = []
	var enemy_damaged: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.REINFORCEMENT_BLOCKED:
			blocked.append(e)
		elif e.type == BattleEvent.Type.DAMAGED and e.unit_id == 101:
			enemy_damaged.append(e)

	assert_eq(blocked.size(), 1)
	assert_eq(enemy_damaged.size(), 1)
	assert_eq(enemy_damaged[0].cause, BattleEvent.Cause.REINFORCEMENT)
	assert_eq(b.hp, 2, "Bộ binh địch mất 1 máu còn 2")
	assert_null(state.unit_by_id(102), "Tiếp viện bị hủy")


func test_reinforcement_blocked_kills_low_hp_unit() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["dia_hinh"] = [
		". # . . .",
		"# # . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["quan"] = [
		"B . . B .",
		". . . 1 .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["0,0", "3,0"]
	dict["tiep_vien"] = [{ "hiep": 2, "o": "3,0", "loai": "K" }]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	assert_true(r.ok, "; ".join(r.errors))
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	var b2: Unit = state.unit_by_id(102)
	b2.hp = 1
	RulesEnemyPhase.begin_battle(state, [])

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var died_events: Array[BattleEvent] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.DIED and e.unit_id == 102:
			died_events.append(e)
	assert_eq(died_events.size(), 1, "Quân chặn chỉ còn 1 máu bị gục khi tiếp viện đè")
	assert_null(state.unit_at(Vector2i(3, 0)), "Ô 3,0 trống sau khi quân chặn gục và tiếp viện bị hủy")


func test_victory_requires_all_reinforcements_cleared() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["quan"] = [
		". . . . .",
		". . . . .",
		". . . . .",
		". . . B .",
		". . . 1 ."
	]
	dict["thu_tu_dich"] = ["3,3"]
	dict["tiep_vien"] = [{ "hiep": 2, "o": "0,0", "loai": "K" }]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	var b: Unit = state.unit_by_id(101)
	b.hp = 1
	RulesEnemyPhase.begin_battle(state, [])

	# Tướng đánh gục quân địch trên bàn
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(3, 3)))
	assert_eq(state.units.filter(func(u: Unit) -> bool: return u.faction == Unit.Faction.NGUYEN).size(), 0)
	assert_eq(state.phase, BattleState.Phase.PLAYER, "Chưa thắng vì còn quân tiếp viện ở hiệp 2")

	# Hết lượt hiệp 1 sang hiệp 2
	var end_events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 2)
	assert_not_null(state.unit_by_id(102), "Quân tiếp viện K đã xuất hiện")

	# Hạ tiếp quân tiếp viện 102
	var k: Unit = state.unit_by_id(102)
	k.cell = Vector2i(3, 3) # đặt kề tướng để đánh được
	var k_died_events: Array[BattleEvent] = []
	Effects.damage(state, k, 2, BattleEvent.Cause.STRIKE, k_died_events)
	RulesVictory.check(state, k_died_events)
	assert_eq(state.phase, BattleState.Phase.WON, "Thắng sau khi diệt toàn bộ quân tiếp viện")


func test_multiple_reinforcements_spawn_and_act_in_order() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_level_dict()
	dict["dia_hinh"] = [
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . #",
		". . . # ."
	]
	dict["quan"] = [
		". . . . .",
		". . . . .",
		". . 1 . .",
		". . . . .",
		". . . . B"
	]
	dict["thu_tu_dich"] = ["4,4"]
	dict["tiep_vien"] = [
		{ "hiep": 2, "o": "2,1", "loai": "B" },
		{ "hiep": 2, "o": "0,2", "loai": "K" }
	]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	assert_true(r.ok, "; ".join(r.errors))
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)

	var u102: Unit = state.unit_by_id(102)
	var u103: Unit = state.unit_by_id(103)
	assert_not_null(u102, "B tiếp viện nhận id 102")
	assert_not_null(u103, "K tiếp viện nhận id 103")
	assert_eq(u102.type, UnitType.BO_BINH)
	assert_eq(u103.type, UnitType.KY_BINH)

	# Kiểm tra thứ tự báo đòn trong hiệp 2:
	# u102 (B) ở 2,1 kề tướng 1 ở 2,2 -> báo đòn số 1
	# u103 (K) ở 0,2 thẳng hàng tướng 1 ở 2,2 -> báo đòn số 2
	assert_eq(state.telegraphs.size(), 2)
	assert_eq(state.telegraphs[0].owner_id, 102)
	assert_eq(state.telegraphs[0].order, 1)
	assert_eq(state.telegraphs[1].owner_id, 103)
	assert_eq(state.telegraphs[1].order, 2)

