class_name BoardView
extends Node2D
## Vẽ bàn cờ nghiêng (isometric 2:1) bằng code, đặt giữa vùng trống bên trái HUD: 49 ô thoi, địa hình, đồng quân.
## Ô 0,0 ở đỉnh trên; cột tăng thì xuống bên phải, hàng tăng thì xuống bên trái (tác giả chốt 2026-10-18).
## Nơi duy nhất đổi ô ↔ điểm: cell_center, cell_at (mặt đất) và pick_cell (thứ nhìn thấy dưới chuột).
## Gốc tọa độ local là đỉnh trên của ô 0,0. Chỉ vẽ theo bản chụp (show_state); null thì về bàn trống.

## Ô thoi rộng gấp đôi cao.
const TILE_W: int = 128
const TILE_H: int = 64
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
## Độ dày mép bàn ở hai cạnh trước.
const EDGE_DEPTH: float = 12.0
const EDGE_LEFT_SHADE: float = 0.35
const EDGE_RIGHT_SHADE: float = 0.5
## Rừng, kho lương, làng nhô lên; ô ải là bệ thấp, quân đứng lên được (tác giả chốt 2026-10-18).
const BLOCK_HEIGHT: float = 16.0
const PASS_HEIGHT: float = BLOCK_HEIGHT / 2.0
const BLOCK_KINDS: Array[int] = [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]
## Sông trũng xuống; thành sông phía sau lộ ra, tối hơn mặt nước.
const RIVER_DEPTH: float = 6.0
const RIVER_BANK_SHADE: float = 0.4
## Phần đồng quân và khối nhô lên trên đỉnh ô 0,0 (để tính khung bàn).
const TOP_OVERHANG: float = 28.0

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
## Ký hiệu hầm chông: ba mũi nhọn quanh tâm ô.
const SPIKE_COLOR: Color = Color(0.45, 0.30, 0.18)
const SPIKE_SIZE: Vector2 = Vector2(10, 12)
const SPIKE_OFFSETS: Array[Vector2] = [Vector2(-22, -2), Vector2(0, -8), Vector2(22, -2)]
## Ô ngoài bàn (cell_at).
const NO_CELL: Vector2i = Vector2i(-1, -1)
## Ô đi tới được: xanh lá nhạt, khác đỏ của ô báo đòn (E2) và khác màu sông.
const REACH_COLOR: Color = Color(0.45, 0.78, 0.40, 0.55)
## Vòng elip trên mặt đất quanh chân tướng đang chọn.
const SELECT_COLOR: Color = Color(0.95, 0.72, 0.10)
const SELECT_RADIUS: Vector2 = Vector2(40, 20)
const SELECT_WIDTH: float = 4.0
const SELECT_POINTS: int = 40
## Đường đi khi rê chuột lên ô sáng.
const PATH_COLOR: Color = Color(0.13, 0.35, 0.65)
const PATH_WIDTH: float = 6.0
const PATH_END_RADIUS: Vector2 = Vector2(10, 5)

var cols: int = 7
var rows: int = 7

## Bản chụp đang vẽ; null là bàn trống.
var _state: BattleState = null
## Chữ của ô phẳng (sông, hầm chông, ô ải), nằm dưới đồng quân.
var _terrain_labels: Node2D
## Khối địa hình và đồng quân, sắp theo y (tức theo cot + hang): vật ở gần người xem vẽ sau.
var _world: Node2D
## id quân -> UnitToken
var _tokens: Dictionary = {}
## Tướng đang chọn: ô của nó (NO_CELL là không chọn), các ô sáng, đường đi đang vẽ (không gồm ô tướng).
var _selected_cell: Vector2i = NO_CELL
var _lit_cells: Array[Vector2i] = []
var _path: Array[Vector2i] = []


## Tâm ô trên mặt đất, tính trong tọa độ của BoardView (gốc là đỉnh trên của ô 0,0).
static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2((cell.x - cell.y) * TILE_W / 2.0, (cell.x + cell.y) * TILE_H / 2.0 + TILE_H / 2.0)


