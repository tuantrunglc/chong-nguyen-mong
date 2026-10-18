class_name ScenarioViewer
extends SceneTree
## Công cụ duyệt kịch bản luật trên terminal (tools/xem_kich_ban.sh): bàn trước và bàn sau cạnh nhau.
## Chạy qua tools/xem_kich_ban.sh [nhom] [--tat_ca]. Tham số đến qua biến môi trường XEM_KICH_BAN_THAM_SO
## (mỗi dòng một tham số), vì AppState cảnh báo mọi tham số dòng lệnh nó không biết.
## Công cụ dòng lệnh nên in bằng print(). Không chạy luật: tác giả duyệt spec, không duyệt kết quả code.

const ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const ALL_FLAG: String = "--tat_ca"
## Bề ngang phần bàn trước (kể cả lề), để bàn sau thẳng cột.
const LEFT_WIDTH: int = 24

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
			print('bỏ qua tham số lạ: "%s"' % arg)

	var stats_result: LoadResult = StatsLoader.load_stats(STATS_PATH)
	if not stats_result.ok:
		for message: String in stats_result.errors:
			print(message)
		return 1
	var stats: Stats = stats_result.data as Stats

	var files: Array[String] = ScenarioLoader.list_files(ROOT)
	var groups: Array[String] = []
	for path: String in files:
		var file_group: String = _group_of(path)
		if not groups.has(file_group):
			groups.append(file_group)
	if not group.is_empty() and not groups.has(group):
		print('không có nhóm "%s". Các nhóm đang có: %s' % [group, ", ".join(groups)])
		return 1

	var code: int = 0
	var shown: int = 0
	var pending: int = 0
	for path: String in files:
		if not group.is_empty() and _group_of(path) != group:
			continue
		var r: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		if not r.ok:
			code = 1
			print("━━━ %s  [sai định dạng]" % path.trim_prefix(ROOT + "/"))
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

	if shown == 0 and code == 0:
		print("Không có kịch bản nào chờ duyệt.")
	elif show_all:
		print("Tổng: %d kịch bản (%d chờ duyệt)." % [shown, pending])
	else:
		print("Tổng: %d kịch bản chờ duyệt." % pending)
	if pending > 0:
		print('Duyệt: thấy đúng thì đổi "da_duyet": false thành true trong file, hoặc nhắn AI "đúng"/"sai: <lý do>".')
	return code


## Thư mục con đầu tiên tính từ kich_ban ("" nếu file nằm ngay trong kich_ban).
static func _group_of(path: String) -> String:
	var id: String = path.trim_prefix(ROOT + "/")
	return id.get_slice("/", 0) if id.contains("/") else ""


## Một kịch bản thành chữ: tên, mô tả, hành động, hai bàn cạnh nhau, ghi chú máu và địa hình bị che.
static func render(scenario: ScenarioData, stats: Stats) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("━━━ %s  [%s]" % [scenario.id, "đã duyệt" if scenario.approved else "chưa duyệt"])
	lines.append(scenario.description)
	lines.append("")
	if scenario.steps.is_empty():
		lines.append("Hành động: (không có)")
	else:
		lines.append("Hành động:")
		for i: int in range(scenario.steps.size()):
			lines.append("  %d. %s" % [i + 1, _step_text(scenario.steps[i])])
	lines.append("")

	var size: Vector2i = scenario.before.size
	var before_units: Dictionary = {}  # ô -> [type, hp]
	for p: LevelData.UnitPlacement in scenario.before.units:
		before_units[p.cell] = [p.type, p.hp if p.hp > 0 else stats.max_hp(p.type)]
	var after_units: Dictionary = {}
	for u: ScenarioData.ExpectedUnit in scenario.after_units:
		after_units[u.cell] = [u.type, u.hp]
	var left: PackedStringArray = _board(size, scenario.before.terrain, before_units, stats, "TRƯỚC")
	var right: PackedStringArray = _board(size, scenario.after_terrain, after_units, stats, "SAU")
	for i: int in range(maxi(left.size(), right.size())):
		var l: String = left[i] if i < left.size() else ""
		var r: String = right[i] if i < right.size() else ""
		lines.append((l.rpad(LEFT_WIDTH) + r).strip_edges(false, true))
	lines.append("")
	return "\n".join(lines)


## Các dòng của một bàn: tiêu đề, số cột, 7 hàng, rồi ghi chú (máu không đầy, địa hình bị quân che).
static func _board(size: Vector2i, terrain: PackedInt32Array, units: Dictionary, stats: Stats,
		title: String) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("      " + title)
	var header: PackedStringArray = PackedStringArray()
	for c: int in range(size.x):
		header.append(str(c))
	lines.append("      " + " ".join(header))
	var hp_notes: PackedStringArray = PackedStringArray()
	var hidden_notes: PackedStringArray = PackedStringArray()
	for r: int in range(size.y):
		var cells: PackedStringArray = PackedStringArray()
		for c: int in range(size.x):
			var cell: Vector2i = Vector2i(c, r)
			var kind: int = terrain[r * size.x + c]
			if not units.has(cell):
				cells.append(ScenarioRunner.TERRAIN_SYMBOLS[kind] as String)
				continue
			var type: int = (units[cell] as Array)[0] as int
			var hp: int = (units[cell] as Array)[1] as int
			cells.append(ScenarioRunner.UNIT_SYMBOLS[type] as String)
			var where: String = BoardText.cell_text(cell)
			if hp < stats.max_hp(type):
				hp_notes.append("%s %s %d/%d" % [where, _unit_name(type), hp, stats.max_hp(type)])
			if HIDDEN_TERRAIN_KEYS.has(kind):
				hidden_notes.append("%s %s (%s)" % [where, ScenarioRunner.TERRAIN_SYMBOLS[kind],
					TranslationServer.translate(HIDDEN_TERRAIN_KEYS[kind] as String)])
		lines.append("   %d  %s" % [r, " ".join(cells)])
	if not hp_notes.is_empty() or not hidden_notes.is_empty():
		lines.append("")
	_append_notes(lines, "Máu:", hp_notes)
	_append_notes(lines, "Dưới quân:", hidden_notes)
	return lines


## Ghi chú đầu tiên đi cùng nhãn, các ghi chú sau thụt vào cho thẳng cột.
static func _append_notes(lines: PackedStringArray, label: String, notes: PackedStringArray) -> void:
	for i: int in range(notes.size()):
		var prefix: String = label if i == 0 else "".rpad(label.length())
		lines.append("  %s %s" % [prefix, notes[i]])


static func _step_text(step: ScenarioData.ScenarioStep) -> String:
	match step.kind:
		"di":
			return "%s đi tới %s" % [_unit_name(step.general), BoardText.cell_text(step.cell)]
		"danh":
			return "%s đánh ô %s" % [_unit_name(step.general), BoardText.cell_text(step.cell)]
		"huy":
			return "Hủy nước đi gần nhất"
		"ket_thuc_luot":
			return "Kết thúc lượt (chạy pha địch)"
	return step.kind


static func _unit_name(type: int) -> String:
	return TranslationServer.translate(UNIT_NAME_KEYS[type] as String)
