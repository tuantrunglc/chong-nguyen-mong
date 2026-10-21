class_name ScenarioLoader
extends RefCounted
## Nạp kịch bản luật (tests/kich_ban/<nhóm>/*.json) thành ScenarioData. Gom mọi lỗi rồi mới trả;
## không ghi log (bên gọi ghi). Định dạng và câu lỗi: Story 1.3, mục "Định dạng kịch bản".
## Thứ tự lỗi: file/JSON -> phien_ban, mo_ta, da_duyet -> truoc -> hanh_dong -> sau.
## Cỡ bàn suy ra từ truoc.dia_hinh (như file trận); các lớp khác phải cùng cỡ (Story 1.9).

## Lớp quyết cỡ bàn, in trong câu lỗi của các lớp khác cỡ.
const SIZE_LAYER: String = "truoc.dia_hinh"

const FORMAT_VERSION: int = 1

const ROOT_KEYS: Array[String] = ["phien_ban_dinh_dang", "mo_ta", "da_duyet", "truoc", "hanh_dong", "sau"]
## "bao_don" của "truoc": đòn quân Nguyên đã báo sẵn khi kịch bản bắt đầu (Story 2.8), không bắt buộc.
const BEFORE_KEYS: Array[String] = ["dia_hinh", "quan", "mau", "thu_tu_dich", "bao_don"]
## "hiep", "da_di", "da_danh", "ket_qua", "bao_don", "o_do" không bắt buộc: không ghi thì không kiểm (review Story 1.5,
## tác giả chốt 2026-10-18; "ket_qua": Story 2.5; "bao_don": Story 2.6; "o_do": Story 2.7).
const AFTER_KEYS: Array[String] = ["dia_hinh", "quan", "mau", "hiep", "da_di", "da_danh", "ket_qua", "bao_don",
	"o_do"]
## Khóa của một mục "bao_don": "o" (đòn vào ô) hoặc "huong" (xung phong), đúng một trong hai.
const TELEGRAPH_KEYS: Array[String] = ["thu_tu", "quan", "o", "huong"]
const DIRECTION_LIST: String = '"B", "D", "N", "T"'
## Giá trị của "sau.ket_qua": đang chơi, thắng, thua (khớp BattleState.Phase PLAYER, WON, LOST).
const OUTCOMES: Array[String] = ["dang_choi", "thang", "thua"]
const OUTCOME_LIST: String = '"dang_choi", "thang", "thua"'

## Lệnh -> khóa thêm. Lệnh mới thêm ở story của nó, kèm câu lỗi. "tu_choi" không bắt buộc.
const COMMANDS: Dictionary = {
	"di": ["tuong", "o", "tu_choi"],
	"danh": ["tuong", "o", "tu_choi"],
	"huy": ["tu_choi"],
	"ket_thuc_luot": [],
}
const COMMAND_LIST: String = '"di", "danh", "huy", "ket_thuc_luot"'
## Mã lý do luật từ chối lệnh (khóa "tu_choi") -> câu cho công cụ duyệt. Lý do mới thêm ở story của nó.
const REJECT_CODES: Dictionary = {
	"khong_co_quan": "scenario.viewer.reject_no_unit",
	"khong_phai_tuong": "scenario.viewer.reject_not_general",
	"da_dung_o_do": "scenario.viewer.reject_already_there",
	"khong_toi_duoc": "scenario.viewer.reject_unreachable",
	"da_di_roi": "scenario.viewer.reject_already_moved",
	"khong_con_nuoc_di": "scenario.viewer.reject_nothing_to_undo",
	"da_danh_roi": "scenario.viewer.reject_already_attacked",
	"khong_ke": "scenario.viewer.reject_not_adjacent",
	"khong_co_dich": "scenario.viewer.reject_no_target",
	"ngoai_tam": "scenario.viewer.reject_not_in_range",
	"tran_da_het": "scenario.viewer.reject_battle_over",
}
const REJECT_LIST: String = '"khong_co_quan", "khong_phai_tuong", "da_dung_o_do", "khong_toi_duoc", ' \
	+ '"da_di_roi", "khong_con_nuoc_di", "da_danh_roi", "khong_ke", "khong_co_dich", "ngoai_tam", "tran_da_het"'
