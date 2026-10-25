class_name BoardView
extends Node2D
## Vẽ bàn cờ nhìn chếch từ trên xuống (ô vuông) bằng code, đặt giữa vùng trống bên trái HUD: ô, địa hình, đồng quân.
## Ô 0,0 ở góc trên trái; cột tăng thì sang phải, hàng tăng thì xuống dưới, giống bàn cờ chữ trong file trận.
## Vật nhô lên chỉ thấy mặt trên và mặt trước (phía người xem); vật ở hàng dưới che vật ở hàng trên.
## Nơi duy nhất đổi ô ↔ điểm: cell_center, cell_rect, cell_at (mặt đất) và pick_cell (thứ nhìn thấy dưới chuột).
## Gốc tọa độ local là góc trên trái của ô 0,0 trên mặt đất. Chỉ vẽ theo bản chụp (show_state); null thì về bàn trống.

## Cạnh ô (px), khớp tranh E8 64×64 hiện 1:1.
const TILE_SIZE: int = 64
## Đọc từ project.godot để chỉ có một nơi khai báo kích thước màn hình.
static var viewport_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width") as int,
	ProjectSettings.get_setting("display/window/size/viewport_height") as int
)
## Vùng trống cho bàn (tọa độ màn hình): dưới tiêu đề, trái bảng HUD, trên nhãn phiên bản.
const AREA: Rect2 = Rect2(16, 52, 940, 612)
const CELL_COLOR: Color = Color(0.93, 0.87, 0.73)
const LINE_COLOR: Color = Color(0.36, 0.24, 0.14)
const LINE_WIDTH: float = 2.0
const BORDER_WIDTH: float = 4.0
## Ký hiệu cảnh báo ô tiếp viện hiệp sau (Story 3.10, FR35): viền cam vàng khác ô đỏ đòn địch.
const REINFORCEMENT_BORDER: Color = Color(1.0, 0.75, 0.2)
const REINFORCEMENT_FILL: Color = Color(0.95, 0.65, 0.15, 0.35)
## Độ dày mép bàn ở cạnh trước.
const EDGE_DEPTH: float = 12.0
const EDGE_SHADE: float = 0.4
## Rừng, kho lương, làng nhô lên; ô ải là bệ thấp, quân đứng lên được (tác giả chốt 2026-10-18).
const BLOCK_HEIGHT: float = 16.0
const PASS_HEIGHT: float = BLOCK_HEIGHT / 2.0
const BLOCK_KINDS: Array[int] = [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]
## Sông trũng xuống; bờ sông ở cạnh trên lộ ra, tối hơn mặt nước.
const RIVER_DEPTH: float = 6.0
const RIVER_BANK_SHADE: float = 0.4
## Chừa thêm phía trên vật cao nhất ở hàng đầu (để tính khung bàn).
const TOP_MARGIN: float = 4.0

