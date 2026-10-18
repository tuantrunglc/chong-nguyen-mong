extends GutTest
## Màn hình chính: tiêu đề lấy từ file dịch, chữ đậm, nằm trên bàn cờ; thanh tiêu đề cửa sổ cùng chữ đó.
## Lúc mở game nạp chi_so.json và file trận; dữ liệu lỗi thì hiện màn hình lỗi.
## Không so với chữ cụ thể: tác giả được quyền sửa chữ trong CSV.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_main"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const LEVEL_DIR: String = PROBE_DIR + "/tran"
const BROKEN_LEVEL: String = LEVEL_DIR + "/tran_01.json"
const BROKEN_STATS: String = PROBE_DIR + "/chi_so.json"
const BROKEN_STATS_ERROR: String = "user://test_main/chi_so.json: nội dung phải là một object JSON"
## Hai lỗi: ký hiệu lạ ở dia_hinh và thiếu thu_tu_dich.
const BROKEN_ERRORS: Array[String] = [
	'user://test_main/tran/tran_01.json: "dia_hinh" dòng 1, cột 1 (ô 0,0): ký hiệu lạ "X"',
	'user://test_main/tran/tran_01.json: thiếu khóa "thu_tu_dich"',
]

var _old_window_title: String = ""


func before_each() -> void:
	_old_window_title = get_window().title
	DirAccess.make_dir_recursive_absolute(PROBE_DIR)
	SaveProbe.path = PROBE_FILE
	Log.clear()


func after_each() -> void:
	get_window().title = _old_window_title
	AppState.launch.dev = false
	AppState.launch.tran = ""
	AppState.stats = null
	if FileAccess.file_exists(BROKEN_LEVEL):
		DirAccess.remove_absolute(BROKEN_LEVEL)
	if FileAccess.file_exists(BROKEN_STATS):
		DirAccess.remove_absolute(BROKEN_STATS)
	DirAccess.remove_absolute(LEVEL_DIR)
	for i: int in range(DevTools.KEYS.size()):
		if InputMap.has_action("dev_f%d" % (i + 1)):
			InputMap.erase_action("dev_f%d" % (i + 1))
	SaveProbe.path = SaveProbe.DEFAULT_PATH
	if FileAccess.file_exists(PROBE_FILE):
		DirAccess.remove_absolute(PROBE_FILE)
	DirAccess.remove_absolute(PROBE_DIR)
	Log.clear()


func _make_main(level_dir: String = "", stats_path: String = "") -> Node2D:
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	if not level_dir.is_empty():
		main.level_dir = level_dir
	if not stats_path.is_empty():
		main.stats_path = stats_path
	add_child_autofree(main)
	return main


## Tạo thư mục trận tạm có tran_01.json lỗi đúng hai chỗ (BROKEN_ERRORS).
func _broken_level_dir() -> String:
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)
	var level: Dictionary = {
		"phien_ban_dinh_dang": 1,
		"ten": "Trận lỗi",
		"kieu": "tieu_diet",
		"dia_hinh": ["X . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . .", ". . . . . . ."],
		"quan": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . .", "1 . . . . . ."],
	}
	var file: FileAccess = FileAccess.open(BROKEN_LEVEL, FileAccess.WRITE)
	file.store_string(JSON.stringify(level))
	file.close()
	return LEVEL_DIR


## chi_so.json lỗi đúng một chỗ (BROKEN_STATS_ERROR): gốc là danh sách.
func _broken_stats_path() -> String:
	var file: FileAccess = FileAccess.open(BROKEN_STATS, FileAccess.WRITE)
	file.store_string("[]")
	file.close()
	return BROKEN_STATS


## Chữ của mọi Label nằm trong node (kể cả lồng nhau).
func _label_texts(node: Node) -> Array[String]:
	var texts: Array[String] = []
	for child: Node in node.get_children():
		if child is Label:
			texts.append((child as Label).text)
		texts.append_array(_label_texts(child))
	return texts


func _find_button(node: Node) -> Button:
	for child: Node in node.get_children():
		if child is Button:
			return child as Button
		var found: Button = _find_button(child)
		if found != null:
			return found
	return null


## Đồng quân đang hiện trên bàn cờ, theo id.
func _tokens(main: Node2D) -> Dictionary:
	return (main._board_view as BoardView).tokens()


func _dev_tools(main: Node2D) -> DevTools:
	for child: Node in main.get_children():
		if child is DevTools:
			return child as DevTools
	return null


func test_title_label_uses_translated_text() -> void:
	var main: Node2D = _make_main()
	var title: Label = main._title_label
	assert_ne(tr("app.title"), "app.title", "app.title đã được dịch")
	assert_eq(title.text, tr("app.title"))


