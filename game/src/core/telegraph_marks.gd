class_name TelegraphMarks
extends RefCounted
## Ô đỏ báo đòn (Story 2.7): đòn quân Nguyên đã báo phủ những ô nào, trúng ô nào, tính theo vị trí hiện tại của chủ
## đòn và vật trên bàn (tính lại sau mỗi lệnh). Chỉ đọc state. Phần vẽ (TelegraphView) chỉ gọi các hàm này.


## Ô -> các số thứ tự đòn phủ ô đó, tăng dần.
static func cells(state: BattleState) -> Dictionary:
	var out: Dictionary = {}
	for t: Telegraph in state.telegraphs:
		for cell: Vector2i in path_cells(state, t):
			if not out.has(cell):
				out[cell] = [] as Array[int]
			(out[cell] as Array[int]).append(t.order)
	for cell: Vector2i in out:
		(out[cell] as Array[int]).sort()
	return out


## Lý do đòn này sẽ bị hủy, hoặc NONE nếu còn hiệu lực (Story 2.9). Phân biệt đúng ba đường path_cells trả rỗng;
## không suy từ hit_cell một mình vì nó gộp cả ba thành NO_CELL.
static func cancel_reason(state: BattleState, telegraph: Telegraph) -> BattleEvent.TelegraphCancel:
	if state.unit_by_id(telegraph.owner_id) == null:
		return BattleEvent.TelegraphCancel.OWNER_DIED
	var owner: Unit = state.unit_by_id(telegraph.owner_id)
	var step: Vector2i = owner.cell + telegraph.offset
	if state.in_bounds(step):
		return BattleEvent.TelegraphCancel.NONE
	if telegraph.kind == Telegraph.Kind.DIRECTION:
		return BattleEvent.TelegraphCancel.NO_TARGET
	return BattleEvent.TelegraphCancel.OUT_OF_BOARD


## Ô đòn sẽ trúng; NO_CELL nếu không có. Kỵ binh: ô cuối đường xung phong (vật đầu tiên, hoặc ô sát mép).
static func hit_cell(state: BattleState, telegraph: Telegraph) -> Vector2i:
	var path: Array[Vector2i] = path_cells(state, telegraph)
	if path.is_empty():
		return Telegraph.NO_CELL
	return path[path.size() - 1]


## Các ô đòn đi qua, theo thứ tự từ chủ đòn ra. Đòn vào ô: chỉ ô đích. Kỵ binh: từ ô trước mặt tới vật đầu tiên
## trên hàng (quân bất kỳ phe, EnemyAI.CHARGE_BLOCKERS; sông không chắn), gồm ô vật đó; hàng trống thì tới mép.
## Chủ đòn đã gục hoặc ô đích ngoài bàn: rỗng.
static func path_cells(state: BattleState, telegraph: Telegraph) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var step: Vector2i = telegraph.target_cell(state)
	if step == Telegraph.NO_CELL:
		return out
	if telegraph.kind == Telegraph.Kind.CELL:
		if state.in_bounds(step):
			out.append(step)
		return out
	while state.in_bounds(step):
		out.append(step)
		if state.unit_at(step) != null or EnemyAI.CHARGE_BLOCKERS.has(state.terrain_at(step)):
			break
		step += telegraph.offset
	return out
