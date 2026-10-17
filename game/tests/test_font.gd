extends GutTest
## Font Be Vietnam Pro có đủ chữ cái tiếng Việt; Theme chung của project dùng đúng font này.

const REGULAR_PATH: String = "res://assets/fonts/font_be_vietnam_pro_regular.ttf"
const BOLD_PATH: String = "res://assets/fonts/font_be_vietnam_pro_bold.ttf"
const THEME_PATH: String = "res://assets/theme/main_theme.tres"
const VIETNAMESE: String = "aàảãáạăằẳẵắặâầẩẫấậbcdđeèẻẽéẹêềểễếệghiìỉĩíịklmnoòỏõóọôồổỗốộơờởỡớợpqrstuùủũúụưừửữứựvxyỳỷỹýỵ"
## Chữ số và dấu đang hiện trên màn hình (nhãn phiên bản "v0.1.0 · abc1234-sua", tiêu đề).
const DIGITS_AND_MARKS: String = "0123456789 ·:,.-\"'!?()"


func _missing_chars(path: String) -> String:
	var font: FontFile = load(path) as FontFile
	if font == null:
		return "(không nạp được %s)" % path
	var missing: String = ""
	for ch: String in VIETNAMESE + VIETNAMESE.to_upper() + DIGITS_AND_MARKS:
		if not font.has_char(ch.unicode_at(0)):
			missing += ch
	return missing


func test_regular_font_has_all_vietnamese_letters() -> void:
	assert_eq(_missing_chars(REGULAR_PATH), "", "ký tự thiếu")


func test_bold_font_has_all_vietnamese_letters() -> void:
	assert_eq(_missing_chars(BOLD_PATH), "", "ký tự thiếu")


func test_project_theme_uses_be_vietnam_pro() -> void:
	assert_eq(ProjectSettings.get_setting("gui/theme/custom"), THEME_PATH)
	var theme: Theme = load(THEME_PATH) as Theme
	assert_not_null(theme, "nạp được theme")
	if theme == null:
		return
	assert_not_null(theme.default_font, "theme có font mặc định")
	if theme.default_font != null:
		assert_eq(theme.default_font.resource_path, REGULAR_PATH)
	var title_font: Font = theme.get_font("font", &"TitleLabel")
	assert_eq(title_font.resource_path, BOLD_PATH, "TitleLabel dùng chữ đậm")
	assert_eq(theme.default_font_size, 16, "cỡ chữ thường")
	assert_eq(theme.get_font_size("font_size", &"TitleLabel"), 28, "cỡ chữ tiêu đề")
	assert_eq(theme.get_type_variation_base(&"TitleLabel"), &"Label", "TitleLabel dựa trên Label")
