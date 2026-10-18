class_name Command
extends RefCounted
## Lệnh của người chơi gửi vào Rules.resolve. Lệnh mới (mưu kế...) thêm ở story của nó.
## Trường chỉ gán trong _init: check_boundaries.sh bắt mọi phép gán "x.cell = ..." ngoài Effects.

enum Kind { MOVE, END_TURN, ATTACK }

var kind: Kind
var unit_id: int
var cell: Vector2i


func _init(p_kind: Kind, p_unit_id: int, p_cell: Vector2i) -> void:
	kind = p_kind
	unit_id = p_unit_id
	cell = p_cell


## Tướng unit_id đi tới ô cell.
static func move(p_unit_id: int, p_cell: Vector2i) -> Command:
	return Command.new(Kind.MOVE, p_unit_id, p_cell)


## Tướng unit_id đánh ô cell.
static func attack(p_unit_id: int, p_cell: Vector2i) -> Command:
	return Command.new(Kind.ATTACK, p_unit_id, p_cell)


## Kết thúc lượt người chơi.
static func end_turn() -> Command:
	return Command.new(Kind.END_TURN, 0, Vector2i(-1, -1))
