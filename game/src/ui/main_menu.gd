class_name MainMenu
extends Control
## Màn hình chính (Story 4.1, FR45), dựng bằng code. Người gọi đặt size trước khi gọi setup().
## Tên game, một dòng phụ đề và nút "Chơi mới" (tác giả chốt 2026-10-28). Có file lưu thì thêm nút "Chơi tiếp" phía
## trên; file lưu hỏng thì một dòng báo nhẹ, không có "Chơi tiếp" (Story 4.3).

signal new_game_pressed
signal continue_pressed

const SUBTITLE_COLOR: Color = Color(0.85, 0.75, 0.6)
const SAVE_BROKEN_COLOR: Color = Color(1.0, 0.78, 0.72)
## Logo hiện ×LOGO_SCALE so với hình gốc 420×84.
const LOGO_SCALE: int = 2
const PLATE_PADDING: float = 20.0
const SEPARATION: int = 20
const BUTTON_SIZE: Vector2 = Vector2(240, 48)

var _buttons: VBoxContainer
var _new_game_button: Button
var _continue_button: Button
var _save_broken_label: Label
var _title_label: Label


func setup() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.size = size
	add_child(center)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", SEPARATION)
	center.add_child(box)

	# Tên game là hình logo (Story 8.6). Tắt UiStyle.ENABLED thì quay về Label chữ như trước 8.6.
	var logo: TextureRect = TextureRect.new()
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.texture = Art.tex(ScreenArt.LOGO)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.custom_minimum_size = logo.texture.get_size() * LOGO_SCALE
	logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	logo.visible = UiStyle.ENABLED
	box.add_child(logo)

	if not UiStyle.ENABLED:
		_title_label = Label.new()
		_title_label.text = tr("app.title")
		_title_label.add_theme_font_size_override("font_size", 56)
		_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(_title_label)

	# Phụ đề và nút nằm trên khung tối để đọc rõ trên nền tranh (Story 8.6, AC 3).
	var plate: PanelContainer = PanelContainer.new()
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var flat: StyleBoxFlat = StyleBoxFlat.new()
	flat.bg_color = Color(0.06, 0.05, 0.04, 0.78)
	flat.set_content_margin_all(PLATE_PADDING)
	plate.add_theme_stylebox_override("panel", UiStyle.panel(PLATE_PADDING, flat))
	box.add_child(plate)
	var inner: VBoxContainer = VBoxContainer.new()
	inner.add_theme_constant_override("separation", SEPARATION)
	plate.add_child(inner)

	var subtitle: Label = Label.new()
	subtitle.text = tr("menu.subtitle")
	subtitle.add_theme_color_override("font_color", SUBTITLE_COLOR)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inner.add_child(subtitle)

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", SEPARATION / 2)
	_buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	inner.add_child(_buttons)
	_continue_button = _add_button("menu.continue", continue_pressed)
	_continue_button.visible = false
	_new_game_button = _add_button("menu.new_game", new_game_pressed)

	_save_broken_label = Label.new()
	_save_broken_label.text = tr("menu.save_broken")
	_save_broken_label.add_theme_color_override("font_color", SAVE_BROKEN_COLOR)
	_save_broken_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_broken_label.visible = false
	inner.add_child(_save_broken_label)
	queue_redraw()


func _add_button(key: String, signal_to_emit: Signal) -> Button:
	var button: Button = Button.new()
	button.text = tr(key)
	button.custom_minimum_size = BUTTON_SIZE
	# Như nút HUD: không giữ focus, để Space/Enter ở menu không bấm nút (Story 4.1, AC5).
	button.focus_mode = Control.FOCUS_NONE
	UiStyle.apply_button(button)
	button.pressed.connect(func() -> void: signal_to_emit.emit())
	_buttons.add_child(button)
	return button


## Trạng thái file lưu (Story 4.3): can_continue hiện nút "Chơi tiếp"; broken hiện dòng báo file lưu hỏng.
func show_save(can_continue: bool, broken: bool) -> void:
	_continue_button.visible = can_continue
	_save_broken_label.visible = broken


func _draw() -> void:
	ScreenArt.draw_backdrop(self, ScreenArt.MENU_BACKGROUND, size)


## Tên game bằng chữ (Label chỉ được dựng khi tắt giao diện hình, còn bình thường là null).
func title_text() -> String:
	return tr("app.title")


func title_label() -> Label:
	return _title_label


## Nút "Chơi mới" (để test).
func new_game_button() -> Button:
	return _new_game_button


func continue_button() -> Button:
	return _continue_button


func save_broken_label() -> Label:
	return _save_broken_label
