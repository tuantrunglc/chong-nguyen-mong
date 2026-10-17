extends RefCounted
# Mẫu hợp lệ: so sánh máu, chú thích nhắc tới Node và print( không bị bắt.

var max_hp: int = 3


func f(unit: Object) -> bool:
	var hp: int = 0  # Node, get_tree(), print(
	return unit.hp == hp
