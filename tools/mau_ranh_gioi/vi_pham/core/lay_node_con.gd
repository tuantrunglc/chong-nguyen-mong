extends RefCounted
# Mẫu vi phạm: lõi luật gọi get_node().
# mong_doi: lõi luật không được truy cập cây scene


func f() -> void:
	get_node("Con")
