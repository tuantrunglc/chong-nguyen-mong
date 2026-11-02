class_name BoardView
extends Node2D
## Vẽ bàn cờ nhìn chếch từ trên xuống (ô vuông) bằng code, đặt giữa vùng trống bên trái HUD: ô, địa hình, đồng quân.
## Ô 0,0 ở góc trên trái; cột tăng thì sang phải, hàng tăng thì xuống dưới, giống bàn cờ chữ trong file trận.
## Vật nhô lên chỉ thấy mặt trên và mặt trước (phía người xem); vật ở hàng dưới che vật ở hàng trên.
## Nơi duy nhất đổi ô ↔ điểm: cell_center, cell_rect, cell_at (mặt đất) và pick_cell (thứ nhìn thấy dưới chuột).
## Gốc tọa độ local là góc trên trái của ô 0,0 trên mặt đất. Chỉ vẽ theo bản chụp (show_state); null thì về bàn trống.

## Cạnh ô (px), khớp tranh E8 64×64 hiện 1:1.
const TILE_SIZE: int = 64
## Đọc từ project.godot để chỉ có một nơi khai báo kích thước màn hình.
static var viewport_size: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width") as int,
	ProjectSettings.get_setting("display/window/size/viewport_height") as int
)
## Vùng trống cho bàn (tọa độ màn hình): dưới tiêu đề, trái bảng HUD, trên nhãn phiên bản.
const AREA: Rect2 = Rect2(16, 52, 948, 612)
const LINE_COLOR: Color = Color(0.36, 0.24, 0.14)
## Lưới ô mờ trên mặt đất bằng hình (Story 8.2), để vẫn đếm được ô khi tính đòn.
const GRID_COLOR: Color = Color(0.0, 0.0, 0.0, 0.25)
const GRID_WIDTH: float = 1.0
## Mép dưới của bàn (cạnh trước), màu đất tối để nối với nền rừng quanh bàn.
const EDGE_COLOR: Color = Color("4c3e24")
const BORDER_WIDTH: float = 4.0
## Ký hiệu cảnh báo ô tiếp viện hiệp sau (Story 3.10, FR35): viền cam vàng khác ô đỏ đòn địch.
const REINFORCEMENT_BORDER: Color = Color(1.0, 0.75, 0.2)
const REINFORCEMENT_FILL: Color = Color(0.95, 0.65, 0.15, 0.35)
## Độ dày mép bàn ở cạnh trước.
const EDGE_DEPTH: float = 12.0
const EDGE_SHADE: float = 0.4
## Rừng, kho lương, làng nhô lên; ô ải là bệ thấp, quân đứng lên được (tác giả chốt 2026-10-18).
const BLOCK_HEIGHT: float = 16.0
const PASS_HEIGHT: float = BLOCK_HEIGHT / 2.0
const BLOCK_KINDS: Array[int] = [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]
## Chừa thêm phía trên vật cao nhất ở hàng đầu (để tính khung bàn).
const TOP_MARGIN: float = 4.0

