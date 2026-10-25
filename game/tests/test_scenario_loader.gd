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
	values[UnitType.CUNG_KY] = {"mau": 1, "tam_di": 3, "tam_ban_gan": 2, "tam_ban_xa": 3}
	return Stats.new(values)


## Bàn RIVER_TERRAIN toàn đất trống, dòng `row` thay bằng `line`.
func _rows(row: int = -1, line: String = "") -> Array[String]:
	var rows: Array[String] = []
	for r: int in range(RIVER_TERRAIN.size()):
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


func test_giu_ai_mission_scenario_loads() -> void:
	var d: Dictionary = _valid()
	(d["truoc"] as Dictionary)["kieu"] = "giu_ai"
	var sc: ScenarioData = _scenario(d)
	assert_eq(sc.before.mission, LevelData.Mission.HOLD_PASS)
	assert_eq(sc.before.max_rounds, 5)


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
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "sai_ma"},
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": true},
		{"lenh": "ket_thuc_luot", "tu_choi": "khong_toi_duoc"},
	]
	var r: LoadResult = _parse(d)
	var codes: String = '"khong_co_quan", "khong_phai_tuong", "da_dung_o_do", "khong_toi_duoc", ' \
		+ '"da_di_roi", "khong_con_nuoc_di", "da_danh_roi", "khong_ke", "khong_co_dich", "bi_chan", ' \
		+ '"ngoai_tam", "tran_da_het"'
	assert_eq(r.errors, [
		F + ': "hanh_dong" mục 1 (di): "tu_choi" là "sai_ma", chỉ được ' + codes,
		F + ': "hanh_dong" mục 2 (di): "tu_choi" là true, chỉ được ' + codes,
	] as Array[String])
	assert_eq(r.warnings, [F + ': "hanh_dong" mục 3 (ket_thuc_luot): bỏ qua khóa lạ "tu_choi"'] as Array[String])


func test_after_round_and_moved_are_read() -> void:
	var d: Dictionary = _valid()
	d["sau"]["hiep"] = 2
	d["sau"]["da_di"] = ["1"]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	assert_eq(s.after_round, 2)
	assert_true(s.checks_moved)
	assert_eq(s.after_moved, [UnitType.NGUYEN_KHOAI] as Array[int])


func test_after_round_and_moved_are_optional() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_eq(s.after_round, 0, "không ghi hiệp thì không kiểm")
	assert_false(s.checks_moved, "không ghi da_di thì không kiểm")
	var d: Dictionary = _valid()
	d["sau"]["da_di"] = []
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_moved, "[] là kiểm: chưa tướng nào đi")
	assert_eq(s.after_moved, [] as Array[int])


func test_after_round_and_moved_errors() -> void:
	var d: Dictionary = _valid()
	d["sau"]["hiep"] = 0
	d["sau"]["da_di"] = ["1", "1", "2", "B", 1]
	assert_eq(_errors(d), [
		F + ': "sau.hiep" phải là số nguyên từ 1 trở lên, đang là 0',
		F + ': "sau.da_di" ghi tướng "1" hai lần',
		F + ': "sau.da_di" có tướng "2" không có trong "sau.quan"',
		F + ': "sau.da_di" có "B", chỉ được "1", "2", "3"',
		F + ': "sau.da_di" có 1, chỉ được "1", "2", "3"',
	] as Array[String])
	d["sau"]["hiep"] = "2"
	d["sau"]["da_di"] = "1"
	assert_eq(_errors(d), [
		F + ': "sau.hiep" phải là số nguyên từ 1 trở lên, đang là "2"',
		F + ': "sau.da_di" phải là một danh sách, đang là "1"',
	] as Array[String])


func test_after_attacked_is_read() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_false(s.checks_attacked, "không ghi da_danh thì không kiểm")
	var d: Dictionary = _valid()
	d["sau"]["da_danh"] = ["1"]
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_attacked)
	assert_eq(s.after_attacked, [UnitType.NGUYEN_KHOAI] as Array[int])
	d["sau"]["da_danh"] = []
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_attacked, "[] là kiểm: chưa tướng nào đánh")
	assert_eq(s.after_attacked, [] as Array[int])


func test_after_attacked_errors() -> void:
	var d: Dictionary = _valid()
	d["sau"]["da_danh"] = ["1", "1", "2", "B"]
	assert_eq(_errors(d), [
		F + ': "sau.da_danh" ghi tướng "1" hai lần',
		F + ': "sau.da_danh" có tướng "2" không có trong "sau.quan"',
		F + ': "sau.da_danh" có "B", chỉ được "1", "2", "3"',
	] as Array[String])
	d["sau"]["da_danh"] = "1"
	assert_eq(_errors(d), [F + ': "sau.da_danh" phải là một danh sách, đang là "1"'] as Array[String])
	d = _valid()
	d["truoc"]["da_danh"] = []
	assert_eq(_parse(d).warnings, [F + ': bỏ qua khóa lạ "truoc.da_danh"'] as Array[String])


