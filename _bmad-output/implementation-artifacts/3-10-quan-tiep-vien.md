---
baseline_commit: e7df841
---

# Story 3.10: Quân tiếp viện

Status: done

## Story

Là người chơi,
tôi muốn biết trước quân tiếp viện sẽ xuất hiện ở đâu,
để đứng chặn ô đó hoặc chuẩn bị đối phó.

## Acceptance Criteria

1. **Cho** file trận hoặc kịch bản có lịch tiếp viện (`tiep_vien`):
   - Mỗi mục tiếp viện gồm: `hiep` (số nguyên ≥ 2), `o` (tọa độ `"cot,hang"`), `loai` (ký hiệu `"B"`, `"K"`, `"C"`). Máu mặc định đầy theo `Stats`.
   - `LevelLoader` và `ScenarioLoader` nạp và kiểm tra dữ liệu hợp lệ: `hiep` ≥ 2, ô nằm trong bàn và là ô đi được (`Terrain.is_walkable`), loại quân Nguyên hợp lệ; báo lỗi tiếng Việt nếu sai.
2. **Khi** bước vào pha chuẩn bị đầu hiệp N (`prepare()`, kể cả hiệp 1 lúc mở trận):
   - Sau khi tiếp viện xuất hiện (bước 1a) và quân địch hành động (bước 1b), hệ thống báo trước các ô tiếp viện của hiệp kế tiếp N+1 (`hiep == state.round_number + 1`), phát sự kiện `BattleEvent.reinforcement_warned`, đánh dấu ký hiệu riêng trong `state.reinforcement_warnings` hiện suốt lượt người chơi hiệp N (FR35, tác giả chốt 2026-10-25).
3. **Khi** sang đầu hiệp sau (bước 1a tiếp viện trong `prepare`):
   - Quân tiếp viện của hiệp đó được xử lý theo đúng thứ tự khai báo trong danh sách tiếp viện:
     - **Trường hợp ô trống:** Quân tiếp viện xuất hiện trên bàn (`BattleEvent.reinforcement_spawned`), nhận id tiếp theo (`state.next_enemy_id`).
     - **Trường hợp ô có quân đứng (bất kể phe: tướng ta hoặc quân Nguyên khác):** Quân đang đứng trên ô mất 1 máu (`BattleEvent.damaged` với nguyên nhân sát thương tiếp viện `Cause.REINFORCEMENT`), quân tiếp viện bị hủy (`BattleEvent.reinforcement_blocked`). Nếu quân đứng đó hết máu thì gục (`BattleEvent.died`).
4. **Khi** bước vào pha chuẩn bị (bước 1b):
   - Quân tiếp viện vừa xuất hiện tham gia chuẩn bị (đi và báo đòn) ngay trong hiệp đó, sau các quân Nguyên cũ (theo thứ tự id).
5. **Khi** xét điều kiện thắng Tiêu diệt (`RulesVictory`):
   - Diệt hết quân Nguyên trên bàn nhưng còn quân tiếp viện chưa xuất hiện trong `state.reinforcements` thì trận đấu chưa kết thúc (không xử `WON` sớm).
6. **Và** hệ thống hiển thị & hoạt ảnh:
   - Các ô có quân tiếp viện sắp tới được vẽ ký hiệu nhận diện trực quan riêng biệt trên bàn cờ.
   - Hoạt ảnh xuất hiện hoặc va chạm chặn tiếp viện được hiển thị rõ ràng.
7. **Và** có bộ kịch bản kiểm thử trong `game/tests/kich_ban/tiep_vien/`, tác giả duyệt theo quy trình M3 trước khi viết code (`da_duyet: true`); test GUT bao phủ toàn diện các ca biên; `tools/test.sh` xanh 100%; commit tiếng Việt kết `(Story 3.10)`.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và tạo kịch bản chờ duyệt** (AC: 1–5, 7)
  - [x] 1.1 Khảo sát cấu trúc `LevelLoader`, `ScenarioLoader`, `BattleState`, `RulesEnemyPhase`, `RulesVictory`, `BattleEvent`.
  - [x] 1.2 Tạo thư mục `game/tests/kich_ban/tiep_vien/` và viết các kịch bản với `"da_duyet": false`:
    - `tiep_vien_xuat_hien_o_trong.json`: Quân tiếp viện xuất hiện ở ô trống đầu hiệp 2, đi và báo đòn.
    - `tiep_vien_bi_tuong_chan.json`: Tướng ta đứng ở ô tiếp viện -> cuối hiệp 1 sang hiệp 2, tướng mất 1 máu, tiếp viện bị hủy.
    - `tiep_vien_bi_dich_chan.json`: Quân Nguyên đứng ở ô tiếp viện -> quân Nguyên mất 1 máu, tiếp viện bị hủy.
    - `tiep_vien_chan_guc_quan.json`: Quân 1 máu đứng chặn ô tiếp viện -> mất 1 máu và gục.
    - `ha_het_dich_nhung_con_tiep_vien_chua_thang.json`: Hiệp 1 diệt hết địch trên bàn nhưng còn tiếp viện hiệp 2 -> chưa thắng.
    - `nhieu_quan_tiep_vien_cung_hiep.json`: 2 quân tiếp viện cùng xuất hiện ở hiệp 2 theo thứ tự danh sách.
  - [x] 1.3 Trình tác giả duyệt kịch bản theo quy trình M3 qua `tools/xem_kich_ban.sh tiep_vien`.

