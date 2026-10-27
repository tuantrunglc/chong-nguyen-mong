class_name ScenarioViewer
extends SceneTree
## Công cụ duyệt kịch bản luật trên terminal (tools/xem_kich_ban.sh): bàn trước và bàn sau cạnh nhau.
## Chạy qua tools/xem_kich_ban.sh [nhom] [--tat_ca]. Tham số đến qua biến môi trường XEM_KICH_BAN_THAM_SO
## (mỗi dòng một tham số), vì AppState cảnh báo mọi tham số dòng lệnh nó không biết.
## Công cụ dòng lệnh nên in bằng print(). Không chạy luật: tác giả duyệt spec, không duyệt kết quả code.
## Chữ cho tác giả đọc đi qua bản dịch (khóa scenario.*); câu lỗi của bộ nạp thì không (như file trận).

const ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const ALL_FLAG: String = "--tat_ca"
## Bề ngang phần bàn trước (kể cả lề), để bàn sau thẳng cột.
const LEFT_WIDTH: int = 24
## Ghi chú của bàn sau bắt đầu ở cột này, hoặc lùi ra xa hơn (cả nhóm cùng lùi) khi ghi chú bàn trước dài.
const NOTE_WIDTH: int = 26
## Khoảng cách tối thiểu giữa ghi chú bàn trước và ghi chú bàn sau.
const NOTE_GAP: int = 2

## UnitType -> khóa dịch của tên đầy đủ.
const UNIT_NAME_KEYS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "scenario.unit.nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "scenario.unit.pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "scenario.unit.tran_khanh_du",
	UnitType.BO_BINH: "scenario.unit.bo_binh",
	UnitType.KY_BINH: "scenario.unit.ky_binh",
	UnitType.CUNG_KY: "scenario.unit.cung_ky",
}
## Địa hình bị quân che thì ghi chú dưới bàn (ô đi vào được mà có ký hiệu riêng).
const HIDDEN_TERRAIN_KEYS: Dictionary = {
	Terrain.SPIKES: "scenario.terrain.spikes",
	Terrain.PASS: "scenario.terrain.pass",
}
## Các loại ghi chú dưới bàn, theo thứ tự in: khóa nhãn và khoảng trắng sau nhãn (Dev Notes "Cách in").
const NOTE_KINDS: Array[Array] = [
	["scenario.viewer.hp", "  "],
	["scenario.viewer.under", " "],
]


const ARGS_ENV: String = "XEM_KICH_BAN_THAM_SO"


func _initialize() -> void:
	quit(_main(OS.get_environment(ARGS_ENV).split("\n", false)))


## Trả mã thoát: 0 là xong, 1 là có file sai định dạng hoặc tên nhóm không có.
func _main(args: PackedStringArray) -> int:
	var show_all: bool = false
	var group: String = ""
	for arg: String in args:
		if arg == ALL_FLAG:
			show_all = true
		elif not arg.begins_with("-") and group.is_empty():
			group = arg
		else:
			print(_t("scenario.viewer.unknown_arg") % arg)

	var stats_result: LoadResult = StatsLoader.load_stats(STATS_PATH)
	if not stats_result.ok:
		for message: String in stats_result.errors:
			print(message)
		return 1
	var stats: Stats = stats_result.data as Stats

	var files: Array[String] = ScenarioLoader.list_files(ROOT)
	if not group.is_empty() and not _groups(files).has(group):
		var groups: Array[String] = _groups(files)
		var shown_groups: String = ", ".join(groups) if not groups.is_empty() else _t("scenario.viewer.no_groups")
		print(_t("scenario.viewer.unknown_group") % [group, shown_groups])
		return 1

	var code: int = 0
	var considered: int = 0
	var shown: int = 0
	var pending: int = 0
	for path: String in files:
		if not group.is_empty() and _group_of(path) != group:
			continue
		considered += 1
		var r: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		if not r.ok:
			code = 1
			print("━━━ %s  [%s]" % [path.trim_prefix(ROOT + "/"), _t("scenario.viewer.invalid")])
			for message: String in r.errors:
				print("  ❌ " + message)
			print("")
			continue
		var scenario: ScenarioData = r.data as ScenarioData
		if not scenario.approved:
			pending += 1
		elif not show_all:
			continue
		shown += 1
		print(render(scenario, stats))

	if considered == 0:
		print(_t("scenario.viewer.none"))
	elif shown == 0 and code == 0:
		print(_t("scenario.viewer.none_pending"))
	elif show_all:
		print(_t("scenario.viewer.total_all") % [shown, pending])
	else:
		print(_t("scenario.viewer.total_pending") % pending)
	if pending > 0:
		print(_t("scenario.viewer.how_to_approve"))
	return code


