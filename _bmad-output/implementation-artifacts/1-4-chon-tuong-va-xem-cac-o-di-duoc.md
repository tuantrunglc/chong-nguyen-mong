---
baseline_commit: 22d7228
---

# Story 1.4: Chọn tướng và xem các ô đi được

Status: done

## Story

Là người chơi,
tôi muốn chọn một tướng và thấy ngay nó đi được tới đâu,
để tính nước đi.

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code (M3).** **Cho** 8 kịch bản `di_chuyen/` ở Dev Notes "Đợt kịch bản 1", gồm kịch bản mẫu `di_thang_3_o.json` có sẵn từ Story 1.3, mọi file `da_duyet: false`. **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 0 đã duyệt · 8 chưa duyệt (8 chưa đạt)`;
   - mỗi kịch bản có lý do `bước 1: lệnh "di" chưa có luật (Story 1.4)`.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh`. Chưa duyệt xong thì không viết dòng code luật nào.
2. **Khi** tác giả duyệt (đổi `da_duyet` thành `true`, hoặc nhắn AI "đúng" để AI đổi), **thì** `tools/test.sh` **trượt**, vì kịch bản đã duyệt chưa đạt. Kịch bản bị tác giả nói "sai" thì AI sửa kịch bản theo lý do tác giả đưa và cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 8 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh `di`, `BattleState.validate()` rỗng (bộ chạy đã kiểm).
4. **Cho** trận 1 đang mở (`tools/chay.sh`). **Khi** bấm vào Nguyễn Khoái (ô `0,6`) hoặc gõ phím `1`, **thì**:
   - Nguyễn Khoái có dấu hiệu "đang chọn";
   - đúng **7 ô** sáng lên: `0,3` `0,4` `1,4` `0,5` `1,5` `2,5` `1,6` (FR5, FR6).

   Ô `2,6` (Phạm Ngũ Lão) không sáng: đi xuyên qua được nhưng không dừng ở đó. Các ô sông, ô quân Nguyên và ô cách hơn 3 bước cũng không sáng (FR7).
5. **Khi** gõ phím `2` (hoặc bấm vào Phạm Ngũ Lão), **thì** đổi sang Phạm Ngũ Lão: dấu "đang chọn" chuyển sang Lão, và đúng 7 ô sáng: `2,3` `1,4` `2,4` `0,5` `1,5` `2,5` `1,6`. Ô `0,6` (Nguyễn Khoái) không sáng.
6. **Khi** gõ phím `3` ở trận 1 (không có Trần Khánh Dư), **thì** không có gì thay đổi: tướng đang chọn vẫn giữ, game không lỗi. Mở `tools/chay.sh --dev --tran=thu_ba_tuong` rồi gõ `3` thì chọn được Trần Khánh Dư.
7. **Khi** đang chọn Nguyễn Khoái mà rê chuột lên ô sáng `2,5`, **thì** game vẽ đường đi theo từng ô: `0,6` → `0,5` → `1,5` → `2,5`. Rê sang ô không sáng thì đường đi biến mất. Đường đi chọn theo luật ở Dev Notes "Chọn đường" (ngắn nhất, hòa thì B→Đ→N→T).
8. **Bỏ chọn** **[Tác giả chốt 2026-10-18]**:
   - bấm lại vào tướng đang chọn (hoặc gõ lại phím của nó) thì bỏ chọn, ô sáng tắt;
   - bấm vào ô không sáng mà không có tướng mình thì cũng bỏ chọn;
   - bấm vào ô sáng thì chưa làm gì (đi là việc của Story 1.5).
9. Màn hình lỗi và bàn trống (menu tạm) không phản ứng với chuột hay phím `1` `2` `3`. Mở lại trận (sau này là F5 ở Story 1.6) thì bỏ chọn.

## Tasks / Subtasks

