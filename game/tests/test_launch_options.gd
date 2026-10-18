extends GutTest
## Đọc tham số khởi động: --dev, --tran=N|tên (desktop) và ?dev=1&tran=N|tên (web).

const BAD: String = 'tham số %s không hợp lệ: "%s", cần số từ 1 hoặc tên file trận (chữ thường không dấu, số, dấu _)'


func _desktop(args: Array[String]) -> LaunchOptions:
	return LaunchOptions.parse(PackedStringArray(args), "")


func _web(query: String) -> LaunchOptions:
	return LaunchOptions.parse(PackedStringArray(), query)


func _assert_options(o: LaunchOptions, dev: bool, tran: String, warnings: Array[String]) -> void:
	assert_eq(o.dev, dev, "dev")
	assert_eq(o.tran, tran, "tran")
	assert_eq(o.warnings, warnings, "warnings")


func _bad(flag: String, value: String) -> Array[String]:
	return [BAD % [flag, value]] as Array[String]


func test_no_args_gives_defaults() -> void:
	_assert_options(_desktop([]), false, "", [])


func test_dev_flag() -> void:
	_assert_options(_desktop(["--dev"]), true, "", [])


func test_tran_value() -> void:
	_assert_options(_desktop(["--tran=3"]), false, "3", [])


func test_tran_number_is_normalized() -> void:
	_assert_options(_desktop(["--tran=03"]), false, "3", [])


func test_dev_and_tran() -> void:
	_assert_options(_desktop(["--dev", "--tran=3"]), true, "3", [])


func test_tran_name() -> void:
	_assert_options(_desktop(["--tran=thu_ba_tuong"]), false, "thu_ba_tuong", [])
	_assert_options(_desktop(["--tran=abc"]), false, "abc", [])
	_assert_options(_desktop(["--tran=tran2"]), false, "tran2", [])


func test_tran_invalid_values() -> void:
	for value: String in ["Thu", "../x", "thu-ba", "tên", "1abc", "0", "-2", "3.5", "", "a b",
			"thu_ba_tuong\n", "99999999999999999999", "00001"]:
		_assert_options(_desktop(["--tran=" + value]), false, "", _bad("--tran", value))


func test_last_valid_tran_wins() -> void:
	_assert_options(_desktop(["--tran=2", "--tran=4"]), false, "4", [])


func test_invalid_tran_keeps_previous_value() -> void:
	_assert_options(_desktop(["--tran=4", "--tran=Abc"]), false, "4", _bad("--tran", "Abc"))


func test_unknown_arg() -> void:
	_assert_options(_desktop(["--xyz"]), false, "", ['bỏ qua tham số lạ: "--xyz"'])


func test_dev_with_value_is_unknown() -> void:
	_assert_options(_desktop(["--dev=1"]), false, "", ['bỏ qua tham số lạ: "--dev=1"'])


func test_tran_with_space_is_unknown() -> void:
	_assert_options(_desktop(["--tran", "3"]), false, "",
		['bỏ qua tham số lạ: "--tran"', 'bỏ qua tham số lạ: "3"'])


func test_web_dev_and_tran() -> void:
	_assert_options(_web("?dev=1&tran=3"), true, "3", [])


func test_web_tran_name() -> void:
	_assert_options(_web("?dev=1&tran=thu_ba_tuong"), true, "thu_ba_tuong", [])


func test_web_tran_name_with_encoded_newline_is_invalid() -> void:
	_assert_options(_web("?dev=1&tran=thu_ba_tuong%0A"), true, "", _bad("?tran", "thu_ba_tuong\n"))


func test_web_without_question_mark() -> void:
	_assert_options(_web("dev=1"), true, "", [])


func test_web_dev_zero_is_off() -> void:
	_assert_options(_web("?dev=0"), false, "", [])


func test_web_last_dev_value_wins() -> void:
	_assert_options(_web("?dev=1&dev=0"), false, "", [])


func test_web_tran_invalid() -> void:
	_assert_options(_web("?tran=X"), false, "", _bad("?tran", "X"))


func test_web_unknown_key() -> void:
	_assert_options(_web("?foo=1"), false, "", ['bỏ qua tham số lạ trên URL: "foo"'])


func test_web_value_is_uri_decoded() -> void:
	_assert_options(_web("?tran=%33"), false, "3", [])
	_assert_options(_web("?tran=%2E%2E%2Fx"), false, "", _bad("?tran", "../x"))


func test_web_empty_pairs_are_ignored() -> void:
	_assert_options(_web("?&&dev=1&"), true, "", [])


func test_tran_without_dev_is_dropped() -> void:
	var o: LaunchOptions = _desktop(["--tran=3"])
	o.require_dev_for_tran()
	_assert_options(o, false, "", ["bỏ qua tran=3 vì chưa bật dev"])


func test_tran_name_without_dev_is_dropped() -> void:
	var o: LaunchOptions = _desktop(["--tran=thu_ba_tuong"])
	o.require_dev_for_tran()
	_assert_options(o, false, "", ["bỏ qua tran=thu_ba_tuong vì chưa bật dev"])


func test_tran_with_dev_is_kept() -> void:
	var o: LaunchOptions = _desktop(["--dev", "--tran=3"])
	o.require_dev_for_tran()
	_assert_options(o, true, "3", [])


func test_no_tran_without_dev_gives_no_warning() -> void:
	var o: LaunchOptions = _desktop([])
	o.require_dev_for_tran()
	_assert_options(o, false, "", [])


func test_level_id() -> void:
	assert_eq(_desktop([]).level_id(), "")
	assert_eq(_desktop(["--tran=1"]).level_id(), "tran_01")
	assert_eq(_desktop(["--tran=12"]).level_id(), "tran_12")
	assert_eq(_desktop(["--tran=123"]).level_id(), "tran_123")
	assert_eq(_desktop(["--tran=thu_ba_tuong"]).level_id(), "thu_ba_tuong")
