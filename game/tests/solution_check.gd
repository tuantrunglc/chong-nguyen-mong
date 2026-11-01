class_name SolutionCheck
extends RefCounted
## Kiểm lời giải một trận (Story 4.6): mở trận từ file thật (from_level + begin_battle) với chỉ số được đưa vào,
## chạy các bước của kịch bản lời giải qua Rules.resolve, validate() sau mỗi lệnh. Đạt khi không lệnh nào bị từ
## chối, trận thắng và không tướng nào gục; không so máu, ô hay số hiệp (khác ScenarioRunner, so đúng từng ô).
## Chỉ đọc các bước của kịch bản, không dùng "truoc"/"sau". Kịch bản nạp bằng bản chụp chỉ số (StatsSnapshot): bộ nạp kiểm
## máu ghi trong "sau" theo máu tối đa, nên nạp bằng số thật thì đổi máu là kịch bản không nạp được. Câu kết quả cho dev và tools/test.sh, không qua tr()
## (như ScenarioRunner), trừ câu thua lấy đúng chữ của bảng kết quả.

const LEVEL_DIR: String = "res://data/tran"
const SOLUTION_DIR: String = "res://tests/kich_ban/tran"
const SCENARIO_ROOT: String = "res://tests/kich_ban"


class Outcome:
	extends RefCounted

	var level_id: String = ""
	## Tên trận trong file trận; id trận khi chưa nạp được.
	var level_name: String = ""
	var passed: bool = false
	## Lý do trượt (một câu); rỗng khi đạt.
	var reason: String = ""
	var round_number: int = 0
	## "Nguyễn Khoái 3" cho mỗi tướng còn trên bàn, theo id.
	var generals: Array[String] = []
	## Nhật ký sự kiện của từng pha địch đã chạy: pha chuẩn bị lúc mở trận rồi mỗi lệnh kết thúc lượt (Story 4.7).
	var enemy_phase_logs: Array[Array] = []

	## "Trận 1 — …: thắng ở hiệp 3, đủ 2 tướng (Nguyễn Khoái 3, Phạm Ngũ Lão 3)" hoặc "Trận 5 — …: <lý do>".
	func summary() -> String:
		if passed:
			return "%s: thắng ở hiệp %d, đủ %d tướng (%s)" % [level_name, round_number, generals.size(),
				", ".join(generals)]
		return "%s: %s" % [level_name, reason]


## Kiểm mọi trận của chuỗi chiến dịch, theo thứ tự chơi. Chuỗi không nạp được thì một kết quả trượt.
static func check_campaign(campaign_path: String, stats: Stats) -> Array[Outcome]:
	var outcomes: Array[Outcome] = []
	var r: LoadResult = CampaignLoader.load_campaign(campaign_path, LEVEL_DIR)
	if not r.ok:
		var o: Outcome = Outcome.new()
		o.level_name = campaign_path
		o.reason = "không nạp được chuỗi trận: %s" % "; ".join(r.errors)
		outcomes.append(o)
		return outcomes
	for level_id: String in (r.data as CampaignData).levels:
		outcomes.append(check(level_id, stats))
	return outcomes


static func check(level_id: String, stats: Stats) -> Outcome:
	var o: Outcome = Outcome.new()
	o.level_id = level_id
	o.level_name = level_id
	var lr: LoadResult = LevelLoader.load_level("%s/%s.json" % [LEVEL_DIR, level_id])
	if not lr.ok:
		o.reason = "không nạp được file trận: %s" % "; ".join(lr.errors)
		return o
	var level: LevelData = lr.data as LevelData
	o.level_name = level.name
	var solution_path: String = "%s/%s_loi_giai.json" % [SOLUTION_DIR, level_id]
	if not FileAccess.file_exists(solution_path):
		o.reason = "chưa có lời giải %s" % solution_path
		return o
	var snapshot: LoadResult = StatsSnapshot.load_stats()
	if not snapshot.ok:
		o.reason = "không nạp được bản chụp chỉ số: %s" % "; ".join(snapshot.errors)
		return o
	var sr: LoadResult = ScenarioLoader.load_scenario(solution_path, SCENARIO_ROOT, snapshot.data as Stats)
	if not sr.ok:
		o.reason = "không nạp được lời giải: %s" % "; ".join(sr.errors)
		return o
	o.reason = _play(level, (sr.data as ScenarioData).steps, stats, o)
	o.passed = o.reason.is_empty()
	return o


