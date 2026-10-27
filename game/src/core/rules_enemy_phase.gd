class_name RulesEnemyPhase
extends RefCounted
## Pha địch: từ lúc người chơi kết thúc lượt tới đầu lượt người chơi của hiệp sau, và pha chuẩn bị của hiệp 1 lúc mở
## trận. Story 1.5: sang hiệp mới, tướng đi và đánh lại được. Story 2.6: pha chuẩn bị (quân Nguyên đi rồi báo đòn).
## Story 2.8: ra các đòn đã báo trước khi sang hiệp. Cuối hiệp (kho lương, báo tiếp viện, 3.9–3.10) chèn sau ra đòn;
## tiếp viện xuất hiện chèn vào đầu prepare (3.10). Chỉ file này và rules_victory.gd được đổi phase.


## Ra đòn, rồi sang hiệp mới và chuẩn bị. Trận hết giữa lúc ra đòn thì dừng: không sang hiệp, không chuẩn bị.
static func end_player_turn(state: BattleState, events: Array[BattleEvent]) -> void:
	_strike_all(state, events)
	if Rules.is_battle_over(state):
		return
	_end_of_round(state, events)
	if Rules.is_battle_over(state):
		return
	state.round_number += 1
	for unit: Unit in state.units:
		unit.has_moved = false
		unit.has_attacked = false
	events.append(BattleEvent.round_started(state.round_number))
	prepare(state, events)


## Ra các đòn đã báo theo số thứ tự (state.telegraphs đã xếp). Ô trúng tính lúc đòn ra, theo bàn sau các đòn trước
## (TelegraphMarks.hit_cell, cùng chỗ tính ô đỏ). NO_CELL (chủ đã gục, ô đích ngoài bàn, Kỵ binh sát mép hướng ra
## ngoài) thì đòn không ra và phát TELEGRAPH_CANCELLED kèm lý do (Story 2.9). Quân ở ô trúng, bất kỳ phe, mất máu
## theo sát thương của chủ đòn; không đẩy, chủ đòn không đi. Kiểm thắng/thua sau từng đòn; trận hết thì dừng ngay.
static func _strike_all(state: BattleState, events: Array[BattleEvent]) -> void:
	state.phase = BattleState.Phase.ENEMY_ACT
	for telegraph: Telegraph in state.telegraphs:
		var hit: Vector2i = TelegraphMarks.hit_cell(state, telegraph)
		if hit == Telegraph.NO_CELL:
			var reason: BattleEvent.TelegraphCancel = TelegraphMarks.cancel_reason(state, telegraph)
			if reason != BattleEvent.TelegraphCancel.NONE:
				var owner_now: Unit = state.unit_by_id(telegraph.owner_id)
				var owner_cell: Vector2i = Telegraph.NO_CELL if owner_now == null else owner_now.cell
				events.append(BattleEvent.telegraph_cancelled(telegraph.owner_id, owner_cell, telegraph.order, reason))
			continue
		var owner: Unit = state.unit_by_id(telegraph.owner_id)
		var strike: Array[BattleEvent] = [BattleEvent.enemy_attacked(owner.id, owner.cell, hit)]
		if state.in_bounds(hit) and state.terrain_at(hit) == Terrain.VILLAGE:
			Effects.damage_morale(state, 1, hit, BattleEvent.Cause.ENEMY_STRIKE, strike)
		else:
			var victim: Unit = state.unit_at(hit)
			if victim != null:
				Effects.damage(state, victim, state.stats.damage(owner.type), BattleEvent.Cause.ENEMY_STRIKE, strike)
		# Kiểm trên sự kiện của riêng đòn này rồi mới nối, để VICTORY/DEFEAT là sự kiện cuối của lệnh.
		RulesVictory.check(state, strike)
		events.append_array(strike)
		if Rules.is_battle_over(state):
			return


## Pha cuối hiệp (kiến trúc dòng 846, 897–908): kho lương hồi máu, kiểm tra hết hiệp (Story 3.5, 3.9).
static func _end_of_round(state: BattleState, events: Array[BattleEvent]) -> void:
	state.phase = BattleState.Phase.END_OF_ROUND
	_heal_from_granaries(state, events)
	RulesVictory.check_round_limit(state, events)


