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
## Bấm nút "Tua nhanh" (Story 4.4).
signal fast_forward_pressed
## Bấm nút "?" (Story 4.8): bảng gợi ý và thao tác.
signal help_pressed

## Góc trên trái và bề rộng: bên phải bàn cờ (bàn nằm trong BoardView.AREA, x 16–956).
const PANEL_POSITION: Vector2 = Vector2(972, 52)
## Nới từ 260 (2026-11-02): bảng thông tin tướng bên dưới cần chỗ cho tiểu sử; khung vẫn trong x 964–1272.
const PANEL_WIDTH: float = 292.0
## Khoảng cách và chiều cao nút thu gọn (2026-11-02) để chừa chỗ cho bảng thông tin tướng bên dưới.
const SEPARATION: int = 8
## Khung bảng nhô ra khỏi cột nút bấy nhiêu px mỗi phía; khoảng cách biểu tượng với chữ.
const FRAME_PADDING: float = 8.0
const ICON_GAP: int = 6
const BUTTON_HEIGHT: float = 36.0
## Cỡ chữ của nút đứng chung hàng (Hủy/Chơi lại, Tua nhanh/?), nhỏ hơn chữ thường cho vừa chỗ.
const PAIR_FONT_SIZE: int = 14
## Hàng Tua nhanh / "?" nằm trên thanh tiêu đề, sát trái nút Âm thanh (2026-11-02, nhường chỗ cho bảng tướng).
## Tọa độ màn hình: mép phải = mép trái nút Âm thanh (main.gd: 1280 − 176 − 8) trừ 8 px; cao bằng nút Âm thanh.
const TOOL_ROW_RIGHT: float = 1088.0
const TOOL_ROW_TOP: float = 8.0
const TOOL_ROW_HEIGHT: float = 32.0
const FAST_BUTTON_WIDTH: float = 160.0
const HELP_BUTTON_WIDTH: float = 96.0
## Đáy bảng thông tin tướng (tọa độ màn hình): chừa nhãn phiên bản ở góc dưới phải.
const GENERAL_BOTTOM: float = 688.0
## Màu chữ nổi bật cho hiệp cuối cùng của trận có giới hạn hiệp (Story 3.5).
const FINAL_ROUND_COLOR: Color = Color(1.0, 0.42, 0.35)
## Dòng báo pha ("Lượt của bạn" / "Quân Nguyên đang ra đòn"), nhỏ hơn số hiệp.
const PHASE_FONT_SIZE: int = 17

