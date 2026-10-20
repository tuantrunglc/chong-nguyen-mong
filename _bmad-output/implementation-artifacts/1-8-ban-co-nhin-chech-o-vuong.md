---
baseline_commit: f60aeeff4441d9b69b6b865b7803274d98bd6d8f
---

# Story 1.8: Bàn cờ nhìn chếch, ô vuông (thay bàn isometric)

Status: done

## Story

Là tác giả,
tôi muốn bàn cờ theo kiểu pixel art nhìn chếch từ trên xuống như ảnh mẫu,
để hình tạm bây giờ đã đúng hướng tranh sẽ làm ở E8.

_Thêm 2026-10-19 theo `sprint-change-proposal-2026-10-19-nhin-chech.md`. Cạnh ô 64 px theo `sprint-change-proposal-2026-10-20-co-ban.md` (tranh E8: ô 64×64, hiện 1:1). Làm ngay sau Story 2.3, trước Story 1.9 và 2.4. Cắt được: khi cắt thì giữ bàn isometric của Story 1.7._

_Story này chỉ **đổi cách vẽ**. Không có luật mới, không có đợt duyệt kịch bản. Bàn vẫn 7×7; cỡ bàn theo file trận là việc của Story 1.9 (làm ngay sau)._

## Acceptance Criteria

1. **Bàn ô vuông.** **Cho** trận 1 đang mở (`tools/chay.sh`), **thì** bàn 7×7 là các ô vuông. Ô `0,0` ở góc trên bên trái. Cột tăng thì sang phải, hàng tăng thì xuống dưới, giống hệt cách viết trong file trận. Bàn nằm gọn trong cửa sổ 1280×720, không đè lên tiêu đề, bảng HUD bên phải và nhãn phiên bản.
2. **Cỡ ô.** Cạnh ô trên màn hình là **64 px** (bội số của 16, khớp tranh E8 64×64 hiện 1:1). Góc trên trái của bàn rơi đúng điểm ảnh nguyên.
3. **Địa hình.**
   - Sông thấp hơn mặt đất, thấy bờ ở cạnh trên.
   - Rừng, kho lương, làng là khối nhô lên, thấy mặt trước tối hơn.
   - Ô ải là bệ đá thấp, quân đứng trên bệ được nâng lên như Story 1.7.
   - Hầm chông phẳng, có ký hiệu.
   - Mỗi loại ô vẫn phân biệt được bằng màu hoặc chữ ngắn.
   - Thử bằng `tools/chay.sh --dev --tran=thu_ba_tuong` (có đủ sông, rừng, hầm chông, kho lương, làng, ô ải).
4. **Quân và che khuất.** Mỗi quân là đồng tròn khắc chữ **đứng** trên ô, có bóng, vẫn hiện số máu. Màu "đã đi" (đỏ xỉn) và "đã đánh" (xám) như cũ. Đồng quân và khối cao được che một phần ô phía trên. Vật ở hàng dưới (`hang` lớn hơn) che vật ở hàng trên, không bao giờ ngược lại. Ví dụ trên `thu_ba_tuong`: Cung kỵ ở `5,2` che mặt trước kho lương `5,1`.
5. **Bấm đúng ô.** **Khi** bấm vào bất kỳ ô nào, kể cả sát mép ô (thử mọi ô của bàn), **thì** game chọn đúng ô đó. Bấm ngoài bàn thì như bấm ra ngoài (bỏ chọn).
6. **Bấm vào phần nhô lên.** **Khi** bấm vào phần thân đồng quân hoặc khối nhô sang ô phía trên, **thì** game chọn ô của quân hoặc khối đó, không chọn ô phía trên (như Story 1.7).
7. **Mọi thứ Story 1.4–2.3 vẽ lên bàn vẫn đúng.** **Khi** chọn tướng (chuột hoặc phím `1` `2` `3`), rê chuột lên ô sáng, xem viền mục tiêu của Khoái và của Lão (Story 2.1–2.3), **thì** ô sáng, vòng chọn, đường đi, viền mục tiêu, viền chờ xác nhận và màu đồng "đã đi"/"đã đánh" hiện đúng ô trên bàn mới. Đi, đánh, hủy (`Z`, nút Hủy), kết thúc lượt (`Space`, nút) như cũ. F5 như Story 1.6.
8. **F1.** **Khi** bật dev và bấm F1, **thì** tọa độ `cot,hang` hiện đúng trên từng ô và id quân hiện cạnh đồng quân của nó. Nhãn không đè lên tên quân và không nuốt chuột.
9. **Test.** `tools/test.sh` xanh. Test đổi ô ↔ điểm được sửa theo bàn mới:
   - đi rồi về đúng ô, cho mọi ô của bàn;
   - điểm sát 4 góc mỗi ô (cách 2 px vào trong) rơi đúng ô;
   - điểm ngoài 4 cạnh bàn là ngoài bàn;
   - bấm vào thân đồng quân và mặt trên khối nhô lên thì chọn đúng ô của chúng;
   - cạnh ô bằng 64 và chia hết cho 16.

   Test cũ dựa vào hình thoi được **sửa tại chỗ**, không xóa. Test mới không lặp cứng `range(7)` hay `49`.
10. **Web.** `tools/build_web.sh` đạt, dung lượng trong giới hạn. Tác giả mở bản build thử thấy mượt như trước.
11. **Không đụng luật.** Không sửa gì trong `game/src/core/`, `game/data/` và `game/tests/kich_ban/`.

## Tasks / Subtasks

- [x] **Task 1: Phép đổi ô ↔ điểm trong `BoardView`** (AC: 1, 2, 5, 6, 9)
  - [x] 1.1 Thay `TILE_W = 128`, `TILE_H = 64` bằng **một** hằng số `const TILE_SIZE: int = 64`. Mọi file khác đọc từ đây (bảng "Ai đang dùng `TILE_W`/`TILE_H`"). Xong task thì `grep -rn "TILE_W\|TILE_H" game/` phải rỗng.
  - [x] 1.2 `static func cell_center(cell)`: gốc tọa độ local của `BoardView` là **góc trên trái của ô `0,0` trên mặt đất**. Công thức: `Vector2((cell.x + 0.5) * TILE_SIZE, (cell.y + 0.5) * TILE_SIZE)`. Vẫn là hàm `static`, không phụ thuộc cỡ bàn (`UnitToken`, `TerrainBlock`, `CoordOverlay` và test gọi kiểu static).
  - [x] 1.3 `static func cell_rect(cell) -> Rect2`: ô vuông trên mặt đất, `Rect2(cell * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))`. Hàm này thay cho `diamond()` (xóa `diamond`).
  - [x] 1.4 `func cell_at(local_pos)`:
    - `Vector2i(floori(local_pos.x / TILE_SIZE), floori(local_pos.y / TILE_SIZE))`. Nằm ngoài `[0, cols) × [0, rows)` thì trả `NO_CELL`.
    - **Bắt buộc `floori`, không dùng `int()`.** `int(-0.5)` là `0`, nên điểm ngay bên trái hoặc ngay trên bàn sẽ rơi nhầm vào cột 0 hoặc hàng 0. Test 6.1 bắt lỗi này.
    - Giữ hợp đồng kiến trúc `cell_at(cell_center(c)) == c`.
  - [x] 1.5 `func pick_cell(local_pos)`: giữ cách làm của 1.7 (đồng quân trước, rồi khối; vật gần người xem nhất thắng; không trúng gì thì `cell_at`), nhưng:
    - "độ sâu" đổi từ `cot + hang` thành **`hang`** (`cell.y`);
    - hình chạm của khối (`_silhouette`) là `Rect2(cell_rect.position - Vector2(0, h), cell_rect.size + Vector2(0, h))` (mặt trên nâng `h` cộng mặt trước), kiểm bằng `Rect2.has_point` thay cho `Geometry2D.is_point_in_polygon`.
  - [x] 1.6 `_local_rect()` theo bàn mới:
    - trái `-stroke`, phải `cols * TILE_SIZE + stroke`;
    - dưới `rows * TILE_SIZE + EDGE_DEPTH + stroke`;
    - trên `-(maxf(PASS_HEIGHT + UnitToken.TOKEN_LIFT + UnitToken.RADIUS - TILE_SIZE / 2.0, BLOCK_HEIGHT) + TOP_MARGIN)`. Đây là phần nhô lên của hàng 0: đầu đồng đứng trên bệ ô ải, hoặc mặt trên khối, cái nào cao hơn. Tính từ hằng số, không ghi số cứng (review 1.7).
  - [x] 1.7 `board_rect()` trả `transform * _local_rect()` (`Transform2D * Rect2`) thay cho `Rect2(position + local.position, local.size)`. Bây giờ `scale` là 1 nên kết quả y như cũ. Story 1.9 thêm `scale` theo bậc nguyên thì màn hình lỗi và test bố cục tự đúng.
  - [x] 1.8 `setup(cols, rows)`: giữ cách canh giữa trong `AREA` bằng `(AREA.get_center() - _local_rect().get_center()).round()` (vị trí là số nguyên, AC 2). Không thêm `scale` ở story này. Số đo cụ thể ở Dev Notes "Bàn có vừa không".