## Màu từng loại ô (màu UI, không phải số cân bằng).
const TERRAIN_COLORS: Dictionary = {
	Terrain.PLAIN: CELL_COLOR,
	Terrain.RIVER: Color(0.49, 0.71, 0.87),
	Terrain.FOREST: Color(0.33, 0.55, 0.31),
	Terrain.SPIKES: Color(0.80, 0.62, 0.45),
	Terrain.GRANARY: Color(0.85, 0.70, 0.30),
	Terrain.VILLAGE: Color(0.76, 0.52, 0.40),
	Terrain.PASS: Color(0.70, 0.70, 0.72),
}
## Khóa dịch của chữ ngắn trên ô. Đất trống không có chữ.
const TERRAIN_KEYS: Dictionary = {
	Terrain.RIVER: "terrain.river",
	Terrain.FOREST: "terrain.forest",
	Terrain.SPIKES: "terrain.spikes",
	Terrain.GRANARY: "terrain.granary",
	Terrain.VILLAGE: "terrain.village",
	Terrain.PASS: "terrain.pass",
}
const TERRAIN_FONT_SIZE: int = 12
## Ký hiệu hầm chông: ba mũi nhọn ở nửa trên ô (nửa dưới để chữ).
const SPIKE_COLOR: Color = Color(0.45, 0.30, 0.18)
const SPIKE_SIZE: Vector2 = Vector2(10, 14)
const SPIKE_OFFSETS: Array[Vector2] = [Vector2(-16, -10), Vector2(0, -14), Vector2(16, -10)]
## Ô ngoài bàn (cell_at).
const NO_CELL: Vector2i = Vector2i(-1, -1)
## Ô đi tới được: xanh lá nhạt, khác đỏ của ô báo đòn (E2) và khác màu sông.
const REACH_COLOR: Color = Color(0.45, 0.78, 0.40, 0.55)
## Viền quanh ô mục tiêu đánh được (tác giả chốt 2026-10-18: trắng), chỉ viền, không tô: ô đỏ báo đòn E2 tô kín.
## Ô chờ xác nhận (tướng đã đi, bấm lần đầu) viền dày gấp đôi.
const TARGET_COLOR: Color = Color(1.0, 1.0, 1.0)
const TARGET_WIDTH: float = 3.0
const PENDING_WIDTH: float = 6.0
## Viền thụt vào trong ô (px) để không chồng lên nét lưới.
const TARGET_INSET: float = 5.0
## Vòng elip trên mặt đất quanh chân tướng đang chọn; nằm gọn trong ô.
const SELECT_COLOR: Color = Color(0.95, 0.72, 0.10)
const SELECT_RADIUS: Vector2 = Vector2(28, 18)
const SELECT_WIDTH: float = 4.0
const SELECT_POINTS: int = 40
## Đường đi khi rê chuột lên ô sáng.
const PATH_COLOR: Color = Color(0.13, 0.35, 0.65)
const PATH_WIDTH: float = 6.0
const PATH_END_RADIUS: Vector2 = Vector2(8, 6)

## Cỡ bàn trống khi chưa có trận (màn hình lỗi, test). Có trận thì theo state.size (Story 1.9).
const EMPTY_SIZE: Vector2i = Vector2i(7, 7)

var cols: int = EMPTY_SIZE.x
var rows: int = EMPTY_SIZE.y

## Bản chụp đang vẽ; null là bàn trống.
var _state: BattleState = null
## Chữ của ô phẳng (sông, hầm chông, ô ải), nằm dưới đồng quân.
var _terrain_labels: Node2D
## Khối địa hình và đồng quân, sắp theo y (tức theo hang): vật ở hàng dưới, gần người xem, vẽ sau.
var _world: Node2D
## Viền mục tiêu, vẽ trên đồng quân để thấy đủ 4 cạnh (tác giả chốt 2026-10-20, review 1.8).
var _target_layer: Node2D
## Ô đỏ báo đòn (dưới đồng quân) và lớp số thứ tự của nó (trên cùng, trừ F1) (Story 2.7).
var _telegraph: TelegraphView
## Nhãn số máu mất do hầm chông trên ô sáng (Story 3.4).
var _damage_labels: Node2D
var _preview: PreviewView
## id quân -> UnitToken
var _tokens: Dictionary = {}
## Tướng đang chọn: ô của nó (NO_CELL là không chọn), các ô sáng, đường đi đang vẽ (không gồm ô tướng).
var _selected_cell: Vector2i = NO_CELL
var _lit_cells: Array[Vector2i] = []
## Ô mục tiêu đánh được của tướng đang chọn, và ô đang chờ xác nhận (NO_CELL là không có).
var _target_cells: Array[Vector2i] = []
var _pending_cell: Vector2i = NO_CELL
var _path: Array[Vector2i] = []


## Tâm ô trên mặt đất, tính trong tọa độ của BoardView (gốc là góc trên trái của ô 0,0).
static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * TILE_SIZE, (cell.y + 0.5) * TILE_SIZE)


