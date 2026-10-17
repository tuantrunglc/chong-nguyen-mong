class_name Log
## Ghi log cho toàn game: lớp static, không phải autoload. Mọi chỗ khác không dùng print().
## Định dạng "[CẤP][hệ_thống] thông điệp". Giữ 200 dòng gần nhất cho báo lỗi F2.
## Không dùng push_error(): GUT coi đó là lỗi engine và làm trượt test.

const MAX_LINES: int = 200

## AppState đặt theo cờ dev. Tắt thì DEBUG không in, không lưu.
static var debug_enabled: bool = false

static var _lines: PackedStringArray = PackedStringArray()


static func error(system: String, message: String) -> void:
	_write("ERROR", system, message, true)


static func warn(system: String, message: String) -> void:
	_write("WARN", system, message, true)


static func info(system: String, message: String) -> void:
	_write("INFO", system, message, false)


static func debug(system: String, message: String) -> void:
	if not debug_enabled:
		return
	_write("DEBUG", system, message, false)


## Bản sao của các dòng đang giữ, cũ nhất ở đầu.
static func get_lines() -> PackedStringArray:
	return _lines.duplicate()


static func clear() -> void:
	_lines.clear()


static func _write(level: String, system: String, message: String, to_stderr: bool) -> void:
	var line: String = "[%s][%s] %s" % [level, system, message]
	_lines.append(line)
	if _lines.size() > MAX_LINES:
		_lines.remove_at(0)
	if to_stderr:
		printerr(line)
	else:
		print(line)