## Bốn đỉnh ô thoi quanh center: trên, phải, dưới, trái.
static func diamond(center: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -TILE_H / 2.0), center + Vector2(TILE_W / 2.0, 0),
		center + Vector2(0, TILE_H / 2.0), center + Vector2(-TILE_W / 2.0, 0),
	])


## Mặt trên của loại ô cao hơn mặt đất bao nhiêu (0 là phẳng).
static func surface_height(kind: int) -> float:
	if BLOCK_KINDS.has(kind):
		return BLOCK_HEIGHT
	if kind == Terrain.PASS:
		return PASS_HEIGHT
	return 0.0


## Vẽ khối thoi nhô lên height từ các đỉnh corners (trên, phải, dưới, trái) trên mặt đất, lên canvas.
## Chỉ gọi trong _draw của canvas đó.
static func draw_raised(canvas: CanvasItem, corners: PackedVector2Array, height: float, color: Color,
		left_shade: float, right_shade: float) -> void:
	var up: Vector2 = Vector2(0, -height)
	var top: PackedVector2Array = PackedVector2Array([corners[0] + up, corners[1] + up, corners[2] + up, corners[3] + up])
	canvas.draw_colored_polygon(PackedVector2Array([top[3], top[2], corners[2], corners[3]]), color.darkened(left_shade))
	canvas.draw_colored_polygon(PackedVector2Array([top[2], top[1], corners[1], corners[2]]), color.darkened(right_shade))
	canvas.draw_colored_polygon(top, color)
	var outline: PackedVector2Array = top.duplicate()
	outline.append(top[0])
	canvas.draw_polyline(outline, LINE_COLOR, 1.5, true)
	canvas.draw_polyline(PackedVector2Array([top[3], corners[3], corners[2], corners[1], top[1]]), LINE_COLOR, 1.5, true)
	canvas.draw_line(top[2], corners[2], LINE_COLOR, 1.5, true)


## Ô chứa điểm local_pos trên mặt đất (tọa độ của BoardView); ngoài bàn thì NO_CELL.
## cell_at(cell_center(c)) == c.
func cell_at(local_pos: Vector2) -> Vector2i:
	var a: float = local_pos.x / TILE_W + local_pos.y / TILE_H
	var b: float = local_pos.y / TILE_H - local_pos.x / TILE_W
	var cell: Vector2i = Vector2i(floori(a), floori(b))
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		return NO_CELL
	return cell


## Ô người chơi nhìn thấy dưới chuột: đồng quân và khối nhô lên che ô phía sau, nên trúng chúng thì lấy ô
## của chúng (vật gần người xem nhất thắng); không trúng gì thì là ô mặt đất (cell_at).
func pick_cell(local_pos: Vector2) -> Vector2i:
	var best: Vector2i = NO_CELL
	var best_depth: int = -1
	for token: UnitToken in _tokens.values():
		if token.hit(local_pos - token.position) and token.cell.x + token.cell.y > best_depth:
			best = token.cell
			best_depth = token.cell.x + token.cell.y
	if _state != null:
		for r: int in range(rows):
			for c: int in range(cols):
				var cell: Vector2i = Vector2i(c, r)
				var height: float = surface_height(_state.terrain_at(cell))
				if height == 0.0 or c + r <= best_depth:
					continue
				if Geometry2D.is_point_in_polygon(local_pos, _silhouette(cell, height)):
					best = cell
					best_depth = c + r
	return best if best != NO_CELL else cell_at(local_pos)


## Khung chữ nhật bao trọn bàn (cả mép bàn, khối và đồng quân nhô lên), trong tọa độ của cha.
func board_rect() -> Rect2:
	var local: Rect2 = _local_rect()
	return Rect2(position + local.position, local.size)


## Vẽ vòng quanh tướng ở unit_cell và tô sáng cells. Xóa đường đi cũ.
func show_selection(unit_cell: Vector2i, cells: Array[Vector2i]) -> void:
	_selected_cell = unit_cell
	_lit_cells = cells.duplicate()
	_path = []
	queue_redraw()