## Khóa dịch của chữ ngắn trên ô. Đất trống không có chữ.
const TERRAIN_KEYS: Dictionary = {
	Terrain.RIVER: "terrain.river",
	Terrain.FOREST: "terrain.forest",
	Terrain.SPIKES: "terrain.spikes",
	Terrain.GRANARY: "terrain.granary",
	Terrain.VILLAGE: "terrain.village",
	Terrain.PASS: "terrain.pass",
}
const TERRAIN_FONT_SIZE: int = 12
## Chữ ngắn trên ô địa hình (Sông, Rừng...). Tắt từ Story 8.2: hình đã đủ rõ, tooltip vẫn có tên. Đặt true để hiện lại.
const SHOW_TERRAIN_LABELS: bool = false
## Bệ ô ải bằng hình 64×64 gồm mặt đá và chân bệ; đặt nửa PASS_HEIGHT trên mặt đất để mặt đá khớp chỗ quân đứng.
const PASS_SPRITE_LIFT: float = PASS_HEIGHT / 2.0
## Ô ngoài bàn (cell_at).
const NO_CELL: Vector2i = Vector2i(-1, -1)
## Ô đi tới được: trắng ngả xanh dương có viền sáng, khác cỏ xanh lá, nước và đỏ của ô báo đòn (E2).
const REACH_COLOR: Color = Color(0.78, 0.90, 1.0, 0.50)
const REACH_BORDER_COLOR: Color = Color(1.0, 1.0, 1.0, 0.95)
const REACH_BORDER_WIDTH: float = 2.0
## Vùng có thể đi của quân Nguyên khi rê chuột lên nó: ô vàng cam viền sáng. Đang chọn tướng thì chỉ vẽ viền, không
## tô, để ô đi được của tướng vẫn rõ.
const ENEMY_REACH_COLOR: Color = Color(0.95, 0.65, 0.15, 0.28)
const ENEMY_REACH_BORDER_COLOR: Color = Color(1.0, 0.85, 0.35, 0.90)
const ENEMY_REACH_BORDER_WIDTH: float = 2.0
## Viền quanh ô mục tiêu đánh được (tác giả chốt 2026-10-18: trắng), chỉ viền, không tô: ô đỏ báo đòn E2 tô kín.
## Ô chờ xác nhận (tướng đã đi, bấm lần đầu) viền dày gấp đôi.
const TARGET_COLOR: Color = Color(1.0, 1.0, 1.0)
const TARGET_WIDTH: float = 3.0
const PENDING_WIDTH: float = 6.0
## Viền thụt vào trong ô (px) để không chồng lên nét lưới.
const TARGET_INSET: float = 5.0
## Vòng elip trên mặt đất quanh chân tướng đang chọn; nằm gọn trong ô.
const SELECT_COLOR: Color = Color(0.95, 0.72, 0.10)
const SELECT_RADIUS: Vector2 = Vector2(28, 18)
const SELECT_WIDTH: float = 4.0
const SELECT_POINTS: int = 40
## Đường đi khi rê chuột lên ô sáng.
const PATH_COLOR: Color = Color(0.13, 0.35, 0.65)
const PATH_WIDTH: float = 6.0
const PATH_END_RADIUS: Vector2 = Vector2(8, 6)

## Cỡ bàn trống khi chưa có trận (màn hình lỗi, test). Có trận thì theo state.size (Story 1.9).
const EMPTY_SIZE: Vector2i = Vector2i(7, 7)

var cols: int = EMPTY_SIZE.x
var rows: int = EMPTY_SIZE.y

## Bản chụp đang vẽ; null là bàn trống.
var _state: BattleState = null
## Nền rừng quanh bàn và mặt đất bằng hình, vẽ trước (dưới) phần vẽ của chính BoardView (Story 8.2).
var _backdrop: BackdropView
var _ground: GroundView
## Chữ của ô phẳng (sông, hầm chông, ô ải), nằm dưới đồng quân.
var _terrain_labels: Node2D
## Khối địa hình và đồng quân, sắp theo y (tức theo hang): vật ở hàng dưới, gần người xem, vẽ sau.
var _world: Node2D
## Viền mục tiêu, vẽ trên đồng quân để thấy đủ 4 cạnh (tác giả chốt 2026-10-20, review 1.8).
var _target_layer: Node2D
## Ô đỏ báo đòn (dưới đồng quân) và lớp số thứ tự của nó (trên cùng, trừ F1) (Story 2.7).
var _telegraph: TelegraphView
## Nhãn số máu mất do hầm chông trên ô sáng (Story 3.4).
var _damage_labels: Node2D
var _preview: PreviewView
var _fx: FxLayer
## id quân -> UnitToken
var _tokens: Dictionary = {}
## Tướng đang chọn: ô của nó (NO_CELL là không chọn), các ô sáng, đường đi đang vẽ (không gồm ô tướng).
var _selected_cell: Vector2i = NO_CELL
var _lit_cells: Array[Vector2i] = []
## Ô mục tiêu đánh được của tướng đang chọn, và ô đang chờ xác nhận (NO_CELL là không có).
var _target_cells: Array[Vector2i] = []
var _pending_cell: Vector2i = NO_CELL
var _path: Array[Vector2i] = []
## Vùng di chuyển của quân địch đang trỏ chuột.
var _enemy_reach_cells: Array[Vector2i] = []


