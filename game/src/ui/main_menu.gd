class_name MainMenu
extends Control
## Màn hình chính (Story 4.1, FR45), dựng bằng code. Người gọi đặt size trước khi gọi setup().
## Tên game, một dòng phụ đề và nút "Chơi mới" (tác giả chốt 2026-10-28). Có file lưu thì thêm nút "Chơi tiếp" phía
## trên; file lưu hỏng thì một dòng báo nhẹ, không có "Chơi tiếp" (Story 4.3).

signal new_game_pressed
signal continue_pressed

const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08)
const SUBTITLE_COLOR: Color = Color(0.85, 0.75, 0.6)
const SAVE_BROKEN_COLOR: Color = Color(1.0, 0.78, 0.72)
const TITLE_FONT_SIZE: int = 56
const SEPARATION: int = 20
const BUTTON_SIZE: Vector2 = Vector2(240, 48)

var _buttons: VBoxContainer
var _new_game_button: Button
var _continue_button: Button
var _save_broken_label: Label


func setup() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.size = size
	add_child(center)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", SEPARATION)
	center.add_child(box)

	var title: Label = Label.new()
	title.text = tr("app.title")
	title.theme_type_variation = &"TitleLabel"
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = tr("menu.subtitle")
	subtitle.add_theme_color_override("font_color", SUBTITLE_COLOR)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	_buttons = VBoxContainer.new()
	_buttons.add_theme_constant_override("separation", SEPARATION / 2)
	_buttons.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(_buttons)
	_continue_button = _add_button("menu.continue", continue_pressed)
	_continue_button.visible = false
	_new_game_button = _add_button("menu.new_game", new_game_pressed)

	_save_broken_label = Label.new()
	_save_broken_label.text = tr("menu.save_broken")
	_save_broken_label.add_theme_color_override("font_color", SAVE_BROKEN_COLOR)
	_save_broken_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_save_broken_label.visible = false
	box.add_child(_save_broken_label)
	queue_redraw()


func _add_button(key: String, signal_to_emit: Signal) -> Button:
	var button: Button = Button.new()
	button.text = tr(key)
	button.custom_minimum_size = BUTTON_SIZE
	# Như nút HUD: không giữ focus, để Space/Enter ở menu không bấm nút (Story 4.1, AC5).
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void: signal_to_emit.emit())
	_buttons.add_child(button)
	return button


## Trạng thái file lưu (Story 4.3): can_continue hiện nút "Chơi tiếp"; broken hiện dòng báo file lưu hỏng.
func show_save(can_continue: bool, broken: bool) -> void:
	_continue_button.visible = can_continue
	_save_broken_label.visible = broken


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)


## Nút "Chơi mới" (để test).
func new_game_button() -> Button:
	return _new_game_button


func continue_button() -> Button:
	return _continue_button


func save_broken_label() -> Label:
	return _save_broken_label
