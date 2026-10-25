---
baseline_commit: e7df841
---

# Story 3.10: Quân tiếp viện

Status: review

## Story

Là người chơi,
tôi muốn biết trước quân tiếp viện sẽ xuất hiện ở đâu,
để đứng chặn ô đó hoặc chuẩn bị đối phó.

## Acceptance Criteria

1. **Cho** file trận hoặc kịch bản có lịch tiếp viện (`tiep_vien`):
   - Mỗi mục tiếp viện gồm: `hiep` (số nguyên ≥ 2), `o` (tọa độ `"cot,hang"`), `loai` (ký hiệu `"B"`, `"K"`, `"C"`). Máu mặc định đầy theo `Stats`.
   - `LevelLoader` và `ScenarioLoader` nạp và kiểm tra dữ liệu hợp lệ: `hiep` ≥ 2, ô nằm trong bàn và là ô đi được (`Terrain.is_walkable`), loại quân Nguyên hợp lệ; báo lỗi tiếng Việt nếu sai.
2. **Khi** tới bước 4 cuối hiệp (`_end_of_round`):
   - Sau khi quân địch kề kho lương hồi máu và trước khi kiểm tra giới hạn hiệp, các ô tiếp viện của hiệp sau (`hiep == state.round_number + 1`) được báo trước (phát sự kiện `BattleEvent.reinforcement_warned`, đánh dấu ký hiệu riêng khác ô đỏ báo đòn, FR35).
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

- [ ] **Task 6: Tác giả nghiệm thu và hoàn tất story** (AC: 7)
  - [ ] 6.1 Báo cáo tác giả bằng tiếng Việt theo phong cách người test hiểu được.
  - [ ] 6.2 Cập nhật `sprint-status.yaml` và commit tiếng Việt kết `(Story 3.10)`.

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