## Tâm ô trên mặt đất, tính trong tọa độ của BoardView (gốc là góc trên trái của ô 0,0).
static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * TILE_SIZE, (cell.y + 0.5) * TILE_SIZE)


## Ô vuông trên mặt đất.
static func cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell * TILE_SIZE), Vector2(TILE_SIZE, TILE_SIZE))


## Tâm mặt trên của ô loại kind: nơi đồng quân đứng (ô ải cao hơn mặt đất).
static func top_center(cell: Vector2i, kind: int) -> Vector2:
	return cell_center(cell) - Vector2(0, surface_height(kind))


## Mặt trên của loại ô cao hơn mặt đất bao nhiêu (0 là phẳng).
static func surface_height(kind: int) -> float:
	if BLOCK_KINDS.has(kind):
		return BLOCK_HEIGHT
	if kind == Terrain.PASS:
		return PASS_HEIGHT
	return 0.0


## Vẽ khối nhô lên height từ ô ground trên mặt đất, lên canvas: mặt trên là ground nâng lên height, mặt trước là
## dải cao height ở cạnh dưới ground, tối hơn front_shade. Nhìn chếch từ phía người xem nên không thấy mặt bên.
## Chỉ gọi trong _draw của canvas đó.
static func draw_raised(canvas: CanvasItem, ground: Rect2, height: float, color: Color, front_shade: float) -> void:
	var top: Rect2 = Rect2(ground.position - Vector2(0, height), ground.size)
	var front: Rect2 = Rect2(top.position.x, top.end.y, ground.size.x, height)
	canvas.draw_rect(front, color.darkened(front_shade))
	canvas.draw_rect(top, color)
	canvas.draw_rect(front, LINE_COLOR, false, 1.5)
	canvas.draw_rect(top, LINE_COLOR, false, 1.5)


## Ô chứa điểm local_pos trên mặt đất (tọa độ của BoardView); ngoài bàn thì NO_CELL.
## cell_at(cell_center(c)) == c.
func cell_at(local_pos: Vector2) -> Vector2i:
	# floori, không dùng int(): int(-0.5) là 0, điểm ngay bên trái hay ngay trên bàn sẽ rơi nhầm vào ô.
	var cell: Vector2i = Vector2i(floori(local_pos.x / TILE_SIZE), floori(local_pos.y / TILE_SIZE))
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		return NO_CELL
	return cell


## Ô người chơi nhìn thấy dưới chuột: đồng quân và khối nhô lên che ô phía sau, nên trúng chúng thì lấy ô
## của chúng (vật gần người xem nhất, tức hàng lớn nhất, thắng); không trúng gì thì là ô mặt đất (cell_at).
func pick_cell(local_pos: Vector2) -> Vector2i:
	var best: Vector2i = NO_CELL
	var best_depth: int = -1
	for token: UnitToken in _tokens.values():
		if token.hit(local_pos - token.position) and token.cell.y > best_depth:
			best = token.cell
			best_depth = token.cell.y
	if _state != null:
		for r: int in range(rows):
			for c: int in range(cols):
				var cell: Vector2i = Vector2i(c, r)
				var height: float = surface_height(_state.terrain_at(cell))
				if height == 0.0 or r <= best_depth:
					continue
				if _silhouette(cell, height).has_point(local_pos):
					best = cell
					best_depth = r
	return best if best != NO_CELL else cell_at(local_pos)


