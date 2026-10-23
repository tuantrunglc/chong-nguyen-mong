extends GutTest
## Khoá liên kết giữa trận thật và kịch bản đã duyệt (review Story 3.3).
## `truoc` của kịch bản phải là bàn SAU pha chuẩn bị hiệp 1 của `tran_02.json`; sửa level
## (cỡ bàn, quân, thứ tự địch, địa hình) mà không sửa kịch bản thì test này trượt.

const LEVEL_PATH: String = "res://data/tran/tran_02.json"
const SCENARIO_PATH: String = "res://tests/kich_ban/tran/tran_02_loi_giai.json"
const SCENARIO_ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const LEVEL_NAME: String = "Trận 2 — Ải Lãnh Kinh"


func test_level_2_loads_and_matches_approved_scenario() -> void:
	var stats_result: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(stats_result.errors, [] as Array[String], "chi_so.json nạp được")
	var stats: Stats = stats_result.data as Stats
	assert_not_null(stats)
	if stats == null:
		return

	var level_result: LoadResult = LevelLoader.load_level(LEVEL_PATH)
	assert_eq(level_result.errors, [] as Array[String], "tran_02.json nạp được")
	assert_eq(level_result.warnings, [] as Array[String], "tran_02.json không có cảnh báo")
	var level: LevelData = level_result.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	assert_eq(level.size, Vector2i(6, 7), "bàn 6 cột × 7 hàng")
	assert_eq(level.name, LEVEL_NAME, "tên trận")

	# Thứ tự địch phải đúng thứ tự đọc bàn (hàng trên → dưới, trái → phải).
	var enemy_cells: Array[Vector2i] = []
	for placement: LevelData.UnitPlacement in level.units:
		if not UnitType.is_general(placement.type):
			enemy_cells.append(placement.cell)
	var reading_order: Array[Vector2i] = enemy_cells.duplicate()
	reading_order.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.y < b.y or (a.y == b.y and a.x < b.x))
	assert_eq(enemy_cells, reading_order, "thu_tu_dich theo thứ tự đọc bàn")

	var scenario_result: LoadResult = ScenarioLoader.load_scenario(SCENARIO_PATH, SCENARIO_ROOT, stats)
	assert_eq(scenario_result.errors, [] as Array[String], "kịch bản trận 2 nạp được")
	var scenario: ScenarioData = scenario_result.data as ScenarioData
	assert_not_null(scenario)
	if scenario == null:
		return
	var before: LevelData = scenario.before
	assert_not_null(before)
	if before == null:
		return

	# Bàn thật sau pha chuẩn bị hiệp 1.
	var real: BattleState = BattleState.from_level(level, stats)
	Rules.resolve(real, Command.begin_battle())

	for r: int in range(real.size.y):
		for c: int in range(real.size.x):
			var cell: Vector2i = Vector2i(c, r)
			assert_eq(before.terrain_at(cell), real.terrain_at(cell),
				"địa hình %s khớp kịch bản" % BoardText.cell_text(cell))

	var expected_units: Dictionary = {}
	var expected_hp: Dictionary = {}
	for placement: LevelData.UnitPlacement in before.units:
		expected_units[placement.cell] = placement.type
		expected_hp[placement.cell] = placement.hp if placement.hp > 0 else stats.max_hp(placement.type)
	var actual_units: Dictionary = {}
	var actual_hp: Dictionary = {}
	for unit: Unit in real.units:
		actual_units[unit.cell] = unit.type
		actual_hp[unit.cell] = unit.hp
	assert_eq(actual_units, expected_units, "quân trên bàn khớp kịch bản")
	assert_eq(actual_hp, expected_hp, "máu quân khớp kịch bản")

	var expected_telegraphs: Array = []
	for expected: ScenarioData.ExpectedTelegraph in scenario.before_telegraphs:
		var offset: Vector2i = expected.target - expected.owner_cell \
			if expected.kind == Telegraph.Kind.CELL else expected.target
		expected_telegraphs.append([expected.owner_cell, expected.kind, offset, expected.order])
	var actual_telegraphs: Array = []
	for telegraph: Telegraph in real.telegraphs:
		var owner: Unit = real.unit_by_id(telegraph.owner_id)
		assert_not_null(owner, "chủ đòn còn trên bàn")
		if owner == null:
			continue
		actual_telegraphs.append([owner.cell, telegraph.kind, telegraph.offset, telegraph.order])
	assert_eq(actual_telegraphs, expected_telegraphs, "đòn đã báo khớp kịch bản")
