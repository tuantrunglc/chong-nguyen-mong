extends RefCounted
# Mẫu vi phạm: lõi luật đọc giờ thực.
# mong_doi: lõi luật không được dùng thời gian thực


func f() -> int:
	return Time.get_ticks_msec()
