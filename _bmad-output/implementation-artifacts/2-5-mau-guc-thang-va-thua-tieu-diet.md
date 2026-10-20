---
baseline_commit: a38f181
---

# Story 2.5: Máu, gục, thắng và thua (Tiêu diệt)

Status: done

## Story

Là người chơi,
tôi muốn thấy rõ máu từng quân và biết khi nào thắng, thua,
để biết mình đang đứng ở đâu trong trận.

_Story luật thứ năm của E2. Cả ba tướng đã có đòn (2.1–2.4), nên đây là lúc trận có kết cục. Máu hiện trên đồng quân và quân hết máu bị nhấc khỏi bàn thì **đã làm từ trước** (Story 1.2, 2.1, 2.2); story này thêm phần còn thiếu: **kiểm thắng/thua, khóa trận khi hết, bảng "Thắng"/"Thua"**. Phần 1 chưa có hoạt ảnh: bảng hiện ngay._

_**Chưa có** (đừng làm ở đây): thua vì hết `so_hiep_toi_da` (3.5), thua vì Lòng dân về 0 (3.7), Giữ ải thắng ở hiệp 5 và thua vì quân Nguyên vào ô ải (3.11), pha địch ra đòn (2.6–2.9), màn chính và chuỗi trận (E4). Hàm kiểm thắng/thua viết sao cho các story đó chỉ việc thêm điều kiện._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 5 kịch bản mới ở Dev Notes "Đợt kịch bản 7" (`da_duyet: false`) và phần khung ở Task 1.1 (khóa `ket_qua` của `sau`, mã từ chối `tran_da_het`). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 44 đã duyệt · 5 chưa duyệt (4 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh ket_thuc`. Chưa duyệt xong thì không viết dòng code luật nào (`rules_victory.gd`, `rules.gd`, `battle_state.gd`).
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` **trượt** (kịch bản đã duyệt chưa đạt). Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 49 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh, `BattleState.validate()` rỗng;
   - **44 kịch bản đã duyệt cũ không bị sửa** (xem AC 10).
4. **Máu và gục (FR38), kiểm lại, không làm lại.** Mỗi đồng quân hiện số máu hiện tại; máu tụt thì số đổi ngay sau lệnh. Quân còn 0 máu bị nhấc khỏi bàn, **kể cả tướng** (không chiếm ô). Đã có sẵn: Task 3.1 chỉ thêm test cho chỗ chưa có test (xem Dev Notes "Đã có sẵn").
5. **Thắng (FR36).** **Cho** trận Tiêu diệt còn đúng một quân Nguyên. **Khi** quân đó gục (hết máu, hoặc chết đuối), **thì** lệnh đó sinh sự kiện `VICTORY` ở cuối danh sách, và `state.phase` là `WON`. Quân Nguyên gục mà vẫn còn quân Nguyên khác thì **không** có kết cục.
6. **Thua (FR36).** **Khi** mọi tướng trên bàn đều gục, **thì** sinh `DEFEAT` và `state.phase` là `LOST`. Số tướng lấy từ bàn lúc đó (trận 1–2 là 2 tướng), **không viết cứng 2 hoặc 3**. Tướng còn sống thì không thua, dù đã đi và đánh hết.
7. **Thắng được ưu tiên (FR38).** **Khi** quân Nguyên cuối và tướng cuối gục **trong cùng một lệnh**, **thì** kết cục là thắng (`VICTORY`, `WON`), không có `DEFEAT`.
8. **Kiểm sau mỗi lần có quân gục, ở mọi nơi (FR38).** `Rules.resolve` là chỗ duy nhất gọi kiểm tra, sau **mọi** lệnh có quân gục (lệnh đánh, và các lệnh sau này kể cả pha địch). Gục vì chết đuối cũng tính (sự kiện `DROWNED`, không phải `DIED`). Lệnh không có quân nào gục thì **không kiểm** (trận thử và kịch bản không có quân Nguyên từ đầu không bị thắng ngay).
9. **Khóa trận khi hết.** Khi `state.phase` đã là `WON` hay `LOST`, mọi lệnh (đi, đánh, kết thúc lượt) bị từ chối với mã **`tran_da_het`** (`Reject.BATTLE_OVER`), state giữ nguyên, **không** sinh thêm sự kiện kết cục. Hủy nước đi (`BattleController.undo`) cũng bị từ chối với cùng mã. _(Tác giả chốt câu 1 (a), 2026-10-20.)_
10. **Không phá luật đã duyệt.** Bộ chạy kịch bản chỉ kiểm kết cục khi `sau` có khóa `ket_qua`; kịch bản không ghi thì không kiểm (như `hiep`, `da_di`, `da_danh`). 44 kịch bản cũ không sửa một chữ. Nếu một kịch bản cũ trượt vì trận bị khóa giữa chừng, **dừng và hỏi tác giả**, không sửa kịch bản.
11. **Giao diện (theo câu 2).** Khi `phase` là `WON`: hiện bảng chữ lớn **"Thắng!"**; `LOST`: **"Thua!"**. Bảng nằm giữa bàn, **không che hết bàn** (người chơi vẫn nhìn được kết cục, nhất là cú đánh cuối), không nhận chuột (trừ nút nếu có). Hủy và Kết thúc lượt mờ. Chọn tướng, ô sáng, viền mục tiêu biến mất; bấm vào bàn không còn gửi lệnh. Chữ qua `tr()`.
12. **Nạp lại trận xóa bảng.** F5 (dev) hoặc nút nạp lại (theo câu 2) mở lại trận từ đầu: bảng ẩn, `phase` về `PLAYER`, mọi thao tác dùng được.
13. **Trận thử `thu_thang` (MỚI).** `tools/chay.sh --dev --tran=thu_thang` cho tác giả tự thắng trong **một lượt** (xem Dev Notes "Trận thử `thu_thang`"). Thua **chưa** thử bằng tay được (chưa có đòn địch, 2.8); AC 6, 7 chỉ có test GUT.
14. **Không có lỗi trong log** (không `ERROR`, `WARN`) khi chạy trận thử, thắng rồi bấm thử bàn.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt 2 câu hỏi** ở "Quyết định của tác giả" (2026-10-20: câu 1 chọn (a) khóa trận; câu 2 chọn (b) bảng chữ kèm nút "Chơi lại trận"). Các Task dưới đây viết đúng theo hai lựa chọn này.
- [x] **Task 1: Khung, đợt kịch bản 7, dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Khung (không phải code luật, làm trước để file kịch bản nạp được):
    - `src/core/battle_event.gd`: thêm `VICTORY`, `DEFEAT` vào **cuối** enum `Type` (sau `ATTACKED`) và hai hàm tạo `victory()`, `defeat()`; thêm `BATTLE_OVER` vào **cuối** enum `Reject`. Sửa chú thích đầu enum.
    - `tests/board_fixture.gd` (`describe`): nhánh mặc định `_` đã in tên loại, nên `VICTORY`, `DEFEAT` ra đúng chữ; kiểm lại, không sửa nếu đủ.
    - `tests/scenario_runner.gd` (`REJECT_EVENTS`): thêm `"tran_da_het": BattleEvent.Reject.BATTLE_OVER`. `src/data/scenario_loader.gd`: thêm `tran_da_het` vào `REJECT_CODES` (kèm khóa `scenario.viewer.reject_battle_over`), vào chuỗi liệt kê mã ở câu lỗi, và vào **mọi** lệnh trong `COMMAND_REJECTS` (di, danh, và lệnh kết thúc lượt nếu bảng có). `i18n/text.csv`: thêm `scenario.viewer.reject_battle_over,trận đã kết thúc (thắng hoặc thua)`; sinh lại `text.vi.translation`.
    - Khóa mới `ket_qua` của `sau` (không bắt buộc): `"dang_choi"`, `"thang"` hoặc `"thua"`. Thêm vào `AFTER_KEYS` của `scenario_loader.gd`; `ScenarioData` thêm `has_outcome`/`outcome` (như `da_di`); giá trị khác thì báo lỗi tiếng Việt kèm file và giá trị sai. `ScenarioRunner.compare` so với `state.phase` **chỉ khi có khóa**; `tests/scenario_viewer.gd` in thêm "kết quả: thắng" ở dòng "Sau lệnh".
    - `tests/test_scenario_loader.gd`: ca nạp `ket_qua` đúng (3 giá trị), ca giá trị sai, ca `tu_choi: "tran_da_het"`.
    - **Chưa** thêm `phase`, `mission`, `RulesVictory` (để Task 2): kịch bản nạp được nhưng chạy thì trượt.
  - [x] 1.2 Viết 5 file đúng như Dev Notes "Đợt kịch bản 7", `"da_duyet": false`, thư mục mới `tests/kich_ban/ket_thuc/`. Không đụng 44 kịch bản đã duyệt.
  - [x] 1.3 `tools/xem_kich_ban.sh ket_thuc`: đọc lại từng bàn trước/sau, khớp `mo_ta`; dòng `ket_qua` và `tu_choi` hiện đúng câu tiếng Việt. `tools/test.sh`: xanh, `44 đã duyệt · 5 chưa duyệt (4 chưa đạt)`, lý do khớp bảng. Ghi Debug Log.
  - [x] 1.4 Commit: `Kịch bản kết cục trận chờ duyệt (Story 2.5)`.
  - [x] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh ket_thuc`, đọc 5 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ ba điều:
    - hết trận thì **mọi lệnh bị từ chối** (kịch bản #5), theo câu 1;
    - **không có kịch bản "thua"**: chưa có đòn nào của địch, và tướng cuối không tự làm mình gục được bằng lệnh của người chơi; luật thua kiểm bằng test GUT (nói rõ để tác giả không tưởng bị bỏ sót);
    - kịch bản cũ không ghi `ket_qua` thì không bị kiểm kết cục.
    Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì xử lý theo AC 2. `tools/test.sh` **phải trượt**. Ghi Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật** (AC: 3–10)
  - [x] 2.1 `src/core/battle_state.gd`: thêm `enum Phase { ENEMY_PREPARE, PLAYER, ENEMY_ACT, END_OF_ROUND, WON, LOST }` (đúng kiến trúc "Mẫu trạng thái"; chỉ `PLAYER`, `WON`, `LOST` dùng ở story này, phần còn lại để 2.6–2.8 dùng) và `var phase: Phase = Phase.PLAYER`; `var mission: LevelData.Mission = LevelData.Mission.ELIMINATE`. `from_level` chép `level.mission`. **`clone()` chép cả hai** (luật "thêm thuộc tính thì thêm vào `clone()`"). Test `test_battle_state.gd`: clone giữ `phase` và `mission`; sửa bản sao không đổi bản gốc.
  - [x] 2.2 `src/core/rules_victory.gd` (MỚI, `RefCounted`, hàm `static`): `check(state, events)`:
    - không làm gì nếu `phase` đã là `WON` hay `LOST`;
    - không làm gì nếu `events` không có `DIED` hay `DROWNED` (AC 8);
    - **thắng trước**: `mission == ELIMINATE` và không còn quân Nguyên → `phase = WON`, thêm `BattleEvent.victory()`; rồi mới tới thua: không còn quân Đại Việt → `phase = LOST`, thêm `defeat()`. Cả hai cùng đúng thì chỉ thắng (AC 7);
    - đếm theo `faction` của quân còn trên `state.units`, không theo id, không viết cứng số tướng (AC 6);
    - viết thành các điều kiện nhỏ tách riêng (`_enemies_cleared`, `_generals_lost`) để 3.5, 3.7, 3.11 thêm điều kiện mà không sửa khung.
    - Đây là chỗ **duy nhất** đổi `phase` sang `WON`/`LOST` (kiến trúc: chỉ `rules_enemy_phase.gd` và `rules_victory.gd` đổi pha). `check_boundaries.sh` hiện chưa bắt phép gán `phase`: đừng thêm nếu không cần; chỉ đảm bảo không nơi nào khác gán `WON`/`LOST`.
  - [x] 2.3 `src/core/rules.gd`: đầu `resolve`, nếu `state.phase` là `WON` hay `LOST` thì trả một sự kiện `REJECTED` `BATTLE_OVER` (lý do cho dev: "trận đã kết thúc") và **không** chạy lệnh. Cuối `resolve` (sau `match`), nếu **không** bị từ chối thì gọi `RulesVictory.check(state, events)`. Một điểm vào, không gọi kiểm ở chỗ khác (không trong `Effects`).
  - [x] 2.4 `src/battle/battle_controller.gd`: `undo()` khi `phase` là `WON`/`LOST` trả `REJECTED BATTLE_OVER`, không phát signal, không đổi gì. (Thực tế bản chụp hủy đã xóa sau lệnh đánh, nhưng khóa rõ ràng để lệnh sau này, ví dụ hầm chông 3.4, không mở lỗ.) `submit` không cần sửa: lệnh bị từ chối đã được xử lý chung.
  - [x] 2.5 `src/core/battle_state.gd` `validate()`: thêm bất biến `phase == WON` thì không còn quân Nguyên **khi mission là ELIMINATE** (rỗng là đúng). Đừng thêm bất biến cho `LOST`: bàn mở đầu có thể chưa đủ tướng trong trận thử. Nếu thấy bất biến này làm hỏng test cũ vì lý do chính đáng thì bỏ và ghi lý do.
  - [x] 2.6 Chạy `tools/test.sh`; kịch bản mới phải đạt. **Test cũ trượt vì trận bị khóa giữa chừng** (ví dụ test GUT giết quân Nguyên cuối rồi chạy tiếp lệnh): sửa **test GUT** bằng cách thêm một quân Nguyên đứng xa, không phải nới luật. Kịch bản cũ trượt thì dừng, hỏi tác giả (AC 10).
  - [x] 2.7 **Phá thử** (mỗi lần một chỗ, ghi Debug Log, trả lại sau mỗi lần): bỏ kiểm `DROWNED` (kịch bản #2 phải trượt); đảo thứ tự thua trước thắng (test thắng ưu tiên phải trượt); bỏ khóa ở `Rules.resolve` (kịch bản #5 phải trượt); kiểm kết cục cả khi không có quân gục (một test GUT "không gục thì không kiểm" phải trượt); bỏ chép `phase` trong `clone()` (test clone phải trượt). Chạy từng kịch bản riêng (`tools/xem_kich_ban.sh`) để chắc mỗi lần phá trượt đúng kịch bản mong đợi, vì `test_scenarios` chỉ in kịch bản trượt đầu tiên.
- [x] **Task 3: Test GUT lõi luật** (AC: 4–9)
  - [x] 3.1 `tests/test_rules_victory.gd` (MỚI), dùng `BoardFixture`, mỗi ca so **dãy sự kiện** (cuối danh sách là `VICTORY`/`DEFEAT`) và `validate()` rỗng:
    - thắng khi quân Nguyên cuối gục vì sát thương; gục vì chết đuối (Dư kéo, Khoái đẩy); gục vì va chạm với quân Nguyên khác (cả hai gục, hết quân);
    - còn quân Nguyên thì chưa thắng, `phase` vẫn `PLAYER`, không có sự kiện kết cục;
    - **thua**: dựng trạng thái bằng `Effects.damage` trực tiếp lên từng tướng (test được phép; chỉ `src/` bị `check_boundaries.sh` chặn), rồi gọi `RulesVictory.check(state, events)` với danh sách sự kiện của lần giết đó. Ca: 2 tướng, một gục thì chưa thua; cả hai gục thì `DEFEAT`; **1 tướng** và **3 tướng** (không viết cứng số tướng);
    - thắng và thua cùng lúc: dựng bằng `Effects.damage` lên quân Nguyên cuối và tướng cuối rồi `check`: chỉ `VICTORY`, không `DEFEAT`; đổi thứ tự hai lần giết (tướng trước, địch trước): kết quả như nhau;
    - lệnh không có quân gục không kiểm: bàn không quân Nguyên từ đầu, tướng đi một bước: `phase` vẫn `PLAYER`;
    - `mission = HOLD_PASS`: hết quân Nguyên **không** thắng (nhưng hết tướng vẫn thua);
    - **khóa:** sau thắng, `Command.move`, `Command.attack`, `Command.end_turn` đều `REJECTED BATTLE_OVER`, `BoardFixture.picture` giữ nguyên, không thêm `VICTORY` lần hai; sau thua cũng vậy;
    - tướng gục (hết máu) bị nhấc khỏi bàn, ô trống đi vào được (AC 4: chưa có test cho tướng).
  - [x] 3.2 `tests/test_battle_controller.gd`: `undo()` sau thắng trả `REJECTED BATTLE_OVER` và không phát `events_resolved`; `submit` lệnh bị khóa không phát signal, `can_undo()` giữ nguyên.
  - [x] 3.3 Kiểm `grep -rn "Type\.\|Reject\." game/tests game/src` mọi chỗ duyệt hay `match` trên `BattleEvent.Type`/`Reject`: chữ mô tả của công cụ duyệt cho `BATTLE_OVER` ra đúng; không có `match` nào bị thiếu nhánh mà âm thầm bỏ qua.
- [x] **Task 4: Giao diện** (AC: 4, 11, 12)
  - [x] 4.1 `src/ui/result_banner.gd` (MỚI): `Control` dựng bằng code như `Hud`; nhãn lớn giữa bàn (`BoardView.AREA`), ẩn mặc định; `show_result(phase)` hiện "Thắng!" hoặc "Thua!" (`tr("result.won")`, `tr("result.lost")`); `hide_result()`. Không nhận chuột (`mouse_filter` bỏ qua). Màu chữ theo màu sẵn có của dự án (đọc `hud.gd`, theme), không số màu tự đặt mới nếu có hằng; bảng có nền bán trong suốt để nhìn xuyên xuống bàn. Nếu tác giả chọn câu 2 (b): thêm nút "Chơi lại trận" phát signal `retry_pressed`, `focus_mode` là `FOCUS_NONE` (như nút của `Hud`).
  - [x] 4.2 `src/app/main.gd`: tạo bảng sau `Hud` (nằm trên bàn), trong `_on_events_resolved` đọc `snapshot.phase`: `WON`/`LOST` thì hiện bảng, ngược lại ẩn. `_start_battle` ẩn bảng trước khi dựng trận (F5 xóa bảng, AC 12). Nếu nút có: nối `retry_pressed` với `_start_battle` (cùng logic F5, không bật bằng dev).
  - [x] 4.3 `src/battle/battle_view.gd`: trong `_on_events_resolved`, khi `snapshot.phase` là `WON`/`LOST` thì `_deselect()` và không chọn lại; `_on_cell_clicked`, `_on_general_key`, `_on_end_turn` không gửi lệnh khi trận hết (dùng một hàm nhỏ `_battle_over()` đọc `snapshot().phase`); `_update_hud` mờ cả Hủy và Kết thúc lượt khi hết. `src/ui/hud.gd`: `show_turn` nhận thêm cờ `over` (mặc định false) làm mờ `end_turn_button`; đổi chữ ký thì sửa mọi chỗ gọi và test.
  - [x] 4.4 `i18n/text.csv`: thêm `result.won,Thắng!`, `result.lost,Thua!` (và `result.retry,Chơi lại trận` nếu có nút); sinh lại `text.vi.translation`. Khóa theo mẫu `<màn>.<mục>`.
  - [x] 4.5 `tests/test_battle_view.gd` (qua `main.tscn` thật, trận thử viết vào `user://` rồi xóa ở `after_each`, phím và chuột bằng sự kiện thật). Bố cục: Khoái, một Bộ binh kề, sông sau Bộ binh (thắng bằng một đòn). Các ca, mỗi ca kiểm cả điều kiện trước (bằng đẳng thức, không `has()`):
    - trước: bảng ẩn, `selected_id()` là `NONE`; sau khi đánh quân cuối: bảng hiện chữ `tr("result.won")`; `selected_id()` là `NONE`; `target_cells()` rỗng;
    - sau thắng: bấm một ô sáng cũ và bấm tướng không gửi lệnh (`snapshot()` giữ nguyên; kiểm bằng đồng quân không dời), nút Hủy và Kết thúc lượt mờ, gõ Space không đổi hiệp;
    - máu đổi ngay: trận hai quân Nguyên, Khoái đánh một quân (3 → 1 máu): `_token(main, id).hp_text()` là `"1"` ngay sau lệnh (AC 4; nếu test tương tự đã có từ 2.1 thì tái dùng, chỉ ghi lại);
    - F5 (dev) sau thắng: bảng ẩn, `phase` về `PLAYER`, đồng quân trở lại bố cục đầu. Nút "Chơi lại trận" nếu có: cùng kết quả.
    - Không có thao tác nào dựa vào hoạt ảnh (Phần 1 chưa có).
  - [x] 4.6 Phá thử giao diện (mỗi lần một chỗ, ghi Debug Log): bỏ `_deselect()` khi hết trận; bỏ ẩn bảng trong `_start_battle`; bỏ `_battle_over()` ở `_on_cell_clicked`: mỗi lần phải có một test giao diện trượt.
- [x] **Task 5: Trận thử `thu_thang`** (AC: 13)
  - [x] 5.1 `game/data/tran/thu_thang.json` (MỚI) đúng bố cục ở Dev Notes "Trận thử `thu_thang`". Không đổi `tran_01.json` và các trận thử cũ.
  - [x] 5.2 `tests/test_loaders.gd`: thêm `test_real_win_trial_level_loads` theo mẫu `test_real_pull_trial_level_loads`: không lỗi, không cảnh báo, **so đủ ô và loại của mọi quân**, kiểm ô sông. Thêm một test chơi thật trên chính file này (nạp `thu_thang.json`, chạy hai lệnh: Khoái đẩy, Dư kéo) kết thúc `WON`; test dùng file thật nên sửa file trận thì test báo.
- [x] **Task 6: Tài liệu và kiểm tay** (AC: 3, 13, 14)
  - [x] 6.1 `game-architecture.md`: thêm `thu_thang.json` vào cây `data/tran/`, `result_banner.gd` vào cây `ui/`, `rules_victory.gd` đã có trong cây (kiểm); bảng thứ tự phân giải: dòng kiểm thắng/thua đặt **sau** lệnh, và "thắng trước thua". Nếu sai lệch với kiến trúc (ví dụ đã đặt tên khác) ghi vào "Lệch so với Tasks".
  - [x] 6.2 `epics.md` Story 2.5: không sửa tiêu chí; nếu quyết định của tác giả (câu 1, 2) làm đổi nghĩa tiêu chí thì ghi chú một dòng.
  - [x] 6.3 _(Tác giả tự kiểm tay AC 13 và 14 (2026-10-20), đạt. Không có ảnh trong `anh/` vì GoPeak không kết nối.)_ Kiểm bằng mắt: chạy `tools/chay.sh --dev --tran=thu_thang` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action` cho phím, `inject_mouse_click` theo pixel của công thức hiện hành (bàn 7×7 giữ `board.position = (262, 139)`; **tính lại từ Debug Log 2.3, không đoán**). Làm theo "Hướng dẫn tác giả tự test", `capture_screenshot` sau mỗi bước chính, lưu `_bmad-output/implementation-artifacts/anh/2-5-*.png` (ít nhất: sau khi Khoái đẩy xuống sông còn một quân Nguyên chưa có bảng; sau khi Dư kéo xuống sông hiện "Thắng!"). Tắt game. Log không có ERROR/WARN. GoPeak không kết nối được thì **bỏ dấu [x] và ghi rõ chờ tác giả kiểm tay** (review 2.3 và 2.4 đã bắt lỗi ghi [x] mà thiếu ảnh).
  - [x] 6.4 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, trận thử, tài liệu, `.uid` mới (cho `rules_victory.gd`, `result_banner.gd`, `test_rules_victory.gd`), `game/i18n/text.vi.translation`. Ví dụ: `Thắng và thua của trận Tiêu diệt (Story 2.5)`.
  - [x] 6.5 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, dùng kết quả thật (số test thật).

## Dev Notes

### Bối cảnh

- **Đã có từ trước (không làm lại):** `Effects.damage` trừ máu, nhấc quân hết máu khỏi bàn (tướng cũng bị nhấc, theo kiến trúc "Gục, thắng, thua") và ghi `DIED`; `Effects.move` cho quân Nguyên chết đuối và ghi `DROWNED`. `UnitToken.update` cập nhật số máu mỗi lần `BoardView._sync_tokens`; token của quân đã gục bị bỏ. Hai thứ này xong ở Story 1.2, 2.1, 2.2.
- `Effects.damage` có ghi chú "Kiểm thắng/thua: Story 2.5": story này **không** gọi kiểm từ trong `Effects` (xem mục "Chỗ gọi kiểm" dưới); sửa câu ghi chú cho đúng ("kiểm thắng/thua ở `Rules.resolve`, `RulesVictory.check`").
- **Chưa có:** `BattleState.phase`, `BattleState.mission`, `RulesVictory`, sự kiện `VICTORY`/`DEFEAT`, mã `tran_da_het`, bảng kết cục. Mọi thứ khác ở "Chưa có" đầu story.
- Đòn địch và pha địch (2.6–2.9) chưa có: **trong E2 chưa có đường nào làm tướng cuối gục**: Khoái đẩy chỉ làm quân bị đẩy mất máu; Lão phóng lao trúng tướng mình chỉ làm tướng *khác* mất máu; Dư kéo không gây sát thương và dừng sát Dư. Tướng cuối không tự làm mình gục. Vì vậy **không có kịch bản "thua"**, và AC 6, 7 kiểm bằng test GUT dựng trạng thái thẳng bằng `Effects.damage`. Hầm chông (3.4), đòn địch (2.8) sẽ mở đường thua thật; lúc đó thêm kịch bản "thua" ở story của chúng.
- Trận 1 (`tran_01.json`, Tiêu diệt, 2 tướng, 3 Bộ binh) **thắng được bằng tay** ở story này: 3 Bộ binh đứng yên (chưa có AI). Tác giả có thể thử thắng ở trận 1 thật, mất vài hiệp, nhưng `thu_thang` nhanh hơn.

### Chỗ gọi kiểm

- Gọi ở **cuối `Rules.resolve`**, một lần mỗi lệnh. Lý do: một lệnh có thể gục nhiều quân (va chạm, đòn nối); kết cục xét theo **trạng thái cuối lệnh** thì "thắng trước thua" đúng mà không cần giữ kết cục tạm. Gọi từ `Effects` sau mỗi lần gục sẽ cho `LOST` rồi lại phải đổi thành `WON` trong cùng một va chạm.
- Phần "cả trong pha địch" (AC 8, epics): pha địch ra đòn (2.8) chạy bên trong `Rules.resolve` (`END_TURN`), nên **cùng một chỗ gọi** bao phủ nó. Story 2.8 phải gọi thêm `RulesVictory.check` **sau từng đòn địch** (để quân địch còn lại không đánh tiếp khi trận đã hết) bằng cách truyền danh sách sự kiện của riêng đòn đó; đặt chú thích ở `rules_victory.gd` và ghi vào `deferred-work.md` ("2.8: gọi `RulesVictory.check` sau từng đòn địch, dừng khi `phase` hết").
- `check` đọc `events` để biết có quân gục hay không: dựa vào `DIED`/`DROWNED` là đủ vì mọi quân rời bàn đều đi qua `Effects` và để lại một trong hai sự kiện. Loại sự kiện gục mới thêm sau này (ví dụ tiếp viện) phải cập nhật hàm này.

### Mã từ chối mới `tran_da_het`

- Khóa trận là luật mới chưa có trong GDD: **đã đưa vào câu hỏi 1** cho tác giả. Mã đặt theo thói quen tiếng Việt không dấu của các mã cũ (`da_danh_roi`, `khong_con_nuoc_di`).
- Khóa nằm ở `Rules.resolve` (một điểm vào) và `BattleController.undo` (không đi qua `Rules.resolve`). Không để UI tự khóa mà luật thì không khóa: UI chỉ làm cho người chơi khỏi thấy nút bấm được.

### Đợt kịch bản 7

Thư mục mới `tests/kich_ban/ket_thuc/`. Mọi kịch bản `"da_duyet": false` lúc viết. Quy ước bàn cờ chữ như các đợt trước (dòng `.` là ô trống; xem `tests/kich_ban/keo/keo_cach_3_o.json` làm mẫu); `ket_qua` ghi trong `sau`. Bàn 7×7 trừ khi ghi khác. Tướng `1` Nguyễn Khoái, `3` Trần Khánh Dư, `B` Bộ binh 3 máu, `~` sông. Khoái sát thương và đẩy theo `chi_so.json` (kiểm số liệu trong file trước khi viết `sau`: Bộ binh mất 2 và bị đẩy 1 ô, 3 → 1 máu, như kịch bản 2.1).

| # | Tên file | Trước | Hành động | Sau | Ý nghĩa |
|---|---|---|---|---|---|
| 1 | `dich_con_lai_chua_thang.json` | Khoái; hai Bộ binh; sông sau Bộ binh thứ nhất | Khoái đánh Bộ binh thứ nhất (bị đẩy xuống sông, chết đuối) | còn Bộ binh thứ hai nguyên máu, `da_danh: ["1"]`, `ket_qua: "dang_choi"` | quân Nguyên gục mà vẫn còn quân khác: chưa có kết cục |
| 2 | `thang_dich_cuoi_chet_duoi.json` | Dư; một Bộ binh cách 3 ô cùng hàng, sông ở ô kề Dư | Dư kéo Bộ binh (kéo 2 ô vào sông, chết đuối) | không còn quân Nguyên, `da_danh: ["3"]`, `ket_qua: "thang"` | quân Nguyên cuối gục vì **chết đuối** (sự kiện `DROWNED`, không phải `DIED`): vẫn thắng |
| 3 | `thang_dich_cuoi_het_mau.json` | Khoái; một Bộ binh **1 máu** kề (trong `truoc` ghi máu 1 bằng khóa `mau` như các kịch bản cũ) | Khoái đánh Bộ binh | không còn quân Nguyên, `ket_qua: "thang"` | quân Nguyên cuối gục vì **hết máu** (`DIED`): thắng, và không có bước đẩy (mục tiêu gục thì không đẩy, luật 2.1) |
| 4 | `thang_khi_hai_dich_cung_gac.json` | Khoái; Bộ binh **3 máu** kề; Bộ binh **1 máu** đứng sát sau nó, cả ba thẳng hàng | Khoái đánh Bộ binh kề (còn 1 máu, bị đẩy vào Bộ binh sau: va chạm, cả hai mất 1 máu) | không còn quân Nguyên, `ket_qua: "thang"` | hai quân Nguyên gục trong **một** lệnh (cùng lúc, bằng va chạm): hết quân là thắng. Số liệu (Khoái gây 2, va chạm 1) kiểm với `chi_so.json` và kịch bản 2.1 `va_cham/`; nếu lệch thì chỉnh máu trong bố cục, không đổi luật |
| 5 | `het_tran_khoa_lenh.json` | như #3 nhưng có thêm Lão `2` (chưa đánh) | #1 Khoái đánh Bộ binh (thắng); #2 Lão đi tới một ô trống bất kỳ | sau lệnh #2 không đổi gì: `tu_choi: "tran_da_het"` ở bước 2; `ket_qua: "thang"` | hết trận thì lệnh sau bị từ chối, bàn giữ nguyên |

- #1 và #2: bàn có sông phải ghi trong `dia_hinh` (cả `truoc` và `sau`).
- #5: bước 2 có `"tu_choi": "tran_da_het"` theo quy ước lệnh bị từ chối; `sau` là bàn **sau bước 1** (bước 2 không đổi gì).
- Tên file, `mo_ta` (một câu tiếng Việt) và đúng số liệu máu do dev viết theo mẫu; **chép đúng cấu trúc từ `keo_cach_3_o.json`** (khóa `phien_ban_dinh_dang`, `mo_ta`, `da_duyet`, `truoc`, `hanh_dong`, `sau`).
- Kịch bản "thua", "thắng và thua cùng lúc": **không viết** (không đạt được bằng lệnh thật, xem Bối cảnh); đã nêu cho tác giả ở Task 1.5.

**Lý do chưa đạt (Task 1.3 phải khớp):** trước khi có `phase`/`RulesVictory`, bộ chạy không có chỗ so `ket_qua`, nên:

| # | Lý do trượt dự kiến |
|---|---|
| 1 | `sau.ket_qua` "dang_choi" nhưng bộ chạy chưa đọc được trạng thái kết cục (thiếu `state.phase`): báo không so được, hoặc trượt ở so kết cục |
| 2, 3, 4 | `ket_qua` mong "thang" nhưng thực tế "dang_choi" (chưa có luật thắng) |
| 5 | bước 2 mong `tran_da_het` nhưng lệnh chạy được (chưa có khóa) |

_(Dev ghi lý do thật vào Debug Log; nếu khác bảng thì giải thích. Nếu #1 lại đạt vì "chưa có phase" không ảnh hưởng, ghi `5 chưa duyệt (4 chưa đạt)` và sửa số ở AC 1 cho khớp, đừng ép #1 trượt bằng thủ thuật.)_

### Trận thử `thu_thang`

Bàn 7×7, Tiêu diệt, 2 quân Nguyên (một tướng Khoái đẩy, một Dư kéo; cả hai chết đuối trong **một** lượt):

```
Địa hình                   Quân
. . . . . . .              . . . . . . .
. . . . . . .              . . . . . . .
. . . ~ . . .              . 1 B . . B .
. . . . . . .              . . . . . . .
. . . . . ~ .              . . . . . . .
. . . . . . .              . . . . . 3 .
. . . . . . .              . . . . . . .
```

- Khoái `1` ở `1,2`; Bộ binh `2,2` kề Đông, sông `3,2` ngay sau: Khoái đánh thì Bộ binh mất 2 máu, bị đẩy 1 ô vào sông và chết đuối (`DAMAGED`, `MOVED`, `DROWNED`). Quân Nguyên còn lại: `5,2`.
- Dư `3` ở `5,5`; sông `5,4` kề Dư; Bộ binh `5,2` cách 3 ô cùng cột (đường `5,4`, `5,3` trống): Dư kéo 2 ô, quân vào `5,3` rồi `5,4` (sông) và chết đuối.
- `thu_tu_dich`: `["2,2", "5,2"]`. `tiep_vien: []`, `muu_ke_mo: []`, `long_dan: 3` nếu trận thử khác có (dev chép đúng khóa bắt buộc từ `thu_keo.json`, `thu_lao.json`).
- Thứ tự an toàn: **đánh quân `2,2` trước** (còn quân `5,2`: không thắng, không bảng); **rồi Dư kéo `5,2`** (hết quân: "Thắng!"). Đánh `5,2` trước cũng được, kết quả như nhau: đây là hai đòn độc lập.
- Dư đứng sát quân cuối chưa được: nhưng ở bố cục này quân cuối cách 3 ô nên kéo được ngay, không cần đi.
- Có tướng `2` (Lão) hay không tùy dev; không cần cho trận thử này.
- Test giao diện ở Task 4.5 dùng bố cục gần giống trong `user://`: không đọc file này, để tác giả sửa trận thử thoải mái.

### Hướng dẫn tác giả tự test (mẫu, dev ghi lại bằng kết quả thật ở Completion Notes)

1. `tools/test.sh`: thấy `Kịch bản luật: 49 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ … test đạt`.
2. `tools/chay.sh --dev --tran=thu_thang` (tắt bộ gõ VNI/Telex). Mở lên: 2 quân Nguyên (Bộ binh), mỗi quân hiện số 3 máu. Chưa có chữ "Thắng!" hay "Thua!".
3. Gõ `1`, bấm vào Bộ binh `2,2` (viền trắng): quân bị đẩy xuống sông và biến mất. **Chưa** có bảng "Thắng!" vì còn một Bộ binh.
4. Gõ `3`, bấm vào Bộ binh `5,2`: Dư kéo, quân rơi xuống sông. Hiện **"Thắng!"** ngay giữa bàn, bàn vẫn nhìn thấy; nút Hủy và Kết thúc lượt mờ.
5. Bấm thử các ô, các tướng, gõ `Space`, `Z`: không gì xảy ra.
6. (Dev) Bấm `F5`: trận mở lại từ đầu, hết bảng, chơi tiếp được.
7. **Thua chưa thử bằng tay được** (chưa có đòn địch, Story 2.8). Kiểm bằng test.
8. (Tùy) Trận 1 thật: `tools/chay.sh --dev`. Chơi tới khi hạ 3 Bộ binh, hiện "Thắng!".

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/battle_state.gd` (96 dòng): `clone()` chép từng trường; thêm `phase`, `mission` vào đó. `from_level` dựng quân; `validate()` kiểm bất biến.
- `src/core/rules.gd` (16 dòng): `match command.kind`; thêm khóa đầu và kiểm cuối. Một lệnh `END_TURN` đang gọi `RulesEnemyPhase.end_player_turn`: sau story này nó phải bị khóa khi trận hết.
- `src/core/battle_event.gd`: `Type` kết thúc ở `ATTACKED`; `Reject` ở `NOT_IN_RANGE`. Chỉ thêm vào cuối enum (kịch bản và công cụ duyệt có thể lưu theo tên, nhưng giữ thứ tự vẫn an toàn hơn).
- `src/core/effects.gd`: chỉ sửa câu ghi chú, không sửa logic.
- `src/battle/battle_controller.gd`: chỉ thêm khóa ở `undo()`.
- `src/battle/battle_view.gd`, `src/ui/hud.gd`, `src/app/main.gd`: như Task 4.
- `src/data/scenario_loader.gd`, `src/data/scenario_data.gd`, `tests/scenario_runner.gd`, `tests/scenario_viewer.gd`, `tests/board_fixture.gd`: như Task 1.1.
- **Phải giữ nguyên:** hành vi `UnitToken`/`BoardView._sync_tokens` (không sửa); hủy nước đi một bước; mọi kịch bản đã duyệt; `test_determinism` (mỗi kịch bản chạy hai lần kết quả giống hệt).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm.
- Một điểm vào: `Rules.resolve(state, command)`. Luật mới ở `rules_<mảng>.gd` đúng mảng: kiểm thắng/thua là `rules_victory.gd` (đã có trong cây thư mục kiến trúc).
- Chỉ `Effects.damage` / `Effects.move` đổi máu và vị trí; `RulesVictory` **không** đổi máu hay vị trí, chỉ đổi `phase` và thêm sự kiện.
- Chỉ `rules_enemy_phase.gd` và `rules_victory.gd` được đổi `phase`.
- Thứ tự cố định B→Đ→N→T cho mọi trường hợp hòa; duyệt quân theo `state.units` (đã có thứ tự), không theo khóa Dictionary. Không `float`.
- Số tướng lấy từ `state.units` lúc đó, không `range(2)`, không `3`.
- UI không sửa `BattleState`; chỉ đọc bản chụp; lệnh đi qua `submit()`. `Hud` và `ResultBanner` chỉ nhận dữ liệu qua hàm, không giữ trạng thái trận.
- Lý do từ chối là chữ cho dev, không qua `tr()`. Chữ cho người chơi ("Thắng!", "Thua!") và chữ công cụ duyệt qua `tr()`.
- Lỗi dữ liệu (`ket_qua` sai) là `LoadResult` có câu tiếng Việt kèm file và giá trị sai; không `assert`.
- Sau mỗi lần phân giải trong test, `state.validate()` rỗng.

### Testing

- `tools/test.sh` là lệnh duy nhất. Viết test trước, cho thấy đỏ, rồi mới code (ghi Debug Log). Với kịch bản, bước "đỏ" là bước 1.6; với test GUT, **chạy đỏ riêng trước khi viết code** (review 2.4 bắt lỗi bỏ bước này).
- Lõi luật test thẳng (`BoardFixture` + `Rules.resolve`), mỗi ca so **dãy sự kiện** và `validate()` rỗng, không chỉ bàn sau (review 2.2).
- Giao diện test qua `main.tscn` thật (`_make_level_main`), phím bằng `InputEventKey` có `physical_keycode`, chuột bằng sự kiện thật (`_click_by_mouse`). Trận thử viết vào `user://` rồi xóa ở `after_each`.
- Điều kiện trước kiểm **bằng đẳng thức**, không `has()` (review 2.2). Kiểm cả `_view()` lẫn `_board()` khi liên quan đến ô sáng.
- "Không có lệnh nào được gửi" chỉ chứng minh được bằng thứ không đổi được **nếu lệnh bị từ chối** (số hiệp không tăng, đồng quân không dời, đồng không xám), vì `can_undo()` false đúng cả khi lệnh bị từ chối (review 2.4). Đừng dùng `can_undo()` đơn độc.
- Phá thử **mỗi lần một chỗ**, và chạy từng kịch bản riêng để chắc mỗi lần phá trượt đúng kịch bản (review 2.4: `test_scenarios` chỉ in kịch bản trượt đầu tiên).
- Test cũ trượt vì trận bị khóa: thêm một quân Nguyên đứng xa vào test, không nới luật, không sửa kịch bản đã duyệt.
- Ca "ngoài bàn" hay ca biên nào cũng phải thật sự kiểm đúng nhánh định kiểm (review 2.4: ca `(1,-1)` bị chặn bởi nhánh khác).

### Previous Story Intelligence (Story 2.1–2.4 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log giống nhau; mọi chỗ làm khác Tasks ghi vào "Lệch so với Tasks"; task chụp ảnh thì phải có file ảnh, không thì bỏ [x] (review 2.3 và 2.4 bắt hai lần).
- **File List đủ:** `game/i18n/text.vi.translation` phải có nếu `text.csv` đổi; mọi file `.uid` mới.
- **Bộ chạy kịch bản bỏ qua tướng đã gục khi so `da_danh`/`da_di`** (`deferred-work.md`, 2.1 và 2.2): kịch bản `va_cham/tuong_minh_guc_vi_va.json` có tướng gục. Story này không sửa, nhưng **đừng làm nó tệ hơn**; nếu `ket_qua` giúp kiểm tướng gục tiện hơn, ghi nhận vào `deferred-work.md`.
- **Mục hoãn liên quan:** `ForcedMove.OBSTACLES` tách khỏi `Terrain.WALKABLE`; `BattleView._on_target_clicked` không kiểm tướng đang chọn còn trên bàn ("xem lại khi pha địch có đòn"). Khi tướng có thể gục giữa hai cú bấm (2.8), phải xử; ở story này `_battle_over()` đã chặn, nhưng chưa phải ca "tướng đang chọn gục".
- **Phím thật:** `InputEventKey` với `physical_keycode`. GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node, GUT bỏ qua cả file.
- **Mẫu đợt kịch bản:** story 2.4 (`2-4-tran-khanh-du-keo.md`) làm đúng mẫu "viết kịch bản → commit → HALT → duyệt → trượt → code → xanh → commit". Làm lại đúng như vậy.
- **Số liệu máu** trong kịch bản phải kiểm lại với `chi_so.json` và kịch bản cũ của 2.1; đừng đoán.

### Git Intelligence

- Commit gần nhất: `a38f181 Trần Khánh Dư kéo (Story 2.4)`, `6cba693 Kịch bản Trần Khánh Dư kéo chờ duyệt`, `d90da8e Story 2.4: tác giả chốt 3 câu hỏi`, `94ad44f Tạo story 2.4`. Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- Mẫu cho story luật: commit "kịch bản … chờ duyệt", rồi commit code khi xanh, rồi (nếu có) commit "Sửa theo code review Story X.Y; xong Story X.Y".
- Tổng test hiện tại: 447/447; kịch bản 44 đã duyệt (sau code review 2.4).

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- Quy trình M3: AI viết kịch bản `da_duyet: false` → tác giả duyệt → test trượt → code. **Cấm** sửa hoặc xóa kịch bản đã duyệt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả, không tự đoán (câu 1, 2 dưới đây).
- **Kiểm thắng/thua sau mỗi lần có quân gục; thắng được ưu tiên khi cùng lúc; số tướng do file trận quy định, thua khi mọi tướng trên bàn gục, không viết cứng số 3.**
- Đẩy/kéo đi từng ô qua `ForcedMove.run`. Chỉ `Effects.damage` / `Effects.move` đổi máu và vị trí.
- Con số cân bằng chỉ trong `data/chi_so.json`; chữ hiển thị chỉ qua `tr()`, khóa `<màn>.<mục>`.
- Không `assert` cho lỗi dữ liệu; `assert` chỉ cho lỗi lập trình.
- Không lặp cứng cỡ bàn (`range(7)`); dùng `level.size`.
- Bật dev bằng `--dev`; `--tran=` chỉ có tác dụng khi bật dev. F5 chỉ khi dev.
- Mọi thao tác làm được bằng một cú bấm chuột (nút "Chơi lại trận", nếu có, đáp ứng điều này).
- Commit khi xanh, lời commit tiếng Việt. Không `push --force`.

### Quyết định của tác giả (2026-10-20)

_Hai câu dưới đây là chỗ GDD và epics chưa nói rõ. Tác giả chốt 2026-10-20: câu 1 chọn (a), câu 2 chọn (b)._

1. **Hết trận thì bàn có khóa không?** GDD và epics nói "hiện Thắng/Thua ngay lập tức", không nói chuyện gì xảy ra sau đó với bàn.
   - (a) **ĐÃ CHỐT:** Khóa. Từ lúc thắng hoặc thua, mọi lệnh (đi, đánh, kết thúc lượt, hủy) bị từ chối với mã mới `tran_da_het`. Người chơi không đánh tiếp được sau khi đã thắng, bảng "Thắng!" không bị mâu thuẫn bởi bàn đang đổi. Đồng thời là luật để Story 2.8 dừng pha địch khi đã hết trận.
   - (b) Luật không khóa, chỉ giao diện che nút: dễ hơn một chút, nhưng kịch bản và test vẫn gửi được lệnh sau khi thua, và kết cục có thể bị ghi đè (ví dụ thắng rồi đánh tiếp gục nốt tướng thành thua).
2. **Bảng "Thắng!"/"Thua!" cần gì thêm khi chưa có menu (E4)?**
   - (a) Chỉ bảng chữ giữa bàn. Chơi lại bằng `F5` (dev) hoặc nạp lại trang. Đơn giản nhất, không thêm việc cho Story 4.2.
   - (b) **ĐÃ CHỐT:** Bảng chữ **và** một nút "Chơi lại trận" nạp lại trận từ đầu (cùng việc F5 làm, nhưng bấm được cả khi không bật dev). Lý do: playtest (GDD đo "tự chơi lại sau khi thua") và bản itch.io không bật được dev; không có nút thì người chơi phải nạp lại trang. Nút này **bỏ khi có menu ở Story 4.2**.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Kiểm thắng/thua **chỉ khi lệnh có quân gục** (`DIED`/`DROWNED` trong sự kiện): theo FR38 "sau mỗi lần có quân gục". Hệ quả: trận thử, kịch bản không có quân Nguyên từ đầu không bị thắng ngay; không kịch bản cũ nào bị đổi nghĩa.
- Kết cục xét theo **trạng thái cuối lệnh**, không tạm thời giữa lệnh (xem "Chỗ gọi kiểm").
- `BattleState.mission` (mặc định `ELIMINATE`) được chép từ file trận; chỉ Tiêu diệt thắng khi hết quân Nguyên. Giữ ải thắng ở hiệp 5 (3.11) nên hết quân Nguyên **không** thắng ở đó. Kịch bản luật không ghi `kieu`, nên luôn là Tiêu diệt.
- Khóa `ket_qua` của `sau` không bắt buộc, không ghi thì không kiểm (như `hiep`, `da_di`, `da_danh`; tác giả chốt cách này ở 1.5).
- Không có kịch bản "thua" và "thắng thua cùng lúc": chỉ test GUT (xem Bối cảnh). Khi 2.8 hoặc 3.4 cho thua thật, thêm kịch bản `ket_thuc/` ở story đó.
- Phase: chỉ `PLAYER`, `WON`, `LOST` được dùng; các pha còn lại để 2.6–2.8 dùng. Khai báo đủ enum ngay để khỏi đổi thứ tự sau.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.5 (dòng 695–718), FR36, FR38; Story 2.8 (pha địch, gọi kiểm sau từng đòn); Story 3.5 (`so_hiep_toi_da`); Story 3.7 (Lòng dân); Story 3.11 (Giữ ải).
- `_bmad-output/planning-artifacts/game-architecture.md` "Gục, thắng, thua" (dòng 848–855), "Mẫu trạng thái" (dòng 889–902), M2 (ống phân giải), M3 (kịch bản là spec), cây thư mục (`rules_victory.gd`, dòng 565).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 80–92 (thắng, thua, thắng ưu tiên, giới hạn hiệp, Lòng dân).
- `_bmad-output/project-context.md` ("Kiểm tra thắng/thua sau mỗi sự kiện gây gục", "Số tướng do file trận quy định", luật test).
- `_bmad-output/implementation-artifacts/2-4-tran-khanh-du-keo.md` (mẫu story và review findings), `2-1-nguyen-khoai-danh-day-va-va-cham.md`, `2-2-song-va-danh-trung-quan-minh.md`, `2-3-pham-ngu-lao-phong-lao.md`, `deferred-work.md`.

### Review Findings

_Code review 2026-10-20, mốc `8c70e77..7c4cfaa`, ba lớp (Blind, Edge Case, Acceptance). Sau review, tác giả tự kiểm tay AC 13 và 14 (đạt) nên Task 6.3 xong; không có ảnh chụp. Tác giả chọn 1a, 2b, sửa hết patch (2026-10-20)._

- [x] [Review][Decision] Trận Tiêu diệt thắng khi "không còn quân Nguyên trên bàn" — nếu file trận không có quân Nguyên từ đầu, hoặc còn `tiep_vien` chưa vào bàn, thì một lần gục (kể cả tướng cuối) cho `WON` ngay. Hiện chưa trận nào gặp (`thu_thang.json` có `tiep_vien: []`). Chọn: (a) `LevelLoader` báo lỗi khi `tieu_diet` mà không có quân Nguyên, còn tiếp viện để Story 3.10 lo; (b) chỉ thắng khi có quân Nguyên gục trong `events`; (c) để nguyên, ghi vào deferred. [game/src/core/rules_victory.gd:41, game/src/data/level_loader.gd:66] — **Tác giả chọn (a).** `LevelLoader` báo `<f>: trận "tieu_diet" phải có ít nhất một quân Nguyên trong "quan"`. Luật này thay luật cũ của Story 1.1 (trận không quân Nguyên vẫn nạp được): test `test_no_enemy_is_allowed` đổi thành `test_tieu_diet_without_enemy` + `test_giu_ai_without_enemy_is_allowed`; bàn mẫu `_board_level` (test_loaders) và trận lỗi của `test_main` thêm một Bộ binh. Tiếp viện chưa vào bàn: ghi deferred cho Story 3.10.
- [x] [Review][Decision] Kịch bản không kiểm được khóa `ket_thuc_luot` sau khi hết trận — `COMMAND_REJECTS` không nhận `ket_thuc_luot` + `tran_da_het`, nên khóa END_TURN chỉ có test GUT bảo vệ. Chọn: (a) mở rộng loader/runner cho `ket_thuc_luot` nhận `tran_da_het` và sửa `test_step_reject_code_errors`; (b) giữ nguyên hợp đồng cũ như dev đã ghi (đã có test GUT). [game/src/data/scenario_loader.gd:42-52, game/tests/scenario_runner.gd:22] — **Tác giả chọn (b).** Giữ nguyên.
- [x] [Review][Patch] `Rules.resolve` gọi `RulesVictory.check` cả khi lệnh bị từ chối, lệch Task 2.3 và chú thích sai; thoát sớm khi `events` có `REJECTED` [game/src/core/rules.gd:19-20]
- [x] [Review][Patch] AC 1 và AC 3 còn ghi `(5 chưa đạt)`, thực tế kịch bản #1 `(4 chưa đạt)`; sửa số cho khớp theo Dev Notes [2-5-mau-guc-thang-va-thua-tieu-diet.md:AC 1, AC 3]
- [x] [Review][Patch] Test `test_win_shows_banner_and_locks_the_board` bấm `(0,5)` (ô kề Lão) chứ không phải ô sáng cũ của tướng vừa chọn như Task 4.5 yêu cầu; sửa để bấm đúng ô sáng cũ và bấm tướng, rồi kiểm không lệnh nào gửi [game/tests/test_battle_view.gd]
- [x] [Review][Patch] `BattleController.reachable` và `attack_targets` vẫn trả ô sau khi hết trận; trả `[]` khi `Rules.is_battle_over(_state)` [game/src/battle/battle_controller.gd:88-107]
- [x] [Review][Patch] Chưa có test GUT cho nhánh thua đi qua `Rules.resolve` (mọi ca thua gọi thẳng `RulesVictory.check`); thêm một ca dùng lệnh thật hoặc đặt trạng thái rồi `resolve` [game/tests/test_rules_victory.gd] — Khi sửa: lệnh của người chơi chưa làm tướng cuối gục được (người ra đòn luôn còn), nên `test_general_falling_through_resolve_is_checked` cho lao Lão hạ Khoái qua `Rules.resolve` (chưa thua vì còn Lão), rồi mới hạ Lão bằng `Effects.damage`. DEFEAT qua lệnh thật chờ Story 2.8.
- [x] [Review][Patch] `ResultBanner.PANEL_SIZE.y = 170` có thể nhỏ hơn nội dung (chữ 56px + khoảng cách + nút 44 + đệm + viền), và test chỉ kiểm rect của `banner`, không phải rect của panel; đo lại và kiểm rect thật [game/src/ui/result_banner.gd:9, game/tests/test_result_banner.gd]
- [x] [Review][Patch] `game-architecture.md`: dòng `hud.gd` còn ghi nút "Chơi lại", nút này nằm ở `result_banner.gd`; bỏ khỏi dòng `hud.gd` [_bmad-output/planning-artifacts/game-architecture.md] — Khi sửa: chữ "Chơi lại" ở đó là nút "Chơi lại hiệp" (luật hoàn tác, chưa làm), không phải nút Chơi lại trận; ghi rõ thành "Chơi lại hiệp" thay vì xóa.
- [x] [Review][Defer] `ResultBanner` chép lại hằng màu nền và viền của `error_screen.gd`, trái Task 4.1 (không số màu tự đặt) — deferred, chưa có hằng dùng chung; gom vào theme khi có màn thứ ba cần dùng [game/src/ui/result_banner.gd]

## Dev Agent Record

### Agent Model Used

_(dev điền)_

### Debug Log References

- Task 1.1: không thêm `phase`, `mission`, `RulesVictory` (để Task 2). Để `ScenarioRunner.compare` biên dịch được khi chưa có `state.phase`, thêm hàm tạm `ScenarioRunner._outcome(state)` luôn trả `"dang_choi"`; Task 2 đổi thành đọc `state.phase`.
- Task 1.1: `ket_thuc_luot` **không** nhận `tu_choi` (test cũ `test_step_reject_code_errors` khẳng định điều này). Task 1.1 chỉ cho thêm `tran_da_het` cho lệnh kết thúc lượt "nếu bảng có": bảng không có, và kịch bản #5 dùng lệnh `di`, nên giữ nguyên. `tran_da_het` có ở `di`, `danh`, `huy`.
- Task 1.1: sửa 4 chỗ trong `test_scenario_loader.gd` có chuỗi liệt kê mã từ chối (thêm `"tran_da_het"` ở cuối); thêm 4 test (`test_after_outcome_is_read`, `test_after_outcome_errors`, `test_battle_over_reject_fits_every_command`, `test_runner_compares_outcome_only_when_written`).
- Task 1.3: `tools/test.sh` xanh, 451/451, `Kịch bản luật: 44 đã duyệt · 5 chưa duyệt (4 chưa đạt)`. Lý do chưa đạt: #2, #3, #4 `sau: mong đợi kết cục "thang", thực tế "dang_choi"`; #5 `bước 2: kịch bản ghi "tu_choi": "tran_da_het" nhưng luật cho chạy`. **#1 (`dich_con_lai_chua_thang`) đạt ngay**, vì "đang chơi" cũng là trạng thái hiện tại (đúng như ghi chú trong Dev Notes); số `(4 chưa đạt)` thay cho `(5 chưa đạt)` ở AC 1.
- Task 1.6: tác giả trả lời "ok" cho cả 5 kịch bản (2026-10-20), hiểu là cả 5 "đúng". Đổi `da_duyet: true` (chỉ khóa đó). `tools/test.sh` trượt đúng như AC 2: `kịch bản đã duyệt ket_thuc/het_tran_khoa_lenh.json: bước 2: kịch bản ghi "tu_choi": "tran_da_het" nhưng luật cho chạy`.
- Task 2/3 (đỏ trước khi code): viết `test_rules_victory.gd` (15 test), `test_clone_copies_phase_and_mission`, `test_from_level_copies_mission`, `test_battle_over_locks_submit_and_undo` **trước** code luật; chạy thấy đỏ (`Cannot find member "Phase" in base "BattleState"`, kịch bản #5 trượt), rồi mới viết `BattleState.phase/mission`, `RulesVictory`, khóa ở `Rules.resolve` và `BattleController.undo`, và đổi `ScenarioRunner._outcome` đọc `state.phase`.
- Task 2.6: sau khi có luật, 1 test cũ trượt: `test_rules_attack.gd › test_strike_pushes_into_river_drowns` (quân chết đuối là quân Nguyên duy nhất nên có thêm `VICTORY`). Sửa test GUT bằng cách thêm Bộ binh xa `6,6` (id 102), không nới luật. **Không kịch bản cũ nào trượt**; không phải sửa kịch bản nào.
- Task 2.7 phá thử (mỗi lần một chỗ, `tools/test.sh`, đã trả lại sau mỗi lần):
  - bỏ `DROWNED` khỏi `_someone_fell`: `test_last_enemy_drowns_by_push_wins`, `test_last_enemy_drowns_by_pull_next_to_du_wins` + kịch bản `ket_thuc/thang_dich_cuoi_chet_duoi.json` (`mong đợi kết cục "thang", thực tế "dang_choi"`);
  - xét thua trước thắng: `test_victory_beats_defeat_in_either_order` (chỉ test GUT bắt, vì không có kịch bản thắng-thua cùng lúc, theo thiết kế);
  - bỏ khóa ở `Rules.resolve`: `test_commands_are_locked_after_victory`, `test_commands_are_locked_after_defeat`, `test_battle_over_locks_submit_and_undo` + kịch bản `ket_thuc/het_tran_khoa_lenh.json` (`bước 2: … nhưng luật cho chạy`);
  - kiểm cả khi không ai gục: 14 test trượt (nhiều test controller và `test_adjacent_cell_off_board_is_not_adjacent`…), gồm `test_no_death_means_no_check`;
  - `clone()` không chép `phase`: `test_clone_copies_phase_and_mission`, `test_battle_over_locks_submit_and_undo` + kịch bản `het_tran_khoa_lenh.json` (`mong đợi kết cục "thang", thực tế "dang_choi"`).
  Lưu ý: `test_scenarios` chỉ in kịch bản trượt đầu tiên mỗi lần chạy, nên mỗi lần phá chỉ thấy một kịch bản; mỗi lần phá thử đó chỉ có tối đa một kịch bản bị ảnh hưởng nên đủ chứng minh.
- Task 3.3: `grep` mọi chỗ duyệt `BattleEvent.Type`/`Reject`: chỉ `BoardFixture.describe` có `match` trên `Type`, nhánh mặc định `_` in tên loại nên `VICTORY`/`DEFEAT` ra đúng chữ; không `match` nào bị thiếu nhánh.
- Test sau Task 3: 469/469 đạt; `Kịch bản luật: 49 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Task 4.2/4.3: `BattleView` dùng `Rules.is_battle_over(snapshot)` (hàm nhỏ mới ở `rules.gd`, `check_boundaries.sh` không chặn) thay vì tự so `phase`, để chỉ một chỗ biết "WON hoặc LOST". `Hud.show_turn(round, can_undo, over = false)`: thêm tham số cuối có mặc định nên mọi chỗ gọi cũ không đổi.
- Task 4.5: ca "máu đổi ngay" (AC 4) đã có từ 2.1: `test_click_target_attacks_and_general_is_spent` kiểm `_token(main, 101).hp_text() == "1"` ngay sau đòn; tái dùng, không viết lại. Test mới: `test_win_needs_every_enemy_gone`, `test_win_shows_banner_and_locks_the_board`, `test_retry_button_reloads_the_battle`, `test_f5_after_win_clears_the_banner`, và 6 test ở `test_result_banner.gd` (chữ "Thua!" chỉ kiểm ở đây vì chưa thua được bằng lệnh thật).
- Task 4.6 phá thử giao diện (mỗi lần một chỗ, đã trả lại): bỏ `_deselect()` khi hết trận → `test_win_shows_banner_and_locks_the_board`; bỏ ẩn bảng trong `_start_battle` → `test_retry_button_reloads_the_battle`, `test_f5_after_win_clears_the_banner`; bỏ `_battle_over()` ở `_on_cell_clicked` → `test_win_shows_banner_and_locks_the_board`.
- Task 5: `thu_thang.json` thêm Lão `2` ở `0,6` (Dev Notes cho phép): Lão chưa đánh nên hết trận bấm Lão là thấy rõ bàn đã khóa. Bố cục của `_make_win_main()` trong test giao diện giống hệt file này.
- Task 6.1: `game-architecture.md`: thêm mã `tran_da_het` và khóa `sau.ket_qua` vào bảng định dạng kịch bản, `result_banner.gd` và `thu_thang.json` vào cây, đổi tên nhóm kịch bản `thang_thua/` thành `ket_thuc/` (tên tôi đã dùng ở đợt kịch bản), và ghi cách kiểm thắng/thua và luật khóa vào mục "Gục, thắng, thua". Không sửa `epics.md` (tiêu chí không đổi nghĩa).
- Task 6.3: `timeout 12 tools/chay.sh --dev --tran=thu_thang`: log có `[INFO][battle] nạp trận thu_thang`, không có ERROR/WARN. Không chụp ảnh vì GoPeak không kết nối được (`CONNECTION_CLOSED`).
- Test cuối: 481/481 đạt (447 + 34 mới: 15 `test_rules_victory`, 6 `test_result_banner`, 4 giao diện, 4 `test_scenario_loader`, 2 `test_loaders`, 2 `test_battle_state`, 1 `test_battle_controller`); `Kịch bản luật: 49 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Kịch bản dùng đúng số liệu 2.1: Khoái gây 2 sát thương, Bộ binh 3 máu; #4 dựa trên `va_cham/day_vao_quan_khac.json` (Bộ binh đẩy vào Bộ binh: cả hai mất 1 máu) với Bộ binh sau ghi 1 máu.

### Completion Notes List

- Trận Tiêu diệt có kết cục: hết quân Nguyên (hết máu, chết đuối, hoặc va chạm) thì `VICTORY`, `phase = WON`; hết tướng trên bàn thì `DEFEAT`, `phase = LOST`; thắng được ưu tiên khi cùng lúc; số tướng đếm từ bàn. Kiểm ở cuối `Rules.resolve`, chỉ khi lệnh có quân gục (`DIED`/`DROWNED`).
- Hết trận thì khóa: mọi lệnh và cả Hủy bị từ chối `BATTLE_OVER` (mã kịch bản `tran_da_het`), theo quyết định 1a của tác giả.
- Giao diện: bảng "Thắng!"/"Thua!" giữa bàn (nhỏ, hơi trong suốt, không nhận chuột) kèm nút "Chơi lại trận" (quyết định 2b, nạp lại trận như F5, bấm được khi không bật dev); Hủy, Kết thúc lượt mờ; chọn tướng, ô sáng, viền, bấm bàn đều không còn tác dụng. F5 hoặc nút nạp lại thì bảng ẩn.
- `BattleState` thêm `phase`, `mission` (đều chép trong `clone()`), `validate()` thêm bất biến "đã thắng (Tiêu diệt) thì không còn quân Nguyên". `Effects` không đổi logic.
- 5 kịch bản `ket_thuc/` đã duyệt và đạt; khóa mới `sau.ket_qua` (không bắt buộc) và mã `tran_da_het`; 44 kịch bản cũ không bị sửa.
- Trận thử `thu_thang.json` (Khoái, Lão, Dư; hai Bộ binh; thắng bằng hai đòn trong một lượt).
- **Lệch so với Tasks:** (1) Task 1.1: lệnh `ket_thuc_luot` không nhận `tu_choi` (giữ hợp đồng cũ, xem Debug Log); (2) Task 6.3 chưa xong: không chụp ảnh được (GoPeak không kết nối), chờ tác giả kiểm tay, nên `[ ]`; (3) Task 5: `thu_thang.json` có thêm Lão; (4) AC 1 ghi `(5 chưa đạt)` nhưng thực tế `(4 chưa đạt)` vì kịch bản #1 đạt ngay (Dev Notes đã báo trước); (5) Task 2.6: một test GUT cũ (`test_strike_pushes_into_river_drowns`) được thêm Bộ binh xa, không kịch bản nào bị sửa.
- Việc để lại: Story 2.8 phải gọi thêm `RulesVictory.check` sau từng đòn địch (đã ghi `deferred-work.md`); khi 2.8 hoặc 3.4 cho thua thật thì thêm kịch bản "thua" vào `ket_thuc/`.
- **Hướng dẫn tác giả tự test (kết quả thật):**
  1. `tools/test.sh`: `Kịch bản luật: 49 đã duyệt · 0 chưa duyệt (0 chưa đạt)`, `✅ 481/481 test đạt`.
  2. `tools/chay.sh --dev --tran=thu_thang` (tắt bộ gõ VNI/Telex). Mở lên: hai Bộ binh (3 máu), Khoái `1,2`, Lão `0,6`, Dư `5,5`; chưa có bảng.
  3. Gõ `1`, bấm Bộ binh `2,2` (viền trắng): Bộ binh rơi xuống sông và biến mất. **Chưa** có bảng "Thắng!" vì còn một Bộ binh.
  4. Gõ `3`, bấm Bộ binh `5,2`: Dư kéo, Bộ binh rơi xuống sông. Hiện **"Thắng!"** giữa bàn (bàn vẫn nhìn thấy), kèm nút "Chơi lại trận"; nút Hủy và Kết thúc lượt mờ.
  5. Gõ `2` hoặc bấm vào Lão, bấm các ô, gõ `Space`, `Z`: không gì xảy ra (Lão không chọn được).
  6. Bấm nút "Chơi lại trận" (hoặc `F5` khi bật dev): bàn về đầu, hết bảng, chơi tiếp được.
  7. **Thua chưa thử bằng tay được** (chưa có đòn địch, Story 2.8); kiểm bằng test GUT.
  8. (Tùy) Trận 1 thật `tools/chay.sh --dev`: hạ 3 Bộ binh thì hiện "Thắng!".

### File List

- `game/src/core/battle_state.gd` (sửa)
- `game/src/core/rules_victory.gd` (mới), `rules_victory.gd.uid` (mới)
- `game/src/core/rules.gd` (sửa)
- `game/src/core/battle_event.gd` (sửa)
- `game/src/core/effects.gd` (sửa, chỉ chú thích)
- `game/src/battle/battle_controller.gd` (sửa)
- `game/src/battle/battle_view.gd` (sửa)
- `game/src/ui/hud.gd` (sửa)
- `game/src/ui/result_banner.gd` (mới), `result_banner.gd.uid` (mới)
- `game/src/app/main.gd` (sửa)
- `game/src/data/scenario_loader.gd`, `game/src/data/scenario_data.gd` (sửa)
- `game/i18n/text.csv` (sửa), `game/i18n/text.vi.translation` (sinh lại)
- `game/data/tran/thu_thang.json` (mới)
- `game/tests/kich_ban/ket_thuc/dich_con_lai_chua_thang.json`, `thang_dich_cuoi_chet_duoi.json`, `thang_dich_cuoi_het_mau.json`, `thang_khi_hai_dich_cung_gac.json`, `het_tran_khoa_lenh.json` (mới)
- `game/tests/test_rules_victory.gd` (mới), `test_rules_victory.gd.uid` (mới)
- `game/tests/test_result_banner.gd` (mới), `test_result_banner.gd.uid` (mới)
- `game/tests/scenario_runner.gd`, `game/tests/scenario_viewer.gd` (sửa)
- `game/tests/test_scenario_loader.gd`, `test_battle_state.gd`, `test_battle_controller.gd`, `test_battle_view.gd`, `test_loaders.gd`, `test_rules_attack.gd`, `test_main.gd` (sửa)
- `game/src/data/level_loader.gd` (sửa, sau review)
- `_bmad-output/planning-artifacts/game-architecture.md` (sửa)
- `_bmad-output/implementation-artifacts/deferred-work.md` (sửa)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa)

### Change Log

- 2026-10-20: Sửa theo code review: tác giả chọn 1a (trận Tiêu diệt không có quân Nguyên thì báo lỗi khi nạp), 2b (giữ nguyên), sửa cả 7 mục patch. Tác giả tự kiểm tay AC 13, 14 nên Task 6.3 xong. 485/485 test, 49 kịch bản đã duyệt. Chuyển `done`.
- 2026-10-20: Task 2–6 (trừ 6.3): lõi luật thắng/thua, khóa trận, bảng kết cục và nút Chơi lại trận, trận thử `thu_thang`; 481/481 test, 49 kịch bản đã duyệt. Chuyển `review`. Task 6.3 chờ tác giả kiểm tay.
- 2026-10-20: Task 1 xong 1.1–1.4: khung kịch bản kết cục (`ket_qua`, `tran_da_het`, sự kiện `VICTORY`/`DEFEAT`), 5 kịch bản `ket_thuc/` chưa duyệt; chờ tác giả duyệt (1.5).
- 2026-10-20: Tạo story (gds-create-story).
- 2026-10-20: Tác giả chốt 2 câu hỏi: 1 (a) khóa trận khi hết; 2 (b) bảng chữ kèm nút "Chơi lại trận".
