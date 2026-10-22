---
baseline_commit: 898098c
---

# Story 2.14: Hoàn thiện trận 1 và mốc tự chơi hết E2

Status: in-progress

## Story

Là tác giả,
tôi muốn trận 1 đã có lời giải được kiểm chứng,
để biết trận này giải được và dạy đúng luật.

## Acceptance Criteria

1. **Cho** AI đề xuất bố cục cuối của trận 1 (2 tướng; dạy né ô đỏ và đẩy xuống sông) **thì** kèm theo một lời giải không mất tướng, ghi theo từng hiệp vào `data/tran/tran_01_loi_giai.md` (FR43).
2. **Khi** tác giả đánh lại đúng lời giải đó **thì** thắng và không mất tướng nào.
3. **Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng.
4. **Và** bản mới được deploy lên itch (riêng tư).
5. **Và** mốc tự chơi hết E2 (khoảng tuần 7): nếu tác giả thấy chán thì sửa luật trước khi sang E3.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát và đề xuất bố cục cuối** (AC: 1)
  - [x] 1.1 Chạy thử trận hiện tại (`tools/chay.sh --tran=1`, hoặc mô phỏng bằng script): ghi lại nó đang dạy gì, chỗ nào quá dễ/khó, hiệp nào buộc phải né ô đỏ, hiệp nào buộc phải đẩy xuống sông.
  - [x] 1.2 Viết đề xuất bố cục trong Completion Notes: bàn chữ (`dia_hinh` + `quan`), `thu_tu_dich`, và với mỗi hiệp của lời giải nói rõ **nó dạy luật gì**. Điều kiện: 2 tướng; có ít nhất một chỗ buộc né đòn đã báo, một chỗ buộc đẩy quân Nguyên xuống sông; **không mất tướng nào**. **Dừng, chờ tác giả duyệt (Câu hỏi 1)** trước khi sửa file trận.
  - [x] 1.3 Nếu tác giả duyệt: sửa `game/data/tran/tran_01.json`; chạy `tools/test.sh` (nhiều test nạp thật file này: `test_real_levels_are_valid`, `test_real_level_1_loads`, `test_main`).

- [x] **Task 2: Lời giải không mất tướng + kiểm chứng bằng máy** (AC: 1, 2)
  - [x] 2.1 Viết script tạm (xoá sau khi xong) chạy lời giải qua `BattleController` trên đúng `tran_01.json` + `chi_so.json`: `start` → `begin()` (pha chuẩn bị hiệp 1) → các lệnh của lời giải (gồm `ket_thuc_luot` giữa các hiệp) → in từng hiệp: lệnh, sự kiện đáng chú ý, máu còn lại, trạng thái đòn đã báo.
  - [x] 2.2 Điều kiện đạt: kết cục `WON` và **cả 2 tướng còn sống** (không tướng nào gục ở bất kỳ hiệp nào). Không đạt thì sửa lời giải, cùng lắm sửa bố cục — không hạ yêu cầu.
  - [x] 2.3 Giữ script này ở dạng test thật nếu gọn (ví dụ `test_tran_01_solvable.gd` chạy lời giải và khẳng định thắng + đủ tướng); nếu không, kịch bản ở Task 4 là đủ.

- [x] **Task 3: Ghi lời giải cho tác giả** (AC: 1, 2)
  - [x] 3.1 `game/data/tran/tran_01_loi_giai.md`: mở đầu bằng mục tiêu ("thắng, không mất tướng"), bàn đầu trận (hai lớp `dia_hinh`/`quan` dạng chữ như file trận), rồi **từng hiệp**: bàn đầu hiệp, lệnh của người chơi (bấm gì, ở ô nào), đòn quân Nguyên ra trong hiệp, máu còn lại, và một câu "hiệp này dạy: …".
  - [x] 3.2 Viết theo cách tác giả làm theo được bằng tay: ô ghi `cột,hàng` (0-based như F1), phím/bấm nêu rõ.
  - [x] 3.3 Đối chiếu lời giải trong tài liệu với lời giải đã chạy ở Task 2 — cùng một chuỗi lệnh, không lệch.

