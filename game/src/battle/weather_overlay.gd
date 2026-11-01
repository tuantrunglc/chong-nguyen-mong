class_name WeatherOverlay
extends Node2D
## Hiệu ứng môi trường thiên nhiên (lá bay nhẹ và sương mù rừng lững lờ) giúp màn hình trận chiến sống động (Story 8.4+).
## Không chặn chuột (Node2D thuần), không che ô đỏ báo đòn (alpha rất mỏng, NFR9), chạy ổn định 60 FPS (NFR1).

const VIEW_SIZE: Vector2 = Vector2(1280, 720)
const LEAF_COUNT: int = 16
const MIST_COUNT: int = 3

## Màu lá chuẩn bảng màu Resurrect 64
const LEAF_COLORS: Array[Color] = [
	Color(0.976, 0.761, 0.169, 0.85), # #f9c22b vàng lá thu
	Color(0.404, 0.400, 0.200, 0.80), # #676633 xanh lá trúc
	Color(0.804, 0.408, 0.239, 0.85), # #cd683d vàng cam khô
	Color(0.682, 0.137, 0.204, 0.75), # #ae2334 lá đỏ sẫm
]

var _leaves: Array[Dictionary] = []
var _mists: Array[Dictionary] = []
var _time: float = 0.0


func _init() -> void:
	# Khởi tạo tất định (không dùng randi/randf để giữ tính lặp lại cho test)
	for i: int in range(LEAF_COUNT):
		var init_x: float = float(posmod(i * 137 + 43, int(VIEW_SIZE.x)))
		var init_y: float = float(posmod(i * 97 + 19, int(VIEW_SIZE.y)))
		var spd_x: float = 25.0 + float(posmod(i * 17, 20))
		var spd_y: float = 18.0 + float(posmod(i * 13, 15))
		var sz: float = 2.0 if (i % 3 != 0) else 3.0
		_leaves.append({
			"pos": Vector2(init_x, init_y),
			"speed": Vector2(spd_x, spd_y),
			"phase": float(i) * 0.4,
			"color": LEAF_COLORS[i % LEAF_COLORS.size()],
			"size": Vector2(sz, sz),
		})

	# 3 dải sương mù rừng (Ambient Mist) mờ ảo trôi ngang màn hình
	for i: int in range(MIST_COUNT):
		var my: float = 80.0 + float(i) * 200.0
		var mx: float = float(posmod(i * 350 - 150, int(VIEW_SIZE.x)))
		_mists.append({
			"x": mx,
			"y": my,
			"speed": 8.0 + float(i) * 4.0,
			"width": 380.0 + float(i) * 60.0,
			"height": 75.0 + float(i) * 20.0,
			"alpha": 0.035 + float(i) * 0.015,
		})


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	# Di chuyển các phiến lá
	for leaf: Dictionary in _leaves:
		var pos: Vector2 = leaf["pos"]
		var speed: Vector2 = leaf["speed"]
		var phase: float = leaf["phase"]
		# Lắc lư hình sin mô phỏng chao liệng trong gió
		var sway: float = sin(_time * 2.2 + phase) * 16.0
		pos.x += (speed.x + sway) * delta
		pos.y += speed.y * delta
		# Bay ra khỏi màn hình thì cuốn lại từ trên hoặc trái
		if pos.x > VIEW_SIZE.x + 10.0:
			pos.x = -10.0
			pos.y = float(posmod(int(pos.y + 113.0), int(VIEW_SIZE.y)))
		if pos.y > VIEW_SIZE.y + 10.0:
			pos.y = -10.0
			pos.x = float(posmod(int(pos.x + 89.0), int(VIEW_SIZE.x)))
		leaf["pos"] = pos

	# Di chuyển các dải sương mù
	for mist: Dictionary in _mists:
		mist["x"] += mist["speed"] * delta
		if mist["x"] > VIEW_SIZE.x + 50.0:
			mist["x"] = -mist["width"] - 20.0

	queue_redraw()


func _draw() -> void:
	# 1. Vẽ các dải sương mù mờ ảo (màu tím tro #7f708a với alpha cực nhẹ 0.03..0.065)
	for mist: Dictionary in _mists:
		var rect: Rect2 = Rect2(mist["x"], mist["y"], mist["width"], mist["height"])
		var col: Color = Color(0.498, 0.439, 0.541, mist["alpha"])
		draw_rect(rect, col)

	# 2. Vẽ các phiến lá pixel nhỏ bay trong gió
	for leaf: Dictionary in _leaves:
		var pos: Vector2 = leaf["pos"]
		var sz: Vector2 = leaf["size"]
		var col: Color = leaf["color"]
		draw_rect(Rect2(pos, sz), col)
