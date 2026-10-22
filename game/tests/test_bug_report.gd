extends GutTest
## Báo cáo F2 (Story 2.13): dựng kịch bản tái hiện từ bàn đầu hiệp + lệnh trong hiệp, kèm bàn hiện tại, 200 dòng
## log và phiên bản. Test quan trọng nhất: tách khối JSON ra, cho bộ nạp + bộ chạy kịch bản phát lại, phải ra đúng
## bàn đang chơi (AC 1 và AC 3 ở mức dữ liệu).

const META: Dictionary = {
	"build": "v0.1.0 · abc1234",
	"tran": "thu",
	"ten_tran": "Trận thử",
	"luc": "2026-10-22 15:00:00",
	"lan_mo": 3,
}


func after_each() -> void:
	Log.clear()


## 5×5 toàn đất: Khoái 1,1; Lão 1,2; Bộ binh 2,1 (kề Khoái, nên pha chuẩn bị đứng yên và báo đòn vào 1,1).
func _level() -> LevelData:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(5, 5)
	for i: int in range(level.size.x * level.size.y):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(1, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.PHAM_NGU_LAO, Vector2i(1, 2)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(2, 1)))
	return level


func _controller() -> BattleController:
	var controller: BattleController = BattleController.new()
	controller.start(_level(), BoardFixture.stats())
	return controller


## 5×5: Khoái (1,1), Kỵ binh 2 máu (2,1) báo đòn 1 vào (1,1), Bộ binh (3,3) báo đòn 2 vào (3,4).
func _telegraphed_controller() -> BattleController:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(5, 5)
	for i: int in range(level.size.x * level.size.y):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(1, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.KY_BINH, Vector2i(2, 1)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(3, 3)))
	var stats: Stats = BoardFixture.stats()
	var state: BattleState = BattleState.from_level(level, stats)
	var horse: Unit = state.unit_at(Vector2i(2, 1))
	var foot: Unit = state.unit_at(Vector2i(3, 3))
	var controller: BattleController = BattleController.new()
	controller.start(level, stats, [Telegraph.new(horse.id, Telegraph.Kind.CELL, Vector2i(-1, 0), 1),
		Telegraph.new(foot.id, Telegraph.Kind.CELL, Vector2i(0, 1), 2)])
	return controller


## "chủ:kiểu:ô tương đối:số thứ tự" của mọi đòn — để so bàn phát lại với bàn thật.
func _strikes(state: BattleState) -> Array[String]:
	var out: Array[String] = []
	for telegraph: Telegraph in state.telegraphs:
		out.append("%d:%d:%s:%d" % [telegraph.owner_id, telegraph.kind,
			BoardText.cell_text(telegraph.offset), telegraph.order])
	return out


func _report(controller: BattleController, log_lines: PackedStringArray = PackedStringArray()) -> String:
	return BugReport.build(controller.snapshot(), controller.round_start_snapshot(),
		controller.round_commands(), log_lines, META)


func _enemy(state: BattleState) -> Unit:
	for unit: Unit in state.units:
		if unit.faction == Unit.Faction.NGUYEN:
			return unit
	return null


## Khối ```json trong báo cáo -> Dictionary.
func _scenario_json(report: String) -> Dictionary:
	var start: int = report.find("```json")
	assert_gt(start, -1, "báo cáo phải có khối json")
	var body_start: int = report.find("\n", start) + 1
	var end: int = report.find("```", body_start)
	assert_gt(end, body_start, "khối json phải đóng")
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(report.substr(body_start, end - body_start)), OK, "khối json đọc được")
	return parser.data as Dictionary


## Dictionary kịch bản -> ScenarioData qua đúng bộ nạp của game (không tự dựng tắt).
func _scenario(data: Dictionary) -> ScenarioData:
	var result: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(data, "  "),
		"user://bao_loi_f2.json", "res://", BoardFixture.stats())
	assert_eq(result.errors, [] as Array[String], "kịch bản trong báo cáo phải nạp được")
	return result.data as ScenarioData


func test_report_has_every_required_section() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(2, 1): "B"})
	var text: String = BugReport.build(state, state.clone(), [] as Array[Dictionary],
		PackedStringArray(["dòng một", "dòng hai"]), META)
	assert_string_contains(text, "Hào Khí Đông A — báo lỗi")
	assert_string_contains(text, "phiên bản: v0.1.0 · abc1234")
	assert_string_contains(text, "trận: thu — Trận thử · hiệp 1")
	assert_string_contains(text, "## Kịch bản tái hiện")
	assert_string_contains(text, "```json")
	assert_string_contains(text, "## Bàn hiện tại")
	assert_string_contains(text, "## Nhật ký (2 dòng gần nhất")
	assert_string_contains(text, "dòng một\ndòng hai")
	assert_string_contains(text, "## Ghi chú cho AI")


