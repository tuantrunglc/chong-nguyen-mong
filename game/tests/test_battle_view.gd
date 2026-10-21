extends GutTest
## Trận 1 thật: chọn tướng (Story 1.4: phím 1-2-3, bấm, bỏ chọn, ô sáng, đường đi) và đi, hủy,
## kết thúc lượt, bảng nút (Story 1.5).
## Trận 1 và chi_so.json thật: tướng ở 0,6 và 2,6, sông cột 3 (trừ hàng 3), tầm đi 3.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_battle_view"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const BROKEN_DIR: String = PROBE_DIR + "/tran"
const BROKEN_LEVEL: String = BROKEN_DIR + "/tran_01.json"
## Trận thử cho đòn đánh (Story 2.1): trận 1 thật không có quân Nguyên nào kề tướng lúc đầu.
const ATTACK_DIR: String = PROBE_DIR + "/tran_danh"
const ATTACK_LEVEL: String = ATTACK_DIR + "/tran_01.json"
## Trận thử cho tướng mình đứng kề (Story 2.2, FR16).
const ALLY_DIR: String = PROBE_DIR + "/tran_dong_minh"
const ALLY_LEVEL: String = ALLY_DIR + "/tran_01.json"
const LAO_DIR: String = PROBE_DIR + "/tran_lao"
const LAO_LEVEL: String = LAO_DIR + "/tran_01.json"
const KEO_DIR: String = PROBE_DIR + "/tran_keo"
const KEO_LEVEL: String = KEO_DIR + "/tran_01.json"
## Phím chọn Dư (tướng thứ ba).
const KEO_KEY: Key = KEY_3
const WIN_DIR: String = PROBE_DIR + "/tran_thang"
const WIN_LEVEL: String = WIN_DIR + "/tran_01.json"

## Ô sáng mong đợi trên trận 1 (AC 4, AC 5), theo thứ tự đọc bàn.
const KHOAI_CELLS: Array[Vector2i] = [
	Vector2i(0, 3), Vector2i(0, 4), Vector2i(1, 4), Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(1, 6),
]
const LAO_CELLS: Array[Vector2i] = [
	Vector2i(2, 3), Vector2i(1, 4), Vector2i(2, 4), Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(1, 6),
]
const KHOAI_CELL: Vector2i = Vector2i(0, 6)
const LAO_CELL: Vector2i = Vector2i(2, 6)


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(PROBE_DIR)
	SaveProbe.path = PROBE_FILE


func after_each() -> void:
	AppState.launch.dev = false
	AppState.launch.tran = ""
	AppState.launch.warnings.clear()
	AppState.stats = null
	for action: String in BattleInput.ACTION_KEYS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	for i: int in range(DevTools.KEYS.size()):
		if InputMap.has_action("dev_f%d" % (i + 1)):
			InputMap.erase_action("dev_f%d" % (i + 1))
	SaveProbe.path = SaveProbe.DEFAULT_PATH
	for path: String in [BROKEN_LEVEL, ATTACK_LEVEL, ALLY_LEVEL, LAO_LEVEL, KEO_LEVEL, WIN_LEVEL, PROBE_FILE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(BROKEN_DIR)
	DirAccess.remove_absolute(ATTACK_DIR)
	DirAccess.remove_absolute(ALLY_DIR)
	DirAccess.remove_absolute(LAO_DIR)
	DirAccess.remove_absolute(KEO_DIR)
	DirAccess.remove_absolute(WIN_DIR)
	DirAccess.remove_absolute(PROBE_DIR)
	Log.clear()


func _make_main(level_dir: String = "") -> Node2D:
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	if not level_dir.is_empty():
		main.level_dir = level_dir
	add_child_autofree(main)
	return main


func _view(main: Node2D) -> BattleView:
	return main._battle_view as BattleView


func _board(main: Node2D) -> BoardView:
	return main._board_view as BoardView


func _battle_input(main: Node2D) -> BattleInput:
	return main._battle_input as BattleInput


## Gửi một phím 1-2-3 qua InputMap, như khi người chơi gõ phím.
func _press_key(main: Node2D, index: int) -> void:
	var ev: InputEventAction = InputEventAction.new()
	ev.action = "select_general_%d" % index
	ev.pressed = true
	_battle_input(main)._unhandled_input(ev)


## Di chuột thật tới tâm ô (qua BattleInput, như người chơi rê chuột).
func _hover_by_mouse(main: Node2D, cell: Vector2i) -> void:
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _board(main).get_global_transform_with_canvas() * BoardView.cell_center(cell)
	_battle_input(main)._unhandled_input(motion)


func _click(main: Node2D, cell: Vector2i) -> void:
	_view(main)._on_cell_clicked(cell)


func _hover(main: Node2D, cell: Vector2i) -> void:
	_view(main)._on_cell_hovered(cell)


func _assert_selected(main: Node2D, id: int, cells: Array[Vector2i], unit_cell: Vector2i) -> void:
	assert_eq(_view(main).selected_id(), id)
	assert_eq(_view(main).lit_cells(), cells)
	assert_eq(_board(main).lit_cells(), cells, "bàn cờ tô đúng các ô đó")
	assert_eq(_board(main)._selected_cell, unit_cell, "vòng chọn ở ô của tướng")


func _assert_nothing_selected(main: Node2D) -> void:
	assert_eq(_view(main).selected_id(), BattleView.NONE)
	assert_eq(_board(main).lit_cells(), [] as Array[Vector2i])
	assert_eq(_board(main)._selected_cell, BoardView.NO_CELL)
	assert_eq(_board(main).path(), [] as Array[Vector2i])


func test_key_1_selects_khoai_and_lights_7_cells() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)
	assert_does_not_have(_board(main).lit_cells(), LAO_CELL, "ô của Lão không sáng")


## Phím 1 thật trên bàn phím (phím vật lý), không gửi thẳng action.
func test_physical_keys_select_generals() -> void:
	var main: Node2D = _make_main()
	for item: Array in [[KEY_1, 1], [KEY_2, 2]]:
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = item[0] as Key
		ev.pressed = true
		_battle_input(main)._unhandled_input(ev)
		assert_eq(_view(main).selected_id(), item[1] as int)


func test_key_never_selects_enemy() -> void:
	var main: Node2D = _make_main()
	_view(main)._on_general_key(101)
	_assert_nothing_selected(main)


func test_click_on_khoai_selects_him() -> void:
	var main: Node2D = _make_main()
	_click(main, KHOAI_CELL)
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)


func test_key_2_switches_to_lao() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_press_key(main, 2)
	_assert_selected(main, 2, LAO_CELLS, LAO_CELL)
	assert_does_not_have(_board(main).lit_cells(), KHOAI_CELL, "ô của Khoái không sáng")


func test_click_on_lao_switches_to_him() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, LAO_CELL)
	_assert_selected(main, 2, LAO_CELLS, LAO_CELL)


func test_key_3_without_du_changes_nothing() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 3)
	_assert_nothing_selected(main)
	_press_key(main, 1)
	_press_key(main, 3)
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)


func test_key_3_selects_du_on_three_generals_level() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = "thu_ba_tuong"
	var main: Node2D = _make_main()
	_press_key(main, 3)
	assert_eq(_view(main).selected_id(), 3)
	assert_gt(_board(main).lit_cells().size(), 0)


