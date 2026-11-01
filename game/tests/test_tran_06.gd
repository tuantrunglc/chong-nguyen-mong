extends GutTest
## Trận 6 — Phục Binh Bạch Đằng (Story 4.5): nạp được, bàn thật khớp "truoc" của kịch bản lời giải, lời giải thắng ở
## hiệp 5 không mất tướng và có dùng Sát Thát (validate sau mỗi lệnh), đứng yên thì thua vì Kỵ binh phi vào ải.
## Trận chưa "bắt buộc" Sát Thát (code review 4.5): có lối thắng khác, chờ story cân bằng.

const LEVEL_PATH: String = "res://data/tran/tran_06.json"
const SCENARIO_PATH: String = "res://tests/kich_ban/tran/tran_06_loi_giai.json"
const SCENARIO_ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const LEVEL_NAME: String = "Trận 6 — Phục Binh Bạch Đằng"
const VKNT: int = Stratagem.Kind.VUON_KHONG_NHA_TRONG
const SAT_THAT: int = Stratagem.Kind.SAT_THAT
## Bộ binh tiếp viện hiệp 2 đứng sát ải 8,7; Khoái dùng Sát Thát chém 3 máu (Story 4.5, điểm dạy chính).
const SAT_THAT_TARGET: Vector2i = Vector2i(8, 6)
## Lịch tiếp viện [hiệp, ô, loại] theo file trận.
const SCHEDULE: Array = [
	[2, Vector2i(9, 5), UnitType.BO_BINH], [2, Vector2i(0, 0), UnitType.CUNG_KY],
	[3, Vector2i(9, 6), UnitType.CUNG_KY], [3, Vector2i(9, 4), UnitType.CUNG_KY],
	[4, Vector2i(0, 6), UnitType.CUNG_KY],
	[5, Vector2i(9, 4), UnitType.KY_BINH], [5, Vector2i(0, 6), UnitType.BO_BINH],
]

var _stats: Stats = null


func before_each() -> void:
	_stats = StatsLoader.load_stats(STATS_PATH).data as Stats


func _level() -> LevelData:
	var result: LoadResult = LevelLoader.load_level(LEVEL_PATH)
	assert_eq(result.errors, [] as Array[String], "tran_06.json nạp được")
	assert_eq(result.warnings, [] as Array[String], "tran_06.json không có cảnh báo")
	return result.data as LevelData


func _scenario() -> ScenarioData:
	var result: LoadResult = ScenarioLoader.load_scenario(SCENARIO_PATH, SCENARIO_ROOT, _stats)
	assert_eq(result.errors, [] as Array[String], "kịch bản trận 6 nạp được")
	assert_eq(result.warnings, [] as Array[String], "kịch bản trận 6 không có cảnh báo")
	return result.data as ScenarioData


## Bàn thật của trận sau pha chuẩn bị hiệp 1 (bàn người chơi thấy khi mở trận).
func _opened(level: LevelData) -> BattleState:
	var state: BattleState = BattleState.from_level(level, _stats)
	Rules.resolve(state, Command.begin_battle())
	assert_eq(state.validate(), [] as Array[String], "validate sạch sau begin_battle")
	return state


func _rejected(events: Array[BattleEvent]) -> bool:
	return events.any(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED)