## Tên các nhóm có kịch bản, theo thứ tự file. File nằm ngay trong kich_ban không thuộc nhóm nào.
static func _groups(files: Array[String]) -> Array[String]:
	var groups: Array[String] = []
	for path: String in files:
		var file_group: String = _group_of(path)
		if not file_group.is_empty() and not groups.has(file_group):
			groups.append(file_group)
	return groups


## Thư mục con đầu tiên tính từ kich_ban ("" nếu file nằm ngay trong kich_ban).
static func _group_of(path: String) -> String:
	var id: String = path.trim_prefix(ROOT + "/")
	return id.get_slice("/", 0) if id.contains("/") else ""


## Một kịch bản thành chữ: tên, mô tả, hành động, hai bàn cạnh nhau, ghi chú máu và địa hình bị che.
static func render(scenario: ScenarioData, stats: Stats) -> String:
	var lines: PackedStringArray = PackedStringArray()
	var status: String = _t("scenario.viewer.approved" if scenario.approved else "scenario.viewer.pending")
	lines.append("━━━ %s  [%s]" % [scenario.id, status])
	lines.append(scenario.description)
	lines.append("")
	if scenario.steps.is_empty():
		lines.append(_t("scenario.viewer.no_actions"))
	else:
		lines.append(_t("scenario.viewer.actions"))
		for i: int in range(scenario.steps.size()):
			var step: ScenarioData.ScenarioStep = scenario.steps[i]
			var text: String = _step_text(step)
			if not step.reject.is_empty():
				text += _t("scenario.viewer.rejected") % _t(ScenarioLoader.REJECT_CODES[step.reject] as String)
			lines.append("  %d. %s" % [i + 1, text])
	lines.append("")
	# Mưu kế mở / đã dùng ở bàn trước (Story 3.12): chỉ in khi kịch bản có mưu kế, để kịch bản cũ không đổi.
	if not scenario.before.stratagems.is_empty():
		var text: String = _t("scenario.viewer.stratagems_open") % _stratagem_names(scenario.before.stratagems, "")
		if not scenario.before.stratagems_used.is_empty():
			text += " · " + _t("scenario.viewer.stratagems_used_before") \
				% _stratagem_names(scenario.before.stratagems_used, "")
		lines.append(text)
		lines.append("")

	var size: Vector2i = scenario.before.size
	var before_units: Dictionary = {}  # ô -> [type, hp]
	for p: LevelData.UnitPlacement in scenario.before.units:
		before_units[p.cell] = [p.type, p.hp if p.hp > 0 else stats.max_hp(p.type)]
	var after_units: Dictionary = {}
	for u: ScenarioData.ExpectedUnit in scenario.after_units:
		after_units[u.cell] = [u.type, u.hp]
	var left: PackedStringArray = _board(size, scenario.before.terrain, before_units,
		_t("scenario.viewer.before"))
	var right: PackedStringArray = _board(size, scenario.after_terrain, after_units, _t("scenario.viewer.after"))
	# Bàn "Ô ĐỎ" cạnh TRƯỚC khi kịch bản đặt sẵn đòn ("truoc.bao_don", Story 2.8): ô đỏ như game vẽ ở bàn trước.
	var boards: Array[PackedStringArray] = [left]
	var before_marks: Dictionary = _before_marks(scenario, stats)
	if not scenario.before_telegraphs.is_empty():
		boards.append(_marks_board(size, before_marks))
	boards.append(right)
	# Bàn "Ô ĐỎ" cạnh SAU khi kịch bản ghi "sau.o_do" (Story 2.7).
	if scenario.checks_marks:
		boards.append(_marks_board(size, scenario.after_marks))
	var rows: int = 0
	for board: PackedStringArray in boards:
		rows = maxi(rows, board.size())
	for i: int in range(rows):
		var line: String = ""
		for b: int in range(boards.size()):
			var cell: String = boards[b][i] if i < boards[b].size() else ""
			line += cell if b == boards.size() - 1 else cell.rpad(LEFT_WIDTH)
		lines.append(line.strip_edges(false, true))

	lines.append_array(_notes_side_by_side(
		_notes(size, scenario.before.terrain, before_units, stats),
		_notes(size, scenario.after_terrain, after_units, stats),
		NOTE_WIDTH + (LEFT_WIDTH if not scenario.before_telegraphs.is_empty() else 0)))
	var after_state: String = _after_state(scenario)
	if not after_state.is_empty():
		lines.append("")
		lines.append("  " + after_state)
	if not scenario.before_telegraphs.is_empty():
		lines.append("")
		lines.append_array(_telegraph_lines(scenario.before_telegraphs, before_units,
			"scenario.viewer.before_telegraphs", "scenario.viewer.telegraphs_none"))
		if not before_marks.is_empty():
			lines.append_array(_marks_lines(size, before_marks))
	if scenario.checks_telegraphs:
		lines.append("")
		lines.append_array(_telegraph_lines(scenario.after_telegraphs, after_units, "scenario.viewer.telegraphs",
			"scenario.viewer.telegraphs_none"))
	if scenario.checks_marks:
		var notes: PackedStringArray = _marks_lines(size, scenario.after_marks)
		if not notes.is_empty():
			lines.append("")
			lines.append_array(notes)
	lines.append("")
	return "\n".join(lines)


