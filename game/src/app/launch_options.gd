class_name LaunchOptions
extends RefCounted
## Tham số khởi động: --dev, --tran=N (desktop, sau dấu --) và ?dev=1&tran=N (web).
## parse() là hàm thuần: tham số sai được trả trong warnings, người gọi tự ghi log.

var dev: bool = false
## 0 nghĩa là không chọn trận.
var tran: int = 0
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


func _set_tran(value: String, flag: String) -> void:
	if value.is_valid_int() and value.to_int() >= 1:
		tran = value.to_int()
	else:
		warnings.append('tham số %s không hợp lệ: "%s", cần số nguyên từ 1' % [flag, value])