func test_after_outcome_is_read() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_eq(s.after_outcome, "", "không ghi ket_qua thì không kiểm")
	for outcome: String in ["dang_choi", "thang", "thua"]:
		var d: Dictionary = _valid()
		d["sau"]["ket_qua"] = outcome
		s = _scenario(d)
		if s == null:
			return
		assert_eq(s.after_outcome, outcome)


func test_after_outcome_errors() -> void:
	var d: Dictionary = _valid()
	d["sau"]["ket_qua"] = "hoa"
	assert_eq(_errors(d), [F + ': "sau.ket_qua" là "hoa", chỉ được "dang_choi", "thang", "thua"'] as Array[String])
	d["sau"]["ket_qua"] = 1
	assert_eq(_errors(d), [F + ': "sau.ket_qua" là 1, chỉ được "dang_choi", "thang", "thua"'] as Array[String])
	d = _valid()
	d["truoc"]["ket_qua"] = "thang"
	assert_eq(_parse(d).warnings, [F + ': bỏ qua khóa lạ "truoc.ket_qua"'] as Array[String])


## "tran_da_het" nhận ở đi, đánh, hủy (lệnh kết thúc lượt vẫn không có "tu_choi", như trước).
func test_battle_over_reject_fits_every_command() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "di", "tuong": "1", "o": "2,5", "tu_choi": "tran_da_het"},
		{"lenh": "danh", "tuong": "1", "o": "1,6", "tu_choi": "tran_da_het"},
		{"lenh": "huy", "tu_choi": "tran_da_het"},
	]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	for step: ScenarioData.ScenarioStep in s.steps:
		assert_eq(step.reject, "tran_da_het", step.kind)


func test_runner_compares_outcome_only_when_written() -> void:
	var d: Dictionary = _valid()
	assert_true(_run(d).passed, "không ghi ket_qua thì không kiểm")
	d["sau"]["ket_qua"] = "dang_choi"
	assert_true(_run(d).passed, "chưa có quân gục: đang chơi")
	d["sau"]["ket_qua"] = "thang"
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, ['sau: mong đợi kết cục "thang", thực tế "dang_choi"'] as Array[String])


func test_before_ignores_round_and_moved() -> void:
	var d: Dictionary = _valid()
	d["truoc"]["hiep"] = 2
	var r: LoadResult = _parse(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [F + ': bỏ qua khóa lạ "truoc.hiep"'] as Array[String])


## Mã có thật nhưng lệnh đó không bao giờ bị từ chối vì nó: kịch bản không bao giờ đạt, báo ngay lúc nạp.
func test_step_reject_code_must_fit_command() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "huy", "tu_choi": "khong_toi_duoc"},
		{"lenh": "di", "tuong": "1", "o": "4,6", "tu_choi": "khong_con_nuoc_di"},
	]
	assert_eq(_parse(d).errors, [
		F + ': "hanh_dong" mục 1 (huy): "tu_choi" là "khong_toi_duoc", lệnh "huy" chỉ bị từ chối vì '
			+ '"khong_con_nuoc_di", "tran_da_het"',
		F + ': "hanh_dong" mục 2 (di): "tu_choi" là "khong_con_nuoc_di", lệnh "di" chỉ bị từ chối vì '
			+ '"khong_co_quan", "khong_phai_tuong", "da_danh_roi", "da_di_roi", "da_dung_o_do", "khong_toi_duoc", "tran_da_het"',
	] as Array[String])


