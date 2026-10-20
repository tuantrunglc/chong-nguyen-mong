extends GutTest
## Bàn cờ nhìn chếch (Story 1.8, thay bàn nghiêng của 1.7): đổi ô ↔ điểm, chọn ô nhìn thấy dưới chuột,
## thứ tự che khuất, bố cục. Ô vuông, ô 0,0 ở góc trên trái; cột tăng sang phải, hàng tăng xuống dưới.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const PROBE_DIR: String = "user://test_board_view"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"
const LEVEL_DIR: String = PROBE_DIR + "/tran"
const PASS_LEVEL: String = LEVEL_DIR + "/tran_01.json"
## Khoảng cách (px) từ góc ô vào phía tâm khi thử điểm sát mép, hoặc ra ngoài cạnh bàn.
const EDGE_STEP: float = 2.0


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


func _all_cells(board: BoardView) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for r: int in range(board.rows):
		for c: int in range(board.cols):
			cells.append(Vector2i(c, r))
	return cells


## Bốn góc ô vuông trên mặt đất: trên trái, trên phải, dưới phải, dưới trái.
func _corners(cell: Vector2i) -> Array[Vector2]:
	var rect: Rect2 = BoardView.cell_rect(cell)
	return [rect.position, Vector2(rect.end.x, rect.position.y), rect.end,
		Vector2(rect.position.x, rect.end.y)] as Array[Vector2]


func _blocks(board: BoardView) -> Array[TerrainBlock]:
	var out: Array[TerrainBlock] = []
	for child: Node in board._world.get_children():
		if child is TerrainBlock:
			out.append(child as TerrainBlock)
	return out


# ---------- Đổi ô ↔ điểm ----------

func test_cell_center_round_trips_every_cell() -> void:
	var board: BoardView = _board(_make_main())
	for cell: Vector2i in _all_cells(board):
		assert_eq(board.cell_at(BoardView.cell_center(cell)), cell)


func test_points_near_each_corner_stay_in_cell() -> void:
	var board: BoardView = _board(_make_main())
	for cell: Vector2i in _all_cells(board):
		var center: Vector2 = BoardView.cell_center(cell)
		for corner: Vector2 in _corners(cell):
			var point: Vector2 = corner + (center - corner).sign() * EDGE_STEP
			assert_eq(board.cell_at(point), cell, "sát góc %s của ô %s" % [corner, cell])


func test_points_outside_board_are_off_board() -> void:
	var board: BoardView = _board(_make_main())
	var last_col: Vector2i = Vector2i(board.cols - 1, 0)
	var last_row: Vector2i = Vector2i(0, board.rows - 1)
	var outside: Array[Vector2] = [
		BoardView.cell_center(Vector2i(0, 0)) + Vector2(0, -BoardView.TILE_SIZE / 2.0 - EDGE_STEP),
		BoardView.cell_center(Vector2i(0, 0)) + Vector2(-BoardView.TILE_SIZE / 2.0 - EDGE_STEP, 0),
		BoardView.cell_center(last_col) + Vector2(BoardView.TILE_SIZE / 2.0 + EDGE_STEP, 0),
		BoardView.cell_center(last_row) + Vector2(0, BoardView.TILE_SIZE / 2.0 + EDGE_STEP),
		# Sát mép trái: int(-1 / 64) là 0, phải dùng floori mới ra ngoài bàn.
		Vector2(-1, BoardView.TILE_SIZE / 2.0),
	]
	for point: Vector2 in outside:
		assert_eq(board.cell_at(point), BoardView.NO_CELL, "ngoài bàn: %s" % point)


func test_columns_go_right_rows_go_down() -> void:
	var origin: Vector2 = BoardView.cell_center(Vector2i(0, 0))
	assert_eq(BoardView.cell_center(Vector2i(1, 0)) - origin, Vector2(BoardView.TILE_SIZE, 0))
	assert_eq(BoardView.cell_center(Vector2i(0, 1)) - origin, Vector2(0, BoardView.TILE_SIZE))


