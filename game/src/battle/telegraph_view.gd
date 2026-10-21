class_name TelegraphView
extends Node2D
## Ô đỏ báo đòn và số thứ tự (Story 2.7, FR24, NFR9). Hai lớp, BoardView tạo và xếp:
## - lớp mặt đất (chính node này): đứng trước đồng quân, tô đỏ mặt trên ô đòn phủ và vẽ mũi tên xung phong của
##   Kỵ binh (trừ khi ô đầu đường có quân hoặc là khối: xem lớp số). Đứng sau phần vẽ của BoardView nên tô lên ô sáng xanh: ô vừa sáng vừa đỏ vẫn ra đỏ.
## - lớp số (numbers): đứng trên đồng quân, số thứ tự ở góc dưới trái mặt ô đòn sẽ trúng (đồng quân đứng giữa
##   ô, chấm máu ở góc dưới phải). Ô khối nhô lên (rừng, kho lương, làng) tô đỏ ở lớp này: khối nằm cùng lớp
##   với đồng quân, tô ở lớp mặt đất thì khối che mất; trên khối không có quân nên không che gì. Mũi tên ở ô có
##   quân cũng vẽ ở lớp này, không thì đồng quân che mất mũi tên của Kỵ binh đứng kề mục tiêu.
## Chỉ vẽ theo bản chụp, mọi luật lấy từ TelegraphMarks. Không nhận chuột: bấm xuyên xuống bàn.

## Đỏ tươi, trong suốt một phần để thấy chữ địa hình; khác đỏ đồng Đại Việt (UnitToken.DAI_VIET_COLOR).
const FILL_COLOR: Color = Color(1.0, 0.08, 0.08, 0.65)
const BORDER_COLOR: Color = Color(0.85, 0.0, 0.0)
const BORDER_WIDTH: float = 3.0
## Mũi tên xung phong: thân và đầu, tính theo nửa cạnh ô.
const ARROW_COLOR: Color = Color(1.0, 1.0, 1.0, 0.95)
const ARROW_OUTLINE_COLOR: Color = Color(0.35, 0.0, 0.0)
const ARROW_LENGTH: float = 0.7
const ARROW_HEAD: float = 0.3
const ARROW_SHAFT_WIDTH: float = 6.0
const NUMBER_FONT_SIZE: int = 28
## Chuỗi nhiều số dài hơn mặt ô thì giảm cỡ chữ cho vừa, không nhỏ hơn mức này.
const NUMBER_MIN_FONT_SIZE: int = 12
const NUMBER_COLOR: Color = Color(1.0, 1.0, 1.0)
const NUMBER_OUTLINE_COLOR: Color = Color(0.25, 0.0, 0.0)
const NUMBER_OUTLINE_SIZE: int = 8
## Khoảng từ mép trái và mép dưới mặt ô tới chữ số (px).
const NUMBER_MARGIN: Vector2 = Vector2(3, 2)
## Nối các số của nhiều đòn trúng cùng một ô.
const NUMBER_SEPARATOR: String = "·"

## Lớp số, BoardView đặt trên đồng quân.
var numbers: Node2D

var _state: BattleState = null
## Ô -> số thứ tự các đòn phủ ô đó (TelegraphMarks.cells).
var _cells: Dictionary = {}
## Ô đầu đường xung phong -> các hướng (Array[Vector2i]) của những Kỵ binh bắt đầu từ ô đó.
var _arrows: Dictionary = {}


func _init() -> void:
	numbers = Node2D.new()
	numbers.draw.connect(_draw_on_blocks)


## Vẽ lại theo bản chụp; null là xóa hết.
func show_state(state: BattleState) -> void:
	_state = state
	_cells = {} if state == null else TelegraphMarks.cells(state)
	_arrows = {}
	for child: Node in numbers.get_children():
		numbers.remove_child(child)
		child.queue_free()
	if state != null:
		var hits: Dictionary = {}
		for t: Telegraph in state.telegraphs:
			var path: Array[Vector2i] = TelegraphMarks.path_cells(state, t)
			if path.is_empty():
				continue
			if t.kind == Telegraph.Kind.DIRECTION:
				if not _arrows.has(path[0]):
					_arrows[path[0]] = [] as Array[Vector2i]
				(_arrows[path[0]] as Array[Vector2i]).append(t.offset)
			var hit: Vector2i = path[path.size() - 1]
			if not hits.has(hit):
				hits[hit] = [] as Array[int]
			(hits[hit] as Array[int]).append(t.order)
		for cell: Vector2i in hits:
			var orders: Array[int] = hits[cell] as Array[int]
			orders.sort()
			_add_number(cell, orders)
	queue_redraw()
	numbers.queue_redraw()


## Ô -> số thứ tự các đòn phủ ô đó, đang vẽ (để test).
func red_cells() -> Dictionary:
	return _cells


## Ô đầu đường xung phong -> các hướng mũi tên (để test).
func arrows() -> Dictionary:
	return _arrows


## Ô -> nhãn số thứ tự đang hiện (để test).
func number_labels() -> Dictionary:
	var out: Dictionary = {}
	for child: Node in numbers.get_children():
		if child is Label and not child.is_queued_for_deletion():
			out[child.get_meta("cell") as Vector2i] = child
	return out


