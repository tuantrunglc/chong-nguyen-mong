extends GutTest
## Công cụ AI (MCP, Story 0.6): phiên bản ghim trong repo, .mcp.json chỉ gọi script trong tools/.

const GOPEAK_VERSION: String = "2.3.8"
const CONTEXT7_VERSION: String = "4.1.1"


func _repo_path(relative: String) -> String:
	return ProjectSettings.globalize_path("res://").path_join("..").path_join(relative).simplify_path()


func _read_json(relative: String) -> Dictionary:
	var path: String = _repo_path(relative)
	assert_true(FileAccess.file_exists(path), "có %s" % relative)
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_true(data is Dictionary, "%s là JSON object" % relative)
	if data is Dictionary:
		return data as Dictionary
	return {}


func _dict(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value as Dictionary
	return {}


func test_mcp_json_has_exactly_two_servers() -> void:
	var servers: Dictionary = _dict(_read_json(".mcp.json").get("mcpServers"))
	var names: Array = servers.keys()
	names.sort()
	assert_eq(names, ["context7", "gopeak"])


func test_mcp_json_does_not_use_npx() -> void:
	var text: String = FileAccess.get_file_as_string(_repo_path(".mcp.json"))
	assert_ne(text, "", "đọc được .mcp.json")
	assert_false(text.contains("npx"), ".mcp.json không gọi npx")


func test_mcp_servers_run_scripts_in_tools() -> void:
	var servers: Dictionary = _dict(_read_json(".mcp.json").get("mcpServers"))
	for server_name: String in ["gopeak", "context7"]:
		var server: Dictionary = _dict(servers.get(server_name))
		var command: String = str(server.get("command", ""))
		var args: Variant = server.get("args", [])
		var first_arg: String = ""
		if args is Array and not (args as Array).is_empty():
			first_arg = str((args as Array)[0])
		assert_true(command.begins_with("tools/") or first_arg.begins_with("tools/"),
				"%s chạy script trong tools/ (command=%s)" % [server_name, command])


func test_package_json_pins_exact_versions() -> void:
	var deps: Dictionary = _dict(_read_json("tools/mcp/package.json").get("dependencies"))
	assert_eq(deps.get("gopeak"), GOPEAK_VERSION)
	assert_eq(deps.get("@upstash/context7-mcp"), CONTEXT7_VERSION)


func test_package_lock_pins_versions_with_integrity() -> void:
	var packages: Dictionary = _dict(_read_json("tools/mcp/package-lock.json").get("packages"))
	var expected: Dictionary = {
		"node_modules/gopeak": GOPEAK_VERSION,
		"node_modules/@upstash/context7-mcp": CONTEXT7_VERSION,
	}
	for key: String in expected:
		var entry: Dictionary = _dict(packages.get(key))
		assert_eq(entry.get("version"), expected[key], key)
		assert_true(str(entry.get("integrity", "")).begins_with("sha512-"), "%s có integrity" % key)


func test_gopeak_script_uses_compact_profile() -> void:
	var text: String = FileAccess.get_file_as_string(_repo_path("tools/mcp_gopeak.sh"))
	assert_string_contains(text, "GOPEAK_TOOL_PROFILE=\"compact\"")


func test_package_lock_root_matches_package_json() -> void:
	var deps: Dictionary = _dict(_read_json("tools/mcp/package.json").get("dependencies"))
	var root: Dictionary = _dict(_dict(_read_json("tools/mcp/package-lock.json").get("packages")).get(""))
	assert_eq(_dict(root.get("dependencies")), deps, "file khóa sinh từ đúng package.json")


func test_godot_sh_versions_match_pinned() -> void:
	var text: String = FileAccess.get_file_as_string(_repo_path("tools/_godot.sh"))
	assert_string_contains(text, "GOPEAK_VERSION=\"%s\"" % GOPEAK_VERSION)
	assert_string_contains(text, "CONTEXT7_VERSION=\"%s\"" % CONTEXT7_VERSION)
