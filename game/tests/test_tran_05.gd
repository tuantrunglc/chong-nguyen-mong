extends GutTest
## Trận 5 — Thăng Long Bỏ Ngỏ (Story 3.14): nạp được, bàn thật khớp "truoc" của kịch bản lời giải, lời giải thắng ở
## hiệp 5 không mất tướng trên BattleState.from_level (validate sau mỗi lệnh), và đứng yên thì thua vì tiếp viện.

const LEVEL_PATH: String = "res://data/tran/tran_05.json"
const SCENARIO_PATH: String = "res://tests/kich_ban/tran/tran_05_loi_giai.json"
const SCENARIO_ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const LEVEL_NAME: String = "Trận 5 — Thăng Long Bỏ Ngỏ"
const VKNT: int = Stratagem.Kind.VUON_KHONG_NHA_TRONG
const SPAWN_CELL: Vector2i = Vector2i(7, 7)

var _stats: Stats = null


func before_each() -> void:
	_stats = StatsLoader.load_stats(STATS_PATH).data as Stats


func _level() -> LevelData:
	var result: LoadResult = LevelLoader.load_level(LEVEL_PATH)
	assert_eq(result.errors, [] as Array[String], "tran_05.json nạp được")
	assert_eq(result.warnings, [] as Array[String], "tran_05.json không có cảnh báo")
	return result.data as LevelData


func _scenario() -> ScenarioData:
	var result: LoadResult = ScenarioLoader.load_scenario(SCENARIO_PATH, SCENARIO_ROOT, _stats)
	assert_eq(result.errors, [] as Array[String], "kịch bản trận 5 nạp được")
	return result.data as ScenarioData


## Bàn thật của trận sau pha chuẩn bị hiệp 1 (bàn người chơi thấy khi mở trận).
func _opened(level: LevelData) -> BattleState:
	var state: BattleState = BattleState.from_level(level, _stats)
	Rules.resolve(state, Command.begin_battle())
	assert_eq(state.validate(), [] as Array[String], "validate sạch sau begin_battle")
	return state


func _rejected(events: Array[BattleEvent]) -> bool:
	return events.any(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED)


func _has_event(events: Array[BattleEvent], type: BattleEvent.Type, cell: Vector2i) -> bool:
	return events.any(func(e: BattleEvent) -> bool: return e.type == type and e.to_cell == cell)


func test_level_5_data() -> void:
	var level: LevelData = _level()
	assert_not_null(level)
	if level == null:
		return
	assert_eq(level.name, LEVEL_NAME)
	assert_eq(level.size, Vector2i(8, 8), "bàn 8×8")
	assert_eq(level.mission, LevelData.Mission.HOLD_PASS, "Giữ ải")
	assert_eq(level.max_rounds, 5)
	assert_eq(level.stratagems, [VKNT] as Array[int], "chỉ mở Vườn không nhà trống")
	for kind: int in [Terrain.RIVER, Terrain.FOREST, Terrain.GRANARY, Terrain.PASS]:
		assert_true(level.terrain.has(kind), "có địa hình %d" % kind)
	var generals: Array[int] = []
	var enemies: Array[int] = []
	for p: LevelData.UnitPlacement in level.units:
		if UnitType.is_general(p.type):
			generals.append(p.type)
		else:
			enemies.append(p.type)
			assert_ne(level.terrain_at(p.cell), Terrain.PASS, "không quân Nguyên nào đặt sẵn trên ải")
	assert_eq(generals, [UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU], "đủ 3 tướng")
	assert_eq(enemies, [UnitType.BO_BINH, UnitType.BO_BINH, UnitType.CUNG_KY], "2 Bộ binh, 1 Cung kỵ")
	# Hai Bộ binh khởi đầu đứng kề kho lương (luật hồi máu có ý nghĩa).
	for p: LevelData.UnitPlacement in level.units:
		if p.type != UnitType.BO_BINH:
			continue
		var next_to_granary: bool = false
		for dir: Vector2i in Grid.DIRECTIONS:
			var n: Vector2i = p.cell + dir
			if Rect2i(Vector2i.ZERO, level.size).has_point(n) and level.terrain_at(n) == Terrain.GRANARY:
				next_to_granary = true
		assert_true(next_to_granary, "Bộ binh %s kề kho lương" % BoardText.cell_text(p.cell))
	assert_eq(level.reinforcements.size(), 1)
	var r: LevelData.Reinforcement = level.reinforcements[0]
	assert_eq([r.round, r.cell, r.type], [3, SPAWN_CELL, UnitType.KY_BINH], "1 Kỵ binh tiếp viện hiệp 3 ở 7,7")
	# thu_tu_dich đọc thẳng từ file (không so với chính level.units).
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LEVEL_PATH)) as Dictionary
	assert_eq(raw["thu_tu_dich"], ["1,0", "6,0", "3,2"], "thu_tu_dich đúng thứ tự đọc bàn")


