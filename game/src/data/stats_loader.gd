class_name StatsLoader
extends RefCounted
## Nạp data/chi_so.json thành Stats. Gom mọi lỗi rồi mới trả về; không ghi log (bên gọi ghi).
## Duyệt theo danh sách cố định dưới đây, không theo khóa của JSON, để lỗi luôn ra cùng thứ tự.

const GROUPS: Array[String] = ["tuong", "quan_nguyen", "muu_ke"]

## [nhóm, tên trong file, UnitType, các khóa bắt buộc]
const UNITS: Array = [
	["tuong", "nguyen_khoai", UnitType.NGUYEN_KHOAI, ["mau", "tam_di", "sat_thuong", "do_day"]],
	["tuong", "pham_ngu_lao", UnitType.PHAM_NGU_LAO,
		["mau", "tam_di", "sat_thuong", "tam_danh_gan", "tam_danh_xa"]],
	["tuong", "tran_khanh_du", UnitType.TRAN_KHANH_DU, ["mau", "tam_di", "tam_danh", "tam_keo"]],
	["quan_nguyen", "bo_binh", UnitType.BO_BINH, ["mau", "tam_di", "sat_thuong"]],
	["quan_nguyen", "ky_binh", UnitType.KY_BINH, ["mau", "tam_di", "sat_thuong"]],
	["quan_nguyen", "cung_ky", UnitType.CUNG_KY,
		["mau", "tam_di", "sat_thuong", "tam_ban_gan", "tam_ban_xa"]],
]

## Tham số mưu kế (Story 3.12, tác giả chốt 2026-10-27): [nhóm, tên trong file, Stratagem.Kind, các khóa bắt buộc].
const STRATAGEMS: Array = [
	["muu_ke", "vuon_khong_nha_trong", Stratagem.Kind.VUON_KHONG_NHA_TRONG, ["sat_thuong"]],
	["muu_ke", "sat_that", Stratagem.Kind.SAT_THAT, ["cong_sat_thuong"]],
]

## Giá trị nhỏ nhất cho từng khóa.
const MIN_VALUE: Dictionary = {
	"mau": 1,
	"tam_di": 0,
	"sat_thuong": 1,
	"do_day": 0,
	"tam_danh_gan": 2,  # lao luôn bay qua ô kề (tác giả chốt 2026-10-19)
	"tam_danh_xa": 1,
	"tam_danh": 1,
	"tam_keo": 0,
	"tam_ban_gan": 1,
	"tam_ban_xa": 1,
	"cong_sat_thuong": 1,
}

## Cặp [gần, xa]: gần không được lớn hơn xa.
const RANGES: Array = [["tam_danh_gan", "tam_danh_xa"], ["tam_ban_gan", "tam_ban_xa"]]


static func load_stats(path: String) -> LoadResult:
	var text: String = JsonFile.read_text(path)
	if text.is_empty():
		return JsonFile.missing_file(path)
	return parse_stats(text, JsonFile.label(path))


static func parse_stats(text: String, file: String) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	var root: Dictionary = JsonFile.parse_object(text, file, result)
	if not result.ok:
		return result

	_warn_unknown(root, GROUPS, "", file, result)
	var groups: Dictionary = {}
	for group: String in GROUPS:
		if not root.has(group):
			result.add_error('%s: thiếu khóa "%s"' % [file, group])
		elif not root[group] is Dictionary:
			result.add_error(JsonFile.type_error(file, group, "một object", root[group]))
		else:
			groups[group] = root[group]
			_warn_unknown(root[group] as Dictionary, _unit_names(group), group + ".", file, result)

	var values: Dictionary = {}
	var stratagem_values: Dictionary = {}
	for entry: Array in UNITS + STRATAGEMS:
		var group: String = entry[0]
		if not groups.has(group):
			continue
		var unit_name: String = entry[1]
		var shown: String = "%s.%s" % [group, unit_name]
		var group_dict: Dictionary = groups[group] as Dictionary
		if not group_dict.has(unit_name):
			result.add_error('%s: thiếu khóa "%s"' % [file, shown])
			continue
		if not group_dict[unit_name] is Dictionary:
			result.add_error(JsonFile.type_error(file, shown, "một object", group_dict[unit_name]))
			continue
		var unit: Dictionary = group_dict[unit_name] as Dictionary
		var keys: Array = entry[3]
		_warn_unknown(unit, keys, shown + ".", file, result)
		var unit_values: Dictionary = {}
		for key: String in keys:
			var v: Variant = JsonFile.get_int(unit, key, "%s.%s" % [shown, key], MIN_VALUE[key] as int, file, result)
			if v != null:
				unit_values[key] = v
		for pair: Array in RANGES:
			var near: String = pair[0]
			var far: String = pair[1]
			if unit_values.has(near) and unit_values.has(far) and int(unit_values[near]) > int(unit_values[far]):
				result.add_error('%s: "%s.%s" (%d) lớn hơn "%s.%s" (%d)'
					% [file, shown, near, unit_values[near], shown, far, unit_values[far]])
		if group == "muu_ke":
			stratagem_values[entry[2] as int] = unit_values
		else:
			values[entry[2] as int] = unit_values

	if result.ok:
		result.data = Stats.new(values, stratagem_values)
	return result


static func _unit_names(group: String) -> Array:
	var names: Array = []
	for entry: Array in UNITS + STRATAGEMS:
		if entry[0] == group:
			names.append(entry[1])
	return names


## Khóa không có trong danh sách: cảnh báo, không phải lỗi (thường là gõ sai tên khóa).
static func _warn_unknown(d: Dictionary, known: Array, prefix: String, file: String, result: LoadResult) -> void:
	for key: Variant in d.keys():
		if not known.has(key):
			result.add_warning("%s: bỏ qua khóa lạ %s" % [file, JsonFile.show(prefix + str(key))])