func test_title_label_uses_bold_title_style() -> void:
	var title: Label = _make_main()._title_label
	assert_eq(title.theme_type_variation, &"TitleLabel")


func test_title_label_sits_above_board() -> void:
	var main: Node2D = _make_main()
	var title: Label = main._title_label
	var board: BoardView = main._board_view
	assert_gt(title.position.y, 0.0, "tiêu đề không chạm mép trên")
	assert_lte(title.position.y + title.size.y, board.position.y, "tiêu đề không đè lên bàn cờ")


func test_window_title_uses_translated_text() -> void:
	get_window().title = ""
	_make_main()
	assert_eq(get_window().title, tr("app.title"))


func test_counts_each_open_and_logs_even_without_dev() -> void:
	_make_main()
	_make_main()
	assert_true(FileAccess.file_exists(PROBE_FILE), "có ghi file thử lưu")
	assert_has(Log.get_lines(), "[INFO][luu_thu] lần mở thứ 2, user:// bền: true")


func test_dev_badge_shows_open_count() -> void:
	AppState.launch.dev = true
	_make_main()
	var main: Node2D = _make_main()
	var badge_text: String = ""
	for child: Node in main.get_children():
		if child is DevTools:
			for grandchild: Node in child.get_children():
				if grandchild is Label:
					badge_text = (grandchild as Label).text
	assert_eq(badge_text, "DEV · lần mở thứ 2")


func test_loads_level_1_by_default() -> void:
	var main: Node2D = _make_main()
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_01")
	assert_not_null(AppState.stats, "đã có chỉ số")
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_null(main._error_screen)
	assert_true(main._board_view.visible)


func test_tran_option_picks_level_file() -> void:
	AppState.launch.tran = "9"
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)
	var main: Node2D = _make_main(LEVEL_DIR)
	assert_eq(main._screen, main.Screen.ERROR)
	assert_has(Log.get_lines(), "[ERROR][data] user://test_main/tran/tran_09.json: không đọc được file")


func test_errors_of_stats_and_level_are_listed_together() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main(_broken_level_dir(), _broken_stats_path())
	var screen: ErrorScreen = main._error_screen
	assert_not_null(screen, "có màn hình lỗi")
	if screen == null:
		return
	var expected: Array[String] = [BROKEN_STATS_ERROR]
	expected.append_array(BROKEN_ERRORS)
	var texts: Array[String] = _label_texts(screen)
	var logged: Array[String] = []
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR][data] "):
			logged.append(line.trim_prefix("[ERROR][data] "))
	assert_eq(logged, expected, "lỗi chi_so.json đứng trước lỗi file trận")
	for message: String in expected:
		assert_has(texts, message)


func test_reload_after_fix_hides_error_screen() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	assert_eq(main._screen, main.Screen.ERROR)
	main.level_dir = "res://data/tran"
	main._start_battle()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_null(main._error_screen)
	assert_true(main._board_view.visible, "bàn cờ hiện lại")
	assert_not_null(AppState.stats, "đã có chỉ số")


func test_reload_with_error_drops_old_data() -> void:
	var main: Node2D = _make_main()
	assert_not_null(AppState.stats)
	main.level_dir = _broken_level_dir()
	main._start_battle()
	assert_eq(main._screen, main.Screen.ERROR)
	assert_null(AppState.stats, "không giữ chỉ số cũ")
	assert_null(main._level, "không giữ trận cũ")


func test_broken_level_in_dev_lists_every_error() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main(_broken_level_dir())
	var screen: ErrorScreen = main._error_screen
	assert_not_null(screen, "có màn hình lỗi")
	if screen == null:
		return
	assert_eq(main._screen, main.Screen.ERROR)
	assert_false(main._board_view.visible, "bàn cờ bị ẩn")
	var texts: Array[String] = _label_texts(screen)
	for message: String in BROKEN_ERRORS:
		assert_has(texts, message)
		assert_has(Log.get_lines(), "[ERROR][data] " + message)
	assert_null(AppState.stats, "lỗi thì không giữ chỉ số")
	assert_not_null(_find_button(screen), "có nút về menu")


func test_broken_level_without_dev_shows_short_message_only() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	var screen: ErrorScreen = main._error_screen
	assert_not_null(screen, "có màn hình lỗi")
	if screen == null:
		return
	var texts: Array[String] = _label_texts(screen)
	assert_has(texts, tr("error.data_short"))
	for message: String in BROKEN_ERRORS:
		assert_does_not_have(texts, message)
		assert_has(Log.get_lines(), "[ERROR][data] " + message, "chi tiết vẫn vào log")
	var button: Button = _find_button(screen)
	assert_not_null(button)
	if button != null:
		assert_eq(button.text, tr("error.back_to_menu"))