func test_tile_is_64_px_multiple_of_16() -> void:
	assert_eq(BoardView.TILE_SIZE, 64, "khớp tranh E8 64×64 hiện 1:1")
	assert_eq(BoardView.TILE_SIZE % 16, 0)


# ---------- Chọn ô nhìn thấy dưới chuột ----------

func test_pick_every_cell_center_with_units_on_board() -> void:
	for main: Node2D in [_make_main(), _make_three_generals()]:
		var board: BoardView = _board(main)
		for cell: Vector2i in _all_cells(board):
			assert_eq(board.pick_cell(BoardView.cell_center(cell)), cell)


func test_pick_head_of_token_selects_its_cell() -> void:
	var board: BoardView = _board(_make_main())
	# Lão ở 2,6: đầu đồng nằm trên đất của ô 2,5 phía trên.
	var head: Vector2 = BoardView.cell_center(Vector2i(2, 6)) \
		+ Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS + 4)
	assert_eq(board.cell_at(head), Vector2i(2, 5), "đầu đồng nằm trên đất của ô phía trên")
	assert_eq(board.pick_cell(head), Vector2i(2, 6))


## Bấm chuột thật (qua BattleInput) vào đầu đồng Lão, chỗ nằm trên đất của ô 2,5: chọn Lão.
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
	# Rừng ở 1,1; mặt trên nhô lên ô 1,0, nơi có Bộ binh đứng (điểm nằm ngoài đồng của nó).
	var top: Vector2 = BoardView.cell_rect(Vector2i(1, 1)).position \
		+ Vector2(BoardView.TILE_SIZE / 2.0, -BoardView.BLOCK_HEIGHT + 4)
	assert_eq(board.cell_at(top), Vector2i(1, 0), "mặt trên khối nhô vào ô phía trên")
	for token: UnitToken in board.tokens().values():
		if token.cell == Vector2i(1, 0):
			assert_false(token.hit(top - token.position), "không trúng đồng Bộ binh ở 1,0")
	assert_eq(board.pick_cell(top), Vector2i(1, 1))


