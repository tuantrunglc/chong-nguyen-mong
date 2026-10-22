class_name BattleView
extends Node
## Chọn tướng, đi, đánh, hủy, kết thúc lượt: nhận signal của BattleInput và Hud, gửi lệnh cho BattleController,
## nhờ BoardView vẽ ô sáng và viền mục tiêu. Chỉ đọc bản chụp, không bao giờ sửa trạng thái trận.
## Bảng thao tác: Story 1.4, 1.5, 2.1 ("Bấm chuột khi đang chọn tướng"), tác giả chốt 2026-10-18.

const NONE: int = 0

## Phát xong hoạt ảnh của một lệnh (hoặc không có gì để phát): bàn đã sẵn sàng vẽ bản chụp cuối.
## `main.gd` vẽ bàn ở đây để hoạt ảnh chạy trên bàn cũ (Story 2.11).
signal playback_finished(snapshot: BattleState)

var _board: BoardView = null
var _input: BattleInput = null
var _hud: Hud = null
## Khung thông tin khi rê chuột (Story 2.10); null thì không hiện gì.
var _tooltip: Tooltip = null
var _controller: BattleController = null
## Id tướng đang chọn; NONE là không chọn.
var _selected: int = NONE
## Ô sáng của tướng đang chọn.
var _cells: Array[Vector2i] = []
## Ô mục tiêu đánh được của tướng đang chọn.
var _targets: Array[Vector2i] = []
## Mục tiêu đang chờ bấm lần nữa (tướng đã đi thì phải xác nhận, FR15); NO_CELL là không chờ.
var _pending: Vector2i = BoardView.NO_CELL
## Phát lại sự kiện bằng Tween (Story 2.11); con của view này, không giữ trạng thái trận.
var _player: EventPlayer = null
## Đang phát hoạt ảnh: mọi lệnh mới đều bị bỏ qua (AC 3).
var _playing: bool = false
## Lệnh đang phát là pha của quân Nguyên (end_turn hoặc mở trận): dòng pha trên HUD.
var _enemy_turn: bool = false
## Lệnh vừa gửi là lệnh mở pha địch; `_on_events_resolved` tiêu thụ nó. Lệnh bị từ chối (không phát signal)
## thì cờ này không được rò sang lượt phát sau.
var _pending_enemy_turn: bool = false
## Tăng mỗi lần start()/stop(): lượt phát của trận cũ không được vẽ lên trận mới (F5 giữa lúc phát).
var _playback_generation: int = 0
## Ô đang được xem trước kết quả đòn; NO_CELL là chưa tính (Story 2.12, AC 4).
var _preview_cell: Vector2i = BoardView.NO_CELL
## Số lần đã tính xem trước (để test AC 4: rê trong cùng ô không tính lại).
var _preview_count: int = 0


func setup(board: BoardView, input: BattleInput, hud: Hud, tooltip: Tooltip = null) -> void:
	_board = board
	_input = input
	_hud = hud
	_tooltip = tooltip
	_player = EventPlayer.new()
	_player.setup(board)
	add_child(_player)
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
	_playback_generation += 1
	if _player != null:
		_player.stop()
	_playing = false
	_enemy_turn = false
	_pending_enemy_turn = false
	_preview_cell = BoardView.NO_CELL
	_hud.set_locked(false)
	_deselect()
	_update_hud()


## Màn hình lỗi, menu: không còn trận, mọi thao tác không làm gì, bảng nút ẩn.
func stop() -> void:
	_controller = null
	_playback_generation += 1
	_playing = false
	_enemy_turn = false
	if _player != null:
		_player.stop()
	_deselect()
	_hide_info()
	_hud.visible = false


func selected_id() -> int:
	return _selected


func lit_cells() -> Array[Vector2i]:
	return _cells.duplicate()


func target_cells() -> Array[Vector2i]:
	return _targets.duplicate()


func pending_cell() -> Vector2i:
	return _pending


## Mở trận: pha địch chuẩn bị của hiệp 1 cũng là một lần phát hoạt ảnh (Story 2.6, 2.11).
## `main.gd` gọi hàm này thay cho `controller.begin()` để view biết đó là pha địch.
func begin_battle() -> void:
	if _controller == null:
		return
	_pending_enemy_turn = true
	_controller.begin()
	_pending_enemy_turn = false


