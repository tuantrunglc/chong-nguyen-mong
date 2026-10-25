class_name ResultBanner
extends Control
## Bảng "Thắng!" / "Thua!" giữa bàn cờ khi trận kết thúc (Story 2.5), dựng bằng code. Chỉ nhận kết cục qua
## show_result, không giữ trạng thái trận. Bảng nhỏ và hơi trong suốt để vẫn nhìn thấy bàn (cú đánh cuối).
## Không nhận chuột, trừ nút "Chơi lại trận" (phát retry_pressed). Nút này bỏ khi có menu ở Story 4.2.

signal retry_pressed

const PANEL_SIZE: Vector2 = Vector2(360, 170)
const PADDING: int = 20
const SEPARATION: int = 16
const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08, 0.88)
const BORDER_COLOR: Color = Color(0.36, 0.24, 0.14)
const BORDER_WIDTH: int = 4
const WON_COLOR: Color = Color(1.0, 0.86, 0.45)
const LOST_COLOR: Color = Color(1.0, 0.62, 0.52)
const TITLE_FONT_SIZE: int = 56
## Cỡ chữ cho thông báo kết quả dài ("Thua: hết hiệp", Story 3.5).
const LONG_TITLE_FONT_SIZE: int = 38
const BUTTON_HEIGHT: float = 44.0

var _panel: PanelContainer
var _title: Label
var _retry_button: Button


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var panel: PanelContainer = PanelContainer.new()
	_panel = panel
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(BORDER_WIDTH)
	style.set_content_margin_all(PADDING)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", SEPARATION)
	panel.add_child(box)

	_title = Label.new()
	_title.theme_type_variation = &"TitleLabel"
	_title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_title)

	_retry_button = Button.new()
	_retry_button.text = tr("result.retry")
	_retry_button.focus_mode = Control.FOCUS_NONE
	_retry_button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	_retry_button.pressed.connect(func() -> void: retry_pressed.emit())
	box.add_child(_retry_button)

	# PANEL_SIZE là cỡ nhỏ nhất; chữ và nút cần nhiều chỗ hơn thì nới ra, để khung luôn bọc hết nội dung và vẫn ở
	# giữa bàn.
	_relayout()


func _relayout() -> void:
	var panel_size: Vector2 = PANEL_SIZE.max(_panel.get_combined_minimum_size()).ceil()
	_panel.size = panel_size
	size = panel_size
	position = (BoardView.AREA.get_center() - panel_size / 2.0).round()


## Hiện bảng theo pha: WON là "Thắng!", LOST là "Thua!" (hoặc "Thua: hết hiệp" nếu defeat_reason là "het_hiep"); pha khác thì ẩn bảng.
func show_result(phase: BattleState.Phase, defeat_reason: String = "") -> void:
	match phase:
		BattleState.Phase.WON:
			_title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
			_title.text = tr("result.won")
			_title.add_theme_color_override("font_color", WON_COLOR)
			_relayout()
			visible = true
		BattleState.Phase.LOST:
			if defeat_reason == "het_hiep":
				_title.add_theme_font_size_override("font_size", LONG_TITLE_FONT_SIZE)
				_title.text = tr("result.lost_round_limit")
			elif defeat_reason == "mat_lang":
				_title.add_theme_font_size_override("font_size", LONG_TITLE_FONT_SIZE)
				_title.text = tr("result.lost_morale")
			else:
				_title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
				_title.text = tr("result.lost")
			_title.add_theme_color_override("font_color", LOST_COLOR)
			_relayout()
			visible = true
		_:
			hide_result()


func hide_result() -> void:
	visible = false


func is_showing() -> bool:
	return visible


func result_text() -> String:
	return _title.text if visible else ""


## Khung thật trên màn hình (tọa độ cha), để test kiểm khung chứ không chỉ kiểm Control bọc ngoài.
func panel_rect() -> Rect2:
	return Rect2(position + _panel.position, _panel.size)


func retry_button() -> Button:
	return _retry_button
