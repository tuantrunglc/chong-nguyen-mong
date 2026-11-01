extends GutTest
## Lời giải 6 trận (Story 4.6): mỗi lời giải đã ghi chạy lại từ file trận thật với chỉ số THẬT (data/chi_so.json),
## để tác giả sửa chỉ số rồi biết ngay trận nào còn thắng không mất tướng. Không so máu, ô hay số hiệp.
## Có biến môi trường KET_QUA_LOI_GIAI thì ghi mỗi trận một dòng cho tools/test.sh: <dat|truot>\t<câu tóm tắt>.
## Có KET_QUA_CHI_SO thì ghi các chỗ chỉ số thật khác bản chụp của kịch bản luật (mỗi chỗ một dòng).

const CAMPAIGN_PATH: String = "res://data/chien_dich.json"
const STATS_PATH: String = "res://data/chi_so.json"
const RESULT_ENV: String = "KET_QUA_LOI_GIAI"
const STATS_DIFF_ENV: String = "KET_QUA_CHI_SO"


func _stats_text() -> String:
	return FileAccess.get_file_as_string(StatsSnapshot.PATH)


## Bản chụp chỉ số với một chỗ sửa: group/name/key là đường khóa trong chi_so.json. Không ghi file nào.
## Dựng từ bản chụp chứ không từ số thật: tác giả sửa số thật thì các ca đột biến dưới đây vẫn đúng.
func _mutated_stats(group: String, name: String, key: String, value: int) -> Stats:
	var root: Dictionary = JSON.parse_string(_stats_text()) as Dictionary
	((root[group] as Dictionary)[name] as Dictionary)[key] = value
	var r: LoadResult = StatsLoader.parse_stats(JSON.stringify(root), "chi_so_dot_bien")
	assert_eq(r.errors, [] as Array[String], "chỉ số đột biến nạp được")
	return r.data as Stats


func _real_stats() -> Stats:
	var r: LoadResult = StatsLoader.load_stats(STATS_PATH)
	assert_eq(r.errors, [] as Array[String], "chi_so.json nạp được")
	return r.data as Stats


func _snapshot_stats() -> Stats:
	var r: LoadResult = StatsSnapshot.load_stats()
	assert_eq(r.errors, [] as Array[String], "bản chụp chỉ số nạp được")
	return r.data as Stats


func test_every_campaign_solution_still_wins() -> void:
	var stats: Stats = _real_stats()
	if stats == null:
		return
	var outcomes: Array[SolutionCheck.Outcome] = SolutionCheck.check_campaign(CAMPAIGN_PATH, stats)
	assert_eq(outcomes.size(), 6, "chuỗi có 6 trận")
	var lines: PackedStringArray = PackedStringArray()
	for o: SolutionCheck.Outcome in outcomes:
		lines.append("%s\t%s" % ["dat" if o.passed else "truot", o.summary().replace("\t", " ").replace("\n", " ")])
		# Một dòng: tóm tắt của tools/test.sh chỉ in dòng đầu của thông điệp.
		assert_true(o.passed, "lời giải %s" % o.summary())
	_write_lines(RESULT_ENV, lines)


func test_stats_diff_lists_changed_values() -> void:
	var snapshot: Dictionary = {"tuong": {"nguyen_khoai": {"mau": 3.0, "sat_thuong": 2.0}}, "muu_ke": {"x": {"a": 1.0}}}
	assert_eq(StatsSnapshot.diff_values(snapshot, snapshot.duplicate(true)), [] as Array[String], "giống hệt thì rỗng")
	var real: Dictionary = {"tuong": {"nguyen_khoai": {"mau": 3.0, "sat_thuong": 3.0}}, "muu_ke": {"x": {}}}
	assert_eq(StatsSnapshot.diff_values(snapshot, real), [
		"muu_ke.x.a: kịch bản 1, thật không có",
		"tuong.nguyen_khoai.sat_thuong: kịch bản 2, thật 3",
	] as Array[String])


func test_stats_diff_is_reported() -> void:
	_write_lines(STATS_DIFF_ENV, PackedStringArray(StatsSnapshot.differences()))
	pass_test("đã ghi khác biệt chỉ số (nếu có)")


## Ca (a): Khoái chỉ đi được 1 ô thì nước đi đầu của lời giải trận 1 bị từ chối.
func test_reports_rejected_step() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_01", _mutated_stats("tuong", "nguyen_khoai", "tam_di", 1))
	assert_false(o.passed)
	assert_string_contains(o.reason, "bị từ chối")
	assert_string_contains(o.reason, "bước 1")


## Ca (b): Kỵ binh 5 máu thì hiệp 1 trận 6 không hạ được Kỵ binh 8,5, nó phi vào ải 8,7 đầu hiệp 2.
func test_reports_lost_battle() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_06", _mutated_stats("quan_nguyen", "ky_binh", "mau", 5))
	assert_false(o.passed)
	assert_eq(o.reason, "thua ở hiệp 2 (%s)" % tr("result.lost_pass"))


## Ca (c): Cung kỵ 4 máu thì trận 5 vẫn thắng nhưng Lão gục ở hiệp 5: thắng mà mất tướng vẫn là trượt.
func test_reports_general_lost_even_when_won() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_05", _mutated_stats("quan_nguyen", "cung_ky", "mau", 4))
	assert_false(o.passed, o.summary())
	assert_eq(o.reason, "thắng ở hiệp 5 nhưng Phạm Ngũ Lão gục ở hiệp 5")


## Đổi máu tướng: lời giải vẫn nạp được (kịch bản nạp bằng bản chụp), lỗi là do chơi chứ không phải do nạp.
func test_changed_general_hp_still_loads_solution() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_03", _mutated_stats("tuong", "tran_khanh_du", "mau", 2))
	assert_false(o.reason.contains("không nạp được"), o.summary())


func test_passing_solution_reports_round_and_generals() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_01", _snapshot_stats())
	assert_true(o.passed, o.summary())
	assert_eq(o.reason, "")
	assert_string_contains(o.summary(), "thắng ở hiệp 3")
	assert_string_contains(o.summary(), "đủ 2 tướng")


func test_missing_solution_file_fails_clearly() -> void:
	var o: SolutionCheck.Outcome = SolutionCheck.check("tran_khong_co", _snapshot_stats())
	assert_false(o.passed)
	assert_string_contains(o.reason, "tran_khong_co")


func _write_lines(env: String, lines: PackedStringArray) -> void:
	var path: String = OS.get_environment(env)
	if path.is_empty():
		return
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "ghi được file kết quả: " + path)
	if file == null:
		return
	for line: String in lines:
		file.store_line(line)
	file.close()