func test_pick_outside_board_is_no_cell() -> void:
	var board: BoardView = _board(_make_main())
	# Cao hơn mọi vật nhô lên ở hàng 0.
	assert_eq(board.pick_cell(BoardView.cell_center(Vector2i(0, 0)) + Vector2(0, -60)), BoardView.NO_CELL)


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
		for token: UnitToken in board.tokens().values():
			if token.cell.y < block.cell.y:
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
	# Đầu đồng nâng theo bệ: điểm này trên đất ô 0,5 (cell_at) và cao hơn đầu đồng nếu đứng trên đất phẳng.
	var head: Vector2 = BoardView.cell_center(Vector2i(0, 6)) \
		+ Vector2(0, -BoardView.PASS_HEIGHT - UnitToken.TOKEN_LIFT - UnitToken.RADIUS + 4)
	assert_eq(board.cell_at(head), Vector2i(0, 5))
	assert_lt(head.y, BoardView.cell_center(Vector2i(0, 6)).y - UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
	assert_eq(board.pick_cell(head), Vector2i(0, 6), "bấm đầu đồng trên bệ: chọn ô ải")
	assert_true(board.board_rect().has_point(board.position + head), "khung bàn bao đầu đồng trên bệ")
	assert_eq(_blocks(board).size(), 0, "bệ ải vẽ trên mặt đất, không phải khối")


# ---------- Bố cục ----------

func test_board_fits_left_of_hud_below_title() -> void:
	for main: Node2D in [_make_main(), _make_three_generals()]:
		var rect: Rect2 = _board(main).board_rect()
		assert_true(BoardView.AREA.encloses(rect), "bàn trong vùng trống: %s" % rect)
		var title: Label = main._title_label
		assert_false(rect.intersects(Rect2(title.position, title.size)), "không đè tiêu đề")
		var hud: Rect2 = Rect2(Hud.PANEL_POSITION, Vector2(Hud.PANEL_WIDTH, 200))
		assert_false(rect.intersects(hud), "không đè HUD")
		var version: Label = main._version_label
		assert_false(rect.intersects(Rect2(version.position, version.size)), "không đè nhãn phiên bản")


func test_board_rect_covers_every_cell_and_token() -> void:
	var board: BoardView = _board(_make_main())
	var rect: Rect2 = board.board_rect()
	for cell: Vector2i in _all_cells(board):
		for corner: Vector2 in _corners(cell):
			assert_true(rect.has_point(board.position + corner), "góc ô %s" % cell)
	for token: UnitToken in board.tokens().values():
		var top: Vector2 = board.position + token.position + Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
		assert_true(rect.has_point(top), "đầu đồng %s" % token.cell)


func test_board_sits_on_whole_pixels() -> void:
	for main: Node2D in [_make_main(), _make_three_generals()]:
		var board: BoardView = _board(main)
		assert_eq(board.position, board.position.round(), "góc bàn rơi đúng điểm ảnh nguyên")


## Đồng quân và khối nhô lên ô phía trên nhưng không bao giờ che tâm ô hàng xóm (pick_cell(tâm ô) == ô).
func test_token_and_block_never_cover_a_neighbour_center() -> void:
	var tile: float = BoardView.TILE_SIZE
	assert_lt(UnitToken.TOKEN_LIFT + UnitToken.RADIUS, tile, "đồng không với tới tâm ô phía trên")
	assert_lt(UnitToken.RADIUS, tile / 2.0, "đồng không lấn sang ô hai bên")
	# Tính từ chân đồng: tâm đồng ở -TOKEN_LIFT, tâm ô hàng trên ở -tile; hai tâm cách nhau hơn một bán kính.
	assert_gt(tile - UnitToken.TOKEN_LIFT, UnitToken.RADIUS, "đồng hàng dưới không che tâm ô hàng trên")
	assert_lt(BoardView.BLOCK_HEIGHT, tile / 2.0, "mặt trên khối không với tới tâm ô phía trên")


# ---------- Viền mục tiêu (Story 2.1) ----------

## Viền mục tiêu nằm trên đồng quân, thấy đủ 4 cạnh (review 1.8, tác giả chốt 2026-10-20); F1 vẫn trên cùng.
func test_target_outline_draws_above_tokens() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var board: BoardView = _board(main)
	assert_gt(board._target_layer.get_index(), board._world.get_index(), "viền vẽ sau đồng quân")
	assert_gt((main._coord_overlay as Node).get_index(), board._target_layer.get_index(), "F1 vẫn trên cùng")


func test_target_outline_and_pending_are_cleared() -> void:
	var board: BoardView = _board(_make_main())
	board.show_selection(Vector2i(0, 6), [] as Array[Vector2i], [Vector2i(0, 5)] as Array[Vector2i])
	board.show_pending(Vector2i(0, 5))
	assert_eq(board.target_cells(), [Vector2i(0, 5)] as Array[Vector2i])
	assert_eq(board.pending_cell(), Vector2i(0, 5))
	board.clear_selection()
	assert_eq(board.target_cells(), [] as Array[Vector2i])
	assert_eq(board.pending_cell(), BoardView.NO_CELL)
	board.show_selection(Vector2i(0, 6), [] as Array[Vector2i], [Vector2i(0, 5)] as Array[Vector2i])
	board.show_pending(Vector2i(0, 5))
	board.show_state(null)
	assert_eq(board.target_cells(), [] as Array[Vector2i], "bàn trống: hết viền")
	assert_eq(board.pending_cell(), BoardView.NO_CELL)
	board.show_selection(Vector2i(0, 6), [] as Array[Vector2i], [Vector2i(0, 5)] as Array[Vector2i])
	assert_eq(board.pending_cell(), BoardView.NO_CELL, "chọn lại thì bỏ chờ")