func test_same_key_or_click_again_deselects() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_press_key(main, 1)
	_assert_nothing_selected(main)
	_click(main, KHOAI_CELL)
	_click(main, KHOAI_CELL)
	_assert_nothing_selected(main)


func test_click_on_unlit_cell_deselects() -> void:
	var main: Node2D = _make_main()
	for cell: Vector2i in [Vector2i(3, 6), Vector2i(1, 0), Vector2i(6, 6), BoardView.NO_CELL]:
		_press_key(main, 1)
		_click(main, cell)
		_assert_nothing_selected(main)


# ---------- Đi, hủy, kết thúc lượt (Story 1.5) ----------

const KHOAI_TARGET: Vector2i = Vector2i(0, 4)
const LAO_TARGET: Vector2i = Vector2i(2, 4)


func _controller(main: Node2D) -> BattleController:
	return main._controller as BattleController


func _hud(main: Node2D) -> Hud:
	return main._hud as Hud


func _unit_cell(main: Node2D, id: int) -> Vector2i:
	return _controller(main).snapshot().unit_by_id(id).cell


func _token(main: Node2D, id: int) -> UnitToken:
	return _board(main).tokens()[id] as UnitToken


## Bấm chuột thật vào tâm ô (qua BattleInput).
func _click_by_mouse(main: Node2D, cell: Vector2i) -> void:
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = _board(main).get_global_transform_with_canvas() * BoardView.cell_center(cell)
	_battle_input(main)._unhandled_input(click)


## Phím thật trên bàn phím (phím vật lý).
func _press_physical(main: Node2D, key: Key, echo: bool = false) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = key
	ev.pressed = true
	ev.echo = echo
	_battle_input(main)._unhandled_input(ev)


func test_click_on_lit_cell_moves_and_keeps_selection() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click_by_mouse(main, KHOAI_TARGET)
	assert_eq(_unit_cell(main, 1), KHOAI_TARGET)
	assert_eq(_token(main, 1).position, BoardView.cell_center(KHOAI_TARGET), "đồng quân sang ô mới")
	assert_true(_token(main, 1).is_moved(), "dấu đã đi")
	assert_false(_token(main, 2).is_moved(), "Lão chưa đi")
	_assert_selected(main, 1, [] as Array[Vector2i], KHOAI_TARGET)
	assert_false(_hud(main).undo_button().disabled, "nút Hủy sáng")


func test_selecting_moved_general_shows_no_lit_cells() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	_press_key(main, 2)
	_press_key(main, 1)
	_assert_selected(main, 1, [] as Array[Vector2i], KHOAI_TARGET)


func test_key_z_undoes_and_lights_cells_again() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	_press_physical(main, KEY_Z)
	assert_eq(_unit_cell(main, 1), KHOAI_CELL)
	assert_false(_token(main, 1).is_moved())
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)
	assert_true(_hud(main).undo_button().disabled, "đã hủy thì nút Hủy mờ")


func test_undo_button_undoes_only_the_last_move() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	_press_key(main, 2)
	_click(main, LAO_TARGET)
	_hud(main).undo_button().pressed.emit()
	assert_eq(_unit_cell(main, 2), LAO_CELL, "Lão về chỗ cũ")
	assert_eq(_unit_cell(main, 1), KHOAI_TARGET, "Khoái vẫn ở ô mới")
	assert_true(_hud(main).undo_button().disabled)
	_press_physical(main, KEY_Z)
	assert_eq(_unit_cell(main, 1), KHOAI_TARGET, "hủy lần hai không làm gì")
	assert_true(_token(main, 1).is_moved())


func test_undo_with_nothing_to_undo_does_nothing() -> void:
	var main: Node2D = _make_main()
	assert_true(_hud(main).visible)
	assert_true(_hud(main).undo_button().disabled, "chưa đi thì nút Hủy mờ")
	_press_physical(main, KEY_Z)
	assert_eq(_unit_cell(main, 1), KHOAI_CELL)
	assert_eq(_unit_cell(main, 2), LAO_CELL)


func test_space_ends_turn() -> void:
	var main: Node2D = _make_main()
	assert_eq(_hud(main).round_text(), "Hiệp 1")
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	_press_physical(main, KEY_SPACE)
	assert_eq(_hud(main).round_text(), "Hiệp 2")
	_assert_nothing_selected(main)
	assert_false(_token(main, 1).is_moved(), "hết dấu đã đi")
	assert_true(_hud(main).undo_button().disabled, "không hủy được nước của lượt trước")
	_press_key(main, 1)
	assert_gt(_view(main).lit_cells().size(), 0, "Khoái đi lại được")


func test_end_turn_button_and_held_space() -> void:
	var main: Node2D = _make_main()
	_hud(main).end_turn_button().pressed.emit()
	assert_eq(_hud(main).round_text(), "Hiệp 2")
	_press_physical(main, KEY_SPACE, true)
	assert_eq(_hud(main).round_text(), "Hiệp 2", "giữ phím (lặp) không kết thúc thêm lượt")


## Màn hình gốc trong SubViewport riêng 1280×720: bảng kết quả của GUT nằm đè lên viewport gốc và nuốt chuột.
func _make_main_in_viewport() -> Node2D:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	add_child_autofree(viewport)
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	viewport.add_child(main)
	await _wait_layout()
	return main


## Gửi sự kiện qua viewport thật (như người chơi), để nút được nhận trước BattleInput.
func _push(main: Node2D, event: InputEvent) -> void:
	main.get_viewport().push_input(event, true)


## Bấm chuột trái vào giữa nút (nhấn rồi nhả: nút chạy khi nhả).
func _click_button(main: Node2D, button: Button) -> void:
	for pressed: bool in [true, false]:
		var click: InputEventMouseButton = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = pressed
		click.position = button.get_global_rect().get_center()
		_push(main, click)


## Chờ bảng nút xếp chỗ xong (container xếp con ở khung hình sau).
func _wait_layout() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


## Nút nhận focus thì Space (ui_accept) bấm lại nút vừa bấm bằng chuột: bấm Hủy rồi gõ Space sẽ hủy thay vì
## kết thúc lượt (AC 9).
func test_click_undo_button_then_space_ends_turn() -> void:
	var main: Node2D = await _make_main_in_viewport()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	_click_button(main, _hud(main).undo_button())
	assert_eq(_unit_cell(main, 1), KHOAI_CELL, "bấm nút Hủy bằng chuột: đã hủy")
	# Godot chạy không màn hình không đưa Space (ui_accept) tới nút đang focus, nên kiểm thẳng điều kiện của lỗi.
	assert_null(main.get_viewport().gui_get_focus_owner(), "bấm chuột không để nút giữ focus")
	_click(main, KHOAI_TARGET)
	var space: InputEventKey = InputEventKey.new()
	space.keycode = KEY_SPACE
	space.physical_keycode = KEY_SPACE
	space.pressed = true
	_push(main, space)
	assert_eq(_hud(main).round_text(), "Hiệp 2", "Space kết thúc đúng một lượt")
	assert_eq(_unit_cell(main, 1), KHOAI_TARGET, "Space không bấm lại nút Hủy")


