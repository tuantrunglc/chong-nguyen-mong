extends GutTest
## Luật đi của tướng (Story 1.4): tầm đi, đi xuyên quân mình, vật chặn, đường đi theo B→Đ→N→T.
## Chỉ số tự đặt trong test, không dựa vào data/chi_so.json (tác giả được sửa).

const EMPTY: Array[String] = [
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
]


func _stats(move_range: int = 3) -> Stats:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": move_range}
	for type: int in [UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY]:
		values[type] = {"mau": 2, "tam_di": 2}
	return Stats.new(values)


## Dựng state từ hai lớp bàn cờ chữ (ký hiệu như file trận): tướng theo ký hiệu, quân Nguyên theo thứ tự đọc bàn.
## Cỡ bàn lấy từ lớp quân: số dòng là số hàng, số ô của dòng đầu là số cột.
func _state(units: Array[String], terrain: Array[String] = EMPTY, stats: Stats = _stats()) -> BattleState:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(BoardText.split_row(units[0]).size(), units.size())
	var generals: Array[LevelData.UnitPlacement] = []
	var enemies: Array[LevelData.UnitPlacement] = []
	for r: int in range(level.size.y):
		var terrain_row: PackedStringArray = BoardText.split_row(terrain[r])
		var unit_row: PackedStringArray = BoardText.split_row(units[r])
		for c: int in range(level.size.x):
			level.terrain.append(BoardText.TERRAIN_SYMBOLS[terrain_row[c]] as int)
			var type: int = BoardText.UNIT_SYMBOLS[unit_row[c]] as int
			if type == BoardText.NO_UNIT:
				continue
			var placement: LevelData.UnitPlacement = LevelData.UnitPlacement.new(type, Vector2i(c, r))
			if UnitType.is_general(type):
				generals.append(placement)
			else:
				enemies.append(placement)
	generals.sort_custom(func(a: LevelData.UnitPlacement, b: LevelData.UnitPlacement) -> bool: return a.type < b.type)
	level.units.append_array(generals)
	level.units.append_array(enemies)
	if level.terrain.has(Terrain.VILLAGE):
		level.long_dan = 3
	var state: BattleState = BattleState.from_level(level, stats)
	assert_eq(state.validate(), [] as Array[String], "bàn thử hợp lệ")
	return state


## Bàn EMPTY, ô (c, r) thay bằng ký hiệu.
func _rows(cells: Dictionary) -> Array[String]:
	var rows: Array[String] = []
	for r: int in range(EMPTY.size()):
		var row: PackedStringArray = BoardText.split_row(EMPTY[r])
		for c: int in range(row.size()):
			if cells.has(Vector2i(c, r)):
				row[c] = cells[Vector2i(c, r)] as String
		rows.append(" ".join(row))
	return rows


func _reachable(state: BattleState, id: int = 1) -> Array[Vector2i]:
	return RulesMove.reachable(state, state.unit_by_id(id))


## Ô và máu của mọi quân, để so state trước/sau.
func _picture(state: BattleState) -> Array:
	var out: Array = []
	for u: Unit in state.units:
		out.append([u.id, u.type, u.cell, u.hp])
	return out


# ---------- Ô đi tới được ----------

func test_center_reaches_diamond_of_24_cells() -> void:
	var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(3, 3): "1"})))
	assert_eq(cells.size(), 24, "25 ô kim cương trừ ô đang đứng")
	for cell: Vector2i in cells:
		var steps: int = absi(cell.x - 3) + absi(cell.y - 3)
		assert_between(steps, 1, 3, "ô %s cách 1–3 bước" % cell)


func test_move_range_comes_from_stats() -> void:
	var state: BattleState = _state(_rows({Vector2i(3, 3): "1"}), EMPTY, _stats(2))
	assert_eq(_reachable(state).size(), 12, "tam_di 2: 13 ô kim cương trừ ô đang đứng")


func test_cells_come_in_reading_order() -> void:
	var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(3, 3): "1"}), EMPTY, _stats(1)))
	assert_eq(cells, [Vector2i(3, 2), Vector2i(2, 3), Vector2i(4, 3), Vector2i(3, 4)] as Array[Vector2i])


## terrain_at không tự kiểm biên: ô x = -1 mà lọt vào thì đọc nhầm ô cuối của hàng trên.
func test_corner_never_leaves_board() -> void:
	var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(0, 0): "1"})))
	assert_eq(cells.size(), 9, "góc: 10 ô trong bàn cách ≤ 3 bước, trừ ô đang đứng")
	for cell: Vector2i in cells:
		assert_true(cell.x >= 0 and cell.y >= 0 and cell.x < 7 and cell.y < 7, "ô %s trong bàn" % cell)


