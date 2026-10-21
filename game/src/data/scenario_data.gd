class_name ScenarioData
extends RefCounted
## Một kịch bản luật đã nạp từ tests/kich_ban/<nhóm>/*.json. Chỉ đọc: ScenarioLoader tạo.
## Bàn trước là LevelData (dựng BattleState như trận thật); bàn sau so theo ô, không theo id.

## Ô của lệnh không cần ô (huy, ket_thuc_luot).
const NO_CELL: Vector2i = Vector2i(-1, -1)


## Một lệnh trong "hanh_dong". Story 1.4 đổi thành Command.
class ScenarioStep:
	extends RefCounted

	## "di", "danh", "huy", "ket_thuc_luot"
	var kind: String
	## UnitType của tướng ra lệnh; -1 nếu lệnh không cần tướng.
	var general: int
	var cell: Vector2i
	## Mã lý do luật phải từ chối lệnh ("tu_choi", một khóa của ScenarioLoader.REJECT_CODES);
	## "" là lệnh phải chạy được.
	var reject: String

	func _init(p_kind: String, p_general: int = -1, p_cell: Vector2i = NO_CELL, p_reject: String = "") -> void:
		kind = p_kind
		general = p_general
		cell = p_cell
		reject = p_reject


## Một quân mong đợi ở bàn sau. hp đã đổi "không ghi" thành máu đầy lúc nạp.
class ExpectedUnit:
	extends RefCounted

	var type: int
	var cell: Vector2i
	var hp: int

	func _init(p_type: int, p_cell: Vector2i, p_hp: int) -> void:
		type = p_type
		cell = p_cell
		hp = p_hp


## Một đòn mong đợi ở bàn sau ("sau.bao_don", Story 2.6). Chủ đòn chỉ theo ô (bàn sau so theo ô, không theo id).
class ExpectedTelegraph:
	extends RefCounted

	var order: int
	var owner_cell: Vector2i
	var kind: Telegraph.Kind
	## CELL: ô bị nhắm (tuyệt đối). DIRECTION: hướng xung phong (một phần tử của Grid.DIRECTIONS).
	var target: Vector2i

	func _init(p_order: int, p_owner_cell: Vector2i, p_kind: Telegraph.Kind, p_target: Vector2i) -> void:
		order = p_order
		owner_cell = p_owner_cell
		kind = p_kind
		target = p_target


## Đường res:// (hoặc user:// trong test).
var path: String = ""
## Tính từ thư mục kich_ban, ví dụ "di_chuyen/di_thang_3_o.json".
var id: String = ""
## Thư mục con đầu tiên ("di_chuyen"); "" nếu file nằm ngay trong kich_ban.
var group: String = ""
var description: String = ""
var approved: bool = false
var before: LevelData = null
var steps: Array[ScenarioStep] = []
## Theo hàng: index = hang * size.x + cot (như LevelData).
var after_terrain: PackedInt32Array = PackedInt32Array()
## Theo thứ tự đọc bàn: hàng trên xuống, trái sang phải.
var after_units: Array[ExpectedUnit] = []
## Hiệp mong đợi ("sau.hiep"); 0 là không kiểm.
var after_round: int = 0
## Có kiểm dấu "đã đi" không ("sau.da_di" có ghi, kể cả []).
var checks_moved: bool = false
## UnitType các tướng phải đã đi; tướng khác trên bàn phải chưa đi.
var after_moved: Array[int] = []
## Có kiểm dấu "đã đánh" không ("sau.da_danh" có ghi, kể cả []).
var checks_attacked: bool = false
## UnitType các tướng phải đã đánh; tướng khác trên bàn phải chưa đánh.
var after_attacked: Array[int] = []
## Kết cục mong đợi ("sau.ket_qua": "dang_choi", "thang", "thua"); "" là không kiểm.
var after_outcome: String = ""
## Có kiểm đòn đã báo không ("sau.bao_don" có ghi, kể cả []).
var checks_telegraphs: bool = false
## Theo số thứ tự tăng dần.
var after_telegraphs: Array[ExpectedTelegraph] = []
## Có kiểm ô đỏ không ("sau.o_do" có ghi, kể cả {}).
var checks_marks: bool = false
## Ô -> Array[int] số thứ tự đòn phủ ô đó, tăng dần (Story 2.7).
var after_marks: Dictionary = {}
