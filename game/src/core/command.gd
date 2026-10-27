class_name Command
extends RefCounted
## Lệnh của người chơi gửi vào Rules.resolve. Lệnh mới thêm ở story của nó.
## Trường chỉ gán trong _init: check_boundaries.sh bắt mọi phép gán "x.cell = ..." ngoài Effects.

## BEGIN_BATTLE: lệnh nội bộ mở trận (pha địch chuẩn bị của hiệp 1), chỉ BattleController.begin() gửi.
## USE_STRATAGEM: dùng mưu kế `stratagem` (Story 3.12), không cần tướng hay ô.
enum Kind { MOVE, END_TURN, ATTACK, BEGIN_BATTLE, USE_STRATAGEM }

var kind: Kind
var unit_id: int
var cell: Vector2i
## Stratagem.Kind của lệnh USE_STRATAGEM; -1 với lệnh khác.
var stratagem: int


func _init(p_kind: Kind, p_unit_id: int, p_cell: Vector2i, p_stratagem: int = -1) -> void:
	kind = p_kind
	unit_id = p_unit_id
	cell = p_cell
	stratagem = p_stratagem


## Tướng unit_id đi tới ô cell.
static func move(p_unit_id: int, p_cell: Vector2i) -> Command:
	return Command.new(Kind.MOVE, p_unit_id, p_cell)


## Tướng unit_id đánh ô cell.
static func attack(p_unit_id: int, p_cell: Vector2i) -> Command:
	return Command.new(Kind.ATTACK, p_unit_id, p_cell)


## Kết thúc lượt người chơi.
static func end_turn() -> Command:
	return Command.new(Kind.END_TURN, 0, Vector2i(-1, -1))


## Dùng mưu kế (Stratagem.Kind). Không tốn hành động của tướng (FR34).
static func use_stratagem(p_stratagem: int) -> Command:
	return Command.new(Kind.USE_STRATAGEM, 0, Vector2i(-1, -1), p_stratagem)


## Mở trận: quân Nguyên đi và báo đòn cho hiệp 1 (Story 2.6). Không phải lệnh của người chơi.
static func begin_battle() -> Command:
	return Command.new(Kind.BEGIN_BATTLE, 0, Vector2i(-1, -1))
