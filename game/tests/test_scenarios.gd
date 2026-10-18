extends GutTest
## Chạy mọi kịch bản luật trong tests/kich_ban/ với chỉ số thật (data/chi_so.json).
## Đã duyệt mà trượt thì test trượt. Chưa duyệt thì chỉ chạy và ghi kết quả (Story 1.3, AC 4).
## Có biến môi trường KET_QUA_KICH_BAN thì ghi kết quả từng kịch bản vào file đó cho tools/test.sh.

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
		assert_eq(r.errors, [] as Array[String], "nạp được: " + path)


func test_approved_scenarios_pass() -> void:
	var stats: Stats = _stats()
	if stats == null:
		return
	var lines: PackedStringArray = PackedStringArray()
	var approved: int = 0
	for path: String in ScenarioLoader.list_files(ROOT):
		var r: LoadResult = ScenarioLoader.load_scenario(path, ROOT, stats)
		if not r.ok:
			continue  # test_every_scenario_loads đã báo
		var scenario: ScenarioData = r.data as ScenarioData
		var result: ScenarioRunner.ScenarioResult = ScenarioRunner.run(scenario, stats)
		lines.append("%s\t%s\t%s" % ["da_duyet" if scenario.approved else "chua_duyet",
			"dat" if result.passed else "truot", scenario.id])
		if scenario.approved:
			approved += 1
			# Một dòng: tóm tắt của tools/test.sh chỉ in dòng đầu của thông điệp.
			assert_true(result.passed, "kịch bản đã duyệt %s: %s" % [scenario.id, "; ".join(result.problems)])
	if approved == 0:
		pass_test("chưa có kịch bản đã duyệt")
	_write_results(lines)


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
