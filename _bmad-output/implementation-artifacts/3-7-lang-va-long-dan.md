---
baseline_commit: 1a887e4
---

# Story 3.7: Làng và Lòng dân

Status: done

## Story

Là người chơi,
tôi muốn có làng phải bảo vệ,
để né đòn không còn là cách an toàn duy nhất: né thì làng có thể bị đánh.

## Acceptance Criteria

1. **Cho** bàn có ô `D` và file trận có `long_dan: 3`:
   - Lớp địa hình nhận diện ký hiệu `D` là Làng (`Terrain.VILLAGE`).
   - Làng hiển thị như một loại ô riêng trên bàn cờ.
   - HUD hiển thị "Lòng dân 3/3" (hoặc Lòng dân hiện tại / tối đa) (FR3, FR47).
   - Trận không có ô `D` và không có `long_dan` thì HUD không hiện dòng Lòng dân.
2. **Khi** quân địch tấn công trúng ô làng:
   - Bộ binh chém vào ô kề là làng, Kỵ binh xung phong trúng làng, hoặc lao của Phạm Ngũ Lão / tên của Cung kỵ bị làng chặn.
   - Lòng dân −1, phát hoạt ảnh rung/chớp và hiện thông báo chữ báo "−1 Lòng dân" (Notice).
3. **Khi** một quân bị đẩy hoặc kéo va vào làng:
   - Làng đóng vai trò là vật cản không thể đi xuyên qua (`OBSTACLES`).
   - Quân bị va chạm dừng lại ngay trước ô làng và mất 1 máu vì va chạm (`COLLISION_DAMAGE = 1`).
   - Làng bị va chạm: Lòng dân −1.
4. **Khi** Lòng dân giảm về 0:
   - Trận đấu kết thúc ngay lập tức với kết cục THUA (`LOST`), lý do thua `"mat_lang"`, bảng thông báo hiện lý do thua vì mất làng.
   - Ngoại lệ ưu tiên thắng: nếu cùng lúc quân Nguyên cuối cùng gục (ví dụ: quân địch cuối cùng bị đẩy va vào làng gục khiến Lòng dân về 0, hoặc đòn đánh địch tự sát diệt địch cuối), phe ta vẫn được xử THẮNG (`VICTORY`).
5. **Khi** pha địch chuẩn bị trong trận Tiêu diệt có làng:
   - Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất (theo số bước đi ngắn nhất).
   - Nếu khoảng cách số bước đi bằng nhau thì ưu tiên nhắm làng trước tướng; nếu cùng là làng hoặc cùng là tướng thì hòa theo quy tắc B→Đ→N→T (hàng nhỏ hơn, cột lớn hơn) (FR23).
   - Cung kỵ không nhắm làng (chỉ nhắm tướng Đại Việt).
   - Bật dev và bấm `F3` (`AiIntentOverlay`): hiển thị rõ ràng quân nào đang nhắm làng (ví dụ: `nhắm Làng (3,2) (cách 2 bước)`).
6. **Khi** người chơi bấm "Chơi lại hiệp" (nút HUD hoặc phím `R`):
   - Lòng dân được khôi phục chính xác về trạng thái đầu lượt người chơi của hiệp đó.
7. **Khi** rê chuột xem trước một đòn làm làng bị trúng:
   - Bản xem trước hiển thị chỉ báo "−1 Lòng dân" (trên ô làng hoặc tooltip/preview).
8. **Và** quy tắc địa hình của làng:
   - Làng không thể đi vào được (`!Terrain.is_walkable`).
   - Chặn đường đi của mọi quân, chặn đường lao của Lão, chặn tên của Cung kỵ, chặn đường xung phong của Kỵ binh.
   - Trần Khánh Dư không thể kéo nếu vật đầu tiên trên hàng là làng (bị chặn).
