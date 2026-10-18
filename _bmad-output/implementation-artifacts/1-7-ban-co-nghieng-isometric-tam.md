# Story 1.7: Bàn cờ nghiêng (isometric) tạm

Status: ready-for-dev

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
- [ ] **Task 1: Phép đổi ô ↔ điểm trong `BoardView`** (AC: 1, 5, 8)
  - [ ] 1.1 Thay `CELL_SIZE` bằng `TILE_W = 128`, `TILE_H = 64` (2:1). Giữ một nơi khai báo; mọi chỗ khác đọc từ đây (xem bảng "Ai đang dùng `CELL_SIZE`" bên dưới).
  - [ ] 1.2 `static func cell_center(cell)`: gốc tọa độ local của `BoardView` là **đỉnh trên của ô `0,0`**. `x = (cot - hang) * TILE_W / 2`, `y = (cot + hang) * TILE_H / 2 + TILE_H / 2`. Vẫn là hàm `static`, không phụ thuộc kích thước bàn (đồng quân và test đang gọi `BoardView.cell_center` kiểu static).
  - [ ] 1.3 `func cell_at(local_pos)`: phép ngược trên **mặt đất**. `a = x / TILE_W + y / TILE_H`, `b = y / TILE_H - x / TILE_W`, `cell = Vector2i(floori(a), floori(b))`. Ngoài `[0, cols) × [0, rows)` thì `NO_CELL`. Giữ đúng hợp đồng kiến trúc `cell_at(cell_center(c)) == c`.
  - [ ] 1.4 `func board_rect() -> Rect2`: khung chữ nhật bao trọn mọi thứ bàn vẽ ra (hình thoi lớn, độ dày mép bàn, phần khối và đồng quân nhô lên ở hàng trên cùng), tính trong tọa độ của cha (`main`). Dùng cho canh giữa, cho màn hình lỗi, cho test bố cục.
  - [ ] 1.5 `setup(cols, rows)`: đặt `position` (đỉnh trên của ô `0,0` trên màn hình) sao cho `board_rect()` nằm giữa vùng trống bên trái HUD: x trong `[16, 956]`, y trong `[52, 664]` (dưới tiêu đề, trên nhãn phiên bản). Bàn 7×7 với 128×64: hình thoi rộng 896, cao 448, còn dư chỗ.
  - [ ] 1.6 `func pick_cell(local_pos) -> Vector2i`: ô mà người chơi **nhìn thấy** dưới chuột. Xét từ gần người xem ra xa (`cot + hang` giảm dần): trúng đồng quân (hình tròn đứng) hoặc trúng khối nhô lên (mặt trên và hai mặt bên) thì trả ô đó; không trúng gì thì trả `cell_at(local_pos)`. Lý do: đồng quân đứng và khối nhô lên chồng lên ô phía sau. Bấm vào đầu đồng quân mà lại chọn ô sau lưng nó thì sai với Story 1.4 ("bấm vào tướng mình luôn là chọn").
- [ ] **Task 2: Vẽ mặt đất trong `BoardView._draw`** (AC: 1, 2, 6)
  - [ ] 2.1 Mỗi ô là đa giác thoi 4 đỉnh quanh `cell_center` (`draw_colored_polygon`). Đất trống màu `CELL_COLOR`, hầm chông màu hiện có kèm ký hiệu vẽ bằng code (ví dụ 3 tam giác nhọn nhỏ), đường kẻ ô `LINE_COLOR`, viền hình thoi lớn `BORDER_WIDTH`.
  - [ ] 2.2 Mép bàn có độ dày: hai mặt trước (cạnh dưới trái, cạnh dưới phải của hình thoi lớn) vẽ thêm một dải tối hơn cao khoảng 12px. Cho bàn cảm giác là một tấm.
  - [ ] 2.3 Sông thấp hơn mặt đất: vẽ ô sông thành lòng trũng (mặt nước hạ xuống khoảng 6px, hai thành phía sau tối hơn lộ ra). Màu nước giữ `TERRAIN_COLORS[RIVER]`.
  - [ ] 2.4 Ô sáng (`REACH_COLOR`) tô lên mặt thoi của ô. Vòng chọn thành **hình elip 2:1** trên mặt đất quanh chân đồng quân (tính các điểm rồi `draw_polyline`; `draw_circle` không méo được). Đường đi nối các `cell_center` như cũ.
  - [ ] 2.5 Chữ ngắn của sông và hầm chông (`TERRAIN_KEYS`) đặt ở nửa dưới ô thoi, không bị đồng quân che hết. Chữ của khối nằm trên mặt trên khối (Task 3).
