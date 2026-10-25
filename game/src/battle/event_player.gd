class_name EventPlayer
extends Node
## Phát lại nhật ký sự kiện của một lệnh bằng Tween (Story 2.11, NFR3, ADR-002).
## Chỉ đọc `BattleEvent` và bản chụp: KHÔNG gọi `show_state` chen giữa chừng, KHÔNG sửa `BattleState`.
## Lúc `play()` bắt đầu, bàn đang ở trạng thái TRƯỚC lệnh; `BoardView.show_state(snapshot)` gọi sau đó sẽ đưa mọi
## thứ về trạng thái cuối. Vì vậy hoạt ảnh chỉ cần đi từ vị trí đang có tới vị trí mà sự kiện nói.

## Một sự kiện có động tác dài chừng này; cả pha bị co lại nếu vượt `MAX_PHASE_SECONDS`.
const SECONDS_PER_EVENT: float = 0.18
## Trần NFR3 cho trọn một pha địch, canh bằng đồng hồ thật (không phải số học).
const MAX_PHASE_SECONDS: float = 3.0
## Sự kiện có động tác không ngắn hơn mức này, trừ khi ngân sách pha đã cạn.
const MIN_EVENT_SECONDS: float = 0.06
const DAMAGE_SECONDS: float = 0.14
const DEATH_SECONDS: float = 0.22
## Đồng quân lao về phía mục tiêu bao xa (px) rồi về chỗ cũ.
const LUNGE_DISTANCE: float = 12.0
## Rung khi va chạm (px).
const SHAKE_DISTANCE: float = 5.0

## Bật khi chạy không có màn hình (GUT): áp dụng ngay, không chờ khung hình nào, để test không phải await.
var instant: bool = DisplayServer.get_name() == "headless"

var _board: BoardView = null
var _notice: Notice = null
## Sự kiện đã phát, ghi lúc ÁP DỤNG (không phải lúc nhận), đúng thứ tự thực tế (để test).
var _played: Array[BattleEvent] = []
## Mỗi lượt phát một số. Lượt cũ đang chờ timer mà thấy số đã đổi thì bỏ cuộc: F5/đổi trận giữa lúc phát
## không thể phát tiếp nhật ký của trận cũ lên bàn mới.
var _play_id: int = 0
## Tween đang chạy, để `stop()` giết ngay (không để đồng quân trôi tiếp trên bàn vừa vẽ lại).
var _active_tween: Tween = null


func setup(board: BoardView, notice: Notice = null) -> void:
	_board = board
	_notice = notice


func played() -> Array[BattleEvent]:
	return _played


## Ước lượng thời lượng phát của danh sách này, chặn ở `MAX_PHASE_SECONDS`.
## Chỉ để test và để đọc; `play()` tự canh đồng hồ thật nên không phụ thuộc hàm này.
func total_seconds(events: Array[BattleEvent]) -> float:
	var sum: float = 0.0
	for event: BattleEvent in events:
		sum += _base_seconds(event)
	return minf(sum, MAX_PHASE_SECONDS)


## Áp dụng ngay toàn bộ, không Tween (test và chế độ instant).
func play_now(events: Array[BattleEvent], snapshot: BattleState = null) -> void:
	_begin(events)
	for event: BattleEvent in events:
		_apply_instant(event, snapshot)


## Phát lần lượt bằng Tween, đúng thứ tự trong nhật ký (AC 1); canh đồng hồ thật để cả pha ≤ `MAX_PHASE_SECONDS`
## kể cả khi mỗi lần chờ bị làm tròn lên một khung hình (NFR3).
func play(events: Array[BattleEvent], snapshot: BattleState = null) -> void:
	var id: int = _begin(events)
	var scale: float = _time_scale(events)
	var deadline: int = Time.get_ticks_msec() + int(MAX_PHASE_SECONDS * 1000.0)
	for event: BattleEvent in events:
		if id != _play_id:
			return
		var seconds: float = _base_seconds(event) * scale
		var remaining: float = float(deadline - Time.get_ticks_msec()) / 1000.0
		if seconds <= 0.0 or remaining <= 0.0:
			# Hết ngân sách (hoặc sự kiện không có động tác): áp nốt ngay, không chờ thêm khung hình nào.
			_apply_instant(event, snapshot)
			continue
		await _play_one(event, minf(maxf(seconds, MIN_EVENT_SECONDS), remaining), snapshot)


