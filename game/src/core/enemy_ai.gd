class_name EnemyAI
extends RefCounted
## Enemy AI tất định (FR23, tác giả chốt 2026-10-21): chọn mục tiêu, chọn ô đứng. Chỉ đọc state; đi và báo đòn là
## việc của RulesEnemyPhase.prepare.
## - Mục tiêu: tướng gần nhất theo số bước đi; hòa thì ít máu hơn, rồi phía Bắc hơn, rồi phía Đông hơn.
## - Ô đứng: trong tầm đi (kể cả đứng yên), ô mà từ đó đòn trúng mục tiêu, cần ít bước nhất; hòa thì Bắc, rồi Đông.
## - Không có ô như vậy: ô gần mục tiêu nhất (số bước), hòa thì ít bước đi hơn, rồi Bắc, rồi Đông; không báo đòn.
## "Phía Bắc hơn" là hàng nhỏ hơn, "phía Đông hơn" là cột lớn hơn: thứ tự B→Đ→N→T áp cho chỗ hòa giữa các ô.
## Đòn: Bộ binh ô kề; Kỵ binh xung phong thẳng hàng; Cung kỵ (Story 2.15) bắn ô thẳng hàng cách 2–3 ô, tên bay
## qua quân; rừng hoặc kho lương chặn tên (Story 3.1). Nhắm làng (3.7), ô ải (3.11) thêm nhánh ở đây.
## Mọi loại quân chỉ nhắm tướng có ĐƯỜNG ĐI tới (Pathfinding.distance_field); tướng bị vây hoàn toàn thì bỏ qua,
## kể cả Cung kỵ bắn qua được — giữ nguyên luật AI chung ở bảng thứ tự phân giải (tác giả chốt 2026-10-23).

## Địa hình chắn đường xung phong của Kỵ binh (FR19). Sông không chắn.
const CHARGE_BLOCKERS: Array[int] = [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]


static func plan(state: BattleState, unit: Unit) -> EnemyIntent:
	var target_unit: Unit = null
	var target_cell: Vector2i = Vector2i(-1, -1)
	var field: Dictionary = {}
	var best_key: Array[int] = []

	# Story 3.7: Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất; hòa bước thì ưu tiên làng (0 < 1).
	# Cung kỵ không nhắm làng (chỉ nhắm tướng Đại Việt).
	if unit.type != UnitType.CUNG_KY:
		for y: int in range(state.size.y):
			for x: int in range(state.size.x):
				var cell: Vector2i = Vector2i(x, y)
				if state.terrain_at(cell) != Terrain.VILLAGE:
					continue
				var f: Dictionary = Pathfinding.distance_field(state, unit, cell)
				if not f.has(unit.cell):
					continue
				var key: Array[int] = [f[unit.cell] as int, 0, 0, cell.y, -cell.x]
				if best_key.is_empty() or _less(key, best_key):
					target_unit = null
					target_cell = cell
					field = f
					best_key = key

	for general: Unit in state.units:
		if general.faction != Unit.Faction.DAI_VIET:
			continue
		var f: Dictionary = Pathfinding.distance_field(state, unit, general.cell)
		if not f.has(unit.cell):
			continue
		var key: Array[int] = [f[unit.cell] as int, 1, general.hp, general.cell.y, -general.cell.x]
		if best_key.is_empty() or _less(key, best_key):
			target_unit = general
			target_cell = general.cell
			field = f
			best_key = key

	if best_key.is_empty():
		return EnemyIntent.new(unit.id, unit.type, unit.cell, unit.cell, 0, 0, EnemyIntent.Reason.NO_PATH)
	var target_id: int = target_unit.id if target_unit != null else 0
	var steps_to_target: int = field[unit.cell] as int
	if not _has_attack_rule(unit.type):
		return EnemyIntent.new(unit.id, unit.type, unit.cell, unit.cell, target_id, steps_to_target,
			EnemyIntent.Reason.NO_ATTACK_RULE, 0, target_cell)

	var walk: Dictionary = {unit.cell: 0}  # ô đứng được -> số bước đi
	var paths: Dictionary = Pathfinding.find_paths(state, unit, state.stats.move_range(unit.type))
	for cell: Variant in paths.keys():
		walk[cell] = (paths[cell] as Array).size()

	var stand: Vector2i = unit.cell
	var found: bool = false
	var stand_key: Array[int] = []
	for cell: Vector2i in walk.keys():
		if not can_hit_from(state, unit, cell, target_cell):
			continue
		var key: Array[int] = [walk[cell] as int, cell.y, -cell.x]
		if not found or _less(key, stand_key):
			stand = cell
			stand_key = key
			found = true
	if found:
		return EnemyIntent.new(unit.id, unit.type, unit.cell, stand, target_id, steps_to_target,
			EnemyIntent.Reason.CAN_HIT, 0, target_cell)

	stand_key = []
	for cell: Vector2i in walk.keys():
		if not field.has(cell):
			continue
		var key: Array[int] = [field[cell] as int, walk[cell] as int, cell.y, -cell.x]
		if stand_key.is_empty() or _less(key, stand_key):
			stand = cell
			stand_key = key
	return EnemyIntent.new(unit.id, unit.type, unit.cell, stand, target_id, steps_to_target,
		EnemyIntent.Reason.CLOSEST, 0, target_cell)