## Ô vuông trên mặt đất.
static func cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell * TILE_SIZE), Vector2(TILE_SIZE, TILE_SIZE))


## Tâm mặt trên của ô loại kind: nơi đồng quân đứng (ô ải cao hơn mặt đất).
static func top_center(cell: Vector2i, kind: int) -> Vector2:
	return cell_center(cell) - Vector2(0, surface_height(kind))


## Mặt trên của loại ô cao hơn mặt đất bao nhiêu (0 là phẳng).
static func surface_height(kind: int) -> float:
	if BLOCK_KINDS.has(kind):
		return BLOCK_HEIGHT
	if kind == Terrain.PASS:
		return PASS_HEIGHT
	return 0.0


## Vẽ khối nhô lên height từ ô ground trên mặt đất, lên canvas: mặt trên là ground nâng lên height, mặt trước là
## dải cao height ở cạnh dưới ground, tối hơn front_shade. Nhìn chếch từ phía người xem nên không thấy mặt bên.
## Chỉ gọi trong _draw của canvas đó.
static func draw_raised(canvas: CanvasItem, ground: Rect2, height: float, color: Color, front_shade: float) -> void:
	var top: Rect2 = Rect2(ground.position - Vector2(0, height), ground.size)
	var front: Rect2 = Rect2(top.position.x, top.end.y, ground.size.x, height)
	canvas.draw_rect(front, color.darkened(front_shade))
	canvas.draw_rect(top, color)
	canvas.draw_rect(front, LINE_COLOR, false, 1.5)
	canvas.draw_rect(top, LINE_COLOR, false, 1.5)


## Ô chứa điểm local_pos trên mặt đất (tọa độ của BoardView); ngoài bàn thì NO_CELL.
## cell_at(cell_center(c)) == c.
func cell_at(local_pos: Vector2) -> Vector2i:
	# floori, không dùng int(): int(-0.5) là 0, điểm ngay bên trái hay ngay trên bàn sẽ rơi nhầm vào ô.
	var cell: Vector2i = Vector2i(floori(local_pos.x / TILE_SIZE), floori(local_pos.y / TILE_SIZE))
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		return NO_CELL
	return cell


## Ô người chơi nhìn thấy dưới chuột: đồng quân và khối nhô lên che ô phía sau, nên trúng chúng thì lấy ô
## của chúng (vật gần người xem nhất, tức hàng lớn nhất, thắng); không trúng gì thì là ô mặt đất (cell_at).
func pick_cell(local_pos: Vector2) -> Vector2i:
	var best: Vector2i = NO_CELL
	var best_depth: int = -1
	for token: UnitToken in _tokens.values():
		if token.hit(local_pos - token.position) and token.cell.y > best_depth:
			best = token.cell
			best_depth = token.cell.y
	if _state != null:
		for r: int in range(rows):
			for c: int in range(cols):
				var cell: Vector2i = Vector2i(c, r)
				var height: float = surface_height(_state.terrain_at(cell))
				if height == 0.0 or r <= best_depth:
					continue
				if _silhouette(cell, height).has_point(local_pos):
					best = cell
					best_depth = r
	return best if best != NO_CELL else cell_at(local_pos)


## Khung chữ nhật bao trọn bàn (cả mép bàn, khối và đồng quân nhô lên), trong tọa độ của cha.
func board_rect() -> Rect2:
	return transform * _local_rect()


