extends GutTest
## Kết thúc lượt người chơi (Story 1.5): sang hiệp mới, mọi tướng đi lại được. Pha địch thêm ở E2.


func _state() -> BattleState:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": 3}
	values[UnitType.BO_BINH] = {"mau": 3, "tam_di": 2}
	var level: LevelData = LevelData.new()
	level.size = Vector2i(7, 7)
	for i: int in range(level.size.x * level.size.y):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(0, 6)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.PHAM_NGU_LAO, Vector2i(1, 6)))
	level.units.append(LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(5, 1), 2))
	return BattleState.from_level(level, Stats.new(values))


func _picture(state: BattleState) -> Array:
	var out: Array = []
	for u: Unit in state.units:
		out.append([u.id, u.cell, u.hp])
	return out


func test_end_turn_starts_next_round() -> void:
	var state: BattleState = _state()
	assert_eq(state.round_number, 1)
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 2)
	assert_eq(events[0].type, BattleEvent.Type.ROUND_STARTED, "sang hiệp trước, rồi mới tới pha địch chuẩn bị")
	assert_eq(events[0].round_number, 2)
	Rules.resolve(state, Command.end_turn())
	assert_eq(state.round_number, 3)
	assert_eq(state.validate(), [] as Array[String])


func test_end_turn_lets_every_general_move_again() -> void:
	var state: BattleState = _state()
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	Rules.resolve(state, Command.move(2, Vector2i(1, 3)))
	var before: Array = _picture(state).slice(0, 2)
	Rules.resolve(state, Command.end_turn())
	for u: Unit in state.units:
		assert_false(u.has_moved, "quân %d đi lại được" % u.id)
	assert_eq(_picture(state).slice(0, 2), before, "tướng không đổi ô, máu (quân Nguyên thì đi, Story 2.6)")
	assert_eq(RulesMove.reachable(state, state.unit_by_id(1)).is_empty(), false)
	assert_eq(state.validate(), [] as Array[String])


func test_end_turn_is_deterministic() -> void:
	var state: BattleState = _state()
	Rules.resolve(state, Command.move(1, Vector2i(0, 4)))
	var a: BattleState = state.clone()
	var b: BattleState = state.clone()
	var ea: Array[BattleEvent] = Rules.resolve(a, Command.end_turn())
	var eb: Array[BattleEvent] = Rules.resolve(b, Command.end_turn())
	assert_eq(ea.size(), eb.size())
	assert_eq(ea[0].round_number, eb[0].round_number)
	assert_eq(_picture(a), _picture(b))
	assert_eq(a.round_number, b.round_number)


# ---------- Pha địch chuẩn bị (Story 2.6) ----------

func test_prepare_moves_then_telegraphs_in_order() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(5, 2): "B", Vector2i(3, 3): "1"})
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(BoardFixture.describe(events), [
		"MOVED 101 3,0>3,1 WALK", "MOVED 101 3,1>3,2 WALK",
		"MOVED 102 5,2>5,3 WALK", "MOVED 102 5,3>4,3 WALK",
		"TELEGRAPHED 101 3,2>3,3 #1", "TELEGRAPHED 102 4,3>3,3 #2",
	] as Array[String])
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_eq(state.telegraphs.size(), 2)
	assert_eq(state.telegraphs[0].owner_id, 101)
	assert_eq(state.telegraphs[0].kind, Telegraph.Kind.CELL)
	assert_eq(state.telegraphs[0].offset, Vector2i(0, 1), "lưu tương đối so với chủ đòn")
	assert_eq(state.telegraphs[1].target_cell(state), Vector2i(3, 3))
	assert_eq(state.enemy_intents.size(), 2)
	assert_eq(state.enemy_intents[1].order, 2)
	assert_eq(state.validate(), [] as Array[String])


func test_prepare_clears_old_telegraphs() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(3, 6): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.telegraphs.size(), 0, "quân xa không báo đòn, đòn cũ bị xóa")
	assert_eq(state.enemy_intents.size(), 1)