## Đường đi từ tướng đang chọn qua path (không gồm ô tướng). [] là xóa.
func show_path(path: Array[Vector2i]) -> void:
	if path == _path:
		return
	_path = path.duplicate()
	queue_redraw()


func clear_selection() -> void:
	_selected_cell = NO_CELL
	_lit_cells = []
	_path = []
	queue_redraw()


func lit_cells() -> Array[Vector2i]:
	return _lit_cells.duplicate()


func path() -> Array[Vector2i]:
	return _path.duplicate()


func setup(new_cols: int = 7, new_rows: int = 7) -> void:
	cols = new_cols
	rows = new_rows
	position = (AREA.get_center() - _local_rect().get_center()).round()
	queue_redraw()


func _ready() -> void:
	# Thứ tự con: chữ ô phẳng, rồi khối và đồng quân. Overlay F1 do main.gd thêm vào sau cùng.
	_terrain_labels = Node2D.new()
	add_child(_terrain_labels)
	_world = Node2D.new()
	_world.y_sort_enabled = true
	add_child(_world)
	setup(cols, rows)


func show_state(state: BattleState) -> void:
	_state = state
	if state != null:
		setup(state.size.x, state.size.y)
	else:
		clear_selection()
	_rebuild_terrain()
	_sync_tokens()
	queue_redraw()


## Đồng quân đang hiện, theo id.
func tokens() -> Dictionary:
	return _tokens


## Khung bàn trong tọa độ của BoardView (cả nửa nét viền bàn).
func _local_rect() -> Rect2:
	var stroke: float = BORDER_WIDTH / 2.0
	var left: float = -rows * TILE_W / 2.0 - stroke
	var right: float = cols * TILE_W / 2.0 + stroke
	var bottom: float = (cols + rows) * TILE_H / 2.0 + EDGE_DEPTH + stroke
	return Rect2(left, -TOP_OVERHANG, right - left, bottom + TOP_OVERHANG)


## Mặt trên của ô (ô ải cao hơn mặt đất).
func _surface(cell: Vector2i) -> float:
	return 0.0 if _state == null else surface_height(_state.terrain_at(cell))


## Tâm mặt trên của ô: nơi đồng quân đứng, nơi vẽ ô sáng và đường đi.
func _top_center(cell: Vector2i) -> Vector2:
	return cell_center(cell) - Vector2(0, _surface(cell))


## Hình bao của khối nhô lên height ở cell (mặt trên và hai mặt bên).
func _silhouette(cell: Vector2i, height: float) -> PackedVector2Array:
	var g: PackedVector2Array = diamond(cell_center(cell))
	var up: Vector2 = Vector2(0, -height)
	return PackedVector2Array([g[0] + up, g[1] + up, g[1], g[2], g[3], g[3] + up])


