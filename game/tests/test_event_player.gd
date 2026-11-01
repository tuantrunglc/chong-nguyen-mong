extends GutTest
## Hoạt ảnh phát lại sự kiện (Story 2.11, AC 1, 2, 6): thứ tự phát, trần 3 giây của một pha, và không đụng state.

const KHOAI: int = 1
## Quân Nguyên đầu tiên theo thứ tự đọc bàn (xem BoardFixture).
const BO_BINH: int = 101


func _board(units: Dictionary) -> BoardView:
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(BoardFixture.state(units))
	return board


func _player(board: BoardView) -> EventPlayer:
	var player: EventPlayer = EventPlayer.new()
	player.setup(board)
	add_child_autofree(player)
	return player


func test_events_apply_in_log_order() -> void:
	var board: BoardView = _board({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var player: EventPlayer = _player(board)
	var khoai: UnitToken = board.tokens()[KHOAI] as UnitToken
	var start: Vector2 = khoai.position
	var bo_binh: UnitToken = board.tokens()[BO_BINH] as UnitToken
	var events: Array[BattleEvent] = [
		BattleEvent.moved(KHOAI, Vector2i(0, 0), Vector2i(1, 0), BattleEvent.Cause.WALK),
		BattleEvent.moved(KHOAI, Vector2i(1, 0), Vector2i(2, 0), BattleEvent.Cause.WALK),
		BattleEvent.died(BO_BINH, Vector2i(3, 0)),
	]
	player.play_now(events, BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"}))
	assert_eq(player.played().size(), 3, "phát đủ số sự kiện nhận được")
	assert_eq(player.played()[0].type, BattleEvent.Type.MOVED, "phát theo đúng thứ tự nhật ký")
	assert_eq(player.played()[2].type, BattleEvent.Type.DIED)
	var step: Vector2 = BoardView.cell_center(Vector2i(1, 0)) - BoardView.cell_center(Vector2i(0, 0))
	assert_eq(khoai.position, start + step * 2.0, "đồng quân đi đúng hai bước")
	assert_false(bo_binh.visible, "quân gục bị ẩn khỏi bàn")


func test_enemy_phase_total_is_capped_at_three_seconds() -> void:
	var board: BoardView = _board({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var player: EventPlayer = _player(board)
	var long_log: Array[BattleEvent] = []
	for i: int in range(40):
		long_log.append(
			BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK))
	assert_almost_eq(player.total_seconds(long_log), EventPlayer.MAX_PHASE_SECONDS, 0.001,
		"nhật ký dài vẫn bị co về đúng 3 giây (NFR3)")
	var short_log: Array[BattleEvent] = [
		BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK),
	]
	assert_almost_eq(player.total_seconds(short_log), EventPlayer.SECONDS_PER_EVENT, 0.001,
		"pha ngắn giữ nguyên nhịp từng sự kiện")
	assert_eq(player.total_seconds([] as Array[BattleEvent]), 0.0, "không có sự kiện thì không tốn thời gian")


func test_animation_does_not_change_battle_state() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.play_now([BattleEvent.moved(KHOAI, Vector2i(0, 0), Vector2i(1, 0), BattleEvent.Cause.WALK)])
	assert_eq(state.unit_by_id(KHOAI).cell, Vector2i(0, 0), "hoạt ảnh chỉ đọc, không sửa state (AC 6)")
	assert_eq(state.unit_by_id(BO_BINH).cell, Vector2i(3, 0), "quân khác cũng không đổi")


## NFR3 đo bằng đồng hồ thật: 60 sự kiện, sàn 0,06 s mỗi sự kiện = 3,6 s nếu không canh đồng hồ, nên test này
## trượt khi mất phần canh `remaining` (đã thử phá).
func test_play_stays_under_three_seconds_on_the_clock() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	var events: Array[BattleEvent] = []
	for i: int in range(60):
		events.append(BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK))
	var started: int = Time.get_ticks_msec()
	await player.play(events, state)
	var elapsed: float = float(Time.get_ticks_msec() - started) / 1000.0
	assert_lte(elapsed, EventPlayer.MAX_PHASE_SECONDS + 0.15, "phát thật ≤ 3 s (đo được %.2f s)" % elapsed)
	assert_eq(player.played().size(), 60, "vẫn phát đủ sự kiện, phần cuối áp ngay khi hết ngân sách")


## Tua nhanh (Story 4.4, FR42): tốc độ 3 thì cả pha ≤ 1 s trên đồng hồ thật, vẫn đủ sự kiện, đúng thứ tự.
func test_fast_speed_plays_every_event_under_one_second() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	player.set_speed(EventPlayer.FAST_SPEED)
	var events: Array[BattleEvent] = []
	for i: int in range(60):
		events.append(BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK))
	events.append(BattleEvent.died(BO_BINH, Vector2i(3, 0)))
	var started: int = Time.get_ticks_msec()
	await player.play(events, state)
	var elapsed: float = float(Time.get_ticks_msec() - started) / 1000.0
	assert_lte(elapsed, EventPlayer.MAX_PHASE_SECONDS / EventPlayer.FAST_SPEED + 0.15,
		"tua: ≤ 1 s (đo được %.2f s)" % elapsed)
	assert_eq(player.played().size(), 61, "không bỏ sự kiện nào")
	assert_eq(player.played()[60].type, BattleEvent.Type.DIED, "đúng thứ tự")


## Bấm tua giữa lúc phát: phần còn lại nhanh theo (60 sự kiện ở tốc độ thường mất 3 s).
func test_speed_change_mid_play_shortens_the_rest() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	var events: Array[BattleEvent] = []
	for i: int in range(60):
		events.append(BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK))
	get_tree().create_timer(0.3).timeout.connect(func() -> void: player.set_speed(EventPlayer.FAST_SPEED))
	var started: int = Time.get_ticks_msec()
	await player.play(events, state)
	var elapsed: float = float(Time.get_ticks_msec() - started) / 1000.0
	# 0,3 s ở tốc độ thường, 2,7 s còn lại chia 3 = 0,9 s.
	assert_lte(elapsed, 0.3 + 2.7 / EventPlayer.FAST_SPEED + 0.25, "tua giữa chừng (đo được %.2f s)" % elapsed)
	assert_gte(elapsed, 0.3, "phần đầu vẫn ở tốc độ thường")
	assert_eq(player.played().size(), 60, "không bỏ sự kiện nào")