## Khung chữ nhật bao trọn bàn (cả mép bàn, khối và đồng quân nhô lên), trong tọa độ của cha.
func board_rect() -> Rect2:
	return transform * _local_rect()


## Vẽ vòng quanh tướng ở unit_cell và tô sáng cells. Xóa đường đi cũ.
## cell_penalties: ô -> số máu sẽ mất do hầm chông trên đường đi (Story 3.4).
func show_selection(unit_cell: Vector2i, cells: Array[Vector2i], targets: Array[Vector2i] = [],
		cell_penalties: Dictionary = {}) -> void:
	_selected_cell = unit_cell
	_lit_cells = cells.duplicate()
	_target_cells = targets.duplicate()
	_pending_cell = NO_CELL
	_path = []
	_clear_damage_labels()
	if _damage_labels != null:
		for cell: Variant in cell_penalties.keys():
			var dmg: int = cell_penalties[cell] as int
			if dmg > 0 and cell is Vector2i:
				var label: Label = Label.new()
				label.set_meta("cell", cell as Vector2i)
				label.text = tr("board.damage_penalty") % dmg
				label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
				label.add_theme_font_size_override("font_size", 14)
				label.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				label.size = Vector2(30, 20)
				label.position = _top_center(cell as Vector2i) - label.size / 2.0
				_damage_labels.add_child(label)
	_redraw()


## Đường đi từ tướng đang chọn qua path (không gồm ô tướng). [] là xóa.
func show_path(path: Array[Vector2i]) -> void:
	if path == _path:
		return
	_path = path.duplicate()
	_redraw()


## Ô mục tiêu đang chờ bấm lần nữa để đánh; NO_CELL là bỏ chờ.
func show_pending(cell: Vector2i) -> void:
	if cell == _pending_cell:
		return
	_pending_cell = cell
	_redraw()


func clear_selection() -> void:
	_selected_cell = NO_CELL
	_lit_cells = []
	_target_cells = []
	_pending_cell = NO_CELL
	_path = []
	_clear_damage_labels()
	_redraw()


func _clear_damage_labels() -> void:
	if _damage_labels != null:
		for child: Node in _damage_labels.get_children():
			_damage_labels.remove_child(child)
			child.queue_free()


func lit_cells() -> Array[Vector2i]:
	return _lit_cells.duplicate()


func show_enemy_reach(cells: Array[Vector2i]) -> void:
	_enemy_reach_cells = cells.duplicate()
	_redraw()


func clear_enemy_reach() -> void:
	if _enemy_reach_cells.is_empty():
		return
	_enemy_reach_cells = []
	_redraw()


func enemy_reach_cells() -> Array[Vector2i]:
	return _enemy_reach_cells.duplicate()


## Vùng đi của quân Nguyên có tô nền không: chỉ khi chưa chọn tướng nào.
func enemy_reach_filled() -> bool:
	return _selected_cell == NO_CELL


func target_cells() -> Array[Vector2i]:
	return _target_cells.duplicate()


func pending_cell() -> Vector2i:
	return _pending_cell


## Nhãn trừ máu hầm chông trên các ô sáng (để test): ô -> chữ ("−1", "−2"...).
func damage_label_texts() -> Dictionary:
	var out: Dictionary = {}
	if _damage_labels == null:
		return out
	for child: Node in _damage_labels.get_children():
		var label: Label = child as Label
		if label != null and label.has_meta("cell"):
			out[label.get_meta("cell") as Vector2i] = label.text
	return out


func path() -> Array[Vector2i]:
	return _path.duplicate()


## Hệ số thu khung bàn board_size cho vừa area_size: 1 / k với k nguyên dương nhỏ nhất còn vừa (thu theo bậc
## nguyên để tranh pixel không nhòe, không bao giờ thu lẻ). Ở 1280×720 mọi cỡ bàn hợp lệ đều ra 1.
static func fit_scale(board_size: Vector2, area_size: Vector2) -> float:
	var k: int = maxi(1, ceili(maxf(board_size.x / area_size.x, board_size.y / area_size.y)))
	return 1.0 / k


