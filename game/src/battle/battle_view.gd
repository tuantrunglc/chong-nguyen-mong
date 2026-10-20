class_name BattleView
extends Node
## Chọn tướng, đi, đánh, hủy, kết thúc lượt: nhận signal của BattleInput và Hud, gửi lệnh cho BattleController,
## nhờ BoardView vẽ ô sáng và viền mục tiêu. Chỉ đọc bản chụp, không bao giờ sửa trạng thái trận.
## Bảng thao tác: Story 1.4, 1.5, 2.1 ("Bấm chuột khi đang chọn tướng"), tác giả chốt 2026-10-18.

const NONE: int = 0

var _board: BoardView = null
var _input: BattleInput = null
var _hud: Hud = null
var _controller: BattleController = null
## Id tướng đang chọn; NONE là không chọn.
var _selected: int = NONE
## Ô sáng của tướng đang chọn.
var _cells: Array[Vector2i] = []
## Ô mục tiêu đánh được của tướng đang chọn.
var _targets: Array[Vector2i] = []
## Mục tiêu đang chờ bấm lần nữa (tướng đã đi thì phải xác nhận, FR15); NO_CELL là không chờ.
var _pending: Vector2i = BoardView.NO_CELL


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


func target_cells() -> Array[Vector2i]:
	return _targets.duplicate()


func pending_cell() -> Vector2i:
	return _pending


## Phím 1-2-3: tướng không có trên bàn hoặc đã đánh thì không gì; phím của tướng đang chọn thì bỏ chọn.
## Hết trận (thắng hoặc thua) thì mọi thao tác không làm gì (Story 2.5).
func _on_general_key(id: int) -> void:
	if _controller == null or _battle_over():
		return
	if id == _selected:
		_deselect()
		return
	var unit: Unit = _controller.snapshot().unit_by_id(id)
	if unit != null and unit.faction == Unit.Faction.DAI_VIET:
		if unit.has_attacked:
			_set_pending(BoardView.NO_CELL)  # như bấm chuột vào tướng đã đánh
		else:
			_select(unit.id)


func _on_cell_clicked(cell: Vector2i) -> void:
	if _controller == null or _battle_over():
		return
	var unit: Unit = _controller.snapshot().unit_at(cell) if cell != BoardView.NO_CELL else null
	if unit != null and unit.faction == Unit.Faction.DAI_VIET:
		# Bấm vào tướng mình luôn là chọn (GDD, chốt 2026-10-17); bấm lại tướng đang chọn thì bỏ chọn.
		# Tướng đã đánh không chọn được: chỉ bỏ chờ xác nhận, tướng đang chọn giữ nguyên (Story 2.3).
		if unit.id == _selected:
			_deselect()
		elif unit.has_attacked:
			_set_pending(BoardView.NO_CELL)
		else:
			_select(unit.id)
		return
	if _selected != NONE and _targets.has(cell):
		_on_target_clicked(cell)
		return
	if _selected != NONE and _cells.has(cell):
		# Đi xong vẫn chọn tướng đó (tác giả chốt); vẽ lại ở _on_events_resolved.
		_controller.submit(Command.move(_selected, cell))
		return
	_deselect()


## Tướng chưa đi: đánh ngay. Đã đi: bấm lần đầu chỉ chờ xác nhận, bấm lại đúng ô đó mới đánh (FR15).
func _on_target_clicked(cell: Vector2i) -> void:
	var unit: Unit = _controller.snapshot().unit_by_id(_selected)
	if unit.has_moved and _pending != cell:
		_set_pending(cell)
		return
	_set_pending(BoardView.NO_CELL)
	_controller.submit(Command.attack(_selected, cell))


func _set_pending(cell: Vector2i) -> void:
	_pending = cell
	_board.show_pending(cell)
	_hud.show_hint(tr("hud.confirm_attack") if cell != BoardView.NO_CELL else "")


## Hủy nước đi gần nhất; vẫn giữ tướng đang chọn (tác giả chốt). Không có gì để hủy thì không gì.
func _on_undo() -> void:
	if _controller == null or _battle_over():
		return
	_controller.undo()


## Kết thúc lượt rồi bỏ chọn (tác giả chốt).
func _on_end_turn() -> void:
	if _controller == null or _battle_over():
		return
	_controller.submit(Command.end_turn())
	_deselect()


## Sau mỗi lệnh chạy được và mỗi lần hủy: ô sáng, vòng chọn, đường đi của tướng đang chọn tính lại.
func _on_events_resolved(_events: Array[BattleEvent], snapshot: BattleState) -> void:
	if _controller == null:
		return
	if Rules.is_battle_over(snapshot):
		_deselect()
		_update_hud()
		return
	if _selected != NONE:
		var unit: Unit = snapshot.unit_by_id(_selected)
		# Đánh xong thì không còn gì để làm với tướng đó: bỏ chọn.
		if unit != null and not unit.has_attacked:
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
	_targets = _controller.attack_targets(id)
	_board.show_selection(_controller.snapshot().unit_by_id(id).cell, _cells, _targets)
	_set_pending(BoardView.NO_CELL)
	# Chuột có thể đang nằm sẵn trên một ô vừa sáng: vẽ đường đi ngay, không chờ rê sang ô khác.
	# Đồng quân vừa dời có thể che ô đang trỏ: chọn lại ô dưới chuột trước.
	_input.refresh_hover()
	_on_cell_hovered(_input.hovered_cell())


func _update_hud() -> void:
	var snapshot: BattleState = _controller.snapshot()
	_hud.show_turn(snapshot.round_number, _controller.can_undo(), Rules.is_battle_over(snapshot))


## Trận đã kết thúc (thắng hoặc thua).
func _battle_over() -> bool:
	return Rules.is_battle_over(_controller.snapshot())


func _deselect() -> void:
	_selected = NONE
	_cells = []
	_targets = []
	_pending = BoardView.NO_CELL
	if _board != null:
		_board.clear_selection()
	if _hud != null:
		_hud.show_hint("")
