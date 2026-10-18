class_name Effects
extends RefCounted
## Nơi duy nhất được đổi vị trí, máu của quân và nhấc quân khỏi bàn. check_boundaries.sh chỉ miễn file này.


## Đặt quân vào ô kề to_cell và ghi sự kiện MOVED. Quân Nguyên vào sông thì chết đuối (tướng không bao giờ bị
## đưa vào sông: ForcedMove chặn trước, luật đi không cho). Hầm chông thêm ở Story 3.4.
static func move(state: BattleState, unit: Unit, to_cell: Vector2i, cause: BattleEvent.Cause,
		events: Array[BattleEvent]) -> void:
	var from_cell: Vector2i = unit.cell
	unit.cell = to_cell
	events.append(BattleEvent.moved(unit.id, from_cell, to_cell, cause))
	if unit.faction == Unit.Faction.NGUYEN and state.terrain_at(to_cell) == Terrain.RIVER:
		_remove(state, unit)
		events.append(BattleEvent.drowned(unit.id, to_cell))


## Trừ amount máu, ghi DAMAGED với số máu đã trừ thật (máu không xuống dưới 0). Hết máu thì nhấc khỏi bàn, ghi DIED
## (cả tướng lẫn quân Nguyên, kiến trúc "Gục, thắng, thua"). Kiểm thắng/thua: Story 2.5.
static func damage(state: BattleState, unit: Unit, amount: int, cause: BattleEvent.Cause,
		events: Array[BattleEvent]) -> void:
	var lost: int = mini(amount, unit.hp)
	unit.hp -= lost
	events.append(BattleEvent.damaged(unit.id, lost, cause))
	if not unit.is_alive():
		_remove(state, unit)
		events.append(BattleEvent.died(unit.id, unit.cell))


static func _remove(state: BattleState, unit: Unit) -> void:
	state.units.erase(unit)
