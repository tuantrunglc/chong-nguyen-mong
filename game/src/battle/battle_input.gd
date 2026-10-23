class_name BattleInput
extends Node
## Chuột và phím tắt trên bàn cờ -> signal. Không biết luật, không giữ trạng thái trận.
## Phím 1-2-3, Z (hủy), Space (kết thúc lượt) khai báo trong InputMap bằng code (như DevTools). Dùng _unhandled_input để nút của
## màn hình lỗi (Control) nhận bấm trước.

signal general_key_pressed(index: int)
signal undo_pressed
signal replay_pressed
signal end_turn_pressed
signal cell_clicked(cell: Vector2i)
## Chỉ phát khi ô dưới chuột đổi; ra ngoài bàn thì cell là BoardView.NO_CELL.
signal cell_hovered(cell: Vector2i)

## Action -> số tướng (id tướng theo ký hiệu 1, 2, 3).
const GENERAL_ACTIONS: Dictionary = {
	"select_general_1": 1,
	"select_general_2": 2,
	"select_general_3": 3,
}
const UNDO_ACTION: String = "undo_move"
## Chơi lại hiệp (Story 3.2).
const REPLAY_ACTION: String = "replay_round"
const END_TURN_ACTION: String = "end_turn"
## Action -> phím vật lý, cho mọi phím tắt của bàn cờ.
const ACTION_KEYS: Dictionary = {
	"select_general_1": KEY_1,
	"select_general_2": KEY_2,
	"select_general_3": KEY_3,
	UNDO_ACTION: KEY_Z,
	REPLAY_ACTION: KEY_R,
	END_TURN_ACTION: KEY_SPACE,
}

var _board: BoardView = null
var _hovered: Vector2i = BoardView.NO_CELL
## Lần di chuột cuối trên cửa sổ (tọa độ màn hình); null khi chuột đã ra khỏi cửa sổ.
var _last_motion: InputEventMouseMotion = null


func setup(board: BoardView) -> void:
	_board = board


## Ô dưới chuột lần cuối; NO_CELL nếu ngoài bàn hoặc chuột đã ra khỏi cửa sổ.
func hovered_cell() -> Vector2i:
	return _hovered


func _ready() -> void:
	get_window().mouse_exited.connect(_on_mouse_exited)
	for action: String in ACTION_KEYS:
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = ACTION_KEYS[action] as Key
		InputMap.action_add_event(action, ev)


## Chuột ra khỏi cửa sổ (hay khung itch.io) không sinh sự kiện di chuột: coi như ra ngoài bàn.
func _on_mouse_exited() -> void:
	_last_motion = null
	_set_hovered(BoardView.NO_CELL)


func _unhandled_input(event: InputEvent) -> void:
	for action: String in GENERAL_ACTIONS:
		if event.is_action_pressed(action, false, true):
			general_key_pressed.emit(GENERAL_ACTIONS[action] as int)
			return
	# Không nhận lặp phím: giữ Space không kết thúc nhiều lượt liền.
	if event.is_action_pressed(UNDO_ACTION, false, true):
		undo_pressed.emit()
		return
	if event.is_action_pressed(REPLAY_ACTION, false, true):
		replay_pressed.emit()
		return
	if event.is_action_pressed(END_TURN_ACTION, false, true):
		end_turn_pressed.emit()
		return
	if _board == null:
		return
	var mouse: InputEventMouse = event as InputEventMouse
	if mouse == null:
		return
	# Vị trí lấy từ chính sự kiện (đổi sang tọa độ bàn cờ), không đọc con trỏ thật: đúng cả khi cửa sổ
	# co giãn và khi input được bơm vào (GoPeak, test). Ô là ô nhìn thấy (đồng quân, khối che ô phía sau).
	var cell: Vector2i = _pick(mouse)
	var button: InputEventMouseButton = mouse as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		cell_clicked.emit(cell)
	elif mouse is InputEventMouseMotion:
		_last_motion = mouse as InputEventMouseMotion
		_set_hovered(cell)


## Chọn lại ô dưới chuột đứng yên: đồng quân vừa dời tới có thể che ô mặt đất đang trỏ.
## Gọi sau khi bàn cờ vẽ bản chụp mới.
func refresh_hover() -> void:
	if _board != null and _last_motion != null:
		_set_hovered(_pick(_last_motion))


func _pick(mouse: InputEventMouse) -> Vector2i:
	return _board.pick_cell((_board.make_input_local(mouse) as InputEventMouse).position)


func _set_hovered(cell: Vector2i) -> void:
	if cell != _hovered:
		_hovered = cell
		cell_hovered.emit(cell)
