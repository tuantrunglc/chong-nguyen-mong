extends GutTest
## Giao diện bằng hình (Story 8.5): kiểu khung và nút, biểu tượng trên HUD, chân dung và biểu tượng máu trong khung
## thông tin. Test kiểm hành vi thật (đọc stylebox, icon, kích thước), không so hằng với hằng.

const GIAO_DIEN: String = "res://assets/textures/giao_dien/"
const CHAN_DUNG: String = "res://assets/textures/chan_dung/"
const SHORT_TEXT: String = "Nguyễn Khoái\nMáu 3/3\nKhông có đòn nào"


func before_each() -> void:
	Art.reset_for_test()
	UiStyle.reset_for_test()
	Log.clear()


func _texture_of(style: StyleBox) -> Texture2D:
	return (style as StyleBoxTexture).texture


func test_panel_and_tooltip_use_the_real_frames() -> void:
	var panel: StyleBoxTexture = UiStyle.panel() as StyleBoxTexture
	assert_eq(panel.texture.resource_path, GIAO_DIEN + "tex_khung_bang_48x48.png")
	assert_eq(panel.texture.get_size(), Vector2(48, 48))
	assert_gt(panel.texture_margin_left, 0.0, "có lề 9-slice")
	assert_eq(panel.get_content_margin(SIDE_LEFT), panel.texture_margin_left, "không nói thì lề trong bằng lề 9-slice")
	var tip: StyleBoxTexture = UiStyle.tooltip(10.0) as StyleBoxTexture
	assert_eq(tip.texture.resource_path, GIAO_DIEN + "tex_khung_tooltip_32x32.png")
	assert_eq(tip.get_content_margin(SIDE_TOP), 10.0, "lề trong theo lời gọi")
	assert_eq(Log.get_lines().size(), 0, "không báo lỗi hình")


func test_button_has_four_different_states() -> void:
	var names: Dictionary = {
		UiStyle.ButtonState.NORMAL: "tex_nut_9slice_normal.png",
		UiStyle.ButtonState.HOVER: "tex_nut_9slice_hover.png",
		UiStyle.ButtonState.PRESSED: "tex_nut_9slice_pressed.png",
		UiStyle.ButtonState.DISABLED: "tex_nut_9slice_disabled.png",
	}
	for state: int in names:
		var style: StyleBoxTexture = UiStyle.button(state)
		assert_eq(style.texture.resource_path, GIAO_DIEN + (names[state] as String))
		assert_eq(style.texture.get_size(), Vector2(32, 24))
	assert_same(UiStyle.button(UiStyle.ButtonState.HOVER), UiStyle.button(UiStyle.ButtonState.HOVER),
		"dựng một lần rồi dùng lại")


func test_apply_button_sets_all_states_and_drops_focus_outline() -> void:
	var button: Button = Button.new()
	add_child_autofree(button)
	UiStyle.apply_button(button)
	for style_name: String in ["normal", "hover", "pressed", "disabled"]:
		assert_true(button.get_theme_stylebox(style_name) is StyleBoxTexture, style_name)
	assert_ne(_texture_of(button.get_theme_stylebox("normal")), _texture_of(button.get_theme_stylebox("hover")))
	assert_true(button.get_theme_stylebox("focus") is StyleBoxEmpty, "không vẽ viền focus")


func test_all_ui_art_files_exist() -> void:
	var paths: Array[String] = [UiStyle.ICON_ROUND, UiStyle.ICON_HP, UiStyle.ICON_MORALE]
	for path: Variant in UiStyle.STRATAGEM_ICONS.values():
		paths.append(path as String)
	for path: Variant in UiStyle.MISSION_ICONS.values():
		paths.append(path as String)
	for path: Variant in UiStyle.PORTRAITS.values():
		paths.append(path as String)
	for path: String in paths:
		assert_true(ResourceLoader.exists(Art.BASE_DIR + path), path)
	assert_eq(UiStyle.portrait_path(UnitType.NGUYEN_KHOAI), "chan_dung/tex_chan_dung_khoai.png")
	assert_eq(UiStyle.portrait_path(UnitType.PHAM_NGU_LAO), "chan_dung/tex_chan_dung_lao.png")
	assert_eq(UiStyle.portrait_path(UnitType.TRAN_KHANH_DU), "chan_dung/tex_chan_dung_du.png")
	assert_eq(UiStyle.portrait_path(UnitType.BO_BINH), "", "quân Nguyên không có chân dung")