- [x] **Task 1: Viết đợt kịch bản 1 và dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Viết 7 file mới trong `game/tests/kich_ban/di_chuyen/` đúng như Dev Notes "Đợt kịch bản 1" (bàn cờ, lệnh, `mo_ta`), `"da_duyet": false`. Giữ nguyên `di_thang_3_o.json` (không đổi gì).
  - [x] 1.2 Chạy `tools/xem_kich_ban.sh di_chuyen`: đọc lại từng bàn trước/sau, xem có khớp `mo_ta` không. Chạy `tools/test.sh`: xanh, `8 chưa duyệt (8 chưa đạt)`.
  - [x] 1.3 Commit: `Kịch bản di_chuyen đợt 1 chờ duyệt (Story 1.4)`.
  - [x] 1.4 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh`, đọc 8 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái (hoặc tự đổi `da_duyet`). Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.5 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản được nói "đúng" (chỉ đổi đúng khóa đó). Kịch bản bị nói "sai" thì sửa theo lý do, cho duyệt lại (lặp 1.2–1.5). Chạy `tools/test.sh`: **phải trượt** (AC 2). Ghi vào Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật: lưới, lệnh, sự kiện, Effects** (AC: 3)
  - [x] 2.1 `src/core/grid.gd` (`class_name Grid`): `const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]` theo thứ tự **B→Đ→N→T**, kèm chú thích. Chỉ thêm thứ story này dùng.
  - [x] 2.2 `src/core/command.gd` (`class_name Command`): `enum Kind { MOVE }` (thêm `ATTACK`, `END_TURN`… ở story của nó); `kind`, `unit_id: int`, `cell: Vector2i`; hàm tạo `static func move(unit_id: int, cell: Vector2i) -> Command`.
  - [x] 2.3 `src/core/battle_event.gd` (`class_name BattleEvent`): `enum Type { MOVED, REJECTED }`, `enum Cause { WALK }`; trường `type`, `unit_id`, `from_cell`, `to_cell`, `cause`, `reason: String`. Hàm tạo `moved(...)`, `rejected(reason)`.
  - [x] 2.4 `src/core/effects.gd` (`class_name Effects`): `static func move(state: BattleState, unit: Unit, to_cell: Vector2i, cause: BattleEvent.Cause, events: Array[BattleEvent]) -> void`. Gán `unit.cell = to_cell` (**chỗ duy nhất** trong `src/` được gán `.cell`; `check_boundaries.sh` đã miễn đúng file này), rồi `events.append(BattleEvent.moved(...))`. Chú thích: hiệu ứng ô (hầm chông) thêm ở Story 3.4.
  - [x] 2.5 Sửa chú thích đầu `src/core/unit.gd`: chỉ `Effects` được đổi `cell`/`hp` sau `_init`.
- [x] **Task 3: Tìm đường và luật đi** (AC: 3, 4, 5, 7)
  - [x] 3.1 `src/core/pathfinding.gd` (`class_name Pathfinding`): BFS tự viết, đúng như Dev Notes "Tìm đường". Hàm `static func find_paths(state: BattleState, unit: Unit, max_steps: int) -> Dictionary`, trả `ô đích -> Array[Vector2i]` (đường đi, không gồm ô xuất phát, gồm ô đích). Chỉ trả ô **dừng được**. **Không** dùng `AStarGrid2D` (cấm).
  - [x] 3.2 `src/core/rules_move.gd` (`class_name RulesMove`):
    - `reachable(state, unit) -> Array[Vector2i]`: các ô dừng được, sắp theo thứ tự đọc bàn (hàng rồi cột). Không duyệt theo khóa Dictionary khi thứ tự có nghĩa.
    - `path_to(state, unit, cell) -> Array[Vector2i]`: rỗng nếu không tới được.
    - `resolve(state, command, events)`: kiểm hợp lệ (Dev Notes "Lệnh đi"); sai thì `events.append(BattleEvent.rejected(lý do))`, **không đổi state**; đúng thì gọi `Effects.move` cho **từng ô** trên đường.
    - Tầm đi lấy từ `state.stats.move_range(unit.type)`, không viết số 3 trong code.
  - [x] 3.3 `src/core/rules.gd` (`class_name Rules`): `static func resolve(state: BattleState, command: Command) -> Array[BattleEvent]`, là **điểm vào duy nhất**. `match command.kind`: `MOVE` → `RulesMove.resolve`.
- [x] **Task 4: Bộ chạy kịch bản chạy lệnh `di`** (AC: 2, 3)
  - [x] 4.1 `game/tests/scenario_runner.gd`: bỏ `"di"` khỏi `PENDING_RULES`. Trong `_run_step`, lệnh `di`: tìm tướng theo loại (`step.general`) trong state. Không có thì trả `'tướng "<ký hiệu>" không còn trên bàn'`. Có thì `Rules.resolve(state, Command.move(id, step.cell))`.
  - [x] 4.2 Lệnh bị từ chối (`REJECTED`) **không phải lỗi của bước**: bộ chạy đi tiếp, bàn sau sẽ so như thường. Kịch bản "không đi được" kiểm bằng bàn sau giống bàn trước.
  - [x] 4.3 Sửa `test_runner_stops_at_command_without_rule` (đang dùng `di` làm lệnh chưa có luật) sang dùng `huy` (Story 1.5). Thêm test bộ chạy: đi được (bàn đổi), bị từ chối (bàn giữ nguyên, `passed`), tướng không có trên bàn.
- [x] **Task 5: Test lõi luật** (AC: 3)
  - [x] 5.1 `game/tests/test_rules_move.gd`, dùng `Stats` tự đặt như `test_scenario_loader.gd` (không phụ thuộc `chi_so.json`). Mỗi ca kiểm `state.validate()` rỗng sau khi phân giải. Các ca:
    - tướng giữa bàn trống tới được 24 ô (25 ô kim cương, trừ ô đang đứng);
    - đổi `tam_di` thành 2 thì chỉ còn 12 ô;
    - tướng ở góc: không có ô nào ngoài bàn, không đọc nhầm sang hàng khác (mục hoãn `terrain_at` ở `deferred-work.md`);
    - đi xuyên quân mình nhưng không dừng trên đó; quân Nguyên chặn; sông, rừng, kho lương, làng chặn; hầm chông và ô ải đi vào được;
    - đường đi theo B→Đ→N→T: từ `3,3` tới `4,2` là `[3,2, 4,2]` (lên trước rồi sang phải);
    - `resolve` đi được: sự kiện `MOVED` theo từng ô, đúng thứ tự, ô cuối là ô đích;
    - `resolve` bị từ chối (ngoài tầm, ô có quân, ô bị chặn, ô đang đứng, id không có, quân Nguyên): đúng một sự kiện `REJECTED`, state giống hệt trước (so từng quân);
    - kết quả tất định: gọi hai lần ra cùng danh sách.
  - [x] 5.2 Kiểm test bắt lỗi thật (như Story 1.3): tạm bỏ luật "quân Nguyên chặn" thì phải có test và kịch bản trượt. Trả lại, ghi Debug Log.
- [x] **Task 6: BattleController hỏi ô đi được** (AC: 4, 5, 7)
  - [x] 6.1 `src/battle/battle_controller.gd`: thêm `reachable(unit_id: int) -> Array[Vector2i]` và `path_to(unit_id: int, cell: Vector2i) -> Array[Vector2i]`. Chỉ đọc state đang sống, trả mảng mới. Id không có thì trả `[]`. **Chưa** có `submit()` (Story 1.5).
- [x] **Task 7: Input và chọn tướng** (AC: 4–9)
  - [x] 7.1 `src/battle/battle_input.gd` (`class_name BattleInput extends Node`):
    - Đăng ký 3 action `select_general_1..3` vào InputMap bằng code trong `_ready` (phím vật lý `KEY_1`..`KEY_3`; đã có thì bỏ qua), như `DevTools`. Không bắt phím trực tiếp.
    - `_unhandled_input`: action → `general_key_pressed(index: int)`; chuột trái nhấn → `cell_clicked(cell)`; chuột di → `cell_hovered(cell)`, **chỉ phát khi ô đổi**.
    - Ô lấy qua `BoardView.cell_at(...)`. Ngoài bàn thì là `BoardView.NO_CELL`.
  - [x] 7.2 `src/battle/battle_view.gd` (`class_name BattleView extends Node`): giữ tướng đang chọn (id, 0 = không chọn) và tham chiếu `BattleController`.
    - `start(controller)` / `stop()`.
    - Nhận signal của `BattleInput`, theo bảng ở Dev Notes "Chọn và bỏ chọn".
    - Gọi `BoardView.show_selection(...)` và `show_path(...)`.
    - Đọc bản chụp (`controller.snapshot()`), không bao giờ sửa state.
  - [x] 7.3 `src/battle/board_view.gd`:
    - `const NO_CELL`, `cell_at(local_pos: Vector2) -> Vector2i`;
    - `show_selection(unit_cell: Vector2i, cells: Array[Vector2i])`, `show_path(path: Array[Vector2i])`, `clear_selection()`;
    - vẽ trong `_draw`, theo Dev Notes "Hiển thị";
    - `show_state(null)` thì xóa luôn ô sáng và đường đi.
  - [x] 7.4 `src/app/main.gd`: tạo `BattleInput` và `BattleView` một lần trong `_ready`. `_start_battle` thành công thì gọi `start(_controller)`. `_show_error` và `_show_menu` gọi `stop()`. Giữ mọi hành vi cũ (`test_main.gd` phải xanh nguyên).
- [x] **Task 8: Test chọn tướng** (AC: 4–9)
  - [x] 8.1 `game/tests/test_battle_view.gd`, theo mẫu `test_main.gd` (dựng `main.tscn`, trận 1 thật). Gọi thẳng hàm xử lý của `BattleView`, hoặc phát `InputEventAction`.
    - Phím 1: 7 ô sáng đúng như AC 4. Phím 2: đúng như AC 5. Phím 3 ở trận 1: không đổi.
    - Bấm lại tướng đang chọn: bỏ chọn. Bấm ô không sáng: bỏ chọn. Rê ô `2,5`: đường đi như AC 7.
    - Màn hình lỗi: phím 1 không làm gì.
  - [x] 8.2 `after_each` xóa 3 action `select_general_*` khỏi InputMap (như cách `test_main.gd` dọn `dev_f*`).
- [x] **Task 9: Kiểm bằng mắt, kiểm khóa, commit** (AC: 3–9)
  - [x] 9.1 Chạy `tools/chay.sh --dev` ở chế độ nền, chờ ~5 giây, bơm phím `1` (`inject_key`), chụp màn hình bằng GoPeak (`capture_screenshot`). Xem ô sáng và vòng chọn có rõ không, có lẫn với màu sông không. Rê/bấm thử bằng `inject_mouse_click` (tọa độ pixel cửa sổ 1280×720: tâm ô = vị trí bàn + `cell_center`). Tắt game. Ghi Debug Log.
  - [x] 9.2 Thử khóa `da_duyet` trên **bản clone tạm** (mục hoãn của Story 0.2 ở `deferred-work.md`): sửa một kịch bản đã duyệt thì `test.sh` phải trượt, ghi rõ tên file. Ghi cách làm và kết quả vào Debug Log. Tự kiểm tự động vẫn để hoãn.
  - [x] 9.3 `tools/test.sh` xanh (AC 3). Commit một lần, gồm kịch bản đã duyệt, code, test và `.uid` mới. Lời commit tiếng Việt, ví dụ `Luật đi và chọn tướng, kịch bản di_chuyen/01–08 (Story 1.4)`.
  - [x] 9.4 Ghi hướng dẫn tác giả tự test vào Completion Notes, theo mẫu ở mục Testing, dùng kết quả thật.

### Review Findings

- [x] [Review][Decision] Bộ chạy kịch bản bỏ qua lý do bị từ chối — tác giả chốt 2026-10-18: thêm khóa `"tu_choi": "<mã>"` vào lệnh của `hanh_dong`; **bắt buộc** (lệnh bị từ chối mà không ghi, hoặc ghi mà không bị từ chối, là trượt); mã ngắn `khong_co_quan`, `khong_phai_tuong`, `da_dung_o_do`, `khong_toi_duoc`. Thành Patch bên dưới.
- [x] [Review][Decision] Mô tả kịch bản 7 sai số bước — tác giả chốt 2026-10-18 câu mới: "Rừng, kho lương, làng chặn ba phía; lối ra duy nhất là phía tây. Tới 3,1 và 3,5 mất 4 bước, tới 5,3 mất 8 bước, đều quá tầm 3, nên Nguyễn Khoái đứng yên."
- [x] [Review][Patch] Đợt duyệt lại (bước 1): bộ nạp đọc `tu_choi`, công cụ duyệt hiện lý do, 6 kịch bản "đứng yên" thêm `"tu_choi": "khong_toi_duoc"` và đặt `da_duyet: false`, sửa `mo_ta` kịch bản 7, cập nhật `game-architecture.md` và `project-context.md`. Chờ tác giả duyệt lại.
- [x] [Review][Patch] Bộ chạy kiểm `tu_choi` (bước 2, sau khi tác giả duyệt): `BattleEvent` mang mã lý do; lệnh bị từ chối phải khớp mã kịch bản ghi, không ghi thì trượt, ghi mà chạy được cũng trượt [game/tests/scenario_runner.gd:82]
- [x] [Review][Patch] Chọn tướng khi chuột đang nằm sẵn trên ô sáng thì không vẽ đường đi, tới khi rê sang ô khác (cả khi đổi 1→2 trên ô sáng chung) [game/src/battle/battle_view.gd:77]
- [x] [Review][Patch] Đường đi còn trên màn hình khi chuột ra khỏi cửa sổ; quay lại đúng ô cũ cũng không vẽ lại [game/src/battle/battle_input.gd:40]
- [x] [Review][Patch] Phím 1-2-3 không kiểm phe như khi bấm chuột (giờ an toàn nhờ id quân Nguyên từ 101) [game/src/battle/battle_view.gd:50]
- [x] [Review][Patch] Kiểm "không phải tướng" theo phe, không theo loại quân như spec (`UnitType.is_general`) [game/src/core/rules_move.gd:33]
- [x] [Review][Patch] `test_blocked_by_terrain_is_rejected` thiếu kiểm `state.validate()` rỗng (Task 5.1) [game/tests/test_rules_move.gd:204]
- [x] [Review][Patch] Chưa có test gửi phím thật (`InputEventKey` với `physical_keycode = KEY_1`); test chỉ gửi action nên gán sai phím ↔ action không bị bắt [game/tests/test_battle_view.gd:67]
- [x] [Review][Patch] Màn menu chưa test bấm chuột (AC 9), chỉ test phím 1 [game/tests/test_battle_view.gd]
- [x] [Review][Defer] `BattleView._cells` tính một lần lúc chọn, không làm mới khi trận đổi [game/src/battle/battle_view.gd:79] — deferred, chưa gặp được; cần xử lý khi Story 1.5 cho tướng đi thật
- [x] [Review][Defer] `BattleView` và `BattleInput` là anh em dưới `main` thay vì con của `BattleView` như kiến trúc vẽ [game/src/app/main.gd:46] — deferred, đúng Task 7.4; dọn khi E2 thêm view
- [x] [Review][Defer] `BoardView.show_state(null)` tự xóa vòng chọn, còn `BattleView._selected` chỉ xóa khi gọi `stop()` [game/src/battle/board_view.gd:131] — deferred, `main.gd` luôn gọi `stop()` trước nên chưa gặp được

## Dev Notes

### Bối cảnh

- Đây là **story luật đầu tiên**. Quy trình M3 lần đầu chạy thật: AI viết kịch bản → tác giả duyệt → kịch bản trượt → viết code tới khi xanh. Đường ống (bộ nạp, bộ chạy, công cụ duyệt, dòng tóm tắt trong `test.sh`) đã có từ Story 1.3, kèm các sửa theo code review (commit `22d7228`).
- Story này dựng **lõi luật lần đầu**: `Rules.resolve`, `Command`, `BattleEvent`, `Effects`, `Pathfinding`, `Grid`. Các story E2 sẽ xây tiếp lên đúng các file này. Cứ làm gọn, nhưng **đúng hợp đồng kiến trúc** (một điểm vào, sự kiện dạng enum, chỉ `Effects` sửa vị trí).
- Phạm vi của lệnh `di` ở story này: kiểm hợp lệ và dời tướng. **Chưa có:** cờ "đã đi" (không đi tiếp được), bấm ô sáng để đi, hủy, kết thúc lượt. Những thứ đó là Story 1.5.
- Tác giả không đọc code. Thứ tác giả nhìn là đầu ra của `tools/xem_kich_ban.sh`, `tools/test.sh` và game chạy bằng `tools/chay.sh`.

### Luật đi (spec) **[GDD, FR5–FR7]**

- 4 hướng, không đi chéo. Tầm đi tính bằng **số bước** thật (đường vòng tính đủ bước), không phải khoảng cách đường chim bay.
- Tầm đi lấy từ `chi_so.json` (`tam_di`, tướng là 3).
- **Đi qua được:** ô trong bàn, địa hình đi vào được (`Terrain.is_walkable`: đất trống `.`, hầm chông `^`, ô ải `A`), không có quân **khác phe**.
- **Dừng được:** ô đi qua được và **không có quân nào** (kể cả quân mình).
- **Chặn:** mép bàn; sông `~`, rừng `#`, kho lương `L`, làng `D`; ô có quân Nguyên.
- Hầm chông: đi vào được. **Mất máu khi đi qua là Story 3.4**, và chọn đường ít hầm chông nhất (FR8) là E3. Story này không viết kịch bản nào có hầm chông.
- Chỉ **tướng** nhận lệnh đi từ người chơi. Quân Nguyên đi bằng AI ở E2 (dùng lại `Pathfinding` với phe của nó).

