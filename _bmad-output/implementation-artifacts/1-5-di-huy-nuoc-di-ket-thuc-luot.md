---
baseline_commit: 02a300ccbeb8855bed37bfbb2fb980c46ec953c0
---

# Story 1.5: Đi, hủy nước đi, kết thúc lượt

Status: done

## Story

Là người chơi,
tôi muốn đi, hủy nước vừa đi và kết thúc lượt,
để thử nhiều cách đứng mà không sợ bấm nhầm.

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 7 kịch bản mới ở Dev Notes "Đợt kịch bản 2" (`da_duyet: false`) và phần khung ở Task 1.1 (mã từ chối mới, `huy` nhận `tu_choi`, chữ của công cụ duyệt). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 8 đã duyệt · 7 chưa duyệt (7 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh`. Chưa duyệt xong thì không viết dòng code luật nào (`rules_*.gd`, `BattleController.submit/undo`).
2. **Khi** tác giả duyệt (đổi `da_duyet` thành `true`, hoặc nhắn AI "đúng"), **thì** `tools/test.sh` **trượt**, vì kịch bản đã duyệt chưa đạt. Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 15 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh (`di`, `huy`, `ket_thuc_luot`), `BattleState.validate()` rỗng (bộ chạy kiểm).
4. **Đi (FR9).** **Cho** trận 1 đang mở (`tools/chay.sh`), đã chọn Nguyễn Khoái. **Khi** bấm ô sáng `0,4`, **thì**:
   - đồng "Khoái" sang ô `0,4`;
   - Khoái vẫn đang chọn (vòng vàng ở `0,4`) nhưng **không còn ô sáng nào**: không đi tiếp được nữa;
   - đồng "Khoái" có dấu hiệu "đã đi", nhìn khác hẳn đồng "Lão" chưa đi (AC 8).

   Còn lượt đánh nhưng đánh có ở E2, nên story này chưa có gì để bấm.
5. **Hủy (FR10)** **[Tác giả chốt 2026-10-18: chỉ hủy được một nước]**. **Khi** bấm nút **Hủy** (hoặc phím `Z`), **thì** chỉ **nước đi gần nhất** được hoàn tác: tướng về ô cũ, hết dấu "đã đi", và đi lại được (nếu đang chọn tướng đó thì ô sáng hiện lại ngay). Đi cả Khoái rồi Lão, bấm Hủy thì chỉ Lão về chỗ cũ; **bấm thêm lần nữa thì không có gì xảy ra**, Khoái vẫn ở ô mới. Phải đi một nước mới thì mới hủy được tiếp (hủy nước mới đó).
6. **Khi** vừa hủy xong (hoặc chưa đi nước nào) mà vẫn bấm `Z`, **thì** không có gì xảy ra, game không lỗi. Lúc đó nút Hủy **mờ đi** (không bấm được).
7. **Kết thúc lượt (FR11).** **Khi** bấm nút **Kết thúc lượt** (hoặc phím `Space`), **thì**:
   - dòng "Hiệp 1" ở bảng bên phải đổi thành "Hiệp 2";
   - mọi tướng hết dấu "đã đi" và đi lại được;
   - bỏ chọn tướng; nút Hủy mờ đi (không hủy được nước đi của lượt trước).

   Pha địch sẽ chèn vào giữa bước này ở E2.
8. **Dấu "đã đi".** Tướng đã đi có đồng quân **nhạt màu hơn** (nền đỏ chuyển sang màu xỉn), chữ và số máu vẫn đọc được; tướng chưa hành động giữ màu đỏ đậm. Không dùng độ trong suốt (bóng mờ dành cho xem trước kết quả đòn ở E2).
9. **Chỉ bằng chuột (NFR8).** Mọi thao tác ở AC 4–7 làm được chỉ bằng bấm chuột. `Z` và `Space` chỉ là lối tắt, khai báo trong InputMap. Giữ phím `Space` không làm kết thúc nhiều lượt liền. Bấm nút bằng chuột rồi gõ `Space` không làm nút đó bị bấm thêm lần nữa.
10. **Màn hình lỗi và menu tạm** không có bảng nút, không phản ứng với `Z`, `Space`. Bật dev và F1 thì sau khi đi, hủy, id quân trên lớp F1 nằm đúng ô mới.

## Tasks / Subtasks

- [x] **Task 1: Khung cho kịch bản mới, viết đợt kịch bản 2, dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Khung (không phải code luật, làm trước để file kịch bản nạp được):
    - `src/core/battle_event.gd`: thêm `Reject.ALREADY_MOVED`, `Reject.NOTHING_TO_UNDO` (thêm vào **cuối** enum).
    - `src/data/scenario_loader.gd`: `COMMANDS["huy"] = ["tu_choi"]`; `REJECT_CODES` thêm `"da_di_roi": "scenario.viewer.reject_already_moved"`, `"khong_con_nuoc_di": "scenario.viewer.reject_nothing_to_undo"`; sửa `REJECT_LIST` cho đủ 6 mã.
    - `tests/scenario_runner.gd`: `REJECT_EVENTS` thêm `"da_di_roi": BattleEvent.Reject.ALREADY_MOVED`, `"khong_con_nuoc_di": BattleEvent.Reject.NOTHING_TO_UNDO` (cùng thứ tự với `REJECT_CODES`; test ở `test_scenario_loader.gd:540-541` kiểm).
    - `i18n/text.csv`: `scenario.viewer.reject_already_moved` = `tướng đã đi rồi trong lượt này`; `scenario.viewer.reject_nothing_to_undo` = `không còn nước đi nào để hủy`.
    - `tests/test_scenario_loader.gd`: test ở dòng ~358-366 (`huy` kèm `tu_choi` bị cảnh báo khóa lạ) đổi sang dùng `ket_thuc_luot` (lệnh này vẫn không nhận `tu_choi`). Sửa các câu lỗi có `REJECT_LIST`. Thêm test: `huy` có `"tu_choi": "khong_con_nuoc_di"` nạp được.
  - [x] 1.2 Viết 7 file đúng như Dev Notes "Đợt kịch bản 2", `"da_duyet": false`. Không đụng 8 kịch bản `di_chuyen/` đã duyệt.
  - [x] 1.3 `tools/xem_kich_ban.sh`: đọc lại từng bàn trước/sau, khớp `mo_ta`; dòng `tu_choi` hiện đúng câu tiếng Việt. `tools/test.sh`: xanh, `8 đã duyệt · 7 chưa duyệt (7 chưa đạt)`, lý do khớp bảng.
  - [x] 1.4 Commit: `Kịch bản hủy và kết thúc lượt chờ duyệt (Story 1.5)`.
  - [x] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh`, đọc 7 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ kịch bản `huy/huy_hai_lan.json` đã viết theo chốt "chỉ hủy được một nước". Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì sửa, cho duyệt lại (lặp 1.3–1.6). `tools/test.sh` **phải trượt** (AC 2). Ghi Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật: cờ "đã đi", số hiệp, lệnh kết thúc lượt** (AC: 3, 4, 7)
  - [x] 2.1 `src/core/unit.gd`: thêm `var has_moved: bool`, gán trong `_init` qua tham số cuối `p_has_moved: bool = false`. Sửa chú thích đầu file: vị trí và máu chỉ `Effects` đổi; cờ `has_moved` do `RulesMove` (đặt) và `RulesEnemyPhase` (xóa) đổi.
  - [x] 2.2 `src/core/battle_state.gd`: thêm `var round_number: int = 1` (hiệp hiện tại, bắt đầu từ 1). **`clone()` chép cả `round_number` và `has_moved` của từng quân** (`Unit.new(u.id, u.type, u.cell, u.hp, u.has_moved)`). `validate()` thêm: `round_number < 1` là sai.
  - [x] 2.3 `src/core/command.gd`: `enum Kind { MOVE, END_TURN }`; `static func end_turn() -> Command` (`unit_id` 0, `cell` `Vector2i(-1, -1)`).
  - [x] 2.4 `src/core/battle_event.gd`: `Type.ROUND_STARTED` (sang hiệp mới); trường `round_number: int = 0`, gán trong `_init` (tham số cuối, mặc định 0); hàm tạo `round_started(p_round: int)`.
  - [x] 2.5 `src/core/rules_move.gd`:
    - `resolve`: sau bước kiểm `NOT_GENERAL`, nếu `unit.has_moved` thì từ chối `Reject.ALREADY_MOVED`, lý do `quân %d đã đi rồi trong lượt này`. Đi xong (sau vòng `Effects.move`) thì `unit.has_moved = true`.
    - `reachable`: tướng đã đi thì trả `[]`. `path_to` cũng trả `[]`.
    - Sửa chú thích đầu file (bỏ "Cờ đã đi thêm ở Story 1.5").
  - [x] 2.6 `src/core/rules_enemy_phase.gd` (MỚI, `class_name RulesEnemyPhase`): `static func end_player_turn(state, events)`. Story này chỉ làm phần cuối hiệp: `state.round_number += 1`, xóa `has_moved` của **mọi** quân (duyệt theo `state.units`), `events.append(BattleEvent.round_started(state.round_number))`. Chú thích: pha địch ra đòn, cuối hiệp (kho lương, tiếp viện), địch chuẩn bị chèn vào đây ở E2–E3, theo "Mẫu trạng thái" của kiến trúc. **Chưa** thêm `Phase` (Story 2.6 thêm khi có pha địch).
  - [x] 2.7 `src/core/rules.gd`: `Command.Kind.END_TURN` → `RulesEnemyPhase.end_player_turn(state, events)`.
- [x] **Task 3: BattleController: `submit`, bản chụp hủy, cứu trận** (AC: 3, 5, 6, 7)
  - [x] 3.1 `src/battle/battle_controller.gd`, theo Dev Notes "BattleController":
    - `signal events_resolved(events: Array[BattleEvent], snapshot: BattleState)` và `signal rolled_back(problems: Array[String])`;
    - `var _undo_snapshot: BattleState = null` (bản chụp trước nước đi gần nhất; chỉ giữ **một**, tác giả chốt); `start()` đặt lại `null`;
    - `submit(command: Command) -> Array[BattleEvent]`;
    - `undo() -> Array[BattleEvent]`;
    - `can_undo() -> bool`;
    - `_resolve(state, command) -> Array[BattleEvent]` (chỉ gọi `Rules.resolve`; tách ra để test thay được, Task 6.2).
  - [x] 3.2 Sửa chú thích đầu file. Giữ `reachable`, `path_to`, `snapshot` như cũ.
- [x] **Task 4: Bộ chạy kịch bản chạy qua BattleController** (AC: 1, 3)
  - [x] 4.1 `tests/scenario_runner.gd`: bỏ `"huy"`, `"ket_thuc_luot"` khỏi `PENDING_RULES` (chỉ còn `"danh": "2.1"`). `run()` dựng `BattleController` từ `scenario.before` (`start(scenario.before, stats)`), không gọi `Rules.resolve` trực tiếp nữa:
    - kiểm `controller.snapshot().validate()` ngay sau `start` (giữ câu `trước: ...`);
    - nối `rolled_back` vào một mảng; sau mỗi bước, mảng có câu thì bước đó trượt `vi phạm bất biến: <câu>` (controller đã quay lại, nên `validate()` trên bản chụp không còn thấy lỗi);
    - `di` → `controller.submit(Command.move(id, ô))`; `ket_thuc_luot` → `controller.submit(Command.end_turn())`; `huy` → `controller.undo()`. Cả ba đi qua `_check_reject(events, step.reject)`;
    - sau mỗi bước vẫn chạy `validate()` trên `controller.snapshot()`; cuối cùng `compare(controller.snapshot(), scenario)`.
  - [x] 4.2 `_general(state, type)` tìm trên `controller.snapshot()`.
  - [x] 4.3 `tests/test_scenario_loader.gd`: `test_runner_stops_at_command_without_rule` đổi sang lệnh `danh` (`lệnh "danh" chưa có luật (Story 2.1)`). Thêm test bộ chạy: `huy` sau `di` (bàn về như trước); `huy` không có gì để hủy mà kịch bản không ghi `tu_choi` thì trượt đúng câu; `ket_thuc_luot` rồi `di` lại được.
- [x] **Task 5: Test lõi luật và controller** (AC: 3)
  - [x] 5.1 `tests/test_rules_move.gd` thêm: đi xong thì `has_moved` bật; `reachable` rỗng; lệnh đi lần hai bị `REJECTED` với `Reject.ALREADY_MOVED`, state giữ nguyên (so từng quân); lệnh bị từ chối **không** bật `has_moved`; tướng khác vẫn đi được. Mỗi ca `validate()` rỗng.
  - [x] 5.2 `tests/test_rules_enemy_phase.gd` (MỚI): `end_player_turn` tăng `round_number` 1→2→3; xóa `has_moved` của mọi tướng; sinh đúng một `ROUND_STARTED` với `round_number` mới; không đổi ô, máu; `validate()` rỗng; gọi hai lần trên hai bản clone ra cùng sự kiện.
  - [x] 5.3 `tests/test_battle_state.gd`: `test_clone_is_deep` kiểm thêm `has_moved` và `round_number` (đổi trên bản sao không ảnh hưởng bản gốc, và bản sao chép đúng giá trị). Thêm ca `validate()` với `round_number = 0`.
  - [x] 5.4 Kiểm test bắt lỗi thật (như Story 1.4 Task 5.2), mỗi lần sửa tạm một chỗ rồi trả lại, ghi Debug Log:
    - bỏ dòng xóa `_undo_snapshot` khi kết thúc lượt → kịch bản `hiep/ket_thuc_luot_xoa_huy.json` và test controller phải trượt;
    - bỏ dòng `unit.has_moved = true` → kịch bản `di_chuyen/di_hai_lan.json` và test luật phải trượt;
    - bỏ chép `has_moved` trong `clone()` → `test_clone_is_deep` phải trượt (kịch bản không bắt được ca này, vì bản chụp hủy luôn chụp lúc tướng chưa đi).
- [x] **Task 6: Test BattleController** (AC: 3, 5, 6, 7)
  - [x] 6.1 `tests/test_battle_controller.gd` (MỚI), dựng `LevelData` nhỏ bằng tay (như `test_rules_move.gd`, không phụ thuộc file trận):
    - `submit(move)` hợp lệ: ô đổi, `can_undo()` true, `events_resolved` phát một lần, bản chụp kèm theo **không phải** state sống (sửa bản chụp không đổi `snapshot()` sau đó);
    - `submit` bị từ chối: không đổi bản chụp hủy (nước đi trước đó vẫn hủy được), không phát `events_resolved`;
    - `undo()`: về ô cũ, `has_moved` tắt; hai nước đi thì `undo()` chỉ trả nước thứ hai; `undo()` lần nữa trả một `REJECTED` `NOTHING_TO_UNDO`, không phát signal, tướng đi trước vẫn ở ô mới; đi thêm một nước thì `can_undo()` lại true;
    - `submit(end_turn)`: `round_number` tăng, `can_undo()` false;
    - `start()` lại thì `can_undo()` false.
  - [x] 6.2 Ca cứu trận: lớp con trong file test `extends BattleController`, ghi đè `_resolve` để làm hỏng state (ví dụ đặt hai quân chung ô, test không bị `check_boundaries.sh` quét). Kiểm: `rolled_back` phát kèm câu lỗi, `snapshot()` giống hệt trước lệnh, bản chụp hủy không đổi (`can_undo()` như trước lệnh), `events_resolved` không phát, log có dòng `[ERROR][battle]`.
- [x] **Task 7: Input, HUD, BattleView, đồng quân** (AC: 4–10)
  - [x] 7.1 `src/battle/battle_input.gd`: đăng ký thêm action `undo_move` (phím vật lý `KEY_Z`) và `end_turn` (`KEY_SPACE`) theo đúng mẫu `GENERAL_ACTIONS` (đã có thì bỏ qua). Signal `undo_pressed`, `end_turn_pressed`. Dùng `is_action_pressed(action, false, true)` (không nhận lặp phím) như phím 1-2-3.
  - [x] 7.2 `src/ui/hud.gd` (MỚI, `class_name Hud extends Control`), dựng hoàn toàn bằng code theo Dev Notes "HUD":
    - nhãn hiệp `tr("hud.round") % n`, nút Hủy `tr("hud.undo")`, nút Kết thúc lượt `tr("hud.end_turn")`;
    - signal `undo_pressed`, `end_turn_pressed`;
    - `show_turn(round_number: int, can_undo: bool)`; ẩn khi không có trận (`visible = false`);
    - **mọi nút `focus_mode = Control.FOCUS_NONE`**; phần không phải nút `mouse_filter = MOUSE_FILTER_IGNORE`.
  - [x] 7.3 `src/battle/battle_view.gd`, theo bảng ở Dev Notes "Chọn, đi, hủy, kết thúc lượt":
    - `setup(board, input, hud)` nối thêm `undo_pressed`, `end_turn_pressed` của cả `BattleInput` và `Hud`;
    - `start(controller)` nối `controller.events_resolved` → `_on_events_resolved`; cập nhật HUD (`show_turn`), hiện HUD. `stop()` ẩn HUD;
    - bấm ô sáng → `_controller.submit(Command.move(_selected, ô))`;
    - `_on_events_resolved`: làm mới chọn (`_refresh_selection()`: tướng đang chọn còn trên bàn thì tính lại `_cells` từ `controller.reachable`, vẽ lại vòng chọn ở ô mới, vẽ lại đường đi theo ô chuột đang trỏ; không còn thì bỏ chọn), cập nhật HUD. Đây là chỗ xử lý mục hoãn "`_cells` tính một lần" của Story 1.4;
    - hủy → `_controller.undo()`; kết thúc lượt → `_controller.submit(Command.end_turn())` rồi bỏ chọn.
  - [x] 7.4 `src/battle/unit_token.gd`: `update(unit)` nhận `unit.has_moved`, `queue_redraw()` khi đổi; `_draw` dùng `DAI_VIET_MOVED_COLOR` cho tướng đã đi. Thêm `is_moved() -> bool` (chỉ đọc, cho test). Quân Nguyên không đổi màu.
  - [x] 7.5 `src/app/main.gd`: tạo `Hud` một lần trong `_ready` (sau bàn cờ, trước nhãn phiên bản), truyền vào `BattleView.setup`. `_start_battle` thành công: nối `_controller.events_resolved` → `_on_events_resolved(events, snapshot)` gọi `_show_board(snapshot)` (đồng quân **và** lớp F1), **trước** khi gọi `_battle_view.start(_controller)`. `_show_error` / `_show_menu` không đổi ngoài việc `stop()` đã ẩn HUD. `test_main.gd` phải xanh nguyên.
  - [x] 7.6 `i18n/text.csv`: `hud.round` = `Hiệp %d`; `hud.undo` = `Hủy (Z)`; `hud.end_turn` = `Kết thúc lượt (Space)`. `tools/test.sh` tự `--import` lại `text.vi.translation`; commit cả file đó.
- [x] **Task 8: Test giao diện trận** (AC: 4–10)
  - [x] 8.1 `tests/test_battle_view.gd` thêm (trận 1 thật, như các test sẵn có):
    - chọn Khoái, bấm ô `0,4` (qua `_battle_input(main)._unhandled_input` với sự kiện chuột thật): đồng ở `0,4`, `is_moved()` true, vẫn chọn Khoái, `lit_cells()` rỗng, vòng chọn ở `0,4`;
    - phím `Z` (gửi **`InputEventKey` thật** với `physical_keycode = KEY_Z`, như ca `KEY_1` của review 1.4): Khoái về `0,6`, hết `is_moved()`, ô sáng hiện lại đúng `KHOAI_CELLS`;
    - đi Khoái rồi Lão, bấm nút Hủy (`hud.undo_pressed.emit()` hoặc `Button.pressed.emit()`): chỉ Lão về; nút Hủy `disabled`;
    - `Z` ngay sau đó: không đổi (Khoái vẫn ở ô mới), không lỗi;
    - `Space` (InputEventKey thật): nhãn hiệp "Hiệp 2", bỏ chọn, Khoái đi lại được, nút Hủy `disabled`;
    - giữ `Space` (sự kiện `echo = true`): không kết thúc thêm lượt;
    - màn hình lỗi: HUD ẩn, `Z`/`Space` không làm gì;
    - bật dev, bật F1, đi Khoái: lớp F1 có id `1` ở ô mới.
  - [x] 8.2 `after_each` xóa thêm action `undo_move`, `end_turn`.
  - [x] 8.3 `tests/test_i18n.gd` (nếu có kiểm danh sách khóa) phải xanh với 5 khóa mới.
- [x] **Task 9: Tài liệu, kiểm bằng mắt, commit** (AC: 3–10)
  - [x] 9.1 `_bmad-output/planning-artifacts/game-architecture.md`:
    - mục "Dữ liệu trận, chỉ số và kịch bản luật", dòng `hanh_dong`: thêm mã `da_di_roi`, `khong_con_nuoc_di` vào danh sách mã `tu_choi`, ghi `huy` cũng nhận `tu_choi`;
    - mục "Quản lý trạng thái" (Hoàn tác) và "Bảng thứ tự phân giải" (Hủy nước đi): đổi "ngăn xếp… vào sau ra trước" thành "chỉ giữ một bản chụp: hủy được đúng một nước, hủy xong phải đi nước mới mới hủy tiếp được (tác giả chốt 2026-10-18)". Đánh, mưu kế, kết thúc lượt xóa bản chụp đó. `project-context.md` (mục "Những điều không được quên", câu Hủy nước đi) sửa theo cùng ý.
  - [x] 9.2 Chạy `tools/chay.sh --dev` ở chế độ nền, chờ ~5 giây. Dùng GoPeak: `inject_action` (`select_general_1`, `undo_move`, `end_turn`; `inject_key` không kích hoạt action theo phím vật lý, xem Debug Log 1.4), `inject_mouse_click` vào ô `0,4` (pixel = vị trí bàn `(332, 52)` + `cell_center`, tức `(376, 448)`), `capture_screenshot` sau mỗi bước. Xem: màu "đã đi" khác rõ màu tướng chưa đi, chữ và số máu còn đọc được; bảng bên phải không đè bàn cờ, không đè nhãn phiên bản; nút Hủy mờ khi không hủy được. Tắt game. Ghi Debug Log.
  - [x] 9.3 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, `.uid` mới, `text.vi.translation`. Ví dụ: `Đi, hủy nước đi, kết thúc lượt; kịch bản huy và hiep (Story 1.5)`.
  - [x] 9.4 Ghi hướng dẫn tác giả tự test vào Completion Notes theo mẫu ở mục Testing, dùng kết quả thật.

### Review Findings

- [x] [Review][Decision] Kịch bản luật không kiểm được dấu "đã đi" và số hiệp — tác giả chốt 2026-10-18: thêm khóa vào phần "sau" (`hiep`: số hiệp, `da_di`: tướng nào đã đi), công cụ duyệt hiện hai thông tin này. Thành Patch bên dưới.
- [x] [Review][Patch] Phần "sau" của kịch bản thêm `hiep` và `da_di`: bộ nạp đọc, bộ chạy so, công cụ duyệt hiện; sửa 6 kịch bản `huy/` và `hiep/`, đặt `da_duyet: false`, chờ tác giả duyệt lại [game/src/data/scenario_loader.gd:14]
- [x] [Review][Patch] Test quay lại khi hỏng bất biến yếu: chưa đi nước nào nên `can_undo()` luôn false; chỉ so ô, không so máu, dấu "đã đi", số hiệp (Task 6.2 "giống hệt") [game/tests/test_battle_controller.gd]
- [x] [Review][Patch] Màn menu chưa test bảng nút bị ẩn và phím Z/Space không làm gì (AC 10, Task 8.1) [game/tests/test_battle_view.gd]
- [x] [Review][Patch] Chưa test (cũng chưa thử tay) "bấm nút bằng chuột rồi gõ Space" chỉ kết thúc một lượt; test hiện chỉ kiểm `focus_mode` (AC 9, Dev Notes HUD) [game/tests/test_battle_view.gd]
- [x] [Review][Dismiss] Đường đi cũ còn vẽ khi chuột rê thẳng từ bàn cờ sang nút Hủy/Kết thúc lượt — báo nhầm: đã thử trong Godot 4.7.2, nút không nuốt sự kiện di chuột (vẫn tới `_unhandled_input`), đường đi mất đúng. Giữ test `test_mouse_onto_button_clears_path` để canh [game/tests/test_battle_view.gd]
- [x] [Review][Patch] Bộ nạp kịch bản nhận mã `tu_choi` không hợp với lệnh (`huy` + `khong_toi_duoc`, `di` + `khong_con_nuoc_di`): tác giả có thể duyệt một kịch bản không bao giờ đạt [game/src/data/scenario_loader.gd:281]
- [x] [Review][Patch] `Log.debug` cho lệnh nhận vào chỉ ghi khi lệnh chạy được; lệnh bị quay lại không có dòng nào nói đó là lệnh gì (Dev Notes BattleController) [game/src/battle/battle_controller.gd:47]
- [x] [Review][Patch] `epics.md` còn nói "ngăn xếp bản chụp" / "ngăn xếp hủy nước đi", trái với quyết định chỉ hủy một nước [_bmad-output/planning-artifacts/epics.md:120,910]
- [x] [Review][Patch] Dev Agent Record thiếu "Agent Model Used" [_bmad-output/implementation-artifacts/1-5-di-huy-nuoc-di-ket-thuc-luot.md]
- [x] [Review][Defer] Lệnh bị từ chối không khôi phục `before`: an toàn chỉ vì luật hiện kiểm hết rồi mới sửa; luật "đánh" ở E2 mà sửa rồi mới từ chối thì trận lệch nửa chừng [game/src/battle/battle_controller.gd:37] — deferred, chưa gặp được; xét lại ở Story 2.1
- [x] [Review][Defer] Kết thúc lượt luôn bỏ chọn kể cả khi lệnh bị quay lại [game/src/battle/battle_view.gd:97] — deferred, chưa gặp được tới khi pha địch E2 có luật
- [x] [Review][Defer] Hủy phát `events_resolved` với danh sách sự kiện rỗng, chưa có loại sự kiện "đã hủy" [game/src/battle/battle_controller.gd:67] — deferred, cần khi có EventPlayer/hoạt ảnh
- [x] [Review][Defer] Phím Z gán theo vị trí vật lý: bàn phím AZERTY thì nút ghi "(Z)" nhưng phím W mới hủy [game/src/battle/battle_input.gd:27] — deferred, theo mẫu phím 1-2-3; bàn phím Việt là QWERTY
- [x] [Review][Defer] Vẽ lại đúng phụ thuộc thứ tự nối signal trong `main.gd` (bàn cờ trước, BattleView sau); chưa có test giữ thứ tự [game/src/app/main.gd:113] — deferred, đã ghi chú trong code

## Dev Notes

### Bối cảnh

- Story luật thứ hai. Quy trình M3 đã chạy trơn ở Story 1.4: AI viết kịch bản → tác giả duyệt → trượt → viết code tới khi xanh. Đọc kỹ "Previous Story Intelligence" bên dưới.
- Story này thêm **lệnh thứ hai cho lõi luật** (`END_TURN`) và lần đầu có **`BattleController.submit()` + bản chụp hủy** (ADR-002). Mọi story E2 sau sẽ gửi lệnh qua đúng `submit()` này, nên làm đúng hợp đồng kiến trúc: một điểm vào, chụp trước khi phân giải, kiểm bất biến sau mỗi lệnh, quay lại khi hỏng.
- Lần đầu có **HUD** (`src/ui/hud.gd`): chỉ có nhãn hiệp và hai nút. Nút mưu kế, Chơi lại, dòng báo pha thêm ở story của chúng.
- **Chưa có:** pha địch (E2), đánh (2.1), hoạt ảnh (2.11, đồng quân nhảy thẳng tới ô mới), khóa input khi đang phát hoạt ảnh (2.11), Chơi lại hiệp (3.2), giới hạn hiệp "Hiệp 2/4" (3.5).
- Tác giả không đọc code. Thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Luật (spec) **[GDD Action Economy, Hoàn tác; FR9–FR11; kiến trúc "Quản lý trạng thái", "Hủy nước đi"]**

- Mỗi tướng **đi một lần** mỗi lượt người chơi (tối đa `tam_di` bước, như Story 1.4). Đi xong thì không đi tiếp được nữa, kể cả còn bước chưa dùng. Còn lượt đánh (E2).
- Lệnh đi bị từ chối (ngoài tầm, ô bị chặn…) **không** tính là đã đi.
- **Hủy nước đi** quay về bản chụp ngay trước nước đi gần nhất: tướng về ô cũ, cờ "đã đi" tắt. **Chỉ hủy được một nước** **[Tác giả chốt 2026-10-18]**: hủy xong thì bấm Hủy nữa không có gì xảy ra; phải đi một nước mới thì mới hủy được (nước mới đó). Đúng câu GDD "muốn quay lại xa hơn thì dùng chơi lại hiệp". Kiến trúc đang ghi "ngăn xếp… vào sau ra trước": sửa ở Task 9.1.
- Lệnh đi bị từ chối không xóa bản chụp hủy: nước đi hợp lệ trước đó vẫn hủy được.
- "Chỉ khi tướng đó chưa đánh": từ Story 2.1, lệnh `Attack` (và `UseStratagem` ở E3) **xóa bản chụp hủy**, nên điều kiện này tự đúng. Story này chưa có đánh; ghi chú vào code chỗ xóa để Story 2.1 nối thêm.
- Không còn gì để hủy mà vẫn hủy: không có gì xảy ra (một sự kiện `REJECTED` `NOTHING_TO_UNDO`, không phải lỗi, không ghi log ERROR).
- **Kết thúc lượt**: hiệp tăng 1, mọi tướng đi lại được, **bản chụp hủy bị xóa** (không hủy được nước đi của lượt trước). Pha địch và cuối hiệp (E2–E3) chèn vào giữa.
- *Hiệp* = cả 4 pha; *lượt người chơi* = chỉ pha người chơi. Số trên HUD là **hiệp**. Không dùng lẫn.

### Đợt kịch bản 2

Quy ước như đợt 1 (Story 1.4): `phien_ban_dinh_dang: 1`, bàn 7×7, mỗi ô cách nhau một dấu cách, `sau.dia_hinh` chép y `truoc.dia_hinh` (toàn `.`), không ghi `mau`. Bàn ghi theo hàng 0 → 6; hàng không nêu là `. . . . . . .`. Mỗi lệnh một dòng trong `hanh_dong` như file mẫu `di_chuyen/di_thang_3_o.json`.

**Mọi bàn đều không có quân Nguyên.** Lý do: kịch bản đã duyệt bị khóa vĩnh viễn; từ E2, `ket_thuc_luot` chạy luôn pha địch, quân Nguyên trên bàn sẽ đi và đánh, làm hỏng bàn sau. Không có quân Nguyên thì pha địch không đổi gì, kịch bản vẫn đạt ở E2 (luật thắng chỉ kiểm sau sự kiện gục, bàn không có ai gục thì không thắng).

| # | File | `mo_ta` | Bàn trước | `hanh_dong` | Bàn sau |
|---|---|---|---|---|---|
| 1 | `di_chuyen/di_hai_lan.json` | `Nguyễn Khoái đã đi rồi thì không đi tiếp được nữa trong lượt này, dù còn thừa bước.` | hàng 6: `1 . . . . . .` | `di 1 → 2,6`; `di 1 → 3,6` **`tu_choi: da_di_roi`** | hàng 6: `. . 1 . . . .` |
| 2 | `huy/huy_nuoc_di.json` | `Hủy nước đi: Nguyễn Khoái về ô cũ và đi lại được (lần này đi lên 3 ô).` | hàng 6: `1 . . . . . .` | `di 1 → 3,6`; `huy`; `di 1 → 0,3` | hàng 3: `1 . . . . . .` |
| 3 | `huy/huy_chi_nuoc_gan_nhat.json` | `Hủy chỉ trả lại nước đi gần nhất: Phạm Ngũ Lão về chỗ cũ, Nguyễn Khoái vẫn đứng ở ô mới.` | hàng 6: `1 2 . . . . .` | `di 1 → 0,4`; `di 2 → 1,3`; `huy` | hàng 4: `1 . . . . . .`; hàng 6: `. 2 . . . . .` |
| 4 | `huy/huy_hai_lan.json` | `Chỉ hủy được một nước: lần hủy đầu trả nước đi của Phạm Ngũ Lão, lần hủy thứ hai không có gì xảy ra, Nguyễn Khoái vẫn đứng ở ô mới.` | hàng 6: `1 2 . . . . .` | `di 1 → 0,4`; `di 2 → 1,3`; `huy`; `huy` **`tu_choi: khong_con_nuoc_di`** | hàng 4: `1 . . . . . .`; hàng 6: `. 2 . . . . .` |
| 5 | `huy/huy_het_roi_bam_tiep.json` | `Đã hủy hết nước đi mà vẫn bấm hủy thì không có gì xảy ra thêm.` | hàng 6: `1 . . . . . .` | `di 1 → 3,6`; `huy`; `huy` **`tu_choi: khong_con_nuoc_di`** | giống trước |
| 6 | `hiep/ket_thuc_luot_di_lai_duoc.json` | `Kết thúc lượt: sang hiệp mới, Nguyễn Khoái đi lại được.` | hàng 6: `1 . . . . . .` | `di 1 → 0,3`; `ket_thuc_luot`; `di 1 → 0,0` | hàng 0: `1 . . . . . .` |
| 7 | `hiep/ket_thuc_luot_xoa_huy.json` | `Kết thúc lượt rồi thì không hủy được nước đi của lượt trước.` | hàng 6: `1 . . . . . .` | `di 1 → 0,3`; `ket_thuc_luot`; `huy` **`tu_choi: khong_con_nuoc_di`** | hàng 3: `1 . . . . . .` |

Mỗi kịch bản thử đúng điều `mo_ta` nói (đã kiểm khi tạo story, dev kiểm lại và ghi Debug Log):
- **#1:** `2,6` → `3,6` chỉ 1 bước, trong tầm. Bị từ chối là vì cờ "đã đi", không phải vì tầm.
- **#2:** nếu hủy không trả tướng về `0,6` thì từ `3,6` tới `0,3` mất 6 bước, bị từ chối `khong_toi_duoc` (kịch bản không ghi nên trượt). Nếu hủy không tắt cờ thì bị `da_di_roi`. Cả hai lỗi đều bị bắt.
- **#3:** đường Khoái `0,6` → `0,5` → `0,4`; đường Lão `1,6` → `1,5` → `1,4` → `1,3`, không đụng Khoái ở `0,4`. Sau hủy, Lão ở `1,6`, Khoái ở `0,4`.
- **#4:** khác #3 ở lần hủy thứ hai. Nếu code lùi được hai nước (ngăn xếp) thì lần hủy thứ hai chạy được, Khoái về `0,6`, kịch bản trượt. Bàn sau giống bàn sau của #3.
- **#5:** khác #4 ở chỗ chỉ có một nước đi; thử ca "hủy hết rồi bấm tiếp" của epic.
- **#6:** `0,3` → `0,0` là 3 bước. Không kết thúc lượt thì bị `da_di_roi`.
- **#7:** nếu kết thúc lượt không xóa bản chụp hủy thì hủy chạy được, Khoái về `0,6`, kịch bản trượt.

**Lý do chưa đạt** (trước khi có code luật, dòng ⏳ của `tools/test.sh`):

| File | Lý do |
|---|---|
| `di_chuyen/di_hai_lan.json` | `bước 2: kịch bản ghi "tu_choi": "da_di_roi" nhưng luật cho chạy` |
| `huy/huy_nuoc_di.json` | `bước 2: lệnh "huy" chưa có luật (Story 1.5)` |
| `huy/huy_chi_nuoc_gan_nhat.json` | `bước 3: lệnh "huy" chưa có luật (Story 1.5)` |
| `huy/huy_hai_lan.json` | `bước 3: lệnh "huy" chưa có luật (Story 1.5)` |
| `huy/huy_het_roi_bam_tiep.json` | `bước 2: lệnh "huy" chưa có luật (Story 1.5)` |
| `hiep/ket_thuc_luot_di_lai_duoc.json` | `bước 2: lệnh "ket_thuc_luot" chưa có luật (Story 1.5)` |
| `hiep/ket_thuc_luot_xoa_huy.json` | `bước 2: lệnh "ket_thuc_luot" chưa có luật (Story 1.5)` |

Ví dụ một lệnh có `tu_choi` trong file: `{"lenh": "di", "tuong": "1", "o": "3,6", "tu_choi": "da_di_roi"}`, `{"lenh": "huy", "tu_choi": "khong_con_nuoc_di"}`.

Không viết thêm kịch bản ngoài 7 cái này. Số hiệp không ghi được trong bàn sau (định dạng chỉ có bàn cờ và máu): kiểm bằng GUT (Task 5.2, 6.1) và bằng mắt trên HUD. Không đổi định dạng kịch bản.

### Bảng thứ tự kiểm của lệnh đi (sau story này)

| Kiểm | `Reject` | Mã `tu_choi` | Lý do (cho dev và log, không qua `tr()`) |
|---|---|---|---|
| Không có quân id đó | `NO_UNIT` | `khong_co_quan` | `không có quân %d` |
| Quân không phải tướng | `NOT_GENERAL` | `khong_phai_tuong` | `quân %d không phải tướng` |
| **Tướng đã đi trong lượt này** | `ALREADY_MOVED` | `da_di_roi` | `quân %d đã đi rồi trong lượt này` |
| Ô đích là ô đang đứng | `ALREADY_THERE` | `da_dung_o_do` | `quân %d đã đứng ở ô c,h` |
| Không đi tới được | `UNREACHABLE` | `khong_toi_duoc` | `quân %d không đi tới được ô c,h` |

Hủy khi không còn bản chụp hủy: `NOTHING_TO_UNDO`, mã `khong_con_nuoc_di`, lý do `không còn nước đi nào để hủy`. Sự kiện này do `BattleController.undo()` tạo (`BattleEvent.rejected(...)`), không qua `Rules.resolve`, vì hủy là việc của controller (ADR-002), không phải luật.

### BattleController

```gdscript
signal events_resolved(events: Array[BattleEvent], snapshot: BattleState)
## Lệnh làm hỏng bất biến: đã quay về bản chụp trước lệnh. Thông báo cho người chơi: E2 (notice.gd).
signal rolled_back(problems: Array[String])

## Bản chụp ngay trước nước đi gần nhất; null là không có gì để hủy. Chỉ giữ một (tác giả chốt 2026-10-18).
var _undo_snapshot: BattleState = null

func submit(command: Command) -> Array[BattleEvent]:
	var before: BattleState = _state.clone()
	var events: Array[BattleEvent] = _resolve(_state, command)
	if _is_rejected(events):
		Log.debug("battle", "lệnh bị từ chối: %s" % events[0].reason)
		return events            # state không đổi, bản chụp hủy giữ nguyên, không phát signal
	var problems: Array[String] = _state.validate()
	if not problems.is_empty():
		for p: String in problems:
			Log.error("battle", "vi phạm bất biến: %s" % p)
		_state = before
		rolled_back.emit(problems)
		return []
	match command.kind:
		Command.Kind.MOVE:
			_undo_snapshot = before   # thay bản cũ: chỉ hủy được nước gần nhất
		Command.Kind.END_TURN:
			_undo_snapshot = null     # Story 2.1: ATTACK cũng xóa; E3: mưu kế cũng xóa
	events_resolved.emit(events, _state.clone())
	return events
```

- `undo()`: `_undo_snapshot == null` → trả `[BattleEvent.rejected(Reject.NOTHING_TO_UNDO, "không còn nước đi nào để hủy")]`, không phát signal. Có → `_state = _undo_snapshot`, `_undo_snapshot = null`, phát `events_resolved([], _state.clone())`, trả `[]`. (Bản chụp là bản riêng, không ai khác giữ, nên gán thẳng được.)
- `can_undo()`: `_undo_snapshot != null`.
- `start()`: dựng state như cũ **và** `_undo_snapshot = null`.
- "Chơi lại hiệp" (Story 3.2) sẽ có bản chụp đầu lượt riêng, không dùng chung biến này.
- Ghi `Log.debug("battle", ...)` cho lệnh nhận vào và lệnh hủy (chỉ hiện khi bật dev). Không ghi log trong `src/core/`.
- `events_resolved` luôn kèm **bản sao** (`_state.clone()`), không bao giờ là state sống (kiến trúc #2).
- `rolled_back`: story này chưa có chỗ hiện thông báo cho người chơi ("Có lỗi, đã quay lại nước trước"). Ghi vào `deferred-work.md`: làm cùng `src/ui/notice.gd` ở E2. Lỗi này chỉ xảy ra khi có bug luật.

### Chọn, đi, hủy, kết thúc lượt (`BattleView`) **[Tác giả chốt 2026-10-18]**

Bảng của Story 1.4 giữ nguyên, chỉ đổi dòng "Bấm ô sáng" và thêm các dòng mới:

| Thao tác | Đang không chọn ai | Đang chọn tướng X |
|---|---|---|
| Bấm ô sáng | (không áp dụng) | X đi tới ô đó. **Vẫn chọn X** ở ô mới, không còn ô sáng |
| Chọn tướng đã đi (phím hoặc bấm) | Chọn, có vòng vàng, **không có ô sáng** | Đổi sang tướng đó, không có ô sáng |
| Hủy (nút / `Z`), còn nước để hủy | Hủy nước gần nhất, vẫn không chọn ai | Hủy nước gần nhất, **vẫn chọn X**, ô sáng của X tính lại (X vừa được hủy thì ô sáng hiện lại) |
| Hủy khi không còn nước để hủy | Không gì | Không gì |
| Kết thúc lượt (nút / `Space`) | Sang hiệp mới | Sang hiệp mới, **bỏ chọn** |
| Bấm ô khác (trống, địa hình chặn, ngoài bàn…) | Không gì | Bỏ chọn (như 1.4) |

- Sau **mỗi** lần `events_resolved`: tính lại `_cells` của tướng đang chọn, vẽ lại vòng chọn ở ô hiện tại, vẽ lại đường đi nếu chuột đang nằm trên ô sáng (`_input.hovered_cell()`, như `_select`).
- Không có controller (màn hình lỗi, menu): mọi thao tác không làm gì, HUD ẩn.
- Bấm vào tướng mình **luôn là chọn** (GDD, chốt 2026-10-17), kể cả tướng đã đi.

### HUD (`src/ui/hud.gd`)

- `Control` dựng bằng code (không `.tscn`, scene nhỏ và phẳng). Đặt bên phải bàn cờ: bàn cờ chiếm x 332–948, y 52–668 (`BoardView.setup`, 7×88 ô); HUD đặt ở x ≈ 972, y = 52, rộng ≈ 260. Cao vừa đủ, không đè nhãn phiên bản ở góc dưới phải. Story 1.7 (bàn nghiêng) có thể phải dời lại; giữ vị trí ở **một** hằng số.
- Từ trên xuống: nhãn "Hiệp N" (font tiêu đề `TitleLabel` như `main.gd`), nút "Hủy (Z)", nút "Kết thúc lượt (Space)". Dùng `VBoxContainer` hoặc đặt tay; nút đủ to để bấm dễ (cao ≥ 40).
- **`focus_mode = Control.FOCUS_NONE` cho mọi nút.** Nếu không: bấm nút bằng chuột thì nút giữ focus; gõ `Space` sau đó vừa kích hoạt action `end_turn` vừa kích hoạt `ui_accept` của nút đang focus (Space nằm trong `ui_accept` mặc định) → kết thúc **hai** lượt, hoặc bấm nhầm Hủy. Có test (Task 8.1) cho trường hợp này nếu dựng được; không thì ghi Debug Log đã thử tay.
- Nút Hủy: `disabled = not can_undo`. Nút bị `disabled` không phát `pressed`.
- Chữ đi qua `tr()`. Màu, cỡ chữ là hằng số UI trong file, không phải số cân bằng.
- Nút là `Control`, nên bấm nút không lọt xuống `BattleInput._unhandled_input` (không bị coi là bấm ra ngoài bàn để bỏ chọn). Phần nền HUD để `MOUSE_FILTER_IGNORE`.

### Đồng quân "đã đi" (`UnitToken`)

- Gợi ý: `DAI_VIET_MOVED_COLOR = Color(0.55, 0.40, 0.38)` (đỏ xỉn), viền giữ nguyên. Chữ màu kem vẫn đọc được. Dev xem ảnh chụp GoPeak, chỉnh nếu khó phân biệt.
- **Không** dùng `modulate` alpha: E2 có bóng mờ cho xem trước kết quả đòn (ADR-005), dễ lẫn.
- Story 2.1 thêm trạng thái "đã đánh". Viết sao cho thêm được một trạng thái nữa (ví dụ một hàm `_fill_color()` chọn màu theo cờ).

### File sẽ sửa (đọc trước khi sửa)

| File | Hôm nay | Story này đổi | Phải giữ |
|---|---|---|---|
| `src/core/unit.gd` | id, phe, loại, ô, máu; gán trong `_init` | + `has_moved` (tham số `_init` mặc định `false`) | Thứ tự tham số cũ; mọi chỗ gọi `Unit.new` cũ vẫn chạy |
| `src/core/battle_state.gd` | `from_level`, `clone`, `validate`, tra cứu | + `round_number`; `clone` chép cờ và hiệp; `validate` kiểm hiệp | Id quân theo `from_level`; câu lỗi `validate` cũ (test so nguyên câu) |
| `src/core/command.gd` | `Kind.MOVE`, `move()` | + `END_TURN`, `end_turn()` | Gán trường chỉ trong `_init` (regex `.cell =` của `check_boundaries.sh`) |
| `src/core/battle_event.gd` | `MOVED`, `REJECTED`; `Reject` 5 giá trị | + `ROUND_STARTED`, `round_number`; `Reject` + 2 (cuối enum) | Thứ tự `Reject` cũ; hàm tạo `moved`, `rejected` |
| `src/core/rules_move.gd` | Kiểm 4 bước, đi từng ô | + kiểm `ALREADY_MOVED`, đặt cờ, `reachable` rỗng khi đã đi | Đi từng ô qua `Effects.move`; thứ tự sắp ô sáng |
| `src/core/rules.gd` | `MOVE` | + `END_TURN` | Điểm vào duy nhất |
| `src/battle/battle_controller.gd` | `start`, `snapshot`, `reachable`, `path_to` | + `submit`, `undo`, `can_undo`, 2 signal, bản chụp hủy (một) | `start` kiểm `validate()` và ghi log; `snapshot()` trả bản sao |
| `src/battle/battle_input.gd` | Phím 1-2-3, bấm, rê, chuột ra khỏi cửa sổ | + action `undo_move`, `end_turn`, 2 signal | Lấy ô từ vị trí trong sự kiện (`make_input_local`); `_unhandled_input` |
| `src/battle/battle_view.gd` | Chọn/bỏ chọn, ô sáng, đường đi | + đi, hủy, kết thúc lượt, làm mới sau mỗi lệnh, HUD | Mọi hành vi chọn của 1.4 (test sẵn có phải xanh) |
| `src/battle/unit_token.gd` | Đồng tròn, chữ, máu | + màu "đã đi" | `setup`/`update`, `name_text`, `hp_text` |
| `src/app/main.gd` | Nạp, dựng bàn, lỗi, menu, F1 | + tạo `Hud`, nối `events_resolved` → `_show_board` | Mọi test `test_main.gd`; F1 chỉ khi đang có trận |
| `src/data/scenario_loader.gd` | `huy` không nhận khóa; 4 mã `tu_choi` | `huy` nhận `tu_choi`; + 2 mã | Câu lỗi cũ (test so nguyên câu, trừ câu có `REJECT_LIST`) |
| `tests/scenario_runner.gd` | Chạy `di` qua `Rules.resolve` trên state | Chạy cả 3 lệnh qua `BattleController` | Câu so sánh; `_check_reject`; `PENDING_RULES` của `danh` |
| `tests/test_scenario_loader.gd` | Test lệnh chưa có luật dùng `huy` | Đổi sang `danh`; sửa test `huy` + `tu_choi` | Các test khác |
| `i18n/text.csv` | Khóa cũ | + 5 khóa | Khóa cũ |

**Không** đổi: định dạng kịch bản (ngoài `huy` nhận `tu_choi`), `tools/test.sh`, `tools/xem_kich_ban.sh`, file trận, `chi_so.json`, `Pathfinding`, `Effects`, `BoardView` (trừ khi cần một hàm đọc cho test).

### Luật kiến trúc phải theo

- `src/core/` chỉ `extends RefCounted`; không Node, `Input`, `FileAccess`, `Time`, ngẫu nhiên, `print`, `Log`. `check_boundaries.sh` quét.
- Chỉ `effects.gd` gán `.cell` / `.hp`. Cờ `has_moved` không bị regex bắt; chỉ `RulesMove` và `RulesEnemyPhase` được đổi nó (ghi rõ trong chú thích `unit.gd`). Trường mới của `Command`/`BattleEvent` gán trong `_init`.
- `Rules.resolve` là điểm vào duy nhất của luật. Hủy **không** phải lệnh luật: nó là khôi phục bản chụp trong `BattleController` (ADR-002).
- `src/battle/` và `src/ui/` không sửa `BattleState`. Mọi thay đổi qua `controller.submit()` / `undo()`. Phần hiển thị chỉ đọc bản chụp.
- Đi xuống gọi hàm, đi lên phát signal: `BattleInput`/`Hud` phát → `BattleView` nhận → gọi `controller`; `controller` phát `events_resolved` → `main` và `BattleView` nhận. Không Event Bus. `AppState` vẫn là autoload duy nhất.
- Phím tắt khai báo trong InputMap bằng code (như `select_general_*` và `DevTools`), không bắt `KEY_Z` trực tiếp.
- Gõ kiểu tĩnh mọi nơi. Lambda nối signal cũng gõ kiểu tham số.
- Tất định: `end_player_turn` duyệt `state.units` theo thứ tự mảng, không duyệt khóa Dictionary.
- Thuật ngữ: biến và chữ hiển thị dùng *hiệp* cho số trên HUD (`round_number`, "Hiệp N"); hàm đổi lượt là `end_player_turn` (kết thúc *lượt người chơi*).

### Ghi chú kỹ thuật Godot 4.7.2

- `Button.focus_mode = Control.FOCUS_NONE`; `Button.disabled`; signal `pressed`. `Control.mouse_filter = Control.MOUSE_FILTER_IGNORE`.
- `ui_accept` mặc định gồm Enter, Enter bàn phím số, **Space**: lý do bắt buộc `FOCUS_NONE` ở trên.
- Action `end_turn`: `InputEventKey.physical_keycode = KEY_SPACE`; `undo_move`: `KEY_Z`. Kiểm bằng `event.is_action_pressed(action, false, true)` (không nhận `echo`).
- Signal trên `RefCounted` dùng được (`BattleController` không phải Node). Nối bằng `controller.events_resolved.connect(_on_events_resolved)`. Khi trận mới thay controller cũ, controller cũ bị giải phóng cùng các kết nối; không cần ngắt tay, nhưng đừng nối hai lần vào cùng một controller.
- Tra Context7 (`/godotengine/godot-docs/__branch__4.7`) nếu cần: `BaseButton.focus_mode`, `Control.mouse_filter`, `InputEvent.is_action_pressed`, `VBoxContainer`.
- Trên web: `Space` có thể cuộn trang nếu iframe không giữ focus bàn phím; game đã nhận phím 1-2-3 nên thường ổn. Ghi vào hướng dẫn test: bấm vào game một lần trước khi gõ phím.

### Cấu trúc file sau story

```
game/
├── src/
│   ├── core/
│   │   ├── unit.gd                # + has_moved
│   │   ├── battle_state.gd        # + round_number, clone/validate
│   │   ├── command.gd             # + END_TURN
│   │   ├── battle_event.gd        # + ROUND_STARTED, Reject x2
│   │   ├── rules.gd               # + END_TURN
│   │   ├── rules_move.gd          # + cờ đã đi
│   │   └── rules_enemy_phase.gd   # MỚI: end_player_turn (phần cuối hiệp)
│   ├── battle/
│   │   ├── battle_controller.gd   # + submit, undo, can_undo, signal
│   │   ├── battle_input.gd        # + Z, Space
│   │   ├── battle_view.gd         # + đi, hủy, kết thúc lượt
│   │   └── unit_token.gd          # + màu đã đi
│   ├── ui/hud.gd                  # MỚI
│   ├── data/scenario_loader.gd    # huy nhận tu_choi, + 2 mã
│   └── app/main.gd                # + Hud, events_resolved
├── i18n/text.csv                  # + 5 khóa (và text.vi.translation)
└── tests/
    ├── kich_ban/di_chuyen/di_hai_lan.json      # MỚI
    ├── kich_ban/huy/*.json                     # MỚI (4)
    ├── kich_ban/hiep/*.json                    # MỚI (2)
    ├── scenario_runner.gd                      # chạy qua BattleController
    ├── test_rules_move.gd                      # + cờ đã đi
    ├── test_rules_enemy_phase.gd               # MỚI
    ├── test_battle_controller.gd               # MỚI
    ├── test_battle_state.gd                    # + clone/validate
    ├── test_battle_view.gd                     # + đi, hủy, kết thúc lượt
    └── test_scenario_loader.gd                 # sửa test huy, danh
```

Nhớ commit file `.uid` của mọi script mới.

### Testing

- `tools/test.sh` là lệnh duy nhất. Lõi luật test trực tiếp (`BattleState` + `Rules.resolve`); controller test không cần màn hình; giao diện test bằng `main.tscn` thật như `test_battle_view.gd`.
- Mỗi test luật có ca **trượt thật** (Task 5.4), không chỉ ca đạt.
- Phần nhìn (màu "đã đi", vị trí HUD) tác giả test tay; dev tự xem bằng ảnh chụp GoPeak (Task 9.2).
- Test giao diện gửi **phím thật** (`InputEventKey` có `physical_keycode`) cho `Z` và `Space`, ngoài các ca gửi action: review 1.4 bắt lỗi gán sai phím ↔ action bằng đúng cách này.

**Mẫu hướng dẫn tác giả tự test** (ghi vào Completion Notes, theo kết quả thật):
1. Gõ `tools/test.sh`. Đúng là: `✅ … test đạt`, có dòng `Kịch bản luật: 15 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
2. Gõ `tools/chay.sh`. Bên phải bàn cờ có "Hiệp 1", nút "Hủy (Z)" đang mờ, nút "Kết thúc lượt (Space)".
3. Bấm "Khoái", bấm ô `0,4` (hai ô phía trên): Khoái sang đó, đồng đổi sang màu xỉn, không còn ô sáng; nút Hủy sáng lên.
4. Bấm "Lão", bấm ô `2,4` (hai ô phía trên Lão): Lão đi, cũng xỉn màu.
5. Bấm Hủy: chỉ Lão về chỗ cũ, đỏ đậm lại; nút Hủy mờ. Gõ `Z`: không có gì, Khoái vẫn ở `0,4`.
6. Đi Khoái một nước, gõ `Space`: "Hiệp 2", Khoái đỏ đậm lại, chọn lại thì có ô sáng; nút Hủy mờ.
7. Chỉ dùng chuột, làm lại bước 3–6 bằng hai nút bên phải: kết quả giống hệt.

(Nếu đang bật bộ gõ VNI/Telex thì tắt đi trước khi gõ phím. Trên bản web, bấm vào game một lần trước khi gõ.)

### Previous Story Intelligence (Story 1.4 và code review)

- **Quy trình duyệt:** kịch bản chưa duyệt mà chưa đạt thì `test.sh` vẫn xanh (dòng ⏳ kèm lý do). Kịch bản đã duyệt mà trượt thì đỏ. Commit đợt kịch bản trước khi duyệt; đổi `da_duyet` rồi thì không commit tới khi xanh.
- **`tu_choi` bắt buộc** (tác giả chốt 2026-10-18): lệnh bị từ chối mà kịch bản không ghi, hoặc ghi mà không bị từ chối, là trượt. Mã mới phải thêm đủ **ba** chỗ: `BattleEvent.Reject`, `ScenarioRunner.REJECT_EVENTS`, `ScenarioLoader.REJECT_CODES` (+ chữ trong `text.csv`). Test `test_scenario_loader.gd:540-541` kiểm khớp và đủ.
- **Bộ chạy** dựng state, chạy từng bước, `validate()` sau mỗi bước, so theo ô. Story này chuyển sang chạy qua `BattleController` để `huy` dùng đúng cơ chế hủy thật, không viết một bản riêng cho test.
- **GoPeak:** `inject_key` chỉ gửi `keycode`, không gửi phím vật lý, nên không kích hoạt action. Dùng `inject_action`. `BattleInput` lấy ô từ vị trí trong sự kiện (`make_input_local`), nên `inject_mouse_click` chạy đúng.
- **GUT:** hàm phụ trong file test không được trùng tên hàm có sẵn của Node (`_input` đã gây lỗi bỏ qua cả file ở 1.4). `test.sh` báo "có file test không được chạy" nếu xảy ra.
- **Mục hoãn của 1.4** (`deferred-work.md`): (1) `_cells` tính một lần: story này xử lý (Task 7.3), ghi "→ xong ở Story 1.5" vào `deferred-work.md`; (2) `BattleView`/`BattleInput` là anh em dưới `main`: để nguyên, `Hud` cũng là con của `main` theo cùng mẫu; (3) `show_state(null)` và `_selected`: vẫn đúng vì `main` gọi `stop()` trước.
- Đồng quân dùng lại theo id; chữ cũ phải `remove_child` rồi `queue_free` (Story 1.2). HUD tạo một lần, không dựng lại mỗi lệnh.
- Phím số và bộ gõ VNI: ghi vào hướng dẫn test.

### Git Intelligence

- Commit gần nhất: `02a300c` (sửa theo review 1.4), `5f178e7` (kịch bản đứng yên ghi `tu_choi`, duyệt lại), `3fc2c67` (thêm Story 1.7 bàn nghiêng), `b5e12f6` (Story 1.4), `679fb9c` (đợt kịch bản 1).
- Mẫu: một commit cho đợt kịch bản chờ duyệt (Task 1.4), một commit chính khi xanh (Task 9.3), rồi "Sửa theo code review Story 1.5". Lời commit tiếng Việt, gạch đầu dòng, kèm `Co-Authored-By`.
- Story 1.7 (bàn nghiêng) sẽ viết lại cách vẽ trong `BoardView` và `cell_at`. Story này **không** đụng `BoardView` để hai story không giẫm nhau; HUD tách riêng.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- **M3 không ngoại lệ.** Không viết code luật trước khi tác giả duyệt. Không bao giờ sửa hay xóa kịch bản `da_duyet: true` để test đạt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả. Các mục **[Tác giả chốt 2026-10-18]** ở trên là quyết định đã có, làm đúng như vậy.
- Sau mỗi lần phân giải trong test: `state.validate()` rỗng.
- Không để game kẹt: vi phạm bất biến thì ghi log ERROR, khôi phục bản chụp (Task 3.1). Không dùng `assert()` cho việc này.
- Chữ hiển thị qua `tr()`, khóa dạng `<man>.<muc>` (`hud.undo`). Lý do từ chối là chữ cho dev, không qua `tr()`.
- Commit chỉ khi `tools/test.sh` xanh. Lệnh cho tác giả nằm trong `tools/`, chạy từ gốc repo.
- MCP chỉ để nhìn và thử (`--dev`). Luật chỉ sửa trong code, có test.

### Quyết định của tác giả (2026-10-18)

1. **Chỉ hủy được một nước.** Hủy xong thì Hủy nữa không có gì xảy ra; đi nước mới thì hủy được nước mới đó. (Tác giả nói "sai" với phương án lùi nhiều nước.)
2. **Đi xong giữ chọn tướng** (vòng vàng theo tướng sang ô mới, không còn ô sáng).
3. **Hủy xong giữ nguyên tướng đang chọn**, tính lại ô sáng.
4. **Kết thúc lượt thì bỏ chọn.**
5. **Dấu "đã đi"**: đồng quân chuyển sang đỏ xỉn.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.5]
- [Source: _bmad-output/planning-artifacts/epics.md#Yêu cầu UX] (tướng đã đi có trạng thái nhìn thấy được)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Action Economy] (lượt người chơi, Hoàn tác)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Controls and Input] (nút Hủy/`Z`, nút Kết thúc/`Space`)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Quản lý trạng thái] (BattleController, hoàn tác bằng bản chụp)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Xử lý lỗi] (vi phạm bất biến → quay lại bản chụp)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Hệ thống sự kiện] (`events_resolved`)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Bảng thứ tự phân giải] (Hủy nước đi)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Mẫu trạng thái] (`end_player_turn`, Phase để E2)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Cây thư mục] (`rules_enemy_phase.gd`, `src/ui/hud.gd`)
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/1-4-chon-tuong-va-xem-cac-o-di-duoc.md]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1: khung (2 mã từ chối mới, `huy` nhận `tu_choi`, chữ công cụ duyệt) + 7 kịch bản viết bằng script. `tools/xem_kich_ban.sh huy`/`hiep`: bàn trước/sau khớp `mo_ta`, dòng `→ bị từ chối: …` hiện đúng. `tools/test.sh`: 273/273 đạt, `Kịch bản luật: 8 đã duyệt · 7 chưa duyệt (7 chưa đạt)`, lý do từng file khớp bảng "Lý do chưa đạt".

- Task 1.6: tác giả trả lời "đúng hết" (2026-10-18). Đổi `da_duyet: true` cho 7 file (mỗi file 1 dòng). `tools/test.sh` trượt đúng AC 2: `kịch bản đã duyệt di_chuyen/di_hai_lan.json: bước 2: kịch bản ghi "tu_choi": "da_di_roi" nhưng luật cho chạy`. Không commit lúc đỏ.
- Task 2–4: lõi luật + controller + bộ chạy xong thì 15/15 kịch bản đạt ngay. Còn đúng một test cũ trượt (`test_runner_stops_at_command_without_rule` dùng `huy`), đã đổi sang `danh` (Story 2.1).
- Task 5.4 (làm hỏng tạm, đã trả lại): bỏ xóa bản chụp hủy khi kết thúc lượt → trượt kịch bản `hiep/ket_thuc_luot_xoa_huy.json`; bỏ `unit.has_moved = true` → trượt 4 test luật/bộ chạy + kịch bản `di_chuyen/di_hai_lan.json`; bỏ chép `has_moved` trong `clone()` → trượt `test_clone_copies_round_and_moved_flag`. Thêm: bỏ nối `events_resolved` → `_show_board` trong `main.gd` → trượt 3 test giao diện (đồng quân, lớp F1).
- Task 6: lần đầu `test_only_one_move_can_be_undone` trượt vì chính test chọn ô `2,3` (4 bước, quá tầm); sửa test sang `2,4`.
- Task 8: `test_coord_overlay_follows_moved_unit` lần đầu không thấy id vì chữ F1 nằm trong `PanelContainer`; sửa cách tìm trong test.
- Task 9.2 (GoPeak, `tools/chay.sh --dev`): bảng bên phải "Hiệp 1", nút Hủy mờ, không đè bàn cờ hay nhãn phiên bản. Bấm Khoái rồi ô `0,4` (pixel 376, 448): Khoái sang ô mới, đỏ xỉn khác rõ đỏ đậm của Lão, chữ và số máu đọc được, nút Hủy sáng. `inject_action undo_move`: Khoái về `0,6`, đỏ đậm lại, nút Hủy mờ. `select_general_2` + bấm `2,4`: Lão đi, vẫn có vòng vàng, không còn ô sáng. Bấm nút "Kết thúc lượt" (pixel 1100, 177): "Hiệp 2", bỏ chọn, Lão đỏ đậm lại, nút Hủy mờ. Log không có ERROR. Lưu ý khi thử bằng GoPeak: ảnh chụp ngay sau cú bấm có thể chưa kịp vẽ lại; lần đầu tưởng bấm không ăn nên bấm thêm, cú thứ ba trúng chính Khoái ở ô mới nên bỏ chọn (đúng luật).
- `tools/test.sh` cuối cùng: 303/303 đạt, ranh giới đạt, `Kịch bản luật: 15 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Sửa theo code review: test nút bấm chạy qua viewport thật (`push_input`) trong `SubViewport` riêng, vì bảng kết quả của GUT nằm đè lên viewport gốc và nuốt chuột. Godot chạy không màn hình không đưa Space (`ui_accept`) tới nút đang focus (đã thử với `FOCUS_ALL`: nút giữ focus nhưng Space vẫn kết thúc lượt), nên `test_click_undo_button_then_space_ends_turn` kiểm thẳng "bấm chuột xong không nút nào giữ focus". Làm hỏng tạm (đã trả lại): `FOCUS_ALL` → trượt test đó và `test_hud_buttons_never_take_focus`; khi quay lại do hỏng bất biến mà xóa bản chụp hủy, hoặc chỉ trả lại hiệp → trượt `test_invariant_violation_rolls_back`.
- Sửa theo code review: `tools/test.sh` 314/314 đạt, `Kịch bản luật: 9 đã duyệt · 6 chưa duyệt (0 chưa đạt)`. Bước khóa `da_duyet` trượt cho tới khi commit (6 kịch bản đã duyệt bị sửa để thêm `hiep`, `da_di`), như lần review Story 1.4.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Đã làm đủ Task 1–9. Thêm 30 test (273 → 303) và 7 kịch bản (8 → 15 đã duyệt).
- **Lệch so với story (ghi để review):**
  - `BattleInput` gom mọi phím vào một bảng `ACTION_KEYS` (thay `GENERAL_KEYS`); `GENERAL_ACTIONS` giữ nguyên.
  - `Hud` có thêm hàm đọc `round_text()`, `undo_button()`, `end_turn_button()` cho test; `UnitToken.is_moved()`.
  - Không viết test "bấm nút rồi gõ Space"; thay bằng test mọi nút `focus_mode = FOCUS_NONE` (`test_hud_buttons_never_take_focus`).
  - Ngoài `game-architecture.md`, sửa luôn `project-context.md` (câu Hủy nước đi) theo Task 9.1.

**Hướng dẫn tác giả tự test** (kết quả thật, đã chụp màn hình bằng GoPeak):
1. Gõ `tools/test.sh`. Đúng là: `✅ 303/303 test đạt`, có dòng `Kịch bản luật: 15 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
2. Gõ `tools/chay.sh`. Bên phải bàn cờ có "Hiệp 1", nút "Hủy (Z)" đang mờ, nút "Kết thúc lượt (Space)".
3. Bấm "Khoái", bấm ô `0,4` (hai ô phía trên): Khoái sang đó, đồng đổi sang đỏ xỉn, vẫn có vòng vàng nhưng không còn ô sáng; nút Hủy sáng lên.
4. Bấm "Lão", bấm ô `2,4` (hai ô phía trên Lão): Lão đi, cũng đỏ xỉn.
5. Bấm Hủy: chỉ Lão về chỗ cũ, đỏ đậm lại; nút Hủy mờ. Gõ `Z`: không có gì, Khoái vẫn ở `0,4`.
6. Gõ `Space`: "Hiệp 2", Khoái đỏ đậm lại, bỏ chọn; chọn lại Khoái thì có ô sáng; nút Hủy mờ.
7. Chỉ dùng chuột, làm lại bước 3–6 bằng hai nút bên phải: kết quả giống hệt.

(Nếu đang bật bộ gõ VNI/Telex thì tắt đi trước khi gõ phím. Trên bản web, bấm vào game một lần trước khi gõ.)

### File List

- `game/src/core/unit.gd`
- `game/src/core/battle_state.gd`
- `game/src/core/command.gd`
- `game/src/core/battle_event.gd`
- `game/src/core/rules.gd`
- `game/src/core/rules_move.gd`
- `game/src/core/rules_enemy_phase.gd` (mới)
- `game/src/battle/battle_controller.gd`
- `game/src/battle/battle_input.gd`
- `game/src/battle/battle_view.gd`
- `game/src/battle/unit_token.gd`
- `game/src/ui/hud.gd` (mới)
- `game/src/app/main.gd`
- `game/src/data/scenario_loader.gd`
- `game/src/data/scenario_data.gd` (code review)
- `game/tests/scenario_viewer.gd` (code review)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/scenario_runner.gd`
- `game/tests/test_scenario_loader.gd`
- `game/tests/test_rules_move.gd`
- `game/tests/test_rules_enemy_phase.gd` (mới)
- `game/tests/test_battle_controller.gd` (mới)
- `game/tests/test_battle_state.gd`
- `game/tests/test_battle_view.gd`
- `game/tests/kich_ban/di_chuyen/di_hai_lan.json` (mới)
- `game/tests/kich_ban/huy/*.json` (4 mới)
- `game/tests/kich_ban/hiep/*.json` (2 mới)
- file `.uid` của mọi script mới
- `_bmad-output/planning-artifacts/game-architecture.md`
- `_bmad-output/project-context.md`
- `_bmad-output/planning-artifacts/epics.md` (code review)
- `_bmad-output/implementation-artifacts/deferred-work.md`
- `_bmad-output/implementation-artifacts/1-5-di-huy-nuoc-di-ket-thuc-luot.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-18: Tạo story.
- 2026-10-18: Tác giả chốt 5 câu hỏi: chỉ hủy được một nước (sửa AC 5–6, kịch bản `huy_hai_lan`, controller giữ một bản chụp, thêm việc sửa kiến trúc ở Task 9.1); giữ chọn khi đi và khi hủy; bỏ chọn khi kết thúc lượt; đỏ xỉn cho "đã đi".
- 2026-10-18: Làm story: mỗi tướng đi một lần mỗi lượt, hủy một nước, kết thúc lượt (sang hiệp mới); `BattleController.submit/undo` có bản chụp hủy và quay lại khi hỏng bất biến; bảng nút HUD; đồng quân đỏ xỉn khi đã đi. 7 kịch bản mới tác giả đã duyệt, đều đạt. `tools/test.sh`: 303/303.
- 2026-10-18: Code review: thêm `hiep`, `da_di` vào phần "sau" của kịch bản (tác giả chốt), 6 kịch bản `huy/`, `hiep/` chờ duyệt lại; bộ nạp chặn mã `tu_choi` không hợp lệnh; log lệnh nhận vào; test quay lại, menu, bấm nút rồi Space; sửa `epics.md`.
- 2026-10-18: Tác giả duyệt lại 6 kịch bản `huy/`, `hiep/` có `hiep`, `da_di`. Story xong.
