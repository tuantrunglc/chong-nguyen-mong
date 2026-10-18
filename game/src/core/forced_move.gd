class_name ForcedMove
extends RefCounted
## Di chuyển cưỡng bức (đẩy, kéo) đi từng ô một (kiến trúc M2, "Bảng thứ tự phân giải"). Mọi đòn đẩy, kéo dùng
## chung hàm này; máu và ô chỉ đổi qua Effects.

## Va mép bàn, vật cản, quân khác thì mất 1 máu: luật cố định của GDD, tác giả chốt 2026-10-18 không đưa vào
## chi_so.json. Sát Thát không cộng vào số này.
const COLLISION_DAMAGE: int = 1
## Vật cản không có máu: va vào thì dừng, chỉ quân bị đẩy mất máu. Làng: Lòng dân −1 thêm ở Story 3.7.
const OBSTACLES: Array[int] = [Terrain.FOREST, Terrain.GRANARY, Terrain.VILLAGE]


## Đẩy unit tối đa distance ô theo dir. Dừng khi va, khi chết đuối hoặc khi đã gục.
static func run(state: BattleState, unit: Unit, dir: Vector2i, distance: int, cause: BattleEvent.Cause,
		events: Array[BattleEvent]) -> void:
	for i: int in range(distance):
		if not unit.is_alive() or not state.units.has(unit):
			return
		var next: Vector2i = unit.cell + dir
		if not state.in_bounds(next):
			_hit_obstacle(state, unit, next, events)
			return
		var terrain: int = state.terrain_at(next)
		if OBSTACLES.has(terrain):
			_hit_obstacle(state, unit, next, events)
			return
		var other: Unit = state.unit_at(next)
		if other != null:
			events.append(BattleEvent.collided(unit.id, other.id, next))
			Effects.damage(state, unit, COLLISION_DAMAGE, BattleEvent.Cause.COLLISION, events)
			Effects.damage(state, other, COLLISION_DAMAGE, BattleEvent.Cause.COLLISION, events)
			return
		if terrain == Terrain.RIVER and unit.faction == Unit.Faction.DAI_VIET:
			_hit_obstacle(state, unit, next, events)
			return
		Effects.move(state, unit, next, cause, events)


## Mép bàn, vật cản, tướng vào sông: đứng yên, mất máu.
static func _hit_obstacle(state: BattleState, unit: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
	events.append(BattleEvent.collided(unit.id, 0, cell))
	Effects.damage(state, unit, COLLISION_DAMAGE, BattleEvent.Cause.COLLISION, events)
