extends GutTest
## Trạng thái trận dựng từ LevelData + Stats: id quân, máu ban đầu, clone() sâu, validate().
## Chỉ số dùng số tự đặt trong test, không dựa vào data/chi_so.json (tác giả được sửa).


func _stats() -> Stats:
	var values: Dictionary = {}
	for type: int in [UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU]:
		values[type] = {"mau": 4}
	values[UnitType.BO_BINH] = {"mau": 5}
	values[UnitType.KY_BINH] = {"mau": 2}
	values[UnitType.CUNG_KY] = {"mau": 1}
	return Stats.new(values)


func _level() -> LevelData:
	var d: Dictionary = {
		"phien_ban_dinh_dang": 1,
		"ten": "Trận thử",
		"kieu": "tieu_diet",
		"dia_hinh": [
			". . . ~ . . .",
			". # . ~ . . .",
			". . . ~ . L .",
			"^ . . . . . A",
			". . . ~ D . .",
			". . . ~ . . .",
			". . . ~ . . .",
		],
		"quan": [
			". B . . . K .",
			". . . . . . .",
			". . . . . . .",
			". . . . . . .",
			". . . . . C .",
			". . . . . . .",
			"2 . 1 . . . .",
		],
		# Khác thứ tự đọc từ trái sang phải.
		"thu_tu_dich": ["5,4", "1,0", "5,0"],
	}
	var r: LoadResult = LevelLoader.parse_level(JSON.stringify(d), "thu.json")
	assert_true(r.ok, "trận mẫu nạp được")
	return r.data as LevelData


func _state() -> BattleState:
	return BattleState.from_level(_level(), _stats())


func _describe(state: BattleState) -> Array[String]:
	var out: Array[String] = []
	for u: Unit in state.units:
		out.append("%d:%d:%d@%d,%d hp%d" % [u.id, u.faction, u.type, u.cell.x, u.cell.y, u.hp])
	return out


## Trạng thái dựng tay để thử validate(): địa hình của trận mẫu (cột 3 là sông, trừ hàng 3).
func _manual(units: Array[Unit]) -> BattleState:
	var level: LevelData = _level()
	var state: BattleState = BattleState.from_level(level, _stats())
	state.units = units
	return state


func test_factory_takes_hp_from_stats() -> void:
	var u: Unit = UnitFactory.create(7, UnitType.BO_BINH, Vector2i(2, 3), _stats())
	assert_eq(u.id, 7)
	assert_eq(u.type, UnitType.BO_BINH)
	assert_eq(u.faction, Unit.Faction.NGUYEN)
	assert_eq(u.cell, Vector2i(2, 3))
	assert_eq(u.hp, 5)
	assert_eq(UnitFactory.create(1, UnitType.NGUYEN_KHOAI, Vector2i.ZERO, _stats()).faction, Unit.Faction.DAI_VIET)


func test_factory_uses_given_hp_when_positive() -> void:
	assert_eq(UnitFactory.create(7, UnitType.BO_BINH, Vector2i.ZERO, _stats(), 2).hp, 2)
	assert_eq(UnitFactory.create(7, UnitType.BO_BINH, Vector2i.ZERO, _stats(), 0).hp, 5, "0 là máu đầy")
	assert_eq(UnitFactory.create(7, UnitType.BO_BINH, Vector2i.ZERO, _stats(), -1).hp, 5, "số âm là máu đầy")
	assert_eq(UnitFactory.create(7, UnitType.BO_BINH, Vector2i.ZERO, _stats(), 9).hp, 5, "không quá máu đầy")


func test_from_level_keeps_placement_hp() -> void:
	var level: LevelData = _level()
	level.units = [
		LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(2, 6), 1),
		LevelData.UnitPlacement.new(UnitType.BO_BINH, Vector2i(1, 0)),
	]
	var s: BattleState = BattleState.from_level(level, _stats())
	assert_eq(s.unit_by_id(1).hp, 1, "máu riêng")
	assert_eq(s.unit_by_id(101).hp, 5, "không ghi máu thì đầy")


func test_from_level_ids_factions_cells_and_hp() -> void:
	var s: BattleState = _state()
	var dv: int = Unit.Faction.DAI_VIET
	var ng: int = Unit.Faction.NGUYEN
	assert_eq(_describe(s), [
		"1:%d:%d@2,6 hp4" % [dv, UnitType.NGUYEN_KHOAI],
		"2:%d:%d@0,6 hp4" % [dv, UnitType.PHAM_NGU_LAO],
		"101:%d:%d@5,4 hp1" % [ng, UnitType.CUNG_KY],
		"102:%d:%d@1,0 hp5" % [ng, UnitType.BO_BINH],
		"103:%d:%d@5,0 hp2" % [ng, UnitType.KY_BINH],
	] as Array[String])
	assert_eq(s.size, Vector2i(7, 7))
	assert_eq(s.terrain_at(Vector2i(3, 0)), Terrain.RIVER)
	assert_eq(s.terrain_at(Vector2i(6, 3)), Terrain.PASS)
	assert_eq(s.validate(), [] as Array[String])


