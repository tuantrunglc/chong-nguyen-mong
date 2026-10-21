extends GutTest
## Bộ nạp chi_so.json và file trận: dữ liệu đúng thì ra Stats / LevelData; dữ liệu sai thì ra đúng
## nguyên văn câu báo lỗi tiếng Việt (danh mục trong story 1.1). So cả mảng để bắt lỗi thừa.

const LEVEL_FILE: String = "data/tran/thu.json"
const STATS_FILE: String = "data/chi_so.json"


# ---------- Dữ liệu mẫu ----------

func _valid_level() -> Dictionary:
	return {
		"phien_ban_dinh_dang": 1,
		"ten": "Trận thử",
		"kieu": "tieu_diet",
		"dia_hinh": [
			". . . ~ . . .",
			". # . ~ . . .",
			". . . ~ . L .",
			"^ . . . . . A",
			". . . ~ D . .",
			". . . ~ . . .",
			". . . ~ . . .",
		],
		"quan": [
			". B . . . K .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . C .",
			". . . . . . .",
			"2 . 1 . . . .",
		],
		# Khác thứ tự đọc từ trái sang phải, trên xuống dưới.
		"thu_tu_dich": ["5,4", "1,0", "5,0"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	}


func _valid_stats() -> Dictionary:
	return {
		"tuong": {
			"nguyen_khoai": {"mau": 3, "tam_di": 3, "sat_thuong": 2, "do_day": 1},
			"pham_ngu_lao": {"mau": 3, "tam_di": 3, "sat_thuong": 1, "tam_danh_gan": 2, "tam_danh_xa": 4},
			"tran_khanh_du": {"mau": 3, "tam_di": 3, "tam_danh": 3, "tam_keo": 2},
		},
		"quan_nguyen": {
			"bo_binh": {"mau": 3, "tam_di": 2, "sat_thuong": 1},
			"ky_binh": {"mau": 2, "tam_di": 3, "sat_thuong": 1},
			"cung_ky": {"mau": 1, "tam_di": 3, "sat_thuong": 1, "tam_ban_gan": 2, "tam_ban_xa": 3},
		},
	}


func _level(d: Dictionary) -> LoadResult:
	return LevelLoader.parse_level(JSON.stringify(d), LEVEL_FILE)


func _stats(d: Dictionary) -> LoadResult:
	return StatsLoader.parse_stats(JSON.stringify(d), STATS_FILE)


func _with(d: Dictionary, key: String, value: Variant) -> Dictionary:
	var copy: Dictionary = d.duplicate(true)
	copy[key] = value
	return copy


func _without(d: Dictionary, key: String) -> Dictionary:
	var copy: Dictionary = d.duplicate(true)
	copy.erase(key)
	return copy


## Đổi một dòng của lớp "dia_hinh" hoặc "quan".
func _with_row(d: Dictionary, layer: String, row: int, text: Variant) -> Dictionary:
	var copy: Dictionary = d.duplicate(true)
	var rows: Array = copy[layer] as Array
	rows[row] = text
	return copy


## Đổi một khóa của một quân trong chi_so.json, ví dụ ("tuong", "nguyen_khoai", "mau", 0).
func _with_stat(group: String, unit: String, key: String, value: Variant) -> Dictionary:
	var copy: Dictionary = _valid_stats()
	((copy[group] as Dictionary)[unit] as Dictionary)[key] = value
	return copy


func _without_stat(group: String, unit: String, key: String) -> Dictionary:
	var copy: Dictionary = _valid_stats()
	((copy[group] as Dictionary)[unit] as Dictionary).erase(key)
	return copy


func _errors(lines: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for line: String in lines:
		out.append(LEVEL_FILE + ": " + line)
	return out


func _stat_errors(lines: Array[String]) -> Array[String]:
	var out: Array[String] = []
	for line: String in lines:
		out.append(STATS_FILE + ": " + line)
	return out


# ---------- File trận: ca hợp lệ ----------

func test_valid_level_loads() -> void:
	var r: LoadResult = _level(_valid_level())
	assert_true(r.ok, "nạp được")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	assert_eq(level.format_version, 1)
	assert_eq(level.name, "Trận thử")
	assert_eq(level.mission, LevelData.Mission.ELIMINATE)
	assert_eq(level.size, Vector2i(7, 7))


func test_valid_level_terrain() -> void:
	var level: LevelData = _level(_valid_level()).data as LevelData
	assert_eq(level.terrain_at(Vector2i(0, 0)), Terrain.PLAIN)
	assert_eq(level.terrain_at(Vector2i(3, 0)), Terrain.RIVER)
	assert_eq(level.terrain_at(Vector2i(1, 1)), Terrain.FOREST)
	assert_eq(level.terrain_at(Vector2i(5, 2)), Terrain.GRANARY)
	assert_eq(level.terrain_at(Vector2i(0, 3)), Terrain.SPIKES)
	assert_eq(level.terrain_at(Vector2i(6, 3)), Terrain.PASS)
	assert_eq(level.terrain_at(Vector2i(4, 4)), Terrain.VILLAGE)
	assert_eq(level.terrain_at(Vector2i(3, 3)), Terrain.PLAIN)


func test_units_ordered_generals_then_enemy_order() -> void:
	var level: LevelData = _level(_valid_level()).data as LevelData
	var got: Array[String] = []
	for p: LevelData.UnitPlacement in level.units:
		got.append("%d@%d,%d" % [p.type, p.cell.x, p.cell.y])
	var expected: Array[String] = [
		"%d@2,6" % UnitType.NGUYEN_KHOAI,
		"%d@0,6" % UnitType.PHAM_NGU_LAO,
		"%d@5,4" % UnitType.CUNG_KY,
		"%d@1,0" % UnitType.BO_BINH,
		"%d@5,0" % UnitType.KY_BINH,
	]
	assert_eq(got, expected)


func test_giu_ai_mission() -> void:
	var level: LevelData = _level(_with(_valid_level(), "kieu", "giu_ai")).data as LevelData
	assert_eq(level.mission, LevelData.Mission.HOLD_PASS)


func test_known_later_keys_give_no_warning() -> void:
	var d: Dictionary = _with(_valid_level(), "so_hiep_toi_da", 4)
	d["long_dan"] = 3
	var r: LoadResult = _level(d)
	assert_true(r.ok)
	assert_eq(r.warnings, [] as Array[String])


func test_optional_keys_may_be_missing() -> void:
	var r: LoadResult = _level(_without(_without(_valid_level(), "tiep_vien"), "muu_ke_mo"))
	assert_true(r.ok)


func test_unknown_key_is_warning_not_error() -> void:
	var r: LoadResult = _level(_with(_valid_level(), "ten_khac", "x"))
	assert_true(r.ok, "vẫn nạp được")
	assert_eq(r.warnings, _errors(['bỏ qua khóa lạ "ten_khac"']))


func test_whole_float_version_is_accepted() -> void:
	var text: String = JSON.stringify(_valid_level()).replace('"phien_ban_dinh_dang":1', '"phien_ban_dinh_dang":1.0')
	assert_string_contains(text, '"phien_ban_dinh_dang":1.0')
	assert_true(LevelLoader.parse_level(text, LEVEL_FILE).ok)


func test_bom_at_start_is_ignored() -> void:
	var text: String = "\uFEFF" + JSON.stringify(_valid_level())
	assert_true(LevelLoader.parse_level(text, LEVEL_FILE).ok)


func test_trailing_comma_is_accepted() -> void:
	var text: String = JSON.stringify(_valid_level())
	text = text.substr(0, text.length() - 1) + ",}"
	assert_true(LevelLoader.parse_level(text, LEVEL_FILE).ok)


func test_extra_spaces_and_tabs_in_rows() -> void:
	var d: Dictionary = _with_row(_valid_level(), "dia_hinh", 2, "  .\t. .  ~ .  L   .  ")
	var r: LoadResult = _level(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq((r.data as LevelData).terrain_at(Vector2i(5, 2)), Terrain.GRANARY)


func test_enemy_order_tolerates_spaces() -> void:
	var r: LoadResult = _level(_with(_valid_level(), "thu_tu_dich", [" 5 , 4 ", "1,0", "5,0"]))
	assert_eq(r.errors, [] as Array[String])


func test_non_breaking_spaces_in_rows() -> void:
	var nbsp: String = "\u00A0"
	var d: Dictionary = _with_row(_valid_level(), "dia_hinh", 2, ". . . ~ .%sL\u3000." % nbsp)
	var r: LoadResult = _level(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq((r.data as LevelData).terrain_at(Vector2i(5, 2)), Terrain.GRANARY)


func test_giu_ai_without_pass_cell() -> void:
	var d: Dictionary = _with_row(_with(_valid_level(), "kieu", "giu_ai"), "dia_hinh", 3, "^ . . . . . .")
	assert_eq(_level(d).errors, _errors(['trận "giu_ai" phải có ít nhất một ô ải "A" trong "dia_hinh"']))


func test_tieu_diet_without_pass_cell_is_allowed() -> void:
	var d: Dictionary = _with_row(_valid_level(), "dia_hinh", 3, "^ . . . . . .")
	assert_eq(_level(d).errors, [] as Array[String])


func test_giu_ai_pass_cell_not_checked_when_terrain_is_broken() -> void:
	var d: Dictionary = _with_row(_with(_valid_level(), "kieu", "giu_ai"), "dia_hinh", 3, "^ . . . . .")
	assert_eq(_level(d).errors, _errors(['"dia_hinh" dòng 4: có 6 ô, dòng 1 có 7']))


# ---------- File trận: lỗi file và JSON ----------

func test_missing_file() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/khong_co.json")
	assert_false(r.ok)
	assert_eq(r.errors, ["data/tran/khong_co.json: không đọc được file"] as Array[String])
	assert_null(r.data)


func test_json_syntax_error_reports_line_counted_from_one() -> void:
	var r: LoadResult = LevelLoader.parse_level('{\n"ten" "a"\n}', LEVEL_FILE)
	assert_eq(r.errors, [LEVEL_FILE + ", dòng 2: JSON sai cú pháp (Expected ':')"] as Array[String])


func test_empty_text_is_json_error() -> void:
	var r: LoadResult = LevelLoader.parse_level("", LEVEL_FILE)
	assert_eq(r.errors.size(), 1)
	assert_string_starts_with(r.errors[0], LEVEL_FILE + ", dòng 1: JSON sai cú pháp (")


func test_root_not_object() -> void:
	var r: LoadResult = LevelLoader.parse_level("[1, 2]", LEVEL_FILE)
	assert_eq(r.errors, _errors(["nội dung phải là một object JSON"]))


# ---------- File trận: khóa ----------

func test_all_required_keys_missing_in_order() -> void:
	var r: LoadResult = _level({})
	assert_eq(r.errors, _errors([
		'thiếu khóa "phien_ban_dinh_dang"',
		'thiếu khóa "ten"',
		'thiếu khóa "kieu"',
		'thiếu khóa "dia_hinh"',
		'thiếu khóa "quan"',
		'thiếu khóa "thu_tu_dich"',
	]))


func test_missing_kieu() -> void:
	assert_eq(_level(_without(_valid_level(), "kieu")).errors, _errors(['thiếu khóa "kieu"']))


func test_version_not_integer() -> void:
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", "1")).errors,
		_errors(['"phien_ban_dinh_dang" phải là số nguyên từ 1 trở lên, đang là "1"']))
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", 2.5)).errors,
		_errors(['"phien_ban_dinh_dang" phải là số nguyên từ 1 trở lên, đang là 2.5']))


func test_version_unsupported() -> void:
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", 2)).errors,
		_errors(['"phien_ban_dinh_dang" là 2, game chỉ đọc được bản 1']))
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", 0)).errors,
		_errors(['"phien_ban_dinh_dang" là 0, game chỉ đọc được bản 1']))
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", -1)).errors,
		_errors(['"phien_ban_dinh_dang" là -1, game chỉ đọc được bản 1']))