### Tìm đường (`Pathfinding.find_paths`)

BFS tự viết, tất định:
1. Hàng đợi bắt đầu từ ô của quân, độ sâu 0.
2. Lấy ô đầu hàng. Nếu độ sâu < `max_steps`, xét 4 ô kề **theo thứ tự `Grid.DIRECTIONS` (B, Đ, N, T)**.
3. Ô kề được nhận nếu: `state.in_bounds(ô)` **trước** rồi mới `state.terrain_at(ô)` (hàm này không tự kiểm biên); địa hình đi vào được; không có quân khác phe; chưa thăm.
4. Ô nhận lần đầu thì ghi ô cha, độ sâu + 1, cho vào cuối hàng đợi. Ô có quân cùng phe vẫn được thăm và mở rộng tiếp (đi xuyên), nhưng **không** là ô đích.
5. Kết quả: mỗi ô thăm được, khác ô xuất phát, không có quân → đường đi dựng ngược từ ô cha.

Vì BFS mở rộng theo B→Đ→N→T và giữ ô cha đầu tiên, đường đi chọn ra là đường ngắn nhất, hòa thì ưu tiên hướng B trước, rồi Đ, N, T, theo thứ tự đi trên đường. Ví dụ: từ `3,3` tới `4,2` là `3,2` → `4,2`, không phải `4,3` → `4,2`.

