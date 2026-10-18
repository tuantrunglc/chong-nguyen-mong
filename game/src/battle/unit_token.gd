class_name UnitToken
extends Node2D
## Đồng quân tròn có chữ, kèm chấm máu ở góc dưới phải. Đặt ở tâm ô (BoardView.cell_center).
## Chỉ vẽ theo bản chụp, không giữ tham chiếu tới trạng thái đang sống.

const RADIUS: float = 34.0
const BORDER_WIDTH: float = 3.0
const DAI_VIET_COLOR: Color = Color(0.70, 0.13, 0.13)
const DAI_VIET_TEXT_COLOR: Color = Color(1.0, 0.95, 0.80)
const NGUYEN_COLOR: Color = Color(0.17, 0.20, 0.28)
const NGUYEN_TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const NAME_FONT_SIZE: int = 18
const HP_RADIUS: float = 11.0
const HP_OFFSET: Vector2 = Vector2(24, 24)
const HP_BORDER_WIDTH: float = 1.5
const HP_COLOR: Color = Color(1.0, 1.0, 1.0)
const HP_TEXT_COLOR: Color = Color(0.12, 0.10, 0.08)
const HP_FONT_SIZE: int = 14

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
var _faction: Unit.Faction = Unit.Faction.DAI_VIET
var _name_label: Label
var _hp_label: Label


func setup(unit: Unit) -> void:
	unit_id = unit.id
	_faction = unit.faction
	var text_color: Color = DAI_VIET_TEXT_COLOR if _faction == Unit.Faction.DAI_VIET else NGUYEN_TEXT_COLOR

	_name_label = _centered_label(Vector2(RADIUS * 2, RADIUS * 2), Vector2.ZERO)
	_name_label.text = tr(NAME_KEYS[unit.type] as String)
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	_name_label.add_theme_color_override("font_color", text_color)

	_hp_label = _centered_label(Vector2(HP_RADIUS * 2, HP_RADIUS * 2), HP_OFFSET)
	_hp_label.add_theme_font_size_override("font_size", HP_FONT_SIZE)
	_hp_label.add_theme_color_override("font_color", HP_TEXT_COLOR)
	update(unit)


func update(unit: Unit) -> void:
	position = BoardView.cell_center(unit.cell)
	_hp_label.text = str(unit.hp)


func name_text() -> String:
	return _name_label.text


func hp_text() -> String:
	return _hp_label.text


func _centered_label(box: Vector2, center: Vector2) -> Label:
	var label: Label = Label.new()
	label.size = box
	label.position = center - box / 2.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	return label


func _draw() -> void:
	var fill: Color = DAI_VIET_COLOR if _faction == Unit.Faction.DAI_VIET else NGUYEN_COLOR
	draw_circle(Vector2.ZERO, RADIUS, fill)
	draw_circle(Vector2.ZERO, RADIUS, BoardView.LINE_COLOR, false, BORDER_WIDTH, true)
	draw_circle(HP_OFFSET, HP_RADIUS, HP_COLOR)
	draw_circle(HP_OFFSET, HP_RADIUS, BoardView.LINE_COLOR, false, HP_BORDER_WIDTH, true)
