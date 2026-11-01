extends GutTest
## Hình trong assets/textures (Story 8.1): có ghi nguồn, đúng tên, đúng bảng màu, lọc Nearest, và Art.tex không làm kẹt game.

const TEXTURES_DIR: String = "res://assets/textures"
const CREDITS_PATH: String = "res://assets/CREDITS.md"
const NAME_PATTERN: String = "^tex_[a-z0-9_]+\\.png$"
## Tranh vẽ lớn, tài liệu không ghi "đã chuẩn hóa Resurrect 64": miễn kiểm bảng màu.
const PALETTE_EXEMPT_DIRS: Array[String] = ["man_hinh", "chan_dung"]

## Resurrect 64 (Kerrie Lake, lospec.com/palette-list/resurrect-64). Chép từ
## _bmad-output/planning-artifacts/art-reference/resurrect-64.gpl; file đó nằm ngoài game/ nên test không đọc trực tiếp.
const RESURRECT_64: Array[String] = [
	"2e222f", "3e3546", "625565", "966c6c", "ab947a", "694f62", "7f708a", "9babb2",
	"c7dcd0", "ffffff", "6e2727", "b33831", "ea4f36", "f57d4a", "ae2334", "e83b3b",
	"fb6b1d", "f79617", "f9c22b", "7a3045", "9e4539", "cd683d", "e6904e", "fbb954",
	"4c3e24", "676633", "a2a947", "d5e04b", "fbff86", "165a4c", "239063", "1ebc73",
	"91db69", "cddf6c", "313638", "374e4a", "547e64", "92a984", "b2ba90", "0b5e65",
	"0b8a8f", "0eaf9b", "30e1b9", "8ff8e2", "323353", "484a77", "4d65b4", "4d9be6",
	"8fd3ff", "45293f", "6b3e75", "905ea9", "a884f3", "eaaded", "753c54", "a24b6f",
	"cf657f", "ed8099", "831c5d", "c32454", "f04f78", "f68181", "fca790", "fdcbb0",
]


func before_each() -> void:
	Art.reset_for_test()
	Log.clear()


## Mọi file .png dưới assets/textures, đường dẫn dạng "assets/textures/<nhóm>/tex_x.png", theo thứ tự tên.
func _all_pngs(dir: String = TEXTURES_DIR) -> Array[String]:
	var found: Array[String] = []
	var d: DirAccess = DirAccess.open(dir)
	if d == null:
		return found
	var names: PackedStringArray = d.get_files()
	names.sort()
	for n: String in names:
		if n.ends_with(".png"):
			found.append((dir + "/" + n).trim_prefix("res://"))
	var subs: PackedStringArray = d.get_directories()
	subs.sort()
	for s: String in subs:
		found.append_array(_all_pngs(dir + "/" + s))
	return found


## Các mẫu đường dẫn (cột "File") trong bảng "Hình" của CREDITS.md.
func _credit_patterns() -> Array[String]:
	var patterns: Array[String] = []
	var text: String = FileAccess.get_file_as_string(CREDITS_PATH)
	var in_section: bool = false
	for line: String in text.split("\n"):
		if line.begins_with("## "):
			in_section = line.begins_with("## Hình")
			continue
		if not in_section or not line.begins_with("|"):
			continue
		var cells: PackedStringArray = line.split("|")
		if cells.size() < 3:
			continue
		var file_cell: String = cells[2]
		var parts: PackedStringArray = file_cell.split("`")
		# Phần tử lẻ nằm giữa hai dấu `
		for i: int in range(1, parts.size(), 2):
			if parts[i].begins_with("assets/textures/"):
				patterns.append(parts[i])
	return patterns


func test_textures_exist() -> void:
	assert_gt(_all_pngs().size(), 0, "assets/textures có hình (chạy tools/nap_hinh.sh)")


func test_every_png_has_a_credits_line() -> void:
	var patterns: Array[String] = _credit_patterns()
	assert_gt(patterns.size(), 0, "CREDITS.md, bảng Hình, có dòng cho hình trong assets/textures")
	for path: String in _all_pngs():
		var covered: bool = false
		for p: String in patterns:
			if path.match(p):
				covered = true
				break
		assert_true(covered, "%s chưa có dòng nào trong CREDITS.md (bảng Hình)" % path)