- [x] **Task 2: Vẽ mặt đất trong `BoardView._draw`** (AC: 1, 3, 7)
  - [x] 2.1 Viết lại `draw_raised` (static, `TerrainBlock` dùng chung) cho ô vuông. Chữ ký gợi ý: `draw_raised(canvas, ground: Rect2, height, color, front_shade)`.
    - Mặt trên là `ground` nâng lên `height`, màu `color`.
    - Mặt trước là dải cao `height` ở cạnh dưới của `ground`, màu `color.darkened(front_shade)`.
    - Kẻ viền `LINE_COLOR` quanh mặt trên và mặt trước.
    - Không còn hai mặt bên: nhìn chếch từ phía Nam chỉ thấy mặt trước.
    - Dùng `draw_rect` (Context7: chữ ký `draw_rect(rect, color, filled, width, antialiased)` của Godot 4.7).
  - [x] 2.2 Tấm bàn và mép bàn: như 1.7, gọi `draw_raised` với `ground = Rect2(0, EDGE_DEPTH, cols * TILE_SIZE, rows * TILE_SIZE)` và `height = EDGE_DEPTH`. Mặt trên tấm trùng mặt đất của bàn; dải tối `EDGE_DEPTH` nằm dưới hàng cuối.
  - [x] 2.3 Sông trũng, thấy bờ ở cạnh trên:
    - Cả ô tô màu bờ `TERRAIN_COLORS[RIVER].darkened(RIVER_BANK_SHADE)`.
    - Mặt nước là `cell_rect` bỏ dải `RIVER_DEPTH` ở trên cùng.
    - Ô ngay phía trên cũng là sông thì **không** có dải bờ, nước liền một mạch (trận 1 có sông là cột 3, khe ở `3,3`). Ô ở hàng 0 luôn có bờ.
    - Kiểm ô phía trên bằng `_state.terrain_at` trong `[0, rows)`; `LevelData.terrain_at` không tự kiểm biên (`deferred-work.md`, review 1.1).
  - [x] 2.4 Hầm chông: ô màu `TERRAIN_COLORS[SPIKES]` và 3 mũi nhọn vẽ bằng đa giác. Đổi `SPIKE_OFFSETS` cho hợp ô vuông 64 px, chỉnh theo ảnh chụp.
  - [x] 2.5 Đường kẻ ô (`x = c * TILE_SIZE`, `y = r * TILE_SIZE`) và viền bàn `BORDER_WIDTH`, giữ cách vẽ hiện tại.
  - [x] 2.6 Vòng lặp vẽ theo độ sâu (bệ ô ải, ô sáng, viền mục tiêu, vòng chọn) đổi thành **từng hàng, từ trên xuống** (`for r in range(rows): for c in range(cols)`). Lý do vẫn như review 1.7: bệ ô ải ở hàng dưới che ô sáng ở hàng trên, còn ô sáng trên bệ nằm trên mặt bệ.
    - Bệ ô ải: `draw_raised(self, cell_rect(cell), PASS_HEIGHT, TERRAIN_COLORS[PASS], ...)`.
    - Ô sáng: `draw_rect` mặt trên của ô (`cell_rect` nâng `_surface(cell)`), màu `REACH_COLOR`.
    - Viền mục tiêu (`_draw_target`): khung vuông thụt vào trong mặt trên ô (gợi ý `grow(-TARGET_INSET)` với `TARGET_INSET = 5.0` px), không tô. `TARGET_WIDTH` thường, `PENDING_WIDTH` khi là ô chờ xác nhận. Màu trắng giữ nguyên (tác giả chốt 2026-10-18).
    - Vòng chọn: elip quanh `_top_center(cell)`, dẹt ít hơn bàn nghiêng. Gợi ý `SELECT_RADIUS = Vector2(28, 18)`, phải nằm gọn trong ô (`x < TILE_SIZE / 2`).
  - [x] 2.7 Đường đi giữ nguyên cách vẽ (nối `_top_center`, chấm cuối là elip `PATH_END_RADIUS`, gợi ý `Vector2(8, 6)`).
  - [x] 2.8 Chữ ngắn của ô phẳng (sông, hầm chông, ô ải) đặt ở phần dưới ô, quanh `_top_center(cell) + Vector2(0, TILE_SIZE / 4.0)`, bề ngang `TILE_SIZE`, để đồng quân đứng giữa ô không che hết. Chữ của khối nằm trên mặt trên khối (Task 3).
  - [x] 2.9 Sửa chú thích đầu file `board_view.gd` (đang ghi "isometric 2:1", "49 ô thoi", "đỉnh trên"). Viết theo bàn mới, không ghi số ô cứng.
- [x] **Task 3: Khối địa hình (`terrain_block.gd`)** (AC: 3, 4)
  - [x] 3.1 `ORIGIN_ABOVE_CENTER = BoardView.TILE_SIZE / 4.0`: khối đặt cao hơn tâm ô 16 px. Giữ cách 1.7 dùng để y-sort không bao giờ bằng nhau:
    - y của khối hàng `r` là `(r + 0.25) * 64`;
    - quân hàng `r - 1` ở `(r - 0.5) * 64`, nhỏ hơn 48 px, vẽ trước khối;
    - quân hàng `r` ở `(r + 0.5) * 64`, lớn hơn 16 px, vẽ sau khối;
    - quân đứng trên bệ ô ải hàng `r` ở `(r + 0.5) * 64 - 8`, vẫn lớn hơn 8 px.
  - [x] 3.2 `_draw`: `BoardView.draw_raised(self, <cell_rect dời về gốc của khối>, _height, color, FRONT_SHADE)`. Bỏ `LEFT_SHADE`/`RIGHT_SHADE`, thay bằng một `FRONT_SHADE` (gợi ý 0.35).
  - [x] 3.3 Chữ trên mặt trên khối: tâm `Vector2(0, ORIGIN_ABOVE_CENTER - _height)`, cỡ nhãn `Vector2(TILE_SIZE, TILE_SIZE / 2.0)`. Sửa chú thích đầu file (đang ghi "ô thoi", "hai mặt bên").
- [x] **Task 4: Đồng quân đứng (`unit_token.gd`)** (AC: 4, 6)
  - [x] 4.1 `position` giữ nguyên là chân đồng, bằng `BoardView.cell_center(unit.cell) - Vector2(0, lift)`. `test_main.gd:309–310` và `test_battle_view.gd:242` so `token.position == cell_center(...)` và phải xanh mà không sửa. Hoạt ảnh E2 (2.11) cũng sẽ dời `position` giữa các `cell_center`.
  - [x] 4.2 Cỡ gợi ý: `RADIUS = 24`, `TOKEN_LIFT = 20`. Đồng phủ từ `-44` tới `+4` so với tâm ô, tức nhô 12 px lên ô phía trên. Ba ràng buộc bắt buộc, có test ở Task 6:
    - `TOKEN_LIFT + RADIUS < TILE_SIZE`: đồng không với tới tâm ô phía trên;
    - `RADIUS < TILE_SIZE / 2`: đồng không lấn sang ô hai bên;
    - đồng ở hàng dưới không che tâm ô hàng trên.
  - [x] 4.3 Bóng: elip mờ ở `(0, 0)`, gợi ý `SHADOW_RADIUS = Vector2(22, 8)`. `NAME_FONT_SIZE` có thể giảm còn 14–15 nếu chữ "Khoái" tràn đồng 48 px (xem ảnh chụp). `HP_OFFSET` chỉnh cho chấm máu nằm ở góc dưới phải đồng và vẫn trong ô.
  - [x] 4.4 Giữ nguyên: `setup`, `update(unit, lift)`, `hit()`, `cell`, `unit_id`, `unit_type`, `NAME_KEYS`, các màu phe, "đã đi", "đã đánh", và các hàm đọc cho test (`hp_text`, `name_text`, `is_moved`, `is_attacked`). Sửa chú thích đầu file (đang ghi "bàn nghiêng").