- [x] **Task 4: Kịch bản tự động** (AC: 3)
  - [x] 4.1 Sinh `game/tests/kich_ban/tran/tran_01_loi_giai.json`:
    - `truoc` = bàn **người chơi thấy ở đầu hiệp 1**, tức sau pha chuẩn bị (gọi `begin()` rồi lấy bản chụp). Lấy lớp chữ bằng `BugReport.before_layers(state)` (Story 2.13) thay vì chép tay, rồi bỏ `thu_tu_dich` nếu bộ nạp không cần — kiểm bằng `tools/test.sh`.
    - `hanh_dong` = toàn bộ lệnh của lời giải, đúng thứ tự, gồm `ket_thuc_luot`.
    - `sau` = bàn cuối: `quan` còn đủ 2 tướng (`1`, `2`), không còn quân Nguyên; thêm `ket_qua: "thang"` (định dạng `sau` hỗ trợ từ Story 2.13).
    - `da_duyet: true` **chỉ sau khi tác giả duyệt lời giải**; trước đó để `false` và ghi rõ trong story.
  - [x] 4.2 `tools/test.sh` xanh; kịch bản mới được `ScenarioLoader.list_files("res://tests/kich_ban")` nhặt tự động (không cần đăng ký).
  - [x] 4.3 Kiểm ngược: sửa một lệnh trong `hanh_dong` (hoặc bỏ một `ket_thuc_luot`) → kịch bản phải **trượt**; khôi phục → xanh. Ghi bằng chứng vào Debug Log.

- [ ] **Task 5: Tác giả đánh lại bằng tay** (AC: 2)
  - [ ] 5.1 Hướng dẫn trong Completion Notes: `tools/chay.sh --tran=1`, làm đúng `tran_01_loi_giai.md`, thấy bảng **Thắng** và không mất tướng nào. **Chờ tác giả chạy.**
  - [ ] 5.2 Ghi nhận kết quả tác giả báo lại (nếu chưa kịp thì ghi "chờ tác giả", không đánh [x] khi chưa có).

- [ ] **Task 6: Deploy itch (riêng tư)** (AC: 4)
  - [x] 6.1 `tools/itch.cfg` **đã điền** `ITCH_TARGET=tuantrunglc/hao-khi-dong-a` từ Story 0.5 — không phải chỗ trống. Bản web đã build lại (`v0.1.0 · 25cf3a0-sua`, 2026-10-22). Thử `tools/deploy_itch.sh`: **butler chưa đăng nhập trên máy này** → chặn thật là bước đăng nhập, không phải `itch.cfg`.
  - [ ] 6.2 Khi đã có: `tools/build_web.sh` rồi `tools/deploy_itch.sh`; giữ trang ở chế độ riêng tư (script không tự đổi hiển thị). Ghi link trong Completion Notes.
  - [ ] 6.3 Nếu chưa có trang: ghi rõ "chặn: chưa cấu hình itch", không tự tạo trang.

- [ ] **Task 7: Mốc tự chơi hết E2** (AC: 5)
  - [ ] 7.1 **Chờ tác giả:** tự chơi từ trận 1 tới hết nội dung E2 (hiện có trận 1) và trả lời: có chán không, luật nào cần sửa trước E3.
  - [ ] 7.2 Ghi câu trả lời vào Change Log; nếu có luật phải sửa thì mở story sửa luật, chưa sang E3.

## Dev Notes

### Hiện trạng trước story này (đọc trước khi sửa)