## Điểm lưới: đường a = const là ranh cột, b = const là ranh hàng.
func _grid_point(a: float, b: float) -> Vector2:
	return Vector2((a - b) * TILE_W / 2.0, (a + b) * TILE_H / 2.0)


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
			# Ô phẳng: chữ ở nửa dưới ô thoi, không bị đồng quân đứng giữa ô che.
			var label: Label = Label.new()
			label.text = text
			label.add_theme_font_size_override("font_size", TERRAIN_FONT_SIZE)
			label.add_theme_color_override("font_color", LINE_COLOR)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = Vector2(TILE_W / 2.0, TERRAIN_FONT_SIZE * 1.5)
			label.position = _top_center(cell) + Vector2(0, TILE_H / 4.0) - label.size / 2.0
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
	var big: PackedVector2Array = PackedVector2Array([
		_grid_point(0, 0), _grid_point(cols, 0), _grid_point(cols, rows), _grid_point(0, rows),
	])
	# Mép bàn: cả bàn là một tấm dày EDGE_DEPTH, mặt trên là mặt đất.
	var base: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in big:
		base.append(point + Vector2(0, EDGE_DEPTH))
	draw_raised(self, base, EDGE_DEPTH, CELL_COLOR, EDGE_LEFT_SHADE, EDGE_RIGHT_SHADE)
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
		draw_line(_grid_point(c, 0), _grid_point(c, rows), LINE_COLOR, LINE_WIDTH, true)
	for r: int in range(1, rows):
		draw_line(_grid_point(0, r), _grid_point(cols, r), LINE_COLOR, LINE_WIDTH, true)
	var border: PackedVector2Array = big.duplicate()
	border.append(big[0])
	draw_polyline(border, LINE_COLOR, BORDER_WIDTH, true)
	# Bệ ô ải vẽ trên mặt đất, theo thứ tự sâu dần (quân đứng lên được, xem BLOCK_KINDS).
	if _state != null:
		for depth: int in range(cols + rows - 1):
			for c: int in range(cols):
				var cell: Vector2i = Vector2i(c, depth - c)
				if cell.y >= 0 and cell.y < rows and _state.terrain_at(cell) == Terrain.PASS:
					draw_raised(self, diamond(cell_center(cell)), PASS_HEIGHT, TERRAIN_COLORS[Terrain.PASS] as Color,
						EDGE_LEFT_SHADE, EDGE_RIGHT_SHADE)
	for cell: Vector2i in _lit_cells:
		draw_colored_polygon(diamond(_top_center(cell)), REACH_COLOR)
	if _selected_cell != NO_CELL:
		draw_polyline(_ellipse(_top_center(_selected_cell), SELECT_RADIUS), SELECT_COLOR, SELECT_WIDTH, true)
		if not _path.is_empty():
			var points: PackedVector2Array = PackedVector2Array([_top_center(_selected_cell)])
			for cell: Vector2i in _path:
				points.append(_top_center(cell))
			draw_polyline(points, PATH_COLOR, PATH_WIDTH, true)
			# Bỏ điểm cuối trùng điểm đầu: đa giác không nhận điểm lặp.
			draw_colored_polygon(_ellipse(_top_center(_path[_path.size() - 1]), PATH_END_RADIUS).slice(0, SELECT_POINTS), PATH_COLOR)


## Sông trũng: cả ô là thành sông tối, mặt nước hạ xuống RIVER_DEPTH, cắt theo mép ô.
func _draw_river(cell: Vector2i) -> void:
	var color: Color = TERRAIN_COLORS[Terrain.RIVER] as Color
	var ground: PackedVector2Array = diamond(cell_center(cell))
	draw_colored_polygon(ground, color.darkened(RIVER_BANK_SHADE))
	var water: PackedVector2Array = diamond(cell_center(cell) + Vector2(0, RIVER_DEPTH))
	for part: PackedVector2Array in Geometry2D.intersect_polygons(water, ground):
		draw_colored_polygon(part, color)


## Hầm chông: ô phẳng màu riêng, ba mũi nhọn quanh tâm.
func _draw_spikes(cell: Vector2i) -> void:
	var center: Vector2 = cell_center(cell)
	draw_colored_polygon(diamond(center), TERRAIN_COLORS[Terrain.SPIKES] as Color)
	for offset: Vector2 in SPIKE_OFFSETS:
		var base: Vector2 = center + offset
		draw_colored_polygon(PackedVector2Array([
			base + Vector2(-SPIKE_SIZE.x / 2.0, SPIKE_SIZE.y / 2.0),
			base + Vector2(SPIKE_SIZE.x / 2.0, SPIKE_SIZE.y / 2.0),
			base + Vector2(0, -SPIKE_SIZE.y / 2.0),
		]), SPIKE_COLOR)


## Elip khép kín (vòng chọn, chấm cuối đường đi) nằm trên mặt ô nghiêng.
func _ellipse(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(SELECT_POINTS + 1):
		var angle: float = TAU * i / SELECT_POINTS
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