Ở E3 (FR8), "ít hầm chông nhất" sẽ thay cách chọn đường. Tập ô đi tới được **không đổi** (vẫn ≤ tầm đi).

### Lệnh đi (`RulesMove.resolve`)

Kiểm theo thứ tự, gặp sai đầu tiên thì từ chối (một sự kiện `REJECTED`, state không đổi). Lý do là câu cho dev và log, **không** qua `tr()`:

| Kiểm | Lý do |
|---|---|
| Không có quân id đó | `không có quân %d` |
| Quân không phải tướng | `quân %d không phải tướng` |
| Ô đích là ô đang đứng | `quân %d đã đứng ở ô c,h` |
| Ô đích không nằm trong `find_paths` | `quân %d không đi tới được ô c,h` |

Hợp lệ thì đi **từng ô** theo đường: mỗi ô một lần `Effects.move(state, unit, ô, BattleEvent.Cause.WALK, events)`. Lúc đi xuyên qua ô quân mình, tướng tạm đứng chung ô. Chỉ chạy `validate()` sau khi cả lệnh xong (bộ chạy và sau này `BattleController` làm việc đó), nên không sao. Ghi chú này vào code.

`Rules.resolve` là điểm vào duy nhất cho mọi chỗ (bộ chạy, sau này `BattleController.submit`). UI chỉ hỏi `BattleController.reachable` / `path_to`, các hàm này gọi `RulesMove.reachable` / `path_to` trên state đang sống, không sửa gì.

### Đợt kịch bản 1 (`game/tests/kich_ban/di_chuyen/`)

Quy ước chung:
- `phien_ban_dinh_dang: 1`, `da_duyet: false`.
- `sau.dia_hinh` chép y `truoc.dia_hinh`. Không ghi `mau` (mọi quân đầy máu), trừ khi nói rõ.
- Địa hình mặc định là đất trống. Bàn ghi dưới đây theo hàng 0 → 6. Ô `.` trong `dia_hinh` là đất trống, trong `quan` là không có quân.
- Bàn 7 dòng × 7 ô, mỗi ô cách nhau một dấu cách (như file trận).
- Kịch bản bị từ chối: `sau.quan` **giống hệt** `truoc.quan`.