func test_back_button_returns_to_menu() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	var button: Button = _find_button(main._error_screen)
	assert_not_null(button)
	if button == null:
		return
	button.pressed.emit()
	assert_eq(main._screen, main.Screen.MENU)
	assert_null(main._error_screen)
	assert_true(main._board_view.visible, "bàn cờ hiện lại")
	assert_has(Log.get_lines(), "[INFO][app] về menu")


func test_version_label_and_dev_badge_stay_above_error_screen() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main(_broken_level_dir())
	var error_index: int = main._error_screen.get_index()
	assert_gt(main._version_label.get_index(), error_index, "nhãn phiên bản vẽ sau màn hình lỗi")
	for child: Node in main.get_children():
		if child is DevTools:
			assert_gt(child.get_index(), error_index, "chữ DEV vẽ sau màn hình lỗi")


func test_level_1_shows_terrain_and_units() -> void:
	var main: Node2D = _make_main()
	var tokens: Dictionary = _tokens(main)
	assert_eq(tokens.keys(), [1, 2, 101, 102, 103], "2 tướng và 3 quân Nguyên")
	if tokens.size() != 5:
		return
	assert_eq((tokens[101] as UnitToken).position, BoardView.cell_center(Vector2i(1, 0)))
	assert_eq((tokens[1] as UnitToken).position, BoardView.cell_center(Vector2i(0, 6)))
	assert_eq((tokens[1] as UnitToken).name_text(), tr("unit.nguyen_khoai"))
	assert_eq((tokens[2] as UnitToken).name_text(), tr("unit.pham_ngu_lao"))
	assert_eq((tokens[101] as UnitToken).name_text(), tr("unit.bo_binh"))
	assert_eq((tokens[1] as UnitToken).hp_text(), str(AppState.stats.max_hp(UnitType.NGUYEN_KHOAI)))
	assert_eq((tokens[103] as UnitToken).hp_text(), str(AppState.stats.max_hp(UnitType.BO_BINH)))
	assert_has(_label_texts(main._board_view), tr("terrain.river"), "ô sông có chữ")


func test_three_generals_level_opens_by_name_in_dev() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = "thu_ba_tuong"
	var main: Node2D = _make_main()
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận thu_ba_tuong")
	var tokens: Dictionary = _tokens(main)
	assert_eq(tokens.keys(), [1, 2, 3, 101, 102, 103, 104])
	if tokens.has(3):
		assert_eq((tokens[3] as UnitToken).name_text(), tr("unit.tran_khanh_du"))
	var texts: Array[String] = _label_texts(main._board_view)
	for key: String in BoardView.TERRAIN_KEYS.values():
		assert_has(texts, tr(key), "đủ chữ địa hình: " + key)


func test_level_name_without_dev_opens_level_1() -> void:
	AppState.launch.tran = "thu_ba_tuong"
	AppState.launch.require_dev_for_tran()
	var main: Node2D = _make_main()
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_01")
	assert_eq(_tokens(main).size(), 5)


func test_back_to_menu_leaves_empty_board() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	assert_eq(_tokens(main).size(), 0, "màn hình lỗi: không có đồng quân")
	_find_button(main._error_screen).pressed.emit()
	assert_eq(_tokens(main).size(), 0, "về menu: bàn trống")
	assert_true(main._board_view.visible)


func test_reload_with_error_clears_board() -> void:
	var main: Node2D = _make_main()
	assert_eq(_tokens(main).size(), 5)
	main.level_dir = _broken_level_dir()
	main._start_battle()
	assert_eq(_tokens(main).size(), 0)
	assert_null(main._controller)


func test_f1_toggles_coordinates_in_dev() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var overlay: CoordOverlay = main._coord_overlay
	assert_not_null(overlay)
	if overlay == null:
		return
	assert_eq(overlay.get_parent(), main._board_view, "nằm trong bàn cờ")
	assert_eq(overlay.get_index(), main._board_view.get_child_count() - 1, "nằm trên đồng quân")
	assert_false(overlay.visible, "ban đầu ẩn")
	var texts: Array[String] = overlay.texts()
	assert_has(texts, "0,0")
	assert_has(texts, "6,6")
	assert_has(texts, "1")
	assert_has(texts, "101")
	Log.debug_enabled = true
	_dev_tools(main).f1_pressed.emit()
	assert_true(overlay.visible)
	_dev_tools(main).f1_pressed.emit()
	assert_false(overlay.visible)
	assert_has(Log.get_lines(), "[DEBUG][dev] f1: hiện tọa độ")
	assert_has(Log.get_lines(), "[DEBUG][dev] f1: ẩn tọa độ")
	Log.debug_enabled = false


func test_no_coordinates_without_dev() -> void:
	var main: Node2D = _make_main()
	assert_null(main._coord_overlay)
	for child: Node in main._board_view.get_children():
		assert_false(child is CoordOverlay)
