---
baseline_commit: f927e1d2b778a953038cfc05beed451b512eda7f
---

# Story 1.7: Bàn cờ nghiêng (isometric) tạm

Status: done

## Story

Là tác giả,
tôi muốn bàn cờ trông có chiều sâu,
để game bớt phẳng ngay trong prototype, trước khi có tranh ở E8.

_Thêm 2026-10-18 theo `sprint-change-proposal-2026-10-18-isometric.md`. Cắt được nếu E1 trễ._

## Acceptance Criteria

1. **Bàn thoi.** **Cho** trận 1 đang mở (`tools/chay.sh`), **thì** bàn 7×7 hiện thành một hình thoi lớn, mỗi ô là một hình thoi rộng gấp đôi cao (2:1). Ô `0,0` ở đỉnh trên cùng; cột tăng thì xuống bên phải, hàng tăng thì xuống bên trái. Bàn nằm gọn trong cửa sổ 1280×720, không đè lên tiêu đề, bảng HUD bên phải và nhãn phiên bản.
2. **Địa hình.** Sông thấp hơn mặt đất. Rừng, kho lương, làng, ô ải là khối nhô lên, có mặt bên tối hơn mặt trên. Hầm chông phẳng, có ký hiệu. Mỗi loại ô vẫn phân biệt được bằng màu hoặc chữ ngắn như hiện nay. Thử bằng `tools/chay.sh --dev --tran=thu_ba_tuong`, trận này có đủ sông, rừng, hầm chông, kho lương, làng, ô ải.
3. **Quân.** Mỗi quân là đồng tròn khắc chữ **đứng** trên ô, có bóng dưới chân, vẫn hiện số máu. Tướng đã đi vẫn đổi màu đỏ xỉn như Story 1.5.
4. **Che khuất.** Quân hoặc khối ở gần người xem (tổng `cot + hang` lớn hơn) che lên vật ở phía sau, không bị ngược. Ví dụ trên `thu_ba_tuong`: khối rừng ở `1,1` che một phần thứ ở `0,0`, `1,0`, `0,1` nếu chồng lên nhau, không bao giờ ngược lại.
5. **Bấm đúng ô.** **Khi** bấm vào bất kỳ ô nào, kể cả sát mép hình thoi, **thì** game chọn đúng ô đó (thử cả 49 ô). Bấm ngoài hình thoi lớn thì như bấm ra ngoài bàn (bỏ chọn).
6. **Thao tác cũ vẫn đúng.** **Khi** chọn tướng (chuột hoặc phím `1` `2` `3`) và rê chuột lên ô sáng, **thì** ô sáng, vòng chọn và đường đi hiện đúng trên bàn nghiêng như Story 1.4. Đi, hủy (`Z`, nút Hủy), kết thúc lượt (`Space`, nút) như Story 1.5. F5 như Story 1.6.
7. **F1.** **Khi** bật dev và bấm F1, **thì** tọa độ `cot,hang` hiện trên từng ô thoi, id quân hiện cạnh đồng quân của nó.
8. **Test.** `tools/test.sh` xanh. Có test cho phép đổi ô ↔ điểm: đi rồi về đúng ô (cả 49 ô), điểm sát mép (bên trong mỗi đỉnh của ô thoi) rơi đúng ô, điểm ngoài hình thoi lớn là ngoài bàn. Các test cũ đang dựa vào ô vuông được sửa theo bàn nghiêng, không xóa.
9. **Web.** Bản web chạy mượt như trước (`tools/build_web.sh` đạt, dung lượng trong giới hạn; tác giả mở thử bàn nghiêng trên trình duyệt).
10. **Không đụng luật.** Không sửa gì trong `game/src/core/`, `game/data/` và `game/tests/kich_ban/`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt ô ải** (2026-10-18): phương án (a), xem "Quyết định của tác giả".
- [x] **Task 1: Phép đổi ô ↔ điểm trong `BoardView`** (AC: 1, 5, 8)
  - [x] 1.1 Thay `CELL_SIZE` bằng `TILE_W = 128`, `TILE_H = 64` (2:1). Giữ một nơi khai báo; mọi chỗ khác đọc từ đây (xem bảng "Ai đang dùng `CELL_SIZE`" bên dưới).
  - [x] 1.2 `static func cell_center(cell)`: gốc tọa độ local của `BoardView` là **đỉnh trên của ô `0,0`**. `x = (cot - hang) * TILE_W / 2`, `y = (cot + hang) * TILE_H / 2 + TILE_H / 2`. Vẫn là hàm `static`, không phụ thuộc kích thước bàn (đồng quân và test đang gọi `BoardView.cell_center` kiểu static).
  - [x] 1.3 `func cell_at(local_pos)`: phép ngược trên **mặt đất**. `a = x / TILE_W + y / TILE_H`, `b = y / TILE_H - x / TILE_W`, `cell = Vector2i(floori(a), floori(b))`. Ngoài `[0, cols) × [0, rows)` thì `NO_CELL`. Giữ đúng hợp đồng kiến trúc `cell_at(cell_center(c)) == c`.
  - [x] 1.4 `func board_rect() -> Rect2`: khung chữ nhật bao trọn mọi thứ bàn vẽ ra (hình thoi lớn, độ dày mép bàn, phần khối và đồng quân nhô lên ở hàng trên cùng), tính trong tọa độ của cha (`main`). Dùng cho canh giữa, cho màn hình lỗi, cho test bố cục.
  - [x] 1.5 `setup(cols, rows)`: đặt `position` (đỉnh trên của ô `0,0` trên màn hình) sao cho `board_rect()` nằm giữa vùng trống bên trái HUD: x trong `[16, 956]`, y trong `[52, 664]` (dưới tiêu đề, trên nhãn phiên bản). Bàn 7×7 với 128×64: hình thoi rộng 896, cao 448, còn dư chỗ.
  - [x] 1.6 `func pick_cell(local_pos) -> Vector2i`: ô mà người chơi **nhìn thấy** dưới chuột. Xét từ gần người xem ra xa (`cot + hang` giảm dần): trúng đồng quân (hình tròn đứng) hoặc trúng khối nhô lên (mặt trên và hai mặt bên) thì trả ô đó; không trúng gì thì trả `cell_at(local_pos)`. Lý do: đồng quân đứng và khối nhô lên chồng lên ô phía sau. Bấm vào đầu đồng quân mà lại chọn ô sau lưng nó thì sai với Story 1.4 ("bấm vào tướng mình luôn là chọn").
