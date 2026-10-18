extends GutTest
## Bộ nạp kịch bản luật (định dạng, câu lỗi nguyên văn) và bộ chạy (so bàn sau theo ô).
## Chỉ số dùng số tự đặt trong test, không dựa vào data/chi_so.json (tác giả được sửa).

const ROOT: String = "user://test_kich_ban"
const PATH: String = ROOT + "/di_chuyen/thu.json"
const F: String = "user://test_kich_ban/di_chuyen/thu.json"

const EMPTY_ROW: String = ". . . . . . ."
const RIVER_TERRAIN: Array[String] = [
	". . . ~ . . .",
	". . . ~ . . .",
	". . . ~ . . .",
	". . . . . . .",
	". . . ~ . . .",
	". . . ~ . . .",
	". . . . . . .",
]


func after_each() -> void:
	_remove_tree(ROOT)


func _remove_tree(dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return
	for name: String in dir.get_files():
		DirAccess.remove_absolute(dir_path.path_join(name))
	for name: String in dir.get_directories():
		_remove_tree(dir_path.path_join(name))
	DirAccess.remove_absolute(dir_path)


func _stats() -> Stats:
	var values: Dictionary = {}
	for type: int in [UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU, UnitType.BO_BINH]:
		values[type] = {"mau": 3, "tam_di": 3}
	values[UnitType.KY_BINH] = {"mau": 2, "tam_di": 3}
	values[UnitType.CUNG_KY] = {"mau": 1, "tam_di": 3}
	return Stats.new(values)


## 7 dòng, dòng `row` thay bằng `line`.
func _rows(row: int = -1, line: String = "") -> Array[String]:
	var rows: Array[String] = []
	for r: int in range(7):
		rows.append(line if r == row else EMPTY_ROW)
	return rows


## Lớp quân: Nguyễn Khoái ở 0,6, Bộ binh ở 5,4.
func _units(general_row: String = "1 . . . . . .") -> Array[String]:
	var rows: Array[String] = _rows(6, general_row)
	rows[4] = ". . . . . B ."
	return rows


## Kịch bản hợp lệ: không có lệnh, bàn sau giống bàn trước.
func _valid() -> Dictionary:
	return {
		"phien_ban_dinh_dang": 1,
		"mo_ta": "Không làm gì, bàn giữ nguyên.",
		"da_duyet": false,
		"truoc": {"dia_hinh": RIVER_TERRAIN.duplicate(), "quan": _units()},
		"hanh_dong": [],
		"sau": {"dia_hinh": RIVER_TERRAIN.duplicate(), "quan": _units()},
	}


func _parse(d: Dictionary) -> LoadResult:
	return ScenarioLoader.parse_scenario(JSON.stringify(d), PATH, ROOT, _stats())


func _errors(d: Dictionary) -> Array[String]:
	return _parse(d).errors


func _scenario(d: Dictionary) -> ScenarioData:
	var r: LoadResult = _parse(d)
	assert_eq(r.errors, [] as Array[String], "kịch bản nạp được")
	return r.data as ScenarioData


func _write(path: String, text: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


# ---------- Ca đúng ----------

func test_valid_scenario_loads() -> void:
	var d: Dictionary = _valid()
	d["da_duyet"] = true
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "3,6"}, {"lenh": "ket_thuc_luot"}]
	var r: LoadResult = _parse(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var s: ScenarioData = r.data as ScenarioData
	if s == null:
		return
	assert_eq(s.id, "di_chuyen/thu.json")
	assert_eq(s.group, "di_chuyen")
	assert_eq(s.path, PATH)
	assert_true(s.approved)
	assert_eq(s.description, "Không làm gì, bàn giữ nguyên.")
	assert_eq(s.steps.size(), 2)
	assert_eq(s.steps[0].kind, "di")
	assert_eq(s.steps[0].general, UnitType.NGUYEN_KHOAI)
	assert_eq(s.steps[0].cell, Vector2i(3, 6))
	assert_eq(s.steps[1].kind, "ket_thuc_luot")
	assert_eq(s.steps[1].general, -1)
	assert_eq(s.steps[1].cell, ScenarioData.NO_CELL)
	assert_eq(s.before.terrain[3], Terrain.RIVER)
	assert_eq(s.after_units.size(), 2)


func test_hp_overrides_one_unit_and_others_are_full() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["mau"] = {"5,4": 1}
	d["sau"]["mau"] = {"0,6": 2}
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	var state: BattleState = BattleState.from_level(s.before, _stats())
	assert_eq(state.unit_by_id(1).hp, 3, "tướng đầy máu")
	assert_eq(state.unit_by_id(101).hp, 1, "Bộ binh theo mau")
	# after_units theo thứ tự đọc bàn: 5,4 rồi 0,6.
	assert_eq(s.after_units[0].cell, Vector2i(5, 4))
	assert_eq(s.after_units[0].hp, 3)
	assert_eq(s.after_units[1].cell, Vector2i(0, 6))
	assert_eq(s.after_units[1].hp, 2)


func test_enemy_ids_follow_reading_order_without_thu_tu_dich() -> void:
	var d: Dictionary = _valid()
	var units: Array[String] = _rows(6, "1 . . . . . .")
	units[0] = ". . . . . K ."
	units[2] = ". C . . . . ."
	units[4] = "B . . . . . ."
	d["truoc"]["quan"] = units
	d["sau"]["quan"] = units.duplicate()
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	var state: BattleState = BattleState.from_level(s.before, _stats())
	assert_eq(state.unit_by_id(101).cell, Vector2i(5, 0))
	assert_eq(state.unit_by_id(102).cell, Vector2i(1, 2))
	assert_eq(state.unit_by_id(103).cell, Vector2i(0, 4))


func test_enemy_ids_follow_thu_tu_dich_when_given() -> void:
	var d: Dictionary = _valid()
	var units: Array[String] = _rows(6, "1 . . . . . .")
	units[0] = ". . . . . K ."
	units[4] = "B . . . . . ."
	d["truoc"]["quan"] = units
	d["truoc"]["thu_tu_dich"] = ["0,4", "5,0"]
	d["sau"]["quan"] = units.duplicate()
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	var state: BattleState = BattleState.from_level(s.before, _stats())
	assert_eq(state.unit_by_id(101).cell, Vector2i(0, 4))
	assert_eq(state.unit_by_id(102).cell, Vector2i(5, 0))


func test_after_may_be_empty() -> void:
	var d: Dictionary = _valid()
	d["sau"]["quan"] = _rows()
	assert_not_null(_scenario(d))


func test_unknown_keys_are_warnings_at_every_level() -> void:
	var d: Dictionary = _valid()
	d["ghi_chu"] = 1
	d["truoc"]["ghi_chu"] = 1
	d["sau"]["x"] = 1
	d["hanh_dong"] = [{"lenh": "huy", "tuong": "1"}]
	var r: LoadResult = _parse(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [
		F + ': bỏ qua khóa lạ "ghi_chu"',
		F + ': bỏ qua khóa lạ "truoc.ghi_chu"',
		F + ': "hanh_dong" mục 1 (huy): bỏ qua khóa lạ "tuong"',
		F + ': bỏ qua khóa lạ "sau.x"',
	] as Array[String])


func test_file_in_root_has_no_group() -> void:
	var r: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(_valid()), ROOT + "/le.json", ROOT, _stats())
	assert_eq((r.data as ScenarioData).group, "")
	assert_eq((r.data as ScenarioData).id, "le.json")


