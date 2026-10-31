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
## chien_dich.json lỗi (Story 4.2): có tên trận không có file.
const BROKEN_CAMPAIGN: String = PROBE_DIR + "/chien_dich.json"
## Bản sao chi_so.json thật, sửa tầm đi của Khoái (F5, Story 1.6).
const SAVE_FILE: String = "user://test_main_save.json"
const F5_STATS: String = PROBE_DIR + "/chi_so_f5.json"
const F5_LOG: String = "[INFO][dev] f5: nạp lại chi_so.json và file trận"
const BROKEN_STATS_ERROR: String = "user://test_main/chi_so.json: nội dung phải là một object JSON"
## Hai lỗi: ký hiệu lạ ở dia_hinh và thiếu thu_tu_dich.
const BROKEN_ERRORS: Array[String] = [
	'user://test_main/tran/tran_01.json: "dia_hinh" dòng 1, cột 1 (ô 0,0): ký hiệu lạ "X"',
	'user://test_main/tran/tran_01.json: thiếu khóa "thu_tu_dich"',
]

var _old_window_title: String = ""


func before_each() -> void:
	# Story 4.3: file lưu riêng cho từng test, không đụng file thật; mỗi test bắt đầu không có file lưu.
	SaveSystem.path = SAVE_FILE
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	# Story 4.1: không chọn trận thì mở màn hình chính; test trận vào thẳng trận 1 (test màn hình chính đặt lại "").
	AppState.launch.tran = "1"
	_old_window_title = get_window().title
	DirAccess.make_dir_recursive_absolute(PROBE_DIR)
	SaveProbe.path = PROBE_FILE
	Log.clear()


