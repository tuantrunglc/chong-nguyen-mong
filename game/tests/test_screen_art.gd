extends GutTest
## Hình màn hình chính và màn chuyển trận (Story 8.6): chọn tranh theo trận, đúng cỡ để phóng ×2 vừa 1280×720.

const MAN_HINH: String = "res://assets/textures/man_hinh/"


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


func test_transition_picture_follows_the_level_about_to_start() -> void:
	assert_eq(ScreenArt.transition_for("tran_02"), ScreenArt.TRANSITION_BINH_THAN)
	for id: String in ["tran_03", "tran_04", "tran_05"]:
		assert_eq(ScreenArt.transition_for(id), ScreenArt.TRANSITION_VAN_KIEP, id)
	assert_eq(ScreenArt.transition_for("tran_06"), ScreenArt.TRANSITION_BACH_DANG)
	assert_eq(ScreenArt.campaign_end(), ScreenArt.TRANSITION_BACH_DANG)


func test_unknown_level_falls_back_without_error() -> void:
	assert_eq(ScreenArt.transition_for("tran_99"), ScreenArt.TRANSITION_VAN_KIEP)
	assert_eq(ScreenArt.transition_for(""), ScreenArt.TRANSITION_VAN_KIEP)
	assert_eq(Log.get_lines().size(), 0)


func test_every_level_of_the_campaign_has_a_real_picture() -> void:
	var campaign: Array = (JSON.parse_string(FileAccess.get_file_as_string("res://data/chien_dich.json")) as Dictionary)["tran"]
	for id: Variant in campaign:
		var path: String = ScreenArt.transition_for(id as String)
		assert_true(ResourceLoader.exists(Art.BASE_DIR + path), "%s -> %s" % [id, path])


func test_every_level_after_the_first_is_listed_in_the_table() -> void:
	var campaign: Array = (JSON.parse_string(FileAccess.get_file_as_string("res://data/chien_dich.json")) as Dictionary)["tran"]
	for i: int in range(1, campaign.size()):
		assert_true(ScreenArt.TRANSITIONS.has(campaign[i]), "%s phải có trong ScreenArt.TRANSITIONS" % campaign[i])


func test_pictures_exist_and_scale_to_the_window_exactly() -> void:
	for path: String in [ScreenArt.MENU_BACKGROUND, ScreenArt.TRANSITION_BINH_THAN, ScreenArt.TRANSITION_VAN_KIEP,
			ScreenArt.TRANSITION_BACH_DANG]:
		var texture: Texture2D = Art.tex(path)
		assert_eq(texture.get_size() * ScreenArt.SCALE, BoardView.viewport_size, "%s phóng ×2 vừa cửa sổ" % path)
	assert_eq(Art.tex(ScreenArt.LOGO).get_size(), Vector2(420, 84))
	assert_eq(Log.get_lines().size(), 0, "không báo lỗi hình")


func test_game_icon_points_to_a_real_file() -> void:
	var icon: String = ProjectSettings.get_setting("application/config/icon", "") as String
	assert_ne(icon, "", "project.godot phải khai báo config/icon")
	assert_true(ResourceLoader.exists(icon), icon)
	assert_eq((load(icon) as Texture2D).get_size(), Vector2(256, 256))


func test_itch_cover_has_the_store_size() -> void:
	var cover: Image = Image.load_from_file(ProjectSettings.globalize_path("res://").path_join("../img/pixellab-thu/toi_uu/man_hinh_chinh/f5_anh_bia_itch_io_630x500.png"))
	assert_not_null(cover, "ảnh bìa itch có thật (nằm ngoài game/, ở img/pixellab-thu)")
	if cover == null:
		return
	assert_eq(cover.get_size(), Vector2i(630, 500))
