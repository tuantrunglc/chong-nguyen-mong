class_name RulesAttack
extends RefCounted
## Đòn của tướng (FR12–FR16). Nguyễn Khoái (Story 2.1): đánh 1 ô kề có quân Nguyên, gây sát thương rồi đẩy theo
## hướng đánh; mục tiêu gục thì không đẩy. Phạm Ngũ Lão (Story 2.3): lao thẳng hàng, bay qua ô kề, trúng quân đầu
## tiên ở ô min_range–max_range, không đẩy. Trần Khánh Dư (Story 2.4): kéo vật đầu tiên trên hàng trong pull_range ô
## (phải là quân Nguyên, không kề) về phía mình pull_distance ô, 0 sát thương. Mỗi tướng đánh một lần mỗi lượt
## (has_attacked).


## Quân Nguyên kề Dư không kéo được (GDD "kéo mục tiêu đã đứng kề thì không có hiệu ứng", tác giả chốt 2026-10-20):
## luật cố định, không nằm trong chi_so.json.
const PULL_MIN_RANGE: int = 2


## Ô tướng đánh được, theo thứ tự hướng B→Đ→N→T. Đã đánh thì rỗng.
static func targets(state: BattleState, unit: Unit) -> Array[Vector2i]:
	if unit.has_attacked:
		return []
	match unit.type:
		UnitType.NGUYEN_KHOAI:
			return _khoai_targets(state, unit)
		UnitType.PHAM_NGU_LAO:
			return _lao_targets(state, unit)
		UnitType.TRAN_KHANH_DU:
			return _du_targets(state, unit)
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
## sẽ trúng tướng đó, viền vẫn ở quân Nguyên phía sau; tác giả chốt 2026-10-19). Quân đứng trước `min_range` (ô kề
## với chỉ số hiện tại) thì lao bay qua.
## Story 3.1: rừng hoặc kho lương ở BẤT KỲ ô nào từ d=1 tới mục tiêu thì chặn hướng đó; vật cản sau mục tiêu
## không ảnh hưởng. Làng để Story 3.7. Sông không chặn.
static func _lao_targets(state: BattleState, lao: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var near: int = state.stats.min_range(lao.type)
	for dir: Vector2i in Grid.DIRECTIONS:
		for d: int in range(1, state.stats.max_range(lao.type) + 1):
			var cell: Vector2i = lao.cell + dir * d
			if not state.in_bounds(cell):
				break
			if Terrain.ATTACK_BLOCKERS.has(state.terrain_at(cell)):
				break
			var unit: Unit = state.unit_at(cell)
			if unit == null or unit.faction != Unit.Faction.NGUYEN:
				continue  # ô trống, hoặc tướng mình đứng chắn: lao đi tiếp
			if d < near:
				continue  # ô kề: lao bay qua quân
			cells.append(cell)
			break
	return cells


## Mỗi hướng nhiều nhất một ô: chỉ xét vật đầu tiên trong pull_range ô. Là quân Nguyên ở ô thứ PULL_MIN_RANGE trở đi
## thì có viền. Tướng mình hoặc quân Nguyên kề thì hướng đó rỗng (khác Lão: không bay qua).
## Story 3.1: rừng hoặc kho lương là vật đầu tiên thì hướng đó rỗng — không kéo được quân đứng sau. Làng ở 3.7.
static func _du_targets(state: BattleState, du: Unit) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dir: Vector2i in Grid.DIRECTIONS:
		for d: int in range(1, state.stats.pull_range(du.type) + 1):
			var cell: Vector2i = du.cell + dir * d
			if not state.in_bounds(cell):
				break
			if Terrain.ATTACK_BLOCKERS.has(state.terrain_at(cell)):
				break
			var unit: Unit = state.unit_at(cell)
			if unit == null:
				continue
			if unit.faction == Unit.Faction.NGUYEN and d >= PULL_MIN_RANGE:
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
				_reject_no_target(state, unit, command.cell,
					"ô %s không phải quân Nguyên gần nhất trong tầm lao" % where, events)
				return
			lao_throw(state, unit, command.cell, events)
		UnitType.TRAN_KHANH_DU:
			var distance: int = Grid.distance(unit.cell, command.cell)
			var reach: int = state.stats.pull_range(unit.type)
			if not state.in_bounds(command.cell) or Grid.straight_dir(unit.cell, command.cell) == Vector2i.ZERO \
					or distance < PULL_MIN_RANGE or distance > reach:
				events.append(BattleEvent.rejected(BattleEvent.Reject.NOT_IN_RANGE,
					"ô %s không thẳng hàng với quân %d trong tầm %d–%d" % [where, unit.id, PULL_MIN_RANGE, reach]))
				return
			if not targets(state, unit).has(command.cell):
				_reject_no_target(state, unit, command.cell,
					"ô %s không phải quân Nguyên đầu tiên trên hàng trong tầm kéo" % where, events)
				return
			events.append(BattleEvent.attacked(unit.id, command.cell))
			du_pull(state, unit, command.cell, events)
		_:
			events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET, "quân %d không có đòn" % unit.id))
			return
	unit.has_attacked = true