func test_huge_version_is_not_integer() -> void:
	assert_eq(_level(_with(_valid_level(), "phien_ban_dinh_dang", 1e20)).errors,
		_errors(['"phien_ban_dinh_dang" phải là số nguyên từ 1 trở lên, đang là 100000000000000000000.0']))


func test_name_wrong_type() -> void:
	assert_eq(_level(_with(_valid_level(), "ten", 5)).errors,
		_errors(['"ten" phải là một chuỗi, đang là 5']))


func test_name_blank() -> void:
	assert_eq(_level(_with(_valid_level(), "ten", "  ")).errors,
		_errors(['"ten" không được để trống']))


func test_kind_unknown() -> void:
	assert_eq(_level(_with(_valid_level(), "kieu", "giet")).errors,
		_errors(['"kieu" là "giet", chỉ được "tieu_diet" hoặc "giu_ai"']))


func test_kind_wrong_type() -> void:
	assert_eq(_level(_with(_valid_level(), "kieu", 1)).errors,
		_errors(['"kieu" phải là một chuỗi, đang là 1']))


# ---------- File trận: bàn cờ ----------

func test_layer_wrong_type() -> void:
	assert_eq(_level(_with(_valid_level(), "dia_hinh", "abc")).errors,
		_errors(['"dia_hinh" phải là một danh sách, đang là "abc"']))


