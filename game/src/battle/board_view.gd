class_name BoardView
extends Node2D
## Vẽ bàn cờ bằng code, đặt giữa khung 1280×720: màu từng ô, chữ ngắn của địa hình, đồng quân.
## Chỉ vẽ theo bản chụp (show_state); null thì về bàn trống.

const CELL_SIZE: int = 88
## Đọc từ project.godot để chỉ có một nơi khai báo kích thước màn hình.
static var viewport_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width") as int,
	ProjectSettings.get_setting("display/window/size/viewport_height") as int
)
const CELL_COLOR: Color = Color(0.93, 0.87, 0.73)
const LINE_COLOR: Color = Color(0.36, 0.24, 0.14)
const LINE_WIDTH: float = 2.0
const BORDER_WIDTH: float = 4.0

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
## Khóa dịch của chữ ngắn ở góc dưới trái ô. Đất trống không có chữ.
const TERRAIN_KEYS: Dictionary = {
	Terrain.RIVER: "terrain.river",
	Terrain.FOREST: "terrain.forest",
	Terrain.SPIKES: "terrain.spikes",
	Terrain.GRANARY: "terrain.granary",
	Terrain.VILLAGE: "terrain.village",
	Terrain.PASS: "terrain.pass",
}
const TERRAIN_FONT_SIZE: int = 12
const TERRAIN_MARGIN: int = 4

var cols: int = 7
var rows: int = 7

## Bản chụp đang vẽ; null là bàn trống.
var _state: BattleState = null
var _terrain_labels: Node2D
var _units: Node2D
## id quân -> UnitToken
var _tokens: Dictionary = {}


## Tâm ô, tính trong tọa độ của BoardView.
static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell) * CELL_SIZE + Vector2.ONE * CELL_SIZE / 2.0


func setup(new_cols: int = 7, new_rows: int = 7) -> void:
	cols = new_cols
	rows = new_rows
	var board_size: Vector2 = Vector2(cols * CELL_SIZE, rows * CELL_SIZE)
	position = (viewport_size - board_size) / 2.0
	queue_redraw()


func _ready() -> void:
	# Thứ tự con: chữ địa hình, rồi đồng quân. Overlay F1 do main.gd thêm vào sau cùng.
	_terrain_labels = Node2D.new()
	add_child(_terrain_labels)
	_units = Node2D.new()
	add_child(_units)
	setup(cols, rows)


func show_state(state: BattleState) -> void:
	_state = state
	if state != null:
		setup(state.size.x, state.size.y)
	_rebuild_terrain_labels()
	_sync_tokens()
	queue_redraw()


## Đồng quân đang hiện, theo id.
func tokens() -> Dictionary:
	return _tokens


func _rebuild_terrain_labels() -> void:
	for child: Node in _terrain_labels.get_children():
		child.queue_free()
	if _state == null:
		return
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			var kind: int = _state.terrain_at(cell)
			if not TERRAIN_KEYS.has(kind):
				continue
			var label: Label = Label.new()
			label.text = tr(TERRAIN_KEYS[kind] as String)
			label.add_theme_font_size_override("font_size", TERRAIN_FONT_SIZE)
			label.add_theme_color_override("font_color", LINE_COLOR)
			label.size = Vector2(CELL_SIZE - TERRAIN_MARGIN * 2, TERRAIN_FONT_SIZE * 2)
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.position = Vector2(cell) * CELL_SIZE \
				+ Vector2(TERRAIN_MARGIN, CELL_SIZE - TERRAIN_MARGIN - label.size.y)
			_terrain_labels.add_child(label)


## Thêm đồng cho quân mới, bỏ đồng của quân không còn, cập nhật đồng còn lại.
func _sync_tokens() -> void:
	var alive: Dictionary = {}
	if _state != null:
		for unit: Unit in _state.units:
			alive[unit.id] = true
			if _tokens.has(unit.id):
				(_tokens[unit.id] as UnitToken).update(unit)
				continue
			var token: UnitToken = UnitToken.new()
			token.setup(unit)
			_units.add_child(token)
			_tokens[unit.id] = token
	for id: int in _tokens.keys():
		if not alive.has(id):
			(_tokens[id] as UnitToken).queue_free()
			_tokens.erase(id)


func _draw() -> void:
	var board_size: Vector2 = Vector2(cols * CELL_SIZE, rows * CELL_SIZE)
	draw_rect(Rect2(Vector2.ZERO, board_size), CELL_COLOR)
	if _state != null:
		for r: int in range(rows):
			for c: int in range(cols):
				var kind: int = _state.terrain_at(Vector2i(c, r))
				if kind != Terrain.PLAIN:
					draw_rect(Rect2(Vector2(c, r) * CELL_SIZE, Vector2.ONE * CELL_SIZE), TERRAIN_COLORS[kind] as Color)
	for c: int in range(1, cols):
		var x: float = c * CELL_SIZE
		draw_line(Vector2(x, 0), Vector2(x, board_size.y), LINE_COLOR, LINE_WIDTH)
	for r: int in range(1, rows):
		var y: float = r * CELL_SIZE
		draw_line(Vector2(0, y), Vector2(board_size.x, y), LINE_COLOR, LINE_WIDTH)
	draw_rect(Rect2(Vector2.ZERO, board_size), LINE_COLOR, false, BORDER_WIDTH)
