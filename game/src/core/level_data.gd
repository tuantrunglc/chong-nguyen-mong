class_name LevelData
extends RefCounted
## Một trận đã nạp từ data/tran/*.json. Chỉ đọc: LevelLoader tạo, BattleState sẽ dựng từ đây.

enum Mission { ELIMINATE, HOLD_PASS }


## Một quân đặt sẵn trên bàn lúc bắt đầu trận.
class UnitPlacement:
	extends RefCounted

	var type: int
	var cell: Vector2i
	## Máu lúc bắt đầu; 0 là máu đầy theo chi_so.json (file trận luôn 0, kịch bản luật ghi được máu riêng).
	var hp: int

	func _init(p_type: int, p_cell: Vector2i, p_hp: int = 0) -> void:
		type = p_type
		cell = p_cell
		hp = p_hp


## Một đợt quân tiếp viện xuất hiện theo hiệp (Story 3.10).
class Reinforcement:
	extends RefCounted

	var round: int
	var cell: Vector2i
	var type: int
	var hp: int

	func _init(p_round: int, p_cell: Vector2i, p_type: int, p_hp: int = 0) -> void:
		round = p_round
		cell = p_cell
		type = p_type
		hp = p_hp

	func clone() -> Reinforcement:
		return Reinforcement.new(round, cell, type, hp)


var format_version: int = 0
var name: String = ""
var mission: Mission = Mission.ELIMINATE
## Số hiệp tối đa (Story 3.5, chỉ trận Tiêu diệt); 0 là không giới hạn.
var max_rounds: int = 0
## Lòng dân ban đầu và tối đa (Story 3.7); 0 là không có làng.
var long_dan: int = 0
## Lòng dân hiện tại lúc bắt đầu (kịch bản luật có thể ghi nhỏ hơn tối đa); 0 là bằng long_dan.
var long_dan_hien_tai: int = 0
var size: Vector2i = Vector2i.ZERO
## Theo hàng: index = hang * size.x + cot.
var terrain: PackedInt32Array = PackedInt32Array()
## Tướng theo ký hiệu 1, 2, 3; rồi quân Nguyên theo thu_tu_dich.
var units: Array[UnitPlacement] = []
## Lịch quân tiếp viện theo hiệp (Story 3.10).
var reinforcements: Array[Reinforcement] = []
## Mưu kế mở trong trận ("muu_ke_mo", Stratagem.Kind theo thứ tự trong file, Story 3.12).
var stratagems: Array[int] = []
## Mưu kế đã dùng lúc bắt đầu (chỉ kịch bản luật ghi, "truoc.muu_ke_da_dung"); file trận luôn rỗng.
var stratagems_used: Array[int] = []


func terrain_at(cell: Vector2i) -> int:
	return terrain[cell.y * size.x + cell.x]