## Bỏ một dòng dia_hinh: bàn 7×6 vẫn hợp lệ (Story 1.9), lỗi là lớp quan khác cỡ.
func test_unit_layer_row_count_differs_from_terrain() -> void:
	var d: Dictionary = _valid_level()
	(d["dia_hinh"] as Array).pop_back()
	assert_eq(_level(d).errors, _errors(['"quan" có 7 dòng, "dia_hinh" có 6']))


func test_row_not_string() -> void:
	assert_eq(_level(_with_row(_valid_level(), "dia_hinh", 1, 5)).errors,
		_errors(['"dia_hinh" dòng 2 phải là một chuỗi, đang là 5']))


func test_row_wrong_length() -> void:
	assert_eq(_level(_with_row(_valid_level(), "dia_hinh", 2, ". . ~ . L .")).errors,
		_errors(['"dia_hinh" dòng 3: có 6 ô, dòng 1 có 7']))


# ---------- File trận: cỡ bàn (Story 1.9) ----------

## Bàn toàn đất trống cols × rows, Nguyễn Khoái ở góc dưới trái, một Bộ binh ở góc trên phải (trận Tiêu diệt phải có
## quân Nguyên).
func _board_level(cols: int, rows: int) -> Dictionary:
	var terrain: Array = []
	var units: Array = []
	for r: int in range(rows):
		var cells: PackedStringArray = PackedStringArray()
		cells.resize(cols)
		cells.fill(".")
		terrain.append(" ".join(cells))
		if r == rows - 1:
			cells[0] = "1"
		if r == 0:
			cells[cols - 1] = "B"
		units.append(" ".join(cells))
	var d: Dictionary = _with(_valid_level(), "dia_hinh", terrain)
	d["quan"] = units
	d["thu_tu_dich"] = ["%d,0" % (cols - 1)]
	return d


func test_board_too_wide() -> void:
	assert_eq(_level(_board_level(11, 8)).errors,
		_errors(['"dia_hinh": bàn 11 cột × 8 hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng']))


func test_board_too_small() -> void:
	assert_eq(_level(_board_level(4, 5)).errors,
		_errors(['"dia_hinh": bàn 4 cột × 5 hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng']))