## Đang phát hoạt ảnh (để test).
func is_playing() -> bool:
	return _playing


## Số lần đã tính bản xem trước (để test AC 4).
func preview_computations() -> int:
	return _preview_count


## Phát lại sự kiện của lệnh này (để test).
func event_player() -> EventPlayer:
	return _player


## Phím 1-2-3: tướng không có trên bàn hoặc đã đánh thì không gì; phím của tướng đang chọn thì bỏ chọn.
## Hết trận (thắng hoặc thua) thì mọi thao tác không làm gì (Story 2.5).
func _on_general_key(id: int) -> void:
	if _controller == null or _playing or _battle_over():
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
	if _controller == null or _playing or _battle_over():
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
	if _controller == null or _playing or _battle_over():
		return
	_controller.undo()


## Kết thúc lượt rồi bỏ chọn (tác giả chốt).
func _on_end_turn() -> void:
	if _controller == null or _playing or _battle_over():
		return
	_pending_enemy_turn = true
	_controller.submit(Command.end_turn())
	# Lệnh bị từ chối thì không có lượt phát nào tiêu thụ cờ: bỏ đi để lượt sau không báo sai pha.
	_pending_enemy_turn = false
	_deselect()


## Mỗi lệnh chạy được: khóa lệnh, phát hoạt ảnh theo nhật ký, rồi mới vẽ bàn và tính lại ô sáng (Story 2.11).
func _on_events_resolved(events: Array[BattleEvent], snapshot: BattleState) -> void:
	if _controller == null:
		return
	_playing = true
	# Bóng xem trước là kết quả của lệnh vừa bấm: phải biến mất trước khi hoạt ảnh chạy trên bàn cũ (Story 2.12).
	_clear_preview()
	_enemy_turn = _pending_enemy_turn
	_pending_enemy_turn = false
	# Không gọi `_update_hud()` ở đây: bản chụp đã là trạng thái SAU lệnh, vẽ số hiệp mới giữa lúc phát sẽ
	# nói dối ("Hiệp 2" khi quân Nguyên còn đang đi). HUD cập nhật một lần khi phát xong.
	_hud.set_locked(true)
	_hud.show_phase(_enemy_turn)
	var generation: int = _playback_generation
	# Chế độ không màn hình (test) hoặc không có gì để phát: làm ngay trong cùng khung hình, không await.
	if _player.instant or events.is_empty():
		_player.play_now(events, snapshot)
		_finish_playback(snapshot, generation)
		return
	await _player.play(events, snapshot)
	_finish_playback(snapshot, generation)


## Phát xong: mở khóa, để `main.gd` vẽ bản chụp cuối, rồi tính lại chọn/ô sáng/khung thông tin trên bàn mới.
func _finish_playback(snapshot: BattleState, generation: int) -> void:
	# Trận đã bị dừng hoặc thay bằng trận khác giữa lúc phát (màn hình lỗi, menu, F5): không được đụng vào
	# cờ khóa của trận đang chạy, cũng không vẽ bản chụp cũ.
	if _controller == null or generation != _playback_generation:
		return
	_playing = false
	_enemy_turn = false
	_hud.set_locked(false)
	playback_finished.emit(snapshot)
	if Rules.is_battle_over(snapshot):
		_deselect()
		_update_hud()
		_update_info(_input.hovered_cell() if _input != null else BoardView.NO_CELL)
		return
	if _selected != NONE:
		var unit: Unit = snapshot.unit_by_id(_selected)
		# Đánh xong thì không còn gì để làm với tướng đó: bỏ chọn.
		if unit != null and not unit.has_attacked:
			_select(_selected)
		else:
			_deselect()
	_update_hud()
	# Bàn đã đổi (đòn dịch theo, đòn bị hủy): chọn lại ô dưới chuột rồi tính lại khung và nổi bật, vì đồng quân
	# vừa dời có thể đã che ô đang trỏ (Story 2.10 review). Không xoá `_preview_cell` ở đây: `_select`/`_deselect`
	# ngay trên đã reset nó và tính lại bóng rồi; xoá thêm sẽ bắt tính lại đúng ô đó lần thứ hai (Story 2.12 review).
	if _input != null:
		_input.refresh_hover()
	var hovered: Vector2i = _input.hovered_cell() if _input != null else BoardView.NO_CELL
	_update_info(hovered)
	_update_preview(hovered)

