extends GutTest
## Đọc mã commit cho nhãn phiên bản: mọi trường hợp hỏng đều lặng lẽ trả về "dev".

const TEST_DIR: String = "user://test_build_info"
const TEST_FILE: String = TEST_DIR + "/build_info.json"


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(TEST_DIR)


func after_each() -> void:
	if FileAccess.file_exists(TEST_FILE):
		DirAccess.remove_absolute(TEST_FILE)
	DirAccess.remove_absolute(TEST_DIR)


func _write(text: String) -> void:
	var file: FileAccess = FileAccess.open(TEST_FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_missing_file_returns_dev() -> void:
	assert_eq(BuildInfo.read_commit(TEST_DIR + "/khong_co.json"), "dev")


func test_broken_json_returns_dev() -> void:
	_write("{commit:")
	assert_eq(BuildInfo.read_commit(TEST_FILE), "dev")


func test_json_array_returns_dev() -> void:
	_write("[1, 2]")
	assert_eq(BuildInfo.read_commit(TEST_FILE), "dev")


func test_non_string_commit_returns_dev() -> void:
	_write("{\"commit\": 123}")
	assert_eq(BuildInfo.read_commit(TEST_FILE), "dev")


func test_empty_commit_returns_dev() -> void:
	_write("{\"commit\": \"\"}")
	assert_eq(BuildInfo.read_commit(TEST_FILE), "dev")


func test_valid_commit_is_returned() -> void:
	_write("{\"commit\": \"abc1234-sua\"}")
	assert_eq(BuildInfo.read_commit(TEST_FILE), "abc1234-sua")
