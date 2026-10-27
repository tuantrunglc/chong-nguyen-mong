class_name Hud
extends Control
## Bảng bên phải bàn cờ, dựng bằng code: số hiệp, nút Hủy, nút Chơi lại (kèm số lần còn lại), nút mưu kế (chỉ mưu kế
## trận mở, Story 3.12), nút Kết thúc lượt, dòng nhắc. Ẩn khi không có trận.
## Nút không nhận focus: nếu không, bấm nút bằng chuột rồi gõ Space thì ui_accept bấm lại nút đó.

signal undo_pressed
signal replay_pressed
signal end_turn_pressed
## Bấm nút mưu kế kind (Stratagem.Kind).
signal stratagem_pressed(kind: int)

## Góc trên trái và bề rộng: bên phải bàn cờ (bàn nằm trong BoardView.AREA, x 16–956).
const PANEL_POSITION: Vector2 = Vector2(972, 52)
const PANEL_WIDTH: float = 260.0
const SEPARATION: int = 12
const BUTTON_HEIGHT: float = 44.0
## Màu chữ nổi bật cho hiệp cuối cùng của trận có giới hạn hiệp (Story 3.5).
const FINAL_ROUND_COLOR: Color = Color(1.0, 0.42, 0.35)
## Dòng báo pha ("Lượt của bạn" / "Quân Nguyên đang ra đòn"), nhỏ hơn số hiệp.
const PHASE_FONT_SIZE: int = 17

var _round_label: Label
## Dòng Lòng dân (Story 3.7); ẩn khi trận không có làng.
var _morale_label: Label
## Dòng pha, luôn hiện khi đang chơi (Story 2.11, AC 4).
var _phase_label: Label
var _undo_button: Button
var _replay_button: Button
## Nhãn cạnh nút Chơi lại: "Còn 1 lần" / "Đã dùng" (Story 3.2).
var _replay_label: Label
var _end_turn_button: Button
## Chỗ đặt nút mưu kế (giữa Chơi lại và Kết thúc lượt); Stratagem.Kind -> Button của mưu kế trận mở.
var _stratagem_box: VBoxContainer
var _stratagem_buttons: Dictionary = {}
var _stratagems_used: Array[int] = []
## Dòng nhắc dưới các nút ("Bấm lần nữa để đánh"); rỗng thì ẩn.
var _hint_label: Label
## Trạng thái để tính lại nút khi khóa/mở (Story 2.11: đang phát hoạt ảnh thì không bấm được).
var _can_undo: bool = false
var _can_replay: bool = false
var _over: bool = false
var _locked: bool = false


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

	_morale_label = Label.new()
	_morale_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_morale_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_morale_label.visible = false
	box.add_child(_morale_label)

	_phase_label = Label.new()
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phase_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_phase_label.visible = false
	box.add_child(_phase_label)

	_undo_button = _button(tr("hud.undo"), box)
	_undo_button.pressed.connect(func() -> void: undo_pressed.emit())
	_replay_button = _button(tr("hud.replay"), box)
	_replay_button.pressed.connect(func() -> void: replay_pressed.emit())
	_replay_label = Label.new()
	_replay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_replay_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	box.add_child(_replay_label)
	_stratagem_box = VBoxContainer.new()
	_stratagem_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stratagem_box.add_theme_constant_override("separation", SEPARATION)
	box.add_child(_stratagem_box)
	_end_turn_button = _button(tr("hud.end_turn"), box)
	_end_turn_button.pressed.connect(func() -> void: end_turn_pressed.emit())
	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.visible = false
	box.add_child(_hint_label)