func test_end_turn_runs_prepare_after_new_round() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(BoardFixture.describe(events), ["ROUND_STARTED", "TELEGRAPHED 101 3,3>3,4 #1"] as Array[String])
	assert_eq(state.round_number, 2)


func test_begin_battle_prepares_round_one() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 1): "B", Vector2i(3, 4): "1"})
	var events: Array[BattleEvent] = Rules.resolve(state, Command.begin_battle())
	assert_eq(BoardFixture.describe(events), [
		"MOVED 101 3,1>3,2 WALK", "MOVED 101 3,2>3,3 WALK", "TELEGRAPHED 101 3,3>3,4 #1",
	] as Array[String], "không sang hiệp, không ROUND_STARTED")
	assert_eq(state.round_number, 1)
	assert_eq(state.phase, BattleState.Phase.PLAYER)


func test_prepare_is_deterministic() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "K", Vector2i(6, 0): "B", Vector2i(3, 6): "B",
		Vector2i(2, 3): "1", Vector2i(4, 3): "2"})
	var a: BattleState = state.clone()
	var b: BattleState = state.clone()
	var ea: Array[BattleEvent] = []
	var eb: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(a, ea)
	RulesEnemyPhase.prepare(b, eb)
	assert_eq(BoardFixture.describe(ea), BoardFixture.describe(eb))
	assert_eq(BoardFixture.picture(a), BoardFixture.picture(b))
	assert_eq(_telegraph_lines(a), _telegraph_lines(b))
	assert_eq(_intent_lines(a), _intent_lines(b))
	assert_gt(a.telegraphs.size(), 0, "ca này có đòn để so")
	assert_eq(a.validate(), [] as Array[String])


func _telegraph_lines(state: BattleState) -> Array[String]:
	var out: Array[String] = []
	for t: Telegraph in state.telegraphs:
		out.append("%d %d %s #%d" % [t.owner_id, t.kind, t.offset, t.order])
	return out


func _intent_lines(state: BattleState) -> Array[String]:
	var out: Array[String] = []
	for i: EnemyIntent in state.enemy_intents:
		out.append("%d %s>%s %d %d #%d" % [i.unit_id, i.from_cell, i.stand_cell, i.target_id, i.reason, i.order])
	return out


func test_begin_battle_runs_only_once() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 0): "B", Vector2i(3, 3): "1"})
	var first: Array[BattleEvent] = []
	RulesEnemyPhase.begin_battle(state, first)
	assert_gt(first.size(), 0)
	var before: Array[String] = BoardFixture.picture(state)
	var telegraphs_before: Array[String] = _telegraph_lines(state)
	var again: Array[BattleEvent] = []
	RulesEnemyPhase.begin_battle(state, again)
	assert_eq(again.size(), 0, "gọi lại thì không làm gì")
	assert_eq(BoardFixture.picture(state), before)
	assert_eq(_telegraph_lines(state), telegraphs_before, "đòn đã báo không bị xóa")
	state.round_number = 2
	state.telegraphs.clear()
	state.enemy_intents.clear()
	RulesEnemyPhase.begin_battle(state, again)
	assert_eq(again.size(), 0, "giữa trận (hiệp 2) cũng không chạy")


func test_charge_blocked_by_later_ally_is_not_telegraphed() -> void:
	# Kỵ binh 101 ở 0,0 thấy đường thẳng xuống tướng 0,5 còn trống, nên chọn đứng yên. Bộ binh 102 (id lớn hơn, đi
	# sau) đi tới 0,4 (ô kề tướng, Bắc hơn 1,5) nên chắn đường: chỉ còn đòn của 102, 101 không báo.
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "K", Vector2i(1, 3): "B", Vector2i(0, 5): "1"})
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	assert_eq(state.unit_by_id(102).cell, Vector2i(0, 4), "Bộ binh đứng vào đường xung phong")
	assert_eq(state.unit_by_id(101).cell, Vector2i(0, 0))
	assert_eq(_telegraph_lines(state), ["102 0 (0, 1) #1"] as Array[String], "chỉ Bộ binh báo đòn, đánh số từ 1")
	assert_eq(state.enemy_intents[0].reason, EnemyIntent.Reason.CLOSEST, "Kỵ binh bị chắn: không còn là CAN_HIT")
	assert_eq(state.enemy_intents[0].order, 0)
	assert_eq(state.enemy_intents[1].order, 1)
	assert_eq(BoardFixture.describe(events), ["MOVED 102 1,3>1,4 WALK", "MOVED 102 1,4>0,4 WALK",
		"TELEGRAPHED 102 0,4>0,5 #1"] as Array[String])
	assert_eq(state.validate(), [] as Array[String])


