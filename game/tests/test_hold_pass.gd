extends GutTest
## Kiểm thử cơ chế nhiệm vụ Giữ ải (Story 3.11, FR37, FR23).

const STATS_PATH: String = "res://data/chi_so.json"


func _stats() -> Stats:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(r.errors, [] as Array[String], "chi_so.json nạp được")
	return r.data as Stats


func _base_hold_pass_dict() -> Dictionary:
	return {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử giữ ải",
		"kieu": "giu_ai",
		"dia_hinh": [
			". . . . .",
			". . . . .",
			". . . . .",
			". . . . .",
			". . A . ."
		],
		"quan": [
			"1 . . . .",
			". . . . .",
			". . . . .",
			". . . . .",
			". . . . B"
		],
		"thu_tu_dich": ["4,4"],
		"tiep_vien": [],
		"muu_ke_mo": []
	}


func test_level_loader_defaults_hold_pass_to_five_rounds() -> void:
	var dict: Dictionary = _base_hold_pass_dict()
	var text: String = JSON.stringify(dict)
	var r: LoadResult = LevelLoader.parse_level(text, "test.json")
	assert_true(r.ok, "; ".join(r.errors))
	var level: LevelData = r.data as LevelData
	assert_eq(level.mission, LevelData.Mission.HOLD_PASS)
	assert_eq(level.max_rounds, 5, "Mặc định 5 hiệp cho trận Giữ ải khi không ghi so_hiep_toi_da")


func test_hero_entering_pass_cell_does_not_lose() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["quan"] = [
		". . . . B",
		". . . . .",
		". . . . .",
		". . 1 . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["4,0"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	# B ở xa (4,0) chỉ đi xuống (4,2), chưa tới ải (2,4).
	# Tướng ở (2,3) bước vào ô ải (2,4)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(2, 4)))
	assert_eq(state.phase, BattleState.Phase.PLAYER, "Tướng vào ô ải trận đấu vẫn tiếp tục")
	assert_eq(state.unit_by_id(1).cell, Vector2i(2, 4), "Tướng đứng trên ô ải trấn giữ")
	assert_eq(state.validate(), [] as Array[String])


func test_enemy_pushed_into_pass_loses_immediately() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["quan"] = [
		". . . . .",
		". . . . .",
		". . 1 . .",
		". . B . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["2,3"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	# Không chạy begin_battle để giữ nguyên vị trí trước lệnh đánh
	# Khoái ở (2,2) đánh B ở (2,3) -> đẩy B xuống (2,4) là ô Ải!
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(2, 3)))
	assert_eq(state.phase, BattleState.Phase.LOST, "Thua ngay khi quân Nguyên bị đẩy vào ô ải")
	assert_eq(state.defeat_reason, "quan_nguyen_vao_ai")
	var has_defeat: bool = false
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.DEFEAT and e.reason == "quan_nguyen_vao_ai":
			has_defeat = true
	assert_true(has_defeat, "Có sự kiện DEFEAT với lý do quan_nguyen_vao_ai")


func test_enemy_pulled_into_pass_loses_immediately() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["dia_hinh"] = [
		". . . . .",
		". . . . .",
		". . A . .",
		". . . . .",
		". . . . ."
	]
	dict["quan"] = [
		". . . . .",
		". . 3 . .",
		". . . . .",
		". . B . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["2,3"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)

	# Khánh Dư (3) ở (2,1) kéo B ở (2,3) vào ô Ải A ở (2,2)!
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(3, Vector2i(2, 3)))
	assert_eq(state.phase, BattleState.Phase.LOST, "Thua ngay khi quân Nguyên bị kéo vào ô ải")
	assert_eq(state.defeat_reason, "quan_nguyen_vao_ai")


func test_surviving_max_rounds_wins() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["so_hiep_toi_da"] = 2
	dict["quan"] = [
		"1 . . . B",
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["4,0"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	RulesEnemyPhase.begin_battle(state, [])

	# Kết thúc hiệp 1 sang hiệp 2
	Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 2)
	assert_eq(state.phase, BattleState.Phase.PLAYER, "Hiệp 2 vẫn tiếp tục")

	# Kết thúc hiệp 2 (hiệp tối đa)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.WON, "Thắng khi qua hết bước cuối hiệp của hiệp tối đa")
	var has_victory: bool = false
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.VICTORY:
			has_victory = true
	assert_true(has_victory, "Có sự kiện VICTORY")


func test_clearing_all_enemies_does_not_win_early_in_hold_pass() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["quan"] = [
		". . . . .",
		". . . . .",
		". . . . .",
		". 1 B . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["2,3"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)
	var b: Unit = state.unit_by_id(101)
	b.hp = 1

	# Khoái đánh gục B
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(2, 3)))
	assert_eq(state.units.filter(func(u: Unit) -> bool: return u.faction == Unit.Faction.NGUYEN).size(), 0)
	assert_eq(state.phase, BattleState.Phase.PLAYER, "Trong trận Giữ ải, diệt hết địch không thắng sớm")


func test_enemy_ai_targets_pass_cell() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["dia_hinh"] = [
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . .",
		". . A . ."
	]
	dict["quan"] = [
		"1 . B . .",
		". . . . .",
		". . . . .",
		". . . . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["2,0"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)

	# B ở (2,0), ô Ải ở (2,4)
	var b: Unit = state.unit_by_id(101)
	var intent: EnemyIntent = EnemyAI.plan(state, b)
	assert_eq(intent.target_cell, Vector2i(2, 4), "Bộ binh nhắm ô ải 2,4")
	assert_eq(intent.stand_cell, Vector2i(2, 2), "Bộ binh đi 2 bước xuống 2,2 về phía ô ải")


func test_cung_ky_still_targets_nearest_general() -> void:
	var stats: Stats = _stats()
	var dict: Dictionary = _base_hold_pass_dict()
	dict["dia_hinh"] = [
		". . . . .",
		". . . . .",
		"A . . . .",
		". . . . .",
		". . . . ."
	]
	dict["quan"] = [
		". . . . .",
		". . . . .",
		". . C . 1",
		". . . . .",
		". . . . ."
	]
	dict["thu_tu_dich"] = ["2,2"]
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(dict), "test.json")
	var state: BattleState = BattleState.from_level(r.data as LevelData, stats)

	var c: Unit = state.unit_by_id(101)
	var intent: EnemyIntent = EnemyAI.plan(state, c)
	assert_eq(intent.target_id, 1, "Cung kỵ nhắm tướng 1")
	assert_eq(intent.target_cell, Vector2i(4, 2), "Mục tiêu là ô của tướng 1")
