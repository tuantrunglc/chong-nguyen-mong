class_name Hud
extends Control
## Bảng bên phải bàn cờ, dựng bằng code: số hiệp, nút Hủy, nút Kết thúc lượt, dòng nhắc. Ẩn khi không có trận.
## Nút không nhận focus: nếu không, bấm nút bằng chuột rồi gõ Space thì ui_accept bấm lại nút đó.

signal undo_pressed
signal end_turn_pressed

## Góc trên trái và bề rộng: bên phải bàn cờ (bàn nằm trong BoardView.AREA, x 16–956).
const PANEL_POSITION: Vector2 = Vector2(972, 52)
const PANEL_WIDTH: float = 260.0
const SEPARATION: int = 12
const BUTTON_HEIGHT: float = 44.0
## Dòng báo pha ("Lượt của bạn" / "Quân Nguyên đang ra đòn"), nhỏ hơn số hiệp.
const PHASE_FONT_SIZE: int = 17

var _round_label: Label
## Dòng pha, luôn hiện khi đang chơi (Story 2.11, AC 4).
var _phase_label: Label
var _undo_button: Button
var _end_turn_button: Button
## Dòng nhắc dưới các nút ("Bấm lần nữa để đánh"); rỗng thì ẩn.
var _hint_label: Label


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

	_phase_label = Label.new()
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phase_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_phase_label.visible = false
	box.add_child(_phase_label)

	_undo_button = _button(tr("hud.undo"), box)
	_undo_button.pressed.connect(func() -> void: undo_pressed.emit())
	_end_turn_button = _button(tr("hud.end_turn"), box)
	_end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())
	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.visible = false
	box.add_child(_hint_label)


## Hiện bảng với số hiệp; nút Hủy mờ khi không có gì để hủy. Hết trận (over) thì cả hai nút đều mờ.
func show_turn(round_number: int, can_undo: bool, over: bool = false) -> void:
	_round_label.text = tr("hud.round") % round_number
	_undo_button.disabled = over or not can_undo
	_end_turn_button.disabled = over
	visible = true
	# Hết trận thì bảng Thắng/Thua là thứ duy nhất cần đọc.
	if over:
		hide_phase()


## Dòng báo pha (Story 2.11, AC 4). `enemy_turn` true khi đang phát hoạt ảnh của quân Nguyên.
func show_phase(enemy_turn: bool) -> void:
	_phase_label.text = tr("hud.phase.enemy") if enemy_turn else tr("hud.phase.player")
	_phase_label.visible = true


func hide_phase() -> void:
	_phase_label.visible = false
	_phase_label.text = ""


## Dòng pha đang hiện (để test); rỗng là đang ẩn.
func phase_text() -> String:
	return _phase_label.text if _phase_label.visible else ""


## Dòng nhắc; chuỗi rỗng là ẩn.
func show_hint(text: String) -> void:
	_hint_label.text = text
	_hint_label.visible = not text.is_empty()


func hint_text() -> String:
	return _hint_label.text if _hint_label.visible else ""


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