| # | File | `mo_ta` | Bàn trước | Lệnh | Bàn sau |
|---|---|---|---|---|---|
| 1 | `di_thang_3_o.json` | (có sẵn, giữ nguyên) | (có sẵn) | `di 1 → 3,6` | (có sẵn) |
| 2 | `qua_tam_di.json` | `Nguyễn Khoái muốn đi 4 ô, quá tầm đi 3, nên đứng yên.` | `quan` hàng 6: `1 . . . . . .`; còn lại trống | `di 1 → 4,6` | giống trước |
| 3 | `di_xuyen_quan_minh.json` | `Nguyễn Khoái đi xuyên qua ô của Phạm Ngũ Lão, tới ô thứ 3.` | `quan` hàng 6: `1 2 . . . . .` | `di 1 → 3,6` | hàng 6: `. 2 . 1 . . .` |
| 4 | `khong_dung_tren_quan_minh.json` | `Nguyễn Khoái không dừng được trên ô của Phạm Ngũ Lão, nên đứng yên.` | `quan` hàng 6: `1 2 . . . . .` | `di 1 → 1,6` | giống trước |
| 5 | `quan_nguyen_chan_duong.json` | `Bộ binh chặn đường. Đi vòng lên hàng trên phải mất 4 bước, quá tầm 3, nên Nguyễn Khoái đứng yên.` | `quan` hàng 6: `1 B . . . . .` | `di 1 → 2,6` | giống trước |
| 6 | `song_chan_duong.json` | `Sông chặn đường. Đi vòng lên hàng trên phải mất 4 bước, quá tầm 3, nên Nguyễn Khoái đứng yên.` | `dia_hinh` hàng 6: `. ~ . . . . .`; `quan` hàng 6: `1 . . . . . .` | `di 1 → 2,6` | giống trước |
| 7 | `rung_kho_lang_chan_duong.json` | `Rừng, kho lương, làng chặn đường: đi vòng phải mất 4 bước nên ba lệnh đều không đi được, Nguyễn Khoái đứng yên.` | `dia_hinh`: `3,2` là `#`, `4,3` là `L`, `3,4` là `D`, còn lại `.`; `quan`: `1` ở `3,3` | `di 1 → 3,1`; `di 1 → 5,3`; `di 1 → 3,5` | giống trước |
| 8 | `ket_o_goc.json` | `Nguyễn Khoái ở góc bàn, sông chặn hai phía, không đi đâu được.` | `dia_hinh` hàng 0: `. ~ . . . . .`, hàng 1: `~ . . . . . .`; `quan` hàng 0: `1 . . . . . .` | `di 1 → 0,2` | giống trước |

Kiểm lại từng kịch bản trước khi đưa tác giả:
- Kịch bản 5: đường vòng `0,6` → `0,5` → `1,5` → `2,5` → `2,6` là 4 bước. Vậy chặn là do Bộ binh, không phải do hết đường.
- Kịch bản 7: ba ô đích đều cách `3,3` hai bước nếu đi thẳng, nhưng ba ô kề phía bắc, đông, nam của `3,3` là rừng, kho lương, làng. Lối ra duy nhất là `2,3`, nên đường ngắn nhất tới `3,1` là 4 bước (`2,3` → `2,2` → `2,1` → `3,1`), tới `3,5` là 4 bước, tới `5,3` là 8 bước.
- Kịch bản 8: `0,0` chỉ có hai ô kề `1,0` (sông) và `0,1` (sông).

Số bước trên đã kiểm bằng BFS lúc tạo story. Dev kiểm lại bằng `tools/xem_kich_ban.sh` và ghi vào Debug Log. Thấy một kịch bản không thử đúng điều `mo_ta` nói thì sửa trước khi đưa tác giả.

Không viết thêm kịch bản ngoài 8 cái này. Ca chưa có trong đợt (ví dụ hầm chông, đi hai lần) để story của nó.

### Chọn và bỏ chọn (`BattleView`) **[Tác giả chốt 2026-10-18]**

| Thao tác | Đang không chọn ai | Đang chọn tướng X |
|---|---|---|
| Phím `n` / bấm tướng `n` có trên bàn, `n` ≠ X | Chọn `n` | Đổi sang `n` |
| Phím / bấm lại tướng X | (không áp dụng) | Bỏ chọn |
| Phím `n` mà tướng `n` không có trên bàn | Không gì | Không gì (giữ X) |
| Bấm ô sáng | (không áp dụng) | Không gì (đi: Story 1.5) |
| Bấm ô khác: trống, quân Nguyên, địa hình chặn, ngoài bàn | Không gì | Bỏ chọn |
| Rê lên ô sáng | Không gì | Vẽ đường đi tới ô đó |
| Rê lên ô khác | Không gì | Xóa đường đi |

- Tướng `n` có id `n` (luật id của `BattleState.from_level`). Tra bằng `snapshot.unit_by_id(n)`.
- Bấm vào tướng mình **luôn là chọn** (GDD, chốt 2026-10-17). Sau này E2 thêm đánh thì cũng không đổi điều này.
- Không có `BattleController` (màn hình lỗi, menu) thì mọi thao tác không làm gì.

### Hiển thị (`BoardView`)

- Ô sáng: phủ một lớp màu **nhạt, khác hẳn đỏ** (màu đỏ dành cho ô báo đòn ở E2, NFR9) và khác màu sông. Gợi ý: xanh lá nhạt, có độ trong suốt, vẽ sau màu địa hình và trước đường kẻ ô.
- Tướng đang chọn: vòng tròn màu nổi (gợi ý vàng đậm), bán kính lớn hơn đồng quân một chút. Vẽ trong `_draw` của `BoardView`, nằm dưới đồng quân, nên chỉ lộ phần viền ngoài.
- Đường đi: đường kẻ dày nối tâm các ô, từ ô tướng tới ô đích, có chấm tròn ở ô đích. Vẽ trong `_draw`, dưới đồng quân.
- Màu là màu UI, để `const` trong `board_view.gd` như `TERRAIN_COLORS`. Không phải số cân bằng.
- Mọi thứ vẽ bằng code, không sửa `.tscn` (scene nhỏ và phẳng).
- `cell_at(local_pos)`: `Vector2i(floor(x / CELL_SIZE), floor(y / CELL_SIZE))`, ngoài `[0, cols) × [0, rows)` thì `NO_CELL = Vector2i(-1, -1)`. Lấy vị trí chuột bằng `board_view.get_local_mouse_position()`, đúng cả khi cửa sổ co giãn (`canvas_items`).

### File sẽ sửa (đọc trước khi sửa)

| File | Hôm nay | Story này đổi | Phải giữ |
|---|---|---|---|
| `game/src/battle/battle_controller.gd` | `start`, `snapshot` | Thêm `reachable`, `path_to` | `start` kiểm `validate()` và ghi log; `snapshot()` trả bản sao |
| `game/src/battle/board_view.gd` | Vẽ ô, chữ địa hình, đồng quân theo id; `show_state(null)` về bàn trống | Thêm `cell_at`, ô sáng, vòng chọn, đường đi | Thứ tự con (chữ địa hình, đồng quân, overlay F1 cuối cùng); `_sync_tokens` |
| `game/src/app/main.gd` | Nạp dữ liệu, dựng bàn, màn hình lỗi, F1 | Tạo `BattleInput` + `BattleView`, gọi `start`/`stop` | Mọi test trong `test_main.gd`; F1 chỉ khi đang có trận |
| `game/src/core/unit.gd` | Chú thích "chỉ gán trong `_init`" | Chú thích: trừ `Effects` | Thuộc tính, `_init` |
| `game/tests/scenario_runner.gd` | `di` chưa có luật | Chạy `di` qua `Rules.resolve` | Câu so sánh, `PENDING_RULES` của `huy`, `ket_thuc_luot`, `danh` |
| `game/tests/test_scenario_loader.gd` | `test_runner_stops_at_command_without_rule` dùng `di` | Đổi sang `huy` | Các test khác |

