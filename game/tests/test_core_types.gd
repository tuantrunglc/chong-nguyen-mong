extends GutTest
## Loại quân và loại địa hình: ai là tướng, ô nào đi vào được.


func test_generals() -> void:
	assert_true(UnitType.is_general(UnitType.NGUYEN_KHOAI))
	assert_true(UnitType.is_general(UnitType.PHAM_NGU_LAO))
	assert_true(UnitType.is_general(UnitType.TRAN_KHANH_DU))
	assert_false(UnitType.is_general(UnitType.BO_BINH))
	assert_false(UnitType.is_general(UnitType.KY_BINH))
	assert_false(UnitType.is_general(UnitType.CUNG_KY))


func test_walkable_terrain() -> void:
	assert_true(Terrain.is_walkable(Terrain.PLAIN))
	assert_true(Terrain.is_walkable(Terrain.SPIKES))
	assert_true(Terrain.is_walkable(Terrain.PASS))
	assert_false(Terrain.is_walkable(Terrain.RIVER))
	assert_false(Terrain.is_walkable(Terrain.FOREST))
	assert_false(Terrain.is_walkable(Terrain.GRANARY))
	assert_false(Terrain.is_walkable(Terrain.VILLAGE))