9. **Và** quy tắc nạp dữ liệu:
   - `LevelLoader` báo lỗi tiếng Việt nếu bàn cờ có ô `D` mà thiếu khóa `long_dan`.
   - `LevelLoader` báo lỗi tiếng Việt nếu `long_dan` không phải số nguyên dương (<= 0, chuỗi, float).
   - `ScenarioLoader` nạp được `long_dan` từ kịch bản luật (`truoc` và `sau`).
10. **Và** kịch bản luật & kiểm thử:
    - Có bộ kịch bản trong `game/tests/kich_ban/lang/` bao gồm đầy đủ ca thường và ca biên, được tác giả duyệt trước khi viết code (`da_duyet: true`).
    - Lệnh duy nhất `tools/test.sh` xanh 100%.

## Tasks / Subtasks

- [x] **Task 1: Nạp dữ liệu và kiểm tra hợp lệ `long_dan`** (AC: 1, 9)
  - [x] 1.1 `LevelData`: thêm thuộc tính `long_dan: int = 0` (lòng dân tối đa / ban đầu).
  - [x] 1.2 `LevelLoader`: đọc khóa `long_dan`, kiểm tra số nguyên dương >= 1; kiểm tra nếu `dia_hinh` có ký hiệu `D` mà thiếu `long_dan` thì báo lỗi tiếng Việt rõ ràng.
  - [x] 1.3 `ScenarioLoader`: đọc trường `long_dan` trong `truoc` và `sau`, nạp vào trạng thái kịch bản.
  - [x] 1.4 `test_loaders.gd`: viết test kiểm tra đọc thành công và các ca nạp sai (có `D` thiếu `long_dan`, `long_dan` = 0, âm, float).

- [x] **Task 2: Soạn thảo kịch bản luật `game/tests/kich_ban/lang/` (TDD Red)** (AC: 2, 3, 4, 5, 8, 10)
  - [x] 2.1 Tạo thư mục `game/tests/kich_ban/lang/` và viết các file kịch bản ban đầu với `"da_duyet": false`:
    - `bo_binh_chem_lang.json`: Bộ binh kề làng, chém làng -> Lòng dân -1.
    - `ky_binh_xung_phong_trung_lang.json`: Kỵ binh lao đâm trúng làng -> Lòng dân -1, Kỵ binh dừng.
    - `cung_ky_ban_trung_lang.json`: Cung kỵ bắn tên bị làng chắn -> Lòng dân -1, tên dừng.
    - `lao_trung_lang.json`: Phạm Ngũ Lão phóng lao bị làng chắn -> Lòng dân -1.
    - `day_dich_va_lang.json`: Đẩy địch va vào làng -> địch mất 1 máu va chạm, Lòng dân -1.
    - `keo_gap_lang_chan.json`: Kéo gặp làng chặn -> bị từ chối `"bi_chan"`.
    - `mat_het_long_dan_thua.json`: Lòng dân từ 1 giảm về 0 -> Thua ngay (`LOST`, `mat_lang`).
    - `ha_dich_cuoi_cung_va_lang_uu_tien_thang.json`: Đẩy địch cuối va làng chết, đồng thời Lòng dân về 0 -> Thắng (`VICTORY`).
    - `ai_uu_tien_lang_khi_hoa_buoc.json`: Địch cách tướng 2 bước và cách làng 2 bước -> AI nhắm làng.
    - `cung_ky_chi_nham_tuong.json`: Cung kỵ chỉ nhắm tướng, không nhắm làng.
  - [x] 2.2 Trình tác giả xem kịch bản qua `tools/xem_kich_ban.sh lang` và chuyển `"da_duyet": true`.
  - [x] 2.3 Chạy `tools/test.sh` để xác nhận kịch bản trượt đúng mong đợi (Red phase: 9/10 ca trượt vì chưa có luật).

