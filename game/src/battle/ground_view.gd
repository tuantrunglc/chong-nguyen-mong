class_name GroundView
extends Node2D
## Mặt đất của bàn (Story 8.2): lát bộ 16 ô cỏ–sông theo lưới lệch nửa ô, cắt gọn trong mặt bàn, rồi hầm chông.
## Là con của BoardView với show_behind_parent: vẽ trước (dưới) lưới, ô sáng, vòng chọn mà BoardView._draw vẽ.
## Chỉ vẽ theo bản chụp, không đổi trạng thái trận. Tọa độ local giống BoardView (gốc là góc trên trái ô 0,0).

var cols: int = BoardView.EMPTY_SIZE.x
var rows: int = BoardView.EMPTY_SIZE.y
var _state: BattleState = null


func _init() -> void:
	show_behind_parent = true


## Đổi cỡ bàn (BoardView.setup gọi).
func setup(new_cols: int, new_rows: int) -> void:
	cols = new_cols
	rows = new_rows
	queue_redraw()


## Bản chụp cần vẽ; null là bàn trống toàn cỏ.
func show_state(state: BattleState) -> void:
	_state = state
	queue_redraw()


func _draw() -> void:
	var tile: int = BoardView.TILE_SIZE
	var half: int = tile / 2
	var surface: Rect2 = Rect2(0, 0, cols * tile, rows * tile)
	for vy: int in range(rows + 1):
		for vx: int in range(cols + 1):
			var m: int = 15 if _state == null else GroundArt.mask(_state, vx, vy)
			var tex: Texture2D = Art.tex(GroundArt.ground_path(m))
			# Ô ghép phủ nửa ô mỗi phía quanh điểm giao; chỉ vẽ phần trong mặt bàn.
			var dest: Rect2 = Rect2(vx * tile - half, vy * tile - half, tile, tile).intersection(surface)
			if dest.size.x <= 0.0 or dest.size.y <= 0.0:
				continue
			var src: Rect2 = Rect2(dest.position - Vector2(vx * tile - half, vy * tile - half), dest.size)
			draw_texture_rect_region(tex, dest, src)
	if _state == null:
		return
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			if _state.terrain_at(cell) == Terrain.SPIKES:
				draw_texture(Art.tex(GroundArt.spikes_path(cell)), BoardView.cell_rect(cell).position)