**Không** đổi: định dạng kịch bản, bộ nạp, công cụ duyệt, `tools/test.sh`, file trận, `chi_so.json`.

### Luật kiến trúc phải theo

- `src/core/` chỉ `extends RefCounted`; không Node, `Input`, `FileAccess`, `Time`, ngẫu nhiên, `print`, `Log`. `check_boundaries.sh` quét.
- Chỉ `effects.gd` được gán `.cell` / `.hp` (quét toàn `src/`). Regex bắt **mọi** dạng `x.cell = …`, kể cả trên `Command`. Vì vậy `Command` và `BattleEvent` gán trường trong `_init(p_cell…)` (`cell = p_cell`, không có dấu chấm), và hàm tạo `static func move(...)` gọi `Command.new(...)`. Tên trường khác (`to_cell`, `from_cell`) không bị bắt.
- `BattleInput` dùng `_unhandled_input`, nên nút "Về menu" của màn hình lỗi (Control) nhận bấm trước. Không dùng `_input`.
- `Rules.resolve` là điểm vào duy nhất. Luật đi nằm ở `rules_move.gd`, BFS ở `pathfinding.gd`.
- Sự kiện dùng enum (`BattleEvent.Type.MOVED`), không dùng chuỗi tự do.
- Lõi không ghi log trong vòng phân giải. Lý do từ chối là dữ liệu trong sự kiện.
- `src/battle/` không sửa `BattleState`. UI hỏi `BattleController`, vẽ theo bản chụp.
- Đi xuống gọi hàm, đi lên phát signal (`BattleInput` phát, `BattleView` nhận). Không Event Bus. `AppState` vẫn là autoload duy nhất.
- Phím tắt khai báo trong InputMap (đăng ký bằng code, như `DevTools`), không bắt `KEY_1` trực tiếp trong `_input`. Mọi thao tác làm được bằng chuột (NFR8).
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). `Dictionary` trả về từ `find_paths`: ép kiểu khi đọc (`as Array`).
- Tất định: BFS duyệt hướng theo `Grid.DIRECTIONS`; danh sách ô trả ra sắp theo thứ tự đọc bàn; không duyệt khóa Dictionary khi thứ tự có nghĩa.
- Không `AStarGrid2D`, không TileMap, không vật lý (project-context).
- Kích thước bàn lấy từ `state.size`, không viết cứng 7 (GDD: trận về sau có thể khác kích thước).

### Ghi chú kỹ thuật Godot 4.7.2

- `_unhandled_input(event: InputEvent)`: `event.is_action_pressed("select_general_1")`. Với chuột: `event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT and event.pressed`; `InputEventMouseMotion` cho rê chuột.
- Đăng ký action: `InputMap.add_action(name)`; `var ev := InputEventKey.new()` (nhớ gõ kiểu: `var ev: InputEventKey = InputEventKey.new()`); `ev.physical_keycode = KEY_1`; `InputMap.action_add_event(name, ev)`. Xem `src/debug/dev_tools.gd`.
- `queue_redraw()` sau khi đổi ô sáng / đường đi. `draw_polyline(points, color, width, antialiased)`, `draw_circle(center, radius, color, filled, width, antialiased)` (như `unit_token.gd`).
- Tra Context7 (`/godotengine/godot-docs/__branch__4.7`) nếu cần: `Node._unhandled_input`, `CanvasItem.get_local_mouse_position`, `InputMap`.
- Trên web: phím `1` `2` `3` tới được game. Nếu tác giả bật bộ gõ VNI, phím số có thể bị bộ gõ dùng để bỏ dấu. Ghi vào hướng dẫn test: tắt bộ gõ, hoặc dùng chuột.

### Cấu trúc file sau story

```
game/
├── src/
│   ├── core/
│   │   ├── grid.gd            # MỚI: DIRECTIONS B→Đ→N→T
│   │   ├── command.gd         # MỚI: Command.move
│   │   ├── battle_event.gd    # MỚI: MOVED, REJECTED
│   │   ├── effects.gd         # MỚI: Effects.move (chỗ duy nhất gán .cell)
│   │   ├── pathfinding.gd     # MỚI: BFS
│   │   ├── rules.gd           # MỚI: Rules.resolve
│   │   ├── rules_move.gd      # MỚI: reachable, path_to, resolve
│   │   └── unit.gd            # sửa chú thích
│   ├── battle/
│   │   ├── battle_controller.gd  # + reachable, path_to
│   │   ├── battle_input.gd       # MỚI
│   │   ├── battle_view.gd        # MỚI
│   │   └── board_view.gd         # + cell_at, ô sáng, vòng chọn, đường đi
│   └── app/main.gd               # tạo BattleInput, BattleView
└── tests/
    ├── kich_ban/di_chuyen/       # + 7 kịch bản (đợt 1)
    ├── scenario_runner.gd        # chạy "di"
    ├── test_rules_move.gd        # MỚI
    ├── test_battle_view.gd       # MỚI
    └── test_scenario_loader.gd   # sửa test lệnh chưa có luật
```

Nhớ commit file `.uid` của mọi script mới.

### Testing

- `tools/test.sh` là lệnh duy nhất. Lõi luật test trực tiếp (`BattleState` + `Rules.resolve`), không cần màn hình.
- Test bộ chạy và test luật phải có ca **trượt thật**, không chỉ ca đạt (bài học Story 1.2, 1.3).
- Phần chọn tướng có test GUT (gọi hàm xử lý, kiểm ô sáng). Phần nhìn (màu, vị trí đường kẻ) tác giả test tay; dev tự xem bằng ảnh chụp GoPeak (Task 9.1).

