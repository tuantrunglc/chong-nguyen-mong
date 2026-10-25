---
baseline_commit: 269d724
---

# Story 3.11: Nhiệm vụ Giữ ải

Status: done

## Story

Là người chơi,
tôi muốn có kiểu trận phải cầm cự,
để chịu áp lực khác với trận tiêu diệt.

## Acceptance Criteria

1. **Cho** trận Giữ ải (`"kieu": "giu_ai"`, `LevelData.Mission.HOLD_PASS`):
   - Địa hình trận có ít nhất một ô ải `A` (`Terrain.PASS`), `so_hiep_toi_da` mặc định là 5 nếu không ghi trong file.
   - Màn hình HUD hiển thị số hiệp dạng `hiệp/tổng` (ví dụ "1/5", "2/5").
2. **Khi** quân Nguyên vào ô ải (`Terrain.PASS`) bằng bất kỳ cách nào (FR37):
   - Tự đi vào trong pha chuẩn bị của địch;
   - Bị tướng Nguyễn Khoái đánh đẩy vào;
   - Bị tướng Trần Khánh Dư dùng đòn kéo vào;
   - **Thì** người chơi thua ngay lập tức (`state.phase = BattleState.Phase.LOST`, `BattleEvent.defeat("quan_nguyen_vao_ai")`).
3. **Khi** mọi tướng Đại Việt trên bàn đều gục (`_generals_lost(state)`):
   - **Thì** người chơi thua ngay lập tức (`defeat()`).
4. **Khi** qua hết bước cuối hiệp của hiệp 5 (hoặc `so_hiep_toi_da` của trận Giữ ải) (FR37):
   - Không có quân Nguyên nào vào ô ải và còn ít nhất một tướng trên bàn;
   - **Thì** người chơi thắng trận (`state.phase = BattleState.Phase.WON`, `BattleEvent.victory()`).
   - Tiêu diệt hết quân Nguyên trên bàn trước hiệp cuối không làm thắng sớm trong trận Giữ ải (người chơi kết thúc lượt cho đến hết hiệp 5 để hoàn thành cầm cự).
5. **Và** Enemy AI trong trận Giữ ải (FR23):
   - **Bộ binh và Kỵ binh:** Nhắm ô ải gần nhất (theo số bước đi `Pathfinding.distance_field`), hòa bước đi thì theo thứ tự B→Đ.
     - Ưu tiên ô đứng trong tầm đi mà từ đó đòn trúng ô ải;
     - Không có ô như vậy thì đi tới ô gần ô ải nhất (số bước ít hơn, hòa thì B→Đ).
   - **Cung kỵ:** Vẫn nhắm tướng Đại Việt gần nhất (theo số bước đi, hòa thì ít máu hơn, B→Đ).
6. **Và** quy trình và kiểm thử:
   - Viết bộ kịch bản luật trong `game/tests/kich_ban/giu_ai/` với `"da_duyet": false`, trình tác giả duyệt theo quy trình M3 trước khi viết code.
   - Thêm test GUT trong `game/tests/test_hold_pass.gd` bao phủ toàn diện mọi ca biên của Giữ ải.
   - `tools/test.sh` xanh 100%, không vi phạm ranh giới kiến trúc; commit tiếng Việt kết `(Story 3.11)`.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và tạo kịch bản chờ duyệt** (AC: 1–5, 6)
  - [x] 1.1 Khảo sát `LevelData.Mission.HOLD_PASS`, `RulesVictory`, `RulesEnemyPhase`, `EnemyAI`, `Effects`.
  - [x] 1.2 Tạo thư mục `game/tests/kich_ban/giu_ai/` và viết các kịch bản với `"da_duyet": false`:
    - `dich_tu_di_vao_ai_thua.json`: Bộ binh tự bước vào ô ải ở pha chuẩn bị -> thua ngay.
    - `day_dich_vao_ai_thua.json`: Khoái đánh đẩy Bộ binh vào ô ải -> thua ngay.
    - `keo_dich_vao_ai_thua.json`: Khánh Dư kéo Bộ binh vào ô ải -> thua ngay.
    - `tuong_vao_ai_khong_thua.json`: Tướng ta bước vào ô ải -> trận đấu tiếp tục bình thường.
    - `ai_bo_binh_nham_ai.json`: Trận giữ ải, Bộ binh nhắm ô ải thay vì tướng ở xa.
    - `ai_cung_ky_van_nham_tuong.json`: Trận giữ ải, Cung kỵ vẫn nhắm tướng gần nhất.
    - `het_hiep_toi_da_thang.json`: Cầm cự qua hết hiệp tối đa -> thắng trận.
    - `cam_cu_du_5_hiep_thang.json`: Cầm cự qua 5 hiệp mặc định -> thắng trận.
    - `diet_het_dich_chua_thang_som.json`: Hiệp 1 diệt hết quân Nguyên trên bàn nhưng chưa hết 5 hiệp -> trận đấu chưa thắng (tiếp tục chơi).
  - [x] 1.3 Trình tác giả duyệt kịch bản theo quy trình M3 qua `tools/xem_kich_ban.sh giu_ai`.

