# Story 4.6: Tinh chỉnh 6 trận

Status: ready-for-dev


## Story

Là tác giả,
tôi muốn cả 6 trận vẫn giải được sau mỗi lần tôi chỉnh chỉ số,
để cân bằng game mà không phá trận.

## Acceptance Criteria

1. **Cho** cả 6 lời giải đã là kịch bản tự động (`game/tests/kich_ban/tran/tran_0N_loi_giai.json`, N = 1–6, từ các story 2.14, 3.3, 3.6, 3.8, 3.14, 4.5)
   **Khi** tác giả sửa `game/data/chi_so.json` rồi chạy `tools/test.sh`
   **Thì** cả 6 lời giải được chạy lại **từ file trận thật** (`LevelLoader.load_level("res://data/tran/tran_0N.json")` → `BattleState.from_level` → `Command.begin_battle()`), với chỉ số **thật** vừa sửa, qua `Rules.resolve`, `state.validate()` rỗng sau mỗi lệnh.
2. **Và** một lời giải được tính là **đạt** khi và chỉ khi: không lệnh nào bị từ chối, trận kết thúc **thắng** (`Phase.WON`), **không tướng nào gục** (mọi tướng có trong file trận đều còn trên bàn; mất máu thì được, như trận 5–6). Không so máu, vị trí từng ô hay số hiệp.
3. **Và** `tools/test.sh` in riêng một mục tiếng Việt cho 6 trận, mỗi trận một dòng, người không đọc code hiểu được, ví dụ:
   ```
         Lời giải 6 trận: 5 còn thắng · 1 hỏng
           ✅ Trận 1 — Bến Rừng: thắng ở hiệp 3, đủ 2 tướng (Khoái 3, Lão 3)
           ❌ Trận 5 — …: bước 9 bị từ chối (Lão không đi tới được ô 2,4)
           ❌ Trận 6 — …: thua ở hiệp 4 (giặc vào ải)  /  thắng nhưng Dư gục ở hiệp 3
   ```
   Lời giải hỏng thì `tools/test.sh` **trượt** (mã thoát khác 0) và mục này ghi lý do.
   **Và** (tác giả chốt Câu hỏi 1a) kịch bản luật và test chặt từng trận chạy với **bản chụp chỉ số** `game/tests/kich_ban/chi_so_kich_ban.json` (y hệt `chi_so.json` lúc làm story), nên sửa `chi_so.json` thật **không** làm đỏ kịch bản luật hay `test_tran_0N.gd`; chỉ bộ kiểm 6 trận đọc số thật. Có test khẳng định hôm nay hai file giống hệt về giá trị, và mục tóm tắt `tools/test.sh` ghi một dòng khi hai file **khác** nhau (ví dụ "Chỉ số thật khác bản chụp kịch bản: Bộ binh mau 3 → 4"), để tác giả biết kịch bản đang chạy số cũ.
4. **Và** "trận 1–2 thắng được không mất tướng ngay lần đầu" **không** kiểm ở đây (tác giả đã biết lời giải); thêm thành một mục quan sát trong Story 4.9 (`epics.md` Story 4.9, mục quan sát buổi chơi thử).
5. **Và** có test GUT chứng minh bộ kiểm này bắt được lỗi thật (không phải test luôn xanh): với chỉ số dựng trong test (không sửa `chi_so.json` thật), ít nhất ba ca: (a) chỉ số làm một lệnh trong lời giải bị từ chối, (b) chỉ số làm trận thua, (c) chỉ số làm một tướng gục mà trận vẫn thắng. Mỗi ca ra đúng câu lý do ở AC 3.
6. **Trau chuốt xem trước kết quả đòn** (FR41; tác giả chốt **giữ**):
   **Khi** rê chuột lên mục tiêu đánh được
   **Thì** bản xem trước hiện cả chuỗi hệ quả, ngoài bóng mờ vị trí cuối + máu sau đòn đã có (Story 2.12):
   - **va chạm** (quân nào va vào gì, mất bao nhiêu máu),
   - **chết đuối** (quân nào rơi sông),
   - **đòn địch dịch theo hoặc bị hủy** (ô đỏ tính lại theo bàn sau đòn: chủ đòn bị đẩy thì ô đỏ dịch; chủ gục/đòn ra ngoài bàn thì ô đỏ biến mất),
   - **đòn địch sẽ trúng đồng đội** (ô đỏ sau đòn rơi vào ô có quân Nguyên khác, hoặc vào tướng mình).
   **Và** kết quả khi bấm đánh thật vẫn khớp đúng bản xem trước; xem trước chỉ chạy lại khi đổi ô trỏ (Story 2.12 AC giữ nguyên).
