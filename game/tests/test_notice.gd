extends GutTest
## Thông báo ngắn (Story 2.13): hiện một câu rồi tự ẩn, không nhận chuột, câu sau thay câu trước.

func _notice() -> Notice:
	var notice: Notice = Notice.new()
	add_child_autofree(notice)
	return notice


func test_shows_text_then_hides_itself() -> void:
	var notice: Notice = _notice()
	notice.show_text("Đã sao chép báo lỗi")
	assert_true(notice.is_shown(), "hiện ngay")
	assert_eq(notice.text(), "Đã sao chép báo lỗi")
	await wait_seconds(Notice.SHOW_SECONDS + Notice.FADE_SECONDS + 0.5)
	assert_false(notice.is_shown(), "tự ẩn sau khoảng 3 giây")
	assert_eq(notice.text(), "", "ẩn rồi thì không còn chữ")


func test_empty_text_hides_immediately() -> void:
	var notice: Notice = _notice()
	notice.show_text("một câu")
	notice.show_text("")
	assert_false(notice.is_shown(), "chuỗi rỗng là ẩn")


func test_second_text_replaces_the_first() -> void:
	var notice: Notice = _notice()
	notice.show_text("một")
	notice.show_text("hai")
	assert_eq(notice.text(), "hai", "câu sau thay câu trước")
	assert_eq(notice._panel.get_child_count(), 1, "một nhãn duy nhất, không chồng")


func test_notice_does_not_take_mouse() -> void:
	var notice: Notice = _notice()
	assert_eq(notice.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(notice.get_child(0).mouse_filter, Control.MOUSE_FILTER_IGNORE, "bảng cũng không nhận chuột")
