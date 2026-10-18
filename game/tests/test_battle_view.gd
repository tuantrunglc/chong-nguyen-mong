extends GutTest
## Chọn tướng trên trận 1 thật (Story 1.4): phím 1-2-3, bấm, bỏ chọn, ô sáng, đường đi.
## Trận 1 và chi_so.json thật: tướng ở 0,6 và 2,6, sông cột 3 (trừ hàng 3), tầm đi 3.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_battle_view"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const BROKEN_DIR: String = PROBE_DIR + "/tran"
const BROKEN_LEVEL: String = BROKEN_DIR + "/tran_01.json"

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
	for action: String in BattleInput.GENERAL_ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	for i: int in range(DevTools.KEYS.size()):
		if InputMap.has_action("dev_f%d" % (i + 1)):
			InputMap.erase_action("dev_f%d" % (i + 1))
	SaveProbe.path = SaveProbe.DEFAULT_PATH
	for path: String in [BROKEN_LEVEL, PROBE_FILE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(BROKEN_DIR)
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


func test_click_on_lit_cell_keeps_selection() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	_click(main, Vector2i(2, 5))
	_assert_selected(main, 1, KHOAI_CELLS, KHOAI_CELL)
	assert_eq((main._controller as BattleController).snapshot().unit_by_id(1).cell, KHOAI_CELL, "chưa đi (Story 1.5)")


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


func test_cell_at_maps_board_pixels() -> void:
	var main: Node2D = _make_main()
	var board: BoardView = _board(main)
	assert_eq(board.cell_at(BoardView.cell_center(Vector2i(2, 5))), Vector2i(2, 5))
	assert_eq(board.cell_at(Vector2(0, 0)), Vector2i(0, 0))
	assert_eq(board.cell_at(Vector2(-1, 10)), BoardView.NO_CELL)
	assert_eq(board.cell_at(Vector2(7 * BoardView.CELL_SIZE, 10)), BoardView.NO_CELL)


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


func test_back_to_menu_clears_selection() -> void:
	var main: Node2D = _make_main()
	_press_key(main, 1)
	main._show_menu()
	_assert_nothing_selected(main)
	_press_key(main, 1)
	_click(main, KHOAI_CELL)
	_assert_nothing_selected(main)


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
