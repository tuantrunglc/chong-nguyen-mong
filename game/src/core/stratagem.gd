class_name Stratagem
extends RefCounted
## Mưu kế của Trần Hưng Đạo (Story 3.12). Mỗi mưu kế dùng 1 lần mỗi trận; file trận ghi mưu kế mở ("muu_ke_mo").
## Mưu kế mới thêm ở story của nó (Sát Thát: Story 3.13).

enum Kind { VUON_KHONG_NHA_TRONG }

## Tên trong file trận và kịch bản -> Kind, theo thứ tự phím (Q, W).
const NAMES: Dictionary = {
	"vuon_khong_nha_trong": Kind.VUON_KHONG_NHA_TRONG,
}

## Ô mưu kế theo thứ tự phím: [Kind, action trong InputMap, phím vật lý] (tác giả chốt 2026-10-27). BattleInput khai
## báo phím từ bảng này, HUD xếp nút theo thứ tự này (không theo thứ tự "muu_ke_mo"). Sát Thát (Story 3.13) thêm
## [Kind.SAT_THAT, "stratagem_2", KEY_W].
const SLOTS: Array = [
	[Kind.VUON_KHONG_NHA_TRONG, "stratagem_1", KEY_Q],
]


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


## Các Kind trong kinds, xếp theo thứ tự phím (SLOTS).
static func in_key_order(kinds: Array[int]) -> Array[int]:
	var ordered: Array[int] = []
	for slot: Array in SLOTS:
		if kinds.has(slot[0] as int):
			ordered.append(slot[0] as int)
	return ordered