- [ ] **Task 3: Lớp vật đứng: khối địa hình và đồng quân, sắp theo chiều sâu** (AC: 2, 3, 4)
  - [ ] 3.1 Trong `BoardView`, thay `_units` bằng một `Node2D` `_world` có `y_sort_enabled = true`. Khối địa hình và đồng quân đều là con của `_world`. Thứ tự con của `BoardView` sau Story 1.7: chữ địa hình phẳng, `_world`, overlay F1 (do `main.gd` thêm cuối cùng).
  - [ ] 3.2 File mới `game/src/battle/terrain_block.gd` (`class_name TerrainBlock extends Node2D`): vẽ một khối thoi nhô lên, mặt trên màu `TERRAIN_COLORS[kind]`, hai mặt bên tối hơn (ví dụ `darkened(0.25)` và `darkened(0.4)`), kèm chữ ngắn trên mặt trên. Chiều cao khối `BLOCK_HEIGHT = 16`.
  - [ ] 3.3 Rừng, kho lương, làng: khối cao `BLOCK_HEIGHT`. **Ô ải** (tác giả chốt 2026-10-18): bệ đá thấp `PASS_HEIGHT = BLOCK_HEIGHT / 2`; quân đứng trên ô ải được nâng lên `PASS_HEIGHT` (BoardView đặt lại `position` của đồng sau `update`, hoặc truyền độ nâng vào đồng; `pick_cell` tính theo vị trí đã nâng).
  - [ ] 3.4 **Thứ tự che khuất bằng y-sort:** đặt `position` của khối ở **đỉnh trên** ô thoi của nó (`cell_center - (0, TILE_H / 2)`), còn đồng quân ở `cell_center` (chân đồng). Như vậy y của khối ô `(c, r)` là `(c + r) * TILE_H / 2`, y của quân là `(c + r) * TILE_H / 2 + TILE_H / 2`: quân ở ô phía sau luôn vẽ trước khối, quân đứng trên chính ô đó (ô ải) vẽ sau khối, và không phụ thuộc thứ tự thêm node. Tự vẽ hình khối lệch xuống trong `_draw` của khối cho đúng chỗ.
  - [ ] 3.5 `_rebuild_terrain_labels()` đổi thành dựng lại cả chữ phẳng lẫn khối (tên mới, ví dụ `_rebuild_terrain()`), gọi ở `show_state` như cũ. Bàn trống (`state == null`) thì không có khối nào.
- [ ] **Task 4: Đồng quân đứng** (AC: 3)
  - [ ] 4.1 `UnitToken`: `position` vẫn là `BoardView.cell_center(unit.cell)` (chân đồng). Trong `_draw`: bóng là elip mờ trên mặt đất tại `(0, 0)`, đồng tròn vẽ nâng lên `TOKEN_LIFT` (tâm đồng ở `(0, -TOKEN_LIFT)`). Nhãn tên và chấm máu dời lên theo.
  - [ ] 4.2 Cỡ gợi ý: `RADIUS = 26`, `TOKEN_LIFT = 22`. Ràng buộc bắt buộc (có test ở Task 7): bấm vào `cell_center` của **mọi** ô, kể cả khi ô trước và sau đều có quân, vẫn ra đúng ô đó. Với 128×64 thì đồng không với tới tâm ô hàng xóm (khoảng cách gần nhất ≥ 32px theo chiều dọc, 64px theo chiều ngang).
  - [ ] 4.3 Màu phe, màu "đã đi", chữ tên, số máu giữ nguyên ý nghĩa; `hp_text()`, `name_text()`, `is_moved()` giữ nguyên cho test.
- [ ] **Task 5: Input và F1 theo bàn nghiêng** (AC: 5, 6, 7)
  - [ ] 5.1 `BattleInput._unhandled_input`: đổi `_board.cell_at(...)` thành `_board.pick_cell(...)` cho cả bấm và rê chuột. Phần còn lại giữ nguyên (lấy vị trí từ sự kiện, `make_input_local`).
  - [ ] 5.2 `CoordOverlay.show_state`: nhãn `cot,hang` canh giữa ở nửa trên ô thoi (quanh `cell_center - (0, TILE_H / 4)`), nhãn id quân đặt cạnh đồng quân (ví dụ góc trên phải của đồng đứng). Chỉ gọi `BoardView.cell_center`, không tự tính hình học [kiến trúc: "View khác gọi hai hàm này, không tự tính"]. Overlay vẫn là con cuối của `BoardView`, nằm trên mọi thứ.
- [ ] **Task 6: `main.gd` và HUD** (AC: 1)
  - [ ] 6.1 `_show_error`: màn hình lỗi lấy khung từ `_board_view.board_rect()` thay cho `position` + `cols * CELL_SIZE`.
  - [ ] 6.2 `Hud.PANEL_POSITION` giữ `(972, 52)` nếu bàn không đè lên; sửa chú thích "bàn chiếm x 332–948" theo khung mới.