## Lệnh -> các mã "tu_choi" luật của lệnh đó trả được. Lệnh mới thêm ở story của nó.
const COMMAND_REJECTS: Dictionary = {
	"di": ["khong_co_quan", "khong_phai_tuong", "da_danh_roi", "da_di_roi", "da_dung_o_do", "khong_toi_duoc",
		"tran_da_het"],
	"danh": ["khong_co_quan", "khong_phai_tuong", "da_danh_roi", "khong_ke", "khong_co_dich", "ngoai_tam",
		"tran_da_het"],
	"huy": ["khong_con_nuoc_di", "tran_da_het"],
}


## Một phần "truoc" hoặc "sau" đã đọc (chỉ dùng trong bộ nạp).
class Section:
	extends RefCounted

	## Cỡ bàn (của truoc.dia_hinh); NO_SIZE nếu không đọc được.
	var size: Vector2i = BoardLayers.NO_SIZE
	var terrain_rows: Array = []
	var unit_rows: Array = []
	var units_clean: bool = false
	## { ký hiệu tướng: ô }
	var generals: Dictionary = {}
	## ô -> máu ghi trong "mau"
	var hp: Dictionary = {}
	## Array[Vector2i] thứ tự quân Nguyên (chỉ "truoc"), hoặc null nếu không đọc được.
	var order: Variant = null
	## "hiep" (chỉ "sau"); 0 là không ghi.
	var round_number: int = 0
	## "da_di" (chỉ "sau"): UnitType các tướng đã đi, theo thứ tự ký hiệu; null là không ghi.
	var moved: Variant = null
	## "da_danh" (chỉ "sau"): như moved, các tướng đã đánh.
	var attacked: Variant = null
	## "ket_qua" (chỉ "sau"): một giá trị của OUTCOMES; "" là không ghi.
	var outcome: String = ""
	## "bao_don" (chỉ "sau"): Array[ScenarioData.ExpectedTelegraph] theo số thứ tự; null là không ghi hoặc sai.
	var telegraphs: Variant = null
	## "o_do" (chỉ "sau"): ô -> Array[int] số thứ tự tăng dần; null là không ghi hoặc sai.
	var marks: Variant = null


## Mọi file .json trong root_dir và thư mục con, sắp theo đường dẫn. Thư mục không có thì [].
static func list_files(root_dir: String) -> Array[String]:
	var files: Array[String] = []
	_collect(root_dir, files)
	files.sort()
	return files


