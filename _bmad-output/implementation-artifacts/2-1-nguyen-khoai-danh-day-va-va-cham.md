---
baseline_commit: 428d7432fa963a2a4be70e5de26904141f7d3a76
---

# Story 2.1: Nguyễn Khoái đánh, đẩy và va chạm

Status: done

## Story

Là người chơi,
tôi muốn Nguyễn Khoái đánh và đẩy địch vào mép bàn, vào vật cản, vào nhau,
để dùng vị trí làm vũ khí.

_Story luật đầu tiên của E2. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 10 kịch bản mới ở Dev Notes "Đợt kịch bản 3" (`da_duyet: false`) và phần khung ở Task 1.1 (mã từ chối mới, khóa `sau.da_danh`, chữ của công cụ duyệt). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 15 đã duyệt · 10 chưa duyệt (10 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh`. Chưa duyệt xong thì không viết dòng code luật nào (`rules_attack.gd`, `forced_move.gd`, `Effects.damage`).
2. **Khi** tác giả duyệt (đổi `da_duyet` thành `true`, hoặc nhắn AI "đúng"), **thì** `tools/test.sh` **trượt**, vì kịch bản đã duyệt chưa đạt. Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 25 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt (chỉ `effects.gd` đổi `.hp`, `.cell`);
   - sau mỗi lệnh, `BattleState.validate()` rỗng (bộ chạy kiểm).
4. **Đánh và đẩy (FR12).** **Cho** Nguyễn Khoái đứng kề một Bộ binh 3 máu. **Khi** bấm vào Bộ binh, **thì** Bộ binh còn 1 máu và bị đẩy 1 ô theo hướng đánh (ra xa Khoái). Sát thương lấy từ `sat_thuong` (2) và khoảng đẩy từ `do_day` (1) trong `chi_so.json`, không ghi số trong code.
5. **Va chạm (FR17).** Quân bị đẩy:
   - vào **mép bàn, rừng, kho lương** (và làng, xem "Quyết định mặc định") thì **đứng yên và mất 1 máu**;
   - vào **quân khác** thì đứng yên, **cả hai mất 1 máu**;
   - còn 0 máu thì **bị nhấc khỏi bàn** (gục).
6. **Gục thì không đẩy.** **Khi** mục tiêu gục vì sát thương của đòn (ví dụ Kỵ binh 2 máu), **thì** không có bước đẩy: quân đứng sau nó không bị va.
7. **Chỉ đánh quân Nguyên kề bên.** Khoái chỉ đánh được ô **kề cạnh** (4 hướng, không chéo) **có quân Nguyên**. Ô trống, ô có tướng mình, ô chéo, ô xa đều không đánh được (lệnh bị từ chối, bàn giữ nguyên).
8. **Mỗi tướng đánh một lần (FR9).** Đánh không cần đi trước. Đi rồi đánh được. **Đã đánh thì không đi, không đánh được nữa** trong lượt này. Kết thúc lượt thì đánh lại được.
9. **Viền mục tiêu.** **Khi** chọn một tướng, **thì** các quân Nguyên đánh được có **viền màu riêng** (xem "Quyết định của tác giả"), khác hẳn ô xanh lá đi được, vòng chọn vàng, đường đi xanh dương và ô đỏ báo đòn của địch (E2). Áp dụng cho mọi đòn tướng về sau (2.3, 2.4). Phạm Ngũ Lão, Trần Khánh Dư chưa có đòn: không có viền nào.
10. **Xác nhận khi đã đi (FR15).** Tướng **chưa đi** thì một cú bấm vào mục tiêu là đánh luôn. Tướng **đã đi** thì cú bấm đầu chỉ đánh dấu mục tiêu "chờ xác nhận"; bấm **đúng mục tiêu đó** lần nữa mới đánh. Bấm chỗ khác thì bỏ chờ và làm như bình thường.
11. **Tướng đã đánh.** Đồng quân của tướng đã đánh **mờ hẳn** (khác rõ màu "đã đi" của Story 1.5, chữ và máu vẫn đọc được). Đánh xong thì tướng đó tự bỏ chọn. Bấm vào nó hoặc gõ phím số của nó **không chọn được**.
12. **Đánh xóa lịch sử hủy (FR10).** **Cho** tướng A vừa đi, rồi tướng B đánh. **Khi** bấm Hủy (`Z` hoặc nút), **thì** không có gì xảy ra; nút Hủy mờ đi. Có kịch bản cho ca này (`huy/danh_xoa_huy.json`).
13. **Một đường cho mọi đòn đẩy, kéo.** Đẩy đi **từng ô** qua `ForcedMove.run`, dùng chung cho Story 2.3, 2.4 về sau. Máu chỉ đổi qua `Effects.damage`, ô chỉ đổi qua `Effects.move`.
14. **Kịch bản.** Có kịch bản trong `day/`, `va_cham/`, đã duyệt và đạt.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt 4 câu hỏi** ở "Quyết định của tác giả" (2026-10-18, cả 4 câu chọn phương án (a)).
- [x] **Task 1: Khung cho kịch bản mới, viết đợt kịch bản 3, dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Khung (không phải code luật, làm trước để file kịch bản nạp được):
    - `src/core/battle_event.gd`: thêm vào **cuối** enum `Reject`: `ALREADY_ATTACKED`, `NOT_ADJACENT`, `NO_TARGET`.
    - `src/data/scenario_loader.gd`:
      - `REJECT_CODES` thêm `"da_danh_roi": "scenario.viewer.reject_already_attacked"`, `"khong_ke": "scenario.viewer.reject_not_adjacent"`, `"khong_co_dich": "scenario.viewer.reject_no_target"`; sửa `REJECT_LIST` cho đủ 9 mã;
      - `COMMAND_REJECTS` thêm `"danh": ["khong_co_quan", "khong_phai_tuong", "da_danh_roi", "khong_ke", "khong_co_dich"]`; `"di"` thêm `"da_danh_roi"`; sửa chú thích (bỏ "Lệnh chưa có ở đây (danh) nhận mọi mã");
      - `AFTER_KEYS` thêm `"da_danh"`, đọc như `da_di` (dùng lại `_read_moved`, đổi tên chung nếu cần, ví dụ `_read_generals`); `ScenarioData` thêm `checks_attacked`, `after_attacked` như `checks_moved`, `after_moved`.
    - `tests/scenario_runner.gd`: `REJECT_EVENTS` thêm 3 mã (cùng thứ tự với `REJECT_CODES`; test `test_scenario_loader.gd` ~540 kiểm). `compare()` kiểm `da_danh` như `da_di` (đọc `has_attacked`). **Giữ** `PENDING_RULES = {"danh": "2.1"}` ở bước này.
    - `tests/scenario_viewer.gd`: dòng "Sau lệnh" hiện thêm `đã đánh: ...` theo mẫu `đã đi` (khóa i18n mới `scenario.viewer.after_attacked`, `scenario.viewer.after_attacked_none`).
    - `i18n/text.csv`: `scenario.viewer.reject_already_attacked` = `tướng đã đánh rồi trong lượt này`; `scenario.viewer.reject_not_adjacent` = `ô đó không kề tướng`; `scenario.viewer.reject_no_target` = `ô đó không có quân Nguyên để đánh`; `scenario.viewer.after_attacked` = `đã đánh: %s`; `scenario.viewer.after_attacked_none` = `chưa tướng nào đánh`.
    - `src/core/unit.gd`: thêm `var has_attacked: bool` (tham số cuối `_init`, mặc định `false`) để bộ chạy đọc được; `BattleState.clone()` chép thêm. Chưa có luật nào bật nó ở bước này.
    - `tests/test_scenario_loader.gd`: test cho `da_danh` (đọc được, ký hiệu lạ báo lỗi như `da_di`), mã `tu_choi` mới đúng lệnh (`di` + `khong_ke` bị báo lỗi, `danh` + `khong_con_nuoc_di` bị báo lỗi).
  - [x] 1.2 Viết 10 file đúng như Dev Notes "Đợt kịch bản 3", `"da_duyet": false`. Tạo thư mục `day/`, `va_cham/`, `danh/`. Không đụng 15 kịch bản đã duyệt.
  - [x] 1.3 `tools/xem_kich_ban.sh`: đọc lại từng bàn trước/sau, khớp `mo_ta`; dòng `tu_choi` hiện đúng câu tiếng Việt; dòng "Sau lệnh" hiện `đã đánh`. `tools/test.sh`: xanh, `15 đã duyệt · 10 chưa duyệt (10 chưa đạt)`, lý do khớp bảng.
  - [x] 1.4 Commit: `Kịch bản đánh, đẩy, va chạm chờ duyệt (Story 2.1)`.
  - [x] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh`, đọc 10 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ: Bộ binh trúng 2 sát thương còn 1 máu, nên mọi va chạm trong đợt này đều làm nó gục (chưa có quân nào đủ máu để "đứng yên còn sống" sau va chạm, trừ quân bị va ở #6). Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì sửa, cho duyệt lại (lặp 1.3–1.6). `tools/test.sh` **phải trượt** (AC 2). Ghi Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật: sự kiện, chỉ số, hướng** (AC: 4, 5, 13)
  - [x] 2.1 `src/core/battle_event.gd`:
    - `Type` thêm (cuối enum): `DAMAGED` (mất máu: `unit_id`, `amount`, `cause`), `DIED` (gục, bị nhấc khỏi bàn: `unit_id`, `from_cell` là ô lúc gục), `COLLIDED` (va: `unit_id` là quân bị đẩy, `other_id` là quân bị va, 0 nếu là mép bàn hoặc vật cản; `to_cell` là ô bị va), `DROWNED` (chết đuối: `unit_id`, `to_cell`), `ATTACKED` (tướng ra đòn: `unit_id` là tướng, `to_cell` là ô đánh).
    - `Cause` thêm: `STRIKE` (đòn của tướng), `PUSH` (bị đẩy), `COLLISION` (va chạm). Sửa chú thích "Đẩy, kéo thêm ở E2" thành "Kéo thêm ở Story 2.4".
    - Trường mới `amount: int = 0`, `other_id: int = 0`. Hàm tạo tĩnh cho từng loại (`damaged`, `died`, `collided`, `drowned`, `attacked`). `_init` dài ra thì vẫn giữ "trường chỉ gán trong _init".
  - [x] 2.2 `src/core/command.gd`: `Kind.ATTACK` (cuối enum); `static func attack(p_unit_id: int, p_cell: Vector2i) -> Command`. Sửa chú thích đầu file.
  - [x] 2.3 `src/core/stats.gd`: `damage(type)` (`sat_thuong`), `push_distance(type)` (`do_day`). Mục hoãn "`Stats.value` trả 0 khi gõ sai khóa": thêm `assert(unit.has(key), ...)` trong `value()` (lỗi lập trình, không phải lỗi dữ liệu: bộ nạp đã kiểm đủ khóa). Số 1 máu va chạm **không** vào `chi_so.json` (tác giả chốt, câu 3): hằng số `COLLISION_DAMAGE` ở `forced_move.gd`.
  - [x] 2.4 `src/core/grid.gd`: `static func dir_between(from: Vector2i, to: Vector2i) -> Vector2i` cho hai ô kề cạnh (trả `to - from`); `static func is_adjacent(a, b) -> bool` (khoảng cách Manhattan 1). Không đi chéo.
  - [x] 2.5 `src/core/unit.gd`: `func is_alive() -> bool` (`hp > 0`). Sửa chú thích đầu file: `has_attacked` do `RulesAttack` đặt, `RulesEnemyPhase` xóa.
- [x] **Task 3: Effects, ForcedMove, RulesAttack** (AC: 3–8, 13)
  - [x] 3.1 `src/core/effects.gd`:
    - `static func damage(state, unit, amount, cause, events)`: trừ máu, ghi `DAMAGED`; còn ≤ 0 thì **xóa quân khỏi `state.units`** và ghi `DIED`. Đây là nơi duy nhất sửa máu và xử lý gục (M2). Máu không âm dưới 0 trong sự kiện (`amount` là số đã trừ thật, không phải số yêu cầu: xem Dev Notes "Sự kiện").
    - `move()`: sau khi đổi ô, ô mới là **sông** mà quân là quân Nguyên thì xóa quân, ghi `DROWNED` (xem "Va chạm" ở Dev Notes: Khoái không bao giờ đẩy tướng mình, nhưng luật phải đúng cho 2.2–2.4). Tướng không bao giờ được `move` vào sông: `ForcedMove` chặn trước. Hầm chông vẫn để Story 3.4.
    - Sửa chú thích đầu file.
  - [x] 3.2 `src/core/forced_move.gd` (MỚI, `class_name ForcedMove extends RefCounted`): `static func run(state, unit, dir, distance, cause, events) -> void`. Lặp từng ô theo bảng ở Dev Notes "Di chuyển cưỡng bức". Mỗi bước kiểm theo đúng thứ tự trong bảng. Dừng ngay khi quân bị đẩy gục hoặc chết đuối. Kéo (2.4) gọi đúng hàm này với hướng ngược lại.
  - [x] 3.3 `src/core/rules_attack.gd` (MỚI, `class_name RulesAttack extends RefCounted`):
    - `static func targets(state, unit) -> Array[Vector2i]`: ô đánh được, theo thứ tự hướng B→Đ→N→T (`Grid.DIRECTIONS`). Rỗng nếu tướng đã đánh hoặc không phải Nguyễn Khoái (đòn Lão, Dư thêm ở 2.3, 2.4).
    - `static func resolve(state, command, events)`: kiểm theo "Bảng thứ tự kiểm của lệnh đánh"; **kiểm hết rồi mới sửa** (mục hoãn Story 1.5: lệnh bị từ chối không khôi phục `before`). Hợp lệ thì `ATTACKED` → `khoai_strike` → `unit.has_attacked = true`.
    - `static func khoai_strike(state, khoai, cell, events)` theo đoạn mẫu M2 của kiến trúc (bỏ `sat_that_bonus`, ghi chú Story 3.13 thêm).
  - [x] 3.4 `src/core/rules.gd`: `Command.Kind.ATTACK` → `RulesAttack.resolve(state, command, events)`.
  - [x] 3.5 `src/core/rules_move.gd`: tướng **đã đánh** thì `reachable`, `path_to` trả `[]`, và `resolve` từ chối `ALREADY_ATTACKED` (kiểm **trước** `ALREADY_MOVED`; xem bảng). Sửa chú thích đầu file.
  - [x] 3.6 `src/core/rules_enemy_phase.gd`: `end_player_turn` xóa cả `has_attacked` của mọi quân.
  - [x] 3.7 `tests/scenario_runner.gd`: bỏ `"danh"` khỏi `PENDING_RULES` (bảng rỗng, giữ cơ chế và chú thích cho lệnh mới về sau); `_run_step` thêm `"danh"` → `controller.submit(Command.attack(general.id, step.cell))` qua `_check_reject`. `test_runner_stops_at_command_without_rule` không còn lệnh nào để thử: đổi thành test bộ chạy với `PENDING_RULES` gán tạm (hoặc đổi tên thành test "danh chạy qua luật"). Không xóa ý của test; ghi vào "Lệch so với Tasks" nếu phải đổi.
- [x] **Task 4: BattleController** (AC: 8, 12)
  - [x] 4.1 `src/battle/battle_controller.gd`:
    - `submit`: `Command.Kind.ATTACK` → `_undo_snapshot = null` (thay chú thích "Story 2.1: đánh cũng xóa"); `_describe` thêm `quân %d đánh ô c,h`;
    - `attack_targets(unit_id) -> Array[Vector2i]` (chỉ đọc, như `reachable`): `RulesAttack.targets`;
    - sửa chú thích đầu file.
- [x] **Task 5: Test lõi luật và controller** (AC: 3–8, 12, 13)
  - [x] 5.1 `tests/test_forced_move.gd` (MỚI), dựng state bằng tay như `test_rules_move.gd`. Mỗi ca kiểm ô, máu, danh sách quân, **đúng dãy sự kiện** (loại, id, ô, `amount`) và `validate()` rỗng:
    - đẩy 1 ô vào ô trống: một `MOVED` `Cause.PUSH`;
    - đẩy 2 ô (gọi thẳng `run` với `distance = 2`, cho Story 2.4): đi từng ô, hai `MOVED`;
    - mép bàn ở cả 4 hướng; rừng; kho lương; làng: đứng yên, `COLLIDED` (`other_id` 0) rồi `DAMAGED` 1;
    - vào quân khác: `COLLIDED`, rồi `DAMAGED` quân bị đẩy, rồi `DAMAGED` quân bị va (thứ tự này cố định);
    - va làm quân bị đẩy gục: `DIED`, quân bị xóa khỏi `state.units`; va làm cả hai gục;
    - quân Nguyên vào sông: `MOVED` rồi `DROWNED`, bị xóa; tướng bị đẩy vào sông: đứng yên, `COLLIDED`, `DAMAGED` 1 (cho 2.2, 2.4);
    - đẩy qua hầm chông, ô ải: vào ô như ô trống (hầm chông mất máu ở 3.4);
    - đẩy 2 ô mà ô thứ nhất đã va: dừng ngay, không đi tiếp.
  - [x] 5.2 `tests/test_rules_attack.gd` (MỚI):
    - đánh Bộ binh 3 máu: còn 1, đẩy đúng hướng (thử cả 4 hướng); `has_attacked` bật; dãy sự kiện `ATTACKED`, `DAMAGED` 2, `MOVED` `PUSH`;
    - đánh Kỵ binh 2 máu: `DIED`, không có sự kiện đẩy, quân đứng sau không bị gì;
    - từ chối theo đủ bảng (mỗi mã một ca), state giữ nguyên (so từng quân: ô, máu, `has_moved`, `has_attacked`), `has_attacked` **không** bật;
    - đi rồi đánh được; đánh rồi đi bị `ALREADY_ATTACKED`; đánh hai lần bị `ALREADY_ATTACKED`;
    - `targets`: chỉ ô kề có quân Nguyên, đúng thứ tự B→Đ→N→T, không có ô tướng mình, rỗng khi đã đánh, rỗng với Lão và Dư;
    - Lão, Dư gửi lệnh đánh: bị từ chối, state giữ nguyên;
    - `end_player_turn` xóa `has_attacked` (thêm vào `test_rules_enemy_phase.gd`).
  - [x] 5.3 `tests/test_battle_state.gd`: `test_clone_is_deep` kiểm thêm `has_attacked`.
  - [x] 5.4 `tests/test_battle_controller.gd`: đi rồi đánh thì `can_undo()` false, `undo()` trả `NOTHING_TO_UNDO`; đánh bị từ chối thì bản chụp hủy giữ nguyên (nước đi trước vẫn hủy được); `attack_targets` đúng; lệnh đánh làm gục quân thì `validate()` rỗng (không bị quay lại).
  - [x] 5.5 `tests/test_core_types.gd` (nếu đang kiểm `Stats`): `damage`, `push_distance` đọc đúng `chi_so.json`.
  - [x] 5.6 Kiểm test bắt lỗi thật, mỗi lần sửa tạm một chỗ rồi trả lại, ghi Debug Log:
    - bỏ dòng `_undo_snapshot = null` của ATTACK → `huy/danh_xoa_huy.json` và test controller phải trượt;
    - đẩy trước khi trừ máu (đảo thứ tự trong `khoai_strike`) → `day/muc_tieu_guc_khong_day.json` phải trượt;
    - bỏ máu va chạm ở mép bàn → `va_cham/day_vao_mep.json` phải trượt;
    - va quân khác chỉ trừ máu quân bị đẩy → `va_cham/day_vao_quan_khac.json` phải trượt;
    - bỏ `unit.has_attacked = true` → `danh/da_danh_roi.json` phải trượt;
    - cho đánh ô chéo (dùng khoảng cách Chebyshev) → `danh/khong_danh_duoc.json` phải trượt.
- [x] **Task 6: Giao diện: viền mục tiêu, xác nhận, đồng đã đánh** (AC: 9–12)
  - [x] 6.1 `src/battle/board_view.gd`:
    - `show_selection(unit_cell, cells, targets: Array[Vector2i] = [])` (giữ chữ ký cũ chạy được); `_target_cells`; `show_pending(cell)` (ô "chờ xác nhận", `NO_CELL` là bỏ); getter `target_cells()`, `pending_cell()` cho test; `clear_selection()` xóa cả hai;
    - vẽ viền mục tiêu trong **cùng vòng lặp theo độ sâu** với bệ ô ải, ô sáng, vòng chọn (Story 1.7), tại `_top_center(cell)`, là đường viền ô thoi (`draw_polyline` khép kín), không tô kín (ô đỏ báo đòn E2 sẽ tô kín). Ô chờ xác nhận vẽ viền dày gấp đôi. Màu **trắng** (tác giả chốt, câu 1): `TARGET_COLOR`, `TARGET_WIDTH`, `PENDING_WIDTH` đặt cạnh `REACH_COLOR`;
    - viền vẽ trên mặt đất, dưới đồng quân: đồng quân che phần giữa ô là đúng; viền phải thấy rõ quanh chân đồng (kiểm bằng mắt, Task 8).
  - [x] 6.2 `src/battle/unit_token.gd`: `update` nhận `unit.has_attacked`, `queue_redraw()` khi đổi; `is_attacked() -> bool`; `_fill_color()` (chỗ có chú thích "Story 2.1 thêm màu 'đã đánh' ở đây") trả màu "đã đánh": **xám nhạt**, chữ xám đậm (tác giả chốt, câu 1). **Không dùng độ trong suốt** (chú thích đầu file: bóng mờ dành cho xem trước 2.12); "mờ hẳn" làm bằng màu xám nhạt, chữ và vòng máu vẫn đọc được.
  - [x] 6.3 `src/battle/battle_view.gd`, theo bảng ở Dev Notes "Bấm chuột khi đang chọn tướng":
    - `_targets: Array[Vector2i]`, `_pending: Vector2i = BoardView.NO_CELL`;
    - `_select`: `_targets = _controller.attack_targets(id)`, truyền cho `show_selection`; xóa `_pending`;
    - `_on_cell_clicked`: thêm nhánh mục tiêu **trước** nhánh ô sáng; tướng đã đánh không chọn được (cả chuột lẫn phím 1-2-3, `_on_general_key`);
    - `_on_events_resolved`: tướng đang chọn đã đánh (`has_attacked`) thì bỏ chọn; còn lại như cũ;
    - `_deselect`, `_on_undo`, `_on_end_turn`: xóa `_pending`;
    - `target_cells()`, `pending_cell()` cho test.
  - [x] 6.4 Dòng nhắc (tác giả chốt, câu 2): `src/ui/hud.gd` thêm `show_hint(text)` (chuỗi rỗng là ẩn), khóa `hud.confirm_attack` = `Bấm lần nữa để đánh` trong `i18n/text.csv`; `BattleView` gọi khi có/không có `_pending`.
- [x] **Task 7: Test giao diện** (AC: 9–12)
  - [x] 7.1 `tests/test_battle_view.gd` thêm. Trận 1 không có Bộ binh nào kề Khoái lúc đầu: viết trận thử vào `user://` như `test_board_view.gd` (`PASS_LEVEL`), ví dụ Khoái ở `3,4`, Lão ở `0,6`, Bộ binh ở `3,3`, Kỵ binh ở `4,4`. Các ca:
    - chọn Khoái (phím `1` thật): `target_cells()` là `[3,3, 4,4]` theo thứ tự B→Đ→N→T (Bắc trước Đông), bàn cờ vẽ đúng các ô đó;
    - bấm chuột thật (qua `_unhandled_input`, như `_click_by_mouse`) vào Bộ binh: Bộ binh ở `3,2` còn 1 máu; đồng Khoái `is_attacked()`; Khoái bị bỏ chọn; nút Hủy mờ;
    - bấm Khoái hoặc phím `1` sau đó: không chọn được;
    - đi Khoái một ô kề Bộ binh rồi bấm Bộ binh: chưa đánh, `pending_cell()` là ô đó; bấm lần nữa: đánh;
    - đã đi, bấm mục tiêu lần đầu rồi bấm một ô khác (ô trống ngoài tầm): bỏ chờ, bỏ chọn như cũ; bấm mục tiêu khác: chuyển chờ sang mục tiêu đó, chưa đánh;
    - Lão đi, Khoái đánh, `Z` (phím thật): không có gì đổi, Lão vẫn ở ô mới;
    - Space: Khoái hết `is_attacked()`, chọn và đánh lại được;
    - chọn Lão: `target_cells()` rỗng.
  - [x] 7.2 `tests/test_board_view.gd`: viền mục tiêu và ô chờ được xóa khi `clear_selection`, `show_state(null)`.
  - [x] 7.3 Kiểm test giao diện bắt lỗi thật (sửa tạm, trả lại, ghi Debug Log): bỏ bước "đã đi thì chờ xác nhận" → ca xác nhận trượt; bỏ chặn chọn tướng đã đánh → ca "không chọn được" trượt.
- [x] **Task 8: Tài liệu, kiểm bằng mắt, commit** (AC: 3–14)
  - [x] 8.1 `_bmad-output/planning-artifacts/game-architecture.md`: cây thư mục thêm `src/core/forced_move.gd`; mục "Dữ liệu trận, chỉ số và kịch bản luật" thêm mã `tu_choi` mới và khóa `sau.da_danh`; bảng di chuyển cưỡng bức ghi thứ tự sự kiện khi va quân (bị đẩy trước, bị va sau), số 1 máu va chạm là hằng số trong code, làng làm phần "dừng, mất 1 máu" từ Story 2.1 (Lòng dân −1 ở 3.7).
  - [x] 8.2 Chạy `tools/chay.sh --dev --tran=thu_ba_tuong` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action` cho phím (`select_general_1`…; `inject_key` không kích hoạt action theo phím vật lý, xem Debug Log 1.4), `inject_mouse_click` theo pixel = vị trí bàn (`BoardView.position`, Story 1.7: `(486, 141)`) + `cell_center`. Cần một quân Nguyên kề tướng: đi Dư hoặc Khoái tới cạnh Bộ binh rồi đánh (bấm hai lần vì đã đi). `capture_screenshot`: viền mục tiêu thấy rõ quanh chân đồng; ô chờ xác nhận khác ô chưa chờ; đồng đã đánh khác đồng đã đi; máu đổi đúng. Lưu ảnh vào `_bmad-output/implementation-artifacts/anh/2-1-*.png`. Tắt game. Ghi Debug Log.
  - [x] 8.3 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, `.uid` mới, `text.vi.translation`. Ví dụ: `Nguyễn Khoái đánh, đẩy, va chạm (Story 2.1)`.
  - [x] 8.4 Ghi hướng dẫn tác giả tự test vào Completion Notes theo mẫu ở mục Testing, dùng kết quả thật.

### Review Findings

_Code review 2026-10-18 (Blind Hunter, Edge Case Hunter, Acceptance Auditor)._

- [x] [Review][Decision] Lão, Dư bị từ chối trước bước kiểm ô kề — Bảng thứ tự kiểm đặt dòng "tướng chưa có đòn" cuối bảng, code đặt ngay sau "đã đánh" (đã ghi ở "Lệch so với Tasks", Task 3.3). Hệ quả: Lão đánh ô xa 3 ô báo `NO_TARGET` "chưa có đòn" thay vì `NOT_ADJACENT`. Tác giả chọn giữ như code, sửa bảng cho khớp [game/src/core/rules_attack.gd:35]
- [x] [Review][Decision] `sat_thuong` = 0 được bộ nạp chấp nhận (`MIN_VALUE` 0): đòn vẫn ghi `DAMAGED` 0 rồi đẩy; `Effects.damage` cũng không chặn số âm (âm thì hồi máu). Tác giả chọn tối thiểu 1: bộ nạp chặn `sat_thuong` 0, `Effects.damage` assert `amount > 0` [game/src/core/effects.gd:22]
- [x] [Review][Patch] Ô kề nhưng ngoài bàn (Khoái ở 0,3 đánh -1,3) báo `NO_TARGET`, bảng yêu cầu `NOT_ADJACENT` ("kể cả ô chéo, ngoài bàn"); thêm ca test ô kề ngoài bàn [game/src/core/rules_attack.gd:39]
- [x] [Review][Patch] Task 5.2 đòi test Lão và Dư; test chỉ có Lão (targets rỗng, lệnh đánh bị từ chối), thiếu Dư [game/tests/test_rules_attack.gd]
- [x] [Review][Patch] `_assert_same_state` không so `has_attacked`: hủy/quay lại mà quên khôi phục cờ đánh thì không test nào bắt [game/tests/test_battle_controller.gd:193]
- [x] [Review][Patch] `Grid.dir_between` trả `to - from`, không bảo đảm là một bước của DIRECTIONS như chú thích; người gọi sau (Sát Thát, 2.3) đưa ô không kề thì `ForcedMove` nhảy cóc qua vật cản. Thêm assert kề [game/src/core/grid.gd:15]
- [x] [Review][Patch] Test ghi cứng chữ "Bấm lần nữa để đánh" thay vì `tr("hud.confirm_attack")` [game/tests/test_battle_view.gd:584]
- [x] [Review][Patch] Test `end_player_turn` xóa `has_attacked` nằm ở `test_rules_attack.gd`, Task 5.2 ghi `test_rules_enemy_phase.gd`; chưa ghi vào "Lệch so với Tasks" [_bmad-output/implementation-artifacts/2-1-nguyen-khoai-danh-day-va-va-cham.md]
- [x] [Review][Defer] Đang chờ xác nhận mà bấm (hoặc gõ phím) vào tướng đã đánh thì không bỏ chờ, gợi ý "Bấm lần nữa" vẫn còn (AC 10) [game/src/battle/battle_view.gd:83] — deferred, chưa gặp được: chỉ Khoái có đòn; xem lại ở Story 2.3/2.4
- [x] [Review][Defer] `UnitToken.update` trả màu chữ tên về màu Đại Việt khi bỏ cờ đã đánh, kể cả quân Nguyên [game/src/battle/unit_token.gd:82] — deferred, quân Nguyên chưa đánh tới 2.6+
- [x] [Review][Defer] Danh sách vật cản của `ForcedMove.OBSTACLES` tách khỏi `Terrain.WALKABLE`: thêm loại ô không đi được mà quên thêm vào đây thì quân bị đẩy lên ô đó, `validate` quay lại cả đòn [game/src/core/forced_move.gd:10] — deferred, hai danh sách hiện khớp
- [x] [Review][Defer] Bộ chạy kịch bản bỏ qua tướng đã gục khi so `da_danh` [game/tests/scenario_runner.gd:177] — deferred, tướng chưa gục được trong kịch bản 2.1; bàn sau vẫn bắt phần lớn
- [x] [Review][Defer] `_on_target_clicked` không kiểm tướng đang chọn còn trên bàn [game/src/battle/battle_view.gd] — deferred, tướng chưa gục được giữa hai cú bấm

## Dev Notes

### Bối cảnh

- Story luật đầu tiên của E2, cũng là đòn đầu tiên. Lần đầu có **máu đổi**, **quân gục**, **di chuyển cưỡng bức**. Mọi đòn về sau (lao 2.3, kéo 2.4, đòn địch 2.8) dùng lại `Effects.damage`, `ForcedMove.run` của story này: làm đúng hợp đồng M2 của kiến trúc.
- **Chưa có:** sông và trúng tướng mình **trong kịch bản** (2.2; code của `ForcedMove` đã đúng bảng, xem "Va chạm"), lao (2.3), kéo (2.4), **thắng/thua** (2.5: quân gục vẫn bị nhấc khỏi bàn ngay ở story này vì `validate()` không cho máu < 1), AI và báo đòn (2.6–2.9), hoạt ảnh (2.11), xem trước (2.12), hầm chông (3.4), Lòng dân (3.7), Sát Thát (3.13).
- Tác giả không đọc code. Thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Luật (spec) **[FR9, FR10, FR12, FR15, FR17; kiến trúc "Bảng thứ tự phân giải", M2]**

- **Đòn Nguyễn Khoái:** đánh 1 ô **kề cạnh có quân Nguyên**, gây `sat_thuong` (2) sát thương, rồi nếu mục tiêu còn sống thì đẩy `do_day` (1) ô **theo hướng đánh** (từ Khoái sang mục tiêu). Thứ tự: kiểm hợp lệ → sát thương → đẩy nếu còn sống → (kiểm thắng/thua: Story 2.5).
- **Tiết kiệm hành động:** mỗi tướng đi một lần và đánh một lần mỗi lượt người chơi. Đánh mà không đi được. Đã đánh thì không đi được nữa. Ba tướng hành động theo thứ tự tùy ý.
- **Không chọn tướng mình làm mục tiêu** (chốt 2026-10-17): bấm vào tướng mình luôn là chọn tướng. Ở mức luật: đánh ô có tướng mình bị từ chối `NO_TARGET`.
- **Hủy:** chỉ hủy được nước đi gần nhất, khi tướng đó chưa đánh. Đánh xóa bản chụp hủy, nên "đi A, đánh B, hủy" không làm gì. "Đi Khoái, đánh Khoái, hủy" cũng không làm gì.
- **Gục:** máu về 0 (hoặc dưới) thì bị nhấc khỏi bàn, cả quân Nguyên lẫn tướng (kiến trúc, **(mặc định)** [KIỂM TRA KHI PLAYTEST E4]).
- Với chỉ số hiện tại: Bộ binh (3 máu) trúng đòn còn 1, bị đẩy; va gì cũng gục. Kỵ binh (2) và Cung kỵ (1) gục ngay, không bị đẩy.

### Di chuyển cưỡng bức (`ForcedMove.run`)

Lặp từng ô, tối đa `distance` ô. Ở mỗi bước, `next = unit.cell + dir`, kiểm theo đúng thứ tự:

| # | `next` là | Kết quả | Sự kiện (theo thứ tự) |
|---|---|---|---|
| 1 | Ngoài bàn (mép) | Dừng. Quân bị đẩy mất 1 máu | `COLLIDED` (other 0, `to_cell` = `next`), `DAMAGED` 1 `COLLISION` (có thể `DIED`) |
| 2 | Rừng `#`, kho lương `L`, làng `D` (tác giả chốt, câu 4) | Dừng. Quân bị đẩy mất 1 máu (vật cản không có máu) | như #1 |
| 3 | Có quân khác (**bất kể phe nào**) | Dừng. **Cả hai** mất 1 máu | `COLLIDED` (other = quân bị va), `DAMAGED` quân bị đẩy, `DAMAGED` quân bị va |
| 4 | Sông `~` | Quân Nguyên: vào ô và chết đuối. Tướng: như #1 | Quân Nguyên: `MOVED` `PUSH`, `DROWNED`. Tướng: như #1 |
| 5 | Còn lại (đất trống, hầm chông, ô ải) | Vào ô, đi tiếp | `MOVED` `cause` (hầm chông mất máu ở 3.4, qua `Effects.move`) |

- Dừng ngay khi quân bị đẩy đã gục hoặc chết đuối (không còn trong `state.units`).
- "Mất 1 máu" ở bảng là luật cố định của GDD, không phải `sat_thuong` của ai: hằng số `COLLISION_DAMAGE: int = 1` ở `forced_move.gd`, chú thích "luật GDD, tác giả chốt 2026-10-18 không đưa vào chi_so.json".
- Sát Thát (+1) **không** cộng vào sát thương va chạm (kiến trúc, mục Mưu kế): đừng truyền bonus vào `ForcedMove`.
- Làng: Lòng dân −1 khi bị va thêm ở Story 3.7; ghi chú trong code ở nhánh #2.
- Đòn dịch theo quân bị đẩy (M1) thêm ở Story 2.9: chưa có `Telegraph`, không làm gì.

### Va chạm với tướng mình, sông

- Khoái chỉ đánh quân Nguyên, nhưng quân bị đẩy có thể **va vào tướng mình** (cả hai mất 1 máu) hoặc **xuống sông** (chết đuối). Bảng trên đã đúng cho cả hai, nên code làm đúng luôn. **Kịch bản** cho hai ca này thuộc Story 2.2 (`va_cham/` trúng quân mình, `dia_hinh/` sông), không viết ở đợt này. Test GUT ở Task 5.1 vẫn phủ cả hai.
- Bộ binh trúng đòn còn 1 máu, nên xuống sông hay va bờ đều biến khỏi bàn: bàn sau giống nhau. Khác nhau ở sự kiện (`DROWNED` hay `DIED`), cần cho hoạt ảnh 2.11; test GUT kiểm sự kiện.

### Đợt kịch bản 3

Quy ước như đợt 1–2: `phien_ban_dinh_dang: 1`, bàn 7×7, mỗi ô cách nhau một dấu cách, `sau.dia_hinh` chép y `truoc.dia_hinh`. Bàn ghi theo tọa độ `cot,hang`; ô không nêu là đất trống `.`, không có quân. Chỉ ghi `mau` cho quân không đủ máu. Mọi kịch bản ghi `sau.da_danh` (và `sau.da_di` khi có lệnh `di`). Không có `ket_thuc_luot`, nên quân Nguyên trên bàn không bị pha địch (E2) làm hỏng.

| # | File | `mo_ta` | Bàn trước | `hanh_dong` | Bàn sau |
|---|---|---|---|---|---|
| 1 | `day/danh_day_1_o.json` | `Nguyễn Khoái đánh Bộ binh kề trên: Bộ binh còn 1 máu, bị đẩy lùi 1 ô lên trên.` | `1` ở 3,4; `B` ở 3,3 | `danh 1 → 3,3` | `1` ở 3,4; `B` ở 3,2, `mau 3,2: 1`; `da_danh: ["1"]` |
| 2 | `day/muc_tieu_guc_khong_day.json` | `Kỵ binh 2 máu trúng đòn thì gục ngay, không bị đẩy: Bộ binh đứng sau nó không bị va.` | `1` ở 3,4; `K` ở 3,3; `B` ở 3,2 | `danh 1 → 3,3` | `1` ở 3,4; `B` ở 3,2 (đủ 3 máu); `da_danh: ["1"]` |
| 3 | `va_cham/day_vao_mep.json` | `Bộ binh ở sát mép trái bị đẩy ra ngoài bàn: đứng yên, mất thêm 1 máu, gục.` | `1` ở 1,3; `B` ở 0,3 | `danh 1 → 0,3` | `1` ở 1,3; `da_danh: ["1"]` |
| 4 | `va_cham/day_vao_rung.json` | `Bộ binh bị đẩy vào rừng: đứng yên, mất thêm 1 máu, gục. Rừng không bị gì.` | `#` ở 3,2; `1` ở 3,4; `B` ở 3,3 | `danh 1 → 3,3` | `#` ở 3,2; `1` ở 3,4; `da_danh: ["1"]` |
| 5 | `va_cham/day_vao_kho_luong.json` | `Bộ binh bị đẩy sang phải vào kho lương: đứng yên, mất thêm 1 máu, gục.` | `L` ở 4,3; `1` ở 2,3; `B` ở 3,3 | `danh 1 → 3,3` | `L` ở 4,3; `1` ở 2,3; `da_danh: ["1"]` |
| 6 | `va_cham/day_vao_quan_khac.json` | `Bộ binh bị đẩy vào Bộ binh khác: cả hai mất 1 máu. Con bị đẩy gục, con bị va còn 2 máu.` | `1` ở 3,5; `B` ở 3,4; `B` ở 3,3 | `danh 1 → 3,4` | `1` ở 3,5; `B` ở 3,3, `mau 3,3: 2`; `da_danh: ["1"]` |
| 7 | `huy/danh_xoa_huy.json` | `Phạm Ngũ Lão đi, rồi Nguyễn Khoái đánh: đòn đánh xóa lịch sử hủy, bấm hủy không có gì xảy ra, Lão vẫn ở ô mới.` | `1` ở 3,4; `B` ở 3,3; `2` ở 0,6 | `di 2 → 0,5`; `danh 1 → 3,3`; `huy` **`tu_choi: khong_con_nuoc_di`** | `1` ở 3,4; `B` ở 3,2, `mau 3,2: 1`; `2` ở 0,5; `da_di: ["2"]`; `da_danh: ["1"]` |
| 8 | `danh/di_roi_danh.json` | `Nguyễn Khoái đi lên 2 ô tới cạnh Bộ binh rồi đánh: đi rồi vẫn đánh được.` | `1` ở 3,6; `B` ở 3,3 | `di 1 → 3,4`; `danh 1 → 3,3` | `1` ở 3,4; `B` ở 3,2, `mau 3,2: 1`; `da_di: ["1"]`; `da_danh: ["1"]` |
| 9 | `danh/da_danh_roi.json` | `Nguyễn Khoái đánh rồi thì không đánh tiếp, cũng không đi được nữa trong lượt này.` | `1` ở 3,4; `B` ở 3,3; `B` ở 4,4 | `danh 1 → 3,3`; `danh 1 → 4,4` **`tu_choi: da_danh_roi`**; `di 1 → 2,4` **`tu_choi: da_danh_roi`** | `1` ở 3,4; `B` ở 3,2, `mau 3,2: 1`; `B` ở 4,4; `da_di: []`; `da_danh: ["1"]` |
| 10 | `danh/khong_danh_duoc.json` | `Nguyễn Khoái không đánh được ô trống, tướng mình đứng kề, hay quân Nguyên đứng chéo.` | `1` ở 3,4; `2` ở 4,4; `B` ở 4,3 | `danh 1 → 2,4` **`tu_choi: khong_co_dich`**; `danh 1 → 4,4` **`tu_choi: khong_co_dich`**; `danh 1 → 4,3` **`tu_choi: khong_ke`** | giống trước; `da_danh: []` |

Mỗi kịch bản thử đúng điều `mo_ta` nói (đã kiểm khi tạo story, dev kiểm lại và ghi Debug Log):
- **#1:** hướng đánh `3,4` → `3,3` là Bắc, nên đẩy lên `3,2`. Đẩy sai hướng (về phía Khoái) thì va Khoái, cả hai mất máu: trượt.
- **#2:** nếu code đẩy trước khi xét gục (hoặc đẩy cả quân đã gục) thì Kỵ binh va Bộ binh ở `3,2`, Bộ binh còn 2 máu: trượt.
- **#3:** đẩy về Tây ra ngoài bàn. Không trừ máu mép bàn thì Bộ binh còn 1 máu ở `0,3`: trượt. Cho quân ra ngoài bàn thì `validate()` báo: trượt.
- **#4, #5:** như #3 với rừng (Bắc) và kho lương (Đông). Cho quân vào ô vật cản thì `validate()` báo "đứng trên ô không đi vào được".
- **#6:** chỉ trừ máu quân bị đẩy thì Bộ binh ở `3,3` còn 3 máu: trượt. Trừ máu quân bị va mà quên quân bị đẩy thì quân bị đẩy còn 1 máu ở `3,4`: trượt.
- **#7:** đường Lão `0,6` → `0,5` (1 bước). Nếu đánh không xóa bản chụp hủy thì hủy chạy được, Lão về `0,6` **và Bộ binh về 3 máu ở `3,3`**: trượt.
- **#8:** đường Khoái `3,6` → `3,5` → `3,4`. Nếu luật cấm đánh sau khi đi thì bị từ chối: trượt.
- **#9:** lệnh đánh thứ hai nhắm Bộ binh ở `4,4` (vẫn kề Khoái, ở hướng Đông) để chỉ cờ "đã đánh" mới chặn được. Lệnh đi `2,4` 1 bước, trong tầm: chỉ cờ "đã đánh" mới chặn.
- **#10:** `2,4` kề nhưng trống; `4,4` kề nhưng là tướng mình; `4,3` có quân Nguyên nhưng chéo. Bàn giữ nguyên.

**Lý do chưa đạt** (sau Task 1.1, trước khi có code luật, dòng ⏳ của `tools/test.sh`):

| File | Lý do |
|---|---|
| `day/danh_day_1_o.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `day/muc_tieu_guc_khong_day.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `va_cham/day_vao_mep.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `va_cham/day_vao_rung.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `va_cham/day_vao_kho_luong.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `va_cham/day_vao_quan_khac.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `huy/danh_xoa_huy.json` | `bước 2: lệnh "danh" chưa có luật (Story 2.1)` |
| `danh/di_roi_danh.json` | `bước 2: lệnh "danh" chưa có luật (Story 2.1)` |
| `danh/da_danh_roi.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |
| `danh/khong_danh_duoc.json` | `bước 1: lệnh "danh" chưa có luật (Story 2.1)` |

Câu chính xác lấy từ `PENDING_RULES` hiện có (`tests/scenario_runner.gd:8-10`); dev kiểm lại và sửa bảng nếu câu thật khác. Ví dụ một lệnh trong file: `{"lenh": "danh", "tuong": "1", "o": "3,3"}`, `{"lenh": "danh", "tuong": "1", "o": "4,4", "tu_choi": "da_danh_roi"}`. Không viết thêm kịch bản ngoài 10 cái này.

### Bảng thứ tự kiểm của lệnh đánh

| Kiểm | `Reject` | Mã `tu_choi` | Lý do (cho dev và log, không qua `tr()`) |
|---|---|---|---|
| Không có quân id đó | `NO_UNIT` | `khong_co_quan` | `không có quân %d` |
| Quân không phải tướng | `NOT_GENERAL` | `khong_phai_tuong` | `quân %d không phải tướng` |
| Tướng đã đánh trong lượt này | `ALREADY_ATTACKED` | `da_danh_roi` | `quân %d đã đánh rồi trong lượt này` |
| Tướng chưa có đòn (Lão, Dư) | `NO_TARGET` | — (không có kịch bản) | `quân %d chưa có đòn (Story 2.3, 2.4)` |
| Ô không kề cạnh tướng (kể cả ô chéo, ngoài bàn) | `NOT_ADJACENT` | `khong_ke` | `ô c,h không kề quân %d` |
| Ô không có quân Nguyên (trống, tướng mình) | `NO_TARGET` | `khong_co_dich` | `ô c,h không có quân Nguyên để đánh` |

_Code review 2026-10-18: tác giả chốt "chưa có đòn" kiểm ngay sau "đã đánh" (chưa có đòn thì không cần kiểm ô). Story 2.3, 2.4 thêm đòn thì Lão, Dư đi tiếp xuống các dòng dưới._

Lệnh đi, thêm **trước** `ALREADY_MOVED`: tướng đã đánh → `ALREADY_ATTACKED`, mã `da_danh_roi`, lý do `quân %d đã đánh rồi trong lượt này`. (Tướng vừa đi vừa đánh thì báo "đã đánh", rõ hơn cho người đọc log.)

Kiểm hết rồi mới sửa: `resolve` không được gọi `Effects` trước khi qua hết các dòng trên (`BattleController.submit` không khôi phục state khi lệnh bị từ chối, mục hoãn Story 1.5).

### Sự kiện

- Một lệnh đánh Bộ binh 3 máu ra ô trống: `ATTACKED(1, 3,3)`, `DAMAGED(101, 2, STRIKE)`, `MOVED(101, 3,3 → 3,2, PUSH)`.
- Đánh rồi đẩy vào rừng: `ATTACKED`, `DAMAGED(2, STRIKE)`, `COLLIDED(101, other 0, 3,2)`, `DAMAGED(1, COLLISION)`, `DIED(101)`.
- `amount` của `DAMAGED` là số máu đã trừ thật: quân 1 máu trúng 2 thì `amount` = 1 (hoạt ảnh hiện "−1" là đúng; máu không âm). Ghi rõ trong chú thích `Effects.damage`.
- Sự kiện chỉ để phát lại (2.11) và để test. Phần hiển thị ở story này chưa đọc sự kiện: vẽ lại theo bản chụp.

### Bấm chuột khi đang chọn tướng (BattleView, sau story này)

| Bấm vào | Tướng đang chọn chưa đi | Tướng đang chọn đã đi |
|---|---|---|
| Tướng mình chưa đánh | chọn tướng đó (bấm lại tướng đang chọn: bỏ chọn) | như bên trái |
| Tướng mình **đã đánh** | không gì (giữ nguyên chọn) | như bên trái |
| Mục tiêu (có viền) | đánh ngay | lần đầu: chờ xác nhận (`_pending`); bấm lại đúng ô đó: đánh; bấm mục tiêu khác: chuyển chờ sang đó |
| Ô sáng (đi được) | đi | (không có ô sáng: đã đi) |
| Chỗ khác (ô trống, quân Nguyên không có viền, ngoài bàn) | bỏ chọn | bỏ chờ, bỏ chọn |

- Đánh xong: tướng đó tự bỏ chọn (ở `_on_events_resolved`, vì đánh rồi thì không còn gì để làm với nó).
- Phím 1-2-3 của tướng đã đánh: không gì.
- Không có tướng nào đang chọn mà bấm quân Nguyên: bỏ chọn như cũ (chưa có xem thông tin, 2.10).
- Rê chuột lên mục tiêu: chưa có gì (xem trước là 2.12). Đường đi xanh dương chỉ vẽ khi rê lên ô sáng, như cũ.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/battle_event.gd`: `Type { MOVED, REJECTED, ROUND_STARTED }`, `Cause { WALK }`, `Reject { NONE, NO_UNIT, NOT_GENERAL, ALREADY_THERE, UNREACHABLE, ALREADY_MOVED, NOTHING_TO_UNDO }`; một `_init` theo vị trí và 3 hàm tạo. Thêm vào cuối enum để không đổi số của giá trị cũ.
- `src/core/effects.gd`: chỉ có `move()`. `tools/check_boundaries.sh:55` bắt mọi phép gán `.hp`, `.cell` ngoài file này.
- `src/core/command.gd`: `Kind { MOVE, END_TURN }`, trường `kind, unit_id, cell` chỉ gán trong `_init`.
- `src/core/stats.gd`: `value()`, `max_hp`, `move_range`. `chi_so.json`: `nguyen_khoai` có `sat_thuong: 2`, `do_day: 1`.
- `src/core/grid.gd`: chỉ có `DIRECTIONS` (B, Đ, N, T).
- `src/core/unit.gd`: `id, faction, type, cell, hp, has_moved`; `_init(p_id, p_type, p_cell, p_hp, p_has_moved = false)`.
- `src/core/battle_state.gd`: `clone()` dòng 45 tạo `Unit.new(u.id, u.type, u.cell, u.hp, u.has_moved)`: thêm `has_attacked`. `validate()` không cho máu < 1 nên quân gục phải bị xóa khỏi `units`. `terrain_at` không tự kiểm biên: gọi `in_bounds` trước (mục hoãn).
- `src/core/rules.gd`: `match command.kind` gọi `RulesMove.resolve` / `RulesEnemyPhase.end_player_turn`.
- `src/core/rules_move.gd`: thứ tự kiểm `NO_UNIT, NOT_GENERAL, ALREADY_MOVED, ALREADY_THERE, UNREACHABLE`.
- `src/core/rules_enemy_phase.gd`: xóa `has_moved` của mọi quân, tăng hiệp.
- `src/battle/battle_controller.gd`: `submit` (dòng 33–55) có `match command.kind` đặt/xóa `_undo_snapshot`, chú thích "Story 2.1: đánh cũng xóa"; `_describe`; `reachable`, `path_to`.
- `src/battle/battle_view.gd`: `_on_cell_clicked` (tướng mình → chọn; ô sáng → đi; còn lại → bỏ chọn); `_select` gọi `reachable`, `show_selection`, `refresh_hover`; `_on_events_resolved` chọn lại tướng đang chọn.
- `src/battle/board_view.gd`: `show_selection(unit_cell, cells)`, `clear_selection`, `_draw` vẽ bệ ô ải, ô sáng, vòng chọn trong một vòng lặp theo độ sâu (Story 1.7, sửa theo review); `REACH_COLOR` xanh lá, chú thích "khác đỏ của ô báo đòn (E2)".
- `src/battle/unit_token.gd`: `_fill_color()` có chú thích "Story 2.1 thêm màu 'đã đánh' ở đây"; `DAI_VIET_MOVED_COLOR` đỏ xỉn; không dùng độ trong suốt.
- `src/data/scenario_loader.gd`, `src/data/scenario_data.gd`, `tests/scenario_runner.gd`, `tests/scenario_viewer.gd`: `danh` đã có trong `COMMANDS` (`tuong`, `o`, `tu_choi`) và chữ `scenario.viewer.step_attack` = `%s đánh ô %s` đã có; `PENDING_RULES = {"danh": "2.1"}`; `da_di` làm mẫu cho `da_danh`.

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm.
- Một điểm vào: `Rules.resolve(state, command) -> Array[BattleEvent]`. Luật đánh ở `rules_attack.gd`; vòng đẩy ở `forced_move.gd` (kiến trúc gọi tên `ForcedMove.run` nhưng cây thư mục chưa có file: tạo mới, ghi vào cây ở Task 8.1).
- Chỉ `Effects.damage` sửa máu và xử lý gục; chỉ `Effects.move` sửa ô. Xóa quân khỏi `state.units` cũng chỉ ở `Effects`.
- Mọi hàm luật nhận `events` rồi `append`; không hàm nào tự tạo danh sách riêng.
- Duyệt quân theo thứ tự trong `state.units`, không theo khóa Dictionary. Hòa thì theo B→Đ→N→T. Không `float` trong luật.
- Chỉ `BattleController` giữ state sống; UI gửi `Command` qua `submit()`, đọc bản chụp.
- Ô ↔ điểm chỉ qua `BoardView` (`cell_center`, `top_center`, `pick_cell`). Ô sáng, viền, vòng chọn vẽ trong vòng lặp theo độ sâu của `BoardView._draw`.
- Chữ hiện lên màn hình qua `tr()`, khóa `<man>.<muc>`. Lý do từ chối là chữ cho dev, không qua `tr()`.
- Không `assert` cho lỗi dữ liệu (file trận, chỉ số); `assert` chỉ cho lỗi lập trình (khóa chỉ số gõ sai trong code).

### Testing

- `tools/test.sh` là lệnh duy nhất. Viết test trước, cho thấy đỏ, rồi mới code (ghi Debug Log).
- Lõi luật test thẳng (`BattleState` + `Rules.resolve`/`ForcedMove.run`), mỗi ca kiểm `validate()` rỗng **và dãy sự kiện**, không chỉ bàn sau.
- Giao diện test qua `main.tscn` thật (`_make_main`), phím gửi bằng `InputEventKey` có `physical_keycode`, chuột bằng sự kiện thật qua `_unhandled_input`. Trận thử viết vào `user://` rồi xóa ở `after_each`.
- Mỗi test hành vi mới phải được "phá thử" (Task 5.6, 7.3): sửa tạm code để test trượt, trả lại, ghi Debug Log.
- Mẫu hướng dẫn tác giả tự test (Completion Notes):
  1. `tools/test.sh`: thấy dòng `Kịch bản luật: 25 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ ... test đạt`.
  2. `tools/chay.sh --dev --tran=thu_ba_tuong`. Đi một tướng tới cạnh Bộ binh … (bước thật, có tọa độ ô).
  3. Thấy viền màu … quanh Bộ binh; bấm một lần: … (chờ xác nhận); bấm lần nữa: Bộ binh còn 1 máu, lùi 1 ô.
  4. Đồng quân tướng vừa đánh … (màu đã chốt); bấm vào không chọn được; nút Hủy mờ.
  5. Thử đẩy vào rừng / kho / quân khác / mép bàn: …
  6. `Space`: tướng hết mờ, đánh lại được.
  - Nhắc: tắt bộ gõ VNI/Telex trước khi gõ phím; trên Mac F1 là Fn+F1.

### Previous Story Intelligence (Story 1.3–1.7 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log phải giống nhau; mọi chỗ làm khác Tasks ghi vào "Lệch so với Tasks"; có "Agent Model Used"; task chụp ảnh thì phải có file ảnh (review 1.5, 1.7).
- **Test yếu đã bị bắt:** điểm bấm vốn đã cho đúng kết quả dù không có tính năng (1.7); điều kiện trước không dựng (`can_undo()` luôn false, 1.5); chỉ so ô mà không so máu, cờ (1.5). Mỗi test hành vi mới phải phá thử.
- **Chuột đứng yên:** sau khi bàn đổi (đi, hủy, đánh), ô dưới chuột phải chọn lại (`BattleInput.refresh_hover`, review 1.7). `_select` đã gọi; đánh xong thì bỏ chọn nên không cần thêm.
- **Bộ nạp kịch bản phải chặn mã `tu_choi` sai lệnh** (`COMMAND_REJECTS`, review 1.5): thêm `danh` ngay ở Task 1.1, không để "nhận mọi mã".
- **Log:** `Log.debug` ghi lệnh nhận vào trước khi phân giải (review 1.5) — `_describe` phải có nhánh ATTACK.
- **Phím thật:** test phải gửi `InputEventKey` với `physical_keycode`, không chỉ action (1.4, 1.5). GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node (`_input`…), GUT bỏ qua cả file (1.4).
- **Màn hình test:** test bấm qua viewport thật cần `SubViewport` riêng (`_make_main_in_viewport`, 1.5).
- **Mục hoãn liên quan** (`deferred-work.md`): lệnh bị từ chối không khôi phục `before` (giữ "kiểm hết rồi mới sửa"); `Stats.value` trả 0 khi gõ sai khóa (thêm assert, Task 2.3); `terrain_at` không kiểm biên (gọi `in_bounds` trước, nhánh #1 của bảng đẩy); `rolled_back` chưa báo người chơi (vẫn hoãn tới `notice.gd`); hủy phát `events_resolved([])` (không đổi).

### Git Intelligence

- 5 commit gần nhất: Story 1.6 (F5) và 1.7 (bàn nghiêng, `428d743` sửa theo review). Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- `428d743` đổi `board_view.gd` (vòng lặp vẽ theo độ sâu cho bệ ô ải, ô sáng, vòng chọn: thêm viền mục tiêu vào **đúng vòng này**), `battle_input.gd` (`refresh_hover`), `coord_overlay.gd`, `battle_view.gd`.
- Tổng test hiện tại: 335/335; kịch bản 15 đã duyệt.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- JSON trả số là `float`: `int()` mọi giá trị máu, tọa độ khi nạp (bộ nạp kịch bản đã làm; khóa `da_danh` là danh sách ký hiệu, không phải số).
- `clone()` phải chép đủ thuộc tính mới (`has_attacked`).
- Đi xuống gọi hàm, đi lên phát signal. `AppState` là autoload duy nhất.
- Quân chỉ tạo qua `UnitFactory.create`. Không tạo quân trong luật đánh.
- Con số cân bằng chỉ trong `data/chi_so.json` (xem câu 3 dưới đây cho số 1 máu va chạm).
- Không sửa, không xóa kịch bản đã duyệt. Kịch bản nghi sai thì hỏi tác giả.
- Commit khi xanh, lời commit tiếng Việt.

### Quyết định của tác giả (2026-10-18)

_Tác giả chốt 2026-10-18: cả 4 câu chọn phương án (a)._

1. **Viền mục tiêu và đồng đã đánh.**
   - (a) **ĐÃ CHỐT:** viền **trắng** quanh ô mục tiêu (ô chờ xác nhận: viền trắng dày gấp đôi); tướng đã đánh: đồng **xám nhạt**, chữ xám đậm. Trắng khác hẳn xanh lá, vàng, xanh dương và đỏ báo đòn.
   - (b) Viền **cam**; đồng đã đánh xám. (Cam gần đỏ báo đòn hơn.)
   - (c) Màu khác do tác giả chọn.
2. **Xác nhận đòn khi tướng đã đi.**
   - (a) **ĐÃ CHỐT:** bấm lần đầu thì viền mục tiêu dày lên **và** bảng bên phải hiện dòng "Bấm lần nữa để đánh"; bấm lần nữa thì đánh.
   - (b) Chỉ viền dày lên, không có dòng chữ.
3. **Số "mất 1 máu" khi va chạm để ở đâu.**
   - (a) **ĐÃ CHỐT:** để trong code như luật cố định của GDD (giống "đẩy theo hướng đánh"), một hằng số ở `forced_move.gd`.
   - (b) Đưa vào `chi_so.json` (nhóm mới, ví dụ `"chung": { "mat_mau_va_cham": 1 }`) để tác giả tự chỉnh khi cân bằng.
4. **Đẩy vào làng `D`.** Kiến trúc: dừng, mất 1 máu, Lòng dân −1. Lòng dân có ở Story 3.7.
   - (a) **ĐÃ CHỐT:** story này làm phần "dừng, mất 1 máu" như rừng; Lòng dân −1 thêm ở 3.7.
   - (b) Chưa làm gì với làng ở story này (để 3.7 làm cả); tạm thời đẩy vào làng làm `validate()` báo lỗi.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Ô ải `A` khi bị đẩy vào: như đất trống (quân đứng lên bệ được, Story 1.7; ô ải không có trong bảng đẩy).
- Hầm chông khi bị đẩy qua: chưa mất máu (Story 3.4 thêm vào `Effects.move`).
- Khoái đánh rồi tự bỏ chọn; bấm hoặc gõ phím tướng đã đánh thì không có gì xảy ra (không bỏ chọn tướng khác đang chọn).
- Thứ tự sự kiện khi va quân: quân bị đẩy mất máu trước, quân bị va sau.
- Kịch bản kiểm thêm `sau.da_danh` (như `da_di`).

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.1 (dòng 524–558), FR9, FR10, FR12, FR15–FR17 (dòng 35–47), UX "viền mục tiêu" (dòng 136).
- `_bmad-output/planning-artifacts/game-architecture.md` M2 "Ống phân giải luật" (dòng 748–771), "Bảng thứ tự phân giải" (dòng 788–845), cây thư mục (dòng 544–561), sự kiện (dòng 277, 481).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 124 (xác nhận), 150 (Nguyễn Khoái), 196 (tướng mình), 201–202 (hủy), 229 (va chạm; kiến trúc và FR17 thắng chỗ GDD nói vật cản cũng mất máu).
- `_bmad-output/project-context.md` (luật bắt buộc, test).
- `_bmad-output/implementation-artifacts/1-5-di-huy-nuoc-di-ket-thuc-luot.md` (mẫu đợt kịch bản, BattleController), `1-7-ban-co-nghieng-isometric-tam.md` (vẽ theo độ sâu, `pick_cell`), `deferred-work.md`.

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1 (khung + đợt kịch bản 3): `tools/test.sh` xanh 339/339, `Kịch bản luật: 15 đã duyệt · 10 chưa duyệt (10 chưa đạt)`; 10 lý do ⏳ khớp bảng "Lý do chưa đạt". `tools/xem_kich_ban.sh` in đúng bàn trước/sau, câu từ chối và dòng "Sau lệnh: … đã đánh: …".
- Task 1.6: tác giả trả lời "đúng" cho cả 10 kịch bản (2026-10-18). Đổi `da_duyet: true` (mỗi file một dòng); `tools/test.sh` trượt đúng như AC 2: `kịch bản đã duyệt danh/da_danh_roi.json: bước 1: lệnh "danh" chưa có luật (Story 2.1)`. Không commit lúc đỏ.
- Đỏ trước: viết `test_forced_move.gd`, `test_rules_attack.gd` trước; `tools/test.sh` báo lỗi script (`Command.attack`, `ForcedMove` chưa có).
- Lần chạy đầu sau khi code: 1 trượt, do test ghi nhầm id (Bộ binh ở hàng trên là 101, Kỵ binh 102); sửa test. Cả 25 kịch bản đạt ngay.
- Phá thử (Task 5.6, trả lại ngay, sau đó 374/374 xanh):
  - bỏ `_undo_snapshot = null` của ATTACK → `huy/danh_xoa_huy.json` và `test_attack_clears_undo` trượt;
  - đẩy trước khi trừ máu → `day/muc_tieu_guc_khong_day.json` (Bộ binh 3,2 còn 2 máu) và 3 test luật trượt;
  - mép bàn không trừ máu → `va_cham/day_vao_mep.json`, `test_edge_in_every_direction`, `test_lethal_attack_is_not_rolled_back` trượt;
  - quân bị va không mất máu → `va_cham/day_vao_quan_khac.json` và 3 test đẩy trượt;
  - bỏ `has_attacked = true` → `danh/da_danh_roi.json` và 4 test luật trượt;
  - cho đánh chéo (Chebyshev) → `danh/khong_danh_duoc.json` và 2 test trượt.
  - Thêm: chỉ bỏ câu `if target.is_alive()` trước `ForcedMove.run` thì **không** test nào trượt, vì `ForcedMove.run` tự dừng khi quân đã gục (lưới an toàn thứ hai). Giữ cả hai; ca "đảo thứ tự" ở trên mới là lỗi thật.
- Phá thử giao diện (Task 7.3): bỏ bước chờ xác nhận → `test_moved_general_needs_confirm_click`, `test_click_elsewhere_cancels_confirm` trượt; cho bấm chọn tướng đã đánh → `test_click_target_attacks_and_general_is_spent` trượt; cho phím 1 chọn tướng đã đánh → cùng test đó trượt.
- GoPeak (`tools/chay.sh --dev --tran=thu_ba_tuong`, bàn ở `(486, 141)`): `select_general_1`, bấm `0,3` (294, 269), `end_turn`; bấm `3,3` (486, 365), `end_turn`; bấm `5,3` (614, 429): Khoái kề Cung kỵ `5,2` và Bộ binh `5,4`, cả hai có viền trắng (ảnh `anh/2-1-vien-muc-tieu.png`). Bấm Bộ binh (550, 461) lần đầu: viền dày, bảng phải hiện "Bấm lần nữa để đánh" (`anh/2-1-cho-xac-nhan.png`). Bấm lần nữa: Bộ binh sang `5,5` còn 1 máu, đồng Khoái xám, bỏ chọn, nút Hủy mờ, dòng nhắc mất (`anh/2-1-sau-khi-danh.png`). Log có `[DEBUG][battle] nhận lệnh: quân 1 đánh ô 5,4`, không có ERROR/WARN.
- Lệch so với Tasks: khóa `scenario.viewer.after_attacked_none` có chữ `chưa tướng nào` (giống `after_moved_none`) để dòng "Sau lệnh" đọc liền ("đã đánh: chưa tướng nào"). Danh sách mã `tu_choi` của lệnh `di` sắp theo thứ tự luật kiểm (`da_danh_roi` trước `da_di_roi`).
  - Task 3.3: Lão, Dư gửi lệnh đánh bị từ chối `NO_TARGET` ngay sau bước "đã đánh" (trước bước kề), không ở cuối bảng: chưa có đòn thì không cần kiểm ô.
  - Task 3.7: `test_runner_stops_at_command_without_rule` đổi thành `test_runner_stops_at_failed_step` (mọi lệnh đã có luật, `PENDING_RULES` rỗng; test vẫn giữ ý "bước trượt thì dừng, không so bàn sau", và kiểm bảng rỗng).
  - Task 5.1, 5.2: hàm dựng bàn thử dùng chung ở `tests/board_fixture.gd` (MỚI, `class_name BoardFixture`), không chép vào hai file test.
  - Task 5.2: test `end_player_turn` xóa `has_attacked` ở `test_rules_attack.gd` (`test_end_turn_clears_attacked`), không ở `test_rules_enemy_phase.gd`: cùng chỗ với các test đòn đánh, dựng bàn bằng `BoardFixture`.
  - Task 5.5: không thêm vào `test_core_types.gd` (file đó không kiểm `Stats`). `Stats.damage`, `push_distance` kiểm ở `test_rules_attack.gd` với chỉ số tự đặt; không đọc `chi_so.json` thật (tác giả được sửa số).
  - Task 7.1: thêm ca "Khoái chưa đi đánh ngay một cú bấm" (`test_unmoved_general_attacks_on_first_click`). Ca "Lão đi, Khoái đánh, Z" bấm qua `_click` (gọi thẳng BattleView), phím Z là phím thật.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Lõi luật: `RulesAttack` (đòn Nguyễn Khoái, `targets`, bảng từ chối "kiểm hết rồi mới sửa"), `ForcedMove.run` (đẩy từng ô; mép bàn, rừng, kho lương, làng, quân khác, sông), `Effects.damage` (trừ máu thật, gục thì nhấc khỏi bàn), `Effects.move` (quân Nguyên vào sông chết đuối). Sự kiện mới `DAMAGED`, `DIED`, `COLLIDED`, `DROWNED`, `ATTACKED`; lệnh `Command.attack`; cờ `has_attacked` (đánh rồi không đi, không đánh; kết thúc lượt xóa).
- `BattleController`: đánh xóa lịch sử hủy; `attack_targets()`; log `quân %d đánh ô c,h`.
- Giao diện: viền trắng quanh mục tiêu (vẽ cùng vòng lặp theo độ sâu), ô chờ xác nhận viền dày, dòng nhắc "Bấm lần nữa để đánh" ở bảng phải; tướng đã đánh đồng xám, tự bỏ chọn, không chọn lại được (chuột và phím).
- Kịch bản: 10 mới (`day/`, `va_cham/`, `danh/`, `huy/danh_xoa_huy.json`), tác giả duyệt cả 10; khóa `sau.da_danh`; mã `da_danh_roi`, `khong_ke`, `khong_co_dich`.
- Test: 3 file mới (`test_forced_move.gd` 13 test, `test_rules_attack.gd` 9 test, `board_fixture.gd` dùng chung), thêm ở `test_battle_view.gd` (7), `test_battle_controller.gd` (4), `test_scenario_loader.gd` (4 mới, 4 sửa), `test_battle_state.gd` (1), `test_board_view.gd` (1). `tools/test.sh`: 374/374, `Kịch bản luật: 25 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- `game-architecture.md`: cây thư mục có `forced_move.gd`; mã `tu_choi` mới, khóa `da_danh`; bảng đẩy ghi thứ tự sự kiện khi va quân, số 1 máu va chạm là hằng số, làng có phần "dừng, mất 1 máu" từ 2.1.
- Mục hoãn đã xử lý: `Stats.value` gõ sai khóa thì `assert`; lệnh đánh "kiểm hết rồi mới sửa" (không cần khôi phục `before`).

**Hướng dẫn tác giả tự test**

1. `tools/test.sh`: thấy `Kịch bản luật: 25 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ 374/374 test đạt`.
2. `tools/chay.sh --dev --tran=thu_ba_tuong`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
3. Gõ `1` chọn Khoái, bấm ô `0,3` (ô trên Khoái 3 ô). Gõ `Space`. Gõ `1`, bấm ô `3,3` (khe giữa sông). Gõ `Space`. Gõ `1`, bấm ô `5,3` (ngay trên Bộ binh dưới, cạnh Cung kỵ).
4. Thấy **viền trắng** quanh Cung kỵ và Bộ binh (hai quân kề Khoái), xem ảnh `_bmad-output/implementation-artifacts/anh/2-1-vien-muc-tieu.png`.
5. Bấm Bộ binh **một lần**: chưa đánh, viền Bộ binh dày lên, bảng phải hiện "Bấm lần nữa để đánh" (vì Khoái đã đi). Bấm **lần nữa**: Bộ binh lùi 1 ô (ra xa Khoái), còn 1 máu; đồng Khoái chuyển **xám**; nút Hủy mờ.
6. Bấm Khoái hoặc gõ `1`: không chọn được. Gõ `Z`: không có gì xảy ra.
7. Gõ `Space`: Khoái hết xám. Gõ `1`, bấm Cung kỵ ở ô trên Khoái **một lần**: Khoái chưa đi trong lượt này nên đánh ngay, Cung kỵ (1 máu) gục, biến khỏi bàn, không bị đẩy.
8. Muốn thử va chạm: đẩy một Bộ binh vào rừng, kho lương, quân khác hoặc mép bàn; Bộ binh mất thêm 1 máu và gục (biến khỏi bàn). Kịch bản `tools/xem_kich_ban.sh --tat_ca` có đủ các ca này.

### File List

- `game/src/core/battle_event.gd` (sửa)
- `game/src/core/command.gd` (sửa)
- `game/src/core/effects.gd` (sửa)
- `game/src/core/forced_move.gd` (mới), `game/src/core/forced_move.gd.uid` (mới)
- `game/src/core/rules_attack.gd` (mới), `game/src/core/rules_attack.gd.uid` (mới)
- `game/src/core/grid.gd` (sửa)
- `game/src/core/rules.gd` (sửa)
- `game/src/core/rules_move.gd` (sửa)
- `game/src/core/rules_enemy_phase.gd` (sửa)
- `game/src/core/stats.gd` (sửa)
- `game/src/core/unit.gd` (sửa)
- `game/src/core/battle_state.gd` (sửa)
- `game/src/data/scenario_loader.gd` (sửa)
- `game/src/data/scenario_data.gd` (sửa)
- `game/src/battle/battle_controller.gd` (sửa)
- `game/src/battle/battle_view.gd` (sửa)
- `game/src/battle/board_view.gd` (sửa)
- `game/src/battle/unit_token.gd` (sửa)
- `game/src/ui/hud.gd` (sửa)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation` (sửa)
- `game/tests/kich_ban/day/danh_day_1_o.json`, `day/muc_tieu_guc_khong_day.json` (mới)
- `game/tests/kich_ban/va_cham/day_vao_mep.json`, `day_vao_rung.json`, `day_vao_kho_luong.json`, `day_vao_quan_khac.json` (mới)
- `game/tests/kich_ban/danh/di_roi_danh.json`, `da_danh_roi.json`, `khong_danh_duoc.json` (mới)
- `game/tests/kich_ban/huy/danh_xoa_huy.json` (mới)
- `game/tests/scenario_runner.gd`, `game/tests/scenario_viewer.gd` (sửa)
- `game/tests/board_fixture.gd` (mới), `.uid` (mới)
- `game/tests/test_forced_move.gd` (mới), `.uid` (mới)
- `game/tests/test_rules_attack.gd` (mới), `.uid` (mới)
- `game/tests/test_scenario_loader.gd`, `test_battle_controller.gd`, `test_battle_state.gd`, `test_battle_view.gd`, `test_board_view.gd` (sửa)
- `_bmad-output/planning-artifacts/game-architecture.md` (sửa)
- `_bmad-output/implementation-artifacts/anh/2-1-vien-muc-tieu.png`, `2-1-cho-xac-nhan.png`, `2-1-sau-khi-danh.png` (mới)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa)
- `_bmad-output/implementation-artifacts/2-1-nguyen-khoai-danh-day-va-va-cham.md` (sửa)

### Change Log

- 2026-10-18: Tạo story. Tác giả chốt: viền trắng, đồng đã đánh xám; xác nhận bằng viền dày và dòng chữ; số 1 máu va chạm để trong code; làng như rừng (Lòng dân ở 3.7).
- 2026-10-18: Đợt kịch bản 3 (10 kịch bản), tác giả duyệt cả 10.
- 2026-10-18: Làm story: đòn Nguyễn Khoái, đẩy và va chạm (`ForcedMove`), gục, đánh xóa hủy, viền mục tiêu, xác nhận khi đã đi, đồng đã đánh; 39 test mới, 4 test sửa; `tools/test.sh` 374/374, kịch bản 25/25.
- 2026-10-18: Sửa theo code review: ô kề ngoài bàn báo `NOT_ADJACENT`; `sat_thuong` tối thiểu 1 (bộ nạp) và `Effects.damage` assert `amount > 0`; `Grid.dir_between` assert ô kề; test thêm Dư, so `has_attacked` khi hủy, gợi ý xác nhận qua `tr()`; bảng thứ tự kiểm khớp code (tác giả chốt). 2 test mới, 4 test sửa; `tools/test.sh` 376/376, kịch bản 25/25. Phá thử: bỏ kiểm `in_bounds` thì ca ngoài bàn trượt.
