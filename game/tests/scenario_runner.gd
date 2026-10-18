class_name ScenarioRunner
extends RefCounted
## Chạy một kịch bản luật: dựng bàn trước, chạy từng lệnh, so kết quả với bàn sau (theo ô).
## Câu so sánh cho dev và log, không qua tr() (như câu lỗi của bộ nạp).

## Lệnh -> story sẽ viết luật cho lệnh đó. Lệnh có luật rồi thì bỏ khỏi bảng này và thêm nhánh trong _run_step.
const PENDING_RULES: Dictionary = {
	"di": "1.4",
	"huy": "1.5",
	"ket_thuc_luot": "1.5",
	"danh": "2.1",
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
	var state: BattleState = BattleState.from_level(scenario.before, stats)
	for problem: String in state.validate():
		result.problems.append("trước: %s" % problem)
	if not result.passed:
		return result
	for i: int in range(scenario.steps.size()):
		var problem: String = _run_step(state, scenario.steps[i])
		if not problem.is_empty():
			result.problems.append("bước %d: %s" % [i + 1, problem])
			return result
		for invariant: String in state.validate():
			result.problems.append("bước %d: %s" % [i + 1, invariant])
		if not result.passed:
			return result
	result.problems.append_array(compare(state, scenario))
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
static func _run_step(_state: BattleState, step: ScenarioData.ScenarioStep) -> String:
	match step.kind:
		_:
			return 'lệnh "%s" chưa có luật (Story %s)' % [step.kind, PENDING_RULES.get(step.kind, "?")]


## So state với bàn sau: địa hình rồi quân, theo thứ tự đọc bàn. Mỗi chỗ khác một câu.
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