## Ô đỏ của bàn trước (Story 2.8): dựng bàn trước với đòn đặt sẵn, tính như game (TelegraphMarks).
static func _before_marks(scenario: ScenarioData, stats: Stats) -> Dictionary:
	var state: BattleState = BattleState.from_level(scenario.before, stats)
	state.telegraphs = ScenarioRunner.before_telegraphs(scenario, stats)
	return TelegraphMarks.cells(state)


## Tiêu đề (header) rồi mỗi đòn một dòng theo số thứ tự ("truoc.bao_don" Story 2.8, "sau.bao_don" Story 2.6).
## units: ô -> [loại, máu] của bàn chứa chủ đòn.
static func _telegraph_lines(telegraphs: Array[ScenarioData.ExpectedTelegraph], units: Dictionary, header: String,
		none: String) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	if telegraphs.is_empty():
		lines.append("  " + _t(none))
		return lines
	lines.append("  " + _t(header))
	for t: ScenarioData.ExpectedTelegraph in telegraphs:
		var owner: Array = units.get(t.owner_cell, [-1, 0]) as Array
		var name: String = _unit_name(owner[0] as int)
		var text: String
		if t.kind == Telegraph.Kind.CELL:
			text = _t("scenario.viewer.telegraph_cell") % [name, BoardText.cell_text(t.owner_cell),
				BoardText.cell_text(t.target)]
		else:
			var code: String = str(BoardText.DIRECTION_CODES.find_key(t.target))
			text = _t("scenario.viewer.telegraph_charge") % [name, BoardText.cell_text(t.owner_cell),
				_t("scenario.viewer.direction_" + code)]
		lines.append("    %d. %s" % [t.order, text])
	return lines


