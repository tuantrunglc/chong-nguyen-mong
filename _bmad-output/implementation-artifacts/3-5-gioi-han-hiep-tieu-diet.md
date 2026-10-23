---
baseline_commit: 2a813e5
tested_commit: a95ede6
---

# Story 3.5: Giới hạn hiệp (Tiêu diệt)

Status: done

## Story

Là người chơi,
tôi muốn trận Tiêu diệt có số hiệp tối đa,
để không thể chỉ né đòn mãi mà phải chủ động tính đường hạ địch.

## Acceptance Criteria

1. **Cho** file trận Tiêu diệt có `so_hiep_toi_da: 4`
   **Thì** HUD hiện "Hiệp 1/4"; hiệp cuối có màu nổi bật (FR48).
2. **Khi** kết thúc bước cuối hiệp của hiệp 4 mà còn quân Nguyên trên bàn
   **Thì** hiện "Thua: hết hiệp" (kết cục `LOST`, bảng thông báo hiện lý do hết hiệp).
3. **Khi** quân Nguyên cuối cùng gục trong pha ra đòn của hiệp 4 (địch đánh trúng nhau)
   **Thì** tính là thắng (`VICTORY`, ưu tiên thắng trước khi kiểm tra hết hiệp).
4. **Khi** file trận không có `so_hiep_toi_da`
   **Thì** không giới hạn hiệp, HUD chỉ hiện "Hiệp 3" như cũ.
5. **Khi** `so_hiep_toi_da` không phải số nguyên dương (chuỗi, số âm, số 0, float lẻ)
   **Thì** bộ nạp báo lỗi tiếng Việt, ghi rõ file và giá trị sai.
6. **Và** chơi lại hiệp không làm đổi số hiệp hiện tại (`round_number` và `max_rounds` giữ nguyên).
7. **Và** có bộ kịch bản trong `tests/kich_ban/gioi_han_hiep/`, tác giả duyệt trước khi viết luật; `tools/test.sh` xanh.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và tạo kịch bản chờ duyệt** (AC: 1–5, 7)
  - [x] 1.1 Khảo sát hiện trạng: `LevelData`, `BattleState`, `LevelLoader`, `ScenarioLoader`, `RulesEnemyPhase`, `RulesVictory`, `Hud`, `ResultBanner`.
  - [x] 1.2 Tạo thư mục `game/tests/kich_ban/gioi_han_hiep/` và viết các kịch bản với `"da_duyet": false`:
    - `het_hiep_tieu_diet_thua.json`: Trận có `so_hiep_toi_da: 1`, hết hiệp 1 còn địch -> thua.
    - `hiep_cuoi_ha_het_dich_thang.json`: Trận có `so_hiep_toi_da: 1`, địch gục trong pha ra đòn hiệp 1 -> thắng.
    - `khong_gioi_han_hiep_sang_hiep_2.json`: Trận không có `so_hiep_toi_da`, hết hiệp 1 sang hiệp 2 bình thường.
  - [x] 1.3 Kiểm tra hiển thị kịch bản.

- [x] **Task 2: Tác giả duyệt kịch bản** (AC: 7)
  - [x] 2.1 Trình bày các kịch bản cho tác giả duyệt và chuyển `"da_duyet": true`.

- [x] **Task 3: Chứng minh trượt (TDD Red)** (AC: 1–7)
  - [x] 3.1 Chạy `tools/test.sh`: các kịch bản mới trượt đúng lý do khi chưa có luật.

- [x] **Task 4: Nạp dữ liệu `so_hiep_toi_da`** (AC: 1, 4, 5)
  - [x] 4.1 `LevelData`: thêm `max_rounds: int = 0`.
  - [x] 4.2 `BattleState`: thêm `max_rounds: int = 0`, `defeat_reason: String = ""`, cập nhật `clone()` và `from_level()`.
  - [x] 4.3 `LevelLoader`: đọc `so_hiep_toi_da`, kiểm tra số nguyên dương >= 1, báo lỗi tiếng Việt nếu sai kiểu hoặc <= 0.
  - [x] 4.4 `ScenarioLoader`: đọc `so_hiep_toi_da` trong `truoc`, chuyển vào `LevelData`.
  - [x] 4.5 Unit test `test_loaders.gd`: kiểm tra đọc thành công và các ca lỗi của `so_hiep_toi_da`.