static func _collect(dir_path: String, files: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for name: String in dir.get_files():
		if name.get_extension() == "json":
			files.append(dir_path.path_join(name))
	for name: String in dir.get_directories():
		_collect(dir_path.path_join(name), files)


static func load_scenario(path: String, root_dir: String, stats: Stats) -> LoadResult:
	var text: String = JsonFile.read_text(path)
	if text.is_empty():
		if not FileAccess.file_exists(path):
			return JsonFile.missing_file(path)
		var empty: LoadResult = LoadResult.new()
		empty.add_error("%s: file rỗng" % JsonFile.label(path))
		return empty
	return parse_scenario(text, path, root_dir, stats)


static func parse_scenario(text: String, path: String, root_dir: String, stats: Stats) -> LoadResult:
	var file: String = JsonFile.label(path)
	var result: LoadResult = LoadResult.new()
	var root: Dictionary = JsonFile.parse_object(text, file, result)
	if not result.ok:
		return result
	_warn_unknown(root, ROOT_KEYS, "", file, result)

	_check_version(root, file, result)
	var description: String = _read_description(root, file, result)
	var approved: bool = _read_approved(root, file, result)

	var before: Section = null
	var before_section: Variant = _read_section(root, "truoc", file, result)
	if before_section != null:
		before = _read_side(before_section as Dictionary, "truoc", BEFORE_KEYS, stats, BoardLayers.NO_SIZE, file, result)
	var size: Vector2i = before.size if before != null else BoardLayers.NO_SIZE
	var steps: Array[ScenarioData.ScenarioStep] = _read_steps(root, before, size, file, result)
	var after: Section = null
	var after_section: Variant = _read_section(root, "sau", file, result)
	if after_section != null:
		after = _read_side(after_section as Dictionary, "sau", AFTER_KEYS, stats, size, file, result)

	if not result.ok:
		return result
	var scenario: ScenarioData = ScenarioData.new()
	scenario.path = path
	scenario.id = path.trim_prefix(root_dir + "/")
	scenario.group = scenario.id.get_slice("/", 0) if scenario.id.contains("/") else ""
	scenario.description = description
	scenario.approved = approved
	scenario.before = _build_level(before, scenario.id)
	if before.telegraphs != null:
		scenario.before_telegraphs = before.telegraphs as Array[ScenarioData.ExpectedTelegraph]
	scenario.steps = steps
	scenario.after_terrain = BoardLayers.terrain_values(after.terrain_rows)
	scenario.after_round = after.round_number
	if after.moved != null:
		scenario.checks_moved = true
		scenario.after_moved = after.moved as Array[int]
	if after.attacked != null:
		scenario.checks_attacked = true
		scenario.after_attacked = after.attacked as Array[int]
	scenario.after_outcome = after.outcome
	if after.telegraphs != null:
		scenario.checks_telegraphs = true
		scenario.after_telegraphs = after.telegraphs as Array[ScenarioData.ExpectedTelegraph]
	if after.marks != null:
		scenario.checks_marks = true
		scenario.after_marks = after.marks as Dictionary
	for cell: Vector2i in BoardLayers.reading_order(after.unit_rows, _unit_symbols()):
		var type: int = BoardText.UNIT_SYMBOLS[BoardLayers.symbol(after.unit_rows, cell)] as int
		var hp: int = after.hp[cell] as int if after.hp.has(cell) else stats.max_hp(type)
		scenario.after_units.append(ScenarioData.ExpectedUnit.new(type, cell, hp))
	result.data = scenario
	return result


## Khóa lạ là cảnh báo. prefix "" ở gốc, "truoc." trong một phần.
static func _warn_unknown(d: Dictionary, known: Array[String], prefix: String,
		file: String, result: LoadResult) -> void:
	for key: Variant in d.keys():
		if not known.has(key):
			result.add_warning("%s: bỏ qua khóa lạ %s" % [file, JsonFile.show(prefix + str(key))])


## Như file trận: số nguyên nào khác 1 (kể cả 0 và số âm) là sai phiên bản.
static func _check_version(root: Dictionary, file: String, result: LoadResult) -> void:
	if root.has("phien_ban_dinh_dang") and JsonFile.is_whole(root["phien_ban_dinh_dang"]):
		var version: int = int(root["phien_ban_dinh_dang"])
		if version != FORMAT_VERSION:
			result.add_error('%s: "phien_ban_dinh_dang" là %d, game chỉ đọc được bản %d'
				% [file, version, FORMAT_VERSION])
	else:
		JsonFile.get_int(root, "phien_ban_dinh_dang", "phien_ban_dinh_dang", 1, file, result)


static func _read_description(root: Dictionary, file: String, result: LoadResult) -> String:
	if not root.has("mo_ta"):
		result.add_error('%s: thiếu khóa "mo_ta"' % file)
		return ""
	if not root["mo_ta"] is String:
		result.add_error(JsonFile.type_error(file, "mo_ta", "một chuỗi", root["mo_ta"]))
		return ""
	var text: String = (root["mo_ta"] as String).strip_edges()
	if text.is_empty():
		result.add_error('%s: "mo_ta" không được để trống' % file)
	return text


static func _read_approved(root: Dictionary, file: String, result: LoadResult) -> bool:
	if not root.has("da_duyet"):
		result.add_error('%s: thiếu khóa "da_duyet"' % file)
		return false
	if not root["da_duyet"] is bool:
		result.add_error(JsonFile.type_error(file, "da_duyet", "true hoặc false", root["da_duyet"]))
		return false
	return root["da_duyet"] as bool


## Trả Dictionary của phần "truoc"/"sau", hoặc null nếu thiếu hay sai kiểu.
static func _read_section(root: Dictionary, key: String, file: String, result: LoadResult) -> Variant:
	if not root.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, key])
		return null
	if not root[key] is Dictionary:
		result.add_error(JsonFile.type_error(file, key, "một object", root[key]))
		return null
	return root[key]