## Chạy lời giải, điền round_number và generals; trả lý do trượt đầu tiên, "" nếu đạt.
static func _play(level: LevelData, steps: Array[ScenarioData.ScenarioStep], stats: Stats, o: Outcome) -> String:
	var state: BattleState = BattleState.from_level(level, stats)
	# Tướng đầu trận (id -> loại quân): tướng cuối trận không còn trên bàn là tướng gục, bất kể sự kiện nào gây ra.
	var general_types: Dictionary = {}
	var general_ids: Array[int] = []
	for u: Unit in state.units:
		if UnitType.is_general(u.type):
			general_ids.append(u.id)
			general_types[u.id] = u.type
	var fallen: Dictionary = {}
	var events: Array[BattleEvent] = Rules.resolve(state, Command.begin_battle())
	o.enemy_phase_logs.append(events)
	for e: BattleEvent in events:
		if e.type == BattleEvent.Type.REJECTED:
			return "mở trận bị từ chối: %s" % _reject_text(e, null)
	var problems: Array[String] = state.validate()
	if not problems.is_empty():
		return "bàn mở trận sai: %s" % problems[0]
	for i: int in range(steps.size()):
		if Rules.is_battle_over(state):
			break
		var step: ScenarioData.ScenarioStep = steps[i]
		var command: Command
		match step.kind:
			"di", "danh":
				if not UnitType.GENERALS.has(step.general):
					return "bước %d: tướng không có trong danh sách tướng" % [i + 1]
				var general_id: int = _general_id(step.general)
				command = Command.move(general_id, step.cell) if step.kind == "di" \
					else Command.attack(general_id, step.cell)
			"muu_ke":
				command = Command.use_stratagem(step.stratagem)
			"ket_thuc_luot":
				command = Command.end_turn()
			_:
				return "bước %d: lệnh \"%s\" không dùng được trong lời giải" % [i + 1, step.kind]
		events = Rules.resolve(state, command)
		if step.kind == "ket_thuc_luot":
			o.enemy_phase_logs.append(events)
		for e: BattleEvent in events:
			if e.type == BattleEvent.Type.REJECTED:
				return "bước %d (%s) bị từ chối: %s" % [i + 1, _describe(step), _reject_text(e, step)]
		_note_deaths(state, general_ids, general_types, fallen)
		problems = state.validate()
		if not problems.is_empty():
			return "bước %d: bàn sai sau lệnh: %s" % [i + 1, problems[0]]
	o.round_number = state.round_number
	for id: int in general_ids:
		var g: Unit = state.unit_by_id(id)
		if g != null:
			o.generals.append("%s %d" % [ScenarioRunner.UNIT_NAMES.get(g.type, "?"), g.hp])
	match state.phase:
		BattleState.Phase.LOST:
			return "thua ở hiệp %d (%s)" % [state.round_number, TranslationServer.translate(
				ResultBanner.lost_title_key(state.defeat_reason))]
		BattleState.Phase.WON:
			if not fallen.is_empty():
				return "thắng ở hiệp %d nhưng %s" % [state.round_number, ", ".join(PackedStringArray(fallen.values()))]
			return ""
	return "hết lời giải mà chưa thắng (đang ở hiệp %d)" % state.round_number


## Ghi "<tên tướng> gục ở hiệp N" (một lần, id -> câu) cho mỗi tướng đầu trận nay không còn trên bàn.
static func _note_deaths(state: BattleState, general_ids: Array[int], general_types: Dictionary,
		fallen: Dictionary) -> void:
	for id: int in general_ids:
		var g: Unit = state.unit_by_id(id)
		if (g != null and g.is_alive()) or fallen.has(id):
			continue
		fallen[id] = "%s gục ở hiệp %d" % [ScenarioRunner.UNIT_NAMES.get(general_types[id], "?"), state.round_number]


## Id tướng theo UnitType (UnitFactory: tướng 1–3 theo thứ tự UnitType.GENERALS).
static func _general_id(general: int) -> int:
	return UnitType.GENERALS.find(general) + 1


## Lý do REJECTED bằng câu người test đọc được; loại lý do chưa có câu riêng thì in chữ của luật.
static func _reject_text(e: BattleEvent, step: ScenarioData.ScenarioStep) -> String:
	var cell: String = "" if step == null or step.kind == "muu_ke" or step.kind == "ket_thuc_luot" \
		else BoardText.cell_text(step.cell)
	var who: String = "" if step == null else str(ScenarioRunner.UNIT_NAMES.get(step.general, "tướng"))
	match e.reject:
		BattleEvent.Reject.UNREACHABLE:
			return "%s không đi tới được ô %s" % [who, cell]
		BattleEvent.Reject.NOT_IN_RANGE:
			return "ô %s ngoài tầm đánh của %s" % [cell, who]
		BattleEvent.Reject.NO_TARGET:
			return "ô %s không có ai để đánh" % cell
		BattleEvent.Reject.BLOCKED:
			return "đòn vào ô %s bị rừng hoặc kho lương chắn" % cell
		BattleEvent.Reject.NOT_ADJACENT:
			return "ô %s không kề %s" % [cell, who]
		BattleEvent.Reject.ALREADY_MOVED:
			return "%s đã đi trong lượt này" % who
		BattleEvent.Reject.ALREADY_ATTACKED:
			return "%s đã đánh trong lượt này" % who
		BattleEvent.Reject.NO_UNIT, BattleEvent.Reject.NOT_GENERAL:
			return "%s không còn trên bàn" % who
		BattleEvent.Reject.STRATAGEM_LOCKED:
			return "mưu kế chưa mở trong trận này"
		BattleEvent.Reject.STRATAGEM_ALREADY_USED:
			return "mưu kế đã dùng rồi"
		BattleEvent.Reject.BATTLE_OVER:
			return "trận đã kết thúc"
	return e.reason


## "Phạm Ngũ Lão đi 2,4" / "Nguyễn Khoái đánh 8,6" / "mưu kế sat_that" / "kết thúc lượt".
static func _describe(step: ScenarioData.ScenarioStep) -> String:
	match step.kind:
		"di", "danh":
			return "%s %s %s" % [ScenarioRunner.UNIT_NAMES.get(step.general, "?"), "đi" if step.kind == "di" else "đánh",
				BoardText.cell_text(step.cell)]
		"muu_ke":
			return "mưu kế %s" % Stratagem.name_of(step.stratagem)
	return "kết thúc lượt"
