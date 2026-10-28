extends GutTest
## Nút mưu kế và phím Q, W trên màn hình trận (Story 3.12–3.13). Luật mưu kế test ở test_stratagem.gd và kịch bản muu_ke/.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const LEVEL_DIR: String = "user://test_stratagem_view"
const LEVEL_FILE: String = LEVEL_DIR + "/tran_01.json"
const VKNT: int = Stratagem.Kind.VUON_KHONG_NHA_TRONG
const SAT_THAT: int = Stratagem.Kind.SAT_THAT
const KHOAI_CELL: Vector2i = Vector2i(1, 6)


func before_each() -> void:
	# Story 4.1: không chọn trận thì mở màn hình chính; test trận vào thẳng trận 1 (test màn hình chính đặt lại "").
	AppState.launch.tran = "1"
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)


func after_each() -> void:
	AppState.stats = null
	AppState.launch.tran = ""
	for action: String in BattleInput.ACTION_KEYS:
		if InputMap.has_action(action):
			InputMap.erase_action(action)
	for slot: Array in Stratagem.SLOTS:
		if InputMap.has_action(slot[1] as String):
			InputMap.erase_action(slot[1] as String)
	if FileAccess.file_exists(LEVEL_FILE):
		DirAccess.remove_absolute(LEVEL_FILE)
	DirAccess.remove_absolute(LEVEL_DIR)
	Log.clear()


