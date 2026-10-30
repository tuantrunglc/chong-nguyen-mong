extends Node2D
## Màn hình gốc: đổi giữa màn hình chính, trận, màn chuyển trận và màn hình lỗi; nhãn phiên bản ở góc dưới phải
## trên mọi màn. Mở game thì hiện màn hình chính (Story 4.1); có chọn trận (chỉ khi bật dev) thì vào thẳng trận đó.
## Vào trận thì nạp chi_so.json, chien_dich.json và file trận; dữ liệu lỗi thì hiện màn hình lỗi thay cho bàn cờ.
## Thắng trận trong chuỗi thì "Tiếp" sang màn chuyển trận rồi trận kế (Story 4.2).

enum Screen { MENU, BATTLE, TRANSITION, ERROR }

const BUILD_INFO_PATH: String = "res://build_info.json"
const VERSION_FONT_SIZE: int = 14
const VERSION_MARGIN: int = 8
## Tiêu đề nằm phía trên bàn cờ (vùng bàn cờ BoardView.AREA bắt đầu ở y = 52).
const TITLE_TOP: int = 4
const TITLE_HEIGHT: int = 44
## Thư mục file trận thật. Chuỗi trận luôn kiểm tên trận ở đây, kể cả khi test đổi level_dir để mở trận thử.
const DATA_LEVEL_DIR: String = "res://data/tran"

## Test đổi được trước khi add_child.
var stats_path: String = "res://data/chi_so.json"
var campaign_path: String = "res://data/chien_dich.json"
var level_dir: String = DATA_LEVEL_DIR

var _screen: Screen = Screen.MENU
var _level: LevelData = null
## Null tới khi nạp xong data/chien_dich.json không lỗi.
var _campaign: CampaignData = null
var _controller: BattleController = null
## Chỉ có khi bật dev (F1).
var _coord_overlay: CoordOverlay = null
## Chỉ có khi bật dev (F3, Story 2.6).
var _ai_overlay: AiIntentOverlay = null
var _error_screen: ErrorScreen = null
var _main_menu: MainMenu
var _level_transition: LevelTransition
var _title_label: Label
var _board_view: BoardView
var _battle_input: BattleInput
var _battle_view: BattleView
var _hud: Hud
var _tooltip: Tooltip
var _result_banner: ResultBanner
var _notice: Notice
var _version_label: Label
## Số lần mở game (SaveProbe) — báo cáo F2 ghi kèm.
var _opens: int = 0
## Id trận đang mở ("tran_01"), cho báo cáo F2.
var _level_id: String = ""
## Test thay được để bắt chuỗi thay vì ghi clipboard thật (headless không có clipboard). Callable() = dùng DisplayServer.
var clipboard_writer: Callable = Callable()


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
	_result_banner.next_pressed.connect(_show_transition)
	_result_banner.retry_pressed.connect(_start_battle)
	_result_banner.menu_pressed.connect(_show_menu)
	add_child(_result_banner)
	# Hai màn che bàn cờ, HUD, tooltip, bảng kết quả; nằm dưới thông báo (F2), nhãn phiên bản và chữ DEV.
	_main_menu = MainMenu.new()
	_main_menu.size = BoardView.viewport_size
	_main_menu.visible = false
	_main_menu.setup()
	_main_menu.new_game_pressed.connect(_on_new_game)
	add_child(_main_menu)
	_level_transition = LevelTransition.new()
	_level_transition.size = BoardView.viewport_size
	_level_transition.visible = false
	_level_transition.setup()
	_level_transition.next_pressed.connect(_start_battle)
	_level_transition.menu_pressed.connect(_show_menu)
	add_child(_level_transition)
	_notice = Notice.new()
	_notice.name = "Notice"
	add_child(_notice)
	_battle_view = BattleView.new()
	_battle_view.setup(_board_view, _battle_input, _hud, _tooltip, _notice)
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
	_opens = SaveProbe.bump(SaveProbe.path)
	Log.info("luu_thu", "lần mở thứ %d, user:// bền: %s" % [_opens, OS.is_userfs_persistent()])

	var dev_tools: DevTools = DevTools.new()
	dev_tools.setup(AppState.launch.dev, _opens)
	add_child(dev_tools)
	if AppState.launch.dev:
		# Con cuối của bàn cờ: nằm trên đồng quân, ẩn theo bàn cờ khi có màn hình lỗi.
		_coord_overlay = CoordOverlay.new()
		_board_view.add_child(_coord_overlay)
		dev_tools.f1_pressed.connect(_toggle_coords)
		_ai_overlay = AiIntentOverlay.new()
		add_child(_ai_overlay)
		# Bật F3 trong trận rồi về menu (hay sang màn chuyển trận): bảng nằm dưới hai màn đó, không vẽ đè lên chữ.
		move_child(_ai_overlay, _main_menu.get_index())
		dev_tools.f3_pressed.connect(_toggle_ai_intents)
		dev_tools.f5_pressed.connect(_reload_data)
		dev_tools.f2_pressed.connect(_on_f2)

	# Công cụ AI (Story 0.6): chỉ khi bật dev trên desktop có cửa sổ.
	McpRuntime.start_if_enabled(self, AppState.launch.dev)

	# Chọn trận chỉ có khi bật dev (AppState đã bỏ tran nếu chưa bật): vào thẳng trận, không qua màn hình chính.
	_level_id = AppState.launch.level_id()
	if _level_id.is_empty():
		_show_menu()
	else:
		_start_battle()