7. **Và** `tools/test.sh` xanh; không sửa luật (`src/core/`), không sửa `chi_so.json`, không sửa kịch bản `da_duyet: true` (đổi nguồn chỉ số của bộ chạy kịch bản không đụng tới file kịch bản); commit tiếng Việt kết `(Story 4.6)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–3** (2026-11-01) — xem "Quyết định của tác giả"; AC 3, 6, 7 đã sửa cho khớp.
- [ ] **Task 1: Bộ kiểm lời giải 6 trận** (AC: 1, 2, 5)
  - [ ] 1.1 Tạo `game/tests/solution_check.gd` (`class_name SolutionCheck`, `RefCounted`, thư mục `tests/` như `scenario_runner.gd`): hàm tĩnh nhận `level_path`, `scenario_path`, `Stats` → trả kết quả `{passed: bool, reason: String, round: int, generals: Array}`. Đọc **các bước** từ kịch bản bằng `ScenarioLoader.load_scenario(path, "res://tests/kich_ban", stats)` (`.steps`), **không** dùng `truoc`/`sau` của kịch bản.
  - [ ] 1.2 Chạy: `BattleState.from_level(level, stats)` → `Rules.resolve(state, Command.begin_battle())` → từng bước. `match step.kind` có nhánh `_:` báo lỗi "bước N: lệnh lạ". Hỗ trợ `di`, `danh`, `muu_ke`, `ket_thuc_luot` (6 lời giải hiện chỉ dùng 4 lệnh này — đã kiểm 2026-11-01); gặp `huy` thì báo lỗi rõ chứ không bỏ qua.
  - [ ] 1.3 Lý do trượt, tiếng Việt, theo thứ tự ưu tiên: lệnh bị từ chối (ghi số bước, tướng, ô, câu `reason` của sự kiện REJECTED) → `validate()` không rỗng → trận chưa hết khi hết bước → thua (ghi hiệp, `defeat_reason` đổi ra chữ: dùng đúng khóa dịch mà màn thua đang dùng) → thắng nhưng có tướng gục (ghi tên tướng). Dừng ngay ở lỗi đầu tiên.
  - [ ] 1.4 Danh sách 6 trận lấy từ `game/data/chien_dich.json` (Story 4.2: `CampaignLoader` ở `src/data/campaign_loader.gd`, `CampaignData` ở `src/core/campaign_data.gd`), không viết cứng 6; kịch bản lời giải theo quy ước tên `tests/kich_ban/tran/<id>_loi_giai.json`. Thiếu kịch bản cho một trận trong chuỗi thì báo trượt rõ.
  - [ ] 1.5 `game/tests/test_loi_giai_6_tran.gd`: một test chạy cả chuỗi với `chi_so.json` thật (mọi trận phải đạt); ghi kết quả từng trận ra file cho `tools/test.sh` đọc (mẫu: `KET_QUA_KICH_BAN` ở `tools/test.sh:142` và `test_scenarios.gd:4,9` `RESULT_ENV`). Đặt tên biến môi trường mới, ví dụ `KET_QUA_LOI_GIAI`.
  - [ ] 1.6 Test đột biến (AC 5): đọc chữ của `chi_so.json`, sửa một số trong Dictionary, `JSON.stringify` rồi nạp bằng `StatsLoader.parse_stats(text, "chi_so_dot_bien")` (`stats_loader.gd:52`) — **không** ghi file vào `data/`. Ba ca (a)(b)(c) phải ra đúng lý do. Gợi ý số (phải tự kiểm bằng chạy thử, không đoán): Khoái `tam_di` 3 → 1 (lệnh đi bị từ chối); Bộ binh `mau` 3 → 9 (thua/không hạ kịp); Cung kỵ `sat_thuong` 1 → 3 (tướng gục).
- [ ] **Task 2: Mục "Lời giải 6 trận" trong `tools/test.sh`** (AC: 3)
  - [ ] 2.1 Đọc file kết quả ở 1.5, in mục như AC 3 (cùng kiểu `bao_cao+=(...)` với mục "Kịch bản luật", `tools/test.sh:244–282`). Lời giải hỏng → đưa vào `ly_do_truot`, mã thoát khác 0.
  - [ ] 2.2 Chưa chạy được GUT (quét project hỏng) thì dòng ghi "chưa chạy được", như mục kịch bản.
  - [ ] 2.3 Bản chụp chỉ số (Quyết định 1a): chép `game/data/chi_so.json` → `game/tests/kich_ban/chi_so_kich_ban.json` (nằm trong `tests/` nên preset export đã loại). Đổi `STATS_PATH` của `test_scenarios.gd`, `test_determinism.gd` (nếu nạp chỉ số), `test_tran_02..06.gd` và mọi test chạy kịch bản luật sang bản chụp — `grep -rn "chi_so.json" game/tests` để không sót (2026-11-01 có 13 file: `scenario_viewer.gd`, `test_battle_state.gd`, `test_determinism.gd`, `test_hold_pass.gd`, `test_loaders.gd`, `test_main.gd`, `test_reinforcements.gd`, `test_scenarios.gd`, `test_tran_02..06.gd`). Test luật có con số cụ thể (`test_battle_state`, `test_hold_pass`, `test_reinforcements`) cũng chuyển sang bản chụp. Giữ số thật cho: `test_loaders.gd` (kiểm file thật nạp được) và `test_main.gd` (mở game thật) — nếu `test_main.gd` có chỗ so con số cụ thể thì báo lại trong Debug Log, không tự quyết. `scenario_viewer.gd`/`tools/xem_kich_ban.sh` cũng phải dùng bản chụp, để tác giả xem đúng số kịch bản đang chạy.
  - [ ] 2.4 Test so giá trị hai file (nạp cả hai bằng `StatsLoader`, so từng khóa): hôm nay giống hệt. Ghi khác biệt ra file kết quả để `tools/test.sh` in dòng "Chỉ số thật khác bản chụp kịch bản: …" (thông tin, **không** làm trượt).
  - [ ] 2.5 Kiểm đột biến bằng tay rồi trả lại: sửa tạm một số trong `data/chi_so.json` → `tools/test.sh`: kịch bản luật vẫn xanh, mục "Lời giải 6 trận" đổi theo, dòng "khác bản chụp" hiện. Ghi kết quả vào Debug Log; **trả số cũ trước khi commit**.
- [ ] **Task 3: Story 4.9 có mục quan sát** (AC: 4) — thêm vào phần quan sát của Story 4.9 trong `epics.md` (và file story 4.9 nếu đã có): "Người chơi thắng trận 1–2 không mất tướng ngay lần đầu không".
- [ ] **Task 4: Trau chuốt xem trước** (AC: 6) — tác giả chốt giữ.
  - [ ] 4.1 Đọc `battle_view.gd` `_update_preview`/`_ghosts_of` (dòng ~341–410) và `preview_view.gd`: dữ liệu đã có sẵn trong `events` của `preview_result` (COLLIDED/DAMAGED với `cause`, DROWNED, DIED, TELEGRAPH_CANCELLED…) và `after_state.telegraphs`.
  - [ ] 4.2 Ô đỏ xem trước: tính `TelegraphMarks.hit_cell(after_state, t)` cho mọi đòn, vẽ lớp ô đỏ "sau đòn" (mờ/khác nét) thay cho ô đỏ thật khi đang xem trước; đòn bị hủy thì ô đỏ cũ có dấu gạch. Đòn sẽ trúng quân Nguyên khác hoặc tướng mình: chỉ báo rõ trên ô đó.
  - [ ] 4.3 Chữ chỉ báo va chạm/chết đuối qua `tr()` (khóa mới trong file dịch, dạng `preview.<muc>`), font đủ dấu, không che số thứ tự đòn (NFR9, đã ghi ở đầu `preview_view.gd`).
  - [ ] 4.4 Không test tự động cho phần vẽ (project-context: UI test tay); có test cho **phần tính** (hàm thuần lấy `before`, `after`, `events` → danh sách chỉ báo) đặt trong `src/battle/`, test bằng `BattleState` dựng sẵn. Giữ test "bấm thật khớp xem trước" của 2.12.
  - [ ] 4.5 Chụp GoPeak (`tools/chay.sh --dev --tran=N`) các ca: đẩy va rừng, đẩy xuống sông, đẩy chủ đòn làm ô đỏ dịch, đẩy làm đòn trúng quân Nguyên khác.
- [ ] **Task 5: Kiểm tra, bàn giao** (AC: 7)
  - [ ] 5.1 `tools/test.sh` xanh; mục "Lời giải 6 trận: 6 còn thắng".
  - [ ] 5.2 Hướng dẫn tác giả thử (tiếng Việt, từng bước): sửa thử một số trong `chi_so.json` (ví dụ Bộ binh `mau` 3 → 4) → `tools/test.sh` → đọc mục "Lời giải 6 trận" → **trả lại số cũ**. Ghi rõ "thấy gì là đúng".
  - [ ] 5.3 Cập nhật story, `sprint-status.yaml`; commit.

## Dev Notes

### Hiện trạng (đã kiểm 2026-11-01, HEAD `2711eab`)

- **6 lời giải phát lại được từ file trận thật** với `chi_so.json` hiện tại: chạy headless (script tạm `sau_tran.gd` trong scratchpad, không thuộc repo) `from_level` + `begin_battle` + các bước của `tran_0N_loi_giai.json`: cả 6 thắng, không lệnh nào bị từ chối.

  | Trận | Kiểu | Thắng ở hiệp | Tướng còn (máu) | Số bước | Lệnh dùng |
  |---|---|---|---|---|---|
  | 1 | Tiêu diệt, 7×7, 2 tướng | 3 | Khoái 3, Lão 3 | 12 | di, danh, ket_thuc_luot |
  | 2 | Tiêu diệt, 6×7, 2 tướng | 6 | Khoái 3, Lão 3 | 15 | di, danh, ket_thuc_luot |
  | 3 | Tiêu diệt 5 hiệp, 6×6 | 2 | 3/3/3 | 7 | di, danh, ket_thuc_luot |
  | 4 | Tiêu diệt 6 hiệp, 7×6 (làng) | 3 | 3/3/3 | 15 | di, danh, ket_thuc_luot |
  | 5 | Giữ ải 5 hiệp, 8×8 | 5 | 3/3/2 | 15 | + muu_ke |
  | 6 | Giữ ải 5 hiệp, 10×8 | 5 | 3/3/3 | 29 | + muu_ke |

- `da_duyet`: `tran_01..04_loi_giai.json` đã duyệt; `tran_05`, `tran_06` chưa (chờ tác giả đánh tay). `tran_01_ne_o_do.json` là kịch bản khác, **không** phải lời giải — không đưa vào bộ kiểm.
- Không có `test_tran_01.gd`; trận 2–6 có `test_tran_0N.gd`.

### Vì sao sửa một số là đỏ cả loạt (đọc trước Câu hỏi 1)

Sửa `chi_so.json` hôm nay sẽ làm trượt **ba lớp** test, không chỉ lời giải:

1. **173 kịch bản luật** (`test_scenarios.gd:2,8`) chạy với chỉ số **thật** và so `sau` **đúng từng ô, từng máu** (`scenario_runner.gd` `compare`, `_compare_cell`). Ví dụ đổi sát thương Khoái 2 → 3 thì mọi kịch bản có Khoái chém đều trượt. Kịch bản đã duyệt **không được sửa** (`tools/test.sh` bước 2 khóa theo commit).
2. **Kịch bản lời giải** `tran_0N_loi_giai.json` cũng là kịch bản luật: dựng từ `truoc` (bàn **sau** pha chuẩn bị, chép tay), so `sau` chính xác. Đổi tầm đi của giặc thì `truoc` không còn khớp bàn thật.
3. **`test_tran_0N.gd`** kiểm chặt: bàn mở khớp `truoc`, máu cuối (`assert_eq(hp, [3, 3, 2])` ở `test_tran_05.gd:178`, `[3, 3, 3]` ở `test_tran_06.gd:207`), đòn chém đúng 3 máu…

AC 1–3 của epic chỉ muốn "lời giải **không còn thắng** thì báo trượt". Nếu giữ nguyên ba lớp trên thì tác giả sửa một số sẽ thấy hàng chục dòng đỏ và không biết trận nào thật sự hỏng. Tác giả đã chốt (Quyết định 1a): kịch bản luật và test chặt dùng bản chụp chỉ số, chỉ bộ kiểm 6 trận dùng số thật.

### Kiến trúc phải giữ

- ADR-006: mọi con số trong `chi_so.json`, tác giả tự cân bằng ([game-architecture.md:378], dòng 246, 340, 465, 471). Bộ kiểm **đọc** chỉ số, không viết cứng con số nào.
- Điểm vào duy nhất `Rules.resolve`; `validate()` sau mỗi lệnh; tất định (duyệt theo id / `thu_tu_dich`).
- `src/core/` cấm `FileAccess`, `print`… Bộ kiểm đặt ở `game/tests/` (như `scenario_runner.gd`), không đặt trong `src/core/`. `tools/check_boundaries.sh` bắt lỗi ranh giới.
- Chuỗi trận: `game/data/chien_dich.json` (Story 4.2). Đừng viết cứng 6 trận.
- `defeat_reason` là mã (`"het_hiep"`, `"mat_lang"`, `"quan_nguyen_vao_ai"`…): màn thua đổi ra chữ ở `result_banner.gd:93–110` (`show_result`). Dùng lại đúng các khóa dịch đó (tách ra hàm tĩnh nếu cần), đừng tạo bảng chữ thứ hai.
- Trận 1–2 chỉ có **2 tướng**: "đủ tướng" = mọi tướng có trong file trận (đếm từ `level.units`), không viết cứng 3.

### Bài học từ story trước (4.5 và review của nó)

- **Test phải có thể trượt.** Review 4.5 bắt `test_solution_without_sat_that_does_not_win` xanh chỉ vì phát lại một chuỗi đã gãy (lệnh bị từ chối mà test không kiểm). Bộ kiểm này **phải** coi lệnh bị từ chối là trượt (AC 2), và AC 5 bắt chứng minh bằng đột biến.
- **Đừng tin "mô phỏng không tìm thấy"**: beam không nhìn trước pha địch bỏ sót lối chặn tiếp viện. Story này không tìm lời giải mới, chỉ phát lại lời giải có sẵn — nhưng nếu cần thử chỉ số, bộ tìm có nhìn trước nằm ở scratchpad phiên review 4.5 (`s7/tim.gd`), không thuộc repo.
- **Cân bằng "bắt buộc Sát Thát" (trận 6) KHÔNG làm ở đây** (Quyết định 2a): story riêng sau, dùng bộ kiểm này. Số liệu: `deferred-work.md` mục code review 4.5; `4-5-tran-6.md` Review Findings.
- Lời giải trận 6 kiểm chặt `[3, 3, 3]` và đòn 3 máu ở `8,6` — đó là test riêng của trận 6, giữ nguyên trừ khi Câu hỏi 1 nói khác.
- 4.2/4.3: test chuỗi dùng `_open("N")`, `_finish(main, Phase.WON)`; file lưu cô lập bằng `tests/pre_run.gd`.

### Git gần đây

- `2711eab` sửa sau review 4.5; `2751624` trận 6; `1334262` tua nhanh (4.4); `1f1b36c` lưu an toàn (4.3). Mẫu commit: tiếng Việt, kết `(Story N.M)`, có dòng Co-Authored-By.

### Xem trước hiện có (cho Task 4)

- `BattleController.preview_result(command)` (`battle_controller.gd:62`): chạy lệnh trên bản sao, trả `{"state", "events"}`, có lưới `validate()`.
- `battle_view.gd:341` `_update_preview`: chỉ tính lại khi ô trỏ đổi (`_preview_cell`), đếm `_preview_count` để test.
- `battle_view.gd:382` `_ghosts_of(before, after, events)`: bóng mờ quân đổi vị trí/máu, quân gục hiện 0 máu ở ô gục.
- `preview_view.gd`: vẽ bóng `GHOST_ALPHA 0.5`, nhãn máu, chỉ báo mất Lòng dân (3.7). Nằm dưới lớp số thứ tự đòn (NFR9).
- Chưa có: chỉ báo va chạm, chết đuối riêng; ô đỏ sau đòn (dịch/hủy); cảnh báo đòn địch trúng đồng đội.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh (`untyped_declaration` là error); JSON số là `float` → `int()`; khóa JSON tiếng Việt không dấu; code tiếng Anh `snake_case`.
- `Array.filter()` trả `Array` không kiểu: gán vào `Array[Unit]` sẽ lỗi — dùng vòng lặp `append`.
- Một lệnh test: `tools/test.sh`, tóm tắt tiếng Việt, mã thoát ≠ 0 là trượt. Sau mỗi lần phân giải trong test gọi `state.validate()`.
- Cấm sửa/xóa kịch bản `da_duyet: true` để test đạt; nghi kịch bản sai thì hỏi tác giả.
- Chữ hiển thị qua `tr()`, khóa `<man>.<muc>`; log qua `Log.*`, không `print()` (script tạm trong scratchpad thì được).
- Không test tự động cho UI/hoạt ảnh; phần đó tác giả test tay, AI chụp GoPeak (`tools/chay.sh --dev` chạy nền, `capture_screenshot`).
- Web đơn luồng: không `Thread`. Hiệu năng không phải vấn đề với bàn ≤ 10×8.
- Nói với tác giả bằng tiếng Việt, bàn cờ chữ, các bước để thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.6] (dòng 1316–1334); Story 4.9 (dòng 1372); Story 2.12 (dòng 845–862); FR41 (dòng 89)
- [Source: _bmad-output/planning-artifacts/game-architecture.md] dòng 246, 286–345, 378 (ADR-006), 465–471
- [Source: _bmad-output/project-context.md#Test]
- [Source: game/tests/scenario_runner.gd] `run`, `compare`, `_compare_cell`; [Source: game/tests/test_scenarios.gd]
- [Source: tools/test.sh] bước 2 (khóa `da_duyet`, dòng 72–96), bước 4 + mục kịch bản (dòng 140–282)
- [Source: _bmad-output/implementation-artifacts/4-5-tran-6.md#Review Findings]; [Source: _bmad-output/implementation-artifacts/deferred-work.md] mục code review 4.5
- [Source: game/src/battle/battle_view.gd], [Source: game/src/battle/preview_view.gd], [Source: game/src/battle/battle_controller.gd]

### Câu hỏi đã hỏi tác giả (đã trả lời ở dưới)

1. **Sửa chỉ số thì các test chặt xử lý thế nào?** (xem "Vì sao sửa một số là đỏ cả loạt")
   - (a) **Đề xuất:** kịch bản luật chạy với **bản chụp chỉ số riêng** `tests/kich_ban/chi_so_kich_ban.json` (chép từ `chi_so.json` hôm nay), để luật đã duyệt không đỏ khi bạn cân bằng; chỉ bộ kiểm 6 trận và game dùng `chi_so.json` thật. Test chặt của từng trận (`test_tran_0N.gd` so máu/bàn mở) chuyển sang dùng bản chụp đó luôn. Muốn kịch bản theo số mới thì cập nhật bản chụp có chủ đích.
   - (b) Giữ như cũ: sửa số thì mọi thứ liên quan đều đỏ; mục "Lời giải 6 trận" chỉ giúp đọc trận nào còn thắng.
   - (c) Cách khác bạn muốn.
2. **Cân bằng "bắt buộc Sát Thát" có làm trong story này không?** (bạn đã chốt mở story cân bằng; mình đề xuất gộp vào 4.6)
   - (a) **Đề xuất:** 4.6 chỉ làm công cụ (bộ kiểm 6 trận + xem trước). Việc chỉnh chỉ số/AI để trận 6 cần Sát Thát là story riêng sau, dùng công cụ này.
   - (b) Gộp vào 4.6: thêm phần thử đổi chỉ số hoặc AI Giữ ải. Đổi AI là **đổi luật** — cần bạn quyết luật mới trước.
3. **Trau chuốt xem trước (AC 6) giữ hay cắt?** Epic cho cắt nếu trễ. Giữ thì thêm khoảng nửa story (phần vẽ phải thử tay).

### Quyết định của tác giả

Chốt 2026-11-01:

1. **(a) Bản chụp chỉ số cho kịch bản luật.** Kịch bản luật (`test_scenarios.gd`, mọi nhóm trong `tests/kich_ban/`, kể cả `tran/`) và test chặt từng trận (`test_tran_0N.gd`) chạy với `game/tests/kich_ban/chi_so_kich_ban.json`, chép y hệt `chi_so.json` hôm nay. Game và bộ kiểm 6 trận dùng `data/chi_so.json` thật. Muốn kịch bản theo số mới thì cập nhật bản chụp có chủ đích.
2. **(a) 4.6 chỉ làm công cụ.** Cân bằng "bắt buộc Sát Thát" là story riêng sau, dùng bộ kiểm này.
3. **Giữ** trau chuốt xem trước (AC 6, Task 4).

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List