## Lệnh đánh chỉ nhận mã của luật đánh; lệnh đi nhận thêm "da_danh_roi" (đã đánh thì không đi được).
func test_attack_reject_codes_fit_command() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "danh", "tuong": "1", "o": "1,6", "tu_choi": "khong_co_dich"},
		{"lenh": "danh", "tuong": "1", "o": "2,6", "tu_choi": "khong_ke"},
		{"lenh": "danh", "tuong": "1", "o": "1,6", "tu_choi": "da_danh_roi"},
		{"lenh": "di", "tuong": "1", "o": "1,6", "tu_choi": "da_danh_roi"},
		{"lenh": "danh", "tuong": "1", "o": "1,6", "tu_choi": "ngoai_tam"},
	]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	assert_eq(s.steps[0].reject, "khong_co_dich")
	assert_eq(s.steps[3].reject, "da_danh_roi")
	assert_eq(s.steps[4].reject, "ngoai_tam")
	d["hanh_dong"] = [
		{"lenh": "danh", "tuong": "1", "o": "1,6", "tu_choi": "khong_con_nuoc_di"},
		{"lenh": "di", "tuong": "1", "o": "1,6", "tu_choi": "khong_ke"},
		{"lenh": "di", "tuong": "1", "o": "1,6", "tu_choi": "ngoai_tam"},
	]
	assert_eq(_parse(d).errors, [
		F + ': "hanh_dong" mục 1 (danh): "tu_choi" là "khong_con_nuoc_di", lệnh "danh" chỉ bị từ chối vì '
			+ '"khong_co_quan", "khong_phai_tuong", "da_danh_roi", "khong_ke", "khong_co_dich", "bi_chan", '
			+ '"ngoai_tam", "tran_da_het"',
		F + ': "hanh_dong" mục 2 (di): "tu_choi" là "khong_ke", lệnh "di" chỉ bị từ chối vì '
			+ '"khong_co_quan", "khong_phai_tuong", "da_danh_roi", "da_di_roi", "da_dung_o_do", "khong_toi_duoc", "tran_da_het"',
		F + ': "hanh_dong" mục 3 (di): "tu_choi" là "ngoai_tam", lệnh "di" chỉ bị từ chối vì '
			+ '"khong_co_quan", "khong_phai_tuong", "da_danh_roi", "da_di_roi", "da_dung_o_do", "khong_toi_duoc", "tran_da_het"',
	] as Array[String])


func test_command_rejects_are_known_codes() -> void:
	for kind: String in ScenarioLoader.COMMAND_REJECTS:
		assert_true(ScenarioLoader.COMMANDS.has(kind), kind)
		for code: String in ScenarioLoader.COMMAND_REJECTS[kind] as Array:
			assert_true(ScenarioLoader.REJECT_CODES.has(code), "%s: %s" % [kind, code])


func test_undo_step_reads_reject_code() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "huy", "tu_choi": "khong_con_nuoc_di"}]
	var r: LoadResult = _parse(d)
	assert_eq(r.errors, [] as Array[String])
	assert_eq(r.warnings, [] as Array[String])
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	assert_eq(s.steps[0].kind, "huy")
	assert_eq(s.steps[0].reject, "khong_con_nuoc_di")


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
		F + ': "sau.dia_hinh" dòng 1: có 3 ô, "truoc.dia_hinh" có 7',
	] as Array[String])


# ---------- Cỡ bàn (Story 1.9) ----------

## Bàn đất trống cols × rows: Khoái ở ô `general`, Bộ binh ở góc trên phải.
func _board(cols: int, rows: int, general: Vector2i = Vector2i(0, 0)) -> Dictionary:
	var terrain: Array[String] = []
	var units: Array[String] = []
	for r: int in range(rows):
		var cells: PackedStringArray = PackedStringArray()
		cells.resize(cols)
		cells.fill(".")
		terrain.append(" ".join(cells))
		if r == general.y:
			cells[general.x] = "1"
		if r == 0:
			cells[cols - 1] = "B"
		units.append(" ".join(cells))
	var d: Dictionary = _valid()
	d["truoc"] = {"dia_hinh": terrain.duplicate(), "quan": units.duplicate()}
	d["sau"] = {"dia_hinh": terrain.duplicate(), "quan": units.duplicate()}
	return d


func test_non_7x7_scenario_loads() -> void:
	var s: ScenarioData = _scenario(_board(5, 6, Vector2i(2, 5)))
	if s == null:
		return
	assert_eq(s.before.size, Vector2i(5, 6))
	assert_eq(s.after_terrain.size(), 30)


func test_after_units_differ_from_before_size() -> void:
	var d: Dictionary = _board(5, 6)
	(d["sau"]["quan"] as Array).pop_back()
	assert_eq(_errors(d), [F + ': "sau.quan" có 5 dòng, "truoc.dia_hinh" có 6'] as Array[String])


func test_step_cell_outside_small_board() -> void:
	var d: Dictionary = _board(5, 6)
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "5,0"}]
	assert_eq(_errors(d), [F + ': "hanh_dong" mục 1 (di): "o" là "5,0", không phải ô trong bàn'] as Array[String])


func test_hp_cell_outside_small_board() -> void:
	var d: Dictionary = _board(5, 6)
	d["truoc"]["mau"] = {"0,6": 1}
	assert_eq(_errors(d), [F + ': "truoc.mau" ô 0,6 nằm ngoài bàn'] as Array[String])


func test_scenario_board_too_wide() -> void:
	assert_eq(_errors(_board(11, 8)),
		[F + ': "truoc.dia_hinh": bàn 11 cột × 8 hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng'] as Array[String])


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


