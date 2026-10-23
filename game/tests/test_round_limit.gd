extends GutTest
## Giới hạn hiệp cho trận Tiêu diệt (Story 3.5, FR37).
## Đạt số hiệp tối đa mà chưa tiêu diệt hết quân địch thì thua trận (defeat_reason = "het_hiep").
## Nếu địch bị diệt hết ở hiệp cuối thì vẫn thắng (thắng ưu tiên trước hết hiệp).


func test_round_limit_defeat_when_turn_ends_at_max_rounds() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 4): "1", Vector2i(0, 0): "B"}
	)
	state.mission = LevelData.Mission.ELIMINATE
	state.max_rounds = 1
	assert_eq(state.round_number, 1)

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.LOST, "hết hiệp tối đa mà còn địch thì thua")
	assert_eq(state.defeat_reason, "het_hiep", "lý do thua là hết hiệp")
	assert_eq(state.round_number, 1, "không tăng round_number khi đã thua")

	var defeat_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.DEFEAT
	)
	assert_eq(defeat_events.size(), 1)
	assert_eq(defeat_events[0].reason, "het_hiep")
	assert_eq(state.validate(), [] as Array[String], "bất biến hợp lệ sau khi thua do hết hiệp")


func test_round_limit_not_reached_advances_round() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 4): "1", Vector2i(0, 0): "B"}
	)
	state.mission = LevelData.Mission.ELIMINATE
	state.max_rounds = 3
	assert_eq(state.round_number, 1)

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.PLAYER, "chưa tới hiệp cuối thì tiếp tục chơi")
	assert_eq(state.round_number, 2, "sang hiệp 2")
	assert_eq(state.defeat_reason, "")


func test_final_round_victory_overrides_round_limit() -> void:
	# Ở hiệp cuối, người chơi đánh hạ quân địch cuối cùng thì thắng ngay.
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 4): "1", Vector2i(3, 3): "B"}, {},
		{Vector2i(3, 3): 1}
	)
	state.mission = LevelData.Mission.ELIMINATE
	state.max_rounds = 1

	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(3, 3)))
	assert_eq(state.phase, BattleState.Phase.WON, "hạ hết địch hiệp cuối thì thắng")
	var win_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.VICTORY
	)
	assert_eq(win_events.size(), 1)


func test_no_round_limit_allows_rounds_beyond() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 4): "1", Vector2i(0, 0): "B"}
	)
	state.mission = LevelData.Mission.ELIMINATE
	state.max_rounds = 0

	for i: int in range(5):
		Rules.resolve(state, Command.end_turn())
		assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_eq(state.round_number, 6)


func test_replay_round_preserves_round_and_max_rounds() -> void:
	var level_dict: Dictionary = {
		"phien_ban_dinh_dang": 1,
		"ten": "Trận có giới hạn hiệp",
		"kieu": "tieu_diet",
		"so_hiep_toi_da": 4,
		"dia_hinh": [
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
		],
		"quan": [
			"B . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . 1 . . .",
			". . . . . . .",
		],
		"thu_tu_dich": ["0,0"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	}
	var res: LoadResult = LevelLoader.parse_level(JSON.stringify(level_dict), "data/tran/test_limit.json")
	assert_eq(res.errors, [] as Array[String])
	var level: LevelData = res.data as LevelData
	var stats: Stats = BoardFixture.stats()

	var controller: BattleController = BattleController.new()
	controller.start(level, stats)
	controller.begin()

	assert_eq(controller.snapshot().round_number, 1)
	assert_eq(controller.snapshot().max_rounds, 4)

	# Kết thúc hiệp 1 -> sang hiệp 2
	controller.submit(Command.end_turn())
	assert_eq(controller.snapshot().round_number, 2)
	assert_eq(controller.snapshot().max_rounds, 4)

	# Bấm Chơi lại hiệp -> quay lại đầu hiệp 2
	controller.replay_round()
	assert_eq(controller.snapshot().round_number, 2)
	assert_eq(controller.snapshot().max_rounds, 4)


func test_hud_round_display_and_final_round_highlight() -> void:
	var hud: Hud = Hud.new()
	add_child_autofree(hud)

	# Không có giới hạn hiệp: "Hiệp 1", không đổi màu nổi bật
	hud.show_turn(1, false, false, 0, false, 0)
	assert_eq(hud.round_text(), "Hiệp 1")
	assert_false(hud.round_has_highlight())

	# Có giới hạn 3 hiệp, đang hiệp 1: "Hiệp 1/3", không nổi bật
	hud.show_turn(1, false, false, 0, false, 3)
	assert_eq(hud.round_text(), "Hiệp 1/3")
	assert_false(hud.round_has_highlight())

	# Hiệp 2: "Hiệp 2/3", không nổi bật
	hud.show_turn(2, false, false, 0, false, 3)
	assert_eq(hud.round_text(), "Hiệp 2/3")
	assert_false(hud.round_has_highlight())

	# Hiệp 3 (hiệp cuối): "Hiệp 3/3", có đổi màu nổi bật
	hud.show_turn(3, false, false, 0, false, 3)
	assert_eq(hud.round_text(), "Hiệp 3/3")
	assert_true(hud.round_has_highlight())

	# Khi trận kết thúc (over = true): tắt màu nổi bật
	hud.show_turn(3, false, false, 0, true, 3)
	assert_false(hud.round_has_highlight())