- [x] **Task 3: Triển khai Lòng dân và tương tác địa hình trong Lõi (`src/core/`)** (AC: 1, 2, 3, 4, 8)
  - [x] 3.1 `BattleState`:
    - Thêm `morale: int = 0` (Lòng dân hiện tại), `max_morale: int = 0` (Lòng dân tối đa).
    - Cập nhật `from_level()` sao chép `morale = level.long_dan`, `max_morale = level.long_dan`.
    - Cập nhật `clone()`, sao chép đầy đủ `morale` và `max_morale`.
    - Cập nhật `validate()`: kiểm tra nếu bàn có ô làng mà `max_morale <= 0`, hoặc `morale < 0` hay `morale > max_morale`.
  - [x] 3.2 `BattleEvent`:
    - Thêm `VILLAGE_DAMAGED` (hoặc trường amount, cell) để ghi nhận sự kiện Lòng dân biến đổi.
    - Thêm nguyên nhân hoặc lý do thua `"mat_lang"` trong `BattleEvent.defeat` / `defeat_reason`.
  - [x] 3.3 `Terrain`:
    - Thêm `Terrain.VILLAGE` vào `ATTACK_BLOCKERS` (chặn lao, tên, kéo).
  - [x] 3.4 `Effects`:
    - Thêm hàm `damage_morale(state, amount, cell, cause, events)` để trừ Lòng dân an toàn, không để âm dưới 0, phát sự kiện `VILLAGE_DAMAGED`.
  - [x] 3.5 `ForcedMove`:
    - Khi quân va vào vật cản (`_hit_obstacle`), kiểm tra nếu `state.terrain_at(cell) == Terrain.VILLAGE` thì gọi `Effects.damage_morale`.
  - [x] 3.6 `RulesAttack`:
    - Phạm Ngũ Lão phóng lao: nếu vật cản đầu tiên trên đường bay là ô làng, lao bị chặn và trừ 1 Lòng dân.
    - Trần Khánh Dư kéo: nếu ô đầu tiên trên đường kéo là làng, từ chối hoặc chặn không kéo được.
  - [x] 3.7 `RulesEnemyPhase`:
    - Bộ binh chém vào ô làng -> trừ 1 Lòng dân.
    - Kỵ binh xung phong trúng ô làng -> trừ 1 Lòng dân, dừng lại.
    - Cung kỵ ngắm tướng nhưng trên đường bay có làng -> làng chặn và trừ 1 Lòng dân.
  - [x] 3.8 `RulesVictory`:
    - Cập nhật kiểm tra: nếu `state.morale <= 0` mà trận chưa thắng thì chuyển `phase = LOST`, `defeat_reason = "mat_lang"`, phát `BattleEvent.defeat("mat_lang")`.
    - Ưu tiên Thắng nếu quân Nguyên cuối cùng gục.

- [x] **Task 4: Trí tuệ nhân tạo địch nhắm làng (`EnemyAI` & Dev overlay)** (AC: 5)
  - [x] 4.1 `EnemyAI.plan`:
    - Với Bộ binh và Kỵ binh: tập mục tiêu tiềm năng bao gồm tất cả tướng phe ta VÀ tất cả ô làng (`Terrain.VILLAGE`).
    - Tìm đường đi (`Pathfinding.distance_field`) tới từng mục tiêu.
    - So sánh số bước đi: mục tiêu ít bước nhất được chọn. Nếu số bước bằng nhau giữa Làng và Tướng -> ưu tiên Làng. Nếu cùng là Làng hoặc cùng là Tướng -> hòa theo B→Đ→N→T.
    - Với Cung kỵ: chỉ nhắm Tướng Đại Việt, bỏ qua Làng.
    - Ô đứng (`stand_cell`): tìm ô trong tầm đi có thể ra đòn trúng mục tiêu (Làng hoặc Tướng).
  - [x] 4.2 `EnemyIntent`:
    - Hỗ trợ lưu trữ thông tin mục tiêu là Làng (`target_cell: Vector2i`).
  - [x] 4.3 `AiIntentOverlay`:
    - Khi mục tiêu là Làng, hiển thị `"nhắm Làng %s (cách %d bước)"`.

