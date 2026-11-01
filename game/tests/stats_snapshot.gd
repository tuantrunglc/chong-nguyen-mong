class_name StatsSnapshot
extends RefCounted
## Bản chụp chỉ số cho kịch bản luật và test chặt từng trận (Story 4.6, tác giả chốt 2026-11-01): kịch bản luật là
## spec ở đúng các con số lúc duyệt, nên chạy với tests/chi_so_kich_ban.json; tác giả sửa data/chi_so.json để cân
## bằng thì kịch bản không đỏ. Chỉ game và bộ kiểm lời giải 6 trận (SolutionCheck) đọc số thật.
## Muốn kịch bản theo số mới: chép data/chi_so.json đè lên bản chụp, có chủ đích, rồi chạy lại test.

const PATH: String = "res://tests/chi_so_kich_ban.json"
const REAL_PATH: String = "res://data/chi_so.json"


static func load_stats() -> LoadResult:
	return StatsLoader.load_stats(PATH)


## Các chỗ số thật khác bản chụp, mỗi chỗ một câu "tuong.nguyen_khoai.sat_thuong: kịch bản 2, thật 3".
## Rỗng khi giống hệt về giá trị (khác khoảng trắng hay thứ tự khóa không tính).
static func differences() -> Array[String]:
	var snapshot: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	var real: Variant = JSON.parse_string(FileAccess.get_file_as_string(REAL_PATH))
	# File thiếu hoặc JSON hỏng: parse_string trả null, không được coi là "không khác biệt".
	if not snapshot is Dictionary:
		return ["%s thiếu hoặc không phải JSON đúng" % PATH] as Array[String]
	if not real is Dictionary:
		return ["%s thiếu hoặc không phải JSON đúng" % REAL_PATH] as Array[String]
	return diff_values(snapshot, real)


## Như differences() nhưng trên hai giá trị JSON đã đọc (để test).
static func diff_values(snapshot: Variant, real: Variant) -> Array[String]:
	var out: Array[String] = []
	_diff("", snapshot, real, out)
	return out


static func _diff(prefix: String, a: Variant, b: Variant, out: Array[String]) -> void:
	if a is Dictionary and b is Dictionary:
		var keys: Array = (a as Dictionary).keys()
		for k: Variant in (b as Dictionary).keys():
			if not keys.has(k):
				keys.append(k)
		keys.sort()
		for k: Variant in keys:
			var path: String = str(k) if prefix.is_empty() else "%s.%s" % [prefix, k]
			_diff(path, (a as Dictionary).get(k), (b as Dictionary).get(k), out)
		return
	if a != b:
		out.append("%s: kịch bản %s, thật %s" % [prefix, _text(a), _text(b)])


static func _text(v: Variant) -> String:
	if v == null:
		return "không có"
	if v is float and is_equal_approx(v as float, roundf(v as float)):
		return str(int(v as float))
	return str(v)
