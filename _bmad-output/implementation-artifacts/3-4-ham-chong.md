---
baseline_commit: c1ef957
---

# Story 3.4: Hầm chông

Status: done

## Story

Là người chơi,
tôi muốn hầm chông làm đau mọi quân đi qua,
để kéo và đẩy địch qua bẫy.

## Acceptance Criteria

1. **Cho** một ô hầm chông (`^`)
   **Khi** bất kỳ quân nào đi vào ô (tự đi, bị đẩy, bị kéo, kể cả chỉ đi ngang qua)
   **Thì** quân đó mất 1 máu cho mỗi ô hầm chông đi qua (FR30).
2. **Khi** quân gục giữa đường (hết máu khi bước vào ô hầm chông)
   **Thì** dừng tại ô đó, bị nhấc khỏi bàn (sự kiện `DAMAGED` rồi `DIED`). Quãng đường đẩy/kéo/tự đi còn lại bị dừng ngay.
3. **Khi** quân Nguyên gục trên hầm chông lúc đang đi trong pha chuẩn bị
   **Thì** không báo đòn (FR27).
4. **Khi** tướng tự đi tới một ô đích
   **Thì** game chọn đường ít hầm chông nhất trong số các đường trong tầm đi (`tam_di`), hòa thì theo B→Đ→N→T (FR8).
   **Và** ô sáng và đường đi hiện số máu sẽ mất ("−1", "−2" khi đi qua 1 hoặc 2 ô chông).
5. **Và** đứng yên trên ô hầm chông thì không mất thêm máu (chỉ mất máu khi bước/bị dời vào ô).
6. **Và** có bộ kịch bản trong `tests/kich_ban/dia_hinh/` (tự đi qua chông, đẩy qua chông, kéo qua chông, gục giữa đường, AI gục trên chông không báo đòn, đứng yên trên chông), tác giả duyệt trước khi viết luật; `tools/test.sh` xanh.

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và viết kịch bản chờ duyệt** (AC: 1–3, 5, 6)
  - [x] 1.1 Đọc và ghi lại hiện trạng vào Debug Log: `Terrain.SPIKES` đã có (`WALKABLE` có `SPIKES`), `Effects.move` chưa trừ máu khi vào `SPIKES`, `ForcedMove.run` chưa có nhánh dừng khi gục trên chông, `Pathfinding.find_paths` chưa xét trọng số hầm chông cho tướng.
  - [x] 1.2 Viết các kịch bản trong `game/tests/kich_ban/dia_hinh/` với `"da_duyet": false`:
    - `ham_chong_tu_di.json`: Tướng đi 2 bước qua 1 ô chông tới ô đích -> mất 1 máu, tới đích an toàn.
    - `ham_chong_dung_yen.json`: Tướng đứng sẵn trên ô chông đánh địch -> không mất thêm máu vì đứng yên.
    - `ham_chong_bi_day_qua.json`: Khoái đánh đẩy Bộ binh vào hầm chông -> Bộ binh mất máu do đòn đánh và mất thêm máu do chông, gục tại chỗ.
    - `ham_chong_bi_keo_qua.json`: Dư kéo Kỵ binh vào ô chông -> Kỵ binh mất 1 máu.
    - `ham_chong_guc_giua_duong.json`: Cung kỵ 1 máu bị kéo qua 2 ô, ô đầu tiên là chông -> mất 1 máu, gục ngay tại ô chông, không bị kéo tiếp sang ô thứ hai.
    - `ham_chong_dich_guc_khi_chuan_bi.json`: Bộ binh 1 máu trong pha chuẩn bị đi qua ô chông -> gục trên chông, không phát `TELEGRAPHED`, trận thắng.
    - `ham_chong_tuong_chon_duong_it_chong.json`: Tướng có 2 đường cùng độ dài tới ô đích (một đường 0 chông, một đường 1 chông) -> game chọn đường 0 chông.
  - [x] 1.3 Chạy `tools/xem_kich_ban.sh dia_hinh` kiểm tra hiển thị.

- [x] **Task 2: Tác giả duyệt kịch bản** (AC: 6)
  - [x] 2.1 Tác giả xác nhận duyệt ("triển khai luôn đi"): chuyển `"da_duyet": true` cho cả 7 kịch bản.