## Vẽ vòng quanh tướng ở unit_cell và tô sáng cells. Xóa đường đi cũ.
## cell_penalties: ô -> số máu sẽ mất do hầm chông trên đường đi (Story 3.4).
func show_selection(unit_cell: Vector2i, cells: Array[Vector2i], targets: Array[Vector2i] = [],
		cell_penalties: Dictionary = {}) -> void:
	_selected_cell = unit_cell
	_lit_cells = cells.duplicate()
	_target_cells = targets.duplicate()
	_pending_cell = NO_CELL
	_path = []
	_clear_damage_labels()
	if _damage_labels != null:
		for cell: Variant in cell_penalties.keys():
			var dmg: int = cell_penalties[cell] as int
			if dmg > 0 and cell is Vector2i:
				var label: Label = Label.new()
				label.set_meta("cell", cell as Vector2i)
				label.text = tr("board.damage_penalty") % dmg
				label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
				label.add_theme_font_size_override("font_size", 14)
				label.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.size = Vector2(30, 20)
				label.position = _top_center(cell as Vector2i) - label.size / 2.0
				_damage_labels.add_child(label)
	_redraw()


## Đường đi từ tướng đang chọn qua path (không gồm ô tướng). [] là xóa.
func show_path(path: Array[Vector2i]) -> void:
	if path == _path:
		return
	_path = path.duplicate()
	_redraw()


## Ô mục tiêu đang chờ bấm lần nữa để đánh; NO_CELL là bỏ chờ.
func show_pending(cell: Vector2i) -> void:
	if cell == _pending_cell:
		return
	_pending_cell = cell
	_redraw()


func clear_selection() -> void:
	_selected_cell = NO_CELL
	_lit_cells = []
	_target_cells = []
	_pending_cell = NO_CELL
	_path = []
	_clear_damage_labels()
	_redraw()


func _clear_damage_labels() -> void:
	if _damage_labels != null:
		for child: Node in _damage_labels.get_children():
			_damage_labels.remove_child(child)
			child.queue_free()


func lit_cells() -> Array[Vector2i]:
	return _lit_cells.duplicate()


func target_cells() -> Array[Vector2i]:
	return _target_cells.duplicate()


func pending_cell() -> Vector2i:
	return _pending_cell


## Nhãn trừ máu hầm chông trên các ô sáng (để test): ô -> chữ ("−1", "−2"...).
func damage_label_texts() -> Dictionary:
	var out: Dictionary = {}
	if _damage_labels == null:
		return out
	for child: Node in _damage_labels.get_children():
		var label: Label = child as Label
		if label != null and label.has_meta("cell"):
			out[label.get_meta("cell") as Vector2i] = label.text
	return out


func path() -> Array[Vector2i]:
	return _path.duplicate()


## Hệ số thu khung bàn board_size cho vừa area_size: 1 / k với k nguyên dương nhỏ nhất còn vừa (thu theo bậc
## nguyên để tranh pixel không nhòe, không bao giờ thu lẻ). Ở 1280×720 mọi cỡ bàn hợp lệ đều ra 1.
static func fit_scale(board_size: Vector2, area_size: Vector2) -> float:
	var k: int = maxi(1, ceili(maxf(board_size.x / area_size.x, board_size.y / area_size.y)))
	return 1.0 / k


## Canh bàn cols × rows giữa AREA, thu theo bậc nguyên nếu không vừa; góc bàn rơi đúng điểm ảnh nguyên.
func setup(new_cols: int = EMPTY_SIZE.x, new_rows: int = EMPTY_SIZE.y) -> void:
	cols = new_cols
	rows = new_rows
	var local: Rect2 = _local_rect()
	var factor: float = fit_scale(local.size, AREA.size)
	scale = Vector2(factor, factor)
	position = (AREA.get_center() - local.get_center() * factor).round()
	_redraw()


func _ready() -> void:
	# Thứ tự con: ô đỏ báo đòn, chữ ô phẳng, khối và đồng quân, viền mục tiêu, số thứ tự đòn. Overlay F1 do
	# main.gd thêm vào sau cùng. Ô đỏ đứng trước chữ ô phẳng để chữ địa hình vẫn đọc được.
	_telegraph = TelegraphView.new()
	add_child(_telegraph)
	_terrain_labels = Node2D.new()
	add_child(_terrain_labels)
	_world = Node2D.new()
	_world.y_sort_enabled = true
	add_child(_world)
	# Bóng mờ xem trước đòn (Story 2.12): trên đồng quân, dưới viền mục tiêu và lớp số thứ tự đòn.
	_preview = PreviewView.new()
	add_child(_preview)
	_target_layer = Node2D.new()
	_target_layer.draw.connect(_draw_targets)
	add_child(_target_layer)
	_damage_labels = Node2D.new()
	add_child(_damage_labels)
	add_child(_telegraph.numbers)
	setup(cols, rows)