## Nút "Chơi mới" của màn hình chính: vào trận đầu của chuỗi trận.
func _on_new_game() -> void:
	Log.info("app", "chơi mới")
	_level_id = ""
	_start_battle()


## Nạp chỉ số, chuỗi trận và trận _level_id (chưa có thì trận đầu của chuỗi). Luôn nạp đủ các file để liệt kê đủ
## lỗi của cả ba; chuỗi trận hỏng mà chưa chọn trận thì không có trận nào để nạp.
## F5 (_reload_data), nút "Đánh lại trận này" và nút "Tiếp" của màn chuyển trận gọi lại hàm này.
func _start_battle() -> void:
	var stats_result: LoadResult = StatsLoader.load_stats(stats_path)
	var campaign_result: LoadResult = CampaignLoader.load_campaign(campaign_path, DATA_LEVEL_DIR)
	if _level_id.is_empty() and campaign_result.ok:
		_level_id = (campaign_result.data as CampaignData).first_level()
	var level_id: String = _level_id
	var results: Array[LoadResult] = [stats_result, campaign_result]
	var level_result: LoadResult = null
	if not level_id.is_empty():
		level_result = LevelLoader.load_level("%s/%s.json" % [level_dir, level_id])
		results.append(level_result)

	var errors: Array[String] = []
	for r: LoadResult in results:
		for w: String in r.warnings:
			Log.warn("data", w)
		errors.append_array(r.errors)
	for e: String in errors:
		Log.error("data", e)
	if not errors.is_empty():
		# Nạp lại mà lỗi thì không giữ dữ liệu của lần nạp trước.
		AppState.stats = null
		_campaign = null
		_level = null
		_show_error(errors)
		return

	AppState.stats = stats_result.data as Stats
	_campaign = campaign_result.data as CampaignData
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
	_set_cover(null)
	_screen = Screen.BATTLE


## F5 (chỉ khi bật dev): đọc lại chi_so.json, chien_dich.json và file trận từ đĩa rồi mở lại trận từ đầu, ở mọi
## màn hình (trận, lỗi, menu; tác giả chốt 2026-10-18). Ở màn chuyển trận là trận kế (Story 4.2).
## Không đếm lại lần mở, không khởi động lại MCP.
func _reload_data() -> void:
	Log.info("dev", "f5: nạp lại chi_so.json và file trận")
	_start_battle()


## F2 (chỉ khi bật dev): sao chép báo lỗi vào clipboard rồi báo trên màn hình (Story 2.13).
## Không có trận (màn hình lỗi/menu/chuyển trận) vẫn chép nhật ký + phiên bản — lỗi nạp dữ liệu là lúc cần báo cáo nhất.
func _on_f2() -> void:
	var meta: Dictionary = _report_meta()
	if _controller == null:
		var no_commands: Array[Dictionary] = []
		_copy_to_clipboard(BugReport.build(null, null, no_commands, Log.get_lines(), meta))
		Log.debug("dev", "f2: đã sao chép báo lỗi (không có trận)")
		_notice.show_text(tr("dev.copied_no_battle"))
		return
	var text: String = BugReport.build(_controller.snapshot(), _controller.round_start_snapshot(),
		_controller.round_commands(), Log.get_lines(), meta)
	_copy_to_clipboard(text)
	Log.debug("dev", "f2: đã sao chép báo lỗi (%d ký tự)" % text.length())
	_notice.show_text(tr("dev.copied"))


