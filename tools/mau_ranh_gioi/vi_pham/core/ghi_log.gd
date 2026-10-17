extends RefCounted
# Mẫu vi phạm: lõi luật ghi log.
# mong_doi: lõi luật không được ghi log


func f() -> void:
	Log.info("x", "y")