- [x] **Task 5: F1, input, `main.gd`, HUD** (AC: 1, 7, 8)
  - [x] 5.1 `CoordOverlay.show_state`:
    - Nhãn `cot,hang` đặt ở **góc dưới trái** ô, tâm quanh `BoardView.top_center(cell, kind) + Vector2(-TILE_SIZE / 4.0, TILE_SIZE / 4.0)`. Chỗ này nằm ngoài đồng quân, nên không đè tên quân.
    - Nhãn id quân giữ công thức hiện tại (`feet + Vector2(RADIUS, -TOKEN_LIFT - RADIUS)`, góc trên phải đồng).
    - Chỉ gọi hàm của `BoardView`, không tự tính hình học.
    - Giữ `MOUSE_FILTER_IGNORE`. Sửa chú thích đầu file.
  - [x] 5.2 `BattleInput`: **không sửa code** (chỉ gọi `pick_cell` qua `make_input_local`). Có thể sửa chú thích nếu còn nhắc bàn nghiêng.
  - [x] 5.3 `main.gd`: màn hình lỗi đã lấy khung từ `board_rect()` nên không sửa code. Sửa chú thích `TITLE_TOP`/"bàn cờ bắt đầu ở y = 52" nếu không còn đúng.
  - [x] 5.4 `hud.gd` dòng 9: chú thích "bàn nghiêng nằm trong BoardView.AREA" đổi thành "bàn nằm trong BoardView.AREA". `PANEL_POSITION` giữ `(972, 52)`.
- [x] **Task 6: Test** (AC: 9; viết test trước, cho thấy đỏ rồi mới sửa code; ghi Debug Log)
  - [x] 6.1 `game/tests/test_board_view.gd`: sửa tại chỗ, không xóa test. Đổi chú thích đầu file.
    - `_all_cells(board)` lặp theo `board.cols`/`board.rows`, không lặp `range(7)`.
    - `_corners(cell)` trả 4 góc của `cell_rect`.
    - `test_cell_center_round_trips_every_cell`: giữ.
    - `test_points_near_each_corner_stay_in_cell`: giữ ý, dùng góc ô vuông, `EDGE_STEP = 2.0`.
    - `test_points_outside_big_diamond_are_off_board` → `test_points_outside_board_are_off_board`. Thử 4 điểm, mỗi điểm cách cạnh bàn 2 px ra ngoài: trên `0,0`, trái `0,0`, phải ô cuối hàng 0, dưới ô cuối cột 0. Thêm điểm `(-1, TILE_SIZE / 2)` để bắt lỗi `int()` thay cho `floori`.
    - `test_columns_go_down_right_rows_go_down_left` → `test_columns_go_right_rows_go_down`:
      - `cell_center(1,0) - cell_center(0,0) == Vector2(TILE_SIZE, 0)`;
      - `cell_center(0,1) - cell_center(0,0) == Vector2(0, TILE_SIZE)`.
    - Thêm `test_tile_is_64_px_multiple_of_16`: `TILE_SIZE == 64` và `TILE_SIZE % 16 == 0` (AC 2).
    - `test_pick_every_cell_center_with_units_on_board`: giữ, cho cả trận 1 và `thu_ba_tuong`.
    - `test_pick_head_of_token_selects_its_cell`: Lão ở `2,6`, `head = cell_center(2,6) + (0, -TOKEN_LIFT - RADIUS + 4)`. Đổi điều kiện trước thành `cell_at(head) == Vector2i(2, 5)` (ô phía trên), `pick_cell(head) == 2,6`.
    - `test_mouse_click_on_token_head_selects_that_general`: giữ.
    - `test_pick_raised_block_top_selects_block`:
      - điểm ở mặt trên khối rừng `1,1` phần nhô lên ô `1,0`: `cell_rect(1,1).position + Vector2(TILE_SIZE / 2.0, -BLOCK_HEIGHT + 4)`;
      - `cell_at` của điểm đó là `1,0`, `pick_cell` là `1,1`;
      - ô `1,0` có Bộ binh; điểm này phải nằm ngoài đồng của nó, nên kiểm thêm `not token.hit(...)`.
    - `test_pick_outside_board_is_no_cell`: điểm trên bàn, cao hơn mọi vật nhô lên.
    - `test_blocks_and_tokens_sort_by_depth`: độ sâu là `cell.y`. Quân ở hàng nhỏ hơn hàng khối có y nhỏ hơn; quân cùng hàng hoặc hàng lớn hơn có y lớn hơn.
    - `test_token_on_pass_stands_on_platform`:
      - đầu đồng trên bệ (`-PASS_HEIGHT - TOKEN_LIFT - RADIUS + 4`) giờ rơi vào đất của ô `0,5`, nên đổi `assert_eq(board.cell_at(head), BoardView.NO_CELL)` thành `Vector2i(0, 5)`;
      - giữ các ý còn lại: cao hơn đầu đồng đứng trên đất phẳng, `pick_cell == 0,6`, khung bàn bao đầu đồng, bệ không phải khối.
    - `test_board_fits_left_of_hud_below_title`: dùng `BoardView.AREA` thay cho số `Rect2(16, 52, 940, 612)` chép tay.
    - `test_board_rect_covers_every_cell_and_token`: giữ, dùng góc ô vuông.
    - Thêm `test_board_sits_on_whole_pixels`: `board.position == board.position.round()` (AC 2).
    - Thêm `test_token_and_block_never_cover_a_neighbour_center`: kiểm ba ràng buộc ở Task 4.2 bằng hằng số, và thêm `BLOCK_HEIGHT < TILE_SIZE / 2.0`.
    - `test_target_outline_and_pending_are_cleared`: giữ.
  - [x] 6.2 `game/tests/test_battle_view.gd`:
    - `test_resting_mouse_follows_token_moving_under_it` (dòng ~420): đổi ô `1,5` thành **`0,5`** ở cả `point` và `_click`, sửa chú thích. Lý do và phép tính ở Dev Notes "Test cũ dựa vào số đo của bàn nghiêng". Đường đi mong đợi `[0,5, 0,4]` giữ nguyên.
    - `test_coord_overlay_follows_moved_unit` (dòng ~389): giữ nếu công thức nhãn id giữ như Task 5.1; đổi công thức nhãn thì sửa test theo.
    - Mọi test bấm hoặc rê qua `get_global_transform_with_canvas() * BoardView.cell_center(cell)` (`_hover_by_mouse`, `_click_by_mouse`, `test_mouse_events_map_screen_pixels_to_cells`, cả các test đánh và lao của Story 2.1–2.3) phải xanh mà **không sửa**. Trượt thì `pick_cell` hoặc `cell_at` sai.
  - [x] 6.3 `game/tests/test_main.gd`: `test_title_label_sits_above_board`, `test_error_screen_covers_board_rect`, `test_level_1_shows_terrain_and_units` phải xanh mà không sửa.
  - [x] 6.4 "Làm hỏng tạm" để thấy test bắt được lỗi (như 1.7). Mỗi lần **chỉ sửa một chỗ**, chạy `tools/test.sh`, ghi tên test trượt vào Debug Log, rồi trả lại ngay:
    - `cell_at` dùng `int()` thay cho `floori` → `test_points_outside_board_are_off_board` trượt;
    - tắt `_world.y_sort_enabled` → `test_blocks_and_tokens_sort_by_depth` trượt;
    - `BattleInput` gọi `cell_at` thay cho `pick_cell` → `test_mouse_click_on_token_head_selects_that_general` trượt;
    - bỏ nâng quân trên ô ải → `test_token_on_pass_stands_on_platform` trượt;
    - `TILE_SIZE = 60` → `test_tile_is_64_px_multiple_of_16` trượt.

    Sau mỗi lần: `git diff --quiet game/src`. Lưu bản sao file trước khi sửa, trả lại từ bản sao, **không** dùng `git checkout`: sự cố ở Story 2.3 làm mất code chưa commit.
  - [x] 6.5 `git diff --stat` không có file nào trong `game/src/core/`, `game/data/`, `game/tests/kich_ban/` (AC 11).