## Bảng ngược dùng cho báo cáo F2: ký hiệu lạ trả "?", hướng lạ trả "" (Story 2.13 review).
func test_symbol_helpers_handle_unknown_values() -> void:
	assert_eq(BoardText.unit_symbol(9999), "?", "loại quân lạ")
	assert_eq(BoardText.terrain_symbol(9999), "?", "địa hình lạ")
	assert_eq(BoardText.unit_symbol(BoardText.NO_UNIT), ".", "ô trống vẫn là dấu chấm")
	for code: String in BoardText.DIRECTION_CODES:
		assert_eq(BoardText.direction_code(BoardText.DIRECTION_CODES[code] as Vector2i), code)
	assert_eq(BoardText.direction_code(Vector2i(2, 0)), "", "vector không phải hướng đơn vị")


## Mọi lệnh đã có luật từ Story 2.1 (PENDING_RULES rỗng): bước trượt thì dừng ở bước đó, không so bàn sau.
func test_runner_stops_at_failed_step() -> void:
	assert_eq(ScenarioRunner.PENDING_RULES, {}, "lệnh nào cũng có luật")
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "danh", "tuong": "1", "o": "1,6"}, {"lenh": "ket_thuc_luot"}]
	d["sau"]["mau"] = {"5,4": 1}
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_false(result.passed)
	assert_eq(result.problems, ['bước 1: luật từ chối ("khong_co_dich": ô 1,6 không có quân Nguyên để đánh) '
		+ 'mà kịch bản không ghi "tu_choi"'] as Array[String], "dừng ở bước 1, không so bàn sau")


## Hủy chạy qua BattleController thật: đi rồi hủy thì bàn về như trước.
func test_runner_undo_restores_board() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "2,5"}, {"lenh": "huy"}]
	assert_eq(_run(d).problems, [] as Array[String])


func test_runner_undo_with_nothing_to_undo_needs_reject_code() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "huy"}]
	assert_eq(_run(d).problems, [
		'bước 1: luật từ chối ("khong_con_nuoc_di": không còn nước đi nào để hủy) mà kịch bản không ghi "tu_choi"',
	] as Array[String])
	d["hanh_dong"] = [{"lenh": "huy", "tu_choi": "khong_con_nuoc_di"}]
	assert_eq(_run(d).problems, [] as Array[String])


func test_runner_end_turn_lets_general_move_again() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [
		{"lenh": "di", "tuong": "1", "o": "0,5"},
		{"lenh": "ket_thuc_luot"},
		{"lenh": "di", "tuong": "1", "o": "0,4"},
	]
	# Kết thúc lượt chạy pha địch (Story 2.6): Bộ binh 5,4 đi về phía Khoái (0,5), qua chỗ cạn của sông, tới 3,3.
	d["sau"]["quan"] = _rows(6, EMPTY_ROW)
	d["sau"]["quan"][3] = ". . . B . . ."
	d["sau"]["quan"][4] = "1 . . . . . ."
	assert_eq(_run(d).problems, [] as Array[String])


func test_runner_checks_round_and_moved() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "0,5"}, {"lenh": "ket_thuc_luot"}]
	# Pha địch (Story 2.6): Bộ binh 5,4 đi tới 3,3 (như test trên).
	d["sau"]["quan"] = _rows(6, EMPTY_ROW)
	d["sau"]["quan"][3] = ". . . B . . ."
	d["sau"]["quan"][5] = "1 . . . . . ."
	d["sau"]["hiep"] = 2
	d["sau"]["da_di"] = []
	assert_eq(_run(d).problems, [] as Array[String])
	d["sau"]["hiep"] = 1
	d["sau"]["da_di"] = ["1"]
	assert_eq(_run(d).problems, [
		"sau: mong đợi hiệp 1, thực tế hiệp 2",
		"sau: 1 (Nguyễn Khoái) mong đợi đã đi, thực tế chưa đi",
	] as Array[String])


func test_runner_checks_attacked() -> void:
	var d: Dictionary = _valid()
	d["sau"]["da_danh"] = []
	assert_eq(_run(d).problems, [] as Array[String])
	d["sau"]["da_danh"] = ["1"]
	assert_eq(_run(d).problems, ["sau: 1 (Nguyễn Khoái) mong đợi đã đánh, thực tế chưa đánh"] as Array[String])


func test_runner_reports_general_moved_but_expected_not() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "0,5"}]
	d["sau"]["quan"] = _units()
	d["sau"]["quan"][6] = EMPTY_ROW
	d["sau"]["quan"][5] = "1 . . . . . ."
	d["sau"]["da_di"] = []
	assert_eq(_run(d).problems, ["sau: 1 (Nguyễn Khoái) mong đợi chưa đi, thực tế đã đi"] as Array[String])