- [ ] **Task 7: Test** (AC: 8; theo mẫu `test_battle_view.gd`, `test_main.gd`)
  - [ ] 7.1 Sửa `test_cell_at_maps_board_pixels` thành bộ test bàn nghiêng:
    - đi rồi về: cả 49 ô, `cell_at(cell_center(c)) == c`;
    - sát mép: với mỗi ô, 4 điểm cách mỗi đỉnh thoi 2px vào phía tâm đều ra đúng ô;
    - ngoài bàn: điểm cách đỉnh trên của ô `0,0` 2px lên trên, điểm ngoài đỉnh trái, phải, dưới của hình thoi lớn đều là `NO_CELL`;
    - hướng: `cell_center(1,0)` ở dưới bên phải `cell_center(0,0)`, `cell_center(0,1)` ở dưới bên trái.
  - [ ] 7.2 Test `pick_cell`: trên trận 1 có quân, `pick_cell(cell_center(c)) == c` cho cả 49 ô; điểm trên đầu đồng quân Khoái (`0,6`), nằm trong vùng đất của ô sau lưng, vẫn ra `0,6`. Trên `thu_ba_tuong`: điểm ở mặt trên khối rừng `1,1` (phần nhô vào ô sau) ra `1,1`.
  - [ ] 7.3 Test che khuất: trong `_world`, `y_sort_enabled` bật; với khối rừng `1,1` và quân ở `1,0` (trận `thu_ba_tuong`: Bộ binh ở `1,0`), y của quân nhỏ hơn y của khối (vẽ trước). Quân đứng trên ô ải (nếu tác giả chốt quân đứng được trên khối ải) có y lớn hơn khối đó.
  - [ ] 7.4 Sửa `test_coord_overlay_follows_moved_unit` (`test_battle_view.gd` dòng ~379): nhãn id 1 nằm quanh đồng ở ô mới (so với `cell_center(KHOAI_TARGET)`), không còn so với gốc ô vuông.
  - [ ] 7.5 Test bố cục: `board_rect()` của trận 1 nằm trong `[16, 956] × [52, 664]`; không giao với khung tiêu đề, khung HUD (`Hud.PANEL_POSITION`, `PANEL_WIDTH`), khung nhãn phiên bản. Sửa `test_title_label_sits_above_board` dùng `board_rect()`.
  - [ ] 7.6 Test màn hình lỗi: khung `ErrorScreen` bằng `board_rect()`.
  - [ ] 7.7 Các test đang bấm qua `get_global_transform_with_canvas() * BoardView.cell_center(cell)` (`_hover_by_mouse`, test bấm chuột thật) phải xanh mà không sửa; nếu trượt là `pick_cell` sai.
  - [ ] 7.8 "Làm hỏng tạm" để chứng minh test bắt được lỗi (như Story 1.5, 1.6): đảo dấu trong `cell_at` → 7.1 trượt; tắt `y_sort_enabled` hoặc đặt khối ở `cell_center` → 7.3 trượt; `BattleInput` quay về `cell_at` → 7.2 trượt. Ghi vào Debug Log.
  - [ ] 7.9 `git diff --stat` không có file nào trong `game/src/core/`, `game/data/`, `game/tests/kich_ban/` (AC 10).
- [ ] **Task 8: Nhìn bằng mắt (GoPeak) và bản web** (AC: 1–7, 9)
  - [ ] 8.1 `tools/chay.sh --dev` chạy nền, chờ ~5 giây, `capture_screenshot`: bàn thoi, quân đứng, không đè tiêu đề và HUD. Bấm `1`, chụp: ô sáng và vòng chọn elip đúng chỗ. `inject_mouse_click` vào tâm vài ô sáng (tính từ `cell_center` + `position` của bàn), chụp: quân đi đúng ô. F1 (`inject_action dev_f1`), chụp: tọa độ đúng ô thoi.
  - [ ] 8.2 `tools/chay.sh --dev --tran=thu_ba_tuong`, chụp: đủ 6 loại ô + ô ải, khối che đúng chiều.
  - [ ] 8.3 `tools/build_web.sh` đạt (dung lượng trong giới hạn). Ghi vào hướng dẫn cho tác giả cách mở bản web để tự xem độ mượt (giống Task 5 Story 1.6). Không deploy.
- [ ] **Task 9: Tài liệu, test, commit** (AC: 8)
  - [ ] 9.1 `game-architecture.md` đã có quy ước ô ↔ điểm và thứ tự vẽ (dòng 573, 676). Bổ sung: `pick_cell` cho chuột (ô nhìn thấy), `cell_at` cho mặt đất; y-sort trong `_world`, khối đặt ở đỉnh trên ô.
  - [ ] 9.2 `deferred-work.md` dòng 4 (chưa có test canh giữa `BoardView.setup`): đánh dấu đã làm bằng test 7.5.
  - [ ] 9.3 `tools/test.sh` xanh. Commit một lần, lời commit tiếng Việt, ví dụ `Bàn cờ nghiêng isometric tạm (Story 1.7)`.
  - [ ] 9.4 Ghi hướng dẫn tác giả tự test vào Completion Notes (mẫu ở mục Testing), kèm ảnh chụp đã xem.

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

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List

### Change Log

- 2026-10-18: Tạo story.
- 2026-10-18: Tác giả chốt ô ải là bệ đá thấp, quân đứng trên được nâng lên (phương án a).
