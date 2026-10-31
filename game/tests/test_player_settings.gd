extends GutTest
## Cài đặt người chơi user://settings.cfg (Story 4.4): đọc, ghi, file hỏng. Câu cảnh báo so nguyên văn.

const FILE: String = "user://test_player_settings.cfg"

var _old_path: String = ""


func before_each() -> void:
	_old_path = PlayerSettings.path
	PlayerSettings.path = FILE
	_remove()


func after_each() -> void:
	_remove()
	PlayerSettings.path = _old_path


func _remove() -> void:
	if FileAccess.file_exists(FILE):
		DirAccess.remove_absolute(FILE)


func _write(text: String) -> void:
	var file: FileAccess = FileAccess.open(FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_no_file_is_normal_speed() -> void:
	var r: LoadResult = PlayerSettings.load_settings()
	assert_true(r.ok)
	assert_eq(r.warnings, [] as Array[String])
	assert_eq((r.data as PlayerSettings).animation_speed, PlayerSettings.NORMAL_SPEED)
	assert_false((r.data as PlayerSettings).is_fast())


func test_save_then_load_round_trips() -> void:
	var settings: PlayerSettings = PlayerSettings.new()
	settings.animation_speed = PlayerSettings.FAST_SPEED
	assert_eq(settings.save(), OK)
	assert_string_contains(FileAccess.get_file_as_string(FILE), "[hoat_anh]")
	var r: LoadResult = PlayerSettings.load_settings()
	assert_eq(r.warnings, [] as Array[String])
	assert_true((r.data as PlayerSettings).is_fast())


func test_fast_speed_matches_event_player() -> void:
	assert_eq(PlayerSettings.FAST_SPEED, EventPlayer.FAST_SPEED)


## File không có khóa toc_do: mặc định, không cảnh báo.
func test_missing_key_is_normal_speed() -> void:
	_write("[khac]\nam_luong=1\n")
	var r: LoadResult = PlayerSettings.load_settings()
	assert_eq(r.warnings, [] as Array[String])
	assert_false((r.data as PlayerSettings).is_fast())


## Giá trị lạ: cảnh báo, tốc độ thường; luôn ok và có data (không bao giờ chặn game).
func test_odd_values_warn_and_use_normal_speed() -> void:
	var cases: Dictionary = {
		"[hoat_anh]\ntoc_do=7\n": FILE + ': "toc_do" là 7, dùng 1',
		"[hoat_anh]\ntoc_do=2.5\n": FILE + ': "toc_do" là 2.5, dùng 1',
		"[hoat_anh]\ntoc_do=\"3\"\n": FILE + ': "toc_do" là "3", dùng 1',
		"[hoat_anh]\ntoc_do=true\n": FILE + ': "toc_do" là true, dùng 1',
	}
	for text: String in cases:
		_write(text)
		var r: LoadResult = PlayerSettings.load_settings()
		assert_true(r.ok, text)
		assert_eq(r.warnings, [cases[text]] as Array[String], text)
		assert_false((r.data as PlayerSettings).is_fast(), text)


## Số nguyên 3 (người sửa tay) vẫn là tua nhanh.
func test_whole_number_three_is_fast() -> void:
	_write("[hoat_anh]\ntoc_do=3\n")
	var r: LoadResult = PlayerSettings.load_settings()
	assert_eq(r.warnings, [] as Array[String])
	assert_true((r.data as PlayerSettings).is_fast())


func test_unreadable_file_warns_and_uses_normal_speed() -> void:
	_write("[hoat_anh\ntoc_do=")
	var r: LoadResult = PlayerSettings.load_settings()
	assert_true(r.ok)
	assert_eq(r.warnings.size(), 1)
	assert_true(r.warnings[0].begins_with(FILE + ": không đọc được file cài đặt (mã lỗi "), r.warnings[0])
	assert_true(r.warnings[0].ends_with("), dùng mặc định"), r.warnings[0])
	assert_false((r.data as PlayerSettings).is_fast())
	# ConfigFile không có cách đọc im lặng: Godot tự in một dòng lỗi phân tích ra console (đúng: file hỏng thật).
	assert_engine_error("ConfigFile parse error")