# ---------- Ra đòn (Story 2.8) ----------
# Bàn dựng bằng BoardFixture (id quân Nguyên theo thứ tự đọc bàn), đòn dựng tay rồi Kết thúc lượt.

func _cell_attack(owner_id: int, offset: Vector2i, order: int) -> Telegraph:
	return Telegraph.new(owner_id, Telegraph.Kind.CELL, offset, order)


func _charge(owner_id: int, dir: Vector2i, order: int) -> Telegraph:
	return Telegraph.new(owner_id, Telegraph.Kind.DIRECTION, dir, order)


## Kết thúc lượt; trả mô tả các sự kiện tới trước ROUND_STARTED (gồm cả nó, nếu có).
func _strike(state: BattleState) -> Array[String]:
	var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
	assert_eq(state.validate(), [] as Array[String])
	var out: Array[String] = []
	for line: String in BoardFixture.describe(events):
		out.append(line)
		if line == "ROUND_STARTED":
			break
	return out


func test_infantry_hits_general_before_new_round() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	assert_eq(_strike(state), ["ATTACKED 101 3,4", "DAMAGED 1 -1 ENEMY_STRIKE", "ROUND_STARTED"] as Array[String])
	assert_eq(state.unit_by_id(1).cell, Vector2i(3, 4), "không đẩy")
	assert_eq(state.unit_by_id(1).hp, 2)
	assert_eq(state.round_number, 2)


## Sát thương lớn hơn máu còn lại: chỉ mất đúng số máu còn lại, quân gục (máu không xuống dưới 0).
func test_damage_larger_than_hp_only_takes_remaining_hp() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "K", Vector2i(6, 6): "1"})
	var values: Dictionary = {
		UnitType.NGUYEN_KHOAI: {"mau": 3, "tam_di": 3, "sat_thuong": 2, "do_day": 1},
		UnitType.BO_BINH: {"mau": 3, "tam_di": 2, "sat_thuong": 5},
		UnitType.KY_BINH: {"mau": 2, "tam_di": 3, "sat_thuong": 1},
	}
	state.stats = Stats.new(values)
	state.telegraphs.append(_cell_attack(state.unit_at(Vector2i(3, 3)).id, Vector2i(0, 1), 1))
	assert_eq(_strike(state), ["ATTACKED 101 3,4", "DAMAGED 102 -2 ENEMY_STRIKE", "DIED 102 3,4", "ROUND_STARTED"] as Array[String],
		"Kỵ binh 2 máu chịu sát thương 5: mất 2, không âm")
	assert_null(state.unit_by_id(102))


func test_cavalry_hits_granary_or_village_nobody_hurt() -> void:
	for symbol: String in ["L", "D"]:
		var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(5, 3): "1"},
			{Vector2i(2, 3): symbol})
		state.telegraphs.append(_charge(101, Vector2i(1, 0), 1))
		assert_eq(_strike(state), ["ATTACKED 101 2,3", "ROUND_STARTED"] as Array[String], "trúng ô %s" % symbol)
		assert_eq(state.unit_by_id(1).hp, 3)


func test_cavalry_on_empty_row_misses_at_edge() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(6, 6): "1"})
	state.telegraphs.append(_charge(101, Vector2i(1, 0), 1))
	assert_eq(_strike(state), ["ATTACKED 101 6,3", "ROUND_STARTED"] as Array[String], "trượt: ô sát mép, không ai mất máu")


