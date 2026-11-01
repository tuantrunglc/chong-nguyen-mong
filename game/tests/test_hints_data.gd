extends GutTest
## Dữ liệu gợi ý luật đầu trận (Story 4.8): khóa "goi_y" của file trận và chữ trong i18n/text.csv.

const CAMPAIGN_PATH: String = "res://data/chien_dich.json"
const LEVEL_DIR: String = "res://data/tran"
const MAX_LINE_CHARS: int = 120


func _level_text(hints: Variant, include: bool = true) -> String:
	var root: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("%s/tran_01.json" % LEVEL_DIR)) as Dictionary
	root.erase("goi_y")
	if include:
		root["goi_y"] = hints
	return JSON.stringify(root)


func test_valid_hints_are_read() -> void:
	var r: LoadResult = LevelLoader.parse_level(_level_text(["hint.tran_01.1", "hint.tran_02.2"]), "t.json")
	assert_true(r.ok, "; ".join(r.errors))
	assert_eq((r.data as LevelData).hints, ["hint.tran_01.1", "hint.tran_02.2"] as Array[String])


func test_missing_hints_means_no_hint() -> void:
	var r: LoadResult = LevelLoader.parse_level(_level_text(null, false), "t.json")
	assert_true(r.ok, "; ".join(r.errors))
	assert_eq((r.data as LevelData).hints, [] as Array[String])


func test_bad_hints_are_errors_naming_the_key() -> void:
	for bad: Variant in ["hint.x", [], ["a", "b", "c"], [1], [""], ["   "], {"a": 1}]:
		var r: LoadResult = LevelLoader.parse_level(_level_text(bad), "t.json")
		assert_false(r.ok, "goi_y = %s phải là lỗi" % JSON.stringify(bad))
		assert_string_contains("; ".join(r.errors), "goi_y")
		assert_string_contains("; ".join(r.errors), "t.json")


func test_every_campaign_level_has_translated_short_hints() -> void:
	var cr: LoadResult = CampaignLoader.load_campaign(CAMPAIGN_PATH, LEVEL_DIR)
	assert_true(cr.ok, "; ".join(cr.errors))
	for level_id: String in (cr.data as CampaignData).levels:
		var lr: LoadResult = LevelLoader.load_level("%s/%s.json" % [LEVEL_DIR, level_id])
		assert_true(lr.ok, "; ".join(lr.errors))
		var level: LevelData = lr.data as LevelData
		assert_false(level.hints.is_empty(), "%s có gợi ý" % level_id)
		assert_lte(level.hints.size(), 2, "%s: tối đa 2 dòng" % level_id)
		for key: String in level.hints:
			var text: String = TranslationServer.translate(key)
			assert_ne(text, key, "%s: khóa %s chưa có trong i18n/text.csv" % [level_id, key])
			assert_lte(text.length(), MAX_LINE_CHARS, "%s: dòng gợi ý quá dài (%d ký tự)" % [level_id, text.length()])


func test_help_rows_are_translated() -> void:
	for row: Array in HintPanel.HELP_ROWS:
		for key: Variant in row:
			assert_ne(TranslationServer.translate(key as String), key, "thiếu khóa %s trong i18n/text.csv" % key)
	for key: String in ["help.title", "help.close", "hint.more", "hud.help"]:
		assert_ne(TranslationServer.translate(key), key, "thiếu khóa %s" % key)
