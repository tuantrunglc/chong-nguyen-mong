class_name TelegraphMarks
extends RefCounted
## Ô đỏ báo đòn (Story 2.7): đòn quân Nguyên đã báo phủ những ô nào, trúng ô nào, tính theo vị trí hiện tại của chủ
## đòn và vật trên bàn (tính lại sau mỗi lệnh). Chỉ đọc state. Phần vẽ (TelegraphView) chỉ gọi các hàm này.


## Ô -> các số thứ tự đòn phủ ô đó, tăng dần.
static func cells(_state: BattleState) -> Dictionary:
	return {}


## Ô đòn sẽ trúng; NO_CELL nếu không có.
static func hit_cell(_state: BattleState, _telegraph: Telegraph) -> Vector2i:
	return Telegraph.NO_CELL


## Các ô đòn đi qua, theo thứ tự từ chủ đòn ra.
static func path_cells(_state: BattleState, _telegraph: Telegraph) -> Array[Vector2i]:
	return []
