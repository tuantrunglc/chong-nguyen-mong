class_name UnitToken
extends Node2D
## Quân đứng yên bằng hình (Story 8.3), có bóng dưới chân, kèm chấm máu ở góc dưới phải thân.
## position là chân quân: tâm mặt trên của ô (BoardView.cell_center, cộng độ cao bệ ô ải nếu có).
## Vùng bấm vẫn là hình tròn cũ quanh thân (RADIUS, TOKEN_LIFT) nên khung bàn và pick_cell không đổi.
## Chỉ vẽ theo bản chụp, không giữ tham chiếu tới trạng thái đang sống.

const RADIUS: float = 24.0
## Tâm vùng bấm cao hơn chân. Đủ nhỏ để vùng bấm không với tới tâm ô hàng xóm (BoardView.pick_cell).
const TOKEN_LIFT: float = 20.0
## Chân hình quân nằm thấp hơn position bấy nhiêu px (chân vẫn trong ô, đỉnh đầu không vượt đỉnh vùng bấm cũ).
const FOOT_DROP: float = 18.0
## Hàng điểm ảnh cuối cùng của chân trong khung 64×64 (hộp bao đo ở Story 8.3: chân ở y 61..63).
const SPRITE_FEET_Y: float = 62.0
const SPRITE_SIZE: float = 64.0
## Bóng 32×16 đặt giữa dưới chân.
const SHADOW_TEXTURE: String = "giao_dien/tex_bong_do_quan_32x16.png"
const SHADOW_SIZE: Vector2 = Vector2(32, 16)
const SHADOW_RAISE: float = 2.0
## Chữ tên trên quân: tắt từ Story 8.3 (hình đủ để nhận ra, tooltip vẫn có tên). Đặt true để hiện lại.
const SHOW_NAMES: bool = false
## Hào quang Sát Thát: nhịp thở (tỉ lệ phóng), tốc độ (rad/giây), tâm cao hơn chân bấy nhiêu px.
const AURA_BREATH: float = 0.06
const AURA_SPEED: float = 4.0
const AURA_LIFT: float = 24.0
## Màu nhân vào hình quân: đã đi hơi xỉn ngả đỏ nhạt, đã đánh xám nhạt rõ hơn (tác giả chốt 2026-10-18: hai trạng thái
## khác hẳn nhau, không dùng độ trong suốt). Nhân vào phần vẽ hình, không phải `modulate` của cả token
## (hoạt ảnh `_flash` dùng `modulate` của token).
const MOVED_TINT: Color = Color(0.78, 0.70, 0.70)
const ATTACKED_TINT: Color = Color(0.60, 0.60, 0.62)
## Màu phe: PreviewView vẫn dùng cho bóng mờ xem trước.
const DAI_VIET_COLOR: Color = Color(0.70, 0.13, 0.13)
const NGUYEN_COLOR: Color = Color(0.17, 0.20, 0.28)
const DAI_VIET_TEXT_COLOR: Color = Color(1.0, 0.95, 0.80)
const ATTACKED_TEXT_COLOR: Color = Color(0.25, 0.25, 0.25)
const NGUYEN_TEXT_COLOR: Color = Color(1.0, 1.0, 1.0)
const NAME_FONT_SIZE: int = 15
const HP_RADIUS: float = 9.0
## Chấm máu, tính từ tâm đồng.
const HP_OFFSET: Vector2 = Vector2(19, 17)
const HP_BORDER_WIDTH: float = 1.5
const HP_COLOR: Color = Color(1.0, 1.0, 1.0)
const HP_TEXT_COLOR: Color = Color(0.12, 0.10, 0.08)
const HP_FONT_SIZE: int = 12

## UnitType -> khóa dịch của chữ trên đồng quân.
const NAME_KEYS: Dictionary = {
	UnitType.NGUYEN_KHOAI: "unit.nguyen_khoai",
	UnitType.PHAM_NGU_LAO: "unit.pham_ngu_lao",
	UnitType.TRAN_KHANH_DU: "unit.tran_khanh_du",
	UnitType.BO_BINH: "unit.bo_binh",
	UnitType.KY_BINH: "unit.ky_binh",
	UnitType.CUNG_KY: "unit.cung_ky",
}

