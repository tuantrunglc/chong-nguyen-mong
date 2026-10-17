extends RefCounted
# Mẫu hợp lệ: effects.gd được sửa máu và vị trí.


func f(unit: Object) -> void:
	unit.hp -= 1
	unit.cell = Vector2i(0, 0)
