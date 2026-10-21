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
	state.round_number += 1
	for unit: Unit in state.units:
		unit.has_moved = false
		unit.has_attacked = false
	events.append(BattleEvent.round_started(state.round_number))
	prepare(state, events)


## Ra các đòn đã báo theo số thứ tự (state.telegraphs đã xếp). Ô trúng tính lúc đòn ra, theo bàn sau các đòn trước
## (TelegraphMarks.hit_cell, cùng chỗ tính ô đỏ). NO_CELL (chủ đã gục, ô đích ngoài bàn, Kỵ binh sát mép hướng ra
## ngoài) thì đòn không ra (sự kiện hủy đòn: Story 2.9). Quân ở ô trúng, bất kỳ phe, mất máu theo sát thương của chủ
## đòn; không đẩy, chủ đòn không đi. Kiểm thắng/thua sau từng đòn; trận hết thì dừng ngay.
static func _strike_all(state: BattleState, events: Array[BattleEvent]) -> void:
	state.phase = BattleState.Phase.ENEMY_ACT
	for telegraph: Telegraph in state.telegraphs:
		var hit: Vector2i = TelegraphMarks.hit_cell(state, telegraph)
		if hit == Telegraph.NO_CELL:
			continue
		var owner: Unit = state.unit_by_id(telegraph.owner_id)
		var strike: Array[BattleEvent] = [BattleEvent.enemy_attacked(owner.id, owner.cell, hit)]
		var victim: Unit = state.unit_at(hit)
		if victim != null:
			Effects.damage(state, victim, state.stats.damage(owner.type), BattleEvent.Cause.ENEMY_STRIKE, strike)
		# Kiểm trên sự kiện của riêng đòn này rồi mới nối, để VICTORY/DEFEAT là sự kiện cuối của lệnh.
		RulesVictory.check(state, strike)
		events.append_array(strike)
		if Rules.is_battle_over(state):
			return


## Pha chuẩn bị của hiệp 1 (lệnh BEGIN_BATTLE): không sang hiệp, không ROUND_STARTED.
## Chỉ chạy được một lần, ở hiệp 1 khi chưa có đòn hay ý định nào; ngoài ra không làm gì và không phát sự kiện
## (lệnh nội bộ gọi sai chỗ, lưới an toàn).
static func begin_battle(state: BattleState, events: Array[BattleEvent]) -> void:
	if state.round_number != 1 or not state.telegraphs.is_empty() or not state.enemy_intents.is_empty():
		return
	prepare(state, events)


## Pha địch chuẩn bị: xóa đòn cũ, rồi từng quân Nguyên theo thứ tự (id, tức thu_tu_dich) chọn mục tiêu và ô đứng
## (EnemyAI.plan) và đi từng ô tới đó. Đi hết cả bọn rồi mới báo đòn, theo bàn cuối cùng: Kỵ binh đã báo xung phong
## mà quân id lớn hơn đi chắn đường thì không báo (reason về CLOSEST). Số thứ tự chỉ đếm quân có đòn. Xong về PLAYER.
static func prepare(state: BattleState, events: Array[BattleEvent]) -> void:
	state.phase = BattleState.Phase.ENEMY_PREPARE
	state.telegraphs.clear()
	state.enemy_intents.clear()
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
		state.enemy_intents.append(intent)
	var next_order: int = 1
	for intent: EnemyIntent in state.enemy_intents:
		if intent.reason != EnemyIntent.Reason.CAN_HIT:
			continue
		var unit: Unit = state.unit_by_id(intent.unit_id)
		var target: Unit = state.unit_by_id(intent.target_id)
		if unit == null or target == null:
			continue
		if not EnemyAI.can_hit_from(state, unit, unit.cell, target.cell):
			intent.reason = EnemyIntent.Reason.CLOSEST
			continue
		var telegraph: Telegraph = EnemyAI.telegraph_for(unit, unit.cell, target.cell, next_order)
		state.telegraphs.append(telegraph)
		intent.order = next_order
		events.append(BattleEvent.telegraphed(unit.id, unit.cell, telegraph.target_cell(state), next_order))
		next_order += 1
	state.phase = BattleState.Phase.PLAYER
