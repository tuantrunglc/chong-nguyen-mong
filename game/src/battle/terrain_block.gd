class_name TerrainBlock
extends Node2D
## Khối địa hình nhô lên (rừng, kho lương, làng) trên bàn nhìn chếch, vẽ bằng hình (Story 8.2), đáy hình chạm đáy ô,
## đầu hình được phép che ô phía trên. Vùng bấm và độ cao khối vẫn theo BLOCK_HEIGHT (hình học không đổi).
## Chữ ngắn trên khối chỉ hiện khi BoardView.SHOW_TERRAIN_LABELS. Ô ải là bệ thấp vẽ trên mặt đất (BoardView).
## position cao hơn tâm ô TILE_SIZE / 4: y-sort (BoardView._world) vẽ khối sau mọi quân ở hàng trên (y của chúng
## nhỏ hơn ít nhất 3 * TILE_SIZE / 4) và trước quân cùng hàng hoặc hàng dưới (lớn hơn ít nhất TILE_SIZE / 4),
## kể cả quân đứng trên bệ ô ải (nâng PASS_HEIGHT, vẫn lớn hơn).

const ORIGIN_ABOVE_CENTER: float = BoardView.TILE_SIZE / 4.0
## Hình lấn xuống dưới đáy ô (px): khoảng trong suốt ở đáy hình, để chân khối chạm đáy ô.
const SPRITE_DROP: float = 2.0

var cell: Vector2i = Vector2i.ZERO
## Terrain.*
var kind: int = Terrain.FOREST
var _height: float = 0.0


func setup(new_cell: Vector2i, new_kind: int, height: float, text: String) -> void:
	cell = new_cell
	kind = new_kind
	_height = height
	position = BoardView.cell_center(cell) - Vector2(0, ORIGIN_ABOVE_CENTER)
	queue_redraw()
	if not BoardView.SHOW_TERRAIN_LABELS:
		return
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", BoardView.TERRAIN_FONT_SIZE)
	label.add_theme_color_override("font_color", BoardView.LINE_COLOR)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(BoardView.TILE_SIZE, BoardView.TILE_SIZE / 2.0)
	label.position = Vector2(0, ORIGIN_ABOVE_CENTER - _height) - label.size / 2.0
	add_child(label)


func _draw() -> void:
	var tex: Texture2D = Art.tex(GroundArt.block_path(kind, cell))
	# Ô vuông trên mặt đất, tính từ position.
	var ground: Rect2 = BoardView.cell_rect(cell)
	ground.position -= position
	draw_texture(tex, Vector2(ground.position.x, ground.end.y - tex.get_height() + SPRITE_DROP))
