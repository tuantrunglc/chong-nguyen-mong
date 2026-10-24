extends GutTest
## Kiểm thử nạp trận 3 và kiểm chứng lời giải không mất tướng (Story 3.6).

const LEVEL_PATH: String = "res://data/tran/tran_03.json"
const SCENARIO_PATH: String = "res://tests/kich_ban/tran/tran_03_loi_giai.json"
const SCENARIO_ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const LEVEL_NAME: String = "Trận 3 — Phục Kích Ải Nội Bàng"


func test_level_3_loads_and_solution_wins_without_damage() -> void:
	var stats_result: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(stats_result.errors, [] as Array[String], "chi_so.json nạp được")
	var stats: Stats = stats_result.data as Stats
	assert_not_null(stats)
	if stats == null:
		return

	var level_result: LoadResult = LevelLoader.load_level(LEVEL_PATH)
	assert_eq(level_result.errors, [] as Array[String], "tran_03.json nạp được")
	assert_eq(level_result.warnings, [] as Array[String], "tran_03.json không có cảnh báo")
	var level: LevelData = level_result.data as LevelData
	assert_not_null(level)
	if level == null:
		return

	assert_eq(level.size, Vector2i(6, 6), "bàn 6 cột × 6 hàng")
	assert_eq(level.name, LEVEL_NAME, "tên trận")
	assert_eq(level.max_rounds, 5, "giới hạn 5 hiệp")
	assert_eq(level.mission, LevelData.Mission.ELIMINATE, "kiểu tiêu diệt")

	# Thứ tự địch theo thứ tự đọc bàn
	var enemy_cells: Array[Vector2i] = []
	for placement: LevelData.UnitPlacement in level.units:
		if not UnitType.is_general(placement.type):
			enemy_cells.append(placement.cell)
	var reading_order: Array[Vector2i] = enemy_cells.duplicate()
	reading_order.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x))
	assert_eq(enemy_cells, reading_order, "thu_tu_dich theo thứ tự đọc bàn")

	# Khóa với kịch bản đã duyệt
	var scenario_result: LoadResult = ScenarioLoader.load_scenario(SCENARIO_PATH, SCENARIO_ROOT, stats)
	assert_eq(scenario_result.errors, [] as Array[String], "kịch bản trận 3 nạp được")
	var scenario: ScenarioData = scenario_result.data as ScenarioData
	assert_not_null(scenario)
	if scenario == null:
		return
	var before: LevelData = scenario.before
	assert_not_null(before)
	if before == null:
		return

	# Khởi động trận và kiểm tra pha chuẩn bị
	var state: BattleState = BattleState.from_level(level, stats)
	var begin_events: Array[BattleEvent] = Rules.resolve(state, Command.begin_battle())
	assert_gt(begin_events.size(), 0, "có sự kiện khởi đầu trận")
	assert_eq(state.phase, BattleState.Phase.PLAYER, "đầu hiệp 1 là pha PLAYER")
	assert_eq(state.round_number, 1, "hiệp 1")
	assert_eq(state.max_rounds, 5, "giới hạn 5 hiệp")

	# So sánh địa hình thật sau begin_battle với kịch bản
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			assert_eq(before.terrain_at(cell), state.terrain_at(cell),
				"địa hình %s khớp kịch bản" % BoardText.cell_text(cell))

	# So sánh đòn báo với kịch bản
	var expected_telegraphs: Array = []
	for expected: ScenarioData.ExpectedTelegraph in scenario.before_telegraphs:
		var offset: Vector2i = expected.target - expected.owner_cell \
			if expected.kind == Telegraph.Kind.CELL else expected.target
		expected_telegraphs.append([expected.owner_cell, expected.kind, offset, expected.order])
	var actual_telegraphs: Array = []
	for telegraph: Telegraph in state.telegraphs:
		var owner: Unit = state.unit_by_id(telegraph.owner_id)
		assert_not_null(owner, "chủ đòn còn trên bàn")
		if owner != null:
			actual_telegraphs.append([owner.cell, telegraph.kind, telegraph.offset, telegraph.order])
	assert_eq(actual_telegraphs, expected_telegraphs, "đòn đã báo khớp kịch bản")

	# --- HIỆP 1 ---
	# Nước 1: Dư (3) kéo Cung kỵ (3,2) vào hầm chông (3,3) -> Cung kỵ gục
	var ev1: Array[BattleEvent] = Rules.resolve(state, Command.attack(3, Vector2i(3, 2)))
	assert_eq(ev1.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư kéo thành công")
	assert_null(state.unit_by_id(102), "Cung kỵ đã gục sau khi bị kéo vào chông")

	# Nước 2: Khoái (1) đánh Bộ binh (2,4) đẩy lên hầm chông (2,3) -> Bộ binh gục
	var ev2: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(2, 4)))
	assert_eq(ev2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái đánh thành công")
	assert_null(state.unit_by_id(103), "Bộ binh đã gục sau khi bị đẩy vào chông")

	# Nước 3: Lão (2) bước sang (5,5) né đường lao của Kỵ binh
	var ev3: Array[BattleEvent] = Rules.resolve(state, Command.move(2, Vector2i(5, 5)))
	assert_eq(ev3.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Lão bước sang 5,5 thành công")

	# Kết thúc lượt 1
	var ev_end1: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.PLAYER, "sang hiệp 2")
	assert_eq(state.round_number, 2, "đang ở hiệp 2")

	# --- HIỆP 2 ---
	# Nước 1: Dư (3) bước sang (5,4)
	var ev_m2: Array[BattleEvent] = Rules.resolve(state, Command.move(3, Vector2i(5, 4)))
	assert_eq(ev_m2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư bước tới 5,4 thành công")

	# Nước 2: Dư (3) kéo Kỵ binh (5,1) qua hầm chông (5,2) về (5,3)
	var ev_p2: Array[BattleEvent] = Rules.resolve(state, Command.attack(3, Vector2i(5, 1)))
	assert_eq(ev_p2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư kéo Kỵ binh thành công")
	var k_after_pull: Unit = state.unit_by_id(101)
	assert_not_null(k_after_pull, "Kỵ binh còn sống")
	if k_after_pull != null:
		assert_eq(k_after_pull.cell, Vector2i(5, 3), "Kỵ binh dừng ở 5,3")
		assert_eq(k_after_pull.hp, 1, "Kỵ binh còn 1 máu do dính chông")

	# Nước 3: Lão (2) phóng lao từ (5,5) qua Dư (5,4) trúng Kỵ binh (5,3)
	var ev_a2: Array[BattleEvent] = Rules.resolve(state, Command.attack(2, Vector2i(5, 3)))
	assert_eq(ev_a2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Lão phóng lao thành công")

	# Kiểm tra kết thúc trận
	assert_eq(state.phase, BattleState.Phase.WON, "trận đấu thắng")
	assert_null(state.unit_by_id(101), "Kỵ binh đã gục")

	# Kiểm tra máu cả 3 tướng còn nguyên 3/3
	var u1: Unit = state.unit_by_id(1)
	var u2: Unit = state.unit_by_id(2)
	var u3: Unit = state.unit_by_id(3)
	assert_not_null(u1, "Khoái còn sống")
	assert_not_null(u2, "Lão còn sống")
	assert_not_null(u3, "Dư còn sống")
	if u1 != null:
		assert_eq(u1.hp, 3, "Khoái còn 3/3 máu")
	if u2 != null:
		assert_eq(u2.hp, 3, "Lão còn 3/3 máu")
	if u3 != null:
		assert_eq(u3.hp, 3, "Dư còn 3/3 máu")

	assert_eq(state.validate(), [] as Array[String], "trạng thái trận sạch")