- [x] **Task 2: Tác giả duyệt kịch bản (Quy trình M3)** (AC: 6)
  - [x] 2.1 Tác giả xem qua bàn cờ và duyệt kịch bản (`da_duyet: true`, ngày 2026-10-25 lúc 20:04).

- [x] **Task 3: Chứng minh trượt (TDD Red)** (AC: 1–6)
  - [x] 3.1 Chạy `tools/test.sh`: 7 kịch bản trượt chính xác do chưa có luật Giữ ải:
    - `ai_bo_binh_nham_ai.json`: Bộ binh nhắm tướng thay vì ô ải.
    - `day_dich_vao_ai_thua.json`: đẩy địch vào ải mong đợi "thua", thực tế "dang_choi".
    - `keo_dich_vao_ai_thua.json`: kéo địch vào ải mong đợi "thua", thực tế "dang_choi".
    - `dich_tu_di_vao_ai_thua.json`: địch vào ải mong đợi "thua", thực tế "dang_choi".
    - `diet_het_dich_chua_thang_som.json`: hết địch mong đợi "dang_choi", thực tế "thang".
    - `het_hiep_toi_da_thang.json`: hết hiệp tối đa mong đợi "thang", thực tế "thua".
    - `cam_cu_du_5_hiep_thang.json`: mong đợi "thang" ở hiệp 5, thực tế chưa dừng.

- [x] **Task 4: Cập nhật lõi luật `src/core/` (TDD Green)** (AC: 1–5)
  - [x] 4.1 `RulesVictory`:
    - Kiểm tra thua khi quân Nguyên vào ô ải: `_enemy_entered_pass(state, events)`.
    - Kiểm tra thắng khi hết hiệp tối đa trong trận Giữ ải: `check_round_limit(state, events)`.
    - Đảm bảo `_enemies_cleared` chỉ áp dụng cho `Mission.ELIMINATE`.
  - [x] 4.2 `EnemyAI`:
    - Trong `plan()`: nếu `state.mission == LevelData.Mission.HOLD_PASS`, Bộ binh và Kỵ binh tìm và nhắm ô `Terrain.PASS` gần nhất; Cung kỵ nhắm tướng gần nhất.
    - Trong `can_hit_from`: ô Ải chỉ là mục tiêu ra đòn khi có tướng trấn giữ; ô Ải trống thì địch đi thẳng vào ải để chiếm.
  - [x] 4.3 `ScenarioLoader` / `LevelLoader`:
    - Đảm bảo `so_hiep_toi_da` mặc định là 5 cho trận `giu_ai` nếu không khai báo trong file.
    - `ScenarioLoader` hỗ trợ khóa `"kieu"` trong `"truoc"` và thiết lập đúng `level.mission`.

- [x] **Task 5: Giao diện HUD & Kiểm thử GUT** (AC: 1, 6)
  - [x] 5.1 HUD hiển thị số hiệp dạng `hiệp/tổng` (ví dụ "1/5") cho trận Giữ ải qua logic `max_rounds > 0`.
  - [x] 5.2 Viết test GUT `game/tests/test_hold_pass.gd` bao phủ toàn bộ các luật và ca biên (7 test cases).
  - [x] 5.3 Thêm test nạp kịch bản và level trận giữ ải trong `test_loaders.gd` và `test_scenario_loader.gd`.
  - [x] 5.4 Chạy `tools/test.sh` xanh 100% 4/4 bước (720/720 test GUT, 144 kịch bản đã duyệt).

