class_name UnitType
extends RefCounted
## Loại quân. Enum không tên để viết được UnitType.NGUYEN_KHOAI, theo bảng đặt tên của kiến trúc.

enum { NGUYEN_KHOAI, PHAM_NGU_LAO, TRAN_KHANH_DU, BO_BINH, KY_BINH, CUNG_KY }

const GENERALS: Array[int] = [NGUYEN_KHOAI, PHAM_NGU_LAO, TRAN_KHANH_DU]
const ENEMIES: Array[int] = [BO_BINH, KY_BINH, CUNG_KY]


static func is_general(type: int) -> bool:
	return GENERALS.has(type)


static func is_enemy(type: int) -> bool:
	return ENEMIES.has(type)
