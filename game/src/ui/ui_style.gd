class_name UiStyle
extends RefCounted
## Kiểu giao diện bằng hình (Story 8.5): khung 9-slice, nút 4 trạng thái, biểu tượng, chân dung. Mọi đường dẫn hình
## giao diện nằm ở đây để tác giả thay hình ở một chỗ. Hình nạp qua Art.tex() (thiếu thì ô hồng và một dòng ERROR).

## Đặt false để quay về khung phẳng cũ (StyleBoxFlat) mà không xóa code.
const ENABLED: bool = true

enum ButtonState { NORMAL, HOVER, PRESSED, DISABLED }

const PANEL_TEXTURE: String = "giao_dien/tex_khung_bang_48x48.png"
## Lề 9-slice đo trên ảnh: viền 3 px cộng góc trang trí.
const PANEL_MARGIN: float = 8.0
const TOOLTIP_TEXTURE: String = "giao_dien/tex_khung_tooltip_32x32.png"
const TOOLTIP_MARGIN: float = 6.0
const BUTTON_TEXTURES: Dictionary = {
	ButtonState.NORMAL: "giao_dien/tex_nut_9slice_normal.png",
	ButtonState.HOVER: "giao_dien/tex_nut_9slice_hover.png",
	ButtonState.PRESSED: "giao_dien/tex_nut_9slice_pressed.png",
	ButtonState.DISABLED: "giao_dien/tex_nut_9slice_disabled.png",
}
## Nút 32×24 có viền 2 px; lề 4 giữ nguyên góc.
const BUTTON_MARGIN: float = 4.0
## Lề trong của nút (chữ cách viền).
const BUTTON_CONTENT_MARGIN: float = 8.0
## Màu chữ nút theo trạng thái: sáng trên nền nút tối; nút mờ dịu hơn hẳn để thấy là không bấm được.
const BUTTON_FONT_COLORS: Dictionary = {
	"font_color": Color(0.96, 0.90, 0.74),
	"font_hover_color": Color(1.0, 0.96, 0.80),
	"font_focus_color": Color(0.96, 0.90, 0.74),
	"font_pressed_color": Color(0.85, 0.76, 0.56),
	"font_hover_pressed_color": Color(0.85, 0.76, 0.56),
	"font_disabled_color": Color(0.58, 0.53, 0.46),
}

const ICON_ROUND: String = "giao_dien/tex_hiep_24x24.png"
const ICON_HP: String = "giao_dien/tex_icon_mau.png"
const ICON_MORALE: String = "giao_dien/tex_icon_long_dan.png"
const ICON_SIZE: float = 24.0
## Stratagem.Kind -> biểu tượng 32×32 trên nút mưu kế.
const STRATAGEM_ICONS: Dictionary = {
	Stratagem.Kind.VUON_KHONG_NHA_TRONG: "giao_dien/tex_ke_vuon_khong_nha_trong.png",
	Stratagem.Kind.SAT_THAT: "giao_dien/tex_ke_sat_that.png",
}
## LevelData.Mission -> biểu tượng nhiệm vụ 24×24 và khóa chữ.
const MISSION_ICONS: Dictionary = {
	LevelData.Mission.ELIMINATE: "giao_dien/tex_nhiem_vu_tieu_diet_24x24.png",
	LevelData.Mission.HOLD_PASS: "giao_dien/tex_nhiem_vu_giu_ai_24x24.png",
}
## Bản 32×32 của biểu tượng nhiệm vụ, dùng ở màn chuyển trận (Story 8.6).
const MISSION_ICONS_LARGE: Dictionary = {
	LevelData.Mission.ELIMINATE: "giao_dien/tex_nhiem_vu_tieu_diet_32x32.png",
	LevelData.Mission.HOLD_PASS: "giao_dien/tex_nhiem_vu_giu_ai_32x32.png",
}
const MISSION_ICON_LARGE_SIZE: float = 32.0
const MISSION_KEYS: Dictionary = {
	LevelData.Mission.ELIMINATE: "hud.mission.eliminate",
	LevelData.Mission.HOLD_PASS: "hud.mission.hold_pass",
}
## UnitType của ba tướng -> chân dung 96×96 (bản không khung).
const PORTRAITS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "chan_dung/tex_chan_dung_khoai.png",
	UnitType.PHAM_NGU_LAO: "chan_dung/tex_chan_dung_lao.png",
	UnitType.TRAN_KHANH_DU: "chan_dung/tex_chan_dung_du.png",
}
const PORTRAIT_SIZE: float = 96.0

static var _button_styles: Dictionary = {}
static var _primary_button_styles: Dictionary = {}
## Khung mẫu dựng một lần theo (đường dẫn, lề hình, lề trong); mỗi lần gọi trả bản sao để người dùng đổi lề riêng.
static var _frame_templates: Dictionary = {}


static func reset_for_test() -> void:
	_button_styles = {}
	_primary_button_styles = {}
	_frame_templates = {}


