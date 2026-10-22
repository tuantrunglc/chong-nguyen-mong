extends GutTest
## Tất định (NFR5, Story 2.8): mỗi kịch bản trong tests/kich_ban/ (cả chưa duyệt) chạy hai lần phải ra giống hệt:
## bàn cuối (vị trí, máu, cờ đi/đánh, hiệp, pha, đòn đã báo, ý định AI) và dãy sự kiện của từng lệnh.

const ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"


## Một dòng chữ cho bàn cuối; null (kịch bản dừng sớm vì lỗi) thành "".
static func state_text(state: BattleState) -> String:
	if state == null:
		return ""
	var parts: PackedStringArray = PackedStringArray()
	parts.append("hiep %d pha %s" % [state.round_number, BattleState.Phase.find_key(state.phase)])
	for u: Unit in state.units:
		parts.append("quan %d %d @%s mau %d di %s danh %s" % [u.id, u.type, BoardText.cell_text(u.cell), u.hp,
			u.has_moved, u.has_attacked])
	for t: Telegraph in state.telegraphs:
		parts.append("don %d chu %d %s %s" % [t.order, t.owner_id, Telegraph.Kind.find_key(t.kind), t.offset])
	for i: EnemyIntent in state.enemy_intents:
		parts.append("y_dinh %d dung %s nham %d %s #%d" % [i.unit_id, BoardText.cell_text(i.stand_cell), i.target_id,
			EnemyIntent.Reason.find_key(i.reason), i.order])
	return " | ".join(parts)


## Đủ mọi trường của sự kiện.
static func event_text(e: BattleEvent) -> String:
	return "%s %d %s>%s %s %s '%s' %d %d %d %s" % [BattleEvent.Type.find_key(e.type), e.unit_id, e.from_cell,
		e.to_cell, BattleEvent.Cause.find_key(e.cause), BattleEvent.Reject.find_key(e.reject), e.reason,
		e.round_number, e.amount, e.other_id, BattleEvent.TelegraphCancel.find_key(e.cancel)]


static func run_text(result: ScenarioRunner.ScenarioResult) -> Array[String]:
	var out: Array[String] = [state_text(result.final_state)]
	for i: int in range(result.step_events.size()):
		for e: BattleEvent in result.step_events[i]:
			out.append("buoc %d: %s" % [i + 1, event_text(e as BattleEvent)])
	out.append_array(result.problems)
	return out


func test_every_scenario_runs_the_same_twice() -> void:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(r.errors, [] as Array[String], "chi_so.json nạp được")
	var stats: Stats = r.data as Stats
	if stats == null:
		return
	var count: int = 0
	for path: String in ScenarioLoader.list_files(ROOT):
		var loaded: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		if not loaded.ok:
			continue  # test_scenarios.gd đã báo kịch bản sai định dạng
		var scenario: ScenarioData = loaded.data as ScenarioData
		var first: Array[String] = run_text(ScenarioRunner.run(scenario, stats))
		var second: Array[String] = run_text(ScenarioRunner.run(scenario, stats))
		count += 1
		if first == second:
			continue
		var line: int = 0
		while line < mini(first.size(), second.size()) and first[line] == second[line]:
			line += 1
		var a: String = first[line] if line < first.size() else "(hết)"
		var b: String = second[line] if line < second.size() else "(hết)"
		fail_test("kịch bản %s chạy hai lần ra khác nhau: lần 1 \"%s\", lần 2 \"%s\"" % [scenario.id, a, b])
	assert_gt(count, 0, "có kịch bản để chạy")
