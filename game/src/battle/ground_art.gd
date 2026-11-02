class_name GroundArt
extends RefCounted
## Chọn hình cho mặt đất và địa hình (Story 8.2): ô ghép cỏ–sông và kiểu hình theo ô. Hàm thuần, không vẽ gì.
## Mọi đường dẫn tính từ thư mục textures của game (xem Art) và đi qua Art.tex().

## Số kiểu hình có sẵn.
const SPIKES_VARIANTS: int = 4
const PASS_VARIANTS: int = 4
const PASS_PAIR_VARIANTS: int = 2
const FOREST_VARIANTS: int = 2
const BACKDROP_VARIANTS: int = 4
const CO_LE_VARIANTS: int = 4
const TILE_COUNT: int = 16
## Hai rừng, theo (cột + hàng) chẵn lẻ: chẵn là tre trúc, lẻ là cây rậm.
const FOREST_PATHS: Array[String] = ["dia_hinh/tex_rung_tre_truc.png", "dia_hinh/tex_rung_cay_ram.png"]


## Ô ghép của điểm giao (vx, vy) giữa bốn ô bàn (vx-1,vy-1), (vx,vy-1), (vx-1,vy), (vx,vy). Bộ 16 ô là ghép theo
## góc: bit bật = ô đó là đất (không phải sông). mask = NW<<3 | NE<<2 | SW<<1 | SE. Ô ngoài bàn kẹp vào mép bàn.
## Ô 0 toàn nước, ô 15 toàn cỏ. Rừng, kho, làng, hầm chông, ô ải đều đứng trên đất nên tính là đất.
static func mask(state: BattleState, vx: int, vy: int) -> int:
	return (_land(state, vx - 1, vy - 1) << 3) | (_land(state, vx, vy - 1) << 2) \
		| (_land(state, vx - 1, vy) << 1) | _land(state, vx, vy)


static func _land(state: BattleState, c: int, r: int) -> int:
	var cell: Vector2i = Vector2i(clampi(c, 0, state.size.x - 1), clampi(r, 0, state.size.y - 1))
	return 0 if state.terrain_at(cell) == Terrain.RIVER else 1


## Kiểu hình (0 tới count - 1) của ô: băm theo ô, không ngẫu nhiên, nên cùng ô luôn cùng hình (kể cả sau hoàn tác).
static func variant(cell: Vector2i, count: int) -> int:
	return posmod(cell.x * 31 + cell.y * 17, count)


static func ground_path(tile_mask: int) -> String:
	return "dia_hinh/tex_o_nen_%d.png" % tile_mask


static func spikes_path(cell: Vector2i) -> String:
	return "dia_hinh/tex_ham_chong_%d.png" % variant(cell, SPIKES_VARIANTS)


static func co_le_path(cell: Vector2i) -> String:
	return "dia_hinh/tex_o_co_le_%d.png" % variant(cell, CO_LE_VARIANTS)


## Trả về true nếu ô đất trống cell có bụi cỏ lẻ/hoa dại/sỏi đá. Tỉ lệ ~57% số ô đất.
static func has_co_le(cell: Vector2i) -> bool:
	return posmod(cell.x * 37 + cell.y * 19, 7) < 4


## Đường dẫn hình Cửa Ải: nếu đứng cạnh ô ải khác theo hàng ngang thì tự động ghép thành Đại Quan Ải liền mạch.
static func pass_path(cell: Vector2i, state: BattleState = null) -> String:
	if state != null:
		var has_left: bool = cell.x > 0 and state.terrain_at(cell + Vector2i(-1, 0)) == Terrain.PASS
		var has_right: bool = cell.x < state.size.x - 1 and state.terrain_at(cell + Vector2i(1, 0)) == Terrain.PASS
		# Cả dãy ải dùng chung kiểu hình của ô đầu dãy (bên trái), để các mảnh trái/giữa/phải khớp nhau.
		var run_v: int = variant(_pass_run_start(cell, state), PASS_PAIR_VARIANTS)
		if not has_left and has_right:
			return "dia_hinh/tex_o_ai_doi_trai_%d.png" % run_v
		elif has_left and not has_right:
			return "dia_hinh/tex_o_ai_doi_phai_%d.png" % run_v
		elif has_left and has_right:
			return "dia_hinh/tex_o_ai_doi_giua_%d.png" % run_v
	return "dia_hinh/tex_o_ai_be_da_%d.png" % variant(cell, PASS_VARIANTS)


## Ô ải đầu tiên (trái nhất) của dãy ải ngang chứa cell.
static func _pass_run_start(cell: Vector2i, state: BattleState) -> Vector2i:
	var start: Vector2i = cell
	while start.x > 0 and state.terrain_at(start + Vector2i(-1, 0)) == Terrain.PASS:
		start += Vector2i(-1, 0)
	return start


## Hình khối nhô lên: rừng, kho lương, làng.
static func block_path(kind: int, cell: Vector2i) -> String:
	match kind:
		Terrain.FOREST:
			return FOREST_PATHS[posmod(cell.x + cell.y, FOREST_VARIANTS)]
		Terrain.GRANARY:
			return "dia_hinh/tex_kho_luong.png"
		Terrain.VILLAGE:
			return "dia_hinh/tex_lang_que.png"
	return ""


## Ô nền rừng quanh bàn, tile là chỉ số ô lát (tọa độ ô 64 px, tính từ gốc BoardView, có thể âm).
static func backdrop_path(tile: Vector2i) -> String:
	return "dia_hinh/tex_vien_rung_%d.png" % variant(tile, BACKDROP_VARIANTS)