func test_passes_through_ally_but_never_stops_on_it() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1", Vector2i(1, 6): "2"}))
	var cells: Array[Vector2i] = _reachable(state)
	assert_has(cells, Vector2i(3, 6), "đi xuyên ô của Lão tới ô thứ 3")
	assert_does_not_have(cells, Vector2i(1, 6), "không dừng trên ô của Lão")


func test_enemy_blocks_the_way() -> void:
	var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(0, 6): "1", Vector2i(1, 6): "B"})))
	assert_does_not_have(cells, Vector2i(1, 6), "không dừng trên quân Nguyên")
	assert_does_not_have(cells, Vector2i(2, 6), "đi vòng mất 4 bước")
	assert_has(cells, Vector2i(2, 5), "đi vòng lên hàng trên thì tới")


func test_blocking_terrain() -> void:
	for symbol: String in ["~", "#", "L", "D"]:
		var terrain: Array[String] = _rows({Vector2i(1, 6): symbol})
		var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(0, 6): "1"}), terrain))
		assert_does_not_have(cells, Vector2i(1, 6), "%s: không vào được" % symbol)
		assert_does_not_have(cells, Vector2i(2, 6), "%s: đi vòng mất 4 bước" % symbol)


func test_spikes_and_pass_are_walkable() -> void:
	var terrain: Array[String] = _rows({Vector2i(1, 6): "^", Vector2i(2, 6): "A"})
	var cells: Array[Vector2i] = _reachable(_state(_rows({Vector2i(0, 6): "1"}), terrain))
	assert_has(cells, Vector2i(1, 6))
	assert_has(cells, Vector2i(2, 6))
	assert_has(cells, Vector2i(3, 6), "đi qua hầm chông và ô ải")


# ---------- Đường đi ----------

func test_path_prefers_north_then_east() -> void:
	var state: BattleState = _state(_rows({Vector2i(3, 3): "1"}))
	var khoai: Unit = state.unit_by_id(1)
	assert_eq(RulesMove.path_to(state, khoai, Vector2i(4, 2)), [Vector2i(3, 2), Vector2i(4, 2)] as Array[Vector2i])
	assert_eq(RulesMove.path_to(state, khoai, Vector2i(2, 4)), [Vector2i(3, 4), Vector2i(2, 4)] as Array[Vector2i],
		"không có hướng B/Đ dẫn tới: N trước rồi T")


func test_path_goes_around_river() -> void:
	var terrain: Array[String] = _rows({Vector2i(1, 6): "~"})
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1"}), terrain)
	assert_eq(RulesMove.path_to(state, state.unit_by_id(1), Vector2i(2, 5)),
		[Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)] as Array[Vector2i])


func test_path_to_unreachable_cell_is_empty() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1"}))
	assert_eq(RulesMove.path_to(state, state.unit_by_id(1), Vector2i(4, 6)), [] as Array[Vector2i])


func test_results_are_deterministic() -> void:
	var state: BattleState = _state(_rows({Vector2i(3, 3): "1", Vector2i(3, 2): "2", Vector2i(4, 3): "B"}))
	var khoai: Unit = state.unit_by_id(1)
	assert_eq(_reachable(state), _reachable(state))
	for cell: Vector2i in _reachable(state):
		assert_eq(RulesMove.path_to(state, khoai, cell), RulesMove.path_to(state, khoai, cell))


# ---------- Lệnh đi ----------

func test_move_walks_cell_by_cell() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1", Vector2i(1, 6): "2"}))
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(3, 6)))
	assert_eq(events.size(), 3, "3 ô, 3 sự kiện")
	var from: Vector2i = Vector2i(0, 6)
	for i: int in range(events.size()):
		assert_eq(events[i].type, BattleEvent.Type.MOVED)
		assert_eq(events[i].unit_id, 1)
		assert_eq(events[i].cause, BattleEvent.Cause.WALK)
		assert_eq(events[i].from_cell, from)
		assert_eq(events[i].to_cell, Vector2i(i + 1, 6))
		from = events[i].to_cell
	assert_eq(state.unit_by_id(1).cell, Vector2i(3, 6))
	assert_eq(state.unit_by_id(2).cell, Vector2i(1, 6), "Lão đứng yên")
	assert_eq(state.validate(), [] as Array[String])


