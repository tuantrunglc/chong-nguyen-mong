extends GutTest
## Bảng "Thắng!" / "Thua!" (Story 2.5). Thua chưa đạt được bằng lệnh thật trước Story 2.8, nên chữ "Thua!" chỉ kiểm ở
## đây; test bàn thắng qua main.tscn nằm ở test_battle_view.gd.


func _banner() -> ResultBanner:
	var banner: ResultBanner = ResultBanner.new()
	add_child_autofree(banner)
	return banner


func test_hidden_until_a_result_is_shown() -> void:
	var banner: ResultBanner = _banner()
	assert_false(banner.is_showing())
	assert_eq(banner.result_text(), "")


func test_won_and_lost_texts() -> void:
	var banner: ResultBanner = _banner()
	banner.show_result(BattleState.Phase.WON)
	assert_true(banner.is_showing())
	assert_eq(banner.result_text(), tr("result.won"))
	assert_eq(banner.result_text(), "Thắng!")
	banner.show_result(BattleState.Phase.LOST)
	assert_true(banner.is_showing())
	assert_eq(banner.result_text(), tr("result.lost"))
	assert_eq(banner.result_text(), "Thua!")


func test_other_phases_and_hide_remove_the_banner() -> void:
	var banner: ResultBanner = _banner()
	banner.show_result(BattleState.Phase.WON)
	banner.show_result(BattleState.Phase.PLAYER)
	assert_false(banner.is_showing(), "pha đang chơi thì ẩn")
	banner.show_result(BattleState.Phase.LOST)
	banner.hide_result()
	assert_false(banner.is_showing())
	assert_eq(banner.result_text(), "")


func test_banner_sits_inside_the_board_area_and_does_not_cover_it() -> void:
	var banner: ResultBanner = _banner()
	var rect: Rect2 = Rect2(banner.position, banner.size)
	assert_true(BoardView.AREA.encloses(rect), "bảng nằm gọn trong vùng bàn cờ")
	assert_lt(rect.size.x, BoardView.AREA.size.x / 2.0, "không che hết bàn: hẹp hơn nửa bề rộng")
	assert_lt(rect.size.y, BoardView.AREA.size.y / 2.0, "không che hết bàn: thấp hơn nửa bề cao")
	assert_eq(rect.get_center(), BoardView.AREA.get_center(), "giữa bàn")


## Bảng không nuốt chuột: chỉ nút Chơi lại trận nhận chuột (BattleInput nhận phần còn lại qua _unhandled_input).
func test_only_the_retry_button_takes_the_mouse() -> void:
	var banner: ResultBanner = _banner()
	var stack: Array[Node] = [banner]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is Control and node != banner.retry_button():
			assert_eq((node as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, str(node.get_path()))
	assert_ne(banner.retry_button().mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(banner.retry_button().focus_mode, Control.FOCUS_NONE, "Space không bấm lại nút")


func test_retry_button_emits_signal() -> void:
	var banner: ResultBanner = _banner()
	watch_signals(banner)
	banner.retry_button().pressed.emit()
	assert_signal_emitted(banner, "retry_pressed")
