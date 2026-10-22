class_name Telegraph
extends RefCounted
## Đòn quân Nguyên đã báo (kiến trúc M1). Lưu tương đối so với chủ đòn, không lưu ô tuyệt đối: chủ đòn bị đẩy
## hoặc kéo thì đòn tự dịch theo. Trường chỉ gán trong _init; sao chép bằng clone().

## CELL: đánh một ô (Bộ binh: ô kề; Cung kỵ: ô thẳng hàng 2–3 ô). DIRECTION: xung phong theo một hướng (Kỵ binh).
enum Kind { CELL, DIRECTION }

## Ô trả về khi chủ đòn không còn trên bàn (đòn sẽ bị hủy ở Story 2.9).
const NO_CELL: Vector2i = Vector2i(-1, -1)

var owner_id: int
var kind: Kind
## CELL: ô đích = ô chủ đòn + offset. DIRECTION: một phần tử của Grid.DIRECTIONS.
var offset: Vector2i
## Số thứ tự ra đòn hiển thị trên bàn, từ 1.
var order: int


func _init(p_owner_id: int, p_kind: Kind, p_offset: Vector2i, p_order: int) -> void:
	owner_id = p_owner_id
	kind = p_kind
	offset = p_offset
	order = p_order


## Ô đích theo vị trí hiện tại của chủ đòn (CELL); DIRECTION thì là ô ngay trước mặt theo hướng xung phong.
## Chủ đòn đã gục thì NO_CELL.
func target_cell(state: BattleState) -> Vector2i:
	var owner: Unit = state.unit_by_id(owner_id)
	if owner == null:
		return NO_CELL
	return owner.cell + offset


func clone() -> Telegraph:
	return Telegraph.new(owner_id, kind, offset, order)