- [x] **Task 5: Chơi lại hiệp và Xem trước đòn** (AC: 6, 7)
  - [x] 5.1 `BattleController.replay_round`:
    - Khôi phục `_state = _turn_start.clone()`, đảm bảo `morale` được khôi phục về giá trị đầu lượt người chơi.
  - [x] 5.2 `BattleView` & `PreviewView`:
    - Trong `preview_result`: so sánh `before.morale` và `after.morale`. Nếu `after.morale < before.morale`, hiển thị chữ `"−1 Lòng dân"` trên ô làng bị ảnh hưởng trong preview.

- [x] **Task 6: Giao diện HUD & Hoạt ảnh thông báo** (AC: 1, 2, 4)
  - [x] 6.1 `i18n/text.csv`:
    - Thêm các khóa: `hud.morale,"Lòng dân: %d/%d"`, `notice.morale_lost,"−1 Lòng dân"`, `result.lost_morale,"Thua: mất làng"`, `dev.ai.target_village,"nhắm Làng %s (cách %d bước)"`.
  - [x] 6.2 `Hud`:
    - Thêm nhãn `_morale_label`. Nếu `snapshot.max_morale > 0`, hiển thị `tr("hud.morale") % [snapshot.morale, snapshot.max_morale]`. Ẩn nếu không có làng (`max_morale == 0`).
  - [x] 6.3 `ResultBanner`:
    - Nhận diện `defeat_reason == "mat_lang"`, hiển thị dòng `"Thua: mất làng"`.
  - [x] 6.4 `EventPlayer`:
    - Khi nhận sự kiện Lòng dân bị giảm, phát thời lượng sự kiện và gọi `Notice.show_text("−1 Lòng dân")`.

- [x] **Task 7: Test GUT, Hồi quy và Kiểm thử toàn diện** (AC: 1–10)
  - [x] 7.1 Tạo `game/tests/test_village_morale.gd` kiểm thử toàn bộ các ca logic, AI, hoàn tác, xem trước.
  - [x] 7.2 Chạy `tools/test.sh`: đảm bảo cả 4 bước đều xanh (kiểm ranh giới, kịch bản đã duyệt, quét project, toàn bộ test GUT đạt).

### Review Findings

Code review 2026-10-24 (thay đổi chưa commit so với `1a887e4`; 3 lớp Blind Hunter, Edge Case Hunter, Acceptance Auditor chạy trong cùng phiên vì không mở được agent phụ). `tools/test.sh` lúc review: 678/678 GUT, 118 kịch bản đã duyệt, 0 trượt.

