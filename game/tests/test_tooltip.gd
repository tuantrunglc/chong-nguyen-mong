extends GutTest
## Khung thông tin khi rê chuột phải gọn: ngắn lại khi nội dung ngắn lại (sửa lỗi cột đen cao đè lên bàn, 2026-11-01).

const LONG_TEXT: String = "Nguyễn Khoái\nMáu 3/3\nĐánh ô 2,1, đòn số 1\nĐánh ô 3,1, đòn số 2\nĐánh ô 4,1, đòn số 3\nĐánh ô 5,1, đòn số 4"
const SHORT_TEXT: String = "Đồng bằng\nKhông có hiệu ứng"
## Hai dòng chữ cỡ mặc định cộng lề và viền: dưới mức này là gọn, cột lỗi cao hàng trăm px.
const MAX_SHORT_HEIGHT: float = 90.0


func _tooltip() -> Tooltip:
	var tip: Tooltip = Tooltip.new()
	add_child_autofree(tip)
	return tip


func test_short_text_after_long_text_is_compact() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text(LONG_TEXT)
	await get_tree().process_frame
	tip.show_text(SHORT_TEXT)
	await get_tree().process_frame
	assert_lt(tip.size.y, MAX_SHORT_HEIGHT, "khung %s phải gọn sau khi nội dung ngắn lại" % tip.size)


func test_first_short_text_is_compact() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text(SHORT_TEXT)
	await get_tree().process_frame
	assert_lt(tip.size.y, MAX_SHORT_HEIGHT, "khung %s" % tip.size)
	assert_lt(tip.size.x, Tooltip.MAX_WIDTH + 1.0, "bề rộng không quá giới hạn")


## Dòng dài hơn bề rộng tối đa thì tự xuống dòng, khung vẫn không thành cột.
func test_long_line_wraps_into_a_reasonable_box() -> void:
	var tip: Tooltip = _tooltip()
	tip.show_text("Đòn của quân Nguyên này sẽ đánh vào ô có tướng của bạn đang đứng, nên hãy đẩy nó đi chỗ khác trước khi hết lượt")
	await get_tree().process_frame
	assert_lt(tip.size.y, 200.0, "khung %s" % tip.size)
	assert_lt(tip.size.x, Tooltip.MAX_WIDTH + 1.0)
