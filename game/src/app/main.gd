extends Node2D
## Màn hình gốc: tiêu đề, bàn cờ và nhãn phiên bản ở góc dưới phải.
## Lúc mở game nạp chi_so.json và file trận; dữ liệu lỗi thì hiện màn hình lỗi thay cho bàn cờ.

enum Screen { MENU, BATTLE, TRANSITION, ERROR }

const BUILD_INFO_PATH: String = "res://build_info.json"
const VERSION_FONT_SIZE: int = 14
const VERSION_MARGIN: int = 8
## Tiêu đề nằm phía trên bàn cờ (bàn cờ bắt đầu ở y = 52).
const TITLE_TOP: int = 4
const TITLE_HEIGHT: int = 44
## Chưa có màn hình chính (story 4.1): không chọn trận thì mở trận 1.
const DEFAULT_TRAN: int = 1

## Test đổi được trước khi add_child.
var stats_path: String = "res://data/chi_so.json"
var level_dir: String = "res://data/tran"

var _screen: Screen = Screen.MENU
var _level: LevelData = null
var _error_screen: ErrorScreen = null
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

	_start_battle()


## Nạp chỉ số và trận. Luôn nạp cả hai file để liệt kê đủ lỗi của cả hai. F5 (story 1.6) gọi lại hàm này.
func _start_battle() -> void:
	var tran: int = AppState.launch.tran if AppState.launch.tran > 0 else DEFAULT_TRAN
	var level_id: String = "tran_%02d" % tran
	var stats_result: LoadResult = StatsLoader.load_stats(stats_path)
	var level_result: LoadResult = LevelLoader.load_level("%s/%s.json" % [level_dir, level_id])

	var errors: Array[String] = []
	for r: LoadResult in [stats_result, level_result]:
		for w: String in r.warnings:
			Log.warn("data", w)
		errors.append_array(r.errors)
	for e: String in errors:
		Log.error("data", e)
	if not errors.is_empty():
		# Nạp lại mà lỗi thì không giữ dữ liệu của lần nạp trước.
		AppState.stats = null
		_level = null
		_show_error(errors)
		return

	AppState.stats = stats_result.data as Stats
	_level = level_result.data as LevelData
	Log.info("battle", "nạp trận %s" % level_id)
	_hide_error()
	_screen = Screen.BATTLE


## Thay bàn cờ bằng màn hình lỗi. Nhãn phiên bản và chữ DEV vẫn nằm trên nó.
func _show_error(errors: Array[String]) -> void:
	_hide_error()
	_board_view.visible = false
	_error_screen = ErrorScreen.new()
	_error_screen.position = _board_view.position
	_error_screen.size = Vector2(_board_view.cols, _board_view.rows) * BoardView.CELL_SIZE
	add_child(_error_screen)
	move_child(_error_screen, _board_view.get_index() + 1)
	_error_screen.setup(errors, AppState.launch.dev)
	_error_screen.back_pressed.connect(_show_menu)
	_screen = Screen.ERROR


## Menu tạm cho tới story 4.1: bàn cờ trống.
func _show_menu() -> void:
	_hide_error()
	_screen = Screen.MENU
	Log.info("app", "về menu")


## Bỏ màn hình lỗi (nếu có) và hiện lại bàn cờ.
func _hide_error() -> void:
	if _error_screen != null:
		_error_screen.queue_free()
		_error_screen = null
	_board_view.visible = true


func _read_version() -> String:
	var value: Variant = ProjectSettings.get_setting("application/config/version", "0.0.0")
	return str(value)

