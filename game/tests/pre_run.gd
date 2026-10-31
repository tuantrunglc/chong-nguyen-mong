extends GutHookScript
## Chạy trước mọi test (tools/test.sh, -gpre_run_script): file lưu trỏ sang file riêng của test, để thắng trận trong
## test không ghi đè tiến độ thật của tác giả (Story 4.3).

const TEST_SAVE_PATH: String = "user://test_luu_game.json"


func run() -> void:
	SaveSystem.path = TEST_SAVE_PATH
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
