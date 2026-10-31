class_name SaveSystem
extends RefCounted
## Tự lưu tiến độ chiến dịch (Story 4.3, FR46): user://save.json = {"phien_ban": 1, "tran_tiep": "tran_03"}.
## Chỉ ghi trận kế tiếp, lưu sau mỗi trận thắng (không lưu giữa trận); mưu kế mở nằm trong file trận.
## Trên web, user:// là IndexedDB, kể cả trong iframe itch.io (đã thử ở Story 0.5). Không ghi log: bên gọi ghi.

const DEFAULT_PATH: String = "user://save.json"
const FORMAT_VERSION: int = 1
const KNOWN_KEYS: Array[String] = ["phien_ban", "tran_tiep"]

## Nội dung file lưu đã đọc.
class SaveData:
	extends RefCounted
	## Id trận kế tiếp ("tran_03").
	var next_level: String = ""


## File main.gd dùng. Test (và hook tests/pre_run.gd) đặt đường dẫn khác để không đụng file lưu thật.
static var path: String = DEFAULT_PATH


## Không có file: ok, data = null. Hợp lệ: data là SaveData. Hỏng: lỗi tiếng Việt (có tên file), không sập.
## Chưa kiểm trận có trong chuỗi trận: bên gọi kiểm với CampaignData.
static func load_save() -> LoadResult:
	if not FileAccess.file_exists(path):
		return LoadResult.new()
	var text: String = JsonFile.read_text(path)
	if text.is_empty():
		# Chuỗi rỗng là file rỗng, hoặc có file mà không mở được để đọc.
		if FileAccess.get_open_error() != OK:
			return JsonFile.missing_file(path)
		var result: LoadResult = LoadResult.new()
		result.add_error("%s: file lưu rỗng" % JsonFile.label(path))
		return result
	return parse_save(text, JsonFile.label(path))


static func parse_save(text: String, file: String) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var root: Dictionary = JsonFile.parse_object(text, file, result)
	if not result.ok:
		return result
	for key: Variant in root.keys():
		if not KNOWN_KEYS.has(key):
			result.add_warning("%s: bỏ qua khóa lạ %s" % [file, JsonFile.show(key)])

	# Như LevelLoader: số nguyên nào khác 1 là sai phiên bản, không phải lỗi số nguyên.
	if root.has("phien_ban") and JsonFile.is_whole(root["phien_ban"]):
		var version: int = int(root["phien_ban"])
		if version != FORMAT_VERSION:
			result.add_error('%s: "phien_ban" là %d, game chỉ đọc được bản %d' % [file, version, FORMAT_VERSION])
	else:
		JsonFile.get_int(root, "phien_ban", "phien_ban", 1, file, result)

	if not root.has("tran_tiep"):
		result.add_error('%s: thiếu khóa "tran_tiep"' % file)
	elif not root["tran_tiep"] is String or (root["tran_tiep"] as String).is_empty():
		result.add_error(JsonFile.type_error(file, "tran_tiep", "tên trận (chuỗi không rỗng)", root["tran_tiep"]))
	if result.ok:
		var save: SaveData = SaveData.new()
		save.next_level = root["tran_tiep"] as String
		result.data = save
	return result


## Ghi trận kế tiếp, trả OK hoặc mã lỗi. Ghi ra file tạm rồi mới đổi tên thành file lưu: ghi hỏng giữa chừng (đầy
## đĩa, tắt game) thì file lưu cũ còn nguyên.
static func save_next_level(level_id: String) -> Error:
	var tmp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var stored: bool = file.store_string(JSON.stringify({"phien_ban": FORMAT_VERSION, "tran_tiep": level_id}))
	var error: Error = file.get_error()
	file.close()
	if not stored or error != OK:
		DirAccess.remove_absolute(tmp_path)
		return error if error != OK else ERR_FILE_CANT_WRITE
	return DirAccess.rename_absolute(tmp_path, path)


## Xóa file lưu (thắng hết chuỗi trận), trả OK hoặc mã lỗi. Không có file thì là OK.
static func clear() -> Error:
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(path)


static func has_file() -> bool:
	return FileAccess.file_exists(path)