- `game/data/tran/tran_01.json`: 7×7, `kieu: tieu_diet`, sông ở **cột 3** (hàng 0–2 và 4–6), 3 Bộ binh ở `(1,0)`, `(5,0)`, `(5,4)`; hai tướng Khoái `(0,6)`, Lão `(2,6)`; `thu_tu_dich: ["1,0", "5,0", "5,4"]`. Đây là bàn mà Story 1.2 dựng; chưa có lời giải nào.
- `game/data/chi_so.json`: Khoái 3 máu, đi 3, sát thương 2, **đẩy 1**; Lão 3 máu, đi 3, sát thương 1, lao gần 2 / xa 4; Bộ binh 3 máu, đi 2, sát thương 1. Không có Kỵ binh/Cung kỵ trong trận 1.
- `game/data/tran/`: các trận thử (`thu_*`) dùng cho test; **đừng sửa** chúng cho story này.
- `game/tests/kich_ban/`: 12 nhóm hiện có, **chưa có `tran/`**. `ScenarioLoader.list_files("res://tests/kich_ban")` quét đệ quy nên thư mục mới tự được chạy.
- `game/src/data/scenario_loader.gd`: `truoc` nhận `dia_hinh`, `quan`, `mau`, `thu_tu_dich`, `bao_don` — **không** có `hiep`/`da_di`/`da_danh`; `sau` nhận thêm `hiep`, `da_di`, `da_danh`, `ket_qua`, `bao_don`, `o_do`.
- `game/src/debug/bug_report.gd` (Story 2.13): `before_layers(state)` / `after_layers(state)` in ra đúng các lớp chữ của kịch bản — dùng để sinh `truoc`/`sau` thay vì chép tay 7 dòng × 7 cột.
- `game/src/core/rules_enemy_phase.gd`: `begin_battle` là pha chuẩn bị hiệp 1 (quân Nguyên đi + báo đòn); **kịch bản không có lệnh này**, nên `truoc` phải là bàn **sau** pha đó (bàn người chơi thấy khi mở trận).
- `game/src/core/battle_state.gd`: `kieu: tieu_diet` → thắng khi hết quân Nguyên (`phase = WON`); tướng gục không làm thua ngay, chỉ thua khi **mọi** tướng gục — nên "không mất tướng" là điều kiện của lời giải, không phải của luật.
- `tools/deploy_itch.sh`: cần `tools/itch.cfg` có `ITCH_TARGET=<tài khoản>/<trang>`, đã đăng nhập butler, và `build/web/` có bản build. `ITCH_TARGET` **đã điền** `tuantrunglc/hao-khi-dong-a` (từ Story 0.5); chặn thật khi đẩy là butler chưa đăng nhập trên máy này.

### Luật kiến trúc phải theo

- Không sửa `src/core/` cho story này. Nếu thấy luật phải đổi mới giải được thì **dừng, hỏi tác giả** — đó là story sửa luật riêng.
- Trận 1 là **dữ liệu**, không phải code: chỉ sửa `game/data/tran/tran_01.json` (+ tài liệu lời giải + kịch bản test).
- Kịch bản luật là **spec**: `da_duyet: true` chỉ khi tác giả đã duyệt lời giải; đã duyệt rồi thì không được sửa để test xanh.
- Mọi test chạy qua `main.tscn`/headless; `tools/test.sh` là lệnh duy nhất.
- Đi xuống gọi hàm, đi lên phát signal — story này không thêm code UI.

### Cách dựng `truoc`/`sau` cho kịch bản (để dev không phải đoán)

1. `BattleController.start(level, stats)` rồi `begin()` → `snapshot()` là bàn người chơi thấy ở hiệp 1.
2. `BugReport.before_layers(snapshot)` → `dia_hinh`, `quan`, `mau`, `thu_tu_dich`, `bao_don` (nếu có). Bỏ `thu_tu_dich` nếu bộ nạp cảnh báo (nó là khóa hợp lệ của `truoc`, giữ được thì tốt vì giữ id quân Nguyên).
3. Chạy lời giải trên controller; `snapshot()` cuối → `BugReport.after_layers(snapshot)` cho `sau`, thêm `"ket_qua": BugReport.outcome(snapshot)`.
4. `hanh_dong`: `{"lenh": "di"|"danh", "tuong": "1"|"2", "o": "cột,hàng"}`, `{"lenh": "ket_thuc_luot"}`. Không có `huy` nếu lời giải không hủy nước nào (khuyến khích: lời giải sạch, không cần hủy).
5. Kiểm: `tools/test.sh` chạy kịch bản; `ScenarioRunner` so bàn cuối với `sau` (ô, máu, tướng còn sống, `ket_qua`).

