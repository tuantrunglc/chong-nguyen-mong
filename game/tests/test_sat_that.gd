extends GutTest
## Mưu kế Sát Thát (Story 3.13): cờ bật/tắt theo lượt người chơi, va chạm không được cộng, tham số từ chi_so.json,
## chơi lại hiệp, xem trước đòn, báo lỗi F2. Luật chính đã khóa bằng kịch bản muu_ke/st_*.

const SAT_THAT: int = Stratagem.Kind.SAT_THAT


func _state(units: Dictionary, hp: Dictionary = {}, stats: Stats = BoardFixture.stats()) -> BattleState:
	var state: BattleState = BoardFixture.state(units, {}, hp, BoardFixture.DEFAULT_SIZE, stats)
	state.stratagems = [SAT_THAT] as Array[int]
	return state


## Bật khi dùng (chỉ một sự kiện STRATAGEM_USED), tắt khi người chơi kết thúc lượt.
func test_flag_on_for_player_turn_only() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	assert_eq(state.sat_that_bonus(), 0)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.use_stratagem(SAT_THAT))
	assert_eq(events.size(), 1)
	assert_eq(events[0].type, BattleEvent.Type.STRATAGEM_USED)
	assert_eq(events[0].amount, SAT_THAT)
	assert_true(state.sat_that_active)
	assert_eq(state.sat_that_bonus(), 1)
	assert_eq(state.validate(), [] as Array[String])
	Rules.resolve(state, Command.end_turn())
	assert_false(state.sat_that_active, "hết lượt người chơi thì hết hiệu lực")
	assert_eq(state.sat_that_bonus(), 0)
	assert_eq(state.validate(), [] as Array[String])


func test_clone_keeps_flag_and_validate_checks_it() -> void:
	var state: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	Rules.resolve(state, Command.use_stratagem(SAT_THAT))
	assert_true(state.clone().sat_that_active)
	var broken: BattleState = _state({Vector2i(6, 0): "B", Vector2i(3, 6): "1"})
	broken.sat_that_active = true
	assert_eq(broken.validate(), ["Sát Thát đang có hiệu lực mà chưa ghi đã dùng"] as Array[String])


## Va chạm khi bị đẩy không được cộng. Với chỉ số thật Khoái đánh 3 là hạ gục mọi quân Nguyên (không đẩy), nên hạ
## sát thương Khoái xuống 1: đòn 1+1=2, va chạm vẫn 1 cho mỗi bên.
func test_push_collision_not_boosted() -> void:
	var stats: Stats = BoardFixture.stats_with(UnitType.NGUYEN_KHOAI, "sat_thuong", 1)
	var state: BattleState = _state({Vector2i(3, 2): "B", Vector2i(3, 3): "B", Vector2i(3, 4): "1"}, {}, stats)
	Rules.resolve(state, Command.use_stratagem(SAT_THAT))
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(3, 3)))
	var damage: Array[String] = []
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.DAMAGED:
			damage.append("%d:%s:%d" % [e.unit_id, BattleEvent.Cause.find_key(e.cause), e.amount])
	assert_eq(damage, ["102:STRIKE:2", "102:COLLISION:1", "101:COLLISION:1"] as Array[String])
	assert_eq(state.unit_by_id(101).hp, 2)
	assert_eq(state.validate(), [] as Array[String])


## Số cộng lấy từ chi_so.json, không viết cứng.
func test_bonus_comes_from_stats() -> void:
	var stats: Stats = Stats.new(BoardFixture.values(), {SAT_THAT: {"cong_sat_thuong": 2}})
	var state: BattleState = _state({Vector2i(3, 1): "B", Vector2i(3, 4): "2"}, {}, stats)
	Rules.resolve(state, Command.use_stratagem(SAT_THAT))
	Rules.resolve(state, Command.attack(2, Vector2i(3, 1)))
	assert_null(state.unit_by_id(101), "Lão 1+2=3 hạ gục Bộ binh 3 máu")


func test_w_key_slot() -> void:
	assert_eq(Stratagem.SLOTS[1], [SAT_THAT, "stratagem_2", KEY_W], "Sát Thát là phím W, sau Vườn không nhà trống")


func _controller() -> BattleController:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(5, 5)
	for i: int in range(level.size.x * level.size.y):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(1, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(2, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(4, 4)))
	level.stratagems = [SAT_THAT] as Array[int]
	var c: BattleController = BattleController.new()
	c.start(level, BoardFixture.stats())
	c.begin()
	return c


## Chơi lại hiệp trả lại Sát Thát dùng trong lượt và bàn về lúc chưa có hiệu lực.
func test_replay_gives_back_sat_that() -> void:
	var c: BattleController = _controller()
	c.submit(Command.use_stratagem(SAT_THAT))
	assert_false(c.can_use_stratagem(SAT_THAT))
	assert_true(c.replay_round())
	assert_true(c.can_use_stratagem(SAT_THAT))
	assert_false(c.snapshot().sat_that_active)


## Xem trước đòn (Story 2.12) chạy luật trên bản sao nên hiện đúng sát thương đã cộng; bàn thật không đổi.
func test_preview_shows_boosted_damage() -> void:
	var c: BattleController = _controller()
	var strike: Command = Command.attack(1, Vector2i(2, 1))
	var before: Dictionary = c.preview_result(strike)
	assert_eq((before["state"] as BattleState).unit_by_id(101).hp, 1, "chưa dùng: Khoái trừ 2")
	c.submit(Command.use_stratagem(SAT_THAT))
	var after: Dictionary = c.preview_result(strike)
	assert_null((after["state"] as BattleState).unit_by_id(101), "đã dùng: Khoái trừ 3, Bộ binh gục")
	assert_eq(c.snapshot().unit_by_id(101).hp, 3, "xem trước không đụng bàn thật")


## F2: báo cáo có Sát Thát rồi đánh phát lại ra đúng bàn (mốc đầu lượt chưa có hiệu lực, lệnh muu_ke bật lại).
func test_bug_report_replays_sat_that() -> void:
	var c: BattleController = _controller()
	c.submit(Command.use_stratagem(SAT_THAT))
	c.submit(Command.attack(1, Vector2i(2, 1)))
	var data: Dictionary = BugReport.scenario_data(c.snapshot(), c.round_start_snapshot(), c.round_commands(), {})
	assert_eq(data["hanh_dong"][0], {"lenh": "muu_ke", "ten": "sat_that"})
	var result: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(data, "  "), "user://bao_loi_f2.json",
		"res://", BoardFixture.stats())
	assert_eq(result.errors, [] as Array[String])
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(result.data as ScenarioData, BoardFixture.stats())
	assert_true(run.passed, str(run.problems))
