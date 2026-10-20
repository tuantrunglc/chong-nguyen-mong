---
baseline_commit: 19d14dc81764debd1bcbce4f24a3be5be904440a
---

# Story 1.9: Cỡ bàn theo file trận

Status: in-progress

## Story

Là tác giả,
tôi muốn mỗi trận có cỡ bàn riêng theo quy mô của trận đánh thật,
để trận phục kích nhỏ và trận Bạch Đằng lớn không phải chung một bàn 7×7.

_Thêm 2026-10-20 theo `sprint-change-proposal-2026-10-20-co-ban.md`. Làm ngay sau Story 1.8 (đã xong, commit `19d14dc`), trước Story 2.4. Cắt được: khi cắt thì giữ bàn 7×7._

_Story này **không có luật mới**. Luật đã đọc `level.size` từ Story 1.1. Việc của story: bộ nạp suy ra cỡ bàn từ bàn cờ chữ, `BoardView` canh bàn theo cỡ đó, test bỏ số 7 cứng. Có **một đợt duyệt kịch bản nhỏ** (mép bàn trên bàn 5×6), xem "Quy trình kịch bản của story này"._

## Acceptance Criteria

1. **Trận nhỏ và trận lớn.** **Cho** hai trận thử mới `thu_co_nho.json` (5×5) và `thu_co_lon.json` (10 cột × 8 hàng) trong `game/data/tran/`, chỉ mở được khi bật dev. **Khi** mở từng trận (`tools/chay.sh --dev --tran=thu_co_nho`, `--tran=thu_co_lon`), **thì**:
   - bàn hiện đúng số cột và số hàng như trong file;
   - bàn nằm gọn trong vùng chơi (`BoardView.AREA`), không đè tiêu đề, bảng HUD và nhãn phiên bản;
   - mỗi ô hiện **64 px** (ở 1280×720 cả hai trận đều vừa, không thu nhỏ);
   - góc trên trái của bàn rơi đúng điểm ảnh nguyên.
2. **Thu theo bậc nguyên.** Nếu khung bàn không vừa vùng chơi thì `BoardView` thu bàn theo bậc `1/2`, `1/3`… (bậc lớn nhất còn vừa), không bao giờ thu lẻ. Ở 1280×720 nhánh này không chạy với mọi cỡ hợp lệ; có test cho nhánh này bằng số đo giả.
3. **Trận cũ không đổi.** Trận 1 và mọi trận thử 7×7 cũ (`thu_ba_tuong`, `thu_day`, `thu_lao`) hiện y như sau Story 1.8: cùng `board.position = (262, 139)`, cùng ảnh chụp. Mọi file trận và kịch bản 7×7 hiện có vẫn hợp lệ, **không sửa file nào**.
4. **Báo lỗi cỡ bàn.** **Khi** sửa một file trận cho có một trong các lỗi sau, **thì** game hiện màn hình lỗi tiếng Việt (như Story 1.1), ghi rõ file, dòng và cỡ đọc được (câu lỗi ở Dev Notes "Câu lỗi"):
   - một dòng của `dia_hinh` thiếu hoặc thừa ký hiệu;
   - lớp `quan` khác cỡ với lớp `dia_hinh` (khác số dòng, hoặc một dòng khác số ô);
   - bàn 11×8, hoặc nhỏ hơn 5×5, hoặc nhiều hơn 8 hàng.
5. **Bàn 10×8 chơi được tới mép.** **Khi** ở `thu_co_lon`, lần lượt: chọn Khoái, đánh Bộ binh ở `9,4` (bị đẩy ra ngoài cột 9), kết thúc lượt, cho Khoái đi xuống `8,6` rồi bấm Bộ binh ở `8,7` hai lần (lần đầu là chờ xác nhận vì Khoái đã đi; bị đẩy ra ngoài hàng 7), rồi bấm F1, **thì** ô sáng, đường đi, viền mục tiêu, va chạm mép bàn và tọa độ F1 đều đúng, kể cả ở cột 9 và hàng 7.
6. **Bấm đúng ô trên mọi cỡ bàn.** Bấm vào bất kỳ ô nào của bàn 5×5 và 10×8 (thử cả 4 góc ô và mép bàn) thì game chọn đúng ô đó. Bấm ngoài bàn thì như bấm ra ngoài.
7. **Kịch bản trên bàn khác 7×7.** Kịch bản luật viết được trên bàn khác 7×7. Có ít nhất một kịch bản mép bàn trên bàn **5 cột × 6 hàng**, tác giả đã duyệt và kịch bản đạt.
8. **Test.** `tools/test.sh` xanh. Test không còn lặp cứng `range(7)` hay `range(49)`, mà lặp theo cỡ bàn của trận thử. Câu lỗi mới có test trong `test_loaders.gd` và `test_scenario_loader.gd`.
9. **Việc hoãn.** Mục "tràn dưới HUD" trong `deferred-work.md` (review 1.7) được đánh dấu **đã làm ở Story 1.9**.
10. **Không đụng luật.** Không sửa gì trong `game/src/core/`. Không sửa kịch bản `da_duyet: true` nào. Không sửa `tran_01.json`, `thu_ba_tuong.json`, `thu_day.json`, `thu_lao.json`.
11. **Web.** `tools/build_web.sh` đạt, dung lượng trong giới hạn.

## Tasks / Subtasks

- [x] **Task 1: Kịch bản mép bàn 5×6 viết trước, cho thấy đỏ** (AC: 7)
  - [x] 1.1 Viết `game/tests/kich_ban/va_cham/day_vao_mep_ban_5x6.json` đúng như Dev Notes "Đợt kịch bản 6", `"da_duyet": false`. Không đụng 36 kịch bản đã duyệt.
  - [x] 1.2 `tools/test.sh` **phải trượt** ở `test_every_scenario_loads`, lý do là câu lỗi cũ "có 5 ô, cần 7". Ghi Debug Log. Không commit khi đang đỏ.
