class_name EventPlayer
extends Node
## Phát lại nhật ký sự kiện của một lệnh bằng Tween (Story 2.11, NFR3, ADR-002).
## Chỉ đọc `BattleEvent` và node của view: KHÔNG gọi `show_state` chen giữa chừng, KHÔNG sửa `BattleState`.
## Lúc `play()` bắt đầu, bàn đang ở trạng thái TRƯỚC lệnh; `BoardView.show_state(snapshot)` gọi sau đó sẽ đưa mọi
## thứ về trạng thái cuối. Vì vậy hoạt ảnh chỉ cần đi từ vị trí đang có tới vị trí mà sự kiện nói.

## Một sự kiện có động tác dài chừng này; cả pha bị co lại nếu vượt `MAX_PHASE_SECONDS`.
const SECONDS_PER_EVENT: float = 0.18
## Trần NFR3 cho trọn một pha địch.
const MAX_PHASE_SECONDS: float = 3.0
const DAMAGE_SECONDS: float = 0.14
const DEATH_SECONDS: float = 0.22
## Đồng quân lao về phía mục tiêu bao xa (px) rồi về chỗ cũ.
const LUNGE_DISTANCE: float = 12.0
## Rung khi va chạm (px).
const SHAKE_DISTANCE: float = 5.0

## Bật khi chạy không có màn hình (GUT): áp dụng ngay, không chờ khung hình nào, để test không phải await.
var instant: bool = DisplayServer.get_name() == "headless"

var _board: BoardView = null
## Sự kiện đã phát, đúng thứ tự nhận được (để test).
var _played: Array[BattleEvent] = []
## `stop()` đặt cờ này để vòng phát dừng giữa chừng.
var _stopped: bool = false


func setup(board: BoardView) -> void:
	_board = board


func played() -> Array[BattleEvent]:
	return _played


## Tổng thời lượng phát của danh sách này; không bao giờ vượt `MAX_PHASE_SECONDS` (AC 2).
func total_seconds(events: Array[BattleEvent]) -> float:
	var sum: float = 0.0
	for event: BattleEvent in events:
		sum += _base_seconds(event)
	return minf(sum, MAX_PHASE_SECONDS)


## Áp dụng ngay toàn bộ, không Tween (test và chế độ instant).
func play_now(events: Array[BattleEvent]) -> void:
	_played = events.duplicate()
	_stopped = false
	for event: BattleEvent in events:
		_apply_instant(event)


## Phát lần lượt bằng Tween, đúng thứ tự trong nhật ký (AC 1).
func play(events: Array[BattleEvent]) -> void:
	_played = events.duplicate()
	_stopped = false
	var scale: float = _time_scale(events)
	for event: BattleEvent in events:
		if _stopped:
			return
		var seconds: float = _base_seconds(event) * scale
		if seconds <= 0.0:
			continue
		await _play_one(event, seconds)


## Dừng giữa chừng (đổi trận, màn hình lỗi): vòng phát thoát ở sự kiện kế tiếp.
func stop() -> void:
	_stopped = true


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
		BattleEvent.Type.MOVED:
			return SECONDS_PER_EVENT
		BattleEvent.Type.ATTACKED:
			return SECONDS_PER_EVENT
		BattleEvent.Type.COLLIDED, BattleEvent.Type.DAMAGED:
			return DAMAGE_SECONDS
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			return DEATH_SECONDS
		BattleEvent.Type.TELEGRAPHED:
			return DAMAGE_SECONDS
	return 0.0


func _play_one(event: BattleEvent, seconds: float) -> void:
	var token: UnitToken = _token(event.unit_id)
	if token == null:
		# TELEGRAPH_CANCELLED không còn đồng quân; các sự kiện khác cũng có thể gặp quân đã bị gỡ.
		await _wait(seconds * 0.5)
		return
	match event.type:
		BattleEvent.Type.MOVED:
			await _tween_to(token, "position", token.position + _delta(event), seconds)
		BattleEvent.Type.ATTACKED:
			await _lunge(token, event, seconds)
		BattleEvent.Type.COLLIDED:
			await _shake(token, seconds)
		BattleEvent.Type.DAMAGED:
			await _flash(token, seconds)
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			await _sink_or_fade(token, event, seconds)
		BattleEvent.Type.TELEGRAPHED:
			await _flash(token, seconds)
		_:
			await _wait(seconds * 0.5)


