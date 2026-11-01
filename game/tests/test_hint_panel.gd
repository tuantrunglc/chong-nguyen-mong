extends GutTest
## Gợi ý luật đầu trận và bảng thao tác (Story 4.8): hiện đúng lúc, nuốt cú bấm, nuốt phím, nút/phím "?".
## Màn hình gốc chạy trong SubViewport 1280×720 như test_battle_view: GUI chia chuột trước, phần còn lại mới tới
## _unhandled_input, nên "bấm xuyên" được kiểm đúng như người chơi.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const SAVE_FILE: String = "user://test_hint_save.json"

var _old_save_path: String = ""
var _old_tran: String = ""


func before_each() -> void:
	_old_save_path = SaveSystem.path
	SaveSystem.path = SAVE_FILE
	_old_tran = AppState.launch.tran
	AppState.hints_enabled = true
	AppState.launch.tran = "1"


func after_each() -> void:
	AppState.hints_enabled = false
	AppState.launch.tran = _old_tran
	SaveSystem.path = _old_save_path
	if FileAccess.file_exists(SAVE_FILE):
		DirAccess.remove_absolute(SAVE_FILE)


func _make_main() -> Node2D:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child_autofree(viewport)
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	main.stats_path = StatsSnapshot.PATH
	viewport.add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	return main


func _panel(main: Node2D) -> HintPanel:
	return main._hint_panel as HintPanel


func _hud(main: Node2D) -> Hud:
	return main._hud as Hud


func _push(main: Node2D, event: InputEvent) -> void:
	main.get_viewport().push_input(event, true)


func _click_at(main: Node2D, point: Vector2) -> void:
	for pressed: bool in [true, false]:
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = point
		_push(main, click)


func _click_cell(main: Node2D, cell: Vector2i) -> void:
	var board: BoardView = main._board_view as BoardView
	_click_at(main, board.get_global_transform_with_canvas() * BoardView.cell_center(cell))


func _key(main: Node2D, keycode: Key, unicode: int = 0) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = keycode
	ev.physical_keycode = keycode
	ev.unicode = unicode
	ev.pressed = true
	_push(main, ev)


## "?" gõ bằng Shift+/ : keycode là "/" nhưng ký tự là "?".
func _question_mark(main: Node2D) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = KEY_SLASH
	ev.physical_keycode = KEY_SLASH
	ev.shift_pressed = true
	ev.unicode = HintPanel.QUESTION_UNICODE
	ev.pressed = true
	_push(main, ev)


func test_hint_shows_when_opening_phase_is_done() -> void:
	var main: Node2D = await _make_main()
	assert_true(_panel(main).is_open(), "trận 1 có gợi ý nên bảng hiện lúc vào trận")
	assert_eq(_panel(main).hint_lines(), [tr("hint.tran_01.1")] as Array[String])
	assert_true(_panel(main).texts().has(tr("hint.more")), "có dòng nhắc phím ?")
	assert_false(_panel(main).texts().has(tr("help.title")), "bảng đầu trận chưa có bảng thao tác")


func test_no_hint_when_disabled_or_level_has_none() -> void:
	AppState.hints_enabled = false
	var main: Node2D = await _make_main()
	assert_false(_panel(main).is_open(), "công tắc tắt thì không tự hiện")
	AppState.hints_enabled = true
	AppState.launch.tran = "thu_day"
	var plain: Node2D = await _make_main()
	assert_false(_panel(plain).is_open(), "trận không có goi_y thì không hiện")


func test_click_closes_panel_without_reaching_the_board() -> void:
	var main: Node2D = await _make_main()
	var khoai: Vector2i = (main._controller as BattleController).snapshot().unit_by_id(1).cell
	_click_cell(main, khoai)
	assert_false(_panel(main).is_open(), "bấm bất kỳ đâu thì tắt")
	assert_eq((main._battle_view as BattleView).selected_id(), BattleView.NONE, "cú bấm chỉ tắt bảng, không chọn tướng")
	_click_cell(main, khoai)
	assert_eq((main._battle_view as BattleView).selected_id(), 1, "bảng đã tắt thì bấm lại chọn được tướng")


func test_keys_do_nothing_while_open_then_work_after_closing() -> void:
	var main: Node2D = await _make_main()
	_key(main, KEY_SPACE)
	assert_eq(_hud(main).round_text(), "Hiệp 1", "Space khi bảng hiện không kết thúc lượt")
	assert_true(_panel(main).is_open(), "Space không tắt bảng")
	_key(main, KEY_ESCAPE)
	assert_false(_panel(main).is_open(), "Esc tắt bảng")
	_key(main, KEY_SPACE)
	assert_eq(_hud(main).round_text(), "Hiệp 2", "bảng tắt thì Space kết thúc lượt")


func test_question_mark_toggles_help_with_any_layout() -> void:
	AppState.launch.tran = "thu_day"
	var main: Node2D = await _make_main()
	_question_mark(main)
	assert_true(_panel(main).is_open(), "phím ? mở bảng")
	var texts: Array[String] = _panel(main).texts()
	assert_true(texts.has(tr("help.title")))
	for row: Array in HintPanel.HELP_ROWS:
		assert_true(texts.has(tr(row[0] as String)), "có thao tác %s" % row[0])
		assert_true(texts.has(tr(row[1] as String)), "có cách làm %s" % row[1])
	assert_eq(_panel(main).hint_lines(), [] as Array[String], "trận không có gợi ý thì chỉ có bảng thao tác")
	_question_mark(main)
	assert_false(_panel(main).is_open(), "? lần nữa tắt bảng")
	# Bàn phím khác: "?" ở vị trí phím khác, vẫn nhận theo ký tự.
	var other: InputEventKey = InputEventKey.new()
	other.keycode = KEY_QUESTION
	other.physical_keycode = KEY_MINUS
	other.unicode = HintPanel.QUESTION_UNICODE
	other.pressed = true
	_push(main, other)
	assert_true(_panel(main).is_open(), "nhận theo ký tự, không theo vị trí phím")


func test_help_button_works_while_locked_and_includes_level_hint() -> void:
	var main: Node2D = await _make_main()
	_key(main, KEY_ESCAPE)
	_hud(main).set_locked(true)
	var button: Button = _hud(main).help_button()
	assert_false(button.disabled, "nút ? không bị khóa khi đang phát hoạt ảnh")
	button.pressed.emit()
	assert_true(_panel(main).is_open())
	assert_eq(_panel(main).hint_lines(), [tr("hint.tran_01.1")] as Array[String], "có cả gợi ý của trận")
	assert_true(_panel(main).texts().has(tr("help.title")))


func test_replay_round_does_not_show_hint_again_but_retry_does() -> void:
	var main: Node2D = await _make_main()
	_key(main, KEY_ESCAPE)
	_hud(main).end_turn_button().pressed.emit()
	_key(main, KEY_R)
	assert_false(_panel(main).is_open(), "Chơi lại hiệp không hiện lại gợi ý")
	main._start_battle()
	assert_true(_panel(main).is_open(), "mở lại trận (Đánh lại trận này) thì hiện lại")
	_key(main, KEY_ESCAPE)
	main._start_battle(false)
	assert_false(_panel(main).is_open(), "F5 nạp lại dữ liệu không hiện lại gợi ý")


func test_leaving_the_battle_closes_the_panel() -> void:
	var main: Node2D = await _make_main()
	assert_true(_panel(main).is_open())
	main._show_menu()
	assert_false(_panel(main).is_open(), "về menu thì bảng đóng")
	_question_mark(main)
	assert_false(_panel(main).is_open(), "ở menu thì phím ? không mở bảng")