## "Sau lệnh: hiệp 2 · đã đi: Nguyễn Khoái · đã đánh: ..." từ "sau.hiep", "sau.da_di", "sau.da_danh"; "" nếu kịch
## bản không ghi khóa nào.
static func _after_state(scenario: ScenarioData) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if scenario.after_round > 0:
		parts.append(_t("scenario.viewer.after_round") % scenario.after_round)
	if scenario.checks_moved:
		var names: PackedStringArray = PackedStringArray()
		for type: int in scenario.after_moved:
			names.append(_unit_name(type))
		var shown: String = ", ".join(names) if not names.is_empty() else _t("scenario.viewer.after_moved_none")
		parts.append(_t("scenario.viewer.after_moved") % shown)
	if scenario.checks_attacked:
		var names: PackedStringArray = PackedStringArray()
		for type: int in scenario.after_attacked:
			names.append(_unit_name(type))
		var shown: String = ", ".join(names) if not names.is_empty() \
			else _t("scenario.viewer.after_attacked_none")
		parts.append(_t("scenario.viewer.after_attacked") % shown)
	if scenario.checks_morale:
		parts.append(_t("scenario.viewer.after_morale") % scenario.after_morale)
	if scenario.checks_stratagems_used:
		parts.append(_t("scenario.viewer.after_stratagems_used")
			% _stratagem_names(scenario.after_stratagems_used, "scenario.viewer.after_stratagems_used_none"))
	if not scenario.after_outcome.is_empty():
		parts.append(_t("scenario.viewer.after_outcome") % _t("scenario.viewer.outcome_" + scenario.after_outcome))
	if parts.is_empty():
		return ""
	return _t("scenario.viewer.after_state") % " · ".join(parts)


## Các dòng của một bàn: tiêu đề, số cột, rồi từng hàng.
static func _board(size: Vector2i, terrain: PackedInt32Array, units: Dictionary, title: String) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("      " + title)
	var header: PackedStringArray = PackedStringArray()
	for c: int in range(size.x):
		header.append(str(c))
	lines.append("      " + " ".join(header))
	for r: int in range(size.y):
		var cells: PackedStringArray = PackedStringArray()
		for c: int in range(size.x):
			var cell: Vector2i = Vector2i(c, r)
			if units.has(cell):
				cells.append(ScenarioRunner.unit_symbol((units[cell] as Array)[0] as int))
			else:
				cells.append(ScenarioRunner.terrain_symbol(terrain[r * size.x + c]))
		lines.append("   %d  %s" % [r, " ".join(cells)])
	return lines


