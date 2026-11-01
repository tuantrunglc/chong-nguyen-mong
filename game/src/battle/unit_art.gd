class_name UnitArt
extends RefCounted
## Chọn hình quân đứng yên (Story 8.3): hình theo loại quân và hướng, hướng quay về địch gần nhất. Hàm thuần, không vẽ gì.
## Hướng chỉ là chuyện hiển thị: không nằm trong Unit, BattleState hay file lưu. Mọi đường dẫn tính từ thư mục
## textures của game (xem Art) và đi qua Art.tex().

## 8 hướng theo thứ tự chỉ số. Bắc ở phía trên màn hình, Đông bên phải.
const FACING_NAMES: Array[String] = [
	"south", "south_east", "east", "north_east", "north", "north_west", "west", "south_west",
]
## Đại Việt quay lên, Nguyên quay xuống khi không còn địch trên bàn.
const DEFAULT_FACING_DAI_VIET: int = 4
const DEFAULT_FACING_NGUYEN: int = 0
## UnitType -> tiền tố tên tệp trong quan/.
const PREFIXES: Dictionary = {
	UnitType.NGUYEN_KHOAI: "khoai",
	UnitType.PHAM_NGU_LAO: "lao",
	UnitType.TRAN_KHANH_DU: "du",
	UnitType.BO_BINH: "bo_binh",
	UnitType.KY_BINH: "ky_binh",
	UnitType.CUNG_KY: "cung_ky",
}


## Chỉ số của hướng theo tên ("south", "north_east"...); không có thì -1.
static func facing_index(p_name: String) -> int:
	return FACING_NAMES.find(p_name)


## Loại quân chưa có trong PREFIXES thì trả đường dẫn không tồn tại, để Art.tex báo lỗi và vẽ ô hồng thay vì crash.
static func sprite_path(unit_type: int, p_facing: int) -> String:
	var prefix: String = PREFIXES.get(unit_type, "khong_ro") as String
	return "quan/tex_%s_%s.png" % [prefix, FACING_NAMES[posmod(p_facing, FACING_NAMES.size())]]


## Hướng đứng của unit: quay mặt về quân địch gần nhất (khoảng cách Manhattan, hòa thì id nhỏ hơn).
## Không còn địch thì hướng mặc định theo phe.
static func facing_for(unit: Unit, state: BattleState) -> int:
	var default_facing: int = DEFAULT_FACING_DAI_VIET if unit.faction == Unit.Faction.DAI_VIET else DEFAULT_FACING_NGUYEN
	if state == null:
		return default_facing
	var best: Unit = null
	var best_distance: int = 0
	for other: Unit in state.units:
		if other.faction == unit.faction:
			continue
		var delta: Vector2i = other.cell - unit.cell
		var distance: int = absi(delta.x) + absi(delta.y)
		if best == null or distance < best_distance or (distance == best_distance and other.id < best.id):
			best = other
			best_distance = distance
	if best == null:
		return default_facing
	return facing_from_vector(best.cell - unit.cell, default_facing)


## Làm tròn vec (cột, hàng; hàng tăng là xuống) về 1 trong 8 hướng. Vec bằng 0 thì trả fallback.
static func facing_from_vector(delta: Vector2i, fallback: int) -> int:
	if delta == Vector2i.ZERO:
		return fallback
	# Góc đo từ hướng nam, quay sang đông: nam 0, đông π/2, bắc π, tây -π/2.
	var angle: float = atan2(float(delta.x), float(delta.y))
	return posmod(roundi(angle / (PI / 4.0)), FACING_NAMES.size())