## size: cỡ bàn đã biết (phần "sau"), hoặc NO_SIZE cho phần "truoc" (dia_hinh của nó quyết cỡ).
static func _read_side(section: Dictionary, name: String, known: Array[String], stats: Stats, size: Vector2i,
		file: String, result: LoadResult) -> Section:
	var side: Section = Section.new()
	_warn_unknown(section, known, name + ".", file, result)
	var terrain_shown: String = name + ".dia_hinh"
	var decides_size: bool = name == "truoc"
	side.terrain_rows = BoardLayers.read_layer(section, "dia_hinh", terrain_shown, BoardText.TERRAIN_SYMBOLS,
		file, result, size, "" if decides_size else SIZE_LAYER)
	side.size = BoardLayers.layer_size(side.terrain_rows) if decides_size else size
	var errors_before_units: int = result.errors.size()
	side.unit_rows = BoardLayers.read_layer(section, "quan", name + ".quan", BoardText.UNIT_SYMBOLS, file, result,
		side.size, SIZE_LAYER)
	side.units_clean = result.errors.size() == errors_before_units and not side.unit_rows.is_empty()
	side.generals = BoardLayers.check_unit_cells(side.terrain_rows, side.unit_rows, name + ".quan", file, result)
	if name == "truoc" and side.units_clean \
			and BoardLayers.reading_order(side.unit_rows, _unit_symbols()).is_empty():
		result.add_error('%s: "truoc.quan" không có quân nào' % file)
	if known.has("thu_tu_dich"):
		if section.has("thu_tu_dich"):
			side.order = BoardLayers.read_enemy_order(section, "thu_tu_dich", name + ".thu_tu_dich",
				side.unit_rows, side.units_clean, side.size, file, result)
		elif side.units_clean:
			side.order = BoardLayers.reading_order(side.unit_rows, BoardLayers.ENEMY_SYMBOLS)
	if section.has("mau"):
		_read_hp(section["mau"], name + ".mau", side, stats, file, result)
	if known.has("hiep") and section.has("hiep"):
		var round_value: Variant = JsonFile.get_int(section, "hiep", name + ".hiep", 1, file, result)
		if round_value != null:
			side.round_number = round_value as int
	if known.has("da_di") and section.has("da_di"):
		side.moved = _read_generals(section["da_di"], name + ".da_di", name + ".quan", side, file, result)
	if known.has("da_danh") and section.has("da_danh"):
		side.attacked = _read_generals(section["da_danh"], name + ".da_danh", name + ".quan", side, file, result)
	if known.has("ket_qua") and section.has("ket_qua"):
		var outcome: Variant = section["ket_qua"]
		if not outcome is String or not OUTCOMES.has(outcome):
			result.add_error('%s: "%s.ket_qua" là %s, chỉ được %s' % [file, name, JsonFile.show(outcome), OUTCOME_LIST])
		else:
			side.outcome = outcome as String
	if known.has("bao_don") and section.has("bao_don"):
		side.telegraphs = _read_telegraphs(section["bao_don"], name + ".bao_don", name + ".quan", side, file, result)
		if name == "truoc" and side.telegraphs != null:
			_check_orders_from_one(side.telegraphs as Array[ScenarioData.ExpectedTelegraph], name + ".bao_don",
				file, result)
	if known.has("o_do") and section.has("o_do"):
		side.marks = _read_marks(section["o_do"], name + ".o_do", side, file, result)
	return side


## Đòn dựng sẵn ("truoc.bao_don") phải đánh số liền từ 1, như BattleState.validate đòi. telegraphs đã xếp tăng dần.
static func _check_orders_from_one(telegraphs: Array[ScenarioData.ExpectedTelegraph], shown: String,
		file: String, result: LoadResult) -> void:
	var orders: Array[int] = []
	for t: ScenarioData.ExpectedTelegraph in telegraphs:
		orders.append(t.order)
	for i: int in range(orders.size()):
		if orders[i] != i + 1:
			result.add_error('%s: "%s" phải đánh số thứ tự liền từ 1 (1, 2, 3…), đang là %s'
				% [file, shown, JsonFile.show(orders)])
			return