## Tắt tua giữa lúc phát: phần còn lại về tốc độ thường (AC 3), tổng vẫn ≤ trần 3 s.
func test_speed_back_to_normal_mid_play_slows_the_rest() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	player.set_speed(EventPlayer.FAST_SPEED)
	var events: Array[BattleEvent] = []
	for i: int in range(60):
		events.append(BattleEvent.moved(BO_BINH, Vector2i(3, 0), Vector2i(3, 0), BattleEvent.Cause.WALK))
	get_tree().create_timer(0.3).timeout.connect(func() -> void: player.set_speed(1.0))
	var started: int = Time.get_ticks_msec()
	await player.play(events, state)
	var elapsed: float = float(Time.get_ticks_msec() - started) / 1000.0
	# 0,3 s ở tốc độ tua, 0,7 s ngân sách còn lại nhân 3 = 2,1 s; nếu tắt không ăn thì cả pha chỉ ~1 s.
	assert_gte(elapsed, 0.3 + 0.7 * EventPlayer.FAST_SPEED - 0.4, "tắt tua giữa chừng (đo được %.2f s)" % elapsed)
	assert_lte(elapsed, EventPlayer.MAX_PHASE_SECONDS + 0.25, "vẫn trong trần pha (đo được %.2f s)" % elapsed)
	assert_eq(player.played().size(), 60, "không bỏ sự kiện nào")


# ---------- Khung chuyển động và hiệu ứng (Story 8.4) ----------

func _run(player: EventPlayer, events: Array[BattleEvent], state: BattleState, done: Array) -> void:
	await player.play(events, state)
	done[0] = true


func _anim_log() -> Array[BattleEvent]:
	return [
		BattleEvent.moved(KHOAI, Vector2i(0, 0), Vector2i(1, 0), BattleEvent.Cause.WALK),
		BattleEvent.attacked(KHOAI, Vector2i(3, 0)),
		BattleEvent.damaged(BO_BINH, 1, BattleEvent.Cause.STRIKE),
		BattleEvent.died(BO_BINH, Vector2i(3, 0)),
	]