func test_runner_second_move_in_turn_is_rejected() -> void:
	var d: Dictionary = _valid()
	d["hanh_dong"] = [{"lenh": "di", "tuong": "1", "o": "0,5"}, {"lenh": "di", "tuong": "1", "o": "0,4"}]
	d["sau"]["quan"] = _units()
	d["sau"]["quan"][6] = EMPTY_ROW
	d["sau"]["quan"][5] = "1 . . . . . ."
	assert_eq(_run(d).problems, [
		'bước 2: luật từ chối ("da_di_roi": quân 1 đã đi rồi trong lượt này) mà kịch bản không ghi "tu_choi"',
	] as Array[String])


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


func test_viewer_shows_after_round_and_moved() -> void:
	var d: Dictionary = _valid()
	var lines: PackedStringArray = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	for line: String in lines:
		assert_false(line.contains("Sau lệnh"), "không ghi thì không in")
	d["sau"]["hiep"] = 2
	d["sau"]["da_di"] = ["1"]
	lines = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	assert_has(lines, "  Sau lệnh: hiệp 2 · đã đi: %s" % tr("scenario.unit.nguyen_khoai"))
	d["sau"].erase("hiep")
	d["sau"]["da_di"] = []
	lines = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	assert_has(lines, "  Sau lệnh: đã đi: chưa tướng nào")
	d["sau"]["da_danh"] = ["1"]
	lines = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	assert_has(lines, "  Sau lệnh: đã đi: chưa tướng nào · đã đánh: %s" % tr("scenario.unit.nguyen_khoai"))
	d["sau"]["da_danh"] = []
	lines = ScenarioViewer.render(_scenario(d), _stats()).split("\n")
	assert_has(lines, "  Sau lệnh: đã đi: chưa tướng nào · đã đánh: chưa tướng nào")


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


# ---------- Đòn đã báo ("sau.bao_don", Story 2.6) ----------

func test_after_telegraphs_are_read_in_order() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_false(s.checks_telegraphs, "không ghi bao_don thì không kiểm")
	var d: Dictionary = _valid()
	d["sau"]["bao_don"] = [
		{"thu_tu": 2, "quan": "6,4", "huong": "T"},
		{"thu_tu": 1, "quan": "5,4", "o": "5,5"},
	]
	d["sau"]["quan"][4] = ". . . . . B B"
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_telegraphs)
	assert_eq(s.after_telegraphs.size(), 2)
	assert_eq(s.after_telegraphs[0].order, 1, "xếp theo thu_tu")
	assert_eq(s.after_telegraphs[0].owner_cell, Vector2i(5, 4))
	assert_eq(s.after_telegraphs[0].kind, Telegraph.Kind.CELL)
	assert_eq(s.after_telegraphs[0].target, Vector2i(5, 5))
	assert_eq(s.after_telegraphs[1].kind, Telegraph.Kind.DIRECTION)
	assert_eq(s.after_telegraphs[1].target, Vector2i(-1, 0))
	d["sau"]["bao_don"] = []
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_telegraphs, "[] vẫn kiểm: không quân nào báo đòn")
	assert_eq(s.after_telegraphs.size(), 0)


func test_after_telegraph_errors() -> void:
	var d: Dictionary = _valid()
	d["sau"]["bao_don"] = [
		{"thu_tu": 1, "quan": "5,4"},
		{"thu_tu": 2, "quan": "5,4", "o": "5,5", "huong": "B"},
		{"thu_tu": 3, "quan": "5,4", "huong": "Bac"},
		{"thu_tu": 3, "quan": "5,4", "o": "5,3"},
		{"thu_tu": 0, "quan": "0,6", "o": "9,9"},
		{"quan": "5,4", "o": "5,3"},
		"5,4",
	]
	var w: String = F + ': "sau.bao_don" mục '
	var dup: String = '"quan" ô 5,4 trùng với mục 1 (mỗi quân chỉ báo một đòn)'
	var either: String = 'phải có đúng một trong "o" (đòn vào ô) và "huong" (xung phong)'
	assert_eq(_errors(d), [
		w + '1: ' + either,
		w + '2: ' + dup,
		w + '2: ' + either,
		w + '3: ' + dup,
		w + '3: "huong" là "Bac", chỉ được "B", "D", "N", "T"',
		w + '4: "thu_tu" 3 trùng với mục 3',
		w + '4: ' + dup,
		w + '5: "thu_tu" phải là số nguyên từ 1 trở lên, đang là 0',
		w + '5: "quan" ô 0,6 không có quân Nguyên trong "sau.quan"',
		w + '5: "o" là "9,9", không phải ô trong bàn',
		w + '6: thiếu khóa "thu_tu"',
		w + '6: ' + dup,
		w + '7 phải là một object, đang là "5,4"',
	] as Array[String])
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,2"}]
	assert_eq(_errors(d), [w + '1: "o" ô 5,2 không kề "quan" ô 5,4'] as Array[String])
	d["sau"]["bao_don"] = {"thu_tu": 1}
	assert_eq(_errors(d), [F + ': "sau.bao_don" phải là một danh sách, đang là {"thu_tu":1}'] as Array[String])
	d = _valid()
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,5", "loai": "B"}]
	assert_eq(_parse(d).warnings, [F + ': "sau.bao_don" mục 1: bỏ qua khóa lạ "loai"'] as Array[String])
	d = _valid()
	d["truoc"]["bao_don"] = []
	assert_eq(_parse(d).warnings, [] as Array[String], "từ Story 2.8 truoc.bao_don là khóa hợp lệ")


