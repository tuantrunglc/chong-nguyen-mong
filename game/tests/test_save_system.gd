extends GutTest
## Đọc, ghi, xóa file lưu (Story 4.3, FR46). Câu lỗi so nguyên văn.

const FILE: String = "user://test_save_system.json"
## Tên file trong câu lỗi (JsonFile.label chỉ bỏ "res://").
const F: String = FILE

var _old_path: String = ""


func before_each() -> void:
	_old_path = SaveSystem.path
	SaveSystem.path = FILE
	SaveSystem.clear()


func after_each() -> void:
	SaveSystem.clear()
	SaveSystem.path = _old_path


func _write(text: String) -> void:
	var file: FileAccess = FileAccess.open(FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_no_file_is_ok_without_data() -> void:
	var r: LoadResult = SaveSystem.load_save()
	assert_true(r.ok)
	assert_null(r.data)
	assert_false(SaveSystem.has_file())


func test_save_then_load_round_trips() -> void:
	assert_eq(SaveSystem.save_next_level("tran_03"), OK)
	assert_eq(JSON.parse_string(FileAccess.get_file_as_string(FILE)), {"phien_ban": 1.0, "tran_tiep": "tran_03"})
	assert_false(FileAccess.file_exists(FILE + ".tmp"), "không để lại file tạm")
	var r: LoadResult = SaveSystem.load_save()
	assert_eq(r.errors, [] as Array[String])
	assert_eq((r.data as SaveSystem.SaveData).next_level, "tran_03")


func test_clear_removes_file() -> void:
	SaveSystem.save_next_level("tran_02")
	assert_eq(SaveSystem.clear(), OK)
	assert_false(FileAccess.file_exists(FILE))
	assert_eq(SaveSystem.clear(), OK, "không có file: không lỗi")


## Ghi lần hai đè lên file cũ (đổi tên file tạm thành file lưu đã có).
func test_save_overwrites_previous_save() -> void:
	SaveSystem.save_next_level("tran_02")
	assert_eq(SaveSystem.save_next_level("tran_04"), OK)
	assert_eq((SaveSystem.load_save().data as SaveSystem.SaveData).next_level, "tran_04")


## Không ghi được (thư mục không có): trả mã lỗi, không có file lưu.
func test_save_into_missing_folder_returns_error() -> void:
	SaveSystem.path = "user://khong_co_thu_muc_nay/save.json"
	assert_ne(SaveSystem.save_next_level("tran_02"), OK)
	assert_false(FileAccess.file_exists(SaveSystem.path))


func test_unknown_key_is_warning_only() -> void:
	_write('{"phien_ban": 1, "tran_tiep": "tran_02", "la": 1}')
	var r: LoadResult = SaveSystem.load_save()
	assert_true(r.ok)
	assert_eq(r.warnings, [F + ': bỏ qua khóa lạ "la"'] as Array[String])


func test_broken_files_report_vietnamese_errors() -> void:
	var cases: Dictionary = {
		"": [F + ": file lưu rỗng"],
		"[1, 2]": [F + ": nội dung phải là một object JSON"],
		'{"tran_tiep": "tran_02"}': [F + ': thiếu khóa "phien_ban"'],
		'{"phien_ban": "1", "tran_tiep": "tran_02"}': [F + ': "phien_ban" phải là số nguyên từ 1 trở lên, đang là "1"'],
		'{"phien_ban": 2, "tran_tiep": "tran_02"}': [F + ': "phien_ban" là 2, game chỉ đọc được bản 1'],
		'{"phien_ban": 1}': [F + ': thiếu khóa "tran_tiep"'],
		'{"phien_ban": 1, "tran_tiep": 3}': [F + ': "tran_tiep" phải là tên trận (chuỗi không rỗng), đang là 3'],
		'{"phien_ban": 1, "tran_tiep": ""}': [F + ': "tran_tiep" phải là tên trận (chuỗi không rỗng), đang là ""'],
		'{"phien_ban": 1.5, "tran_tiep": "tran_02"}': [F + ': "phien_ban" phải là số nguyên từ 1 trở lên, đang là 1.5'],
		'{"phien_ban": true, "tran_tiep": "tran_02"}': [F + ': "phien_ban" phải là số nguyên từ 1 trở lên, đang là true'],
		'{"phien_ban": null, "tran_tiep": "tran_02"}': [F + ': "phien_ban" phải là số nguyên từ 1 trở lên, đang là null'],
		'{"phien_ban": 0, "tran_tiep": "tran_02"}': [F + ': "phien_ban" là 0, game chỉ đọc được bản 1'],
		'{"phien_ban": 1, "tran_tiep": null}': [F + ': "tran_tiep" phải là tên trận (chuỗi không rỗng), đang là null'],
		'{"phien_ban": 1, "tran_tiep": ["tran_02"]}':
			[F + ': "tran_tiep" phải là tên trận (chuỗi không rỗng), đang là ["tran_02"]'],
	}
	for text: String in cases:
		_write(text)
		var r: LoadResult = SaveSystem.load_save()
		assert_eq(r.errors, cases[text] as Array, text)
		assert_null(r.data, text)


func test_bad_json_names_file_and_line() -> void:
	_write('{\n"phien_ban": 1,,\n}')
	var r: LoadResult = SaveSystem.load_save()
	assert_eq(r.errors.size(), 1)
	assert_true(r.errors[0].begins_with(F + ", dòng 2: JSON sai cú pháp"), r.errors[0])
