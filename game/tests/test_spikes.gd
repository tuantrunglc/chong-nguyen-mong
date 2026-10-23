extends GutTest
## Test luật hầm chông (Story 3.4): mất 1 máu mỗi ô đi qua, gục giữa đường, AI gục lúc đi,
## tướng chọn đường ít chông nhất, đứng yên không mất thêm máu.

const EMPTY: Array[String] = [
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
	". . . . . . .",
]


func _stats() -> Stats:
	var values: Dictionary = {}
	for type: int in UnitType.GENERALS:
		values[type] = {"mau": 3, "tam_di": 3, "sat_thuong": 1, "tam_danh": 3, "tam_keo": 2, "do_day": 1}
	for type: int in [UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY]:
		values[type] = {"mau": 3, "tam_di": 2, "sat_thuong": 1}
	return Stats.new(values)


func _state(units: Array[String], terrain: Array[String] = EMPTY) -> BattleState:
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
	var state: BattleState = BattleState.from_level(level, _stats())
	assert_eq(state.validate(), [] as Array[String], "bàn thử hợp lệ")
	return state


func test_hero_walking_into_spikes_takes_damage() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var events: Array[BattleEvent] = []
	RulesMove.resolve(state, Command.move(1, Vector2i(3, 4)), events)
	var hero: Unit = state.unit_by_id(1)
	assert_not_null(hero)
	assert_eq(hero.cell, Vector2i(3, 4))
	assert_eq(hero.hp, 2, "mất 1 máu khi bước vào ô chông")
	assert_eq(state.validate(), [] as Array[String])


func test_hero_walking_through_two_spikes_takes_two_damage() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var events: Array[BattleEvent] = []
	RulesMove.resolve(state, Command.move(1, Vector2i(3, 3)), events)
	var hero: Unit = state.unit_by_id(1)
	assert_not_null(hero)
	assert_eq(hero.cell, Vector2i(3, 3))
	assert_eq(hero.hp, 1, "mất 2 máu khi đi qua 2 ô chông")
	assert_eq(state.validate(), [] as Array[String])


func test_hero_dying_on_spikes_stops_immediately() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . 2 . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	Effects.damage(state, hero, 2, BattleEvent.Cause.STRIKE, [])
	var events: Array[BattleEvent] = []
	RulesMove.resolve(state, Command.move(1, Vector2i(3, 3)), events)
	assert_null(state.unit_by_id(1), "tướng đã gục và bị nhấc khỏi bàn")
	var died_index: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.DIED:
			died_index = i
			assert_eq(events[i].from_cell, Vector2i(3, 4), "gục tại ô chông đầu tiên")
	assert_true(died_index >= 0, "có sự kiện DIED")
	for i: int in range(died_index + 1, events.size()):
		assert_ne(events[i].type, BattleEvent.Type.MOVED, "không có MOVED sau khi đã DIED")
	assert_eq(state.validate(), [] as Array[String])


func test_enemy_pulled_onto_spikes_and_dying_stops_immediately() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		"B . . . . . .",
		". . . . . . .",
		". . . C . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 3 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy: Unit = state.unit_at(Vector2i(3, 2))
	Effects.damage(state, enemy, 2, BattleEvent.Cause.STRIKE, [])  # Cung kỵ còn 1 máu
	var events: Array[BattleEvent] = []
	RulesAttack.resolve(state, Command.attack(3, Vector2i(3, 2)), events)
	assert_null(state.unit_at(Vector2i(3, 3)), "Cung kỵ đã gục tại 3,3 và bị nhấc khỏi bàn")
	assert_null(state.unit_at(Vector2i(3, 4)), "không bị kéo tiếp sang 3,4")
	var died_index: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.DIED:
			died_index = i
			assert_eq(events[i].from_cell, Vector2i(3, 3))
	assert_true(died_index >= 0)
	for i: int in range(died_index + 1, events.size()):
		assert_ne(events[i].type, BattleEvent.Type.MOVED, "không bị kéo thêm sau khi gục")
	assert_eq(state.validate(), [] as Array[String])