# ---------- Đòn đặt sẵn ("truoc.bao_don", Story 2.8) ----------

## Bàn trước của _valid() thêm Kỵ binh ở 6,4: Bộ binh 5,4 (id 101) và Kỵ binh 6,4 (id 102).
func _with_two_enemies() -> Dictionary:
	var d: Dictionary = _valid()
	d["truoc"]["quan"][4] = ". . . . . B K"
	d["sau"]["quan"][4] = ". . . . . B K"
	return d


func test_before_telegraphs_are_read_and_built() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_eq(s.before_telegraphs.size(), 0, "không ghi thì bàn trước không có đòn")
	var d: Dictionary = _with_two_enemies()
	d["truoc"]["bao_don"] = [
		{"thu_tu": 2, "quan": "6,4", "huong": "N"},
		{"thu_tu": 1, "quan": "5,4", "o": "4,4"},
	]
	s = _scenario(d)
	if s == null:
		return
	assert_eq(s.before_telegraphs.size(), 2)
	assert_eq(s.before_telegraphs[0].order, 1, "xếp theo thu_tu")
	var built: Array[Telegraph] = ScenarioRunner.before_telegraphs(s, _stats())
	assert_eq(built.size(), 2)
	assert_eq([built[0].owner_id, built[0].kind, built[0].offset, built[0].order],
		[101, Telegraph.Kind.CELL, Vector2i(-1, 0), 1], "Bộ binh 5,4 đánh ô 4,4: offset Tây")
	assert_eq([built[1].owner_id, built[1].kind, built[1].offset, built[1].order],
		[102, Telegraph.Kind.DIRECTION, Vector2i(0, 1), 2], "Kỵ binh 6,4 xung phong Nam")


func test_runner_starts_with_before_telegraphs() -> void:
	var d: Dictionary = _with_two_enemies()
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "4,4"}]
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "4,4"}]
	assert_true(_run(d).passed, "không có lệnh: đòn đặt sẵn còn nguyên ở bàn sau")


func test_before_telegraph_errors() -> void:
	var d: Dictionary = _with_two_enemies()
	d["truoc"]["bao_don"] = [
		{"thu_tu": 1, "quan": "5,4", "o": "4,4"},
		{"thu_tu": 3, "quan": "6,4", "huong": "N"},
	]
	assert_eq(_errors(d), [F + ': "truoc.bao_don" phải đánh số thứ tự liền từ 1 (1, 2, 3…), đang là [1,3]']
		as Array[String])
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "0,6", "o": "1,6"}]
	assert_eq(_errors(d), [F + ': "truoc.bao_don" mục 1: "quan" ô 0,6 không có quân Nguyên trong "truoc.quan"']
		as Array[String])
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "3,4"}]
	assert_eq(_errors(d), [F + ': "truoc.bao_don" mục 1: "o" ô 3,4 không kề "quan" ô 5,4'] as Array[String])


