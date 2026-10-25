class_name EnemyIntent
extends RefCounted
## Ý định của một quân Nguyên trong pha chuẩn bị (EnemyAI.plan): nhắm ai, đứng đâu, vì sao. BattleState giữ lại để
## F3 đọc từ bản chụp (Story 2.6). Thuần dữ liệu; trường gán trong _init, trừ order do RulesEnemyPhase đặt khi báo
## đòn.

enum Reason {
	## Có ô trong tầm đi mà từ đó đòn trúng mục tiêu: đứng đó và báo đòn.
	CAN_HIT,
	## Không có ô như vậy: đi tới ô gần mục tiêu nhất, không báo đòn.
	CLOSEST,
	## Không có đường tới tướng nào: đứng yên, không báo đòn.
	NO_PATH,
	## Loại quân chưa có luật đòn: đứng yên, không báo đòn. Từ Story 2.15 cả ba loại quân Nguyên đều có luật;
	## giữ mã này cho loại quân thêm sau.
	NO_ATTACK_RULE,
}

var unit_id: int
## UnitType của quân (F3 vẫn ghi được tên khi quân đã gục).
var unit_type: int
var from_cell: Vector2i
var stand_cell: Vector2i
## 0 là không có mục tiêu.
var target_id: int
## Số bước từ from_cell tới mục tiêu (Pathfinding.distance_field); 0 khi không có mục tiêu.
var target_steps: int
var reason: Reason
## Số thứ tự đòn đã báo; 0 là không báo đòn.
var order: int
## Ô mục tiêu (Story 3.7: nhắm ô làng thì target_id = 0 và target_cell là ô làng; nhắm tướng thì là cell của tướng).
var target_cell: Vector2i = Vector2i(-1, -1)


func _init(p_unit_id: int, p_unit_type: int, p_from: Vector2i, p_stand: Vector2i, p_target_id: int,
		p_target_steps: int, p_reason: Reason, p_order: int = 0,
		p_target_cell: Vector2i = Vector2i(-1, -1)) -> void:
	unit_id = p_unit_id
	unit_type = p_unit_type
	from_cell = p_from
	stand_cell = p_stand
	target_id = p_target_id
	target_steps = p_target_steps
	reason = p_reason
	order = p_order
	target_cell = p_target_cell


func clone() -> EnemyIntent:
	return EnemyIntent.new(unit_id, unit_type, from_cell, stand_cell, target_id, target_steps, reason, order, target_cell)
