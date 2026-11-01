extends GutTest
## Chỉ báo xem trước (Story 4.6, FR41 trau chuốt): va chạm, chết đuối, đòn địch dời hoặc bị hủy, đòn địch sẽ trúng
## quân khác. Chỉ test phần tính (PreviewMarks.compute); phần vẽ tác giả thử tay.
## Bàn chung: Khoái 2,3 chém Bộ binh 3,3, đẩy sang phải 4,3. Bộ binh đã báo đòn đánh ô ngay dưới nó (3,4).

const KHOAI_CELL: Vector2i = Vector2i(2, 3)
const BO_BINH_CELL: Vector2i = Vector2i(3, 3)
const PUSHED_CELL: Vector2i = Vector2i(4, 3)
const OLD_HIT: Vector2i = Vector2i(3, 4)
const NEW_HIT: Vector2i = Vector2i(4, 4)
## Cung kỵ đứng xa ở góc: Bộ binh gục thì trận chưa thắng (Tiêu diệt), còn đòn để báo.
const FAR_ARCHER: Dictionary = {Vector2i(6, 6): "C"}


## Bàn với Khoái và Bộ binh (id 101, đứng trước mọi quân Nguyên khác theo thứ tự đọc bàn) đã báo đòn xuống dưới.
func _state(extra_units: Dictionary = {}, terrain: Dictionary = {}) -> BattleState:
	var units: Dictionary = {KHOAI_CELL: "1", BO_BINH_CELL: "B"}
	units.merge(extra_units)
	var state: BattleState = BoardFixture.state(units, terrain)
	var bo_binh: Unit = state.unit_at(BO_BINH_CELL)
	state.telegraphs.append(Telegraph.new(bo_binh.id, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	assert_eq(state.validate(), [] as Array[String])
	return state


func _marks_after_attack(state: BattleState, target: Vector2i) -> Array[Dictionary]:
	var after: BattleState = state.clone()
	var events: Array[BattleEvent] = Rules.resolve(after, Command.attack(1, target))
	assert_false(events.any(func(e: BattleEvent) -> bool: return e.type == BattleEvent.Type.REJECTED), "đánh được")
	assert_eq(after.validate(), [] as Array[String])
	return PreviewMarks.compute(state, after, events)


func _kinds(marks: Array[Dictionary]) -> Array:
	var out: Array = []
	for m: Dictionary in marks:
		out.append([m["kind"], m["cell"]])
	return out


func test_pushed_owner_moves_its_strike() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state(), BO_BINH_CELL)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.STRIKE_MOVED, NEW_HIT]])
	assert_eq(marks[0]["from_cell"], OLD_HIT, "ô đỏ cũ")


func test_moved_strike_will_hit_another_enemy() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state({NEW_HIT: "K"}), BO_BINH_CELL)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.STRIKE_MOVED, NEW_HIT], [PreviewMarks.Kind.HITS_ENEMY, NEW_HIT]])


func test_moved_strike_will_hit_a_general() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state({NEW_HIT: "2"}), BO_BINH_CELL)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.STRIKE_MOVED, NEW_HIT], [PreviewMarks.Kind.HITS_GENERAL, NEW_HIT]])


## Đẩy va rừng: Bộ binh 3 máu mất 2 (chém) + 1 (va) thì gục, nên đòn của nó cũng bị hủy.
func test_push_into_forest_marks_collision_and_cancels_strike() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state(FAR_ARCHER, {PUSHED_CELL: "#"}), BO_BINH_CELL)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.COLLISION, BO_BINH_CELL], [PreviewMarks.Kind.STRIKE_CANCELLED, OLD_HIT]])
	assert_eq(marks[0]["amount"], ForcedMove.COLLISION_DAMAGE)


func test_push_into_river_marks_drowning_and_cancels_strike() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state(FAR_ARCHER, {PUSHED_CELL: "~"}), BO_BINH_CELL)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.DROWNED, PUSHED_CELL], [PreviewMarks.Kind.STRIKE_CANCELLED, OLD_HIT]])


## Chém gục quân khác (Kỵ binh 2 máu) không đụng tới đòn của Bộ binh: không chỉ báo đòn nào.
func test_unrelated_attack_leaves_strikes_unmarked() -> void:
	var marks: Array[Dictionary] = _marks_after_attack(_state({Vector2i(2, 2): "K"}), Vector2i(2, 2))
	assert_eq(_kinds(marks), [])


## Đòn không dời nhưng quân ở ô trúng đổi: Khoái 1,4 chém Bộ binh thứ hai 2,4 (còn 1 máu), đẩy nó sang 3,4, đúng ô
## Bộ binh 3,3 sắp đánh: báo trúng giặc.
func test_strike_unchanged_but_new_victim_is_marked() -> void:
	var units: Dictionary = {Vector2i(1, 4): "1", BO_BINH_CELL: "B", Vector2i(2, 4): "B"}
	var state: BattleState = BoardFixture.state(units)
	state.telegraphs.append(Telegraph.new(state.unit_at(BO_BINH_CELL).id, Telegraph.Kind.CELL, Vector2i(0, 1), 1))
	assert_eq(state.validate(), [] as Array[String])
	var marks: Array[Dictionary] = _marks_after_attack(state, Vector2i(2, 4))
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.HITS_ENEMY, OLD_HIT]])


## Trận kết thúc ngay trong lệnh (đòn cuối hạ quân cuối): không còn đòn nào để báo, không chỉ báo đòn.
func test_battle_over_reports_no_strike_marks() -> void:
	var state: BattleState = _state({}, {PUSHED_CELL: "~"})
	var after: BattleState = state.clone()
	var events: Array[BattleEvent] = Rules.resolve(after, Command.attack(1, BO_BINH_CELL))
	assert_eq(after.phase, BattleState.Phase.WON, "hết quân Nguyên thì thắng (Tiêu diệt)")
	var marks: Array[Dictionary] = PreviewMarks.compute(state, after, events)
	assert_eq(_kinds(marks), [[PreviewMarks.Kind.DROWNED, PUSHED_CELL]])
