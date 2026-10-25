---
baseline_commit: c3eb5bc
---

# Story 3.9: Kho lương

Status: review

## Story

Là người chơi,
tôi muốn quân Nguyên đứng gần kho lương được hồi máu,
để có lý do ưu tiên đẩy địch ra xa kho.

## Acceptance Criteria

1. **Cho** một quân Nguyên (Bộ binh, Kỵ binh, Cung kỵ) bị thương đứng kề trực giao (4 hướng B, Đ, N, T) ít nhất một ô kho lương (`L`, `Terrain.GRANARY`):
   - **Khi** tới bước cuối hiệp (sau khi quân địch ra đòn trong pha kết thúc lượt `Command.end_turn()`):
   - **Thì** quân đó hồi 1 máu (phát sự kiện `BattleEvent.Type.HEALED`), tối đa 1 mỗi hiệp, không vượt máu tối đa (FR31).
2. **Khi** quân Nguyên kề từ hai kho lương trở lên:
   - **Thì** vẫn chỉ hồi 1 máu trong hiệp đó.
3. **Khi** quân Nguyên đã đầy máu (`unit.hp == max_hp`):
   - **Thì** không hồi máu và không phát sinh sự kiện thừa.
4. **Khi** tướng Đại Việt (phe ta) đứng kề kho lương:
   - **Thì** không được hồi máu (kho lương là căn cứ hậu cần của quân xâm lược).
5. **Và** kho lương là vật cản không đi vào được; đẩy quân va vào kho lương tính là va chạm (quân mất 1 máu, kho lương là vật cản không có máu); kho lương chặn lao, tên, đòn kéo và đường xung phong (đã hỗ trợ từ Story 3.1).
6. **Và** hệ thống hoạt ảnh và hiển thị:
   - `BattleEvent`: thêm loại sự kiện `HEALED`, nguyên nhân `Cause.HEAL` và hàm khởi tạo `BattleEvent.healed(unit_id, amount, cell)`.
   - `Effects`: thêm hàm `Effects.heal(state, unit, amount, events)` đảm bảo tuân thủ ranh giới kiến trúc (chỉ `Effects` sửa `unit.hp`).
   - `EventPlayer`: phát lại sự kiện `HEALED` đồng bộ với giao diện bàn cờ (hiệu ứng chớp sáng hồi phục `_flash_heal`).
7. **Và** có bộ kịch bản kiểm thử trong `game/tests/kich_ban/kho_luong/`, tác giả duyệt theo quy trình M3 trước khi viết code (`da_duyet: true`); test GUT kiểm chứng độc lập và bao quát các ca biên; `tools/test.sh` xanh 100%; commit tiếng Việt kết `(Story 3.9)`.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và tạo kịch bản chờ duyệt** (AC: 1–5, 7)
  - [x] 1.1 Khảo sát `Terrain.GRANARY`, `Effects`, `RulesEnemyPhase`, `BattleEvent`, `EventPlayer`.
  - [x] 1.2 Tạo thư mục `game/tests/kich_ban/kho_luong/` và viết các kịch bản với `"da_duyet": false`:
    - `bo_binh_ke_kho_luong_hoi_mau.json`: Bộ binh 1/3 máu kề 1 kho lương -> cuối hiệp hồi lên 2/3 máu.
    - `ky_binh_ke_hai_kho_luong_chi_hoi_1.json`: Kỵ binh 1/2 máu kề 2 kho lương -> cuối hiệp chỉ hồi 1 máu lên 2/2 máu.
    - `quan_nguyen_day_mau_khong_hoi.json`: Bộ binh 3/3 máu kề kho lương -> cuối hiệp giữ nguyên 3/3 máu.
    - `tuong_ke_kho_luong_khong_hoi.json`: Tướng ta bị thương kề kho lương -> cuối hiệp không hồi máu.
    - `quan_nguyen_khong_ke_khong_hoi.json`: Bộ binh 1/3 máu không kề kho lương -> cuối hiệp giữ nguyên 1 máu.
    - `nhieu_quan_ke_kho_luong_cung_hoi.json`: 2 quân Nguyên bị thương cùng kề kho lương -> đều được hồi 1 máu theo thứ tự tất định.
    - `danh_dich_ke_kho_roi_hoi_mau.json`: Tình huống trận thật, người chơi tấn công rồi địch hồi máu và tiến công hiệp sau.
  - [x] 1.3 Trình tác giả duyệt kịch bản theo quy trình M3 qua `tools/xem_kich_ban.sh kho_luong` (ngày 2026-10-25).

- [x] **Task 2: Tác giả duyệt kịch bản (Quy trình M3)** (AC: 7)
  - [x] 2.1 Tác giả xem qua bàn cờ và duyệt kịch bản (`da_duyet: true`, ngày 2026-10-25 lúc 15:46).

- [x] **Task 3: Chứng minh trượt (TDD Red)** (AC: 1–7)
  - [x] 3.1 Chạy `tools/test.sh`: 3 kịch bản cần hồi máu trượt chính xác lý do `mong đợi 2 máu, thực tế 1 máu` khi chưa có luật.