var _round_label: Label
## Biểu tượng cạnh dòng hiệp, Lòng dân, nhiệm vụ (Story 8.5); mỗi dòng là một hàng ngang gồm biểu tượng và chữ.
var _round_icon: TextureRect
var _morale_icon: TextureRect
var _mission_icon: TextureRect
var _mission_label: Label
var _morale_row: HBoxContainer
var _mission_row: HBoxContainer
## Khung bảng phía sau cột nút (Story 8.5), co theo chiều cao cột.
var _frame: Panel
var _box: VBoxContainer
## Dòng Lòng dân (Story 3.7); ẩn khi trận không có làng.
var _morale_label: Label
## Dòng pha, luôn hiện khi đang chơi (Story 2.11, AC 4).
var _phase_label: Label
var _undo_button: Button
var _replay_button: Button
## Nhãn cạnh nút Chơi lại: "Còn 1 lần" / "Đã dùng" (Story 3.2).
var _replay_label: Label
var _end_turn_button: Button
## Nút bật/tắt tua nhanh pha địch (Story 4.4): không bị set_locked khóa, vì lúc pha địch đang phát mới cần bấm.
var _fast_button: Button
## Nút "?" (Story 4.8): như nút tua, không bị set_locked khóa.
var _help_button: Button
## Chỗ đặt nút mưu kế (giữa Chơi lại và Kết thúc lượt); Stratagem.Kind -> Button của mưu kế trận mở.
var _stratagem_box: VBoxContainer
var _stratagem_buttons: Dictionary = {}
var _stratagems_used: Array[int] = []
## Dòng nhắc dưới các nút ("Bấm lần nữa để đánh"); rỗng thì ẩn.
var _hint_label: Label
## Bảng thông tin tướng vừa chọn (2026-11-02), bám đáy cột phải; không nằm trong cột nút nên dòng nhắc hiện/ẩn
## không làm bảng nhảy.
var _general_panel: GeneralPanel
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
	_frame = Panel.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_theme_stylebox_override("panel", UiStyle.panel(-1.0, StyleBoxEmpty.new()))
	_frame.position = Vector2(-FRAME_PADDING, -FRAME_PADDING)
	add_child(_frame)
	var box: VBoxContainer = VBoxContainer.new()
	_box = box
	box.resized.connect(_fit_frame)
	box.size = Vector2(PANEL_WIDTH, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", SEPARATION)
	add_child(box)

	var round_row: HBoxContainer = _icon_row(box, UiStyle.ICON_ROUND)
	_round_icon = round_row.get_child(0) as TextureRect
	_round_label = Label.new()
	_round_label.theme_type_variation = &"TitleLabel"
	_round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	round_row.add_child(_round_label)

	_mission_row = _icon_row(box, "")
	_mission_icon = _mission_row.get_child(0) as TextureRect
	_mission_label = Label.new()
	_mission_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_mission_row.add_child(_mission_label)
	_mission_row.visible = false

	_morale_row = _icon_row(box, UiStyle.ICON_MORALE)
	_morale_icon = _morale_row.get_child(0) as TextureRect
	_morale_label = Label.new()
	_morale_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_morale_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_morale_label.visible = false
	_morale_row.add_child(_morale_label)
	_morale_row.visible = false

	_phase_label = Label.new()
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phase_label.add_theme_font_size_override("font_size", PHASE_FONT_SIZE)
	_phase_label.visible = false
	box.add_child(_phase_label)

	var edit_row: HBoxContainer = _pair_row(box)
	_undo_button = _button(tr("hud.undo"), edit_row)
	_undo_button.pressed.connect(func() -> void: undo_pressed.emit())
	_replay_button = _button(tr("hud.replay"), edit_row)
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

	var tool_row: HBoxContainer = HBoxContainer.new()
	tool_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tool_row.add_theme_constant_override("separation", SEPARATION)
	var tool_width: float = FAST_BUTTON_WIDTH + HELP_BUTTON_WIDTH + SEPARATION
	tool_row.position = Vector2(TOOL_ROW_RIGHT - tool_width, TOOL_ROW_TOP) - PANEL_POSITION
	tool_row.size = Vector2(tool_width, TOOL_ROW_HEIGHT)
	add_child(tool_row)
	_fast_button = _button(tr("hud.fast.off"), tool_row)
	_fast_button.custom_minimum_size = Vector2(FAST_BUTTON_WIDTH, TOOL_ROW_HEIGHT)
	_fast_button.size_flags_horizontal = Control.SIZE_FILL
	_fast_button.pressed.connect(func() -> void: fast_forward_pressed.emit())
	_help_button = _button(tr("hud.help"), tool_row)
	_help_button.custom_minimum_size = Vector2(HELP_BUTTON_WIDTH, TOOL_ROW_HEIGHT)
	_help_button.size_flags_horizontal = Control.SIZE_FILL
	_help_button.pressed.connect(func() -> void: help_pressed.emit())
	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.visible = false
	box.add_child(_hint_label)

	_general_panel = GeneralPanel.new(PANEL_WIDTH + FRAME_PADDING * 2.0)
	_general_panel.position.x = -FRAME_PADDING
	_general_panel.resized.connect(_place_general_panel)
	add_child(_general_panel)


## Hiện bảng với số hiệp; nút Hủy mờ khi không có gì để hủy, nút Chơi lại mờ khi đã dùng/không chơi lại được.
## Hết trận (over) thì mọi nút đều mờ và ẩn số lần chơi lại.
## Có giới hạn hiệp (max_rounds > 0) thì hiện "Hiệp X/Y"; hiệp cuối đổi màu nổi bật (Story 3.5).
## Có làng (max_morale > 0) thì hiện "Lòng dân: X/Y" (Story 3.7).
func show_turn(round_number: int, can_undo: bool, can_replay: bool, replay_left: int, over: bool = false,
		max_rounds: int = 0, morale: int = 0, max_morale: int = 0, mission: int = -1) -> void:
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
	_morale_row.visible = _morale_label.visible
	_show_mission(mission)
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
## `sat_that_bonus` > 0: Sát Thát đang có hiệu lực trong lượt này, nút ghi "đang +N sát thương" thay cho "đã dùng"
## (tác giả chốt 2026-10-27, Story 3.13): mưu kế này không để lại dấu gì trên bàn.
func show_stratagems(open_kinds: Array[int], used: Array[int], sat_that_bonus: int = 0) -> void:
	var open: Array[int] = Stratagem.in_key_order(open_kinds)
	if open != _stratagem_kinds():
		for button: Button in _stratagem_buttons.values():
			button.queue_free()
		_stratagem_buttons.clear()
		for kind: int in open:
			var button: Button = _button("", _stratagem_box)
			button.tooltip_text = tr("stratagem.tip." + Stratagem.name_of(kind))
			var icon_path: String = UiStyle.STRATAGEM_ICONS.get(kind, "") as String
			if UiStyle.ENABLED and not icon_path.is_empty():
				button.icon = Art.tex(icon_path)
				button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(func() -> void: stratagem_pressed.emit(kind))
			_stratagem_buttons[kind] = button
	_stratagem_box.visible = not open.is_empty()
	_stratagems_used = used.duplicate()
	for kind: int in _stratagem_buttons:
		var key: String = "stratagem." + Stratagem.name_of(kind)
		var button: Button = _stratagem_buttons[kind] as Button
		if kind == Stratagem.Kind.SAT_THAT and sat_that_bonus > 0:
			button.text = tr("hud.stratagem.active") % [tr(key), sat_that_bonus]
		elif used.has(kind):
			button.text = tr("hud.stratagem.used") % tr(key)
		else:
			button.text = tr("hud." + key)
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


## Chữ nút tua nhanh: "Tua nhanh (T): bật" / "Tua nhanh (T): tắt" (Story 4.4).
func show_fast_forward(on: bool) -> void:
	_fast_button.text = tr("hud.fast.on") if on else tr("hud.fast.off")


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


## Dòng nhiệm vụ: chữ và có đang hiện không (để test); rỗng là đang ẩn.
func mission_text() -> String:
	return _mission_label.text if _mission_row.visible else ""


func mission_icon() -> Texture2D:
	return _mission_icon.texture if _mission_row.visible else null


func round_icon() -> Texture2D:
	return _round_icon.texture


func morale_icon() -> Texture2D:
	return _morale_icon.texture if _morale_row.visible else null


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


func fast_forward_button() -> Button:
	return _fast_button


func help_button() -> Button:
	return _help_button


## Bảng thông tin tướng (2026-11-02): chân dung, tên, chỉ số, tiểu sử, mẹo. Giữ tới khi gọi lại với tướng khác.
func show_general(unit_type: int, hp: int, stats: Stats) -> void:
	_general_panel.show_general(unit_type, hp, stats)
	_place_general_panel()


func hide_general() -> void:
	_general_panel.hide_panel()


func general_panel() -> GeneralPanel:
	return _general_panel


func _place_general_panel() -> void:
	# Co theo nội dung (tiểu sử mỗi tướng dài ngắn khác nhau) rồi bám đáy.
	var height: float = _general_panel.get_combined_minimum_size().y
	_general_panel.size = Vector2(PANEL_WIDTH + FRAME_PADDING * 2.0, height)
	_general_panel.position.y = GENERAL_BOTTOM - PANEL_POSITION.y - height


## Hàng ngang hai nút chia đôi bề rộng cột.
func _pair_row(box: VBoxContainer) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", SEPARATION)
	box.add_child(row)
	return row


class StyledButton extends Button:
	func _make_custom_tooltip(for_text: String) -> Object:
		return UiStyle.create_custom_tooltip(for_text)


func _button(text: String, box: BoxContainer) -> Button:
	var button: Button = StyledButton.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	UiStyle.apply_button(button)
	if box is HBoxContainer:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", PAIR_FONT_SIZE)
	box.add_child(button)
	return button


## Hàng ngang căn giữa: biểu tượng (con đầu) rồi chữ do người gọi thêm. icon_path rỗng thì để trống, gán sau.
func _icon_row(parent: Container, icon_path: String) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", ICON_GAP)
	var icon: TextureRect = TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.custom_minimum_size = Vector2(UiStyle.ICON_SIZE, UiStyle.ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.visible = UiStyle.ENABLED
	if not icon_path.is_empty():
		icon.texture = Art.tex(icon_path)
	row.add_child(icon)
	parent.add_child(row)
	return row


## Dòng nhiệm vụ theo kiểu trận (LevelData.Mission); mission < 0 là không biết, ẩn dòng.
func _show_mission(mission: int) -> void:
	if not UiStyle.MISSION_ICONS.has(mission):
		_mission_row.visible = false
		return
	_mission_icon.texture = Art.tex(UiStyle.MISSION_ICONS[mission] as String)
	_mission_label.text = tr(UiStyle.MISSION_KEYS[mission] as String)
	_mission_row.visible = true


func _fit_frame() -> void:
	_frame.size = _box.size + Vector2(FRAME_PADDING, FRAME_PADDING) * 2.0
