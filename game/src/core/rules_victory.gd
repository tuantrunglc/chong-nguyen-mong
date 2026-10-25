class_name RulesVictory
extends RefCounted
## Kết cục của trận (FR36, FR38): thắng khi hết quân Nguyên (Tiêu diệt), thua khi mọi tướng trên bàn đã gục.
## Chỉ nơi này (và rules_enemy_phase.gd) được đổi BattleState.phase sang WON hoặc LOST.
## Điều kiện thắng/thua thêm ở story của nó: số hiệp tối đa (3.5), Lòng dân (3.7), Giữ ải (3.11): thêm hàm điều
## kiện nhỏ như _enemies_cleared, _generals_lost, không sửa khung check().


## Gọi sau mỗi lệnh (Rules.resolve) và, từ Story 2.8, sau từng đòn địch. events là các sự kiện vừa sinh ra: chỉ
## khi có quân gục (DIED, hoặc DROWNED vì chết đuối không có DIED) hoặc làng bị hại (VILLAGE_DAMAGED, Story 3.7)
## mới kiểm, nên bàn không có quân Nguyên từ đầu không bị thắng ngay. Thắng được ưu tiên: hết quân Nguyên và
## hết tướng/mất làng cùng lúc thì chỉ thắng.
## Trận đã hết thì không làm gì (không sinh kết cục lần hai).
static func check(state: BattleState, events: Array[BattleEvent]) -> void:
	if state.phase == BattleState.Phase.WON or state.phase == BattleState.Phase.LOST:
		return
	if not _someone_fell(events) and not _village_damaged(events) and not _enemy_entered_pass(state, events):
		return
	if _enemy_entered_pass(state, events):
		state.phase = BattleState.Phase.LOST
		state.defeat_reason = "quan_nguyen_vao_ai"
		events.append(BattleEvent.defeat("quan_nguyen_vao_ai"))
		return
	if _enemies_cleared(state):
		state.phase = BattleState.Phase.WON
		events.append(BattleEvent.victory())
	elif _generals_lost(state):
		state.phase = BattleState.Phase.LOST
		events.append(BattleEvent.defeat())
	elif _morale_lost(state):
		state.phase = BattleState.Phase.LOST
		state.defeat_reason = "mat_lang"
		events.append(BattleEvent.defeat("mat_lang"))


## Kiểm tra hết hiệp ở bước 4 (cuối hiệp) (Story 3.5, 3.11).
## Tiêu diệt: thua nếu hết hiệp mà còn quân Nguyên.
## Giữ ải: thắng nếu qua hết bước cuối hiệp của hiệp tối đa (mặc định 5).
static func check_round_limit(state: BattleState, events: Array[BattleEvent]) -> bool:
	if state.phase == BattleState.Phase.WON or state.phase == BattleState.Phase.LOST:
		return false
	if state.mission == LevelData.Mission.ELIMINATE and state.max_rounds > 0 and state.round_number >= state.max_rounds:
		if _count(state, Unit.Faction.NGUYEN) > 0 or not state.reinforcements.is_empty():
			state.phase = BattleState.Phase.LOST
			state.defeat_reason = "het_hiep"
			events.append(BattleEvent.defeat("het_hiep"))
			return true
	elif state.mission == LevelData.Mission.HOLD_PASS and state.max_rounds > 0 and state.round_number >= state.max_rounds:
		state.phase = BattleState.Phase.WON
		events.append(BattleEvent.victory())
		return true
	return false


## Quân Nguyên vào ô ải bằng bất kỳ cách nào (FR37, Story 3.11).
static func _enemy_entered_pass(state: BattleState, events: Array[BattleEvent]) -> bool:
	if state.mission != LevelData.Mission.HOLD_PASS:
		return false
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.MOVED:
			if state.in_bounds(event.to_cell) and state.terrain_at(event.to_cell) == Terrain.PASS:
				if event.unit_id >= BattleState.FIRST_ENEMY_ID:
					return true
				var u: Unit = state.unit_by_id(event.unit_id)
				if u != null and u.faction == Unit.Faction.NGUYEN:
					return true
	return false


static func _someone_fell(events: Array[BattleEvent]) -> bool:
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.DIED or event.type == BattleEvent.Type.DROWNED:
			return true
	return false


static func _village_damaged(events: Array[BattleEvent]) -> bool:
	for event: BattleEvent in events:
		if event.type == BattleEvent.Type.VILLAGE_DAMAGED:
			return true
	return false


## Mất hết Lòng dân (Story 3.7). Chỉ áp dụng cho trận có làng (max_morale > 0).
static func _morale_lost(state: BattleState) -> bool:
	return state.max_morale > 0 and state.morale <= 0


## Tiêu diệt: không còn quân Nguyên trên bàn và không còn quân tiếp viện chưa xuất hiện (Story 3.10).
## Giữ ải thắng theo luật khác (Story 3.11), nên không thắng ở đây.
static func _enemies_cleared(state: BattleState) -> bool:
	return state.mission == LevelData.Mission.ELIMINATE and _count(state, Unit.Faction.NGUYEN) == 0 and state.reinforcements.is_empty()


## Mọi tướng trên bàn đã gục. Số tướng do file trận quy định, nên đếm quân còn lại, không viết cứng số tướng.
static func _generals_lost(state: BattleState) -> bool:
	return _count(state, Unit.Faction.DAI_VIET) == 0


static func _count(state: BattleState, faction: Unit.Faction) -> int:
	var count: int = 0
	for unit: Unit in state.units:
		if unit.faction == faction:
			count += 1
	return count
