class_name FpsOverlay
extends CanvasLayer
## Bộ đếm FPS (chỉ khi bật dev, Story 4.7): "FPS 60 (thấp nhất 52)" ở góc dưới trái, trên mọi màn.
## "Thấp nhất" là min các mẫu trong WINDOW_SECONDS gần nhất, để thấy khung hình giật chứ không chỉ số trung bình.
## F4 xóa mẫu cũ để đo lại từ đầu. Mỗi LOG_SECONDS ghi một dòng [INFO][hieu_nang] cho người đọc log.
## Không nhận chuột; main.gd chỉ dựng node này khi bật dev.

const LAYER_INDEX: int = 100
const WINDOW_SECONDS: float = 5.0
const SAMPLE_SECONDS: float = 0.25
const REFRESH_SECONDS: float = 0.5
const LOG_SECONDS: float = 5.0
const MARGIN: Vector2 = Vector2(8, 28)
const FONT_SIZE: int = 14
const TEXT_COLOR: Color = Color(0.7, 1.0, 0.7)
const BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 0.6)

## Mẫu (giây, fps), cũ nhất trước.
var _samples: Array[Vector2] = []
var _label: Label = null
var _since_sample: float = 0.0
var _since_refresh: float = 0.0
var _since_log: float = 0.0


func _init() -> void:
	layer = LAYER_INDEX


func _ready() -> void:
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_color_override("font_color", TEXT_COLOR)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.set_content_margin_all(3)
	_label.add_theme_stylebox_override("normal", style)
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = MARGIN.x
	_label.offset_top = -MARGIN.y
	add_child(_label)
	_refresh(Time.get_ticks_msec() / 1000.0)


func _process(delta: float) -> void:
	_since_sample += delta
	_since_refresh += delta
	_since_log += delta
	var now: float = Time.get_ticks_msec() / 1000.0
	if _since_sample >= SAMPLE_SECONDS:
		_since_sample = 0.0
		record(now, int(Engine.get_frames_per_second()))
	if _since_refresh >= REFRESH_SECONDS:
		_since_refresh = 0.0
		_refresh(now)
	if _since_log >= LOG_SECONDS:
		_since_log = 0.0
		Log.info("hieu_nang", text(now))


## Thêm một mẫu và bỏ các mẫu đã quá cửa sổ.
func record(now: float, fps: int) -> void:
	_samples.append(Vector2(now, fps))
	while not _samples.is_empty() and _samples[0].x < now - WINDOW_SECONDS:
		_samples.remove_at(0)


## F4: quên mọi mẫu cũ.
func reset() -> void:
	_samples.clear()
	_since_sample = 0.0


## Chữ đang hiện: mẫu mới nhất và min trong cửa sổ; chưa có mẫu thì lấy FPS tức thời.
func text(now: float) -> String:
	var current: int = int(_samples[_samples.size() - 1].y) if not _samples.is_empty() \
		else int(Engine.get_frames_per_second())
	return format_text(current, window_min(_samples, now, WINDOW_SECONDS, current))


static func format_text(fps: int, low: int) -> String:
	var template: String = TranslationServer.translate("dev.fps")
	# Khóa chưa dịch thì tr() trả lại chính khóa: không dùng `%` trên đó (ném lỗi runtime).
	if template.count("%d") != 2:
		return "FPS %d (min %d)" % [fps, low]
	return template % [fps, low]


## Min fps của các mẫu có thời điểm trong [now - window, now]; không có mẫu nào thì trả fallback.
static func window_min(samples: Array[Vector2], now: float, window: float, fallback: int = 0) -> int:
	var low: int = -1
	for s: Vector2 in samples:
		if s.x < now - window:
			continue
		if low < 0 or int(s.y) < low:
			low = int(s.y)
	return fallback if low < 0 else low


func _refresh(now: float) -> void:
	_label.text = text(now)
