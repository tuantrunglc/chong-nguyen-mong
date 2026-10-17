extends GutTest
## Preset export Web: đơn luồng, có file JSON, không mang theo test, GUT và addon GoPeak.

const PRESET_PATH: String = "res://export_presets.cfg"

var _cfg: ConfigFile


func before_each() -> void:
	_cfg = ConfigFile.new()
	_cfg.load(PRESET_PATH)


func _web_sections() -> Array[String]:
	var found: Array[String] = []
	for section: String in _cfg.get_sections():
		if section.begins_with("preset.") and section.count(".") == 1 \
				and _cfg.get_value(section, "platform", "") == "Web":
			found.append(section)
	return found


func _preset_value(key: String) -> Variant:
	return _cfg.get_value("preset.0", key, null)


func test_has_one_web_preset_named_web() -> void:
	assert_true(FileAccess.file_exists(PRESET_PATH), "có export_presets.cfg")
	assert_eq(_web_sections(), ["preset.0"] as Array[String], "đúng một preset Web")
	assert_eq(_preset_value("name"), "Web")


func test_includes_json_files() -> void:
	assert_string_contains(str(_preset_value("include_filter")), "*.json")


func test_excludes_tests_and_gut() -> void:
	var exclude: String = str(_preset_value("exclude_filter"))
	assert_string_contains(exclude, "tests/*")
	assert_string_contains(exclude, "addons/gut/*")


func test_excludes_gopeak_runtime() -> void:
	assert_string_contains(str(_preset_value("exclude_filter")), "addons/godot_mcp_runtime/*")


func test_single_threaded() -> void:
	assert_eq(_cfg.get_value("preset.0.options", "variant/thread_support", null), false)


func test_exports_to_build_web() -> void:
	assert_eq(_preset_value("export_path"), "../build/web/index.html")
