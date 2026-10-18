class_name UnitToken
extends Node2D
## Đồng quân tròn có chữ, đứng trên ô bàn nghiêng, có bóng dưới chân, kèm chấm máu ở góc dưới phải.
## position là chân đồng: tâm mặt trên của ô (BoardView.cell_center, cộng độ cao bệ ô ải nếu có).
## Chỉ vẽ theo bản chụp, không giữ tham chiếu tới trạng thái đang sống.

const RADIUS: float = 26.0
## Tâm đồng cao hơn chân đồng. Đủ nhỏ để đồng không với tới tâm ô hàng xóm (BoardView.pick_cell).
const TOKEN_LIFT: float = 22.0
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.3)
const SHADOW_RADIUS: Vector2 = Vector2(24, 11)
const SHADOW_POINTS: int = 24
const BORDER_WIDTH: float = 3.0
const DAI_VIET_COLOR: Color = Color(0.70, 0.13, 0.13)
## Tướng đã đi trong lượt: đỏ xỉn, không dùng độ trong suốt (bóng mờ dành cho xem trước ở E2).
const DAI_VIET_MOVED_COLOR: Color = Color(0.55, 0.40, 0.38)
const DAI_VIET_TEXT_COLOR: Color = Color(1.0, 0.95, 0.80)
const NGUYEN_COLOR: Color = Color(0.17, 0.20, 0.28)
const NGUYEN_TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const NAME_FONT_SIZE: int = 16
const HP_RADIUS: float = 9.0
## Chấm máu, tính từ tâm đồng.
const HP_OFFSET: Vector2 = Vector2(19, 17)
const HP_BORDER_WIDTH: float = 1.5
const HP_COLOR: Color = Color(1.0, 1.0, 1.0)
const HP_TEXT_COLOR: Color = Color(0.12, 0.10, 0.08)
const HP_FONT_SIZE: int = 12

## UnitType -> khóa dịch của chữ trên đồng quân.
const NAME_KEYS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "unit.nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "unit.pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "unit.tran_khanh_du",
	UnitType.BO_BINH: "unit.bo_binh",
	UnitType.KY_BINH: "unit.ky_binh",
	UnitType.CUNG_KY: "unit.cung_ky",
}

var unit_id: int = 0
## UnitType. Đổi loại thì BoardView dựng đồng mới, không gọi update().
var unit_type: int = -1
## Ô đang đứng (để BoardView.pick_cell biết bấm trúng đồng là ô nào).
var cell: Vector2i = Vector2i.ZERO
var _faction: Unit.Faction = Unit.Faction.DAI_VIET
var _moved: bool = false
var _name_label: Label
var _hp_label: Label


## lift: mặt ô cao hơn mặt đất bao nhiêu (bệ ô ải).
func setup(unit: Unit, lift: float = 0.0) -> void:
	unit_id = unit.id
	unit_type = unit.type
	_faction = unit.faction
	var text_color: Color = DAI_VIET_TEXT_COLOR if _faction == Unit.Faction.DAI_VIET else NGUYEN_TEXT_COLOR

	var coin: Vector2 = Vector2(0, -TOKEN_LIFT)
	_name_label = _centered_label(Vector2(RADIUS * 2, RADIUS * 2), coin)
	_name_label.text = tr(NAME_KEYS[unit.type] as String)
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	_name_label.add_theme_color_override("font_color", text_color)

	_hp_label = _centered_label(Vector2(HP_RADIUS * 2, HP_RADIUS * 2), coin + HP_OFFSET)
	_hp_label.add_theme_font_size_override("font_size", HP_FONT_SIZE)
	_hp_label.add_theme_color_override("font_color", HP_TEXT_COLOR)
	update(unit, lift)


func update(unit: Unit, lift: float = 0.0) -> void:
	cell = unit.cell
	position = BoardView.cell_center(unit.cell) - Vector2(0, lift)
	_hp_label.text = str(unit.hp)
	if unit.has_moved != _moved:
		_moved = unit.has_moved
		queue_redraw()


func is_moved() -> bool:
	return _moved


func name_text() -> String:
	return _name_label.text


func hp_text() -> String:
	return _hp_label.text


## point tính từ chân đồng: có nằm trên mặt đồng không.
func hit(point: Vector2) -> bool:
	return point.distance_to(Vector2(0, -TOKEN_LIFT)) <= RADIUS


func _centered_label(box: Vector2, center: Vector2) -> Label:
	var label: Label = Label.new()
	label.size = box
	label.position = center - box / 2.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	return label


func _draw() -> void:
	var shadow: PackedVector2Array = PackedVector2Array()
	for i: int in range(SHADOW_POINTS):
		var angle: float = TAU * i / SHADOW_POINTS
		shadow.append(Vector2(cos(angle) * SHADOW_RADIUS.x, sin(angle) * SHADOW_RADIUS.y))
	draw_colored_polygon(shadow, SHADOW_COLOR)
	var coin: Vector2 = Vector2(0, -TOKEN_LIFT)
	draw_circle(coin, RADIUS, _fill_color())
	draw_circle(coin, RADIUS, BoardView.LINE_COLOR, false, BORDER_WIDTH, true)
	draw_circle(coin + HP_OFFSET, HP_RADIUS, HP_COLOR)
	draw_circle(coin + HP_OFFSET, HP_RADIUS, BoardView.LINE_COLOR, false, HP_BORDER_WIDTH, true)


## Story 2.1 thêm màu "đã đánh" ở đây.
func _fill_color() -> Color:
	if _faction == Unit.Faction.NGUYEN:
		return NGUYEN_COLOR
	return DAI_VIET_MOVED_COLOR if _moved else DAI_VIET_COLOR