func test_no_battle_report_has_no_scenario() -> void:
	var text: String = BugReport.build(null, null, [] as Array[Dictionary],
		PackedStringArray(["[INFO][battle] nạp trận"]), META)
	assert_string_contains(text, "trận: thu (không có bàn)", "vẫn giữ id trận để biết trận nào hỏng")
	assert_string_contains(text, "[INFO][battle] nạp trận")
	assert_false(text.contains("```json"), "không có trận thì không có kịch bản")
	assert_string_contains(text, "Không có trận đang chạy")


func test_truoc_layers_match_the_board() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(2, 1): "B"},
		{Vector2i(0, 0): "~"}, {Vector2i(2, 1): 1})
	var layers: Dictionary = BugReport.before_layers(state)
	var terrain: Array[String] = layers["dia_hinh"] as Array[String]
	assert_eq(terrain.size(), 7, "bảy hàng")
	assert_eq(terrain[0], "~ . . . . . .", "hàng 0 có sông ở cột 0")
	var units: Array[String] = layers["quan"] as Array[String]
	assert_eq(units[1], ". 1 B . . . .", "hàng 1 có Khoái và Bộ binh")
	var hp: Dictionary = layers["mau"] as Dictionary
	assert_eq(hp.size(), 1, "chỉ quân thiếu máu mới ghi")
	assert_eq(int(hp["2,1"]), 1, "Bộ binh còn 1 máu")
	assert_eq(layers["thu_tu_dich"], ["2,1"] as Array[String], "thứ tự quân Nguyên theo ô")


func test_truoc_omits_mau_when_nobody_is_hurt() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(2, 1): "B"})
	assert_false(BugReport.before_layers(state).has("mau"), "không ai thiếu máu thì không có khóa mau")


func test_bao_don_lists_cell_and_direction_strikes() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(2, 1): "B",
		Vector2i(4, 4): "K"})
	var infantry: Unit = state.unit_at(Vector2i(2, 1))
	var cavalry: Unit = state.unit_at(Vector2i(4, 4))
	state.telegraphs.append(Telegraph.new(cavalry.id, Telegraph.Kind.DIRECTION, Vector2i(-1, 0), 1))
	state.telegraphs.append(Telegraph.new(infantry.id, Telegraph.Kind.CELL, Vector2i(-1, 0), 2))
	var strikes: Array = BugReport.strikes_layer(state)
	assert_eq(strikes.size(), 2, "hai đòn")
	assert_eq(strikes[0] as Dictionary, {"thu_tu": 1, "quan": "4,4", "huong": "T"} as Dictionary,
		"Kỵ binh xung phong hướng Tây")
	assert_eq(strikes[1] as Dictionary, {"thu_tu": 2, "quan": "2,1", "o": "1,1"} as Dictionary,
		"Bộ binh chém ô 1,1")


func test_strike_of_dead_owner_is_dropped_and_mentioned() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(3, 3): "B"})
	state.telegraphs.append(Telegraph.new(999, Telegraph.Kind.CELL, Vector2i(-1, 0), 1))
	assert_eq(BugReport.strikes_layer(state).size(), 0, "chủ đã gục: không ghi được vào kịch bản")
	assert_eq(BugReport.dropped_strikes(state), 1, "đếm được đòn bị bỏ")
	assert_false(BugReport.after_layers(state).has("bao_don"), "không ghi được hết thì bỏ cả khóa")
	var lines: PackedStringArray = BugReport.current_section(state)
	assert_has(lines, "bỏ 1 đòn không ghi được vào kịch bản (chủ đã gục / ô đích ngoài bàn / hướng lạ)")


func test_off_board_strike_target_is_dropped() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(3, 0): "B"})
	var foot: Unit = state.unit_at(Vector2i(3, 0))
	state.telegraphs.append(Telegraph.new(foot.id, Telegraph.Kind.CELL, Vector2i(0, -1), 1))
	assert_eq(BugReport.strikes_layer(state).size(), 0, "ô đích 3,-1 ngoài bàn: bộ nạp sẽ từ chối")
	assert_eq(BugReport.dropped_strikes(state), 1)


