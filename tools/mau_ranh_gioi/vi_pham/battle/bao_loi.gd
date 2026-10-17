extends Node2D
# Mẫu vi phạm: tầng battle dùng push_error thay vì Log.error.
# mong_doi: chỉ Log được in ra console (dùng Log.info/warn/error/debug)


func f() -> void:
	push_error("x")
