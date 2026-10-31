extends GutHookScript
## Chạy trước mọi test (tools/test.sh, -gpre_run_script): file lưu và file cài đặt trỏ sang file riêng của test, để
## thắng trận hay bấm tua trong test không ghi đè tiến độ và cài đặt thật của tác giả (Story 4.3, 4.4).

const TEST_SAVE_PATH: String = "user://test_luu_game.json"
## Cài đặt người chơi (Story 4.4): test bấm tua không ghi vào settings.cfg thật.
const TEST_SETTINGS_PATH: String = "user://test_cai_dat.cfg"


func run() -> void:
	SaveSystem.path = TEST_SAVE_PATH
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
	PlayerSettings.path = TEST_SETTINGS_PATH
	if FileAccess.file_exists(TEST_SETTINGS_PATH):
		DirAccess.remove_absolute(TEST_SETTINGS_PATH)