func test_board_too_tall() -> void:
	assert_eq(_level(_board_level(7, 9)).errors,
		_errors(['"dia_hinh": bàn 7 cột × 9 hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng']))


func test_empty_terrain_layer_is_a_size_error() -> void:
	var d: Dictionary = _with(_board_level(5, 5), "dia_hinh", [])
	var errors: Array[String] = _level(d).errors
	assert_has(errors, LEVEL_FILE + ': "dia_hinh": bàn 0 cột × 0 hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng')


func test_unit_row_wrong_length() -> void:
	assert_eq(_level(_with_row(_valid_level(), "quan", 1, ". . . . . .")).errors,
		_errors(['"quan" dòng 2: có 6 ô, "dia_hinh" có 7']))


func test_smallest_and_largest_boards_load() -> void:
	for size: Vector2i in [Vector2i(5, 5), Vector2i(10, 8)]:
		var r: LoadResult = _level(_board_level(size.x, size.y))
		assert_eq(r.errors, [] as Array[String], "bàn %s" % size)
		if r.ok:
			assert_eq((r.data as LevelData).size, size)


func test_non_square_board_loads() -> void:
	var d: Dictionary = _board_level(6, 7)
	(d["dia_hinh"] as Array)[6] = ". . . . . ~"
	var r: LoadResult = _level(d)
	assert_eq(r.errors, [] as Array[String])
	if not r.ok:
		return
	var level: LevelData = r.data as LevelData
	assert_eq(level.size, Vector2i(6, 7), "6 cột, 7 hàng")
	assert_eq(level.terrain_at(Vector2i(5, 6)), Terrain.RIVER, "ô góc dưới phải")
	assert_eq(level.units[0].cell, Vector2i(0, 6))


func test_enemy_order_outside_non_square_board() -> void:
	var d: Dictionary = _with(_board_level(6, 7), "thu_tu_dich", ["5,0", "6,0"])
	assert_eq(_level(d).errors, _errors(['"thu_tu_dich" mục 2: ô 6,0 nằm ngoài bàn']))


func test_co_nho_and_co_lon_load() -> void:
	var sizes: Dictionary = {"thu_co_nho": Vector2i(5, 5), "thu_co_lon": Vector2i(10, 8)}
	for name: String in sizes:
		var r: LoadResult = LevelLoader.load_level("res://data/tran/%s.json" % name)
		assert_eq(r.errors, [] as Array[String], name)
		assert_eq(r.warnings, [] as Array[String], name)
		if r.ok:
			assert_eq((r.data as LevelData).size, sizes[name], name)


func test_unknown_terrain_symbol() -> void:
	assert_eq(_level(_with_row(_valid_level(), "dia_hinh", 2, ". . . X . L .")).errors,
		_errors(['"dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"']))


func test_unknown_unit_symbol() -> void:
	assert_eq(_level(_with_row(_valid_level(), "quan", 1, ". . Z . . . .")).errors,
		_errors(['"quan" dòng 2, cột 3 (ô 2,1): ký hiệu lạ "Z"']))


func test_unit_on_river() -> void:
	var d: Dictionary = _with_row(_valid_level(), "quan", 1, ". . . B . . .")
	(d["thu_tu_dich"] as Array).append("3,1")
	assert_eq(_level(d).errors,
		_errors(['"quan" dòng 2, cột 4 (ô 3,1): quân "B" đứng trên ô không đi vào được "~"']))


func test_general_on_forest() -> void:
	var d: Dictionary = _with_row(_valid_level(), "quan", 1, ". 3 . . . . .")
	assert_eq(_level(d).errors,
		_errors(['"quan" dòng 2, cột 2 (ô 1,1): quân "3" đứng trên ô không đi vào được "#"']))


func test_unit_on_unreadable_terrain_cell_is_not_reported_twice() -> void:
	var d: Dictionary = _with_row(_valid_level(), "dia_hinh", 0, ". X . ~ . . .")
	assert_eq(_level(d).errors, _errors(['"dia_hinh" dòng 1, cột 2 (ô 1,0): ký hiệu lạ "X"']))


func test_duplicate_general() -> void:
	assert_eq(_level(_with_row(_valid_level(), "quan", 6, "2 . 1 . 1 . .")).errors,
		_errors(['"quan" dòng 7, cột 5 (ô 4,6): tướng "1" đã có ở ô 2,6']))


func test_no_general() -> void:
	assert_eq(_level(_with_row(_valid_level(), "quan", 6, ". . . . . . .")).errors,
		_errors(['"quan" không có tướng nào (cần ít nhất một trong 1, 2, 3)']))


func test_tieu_diet_without_enemy() -> void:
	var d: Dictionary = _valid_level()
	d["quan"] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		"2 . 1 . . . .",
	]
	d["thu_tu_dich"] = []
	assert_eq(_level(d).errors,
		_errors(['trận "tieu_diet" phải có ít nhất một quân Nguyên trong "quan"']))


func test_giu_ai_without_enemy_is_allowed() -> void:
	var d: Dictionary = _with(_valid_level(), "kieu", "giu_ai")
	d["quan"] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		"2 . 1 . . . .",
	]
	d["thu_tu_dich"] = []
	assert_true(_level(d).ok)


