extends GutTest
## File dịch: mọi khóa trong text.csv dịch được, kể cả khi máy đặt ngôn ngữ tiếng Anh.
## Không so với chữ cụ thể: tác giả được quyền sửa chữ trong CSV.

const CSV_PATH: String = "res://i18n/text.csv"

var _old_locale: String = ""


func before_each() -> void:
	_old_locale = TranslationServer.get_locale()


func after_each() -> void:
	TranslationServer.set_locale(_old_locale)


func _keys() -> Array[String]:
	var keys: Array[String] = []
	var text: String = FileAccess.get_file_as_string(CSV_PATH)
	var lines: PackedStringArray = text.split("\n")
	for i: int in range(1, lines.size()):
		var line: String = lines[i].strip_edges()
		if line.is_empty():
			continue
		keys.append(line.get_slice(",", 0))
	return keys


func test_csv_has_app_title() -> void:
	assert_has(_keys(), "app.title")


func test_every_key_translates_on_english_machine() -> void:
	TranslationServer.set_locale("en")
	var keys: Array[String] = _keys()
	assert_gt(keys.size(), 0, "text.csv có khóa")
	for key: String in keys:
		var value: String = tr(key)
		assert_ne(value, key, "khóa %s chưa được dịch" % key)
		assert_ne(value, "", "khóa %s dịch ra chuỗi rỗng" % key)


func test_fallback_locale_is_vietnamese() -> void:
	assert_eq(ProjectSettings.get_setting("internationalization/locale/fallback"), "vi")