func after_each() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)
	get_window().title = _old_window_title
	AppState.launch.dev = false
	AppState.launch.tran = ""
	AppState.launch.warnings.clear()
	AppState.stats = null
	if FileAccess.file_exists(BROKEN_LEVEL):
		DirAccess.remove_absolute(BROKEN_LEVEL)
	for path: String in [BROKEN_STATS, F5_STATS, BROKEN_CAMPAIGN, LEVEL_DIR + "/tran_04.json", LEVEL_DIR + "/tran_05.json"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
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
		"quan": [". . . . . . B", ". . . . . . .", ". . . . . . .", ". . . . . . .",
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


## Chép res://data/chi_so.json thật sang user://, đổi tầm đi của Nguyễn Khoái. Không bao giờ ghi vào res://data/.
func _write_stats(tam_di_khoai: int) -> String:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/chi_so.json")) as Dictionary
	((data["tuong"] as Dictionary)["nguyen_khoai"] as Dictionary)["tam_di"] = tam_di_khoai
	var file: FileAccess = FileAccess.open(F5_STATS, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	return F5_STATS


func _press_f5(main: Node2D) -> void:
	_dev_tools(main).f5_pressed.emit()


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
	assert_lte(title.position.y + title.size.y, board.board_rect().position.y, "tiêu đề không đè lên bàn cờ")


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


func test_tran_1_loads_level_1() -> void:
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
	assert_true(main.main_menu().visible, "hiện màn hình chính (Story 4.1)")
	assert_false(main._board_view.visible, "bàn cờ ẩn sau màn hình chính")
	assert_has(Log.get_lines(), "[INFO][app] về menu")


## Bàn nghiêng (Story 1.7): màn hình lỗi phủ đúng khung bàn cờ.
func test_error_screen_covers_board_rect() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	var screen: ErrorScreen = main._error_screen
	assert_eq(Rect2(screen.position, screen.size), (main._board_view as BoardView).board_rect())


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
	# Hiệp 1 mở bằng pha địch chuẩn bị (Story 2.6): Bộ binh dạy ở 2,4 đi xuống 2,5, báo đòn vào Lão (2,6).
	assert_eq((tokens[101] as UnitToken).position, BoardView.cell_center(Vector2i(2, 5)))
	assert_eq((tokens[102] as UnitToken).position, BoardView.cell_center(Vector2i(4, 1)), "Bộ binh 5,0 tiến vào 4,1")
	assert_eq((tokens[103] as UnitToken).position, BoardView.cell_center(Vector2i(4, 3)), "Bộ binh 5,4 tiến vào 4,3")
	var red: Dictionary = {Vector2i(2, 6): [1] as Array[int]}
	assert_eq(main._board_view.telegraph_view().red_cells(), red, "ô đỏ hiệp 1 nhắm đúng ô Lão")
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
	var texts: Array[String] = _label_texts(main._board_view)
	for key: String in BoardView.TERRAIN_KEYS.values():
		assert_has(texts, tr(key), "đủ chữ địa hình: " + key)
	assert_true(tokens.has(3), "có tướng 3")
	if not tokens.has(3):
		return
	assert_eq((tokens[3] as UnitToken).name_text(), tr("unit.tran_khanh_du"))


## Story 4.1: chưa bật dev thì tran bị bỏ, nên mở màn hình chính (trước đây: mở trận 1).
func test_level_name_without_dev_shows_menu() -> void:
	AppState.launch.tran = "thu_ba_tuong"
	AppState.launch.require_dev_for_tran()
	var main: Node2D = _make_main()
	assert_eq(main._screen, main.Screen.MENU)
	assert_true(main.main_menu().visible)
	assert_eq(_tokens(main).size(), 0)
	for line: String in Log.get_lines():
		assert_false(line.begins_with("[INFO][battle] nạp trận"), "không nạp trận nào: " + line)


func test_back_to_menu_leaves_empty_board() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	assert_eq(_tokens(main).size(), 0, "màn hình lỗi: không có đồng quân")
	_find_button(main._error_screen).pressed.emit()
	assert_eq(_tokens(main).size(), 0, "về menu: bàn trống")
	assert_false(main._board_view.visible, "về menu: bàn cờ ẩn sau màn hình chính (Story 4.1)")


func test_back_to_menu_after_battle_clears_everything() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	assert_eq(_tokens(main).size(), 5)
	assert_false(main._coord_overlay.texts().is_empty(), "trước đó có tọa độ F1")
	main._show_menu()
	assert_eq(_tokens(main).size(), 0, "không còn đồng quân")
	assert_eq(_label_texts(main._board_view), [] as Array[String], "không còn chữ địa hình, tọa độ, chữ trên đồng quân")
	assert_eq(main._coord_overlay.texts(), [] as Array[String], "không còn tọa độ F1")
	assert_null(main._board_view._state, "không còn màu ô")


func test_reload_rebuilds_token_when_id_changes_type() -> void:
	var main: Node2D = _make_main()
	var board: BoardView = main._board_view
	var state: BattleState = main._controller.snapshot()
	var index: int = state.units.find(state.unit_by_id(101))
	state.units[index] = Unit.new(101, UnitType.KY_BINH, Vector2i(1, 0), 2)
	board.show_state(state)
	var token: UnitToken = _tokens(main)[101] as UnitToken
	assert_eq(token.name_text(), tr("unit.ky_binh"), "chữ theo loại mới")
	assert_eq(token.hp_text(), "2")
	assert_eq(token.unit_type, UnitType.KY_BINH)
	var on_board: int = 0
	for child: Node in board._world.get_children():
		if child is UnitToken:
			on_board += 1
	assert_eq(on_board, 5, "đồng cũ đã gỡ khỏi bàn")


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


func test_f1_does_nothing_on_error_screen() -> void:
	AppState.launch.dev = true
	Log.debug_enabled = true
	var main: Node2D = _make_main(_broken_level_dir())
	_dev_tools(main).f1_pressed.emit()
	assert_false(main._coord_overlay.visible)
	assert_does_not_have(Log.get_lines(), "[DEBUG][dev] f1: hiện tọa độ")
	_find_button(main._error_screen).pressed.emit()
	_dev_tools(main).f1_pressed.emit()
	assert_false(main._coord_overlay.visible, "menu: F1 cũng không làm gì")
	assert_does_not_have(Log.get_lines(), "[DEBUG][dev] f1: hiện tọa độ")
	Log.debug_enabled = false


func test_f1_stays_on_after_reload() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	_dev_tools(main).f1_pressed.emit()
	main._start_battle()
	assert_true(main._coord_overlay.visible, "nạp lại vẫn hiện tọa độ")
	assert_has(main._coord_overlay.texts(), "0,0")


## F5 nạp lại trận đã đổi cỡ (Story 1.9): bàn theo cỡ mới, vẫn trong vùng chơi, không còn đồng ngoài bàn.
func test_f5_reload_follows_new_board_size() -> void:
	var dir: String = PROBE_DIR + "/tran_co"
	DirAccess.make_dir_recursive_absolute(dir)
	var path: String = dir + "/tran_01.json"
	var source: FileAccess = FileAccess.open("res://data/tran/tran_01.json", FileAccess.READ)
	var text: String = source.get_as_text()
	source.close()
	_write_text(path, text)
	var main: Node2D = _make_main(dir)
	var board: BoardView = main._board_view as BoardView
	assert_eq(Vector2i(board.cols, board.rows), Vector2i(7, 7))
	source = FileAccess.open("res://data/tran/thu_co_nho.json", FileAccess.READ)
	_write_text(path, source.get_as_text())
	source.close()
	main._start_battle()
	assert_eq(Vector2i(board.cols, board.rows), Vector2i(5, 5), "bàn theo cỡ mới")
	assert_true(BoardView.AREA.encloses(board.board_rect()), "vẫn trong vùng chơi")
	for token: UnitToken in board.tokens().values():
		assert_true(Rect2i(Vector2i.ZERO, Vector2i(5, 5)).has_point(token.cell), "đồng %s trong bàn" % token.cell)
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(dir)


func _write_text(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func test_no_coordinates_without_dev() -> void:
	var main: Node2D = _make_main()
	assert_null(main._coord_overlay)
	for child: Node in main._board_view.get_children():
		assert_false(child is CoordOverlay)


# ---------- F5 nạp lại dữ liệu (Story 1.6) ----------

func test_f5_reads_edited_stats() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main("", _write_stats(3))
	var old: BattleController = main._controller
	assert_eq(old.reachable(1).size(), 6, "tầm đi 3: 6 ô (Bộ binh đứng 2,5 chắn)")
	old.submit(Command.move(1, Vector2i(0, 4)))
	assert_eq(old.snapshot().unit_by_id(1).cell, Vector2i(0, 4), "trước F5 Khoái đã đi")
	assert_true(old.can_undo(), "trước F5 có nước để hủy")
	_write_stats(2)
	_press_f5(main)
	var controller: BattleController = main._controller
	assert_ne(controller, old, "controller mới")
	assert_eq(controller.reachable(1),
		[Vector2i(0, 4), Vector2i(0, 5), Vector2i(1, 5), Vector2i(1, 6)] as Array[Vector2i], "tầm đi 2: 4 ô")
	var state: BattleState = controller.snapshot()
	assert_eq(state.unit_by_id(1).cell, Vector2i(0, 6), "Khoái về chỗ đầu trận")
	assert_eq(state.round_number, 1)
	assert_false(controller.can_undo(), "không còn nước để hủy")
	assert_true((main._hud as Hud).undo_button().disabled, "nút Hủy mờ")
	assert_eq((main._battle_view as BattleView).selected_id(), BattleView.NONE)
	assert_eq((main._hud as Hud).round_text(), "Hiệp 1")
	var lines: PackedStringArray = Log.get_lines()
	var at: int = lines.find(F5_LOG)
	assert_gt(at, -1, "có dòng log F5")
	assert_eq(lines.find("[INFO][battle] nạp trận tran_01", at), at + 1, "rồi nạp trận")


func test_f5_shows_error_then_recovers() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	main.level_dir = _broken_level_dir()
	_press_f5(main)
	assert_eq(main._screen, main.Screen.ERROR)
	var texts: Array[String] = _label_texts(main._error_screen)
	for message: String in BROKEN_ERRORS:
		assert_has(texts, message)
	main.level_dir = "res://data/tran"
	_press_f5(main)
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_null(main._error_screen)
	assert_true(main._board_view.visible)
	assert_eq(_tokens(main).size(), 5)


func test_f5_keeps_chosen_level() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = "thu_ba_tuong"
	var main: Node2D = _make_main()
	_press_f5(main)
	assert_not_null(main._controller.snapshot().unit_by_id(3), "vẫn có Trần Khánh Dư")
	assert_eq(Array(Log.get_lines()).count("[INFO][battle] nạp trận thu_ba_tuong"), 2)


func test_f5_on_menu_opens_battle() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main(_broken_level_dir())
	_find_button(main._error_screen).pressed.emit()
	assert_eq(main._screen, main.Screen.MENU)
	main.level_dir = "res://data/tran"
	_press_f5(main)
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(_tokens(main).size(), 5)


func test_f5_keeps_coordinates_and_open_count() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var opens: int = SaveProbe._read(PROBE_FILE)
	_dev_tools(main).f1_pressed.emit()
	_press_f5(main)
	assert_true(main._coord_overlay.visible, "tọa độ vẫn hiện")
	assert_has(_label_texts(_dev_tools(main)), "DEV · lần mở thứ %d" % opens)
	assert_eq(SaveProbe._read(PROBE_FILE), opens, "F5 không đếm thêm lần mở")


func test_f5_needs_dev() -> void:
	Log.debug_enabled = true
	var main: Node2D = _make_main()
	var tools: DevTools = _dev_tools(main)
	assert_eq(tools.f5_pressed.get_connections(), [], "không bật dev thì không nối F5")
	var old: BattleController = main._controller
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = KEY_F5
	ev.pressed = true
	tools._unhandled_input(ev)
	assert_eq(main._controller, old, "không nạp lại")
	for line: String in Log.get_lines():
		assert_false(line.contains("][dev]"), line)
	Log.debug_enabled = false


## Khối ```json trong báo cáo -> Dictionary.
func _report_json(report: String) -> Dictionary:
	var start: int = report.find("```json")
	assert_gt(start, -1, "báo cáo phải có khối json")
	var body: int = report.find("\n", start) + 1
	var end: int = report.find("```", body)
	var parser: JSON = JSON.new()
	assert_eq(parser.parse(report.substr(body, end - body)), OK, "khối json đọc được")
	return parser.data as Dictionary


## Phát lại báo cáo bằng chính bộ nạp + bộ chạy của game, trả bàn cuối.
func _replay_report(report: String) -> BattleState:
	var loaded: LoadResult = ScenarioLoader.parse_scenario(JSON.stringify(_report_json(report), "  "),
		"user://f2_report.json", "res://", AppState.stats)
	assert_eq(loaded.errors, [] as Array[String], "kịch bản trong báo cáo phải nạp được")
	var run: ScenarioRunner.ScenarioResult = ScenarioRunner.run(loaded.data as ScenarioData, AppState.stats)
	assert_true(run.passed, "kịch bản trong báo cáo phải chạy được: %s" % str(run.problems))
	return run.final_state


## F2 (Story 2.13): chỉ khi bật dev, ghi clipboard qua seam test, hiện thông báo, báo cáo đủ phần và PHÁT LẠI ĐÚNG
## bàn đang chơi (nối nhầm `snapshot()` / `round_start_snapshot()` / `round_commands()` sẽ trượt ở đây).
func test_f2_copies_report_only_with_dev() -> void:
	AppState.launch.dev = true
	Log.debug_enabled = true
	var main: Node2D = _make_main()
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 1, "ghi clipboard đúng một lần")
	assert_string_contains(copied[0], "\"phien_ban_dinh_dang\": 1")
	assert_string_contains(copied[0], "trận: tran_01")
	assert_string_contains(copied[0], "phiên bản: v")
	assert_string_contains(copied[0], "## Bàn hiện tại")
	assert_string_contains(copied[0], "## Nhật ký")
	var luc: String = ""
	for line: String in copied[0].split("\n"):
		if line.begins_with("lúc: "):
			luc = line
	assert_true(luc.contains("lần mở thứ"), "có dòng lúc + lần mở: %s" % luc)
	assert_false(luc.contains("T"), "giờ dùng dấu cách, không dùng dấu T: %s" % luc)
	assert_true(main.notice().is_shown(), "hiện thông báo")
	assert_eq(main.notice().text(), tr("dev.copied"))
	assert_ne(main.notice().text(), "dev.copied", "khóa dịch phải có thật trong text.csv")
	assert_has(Log.get_lines(), "[DEBUG][dev] f2: đã sao chép báo lỗi (%d ký tự)" % copied[0].length())
	assert_eq(BoardFixture.picture(_replay_report(copied[0])), BoardFixture.picture(main._controller.snapshot()),
		"báo cáo đã chép phát lại ra đúng bàn đang chơi")
	Log.debug_enabled = false


## Story 3.2: chơi lại rồi đi tiếp, báo cáo F2 vẫn phát lại ra đúng bàn đang chơi.
func test_f2_after_replay_replays_current_board() -> void:
	AppState.launch.dev = true
	Log.debug_enabled = true
	var main: Node2D = _make_main()
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	var view: BattleView = main._battle_view as BattleView
	view._on_cell_clicked(Vector2i(0, 6))
	view._on_cell_clicked(Vector2i(0, 4))
	view._on_replay()
	view._on_cell_clicked(Vector2i(0, 6))
	view._on_cell_clicked(Vector2i(0, 4))
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 1, "ghi clipboard đúng một lần")
	assert_eq(BoardFixture.picture(_replay_report(copied[0])),
		BoardFixture.picture(main._controller.snapshot()), "F2 sau chơi lại phát lại đúng bàn")
	Log.debug_enabled = false


func test_f2_is_not_wired_without_dev() -> void:
	AppState.launch.dev = false
	var main: Node2D = _make_main()
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 0, "không bật dev thì không nối F2")
	assert_false(main.notice().is_shown())


func test_f2_still_copies_on_error_screen() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main(_broken_level_dir())
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 1, "màn hình lỗi vẫn chép được")
	assert_string_contains(copied[0], "trận: tran_01 (không có bàn)", "vẫn biết trận nào hỏng")
	assert_string_contains(copied[0], "## Nhật ký")
	assert_false(copied[0].contains("```json"), "không có trận thì không có kịch bản")
	assert_eq(main.notice().text(), tr("dev.copied_no_battle"))