func test_no_general_not_reported_when_layer_broken() -> void:
	assert_eq(_level(_with_row(_valid_level(), "quan", 6, "X . . . . . .")).errors,
		_errors(['"quan" dòng 7, cột 1 (ô 0,6): ký hiệu lạ "X"']))


# ---------- File trận: thu_tu_dich ----------

func test_enemy_order_wrong_type() -> void:
	assert_eq(_level(_with(_valid_level(), "thu_tu_dich", "1,0")).errors,
		_errors(['"thu_tu_dich" phải là một danh sách, đang là "1,0"']))


func test_enemy_order_item_not_cell() -> void:
	var r: LoadResult = _level(_with(_valid_level(), "thu_tu_dich", ["5,4", "1;0", 5, "5,0"]))
	assert_eq(r.errors, _errors([
		'"thu_tu_dich" mục 2: "1;0" không phải tọa độ "cot,hang"',
		'"thu_tu_dich" mục 3: 5 không phải tọa độ "cot,hang"',
		'quân Nguyên "B" ở ô 1,0 không có trong "thu_tu_dich"',
	]))


func test_enemy_order_outside_board() -> void:
	assert_eq(_level(_with(_valid_level(), "thu_tu_dich", ["5,4", "1,0", "9,9"])).errors, _errors([
		'"thu_tu_dich" mục 3: ô 9,9 nằm ngoài bàn',
		'quân Nguyên "K" ở ô 5,0 không có trong "thu_tu_dich"',
	]))


func test_enemy_order_cell_without_enemy() -> void:
	assert_eq(_level(_with(_valid_level(), "thu_tu_dich", ["5,4", "1,0", "5,0", "0,0", "2,6"])).errors, _errors([
		'"thu_tu_dich" mục 4: ô 0,0 không có quân Nguyên',
		'"thu_tu_dich" mục 5: ô 2,6 không có quân Nguyên',
	]))


func test_enemy_order_duplicate() -> void:
	assert_eq(_level(_with(_valid_level(), "thu_tu_dich", ["5,4", "1,0", "5,0", "1,0"])).errors,
		_errors(['"thu_tu_dich" mục 4: ô 1,0 đã ghi ở mục 2']))


func test_enemy_missing_from_order() -> void:
	assert_eq(_level(_with(_valid_level(), "thu_tu_dich", ["5,4", "1,0"])).errors,
		_errors(['quân Nguyên "K" ở ô 5,0 không có trong "thu_tu_dich"']))


# ---------- File trận: nhiều lỗi cùng lúc ----------

func test_many_errors_listed_in_order() -> void:
	var d: Dictionary = _with(_valid_level(), "kieu", "giet")
	d = _with_row(d, "dia_hinh", 2, ". . . X . L .")
	d = _with_row(d, "dia_hinh", 5, ". Y . ~ . . .")
	d["thu_tu_dich"] = ["5,4", "1,0", "9,9"]
	assert_eq(_level(d).errors, _errors([
		'"kieu" là "giet", chỉ được "tieu_diet" hoặc "giu_ai"',
		'"dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"',
		'"dia_hinh" dòng 6, cột 2 (ô 1,5): ký hiệu lạ "Y"',
		'"thu_tu_dich" mục 3: ô 9,9 nằm ngoài bàn',
		'quân Nguyên "K" ở ô 5,0 không có trong "thu_tu_dich"',
	]))


func test_errors_give_no_data() -> void:
	var r: LoadResult = _level(_with(_valid_level(), "kieu", "giet"))
	assert_false(r.ok)
	assert_null(r.data)


# ---------- chi_so.json ----------

func test_valid_stats_load() -> void:
	var r: LoadResult = _stats(_valid_stats())
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var stats: Stats = r.data as Stats
	assert_not_null(stats)
	if stats == null:
		return
	assert_eq(stats.max_hp(UnitType.NGUYEN_KHOAI), 3)
	assert_eq(stats.move_range(UnitType.BO_BINH), 2)
	assert_eq(stats.max_hp(UnitType.CUNG_KY), 1)
	assert_eq(stats.value(UnitType.NGUYEN_KHOAI, "sat_thuong"), 2)
	assert_eq(stats.value(UnitType.PHAM_NGU_LAO, "tam_danh_xa"), 4)
	assert_eq(stats.value(UnitType.TRAN_KHANH_DU, "tam_keo"), 2)
	assert_eq(stats.value(UnitType.KY_BINH, "mau"), 2)


func test_stats_whole_float_is_accepted() -> void:
	var r: LoadResult = _stats(_with_stat("tuong", "nguyen_khoai", "mau", 3.0))
	assert_eq(r.errors, [] as Array[String])
	assert_eq((r.data as Stats).max_hp(UnitType.NGUYEN_KHOAI), 3)


func test_stats_missing_key() -> void:
	assert_eq(_stats(_without_stat("tuong", "nguyen_khoai", "tam_di")).errors,
		_stat_errors(['thiếu khóa "tuong.nguyen_khoai.tam_di"']))


func test_stats_missing_unit() -> void:
	var d: Dictionary = _valid_stats()
	(d["tuong"] as Dictionary).erase("tran_khanh_du")
	assert_eq(_stats(d).errors, _stat_errors(['thiếu khóa "tuong.tran_khanh_du"']))


