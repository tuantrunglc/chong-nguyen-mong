extends GutTest
## Chọn khung hình chuyển động của quân (Story 8.4): hàm thuần, không cần màn hình.

const ALL_TYPES: Array[int] = [
	UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU,
	UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY,
]
const GENERALS: Array[int] = [UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU]
const WALK_FACINGS: Array[String] = ["north", "east", "south", "west"]
const ATTACK_FACINGS: Array[String] = ["east", "south", "west"]


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


func test_walk_facing_follows_the_longer_axis() -> void:
	var o: Vector2i = Vector2i(4, 4)
	assert_eq(UnitAnim.walk_facing(o, Vector2i(7, 4)), "east")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(1, 4)), "west")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(4, 6)), "south")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(4, 2)), "north")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(6, 5)), "east", "dx lớn hơn thì ngang thắng")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(5, 7)), "south", "dy lớn hơn thì dọc thắng")


func test_walk_facing_tie_prefers_south_then_north() -> void:
	var o: Vector2i = Vector2i(4, 4)
	assert_eq(UnitAnim.walk_facing(o, Vector2i(5, 5)), "south", "hòa, đi xuống thì south")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(3, 5)), "south")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(5, 3)), "north", "hòa, đi lên thì north")
	assert_eq(UnitAnim.walk_facing(o, Vector2i(3, 3)), "north")


func test_attack_facing_never_north() -> void:
	var from: Vector2 = Vector2(100, 100)
	var seen: Dictionary = {}
	for dx: int in range(-3, 4):
		for dy: int in range(-3, 4):
			var facing: String = UnitAnim.attack_facing(from, from + Vector2(dx * 64, dy * 64))
			assert_ne(facing, "north", "không có bộ hình đánh hướng bắc (%d,%d)" % [dx, dy])
			assert_has(ATTACK_FACINGS, facing)
			seen[facing] = true
	assert_eq(seen.size(), 3, "ba hướng đều xuất hiện")


func test_attack_facing_north_uses_east_when_dx_not_negative() -> void:
	var from: Vector2 = Vector2(100, 100)
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(0, -64)), "east", "thẳng lên bắc, dx = 0 thì east")
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(20, -64)), "east")
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(-20, -64)), "west", "lên bắc lệch tây thì west")
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(0, 64)), "south")
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(128, 64)), "east")
	assert_eq(UnitAnim.attack_facing(from, from + Vector2(-128, 64)), "west")


func _all_exist(paths: Array[String]) -> bool:
	for path: String in paths:
		if not ResourceLoader.exists(Art.BASE_DIR + path):
			return false
	return true


func test_walk_and_attack_frames_exist_for_every_type_and_facing() -> void:
	for type: int in ALL_TYPES:
		for facing: String in WALK_FACINGS:
			var paths: Array[String] = UnitAnim.frame_paths(type, UnitAnim.Clip.WALK, facing)
			assert_eq(paths.size(), 4, "đi %d %s" % [type, facing])
			assert_true(_all_exist(paths), "đủ 4 khung đi %d %s: %s" % [type, facing, paths])
		for facing: String in ATTACK_FACINGS:
			var paths: Array[String] = UnitAnim.frame_paths(type, UnitAnim.Clip.ATTACK, facing)
			assert_eq(paths.size(), 4)
			assert_true(_all_exist(paths), "đủ 4 khung đánh %d %s" % [type, facing])


func test_hurt_and_die_frames_exist_for_every_type() -> void:
	for type: int in ALL_TYPES:
		for clip: int in [UnitAnim.Clip.HURT, UnitAnim.Clip.DIE]:
			for facing: String in ["south", "east", "west", "north_west", "south_east"]:
				var paths: Array[String] = UnitAnim.frame_paths(type, clip, facing)
				assert_eq(paths.size(), 4)
				assert_true(_all_exist(paths), "khung %d clip %d %s" % [type, clip, facing])


func test_frame_files_are_the_real_names() -> void:
	assert_eq(UnitAnim.frame_paths(UnitType.NGUYEN_KHOAI, UnitAnim.Clip.WALK, "east")[0],
		"hoat_anh/tex_khoai_di_east_0.png")
	assert_eq(UnitAnim.frame_paths(UnitType.BO_BINH, UnitAnim.Clip.DROWN, "south")[3],
		"hoat_anh/tex_bo_binh_chet_duoi_3.png")
	assert_eq(UnitAnim.frame_paths(UnitType.PHAM_NGU_LAO, UnitAnim.Clip.ATTACK, "west")[2],
		"hoat_anh/tex_lao_danh_west_2.png")
	assert_eq(UnitAnim.frame_paths(UnitType.KY_BINH, UnitAnim.Clip.HURT, "east")[1],
		"hoat_anh/tex_ky_binh_trung_don_1.png", "quân thường dùng bộ trúng đòn chung")
	assert_eq(UnitAnim.frame_paths(UnitType.TRAN_KHANH_DU, UnitAnim.Clip.DIE, "west")[0],
		"hoat_anh/tex_du_guc_0.png")


func test_cung_ky_hurt_and_die_pick_east_or_west() -> void:
	assert_eq(UnitAnim.frame_paths(UnitType.CUNG_KY, UnitAnim.Clip.HURT, "west")[0],
		"hoat_anh/tex_cung_ky_trung_don_west_0.png")
	assert_eq(UnitAnim.frame_paths(UnitType.CUNG_KY, UnitAnim.Clip.HURT, "south_west")[0],
		"hoat_anh/tex_cung_ky_trung_don_west_0.png", "hướng chứa west thì west")
	assert_eq(UnitAnim.frame_paths(UnitType.CUNG_KY, UnitAnim.Clip.HURT, "south")[0],
		"hoat_anh/tex_cung_ky_trung_don_east_0.png", "còn lại thì east")
	assert_eq(UnitAnim.frame_paths(UnitType.CUNG_KY, UnitAnim.Clip.DIE, "north_west")[3],
		"hoat_anh/tex_cung_ky_guc_west_3.png")
	assert_eq(UnitAnim.frame_paths(UnitType.CUNG_KY, UnitAnim.Clip.DIE, "east")[3],
		"hoat_anh/tex_cung_ky_guc_east_3.png")


func test_drown_only_for_non_generals() -> void:
	for type: int in GENERALS:
		assert_eq(UnitAnim.frame_paths(type, UnitAnim.Clip.DROWN, "south"), [] as Array[String],
			"tướng không có bộ chết đuối (%d)" % type)
	for type: int in [UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY]:
		var paths: Array[String] = UnitAnim.frame_paths(type, UnitAnim.Clip.DROWN, "south")
		assert_eq(paths.size(), 4)
		assert_true(_all_exist(paths), "đủ 4 khung chết đuối %d" % type)


func test_invalid_input_gives_empty_list() -> void:
	assert_eq(UnitAnim.frame_paths(9999, UnitAnim.Clip.WALK, "east"), [] as Array[String], "loại quân lạ")
	assert_eq(UnitAnim.frame_paths(UnitType.BO_BINH, UnitAnim.Clip.WALK, "south_east"), [] as Array[String],
		"đi chỉ có 4 hướng")
	assert_eq(UnitAnim.frame_paths(UnitType.BO_BINH, UnitAnim.Clip.ATTACK, "north"), [] as Array[String],
		"đánh không có hướng bắc")
	assert_eq(UnitAnim.frame_paths(UnitType.BO_BINH, 99, "east"), [] as Array[String], "động tác lạ")
