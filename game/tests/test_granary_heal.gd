extends GutTest
## Kiểm thử chuyên biệt cho cơ chế Kho lương và Hồi máu cuối hiệp (Story 3.9).


func test_enemy_heals_when_adjacent_to_granary() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 1): 1}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch sau kết thúc lượt")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 1, "có đúng 1 sự kiện HEALED")
	if heal_events.size() > 0:
		var he: BattleEvent = heal_events[0]
		assert_eq(he.unit_id, 101, "quân được hồi là Bộ binh")
		assert_eq(he.amount, 1, "hồi 1 máu")

	var b: Unit = state.unit_by_id(101)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 2, "Bộ binh hồi từ 1 lên 2 máu")


func test_enemy_adjacent_to_two_granaries_heals_only_once() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 2): "K", Vector2i(0, 6): "1"},
		{Vector2i(3, 1): "L", Vector2i(2, 2): "L"},
		{Vector2i(3, 2): 1}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch sau kết thúc lượt")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 1, "kề 2 kho lương nhưng chỉ hồi tối đa 1 máu mỗi hiệp")

	var k: Unit = state.unit_by_id(101)
	assert_not_null(k)
	if k != null:
		assert_eq(k.hp, 2, "Kỵ binh hồi từ 1 lên 2 máu")


func test_full_health_enemy_does_not_heal() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 0, "đầy máu không sinh sự kiện HEALED")

	var b: Unit = state.unit_by_id(101)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 3, "Bộ binh giữ nguyên máu tối đa 3")


func test_general_near_granary_does_not_heal() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "1", Vector2i(6, 6): "B"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 1): 2}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED and e.unit_id == 1
	)
	assert_eq(heal_events.size(), 0, "tướng ta không hồi máu từ kho lương")

	var khoai: Unit = state.unit_by_id(1)
	assert_not_null(khoai)
	if khoai != null:
		assert_eq(khoai.hp, 2, "máu tướng giữ nguyên 2")


func test_enemy_not_adjacent_does_not_heal() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 0): "B", Vector2i(6, 6): "1"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 0): 1}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 0, "không kề kho lương không hồi máu")

	var b: Unit = state.unit_by_id(101)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 1, "máu giữ nguyên 1")


func test_multiple_enemies_heal_in_deterministic_order() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "B", Vector2i(4, 2): "K", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 1): 1, Vector2i(4, 2): 1}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 2, "cả 2 quân đều được hồi máu")
	if heal_events.size() == 2:
		assert_eq(heal_events[0].unit_id, 101, "B1 hồi trước")
		assert_eq(heal_events[1].unit_id, 102, "K hồi sau")

	var b: Unit = state.unit_by_id(101)
	var k: Unit = state.unit_by_id(102)
	assert_not_null(b)
	assert_not_null(k)
	if b != null and k != null:
		assert_eq(b.hp, 2, "B hồi lên 2 máu")
		assert_eq(k.hp, 2, "K hồi lên 2 máu")


func test_granary_collision_damage() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(1, 1): "1", Vector2i(2, 1): "B"},
		{Vector2i(3, 1): "L"}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(2, 1)))
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	var coll: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.COLLIDED
	)
	assert_eq(coll.size(), 1, "có sự kiện va chạm vào kho lương")
	if coll.size() > 0:
		assert_eq(coll[0].to_cell, Vector2i(3, 1), "va chạm tại ô kho lương")
		assert_eq(coll[0].other_id, 0, "kho lương là vật cản không có id")

	var b: Unit = state.unit_by_id(101)
	assert_null(b, "Bộ binh nhận 2 sát thương đánh + 1 sát thương va chạm kho lương -> gục")
