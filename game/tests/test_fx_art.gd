extends GutTest
## Chọn hiệu ứng theo sự kiện (Story 8.4, AC 9 tới 17): hàm thuần, chỉ đọc sự kiện và bản chụp.

const KHOAI: int = 1
const LAO: int = 2
const DU: int = 3
const BO_BINH: int = 101


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


func _state() -> BattleState:
	# Ba tướng hàng 0 (Khoái, Lão, Dư); Bộ binh 101, Kỵ binh 102, Cung kỵ 103 ở hàng 3.
	return BoardFixture.state({
		Vector2i(0, 0): "1", Vector2i(1, 0): "2", Vector2i(2, 0): "3",
		Vector2i(0, 3): "B", Vector2i(1, 3): "K", Vector2i(2, 3): "C",
	})


func _kinds(event: BattleEvent, state: BattleState) -> Array[String]:
	var out: Array[String] = []
	for fx: Dictionary in FxArt.plan(event, state):
		out.append(fx["kind"] as String)
	return out


func _paths_exist(fx: Dictionary) -> bool:
	var paths: Array[String] = []
	if fx.has("paths"):
		paths.assign(fx["paths"] as Array)
	elif not (fx["path"] as String).is_empty():
		paths.append(fx["path"] as String)
	if paths.is_empty():
		return false
	for path: String in paths:
		if not ResourceLoader.exists(Art.BASE_DIR + path):
			return false
	return true


func test_attacks_pick_spear_arrow_or_slash_by_unit() -> void:
	var state: BattleState = _state()
	var target: Vector2i = Vector2i(0, 3)
	assert_eq(_kinds(BattleEvent.attacked(LAO, target), state), ["lao_bay"] as Array[String], "Lão phóng lao")
	assert_eq(_kinds(BattleEvent.enemy_attacked(103, Vector2i(2, 3), Vector2i(2, 0)), state),
		["ten_bay"] as Array[String], "Cung kỵ bắn tên")
	assert_eq(_kinds(BattleEvent.attacked(KHOAI, target), state), ["vet_chem"] as Array[String], "Khoái chém")
	assert_eq(_kinds(BattleEvent.enemy_attacked(BO_BINH, Vector2i(0, 3), Vector2i(0, 0)), state),
		["vet_chem"] as Array[String], "Bộ binh chém")


func test_attacks_without_effect() -> void:
	var state: BattleState = _state()
	assert_eq(_kinds(BattleEvent.attacked(DU, Vector2i(0, 3)), state), [] as Array[String], "Dư không có vệt chém")
	assert_eq(_kinds(BattleEvent.enemy_attacked(102, Vector2i(1, 3), Vector2i(1, 0)), state), [] as Array[String],
		"Kỵ binh không có hiệu ứng đòn")
	var no_flying: Array[String] = _kinds(BattleEvent.enemy_attacked(BO_BINH, Vector2i(0, 3), Vector2i(0, 0)), state)
	assert_false(no_flying.has("lao_bay") or no_flying.has("ten_bay"), "Bộ binh không bắn lao hay tên")


func test_slash_has_four_existing_frames_and_flying_ones_travel() -> void:
	var state: BattleState = _state()
	var slash: Dictionary = FxArt.plan(BattleEvent.attacked(KHOAI, Vector2i(0, 3)), state)[0]
	assert_eq((slash["paths"] as Array).size(), 4)
	assert_true(_paths_exist(slash), "bốn khung vệt chém có thật")
	assert_eq(slash["style"], FxArt.STYLE_FRAMES)
	assert_eq(slash["to_cell"], Vector2i(0, 3))
	var spear: Dictionary = FxArt.plan(BattleEvent.attacked(LAO, Vector2i(0, 3)), state)[0]
	assert_eq(spear["style"], FxArt.STYLE_TRAVEL)
	assert_eq(spear["to_cell"], Vector2i(0, 3))


func test_bay_dir_follows_the_main_axis() -> void:
	var o: Vector2 = Vector2(100, 100)
	assert_eq(FxArt.bay_dir(o, o + Vector2(200, 30)), "dong")
	assert_eq(FxArt.bay_dir(o, o + Vector2(-200, 30)), "tay")
	assert_eq(FxArt.bay_dir(o, o + Vector2(30, 200)), "nam")
	assert_eq(FxArt.bay_dir(o, o + Vector2(30, -200)), "bac")


