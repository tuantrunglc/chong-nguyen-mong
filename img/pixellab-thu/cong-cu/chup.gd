extends SceneTree
## Script tạm (không thuộc repo): chạy main.tscn có cửa sổ, gửi input thật qua root.push_input, lưu ảnh.
## Tham số sau "--": --dev --tran=... --out=<thư mục> --steps=shot:ten,act:select_general_1,click:c:r,key:Z
var _out: String = ""


func _initialize() -> void:
	_run()


func _run() -> void:
	var steps: PackedStringArray = []
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			_out = a.substr(6)
		elif a.begins_with("--steps="):
			steps = a.substr(8).split(",")
	await process_frame
	change_scene_to_file("res://scenes/main.tscn")
	for i: int in range(30):
		await process_frame
	var main: Node = current_scene
	var board: Node2D = main.get("_board_view") as Node2D
	print("[chup] board.position=", board.position, " board_rect=", board.call("board_rect"))
	for step: String in steps:
		var p: PackedStringArray = step.split(":")
		match p[0]:
			"shot":
				await RenderingServer.frame_post_draw
				await RenderingServer.frame_post_draw
				var path: String = _out + "/" + p[1] + ".png"
				root.get_texture().get_image().save_png(path)
				print("[chup] ", path)
			"act":
				for pressed: bool in [true, false]:
					var ev: InputEventAction = InputEventAction.new()
					ev.action = p[1]
					ev.pressed = pressed
					root.push_input(ev)
					await process_frame
			"key":
				for pressed: bool in [true, false]:
					var k: InputEventKey = InputEventKey.new()
					k.physical_keycode = OS.find_keycode_from_string(p[1])
					k.keycode = k.physical_keycode
					k.pressed = pressed
					root.push_input(k)
					await process_frame
			"click", "hover":
				var cell: Vector2i = Vector2i(int(p[1]), int(p[2]))
				var at: Vector2 = board.get_global_transform_with_canvas() * BoardView.cell_center(cell)
				var m: InputEventMouseMotion = InputEventMouseMotion.new()
				m.position = at
				root.push_input(m)
				await process_frame
				if p[0] == "click":
					print("[chup] click ", cell, " tại ", at)
					for pressed: bool in [true, false]:
						var b: InputEventMouseButton = InputEventMouseButton.new()
						b.button_index = MOUSE_BUTTON_LEFT
						b.pressed = pressed
						b.position = at
						root.push_input(b)
						await process_frame
		for i: int in range(5):
			await process_frame
	quit()