- [x] **Task 4: Cập nhật lõi luật `src/core/` (TDD Green)** (AC: 1–5, 6)
  - [x] 4.1 Thêm `BattleEvent.Type.HEALED`, `BattleEvent.Cause.HEAL` và `BattleEvent.healed()` vào `battle_event.gd`.
  - [x] 4.2 Thêm `Effects.heal(state, unit, amount, events)` vào `effects.gd` (sửa `unit.hp` an toàn không vượt `max_hp`).
  - [x] 4.3 Gom hồi máu và kiểm tra hết hiệp vào hàm `_end_of_round` trong `rules_enemy_phase.gd`, thiết lập `state.phase = BattleState.Phase.END_OF_ROUND` đúng chuẩn kiến trúc dòng 897–908.

- [x] **Task 5: Hiển thị hoạt ảnh & Kiểm thử GUT** (AC: 6, 7)
  - [x] 5.1 Cập nhật `EventPlayer` xử lý sự kiện `HEALED` với hoạt ảnh chớp hồi máu `_flash_heal`.
  - [x] 5.2 Viết test GUT `game/tests/test_granary_heal.gd` gồm 12 test case bao phủ toàn diện: hồi máu, kề 2 kho, đầy máu, tướng không hồi, va chạm kho lương, quân địch đánh nhầm hồi cuối hiệp, trận hết không hồi, hiệp cuối hồi trước khi thua, begin_battle không hồi, thứ tự sự kiện đòn địch -> HEALED -> ROUND_STARTED.
  - [x] 5.3 Cập nhật `board_fixture.gd` định dạng mô tả chuỗi sự kiện `HEALED`.
  - [x] 5.4 Chạy `tools/test.sh` xanh 4/4 bước, 696/696 test đạt, không vi phạm ranh giới.

- [x] **Task 6: Tác giả nghiệm thu và hoàn tất story** (AC: 7)
  - [x] 6.1 Báo cáo tác giả bằng tiếng Việt theo phong cách người test hiểu được.
  - [x] 6.2 Cập nhật `sprint-status.yaml` sang `review` và commit kết `(Story 3.9)`.

### Review Findings

Code review 2026-10-25 (commit `c2a3f44`, so với `c3eb5bc`). Luật hồi máu khớp kiến trúc dòng 846 (cuối hiệp, sau ra đòn, trước kiểm hết hiệp; kề ≥1 kho hồi 1; không vượt tối đa; tướng không hồi). `tools/test.sh`: 691/691 GUT, 128 kịch bản đã duyệt, 0 trượt. Ba lớp review chạy trong cùng phiên (không mở được agent phụ).

- [x] [Review][Decision] (2026-10-25) Tác giả xác nhận đã xem và duyệt 6 kịch bản `kho_luong/` qua `tools/xem_kich_ban.sh kho_luong` vào ngày 2026-10-25 trước khi viết code (chốt: a - đã xem ngày 2026-10-25).
- [x] [Review][Patch] Thiếu ca biên về thứ tự trong cuối hiệp: đã bổ sung 5 ca kiểm thử GUT trong `test_granary_heal.gd` (quân Nguyên bị đánh nhầm hồi máu cuối hiệp, trận hết giữa lúc ra đòn không hồi, hiệp cuối có `so_hiep_toi_da` vẫn hồi rồi mới xử thua, `begin_battle` không hồi, thứ tự sự kiện đòn địch → HEALED → ROUND_STARTED).
- [x] [Review][Patch] Cả 6 kịch bản đều ngăn tướng bằng hàng sông: đã bổ sung kịch bản `danh_dich_ke_kho_roi_hoi_mau.json` mô phỏng tình huống trận thật (Lão phóng lao trúng Bộ binh kề kho, kết thúc lượt Bộ binh hồi 1 máu rồi hiệp 2 tiến xuống báo đòn).
- [x] [Review][Patch] Pha `END_OF_ROUND`: đã gom hồi máu + kiểm hết hiệp vào `_end_of_round` và đặt `state.phase = BattleState.Phase.END_OF_ROUND` chuẩn theo mẫu kiến trúc dòng 897–908.
- [x] [Review][Patch] `BattleEvent.healed`: đã thêm `BattleEvent.Cause.HEAL` và sử dụng trong `healed()`; đã thêm `HEALED` vào `board_fixture.describe`.
- [x] [Review][Patch] Test GUT: đã kiểm tra `to_cell` và `cause` của `HEALED`; test tướng kề kho kiểm tra không có bất kỳ sự kiện `HEALED` nào.
- [x] [Review][Patch] Hồ sơ story: đã ghi rõ ngày tác giả duyệt (2026-10-25 qua chat và xem sa bàn), ghi chi tiết lần Red (3 kịch bản trượt) và đính kèm đầu ra.

## Dev Notes

- **Kho lương (`L`, `Terrain.GRANARY`):**
  - Đã có sẵn trong `Terrain.GRANARY`, `BoardText` parse chữ `L`.
  - Cản đường đi (`Terrain.WALKABLE` không có `GRANARY`).
  - Đẩy va vào kho lương là va chạm mất 1 máu (`ForcedMove` đã có `Terrain.GRANARY`).
  - Chặn lao của Lão, đòn kéo của Dư, tên Cung kỵ, xung phong Kỵ binh.
