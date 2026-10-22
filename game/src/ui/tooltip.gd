class_name Tooltip
extends PanelContainer
## Khung thông tin khi rê chuột (Story 2.10, FR40): tên quân, máu, đòn sắp đánh và số thứ tự; hoặc tên địa hình
## và hiệu ứng. Chỉ hiển thị: không nhận chuột (bấm xuyên qua), không đọc trạng thái sống, không biết luật.
## Dựng bằng code, không cần mở editor.

## Tên đầy đủ của từng loại quân (token chỉ có chữ cái tắt).
const UNIT_NAMES: Dictionary = {
	UnitType.NGUYEN_KHOAI: "unit.full.nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "unit.full.pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "unit.full.tran_khanh_du",
	UnitType.BO_BINH: "unit.full.bo_binh",
	UnitType.KY_BINH: "unit.full.ky_binh",
	UnitType.CUNG_KY: "unit.full.cung_ky",
}
const TERRAIN_NAMES: Dictionary = {
	Terrain.PLAIN: "terrain.plain",
	Terrain.RIVER: "terrain.river",
	Terrain.FOREST: "terrain.forest",
	Terrain.SPIKES: "terrain.spikes",
	Terrain.GRANARY: "terrain.granary",
	Terrain.VILLAGE: "terrain.village",
	Terrain.PASS: "terrain.pass",
}
const TERRAIN_EFFECTS: Dictionary = {
	Terrain.PLAIN: "terrain.effect.plain",
	Terrain.RIVER: "terrain.effect.river",
	Terrain.FOREST: "terrain.effect.forest",
	Terrain.SPIKES: "terrain.effect.spikes",
	Terrain.GRANARY: "terrain.effect.granary",
	Terrain.VILLAGE: "terrain.effect.village",
	Terrain.PASS: "terrain.effect.pass",
}
## Hướng xung phong -> tên hướng; dùng chung chữ với công cụ duyệt kịch bản.
const DIRECTION_NAMES: Dictionary = {
	Vector2i(0, -1): "scenario.viewer.direction_B",
	Vector2i(1, 0): "scenario.viewer.direction_D",
	Vector2i(0, 1): "scenario.viewer.direction_N",
	Vector2i(-1, 0): "scenario.viewer.direction_T",
}

## Cách con trỏ một khoảng để không che ô đang trỏ.
const CURSOR_OFFSET: Vector2 = Vector2(18, 14)
## Chừa mép màn hình.
const SCREEN_MARGIN: float = 8.0
const MAX_WIDTH: float = 340.0

var _label: Label


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.04, 0.92)
	style.border_color = Color(0.85, 0.70, 0.35, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_label)


## Hiện khung với nội dung mới; khung tự đo lại kích thước và bám con trỏ.
func show_text(text: String) -> void:
	if text.is_empty():
		hide_tooltip()
		return
	_label.text = text
	visible = true
	reset_size()
	place_at(get_viewport().get_mouse_position())


func hide_tooltip() -> void:
	visible = false
	_label.text = ""


## Đặt khung cạnh điểm neo, lật sang trái/trên khi sát mép màn hình.
func place_at(anchor: Vector2) -> void:
	var screen: Vector2 = get_viewport_rect().size
	var pos: Vector2 = anchor + CURSOR_OFFSET
	if pos.x + size.x > screen.x - SCREEN_MARGIN:
		pos.x = anchor.x - size.x - CURSOR_OFFSET.x
	if pos.y + size.y > screen.y - SCREEN_MARGIN:
		pos.y = anchor.y - size.y - CURSOR_OFFSET.y
	pos.x = clampf(pos.x, SCREEN_MARGIN, maxf(SCREEN_MARGIN, screen.x - size.x - SCREEN_MARGIN))
	pos.y = clampf(pos.y, SCREEN_MARGIN, maxf(SCREEN_MARGIN, screen.y - size.y - SCREEN_MARGIN))
	position = pos


## Nội dung đang hiện (để test).
func text() -> String:
	return _label.text if _label != null else ""


## Đang hiện và có chữ (để test).
func visible_now() -> bool:
	return visible and not text().is_empty()
