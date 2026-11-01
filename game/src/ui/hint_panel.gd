class_name HintPanel
extends Control
## Bảng gợi ý luật đầu trận và bảng thao tác, phím tắt (Story 4.8), dựng bằng code. Chỉ hiện chữ do người gọi đưa
## (khóa dịch), không biết luật. Phủ cả cửa sổ để nuốt cú bấm: bấm chuột trái ở đâu cũng chỉ tắt bảng, không chọn
## hay đánh gì. Đang mở thì mọi phím bị nuốt, trừ Esc và ? là tắt bảng (người mới gõ nhầm Space không mất lượt).
## Phím ? (mở bảng khi đang đóng) nhận theo ký tự, không theo vị trí phím, để đúng mọi bàn phím: phát help_requested,
## main.gd quyết có mở không. Node nằm sau BattleInput trong cây nên nhận phím trước nó.

signal help_requested
signal closed

## Mã ký tự "?".
const QUESTION_UNICODE: int = 63
const PADDING: int = 20
const SEPARATION: int = 10
const BACKGROUND_COLOR: Color = Color(0.16, 0.11, 0.08, 0.92)
const BORDER_COLOR: Color = Color(0.36, 0.24, 0.14)
const BORDER_WIDTH: int = 4
const HINT_COLOR: Color = Color(1.0, 0.86, 0.45)
const NOTE_COLOR: Color = Color(0.85, 0.75, 0.6)
const HINT_FONT_SIZE: int = 20
const BODY_FONT_SIZE: int = 17
const NOTE_FONT_SIZE: int = 15
const PANEL_WIDTH: float = 720.0
const HELP_COLUMN_WIDTH: float = 190.0
## Bảng thao tác theo bảng Controls của GDD: [khóa tên thao tác, khóa cách làm].
const HELP_ROWS: Array[Array] = [
	["help.select", "help.select.how"],
	["help.move", "help.move.how"],
	["help.attack", "help.attack.how"],
	["help.info", "help.info.how"],
	["help.stratagem", "help.stratagem.how"],
	["help.undo", "help.undo.how"],
	["help.end_turn", "help.end_turn.how"],
	["help.replay", "help.replay.how"],
	["help.fast", "help.fast.how"],
]

var _center: CenterContainer
var _box: VBoxContainer
var _lines: Array[String] = []


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_center = CenterContainer.new()
	_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_center)
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(BORDER_WIDTH)
	style.set_content_margin_all(PADDING)
	panel.add_theme_stylebox_override("panel", style)
	_center.add_child(panel)
	_box = VBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_constant_override("separation", SEPARATION)
	panel.add_child(_box)


## Gợi ý đầu trận: các dòng gợi ý và một dòng nhắc phím ?, ở nửa dưới bàn cờ để còn thấy bàn.
func show_hint(keys: Array[String]) -> void:
	_clear()
	_lines.clear()
	for key: String in keys:
		_lines.append(tr(key))
		_add_label(_lines[_lines.size() - 1], HINT_FONT_SIZE, HINT_COLOR)
	_add_label(tr("hint.more"), NOTE_FONT_SIZE, NOTE_COLOR)
	_open(Rect2(BoardView.AREA.position.x, BoardView.AREA.get_center().y, BoardView.AREA.size.x,
		BoardView.AREA.size.y / 2.0))


## Bảng "?" : gợi ý của trận (nếu có) rồi bảng thao tác, giữa bàn cờ.
func show_help(keys: Array[String]) -> void:
	_clear()
	_lines.clear()
	for key: String in keys:
		_lines.append(tr(key))
		_add_label(_lines[_lines.size() - 1], HINT_FONT_SIZE, HINT_COLOR)
	_add_label(tr("help.title"), HINT_FONT_SIZE, Color.WHITE)
	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 4)
	_box.add_child(grid)
	for row: Array in HELP_ROWS:
		var name_label: Label = _label(tr(row[0] as String), BODY_FONT_SIZE, HINT_COLOR)
		name_label.custom_minimum_size = Vector2(HELP_COLUMN_WIDTH, 0)
		grid.add_child(name_label)
		var how_label: Label = _label(tr(row[1] as String), BODY_FONT_SIZE, Color.WHITE)
		how_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		how_label.custom_minimum_size = Vector2(PANEL_WIDTH - HELP_COLUMN_WIDTH - 24.0 - 2.0 * PADDING - 2.0 * BORDER_WIDTH, 0)
		grid.add_child(how_label)
	_add_label(tr("help.close"), NOTE_FONT_SIZE, NOTE_COLOR)
	_open(BoardView.AREA)


func hide_panel() -> void:
	if not visible:
		return
	visible = false
	closed.emit()


func is_open() -> bool:
	return visible


## Các dòng gợi ý đang hiện, đã dịch (để test).
func hint_lines() -> Array[String]:
	return _lines.duplicate()


## Mọi chữ đang hiện, mỗi nhãn một phần tử (để test).
func texts() -> Array[String]:
	var out: Array[String] = []
	_collect_texts(_box, out)
	return out


func _gui_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		hide_panel()
	# Mọi sự kiện chuột khác cũng không được lọt xuống bàn cờ.
	accept_event()


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed:
		return
	if visible:
		if key.echo:
			get_viewport().set_input_as_handled()
			return
		if key.keycode == KEY_ESCAPE or key.unicode == QUESTION_UNICODE:
			hide_panel()
		get_viewport().set_input_as_handled()
	elif key.unicode == QUESTION_UNICODE and not key.echo:
		help_requested.emit()
		get_viewport().set_input_as_handled()


func _open(area: Rect2) -> void:
	_center.position = area.position
	_center.size = area.size
	visible = true


func _clear() -> void:
	for child: Node in _box.get_children():
		_box.remove_child(child)
		child.queue_free()


func _add_label(text: String, font_size: int, color: Color) -> void:
	var label: Label = _label(text, font_size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Nhãn tự xuống dòng phải có bề rộng sẵn, nếu không bảng tính chiều cao theo bề rộng 0 (cao hàng nghìn px).
	label.custom_minimum_size = Vector2(PANEL_WIDTH - 2.0 * PADDING - 2.0 * BORDER_WIDTH, 0)
	_box.add_child(label)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return label


func _collect_texts(node: Node, out: Array[String]) -> void:
	for child: Node in node.get_children():
		if child is Label:
			out.append((child as Label).text)
		_collect_texts(child, out)