- [x] **Task 5: Luật giới hạn hiệp trong lõi (`core/`)** (AC: 2, 3, 6)
  - [x] 5.1 Cập nhật `RulesEnemyPhase.end_player_turn`: sau khi `_strike_all` xong, gọi `RulesVictory.check_round_limit`: nếu `state.mission == ELIMINATE and max_rounds > 0 and round_number >= max_rounds` và còn quân Nguyên thì chuyển phase sang `LOST`, gán `defeat_reason = "het_hiep"` và sinh sự kiện `DEFEAT("het_hiep")`.
  - [x] 5.2 Đảm bảo `RulesVictory` ưu tiên thắng: nếu địch cuối gục trong `_strike_all`, `check()` chuyển thành `WON` và kết thúc ngay trước khi kiểm tra hết hiệp.
  - [x] 5.3 Unit test trong `test_round_limit.gd`.

- [x] **Task 6: Hiển thị trên HUD & ResultBanner** (AC: 1, 2, 4)
  - [x] 6.1 `i18n/text.csv`: thêm `hud.round_limit,Hiệp %d/%d`, `result.lost_round_limit,"Thua: hết hiệp"`.
  - [x] 6.2 `Hud.show_turn`: nhận thêm `max_rounds: int = 0`. Nếu `max_rounds > 0` hiện `"Hiệp %d/%d"`, nếu `round_number >= max_rounds` và chưa over tô màu nổi bật `FINAL_ROUND_COLOR`.
  - [x] 6.3 `ResultBanner`: nhận lý do thua `defeat_reason`, nếu `"het_hiep"` hiển thị `"Thua: hết hiệp"` (font 38pt tự căn chỉnh panel).
  - [x] 6.4 `BattleView._update_hud`: truyền `snapshot.max_rounds` vào `_hud.show_turn()`.
  - [x] 6.5 `Main._on_playback_finished`: truyền `snapshot.defeat_reason` vào `_result_banner.show_result()`.

- [x] **Task 7: Test GUT, hồi quy và test suite xanh** (AC: 1–7)
  - [x] 7.1 Tạo `game/tests/test_round_limit.gd` phủ đầy đủ các ca luật và giao diện.
  - [x] 7.2 Chạy `tools/check_boundaries.sh` và `tools/test.sh` xanh 100% (669/669 test đạt, 107/107 kịch bản đạt).

- [x] **Task 8: Review code và chốt story** (AC: 7)
  - [x] 8.1 Chạy review 3 lớp (Blind Hunter, Edge Case Hunter, Acceptance Auditor): cả 7 AC đều thỏa mãn, không có lỗi tiềm ẩn.
  - [x] 8.2 Cập nhật sprint status `done`.

## Dev Notes

### Kiến trúc & Phân giải
- `game-architecture.md:846`: "4. Cuối hiệp: Quân Nguyên kề ít nhất một kho lương hồi 1 máu... Trận có so_hiep_toi_da: nếu đây là hiệp cuối mà còn quân Nguyên thì thua (mặc định)".
- `game-architecture.md:861`: "Tiêu diệt có so_hiep_toi_da: kết thúc bước 4 của hiệp cuối mà còn quân Nguyên thì thua. Quân Nguyên chết vì đánh trúng nhau trong pha ra đòn của hiệp cuối vẫn tính. (mặc định)".

## Dev Agent Record

### Agent Model Used
Gemini 3.8 Flash (Medium)

### Debug Log References
- `test_round_limit.gd`: `defeat_events[0].reason` thay vì `defeat_reason` (BattleEvent dùng `reason`).

### Completion Notes List
- Hoàn thành đầy đủ tính năng `so_hiep_toi_da` cho trận Tiêu diệt từ core tới UI.
- Thêm 3 kịch bản đã duyệt và 8 test GUT mới.

### File List
- `game/src/core/level_data.gd`
- `game/src/core/battle_state.gd`
- `game/src/core/battle_event.gd`
- `game/src/core/rules_victory.gd`
- `game/src/core/rules_enemy_phase.gd`
- `game/src/data/level_loader.gd`
- `game/src/data/scenario_loader.gd`
- `game/src/ui/hud.gd`
- `game/src/ui/result_banner.gd`
- `game/src/battle/battle_view.gd`
- `game/src/app/main.gd`
- `game/i18n/text.csv`
- `game/tests/kich_ban/gioi_han_hiep/het_hiep_tieu_diet_thua.json`
- `game/tests/kich_ban/gioi_han_hiep/hiep_cuoi_ha_het_dich_thang.json`
- `game/tests/kich_ban/gioi_han_hiep/khong_gioi_han_hiep_sang_hiep_2.json`
- `game/tests/test_loaders.gd`
- `game/tests/test_result_banner.gd`
- `game/tests/test_round_limit.gd`
