class_name ScenarioLoader
extends RefCounted
## Nạp kịch bản luật (tests/kich_ban/<nhóm>/*.json) thành ScenarioData. Gom mọi lỗi rồi mới trả;
## không ghi log (bên gọi ghi). Định dạng và câu lỗi: Story 1.3, mục "Định dạng kịch bản".
## Thứ tự lỗi: file/JSON -> phien_ban, mo_ta, da_duyet -> truoc -> hanh_dong -> sau.

const FORMAT_VERSION: int = 1

const ROOT_KEYS: Array[String] = ["phien_ban_dinh_dang", "mo_ta", "da_duyet", "truoc", "hanh_dong", "sau"]
const BEFORE_KEYS: Array[String] = ["dia_hinh", "quan", "mau", "thu_tu_dich"]
const AFTER_KEYS: Array[String] = ["dia_hinh", "quan", "mau"]

## Lệnh -> khóa thêm. Lệnh mới thêm ở story của nó, kèm câu lỗi.
const COMMANDS: Dictionary = {
	"di": ["tuong", "o"],
	"danh": ["tuong", "o"],
	"huy": [],
	"ket_thuc_luot": [],
}
const COMMAND_LIST: String = '"di", "danh", "huy", "ket_thuc_luot"'


## Một phần "truoc" hoặc "sau" đã đọc (chỉ dùng trong bộ nạp).
class Section:
	extends RefCounted

	var terrain_rows: Array = []
	var unit_rows: Array = []
	var units_clean: bool = false
	## { ký hiệu tướng: ô }
	var generals: Dictionary = {}
	## ô -> máu ghi trong "mau"
	var hp: Dictionary = {}
	## Array[Vector2i] thứ tự quân Nguyên (chỉ "truoc"), hoặc null nếu không đọc được.
	var order: Variant = null


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
		before = _read_side(before_section as Dictionary, "truoc", BEFORE_KEYS, stats, file, result)
	var steps: Array[ScenarioData.ScenarioStep] = _read_steps(root, before, file, result)
	var after: Section = null
	var after_section: Variant = _read_section(root, "sau", file, result)
	if after_section != null:
		after = _read_side(after_section as Dictionary, "sau", AFTER_KEYS, stats, file, result)

	if not result.ok:
		return result
	var scenario: ScenarioData = ScenarioData.new()
	scenario.path = path
	scenario.id = path.trim_prefix(root_dir + "/")
	scenario.group = scenario.id.get_slice("/", 0) if scenario.id.contains("/") else ""
	scenario.description = description
	scenario.approved = approved
	scenario.before = _build_level(before, scenario.id)
	scenario.steps = steps
	scenario.after_terrain = BoardLayers.terrain_values(after.terrain_rows)
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


static func _read_side(section: Dictionary, name: String, known: Array[String], stats: Stats,
		file: String, result: LoadResult) -> Section:
	var side: Section = Section.new()
	_warn_unknown(section, known, name + ".", file, result)
	side.terrain_rows = BoardLayers.read_layer(section, "dia_hinh", name + ".dia_hinh",
		BoardText.TERRAIN_SYMBOLS, file, result)
	var errors_before_units: int = result.errors.size()
	side.unit_rows = BoardLayers.read_layer(section, "quan", name + ".quan", BoardText.UNIT_SYMBOLS, file, result)
	side.units_clean = result.errors.size() == errors_before_units and not side.unit_rows.is_empty()
	side.generals = BoardLayers.check_unit_cells(side.terrain_rows, side.unit_rows, name + ".quan", file, result)
	if name == "truoc" and side.units_clean \
			and BoardLayers.reading_order(side.unit_rows, _unit_symbols()).is_empty():
		result.add_error('%s: "truoc.quan" không có quân nào' % file)
	if known.has("thu_tu_dich"):
		if section.has("thu_tu_dich"):
			side.order = BoardLayers.read_enemy_order(section, "thu_tu_dich", name + ".thu_tu_dich",
				side.unit_rows, side.units_clean, file, result)
		elif side.units_clean:
			side.order = BoardLayers.reading_order(side.unit_rows, BoardLayers.ENEMY_SYMBOLS)
	if section.has("mau"):
		_read_hp(section["mau"], name + ".mau", side, stats, file, result)
	return side


## "mau": { "cot,hang": máu } cho quân không đầy máu.
static func _read_hp(value: Variant, shown: String, side: Section, stats: Stats,
		file: String, result: LoadResult) -> void:
	if not value is Dictionary:
		result.add_error(JsonFile.type_error(file, shown, "một object", value))
		return
	var hp_map: Dictionary = value as Dictionary
	var board: Rect2i = Rect2i(Vector2i.ZERO, BoardLayers.BOARD_SIZE)
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
		if not board.has_point(cell):
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


static func _read_steps(root: Dictionary, before: Section, file: String,
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
		var step: Variant = _read_step(items[i], i + 1, before, file, result)
		if step != null:
			steps.append(step as ScenarioData.ScenarioStep)
	return steps


## Trả ScenarioStep, hoặc null nếu lệnh sai.
static func _read_step(item: Variant, number: int, before: Section, file: String, result: LoadResult) -> Variant:
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
		cell = _read_step_cell(d, where, result)
	if result.errors.size() != errors_before:
		return null
	return ScenarioData.ScenarioStep.new(kind as String, general, cell)


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


static func _read_step_cell(d: Dictionary, where: String, result: LoadResult) -> Vector2i:
	if not d.has("o"):
		result.add_error('%s: thiếu khóa "o"' % where)
		return ScenarioData.NO_CELL
	var value: Variant = d["o"]
	var parsed: Variant = BoardText.parse_cell(value as String) if value is String else null
	if parsed == null or not Rect2i(Vector2i.ZERO, BoardLayers.BOARD_SIZE).has_point(parsed as Vector2i):
		result.add_error('%s: "o" là %s, không phải ô trong bàn' % [where, JsonFile.show(value)])
		return ScenarioData.NO_CELL
	return parsed as Vector2i


## Bàn trước thành LevelData: tướng theo ký hiệu 1, 2, 3, rồi quân Nguyên theo thứ tự (như file trận).
static func _build_level(side: Section, name: String) -> LevelData:
	var level: LevelData = LevelData.new()
	level.format_version = FORMAT_VERSION
	level.name = name
	level.mission = LevelData.Mission.ELIMINATE
	level.size = BoardLayers.BOARD_SIZE
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