func test_cavalry_on_large_board_hits_far_general() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 7): "K", Vector2i(9, 7): "1"}, {}, {}, Vector2i(10, 8))
	state.telegraphs.append(_charge(101, Vector2i(1, 0), 1))
	assert_eq(_strike(state), ["ATTACKED 101 9,7", "DAMAGED 1 -1 ENEMY_STRIKE", "ROUND_STARTED"] as Array[String])


func test_cavalry_at_edge_facing_out_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 3): "K", Vector2i(6, 6): "1"})
	state.telegraphs.append(_charge(101, Vector2i(-1, 0), 1))
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 101 0,3 #1 NO_TARGET", "ROUND_STARTED"] as Array[String])


func test_attack_of_owner_fallen_before_phase_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1", Vector2i(0, 0): "B"})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	state.units.erase(state.unit_by_id(101))
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 101 -1,-1 #1 OWNER_DIED", "ROUND_STARTED"] as Array[String])
	assert_eq(state.unit_by_id(1).hp, 3)


func test_attack_killing_next_owner_cancels_its_attack() -> void:
	# Bộ binh 3,2 (101) chém ô 3,3, nơi Bộ binh 102 (1 máu) đứng; đòn 2 của 102 nhắm Khoái nhưng 102 đã gục.
	var state: BattleState = BoardFixture.state({Vector2i(3, 2): "B", Vector2i(3, 3): "B", Vector2i(3, 4): "1"},
		{}, {Vector2i(3, 3): 1})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	state.telegraphs.append(_cell_attack(102, Vector2i(0, 1), 2))
	assert_eq(_strike(state), ["ATTACKED 101 3,3", "DAMAGED 102 -1 ENEMY_STRIKE", "DIED 102 3,3",
		"TELEGRAPH_CANCELLED 102 -1,-1 #2 OWNER_DIED", "ROUND_STARTED"] as Array[String])
	assert_eq(state.unit_by_id(1).hp, 3, "đòn 2 không ra")


func test_enemies_killing_each_other_is_not_victory() -> void:
	# Ở story này không thể thắng trong pha địch: quân ra đòn cuối luôn còn sống.
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 3): "B", Vector2i(3, 4): "B"},
		{}, {Vector2i(3, 3): 1, Vector2i(3, 4): 1})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	state.telegraphs.append(_cell_attack(102, Vector2i(0, -1), 2))
	var events: Array[String] = BoardFixture.describe(Rules.resolve(state, Command.end_turn()))
	assert_eq(events.slice(0, 5), ["ATTACKED 101 3,4", "DAMAGED 102 -1 ENEMY_STRIKE", "DIED 102 3,4",
		"TELEGRAPH_CANCELLED 102 -1,-1 #2 OWNER_DIED", "ROUND_STARTED"] as Array[String])
	assert_does_not_have(events, "VICTORY")
	assert_eq(state.phase, BattleState.Phase.PLAYER)
	assert_not_null(state.unit_by_id(101))


func test_last_general_falls_mid_phase_stops_everything() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1", Vector2i(5, 5): "B",
		Vector2i(5, 6): "B"}, {}, {Vector2i(3, 4): 1})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	state.telegraphs.append(_cell_attack(102, Vector2i(0, 1), 2))
	var events: Array[String] = BoardFixture.describe(Rules.resolve(state, Command.end_turn()))
	assert_eq(events, ["ATTACKED 101 3,4", "DAMAGED 1 -1 ENEMY_STRIKE", "DIED 1 3,4", "DEFEAT"] as Array[String],
		"thua là sự kiện cuối, có đúng một lần; đòn 2 không ra; không sang hiệp")
	assert_eq(state.phase, BattleState.Phase.LOST)
	assert_eq(state.round_number, 1)
	assert_eq(state.unit_by_id(103).hp, 3, "Bộ binh 5,6 không trúng đòn 2")
	assert_eq(state.telegraphs.size(), 2, "không chạy pha chuẩn bị: đòn còn nguyên")
	assert_eq(state.validate(), [] as Array[String])