- [x] **Task 2: Tác giả duyệt kịch bản (Quy trình M3)** (AC: 7)
  - [x] 2.1 Tác giả xem qua bàn cờ và duyệt kịch bản (`da_duyet: true`, ngày 2026-10-25 lúc 17:40).

- [x] **Task 3: Chứng minh trượt (TDD Red)** (AC: 1–7)
  - [x] 3.1 Chạy `tools/test.sh`: kiểm chứng cả 6 kịch bản tiếp viện đều trượt chính xác do chưa có cơ chế tiếp viện.

- [x] **Task 4: Cập nhật lõi luật `src/core/` và nạp dữ liệu `src/data/` (TDD Green)** (AC: 1–5)
  - [x] 4.1 Thêm cấu trúc `Reinforcement` vào `level_data.gd` và `reinforcements` vào `battle_state.gd` (bao gồm `clone()` và `validate()`).
  - [x] 4.2 Thêm các loại sự kiện trong `battle_event.gd`: `REINFORCEMENT_WARNED`, `REINFORCEMENT_SPAWNED`, `REINFORCEMENT_BLOCKED`, nguyên nhân `Cause.REINFORCEMENT`.
  - [x] 4.3 Cập nhật `LevelLoader` và `ScenarioLoader` đọc và xác thực khóa `"tiep_vien"`.
  - [x] 4.4 Cập nhật `RulesEnemyPhase`:
    - Trong `_end_of_round`: báo trước các ô tiếp viện của hiệp kế tiếp (`_warn_reinforcements`).
    - Trong `prepare`: xử lý bước 1a sinh quân tiếp viện hoặc gây 1 sát thương chặn tiếp viện (`_spawn_reinforcements`), quản lý `next_enemy_id`.
  - [x] 4.5 Cập nhật `RulesVictory`: trận Tiêu diệt chỉ thắng khi hết quân trên bàn VÀ không còn tiếp viện chưa xuất hiện.

- [x] **Task 5: Hiển thị bàn cờ & Kiểm thử GUT** (AC: 6, 7)
  - [x] 5.1 Cập nhật `board_view.gd` / `telegraph_view.gd` / `event_player.gd`: hiển thị dấu hiệu ô tiếp viện (viền cam vàng nổi bật, chevron chỉ xuống) và phát sự kiện tiếp viện.
  - [x] 5.2 Viết test GUT `game/tests/test_reinforcements.gd` bao phủ toàn diện: nạp tiếp viện, báo trước, xuất hiện, chặn bởi tướng/địch/gục, thứ tự hành động, điều kiện thắng Tiêu diệt.
  - [x] 5.3 Cập nhật `test_loaders.gd` kiểm tra các ca báo lỗi nạp `tiep_vien` bằng tiếng Việt.
  - [x] 5.4 Chạy `tools/test.sh` xanh 4/4 bước (708/708 test GUT, 135 kịch bản đã duyệt), không vi phạm ranh giới kiến trúc.

- [x] **Task 6: Tác giả nghiệm thu và hoàn tất story** (AC: 7)
  - [x] 6.1 Báo cáo tác giả bằng tiếng Việt theo phong cách người test hiểu được.
  - [x] 6.2 Cập nhật `sprint-status.yaml` và commit tiếng Việt kết `(Story 3.10)`.

### Review Findings