- [x] **Task 2: Bộ nạp suy ra cỡ bàn** (AC: 3, 4, 7, 8)
  - [x] 2.1 `board_layers.gd`: bỏ `BOARD_SIZE`, thêm `const BOARD_MIN: Vector2i = Vector2i(5, 5)` và `const BOARD_MAX: Vector2i = Vector2i(10, 8)` (cột, hàng). Thêm `const NO_SIZE: Vector2i = Vector2i.ZERO` cho "chưa biết cỡ". Sửa chú thích đầu hằng số (đang ghi "Giai đoạn 1 mới có bàn khác cỡ").
  - [x] 2.2 `read_layer(root, key, shown, symbols, file, result, size: Vector2i = NO_SIZE, size_shown: String = "")` (gợi ý; giữ cách gom lỗi hiện tại):
    - `size == NO_SIZE` (lớp đầu tiên: `dia_hinh` của file trận, `truoc.dia_hinh` của kịch bản): số cột lấy từ **dòng đầu tiên là chuỗi**; dòng nào khác số ô thì lỗi "dòng N: có X ô, dòng M có Y". Số hàng là số dòng.
    - `size != NO_SIZE` (các lớp còn lại): dòng nào khác `size.x` ô thì lỗi "dòng N: có X ô, `<size_shown>` có Y"; số dòng khác `size.y` thì lỗi "có X dòng, `<size_shown>` có Y" và trả `[]` như hiện nay.
    - Câu lỗi đúng như bảng "Câu lỗi". Giữ thứ tự lỗi hiện tại (lỗi từng dòng trước, lỗi số dòng sau).
  - [x] 2.3 `static func layer_size(rows: Array) -> Vector2i`: cỡ của lớp đã đọc (số cột của dòng đọc được đầu tiên, số dòng); `[]` hoặc không có dòng đọc được thì `NO_SIZE`. Hoặc để `read_layer` trả kèm cỡ; chọn một, ghi Debug Log.
  - [x] 2.4 `static func check_size(size, shown, file, result) -> bool`: ngoài `[BOARD_MIN, BOARD_MAX]` thì lỗi "bàn C cột × H hàng" như bảng, trả `false`. Gọi **một lần**, ngay sau khi đọc lớp đầu tiên, và chỉ khi lớp đó không có lỗi dòng (lớp lệch dòng thì đã có lỗi riêng, không báo thêm cỡ sai).
  - [x] 2.5 `check_unit_cells`, `reading_order`: lặp theo cỡ của `rows` (số dòng, số ô của từng dòng), không theo hằng số. `read_enemy_order` nhận thêm `size`; `size == NO_SIZE` thì **bỏ qua** kiểm "nằm ngoài bàn" (lớp bàn sai đã có lỗi riêng).
  - [x] 2.6 `level_loader.gd`: bỏ `const BOARD_SIZE`. Đọc `dia_hinh` (không có cỡ) → lấy cỡ → `check_size` → đọc `quan` với cỡ đó, `size_shown = "dia_hinh"`. `level.size` lấy từ cỡ đọc được. Lớp `dia_hinh` hỏng (không lấy được cỡ) thì vẫn đọc `quan` theo cỡ của chính nó (như `NO_SIZE`) để báo ký hiệu lạ, không kiểm chéo.
  - [x] 2.7 `scenario_loader.gd`: `truoc.dia_hinh` quyết cỡ (`check_size` một lần); `truoc.quan`, `sau.dia_hinh`, `sau.quan` đọc với cỡ đó, `size_shown = "truoc.dia_hinh"`. `_read_hp` và `_read_step_cell` kiểm "trong bàn" theo cỡ đó; `NO_SIZE` thì bỏ qua kiểm ngoài bàn (`_read_step_cell` vẫn báo khi `o` không phải tọa độ). `_build_level` gán `level.size` từ cỡ đó. Thứ tự đọc trong `parse_scenario` giữ nguyên (`truoc` → `hanh_dong` → `sau`), nên cỡ phải có trước khi đọc `hanh_dong`.
  - [x] 2.8 `grep -rn "BOARD_SIZE" game/` rỗng.
  - [x] 2.9 `tools/test.sh`: kịch bản 5×6 nạp được, `chưa duyệt`, đạt (luật mép bàn đã có). Các test câu lỗi cũ trượt đúng chỗ (Task 4 sửa). Ghi Debug Log.
- [x] **Task 3: `BoardView` canh và thu theo cỡ bàn** (AC: 1, 2, 3, 6)
  - [x] 3.1 `static func fit_scale(board_size: Vector2, area_size: Vector2) -> float`: trả `1.0 / k` với `k` là số nguyên dương nhỏ nhất sao cho `board_size / k` vừa `area_size` (cả hai chiều, `<=`). Static để test bằng số đo giả.
  - [x] 3.2 `setup(new_cols, new_rows)`:
    - `scale = Vector2.ONE * fit_scale(_local_rect().size, AREA.size)`;
    - `position = (AREA.get_center() - _local_rect().get_center() * scale).round()`.
    - Bàn 7×7 ra đúng `(262, 139)` như 1.8 (AC 3).
  - [x] 3.3 Bỏ số 7 cứng trong `board_view.gd`: `var cols: int = 7`, `var rows: int = 7`, `setup(new_cols: int = 7, new_rows: int = 7)` đổi thành một hằng `const EMPTY_SIZE: Vector2i = Vector2i(7, 7)` có chú thích "cỡ bàn trống khi chưa có trận (màn hình lỗi, test)". Hành vi bàn trống giữ nguyên.
  - [x] 3.4 Không sửa `cell_center`, `cell_rect`, `cell_at`, `pick_cell`, `board_rect`: chúng làm việc trong tọa độ local, `board_rect` đã nhân `transform` (Story 1.8, Task 1.7). `BattleInput` dùng `make_input_local`, `CoordOverlay` là con của `BoardView`, màn hình lỗi lấy `board_rect()`: tự đúng khi có `scale`. Chỉ sửa nếu test Task 4.3 trượt; ghi Debug Log nếu phải sửa.
  - [x] 3.5 `main.gd`, `hud.gd`, `coord_overlay.gd`, `battle_input.gd`: không sửa code. `CoordOverlay.show_state` đã lặp theo `state.size`.
