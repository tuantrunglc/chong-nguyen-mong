extends RefCounted
# Mẫu vi phạm: lõi luật gọi get_tree().
# mong_doi: lõi luật không được truy cập cây scene


func f() -> void:
	get_tree()
