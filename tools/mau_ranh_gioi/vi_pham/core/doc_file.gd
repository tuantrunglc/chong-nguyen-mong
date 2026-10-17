extends RefCounted
# Mẫu vi phạm: lõi luật đọc file.
# mong_doi: lõi luật không được đọc/ghi file


func f() -> bool:
	return FileAccess.file_exists("res://a.json")
