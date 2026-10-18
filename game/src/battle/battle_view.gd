class_name BattleView
extends Node
## Chọn tướng trên bàn cờ: nhận signal của BattleInput, hỏi BattleController ô đi được, nhờ BoardView vẽ.
## Chỉ đọc bản chụp, không bao giờ sửa trạng thái trận. Bảng chọn/bỏ chọn: Story 1.4, tác giả chốt 2026-10-18.

const NONE: int = 0

var _board: BoardView = null
var _controller: BattleController = null
## Id tướng đang chọn; NONE là không chọn.
var _selected: int = NONE
## Ô sáng của tướng đang chọn.
var _cells: Array[Vector2i] = []


func setup(board: BoardView, input: BattleInput) -> void:
	_board = board
	input.general_key_pressed.connect(_on_general_key)
	input.cell_clicked.connect(_on_cell_clicked)
	input.cell_hovered.connect(_on_cell_hovered)


## Bắt đầu trận mới (kể cả nạp lại): bỏ chọn.
func start(controller: BattleController) -> void:
	_controller = controller
	_deselect()


## Màn hình lỗi, menu: không còn trận, mọi thao tác không làm gì.
func stop() -> void:
	_controller = null
	_deselect()


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
	if _controller.snapshot().unit_by_id(id) != null:
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
		return  # đi: Story 1.5
	_deselect()


func _on_cell_hovered(cell: Vector2i) -> void:
	if _controller == null or _selected == NONE or not _cells.has(cell):
		_board.show_path([])
		return
	_board.show_path(_controller.path_to(_selected, cell))


func _select(id: int) -> void:
	_selected = id
	_cells = _controller.reachable(id)
	_board.show_selection(_controller.snapshot().unit_by_id(id).cell, _cells)


func _deselect() -> void:
	_selected = NONE
	_cells = []
	if _board != null:
		_board.clear_selection()