## "da_di": ["1", "2"] là các tướng đã đi trong lượt; [] là chưa tướng nào đi ("da_danh" cũng vậy). Trả Array[int]
## UnitType theo thứ tự ký hiệu, hoặc null nếu sai (đã thêm lỗi).
static func _read_generals(value: Variant, shown: String, units_shown: String, side: Section,
		file: String, result: LoadResult) -> Variant:
	if not value is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", value))
		return null
	var errors_before: int = result.errors.size()
	var seen: Array[String] = []
	for item: Variant in value as Array:
		if not item is String or not BoardLayers.GENERAL_SYMBOLS.has(item):
			result.add_error('%s: "%s" có %s, chỉ được "1", "2", "3"' % [file, shown, JsonFile.show(item)])
			continue
		if seen.has(item):
			result.add_error('%s: "%s" ghi tướng "%s" hai lần' % [file, shown, item])
			continue
		seen.append(item as String)
		# Lớp quân đã sai thì không kiểm chéo (đã có lỗi riêng).
		if side.units_clean and not side.generals.has(item):
			result.add_error('%s: "%s" có tướng "%s" không có trong "%s"' % [file, shown, item, units_shown])
	if result.errors.size() != errors_before:
		return null
	var moved: Array[int] = []
	for symbol: String in BoardLayers.GENERAL_SYMBOLS:
		if seen.has(symbol):
			moved.append(BoardText.UNIT_SYMBOLS[symbol] as int)
	return moved


## "bao_don": [{"thu_tu": 1, "quan": "3,3", "o": "3,4"}, {"thu_tu": 2, "quan": "0,3", "huong": "D"}]: các đòn quân
## Nguyên đã báo. [] là không quân nào báo đòn. Trả Array[ExpectedTelegraph] theo số thứ tự, hoặc null nếu sai.
static func _read_telegraphs(value: Variant, shown: String, units_shown: String, side: Section,
		file: String, result: LoadResult) -> Variant:
	if not value is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", value))
		return null
	var errors_before: int = result.errors.size()
	var telegraphs: Array[ScenarioData.ExpectedTelegraph] = []
	var seen_orders: Dictionary = {}  # thu_tu -> mục đầu tiên ghi số đó
	var seen_owners: Dictionary = {}  # ô "quan" -> mục đầu tiên ghi ô đó
	var items: Array = value as Array
	for i: int in range(items.size()):
		var where: String = '%s: "%s" mục %d' % [file, shown, i + 1]
		if not items[i] is Dictionary:
			result.add_error("%s phải là một object, đang là %s" % [where, JsonFile.show(items[i])])
			continue
		var d: Dictionary = items[i] as Dictionary
		for key: Variant in d.keys():
			if not TELEGRAPH_KEYS.has(key):
				result.add_warning("%s: bỏ qua khóa lạ %s" % [where, JsonFile.show(key)])
		var item_errors: int = result.errors.size()
		var order: int = 0
		if not d.has("thu_tu"):
			result.add_error('%s: thiếu khóa "thu_tu"' % where)
		elif not JsonFile.is_whole(d["thu_tu"]) or int(d["thu_tu"]) < 1:
			result.add_error('%s: "thu_tu" phải là số nguyên từ 1 trở lên, đang là %s'
				% [where, JsonFile.show(d["thu_tu"])])
		else:
			order = int(d["thu_tu"])
			if seen_orders.has(order):
				result.add_error('%s: "thu_tu" %d trùng với mục %d' % [where, order, seen_orders[order]])
			else:
				seen_orders[order] = i + 1
		var owner: Variant = _read_telegraph_cell(d, "quan", where, side.size, result)
		if owner != null and side.units_clean \
				and not BoardLayers.ENEMY_SYMBOLS.has(BoardLayers.symbol(side.unit_rows, owner as Vector2i)):
			result.add_error('%s: "quan" ô %s không có quân Nguyên trong "%s"'
				% [where, BoardText.cell_text(owner as Vector2i), units_shown])
		if owner != null:
			if seen_owners.has(owner):
				result.add_error('%s: "quan" ô %s trùng với mục %d (mỗi quân chỉ báo một đòn)'
					% [where, BoardText.cell_text(owner as Vector2i), seen_owners[owner]])
			else:
				seen_owners[owner] = i + 1
		var kind: Telegraph.Kind = Telegraph.Kind.CELL
		var target: Variant = null
		if d.has("o") == d.has("huong"):
			result.add_error('%s: phải có đúng một trong "o" (đòn vào ô) và "huong" (xung phong)' % where)
		elif d.has("o"):
			target = _read_telegraph_cell(d, "o", where, side.size, result)
			if owner != null and target != null and not Grid.is_adjacent(owner as Vector2i, target as Vector2i):
				result.add_error('%s: "o" ô %s không kề "quan" ô %s'
					% [where, BoardText.cell_text(target as Vector2i), BoardText.cell_text(owner as Vector2i)])
		else:
			kind = Telegraph.Kind.DIRECTION
			var code: Variant = d["huong"]
			if not code is String or not BoardText.DIRECTION_CODES.has(code):
				result.add_error('%s: "huong" là %s, chỉ được %s' % [where, JsonFile.show(code), DIRECTION_LIST])
			else:
				target = BoardText.DIRECTION_CODES[code]
		if result.errors.size() == item_errors:
			telegraphs.append(ScenarioData.ExpectedTelegraph.new(order, owner as Vector2i, kind, target as Vector2i))
	if result.errors.size() != errors_before:
		return null
	telegraphs.sort_custom(func(a: ScenarioData.ExpectedTelegraph, b: ScenarioData.ExpectedTelegraph) -> bool:
		return a.order < b.order)
	return telegraphs


