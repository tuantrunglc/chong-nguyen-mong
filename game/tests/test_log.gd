extends GutTest
## Log: định dạng 4 cấp, giữ 200 dòng gần nhất, DEBUG chỉ ghi khi bật dev.


func before_each() -> void:
	Log.clear()
	Log.debug_enabled = false


func after_each() -> void:
	Log.clear()
	Log.debug_enabled = false


func test_each_level_has_its_format() -> void:
	Log.debug_enabled = true
	Log.error("save", "file hỏng")
	Log.warn("data", "khóa thừa")
	Log.info("app", "tran=3")
	Log.debug("ai", "chọn ô 4,2")
	assert_eq(Log.get_lines(), PackedStringArray([
		"[ERROR][save] file hỏng",
		"[WARN][data] khóa thừa",
		"[INFO][app] tran=3",
		"[DEBUG][ai] chọn ô 4,2",
	]))


func test_keeps_only_last_200_lines() -> void:
	for i: int in range(1, 202):
		Log.info("thu", "dong %d" % i)
	var lines: PackedStringArray = Log.get_lines()
	assert_eq(lines.size(), Log.MAX_LINES)
	assert_eq(lines[0], "[INFO][thu] dong 2")
	assert_eq(lines[lines.size() - 1], "[INFO][thu] dong 201")


func test_debug_is_dropped_when_dev_is_off() -> void:
	Log.debug("ai", "khong ghi")
	assert_eq(Log.get_lines().size(), 0)


func test_debug_is_kept_when_dev_is_on() -> void:
	Log.debug_enabled = true
	Log.debug("ai", "co ghi")
	assert_eq(Log.get_lines(), PackedStringArray(["[DEBUG][ai] co ghi"]))


func test_get_lines_returns_a_copy() -> void:
	Log.info("app", "goc")
	var lines: PackedStringArray = Log.get_lines()
	lines.append("them")
	lines[0] = "sua"
	assert_eq(Log.get_lines(), PackedStringArray(["[INFO][app] goc"]))


func test_clear_empties_the_buffer() -> void:
	Log.info("app", "mot")
	Log.clear()
	assert_eq(Log.get_lines().size(), 0)