- [x] **Task 2: Vẽ mặt đất trong `BoardView._draw`** (AC: 1, 2, 6)
  - [x] 2.1 Mỗi ô là đa giác thoi 4 đỉnh quanh `cell_center` (`draw_colored_polygon`). Đất trống màu `CELL_COLOR`, hầm chông màu hiện có kèm ký hiệu vẽ bằng code (ví dụ 3 tam giác nhọn nhỏ), đường kẻ ô `LINE_COLOR`, viền hình thoi lớn `BORDER_WIDTH`.
  - [x] 2.2 Mép bàn có độ dày: hai mặt trước (cạnh dưới trái, cạnh dưới phải của hình thoi lớn) vẽ thêm một dải tối hơn cao khoảng 12px. Cho bàn cảm giác là một tấm.
  - [x] 2.3 Sông thấp hơn mặt đất: vẽ ô sông thành lòng trũng (mặt nước hạ xuống khoảng 6px, hai thành phía sau tối hơn lộ ra). Màu nước giữ `TERRAIN_COLORS[RIVER]`.
  - [x] 2.4 Ô sáng (`REACH_COLOR`) tô lên mặt thoi của ô. Vòng chọn thành **hình elip 2:1** trên mặt đất quanh chân đồng quân (tính các điểm rồi `draw_polyline`; `draw_circle` không méo được). Đường đi nối các `cell_center` như cũ.
  - [x] 2.5 Chữ ngắn của sông và hầm chông (`TERRAIN_KEYS`) đặt ở nửa dưới ô thoi, không bị đồng quân che hết. Chữ của khối nằm trên mặt trên khối (Task 3).
- [x] **Task 3: Lớp vật đứng: khối địa hình và đồng quân, sắp theo chiều sâu** (AC: 2, 3, 4)
  - [x] 3.1 Trong `BoardView`, thay `_units` bằng một `Node2D` `_world` có `y_sort_enabled = true`. Khối địa hình và đồng quân đều là con của `_world`. Thứ tự con của `BoardView` sau Story 1.7: chữ địa hình phẳng, `_world`, overlay F1 (do `main.gd` thêm cuối cùng).
  - [x] 3.2 File mới `game/src/battle/terrain_block.gd` (`class_name TerrainBlock extends Node2D`): vẽ một khối thoi nhô lên, mặt trên màu `TERRAIN_COLORS[kind]`, hai mặt bên tối hơn (ví dụ `darkened(0.25)` và `darkened(0.4)`), kèm chữ ngắn trên mặt trên. Chiều cao khối `BLOCK_HEIGHT = 16`.
  - [x] 3.3 Rừng, kho lương, làng: khối cao `BLOCK_HEIGHT`. **Ô ải** (tác giả chốt 2026-10-18): bệ đá thấp `PASS_HEIGHT = BLOCK_HEIGHT / 2`; quân đứng trên ô ải được nâng lên `PASS_HEIGHT` (BoardView đặt lại `position` của đồng sau `update`, hoặc truyền độ nâng vào đồng; `pick_cell` tính theo vị trí đã nâng).
  - [x] 3.4 **Thứ tự che khuất bằng y-sort:** đặt `position` của khối ở **đỉnh trên** ô thoi của nó (`cell_center - (0, TILE_H / 2)`), còn đồng quân ở `cell_center` (chân đồng). Như vậy y của khối ô `(c, r)` là `(c + r) * TILE_H / 2`, y của quân là `(c + r) * TILE_H / 2 + TILE_H / 2`: quân ở ô phía sau luôn vẽ trước khối, quân đứng trên chính ô đó (ô ải) vẽ sau khối, và không phụ thuộc thứ tự thêm node. Tự vẽ hình khối lệch xuống trong `_draw` của khối cho đúng chỗ.
  - [x] 3.5 `_rebuild_terrain_labels()` đổi thành dựng lại cả chữ phẳng lẫn khối (tên mới, ví dụ `_rebuild_terrain()`), gọi ở `show_state` như cũ. Bàn trống (`state == null`) thì không có khối nào.
- [x] **Task 4: Đồng quân đứng** (AC: 3)
  - [x] 4.1 `UnitToken`: `position` vẫn là `BoardView.cell_center(unit.cell)` (chân đồng). Trong `_draw`: bóng là elip mờ trên mặt đất tại `(0, 0)`, đồng tròn vẽ nâng lên `TOKEN_LIFT` (tâm đồng ở `(0, -TOKEN_LIFT)`). Nhãn tên và chấm máu dời lên theo.
  - [x] 4.2 Cỡ gợi ý: `RADIUS = 26`, `TOKEN_LIFT = 22`. Ràng buộc bắt buộc (có test ở Task 7): bấm vào `cell_center` của **mọi** ô, kể cả khi ô trước và sau đều có quân, vẫn ra đúng ô đó. Với 128×64 thì đồng không với tới tâm ô hàng xóm (khoảng cách gần nhất ≥ 32px theo chiều dọc, 64px theo chiều ngang).
  - [x] 4.3 Màu phe, màu "đã đi", chữ tên, số máu giữ nguyên ý nghĩa; `hp_text()`, `name_text()`, `is_moved()` giữ nguyên cho test.