# ---------- Câu lỗi ----------

func test_missing_root_keys() -> void:
	assert_eq(_errors({}), [
		F + ': thiếu khóa "phien_ban_dinh_dang"',
		F + ': thiếu khóa "mo_ta"',
		F + ': thiếu khóa "da_duyet"',
		F + ': thiếu khóa "truoc"',
		F + ': thiếu khóa "hanh_dong"',
		F + ': thiếu khóa "sau"',
	] as Array[String])


func test_wrong_version() -> void:
	var d: Dictionary = _valid()
	d["phien_ban_dinh_dang"] = 2
	assert_eq(_errors(d), [F + ': "phien_ban_dinh_dang" là 2, game chỉ đọc được bản 1'] as Array[String])


func test_empty_description() -> void:
	var d: Dictionary = _valid()
	d["mo_ta"] = "   "
	assert_eq(_errors(d), [F + ': "mo_ta" không được để trống'] as Array[String])


func test_description_must_be_text() -> void:
	var d: Dictionary = _valid()
	d["mo_ta"] = 3
	assert_eq(_errors(d), [F + ': "mo_ta" phải là một chuỗi, đang là 3'] as Array[String])


func test_approved_must_be_bool() -> void:
	for value: Variant in ["true", 1]:
		var d: Dictionary = _valid()
		d["da_duyet"] = value
		assert_eq(_errors(d), [F + ': "da_duyet" phải là true hoặc false, đang là %s' % JSON.stringify(value)]
			as Array[String])


