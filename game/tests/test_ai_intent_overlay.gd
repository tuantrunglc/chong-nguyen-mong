extends GutTest
## Bảng F3 ý định AI (Story 2.6): chữ dựng từ BattleState.enemy_intents của bản chụp.


func _prepared(units: Dictionary, terrain: Dictionary = {}) -> BattleState:
	var state: BattleState = BoardFixture.state(units, terrain)
	var events: Array[BattleEvent] = []
	RulesEnemyPhase.prepare(state, events)
	return state


func test_lines_for_each_reason() -> void:
	# 101 đi tới kề Khoái và báo đòn; 102 xa, đi gần lại; 103 bị sông vây ở góc.
	var state: BattleState = _prepared({Vector2i(3, 1): "B", Vector2i(3, 4): "1", Vector2i(6, 4): "K",
		Vector2i(0, 6): "B"}, {Vector2i(0, 5): "~", Vector2i(1, 6): "~"})
	assert_eq(AiIntentOverlay.texts_for(state), [
		"Ý định quân Nguyên (hiệp 1)",
		"Bộ binh 101: 3,1 → 3,3 · nhắm Nguyễn Khoái (cách 3 bước) · đứng đây vì đánh trúng được · đòn số 1",
		"Kỵ binh 102: đứng yên ở 6,4 · nhắm Nguyễn Khoái (cách 3 bước) · đứng đây vì đánh trúng được · đòn số 2",
		"Bộ binh 103: đứng yên ở 0,6 · không có đường tới tướng nào · không báo đòn",
	] as Array[String])


func test_far_unit_and_fallen_unit() -> void:
	var state: BattleState = _prepared({Vector2i(3, 0): "B", Vector2i(3, 6): "2"})
	assert_eq(AiIntentOverlay.texts_for(state)[1], "Bộ binh 101: 3,0 → 3,2 · nhắm Phạm Ngũ Lão (cách 6 bước) · "
		+ "không có ô đánh trúng trong tầm đi, đi tới ô gần nhất · không báo đòn")
	var events: Array[BattleEvent] = []
	Effects.damage(state, state.unit_by_id(101), 3, BattleEvent.Cause.STRIKE, events)
	assert_eq(AiIntentOverlay.texts_for(state)[1].begins_with("Bộ binh 101 (đã gục): 3,0 → 3,2"), true,
		"ý định của đầu hiệp vẫn hiện, ghi đã gục")


func test_no_enemy_and_archer() -> void:
	var empty: BattleState = _prepared({Vector2i(3, 6): "1"})
	assert_eq(AiIntentOverlay.texts_for(empty), ["Ý định quân Nguyên (hiệp 1)", "không có quân Nguyên"] as Array[String])
	var archer: BattleState = _prepared({Vector2i(3, 0): "C", Vector2i(3, 6): "1"})
	assert_eq(AiIntentOverlay.texts_for(archer)[1], "Cung kỵ 101: đứng yên ở 3,0 · nhắm Nguyễn Khoái (cách 6 bước) · "
		+ "chưa có luật đòn cho loại quân này · không báo đòn")


func test_toggle_and_show_state() -> void:
	var overlay: AiIntentOverlay = AiIntentOverlay.new()
	add_child_autofree(overlay)
	assert_false(overlay.visible, "mặc định ẩn")
	overlay.show_state(_prepared({Vector2i(3, 3): "B", Vector2i(3, 4): "1"}))
	assert_eq(overlay.texts().size(), 2)
	assert_true(overlay.toggle())
	assert_false(overlay.toggle())
	overlay.show_state(null)
	assert_eq(overlay.texts(), [] as Array[String])