# ---------- HUD ----------

func _hud() -> Hud:
	var hud: Hud = Hud.new()
	add_child_autofree(hud)
	return hud


func test_hud_buttons_use_texture_styles() -> void:
	var hud: Hud = _hud()
	hud.show_stratagems([Stratagem.Kind.VUON_KHONG_NHA_TRONG, Stratagem.Kind.SAT_THAT], [] as Array[int])
	var buttons: Array[Button] = [hud.undo_button(), hud.replay_button(), hud.end_turn_button(),
		hud.fast_forward_button(), hud.help_button(),
		hud.stratagem_button(Stratagem.Kind.SAT_THAT)]
	for button: Button in buttons:
		for style_name: String in ["normal", "hover", "pressed", "disabled"]:
			assert_true(button.get_theme_stylebox(style_name) is StyleBoxTexture, "%s %s" % [button.text, style_name])
		assert_eq(button.focus_mode, Control.FOCUS_NONE, "nút vẫn không nhận focus")


func test_stratagem_buttons_have_their_own_icons() -> void:
	var hud: Hud = _hud()
	hud.show_stratagems([Stratagem.Kind.VUON_KHONG_NHA_TRONG, Stratagem.Kind.SAT_THAT], [] as Array[int])
	var vknt: Button = hud.stratagem_button(Stratagem.Kind.VUON_KHONG_NHA_TRONG)
	var sat_that: Button = hud.stratagem_button(Stratagem.Kind.SAT_THAT)
	assert_eq(vknt.icon.resource_path, GIAO_DIEN + "tex_ke_vuon_khong_nha_trong.png")
	assert_eq(sat_that.icon.resource_path, GIAO_DIEN + "tex_ke_sat_that.png")
	assert_eq(sat_that.text, "Sát Thát (W)", "chữ nút giữ nguyên")


func test_hud_round_row_has_icon_and_unchanged_text() -> void:
	var hud: Hud = _hud()
	hud.show_turn(2, false, false, 0, false, 6)
	assert_eq(hud.round_icon().resource_path, GIAO_DIEN + "tex_hiep_24x24.png")
	assert_eq(hud.round_text(), "Hiệp 2/6")
	assert_false(hud.round_has_highlight())
	hud.show_turn(6, false, false, 0, false, 6)
	assert_true(hud.round_has_highlight(), "hiệp cuối vẫn nổi bật")


func test_hud_morale_row_shows_icon_only_with_village() -> void:
	var hud: Hud = _hud()
	hud.show_turn(1, false, false, 0, false, 0, 0, 0)
	assert_null(hud.morale_icon(), "không có làng thì ẩn cả biểu tượng")
	hud.show_turn(1, false, false, 0, false, 0, 3, 3)
	assert_eq(hud.morale_icon().resource_path, GIAO_DIEN + "tex_icon_long_dan.png")
	assert_eq(hud.morale_text(), "Lòng dân: 3/3")


func test_hud_mission_row_follows_level_kind() -> void:
	var hud: Hud = _hud()
	hud.show_turn(1, false, false, 0)
	assert_eq(hud.mission_text(), "", "không biết kiểu trận thì ẩn dòng")
	hud.show_turn(1, false, false, 0, false, 0, 0, 0, LevelData.Mission.ELIMINATE)
	assert_eq(hud.mission_text(), "Tiêu diệt")
	assert_eq(hud.mission_icon().resource_path, GIAO_DIEN + "tex_nhiem_vu_tieu_diet_24x24.png")
	hud.show_turn(1, false, false, 0, false, 0, 0, 0, LevelData.Mission.HOLD_PASS)
	assert_eq(hud.mission_text(), "Giữ ải")
	assert_eq(hud.mission_icon().resource_path, GIAO_DIEN + "tex_nhiem_vu_giu_ai_24x24.png")


# ---------- Khung thông tin ----------

func _tooltip() -> Tooltip:
	var tip: Tooltip = Tooltip.new()
	add_child_autofree(tip)
	return tip


func test_tooltip_uses_texture_frame() -> void:
	var tip: Tooltip = _tooltip()
	assert_true(tip.get_theme_stylebox("panel") is StyleBoxTexture)


