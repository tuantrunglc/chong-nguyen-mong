class_name TerrainBlock
extends Node2D
## Khối địa hình nhô lên (rừng, kho lương, làng) trên bàn nghiêng, vẽ bằng code: mặt trên màu địa hình,
## hai mặt bên tối hơn, chữ ngắn trên mặt trên. Ô ải là bệ thấp vẽ trên mặt đất (BoardView), không phải khối.
## position nằm giữa đỉnh trên và tâm ô thoi (cao hơn tâm TILE_H / 4): y-sort (BoardView._world) vẽ khối sau
## mọi quân ở ô phía sau (y của chúng nhỏ hơn ít nhất TILE_H / 2) và trước quân cùng độ sâu hoặc gần hơn,
## kể cả quân đứng trên bệ ô ải.

const ORIGIN_ABOVE_CENTER: float = BoardView.TILE_H / 4.0
const LEFT_SHADE: float = 0.25
const RIGHT_SHADE: float = 0.45

var cell: Vector2i = Vector2i.ZERO
## Terrain.*
var kind: int = Terrain.FOREST
var _height: float = 0.0


func setup(new_cell: Vector2i, new_kind: int, height: float, text: String) -> void:
	cell = new_cell
	kind = new_kind
	_height = height
	position = BoardView.cell_center(cell) - Vector2(0, ORIGIN_ABOVE_CENTER)
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", BoardView.TERRAIN_FONT_SIZE)
	label.add_theme_color_override("font_color", BoardView.LINE_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(BoardView.TILE_W / 2.0, BoardView.TILE_H / 2.0)
	label.position = Vector2(0, ORIGIN_ABOVE_CENTER - _height) - label.size / 2.0
	add_child(label)
	queue_redraw()


func _draw() -> void:
	var color: Color = BoardView.TERRAIN_COLORS[kind] as Color
	# Đỉnh của ô thoi trên mặt đất, tính từ position.
	var corners: PackedVector2Array = BoardView.diamond(Vector2(0, ORIGIN_ABOVE_CENTER))
	BoardView.draw_raised(self, corners, _height, color, LEFT_SHADE, RIGHT_SHADE)
