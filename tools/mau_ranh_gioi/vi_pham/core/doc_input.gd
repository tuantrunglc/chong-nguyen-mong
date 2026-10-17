extends RefCounted
# Mẫu vi phạm: lõi luật đọc Input.
# mong_doi: lõi luật không được đọc Input


func f() -> bool:
	return Input.is_action_pressed("chon")
