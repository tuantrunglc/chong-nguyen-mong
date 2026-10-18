class_name BattleController
extends RefCounted
## Nơi duy nhất giữ trạng thái trận đang sống. Phần hiển thị chỉ nhận bản chụp (snapshot()).
## Lệnh của người chơi (submit) và ngăn xếp hủy thêm ở story 1.4/1.5.

var _state: BattleState = null


func start(level: LevelData, stats: Stats) -> void:
	_state = BattleState.from_level(level, stats)
	# Bộ nạp đã chặn các lỗi này; đây chỉ là lưới an toàn.
	for problem: String in _state.validate():
		Log.error("battle", problem)


func snapshot() -> BattleState:
	return _state.clone()