func test_commands_become_scenario_steps() -> void:
	var commands: Array[Dictionary] = [
		{"lenh": "di", "tuong": 1, "o": Vector2i(3, 4), "tu_choi": BattleEvent.Reject.NONE},
		{"lenh": "danh", "tuong": 2, "o": Vector2i(3, 3), "tu_choi": BattleEvent.Reject.NOT_IN_RANGE},
		{"lenh": "huy", "tuong": 0, "o": Vector2i.ZERO, "tu_choi": BattleEvent.Reject.NONE},
	]
	var steps: Array = BugReport.command_entries(commands)
	assert_eq(steps.size(), 3)
	assert_eq(steps[0] as Dictionary, {"lenh": "di", "tuong": "1", "o": "3,4"} as Dictionary)
	assert_eq(steps[1] as Dictionary,
		{"lenh": "danh", "tuong": "2", "o": "3,3", "tu_choi": "ngoai_tam"} as Dictionary,
		"lệnh bị từ chối giữ mã lý do")
	assert_eq(steps[2] as Dictionary, {"lenh": "huy"} as Dictionary, "hủy không có tướng/ô")


func test_reject_codes_match_scenario_runner() -> void:
	for reject: int in BugReport.REJECT_CODES:
		var code: String = str(BugReport.REJECT_CODES[reject])
		assert_true(ScenarioRunner.REJECT_EVENTS.has(code), "mã %s phải có trong bộ chạy kịch bản" % code)
		assert_eq(int(ScenarioRunner.REJECT_EVENTS[code]), reject, "mã %s phải trỏ về đúng lý do" % code)
	assert_eq(BugReport.REJECT_CODES.size(), ScenarioRunner.REJECT_EVENTS.size(), "không thiếu mã nào")
	for value: int in BattleEvent.Reject.values():
		if value == BattleEvent.Reject.NONE:
			continue
		assert_true(BugReport.REJECT_CODES.has(value), "lý do từ chối %d phải có mã trong báo cáo" % value)


func test_log_keeps_the_last_200_lines() -> void:
	var lines: PackedStringArray = PackedStringArray()
	for i: int in range(250):
		lines.append("dòng %d" % i)
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1"})
	var text: String = BugReport.build(state, state.clone(), [] as Array[Dictionary], lines, META)
	assert_string_contains(text, "## Nhật ký (200 dòng gần nhất")
	assert_false(text.contains("dòng 49\n"), "bỏ dòng cũ nhất")
	assert_string_contains(text, "dòng 50")
	assert_string_contains(text, "dòng 249")


func test_report_does_not_touch_the_live_state() -> void:
	var controller: BattleController = _controller()
	controller.begin()
	var before: Array[String] = BoardFixture.picture(controller.snapshot())
	_report(controller)
	assert_eq(BoardFixture.picture(controller.snapshot()), before, "dựng báo cáo không đổi trận")
	assert_false(controller.can_undo(), "không tạo bản chụp hủy")


## AC 1 + AC 3: báo cáo lấy giữa hiệp, phát lại bằng chính bộ nạp + bộ chạy kịch bản, phải ra đúng bàn đang chơi.
func test_report_replays_to_the_live_board() -> void:
	var controller: BattleController = _controller()
	controller.begin()
	controller.submit(Command.move(2, Vector2i(1, 3)))
	var enemy: Unit = _enemy(controller.snapshot())
	controller.submit(Command.attack(1, enemy.cell))
	controller.undo()  # đánh đã xóa bản chụp hủy -> bị từ chối (lệnh này thuộc hiệp cũ, không vào hanh_dong của hiệp mới)
	controller.submit(Command.end_turn())
	controller.submit(Command.move(1, Vector2i(0, 1)))
	var data: Dictionary = _scenario_json(_report(controller))
	var steps: Array = data["hanh_dong"] as Array
	assert_eq(steps.size(), 1, "chỉ lệnh của hiệp đang chơi")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(_scenario(data), BoardFixture.stats())
	assert_true(run.passed, "kịch bản phát lại không lỗi: %s" % str(run.problems))
	assert_eq(BoardFixture.picture(run.final_state), BoardFixture.picture(controller.snapshot()),
		"bàn sau khi phát lại khớp bàn đang chơi (ô, máu, đã đi, đã đánh)")
	assert_eq(_strikes(run.final_state), _strikes(controller.snapshot()), "đòn đã báo cũng khớp")


