class_name UnitFactory
extends RefCounted
## Nơi duy nhất tạo quân. Id do người gọi cấp: tướng 1–3, quân Nguyên từ 101.


static func create(id: int, type: int, cell: Vector2i, stats: Stats) -> Unit:
	return Unit.new(id, type, cell, stats.max_hp(type))