func _on_cell_hovered(cell: Vector2i) -> void:
	# Đang phát thì khung thông tin đứng yên: bản chụp đã là trạng thái sau lệnh, đọc nó lúc này sẽ tả ô mà
	# người chơi chưa thấy quân tới. Phát xong `_finish_playback` cập nhật lại theo ô đang trỏ.
	if _playing:
		return
	_update_info(cell)
	_update_preview(cell)
	if _controller == null or _selected == NONE or not _cells.has(cell):
		_board.show_path([])
		return
	_board.show_path(_controller.path_to(_selected, cell))


## Bóng mờ kết quả đòn khi rê lên mục tiêu đánh được (Story 2.12). Chỉ tính lại khi ĐỔI ô (AC 4); đang phát
## hoạt ảnh thì không tính, vì bản chụp đã là trạng thái sau lệnh.
func _update_preview(cell: Vector2i) -> void:
	if _board == null:
		return
	if _playing or _controller == null or _selected == NONE or not _targets.has(cell):
		_clear_preview()
		return
	if cell == _preview_cell:
		return
	_preview_cell = cell
	var before: BattleState = _controller.snapshot()
	var result: Dictionary = _controller.preview_result(Command.attack(_selected, cell))
	if result.is_empty():
		# Lệnh không chạy được: không nhớ ô này, để lần trỏ sau còn tính lại (trạng thái có thể vừa đổi).
		_preview_cell = BoardView.NO_CELL
		_board.preview_view().clear()
		return
	_preview_count += 1
	_board.preview_view().show_ghosts(
		_ghosts_of(before, result["state"] as BattleState, result["events"] as Array[BattleEvent]))


func _clear_preview() -> void:
	_preview_cell = BoardView.NO_CELL
	if _board != null:
		_board.preview_view().clear()


## Chênh lệch hai bản chụp thành danh sách bóng: quân đổi ô hoặc mất máu hiện ở vị trí cuối với máu sau đòn;
## quân biến mất hiện ở ô cũ với máu 0 (Story 2.12).
func _ghosts_of(before: BattleState, after: BattleState, events: Array[BattleEvent]) -> Array[Dictionary]:
	var ghosts: Array[Dictionary] = []
	# Ô cuối của từng quân trong lệnh này. `Effects.move` phát MOVED trước rồi mới tới DROWNED, nên MOVED đã phủ
	# cả ca chết đuối; không cần nhánh riêng cho DROWNED.
	var last_cell: Dictionary = {}
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.MOVED:
			last_cell[event.unit_id] = event.to_cell
	for unit: Unit in after.units:
		var old: Unit = before.unit_by_id(unit.id)
		if old == null:
			continue
		if old.cell == unit.cell and old.hp == unit.hp:
			continue
		ghosts.append(_ghost(unit.cell, unit, after, -1, old.cell != unit.cell))
	for unit: Unit in before.units:
		if after.unit_by_id(unit.id) == null:
			# Quân biến mất: đặt bóng ở ô cuối cùng nó tới trong lệnh (chết đuối sau khi bị đẩy), không phải ô đầu.
			var cell: Vector2i = last_cell.get(unit.id, unit.cell) as Vector2i
			ghosts.append(_ghost(cell, unit, before, 0, cell != unit.cell))
	return ghosts


func _ghost(cell: Vector2i, unit: Unit, state: BattleState, hp: int = -1, moved: bool = true) -> Dictionary:
	var lift: float = BoardView.surface_height(state.terrain_at(cell))
	return {
		"cell": cell,
		"pos": BoardView.cell_center(cell) - Vector2(0.0, lift),
		"type": unit.type,
		"hp": unit.hp if hp < 0 else hp,
		"faction": unit.faction,
		"moved": moved,
	}


