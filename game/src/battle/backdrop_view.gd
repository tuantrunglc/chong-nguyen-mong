class_name BackdropView
extends Node2D
## Nền rừng quanh bàn (Story 8.2): lát kín cả cửa sổ bằng các ô rừng rậm 64 px, dưới mặt đất của bàn.
## Là con của BoardView (show_behind_parent). BoardView có position và scale riêng, nên vùng cần lát tính từ
## tọa độ màn hình về tọa độ local. Vẽ lại khi BoardView.setup đổi cỡ bàn (đổi position), không vẽ mỗi lần rê chuột.

## Làm dịu và tối viền rừng 30% để bàn cờ nổi bật lên làm trung tâm thị giác.
const BACKDROP_MODULATE: Color = Color(0.70, 0.70, 0.70, 1.0)
const SHADOW_COLOR_SOFT: Color = Color(0.08, 0.06, 0.10, 0.35)
const SHADOW_COLOR_HARD: Color = Color(0.08, 0.06, 0.10, 0.45)


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
			draw_texture(Art.tex(GroundArt.backdrop_path(cell)), Vector2(cell) * tile, BACKDROP_MODULATE)

	# Đổ bóng nổi khối (drop shadow) của sa bàn lên nền rừng (hướng đông nam theo ánh sáng từ trên trái)
	var parent: BoardView = get_parent() as BoardView
	if parent != null and parent.cols > 0 and parent.rows > 0:
		var w: float = float(parent.cols * BoardView.TILE_SIZE)
		var h: float = float(parent.rows * BoardView.TILE_SIZE)
		var frame_rect: Rect2 = Rect2(-16.0, -16.0, w + 32.0, h + 32.0)
		var soft_rect: Rect2 = Rect2(frame_rect.position + Vector2(8.0, 10.0), frame_rect.size)
		var hard_rect: Rect2 = Rect2(frame_rect.position + Vector2(4.0, 5.0), frame_rect.size)
		draw_rect(soft_rect, SHADOW_COLOR_SOFT)
		draw_rect(hard_rect, SHADOW_COLOR_HARD)

	# Viền tối mờ 4 góc màn hình (Vignette) để tập trung ánh nhìn vào sa bàn chiến trận
	_draw_vignette(screen_rect())


func _draw_vignette(area: Rect2) -> void:
	var edge_v: float = 90.0
	var edge_h: float = 110.0
	var c_dark: Color = Color(0.04, 0.03, 0.05, 0.55)
	var c_clear: Color = Color(0.04, 0.03, 0.05, 0.0)

	# Mép trên
	draw_polygon(PackedVector2Array([
		area.position,
		Vector2(area.end.x, area.position.y),
		Vector2(area.end.x, area.position.y + edge_v),
		Vector2(area.position.x, area.position.y + edge_v)
	]), PackedColorArray([c_dark, c_dark, c_clear, c_clear]))

	# Mép dưới
	draw_polygon(PackedVector2Array([
		Vector2(area.position.x, area.end.y - edge_v),
		Vector2(area.end.x, area.end.y - edge_v),
		area.end,
		Vector2(area.position.x, area.end.y)
	]), PackedColorArray([c_clear, c_clear, c_dark, c_dark]))

	# Mép trái
	draw_polygon(PackedVector2Array([
		area.position,
		Vector2(area.position.x + edge_h, area.position.y),
		Vector2(area.position.x + edge_h, area.end.y),
		Vector2(area.position.x, area.end.y)
	]), PackedColorArray([c_dark, c_clear, c_clear, c_dark]))

	# Mép phải
	draw_polygon(PackedVector2Array([
		Vector2(area.end.x - edge_h, area.position.y),
		Vector2(area.end.x, area.position.y),
		area.end,
		Vector2(area.end.x - edge_h, area.end.y)
	]), PackedColorArray([c_clear, c_dark, c_dark, c_clear]))
