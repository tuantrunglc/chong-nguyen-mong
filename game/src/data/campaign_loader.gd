class_name CampaignLoader
extends RefCounted
## Nạp data/chien_dich.json thành CampaignData (Story 4.2). Gom mọi lỗi rồi mới trả về; không ghi log (bên gọi ghi).
## Mỗi tên trận phải có file <level_dir>/<ten>.json; file trận được nạp lúc vào trận, ở đây chỉ kiểm có file.

const FORMAT_VERSION: int = 1
const KNOWN_KEYS: Array[String] = ["phien_ban_dinh_dang", "tran"]


static func load_campaign(path: String, level_dir: String) -> LoadResult:
	var text: String = JsonFile.read_text(path)
	if text.is_empty():
		return JsonFile.missing_file(path)
	return parse_campaign(text, JsonFile.label(path), level_dir)


static func parse_campaign(text: String, file: String, level_dir: String) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var root: Dictionary = JsonFile.parse_object(text, file, result)
	if not result.ok:
		return result

	for key: Variant in root.keys():
		if not KNOWN_KEYS.has(key):
			result.add_warning("%s: bỏ qua khóa lạ %s" % [file, JsonFile.show(key)])

	# Như LevelLoader: số nguyên nào khác 1 là sai phiên bản, không phải lỗi số nguyên.
	var version: Variant = null
	if root.has("phien_ban_dinh_dang") and JsonFile.is_whole(root["phien_ban_dinh_dang"]):
		version = int(root["phien_ban_dinh_dang"])
	else:
		JsonFile.get_int(root, "phien_ban_dinh_dang", "phien_ban_dinh_dang", 1, file, result)
	if version != null and int(version) != FORMAT_VERSION:
		result.add_error('%s: "phien_ban_dinh_dang" là %d, game chỉ đọc được bản %d'
			% [file, version, FORMAT_VERSION])

	var levels: Array[String] = _read_levels(root, file, level_dir, result)
	if not result.ok:
		return result
	var campaign: CampaignData = CampaignData.new()
	campaign.format_version = int(version)
	campaign.levels = levels
	result.data = campaign
	return result


## Đọc "tran" theo thứ tự. Mỗi mục kiểm kiểu, rồi trùng (mục trùng không kiểm lại file), rồi có file.
static func _read_levels(root: Dictionary, file: String, level_dir: String, result: LoadResult) -> Array[String]:
	var levels: Array[String] = []
	if not root.has("tran"):
		result.add_error('%s: thiếu khóa "tran"' % file)
		return levels
	if not root["tran"] is Array:
		result.add_error(JsonFile.type_error(file, "tran", "danh sách tên trận", root["tran"]))
		return levels
	var items: Array = root["tran"]
	if items.is_empty():
		result.add_error('%s: "tran" không có trận nào' % file)
		return levels
	for i: int in range(items.size()):
		var item: Variant = items[i]
		if not item is String:
			result.add_error('%s: "tran" mục %d phải là tên trận (chuỗi), đang là %s' % [file, i + 1, JsonFile.show(item)])
			continue
		var level_id: String = item
		if levels.has(level_id):
			result.add_error('%s: "tran" có %s hai lần' % [file, JsonFile.show(level_id)])
			continue
		levels.append(level_id)
		var level_path: String = "%s/%s.json" % [level_dir, level_id]
		if not FileAccess.file_exists(level_path):
			result.add_error('%s: "tran" có %s nhưng không có file %s'
				% [file, JsonFile.show(level_id), JsonFile.label(level_path)])
	return levels
