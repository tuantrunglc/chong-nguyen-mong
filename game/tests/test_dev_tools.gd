extends GutTest
## Phím F1–F5 chỉ có tác dụng khi bật dev; không bật dev thì không có chữ "DEV" và không có log.

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


func _press_f1(tools: DevTools) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = KEY_F1
	ev.pressed = true
	tools._unhandled_input(ev)


func _has_label(tools: DevTools) -> bool:
	for child: Node in tools.get_children():
		if child is Label:
			return true
	return false


func test_dev_off_keys_do_nothing() -> void:
	var tools: DevTools = DevTools.new()
	tools.setup(false)
	add_child_autofree(tools)
	_press_f1(tools)
	assert_eq(Log.get_lines().size(), 0, "không có dòng log nào")
	assert_false(_has_label(tools), "không có chữ DEV")
	assert_false(InputMap.has_action("dev_f1"), "không đăng ký phím dev")


func test_dev_on_shows_badge_and_logs_f1() -> void:
	Log.debug_enabled = true
	var tools: DevTools = DevTools.new()
	tools.setup(true)
	add_child_autofree(tools)
	_press_f1(tools)
	assert_eq(Log.get_lines(), PackedStringArray(["[DEBUG][dev] f1: chưa có công cụ tọa độ (story 1.2)"]))
	var badge: Label = null
	for child: Node in tools.get_children():
		if child is Label:
			badge = child as Label
	assert_not_null(badge)
	if badge != null:
		assert_eq(badge.text, "DEV")
