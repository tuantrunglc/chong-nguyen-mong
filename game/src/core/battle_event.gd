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
	## Quân unit_id ra đòn vào ô to_cell. Tướng: ô bị đánh (Khoái), ô quân trúng lao (Lão; có thể khác ô được bấm),
	## ô quân bị kéo trước khi kéo (Dư). Quân Nguyên (Story 2.8): from_cell là ô nó đứng, to_cell là ô trúng
	## (TelegraphMarks.hit_cell; Kỵ binh trượt thì ô sát mép), cause ENEMY_STRIKE.
	ATTACKED,
	## Hết trận: quân Nguyên cuối gục (thắng). Chỉ RulesVictory sinh, luôn là sự kiện cuối của lệnh (Story 2.5).
	VICTORY,
	## Hết trận: mọi tướng trên bàn đã gục (thua).
	DEFEAT,
	## Quân Nguyên unit_id báo đòn (Story 2.6): from_cell là ô nó đứng; to_cell là ô bị nhắm (đòn vào ô) hoặc ô ngay
	## trước mặt theo hướng xung phong (Kỵ binh); amount là số thứ tự ra đòn.
	TELEGRAPHED,
	## Đòn đã báo bị hủy, phát đúng chỗ nó đáng lẽ ra đòn (Story 2.9): unit_id là chủ đòn, from_cell là ô chủ đòn
	## lúc hủy (ZERO nếu chủ đã gục), amount là số thứ tự, cancel là lý do. Không kèm ATTACKED.
	TELEGRAPH_CANCELLED,
	## Làng ở to_cell bị trúng đòn/va chạm (Story 3.7): amount là số Lòng dân bị trừ, cause là nguyên nhân.
	VILLAGE_DAMAGED,
	## Quân unit_id được hồi amount máu tại ô to_cell (Story 3.9).
	HEALED,
	## Cuối hiệp: báo trước ô to_cell sẽ có quân tiếp viện loại amount ở hiệp round_number (Story 3.10).
	REINFORCEMENT_WARNED,
	## Đầu hiệp: quân tiếp viện unit_id loại amount xuất hiện tại ô to_cell (Story 3.10).
	REINFORCEMENT_SPAWNED,
	## Đầu hiệp: tiếp viện loại amount tại ô to_cell bị chặn bởi quân other_id (Story 3.10).
	REINFORCEMENT_BLOCKED,
}

## Vì sao quân đổi ô hoặc mất máu. STRIKE: đòn có sát thương của tướng (Khoái, Lão).
## PULL: đòn kéo của Trần Khánh Dư (Story 2.4); mọi MOVED của đòn kéo mang nguyên nhân này.
## ENEMY_STRIKE: đòn quân Nguyên đã báo (Story 2.8); tách khỏi STRIKE để mưu kế cộng sát thương tướng không đụng tới.
## SPIKES: sát thương hầm chông (Story 3.4).
## HEAL: hồi máu từ kho lương hoặc hiệu ứng (Story 3.9).
## REINFORCEMENT: sát thương va chạm do tiếp viện xuất hiện trên ô đã có quân (Story 3.10).
enum Cause { WALK, STRIKE, PUSH, COLLISION, PULL, ENEMY_STRIKE, SPIKES, HEAL, REINFORCEMENT }

## Vì sao lệnh bị từ chối (REJECTED). Kịch bản luật ghi bằng mã "tu_choi" (ScenarioRunner.REJECT_EVENTS).
enum Reject {
	NONE, NO_UNIT, NOT_GENERAL, ALREADY_THERE, UNREACHABLE, ALREADY_MOVED, NOTHING_TO_UNDO,
	ALREADY_ATTACKED, NOT_ADJACENT, NO_TARGET, NOT_IN_RANGE,
	## Đòn có địch trong tầm nhưng bị rừng hoặc kho lương chặn trước nó (Story 3.1): khác NO_TARGET.
	BLOCKED,
	## Trận đã kết thúc (thắng hoặc thua): mọi lệnh bị khóa (Story 2.5).
	BATTLE_OVER,
}

