extends GutTest
## Kiểm thử chuyên biệt cho cơ chế Làng và Lòng dân (Story 3.7).
## Bao gồm HUD, ResultBanner, PreviewView, AiIntentOverlay, khôi phục khi Chơi lại hiệp và tính toàn vẹn trạng thái.


func test_hud_morale_display() -> void:
	var hud: Hud = Hud.new()
	add_child_autofree(hud)

	# Không có làng (max_morale = 0): không hiện nhãn Lòng dân
	hud.show_turn(1, false, false, 0, false, 0, 0, 0)
	assert_eq(hud.morale_text(), "")

	# Có làng 3/3: hiện "Lòng dân: 3/3"
	hud.show_turn(1, false, false, 0, false, 0, 3, 3)
	assert_eq(hud.morale_text(), "Lòng dân: 3/3")

	# Mất 1 Lòng dân: hiện "Lòng dân: 2/3"
	hud.show_turn(1, false, false, 0, false, 0, 2, 3)
	assert_eq(hud.morale_text(), "Lòng dân: 2/3")


func test_result_banner_defeat_mat_lang() -> void:
	var banner: ResultBanner = ResultBanner.new()
	add_child_autofree(banner)

	banner.show_result(BattleState.Phase.LOST, "mat_lang")
	assert_true(banner.is_showing())
	assert_eq(banner.result_text(), "Thua: mất làng")


func test_preview_village_damage_indicator() -> void:
	var preview: PreviewView = PreviewView.new()
	add_child_autofree(preview)

	preview.show_ghosts([], {"cell": Vector2i(2, 3), "amount": 1})
	assert_eq(preview.village_damage_text(), "−1 Lòng dân")

	preview.clear()
	assert_eq(preview.village_damage_text(), "")


func test_ai_intent_overlay_displays_village_target() -> void:
	var intent: EnemyIntent = EnemyIntent.new(101, UnitType.BO_BINH, Vector2i(3, 2), Vector2i(3, 3),
		0, 2, EnemyIntent.Reason.CAN_HIT, 1, Vector2i(3, 4))
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B"})
	var line: String = AiIntentOverlay.line_for(intent, state)
	assert_true(line.contains("nhắm Làng 3,4 (cách 2 bước)"), "F3 ghi rõ nhắm làng")


func test_morale_restored_on_replay_round() -> void:
	var level_dict: Dictionary = {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử làng replay",
		"kieu": "tieu_diet",
		"dia_hinh": [
			". . . . .",
			". . D . .",
			". . . . .",
			". . . . .",
			". . . . ."
		],
		"quan": [
			". . . . B",
			". . . . .",
			". . B . .",
			". 1 . . .",
			". . . . ."
		],
		"thu_tu_dich": ["2,2", "4,0"],
		"long_dan": 3,
		"tiep_vien": [],
		"muu_ke_mo": []
	}
	var res: LoadResult = LevelLoader.parse_level(JSON.stringify(level_dict), "data/tran/test_lang_replay.json")
	assert_eq(res.errors, [] as Array[String])
	var level: LevelData = res.data as LevelData
	var stats: Stats = BoardFixture.stats()

	var controller: BattleController = BattleController.new()
	controller.start(level, stats)
	controller.begin()

	assert_eq(controller.snapshot().morale, 3)
	assert_eq(controller.snapshot().max_morale, 3)

	# Trong lượt người chơi: Khoái đi tới (2,3) và đánh (2,2), đẩy địch va vào làng (2,1) làm Lòng dân -1
	controller.submit(Command.move(1, Vector2i(2, 3)))
	controller.submit(Command.attack(1, Vector2i(2, 2)))
	assert_eq(controller.snapshot().morale, 2, "trong lượt người chơi, đẩy địch va vào làng làm Lòng dân giảm từ 3 xuống 2")

	# Chơi lại hiệp -> khôi phục Lòng dân về 3 (giá trị đầu lượt người chơi của hiệp 1)
	assert_true(controller.replay_round(), "chơi lại hiệp thành công")
	assert_eq(controller.snapshot().morale, 3, "chơi lại hiệp khôi phục Lòng dân về 3 (giá trị đầu lượt người chơi)")
	assert_eq(controller.snapshot().round_number, 1)
	assert_eq(controller.snapshot().unit_by_id(1).cell, Vector2i(1, 3), "Khoái trở lại ô đầu lượt 1")


func test_defeat_reason_is_mat_lang() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(2, 2): "B"}, {Vector2i(2, 1): "D"})
	state.morale = 1
	state.max_morale = 3
	var events: Array[BattleEvent] = []
	Effects.damage_morale(state, 1, Vector2i(2, 1), BattleEvent.Cause.STRIKE, events)
	RulesVictory.check(state, events)
	assert_eq(state.morale, 0)
	assert_eq(state.phase, BattleState.Phase.LOST, "hết Lòng dân thì trận kết thúc THUA ngay")
	assert_eq(state.defeat_reason, "mat_lang", "lý do thua ở lõi là mat_lang")
	assert_true(state.units.any(func(u: Unit) -> bool: return u.faction == Unit.Faction.DAI_VIET and u.hp > 0),
		"tướng Đại Việt vẫn còn sống nhưng vẫn thua vì mất làng")