## Ô "cot,hang" trong bàn của một mục "bao_don", hoặc null nếu thiếu hay sai (đã thêm lỗi).
static func _read_telegraph_cell(d: Dictionary, key: String, where: String, size: Vector2i,
		result: LoadResult) -> Variant:
	if not d.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [where, key])
		return null
	var value: Variant = d[key]
	var parsed: Variant = BoardText.parse_cell(value as String) if value is String else null
	if parsed == null or (size != BoardLayers.NO_SIZE and not Rect2i(Vector2i.ZERO, size).has_point(parsed as Vector2i)):
		result.add_error('%s: "%s" là %s, không phải ô trong bàn' % [where, key, JsonFile.show(value)])
		return null
	return parsed


## "o_do": { "cot,hang": [số thứ tự, …] }: mọi ô đỏ và các đòn phủ ô đó; {} là không ô nào đỏ. Trả ô -> Array[int]
## tăng dần, hoặc null nếu sai (đã thêm lỗi).
static func _read_marks(value: Variant, shown: String, side: Section, file: String, result: LoadResult) -> Variant:
	if not value is Dictionary:
		result.add_error(JsonFile.type_error(file, shown, "một object", value))
		return null
	var errors_before: int = result.errors.size()
	var board: Rect2i = Rect2i(Vector2i.ZERO, side.size)
	var marks: Dictionary = {}
	var seen: Dictionary = {}  # ô -> khóa đầu tiên trỏ tới ô đó
	var map: Dictionary = value as Dictionary
	for key: Variant in map.keys():
		var parsed: Variant = BoardText.parse_cell(key as String) if key is String else null
		if parsed == null:
			result.add_error('%s: "%s" có khóa %s không phải tọa độ "cot,hang"' % [file, shown, JsonFile.show(key)])
			continue
		var cell: Vector2i = parsed as Vector2i
		var cell_shown: String = BoardText.cell_text(cell)
		if seen.has(cell):
			result.add_error('%s: "%s" ghi ô %s hai lần (%s và %s)'
				% [file, shown, cell_shown, JsonFile.show(seen[cell]), JsonFile.show(key)])
			continue
		seen[cell] = key
		if side.size != BoardLayers.NO_SIZE and not board.has_point(cell):
			result.add_error('%s: "%s" ô %s nằm ngoài bàn' % [file, shown, cell_shown])
			continue
		var orders: Variant = _read_orders(map[key])
		if orders == null:
			result.add_error('%s: "%s" ô %s phải là danh sách số thứ tự (số nguyên từ 1, không trùng), đang là %s'
				% [file, shown, cell_shown, JsonFile.show(map[key])])
			continue
		marks[cell] = orders
	if result.errors.size() != errors_before:
		return null
	return marks


## Danh sách số nguyên ≥ 1, không rỗng, không trùng -> Array[int] tăng dần; sai thì null.
static func _read_orders(value: Variant) -> Variant:
	if not value is Array or (value as Array).is_empty():
		return null
	var orders: Array[int] = []
	for item: Variant in value as Array:
		if not JsonFile.is_whole(item) or int(item) < 1 or orders.has(int(item)):
			return null
		orders.append(int(item))
	orders.sort()
	return orders