func test_tooltip_portrait_widens_the_box_and_keeps_text() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text(SHORT_TEXT)
	await get_tree().process_frame
	var plain: Vector2 = tip.size
	assert_false(tip.portrait_visible())
	tip.show_text(SHORT_TEXT, Art.tex("chan_dung/tex_chan_dung_khoai.png"))
	await get_tree().process_frame
	assert_true(tip.portrait_visible())
	assert_gte(tip.size.x, plain.x + UiStyle.PORTRAIT_SIZE, "khung rộng thêm cỡ chân dung")
	assert_gte(tip.size.y, UiStyle.PORTRAIT_SIZE, "khung cao ít nhất bằng chân dung")
	assert_eq(tip.text(), SHORT_TEXT, "chữ gốc không đổi")
	tip.show_text(SHORT_TEXT)
	await get_tree().process_frame
	assert_false(tip.portrait_visible(), "dòng sau không chân dung thì ẩn")
	assert_eq(tip.size, plain, "về cỡ cũ")


func test_tooltip_hp_icon_shows_on_requested_line_only() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text(SHORT_TEXT, null, 1)
	await get_tree().process_frame
	assert_true(tip.icon_visible())
	assert_eq(tip.text(), SHORT_TEXT)
	tip.show_text("Đồng bằng\nKhông có hiệu ứng")
	await get_tree().process_frame
	assert_false(tip.icon_visible(), "địa hình không có biểu tượng máu")
	var two_lines: float = tip.size.y
	tip.show_text("Đồng bằng\nKhông có hiệu ứng\nThêm một dòng")
	await get_tree().process_frame
	assert_gt(tip.size.y, two_lines, "thêm dòng thì khung cao thêm, không bị khóa cỡ")


func test_tooltip_with_portrait_stays_on_screen_near_the_edge() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text(SHORT_TEXT, Art.tex("chan_dung/tex_chan_dung_khoai.png"))
	await get_tree().process_frame
	var screen: Vector2 = tip.get_viewport_rect().size
	tip.place_at(screen - Vector2(2, 2))
	assert_lte(tip.position.x + tip.size.x, screen.x, "không tràn mép phải")
	assert_lte(tip.position.y + tip.size.y, screen.y, "không tràn mép dưới")


func test_tooltip_hp_icon_sits_on_the_hp_line_even_with_line_spacing() -> void:
	var tip: Tooltip = _tooltip()
	tip._label.add_theme_constant_override("line_spacing", 6)
	tip.show_text(SHORT_TEXT, null, 1)
	await get_tree().process_frame
	var font: Font = tip._label.get_theme_font("font")
	var line_height: float = font.get_height(tip._label.get_theme_font_size("font_size"))
	var center_y: float = tip._icon.position.y + UiStyle.ICON_SIZE / 2.0
	var line_top: float = line_height + 6.0
	assert_gte(center_y, line_top, "tâm biểu tượng nằm từ đầu dòng Máu")
	assert_lte(center_y, line_top + line_height, "và không quá cuối dòng Máu")


func test_tooltip_wrapped_hp_line_keeps_indent_on_every_physical_line() -> void:
	var tip: Tooltip = _tooltip()
	var long_hp: String = "Tên\nMáu " + "rất dài ".repeat(40) + "\nĐòn"
	tip.show_text(long_hp, null, 1)
	await get_tree().process_frame
	var lines: PackedStringArray = tip._label.text.split("\n")
	assert_gt(lines.size(), 3, "dòng Máu dài phải bị ngắt")
	assert_false(lines[0].begins_with(" "), "dòng khác không thụt")
	assert_true(lines[1].begins_with(" "), "dòng Máu thụt chừa chỗ icon")
	var indent_len: int = lines[1].length() - lines[1].lstrip(" ").length()
	for i: int in range(1, lines.size() - 1):
		assert_eq(lines[i].length() - lines[i].lstrip(" ").length(), indent_len, "dòng ngắt %d giữ thụt lề" % i)
	assert_false(lines[lines.size() - 1].begins_with(" "), "dòng sau dòng Máu không thụt")
	assert_eq(tip.text(), long_hp, "chữ gốc không đổi")


func test_frames_are_independent_copies() -> void:
	var a: StyleBoxTexture = UiStyle.panel() as StyleBoxTexture
	var b: StyleBoxTexture = UiStyle.panel() as StyleBoxTexture
	assert_not_same(a, b, "mỗi nơi dùng một bản để đổi lề riêng")
	a.set_content_margin_all(30.0)
	assert_eq(b.get_content_margin(SIDE_LEFT), UiStyle.PANEL_MARGIN, "đổi lề bản này không dính bản kia")
	assert_same(a.texture, b.texture, "nhưng dùng chung hình đã nạp")