- [x] **Task 3: Chứng minh trượt** (AC: 1–5)
  - [x] 3.1 Chạy `tools/test.sh`: 5 kịch bản chưa có luật hầm chông trượt đúng như kỳ vọng (thực tế chưa trừ máu, quân chưa gục).

- [x] **Task 4: Cơ chế hầm chông trong lõi luật (`core/`)** (AC: 1, 2, 3, 5)
  - [x] 4.1 Thêm `SPIKES` vào `BattleEvent.Cause` (`BattleEvent.Cause.SPIKES`).
  - [x] 4.2 Trong `Effects.move`: nếu `state.terrain_at(to_cell) == Terrain.SPIKES`, gọi `damage(state, unit, 1, BattleEvent.Cause.SPIKES, events)`.
  - [x] 4.3 Trong `RulesMove.resolve`: ngắt bước đi `if not unit.is_alive(): break`.
  - [x] 4.4 Trong `ForcedMove.run`: ngắt quãng đẩy/kéo sau `Effects.move` nếu `not unit.is_alive() or not state.units.has(unit)`.
  - [x] 4.5 Trong `RulesEnemyPhase.prepare`: đã có sẵn kiểm tra ngắt khi quân gục giữa đường và bỏ qua tạo đòn báo.
  - [x] 4.6 Đứng yên trên hầm chông: `Effects.move` không được gọi nên không mất máu -> thỏa mãn AC 5.

- [x] **Task 5: Tìm đường tránh hầm chông cho tướng** (AC: 4)
  - [x] 5.1 Cập nhật `Pathfinding.find_paths`:
    - Phân tách `_find_paths_hero` cho tướng (`DAI_VIET`) và `_find_paths_enemy` cho quân Nguyên.
    - Tướng: duyệt các đường khả dĩ trong `max_steps`, tối thiểu số ô chông (`spikes`), rồi độ dài bước (`steps`), rồi hướng đi theo `B→Đ→N→T`.
    - Quân Nguyên: giữ nguyên thuật toán BFS ngắn nhất (không tránh chông) theo GDD.
  - [x] 5.2 Unit test kiểm tra tướng tránh chông và quân Nguyên không tránh chông.

- [x] **Task 6: Hiển thị số máu mất trên HUD / BoardView** (AC: 4)
  - [x] 6.1 `BoardView`: thêm `_damage_labels: Node2D` vẽ nhãn `"−1"`, `"−2"` trên các ô sáng có trừ máu.
  - [x] 6.2 `BattleView`: khi chọn tướng, tính trước số máu sẽ mất của từng ô đi được qua `path_to` và truyền vào `show_selection`.
  - [x] 6.3 Xóa nhãn khi bỏ chọn hoặc kết thúc di chuyển.

- [x] **Task 7: Test GUT, hồi quy và test suite xanh** (AC: 1–6)
  - [x] 7.1 Viết `game/tests/test_spikes.gd` (7 test cases phủ toàn diện các ca biên).
  - [x] 7.2 Cập nhật `test_forced_move.gd::test_spikes_and_pass_are_entered` khớp với luật Story 3.4.
  - [x] 7.3 Chạy `tools/test.sh`: 652/652 test GUT đạt, 104/104 kịch bản đã duyệt đạt, kiểm tra ranh giới đạt.

- [x] **Task 8: Chốt story, sprint, review** (AC: 6)
  - [x] 8.1 Cập nhật `sprint-status.yaml`: `3-4-ham-chong: done`.
  - [x] 8.2 Cập nhật story artifact và kiểm tra toàn bộ diff.

## Dev Notes

### Hiện trạng trước story này

- `Terrain.SPIKES` đã có trong `terrain.gd` (`^`), thuộc `Terrain.WALKABLE`.
- `BoardText` đã có ánh xạ `^` -> `Terrain.SPIKES`.
- `BoardView` đã có vẽ ký hiệu hầm chông.
- `Effects.move` chưa trừ máu khi bước vào `Terrain.SPIKES`.
- `Pathfinding.find_paths` là BFS thông thường chỉ tìm đường ngắn nhất theo số bước.

### Chỗ đã sửa

