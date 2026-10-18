class_name ScenarioRunner
extends RefCounted
## Chạy một kịch bản luật: dựng bàn trước, chạy từng lệnh qua BattleController (như game thật, kể cả hủy),
## so kết quả với bàn sau (theo ô).
## Câu so sánh cho dev và log, không qua tr() (như câu lỗi của bộ nạp).

## Lệnh -> story sẽ viết luật cho lệnh đó. Lệnh có luật rồi thì bỏ khỏi bảng này và thêm nhánh trong _run_step.
const PENDING_RULES: Dictionary = {
	"danh": "2.1",
}

## Mã "tu_choi" của kịch bản -> lý do luật trả. Cùng khóa với ScenarioLoader.REJECT_CODES (test kiểm).
const REJECT_EVENTS: Dictionary = {
	"khong_co_quan": BattleEvent.Reject.NO_UNIT,
	"khong_phai_tuong": BattleEvent.Reject.NOT_GENERAL,
	"da_dung_o_do": BattleEvent.Reject.ALREADY_THERE,
	"khong_toi_duoc": BattleEvent.Reject.UNREACHABLE,
	"da_di_roi": BattleEvent.Reject.ALREADY_MOVED,
	"khong_con_nuoc_di": BattleEvent.Reject.NOTHING_TO_UNDO,
}

## Tên đầy đủ cho câu so sánh. Ký hiệu lấy ngược từ BoardText (unit_symbol, terrain_symbol).
const UNIT_NAMES: Dictionary = {
	UnitType.NGUYEN_KHOAI: "Nguyễn Khoái",
	UnitType.PHAM_NGU_LAO: "Phạm Ngũ Lão",
	UnitType.TRAN_KHANH_DU: "Trần Khánh Dư",
	UnitType.BO_BINH: "Bộ binh",
	UnitType.KY_BINH: "Kỵ binh",
	UnitType.CUNG_KY: "Cung kỵ",
}
const TERRAIN_NAMES: Dictionary = {
	Terrain.PLAIN: "đất trống",
	Terrain.RIVER: "sông",
	Terrain.FOREST: "rừng",
	Terrain.SPIKES: "hầm chông",
	Terrain.GRANARY: "kho lương",
	Terrain.VILLAGE: "làng",
	Terrain.PASS: "ô ải",
}


class ScenarioResult:
	extends RefCounted

	var problems: Array[String] = []
	var passed: bool:
		get:
			return problems.is_empty()


static func run(scenario: ScenarioData, stats: Stats) -> ScenarioResult:
	var result: ScenarioResult = ScenarioResult.new()
	var controller: BattleController = BattleController.new()
	controller.start(scenario.before, stats)
	for problem: String in controller.snapshot().validate():
		result.problems.append("trước: %s" % problem)
	if not result.passed:
		return result
	# Controller tự quay lại khi lệnh làm hỏng bất biến, nên validate() sau đó không thấy lỗi: nghe signal.
	var rolled_back: Array[String] = []
	controller.rolled_back.connect(func(problems: Array[String]) -> void: rolled_back.append_array(problems))
	for i: int in range(scenario.steps.size()):
		var problem: String = _run_step(controller, scenario.steps[i])
		for invariant: String in rolled_back:
			result.problems.append("bước %d: vi phạm bất biến: %s" % [i + 1, invariant])
		if not result.passed:
			return result
		if not problem.is_empty():
			result.problems.append("bước %d: %s" % [i + 1, problem])
			return result
		for invariant: String in controller.snapshot().validate():
			result.problems.append("bước %d: %s" % [i + 1, invariant])
		if not result.passed:
			return result
	result.problems.append_array(compare(controller.snapshot(), scenario))
	return result


## Ký hiệu của UnitType trên bàn cờ chữ (bảng ngược của BoardText.UNIT_SYMBOLS).
static func unit_symbol(type: int) -> String:
	var symbol: Variant = BoardText.UNIT_SYMBOLS.find_key(type)
	return symbol as String if symbol != null else "?"


## Ký hiệu của Terrain trên bàn cờ chữ (bảng ngược của BoardText.TERRAIN_SYMBOLS).
static func terrain_symbol(terrain: int) -> String:
	var symbol: Variant = BoardText.TERRAIN_SYMBOLS.find_key(terrain)
	return symbol as String if symbol != null else "?"


