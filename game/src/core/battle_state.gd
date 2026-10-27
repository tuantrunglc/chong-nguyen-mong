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
## Số hiệp tối đa (Story 3.5, chỉ trận Tiêu diệt); 0 là không giới hạn.
var max_rounds: int = 0
## Lòng dân hiện tại và tối đa (Story 3.7); 0 là không có làng.
var morale: int = 0
var max_morale: int = 0
## Chỉ đọc, dùng chung giữa các bản sao.
var stats: Stats = null
## Pha hiện tại. WON hoặc LOST là hết trận: Rules.resolve từ chối mọi lệnh (Story 2.5).
var phase: Phase = Phase.PLAYER
## Lý do thua trận ("" nếu thua thường vì hết tướng, "het_hiep" nếu hết hiệp, Story 3.5).
var defeat_reason: String = ""
## Kiểu nhiệm vụ của trận (chép từ file trận). Kịch bản luật không ghi kiểu nên là Tiêu diệt.
var mission: LevelData.Mission = LevelData.Mission.ELIMINATE
## Đòn quân Nguyên đã báo trong pha chuẩn bị của hiệp này (Story 2.6), theo số thứ tự.
var telegraphs: Array[Telegraph] = []
## Ý định của từng quân Nguyên trong pha chuẩn bị vừa rồi, theo thứ tự hành động (để F3 đọc từ bản chụp).
var enemy_intents: Array[EnemyIntent] = []
## Lịch quân tiếp viện còn lại theo hiệp (Story 3.10).
var reinforcements: Array[LevelData.Reinforcement] = []
## Các ô tiếp viện được cảnh báo cho hiệp sau (để UI vẽ ký hiệu riêng, Story 3.10).
var reinforcement_warnings: Array[Vector2i] = []
## Id kế tiếp cho quân Nguyên mới (Story 3.10).
var next_enemy_id: int = FIRST_ENEMY_ID
## Mưu kế mở trong trận và mưu kế đã dùng (Stratagem.Kind, Story 3.12). Chơi lại hiệp trả lại mưu kế vì bản chụp
## đầu lượt giữ danh sách đã dùng lúc đó.
var stratagems: Array[int] = []
var stratagems_used: Array[int] = []
## Sát Thát đang có hiệu lực trong lượt người chơi này (Story 3.13). RulesStratagem bật, RulesEnemyPhase tắt khi
## người chơi kết thúc lượt. Bản chụp đầu lượt luôn là false, nên chơi lại hiệp trả lại cả mưu kế lẫn cờ.
var sat_that_active: bool = false


## Tướng: id = vị trí trong UnitType.GENERALS + 1. Quân Nguyên: 101, 102… theo thứ tự level.units
## (tức thứ tự thu_tu_dich).
static func from_level(level: LevelData, p_stats: Stats) -> BattleState:
	var state: BattleState = BattleState.new()
	state.size = level.size
	state.terrain = level.terrain.duplicate()
	state.stats = p_stats
	state.mission = level.mission
	state.max_rounds = level.max_rounds
	state.max_morale = level.long_dan
	state.morale = level.long_dan_hien_tai if level.long_dan_hien_tai > 0 else level.long_dan
	var next_id: int = FIRST_ENEMY_ID
	for p: LevelData.UnitPlacement in level.units:
		var id: int
		if UnitType.is_general(p.type):
			id = UnitType.GENERALS.find(p.type) + 1
		else:
			id = next_id
			next_id += 1
		state.units.append(UnitFactory.create(id, p.type, p.cell, p_stats, p.hp))
	state.next_enemy_id = next_id
	state.stratagems = level.stratagems.duplicate()
	state.stratagems_used = level.stratagems_used.duplicate()
	for r: LevelData.Reinforcement in level.reinforcements:
		state.reinforcements.append(r.clone())
		if r.round == state.round_number + 1:
			state.reinforcement_warnings.append(r.cell)
	return state


