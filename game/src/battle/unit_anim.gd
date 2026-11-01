class_name UnitAnim
extends RefCounted
## Chọn khung hình chuyển động của quân (Story 8.4): đi, đánh, trúng đòn, gục, chết đuối. Hàm thuần, không vẽ gì.
## Đường dẫn tính từ thư mục textures của game (xem Art) và đi qua Art.tex(). Tiền tố quân dùng lại bảng của UnitArt.

enum Clip { WALK, ATTACK, HURT, DIE, DROWN }

const FRAME_COUNT: int = 4
const WALK_FACINGS: Array[String] = ["north", "east", "south", "west"]
## Bộ hình đánh không có hướng bắc.
const ATTACK_FACINGS: Array[String] = ["east", "south", "west"]
## Quân có bộ chết đuối; ba tướng thì không (luật coi như va chạm).
const DROWN_PREFIXES: Array[String] = ["bo_binh", "ky_binh", "cung_ky"]
const CUNG_KY_PREFIX: String = "cung_ky"
## Clip -> đoạn tên tệp.
const CLIP_NAMES: Dictionary = {
	Clip.WALK: "di",
	Clip.ATTACK: "danh",
	Clip.HURT: "trung_don",
	Clip.DIE: "guc",
	Clip.DROWN: "chet_duoi",
}


## Hướng đi (north|east|south|west) theo ô đi: trục có |delta| lớn hơn thắng, hòa thì nam/bắc trước.
static func walk_facing(from: Vector2i, to: Vector2i) -> String:
	var delta: Vector2i = to - from
	if absi(delta.x) > absi(delta.y):
		return "east" if delta.x > 0 else "west"
	return "north" if delta.y < 0 else "south"


## Hướng đánh (east|south|west): không bao giờ north. Đánh lên phía bắc thì east nếu dx >= 0, ngược lại west.
static func attack_facing(from_pos: Vector2, to_pos: Vector2) -> String:
	var delta: Vector2 = to_pos - from_pos
	if absf(delta.x) > absf(delta.y):
		return "east" if delta.x > 0.0 else "west"
	if delta.y > 0.0 or (delta.y == 0.0 and delta.x == 0.0):
		return "south"
	return "east" if delta.x >= 0.0 else "west"


## 4 đường dẫn khung của một động tác, hoặc [] khi quân đó không có bộ này (tướng + DROWN, hướng không hợp lệ,
## loại quân lạ). facing là tên hướng (north, south_west...): đi và đánh dùng đúng tên, trúng đòn và gục của
## Cung kỵ chỉ lấy west hay east.
static func frame_paths(unit_type: int, clip: int, facing: String) -> Array[String]:
	var out: Array[String] = []
	if not UnitArt.PREFIXES.has(unit_type) or not CLIP_NAMES.has(clip):
		return out
	var prefix: String = UnitArt.PREFIXES[unit_type] as String
	var suffix: String = ""
	match clip:
		Clip.WALK:
			if not WALK_FACINGS.has(facing):
				return out
			suffix = "_" + facing
		Clip.ATTACK:
			if not ATTACK_FACINGS.has(facing):
				return out
			suffix = "_" + facing
		Clip.HURT, Clip.DIE:
			if prefix == CUNG_KY_PREFIX:
				suffix = "_west" if facing.contains("west") else "_east"
		Clip.DROWN:
			if not DROWN_PREFIXES.has(prefix):
				return out
	for i: int in range(FRAME_COUNT):
		out.append("hoat_anh/tex_%s_%s%s_%d.png" % [prefix, CLIP_NAMES[clip] as String, suffix, i])
	return out
