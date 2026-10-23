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
	return _make_level_main("thu_ba_tuong")


## Mở trận thử trong data/tran theo tên (bật dev).
func _make_level_main(name: String) -> Node2D:
	AppState.launch.dev = true
	AppState.launch.tran = name
	return _make_main()


## Bàn của trận 1, thu_ba_tuong, bàn nhỏ 5×5 và bàn lớn 10×8 (Story 1.9).
func _boards() -> Array[BoardView]:
	var out: Array[BoardView] = [_board(_make_main())]
	for name: String in ["thu_ba_tuong", "thu_co_nho", "thu_co_lon"]:
		out.append(_board(_make_level_main(name)))
	return out


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
	for board: BoardView in _boards():
		for cell: Vector2i in _all_cells(board):
			assert_eq(board.cell_at(BoardView.cell_center(cell)), cell)


func test_points_near_each_corner_stay_in_cell() -> void:
	for board: BoardView in _boards():
		for cell: Vector2i in _all_cells(board):
			var center: Vector2 = BoardView.cell_center(cell)
			for corner: Vector2 in _corners(cell):
				var point: Vector2 = corner + (center - corner).sign() * EDGE_STEP
				assert_eq(board.cell_at(point), cell, "sát góc %s của ô %s" % [corner, cell])


func test_points_outside_board_are_off_board() -> void:
	for board: BoardView in _boards():
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
			assert_eq(board.cell_at(point), BoardView.NO_CELL, "ngoài bàn %dx%d: %s" % [board.cols, board.rows, point])


func test_columns_go_right_rows_go_down() -> void:
	var origin: Vector2 = BoardView.cell_center(Vector2i(0, 0))
	assert_eq(BoardView.cell_center(Vector2i(1, 0)) - origin, Vector2(BoardView.TILE_SIZE, 0))
	assert_eq(BoardView.cell_center(Vector2i(0, 1)) - origin, Vector2(0, BoardView.TILE_SIZE))


func test_tile_is_64_px_multiple_of_16() -> void:
	assert_eq(BoardView.TILE_SIZE, 64, "khớp tranh E8 64×64 hiện 1:1")
	assert_eq(BoardView.TILE_SIZE % 16, 0)


# ---------- Chọn ô nhìn thấy dưới chuột ----------

func test_pick_every_cell_center_with_units_on_board() -> void:
	for board: BoardView in _boards():
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
	for board: BoardView in _boards():
		var main: Node2D = board.get_parent() as Node2D
		var rect: Rect2 = board.board_rect()
		assert_true(BoardView.AREA.encloses(rect), "bàn trong vùng trống: %s" % rect)
		var title: Label = main._title_label
		assert_false(rect.intersects(Rect2(title.position, title.size)), "không đè tiêu đề")
		var hud: Rect2 = Rect2(Hud.PANEL_POSITION, Vector2(Hud.PANEL_WIDTH, 200))
		assert_false(rect.intersects(hud), "không đè HUD")
		var version: Label = main._version_label
		assert_false(rect.intersects(Rect2(version.position, version.size)), "không đè nhãn phiên bản")


func test_board_rect_covers_every_cell_and_token() -> void:
	for board: BoardView in _boards():
		var rect: Rect2 = board.board_rect()
		for cell: Vector2i in _all_cells(board):
			for corner: Vector2 in _corners(cell):
				assert_true(rect.has_point(board.transform * corner), "góc ô %s" % cell)
		for token: UnitToken in board.tokens().values():
			var top: Vector2 = token.position + Vector2(0, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS)
			assert_true(rect.has_point(board.transform * top), "đầu đồng %s" % token.cell)


func test_board_sits_on_whole_pixels() -> void:
	for board: BoardView in _boards():
		assert_eq(board.position, board.position.round(), "góc bàn rơi đúng điểm ảnh nguyên")