- [x] **Task 4: Test** (AC: 1–8; viết test trước, cho thấy đỏ rồi mới sửa code; ghi Debug Log)
  - [x] 4.1 `test_loaders.gd`: sửa tại chỗ, không xóa test:
    - `test_giu_ai_pass_cell_not_checked_when_terrain_is_broken` (dòng ~228): câu mới "dòng 4: có 6 ô, dòng 1 có 7".
    - `test_wrong_row_count` (dòng ~332): bỏ một dòng `dia_hinh` giờ là bàn **7×6 hợp lệ**, nên lỗi thành `"quan" có 7 dòng, "dia_hinh" có 6`. Đổi tên thành `test_unit_layer_row_count_differs_from_terrain` và sửa chú thích.
    - `test_row_wrong_length` (dòng ~342): câu mới "dòng 3: có 6 ô, dòng 1 có 7".
    - Thêm (mỗi câu lỗi trong bảng một test, so **đúng cả câu**):
      - `test_board_too_wide`: `dia_hinh` 11×8 (và `quan` 11×8) → lỗi cỡ, không có lỗi nào khác;
      - `test_board_too_small`: 4×5;
      - `test_board_too_tall`: 7×9;
      - `test_unit_row_wrong_length`: một dòng `quan` có 6 ô;
      - `test_smallest_and_largest_boards_load`: 5×5 và 10×8 nạp không lỗi, `level.size` đúng;
      - `test_non_square_board_loads`: 6×7 (6 cột, 7 hàng), `level.size == Vector2i(6, 7)`, `terrain_at(Vector2i(5, 6))` đúng ô góc dưới phải;
      - `test_enemy_order_outside_non_square_board`: bàn 6×7, `thu_tu_dich` có `"6,0"` → "nằm ngoài bàn";
      - `test_co_nho_and_co_lon_load`: nạp `thu_co_nho.json` và `thu_co_lon.json` không lỗi, cỡ `5×5` và `10×8` (theo mẫu `test_loaders.gd:598`, `617`).
    - `test_loaders.gd:125` (`level.size == Vector2i(7, 7)` cho trận 1) giữ: đó là giá trị thật của trận 1, không phải lặp cứng.
  - [x] 4.2 `test_scenario_loader.gd`:
    - `test_many_errors_are_listed_together` (dòng ~535): câu mới `"sau.dia_hinh" dòng 1: có 3 ô, "truoc.dia_hinh" có 7`.
    - `_rows` (dòng ~48) lặp theo số dòng của `EMPTY_ROW`/một hằng cỡ trong file test, không `range(7)`.
    - Thêm: kịch bản 5×6 hợp lệ nạp được (`before.size == Vector2i(5, 6)`); `sau.quan` khác cỡ `truoc.dia_hinh`; `"o": "5,0"` trên bàn 5×6 → "không phải ô trong bàn"; `"mau"` có ô `0,6` trên bàn 5×6 → "nằm ngoài bàn"; `truoc.dia_hinh` 11×8 → lỗi cỡ.
  - [x] 4.3 `test_board_view.gd`:
    - Hàm trợ giúp `_make_level_main(name)` mở trận thử theo tên (theo mẫu `_make_three_generals`).
    - Mọi test đang lặp `_all_cells(board)` cho trận 1 và `thu_ba_tuong` thêm `thu_co_nho` và `thu_co_lon`: `test_cell_center_round_trips_every_cell`, `test_points_near_each_corner_stay_in_cell`, `test_points_outside_board_are_off_board`, `test_pick_every_cell_center_with_units_on_board`, `test_board_rect_covers_every_cell_and_token`, `test_board_sits_on_whole_pixels`.
    - `test_board_fits_left_of_hud_below_title`: thêm `thu_co_nho`, `thu_co_lon`.
    - Thêm `test_board_size_follows_level`: `board.cols/rows` bằng `5×5`, `10×8`, `7×7`; `board.scale == Vector2.ONE` cho cả ba (ô 64 px, AC 1).
    - Thêm `test_level_1_board_unchanged`: `board.position == Vector2(262, 139)` (AC 3).
    - Thêm `test_fit_scale_uses_whole_steps`: `fit_scale(Vector2(644, 550), BoardView.AREA.size) == 1.0`; `fit_scale(Vector2(1000, 500), Vector2(940, 612)) == 0.5`; `fit_scale(Vector2(2000, 500), Vector2(940, 612)) == 1.0 / 3.0`; kết quả luôn là `1.0 / k`.
    - Thêm `test_scaled_board_still_maps_clicks`: `AREA` là `const` nên không ép được nhánh thu nhỏ qua `setup`. Đặt thẳng `board.scale = Vector2(0.5, 0.5)`, rồi với 4 ô góc `c`: dựng sự kiện chuột tại `board.get_global_transform_with_canvas() * BoardView.cell_center(c)`, kiểm `board.pick_cell(board.make_input_local(event).position) == c`, và `board.board_rect()` bao các điểm đó. Mục đích: đường chuột và khung bàn đúng khi có `scale`. Có cách gọn hơn thì ghi Debug Log.
  - [x] 4.4 `test_battle_view.gd`: thêm `test_large_board_edge_push_and_f1` theo AC 5 trên `thu_co_lon`, bấm bằng chuột thật (`_click_by_mouse` / `get_global_transform_with_canvas() * BoardView.cell_center(cell)`):
    - chọn Khoái (`8,4`), bấm Bộ binh `9,4`: Bộ binh mất máu (2 sát thương + 1 va mép = gục, đồng bị nhấc), Khoái xám;
    - `Space`; chọn Khoái, bấm `8,6` (ô sáng), bấm Bộ binh `8,7`: viền chờ xác nhận (`pending_cell() == 8,7`); bấm lần nữa: Bộ binh gục;
    - F1: có nhãn `9,7` và `0,0`; nhãn id của Khoái ở đúng chỗ.
    - Dùng số máu đọc từ `data/chi_so.json` như các test giao diện khác, không ghi cứng nếu đã có hàm đọc.
  - [x] 4.4b `test_main.gd`: thêm `test_f5_reload_follows_new_board_size` theo mẫu các test F5 có sẵn (trận ghi vào `user://`, `level_dir`): mở trận 7×7, ghi đè file thành 5×5, F5 → `board.cols/rows == 5×5`, `board_rect()` vẫn trong `AREA`, không còn đồng quân cũ ngoài bàn (Story 1.6: F5 nạp lại).
  - [x] 4.5 Bỏ `range(7)`/`range(49)`/`Vector2i(7, 7)` lặp cứng trong test (AC 8). Mỗi file chỉ còn **một** hằng cỡ có tên (ví dụ `const SIZE: Vector2i = Vector2i(7, 7)`) hoặc cỡ lấy từ bàn cờ chữ:
    - `board_fixture.gd`: `rows()` và `state()` nhận `size: Vector2i = DEFAULT_SIZE`; `EMPTY_ROW` dựng từ `size.x`. Mọi chỗ gọi cũ không đổi.
    - `test_rules_move.gd`: `_state`, `_rows` lặp theo `units.size()` và số ô của dòng; `level.size` lấy từ đó.
    - `test_rules_enemy_phase.gd:11–12`, `test_battle_controller.gd:37–38`: `range(level.size.x * level.size.y)`.
    - `test_scenario_loader.gd:48`: như 4.2.
    - `test_battle_state.gd:105`, `test_loaders.gd:125`: kiểm giá trị thật của trận 1, **giữ**.
    - Thêm một test luật trên bàn khác cỡ bằng `BoardFixture.state(..., Vector2i(10, 8))`: Khoái ở `9,7` (góc dưới phải), `RulesMove.reachable` chứa `9,4` và `6,7`, không chứa ô nào có `x >= 10` hoặc `y >= 8`. Đặt trong `test_rules_move.gd`.
    - Xong: `grep -rnE "range\((7|49)\)" game/tests` rỗng.
  - [x] 4.6 "Làm hỏng tạm" (như 1.8), mỗi lần **một chỗ**, lưu bản sao file trước, trả lại từ bản sao (**không** `git checkout`), `diff` với bản sao sau mỗi lần, ghi tên test trượt vào Debug Log:
    - `BOARD_MAX = Vector2i(11, 8)` → `test_board_too_wide` trượt;
    - `fit_scale` luôn trả `1.0` → `test_fit_scale_uses_whole_steps` trượt;
    - `setup` bỏ `.round()` → không bắt buộc trượt (7×7, 5×5, 10×8 đều ra số nguyên); ghi lại kết quả thật, không cần thêm test;
    - `level_loader` gán `level.size = Vector2i(7, 7)` → `test_board_size_follows_level` và `test_co_nho_and_co_lon_load` trượt.