## Dừng giữa chừng (đổi trận, màn hình lỗi): vô hiệu lượt phát đang chờ và giết Tween đang chạy.
func stop() -> void:
	_play_id += 1
	if _active_tween != null:
		_active_tween.kill()
		_active_tween = null


## Bắt đầu một lượt phát mới; trả số lượt để vòng lặp tự kiểm.
func _begin(events: Array[BattleEvent]) -> int:
	_play_id += 1
	_played = []
	return _play_id


## Tỉ lệ co thời gian để cả danh sách vừa `MAX_PHASE_SECONDS`.
func _time_scale(events: Array[BattleEvent]) -> float:
	var sum: float = 0.0
	for event: BattleEvent in events:
		sum += _base_seconds(event)
	if sum <= MAX_PHASE_SECONDS or sum <= 0.0:
		return 1.0
	return MAX_PHASE_SECONDS / sum


## Sự kiện không có động tác thì 0 giây (không tốn thời gian của pha).
func _base_seconds(event: BattleEvent) -> float:
	match event.type:
		BattleEvent.Type.MOVED, BattleEvent.Type.ATTACKED:
			return SECONDS_PER_EVENT
		BattleEvent.Type.COLLIDED, BattleEvent.Type.DAMAGED, BattleEvent.Type.TELEGRAPHED, BattleEvent.Type.VILLAGE_DAMAGED:
			return DAMAGE_SECONDS
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			return DEATH_SECONDS
	return 0.0


func _play_one(event: BattleEvent, seconds: float, snapshot: BattleState) -> void:
	_played.append(event)
	var token: UnitToken = _token(event.unit_id)
	match event.type:
		BattleEvent.Type.MOVED:
			if token != null:
				await _tween_to(token, "position", _move_target(token, event, snapshot), seconds)
		BattleEvent.Type.ATTACKED:
			if token != null:
				await _lunge(token, event, seconds)
		BattleEvent.Type.COLLIDED:
			await _collide(token, event, seconds)
		BattleEvent.Type.DAMAGED, BattleEvent.Type.TELEGRAPHED:
			if token != null:
				await _flash(token, seconds)
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			if token != null:
				await _sink_or_fade(token, event, seconds)
		BattleEvent.Type.VILLAGE_DAMAGED:
			if _notice != null:
				_notice.show_text(TranslationServer.translate("notice.morale_lost"))
			await _flash_village(event.to_cell, seconds)
		_:
			await _wait(seconds * 0.5)


## Trạng thái cuối của một sự kiện, dùng khi không chạy Tween (test, chế độ instant, hết ngân sách pha).
func _apply_instant(event: BattleEvent, snapshot: BattleState) -> void:
	_played.append(event)
	if event.type == BattleEvent.Type.VILLAGE_DAMAGED and _notice != null:
		_notice.show_text(TranslationServer.translate("notice.morale_lost"))
	var token: UnitToken = _token(event.unit_id)
	if token == null:
		return
	match event.type:
		BattleEvent.Type.MOVED:
			token.position = _move_target(token, event, snapshot)
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			token.visible = false


func _flash_village(cell: Vector2i, seconds: float) -> void:
	if _board == null or not is_inside_tree():
		await _wait(seconds)
		return
	var rect: Rect2 = BoardView.cell_rect(cell)
	var flash_node: ColorRect = ColorRect.new()
	flash_node.color = Color(1.0, 0.25, 0.25, 0.6)
	flash_node.position = rect.position
	flash_node.size = rect.size
	flash_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(flash_node)
	var tween: Tween = _new_tween()
	tween.tween_property(flash_node, "color:a", 0.0, seconds)
	await _wait(seconds)
	if is_instance_valid(flash_node):
		flash_node.queue_free()


