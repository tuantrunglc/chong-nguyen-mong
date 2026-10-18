class_name BattleInput
extends Node
## Chuột và phím tắt trên bàn cờ -> signal. Không biết luật, không giữ trạng thái trận.
## Phím 1-2-3 khai báo trong InputMap bằng code (như DevTools). Dùng _unhandled_input để nút của
## màn hình lỗi (Control) nhận bấm trước.

signal general_key_pressed(index: int)
signal cell_clicked(cell: Vector2i)
## Chỉ phát khi ô dưới chuột đổi; ra ngoài bàn thì cell là BoardView.NO_CELL.
signal cell_hovered(cell: Vector2i)

## Action -> số tướng (id tướng theo ký hiệu 1, 2, 3).
const GENERAL_ACTIONS: Dictionary = {
	"select_general_1": 1,
	"select_general_2": 2,
	"select_general_3": 3,
}
const GENERAL_KEYS: Array[Key] = [KEY_1, KEY_2, KEY_3]

var _board: BoardView = null
var _hovered: Vector2i = BoardView.NO_CELL


func setup(board: BoardView) -> void:
	_board = board


## Ô dưới chuột lần cuối; NO_CELL nếu ngoài bàn hoặc chuột đã ra khỏi cửa sổ.
func hovered_cell() -> Vector2i:
	return _hovered


func _ready() -> void:
	get_window().mouse_exited.connect(_on_mouse_exited)
	var actions: Array = GENERAL_ACTIONS.keys()
	for i: int in range(actions.size()):
		var action: String = actions[i] as String
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		var ev: InputEventKey = InputEventKey.new()
		ev.physical_keycode = GENERAL_KEYS[i]
		InputMap.action_add_event(action, ev)


## Chuột ra khỏi cửa sổ (hay khung itch.io) không sinh sự kiện di chuột: coi như ra ngoài bàn.
func _on_mouse_exited() -> void:
	if _hovered != BoardView.NO_CELL:
		_hovered = BoardView.NO_CELL
		cell_hovered.emit(_hovered)


func _unhandled_input(event: InputEvent) -> void:
	for action: String in GENERAL_ACTIONS:
		if event.is_action_pressed(action, false, true):
			general_key_pressed.emit(GENERAL_ACTIONS[action] as int)
			return
	if _board == null:
		return
	var mouse: InputEventMouse = event as InputEventMouse
	if mouse == null:
		return
	# Vị trí lấy từ chính sự kiện (đổi sang tọa độ bàn cờ), không đọc con trỏ thật: đúng cả khi cửa sổ
	# co giãn và khi input được bơm vào (GoPeak, test).
	var cell: Vector2i = _board.cell_at((_board.make_input_local(mouse) as InputEventMouse).position)
	var button: InputEventMouseButton = mouse as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT and button.pressed:
		cell_clicked.emit(cell)
	elif mouse is InputEventMouseMotion and cell != _hovered:
		_hovered = cell
		cell_hovered.emit(cell)