func test_sections_must_be_objects_and_steps_a_list() -> void:
	var d: Dictionary = _valid()
	d["truoc"] = []
	d["hanh_dong"] = {}
	d["sau"] = "x"
	assert_eq(_errors(d), [
		F + ': "truoc" phải là một object, đang là []',
		F + ': "hanh_dong" phải là một danh sách, đang là {}',
		F + ': "sau" phải là một object, đang là "x"',
	] as Array[String])


func test_layer_errors_name_the_section() -> void:
	var d: Dictionary = _valid()
	var terrain: Array[String] = RIVER_TERRAIN.duplicate()
	terrain[0] = "X . . ~ . . ."
	d["truoc"]["dia_hinh"] = terrain
	d["sau"].erase("quan")
	assert_eq(_errors(d), [
		F + ': "truoc.dia_hinh" dòng 1, cột 1 (ô 0,0): ký hiệu lạ "X"',
		F + ': thiếu khóa "sau.quan"',
	] as Array[String])


func test_unit_on_blocked_cell_and_duplicate_general() -> void:
	var d: Dictionary = _valid()
	d["sau"]["quan"] = _units("1 . . 1 . . .")
	var units: Array[String] = _units()
	units[0] = ". . . 2 . . ."
	d["truoc"]["quan"] = units
	assert_eq(_errors(d), [
		F + ': "truoc.quan" dòng 1, cột 4 (ô 3,0): quân "2" đứng trên ô không đi vào được "~"',
		F + ': "sau.quan" dòng 7, cột 4 (ô 3,6): tướng "1" đã có ở ô 0,6',
	] as Array[String])


func test_before_needs_a_unit() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["quan"] = _rows()
	assert_eq(_errors(d), [F + ': "truoc.quan" không có quân nào'] as Array[String])


## JSON.stringify sắp khóa theo chữ cái, nên lỗi theo thứ tự "4,4", "9,9", "abc".
func test_hp_errors() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["mau"] = {"4,4": 1, "abc": 1, "9,9": 1}
	d["sau"]["mau"] = {"0,6": 0, "5,4": 4}
	assert_eq(_errors(d), [
		F + ': "truoc.mau" ô 4,4 không có quân',
		F + ': "truoc.mau" ô 9,9 nằm ngoài bàn',
		F + ': "truoc.mau" có khóa "abc" không phải tọa độ "cot,hang"',
		F + ': "sau.mau" ô 0,6: máu phải là số nguyên từ 1 tới 3, đang là 0',
		F + ': "sau.mau" ô 5,4: máu phải là số nguyên từ 1 tới 3, đang là 4',
	] as Array[String])


func test_hp_same_cell_written_twice() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["mau"] = {"0,6": 1, "00,6": 2}
	assert_eq(_errors(d), [F + ': "truoc.mau" ghi ô 0,6 hai lần ("0,6" và "00,6")'] as Array[String])


func test_hp_must_be_object() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["mau"] = [1]
	assert_eq(_errors(d), [F + ': "truoc.mau" phải là một object, đang là [1]'] as Array[String])


func test_thu_tu_dich_errors_name_the_section() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["thu_tu_dich"] = ["0,6"]
	assert_eq(_errors(d), [
		F + ': "truoc.thu_tu_dich" mục 1: ô 0,6 không có quân Nguyên',
		F + ': quân Nguyên "B" ở ô 5,4 không có trong "truoc.thu_tu_dich"',
	] as Array[String])


func test_step_errors() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		"di",
		{"tuong": "1"},
		{"lenh": "chay"},
		{"lenh": "di", "tuong": "1"},
		{"lenh": "di", "tuong": "4", "o": "1,1"},
		{"lenh": "danh", "tuong": "3", "o": "1,1"},
		{"lenh": "di", "tuong": "1", "o": "9,9"},
		{"lenh": "di", "tuong": 1, "o": 5},
	]
	assert_eq(_errors(d), [
		F + ': "hanh_dong" mục 1 phải là một object, đang là "di"',
		F + ': "hanh_dong" mục 2: thiếu khóa "lenh"',
		F + ': "hanh_dong" mục 3: lệnh lạ "chay", chỉ được "di", "danh", "huy", "ket_thuc_luot"',
		F + ': "hanh_dong" mục 4 (di): thiếu khóa "o"',
		F + ': "hanh_dong" mục 5 (di): "tuong" là "4", chỉ được "1", "2", "3"',
		F + ': "hanh_dong" mục 6 (danh): tướng "3" không có trong "truoc.quan"',
		F + ': "hanh_dong" mục 7 (di): "o" là "9,9", không phải ô trong bàn',
		F + ': "hanh_dong" mục 8 (di): "tuong" là 1, chỉ được "1", "2", "3"',
		F + ': "hanh_dong" mục 8 (di): "o" là 5, không phải ô trong bàn',
	] as Array[String])