func test_clips_and_effects_play_then_clean_up() -> void:
	Art.reset_for_test()
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	var khoai: UnitToken = board.tokens()[KHOAI] as UnitToken
	var bo_binh: UnitToken = board.tokens()[BO_BINH] as UnitToken
	var done: Array = [false]
	var started: int = Time.get_ticks_msec()
	_run(player, _anim_log(), state, done)
	await wait_seconds(0.06)
	assert_true(khoai.has_clip(), "đang đi thì phát khung đi")
	assert_eq(khoai.facing_name(), "east", "hướng đứng theo hướng vừa đi")
	await wait_seconds(0.22)
	assert_gt(board.fx_layer().active_count(), 0, "đang đánh thì có vệt chém")
	assert_true(khoai.has_clip(), "đang đánh thì phát khung đánh")
	await wait_until(func() -> bool: return done[0] as bool, 4.0)
	var elapsed: float = float(Time.get_ticks_msec() - started) / 1000.0
	assert_lte(elapsed, EventPlayer.MAX_PHASE_SECONDS + 0.15, "hoạt ảnh không kéo dài pha (đo %.2f s)" % elapsed)
	await wait_seconds(0.1)
	assert_eq(board.fx_layer().active_count(), 0, "hiệu ứng tự gỡ")
	assert_false(khoai.has_clip(), "không còn khung chạy dở")
	assert_eq(khoai.modulate, Color.WHITE, "quân sống về màu trắng")
	assert_false(bo_binh.visible, "quân gục bị ẩn")
	assert_eq(player.played().size(), 4, "vẫn phát đủ sự kiện")


func test_stop_clears_clips_and_effects() -> void:
	Art.reset_for_test()
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	var events: Array[BattleEvent] = [BattleEvent.attacked(KHOAI, Vector2i(3, 0))]
	_run(player, events, state, [false])
	await wait_seconds(0.05)
	assert_gt(board.fx_layer().active_count(), 0, "đề bài: đang có hiệu ứng")
	player.stop()
	assert_eq(board.fx_layer().active_count(), 0, "stop() xóa hiệu ứng")
	assert_false((board.tokens()[KHOAI] as UnitToken).has_clip(), "stop() gỡ khung")


func test_show_state_clears_clips_and_effects() -> void:
	Art.reset_for_test()
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	player.instant = false
	_run(player, _anim_log(), state, [false])
	await wait_seconds(0.25)
	board.show_state(state)
	assert_eq(board.fx_layer().active_count(), 0, "show_state xóa hiệu ứng đang bay")
	assert_false((board.tokens()[KHOAI] as UnitToken).has_clip(), "UnitToken.update gỡ khung")
	player.stop()


func test_instant_mode_makes_no_clips_or_effects() -> void:
	var state: BattleState = BoardFixture.state({Vector2i(0, 0): "1", Vector2i(3, 0): "B"})
	var board: BoardView = BoardView.new()
	add_child_autofree(board)
	board.show_state(state)
	var player: EventPlayer = _player(board)
	var events: Array[BattleEvent] = _anim_log()
	player.play_now(events, state)
	assert_eq(board.fx_layer().active_count(), 0, "play_now không tạo hiệu ứng")
	assert_false((board.tokens()[KHOAI] as UnitToken).has_clip(), "play_now không phát khung")
	assert_eq(player.played().size(), 4)
	assert_eq(player.played()[1].type, BattleEvent.Type.ATTACKED, "thứ tự cũ giữ nguyên")
	player.instant = true
	await player.play(events, state)
	assert_eq(board.fx_layer().active_count(), 0, "instant không tạo hiệu ứng")


## Tiếng đi kèm sự kiện (Story 8.7): đúng thứ tự nhật ký, đúng loại quân ra đòn; chế độ instant thì im.
func test_events_make_their_sounds_in_log_order() -> void:
	var sound: Sound = Sound.new()
	add_child_autofree(sound)
	Sound.host = sound
	sound.unlock()
	var units: Dictionary = {Vector2i(0, 0): "1", Vector2i(3, 0): "B"}
	var board: BoardView = _board(units)
	var player: EventPlayer = _player(board)
	var events: Array[BattleEvent] = [
		BattleEvent.moved(KHOAI, Vector2i(0, 0), Vector2i(1, 0), BattleEvent.Cause.WALK),
		BattleEvent.attacked(KHOAI, Vector2i(2, 0)),
		BattleEvent.collided(BO_BINH, KHOAI, Vector2i(2, 0)),
		BattleEvent.enemy_attacked(BO_BINH, Vector2i(3, 0), Vector2i(2, 0)),
		BattleEvent.drowned(BO_BINH, Vector2i(3, 0)),
	]
	player.instant = true
	player.play_now(events, BoardFixture.state(units))
	assert_eq(sound.played_log.size(), 0, "instant (không hoạt ảnh) thì không có tiếng")
	player.instant = false
	player.play_now(events, BoardFixture.state(units))
	assert_eq(sound.played_log, [SoundMap.CHEM, SoundMap.VA_CHAM, SoundMap.DAP_KHIENG, SoundMap.ROI_SONG] as Array[String],
		"đi bộ im; Khoái chém, va chạm, bộ binh đánh khiên, rơi sông")
	Sound.host = null