## Rê thẳng từ ô sáng lên nút: đường đi phải mất. Godot 4.7 vẫn chuyển sự kiện di chuột trên nút tới
## _unhandled_input (đã thử khi review Story 1.5); test này giữ điều đó.
func test_mouse_onto_button_clears_path() -> void:
	var main: Node2D = await _make_main_in_viewport()
	_press_key(main, 1)
	_hover_by_mouse(main, Vector2i(2, 5))
	assert_false(_board(main).path().is_empty())
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _hud(main).end_turn_button().get_global_rect().get_center()
	_push(main, motion)
	assert_eq(_board(main).path(), [] as Array[Vector2i])
	assert_eq(_battle_input(main).hovered_cell(), BoardView.NO_CELL)


func test_hud_buttons_never_take_focus() -> void:
	var main: Node2D = _make_main()
	for button: Button in [_hud(main).undo_button(), _hud(main).end_turn_button()]:
		assert_eq(button.focus_mode, Control.FOCUS_NONE)
	assert_eq(_hud(main).undo_button().text, "Hủy (Z)")
	assert_eq(_hud(main).end_turn_button().text, "Kết thúc lượt (Space)")


func test_coord_overlay_follows_moved_unit() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	var expected: Vector2 = BoardView.cell_center(KHOAI_TARGET) \
		+ Vector2(UnitToken.RADIUS, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
	var found: bool = false
	for child: Node in (main._coord_overlay as CoordOverlay).get_children():
		if child.is_queued_for_deletion() or child.get_child_count() == 0:
			continue
		var label: Label = child.get_child(0) as Label
		if label != null and label.text == "1":
			assert_eq((child as Control).position, expected, "id 1 cạnh đầu đồng ở ô mới")
			found = true
	assert_true(found, "lớp F1 có id 1")


## Bàn chạy F1: nhãn tọa độ không nuốt chuột, bấm xuyên xuống bàn cờ.
func test_coord_labels_let_mouse_through() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var overlay: CoordOverlay = main._coord_overlay as CoordOverlay
	assert_gt(overlay.get_child_count(), 0)
	for child: Node in overlay.get_children():
		assert_eq((child as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
		assert_eq((child.get_child(0) as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)


## Chuột đứng yên trên đất ô 0,4, đúng chỗ đầu đồng sẽ che khi Khoái sang 0,5: ô dưới chuột đổi theo,
## hủy nước đi thì về lại 0,4 và vẽ đường đi tới đó.
func test_resting_mouse_follows_token_moving_under_it() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	var point: Vector2 = BoardView.cell_center(Vector2i(0, 5)) + Vector2(0, -40)
	assert_eq(_board(main).cell_at(point), Vector2i(0, 4), "đất của ô 0,4")
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = _board(main).get_global_transform_with_canvas() * point
	_battle_input(main)._unhandled_input(motion)
	assert_eq(_battle_input(main).hovered_cell(), Vector2i(0, 4))
	_click(main, Vector2i(0, 5))
	assert_eq(_battle_input(main).hovered_cell(), Vector2i(0, 5), "đầu đồng Khoái che chỗ chuột")
	_press_physical(main, KEY_Z)
	assert_eq(_battle_input(main).hovered_cell(), Vector2i(0, 4))
	assert_eq(_board(main).path(), [Vector2i(0, 5), Vector2i(0, 4)] as Array[Vector2i])


func test_hover_lit_cell_draws_path() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_hover(main, Vector2i(2, 5))
	assert_eq(_board(main).path(), [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)] as Array[Vector2i])
	_hover(main, Vector2i(3, 5))
	assert_eq(_board(main).path(), [] as Array[Vector2i], "rê ra ô sông: hết đường đi")


## Chuột nằm sẵn trên ô sẽ sáng, rồi mới gõ phím: đường đi hiện ngay, không cần rê đi rê lại.
func test_selecting_under_resting_mouse_draws_path_at_once() -> void:
	var main: Node2D = _make_main()
	_hover_by_mouse(main, Vector2i(1, 5))
	_press_key(main, 1)
	assert_eq(_board(main).path(), [Vector2i(0, 5), Vector2i(1, 5)] as Array[Vector2i])
	_press_key(main, 2)
	assert_eq(_board(main).path(), [Vector2i(2, 5), Vector2i(1, 5)] as Array[Vector2i], "đổi tướng: đường của Lão")


func test_mouse_leaving_window_clears_path() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_hover_by_mouse(main, Vector2i(2, 5))
	assert_false(_board(main).path().is_empty())
	main.get_window().mouse_exited.emit()
	assert_eq(_board(main).path(), [] as Array[Vector2i])
	_hover_by_mouse(main, Vector2i(2, 5))
	assert_false(_board(main).path().is_empty(), "quay lại đúng ô cũ: vẽ lại")


func test_hover_without_selection_draws_nothing() -> void:
	var main: Node2D = _make_main()
	_hover(main, Vector2i(0, 5))
	assert_eq(_board(main).path(), [] as Array[Vector2i])


func test_keys_do_nothing_on_error_screen() -> void:
	DirAccess.make_dir_recursive_absolute(BROKEN_DIR)
	var file: FileAccess = FileAccess.open(BROKEN_LEVEL, FileAccess.WRITE)
	file.store_string("[]")
	file.close()
	var main: Node2D = _make_main(BROKEN_DIR)
	assert_eq(main._screen, main.Screen.ERROR)
	_press_key(main, 1)
	_click(main, KHOAI_CELL)
	_assert_nothing_selected(main)
	assert_false(_hud(main).visible, "màn hình lỗi không có bảng nút")
	_press_physical(main, KEY_Z)
	_press_physical(main, KEY_SPACE)
	_assert_nothing_selected(main)


func test_back_to_menu_clears_selection() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, KHOAI_TARGET)
	var controller: BattleController = _controller(main)
	main._show_menu()
	_assert_nothing_selected(main)
	assert_false(_hud(main).visible, "màn menu không có bảng nút")
	_press_key(main, 1)
	_click(main, KHOAI_CELL)
	_assert_nothing_selected(main)
	_press_physical(main, KEY_Z)
	_press_physical(main, KEY_SPACE)
	assert_eq(controller.snapshot().unit_by_id(1).cell, KHOAI_TARGET, "Z không hủy")
	assert_eq(controller.snapshot().round_number, 1, "Space không kết thúc lượt")
	assert_false(_hud(main).visible)


func test_restart_battle_clears_selection() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	main._start_battle()
	_assert_nothing_selected(main)


## Vị trí lấy từ sự kiện chuột (pixel màn hình), không từ con trỏ thật.
func test_mouse_events_map_screen_pixels_to_cells() -> void:
	var main: Node2D = _make_main()
	var board: BoardView = _board(main)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = board.get_global_transform_with_canvas() * BoardView.cell_center(KHOAI_CELL)
	_battle_input(main)._unhandled_input(click)
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = board.get_global_transform_with_canvas() * BoardView.cell_center(Vector2i(2, 5))
	_battle_input(main)._unhandled_input(motion)
	assert_eq(board.path(), [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)] as Array[Vector2i])


# ---------- Đánh (Story 2.1) ----------

## Khoái ở 3,4 kề Bộ binh 3,3 (Bắc) và Kỵ binh 4,4 (Đông); thêm Bộ binh 5,5 kề Lão 5,6. Mọi quân Nguyên đã đứng kề
## tướng nó nhắm nên pha địch chuẩn bị lúc mở trận (Story 2.6) không dời quân nào.
func _make_attack_main() -> Node2D:
	return _make_level_main(ATTACK_DIR, ATTACK_LEVEL, {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử đánh",
		"kieu": "tieu_diet",
		"dia_hinh": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . .", ". . . . . . ."],
		"quan": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . B . . .",
			". . . 1 K . .", ". . . . . B .", ". . . . . 2 ."],
		"thu_tu_dich": ["3,3", "4,4", "5,5"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	})


## Ghi trận thử vào user:// rồi mở game với trận đó (after_each xóa file).
func _make_level_main(dir: String, path: String, level: Dictionary) -> Node2D:
	DirAccess.make_dir_recursive_absolute(dir)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(level))
	file.close()
	return _make_main(dir)


