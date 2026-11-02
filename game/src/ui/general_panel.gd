class_name GeneralPanel
extends PanelContainer
## Bảng thông tin tướng ở cột phải (tác giả chốt 2026-11-02): bấm chọn tướng Đại Việt thì hiện chân dung, họ tên đủ,
## máu, tầm đi, đòn, tiểu sử ngắn có ghi nguồn và một dòng mẹo. Giữ nguyên tới khi chọn tướng khác. Chỉ hiển thị:
## không nhận chuột, không đọc trạng thái sống; con số lấy từ Stats (chi_so.json), chữ đi qua tr().

## UnitType -> phần tên khóa chữ (general.attack.<x>, general.bio.<x>, general.tip.<x>).
const KEYS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "tran_khanh_du",
}
const CONTENT_MARGIN: float = 8.0
const GAP: int = 4
const NAME_FONT_SIZE: int = 20
const BODY_FONT_SIZE: int = 15
const TEXT_FONT_SIZE: int = 14
## Màu dòng nguồn và mẹo: dịu hơn chữ chính, cùng tông nâu vàng với nhãn "Còn 1 lần" của Hud.
const TIP_COLOR: Color = Color(0.95, 0.82, 0.50)

var _type: int = -1
var _portrait: TextureRect
var _name_label: Label
var _hp_icon: TextureRect
var _hp_label: Label
var _move_label: Label
var _attack_label: Label
var _bio_label: Label
var _tip_label: Label


## width: bề rộng cả bảng (gồm viền). Nhãn tự xuống dòng cần bề rộng cố định thì mới đo đúng chiều cao.
func _init(width: float = 308.0) -> void:
	custom_minimum_size.x = width
	var text_width: float = width - CONTENT_MARGIN * 2.0
	var facts_width: float = text_width - UiStyle.PORTRAIT_SIZE - (GAP + 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.14, 0.13, 0.95)
	style.border_color = Color(0.67, 0.58, 0.48)
	style.set_border_width_all(2)
	style.set_content_margin_all(CONTENT_MARGIN)
	add_theme_stylebox_override("panel", UiStyle.panel(CONTENT_MARGIN, style))
	var box: VBoxContainer = _vbox(self)

	var head: HBoxContainer = HBoxContainer.new()
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_theme_constant_override("separation", GAP + 2)
	box.add_child(head)
	_portrait = TextureRect.new()
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.custom_minimum_size = Vector2(UiStyle.PORTRAIT_SIZE, UiStyle.PORTRAIT_SIZE)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.visible = UiStyle.ENABLED
	head.add_child(_portrait)
	var facts: VBoxContainer = _vbox(head)
	facts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	facts.add_theme_constant_override("separation", 2)
	_name_label = _label(facts, NAME_FONT_SIZE, facts_width)
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	var hp_row: HBoxContainer = HBoxContainer.new()
	hp_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_row.add_theme_constant_override("separation", 4)
	facts.add_child(hp_row)
	_hp_icon = TextureRect.new()
	_hp_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hp_icon.texture = Art.tex(UiStyle.ICON_HP)
	_hp_icon.custom_minimum_size = Vector2(UiStyle.ICON_SIZE, UiStyle.ICON_SIZE)
	_hp_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hp_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hp_icon.visible = UiStyle.ENABLED
	hp_row.add_child(_hp_icon)
	_hp_label = _label(hp_row, BODY_FONT_SIZE, facts_width - UiStyle.ICON_SIZE - 4)
	_move_label = _label(facts, BODY_FONT_SIZE, facts_width)
	_attack_label = _label(facts, TEXT_FONT_SIZE, facts_width)
	_bio_label = _label(box, TEXT_FONT_SIZE, text_width)
	_tip_label = _label(box, TEXT_FONT_SIZE, text_width)
	_tip_label.add_theme_color_override("font_color", TIP_COLOR)


## Hiện bảng của tướng unit_type với máu hiện tại; loại quân không phải tướng Đại Việt thì ẩn bảng.
func show_general(unit_type: int, hp: int, stats: Stats) -> void:
	if not KEYS.has(unit_type) or stats == null:
		hide_panel()
		return
	_type = unit_type
	var key: String = KEYS[unit_type] as String
	_portrait.texture = Art.tex(UiStyle.portrait_path(unit_type))
	_name_label.text = tr(Tooltip.UNIT_NAMES[unit_type] as String)
	_hp_label.text = tr("tooltip.hp") % [hp, stats.max_hp(unit_type)]
	_move_label.text = tr("general.move") % stats.move_range(unit_type)
	_attack_label.text = _attack_text(unit_type, stats)
	_bio_label.text = tr("general.bio." + key)
	_tip_label.text = tr("general.tip." + key)
	visible = true


func hide_panel() -> void:
	_type = -1
	visible = false


## Loại tướng đang hiện; -1 là bảng đang ẩn.
func shown_type() -> int:
	return _type if visible else -1


## Toàn bộ chữ trong bảng theo thứ tự đọc (để test).
func text() -> String:
	if not visible:
		return ""
	return "\n".join([_name_label.text, _hp_label.text, _move_label.text, _attack_label.text, _bio_label.text,
		_tip_label.text])


func portrait() -> Texture2D:
	return _portrait.texture if visible and _portrait.visible else null


## Đòn của từng tướng, số lấy từ chi_so.json (Dư: ô kề không kéo được là luật cố định, RulesAttack.PULL_MIN_RANGE).
func _attack_text(unit_type: int, stats: Stats) -> String:
	match unit_type:
		UnitType.NGUYEN_KHOAI:
			return tr("general.attack.nguyen_khoai") % [stats.damage(unit_type), stats.push_distance(unit_type)]
		UnitType.PHAM_NGU_LAO:
			return tr("general.attack.pham_ngu_lao") % [stats.min_range(unit_type), stats.max_range(unit_type),
				stats.damage(unit_type)]
		UnitType.TRAN_KHANH_DU:
			return tr("general.attack.tran_khanh_du") % [RulesAttack.PULL_MIN_RANGE, stats.pull_range(unit_type),
				stats.pull_distance(unit_type)]
	return ""


func _vbox(parent: Control) -> VBoxContainer:
	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", GAP)
	parent.add_child(box)
	return box


## Nhãn tự xuống dòng ở đúng bề rộng width (Label tự xuống dòng mà không có bề rộng thì đo chiều cao sai).
func _label(parent: Control, font_size: int, width: float) -> Label:
	var label: Label = Label.new()
	label.custom_minimum_size.x = width
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label