## Mặt trên ô (ô ải, khối nhô lên nâng theo chiều cao).
func top_rect(cell: Vector2i) -> Rect2:
	var center: Vector2 = BoardView.top_center(cell, _state.terrain_at(cell))
	var half: Vector2 = Vector2(BoardView.TILE_SIZE, BoardView.TILE_SIZE) / 2.0
	return Rect2(center - half, half * 2.0)


## Khung chữ số của nhãn: từ đỉnh chữ số tới đường chân chữ (không tính khoảng dành cho dấu tiếng Việt), tọa độ
## của BoardView. Đo bằng glyph thật của font.
func number_glyph_rect(label: Label) -> Rect2:
	var font: Font = label.get_theme_font("font")
	var ts: TextServer = TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	var size: int = label.get_meta("font_size") as int
	var glyph: int = ts.font_get_glyph_index(rid, size, "0".unicode_at(0), 0)
	var top: float = ts.font_get_glyph_offset(rid, Vector2i(size, 0), glyph).y
	var baseline: float = label.position.y + font.get_ascent(size)
	var width: float = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	return Rect2(label.position.x, baseline + top, width, -top)


func _add_number(cell: Vector2i, orders: Array[int]) -> void:
	var parts: PackedStringArray = PackedStringArray()
	for order: int in orders:
		parts.append(str(order))
	var label: Label = Label.new()
	label.text = NUMBER_SEPARATOR.join(parts)
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.set_meta("cell", cell)
	numbers.add_child(label)
	var size: int = _fitting_font_size(label)
	label.set_meta("font_size", size)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", NUMBER_COLOR)
	label.add_theme_color_override("font_outline_color", NUMBER_OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", NUMBER_OUTLINE_SIZE)
	# Đường chân chữ cách mép dưới mặt ô NUMBER_MARGIN.y: chữ số nằm dưới đồng quân và chấm máu.
	var ascent: float = label.get_theme_font("font").get_ascent(size)
	var face: Rect2 = top_rect(cell)
	label.position = Vector2(face.position.x + NUMBER_MARGIN.x, face.end.y - NUMBER_MARGIN.y - ascent)


## Cỡ chữ lớn nhất (không quá NUMBER_FONT_SIZE, không nhỏ hơn NUMBER_MIN_FONT_SIZE) để chuỗi của nhãn nằm gọn trong
## mặt ô. Nhãn đã nằm trong cây để lấy đúng font của theme.
func _fitting_font_size(label: Label) -> int:
	var font: Font = label.get_theme_font("font")
	var room: float = BoardView.TILE_SIZE - NUMBER_MARGIN.x * 2.0
	var size: int = NUMBER_FONT_SIZE
	while size > NUMBER_MIN_FONT_SIZE and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > room:
		size -= 1
	return size


## Mũi tên ở ô này vẽ ở lớp trên đồng quân: ô khối, hoặc ô đang có quân đứng (đồng quân che mũi tên ở lớp dưới).
func arrow_on_top(cell: Vector2i) -> bool:
	return _is_block(cell) or _state.unit_at(cell) != null


func _is_block(cell: Vector2i) -> bool:
	return BoardView.BLOCK_KINDS.has(_state.terrain_at(cell))


func _draw_red(canvas: CanvasItem, cell: Vector2i) -> void:
	var face: Rect2 = top_rect(cell)
	canvas.draw_rect(face, FILL_COLOR)
	canvas.draw_rect(face.grow(-BORDER_WIDTH / 2.0), BORDER_COLOR, false, BORDER_WIDTH)


func _draw() -> void:
	if _state == null:
		return
	for cell: Vector2i in _cells:
		if not _is_block(cell):
			_draw_red(self, cell)
	for cell: Vector2i in _arrows:
		if not arrow_on_top(cell):
			for dir: Vector2i in _arrows[cell] as Array[Vector2i]:
				_draw_arrow(self, cell, dir)


## Ô khối nhô lên: tô trên lớp số (xem đầu file).
func _draw_on_blocks() -> void:
	if _state == null:
		return
	for cell: Vector2i in _cells:
		if _is_block(cell):
			_draw_red(numbers, cell)
	for cell: Vector2i in _arrows:
		if arrow_on_top(cell):
			for dir: Vector2i in _arrows[cell] as Array[Vector2i]:
				_draw_arrow(numbers, cell, dir)


## Mũi tên giữa mặt ô, chỉ theo hướng xung phong.
func _draw_arrow(canvas: CanvasItem, cell: Vector2i, dir: Vector2i) -> void:
	var half: float = BoardView.TILE_SIZE / 2.0
	var center: Vector2 = top_rect(cell).get_center()
	var forward: Vector2 = Vector2(dir)
	var side: Vector2 = Vector2(-forward.y, forward.x)
	var tip: Vector2 = center + forward * half * ARROW_LENGTH
	var tail: Vector2 = center - forward * half * ARROW_LENGTH
	var head_base: Vector2 = tip - forward * half * ARROW_HEAD * 2.0
	var head: PackedVector2Array = PackedVector2Array([tip, head_base + side * half * ARROW_HEAD,
		head_base - side * half * ARROW_HEAD])
	canvas.draw_line(tail, head_base, ARROW_OUTLINE_COLOR, ARROW_SHAFT_WIDTH + 4.0)
	canvas.draw_line(tail, head_base, ARROW_COLOR, ARROW_SHAFT_WIDTH)
	canvas.draw_colored_polygon(head, ARROW_COLOR)
	canvas.draw_polyline(head + PackedVector2Array([tip]), ARROW_OUTLINE_COLOR, 2.0, true)
