class_name Grid
extends RefCounted
## Lưới ô vuông: 4 hướng, không đi chéo. Tọa độ Vector2i(cot, hang), gốc trên trái, Bắc ở trên.

## 4 hướng theo thứ tự B→Đ→N→T: thứ tự cố định cho mọi trường hợp hòa (BFS, chọn đường, chọn ô đứng).
const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
