extends GutTest
## Bộ đếm FPS của chế độ dev (Story 4.7): chữ, min trong cửa sổ, F4 xóa mẫu, chỉ có khi bật dev.

const MAIN_SCENE: String = "res://scenes/main.tscn"


func after_each() -> void:
	AppState.launch.dev = false


func test_format_text() -> void:
	assert_eq(FpsOverlay.format_text(60, 52), "FPS 60 (thấp nhất 52)")


func test_window_min_ignores_samples_older_than_window() -> void:
	var samples: Array[Vector2] = [Vector2(0.0, 20.0), Vector2(6.0, 58.0), Vector2(8.0, 60.0), Vector2(10.0, 55.0)]
	assert_eq(FpsOverlay.window_min(samples, 10.0, 5.0), 55, "mẫu 20 fps ở giây 0 đã quá cửa sổ 5 giây")
	assert_eq(FpsOverlay.window_min(samples, 10.0, 11.0), 20, "cửa sổ rộng thì lấy cả mẫu cũ")
	assert_eq(FpsOverlay.window_min([] as Array[Vector2], 10.0, 5.0, 42), 42, "không có mẫu thì trả giá trị dự phòng")


func test_record_drops_old_samples_and_reset_clears() -> void:
	var overlay: FpsOverlay = FpsOverlay.new()
	add_child_autofree(overlay)
	overlay.record(0.0, 10)
	overlay.record(1.0, 60)
	assert_eq(overlay.text(1.0), "FPS 60 (thấp nhất 10)")
	overlay.record(7.0, 59)
	assert_eq(overlay.text(7.0), "FPS 59 (thấp nhất 59)", "mẫu 10 fps và 60 fps cũ đã trôi khỏi cửa sổ")
	overlay.reset()
	overlay.record(8.0, 61)
	assert_eq(overlay.text(8.0), "FPS 61 (thấp nhất 61)", "F4 quên mẫu cũ")


func test_label_ignores_mouse_and_sits_on_top() -> void:
	var overlay: FpsOverlay = FpsOverlay.new()
	add_child_autofree(overlay)
	assert_eq(overlay.layer, FpsOverlay.LAYER_INDEX)
	var labels: Array[Node] = overlay.get_children().filter(func(n: Node) -> bool: return n is Label)
	assert_eq(labels.size(), 1)
	assert_eq((labels[0] as Label).mouse_filter, Control.MOUSE_FILTER_IGNORE, "bấm xuyên xuống bàn")


func test_main_has_overlay_only_in_dev() -> void:
	AppState.launch.dev = false
	var plain: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	add_child_autofree(plain)
	assert_null(plain._fps_overlay, "không dev thì không dựng bộ đếm")
	AppState.launch.dev = true
	var dev: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	add_child_autofree(dev)
	assert_not_null(dev._fps_overlay)
	assert_true(dev._fps_overlay.is_inside_tree())
