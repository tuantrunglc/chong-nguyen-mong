class_name BattleEvent
extends RefCounted
## Một sự kiện do Rules.resolve sinh ra. Phần hiển thị chỉ phát lại sự kiện, không đọc trạng thái sống.
## Loại sự kiện mới thêm ở story của nó. Trường chỉ gán trong _init (như Command).

enum Type {
	## Quân đi sang một ô kề (mỗi ô một sự kiện).
	MOVED,
	## Lệnh không hợp lệ: không có gì thay đổi, reason ghi lý do (cho dev và log, không qua tr()).
	REJECTED,
	## Sang hiệp mới; round_number là số hiệp mới.
	ROUND_STARTED,
	## Mất máu: amount là số máu đã trừ thật (quân 1 máu trúng 2 thì amount = 1).
	DAMAGED,
	## Gục và bị nhấc khỏi bàn; from_cell là ô lúc gục.
	DIED,
	## Bị đẩy va vào vật ở to_cell: other_id là quân bị va, 0 nếu là mép bàn hoặc vật cản.
	COLLIDED,
	## Quân Nguyên vào ô sông to_cell và chết đuối (bị nhấc khỏi bàn).
	DROWNED,
	## Tướng unit_id ra đòn vào ô to_cell: ô bị đánh (Khoái), ô quân trúng lao (Lão; có thể khác ô được bấm).
	ATTACKED,
}

## Vì sao quân đổi ô hoặc mất máu. STRIKE: đòn có sát thương của tướng (Khoái, Lão). Kéo thêm ở Story 2.4.
enum Cause { WALK, STRIKE, PUSH, COLLISION }

## Vì sao lệnh bị từ chối (REJECTED). Kịch bản luật ghi bằng mã "tu_choi" (ScenarioRunner.REJECT_EVENTS).
enum Reject {
	NONE, NO_UNIT, NOT_GENERAL, ALREADY_THERE, UNREACHABLE, ALREADY_MOVED, NOTHING_TO_UNDO,
	ALREADY_ATTACKED, NOT_ADJACENT, NO_TARGET, NOT_IN_RANGE,
}

var type: Type
var unit_id: int = 0
var from_cell: Vector2i = Vector2i.ZERO
var to_cell: Vector2i = Vector2i.ZERO
var cause: Cause = Cause.WALK
var reject: Reject = Reject.NONE
var reason: String = ""
var round_number: int = 0
var amount: int = 0
var other_id: int = 0


func _init(p_type: Type, p_unit_id: int = 0, p_from: Vector2i = Vector2i.ZERO, p_to: Vector2i = Vector2i.ZERO,
		p_cause: Cause = Cause.WALK, p_reject: Reject = Reject.NONE, p_reason: String = "", p_round: int = 0,
		p_amount: int = 0, p_other_id: int = 0) -> void:
	type = p_type
	unit_id = p_unit_id
	from_cell = p_from
	to_cell = p_to
	cause = p_cause
	reject = p_reject
	reason = p_reason
	round_number = p_round
	amount = p_amount
	other_id = p_other_id


static func moved(p_unit_id: int, p_from: Vector2i, p_to: Vector2i, p_cause: Cause) -> BattleEvent:
	return BattleEvent.new(Type.MOVED, p_unit_id, p_from, p_to, p_cause)


static func rejected(p_reject: Reject, p_reason: String) -> BattleEvent:
	return BattleEvent.new(Type.REJECTED, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, p_reject, p_reason)


static func round_started(p_round: int) -> BattleEvent:
	return BattleEvent.new(Type.ROUND_STARTED, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, Reject.NONE, "", p_round)


static func damaged(p_unit_id: int, p_amount: int, p_cause: Cause) -> BattleEvent:
	return BattleEvent.new(Type.DAMAGED, p_unit_id, Vector2i.ZERO, Vector2i.ZERO, p_cause, Reject.NONE, "", 0,
		p_amount)


static func died(p_unit_id: int, p_cell: Vector2i) -> BattleEvent:
	return BattleEvent.new(Type.DIED, p_unit_id, p_cell)


static func collided(p_unit_id: int, p_other_id: int, p_cell: Vector2i) -> BattleEvent:
	return BattleEvent.new(Type.COLLIDED, p_unit_id, Vector2i.ZERO, p_cell, Cause.COLLISION, Reject.NONE, "", 0, 0,
		p_other_id)


static func drowned(p_unit_id: int, p_cell: Vector2i) -> BattleEvent:
	return BattleEvent.new(Type.DROWNED, p_unit_id, Vector2i.ZERO, p_cell)


static func attacked(p_unit_id: int, p_cell: Vector2i) -> BattleEvent:
	return BattleEvent.new(Type.ATTACKED, p_unit_id, Vector2i.ZERO, p_cell, Cause.STRIKE)
