class_name BoardLayers
extends RefCounted
## Đọc lớp bàn cờ chữ (dia_hinh, quan) và thu_tu_dich, gom lỗi vào LoadResult.
## Dùng chung cho file trận và kịch bản luật. `key` là khóa trong object, `shown` là tên in trong câu lỗi
## ("quan" với file trận, "truoc.quan" với kịch bản).

## Cỡ bàn (cột, hàng) suy ra từ bàn cờ chữ, hợp lệ trong [BOARD_MIN, BOARD_MAX] (tác giả chốt 2026-10-20).
## Quy cách định dạng, không phải số cân bằng.
const BOARD_MIN: Vector2i = Vector2i(5, 5)
const BOARD_MAX: Vector2i = Vector2i(10, 8)
## Chưa biết cỡ (lớp đầu tiên hỏng): không kiểm chéo, không kiểm ô ngoài bàn (đã có lỗi riêng).
const NO_SIZE: Vector2i = Vector2i.ZERO

const GENERAL_SYMBOLS: Array[String] = ["1", "2", "3"]
const ENEMY_SYMBOLS: Array[String] = ["B", "K", "C"]


## Đọc một lớp bàn cờ chữ. Trả mảng theo dòng: mỗi phần tử là PackedStringArray các ký hiệu của dòng
## (ô có ký hiệu lạ thành ""), hoặc null nếu cả dòng không đọc được. Lớp thiếu hoặc sai kiểu thì trả [].
## size_shown "" là lớp đầu tiên (quyết cỡ bàn): mọi dòng phải cùng số ô với dòng đầu tiên, và cỡ phải nằm trong
## [BOARD_MIN, BOARD_MAX]. Lớp khác: cùng cỡ `size` của lớp size_shown, sai số dòng thì trả []; size là NO_SIZE
## (lớp đầu hỏng) thì chỉ kiểm các dòng cùng số ô với nhau.
static func read_layer(root: Dictionary, key: String, shown: String, symbols: Dictionary,
		file: String, result: LoadResult, size: Vector2i = NO_SIZE, size_shown: String = "") -> Array:
	if not root.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, shown])
		return []
	if not root[key] is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", root[key]))
		return []
	var lines: Array = root[key] as Array
	var cross_check: bool = not size_shown.is_empty() and size != NO_SIZE
	# Dòng đầu tiên là chuỗi: số ô của nó là số cột khi chưa có cỡ để so.
	var first_row: int = -1
	var first_width: int = 0
	var rows: Array = []
	for r: int in range(lines.size()):
		var line: Variant = lines[r]
		if not line is String:
			result.add_error('%s: "%s" dòng %d phải là một chuỗi, đang là %s'
				% [file, shown, r + 1, JsonFile.show(line)])
			rows.append(null)
			continue
		var tokens: PackedStringArray = BoardText.split_row(line as String)
		if first_row < 0:
			first_row = r
			first_width = tokens.size()
		if cross_check and tokens.size() != size.x:
			result.add_error('%s: "%s" dòng %d: có %d ô, "%s" có %d'
				% [file, shown, r + 1, tokens.size(), size_shown, size.x])
			rows.append(null)
			continue
		if not cross_check and tokens.size() != first_width:
			result.add_error('%s: "%s" dòng %d: có %d ô, dòng %d có %d'
				% [file, shown, r + 1, tokens.size(), first_row + 1, first_width])
			rows.append(null)
			continue
		for c: int in range(tokens.size()):
			if not symbols.has(tokens[c]):
				result.add_error('%s: "%s" dòng %d, cột %d (ô %d,%d): ký hiệu lạ %s'
					% [file, shown, r + 1, c + 1, c, r, JsonFile.show(tokens[c])])
				tokens[c] = ""
		rows.append(tokens)
	if cross_check and lines.size() != size.y:
		result.add_error('%s: "%s" có %d dòng, "%s" có %d' % [file, shown, lines.size(), size_shown, size.y])
		return []
	if size_shown.is_empty() and not rows.has(null):
		var read: Vector2i = Vector2i(first_width, lines.size())
		if read.x < BOARD_MIN.x or read.y < BOARD_MIN.y or read.x > BOARD_MAX.x or read.y > BOARD_MAX.y:
			result.add_error('%s: "%s": bàn %d cột × %d hàng, chỉ được từ %d đến %d cột và từ %d đến %d hàng'
				% [file, shown, read.x, read.y, BOARD_MIN.x, BOARD_MAX.x, BOARD_MIN.y, BOARD_MAX.y])
	return rows


