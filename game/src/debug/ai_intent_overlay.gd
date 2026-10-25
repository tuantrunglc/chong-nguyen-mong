class_name AiIntentOverlay
extends Node2D
## F3 (chỉ khi bật dev, Story 2.6): bảng ý định của quân Nguyên trong pha chuẩn bị vừa rồi: mỗi quân một dòng, đi từ
## đâu tới đâu, nhắm tướng nào (cách mấy bước), vì sao chọn ô đó, đòn số mấy. Đọc BattleState.enemy_intents của bản
## chụp, không tính lại (tính lại sau khi quân đã đi sẽ ra kết quả khác).
## Góc trên trái, dưới chữ "DEV"; không nhận chuột, không che cột nút HUD bên phải.

const PANEL_POSITION: Vector2 = Vector2(8, 40)
const PANEL_WIDTH: float = 640.0
const FONT_SIZE: int = 14
const TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const BACKGROUND_COLOR: Color = Color(0.0, 0.0, 0.0, 0.7)
const SEPARATOR: String = " · "

## Tên đầy đủ theo UnitType (như công cụ duyệt kịch bản).
const UNIT_NAME_KEYS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "scenario.unit.nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "scenario.unit.pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "scenario.unit.tran_khanh_du",
	UnitType.BO_BINH: "scenario.unit.bo_binh",
	UnitType.KY_BINH: "scenario.unit.ky_binh",
	UnitType.CUNG_KY: "scenario.unit.cung_ky",
}
const REASON_KEYS: Dictionary = {
	EnemyIntent.Reason.CAN_HIT: "dev.ai.can_hit",
	EnemyIntent.Reason.CLOSEST: "dev.ai.closest",
	EnemyIntent.Reason.NO_PATH: "dev.ai.no_path",
	EnemyIntent.Reason.NO_ATTACK_RULE: "dev.ai.no_rule",
}

var _label: Label = null


func _ready() -> void:
	visible = false
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = PANEL_POSITION
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = BACKGROUND_COLOR
	style.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	_label.add_theme_color_override("font_color", TEXT_COLOR)
	panel.add_child(_label)
	add_child(panel)


## Viết lại bảng theo bản chụp; null thì để trống.
func show_state(state: BattleState) -> void:
	_label.text = "\n".join(texts_for(state)) if state != null else ""


## Bật/tắt; trả về trạng thái mới (true là đang hiện).
func toggle() -> bool:
	visible = not visible
	return visible


## Các dòng đang hiện (để test).
func texts() -> Array[String]:
	var out: Array[String] = []
	if not _label.text.is_empty():
		out.assign(_label.text.split("\n"))
	return out


## Dòng tiêu đề rồi mỗi quân Nguyên một dòng, theo thứ tự hành động.
static func texts_for(state: BattleState) -> Array[String]:
	var lines: Array[String] = [tr_static("dev.ai.title") % state.round_number]
	if state.enemy_intents.is_empty():
		lines.append(tr_static("dev.ai.none"))
		return lines
	for intent: EnemyIntent in state.enemy_intents:
		lines.append(line_for(intent, state))
	return lines


## "Bộ binh 101: 3,0 → 3,2 · nhắm Nguyễn Khoái (cách 3 bước) · đứng đây vì đánh trúng được · đòn số 1"
static func line_for(intent: EnemyIntent, state: BattleState) -> String:
	var name: String = "%s %d" % [_unit_name(intent.unit_type), intent.unit_id]
	if state.unit_by_id(intent.unit_id) == null:
		name += " " + tr_static("dev.ai.fallen")
	var parts: PackedStringArray = PackedStringArray()
	if intent.stand_cell == intent.from_cell:
		parts.append(tr_static("dev.ai.stayed") % [name, BoardText.cell_text(intent.from_cell)])
	else:
		parts.append(tr_static("dev.ai.moved") % [name, BoardText.cell_text(intent.from_cell),
			BoardText.cell_text(intent.stand_cell)])
	if intent.target_id != 0:
		var general: int = UnitType.GENERALS[intent.target_id - 1]
		parts.append(tr_static("dev.ai.target") % [_unit_name(general), intent.target_steps])
	elif intent.target_cell != Vector2i(-1, -1):
		parts.append(tr_static("dev.ai.target_village") % [BoardText.cell_text(intent.target_cell), intent.target_steps])
	parts.append(tr_static(REASON_KEYS[intent.reason] as String))
	if intent.order > 0:
		parts.append(tr_static("dev.ai.order") % intent.order)
	else:
		parts.append(tr_static("dev.ai.no_attack"))
	return SEPARATOR.join(parts)


static func _unit_name(type: int) -> String:
	return tr_static(UNIT_NAME_KEYS.get(type, "?") as String)


## tr() cho hàm static.
static func tr_static(key: String) -> String:
	return TranslationServer.translate(key)
