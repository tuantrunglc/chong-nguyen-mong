class_name Rules
extends RefCounted
## Điểm vào duy nhất của luật: nhận state và lệnh, sửa state, trả danh sách sự kiện.
## Muốn giữ bản gốc (hoàn tác, xem trước) thì clone() trước khi gọi.


static func resolve(state: BattleState, command: Command) -> Array[BattleEvent]:
	var events: Array[BattleEvent] = []
	if is_battle_over(state):
		events.append(BattleEvent.rejected(BattleEvent.Reject.BATTLE_OVER, "trận đã kết thúc"))
		return events
	match command.kind:
		Command.Kind.MOVE:
			RulesMove.resolve(state, command, events)
		Command.Kind.ATTACK:
			RulesAttack.resolve(state, command, events)
		Command.Kind.END_TURN:
			RulesEnemyPhase.end_player_turn(state, events)
		Command.Kind.BEGIN_BATTLE:
			RulesEnemyPhase.begin_battle(state, events)
	# Lệnh bị từ chối thì không có gì đổi, nên không kiểm kết cục.
	if not _was_rejected(events):
		RulesVictory.check(state, events)
	# Hết trận thì bỏ đòn đã báo còn lại: không còn lượt nào để chúng ra đòn, giữ lại thì ô đỏ nằm trên
	# bàn sau bảng thắng/thua (tác giả chốt 2026-10-22, Story 2.9).
	if is_battle_over(state):
		state.telegraphs.clear()
	return events


## Đã thắng hoặc thua: mọi lệnh bị từ chối (BATTLE_OVER).
static func is_battle_over(state: BattleState) -> bool:
	return state.phase == BattleState.Phase.WON or state.phase == BattleState.Phase.LOST


static func _was_rejected(events: Array[BattleEvent]) -> bool:
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.REJECTED:
			return true
	return false