func test_general_id_follows_symbol_not_presence() -> void:
	var level: LevelData = _level()
	level.units = [LevelData.UnitPlacement.new(UnitType.TRAN_KHANH_DU, Vector2i(0, 0))]
	var s: BattleState = BattleState.from_level(level, _stats())
	assert_eq(s.units[0].id, 3)


func test_lookups() -> void:
	var s: BattleState = _state()
	assert_eq(s.unit_at(Vector2i(1, 0)).id, 102)
	assert_null(s.unit_at(Vector2i(0, 0)))
	assert_eq(s.unit_by_id(101).cell, Vector2i(5, 4))
	assert_null(s.unit_by_id(999))
	assert_true(s.in_bounds(Vector2i(0, 0)))
	assert_true(s.in_bounds(Vector2i(6, 6)))
	assert_false(s.in_bounds(Vector2i(7, 0)))
	assert_false(s.in_bounds(Vector2i(0, -1)))


func test_clone_is_deep() -> void:
	var original: BattleState = _state()
	var copy: BattleState = original.clone()
	assert_eq(_describe(copy), _describe(original))
	for i: int in range(original.units.size()):
		assert_ne(copy.units[i], original.units[i], "quân %d là object mới" % original.units[i].id)
	copy.units[0] = Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(3, 3), 1)
	copy.units.pop_back()
	assert_eq(original.units.size(), 5, "bản gốc không mất quân")
	assert_eq(original.units[0].cell, Vector2i(2, 6), "bản gốc không đổi ô")
	assert_eq(copy.stats, original.stats, "chỉ số dùng chung")


func test_clone_copies_round_and_moved_flag() -> void:
	var original: BattleState = _state()
	original.round_number = 4
	original.units[0] = Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(2, 6), 4, true)
	var copy: BattleState = original.clone()
	assert_eq(copy.round_number, 4)
	assert_true(copy.unit_by_id(1).has_moved, "bản sao giữ cờ đã đi")
	assert_false(copy.unit_by_id(2).has_moved)
	copy.round_number = 5
	copy.unit_by_id(1).has_moved = false
	assert_eq(original.round_number, 4, "bản gốc không đổi hiệp")
	assert_true(original.unit_by_id(1).has_moved, "bản gốc không đổi cờ")


func test_clone_copies_attacked_flag() -> void:
	var original: BattleState = _state()
	original.units[0] = Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(2, 6), 4, false, true)
	var copy: BattleState = original.clone()
	assert_true(copy.unit_by_id(1).has_attacked, "bản sao giữ cờ đã đánh")
	assert_false(copy.unit_by_id(2).has_attacked)
	copy.unit_by_id(1).has_attacked = false
	assert_true(original.unit_by_id(1).has_attacked, "bản gốc không đổi cờ")


## Story 2.5: phase và mission là một phần của trạng thái nên clone() phải chép.
func test_clone_copies_phase_and_mission() -> void:
	var original: BattleState = _state()
	assert_eq(original.phase, BattleState.Phase.PLAYER, "mặc định đang lượt người chơi")
	assert_eq(original.mission, LevelData.Mission.ELIMINATE, "mặc định Tiêu diệt")
	original.phase = BattleState.Phase.WON
	original.mission = LevelData.Mission.HOLD_PASS
	var copy: BattleState = original.clone()
	assert_eq(copy.phase, BattleState.Phase.WON)
	assert_eq(copy.mission, LevelData.Mission.HOLD_PASS)
	copy.phase = BattleState.Phase.LOST
	copy.mission = LevelData.Mission.ELIMINATE
	assert_eq(original.phase, BattleState.Phase.WON, "bản gốc không đổi")
	assert_eq(original.mission, LevelData.Mission.HOLD_PASS, "bản gốc không đổi")


## Story 2.6: đòn đã báo và ý định AI chép sâu (sửa bản sao không đổi bản gốc).
func test_clone_copies_telegraphs_and_intents_deeply() -> void:
	var original: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(original, events)
	var copy: BattleState = original.clone()
	assert_eq(copy.telegraphs.size(), 1)
	assert_ne(copy.telegraphs[0], original.telegraphs[0], "đối tượng mới, không dùng chung")
	assert_eq(copy.telegraphs[0].target_cell(copy), Vector2i(3, 4))
	assert_eq(copy.enemy_intents.size(), 1)
	assert_ne(copy.enemy_intents[0], original.enemy_intents[0])
	assert_eq(copy.enemy_intents[0].order, 1)
	copy.telegraphs.clear()
	copy.enemy_intents[0].order = 9
	assert_eq(original.telegraphs.size(), 1, "bản gốc không đổi")
	assert_eq(original.enemy_intents[0].order, 1, "bản gốc không đổi")