func test_step_reject_code_is_read() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "khong_toi_duoc"},
		{"lenh": "di", "tuong": "1", "o": "1,6"},
	]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	assert_eq(s.steps[0].reject, "khong_toi_duoc")
	assert_eq(s.steps[1].reject, "", "không ghi là lệnh phải chạy được")


func test_step_reject_code_errors() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "bi_chan"},
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": true},
		{"lenh": "huy", "tu_choi": "khong_toi_duoc"},
	]
	var r: LoadResult = _parse(d)
	var codes: String = '"khong_co_quan", "khong_phai_tuong", "da_dung_o_do", "khong_toi_duoc"'
	assert_eq(r.errors, [
		F + ': "hanh_dong" mục 1 (di): "tu_choi" là "bi_chan", chỉ được ' + codes,
		F + ': "hanh_dong" mục 2 (di): "tu_choi" là true, chỉ được ' + codes,
	] as Array[String])
	assert_eq(r.warnings, [F + ': "hanh_dong" mục 3 (huy): bỏ qua khóa lạ "tu_choi"'] as Array[String])


func test_many_errors_are_listed_together() -> void:
	var d: Dictionary = _valid()
	d.erase("mo_ta")
	d["truoc"]["mau"] = {"5,4": 9}
	d["hanh_dong"] = [{"lenh": "x"}]
	d["sau"]["dia_hinh"] = _rows(0, ". . .")
	assert_eq(_errors(d), [
		F + ': thiếu khóa "mo_ta"',
		F + ': "truoc.mau" ô 5,4: máu phải là số nguyên từ 1 tới 3, đang là 9',
		F + ': "hanh_dong" mục 1: lệnh lạ "x", chỉ được "di", "danh", "huy", "ket_thuc_luot"',
		F + ': "sau.dia_hinh" dòng 1: có 3 ô, cần 7',
	] as Array[String])


func test_missing_file() -> void:
	var r: LoadResult = ScenarioLoader.load_scenario(ROOT + "/khong_co.json", ROOT, _stats())
	assert_eq(r.errors, ["user://test_kich_ban/khong_co.json: không đọc được file"] as Array[String])


func test_empty_file() -> void:
	_write(PATH, "")
	assert_eq(ScenarioLoader.load_scenario(PATH, ROOT, _stats()).errors, [F + ": file rỗng"] as Array[String])


# ---------- list_files ----------

func test_list_files_sorted_recursive_json_only() -> void:
	_write(ROOT + "/va_cham/b.json", "{}")
	_write(ROOT + "/di_chuyen/z.json", "{}")
	_write(ROOT + "/di_chuyen/a.json", "{}")
	_write(ROOT + "/di_chuyen/ghi_chu.txt", "x")
	_write(ROOT + "/goc.json", "{}")
	assert_eq(ScenarioLoader.list_files(ROOT), [
		ROOT + "/di_chuyen/a.json",
		ROOT + "/di_chuyen/z.json",
		ROOT + "/goc.json",
		ROOT + "/va_cham/b.json",
	] as Array[String])


func test_list_files_of_missing_dir_is_empty() -> void:
	assert_eq(ScenarioLoader.list_files(ROOT + "/khong_co"), [] as Array[String])


# ---------- Bộ chạy ----------

func _run(d: Dictionary) -> ScenarioRunner.ScenarioResult:
	return ScenarioRunner.run(_scenario(d), _stats())


func test_runner_passes_when_after_equals_before() -> void:
	var result: ScenarioRunner.ScenarioResult = _run(_valid())
	assert_true(result.passed)
	assert_eq(result.problems, [] as Array[String])


func test_runner_reports_hp_difference() -> void:
	var d: Dictionary = _valid()
	d["sau"]["mau"] = {"5,4": 1}
	assert_eq(_run(d).problems, ["sau: ô 5,4 B mong đợi 1 máu, thực tế 3 máu"] as Array[String])