### Testing

- `tools/test.sh` là lệnh duy nhất; trong phiên AI có sandbox: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`.
- Chạy một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_scenarios.gd -gexit`
- **Bẫy của story này:** (a) kịch bản `truoc` lấy bàn TRƯỚC `begin()` → lời giải lệch ngay từ hiệp 1; (b) lời giải "thắng" nhưng có tướng gục — phải kiểm máu/còn tướng ở **mọi** hiệp, không chỉ kết cục; (c) `da_duyet: true` trước khi tác giả duyệt; (d) quên `ket_thuc_luot` giữa các hiệp.
- Kiểm ngược (bài học 2.12/2.13): sửa một lệnh hoặc bỏ một `ket_thuc_luot` → kịch bản phải trượt.

### Previous Story Intelligence (2.13, 2.12, 2.11)

- 2.13: `BugReport.before_layers`/`after_layers`/`outcome` dựng đúng lớp chữ của kịch bản — dùng lại, đừng viết lại. Báo cáo F2 cũng là cách nhanh nhất để lấy một bàn chữ từ game thật; nhớ nó in cả khối JSON.
- 2.13: `sau` chỉ ghi `bao_don` khi **mọi** đòn ghi được; đừng chép tay `bao_don`.
- 2.12: kịch bản phát lại phải so cả **đòn đã báo** và `ket_qua`, không chỉ quân.
- 2.11: `begin()` phát hoạt ảnh; script headless dùng `_player.instant` hoặc gọi thẳng controller (không cần view).
- 1.2/1.9: `tran_01.json` là bàn mẫu của test nạp dữ liệu; đổi bố cục vẫn phải hợp lệ (có tướng, có quân Nguyên, ô đi được).

### Git Intelligence

- `898098c Sửa theo code review Story 2.13: kịch bản trong báo cáo F2 luôn phát lại được (Story 2.13)`
- `bb104e2 F2 sao chép báo lỗi: kịch bản tái hiện, thông báo, 21 test (Story 2.13)`
- `6030532 Sửa theo code review vòng 2 ... (Story 2.12)`

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1.
- Kịch bản luật là spec; `da_duyet` chỉ do tác giả chốt; cấm sửa kịch bản đã duyệt để test xanh.
- Chữ hiển thị qua `tr()`; story này không thêm chữ UI (tài liệu lời giải là tiếng Việt thường).
- Commit khi `tools/test.sh` xanh, lời commit tiếng Việt.

### Câu hỏi cho tác giả (chốt trước khi sửa file trận)

1. **Bố cục:** giữ khung 7×7 + sông cột 3 + 3 Bộ binh như hiện tại và chỉ tinh chỉnh vị trí/`thu_tu_dich`, hay thiết kế lại từ đầu? (Đề xuất: giữ khung, vì nó đã có sông giữa bàn và hai tướng; chỉ đổi vị trí để lời giải buộc dùng cả "né ô đỏ" lẫn "đẩy xuống sông".)
2. **itch (đã trả lời):** trang đã có — `tuantrunglc/hao-khi-dong-a` trong `tools/itch.cfg` và đã đẩy bản web ở Story 0.5. Câu hỏi cũ ("cfg chưa điền") sai; chặn thật khi đẩy là butler chưa đăng nhập.
3. **Độ dài lời giải:** bao nhiêu hiệp là chấp nhận được? (Đề xuất 3–5 hiệp; dài hơn thì người chơi mới mệt và khó làm theo bằng tay.)

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.14 (dòng ~884–905), FR43 (dòng 93, 167), phạm vi E2 (dòng 199).
- `_bmad-output/planning-artifacts/game-architecture.md`: cây `data/tran/` và `tests/kich_ban/`, mục kịch bản luật; quy trình M3 (dòng ~797).
- `_bmad-output/project-context.md`: quy trình M3, `da_duyet`, test một lệnh.
- `game/data/tran/tran_01.json`, `game/data/chi_so.json`, `game/src/data/scenario_loader.gd`, `game/src/debug/bug_report.gd`, `game/src/core/rules_enemy_phase.gd`, `game/tests/scenario_runner.gd`, `tools/deploy_itch.sh`, `tools/itch.cfg`.