## Tâm căn giữa của bàn cờ trên màn hình: trục ngang và trục dọc đúng giữa vùng sa bàn tác chiến (bên trái HUD).
static func board_center() -> Vector2:
	return AREA.get_center()


## Canh bàn cols × rows giữa vùng sa bàn AREA (bên trái HUD), thu theo bậc nguyên nếu không vừa; góc bàn rơi đúng điểm ảnh nguyên.
func setup(new_cols: int = EMPTY_SIZE.x, new_rows: int = EMPTY_SIZE.y) -> void:
	cols = new_cols
	rows = new_rows
	var local: Rect2 = _local_rect()
	var factor: float = fit_scale(local.size, AREA.size)
	scale = Vector2(factor, factor)
	position = (board_center() - local.get_center() * factor).round()
	if _ground != null and _backdrop != null:
		_ground.setup(cols, rows)
		_backdrop.queue_redraw()
	_redraw()


func _ready() -> void:
	# Thứ tự con: ô đỏ báo đòn, chữ ô phẳng, khối và đồng quân, viền mục tiêu, số thứ tự đòn. Overlay F1 do
	# main.gd thêm vào sau cùng. Ô đỏ đứng trước chữ ô phẳng để chữ địa hình vẫn đọc được.
	# Hai con đầu tiên vẽ trước BoardView._draw (show_behind_parent): nền rừng, rồi mặt đất.
	_backdrop = BackdropView.new()
	add_child(_backdrop)
	_ground = GroundView.new()
	add_child(_ground)
	_telegraph = TelegraphView.new()
	add_child(_telegraph)
	_terrain_labels = Node2D.new()
	add_child(_terrain_labels)
	_world = Node2D.new()
	_world.y_sort_enabled = true
	add_child(_world)
	# Hiệu ứng (Story 8.4): trên đồng quân, dưới bóng xem trước, viền mục tiêu và số thứ tự đòn.
	_fx = FxLayer.new()
	add_child(_fx)
	# Bóng mờ xem trước đòn (Story 2.12): trên đồng quân, dưới viền mục tiêu và lớp số thứ tự đòn.
	_preview = PreviewView.new()
	add_child(_preview)
	_target_layer = Node2D.new()
	_target_layer.draw.connect(_draw_targets)
	add_child(_target_layer)
	_damage_labels = Node2D.new()
	add_child(_damage_labels)
	add_child(_telegraph.numbers)
	setup(cols, rows)


func show_state(state: BattleState) -> void:
	_state = state
	if state != null:
		setup(state.size.x, state.size.y)
	else:
		clear_selection()
	# Bàn đổi thì bóng xem trước của lệnh cũ không còn nghĩa; hiệu ứng đang bay cũng vậy.
	_preview.clear()
	if _fx != null:
		_fx.clear()
	if _ground != null:
		_ground.show_state(state)
	_rebuild_terrain()
	_sync_tokens()
	_telegraph.show_state(state)
	_redraw()


## Lớp hiệu ứng (Story 8.4) cho EventPlayer và test.
func fx_layer() -> FxLayer:
	return _fx


## Ô đỏ báo đòn đang vẽ.
func telegraph_view() -> TelegraphView:
	return _telegraph


## Bóng mờ xem trước đòn (Story 2.12).
func preview_view() -> PreviewView:
	return _preview


## Đồng quân đang hiện, theo id.
func tokens() -> Dictionary:
	return _tokens


## Khung bàn trong tọa độ của BoardView (cả nửa nét viền bàn).
## Phía trên: đầu đồng quân đứng trên bệ ô ải ở hàng 0, hoặc mặt trên khối nhô lên, cái nào cao hơn.
func _local_rect() -> Rect2:
	var stroke: float = BORDER_WIDTH / 2.0
	var left: float = -stroke
	var right: float = cols * TILE_SIZE + stroke
	var bottom: float = rows * TILE_SIZE + EDGE_DEPTH + stroke
	var token_top: float = PASS_HEIGHT + UnitToken.TOKEN_LIFT + UnitToken.RADIUS - TILE_SIZE / 2.0
	var top: float = maxf(token_top, BLOCK_HEIGHT) + TOP_MARGIN
	return Rect2(left, -top, right - left, bottom + top)