## Cỡ bàn theo file trận; mọi cỡ hợp lệ hiện ô 64 px, không thu nhỏ ở 1280×720 (Story 1.9).
func test_board_size_follows_level() -> void:
	var sizes: Array[Vector2i] = [Vector2i(7, 7), Vector2i(7, 7), Vector2i(5, 5), Vector2i(10, 8)]
	var boards: Array[BoardView] = _boards()
	for i: int in range(boards.size()):
		assert_eq(Vector2i(boards[i].cols, boards[i].rows), sizes[i])
		assert_eq(boards[i].scale, Vector2.ONE, "ô 64 px")


func test_level_1_board_unchanged() -> void:
	assert_eq(_board(_make_main()).position, Vector2(262, 139), "như sau Story 1.8")


func test_fit_scale_uses_whole_steps() -> void:
	assert_eq(BoardView.fit_scale(Vector2(644, 550), BoardView.AREA.size), 1.0, "bàn 10×8 vừa ở 1:1")
	assert_eq(BoardView.fit_scale(Vector2(1000, 500), Vector2(940, 612)), 0.5)
	assert_eq(BoardView.fit_scale(Vector2(2000, 500), Vector2(940, 612)), 1.0 / 3.0)
	assert_eq(BoardView.fit_scale(Vector2(900, 1300), Vector2(940, 612)), 1.0 / 3.0, "chiều cao quyết")


## AREA là const nên không ép được nhánh thu nhỏ qua setup: đặt thẳng scale, kiểm đường chuột và khung bàn.
func test_scaled_board_still_maps_clicks() -> void:
	var board: BoardView = _board(_make_level_main("thu_co_lon"))
	board.scale = Vector2(0.5, 0.5)
	var rect: Rect2 = board.board_rect()
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(board.cols - 1, 0), Vector2i(0, board.rows - 1),
			Vector2i(board.cols - 1, board.rows - 1)]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.position = board.get_global_transform_with_canvas() * BoardView.cell_center(cell)
		var local: Vector2 = (board.make_input_local(event) as InputEventMouse).position
		assert_eq(board.pick_cell(local), cell, "ô %s khi thu 1/2" % cell)
		assert_true(rect.has_point(board.transform * BoardView.cell_center(cell)), "khung bao ô %s" % cell)


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


func test_damage_labels_show_and_clear() -> void:
	var board: BoardView = _board(_make_main())
	var penalties: Dictionary = {Vector2i(0, 5): 1, Vector2i(1, 5): 2}
	board.show_selection(Vector2i(0, 6), [Vector2i(0, 5), Vector2i(1, 5)], [], penalties)
	assert_eq(board.damage_label_texts(), {Vector2i(0, 5): "−1", Vector2i(1, 5): "−2"}, "hiện đúng nhãn trừ máu")
	board.clear_selection()
	assert_eq(board.damage_label_texts(), {}, "bỏ chọn thì xóa sạch nhãn trừ máu")
	board.show_selection(Vector2i(0, 6), [Vector2i(0, 5)], [])
	assert_eq(board.damage_label_texts(), {}, "ô không mất máu thì không hiện nhãn")


# ---------- Ô đỏ báo đòn (Story 2.7) ----------

## BoardView đứng riêng (không qua main), vẽ bản chụp dựng tay.
func _telegraph_board(state: BattleState) -> BoardView:
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	return board


func _label_texts(view: TelegraphView) -> Dictionary:
	var out: Dictionary = {}
	var labels: Dictionary = view.number_labels()
	for cell: Vector2i in labels:
		out[cell] = (labels[cell] as Label).text
	return out


## Kỵ binh 0,3 xung phong Đông vào Khoái 4,3; Bộ binh 4,2 chém Khoái (như kịch bản o_do_ky_binh_va_bo_binh).
func _charge_and_infantry() -> BattleState:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 2): "B", Vector2i(4, 3): "1"})
	# Quân Nguyên đánh id theo thứ tự đọc bàn: Bộ binh 4,2 là 101, Kỵ binh 0,3 là 102.
	state.telegraphs.append(Telegraph.new(102, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 1))
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 1), 2))
	return state