- [x] **Task 7: Kiểm bằng mắt (GoPeak) và bản web** (AC: 1–8, 10)
  - [x] 7.1 Chạy nền `tools/chay.sh --dev`, chờ khoảng 5 giây, rồi `capture_screenshot`. Phải thấy: bàn vuông, `0,0` ở góc trên trái, sông là cột dọc có khe ở `3,3`, quân đứng có bóng, không đè tiêu đề và HUD.
    - `inject_action select_general_1`: 7 ô sáng, vòng chọn đúng chỗ.
    - `inject_mouse_click` vào tâm một ô sáng: Khoái đi tới, đồng đổi màu "đã đi".
    - `inject_action dev_f1`: tọa độ đúng từng ô.
    - Lưu ảnh `_bmad-output/implementation-artifacts/anh/1-8-*.png`.
  - [x] 7.2 `tools/chay.sh --dev --tran=thu_ba_tuong`, chụp: đủ 6 loại ô và ô ải; khối có mặt trước; Cung kỵ `5,2` che mặt trước kho `5,1`.
  - [x] 7.3 `tools/chay.sh --dev --tran=thu_lao`, gõ `2`, chụp: 3 viền trắng ở `3,1`, `6,3`, `3,6` như ảnh `anh/2-3-1-chon-lao-ba-vien.png`, nhưng trên bàn vuông. Thêm một ảnh viền mục tiêu của Khoái và viền chờ xác nhận (dày) nếu GoPeak còn chạy được.
  - [x] 7.4 Pixel tâm ô trên màn hình là `board.position + ((c + 0.5) * 64, (r + 0.5) * 64)`. Với hằng số gợi ý, `board.position = (262, 139)`, tức `(294 + 64c, 171 + 64r)`. **Đọc `board.position` thật** (từ test hoặc log tạm) trước khi bấm, đừng tin số này nếu đã đổi hằng số.
  - [x] 7.5 `tools/build_web.sh` đạt (dung lượng trong giới hạn). Ghi hướng dẫn mở bản web cho tác giả, giống 1.7. Không deploy.
- [x] **Task 8: Tài liệu, test, commit** (AC: 9)
  - [x] 8.1 `game-architecture.md` dòng 684 (quy ước ô ↔ điểm) đã viết theo 1.8. Sửa hai chỗ cho khớp code:
    - "khối đặt cao hơn tâm ô `TILE_H / 4`" → `TILE_SIZE / 4`;
    - "cạnh ô là bội số của 16 px (E8: 64 px)" → "cạnh ô `TILE_SIZE` = 64 px".
    - Thêm `cell_rect()` vào danh sách hàm đổi ô ↔ điểm.
    - Không sửa chỗ khác.
  - [x] 8.2 `deferred-work.md`, mục review 1.7 "Bệ ô ải vẽ trên mặt đất…": ghi thêm "vẫn còn trên bàn nhìn chếch (khối ở hàng trên che dải 8 px của bệ ô ải ngay dưới), Story 1.8". Mục "bàn lớn hơn 7×7 tràn dưới HUD" để Story 1.9 đánh dấu, story này không đụng.
  - [x] 8.3 `tools/test.sh` xanh. Commit một lần, lời commit tiếng Việt, ví dụ `Bàn cờ nhìn chếch, ô vuông 64 px (Story 1.8)`. Commit gồm cả ảnh chụp và `.uid` mới nếu có.
  - [x] 8.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes theo mẫu ở Dev Notes, dùng kết quả thật (số test thật, ảnh thật).

### Review Findings

- [x] [Review][Decision] Viền mục tiêu và trạng thái chờ xác nhận bị đồng quân che phần trên — Ảnh `1-8-7` và `1-8-9` cho thấy đồng quân che gần hết cạnh trên của viền; ba cạnh còn lại vẫn nhận ra được. Godot vẽ node con `_world` trên phần `_draw()` của `BoardView`, nên đây là hành vi ổn định tại `game/src/battle/board_view.gd:377`. Cần tác giả quyết định giữ cách thể hiện có chiều sâu hiện tại hay đưa chỉ báo lên trên quân để dễ đọc hơn. **Tác giả chọn (2026-10-20): vẽ viền lên trên quân.** Đã sửa: viền vẽ trên lớp `_target_layer`, con của `BoardView` nằm sau `_world` và trước overlay F1; thêm `test_target_outline_draws_above_tokens`; chụp lại ảnh `1-8-7`, `1-8-9`.

## Dev Notes

### Bối cảnh

- Đây chỉ là **đổi cách vẽ**. Luật, dữ liệu trận, kịch bản và tọa độ `cot,hang` giữ nguyên [sprint-change-proposal-2026-10-19-nhin-chech.md, mục 2]. Không có đợt duyệt kịch bản.
- Story 1.7 làm bàn isometric và đặt nền cho story này: `cell_center`/`cell_at`/`pick_cell`, lớp `_world` y-sort, `TerrainBlock`, đồng đứng, `board_rect`, bệ ô ải. Story này **giữ nguyên kiến trúc đó**, chỉ thay hình học từ thoi 2:1 sang ô vuông nhìn chếch.
- Story 2.1–2.3 đã vẽ thêm lên bàn (viền mục tiêu, viền chờ xác nhận, đồng xám "đã đánh", quân gục bị nhấc khỏi bàn). Mọi thứ đó phải hiện đúng trên bàn mới (AC 7, bảng "Story 1.4–2.3 vẽ gì lên bàn").
- **Story 1.9 làm ngay sau** (cỡ bàn theo file trận, 5×5 tới 10×8, canh giữa, thu theo bậc nguyên nếu cần). Story này **giữ 7×7, không làm cỡ bàn thay đổi**, nhưng không được làm 1.9 khó hơn (mục "Để Story 1.9 dễ làm").
- Ảnh mẫu không khí: `_bmad-output/planning-artifacts/art-reference/mau-01-doanh-trai-dong-bo-dau.png`. Ô vuông nhìn chếch; người đứng chân ở nửa dưới ô, đầu nhô lên ô phía trên. Không có mặt bên, chỉ thấy mặt trước của vật.

Hình học (ô 64 px, gốc local của `BoardView` là góc trên trái ô `0,0`):

```
 (0,0)──────┬──────┬───      cột tăng: sang phải
   │  0,0   │ 1,0  │         hàng tăng: xuống dưới
   ├────────┼──────┼───      tâm ô (c,r) = ((c+0.5)·64, (r+0.5)·64)
   │  0,1   │ 1,1  │         khối cao h: mặt trên nâng h, mặt trước là dải h ở cạnh dưới ô
   ...                       đồng quân: chân ở tâm ô, đồng tròn tâm ở (0, −20), bán kính 24
 ══════════════════════      mép bàn dày EDGE_DEPTH dưới hàng cuối
```

- Trận 1: sông là cột 3 (mọi ô `3,r` trừ `3,3`), thành một dải dọc có khe ở giữa. Khoái ở `0,6` (góc dưới trái), Lão ở `2,6`, địch ở `1,0`, `5,0`, `5,4`. Bố cục trên màn hình giờ **giống hệt** bàn cờ chữ trong file trận.

### Bàn có vừa không (1280×720, ô 64 px)

Vùng chơi `BoardView.AREA = Rect2(16, 52, 940, 612)`: x 16–956, y 52–664. Phía trên là tiêu đề (y 4–48), bên phải là HUD (x ≥ 972), phía dưới là nhãn phiên bản (y ≥ 672).

Số đo với hằng số gợi ý (`TILE_SIZE` 64, `EDGE_DEPTH` 12, `BORDER_WIDTH` 4, `BLOCK_HEIGHT` 16, `PASS_HEIGHT` 8, `RADIUS` 24, `TOKEN_LIFT` 20, `TOP_MARGIN` 4):

| | 7×7 (story này) | 10×8 (lớn nhất, Story 1.9) |
|---|---|---|
| Mặt bàn | 448 × 448 | 640 × 512 |
| Nhô lên trên | max(8 + 20 + 24 − 32, 16) + 4 = **24** | 24 |
| Dưới (mép bàn + nửa nét viền) | 12 + 2 = 14 | 14 |
| Khung `board_rect` | **452 × 486** | 644 × 550 |
| So với vùng chơi 940 × 612 | **vừa**, dư 488 × 126 | **vừa ở cỡ 1:1**, dư 296 × 62 |
| `board.position` (canh giữa, làm tròn) | **(262, 139)** | (do 1.9 tính) |
| Khung trên màn hình | x 260–712, y 115–601 | |

