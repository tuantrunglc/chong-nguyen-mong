class_name CampaignData
extends RefCounted
## Chuỗi trận đã nạp từ data/chien_dich.json (Story 4.2). Chỉ đọc: CampaignLoader tạo.
## Chỉ ghi thứ tự trận; mưu kế mở theo trận nằm trong file trận ("muu_ke_mo", tác giả chốt 2026-10-30).

var format_version: int = 0
## Id trận theo thứ tự chơi ("tran_01"…), không rỗng, không trùng.
var levels: Array[String] = []


func first_level() -> String:
	return levels[0] if not levels.is_empty() else ""


func contains(level_id: String) -> bool:
	return levels.has(level_id)


## Trận chơi sau level_id; "" khi level_id là trận cuối hoặc không có trong chuỗi.
func next_after(level_id: String) -> String:
	var i: int = levels.find(level_id)
	if i < 0 or i == levels.size() - 1:
		return ""
	return levels[i + 1]


func is_last(level_id: String) -> bool:
	return not levels.is_empty() and levels[-1] == level_id