## Khung thông tin và ô đỏ nổi bật theo ô đang trỏ (Story 2.10). Chỉ đọc bản chụp.
func _update_info(cell: Vector2i) -> void:
	if _controller == null or _board == null:
		return
	var state: BattleState = _controller.snapshot()
	if state == null:
		return
	# Hết trận thì không còn gì để xem: bảng Thắng/Thua là thứ duy nhất còn trên bàn (Story 2.10, Task 3.3).
	if Rules.is_battle_over(state):
		_hide_info()
		return
	if not state.in_bounds(cell):
		_hide_info()
		return
	var unit: Unit = state.unit_at(cell)
	if _tooltip != null:
		_tooltip.show_text(_unit_text(unit, state) if unit != null else _terrain_text(state.terrain_at(cell)))
	_board.telegraph_view().highlight(_telegraph_cells_of(unit, state))


func _unit_text(unit: Unit, state: BattleState) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(tr(Tooltip.UNIT_NAMES[unit.type] as String))
	lines.append(tr("tooltip.hp") % [unit.hp, state.stats.max_hp(unit.type)])
	lines.append(_attack_text(unit, state))
	return "\n".join(lines)


## Chữ "đòn sắp đánh" của quân này. Đòn đã bị hủy (chủ đòn gục, ô đích ngoài bàn, Kỵ binh sát mép hướng ra
## ngoài) thì `TelegraphMarks.hit_cell` trả `NO_CELL` và đường đỏ cũng rỗng, nên phải kiểm trước khi hứa đòn:
## nếu không, khung nói "Xung phong hướng Bắc" trong khi bàn không còn ô đỏ nào (Story 2.10 review).
func _attack_text(unit: Unit, state: BattleState) -> String:
	for t: Telegraph in state.telegraphs:
		if t.owner_id != unit.id:
			continue
		var hit: Vector2i = TelegraphMarks.hit_cell(state, t)
		if hit == Telegraph.NO_CELL:
			return tr("tooltip.no_attack")
		if t.kind == Telegraph.Kind.DIRECTION:
			return tr("tooltip.attack_charge") % [tr(Tooltip.DIRECTION_NAMES[t.offset] as String), t.order]
		return tr("tooltip.attack_cell") % [BoardText.cell_text(hit), t.order]
	return tr("tooltip.no_attack")


func _terrain_text(terrain: int) -> String:
	return "%s\n%s" % [tr(Tooltip.TERRAIN_NAMES[terrain] as String),
		tr(Tooltip.TERRAIN_EFFECTS[terrain] as String)]


func _telegraph_cells_of(unit: Unit, state: BattleState) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if unit == null:
		return cells
	for t: Telegraph in state.telegraphs:
		if t.owner_id == unit.id:
			cells.append_array(TelegraphMarks.path_cells(state, t))
	return cells


## Ẩn khung thông tin và bỏ nổi bật ô đỏ (hết trận, dừng trận).
func _hide_info() -> void:
	_clear_preview()
	if _tooltip != null:
		_tooltip.hide_tooltip()
	if _board != null:
		_board.telegraph_view().highlight([] as Array[Vector2i])


func _select(id: int) -> void:
	# Đổi tướng thì kết quả đòn khác: bóng của tướng trước không được giữ lại (Story 2.12 review).
	_preview_cell = BoardView.NO_CELL
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
	var over: bool = Rules.is_battle_over(snapshot)
	_hud.show_turn(snapshot.round_number, _controller.can_undo(), over)
	# Dòng pha luôn có khi đang chơi; lúc phát hoạt ảnh pha địch thì báo đúng pha đang chạy (Story 2.11, AC 4).
	if not over:
		_hud.show_phase(_playing and _enemy_turn)


## Trận đã kết thúc (thắng hoặc thua).
func _battle_over() -> bool:
	return Rules.is_battle_over(_controller.snapshot())


func _deselect() -> void:
	_clear_preview()
	_selected = NONE
	_cells = []
	_targets = []
	_pending = BoardView.NO_CELL
	if _board != null:
		_board.clear_selection()
	if _hud != null:
		_hud.show_hint("")