## "mau": { "cot,hang": máu } cho quân không đầy máu.
static func _read_hp(value: Variant, shown: String, side: Section, stats: Stats,
		file: String, result: LoadResult) -> void:
	if not value is Dictionary:
		result.add_error(JsonFile.type_error(file, shown, "một object", value))
		return
	var hp_map: Dictionary = value as Dictionary
	var board: Rect2i = Rect2i(Vector2i.ZERO, side.size)
	var seen: Dictionary = {}  # ô -> khóa đầu tiên trỏ tới ô đó ("0,6" và "00,6" là một ô)
	for key: Variant in hp_map.keys():
		var parsed: Variant = BoardText.parse_cell(key as String) if key is String else null
		if parsed == null:
			result.add_error('%s: "%s" có khóa %s không phải tọa độ "cot,hang"'
				% [file, shown, JsonFile.show(key)])
			continue
		var cell: Vector2i = parsed as Vector2i
		var cell_shown: String = BoardText.cell_text(cell)
		if seen.has(cell):
			result.add_error('%s: "%s" ghi ô %s hai lần (%s và %s)'
				% [file, shown, cell_shown, JsonFile.show(seen[cell]), JsonFile.show(key)])
			continue
		seen[cell] = key
		if side.size != BoardLayers.NO_SIZE and not board.has_point(cell):
			result.add_error('%s: "%s" ô %s nằm ngoài bàn' % [file, shown, cell_shown])
			continue
		var unit: String = BoardLayers.symbol(side.unit_rows, cell)
		if unit == "":
			continue  # ô hoặc dòng của lớp quân đã sai, đã có lỗi riêng
		if unit == ".":
			result.add_error('%s: "%s" ô %s không có quân' % [file, shown, cell_shown])
			continue
		var max_hp: int = stats.max_hp(BoardText.UNIT_SYMBOLS[unit] as int)
		var hp: Variant = hp_map[key]
		if not JsonFile.is_whole(hp) or int(hp) < 1 or int(hp) > max_hp:
			result.add_error('%s: "%s" ô %s: máu phải là số nguyên từ 1 tới %d, đang là %s'
				% [file, shown, cell_shown, max_hp, JsonFile.show(hp)])
			continue
		side.hp[cell] = int(hp)


static func _read_steps(root: Dictionary, before: Section, size: Vector2i, file: String,
		result: LoadResult) -> Array[ScenarioData.ScenarioStep]:
	var steps: Array[ScenarioData.ScenarioStep] = []
	if not root.has("hanh_dong"):
		result.add_error('%s: thiếu khóa "hanh_dong"' % file)
		return steps
	if not root["hanh_dong"] is Array:
		result.add_error(JsonFile.type_error(file, "hanh_dong", "một danh sách", root["hanh_dong"]))
		return steps
	var items: Array = root["hanh_dong"] as Array
	for i: int in range(items.size()):
		var step: Variant = _read_step(items[i], i + 1, before, size, file, result)
		if step != null:
			steps.append(step as ScenarioData.ScenarioStep)
	return steps


## Trả ScenarioStep, hoặc null nếu lệnh sai.
static func _read_step(item: Variant, number: int, before: Section, size: Vector2i, file: String,
		result: LoadResult) -> Variant:
	var where: String = '%s: "hanh_dong" mục %d' % [file, number]
	if not item is Dictionary:
		result.add_error("%s phải là một object, đang là %s" % [where, JsonFile.show(item)])
		return null
	var d: Dictionary = item as Dictionary
	if not d.has("lenh"):
		result.add_error('%s: thiếu khóa "lenh"' % where)
		return null
	var kind: Variant = d["lenh"]
	if not kind is String or not COMMANDS.has(kind):
		result.add_error("%s: lệnh lạ %s, chỉ được %s" % [where, JsonFile.show(kind), COMMAND_LIST])
		return null
	where = "%s (%s)" % [where, kind]
	var fields: Array = COMMANDS[kind] as Array
	for key: Variant in d.keys():
		if key != "lenh" and not fields.has(key):
			result.add_warning("%s: bỏ qua khóa lạ %s" % [where, JsonFile.show(key)])
	var errors_before: int = result.errors.size()
	var general: int = -1
	var cell: Vector2i = ScenarioData.NO_CELL
	if fields.has("tuong"):
		general = _read_general(d, where, before, result)
	if fields.has("o"):
		cell = _read_step_cell(d, where, size, result)
	var reject: String = ""
	if d.has("tu_choi") and fields.has("tu_choi"):
		var value: Variant = d["tu_choi"]
		if not value is String or not REJECT_CODES.has(value):
			result.add_error('%s: "tu_choi" là %s, chỉ được %s' % [where, JsonFile.show(value), REJECT_LIST])
		elif COMMAND_REJECTS.has(kind) and not (COMMAND_REJECTS[kind] as Array).has(value):
			var allowed: PackedStringArray = PackedStringArray()
			for code: String in COMMAND_REJECTS[kind] as Array:
				allowed.append('"%s"' % code)
			result.add_error('%s: "tu_choi" là %s, lệnh "%s" chỉ bị từ chối vì %s'
				% [where, JsonFile.show(value), kind, ", ".join(allowed)])
		else:
			reject = value as String
	if result.errors.size() != errors_before:
		return null
	return ScenarioData.ScenarioStep.new(kind as String, general, cell, reject)


