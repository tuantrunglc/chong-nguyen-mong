extends Node
## Autoload duy nhất (không có class_name, vì trùng tên autoload là lỗi).
## Giữ tham số khởi động và chỉ số đã nạp (main.gd nạp); E4 thêm tiến độ, cài đặt.

var launch: LaunchOptions
## Null tới khi nạp xong data/chi_so.json không lỗi.
var stats: Stats = null


func _ready() -> void:
	launch = LaunchOptions.read_current()
	launch.require_dev_for_tran()
	Log.debug_enabled = launch.dev
	for w: String in launch.warnings:
		Log.warn("app", w)
	if launch.dev:
		Log.info("app", "dev=1")
	if not launch.tran.is_empty():
		Log.info("app", "tran=%s" % launch.tran)
