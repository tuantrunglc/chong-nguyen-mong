class_name Unit
extends RefCounted
## Một quân trên bàn: tướng hoặc quân Nguyên. Chỉ Effects được đổi máu và vị trí,
## nên mọi thuộc tính chỉ gán trong _init (sao chép thì tạo Unit mới).

## Phe. Không đặt tên Side: trùng enum Side có sẵn của Godot (SIDE_LEFT…).
enum Faction { DAI_VIET, NGUYEN }

var id: int
var faction: Faction
## UnitType
var type: int
var cell: Vector2i
var hp: int


func _init(p_id: int, p_type: int, p_cell: Vector2i, p_hp: int) -> void:
	id = p_id
	type = p_type
	if UnitType.is_general(p_type):
		faction = Faction.DAI_VIET
	else:
		faction = Faction.NGUYEN
	cell = p_cell
	hp = p_hp