## Khung bảng. content_margin < 0 thì lấy lề 9-slice. fallback dùng khi ENABLED = false.
static func panel(content_margin: float = -1.0, fallback: StyleBox = null) -> StyleBox:
	return _frame(PANEL_TEXTURE, PANEL_MARGIN, content_margin, fallback)


static func tooltip(content_margin: float = -1.0, fallback: StyleBox = null) -> StyleBox:
	return _frame(TOOLTIP_TEXTURE, TOOLTIP_MARGIN, content_margin, fallback)


## Tạo khung chú thích tùy biến đồng bộ mỹ thuật Đông A cho các Control có tooltip_text.
static func create_custom_tooltip(for_text: String, width: float = 280.0) -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", tooltip(8.0))
	var label: Label = Label.new()
	label.text = for_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(width, 0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.96, 0.94, 0.90))
	label.add_theme_color_override("font_shadow_color", Color(0.06, 0.04, 0.03, 0.85))
	label.add_theme_constant_override("shadow_offset_y", 1)
	panel.add_child(label)
	return panel


static func button(state: int) -> StyleBoxTexture:
	if not BUTTON_TEXTURES.has(state):
		state = ButtonState.NORMAL
	if _button_styles.has(state):
		return _button_styles[state] as StyleBoxTexture
	var style: StyleBoxTexture = _texture_box(BUTTON_TEXTURES[state] as String, BUTTON_MARGIN)
	style.set_content_margin_all(BUTTON_CONTENT_MARGIN)
	_button_styles[state] = style
	return style


## Gắn đủ 4 trạng thái và bỏ viền focus (nút không nhận focus, xem Hud).
static func apply_button(target: Button) -> void:
	# Tiếng rê và bấm nút (Story 8.7), không phụ thuộc công tắc ENABLED; nút đang mờ thì im.
	if not target.has_meta("sound_wired"):
		target.set_meta("sound_wired", true)
		target.mouse_entered.connect(func() -> void:
			if not target.disabled:
				Sound.ui_hover())
		target.pressed.connect(Sound.ui_click)
	if not ENABLED:
		return
	target.add_theme_stylebox_override("normal", button(ButtonState.NORMAL))
	target.add_theme_stylebox_override("hover", button(ButtonState.HOVER))
	target.add_theme_stylebox_override("pressed", button(ButtonState.PRESSED))
	target.add_theme_stylebox_override("disabled", button(ButtonState.DISABLED))
	target.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for color_name: String in BUTTON_FONT_COLORS:
		target.add_theme_color_override(color_name, BUTTON_FONT_COLORS[color_name] as Color)


static func primary_button(state: int) -> StyleBoxTexture:
	if not BUTTON_TEXTURES.has(state):
		state = ButtonState.NORMAL
	if _primary_button_styles.has(state):
		return _primary_button_styles[state] as StyleBoxTexture
	var style: StyleBoxTexture = _texture_box(BUTTON_TEXTURES[state] as String, BUTTON_MARGIN)
	style.set_content_margin_all(BUTTON_CONTENT_MARGIN)
	match state:
		ButtonState.NORMAL:
			style.modulate_color = Color(1.35, 1.15, 0.75)
		ButtonState.HOVER:
			style.modulate_color = Color(1.50, 1.35, 0.90)
		ButtonState.PRESSED:
			style.modulate_color = Color(1.10, 0.95, 0.65)
		ButtonState.DISABLED:
			style.modulate_color = Color(0.80, 0.75, 0.70)
	_primary_button_styles[state] = style
	return style


## Gắn kiểu nút chính nổi bật (Kết thúc lượt).
static func apply_primary_button(target: Button) -> void:
	apply_button(target)
	if not ENABLED:
		return
	target.add_theme_stylebox_override("normal", primary_button(ButtonState.NORMAL))
	target.add_theme_stylebox_override("hover", primary_button(ButtonState.HOVER))
	target.add_theme_stylebox_override("pressed", primary_button(ButtonState.PRESSED))
	target.add_theme_stylebox_override("disabled", primary_button(ButtonState.DISABLED))
	target.add_theme_color_override("font_color", Color(1.0, 0.98, 0.88))
	target.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	target.add_theme_font_size_override("font_size", 17)


## Đường dẫn chân dung của tướng, "" nếu không phải tướng Đại Việt.
static func portrait_path(unit_type: int) -> String:
	return PORTRAITS.get(unit_type, "") as String


static func _frame(path: String, margin: float, content_margin: float, fallback: StyleBox) -> StyleBox:
	if not ENABLED and fallback != null:
		return fallback
	var key: String = "%s|%s|%s" % [path, margin, content_margin]
	if not _frame_templates.has(key):
		var template: StyleBoxTexture = _texture_box(path, margin)
		template.set_content_margin_all(margin if content_margin < 0.0 else content_margin)
		_frame_templates[key] = template
	return (_frame_templates[key] as StyleBoxTexture).duplicate() as StyleBoxTexture


static func _texture_box(path: String, margin: float) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = Art.tex(path)
	style.set_texture_margin_all(margin)
	return style
