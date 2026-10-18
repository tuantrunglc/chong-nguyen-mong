extends GutTest
## Màn hình chính: tiêu đề lấy từ file dịch, chữ đậm, nằm trên bàn cờ; thanh tiêu đề cửa sổ cùng chữ đó.
## Lúc mở game nạp chi_so.json và file trận; dữ liệu lỗi thì hiện màn hình lỗi.
## Không so với chữ cụ thể: tác giả được quyền sửa chữ trong CSV.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_main"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const LEVEL_DIR: String = PROBE_DIR + "/tran"
const BROKEN_LEVEL: String = LEVEL_DIR + "/tran_01.json"
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
	AppState.launch.tran = 0
	AppState.stats = null
	if FileAccess.file_exists(BROKEN_LEVEL):
		DirAccess.remove_absolute(BROKEN_LEVEL)
	DirAccess.remove_absolute(LEVEL_DIR)
	for i: int in range(DevTools.KEYS.size()):
		if InputMap.has_action("dev_f%d" % (i + 1)):
			InputMap.erase_action("dev_f%d" % (i + 1))
	SaveProbe.path = SaveProbe.DEFAULT_PATH
	if FileAccess.file_exists(PROBE_FILE):
		DirAccess.remove_absolute(PROBE_FILE)
	DirAccess.remove_absolute(PROBE_DIR)
	Log.clear()


func _make_main(level_dir: String = "") -> Node2D:
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	if not level_dir.is_empty():
		main.level_dir = level_dir
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
	AppState.launch.tran = 9
	var main: Node2D = _make_main()
	assert_eq(main._screen, main.Screen.ERROR)
	assert_has(Log.get_lines(), "[ERROR][data] data/tran/tran_09.json: không đọc được file")


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
