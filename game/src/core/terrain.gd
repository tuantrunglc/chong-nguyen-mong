class_name Terrain
extends RefCounted
## Loại địa hình của một ô. Ký hiệu trong file trận: . ~ # ^ L D A (xem BoardText).

enum { PLAIN, RIVER, FOREST, SPIKES, GRANARY, VILLAGE, PASS }

## Đất trống, hầm chông, ô ải đi vào được; sông, rừng, kho lương, làng thì không.
const WALKABLE: Array[int] = [PLAIN, SPIKES, PASS]
## Vật cản chặn đòn lao, tên và kéo (Story 3.1). Làng chặn ở Story 3.7 (cùng Lòng dân). Sông không chặn.
const ATTACK_BLOCKERS: Array[int] = [FOREST, GRANARY]


static func is_walkable(terrain: int) -> bool:
	return WALKABLE.has(terrain)
