extends Node2D
## Màn hình gốc: bàn cờ trống và nhãn phiên bản ở góc dưới phải.

const BUILD_INFO_PATH: String = "res://build_info.json"
const VERSION_FONT_SIZE: int = 14
const VERSION_MARGIN: int = 8

var _board_view: BoardView
var _version_label: Label


func _ready() -> void:
	_board_view = BoardView.new()
	add_child(_board_view)

	_version_label = Label.new()
	_version_label.text = "v%s · %s" % [_read_version(), _read_commit()]
	_version_label.add_theme_font_size_override("font_size", VERSION_FONT_SIZE)
	_version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_version_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_version_label.size = Vector2(400, 40)
	_version_label.position = BoardView.VIEWPORT_SIZE - _version_label.size - Vector2(VERSION_MARGIN, VERSION_MARGIN)
	add_child(_version_label)


func _read_version() -> String:
	var value: Variant = ProjectSettings.get_setting("application/config/version", "0.0.0")
	return str(value)


func _read_commit() -> String:
	if not FileAccess.file_exists(BUILD_INFO_PATH):
		return "dev"
	var text: String = FileAccess.get_file_as_string(BUILD_INFO_PATH)
	# JSON.new().parse() trả mã lỗi mà không in ERROR (JSON.parse_string() thì in).
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not json.data is Dictionary:
		return "dev"
	var info: Dictionary = json.data as Dictionary
	var commit: Variant = info.get("commit", "")
	if not commit is String or (commit as String).is_empty():
		return "dev"
	return commit as String