func test_telegraphs_draw_red_cells_numbers_and_arrow() -> void:
	var view: TelegraphView = _telegraph_board(_charge_and_infantry()).telegraph_view()
	var red: Dictionary = {}
	for x: int in range(1, 4):
		red[Vector2i(x, 3)] = [1] as Array[int]
	red[Vector2i(4, 3)] = [1, 2] as Array[int]
	assert_eq(view.red_cells(), red, "đường Kỵ binh tới Khoái, ô Khoái có cả đòn Bộ binh")
	assert_eq(_label_texts(view), {Vector2i(4, 3): "1·2"}, "số chỉ ở ô đòn trúng")
	assert_eq(view.arrows(), {Vector2i(1, 3): [Vector2i(1, 0)] as Array[Vector2i]}, "mũi tên ở ô đầu đường, chỉ Đông")


## Kỵ binh kề mục tiêu: ô đầu đường có quân nên mũi tên vẽ ở lớp trên đồng quân; ô đầu đường trống thì ở lớp dưới.
func test_arrow_over_token_when_first_cell_has_unit() -> void:
	var near: BattleState = BoardFixture.state({Vector2i(3, 3): "K", Vector2i(4, 3): "1"})
	near.telegraphs.append(Telegraph.new(near.unit_at(Vector2i(3, 3)).id, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 1))
	var view: TelegraphView = _telegraph_board(near).telegraph_view()
	assert_eq(view.arrows(), {Vector2i(4, 3): [Vector2i(1, 0)] as Array[Vector2i]})
	assert_true(view.arrow_on_top(Vector2i(4, 3)), "ô đầu đường có Khoái: mũi tên trên đồng quân")
	var far: TelegraphView = _telegraph_board(_charge_and_infantry()).telegraph_view()
	assert_false(far.arrow_on_top(Vector2i(1, 3)), "ô đầu đường trống: mũi tên ở lớp mặt đất")


## Hai Kỵ binh khác hướng cùng bắt đầu ở ô 2,1: giữ cả hai mũi tên.
func test_two_cavalry_sharing_first_cell_keep_both_arrows() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(2, 0): "K", Vector2i(1, 1): "K"})
	state.telegraphs.append(Telegraph.new(state.unit_at(Vector2i(2, 0)).id, Telegraph.Kind.DIRECTION, Vector2i(0, 1), 1))
	state.telegraphs.append(Telegraph.new(state.unit_at(Vector2i(1, 1)).id, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 2))
	var view: TelegraphView = _telegraph_board(state).telegraph_view()
	var dirs: Array[Vector2i] = [Vector2i(0, 1), Vector2i(1, 0)]
	assert_eq(view.arrows(), {Vector2i(2, 1): dirs})


## Ba đòn vào một ô: chuỗi `1·2·3` tự giảm cỡ chữ cho nằm trong mặt ô.
func test_many_numbers_shrink_to_fit_the_cell() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B", Vector2i(2, 3): "B", Vector2i(4, 3): "B",
		Vector2i(3, 3): "1"})
	state.telegraphs.append(Telegraph.new(state.unit_at(Vector2i(3, 2)).id, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	state.telegraphs.append(Telegraph.new(state.unit_at(Vector2i(2, 3)).id, Telegraph.Kind.CELL, Vector2i(1, 0), 2))
	state.telegraphs.append(Telegraph.new(state.unit_at(Vector2i(4, 3)).id, Telegraph.Kind.CELL, Vector2i(-1, 0), 3))
	var view: TelegraphView = _telegraph_board(state).telegraph_view()
	var label: Label = view.number_labels()[Vector2i(3, 3)] as Label
	assert_eq(label.text, "1·2·3")
	assert_lt(label.get_meta("font_size") as int, TelegraphView.NUMBER_FONT_SIZE, "chuỗi dài thì giảm cỡ chữ")
	assert_gte(label.get_meta("font_size") as int, TelegraphView.NUMBER_MIN_FONT_SIZE)
	assert_true(BoardView.cell_rect(Vector2i(3, 3)).encloses(view.number_glyph_rect(label)), "chữ nằm trong ô")
	var one: TelegraphView = _telegraph_board(_charge_and_infantry()).telegraph_view()
	assert_eq((one.number_labels()[Vector2i(4, 3)] as Label).get_meta("font_size"), TelegraphView.NUMBER_FONT_SIZE,
		"chuỗi ngắn giữ cỡ chữ lớn")


func test_no_telegraphs_draws_nothing() -> void:
	var view: TelegraphView = _telegraph_board(BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 3): "1"})) \
		.telegraph_view()
	assert_eq(view.red_cells(), {})
	assert_eq(view.number_labels(), {})
	assert_eq(view.arrows(), {})
	var board: BoardView = view.get_parent() as BoardView
	board.show_state(_charge_and_infantry())
	board.show_state(null)
	assert_eq(view.red_cells(), {}, "bàn trống: hết ô đỏ")
	assert_eq(view.number_labels(), {}, "bàn trống: hết số")


