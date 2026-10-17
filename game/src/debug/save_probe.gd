class_name SaveProbe
extends RefCounted
## Thử lưu user:// (Story 0.5): mỗi lần mở game đếm thêm 1 vào một file nhỏ.
## Tải lại trang mà số tăng là user:// lưu bền (trên web là IndexedDB, kể cả trong iframe itch.io).
## Không phải lưu game thật: lưu game ở user://save.json, làm ở E4.

const DEFAULT_PATH: String = "user://thu_luu.json"
const KEY: String = "so_lan_mo"

## File main.gd dùng. Test đặt đường dẫn khác để không ghi vào file thật.
static var path: String = DEFAULT_PATH


## Đọc số lần mở đã lưu (thiếu hoặc hỏng thì coi là 0), ghi số mới và trả về số mới.
static func bump(file_path: String) -> int:
	var count: int = _read(file_path) + 1
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return count
	file.store_string(JSON.stringify({KEY: count}))
	file.close()
	return count


static func _read(file_path: String) -> int:
	if not FileAccess.file_exists(file_path):
		return 0
	# JSON.new().parse() trả mã lỗi mà không in ERROR (JSON.parse_string() thì in).
	var json: JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string(file_path)) != OK or not json.data is Dictionary:
		return 0
	var value: Variant = (json.data as Dictionary).get(KEY, 0)
	if not (value is float or value is int):
		return 0
	return maxi(int(value), 0)
