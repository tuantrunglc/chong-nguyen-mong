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
	player.play_now(events)
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
