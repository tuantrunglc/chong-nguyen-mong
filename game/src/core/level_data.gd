class_name LevelData
extends RefCounted
## Một trận đã nạp từ data/tran/*.json. Chỉ đọc: LevelLoader tạo, BattleState sẽ dựng từ đây.

enum Mission { ELIMINATE, HOLD_PASS }


## Một quân đặt sẵn trên bàn lúc bắt đầu trận.
class UnitPlacement:
	extends RefCounted

	var type: int
	var cell: Vector2i

	func _init(p_type: int, p_cell: Vector2i) -> void:
		type = p_type
		cell = p_cell


var format_version: int = 0
var name: String = ""
var mission: Mission = Mission.ELIMINATE
var size: Vector2i = Vector2i.ZERO
## Theo hàng: index = hang * size.x + cot.
var terrain: PackedInt32Array = PackedInt32Array()
## Tướng theo ký hiệu 1, 2, 3; rồi quân Nguyên theo thu_tu_dich.
var units: Array[UnitPlacement] = []


func terrain_at(cell: Vector2i) -> int:
	return terrain[cell.y * size.x + cell.x]