## Bàn "Ô ĐỎ": ô đỏ ghi số thứ tự đòn phủ nó (một chữ số), ô có từ hai đòn ghi "*"; ô khác ".".
static func _marks_board(size: Vector2i, marks: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("      " + _t("scenario.viewer.marks"))
	var header: PackedStringArray = PackedStringArray()
	for c: int in range(size.x):
		header.append(str(c))
	lines.append("      " + " ".join(header))
	for r: int in range(size.y):
		var cells: PackedStringArray = PackedStringArray()
		for c: int in range(size.x):
			var orders: Array = marks.get(Vector2i(c, r), []) as Array
			if orders.is_empty():
				cells.append(".")
			elif orders.size() == 1 and (orders[0] as int) < 10:
				cells.append(str(orders[0]))
			else:
				cells.append("*")
		lines.append("   %d  %s" % [r, " ".join(cells)])
	return lines


## Dòng dưới bàn "Ô ĐỎ": ô có từ hai đòn ("3,3: đòn 1·2"), hoặc "không ô nào đỏ".
static func _marks_lines(size: Vector2i, marks: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	if marks.is_empty():
		lines.append("  " + _t("scenario.viewer.marks_none"))
		return lines
	for r: int in range(size.y):
		for c: int in range(size.x):
			var orders: Array = marks.get(Vector2i(c, r), []) as Array
			if orders.size() < 2:
				continue
			var parts: PackedStringArray = PackedStringArray()
			for order: Variant in orders:
				parts.append(str(order))
			lines.append("  " + _t("scenario.viewer.marks_many") % [BoardText.cell_text(Vector2i(c, r)), "·".join(parts)])
	return lines


## Ghi chú của một bàn, mỗi loại trong NOTE_KINDS một danh sách: máu không đầy, địa hình bị quân che.
static func _notes(size: Vector2i, terrain: PackedInt32Array, units: Dictionary, stats: Stats) -> Array[PackedStringArray]:
	var hp_notes: PackedStringArray = PackedStringArray()
	var hidden_notes: PackedStringArray = PackedStringArray()
	for r: int in range(size.y):
		for c: int in range(size.x):
			var cell: Vector2i = Vector2i(c, r)
			if not units.has(cell):
				continue
			var type: int = (units[cell] as Array)[0] as int
			var hp: int = (units[cell] as Array)[1] as int
			var kind: int = terrain[r * size.x + c]
			var where: String = BoardText.cell_text(cell)
			if hp < stats.max_hp(type):
				hp_notes.append("%s %s %d/%d" % [where, _unit_name(type), hp, stats.max_hp(type)])
			if HIDDEN_TERRAIN_KEYS.has(kind):
				hidden_notes.append("%s %s (%s)" % [where, ScenarioRunner.terrain_symbol(kind),
					_t(HIDDEN_TERRAIN_KEYS[kind] as String)])
	return [hp_notes, hidden_notes]


## Ghi chú hai bàn đặt cạnh nhau, cùng loại cùng dòng (Máu cạnh Máu). Ghi chú bàn sau luôn thẳng cột với nhau.
## min_width: cột bắt đầu ghi chú bàn sau (rộng thêm LEFT_WIDTH khi có bàn "Ô ĐỎ" đứng giữa TRƯỚC và SAU).
static func _notes_side_by_side(left: Array[PackedStringArray], right: Array[PackedStringArray],
		min_width: int = NOTE_WIDTH) -> PackedStringArray:
	var pairs: Array[PackedStringArray] = []  # [trái, phải]
	for k: int in range(NOTE_KINDS.size()):
		var label: String = _t(NOTE_KINDS[k][0] as String)
		var gap: String = NOTE_KINDS[k][1] as String
		for i: int in range(maxi(left[k].size(), right[k].size())):
			pairs.append(PackedStringArray([_note_line(label, gap, left[k], i), _note_line(label, gap, right[k], i)]))
	if pairs.is_empty():
		return PackedStringArray()
	var width: int = min_width
	for pair: PackedStringArray in pairs:
		width = maxi(width, pair[0].length() + NOTE_GAP)
	var lines: PackedStringArray = PackedStringArray([""])
	for pair: PackedStringArray in pairs:
		lines.append((pair[0].rpad(width) + pair[1]).strip_edges(false, true))
	return lines


## Dòng thứ i của một loại ghi chú: dòng đầu có nhãn, các dòng sau thụt vào cho thẳng cột. Hết ghi chú thì "".
static func _note_line(label: String, gap: String, notes: PackedStringArray, i: int) -> String:
	if i >= notes.size():
		return ""
	var prefix: String = label if i == 0 else "".rpad(label.length())
	return "  %s%s%s" % [prefix, gap, notes[i]]


static func _step_text(step: ScenarioData.ScenarioStep) -> String:
	match step.kind:
		"di":
			return _t("scenario.viewer.step_move") % [_unit_name(step.general), BoardText.cell_text(step.cell)]
		"danh":
			return _t("scenario.viewer.step_attack") % [_unit_name(step.general), BoardText.cell_text(step.cell)]
		"huy":
			return _t("scenario.viewer.step_undo")
		"ket_thuc_luot":
			return _t("scenario.viewer.step_end_turn")
		"muu_ke":
			return _t("scenario.viewer.step_stratagem") % _stratagem_name(step.stratagem)
	return step.kind


## Tên mưu kế hiển thị (Story 3.12).
static func _stratagem_name(kind: int) -> String:
	return _t("stratagem." + Stratagem.name_of(kind))


static func _stratagem_names(kinds: Array[int], none_key: String) -> String:
	var names: PackedStringArray = PackedStringArray()
	for kind: int in kinds:
		names.append(_stratagem_name(kind))
	return ", ".join(names) if not names.is_empty() else _t(none_key)


static func _unit_name(type: int) -> String:
	return _t(UNIT_NAME_KEYS.get(type, "?") as String)


## tr() cho hàm static (SceneTree không có tr() trong hàm static).
static func _t(key: String) -> String:
	return TranslationServer.translate(key)