func test_validate_reports_bad_telegraph_order() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(5, 5): "B", Vector2i(3, 4): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	assert_eq(state.validate(), [] as Array[String])
	state.telegraphs.append(Telegraph.new(102, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	state.telegraphs.append(Telegraph.new(102, Telegraph.Kind.CELL, Vector2i(0, 1), 0))
	assert_eq(state.validate(), [
		"đòn số 1 bị trùng (quân 101 và quân 102)",
		"đòn của quân 102 có số thứ tự 0, cần từ 1 trở lên",
	] as Array[String])


func test_validate_reports_bad_telegraph_shape() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(3, 3): "B", Vector2i(3, 4): "1"})
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(0, 1), 1))
	assert_eq(state.validate(), [] as Array[String], "hướng hợp lệ")
	state.telegraphs.clear()
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.DIRECTION, Vector2i(1, 1), 1))
	assert_eq(state.validate(), ["đòn của quân 101 xung phong theo hướng 1,1 không hợp lệ"] as Array[String])
	state.telegraphs.clear()
	state.telegraphs.append(Telegraph.new(101, Telegraph.Kind.CELL, Vector2i(0, 2), 1))
	assert_eq(state.validate(), ["đòn của quân 101 đánh ô cách 0,2, cần đúng một ô kề"] as Array[String])
	state.telegraphs.clear()
	state.telegraphs.append(Telegraph.new(7, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	assert_eq(state.validate(), [] as Array[String], "chủ đòn đã gục (không còn trên bàn) vẫn hợp lệ")
	state.telegraphs.clear()
	var general_id: int = state.units[0].id
	state.telegraphs.append(Telegraph.new(general_id, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	assert_eq(state.validate(), ["đòn của quân %d thuộc quân không phải quân Nguyên" % general_id] as Array[String])


func test_from_level_copies_mission() -> void:
	var level: LevelData = LevelData.new()
	level.size = Vector2i(5, 5)
	for i: int in range(25):
		level.terrain.append(Terrain.PLAIN)
	level.units.append(LevelData.UnitPlacement.new(UnitType.NGUYEN_KHOAI, Vector2i(0, 4)))
	level.mission = LevelData.Mission.HOLD_PASS
	assert_eq(BattleState.from_level(level, BoardFixture.stats()).mission, LevelData.Mission.HOLD_PASS)
	level.mission = LevelData.Mission.ELIMINATE
	assert_eq(BattleState.from_level(level, BoardFixture.stats()).mission, LevelData.Mission.ELIMINATE)


func test_validate_round_number() -> void:
	var s: BattleState = _manual([] as Array[Unit])
	s.round_number = 0
	assert_eq(s.validate(), ["hiệp 0, cần từ 1 trở lên"] as Array[String])


func test_validate_duplicate_id() -> void:
	var s: BattleState = _manual([
		Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(0, 0), 4),
		Unit.new(1, UnitType.PHAM_NGU_LAO, Vector2i(1, 0), 4),
	] as Array[Unit])
	assert_eq(s.validate(), ["quân 1 ở ô 1,0 trùng id với quân khác"] as Array[String])


func test_validate_out_of_board() -> void:
	var s: BattleState = _manual([Unit.new(101, UnitType.BO_BINH, Vector2i(7, 2), 3)] as Array[Unit])
	assert_eq(s.validate(), ["quân 101 ở ô 7,2 nằm ngoài bàn"] as Array[String])


func test_validate_two_units_same_cell() -> void:
	var s: BattleState = _manual([
		Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(0, 0), 4),
		Unit.new(101, UnitType.BO_BINH, Vector2i(0, 0), 3),
	] as Array[Unit])
	assert_eq(s.validate(), ["quân 101 ở ô 0,0 đứng chung ô với quân 1"] as Array[String])


func test_validate_blocked_terrain() -> void:
	var s: BattleState = _manual([Unit.new(101, UnitType.BO_BINH, Vector2i(3, 0), 3)] as Array[Unit])
	assert_eq(s.validate(), ["quân 101 ở ô 3,0 đứng trên ô không đi vào được"] as Array[String])


func test_validate_hp_range() -> void:
	var s: BattleState = _manual([
		Unit.new(1, UnitType.NGUYEN_KHOAI, Vector2i(0, 0), 0),
		Unit.new(101, UnitType.BO_BINH, Vector2i(1, 0), 6),
	] as Array[Unit])
	assert_eq(s.validate(), [
		"quân 1 ở ô 0,0 có máu 0, cần từ 1 tới 4",
		"quân 101 ở ô 1,0 có máu 6, cần từ 1 tới 5",
	] as Array[String])


func test_real_levels_are_valid() -> void:
	var stats: LoadResult = StatsLoader.load_stats("res://data/chi_so.json")
	assert_true(stats.ok)
	for path: String in ["res://data/tran/tran_01.json", "res://data/tran/thu_ba_tuong.json"]:
		var level: LoadResult = LevelLoader.load_level(path)
		assert_true(level.ok, path)
		if not (stats.ok and level.ok):
			continue
		var s: BattleState = BattleState.from_level(level.data as LevelData, stats.data as Stats)
		assert_eq(s.validate(), [] as Array[String], path)
