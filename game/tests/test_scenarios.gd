extends GutTest
## Chạy mọi kịch bản luật trong tests/kich_ban/ với chỉ số thật (data/chi_so.json).
## Đã duyệt mà trượt thì test trượt. Chưa duyệt thì chỉ chạy và ghi kết quả (Story 1.3, AC 4).
## Có biến môi trường KET_QUA_KICH_BAN thì ghi kết quả từng kịch bản vào file đó cho tools/test.sh,
## mỗi kịch bản một dòng: <da_duyet|chua_duyet|sai_dinh_dang>\t<dat|truot>\t<id>\t<lý do đầu tiên, nếu có>.

const ROOT: String = "res://tests/kich_ban"
const STATS_PATH: String = "res://data/chi_so.json"
const RESULT_ENV: String = "KET_QUA_KICH_BAN"


func _stats() -> Stats:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(r.errors, [] as Array[String], "chi_so.json nạp được")
	return r.data as Stats


func test_every_scenario_loads() -> void:
	var stats: Stats = _stats()
	if stats == null:
		return
	var files: Array[String] = ScenarioLoader.list_files(ROOT)
	assert_gt(files.size(), 0, "có ít nhất một kịch bản trong tests/kich_ban")
	for path: String in files:
		var r: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		# Một dòng, đủ cả câu: assert_eq trên mảng bị GUT cắt giữa câu lỗi.
		assert_true(r.ok, "; ".join(r.errors))


func test_approved_scenarios_pass() -> void:
	var stats: Stats = _stats()
	if stats == null:
		return
	var lines: PackedStringArray = PackedStringArray()
	var approved: int = 0
	for path: String in ScenarioLoader.list_files(ROOT):
		var r: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		if not r.ok:
			# test_every_scenario_loads đã làm trượt; ở đây chỉ ghi để tóm tắt vẫn đếm file này.
			var errors: Array[String] = []
			for message: String in r.errors:
				errors.append(message.trim_prefix(JsonFile.label(path) + ": "))  # tên file đã có ở cột id
			lines.append(_result_line("sai_dinh_dang", false, path.trim_prefix(ROOT + "/"), errors))
			continue
		var scenario: ScenarioData = r.data as ScenarioData
		var result: ScenarioRunner.ScenarioResult = ScenarioRunner.run(scenario, stats)
		lines.append(_result_line("da_duyet" if scenario.approved else "chua_duyet", result.passed,
			scenario.id, result.problems))
		if scenario.approved:
			approved += 1
			# Một dòng: tóm tắt của tools/test.sh chỉ in dòng đầu của thông điệp.
			assert_true(result.passed, "kịch bản đã duyệt %s: %s" % [scenario.id, "; ".join(result.problems)])
	if approved == 0:
		pass_test("chưa có kịch bản đã duyệt")
	_write_results(lines)


## Lý do là câu đầu tiên, bỏ tab và xuống dòng để giữ đúng một dòng bốn cột.
static func _result_line(status: String, passed: bool, id: String, problems: Array[String]) -> String:
	var reason: String = problems[0] if not problems.is_empty() else ""
	reason = reason.replace("\t", " ").replace("\n", " ")
	return "%s\t%s\t%s\t%s" % [status, "dat" if passed else "truot", id, reason]


func _write_results(lines: PackedStringArray) -> void:
	var path: String = OS.get_environment(RESULT_ENV)
	if path.is_empty():
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "ghi được file kết quả kịch bản: " + path)
	if file == null:
		return
	for line: String in lines:
		file.store_line(line)
	file.close()