- [ ] **Task 5: Trận thử, đợt duyệt kịch bản** (AC: 1, 5, 7)
  - [x] 5.1 Thêm `game/data/tran/thu_co_nho.json` và `thu_co_lon.json` đúng như Dev Notes "Trận thử". Không sửa trận cũ.
  - [x] 5.2 `tools/xem_kich_ban.sh va_cham`: kịch bản 5×6 hiện bàn 5 cột × 6 hàng, trước và sau đúng `mo_ta`. `tools/test.sh` xanh, có dòng `Kịch bản luật: 36 đã duyệt · 1 chưa duyệt (0 chưa đạt)`. Ghi Debug Log.
  - [x] 5.3 Commit: `Cỡ bàn theo file trận, kịch bản mép bàn 5×6 chờ duyệt (Story 1.9)`.
  - [ ] 5.4 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh va_cham`, đọc kịch bản `day_vao_mep_ban_5x6`, trả lời "đúng" hoặc "sai: <lý do>". Nói rõ: luật đẩy vào mép bàn đã có từ Story 2.1, nên kịch bản này **đạt ngay** khi duyệt; nó kiểm rằng mép bàn tính đúng trên bàn không phải 7×7 (cột 4, hàng 5 là mép).
  - [ ] 5.5 Tác giả nói "đúng": đổi `da_duyet: true` (chỉ khóa đó). "Sai": sửa kịch bản theo lý do rồi cho duyệt lại, không sửa code để khớp. Kịch bản đúng mà game sai thì sửa code (không sửa `src/core/` nếu chưa hỏi tác giả).
- [ ] **Task 6: Kiểm bằng mắt và bản web** (AC: 1, 3, 5, 6, 11)
  - [ ] 6.1 Chụp (GoPeak nếu chạy được; không thì dùng script chụp tạm như Debug Log 1.8, không đưa script vào repo). Lưu `_bmad-output/implementation-artifacts/anh/1-9-*.png`:
    - `tools/chay.sh --dev --tran=thu_co_nho`: bàn 5×5 giữa vùng chơi;
    - `--tran=thu_co_lon`: bàn 10×8 vừa vùng chơi, không đè HUD; chọn Khoái thấy ô sáng; sau khi đánh `9,4`; F1 có `9,7`;
    - trận 1: giống `anh/1-8-1-tran-1.png`.
  - [ ] 6.2 Đọc `board.position` thật của từng trận (log tạm hoặc test) trước khi bấm. Số dự tính ở Dev Notes "Bàn có vừa không".
  - [ ] 6.3 Thử một file trận hỏng (chép `thu_co_nho.json` ra `user://` hoặc dùng test) để chụp màn hình lỗi cỡ bàn. Không để file hỏng trong `game/data/tran/`.
  - [ ] 6.4 `tools/build_web.sh` đạt. Không deploy.
- [ ] **Task 7: Tài liệu, test, commit** (AC: 8, 9)
  - [ ] 7.1 `deferred-work.md`, mục review 1.7 "`BoardView.setup` … tràn dưới HUD": thêm "**Đã làm ở Story 1.9** (canh theo cỡ bàn, thu theo bậc nguyên; bàn lớn nhất 10×8 vừa ở 1:1)".
  - [ ] 7.2 `game-architecture.md`: mục "Cỡ bàn" (dòng ~322) đã viết đúng; chỉ thêm `NO_SIZE` nếu dùng, và ghi "thu theo bậc `1/k`" vào dòng 684 nếu chưa có. Không sửa chỗ khác.
  - [ ] 7.3 `tools/test.sh` xanh. Commit: `Cỡ bàn theo file trận (Story 1.9)`, gồm kịch bản đã duyệt, ảnh, `.uid` mới.
  - [ ] 7.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes theo mẫu ở Dev Notes, dùng kết quả thật.

## Dev Notes

### Bối cảnh

- Bàn đang khóa 7×7 ở **một hằng số**: `BoardLayers.BOARD_SIZE` (`game/src/data/board_layers.gd:8`), dùng ở `level_loader.gd:7, 75` và `scenario_loader.gd:265, 381, 393`. Luật (`src/core/`) đã dùng `level.size` / `state.size` (`battle_state.gd:23, 77, 82`), nên **không cần sửa luật** [proposal 2026-10-20, mục 2].
- Cỡ bàn **suy ra từ bàn cờ chữ**: số dòng của `dia_hinh` là số hàng, số ký hiệu trên một dòng là số cột. Không thêm trường JSON mới. Mọi lớp phải cùng cỡ. Hợp lệ: 5–10 cột, 5–8 hàng [game-architecture.md dòng 322–328; GDD "Grid System" dòng 135].
- Story 1.8 đã dọn đường: hình học chỉ ở `BoardView`, `board_rect()` tính qua `transform`, chuột qua `make_input_local`, `_local_rect()` chỉ phụ thuộc `cols`/`rows` và hằng số [1.8, "Để Story 1.9 dễ làm"].
- Kịch bản luật dùng chung `BoardLayers` với file trận, nên luật cỡ bàn áp cho cả hai [architecture dòng 327].
- `ScenarioRunner` và `scenario_viewer.gd` đã lặp theo `state.size` / `scenario.before.size`: không cần sửa (`scenario_runner.gd:148–158`, `scenario_viewer.gd:145–226`).