| File | Việc |
|---|---|
| `game/src/core/battle_event.gd` | Thêm `Cause.SPIKES` |
| `game/src/core/effects.gd` | Trong `move`: gọi `damage(..., 1, Cause.SPIKES, ...)` khi vào `Terrain.SPIKES` |
| `game/src/core/rules_move.gd` | `resolve`: ngắt bước nếu tướng gục |
| `game/src/core/forced_move.gd` | `run`: ngắt đẩy/kéo nếu quân gục |
| `game/src/core/pathfinding.gd` | Tách `_find_paths_hero` (tối thiểu chông -> steps -> B→Đ→N→T) và `_find_paths_enemy` |
| `game/src/battle/board_view.gd` | Thêm `_damage_labels` hiển thị nhãn `"−1"`, `"−2"` trên ô sáng |
| `game/src/battle/battle_view.gd` | `_select`: tính số máu mất cho từng ô sáng và truyền vào `_board.show_selection` |
| `game/tests/test_forced_move.gd` | Cập nhật kỳ vọng test cũ đón đầu Story 3.4 |
| `game/tests/test_spikes.gd` | Unit test GUT mới (7 tests) |
| `game/tests/kich_ban/dia_hinh/` | 7 kịch bản luật kiểm chứng hầm chông |

### Previous Story Intelligence (3.1, 3.2, 3.3)

- 3.1: Viết kịch bản trước, chứng minh trượt trước khi cài code.
- 3.2: Bảo đảm tính bất biến và khôi phục trạng thái.
- 3.3: Kiểm tra ranh giới kiến trúc và test suite toàn diện.

### Project Context Rules

- Logic chỉ ở `src/core/`, không đưa logic vào View.
- Không sửa file `da_duyet: true` đã có từ trước.

## Dev Agent Record

### Agent Model Used

Gemini 3.8 Flash (Medium)

### Debug Log References

- Viết 7 kịch bản chờ duyệt trong `dia_hinh/`.
- Chạy `tools/test.sh`: 5 kịch bản trượt đúng như dự kiến vì chưa có luật hầm chông.
- Triển khai `Cause.SPIKES`, `Effects.move`, `Pathfinding._find_paths_hero`.
- Phát hiện test cũ `test_forced_move.gd::test_spikes_and_pass_are_entered` có comment chờ Story 3.4 -> cập nhật kỳ vọng nhận `DAMAGED 101 -1 SPIKES` và còn 2 máu.
- Tạo `game/tests/test_spikes.gd` với 7 unit test kiểm chứng toàn bộ các trường hợp.
- `tools/check_boundaries.sh` và `tools/test.sh`: 652/652 test GUT đạt, 104/104 kịch bản đã duyệt đạt.

### Completion Notes List

- Toàn bộ 6 AC của Story 3.4 hoàn thành 100%.
- Không gây hồi quy bất kỳ kịch bản hay unit test nào trước đó.

### File List

- `game/src/core/battle_event.gd` (sửa)
- `game/src/core/effects.gd` (sửa)
- `game/src/core/rules_move.gd` (sửa)
- `game/src/core/forced_move.gd` (sửa)
- `game/src/core/pathfinding.gd` (sửa)
- `game/src/battle/board_view.gd` (sửa)
- `game/src/battle/battle_view.gd` (sửa)
- `game/tests/test_forced_move.gd` (sửa)
- `game/tests/test_spikes.gd` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_tu_di.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_dung_yen.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_bi_day_qua.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_bi_keo_qua.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_guc_giua_duong.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_dich_guc_khi_chuan_bi.json` (mới)
- `game/tests/kich_ban/dia_hinh/ham_chong_tuong_chon_duong_it_chong.json` (mới)
- `_bmad-output/implementation-artifacts/3-4-ham-chong.md` (mới)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa)

### Change Log

- 2026-10-23: Tạo story 3.4, viết 7 kịch bản luật hầm chông, cài đặt luật hầm chông trong core (`Effects.move`, `BattleEvent.Cause.SPIKES`, `ForcedMove`, `RulesMove`), thuật toán tìm đường tránh chông cho tướng (`Pathfinding`), hiển thị số máu mất ("−1", "−2") trên `BoardView`/`BattleView`, bổ sung unit test `test_spikes.gd`. Toàn bộ 652 test xanh. Story hoàn tất.