## Chạy một lệnh trên state. Trả "" nếu chạy được, hoặc câu báo vì sao không chạy được.
## Lệnh bị luật từ chối (REJECTED) đúng lý do kịch bản ghi ("tu_choi") vẫn là chạy được: không có gì đổi,
## bàn sau so như thường. Bị từ chối mà kịch bản không ghi, sai lý do, hay ghi mà không bị từ chối: trượt.
static func _run_step(controller: BattleController, step: ScenarioData.ScenarioStep) -> String:
	match step.kind:
		"di":
			var general: Unit = _general(controller.snapshot(), step.general)
			if general == null:
				return 'tướng "%s" không còn trên bàn' % unit_symbol(step.general)
			return _check_reject(controller.submit(Command.move(general.id, step.cell)), step.reject)
		"ket_thuc_luot":
			return _check_reject(controller.submit(Command.end_turn()), step.reject)
		"huy":
			return _check_reject(controller.undo(), step.reject)
		_:
			return 'lệnh "%s" chưa có luật (Story %s)' % [step.kind, PENDING_RULES.get(step.kind, "?")]


static func _check_reject(events: Array[BattleEvent], expected: String) -> String:
	var rejected: BattleEvent = null
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.REJECTED:
			rejected = event
			break
	if rejected == null:
		if expected.is_empty():
			return ""
		return 'kịch bản ghi "tu_choi": "%s" nhưng luật cho chạy' % expected
	var actual: Variant = REJECT_EVENTS.find_key(rejected.reject)
	if actual == expected:
		return ""
	if expected.is_empty():
		return 'luật từ chối ("%s": %s) mà kịch bản không ghi "tu_choi"' % [actual, rejected.reason]
	return 'luật từ chối vì "%s" (%s), kịch bản ghi "tu_choi": "%s"' % [actual, rejected.reason, expected]


static func _general(state: BattleState, type: int) -> Unit:
	for unit: Unit in state.units:
		if unit.type == type:
			return unit
	return null


## So state với bàn sau: địa hình rồi quân theo thứ tự đọc bàn, rồi hiệp và dấu "đã đi" (nếu kịch bản ghi).
## Mỗi chỗ khác một câu.
static func compare(state: BattleState, scenario: ScenarioData) -> Array[String]:
	var problems: Array[String] = []
	var expected: Dictionary = {}  # ô -> ExpectedUnit
	for unit: ScenarioData.ExpectedUnit in scenario.after_units:
		expected[unit.cell] = unit
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			var want: int = scenario.after_terrain[r * state.size.x + c]
			var got: int = state.terrain_at(cell)
			if want != got:
				problems.append('sau: ô %s mong đợi "%s" (%s), thực tế "%s" (%s)'
					% [BoardText.cell_text(cell), terrain_symbol(want), TERRAIN_NAMES.get(want, "?"),
						terrain_symbol(got), TERRAIN_NAMES.get(got, "?")])
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			var problem: String = _compare_cell(cell, expected.get(cell) as ScenarioData.ExpectedUnit,
				state.unit_at(cell))
			if not problem.is_empty():
				problems.append(problem)
	if scenario.after_round > 0 and state.round_number != scenario.after_round:
		problems.append("sau: mong đợi hiệp %d, thực tế hiệp %d" % [scenario.after_round, state.round_number])
	if scenario.checks_moved:
		for type: int in UnitType.GENERALS:
			var general: Unit = _general(state, type)
			if general == null or general.has_moved == scenario.after_moved.has(type):
				continue
			var want: String = "đã đi" if scenario.after_moved.has(type) else "chưa đi"
			var got: String = "đã đi" if general.has_moved else "chưa đi"
			problems.append("sau: %s (%s) mong đợi %s, thực tế %s"
				% [unit_symbol(type), UNIT_NAMES.get(type, "?"), want, got])
	return problems


static func _compare_cell(cell: Vector2i, want: ScenarioData.ExpectedUnit, got: Unit) -> String:
	var where: String = "sau: ô %s" % BoardText.cell_text(cell)
	if want == null and got == null:
		return ""
	if want == null:
		return "%s mong đợi trống, thực tế %s" % [where, _describe(got.type, got.hp)]
	if got == null:
		return "%s mong đợi %s, thực tế trống" % [where, _describe(want.type, want.hp)]
	if want.type != got.type:
		return "%s mong đợi %s, thực tế %s" % [where, _describe(want.type, want.hp), _describe(got.type, got.hp)]
	if want.hp != got.hp:
		return "%s %s mong đợi %d máu, thực tế %d máu" % [where, unit_symbol(want.type), want.hp, got.hp]
	return ""


## "1 (Nguyễn Khoái, 3 máu)"
static func _describe(type: int, hp: int) -> String:
	return "%s (%s, %d máu)" % [unit_symbol(type), UNIT_NAMES.get(type, "?"), hp]
