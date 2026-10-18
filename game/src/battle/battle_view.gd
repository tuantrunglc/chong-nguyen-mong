class_name BattleView
extends Node
## Chọn tướng, đi, hủy, kết thúc lượt: nhận signal của BattleInput và Hud, gửi lệnh cho BattleController,
## nhờ BoardView vẽ ô sáng. Chỉ đọc bản chụp, không bao giờ sửa trạng thái trận.
## Bảng thao tác: Story 1.4 và 1.5, tác giả chốt 2026-10-18.

const NONE: int = 0

var _board: BoardView = null
var _input: BattleInput = null
var _hud: Hud = null
var _controller: BattleController = null
## Id tướng đang chọn; NONE là không chọn.
var _selected: int = NONE
## Ô sáng của tướng đang chọn.
var _cells: Array[Vector2i] = []


func setup(board: BoardView, input: BattleInput, hud: Hud) -> void:
	_board = board
	_input = input
	_hud = hud
	input.general_key_pressed.connect(_on_general_key)
	input.cell_clicked.connect(_on_cell_clicked)
	input.cell_hovered.connect(_on_cell_hovered)
	input.undo_pressed.connect(_on_undo)
	input.end_turn_pressed.connect(_on_end_turn)
	hud.undo_pressed.connect(_on_undo)
	hud.end_turn_pressed.connect(_on_end_turn)


## Bắt đầu trận mới (kể cả nạp lại): bỏ chọn, hiện bảng nút.
func start(controller: BattleController) -> void:
	_controller = controller
	controller.events_resolved.connect(_on_events_resolved)
	_deselect()
	_update_hud()


## Màn hình lỗi, menu: không còn trận, mọi thao tác không làm gì, bảng nút ẩn.
func stop() -> void:
	_controller = null
	_deselect()
	_hud.visible = false


func selected_id() -> int:
	return _selected


func lit_cells() -> Array[Vector2i]:
	return _cells.duplicate()


## Phím 1-2-3: tướng không có trên bàn thì không gì; phím của tướng đang chọn thì bỏ chọn.
func _on_general_key(id: int) -> void:
	if _controller == null:
		return
	if id == _selected:
		_deselect()
		return
	var unit: Unit = _controller.snapshot().unit_by_id(id)
	if unit != null and unit.faction == Unit.Faction.DAI_VIET:
		_select(id)


func _on_cell_clicked(cell: Vector2i) -> void:
	if _controller == null:
		return
	var unit: Unit = _controller.snapshot().unit_at(cell) if cell != BoardView.NO_CELL else null
	if unit != null and unit.faction == Unit.Faction.DAI_VIET:
		# Bấm vào tướng mình luôn là chọn (GDD, chốt 2026-10-17); bấm lại tướng đang chọn thì bỏ chọn.
		if unit.id == _selected:
			_deselect()
		else:
			_select(unit.id)
		return
	if _selected != NONE and _cells.has(cell):
		# Đi xong vẫn chọn tướng đó (tác giả chốt); vẽ lại ở _on_events_resolved.
		_controller.submit(Command.move(_selected, cell))
		return
	_deselect()


## Hủy nước đi gần nhất; vẫn giữ tướng đang chọn (tác giả chốt). Không có gì để hủy thì không gì.
func _on_undo() -> void:
	if _controller == null:
		return
	_controller.undo()


## Kết thúc lượt rồi bỏ chọn (tác giả chốt).
func _on_end_turn() -> void:
	if _controller == null:
		return
	_controller.submit(Command.end_turn())
	_deselect()


## Sau mỗi lệnh chạy được và mỗi lần hủy: ô sáng, vòng chọn, đường đi của tướng đang chọn tính lại.
func _on_events_resolved(_events: Array[BattleEvent], snapshot: BattleState) -> void:
	if _controller == null:
		return
	if _selected != NONE:
		if snapshot.unit_by_id(_selected) != null:
			_select(_selected)
		else:
			_deselect()
	_update_hud()


func _on_cell_hovered(cell: Vector2i) -> void:
	if _controller == null or _selected == NONE or not _cells.has(cell):
		_board.show_path([])
		return
	_board.show_path(_controller.path_to(_selected, cell))


func _select(id: int) -> void:
	_selected = id
	_cells = _controller.reachable(id)
	_board.show_selection(_controller.snapshot().unit_by_id(id).cell, _cells)
	# Chuột có thể đang nằm sẵn trên một ô vừa sáng: vẽ đường đi ngay, không chờ rê sang ô khác.
	# Đồng quân vừa dời có thể che ô đang trỏ: chọn lại ô dưới chuột trước.
	_input.refresh_hover()
	_on_cell_hovered(_input.hovered_cell())


func _update_hud() -> void:
	_hud.show_turn(_controller.snapshot().round_number, _controller.can_undo())


func _deselect() -> void:
	_selected = NONE
	_cells = []
	if _board != null:
		_board.clear_selection()