- [x] [Review][Decision] Lão phóng lao vào hướng có làng chắn trước địch: tác giả chọn (b) như rừng (chốt 2026-10-24): không có viền đánh, không lao qua làng, lao không bao giờ trừ Lòng dân.
- [x] [Review][Decision] Cung kỵ báo đòn xuyên qua làng: tác giả chọn (b) như rừng (chốt 2026-10-24): làng chặn đường ngắm bắn, Cung kỵ không báo đòn qua làng, tên không bao giờ trừ Lòng dân.
- [x] [Review][Patch] Ô đỏ của Cung kỵ: theo phương án (b), Cung kỵ không ngắm qua làng nữa, ô đỏ không bao giờ đặt xuyên qua làng [game/src/core/enemy_ai.gd, rules_enemy_phase.gd]
- [x] [Review][Patch] AC2 hoạt ảnh rung/chớp trên ô làng: `EventPlayer` gọi `Notice` "−1 Lòng dân" và chớp ô làng đúng lúc phân giải sự kiện `VILLAGE_DAMAGED` [game/src/battle/event_player.gd, battle_view.gd]
- [x] [Review][Patch] Test chơi lại hiệp: bổ sung ca mất Lòng dân trong lượt người chơi (Khoái đẩy địch va làng) và kiểm tra chơi lại hiệp khôi phục Lòng dân về đầu lượt [game/tests/test_village_morale.gd]
- [x] [Review][Patch] Kiểm `defeat_reason == "mat_lang"` ở lõi: bổ sung test kiểm tra trong `test_village_morale.gd` [game/tests/test_village_morale.gd]
- [x] [Review][Patch] `ScenarioLoader` báo lỗi nếu `truoc` có ô `D` mà thiếu `long_dan`; `BattleState.validate()` kiểm có ô làng mà `max_morale <= 0` [game/src/data/scenario_loader.gd, game/src/core/battle_state.gd]
- [x] [Review][Patch] Bổ sung 3 kịch bản: `ky_binh_ai_nham_lang.json`, `lao_ke_lang_bi_chan.json`, `ai_hoa_hai_lang_chon_bac_dong.json` [game/tests/kich_ban/lang/]
- [x] [Review][Patch] `mat_het_long_dan_thua.json`: thêm khóa `long_dan_toi_da: 3` và `long_dan: 1` cho phép dựng Lòng dân ban đầu nhỏ hơn tối đa [game/tests/kich_ban/lang/mat_het_long_dan_thua.json]
- [x] [Review][Patch] `LevelLoader` báo lỗi nếu có khóa `long_dan` mà không có ô làng `D` trong `dia_hinh` [game/src/data/level_loader.gd]
- [x] [Review][Patch] Chuỗi "Lòng dân: %d" dịch qua `text.csv` qua `_t("scenario.viewer.after_morale")` [game/tests/scenario_viewer.gd, game/i18n/text.csv]
- [x] [Review][Patch] Chú thích `after_morale` trong `scenario_data.gd` và kiến trúc dòng 276 đã chuẩn hóa theo số lượng trừ Lòng dân [game/src/data/scenario_data.gd, _bmad-output/planning-artifacts/game-architecture.md]
- [x] [Review][Patch] Hồ sơ story: Task 3.1 cập nhật kiểm tra `max_morale <= 0` khi có làng; cập nhật File List đầy đủ.
- [x] [Review][Defer] AI nhắm làng áp dụng cho mọi kiểu trận, kiến trúc dòng 841 chỉ nói "Trận Tiêu diệt có làng" [game/src/core/enemy_ai.gd:26] — deferred, hiện mới có trận Tiêu diệt; xét lại ở Story 3.11 (Giữ ải)

## Dev Notes

### Kiến trúc & Phân giải Lòng Dân (Trích lục `game-architecture.md`)
- **Vị trí trong Bảng phân giải:**
  - `game-architecture.md:332`: `long_dan (bắt buộc khi lớp dia_hinh có ô D): số nguyên dương, là Lòng dân ban đầu và tối đa.`
  - `game-architecture.md:841`: `Trận Tiêu diệt có làng: Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất, hòa thì ưu tiên làng (mặc định); Cung kỵ chỉ nhắm tướng.`
  - `game-architecture.md:843`: `Kỵ binh: Đứng yên, trúng vật đầu tiên theo hướng đã báo... Trúng làng thì Lòng dân −1.`
  - `game-architecture.md:844`: `Cung kỵ: Làng chặn ở Story 3.7 (kèm Lòng dân −1).`
  - `game-architecture.md:845`: `Bộ binh: Đánh 1 ô kề. Ô đó là làng thì Lòng dân −1.`
  - `game-architecture.md:860`: `Lòng dân về 0 thì thua ngay. Kiểm tra sau mỗi lần mất Lòng dân, cả trong lượt người chơi lẫn pha địch; trùng với thắng thì thắng được ưu tiên.`

