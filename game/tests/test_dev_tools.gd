extends GutTest
## Phím F1–F5 chỉ có tác dụng khi bật dev; không bật dev thì không có chữ "DEV", không có log, không phát signal.
## F1 phát f1_pressed (main.gd bật/tắt tọa độ), F5 phát f5_pressed (main.gd nạp lại dữ liệu); F2–F4 mới chỉ ghi log.
## Bật dev thì chữ DEV kèm số lần mở (nếu có).

const ACTIONS: Array[String] = ["dev_f1", "dev_f2", "dev_f3", "dev_f4", "dev_f5"]


func before_each() -> void:
	_reset()


func after_each() -> void:
	_reset()


func _reset() -> void:
	Log.clear()
	Log.debug_enabled = false
	for action: String in ACTIONS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)


## Bấm lần lượt F1–F5, theo đúng thứ tự main.gd dùng: setup() rồi mới vào cây.
func _make_and_press_all(enabled: bool) -> DevTools:
	var tools: DevTools = DevTools.new()
	tools.setup(enabled, 1)
	add_child_autofree(tools)
	watch_signals(tools)
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
	assert_signal_not_emitted(tools, "f1_pressed")
	assert_signal_not_emitted(tools, "f5_pressed")


func test_dev_on_shows_badge_and_logs_each_key() -> void:
	Log.debug_enabled = true
	var tools: DevTools = _make_and_press_all(true)
	assert_signal_emit_count(tools, "f1_pressed", 1)
	assert_signal_emit_count(tools, "f5_pressed", 1)
	assert_eq(Log.get_lines(), PackedStringArray([
		"[DEBUG][dev] f2: chưa có sao chép báo lỗi (story 2.13)",
		"[DEBUG][dev] f3: chưa có xem ý định ai (story 2.6)",
		"[DEBUG][dev] f4: không dùng",
	]))
	assert_true(tools.is_processing_unhandled_input(), "nhận phím")
	var badge: Label = null
	for child: Node in tools.get_children():
		if child is Label:
			badge = child as Label
	assert_not_null(badge)
	if badge != null:
		assert_eq(badge.text, "DEV · lần mở thứ 1")


func test_dev_on_without_count_shows_plain_badge() -> void:
	var tools: DevTools = DevTools.new()
	tools.setup(true)
	add_child_autofree(tools)
	var badge: Label = tools.get_child(0) as Label
	assert_eq(badge.text, "DEV")
