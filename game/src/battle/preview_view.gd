class_name PreviewView
extends Node2D
## Bóng mờ kết quả đòn (Story 2.12, FR41): vị trí cuối + số máu sau đòn của mọi quân bị ảnh hưởng.
## Chỉ nhận dữ liệu hiển thị đã tính sẵn (`pos`, `type`, `hp`, `faction`, `cell`): không đọc trạng thái sống,
## không sửa gì. BoardView đặt nó sau lớp đồng quân, trước viền mục tiêu và lớp số thứ tự đòn: bóng nằm trên ô
## đỏ (ô đỏ vốn ở dưới đồng quân) nhưng không bao giờ che số thứ tự đòn (NFR9).

const GHOST_ALPHA: float = 0.5
const HP_FONT_SIZE: int = 12
const OUTLINE_SIZE: int = 6

## Viền ô trúng mới của đòn dời (Story 4.6): cam, khác viền trắng ô mục tiêu và viền cam vàng ô tiếp viện.
const MOVED_STRIKE_COLOR: Color = Color(1.0, 0.55, 0.1, 0.95)
## Dấu gạch chéo trên ô đỏ không còn trúng (đòn hủy, hoặc ô cũ của đòn dời).
const CROSS_COLOR: Color = Color(1.0, 1.0, 1.0, 0.9)
const CROSS_WIDTH: float = 3.0
const MARK_FONT_SIZE: int = 12
## Chữ va chạm/chết đuối ở mép dưới ô, chữ về đòn ở mép trên ô: số thứ tự đòn nằm góc dưới–trái và đồng quân giữa ô,
## đặt chung một chỗ thì chữ bị che (chụp thử Story 4.6). Nhiều chữ cùng chỗ thì xếp lùi vào giữa ô.
const MARK_LABEL_BOTTOM: float = 0.36
const MARK_LABEL_TOP: float = -0.42
const MARK_LABEL_STEP: float = 15.0
## Nền tối dưới chữ chỉ báo, để đọc được trên ô đỏ, ô sông và đồng quân.
const MARK_BG_COLOR: Color = Color(0.08, 0.06, 0.05, 0.8)
const MARK_TEXT_COLOR: Color = Color(1.0, 0.95, 0.75, 0.95)
const MARK_DANGER_COLOR: Color = Color(1.0, 0.45, 0.4, 0.98)
## Đánh dấu nhãn của chỉ báo, để tách khỏi nhãn số máu của bóng.
const MARK_META: StringName = &"preview_mark"
const MARK_KEYS: Dictionary = {
	PreviewMarks.Kind.COLLISION: "preview.collision",
	PreviewMarks.Kind.DROWNED: "preview.drowned",
	PreviewMarks.Kind.STRIKE_MOVED: "preview.strike_moved",
	PreviewMarks.Kind.STRIKE_CANCELLED: "preview.strike_cancelled",
	PreviewMarks.Kind.HITS_ENEMY: "preview.hits_enemy",
	PreviewMarks.Kind.HITS_GENERAL: "preview.hits_general",
}

var _ghosts: Array[Dictionary] = []
var _marks: Array[Dictionary] = []
## Bản chụp sau lệnh xem trước, chỉ để biết độ cao mặt ô khi vẽ chỉ báo.
var _marks_state: BattleState = null


## Vẽ bóng cho danh sách quân; danh sách rỗng là xóa hết.
## village_damage (Story 3.7): { "cell": Vector2i, "amount": int } để hiện chỉ báo mất Lòng dân trên làng.
func show_ghosts(ghosts: Array[Dictionary], village_damage: Dictionary = {}) -> void:
	_clear_labels()
	_marks = []
	_marks_state = null
	_ghosts = ghosts.duplicate(true)
	for ghost: Dictionary in _ghosts:
		_add_labels(ghost)
	if not village_damage.is_empty() and village_damage.has("cell"):
		var cell: Vector2i = village_damage["cell"] as Vector2i
		var text: String = tr("notice.morale_lost")
		var center: Vector2 = BoardView.cell_center(cell)
		_add_label(text, center, 14, Color(1.0, 0.4, 0.35, 0.95))
	queue_redraw()


## Chỉ báo chuỗi hệ quả (PreviewMarks.compute, Story 4.6); gọi sau show_ghosts của cùng lần xem trước.
## state: bản chụp sau lệnh, chỉ đọc độ cao ô.
func show_marks(marks: Array[Dictionary], state: BattleState) -> void:
	_marks = marks.duplicate(true)
	_marks_state = state
	var per_slot: Dictionary = {}
	for mark: Dictionary in _marks:
		var cell: Vector2i = mark["cell"] as Vector2i
		var kind: int = mark["kind"] as int
		var at_bottom: bool = kind == PreviewMarks.Kind.COLLISION or kind == PreviewMarks.Kind.DROWNED
		var slot: Array = [cell, at_bottom]
		var stacked: int = per_slot.get(slot, 0) as int
		per_slot[slot] = stacked + 1
		var text: String = tr(MARK_KEYS[kind] as String)
		if kind == PreviewMarks.Kind.COLLISION:
			text = text % (mark.get("amount", 1) as int)
		elif kind == PreviewMarks.Kind.STRIKE_MOVED or kind == PreviewMarks.Kind.STRIKE_CANCELLED:
			text = text % (mark.get("order", 0) as int)
		var y: float = BoardView.TILE_SIZE * MARK_LABEL_BOTTOM - stacked * MARK_LABEL_STEP if at_bottom \
			else BoardView.TILE_SIZE * MARK_LABEL_TOP + stacked * MARK_LABEL_STEP
		var danger: bool = kind == PreviewMarks.Kind.HITS_GENERAL
		var label: Label = _add_label(text, _top_center(cell) + Vector2(0.0, y), MARK_FONT_SIZE,
			MARK_DANGER_COLOR if danger else MARK_TEXT_COLOR)
		label.set_meta(MARK_META, true)
		var bg: StyleBoxFlat = StyleBoxFlat.new()
		bg.bg_color = MARK_BG_COLOR
		bg.set_corner_radius_all(3)
		label.add_theme_stylebox_override("normal", bg)
		# Vừa khít chữ để nền không phủ cả ô.
		label.size = Vector2(label.get_minimum_size().x + 6.0, MARK_FONT_SIZE + 4.0)
		label.position = _top_center(cell) + Vector2(0.0, y) - label.size / 2.0
	queue_redraw()


