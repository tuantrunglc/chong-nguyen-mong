---
baseline_commit: 4f66e01
---

# Story 2.6: Địch chuẩn bị: AI đi và chọn mục tiêu

Status: done

## Story

Là người chơi,
tôi muốn quân Nguyên đi theo luật mà tôi đoán trước được,
để tính được nước đi của chúng mà không cần xem code.

_Story luật thứ sáu của E2, mở pha địch. Tới nay quân Nguyên đứng yên; từ story này, **đầu mỗi hiệp** (kể cả hiệp 1, trước lượt đầu tiên của người chơi) từng quân Nguyên chọn tướng để nhắm, đi tới ô đứng, rồi **báo đòn** (ghi `Telegraph` vào `BattleState`). Đòn **chưa đánh** (2.8) và **chưa vẽ ô đỏ** (2.7): tác giả kiểm bằng kịch bản và bằng bảng F3._

_**Chưa có** (đừng làm ở đây): vẽ ô đỏ, số thứ tự, mũi tên (2.7); ra đòn, trừ máu (2.8); đòn dịch theo khi bị đẩy, hủy đòn (2.9); Cung kỵ (2.15); hầm chông khi đi (3.4); tiếp viện (3.10); nhắm làng (3.7), nhắm ô ải (3.11). Viết `EnemyAI` sao cho các story đó chỉ việc thêm nhánh._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 10 kịch bản mới ở Dev Notes "Đợt kịch bản 8" (`da_duyet: false`) và phần khung ở Task 1.1 (khóa `bao_don` của `sau`, lớp `Telegraph`, trường `BattleState.telegraphs`). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 49 đã duyệt · 10 chưa duyệt (10 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh ai`. Chưa duyệt xong thì không viết dòng code luật nào (`enemy_ai.gd`, `rules_enemy_phase.gd`, `pathfinding.gd`).
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` **trượt** (kịch bản đã duyệt chưa đạt). Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 59 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh, `BattleState.validate()` rỗng;
   - **49 kịch bản đã duyệt cũ không bị sửa một chữ** (xem AC 12).
4. **Pha địch chuẩn bị chạy đầu mỗi hiệp (FR22).** Khi trận mở (hiệp 1, trước lượt đầu của người chơi) và sau mỗi lần Kết thúc lượt (đầu hiệp mới), từng quân Nguyên đi rồi báo đòn. Xong pha thì về `Phase.PLAYER`. Bàn người chơi thấy lúc mở trận là bàn **sau khi** quân Nguyên đã đi.
5. **Thứ tự hành động (FR23).** Quân Nguyên hành động **lần lượt** theo thứ tự trong file trận (`thu_tu_dich`, tức thứ tự id 101, 102…). Quân sau thấy vị trí mới của quân trước (ô quân trước vừa đứng thì quân sau không đứng được).
6. **Chọn mục tiêu (FR23, câu 1).** Mỗi quân nhắm **tướng gần nhất theo số bước đi**: đếm bước như quân đó đi (4 hướng; đi xuyên quân Nguyên khác; sông, rừng, kho lương, làng, tướng khác chặn), không giới hạn tầm đi. **Hòa số bước thì nhắm tướng ít máu hơn; vẫn hòa thì tướng ở phía Bắc hơn (hàng trên hơn), rồi phía Đông hơn (cột lớn hơn).** Tướng không có đường tới thì không xét.
7. **Chọn ô đứng (FR23, câu 2).** Trong tầm đi (`tam_di` của `chi_so.json`; kể cả đứng yên), quân chọn **ô mà từ đó đòn trúng được mục tiêu**, cần **ít bước đi nhất** (đang đánh được thì đứng yên). Hòa thì ô ở phía Bắc hơn, rồi phía Đông hơn.
   - **Bộ binh:** ô kề mục tiêu (4 hướng).
   - **Kỵ binh:** ô cùng hàng hoặc cùng cột với mục tiêu, và trên đường thẳng từ ô đó tới mục tiêu **không có gì chắn** (không quân nào, không rừng, kho lương, làng; sông không chắn). Không giới hạn khoảng cách.
8. **Không có ô đánh trúng (FR23, câu 3).** Quân đi tới ô **gần mục tiêu nhất theo số bước đi** (đếm như AC 6). Hòa thì ô cần ít bước đi hơn, rồi phía Bắc hơn, rồi phía Đông hơn. **Hiệp đó quân này không báo đòn.** Số thứ tự chỉ đếm quân có đòn: 1, 2, 3 liền nhau. Không có tướng nào có đường tới thì quân đứng yên, không báo đòn.
9. **Đi theo luật (kiến trúc "Tự đi").** Quân đi theo đường ngắn nhất tới ô đã chọn, từng ô một qua `Effects.move` (`Cause.WALK`), hòa thì theo B→Đ→N→T (`Pathfinding.find_paths`, như tướng). Không đứng chung ô với quân khác. Không né ô đỏ của đồng đội, không phối hợp.
10. **Báo đòn (M1).** Mỗi quân có ô đánh trúng tạo một `Telegraph` lưu tương đối: `owner_id`, `kind`, `offset`, `order`. Bộ binh: `CELL`, `offset` = ô mục tiêu − ô đứng. Kỵ binh: `DIRECTION`, `offset` = hướng (một phần tử của `Grid.DIRECTIONS`). Đầu pha chuẩn bị, đòn cũ bị xóa. `BattleState.clone()` sao chép sâu từng `Telegraph`. Mỗi đòn sinh sự kiện `TELEGRAPHED` (chủ đòn, ô đứng, số thứ tự).
11. **F3 (dev).** Khi bật dev và bấm `F3`, hiện bảng ý định: mỗi quân Nguyên một dòng: quân nào, đi từ ô nào tới ô nào, nhắm tướng nào (cách mấy bước), vì sao chọn ô đó (đánh trúng được, hay không với tới nên đi gần nhất, hay không có đường), và đòn số mấy. Bấm `F3` lần nữa thì ẩn. Không bật dev thì `F3` không làm gì. Bảng cập nhật sau mỗi lệnh và sau mỗi lần nạp lại trận (F5, "Chơi lại trận").
12. **Chỉ số (FR18, FR19).** Bộ binh 3 máu, đi 2; Kỵ binh 2 máu, đi 3: lấy từ `chi_so.json` (đã có, kiểm lại không sửa). AI đọc tầm đi qua `Stats.move_range`, không viết cứng số.
13. **Không phá luật đã duyệt.** Bộ chạy kịch bản dựng bàn `truoc` **không** chạy pha chuẩn bị lúc mở (bàn `truoc` là đầu lượt người chơi); pha chuẩn bị chỉ chạy trong lệnh `ket_thuc_luot`. Khóa `bao_don` không bắt buộc, không ghi thì không kiểm. 49 kịch bản cũ không sửa. Nếu một kịch bản cũ trượt, **dừng và hỏi tác giả**.
14. **Trận thật và trận thử vẫn chơi được.** Mở `tran_01` bằng `tools/chay.sh --dev`: 3 Bộ binh đã đi về phía hai tướng trước lượt đầu. Các trận thử `thu_*` có hướng dẫn tự test cũ: dev kiểm lại từng trận sau khi quân Nguyên biết đi; trận nào hỏng bước thử thì đổi bố cục (ghi lại trong Completion Notes).
15. **Không có lỗi trong log** (không `ERROR`, `WARN`) khi chạy `tran_01`, bấm F3, kết thúc lượt vài lần.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt 3 câu hỏi** ở "Quyết định của tác giả" (2026-10-21: câu 1 tướng ít máu hơn, câu 2 ít bước nhất, câu 3 không báo đòn). Các Task dưới viết đúng theo ba lựa chọn này.
- [x] **Task 1: Khung, đợt kịch bản 8, dừng chờ duyệt** (AC: 1, 2, 13)
  - [x] 1.1 Khung (không phải code luật, làm trước để kịch bản nạp và so được):
    - `src/core/telegraph.gd` (MỚI): đúng mẫu M1 của kiến trúc: `class_name Telegraph extends RefCounted`, `enum Kind { CELL, DIRECTION }`, `owner_id`, `kind`, `offset: Vector2i`, `order: int`, gán trong `_init`. Hàm `target_cell(state)` (chỉ cho `CELL`; chủ đòn không còn thì trả `Vector2i(-1, -1)`, không crash) và `clone()`.
    - `src/core/battle_state.gd`: `var telegraphs: Array[Telegraph] = []`; `clone()` chép **từng** telegraph bằng `Telegraph.clone()` (không `duplicate(true)`: luật project-context). `validate()`: số thứ tự (`order`) mỗi đòn từ 1, không trùng.
    - `src/data/scenario_loader.gd`: khóa mới `bao_don` của `sau` (không bắt buộc), thêm vào `AFTER_KEYS`. Mỗi phần tử: `{"thu_tu": <số nguyên ≥ 1>, "quan": "cot,hang", "o": "cot,hang"}` (Bộ binh) **hoặc** `{"thu_tu": …, "quan": …, "huong": "B" | "D" | "N" | "T"}` (Kỵ binh). Kiểm: đúng một trong `o`/`huong`; `quan` trong bàn và có quân Nguyên ở `sau.quan`; `o` trong bàn; `thu_tu` không trùng. Sai thì câu lỗi tiếng Việt kèm file, phần tử thứ mấy và giá trị sai (mẫu câu lỗi của `ket_qua`). `[]` là "không quân nào báo đòn" (vẫn kiểm).
    - `src/data/scenario_data.gd`: `checks_telegraphs: bool`, `after_telegraphs: Array[ExpectedTelegraph]` (lớp con mới: `order`, `owner_cell`, `kind`, `target_cell` hoặc `direction`).
    - `tests/scenario_runner.gd` `compare`: khi `checks_telegraphs`, so danh sách đòn của state (xếp theo `order`) với danh sách mong đợi: cùng số đòn; từng đòn cùng số thứ tự, chủ đòn đứng đúng ô, cùng loại, cùng ô đích (`CELL`: `ô chủ đòn + offset`) hoặc cùng hướng. Mỗi chỗ khác một câu: `sau: đòn 1 mong đợi quân ở 3,3 chém ô 3,4, thực tế không có đòn 1`.
    - `tests/scenario_viewer.gd` (`tools/xem_kich_ban.sh`): in thêm mục "Đòn đã báo" dưới bàn sau, mỗi đòn một dòng: `1. Bộ binh ở 3,3 chém ô 3,4`, `1. Kỵ binh ở 0,3 xung phong về hướng Đông`; `[]` in "không quân nào báo đòn". Chữ qua `tr()` (khóa `scenario.viewer.*` mới trong `i18n/text.csv`, sinh lại `text.vi.translation`).
    - Hướng trong file: `B`, `D`, `N`, `T` (Bắc, Đông, Nam, Tây; viết không dấu như mọi khóa). Bảng chuyển hướng ↔ `Vector2i` để một chỗ (ví dụ trong `board_text.gd`, cạnh `cell_text`) để loader, runner, viewer, F3 dùng chung.
    - `tests/test_scenario_loader.gd`: ca nạp `bao_don` đúng (ô, hướng, rỗng); ca sai: thiếu cả `o` lẫn `huong`, có cả hai, `huong` lạ, `thu_tu` trùng hoặc < 1, `quan` không có quân Nguyên, ô ngoài bàn.
    - **Chưa** viết `EnemyAI`, chưa sửa `RulesEnemyPhase`: kịch bản nạp được nhưng chạy thì trượt.
  - [x] 1.2 Viết 10 file đúng như Dev Notes "Đợt kịch bản 8", `"da_duyet": false`, thư mục mới `tests/kich_ban/ai/`. Chép cấu trúc từ `tests/kich_ban/hiep/ket_thuc_luot_di_lai_duoc.json`. Không đụng 49 kịch bản đã duyệt.
  - [x] 1.3 `tools/xem_kich_ban.sh ai`: đọc lại từng bàn trước/sau và mục "Đòn đã báo", khớp `mo_ta`. `tools/test.sh`: xanh, `49 đã duyệt · 10 chưa duyệt (10 chưa đạt)`, lý do khớp bảng. Ghi Debug Log.
  - [x] 1.4 Commit: `Kịch bản AI quân Nguyên chờ duyệt (Story 2.6)`.
  - [x] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh ai`, đọc 10 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ:
    - mọi kịch bản là **một lần Kết thúc lượt**: bàn sau là đầu hiệp 2, sau khi quân Nguyên đã đi và báo đòn; đòn **chưa đánh** (Story 2.8);
    - mục "Đòn đã báo" là thứ sẽ thành ô đỏ và số thứ tự ở Story 2.7;
    - kịch bản cũ có `ket_thuc_luot` (`hiep/`) không có quân Nguyên nên không đổi.
    Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" xử lý theo AC 2. `tools/test.sh` **phải trượt**. Ghi Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật** (AC: 3–10, 12)
  - [x] 2.1 `src/core/pathfinding.gd`: thêm `distance_field(state, unit, goal) -> Dictionary` (ô → số bước tới `goal`): BFS **xuất phát từ `goal`** qua các ô `unit` đi qua được (`_can_pass`, dùng lại, không chép), `goal` = 0 dù có quân đứng. Không giới hạn bước. Đường đi đối xứng nên số bước từ quân tới mục tiêu là `field[unit.cell]`, từ một ô đứng `c` là `field[c]`. Không dùng `AStarGrid2D`.
  - [x] 2.2 `src/core/enemy_ai.gd` (MỚI, `class_name EnemyAI`, `RefCounted`, hàm `static`). Một hàm công khai `plan(state, unit) -> EnemyIntent` **không sửa state**:
    1. Mục tiêu: với mỗi tướng còn trên bàn (duyệt `state.units`, không duyệt Dictionary), `field = distance_field(state, unit, tướng.cell)`; không có `field[unit.cell]` thì bỏ tướng đó. Chọn theo khóa (số bước, máu, hàng, −cột) nhỏ nhất (AC 6).
    2. Ô ứng viên = `unit.cell` (0 bước) + các khóa của `Pathfinding.find_paths(state, unit, state.stats.move_range(unit.type))` (số bước = độ dài đường).
    3. Ô đánh trúng: Bộ binh `Grid.is_adjacent(c, mục tiêu)`; Kỵ binh `_clear_line(state, c, mục tiêu)` (cùng hàng/cột, mọi ô **giữa** hai đầu không có quân và không phải rừng, kho lương, làng; dùng `Grid.straight_dir`). Có thì chọn theo (số bước, hàng, −cột) (AC 7).
    4. Không có thì chọn ô ứng viên có `field[c]` (ô không có trong `field` thì bỏ) theo (`field[c]`, số bước, hàng, −cột) (AC 8).
    5. Trả `EnemyIntent`.
    - Loại quân chưa có luật đòn (Cung kỵ, 2.15): `plan` trả ý định "đứng yên, không báo đòn" với lý do riêng, không crash (Cung kỵ chưa có trong trận nào).
  - [x] 2.3 `src/core/enemy_intent.gd` (MỚI, thuần dữ liệu, gán trong `_init`, có `clone()`): `unit_id`, `from_cell`, `stand_cell`, `target_id` (0 = không có), `target_steps`, `reason: Reason` (`enum Reason { CAN_HIT, CLOSEST, NO_PATH, NO_ATTACK_RULE }`), `order` (0 = không báo đòn). `BattleState` thêm `enemy_intents: Array[EnemyIntent]` (để F3 đọc từ bản chụp); `clone()` chép sâu.
  - [x] 2.4 `src/core/rules_enemy_phase.gd`: thêm `prepare(state, events)`:
    - `state.phase = ENEMY_PREPARE`; xóa `telegraphs`, `enemy_intents`;
    - duyệt **bản sao** của danh sách quân Nguyên theo thứ tự `state.units` (xếp theo id, khớp `thu_tu_dich`; từ 3.4 quân có thể gục giữa đường);
    - với mỗi quân: `intent = EnemyAI.plan(state, unit)`; đi theo `Pathfinding.find_paths(...)[stand_cell]` qua `Effects.move(..., Cause.WALK, events)`; nếu `reason == CAN_HIT` thì đếm số thứ tự tiếp theo, tạo `Telegraph`, thêm `BattleEvent.telegraphed(...)`; ghi `intent` (đã gán `order`);
    - cuối: `state.phase = PLAYER`.
    - `end_player_turn`: giữ phần cũ (tăng hiệp, xóa cờ, `ROUND_STARTED`), rồi gọi `prepare`. Chú thích chỗ Story 2.8 chèn "ra đòn" (trước khi sang hiệp) và 3.10 chèn tiếp viện (đầu `prepare`).
    - `begin_battle(state, events)`: chạy `prepare` cho hiệp 1 (không tăng hiệp, không `ROUND_STARTED`).
  - [x] 2.5 `src/core/command.gd`: `Kind.BEGIN_BATTLE` (thêm **cuối** enum) và `Command.begin_battle()`: lệnh nội bộ "mở trận", chỉ `BattleController.begin()` gửi; kịch bản không có lệnh này. `src/core/rules.gd`: nhánh `BEGIN_BATTLE` → `RulesEnemyPhase.begin_battle`. Giữ một điểm vào `Rules.resolve`.
  - [x] 2.6 `src/core/battle_event.gd`: `TELEGRAPHED` (thêm **cuối** `Type`; `unit_id` = chủ đòn, `from_cell` = ô đứng, `to_cell` = ô đích (`CELL`) hoặc ô đứng + hướng (`DIRECTION`), `amount` = số thứ tự) và hàm tạo `telegraphed(...)`. Kiểm `tests/board_fixture.gd` `describe` in được sự kiện mới.
  - [x] 2.7 `src/battle/battle_controller.gd`: `begin()` gửi `Command.begin_battle()` qua cùng đường `submit` (validate, quay lại nếu hỏng, phát `events_resolved`); `_describe` có câu "mở trận". `start()` **không** tự chạy pha chuẩn bị (bộ chạy kịch bản và test controller cũ dựng bàn bằng `start`). Lệnh `BEGIN_BATTLE` để `_undo_snapshot = null`.
  - [x] 2.8 `src/app/main.gd`: sau `_controller.start(...)` và nối signal, gọi `_controller.begin()` (mọi chỗ mở trận: lần đầu, F5, "Chơi lại trận"). Thứ tự: nối `events_resolved` trước, để bàn vẽ bản sau khi quân đã đi.
  - [x] 2.9 Chạy `tools/test.sh`; 10 kịch bản mới phải đạt. **Test GUT cũ trượt vì quân Nguyên giờ biết đi** (ví dụ `test_rules_enemy_phase.gd::test_end_turn_lets_every_general_move_again` có Bộ binh ở `5,1`; `test_battle_view.gd` mở trận qua `main.tscn` có Bộ binh): sửa **test** (đặt quân Nguyên đứng kề tướng để nó đứng yên, hoặc kiểm vị trí mới đúng luật), không nới luật. Kịch bản cũ trượt thì dừng, hỏi tác giả (AC 13).
  - [x] 2.10 **Phá thử** (mỗi lần một chỗ, ghi Debug Log, trả lại sau mỗi lần; chạy từng kịch bản riêng vì `test_scenarios` chỉ in kịch bản trượt đầu tiên): đổi hòa mục tiêu sang "phía Bắc trước máu" (kịch bản #5 phải trượt); bỏ "ít bước nhất" (kịch bản #2 hoặc #8 phải trượt); đánh số cả quân không báo đòn (kịch bản #9 phải trượt); cho Kỵ binh xung phong xuyên đồng đội (#9 phải trượt); duyệt quân theo thứ tự ngược (#10 phải trượt); bỏ chép `telegraphs` trong `clone()` (test clone phải trượt).
- [x] **Task 3: Test GUT lõi luật** (AC: 4–10)
  - [x] 3.1 `tests/test_enemy_ai.gd` (MỚI), dùng `BoardFixture`, mỗi ca kiểm `EnemyIntent` (mục tiêu, số bước, ô đứng, lý do) và `plan` không đổi state (`BoardFixture.picture` trước = sau):
    - hòa số bước và máu, **cùng hàng**: nhắm tướng phía Đông (kịch bản không có ca này);
    - tướng bị sông vây kín: không xét; mọi tướng không có đường: `NO_PATH`, đứng yên;
    - số bước đi vòng qua sông (đường thật dài hơn Manhattan) quyết mục tiêu: chọn tướng gần theo đường đi, không theo Manhattan;
    - đi xuyên quân Nguyên khác khi đếm bước và khi đi, không dừng trên nó;
    - tướng khác chắn đường: không đi xuyên;
    - Kỵ binh: rừng giữa đường thì ô đó không đánh trúng; sông giữa đường thì vẫn trúng; đứng kề mục tiêu cùng hàng vẫn tính là đánh trúng;
    - Bộ binh: ô kề mục tiêu là sông thì không đứng được;
    - hòa ô gần nhất (AC 8): ít bước hơn thắng;
    - Cung kỵ: `NO_ATTACK_RULE`, không crash;
    - bàn lớn khác 7×7 (ví dụ 10×8): không lặp cứng cỡ bàn.
  - [x] 3.2 `tests/test_rules_enemy_phase.gd`: `prepare` sinh `MOVED` từng ô (cause `WALK`) rồi `TELEGRAPHED`, theo thứ tự quân; đòn cũ bị xóa đầu pha; `phase` về `PLAYER`; `end_player_turn` sinh `ROUND_STARTED` rồi pha chuẩn bị; `begin_battle` không tăng hiệp; chạy hai lần trên hai bản `clone()` cho cùng dãy sự kiện, cùng đòn (tất định); `validate()` rỗng.
  - [x] 3.3 `tests/test_battle_state.gd`: `clone()` sao chép sâu `telegraphs` và `enemy_intents` (sửa bản sao không đổi bản gốc); `validate()` báo số thứ tự trùng.
  - [x] 3.4 `tests/test_battle_controller.gd`: `begin()` phát `events_resolved` một lần với bản chụp đã có đòn; `can_undo()` false sau `begin()`; `start()` không chạy pha chuẩn bị.
  - [x] 3.5 `grep -rn "Type\.\|Kind\." game/src game/tests`: mọi `match` trên `BattleEvent.Type` và `Command.Kind` có nhánh cho loại mới hoặc bỏ qua có chủ ý (`_describe` của controller, `board_fixture.describe`, công cụ duyệt).
- [x] **Task 4: F3 ý định AI** (AC: 11)
  - [x] 4.1 `src/debug/dev_tools.gd`: thêm `signal f3_pressed`, phát khi bấm F3 (như F1, F5); bỏ câu "f3: chưa có…" ở `MESSAGES`. `tests/test_dev_tools.gd`: F3 phát signal khi bật dev, không làm gì khi tắt.
  - [x] 4.2 `src/debug/ai_intent_overlay.gd` (MỚI, như `coord_overlay.gd`): `show_state(snapshot)` dựng bảng chữ từ `snapshot.enemy_intents`, `toggle()`, `texts()` (để test). Mỗi dòng (chữ qua `tr()`, khóa `dev.ai.*`):
    - `Bộ binh 101: 3,0 → 3,2 · nhắm Nguyễn Khoái (cách 3 bước) · đứng đây vì chém trúng được · đòn số 1`
    - `Kỵ binh 102: 0,3 → 2,3 · nhắm Nguyễn Khoái (cách 4 bước) · không có ô đánh trúng trong tầm đi, đi tới ô gần nhất · không báo đòn`
    - `Bộ binh 103: đứng yên ở 6,6 · không có đường tới tướng nào · không báo đòn`
    - dòng đầu: `Ý định quân Nguyên (hiệp N)`; không có quân Nguyên thì `không có quân Nguyên`.
    - Bảng nền tối mờ, góc trên trái dưới chữ "DEV", không nhận chuột; không che nút HUD (cột phải, `Hud.PANEL_POSITION`). Quân đã gục sau khi báo (người chơi hạ nó) vẫn hiện dòng cũ kèm "(đã gục)", vì ý định là của đầu hiệp.
  - [x] 4.3 `src/app/main.gd`: chỉ khi bật dev tạo overlay, nối `f3_pressed` (chỉ có tác dụng khi đang có trận, như F1), cập nhật trong `_show_board`. Bật/tắt giữ qua các lần nạp lại trận.
  - [x] 4.4 `tests/test_main.gd` (hoặc file test overlay riêng): F3 hiện/ẩn bảng; chữ khớp ý định của trận dựng trong `user://`; không bật dev thì không có overlay. Phím bằng `InputEventKey` có `physical_keycode`.
- [ ] **Task 5: Trận thật, trận thử, tài liệu** (AC: 14, 15)
  - [ ] 5.1 Chạy từng trận thử `thu_*` (`tools/chay.sh --dev --tran=<tên>`), bấm F3, đối chiếu với hướng dẫn tự test của story tạo ra nó (1.9 `thu_co_lon`/`thu_co_nho`, 2.1 `thu_day`, 2.3 `thu_lao`, 2.4 `thu_keo`, 2.5 `thu_thang`, `thu_ba_tuong`). Trận nào quân Nguyên giờ đi mất khỏi chỗ cần thử: đổi bố cục (thường là đặt quân Nguyên **kề** tướng sẽ nhắm nó, để nó đứng yên), ghi trận nào đổi gì vào Completion Notes. Đọc lại bằng F3 rằng ý định đúng luật.
  - [ ] 5.2 `tran_01`: mở bằng `tools/chay.sh --dev`, F3, kết thúc lượt 2–3 lần; ghi lại ý định thật của 3 Bộ binh ở hiệp 1 vào Completion Notes (để tác giả đối chiếu khi tự test).
  - [ ] 5.3 _(Chưa chụp: GoPeak không kết nối trong phiên này; chờ tác giả kiểm tay F3 trên `tran_01`, không có ảnh.)_ Chụp màn hình (`tools/chay.sh --dev` + GoPeak `capture_screenshot`) bảng F3 trên `tran_01`; lưu `_bmad-output/implementation-artifacts/anh/2-6-f3.png`. Không chụp được thì bỏ [x] và ghi lý do.
  - [x] 5.4 `game-architecture.md`: dòng "Pha địch 1b" ghi luật đã chốt (mục tiêu hòa → máu → Bắc → Đông; ô đứng ít bước nhất; không với tới thì đi gần nhất, không báo đòn; Kỵ binh cần đường thẳng trống); cây thư mục thêm `enemy_intent.gd`, `ai_intent_overlay.gd`; mục "Kịch bản luật" thêm khóa `bao_don`. `deferred-work.md`: ghi việc cho 2.7 (vẽ từ `telegraphs`), 2.8 (ra đòn rồi mới sang hiệp; xóa đòn sau khi ra), 2.9 (dời/hủy đòn khi chủ bị đẩy hoặc gục; F3 ghi "đã gục").
  - [x] 5.5 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, trận thử, tài liệu, mọi `.uid` mới, `game/i18n/text.vi.translation`. Ví dụ: `Quân Nguyên đi và báo đòn (Story 2.6)`.
  - [x] 5.6 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes bằng kết quả thật.

### Review Findings

- [x] [Review][Patch] (tác giả chọn a: lập kế hoạch mọi quân trước, rồi mới báo đòn) Kỵ binh báo xung phong xong, quân Nguyên id lớn hơn đi vào giữa đường thẳng — `Telegraph` lưu hướng, không kiểm lại; `can_hit_from` chỉ kiểm lúc lập kế hoạch cho Kỵ binh (Bộ binh id 102 đi sau có thể chắn). Chọn: (a) lập kế hoạch mọi quân trước rồi mới báo đòn, (b) cuối `prepare` hủy/kiểm lại đòn `DIRECTION` bị chắn, (c) để 2.8 kiểm lại đường khi ra đòn. [rules_enemy_phase.gd:34-53, enemy_ai.gd:71-86]
- [x] [Review][Patch] (tác giả chọn a: đổi bố cục + test) Ba trận thử `thu_ba_tuong`, `thu_co_nho`, `thu_day` không đổi bố cục dù quân Nguyên giờ đi lúc mở trận (AC 14, Task 5.1). Chọn: (a) đổi bố cục như 4 trận kia + test `_assert_enemies_stay_on_begin`, (b) chấp nhận, sửa AC 14 và ghi hướng dẫn tự test mới cho 3 trận này. [game/data/tran/, test_loaders.gd]
- [x] [Review][Patch] Task 5.1, 5.2, 5.3 đánh `[x]` nhưng chưa bấm F3 thật, không có ảnh `anh/2-6-f3.png`; số liệu hiệp 1 `tran_01` lấy từ mô phỏng Python ngoài repo. Đã bỏ `[x]` (5.1 chỉ còn phần đổi bố cục xong; F3 chờ tác giả kiểm tay). [story: Tasks 5.1–5.3, dòng ~118-122]
- [x] [Review][Patch] `BEGIN_BATTLE` chạy lại được (giữa trận hoặc gọi `begin()` lần hai): quân Nguyên đi thêm lượt, đòn đã báo bị xóa. Chỉ chạy khi `round_number == 1` và `telegraphs`, `enemy_intents` rỗng, nếu không thì từ chối; thêm test gọi lại. [rules.gd:19-20, rules_enemy_phase.gd:20, battle_controller.gd:28-30]
- [x] [Review][Patch] Vòng `for step in path` không dừng khi quân đã gục giữa đường (hầm chông 3.4): vẫn gán `cell` và phát MOVED. `break` khi `state.unit_by_id(unit.id) == null`. [rules_enemy_phase.gd:37-39]
- [x] [Review][Patch] `BattleState.validate()` chỉ kiểm `order` của telegraph, không kiểm hình dạng: `DIRECTION` phải có `offset` thuộc `Grid.DIRECTIONS`, `CELL` phải có `offset` một ô kề, `owner_id` phải là quân Nguyên (cho phép đã gục, xem deferred 2.9). Thêm test. [battle_state.gd:92-99]
- [x] [Review][Patch] `test_f3_shows_ai_intents...` đặt `AppState.launch.dev = true` mà không khôi phục; thêm `after_each` đặt lại. (Không cần sửa: `after_each` ở dòng 42 đã đặt `dev = false`.) [test_battle_view.gd]
- [x] [Review][Patch] `test_prepare_is_deterministic` chỉ so `describe`, `picture` và số lượng telegraph; so cả nội dung đòn (owner, kind, offset, order) và `enemy_intents`. [test_rules_enemy_phase.gd]
- [x] [Review][Patch] Loader `bao_don` không báo lỗi khi hai mục trùng ô `quan`, hoặc `o` không kề `quan`; lỗi chỉ lộ ở runner. [scenario_loader.gd:~326-345]
- [x] [Review][Defer] Overlay F3 dùng `UnitType.GENERALS[intent.target_id - 1]`, vỡ khi 3.7 thêm mục tiêu làng — deferred, xử lý ở 3.7 [ai_intent_overlay.gd]
- [x] [Review][Defer] Overlay F3 mượn khóa dịch `scenario.unit.*` của công cụ duyệt kịch bản; gom về `unit.*` khi dọn i18n — deferred [ai_intent_overlay.gd]
- [x] [Review][Defer] `main._start_battle` bỏ qua kết quả `begin()` (bị từ chối thì không báo lỗi) — deferred, xử lý cùng màn lỗi ở E4 [main.gd]

## Dev Notes

### Bối cảnh

- **Đã có (không làm lại):** `Pathfinding.find_paths` (BFS B→Đ→N→T, đi xuyên quân cùng phe, không dừng trên quân), `Effects.move` (đi một ô, ghi `MOVED`; quân Nguyên vào sông thì chết đuối, nhưng đường AI không qua sông), `Grid.is_adjacent`, `Grid.straight_dir`, `Grid.DIRECTIONS`, `BattleState.Phase` (đã khai báo đủ 6 pha ở 2.5), `RulesVictory.check` ở cuối `Rules.resolve`. Chỉ số Bộ binh, Kỵ binh đã có trong `chi_so.json` và `StatsLoader`.
- **Chưa có:** `Telegraph`, `EnemyAI`, `EnemyIntent`, `distance_field`, pha chuẩn bị, `BEGIN_BATTLE`, `TELEGRAPHED`, khóa `bao_don`, F3.
- `RulesEnemyPhase.end_player_turn` hiện chỉ tăng hiệp và xóa cờ đi/đánh (Story 1.5). Story này thêm pha chuẩn bị **sau** phần đó. Story 2.8 sẽ chèn "ra đòn" **trước** khi sang hiệp: viết `end_player_turn` theo khung "Mẫu trạng thái" của kiến trúc để 2.8 chỉ chèn một dòng.
- **Kịch bản cũ an toàn:** hai kịch bản có `ket_thuc_luot` (`hiep/ket_thuc_luot_di_lai_duoc.json`, `hiep/ket_thuc_luot_xoa_huy.json`) không có quân Nguyên (đã cố ý từ 1.5, xem `deferred-work.md`). Mọi kịch bản khác không kết thúc lượt, và bộ chạy không chạy pha chuẩn bị lúc mở (AC 13), nên quân Nguyên trong chúng vẫn đứng yên.
- **Đòn chưa đánh:** đòn báo ở hiệp này bị xóa đầu pha chuẩn bị hiệp sau mà không đánh. Đúng ý story (2.8 làm phần đánh). Người chơi đẩy hay kéo chủ đòn thì đòn tự theo (lưu tương đối), nhưng hủy khi ra ngoài bàn hay khi chủ gục là 2.9: ở story này `Telegraph.target_cell` phải chịu được chủ đòn đã gục.

### Thuật toán (đã chốt, AC 6–8)

```
với mỗi quân Nguyên q, theo thứ tự id:
  mục tiêu = tướng t có đường tới, khóa nhỏ nhất (bước(q, t), máu t, hàng t, −cột t)
  không có → đứng yên, NO_PATH, không báo đòn
  ứng viên = {q.cell: 0} ∪ {ô: số bước} trong tầm đi (find_paths)
  đánh trúng = ứng viên mà từ đó đòn trúng t (Bộ binh: kề; Kỵ binh: đường thẳng trống)
  có → ô đứng = khóa nhỏ nhất (số bước, hàng, −cột); CAN_HIT; báo đòn số tiếp theo
  không → ô đứng = khóa nhỏ nhất (bước(ô, t), số bước, hàng, −cột); CLOSEST; không báo đòn
  đi tới ô đứng theo đường của find_paths
```

- "Bước(a, t)" = `distance_field(state, q, t.cell)[a]`: đếm như `q` đi, không giới hạn tầm đi. Đếm bằng `q` (không phải quân bất kỳ) vì "đi xuyên quân cùng phe" phụ thuộc phe của quân đang tính.
- "Phía Bắc hơn" = hàng (`y`) nhỏ hơn; "phía Đông hơn" = cột (`x`) lớn hơn. Đây là thứ tự B→Đ→N→T của GDD áp cho chỗ hòa giữa các ô/tướng; hòa giữa các **đường** vẫn do `find_paths` lo (thứ tự bước B→Đ→N→T).
- Khóa so sánh viết thành một hàm so sánh mảng số nguyên nhỏ (tránh `sort_custom` với lambda dài); không dùng `float`.
- Mỗi quân gọi `distance_field` một lần cho mỗi tướng (≤ 3) và một `find_paths`: bàn ≤ 80 ô nên không cần tối ưu (project-context "Hiệu năng").

### Đợt kịch bản 8

Thư mục mới `tests/kich_ban/ai/`. Mọi kịch bản `"da_duyet": false` lúc viết, bàn 7×7 toàn đất trống (trừ khi ghi), hành động **chỉ một lệnh** `{"lenh": "ket_thuc_luot"}`, `sau` ghi `"hiep": 2` và `bao_don`. Tướng 3 máu trừ khi ghi khóa `mau` (như kịch bản cũ). `B` Bộ binh đi 2, `K` Kỵ binh đi 3 (kiểm lại `chi_so.json` trước khi viết `sau`). Tọa độ `cot,hang`.

| # | Tên file | Trước | Sau | Ý nghĩa |
|---|---|---|---|---|
| 1 | `bo_binh_toi_canh_tuong.json` | B `3,1`; Khoái `3,4` | B `3,3`; đòn 1: B ở `3,3` chém `3,4` | đi 2 bước tới ô kề tướng rồi báo đòn |
| 2 | `bo_binh_ke_tuong_dung_yen.json` | B `3,3`; Khoái `3,4` | B `3,3` (không đi); đòn 1: chém `3,4` | đã đánh được thì đứng yên (ít bước nhất = 0) |
| 3 | `bo_binh_xa_khong_bao_don.json` | B `3,0`; Khoái `3,6` | B `3,2`; `bao_don: []` | không với tới: đi 2 bước về phía tướng, không báo đòn (câu 3) |
| 4 | `nham_tuong_gan_nhat.json` | B `3,1`; Khoái `0,1`; Lão `6,4` | B `1,1`; đòn 1: chém `0,1` | Khoái cách 3 bước, Lão cách 6: nhắm Khoái. Đứng `1,1` (2 bước) chứ không `0,0`/`0,2` (4 bước) |
| 5 | `hoa_nham_tuong_it_mau.json` | B `3,3`; Khoái `3,0` 3 máu; Lão `3,6` **2 máu** | B `3,5`; đòn 1: chém `3,6` | hai tướng cùng cách 3 bước: nhắm Lão vì ít máu hơn (câu 1), dù Khoái ở phía Bắc |
| 6 | `hoa_cung_mau_nham_phia_bac.json` | như #5 nhưng Lão 3 máu | B `3,1`; đòn 1: chém `3,0` | cùng bước, cùng máu: nhắm tướng phía Bắc (Khoái) |
| 7 | `hoa_o_dung_chon_phia_bac.json` | B `1,1`; Khoái `2,2` | B `2,1`; đòn 1: chém `2,2` | hai ô kề Khoái cùng 1 bước (`2,1` phía Bắc, `1,2` phía Tây): chọn ô phía Bắc hơn (câu 2) |
| 8 | `ky_binh_xung_phong_thang_hang.json` | K `0,0`; Khoái `4,3` | K `0,3`; đòn 1: K ở `0,3` xung phong hướng Đông | Kỵ binh đi 3 bước vào cùng hàng với Khoái, đường trống, báo xung phong |
| 9 | `ky_binh_bi_dong_doi_chan.json` | K `0,3`; B `3,3`; Khoái `4,3`; `thu_tu_dich: ["0,3", "3,3"]` | K `2,3`, không đòn; B `3,3`; đòn **1**: B chém `4,3` | Bộ binh chắn hàng nên Kỵ binh không xung phong được; ô cùng cột với Khoái quá xa (5 bước): đi tới ô gần Khoái nhất (`2,3`, đếm bước xuyên đồng đội: 2 bước), không báo đòn. Bộ binh kề Khoái đứng yên, đòn của nó là **số 1** vì Kỵ binh không có đòn |
| 10 | `thu_tu_theo_file_tran.json` | B `3,0`; B `5,2`; Khoái `3,3`; `thu_tu_dich: ["3,0", "5,2"]` | B `3,2`, B `4,3`; đòn 1: B ở `3,2` chém `3,3`; đòn 2: B ở `4,3` chém `3,3` | quân thứ nhất lấy ô `3,2`; quân thứ hai lẽ ra cũng chọn `3,2` (hòa với `4,3`, phía Bắc hơn) nhưng ô đã có quân nên đứng `4,3` |

- Kiểm lại từng bàn bằng tay theo "Thuật toán" trước khi viết `sau` (đếm bước, hòa). Ví dụ #9: từ `0,3` đi 3 bước tới được `1,3`, `2,3`, `0,0..0,6`, `1,2`… nhưng không tới ô nào của cột 4 hay hàng 3 phía Đông Khoái; ô `2,3` cách Khoái 2 bước (đi xuyên Bộ binh ở `3,3`), các ô khác ≥ 3.
- #9, #10 phải ghi `thu_tu_dich` trong `truoc` (bộ nạp đối chiếu với lớp `quan`; xem kịch bản cũ có `thu_tu_dich`). Kịch bản một quân Nguyên không cần.
- Tên file, `mo_ta` (một câu tiếng Việt) do dev viết theo bảng; nếu đếm tay ra khác bảng thì **dừng, ghi lại, hỏi** (bảng là đề xuất của AI, chưa duyệt).

**Lý do chưa đạt (Task 1.3 phải khớp):** chưa có pha chuẩn bị nên quân Nguyên đứng yên và không có đòn.

| # | Lý do trượt dự kiến |
|---|---|
| 1, 3–10 | bàn sau khác: quân Nguyên còn ở ô cũ (`sau: ô … mong đợi trống, thực tế B …`), và thiếu đòn |
| 2 | bàn sau khớp (B đứng yên), chỉ thiếu đòn: `sau: đòn 1 mong đợi …, thực tế không có đòn 1` |

### Định dạng `bao_don`

```json
"sau": {
  "dia_hinh": [...], "quan": [...], "hiep": 2,
  "bao_don": [
    { "thu_tu": 1, "quan": "3,3", "o": "3,4" },
    { "thu_tu": 2, "quan": "0,3", "huong": "D" }
  ]
}
```

- `quan` là ô chủ đòn **ở bàn sau** (bàn sau so theo ô, không theo id, như mọi kịch bản).
- `o` là ô bị nhắm (tuyệt đối, cho người đọc); runner so với `ô chủ đòn + offset`. Lưu trong `BattleState` vẫn tương đối (M1).
- Khóa này 2.7 (`don_dich/`) và 2.8, 2.9 dùng lại; 2.8 có thể cần `truoc.bao_don` (đòn có sẵn trước lệnh): **không** làm ở đây.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/rules_enemy_phase.gd` (12 dòng): chỉ `end_player_turn`. Thêm `prepare`, `begin_battle`.
- `src/core/pathfinding.gd` (45 dòng): `find_paths`, `_can_pass`. Thêm `distance_field`, dùng chung `_can_pass`.
- `src/core/battle_state.gd` (111 dòng): `clone()` chép từng trường; `validate()`. Thêm `telegraphs`, `enemy_intents` vào **cả hai**.
- `src/core/rules.gd` (32 dòng): `match command.kind`, khóa hết trận, kiểm kết cục cuối lệnh. Thêm nhánh `BEGIN_BATTLE`.
- `src/core/command.gd`, `src/core/battle_event.gd`: chỉ thêm vào **cuối** enum.
- `src/battle/battle_controller.gd` (127 dòng): thêm `begin()`, nhánh `_describe`, nhánh `match` sau `submit`.
- `src/app/main.gd`: chỗ mở trận (dòng ~116–121), `_show_board`, phần dev (dòng ~74–83).
- `src/debug/dev_tools.gd`: `MESSAGES`, `_unhandled_input`.
- `src/data/scenario_loader.gd` (443 dòng), `src/data/scenario_data.gd`, `tests/scenario_runner.gd`, `tests/scenario_viewer.gd`: như Task 1.1.
- **Phải giữ nguyên:** hủy nước đi một bước (`_undo_snapshot`); khóa hết trận; mọi kịch bản đã duyệt; `RulesMove` của tướng (không đổi `find_paths` theo cách làm lệch đường của tướng: chỉ **thêm** hàm).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm. AI tất định: **không số ngẫu nhiên**, không duyệt khóa Dictionary để quyết thứ tự.
- Điểm vào duy nhất `Rules.resolve`: mở trận cũng là một `Command` (`BEGIN_BATTLE`), không thêm hàm luật công khai thứ hai cho controller gọi.
- Chỉ `Effects.move` đổi vị trí: AI **không** gán `unit.cell`. `EnemyAI.plan` chỉ đọc.
- Chỉ `rules_enemy_phase.gd` và `rules_victory.gd` đổi `phase`.
- Đòn lưu tương đối (`owner_id` + `offset`), không lưu ô tuyệt đối (M1).
- `clone()` tự viết, sao chép sâu từng `Telegraph`, `EnemyIntent`; `Array.duplicate(true)` không sao chép object bên trong.
- Không lặp cứng cỡ bàn; dùng `state.size`.
- Chữ cho người đọc (công cụ duyệt, F3) qua `tr()`; lý do từ chối và log cho dev không qua `tr()`.
- F1/F2/F3/F5 không có tác dụng khi không bật dev.

### Testing

- `tools/test.sh` là lệnh duy nhất. Viết test trước, cho thấy đỏ, rồi mới code (ghi Debug Log). Với kịch bản, bước "đỏ" là 1.6; với test GUT, chạy đỏ riêng trước khi viết code.
- Lõi luật test thẳng (`BoardFixture` + `Rules.resolve` hoặc `RulesEnemyPhase.prepare`), mỗi ca so **dãy sự kiện** và `validate()` rỗng.
- Giao diện test qua `main.tscn` thật (`_make_level_main`); trận thử viết vào `user://` rồi xóa ở `after_each`. Phím bằng `InputEventKey` có `physical_keycode`.
- Điều kiện trước kiểm bằng đẳng thức, không `has()`.
- Phá thử mỗi lần một chỗ, chạy từng kịch bản riêng.
- Test cũ trượt vì quân Nguyên biết đi: sửa bố cục test (quân kề tướng thì đứng yên), không nới luật.

### Previous Story Intelligence (Story 2.1–2.5 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log giống nhau; làm khác Tasks thì ghi "Lệch so với Tasks"; task chụp ảnh phải có file ảnh, không thì bỏ [x].
- **File List đủ:** `game/i18n/text.vi.translation` nếu `text.csv` đổi; mọi `.uid` mới (`telegraph.gd`, `enemy_ai.gd`, `enemy_intent.gd`, `ai_intent_overlay.gd`, `test_enemy_ai.gd`).
- **Mục hoãn liên quan** (`deferred-work.md`): `UnitToken.update` cho quân đã đánh về màu Đại Việt (quân Nguyên chưa có cờ đánh: không đụng ở story này); `BattleView._on_end_turn` luôn bỏ chọn (giữ); `BattleController.undo` phát danh sách sự kiện rỗng (giữ); "Kịch bản có `ket_thuc_luot` không có quân Nguyên" (đúng như dự kiến, AC 13).
- **2.5:** `RulesVictory.check` gọi ở cuối `Rules.resolve`, chỉ khi có `DIED`/`DROWNED`: pha chuẩn bị ở story này không làm ai gục (đường AI không qua sông, chưa có hầm chông), nên không cần gọi thêm.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node, GUT bỏ qua cả file. GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **Mẫu đợt kịch bản:** viết kịch bản → commit → HALT → duyệt → trượt → code → xanh → commit (2.4, 2.5).

### Git Intelligence

- Commit gần nhất: `439dd68 Hoàn thiện Story 2.5 và thêm tư liệu asset`, `7c4cfaa Thắng và thua của trận Tiêu diệt (Story 2.5)`, `68bc517 Kịch bản kết cục trận chờ duyệt (Story 2.5)`, `8c70e77 Tạo story 2.5…`. Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- Cây làm việc có thay đổi ngoài story (hình E8 trong `img/`, `ban-giao-asset.md`): **không** gộp vào commit của story; commit riêng hoặc để tác giả quyết.
- Kịch bản hiện tại: 49 đã duyệt.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- Quy trình M3; **cấm** sửa hoặc xóa kịch bản đã duyệt; nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả (đã hỏi 3 câu; chỗ còn lại là "Quyết định mặc định" dưới, tác giả đổi được).
- **Thứ tự cố định B→Đ→N→T cho mọi hòa; không số ngẫu nhiên trong combat; duyệt quân theo `thu_tu_dich`, không theo khóa Dictionary.**
- **Đòn địch lưu tương đối; đòn trúng mọi phe** (2.8).
- Con số cân bằng chỉ trong `data/chi_so.json`.
- Bật dev bằng `--dev`; F3 chỉ khi dev.
- Commit khi xanh, lời commit tiếng Việt.

### Quyết định của tác giả (2026-10-21)

_Ba câu GDD chưa nói rõ. Tác giả chốt 2026-10-21._

1. **Hai tướng cùng số bước thì nhắm ai?** **ĐÃ CHỐT: tướng ít máu hơn**; máu bằng nhau thì tướng phía Bắc hơn, rồi phía Đông hơn. (Các phương án khác: chỉ theo phía Bắc/Đông; theo số tướng 1→2→3.)
2. **Nhiều ô đứng đánh trúng được thì đứng ô nào?** **ĐÃ CHỐT: ô cần ít bước đi nhất** (đang đánh được thì đứng yên); hòa thì phía Bắc hơn, rồi phía Đông hơn. (Phương án khác: theo phía của tướng B→Đ→N→T, không quan tâm số bước.)
3. **Không tới được ô đánh trúng thì có báo đòn không?** **ĐÃ CHỐT: không báo đòn**; chỉ đi tới ô gần tướng nhất. Số thứ tự chỉ đếm quân có đòn, liền nhau. (Phương án khác: vẫn chém/xung phong về phía tướng.)

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- **Hiệp 1 cũng có pha địch chuẩn bị** (GDD: hiệp = địch chuẩn bị → lượt người chơi → …). Bàn mở trận là bàn sau khi quân Nguyên đã đi. Hệ quả: trận thử `thu_*` phải xem lại (Task 5.1).
- "Gần" ở AC 8 tính bằng **số bước đi** như AC 6, không phải đường chim bay. Hòa ô gần nhất: ít bước đi hơn, rồi Bắc, rồi Đông.
- Tướng không có đường tới (bị sông vây kín) thì không xét; không có tướng nào thì đứng yên, không báo đòn.
- Kỵ binh xung phong không giới hạn khoảng cách, kể cả khi đứng kề mục tiêu. Đường thẳng bị chắn bởi quân (mọi phe), rừng, kho lương, làng; sông không chắn (FR19). Rừng/kho lương chặn **đòn đánh** khi ra đòn là 2.8 và 3.1; ở đây chỉ dùng cho AI chọn ô.
- Bộ chạy kịch bản không chạy pha chuẩn bị lúc mở bàn `truoc`; chỉ lệnh `ket_thuc_luot` chạy nó.
- Ý định F3 lưu trong `BattleState.enemy_intents` (đọc từ bản chụp như F1), không tính lại lúc bấm (tính lại sau khi quân đã đi sẽ ra kết quả khác).

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.6 (dòng 720–740), FR18, FR19, FR22, FR23; Story 2.7–2.9 (dùng `telegraphs`), 2.15 (Cung kỵ).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` "Action Economy" (dòng 180–207), "Enemy AI" (dòng 215–221), bảng quân Nguyên (dòng 175–177).
- `_bmad-output/planning-artifacts/game-architecture.md` M1 (Telegraph tương đối), "Tự đi" (quân Nguyên đi đường ngắn nhất, B→Đ→N→T), "Pha địch" bước 1b, "Mẫu trạng thái", "Công cụ debug" (F3), cây thư mục (`enemy_ai.gd`, `pathfinding.gd`, `telegraph.gd`, `tests/kich_ban/ai/`).
- `_bmad-output/project-context.md` (B→Đ→N→T, không ngẫu nhiên, clone sâu, M3).
- `_bmad-output/implementation-artifacts/2-5-mau-guc-thang-va-thua-tieu-diet.md` (mẫu story, review findings), `deferred-work.md`.

## Dev Agent Record

### Agent Model Used

### Debug Log References

- 2026-10-21 Task 1.1: khung xong (`Telegraph`, `BattleState.telegraphs` + clone/validate, `BoardText.DIRECTION_CODES`, `bao_don` trong loader/data/runner/viewer, 8 khóa `scenario.viewer.*`). `tools/test.sh`: 489/489 đạt, `49 đã duyệt · 0 chưa duyệt`.
- 2026-10-21 Task 1.3: 10 kịch bản `ai/`, `tools/test.sh`: 489/489 đạt, `Kịch bản luật: 49 đã duyệt · 10 chưa duyệt (10 chưa đạt)`. Lý do khớp bảng: #2 `sau: đòn 1 mong đợi quân ở 3,3 đánh ô 3,4, thực tế không có đòn 1`; 9 cái còn lại trượt ở ô quân Nguyên (còn ở ô cũ). Bàn sau đã kiểm bằng mô phỏng tay theo "Thuật toán" (khớp bảng cả 10).
- Lệch nhỏ so với Tasks: công cụ duyệt in "đánh ô" thay cho "chém ô" (một câu chung cho mọi đòn vào ô, Cung kỵ 2.15 dùng lại).
- 2026-10-21 Task 1.6: tác giả trả lời "đúng cả 10". Đổi `da_duyet: true`; `tools/test.sh` trượt đúng: `ai/bo_binh_ke_tuong_dung_yen.json: sau: đòn 1 mong đợi quân ở 3,3 đánh ô 3,4, thực tế không có đòn 1`.
- Task 2.9: sau khi có luật, 59/59 kịch bản đạt; 20 test GUT cũ trượt vì quân Nguyên giờ biết đi (14 ở `test_battle_view.gd`, 1 `test_main.gd`, 1 `test_rules_attack.gd`, 2 `test_rules_enemy_phase.gd`, 2 `test_scenario_loader.gd`), sau đó thêm 2 ở `test_loaders.gd` khi đổi trận thử. Sửa test (bố cục hoặc vị trí mong đợi theo luật), không nới luật. Không kịch bản cũ nào trượt.
- Task 2.10 phá thử (mỗi lần một chỗ, đã trả lại): (1) hòa mục tiêu Bắc trước máu → `ai/hoa_nham_tuong_it_mau.json` trượt; (2) bỏ "ít bước nhất" → `ai/ky_binh_bi_dong_doi_chan.json` trượt (Bộ binh 3,3 đi lên 4,2), cùng 2 test giao diện; (3) đánh số cả quân không báo đòn → `ai/ky_binh_bi_dong_doi_chan.json` trượt (`thừa đòn 2`); (4) Kỵ binh xung phong xuyên đồng đội → `ai/ky_binh_bi_dong_doi_chan.json` trượt; (5) duyệt quân ngược → `ai/thu_tu_theo_file_tran.json` trượt; (6) bỏ chép `telegraphs` trong `clone()` → `test_clone_copies_telegraphs_and_intents_deeply` và `test_begin_runs_enemy_prepare_once_and_emits` trượt.
- Số liệu mong đợi của test GUT AI kiểm bằng bộ mô phỏng Python viết lại luật (ngoài repo); 7 chỗ tính tay ban đầu sai đã sửa theo mô phỏng trước khi chạy.
- Ca "hòa ô gần nhất thì ít bước đi hơn": tìm 200.000 bàn ngẫu nhiên chỉ có sông, không ra ca nào; chỉ gặp khi có quân cùng phe chiếm ô. Bỏ test riêng, ca này nằm trong `test_walks_through_ally_but_never_stops_on_it`.
- Task 4–5: `tools/test.sh` 515/515 đạt, `Kịch bản luật: 59 đã duyệt · 0 chưa duyệt (0 chưa đạt)`. Chạy `tools/chay.sh --dev` (trận 1) và 7 trận thử, mỗi trận vài giây: log không có WARN, ERROR. Không bơm phím/chụp ảnh được (GoPeak không kết nối).

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Pha địch chuẩn bị chạy đầu mỗi hiệp, kể cả hiệp 1 (`BattleController.begin()` → lệnh nội bộ `BEGIN_BATTLE`, `main.gd` gọi ở mọi lần mở trận). `EnemyAI.plan` chọn mục tiêu và ô đứng theo đúng 3 câu tác giả chốt; `RulesEnemyPhase.prepare` cho quân đi từng ô qua `Effects.move` rồi tạo `Telegraph` tương đối, sự kiện `TELEGRAPHED`, lưu `EnemyIntent` cho F3. Bộ chạy kịch bản không gọi `begin()` nên bàn `truoc` giữ nguyên.
- F3 (dev): bảng chữ góc trên trái, mỗi quân Nguyên một dòng; cập nhật sau mỗi lệnh và khi nạp lại.
- Trận thử đổi bố cục để pha địch lúc mở trận không dời quân (bước tự test cũ vẫn đúng): `thu_lao` (sông 1,0 và 0,1 vây Bộ binh 0,0), `thu_keo` (Lão 2,0 kề Bộ binh 3,0; sông 6,4; sông 3,5, 2,6, 4,6 vây Bộ binh 3,6), `thu_thang` (Lão từ 0,6 sang 6,2, kề Bộ binh 5,2), `thu_co_lon` (Lão từ 0,7 sang 7,7, kề Bộ binh 8,7). `thu_ba_tuong`, `thu_co_nho`, `thu_day` để nguyên: quân Nguyên trong đó giờ đi lại gần tướng, các bước tự test cũ của Story 2.1 trên `thu_ba_tuong` không còn đúng từng ô.
- Trận 1 thật, hiệp 1 (theo luật, kiểm bằng mô phỏng): cả 3 Bộ binh nhắm **Lão** (Bộ binh 1,0 cách Khoái và Lão cùng 7 bước, cùng máu, cùng hàng: chọn phía Đông là Lão), đi 1,0→2,1, 5,0→4,1, 5,4→4,3; không quân nào với tới nên không báo đòn.

**Hướng dẫn tác giả tự test**

1. `tools/test.sh`: thấy `Kịch bản luật: 59 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ 515/515 test đạt`.
2. `tools/chay.sh --dev` (tắt bộ gõ VNI/Telex). Bàn mở ra: 3 Bộ binh **đã tiến lên** so với trước (đứng ở 2,1, 4,1, 4,3). Bấm `F1` để xem tọa độ nếu cần.
3. Bấm `F3`: góc trên trái hiện bảng "Ý định quân Nguyên (hiệp 1)", 3 dòng, mỗi dòng ghi Bộ binh đi từ đâu tới đâu, nhắm Phạm Ngũ Lão (kèm số bước), "không có ô đánh trúng trong tầm đi, đi tới ô gần nhất · không báo đòn".
4. Gõ `Space` (Kết thúc lượt): Bộ binh đi tiếp về phía Lão, bảng đổi thành "hiệp 2". Lặp vài lần: khi một Bộ binh tới được ô kề Lão, dòng của nó ghi "đứng đây vì đánh trúng được · đòn số 1". **Đòn chưa đánh** (Story 2.8) và **chưa có ô đỏ** (Story 2.7): Lão không mất máu.
5. Thử đi tướng ra chỗ khác rồi Kết thúc lượt: quân Nguyên đổi mục tiêu sang tướng gần hơn.
6. Bấm `F3` lần nữa: bảng ẩn. Bấm `F5`: trận mở lại từ hiệp 1, bảng vẫn giữ bật/tắt như trước.
7. Không bật dev (`tools/chay.sh`): `F3` không làm gì.
8. Trận thử `--tran=thu_lao`, `thu_keo`, `thu_thang`, `thu_co_lon`: quân Nguyên đứng yên lúc mở trận, các bước tự test của Story 2.3, 2.4, 2.5, 1.9 làm như cũ (chỉ khác: `thu_thang` có Lão ở 6,2; `thu_co_lon` có Lão ở 7,7).

### File List

- `game/src/core/telegraph.gd` (mới), `game/src/core/telegraph.gd.uid` (mới)
- `game/src/core/battle_state.gd`
- `game/src/data/board_text.gd`, `game/src/data/scenario_data.gd`, `game/src/data/scenario_loader.gd`
- `game/tests/scenario_runner.gd`, `game/tests/scenario_viewer.gd`, `game/tests/test_scenario_loader.gd`
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/kich_ban/ai/*.json` (10 file mới)
- `game/src/core/enemy_ai.gd`, `game/src/core/enemy_ai.gd.uid`, `game/src/core/enemy_intent.gd`, `game/src/core/enemy_intent.gd.uid` (mới)
- `game/src/core/pathfinding.gd`, `game/src/core/rules_enemy_phase.gd`, `game/src/core/rules.gd`, `game/src/core/command.gd`, `game/src/core/battle_event.gd`
- `game/src/battle/battle_controller.gd`, `game/src/app/main.gd`, `game/src/debug/dev_tools.gd`
- `game/src/debug/ai_intent_overlay.gd`, `game/src/debug/ai_intent_overlay.gd.uid` (mới)
- `game/data/tran/thu_lao.json`, `thu_keo.json`, `thu_thang.json`, `thu_co_lon.json`
- `game/tests/test_enemy_ai.gd`, `game/tests/test_enemy_ai.gd.uid`, `game/tests/test_ai_intent_overlay.gd`, `game/tests/test_ai_intent_overlay.gd.uid` (mới)
- `game/tests/board_fixture.gd`, `game/tests/test_rules_enemy_phase.gd`, `game/tests/test_battle_state.gd`, `game/tests/test_battle_controller.gd`, `game/tests/test_battle_view.gd`, `game/tests/test_main.gd`, `game/tests/test_rules_attack.gd`, `game/tests/test_loaders.gd`, `game/tests/test_dev_tools.gd`
- `_bmad-output/planning-artifacts/game-architecture.md`, `_bmad-output/implementation-artifacts/deferred-work.md`, `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-21: Tạo story; tác giả chốt 3 câu hỏi. Khung `bao_don` và 10 kịch bản `ai/` (tác giả duyệt cả 10). Enemy AI, pha địch chuẩn bị (cả hiệp 1), F3, đổi bố cục 4 trận thử. 515/515 test đạt, 59 kịch bản đạt.
- 2026-10-21 (code review): `prepare` đi hết cả bọn rồi mới báo đòn theo bàn cuối (Kỵ binh bị chắn thì không báo, reason về CLOSEST); `begin_battle` chỉ chạy một lần ở hiệp 1; `validate()` kiểm hình dạng đòn; bộ nạp `bao_don` chặn trùng `quan` và `o` không kề; `thu_ba_tuong`, `thu_co_nho`, `thu_day` đổi bố cục để quân Nguyên đứng yên lúc mở trận (`thu_day`: Bộ binh 2,2 → 2,3, Bộ binh 6,6 → 2,5, thêm sông 3,3; `thu_ba_tuong`: Bộ binh 1,0 → 0,5, Kỵ binh 5,0 → 2,5, Bộ binh 5,4 → 5,6; `thu_co_nho`: Bộ binh 1,0 → 0,3, Kỵ binh 4,0 → 4,4). `tools/test.sh`: 519/519 đạt. Còn chờ tác giả kiểm tay F3 trên `tran_01` và thử lại 3 trận trên (hướng dẫn tự test cũ của 2.1/2.2 không còn đúng từng ô).