## Story 4.1 (FR45): mở game không chọn trận thì hiện màn hình chính, chưa nạp trận nào.
func test_no_tran_shows_main_menu() -> void:
	AppState.launch.tran = ""
	var main: Node2D = _make_main()
	var menu: MainMenu = main.main_menu()
	assert_eq(main._screen, main.Screen.MENU)
	assert_true(menu.visible)
	assert_null(main._controller)
	assert_false(main._board_view.visible, "bàn cờ ẩn")
	assert_false(main._title_label.visible, "tiêu đề trận ẩn (màn hình chính đã có tên game)")
	assert_false(main._hud.visible, "HUD ẩn")
	assert_true(main._version_label.visible, "nhãn phiên bản vẫn hiện")
	assert_lt(menu.get_index(), main._version_label.get_index(), "nhãn phiên bản nằm trên màn hình chính")
	for hidden: Node in [main._board_view, main._hud, main._tooltip, main._result_banner]:
		assert_lt(hidden.get_index(), menu.get_index(), "%s nằm dưới màn hình chính" % hidden.name)
	assert_eq(menu.new_game_button().text, tr("menu.new_game"))
	assert_eq(menu.new_game_button().focus_mode, Control.FOCUS_NONE, "nút không giữ focus: Space ở menu không bấm nút")
	var texts: Array[String] = _label_texts(menu)
	assert_has(texts, tr("app.title"))
	assert_has(texts, tr("menu.subtitle"))
	assert_eq(_tokens(main).size(), 0)
	assert_has(Log.get_lines(), "[INFO][app] mở màn hình chính")
	assert_does_not_have(Log.get_lines(), "[INFO][app] về menu", "mở game lần đầu: chưa rời màn nào")


