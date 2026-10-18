class_name Effects
extends RefCounted
## Nơi duy nhất được đổi vị trí (và sau này máu) của quân. check_boundaries.sh chỉ miễn file này.


## Đặt quân vào ô kề to_cell và ghi sự kiện MOVED. Hiệu ứng của ô vừa vào (hầm chông) thêm ở Story 3.4.
static func move(state: BattleState, unit: Unit, to_cell: Vector2i, cause: BattleEvent.Cause,
		events: Array[BattleEvent]) -> void:
	var from_cell: Vector2i = unit.cell
	unit.cell = to_cell
	events.append(BattleEvent.moved(unit.id, from_cell, to_cell, cause))
