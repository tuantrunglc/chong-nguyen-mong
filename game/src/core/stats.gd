class_name Stats
extends RefCounted
## Chỉ số đã nạp từ data/chi_so.json. Chỉ đọc: StatsLoader tạo, lõi luật chỉ hỏi.
## Khóa giữ nguyên tên trong file (mau, tam_di, sat_thuong...). Hàm đòn thêm ở E2 khi dùng.

## UnitType -> { khóa: int }
var _values: Dictionary = {}


func _init(values: Dictionary) -> void:
	_values = values.duplicate(true)


## Bộ nạp đã kiểm đủ khóa, nên khóa thiếu ở đây là lỗi lập trình; trả 0.
func value(type: int, key: String) -> int:
	var unit: Dictionary = _values.get(type, {}) as Dictionary
	return int(unit.get(key, 0))


func max_hp(type: int) -> int:
	return value(type, "mau")


func move_range(type: int) -> int:
	return value(type, "tam_di")