## Trận thử mưu kế (data/tran/thu_muu_ke.json, mở cả hai mưu kế) chép làm trận 1; open = false thì xóa mưu kế mở;
## open_names khác rỗng thì thay "muu_ke_mo" bằng danh sách đó.
func _make_main(open: bool = true, open_names: Array = []) -> Node2D:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/tran/thu_muu_ke.json"))
	if not open:
		data["muu_ke_mo"] = []
	elif not open_names.is_empty():
		data["muu_ke_mo"] = open_names
	var file: FileAccess = FileAccess.open(LEVEL_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	var main: Node2D = (load(MAIN_SCENE) as PackedScene).instantiate() as Node2D
	main.level_dir = LEVEL_DIR
	add_child_autofree(main)
	return main


func _hud(main: Node2D) -> Hud:
	return main._hud as Hud


func _controller(main: Node2D) -> BattleController:
	return main._controller as BattleController


## Lệnh bị luật từ chối trong hiệp (F2 ghi cả lệnh bị từ chối): giao diện phải chặn trước, không gửi xuống luật.
func _rejected_commands(main: Node2D) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for entry: Dictionary in _controller(main).round_commands():
		if int(entry.get("tu_choi", BattleEvent.Reject.NONE)) != BattleEvent.Reject.NONE:
			out.append(entry)
	return out


func _press_q(main: Node2D) -> void:
	_press(main, KEY_Q)


func _press(main: Node2D, key: Key) -> void:
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = key
	ev.pressed = true
	(main._battle_input as BattleInput)._unhandled_input(ev)


func test_button_shown_only_when_level_opens_stratagem() -> void:
	var main: Node2D = _make_main()
	var button: Button = _hud(main).stratagem_button(VKNT)
	assert_not_null(button, "trận mở mưu kế thì có nút")
	assert_eq(button.text, tr("hud.stratagem.vuon_khong_nha_trong"))
	assert_false(button.disabled)


func test_locked_stratagem_has_no_button_and_q_does_nothing() -> void:
	var main: Node2D = _make_main(false)
	assert_null(_hud(main).stratagem_button(VKNT), "mưu kế khóa thì không hiện nút")
	_press_q(main)
	assert_eq(_controller(main).stratagems_used(), [] as Array[int])
	assert_eq(_rejected_commands(main), [] as Array[Dictionary], "Q bị chặn ở giao diện, không gửi lệnh xuống luật")


func test_button_uses_stratagem_once_then_dims() -> void:
	var main: Node2D = _make_main()
	var button: Button = _hud(main).stratagem_button(VKNT)
	button.pressed.emit()
	var snapshot: BattleState = _controller(main).snapshot()
	assert_eq(snapshot.stratagems_used, [VKNT] as Array[int])
	assert_eq(snapshot.terrain_at(Vector2i(1, 1)), Terrain.PLAIN, "kho lương đã đốt")
	assert_true(button.disabled, "dùng rồi thì mờ")
	assert_eq(button.text, tr("hud.stratagem.used") % tr("stratagem.vuon_khong_nha_trong"))
	_press_q(main)
	assert_eq(_controller(main).snapshot().unit_by_id(101).hp, 2, "Q lần hai không trừ máu nữa")
	assert_eq(_rejected_commands(main), [] as Array[Dictionary], "Q lần hai bị chặn ở giao diện")


func test_q_key_uses_stratagem() -> void:
	var main: Node2D = _make_main()
	_press_q(main)
	assert_eq(_controller(main).stratagems_used(), [VKNT] as Array[int])
	assert_true(InputMap.has_action("stratagem_1"), "phím Q khai báo trong InputMap")


## Tác giả chốt 2026-10-27: dùng mưu kế không bỏ chọn tướng.
func test_selected_general_stays_selected() -> void:
	var main: Node2D = _make_main()
	var view: BattleView = main._battle_view as BattleView
	view._on_cell_clicked(KHOAI_CELL)
	assert_eq(view.selected_id(), 1)
	_press_q(main)
	assert_eq(view.selected_id(), 1)


## Chơi lại hiệp trả lại mưu kế: nút sáng lại.
func test_replay_re_enables_button() -> void:
	var main: Node2D = _make_main()
	_press_q(main)
	_hud(main).replay_button().pressed.emit()
	var button: Button = _hud(main).stratagem_button(VKNT)
	assert_false(button.disabled)
	assert_eq(button.text, tr("hud.stratagem.vuon_khong_nha_trong"))


## Story 3.13: nút Q nằm trên nút W, kể cả khi file trận ghi Sát Thát trước (tác giả chốt 2026-10-27).
func test_buttons_follow_key_order() -> void:
	var main: Node2D = _make_main(true, ["sat_that", "vuon_khong_nha_trong"])
	var q: Button = _hud(main).stratagem_button(VKNT)
	var w: Button = _hud(main).stratagem_button(SAT_THAT)
	assert_not_null(w)
	assert_eq(w.text, tr("hud.stratagem.sat_that"))
	assert_lt(q.get_index(), w.get_index(), "nút Q trên nút W")


## Phím W dùng Sát Thát; trong lượt đó nút mờ và ghi đang +1 sát thương; sang hiệp sau ghi đã dùng.
func test_w_key_uses_sat_that_and_button_shows_active_then_used() -> void:
	var main: Node2D = _make_main()
	_press(main, KEY_W)
	assert_true(InputMap.has_action("stratagem_2"), "phím W khai báo trong InputMap")
	assert_eq(_controller(main).stratagems_used(), [SAT_THAT] as Array[int])
	var button: Button = _hud(main).stratagem_button(SAT_THAT)
	assert_true(button.disabled)
	assert_eq(button.text, tr("hud.stratagem.active") % [tr("stratagem.sat_that"), 1])
	_hud(main).end_turn_button().pressed.emit()
	assert_eq(_controller(main).snapshot().round_number, 2)
	assert_eq(button.text, tr("hud.stratagem.used") % tr("stratagem.sat_that"))
	assert_true(button.disabled)


## Trận không mở Sát Thát: không có nút, W không gửi lệnh nào xuống luật.
func test_locked_sat_that_has_no_button_and_w_does_nothing() -> void:
	var main: Node2D = _make_main(true, ["vuon_khong_nha_trong"])
	assert_null(_hud(main).stratagem_button(SAT_THAT))
	_press(main, KEY_W)
	assert_eq(_controller(main).stratagems_used(), [] as Array[int])
	assert_eq(_rejected_commands(main), [] as Array[Dictionary], "W bị chặn ở giao diện")
