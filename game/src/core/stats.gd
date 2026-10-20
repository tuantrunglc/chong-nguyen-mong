class_name Stats
extends RefCounted
## Chỉ số đã nạp từ data/chi_so.json. Chỉ đọc: StatsLoader tạo, lõi luật chỉ hỏi.
## Khóa giữ nguyên tên trong file (mau, tam_di, sat_thuong...). Hàm đòn thêm ở story dùng nó.

## UnitType -> { khóa: int }
var _values: Dictionary = {}


func _init(values: Dictionary) -> void:
	_values = values.duplicate(true)


## Bộ nạp đã kiểm đủ khóa, nên khóa thiếu ở đây là lỗi lập trình (gõ sai tên khóa): assert, bản build trả 0.
func value(type: int, key: String) -> int:
	var unit: Dictionary = _values.get(type, {}) as Dictionary
	assert(unit.has(key), "chỉ số thiếu khóa %s của loại quân %d" % [key, type])
	return int(unit.get(key, 0))


func max_hp(type: int) -> int:
	return value(type, "mau")


func move_range(type: int) -> int:
	return value(type, "tam_di")


func damage(type: int) -> int:
	return value(type, "sat_thuong")


func push_distance(type: int) -> int:
	return value(type, "do_day")


## Tầm lao của Phạm Ngũ Lão: ô gần nhất và xa nhất lao trúng được (tính từ tướng).
func min_range(type: int) -> int:
	return value(type, "tam_danh_gan")


func max_range(type: int) -> int:
	return value(type, "tam_danh_xa")


## Tầm kéo của Trần Khánh Dư: vật đầu tiên trên hàng trong vòng này mới kéo được (ô kề không kéo, xem RulesAttack).
func pull_range(type: int) -> int:
	return value(type, "tam_danh")


## Số ô quân Nguyên bị kéo về phía Dư (dừng sớm nếu bị chặn).
func pull_distance(type: int) -> int:
	return value(type, "tam_keo")