## AC 3: F2 rơi đúng lúc pha địch vừa chạy xong (chưa ra lệnh nào ở hiệp mới) thì báo cáo phải dùng hiệp TRƯỚC
## + `ket_thuc_luot`, để phát lại ra cả pha địch chứ không chỉ chụp bàn sau nó.
func test_report_right_after_end_turn_keeps_the_enemy_phase() -> void:
	var controller: BattleController = _controller()
	controller.begin()
	controller.submit(Command.move(2, Vector2i(1, 3)))
	var enemy: Unit = _enemy(controller.snapshot())
	controller.submit(Command.attack(1, enemy.cell))
	controller.submit(Command.end_turn())
	assert_eq(controller.round_commands().size(), 3, "báo cáo vẫn thấy ba lệnh của hiệp trước")
	var data: Dictionary = _scenario_json(_report(controller))
	var steps: Array = data["hanh_dong"] as Array
	assert_eq(steps.size(), 3, "ba lệnh của hiệp trước")
	assert_eq(str((steps[2] as Dictionary)["lenh"]), "ket_thuc_luot", "lệnh cuối là kết thúc lượt")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(_scenario(data), BoardFixture.stats())
	assert_true(run.passed, "kịch bản phát lại không lỗi: %s" % str(run.problems))
	assert_eq(BoardFixture.picture(run.final_state), BoardFixture.picture(controller.snapshot()),
		"phát lại có cả pha địch: bàn khớp")
	assert_eq(_strikes(run.final_state), _strikes(controller.snapshot()), "đòn đã báo sau pha địch cũng khớp")


## Lệnh bị từ chối trong hiệp vào `hanh_dong` kèm mã lý do và phát lại khớp — nhánh `tu_choi` trước đây chỉ được
## kiểm ở mức layer bằng dict tự dựng.
func test_rejected_command_is_replayed() -> void:
	var controller: BattleController = _controller()
	controller.begin()
	controller.submit(Command.attack(1, Vector2i(4, 4)))  # ngoài tầm
	var data: Dictionary = _scenario_json(_report(controller))
	var steps: Array = data["hanh_dong"] as Array
	assert_eq(steps.size(), 1, "lệnh bị từ chối vẫn có trong hanh_dong")
	assert_true((steps[0] as Dictionary).has("tu_choi"), "kèm mã lý do")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(_scenario(data), BoardFixture.stats())
	assert_true(run.passed, "kịch bản có bước bị từ chối vẫn phát lại được: %s" % str(run.problems))
	assert_eq(BoardFixture.picture(run.final_state), BoardFixture.picture(controller.snapshot()))


## `sau` ghi cờ đã đi/đã đánh và kết cục (định dạng kiểm được cả ba) — trước đây chỉ in ở phần "bàn hiện tại".
func test_sau_records_flags_and_outcome() -> void:
	var controller: BattleController = _controller()
	controller.begin()
	controller.submit(Command.move(1, Vector2i(0, 1)))
	var data: Dictionary = _scenario_json(_report(controller))
	var sau: Dictionary = data["sau"] as Dictionary
	assert_eq(sau["da_di"], ["1"] as Array[String], "Khoái đã đi")
	assert_eq(sau["da_danh"], [] as Array[String])
	assert_eq(str(sau["ket_qua"]), "dang_choi")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(_scenario(data), BoardFixture.stats())
	assert_true(run.passed, "kịch bản có da_di/ket_qua vẫn phát lại được: %s" % str(run.problems))


## HIGH của review: giết một chủ đòn khi còn đòn khác — `sau` không ghi được hết thì bỏ cả khóa `bao_don`, và báo
## cáo vẫn phát lại được (trước khi sửa: `sau: thừa đòn 1` → kịch bản trong báo cáo luôn trượt).
func test_sau_omits_bao_don_when_a_strike_cannot_be_written() -> void:
	var controller: BattleController = _telegraphed_controller()
	controller.submit(Command.attack(1, Vector2i(2, 1)))
	assert_eq(controller.snapshot().telegraphs.size(), 2, "cả hai đòn còn trên bàn (đòn của chủ đã gục chưa bị xoá)")
	var data: Dictionary = _scenario_json(_report(controller))
	assert_false((data["sau"] as Dictionary).has("bao_don"), "không ghi được hết thì bỏ cả khóa")
	assert_true((data["truoc"] as Dictionary).has("bao_don"), "bàn đầu hiệp vẫn ghi đủ hai đòn")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(_scenario(data), BoardFixture.stats())
	assert_true(run.passed, "báo cáo phải phát lại được, không 'thừa đòn': %s" % str(run.problems))
	assert_eq(BoardFixture.picture(run.final_state), BoardFixture.picture(controller.snapshot()))
	assert_eq(_strikes(run.final_state), _strikes(controller.snapshot()), "đòn còn treo trên bàn phát lại khớp")
	var lines: PackedStringArray = BugReport.current_section(controller.snapshot())
	assert_has(lines, "bỏ 1 đòn không ghi được vào kịch bản (chủ đã gục / ô đích ngoài bàn / hướng lạ)")