## Story 2.15: "o" của Cung kỵ phải thẳng hàng và cách đúng tầm `tam_ban_gan`–`tam_ban_xa` trong chi_so.json
## (một nguồn với luật, không hard-code). `truoc` và `sau` dùng chung phép kiểm.
func test_archer_telegraph_target_uses_stats_range() -> void:
	var after: String = F + ': "sau.bao_don" mục 1: '
	var before: String = F + ': "truoc.bao_don" mục 1: '
	var d: Dictionary = _valid()
	d["truoc"]["quan"][4] = ". . . . . C ."
	d["sau"]["quan"][4] = ". . . . . C ."
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,2"}]
	assert_eq(_errors(d), [] as Array[String], "thẳng hàng, cách 2 ô")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,1"}]
	assert_eq(_errors(d), [] as Array[String], "thẳng hàng, cách 3 ô")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,5"}]
	assert_eq(_errors(d), [after + '"o" ô 5,5 không cách "quan" ô 5,4 từ 2 ô trở lên (Cung kỵ bắn xa)']
		as Array[String], "ô kề")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "3,2"}]
	assert_eq(_errors(d), [after + '"o" ô 3,2 không thẳng hàng với "quan" ô 5,4 (Cung kỵ chỉ bắn thẳng hàng)']
		as Array[String], "chéo")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,0"}]
	assert_eq(_errors(d), [after + '"o" ô 5,0 vượt tầm bắn 3 ô của Cung kỵ, tính từ "quan" ô 5,4']
		as Array[String], "4 ô: quá tầm, bộ nạp báo ngay")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,4"}]
	assert_eq(_errors(d), [after + '"o" ô 5,4 trùng "quan" ô 5,4'] as Array[String], "trùng ô chủ đòn")
	d["sau"]["bao_don"] = []
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,2"}]
	assert_eq(_errors(d), [] as Array[String], "truoc dùng chung phép kiểm")
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,5"}]
	assert_eq(_errors(d), [before + '"o" ô 5,5 không cách "quan" ô 5,4 từ 2 ô trở lên (Cung kỵ bắn xa)']
		as Array[String], "truoc: ô kề cũng lỗi")
	d["truoc"]["bao_don"] = []
	d["sau"]["quan"][4] = ". . . . . B ."
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,2"}]
	assert_eq(_errors(d), [after + '"o" ô 5,2 không kề "quan" ô 5,4'] as Array[String],
		"Bộ binh vẫn chỉ đánh một ô kề")
	d["sau"]["quan"][4] = ". . . . . K ."
	assert_eq(_errors(d), [after + '"o" ô 5,2 không kề "quan" ô 5,4'] as Array[String],
		"Kỵ binh không bắn xa")


func test_runner_compares_telegraphs_only_when_written() -> void:
	var d: Dictionary = _valid()
	d["sau"]["bao_don"] = []
	assert_true(_run(d).passed, "bàn không có đòn, kịch bản ghi []")
	d["sau"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "5,5"}]
	var result: ScenarioRunner.ScenarioResult = _run(d)
	assert_eq(result.problems,
		["sau: đòn 1 mong đợi quân ở 5,4 đánh ô 5,5, thực tế không có đòn 1"] as Array[String])


func test_compare_telegraphs_reports_wrong_and_extra() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(0, 3): "K", Vector2i(3, 4): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 1))
	state.telegraphs.append(Telegraph.new(102, Telegraph.Kind.CELL, Vector2i(0, 1), 2))
	var wanted: Array[ScenarioData.ExpectedTelegraph] = [
		ScenarioData.ExpectedTelegraph.new(1, Vector2i(0, 3), Telegraph.Kind.DIRECTION, Vector2i(1, 0)),
	]
	assert_eq(ScenarioRunner._compare_telegraphs(state, wanted),
		["sau: thừa đòn 2: quân ở 3,3 đánh ô 3,4"] as Array[String])
	wanted = [ScenarioData.ExpectedTelegraph.new(1, Vector2i(0, 3), Telegraph.Kind.DIRECTION, Vector2i(0, 1)),
		ScenarioData.ExpectedTelegraph.new(2, Vector2i(3, 3), Telegraph.Kind.CELL, Vector2i(3, 4))]
	assert_eq(ScenarioRunner._compare_telegraphs(state, wanted),
		["sau: đòn 1 mong đợi quân ở 0,3 xung phong hướng N, thực tế quân ở 0,3 xung phong hướng D"] as Array[String])


# ---------- Ô đỏ ("sau.o_do", Story 2.7) ----------

func test_after_marks_are_read() -> void:
	var s: ScenarioData = _scenario(_valid())
	if s == null:
		return
	assert_false(s.checks_marks, "không ghi o_do thì không kiểm")
	var d: Dictionary = _valid()
	d["sau"]["o_do"] = {"5,5": [1], "4,4": [3, 1]}
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_marks)
	assert_eq(s.after_marks.size(), 2)
	assert_eq(s.after_marks[Vector2i(5, 5)], [1] as Array[int])
	assert_eq(s.after_marks[Vector2i(4, 4)], [1, 3] as Array[int], "xếp tăng dần")
	d["sau"]["o_do"] = {}
	s = _scenario(d)
	if s == null:
		return
	assert_true(s.checks_marks, "{} vẫn kiểm: không ô nào đỏ")
	assert_eq(s.after_marks.size(), 0)


