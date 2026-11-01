extends GutTest
## Đo cho Story 4.7, phần máy đo được: pha địch dài nhất mỗi trận (NFR3) và không kẹt trận (NFR6).
## Chạy trên chỉ số THẬT (data/chi_so.json) như bộ kiểm lời giải: tác giả sửa số thì số đo theo.
## Chuyển trận, màn thắng/thua và nút đi tiếp đã có test ở test_main.gd (4.2, 4.3); không lặp lại ở đây.

const CAMPAIGN_PATH: String = "res://data/chien_dich.json"
const STATS_PATH: String = "res://data/chi_so.json"
## Trần số lệnh "kết thúc lượt" cho mỗi trận: quá mức này mà trận chưa xong là coi như kẹt.
const MAX_END_TURNS: int = 60


func _campaign() -> CampaignData:
	var r: LoadResult = CampaignLoader.load_campaign(CAMPAIGN_PATH, SolutionCheck.LEVEL_DIR)
	assert_true(r.ok, "chuỗi trận nạp được: %s" % "; ".join(r.errors))
	return r.data as CampaignData if r.ok else null


func _stats() -> Stats:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_true(r.ok, "chi_so.json nạp được: %s" % "; ".join(r.errors))
	return r.data as Stats if r.ok else null


func _open(level_id: String, stats: Stats) -> BattleState:
	var lr: LoadResult = LevelLoader.load_level("%s/%s.json" % [SolutionCheck.LEVEL_DIR, level_id])
	assert_true(lr.ok, "%s nạp được: %s" % [level_id, "; ".join(lr.errors)])
	return BattleState.from_level(lr.data as LevelData, stats)


## Pha địch dài nhất của lời giải mỗi trận không vượt 3 giây. Ghi số đo (số sự kiện, giây trước khi co) vào log test
## để dán vào NEXT-STEPS.md; total_seconds() đã chặn ở 3 giây, còn pha thật được EventPlayer canh bằng đồng hồ.
func test_longest_enemy_phase_of_each_level_fits_three_seconds() -> void:
	var campaign: CampaignData = _campaign()
	var stats: Stats = _stats()
	if campaign == null or stats == null:
		return
	var player: EventPlayer = EventPlayer.new()
	add_child_autofree(player)
	var outcomes: Array[SolutionCheck.Outcome] = SolutionCheck.check_campaign(CAMPAIGN_PATH, stats)
	assert_eq(outcomes.size(), campaign.levels.size(), "mỗi trận trong chuỗi có một kết quả")
	for o: SolutionCheck.Outcome in outcomes:
		assert_true(o.passed, o.summary())
		assert_false(o.enemy_phase_logs.is_empty(), "%s: có ít nhất pha chuẩn bị" % o.level_id)
		var longest_events: int = 0
		var longest_raw: float = 0.0
		for log_events: Array in o.enemy_phase_logs:
			var typed: Array[BattleEvent] = []
			for e: Variant in log_events:
				typed.append(e as BattleEvent)
			assert_lte(player.total_seconds(typed), EventPlayer.MAX_PHASE_SECONDS, "%s: pha địch ≤ 3 giây" % o.level_id)
			if player.raw_seconds(typed) > longest_raw:
				longest_raw = player.raw_seconds(typed)
				longest_events = typed.size()
		gut.p("%s: pha địch dài nhất %d sự kiện, %.2f giây trước khi co (trần %.1f)" % [o.level_id, longest_events,
			longest_raw, EventPlayer.MAX_PHASE_SECONDS])


## Đứng yên: chỉ kết thúc lượt. Trận phải xong (thắng hoặc thua) trong MAX_END_TURNS lượt, bàn luôn hợp lệ,
## không lệnh nào bị từ chối trong lúc trận còn mở.
func test_standing_still_always_ends_every_level() -> void:
	var campaign: CampaignData = _campaign()
	var stats: Stats = _stats()
	if campaign == null or stats == null:
		return
	for level_id: String in campaign.levels:
		var state: BattleState = _open(level_id, stats)
		Rules.resolve(state, Command.begin_battle())
		var turns: int = 0
		while not Rules.is_battle_over(state) and turns < MAX_END_TURNS:
			var events: Array[BattleEvent] = Rules.resolve(state, Command.end_turn())
			turns += 1
			for e: BattleEvent in events:
				assert_ne(e.type, BattleEvent.Type.REJECTED, "%s lượt %d: kết thúc lượt bị từ chối (%s)" % [level_id, turns, e.reason])
			assert_eq(state.validate(), [] as Array[String], "%s lượt %d: bàn hợp lệ" % [level_id, turns])
		assert_true(Rules.is_battle_over(state), "%s: đứng yên %d lượt mà trận chưa kết thúc (kẹt?)" % [level_id, turns])
		gut.p("%s: đứng yên, trận kết thúc sau %d lượt (%s)" % [level_id, turns,
			"thắng" if state.phase == BattleState.Phase.WON else "thua"])
