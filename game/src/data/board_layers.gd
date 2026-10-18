class_name BoardLayers
extends RefCounted
## Đọc lớp bàn cờ chữ (dia_hinh, quan) và thu_tu_dich, gom lỗi vào LoadResult.
## Dùng chung cho file trận và kịch bản luật. `key` là khóa trong object, `shown` là tên in trong câu lỗi
## ("quan" với file trận, "truoc.quan" với kịch bản).

## Quy cách định dạng của prototype (không phải số cân bằng). Giai đoạn 1 mới có bàn khác cỡ.
const BOARD_SIZE: Vector2i = Vector2i(7, 7)

const GENERAL_SYMBOLS: Array[String] = ["1", "2", "3"]
const ENEMY_SYMBOLS: Array[String] = ["B", "K", "C"]


## Đọc một lớp bàn cờ chữ. Trả mảng BOARD_SIZE.y phần tử: mỗi phần tử là PackedStringArray
## các ký hiệu của dòng (ô có ký hiệu lạ thành ""), hoặc null nếu cả dòng không đọc được.
## Lớp thiếu, sai kiểu hoặc sai số dòng thì trả [] (không kiểm chéo với lớp khác).
static func read_layer(root: Dictionary, key: String, shown: String, symbols: Dictionary,
		file: String, result: LoadResult) -> Array:
	if not root.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, shown])
		return []
	if not root[key] is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", root[key]))
		return []
	var lines: Array = root[key] as Array
	var rows: Array = []
	for r: int in range(lines.size()):
		var line: Variant = lines[r]
		if not line is String:
			result.add_error('%s: "%s" dòng %d phải là một chuỗi, đang là %s'
				% [file, shown, r + 1, JsonFile.show(line)])
			rows.append(null)
			continue
		var tokens: PackedStringArray = BoardText.split_row(line as String)
		if tokens.size() != BOARD_SIZE.x:
			result.add_error('%s: "%s" dòng %d: có %d ô, cần %d'
				% [file, shown, r + 1, tokens.size(), BOARD_SIZE.x])
			rows.append(null)
			continue
		for c: int in range(tokens.size()):
			if not symbols.has(tokens[c]):
				result.add_error('%s: "%s" dòng %d, cột %d (ô %d,%d): ký hiệu lạ %s'
					% [file, shown, r + 1, c + 1, c, r, JsonFile.show(tokens[c])])
				tokens[c] = ""
		rows.append(tokens)
	if lines.size() != BOARD_SIZE.y:
		result.add_error('%s: "%s" có %d dòng, cần %d' % [file, shown, lines.size(), BOARD_SIZE.y])
		return []
	return rows


static func has_symbol(rows: Array, symbol_text: String) -> bool:
	for row: Variant in rows:
		if row != null and (row as PackedStringArray).has(symbol_text):
			return true
	return false


## Ký hiệu ở ô; "" nếu ô hoặc dòng không đọc được.
static func symbol(rows: Array, cell: Vector2i) -> String:
	if rows.is_empty() or rows[cell.y] == null:
		return ""
	return (rows[cell.y] as PackedStringArray)[cell.x]


## Kiểm từng ô của lớp quân: quân đứng trên ô chặn, tướng lặp. Trả { ký hiệu tướng: ô }.
static func check_unit_cells(terrain_rows: Array, unit_rows: Array, shown: String,
		file: String, result: LoadResult) -> Dictionary:
	var generals: Dictionary = {}
	if unit_rows.is_empty():
		return generals
	for r: int in range(BOARD_SIZE.y):
		for c: int in range(BOARD_SIZE.x):
			var cell: Vector2i = Vector2i(c, r)
			var unit: String = symbol(unit_rows, cell)
			if unit == "" or unit == ".":
				continue
			var where: String = '%s: "%s" dòng %d, cột %d (ô %d,%d)' % [file, shown, r + 1, c + 1, c, r]
			var ground: String = symbol(terrain_rows, cell)
			if ground != "" and not Terrain.is_walkable(BoardText.TERRAIN_SYMBOLS[ground] as int):
				result.add_error('%s: quân "%s" đứng trên ô không đi vào được "%s"' % [where, unit, ground])
			if GENERAL_SYMBOLS.has(unit):
				if generals.has(unit):
					result.add_error('%s: tướng "%s" đã có ở ô %s'
						% [where, unit, BoardText.cell_text(generals[unit] as Vector2i)])
				else:
					generals[unit] = cell
	return generals


## Đọc thứ tự quân Nguyên và đối chiếu với lớp quân. Trả Array[Vector2i], hoặc null nếu thiếu/sai kiểu.
static func read_enemy_order(root: Dictionary, key: String, shown: String, unit_rows: Array,
		units_clean: bool, file: String, result: LoadResult) -> Variant:
	if not root.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, shown])
		return null
	if not root[key] is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", root[key]))
		return null
	var items: Array = root[key] as Array
	var order: Array[Vector2i] = []
	var seen: Dictionary = {}  # ô -> số mục (đếm từ 1)
	var board: Rect2i = Rect2i(Vector2i.ZERO, BOARD_SIZE)
	for i: int in range(items.size()):
		var item: Variant = items[i]
		var where: String = '%s: "%s" mục %d' % [file, shown, i + 1]
		var parsed: Variant = BoardText.parse_cell(item as String) if item is String else null
		if parsed == null:
			result.add_error('%s: %s không phải tọa độ "cot,hang"' % [where, JsonFile.show(item)])
			continue
		var cell: Vector2i = parsed as Vector2i
		var cell_shown: String = BoardText.cell_text(cell)
		if not board.has_point(cell):
			result.add_error("%s: ô %s nằm ngoài bàn" % [where, cell_shown])
			continue
		if seen.has(cell):
			result.add_error("%s: ô %s đã ghi ở mục %d" % [where, cell_shown, seen[cell]])
			continue
		seen[cell] = i + 1
		var unit: String = symbol(unit_rows, cell)
		if unit == "":
			continue
		if not ENEMY_SYMBOLS.has(unit):
			result.add_error("%s: ô %s không có quân Nguyên" % [where, cell_shown])
			continue
		order.append(cell)

	if units_clean:
		for cell: Vector2i in reading_order(unit_rows, ENEMY_SYMBOLS):
			if not seen.has(cell):
				result.add_error('%s: quân Nguyên "%s" ở ô %s không có trong "%s"'
					% [file, symbol(unit_rows, cell), BoardText.cell_text(cell), shown])
	return order


## Các ô có ký hiệu thuộc `symbols`, theo thứ tự đọc bàn: hàng trên xuống, trái sang phải.
static func reading_order(rows: Array, symbols: Array[String]) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for r: int in range(BOARD_SIZE.y):
		for c: int in range(BOARD_SIZE.x):
			var cell: Vector2i = Vector2i(c, r)
			if symbols.has(symbol(rows, cell)):
				cells.append(cell)
	return cells


static func terrain_values(rows: Array) -> PackedInt32Array:
	var values: PackedInt32Array = PackedInt32Array()
	for row: Variant in rows:
		for symbol_text: String in row as PackedStringArray:
			values.append(BoardText.TERRAIN_SYMBOLS[symbol_text] as int)
	return values