## Dev Agent Record

### Review Findings

#### Vòng 1 — code review 2026-10-22 (diff `898098c..25cf3a0`)

Blind Hunter + Edge Case Hunter + Acceptance Auditor. 20 phát hiện thô → 11 việc sau khi gộp và khử trùng; 3 việc cần tác giả quyết đã chốt 2026-10-22, còn **9 sửa, 2 hoãn**, 9 phát hiện bị loại hoặc gộp. Bằng chứng thô: `.review/2-14-findings-*.md`. Đã xác nhận độc lập: `tools/test.sh` 618/618, 81 đã duyệt + 2 chưa duyệt (0 chưa đạt), 12 lệnh/3 hiệp cho đường chính, `truoc` khớp bàn sau `begin()`, File List đủ 7 tệp, không đụng `src/core/`, `chi_so.json` hay kịch bản đã duyệt.

- [x] [Review][Patch] **HIGH — AC4: sửa 5 chỗ nói sai về itch, build lại rồi thử đẩy** — `ITCH_TARGET=tuantrunglc/hao-khi-dong-a` có từ commit `c9cc5a6`, có mặt ở cả `898098c` và `25cf3a0`; Story 0.5 đã đẩy bản web lên trang đó (commit `ebd46e2`). Story lặp lại điều sai ở 5 chỗ (dòng 54, 74, 123, 145, 176) và Câu hỏi 2. Bản build duy nhất trong `build/web/` là `d3ddfd1-sua` ngày 20/10 — cũ hơn story, nên phải build lại. **Tác giả đã chốt (2026-10-22): thử đẩy ngay**; nếu butler chưa đăng nhập thì ghi đúng lý do thật (không phải `itch.cfg`) và hẹn tác giả đăng nhập rồi chạy lại. [tools/itch.cfg:3, story:54,74,123,145,176]
- [x] [Review][Defer] **MEDIUM — AC3: bật `da_duyet: true` sau khi tác giả đánh tay** — `test_scenarios.gd:49-52` chỉ `assert` khi kịch bản đã duyệt; hiện `da_duyet: false` nên lời giải hỏng chỉ được liệt kê, `tools/test.sh` vẫn xanh. **Tác giả đã chốt (2026-10-22): dev bật cờ sau khi tác giả đánh lại bằng tay và xác nhận** (không bắt tác giả sửa JSON). Phần sửa câu chữ tài liệu và hướng dẫn vẫn làm ngay (xem patch bên dưới). [game/tests/kich_ban/tran/tran_01_loi_giai.json:2] — deferred, chờ tác giả đánh tay.
- [x] [Review][Patch] **MEDIUM — AC1/Task 1.2: thêm kịch bản cho nhánh né ô đỏ + ghi lại khảo sát và duyệt bố cục** — trận chỉ có một ô đỏ (`2,5 → 2,6`); lời giải chính hạ chủ đòn ngay hiệp 1. **Tác giả đã chốt (2026-10-22): "hạ chủ đòn" được tính là dạy né; vẫn phải có kịch bản chạy nhánh né** (Lão sang `1,6` ở hiệp 1 rồi thắng, không mất tướng), bổ sung phần khảo sát Task 1.1 vào Completion Notes và ghi rõ việc tác giả duyệt bố cục. [game/tests/kich_ban/tran/, story:26,149]

