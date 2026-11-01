class_name BackdropView
extends Node2D
## Nền rừng quanh bàn (Story 8.2): lát kín cả cửa sổ bằng các ô rừng rậm 64 px, dưới mặt đất của bàn.
## Là con của BoardView (show_behind_parent). BoardView có position và scale riêng, nên vùng cần lát tính từ
## tọa độ màn hình về tọa độ local. Vẽ lại khi BoardView.setup đổi cỡ bàn (đổi position), không vẽ mỗi lần rê chuột.


func _init() -> void:
	show_behind_parent = true


## Vùng cửa sổ trong tọa độ local của BoardView (cha). Cha không phải Node2D thì coi như chưa đặt vị trí.
func screen_rect() -> Rect2:
	var parent: Node2D = get_parent() as Node2D
	var offset: Vector2 = Vector2.ZERO if parent == null else parent.position
	var factor: Vector2 = Vector2.ONE if parent == null else parent.scale
	return Rect2(-offset / factor, BoardView.viewport_size / factor)


## Khoảng ô lát (chỉ số ô 64 px, đầu gồm, cuối không gồm) phủ kín screen_rect().
func tile_range() -> Rect2i:
	var tile: float = float(BoardView.TILE_SIZE)
	var area: Rect2 = screen_rect()
	var first: Vector2i = Vector2i(floori(area.position.x / tile), floori(area.position.y / tile))
	var last: Vector2i = Vector2i(ceili(area.end.x / tile), ceili(area.end.y / tile))
	return Rect2i(first, last - first)


func _draw() -> void:
	var tile: float = float(BoardView.TILE_SIZE)
	var range: Rect2i = tile_range()
	var first: Vector2i = range.position
	var last: Vector2i = range.end
	for ty: int in range(first.y, last.y):
		for tx: int in range(first.x, last.x):
			var cell: Vector2i = Vector2i(tx, ty)
			draw_texture(Art.tex(GroundArt.backdrop_path(cell)), Vector2(cell) * tile)
