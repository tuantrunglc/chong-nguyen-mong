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


## Dãy ải ngang: ô lẻ dùng hình bệ đá; dãy 2 ô ghép trái + phải; dãy 3 ô thêm mảnh giữa. Mọi mảnh của một dãy
## cùng kiểu hình với ô đầu dãy, kể cả dãy chạm mép bàn.
func test_pass_run_pieces_share_one_variant() -> void:
	var size: Vector2i = Vector2i(10, 3)
	for start: int in range(0, 8):
		var cells: Dictionary = {}
		for dx: int in range(3):
			cells[Vector2i(start + dx, 1)] = "A"
		var state: BattleState = _state(".", cells, size)
		var v: int = GroundArt.variant(Vector2i(start, 1), GroundArt.PASS_PAIR_VARIANTS)
		assert_eq(GroundArt.pass_path(Vector2i(start, 1), state), "dia_hinh/tex_o_ai_doi_trai_%d.png" % v, "đầu dãy từ %d" % start)
		assert_eq(GroundArt.pass_path(Vector2i(start + 1, 1), state), "dia_hinh/tex_o_ai_doi_giua_%d.png" % v, "giữa dãy từ %d" % start)
		assert_eq(GroundArt.pass_path(Vector2i(start + 2, 1), state), "dia_hinh/tex_o_ai_doi_phai_%d.png" % v, "cuối dãy từ %d" % start)
		for dx: int in range(3):
			assert_true(ResourceLoader.exists(ASSET_DIR + GroundArt.pass_path(Vector2i(start + dx, 1), state)), "hình có thật")


func test_single_pass_and_pass_pair_pick_the_right_piece() -> void:
	var lone: BattleState = _state(".", {Vector2i(1, 1): "A"})
	assert_eq(GroundArt.pass_path(Vector2i(1, 1), lone), GroundArt.pass_path(Vector2i(1, 1)), "ô ải lẻ dùng hình bệ đá")
	# Hai ô ải chồng dọc không ghép: mỗi ô vẫn là ô lẻ.
	var column: BattleState = _state(".", {Vector2i(1, 0): "A", Vector2i(1, 1): "A"})
	assert_eq(GroundArt.pass_path(Vector2i(1, 0), column), GroundArt.pass_path(Vector2i(1, 0)), "dãy dọc không ghép")
	var pair: BattleState = _state(".", {Vector2i(1, 1): "A", Vector2i(2, 1): "A"})
	var v: int = GroundArt.variant(Vector2i(1, 1), GroundArt.PASS_PAIR_VARIANTS)
	assert_eq(GroundArt.pass_path(Vector2i(1, 1), pair), "dia_hinh/tex_o_ai_doi_trai_%d.png" % v)
	assert_eq(GroundArt.pass_path(Vector2i(2, 1), pair), "dia_hinh/tex_o_ai_doi_phai_%d.png" % v, "mép phải bàn")
