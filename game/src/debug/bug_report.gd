class_name BugReport
extends RefCounted
## Dựng nội dung báo lỗi F2 (Story 2.13): kịch bản tái hiện (khối JSON dán thẳng vào `tests/kich_ban/`), bàn hiện
## tại để đối chiếu, 200 dòng log gần nhất và phiên bản build.
## Chỉ đọc dữ liệu được truyền vào: không giữ trạng thái sống, không đọc autoload, không ghi file, không phát signal.
## `truoc` là BÀN ĐẦU HIỆP + `hanh_dong` là mọi lệnh trong hiệp, nên phát lại ra đúng bàn đang chơi (tác giả chốt
## 2026-10-22: định dạng `truoc` không có `hiep`/`da_di`/`da_danh` nên không tả được bàn giữa hiệp).

const FORMAT_VERSION: int = 1
## Số dòng log tối đa đưa vào báo cáo (Log đã giữ 200; đây là chốt chặn thứ hai).
const LOG_LINES: int = 200

## BattleEvent.Reject -> mã "tu_choi" của kịch bản (ngược của ScenarioLoader.REJECT_CODES / ScenarioRunner.REJECT_EVENTS).
const REJECT_CODES: Dictionary = {
	BattleEvent.Reject.NO_UNIT: "khong_co_quan",
	BattleEvent.Reject.NOT_GENERAL: "khong_phai_tuong",
	BattleEvent.Reject.ALREADY_THERE: "da_dung_o_do",
	BattleEvent.Reject.UNREACHABLE: "khong_toi_duoc",
	BattleEvent.Reject.ALREADY_MOVED: "da_di_roi",
	BattleEvent.Reject.NOTHING_TO_UNDO: "khong_con_nuoc_di",
	BattleEvent.Reject.ALREADY_ATTACKED: "da_danh_roi",
	BattleEvent.Reject.NOT_ADJACENT: "khong_ke",
	BattleEvent.Reject.NO_TARGET: "khong_co_dich",
	BattleEvent.Reject.BLOCKED: "bi_chan",
	BattleEvent.Reject.NOT_IN_RANGE: "ngoai_tam",
	BattleEvent.Reject.BATTLE_OVER: "tran_da_het",
	BattleEvent.Reject.STRATAGEM_LOCKED: "muu_ke_khoa",
	BattleEvent.Reject.STRATAGEM_USED: "muu_ke_da_dung",
}

## Tên đầy đủ cho phần "bàn hiện tại" (chữ chẩn đoán, không qua `tr()` như log — báo cáo dán cho AI, không phải UI).
const TEN_QUAN: Dictionary = {
	UnitType.NGUYEN_KHOAI: "Nguyễn Khoái",
	UnitType.PHAM_NGU_LAO: "Phạm Ngũ Lão",
	UnitType.TRAN_KHANH_DU: "Trần Khánh Dư",
	UnitType.BO_BINH: "Bộ binh",
	UnitType.KY_BINH: "Kỵ binh",
	UnitType.CUNG_KY: "Cung kỵ",
}


