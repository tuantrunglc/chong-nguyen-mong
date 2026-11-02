class_name GroundView
extends Node2D
## Mặt đất của bàn (Story 8.2): lát bộ 16 ô cỏ–sông theo lưới lệch nửa ô, cắt gọn trong mặt bàn,
## điểm xuyết hoa cỏ lẻ và sỏi đá, hiệu ứng gợn sóng lăn tăn trên sông, rồi hầm chông.
## Là con của BoardView với show_behind_parent: vẽ trước (dưới) lưới, ô sáng, vòng chọn mà BoardView._draw vẽ.
## Chỉ vẽ theo bản chụp, không đổi trạng thái trận. Tọa độ local giống BoardView (gốc là góc trên trái ô 0,0).

const WAVE_INTERVAL: float = 0.4
const WAVE_COLOR: Color = Color(0.043, 0.541, 0.561, 0.85) # #0b8a8f
const GLIMMER_COLOR: Color = Color(0.561, 0.827, 1.0, 0.90) # #8fd3ff

var cols: int = BoardView.EMPTY_SIZE.x
var rows: int = BoardView.EMPTY_SIZE.y
var _state: BattleState = null
var _wave_time: float = 0.0
var _wave_frame: int = 0


func _init() -> void:
	show_behind_parent = true


func _process(delta: float) -> void:
	if not visible:
		return
	_wave_time += delta
	if _wave_time >= WAVE_INTERVAL:
		_wave_time = fmod(_wave_time, WAVE_INTERVAL)
		_wave_frame = (_wave_frame + 1) % 4
		queue_redraw()


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
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			var terrain: int = Terrain.PLAIN if _state == null else _state.terrain_at(cell)
			if terrain == Terrain.SPIKES:
				draw_texture(Art.tex(GroundArt.spikes_path(cell)), BoardView.cell_rect(cell).position)
			elif terrain == Terrain.PLAIN and GroundArt.has_co_le(cell):
				draw_texture(Art.tex(GroundArt.co_le_path(cell)), BoardView.cell_rect(cell).position)
			elif terrain == Terrain.RIVER:
				_draw_water_ripple(BoardView.cell_rect(cell).position, cell)


func _draw_water_ripple(origin: Vector2, cell: Vector2i) -> void:
	# Khởi tạo pha sóng lệch nhau giữa các ô để sóng cuộn tự nhiên theo dòng nước
	var f: int = posmod(_wave_frame + cell.x * 2 + cell.y * 3, 4)
	var w1_offset_x: float = float([0, 2, 4, 2][f])
	var w2_offset_x: float = float([0, -2, -4, -2][f])
	var p1: Vector2 = origin + Vector2(16.0 + w1_offset_x, 22.0)
	var p2: Vector2 = origin + Vector2(34.0 + w2_offset_x, 42.0)
	# Gợn sóng 1 (có vệt sáng lấp lánh ở giữa)
	draw_line(p1, p1 + Vector2(14.0, 0.0), WAVE_COLOR, 1.0)
	draw_line(p1 + Vector2(4.0, 0.0), p1 + Vector2(8.0, 0.0), GLIMMER_COLOR, 1.0)
	# Gợn sóng 2
	draw_line(p2, p2 + Vector2(16.0, 0.0), WAVE_COLOR, 1.0)
	draw_line(p2 + Vector2(5.0, 0.0), p2 + Vector2(10.0, 0.0), GLIMMER_COLOR, 1.0)
	# Đốm nước lấp lánh phụ ở frame chẵn
	if f % 2 == 0:
		var p3: Vector2 = origin + Vector2(24.0, 54.0)
		draw_line(p3, p3 + Vector2(6.0, 0.0), WAVE_COLOR, 1.0)