- [x] **Task 6: Tác giả nghiệm thu và hoàn tất story** (AC: 6)
  - [x] 6.1 Báo cáo tác giả bằng tiếng Việt theo phong cách người test hiểu được.
  - [x] 6.2 Cập nhật `sprint-status.yaml` và commit tiếng Việt kết `(Story 3.11)`.

## Dev Agent Record

### Agent Model Used
Antigravity Agent (DeepMind / Gemini), 2026-10-25.

### Debug Log References
- **Nền trước story:** `tools/test.sh` 710/710 test GUT, 135 kịch bản đã duyệt (HEAD `269d724`).
- **Lần Red (Task 3):** 7/9 kịch bản `giu_ai/` trượt chính xác do chưa có luật Giữ ải:
  - `ai_bo_binh_nham_ai.json`: Bộ binh nhắm tướng thay vì ô ải
  - `day_dich_vao_ai_thua.json`: mong đợi "thua", thực tế "dang_choi"
  - `keo_dich_vao_ai_thua.json`: mong đợi "thua", thực tế "dang_choi"
  - `dich_tu_di_vao_ai_thua.json`: mong đợi "thua", thực tế "dang_choi"
  - `diet_het_dich_chua_thang_som.json`: mong đợi "dang_choi", thực tế "thang"
  - `het_hiep_toi_da_thang.json`: mong đợi "thang", thực tế "thua"
  - `cam_cu_du_5_hiep_thang.json`: mong đợi "thang" ở hiệp 5, thực tế chưa dừng
- **Lần Green (Task 4, 5):** `tools/test.sh` 4/4 bước đạt: 720/720 test GUT đạt, 144 kịch bản đã duyệt đạt, 0 vi phạm ranh giới kiến trúc.

### File List
- `_bmad-output/implementation-artifacts/3-11-nhiem-vu-giu-ai.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `game/src/core/rules_victory.gd` (kiểm tra quân Nguyên vào ô ải thua ngay, hết hiệp tối đa thắng trận Giữ ải)
- `game/src/core/rules_enemy_phase.gd` (kiểm tra địch vào ải lúc đi ở `prepare`)
- `game/src/core/enemy_ai.gd` (AI Bộ binh và Kỵ binh nhắm ô Ải gần nhất; ô ải trống thì đi vào chiếm ải)
- `game/src/data/level_loader.gd` (mặc định 5 hiệp cho trận `giu_ai`)
- `game/src/data/scenario_loader.gd` (hỗ trợ `truoc.kieu: "giu_ai"`, mặc định 5 hiệp)
- `game/tests/test_hold_pass.gd` (bộ test GUT cho nhiệm vụ Giữ ải)
- `game/tests/test_loaders.gd` (test nạp mặc định 5 hiệp cho trận Giữ ải)
- `game/tests/test_scenario_loader.gd` (test nạp kịch bản Giữ ải)
- `game/tests/kich_ban/giu_ai/*.json` (9 kịch bản luật Giữ ải đã được duyệt)

## Dev Notes

- **Quy tắc Giữ ải (FR37):**
  - Trận Giữ ải có `state.mission == LevelData.Mission.HOLD_PASS`.
  - Ô Ải (`Terrain.PASS`, ký hiệu `"A"`) là ô đi được (`Terrain.is_walkable`), có độ cao `PASS_HEIGHT`.
  - Bất kỳ quân Nguyên nào đi vào, bị đẩy vào, hoặc bị kéo vào ô Ải -> bên ta THUA NGAY LẬP TỨC (`defeat_reason = "quan_nguyen_vao_ai"`).
  - Tướng ta vào ô ải không thua; tướng trấn giữ ô ải là chiến thuật hợp lệ.
  - Cầm cự hết số hiệp tối đa (mặc định 5 hiệp) -> THẮNG.