### Câu lỗi (tiếng Việt, so đúng cả câu trong test)

Tiền tố `<file>: ` như mọi câu lỗi hiện có. `<lớp>` là `shown` hiện tại (`dia_hinh`, `quan`, `truoc.dia_hinh`, `sau.quan`…).

| Trường hợp | Câu lỗi |
|---|---|
| Lớp đầu tiên, một dòng khác số ô dòng đầu | `"<lớp>" dòng N: có X ô, dòng M có Y` |
| Lớp khác, một dòng khác số cột của lớp đầu | `"<lớp>" dòng N: có X ô, "<lớp đầu>" có Y` |
| Lớp khác, khác số dòng | `"<lớp>" có X dòng, "<lớp đầu>" có Y` |
| Cỡ ngoài giới hạn | `"<lớp đầu>": bàn C cột × H hàng, chỉ được từ 5 đến 10 cột và từ 5 đến 8 hàng` |

- "dòng M" thường là "dòng 1" (dòng đầu tiên là chuỗi).
- Số 5, 10, 8 trong câu lấy từ `BOARD_MIN`/`BOARD_MAX`, không gõ tay.
- Lớp đầu `[]` (danh sách rỗng): báo bằng câu cỡ ngoài giới hạn (`bàn 0 cột × 0 hàng`).
- Câu lỗi cũ "có X dòng, cần 7" và "có X ô, cần 7" **mất hẳn**; tìm `cần 7` trong test để sửa hết (`test_loaders.gd:228, 332, 342`, `test_scenario_loader.gd:535`).
- Câu lỗi "dòng N phải là một chuỗi", "ký hiệu lạ", "nằm ngoài bàn", "không phải ô trong bàn" **giữ nguyên chữ**.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

**`game/src/data/board_layers.gd`** (152 dòng)
- Hiện tại: `BOARD_SIZE`, `read_layer` (kiểm số ô từng dòng và số dòng theo hằng, ký hiệu lạ → `""`, dòng hỏng → `null`, sai số dòng → `[]`), `has_symbol`, `symbol`, `check_unit_cells` (lặp hằng), `read_enemy_order` (kiểm trong bàn theo hằng), `reading_order` (lặp hằng), `terrain_values`.
- Đổi: Task 2.1–2.5.
- Giữ nguyên: cách gom lỗi (`LoadResult.add_error`), quy ước dòng hỏng `null` / lớp hỏng `[]`, `symbol()` trả `""` khi không đọc được, `GENERAL_SYMBOLS`, `ENEMY_SYMBOLS`, mọi câu lỗi không thuộc bảng trên.
- Lưu ý: `symbol(rows, cell)` đọc `rows[cell.y][cell.x]` không kiểm biên. Khi lặp theo cỡ của `rows` thì dòng `null` phải bỏ qua (như hiện nay).

**`game/src/data/level_loader.gd`** (112 dòng)
- Hiện tại: thứ tự lỗi ghi ở đầu file; `level.size = BOARD_SIZE`.
- Đổi: Task 2.6. Thêm "cỡ bàn" vào chú thích thứ tự lỗi (sau lớp `dia_hinh`).
- Giữ nguyên: thứ tự lỗi còn lại, `terrain_clean`/`units_clean`, kiểm ô ải chỉ khi `dia_hinh` sạch.

**`game/src/data/scenario_loader.gd`** (411 dòng)
- Hiện tại: `_read_side` đọc `dia_hinh`, `quan` của mỗi phần; `_read_hp` (dòng ~265) và `_read_step_cell` (dòng ~381) kiểm trong bàn theo hằng; `_build_level` (dòng ~393) gán hằng.
- Đổi: Task 2.7. `_read_side` nhận cỡ (`NO_SIZE` cho `truoc`, cỡ của `truoc.dia_hinh` cho `sau`); `_read_steps`/`_read_step` nhận cỡ để `_read_step_cell` kiểm.
- Giữ nguyên: mọi câu lỗi khác, `COMMANDS`, `REJECT_CODES`, cấu trúc `Section`.

**`game/src/battle/board_view.gd`** (sau Story 1.8)
- Hiện tại: `TILE_SIZE = 64`, `AREA = Rect2(16, 52, 940, 612)`, `setup()` canh giữa và `round()`, `board_rect() = transform * _local_rect()`, `_local_rect()` theo `cols`/`rows`, `_target_layer` (viền mục tiêu trên quân, review 1.8), `_redraw()`.
- Đổi: Task 3.1–3.3.
- Giữ nguyên: mọi thứ khác của 1.8, gồm `_target_layer` và `_redraw()`.

**Test sẽ sửa:** `test_loaders.gd`, `test_scenario_loader.gd`, `test_board_view.gd`, `test_battle_view.gd`, `board_fixture.gd`, `test_rules_move.gd`, `test_rules_enemy_phase.gd`, `test_battle_controller.gd`. Danh sách chỗ `range(7)`/`49`: `board_fixture.gd:23, 25, 37, 40, 43`; `test_rules_move.gd:28, 31, 34, 55, 57`; `test_scenario_loader.gd:48`; `test_rules_enemy_phase.gd:11–12`; `test_battle_controller.gd:37–38`.

### Bàn có vừa không (1280×720, ô 64 px, hằng số Story 1.8)

`_local_rect()`: trái `-2`, phải `cols·64 + 2`, trên `-24`, dưới `rows·64 + 12 + 2`. Vùng chơi `AREA` 940×612, tâm `(486, 358)`.

| Bàn | Khung `board_rect` | `fit_scale` | `board.position` dự tính | Khung trên màn hình |
|---|---|---|---|---|
| 5×5 | 324 × 358 | 1 | (326, 203) | x 324–648, y 179–537 |
| 7×7 (trận 1) | 452 × 486 | 1 | **(262, 139)** (như 1.8) | x 260–712, y 115–601 |
| 10×8 | 644 × 550 | 1 | (166, 107) | x 164–808, y 83–633 |

