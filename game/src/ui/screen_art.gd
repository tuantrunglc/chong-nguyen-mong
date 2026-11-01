class_name ScreenArt
extends RefCounted
## Hình của màn hình chính và màn chuyển trận (Story 8.6). Đường dẫn hình và bảng "trận nào dùng tranh nào" nằm ở đây
## để tác giả đổi ở một chỗ. Tranh 640×360 phóng đúng ×2 ra cửa sổ 1280×720 (lọc Nearest, không nhòe).
## Hình nạp qua Art.tex() (thiếu thì ô hồng và một dòng ERROR).

const SCALE: int = 2
const MENU_BACKGROUND: String = "man_hinh/tex_nen_man_hinh.png"
const LOGO: String = "man_hinh/tex_logo_hao_khi_dong_a.png"
const TRANSITION_BINH_THAN: String = "man_hinh/tex_chuyen_tran_hoi_nghi_binh_than.png"
const TRANSITION_VAN_KIEP: String = "man_hinh/tex_chuyen_tran_luy_ai_van_kiep.png"
const TRANSITION_BACH_DANG: String = "man_hinh/tex_chuyen_tran_thuy_chien_bach_dang.png"
## Id trận sắp vào -> tranh chuyển trận. Id lạ (trận thêm sau) dùng TRANSITION_DEFAULT.
const TRANSITIONS: Dictionary = {
	"tran_02": TRANSITION_BINH_THAN,
	"tran_03": TRANSITION_VAN_KIEP,
	"tran_04": TRANSITION_VAN_KIEP,
	"tran_05": TRANSITION_VAN_KIEP,
	"tran_06": TRANSITION_BACH_DANG,
}
const TRANSITION_DEFAULT: String = TRANSITION_VAN_KIEP
## Nền phẳng khi UiStyle.ENABLED = false hoặc chưa có tranh.
const FALLBACK_COLOR: Color = Color(0.16, 0.11, 0.08)


## Tranh chuyển trận cho trận sắp vào.
static func transition_for(level_id: String) -> String:
	return TRANSITIONS.get(level_id, TRANSITION_DEFAULT) as String


## Tranh của màn "Đã thắng cả chiến dịch".
static func campaign_end() -> String:
	return TRANSITION_BACH_DANG


## Vẽ nền phủ kín `size` lên canvas (gọi trong _draw của node đó).
static func draw_backdrop(canvas: CanvasItem, path: String, size: Vector2) -> void:
	if not UiStyle.ENABLED or path.is_empty():
		canvas.draw_rect(Rect2(Vector2.ZERO, size), FALLBACK_COLOR)
		return
	canvas.draw_texture_rect(Art.tex(path), Rect2(Vector2.ZERO, size), false)
