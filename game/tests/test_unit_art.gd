extends GutTest
## Hình quân đứng yên (Story 8.3): chọn hình theo loại và hướng, hướng quay về địch gần nhất. Hàm thuần, không cần màn hình.

const ALL_TYPES: Array[int] = [
	UnitType.NGUYEN_KHOAI, UnitType.PHAM_NGU_LAO, UnitType.TRAN_KHANH_DU,
	UnitType.BO_BINH, UnitType.KY_BINH, UnitType.CUNG_KY,
]
## Tên tệp thật trong assets/textures/quan, viết tay (không suy ra từ hằng của UnitArt).
const EXPECTED_FILES: Dictionary = {
	UnitType.NGUYEN_KHOAI: "tex_khoai_south.png",
	UnitType.PHAM_NGU_LAO: "tex_lao_south.png",
	UnitType.TRAN_KHANH_DU: "tex_du_south.png",
	UnitType.BO_BINH: "tex_bo_binh_south.png",
	UnitType.KY_BINH: "tex_ky_binh_south.png",
	UnitType.CUNG_KY: "tex_cung_ky_south.png",
}
## Bàn 9×9, tướng Khoái ở giữa (4,4), một Bộ binh ở ô enemy.
const CENTER: Vector2i = Vector2i(4, 4)
const BIG: Vector2i = Vector2i(9, 9)


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


func _facing_toward(enemy_cell: Vector2i) -> int:
	var state: BattleState = BoardFixture.state({CENTER: "1", enemy_cell: "B"}, {}, {}, BIG)
	return UnitArt.facing_for(state.unit_by_id(1), state)


func test_every_type_and_facing_loads_without_error() -> void:
	for type: int in ALL_TYPES:
		for facing: int in range(UnitArt.FACING_NAMES.size()):
			var path: String = UnitArt.sprite_path(type, facing)
			assert_true(ResourceLoader.exists(Art.BASE_DIR + path), "có tệp %s" % path)
			var tex: Texture2D = Art.tex(path)
			assert_eq(tex.get_size(), Vector2(64, 64), "hình 64×64: %s" % path)
	for line: String in Log.get_lines():
		assert_false(line.contains("[ERROR][hinh]"), "không có dòng ERROR hình: %s" % line)


func test_south_file_names_match_each_type() -> void:
	var south: int = UnitArt.facing_index("south")
	for type: int in ALL_TYPES:
		assert_eq(UnitArt.sprite_path(type, south), "quan/" + (EXPECTED_FILES[type] as String))


func test_different_types_give_different_sprites() -> void:
	var seen: Dictionary = {}
	for type: int in ALL_TYPES:
		seen[UnitArt.sprite_path(type, 0)] = true
	assert_eq(seen.size(), ALL_TYPES.size(), "6 loại quân ra 6 hình khác nhau")


func test_facing_covers_all_eight_directions() -> void:
	var cases: Dictionary = {
		Vector2i(4, 7): "south", Vector2i(7, 7): "south_east", Vector2i(7, 4): "east", Vector2i(7, 1): "north_east",
		Vector2i(4, 1): "north", Vector2i(1, 1): "north_west", Vector2i(1, 4): "west", Vector2i(1, 7): "south_west",
	}
	for enemy: Vector2i in cases:
		assert_eq(_facing_toward(enemy), UnitArt.facing_index(cases[enemy] as String), "địch ở %s" % enemy)


func test_facing_rounds_to_nearest_of_eight() -> void:
	# Lệch nhẹ về một phía vẫn gộp vào hướng gần nhất (góc dưới 22,5 độ).
	assert_eq(_facing_toward(Vector2i(5, 8)), UnitArt.facing_index("south"), "rất gần hướng nam")
	assert_eq(_facing_toward(Vector2i(7, 5)), UnitArt.facing_index("east"), "rất gần hướng đông")
	assert_eq(_facing_toward(Vector2i(6, 6)), UnitArt.facing_index("south_east"))


