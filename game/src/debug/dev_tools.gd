class_name DevTools
extends Node2D
## Công cụ dev: chữ "DEV" ở góc trên trái và phím F1–F5. Không bật dev thì không làm gì.
## Phím đăng ký vào InputMap bằng code, chỉ khi bật dev.
## Bật dev thì chữ DEV kèm số lần mở do main.gd đếm (SaveProbe): tải lại trang mà số tăng là user:// lưu được.

const BADGE_MARGIN: int = 8
const BADGE_FONT_SIZE: int = 20
const BADGE_COLOR: Color = Color(0.85, 0.1, 0.1)
const KEYS: Array[Key] = [KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5]
## Câu log khi bấm phím, theo thứ tự F1–F5. Công cụ thật làm ở các story ghi trong ngoặc.
const MESSAGES: Array[String] = [
	"f1: chưa có công cụ tọa độ (story 1.2)",
	"f2: chưa có sao chép báo lỗi (story 2.13)",
	"f3: chưa có xem ý định ai (story 2.6)",
	"f4: không dùng",
	"f5: chưa có nạp lại dữ liệu (story 1.6)",
]

var _enabled: bool = false


## opens: số lần mở game (SaveProbe); 0 thì chữ DEV không kèm số.
func setup(enabled: bool, opens: int = 0) -> void:
	_enabled = enabled
	if not enabled:
		return
	for i: int in range(KEYS.size()):
		var action: String = _action(i)
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = KEYS[i]
		InputMap.action_add_event(action, ev)

	var badge: Label = Label.new()
	badge.text = "DEV · lần mở thứ %d" % opens if opens > 0 else "DEV"
	badge.add_theme_font_size_override("font_size", BADGE_FONT_SIZE)
	badge.add_theme_color_override("font_color", BADGE_COLOR)
	badge.position = Vector2(BADGE_MARGIN, BADGE_MARGIN)
	add_child(badge)


func _ready() -> void:
	# Godot tự bật lại xử lý input khi node vào cây, nên phải tắt ở đây chứ không ở setup().
	set_process_unhandled_input(_enabled)


func _unhandled_input(event: InputEvent) -> void:
	if not _enabled:
		return
	for i: int in range(KEYS.size()):
		if event.is_action_pressed(_action(i), false, true):
			Log.debug("dev", MESSAGES[i])
			get_viewport().set_input_as_handled()
			return


func _action(index: int) -> String:
	return "dev_f%d" % (index + 1)