- **Kết luận:** bàn 7×7 với ô 64 px vừa gọn bên trái HUD, ở độ phân giải 1280×720 hiện có, **không cần đổi độ phân giải, không cần thu nhỏ**. Bàn 10×8 cũng vừa ở cỡ 1:1, miễn là phần nhô lên trên cộng phần dưới không quá 612 − 512 = 100 px. Story 1.9 vẫn phải làm nhánh "thu theo bậc nguyên" theo AC của nó, nhưng với số đo này nhánh đó sẽ không chạy ở 1280×720.
- Muốn chỉnh cỡ đồng, khối hay mép bàn thì giữ ngân sách đó. Test bố cục (6.1) chỉ kiểm 7×7; Story 1.9 thêm 10×8.
- Ô 64 px "hiện 1:1" nghĩa là 1:1 ở độ phân giải gốc 1280×720. Cửa sổ lớn hơn thì stretch `canvas_items` vẫn phóng cả màn hình như hiện nay. Lọc `Nearest` cho tranh là việc của E8; story này chưa có ảnh nên không đổi `project.godot`.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

**`game/src/battle/board_view.gd`** (456 dòng)
- Hiện tại:
  - Bàn thoi 2:1, `TILE_W = 128`, `TILE_H = 64`. Gốc local là đỉnh trên ô `0,0`.
  - Hàm static: `cell_center`, `diamond`, `top_center`, `surface_height`, `draw_raised` (thoi, hai mặt bên). Hàm thường: `cell_at` (phép ngược thoi), `pick_cell` (độ sâu `c + r`, `_silhouette` lục giác), `board_rect`, `_local_rect` (thoi), `_grid_point`.
  - `_draw`:
    1. tấm bàn và mép;
    2. sông, hầm chông;
    3. lưới, viền bàn;
    4. vòng lặp theo `depth = c + r`: bệ ô ải, ô sáng, viền mục tiêu, vòng chọn;
    5. đường đi.
  - Con: `_terrain_labels` (chữ ô phẳng), `_world` (`y_sort_enabled`: `TerrainBlock` và `UnitToken`). Overlay F1 do `main.gd` thêm cuối cùng.
  - `AREA`, `viewport_size`, `setup()` canh giữa và `round()`.
- Đổi: mọi hình học (Task 1, 2). Độ sâu từ `c + r` thành `r`.
- Giữ nguyên:
  - API: `show_state`, `show_selection(unit_cell, cells, targets)`, `show_path`, `show_pending`, `clear_selection`, `lit_cells()`, `target_cells()`, `pending_cell()`, `path()`, `tokens()`;
  - biến và hằng: `_selected_cell`, `_world`, `NO_CELL`, `cols`/`rows`, `viewport_size`, `AREA`, `TERRAIN_COLORS`, `TERRAIN_KEYS`, `LINE_COLOR`, `TERRAIN_FONT_SIZE`, `BLOCK_KINDS`, `BLOCK_HEIGHT`, `PASS_HEIGHT`, `REACH_COLOR`, `TARGET_COLOR`, `SELECT_COLOR`, `PATH_COLOR`;
  - hàm static: `top_center`, `surface_height`;
  - `_sync_tokens` (dựng lại đồng khi id đổi loại, F5), `_remove_token`;
  - `show_state(null)` xóa vòng chọn, viền mục tiêu và chờ xác nhận (deferred 1.4, test `test_target_outline_and_pending_are_cleared`).

**`game/src/battle/terrain_block.gd`** (40 dòng)
- Hiện tại: khối thoi, `position = cell_center - (0, TILE_H / 4)`, nhãn rộng `TILE_W / 2`, `draw_raised` với hai mặt bên `LEFT_SHADE`/`RIGHT_SHADE`.
- Đổi: Task 3.
- Giữ nguyên: `setup(cell, kind, height, text)`, `cell`, `kind` (test đọc).

**`game/src/battle/unit_token.gd`** (137 dòng)
- Hiện tại: `RADIUS 26`, `TOKEN_LIFT 22`, bóng `(24, 11)`, `HP_OFFSET (19, 17)`, `NAME_FONT_SIZE 16`. `position = cell_center - lift`. `hit()` là hình tròn tâm `(0, -TOKEN_LIFT)`.
- Đổi: cỡ (Task 4), chú thích.
- Giữ nguyên: mọi API và màu (Task 4.4).

**`game/src/debug/coord_overlay.gd`** (68 dòng)
- Hiện tại: nhãn tọa độ ở nửa trái ô thoi (`top_center - (TILE_W / 4, 0)`), nhãn id ở góc trên phải đồng, `MOUSE_FILTER_IGNORE`, `texts()` cho test.
- Đổi: chỗ đặt nhãn tọa độ (Task 5.1), bỏ `TILE_W`.
- Giữ nguyên: là con cuối của `BoardView`, `toggle()`, `texts()`, không nhận chuột.

**`game/src/battle/battle_input.gd`**: không sửa. `_pick` gọi `_board.pick_cell(make_input_local(...).position)`, `refresh_hover` (review 1.7) chọn lại ô khi đồng quân dời tới dưới chuột đứng yên.

**`game/src/app/main.gd`**: không sửa code. `_show_error` lấy khung từ `board_rect()`.

**`game/src/ui/hud.gd`**: chỉ sửa chú thích dòng 9.

### Ai đang dùng `TILE_W` / `TILE_H` / hình thoi (`grep -rn "TILE_W\|TILE_H\|diamond(" game/`)

| Chỗ | Việc |
|---|---|
| `src/battle/board_view.gd` | thay bằng `TILE_SIZE`, `cell_rect` |
| `src/battle/terrain_block.gd:9, 30, 39` | `TILE_SIZE`, `cell_rect` |
| `src/debug/coord_overlay.gd:27` | `TILE_SIZE` |
| `tests/test_board_view.gd:68, 118` | `_corners` theo ô vuông; bỏ kiểm "thoi rộng gấp đôi cao" |

Các chỗ gọi `cell_center`, `board_rect`, `pick_cell`, `TOKEN_LIFT`, `RADIUS` (`test_battle_view.gd:90, 224, 242, 394–395, 423, 520, 524`; `test_main.gd:153, 287–290, 309–310`) chỉ sửa khi có ghi trong Task 6.2.

### Test cũ dựa vào số đo của bàn nghiêng

- `test_resting_mouse_follows_token_moving_under_it` (`test_battle_view.gd:420`) lấy điểm `cell_center(1,5) + (0, -40)`:
  - Trên bàn vuông, điểm này rơi vào đất của ô `1,4`, không phải `0,4`.
  - Đổi sang `cell_center(0,5) + (0, -40)`: điểm này cách tâm ô `0,5` 40 px lên trên, trên đất của ô `0,4` (vì 40 > 32).
  - Khi Khoái (đang ở `0,6`) đi tới `0,5`, tâm đồng ở `(0, -20)` so với tâm ô, nên điểm cách tâm đồng 20 px ≤ `RADIUS` 24: chuột trúng đồng, ô dưới chuột thành `0,5`.
  - `Z` hủy thì về `0,4`, đường đi `[0,5, 0,4]` y như test cũ.
  - Khoái ở `0,6` lúc đầu không che điểm này (cách 104 px).
- `test_pick_head_of_token_selects_its_cell`: đầu đồng Lão rơi vào ô `2,5`, không còn là `1,5`.
- `test_token_on_pass_stands_on_platform`: đầu đồng trên bệ ô ải ở `0,6` rơi vào ô `0,5`, không còn ngoài bàn.

### Story 1.4–2.3 vẽ gì lên bàn (kiểm hết trên bàn mới)

| Thứ | Từ story | Vẽ ở đâu | Việc ở story này |
|---|---|---|---|
| Ô sáng (xanh lá) | 1.4 | `BoardView._draw`, mặt trên ô | `draw_rect` ô vuông |
| Vòng chọn (vàng, elip) | 1.4 | `_draw` | elip mới quanh chân |
| Đường đi + chấm cuối | 1.4 | `_draw` | giữ, nối `_top_center` |
| Đồng "đã đi" (đỏ xỉn) | 1.5 | `UnitToken` | giữ màu |
| Viền mục tiêu trắng | 2.1 | `_draw_target` | khung vuông thụt vào |
| Viền chờ xác nhận (dày gấp đôi) | 2.1 | `_draw_target` | giữ `PENDING_WIDTH` |
| Đồng "đã đánh" (xám, chữ xám đậm) | 2.1 | `UnitToken` | giữ màu |
| Số máu đổi, quân gục bị nhấc | 2.1–2.3 | `UnitToken`, `_sync_tokens` | giữ |
| Viền mục tiêu của Lão, cách 2–4 ô, qua sông | 2.3 | `_draw_target` | như trên; xem ảnh 7.3 |
| Dòng "Bấm lần nữa để đánh" | 2.1 | HUD | không đổi |