- [x] **Task 5: Input và F1 theo bàn nghiêng** (AC: 5, 6, 7)
  - [x] 5.1 `BattleInput._unhandled_input`: đổi `_board.cell_at(...)` thành `_board.pick_cell(...)` cho cả bấm và rê chuột. Phần còn lại giữ nguyên (lấy vị trí từ sự kiện, `make_input_local`).
  - [x] 5.2 `CoordOverlay.show_state`: nhãn `cot,hang` canh giữa ở nửa trên ô thoi (quanh `cell_center - (0, TILE_H / 4)`), nhãn id quân đặt cạnh đồng quân (ví dụ góc trên phải của đồng đứng). Chỉ gọi `BoardView.cell_center`, không tự tính hình học [kiến trúc: "View khác gọi hai hàm này, không tự tính"]. Overlay vẫn là con cuối của `BoardView`, nằm trên mọi thứ.
- [x] **Task 6: `main.gd` và HUD** (AC: 1)
  - [x] 6.1 `_show_error`: màn hình lỗi lấy khung từ `_board_view.board_rect()` thay cho `position` + `cols * CELL_SIZE`.
  - [x] 6.2 `Hud.PANEL_POSITION` giữ `(972, 52)` nếu bàn không đè lên; sửa chú thích "bàn chiếm x 332–948" theo khung mới.
- [x] **Task 7: Test** (AC: 8; theo mẫu `test_battle_view.gd`, `test_main.gd`)
  - [x] 7.1 Sửa `test_cell_at_maps_board_pixels` thành bộ test bàn nghiêng:
    - đi rồi về: cả 49 ô, `cell_at(cell_center(c)) == c`;
    - sát mép: với mỗi ô, 4 điểm cách mỗi đỉnh thoi 2px vào phía tâm đều ra đúng ô;
    - ngoài bàn: điểm cách đỉnh trên của ô `0,0` 2px lên trên, điểm ngoài đỉnh trái, phải, dưới của hình thoi lớn đều là `NO_CELL`;
    - hướng: `cell_center(1,0)` ở dưới bên phải `cell_center(0,0)`, `cell_center(0,1)` ở dưới bên trái.
  - [x] 7.2 Test `pick_cell`: trên trận 1 có quân, `pick_cell(cell_center(c)) == c` cho cả 49 ô; điểm trên đầu đồng quân Khoái (`0,6`), nằm trong vùng đất của ô sau lưng, vẫn ra `0,6`. Trên `thu_ba_tuong`: điểm ở mặt trên khối rừng `1,1` (phần nhô vào ô sau) ra `1,1`.
  - [x] 7.3 Test che khuất: trong `_world`, `y_sort_enabled` bật; với khối rừng `1,1` và quân ở `1,0` (trận `thu_ba_tuong`: Bộ binh ở `1,0`), y của quân nhỏ hơn y của khối (vẽ trước). Quân đứng trên ô ải (nếu tác giả chốt quân đứng được trên khối ải) có y lớn hơn khối đó.
  - [x] 7.4 Sửa `test_coord_overlay_follows_moved_unit` (`test_battle_view.gd` dòng ~379): nhãn id 1 nằm quanh đồng ở ô mới (so với `cell_center(KHOAI_TARGET)`), không còn so với gốc ô vuông.
  - [x] 7.5 Test bố cục: `board_rect()` của trận 1 nằm trong `[16, 956] × [52, 664]`; không giao với khung tiêu đề, khung HUD (`Hud.PANEL_POSITION`, `PANEL_WIDTH`), khung nhãn phiên bản. Sửa `test_title_label_sits_above_board` dùng `board_rect()`.
  - [x] 7.6 Test màn hình lỗi: khung `ErrorScreen` bằng `board_rect()`.
  - [x] 7.7 Các test đang bấm qua `get_global_transform_with_canvas() * BoardView.cell_center(cell)` (`_hover_by_mouse`, test bấm chuột thật) phải xanh mà không sửa; nếu trượt là `pick_cell` sai.
  - [x] 7.8 "Làm hỏng tạm" để chứng minh test bắt được lỗi (như Story 1.5, 1.6): đảo dấu trong `cell_at` → 7.1 trượt; tắt `y_sort_enabled` hoặc đặt khối ở `cell_center` → 7.3 trượt; `BattleInput` quay về `cell_at` → 7.2 trượt. Ghi vào Debug Log.
  - [x] 7.9 `git diff --stat` không có file nào trong `game/src/core/`, `game/data/`, `game/tests/kich_ban/` (AC 10).
- [x] **Task 8: Nhìn bằng mắt (GoPeak) và bản web** (AC: 1–7, 9)
  - [x] 8.1 `tools/chay.sh --dev` chạy nền, chờ ~5 giây, `capture_screenshot`: bàn thoi, quân đứng, không đè tiêu đề và HUD. Bấm `1`, chụp: ô sáng và vòng chọn elip đúng chỗ. `inject_mouse_click` vào tâm vài ô sáng (tính từ `cell_center` + `position` của bàn), chụp: quân đi đúng ô. F1 (`inject_action dev_f1`), chụp: tọa độ đúng ô thoi.
  - [x] 8.2 `tools/chay.sh --dev --tran=thu_ba_tuong`, chụp: đủ 6 loại ô + ô ải, khối che đúng chiều.
  - [x] 8.3 `tools/build_web.sh` đạt (dung lượng trong giới hạn). Ghi vào hướng dẫn cho tác giả cách mở bản web để tự xem độ mượt (giống Task 5 Story 1.6). Không deploy.
- [x] **Task 9: Tài liệu, test, commit** (AC: 8)
  - [x] 9.1 `game-architecture.md` đã có quy ước ô ↔ điểm và thứ tự vẽ (dòng 573, 676). Bổ sung: `pick_cell` cho chuột (ô nhìn thấy), `cell_at` cho mặt đất; y-sort trong `_world`, khối đặt ở đỉnh trên ô.
  - [x] 9.2 `deferred-work.md` dòng 4 (chưa có test canh giữa `BoardView.setup`): đánh dấu đã làm bằng test 7.5.
  - [x] 9.3 `tools/test.sh` xanh. Commit một lần, lời commit tiếng Việt, ví dụ `Bàn cờ nghiêng isometric tạm (Story 1.7)`.
  - [x] 9.4 Ghi hướng dẫn tác giả tự test vào Completion Notes (mẫu ở mục Testing), kèm ảnh chụp đã xem.