- [x] [Review][Patch] **MEDIUM — sơ đồ cuối hiệp 1 trong tài liệu đặt Khoái ở `1,6`, đúng là `1,5`** — `tran_01_loi_giai.md:45-46` phải là `hàng 5:  . 1 2 . . . .` và `hàng 6:  . . . . . . .`; máy và chính các bước (`:34`, `:51`) đều là `1,5`. Nhân đây cho sông (`~`) hiện trong các sơ đồ cho khớp lớp chữ của game. [game/data/tran/tran_01_loi_giai.md:42-47]
- [x] [Review][Patch] **MEDIUM — lời khuyên "Lão đi sang `1,6`" / "chơi chậm hơn" phá chuỗi lệnh phía sau mà không nói** — hiệp 2 giả định Lão đứng `2,5` bắn `2,2`; hiệp 3 giả định Lão `2,5`. Làm theo lời khuyên thì chuỗi 12 lệnh không còn đúng. Sửa: bỏ lời khuyên, hoặc ghi rõ "đây là đường khác, phải tự tìm tiếp; chuỗi bên dưới chỉ đúng khi hạ chủ đòn ở hiệp 1". [game/data/tran/tran_01_loi_giai.md:76]
- [x] [Review][Patch] **MEDIUM — không test nào buộc `truoc`/ô đỏ mở màn khớp bàn thật sau `begin()`** — `test_main.gd:309-310` chỉ chốt đồng quân 101; dời Bộ binh `4,1`/`4,3` hoặc đổi AI sẽ làm lời giải tay hỏng mà 618 test vẫn xanh. Thêm assert 102 ở `4,1`, 103 ở `4,3`, ô đỏ `2,6` (hoặc so `BugReport.before_layers(begin())` với `truoc`). [game/tests/test_main.gd:309]
- [x] [Review][Patch] **LOW — tài liệu nói kịch bản "khẳng định" trong khi cờ duyệt đang tắt; hướng dẫn bắt tác giả sửa JSON** — sửa `tran_01_loi_giai.md:80` thành "chạy và báo kết quả; chỉ thành chốt chặn sau khi duyệt", và đổi bước 4 trong Completion Notes thành "tác giả xác nhận; dev bật cờ". [game/data/tran/tran_01_loi_giai.md:80, story:173]
- [x] [Review][Patch] **LOW — comment `test_battle_view.gd:11` giờ sai** — "trận 1 thật không có quân Nguyên nào kề tướng lúc đầu": nay Bộ binh `2,5` kề Lão `2,6` ngay khi mở trận. Sửa comment cho đúng (trận thử vẫn cần vì lý do khác). [game/tests/test_battle_view.gd:11]
- [x] [Review][Patch] **LOW — "14 test trượt" trong Debug Log không tái lập được** — dựng lại: test cũ + dữ liệu mới → 22 trượt; test mới + dữ liệu cũ → 18 trượt. Sửa thành số đo được hoặc bỏ con số. [story:142]
- [x] [Review][Patch] **LOW — mục "Hiện trạng liên quan" vẫn tả bố cục trước story như đang là hiện tại** — dòng 66-74 ghi `1,0`/`5,0`/`5,4`, trong khi story này đổi thành `2,4`. Ghi rõ "trước story 2.14" hoặc cập nhật. [story:66]

- [x] [Review][Defer] **LOW — mẫu JSON "Trận 1" trong `game-architecture.md` còn bố cục cũ và 3 tướng** — lệch có sẵn từ trước diff; ghi rõ là ví dụ minh hoạ hoặc cập nhật sau. [game-architecture.md:304-313] — deferred, pre-existing

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- `tools/test.sh`: **618/618 đạt**, 81 kịch bản đã duyệt; kịch bản mới `tran/tran_01_loi_giai.json` hiện **1 chưa duyệt (0 chưa đạt)** — phát lại đúng, chờ tác giả duyệt.
- Đổi bố cục trận 1 làm **22 test trượt** (con số cũ ghi 14 không tái lập được; đo lại với bộ test cũ + dữ liệu mới) — các test ghi nhớ bàn mở màn trận 1: ô sáng của Khoái/Lão, đường đi tới `2,5`, vị trí đồng quân 101. Đã cập nhật đúng theo bàn mới; chạy lại 618/618.
- Tìm lời giải bằng beam search (script tạm, đã xoá): thắng ở **hiệp 3**, cả hai tướng còn 3 máu. Chạy lại bằng `BattleController` thật để in sự kiện từng lệnh.
- Kiểm ngược kịch bản: sửa một bước `danh 2 2,2` thành `3,2` và tạm đặt `da_duyet: true` → `test_scenarios` trượt đúng câu "bước 7: luật từ chối ... mà kịch bản không ghi tu_choi"; khôi phục → xanh.
- **Deploy itch:** đã build lại bản web (`v0.1.0 · 25cf3a0-sua`, 2026-10-22) và thử `tools/deploy_itch.sh` → **butler chưa đăng nhập** trên máy này (lỗi thật, không phải `itch.cfg`). Tác giả chạy `tools/dang_nhap_itch.sh` một lần rồi `tools/deploy_itch.sh`. Còn hai bước tác giả: đánh lại bằng tay (AC 2), mốc E2 (AC 5).