func test_stats_missing_group() -> void:
	assert_eq(_stats(_without(_valid_stats(), "quan_nguyen")).errors,
		_stat_errors(['thiếu khóa "quan_nguyen"']))


func test_stats_group_wrong_type() -> void:
	assert_eq(_stats(_with(_valid_stats(), "tuong", 5)).errors,
		_stat_errors(['"tuong" phải là một object, đang là 5']))


func test_stats_unit_wrong_type() -> void:
	var d: Dictionary = _valid_stats()
	(d["quan_nguyen"] as Dictionary)["bo_binh"] = [3]
	assert_eq(_stats(d).errors, _stat_errors(['"quan_nguyen.bo_binh" phải là một object, đang là [3]']))


func test_stats_hp_must_be_at_least_one() -> void:
	assert_eq(_stats(_with_stat("tuong", "nguyen_khoai", "mau", 0)).errors,
		_stat_errors(['"tuong.nguyen_khoai.mau" phải là số nguyên từ 1 trở lên, đang là 0']))


func test_stats_move_may_be_zero_not_negative() -> void:
	assert_eq(_stats(_with_stat("quan_nguyen", "bo_binh", "tam_di", 0)).errors, [] as Array[String])
	assert_eq(_stats(_with_stat("quan_nguyen", "bo_binh", "tam_di", -1)).errors,
		_stat_errors(['"quan_nguyen.bo_binh.tam_di" phải là số nguyên từ 0 trở lên, đang là -1']))


func test_stats_damage_at_least_one() -> void:
	assert_eq(_stats(_with_stat("quan_nguyen", "bo_binh", "sat_thuong", 0)).errors,
		_stat_errors(['"quan_nguyen.bo_binh.sat_thuong" phải là số nguyên từ 1 trở lên, đang là 0']))


func test_stats_value_not_integer() -> void:
	assert_eq(_stats(_with_stat("tuong", "pham_ngu_lao", "sat_thuong", "1")).errors,
		_stat_errors(['"tuong.pham_ngu_lao.sat_thuong" phải là số nguyên từ 1 trở lên, đang là "1"']))
	assert_eq(_stats(_with_stat("tuong", "pham_ngu_lao", "sat_thuong", 1.5)).errors,
		_stat_errors(['"tuong.pham_ngu_lao.sat_thuong" phải là số nguyên từ 1 trở lên, đang là 1.5']))


## Lao luôn bay qua ô kề: tầm gần của Lão là 1 thì báo lỗi (tác giả chốt 2026-10-19, review 2.3).
func test_stats_lance_near_range_at_least_two() -> void:
	assert_eq(_stats(_with_stat("tuong", "pham_ngu_lao", "tam_danh_gan", 1)).errors,
		_stat_errors(['"tuong.pham_ngu_lao.tam_danh_gan" phải là số nguyên từ 2 trở lên, đang là 1']))


func test_stats_range_order() -> void:
	assert_eq(_stats(_with_stat("tuong", "pham_ngu_lao", "tam_danh_gan", 5)).errors,
		_stat_errors(['"tuong.pham_ngu_lao.tam_danh_gan" (5) lớn hơn "tuong.pham_ngu_lao.tam_danh_xa" (4)']))
	assert_eq(_stats(_with_stat("quan_nguyen", "cung_ky", "tam_ban_xa", 1)).errors,
		_stat_errors(['"quan_nguyen.cung_ky.tam_ban_gan" (2) lớn hơn "quan_nguyen.cung_ky.tam_ban_xa" (1)']))


func test_stats_typo_key_gives_warning_and_missing_error() -> void:
	var d: Dictionary = _without_stat("tuong", "nguyen_khoai", "tam_di")
	((d["tuong"] as Dictionary)["nguyen_khoai"] as Dictionary)["tam_dii"] = 3
	var r: LoadResult = _stats(d)
	assert_eq(r.errors, _stat_errors(['thiếu khóa "tuong.nguyen_khoai.tam_di"']))
	assert_eq(r.warnings, _stat_errors(['bỏ qua khóa lạ "tuong.nguyen_khoai.tam_dii"']))


func test_stats_unknown_keys_at_every_level_are_warnings() -> void:
	var d: Dictionary = _with(_valid_stats(), "ghi_chu", "x")
	(d["quan_nguyen"] as Dictionary)["voi_chien"] = {}
	var r: LoadResult = _stats(d)
	assert_true(r.ok)
	assert_eq(r.warnings, _stat_errors([
		'bỏ qua khóa lạ "ghi_chu"',
		'bỏ qua khóa lạ "quan_nguyen.voi_chien"',
	]))


func test_stats_many_errors_in_order() -> void:
	var d: Dictionary = _with_stat("tuong", "nguyen_khoai", "mau", 0)
	((d["tuong"] as Dictionary)["pham_ngu_lao"] as Dictionary).erase("tam_di")
	((d["quan_nguyen"] as Dictionary)["cung_ky"] as Dictionary)["sat_thuong"] = "mot"
	assert_eq(_stats(d).errors, _stat_errors([
		'"tuong.nguyen_khoai.mau" phải là số nguyên từ 1 trở lên, đang là 0',
		'thiếu khóa "tuong.pham_ngu_lao.tam_di"',
		'"quan_nguyen.cung_ky.sat_thuong" phải là số nguyên từ 1 trở lên, đang là "mot"',
	]))


