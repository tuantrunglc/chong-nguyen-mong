class_name CoordOverlay
extends Node2D
## F1 (chỉ khi bật dev): tọa độ "cot,hang" ở góc trên trái mỗi ô, id quân ở góc trên phải ô của nó.
## main.gd đặt node này làm con cuối của BoardView, nên nó nằm trên đồng quân và ẩn theo bàn cờ.

const FONT_SIZE: int = 12
const MARGIN: int = 3
const LABEL_SIZE: Vector2 = Vector2(40, 18)
const TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 0.55)


func _ready() -> void:
	visible = false


## Vẽ lại theo bản chụp; null thì xóa hết.
func show_state(state: BattleState) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	if state == null:
		return
	var cell_size: Vector2 = Vector2.ONE * BoardView.CELL_SIZE
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var origin: Vector2 = Vector2(c, r) * cell_size
			_add_label("%d,%d" % [c, r], origin + Vector2(MARGIN, MARGIN), HORIZONTAL_ALIGNMENT_LEFT)
	for unit: Unit in state.units:
		var origin: Vector2 = Vector2(unit.cell) * cell_size
		var top_right: Vector2 = origin + Vector2(cell_size.x - MARGIN - LABEL_SIZE.x, MARGIN)
		_add_label(str(unit.id), top_right, HORIZONTAL_ALIGNMENT_RIGHT)


## Bật/tắt; trả về trạng thái mới (true là đang hiện).
func toggle() -> bool:
	visible = not visible
	return visible


## Chữ của mọi Label đang có (để test).
func texts() -> Array[String]:
	var out: Array[String] = []
	for child: Node in get_children():
		out.append(((child as PanelContainer).get_child(0) as Label).text)
	return out


func _add_label(text: String, at: Vector2, align: HorizontalAlignment) -> void:
	var label: Label = Label.new()
	label.text = text
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.content_margin_left = 2
	style.content_margin_right = 2
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	panel.position = at
	add_child(panel)
	if align == HORIZONTAL_ALIGNMENT_RIGHT:
		# PanelContainer co theo chữ: đẩy sang phải để mép phải thẳng hàng với góc ô.
		panel.position.x = at.x + LABEL_SIZE.x - panel.get_combined_minimum_size().x
