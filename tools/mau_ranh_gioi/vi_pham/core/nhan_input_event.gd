extends RefCounted
# Mẫu vi phạm: lõi luật nhận InputEvent.
# mong_doi: lõi luật không được đọc Input


func f(e: InputEvent) -> bool:
	return e.is_pressed()