- Mọi cỡ hợp lệ đều vừa ở 1:1 (lớn nhất 644×550 trong 940×612). Nhánh thu nhỏ chỉ chạy khi đổi `AREA` hoặc độ phân giải; vẫn phải có và có test (AC 2).
- "Thu theo bậc nguyên" hiểu là `1/2`, `1/3`… (ô 32, 21,3… px). Tranh E8 lọc Nearest thu `1/2` vẫn sắc; `1/3` thì không còn nguyên điểm ảnh nhưng chỉ xảy ra ở độ phân giải không dùng (quyết định mặc định 3).
- Đọc `board.position` thật trước khi bấm bằng GoPeak (bài học 1.8).

### Trận thử

`game/data/tran/thu_co_nho.json` (5×5):

```json
{
  "phien_ban_dinh_dang": 1,
  "ten": "Thử bàn nhỏ",
  "kieu": "tieu_diet",
  "dia_hinh": [
    ". . ~ . .",
    ". # ~ . .",
    ". . . . .",
    ". . ~ ^ .",
    ". . ~ . ."
  ],
  "quan": [
    ". B . . K",
    ". . . . .",
    ". . . . .",
    ". . . . .",
    "1 . . 2 ."
  ],
  "thu_tu_dich": ["1,0", "4,0"],
  "tiep_vien": [],
  "muu_ke_mo": []
}
```

`game/data/tran/thu_co_lon.json` (10 cột × 8 hàng; có `D` nên có `long_dan` như `thu_ba_tuong.json`):

```json
{
  "phien_ban_dinh_dang": 1,
  "ten": "Thử bàn lớn",
  "kieu": "tieu_diet",
  "dia_hinh": [
    ". . . . ~ . . . . .",
    ". # . . ~ . . . L .",
    ". . . . ~ . . . . .",
    ". . . . . . . . . .",
    ". . ^ . ~ . . . . .",
    ". . . . ~ . . D . .",
    ". . . . ~ . . . . A",
    ". . . . ~ . . . . ."
  ],
  "quan": [
    ". B . . . . . . . K",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    ". . . . . . . . 1 B",
    ". . . . . . . . . .",
    ". . . . . . . . . .",
    "2 . 3 . . . . . B ."
  ],
  "thu_tu_dich": ["1,0", "9,0", "9,4", "8,7"],
  "long_dan": 3,
  "tiep_vien": [],
  "muu_ke_mo": []
}
```

- AC 5 trên `thu_co_lon`: Khoái `8,4` kề Bộ binh `9,4`, chưa đi nên bấm một lần là đánh, đẩy sang phải ra ngoài cột 9. Sau `Space`, Khoái đi `8,4 → 8,6` (2 ô, `tam_di` 3); đã đi nên bấm Bộ binh `8,7` lần đầu là chờ xác nhận (Story 2.1), lần hai mới đánh, đẩy xuống ra ngoài hàng 7.
- Chỉ số thật (`data/chi_so.json`): Khoái 2 sát thương, đẩy 1; Bộ binh 3 máu. Va mép mất thêm 1 → gục (như `kich_ban/va_cham/day_vao_mep.json`).
- Chưa có pha địch (Story 2.6), nên `Space` chỉ sang hiệp mới.

### Đợt kịch bản 6 (mép bàn trên bàn 5×6)

`game/tests/kich_ban/va_cham/day_vao_mep_ban_5x6.json`, `da_duyet: false`:

```json
{
  "phien_ban_dinh_dang": 1,
  "mo_ta": "Bàn 5 cột × 6 hàng: Bộ binh ở hàng cuối (hàng 5) bị Khoái đẩy xuống ra ngoài bàn: đứng yên, mất thêm 1 máu, gục.",
  "da_duyet": false,
  "truoc": {
    "dia_hinh": [
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . ."
    ],
    "quan": [
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . 1 . .",
      ". . B . ."
    ]
  },
  "hanh_dong": [
    { "lenh": "danh", "tuong": "1", "o": "2,5" }
  ],
  "sau": {
    "dia_hinh": [
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . ."
    ],
    "quan": [
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . . . .",
      ". . 1 . .",
      ". . . . ."
    ],
    "da_danh": ["1"]
  }
}
```

- Theo mẫu `va_cham/day_vao_mep.json` (đã duyệt): cùng luật, khác cỡ bàn và khác hướng đẩy (xuống, vì bàn có 6 hàng chứ không phải 7). Trên bàn 7×7, hàng 5 **không** phải mép, nên kịch bản này chỉ đúng khi bộ nạp lấy cỡ từ bàn cờ chữ.
- Dev có thể thêm một kịch bản thứ hai (đẩy sang phải ra ngoài cột 4) nếu muốn, cũng `da_duyet: false`, cùng đợt duyệt.

### Quy trình kịch bản của story này (lệch M3, tác giả đồng ý 2026-10-20)

- M3 đòi: kịch bản mới, duyệt xong, chạy test phải **trượt**, rồi mới viết code.
- Story này không có luật mới. Kịch bản 5×6 **trượt trước khi sửa bộ nạp** (sai định dạng: "có 5 ô, cần 7"), Task 1.2 ghi lại bằng chứng đó. Sau Task 2, nó nạp được và **đạt ngay** vì luật mép bàn đã có (Story 2.1).
- Vì kịch bản sai định dạng không hiện được trong `tools/xem_kich_ban.sh`, đợt duyệt chạy **sau** Task 2 (bộ nạp), không phải trước. **Tác giả đồng ý cách này (2026-10-20).**

### Luật kiến trúc phải theo

- `src/core/` cấm sửa (AC 10). `check_boundaries.sh` chạy trong `tools/test.sh`.
- Bộ nạp gom mọi lỗi rồi mới trả, không ghi log; lỗi dữ liệu là `LoadResult` với câu tiếng Việt, không `assert()` [project-context "Không để game kẹt"].
- JSON trả số về `float`: tọa độ qua `BoardText.parse_cell`, đã là `int`.
- Gõ kiểu tĩnh mọi nơi; `Variant` từ JSON phải kiểm kiểu trước khi ép.
- Mọi đổi ô ↔ điểm chỉ ở `board_view.gd`; thu nhỏ là `scale` của `BoardView`, không đổi `TILE_SIZE` [architecture dòng 684].
- Không lặp cứng cỡ bàn trong code và test mới [project-context "Hiệu năng"].
- Không thêm trường JSON mới. Preset web đã có filter `*.json` nên trận thử mới tự vào bản web, như `thu_lao.json`.

