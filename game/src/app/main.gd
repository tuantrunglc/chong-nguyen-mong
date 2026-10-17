extends Node2D
## Màn hình gốc: tiêu đề, bàn cờ trống và nhãn phiên bản ở góc dưới phải.

const BUILD_INFO_PATH: String = "res://build_info.json"
const VERSION_FONT_SIZE: int = 14
const VERSION_MARGIN: int = 8
## Tiêu đề nằm phía trên bàn cờ (bàn cờ bắt đầu ở y = 52).
const TITLE_TOP: int = 4
const TITLE_HEIGHT: int = 44

var _title_label: Label
var _board_view: BoardView
var _version_label: Label


func _ready() -> void:
	get_window().title = tr("app.title")

	_title_label = Label.new()
	_title_label.text = tr("app.title")
	_title_label.theme_type_variation = &"TitleLabel"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.size = Vector2(BoardView.viewport_size.x, TITLE_HEIGHT)
	_title_label.position = Vector2(0, TITLE_TOP)
	add_child(_title_label)

	_board_view = BoardView.new()
	add_child(_board_view)

	_version_label = Label.new()
	_version_label.text = "v%s · %s" % [_read_version(), BuildInfo.read_commit(BUILD_INFO_PATH)]
	_version_label.add_theme_font_size_override("font_size", VERSION_FONT_SIZE)
	_version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_version_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_version_label.size = Vector2(400, 40)
	_version_label.position = BoardView.viewport_size - _version_label.size - Vector2(VERSION_MARGIN, VERSION_MARGIN)
	add_child(_version_label)

	# Thử lưu user:// (Story 0.5): luôn đếm và ghi log, vì trên itch.io không bật được dev trong iframe
	# (tác giả chốt 2026-10-17). Xem bằng F12 → Console. Chữ trên màn hình chỉ hiện khi bật dev.
	var opens: int = SaveProbe.bump(SaveProbe.path)
	Log.info("luu_thu", "lần mở thứ %d, user:// bền: %s" % [opens, OS.is_userfs_persistent()])

	var dev_tools: DevTools = DevTools.new()
	dev_tools.setup(AppState.launch.dev, opens)
	add_child(dev_tools)

	# Công cụ AI (Story 0.6): chỉ khi bật dev trên desktop có cửa sổ.
	McpRuntime.start_if_enabled(self, AppState.launch.dev)


func _read_version() -> String:
	var value: Variant = ProjectSettings.get_setting("application/config/version", "0.0.0")
	return str(value)

