extends GutTest
## Bàn cờ nghiêng (Story 1.7): đổi ô ↔ điểm, chọn ô nhìn thấy dưới chuột, thứ tự che khuất, bố cục.
## Isometric 2:1, ô 0,0 ở đỉnh trên; cột tăng xuống phải, hàng tăng xuống trái.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_board_view"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const LEVEL_DIR: String = PROBE_DIR + "/tran"
const PASS_LEVEL: String = LEVEL_DIR + "/tran_01.json"
## Khoảng cách (px) từ đỉnh ô thoi vào phía tâm khi thử điểm sát mép.
const EDGE_STEP: float = 3.0


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
	for path: String in [PASS_LEVEL, PROBE_FILE]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(LEVEL_DIR)
	DirAccess.remove_absolute(PROBE_DIR)
	Log.clear()


func _make_main(level_dir: String = "") -> Node2D:
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	if not level_dir.is_empty():
		main.level_dir = level_dir
	add_child_autofree(main)
	return main


func _make_three_generals() -> Node2D:
	AppState.launch.dev = true
	AppState.launch.tran = "thu_ba_tuong"
	return _make_main()


func _board(main: Node2D) -> BoardView:
	return main._board_view as BoardView


func _all_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for r: int in range(7):
		for c: int in range(7):
			cells.append(Vector2i(c, r))
	return cells


## Bốn đỉnh ô thoi trên mặt đất: trên, phải, dưới, trái.
func _corners(cell: Vector2i) -> Array[Vector2]:
	var center: Vector2 = BoardView.cell_center(cell)
	var half: Vector2 = Vector2(BoardView.TILE_W, BoardView.TILE_H) / 2.0
	return [center + Vector2(0, -half.y), center + Vector2(half.x, 0), center + Vector2(0, half.y),
		center + Vector2(-half.x, 0)] as Array[Vector2]


func _blocks(board: BoardView) -> Array[TerrainBlock]:
	var out: Array[TerrainBlock] = []
	for child: Node in board._world.get_children():
		if child is TerrainBlock:
			out.append(child as TerrainBlock)
	return out


# ---------- Đổi ô ↔ điểm ----------

func test_cell_center_round_trips_every_cell() -> void:
	var board: BoardView = _board(_make_main())
	for cell: Vector2i in _all_cells():
		assert_eq(board.cell_at(BoardView.cell_center(cell)), cell)


func test_points_near_each_corner_stay_in_cell() -> void:
	var board: BoardView = _board(_make_main())
	for cell: Vector2i in _all_cells():
		var center: Vector2 = BoardView.cell_center(cell)
		for corner: Vector2 in _corners(cell):
			var point: Vector2 = corner + (center - corner).normalized() * EDGE_STEP
			assert_eq(board.cell_at(point), cell, "sát đỉnh %s của ô %s" % [corner, cell])


func test_points_outside_big_diamond_are_off_board() -> void:
	var board: BoardView = _board(_make_main())
	var outside: Array[Vector2] = [
		_corners(Vector2i(0, 0))[0] + Vector2(0, -EDGE_STEP),
		_corners(Vector2i(6, 0))[1] + Vector2(EDGE_STEP, 0),
		_corners(Vector2i(6, 6))[2] + Vector2(0, EDGE_STEP),
		_corners(Vector2i(0, 6))[3] + Vector2(-EDGE_STEP, 0),
	]
	for point: Vector2 in outside:
		assert_eq(board.cell_at(point), BoardView.NO_CELL, "ngoài bàn: %s" % point)


func test_columns_go_down_right_rows_go_down_left() -> void:
	var origin: Vector2 = BoardView.cell_center(Vector2i(0, 0))
	var next_col: Vector2 = BoardView.cell_center(Vector2i(1, 0))
	var next_row: Vector2 = BoardView.cell_center(Vector2i(0, 1))
	assert_gt(next_col.x, origin.x)
	assert_gt(next_col.y, origin.y)
	assert_lt(next_row.x, origin.x)
	assert_gt(next_row.y, origin.y)
	assert_eq(BoardView.TILE_W, BoardView.TILE_H * 2, "thoi rộng gấp đôi cao")


# ---------- Chọn ô nhìn thấy dưới chuột ----------

func test_pick_every_cell_center_with_units_on_board() -> void:
	for main: Node2D in [_make_main(), _make_three_generals()]:
		var board: BoardView = _board(main)
		for cell: Vector2i in _all_cells():
			assert_eq(board.pick_cell(BoardView.cell_center(cell)), cell)


func test_pick_head_of_token_selects_its_cell() -> void:
	var board: BoardView = _board(_make_main())
	# Lão ở 2,6: đầu đồng nằm trên đất của ô 1,5 phía sau.
	var head: Vector2 = BoardView.cell_center(Vector2i(2, 6)) \
		+ Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS + 4)
	assert_eq(board.cell_at(head), Vector2i(1, 5), "đầu đồng nằm trên đất của ô sau lưng")
	assert_eq(board.pick_cell(head), Vector2i(2, 6))