func test_enemy_pushed_onto_spikes_and_dying_stops_immediately() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		"B . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . B . . .",
		". . . 1 . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy: Unit = state.unit_at(Vector2i(3, 3))
	Effects.damage(state, enemy, 1, BattleEvent.Cause.STRIKE, [])  # còn 2 máu
	# Khoái đánh gây 1 sát thương (stats thử: 1), đẩy 1 bước vào (3,2)[^] -> mất 1 chông -> gục tại 3,2
	var events: Array[BattleEvent] = []
	RulesAttack.resolve(state, Command.attack(1, Vector2i(3, 3)), events)
	assert_null(state.unit_at(Vector2i(3, 2)), "gục tại ô chông")
	var died_index: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.DIED:
			died_index = i
	assert_true(died_index >= 0)
	for i: int in range(died_index + 1, events.size()):
		assert_ne(events[i].type, BattleEvent.Type.MOVED)
	assert_eq(state.validate(), [] as Array[String])


func test_standing_on_spikes_takes_no_damage() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . B . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	assert_eq(hero.hp, 3)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)
	assert_eq(hero.hp, 3, "đứng yên trên ô chông qua lượt không mất máu")
	assert_eq(state.validate(), [] as Array[String])


func test_hero_pathfinding_avoids_spikes() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	var path: Array[Vector2i] = RulesMove.path_to(state, hero, Vector2i(4, 4))
	assert_eq(path, [Vector2i(4, 5), Vector2i(4, 4)], "chọn đường Đông-Bắc để tránh hầm chông ở (3,4)")
	assert_eq(state.validate(), [] as Array[String])


func test_hero_pathfinding_longer_clean_path_beats_shorter_spikes_path() -> void:
	# Bắt đầu (2,4), đích (4,4), max_steps = 4:
	# Đường 1: (2,4) -> (3,4)[^] -> (4,4) [2 bước, 1 chông]
	# Đường 2: (2,4) -> (2,3) -> (3,3) -> (4,3) -> (4,4) [4 bước, 0 chông]
	# Lõi AC4: đường ít chông nhất thắng dù dài bước hơn.
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . 1 . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	var paths: Dictionary = Pathfinding.find_paths(state, hero, 4)
	assert_true(paths.has(Vector2i(4, 4)))
	assert_eq(paths[Vector2i(4, 4)], [Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(4, 4)],
		"đường vòng 4 bước sạch chông thắng đường thẳng 2 bước có chông")
	assert_eq(state.validate(), [] as Array[String])


func test_enemy_pathfinding_does_not_avoid_spikes() -> void:
	# Quân xuất phát (3,3), đích (4,2), max_steps = 2:
	# Hướng B->Đ->N->T:
	# Đi Bắc trước: (3,3) -> (3,2)[^] -> (4,2) [2 bước, 1 chông]
	# Đi Đông trước: (3,3) -> (4,3)[.] -> (4,2) [2 bước, 0 chông]
	# Vì Bắc xét trước Đông, BFS quân Nguyên chọn đường qua chông (3,2).
	# Trong khi tướng sẽ chọn đường sạch chông qua (4,3).
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . B . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy: Unit = state.unit_by_id(101)
	var paths: Dictionary = Pathfinding.find_paths(state, enemy, 2)
	assert_true(paths.has(Vector2i(4, 2)))
	assert_eq(paths[Vector2i(4, 2)], [Vector2i(3, 2), Vector2i(4, 2)],
		"quân Nguyên đi theo BFS B->Đ nên chọn ô chông (3,2)")
	assert_eq(state.validate(), [] as Array[String])


func test_enemy_dying_on_spikes_during_preparation_does_not_telegraph_while_other_does() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . B . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . B .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy1: Unit = state.unit_at(Vector2i(3, 2))
	Effects.damage(state, enemy1, 2, BattleEvent.Cause.STRIKE, [])  # 1 HP
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.end_player_turn(state, events)
	assert_null(state.unit_by_id(enemy1.id), "địch 1 gục trên chông")
	for t: Telegraph in state.telegraphs:
		assert_ne(t.owner_id, enemy1.id, "địch gục không có đòn báo")
	assert_eq(state.telegraphs.size(), 1, "chỉ địch 2 sống sót báo đòn")
	assert_eq(state.telegraphs[0].order, 1)
	assert_eq(state.validate(), [] as Array[String])


