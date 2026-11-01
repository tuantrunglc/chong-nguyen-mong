class_name FxArt
extends RefCounted
## Chọn hiệu ứng cho từng sự kiện (Story 8.4). Mọi đường dẫn hình hiệu ứng nằm ở đây, để thay hình ở một chỗ.
## Hàm thuần: chỉ đọc BattleEvent và bản chụp, không sửa gì, không vẽ gì.

const DIR: String = "hieu_ung/"
const VA_CHAM: String = DIR + "tex_va_cham.png"
const NUOC_BAN: String = DIR + "tex_nuoc_ban.png"
const CHONG_DAM: String = DIR + "tex_chong_dam.png"
const LUA_CHAY_KHO: String = DIR + "tex_lua_chay_kho.png"
const HOI_MAU: String = DIR + "tex_hoi_mau.png"
const LANG_TRUNG_DON: String = DIR + "tex_lang_trung_don.png"
const HAO_QUANG: String = DIR + "tex_hao_quang_sat_that.png"
const DAU_TIEP_VIEN: String = DIR + "tex_dau_tiep_vien.png"
const VET_CHEM_FRAMES: int = 4
## Loại hiệu ứng bay: hậu tố hướng thêm vào sau.
const LAO_BAY: String = "lao_bay"
const TEN_BAY: String = "ten_bay"

## Kiểu chuyển động mà FxLayer thể hiện.
const STYLE_POP: String = "pop"
const STYLE_FLICKER: String = "flicker"
const STYLE_RISE: String = "rise"
const STYLE_FRAMES: String = "frames"
const STYLE_TRAVEL: String = "travel"


## Hướng bay theo trục chính của đường bay: bac|dong|nam|tay (hậu tố tệp tex_lao_bay_*, tex_ten_bay_*).
static func bay_dir(from: Vector2, to: Vector2) -> String:
	var delta: Vector2 = to - from
	if absf(delta.x) > absf(delta.y):
		return "dong" if delta.x > 0.0 else "tay"
	return "bac" if delta.y < 0.0 else "nam"


## Đường dẫn hình của hiệu ứng bay (kind là LAO_BAY hoặc TEN_BAY) theo hướng từ from tới to.
static func bay_path(kind: String, from: Vector2, to: Vector2) -> String:
	return "%stex_%s_%s.png" % [DIR, kind, bay_dir(from, to)]


## Danh sách hiệu ứng của một sự kiện. Mỗi mục:
## { "kind": String, "style": String, "to_cell": Vector2i, "at_unit": bool, "path": String hoặc "paths": Array[String] }
## at_unit: đặt trên quân của sự kiện (không phải ô). Kind LAO_BAY/TEN_BAY: bay từ quân tới to_cell, đường dẫn
## chọn lúc phát bằng bay_path (cần vị trí vẽ). state null hoặc quân không có thì trả [] cho hiệu ứng cần loại quân.
static func plan(event: BattleEvent, state: BattleState) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	match event.type:
		BattleEvent.Type.ATTACKED:
			if state == null:
				return out
			var unit: Unit = state.unit_by_id(event.unit_id)
			if unit == null:
				return out
			match unit.type:
				UnitType.PHAM_NGU_LAO:
					out.append(_fx(LAO_BAY, STYLE_TRAVEL, event.to_cell))
				UnitType.CUNG_KY:
					out.append(_fx(TEN_BAY, STYLE_TRAVEL, event.to_cell))
				UnitType.NGUYEN_KHOAI, UnitType.BO_BINH:
					var frames: Array[String] = []
					for i: int in range(VET_CHEM_FRAMES):
						frames.append("%stex_vet_chem_%d.png" % [DIR, i])
					var slash: Dictionary = _fx("vet_chem", STYLE_FRAMES, event.to_cell)
					slash["paths"] = frames
					out.append(slash)
		BattleEvent.Type.COLLIDED:
			out.append(_fx("va_cham", STYLE_POP, event.to_cell, VA_CHAM))
		BattleEvent.Type.DROWNED:
			out.append(_fx("nuoc_ban", STYLE_POP, event.to_cell, NUOC_BAN))
		BattleEvent.Type.DAMAGED:
			if event.cause == BattleEvent.Cause.SPIKES:
				var spikes: Dictionary = _fx("chong_dam", STYLE_POP, Vector2i.ZERO, CHONG_DAM)
				spikes["at_unit"] = true
				out.append(spikes)
		BattleEvent.Type.GRANARY_BURNED:
			out.append(_fx("lua_kho", STYLE_FLICKER, event.to_cell, LUA_CHAY_KHO))
		BattleEvent.Type.HEALED:
			out.append(_fx("hoi_mau", STYLE_RISE, event.to_cell, HOI_MAU))
		BattleEvent.Type.VILLAGE_DAMAGED:
			out.append(_fx("khoi_lang", STYLE_RISE, event.to_cell, LANG_TRUNG_DON))
	return out


static func _fx(kind: String, style: String, to_cell: Vector2i, path: String = "") -> Dictionary:
	return {"kind": kind, "style": style, "to_cell": to_cell, "at_unit": false, "path": path}
