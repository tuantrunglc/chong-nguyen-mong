class_name LevelLoader
extends RefCounted
## Nạp data/tran/*.json thành LevelData. Gom mọi lỗi rồi mới trả về; không ghi log (bên gọi ghi).
## Thứ tự lỗi: file/JSON -> khóa (phien_ban, ten, kieu) -> lớp dia_hinh -> lớp quan
## -> kiểm từng ô của lớp quan -> thu_tu_dich -> quân thiếu trong thu_tu_dich.

## Quy cách định dạng của prototype (không phải số cân bằng). Giai đoạn 1 mới có bàn khác cỡ.
const BOARD_SIZE: Vector2i = Vector2i(7, 7)
const FORMAT_VERSION: int = 1

const KINDS: Dictionary = {
	"tieu_diet": LevelData.Mission.ELIMINATE,
	"giu_ai": LevelData.Mission.HOLD_PASS,
}

## tiep_vien, muu_ke_mo, so_hiep_toi_da, long_dan: biết tên nhưng chưa đọc (story 3.10, 3.12, 3.5, 3.7).
const KNOWN_KEYS: Array[String] = [
	"phien_ban_dinh_dang", "ten", "kieu", "dia_hinh", "quan", "thu_tu_dich",
	"tiep_vien", "muu_ke_mo", "so_hiep_toi_da", "long_dan",
]

const GENERAL_SYMBOLS: Array[String] = ["1", "2", "3"]
const ENEMY_SYMBOLS: Array[String] = ["B", "K", "C"]


static func load_level(path: String) -> LoadResult:
	var text: String = JsonFile.read_text(path)
	if text.is_empty():
		return JsonFile.missing_file(path)
	return parse_level(text, JsonFile.label(path))


static func parse_level(text: String, file: String) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var root: Dictionary = JsonFile.parse_object(text, file, result)
	if not result.ok:
		return result

	for key: Variant in root.keys():
		if not KNOWN_KEYS.has(key):
			result.add_warning('%s: bỏ qua khóa lạ "%s"' % [file, key])

	var version: Variant = JsonFile.get_int(root, "phien_ban_dinh_dang", "phien_ban_dinh_dang", 1, file, result)
	if version != null and int(version) != FORMAT_VERSION:
		result.add_error('%s: "phien_ban_dinh_dang" là %d, game chỉ đọc được bản %d'
			% [file, version, FORMAT_VERSION])
	var level_name: String = _read_name(root, file, result)
	var mission: Variant = _read_kind(root, file, result)

	var terrain_rows: Array = _read_layer(root, "dia_hinh", BoardText.TERRAIN_SYMBOLS, file, result)
	var errors_before_units: int = result.errors.size()
	var unit_rows: Array = _read_layer(root, "quan", BoardText.UNIT_SYMBOLS, file, result)
	var units_clean: bool = result.errors.size() == errors_before_units and not unit_rows.is_empty()

	var generals: Dictionary = _check_unit_cells(terrain_rows, unit_rows, file, result)
	if units_clean and generals.is_empty():
		result.add_error('%s: "quan" không có tướng nào (cần ít nhất một trong 1, 2, 3)' % file)

	var order: Variant = _read_enemy_order(root, unit_rows, units_clean, file, result)

	if not result.ok:
		return result
	var level: LevelData = LevelData.new()
	level.format_version = int(version)
	level.name = level_name
	level.mission = mission as LevelData.Mission
	level.size = BOARD_SIZE
	level.terrain = _terrain_values(terrain_rows)
	for symbol: String in GENERAL_SYMBOLS:
		if generals.has(symbol):
			level.units.append(LevelData.UnitPlacement.new(BoardText.UNIT_SYMBOLS[symbol] as int, generals[symbol] as Vector2i))
	for cell: Vector2i in order as Array[Vector2i]:
		var symbol: String = (unit_rows[cell.y] as PackedStringArray)[cell.x]
		level.units.append(LevelData.UnitPlacement.new(BoardText.UNIT_SYMBOLS[symbol] as int, cell))
	result.data = level
	return result


static func _read_name(root: Dictionary, file: String, result: LoadResult) -> String:
	if not root.has("ten"):
		result.add_error('%s: thiếu khóa "ten"' % file)
		return ""
	if not root["ten"] is String:
		result.add_error(JsonFile.type_error(file, "ten", "một chuỗi", root["ten"]))
		return ""
	var level_name: String = (root["ten"] as String).strip_edges()
	if level_name.is_empty():
		result.add_error('%s: "ten" không được để trống' % file)
	return level_name


## Trả LevelData.Mission, hoặc null nếu sai.
static func _read_kind(root: Dictionary, file: String, result: LoadResult) -> Variant:
	if not root.has("kieu"):
		result.add_error('%s: thiếu khóa "kieu"' % file)
		return null
	var kind: Variant = root["kieu"]
	if not kind is String:
		result.add_error(JsonFile.type_error(file, "kieu", "một chuỗi", kind))
		return null
	if not KINDS.has(kind):
		result.add_error('%s: "kieu" là %s, chỉ được "tieu_diet" hoặc "giu_ai"' % [file, JsonFile.show(kind)])
		return null
	return KINDS[kind]


