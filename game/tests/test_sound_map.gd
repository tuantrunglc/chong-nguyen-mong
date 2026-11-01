extends GutTest
## Bảng tiếng và nhạc (Story 8.7): sự kiện nào kêu tiếng nào, file có thật và nạp được.


func _ev(type: BattleEvent.Type) -> BattleEvent:
	return BattleEvent.new(type)


func test_every_event_type_is_mapped_or_deliberately_silent() -> void:
	var mapped: Dictionary = {}
	for type: int in BattleEvent.Type.values():
		var event: BattleEvent = _ev(type as BattleEvent.Type)
		var silent: bool = SoundMap.SILENT_TYPES.has(type)
		var any_sound: bool = false
		for unit_type: int in [-1, UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU,
				UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY]:
			if not SoundMap.sfx_for_event(event, unit_type).is_empty():
				any_sound = true
		# SPIKES và SAT_THAT là điều kiện riêng: thử thêm.
		var spikes: BattleEvent = BattleEvent.damaged(1, 1, BattleEvent.Cause.SPIKES)
		var sat_that: BattleEvent = BattleEvent.stratagem_used(Stratagem.Kind.SAT_THAT)
		if event.type == spikes.type and not SoundMap.sfx_for_event(spikes).is_empty():
			any_sound = true
		if event.type == sat_that.type and not SoundMap.sfx_for_event(sat_that).is_empty():
			any_sound = true
		mapped[type] = any_sound
		if silent and event.type != BattleEvent.Type.DAMAGED:
			assert_false(any_sound, "loại %d cố ý im" % type)
		elif not silent:
			assert_true(any_sound, "loại %d chưa có tiếng và chưa khai báo im (SoundMap.SILENT_TYPES)" % type)


func test_generals_and_enemies_have_their_own_attack_sound() -> void:
	var attack: BattleEvent = BattleEvent.attacked(1, Vector2i(1, 0))
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.NGUYEN_KHOAI), SoundMap.CHEM)
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.PHAM_NGU_LAO), SoundMap.PHONG_LAO)
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.TRAN_KHANH_DU), SoundMap.KEO_DICH)
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.BO_BINH), SoundMap.DAP_KHIENG)
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.KY_BINH), SoundMap.NGUA_PHI)
	assert_eq(SoundMap.sfx_for_event(attack, UnitType.CUNG_KY), SoundMap.BAN_CUNG)
	assert_eq(SoundMap.sfx_for_event(attack, -1), "", "không biết loại quân thì im, không lỗi")


func test_core_sounds() -> void:
	assert_eq(SoundMap.sfx_for_event(BattleEvent.collided(1, 2, Vector2i(1, 1))), SoundMap.VA_CHAM)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.drowned(101, Vector2i(2, 2))), SoundMap.ROI_SONG)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.died(101, Vector2i(2, 2))), SoundMap.GUC_NGA)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.damaged(1, 1, BattleEvent.Cause.SPIKES)), SoundMap.CHONG_DAM)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.damaged(1, 1, BattleEvent.Cause.PUSH)), "", "mất máu thường im: đòn đã có tiếng")
	assert_eq(SoundMap.sfx_for_event(BattleEvent.victory()), SoundMap.THANG)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.defeat()), SoundMap.THUA)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.stratagem_used(Stratagem.Kind.SAT_THAT)), SoundMap.SAT_THAT)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.stratagem_used(Stratagem.Kind.VUON_KHONG_NHA_TRONG)), "")
	assert_eq(SoundMap.sfx_for_event(BattleEvent.granary_burned(Vector2i(1, 1))), SoundMap.LUA_CHAY)
	assert_eq(SoundMap.sfx_for_event(BattleEvent.moved(1, Vector2i(0, 0), Vector2i(1, 0), BattleEvent.Cause.WALK)), "")


func test_every_file_exists_and_loads_as_a_stream() -> void:
	for file: String in SoundMap.all_sfx():
		var path: String = SoundMap.sfx_path(file)
		assert_true(ResourceLoader.exists(path), path)
		assert_true(load(path) is AudioStream, path)
	for file: String in SoundMap.all_music():
		var path: String = SoundMap.music_path(file)
		assert_true(ResourceLoader.exists(path), path)
		assert_true(load(path) is AudioStream, path)


func test_music_follows_the_level() -> void:
	assert_eq(SoundMap.music_for_level("tran_01"), SoundMap.MUSIC_BATTLE)
	assert_eq(SoundMap.music_for_level("tran_05"), SoundMap.MUSIC_BATTLE)
	assert_eq(SoundMap.music_for_level("tran_06"), SoundMap.MUSIC_TENSION)
	assert_eq(SoundMap.music_for_level("tran_99"), SoundMap.MUSIC_BATTLE, "id lạ dùng nhạc trận thường")
	assert_eq(SoundMap.music_for_level(""), SoundMap.MUSIC_BATTLE)
