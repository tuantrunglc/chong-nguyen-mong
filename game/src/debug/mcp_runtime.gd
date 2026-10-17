class_name McpRuntime
extends RefCounted
## Bật cổng 7777 cho GoPeak (công cụ AI chụp màn hình, bơm input) khi chạy bản desktop có bật dev.
## Không dùng autoload: gắn node làm con của màn hình gốc. Bản web không có addon (preset loại trừ).

const SCRIPT_PATH: String = "res://addons/godot_mcp_runtime/mcp_runtime_autoload.gd"


static func should_start(dev: bool, is_web: bool, is_headless: bool) -> bool:
	return dev and not is_web and not is_headless


## Gắn node runtime vào parent nếu đủ điều kiện. Trả về true nếu đã gắn.
static func start_if_enabled(parent: Node, dev: bool) -> bool:
	if not should_start(dev, OS.has_feature("web"), DisplayServer.get_name() == "headless"):
		return false
	if not ResourceLoader.exists(SCRIPT_PATH):
		Log.warn("mcp", "không thấy addon GoPeak: %s" % SCRIPT_PATH)
		return false
	# load() lúc chạy, không preload(): bản web không có file này.
	var script: GDScript = load(SCRIPT_PATH) as GDScript
	var node: Node = script.new() as Node
	parent.add_child(node)
	Log.info("mcp", "mở cổng 7777 cho GoPeak (chỉ máy này)")
	return true
