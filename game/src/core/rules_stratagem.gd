class_name RulesStratagem
extends RefCounted
## Mưu kế của Trần Hưng Đạo (Story 3.12, FR33–FR34). Mỗi mưu kế dùng 1 lần mỗi trận, chỉ khi file trận mở nó; không
## tốn hành động của tướng. Lệnh này xóa bản chụp hủy (BattleController), như đánh.


static func resolve(state: BattleState, command: Command, events: Array[BattleEvent]) -> void:
	var kind: int = command.stratagem
	if not state.stratagems.has(kind):
		events.append(BattleEvent.rejected(BattleEvent.Reject.STRATAGEM_LOCKED,
			"trận này không mở mưu kế %s" % Stratagem.name_of(kind)))
		return
	if state.stratagems_used.has(kind):
		events.append(BattleEvent.rejected(BattleEvent.Reject.STRATAGEM_USED,
			"mưu kế %s đã dùng trong trận" % Stratagem.name_of(kind)))
		return
	state.stratagems_used.append(kind)
	events.append(BattleEvent.stratagem_used(kind))
	match kind:
		Stratagem.Kind.VUON_KHONG_NHA_TRONG:
			_scorched_earth(state, events)


## Vườn không nhà trống (kiến trúc, bảng phân giải "Mưu kế"): mọi ô kho lương thành đất trống (theo thứ tự đọc bàn),
## rồi mọi quân Nguyên mất máu theo thứ tự hành động: id tăng dần = thu_tu_dich, rồi tiếp viện theo thứ tự xuất hiện.
## Hết kho lương thì cuối hiệp không ai hồi máu nữa (FR33 "từ đó đến hết trận, quân Nguyên không hồi máu").
static func _scorched_earth(state: BattleState, events: Array[BattleEvent]) -> void:
	for r: int in range(state.size.y):
		for c: int in range(state.size.x):
			var cell: Vector2i = Vector2i(c, r)
			if state.terrain_at(cell) == Terrain.GRANARY:
				Effects.burn_granary(state, cell, events)
	# Bản sao: Effects.damage nhấc quân gục khỏi state.units.
	var enemies: Array[Unit] = []
	for unit: Unit in state.units:
		if unit.faction == Unit.Faction.NGUYEN:
			enemies.append(unit)
	enemies.sort_custom(func(a: Unit, b: Unit) -> bool: return a.id < b.id)
	var amount: int = state.stats.stratagem_damage(Stratagem.Kind.VUON_KHONG_NHA_TRONG)
	for enemy: Unit in enemies:
		Effects.damage(state, enemy, amount, BattleEvent.Cause.STRATAGEM, events)