### Completion Notes List

**Đề xuất bố cục cuối (Task 1.2) — tác giả đã chốt hướng "giữ khung, tinh chỉnh":**

- Giữ bàn 7×7, sông cột 3 (hàng 3 đi được), hai tướng Khoái `0,6` — Lão `2,6`.
- Dời **một** Bộ binh từ `1,0` xuống `2,4` (thứ tự quân Nguyên: `2,4`, `5,0`, `5,4`). Hiệp 1 nó đi xuống `2,5` và **báo đòn vào `2,6`** — đúng ô Lão, nên người chơi gặp ô đỏ ngay hiệp đầu; đồng thời nó đứng sát sông, mở ra bài "đẩy xuống sông" bằng một cú đẩy của Khoái.
- Hai Bộ binh còn lại giữ nguyên `5,0`, `5,4`, tiến vào giữa bàn.
- Không đổi `chi_so.json` và không đụng `src/core/`.

**Khảo sát bàn cũ (Task 1.1):** bàn trước story (Bộ binh `1,0`, `5,0`, `5,4`) mở trận không có ô đỏ nào trên ô tướng — Bộ binh `1,0` chỉ báo vào ô trống `2,1` — nên hiệp 1 không dạy gì; muốn "đẩy xuống sông" phải chờ quân Nguyên tự đi sát sông. Bàn mới đưa ô đỏ lên đúng ô Lão ngay hiệp 1 và đặt Bộ binh sát sông, nên cả hai bài đều xuất hiện ngay.

**Duyệt bố cục:** tác giả chốt "giữ khung, tinh chỉnh" (2026-10-22); chi tiết dời Bộ binh xuống `2,4` ghi ở trên. Lời giải chính (hạ chủ đòn) được tác giả chấp nhận là đủ dạy "né ô đỏ"; nhánh né có kịch bản riêng bên dưới.

**Lời giải (3 hiệp, không mất tướng) — đã kiểm bằng máy:**

| Hiệp | Lệnh | Kết quả |
|---|---|---|
| 1 | Khoái đi `1,5`, đánh `2,5`; Lão đi `2,5`; hết lượt | Bộ binh `2,5` bị đẩy xuống sông `3,5`, chết đuối; ô đỏ `2,6` bị hủy |
| 2 | Khoái đi `2,4`, đánh `2,3`; Lão đánh `2,2`; hết lượt | Bộ binh `2,3` mất 2 máu, bị đẩy lên `2,2`, rồi trúng lao và gục |
| 3 | Khoái đi `2,3`, đánh `3,3`; Lão đi `1,3`, đánh `4,3` | Quân cuối mất 2 máu, bị đẩy sang `4,3`, trúng lao và gục → **thắng** |

Cả hai tướng còn 3 máu ở mọi hiệp. Bản đầy đủ cho người chơi: `game/data/tran/tran_01_loi_giai.md`.

**Kịch bản tự động:** hai kịch bản trong `game/tests/kich_ban/tran/`:

