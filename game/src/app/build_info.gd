class_name BuildInfo
extends RefCounted
## Đọc mã commit do tools/chay.sh ghi ra. Mọi trường hợp hỏng đều lặng lẽ trả về "dev".


static func read_commit(path: String) -> String:
	if not FileAccess.file_exists(path):
		return "dev"
	var text: String = FileAccess.get_file_as_string(path)
	# JSON.new().parse() trả mã lỗi mà không in ERROR (JSON.parse_string() thì in).
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return "dev"
	var info: Dictionary = json.data as Dictionary
	var commit: Variant = info.get("commit", "")
	if not commit is String or (commit as String).is_empty():
		return "dev"
	return commit as String
