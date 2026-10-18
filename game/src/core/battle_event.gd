class_name BattleEvent
extends RefCounted
## Một sự kiện do Rules.resolve sinh ra. Phần hiển thị chỉ phát lại sự kiện, không đọc trạng thái sống.
## Loại sự kiện mới thêm ở story của nó. Trường chỉ gán trong _init (như Command).

enum Type {
	## Quân đi sang một ô kề (mỗi ô một sự kiện).
	MOVED,
	## Lệnh không hợp lệ: không có gì thay đổi, reason ghi lý do (cho dev và log, không qua tr()).
	REJECTED,
}

## Vì sao quân đổi ô. Đẩy, kéo thêm ở E2.
enum Cause { WALK }

var type: Type
var unit_id: int = 0
var from_cell: Vector2i = Vector2i.ZERO
var to_cell: Vector2i = Vector2i.ZERO
var cause: Cause = Cause.WALK
var reason: String = ""


func _init(p_type: Type, p_unit_id: int = 0, p_from: Vector2i = Vector2i.ZERO, p_to: Vector2i = Vector2i.ZERO,
		p_cause: Cause = Cause.WALK, p_reason: String = "") -> void:
	type = p_type
	unit_id = p_unit_id
	from_cell = p_from
	to_cell = p_to
	cause = p_cause
	reason = p_reason


static func moved(p_unit_id: int, p_from: Vector2i, p_to: Vector2i, p_cause: Cause) -> BattleEvent:
	return BattleEvent.new(Type.MOVED, p_unit_id, p_from, p_to, p_cause)


static func rejected(p_reason: String) -> BattleEvent:
	return BattleEvent.new(Type.REJECTED, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, p_reason)