### Testing

- Test nạp so **đúng cả câu lỗi** (mẫu `_errors([...])` ở `test_loaders.gd`, `F + ': ...'` ở `test_scenario_loader.gd`).
- Test giao diện mở `main.tscn` thật: `AppState.launch.dev = true`, `AppState.launch.tran = "<tên>"` (mẫu `_make_three_generals`, `test_board_view.gd:47`). `after_each` đã đặt lại `AppState.launch`.
- Bấm bằng sự kiện thật qua `BattleInput` (`get_global_transform_with_canvas() * BoardView.cell_center(cell)`), nên `scale` sai thì test trượt.
- `Rect2.has_point` không tính cạnh phải và dưới; `_local_rect` cộng nửa nét viền (1.7, 1.8).
- Hiện có **406** test (sau review 1.8). Ghi số thật ở Debug Log, Completion Notes, Change Log; ba nơi phải khớp.
- Phá thử mỗi lần **một** chỗ, trả lại từ bản sao (Task 4.6).

### Hướng dẫn tác giả tự test (mẫu; dev ghi lại bằng kết quả thật ở Completion Notes)

1. `tools/test.sh`: thấy `Kịch bản luật: 37 đã duyệt · 0 chưa duyệt` và `✅ … test đạt`.
2. `tools/chay.sh`: trận 1 y như trước (so ảnh `anh/1-8-1-tran-1.png`).
3. `tools/chay.sh --dev --tran=thu_co_nho`: bàn 5 cột × 5 hàng nằm giữa vùng bên trái HUD.
4. `tools/chay.sh --dev --tran=thu_co_lon`: bàn 10 cột × 8 hàng, vẫn không đè bảng HUD bên phải.
   - Bấm Khoái (góc phải, hàng 4), bấm Bộ binh ngay bên phải: Bộ binh bị đẩy vào mép, gục.
   - `Space`. Bấm Khoái, bấm ô hai bước phía dưới, bấm Bộ binh ở hàng cuối: thấy viền dày và dòng "Bấm lần nữa để đánh". Bấm lần nữa: Bộ binh gục.
   - F1 (Mac: Fn+F1): tọa độ góc dưới phải là `9,7`.
   - Bấm sát mép và góc các ô ở cột 9, hàng 7: luôn chọn đúng ô.
5. Thử báo lỗi: chép `game/data/tran/thu_co_nho.json` thành `thu_hong.json`, xóa một dấu `.` ở dòng 2 của `dia_hinh`, chạy `tools/chay.sh --dev --tran=thu_hong`: thấy lỗi tiếng Việt ghi tên file, "dòng 2: có 4 ô, dòng 1 có 5". Thử thêm một cột vào mọi dòng của bàn lớn (11 cột): thấy lỗi "bàn 11 cột × 8 hàng…". **Xóa `thu_hong.json` khi thử xong.**
6. `tools/xem_kich_ban.sh va_cham --tat_ca`: thấy kịch bản bàn 5×6.

### Previous Story Intelligence (Story 1.8 và review)

- **1.8:**
  - Hình học chỉ ở `BoardView`; `board_rect = transform * _local_rect()`. Đã có test bố cục, test bấm mọi ô, test đồng quân không che tâm ô bên cạnh.
  - Review 1.8: viền mục tiêu vẽ trên quân qua `_target_layer` (con sau `_world`, trước F1), mọi chỗ vẽ lại gọi `_redraw()`. Không được làm mất.
  - `NAME_FONT_SIZE` 15. `board.position` trận 1 = `(262, 139)`.
  - Máy dev chưa có Node 20 nên GoPeak không chạy; 1.8 chụp bằng script tạm `godot --path game --script chup.gd -- --dev …` (mở `main.tscn`, gửi input qua `root.push_input`, lưu `root.get_texture().get_image()`). Script nằm ngoài repo.
  - Phá thử: lưu bản sao `game/src` vào scratchpad, sửa một chỗ, chạy test, `cp` trả lại, `diff -r` kiểm. Không `git checkout`.
- **2.1–2.3:** Test giao diện bấm qua `BattleInput` là lưới an toàn cho đổi hình học. Đẩy vào mép: mất thêm 1 máu (`va_cham/day_vao_mep.json`).
- **1.1, 1.3:** Bộ nạp gom lỗi; câu lỗi so nguyên văn; "lớp hỏng thì không kiểm chéo" (`units_clean`, `terrain_clean`). Giữ tinh thần đó cho kiểm cỡ.
- **Sự cố 2.3:** `git checkout -q game/src` khi phá thử đã xóa code chưa commit.
- **Mac:** F1/F5 là Fn+F1/Fn+F5.

### Git Intelligence

- Commit gần nhất: `19d14dc` sửa review 1.8 (viền trên quân); `a116ac1` Story 1.8; `f60aeef` tạo story 1.8; `63dcc47` bản nháp hình Phạm Ngũ Lão (`img/`, chưa vào game); `f6e425b` tài liệu cỡ bàn theo trận.
- Mẫu lời commit: tiếng Việt, kết bằng `(Story 1.9)`, có dòng `Co-Authored-By`. Story có kịch bản: một commit "… chờ duyệt", một commit khi xong.
- Kiểm `git status` trước khi bắt đầu; không gộp file ngoài story (`img/`, `NEXT-STEPS.md`).

### Project Context Rules

- Godot **4.7.2**, GDScript, GUT 9.7.1, renderer Compatibility, 1280×720, stretch `canvas_items`, aspect `keep`. Không tự nâng phiên bản.
- **Context7** (`/godotengine/godot-docs/__branch__4.7`): tra `Node2D.scale`, `CanvasItem.make_input_local`, `Transform2D * Rect2` nếu cần. **GoPeak** cần Node ≥ 20.18.1.
- Bàn tối đa 10×8 (80 ô): không tối ưu, không cache.
- **Không lặp cứng cỡ bàn** (`range(7)`, `49`); dùng `level.size` hoặc cỡ của trận thử.
- Quy trình M3: AI viết kịch bản `da_duyet: false`, tác giả duyệt bằng `tools/xem_kich_ban.sh`. Cấm sửa hay xóa kịch bản đã duyệt để test đạt.
- Lỗi dữ liệu: `LoadResult`, câu tiếng Việt kèm file, dòng, giá trị sai (`test_loaders.gd`).
- Chữ hiển thị qua `tr()`. Câu lỗi bộ nạp **không** qua `tr()` (như hiện nay).
- Xong một việc nghĩa là `tools/test.sh` xanh rồi commit. Không `push --force`.
- Nói với tác giả bằng tiếng Việt, theo bước thử.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

