extends Node2D
## Màn hình gốc: tiêu đề, bàn cờ và nhãn phiên bản ở góc dưới phải.
## Lúc mở game nạp chi_so.json và file trận; dữ liệu lỗi thì hiện màn hình lỗi thay cho bàn cờ.

enum Screen { MENU, BATTLE, TRANSITION, ERROR }

const BUILD_INFO_PATH: String = "res://build_info.json"
const VERSION_FONT_SIZE: int = 14
const VERSION_MARGIN: int = 8
## Tiêu đề nằm phía trên bàn cờ (vùng bàn cờ BoardView.AREA bắt đầu ở y = 52).
const TITLE_TOP: int = 4
const TITLE_HEIGHT: int = 44
## Chưa có màn hình chính (story 4.1): không chọn trận thì mở trận 1.
const DEFAULT_TRAN: int = 1

## Test đổi được trước khi add_child.
var stats_path: String = "res://data/chi_so.json"
var level_dir: String = "res://data/tran"

var _screen: Screen = Screen.MENU
var _level: LevelData = null
var _controller: BattleController = null
## Chỉ có khi bật dev (F1).
var _coord_overlay: CoordOverlay = null
## Chỉ có khi bật dev (F3, Story 2.6).
var _ai_overlay: AiIntentOverlay = null
var _error_screen: ErrorScreen = null
var _title_label: Label
var _board_view: BoardView
var _battle_input: BattleInput
var _battle_view: BattleView
var _hud: Hud
var _tooltip: Tooltip
var _result_banner: ResultBanner
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
	_battle_input = BattleInput.new()
	_battle_input.setup(_board_view)
	add_child(_battle_input)
	_hud = Hud.new()
	add_child(_hud)
	_tooltip = Tooltip.new()
	add_child(_tooltip)
	_result_banner = ResultBanner.new()
	_result_banner.retry_pressed.connect(_start_battle)
	add_child(_result_banner)
	_battle_view = BattleView.new()
	_battle_view.setup(_board_view, _battle_input, _hud, _tooltip)
	# Hoạt ảnh phát xong mới vẽ bản chụp cuối (Story 2.11).
	_battle_view.playback_finished.connect(_on_playback_finished)
	add_child(_battle_view)

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
	if AppState.launch.dev:
		# Con cuối của bàn cờ: nằm trên đồng quân, ẩn theo bàn cờ khi có màn hình lỗi.
		_coord_overlay = CoordOverlay.new()
		_board_view.add_child(_coord_overlay)
		dev_tools.f1_pressed.connect(_toggle_coords)
		_ai_overlay = AiIntentOverlay.new()
		add_child(_ai_overlay)
		dev_tools.f3_pressed.connect(_toggle_ai_intents)
		dev_tools.f5_pressed.connect(_reload_data)

	# Công cụ AI (Story 0.6): chỉ khi bật dev trên desktop có cửa sổ.
	McpRuntime.start_if_enabled(self, AppState.launch.dev)

	_start_battle()


## Nạp chỉ số và trận. Luôn nạp cả hai file để liệt kê đủ lỗi của cả hai. F5 gọi lại hàm này (_reload_data).
func _start_battle() -> void:
	var level_id: String = AppState.launch.level_id()
	if level_id.is_empty():
		level_id = "tran_%02d" % DEFAULT_TRAN
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
	_result_banner.hide_result()
	_controller = BattleController.new()
	_controller.start(_level, AppState.stats)
	# Bàn "trước lệnh" phải có trước: hoạt ảnh chạy trên nó, xong mới vẽ bản chụp cuối (Story 2.11).
	_show_board(_controller.snapshot())
	_battle_view.start(_controller)
	# Hiệp 1 cũng bắt đầu bằng pha địch chuẩn bị (Story 2.6): bàn người chơi thấy là bàn sau khi quân Nguyên đã đi.
	_battle_view.begin_battle()
	_hide_error()
	_screen = Screen.BATTLE


## F5 (chỉ khi bật dev): đọc lại chi_so.json và file trận từ đĩa rồi mở lại trận từ đầu, ở mọi màn hình
## (trận, lỗi, menu; tác giả chốt 2026-10-18). Không đếm lại lần mở, không khởi động lại MCP.
func _reload_data() -> void:
	Log.info("dev", "f5: nạp lại chi_so.json và file trận")
	_start_battle()


## Hoạt ảnh của lệnh vừa phát xong: vẽ bản chụp cuối và bảng kết quả (Story 2.11).
func _on_playback_finished(snapshot: BattleState) -> void:
	_show_board(snapshot)
	_result_banner.show_result(snapshot.phase)


## Thay bàn cờ bằng màn hình lỗi. Nhãn phiên bản và chữ DEV vẫn nằm trên nó.
func _show_error(errors: Array[String]) -> void:
	_hide_error()
	_controller = null
	_battle_view.stop()
	_result_banner.hide_result()
	_show_board(null)
	_board_view.visible = false
	_error_screen = ErrorScreen.new()
	var rect: Rect2 = _board_view.board_rect()
	_error_screen.position = rect.position
	_error_screen.size = rect.size
	add_child(_error_screen)
	move_child(_error_screen, _board_view.get_index() + 1)
	_error_screen.setup(errors, AppState.launch.dev)
	_error_screen.back_pressed.connect(_show_menu)
	_screen = Screen.ERROR


## Menu tạm cho tới story 4.1: bàn cờ trống.
func _show_menu() -> void:
	_hide_error()
	_controller = null
	_battle_view.stop()
	_result_banner.hide_result()
	_show_board(null)
	_screen = Screen.MENU
	Log.info("app", "về menu")


## Vẽ bản chụp lên bàn cờ (và tọa độ F1 nếu bật dev); null là bàn trống.
func _show_board(snapshot: BattleState) -> void:
	_board_view.show_state(snapshot)
	if _coord_overlay != null:
		_coord_overlay.show_state(snapshot)
	if _ai_overlay != null:
		_ai_overlay.show_state(snapshot)


## Chỉ khi đang có trận: màn hình lỗi và menu không có gì để hiện (tác giả chốt 2026-10-18).
## Bật/tắt được giữ qua các lần nạp lại trận.
func _toggle_coords() -> void:
	if _screen != Screen.BATTLE:
		return
	var shown: bool = _coord_overlay.toggle()
	Log.debug("dev", "f1: hiện tọa độ" if shown else "f1: ẩn tọa độ")


## F3: như F1, chỉ khi đang có trận. Bật/tắt giữ qua các lần nạp lại trận.
func _toggle_ai_intents() -> void:
	if _screen != Screen.BATTLE:
		return
	var shown: bool = _ai_overlay.toggle()
	Log.debug("dev", "f3: hiện ý định ai" if shown else "f3: ẩn ý định ai")


## Bỏ màn hình lỗi (nếu có) và hiện lại bàn cờ.
func _hide_error() -> void:
	if _error_screen != null:
		_error_screen.queue_free()
		_error_screen = null
	_board_view.visible = true


func _read_version() -> String:
	var value: Variant = ProjectSettings.get_setting("application/config/version", "0.0.0")
	return str(value)