## Bàn thật sau pha chuẩn bị hiệp 1 phải đúng là "truoc" của kịch bản lời giải.
func test_opened_board_matches_scenario() -> void:
	var level: LevelData = _level()
	var scenario: ScenarioData = _scenario()
	if level == null or scenario == null:
		return
	var state: BattleState = _opened(level)
	var before: LevelData = scenario.before
	assert_eq(state.terrain, before.terrain, "địa hình khớp")
	var want: Dictionary = {}
	for p: LevelData.UnitPlacement in before.units:
		want[p.cell] = [p.type, p.hp if p.hp > 0 else _stats.max_hp(p.type)]
	var got: Dictionary = {}
	for u: Unit in state.units:
		got[u.cell] = [u.type, u.hp]
	assert_eq(got, want, "quân và máu khớp")
	assert_eq(before.max_rounds, state.max_rounds, "so_hiep_toi_da khớp")
	assert_eq(before.mission, state.mission, "kiểu trận khớp")
	assert_eq(before.stratagems, state.stratagems, "muu_ke_mo khớp")
	var want_reinf: Array = []
	for r: LevelData.Reinforcement in before.reinforcements:
		want_reinf.append([r.round, r.cell, r.type])
	var got_reinf: Array = []
	for r: LevelData.Reinforcement in state.reinforcements:
		got_reinf.append([r.round, r.cell, r.type])
	assert_eq(got_reinf, want_reinf, "tiep_vien khớp")
	var want_strikes: Array = []
	for t: ScenarioData.ExpectedTelegraph in scenario.before_telegraphs:
		want_strikes.append([t.owner_cell, t.target, t.order])
	var got_strikes: Array = []
	for t: Telegraph in state.telegraphs:
		got_strikes.append([state.unit_by_id(t.owner_id).cell, TelegraphMarks.hit_cell(state, t), t.order])
	assert_eq(got_strikes, want_strikes, "đòn đã báo khớp")
	# thu_tu_dich của kịch bản: đọc thẳng từ JSON, phải khớp thứ tự hành động thật (id tăng dần).
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SCENARIO_PATH)) as Dictionary
	var enemy_cells: Array = []
	for u: Unit in state.units:
		if not UnitType.is_general(u.type):
			enemy_cells.append(BoardText.cell_text(u.cell))
	assert_eq((raw["truoc"] as Dictionary)["thu_tu_dich"], enemy_cells, "thu_tu_dich của kịch bản đúng thứ tự thật")


## Lời giải (lấy từ kịch bản) chạy trên trận thật: thắng ở hiệp 5, đủ 3 tướng.
func test_solution_wins_without_losing_a_general() -> void:
	var level: LevelData = _level()
	var scenario: ScenarioData = _scenario()
	if level == null or scenario == null:
		return
	var state: BattleState = _opened(level)
	var blocked: bool = false
	for i: int in range(scenario.steps.size()):
		var step: ScenarioData.ScenarioStep = scenario.steps[i]
		var command: Command
		match step.kind:
			"di":
				command = Command.move(UnitType.GENERALS.find(step.general) + 1, step.cell)
			"danh":
				command = Command.attack(UnitType.GENERALS.find(step.general) + 1, step.cell)
			"muu_ke":
				command = Command.use_stratagem(step.stratagem)
			"ket_thuc_luot":
				command = Command.end_turn()
		var events: Array[BattleEvent] = Rules.resolve(state, command)
		assert_false(_rejected(events), "bước %d (%s) chạy được" % [i + 1, step.kind])
		assert_eq(state.validate(), [] as Array[String], "validate sạch sau bước %d" % (i + 1))
		if step.kind == "muu_ke":
			assert_false(state.terrain.has(Terrain.GRANARY), "đốt hết kho lương")
		if _has_event(events, BattleEvent.Type.REINFORCEMENT_BLOCKED, SPAWN_CELL):
			blocked = true
			assert_eq(state.round_number, 3, "tiếp viện bị chặn ở đầu hiệp 3")
	assert_true(blocked, "Dư đứng ô 7,7 chặn được Kỵ binh tiếp viện")
	assert_eq(state.phase, BattleState.Phase.WON, "thắng")
	assert_eq(state.round_number, 5, "thắng ở hiệp 5 (Giữ ải không thắng sớm)")
	var hp: Array = []
	for id: int in [1, 2, 3]:
		var g: Unit = state.unit_by_id(id)
		assert_not_null(g, "tướng %d còn sống" % id)
		hp.append(g.hp if g != null else 0)
	assert_eq(hp, [3, 3, 2], "Khoái 3/3, Lão 3/3, Dư 2/3 (mất 1 máu khi chặn tiếp viện)")


## Đứng yên không chặn: Kỵ binh tiếp viện xuất hiện đúng ô 7,7 ở đầu hiệp 3 và phi vào ải — thua ngay.
func test_unblocked_reinforcement_takes_the_pass() -> void:
	var level: LevelData = _level()
	if level == null:
		return
	var state: BattleState = _opened(level)
	var spawned: bool = false
	for i: int in range(5):
		if Rules.is_battle_over(state):
			break
		var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
		assert_eq(state.validate(), [] as Array[String])
		if _has_event(events, BattleEvent.Type.REINFORCEMENT_SPAWNED, SPAWN_CELL):
			spawned = true
			assert_eq(state.round_number, 3, "Kỵ binh xuất hiện ở hiệp 3")
	assert_true(spawned, "Kỵ binh tiếp viện xuất hiện ở 7,7")
	assert_eq(state.phase, BattleState.Phase.LOST)
	assert_eq(state.defeat_reason, "quan_nguyen_vao_ai", "thua vì giặc vào ải")
	assert_eq(state.round_number, 3)