## Hiện bảng với số hiệp; nút Hủy mờ khi không có gì để hủy, nút Chơi lại mờ khi đã dùng/không chơi lại được.
## Hết trận (over) thì mọi nút đều mờ và ẩn số lần chơi lại.
## Có giới hạn hiệp (max_rounds > 0) thì hiện "Hiệp X/Y"; hiệp cuối đổi màu nổi bật (Story 3.5).
## Có làng (max_morale > 0) thì hiện "Lòng dân: X/Y" (Story 3.7).
func show_turn(round_number: int, can_undo: bool, can_replay: bool, replay_left: int, over: bool = false,
		max_rounds: int = 0, morale: int = 0, max_morale: int = 0) -> void:
	if max_rounds > 0:
		_round_label.text = tr("hud.round_limit") % [round_number, max_rounds]
		if round_number >= max_rounds and not over:
			_round_label.add_theme_color_override("font_color", FINAL_ROUND_COLOR)
		else:
			_round_label.remove_theme_color_override("font_color")
	else:
		_round_label.text = tr("hud.round") % round_number
		_round_label.remove_theme_color_override("font_color")
	if max_morale > 0:
		_morale_label.text = tr("hud.morale") % [morale, max_morale]
		_morale_label.visible = true
	else:
		_morale_label.visible = false
	_can_undo = can_undo
	_can_replay = can_replay
	_over = over
	# Giữ nhãn luôn chiếm chỗ để bảng không nhảy khi hết trận; hết trận thì để trống.
	_replay_label.text = "" if over else (tr("hud.replay.used") if replay_left <= 0 else tr("hud.replay.left") % replay_left)
	_apply_disabled()
	visible = true
	# Hết trận thì bảng Thắng/Thua là thứ duy nhất cần đọc.
	if over:
		hide_phase()


## Nút mưu kế (Story 3.12): một nút cho mỗi mưu kế trận mở (mưu kế khóa thì không có nút), xếp theo thứ tự phím
## (Stratagem.SLOTS); đã dùng thì mờ và ghi "đã dùng". Dựng lại nút chỉ khi danh sách mưu kế mở đổi (trận mới).
func show_stratagems(open_kinds: Array[int], used: Array[int]) -> void:
	var open: Array[int] = Stratagem.in_key_order(open_kinds)
	if open != _stratagem_kinds():
		for button: Button in _stratagem_buttons.values():
			button.queue_free()
		_stratagem_buttons.clear()
		for kind: int in open:
			var button: Button = _button("", _stratagem_box)
			button.pressed.connect(func() -> void: stratagem_pressed.emit(kind))
			_stratagem_buttons[kind] = button
	_stratagem_box.visible = not open.is_empty()
	_stratagems_used = used.duplicate()
	for kind: int in _stratagem_buttons:
		var key: String = "stratagem." + Stratagem.name_of(kind)
		var button: Button = _stratagem_buttons[kind] as Button
		button.text = tr("hud.stratagem.used") % tr(key) if used.has(kind) else tr("hud." + key)
	_apply_disabled()


func _stratagem_kinds() -> Array[int]:
	var kinds: Array[int] = []
	for kind: int in _stratagem_buttons:
		kinds.append(kind)
	return kinds


## Nút của mưu kế kind; null nếu trận không mở mưu kế đó (để test).
func stratagem_button(kind: int) -> Button:
	return _stratagem_buttons.get(kind) as Button


## Khóa nút khi đang phát hoạt ảnh: nút trông mờ đúng như lúc không bấm được (Story 2.11, AC 3).
func set_locked(locked: bool) -> void:
	_locked = locked
	_apply_disabled()


func _apply_disabled() -> void:
	_undo_button.disabled = _over or not _can_undo or _locked
	_replay_button.disabled = _over or not _can_replay or _locked
	_end_turn_button.disabled = _over or _locked
	for kind: int in _stratagem_buttons:
		(_stratagem_buttons[kind] as Button).disabled = _over or _locked or _stratagems_used.has(kind)


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


func morale_text() -> String:
	return _morale_label.text if _morale_label.visible else ""


## Số hiệp đang đổi màu nổi bật (để test hiệp cuối, Story 3.5).
func round_has_highlight() -> bool:
	return _round_label.has_theme_color_override("font_color")


func undo_button() -> Button:
	return _undo_button


func replay_button() -> Button:
	return _replay_button


func replay_label_text() -> String:
	return _replay_label.text


func end_turn_button() -> Button:
	return _end_turn_button


func _button(text: String, box: VBoxContainer) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	box.add_child(button)
	return button