### Review Findings

_Code review 2026-10-18 (Blind Hunter, Edge Case Hunter, Acceptance Auditor)._

- [x] [Review][Patch] Ô sáng và vòng chọn ở ô ngay sau ô ải tô lấn 8px lên mặt bệ ô ải phía trước (gặp ở trận thu_ba_tuong, ô 5,3 và 6,2): vẽ ô sáng xen với bệ ô ải theo độ sâu. Tác giả chọn giữ bệ ô ải vẽ trên mặt đất (2026-10-18) [game/src/battle/board_view.gd:354]
- [x] [Review][Defer] Khối rừng, kho lương, làng đứng sau ô ải che dải 8px của bệ (trong khi pick_cell chọn ô ải); chữ ô phẳng phía sau đè lên bệ ô ải [game/src/battle/board_view.gd:354] — deferred, trận hiện có chưa gặp; xem lại khi làm trận Giữ ải
- [x] [Review][Patch] Ô dưới chuột không cập nhật khi đồng quân dời tới mà chuột đứng yên (đi, hủy, lượt địch, F5): đường đi xem trước vẽ tới ô cũ, còn cú bấm kế tiếp trúng đồng quân [game/src/battle/battle_input.gd:85]
- [x] [Review][Patch] Nhãn tọa độ F1 (PanelContainer, mặc định MOUSE_FILTER_STOP) nuốt cú bấm và rê chuột trên phần lớn mỗi ô; cần MOUSE_FILTER_IGNORE [game/src/debug/coord_overlay.gd:56]
- [x] [Review][Patch] `TOP_OVERHANG = 28` là số cứng; nên tính từ `TOKEN_LIFT`, `RADIUS`, `PASS_HEIGHT` để `board_rect()` không hụt khi chỉnh cỡ [game/src/battle/board_view.gd:31]
- [x] [Review][Patch] Test chưa đúng spec: `test_token_on_pass_stands_on_platform` bấm vào điểm mà `cell_at` vốn đã trả đúng ô, nên không kiểm được việc chọn theo vị trí đã nâng (Task 3.3); `EDGE_STEP` là 3px thay vì 2px (Task 7.1) [game/tests/test_board_view.gd]
- [x] [Review][Patch] `CoordOverlay` tự cộng độ cao bệ (`surface_height`) vào `cell_center`, trái luật "chỉ BoardView đổi ô ↔ điểm"; nên thêm một hàm static tâm mặt trên ô ở BoardView và gọi hàm đó [game/src/debug/coord_overlay.gd:27]
- [x] [Review][Patch] Ghi chép story chưa khớp: Debug Log ghi 332/332, Completion ghi 333/333. Change Log ghi "14 test mới/sửa", thực tế là 14 mới, 3 sửa, 1 xóa. Việc xóa `test_cell_at_maps_board_pixels` (AC 8 ghi "không xóa"), dùng Lão 2,6 thay Khoái 0,6 (Task 7.2) và phá thử 7.8 chỉ làm một nhánh đều chưa ghi lại. Task 9.4 thiếu ảnh chụp [_bmad-output/implementation-artifacts/1-7-ban-co-nghieng-isometric-tam.md]
- [x] [Review][Defer] Bàn lớn hơn 7×7 tràn khỏi AREA và đè HUD, không có co giãn; file trận hiện khóa ở 7×7 [game/src/battle/board_view.gd:199] — deferred, chưa gặp được

## Dev Notes

### Bối cảnh

Đây chỉ là **đổi cách vẽ**. Luật, dữ liệu trận, kịch bản và tọa độ `cot,hang` trong file giữ nguyên [sprint-change-proposal-2026-10-18-isometric.md, mục Kỹ thuật]. Mọi thao tác của E1 đã có (chọn, đi, hủy, kết thúc lượt, F1, F5); story này phải giữ chúng chạy đúng trên bàn nghiêng. E2 (báo đòn 2.7, rê chuột 2.10, hoạt ảnh 2.11, xem trước 2.12) sẽ vẽ thẳng lên bàn nghiêng, nên quy ước ở đây là nền cho E2.

Hình học (128×64, ô `0,0` ở đỉnh trên):

```
               ^ đỉnh trên = position của BoardView
              / \
             /0,0\
            /\   /\
           /1,0\/0,1\        cột tăng: xuống phải
          /\   /\   /\       hàng tăng: xuống trái
         ...           ...
```

- Hướng Bắc trong file (hàng 0) thành hướng chéo lên bên phải trên màn hình. Tác giả đã chốt [proposal, mục 6].
- Trận 1: sông là cột 3 (mọi ô `3,r` trừ `3,3`). Cột cố định, hàng tăng thì xuống bên trái, nên sông thành một dải chéo từ cạnh trên phải xuống cạnh dưới trái, có khe ở `3,3`. Ô `0,6` (Khoái) là đỉnh trái của bàn; Lão ở `2,6`; địch ở `1,0`, `5,0`, `5,4`.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