func _token(unit_id: int) -> UnitToken:
	if _board == null:
		return null
	return _board.tokens().get(unit_id) as UnitToken


## Đích của một bước đi: tâm ô đích, trừ độ cao mặt ô (ô ải) — cùng công thức với `UnitToken.update`.
func _move_target(token: UnitToken, event: BattleEvent, snapshot: BattleState) -> Vector2:
	var lift: float = 0.0
	if snapshot != null and snapshot.in_bounds(event.to_cell):
		lift = BoardView.surface_height(snapshot.terrain_at(event.to_cell))
	else:
		# Không có bản chụp: giữ nguyên độ cao đang có.
		lift = BoardView.cell_center(event.from_cell).y - token.position.y
	return BoardView.cell_center(event.to_cell) - Vector2(0.0, lift)


func _lunge(token: UnitToken, event: BattleEvent, seconds: float) -> void:
	# Hướng lao tính từ chỗ đồng quân đang vẽ tới ô trúng: đúng cả khi nó vừa được đẩy trong cùng nhật ký
	# (view không được ghi `token.cell` — luật ranh giới, chỉ Effects được sửa `.cell`).
	var direction: Vector2 = BoardView.cell_center(event.to_cell) - token.position
	if direction.length() < 1.0:
		direction = Vector2.DOWN
	var start: Vector2 = token.position
	var forward: Vector2 = start + direction.normalized() * LUNGE_DISTANCE
	var tween: Tween = _new_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(token, "position", forward, seconds * 0.4)
	tween.tween_property(token, "position", start, seconds * 0.6)
	await _wait(seconds)


func _collide(token: UnitToken, event: BattleEvent, seconds: float) -> void:
	# Cả hai quân cùng rung: bên bị đẩy và bên bị va.
	if token != null:
		await _shake(token, seconds)
	var other: UnitToken = _token(event.other_id)
	if other != null:
		await _shake(other, seconds * 0.6)


func _shake(token: UnitToken, seconds: float) -> void:
	var start: Vector2 = token.position
	var tween: Tween = _new_tween()
	tween.tween_property(token, "position", start + Vector2(SHAKE_DISTANCE, -SHAKE_DISTANCE * 0.4), seconds * 0.25)
	tween.tween_property(token, "position", start - Vector2(SHAKE_DISTANCE, -SHAKE_DISTANCE * 0.4),
		seconds * 0.5)
	tween.tween_property(token, "position", start, seconds * 0.25)
	await _wait(seconds)


func _flash(token: UnitToken, seconds: float) -> void:
	var normal: Color = token.modulate
	var tween: Tween = _new_tween()
	tween.tween_property(token, "modulate", Color(1.0, 0.35, 0.35, normal.a), seconds * 0.35)
	tween.tween_property(token, "modulate", normal, seconds * 0.65)
	await _wait(seconds)


## Gục: mờ hẳn. Chết đuối: chìm xuống rồi mờ. Cả hai ẩn đồng quân; `show_state` sau đó gỡ hẳn.
func _sink_or_fade(token: UnitToken, event: BattleEvent, seconds: float) -> void:
	var tween: Tween = _new_tween()
	if event.type == BattleEvent.Type.DROWNED:
		tween.set_parallel(true)
		tween.tween_property(token, "position", token.position + Vector2(0.0, 10.0), seconds)
	tween.tween_property(token, "modulate:a", 0.0, seconds)
	await _wait(seconds)
	token.visible = false


func _tween_to(node: Node2D, property: String, target: Variant, seconds: float) -> void:
	var tween: Tween = _new_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, property, target, seconds)
	await _wait(seconds)


## Tween mới cho node này; giết Tween cũ để `stop()`/lượt sau không chồng chuyển động lên nhau.
func _new_tween() -> Tween:
	if _active_tween != null:
		_active_tween.kill()
	_active_tween = create_tween()
	return _active_tween


## Chờ bằng timer (không chờ `Tween.finished`): `stop()`/đổi trận giết Tween thì vòng phát vẫn tỉnh dậy được.
func _wait(seconds: float) -> void:
	if seconds <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(seconds).timeout