func test_runner_reports_moved_unit_as_missing_and_extra() -> void:
	var d: Dictionary = _valid()
	d["sau"]["quan"] = _units(". . . 1 . . .")
	assert_eq(_run(d).problems, [
		"sau: ô 0,6 mong đợi trống, thực tế 1 (Nguyễn Khoái, 3 máu)",
		"sau: ô 3,6 mong đợi 1 (Nguyễn Khoái, 3 máu), thực tế trống",
	] as Array[String])


func test_runner_reports_wrong_type() -> void:
	var d: Dictionary = _valid()
	var units: Array[String] = _units()
	units[4] = ". . . . . K ."
	d["sau"]["quan"] = units
	assert_eq(_run(d).problems, ["sau: ô 5,4 mong đợi K (Kỵ binh, 2 máu), thực tế B (Bộ binh, 3 máu)"] as Array[String])


func test_runner_reports_terrain_difference() -> void:
	var d: Dictionary = _valid()
	var terrain: Array[String] = RIVER_TERRAIN.duplicate()
	terrain[2] = ". . . ~ . L ."
	d["sau"]["dia_hinh"] = terrain
	assert_eq(_run(d).problems, ['sau: ô 5,2 mong đợi "L" (kho lương), thực tế "." (đất trống)'] as Array[String])


## Thêm quân hay địa hình vào BoardText thì phải thêm tên ở bộ chạy và công cụ duyệt.
func test_every_board_symbol_has_a_name() -> void:
	for symbol: String in BoardText.UNIT_SYMBOLS:
		var type: int = BoardText.UNIT_SYMBOLS[symbol] as int
		if type == BoardText.NO_UNIT:
			continue
		assert_true(ScenarioRunner.UNIT_NAMES.has(type), "bộ chạy có tên quân " + symbol)
		assert_true(ScenarioViewer.UNIT_NAME_KEYS.has(type), "công cụ duyệt có tên quân " + symbol)
		assert_eq(ScenarioRunner.unit_symbol(type), symbol)
	for symbol: String in BoardText.TERRAIN_SYMBOLS:
		var kind: int = BoardText.TERRAIN_SYMBOLS[symbol] as int
		assert_true(ScenarioRunner.TERRAIN_NAMES.has(kind), "bộ chạy có tên địa hình " + symbol)
		assert_eq(ScenarioRunner.terrain_symbol(kind), symbol)


func test_runner_stops_at_command_without_rule() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "huy"}, {"lenh": "ket_thuc_luot"}]
	d["sau"]["mau"] = {"5,4": 1}
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, ['bước 1: lệnh "huy" chưa có luật (Story 1.5)'] as Array[String],
		"dừng ở bước 1, không so bàn sau")


func test_runner_moves_general() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "2,5"}]
	d["sau"]["quan"] = _units()
	d["sau"]["quan"][6] = EMPTY_ROW
	d["sau"]["quan"][5] = ". . 1 . . . ."
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_eq(result.problems, [] as Array[String])


func test_runner_reports_wrong_destination() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "2,5"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_eq(result.problems, [
		"sau: ô 2,5 mong đợi trống, thực tế 1 (Nguyễn Khoái, 3 máu)",
		"sau: ô 0,6 mong đợi 1 (Nguyễn Khoái, 3 máu), thực tế trống",
	] as Array[String], "đi được thì bàn đổi; bàn sau ghi giữ nguyên là sai")


## Lệnh bị luật từ chối đúng lý do kịch bản ghi: bàn giữ nguyên, kịch bản ghi giữ nguyên thì đạt.
func test_runner_rejected_move_keeps_board() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "khong_toi_duoc"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_true(result.passed)
	assert_eq(result.problems, [] as Array[String])


func test_runner_rejection_not_written_fails() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "4,6"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, [
		'bước 1: luật từ chối ("khong_toi_duoc": quân 1 không đi tới được ô 4,6) mà kịch bản không ghi "tu_choi"',
	] as Array[String])


## Gõ nhầm ô đích thành ô tướng đang đứng: bàn vẫn giữ nguyên, nhưng sai lý do nên trượt.
func test_runner_wrong_rejection_fails() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "0,6", "tu_choi": "khong_toi_duoc"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, [
		'bước 1: luật từ chối vì "da_dung_o_do" (quân 1 đã đứng ở ô 0,6), kịch bản ghi "tu_choi": "khong_toi_duoc"',
	] as Array[String])


func test_runner_expected_rejection_but_move_runs_fails() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "2,5", "tu_choi": "khong_toi_duoc"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, ['bước 1: kịch bản ghi "tu_choi": "khong_toi_duoc" nhưng luật cho chạy'] as Array[String])


