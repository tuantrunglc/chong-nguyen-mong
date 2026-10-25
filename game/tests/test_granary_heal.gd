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
		assert_eq(he.to_cell, Vector2i(3, 1), "ô được hồi là to_cell 3,1")
		assert_eq(he.cause, BattleEvent.Cause.HEAL, "nguyên nhân là HEAL")

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
	if heal_events.size() > 0:
		assert_eq(heal_events[0].to_cell, Vector2i(3, 2), "ô hồi là to_cell 3,2")
		assert_eq(heal_events[0].cause, BattleEvent.Cause.HEAL, "nguyên nhân là HEAL")

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
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 0, "tướng ta không hồi máu từ kho lương (không có bất kỳ sự kiện HEALED nào)")

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
		assert_eq(heal_events[0].to_cell, Vector2i(3, 1), "ô của B1 là 3,1")
		assert_eq(heal_events[1].unit_id, 102, "K hồi sau")
		assert_eq(heal_events[1].to_cell, Vector2i(4, 2), "ô của K là 4,2")

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


func test_enemy_friendly_fired_heals_at_end_of_round() -> void:
	# B kề kho lương L, K ở phía trên báo đòn xuống Nam trúng B (đánh nhầm)
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 0): "K", Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"}
	)
	# Cài đặt đòn báo của K xung phong Nam trúng B
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(0, 1), 1))

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String], "validate sạch")

	# Kiểm tra trong các sự kiện: K ra đòn -> B bị thương -> B hồi máu
	var attack_ev: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.ATTACKED and e.unit_id == 101
	)
	var dmg_ev: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.DAMAGED and e.unit_id == 102
	)
	var heal_ev: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED and e.unit_id == 102
	)
	assert_eq(attack_ev.size(), 1, "K có ra đòn đánh nhầm đồng đội")
	assert_eq(dmg_ev.size(), 1, "B bị mất 1 máu do đòn địch")
	assert_eq(heal_ev.size(), 1, "B được kho lương hồi lại 1 máu ngay cuối hiệp")

	var b: Unit = state.unit_by_id(102)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 3, "B mất 1 máu rồi hồi 1 máu nên trở về 3/3 máu")


func test_no_heal_if_battle_ends_during_strike_phase() -> void:
	# Trận thua ngay trong pha ra đòn của địch: tướng duy nhất gục vì đòn địch
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 0): "B", Vector2i(3, 1): "1", Vector2i(1, 1): "B"},
		{Vector2i(1, 2): "L"},
		{Vector2i(1, 1): 1, Vector2i(3, 1): 1}
	)
	# Bộ binh 101 ở 3,0 báo đòn Nam trúng Khoái 1 ở 3,1 (Khoái chỉ còn 1 máu)
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 1), 1))

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.LOST, "trận đã thua vì tướng duy nhất gục")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 0, "trận hết giữa lúc ra đòn thì không chạy hồi máu cuối hiệp")

	var b_near_granary: Unit = state.unit_by_id(102)
	assert_not_null(b_near_granary)
	if b_near_granary != null:
		assert_eq(b_near_granary.hp, 1, "Bộ binh kề kho lương không được hồi máu vì trận đã kết thúc")


func test_last_round_heals_before_round_limit_defeat() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 1): 1}
	)
	state.max_rounds = 1 # Giới hạn 1 hiệp
	state.round_number = 1

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.phase, BattleState.Phase.LOST, "thua do hết hiệp")
	assert_eq(state.defeat_reason, "het_hiep", "lý do thua là het_hiep")

	# Kiểm tra B vẫn được hồi máu trước khi xử thua
	var heal_idx: int = -1
	var defeat_idx: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.HEALED:
			heal_idx = i
		elif events[i].type == BattleEvent.Type.DEFEAT:
			defeat_idx = i

	assert_gt(heal_idx, -1, "có sự kiện HEALED ở cuối hiệp")
	assert_gt(defeat_idx, -1, "có sự kiện DEFEAT ở cuối hiệp")
	assert_lt(heal_idx, defeat_idx, "sự kiện HEALED phải xuất hiện trước DEFEAT")

	var b: Unit = state.unit_by_id(101)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 2, "B vẫn có 2 máu sau khi hồi trước khi thua")


func test_begin_battle_does_not_heal() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"},
		{Vector2i(3, 1): 1}
	)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.begin_battle())
	assert_eq(state.validate(), [] as Array[String], "validate sạch sau begin_battle")

	var heal_events: Array[BattleEvent] = events.filter(
		func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.HEALED
	)
	assert_eq(heal_events.size(), 0, "begin_battle không có sự kiện HEALED")

	var b: Unit = state.unit_by_id(101)
	assert_not_null(b)
	if b != null:
		assert_eq(b.hp, 1, "máu giữ nguyên 1 sau begin_battle")


func test_event_order_strike_healed_round_started() -> void:
	var state: BattleState = BoardFixture.state(
		{Vector2i(3, 0): "K", Vector2i(3, 1): "B", Vector2i(0, 6): "1"},
		{Vector2i(3, 2): "L"}
	)
	# K báo đòn xuống Nam trúng B (đánh nhầm)
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(0, 1), 1))

	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())

	var strike_idx: int = -1
	var heal_idx: int = -1
	var round_start_idx: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.ATTACKED and events[i].cause == BattleEvent.Cause.ENEMY_STRIKE:
			strike_idx = i
		elif events[i].type == BattleEvent.Type.HEALED:
			heal_idx = i
		elif events[i].type == BattleEvent.Type.ROUND_STARTED:
			round_start_idx = i

	assert_gt(strike_idx, -1, "có đòn đánh của địch")
	assert_gt(heal_idx, -1, "có hồi máu")
	assert_gt(round_start_idx, -1, "có sang hiệp")
	assert_lt(strike_idx, heal_idx, "đòn đánh địch ra trước hồi máu")
	assert_lt(heal_idx, round_start_idx, "hồi máu trước khi bắt đầu hiệp mới")
