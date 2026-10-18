class_name Hud
extends Control
## Bảng bên phải bàn cờ, dựng bằng code: số hiệp, nút Hủy, nút Kết thúc lượt. Ẩn khi không có trận.
## Nút không nhận focus: nếu không, bấm nút bằng chuột rồi gõ Space thì ui_accept bấm lại nút đó.

signal undo_pressed
signal end_turn_pressed

## Góc trên trái và bề rộng: bên phải bàn cờ (bàn nghiêng nằm trong BoardView.AREA, x 16–956).
const PANEL_POSITION: Vector2 = Vector2(972, 52)
const PANEL_WIDTH: float = 260.0
const SEPARATION: int = 12
const BUTTON_HEIGHT: float = 44.0

var _round_label: Label
var _undo_button: Button
var _end_turn_button: Button


func _ready() -> void:
	position = PANEL_POSITION
	size = Vector2(PANEL_WIDTH, 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var box: VBoxContainer = VBoxContainer.new()
	box.size = Vector2(PANEL_WIDTH, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", SEPARATION)
	add_child(box)

	_round_label = Label.new()
	_round_label.theme_type_variation = &"TitleLabel"
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_round_label)

	_undo_button = _button(tr("hud.undo"), box)
	_undo_button.pressed.connect(func() -> void: undo_pressed.emit())
	_end_turn_button = _button(tr("hud.end_turn"), box)
	_end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())


## Hiện bảng với số hiệp; nút Hủy mờ khi không có gì để hủy.
func show_turn(round_number: int, can_undo: bool) -> void:
	_round_label.text = tr("hud.round") % round_number
	_undo_button.disabled = not can_undo
	visible = true


func round_text() -> String:
	return _round_label.text


func undo_button() -> Button:
	return _undo_button


func end_turn_button() -> Button:
	return _end_turn_button


func _button(text: String, box: VBoxContainer) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	box.add_child(button)
	return button