## Bấm "Chơi mới" thì vào trận 1, như trận 1 mở trước đây.
func test_new_game_opens_level_1() -> void:
	AppState.launch.tran = ""
	var main: Node2D = _make_main()
	main.main_menu().new_game_button().pressed.emit()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_01")
	assert_false(main.main_menu().visible)
	assert_true(main._board_view.visible)
	assert_true(main._title_label.visible)
	assert_true(main._hud.visible)
	assert_has(Log.get_lines(), "[INFO][app] chơi mới")
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_01")
	assert_eq(_tokens(main).size(), 5)


## Bật dev và chọn trận thì vào thẳng trận đó, không qua màn hình chính.
func test_dev_tran_skips_main_menu() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = "3"
	var main: Node2D = _make_main()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_false(main.main_menu().visible)
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_03")


## Phím tắt trận và chuột trên bàn ở màn hình chính không làm gì: không vào trận, không chọn quân, không có cảnh báo hay lỗi.
## Kiểm trước là BattleInput có nhận phím và chuột (phát signal), để test không đạt suông khi phím không khớp action.
func test_battle_keys_do_nothing_on_main_menu() -> void:
	AppState.launch.tran = ""
	var main: Node2D = _make_main()
	var input: BattleInput = main._battle_input as BattleInput
	watch_signals(input)
	Log.clear()
	for key: Key in [KEY_SPACE, KEY_Z, KEY_R, KEY_Q, KEY_W, KEY_1, KEY_2, KEY_3]:
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = key
		ev.pressed = true
		input._unhandled_input(ev)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = main._board_view.get_global_transform_with_canvas() * BoardView.cell_center(Vector2i(0, 6))
	input._unhandled_input(click)
	for sig: String in ["end_turn_pressed", "undo_pressed", "replay_pressed", "stratagem_key_pressed",
			"general_key_pressed", "cell_clicked"]:
		assert_signal_emitted(input, sig, "BattleInput nhận được: " + sig)
	assert_eq(main._screen, main.Screen.MENU)
	assert_null(main._controller)
	assert_true(main.main_menu().visible)
	assert_eq((main._battle_view as BattleView).selected_id(), BattleView.NONE, "không chọn quân")
	for line: String in Log.get_lines():
		assert_false(line.begins_with("[WARN]") or line.begins_with("[ERROR]"), line)


