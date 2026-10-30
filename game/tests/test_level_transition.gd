extends GutTest
## Màn chuyển trận (Story 4.2, FR44): tên trận kế, mưu kế vừa mở, nút "Tiếp"; hết chuỗi thì "Đã thắng cả chiến dịch"
## và nút "Về menu". Không so chữ cụ thể ngoài khóa dịch: tác giả được quyền sửa chữ trong CSV.


func _screen() -> LevelTransition:
	var screen: LevelTransition = LevelTransition.new()
	screen.size = BoardView.viewport_size
	screen.setup()
	add_child_autofree(screen)
	return screen


func _texts(node: Node) -> Array[String]:
	var out: Array[String] = []
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		stack.append_array(n.get_children())
		if n is Label and (n as Label).visible:
			out.append((n as Label).text)
	return out


func test_next_level_shows_name_and_next_button() -> void:
	var screen: LevelTransition = _screen()
	var none: Array[int] = []
	screen.show_next("Trận 2 — Ải Lãnh Kinh", none)
	var texts: Array[String] = _texts(screen)
	assert_has(texts, "Trận 2 — Ải Lãnh Kinh")
	assert_has(texts, tr("transition.next_level"))
	assert_eq(screen.stratagem_lines(), [] as Array[String], "không mở mưu kế mới thì không có dòng nào")
	assert_true(screen.next_button().visible)
	assert_false(screen.menu_button().visible)
	assert_eq(screen.next_button().text, tr("transition.next"))


func test_new_stratagems_one_line_each_in_key_order() -> void:
	var screen: LevelTransition = _screen()
	var kinds: Array[int] = [Stratagem.Kind.SAT_THAT, Stratagem.Kind.VUON_KHONG_NHA_TRONG]
	screen.show_next("Trận 6", kinds)
	assert_eq(screen.stratagem_lines(), [
		tr("transition.new_stratagem") % tr("stratagem.vuon_khong_nha_trong"),
		tr("transition.new_stratagem") % tr("stratagem.sat_that"),
	] as Array[String])
	assert_eq(screen.stratagem_lines()[0], "Mưu kế mới: Vườn không nhà trống")


func test_campaign_end_shows_only_menu() -> void:
	var screen: LevelTransition = _screen()
	var kinds: Array[int] = [Stratagem.Kind.SAT_THAT]
	screen.show_next("Trận 5", kinds)
	screen.show_campaign_end()
	var texts: Array[String] = _texts(screen)
	assert_has(texts, tr("transition.campaign_won"))
	assert_does_not_have(texts, "Trận 5", "không còn tên trận kế")
	assert_does_not_have(texts, tr("transition.next_level"))
	assert_eq(screen.stratagem_lines(), [] as Array[String], "không còn dòng mưu kế của lần trước")
	assert_false(screen.next_button().visible)
	assert_true(screen.menu_button().visible)
	assert_eq(screen.menu_button().text, tr("transition.menu"))


func test_show_next_after_end_restores_next_button() -> void:
	var screen: LevelTransition = _screen()
	screen.show_campaign_end()
	var none: Array[int] = []
	screen.show_next("Trận 2", none)
	assert_true(screen.next_button().visible)
	assert_false(screen.menu_button().visible)
	assert_does_not_have(_texts(screen), tr("transition.campaign_won"))


func test_buttons_emit_signals_and_take_no_focus() -> void:
	var screen: LevelTransition = _screen()
	watch_signals(screen)
	screen.next_button().pressed.emit()
	screen.menu_button().pressed.emit()
	assert_signal_emitted(screen, "next_pressed")
	assert_signal_emitted(screen, "menu_pressed")
	for button: Button in [screen.next_button(), screen.menu_button()]:
		assert_eq(button.focus_mode, Control.FOCUS_NONE, "Space không bấm nút " + button.text)
