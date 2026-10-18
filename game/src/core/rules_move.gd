class_name RulesMove
extends RefCounted
## Luật đi của tướng (FR5–FR7): tối đa tam_di bước, 4 hướng, đi xuyên quân mình, không dừng trên quân nào;
## quân Nguyên, sông, rừng, kho lương, làng, mép bàn chặn. Cờ "đã đi" thêm ở Story 1.5.


## Các ô quân dừng được, theo thứ tự đọc bàn (hàng trên xuống, trái sang phải).
static func reachable(state: BattleState, unit: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Variant in _paths(state, unit).keys():
		cells.append(cell as Vector2i)
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.y < b.y or (a.y == b.y and a.x < b.x))
	return cells


## Đường đi tới cell (không gồm ô đang đứng); rỗng nếu không tới được.
static func path_to(state: BattleState, unit: Unit, cell: Vector2i) -> Array[Vector2i]:
	var paths: Dictionary = _paths(state, unit)
	if not paths.has(cell):
		return []
	return (paths[cell] as Array[Vector2i]).duplicate()


## Lệnh sai thì một sự kiện REJECTED và state giữ nguyên. Đúng thì đi từng ô trên đường.
## Lúc đi xuyên ô quân mình, hai quân tạm chung ô; validate() chỉ chạy sau khi cả lệnh xong.
static func resolve(state: BattleState, command: Command, events: Array[BattleEvent]) -> void:
	var unit: Unit = state.unit_by_id(command.unit_id)
	var where: String = "%d,%d" % [command.cell.x, command.cell.y]
	if unit == null:
		events.append(BattleEvent.rejected(BattleEvent.Reject.NO_UNIT, "không có quân %d" % command.unit_id))
		return
	if not UnitType.is_general(unit.type):
		events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_GENERAL, "quân %d không phải tướng" % unit.id))
		return
	if command.cell == unit.cell:
		events.append(BattleEvent.rejected(BattleEvent.Reject.ALREADY_THERE, "quân %d đã đứng ở ô %s" % [unit.id, where]))
		return
	var path: Array[Vector2i] = path_to(state, unit, command.cell)
	if path.is_empty():
		events.append(BattleEvent.rejected(BattleEvent.Reject.UNREACHABLE,
			"quân %d không đi tới được ô %s" % [unit.id, where]))
		return
	for step: Vector2i in path:
		Effects.move(state, unit, step, BattleEvent.Cause.WALK, events)


static func _paths(state: BattleState, unit: Unit) -> Dictionary:
	return Pathfinding.find_paths(state, unit, state.stats.move_range(unit.type))