# ---------- Hủy đòn (Story 2.9) ----------
# Đòn đã báo lưu tương đối nên tự dịch theo chủ đòn; ở đây kiểm ba đường hủy và sự kiện báo hủy.

## Đòn vào ô bị đẩy ra ngoài bàn: hủy, phát TELEGRAPH_CANCELLED, không sát thương ai.
func test_cell_telegraph_pushed_off_board_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 5): "B", Vector2i(0, 4): "1"})
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 1))
	Rules.resolve(state, Command.attack(1, Vector2i(0, 5)))
	assert_eq(state.unit_by_id(101).cell, Vector2i(0, 6), "Bộ binh bị đẩy xuống sát mép")
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 101 0,6 #1 OUT_OF_BOARD", "ROUND_STARTED"] as Array[String])


## Chủ đòn gục trước lượt ra đòn (chết đuối): hủy với lý do OWNER_DIED.
func test_owner_drowned_telegraph_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(6, 0): "B", Vector2i(2, 2): "B", Vector2i(2, 1): "1"},
		{Vector2i(2, 3): "~"})
	state.telegraphs.append(_cell_attack(102, Vector2i(0, 1), 1))
	Rules.resolve(state, Command.attack(1, Vector2i(2, 2)))
	assert_null(state.unit_by_id(102), "Bộ binh 102 chết đuối")
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 102 -1,-1 #1 OWNER_DIED", "ROUND_STARTED"] as Array[String])


## Kỵ binh báo xung phong khi ô ngay trước mặt đã ngoài bàn: hủy với lý do NO_TARGET.
func test_charge_with_first_step_off_board_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "K", Vector2i(3, 3): "1"})
	state.telegraphs.append(_charge(101, Vector2i(0, -1), 1))
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 101 0,0 #1 NO_TARGET", "ROUND_STARTED"] as Array[String])


## Đòn số 1 bị hủy thì đòn số 2 vẫn là số 2 và vẫn ra đòn: số thứ tự không dồn lại.
func test_cancelled_strike_does_not_renumber_others() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(0, 5): "B", Vector2i(3, 4): "2",
		Vector2i(0, 4): "1"})
	state.telegraphs.append(_cell_attack(102, Vector2i(0, 1), 1))
	state.telegraphs.append(_cell_attack(101, Vector2i(0, 1), 2))
	Rules.resolve(state, Command.attack(1, Vector2i(0, 5)))
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 102 0,6 #1 OUT_OF_BOARD", "ATTACKED 101 3,4",
		"DAMAGED 2 -1 ENEMY_STRIKE", "ROUND_STARTED"] as Array[String],
		"đòn số 2 giữ số, đánh vào Phạm Ngũ Lão")
	assert_eq(state.unit_by_id(2).hp, 2)


## Chủ đòn gục vì cú đẩy của chính nó (sát thương + va mép bàn): đòn bị hủy, mục tiêu không mất máu.
func test_owner_dying_from_push_into_edge_telegraph_is_cancelled() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 6): "B", Vector2i(0, 5): "1", Vector2i(4, 6): "2",
		Vector2i(4, 5): "B"})
	state.telegraphs.append(_cell_attack(102, Vector2i(0, -1), 1))
	var attack: Array[BattleEvent] = Rules.resolve(state, Command.attack(1, Vector2i(0, 6)))
	assert_eq(BoardFixture.describe(attack), ["ATTACKED 1 0,6", "DAMAGED 102 -2 STRIKE", "COLLIDED 102 0 0,7",
		"DAMAGED 102 -1 COLLISION", "DIED 102 0,6"] as Array[String], "va mép bàn làm gục")
	assert_eq(_strike(state), ["TELEGRAPH_CANCELLED 102 -1,-1 #1 OWNER_DIED", "ROUND_STARTED"] as Array[String])
	assert_eq(state.unit_by_id(2).hp, 3, "đòn của chủ đòn đã gục không trúng ai")
	assert_eq(state.telegraphs.size(), 1, "đòn bị hủy vẫn nằm trong danh sách đòn của hiệp")
