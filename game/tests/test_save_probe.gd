extends GutTest
## Thử lưu user://: mỗi lần gọi tăng số lần mở; file thiếu hoặc hỏng thì đếm lại từ 1.
## Không ghi được file thì có dòng WARN, để không lẫn với "user:// không bền".

const TEST_DIR: String = "user://test_save_probe"
const TEST_FILE: String = TEST_DIR + "/thu_luu.json"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)
	Log.clear()


func after_each() -> void:
	if FileAccess.file_exists(TEST_FILE):
		DirAccess.remove_absolute(TEST_FILE)
	DirAccess.remove_absolute(TEST_DIR)
	Log.clear()


func _write(text: String) -> void:
	var file: FileAccess = FileAccess.open(TEST_FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_missing_file_counts_one() -> void:
	assert_eq(SaveProbe.bump(TEST_FILE), 1)


func test_second_call_counts_two() -> void:
	SaveProbe.bump(TEST_FILE)
	assert_eq(SaveProbe.bump(TEST_FILE), 2)


func test_broken_file_counts_one() -> void:
	_write("{so_lan_mo:")
	assert_eq(SaveProbe.bump(TEST_FILE), 1)


func test_string_count_counts_one() -> void:
	_write("{\"so_lan_mo\": \"ba\"}")
	assert_eq(SaveProbe.bump(TEST_FILE), 1)


func test_existing_count_is_read_as_int() -> void:
	_write("{\"so_lan_mo\": 4}")
	assert_eq(SaveProbe.bump(TEST_FILE), 5)


func test_write_failure_logs_warning() -> void:
	var missing_dir_file: String = TEST_DIR + "/khong_co/thu_luu.json"
	assert_eq(SaveProbe.bump(missing_dir_file), 1)
	var warned: bool = false
	for line: String in Log.get_lines():
		if line.begins_with("[WARN][luu_thu] không ghi được " + missing_dir_file):
			warned = true
	assert_true(warned, "có dòng WARN khi không ghi được file")