## Đứng ở cell thì đòn của unit có trúng ô target không. Bộ binh: ô kề. Kỵ binh: cùng hàng hoặc cùng cột, giữa hai
## ô không có quân nào (trừ chính unit, nó sẽ rời ô cũ) và không có rừng, kho lương, làng. Cung kỵ (Story 2.15):
## cùng hàng hoặc cùng cột, cách `tam_ban_gan`–`tam_ban_xa` ô, không xét QUÂN ở giữa, nhưng rừng hoặc kho lương
## giữa thì chặn (Story 3.1); làng chặn ở Story 3.7.
static func can_hit_from(state: BattleState, unit: Unit, cell: Vector2i, target: Vector2i) -> bool:
	match unit.type:
		UnitType.BO_BINH:
			return Grid.is_adjacent(cell, target)
		UnitType.KY_BINH:
			var dir: Vector2i = Grid.straight_dir(cell, target)
			if dir == Vector2i.ZERO:
				return false
			var step: Vector2i = cell + dir
			while step != target:
				var other: Unit = state.unit_at(step)
				if (other != null and other != unit) or CHARGE_BLOCKERS.has(state.terrain_at(step)):
					return false
				step += dir
			return true
		UnitType.CUNG_KY:
			if state.in_bounds(target) and state.terrain_at(target) == Terrain.VILLAGE:
				return false  # Cung kỵ không nhắm làng (Story 3.7)
			var dir: Vector2i = Grid.straight_dir(cell, target)
			if dir == Vector2i.ZERO:
				return false
			var distance: int = Grid.distance(cell, target)
			if distance < state.stats.shoot_min_range(unit.type) \
					or distance > state.stats.shoot_max_range(unit.type):
				return false
			var step: Vector2i = cell + dir
			while step != target:
				if Terrain.ATTACK_BLOCKERS.has(state.terrain_at(step)):
					return false  # Rừng, kho lương, làng chặn tên (Story 3.1, 3.7: tác giả chốt 2026-10-24)
				step += dir
			return true
	return false


## Telegraph cho unit đứng ở stand đánh target: Bộ binh vào ô, Kỵ binh theo hướng.
static func telegraph_for(unit: Unit, stand: Vector2i, target: Vector2i, order: int) -> Telegraph:
	if unit.type == UnitType.KY_BINH:
		return Telegraph.new(unit.id, Telegraph.Kind.DIRECTION, Grid.straight_dir(stand, target), order)
	return Telegraph.new(unit.id, Telegraph.Kind.CELL, target - stand, order)


## Loại quân có luật đòn. Từ Story 2.15 cả ba loại quân Nguyên đều có; giữ hàm để loại quân thêm sau không có luật
## thì không báo đòn.
static func _has_attack_rule(type: int) -> bool:
	return type == UnitType.BO_BINH or type == UnitType.KY_BINH or type == UnitType.CUNG_KY


## So hai khóa cùng độ dài theo thứ tự từ điển: a nhỏ hơn b.
static func _less(a: Array[int], b: Array[int]) -> bool:
	for i: int in range(a.size()):
		if a[i] != b[i]:
			return a[i] < b[i]
	return false