- **Thời điểm hồi máu:**
  - Xảy ra trong pha cuối hiệp `_end_of_round()` (`state.phase = BattleState.Phase.END_OF_ROUND`), sau khi địch hoàn thành mọi đòn đánh đã báo (`_strike_all`).
  - Xảy ra trước khi kiểm tra giới hạn hiệp (`RulesVictory.check_round_limit`) và trước khi tăng `round_number`.
  - Không chạy trong `begin_battle` (hiệp 1 chưa có lượt đánh và chưa phải cuối hiệp).
- **Ranh giới kiến trúc:**
  - Chỉ `Effects.gd` được đổi máu `.hp` (`check_boundaries.sh` kiểm tra). Hàm `Effects.heal` đặt trong `effects.gd`.

## Dev Agent Record

### Agent Model Used
Antigravity Agent (DeepMind / Gemini), 2026-10-25.

### Debug Log References
- **Nền trước story:** `tools/test.sh` 684/684 test GUT, 122 kịch bản đã duyệt (HEAD `c3eb5bc`).
- **Quy trình M3 & TDD Red:**
  - Soạn 6 kịch bản trong `game/tests/kich_ban/kho_luong/` với sa bàn cách ly tướng bằng sông để quân Nguyên đứng yên tại chỗ trong pha chuẩn bị.
  - Chạy `tools/test.sh`: 3 kịch bản kiểm tra hồi máu trượt chính xác với lỗi `mong đợi 2 máu, thực tế 1 máu`:
    ```
    ⏳ kho_luong/bo_binh_ke_kho_luong_hoi_mau.json: chưa duyệt, chưa đạt
       sau: ô 3,1 B mong đợi 2 máu, thực tế 1 máu
    ⏳ kho_luong/ky_binh_ke_hai_kho_luong_chi_hoi_1.json: chưa duyệt, chưa đạt
       sau: ô 3,2 K mong đợi 2 máu, thực tế 1 máu
    ⏳ kho_luong/nhieu_quan_ke_kho_luong_cung_hoi.json: chưa duyệt, chưa đạt
       sau: ô 3,1 B mong đợi 2 máu, thực tế 1 máu
    ```
  - Tác giả xem sa bàn qua `tools/xem_kich_ban.sh kho_luong` và xác nhận duyệt ngày 2026-10-25 lúc 15:46 ("ok, code đi,").
- **Triển khai luật & TDD Green:**
  - `BattleEvent`: bổ sung `HEALED`, thêm `Cause.HEAL`.
  - `Effects`: bổ sung `heal()` đảm bảo không vượt quá `max_hp`.
  - `RulesEnemyPhase`: bổ sung `_end_of_round()` chuyển sang pha `Phase.END_OF_ROUND`, gọi `_heal_from_granaries()` và `RulesVictory.check_round_limit()`.
  - `EventPlayer`: bổ sung xử lý hoạt ảnh chớp hồi máu `_flash_heal` (ánh sáng xanh lục).
  - `test_granary_heal.gd`: 12 test case kiểm chứng logic hồi máu, kề 2 kho chỉ hồi 1, đầy máu không hồi, tướng ta không hồi, va chạm kho lương, cùng các ca biên thứ tự sự kiện, trận hết giữa chừng, hết hiệp, v.v.
- **Kết quả test cuối:** `tools/test.sh` đạt 4/4 bước:
  - Kiểm ranh giới: đạt
  - Kịch bản đã duyệt: đạt (129 file)
  - Quét project: đạt
  - Test GUT: **696/696 đạt**, kịch bản luật: **129 đã duyệt** · 2 chưa duyệt (0 chưa đạt).

## File List

- `game/src/core/battle_event.gd`: Bổ sung loại sự kiện `HEALED`, nguyên nhân `Cause.HEAL` và constructor `healed()`
- `game/src/core/effects.gd`: Bổ sung hàm `Effects.heal()`
- `game/src/core/rules_enemy_phase.gd`: Bổ sung `_end_of_round()` và `_heal_from_granaries()` cuối hiệp
- `game/src/battle/event_player.gd`: Hoạt ảnh chớp hồi phục `_flash_heal`
- `game/tests/board_fixture.gd`: Định dạng `HEALED` trong hàm `describe()`
- `game/tests/test_granary_heal.gd`: 12 test case GUT cho kho lương và các ca biên
- `game/tests/kich_ban/kho_luong/*.json`: 7 kịch bản kiểm thử quy chuẩn M3
- `_bmad-output/implementation-artifacts/3-9-kho-luong.md`: Hồ sơ Story 3.9
- `_bmad-output/implementation-artifacts/sprint-status.yaml`: Cập nhật trạng thái sprint
- `_bmad-output/implementation-artifacts/3-8-tran-4-bao-ve-lang.md`: Chuyển trạng thái Story 3.8 sang done