## Ghi clipboard; test thay `clipboard_writer` để bắt chuỗi (máy chạy test không có clipboard).
func _copy_to_clipboard(text: String) -> void:
	if clipboard_writer.is_valid():
		clipboard_writer.call(text)
	else:
		DisplayServer.clipboard_set(text)


## Thông báo ngắn (để test).
func notice() -> Notice:
	return _notice


func _report_meta() -> Dictionary:
	return {
		"build": "v%s · %s" % [_read_version(), BuildInfo.read_commit(BUILD_INFO_PATH)],
		"tran": _level_id,
		"ten_tran": _level.name if _level != null else "",
		"luc": Time.get_datetime_string_from_system(false, true),
		"lan_mo": _opens,
	}


## Hoạt ảnh của lệnh vừa phát xong: vẽ bản chụp cuối và bảng kết quả (Story 2.11).
## Trận có trong chuỗi thì thắng có nút "Tiếp" (Story 4.2).
func _on_playback_finished(snapshot: BattleState) -> void:
	_show_board(snapshot)
	var in_campaign: bool = _campaign != null and _campaign.contains(_level_id)
	_result_banner.show_result(snapshot.phase, snapshot.defeat_reason, in_campaign)


## Nút "Tiếp" của bảng Thắng! (Story 4.2): màn chuyển trận sang trận kế, hoặc màn kết thúc nếu vừa thắng trận cuối.
## Đây là chỗ duy nhất biết "vừa thắng trận X": Story 4.3 gắn tự lưu ở đây.
func _show_transition() -> void:
	var won_id: String = _level_id
	var won_level: LevelData = _level
	_stop_battle()
	if _campaign.is_last(won_id):
		_level_transition.show_campaign_end()
		Log.info("app", "thắng cả chiến dịch")
	else:
		var next_id: String = _campaign.next_after(won_id)
		var next_result: LoadResult = LevelLoader.load_level("%s/%s.json" % [level_dir, next_id])
		for w: String in next_result.warnings:
			Log.warn("data", w)
		_level_id = next_id
		if not next_result.ok:
			for e: String in next_result.errors:
				Log.error("data", e)
			_level = null
			_show_error(next_result.errors)
			return
		_level = next_result.data as LevelData
		var opened: Array[int] = []
		for kind: int in _level.stratagems:
			if not won_level.stratagems.has(kind):
				opened.append(kind)
		_level_transition.show_next(_level.name, opened)
		Log.info("app", "chuyển trận %s -> %s" % [won_id, next_id])
	_set_cover(_level_transition)
	_screen = Screen.TRANSITION


## Thay bàn cờ bằng màn hình lỗi. Nhãn phiên bản và chữ DEV vẫn nằm trên nó.
func _show_error(errors: Array[String]) -> void:
	_stop_battle()
	_set_cover(null)
	_error_screen = ErrorScreen.new()
	var rect: Rect2 = _board_view.board_rect()
	_error_screen.position = rect.position
	_error_screen.size = rect.size
	add_child(_error_screen)
	move_child(_error_screen, _board_view.get_index() + 1)
	_error_screen.setup(errors, AppState.launch.dev)
	_error_screen.back_pressed.connect(_show_menu)
	_screen = Screen.ERROR


## Màn hình chính (Story 4.1): dừng trận, xóa bàn rồi ẩn bàn cờ và tiêu đề sau màn hình chính.
func _show_menu() -> void:
	_stop_battle()
	_set_cover(_main_menu)
	_screen = Screen.MENU
	Log.info("app", "về menu")


## Rời trận (màn hình lỗi, menu, màn chuyển trận): bỏ controller, dừng hoạt ảnh, ẩn bảng kết quả, xóa và ẩn bàn cờ.
func _stop_battle() -> void:
	_hide_error()
	_controller = null
	_battle_view.stop()
	_result_banner.hide_result()
	_show_board(null)
	_board_view.visible = false


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


## Hiện một màn che (màn hình chính, màn chuyển trận) hoặc không màn nào (null). Có màn che thì ẩn tiêu đề trận
## (màn hình chính đã có tên game).
func _set_cover(cover: Control) -> void:
	_main_menu.visible = cover == _main_menu
	_level_transition.visible = cover == _level_transition
	_title_label.visible = cover == null


## Màn hình chính (để test).
func main_menu() -> MainMenu:
	return _main_menu


## Màn chuyển trận (để test).
func level_transition() -> LevelTransition:
	return _level_transition


func _read_version() -> String:
	var value: Variant = ProjectSettings.get_setting("application/config/version", "0.0.0")
	return str(value)

