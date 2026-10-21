class_name CoordOverlay
extends Node2D
## F1 (chỉ khi bật dev): tọa độ "cot,hang" ở góc dưới phải mỗi ô, dưới chấm máu (ngoài đồng quân, không đè tên
## quân; góc dưới trái để số thứ tự đòn, Story 2.7), id quân ở bên phải đầu đồng quân.
## main.gd đặt node này làm con cuối của BoardView, nên nó nằm trên đồng quân và ẩn theo bàn cờ.
## Vị trí chỉ tính qua BoardView.top_center (bàn nhìn chếch, Story 1.8). Nhãn không nhận chuột: bấm xuyên xuống bàn.

const FONT_SIZE: int = 12
const TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 0.55)
## Tâm nhãn tọa độ, tính từ tâm mặt ô: góc dưới phải, dưới chấm máu (UnitToken.HP_OFFSET).
const CELL_LABEL_OFFSET: Vector2 = Vector2(18, 21)


func _ready() -> void:
	visible = false


## Vẽ lại theo bản chụp; null thì xóa hết.
func show_state(state: BattleState) -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	if state == null:
		return
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			var corner: Vector2 = BoardView.top_center(cell, state.terrain_at(cell)) \
				+ CELL_LABEL_OFFSET
			_add_label("%d,%d" % [c, r], corner, true)
	for unit: Unit in state.units:
		var feet: Vector2 = BoardView.top_center(unit.cell, state.terrain_at(unit.cell))
		_add_label(str(unit.id), feet + Vector2(UnitToken.RADIUS, -UnitToken.TOKEN_LIFT - UnitToken.RADIUS), false)


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


## centered: tâm nhãn ở at; không thì góc trên trái nhãn ở at.
func _add_label(text: String, at: Vector2, centered: bool) -> void:
	var label: Label = Label.new()
	label.text = text
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.add_theme_font_size_override("font_size", FONT_SIZE)
	label.add_theme_color_override("font_color", TEXT_COLOR)
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.content_margin_left = 2
	style.content_margin_right = 2
	panel.add_theme_stylebox_override("panel", style)
	panel.add_child(label)
	panel.position = at
	add_child(panel)
	if centered:
		# PanelContainer co theo chữ: biết cỡ rồi mới canh giữa được.
		panel.position = at - panel.get_combined_minimum_size() / 2.0