func test_level_6_data() -> void:
	var level: LevelData = _level()
	assert_not_null(level)
	if level == null:
		return
	assert_eq(level.name, LEVEL_NAME)
	assert_eq(level.size, Vector2i(10, 8), "bàn 10×8")
	assert_eq(level.mission, LevelData.Mission.HOLD_PASS, "Giữ ải")
	assert_eq(level.max_rounds, 5)
	assert_eq(level.stratagems, [VKNT, SAT_THAT] as Array[int], "mở cả Vườn không nhà trống và Sát Thát")
	for kind: int in [Terrain.RIVER, Terrain.FOREST, Terrain.SPIKES, Terrain.GRANARY, Terrain.PASS]:
		assert_true(level.terrain.has(kind), "có địa hình %d" % kind)
	assert_false(level.terrain.has(Terrain.VILLAGE), "không có làng (tác giả chốt)")
	assert_eq(level.long_dan, 0, "không có Lòng dân")
	var generals: Array[int] = []
	var enemies: Array[int] = []
	var enemy_cells: Array[Vector2i] = []
	for p: LevelData.UnitPlacement in level.units:
		if UnitType.is_general(p.type):
			generals.append(p.type)
		else:
			enemies.append(p.type)
			enemy_cells.append(p.cell)
			assert_ne(level.terrain_at(p.cell), Terrain.PASS, "không quân Nguyên nào đặt sẵn trên ải")
	assert_eq(generals, [UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU], "đủ 3 tướng")
	assert_eq(enemies, [UnitType.BO_BINH, UnitType.KY_BINH, UnitType.BO_BINH, UnitType.CUNG_KY, UnitType.KY_BINH],
		"5 quân khởi đầu: 2 Bộ binh, 2 Kỵ binh, 1 Cung kỵ")
	# thu_tu_dich đọc thẳng từ file (không so với chính level.units).
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LEVEL_PATH)) as Dictionary
	assert_eq(raw["thu_tu_dich"], ["2,2", "4,2", "5,2", "1,4", "6,4"], "thu_tu_dich đúng thứ tự đọc bàn")
	# Thứ tự hành động thật của quân Nguyên trong level cũng phải đúng thứ tự đọc bàn.
	var reading_order: Array[Vector2i] = [Vector2i(2, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(1, 4), Vector2i(6, 4)]
	assert_eq(enemy_cells, reading_order, "thu_tu_dich thật của level đúng thứ tự đọc bàn")
	# Tiếp viện: +1–2 quân mỗi hiệp từ hiệp 2 tới hiệp 5, ô đi được, không phải ải.
	var got: Array = []
	var per_round: Dictionary = {}
	for r: LevelData.Reinforcement in level.reinforcements:
		got.append([r.round, r.cell, r.type])
		per_round[r.round] = int(per_round.get(r.round, 0)) + 1
		assert_true(Terrain.WALKABLE.has(level.terrain_at(r.cell)), "ô tiếp viện %s đi được" % BoardText.cell_text(r.cell))
		assert_ne(level.terrain_at(r.cell), Terrain.PASS, "ô tiếp viện %s không phải ải" % BoardText.cell_text(r.cell))
		assert_ne(level.terrain_at(r.cell), Terrain.SPIKES, "ô tiếp viện %s không nằm trên chông" % BoardText.cell_text(r.cell))
	assert_eq(got, SCHEDULE, "lịch tiếp viện")
	for rd: int in [2, 3, 4, 5]:
		assert_between(int(per_round.get(rd, 0)), 1, 2, "hiệp %d có 1–2 quân tiếp viện" % rd)


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
		want_strikes.append([t.owner_cell, t.kind, t.target, t.order])
	var got_strikes: Array = []
	for t: Telegraph in state.telegraphs:
		got_strikes.append([state.unit_by_id(t.owner_id).cell, t.kind, TelegraphMarks.hit_cell(state, t), t.order])
	assert_eq(got_strikes, want_strikes, "đòn đã báo khớp")
	# thu_tu_dich của kịch bản: đọc thẳng từ JSON, phải khớp thứ tự hành động thật (id tăng dần).
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SCENARIO_PATH)) as Dictionary
	var enemies: Array[Unit] = []
	for u: Unit in state.units:
		if not UnitType.is_general(u.type):
			enemies.append(u)
	enemies.sort_custom(func(a: Unit, b: Unit) -> bool: return a.id < b.id)
	var enemy_cells: Array = []
	for u: Unit in enemies:
		enemy_cells.append(BoardText.cell_text(u.cell))
	assert_eq((raw["truoc"] as Dictionary)["thu_tu_dich"], enemy_cells, "thu_tu_dich của kịch bản đúng thứ tự thật")