func test_stats_json_errors() -> void:
	assert_eq(StatsLoader.parse_stats("[]", STATS_FILE).errors,
		_stat_errors(["nội dung phải là một object JSON"]))
	var r: LoadResult = StatsLoader.parse_stats('{"tuong": }', STATS_FILE)
	assert_eq(r.errors.size(), 1)
	assert_string_starts_with(r.errors[0], STATS_FILE + ", dòng 1: JSON sai cú pháp (")


func test_stats_missing_file() -> void:
	assert_eq(StatsLoader.load_stats("res://data/khong_co.json").errors,
		["data/khong_co.json: không đọc được file"] as Array[String])


# ---------- File thật tác giả sửa ----------

func test_real_stats_file_loads() -> void:
	var r: LoadResult = StatsLoader.load_stats("res://data/chi_so.json")
	assert_eq(r.errors, [] as Array[String], "data/chi_so.json không có lỗi")
	assert_true(r.ok)
	var stats: Stats = r.data as Stats
	assert_not_null(stats)
	if stats == null:
		return
	# Các bước tác giả tự test (Story 2.3) dựa vào tầm lao 2–4 và 1 sát thương.
	assert_eq(stats.damage(UnitType.PHAM_NGU_LAO), 1)
	assert_eq(stats.min_range(UnitType.PHAM_NGU_LAO), 2)
	assert_eq(stats.max_range(UnitType.PHAM_NGU_LAO), 4)


func test_real_level_1_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/tran_01.json")
	assert_eq(r.errors, [] as Array[String], "data/tran/tran_01.json không có lỗi")
	assert_true(r.ok)


func test_enemy_order_too_long_number_is_not_a_cell() -> void:
	var r: LoadResult = _level(_with(_valid_level(), "thu_tu_dich", ["99999999999999999999,4", "1,0", "5,0"]))
	assert_eq(r.errors, _errors([
		'"thu_tu_dich" mục 1: "99999999999999999999,4" không phải tọa độ "cot,hang"',
		'quân Nguyên "C" ở ô 5,4 không có trong "thu_tu_dich"',
	]))


func test_stats_huge_number_is_rejected() -> void:
	assert_eq(_stats(_with_stat("tuong", "nguyen_khoai", "mau", 1e20)).errors,
		_stat_errors(['"tuong.nguyen_khoai.mau" phải là số nguyên từ 1 trở lên, đang là 100000000000000000000.0']))


func test_real_three_generals_level_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/thu_ba_tuong.json")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	var generals: int = 0
	for p: LevelData.UnitPlacement in level.units:
		if UnitType.is_general(p.type):
			generals += 1
	assert_eq(generals, 3, "đủ 3 tướng")
	assert_eq(level.units.size() - generals, 4, "4 quân Nguyên")


func test_real_push_trial_level_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/thu_day.json")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	# Các bước tác giả tự test (Story 2.2) dựa vào đúng chỗ đứng này.
	var expected: Dictionary = {
		Vector2i(0, 3): UnitType.PHAM_NGU_LAO, Vector2i(1, 3): UnitType.NGUYEN_KHOAI,
		Vector2i(1, 5): UnitType.TRAN_KHANH_DU, Vector2i(2, 3): UnitType.BO_BINH,
		Vector2i(1, 4): UnitType.BO_BINH, Vector2i(2, 5): UnitType.BO_BINH,
	}
	var actual: Dictionary = {}
	for p: LevelData.UnitPlacement in level.units:
		actual[p.cell] = p.type
	assert_eq(actual, expected)
	assert_eq(level.terrain_at(Vector2i(3, 1)), Terrain.RIVER)
	assert_eq(level.terrain_at(Vector2i(3, 2)), Terrain.RIVER)
	assert_eq(level.terrain_at(Vector2i(3, 3)), Terrain.RIVER, "Bộ binh 2,3 bị đẩy sang Đông thì xuống sông")
	_assert_enemies_stay_on_begin(level)


func test_real_lance_trial_level_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/thu_lao.json")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	# Các bước tác giả tự test (Story 2.3) dựa vào đúng chỗ đứng này.
	var expected: Dictionary = {
		Vector2i(3, 3): UnitType.PHAM_NGU_LAO, Vector2i(3, 5): UnitType.NGUYEN_KHOAI,
		Vector2i(0, 0): UnitType.BO_BINH, Vector2i(3, 1): UnitType.BO_BINH, Vector2i(3, 2): UnitType.BO_BINH,
		Vector2i(6, 3): UnitType.KY_BINH, Vector2i(3, 6): UnitType.BO_BINH,
	}
	var actual: Dictionary = {}
	for p: LevelData.UnitPlacement in level.units:
		actual[p.cell] = p.type
	assert_eq(actual, expected)
	_assert_enemies_stay_on_begin(level)
	assert_eq(level.terrain_at(Vector2i(4, 3)), Terrain.RIVER, "lao bay qua sông tới Kỵ binh 6,3")
	assert_eq(level.terrain_at(Vector2i(5, 3)), Terrain.RIVER)


