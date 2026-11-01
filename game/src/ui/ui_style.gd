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


static func reset_for_test() -> void:
	_button_styles = {}


## Khung bảng. content_margin < 0 thì lấy lề 9-slice. fallback dùng khi ENABLED = false.
static func panel(content_margin: float = -1.0, fallback: StyleBox = null) -> StyleBox:
	return _frame(PANEL_TEXTURE, PANEL_MARGIN, content_margin, fallback)


static func tooltip(content_margin: float = -1.0, fallback: StyleBox = null) -> StyleBox:
	return _frame(TOOLTIP_TEXTURE, TOOLTIP_MARGIN, content_margin, fallback)


static func button(state: int) -> StyleBoxTexture:
	if _button_styles.has(state):
		return _button_styles[state] as StyleBoxTexture
	var style: StyleBoxTexture = _texture_box(BUTTON_TEXTURES[state] as String, BUTTON_MARGIN)
	style.set_content_margin_all(BUTTON_CONTENT_MARGIN)
	_button_styles[state] = style
	return style


## Gắn đủ 4 trạng thái và bỏ viền focus (nút không nhận focus, xem Hud).
static func apply_button(target: Button) -> void:
	if not ENABLED:
		return
	target.add_theme_stylebox_override("normal", button(ButtonState.NORMAL))
	target.add_theme_stylebox_override("hover", button(ButtonState.HOVER))
	target.add_theme_stylebox_override("pressed", button(ButtonState.PRESSED))
	target.add_theme_stylebox_override("disabled", button(ButtonState.DISABLED))
	target.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


## Đường dẫn chân dung của tướng, "" nếu không phải tướng Đại Việt.
static func portrait_path(unit_type: int) -> String:
	return PORTRAITS.get(unit_type, "") as String


static func _frame(path: String, margin: float, content_margin: float, fallback: StyleBox) -> StyleBox:
	if not ENABLED and fallback != null:
		return fallback
	var style: StyleBoxTexture = _texture_box(path, margin)
	style.set_content_margin_all(margin if content_margin < 0.0 else content_margin)
	return style


static func _texture_box(path: String, margin: float) -> StyleBoxTexture:
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = Art.tex(path)
	style.set_texture_margin_all(margin)
	return style
