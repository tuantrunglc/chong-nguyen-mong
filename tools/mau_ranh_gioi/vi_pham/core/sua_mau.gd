extends RefCounted
# Mẫu vi phạm: sửa máu ngoài effects.gd.
# mong_doi: chỉ Effects được sửa máu và vị trí (.hp/.cell)


func f(unit: Object) -> void:
	unit.hp += 1
