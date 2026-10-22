class_name BoardFixture
extends RefCounted
## Dựng BattleState từ bàn cờ chữ cho test luật đánh, đẩy (Story 2.1). Chỉ số tự đặt, không dựa vào
## data/chi_so.json (tác giả được sửa): Khoái 3 máu, 2 sát thương, đẩy 1; Bộ binh 3 máu; Kỵ binh 2; Cung kỵ 1.

## Cỡ bàn khi test không chỉ định (bàn 7×7 như trận 1).
const DEFAULT_SIZE: Vector2i = Vector2i(7, 7)


static func stats() -> Stats:
	var values: Dictionary = {}
	values[UnitType.NGUYEN_KHOAI] = {"mau": 3, "tam_di": 3, "sat_thuong": 2, "do_day": 1}
	values[UnitType.PHAM_NGU_LAO] = {"mau": 3, "tam_di": 3, "sat_thuong": 1, "tam_danh_gan": 2, "tam_danh_xa": 4}
	values[UnitType.TRAN_KHANH_DU] = {"mau": 3, "tam_di": 3, "tam_danh": 3, "tam_keo": 2}
	values[UnitType.BO_BINH] = {"mau": 3, "tam_di": 2, "sat_thuong": 1}
	values[UnitType.KY_BINH] = {"mau": 2, "tam_di": 3, "sat_thuong": 1}
	values[UnitType.CUNG_KY] = {"mau": 1, "tam_di": 3, "sat_thuong": 1, "tam_ban_gan": 2, "tam_ban_xa": 3}
	return Stats.new(values)


## Bàn trống cỡ size, ô (c, r) thay bằng ký hiệu.
static func rows(cells: Dictionary, size: Vector2i = DEFAULT_SIZE) -> Array[String]:
	var out: Array[String] = []
	for r: int in range(size.y):
		var row: PackedStringArray = PackedStringArray()
		row.resize(size.x)
		row.fill(".")
		for c: int in range(size.x):
			if cells.has(Vector2i(c, r)):
				row[c] = cells[Vector2i(c, r)] as String
		out.append(" ".join(row))
	return out


## Tướng theo ký hiệu (id 1, 2, 3), quân Nguyên theo thứ tự đọc bàn (id 101, 102…). hp: ô -> máu.
static func state(units: Dictionary, terrain: Dictionary = {}, hp: Dictionary = {},
		size: Vector2i = DEFAULT_SIZE) -> BattleState:
	var unit_rows: Array[String] = rows(units, size)
	var terrain_rows: Array[String] = rows(terrain, size)
	var level: LevelData = LevelData.new()
	level.size = size
	var generals: Array[LevelData.UnitPlacement] = []
	var enemies: Array[LevelData.UnitPlacement] = []
	for r: int in range(size.y):
		var terrain_row: PackedStringArray = BoardText.split_row(terrain_rows[r])
		var unit_row: PackedStringArray = BoardText.split_row(unit_rows[r])
		for c: int in range(size.x):
			level.terrain.append(BoardText.TERRAIN_SYMBOLS[terrain_row[c]] as int)
			var type: int = BoardText.UNIT_SYMBOLS[unit_row[c]] as int
			if type == BoardText.NO_UNIT:
				continue
			var cell: Vector2i = Vector2i(c, r)
			var placement: LevelData.UnitPlacement = LevelData.UnitPlacement.new(type, cell, hp.get(cell, 0) as int)
			if UnitType.is_general(type):
				generals.append(placement)
			else:
				enemies.append(placement)
	generals.sort_custom(func(a: LevelData.UnitPlacement, b: LevelData.UnitPlacement) -> bool: return a.type < b.type)
	level.units.append_array(generals)
	level.units.append_array(enemies)
	return BattleState.from_level(level, stats())


## "loại:id:..." của từng sự kiện, để so cả dãy trong một assert.
static func describe(events: Array[BattleEvent]) -> Array[String]:
	var out: Array[String] = []
	for e: BattleEvent in events:
		match e.type:
			BattleEvent.Type.MOVED:
				out.append("MOVED %d %s>%s %s" % [e.unit_id, BoardText.cell_text(e.from_cell),
					BoardText.cell_text(e.to_cell), BattleEvent.Cause.find_key(e.cause)])
			BattleEvent.Type.DAMAGED:
				out.append("DAMAGED %d -%d %s" % [e.unit_id, e.amount, BattleEvent.Cause.find_key(e.cause)])
			BattleEvent.Type.DIED:
				out.append("DIED %d %s" % [e.unit_id, BoardText.cell_text(e.from_cell)])
			BattleEvent.Type.COLLIDED:
				out.append("COLLIDED %d %d %s" % [e.unit_id, e.other_id, BoardText.cell_text(e.to_cell)])
			BattleEvent.Type.DROWNED:
				out.append("DROWNED %d %s" % [e.unit_id, BoardText.cell_text(e.to_cell)])
			BattleEvent.Type.ATTACKED:
				out.append("ATTACKED %d %s" % [e.unit_id, BoardText.cell_text(e.to_cell)])
			BattleEvent.Type.TELEGRAPHED:
				out.append("TELEGRAPHED %d %s>%s #%d" % [e.unit_id, BoardText.cell_text(e.from_cell),
					BoardText.cell_text(e.to_cell), e.amount])
			BattleEvent.Type.TELEGRAPH_CANCELLED:
				out.append("TELEGRAPH_CANCELLED %d %s #%d %s" % [e.unit_id, BoardText.cell_text(e.from_cell),
					e.amount, BattleEvent.TelegraphCancel.find_key(e.cancel)])
			BattleEvent.Type.REJECTED:
				out.append("REJECTED %s" % BattleEvent.Reject.find_key(e.reject))
			_:
				out.append(str(BattleEvent.Type.find_key(e.type)))
	return out


## "id@c,h:máu:đi:đánh" của mọi quân, để so state trước/sau.
static func picture(s: BattleState) -> Array[String]:
	var out: Array[String] = []
	for u: Unit in s.units:
		out.append("%d@%s:%d:%s:%s" % [u.id, BoardText.cell_text(u.cell), u.hp, u.has_moved, u.has_attacked])
	return out