## Vì sao đòn đã báo bị hủy (TELEGRAPH_CANCELLED, Story 2.9). Đúng ba đường TelegraphMarks trả ô trúng rỗng:
## OUT_OF_BOARD: đòn vào ô, chủ đòn bị đẩy/kéo làm ô đích rơi ra ngoài bàn.
## OWNER_DIED: chủ đòn đã gục trước lượt ra đòn của mình.
## NO_TARGET: Kỵ binh xung phong mà ô ngay trước mặt đã ngoài bàn. Với chỉ số hiện tại, đường này chỉ tới được từ
## dữ liệu trận (`bao_don` ghi hướng ra ngoài bàn), không từ một cú đẩy trong game.
enum TelegraphCancel { NONE, OUT_OF_BOARD, OWNER_DIED, NO_TARGET }

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
var cancel: TelegraphCancel = TelegraphCancel.NONE


func _init(p_type: Type, p_unit_id: int = 0, p_from: Vector2i = Vector2i.ZERO, p_to: Vector2i = Vector2i.ZERO,
		p_cause: Cause = Cause.WALK, p_reject: Reject = Reject.NONE, p_reason: String = "", p_round: int = 0,
		p_amount: int = 0, p_other_id: int = 0, p_cancel: TelegraphCancel = TelegraphCancel.NONE) -> void:
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
	cancel = p_cancel


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


## Quân Nguyên unit_id đứng ở p_from ra đòn đã báo, trúng ô p_to (Story 2.8). Hàm riêng để không đổi lời gọi của tướng.
static func enemy_attacked(p_unit_id: int, p_from: Vector2i, p_to: Vector2i) -> BattleEvent:
	return BattleEvent.new(Type.ATTACKED, p_unit_id, p_from, p_to, Cause.ENEMY_STRIKE)


static func victory() -> BattleEvent:
	return BattleEvent.new(Type.VICTORY)


static func defeat(p_reason: String = "") -> BattleEvent:
	return BattleEvent.new(Type.DEFEAT, 0, Vector2i.ZERO, Vector2i.ZERO, Cause.WALK, Reject.NONE, p_reason)


static func telegraphed(p_unit_id: int, p_stand: Vector2i, p_to: Vector2i, p_order: int) -> BattleEvent:
	return BattleEvent.new(Type.TELEGRAPHED, p_unit_id, p_stand, p_to, Cause.WALK, Reject.NONE, "", 0, p_order)


## Đòn đã báo của quân unit_id bị hủy (Story 2.9): p_from là ô chủ đòn lúc hủy (Telegraph.NO_CELL nếu đã gục),
## p_order là số thứ tự đã báo, p_cancel là lý do.
static func telegraph_cancelled(p_unit_id: int, p_from: Vector2i, p_order: int, p_cancel: TelegraphCancel) -> BattleEvent:
	return BattleEvent.new(Type.TELEGRAPH_CANCELLED, p_unit_id, p_from, Vector2i.ZERO, Cause.WALK, Reject.NONE, "",
		0, p_order, 0, p_cancel)


static func village_damaged(cell: Vector2i, p_amount: int = 1, p_cause: Cause = Cause.ENEMY_STRIKE) -> BattleEvent:
	return BattleEvent.new(Type.VILLAGE_DAMAGED, 0, Vector2i.ZERO, cell, p_cause, Reject.NONE, "", 0, p_amount)


static func healed(p_unit_id: int, p_amount: int, p_cell: Vector2i, p_cause: Cause = Cause.HEAL) -> BattleEvent:
	return BattleEvent.new(Type.HEALED, p_unit_id, Vector2i.ZERO, p_cell, p_cause, Reject.NONE, "", 0, p_amount)


static func reinforcement_warned(p_cell: Vector2i, p_type: int, p_round: int) -> BattleEvent:
	return BattleEvent.new(Type.REINFORCEMENT_WARNED, 0, Vector2i.ZERO, p_cell, Cause.REINFORCEMENT, Reject.NONE, "", p_round, p_type)


static func reinforcement_spawned(p_unit_id: int, p_cell: Vector2i, p_type: int) -> BattleEvent:
	return BattleEvent.new(Type.REINFORCEMENT_SPAWNED, p_unit_id, Vector2i.ZERO, p_cell, Cause.REINFORCEMENT, Reject.NONE, "", 0, p_type)


static func reinforcement_blocked(p_cell: Vector2i, p_type: int, p_blocker_id: int) -> BattleEvent:
	return BattleEvent.new(Type.REINFORCEMENT_BLOCKED, 0, Vector2i.ZERO, p_cell, Cause.REINFORCEMENT, Reject.NONE, "", 0, p_type, p_blocker_id)
