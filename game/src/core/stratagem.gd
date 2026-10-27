class_name Stratagem
extends RefCounted
## Mưu kế của Trần Hưng Đạo (Story 3.12). Mỗi mưu kế dùng 1 lần mỗi trận; file trận ghi mưu kế mở ("muu_ke_mo").
## Mưu kế mới thêm ở story của nó (Sát Thát: Story 3.13).

enum Kind { VUON_KHONG_NHA_TRONG }

## Tên trong file trận và kịch bản -> Kind, theo thứ tự phím (Q, W).
const NAMES: Dictionary = {
	"vuon_khong_nha_trong": Kind.VUON_KHONG_NHA_TRONG,
}


## Tên trong file của một Kind; "" nếu không có.
static func name_of(kind: int) -> String:
	var found: Variant = NAMES.find_key(kind)
	return found as String if found != null else ""


## Danh sách tên cho câu lỗi: '"vuon_khong_nha_trong"'.
static func name_list() -> String:
	var shown: PackedStringArray = PackedStringArray()
	for key: String in NAMES:
		shown.append('"%s"' % key)
	return ", ".join(shown)
