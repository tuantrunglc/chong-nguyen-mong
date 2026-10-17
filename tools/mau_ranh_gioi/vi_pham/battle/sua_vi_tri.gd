extends Node2D
# Mẫu vi phạm: tầng battle sửa vị trí quân trực tiếp.


func f(unit: Object) -> void:
	unit.cell = Vector2i(1, 2)
