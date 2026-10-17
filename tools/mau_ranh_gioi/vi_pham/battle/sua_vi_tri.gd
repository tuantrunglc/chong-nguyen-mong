extends Node2D
# Mẫu vi phạm: tầng battle sửa vị trí quân trực tiếp.
# mong_doi: chỉ Effects được sửa máu và vị trí (.hp/.cell)


func f(unit: Object) -> void:
	unit.cell = Vector2i(1, 2)