func _unit_at(main: Node2D, cell: Vector2i) -> Unit:
	return _controller(main).snapshot().unit_at(cell)


## Mở trận: Bộ binh 3,3 (đòn 1) và Kỵ binh 4,4 (đòn 2, xung phong Tây) cùng nhắm Khoái 3,4; Bộ binh 5,5 (đòn 3)
## chém Lão 5,6 (Story 2.7). Khoái đánh đẩy Bộ binh lên 3,2: ô đỏ của nó dịch theo, lên 3,3.
func test_telegraphs_drawn_on_open_and_follow_pushed_owner() -> void:
	var main: Node2D = _make_attack_main()
	var view: TelegraphView = _board(main).telegraph_view()
	assert_eq(view.red_cells(), {Vector2i(3, 4): [1, 2] as Array[int], Vector2i(5, 6): [3] as Array[int]})
	var labels: Dictionary = view.number_labels()
	assert_eq((labels[Vector2i(3, 4)] as Label).text, "1·2")
	assert_eq((labels[Vector2i(5, 6)] as Label).text, "3")
	assert_eq(view.arrows(), {Vector2i(3, 4): Vector2i(-1, 0)}, "mũi tên Kỵ binh chỉ Tây")
	_press_physical(main, KEY_1)
	_click_by_mouse(main, Vector2i(3, 3))
	assert_eq(view.red_cells(), {Vector2i(3, 3): [1] as Array[int], Vector2i(3, 4): [2] as Array[int],
		Vector2i(5, 6): [3] as Array[int]}, "đòn 1 dịch theo Bộ binh bị đẩy")


func test_selecting_khoai_outlines_targets() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	var targets: Array[Vector2i] = [Vector2i(3, 3), Vector2i(4, 4)]
	assert_eq(_view(main).target_cells(), targets, "B→Đ→N→T: Bắc trước Đông")
	assert_eq(_board(main).target_cells(), targets, "bàn cờ viền đúng các ô đó")
	_press_physical(main, KEY_2)
	assert_eq(_board(main).target_cells(), [] as Array[Vector2i], "Lão không có quân Nguyên thẳng hàng trong tầm")


func test_click_target_attacks_and_general_is_spent() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	_click_by_mouse(main, Vector2i(3, 3))
	assert_null(_unit_at(main, Vector2i(3, 3)))
	assert_eq(_unit_at(main, Vector2i(3, 2)).hp, 1, "Bộ binh còn 1 máu, lùi lên 1 ô")
	assert_eq(_token(main, 101).hp_text(), "1")
	assert_true(_token(main, 1).is_attacked(), "đồng Khoái đổi màu đã đánh")
	assert_eq(_view(main).selected_id(), BattleView.NONE, "đánh xong tự bỏ chọn")
	assert_eq(_board(main).target_cells(), [] as Array[Vector2i])
	assert_true(_hud(main).undo_button().disabled)
	_press_physical(main, KEY_1)
	assert_eq(_view(main).selected_id(), BattleView.NONE, "phím 1 không chọn được tướng đã đánh")
	_click_by_mouse(main, Vector2i(3, 4))
	assert_eq(_view(main).selected_id(), BattleView.NONE, "bấm cũng không chọn được")


func test_moved_general_needs_confirm_click() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	_click(main, Vector2i(4, 5))
	assert_eq(_view(main).target_cells(), [Vector2i(4, 4), Vector2i(5, 5)] as Array[Vector2i])
	_click(main, Vector2i(4, 4))
	assert_eq(_view(main).pending_cell(), Vector2i(4, 4), "lần đầu chỉ chờ xác nhận")
	assert_eq(_board(main).pending_cell(), Vector2i(4, 4))
	assert_eq(_hud(main).hint_text(), tr("hud.confirm_attack"))
	assert_eq(_unit_at(main, Vector2i(4, 4)).hp, 2, "chưa đánh")
	_click(main, Vector2i(5, 5))
	assert_eq(_view(main).pending_cell(), Vector2i(5, 5), "bấm mục tiêu khác: chuyển chờ sang đó")
	assert_eq(_unit_at(main, Vector2i(5, 5)).hp, 3, "chưa đánh")
	_click(main, Vector2i(5, 5))
	assert_eq(_unit_at(main, Vector2i(6, 5)).hp, 1, "bấm lại đúng ô: đánh, Bộ binh lùi sang phải")
	assert_true(_token(main, 1).is_attacked())
	assert_eq(_view(main).pending_cell(), BoardView.NO_CELL)
	assert_eq(_hud(main).hint_text(), "")


func test_unmoved_general_attacks_on_first_click() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	_click(main, Vector2i(4, 4))
	assert_null(_unit_at(main, Vector2i(4, 4)), "Kỵ binh 2 máu gục ngay")
	assert_eq(_hud(main).hint_text(), "")


func test_click_elsewhere_cancels_confirm() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	_click(main, Vector2i(4, 5))
	_click(main, Vector2i(4, 4))
	_click(main, Vector2i(1, 1))
	assert_eq(_view(main).selected_id(), BattleView.NONE, "bấm ô trống ngoài tầm: bỏ chọn như cũ")
	assert_eq(_view(main).pending_cell(), BoardView.NO_CELL)
	assert_eq(_board(main).pending_cell(), BoardView.NO_CELL)
	assert_eq(_hud(main).hint_text(), "")
	assert_eq(_unit_at(main, Vector2i(4, 4)).hp, 2, "không đánh")


func test_attack_clears_undo_in_game() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_2)
	_click(main, Vector2i(6, 6))
	_press_physical(main, KEY_1)
	_click(main, Vector2i(3, 3))
	_press_physical(main, KEY_Z)
	assert_eq(_unit_cell(main, 2), Vector2i(6, 6), "Lão vẫn ở ô mới")
	assert_eq(_unit_at(main, Vector2i(3, 2)).hp, 1, "đòn đánh không bị hủy")


