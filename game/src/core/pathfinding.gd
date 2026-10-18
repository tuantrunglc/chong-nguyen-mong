class_name Pathfinding
extends RefCounted
## Tìm đường bằng BFS tự viết (không dùng AStarGrid2D: luật "đi xuyên quân mình" không khớp).
## Tất định: xét ô kề theo Grid.DIRECTIONS (B→Đ→N→T) và giữ ô cha đầu tiên, nên đường đi là đường
## ngắn nhất, hòa thì ưu tiên B, rồi Đ, N, T theo thứ tự đi trên đường.


## Mọi ô quân dừng được trong max_steps bước: ô đích -> đường đi (không gồm ô xuất phát, gồm ô đích).
## Đi qua được: ô trong bàn, địa hình đi vào được, không có quân khác phe. Dừng được: thêm điều kiện
## không có quân nào. Ô quân cùng phe vẫn đi xuyên qua để tới ô sau.
## Dictionary chỉ để tra; ai cần thứ tự thì tự sắp (xem RulesMove.reachable).
static func find_paths(state: BattleState, unit: Unit, max_steps: int) -> Dictionary:
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


## in_bounds trước: terrain_at không tự kiểm biên.
static func _can_pass(state: BattleState, unit: Unit, cell: Vector2i) -> bool:
	if not state.in_bounds(cell) or not Terrain.is_walkable(state.terrain_at(cell)):
		return false
	var other: Unit = state.unit_at(cell)
	return other == null or other.faction == unit.faction
