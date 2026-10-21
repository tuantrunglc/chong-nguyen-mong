class_name BattleState
extends RefCounted
## Trạng thái trận, thuần dữ liệu. Chỉ BattleController giữ bản đang sống; nơi khác nhận clone().
## Thêm thuộc tính mới thì nhớ thêm vào clone().

## Id quân Nguyên đầu tiên; tướng lấy id theo ký hiệu 1, 2, 3.
const FIRST_ENEMY_ID: int = 101

## Pha trận (kiến trúc "Mẫu trạng thái"). ENEMY_PREPARE chỉ có trong lúc RulesEnemyPhase.prepare chạy (Story 2.6);
## ENEMY_ACT, END_OF_ROUND để Story 2.8 dùng. Chỉ rules_enemy_phase.gd và rules_victory.gd được đổi pha.
enum Phase { ENEMY_PREPARE, PLAYER, ENEMY_ACT, END_OF_ROUND, WON, LOST }

var size: Vector2i = Vector2i.ZERO
## Theo hàng: index = hang * size.x + cot (như LevelData).
var terrain: PackedInt32Array = PackedInt32Array()
var units: Array[Unit] = []
## Hiệp hiện tại (cả 4 pha), bắt đầu từ 1.
var round_number: int = 1
## Chỉ đọc, dùng chung giữa các bản sao.
var stats: Stats = null
## Pha hiện tại. WON hoặc LOST là hết trận: Rules.resolve từ chối mọi lệnh (Story 2.5).
var phase: Phase = Phase.PLAYER
## Kiểu nhiệm vụ của trận (chép từ file trận). Kịch bản luật không ghi kiểu nên là Tiêu diệt.
var mission: LevelData.Mission = LevelData.Mission.ELIMINATE
## Đòn quân Nguyên đã báo trong pha chuẩn bị của hiệp này (Story 2.6), theo số thứ tự.
var telegraphs: Array[Telegraph] = []
## Ý định của từng quân Nguyên trong pha chuẩn bị vừa rồi, theo thứ tự hành động (để F3 đọc từ bản chụp).
var enemy_intents: Array[EnemyIntent] = []


## Tướng: id = vị trí trong UnitType.GENERALS + 1. Quân Nguyên: 101, 102… theo thứ tự level.units
## (tức thứ tự thu_tu_dich).
static func from_level(level: LevelData, p_stats: Stats) -> BattleState:
	var state: BattleState = BattleState.new()
	state.size = level.size
	state.terrain = level.terrain.duplicate()
	state.stats = p_stats
	state.mission = level.mission
	var next_enemy_id: int = FIRST_ENEMY_ID
	for p: LevelData.UnitPlacement in level.units:
		var id: int
		if UnitType.is_general(p.type):
			id = UnitType.GENERALS.find(p.type) + 1
		else:
			id = next_enemy_id
			next_enemy_id += 1
		state.units.append(UnitFactory.create(id, p.type, p.cell, p_stats, p.hp))
	return state


func clone() -> BattleState:
	var copy: BattleState = BattleState.new()
	copy.size = size
	copy.terrain = terrain.duplicate()
	copy.stats = stats
	copy.round_number = round_number
	copy.phase = phase
	copy.mission = mission
	for u: Unit in units:
		copy.units.append(Unit.new(u.id, u.type, u.cell, u.hp, u.has_moved, u.has_attacked))
	for t: Telegraph in telegraphs:
		copy.telegraphs.append(t.clone())
	for intent: EnemyIntent in enemy_intents:
		copy.enemy_intents.append(intent.clone())
	return copy


## Bất biến của trạng thái. Rỗng là đúng; mỗi câu là một chỗ sai.
func validate() -> Array[String]:
	var problems: Array[String] = []
	var seen_ids: Dictionary = {}
	var by_cell: Dictionary = {}  # ô -> id quân đứng đó trước
	if round_number < 1:
		problems.append("hiệp %d, cần từ 1 trở lên" % round_number)
	for u: Unit in units:
		var where: String = "quân %d ở ô %d,%d" % [u.id, u.cell.x, u.cell.y]
		if seen_ids.has(u.id):
			problems.append("%s trùng id với quân khác" % where)
		seen_ids[u.id] = true
		if not in_bounds(u.cell):
			problems.append("%s nằm ngoài bàn" % where)
			continue
		if by_cell.has(u.cell):
			problems.append("%s đứng chung ô với quân %d" % [where, by_cell[u.cell]])
		else:
			by_cell[u.cell] = u.id
		if not Terrain.is_walkable(terrain_at(u.cell)):
			problems.append("%s đứng trên ô không đi vào được" % where)
		var max_hp: int = stats.max_hp(u.type)
		if u.hp < 1 or u.hp > max_hp:
			problems.append("%s có máu %d, cần từ 1 tới %d" % [where, u.hp, max_hp])
	var orders: Dictionary = {}
	for t: Telegraph in telegraphs:
		var shape: String = _telegraph_shape_problem(t)
		if not shape.is_empty():
			problems.append("đòn của quân %d %s" % [t.owner_id, shape])
		if t.order < 1:
			problems.append("đòn của quân %d có số thứ tự %d, cần từ 1 trở lên" % [t.owner_id, t.order])
		elif orders.has(t.order):
			problems.append("đòn số %d bị trùng (quân %d và quân %d)" % [t.order, orders[t.order], t.owner_id])
		else:
			orders[t.order] = t.owner_id
	if phase == Phase.WON and mission == LevelData.Mission.ELIMINATE:
		for u: Unit in units:
			if u.faction == Unit.Faction.NGUYEN:
				problems.append("đã thắng (Tiêu diệt) mà còn quân Nguyên %d" % u.id)
	return problems


## Hình dạng đòn đã báo; rỗng là hợp lệ. Chủ đòn đã gục vẫn hợp lệ (hủy đòn ở Story 2.9), nhưng phải từng là quân
## Nguyên: không có quân nào mang id đó thì chỉ kiểm hình dạng.
func _telegraph_shape_problem(t: Telegraph) -> String:
	var owner: Unit = unit_by_id(t.owner_id)
	if owner != null and owner.faction != Unit.Faction.NGUYEN:
		return "thuộc quân không phải quân Nguyên"
	match t.kind:
		Telegraph.Kind.DIRECTION:
			if not Grid.DIRECTIONS.has(t.offset):
				return "xung phong theo hướng %d,%d không hợp lệ" % [t.offset.x, t.offset.y]
		Telegraph.Kind.CELL:
			if absi(t.offset.x) + absi(t.offset.y) != 1:
				return "đánh ô cách %d,%d, cần đúng một ô kề" % [t.offset.x, t.offset.y]
	return ""


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


## Chỉ gọi với ô trong bàn (in_bounds).
func terrain_at(cell: Vector2i) -> int:
	return terrain[cell.y * size.x + cell.x]


func unit_at(cell: Vector2i) -> Unit:
	for u: Unit in units:
		if u.cell == cell:
			return u
	return null


func unit_by_id(id: int) -> Unit:
	for u: Unit in units:
		if u.id == id:
			return u
	return null