func test_end_turn_lets_general_attack_again() -> void:
	var main: Node2D = _make_attack_main()
	_press_physical(main, KEY_1)
	_click(main, Vector2i(3, 3))
	_press_physical(main, KEY_SPACE)
	assert_false(_token(main, 1).is_attacked())
	_press_physical(main, KEY_1)
	assert_eq(_view(main).selected_id(), 1)
	# Pha địch (Story 2.6): Bộ binh bị đẩy ra 3,2 đi lại về ô kề Khoái.
	assert_eq(_view(main).target_cells(), [Vector2i(3, 3), Vector2i(4, 4)] as Array[Vector2i])


# ---------- Không chọn tướng mình làm mục tiêu (Story 2.2, FR16) ----------

## Khoái ở 3,4, Lão kề Tây 2,4, Bộ binh kề Bắc 3,3; thêm Bộ binh 6,6 trong góc bị sông 6,5 và 5,6 vây (không có đường
## tới tướng nào nên đứng yên khi pha địch chạy, Story 2.6).
func _make_ally_main() -> Node2D:
	return _make_level_main(ALLY_DIR, ALLY_LEVEL, {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử tướng mình kề bên",
		"kieu": "tieu_diet",
		"dia_hinh": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . ~", ". . . . . ~ ."],
		"quan": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . B . . .",
			". . 2 1 . . .", ". . . . . . .", ". . . . . . B"],
		"thu_tu_dich": ["3,3", "6,6"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	})


func test_ally_next_to_khoai_has_no_outline() -> void:
	var main: Node2D = _make_ally_main()
	_press_physical(main, KEY_1)
	assert_eq(_view(main).selected_id(), 1)
	var targets: Array[Vector2i] = [Vector2i(3, 3)]
	assert_eq(_view(main).target_cells(), targets, "chỉ Bộ binh, không có Lão ở 2,4")
	assert_eq(_board(main).target_cells(), targets)


func test_click_adjacent_ally_switches_selection() -> void:
	var main: Node2D = _make_ally_main()
	_press_physical(main, KEY_1)
	assert_eq(_view(main).target_cells(), [Vector2i(3, 3)] as Array[Vector2i], "trước: Khoái đang chọn, Bộ binh có viền")
	_click_by_mouse(main, Vector2i(2, 4))
	assert_eq(_view(main).selected_id(), 2, "bấm Lão là chọn Lão")
	assert_false(_controller(main).can_undo(), "không lệnh nào được gửi")
	assert_eq(_unit_at(main, Vector2i(3, 3)).hp, 3, "Bộ binh không mất máu")
	assert_eq(_unit_at(main, Vector2i(2, 4)).hp, 3, "Lão không mất máu")
	assert_false(_controller(main).snapshot().unit_by_id(1).has_attacked, "Khoái chưa đánh")
	assert_eq(_view(main).target_cells(), [] as Array[Vector2i], "không còn viền mục tiêu")
	assert_eq(_board(main).target_cells(), [] as Array[Vector2i])


func test_click_ally_while_confirming_cancels_confirm() -> void:
	var main: Node2D = _make_ally_main()
	_press_physical(main, KEY_1)
	assert_eq(_view(main).selected_id(), 1)
	_click_by_mouse(main, Vector2i(2, 3))
	assert_eq(_unit_cell(main, 1), Vector2i(2, 3), "trước: Khoái đã đi tới 2,3, xuyên qua Lão")
	assert_eq(_unit_cell(main, 2), Vector2i(2, 4), "trước: Lão kề Nam Khoái")
	_click_by_mouse(main, Vector2i(3, 3))
	assert_eq(_view(main).pending_cell(), Vector2i(3, 3), "trước: đang chờ xác nhận Bộ binh")
	assert_eq(_hud(main).hint_text(), tr("hud.confirm_attack"))
	_click_by_mouse(main, Vector2i(2, 4))
	assert_eq(_view(main).selected_id(), 2, "bấm Lão là chọn Lão")
	assert_eq(_view(main).pending_cell(), BoardView.NO_CELL, "bỏ chờ xác nhận")
	assert_eq(_board(main).pending_cell(), BoardView.NO_CELL)
	assert_eq(_hud(main).hint_text(), "", "dòng nhắc mất")
	assert_eq(_unit_at(main, Vector2i(3, 3)).hp, 3, "Bộ binh không mất máu")
	assert_false(_controller(main).snapshot().unit_by_id(1).has_attacked, "Khoái chưa đánh")


# ---------- Lao của Phạm Ngũ Lão (Story 2.3) ----------

