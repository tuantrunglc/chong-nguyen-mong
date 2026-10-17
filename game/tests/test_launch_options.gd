extends GutTest
## Đọc tham số khởi động: --dev, --tran=N (desktop) và ?dev=1&tran=N (web).


func _desktop(args: Array[String]) -> LaunchOptions:
	return LaunchOptions.parse(PackedStringArray(args), "")


func _web(query: String) -> LaunchOptions:
	return LaunchOptions.parse(PackedStringArray(), query)


func _assert_options(o: LaunchOptions, dev: bool, tran: int, warnings: Array[String]) -> void:
	assert_eq(o.dev, dev, "dev")
	assert_eq(o.tran, tran, "tran")
	assert_eq(o.warnings, warnings, "warnings")


func test_no_args_gives_defaults() -> void:
	_assert_options(_desktop([]), false, 0, [])


func test_dev_flag() -> void:
	_assert_options(_desktop(["--dev"]), true, 0, [])


func test_tran_value() -> void:
	_assert_options(_desktop(["--tran=3"]), false, 3, [])


func test_dev_and_tran() -> void:
	_assert_options(_desktop(["--dev", "--tran=3"]), true, 3, [])


func test_tran_not_a_number() -> void:
	_assert_options(_desktop(["--tran=abc"]), false, 0,
		['tham số --tran không hợp lệ: "abc", cần số nguyên từ 1'])


func test_tran_zero() -> void:
	_assert_options(_desktop(["--tran=0"]), false, 0,
		['tham số --tran không hợp lệ: "0", cần số nguyên từ 1'])


func test_tran_negative() -> void:
	_assert_options(_desktop(["--tran=-2"]), false, 0,
		['tham số --tran không hợp lệ: "-2", cần số nguyên từ 1'])


func test_tran_decimal() -> void:
	_assert_options(_desktop(["--tran=3.5"]), false, 0,
		['tham số --tran không hợp lệ: "3.5", cần số nguyên từ 1'])


func test_tran_empty() -> void:
	_assert_options(_desktop(["--tran="]), false, 0,
		['tham số --tran không hợp lệ: "", cần số nguyên từ 1'])


func test_last_valid_tran_wins() -> void:
	_assert_options(_desktop(["--tran=2", "--tran=4"]), false, 4, [])


func test_invalid_tran_keeps_previous_value() -> void:
	_assert_options(_desktop(["--tran=4", "--tran=abc"]), false, 4,
		['tham số --tran không hợp lệ: "abc", cần số nguyên từ 1'])


func test_unknown_arg() -> void:
	_assert_options(_desktop(["--xyz"]), false, 0, ['bỏ qua tham số lạ: "--xyz"'])


func test_dev_with_value_is_unknown() -> void:
	_assert_options(_desktop(["--dev=1"]), false, 0, ['bỏ qua tham số lạ: "--dev=1"'])


func test_tran_with_space_is_unknown() -> void:
	_assert_options(_desktop(["--tran", "3"]), false, 0,
		['bỏ qua tham số lạ: "--tran"', 'bỏ qua tham số lạ: "3"'])


func test_web_dev_and_tran() -> void:
	_assert_options(_web("?dev=1&tran=3"), true, 3, [])


func test_web_without_question_mark() -> void:
	_assert_options(_web("dev=1"), true, 0, [])


func test_web_dev_zero_is_off() -> void:
	_assert_options(_web("?dev=0"), false, 0, [])


func test_web_last_dev_value_wins() -> void:
	_assert_options(_web("?dev=1&dev=0"), false, 0, [])


func test_web_tran_not_a_number() -> void:
	_assert_options(_web("?tran=x"), false, 0,
		['tham số ?tran không hợp lệ: "x", cần số nguyên từ 1'])


func test_web_unknown_key() -> void:
	_assert_options(_web("?foo=1"), false, 0, ['bỏ qua tham số lạ trên URL: "foo"'])


func test_web_value_is_uri_decoded() -> void:
	_assert_options(_web("?tran=%33"), false, 3, [])


func test_web_empty_pairs_are_ignored() -> void:
	_assert_options(_web("?&&dev=1&"), true, 0, [])


func test_tran_without_dev_is_dropped() -> void:
	var o: LaunchOptions = _desktop(["--tran=3"])
	o.require_dev_for_tran()
	_assert_options(o, false, 0, ["bỏ qua tran=3 vì chưa bật dev"])


func test_tran_with_dev_is_kept() -> void:
	var o: LaunchOptions = _desktop(["--dev", "--tran=3"])
	o.require_dev_for_tran()
	_assert_options(o, true, 3, [])


func test_no_tran_without_dev_gives_no_warning() -> void:
	var o: LaunchOptions = _desktop([])
	o.require_dev_for_tran()
	_assert_options(o, false, 0, [])