var unit_id: int = 0
## UnitType. Đổi loại thì BoardView dựng đồng mới, không gọi update().
var unit_type: int = -1
## Ô đang đứng (để BoardView.pick_cell biết bấm trúng đồng là ô nào).
var cell: Vector2i = Vector2i.ZERO
var _faction: Unit.Faction = Unit.Faction.DAI_VIET
var _moved: bool = false
var _attacked: bool = false
## Hướng đứng, chỉ số của UnitArt.FACING_NAMES. BoardView đặt theo địch gần nhất.
var _facing: int = UnitArt.DEFAULT_FACING_DAI_VIET
## Khung chuyển động đang phát (Story 8.4); rỗng là vẽ hình đứng yên. Tween khung thuộc token, chạy song song với
## tween vị trí của EventPlayer (EventPlayer._new_tween giết tween cũ nên không dùng chung).
var _clip: Array[Texture2D] = []
var _clip_index: int = 0
var _clip_tween: Tween = null
## Hào quang Sát Thát sau lưng (BoardView bật theo bản chụp).
var _aura: bool = false
var _name_label: Label
var _hp_label: Label


## lift: mặt ô cao hơn mặt đất bao nhiêu (bệ ô ải).
func setup(unit: Unit, lift: float = 0.0) -> void:
	unit_id = unit.id
	unit_type = unit.type
	_faction = unit.faction
	_facing = UnitArt.DEFAULT_FACING_DAI_VIET if _faction == Unit.Faction.DAI_VIET else UnitArt.DEFAULT_FACING_NGUYEN
	var text_color: Color = DAI_VIET_TEXT_COLOR if _faction == Unit.Faction.DAI_VIET else NGUYEN_TEXT_COLOR

	var coin: Vector2 = Vector2(0, -TOKEN_LIFT)
	_name_label = _centered_label(Vector2(RADIUS * 2, RADIUS * 2), coin)
	_name_label.text = tr(NAME_KEYS[unit.type] as String)
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	_name_label.add_theme_color_override("font_color", text_color)
	_name_label.visible = SHOW_NAMES

	_hp_label = _centered_label(Vector2(HP_RADIUS * 2, HP_RADIUS * 2), coin + HP_OFFSET)
	_hp_label.add_theme_font_size_override("font_size", HP_FONT_SIZE)
	_hp_label.add_theme_color_override("font_color", HP_TEXT_COLOR)
	update(unit, lift)


func update(unit: Unit, lift: float = 0.0) -> void:
	# Bản chụp mới là nguồn đúng: trả lại trạng thái hiện cho đồng quân dùng lại sau một lượt phát bị ngắt
	# (hoạt ảnh gục/chết đuối có thể đã ẩn hoặc làm mờ nó — Story 2.11 review).
	visible = true
	modulate = Color.WHITE
	clear_clip()
	cell = unit.cell
	position = BoardView.cell_center(unit.cell) - Vector2(0, lift)
	_hp_label.text = str(unit.hp)
	if unit.has_moved != _moved:
		_moved = unit.has_moved
		queue_redraw()
	if unit.has_attacked != _attacked:
		_attacked = unit.has_attacked
		_name_label.add_theme_color_override("font_color", ATTACKED_TEXT_COLOR if _attacked else DAI_VIET_TEXT_COLOR)
		queue_redraw()


func is_moved() -> bool:
	return _moved


func is_attacked() -> bool:
	return _attacked


func name_text() -> String:
	return _name_label.text


func hp_text() -> String:
	return _hp_label.text


## point tính từ chân đồng: có nằm trên mặt đồng không.
func hit(point: Vector2) -> bool:
	return point.distance_to(Vector2(0, -TOKEN_LIFT)) <= RADIUS


func _centered_label(box: Vector2, center: Vector2) -> Label:
	var label: Label = Label.new()
	label.size = box
	label.position = center - box / 2.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(label)
	return label