## Đọc một lớp bàn cờ chữ. Trả mảng BOARD_SIZE.y phần tử: mỗi phần tử là PackedStringArray
## các ký hiệu của dòng (ô có ký hiệu lạ thành ""), hoặc null nếu cả dòng không đọc được.
## Lớp thiếu, sai kiểu hoặc sai số dòng thì trả [] (không kiểm chéo với lớp khác).
static func _read_layer(root: Dictionary, layer: String, symbols: Dictionary,
		file: String, result: LoadResult) -> Array:
	if not root.has(layer):
		result.add_error('%s: thiếu khóa "%s"' % [file, layer])
		return []
	if not root[layer] is Array:
		result.add_error(JsonFile.type_error(file, layer, "một danh sách", root[layer]))
		return []
	var lines: Array = root[layer] as Array
	var rows: Array = []
	for r: int in range(lines.size()):
		var line: Variant = lines[r]
		if not line is String:
			result.add_error('%s: "%s" dòng %d phải là một chuỗi, đang là %s'
				% [file, layer, r + 1, JsonFile.show(line)])
			rows.append(null)
			continue
		var tokens: PackedStringArray = BoardText.split_row(line as String)
		if tokens.size() != BOARD_SIZE.x:
			result.add_error('%s: "%s" dòng %d: có %d ô, cần %d'
				% [file, layer, r + 1, tokens.size(), BOARD_SIZE.x])
			rows.append(null)
			continue
		for c: int in range(tokens.size()):
			if not symbols.has(tokens[c]):
				result.add_error('%s: "%s" dòng %d, cột %d (ô %d,%d): ký hiệu lạ "%s"'
					% [file, layer, r + 1, c + 1, c, r, tokens[c]])
				tokens[c] = ""
		rows.append(tokens)
	if lines.size() != BOARD_SIZE.y:
		result.add_error('%s: "%s" có %d dòng, cần %d' % [file, layer, lines.size(), BOARD_SIZE.y])
		return []
	return rows


## Ký hiệu ở ô; "" nếu ô hoặc dòng không đọc được.
static func _symbol(rows: Array, cell: Vector2i) -> String:
	if rows.is_empty() or rows[cell.y] == null:
		return ""
	return (rows[cell.y] as PackedStringArray)[cell.x]


## Kiểm từng ô của lớp quan: quân đứng trên ô chặn, tướng lặp. Trả { ký hiệu tướng: ô }.
static func _check_unit_cells(terrain_rows: Array, unit_rows: Array, file: String, result: LoadResult) -> Dictionary:
	var generals: Dictionary = {}
	if unit_rows.is_empty():
		return generals
	for r: int in range(BOARD_SIZE.y):
		for c: int in range(BOARD_SIZE.x):
			var cell: Vector2i = Vector2i(c, r)
			var unit: String = _symbol(unit_rows, cell)
			if unit == "" or unit == ".":
				continue
			var where: String = '%s: "quan" dòng %d, cột %d (ô %d,%d)' % [file, r + 1, c + 1, c, r]
			var ground: String = _symbol(terrain_rows, cell)
			if ground != "" and not Terrain.is_walkable(BoardText.TERRAIN_SYMBOLS[ground] as int):
				result.add_error('%s: quân "%s" đứng trên ô không đi vào được "%s"' % [where, unit, ground])
			if GENERAL_SYMBOLS.has(unit):
				if generals.has(unit):
					result.add_error('%s: tướng "%s" đã có ở ô %s'
						% [where, unit, BoardText.cell_text(generals[unit] as Vector2i)])
				else:
					generals[unit] = cell
	return generals


## Đọc thu_tu_dich và đối chiếu với lớp quan. Trả Array[Vector2i], hoặc null nếu thiếu/sai kiểu.
static func _read_enemy_order(root: Dictionary, unit_rows: Array, units_clean: bool,
		file: String, result: LoadResult) -> Variant:
	if not root.has("thu_tu_dich"):
		result.add_error('%s: thiếu khóa "thu_tu_dich"' % file)
		return null
	if not root["thu_tu_dich"] is Array:
		result.add_error(JsonFile.type_error(file, "thu_tu_dich", "một danh sách", root["thu_tu_dich"]))
		return null
	var items: Array = root["thu_tu_dich"] as Array
	var order: Array[Vector2i] = []
	var seen: Dictionary = {}  # ô -> số mục (đếm từ 1)
	var board: Rect2i = Rect2i(Vector2i.ZERO, BOARD_SIZE)
	for i: int in range(items.size()):
		var item: Variant = items[i]
		var where: String = '%s: "thu_tu_dich" mục %d' % [file, i + 1]
		var parsed: Variant = BoardText.parse_cell(item as String) if item is String else null
		if parsed == null:
			result.add_error('%s: %s không phải tọa độ "cot,hang"' % [where, JsonFile.show(item)])
			continue
		var cell: Vector2i = parsed as Vector2i
		var shown: String = BoardText.cell_text(cell)
		if not board.has_point(cell):
			result.add_error("%s: ô %s nằm ngoài bàn" % [where, shown])
			continue
		if seen.has(cell):
			result.add_error("%s: ô %s đã ghi ở mục %d" % [where, shown, seen[cell]])
			continue
		seen[cell] = i + 1
		var unit: String = _symbol(unit_rows, cell)
		if unit == "":
			continue
		if not ENEMY_SYMBOLS.has(unit):
			result.add_error("%s: ô %s không có quân Nguyên" % [where, shown])
			continue
		order.append(cell)

	if units_clean:
		for r: int in range(BOARD_SIZE.y):
			for c: int in range(BOARD_SIZE.x):
				var cell: Vector2i = Vector2i(c, r)
				var unit: String = _symbol(unit_rows, cell)
				if ENEMY_SYMBOLS.has(unit) and not seen.has(cell):
					result.add_error('%s: quân Nguyên "%s" ở ô %s không có trong "thu_tu_dich"'
						% [file, unit, BoardText.cell_text(cell)])
	return order


static func _terrain_values(rows: Array) -> PackedInt32Array:
	var values: PackedInt32Array = PackedInt32Array()
	for row: Variant in rows:
		for symbol: String in row as PackedStringArray:
			values.append(BoardText.TERRAIN_SYMBOLS[symbol] as int)
	return values
