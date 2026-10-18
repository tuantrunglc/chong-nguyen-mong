class_name Unit
extends RefCounted
## Một quân trên bàn: tướng hoặc quân Nguyên. Mọi thuộc tính gán trong _init (sao chép thì tạo Unit mới);
## sau đó chỉ Effects được đổi vị trí và máu. Cờ has_moved: RulesMove đặt; has_attacked: RulesAttack đặt;
## RulesEnemyPhase xóa cả hai.

## Phe. Không đặt tên Side: trùng enum Side có sẵn của Godot (SIDE_LEFT…).
enum Faction { DAI_VIET, NGUYEN }

var id: int
var faction: Faction
## UnitType
var type: int
var cell: Vector2i
var hp: int
## Đã đi trong lượt người chơi này (không đi tiếp được nữa).
var has_moved: bool
## Đã đánh trong lượt người chơi này (không đi, không đánh được nữa).
var has_attacked: bool


func _init(p_id: int, p_type: int, p_cell: Vector2i, p_hp: int, p_has_moved: bool = false,
		p_has_attacked: bool = false) -> void:
	id = p_id
	type = p_type
	if UnitType.is_general(p_type):
		faction = Faction.DAI_VIET
	else:
		faction = Faction.NGUYEN
	cell = p_cell
	hp = p_hp
	has_moved = p_has_moved
	has_attacked = p_has_attacked


## Còn máu. Quân hết máu bị Effects nhấc khỏi bàn ngay.
func is_alive() -> bool:
	return hp > 0
