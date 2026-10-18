class_name Rules
extends RefCounted
## Điểm vào duy nhất của luật: nhận state và lệnh, sửa state, trả danh sách sự kiện.
## Muốn giữ bản gốc (hoàn tác, xem trước) thì clone() trước khi gọi.


static func resolve(state: BattleState, command: Command) -> Array[BattleEvent]:
	var events: Array[BattleEvent] = []
	match command.kind:
		Command.Kind.MOVE:
			RulesMove.resolve(state, command, events)
	return events
