extends Node
## Autoload duy nhất (không có class_name, vì trùng tên autoload là lỗi).
## Hiện chỉ giữ tham số khởi động; E1 thêm chỉ số, tiến độ, cài đặt.

var launch: LaunchOptions


func _ready() -> void:
	launch = LaunchOptions.read_current()
	Log.debug_enabled = launch.dev
	for w: String in launch.warnings:
		Log.warn("app", w)
	if launch.dev:
		Log.info("app", "dev=1")
	if launch.tran > 0:
		if launch.dev:
			Log.info("app", "tran=%d" % launch.tran)
		else:
			# Tác giả chốt 2026-10-17: chọn trận chỉ dùng được khi bật dev.
			Log.warn("app", "bỏ qua tran=%d vì chưa bật dev" % launch.tran)
			launch.tran = 0
