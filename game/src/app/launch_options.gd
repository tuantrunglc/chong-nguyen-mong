class_name LaunchOptions
extends RefCounted
## Tham số khởi động: --dev, --tran=N|tên (desktop, sau dấu --) và ?dev=1&tran=N|tên (web).
## parse() là hàm thuần: tham số sai được trả trong warnings, người gọi tự ghi log.

## Tên file trận: chữ thường không dấu, số, dấu _, bắt đầu bằng chữ (chặn cả "../").
## \A…\z thay cho ^…$: $ của PCRE vẫn khớp trước dấu xuống dòng ở cuối ("abc\n").
const LEVEL_NAME_PATTERN: String = "\\A[a-z][a-z0-9_]*\\z"
## Số trận dài hơn thì coi là sai: to_int() với số quá int64 làm engine in ERROR.
const MAX_TRAN_DIGITS: int = 4

var dev: bool = false
## Số trận ("3", đã bỏ số 0 ở đầu) hoặc tên file trận ("thu_ba_tuong"). "" nghĩa là không chọn trận.
var tran: String = ""
var warnings: Array[String] = []


static func parse(user_args: PackedStringArray, url_query: String) -> LaunchOptions:
	var o: LaunchOptions = LaunchOptions.new()
	for arg: String in user_args:
		if arg == "--dev":
			o.dev = true
		elif arg.begins_with("--tran="):
			o._set_tran(arg.trim_prefix("--tran="), "--tran")
		else:
			o.warnings.append('bỏ qua tham số lạ: "%s"' % arg)

	for pair: String in url_query.trim_prefix("?").split("&", false):
		var eq: int = pair.find("=")
		var key: String = (pair if eq < 0 else pair.left(eq)).uri_decode()
		var value: String = "" if eq < 0 else pair.substr(eq + 1).uri_decode()
		if key == "dev":
			o.dev = value == "1"
		elif key == "tran":
			o._set_tran(value, "?tran")
		else:
			o.warnings.append('bỏ qua tham số lạ trên URL: "%s"' % key)
	return o


## Đọc tham số của lần chạy hiện tại: URL trên web, dòng lệnh trên desktop.
static func read_current() -> LaunchOptions:
	if OS.has_feature("web"):
		var search: Variant = JavaScriptBridge.eval("window.location.search", true)
		var query: String = search as String if search is String else ""
		return parse(PackedStringArray(), query)
	return parse(OS.get_cmdline_user_args(), "")


## Tác giả chốt 2026-10-17: chọn trận chỉ dùng được khi bật dev. Không bật thì bỏ tran, kèm cảnh báo.
func require_dev_for_tran() -> void:
	if not tran.is_empty() and not dev:
		warnings.append("bỏ qua tran=%s vì chưa bật dev" % tran)
		tran = ""


## Tên file trận (không có .json): số N thành "tran_0N"; tên giữ nguyên; "" nếu không chọn trận.
func level_id() -> String:
	if tran.is_empty():
		return ""
	if tran.is_valid_int():
		return "tran_%02d" % tran.to_int()
	return tran


func _set_tran(value: String, flag: String) -> void:
	if value.is_valid_int() and value.length() <= MAX_TRAN_DIGITS and value.to_int() >= 1:
		tran = str(value.to_int())
	elif RegEx.create_from_string(LEVEL_NAME_PATTERN).search(value) != null:
		tran = value
	else:
		warnings.append('tham số %s không hợp lệ: "%s", cần số từ 1 hoặc tên file trận (chữ thường không dấu, số, dấu _)'
			% [flag, value])