## Trạng thái cuối của một sự kiện, dùng khi không chạy Tween (test, chế độ instant).
func _apply_instant(event: BattleEvent) -> void:
	var token: UnitToken = _token(event.unit_id)
	if token == null:
		return
	match event.type:
		BattleEvent.Type.MOVED:
			token.position += _delta(event)
		BattleEvent.Type.DIED, BattleEvent.Type.DROWNED:
			token.visible = false


func _token(unit_id: int) -> UnitToken:
	if _board == null:
		return null
	return _board.tokens().get(unit_id) as UnitToken


## Sự kiện đi nói ô đầu và ô cuối; đồng quân đang đứng ở ô đầu (lift của ô ải giữ nguyên).
func _delta(event: BattleEvent) -> Vector2:
	return BoardView.cell_center(event.to_cell) - BoardView.cell_center(event.from_cell)


func _lunge(token: UnitToken, event: BattleEvent, seconds: float) -> void:
	# Hướng lao tính từ chỗ đồng quân đang vẽ tới ô trúng: đúng cả khi nó vừa được đẩy trong cùng nhật ký
	# (không đọc `token.cell`, vì view không được sửa `cell` — luật ranh giới, chỉ Effects).
	var direction: Vector2 = BoardView.cell_center(event.to_cell) - token.position
	if direction.length() < 1.0:
		direction = Vector2.DOWN
	var start: Vector2 = token.position
	var forward: Vector2 = start + direction.normalized() * LUNGE_DISTANCE
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(token, "position", forward, seconds * 0.4)
	tween.tween_property(token, "position", start, seconds * 0.6)
	await _wait(seconds)


func _shake(token: UnitToken, seconds: float) -> void:
	var start: Vector2 = token.position
	var tween: Tween = create_tween()
	tween.tween_property(token, "position", start + Vector2(SHAKE_DISTANCE, -SHAKE_DISTANCE * 0.4), seconds * 0.25)
	tween.tween_property(token, "position", start - Vector2(SHAKE_DISTANCE, -SHAKE_DISTANCE * 0.4),
		seconds * 0.5)
	tween.tween_property(token, "position", start, seconds * 0.25)
	await _wait(seconds)


func _flash(token: UnitToken, seconds: float) -> void:
	var normal: Color = token.modulate
	var tween: Tween = create_tween()
	tween.tween_property(token, "modulate", Color(1.0, 0.35, 0.35, normal.a), seconds * 0.35)
	tween.tween_property(token, "modulate", normal, seconds * 0.65)
	await _wait(seconds)


## Gục: mờ hẳn. Chết đuối: chìm xuống rồi mờ. Cả hai ẩn đồng quân; `show_state` sau đó gỡ hẳn.
func _sink_or_fade(token: UnitToken, event: BattleEvent, seconds: float) -> void:
	var tween: Tween = create_tween()
	if event.type == BattleEvent.Type.DROWNED:
		tween.set_parallel(true)
		tween.tween_property(token, "position", token.position + Vector2(0.0, 10.0), seconds)
	tween.tween_property(token, "modulate:a", 0.0, seconds)
	await _wait(seconds)
	token.visible = false


func _tween_to(node: Node2D, property: String, target: Variant, seconds: float) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, property, target, seconds)
	await _wait(seconds)


## Chờ bằng timer (không chờ `Tween.finished`): `stop()`/đổi trận giết Tween thì vòng phát vẫn tỉnh dậy được.
func _wait(seconds: float) -> void:
	if seconds <= 0.0 or not is_inside_tree():
		return
	await get_tree().create_timer(seconds).timeout