**Mẫu hướng dẫn tác giả tự test** (ghi vào Completion Notes, theo kết quả thật):
1. Gõ `tools/test.sh`. Đúng là: `✅ … test đạt`, có dòng `Kịch bản luật: 8 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
2. Gõ `tools/chay.sh`. Bấm vào đồng "Khoái": có vòng chọn, 7 ô sáng (`0,3` `0,4` `1,4` `0,5` `1,5` `2,5` `1,6`). Ô của "Lão" không sáng.
3. Rê chuột lên ô `2,5` (ô ngay trên "Lão"): thấy đường đi `0,6` → `0,5` → `1,5` → `2,5`. Rê ra ô sông: đường đi mất.
4. Gõ `2`: đổi sang "Lão", 7 ô sáng (`2,3` `1,4` `2,4` `0,5` `1,5` `2,5` `1,6`). Gõ `3`: không có gì đổi.
5. Bấm lại "Lão": bỏ chọn, hết ô sáng. Chọn lại, bấm vào ô sông: bỏ chọn.
6. Gõ `tools/chay.sh --dev --tran=thu_ba_tuong`, gõ `3`: chọn được "Dư".
7. Bấm ô sáng: chưa đi (Story 1.5 mới có).

(Nếu bàn phím đang bật bộ gõ VNI, tắt đi trước khi gõ số.)

### Previous Story Intelligence (Story 1.3 và code review)

- **Quy trình duyệt:** kịch bản chưa duyệt mà chưa đạt thì `test.sh` vẫn xanh, có dòng ⏳ kèm lý do ở dòng dưới. Kịch bản đã duyệt mà trượt thì `test.sh` đỏ. Nhờ vậy commit được đợt kịch bản trước khi tác giả duyệt (Task 1.3). Đổi `da_duyet` rồi thì không commit tới khi xanh.
- **Bộ chạy** (`scenario_runner.gd`): dựng `BattleState.from_level(scenario.before, stats)`, chạy từng bước, sau mỗi bước `validate()`, rồi `compare` theo ô. Bảng ký hiệu lấy ngược từ `BoardText` (`unit_symbol`, `terrain_symbol`). Lệnh chưa có luật trả `lệnh "x" chưa có luật (Story y)` từ `PENDING_RULES`.
- **Công cụ duyệt** in hành động `di` thành `<tên tướng> đi tới c,h`. Không cần sửa.
- `test_scenarios.gd` ghi kết quả 4 cột cho `test.sh`: trạng thái, đạt/trượt, id, lý do đầu tiên. File sai định dạng cũng có dòng (`sai_dinh_dang`).
- Lần trước, khi chạy `-s`, `AppState` đọc mọi tham số sau `--` nên in cảnh báo "tham số lạ". Story này không thêm script `-s` mới.
- Đọc `deferred-work.md`: `terrain_at` không tự kiểm biên (gọi `in_bounds` trước); khóa `da_duyet` chưa có tự kiểm tự động (Task 9.2 thử tay trên clone tạm); F1/F5 trên trình duyệt có thể bị trình duyệt chiếm (không liên quan phím 1–3).
- Story 1.2: đồng quân dùng lại theo id; chữ cũ phải `remove_child` rồi mới `queue_free`; regex dùng `\A…\z`. Story này không thêm Label mới. Nếu có thì theo đúng mẫu đó.

### Git Intelligence

- Commit gần nhất: `22d7228` (sửa theo review 1.3), `29dbcf7` (Story 1.3), `b8b1b6d` (tạo story 1.3), `3d1a664` (sửa theo review 1.2), `06beb1d` (Story 1.2).
- Mẫu: một commit cho đợt kịch bản chờ duyệt (Task 1.3), một commit chính khi xanh (Task 9.3), rồi "Sửa theo code review Story 1.4". Lời commit tiếng Việt, gạch đầu dòng theo thay đổi, kèm dòng `Co-Authored-By`.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- **M3 không ngoại lệ.** Không viết code luật trước khi tác giả duyệt. Không bao giờ sửa hay xóa kịch bản `da_duyet: true` để test đạt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả, không tự đoán. Các mục **[Tác giả chốt 2026-10-18]** ở trên là đề xuất; tác giả có thể đổi trước khi dev bắt đầu.
- Sau mỗi lần phân giải trong test: `state.validate()` rỗng.
- Thứ tự B→Đ→N→T cho mọi trường hợp hòa (BFS, chọn đường).
- Chữ hiển thị qua `tr()` (story này không thêm chữ mới cho người chơi; lý do từ chối là chữ cho dev).
- Commit chỉ khi `tools/test.sh` xanh. Lệnh cho tác giả nằm trong `tools/`, chạy từ gốc repo.
- MCP chỉ để nhìn và thử (`--dev`). Luật và dữ liệu chỉ sửa trong code, có test.

### Quyết định trong story này (tác giả đồng ý cả 3 mục, 2026-10-18)

1. **Bỏ chọn** (AC 8): bấm lại tướng đang chọn hoặc gõ lại phím của nó thì bỏ chọn; bấm ô không sáng thì bỏ chọn; bấm ô sáng chưa làm gì (Story 1.5).
2. **Lệnh đi không hợp lệ trong kịch bản**: tướng đứng yên, bàn sau giống bàn trước, kịch bản đạt.
3. **Hầm chông**: đợt này không có kịch bản hầm chông. Trong game tướng đi vào ô hầm chông được nhưng chưa mất máu, tới Story 3.4 (mất máu) và E3 (đường ít hầm chông nhất).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.4]
- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.5] (phần để lại cho story sau)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Grid System and Movement]
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Controls and Input]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Quản lý trạng thái]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#M2. Ống phân giải luật (resolution pipeline)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#M3. Kịch bản luật là spec (quy trình)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Bảng thứ tự phân giải] (Tự đi)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Cây thư mục] (`grid.gd`, `command.gd`, `battle_event.gd`, `rules.gd`, `rules_move.gd`, `pathfinding.gd`, `battle_input.gd`, `battle_view.gd`)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Xử lý lỗi] (lệnh không hợp lệ không phải lỗi)
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/1-3-kich-ban-luat-va-cong-cu-duyet-tren-terminal.md]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1: viết 7 kịch bản mới bằng script (bàn 7×7, mỗi lệnh `di` một dòng như file mẫu). `tools/xem_kich_ban.sh di_chuyen` in đủ 8 kịch bản, từng bàn trước/sau khớp `mo_ta`. Số bước của đường vòng (kịch bản 5, 6, 7, 8) đã kiểm bằng BFS lúc tạo story. `tools/test.sh`: 226/226 đạt, `Kịch bản luật: 0 đã duyệt · 8 chưa duyệt (8 chưa đạt)`, mỗi kịch bản có lý do `bước 1: lệnh "di" chưa có luật (Story 1.4)`.

- Task 1.5: tác giả trả lời "đúng hết" (2026-10-18). Đổi `da_duyet: true` cho cả 8 file (chỉ khóa đó, `git diff` mỗi file 1 dòng). `tools/test.sh` trượt đúng như AC 2: `kịch bản đã duyệt di_chuyen/di_thang_3_o.json: bước 1: lệnh "di" chưa có luật (Story 1.4)`. Không commit lúc đỏ.
- Task 2–5: viết lõi luật xong, `tools/test.sh` xanh 245/245, `Kịch bản luật: 8 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Task 5.2: tạm cho quân Nguyên không chặn đường (`_can_pass` luôn trả true) thì 2 test trượt: `test_enemy_blocks_the_way` và `test_approved_scenarios_pass` (kịch bản `quan_nguyen_chan_duong`). Đã trả code về như cũ.
- Task 8: lần đầu GUT bỏ qua `test_battle_view.gd` vì hàm phụ tên `_input` trùng hàm có sẵn của Node (`test.sh` bắt được: "có file test không được chạy"). Đổi tên thành `_battle_input`.
- Task 9.1 (GoPeak, `tools/chay.sh --dev`): lần đầu bấm chuột bơm vào không chọn được tướng. Nguyên nhân: `BattleInput` đọc vị trí con trỏ thật (`get_local_mouse_position()`), không đọc vị trí trong sự kiện. Đã đổi sang `make_input_local(event).position` (đúng cho cả bấm thật lẫn bơm), thêm test `test_mouse_events_map_screen_pixels_to_cells`. Chạy lại: bấm "Khoái" (pixel 376, 624) thì có vòng vàng, 7 ô xanh lá đúng AC 4; rê lên ô `2,5` (pixel 552, 536) thì có đường đi xanh dương `0,6 → 0,5 → 1,5 → 2,5`; action `select_general_2` đổi sang "Lão", 7 ô đúng AC 5. Màu ô sáng (xanh lá) khác rõ màu sông (xanh dương).
- `inject_key` của GoPeak chỉ gửi `keycode`, không gửi phím vật lý, nên không kích hoạt action (action đăng ký theo phím vật lý, giống DevTools). Phím thật trên bàn phím có đủ cả hai. Khi thử bằng GoPeak thì dùng `inject_action` (`select_general_1..3`).
- Task 9.2 (khóa, trên bản sao tạm có commit riêng, đã xóa): sửa ô đích của `qua_tam_di.json` (kịch bản đã duyệt) thì `tools/test.sh` trượt ở bước 2: `❌ game/tests/kich_ban/di_chuyen/qua_tam_di.json: kịch bản đã duyệt bị sửa so với commit gần nhất`. Repo chính không bị đụng. Tự kiểm tự động vẫn hoãn.
- `tools/test.sh` cuối cùng: 261/261 đạt, ranh giới đạt, `Kịch bản luật: 8 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Đã làm đủ Task 1–9. Thêm 35 test (226 → 261).
- **Lệch so với story (ghi để review):**
  - `BattleInput` lấy ô từ vị trí trong sự kiện chuột (`make_input_local`), không dùng `get_local_mouse_position()` như Dev Notes "Hiển thị" gợi ý (lý do ở Debug Log).
  - `BoardView` có thêm `lit_cells()` và `path()` (chỉ đọc) để test kiểm thứ đang vẽ; `BattleView` có `selected_id()` và `lit_cells()`.
  - Test bộ chạy cũ trong `test_scenario_loader.gd` dùng chỉ số không có `tam_di` (tầm đi 0): đã thêm `tam_di: 3`.

**Hướng dẫn tác giả tự test** (kết quả thật, đã chụp màn hình bằng GoPeak):
1. Gõ `tools/test.sh`. Đúng là: `✅ 261/261 test đạt`, có dòng `Kịch bản luật: 8 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
2. Gõ `tools/chay.sh`. Bấm vào đồng "Khoái": có vòng vàng quanh Khoái, 7 ô xanh lá (`0,3` `0,4` `1,4` `0,5` `1,5` `2,5` `1,6`). Ô của "Lão" không sáng.
3. Rê chuột lên ô `2,5` (ô ngay trên "Lão"): thấy đường kẻ xanh dương `0,6 → 0,5 → 1,5 → 2,5`, chấm tròn ở ô đích. Rê ra ô sông: đường đi mất.
4. Gõ `2`: vòng vàng sang "Lão", 7 ô sáng (`2,3` `1,4` `2,4` `0,5` `1,5` `2,5` `1,6`). Gõ `3`: không có gì đổi.
5. Bấm lại "Lão": bỏ chọn, hết ô sáng. Chọn lại, bấm vào ô sông: bỏ chọn.
6. Gõ `tools/chay.sh --dev --tran=thu_ba_tuong`, gõ `3`: chọn được "Dư".
7. Bấm ô sáng: chưa đi (Story 1.5 mới có).

