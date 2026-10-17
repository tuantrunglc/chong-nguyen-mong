extends GutTest
## Màn hình chính: tiêu đề lấy từ file dịch, chữ đậm, nằm trên bàn cờ; thanh tiêu đề cửa sổ cùng chữ đó.
## Không so với chữ cụ thể: tác giả được quyền sửa chữ trong CSV.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_main"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"

var _old_window_title: String = ""


func before_each() -> void:
	_old_window_title = get_window().title
	DirAccess.make_dir_recursive_absolute(PROBE_DIR)
	SaveProbe.path = PROBE_FILE
	Log.clear()


func after_each() -> void:
	get_window().title = _old_window_title
	AppState.launch.dev = false
	for i: int in range(DevTools.KEYS.size()):
		if InputMap.has_action("dev_f%d" % (i + 1)):
			InputMap.erase_action("dev_f%d" % (i + 1))
	SaveProbe.path = SaveProbe.DEFAULT_PATH
	if FileAccess.file_exists(PROBE_FILE):
		DirAccess.remove_absolute(PROBE_FILE)
	DirAccess.remove_absolute(PROBE_DIR)
	Log.clear()


func _make_main() -> Node2D:
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	add_child_autofree(main)
	return main


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
