extends RefCounted
# Mẫu hợp lệ: src/data được đọc file.


func f() -> bool:
	return FileAccess.file_exists("res://a.json")
