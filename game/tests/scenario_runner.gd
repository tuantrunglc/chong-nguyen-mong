class_name ScenarioRunner
extends RefCounted
## Chạy một kịch bản luật: dựng bàn trước, chạy từng lệnh qua BattleController (như game thật, kể cả hủy),
## so kết quả với bàn sau (theo ô).
## Câu so sánh cho dev và log, không qua tr() (như câu lỗi của bộ nạp).

## Lệnh -> story sẽ viết luật cho lệnh đó. Lệnh có luật rồi thì bỏ khỏi bảng này và thêm nhánh trong _run_step.
const PENDING_RULES: Dictionary = {}

## Mã "tu_choi" của kịch bản -> lý do luật trả. Cùng khóa với ScenarioLoader.REJECT_CODES (test kiểm).
const REJECT_EVENTS: Dictionary = {
	"khong_co_quan": BattleEvent.Reject.NO_UNIT,
	"khong_phai_tuong": BattleEvent.Reject.NOT_GENERAL,
	"da_dung_o_do": BattleEvent.Reject.ALREADY_THERE,
	"khong_toi_duoc": BattleEvent.Reject.UNREACHABLE,
	"da_di_roi": BattleEvent.Reject.ALREADY_MOVED,
	"khong_con_nuoc_di": BattleEvent.Reject.NOTHING_TO_UNDO,
	"da_danh_roi": BattleEvent.Reject.ALREADY_ATTACKED,
	"khong_ke": BattleEvent.Reject.NOT_ADJACENT,
	"khong_co_dich": BattleEvent.Reject.NO_TARGET,
	"ngoai_tam": BattleEvent.Reject.NOT_IN_RANGE,
	"tran_da_het": BattleEvent.Reject.BATTLE_OVER,
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
		"danh":
			var general: Unit = _general(controller.snapshot(), step.general)
			if general == null:
				return 'tướng "%s" không còn trên bàn' % unit_symbol(step.general)
			return _check_reject(controller.submit(Command.attack(general.id, step.cell)), step.reject)
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


## So state với bàn sau: địa hình rồi quân theo thứ tự đọc bàn, rồi hiệp, dấu "đã đi", "đã đánh" (nếu kịch bản ghi).
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
	if scenario.checks_attacked:
		for type: int in UnitType.GENERALS:
			var general: Unit = _general(state, type)
			if general == null or general.has_attacked == scenario.after_attacked.has(type):
				continue
			var want: String = "đã đánh" if scenario.after_attacked.has(type) else "chưa đánh"
			var got: String = "đã đánh" if general.has_attacked else "chưa đánh"
			problems.append("sau: %s (%s) mong đợi %s, thực tế %s"
				% [unit_symbol(type), UNIT_NAMES.get(type, "?"), want, got])
	if not scenario.after_outcome.is_empty() and _outcome(state) != scenario.after_outcome:
		problems.append('sau: mong đợi kết cục "%s", thực tế "%s"' % [scenario.after_outcome, _outcome(state)])
	if scenario.checks_telegraphs:
		problems.append_array(_compare_telegraphs(state, scenario.after_telegraphs))
	if scenario.checks_marks:
		problems.append_array(_compare_marks(state, scenario.after_marks))
	return problems


## So ô đỏ (TelegraphMarks.cells) theo thứ tự đọc bàn: mỗi ô khác một câu.
static func _compare_marks(state: BattleState, wanted: Dictionary) -> Array[String]:
	var problems: Array[String] = []
	var got: Dictionary = TelegraphMarks.cells(state)
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			var want: Variant = wanted.get(cell)
			var have: Variant = got.get(cell)
			if want == have:
				continue
			problems.append("sau: ô %s mong đợi %s, thực tế %s"
				% [BoardText.cell_text(cell), _marks_text(want), _marks_text(have)])
	return problems


## "đỏ (đòn 1·2)" hoặc "không đỏ".
static func _marks_text(orders: Variant) -> String:
	if orders == null:
		return "không đỏ"
	var parts: PackedStringArray = PackedStringArray()
	for order: int in orders as Array[int]:
		parts.append(str(order))
	return "đỏ (đòn %s)" % "·".join(parts)


## So đòn đã báo theo số thứ tự: mỗi số thứ tự có ở một bên mà khác hoặc thiếu ở bên kia là một câu.
static func _compare_telegraphs(state: BattleState, wanted: Array[ScenarioData.ExpectedTelegraph]) -> Array[String]:
	var problems: Array[String] = []
	var got: Dictionary = {}  # thu_tu -> mô tả đòn thực tế
	var orders: Array[int] = []
	for t: Telegraph in state.telegraphs:
		var owner: Unit = state.unit_by_id(t.owner_id)
		var owner_cell: Vector2i = owner.cell if owner != null else Telegraph.NO_CELL
		var target: Vector2i = t.target_cell(state) if t.kind == Telegraph.Kind.CELL else t.offset
		got[t.order] = telegraph_text(owner_cell, t.kind, target)
		if not orders.has(t.order):
			orders.append(t.order)
	for w: ScenarioData.ExpectedTelegraph in wanted:
		var want_text: String = telegraph_text(w.owner_cell, w.kind, w.target)
		if not got.has(w.order):
			problems.append("sau: đòn %d mong đợi %s, thực tế không có đòn %d" % [w.order, want_text, w.order])
		elif got[w.order] != want_text:
			problems.append("sau: đòn %d mong đợi %s, thực tế %s" % [w.order, want_text, got[w.order]])
	orders.sort()
	for order: int in orders:
		var listed: bool = false
		for w: ScenarioData.ExpectedTelegraph in wanted:
			listed = listed or w.order == order
		if not listed:
			problems.append("sau: thừa đòn %d: %s" % [order, got[order]])
	return problems


## "quân ở 3,3 đánh ô 3,4" hoặc "quân ở 0,3 xung phong hướng D" (cho câu so sánh, không qua tr()).
static func telegraph_text(owner_cell: Vector2i, kind: Telegraph.Kind, target: Vector2i) -> String:
	if kind == Telegraph.Kind.CELL:
		return "quân ở %s đánh ô %s" % [BoardText.cell_text(owner_cell), BoardText.cell_text(target)]
	var code: Variant = BoardText.DIRECTION_CODES.find_key(target)
	return "quân ở %s xung phong hướng %s" % [BoardText.cell_text(owner_cell), code if code != null else "?"]


## Kết cục của state theo cách kịch bản ghi ("ket_qua").
static func _outcome(state: BattleState) -> String:
	match state.phase:
		BattleState.Phase.WON:
			return "thang"
		BattleState.Phase.LOST:
			return "thua"
	return "dang_choi"


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