func set_facing(p_facing: int) -> void:
	var wrapped: int = posmod(p_facing, UnitArt.FACING_NAMES.size())
	if wrapped != _facing:
		_facing = wrapped
		queue_redraw()


func facing() -> int:
	return _facing


func facing_name() -> String:
	return UnitArt.FACING_NAMES[_facing]


## Phát các khung trong seconds giây, thay khung đang chạy (không chồng). hold: dừng ở khung cuối (gục, chết đuối);
## không thì hết giờ quay về hình đứng yên.
func play_clip(frames: Array[Texture2D], seconds: float, hold: bool = false) -> void:
	clear_clip()
	if frames.is_empty() or not is_inside_tree():
		return
	_clip = frames
	_clip_index = 0
	queue_redraw()
	_clip_tween = create_tween()
	_clip_tween.tween_method(_set_clip_frame, 0.0, float(frames.size()), maxf(seconds, 0.001))
	if not hold:
		_clip_tween.tween_callback(clear_clip)


func clear_clip() -> void:
	if _clip_tween != null:
		_clip_tween.kill()
		_clip_tween = null
	if not _clip.is_empty():
		_clip = []
		queue_redraw()


func has_clip() -> bool:
	return not _clip.is_empty()


func _set_clip_frame(value: float) -> void:
	var index: int = clampi(int(value), 0, _clip.size() - 1) if not _clip.is_empty() else 0
	if index != _clip_index:
		_clip_index = index
		queue_redraw()


## Hào quang Sát Thát (Story 8.4): chỉ vẽ lại mỗi khung khi đang bật.
func set_aura(on: bool) -> void:
	_aura = on
	set_process(on)
	queue_redraw()


func has_aura() -> bool:
	return _aura


func _process(_delta: float) -> void:
	queue_redraw()


## Màu nhân của hình theo trạng thái: đã đánh rõ hơn đã đi; trắng là còn nguyên lượt.
## Chỉ quân Đại Việt đổi màu: cờ của quân Nguyên còn nguyên suốt lượt người chơi, tô xỉn sẽ dễ nhầm là quân ta hết lượt.
func tint() -> Color:
	if _faction != Unit.Faction.DAI_VIET:
		return Color.WHITE
	if _attacked:
		return ATTACKED_TINT
	return MOVED_TINT if _moved else Color.WHITE


func _draw() -> void:
	draw_texture(Art.tex(SHADOW_TEXTURE), Vector2(-SHADOW_SIZE.x / 2.0, FOOT_DROP - SHADOW_RAISE - SHADOW_SIZE.y / 2.0))
	var origin: Vector2 = Vector2(-SPRITE_SIZE / 2.0, FOOT_DROP - SPRITE_FEET_Y)
	if _aura:
		_draw_aura(origin)
	var frame: Texture2D = _clip[_clip_index] if not _clip.is_empty() else Art.tex(UnitArt.sprite_path(unit_type, _facing))
	draw_texture(frame, origin, tint())
	var coin: Vector2 = Vector2(0, -TOKEN_LIFT)
	draw_circle(coin + HP_OFFSET, HP_RADIUS, HP_COLOR)
	draw_circle(coin + HP_OFFSET, HP_RADIUS, BoardView.LINE_COLOR, false, HP_BORDER_WIDTH, true)


## Hào quang 48×48 đặt giữa thân, nhịp thở nhẹ theo đồng hồ (hiển thị, không ảnh hưởng luật).
func _draw_aura(origin: Vector2) -> void:
	var texture: Texture2D = Art.tex(FxArt.HAO_QUANG)
	var breath: float = 1.0 + AURA_BREATH * sin(float(Time.get_ticks_msec()) / 1000.0 * AURA_SPEED)
	var size: Vector2 = texture.get_size() * breath
	var center: Vector2 = origin + Vector2(SPRITE_SIZE / 2.0, SPRITE_FEET_Y - AURA_LIFT)
	draw_texture_rect(texture, Rect2(center - size / 2.0, size), false)
