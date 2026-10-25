extends GutTest
## Kiểm thử nạp trận 4 và kiểm chứng lời giải không mất tướng, bảo toàn Lòng dân (Story 3.8).

const LEVEL_PATH: String = "res://data/tran/tran_04.json"
const SCENARIO_PATH: String = "res://tests/kich_ban/tran/tran_04_loi_giai.json"
const SCENARIO_ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const LEVEL_NAME: String = "Trận 4 — Làng Quanh Vạn Kiếp"


func test_level_4_loads_and_solution_wins_without_damage() -> void:
	var stats_result: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(stats_result.errors, [] as Array[String], "chi_so.json nạp được")
	var stats: Stats = stats_result.data as Stats
	assert_not_null(stats)
	if stats == null:
		return

	var level_result: LoadResult = LevelLoader.load_level(LEVEL_PATH)
	assert_eq(level_result.errors, [] as Array[String], "tran_04.json nạp được")
	assert_eq(level_result.warnings, [] as Array[String], "tran_04.json không có cảnh báo")
	var level: LevelData = level_result.data as LevelData
	assert_not_null(level)
	if level == null:
		return

	assert_eq(level.size, Vector2i(7, 6), "bàn 7 cột × 6 hàng")
	assert_eq(level.name, LEVEL_NAME, "tên trận")
	assert_eq(level.max_rounds, 6, "giới hạn 6 hiệp")
	assert_eq(level.long_dan, 3, "Lòng dân khởi đầu 3")
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
	assert_eq(scenario_result.errors, [] as Array[String], "kịch bản trận 4 nạp được")
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
	assert_eq(state.max_rounds, 6, "giới hạn 6 hiệp")
	assert_eq(state.morale, 3, "Lòng dân còn nguyên 3")

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
	# Nước 1: Dư (3) đi (3,2)
	var ev1: Array[BattleEvent] = Rules.resolve(state, Command.move(3, Vector2i(3, 2)))
	assert_eq(ev1.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư đi 3,2")

	# Nước 2: Dư (3) kéo B2 ở (5,2) về (4,2)
	var ev2: Array[BattleEvent] = Rules.resolve(state, Command.attack(3, Vector2i(5, 2)))
	assert_eq(ev2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư kéo B2")
	var b2: Unit = state.unit_by_id(103)
	assert_not_null(b2, "B2 còn trên bàn")
	if b2 != null:
		assert_eq(b2.cell, Vector2i(4, 2), "B2 bị kéo về 4,2")

	# Nước 3: Khoái (1) đi (4,3)
	var ev3: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(4, 3)))
	assert_eq(ev3.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái đi 4,3")

	# Nước 4: Khoái (1) chém B2 ở (4,2) đẩy vào rừng (4,1) -> B2 gục
	var ev4: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(4, 2)))
	assert_eq(ev4.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái chém B2")
	assert_null(state.unit_by_id(103), "B2 đã gục sau khi bị đẩy vào rừng")

	# Nước 5: Lão (2) đi (4,2)
	var ev5: Array[BattleEvent] = Rules.resolve(state, Command.move(2, Vector2i(4, 2)))
	assert_eq(ev5.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Lão đi 4,2")

	# Nước 6: Lão (2) phóng lao Tây qua Dư (3,2) trúng K (2,2)
	var ev6: Array[BattleEvent] = Rules.resolve(state, Command.attack(2, Vector2i(2, 2)))
	assert_eq(ev6.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Lão phóng lao trúng K")
	var k_unit: Unit = state.unit_by_id(102)
	assert_not_null(k_unit, "K còn sống")
	if k_unit != null:
		assert_eq(k_unit.hp, 1, "K còn 1 máu")

	# Kết thúc hiệp 1
	var ev_end1: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.PLAYER, "sang hiệp 2")
	assert_eq(state.round_number, 2, "đang ở hiệp 2")
	assert_eq(state.morale, 3, "Lòng dân còn 3/3")

	# --- HIỆP 2 ---
	# Nước 1: Lão (2) dứt điểm K (2,2) qua Dư (3,2)
	var ev_l2: Array[BattleEvent] = Rules.resolve(state, Command.attack(2, Vector2i(2, 2)))
	assert_eq(ev_l2.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Lão dứt điểm K")
	assert_null(state.unit_by_id(102), "Kỵ binh đã gục")

	# Nước 2: Dư (3) đi (2,0)
	var ev_d2_m: Array[BattleEvent] = Rules.resolve(state, Command.move(3, Vector2i(2, 0)))
	assert_eq(ev_d2_m.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư đi 2,0")

	# Nước 3: Dư (3) kéo B1 ở (0,0) sang Đông về (1,0) giải cứu làng D1
	var ev_d2_a: Array[BattleEvent] = Rules.resolve(state, Command.attack(3, Vector2i(0, 0)))
	assert_eq(ev_d2_a.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư kéo B1 giải vây làng D1")
	var b1_pulled: Unit = state.unit_by_id(101)
	assert_not_null(b1_pulled, "B1 còn sống")
	if b1_pulled != null:
		assert_eq(b1_pulled.cell, Vector2i(1, 0), "B1 dừng ở 1,0")

	# Nước 4: Khoái (1) tiến sang Tây về (1,3)
	var ev_k2_m: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(1, 3)))
	assert_eq(ev_k2_m.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái tiến về 1,3")

	# Kết thúc hiệp 2
	var ev_end2: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.PLAYER, "sang hiệp 3")
	assert_eq(state.round_number, 3, "đang ở hiệp 3")
	assert_eq(state.morale, 3, "Lòng dân còn 3/3")

	# --- HIỆP 3 ---
	# Nước 1: Dư (3) ở (2,0) bước né đòn sang (3,0)
	var ev_d3: Array[BattleEvent] = Rules.resolve(state, Command.move(3, Vector2i(3, 0)))
	assert_eq(ev_d3.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Dư né sang 3,0")

	# Nước 2: Khoái (1) tiến lên (1,1)
	var ev_k3_m: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(1, 1)))
	assert_eq(ev_k3_m.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái tiến lên 1,1")

	# Nước 3: Khoái (1) chém Bắc vào B1 ở (1,0) đẩy vào mép bàn phía Bắc dứt điểm
	var ev_k3_a: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(1, 0)))
	assert_eq(ev_k3_a.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED).size(), 0, "Khoái chém dứt điểm B1")

	# Kiểm tra kết thúc trận
	assert_eq(state.phase, BattleState.Phase.WON, "trận đấu thắng")
	assert_null(state.unit_by_id(101), "B1 đã gục")

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

	# Kiểm tra Lòng dân
	assert_eq(state.morale, 3, "Lòng dân nguyên vẹn 3/3")
	assert_eq(state.validate(), [] as Array[String], "trạng thái trận sạch")