func test_red_path_redrawn_when_general_leaves_row() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 3): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 1))
	var board: BoardView = _telegraph_board(state)
	assert_eq(_label_texts(board.telegraph_view()), {Vector2i(4, 3): "1"})
	var moved: BattleState = state.clone()
	moved.unit_by_id(1).cell = Vector2i(4, 5)
	board.show_state(moved)
	assert_eq(board.telegraph_view().red_cells().size(), 6, "hàng trống: đỏ tới mép")
	assert_eq(_label_texts(board.telegraph_view()), {Vector2i(6, 3): "1"}, "số ở ô sát mép")


## Số thứ tự nằm dưới đồng quân và chấm máu, trong mặt ô; nhãn không nuốt chuột.
func test_number_clear_of_token_and_hp_dot() -> void:
	var board: BoardView = _telegraph_board(_charge_and_infantry())
	var view: TelegraphView = board.telegraph_view()
	var label: Label = view.number_labels()[Vector2i(4, 3)] as Label
	var glyphs: Rect2 = view.number_glyph_rect(label)
	var feet: Vector2 = BoardView.cell_center(Vector2i(4, 3))
	var coin: Vector2 = feet - Vector2(0, UnitToken.TOKEN_LIFT)
	assert_gt(glyphs.position.y, coin.y + UnitToken.RADIUS, "chữ số dưới mặt đồng")
	assert_gt(glyphs.position.y, coin.y + UnitToken.HP_OFFSET.y + UnitToken.HP_RADIUS, "chữ số dưới chấm máu")
	assert_true(BoardView.cell_rect(Vector2i(4, 3)).encloses(glyphs), "chữ số trong ô")
	assert_gte(TelegraphView.NUMBER_FONT_SIZE, 28, "chữ lớn")
	assert_eq(label.mouse_filter, Control.MOUSE_FILTER_IGNORE)


## Lớp đỏ dưới đồng quân, lớp số trên đồng quân và viền mục tiêu; F1 vẫn trên cùng.
func test_telegraph_layers_order() -> void:
	AppState.launch.dev = true
	var main: Node2D = _make_main()
	var board: BoardView = _board(main)
	var view: TelegraphView = board.telegraph_view()
	assert_lt(view.get_index(), board._terrain_labels.get_index(), "ô đỏ dưới chữ địa hình")
	assert_gt(view.numbers.get_index(), board._target_layer.get_index(), "số trên viền mục tiêu")
	assert_gt((main._coord_overlay as Node).get_index(), view.numbers.get_index(), "F1 vẫn trên cùng")


## Rừng là vật đầu tiên: ô rừng đỏ và có số, vẽ trên lớp số (khối không che).
func test_red_on_forest_block() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(6, 6): "1"}, {Vector2i(3, 3): "#"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(1, 0), 1))
	var view: TelegraphView = _telegraph_board(state).telegraph_view()
	assert_eq(view.red_cells().size(), 3)
	assert_eq(_label_texts(view), {Vector2i(3, 3): "1"})
	var face: Rect2 = view.top_rect(Vector2i(3, 3))
	assert_eq(face.position.y, BoardView.cell_rect(Vector2i(3, 3)).position.y - BoardView.BLOCK_HEIGHT, "mặt trên khối")