## Trả UnitType của tướng, hoặc -1 nếu sai (đã thêm lỗi).
static func _read_general(d: Dictionary, where: String, before: Section, result: LoadResult) -> int:
	if not d.has("tuong"):
		result.add_error('%s: thiếu khóa "tuong"' % where)
		return -1
	var value: Variant = d["tuong"]
	if not value is String or not BoardLayers.GENERAL_SYMBOLS.has(value):
		result.add_error('%s: "tuong" là %s, chỉ được "1", "2", "3"' % [where, JsonFile.show(value)])
		return -1
	# Lớp quân của "truoc" đã sai thì không kiểm chéo (đã có lỗi riêng).
	if before != null and before.units_clean and not before.generals.has(value):
		result.add_error('%s: tướng "%s" không có trong "truoc.quan"' % [where, value])
		return -1
	return BoardText.UNIT_SYMBOLS[value] as int


## size NO_SIZE (bàn trước không đọc được): chỉ kiểm "o" là tọa độ, không kiểm ngoài bàn.
static func _read_step_cell(d: Dictionary, where: String, size: Vector2i, result: LoadResult) -> Vector2i:
	if not d.has("o"):
		result.add_error('%s: thiếu khóa "o"' % where)
		return ScenarioData.NO_CELL
	var value: Variant = d["o"]
	var parsed: Variant = BoardText.parse_cell(value as String) if value is String else null
	var outside: bool = parsed != null and size != BoardLayers.NO_SIZE \
		and not Rect2i(Vector2i.ZERO, size).has_point(parsed as Vector2i)
	if parsed == null or outside:
		result.add_error('%s: "o" là %s, không phải ô trong bàn' % [where, JsonFile.show(value)])
		return ScenarioData.NO_CELL
	return parsed as Vector2i


## Bàn trước thành LevelData: tướng theo ký hiệu 1, 2, 3, rồi quân Nguyên theo thứ tự (như file trận).
static func _build_level(side: Section, name: String) -> LevelData:
	var level: LevelData = LevelData.new()
	level.format_version = FORMAT_VERSION
	level.name = name
	level.mission = LevelData.Mission.ELIMINATE
	level.size = side.size
	level.terrain = BoardLayers.terrain_values(side.terrain_rows)
	for symbol: String in BoardLayers.GENERAL_SYMBOLS:
		if side.generals.has(symbol):
			var cell: Vector2i = side.generals[symbol] as Vector2i
			level.units.append(LevelData.UnitPlacement.new(BoardText.UNIT_SYMBOLS[symbol] as int, cell,
				side.hp.get(cell, 0) as int))
	for cell: Vector2i in side.order as Array[Vector2i]:
		var symbol: String = BoardLayers.symbol(side.unit_rows, cell)
		level.units.append(LevelData.UnitPlacement.new(BoardText.UNIT_SYMBOLS[symbol] as int, cell,
			side.hp.get(cell, 0) as int))
	return level


static func _unit_symbols() -> Array[String]:
	var symbols: Array[String] = []
	symbols.append_array(BoardLayers.GENERAL_SYMBOLS)
	symbols.append_array(BoardLayers.ENEMY_SYMBOLS)
	return symbols