func test_facing_picks_nearest_enemy_and_lower_id_on_tie() -> void:
	# Hai địch cách tướng 2 ô: (4,6) phía nam và (6,4) phía đông. Id nhỏ hơn thắng: thứ tự đọc bàn cho (6,4) trước.
	var state: BattleState = BoardFixture.state({CENTER: "1", Vector2i(4, 6): "B", Vector2i(6, 4): "B"}, {}, {}, BIG)
	assert_eq(state.unit_by_id(101).cell, Vector2i(6, 4), "đề bài: id 101 là địch phía đông")
	assert_eq(UnitArt.facing_for(state.unit_by_id(1), state), UnitArt.facing_index("east"),
		"hòa khoảng cách thì lấy quân id nhỏ (101, phía đông), không phải phía nam")
	# Thêm địch gần hơn (kề bên tây): nó thắng dù id lớn hơn.
	var state2: BattleState = BoardFixture.state(
		{CENTER: "1", Vector2i(4, 6): "B", Vector2i(3, 4): "B"}, {}, {}, BIG)
	assert_eq(UnitArt.facing_for(state2.unit_by_id(1), state2), UnitArt.facing_index("west"), "địch kề thắng")


func test_enemy_faces_nearest_general() -> void:
	var state: BattleState = BoardFixture.state({CENTER: "1", Vector2i(4, 7): "B"}, {}, {}, BIG)
	var bo_binh: Unit = state.unit_by_id(101)
	assert_eq(UnitArt.facing_for(bo_binh, state), UnitArt.facing_index("north"), "quân Nguyên quay về tướng")


func test_no_enemy_uses_faction_default() -> void:
	var state: BattleState = BoardFixture.state({CENTER: "1"}, {}, {}, BIG)
	assert_eq(UnitArt.facing_for(state.unit_by_id(1), state), UnitArt.facing_index("north"), "Đại Việt quay lên")
	var only_enemy: BattleState = BoardFixture.state({CENTER: "B"}, {}, {}, BIG)
	assert_eq(UnitArt.facing_for(only_enemy.unit_by_id(101), only_enemy), UnitArt.facing_index("south"),
		"Nguyên quay xuống")


func test_facing_does_not_change_state() -> void:
	var state: BattleState = BoardFixture.state({CENTER: "1", Vector2i(7, 4): "B"}, {}, {}, BIG)
	var before: Array[String] = BoardFixture.picture(state)
	UnitArt.facing_for(state.unit_by_id(1), state)
	assert_eq(BoardFixture.picture(state), before)
	assert_eq(state.validate(), [] as Array[String])


func _token_of(faction_symbol: String, moved: bool, attacked: bool) -> UnitToken:
	var cell: Vector2i = Vector2i(1, 1) if faction_symbol == "1" else Vector2i(3, 3)
	var state: BattleState = BoardFixture.state({Vector2i(1, 1): "1", Vector2i(3, 3): "B"})
	var unit: Unit = state.unit_by_id(1) if faction_symbol == "1" else state.unit_by_id(101)
	assert_eq(unit.cell, cell)
	unit.has_moved = moved
	unit.has_attacked = attacked
	var token: UnitToken = UnitToken.new()
	add_child_autofree(token)
	token.setup(unit)
	return token


func test_dai_viet_tint_follows_moved_and_attacked() -> void:
	var fresh: Color = _token_of("1", false, false).tint()
	var moved: Color = _token_of("1", true, false).tint()
	var attacked: Color = _token_of("1", false, true).tint()
	assert_eq(fresh, Color.WHITE, "còn nguyên lượt thì giữ màu hình")
	assert_eq(moved, UnitToken.MOVED_TINT)
	assert_eq(attacked, UnitToken.ATTACKED_TINT)
	assert_eq(_token_of("1", true, true).tint(), UnitToken.ATTACKED_TINT, "cả hai cờ thì lấy màu đã đánh")
	assert_gt(_distance(moved, fresh), 0.2, "đã đi khác quân nguyên lượt")
	assert_gt(_distance(attacked, fresh), 0.3, "đã đánh khác quân nguyên lượt")
	assert_gt(_distance(attacked, moved), 0.1, "đã đánh khác đã đi")
	assert_eq(moved.a, 1.0, "không dùng độ trong suốt")
	assert_eq(attacked.a, 1.0, "không dùng độ trong suốt")


func test_nguyen_units_never_tinted() -> void:
	assert_eq(_token_of("B", true, false).tint(), Color.WHITE)
	assert_eq(_token_of("B", false, true).tint(), Color.WHITE)
	assert_eq(_token_of("B", true, true).tint(), Color.WHITE)


func test_unknown_unit_type_gives_missing_path_not_crash() -> void:
	var path: String = UnitArt.sprite_path(9999, 0)
	assert_false(ResourceLoader.exists(Art.BASE_DIR + path), "không tìm ra hình thì Art.tex lo báo lỗi")


func _distance(a: Color, b: Color) -> float:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length()
