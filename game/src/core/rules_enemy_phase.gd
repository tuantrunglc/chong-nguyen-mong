class_name RulesEnemyPhase
extends RefCounted
## Từ lúc người chơi kết thúc lượt tới đầu lượt người chơi của hiệp sau. Story 1.5 chỉ có phần cuối hiệp
## (sang hiệp mới, tướng đi lại được). Pha địch ra đòn, cuối hiệp (kho lương, tiếp viện), địch chuẩn bị
## và Phase chèn vào đây ở E2–E3 (kiến trúc: "Mẫu trạng thái").


static func end_player_turn(state: BattleState, events: Array[BattleEvent]) -> void:
	state.round_number += 1
	for unit: Unit in state.units:
		unit.has_moved = false
	events.append(BattleEvent.round_started(state.round_number))
