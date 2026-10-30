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
	banner.show_result(BattleState.Phase.LOST, "het_hiep")
	assert_true(banner.is_showing())
	assert_eq(banner.result_text(), tr("result.lost_round_limit"))
	assert_eq(banner.result_text(), "Thua: hết hiệp")
	banner.show_result(BattleState.Phase.LOST, "quan_nguyen_vao_ai")
	assert_true(banner.is_showing())
	assert_eq(banner.result_text(), tr("result.lost_pass"))
	assert_eq(banner.result_text(), "Thua: giặc vào ải")


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
	banner.show_result(BattleState.Phase.WON)
	await wait_process_frames(1)
	var rect: Rect2 = banner.panel_rect()
	assert_eq(rect, Rect2(banner.position, banner.size), "khung trùng Control bọc ngoài, không tràn ra")
	assert_true(BoardView.AREA.encloses(rect), "bảng nằm gọn trong vùng bàn cờ")
	assert_lt(rect.size.x, BoardView.AREA.size.x / 2.0, "không che hết bàn: hẹp hơn nửa bề rộng")
	assert_lt(rect.size.y, BoardView.AREA.size.y / 2.0, "không che hết bàn: thấp hơn nửa bề cao")
	assert_almost_eq(rect.get_center(), BoardView.AREA.get_center(), Vector2(1, 1), "giữa bàn")


## Khung đủ chỗ cho chữ "Thắng!"/"Thua!"/"Thua: hết hiệp", khoảng cách, các nút (một hoặc hai), đệm và viền.
func test_panel_fits_its_content() -> void:
	var banner: ResultBanner = _banner()
	var cases: Array[Dictionary] = [
		{"phase": BattleState.Phase.WON, "reason": "", "next": true},
		{"phase": BattleState.Phase.WON, "reason": "", "next": false},
		{"phase": BattleState.Phase.LOST, "reason": ""},
		{"phase": BattleState.Phase.LOST, "reason": "het_hiep"},
		{"phase": BattleState.Phase.LOST, "reason": "quan_nguyen_vao_ai"},
	]
	for c: Dictionary in cases:
		banner.show_result(c.phase, c.reason, c.get("next", false))
		await wait_process_frames(1)
		var panel: PanelContainer = banner.get_child(0) as PanelContainer
		var needed: Vector2 = panel.get_combined_minimum_size()
		assert_true(banner.panel_rect().size.x >= needed.x and banner.panel_rect().size.y >= needed.y,
			"%s (%s): khung %s, nội dung cần %s" % [c.phase, c.reason, banner.panel_rect().size, needed])
		assert_eq(banner.panel_rect(), Rect2(banner.position, banner.size), "%s: khung không giãn thêm" % c.phase)
		assert_true(BoardView.AREA.encloses(banner.panel_rect()), "khung nằm trong bàn")
		assert_lt(banner.panel_rect().size.x, BoardView.AREA.size.x / 2.0, "khung không che quá nửa bàn")


## Bảng không nuốt chuột: chỉ các nút nhận chuột (BattleInput nhận phần còn lại qua _unhandled_input).
func test_only_the_buttons_take_the_mouse() -> void:
	var banner: ResultBanner = _banner()
	var buttons: Array[Button] = [banner.next_button(), banner.retry_button(), banner.menu_button()]
	var stack: Array[Node] = [banner]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is Button:
			assert_true(buttons.has(node as Button), "nút lạ: " + str(node.get_path()))
		elif node is Control:
			assert_eq((node as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE, str(node.get_path()))
	for button: Button in buttons:
		assert_ne(button.mouse_filter, Control.MOUSE_FILTER_IGNORE, button.text)
		assert_eq(button.focus_mode, Control.FOCUS_NONE, "Space không bấm lại nút " + button.text)


func test_buttons_emit_signals() -> void:
	var banner: ResultBanner = _banner()
	watch_signals(banner)
	banner.next_button().pressed.emit()
	banner.retry_button().pressed.emit()
	banner.menu_button().pressed.emit()
	assert_signal_emitted(banner, "next_pressed")
	assert_signal_emitted(banner, "retry_pressed")
	assert_signal_emitted(banner, "menu_pressed")


func test_button_texts() -> void:
	var banner: ResultBanner = _banner()
	assert_eq(banner.next_button().text, tr("result.next"))
	assert_eq(banner.retry_button().text, tr("result.retry"))
	assert_eq(banner.retry_button().text, "Đánh lại trận này")
	assert_eq(banner.menu_button().text, tr("result.menu"))


## Story 4.2 (tác giả chốt 2026-10-30): thắng trận trong chuỗi chỉ có "Tiếp"; thua, hoặc thắng trận ngoài chuỗi
## (trận thử mở bằng dev), có "Đánh lại trận này" và "Về menu".
func test_won_in_campaign_shows_only_next() -> void:
	var banner: ResultBanner = _banner()
	banner.show_result(BattleState.Phase.WON, "", true)
	assert_true(banner.next_button().visible)
	assert_false(banner.retry_button().visible)
	assert_false(banner.menu_button().visible)


func test_won_outside_campaign_shows_retry_and_menu() -> void:
	var banner: ResultBanner = _banner()
	banner.show_result(BattleState.Phase.WON, "", false)
	assert_false(banner.next_button().visible)
	assert_true(banner.retry_button().visible)
	assert_true(banner.menu_button().visible)


func test_lost_shows_retry_and_menu_for_every_reason() -> void:
	var banner: ResultBanner = _banner()
	for reason: String in ["", "het_hiep", "mat_lang", "quan_nguyen_vao_ai"]:
		# can_continue không đổi gì khi thua.
		banner.show_result(BattleState.Phase.LOST, reason, true)
		assert_false(banner.next_button().visible, reason)
		assert_true(banner.retry_button().visible, reason)
		assert_true(banner.menu_button().visible, reason)
