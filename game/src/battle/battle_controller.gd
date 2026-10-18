class_name BattleController
extends RefCounted
## Nơi duy nhất giữ trạng thái trận đang sống. Phần hiển thị chỉ nhận bản chụp (snapshot()).
## UI hỏi ô đi được qua reachable/path_to (chỉ đọc). Lệnh của người chơi (submit) và ngăn xếp hủy thêm ở story 1.5.

var _state: BattleState = null


func start(level: LevelData, stats: Stats) -> void:
	_state = BattleState.from_level(level, stats)
	# Bộ nạp đã chặn các lỗi này; đây chỉ là lưới an toàn.
	for problem: String in _state.validate():
		Log.error("battle", problem)


func snapshot() -> BattleState:
	return _state.clone()


## Các ô quân unit_id dừng được, theo thứ tự đọc bàn. Không có quân đó thì [].
func reachable(unit_id: int) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null:
		return []
	return RulesMove.reachable(_state, unit)


## Đường đi của quân unit_id tới cell (không gồm ô đang đứng); không tới được thì [].
func path_to(unit_id: int, cell: Vector2i) -> Array[Vector2i]:
	var unit: Unit = _state.unit_by_id(unit_id)
	if unit == null:
		return []
	return RulesMove.path_to(_state, unit, cell)