## Báo trước các ô tiếp viện sẽ xuất hiện ở hiệp sau (Story 3.10, FR35).
static func _warn_reinforcements(state: BattleState, events: Array[BattleEvent]) -> void:
	state.reinforcement_warnings.clear()
	var next_round: int = state.round_number + 1
	for r: LevelData.Reinforcement in state.reinforcements:
		if r.round == next_round:
			state.reinforcement_warnings.append(r.cell)
			events.append(BattleEvent.reinforcement_warned(r.cell, r.type, r.round))


## Cuối hiệp: mỗi quân Nguyên đứng kề ít nhất một kho lương hồi 1 máu (Story 3.9). Vườn không nhà trống đốt hết kho
## nên sau đó không ai hồi (Story 3.12).
static func _heal_from_granaries(state: BattleState, events: Array[BattleEvent]) -> void:
	var enemies: Array[Unit] = []
	for unit: Unit in state.units:
		if UnitType.is_general(unit.type):
			continue
		if _is_adjacent_to_granary(state, unit.cell):
			enemies.append(unit)
	enemies.sort_custom(func(a: Unit, b: Unit) -> bool: return a.id < b.id)
	for enemy: Unit in enemies:
		Effects.heal(state, enemy, 1, events)


static func _is_adjacent_to_granary(state: BattleState, cell: Vector2i) -> bool:
	for dir: Vector2i in Grid.DIRECTIONS:
		var neighbor: Vector2i = cell + dir
		if state.in_bounds(neighbor) and state.terrain_at(neighbor) == Terrain.GRANARY:
			return true
	return false


## Pha chuẩn bị của hiệp 1 (lệnh BEGIN_BATTLE): không sang hiệp, không ROUND_STARTED.
## Chỉ chạy được một lần, ở hiệp 1 khi chưa có đòn hay ý định nào; ngoài ra không làm gì và không phát sự kiện
## (lệnh nội bộ gọi sai chỗ, lưới an toàn).
static func begin_battle(state: BattleState, events: Array[BattleEvent]) -> void:
	if state.round_number != 1 or not state.telegraphs.is_empty() or not state.enemy_intents.is_empty():
		return
	prepare(state, events)


## Pha địch chuẩn bị: xóa đòn cũ, tiếp viện xuất hiện (bước 1a), rồi từng quân Nguyên theo thứ tự (id, tức thu_tu_dich
## rồi tiếp viện) chọn mục tiêu và ô đứng (EnemyAI.plan) và đi từng ô tới đó (bước 1b). Đi hết cả bọn rồi mới báo đòn,
## theo bàn cuối cùng: Kỵ binh đã báo xung phong mà quân id lớn hơn đi chắn đường thì không báo (reason về CLOSEST).
## Số thứ tự chỉ đếm quân có đòn. Xong về PLAYER.
static func prepare(state: BattleState, events: Array[BattleEvent]) -> void:
	state.phase = BattleState.Phase.ENEMY_PREPARE
	state.telegraphs.clear()
	state.enemy_intents.clear()
	_spawn_reinforcements(state, events)
	if Rules.is_battle_over(state):
		return
	var enemies: Array[Unit] = []
	for unit: Unit in state.units:
		if unit.faction == Unit.Faction.NGUYEN:
			enemies.append(unit)
	enemies.sort_custom(func(a: Unit, b: Unit) -> bool: return a.id < b.id)
	for unit: Unit in enemies:
		# Từ Story 3.4 quân có thể gục trên hầm chông khi đang đi: quân đã rời bàn thì bỏ qua.
		if state.unit_by_id(unit.id) == null:
			continue
		var intent: EnemyIntent = EnemyAI.plan(state, unit)
		if intent.stand_cell != unit.cell:
			var path: Array[Vector2i] = Pathfinding.find_paths(state, unit,
				state.stats.move_range(unit.type))[intent.stand_cell] as Array[Vector2i]
			for step: Vector2i in path:
				Effects.move(state, unit, step, BattleEvent.Cause.WALK, events)
				if state.unit_by_id(unit.id) == null:
					break
				if state.mission == LevelData.Mission.HOLD_PASS and state.terrain_at(step) == Terrain.PASS:
					RulesVictory.check(state, events)
					if Rules.is_battle_over(state):
						return
		state.enemy_intents.append(intent)
	var next_order: int = 1
	for intent: EnemyIntent in state.enemy_intents:
		if intent.reason != EnemyIntent.Reason.CAN_HIT:
			continue
		var unit: Unit = state.unit_by_id(intent.unit_id)
		if unit == null:
			continue
		var target_cell: Vector2i = intent.target_cell
		if intent.target_id > 0:
			var target: Unit = state.unit_by_id(intent.target_id)
			if target == null:
				continue
			target_cell = target.cell
		elif target_cell == Vector2i(-1, -1):
			continue
		if not EnemyAI.can_hit_from(state, unit, unit.cell, target_cell):
			intent.reason = EnemyIntent.Reason.CLOSEST
			continue
		var telegraph: Telegraph = EnemyAI.telegraph_for(unit, unit.cell, target_cell, next_order)
		state.telegraphs.append(telegraph)
		intent.order = next_order
		events.append(BattleEvent.telegraphed(unit.id, unit.cell, telegraph.target_cell(state), next_order))
		next_order += 1
	_warn_reinforcements(state, events)
	state.phase = BattleState.Phase.PLAYER