func show_state(state: BattleState) -> void:
	_state = state
	if state != null:
		setup(state.size.x, state.size.y)
	else:
		clear_selection()
	# Bàn đổi thì bóng xem trước của lệnh cũ không còn nghĩa.
	_preview.clear()
	_rebuild_terrain()
	_sync_tokens()
	_telegraph.show_state(state)
	_redraw()


## Ô đỏ báo đòn đang vẽ.
func telegraph_view() -> TelegraphView:
	return _telegraph


## Bóng mờ xem trước đòn (Story 2.12).
func preview_view() -> PreviewView:
	return _preview


## Đồng quân đang hiện, theo id.
func tokens() -> Dictionary:
	return _tokens


## Khung bàn trong tọa độ của BoardView (cả nửa nét viền bàn).
## Phía trên: đầu đồng quân đứng trên bệ ô ải ở hàng 0, hoặc mặt trên khối nhô lên, cái nào cao hơn.
func _local_rect() -> Rect2:
	var stroke: float = BORDER_WIDTH / 2.0
	var left: float = -stroke
	var right: float = cols * TILE_SIZE + stroke
	var bottom: float = rows * TILE_SIZE + EDGE_DEPTH + stroke
	var token_top: float = PASS_HEIGHT + UnitToken.TOKEN_LIFT + UnitToken.RADIUS - TILE_SIZE / 2.0
	var top: float = maxf(token_top, BLOCK_HEIGHT) + TOP_MARGIN
	return Rect2(left, -top, right - left, bottom + top)


## Mặt trên của ô (ô ải cao hơn mặt đất).
func _surface(cell: Vector2i) -> float:
	return 0.0 if _state == null else surface_height(_state.terrain_at(cell))


## Tâm mặt trên của ô: nơi đồng quân đứng, nơi vẽ ô sáng và đường đi.
func _top_center(cell: Vector2i) -> Vector2:
	return cell_center(cell) - Vector2(0, _surface(cell))


## Hình bao của khối nhô lên height ở cell (mặt trên nâng lên và mặt trước).
func _silhouette(cell: Vector2i, height: float) -> Rect2:
	var ground: Rect2 = cell_rect(cell)
	return Rect2(ground.position - Vector2(0, height), ground.size + Vector2(0, height))


## Dựng lại chữ ô phẳng và khối nhô lên theo bản chụp.
func _rebuild_terrain() -> void:
	for child: Node in _terrain_labels.get_children():
		_terrain_labels.remove_child(child)
		child.queue_free()
	for child: Node in _world.get_children():
		if child is TerrainBlock:
			_world.remove_child(child)
			child.queue_free()
	if _state == null:
		return
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			var kind: int = _state.terrain_at(cell)
			if not TERRAIN_KEYS.has(kind):
				continue
			var text: String = tr(TERRAIN_KEYS[kind] as String)
			if BLOCK_KINDS.has(kind):
				var block: TerrainBlock = TerrainBlock.new()
				block.setup(cell, kind, BLOCK_HEIGHT, text)
				_world.add_child(block)
				continue
			# Ô phẳng: chữ ở phần dưới ô, không bị đồng quân đứng giữa ô che hết.
			var label: Label = Label.new()
			label.text = text
			label.add_theme_font_size_override("font_size", TERRAIN_FONT_SIZE)
			label.add_theme_color_override("font_color", LINE_COLOR)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = Vector2(TILE_SIZE, TERRAIN_FONT_SIZE * 1.5)
			label.position = _top_center(cell) + Vector2(0, TILE_SIZE / 4.0) - label.size / 2.0
			_terrain_labels.add_child(label)