**`game/src/battle/board_view.gd`**
- Hiện tại: `CELL_SIZE = 88`, bàn vuông 616×616 đặt ở (332, 52) bằng `setup()`. `cell_center` (static) và `cell_at` theo ô vuông. `_draw` vẽ nền, màu địa hình, ô sáng, đường kẻ, viền, vòng chọn (`draw_circle` bán kính 41), đường đi (`draw_polyline`). Con: `_terrain_labels` (Label ở góc dưới trái ô), `_units` (UnitToken theo id). `show_state(null)` xóa vòng chọn và về bàn trống. `_sync_tokens` dựng lại đồng khi id cũ đổi loại.
- Đổi: hình học thoi, `board_rect`, `pick_cell`, lớp `_world` y-sort, khối địa hình.
- Giữ nguyên: API `show_state`, `show_selection`, `show_path`, `clear_selection`, `lit_cells()`, `path()`, `tokens()`, `_selected_cell`, `NO_CELL`, `cols`/`rows`, `viewport_size`, `TERRAIN_COLORS`, `TERRAIN_KEYS`, `LINE_COLOR` (UnitToken dùng). `_sync_tokens` giữ logic cũ, chỉ đổi node cha thành `_world`.

**`game/src/battle/unit_token.gd`**: đồng tròn `RADIUS = 34` ở tâm ô, chấm máu `HP_OFFSET (24, 24)`. Đổi: đứng, có bóng. Giữ: `setup`, `update`, `unit_id`, `unit_type`, các hàm đọc cho test, `NAME_KEYS`.

**`game/src/battle/battle_input.gd`**: chỉ đổi `cell_at` → `pick_cell` (dòng 81).

**`game/src/debug/coord_overlay.gd`**: đang tính gốc ô vuông bằng `CELL_SIZE`. Đổi sang `cell_center`.

**`game/src/app/main.gd`** dòng 140–141: khung màn hình lỗi từ `CELL_SIZE`. Đổi sang `board_rect()`.

**`game/src/ui/hud.gd`**: chỉ sửa chú thích nếu bàn không đè.

### Ai đang dùng `CELL_SIZE` / ô vuông (phải sửa hết, `grep -rn CELL_SIZE game/`)

| Chỗ | Việc |
|---|---|
| `src/battle/board_view.gd` | thay bằng `TILE_W`, `TILE_H` |
| `src/app/main.gd:141` | `board_rect()` |
| `src/debug/coord_overlay.gd:24` | `cell_center` |
| `tests/test_battle_view.gd:383, 392, 439` | test F1 theo đồng quân, test `cell_at` mới |
| `tests/test_battle_view.gd:79, 213, 490, 494` và `tests/test_main.gd:302–303` | dùng `cell_center`, giữ nguyên, phải xanh |
| `tests/test_main.gd:153` | dùng `board_rect()` |

### Che khuất: vì sao dùng y-sort và đặt khối ở đỉnh trên ô

- Godot 4.7: `CanvasItem.y_sort_enabled` vẽ con có y lớn hơn ở trước; chỉ sắp các node cùng `z_index` [Godot docs 4.7, CanvasItem.y_sort_enabled]. Với thoi 2:1, y của tâm ô tăng theo `cot + hang`, đúng quy ước kiến trúc "thứ tự vẽ theo `cot + hang`, lớn hơn vẽ sau".
- Nếu khối và quân đều đặt ở tâm ô thì khi bằng y, Godot theo thứ tự node; khối dựng lại sau mỗi `show_state` sẽ nằm sau quân và che quân đang đứng trên ô ải. Đặt khối ở đỉnh trên ô (nhỏ hơn nửa ô) tránh hẳn chuyện này.
- Ô sáng, đường đi, vòng chọn vẽ trong `_draw` của `BoardView`, nên luôn nằm **dưới** khối và quân (cha vẽ trước con). Đường đi đi qua sau một khối thì bị khối che một đoạn: chấp nhận được, các ô đi được không bao giờ là khối (trừ ô ải).
- Hoạt ảnh E2 dời `position` của đồng quân bằng Tween; y-sort tự sắp lại mỗi khung hình. Không cần làm gì thêm bây giờ.

### Bấm chuột: `cell_at` và `pick_cell`

- `cell_at` là phép toán thuần trên mặt đất, giữ hợp đồng kiến trúc `cell_at(cell_center(c)) == c`. Các view khác (E2) tính vị trí qua `cell_center`.
- `pick_cell` cho chuột: thứ người chơi nhìn thấy trên cùng thắng. Hình chạm của đồng quân: hình tròn tâm `cell_center - (0, TOKEN_LIFT)`, bán kính `RADIUS`. Hình chạm của khối: mặt trên (thoi nâng lên `BLOCK_HEIGHT`) cộng hai mặt bên (dễ nhất: đa giác lục giác bao khối, `Geometry2D.is_point_in_polygon`). Duyệt ô theo `cot + hang` giảm dần, trong cùng tổng thì thứ tự nào cũng được (không chồng nhau).
- Ràng buộc kích thước để không bao giờ "nuốt" tâm ô khác: `BLOCK_HEIGHT < TILE_H / 2` và đồng quân không với tới tâm ô hàng xóm (Task 4.2). Test 7.2 giữ ràng buộc này.
- Ngoài hình thoi lớn mà không trúng đồng hay khối nào: `NO_CELL` → `BattleView` bỏ chọn như cũ.

### Cỡ và màu (màu UI, không phải số cân bằng, để `const` trong file view)

- `TILE_W = 128`, `TILE_H = 64`; hình thoi lớn 896×448. Mép bàn dày ~12px. Khối cao 16px. Sông trũng ~6px. Đồng `RADIUS = 26`, nâng 22px. Chữ địa hình cỡ 12 như cũ, chữ tên quân cỡ 18 có thể phải giảm còn 15–16 để vừa đồng nhỏ hơn.
- Có thể chỉnh sau khi chụp màn hình, miễn test bố cục (7.5) và test bấm (7.1, 7.2) xanh.
- Mặt bên khối: `Color.darkened()`. Bóng đồng: đen alpha ~0.3.

### Luật kiến trúc phải theo