## Ba trận thử còn lại (Story 2.1, 1.9): bố cục đổi ở Story 2.6 để pha địch lúc mở trận không dời quân nào.
func test_other_real_trial_levels_keep_enemies_still_on_begin() -> void:
	for file: String in ["thu_ba_tuong", "thu_co_nho", "thu_day"]:
		var r: LoadResult = LevelLoader.load_level("res://data/tran/%s.json" % file)
		assert_eq(r.errors, [] as Array[String], file)
		assert_eq(r.warnings, [] as Array[String], file)
		var level: LevelData = r.data as LevelData
		assert_not_null(level, file)
		if level != null:
			_assert_enemies_stay_on_begin(level)


func test_real_pull_trial_level_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/thu_keo.json")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	# Các bước tác giả tự test (Story 2.4) dựa vào đúng chỗ đứng này.
	var expected: Dictionary = {
		Vector2i(3, 3): UnitType.TRAN_KHANH_DU, Vector2i(3, 4): UnitType.NGUYEN_KHOAI,
		Vector2i(3, 0): UnitType.BO_BINH, Vector2i(1, 3): UnitType.BO_BINH, Vector2i(2, 3): UnitType.BO_BINH,
		Vector2i(6, 3): UnitType.KY_BINH, Vector2i(3, 6): UnitType.BO_BINH, Vector2i(2, 0): UnitType.PHAM_NGU_LAO,
	}
	var actual: Dictionary = {}
	for p: LevelData.UnitPlacement in level.units:
		actual[p.cell] = p.type
	assert_eq(actual, expected)
	_assert_enemies_stay_on_begin(level)
	assert_eq(level.terrain_at(Vector2i(4, 3)), Terrain.RIVER, "Kỵ binh 6,3 bị kéo qua sông")
	assert_eq(level.terrain_at(Vector2i(5, 3)), Terrain.RIVER)
	assert_eq(level.size, Vector2i(7, 7))


func test_real_win_trial_level_loads() -> void:
	var r: LoadResult = LevelLoader.load_level("res://data/tran/thu_thang.json")
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var level: LevelData = r.data as LevelData
	assert_not_null(level)
	if level == null:
		return
	# Các bước tác giả tự test (Story 2.5) dựa vào đúng chỗ đứng này.
	var expected: Dictionary = {
		Vector2i(1, 2): UnitType.NGUYEN_KHOAI, Vector2i(6, 2): UnitType.PHAM_NGU_LAO,
		Vector2i(5, 5): UnitType.TRAN_KHANH_DU, Vector2i(2, 2): UnitType.BO_BINH, Vector2i(5, 2): UnitType.BO_BINH,
	}
	var actual: Dictionary = {}
	for p: LevelData.UnitPlacement in level.units:
		actual[p.cell] = p.type
	assert_eq(actual, expected)
	_assert_enemies_stay_on_begin(level)
	assert_eq(level.terrain_at(Vector2i(3, 2)), Terrain.RIVER, "Bộ binh 2,2 bị đẩy xuống sông")
	assert_eq(level.terrain_at(Vector2i(5, 4)), Terrain.RIVER, "Bộ binh 5,2 bị kéo xuống sông")
	assert_eq(level.size, Vector2i(7, 7))
	assert_eq(level.mission, LevelData.Mission.ELIMINATE)


## Chơi thật trên chính file trận: Khoái đẩy, Dư kéo; hết quân Nguyên thì thắng (chỉ số thật của chi_so.json).
func test_real_win_trial_level_can_be_won_in_one_turn() -> void:
	var level: LevelData = LevelLoader.load_level("res://data/tran/thu_thang.json").data as LevelData
	var stats: Stats = StatsLoader.load_stats("res://data/chi_so.json").data as Stats
	assert_not_null(level)
	assert_not_null(stats)
	if level == null or stats == null:
		return
	var controller: BattleController = BattleController.new()
	controller.start(level, stats)
	controller.begin()
	assert_eq(controller.snapshot().phase, BattleState.Phase.PLAYER, "trước: đang chơi")
	var first: Array[BattleEvent] = controller.submit(Command.attack(1, Vector2i(2, 2)))
	assert_eq(first.filter(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.VICTORY).size(), 0)
	assert_eq(controller.snapshot().phase, BattleState.Phase.PLAYER, "còn Bộ binh 5,2")
	var second: Array[BattleEvent] = controller.submit(Command.attack(3, Vector2i(5, 2)))
	assert_eq(second[second.size() - 1].type, BattleEvent.Type.VICTORY)
	assert_eq(controller.snapshot().phase, BattleState.Phase.WON)
	assert_eq(controller.snapshot().units.size(), 3, "còn ba tướng")
	assert_eq(controller.snapshot().validate(), [] as Array[String])


## Trận thử dựng sao cho pha địch chuẩn bị lúc mở trận (Story 2.6) không dời quân nào: các bước tác giả tự test
## của story cũ vẫn đúng (chỉ số thật của chi_so.json).
func _assert_enemies_stay_on_begin(level: LevelData) -> void:
	var stats: Stats = StatsLoader.load_stats("res://data/chi_so.json").data as Stats
	var controller: BattleController = BattleController.new()
	controller.start(level, stats)
	var before: Array[String] = BoardFixture.picture(controller.snapshot())
	controller.begin()
	assert_eq(BoardFixture.picture(controller.snapshot()), before, "mở trận: quân Nguyên đứng yên")