func test_bay_paths_are_real_files_for_every_direction() -> void:
	for kind: String in [FxArt.LAO_BAY, FxArt.TEN_BAY]:
		for delta: Vector2 in [Vector2(9, 0), Vector2(-9, 0), Vector2(0, 9), Vector2(0, -9)]:
			var path: String = FxArt.bay_path(kind, Vector2.ZERO, delta)
			assert_true(ResourceLoader.exists(Art.BASE_DIR + path), path)
	assert_eq(FxArt.bay_path(FxArt.LAO_BAY, Vector2.ZERO, Vector2(50, 0)), "hieu_ung/tex_lao_bay_dong.png")
	assert_eq(FxArt.bay_path(FxArt.TEN_BAY, Vector2.ZERO, Vector2(0, -50)), "hieu_ung/tex_ten_bay_bac.png")


func test_single_cell_effects() -> void:
	var state: BattleState = _state()
	var cell: Vector2i = Vector2i(3, 3)
	var cases: Dictionary = {
		BattleEvent.Type.COLLIDED: ["va_cham", BattleEvent.collided(BO_BINH, KHOAI, cell)],
		BattleEvent.Type.DROWNED: ["nuoc_ban", BattleEvent.drowned(BO_BINH, cell)],
		BattleEvent.Type.GRANARY_BURNED: ["lua_kho", BattleEvent.granary_burned(cell)],
		BattleEvent.Type.HEALED: ["hoi_mau", BattleEvent.healed(BO_BINH, 1, cell)],
		BattleEvent.Type.VILLAGE_DAMAGED: ["khoi_lang", BattleEvent.village_damaged(cell)],
	}
	for type: int in cases:
		var kind: String = (cases[type] as Array)[0] as String
		var event: BattleEvent = (cases[type] as Array)[1] as BattleEvent
		var plan: Array[Dictionary] = FxArt.plan(event, state)
		assert_eq(plan.size(), 1, kind)
		assert_eq(plan[0]["kind"], kind)
		assert_eq(plan[0]["to_cell"], cell, "%s ở đúng ô" % kind)
		assert_true(_paths_exist(plan[0]), "hình của %s có thật" % kind)


func test_spikes_only_for_spikes_damage() -> void:
	var state: BattleState = _state()
	var spikes: Array[Dictionary] = FxArt.plan(BattleEvent.damaged(BO_BINH, 1, BattleEvent.Cause.SPIKES), state)
	assert_eq(spikes.size(), 1)
	assert_eq(spikes[0]["kind"], "chong_dam")
	assert_true(spikes[0]["at_unit"] as bool, "chông đâm đặt trên quân")
	assert_true(_paths_exist(spikes[0]))
	for cause: int in [BattleEvent.Cause.STRIKE, BattleEvent.Cause.COLLISION, BattleEvent.Cause.ENEMY_STRIKE]:
		assert_eq(FxArt.plan(BattleEvent.damaged(BO_BINH, 1, cause as BattleEvent.Cause), state).size(), 0,
			"đòn thường không có chông (%d)" % cause)


func test_events_without_effects() -> void:
	var state: BattleState = _state()
	assert_eq(FxArt.plan(BattleEvent.moved(KHOAI, Vector2i(0, 0), Vector2i(0, 1), BattleEvent.Cause.WALK), state).size(), 0)
	assert_eq(FxArt.plan(BattleEvent.died(BO_BINH, Vector2i(0, 3)), state).size(), 0)
	assert_eq(FxArt.plan(BattleEvent.telegraphed(BO_BINH, Vector2i(0, 3), Vector2i(0, 0), 1), state).size(), 0,
		"báo đòn chỉ nháy đỏ, không có hiệu ứng")


func test_null_state_and_unknown_unit_do_not_crash() -> void:
	assert_eq(FxArt.plan(BattleEvent.attacked(LAO, Vector2i(0, 3)), null).size(), 0, "không có bản chụp")
	assert_eq(FxArt.plan(BattleEvent.attacked(999, Vector2i(0, 3)), _state()).size(), 0, "quân không có")
	assert_eq(FxArt.plan(BattleEvent.granary_burned(Vector2i(1, 1)), null).size(), 1, "kho cháy không cần quân")
	assert_eq(Log.get_lines().size(), 0)