func test_button_with_unknown_state_falls_back_to_normal() -> void:
	assert_same(UiStyle.button(999), UiStyle.button(UiStyle.ButtonState.NORMAL))


func test_buttons_get_readable_colors_and_dimmer_disabled_text() -> void:
	var button: Button = Button.new()
	add_child_autofree(button)
	UiStyle.apply_button(button)
	var normal: Color = button.get_theme_color("font_color")
	var disabled: Color = button.get_theme_color("font_disabled_color")
	assert_gt(normal.get_luminance(), 0.6, "chữ nút thường sáng trên nền nút tối")
	assert_lt(disabled.get_luminance(), normal.get_luminance() - 0.2, "nút mờ tối hơn hẳn nút thường")
	assert_gt(disabled.get_luminance(), 0.3, "nhưng vẫn đọc được")


func test_every_stratagem_and_mission_has_icon_and_text_key() -> void:
	for kind: int in Stratagem.Kind.values():
		assert_true(UiStyle.STRATAGEM_ICONS.has(kind), "mưu kế %d có biểu tượng" % kind)
	for mission: int in LevelData.Mission.values():
		assert_true(UiStyle.MISSION_ICONS.has(mission), "nhiệm vụ %d có biểu tượng" % mission)
		assert_true(UiStyle.MISSION_KEYS.has(mission), "nhiệm vụ %d có khóa chữ" % mission)
		assert_ne(tr(UiStyle.MISSION_KEYS[mission] as String), UiStyle.MISSION_KEYS[mission], "khóa đã được dịch")


func test_hud_frame_stays_inside_screen_and_clear_of_board() -> void:
	var hud: Hud = _hud()
	hud.show_turn(3, true, true, 1, false, 6, 3, 3, LevelData.Mission.HOLD_PASS)
	hud.show_stratagems([Stratagem.Kind.VUON_KHONG_NHA_TRONG, Stratagem.Kind.SAT_THAT], [] as Array[int])
	hud.show_phase(false)
	hud.show_hint("Bấm lần nữa để đánh")
	await get_tree().process_frame
	await get_tree().process_frame
	var frame: Rect2 = hud._frame.get_global_rect()
	assert_gte(frame.position.x, BoardView.AREA.end.x, "khung không đè bàn cờ")
	assert_gte(frame.position.y, 0.0)
	assert_lte(frame.end.y, 720.0, "khung không tràn đáy màn hình ở cột đầy nhất")
	assert_lte(frame.end.x, 1280.0)
	assert_gt(frame.size.y, 200.0, "khung co theo cột, không phải 0")


func test_buttons_on_other_screens_use_texture_styles() -> void:
	var banner: ResultBanner = ResultBanner.new()
	add_child_autofree(banner)
	var transition: LevelTransition = LevelTransition.new()
	add_child_autofree(transition)
	transition.size = Vector2(1280, 720)
	transition.setup()
	var menu: MainMenu = MainMenu.new()
	add_child_autofree(menu)
	menu.size = Vector2(1280, 720)
	menu.setup()
	var error_screen: ErrorScreen = ErrorScreen.new()
	add_child_autofree(error_screen)
	error_screen.size = Vector2(600, 400)
	error_screen.setup([] as Array[String], false)
	var buttons: Array[Button] = [banner.next_button(), banner.retry_button(), banner.menu_button(),
		transition.next_button(), transition.menu_button(), menu.new_game_button(), menu.continue_button(),
		error_screen._button]
	for button: Button in buttons:
		assert_not_null(button)
		for style_name: String in ["normal", "hover", "pressed", "disabled"]:
			assert_true(button.get_theme_stylebox(style_name) is StyleBoxTexture, "%s %s" % [button.name, style_name])


func test_hint_panel_content_margin_never_smaller_than_frame_edge() -> void:
	var panel: HintPanel = HintPanel.new()
	add_child_autofree(panel)
	var keys: Array[String] = ["hint.more"]
	panel.show_hint(keys)
	await get_tree().process_frame
	var style: StyleBox = panel._panel.get_theme_stylebox("panel")
	assert_gte(style.get_content_margin(SIDE_LEFT), UiStyle.PANEL_MARGIN, "chữ không đè góc trang trí")
	assert_eq(panel._content_width, HintPanel.HINT_PANEL_WIDTH - 2.0 * style.get_content_margin(SIDE_LEFT),
		"bề rộng chữ tính theo lề thật")
