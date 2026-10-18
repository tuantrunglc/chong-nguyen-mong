class_name JsonFile
extends RefCounted
## Phần dùng chung của các bộ nạp: đọc file, parse JSON, đọc số nguyên, in giá trị trong câu lỗi.
## Câu lỗi theo danh mục của story 1.1; test so nguyên văn.

const BOM: String = "﻿"


## Đường dẫn hiện trong câu lỗi: bỏ "res://" (ví dụ data/tran/tran_01.json).
static func label(path: String) -> String:
	return path.trim_prefix("res://")


## Đọc cả file; rỗng hoặc không đọc được thì trả "" (FileAccess không in lỗi ra console).
static func read_text(path: String) -> String:
	return FileAccess.get_file_as_string(path)


static func missing_file(path: String) -> LoadResult:
	var result: LoadResult = LoadResult.new()
	result.add_error("%s: không đọc được file" % label(path))
	return result


## Parse thành object. Sai thì thêm lỗi vào result và trả {} (người gọi kiểm result.ok).
## Dùng JSON.new().parse(): JSON.parse_string() tự in ERROR ra console.
static func parse_object(text: String, file: String, result: LoadResult) -> Dictionary:
	var source: String = text.trim_prefix(BOM)
	var json: JSON = JSON.new()
	if json.parse(source) != OK:
		# get_error_line() đếm từ 0; trình soạn thảo đếm từ 1.
		result.add_error("%s, dòng %d: JSON sai cú pháp (%s)"
			% [file, json.get_error_line() + 1, json.get_error_message()])
		return {}
	if not json.data is Dictionary:
		result.add_error("%s: nội dung phải là một object JSON" % file)
		return {}
	return json.data as Dictionary


## JSON của Godot 4.7 trả mọi số về float; nhận cả int (dữ liệu dựng trong code) nếu không có phần lẻ.
static func is_whole(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		var f: float = value as float
		return is_finite(f) and f == floorf(f)
	return false


## Đọc d[key] thành số nguyên >= min_value. Sai thì thêm lỗi và trả null.
## shown_key là tên khóa in trong câu lỗi (chi_so.json in đường đầy đủ "tuong.nguyen_khoai.mau").
static func get_int(d: Dictionary, key: String, shown_key: String, min_value: int,
		file: String, result: LoadResult) -> Variant:
	if not d.has(key):
		result.add_error('%s: thiếu khóa "%s"' % [file, shown_key])
		return null
	var value: Variant = d[key]
	if not is_whole(value) or int(value) < min_value:
		result.add_error('%s: "%s" phải là số nguyên từ %d trở lên, đang là %s'
			% [file, shown_key, min_value, show(value)])
		return null
	return int(value)


static func type_error(file: String, shown_key: String, kind: String, value: Variant) -> String:
	return '%s: "%s" phải là %s, đang là %s' % [file, shown_key, kind, show(value)]


## Giá trị in trong câu lỗi: chuỗi có ngoặc kép, số nguyên không có ".0" (JSON trả mọi số về float).
static func show(value: Variant) -> String:
	return JSON.stringify(_whole_to_int(value))


static func _whole_to_int(value: Variant) -> Variant:
	if value is float and is_whole(value):
		return int(value)
	if value is Array:
		var items: Array = []
		for item: Variant in value as Array:
			items.append(_whole_to_int(item))
		return items
	if value is Dictionary:
		var out: Dictionary = {}
		for key: Variant in (value as Dictionary).keys():
			out[key] = _whole_to_int((value as Dictionary)[key])
		return out
	return value