Code review 2026-10-25 (commit `0dc3c07`, so với `e7df841`). `tools/test.sh` xanh nhưng mô phỏng headless bằng luật thật xác nhận 3 lỗi nặng bên dưới (bàn thử trong scratchpad: `tv1.json`, `tv2.json`, `tv3.json`). Ba lớp review chạy trong cùng phiên (không mở được agent phụ).

- [x] [Review][Decision] (2026-10-25) Thời điểm báo tiếp viện: Chọn (a) báo ở pha chuẩn bị đầu hiệp N cho tiếp viện của hiệp N+1, dấu hiện suốt lượt người chơi hiệp N. Đã sửa kiến trúc dòng 841/846 và AC2 cho khớp.
- [x] [Review][Patch] Dấu tiếp viện không bao giờ hiện cho người chơi: Đã sửa pha chuẩn bị `prepare()` báo trước tiếp viện cho hiệp kế tiếp và lưu trong `state.reinforcement_warnings` duy trì suốt lượt người chơi pha PLAYER [game/src/core/rules_enemy_phase.gd].
- [x] [Review][Patch] Kẹt trận, không thắng được: Đã thêm `_check_victory_after_spawn()` xử lý thắng/thua sau bước 1a khi có tiếp viện xử lý (`not current_reinforcements.is_empty()`), chặn tiếp viện cuối trên bàn trống sẽ thắng ngay lập tức [game/src/core/rules_enemy_phase.gd].
- [x] [Review][Patch] Tiếp viện có `hiep` lớn hơn `so_hiep_toi_da` bị từ chối: Báo lỗi tiếng Việt lúc nạp trong `BoardLayers.read_reinforcements`; cập nhật `RulesVictory.check_round_limit` tính cả tiếp viện chưa xuất hiện là còn quân Nguyên [game/src/data/board_layers.gd, game/src/core/rules_victory.gd].
- [x] [Review][Patch] `ScenarioLoader`: Đã truyền đúng `terrain_clean` vào `_read_reinforcements`; chuyển hàm đọc tiếp viện sang `BoardLayers.read_reinforcements` dùng chung [game/src/data/scenario_loader.gd, game/src/data/board_layers.gd].
- [x] [Review][Patch] `EventPlayer.gd`: `REINFORCEMENT_SPAWNED` không gọi `_board.show_state(snapshot)` giữa chừng mà thêm token mới qua `_board.add_reinforcement_token()`, giữ nguyên hoạt ảnh đi từng bước của quân cũ [game/src/battle/event_player.gd, game/src/battle/board_view.gd].
- [x] [Review][Patch] Kiểm thử bổ sung: Đã thêm test GUT cho các ca biên (dấu báo trong snapshot, chặn tiếp viện cuối thắng trận, hiep vượt quá max rounds bị từ chối); thêm khóa `sau.bao_tiep_vien` cho `ScenarioRunner` và 2 kịch bản mới (`chan_tiep_vien_cuoi_khi_ban_trong_thang.json`, `bao_tiep_vien_hiep_sau.json`) với `da_duyet: false` [game/tests/test_reinforcements.gd, game/tests/test_loaders.gd, game/tests/scenario_runner.gd].
- [x] [Review][Patch] `reinforcement_warned`/`reinforcement_spawned` ghi `Cause.REINFORCEMENT`; `REINFORCEMENT_BLOCKED` dùng hoạt ảnh `_flash_blocked` riêng màu cam tiếp viện; thêm tooltip `tooltip.reinforcement_warning` qua `text.csv` [game/src/core/battle_event.gd, game/src/battle/event_player.gd, game/i18n/text.csv, game/src/battle/battle_view.gd].
- [x] [Review][Patch] Quy trình và hồ sơ: commit kịch bản mới riêng trước code (M3: commit `d5967f1`); tick Task 6 và hoàn thiện File List.

## Dev Agent Record

### Agent Model Used
Antigravity Agent (DeepMind / Gemini), 2026-10-25.

### Debug Log References
- **Nền trước story:** `tools/test.sh` 696/696 test GUT, 129 kịch bản đã duyệt (HEAD `e7df841`).
- **Lần Red (Task 3):** 6 kịch bản tiếp viện mới (`tiep_vien/`) trượt chính xác do chưa có luật tiếp viện:
  - `ha_het_dich_nhung_con_tiep_vien_chua_thang.json`: mong đợi "dang_choi", thực tế "thang"
  - `nhieu_quan_tiep_vien_cung_hiep.json`: ô 2,1 mong đợi B, thực tế trống
  - `tiep_vien_bi_dich_chan.json`: ô 3,0 B mong đợi 2 máu, thực tế 3 máu
  - `tiep_vien_bi_tuong_chan.json`: ô 3,0 1 mong đợi 2 máu, thực tế 3 máu
  - `tiep_vien_chan_guc_quan.json`: ô 3,0 mong đợi trống, thực tế B
  - `tiep_vien_xuat_hien_o_trong.json`: ô 3,0 mong đợi K, thực tế trống