## Mặt trên của ô (ô ải cao hơn mặt đất).
func _surface(cell: Vector2i) -> float:
	return 0.0 if _state == null else surface_height(_state.terrain_at(cell))


## Tâm mặt trên của ô: nơi đồng quân đứng, nơi vẽ ô sáng và đường đi.
func _top_center(cell: Vector2i) -> Vector2:
	return cell_center(cell) - Vector2(0, _surface(cell))


## Hình bao của khối nhô lên height ở cell (mặt trên nâng lên và mặt trước).
func _silhouette(cell: Vector2i, height: float) -> Rect2:
	var ground: Rect2 = cell_rect(cell)
	return Rect2(ground.position - Vector2(0, height), ground.size + Vector2(0, height))


## Dựng lại chữ ô phẳng và khối nhô lên theo bản chụp.
func _rebuild_terrain() -> void:
	for child: Node in _terrain_labels.get_children():
		_terrain_labels.remove_child(child)
		child.queue_free()
	for child: Node in _world.get_children():
		if child is TerrainBlock:
			_world.remove_child(child)
			child.queue_free()
	if _state == null:
		return
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			var kind: int = _state.terrain_at(cell)
			if not TERRAIN_KEYS.has(kind):
				continue
			var text: String = tr(TERRAIN_KEYS[kind] as String)
			if BLOCK_KINDS.has(kind):
				var block: TerrainBlock = TerrainBlock.new()
				block.setup(cell, kind, BLOCK_HEIGHT, text)
				_world.add_child(block)
				continue
			# Ô phẳng: chữ ở phần dưới ô, không bị đồng quân đứng giữa ô che hết.
			if not SHOW_TERRAIN_LABELS:
				continue
			var label: Label = Label.new()
			label.text = text
			label.add_theme_font_size_override("font_size", TERRAIN_FONT_SIZE)
			label.add_theme_color_override("font_color", LINE_COLOR)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size = Vector2(TILE_SIZE, TERRAIN_FONT_SIZE * 1.5)
			label.position = _top_center(cell) + Vector2(0, TILE_SIZE / 4.0) - label.size / 2.0
			_terrain_labels.add_child(label)


## Thêm đồng cho quân mới, bỏ đồng của quân không còn, cập nhật đồng còn lại.
## Id cũ mà đổi loại quân (nạp lại trận đã sửa) thì dựng lại đồng: tên và màu phe chỉ đặt lúc setup.
func _sync_tokens() -> void:
	var alive: Dictionary = {}
	if _state != null:
		for unit: Unit in _state.units:
			alive[unit.id] = true
			var lift: float = _surface(unit.cell)
			if _tokens.has(unit.id):
				var old: UnitToken = _tokens[unit.id] as UnitToken
				if old.unit_type == unit.type:
					old.update(unit, lift)
					old.set_facing(UnitArt.facing_for(unit, _state))
					old.set_aura(_has_aura(unit))
					continue
				_remove_token(unit.id)
			var token: UnitToken = UnitToken.new()
			token.setup(unit, lift)
			token.set_facing(UnitArt.facing_for(unit, _state))
			token.set_aura(_has_aura(unit))
			_world.add_child(token)
			_tokens[unit.id] = token
	for id: int in _tokens.keys():
		if not alive.has(id):
			_remove_token(id)


## Hào quang Sát Thát: tướng Đại Việt còn sống khi mưu kế đang có hiệu lực (theo bản chụp).
func _has_aura(unit: Unit) -> bool:
	return _state != null and _state.sat_that_active and unit.faction == Unit.Faction.DAI_VIET


