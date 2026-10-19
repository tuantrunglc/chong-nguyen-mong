class_name RulesAttack
extends RefCounted
## Đòn của tướng (FR12–FR16). Nguyễn Khoái (Story 2.1): đánh 1 ô kề có quân Nguyên, gây sát thương rồi đẩy theo
## hướng đánh; mục tiêu gục thì không đẩy. Phạm Ngũ Lão (Story 2.3): lao thẳng hàng, bay qua ô kề, trúng quân đầu
## tiên ở ô min_range–max_range, không đẩy. Mỗi tướng đánh một lần mỗi lượt (has_attacked). Dư: Story 2.4.


## Ô tướng đánh được, theo thứ tự hướng B→Đ→N→T. Đã đánh hoặc chưa có đòn thì rỗng.
static func targets(state: BattleState, unit: Unit) -> Array[Vector2i]:
	if unit.has_attacked:
		return []
	match unit.type:
		UnitType.NGUYEN_KHOAI:
			return _khoai_targets(state, unit)
		UnitType.PHAM_NGU_LAO:
			return _lao_targets(state, unit)
	return []


static func _khoai_targets(state: BattleState, khoai: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dir: Vector2i in Grid.DIRECTIONS:
		var cell: Vector2i = khoai.cell + dir
		var target: Unit = state.unit_at(cell) if state.in_bounds(cell) else null
		if target != null and target.faction == Unit.Faction.NGUYEN:
			cells.append(cell)
	return cells


## Mỗi hướng nhiều nhất một ô: quân Nguyên gần nhất ở ô min_range–max_range. Tướng mình đứng chắn thì đi tiếp (lao
## sẽ trúng tướng đó, viền vẫn ở quân Nguyên phía sau; tác giả chốt 2026-10-19). Ô kề không xét.
## Story 3.1: gặp rừng, kho lương, làng ở bất kỳ ô nào từ ô kề thì dừng hướng đó.
static func _lao_targets(state: BattleState, lao: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dir: Vector2i in Grid.DIRECTIONS:
		for d: int in range(state.stats.min_range(lao.type), state.stats.max_range(lao.type) + 1):
			var cell: Vector2i = lao.cell + dir * d
			if not state.in_bounds(cell):
				break
			var unit: Unit = state.unit_at(cell)
			if unit != null and unit.faction == Unit.Faction.NGUYEN:
				cells.append(cell)
				break
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
	match unit.type:
		UnitType.NGUYEN_KHOAI:
			if not Grid.is_adjacent(unit.cell, command.cell) or not state.in_bounds(command.cell):
				events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_ADJACENT,
					"ô %s không kề quân %d" % [where, unit.id]))
				return
			if not targets(state, unit).has(command.cell):
				events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET,
					"ô %s không có quân Nguyên để đánh" % where))
				return
			events.append(BattleEvent.attacked(unit.id, command.cell))
			khoai_strike(state, unit, command.cell, events)
		UnitType.PHAM_NGU_LAO:
			var near: int = state.stats.min_range(unit.type)
			var far: int = state.stats.max_range(unit.type)
			var distance: int = Grid.distance(unit.cell, command.cell)
			if not state.in_bounds(command.cell) or Grid.straight_dir(unit.cell, command.cell) == Vector2i.ZERO \
					or distance < near or distance > far:
				events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_IN_RANGE,
					"ô %s không thẳng hàng với quân %d trong tầm %d–%d" % [where, unit.id, near, far]))
				return
			if not targets(state, unit).has(command.cell):
				events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET,
					"ô %s không phải quân Nguyên gần nhất trong tầm lao" % where))
				return
			lao_throw(state, unit, command.cell, events)
		_:
			events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET,
				"quân %d chưa có đòn (Story 2.4)" % unit.id))
			return
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


## Lao về phía cell, trúng quân đầu tiên (mọi phe) từ ô min_range; tự ghi ATTACKED với ô quân trúng (có thể là
## tướng mình đứng chắn trước cell). Không đẩy. Sát Thát (+1) thêm ở Story 3.13; rừng, kho lương, làng chặn: 3.1.
static func lao_throw(state: BattleState, lao: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	var dir: Vector2i = Grid.straight_dir(lao.cell, cell)
	for d: int in range(state.stats.min_range(lao.type), Grid.distance(lao.cell, cell) + 1):
		var target: Unit = state.unit_at(lao.cell + dir * d)
		if target != null:
			events.append(BattleEvent.attacked(lao.id, target.cell))
			Effects.damage(state, target, state.stats.damage(lao.type), BattleEvent.Cause.STRIKE, events)
			return
