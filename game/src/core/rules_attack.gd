class_name RulesAttack
extends RefCounted
## Đòn của tướng (FR12–FR15). Story 2.1: Nguyễn Khoái đánh 1 ô kề có quân Nguyên, gây sát thương rồi đẩy theo
## hướng đánh; mục tiêu gục thì không đẩy. Mỗi tướng đánh một lần mỗi lượt (has_attacked). Lão, Dư: Story 2.3, 2.4.


## Ô tướng đánh được, theo thứ tự hướng B→Đ→N→T. Đã đánh hoặc chưa có đòn thì rỗng.
static func targets(state: BattleState, unit: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if unit.has_attacked or unit.type != UnitType.NGUYEN_KHOAI:
		return cells
	for dir: Vector2i in Grid.DIRECTIONS:
		var cell: Vector2i = unit.cell + dir
		var target: Unit = state.unit_at(cell) if state.in_bounds(cell) else null
		if target != null and target.faction == Unit.Faction.NGUYEN:
			cells.append(cell)
	return cells


## Lệnh sai thì một sự kiện REJECTED và state giữ nguyên: kiểm hết rồi mới sửa (BattleController không khôi phục
## state khi lệnh bị từ chối).
static func resolve(state: BattleState, command: Command, events: Array[BattleEvent]) -> void:
	var unit: Unit = state.unit_by_id(command.unit_id)
	var where: String = "%d,%d" % [command.cell.x, command.cell.y]
	if unit == null:
		events.append(BattleEvent.rejected(BattleEvent.Reject.NO_UNIT, "không có quân %d" % command.unit_id))
		return
	if not UnitType.is_general(unit.type):
		events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_GENERAL, "quân %d không phải tướng" % unit.id))
		return
	if unit.has_attacked:
		events.append(BattleEvent.rejected(BattleEvent.Reject.ALREADY_ATTACKED,
			"quân %d đã đánh rồi trong lượt này" % unit.id))
		return
	if unit.type != UnitType.NGUYEN_KHOAI:
		events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET,
			"quân %d chưa có đòn (Story 2.3, 2.4)" % unit.id))
		return
	if not Grid.is_adjacent(unit.cell, command.cell):
		events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_ADJACENT, "ô %s không kề quân %d" % [where, unit.id]))
		return
	if not targets(state, unit).has(command.cell):
		events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET,
			"ô %s không có quân Nguyên để đánh" % where))
		return
	events.append(BattleEvent.attacked(unit.id, command.cell))
	khoai_strike(state, unit, command.cell, events)
	unit.has_attacked = true


## Sát thương rồi đẩy nếu mục tiêu còn sống (kiến trúc M2). Sát Thát (+1) thêm ở Story 3.13.
static func khoai_strike(state: BattleState, khoai: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	var target: Unit = state.unit_at(cell)
	if target == null:
		return
	Effects.damage(state, target, state.stats.damage(khoai.type), BattleEvent.Cause.STRIKE, events)
	if target.is_alive():
		ForcedMove.run(state, target, Grid.dir_between(khoai.cell, cell), state.stats.push_distance(khoai.type),
			BattleEvent.Cause.PUSH, events)