- Mọi đổi ô ↔ điểm chỉ nằm trong `board_view.gd` (`cell_center`, `cell_at`; thêm `pick_cell` cho chuột) [game-architecture.md dòng 676].
- Vẽ bằng code (`_draw`, `draw_colored_polygon`, `draw_polyline`); ô và quân sinh bằng code; không TileMap, không `.tscn` mới, không tranh [project-context.md "Luật riêng của Godot"; proposal "Không dùng tranh AI"].
- `src/core/` cấm sửa; `check_boundaries.sh` kiểm phần cấm import [project-context.md "Tổ chức code"].
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). `PackedVector2Array` cho đa giác.
- Chữ hiển thị qua `tr()`. Story này không thêm chữ mới: chữ địa hình dùng lại `TERRAIN_KEYS`, ký hiệu hầm chông vẽ bằng hình.
- Renderer Compatibility (WebGL 2): `draw_colored_polygon` và `draw_polyline` chạy tốt; không dùng shader.
- Đi xuống thì gọi hàm, đi lên thì phát signal; không đổi đường signal hiện có.

### Testing

- Test chạy không cần màn hình qua `main.tscn` thật (`_make_main` trong `test_main.gd`, `test_battle_view.gd`).
- Test bố cục so khung chữ nhật (`Rect2.intersects`, `Rect2.encloses`), không so pixel ảnh.
- Không có test tự động cho "trông có đẹp không": tác giả xem bằng mắt (project-context "Test": UI tác giả test bằng tay). AI tự chụp bằng GoPeak trước để bắt lỗi rõ ràng (Task 8).
- Hướng dẫn tác giả tự test (Completion Notes), mẫu:
  1. `tools/chay.sh`: bàn thoi, ô `0,0` ở đỉnh trên, Khoái ở góc trái, sông là dải chéo có khe ở `3,3`. Quân đứng có bóng.
  2. Bấm Khoái (hoặc `1`): 7 ô sáng, vòng vàng elip dưới chân. Rê chuột lên ô sáng: đường đi. Bấm ô sáng: Khoái đi tới. Thử bấm sát mép các ô thoi, và bấm vào đầu đồng quân.
  3. `Z`, `Space`, nút Hủy, nút Kết thúc lượt chạy như trước.
  4. `tools/chay.sh --dev --tran=thu_ba_tuong`: rừng, kho lương, làng, ô ải là khối; hầm chông có ký hiệu; sông trũng. Khối ở trước che vật ở sau.
  5. F1: tọa độ trên từng ô thoi. F5 vẫn nạp lại.
  6. (Web) mở bản build theo hướng dẫn, xem có giật không. Nhớ trên Mac phím F1/F5 là Fn+F1/Fn+F5.

### Previous Story Intelligence (Story 1.4–1.6 và code review)

- Story 1.4 đặt nền: `cell_at` lấy vị trí từ chính sự kiện chuột qua `make_input_local`, đúng cả khi cửa sổ co giãn (`canvas_items`) và khi input được bơm vào (GoPeak, test). Giữ nguyên cách này.
- Story 1.4/1.5: chuột nằm sẵn trên ô rồi gõ phím chọn tướng thì vẽ đường đi ngay (`BattleView._select` gọi `_on_cell_hovered(_input.hovered_cell())`). `hovered_cell` giờ đến từ `pick_cell`; test `test_selecting_under_resting_mouse_draws_path_at_once` phải xanh.
- Code review 1.5: `main.gd` nối `events_resolved` trước `BattleView.start` để đồng quân vẽ lại trước ô sáng. Không đổi.
- Deferred 1.4: `BoardView.show_state(null)` tự xóa vòng chọn; giữ đúng hành vi này khi viết lại `_draw`.
- Story 1.6: F5 dựng lại trận bằng `show_state` mới. Khối địa hình phải dựng lại theo dữ liệu mới (sửa `dia_hinh` rồi F5 thì khối đổi theo).
- GoPeak: `inject_action` cho phím gán theo phím vật lý; `inject_mouse_click` nhận pixel cửa sổ 1280×720. Ảnh chụp ngay sau thao tác có thể chưa vẽ lại, chờ chút rồi chụp lại.
- Test bấm qua viewport thật phải đặt `main` trong `SubViewport` riêng (bảng kết quả GUT đè viewport gốc), như Story 1.5.
- Mỗi test hành vi mới phải được "làm hỏng tạm" để thấy nó trượt (Task 7.8).

### Git Intelligence

- 5 commit gần nhất: Story 1.5 (đi, hủy, kết thúc lượt), code review 1.5, Story 1.6 (F5). Story 1.6 không đụng file vẽ. `board_view.gd` đổi lần cuối ở Story 1.4/1.5 (ô sáng, vòng chọn, đường đi, màu "đã đi").
- Mẫu lời commit: tiếng Việt, kết thúc bằng `(Story 1.7)`.
- Thay đổi code review Story 1.6 (3 test F5 trong `test_main.gd`) có thể chưa commit lúc bắt đầu story này: kiểm `git status` trước, đừng gộp nhầm.

### Project Context Rules

- Godot 4.7.2, GDScript, GUT 9.7.1; cú pháp Godot 4; renderer Compatibility; 1280×720, stretch `canvas_items`, aspect `keep`.
- Hiệu năng không phải vấn đề với 7×7: không cache, không object pool. Dựng lại chữ và khối mỗi `show_state` là được.
- Mọi thao tác làm được bằng một cú bấm chuột; phím tắt qua InputMap.
- Xong một việc = `tools/test.sh` xanh rồi commit. Nói với tác giả bằng tiếng Việt, theo bước thử.
- Luật chưa có trong tài liệu thì hỏi tác giả.

### Quyết định của tác giả (2026-10-18)