## Chỉ báo đang hiện (để test).
func marks() -> Array[Dictionary]:
	return _marks.duplicate(true)


func clear() -> void:
	if _ghosts.is_empty() and _marks.is_empty() and get_child_count() == 0:
		return
	_ghosts = []
	_marks = []
	_marks_state = null
	_clear_labels()
	queue_redraw()


## Bóng đang hiện (để test).
func ghosts() -> Array[Dictionary]:
	return _ghosts.duplicate(true)


## Chữ báo trừ Lòng dân trên làng (để test Story 3.7, AC 7).
func village_damage_text() -> String:
	for child: Node in get_children():
		var label: Label = child as Label
		if label != null and label.text.contains("Lòng dân"):
			return label.text
	return ""


func _clear_labels() -> void:
	# Gỡ khỏi cây ngay rồi mới hẹn xóa: nếu chỉ `queue_free` thì nhãn cũ còn nằm trong cây tới cuối khung hình
	# và chồng lên nhãn mới khi chuột đổi ô nhanh.
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func _add_labels(ghost: Dictionary) -> void:
	var pos: Vector2 = ghost.get("pos", Vector2.ZERO) as Vector2
	var center: Vector2 = pos + Vector2(0.0, -UnitToken.TOKEN_LIFT)
	var hp: int = ghost.get("hp", 0) as int
	var moved: bool = ghost.get("moved", true) as bool
	# Số máu luôn nằm TRONG ô của bóng. Quân không đổi ô (bị đánh tại chỗ) đặt số ở góc dưới–trái, đối xứng với
	# chấm máu thật ở góc dưới–phải: không đè số thật, và không lọt sang ô bên trên như bản đặt phía trên đồng
	# (Story 2.12 review vòng 2). Bóng không vẽ tên quân để không làm đậm/nhòe tên thật.
	var hp_center: Vector2
	if moved:
		hp_center = center + UnitToken.HP_OFFSET
	else:
		hp_center = center + Vector2(-UnitToken.HP_OFFSET.x, UnitToken.HP_OFFSET.y)
	_add_label(str(hp), hp_center, HP_FONT_SIZE, Color(1.0, 1.0, 1.0, GHOST_ALPHA))


func _add_label(text: String, center: Vector2, font_size: int, color: Color) -> Label:
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
	return label


func _draw() -> void:
	for ghost: Dictionary in _ghosts:
		var pos: Vector2 = ghost.get("pos", Vector2.ZERO) as Vector2
		var faction: int = ghost.get("faction", Unit.Faction.NGUYEN) as int
		var color: Color = UnitToken.DAI_VIET_COLOR if faction == Unit.Faction.DAI_VIET else UnitToken.NGUYEN_COLOR
		color.a = GHOST_ALPHA
		draw_circle(pos + Vector2(0.0, -UnitToken.TOKEN_LIFT), UnitToken.RADIUS, color)
		draw_arc(pos + Vector2(0.0, -UnitToken.TOKEN_LIFT), UnitToken.RADIUS, 0.0, TAU, 32,
			Color(1.0, 1.0, 1.0, GHOST_ALPHA), 2.0)
	# Gạch chéo ô đỏ cũ chỉ khi sau lệnh không còn đòn nào trúng ô đó (một ô có thể chịu nhiều đòn).
	var still_hit: Dictionary = {} if _marks_state == null else TelegraphMarks.cells(_marks_state)
	for mark: Dictionary in _marks:
		var old_cell: Vector2i = Telegraph.NO_CELL
		match mark["kind"] as int:
			PreviewMarks.Kind.STRIKE_CANCELLED:
				old_cell = mark["cell"] as Vector2i
			PreviewMarks.Kind.STRIKE_MOVED:
				old_cell = mark["from_cell"] as Vector2i
				draw_rect(_top_rect(mark["cell"] as Vector2i).grow(-3.0), MOVED_STRIKE_COLOR, false, 3.0)
		if old_cell != Telegraph.NO_CELL and not still_hit.has(old_cell):
			_draw_cross(old_cell)


func _draw_cross(cell: Vector2i) -> void:
	var r: Rect2 = _top_rect(cell).grow(-8.0)
	draw_line(r.position, r.end, CROSS_COLOR, CROSS_WIDTH)
	draw_line(Vector2(r.end.x, r.position.y), Vector2(r.position.x, r.end.y), CROSS_COLOR, CROSS_WIDTH)


func _top_center(cell: Vector2i) -> Vector2:
	if _marks_state == null or not _marks_state.in_bounds(cell):
		return BoardView.cell_center(cell)
	return BoardView.top_center(cell, _marks_state.terrain_at(cell))


func _top_rect(cell: Vector2i) -> Rect2:
	var half: Vector2 = Vector2(BoardView.TILE_SIZE, BoardView.TILE_SIZE) / 2.0
	return Rect2(_top_center(cell) - half, half * 2.0)