## Lời giải (lấy từ kịch bản) chạy trên trận thật: dùng Sát Thát, tiếp viện tới đúng ô đúng hiệp, thắng ở hiệp 5,
## đủ 3 tướng.
func test_solution_wins_without_losing_a_general() -> void:
	var level: LevelData = _level()
	var scenario: ScenarioData = _scenario()
	if level == null or scenario == null:
		return
	var state: BattleState = _opened(level)
	var spawned: Array = []
	var sat_that_hit: bool = false
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
			_:
				fail_test("bước %d: lệnh lạ \"%s\"" % [i + 1, step.kind])
				return
		var target: Unit = state.unit_at(step.cell) if step.kind == "danh" else null
		var events: Array[BattleEvent] = Rules.resolve(state, command)
		assert_false(_rejected(events), "bước %d (%s) chạy được" % [i + 1, step.kind])
		assert_eq(state.validate(), [] as Array[String], "validate sạch sau bước %d" % (i + 1))
		if step.kind == "muu_ke" and step.stratagem == VKNT:
			assert_false(state.terrain.has(Terrain.GRANARY), "đốt hết kho lương")
		if step.kind == "danh" and step.cell == SAT_THAT_TARGET and target != null:
			assert_true(state.sat_that_active, "đòn chém 8,6 nằm trong lượt Sát Thát")
			var dealt: int = 0
			for e: BattleEvent in events:
				if e.type == BattleEvent.Type.DAMAGED and e.unit_id == target.id:
					dealt += e.amount
			assert_eq(dealt, 3, "Khoái có Sát Thát chém Bộ binh 8,6 mất 3 máu")
			assert_null(state.unit_by_id(target.id), "Bộ binh sát ải gục ngay")
			sat_that_hit = true
		for e: BattleEvent in events:
			if e.type == BattleEvent.Type.REINFORCEMENT_SPAWNED:
				spawned.append([state.round_number, e.to_cell])
	assert_true(SAT_THAT in state.stratagems_used, "lời giải có dùng Sát Thát")
	assert_true(VKNT in state.stratagems_used, "lời giải có dùng Vườn không nhà trống")
	assert_true(sat_that_hit, "có đòn chém 8,6 trong lượt Sát Thát")
	assert_eq(spawned.size(), SCHEDULE.size(), "đủ 7 quân tiếp viện xuất hiện (không ô nào bị chặn)")
	var want_cells: Array = []
	for s: Array in SCHEDULE:
		want_cells.append([s[0], s[1]])
	assert_eq(spawned, want_cells, "tiếp viện xuất hiện đúng hiệp, đúng ô")
	assert_eq(state.phase, BattleState.Phase.WON, "thắng")
	assert_eq(state.round_number, 5, "thắng ở hiệp 5 (Giữ ải không thắng sớm)")
	var hp: Array = []
	for id: int in [1, 2, 3]:
		var g: Unit = state.unit_by_id(id)
		assert_not_null(g, "tướng %d còn sống" % id)
		hp.append(g.hp if g != null else 0)
	assert_eq(hp, [3, 3, 3], "cả ba tướng 3/3")


## Đứng yên: Kỵ binh 8,5 phi vào ải 8,7 ngay đầu hiệp 2 — thua.
func test_standing_still_loses_the_pass_in_round_2() -> void:
	var level: LevelData = _level()
	if level == null:
		return
	var state: BattleState = _opened(level)
	for i: int in range(5):
		if Rules.is_battle_over(state):
			break
		Rules.resolve(state, Command.end_turn())
		assert_eq(state.validate(), [] as Array[String])
	assert_eq(state.phase, BattleState.Phase.LOST)
	assert_eq(state.defeat_reason, "quan_nguyen_vao_ai", "thua vì giặc vào ải")
	assert_eq(state.round_number, 2)
	var intruder: Unit = state.unit_at(Vector2i(8, 7))
	assert_not_null(intruder, "có quân trên ải 8,7")
	if intruder != null:
		assert_eq(intruder.type, UnitType.KY_BINH, "Kỵ binh phi vào ải 8,7")
