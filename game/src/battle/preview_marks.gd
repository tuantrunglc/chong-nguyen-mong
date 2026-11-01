class_name PreviewMarks
extends RefCounted
## Chuỗi hệ quả của một đòn xem trước (Story 4.6, FR41 trau chuốt), ngoài bóng mờ vị trí cuối + máu (Story 2.12):
## va chạm, chết đuối, đòn địch dời theo hoặc bị hủy, đòn địch sẽ trúng quân khác. Hàm thuần: đọc hai bản chụp
## (trước/sau lệnh, cái sau từ BattleController.preview_result) và sự kiện của lệnh; không sửa gì, không vẽ.
## Mỗi chỉ báo là { "kind": Kind, "cell": Vector2i, ... }; thứ tự: va chạm, chết đuối theo thứ tự sự kiện, rồi đòn
## theo số thứ tự đòn.

enum Kind {
	## Quân bị đẩy va vào vật: "cell" là ô quân đó đứng lúc va, "amount" là máu mất do va.
	COLLISION,
	## Quân Nguyên rơi xuống sông: "cell" là ô sông.
	DROWNED,
	## Đòn đã báo dời theo chủ đòn: "cell" là ô trúng mới, "from_cell" là ô đỏ cũ, "order" là số thứ tự đòn.
	STRIKE_MOVED,
	## Đòn đã báo không còn ra (chủ gục, đòn ra ngoài bàn…): "cell" là ô đỏ cũ.
	STRIKE_CANCELLED,
	## Sau lệnh, đòn sẽ trúng một quân Nguyên khác (địch đánh nhau): "cell" là ô trúng.
	HITS_ENEMY,
	## Sau lệnh, đòn sẽ trúng một tướng mình: "cell" là ô trúng.
	HITS_GENERAL,
}


static func compute(before: BattleState, after: BattleState, events: Array[BattleEvent]) -> Array[Dictionary]:
	var marks: Array[Dictionary] = []
	_add_forced_move_marks(before, events, marks)
	# Hết trận trong lệnh này thì bàn sau không còn đòn nào (Rules.resolve xóa telegraphs): không báo đòn.
	if not Rules.is_battle_over(after):
		_add_strike_marks(before, after, marks)
	return marks


static func _add_forced_move_marks(before: BattleState, events: Array[BattleEvent], marks: Array[Dictionary]) -> void:
	# Ô hiện tại của từng quân trong lúc lệnh chạy, theo các MOVED đã qua.
	var at: Dictionary = {}
	for unit: Unit in before.units:
		at[unit.id] = unit.cell
	for i: int in range(events.size()):
		var event: BattleEvent = events[i]
		match event.type:
			BattleEvent.Type.MOVED:
				at[event.unit_id] = event.to_cell
			BattleEvent.Type.COLLIDED:
				marks.append({"kind": Kind.COLLISION, "cell": at.get(event.unit_id, event.to_cell) as Vector2i,
					"amount": _collision_damage(events, i)})
			BattleEvent.Type.DROWNED:
				marks.append({"kind": Kind.DROWNED, "cell": event.to_cell})


## Máu quân va thật sự mất: DAMAGED (cause COLLISION) của quân đó ngay sau COLLIDED thứ index.
static func _collision_damage(events: Array[BattleEvent], index: int) -> int:
	var unit_id: int = events[index].unit_id
	for i: int in range(index + 1, events.size()):
		var e: BattleEvent = events[i]
		if e.type == BattleEvent.Type.DAMAGED and e.cause == BattleEvent.Cause.COLLISION and e.unit_id == unit_id:
			return e.amount
	return 0


static func _add_strike_marks(before: BattleState, after: BattleState, marks: Array[Dictionary]) -> void:
	for old: Telegraph in before.telegraphs:
		var old_hit: Vector2i = TelegraphMarks.hit_cell(before, old)
		var now: Telegraph = _same_telegraph(after, old)
		var new_hit: Vector2i = Telegraph.NO_CELL if now == null else TelegraphMarks.hit_cell(after, now)
		if new_hit == Telegraph.NO_CELL:
			if old_hit != Telegraph.NO_CELL:
				marks.append({"kind": Kind.STRIKE_CANCELLED, "cell": old_hit, "order": old.order})
			continue
		if new_hit != old_hit:
			marks.append({"kind": Kind.STRIKE_MOVED, "cell": new_hit, "from_cell": old_hit, "order": old.order})
		var victim: Unit = after.unit_at(new_hit)
		if victim == null or victim.id == old.owner_id:
			continue
		# Đòn không dời và vẫn trúng đúng quân cũ: ô đỏ thật đã nói đủ, không báo thêm.
		var old_victim: Unit = before.unit_at(old_hit) if old_hit != Telegraph.NO_CELL else null
		if new_hit == old_hit and old_victim != null and old_victim.id == victim.id:
			continue
		var kind: Kind = Kind.HITS_GENERAL if victim.faction == Unit.Faction.DAI_VIET else Kind.HITS_ENEMY
		marks.append({"kind": kind, "cell": new_hit, "order": old.order})


## Đòn tương ứng trong bản chụp sau (clone giữ chủ đòn và số thứ tự); null nếu không còn.
static func _same_telegraph(state: BattleState, telegraph: Telegraph) -> Telegraph:
	for t: Telegraph in state.telegraphs:
		if t.owner_id == telegraph.owner_id and t.order == telegraph.order:
			return t
	return null
