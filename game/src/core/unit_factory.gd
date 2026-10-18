class_name UnitFactory
extends RefCounted
## Nơi duy nhất tạo quân. Id do người gọi cấp: tướng 1–3, quân Nguyên từ 101.


## hp > 0 là máu riêng (kịch bản luật); còn lại là máu đầy theo chỉ số.
static func create(id: int, type: int, cell: Vector2i, stats: Stats, hp: int = 0) -> Unit:
	return Unit.new(id, type, cell, hp if hp > 0 else stats.max_hp(type))