## F2 ở màn hình chính (dev): chép báo lỗi "không có trận", thông báo nằm trên menu nên nhìn thấy.
func test_f2_on_main_menu_shows_notice_above_menu() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = ""
	var main: Node2D = _make_main()
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 1)
	assert_eq(main.notice().text(), tr("dev.copied_no_battle"))
	assert_gt(main.notice().get_index(), main.main_menu().get_index(), "thông báo vẽ sau màn hình chính")


## F3 (dev): bảng ý định AI nằm dưới màn hình chính, bật trong trận rồi về menu không vẽ đè tên game.
func test_ai_overlay_stays_under_main_menu() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	_dev_tools(main).f3_pressed.emit()
	assert_true(main._ai_overlay.visible, "F3 bật trong trận")
	main._show_menu()
	assert_true(main.main_menu().visible)
	assert_lt(main._ai_overlay.get_index(), main.main_menu().get_index(), "bảng F3 vẽ trước màn hình chính")


## Màn hình lỗi → Về menu → sửa file → Chơi mới: vào được trận, không giữ dữ liệu lỗi.
func test_new_game_after_error_screen() -> void:
	var main: Node2D = _make_main(_broken_level_dir())
	assert_eq(main._screen, main.Screen.ERROR)
	_find_button(main._error_screen).pressed.emit()
	assert_true(main.main_menu().visible)
	main.level_dir = "res://data/tran"
	main.main_menu().new_game_button().pressed.emit()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_null(main._error_screen)
	assert_eq(_tokens(main).size(), 5)


## F5 ở màn hình chính khi chưa mở trận nào: mở trận 1 (kiến trúc: F5 chạy ở mọi màn hình).
func test_f5_on_fresh_main_menu_opens_level_1() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = ""
	var main: Node2D = _make_main()
	assert_eq(main._screen, main.Screen.MENU)
	_press_f5(main)
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_01")
	assert_false(main.main_menu().visible)


# ---------- Chuỗi trận và màn chuyển trận (Story 4.2) ----------

## Kết thúc trận đang mở bằng pha cho trước, như lúc hoạt ảnh của lệnh cuối phát xong.
func _finish(main: Node2D, phase: BattleState.Phase, reason: String = "") -> void:
	var snapshot: BattleState = (main._controller as BattleController).snapshot()
	snapshot.phase = phase
	snapshot.defeat_reason = reason
	main._on_playback_finished(snapshot)


func _banner(main: Node2D) -> ResultBanner:
	return main._result_banner as ResultBanner


func _transition(main: Node2D) -> LevelTransition:
	return main.level_transition()


func _open(level: String) -> Node2D:
	AppState.launch.tran = level
	return _make_main()


func test_won_level_in_campaign_shows_next_only() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	assert_true(_banner(main).is_showing())
	assert_true(_banner(main).next_button().visible, "thắng trận trong chuỗi: nút Tiếp")
	assert_false(_banner(main).retry_button().visible)
	assert_false(_banner(main).menu_button().visible)