Ô đỏ báo đòn (2.7), xem trước (2.12), hoạt ảnh (2.11) chưa có. Chúng sẽ vẽ trên bàn mới qua `cell_center`/`cell_rect`.

### Để Story 1.9 dễ làm (bắt buộc)

- **Không thêm số 7 hay 49 cứng mới** (project-context: "Không lặp cứng cỡ bàn"). Code lặp theo `cols`/`rows`; test lặp theo `board.cols`/`board.rows` (`_all_cells(board)`). Các `range(7)` có sẵn ở `board_fixture.gd`, `test_rules_move.gd`, `test_scenario_loader.gd`, `test_rules_enemy_phase.gd`, `test_battle_controller.gd` để 1.9 sửa, story này không đụng.
- `var cols: int = 7`, `setup(new_cols = 7, new_rows = 7)` có sẵn: giữ nguyên, 1.9 xử lý.
- **Đổi ô ↔ điểm chỉ nằm trong `BoardView`** (`cell_center`, `cell_rect`, `cell_at`, `pick_cell`, `top_center`). `TerrainBlock`, `UnitToken`, `CoordOverlay` gọi các hàm đó, không tự nhân `TILE_SIZE` với tọa độ ô.
- `board_rect()` tính qua `transform` (Task 1.7). `BattleInput` đã dùng `make_input_local`, nên 1.9 thêm `scale` cho `BoardView` thì chuột, F1 (con của `BoardView`) và màn hình lỗi tự đúng.
- `_local_rect()` chỉ phụ thuộc `cols`, `rows` và hằng số.

### Luật kiến trúc phải theo

- Mọi đổi ô ↔ điểm chỉ ở `board_view.gd` [game-architecture.md dòng 684]. Hợp đồng: `cell_at(cell_center(c)) == c`, `pick_cell(cell_center(c)) == c`.
- Thứ tự vẽ theo `hang`, lớn hơn vẽ sau [dòng 684]. Khối và đồng là con của `_world` (`y_sort_enabled`). Ô sáng, đường đi, vòng chọn, sông, hầm chông, bệ ô ải vẽ trong `_draw` của `BoardView`, luôn dưới khối và quân.
- Vẽ bằng code (`_draw`, `draw_rect`, `draw_colored_polygon`, `draw_polyline`). Ô và quân sinh bằng code. Không TileMap, không `.tscn` mới, không ảnh [project-context "Luật riêng của Godot"; danh sách hình E8: ô sáng và ô đỏ luôn vẽ bằng code].
- `src/core/` cấm sửa (AC 11). `check_boundaries.sh` chạy trong `tools/test.sh`.
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). Không `float` trong luật (story này không có luật).
- Chữ hiển thị qua `tr()`. Story này không thêm chữ mới.
- Renderer Compatibility (WebGL 2): `draw_rect`, `draw_colored_polygon`, `draw_polyline` chạy tốt. Không dùng shader.
- Đi xuống thì gọi hàm, đi lên thì phát signal. Không đổi đường signal hiện có.

### Cỡ và màu (màu UI, không phải số cân bằng; để `const` trong file view)

- Hằng số gợi ý:
  - `TILE_SIZE = 64`, `EDGE_DEPTH = 12`, `BLOCK_HEIGHT = 16`, `PASS_HEIGHT = BLOCK_HEIGHT / 2`, `RIVER_DEPTH = 6`;
  - đồng `RADIUS = 24`, `TOKEN_LIFT = 20`;
  - `SELECT_RADIUS = (28, 18)`, `SHADOW_RADIUS = (22, 8)`.
- Màu địa hình, màu phe, `REACH_COLOR`, `TARGET_COLOR`, `SELECT_COLOR`, `PATH_COLOR` giữ nguyên.
- Mặt trước khối và mép bàn tối hơn bằng `Color.darkened()`.
- Chỉnh được sau khi chụp màn hình, miễn test bố cục và test bấm xanh, và ba ràng buộc ở Task 4.2 còn đúng.

### Testing

- Test chạy không cần màn hình qua `main.tscn` thật (`_make_main`, `_make_three_generals`, `_make_level_main` ghi trận thử vào `user://` rồi xóa ở `after_each`).
- Test bố cục so khung chữ nhật (`Rect2.encloses`, `intersects`, `has_point`), không so pixel ảnh.
  - `Rect2.has_point` **không tính** cạnh phải và cạnh dưới. Điểm đúng trên mép phải hay mép dưới bàn là "ngoài" khung mặt đất. `_local_rect` cộng nửa nét viền nên khung `board_rect` vẫn bao được (review 1.7 từng gặp).
- Không có test tự động cho "trông có đẹp không". AI tự chụp bằng GoPeak trước (Task 7), tác giả xem bằng mắt.
- Phá thử mỗi lần **một** chỗ, trả lại từ bản sao (Task 6.4).
- Hiện có 402 test (sau review 2.3). Ghi số thật vào Debug Log, Completion Notes, Change Log, và ba nơi phải khớp nhau (review 1.7, 2.2).

### Hướng dẫn tác giả tự test (mẫu; dev ghi lại bằng kết quả thật ở Completion Notes)

1. `tools/test.sh`: thấy `✅ … test đạt`.
2. `tools/chay.sh`:
   - Bàn ô vuông. Ô `0,0` ở góc trên trái, giống bàn cờ chữ trong file trận.
   - Khoái ở góc dưới trái, Lão cách Khoái 2 ô bên phải.
   - Sông là cột dọc ở giữa, có khe ở giữa, thấy bờ tối ở cạnh trên chỗ khe.
   - Quân là đồng tròn đứng, có bóng, có số máu.
3. Bấm Khoái (hoặc `1`): 7 ô xanh và vòng vàng dưới chân. Rê chuột lên ô xanh: thấy đường đi. Bấm ô đó: Khoái đi tới, đổi màu đỏ xỉn.
4. Bấm sát mép các ô: luôn chọn đúng ô dưới chuột. Bấm vào phần trên của đồng Lão (phần nhô lên ô phía trên): chọn Lão.
5. `Z`, nút Hủy, `Space`, nút Kết thúc lượt chạy như trước.
6. `tools/chay.sh --dev --tran=thu_ba_tuong`:
   - Rừng (xanh lá), Kho (vàng), Làng (nâu) là khối nổi, có mặt trước tối hơn.
   - Ô ải là bệ đá xám thấp, hầm chông có 3 mũi nhọn, sông trũng.
   - Cung kỵ (`C`) đứng dưới kho nên che mặt trước kho.
7. `tools/chay.sh --dev --tran=thu_lao`, gõ `2`: 3 viền trắng như ở Story 2.3. Bấm Bộ binh xa phía trên Lão: nó còn 2 máu, Lão xám.
8. Còn trong `--dev`: bấm F1 (trên Mac là Fn+F1), thấy tọa độ ở góc dưới trái mỗi ô, số id cạnh đầu mỗi quân. F5 (Fn+F5): trận nạp lại.
9. (Web) `python3 -m http.server 8060 -d build/web`, mở `http://localhost:8060` trong Chrome, xem có mượt không. Ctrl+C để tắt.

### Previous Story Intelligence (Story 1.7, 2.1–2.3 và code review)

- **1.7 (bàn nghiêng):**
  - Khối đặt ở đỉnh trên ô thì bằng y với quân ô bên cạnh, nên y-sort không chắc chắn. Phải đặt cao hơn tâm `TILE / 4` (Debug Log 1.7). Giữ cách này (Task 3.1).
  - `board_rect` hụt mép phải vì `Rect2` không tính mép cuối; đã cộng nửa nét viền. Giữ.
  - Bệ ô ải vẽ trên mặt đất trong `_draw`, không phải `TerrainBlock`, để ô sáng, viền và vòng chọn trên ô ải nằm trên mặt bệ.
  - Review 1.7 sửa 5 chỗ: ô sáng vẽ xen với bệ ô ải theo độ sâu; `refresh_hover` khi đồng dời tới dưới chuột; nhãn F1 `MOUSE_FILTER_IGNORE`; phần nhô lên của khung bàn tính từ hằng số; `top_center` static cho F1. Không được làm mất cái nào.
  - Review 1.7: ghi chép phải khớp (số test, test xóa hay sửa, lệch so với Task). Task chụp ảnh thì phải có file ảnh.