## Sát thương rồi đẩy nếu mục tiêu còn sống (kiến trúc M2). Sát Thát cộng vào sát thương đòn, không cộng vào va
## chạm khi bị đẩy (Story 3.13).
static func khoai_strike(state: BattleState, khoai: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	var target: Unit = state.unit_at(cell)
	if target == null:
		return
	Effects.damage(state, target, state.stats.damage(khoai.type) + state.sat_that_bonus(), BattleEvent.Cause.STRIKE,
		events)
	if target.is_alive():
		ForcedMove.run(state, target, Grid.dir_between(khoai.cell, cell), state.stats.push_distance(khoai.type),
			BattleEvent.Cause.PUSH, events)


## Đòn có địch đúng ô đích nhưng bị rừng/kho lương chặn trước nó: lý do BLOCKED, không phải NO_TARGET
## (Story 3.1 — người chơi bấm vào địch mà báo "không có đích" là sai). Còn lại giữ NO_TARGET như cũ.
static func _reject_no_target(state: BattleState, unit: Unit, cell: Vector2i, reason: String,
		events: Array[BattleEvent]) -> void:
	if _blocked_target(state, unit.cell, cell):
		events.append(BattleEvent.rejected(BattleEvent.Reject.BLOCKED,
			"đòn bị rừng, kho lương hoặc làng chặn trước ô %d,%d" % [cell.x, cell.y]))
		return
	events.append(BattleEvent.rejected(BattleEvent.Reject.NO_TARGET, reason))


## Ô đích có quân Nguyên và có vật cản chặn giữa ô chủ đòn với nó (không tính hai đầu).
static func _blocked_target(state: BattleState, from: Vector2i, to: Vector2i) -> bool:
	var target: Unit = state.unit_at(to)
	if target == null or target.faction != Unit.Faction.NGUYEN:
		return false
	var dir: Vector2i = Grid.straight_dir(from, to)
	if dir == Vector2i.ZERO:
		return false
	var step: Vector2i = from + dir
	while step != to:
		if Terrain.ATTACK_BLOCKERS.has(state.terrain_at(step)):
			return true
		step += dir
	return false


## Lao về phía cell, trúng quân đầu tiên (mọi phe) từ ô min_range; tự ghi ATTACKED với ô quân trúng (có thể là
## tướng mình đứng chắn trước cell). Không đẩy. Sát Thát cộng vào sát thương, kể cả khi trúng tướng mình (tác giả
## chốt, Story 3.13). Rừng hoặc kho lương trước mục tiêu thì lao bị chặn, không ai mất máu (Story 3.1; làng ở 3.7)
## — phòng thủ, vì `targets` đã loại các ô đó.
static func lao_throw(state: BattleState, lao: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	var dir: Vector2i = Grid.straight_dir(lao.cell, cell)
	var near: int = state.stats.min_range(lao.type)
	for d: int in range(1, Grid.distance(lao.cell, cell) + 1):
		var step: Vector2i = lao.cell + dir * d
		if Terrain.ATTACK_BLOCKERS.has(state.terrain_at(step)):
			return
		var target: Unit = state.unit_at(step)
		if target == null or d < near:
			continue  # ô trống, hoặc quân bị bay qua (trước tầm gần)
		events.append(BattleEvent.attacked(lao.id, target.cell))
		Effects.damage(state, target, state.stats.damage(lao.type) + state.sat_that_bonus(), BattleEvent.Cause.STRIKE,
			events)
		return
	# resolve đã kiểm cell có trong targets: tới đây là targets và lao_throw lệch nhau.
	assert(false, "RulesAttack.lao_throw: không trúng ai từ %s tới %s" % [lao.cell, cell])


## Kéo quân ở cell về phía Dư, đi từng ô qua ForcedMove, 0 sát thương. Chỉ còn đúng số ô trống giữa Dư và mục tiêu:
## quân dừng sát Dư, không va Dư (tác giả chốt 2026-10-20). Sát Thát không cộng (Story 3.13).
static func du_pull(state: BattleState, du: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	var target: Unit = state.unit_at(cell)
	assert(target != null, "RulesAttack.du_pull: không có quân ở %s" % cell)
	if target == null:
		return
	var steps: int = mini(state.stats.pull_distance(du.type), Grid.distance(du.cell, cell) - 1)
	ForcedMove.run(state, target, Grid.straight_dir(cell, du.cell), steps, BattleEvent.Cause.PULL, events)
