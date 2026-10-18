class_name ErrorScreen
extends Control
## Màn hình lỗi dữ liệu, dựng bằng code. Người gọi đặt position và size trước khi gọi setup().
## Bật dev: liệt kê mọi lỗi (cuộn được). Không bật dev: một câu ngắn, chi tiết chỉ nằm trong log.
## Luôn có nút "Về menu"; bấm thì phát back_pressed.

signal back_pressed

const PADDING: int = 24
const SEPARATION: int = 16
const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08)
const BORDER_COLOR: Color = Color(0.36, 0.24, 0.14)
const BORDER_WIDTH: float = 4.0
const ERROR_COLOR: Color = Color(1.0, 0.78, 0.72)

var _button: Button


func setup(errors: Array[String], dev: bool) -> void:
	var box: VBoxContainer = VBoxContainer.new()
	box.position = Vector2(PADDING, PADDING)
	box.size = size - Vector2(PADDING * 2, PADDING * 2)
	box.add_theme_constant_override("separation", SEPARATION)
	add_child(box)

	var title: Label = Label.new()
	title.text = tr("error.data_title")
	title.theme_type_variation = &"TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	if dev:
		var scroll: ScrollContainer = ScrollContainer.new()
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		box.add_child(scroll)
		var list: VBoxContainer = VBoxContainer.new()
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)
		for message: String in errors:
			list.add_child(_wrapped_label(message, ERROR_COLOR))
	else:
		var short: Label = _wrapped_label(tr("error.data_short"), Color.WHITE)
		short.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		short.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_child(short)

	_button = Button.new()
	_button.text = tr("error.back_to_menu")
	_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_button.pressed.connect(_on_button_pressed)
	box.add_child(_button)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	draw_rect(Rect2(Vector2.ZERO, size), BORDER_COLOR, false, BORDER_WIDTH)


func _wrapped_label(text: String, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", color)
	# Câu lỗi là chi tiết kỹ thuật, không đi qua bản dịch (story 1.1, Task 4.3).
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return label


func _on_button_pressed() -> void:
	back_pressed.emit()
