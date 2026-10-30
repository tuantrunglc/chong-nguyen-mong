class_name LevelTransition
extends Control
## Màn chuyển trận (Story 4.2, FR44), dựng bằng code như MainMenu. Người gọi đặt size trước khi gọi setup().
## Thắng một trận trong chuỗi: tên trận kế, mưu kế vừa mở (mỗi mưu kế một dòng), nút "Tiếp".
## Thắng trận cuối: "Đã thắng cả chiến dịch" và nút "Về menu" (tác giả chốt 2026-10-30).

signal next_pressed
signal menu_pressed

const SUBTITLE_COLOR: Color = Color(0.85, 0.75, 0.6)
const STRATAGEM_COLOR: Color = Color(1.0, 0.86, 0.45)
const TITLE_FONT_SIZE: int = 44
const SEPARATION: int = 20
const BUTTON_SIZE: Vector2 = Vector2(240, 48)

var _heading: Label
var _title: Label
var _stratagems: VBoxContainer
var _next_button: Button
var _menu_button: Button


func setup() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.size = size
	add_child(center)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", SEPARATION)
	center.add_child(box)

	_heading = Label.new()
	_heading.text = tr("transition.next_level")
	_heading.add_theme_color_override("font_color", SUBTITLE_COLOR)
	_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_heading)

	_title = Label.new()
	_title.theme_type_variation = &"TitleLabel"
	_title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Tên trận lấy từ file trận, không phải khóa dịch.
	_title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	box.add_child(_title)

	_stratagems = VBoxContainer.new()
	box.add_child(_stratagems)

	_next_button = _add_button(box, "transition.next", next_pressed)
	_menu_button = _add_button(box, "transition.menu", menu_pressed)
	queue_redraw()


func _add_button(parent: Control, key: String, signal_to_emit: Signal) -> Button:
	var button: Button = Button.new()
	button.text = tr(key)
	button.custom_minimum_size = BUTTON_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# Như nút HUD: không giữ focus, để Space/Enter không bấm nút.
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(func() -> void: signal_to_emit.emit())
	parent.add_child(button)
	return button


## Trận kế: tên trận (khóa "ten" của file trận) và các mưu kế trận kế mở mà trận vừa thắng không có.
func show_next(level_name: String, new_stratagems: Array[int]) -> void:
	_heading.visible = true
	_title.text = level_name
	_clear_stratagems()
	for kind: int in Stratagem.in_key_order(new_stratagems):
		var line: Label = Label.new()
		line.text = tr("transition.new_stratagem") % tr("stratagem." + Stratagem.name_of(kind))
		line.add_theme_color_override("font_color", STRATAGEM_COLOR)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		line.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		_stratagems.add_child(line)
	_next_button.visible = true
	_menu_button.visible = false


## Hết chuỗi trận.
func show_campaign_end() -> void:
	_heading.visible = false
	_title.text = tr("transition.campaign_won")
	_clear_stratagems()
	_next_button.visible = false
	_menu_button.visible = true


func _clear_stratagems() -> void:
	for child: Node in _stratagems.get_children():
		_stratagems.remove_child(child)
		child.queue_free()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), MainMenu.BACKGROUND_COLOR)


## Các dòng mưu kế mới đang hiện (để test).
func stratagem_lines() -> Array[String]:
	var lines: Array[String] = []
	for child: Node in _stratagems.get_children():
		lines.append((child as Label).text)
	return lines


func next_button() -> Button:
	return _next_button


func menu_button() -> Button:
	return _menu_button
