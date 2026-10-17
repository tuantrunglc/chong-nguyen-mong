extends RefCounted
# Mẫu vi phạm: lõi luật dùng số ngẫu nhiên.
# mong_doi: lõi luật không được dùng số ngẫu nhiên


func f() -> int:
	return randi() % 6
