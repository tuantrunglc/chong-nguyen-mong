class_name Log
# Mẫu hợp lệ: chỉ src/debug/log.gd được in ra console.


static func f(line: String) -> void:
	print(line)
	printerr(line)
