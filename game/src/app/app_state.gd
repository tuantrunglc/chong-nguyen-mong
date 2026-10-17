extends Node
## Autoload duy nhất (không có class_name, vì trùng tên autoload là lỗi).
## Hiện chỉ giữ tham số khởi động; E1 thêm chỉ số, tiến độ, cài đặt.

var launch: LaunchOptions


func _ready() -> void:
	launch = LaunchOptions.read_current()
	launch.require_dev_for_tran()
	Log.debug_enabled = launch.dev
	for w: String in launch.warnings:
		Log.warn("app", w)
	if launch.dev:
		Log.info("app", "dev=1")
	if launch.tran > 0:
		Log.info("app", "tran=%d" % launch.tran)