- **2.1–2.3:**
  - Viền mục tiêu dùng chung `_draw_target` cho mọi tướng. Lão có mục tiêu cách 2–4 ô, nên viền nằm xa đồng quân, kể cả bên kia sông.
  - Test giao diện bấm bằng sự kiện thật qua `BattleInput` (`_click_by_mouse`), nên đổi hình học sai thì các test này trượt hàng loạt. Đó là lưới an toàn: chúng phải xanh mà không sửa.
- **GoPeak** (Debug Log 2.3):
  - `inject_action` phải gửi cả bấm (`pressed` true) lẫn nhả (false).
  - Ảnh chụp trễ một nhịp, nên chụp hai lần.
  - Sau vài giây thao tác có thể ngừng có tác dụng: tắt game, chạy lại.
  - `inject_mouse_click` nhận pixel cửa sổ 1280×720.
- **Sự cố 2.3:** phá thử bằng `git checkout -q game/src` đã xóa code chưa commit. Lưu bản sao file trước khi phá thử (Task 6.4).
- **Mac:** F1/F5 là Fn+F1/Fn+F5 (deferred 1.6).

### Git Intelligence

- Commit gần nhất:
  - `63dcc47` bản nháp hình Phạm Ngũ Lão (`img/`, chưa vào game);
  - `f6e425b` cỡ bàn theo trận, ô E8 64 px (tài liệu);
  - `1195efb` review 2.3;
  - `32e2229` danh sách hình E8;
  - `aeae68d` Story 2.3.
- Không commit nào sau 1.7 đụng `board_view.gd`, `terrain_block.gd`, `unit_token.gd`, `coord_overlay.gd`, trừ phần viền mục tiêu của 2.1 (`_draw_target`, `show_pending`).
- Mẫu lời commit: tiếng Việt, kết bằng `(Story 1.8)`, có dòng `Co-Authored-By`.
- Kiểm `git status` trước khi bắt đầu; đừng gộp file không thuộc story (ví dụ `img/`, `NEXT-STEPS.md`).

### Project Context Rules

- Godot **4.7.2**, GDScript, GUT 9.7.1, renderer Compatibility, 1280×720, stretch `canvas_items`, aspect `keep`. Không tự nâng phiên bản.
- **Context7** (MCP đã cài ở Story 0.6): tra API Godot 4.7 trước khi dùng API lạ, ví dụ `draw_rect` (tham số `filled`, `width`), `Transform2D * Rect2`, `Rect2.has_point`/`grow`, `CanvasItem.y_sort_enabled`. **GoPeak** 2.3.8 để chạy game, bơm input, chụp màn hình.
- Bàn tối đa 10×8 nên hiệu năng không phải vấn đề. Dựng lại chữ và khối mỗi lần `show_state` là được, không cache, không object pool.
- Không lặp cứng cỡ bàn (`range(7)`, `49`) trong code và test mới.
- Mọi thao tác làm được bằng một cú bấm chuột. Phím tắt qua InputMap (không đổi).
- Xong một việc nghĩa là `tools/test.sh` xanh rồi commit. Không `push --force`.
- Nói với tác giả bằng tiếng Việt, theo bước thử.
- Luật chưa có trong tài liệu thì hỏi tác giả (story này không có luật mới).

### Quyết định mặc định đã chọn (tác giả có thể đổi)

1. **Cạnh ô 64 px, hiện 1:1**, bàn 7×7 không thu nhỏ (proposal 2026-10-20 mục 5.4: "Khi làm 1.8, có thể đặt sẵn cạnh ô 64 px cho khớp E8").
2. **Chân đồng quân ở tâm ô**; đồng nhô 12 px lên ô phía trên. Giữ hợp đồng `token.position == cell_center` cho test và hoạt ảnh E2. Tranh E8 (khung 64×64) sẽ tự dời hình trong `UnitToken._draw`, không đổi `position`.
3. **Sông liền:** hai ô sông chồng dọc thì không có dải bờ giữa chúng; bờ chỉ hiện ở cạnh trên của đoạn sông.
4. **Bấm chuột chọn thứ nhìn thấy trên cùng**, như 1.7.
5. **F1:** tọa độ ở góc dưới trái ô; có thể đè một phần chữ "sông"/"chông" (F1 chỉ dùng khi dev), nhưng không đè tên quân.
6. **Khối ở hàng trên vẫn che dải 8 px của bệ ô ải ngay dưới** (mục hoãn 1.7, tác giả đã chọn giữ). Chưa trận nào có ô ải ngay dưới khối.

### References