## Thêm đồng cho quân mới, bỏ đồng của quân không còn, cập nhật đồng còn lại.
## Id cũ mà đổi loại quân (nạp lại trận đã sửa) thì dựng lại đồng: tên và màu phe chỉ đặt lúc setup.
func _sync_tokens() -> void:
	var alive: Dictionary = {}
	if _state != null:
		for unit: Unit in _state.units:
			alive[unit.id] = true
			var lift: float = _surface(unit.cell)
			if _tokens.has(unit.id):
				var old: UnitToken = _tokens[unit.id] as UnitToken
				if old.unit_type == unit.type:
					old.update(unit, lift)
					continue
				_remove_token(unit.id)
			var token: UnitToken = UnitToken.new()
			token.setup(unit, lift)
			_world.add_child(token)
			_tokens[unit.id] = token
	for id: int in _tokens.keys():
		if not alive.has(id):
			_remove_token(id)


func _remove_token(id: int) -> void:
	var token: UnitToken = _tokens[id] as UnitToken
	_world.remove_child(token)
	token.queue_free()
	_tokens.erase(id)


func _draw() -> void:
	var surface: Rect2 = Rect2(0, 0, cols * TILE_SIZE, rows * TILE_SIZE)
	# Mép bàn: cả bàn là một tấm dày EDGE_DEPTH, mặt trên là mặt đất.
	draw_raised(self, Rect2(surface.position + Vector2(0, EDGE_DEPTH), surface.size), EDGE_DEPTH, CELL_COLOR, EDGE_SHADE)
	if _state != null:
		for r: int in range(rows):
			for c: int in range(cols):
				var cell: Vector2i = Vector2i(c, r)
				match _state.terrain_at(cell):
					Terrain.RIVER:
						_draw_river(cell)
					Terrain.SPIKES:
						_draw_spikes(cell)
	for c: int in range(1, cols):
		draw_line(Vector2(c * TILE_SIZE, 0), Vector2(c * TILE_SIZE, surface.end.y), LINE_COLOR, LINE_WIDTH, true)
	for r: int in range(1, rows):
		draw_line(Vector2(0, r * TILE_SIZE), Vector2(surface.end.x, r * TILE_SIZE), LINE_COLOR, LINE_WIDTH, true)
	draw_rect(surface, LINE_COLOR, false, BORDER_WIDTH)
	# Bệ ô ải, ô sáng và vòng chọn vẽ trên mặt đất, từng hàng từ trên xuống (quân đứng lên bệ được,
	# xem BLOCK_KINDS): bệ ô ải ở hàng dưới che ô sáng ở hàng trên, ô sáng trên bệ nằm trên mặt bệ.
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			if _state != null and _state.terrain_at(cell) == Terrain.PASS:
				draw_raised(self, cell_rect(cell), PASS_HEIGHT, TERRAIN_COLORS[Terrain.PASS] as Color, EDGE_SHADE)
			if _lit_cells.has(cell):
				draw_rect(_top_rect(cell), REACH_COLOR)
			if cell == _selected_cell:
				draw_polyline(_ellipse(_top_center(cell), SELECT_RADIUS), SELECT_COLOR, SELECT_WIDTH, true)
	if _state != null and not _state.reinforcement_warnings.is_empty():
		for cell: Vector2i in _state.reinforcement_warnings:
			_draw_reinforcement_marker(cell)
	if _selected_cell != NO_CELL and not _path.is_empty():
		var points: PackedVector2Array = PackedVector2Array([_top_center(_selected_cell)])
		for cell: Vector2i in _path:
			points.append(_top_center(cell))
		draw_polyline(points, PATH_COLOR, PATH_WIDTH, true)
		# Bỏ điểm cuối trùng điểm đầu: đa giác không nhận điểm lặp.
		draw_colored_polygon(_ellipse(_top_center(_path[_path.size() - 1]), PATH_END_RADIUS).slice(0, SELECT_POINTS), PATH_COLOR)


