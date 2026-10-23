class_name Pathfinding
extends RefCounted
## Tìm đường bằng BFS tự viết (không dùng AStarGrid2D: luật "đi xuyên quân mình" không khớp).
## Tất định: xét ô kề theo Grid.DIRECTIONS (B→Đ→N→T) và giữ ô cha đầu tiên, nên đường đi là đường
## ngắn nhất, hòa thì ưu tiên B, rồi Đ, N, T theo thứ tự đi trên đường.


## Mọi ô quân dừng được trong max_steps bước: ô đích -> đường đi (không gồm ô xuất phát, gồm ô đích).
## Đi qua được: ô trong bàn, địa hình đi vào được, không có quân khác phe. Dừng được: thêm điều kiện
## không có quân nào. Ô quân cùng phe vẫn đi xuyên qua để tới ô sau.
## Dictionary chỉ để tra; ai cần thứ tự thì tự sắp (xem RulesMove.reachable).
## Tướng (Story 3.4): ưu tiên đường ít hầm chông nhất, hòa thì ít bước hơn, rồi B→Đ→N→T.
## Quân Nguyên: đường ngắn nhất theo BFS, không tránh hầm chông.
static func find_paths(state: BattleState, unit: Unit, max_steps: int) -> Dictionary:
	if unit.faction == Unit.Faction.DAI_VIET:
		return _find_paths_hero(state, unit, max_steps)
	return _find_paths_enemy(state, unit, max_steps)


static func _find_paths_enemy(state: BattleState, unit: Unit, max_steps: int) -> Dictionary:
	var parent: Dictionary = {unit.cell: unit.cell}  # ô -> ô cha
	var depth: Dictionary = {unit.cell: 0}
	var queue: Array[Vector2i] = [unit.cell]
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		var steps: int = depth[current] as int
		if steps >= max_steps:
			continue
		for dir: Vector2i in Grid.DIRECTIONS:
			var next: Vector2i = current + dir
			if parent.has(next) or not _can_pass(state, unit, next):
				continue
			parent[next] = current
			depth[next] = steps + 1
			queue.append(next)

	var paths: Dictionary = {}
	for cell: Vector2i in queue:
		if cell == unit.cell or state.unit_at(cell) != null:
			continue
		var path: Array[Vector2i] = []
		var step: Vector2i = cell
		while step != unit.cell:
			path.push_front(step)
			step = parent[step] as Vector2i
		paths[cell] = path
	return paths


## Tìm đường cho tướng: trong max_steps bước, chọn đường ít hầm chông nhất; hòa thì ít bước hơn, rồi B→Đ→N→T.
static func _find_paths_hero(state: BattleState, unit: Unit, max_steps: int) -> Dictionary:
	# Lưu [spikes, path, dirs] tốt nhất cho từng ô đích
	var best: Dictionary = {}
	# queue: [current_cell, path, spikes, dirs]
	var queue: Array[Array] = [[unit.cell, [] as Array[Vector2i], 0, [] as Array[int]]]
	while not queue.is_empty():
		var item: Array = queue.pop_front()
		var current: Vector2i = item[0] as Vector2i
		var path: Array[Vector2i] = item[1] as Array[Vector2i]
		var spikes: int = item[2] as int
		var dirs: Array[int] = item[3] as Array[int]

		if path.size() >= max_steps:
			continue

		for d: int in range(Grid.DIRECTIONS.size()):
			var dir: Vector2i = Grid.DIRECTIONS[d]
			var next: Vector2i = current + dir
			if not _can_pass(state, unit, next):
				continue
			if path.has(next) or next == unit.cell:
				continue
			var next_spikes: int = spikes + (1 if state.terrain_at(next) == Terrain.SPIKES else 0)
			var next_path: Array[Vector2i] = path.duplicate()
			next_path.append(next)
			var next_dirs: Array[int] = dirs.duplicate()
			next_dirs.append(d)

			var replace: bool = false
			if not best.has(next):
				replace = true
			else:
				var cur: Array = best[next] as Array
				replace = _is_better_path(next_spikes, next_path, next_dirs, cur[0] as int, cur[1] as Array[Vector2i], cur[2] as Array[int])

			if replace:
				best[next] = [next_spikes, next_path, next_dirs]

			queue.append([next, next_path, next_spikes, next_dirs])

	var paths: Dictionary = {}
	for cell: Vector2i in best.keys():
		if state.unit_at(cell) != null:
			continue
		paths[cell] = (best[cell][1] as Array[Vector2i]).duplicate()
	return paths


static func _is_better_path(cand_spikes: int, cand_path: Array[Vector2i], cand_dirs: Array[int],
		cur_spikes: int, cur_path: Array[Vector2i], cur_dirs: Array[int]) -> bool:
	if cand_spikes < cur_spikes:
		return true
	if cand_spikes > cur_spikes:
		return false
	if cand_path.size() < cur_path.size():
		return true
	if cand_path.size() > cur_path.size():
		return false
	for k: int in range(cand_dirs.size()):
		if cand_dirs[k] < cur_dirs[k]:
			return true
		if cand_dirs[k] > cur_dirs[k]:
			return false
	return false


## Số bước từ mỗi ô tới goal, đếm như unit đi (4 hướng, đi xuyên quân cùng phe; ô không đi vào được, quân khác phe
## chặn), không giới hạn bước: ô -> số bước, goal = 0 dù goal có quân đứng. BFS xuất phát từ goal: ô đi qua được
## không phụ thuộc hướng đi, nên field[a] là số bước từ a tới goal. Ô không có trong field là không có đường tới goal.
## Enemy AI (Story 2.6) dùng để chọn tướng gần nhất và ô gần mục tiêu nhất.
static func distance_field(state: BattleState, unit: Unit, goal: Vector2i) -> Dictionary:
	var field: Dictionary = {goal: 0}
	var queue: Array[Vector2i] = [goal]
	var head: int = 0
	while head < queue.size():
		var current: Vector2i = queue[head]
		head += 1
		for dir: Vector2i in Grid.DIRECTIONS:
			var next: Vector2i = current + dir
			if field.has(next) or not _can_pass(state, unit, next):
				continue
			field[next] = (field[current] as int) + 1
			queue.append(next)
	return field


## in_bounds trước: terrain_at không tự kiểm biên.
static func _can_pass(state: BattleState, unit: Unit, cell: Vector2i) -> bool:
	if not state.in_bounds(cell) or not Terrain.is_walkable(state.terrain_at(cell)):
		return false
	var other: Unit = state.unit_at(cell)
	return other == null or other.faction == unit.faction