- `_bmad-output/planning-artifacts/epics.md`: Story 1.8 (tiêu chí nghiệm thu), Story 1.9 (làm ngay sau), Story 1.7, FR3, danh sách cắt (dòng 184).
- `_bmad-output/planning-artifacts/sprint-change-proposal-2026-10-19-nhin-chech.md`: mục 2 (file phải sửa, thứ tự làm, "kiểm lại mọi thứ 2.1–2.3 vẽ").
- `_bmad-output/planning-artifacts/sprint-change-proposal-2026-10-20-co-ban.md`: mục 2 (Hiển thị: ô 64 px, canh giữa, bậc nguyên), mục 4.2 (kiến trúc), mục 5 (thứ tự 1.8 → 1.9 → 2.4).
- `_bmad-output/planning-artifacts/game-architecture.md`: dòng 105 và 251 (1280×720, `canvas_items`), dòng 580 (`board_view.gd`), dòng 684 (quy ước ô ↔ điểm, thứ tự vẽ).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md`: Art Style, mục "Góc nhìn" (dòng 339). `decision-log.md`: dòng 71–74.
- `_bmad-output/planning-artifacts/art-reference/README.md`, `danh-sach-hinh-e8.md` (ô 64×64; ô sáng và ô đỏ vẽ bằng code; ô ải là bệ đá thấp; sông thấy bờ ở cạnh trên), `mau-01-doanh-trai-dong-bo-dau.png`.
- `_bmad-output/project-context.md` (luật Godot, hiệu năng, không lặp cứng cỡ bàn, test).
- `_bmad-output/implementation-artifacts/1-7-ban-co-nghieng-isometric-tam.md` (Dev Notes, Debug Log, Review Findings), `2-3-pham-ngu-lao-phong-lao.md` (Debug Log GoPeak, sự cố phá thử), `deferred-work.md` (mục review 1.7).
- `game/data/tran/tran_01.json`, `thu_ba_tuong.json`, `thu_lao.json` (bố cục dùng để kiểm bằng mắt).

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5[1m])

### Debug Log References

- Máy chưa có Godot: chạy `tools/cai_dat.sh` (Godot 4.7.2, export template, butler). Bước cài công cụ AI báo thiếu Node.js ≥ 20.18.1 (máy có 18.20.8), nên GoPeak không chạy được.
- **Đỏ trước (Task 6):** viết test mới, lưu bản sao `game/src` vào scratchpad, tạm trả 4 file view về bản HEAD bằng `git show HEAD:<file> > <file>` (không dùng `git checkout`), chạy `tools/test.sh`:
  - `test_board_view.gd` lỗi parse (`cell_rect()`, `TILE_SIZE` chưa có), GUT bỏ cả file (22/23 file chạy);
  - `test_resting_mouse_follows_token_moving_under_it` trượt (`(-1,-1)`, mong `0,4`).
  - Trả code mới từ bản sao, `tools/test.sh`: 405/405 đạt.
- **Phá thử (Task 6.4)**, mỗi lần một chỗ, trả lại từ bản sao, `diff -r` với bản sao sau mỗi lần (đều khớp):
  - `cell_at` dùng `int()` → `test_points_outside_board_are_off_board`, `test_pick_outside_board_is_no_cell` trượt;
  - tắt `_world.y_sort_enabled` → `test_blocks_and_tokens_sort_by_depth` trượt;
  - `BattleInput` gọi `cell_at` thay `pick_cell` → `test_mouse_click_on_token_head_selects_that_general`, `test_resting_mouse_follows_token_moving_under_it` trượt;
  - bỏ nâng quân trên ô ải (`lift = 0.0`) → `test_token_on_pass_stands_on_platform` trượt;
  - `TILE_SIZE = 60` → `test_tile_is_64_px_multiple_of_16` trượt.
- **Kiểm bằng mắt (Task 7), lệch so với Task:** không có GoPeak (thiếu Node 20), nên dùng script tạm trong scratchpad (không vào repo): `godot --path game --script chup.gd -- --dev [--tran=...]`. Script mở `main.tscn` có cửa sổ, gửi input thật qua `root.push_input` (`InputEventAction` bấm và nhả, chuột rê và bấm tại `get_global_transform_with_canvas() * cell_center(ô)`), rồi lưu `root.get_texture().get_image()`. Đường input giống `inject_action`/`inject_mouse_click`.
  - `board.position` thật = `(262, 139)`, `board_rect` = `(260, 115) 452×486`, khớp Dev Notes.
- Sau ảnh đầu, chữ "Khoái" chạm sát mép đồng 48 px, nên giảm `NAME_FONT_SIZE` từ 16 xuống 15 (Task 4.3 cho phép). `HP_OFFSET` giữ `(19, 17)`: chấm máu vẫn nằm trong ô.
- `tools/build_web.sh`: bản nén 10,4 MB (giới hạn 25 MB).

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- `BoardView`:
  - một hằng `TILE_SIZE = 64`; `cell_center` và `cell_rect` (static) thay cho phép tính thoi và `diamond()`;
  - `cell_at` dùng `floori`;
  - `pick_cell` lấy độ sâu theo `hang`, hình chạm của khối là `Rect2` (mặt trên nâng lên và mặt trước);
  - `_local_rect` theo bàn vuông; `board_rect = transform * _local_rect()`;
  - `draw_raised(canvas, ground: Rect2, height, color, front_shade)` chỉ có mặt trên và mặt trước;
  - sông có bờ ở cạnh trên, liền mạch khi ô trên cũng là sông; hầm chông 3 mũi nhọn ở nửa trên ô;
  - vòng vẽ bệ ô ải, ô sáng, viền, vòng chọn chạy từng hàng từ trên xuống;
  - viền mục tiêu là khung vuông `grow(-5)`.
- `TerrainBlock`: đặt cao hơn tâm ô `TILE_SIZE / 4`, một `FRONT_SHADE`. `UnitToken`: `RADIUS 24`, `TOKEN_LIFT 20`, bóng `(22, 8)`, chữ 15. `CoordOverlay`: tọa độ ở góc dưới trái ô. Chỉ sửa chú thích ở `hud.gd`, `main.gd`; `BattleInput` không đổi.
- Test: `test_board_view.gd` sửa tại chỗ (đổi tên 2 test, không xóa test nào) và thêm 3 test (`test_tile_is_64_px_multiple_of_16`, `test_board_sits_on_whole_pixels`, `test_token_and_block_never_cover_a_neighbour_center`). `test_battle_view.gd`: chỉ đổi ô `1,5` → `0,5` trong `test_resting_mouse_follows_token_moving_under_it`. `test_main.gd` và các test bấm chuột khác xanh mà không sửa. Số test 402 → **405**, đạt hết.
- AC 11: `git diff --stat` không có file nào trong `game/src/core/`, `game/data/`, `game/tests/kich_ban/`.
- Ảnh chụp: `anh/1-8-1-tran-1.png`, `1-8-2-chon-khoai.png` (7 ô sáng, vòng chọn, đường đi), `1-8-3-khoai-da-di.png`, `1-8-4-f1.png`, `1-8-5-ba-tuong.png`, `1-8-6-ba-tuong-chon-khoai.png`, `1-8-7-lao-ba-vien.png`, `1-8-8-lao-danh.png` (Bộ binh `3,1` còn 2 máu, Lão xám), `1-8-9-khoai-cho-xac-nhan.png` (viền dày và "Bấm lần nữa để đánh").
- Viền mục tiêu trước đây bị đồng quân che cạnh trên. Review 1.8: tác giả chọn vẽ viền lên trên quân. `BoardView` có thêm con `_target_layer` (sau `_world`, trước overlay F1), vẽ viền qua signal `draw`; mọi chỗ vẽ lại gọi `_redraw()` để vẽ lại cả lớp này. Viền giờ thấy đủ 4 cạnh, cạnh trên đè lên mép đồng quân (ảnh 1-8-7, 1-8-9 chụp lại). Thêm `test_target_outline_draws_above_tokens` (đỏ trước khi sửa, lỗi thiếu `_target_layer`). Số test 405 → **406**, đạt hết.

**Hướng dẫn tác giả tự test**

1. `tools/test.sh`: thấy `✅ 406/406 test đạt`.
2. `tools/chay.sh` (so với ảnh `anh/1-8-1-tran-1.png`):
   - bàn ô vuông, ô `0,0` ở góc trên trái, giống bàn cờ chữ trong file trận;
   - Khoái ở góc dưới trái, Lão cách Khoái 2 ô bên phải;
   - sông là cột dọc ở giữa, có khe ở hàng 3, thấy dải bờ tối ở cạnh trên ô sông ngay dưới khe và ở hàng 0;
   - quân là đồng tròn đứng, có bóng, có số máu.
3. Bấm Khoái (hoặc `1`): 7 ô xanh, vòng vàng dưới chân. Rê chuột lên ô xanh thấy đường đi. Bấm ô đó: Khoái đi tới, đổi đỏ xỉn.
4. Bấm sát mép các ô: luôn chọn đúng ô dưới chuột. Bấm vào phần trên của đồng Lão (phần nhô lên ô phía trên): chọn Lão.
5. `Z`, nút Hủy, `Space`, nút Kết thúc lượt chạy như trước.
6. `tools/chay.sh --dev --tran=thu_ba_tuong` (ảnh `1-8-5`):
   - Rừng (xanh lá), Kho (vàng), Làng (nâu) là khối nổi, có dải mặt trước tối hơn;
   - Ải là bệ đá xám thấp, Chông có 3 mũi nhọn, sông trũng;
   - Cung kỵ (`C`) đứng ngay dưới Kho, che mặt trước Kho.
7. `tools/chay.sh --dev --tran=thu_lao`, gõ `2`: 3 viền trắng đủ 4 cạnh, nằm trên đồng quân địch, ở trên, phải và dưới Lão (ảnh `1-8-7`). Bấm Bộ binh xa phía trên Lão: nó còn 2 máu, Lão xám (ảnh `1-8-8`).
8. Còn trong `--dev`: bấm F1 (Mac: Fn+F1), thấy tọa độ ở góc dưới trái mỗi ô, số id cạnh đầu mỗi quân (ảnh `1-8-4`). F5 (Fn+F5): trận nạp lại.
9. (Web) `python3 -m http.server 8060 -d build/web`, mở `http://localhost:8060` trong Chrome, xem có mượt không. Ctrl+C để tắt. Bản build đã có sẵn trong `build/web/`.

### File List

- `game/src/battle/board_view.gd` (sửa)
- `game/src/battle/terrain_block.gd` (sửa)
- `game/src/battle/unit_token.gd` (sửa)
- `game/src/debug/coord_overlay.gd` (sửa)
- `game/src/app/main.gd` (sửa chú thích)
- `game/src/ui/hud.gd` (sửa chú thích)
- `game/tests/test_board_view.gd` (sửa)
- `game/tests/test_battle_view.gd` (sửa)
- `_bmad-output/planning-artifacts/game-architecture.md` (sửa)
- `_bmad-output/implementation-artifacts/deferred-work.md` (sửa)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa)
- `_bmad-output/implementation-artifacts/1-8-ban-co-nhin-chech-o-vuong.md` (sửa)
- `_bmad-output/implementation-artifacts/anh/1-8-1-tran-1.png` … `1-8-9-khoai-cho-xac-nhan.png` (mới, 9 ảnh)

### Change Log

- 2026-10-20: Tạo story. Cạnh ô 64 px theo proposal 2026-10-20; bàn 7×7 vừa ở 1:1 trong 1280×720 (khung 452×486 trong vùng 940×612).
- 2026-10-20: Làm story. Bàn ô vuông 64 px nhìn chếch thay bàn isometric; khối chỉ còn mặt trước; độ sâu theo `hang`; đồng quân nhỏ lại (24/20). Test 402 → 405, đạt hết. Kiểm bằng mắt bằng script chụp tạm (không có GoPeak), 9 ảnh. Bản web 10,4 MB. Chuyển sang review.
- 2026-10-20: Sửa theo code review: viền mục tiêu và viền chờ xác nhận vẽ trên đồng quân (tác giả chọn). Test 405 → 406, đạt hết. Xong story.