## Cỡ (cột, hàng) của lớp đã đọc; NO_SIZE nếu lớp rỗng hoặc có dòng không đọc được.
static func layer_size(rows: Array) -> Vector2i:
	if rows.is_empty() or rows.has(null):
		return NO_SIZE
	return Vector2i((rows[0] as PackedStringArray).size(), rows.size())


static func has_symbol(rows: Array, symbol_text: String) -> bool:
	for row: Variant in rows:
		if row != null and (row as PackedStringArray).has(symbol_text):
			return true
	return false


## Ký hiệu ở ô; "" nếu ô hoặc dòng không đọc được, hay ô nằm ngoài lớp (lớp khác cỡ đã có lỗi riêng).
static func symbol(rows: Array, cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= rows.size() or rows[cell.y] == null:
		return ""
	var row: PackedStringArray = rows[cell.y] as PackedStringArray
	if cell.x < 0 or cell.x >= row.size():
		return ""
	return row[cell.x]


## Kiểm từng ô của lớp quân: quân đứng trên ô chặn, tướng lặp, và quân Nguyên trên ô ải trong trận giu_ai.
## Trả { ký hiệu tướng: ô }.
static func check_unit_cells(terrain_rows: Array, unit_rows: Array, shown: String,
		file: String, result: LoadResult, mission: Variant = null) -> Dictionary:
	var generals: Dictionary = {}
	for r: int in range(unit_rows.size()):
		if unit_rows[r] == null:
			continue
		for c: int in range((unit_rows[r] as PackedStringArray).size()):
			var cell: Vector2i = Vector2i(c, r)
			var unit: String = symbol(unit_rows, cell)
			if unit == "" or unit == ".":
				continue
			var where: String = '%s: "%s" dòng %d, cột %d (ô %d,%d)' % [file, shown, r + 1, c + 1, c, r]
			var ground: String = symbol(terrain_rows, cell)
			if ground != "" and not Terrain.is_walkable(BoardText.TERRAIN_SYMBOLS[ground] as int):
				result.add_error('%s: quân "%s" đứng trên ô không đi vào được "%s"' % [where, unit, ground])
			elif mission == LevelData.Mission.HOLD_PASS and ENEMY_SYMBOLS.has(unit) and ground == "A":
				result.add_error('%s: trận "giu_ai" không được đặt quân Nguyên "%s" trên ô ải "A"' % [where, unit])
			if GENERAL_SYMBOLS.has(unit):
				if generals.has(unit):
					result.add_error('%s: tướng "%s" đã có ở ô %s'
						% [where, unit, BoardText.cell_text(generals[unit] as Vector2i)])
				else:
					generals[unit] = cell
	return generals


## Đọc thứ tự quân Nguyên và đối chiếu với lớp quân. Trả Array[Vector2i], hoặc null nếu thiếu/sai kiểu.
## size là cỡ bàn; NO_SIZE thì không kiểm ô ngoài bàn.
static func read_enemy_order(root: Dictionary, key: String, shown: String, unit_rows: Array,
		units_clean: bool, size: Vector2i, file: String, result: LoadResult) -> Variant:
	if not root.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, shown])
		return null
	if not root[key] is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", root[key]))
		return null
	var items: Array = root[key] as Array
	var order: Array[Vector2i] = []
	var seen: Dictionary = {}  # ô -> số mục (đếm từ 1)
	var board: Rect2i = Rect2i(Vector2i.ZERO, size)
	for i: int in range(items.size()):
		var item: Variant = items[i]
		var where: String = '%s: "%s" mục %d' % [file, shown, i + 1]
		var parsed: Variant = BoardText.parse_cell(item as String) if item is String else null
		if parsed == null:
			result.add_error('%s: %s không phải tọa độ "cot,hang"' % [where, JsonFile.show(item)])
			continue
		var cell: Vector2i = parsed as Vector2i
		var cell_shown: String = BoardText.cell_text(cell)
		if size != NO_SIZE and not board.has_point(cell):
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
	for r: int in range(rows.size()):
		if rows[r] == null:
			continue
		for c: int in range((rows[r] as PackedStringArray).size()):
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


const REINFORCEMENT_KEYS: Array[String] = ["hiep", "o", "loai", "mau"]

