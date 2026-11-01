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
## Bề rộng tối đa của cả khung; chữ dài hơn thì Label tự xuống dòng.
const MAX_WIDTH: float = 340.0
## Lề trong của khung (StyleBox), trừ ra khi tính bề rộng cho Label.
const CONTENT_MARGIN: float = 8.0
## Chừa một chút cho dấu tiếng Việt và cho số đo của font khỏi cụt chữ.
const WIDTH_SLACK: float = 4.0
## Khoảng cách chân dung với chữ, và biểu tượng máu với chữ (px).
const PORTRAIT_GAP: float = 8.0
const ICON_GAP: float = 4.0

var _row: HBoxContainer
var _portrait: TextureRect
var _icon: TextureRect
var _label: Label
## Chữ gốc chưa ngắt dòng (text() trả lại đúng chữ này).
var _text: String = ""


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.05, 0.04, 0.92)
	style.border_color = Color(0.85, 0.70, 0.35, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(CONTENT_MARGIN)
	add_theme_stylebox_override("panel", UiStyle.tooltip(CONTENT_MARGIN, style))
	_row = HBoxContainer.new()
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_row.add_theme_constant_override("separation", int(PORTRAIT_GAP))
	add_child(_row)
	# Chân dung tướng (Story 8.5): chỉ hiện khi có.
	_portrait = TextureRect.new()
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.custom_minimum_size = Vector2(UiStyle.PORTRAIT_SIZE, UiStyle.PORTRAIT_SIZE)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_portrait.visible = false
	_row.add_child(_portrait)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Không dùng tự xuống dòng của Label: nó đo chiều cao theo bề rộng đang có (của lần hiện trước), nên khung cứ cao
	# như cột (đo thật: 164×589 px cho hai dòng chữ, 340×2101 px cho một dòng dài). Tự ngắt dòng ở _fit_width.
	_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_row.add_child(_label)
	# Biểu tượng máu đứng trước dòng "Máu" (Story 8.5); đặt theo dòng ở _fit_width.
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.texture = Art.tex(UiStyle.ICON_HP)
	_icon.custom_minimum_size = Vector2(UiStyle.ICON_SIZE, UiStyle.ICON_SIZE)
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.visible = false
	_label.add_child(_icon)


## Hiện khung với nội dung mới; khung tự đo lại kích thước và bám con trỏ.
## portrait: chân dung bên trái (tướng Đại Việt), null thì ẩn. icon_line: số thứ tự dòng (đếm theo dòng nguồn, từ 0)
## được đặt biểu tượng máu đứng trước, -1 là không có.
func show_text(text: String, portrait: Texture2D = null, icon_line: int = -1) -> void:
	if text.is_empty():
		hide_tooltip()
		return
	_text = text
	_portrait.texture = portrait
	_portrait.visible = portrait != null and UiStyle.ENABLED
	visible = true
	_fit_width(text, icon_line)
	reset_size()
	var viewport: Viewport = get_viewport()
	place_at(viewport.get_mouse_position() if viewport != null else Vector2.ZERO)


## Ngắt dòng theo từ cho vừa MAX_WIDTH rồi cho Label bề rộng bằng dòng dài nhất. Dòng icon_line chừa chỗ cho biểu tượng.
func _fit_width(text: String, icon_line: int = -1) -> void:
	_icon.visible = false
	var font: Font = _label.get_theme_font("font")
	if font == null:
		_label.text = text
		return
	var font_size: int = _label.get_theme_font_size("font_size")
	var room: float = MAX_WIDTH - CONTENT_MARGIN * 2.0
	if _portrait.visible:
		room -= UiStyle.PORTRAIT_SIZE + PORTRAIT_GAP
	var lines: PackedStringArray = PackedStringArray()
	var widest: float = 0.0
	var icon_row: int = -1
	var source_index: int = 0
	for source: String in text.split("\n"):
		var indent: String = ""
		if source_index == icon_line and UiStyle.ENABLED:
			icon_row = lines.size()
			# Chừa chỗ biểu tượng bằng dấu cách (chữ gốc vẫn giữ nguyên ở _text). Mọi dòng ngắt của dòng nguồn này
			# giữ cùng thụt lề cho thẳng cột.
			var space: float = maxf(font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x, 1.0)
			indent = " ".repeat(int(ceil((UiStyle.ICON_SIZE + ICON_GAP) / space)))
		var current: String = ""
		for word: String in source.split(" "):
			var trial: String = word if current.is_empty() else current + " " + word
			if not current.is_empty() and font.get_string_size(indent + trial, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
				lines.append(indent + current)
				widest = maxf(widest, font.get_string_size(indent + current, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
				current = word
			else:
				current = trial
		lines.append(indent + current)
		widest = maxf(widest, font.get_string_size(indent + current, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		source_index += 1
	_label.text = "\n".join(lines)
	_label.custom_minimum_size = Vector2(minf(widest + WIDTH_SLACK, room), 0.0)
	if icon_row >= 0:
		var line_height: float = font.get_height(font_size)
		var step: float = line_height + _label.get_theme_constant("line_spacing")
		_icon.position = Vector2(0.0, icon_row * step + (line_height - UiStyle.ICON_SIZE) / 2.0)
		_icon.size = Vector2(UiStyle.ICON_SIZE, UiStyle.ICON_SIZE)
		_icon.visible = true


func hide_tooltip() -> void:
	visible = false
	_text = ""
	_label.text = ""
	_portrait.visible = false
	_icon.visible = false


## Chân dung đang hiện (để test).
func portrait_visible() -> bool:
	return _portrait.visible


func icon_visible() -> bool:
	return _icon.visible


## Đặt khung cạnh điểm neo, lật sang trái/trên khi sát mép màn hình.
func place_at(anchor: Vector2) -> void:
	if get_viewport() == null:
		position = anchor + CURSOR_OFFSET
		return
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
	return _text


## Đang hiện và có chữ (để test).
func visible_now() -> bool:
	return visible and not text().is_empty()