func _remove_token(id: int) -> void:
	var token: UnitToken = _tokens[id] as UnitToken
	_world.remove_child(token)
	token.queue_free()
	_tokens.erase(id)


## Thêm một đồng quân mới khi tiếp viện xuất hiện (Story 3.10).
func add_reinforcement_token(p_id: int, p_type: int, at_cell: Vector2i, p_hp: int) -> UnitToken:
	if _tokens.has(p_id):
		return _tokens[p_id] as UnitToken
	var u: Unit = Unit.new(p_id, p_type, at_cell, p_hp)
	var lift: float = _surface(at_cell)
	var token: UnitToken = UnitToken.new()
	token.setup(u, lift)
	token.set_facing(UnitArt.facing_for(u, _state))
	_world.add_child(token)
	_tokens[p_id] = token
	return token


func _draw() -> void:
	var surface: Rect2 = Rect2(0, 0, cols * TILE_SIZE, rows * TILE_SIZE)
	# Khung sa bàn gỗ lim dát đồng bao quanh bàn cờ (Story 8.2).
	_draw_board_frame(cols, rows)
	for c: int in range(1, cols):
		draw_line(Vector2(c * TILE_SIZE, 0), Vector2(c * TILE_SIZE, surface.end.y), GRID_COLOR, GRID_WIDTH, true)
	for r: int in range(1, rows):
		draw_line(Vector2(0, r * TILE_SIZE), Vector2(surface.end.x, r * TILE_SIZE), GRID_COLOR, GRID_WIDTH, true)
	draw_rect(surface, LINE_COLOR, false, BORDER_WIDTH)
	# Bệ ô ải, ô sáng và vòng chọn vẽ trên mặt đất, từng hàng từ trên xuống (quân đứng lên bệ được,
	# xem BLOCK_KINDS): bệ ô ải ở hàng dưới che ô sáng ở hàng trên, ô sáng trên bệ nằm trên mặt bệ.
	for r: int in range(rows):
		for c: int in range(cols):
			var cell: Vector2i = Vector2i(c, r)
			if _state != null and _state.terrain_at(cell) == Terrain.PASS:
				draw_texture(Art.tex(GroundArt.pass_path(cell, _state)), cell_rect(cell).position - Vector2(0, PASS_SPRITE_LIFT))
			if _lit_cells.has(cell):
				draw_rect(_top_rect(cell), REACH_COLOR)
				draw_rect(_top_rect(cell).grow(-REACH_BORDER_WIDTH / 2.0), REACH_BORDER_COLOR, false, REACH_BORDER_WIDTH)
			if _enemy_reach_cells.has(cell):
				if enemy_reach_filled():
					draw_rect(_top_rect(cell), ENEMY_REACH_COLOR)
				draw_rect(_top_rect(cell).grow(-ENEMY_REACH_BORDER_WIDTH / 2.0), ENEMY_REACH_BORDER_COLOR, false, ENEMY_REACH_BORDER_WIDTH)
			if cell == _selected_cell:
				draw_polyline(_ellipse(_top_center(cell), SELECT_RADIUS), SELECT_COLOR, SELECT_WIDTH, true)
	if _state != null and not _state.reinforcement_warnings.is_empty():
		for cell: Vector2i in _state.reinforcement_warnings:
			_draw_reinforcement_marker(cell)
	if _selected_cell != NO_CELL and not _path.is_empty():
		var points: PackedVector2Array = PackedVector2Array([_top_center(_selected_cell)])
		for cell: Vector2i in _path:
			points.append(_top_center(cell))
		draw_polyline(points, PATH_COLOR, PATH_WIDTH, true)
		# Bỏ điểm cuối trùng điểm đầu: đa giác không nhận điểm lặp.
		draw_colored_polygon(_ellipse(_top_center(_path[_path.size() - 1]), PATH_END_RADIUS).slice(0, SELECT_POINTS), PATH_COLOR)


