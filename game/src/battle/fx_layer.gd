class_name FxLayer
extends Node2D
## Lớp hiệu ứng trên đồng quân, dưới viền mục tiêu và số thứ tự đòn (Story 8.4, NFR9).
## Mỗi hiệu ứng là một hình (hoặc vài khung) có thời lượng; `_process` chạy khi còn hiệu ứng và tắt khi rỗng (NFR1).
## Thời gian tính bằng delta với thời lượng đã chia tốc độ phát, nên tua nhanh nhanh theo. Chỉ vẽ, không đọc luật.

## Đặt false để tắt mọi hiệu ứng mà không xóa code.
const ENABLED: bool = true
## Phần đầu của thời lượng sự kiện dành cho đường bay; sau đó hình biến mất.
const TRAVEL_PORTION: float = 0.7
const POP_START_SCALE: float = 0.7
const POP_GROW: float = 0.5
const RISE_DISTANCE: float = 16.0
const FLICKER_WAVES: float = 3.0
const FLICKER_SCALE: float = 0.08

## Mỗi mục: { "paths": Array[String], "center": Vector2, "to": Vector2, "seconds": float, "age": float, "style": String }
var _items: Array[Dictionary] = []


func _ready() -> void:
	set_process(false)


func active_count() -> int:
	return _items.size()


func clear() -> void:
	_items = []
	set_process(false)
	queue_redraw()


## Một hình tĩnh với kiểu chuyển động style (STYLE_POP, STYLE_FLICKER, STYLE_RISE).
func spawn_static(path: String, center: Vector2, seconds: float, style: String) -> void:
	_add([path], center, center, seconds, style)


## Nhiều khung trải đều trong seconds.
func spawn_frames(paths: Array[String], center: Vector2, seconds: float) -> void:
	_add(paths, center, center, seconds, FxArt.STYLE_FRAMES)


## Hình bay thẳng từ from tới to trong phần đầu của seconds, rồi biến mất.
func spawn_travel(path: String, from: Vector2, to: Vector2, seconds: float) -> void:
	_add([path], from, to, seconds * TRAVEL_PORTION, FxArt.STYLE_TRAVEL)


func _add(paths: Array[String], center: Vector2, to: Vector2, seconds: float, style: String) -> void:
	if not ENABLED or paths.is_empty():
		return
	_items.append({"paths": paths, "center": center, "to": to, "seconds": maxf(seconds, 0.001), "age": 0.0, "style": style})
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var keep: Array[Dictionary] = []
	for item: Dictionary in _items:
		item["age"] = (item["age"] as float) + delta
		if (item["age"] as float) < (item["seconds"] as float):
			keep.append(item)
	_items = keep
	if _items.is_empty():
		set_process(false)
	queue_redraw()


func _draw() -> void:
	for item: Dictionary in _items:
		var progress: float = clampf((item["age"] as float) / (item["seconds"] as float), 0.0, 1.0)
		var paths: Array[String] = item["paths"] as Array[String]
		var center: Vector2 = item["center"] as Vector2
		var scale_factor: float = 1.0
		var alpha: float = 1.0
		var index: int = 0
		match item["style"] as String:
			FxArt.STYLE_POP:
				scale_factor = POP_START_SCALE + POP_GROW * progress
				alpha = 1.0 - progress * progress
			FxArt.STYLE_FLICKER:
				scale_factor = 1.0 + FLICKER_SCALE * sin(progress * TAU * FLICKER_WAVES)
				alpha = 1.0 if progress < 0.5 else 2.0 * (1.0 - progress)
			FxArt.STYLE_RISE:
				center += Vector2(0.0, -RISE_DISTANCE * progress)
				alpha = 1.0 - progress
			FxArt.STYLE_FRAMES:
				index = mini(int(progress * paths.size()), paths.size() - 1)
			FxArt.STYLE_TRAVEL:
				center = center.lerp(item["to"] as Vector2, progress)
		var texture: Texture2D = Art.tex(paths[index])
		var size: Vector2 = texture.get_size() * scale_factor
		draw_texture_rect(texture, Rect2(center - size / 2.0, size), false, Color(1.0, 1.0, 1.0, alpha))