## Bấm chuột thật (qua BattleInput) vào đầu đồng Lão, chỗ nằm trên đất của ô 1,5: chọn Lão.
func test_mouse_click_on_token_head_selects_that_general() -> void:
	var main: Node2D = _make_main()
	var board: BoardView = _board(main)
	var click: InputEventMouseButton = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var head: Vector2 = BoardView.cell_center(Vector2i(2, 6)) \
		+ Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS + 4)
	click.position = board.get_global_transform_with_canvas() * head
	(main._battle_input as BattleInput)._unhandled_input(click)
	assert_eq((main._battle_view as BattleView).selected_id(), 2, "chọn Lão")


func test_pick_raised_block_top_selects_block() -> void:
	var board: BoardView = _board(_make_three_generals())
	var top: Vector2 = _corners(Vector2i(1, 1))[0] + Vector2(0, -BoardView.BLOCK_HEIGHT + 4)
	assert_ne(board.cell_at(top), Vector2i(1, 1), "mặt trên khối nhô vào ô phía sau")
	assert_eq(board.pick_cell(top), Vector2i(1, 1))


func test_pick_outside_board_is_no_cell() -> void:
	var board: BoardView = _board(_make_main())
	assert_eq(board.pick_cell(_corners(Vector2i(0, 0))[0] + Vector2(0, -60)), BoardView.NO_CELL)


# ---------- Che khuất ----------

func test_blocks_and_tokens_sort_by_depth() -> void:
	var board: BoardView = _board(_make_three_generals())
	assert_true(board._world.y_sort_enabled)
	var blocks: Array[TerrainBlock] = _blocks(board)
	assert_eq(blocks.size(), 3, "rừng, kho lương, làng")
	var kinds: Array[int] = []
	for block: TerrainBlock in blocks:
		kinds.append(block.kind)
	assert_has(kinds, Terrain.FOREST)
	for block: TerrainBlock in blocks:
		var block_depth: int = block.cell.x + block.cell.y
		for token: UnitToken in board.tokens().values():
			var depth: int = token.cell.x + token.cell.y
			if depth < block_depth:
				assert_lt(token.position.y, block.position.y, "quân %s sau khối %s" % [token.cell, block.cell])
			else:
				assert_gt(token.position.y, block.position.y, "quân %s trước khối %s" % [token.cell, block.cell])


func test_token_on_pass_stands_on_platform() -> void:
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)
	var level: Dictionary = {
		"phien_ban_dinh_dang": 1,
		"ten": "Thử ô ải",
		"kieu": "tieu_diet",
		"dia_hinh": [". . . . . . .", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . .", "A . . . . . ."],
		"quan": [". . . . . . B", ". . . . . . .", ". . . . . . .", ". . . . . . .",
			". . . . . . .", ". . . . . . .", "1 . . . . . ."],
		"thu_tu_dich": ["6,0"],
		"tiep_vien": [],
		"muu_ke_mo": [],
	}
	var file: FileAccess = FileAccess.open(PASS_LEVEL, FileAccess.WRITE)
	file.store_string(JSON.stringify(level))
	file.close()
	var board: BoardView = _board(_make_main(LEVEL_DIR))
	var token: UnitToken = board.tokens()[1] as UnitToken
	assert_eq(token.position, BoardView.cell_center(Vector2i(0, 6)) - Vector2(0, BoardView.PASS_HEIGHT),
		"đứng trên bệ ải")
	assert_eq(board.pick_cell(BoardView.cell_center(Vector2i(0, 6))), Vector2i(0, 6))
	assert_eq(_blocks(board).size(), 0, "bệ ải vẽ trên mặt đất, không phải khối")


# ---------- Bố cục ----------

func test_board_fits_left_of_hud_below_title() -> void:
	for main: Node2D in [_make_main(), _make_three_generals()]:
		var rect: Rect2 = _board(main).board_rect()
		assert_true(Rect2(16, 52, 940, 612).encloses(rect), "bàn trong vùng trống: %s" % rect)
		var title: Label = main._title_label
		assert_false(rect.intersects(Rect2(title.position, title.size)), "không đè tiêu đề")
		var hud: Rect2 = Rect2(Hud.PANEL_POSITION, Vector2(Hud.PANEL_WIDTH, 200))
		assert_false(rect.intersects(hud), "không đè HUD")
		var version: Label = main._version_label
		assert_false(rect.intersects(Rect2(version.position, version.size)), "không đè nhãn phiên bản")


func test_board_rect_covers_every_cell_and_token() -> void:
	var board: BoardView = _board(_make_main())
	var rect: Rect2 = board.board_rect()
	for cell: Vector2i in _all_cells():
		for corner: Vector2 in _corners(cell):
			assert_true(rect.has_point(board.position + corner), "đỉnh ô %s" % cell)
	for token: UnitToken in board.tokens().values():
		var top: Vector2 = board.position + token.position + Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
		assert_true(rect.has_point(top), "đầu đồng %s" % token.cell)