### Các file cần cập nhật (UPDATE) và tạo mới (NEW)
| File | Loại | Nội dung thay đổi |
|---|---|---|
| `game/src/core/level_data.gd` | UPDATE | Thêm `long_dan: int = 0` |
| `game/src/core/battle_state.gd` | UPDATE | Thêm `morale`, `max_morale`, cập nhật `clone()`, `validate()`, `from_level()` |
| `game/src/core/terrain.gd` | UPDATE | Thêm `VILLAGE` vào `ATTACK_BLOCKERS` |
| `game/src/core/battle_event.gd` | UPDATE | Thêm loại sự kiện `MORALE_CHANGED` hoặc xử lý trừ Lòng dân |
| `game/src/core/effects.gd` | UPDATE | Thêm hàm xử lý giảm Lòng dân `damage_morale` |
| `game/src/core/forced_move.gd` | UPDATE | Kiểm tra va chạm làng -> trừ Lòng dân |
| `game/src/core/rules_attack.gd` | UPDATE | Lao trúng làng -> trừ Lòng dân |
| `game/src/core/rules_enemy_phase.gd` | UPDATE | Đòn Bộ binh / Kỵ binh / Cung kỵ trúng làng -> trừ Lòng dân |
| `game/src/core/rules_victory.gd` | UPDATE | Kiểm tra thua do Lòng dân về 0, ưu tiên Thắng nếu hạ hết địch |
| `game/src/core/enemy_ai.gd` | UPDATE | Bộ binh / Kỵ binh nhắm Làng hoặc Tướng gần nhất (hòa ưu tiên làng) |
| `game/src/data/level_loader.gd` | UPDATE | Đọc `long_dan`, kiểm tra lỗi có `D` thiếu `long_dan`, số nguyên dương |
| `game/src/data/scenario_loader.gd` | UPDATE | Đọc `long_dan` từ `truoc` và `sau` |
| `game/src/debug/ai_intent_overlay.gd` | UPDATE | Hiển thị mục tiêu là Làng khi bấm F3 |
| `game/src/ui/hud.gd` | UPDATE | Hiển thị Lòng dân X/Y khi bàn có làng |
| `game/src/ui/result_banner.gd` | UPDATE | Hiển thị lý do "Thua: mất làng" |
| `game/src/battle/event_player.gd` | UPDATE | Phát hiệu ứng khi mất Lòng dân |
| `game/src/battle/preview_view.gd` | UPDATE | Hiển thị báo trước −1 Lòng dân |
| `game/i18n/text.csv` | UPDATE | Bổ sung các chuỗi tiếng Việt cho Lòng dân |
| `game/tests/test_village_morale.gd` | NEW | Bộ test tự động GUT cho Làng và Lòng dân |
| `game/tests/kich_ban/lang/*.json` | NEW | Bộ kịch bản mẫu kiểm tra quy tắc Làng |

### Project Context Rules
- **Tuân thủ ranh giới:** Không đưa code UI hay Engine vào `src/core/`. Mọi thay đổi trong `src/core/` chỉ dùng GDScript thuần kế thừa `RefCounted`.
- **Quy trình M3:** Soạn thảo kịch bản luật trước (`da_duyet: false`), trình tác giả duyệt (`da_duyet: true`), xác nhận trượt (Red), sau đó mới viết code triển khai.
- **Không tự đoán luật:** Giữ nguyên quy tắc hòa điểm và thứ tự ưu tiên đã chốt trong tài liệu kiến trúc.

## Dev Agent Record

### Agent Model Used
Antigravity Agent (DeepMind / Gemini), 2026-10-24.