func test_next_shows_transition_to_level_2() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	assert_eq(main._screen, main.Screen.TRANSITION)
	assert_null(main._controller, "rời trận")
	assert_true(_transition(main).visible)
	assert_false(main.main_menu().visible)
	assert_false(main._board_view.visible, "bàn cờ ẩn")
	assert_false(main._title_label.visible, "tiêu đề trận ẩn")
	assert_false(main._hud.visible, "HUD ẩn")
	assert_false(_banner(main).is_showing(), "bảng kết quả ẩn")
	assert_true(main._version_label.visible)
	var texts: Array[String] = _label_texts(_transition(main))
	assert_has(texts, "Trận 2 — Ải Lãnh Kinh", "tên trận kế lấy từ file trận")
	assert_eq(_transition(main).stratagem_lines(), [] as Array[String], "trận 2 không mở mưu kế mới")
	assert_true(_transition(main).next_button().visible)
	assert_false(_transition(main).menu_button().visible)
	assert_eq(main._level_id, "tran_02")
	assert_has(Log.get_lines(), "[INFO][app] chuyển trận tran_01 -> tran_02")


## AC3: vào trận mới thì các tướng đủ máu theo chi_so.json, không mang máu từ trận trước.
func test_next_level_starts_with_full_hp() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	_transition(main).next_button().pressed.emit()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_02")
	assert_false(_transition(main).visible)
	assert_true(main._board_view.visible)
	assert_true(main._title_label.visible)
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_02")
	var generals: int = 0
	for unit: Unit in (main._controller as BattleController).snapshot().units:
		if UnitType.is_general(unit.type):
			generals += 1
			assert_eq(unit.hp, AppState.stats.max_hp(unit.type), "tướng %d đủ máu" % unit.id)
	assert_gt(generals, 0)


func test_transition_to_level_5_lists_new_stratagem() -> void:
	var main: Node2D = _open("4")
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	assert_eq(main._level_id, "tran_05")
	assert_eq(_transition(main).stratagem_lines(),
		[tr("transition.new_stratagem") % tr("stratagem.vuon_khong_nha_trong")] as Array[String],
		"trận 5 mở Vườn không nhà trống, trận 4 chưa có")


func test_last_level_won_shows_campaign_end_then_menu() -> void:
	var main: Node2D = _open("5")
	_finish(main, BattleState.Phase.WON)
	assert_true(_banner(main).next_button().visible, "trận cuối vẫn có Tiếp")
	_banner(main).next_button().pressed.emit()
	assert_eq(main._screen, main.Screen.TRANSITION)
	assert_has(_label_texts(_transition(main)), tr("transition.campaign_won"))
	assert_false(_transition(main).next_button().visible)
	assert_true(_transition(main).menu_button().visible)
	assert_eq(main._level_id, "tran_05", "F5 ở màn kết thúc mở lại trận cuối")
	assert_has(Log.get_lines(), "[INFO][app] thắng cả chiến dịch")
	_transition(main).menu_button().pressed.emit()
	assert_eq(main._screen, main.Screen.MENU)
	assert_true(main.main_menu().visible)
	assert_false(_transition(main).visible)


func test_lost_shows_retry_and_menu() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.LOST, "het_hiep")
	assert_false(_banner(main).next_button().visible)
	assert_true(_banner(main).retry_button().visible)
	assert_true(_banner(main).menu_button().visible)
	_banner(main).menu_button().pressed.emit()
	assert_eq(main._screen, main.Screen.MENU)
	assert_true(main.main_menu().visible)
	assert_null(main._controller)


func test_lost_retry_reopens_the_same_level() -> void:
	var main: Node2D = _open("3")
	var old: BattleController = main._controller
	_finish(main, BattleState.Phase.LOST)
	_banner(main).retry_button().pressed.emit()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_03")
	assert_ne(main._controller, old, "trận mở lại từ đầu")
	assert_false(_banner(main).is_showing())


func test_dev_level_outside_campaign_has_no_next() -> void:
	AppState.launch.dev = true
	var main: Node2D = _open("thu_muu_ke")
	_finish(main, BattleState.Phase.WON)
	assert_false(_banner(main).next_button().visible, "trận thử không nằm trong chuỗi")
	assert_true(_banner(main).retry_button().visible)
	assert_true(_banner(main).menu_button().visible)


func test_dev_level_in_campaign_continues_from_there() -> void:
	AppState.launch.dev = true
	var main: Node2D = _open("3")
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	_transition(main).next_button().pressed.emit()
	assert_eq(main._level_id, "tran_04")
	assert_eq(main._screen, main.Screen.BATTLE)


## Phím trận và chuột trên bàn ở màn chuyển trận không làm gì (như ở màn hình chính, Story 4.1).
func test_battle_keys_do_nothing_on_transition() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	var input: BattleInput = main._battle_input as BattleInput
	watch_signals(input)
	Log.clear()
	for key: Key in [KEY_SPACE, KEY_Z, KEY_R, KEY_Q, KEY_1]:
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = key
		ev.pressed = true
		input._unhandled_input(ev)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = main._board_view.get_global_transform_with_canvas() * BoardView.cell_center(Vector2i(0, 5))
	input._unhandled_input(click)
	for sig: String in ["end_turn_pressed", "undo_pressed", "replay_pressed", "stratagem_key_pressed",
			"general_key_pressed", "cell_clicked"]:
		assert_signal_emitted(input, sig, "BattleInput nhận được: " + sig)
	assert_eq(main._screen, main.Screen.TRANSITION)
	assert_null(main._controller)
	assert_eq((main._battle_view as BattleView).selected_id(), BattleView.NONE)
	for line: String in Log.get_lines():
		assert_false(line.begins_with("[WARN]") or line.begins_with("[ERROR]"), line)