## Toàn bộ văn bản dán vào clipboard. `state` null: không có trận (màn hình lỗi/menu) — chỉ log + phiên bản.
## `round_start`/`commands`: xem `BattleController.round_start_snapshot()/round_commands()`.
static func build(state: BattleState, round_start: BattleState, commands: Array[Dictionary],
		log_lines: PackedStringArray, meta: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Hào Khí Đông A — báo lỗi")
	lines.append("phiên bản: %s" % str(meta.get("build", "dev")))
	if state == null:
		lines.append("trận: %s (không có bàn)" % str(meta.get("tran", "?")))
	else:
		lines.append("trận: %s — %s · hiệp %d" % [str(meta.get("tran", "?")), str(meta.get("ten_tran", "?")),
			state.round_number])
	lines.append("lúc: %s · lần mở thứ %d" % [str(meta.get("luc", "?")), int(meta.get("lan_mo", 0))])
	lines.append("")
	if state != null:
		lines.append("## Kịch bản tái hiện (chỉ khối json ngay dưới đây là tệp .json)")
		lines.append("```json")
		lines.append(JSON.stringify(scenario_data(state, round_start, commands, meta), "  "))
		lines.append("```")
		lines.append("(hết khối JSON — phần còn lại của báo cáo KHÔNG thuộc tệp kịch bản)")
		lines.append("")
		lines.append("## Bàn hiện tại (để đối chiếu, không phải kịch bản)")
		lines.append_array(current_section(state))
		lines.append("")
	var logs: PackedStringArray = log_lines
	if logs.size() > LOG_LINES:
		logs = logs.slice(logs.size() - LOG_LINES)
	lines.append("## Nhật ký (%d dòng gần nhất, cũ → mới)" % logs.size())
	lines.append_array(logs)
	lines.append("")
	lines.append("## Ghi chú cho AI")
	if state == null:
		lines.append("Không có trận đang chạy. Chỉ có nhật ký và phiên bản ở trên.")
	else:
		lines.append("Cả báo cáo này là một tệp .txt. Chỉ khối json ở trên là một kịch bản luật hợp lệ:")
		lines.append("`truoc` là bàn đầu hiệp, `hanh_dong` là các lệnh người chơi đã bấm trong hiệp, `sau` là bàn SAU")
		lines.append("lệnh vừa rồi (đang phát hoạt ảnh thì đây là bàn cuối, không phải khung đang chạy).")
		lines.append("Muốn chạy thử: chép ĐÚNG khối đó (không kèm dòng nào khác) vào")
		lines.append("game/tests/kich_ban/<nhóm>/<tên>.json rồi chạy tools/test.sh.")
		lines.append("Nếu đây là lỗi: sửa `sau` thành điều ĐÚNG (kịch bản phải trượt), rồi mới sửa code — quy trình M3.")
	return "\n".join(lines)


## Khối kịch bản (Dictionary thuần, JSON.stringify được): `truoc` = bàn đầu hiệp, `hanh_dong` = lệnh trong hiệp.
static func scenario_data(state: BattleState, round_start: BattleState, commands: Array[Dictionary],
		meta: Dictionary) -> Dictionary:
	var start: BattleState = round_start if round_start != null else state
	return {
		"phien_ban_dinh_dang": FORMAT_VERSION,
		"mo_ta": "Báo lỗi F2: trận %s, hiệp %d, %d lệnh trong hiệp." % [str(meta.get("tran", "?")),
			start.round_number, commands.size()],
		"da_duyet": false,
		"truoc": before_layers(start),
		"hanh_dong": command_entries(commands),
		# `sau` = bàn hiện tại: kịch bản hợp lệ ngay, ghi lại điều ĐANG xảy ra. Nếu là lỗi thì sửa `sau` thành
		# điều đúng (kịch bản phải trượt trước khi sửa code — quy trình M3).
		"sau": after_layers(state),
	}


## Các lớp của "truoc": dia_hinh, quan, mau (chỉ quân thiếu máu), thu_tu_dich, bao_don (nếu ghi được hết).
static func before_layers(state: BattleState) -> Dictionary:
	var layers: Dictionary = {"dia_hinh": terrain_rows(state), "quan": unit_rows(state)}
	var hp: Dictionary = hp_layer(state)
	if not hp.is_empty():
		layers["mau"] = hp
	layers["thu_tu_dich"] = enemy_order(state)
	_add_strikes(layers, state)
	return layers


## Các lớp của "sau": như "truoc" nhưng KHÔNG có `thu_tu_dich` (định dạng "sau" không nhận khóa đó);
## thêm cờ đã đi/đã đánh của tướng và kết cục — định dạng "sau" kiểm được cả ba.
static func after_layers(state: BattleState) -> Dictionary:
	var layers: Dictionary = {"dia_hinh": terrain_rows(state), "quan": unit_rows(state)}
	var hp: Dictionary = hp_layer(state)
	if not hp.is_empty():
		layers["mau"] = hp
	_add_strikes(layers, state)
	layers["da_di"] = general_symbols(state, true)
	layers["da_danh"] = general_symbols(state, false)
	layers["ket_qua"] = outcome(state)
	return layers


## Ghi `bao_don` chỉ khi MỌI đòn serialize được. Bỏ một đòn (chủ đã gục, ô đích ngoài bàn, hướng lạ) mà vẫn ghi
## thì bàn phát lại còn đòn đó còn "sau" thì không — `ScenarioRunner` báo "thừa đòn" và kịch bản trong báo cáo
## luôn trượt (Story 2.13 review). Bỏ cả khóa thì bộ chạy chỉ không so đòn, kịch bản vẫn dùng được.
static func _add_strikes(layers: Dictionary, state: BattleState) -> void:
	var strikes: Array = strikes_layer(state)
	if strikes.is_empty() or strikes.size() != state.telegraphs.size():
		return
	layers["bao_don"] = strikes


## Ký hiệu "1"/"2"/"3" của các tướng đã đi (moved = true) hoặc đã đánh (moved = false).
static func general_symbols(state: BattleState, moved: bool) -> Array[String]:
	var out: Array[String] = []
	for unit: Unit in state.units:
		if unit.faction != Unit.Faction.DAI_VIET:
			continue
		if moved and unit.has_moved:
			out.append(str(unit.id))
		elif not moved and unit.has_attacked:
			out.append(str(unit.id))
	return out


## "dang_choi" / "thang" / "thua" (khớp giá trị `sau.ket_qua` của kịch bản).
static func outcome(state: BattleState) -> String:
	match state.phase:
		BattleState.Phase.WON:
			return "thang"
		BattleState.Phase.LOST:
			return "thua"
	return "dang_choi"


## Lớp `dia_hinh`: mỗi hàng một chuỗi, ô cách nhau một dấu cách.
static func terrain_rows(state: BattleState) -> Array[String]:
	var rows: Array[String] = []
	for y: int in range(state.size.y):
		var cells: PackedStringArray = PackedStringArray()
		for x: int in range(state.size.x):
			cells.append(BoardText.terrain_symbol(state.terrain[y * state.size.x + x]))
		rows.append(" ".join(cells))
	return rows


## Lớp `quan`: ký hiệu quân theo ô, ô trống là ".".
static func unit_rows(state: BattleState) -> Array[String]:
	var by_cell: Dictionary = {}
	for unit: Unit in state.units:
		by_cell[unit.cell] = BoardText.unit_symbol(unit.type)
	var rows: Array[String] = []
	for y: int in range(state.size.y):
		var cells: PackedStringArray = PackedStringArray()
		for x: int in range(state.size.x):
			cells.append(str(by_cell.get(Vector2i(x, y), ".")))
		rows.append(" ".join(cells))
	return rows


## Lớp `mau`: ô -> máu, chỉ cho quân đang thiếu máu (quân đầy máu không ghi).
static func hp_layer(state: BattleState) -> Dictionary:
	var out: Dictionary = {}
	for unit: Unit in state.units:
		if unit.hp < state.stats.max_hp(unit.type):
			out[BoardText.cell_text(unit.cell)] = unit.hp
	return out


## Lớp `thu_tu_dich`: ô quân Nguyên theo id tăng dần (id quyết định thứ tự ra đòn; bộ nạp gán id theo danh sách này).
static func enemy_order(state: BattleState) -> Array[String]:
	var enemies: Array[Unit] = []
	for unit: Unit in state.units:
		if unit.faction == Unit.Faction.NGUYEN:
			enemies.append(unit)
	enemies.sort_custom(func(a: Unit, b: Unit) -> bool: return a.id < b.id)
	var out: Array[String] = []
	for unit: Unit in enemies:
		out.append(BoardText.cell_text(unit.cell))
	return out


## Lớp `bao_don`: các đòn ghi được, xếp theo số thứ tự. Bỏ đòn không ghi được: chủ đã gục (bộ nạp đòi `quan` phải
## có quân Nguyên), ô đích ra ngoài bàn (bộ nạp từ chối), hướng lạ. `dropped_strikes()` đếm phần bỏ.
static func strikes_layer(state: BattleState) -> Array:
	var sorted: Array[Telegraph] = state.telegraphs.duplicate()
	sorted.sort_custom(func(a: Telegraph, b: Telegraph) -> bool: return a.order < b.order)
	var out: Array = []
	for telegraph: Telegraph in sorted:
		var owner: Unit = state.unit_by_id(telegraph.owner_id)
		if owner == null:
			continue
		var item: Dictionary = {"thu_tu": telegraph.order, "quan": BoardText.cell_text(owner.cell)}
		if telegraph.kind == Telegraph.Kind.DIRECTION:
			var code: String = BoardText.direction_code(telegraph.offset)
			if code.is_empty():
				continue
			item["huong"] = code
		else:
			var target: Vector2i = owner.cell + telegraph.offset
			if not state.in_bounds(target):
				continue
			item["o"] = BoardText.cell_text(target)
		out.append(item)
	return out


## Số đòn không ghi được vào kịch bản (chủ đã gục, ô đích ngoài bàn, hướng lạ).
static func dropped_strikes(state: BattleState) -> int:
	return state.telegraphs.size() - strikes_layer(state).size()


## `hanh_dong`: [{lenh, tuong, o, tu_choi}] đúng định dạng kịch bản; lệnh bị từ chối giữ mã `tu_choi`.
static func command_entries(commands: Array[Dictionary]) -> Array:
	var out: Array = []
	for record: Dictionary in commands:
		var code: String = str(record.get("lenh", ""))
		if code.is_empty():
			continue
		var entry: Dictionary = {"lenh": code}
		if code == "di" or code == "danh":
			entry["tuong"] = str(int(record.get("tuong", 0)))
			entry["o"] = BoardText.cell_text(record.get("o", Vector2i.ZERO) as Vector2i)
		var reject: int = int(record.get("tu_choi", BattleEvent.Reject.NONE))
		if reject != BattleEvent.Reject.NONE and REJECT_CODES.has(reject):
			entry["tu_choi"] = str(REJECT_CODES[reject])
		out.append(entry)
	return out


## Phần "bàn hiện tại": hiệp, cờ đã đi/đã đánh của tướng, bàn chữ, máu lẻ, đòn đã báo. Chỉ để đối chiếu.
static func current_section(state: BattleState) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("hiệp: %d" % state.round_number)
	var generals: PackedStringArray = PackedStringArray()
	for unit: Unit in state.units:
		if unit.faction != Unit.Faction.DAI_VIET:
			continue
		generals.append("%s (%d): %s, %s, %d máu" % [_ten_quan(unit.type), unit.id,
			"đã đi" if unit.has_moved else "chưa đi", "đã đánh" if unit.has_attacked else "chưa đánh",
			unit.hp])
	lines.append("tướng: %s" % ("; ".join(generals) if not generals.is_empty() else "không còn tướng nào"))
	lines.append("địa hình:")
	for row: String in terrain_rows(state):
		lines.append("  " + row)
	lines.append("quân:")
	for row: String in unit_rows(state):
		lines.append("  " + row)
	var hp: Dictionary = hp_layer(state)
	if hp.is_empty():
		lines.append("máu lẻ: không có")
	else:
		var parts: PackedStringArray = PackedStringArray()
		for cell: String in hp:
			parts.append("%s=%d" % [cell, int(hp[cell])])
		lines.append("máu lẻ: %s" % " · ".join(parts))
	var strikes: Array = strikes_layer(state)
	if not strikes.is_empty():
		var parts: PackedStringArray = PackedStringArray()
		for item: Dictionary in strikes:
			var where: String = str(item["o"]) if item.has("o") else ("hướng %s" % str(item["huong"]))
			parts.append("%d. %s" % [int(item["thu_tu"]), where])
		lines.append("đòn đã báo: %s" % " · ".join(parts))
	var dropped: int = dropped_strikes(state)
	if dropped > 0:
		lines.append("bỏ %d đòn không ghi được vào kịch bản (chủ đã gục / ô đích ngoài bàn / hướng lạ)" % dropped)
	return lines


static func _ten_quan(type: int) -> String:
	return str(TEN_QUAN.get(type, "quân lạ"))