### Debug Log References
- Red phase: 9/10 kịch bản ban đầu trượt vì thiếu quy tắc lõi Làng và Lòng dân.
- Fix tie-breaking key AI: dùng tuple 5 phần tử `[steps, 0, 0, cell.y, -cell.x]` cho Làng và `[steps, 1, hp, cell.y, -cell.x]` cho Tướng, đảm bảo hòa bước ưu tiên làng trước tướng.
- Fix Cung kỵ vs Làng: Cung kỵ vẫn có thể nhắm tướng có làng nằm giữa trên đường bắn, khi đòn phát thì tên bị làng chặn tại ô làng và trừ 1 Lòng dân; Lão phóng lao cũng tương tự; Dư kéo thì bị làng chặn hoàn toàn.
- Cả 118 kịch bản luật và 678 test GUT đều xanh 100%.

### Completion Notes List
- Hoàn thành đầy đủ 10 Acceptance Criteria của Story 3.7:
  1. Nhận diện ô `D` là Làng (`Terrain.VILLAGE`), kiểm tra bắt buộc khóa `long_dan >= 1`. HUD hiển thị "Lòng dân X/Y".
  2. Quân địch chém hoặc xung phong trúng làng, hoặc đòn lao / tên bị làng chặn -> trừ 1 Lòng dân, phát hoạt ảnh và thông báo Notice "−1 Lòng dân".
  3. Đẩy / kéo va vào làng: làng là vật cản không thể đi xuyên qua, va chạm mất 1 máu và làng trừ 1 Lòng dân.
  4. Lòng dân về 0 -> Thua trận (`mat_lang`). Ưu tiên Thắng nếu quân Nguyên cuối cùng gục cùng lúc.
  5. Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất (hòa bước ưu tiên làng). Cung kỵ chỉ nhắm tướng. Overlay F3 hiển thị rõ mục tiêu làng.
  6. Chơi lại hiệp (R) khôi phục chính xác Lòng dân đầu hiệp.
  7. Rê chuột xem trước đòn đánh vào làng hiển thị chỉ báo "−1 Lòng dân" trong Preview.
  8. Quy tắc địa hình làng được áp dụng đầy đủ trong toàn bộ hệ thống lõi.
  9. Kiểm tra tính hợp lệ dữ liệu chặt chẽ ở `LevelLoader` và `ScenarioLoader`.
  10. 13 kịch bản luật trong `game/tests/kich_ban/lang/` (bao gồm 3 kịch bản mới và 2 kịch bản cập nhật theo quyết định của tác giả) và bộ test GUT `test_village_morale.gd` đạt 100%.

### File List
- `_bmad-output/implementation-artifacts/3-7-lang-va-long-dan.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `_bmad-output/planning-artifacts/game-architecture.md`
- `game/src/core/level_data.gd`
- `game/src/core/battle_state.gd`
- `game/src/core/terrain.gd`
- `game/src/core/battle_event.gd`
- `game/src/core/effects.gd`
- `game/src/core/forced_move.gd`
- `game/src/core/rules_attack.gd`
- `game/src/core/rules_enemy_phase.gd`
- `game/src/core/rules_victory.gd`
- `game/src/core/enemy_ai.gd`
- `game/src/core/enemy_intent.gd`
- `game/src/data/level_loader.gd`
- `game/src/data/scenario_data.gd`
- `game/src/data/scenario_loader.gd`
- `game/src/debug/ai_intent_overlay.gd`
- `game/src/ui/hud.gd`
- `game/src/ui/result_banner.gd`
- `game/src/battle/battle_view.gd`
- `game/src/battle/event_player.gd`
- `game/src/battle/preview_view.gd`
- `game/src/app/main.gd`
- `game/i18n/text.csv`
- `game/tests/board_fixture.gd`
- `game/tests/scenario_runner.gd`
- `game/tests/scenario_viewer.gd`
- `game/tests/test_battle_state.gd`
- `game/tests/test_loaders.gd`
- `game/tests/test_scenario_loader.gd`
- `game/tests/test_forced_move.gd`
- `game/tests/test_rules_move.gd`
- `game/tests/test_rules_enemy_phase.gd`
- `game/tests/test_village_morale.gd`
- `game/tests/kich_ban/lang/*.json` (13 files)
