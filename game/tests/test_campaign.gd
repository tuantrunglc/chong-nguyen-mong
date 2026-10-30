extends GutTest
## Chuỗi trận (Story 4.2): data/chien_dich.json -> CampaignData. Câu lỗi so nguyên văn (tác giả đọc).

const FILE: String = "data/chien_dich.json"
const LEVEL_DIR: String = "res://data/tran"
const CAMPAIGN_PATH: String = "res://data/chien_dich.json"


func _parse(d: Variant) -> LoadResult:
	return CampaignLoader.parse_campaign(JSON.stringify(d), FILE, LEVEL_DIR)


func _valid() -> Dictionary:
	return {"phien_ban_dinh_dang": 1, "tran": ["tran_01", "tran_02", "tran_03"]}


func _campaign(levels: Array[String]) -> CampaignData:
	var c: CampaignData = CampaignData.new()
	c.levels = levels
	return c


# ---------- Bộ nạp ----------

func test_valid_campaign_keeps_order() -> void:
	var r: LoadResult = _parse(_valid())
	assert_true(r.ok, str(r.errors))
	assert_eq((r.data as CampaignData).levels, ["tran_01", "tran_02", "tran_03"] as Array[String])
	assert_eq(r.warnings.size(), 0)


func test_real_campaign_file_loads_and_every_level_loads() -> void:
	var r: LoadResult = CampaignLoader.load_campaign(CAMPAIGN_PATH, LEVEL_DIR)
	assert_true(r.ok, str(r.errors))
	var c: CampaignData = r.data as CampaignData
	assert_eq(c.levels, ["tran_01", "tran_02", "tran_03", "tran_04", "tran_05"] as Array[String],
		"tác giả chốt 2026-10-30: 5 trận, 4.5 thêm trận 6")
	for id: String in c.levels:
		var level: LoadResult = LevelLoader.load_level("%s/%s.json" % [LEVEL_DIR, id])
		assert_true(level.ok, "%s: %s" % [id, level.errors])


func test_missing_file() -> void:
	var r: LoadResult = CampaignLoader.load_campaign("res://data/khong_co.json", LEVEL_DIR)
	assert_eq(r.errors, ["data/khong_co.json: không đọc được file"] as Array[String])


func test_broken_json() -> void:
	var r: LoadResult = CampaignLoader.parse_campaign("{", FILE, LEVEL_DIR)
	assert_false(r.ok)
	assert_string_starts_with(r.errors[0], "data/chien_dich.json, dòng 1: JSON sai cú pháp")


func test_wrong_version() -> void:
	var d: Dictionary = _valid()
	d["phien_ban_dinh_dang"] = 2
	assert_eq(_parse(d).errors,
		['data/chien_dich.json: "phien_ban_dinh_dang" là 2, game chỉ đọc được bản 1'] as Array[String])


func test_missing_version() -> void:
	var d: Dictionary = _valid()
	d.erase("phien_ban_dinh_dang")
	assert_eq(_parse(d).errors, ['data/chien_dich.json: thiếu khóa "phien_ban_dinh_dang"'] as Array[String])


func test_missing_levels_key() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1}).errors,
		['data/chien_dich.json: thiếu khóa "tran"'] as Array[String])


func test_levels_not_a_list() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1, "tran": "tran_01"}).errors,
		['data/chien_dich.json: "tran" phải là danh sách tên trận, đang là "tran_01"'] as Array[String])


func test_empty_list() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1, "tran": []}).errors,
		['data/chien_dich.json: "tran" không có trận nào'] as Array[String])


func test_item_not_a_string() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1, "tran": ["tran_01", 2]}).errors,
		['data/chien_dich.json: "tran" mục 2 phải là tên trận (chuỗi), đang là 2'] as Array[String])


func test_duplicate_level() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1, "tran": ["tran_01", "tran_02", "tran_01"]}).errors,
		['data/chien_dich.json: "tran" có "tran_01" hai lần'] as Array[String])


func test_level_file_missing() -> void:
	assert_eq(_parse({"phien_ban_dinh_dang": 1, "tran": ["tran_01", "tran_09"]}).errors,
		['data/chien_dich.json: "tran" có "tran_09" nhưng không có file data/tran/tran_09.json'] as Array[String])


func test_all_errors_listed() -> void:
	var r: LoadResult = _parse({"phien_ban_dinh_dang": 1, "tran": [3, "tran_09", "tran_09"]})
	assert_eq(r.errors, [
		'data/chien_dich.json: "tran" mục 1 phải là tên trận (chuỗi), đang là 3',
		'data/chien_dich.json: "tran" có "tran_09" nhưng không có file data/tran/tran_09.json',
		'data/chien_dich.json: "tran" có "tran_09" hai lần',
	] as Array[String])


func test_unknown_key_warns() -> void:
	var d: Dictionary = _valid()
	d["muu_ke"] = []
	var r: LoadResult = _parse(d)
	assert_true(r.ok)
	assert_eq(r.warnings, ['data/chien_dich.json: bỏ qua khóa lạ "muu_ke"'] as Array[String])


# ---------- CampaignData ----------

func test_first_level() -> void:
	assert_eq(_campaign(["tran_02", "tran_03"] as Array[String]).first_level(), "tran_02")


func test_next_after() -> void:
	var c: CampaignData = _campaign(["tran_01", "tran_02", "tran_03"] as Array[String])
	assert_eq(c.next_after("tran_01"), "tran_02")
	assert_eq(c.next_after("tran_02"), "tran_03")
	assert_eq(c.next_after("tran_03"), "", "trận cuối: không có trận kế")
	assert_eq(c.next_after("thu_muu_ke"), "", "trận ngoài chuỗi: không có trận kế")


func test_contains_and_is_last() -> void:
	var c: CampaignData = _campaign(["tran_01", "tran_02"] as Array[String])
	assert_true(c.contains("tran_01"))
	assert_false(c.contains("thu_muu_ke"))
	assert_false(c.is_last("tran_01"))
	assert_true(c.is_last("tran_02"))
	assert_false(c.is_last("thu_muu_ke"))
