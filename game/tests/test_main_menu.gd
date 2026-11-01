extends GutTest
## Màn hình chính có tranh nền và logo (Story 8.6). Nút, file lưu, focus đã được test_main.gd và test_ui_style.gd kiểm.


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


func _menu() -> MainMenu:
	var menu: MainMenu = MainMenu.new()
	menu.size = BoardView.viewport_size
	menu.setup()
	add_child_autofree(menu)
	return menu


func _find_logo(node: Node) -> TextureRect:
	for child: Node in node.get_children():
		if child is TextureRect and (child as TextureRect).texture == Art.tex(ScreenArt.LOGO):
			return child as TextureRect
		var found: TextureRect = _find_logo(child)
		if found != null:
			return found
	return null


func test_title_is_the_logo_picture_not_a_label() -> void:
	var menu: MainMenu = _menu()
	var logo: TextureRect = _find_logo(menu)
	assert_not_null(logo, "có hình logo")
	if logo != null:
		assert_eq(logo.custom_minimum_size, Vector2(420, 84) * MainMenu.LOGO_SCALE)
		assert_eq(logo.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(menu.title_text(), tr("app.title"))
	assert_ne(menu.title_text(), "app.title", "khóa đã được dịch")


func test_logo_fits_inside_the_window() -> void:
	var menu: MainMenu = _menu()
	var logo: TextureRect = _find_logo(menu)
	assert_not_null(logo, "có hình logo")
	if logo == null:
		return
	assert_lte(logo.custom_minimum_size.x, BoardView.viewport_size.x)
	assert_lte(logo.custom_minimum_size.y, BoardView.viewport_size.y / 3.0, "logo không chiếm quá một phần ba chiều cao")


func test_logo_and_background_load_without_errors() -> void:
	var menu: MainMenu = _menu()
	await get_tree().process_frame
	# _draw có thể chưa chạy (headless): nạp nền trực tiếp để chắc chắn file có thật.
	assert_ne(Art.tex(ScreenArt.MENU_BACKGROUND).get_size(), Vector2(64, 64), "nền không phải ô hồng")
	assert_eq(Log.get_lines().size(), 0, "không báo lỗi hình khi vẽ màn hình chính")
	assert_eq(menu.size, BoardView.viewport_size)


func test_title_label_exists_only_when_picture_ui_is_off() -> void:
	var menu: MainMenu = _menu()
	if UiStyle.ENABLED:
		assert_null(menu.title_label(), "logo hình thay cho Label")
	else:
		assert_eq(menu.title_label().text, tr("app.title"))
