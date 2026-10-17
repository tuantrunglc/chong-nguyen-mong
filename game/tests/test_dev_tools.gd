extends GutTest
## Phím F1–F5 chỉ có tác dụng khi bật dev; không bật dev thì không có chữ "DEV" và không có log.
## Bật dev thì thử lưu user:// (đếm số lần mở). Test dùng file riêng, không đụng user://thu_luu.json thật.

const ACTIONS: Array[String] = ["dev_f1", "dev_f2", "dev_f3", "dev_f4", "dev_f5"]
const PROBE_DIR: String = "user://test_dev_tools"
const PROBE_FILE: String = PROBE_DIR + "/thu_luu.json"


func before_each() -> void:
	_reset()


func after_each() -> void:
	_reset()


func _reset() -> void:
	if FileAccess.file_exists(PROBE_FILE):
		DirAccess.remove_absolute(PROBE_FILE)
	DirAccess.remove_absolute(PROBE_DIR)
	DirAccess.make_dir_recursive_absolute(PROBE_DIR)
	Log.clear()
	Log.debug_enabled = false
	for action: String in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)


## Bấm lần lượt F1–F5, theo đúng thứ tự main.gd dùng: setup() rồi mới vào cây.
func _make_and_press_all(enabled: bool) -> DevTools:
	var tools: DevTools = DevTools.new()
	tools.probe_path = PROBE_FILE
	tools.setup(enabled)
	add_child_autofree(tools)
	for key: Key in DevTools.KEYS:
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = key
		ev.pressed = true
		tools._unhandled_input(ev)
	return tools


func _has_label(tools: DevTools) -> bool:
	for child: Node in tools.get_children():
		if child is Label:
			return true
	return false


func test_dev_off_keys_do_nothing() -> void:
	# Bật DEBUG để nếu phím lọt qua thì chắc chắn có dòng log.
	Log.debug_enabled = true
	var tools: DevTools = _make_and_press_all(false)
	assert_eq(Log.get_lines().size(), 0, "không có dòng log nào")
	assert_false(_has_label(tools), "không có chữ DEV")
	assert_false(InputMap.has_action("dev_f1"), "không đăng ký phím dev")
	assert_false(tools.is_processing_unhandled_input(), "không nhận phím")
	assert_false(FileAccess.file_exists(PROBE_FILE), "không ghi file thử lưu")


func test_dev_on_shows_badge_and_logs_each_key() -> void:
	Log.debug_enabled = true
	var tools: DevTools = _make_and_press_all(true)
	assert_eq(Log.get_lines(), PackedStringArray([
		"[INFO][luu_thu] lần mở thứ 1, user:// bền: true",
		"[DEBUG][dev] f1: chưa có công cụ tọa độ (story 1.2)",
		"[DEBUG][dev] f2: chưa có sao chép báo lỗi (story 2.13)",
		"[DEBUG][dev] f3: chưa có xem ý định ai (story 2.6)",
		"[DEBUG][dev] f4: không dùng",
		"[DEBUG][dev] f5: chưa có nạp lại dữ liệu (story 1.6)",
	]))
	assert_true(tools.is_processing_unhandled_input(), "nhận phím")
	var badge: Label = null
	for child: Node in tools.get_children():
		if child is Label:
			badge = child as Label
	assert_not_null(badge)
	if badge != null:
		assert_eq(badge.text, "DEV · lần mở thứ 1")


func test_dev_on_counts_each_open() -> void:
	var first: DevTools = DevTools.new()
	first.probe_path = PROBE_FILE
	first.setup(true)
	first.free()
	_reset_actions()
	var second: DevTools = DevTools.new()
	second.probe_path = PROBE_FILE
	second.setup(true)
	add_child_autofree(second)
	var badge: Label = second.get_child(0) as Label
	assert_eq(badge.text, "DEV · lần mở thứ 2")


func _reset_actions() -> void:
	for action: String in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