1. **Ô ải là khối nhô lên, nhưng quân đi vào được** (quân Nguyên vào ô ải thì thua; tướng cũng đứng được). Spec ghi ô ải là khối nhô lên như rừng. Chọn:
   - **(a) ĐÃ CHỐT:** ô ải là bệ đá thấp (cao bằng nửa khối rừng); quân đứng trên ô ải được nâng lên theo bệ.
   - (b) Ô ải phẳng trên mặt đất (màu đá xám) kèm một cột cờ hoặc cổng nhỏ nhô lên ở góc sau; quân đứng như ô thường.
   - Chưa trận nào đang chơi có ô ải (trận 5 ở E3), chỉ trận thử `thu_ba_tuong` có. Chọn cách nào cũng không đổi luật.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Bấm chuột chọn **thứ nhìn thấy trên cùng**: bấm vào đầu đồng quân hay mặt khối đang nhô vào ô phía sau thì chọn ô của đồng hay khối đó, không chọn ô phía sau (Task 1.6).
- HUD giữ ở bên phải như cũ; bàn nằm ở vùng bên trái HUD.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 1.7; Epic 1 mô tả; danh sách cắt được khi trễ.
- `_bmad-output/planning-artifacts/sprint-change-proposal-2026-10-18-isometric.md` (mục 4.1 spec bàn nghiêng, mục 6 tác giả xác nhận ô `0,0`).
- `_bmad-output/planning-artifacts/game-architecture.md` dòng 573 (`board_view.gd` vẽ 49 ô thoi), dòng 676 (quy ước ô ↔ điểm, thứ tự vẽ).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` mục Art Style (Góc nhìn 2,5D), mục Terrain (ô nào đi vào được).
- `game/src/core/terrain.gd`: `WALKABLE = [PLAIN, SPIKES, PASS]`.
- `_bmad-output/implementation-artifacts/1-4-chon-tuong-va-xem-cac-o-di-duoc.md` (mục Hiển thị `BoardView`, `cell_at`).
- `_bmad-output/implementation-artifacts/deferred-work.md` dòng 4 (test canh giữa bàn), dòng 71 (`show_state(null)`).
- Godot 4.7 docs: `CanvasItem.y_sort_enabled`, custom drawing in 2D (`draw_colored_polygon`, `draw_polyline`, `draw_set_transform`).

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Đỏ trước: viết `game/tests/test_board_view.gd` trước, `tools/test.sh` báo lỗi script (`TILE_W`, `TerrainBlock` chưa có).
- Lần chạy đầu sau khi code: 3 trượt.
  - Khối đặt ở đỉnh trên ô (như Task 3.4 ghi) bằng đúng y với quân ở ô phía sau sát nó (`64 < 64` trượt). Đổi khối lên cao hơn tâm `TILE_H / 4`: quân phía sau nhỏ hơn 16px, quân cùng độ sâu lớn hơn 16px, quân trên bệ ô ải lớn hơn 8px.
  - `board_rect` hụt đúng mép phải (Rect2 không tính mép cuối). Thêm nửa nét viền bàn vào khung.
  - `test_reload_rebuilds_token_when_id_changes_type` còn đọc `_units`. Đổi sang đếm `UnitToken` trong `_world`.
- Làm hỏng tạm (trả lại ngay, sau đó 332/332 xanh; về sau thêm `test_error_screen_covers_board_rect` nên thành 333):
  - đảo dấu `cell_at` → 9 trượt (2 test đổi ô ↔ điểm và 5 test chuột cũ);
  - tắt `y_sort_enabled` → `test_blocks_and_tokens_sort_by_depth` trượt;
  - `BattleInput` quay về `cell_at` → `test_mouse_click_on_token_head_selects_that_general` trượt;
  - bỏ nâng quân trên ô ải → `test_token_on_pass_stands_on_platform` trượt.
  - Nhánh "đặt khối ở `cell_center`" của Task 7.8 chưa chạy thử; đọc code thì `assert_gt` cho quân cùng độ sâu sẽ trượt vì bằng y (ghi bổ sung khi code review).
- Lệch so với Tasks (đã cân nhắc, cùng mục đích):
  - Task 3.3: bệ ô ải vẽ trên mặt đất trong `BoardView._draw`, không phải node `TerrainBlock`. Ô sáng, vòng chọn, đường đi trên ô ải vẽ trên mặt bệ; nếu bệ là node trong `_world` thì nó che mất chúng. Bệ chỉ cao 8px nên không cần sắp theo chiều sâu với quân. Test 7.3 phần ô ải đổi thành kiểm quân đứng trên bệ (`cell_center - PASS_HEIGHT`) và bệ không nằm trong `_world`.
  - Task 3.4: khối đặt cao hơn tâm `TILE_H / 4`, không phải ở đỉnh trên (xem trên).
  - Task 5.2: nhãn tọa độ F1 đặt ở nửa trái ô. Ảnh chụp cho thấy đặt ở nửa trên thì đè lên tên quân.
  - Task 7.1 / AC 8: `test_cell_at_maps_board_pixels` (ô vuông) bị xóa, không sửa tại chỗ; các test đổi ô ↔ điểm mới trong `test_board_view.gd` thay nó (ghi bổ sung khi code review).
  - Task 7.2: test đầu đồng dùng Lão ở `2,6` thay Khoái ở `0,6`: đầu đồng Khoái nằm ngoài bàn (`cell_at` trả `NO_CELL`), không nằm trên đất của ô sau lưng như spec giả định (ghi bổ sung khi code review).
- GoPeak (`tools/chay.sh --dev`):
  - Trận 1: bàn thoi, sông dải chéo có khe `3,3`, quân đứng có bóng, không đè tiêu đề và HUD.
  - `select_general_1`: 7 ô sáng, vòng elip. Rê chuột (294, 334) = ô `1,4`: đường đi.
  - Bấm (294, 334): Khoái sang `1,4`, đổi màu "đã đi", nút Hủy sáng.
  - `dev_f1`: tọa độ đúng từng ô.
  - `--tran=thu_ba_tuong`: rừng, kho, làng là khối; ô ải là bệ xám; hầm chông có 3 mũi; sông trũng. Cung kỵ ở `5,2` che lên kho `5,1` phía sau.
- `tools/build_web.sh`: đạt, nén 10.4 MB / 25 MB.
- Ảnh chụp (code review): `_bmad-output/implementation-artifacts/anh/1-7-thu-ba-tuong.png`, trận `thu_ba_tuong`, Dư đã đi và đang chọn.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- `BoardView` vẽ bàn nghiêng 2:1 (ô 128×64), ô `0,0` ở đỉnh trên, bàn canh giữa vùng `AREA` (x 16–956, y 52–664), HUD giữ nguyên.
  - `cell_center` (static), `cell_at` (mặt đất), `pick_cell` (thứ nhìn thấy: đồng quân, khối), `board_rect`.
  - Mặt đất có mép bàn dày, sông trũng (mặt nước cắt theo mép ô), hầm chông 3 mũi, bệ ô ải, ô sáng, vòng chọn elip, đường đi.
- `TerrainBlock` (mới): khối rừng, kho lương, làng, có mặt bên tối hơn và chữ trên mặt.
  - Khối và đồng quân nằm chung `_world` (`y_sort_enabled`), che đúng chiều theo `cot + hang`.
- `UnitToken`: đồng đứng (nâng 22px, bán kính 26), bóng elip dưới chân. Đứng trên ô ải thì nâng thêm 8px. Có `cell` và `hit()` cho `pick_cell`.
- `BattleInput` dùng `pick_cell` cho cả bấm và rê.
- `CoordOverlay` tính theo `cell_center`.
- Khung màn hình lỗi lấy từ `board_rect()`.
- Test: thêm `test_board_view.gd` (13 test).
  - Đổi ô ↔ điểm: 49 ô đi rồi về, sát 4 đỉnh của mọi ô, ngoài 4 đỉnh bàn, hướng cột và hàng.
  - Chọn ô: `pick_cell` tâm mọi ô trên 2 trận, đầu đồng Lão, mặt khối rừng, bấm chuột thật qua `BattleInput`.
  - Che khuất, quân trên ô ải, bố cục.
  - Thêm `test_error_screen_covers_board_rect`. Sửa 4 test cũ theo bàn nghiêng.
- `tools/test.sh`: 333/333.
- Không sửa `game/src/core/`, `game/data/`, `game/tests/kich_ban/` (`git diff --stat` rỗng).

**Hướng dẫn tác giả tự test**

1. `tools/chay.sh`. Thấy bàn thoi, ô `0,0` ở đỉnh trên. Khoái ở góc trái, Lão bên phải Khoái. Sông là dải chéo, có khe ở giữa. Quân là đồng tròn đứng, có bóng, có số máu.
2. Bấm vào Khoái (hoặc phím `1`). Thấy 7 ô xanh và vòng vàng elip dưới chân Khoái. Rê chuột lên một ô xanh: thấy đường đi màu xanh dương. Bấm ô đó: Khoái đi tới, đổi màu đỏ xỉn, nút Hủy sáng.
3. Thử bấm sát mép các ô thoi: luôn chọn đúng ô dưới chuột. Bấm vào đầu đồng Lão (phần trên đồng tròn): chọn Lão.
4. `Z`, nút Hủy, `Space`, nút Kết thúc lượt chạy như trước.
5. `tools/chay.sh --dev --tran=thu_ba_tuong`:
   - Rừng (xanh lá), Kho (vàng), Làng (nâu) là khối nổi, mặt bên tối hơn.
   - Ô ải là bệ đá xám thấp. Hầm chông có 3 mũi nhọn. Sông trũng xuống.
   - Quân Cung kỵ (`C`) đứng trước kho nên che lên kho.
6. Còn trong `--dev`: bấm F1 (trên Mac là Fn+F1), thấy tọa độ ở nửa trái mỗi ô, số id cạnh đầu mỗi quân. Bấm F5 (Fn+F5): trận nạp lại.
7. (Web) Gõ `python3 -m http.server 8060 -d build/web`, mở `http://localhost:8060` trong Chrome, xem bàn nghiêng có mượt không. Xong thì bấm Ctrl+C để tắt server.