func test_f2_on_transition_copies_and_notice_is_above() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	var copied: Array[String] = []
	main.clipboard_writer = func(text: String) -> void: copied.append(text)
	_dev_tools(main).f2_pressed.emit()
	assert_eq(copied.size(), 1)
	assert_eq(main.notice().text(), tr("dev.copied_no_battle"))
	assert_gt(main.notice().get_index(), _transition(main).get_index(), "thông báo vẽ sau màn chuyển trận")


func test_f5_on_transition_opens_next_level() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	_press_f5(main)
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_02")
	assert_false(_transition(main).visible)


func test_transition_layer_order() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var index: int = _transition(main).get_index()
	for below: Node in [main._board_view, main._hud, main._tooltip, main._result_banner, main._ai_overlay]:
		assert_lt(below.get_index(), index, "%s nằm dưới màn chuyển trận" % below.name)
	for above: Node in [main.notice(), main._version_label]:
		assert_gt(above.get_index(), index, "%s nằm trên màn chuyển trận" % above.name)


## "Chơi mới" mở trận đầu của chien_dich.json (không viết cứng tran_01).
func test_new_game_opens_first_level_of_campaign() -> void:
	AppState.launch.tran = ""
	_write_text(BROKEN_CAMPAIGN, JSON.stringify({"phien_ban_dinh_dang": 1, "tran": ["tran_03", "tran_04"]}))
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	main.campaign_path = BROKEN_CAMPAIGN
	add_child_autofree(main)
	main.main_menu().new_game_button().pressed.emit()
	assert_eq(main._level_id, "tran_03")
	assert_eq(main._screen, main.Screen.BATTLE)


func test_broken_campaign_shows_error_on_new_game() -> void:
	AppState.launch.tran = ""
	_write_text(BROKEN_CAMPAIGN, JSON.stringify({"phien_ban_dinh_dang": 1, "tran": ["tran_01", "tran_09"]}))
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	main.campaign_path = BROKEN_CAMPAIGN
	add_child_autofree(main)
	main.main_menu().new_game_button().pressed.emit()
	assert_eq(main._screen, main.Screen.ERROR)
	assert_null(main._controller)
	assert_has(Log.get_lines(),
		'[ERROR][data] user://test_main/chien_dich.json: "tran" có "tran_09" nhưng không có file data/tran/tran_09.json')


## Mưu kế "vừa mở" chỉ là mưu kế trận kế có mà trận vừa thắng chưa có (trận 6 sẽ mở thêm Sát Thát).
func test_transition_lists_only_stratagems_not_open_before() -> void:
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/tran/tran_05.json")) as Dictionary
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)
	var before: Dictionary = source.duplicate(true)
	before["muu_ke_mo"] = ["vuon_khong_nha_trong"]
	_write_text(LEVEL_DIR + "/tran_04.json", JSON.stringify(before))
	var after: Dictionary = source.duplicate(true)
	after["ten"] = "Trận thử mưu kế"
	after["muu_ke_mo"] = ["vuon_khong_nha_trong", "sat_that"]
	_write_text(LEVEL_DIR + "/tran_05.json", JSON.stringify(after))
	AppState.launch.tran = "4"
	var main: Node2D = _make_main(LEVEL_DIR)
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	assert_has(_label_texts(_transition(main)), "Trận thử mưu kế")
	assert_eq(_transition(main).stratagem_lines(),
		[tr("transition.new_stratagem") % tr("stratagem.sat_that")] as Array[String], "Vườn không nhà trống đã có từ trước")


## Về menu bỏ cả dữ liệu trận vừa rời: F2 ở menu không ghi tên trận cũ; F5 vẫn mở lại trận đang chọn.
func test_back_to_menu_drops_level_data() -> void:
	var main: Node2D = _make_main()
	assert_not_null(main._level)
	main._show_menu()
	assert_null(main._level)
	assert_null(AppState.stats)
	assert_eq(main._report_meta()["ten_tran"], "", "F2 ở menu: không có tên trận")
	assert_eq(main._level_id, "tran_01", "vẫn nhớ trận đang chọn cho F5")


## Về menu quên ô chuột đang trỏ trên bàn: vào trận lại, ô cũ không sáng lại khi chuột đã ở chỗ khác (menu chặn chuột).
func test_back_to_menu_forgets_hovered_cell() -> void:
	var main: Node2D = _make_main()
	var input: BattleInput = main._battle_input as BattleInput
	var board: BoardView = main._board_view as BoardView
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = board.get_global_transform_with_canvas() * BoardView.cell_center(Vector2i(1, 1))
	input._unhandled_input(motion)
	assert_eq(input.hovered_cell(), Vector2i(1, 1))
	main._show_menu()
	assert_eq(input.hovered_cell(), BoardView.NO_CELL)
	main.main_menu().new_game_button().pressed.emit()
	input.refresh_hover()
	assert_eq(input.hovered_cell(), BoardView.NO_CELL, "không chọn lại ô cũ")


