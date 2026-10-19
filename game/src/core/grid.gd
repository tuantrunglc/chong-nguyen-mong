class_name Grid
extends RefCounted
## Lưới ô vuông: 4 hướng, không đi chéo. Tọa độ Vector2i(cot, hang), gốc trên trái, Bắc ở trên.

## 4 hướng theo thứ tự B→Đ→N→T: thứ tự cố định cho mọi trường hợp hòa (BFS, chọn đường, chọn ô đứng).
const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]


## Kề cạnh (4 hướng, không chéo).
static func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return distance(a, b) == 1


## Khoảng cách Manhattan (số bước đi 4 hướng).
static func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## Hướng từ from tới to khi cùng hàng hoặc cùng cột (một phần tử của DIRECTIONS, cách xa bao nhiêu cũng được).
## Chéo, lệch hàng hoặc cùng ô thì trả Vector2i.ZERO. Đường lao (Story 2.3), kéo (2.4) dùng hàm này.
static func straight_dir(from: Vector2i, to: Vector2i) -> Vector2i:
	if from == to or (from.x != to.x and from.y != to.y):
		return Vector2i.ZERO
	return Vector2i(signi(to.x - from.x), signi(to.y - from.y))


## Hướng từ ô from sang ô kề to (một phần tử của DIRECTIONS). Ô không kề là lỗi của người gọi: ForcedMove sẽ
## nhảy cóc qua vật cản.
static func dir_between(from: Vector2i, to: Vector2i) -> Vector2i:
	assert(is_adjacent(from, to), "dir_between: %s và %s không kề" % [from, to])
	return to - from
