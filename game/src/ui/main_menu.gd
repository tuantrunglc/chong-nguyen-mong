class_name MainMenu
extends Control
## Màn hình chính (Story 4.1, FR45), dựng bằng code. Người gọi đặt size trước khi gọi setup().
## Tên game, một dòng phụ đề và nút "Chơi mới" (tác giả chốt 2026-10-28). Nút "Chơi tiếp" thêm ở Story 4.3,
## nằm trên "Chơi mới" trong cùng hộp _buttons.

signal new_game_pressed

const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08)
const SUBTITLE_COLOR: Color = Color(0.85, 0.75, 0.6)
const TITLE_FONT_SIZE: int = 56
const SEPARATION: int = 20
const BUTTON_SIZE: Vector2 = Vector2(240, 48)

var _buttons: VBoxContainer
var _new_game_button: Button


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
	_new_game_button = Button.new()
	_new_game_button.text = tr("menu.new_game")
	_new_game_button.custom_minimum_size = BUTTON_SIZE
	_new_game_button.pressed.connect(func() -> void: new_game_pressed.emit())
	_buttons.add_child(_new_game_button)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)


## Nút "Chơi mới" (để test).
func new_game_button() -> Button:
	return _new_game_button
