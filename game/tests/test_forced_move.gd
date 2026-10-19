extends GutTest
## Di chuyển cưỡng bức (Story 2.1): đẩy từng ô, va mép bàn, vật cản, quân khác, sông. Mỗi ca so cả dãy sự kiện.

const N: Vector2i = Vector2i(0, -1)
const E: Vector2i = Vector2i(1, 0)
const S: Vector2i = Vector2i(0, 1)
const W: Vector2i = Vector2i(-1, 0)


func _push(state: BattleState, id: int, dir: Vector2i, distance: int = 1) -> Array[String]:
	var events: Array[BattleEvent] = []
	ForcedMove.run(state, state.unit_by_id(id), dir, distance, BattleEvent.Cause.PUSH, events)
	assert_eq(state.validate(), [] as Array[String], "bất biến sau khi đẩy")
	return BoardFixture.describe(events)


func test_push_into_empty_cell() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"})
	assert_eq(_push(state, 101, N), ["MOVED 101 3,3>3,2 PUSH"] as Array[String])
	assert_eq(state.unit_by_id(101).cell, Vector2i(3, 2))
	assert_eq(state.unit_by_id(101).hp, 3)


## Kéo 2 ô (Story 2.4) dùng cùng vòng lặp: đi từng ô.
func test_push_two_cells_goes_one_cell_at_a_time() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"})
	assert_eq(_push(state, 101, E, 2), ["MOVED 101 3,3>4,3 PUSH", "MOVED 101 4,3>5,3 PUSH"] as Array[String])


func test_edge_in_every_direction() -> void:
	var cases: Array = [[Vector2i(3, 0), N], [Vector2i(6, 3), E], [Vector2i(3, 6), S], [Vector2i(0, 3), W]]
	for c: Array in cases:
		var cell: Vector2i = c[0] as Vector2i
		var dir: Vector2i = c[1] as Vector2i
		var state: BattleState = BoardFixture.state({cell: "B"})
		var outside: String = BoardText.cell_text(cell + dir)
		assert_eq(_push(state, 101, dir), ["COLLIDED 101 0 %s" % outside, "DAMAGED 101 -1 COLLISION"] as Array[String])
		assert_eq(state.unit_by_id(101).cell, cell, "đứng yên")
		assert_eq(state.unit_by_id(101).hp, 2)


func test_obstacles_stop_and_cost_one_hp() -> void:
	for symbol: String in ["#", "L", "D"]:
		var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {Vector2i(3, 2): symbol})
		assert_eq(_push(state, 101, N), ["COLLIDED 101 0 3,2", "DAMAGED 101 -1 COLLISION"] as Array[String], symbol)
		assert_eq(state.unit_by_id(101).cell, Vector2i(3, 3))
		assert_eq(state.unit_by_id(101).hp, 2)


## Quân bị đẩy mất máu trước, quân bị va sau.
func test_unit_collision_hurts_both() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 2): "K"})
	assert_eq(_push(state, 102, N), ["COLLIDED 102 101 3,2", "DAMAGED 102 -1 COLLISION",
		"DAMAGED 101 -1 COLLISION"] as Array[String])
	assert_eq(state.unit_by_id(101).hp, 1, "Kỵ binh bị va")
	assert_eq(state.unit_by_id(102).hp, 2, "Bộ binh bị đẩy")
	assert_eq(state.unit_by_id(102).cell, Vector2i(3, 3))


## Bị đẩy vào tướng mình: tướng cũng mất máu (Story 2.2 có kịch bản).
func test_collision_with_general_hurts_general() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 2): "2"})
	assert_eq(_push(state, 101, N), ["COLLIDED 101 2 3,2", "DAMAGED 101 -1 COLLISION",
		"DAMAGED 2 -1 COLLISION"] as Array[String])
	assert_eq(state.unit_by_id(2).hp, 2)


## Story 2.2 (AC 7): tướng gục vì va thì bị nhấc khỏi bàn, có DIED.
func test_collision_can_kill_general() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 2): "2"}, {}, {Vector2i(3, 2): 1})
	assert_eq(_push(state, 101, N), ["COLLIDED 101 2 3,2", "DAMAGED 101 -1 COLLISION",
		"DAMAGED 2 -1 COLLISION", "DIED 2 3,2"] as Array[String])
	assert_null(state.unit_by_id(2))
	assert_eq(state.unit_by_id(101).cell, Vector2i(3, 3))


func test_collision_can_kill_pushed_unit() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {Vector2i(3, 2): "#"}, {Vector2i(3, 3): 1})
	assert_eq(_push(state, 101, N), ["COLLIDED 101 0 3,2", "DAMAGED 101 -1 COLLISION",
		"DIED 101 3,3"] as Array[String])
	assert_null(state.unit_by_id(101), "nhấc khỏi bàn")
	assert_eq(state.units.size(), 0)


func test_collision_can_kill_both() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 2): "C"}, {}, {Vector2i(3, 3): 1})
	assert_eq(_push(state, 102, N), ["COLLIDED 102 101 3,2", "DAMAGED 102 -1 COLLISION", "DIED 102 3,3",
		"DAMAGED 101 -1 COLLISION", "DIED 101 3,2"] as Array[String])
	assert_eq(state.units.size(), 0)


func test_nguyen_unit_drowns_in_river() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {Vector2i(3, 2): "~"})
	assert_eq(_push(state, 101, N, 2), ["MOVED 101 3,3>3,2 PUSH", "DROWNED 101 3,2"] as Array[String],
		"chết đuối thì dừng, không đi tiếp")
	assert_null(state.unit_by_id(101))


## Tướng bị đẩy vào sông (Story 2.2, 2.4): tính như va chạm.
func test_general_pushed_into_river_collides() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "1"}, {Vector2i(3, 2): "~"})
	assert_eq(_push(state, 1, N), ["COLLIDED 1 0 3,2", "DAMAGED 1 -1 COLLISION"] as Array[String])
	assert_eq(state.unit_by_id(1).cell, Vector2i(3, 3))


## Hầm chông mất máu ở Story 3.4; ô ải như đất trống.
func test_spikes_and_pass_are_entered() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {Vector2i(3, 2): "^", Vector2i(3, 1): "A"})
	assert_eq(_push(state, 101, N, 2), ["MOVED 101 3,3>3,2 PUSH", "MOVED 101 3,2>3,1 PUSH"] as Array[String])
	assert_eq(state.unit_by_id(101).hp, 3)


func test_stops_after_first_collision() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {Vector2i(3, 2): "#"})
	assert_eq(_push(state, 101, N, 2), ["COLLIDED 101 0 3,2", "DAMAGED 101 -1 COLLISION"] as Array[String])


func test_damage_amount_is_what_was_lost() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B"}, {}, {Vector2i(3, 3): 1})
	var events: Array[BattleEvent] = []
	Effects.damage(state, state.unit_by_id(101), 2, BattleEvent.Cause.STRIKE, events)
	assert_eq(BoardFixture.describe(events), ["DAMAGED 101 -1 STRIKE", "DIED 101 3,3"] as Array[String])
