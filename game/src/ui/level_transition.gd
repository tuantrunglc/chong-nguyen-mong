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
const PANEL_PADDING: float = 20.0
const ICON_GAP: int = 8

## Tranh nền đang hiện (đường dẫn từ assets/textures/); đổi theo trận sắp vào.
var _backdrop: String = ScreenArt.TRANSITION_DEFAULT
var _heading: Label
var _title: Label
## Dòng nhiệm vụ của trận kế (biểu tượng 32×32 và chữ); ẩn khi không biết kiểu trận.
var _mission_row: HBoxContainer
var _mission_icon: TextureRect
var _mission_label: Label
var _stratagems: VBoxContainer
var _next_button: Button
var _menu_button: Button


func setup() -> void:
	var center: CenterContainer = CenterContainer.new()
	center.size = size
	add_child(center)
	# Chữ nằm trên khung tối để đọc rõ trên cả ba tranh (Story 8.6, AC 6).
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var flat: StyleBoxFlat = StyleBoxFlat.new()
	flat.bg_color = Color(0.06, 0.05, 0.04, 0.78)
	flat.set_content_margin_all(PANEL_PADDING)
	panel.add_theme_stylebox_override("panel", UiStyle.panel(PANEL_PADDING, flat))
	center.add_child(panel)
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", SEPARATION)
	panel.add_child(box)

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

	_mission_row = HBoxContainer.new()
	_mission_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mission_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_mission_row.add_theme_constant_override("separation", ICON_GAP)
	_mission_icon = TextureRect.new()
	_mission_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mission_icon.custom_minimum_size = Vector2(UiStyle.MISSION_ICON_LARGE_SIZE, UiStyle.MISSION_ICON_LARGE_SIZE)
	_mission_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mission_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mission_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_mission_icon.visible = UiStyle.ENABLED
	_mission_row.add_child(_mission_icon)
	_mission_label = Label.new()
	_mission_label.add_theme_color_override("font_color", SUBTITLE_COLOR)
	_mission_row.add_child(_mission_label)
	_mission_row.visible = false
	box.add_child(_mission_row)

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
	UiStyle.apply_button(button)
	button.pressed.connect(func() -> void: signal_to_emit.emit())
	parent.add_child(button)
	return button


## Trận kế: tên trận (khóa "ten" của file trận) và các mưu kế trận kế mở mà trận vừa thắng không có.
## mission (LevelData.Mission) hiện dòng nhiệm vụ; -1 là không biết, ẩn dòng. level_id chọn tranh nền (ScreenArt).
func show_next(level_name: String, new_stratagems: Array[int], mission: int = -1, level_id: String = "") -> void:
	_backdrop = ScreenArt.transition_for(level_id)
	_heading.visible = true
	_title.text = level_name
	_show_mission(mission)
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
	queue_redraw()


## Hết chuỗi trận.
func show_campaign_end() -> void:
	_backdrop = ScreenArt.campaign_end()
	_heading.visible = false
	_title.text = tr("transition.campaign_won")
	_mission_row.visible = false
	_clear_stratagems()
	_next_button.visible = false
	_menu_button.visible = true
	queue_redraw()


func _show_mission(mission: int) -> void:
	if not UiStyle.MISSION_ICONS_LARGE.has(mission):
		_mission_row.visible = false
		return
	_mission_icon.texture = Art.tex(UiStyle.MISSION_ICONS_LARGE[mission] as String)
	_mission_label.text = tr(UiStyle.MISSION_KEYS[mission] as String)
	_mission_row.visible = true


func _clear_stratagems() -> void:
	for child: Node in _stratagems.get_children():
		_stratagems.remove_child(child)
		child.queue_free()


func _draw() -> void:
	ScreenArt.draw_backdrop(self, _backdrop, size)


## Tranh nền đang dùng và dòng nhiệm vụ đang hiện (để test); chữ rỗng là đang ẩn.
func backdrop_path() -> String:
	return _backdrop


func mission_text() -> String:
	return _mission_label.text if _mission_row.visible else ""


func mission_icon() -> Texture2D:
	return _mission_icon.texture if _mission_row.visible else null


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
