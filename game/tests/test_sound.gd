extends GutTest
## Bộ phát âm thanh (Story 8.7): chỉ phát sau lần bấm đầu, chống chồng tiếng, tắt tiếng, nhạc theo màn.

var _sound: Sound


func before_each() -> void:
	Sound.reset_for_test()
	Log.clear()
	_sound = Sound.new()
	add_child_autofree(_sound)


func after_each() -> void:
	_sound.set_muted(false)
	Sound.host = null


func test_buses_exist_with_default_volumes() -> void:
	var music: int = AudioServer.get_bus_index(Sound.BUS_MUSIC)
	var sfx: int = AudioServer.get_bus_index(Sound.BUS_SFX)
	assert_gte(music, 0)
	assert_gte(sfx, 0)
	assert_almost_eq(AudioServer.get_bus_volume_db(music), Sound.MUSIC_VOLUME_DB, 0.01)
	assert_almost_eq(AudioServer.get_bus_volume_db(sfx), Sound.SFX_VOLUME_DB, 0.01)


func test_nothing_plays_before_the_first_click() -> void:
	assert_false(_sound.is_unlocked())
	assert_false(_sound.play_sfx(SoundMap.CHEM))
	_sound.play_music(SoundMap.MUSIC_MENU)
	assert_eq(_sound.wanted_music(), SoundMap.MUSIC_MENU, "nhạc được nhớ")
	assert_eq(_sound.playing_music(), "", "nhưng chưa phát")
	assert_eq(_sound.played_log.size(), 0)


func test_music_starts_when_unlocked() -> void:
	_sound.play_music(SoundMap.MUSIC_MENU)
	_sound.unlock()
	assert_true(_sound.is_unlocked())
	await wait_seconds(Sound.FADE_SECONDS + 0.1)
	assert_eq(_sound.playing_music(), SoundMap.MUSIC_MENU)
	assert_true(_sound.play_sfx(SoundMap.CHEM))


func test_same_sound_is_not_stacked() -> void:
	_sound.unlock()
	assert_true(_sound.play_sfx(SoundMap.CHEM))
	assert_false(_sound.play_sfx(SoundMap.CHEM), "cùng tiếng trong 0,05 giây chỉ phát một lần")
	assert_true(_sound.play_sfx(SoundMap.VA_CHAM), "tiếng khác vẫn phát")
	assert_eq(_sound.played_log, [SoundMap.CHEM, SoundMap.VA_CHAM] as Array[String])
	await wait_seconds(0.08)
	assert_true(_sound.play_sfx(SoundMap.CHEM), "qua khoảng chờ thì phát lại được")


func test_at_most_eight_voices_at_once() -> void:
	_sound.unlock()
	var played: int = 0
	for file: String in SoundMap.all_sfx():
		if _sound.play_sfx(file):
			played += 1
	assert_eq(played, Sound.MAX_VOICES, "tiếng thứ chín trở đi bị bỏ, không dồn hàng đợi")


func test_empty_name_is_silence() -> void:
	_sound.unlock()
	assert_false(_sound.play_sfx(""))


func test_mute_mutes_both_buses_and_back() -> void:
	_sound.set_muted(true)
	assert_true(_sound.is_muted())
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.BUS_MUSIC)))
	assert_true(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.BUS_SFX)))
	_sound.set_muted(false)
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.BUS_MUSIC)))
	assert_false(AudioServer.is_bus_mute(AudioServer.get_bus_index(Sound.BUS_SFX)))


func test_same_music_is_not_restarted_and_stop_is_silence() -> void:
	_sound.unlock()
	_sound.play_music(SoundMap.MUSIC_BATTLE)
	await wait_seconds(Sound.FADE_SECONDS + 0.1)
	assert_eq(_sound.playing_music(), SoundMap.MUSIC_BATTLE)
	_sound.play_music(SoundMap.MUSIC_BATTLE)
	assert_eq(_sound.playing_music(), SoundMap.MUSIC_BATTLE, "yêu cầu lại cùng bản thì giữ nguyên")
	_sound.stop_music()
	await wait_seconds(Sound.FADE_SECONDS + 0.1)
	assert_eq(_sound.playing_music(), "")
	assert_eq(_sound.wanted_music(), "")


func test_music_streams_loop() -> void:
	_sound.unlock()
	for file: String in SoundMap.all_music():
		var stream: AudioStream = Sound._stream(SoundMap.music_path(file))
		assert_true(stream is AudioStreamOggVorbis, file)
		assert_true((stream as AudioStreamOggVorbis).loop, "%s phải lặp" % file)


func test_missing_file_logs_one_error_and_does_not_crash() -> void:
	_sound.unlock()
	assert_false(_sound.play_sfx("sfx_khong_co.wav"))
	assert_false(_sound.play_sfx("sfx_khong_co.wav"))
	var errors: int = 0
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR][am_thanh]"):
			errors += 1
	assert_eq(errors, 1, "mỗi đường dẫn báo lỗi một lần")


func test_ui_cues_go_through_the_host() -> void:
	Sound.host = _sound
	_sound.unlock()
	Sound.ui_hover()
	Sound.ui_click()
	assert_eq(_sound.played_log, [SoundMap.RE_CHUOT, SoundMap.BAM_NUT] as Array[String])


func test_buttons_made_by_ui_style_make_sound_but_not_when_disabled() -> void:
	Sound.host = _sound
	_sound.unlock()
	var button: Button = Button.new()
	add_child_autofree(button)
	UiStyle.apply_button(button)
	UiStyle.apply_button(button)
	button.mouse_entered.emit()
	button.pressed.emit()
	assert_eq(_sound.played_log, [SoundMap.RE_CHUOT, SoundMap.BAM_NUT] as Array[String], "nối hai lần vẫn một tiếng")
	_sound.played_log.clear()
	button.disabled = true
	await wait_seconds(0.08)
	button.mouse_entered.emit()
	assert_eq(_sound.played_log.size(), 0, "nút mờ không kêu khi rê")