func test_runner_and_loader_know_the_same_reject_codes() -> void:
	assert_eq(ScenarioRunner.REJECT_EVENTS.keys(), ScenarioLoader.REJECT_CODES.keys())
	assert_eq(ScenarioRunner.REJECT_EVENTS.size(), BattleEvent.Reject.size() - 1, "mọi lý do (trừ NONE) đều có mã")


func test_runner_general_missing_from_board() -> void:
	var d: Dictionary = _valid()
	var scenario: ScenarioData = _scenario(d)
	scenario.steps.append(ScenarioData.ScenarioStep.new("di", UnitType.PHAM_NGU_LAO, Vector2i(1, 1)))
	var result: ScenarioRunner.ScenarioResult = ScenarioRunner.run(scenario, _stats())
	assert_eq(result.problems, ['bước 1: tướng "2" không còn trên bàn'] as Array[String])


# ---------- Công cụ duyệt ----------

func test_viewer_renders_boards_side_by_side_with_notes() -> void:
	var d: Dictionary = _valid()
	var terrain: Array[String] = RIVER_TERRAIN.duplicate()
	terrain[6] = "^ . . . . . ."
	d["truoc"]["dia_hinh"] = terrain
	d["sau"]["dia_hinh"] = terrain.duplicate()
	d["truoc"]["mau"] = {"5,4": 1}
	d["sau"]["quan"] = _units(". . . 1 . . .")
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "3,6"}]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	var lines: PackedStringArray = ScenarioViewer.render(s, _stats()).split("\n")
	assert_eq(lines[0], "━━━ di_chuyen/thu.json  [chưa duyệt]")
	assert_eq(lines[1], "Không làm gì, bàn giữ nguyên.")
	assert_has(lines, "  1. %s đi tới 3,6" % tr("scenario.unit.nguyen_khoai"))
	assert_has(lines, "      TRƯỚC                   SAU")
	assert_has(lines, "   6  1 . . . . . .        6  ^ . . 1 . . .", "quân che hầm chông ở bàn trước")
	assert_has(lines, "  Máu:  5,4 %s 1/3" % tr("scenario.unit.bo_binh"), "chỉ bàn trước có máu không đầy")
	assert_has(lines, "  Dưới quân: 0,6 ^ (%s)" % tr("scenario.terrain.spikes"))


func test_viewer_shows_expected_rejection() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "khong_toi_duoc"}]
	var lines: PackedStringArray = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	assert_has(lines, "  1. %s đi tới 4,6 → bị từ chối: không đi tới được ô đó" % tr("scenario.unit.nguyen_khoai"))


## Như mẫu "Cách in": Máu bên phải bắt đầu ở cột 28.
func test_viewer_puts_after_notes_under_after_board() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["mau"] = {"5,4": 1}
	d["sau"]["mau"] = {"5,4": 1}
	var lines: PackedStringArray = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	var bo_binh: String = tr("scenario.unit.bo_binh")
	assert_has(lines, ("  Máu:  5,4 %s 1/3" % bo_binh).rpad(26) + "  Máu:  5,4 %s 1/3" % bo_binh)


## Ghi chú bàn trước dài: ghi chú bàn sau cùng lùi ra, vẫn thẳng cột với nhau, và cùng loại cùng dòng.
func test_viewer_keeps_after_notes_aligned_when_before_notes_are_long() -> void:
	var d: Dictionary = _valid()
	var terrain: Array[String] = RIVER_TERRAIN.duplicate()
	terrain[6] = "^ . . . . . ."
	d["truoc"]["dia_hinh"] = terrain
	d["truoc"]["mau"] = {"0,6": 2}
	d["sau"]["mau"] = {"5,4": 1}
	var lines: PackedStringArray = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	var hp_line: String = ""
	var under_line: String = ""
	for line: String in lines:
		if line.begins_with("  Máu:"):
			hp_line = line
		elif line.begins_with("  Dưới quân:"):
			under_line = line
	var left_hp: String = "  Máu:  0,6 %s 2/3" % tr("scenario.unit.nguyen_khoai")
	var left_under: String = "  Dưới quân: 0,6 ^ (%s)" % tr("scenario.terrain.spikes")
	var width: int = maxi(26, maxi(left_hp.length(), left_under.length()) + 2)
	assert_eq(hp_line, left_hp.rpad(width) + "  Máu:  5,4 %s 1/3" % tr("scenario.unit.bo_binh"))
	assert_eq(under_line, left_under, "bàn sau không có quân trên hầm chông nên bên phải trống")
