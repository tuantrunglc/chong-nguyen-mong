extends GutTest
## Chọn ô ghép cỏ–sông và biến thể hình địa hình (Story 8.2): hàm thuần, không cần màn hình.

const ASSET_DIR: String = "res://assets/textures/"
const SIZE_3: Vector2i = Vector2i(3, 3)


## Bàn size, mọi ô là symbol, riêng các ô trong overrides (ô -> ký hiệu) thì khác.
func _state(symbol: String, overrides: Dictionary = {}, size: Vector2i = SIZE_3) -> BattleState:
	var cells: Dictionary = overrides.duplicate()
	for r: int in range(size.y):
		for c: int in range(size.x):
			if not cells.has(Vector2i(c, r)):
				cells[Vector2i(c, r)] = symbol
	return BoardFixture.state({}, cells, {}, size)


func test_all_land_is_mask_15_everywhere() -> void:
	var state: BattleState = _state(".")
	for vy: int in range(SIZE_3.y + 1):
		for vx: int in range(SIZE_3.x + 1):
			assert_eq(GroundArt.mask(state, vx, vy), 15, "điểm %d,%d" % [vx, vy])


func test_all_river_is_mask_0_everywhere() -> void:
	var state: BattleState = _state("~")
	for vy: int in range(SIZE_3.y + 1):
		for vx: int in range(SIZE_3.x + 1):
			assert_eq(GroundArt.mask(state, vx, vy), 0, "điểm %d,%d" % [vx, vy])


## Một ô sông ở giữa bàn 3×3: bốn điểm quanh nó, mỗi điểm thiếu đúng một góc đất (bit NW=8 NE=4 SW=2 SE=1).
func test_single_river_cell_in_the_middle() -> void:
	var state: BattleState = _state(".", {Vector2i(1, 1): "~"})
	assert_eq(GroundArt.mask(state, 1, 1), 14, "ô sông ở góc dưới phải của điểm")
	assert_eq(GroundArt.mask(state, 2, 1), 13, "ô sông ở góc dưới trái của điểm")
	assert_eq(GroundArt.mask(state, 1, 2), 11, "ô sông ở góc trên phải của điểm")
	assert_eq(GroundArt.mask(state, 2, 2), 7, "ô sông ở góc trên trái của điểm")
	assert_eq(GroundArt.mask(state, 0, 0), 15, "điểm xa sông vẫn toàn đất")


## Tọa độ ngoài bàn kẹp vào mép: sông ở góc trên trái chạy ra tới mép bàn.
func test_outside_cells_clamp_to_the_edge() -> void:
	var state: BattleState = _state(".", {Vector2i(0, 0): "~"})
	assert_eq(GroundArt.mask(state, 0, 0), 0, "cả bốn góc đều kẹp về ô sông")
	assert_eq(GroundArt.mask(state, 1, 0), 5, "hai góc trái là sông (ngoài bàn kẹp vào), hai góc phải là đất")
	assert_eq(GroundArt.mask(state, 0, 1), 3, "hai góc trên là sông, hai góc dưới là đất")


func test_every_non_river_terrain_counts_as_land() -> void:
	for symbol: String in [".", "#", "^", "L", "D", "A"]:
		var state: BattleState = _state(".", {Vector2i(1, 1): symbol})
		for vy: int in range(1, 3):
			for vx: int in range(1, 3):
				assert_eq(GroundArt.mask(state, vx, vy), 15, "ký hiệu %s tính là đất" % symbol)


func test_variant_is_in_range_and_deterministic() -> void:
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(9, 7), Vector2i(-1, -1), Vector2i(-5, 3), Vector2i(100, -100)]:
		for count: int in [2, 4]:
			var first: int = GroundArt.variant(cell, count)
			assert_between(first, 0, count - 1, "ô %s chia %d" % [cell, count])
			assert_eq(GroundArt.variant(cell, count), first, "cùng ô cùng kết quả")
		assert_eq(GroundArt.has_co_le(cell), GroundArt.has_co_le(cell), "has_co_le tất định")


func test_every_variant_appears_on_the_biggest_board() -> void:
	for count: int in [2, 4]:
		var seen: Dictionary = {}
		for r: int in range(8):
			for c: int in range(10):
				seen[GroundArt.variant(Vector2i(c, r), count)] = true
		assert_eq(seen.size(), count, "đủ %d kiểu trên bàn 10×8" % count)


func test_every_art_path_exists() -> void:
	for m: int in range(16):
		assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.ground_path(m)), "ô ghép %d" % m)
	for r: int in range(8):
		for c: int in range(10):
			var cell: Vector2i = Vector2i(c, r)
			assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.spikes_path(cell)), "hầm chông %s" % cell)
			assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.co_le_path(cell)), "cỏ lẻ %s" % cell)
			assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.pass_path(cell)), "ô ải %s" % cell)
			assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.backdrop_path(cell)), "nền rừng %s" % cell)
			for kind: int in [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]:
				assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.block_path(kind, cell)), "khối %d %s" % [kind, cell])
	for i: int in range(GroundArt.PASS_PAIR_VARIANTS):
		assert_true(ResourceLoader.exists(ASSET_DIR + "dia_hinh/tex_o_ai_doi_trai_%d.png" % i), "ô ải đôi trái %d" % i)
		assert_true(ResourceLoader.exists(ASSET_DIR + "dia_hinh/tex_o_ai_doi_phai_%d.png" % i), "ô ải đôi phải %d" % i)
		assert_true(ResourceLoader.exists(ASSET_DIR + "dia_hinh/tex_o_ai_doi_giua_%d.png" % i), "ô ải đôi giữa %d" % i)
