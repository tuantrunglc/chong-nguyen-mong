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


## Mỗi dòng đúng số cột của dòng tiêu đề: chữ có dấu phẩy mà quên ngoặc kép thì Godot cắt mất nửa câu sau dấu phẩy.
func test_every_row_has_exactly_the_header_columns() -> void:
	var file: FileAccess = FileAccess.open(CSV_PATH, FileAccess.READ)
	assert_not_null(file, "mở được text.csv")
	var header: PackedStringArray = file.get_csv_line()
	var line_number: int = 1
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		line_number += 1
		if row.size() == 1 and row[0].is_empty():
			continue
		assert_eq(row.size(), header.size(), "dòng %d (%s) có dấu phẩy chưa bọc ngoặc kép" % [line_number, row[0]])
