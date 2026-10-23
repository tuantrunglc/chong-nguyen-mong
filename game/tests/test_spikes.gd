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
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var hero: Unit = state.unit_by_id(1)
	Effects.damage(state, hero, 2, BattleEvent.Cause.STRIKE, [])
	var events: Array[BattleEvent] = []
	RulesMove.resolve(state, Command.move(1, Vector2i(3, 3)), events)
	assert_null(state.unit_by_id(1), "tướng đã gục và bị nhấc khỏi bàn")
	var has_died: bool = false
	var cell_died: Vector2i = Vector2i.ZERO
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.DIED:
			has_died = true
			cell_died = e.from_cell
	assert_true(has_died)
	assert_eq(cell_died, Vector2i(3, 4), "gục ngay tại ô hầm chông, không đi tiếp tới 3,3")


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
		". . . . . . .",
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
	assert_eq(hero.hp, 3, "đứng yên trên ô chông không mất máu")


func test_hero_pathfinding_avoids_spikes() -> void:
	# (3,5) tới (4,4): đường Bắc-Đông qua (3,4) có chông, đường Đông-Bắc qua (4,5) không có chông
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


func test_hero_pathfinding_takes_detour_to_avoid_spikes_within_range() -> void:
	# (3,5) tới (3,3): đường thẳng 2 bước qua (3,4) có chông.
	# Đường vòng 4 bước: vượt tầm đi (tam_di = 3), nên nếu không có đường vòng <= 3 bước thì buộc phải đi qua chông.
	# Nhưng nếu ô đích là (4,3):
	# Đường 1: (3,5) -> (3,4)[chông] -> (4,4) -> (4,3): 3 bước, 1 chông.
	# Đường 2: (3,5) -> (4,5) -> (4,4) -> (4,3): 3 bước, 0 chông.
	# -> Game chọn đường 2 (0 chông).
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
	var path: Array[Vector2i] = RulesMove.path_to(state, hero, Vector2i(4, 3))
	assert_eq(path, [Vector2i(4, 5), Vector2i(4, 4), Vector2i(4, 3)], "chọn đường vòng 3 bước sạch chông")


func test_enemy_pathfinding_does_not_avoid_spikes() -> void:
	# Quân Nguyên không tránh chông: giữa (3,1) và (4,2):
	# Hướng B->Đ->N->T: từ (3,1) đi Nam sang (3,2)[chông] rồi Đông sang (4,2)
	# vs đi Đông sang (4,1) rồi Nam sang (4,2).
	# Từ (3,1), hướng B không đi được (ra ngoài). Hướng Đ sang (4,1).
	# Thử với xuất phát (3,3) tới (4,4): B-Đ-N-T:
	# B sang (3,2); Đ sang (4,3); N sang (3,4)[chông]; T sang (2,3).
	# Để test đường ngắn nhất: Bộ binh ở (3,2) đi thẳng Nam tới (3,3)[chông] vì là đường ngắn nhất tới tướng (3,5).
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
		". . . 1 . . .",
		". . . . . . .",
	]
	var state: BattleState = _state(units, terrain)
	var enemy: Unit = state.unit_by_id(101)
	var paths: Dictionary = Pathfinding.find_paths(state, enemy, 1)
	assert_true(paths.has(Vector2i(3, 3)))
	assert_eq(paths[Vector2i(3, 3)], [Vector2i(3, 3)], "quân Nguyên vẫn đi thẳng vào hầm chông")