func test_every_credits_pattern_matches_a_file() -> void:
	var pngs: Array[String] = _all_pngs()
	for p: String in _credit_patterns():
		var hit: bool = false
		for path: String in pngs:
			if path.match(p):
				hit = true
				break
		assert_true(hit, "CREDITS.md ghi %s nhưng không có file nào khớp" % p)


func test_file_names_follow_convention() -> void:
	var re: RegEx = RegEx.new()
	re.compile(NAME_PATTERN)
	for path: String in _all_pngs():
		assert_not_null(re.search(path.get_file()), "%s sai quy ước tên tex_<tên>.png (chữ thường, không dấu, gạch dưới)" % path)


func test_default_filter_is_nearest() -> void:
	var value: int = int(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", 1))
	assert_eq(value, 0, "default_texture_filter phải là 0 (Nearest) để pixel art không nhòe")


func test_images_use_resurrect_64_only() -> void:
	var palette: Dictionary = {}
	for hex: String in RESURRECT_64:
		palette[Color.html(hex).to_rgba32() >> 8] = true
	assert_eq(palette.size(), 64, "bảng màu có đủ 64 màu")
	for path: String in _all_pngs():
		var group: String = path.trim_prefix("assets/textures/").get_slice("/", 0)
		if group in PALETTE_EXEMPT_DIRS:
			continue
		# Đọc byte thô rồi giải mã PNG: đúng điểm ảnh gốc, không cần bản import, không bị cảnh báo load_from_file.
		var img: Image = Image.new()
		var err: int = img.load_png_from_buffer(FileAccess.get_file_as_bytes("res://" + path))
		if err != OK:
			fail_test("%s: không đọc được hình (mã lỗi %d)" % [path, err])
			continue
		img.convert(Image.FORMAT_RGBA8)
		var bad: Dictionary = {}
		for y: int in img.get_height():
			for x: int in img.get_width():
				var c: Color = img.get_pixel(x, y)
				if c.a == 0.0:
					continue
				var rgb: int = c.to_rgba32() >> 8
				if not palette.has(rgb):
					bad[rgb] = true
		assert_eq(bad.size(), 0, "%s có %d màu ngoài Resurrect 64" % [path, bad.size()])


func test_art_loads_real_texture() -> void:
	var path: String = _all_pngs()[0].trim_prefix("assets/textures/")
	var tex: Texture2D = Art.tex(path)
	assert_not_null(tex)
	assert_eq(Log.get_lines().size(), 0, "hình có thật thì không ghi lỗi")
	assert_same(Art.tex(path), tex, "nạp một lần rồi nhớ")


func test_art_missing_returns_placeholder_and_logs_once() -> void:
	var tex: Texture2D = Art.tex("quan/tex_khong_co.png")
	assert_not_null(tex, "thiếu hình vẫn trả hình thay thế, không để game kẹt")
	assert_eq(tex.get_size(), Vector2(64, 64))
	var errors: Array[String] = []
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR]"):
			errors.append(line)
	assert_eq(errors.size(), 1, "báo lỗi đúng một dòng")
	if errors.size() == 1:
		assert_string_contains(errors[0], "[hinh]")
		assert_string_contains(errors[0], "Không nạp được hình")
		assert_string_contains(errors[0], "quan/tex_khong_co.png")
	Art.tex("quan/tex_khong_co.png")
	var after: int = 0
	for line: String in Log.get_lines():
		if line.begins_with("[ERROR]"):
			after += 1
	assert_eq(after, 1, "gọi lại cùng đường dẫn không báo thêm")


func test_only_art_loads_textures_directly() -> void:
	var offenders: Array[String] = []
	_scan_sources("res://src", offenders)
	assert_eq(offenders, [], "chỉ src/ui/art.gd được nạp hình thẳng (qua Art.tex)")


func _scan_sources(dir: String, offenders: Array[String]) -> void:
	var d: DirAccess = DirAccess.open(dir)
	if d == null:
		return
	for f: String in d.get_files():
		if not f.ends_with(".gd") or f == "art.gd":
			continue
		var text: String = FileAccess.get_file_as_string(dir + "/" + f)
		if text.contains("res://assets/textures"):
			offenders.append(dir + "/" + f)
	for s: String in d.get_directories():
		_scan_sources(dir + "/" + s, offenders)