## Khung sa bàn gỗ lim dát đồng bao quanh bàn cờ (Story 8.2).
func _draw_board_frame(p_cols: int, p_rows: int) -> void:
	var tile: int = TILE_SIZE
	var top_tex: Texture2D = Art.tex("dia_hinh/tex_khung_canh_tren_64x16.png")
	var bot_tex: Texture2D = Art.tex("dia_hinh/tex_khung_canh_duoi_64x16.png")
	var left_tex: Texture2D = Art.tex("dia_hinh/tex_khung_canh_trai_16x64.png")
	var right_tex: Texture2D = Art.tex("dia_hinh/tex_khung_canh_phai_16x64.png")
	var tl_tex: Texture2D = Art.tex("dia_hinh/tex_khung_goc_tren_trai_32x32.png")
	var tr_tex: Texture2D = Art.tex("dia_hinh/tex_khung_goc_tren_phai_32x32.png")
	var bl_tex: Texture2D = Art.tex("dia_hinh/tex_khung_goc_duoi_trai_32x32.png")
	var br_tex: Texture2D = Art.tex("dia_hinh/tex_khung_goc_duoi_phai_32x32.png")
	var w: float = float(p_cols * tile)
	var h: float = float(p_rows * tile)
	for c: int in range(p_cols):
		draw_texture(top_tex, Vector2(c * tile, -16.0))
		draw_texture(bot_tex, Vector2(c * tile, h))
	for r: int in range(p_rows):
		draw_texture(left_tex, Vector2(-16.0, r * tile))
		draw_texture(right_tex, Vector2(w, r * tile))
	draw_texture(tl_tex, Vector2(-16.0, -16.0))
	draw_texture(tr_tex, Vector2(w - 16.0, -16.0))
	draw_texture(bl_tex, Vector2(-16.0, h - 16.0))
	draw_texture(br_tex, Vector2(w - 16.0, h - 16.0))


## Mặt trên của ô (ô ải nâng lên theo bệ).
func _top_rect(cell: Vector2i) -> Rect2:
	var ground: Rect2 = cell_rect(cell)
	return Rect2(ground.position - Vector2(0, _surface(cell)), ground.size)


## Vẽ lại mặt đất và lớp viền mục tiêu.
func _redraw() -> void:
	queue_redraw()
	if _target_layer != null:
		_target_layer.queue_redraw()


## Khung vuông quanh mỗi mục tiêu, thụt vào trong mặt trên ô, không tô; ô chờ xác nhận viền dày hơn.
## Vẽ lên _target_layer (trên đồng quân), cùng tọa độ với BoardView.
func _draw_targets() -> void:
	for cell: Vector2i in _target_cells:
		var width: float = PENDING_WIDTH if cell == _pending_cell else TARGET_WIDTH
		_target_layer.draw_rect(_top_rect(cell).grow(-TARGET_INSET), TARGET_COLOR, false, width)


## Ký hiệu đánh dấu ô tiếp viện hiệp sau (Story 3.10): nền vàng cam mờ, viền nổi và chevron hướng xuống.
func _draw_reinforcement_marker(cell: Vector2i) -> void:
	var rect: Rect2 = _top_rect(cell).grow(-3.0)
	draw_rect(rect, REINFORCEMENT_FILL, true)
	draw_rect(rect, REINFORCEMENT_BORDER, false, 3.0)
	# Dấu cờ thay cho mũi tên; nền và viền cam giữ nguyên để phân biệt với ô đỏ báo đòn (FR35).
	var flag: Texture2D = Art.tex(FxArt.DAU_TIEP_VIEN)
	draw_texture(flag, _top_center(cell) - flag.get_size() / 2.0)


## Elip khép kín (vòng chọn, chấm cuối đường đi) nằm trên mặt ô nhìn chếch.
func _ellipse(center: Vector2, radius: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(SELECT_POINTS + 1):
		var angle: float = TAU * i / SELECT_POINTS
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	return points
