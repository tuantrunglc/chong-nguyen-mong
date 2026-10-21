extends GutTest
## Ô đỏ báo đòn (Story 2.7): TelegraphMarks. Ca chính nằm trong kịch bản tests/kich_ban/don_dich/; ở đây là các ca
## biên kịch bản không có. Đòn dựng tay để thử cả chủ đòn đã gục và ô đích ngoài bàn.

const EAST: Vector2i = Vector2i(1, 0)
const WEST: Vector2i = Vector2i(-1, 0)


func _cell(owner_id: int, offset: Vector2i, order: int) -> Telegraph:
	return Telegraph.new(owner_id, Telegraph.Kind.CELL, offset, order)


func _charge(owner_id: int, dir: Vector2i, order: int) -> Telegraph:
	return Telegraph.new(owner_id, Telegraph.Kind.DIRECTION, dir, order)


func _row(from_x: int, to_x: int, y: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for x: int in range(from_x, to_x + 1):
		out.append(Vector2i(x, y))
	return out


func test_cell_attack_of_fallen_owner_is_not_drawn() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	state.telegraphs.append(_cell(101, Vector2i(0, 1), 1))
	state.units.erase(state.unit_by_id(101))
	assert_eq(TelegraphMarks.hit_cell(state, state.telegraphs[0]), Telegraph.NO_CELL)
	assert_eq(TelegraphMarks.path_cells(state, state.telegraphs[0]), [] as Array[Vector2i])
	assert_eq(TelegraphMarks.cells(state), {})


func test_cell_attack_off_board_is_not_drawn() -> void:
	# Bộ binh bị đẩy sát mép: ô đích dịch theo, ra ngoài bàn.
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "B", Vector2i(6, 6): "1"})
	state.telegraphs.append(_cell(101, WEST, 1))
	assert_eq(TelegraphMarks.hit_cell(state, state.telegraphs[0]), Telegraph.NO_CELL)
	assert_eq(TelegraphMarks.cells(state), {})


func test_cell_attack_on_empty_cell_is_still_red() -> void:
	# Tướng đã rời ô: đòn vẫn đánh vào ô, ô vẫn đỏ.
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(6, 6): "1"})
	state.telegraphs.append(_cell(101, Vector2i(0, 1), 1))
	assert_eq(TelegraphMarks.hit_cell(state, state.telegraphs[0]), Vector2i(3, 4))
	assert_eq(TelegraphMarks.cells(state), {Vector2i(3, 4): [1] as Array[int]})


func test_cavalry_at_edge_facing_out_has_no_cells() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(6, 6): "1"})
	state.telegraphs.append(_charge(101, WEST, 1))
	assert_eq(TelegraphMarks.path_cells(state, state.telegraphs[0]), [] as Array[Vector2i])
	assert_eq(TelegraphMarks.hit_cell(state, state.telegraphs[0]), Telegraph.NO_CELL)
	assert_eq(TelegraphMarks.cells(state), {})


func test_cavalry_of_fallen_owner_is_not_drawn() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 3): "1"})
	state.telegraphs.append(_charge(101, EAST, 1))
	state.units.erase(state.unit_by_id(101))
	assert_eq(TelegraphMarks.path_cells(state, state.telegraphs[0]), [] as Array[Vector2i])
	assert_eq(TelegraphMarks.cells(state), {})


func test_cavalry_stops_on_and_includes_blocking_terrain() -> void:
	for symbol: String in ["#", "L", "D"]:
		var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(5, 3): "1"},
			{Vector2i(2, 3): symbol})
		var t: Telegraph = _charge(101, EAST, 1)
		state.telegraphs.append(t)
		assert_eq(TelegraphMarks.path_cells(state, t), _row(1, 2, 3), "dừng ở ô %s, gồm ô đó" % symbol)
		assert_eq(TelegraphMarks.hit_cell(state, t), Vector2i(2, 3), "trúng ô %s" % symbol)


func test_cavalry_stops_on_other_enemy() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(3, 3): "B", Vector2i(5, 3): "1"})
	var t: Telegraph = _charge(101, EAST, 1)
	state.telegraphs.append(t)
	assert_eq(TelegraphMarks.path_cells(state, t), _row(1, 3, 3), "quân Nguyên khác cũng chắn")
	assert_eq(TelegraphMarks.hit_cell(state, t), Vector2i(3, 3))


func test_cavalry_on_large_board_runs_to_far_edge() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 7): "K", Vector2i(0, 0): "1"}, {}, {}, Vector2i(10, 8))
	var t: Telegraph = _charge(101, EAST, 1)
	state.telegraphs.append(t)
	assert_eq(TelegraphMarks.path_cells(state, t), _row(1, 9, 7), "bàn 10×8: tới cột 9")
	assert_eq(TelegraphMarks.hit_cell(state, t), Vector2i(9, 7), "hàng trống: trúng ô sát mép")


func test_three_attacks_on_one_cell_sorted() -> void:
	# Đòn ghi trong state theo thứ tự 1, 2, 3; ô chung nhận đủ ba số, tăng dần.
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B", Vector2i(2, 3): "B", Vector2i(4, 3): "B",
		Vector2i(3, 3): "1"})
	state.telegraphs.append(_cell(101, Vector2i(0, 1), 1))
	state.telegraphs.append(_cell(102, EAST, 2))
	state.telegraphs.append(_cell(103, WEST, 3))
	assert_eq(TelegraphMarks.cells(state), {Vector2i(3, 3): [1, 2, 3] as Array[int]})


func test_cells_does_not_change_state() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(4, 2): "B", Vector2i(4, 3): "1"})
	state.telegraphs.append(_charge(101, EAST, 1))
	state.telegraphs.append(_cell(102, Vector2i(0, 1), 2))
	var before: Array[String] = BoardFixture.picture(state)
	var shapes: Array[String] = []
	for t: Telegraph in state.telegraphs:
		shapes.append("%d %d %s %d" % [t.owner_id, t.kind, t.offset, t.order])
	TelegraphMarks.cells(state)
	assert_eq(BoardFixture.picture(state), before, "bàn không đổi")
	var after: Array[String] = []
	for t: Telegraph in state.telegraphs:
		after.append("%d %d %s %d" % [t.owner_id, t.kind, t.offset, t.order])
	assert_eq(after, shapes, "đòn không đổi")