Nếu đang bật bộ gõ VNI thì tắt đi trước khi gõ số.

### File List

- `game/src/core/grid.gd` (mới)
- `game/src/core/command.gd` (mới)
- `game/src/core/battle_event.gd` (mới)
- `game/src/core/effects.gd` (mới)
- `game/src/core/pathfinding.gd` (mới)
- `game/src/core/rules.gd` (mới)
- `game/src/core/rules_move.gd` (mới)
- `game/src/core/unit.gd`
- `game/src/battle/battle_controller.gd`
- `game/src/battle/battle_input.gd` (mới)
- `game/src/battle/battle_view.gd` (mới)
- `game/src/battle/board_view.gd`
- `game/src/app/main.gd`
- `game/tests/scenario_runner.gd`
- `game/tests/test_scenario_loader.gd`
- `game/tests/test_rules_move.gd` (mới)
- `game/tests/test_battle_view.gd` (mới)
- `game/tests/kich_ban/di_chuyen/*.json` (7 mới, 8 đổi `da_duyet: true`)
- file `.uid` của mọi script mới
- `_bmad-output/implementation-artifacts/1-4-chon-tuong-va-xem-cac-o-di-duoc.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-18: Tạo story.
- 2026-10-18: Tác giả chốt 3 quyết định (bỏ chọn, lệnh đi không hợp lệ, hầm chông).
- 2026-10-18: Làm story: lõi luật đi (`Rules`, `RulesMove`, `Pathfinding`, `Effects`, `Command`, `BattleEvent`, `Grid`), bộ chạy chạy lệnh `di`, chọn tướng bằng chuột và phím 1-2-3, ô sáng, đường đi. 8 kịch bản `di_chuyen/` tác giả đã duyệt và đều đạt.
- 2026-10-18: Code review: 2 quyết định, 9 sửa, 3 hoãn (`deferred-work.md`). Kịch bản ghi lý do từ chối (`tu_choi`, bắt buộc); 6 kịch bản đứng yên tác giả duyệt lại. Sửa đường đi khi chọn lúc chuột nằm sẵn trên ô sáng và khi chuột ra khỏi cửa sổ; phím 1-2-3 kiểm phe; luật kiểm "không phải tướng" theo loại quân. `tools/test.sh`: 272/272, 8 đã duyệt · 0 chưa duyệt.
