class_name BoardText
extends RefCounted
## Bàn cờ chữ: ký hiệu ô và quân, tách dòng, đọc tọa độ "cot,hang".
## Dùng chung cho file trận, kịch bản luật (story 1.3) và báo lỗi F2 (story 2.13).

## Ô không có quân trong lớp "quan".
const NO_UNIT: int = -1

const TERRAIN_SYMBOLS: Dictionary = {
	".": Terrain.PLAIN,
	"~": Terrain.RIVER,
	"#": Terrain.FOREST,
	"^": Terrain.SPIKES,
	"L": Terrain.GRANARY,
	"D": Terrain.VILLAGE,
	"A": Terrain.PASS,
}

const UNIT_SYMBOLS: Dictionary = {
	".": NO_UNIT,
	"1": UnitType.NGUYEN_KHOAI,
	"2": UnitType.PHAM_NGU_LAO,
	"3": UnitType.TRAN_KHANH_DU,
	"B": UnitType.BO_BINH,
	"K": UnitType.KY_BINH,
	"C": UnitType.CUNG_KY,
}

## Hướng trong kịch bản luật ("bao_don", Story 2.6): Bắc, Đông, Nam, Tây, viết không dấu như mọi khóa.
## Cùng thứ tự B→Đ→N→T với Grid.DIRECTIONS.
const DIRECTION_CODES: Dictionary = {
	"B": Vector2i(0, -1),
	"D": Vector2i(1, 0),
	"N": Vector2i(0, 1),
	"T": Vector2i(-1, 0),
}


## Tách một dòng thành các ô. Chịu được dấu cách và tab thừa ở đầu, cuối, giữa,
## kể cả dấu cách không ngắt (U+00A0, U+3000) hay lẫn vào khi gõ tiếng Việt hoặc chép từ chỗ khác.
static func split_row(line: String) -> PackedStringArray:
	return line.replace("\t", " ").replace("\u00A0", " ").replace("\u3000", " ").split(" ", false)


## Số chữ số tối đa của một tọa độ; dài hơn thì to_int() in ERROR ra console hoặc tràn Vector2i.
const MAX_CELL_DIGITS: int = 4


## "1,0" -> Vector2i(1, 0); chịu dấu cách quanh số. Không phải hai số nguyên thì trả null.
static func parse_cell(text: String) -> Variant:
	var parts: PackedStringArray = text.split(",")
	if parts.size() != 2:
		return null
	var col: String = parts[0].strip_edges()
	var row: String = parts[1].strip_edges()
	if col.length() > MAX_CELL_DIGITS or row.length() > MAX_CELL_DIGITS:
		return null
	if not col.is_valid_int() or not row.is_valid_int():
		return null
	return Vector2i(col.to_int(), row.to_int())


static func cell_text(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]
