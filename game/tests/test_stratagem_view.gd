extends GutTest
## Nút mưu kế và phím Q trên màn hình trận (Story 3.12). Luật mưu kế test ở test_stratagem.gd và kịch bản muu_ke/.

const MAIN_SCENE: String = "res://scenes/main.tscn"
const LEVEL_DIR: String = "user://test_stratagem_view"
const LEVEL_FILE: String = LEVEL_DIR + "/tran_01.json"
const VKNT: int = Stratagem.Kind.VUON_KHONG_NHA_TRONG
const KHOAI_CELL: Vector2i = Vector2i(1, 6)


func before_each() -> void:
	DirAccess.make_dir_recursive_absolute(LEVEL_DIR)


func after_each() -> void:
	AppState.stats = null
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


## Trận thử mưu kế (data/tran/thu_muu_ke.json) chép làm trận 1; open = false thì xóa mưu kế mở.
func _make_main(open: bool = true) -> Node2D:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/tran/thu_muu_ke.json"))
	if not open:
		data["muu_ke_mo"] = []
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
	var ev: InputEventKey = InputEventKey.new()
	ev.physical_keycode = KEY_Q
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
