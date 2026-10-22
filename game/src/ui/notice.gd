class_name Notice
extends Control
## Thông báo ngắn giữa bàn (Story 2.13; kiến trúc: src/ui/notice.gd): hiện một câu rồi tự mờ dần và ẩn.
## Không nhận chuột, không chặn input, không giữ trạng thái trận. Bảng nằm trên đồng quân nhưng dưới HUD.

const SHOW_SECONDS: float = 2.5
const FADE_SECONDS: float = 0.35
const FONT_SIZE: int = 20
const BOTTOM_MARGIN: float = 24.0
const PADDING: int = 14
const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08, 0.9)
const BORDER_COLOR: Color = Color(0.36, 0.24, 0.14)
const TEXT_COLOR: Color = Color(1.0, 0.95, 0.82)

var _panel: PanelContainer
var _label: Label
var _tween: Tween
var _shown: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = BoardView.viewport_size
	visible = false

	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(2)
	style.set_content_margin_all(PADDING)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_color_override("font_color", TEXT_COLOR)
	_label.theme_type_variation = &"TitleLabel"
	_panel.add_child(_label)


## Hiện câu thông báo; chuỗi rỗng là ẩn ngay. Gọi liên tiếp thì câu sau thay câu trước, không chồng bảng.
func show_text(text: String) -> void:
	if _label == null:
		return
	_label.text = text
	_shown = not text.is_empty()
	visible = _shown
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not _shown:
		return
	modulate.a = 1.0
	_place_panel()
	_tween = create_tween()
	_tween.tween_interval(SHOW_SECONDS)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_SECONDS)
	_tween.tween_callback(_hide)


func text() -> String:
	return _label.text if _label != null and visible else ""


func is_shown() -> bool:
	return _shown


## Canh bảng giữa bàn, sát đáy (không che HUD bên phải và không che thanh tiêu đề).
func _place_panel() -> void:
	_panel.reset_size()
	_panel.position = Vector2((size.x - _panel.size.x) / 2.0, size.y - BOTTOM_MARGIN - _panel.size.y)


func _hide() -> void:
	visible = false
	_shown = false