func test_rejected_moves_change_nothing() -> void:
	var units: Array[String] = _rows({Vector2i(0, 6): "1", Vector2i(1, 6): "2", Vector2i(0, 4): "B"})
	var cases: Array[Array] = [
		[Command.move(1, Vector2i(4, 6)), "quân 1 không đi tới được ô 4,6", BattleEvent.Reject.UNREACHABLE],
		[Command.move(1, Vector2i(1, 6)), "quân 1 không đi tới được ô 1,6", BattleEvent.Reject.UNREACHABLE],
		[Command.move(1, Vector2i(0, 4)), "quân 1 không đi tới được ô 0,4", BattleEvent.Reject.UNREACHABLE],
		[Command.move(1, Vector2i(0, 6)), "quân 1 đã đứng ở ô 0,6", BattleEvent.Reject.ALREADY_THERE],
		[Command.move(3, Vector2i(0, 5)), "không có quân 3", BattleEvent.Reject.NO_UNIT],
		[Command.move(101, Vector2i(0, 3)), "quân 101 không phải tướng", BattleEvent.Reject.NOT_GENERAL],
	]
	for item: Array in cases:
		var state: BattleState = _state(units)
		var before: Array = _picture(state)
		var events: Array[BattleEvent] = Rules.resolve(state, item[0] as Command)
		assert_eq(events.size(), 1, item[1] as String)
		assert_eq(events[0].type, BattleEvent.Type.REJECTED)
		assert_eq(events[0].reason, item[1] as String)
		assert_eq(events[0].reject, item[2] as BattleEvent.Reject, item[1] as String)
		assert_eq(_picture(state), before, "state giữ nguyên: " + (item[1] as String))
		assert_eq(state.validate(), [] as Array[String])


func test_blocked_by_terrain_is_rejected() -> void:
	var terrain: Array[String] = _rows({Vector2i(1, 6): "~"})
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1"}), terrain)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(2, 6)))
	assert_eq(events.size(), 1)
	assert_eq(events[0].type, BattleEvent.Type.REJECTED)
	assert_eq(events[0].reject, BattleEvent.Reject.UNREACHABLE)
	assert_eq(state.unit_by_id(1).cell, Vector2i(0, 6))
	assert_eq(state.validate(), [] as Array[String])


# ---------- Mỗi tướng đi một lần mỗi lượt (Story 1.5) ----------

func test_move_sets_has_moved_and_empties_reachable() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1", Vector2i(1, 6): "2"}))
	assert_false(state.unit_by_id(1).has_moved)
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	assert_true(state.unit_by_id(1).has_moved)
	assert_false(state.unit_by_id(2).has_moved, "Lão chưa đi")
	assert_eq(_reachable(state, 1), [] as Array[Vector2i], "đã đi thì không còn ô sáng")
	assert_eq(RulesMove.path_to(state, state.unit_by_id(1), Vector2i(0, 3)), [] as Array[Vector2i])
	assert_eq(state.validate(), [] as Array[String])


func test_second_move_in_turn_is_rejected() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1"}))
	Rules.resolve(state, Command.move(1, Vector2i(1, 6)))
	var before: Array = _picture(state)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(2, 6)))
	assert_eq(events.size(), 1)
	assert_eq(events[0].type, BattleEvent.Type.REJECTED)
	assert_eq(events[0].reject, BattleEvent.Reject.ALREADY_MOVED)
	assert_eq(events[0].reason, "quân 1 đã đi rồi trong lượt này")
	assert_eq(_picture(state), before, "state giữ nguyên")
	assert_eq(state.validate(), [] as Array[String])


func test_rejected_move_does_not_count_as_moved() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1"}))
	Rules.resolve(state, Command.move(1, Vector2i(4, 6)))
	assert_false(state.unit_by_id(1).has_moved, "đi không được thì chưa tính là đã đi")
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(3, 6)))
	assert_eq(events[events.size() - 1].type, BattleEvent.Type.MOVED)
	assert_eq(state.unit_by_id(1).cell, Vector2i(3, 6))
	assert_eq(state.validate(), [] as Array[String])


func test_other_general_still_moves_after_one_moved() -> void:
	var state: BattleState = _state(_rows({Vector2i(0, 6): "1", Vector2i(1, 6): "2"}))
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	Rules.resolve(state, Command.move(2, Vector2i(1, 3)))
	assert_eq(state.unit_by_id(2).cell, Vector2i(1, 3))
	assert_true(state.unit_by_id(2).has_moved)
	assert_eq(state.validate(), [] as Array[String])


## Bàn 10×8 (Story 1.9): đi từ góc dưới phải tới đủ 3 ô theo hàng và theo cột, không ra ngoài bàn.
func test_reachable_on_large_board_stays_inside() -> void:
	var size: Vector2i = Vector2i(10, 8)
	var state: BattleState = BoardFixture.state({Vector2i(9, 7): "1"}, {}, {}, size)
	var cells: Array[Vector2i] = _reachable(state)
	assert_has(cells, Vector2i(9, 4))
	assert_has(cells, Vector2i(6, 7))
	for cell: Vector2i in cells:
		assert_true(Rect2i(Vector2i.ZERO, size).has_point(cell), "ô %s trong bàn" % cell)