- **Lần Green (Task 5):** `tools/test.sh` 4/4 bước đạt: 708/708 test GUT đạt, 135 kịch bản đã duyệt đạt, không vi phạm ranh giới kiến trúc.
- **Sau Code Review:** `tools/test.sh` 4/4 bước đạt: 710/710 test GUT đạt, 135 kịch bản đã duyệt đạt, 4 kịch bản chưa duyệt đạt 100%.

### File List
- `_bmad-output/planning-artifacts/game-architecture.md` (cập nhật dòng 841, 846 theo quyết định báo tiếp viện đầu hiệp)
- `_bmad-output/implementation-artifacts/3-10-quan-tiep-vien.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `game/i18n/text.csv` (thêm `tooltip.reinforcement_warning`)
- `game/src/core/battle_event.gd` (thêm các kiểu và nguyên nhân sự kiện tiếp viện, cập nhật `Cause.REINFORCEMENT`)
- `game/src/core/battle_state.gd` (thêm mảng tiếp viện, `reinforcement_warnings`, cập nhật clone/validate/from_level)
- `game/src/core/rules_enemy_phase.gd` (cập nhật `prepare`, `_spawn_reinforcements`, `_warn_reinforcements`, `_check_victory_after_spawn`)
- `game/src/core/rules_victory.gd` (điều kiện thắng Tiêu diệt tính cả tiếp viện chưa xuất hiện, `check_round_limit`)
- `game/src/data/board_layers.gd` (hàm `read_reinforcements` dùng chung)
- `game/src/data/level_data.gd` (lớp `Reinforcement`)
- `game/src/data/level_loader.gd` (nạp tiếp viện qua `BoardLayers`)
- `game/src/data/scenario_data.gd` (thêm hỗ trợ `bao_tiep_vien`)
- `game/src/data/scenario_loader.gd` (nạp `bao_tiep_vien` và dùng `BoardLayers.read_reinforcements`)
- `game/src/battle/board_view.gd` (vẽ viền và chevron tiếp viện, thêm `add_reinforcement_token`)
- `game/src/battle/battle_view.gd` (hiển thị tooltip tiếp viện khi rê chuột)
- `game/src/battle/event_player.gd` (hoạt ảnh `REINFORCEMENT_SPAWNED` qua token mới, `_flash_blocked` riêng)
- `game/tests/scenario_runner.gd` (so khớp `bao_tiep_vien`)
- `game/tests/test_loaders.gd` (kiểm tra lỗi nạp tiếp viện tiếng Việt)
- `game/tests/test_reinforcements.gd` (bộ test GUT toàn diện cho tiếp viện)
- `game/tests/kich_ban/tiep_vien/*.json` (8 kịch bản luật tiếp viện)

## Dev Notes

- **Ký hiệu & Định dạng dữ liệu:**
  - `tiep_vien`: danh sách các object `{"hiep": 2, "o": "3,0", "loai": "K"}`.
  - Ký hiệu quân: `"B"` (Bộ binh), `"K"` (Kỵ binh), `"C"` (Cung kỵ).
  - Tọa độ: `"cot,hang"` (chuỗi phân tách bởi dấu phẩy, giống `thu_tu_dich`).
- **Quy trình pha địch (game-architecture.md dòng 840–846):**
  - Bước 1a: Tiếp viện xử lý đầu tiên khi bước vào hiệp mới (`prepare()`). Ô có quân đứng: quân đó mất 1 máu, tiếp viện bị hủy.
  - Bước 1b: Chuẩn bị: quân tiếp viện vừa vào bàn đi và báo đòn ngay sau các quân cũ (theo thứ tự id).
  - Bước 4: Cuối hiệp: Kho lương hồi máu -> Báo ô tiếp viện hiệp sau -> Kiểm tra giới hạn hiệp.
- **Ranh giới kiến trúc:**
  - Chỉ `Effects.gd` sửa máu `.hp` (`Effects.damage`).
  - Id quân Nguyên tiếp viện bắt đầu nối tiếp các quân cũ (từ `101 + n`), đảm bảo tính đơn điệu và duy nhất.
