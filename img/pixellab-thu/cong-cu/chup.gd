extends SceneTree
## Script tạm: chạy main.tscn có cửa sổ, gửi input thật qua Input.parse_input_event, lưu ảnh.
## Tham số sau "--": --dev --tran=... --out=<thư mục> --steps=...
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
	for i: int in range(40):
		await process_frame
	var main: Node = current_scene
	var board: Node2D = main.get("_board_view") as Node2D
	print("[chup] board.position=", board.position, " board_rect=", board.call("board_rect"))
	for step: String in steps:
		var p: PackedStringArray = step.split(":")
		match p[0]:
			"wait":
				var frames: int = int(p[1]) if p.size() > 1 else 10
				for i: int in range(frames):
					await process_frame
			"shot":
				for i: int in range(5):
					await process_frame
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
					Input.parse_input_event(ev)
					await process_frame
			"key":
				for pressed: bool in [true, false]:
					var k: InputEventKey = InputEventKey.new()
					k.physical_keycode = OS.find_keycode_from_string(p[1])
					k.keycode = k.physical_keycode
					k.pressed = pressed
					Input.parse_input_event(k)
					await process_frame
			"dismiss_hint":
				var hp: Node = main.get("_hint_panel")
				if hp != null and hp.has_method("hide_panel"):
					hp.call("hide_panel")
				for i: int in range(10):
					await process_frame
			"help":
				main.call("_show_help")
				for i: int in range(20):
					await process_frame
			"win":
				var hp_win: Node = main.get("_hint_panel")
				if hp_win != null and hp_win.has_method("hide_panel"):
					hp_win.call("hide_panel")
				var banner: Node = main.get("_result_banner")
				if banner != null:
					banner.call("show_result", BattleState.Phase.WON, "", false)
				for i: int in range(25):
					await process_frame
			"lose":
				var hp_lose: Node = main.get("_hint_panel")
				if hp_lose != null and hp_lose.has_method("hide_panel"):
					hp_lose.call("hide_panel")
				var banner: Node = main.get("_result_banner")
				if banner != null:
					banner.call("show_result", BattleState.Phase.LOST, "het_hiep", false)
				for i: int in range(25):
					await process_frame
			"hover_btn":
				var hud_node: Node = main.get("_hud")
				var btn: Button = null
				match p[1]:
					"end_turn": btn = hud_node.get("_end_turn_button") as Button
					"replay": btn = hud_node.get("_replay_button") as Button
					"undo": btn = hud_node.get("_undo_button") as Button
					"fast": btn = hud_node.get("_fast_button") as Button
					"help": btn = hud_node.get("_help_button") as Button
				if btn != null:
					var center: Vector2 = btn.global_position + btn.size / 2.0
					print("[chup] hover_btn ", p[1], " tại ", center)
					root.warp_mouse(center)
					var m: InputEventMouseMotion = InputEventMouseMotion.new()
					m.position = center
					m.global_position = center
					Input.parse_input_event(m)
					for i: int in range(25):
						await process_frame
			"hover_token":
				var cell: Vector2i = Vector2i(int(p[1]), int(p[2]))
				var state: BattleState = (main.get("_controller") as BattleController).snapshot()
				var lift: float = BoardView.surface_height(state.terrain_at(cell))
				var local_coin: Vector2 = BoardView.cell_center(cell) - Vector2(0.0, lift + UnitToken.TOKEN_LIFT)
				var at: Vector2 = board.get_global_transform_with_canvas() * local_coin
				print("[chup] hover_token ", cell, " tại ", at)
				root.warp_mouse(at)
				var m: InputEventMouseMotion = InputEventMouseMotion.new()
				m.position = at
				m.global_position = at
				Input.parse_input_event(m)
				for i: int in range(25):
					await process_frame
				var tt: Node = main.get("_tooltip")
				if tt != null:
					print("[chup] tooltip text:\n", tt.call("text"))
			"hover_pos":
				var pos: Vector2 = Vector2(float(p[1]), float(p[2]))
				root.warp_mouse(pos)
				var m: InputEventMouseMotion = InputEventMouseMotion.new()
				m.position = pos
				m.global_position = pos
				Input.parse_input_event(m)
				for i: int in range(20):
					await process_frame
			"click_pos":
				var pos: Vector2 = Vector2(float(p[1]), float(p[2]))
				root.warp_mouse(pos)
				for pressed: bool in [true, false]:
					var b: InputEventMouseButton = InputEventMouseButton.new()
					b.button_index = MOUSE_BUTTON_LEFT
					b.pressed = pressed
					b.position = pos
					b.global_position = pos
					Input.parse_input_event(b)
					await process_frame
				for i: int in range(15):
					await process_frame
			"hover":
				var cell: Vector2i = Vector2i(int(p[1]), int(p[2]))
				var at: Vector2 = board.get_global_transform_with_canvas() * BoardView.cell_center(cell)
				print("[chup] hover ", cell, " tại ", at)
				root.warp_mouse(at)
				var m: InputEventMouseMotion = InputEventMouseMotion.new()
				m.position = at
				m.global_position = at
				Input.parse_input_event(m)
				for i: int in range(25):
					await process_frame
			"click":
				var cell: Vector2i = Vector2i(int(p[1]), int(p[2]))
				var at: Vector2 = board.get_global_transform_with_canvas() * BoardView.cell_center(cell)
				print("[chup] click ", cell, " tại ", at)
				root.warp_mouse(at)
				for pressed: bool in [true, false]:
					var b: InputEventMouseButton = InputEventMouseButton.new()
					b.button_index = MOUSE_BUTTON_LEFT
					b.pressed = pressed
					b.position = at
					b.global_position = at
					Input.parse_input_event(b)
					await process_frame
				for i: int in range(15):
					await process_frame
		for i: int in range(5):
			await process_frame
	quit()
