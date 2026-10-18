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
}

## Vì sao quân đổi ô. Đẩy, kéo thêm ở E2.
enum Cause { WALK }

## Vì sao lệnh bị từ chối (REJECTED). Kịch bản luật ghi bằng mã "tu_choi" (ScenarioRunner.REJECT_EVENTS).
enum Reject { NONE, NO_UNIT, NOT_GENERAL, ALREADY_THERE, UNREACHABLE, ALREADY_MOVED, NOTHING_TO_UNDO }

var type: Type
var unit_id: int = 0
var from_cell: Vector2i = Vector2i.ZERO
var to_cell: Vector2i = Vector2i.ZERO
var cause: Cause = Cause.WALK
var reject: Reject = Reject.NONE
var reason: String = ""
var round_number: int = 0


func _init(p_type: Type, p_unit_id: int = 0, p_from: Vector2i = Vector2i.ZERO, p_to: Vector2i = Vector2i.ZERO,
		p_cause: Cause = Cause.WALK, p_reject: Reject = Reject.NONE, p_reason: String = "", p_round: int = 0) -> void:
	type = p_type
	unit_id = p_unit_id
	from_cell = p_from
	to_cell = p_to
	cause = p_cause
	reject = p_reject
	reason = p_reason
	round_number = p_round


static func moved(p_unit_id: int, p_from: Vector2i, p_to: Vector2i, p_cause: Cause) -> BattleEvent:
	return BattleEvent.new(Type.MOVED, p_unit_id, p_from, p_to, p_cause)


static func rejected(p_reject: Reject, p_reason: String) -> BattleEvent:
	return BattleEvent.new(Type.REJECTED, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, p_reject, p_reason)


static func round_started(p_round: int) -> BattleEvent:
	return BattleEvent.new(Type.ROUND_STARTED, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, Reject.NONE, "", p_round)
