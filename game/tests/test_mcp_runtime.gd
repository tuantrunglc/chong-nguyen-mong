extends GutTest
## Cổng 7777 cho GoPeak (Story 0.6): chỉ mở khi bật dev, trên desktop, có cửa sổ; chỉ nghe máy này.
## Không thêm autoload thứ hai: addon gắn làm node con, không có plugin.cfg để ai bật plugin.

const ADDON_DIR: String = "res://addons/godot_mcp_runtime"


func test_should_start_only_with_dev_on_desktop_debug_build_with_window() -> void:
	# Chỉ đúng một tổ hợp được mở cổng: dev, không web, có cửa sổ, bản debug.
	for dev: bool in [false, true]:
		for is_web: bool in [false, true]:
			for is_headless: bool in [false, true]:
				for is_debug: bool in [false, true]:
					var combo: Array = [dev, is_web, is_headless, is_debug]
					assert_eq(McpRuntime.should_start(dev, is_web, is_headless, is_debug),
							combo == [true, false, false, true],
							"dev=%s web=%s headless=%s debug=%s" % combo)


func test_release_build_never_starts_even_with_dev() -> void:
	assert_false(McpRuntime.should_start(true, false, false, false))


func test_does_not_start_without_dev() -> void:
	var parent: Node = add_child_autofree(Node.new()) as Node
	assert_false(McpRuntime.start_if_enabled(parent, false))
	assert_eq(parent.get_child_count(), 0)


func test_does_not_open_port_when_headless_even_with_dev() -> void:
	assert_eq(DisplayServer.get_name(), "headless", "GUT chạy headless")
	var parent: Node = add_child_autofree(Node.new()) as Node
	assert_false(McpRuntime.start_if_enabled(parent, true))
	assert_eq(parent.get_child_count(), 0)


func test_runtime_script_listens_on_localhost_only() -> void:
	assert_true(FileAccess.file_exists(McpRuntime.SCRIPT_PATH), "có file addon runtime")
	var source: String = FileAccess.get_file_as_string(McpRuntime.SCRIPT_PATH)
	assert_string_contains(source, "listen(_port, \"127.0.0.1\")")
	assert_false(source.contains("listen(_port)"), "không còn listen(_port) nghe mọi địa chỉ")


func test_addon_has_no_plugin_cfg() -> void:
	assert_false(FileAccess.file_exists(ADDON_DIR.path_join("plugin.cfg")),
			"không có plugin.cfg (plugin sẽ tự thêm autoload)")


func test_app_state_is_the_only_autoload() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	assert_eq(cfg.load("res://project.godot"), OK)
	assert_eq(cfg.get_section_keys("autoload"), PackedStringArray(["AppState"]))