## Giống data/tran/thu_lao.json. Lão ở 3,3: Bộ binh kề Bắc 3,2, Bộ binh 3,1; Kỵ binh 6,3 (Đông, ô 3, sông 4,3 và
## 5,3 nằm giữa); Khoái 3,5 chắn trước Bộ binh 3,6; Bộ binh 0,0 trong góc bị sông 1,0 và 0,1 vây. Pha địch lúc mở
## trận (Story 2.6) không dời quân nào.
func _make_lao_main() -> Node2D:
	return _make_level_main(LAO_DIR, LAO_LEVEL, {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử lao",
		"kieu": "tieu_diet",
		"dia_hinh": [". ~ . . . . .", "~ . . . . . .", ". . . . . . .", ". . . . ~ ~ .",
			". . . . . . .", ". . . . . . .", ". . . . . . ."],
		"quan": ["B . . . . . .", ". . . B . . .", ". . . B . . .", ". . . 2 . . K",
			". . . . . . .", ". . . 1 . . .", ". . . B . . ."],
		"thu_tu_dich": ["0,0", "3,1", "3,2", "6,3", "3,6"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	})


func test_selecting_lao_outlines_nearest_enemy_each_way() -> void:
	var main: Node2D = _make_lao_main()
	_press_physical(main, KEY_2)
	assert_eq(_view(main).selected_id(), 2)
	var targets: Array[Vector2i] = [Vector2i(3, 1), Vector2i(6, 3), Vector2i(3, 6)]
	assert_eq(_view(main).target_cells(), targets,
		"B→Đ→N→T; không có Bộ binh kề 3,2; 6,3 có viền dù sông giữa; 3,6 có viền dù Khoái chắn")
	assert_eq(_board(main).target_cells(), targets)


func test_lance_flies_over_adjacent_unit() -> void:
	var main: Node2D = _make_lao_main()
	_press_physical(main, KEY_2)
	assert_eq(_unit_at(main, Vector2i(3, 1)).hp, 3, "trước: Bộ binh ô 2 đủ máu")
	assert_eq(_unit_at(main, Vector2i(3, 2)).hp, 3, "trước: Bộ binh kề đủ máu")
	assert_true(_view(main).target_cells().has(Vector2i(3, 1)), "trước: 3,1 có viền")
	_click_by_mouse(main, Vector2i(3, 1))
	assert_eq(_unit_at(main, Vector2i(3, 1)).hp, 2, "Bộ binh ô 2 trúng lao")
	assert_eq(_unit_at(main, Vector2i(3, 2)).hp, 3, "Bộ binh kề không bị gì")
	assert_true(_token(main, 2).is_attacked())
	assert_eq(_view(main).selected_id(), BattleView.NONE, "phóng xong thì bỏ chọn")
	assert_false(_controller(main).can_undo())


func test_lance_hits_blocking_khoai() -> void:
	var main: Node2D = _make_lao_main()
	_press_physical(main, KEY_2)
	assert_eq(_controller(main).snapshot().unit_by_id(1).hp, 3, "trước: Khoái đủ máu")
	assert_eq(_unit_at(main, Vector2i(3, 6)).hp, 3, "trước: Bộ binh đủ máu")
	assert_true(_view(main).target_cells().has(Vector2i(3, 6)), "trước: 3,6 có viền")
	_click_by_mouse(main, Vector2i(3, 6))
	assert_eq(_controller(main).snapshot().unit_by_id(1).hp, 2, "Khoái đứng chắn trúng lao")
	assert_eq(_unit_at(main, Vector2i(3, 6)).hp, 3, "Bộ binh không bị gì")


func test_lance_after_move_needs_confirm() -> void:
	var main: Node2D = _make_lao_main()
	_press_physical(main, KEY_2)
	_click_by_mouse(main, Vector2i(2, 3))
	assert_eq(_unit_cell(main, 2), Vector2i(2, 3), "trước: Lão đã đi tới 2,3")
	assert_eq(_view(main).target_cells(), [Vector2i(6, 3)] as Array[Vector2i], "trước: chỉ còn Kỵ binh cách 4 ô")
	_click_by_mouse(main, Vector2i(6, 3))
	assert_eq(_view(main).pending_cell(), Vector2i(6, 3), "lần đầu chỉ chờ xác nhận")
	assert_eq(_hud(main).hint_text(), tr("hud.confirm_attack"))
	assert_eq(_unit_at(main, Vector2i(6, 3)).hp, 2, "chưa phóng")
	_click_by_mouse(main, Vector2i(6, 3))
	assert_eq(_unit_at(main, Vector2i(6, 3)).hp, 1, "lần hai mới phóng")


## Khoái đã đánh; Lão đi rồi chờ xác nhận Kỵ binh; bấm (hoặc gõ phím) Khoái thì bỏ chờ, Lão vẫn được chọn (AC 12).
func _lao_pending_with_spent_khoai() -> Node2D:
	var main: Node2D = _make_lao_main()
	_press_physical(main, KEY_1)
	_click_by_mouse(main, Vector2i(3, 6))
	assert_true(_token(main, 1).is_attacked(), "trước: Khoái đã đánh")
	_press_physical(main, KEY_2)
	_click_by_mouse(main, Vector2i(2, 3))
	_click_by_mouse(main, Vector2i(6, 3))
	assert_eq(_view(main).pending_cell(), Vector2i(6, 3), "trước: đang chờ xác nhận Kỵ binh")
	assert_eq(_hud(main).hint_text(), tr("hud.confirm_attack"))
	return main


func _assert_pending_cleared_lao_kept(main: Node2D) -> void:
	assert_eq(_view(main).pending_cell(), BoardView.NO_CELL, "bỏ chờ xác nhận")
	assert_eq(_board(main).pending_cell(), BoardView.NO_CELL)
	assert_eq(_hud(main).hint_text(), "", "dòng nhắc mất")
	assert_eq(_view(main).selected_id(), 2, "Lão vẫn được chọn")
	assert_eq(_unit_at(main, Vector2i(6, 3)).hp, 2, "Kỵ binh không bị gì")


func test_click_spent_general_cancels_confirm() -> void:
	var main: Node2D = _lao_pending_with_spent_khoai()
	_click_by_mouse(main, Vector2i(3, 5))
	_assert_pending_cleared_lao_kept(main)


func test_key_of_spent_general_cancels_confirm() -> void:
	var main: Node2D = _lao_pending_with_spent_khoai()
	_press_physical(main, KEY_1)
	_assert_pending_cleared_lao_kept(main)


# ---------- Kéo của Trần Khánh Dư (Story 2.4) ----------

## Giống data/tran/thu_keo.json. Dư ở 3,3: Bộ binh 3,0 (Bắc, ô 3); Kỵ binh 6,3 (Đông, ô 3, sông 4,3 và 5,3 giữa);
## Khoái 3,4 kề Nam chắn Bộ binh 3,6; Bộ binh 2,3 kề Tây chắn Bộ binh 1,3. Để pha địch lúc mở trận (Story 2.6) không
## dời quân nào: Lão 2,0 kề Bộ binh 3,0; sông 6,4 buộc Kỵ binh nhắm Dư (đã thẳng hàng); Bộ binh 3,6 bị sông vây.
func _make_keo_main() -> Node2D:
	return _make_level_main(KEO_DIR, KEO_LEVEL, {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử kéo",
		"kieu": "tieu_diet",
		"dia_hinh": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . ~ ~ .",
			". . . . . . ~", ". . . ~ . . .", ". . ~ . ~ . ."],
		"quan": [". . 2 B . . .", ". . . . . . .", ". . . . . . .", ". B B 3 . . K",
			". . . 1 . . .", ". . . . . . .", ". . . B . . ."],
		"thu_tu_dich": ["3,0", "1,3", "2,3", "6,3", "3,6"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	})


func test_selecting_du_outlines_first_enemy_each_way() -> void:
	var main: Node2D = _make_keo_main()
	_press_physical(main, KEY_3)
	assert_eq(_view(main).selected_id(), 3)
	var targets: Array[Vector2i] = [Vector2i(3, 0), Vector2i(6, 3)]
	assert_eq(_view(main).target_cells(), targets,
		"B→Đ→N→T; 6,3 có viền dù sông giữa; không có Khoái chắn Nam, Bộ binh kề Tây, và hai quân sau chúng")
	assert_eq(_board(main).target_cells(), targets)


func test_pull_by_mouse_brings_enemy_next_to_du() -> void:
	var main: Node2D = _make_keo_main()
	_press_physical(main, KEO_KEY)
	assert_eq(_unit_at(main, Vector2i(3, 0)).hp, 3, "trước: Bộ binh đủ máu")
	assert_true(_view(main).target_cells().has(Vector2i(3, 0)), "trước: 3,0 có viền")
	_click_by_mouse(main, Vector2i(3, 0))
	assert_null(_unit_at(main, Vector2i(3, 0)), "Bộ binh rời 3,0")
	assert_eq(_unit_at(main, Vector2i(3, 2)).faction, Unit.Faction.NGUYEN, "Bộ binh kề Dư")
	assert_eq(_unit_at(main, Vector2i(3, 2)).hp, 3, "không mất máu")
	assert_true(_token(main, 3).is_attacked())
	assert_eq(_view(main).selected_id(), BattleView.NONE, "kéo xong thì bỏ chọn")
	assert_false(_controller(main).can_undo())


func test_pull_over_river_drowns_cavalry() -> void:
	var main: Node2D = _make_keo_main()
	_press_physical(main, KEO_KEY)
	assert_eq(_unit_at(main, Vector2i(6, 3)).hp, 2, "trước: Kỵ binh đủ máu")
	assert_true(_view(main).target_cells().has(Vector2i(6, 3)), "trước: 6,3 có viền")
	_click_by_mouse(main, Vector2i(6, 3))
	assert_null(_unit_at(main, Vector2i(6, 3)), "Kỵ binh rời 6,3")
	assert_null(_unit_at(main, Vector2i(5, 3)), "rơi xuống sông 5,3 và biến mất")
	assert_null(_unit_at(main, Vector2i(4, 3)))


func test_click_adjacent_enemy_sends_nothing() -> void:
	var main: Node2D = _make_keo_main()
	_press_physical(main, KEO_KEY)
	_click_by_mouse(main, Vector2i(2, 3))
	assert_false(_controller(main).snapshot().unit_by_id(3).has_attacked, "Dư chưa đánh")
	assert_eq(_unit_at(main, Vector2i(2, 3)).hp, 3, "không ai mất máu")
	assert_eq(_unit_cell(main, 3), Vector2i(3, 3))
	assert_eq(_view(main).pending_cell(), BoardView.NO_CELL)
	assert_false(_controller(main).can_undo(), "không có lệnh nào được gửi")
	assert_false(_token(main, 3).is_attacked(), "Dư không xám")


func test_pull_after_move_needs_confirm() -> void:
	var main: Node2D = _make_keo_main()
	_press_physical(main, KEO_KEY)
	_click_by_mouse(main, Vector2i(3, 2))
	assert_eq(_unit_cell(main, 3), Vector2i(3, 2), "trước: Dư đã đi tới 3,2")
	assert_eq(_view(main).target_cells(), [Vector2i(3, 0)] as Array[Vector2i], "trước: chỉ còn Bộ binh cách 2 ô")
	_click_by_mouse(main, Vector2i(3, 0))
	assert_eq(_view(main).pending_cell(), Vector2i(3, 0), "lần đầu chỉ chờ xác nhận")
	assert_eq(_hud(main).hint_text(), tr("hud.confirm_attack"))
	assert_eq(_unit_at(main, Vector2i(3, 0)).faction, Unit.Faction.NGUYEN, "chưa kéo")
	_click_by_mouse(main, Vector2i(3, 0))
	assert_null(_unit_at(main, Vector2i(3, 0)), "lần hai mới kéo")
	assert_eq(_unit_at(main, Vector2i(3, 1)).hp, 3, "cách 2 ô: dừng sát Dư, không mất máu")


## Bàn 10×8 (Story 1.9, thu_co_lon): đẩy ra ngoài cột 9 rồi ngoài hàng 7, bấm chuột thật; F1 có tọa độ góc cuối.
func _enemy_count(main: Node2D) -> int:
	var count: int = 0
	for unit: Unit in _controller(main).snapshot().units:
		if unit.faction != Unit.Faction.DAI_VIET:
			count += 1
	return count


func test_large_board_edge_push_and_f1() -> void:
	AppState.launch.dev = true
	AppState.launch.tran = "thu_co_lon"
	var main: Node2D = _make_main()
	assert_eq(_controller(main).snapshot().size, Vector2i(10, 8))
	var khoai: Vector2i = Vector2i(8, 4)
	var enemies_before: int = _enemy_count(main)
	_click_by_mouse(main, khoai)
	assert_eq(_view(main).selected_id(), 1, "chọn Khoái")
	assert_has(_board(main).target_cells(), Vector2i(9, 4), "viền mục tiêu ở cột 9")
	_click_by_mouse(main, Vector2i(9, 4))
	assert_null(_unit_at(main, Vector2i(9, 4)), "Bộ binh bị đẩy vào mép phải, gục")
	assert_eq(_enemy_count(main), enemies_before - 1, "đúng một quân Nguyên gục, không phải bị đẩy đi chỗ khác")
	assert_eq(_unit_cell(main, 1), khoai, "Khoái đứng yên")
	assert_true(_unit_at(main, khoai).has_attacked, "Khoái đã đánh")
	assert_true(_token(main, 1).is_attacked(), "Khoái xám")
	_press_physical(main, KEY_SPACE)
	_click_by_mouse(main, khoai)
	assert_has(_board(main).lit_cells(), Vector2i(8, 6))
	_hover_by_mouse(main, Vector2i(8, 6))
	assert_eq(_board(main).path(), [Vector2i(8, 5), Vector2i(8, 6)] as Array[Vector2i], "đường đi xuống")
	_click_by_mouse(main, Vector2i(8, 6))
	assert_eq(_unit_at(main, Vector2i(8, 6)).id, 1, "Khoái đi tới 8,6")
	_click_by_mouse(main, Vector2i(8, 7))
	assert_eq(_board(main).pending_cell(), Vector2i(8, 7), "đã đi nên chờ xác nhận")
	_click_by_mouse(main, Vector2i(8, 7))
	assert_null(_unit_at(main, Vector2i(8, 7)), "Bộ binh bị đẩy vào mép dưới, gục")
	assert_eq(_enemy_count(main), enemies_before - 2, "quân Nguyên thứ hai gục")
	var overlay: CoordOverlay = main._coord_overlay as CoordOverlay
	var dev_tools: DevTools = null
	for node: Node in main.get_children():
		if node is DevTools:
			dev_tools = node as DevTools
	assert_not_null(dev_tools)
	assert_false(overlay.visible, "mặc định ẩn")
	dev_tools.f1_pressed.emit()
	assert_true(overlay.visible, "F1 lần một hiện tọa độ")
	assert_has(overlay.texts(), "9,7", "tọa độ ô góc dưới phải")
	assert_has(overlay.texts(), "0,0")
	var expected: Vector2 = BoardView.cell_center(Vector2i(8, 6)) \
		+ Vector2(UnitToken.RADIUS, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
	var found: bool = false
	for child: Node in overlay.get_children():
		if child.is_queued_for_deletion() or child.get_child_count() == 0:
			continue
		if (child.get_child(0) as Label).text == "1":
			assert_eq((child as Control).position, expected, "id 1 cạnh đầu đồng Khoái")
			found = true
	assert_true(found, "lớp F1 có id 1")


# ---------- Thắng và thua (Story 2.5) ----------

## Giống data/tran/thu_thang.json (Lão chưa đánh ở 6,2 để thử khóa bàn; Lão kề Bộ binh 5,2 để nó đứng yên khi pha
## địch chạy, Story 2.6). Khoái 1,2 đẩy Bộ binh 2,2 xuống sông
## 3,2; Dư 5,5 kéo Bộ binh 5,2 (cách 3 ô) xuống sông 5,4. Hai đòn độc lập: hết quân Nguyên sau đòn thứ hai.
func _make_win_main() -> Node2D:
	return _make_level_main(WIN_DIR, WIN_LEVEL, {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử thắng",
		"kieu": "tieu_diet",
		"dia_hinh": [". . . . . . .", ". . . . . . .", ". . . ~ . . .", ". . . . . . .",
			". . . . . ~ .", ". . . . . . .", ". . . . . . ."],
		"quan": [". . . . . . .", ". . . . . . .", ". 1 B . . B 2", ". . . . . . .",
			". . . . . . .", ". . . . . 3 .", ". . . . . . ."],
		"thu_tu_dich": ["2,2", "5,2"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	})


func _banner(main: Node2D) -> ResultBanner:
	return main._result_banner as ResultBanner


## Thắng trong hai đòn: đòn đầu chưa có bảng, đòn sau hiện "Thắng!" và khóa bàn.
func _win(main: Node2D) -> void:
	_press_physical(main, KEY_1)
	_click_by_mouse(main, Vector2i(2, 2))
	_press_physical(main, KEO_KEY)
	_click_by_mouse(main, Vector2i(5, 2))


func test_win_needs_every_enemy_gone() -> void:
	var main: Node2D = _make_win_main()
	assert_false(_banner(main).is_showing(), "trước: chưa có bảng")
	assert_eq(_controller(main).snapshot().phase, BattleState.Phase.PLAYER)
	_press_physical(main, KEY_1)
	assert_eq(_view(main).target_cells(), [Vector2i(2, 2)] as Array[Vector2i], "trước: Bộ binh 2,2 có viền")
	_click_by_mouse(main, Vector2i(2, 2))
	assert_null(_unit_at(main, Vector2i(2, 2)), "Bộ binh đầu chết đuối")
	assert_not_null(_unit_at(main, Vector2i(5, 2)), "còn Bộ binh thứ hai")
	assert_false(_banner(main).is_showing(), "còn quân Nguyên thì chưa thắng")
	assert_false(_hud(main).end_turn_button().disabled)


func test_win_shows_banner_and_locks_the_board() -> void:
	var main: Node2D = _make_win_main()
	_press_physical(main, KEY_1)
	_click_by_mouse(main, Vector2i(2, 2))
	_press_physical(main, KEO_KEY)
	assert_eq(_view(main).target_cells(), [Vector2i(5, 2)] as Array[Vector2i], "trước: Bộ binh 5,2 có viền")
	assert_eq(_view(main).selected_id(), 3, "trước: Dư đang chọn")
	var old_lit: Array[Vector2i] = _controller(main).reachable(3)
	assert_false(old_lit.is_empty(), "trước: Dư có ô sáng")
	_click_by_mouse(main, Vector2i(5, 2))
	assert_null(_unit_at(main, Vector2i(5, 2)), "Bộ binh cuối chết đuối")
	assert_true(_banner(main).is_showing())
	assert_eq(_banner(main).result_text(), tr("result.won"))
	assert_eq(_controller(main).snapshot().phase, BattleState.Phase.WON)
	assert_eq(_view(main).selected_id(), BattleView.NONE)
	assert_eq(_view(main).target_cells(), [] as Array[Vector2i])
	assert_eq(_board(main).target_cells(), [] as Array[Vector2i])
	assert_true(_hud(main).undo_button().disabled)
	assert_true(_hud(main).end_turn_button().disabled)
	var before: Array[String] = BoardFixture.picture(_controller(main).snapshot())
	# Bấm ô sáng cũ của Dư (tướng vừa chọn): nếu bàn không khóa thì Dư đi tới đó.
	_click_by_mouse(main, old_lit[0])
	assert_eq(_unit_cell(main, 3), Vector2i(5, 5), "Dư không dời")
	assert_eq(_view(main).selected_id(), BattleView.NONE, "bấm ô sáng cũ không chọn gì")
	# Bấm tướng: Lão chưa đánh, nếu bàn không khóa thì bấm vào Lão (hay phím 2) là chọn được.
	_click_by_mouse(main, Vector2i(6, 2))
	assert_eq(_view(main).selected_id(), BattleView.NONE, "bấm vào Lão không chọn được")
	_press_physical(main, KEY_2)
	assert_eq(_view(main).selected_id(), BattleView.NONE, "phím 2 không chọn được")
	_click_by_mouse(main, Vector2i(6, 1))
	assert_eq(_unit_cell(main, 2), Vector2i(6, 2), "Lão không dời")
	_press_physical(main, KEY_SPACE)
	_hud(main).end_turn_button().pressed.emit()
	_view(main)._on_undo()
	assert_eq(BoardFixture.picture(_controller(main).snapshot()), before, "không lệnh nào chạy: bàn giữ nguyên")
	assert_eq(_controller(main).snapshot().round_number, 1, "không sang hiệp mới")
	assert_eq(_controller(main).snapshot().phase, BattleState.Phase.WON, "kết cục giữ nguyên")


func test_retry_button_reloads_the_battle() -> void:
	var main: Node2D = _make_win_main()
	_win(main)
	assert_true(_banner(main).is_showing(), "điều kiện trước: đã thắng")
	assert_true(_banner(main).retry_button().visible, "nút Chơi lại trận hiện cùng bảng")
	_banner(main).retry_button().pressed.emit()
	_assert_fresh_win_battle(main)


func test_f5_after_win_clears_the_banner() -> void:
	var main: Node2D = _make_win_main()
	AppState.launch.dev = true
	_win(main)
	assert_true(_banner(main).is_showing(), "điều kiện trước: đã thắng")
	main._reload_data()
	_assert_fresh_win_battle(main)


func _assert_fresh_win_battle(main: Node2D) -> void:
	assert_false(_banner(main).is_showing(), "bảng ẩn")
	var state: BattleState = _controller(main).snapshot()
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_eq(state.units.size(), 5, "đủ quân như lúc đầu")
	assert_not_null(_unit_at(main, Vector2i(2, 2)))
	assert_not_null(_unit_at(main, Vector2i(5, 2)))
	assert_false(_hud(main).end_turn_button().disabled)
	_press_physical(main, KEY_1)
	assert_eq(_view(main).selected_id(), 1, "chơi tiếp được")
	assert_eq(_view(main).target_cells(), [Vector2i(2, 2)] as Array[Vector2i])


# ---------- F3 ý định AI (Story 2.6) ----------

## Phím dev đi vào DevTools (không qua BattleInput).
func _press_dev(main: Node2D, key: Key) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = key
	ev.pressed = true
	for node: Node in main.get_children():
		if node is DevTools:
			(node as DevTools)._unhandled_input(ev)


func test_f3_shows_ai_intents_and_follows_reload() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_attack_main()
	var overlay: AiIntentOverlay = main._ai_overlay as AiIntentOverlay
	assert_not_null(overlay, "bật dev thì có bảng F3")
	if overlay == null:
		return
	assert_false(overlay.visible, "mặc định ẩn")
	_press_dev(main, KEY_F3)
	assert_true(overlay.visible, "F3 hiện bảng")
	var lines: Array[String] = overlay.texts()
	assert_eq(lines.size(), 4, "tiêu đề và 3 quân Nguyên")
	assert_eq(lines[0], "Ý định quân Nguyên (hiệp 1)")
	assert_true(lines[1].begins_with("Bộ binh 101: đứng yên ở 3,3 · nhắm Nguyễn Khoái"), lines[1])
	_press_physical(main, KEY_SPACE)
	assert_eq(overlay.texts()[0], "Ý định quân Nguyên (hiệp 2)", "cập nhật sau lệnh")
	main._reload_data()
	assert_true(overlay.visible, "nạp lại vẫn giữ bật")
	assert_eq(overlay.texts()[0], "Ý định quân Nguyên (hiệp 1)", "trận mở lại từ đầu")
	_press_dev(main, KEY_F3)
	assert_false(overlay.visible, "F3 lần hai ẩn")


func test_no_f3_overlay_without_dev() -> void:
	AppState.launch.dev = false
	var main: Node2D = _make_attack_main()
	assert_null(main._ai_overlay, "không bật dev thì không có bảng F3")