### File List

- `game/src/battle/board_view.gd` (sửa)
- `game/src/battle/terrain_block.gd` (mới)
- `game/src/battle/terrain_block.gd.uid` (mới)
- `game/src/battle/unit_token.gd` (sửa)
- `game/src/battle/battle_input.gd` (sửa)
- `game/src/debug/coord_overlay.gd` (sửa)
- `game/src/app/main.gd` (sửa)
- `game/src/ui/hud.gd` (sửa chú thích)
- `game/tests/test_board_view.gd` (mới)
- `game/tests/test_board_view.gd.uid` (mới)
- `game/tests/test_battle_view.gd` (sửa)
- `game/tests/test_main.gd` (sửa)
- `_bmad-output/planning-artifacts/game-architecture.md` (sửa)
- `_bmad-output/implementation-artifacts/deferred-work.md` (sửa)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa)
- `_bmad-output/implementation-artifacts/1-7-ban-co-nghieng-isometric-tam.md` (sửa)

### Change Log

- 2026-10-18: Tạo story.
- 2026-10-18: Tác giả chốt ô ải là bệ đá thấp, quân đứng trên được nâng lên (phương án a).
- 2026-10-18: Làm story: bàn nghiêng isometric 2:1, khối địa hình, đồng quân đứng, chọn ô nhìn thấy dưới chuột, F1 theo ô thoi; 14 test mới, 3 test sửa, 1 test xóa; `tools/test.sh` 333/333; build web đạt.
- 2026-10-18: Sửa theo code review: ô sáng vẽ xen với bệ ô ải theo độ sâu; chuột đứng yên chọn lại ô khi đồng quân dời tới; nhãn F1 không nuốt chuột; khung bàn tính phần nhô từ cỡ đồng quân; `BoardView.top_center` cho F1; test chọn đầu đồng trên bệ ô ải, sát mép 2px; 2 test mới; `tools/test.sh` 335/335.