func test_after_marks_errors() -> void:
	var d: Dictionary = _valid()
	d["sau"]["o_do"] = {"9,9": [1], "a": [1], "3,4": [1], "03,4": [2], "1,1": [], "2,2": [0], "3,3": [1, 1],
		"4,4": 1}
	var w: String = F + ': "sau.o_do" '
	var rule: String = " phải là danh sách số thứ tự (số nguyên từ 1, không trùng), đang là "
	# JSON.stringify xếp khóa theo chữ, nên lỗi ra theo thứ tự khóa đã xếp.
	assert_eq(_errors(d), [
		w + "ô 1,1" + rule + "[]",
		w + "ô 2,2" + rule + "[0]",
		w + "ô 3,3" + rule + "[1,1]",
		w + 'ghi ô 3,4 hai lần ("03,4" và "3,4")',
		w + "ô 4,4" + rule + "1",
		w + "ô 9,9 nằm ngoài bàn",
		w + 'có khóa "a" không phải tọa độ "cot,hang"',
	] as Array[String])
	d["sau"]["o_do"] = []
	assert_eq(_errors(d), [F + ': "sau.o_do" phải là một object, đang là []'] as Array[String])
	d = _valid()
	d["truoc"]["o_do"] = {}
	assert_eq(_parse(d).warnings, [F + ': bỏ qua khóa lạ "truoc.o_do"'] as Array[String])


func test_runner_compares_marks_only_when_written() -> void:
	var d: Dictionary = _valid()
	d["sau"]["o_do"] = {}
	assert_true(_run(d).passed, "bàn không có đòn, kịch bản ghi {}")
	d["sau"]["o_do"] = {"5,5": [1, 2]}
	assert_eq(_run(d).problems, ["sau: ô 5,5 mong đợi đỏ (đòn 1·2), thực tế không đỏ"] as Array[String])


## Công cụ duyệt (Story 2.8): bàn "Ô ĐỎ" của bàn trước đứng giữa TRƯỚC và SAU, kèm danh sách đòn đặt sẵn.
func test_viewer_shows_before_telegraphs() -> void:
	var d: Dictionary = _with_two_enemies()
	d["truoc"]["bao_don"] = [{"thu_tu": 1, "quan": "5,4", "o": "4,4"}]
	var s: ScenarioData = _scenario(d)
	if s == null:
		return
	var text: String = ScenarioViewer.render(s, _stats())
	var header: String = ""
	for line: String in text.split("\n"):
		if line.contains(tr("scenario.viewer.before")) and line.contains(tr("scenario.viewer.after")):
			header = line
	assert_true(header.find(tr("scenario.viewer.marks")) > header.find(tr("scenario.viewer.before")), "Ô ĐỎ sau TRƯỚC")
	assert_true(header.find(tr("scenario.viewer.marks")) < header.find(tr("scenario.viewer.after")), "Ô ĐỎ trước SAU")
	assert_string_contains(text, tr("scenario.viewer.before_telegraphs"))
	assert_string_contains(text, "1. " + tr("scenario.viewer.telegraph_cell") % [tr("scenario.unit.bo_binh"), "5,4", "4,4"])


## Story 3.7: Ô làng "D" trong "dia_hinh" của bàn "truoc" đòi khóa "long_dan".
func test_village_in_scenario_requires_long_dan() -> void:
	var d: Dictionary = _valid()
	var terrain_with_village: Array[String] = RIVER_TERRAIN.duplicate()
	terrain_with_village[3] = ". . . D . . ."
	d["truoc"]["dia_hinh"] = terrain_with_village
	d["sau"]["dia_hinh"] = terrain_with_village
	assert_eq(_errors(d), [F + ': có ô làng "D" trong "dia_hinh" mà thiếu khóa "long_dan"'] as Array[String])
	d["truoc"]["long_dan"] = 3
	assert_eq(_errors(d), [] as Array[String])
	var s: ScenarioData = _scenario(d)
	assert_eq(s.before.long_dan, 3)


## Story 3.7: "long_dan_toi_da" cho phép kịch bản dựng Lòng dân ban đầu nhỏ hơn tối đa.
func test_scenario_long_dan_toi_da() -> void:
	var d: Dictionary = _valid()
	var terrain_with_village: Array[String] = RIVER_TERRAIN.duplicate()
	terrain_with_village[3] = ". . . D . . ."
	d["truoc"]["dia_hinh"] = terrain_with_village
	d["sau"]["dia_hinh"] = terrain_with_village
	d["truoc"]["long_dan"] = 1
	d["truoc"]["long_dan_toi_da"] = 3
	d["sau"]["long_dan"] = 0
	var s: ScenarioData = _scenario(d)
	assert_eq(s.before.long_dan, 3)
	assert_eq(s.before.long_dan_hien_tai, 1)
	assert_true(s.checks_morale)
	assert_eq(s.after_morale, 0)