func _write_save(text: String) -> void:
	var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _menu_after_open() -> Node2D:
	AppState.launch.tran = ""
	return _make_main()


## Story 4.3 (FR45): chưa có file lưu thì màn hình chính chỉ có "Chơi mới".
func test_no_save_no_continue_button() -> void:
	var main: Node2D = _menu_after_open()
	assert_false(main.main_menu().continue_button().visible)
	assert_false(main.main_menu().save_broken_label().visible)
	assert_true(main.main_menu().new_game_button().visible)


## Thắng trận giữa chuỗi rồi "Tiếp": lưu trận kế tiếp (FR46).
func test_winning_saves_next_level() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	assert_false(FileAccess.file_exists(SAVE_FILE), "chưa bấm Tiếp thì chưa lưu")
	_banner(main).next_button().pressed.emit()
	assert_eq(JSON.parse_string(FileAccess.get_file_as_string(SAVE_FILE)), {"phien_ban": 1.0, "tran_tiep": "tran_02"})
	assert_has(Log.get_lines(), "[INFO][save] đã lưu: trận tiếp tran_02")


## Mở lại game (main mới) sau khi lưu: có "Chơi tiếp" trên "Chơi mới"; bấm thì vào đúng trận đã lưu, tướng đủ máu.
func test_continue_after_reopen_opens_saved_level() -> void:
	var first: Node2D = _make_main()
	_finish(first, BattleState.Phase.WON)
	_banner(first).next_button().pressed.emit()
	var main: Node2D = _menu_after_open()
	var menu: MainMenu = main.main_menu()
	assert_true(menu.continue_button().visible)
	assert_eq(menu.continue_button().text, tr("menu.continue"))
	assert_lt(menu.continue_button().get_index(), menu.new_game_button().get_index(), "Chơi tiếp nằm trên Chơi mới")
	assert_eq(menu.continue_button().focus_mode, Control.FOCUS_NONE)
	menu.continue_button().pressed.emit()
	assert_eq(main._screen, main.Screen.BATTLE)
	assert_eq(main._level_id, "tran_02")
	assert_has(Log.get_lines(), "[INFO][battle] nạp trận tran_02")
	for u: Unit in (main._controller as BattleController).snapshot().units:
		if u.faction == Unit.Faction.DAI_VIET:
			assert_eq(u.hp, AppState.stats.max_hp(u.type), "tướng đủ máu")


## Về menu sau khi lưu (không cần mở lại game) cũng thấy "Chơi tiếp".
func test_back_to_menu_after_save_shows_continue() -> void:
	var main: Node2D = _make_main()
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	main._show_menu()
	assert_true(main.main_menu().continue_button().visible)


## Thắng trận cuối: xóa file lưu, màn hình chính không còn "Chơi tiếp".
func test_last_level_won_clears_save() -> void:
	_write_save('{"phien_ban": 1, "tran_tiep": "tran_05"}')
	var main: Node2D = _open("5")
	_finish(main, BattleState.Phase.WON)
	_banner(main).next_button().pressed.emit()
	assert_false(FileAccess.file_exists(SAVE_FILE))
	assert_has(Log.get_lines(), "[INFO][save] xóa file lưu: đã thắng cả chiến dịch")
	_transition(main).menu_button().pressed.emit()
	assert_false(main.main_menu().continue_button().visible)


## File lưu hỏng: không sập, dòng báo nhẹ, không có "Chơi tiếp", log ERROR có tên file; "Chơi mới" vẫn vào trận 1.
func test_broken_save_shows_notice_and_allows_new_game() -> void:
	var cases: Dictionary = {
		"{hỏng": "user://test_main_save.json, dòng 1: JSON sai cú pháp",
		"[1]": "user://test_main_save.json: nội dung phải là một object JSON",
		'{"phien_ban": 2, "tran_tiep": "tran_02"}': 'user://test_main_save.json: "phien_ban" là 2, game chỉ đọc được bản 1',
		'{"phien_ban": 1, "tran_tiep": "tran_99"}':
			'user://test_main_save.json: "tran_tiep" là "tran_99", không có trong chuỗi trận',
	}
	for text: String in cases:
		_write_save(text)
		Log.clear()
		var main: Node2D = _menu_after_open()
		var menu: MainMenu = main.main_menu()
		assert_false(menu.continue_button().visible, text)
		assert_true(menu.save_broken_label().visible, text)
		assert_eq(menu.save_broken_label().text, tr("menu.save_broken"))
		var found: bool = false
		for line: String in Log.get_lines():
			if line.begins_with("[ERROR][save] " + (cases[text] as String)):
				found = true
		assert_true(found, "log ERROR cho %s" % text)
		assert_true(FileAccess.file_exists(SAVE_FILE), "không xóa file hỏng")
		menu.new_game_button().pressed.emit()
		assert_eq(main._level_id, "tran_01", text)
		assert_eq(main._screen, main.Screen.BATTLE, text)