## Bước 1a tiếp viện (Story 3.10): xử lý theo thứ tự khai báo. Ô có quân đứng: quân đó mất 1 máu, tiếp viện bị hủy.
## Ô trống: tiếp viện xuất hiện trên bàn, nhận id tiếp theo.
static func _spawn_reinforcements(state: BattleState, events: Array[BattleEvent]) -> void:
	var current_reinforcements: Array[LevelData.Reinforcement] = []
	var remaining: Array[LevelData.Reinforcement] = []
	for r: LevelData.Reinforcement in state.reinforcements:
		if r.round == state.round_number:
			current_reinforcements.append(r)
		else:
			remaining.append(r)
	state.reinforcements = remaining
	state.reinforcement_warnings.clear()

	for r: LevelData.Reinforcement in current_reinforcements:
		var occupant: Unit = state.unit_at(r.cell)
		if occupant != null:
			var strike: Array[BattleEvent] = []
			Effects.damage(state, occupant, 1, BattleEvent.Cause.REINFORCEMENT, strike)
			strike.append(BattleEvent.reinforcement_blocked(r.cell, r.type, occupant.id))
			events.append_array(strike)
		else:
			var new_unit: Unit = UnitFactory.create(state.next_enemy_id, r.type, r.cell, state.stats, r.hp)
			state.next_enemy_id += 1
			state.units.append(new_unit)
			events.append(BattleEvent.reinforcement_spawned(new_unit.id, r.cell, r.type))

	if not current_reinforcements.is_empty():
		RulesVictory.check(state, events)
		_check_victory_after_spawn(state, events)


## Kiểm tra thắng/thua sau bước 1a kể cả khi không ai gục (Review Patch 2: bàn trống + hết tiếp viện → thắng).
static func _check_victory_after_spawn(state: BattleState, events: Array[BattleEvent]) -> void:
	if state.phase == BattleState.Phase.WON or state.phase == BattleState.Phase.LOST:
		return
	var enemies_count: int = 0
	var heroes_count: int = 0
	for u: Unit in state.units:
		if u.faction == Unit.Faction.NGUYEN:
			enemies_count += 1
		elif u.faction == Unit.Faction.DAI_VIET:
			heroes_count += 1
	if state.mission == LevelData.Mission.ELIMINATE and enemies_count == 0 and state.reinforcements.is_empty():
		state.phase = BattleState.Phase.WON
		events.append(BattleEvent.victory())
	elif heroes_count == 0:
		state.phase = BattleState.Phase.LOST
		events.append(BattleEvent.defeat())