- `tran_01_loi_giai.json` — đường chính: `hanh_dong` 12 lệnh, 3 hiệp; `sau` là bàn thắng còn đủ hai tướng (`ket_qua: "thang"`).
- `tran_01_ne_o_do.json` — nhánh né ô đỏ: Lão đi `1,6` (đòn giáng xuống ô trống), Khoái `1,5`; hiệp 2 Khoái đẩy Bộ binh `2,5` xuống sông; hiệp 3 Khoái đẩy Bộ binh `2,4` xuống sông; hiệp 4 Khoái đánh `1,3`, Lão lao `1,2` → thắng, hai tướng 3 máu.

Cả hai đang để `da_duyet: false`. **Tác giả đánh tay xong và xác nhận thì dev bật `true`** cho cả hai (tác giả không phải sửa JSON); khi đã duyệt, sửa một bước là `tools/test.sh` trượt (đã kiểm ngược).

**Hướng dẫn tác giả tự test (AC 2):**

1. `tools/chay.sh --tran=1`.
2. Làm đúng `game/data/tran/tran_01_loi_giai.md` (3 hiệp, 12 lệnh).
3. Thấy bảng **Thắng** và **không tướng nào gục** (cả hai cùng 3 máu).
4. Nếu khớp: báo lại; **dev** bật `"da_duyet": true` cho cả hai kịch bản rồi chạy `tools/test.sh` (vẫn 618/618, dòng tóm tắt thành `83 đã duyệt`).
5. Thử nhánh né: làm mục "Nhánh né ô đỏ" trong tài liệu (4 hiệp) để thấy đòn đã báo giáng xuống ô trống `2,6`.

**Deploy (AC 4): build xong, chặn ở bước đăng nhập.** `tools/itch.cfg` đã điền `tuantrunglc/hao-khi-dong-a` từ Story 0.5. Đã build lại bản web (`v0.1.0 · 25cf3a0-sua`, 2026-10-22) và chạy thử `tools/deploy_itch.sh` → **butler chưa đăng nhập trên máy này**. Tác giả chạy `tools/dang_nhap_itch.sh` (một lần, mở trình duyệt) rồi `tools/deploy_itch.sh`; trang vẫn riêng tư (script không tự đổi hiển thị).

### File List

- `game/data/tran/tran_01.json` (bố cục cuối: Bộ binh `2,4`, `5,0`, `5,4`; `thu_tu_dich` tương ứng)
- `game/data/tran/tran_01_loi_giai.md` (mới — lời giải 3 hiệp cho tác giả; sửa sơ đồ hiệp 1 và thêm nhánh né ô đỏ)
- `game/tests/kich_ban/tran/tran_01_loi_giai.json` (mới — kịch bản tự động, `da_duyet: false`)
- `game/tests/kich_ban/tran/tran_01_ne_o_do.json` (mới — kịch bản nhánh né ô đỏ, 4 hiệp, `da_duyet: false`)
- `game/tests/test_battle_view.gd` (ô sáng/đường đi theo bàn mới; `LAO_TARGET` sang `1,4`; comment trận thử)
- `game/tests/test_main.gd` (vị trí đồng quân 101 ở `2,5`; số ô đi được 7 → 6; khóa thêm 102/103 và ô đỏ `2,6`)
- `_bmad-output/implementation-artifacts/deferred-work.md`
- `_bmad-output/implementation-artifacts/2-14-hoan-thien-tran-1-va-moc-tu-choi-het-e2.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-22: bố cục cuối trận 1 (dời một Bộ binh xuống `2,4` để hiệp 1 có ô đỏ + sát sông), lời giải 3 hiệp không mất tướng, kịch bản tự động `tran/tran_01_loi_giai.json`; 618/618 test. Chờ tác giả: đánh lại bằng tay (AC 2), duyệt kịch bản, deploy itch (AC 4 — chặn vì `itch.cfg`), mốc E2 (AC 5).
- 2026-10-22 (sau code review): sửa sơ đồ hiệp 1 trong tài liệu (Khoái `1,5`, hiện sông), thêm kịch bản nhánh né `tran_01_ne_o_do.json` (4 hiệp), khóa thêm 102/103 + ô đỏ `2,6` trong `test_main`, sửa comment và số liệu story, build lại web; deploy chặn ở butler chưa đăng nhập (không phải `itch.cfg`). 618/618 test.