func clone() -> BattleState:
	var copy: BattleState = BattleState.new()
	copy.size = size
	copy.terrain = terrain.duplicate()
	copy.stats = stats
	copy.round_number = round_number
	copy.max_rounds = max_rounds
	copy.morale = morale
	copy.max_morale = max_morale
	copy.phase = phase
	copy.defeat_reason = defeat_reason
	copy.mission = mission
	copy.next_enemy_id = next_enemy_id
	copy.reinforcement_warnings = reinforcement_warnings.duplicate()
	copy.stratagems = stratagems.duplicate()
	copy.stratagems_used = stratagems_used.duplicate()
	copy.sat_that_active = sat_that_active
	for r: LevelData.Reinforcement in reinforcements:
		copy.reinforcements.append(r.clone())
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
	if max_rounds < 0:
		problems.append("số hiệp tối đa %d, cần từ 0 trở lên" % max_rounds)
	if max_morale < 0:
		problems.append("Lòng dân tối đa %d, cần từ 0 trở lên" % max_morale)
	if morale < 0:
		problems.append("Lòng dân %d, cần từ 0 trở lên" % morale)
	if max_morale > 0 and morale > max_morale:
		problems.append("Lòng dân %d vượt tối đa %d" % [morale, max_morale])
	if terrain.has(Terrain.VILLAGE) and max_morale <= 0:
		problems.append("bàn có ô làng mà thiếu Lòng dân tối đa")
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
		if not reinforcements.is_empty():
			problems.append("đã thắng (Tiêu diệt) mà còn %d quân tiếp viện chưa xuất hiện" % reinforcements.size())
	for r: LevelData.Reinforcement in reinforcements:
		if r.round < 2:
			problems.append("tiếp viện hiệp %d, cần từ 2 trở lên" % r.round)
		if not in_bounds(r.cell):
			problems.append("tiếp viện ở ô %d,%d nằm ngoài bàn" % [r.cell.x, r.cell.y])
		elif not Terrain.is_walkable(terrain_at(r.cell)):
			problems.append("tiếp viện ở ô %d,%d là ô không đi vào được" % [r.cell.x, r.cell.y])
		if not UnitType.is_enemy(r.type):
			problems.append("tiếp viện loại quân %d không phải quân Nguyên" % r.type)
	var used_seen: Array[int] = []
	for kind: int in stratagems_used:
		if used_seen.has(kind):
			continue  # mỗi mưu kế báo một lần, dù bị ghi trùng mấy lần
		used_seen.append(kind)
		if not stratagems.has(kind):
			problems.append("mưu kế %s đã dùng mà không mở trong trận" % Stratagem.name_of(kind))
		if stratagems_used.count(kind) > 1:
			problems.append("mưu kế %s bị ghi đã dùng hai lần" % Stratagem.name_of(kind))
	if sat_that_active and not stratagems_used.has(Stratagem.Kind.SAT_THAT):
		problems.append("Sát Thát đang có hiệu lực mà chưa ghi đã dùng")
	for u: Unit in units:
		if u.faction == Unit.Faction.NGUYEN and u.id >= next_enemy_id:
			problems.append("quân Nguyên %d có id lớn hơn hoặc bằng next_enemy_id %d" % [u.id, next_enemy_id])
	return problems


## Sát thương cộng thêm cho đòn của tướng lúc này: tham số Sát Thát khi đang có hiệu lực, không thì 0 (kiến trúc M2).
func sat_that_bonus() -> int:
	return stats.strike_bonus(Stratagem.Kind.SAT_THAT) if sat_that_active else 0


## Hình dạng đòn đã báo; rỗng là hợp lệ. Chủ đòn đã gục vẫn hợp lệ (hủy đòn ở Story 2.9), nhưng phải từng là quân
## Nguyên: không có quân nào mang id đó thì chỉ kiểm hình dạng. `CELL` = một ô kề (Bộ binh) hoặc ô thẳng hàng 2–3
## (Cung kỵ, Story 2.15).
func _telegraph_shape_problem(t: Telegraph) -> String:
	var owner: Unit = unit_by_id(t.owner_id)
	if owner != null and owner.faction != Unit.Faction.NGUYEN:
		return "thuộc quân không phải quân Nguyên"
	match t.kind:
		Telegraph.Kind.DIRECTION:
			if not Grid.DIRECTIONS.has(t.offset):
				return "xung phong theo hướng %d,%d không hợp lệ" % [t.offset.x, t.offset.y]
		Telegraph.Kind.CELL:
			return _cell_telegraph_problem(t, owner)
	return ""


## Đòn vào ô (Story 2.15): Bộ binh đánh ô kề; Cung kỵ bắn ô thẳng hàng trong tầm `tam_ban_gan`–`tam_ban_xa`.
## Chủ đòn đã gục thì không biết loại quân: chỉ đòi offset thẳng hàng, dài từ 1 trở lên — không chặn trần, vì trần
## là số cân bằng (`tam_ban_xa`) và đòn của chủ đã gục sẽ bị hủy ở Story 2.9, không phải dữ liệu hỏng.
func _cell_telegraph_problem(t: Telegraph, owner: Unit) -> String:
	var straight: bool = t.offset.x == 0 or t.offset.y == 0
	var distance: int = Grid.distance(Vector2i.ZERO, t.offset)
	if owner != null and owner.type == UnitType.CUNG_KY:
		var near: int = stats.shoot_min_range(owner.type)
		var far: int = stats.shoot_max_range(owner.type)
		if not straight or distance < near or distance > far:
			return "đánh ô cách %d,%d, Cung kỵ chỉ bắn thẳng hàng %d–%d ô" % [t.offset.x, t.offset.y, near, far]
		return ""
	if owner == null:
		if straight and distance >= 1:
			return ""
		return "đánh ô cách %d,%d không hợp lệ (chủ đòn đã gục, phải thẳng hàng)" % [t.offset.x, t.offset.y]
	if distance == 1:
		return ""
	return "đánh ô cách %d,%d, cần đúng một ô kề" % [t.offset.x, t.offset.y]


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