func test_last_hero_dying_on_spikes_triggers_defeat() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		"B . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	Effects.damage(state, hero, 2, BattleEvent.Cause.STRIKE, [])  # 1 HP
	var events: Array[BattleEvent] = Rules.resolve(state, Command.move(1, Vector2i(3, 4)))
	assert_null(state.unit_by_id(1), "tướng gục")
	assert_true(Rules.is_battle_over(state), "trận kết thúc")
	assert_eq(events[events.size() - 1].type, BattleEvent.Type.DEFEAT, "thua trận khi tướng cuối gục")
	assert_eq(state.validate(), [] as Array[String])


func test_unit_survives_spikes_and_collides_when_pushed() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . # . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . B . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy: Unit = state.unit_at(Vector2i(3, 3))
	var events: Array[BattleEvent] = []
	# Đẩy 2 bước lên phía Bắc: (3,2)[^] -> (3,1)[*]
	ForcedMove.run(state, enemy, Vector2i.UP, 2, BattleEvent.Cause.PUSH, events)
	assert_eq(enemy.cell, Vector2i(3, 2), "dừng tại (3,2) trước rừng ở (3,1)")
	# 3 HP ban đầu: -1 chông ở (3,2), -1 va chạm rừng ở (3,1) -> còn 1 HP
	assert_eq(enemy.hp, 1)
	assert_eq(state.validate(), [] as Array[String])


func test_hero_walking_through_ally_standing_on_spikes() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 2 . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var events: Array[BattleEvent] = []
	# Khoái (1) ở (3,5) đi xuyên qua Lão (2) đứng trên chông ở (3,4) tới (3,3)
	RulesMove.resolve(state, Command.move(1, Vector2i(3, 3)), events)
	var hero1: Unit = state.unit_by_id(1)
	var hero2: Unit = state.unit_by_id(2)
	assert_eq(hero1.cell, Vector2i(3, 3))
	assert_eq(hero1.hp, 2, "Khoái đi qua chông mất 1 máu")
	assert_eq(hero2.cell, Vector2i(3, 4))
	assert_eq(hero2.hp, 3, "Lão đứng yên trên chông không mất máu")
	assert_eq(state.validate(), [] as Array[String])


func test_movement_penalties() -> void:
	var terrain: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . ^ . . .",
		". . . . . . .",
		". . . . . . .",
	]
	var units: Array[String] = [
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . . . . .",
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	var penalties: Dictionary = RulesMove.movement_penalties(state, hero)
	assert_true(penalties.has(Vector2i(3, 4)), "ô chông có phạt máu")
	assert_eq(penalties[Vector2i(3, 4)], 1)
	assert_eq(state.validate(), [] as Array[String])


func test_scenario_guc_giua_duong_has_no_moved_after_died() -> void:
	var path: String = "res://tests/kich_ban/dia_hinh/ham_chong_guc_giua_duong.json"
	var load_res: LoadResult = ScenarioLoader.load_scenario(path, "res://tests/kich_ban", _stats())
	assert_eq(load_res.errors, [] as Array[String])
	var scenario: ScenarioData = load_res.data as ScenarioData
	assert_not_null(scenario)
	var result: ScenarioRunner.ScenarioResult = ScenarioRunner.run(scenario, _stats())
	assert_true(result.passed, "kịch bản chạy đạt")
	var events: Array[BattleEvent] = result.step_events[0]
	var died_index: int = -1
	for i: int in range(events.size()):
		if events[i].type == BattleEvent.Type.DIED:
			died_index = i
	assert_true(died_index >= 0, "có sự kiện DIED")
	for i: int in range(died_index + 1, events.size()):
		assert_ne(events[i].type, BattleEvent.Type.MOVED, "không có MOVED sau DIED")