1. **Số cột lấy từ dòng đầu** của `dia_hinh`; dòng khác thì báo "dòng N: có X ô, dòng 1 có Y".
2. **Câu lỗi** như bảng "Câu lỗi".
3. **Thu theo bậc `1/k`** (1/2, 1/3…). Ở 1280×720 không bao giờ chạy.
4. **Đợt duyệt kịch bản chạy sau khi sửa bộ nạp**, và kịch bản đạt ngay khi duyệt (không có luật mới). Tác giả đã đồng ý 2026-10-20.
5. **Trận thử** `thu_co_nho`, `thu_co_lon` như Dev Notes; tác giả có thể đổi bố cục.

### References

- `_bmad-output/planning-artifacts/epics.md`: Story 1.9 (dòng 548–574), phương án cắt (dòng 184).
- `_bmad-output/planning-artifacts/sprint-change-proposal-2026-10-20-co-ban.md`: mục 2 (ảnh hưởng), 4.2 (kiến trúc), 5 (bàn giao).
- `_bmad-output/planning-artifacts/game-architecture.md`: dòng 322–328 (cỡ bàn), dòng 684 (ô ↔ điểm, canh giữa, bậc nguyên).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md`: Grid System (dòng 135–143), bảng 6 trận (dòng ~253).
- `_bmad-output/project-context.md`: hiệu năng, không lặp cứng cỡ bàn, M3, test.
- `_bmad-output/implementation-artifacts/1-8-ban-co-nhin-chech-o-vuong.md`: "Để Story 1.9 dễ làm", "Bàn có vừa không", Debug Log (chụp ảnh, phá thử), Review Findings.
- `_bmad-output/implementation-artifacts/deferred-work.md`: mục review 1.7 "tràn dưới HUD" (dòng ~92).
- `game/tests/kich_ban/va_cham/day_vao_mep.json` (mẫu kịch bản mép bàn).

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5[1m])

### Debug Log References

- **Task 1 (đỏ trước):** thêm `va_cham/day_vao_mep_ban_5x6.json` (`da_duyet: false`), `tools/test.sh` trượt ở `test_every_scenario_loads`: `"truoc.dia_hinh" dòng 1: có 5 ô, cần 7` (…), tóm tắt `36 đã duyệt · 0 chưa duyệt (0 chưa đạt) · 1 sai định dạng`.
- **Task 2, lệch so với Task 2.3–2.4:** không tách `check_size` riêng. Lớp đầu tiên (`size_shown == ""`) tự kiểm cỡ ngay trong `read_layer`, sau khi đọc hết dòng, chỉ khi không có dòng hỏng (`null`). `layer_size(rows)` trả `NO_SIZE` khi lớp rỗng hoặc có dòng hỏng. Lý do: lớp rỗng `[]` cần báo "bàn 0 cột × 0 hàng", mà bên gọi không phân biệt được "thiếu khóa" với "danh sách rỗng" từ giá trị trả về.
  - `read_layer` có ba chế độ: lớp đầu (so với dòng đầu, kiểm giới hạn); lớp khác có cỡ (so với `size`, sai số dòng trả `[]`); lớp khác mà lớp đầu hỏng (`NO_SIZE`, chỉ so các dòng với nhau, không kiểm giới hạn).
  - `symbol()` giờ an toàn khi ô nằm ngoài lớp (lớp `quan` có thể khác cỡ `dia_hinh` khi `dia_hinh` hỏng).
  - Ký hiệu lạ không làm mất cỡ (dòng vẫn đọc được, ô thành `""`), nên lớp `quan` vẫn được kiểm chéo.
- Viết test bộ nạp trước (`test_loaders.gd`, `test_scenario_loader.gd`), rồi sửa bộ nạp: còn trượt `test_co_nho_and_co_lon_load` vì chưa có trận thử; thêm trận thử (Task 5.1) thì xanh. Kịch bản 5×6 nạp được, chưa duyệt, đạt.
- **Task 3:** test bố cục cho 4 trận và `fit_scale` viết trước → lỗi parse `fit_scale()` chưa có (GUT bỏ cả file). Thêm `fit_scale` + `scale` trong `setup` → 424/424. `cell_center`, `cell_at`, `pick_cell`, `board_rect`, `BattleInput`, `CoordOverlay`, `main.gd` **không phải sửa**.
- **Task 4.4, 4.4b:** `test_large_board_edge_push_and_f1` và `test_f5_reload_follows_new_board_size` xanh ngay khi viết (sau Task 2–3, không cần code thêm).
- **Phá thử (Task 4.6)**, bản sao `game/src` ở scratchpad, `diff -r` sau mỗi lần (đều khớp):
  - `BOARD_MAX = (11, 8)` → `test_board_too_wide`, `test_board_too_small`, `test_board_too_tall`, `test_empty_terrain_layer_is_a_size_error`, `test_scenario_board_too_wide` trượt (câu lỗi chứa số 10);
  - `fit_scale` luôn `1.0` → `test_fit_scale_uses_whole_steps` trượt;
  - bỏ `.round()` trong `setup` → 427/427 đạt (đúng dự đoán: 5×5, 7×7, 10×8 đều ra số nguyên);
  - `level.size = Vector2i(7, 7)` trong `level_loader` → 13 test trượt (bố cục, bấm ô, nạp bàn nhỏ/lớn, F5 đổi cỡ, chơi bàn 10×8).
- **Task 5.2:** `tools/xem_kich_ban.sh va_cham` hiện bàn 5 cột × 6 hàng, trước/sau khớp `mo_ta`. `tools/test.sh`: 427/427, `36 đã duyệt · 1 chưa duyệt (0 chưa đạt)`.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List

### Change Log

- 2026-10-20: Tạo story. Cỡ bàn suy ra từ bàn cờ chữ (5×5 đến 10×8); mọi cỡ hợp lệ vừa ở ô 64 px trong 1280×720.