static func read_reinforcements(root: Dictionary, terrain_rows: Array, terrain_clean: bool, size: Vector2i,
		max_rounds: int, file: String, result: LoadResult) -> Array[LevelData.Reinforcement]:
	var list: Array[LevelData.Reinforcement] = []
	if not root.has("tiep_vien"):
		return list
	var raw: Variant = root["tiep_vien"]
	if not raw is Array:
		result.add_error(JsonFile.type_error(file, "tiep_vien", "một danh sách", raw))
		return list
	var items: Array = raw as Array
	var board_rect: Rect2i = Rect2i(Vector2i.ZERO, size)
	for i: int in range(items.size()):
		var where: String = '%s: "tiep_vien" mục %d' % [file, i + 1]
		if not items[i] is Dictionary:
			result.add_error("%s phải là một object, đang là %s" % [where, JsonFile.show(items[i])])
			continue
		var d: Dictionary = items[i] as Dictionary
		for key: Variant in d.keys():
			if not REINFORCEMENT_KEYS.has(key):
				result.add_warning("%s: bỏ qua khóa lạ %s" % [where, JsonFile.show(key)])
		var round_val: Variant = null
		if not d.has("hiep"):
			result.add_error('%s: thiếu khóa "hiep"' % where)
		elif not JsonFile.is_whole(d["hiep"]) or int(d["hiep"]) < 2:
			result.add_error('%s: "hiep" phải là số nguyên từ 2 trở lên, đang là %s'
				% [where, JsonFile.show(d["hiep"])])
		elif max_rounds > 0 and int(d["hiep"]) > max_rounds:
			result.add_error('%s: "hiep" là %d, vượt quá số hiệp tối đa %d'
				% [where, int(d["hiep"]), max_rounds])
		else:
			round_val = int(d["hiep"])

		var cell: Variant = null
		if not d.has("o"):
			result.add_error('%s: thiếu khóa "o"' % where)
		else:
			var parsed: Variant = BoardText.parse_cell(d["o"] as String) if d["o"] is String else null
			if parsed == null or not board_rect.has_point(parsed as Vector2i):
				result.add_error('%s: "o" là %s, không phải ô trong bàn' % [where, JsonFile.show(d["o"])])
			else:
				var c: Vector2i = parsed as Vector2i
				if terrain_clean:
					var terrain_symbol: String = (terrain_rows[c.y] as PackedStringArray)[c.x]
					var terrain_type: int = BoardText.TERRAIN_SYMBOLS[terrain_symbol] as int
					if not Terrain.is_walkable(terrain_type):
						result.add_error('%s: ô %s là ô không đi vào được' % [where, BoardText.cell_text(c)])
					else:
						cell = c
				else:
					cell = c

		var type_val: Variant = null
		if not d.has("loai"):
			result.add_error('%s: thiếu khóa "loai"' % where)
		elif not d["loai"] is String or not ENEMY_SYMBOLS.has(d["loai"]):
			result.add_error('%s: "loai" là %s, chỉ được "B", "K", "C"' % [where, JsonFile.show(d["loai"])])
		else:
			type_val = BoardText.UNIT_SYMBOLS[d["loai"]] as int

		var hp_val: int = 0
		if d.has("mau"):
			if not JsonFile.is_whole(d["mau"]) or int(d["mau"]) < 1:
				result.add_error('%s: "mau" phải là số nguyên từ 1 trở lên, đang là %s'
					% [where, JsonFile.show(d["mau"])])
			else:
				hp_val = int(d["mau"])

		if round_val != null and cell != null and type_val != null:
			list.append(LevelData.Reinforcement.new(round_val as int, cell as Vector2i, type_val as int, hp_val))
	return list


## Danh sách tên mưu kế (Story 3.12): "muu_ke_mo" của file trận, "muu_ke_mo"/"muu_ke_da_dung" của kịch bản.
## Trả Array[int] (Stratagem.Kind) theo thứ tự trong file; sai thì thêm lỗi và bỏ mục sai.
static func read_stratagems(value: Variant, shown: String, file: String, result: LoadResult) -> Array[int]:
	var list: Array[int] = []
	if not value is Array:
		result.add_error(JsonFile.type_error(file, shown, "một danh sách", value))
		return list
	var items: Array = value as Array
	for i: int in range(items.size()):
		var item: Variant = items[i]
		if not item is String or not Stratagem.NAMES.has(item):
			result.add_error('%s: "%s" mục %d là %s, chỉ được %s'
				% [file, shown, i + 1, JsonFile.show(item), Stratagem.name_list()])
			continue
		var kind: int = Stratagem.NAMES[item] as int
		if list.has(kind):
			result.add_error('%s: "%s" mục %d: %s bị ghi hai lần' % [file, shown, i + 1, JsonFile.show(item)])
			continue
		list.append(kind)
	return list
