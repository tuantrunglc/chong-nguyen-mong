class_name LevelLoader
extends RefCounted
## Nạp data/tran/*.json thành LevelData. Gom mọi lỗi rồi mới trả về; không ghi log (bên gọi ghi).
## Thứ tự lỗi: file/JSON -> khóa (phien_ban, ten, kieu) -> lớp dia_hinh (kể cả cỡ bàn) -> ô ải -> lớp quan
## (cùng cỡ với dia_hinh) -> kiểm từng ô của lớp quan -> thu_tu_dich -> quân thiếu trong thu_tu_dich.
## Cỡ bàn suy ra từ dia_hinh: số dòng là số hàng, số ô trên một dòng là số cột (Story 1.9).

const FORMAT_VERSION: int = 1

const KINDS: Dictionary = {
	"tieu_diet": LevelData.Mission.ELIMINATE,
	"giu_ai": LevelData.Mission.HOLD_PASS,
}

const KNOWN_KEYS: Array[String] = [
	"phien_ban_dinh_dang", "ten", "kieu", "dia_hinh", "quan", "thu_tu_dich",
	"tiep_vien", "muu_ke_mo", "so_hiep_toi_da", "long_dan",
]

const GENERAL_SYMBOLS: Array[String] = BoardLayers.GENERAL_SYMBOLS


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
			result.add_warning("%s: bỏ qua khóa lạ %s" % [file, JsonFile.show(key)])

	# Số nguyên nào khác 1 (kể cả 0 và số âm) là sai phiên bản, không phải lỗi số nguyên.
	var version: Variant = null
	if root.has("phien_ban_dinh_dang") and JsonFile.is_whole(root["phien_ban_dinh_dang"]):
		version = int(root["phien_ban_dinh_dang"])
	else:
		JsonFile.get_int(root, "phien_ban_dinh_dang", "phien_ban_dinh_dang", 1, file, result)
	if version != null and int(version) != FORMAT_VERSION:
		result.add_error('%s: "phien_ban_dinh_dang" là %d, game chỉ đọc được bản %d'
			% [file, version, FORMAT_VERSION])
	var level_name: String = _read_name(root, file, result)
	var mission: Variant = _read_kind(root, file, result)
	var max_rounds: int = _read_max_rounds(root, file, result)
	if mission == LevelData.Mission.HOLD_PASS and max_rounds == 0:
		max_rounds = 5

	var errors_before_terrain: int = result.errors.size()
	var terrain_rows: Array = BoardLayers.read_layer(root, "dia_hinh", "dia_hinh", BoardText.TERRAIN_SYMBOLS, file, result)
	var terrain_clean: bool = result.errors.size() == errors_before_terrain and not terrain_rows.is_empty()
	var size: Vector2i = BoardLayers.layer_size(terrain_rows)
	# Dòng hỏng có thể chứa ô ải: chỉ kiểm khi cả lớp dia_hinh đọc được.
	if terrain_clean and mission == LevelData.Mission.HOLD_PASS and not BoardLayers.has_symbol(terrain_rows, "A"):
		result.add_error('%s: trận "giu_ai" phải có ít nhất một ô ải "A" trong "dia_hinh"' % file)
	var long_dan: int = _read_long_dan(root, terrain_rows, terrain_clean, file, result)
	var errors_before_units: int = result.errors.size()
	var unit_rows: Array = BoardLayers.read_layer(root, "quan", "quan", BoardText.UNIT_SYMBOLS, file, result,
		size, "dia_hinh")
	var units_clean: bool = result.errors.size() == errors_before_units and not unit_rows.is_empty()

	var generals: Dictionary = BoardLayers.check_unit_cells(terrain_rows, unit_rows, "quan", file, result, mission)
	if units_clean and generals.is_empty():
		result.add_error('%s: "quan" không có tướng nào (cần ít nhất một trong 1, 2, 3)' % file)
	# Tiêu diệt thắng khi hết quân Nguyên: bàn trống quân Nguyên từ đầu thì trận thắng ngay ở lần gục đầu tiên.
	if units_clean and mission == LevelData.Mission.ELIMINATE \
			and BoardLayers.reading_order(unit_rows, BoardLayers.ENEMY_SYMBOLS).is_empty():
		result.add_error('%s: trận "tieu_diet" phải có ít nhất một quân Nguyên trong "quan"' % file)

	var order: Variant = BoardLayers.read_enemy_order(root, "thu_tu_dich", "thu_tu_dich", unit_rows, units_clean,
		size, file, result)
	var reinforcements: Array[LevelData.Reinforcement] = BoardLayers.read_reinforcements(root, terrain_rows,
		terrain_clean, size, max_rounds, file, result)
	var stratagems: Array[int] = []
	if root.has("muu_ke_mo"):
		stratagems = BoardLayers.read_stratagems(root["muu_ke_mo"], "muu_ke_mo", file, result)

	if not result.ok:
		return result
	var level: LevelData = LevelData.new()
	level.format_version = int(version)
	level.name = level_name
	level.mission = mission as LevelData.Mission
	level.max_rounds = max_rounds
	level.long_dan = long_dan
	level.size = size
	level.terrain = BoardLayers.terrain_values(terrain_rows)
	level.reinforcements = reinforcements
	level.stratagems = stratagems
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


static func _read_max_rounds(root: Dictionary, file: String, result: LoadResult) -> int:
	if not root.has("so_hiep_toi_da"):
		return 0
	var val: Variant = JsonFile.get_int(root, "so_hiep_toi_da", "so_hiep_toi_da", 1, file, result)
	return int(val) if val != null else 0


static func _read_long_dan(root: Dictionary, terrain_rows: Array, terrain_clean: bool, file: String, result: LoadResult) -> int:
	if not terrain_clean:
		return 0
	var has_village: bool = BoardLayers.has_symbol(terrain_rows, "D")
	if has_village and not root.has("long_dan"):
		result.add_error('%s: có ô làng "D" trong "dia_hinh" mà thiếu khóa "long_dan"' % file)
		return 0
	if not root.has("long_dan"):
		return 0
	if not has_village:
		result.add_error('%s: có khóa "long_dan" mà không có ô làng "D" trong "dia_hinh"' % file)
		return 0
	var val: Variant = JsonFile.get_int(root, "long_dan", "long_dan", 1, file, result)
	return int(val) if val != null else 0
