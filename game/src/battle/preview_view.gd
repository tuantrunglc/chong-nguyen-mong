class_name PreviewView
extends Node2D
## Bóng mờ kết quả đòn (Story 2.12, FR41): vị trí cuối + số máu sau đòn của mọi quân bị ảnh hưởng.
## Chỉ nhận dữ liệu hiển thị đã tính sẵn (`pos`, `type`, `hp`, `faction`, `cell`): không đọc trạng thái sống,
## không sửa gì. BoardView đặt nó sau lớp đồng quân và trước lớp số thứ tự đòn, để ô đỏ + số vẫn nổi nhất (NFR9).

const GHOST_ALPHA: float = 0.5
const NAME_FONT_SIZE: int = 15
const HP_FONT_SIZE: int = 12
const OUTLINE_SIZE: int = 6

var _ghosts: Array[Dictionary] = []


## Vẽ bóng cho danh sách quân; danh sách rỗng là xóa hết.
func show_ghosts(ghosts: Array[Dictionary]) -> void:
	_clear_labels()
	_ghosts = ghosts.duplicate(true)
	for ghost: Dictionary in _ghosts:
		_add_labels(ghost)
	queue_redraw()


func clear() -> void:
	if _ghosts.is_empty():
		return
	_ghosts = []
	_clear_labels()
	queue_redraw()


## Bóng đang hiện (để test).
func ghosts() -> Array[Dictionary]:
	return _ghosts.duplicate(true)


func _clear_labels() -> void:
	# Gỡ khỏi cây ngay rồi mới hẹn xóa: nếu chỉ `queue_free` thì nhãn cũ còn nằm trong cây tới cuối khung hình
	# và chồng lên nhãn mới khi chuột đổi ô nhanh.
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func _add_labels(ghost: Dictionary) -> void:
	var pos: Vector2 = ghost.get("pos", Vector2.ZERO) as Vector2
	var center: Vector2 = pos + Vector2(0.0, -UnitToken.TOKEN_LIFT)
	var type: int = ghost.get("type", 0) as int
	var hp: int = ghost.get("hp", 0) as int
	var moved: bool = ghost.get("moved", true) as bool
	var text_color: Color = Color(1.0, 0.95, 0.80, GHOST_ALPHA)
	if not UnitToken.NAME_KEYS.has(type):
		return
	_add_label(tr(UnitToken.NAME_KEYS[type] as String), center, NAME_FONT_SIZE, text_color)
	# Quân không đổi ô (bị đánh tại chỗ): số máu sau đòn phải nằm TRÊN đồng quân, nếu để đúng góc dưới phải thì
	# hai số máu (thật và xem trước) chồng lên nhau thành một cục không đọc được.
	var hp_center: Vector2 = center + UnitToken.HP_OFFSET if moved else center - Vector2(0.0, UnitToken.RADIUS + 10.0)
	_add_label(str(hp), hp_center, HP_FONT_SIZE, Color(1.0, 1.0, 1.0, GHOST_ALPHA))


func _add_label(text: String, center: Vector2, font_size: int, color: Color) -> void:
	var label: Label = Label.new()
	label.text = text
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.theme_type_variation = &"TitleLabel"
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.06, 0.05, GHOST_ALPHA))
	label.add_theme_constant_override("outline_size", OUTLINE_SIZE)
	label.size = Vector2(UnitToken.RADIUS * 2.0, font_size * 1.6)
	label.position = center - label.size / 2.0
	add_child(label)


func _draw() -> void:
	for ghost: Dictionary in _ghosts:
		var pos: Vector2 = ghost.get("pos", Vector2.ZERO) as Vector2
		var faction: int = ghost.get("faction", Unit.Faction.NGUYEN) as int
		var color: Color = UnitToken.DAI_VIET_COLOR if faction == Unit.Faction.DAI_VIET else UnitToken.NGUYEN_COLOR
		color.a = GHOST_ALPHA
		draw_circle(pos + Vector2(0.0, -UnitToken.TOKEN_LIFT), UnitToken.RADIUS, color)
		draw_arc(pos + Vector2(0.0, -UnitToken.TOKEN_LIFT), UnitToken.RADIUS, 0.0, TAU, 32,
			Color(1.0, 1.0, 1.0, GHOST_ALPHA), 2.0)