## Mặt trên của ô (ô ải nâng lên theo bệ).
func _top_rect(cell: Vector2i) -> Rect2:
	var ground: Rect2 = cell_rect(cell)
	return Rect2(ground.position - Vector2(0, _surface(cell)), ground.size)


## Vẽ lại mặt đất và lớp viền mục tiêu.
func _redraw() -> void:
	queue_redraw()
	if _target_layer != null:
		_target_layer.queue_redraw()


## Khung vuông quanh mỗi mục tiêu, thụt vào trong mặt trên ô, không tô; ô chờ xác nhận viền dày hơn.
## Vẽ lên _target_layer (trên đồng quân), cùng tọa độ với BoardView.
func _draw_targets() -> void:
	for cell: Vector2i in _target_cells:
		var width: float = PENDING_WIDTH if cell == _pending_cell else TARGET_WIDTH
		_target_layer.draw_rect(_top_rect(cell).grow(-TARGET_INSET), TARGET_COLOR, false, width)


## Sông trũng: cả ô là bờ tối, mặt nước bỏ dải RIVER_DEPTH ở trên cùng. Ô ngay phía trên cũng là sông thì không có
## bờ, nước liền một mạch; hàng 0 luôn có bờ.
func _draw_river(cell: Vector2i) -> void:
	var color: Color = TERRAIN_COLORS[Terrain.RIVER] as Color
	var ground: Rect2 = cell_rect(cell)
	var above: Vector2i = cell + Vector2i(0, -1)
	# terrain_at không tự kiểm biên: chỉ hỏi khi ô phía trên còn trong bàn.
	if above.y >= 0 and _state.terrain_at(above) == Terrain.RIVER:
		draw_rect(ground, color)
		return
	draw_rect(ground, color.darkened(RIVER_BANK_SHADE))
	draw_rect(Rect2(ground.position + Vector2(0, RIVER_DEPTH), ground.size - Vector2(0, RIVER_DEPTH)), color)


## Hầm chông: ô phẳng màu riêng, ba mũi nhọn quanh tâm.
func _draw_spikes(cell: Vector2i) -> void:
	var center: Vector2 = cell_center(cell)
	draw_rect(cell_rect(cell), TERRAIN_COLORS[Terrain.SPIKES] as Color)
	for offset: Vector2 in SPIKE_OFFSETS:
		var base: Vector2 = center + offset
		draw_colored_polygon(PackedVector2Array([
			base + Vector2(-SPIKE_SIZE.x / 2.0, SPIKE_SIZE.y / 2.0),
			base + Vector2(SPIKE_SIZE.x / 2.0, SPIKE_SIZE.y / 2.0),
			base + Vector2(0, -SPIKE_SIZE.y / 2.0),
		]), SPIKE_COLOR)


## Ký hiệu đánh dấu ô tiếp viện hiệp sau (Story 3.10): nền vàng cam mờ, viền nổi và chevron hướng xuống.
func _draw_reinforcement_marker(cell: Vector2i) -> void:
	var rect: Rect2 = _top_rect(cell).grow(-3.0)
	draw_rect(rect, REINFORCEMENT_FILL, true)
	draw_rect(rect, REINFORCEMENT_BORDER, false, 3.0)
	var center: Vector2 = _top_center(cell)
	var chevron: PackedVector2Array = PackedVector2Array([
		center + Vector2(-12, -8),
		center + Vector2(0, 4),
		center + Vector2(12, -8)
	])
	draw_polyline(chevron, REINFORCEMENT_BORDER, 3.0)


## Elip khép kín (vòng chọn, chấm cuối đường đi) nằm trên mặt ô nhìn chếch.
func _ellipse(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(SELECT_POINTS + 1):
		var angle: float = TAU * i / SELECT_POINTS
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
