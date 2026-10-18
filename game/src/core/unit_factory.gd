class_name UnitFactory
extends RefCounted
## Nơi duy nhất tạo quân. Id do người gọi cấp: tướng 1–3, quân Nguyên từ 101.


## hp > 0 là máu riêng (kịch bản luật), không quá máu đầy; còn lại (0, số âm) là máu đầy theo chỉ số.
static func create(id: int, type: int, cell: Vector2i, stats: Stats, hp: int = 0) -> Unit:
	var max_hp: int = stats.max_hp(type)
	return Unit.new(id, type, cell, mini(hp, max_hp) if hp > 0 else max_hp)
