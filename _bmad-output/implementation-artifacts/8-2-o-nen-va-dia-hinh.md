---
baseline_commit: 142292a
---

# Story 8.2: Ô nền và địa hình

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn bàn cờ có cỏ, sông, rừng, làng như một chiến trường thật,
để nhìn là biết chỗ nào là gì.

_Chốt 2026-11-01 (tác giả): 6 trận hiện có đều là đất liền và sông, nên 8.2 chỉ dùng **ô ghép**, không làm nền vẽ liền (biển là Trận Bạch Đằng, E7). Ô báo đòn, ô sáng, đường đi, vòng chọn vẫn vẽ bằng code. Quân vẫn là đồng tròn vẽ bằng code (8.3 mới thay bằng hình). Đây là story đầu tiên **đổi diện mạo** của Epic 8._

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.2, `art-reference/ban-giao-asset.md`, `danh-sach-hinh-e8.md` mục A, mã nguồn `board_view.gd`, `terrain_block.gd`, `telegraph_view.gd`. Mục **[Chờ tác giả]** có đề xuất mặc định ở "Câu hỏi cho tác giả"; dev làm theo mặc định và để tác giả sửa sau khi xem hình.)

1. **Mặt đất ghép bờ cỏ–sông.** Nền mọi ô vẽ bằng bộ 16 ô `tex_o_nen_0..15` theo cách **lưới lệch nửa ô** (đã dùng ở bản thử, `img/pixellab-thu/cong-cu/lat_o.py`):
   - Với mỗi điểm giao `(vx, vy)`, `vx` từ `0` đến `cols`, `vy` từ `0` đến `rows`, tính `mask = (đất(vx-1,vy-1) << 3) | (đất(vx,vy-1) << 2) | (đất(vx-1,vy) << 1) | đất(vx,vy)`, trong đó `đất(c, r)` là `1` nếu ô `(c, r)` **không phải sông** (`terrain != Terrain.RIVER`: rừng, kho, làng, hầm chông, ô ải đều tính là đất), `0` nếu là sông. Tọa độ ngoài bàn **kẹp vào mép bàn** (ô ngoài bàn giống ô sát mép), nên sông chạy ra tới mép bàn.
   - Ô ghép `tex_o_nen_<mask>.png` (64×64) vẽ ở `(vx*64 - 32, vy*64 - 32)` tọa độ BoardView, **cắt gọn trong mặt bàn** `Rect2(0, 0, cols*64, rows*64)` (nửa ô thò ra ngoài mép bàn không được vẽ).
   - Đã kiểm trên hình: `mask 0` = toàn nước, `mask 15` = toàn cỏ, `mask 1` = chỉ góc dưới phải là cỏ, `mask 3` = nửa dưới là cỏ. Nếu dev thấy bờ sông lộn ngược, sửa **bit**, không sửa hình.
2. **Địa hình đặt lên nền, theo loại ô** (mọi hình qua `Art.tex()`, không `load()` riêng):
   - **Hầm chông** `^`: vẽ nguyên ô `tex_ham_chong_<0..3>` (64×64) thay hình ba mũi nhọn vẽ bằng code.
   - **Ô ải** `A`: vẽ bệ `tex_o_ai_be_da_<0..3>` (64×64, đã gồm mặt đá và chân bệ) thay `draw_raised` màu xám. Mặt trên bệ phải khớp `_top_rect(cell)` (cao hơn mặt đất `PASS_HEIGHT` = 8 px): quân đứng trên bệ không lệch mặt đá quá 4 px. Thứ tự vẽ từng hàng từ trên xuống (bệ che ô sáng hàng trên) như hiện nay.
   - **Rừng** `#`: `tex_rung_tre_truc` hoặc `tex_rung_cay_ram` (64×96, nền trong suốt). **Kho lương** `L`: `tex_kho_luong` (64×96). **Làng** `D`: `tex_lang_que` (64×96). Vẽ trong `TerrainBlock` thay khối màu, **đáy hình chạm đáy ô** (theo bản thử đã duyệt: góc trên trái hình đặt ở `(ground.x, ground.end.y - hình.cao + 2)` tính từ `position` của `TerrainBlock`; dev căn lại bằng mắt nếu lệch).
   - **Sông** `~`: chỉ là phần nước của nền (AC 1), không có hình riêng.
   - **Kho cháy** (`tex_kho_chay`), **làng cháy khói** (`tex_lang_chay_khoi`, `tex_lang_que_128`), `tex_ho_bay_la_*` (hố bẫy phủ lá), `tex_o_co_le_*` (cỏ lẻ) **chưa dùng ở story này** (kho cháy và làng trúng đòn là trạng thái động: Story 8.4; hố bẫy và cỏ lẻ chưa có luật tương ứng).
3. **Biến thể chọn tất định theo ô, không ngẫu nhiên.** Hầm chông, ô ải chọn kiểu `(cell.x * 31 + cell.y * 17) % 4`; rừng chọn `(cell.x + cell.y) % 2` (0 là `tre_truc`, 1 là `cay_ram`). Cùng ô thì luôn cùng hình (kể cả sau hoàn tác, F5, mở lại trận): **không** dùng `randi()`/`randf()`. Hàm chọn là hàm static có test.
4. **Nền rừng quanh bàn** (A8). Phần màn hình ngoài mặt bàn, trong lúc đánh trận, lát kín bằng `tex_vien_rung_<0..3>` (64×64), biến thể chọn tất định theo vị trí lát, thay nền xám mặc định. Vẽ **một lần** (không vẽ lại mỗi lần rê chuột), nằm **dưới** mặt đất bàn, và **dưới** HUD, tiêu đề, bảng. Phủ đủ cửa sổ 1280×720 mọi cỡ bàn 5×5 đến 10×8. Màn hình chính, màn chuyển trận, màn lỗi **không đổi** (8.6 làm).
5. **Mép dưới của bàn** (độ dày `EDGE_DEPTH`, hiện vẽ màu cát) đổi sang màu đất tối (`#4c3e24` hoặc gần đó trong bảng Resurrect 64) để nối với nền rừng; `EDGE_DEPTH` và mọi hằng hình học **không đổi**.
6. **Hình học và luật không đổi.** Không sửa `src/core/`, dữ liệu trận, `chi_so.json`, kịch bản `da_duyet: true`. Không đổi giá trị `TILE_SIZE`, `BLOCK_HEIGHT`, `PASS_HEIGHT`, `EDGE_DEPTH`, `AREA`, và hàm `cell_center`, `cell_rect`, `cell_at`, `pick_cell`, `board_rect`, `top_center`, `surface_height`. Vùng bấm của khối nhô lên (`_silhouette`) vẫn theo `BLOCK_HEIGHT`, **không** theo chiều cao hình. Hình rừng, kho, làng cao hơn khối cũ (96 px so với 16 px) và được phép che ô phía trên nó; hình ở hàng 0 thò lên trên bàn nhưng không được cắt cụt bởi mép cửa sổ. Thứ tự vẽ theo hàng (y-sort) của `TerrainBlock` và quân giữ nguyên.
7. **Các lớp báo hiệu vẫn nổi rõ trên nền mới** (NFR9):
   - Ô đỏ báo đòn, số thứ tự, mũi tên xung phong, viền mục tiêu trắng, vòng chọn vàng, đường đi, dấu tiếp viện, nhãn trừ máu hầm chông: **vẫn vẽ bằng code, không đổi thứ tự lớp** (kể cả `TelegraphView` vẽ ô đỏ của khối ở lớp số, trên khối).
   - **Ô sáng** (ô đi tới được, hiện xanh lá `REACH_COLOR` alpha 0.55) sẽ **chìm trên cỏ xanh**. Đổi màu `REACH_COLOR` (và viền nếu cần) sang màu **khác hẳn** cỏ, sông và ô đỏ (ví dụ trắng ngả xanh dương nhạt có viền sáng, hoặc cyan), sao cho ô sáng nhìn rõ trên cả cỏ, bờ sông và nền hầm chông. Đây là màu giao diện, không phải số cân bằng. Dev chụp màn hình có ô sáng (xem Task 6) cho tác giả duyệt màu.
   - Đường đi (`PATH_COLOR` xanh đậm) vẫn thấy được trên nước; nếu không, chỉnh màu.
8. **Chữ ghi trên ô** (Sông, Rừng, Làng, Kho, Hầm chông, Ải). **[Chờ tác giả: Câu hỏi 1]** Mặc định **bỏ**, vì hình đã đủ rõ và tooltip khi rê chuột vẫn có tên và hiệu ứng địa hình. Làm bằng một hằng `SHOW_TERRAIN_LABELS: bool = false` trong `BoardView`; đặt `true` là chữ hiện lại như cũ. Giữ node `_terrain_labels` và thứ tự lớp (test `test_telegraph_layers_order` kiểm).
9. **Lưới ô.** **[Chờ tác giả: Câu hỏi 2]** Mặc định giữ đường kẻ ô nhưng **mờ**: màu đen trong suốt khoảng 0.25, nét 1 px (thay `LINE_COLOR` nâu đậm 2 px), để vẫn đếm được ô khi chơi chiến thuật. Viền ngoài bàn (`BORDER_WIDTH`) giữ, đổi màu cho hợp nền nếu cần. Lưới là hằng màu, dễ chỉnh.
10. **Hiệu năng, dung lượng.** Chạy bàn 10×8 (trận 6) ở 60 FPS như Story 4.7 (đo lại bằng bộ đếm FPS của `--dev`, ghi số vào Completion Notes). `tools/build_web.sh`: bản nén ≤ 25 MB, ghi số mới (hiện 11.0 MB).
11. **Test và bàn giao.** Test GUT mới (Task 5), `tools/test.sh` xanh (kể cả `check_boundaries.sh`). Chụp màn hình 6 trận (Task 6) và đưa tác giả xem. Commit tiếng Việt kết `(Story 8.2)`. Tác giả thử tay rồi mới `done`.

## Tasks / Subtasks

- [ ] **Task 0: Tác giả trả lời Câu hỏi 1–3** (cuối file), hoặc nhận mặc định.
- [ ] **Task 1: Chọn ô và biến thể** (AC: 1, 3)
  - [ ] 1.1 Tạo `src/battle/ground_art.gd` (`class_name GroundArt`, `extends RefCounted`, chỉ hàm static, **không** `Node`): `static func mask(state: BattleState, vx: int, vy: int) -> int` (công thức AC 1, kẹp biên bằng `clampi` theo `state.size`; không gọi `terrain_at` với ô ngoài bàn: `terrain_at` không tự kiểm biên); `static func variant(cell: Vector2i, count: int) -> int` (hàm băm AC 3, luôn trong `[0, count)`, kể cả ô âm); các hàm trả đường dẫn hình ngắn cho `Art.tex()`: `ground_path(mask)`, `spikes_path(cell)`, `pass_path(cell)`, `block_path(kind, cell)`, `backdrop_path(tx, ty)`.
  - [ ] 1.2 Test (Task 5) viết **trước**, chạy thấy trượt.
- [ ] **Task 2: Mặt đất và nền quanh bàn** (AC: 1, 4, 5, 9)
  - [ ] 2.1 `GroundView` (`src/battle/ground_view.gd`, `extends Node2D`, `show_behind_parent = true`, thêm làm con của `BoardView`): với `show_behind_parent` node con được vẽ **trước** `_draw` của cha, nên mặt đất nằm dưới lưới, ô sáng, vòng chọn mà `BoardView._draw` vẽ. Con này phải ở **chỉ số 0** để vẽ dưới `_telegraph` (ô đỏ); kiểm bằng ảnh chụp rằng ô sáng, ô đỏ, lưới, chữ vẫn nằm trên mặt đất. API: `show_state(state)`; `_draw` lát lưới lệch nửa ô theo AC 1 bằng `draw_texture_rect_region` (cắt gọn mặt bàn) và vẽ ô hầm chông.
  - [ ] 2.2 Nền quanh bàn: một node con riêng (hoặc `GroundView` thứ hai) `show_behind_parent`, phủ toàn cửa sổ **trong tọa độ màn hình**: vì `BoardView` có `position` và `scale` (thu theo bậc nguyên), tính vùng cần lát trong tọa độ local bằng `Rect2(-position / scale, viewport_size / scale)`. Vẽ lại **chỉ khi** `setup()` đổi cỡ bàn.
  - [ ] 2.3 Sửa `BoardView._draw`: bỏ vẽ màu ô, sông, hầm chông, mép bàn màu cát; giữ vòng lặp từng hàng (bệ ô ải, ô sáng, vòng chọn) với bệ ô ải bằng hình (AC 2); lưới mờ (AC 9); mép dưới màu đất (AC 5). Giữ `_draw_river`, `_draw_spikes`, `TERRAIN_COLORS` chỉ khi còn dùng (màu dự phòng khi thiếu hình, hoặc xóa nếu không ai dùng; `test_main.gd` dùng `TERRAIN_KEYS`, **giữ** `TERRAIN_KEYS`).
- [ ] **Task 3: Khối nhô lên bằng hình** (AC: 2, 3, 6, 8)
  - [ ] 3.1 `TerrainBlock`: `_draw` vẽ hình `Art.tex(GroundArt.block_path(kind, cell))` ở vị trí AC 2; bỏ `draw_raised` và nhãn chữ khi `BoardView.SHOW_TERRAIN_LABELS` là `false`. Giữ `position`, `ORIGIN_ABOVE_CENTER`, `cell`, `kind` (test cũ đọc).
  - [ ] 3.2 `BoardView._rebuild_terrain`: ô phẳng (sông, hầm chông, ô ải) chỉ thêm nhãn khi `SHOW_TERRAIN_LABELS`.
- [ ] **Task 4: Màu báo hiệu** (AC: 7)
  - [ ] 4.1 Đổi `REACH_COLOR` (và viền ô sáng nếu cần) sau khi xem ảnh chụp thật. 4.2 Kiểm đường đi, viền mục tiêu, ô đỏ trên cỏ, sông, hầm chông: ghi vào Completion Notes ô nào kém rõ, màu đã đổi.
- [ ] **Task 5: Test GUT** (AC: 1, 3, 6, 7, 8, 10, 11)
  - [ ] 5.1 `tests/test_ground_art.gd`: `GroundArt.mask` với các bàn dựng bằng `BoardFixture`/`BoardText` (xem `tests/board_fixture.gd`): toàn đất → 15; toàn sông → 0; một ô sông ở giữa bàn: bốn điểm giao quanh nó có `mask` 14, 13, 11, 7 đúng chỗ (viết bàn 3×3, tính tay từng điểm); ô sông ở góc và ở mép: tọa độ ngoài bàn kẹp đúng; rừng, kho, làng, hầm chông, ô ải đều tính là đất; `variant` luôn trong khoảng, cùng đầu vào cùng đầu ra, ô âm không lỗi, và đủ các biến thể xuất hiện trên bàn 10×8 (không dồn một kiểu).
  - [ ] 5.2 `tests/test_board_view.gd` (thêm, không sửa test cũ): dựng bàn có đủ 7 loại ô, `show_state`, chờ một khung hình, **không** có dòng `[ERROR][hinh]` trong `Log` (mọi hình có thật); `BoardView.SHOW_TERRAIN_LABELS == false` thì `_terrain_labels` không có nhãn; geometry không đổi (các test cũ đã kiểm: chạy lại xanh).
  - [ ] 5.3 Nền quanh bàn: với bàn 5×5 và 10×8, vùng lát trong tọa độ màn hình phủ trọn `Rect2(0, 0, 1280, 720)` (trừ mặt bàn). Cung cấp hàm `GroundView.backdrop_rect()` hoặc tương đương để test.
  - [ ] 5.4 **Thử làm hỏng:** đổi tạm bit trong `mask` → test 5.1 trượt; đổi tạm `variant` thành số ngẫu nhiên → test tất định trượt. Hoàn lại.
- [ ] **Task 6: Chụp và bàn giao** (AC: 7, 10, 11)
  - [ ] 6.1 Chụp bằng GoPeak `capture_screenshot` (`tools/chay.sh --dev --tran=N`, N=1..6; chờ khoảng 5 giây; xong thì tắt game): trận 1 (cỏ và sông), trận 2 (rừng), trận 4 (làng), trận 3 (hầm chông), trận 5 (ô ải), trận 6 (bàn lớn nhất, kho). Lưu ảnh vào `_bmad-output/implementation-artifacts/anh/8-2-*.png` (thư mục đã có, theo mẫu các story trước).
  - [ ] 6.2 Ảnh có **ô sáng** và **ô đỏ báo đòn** cùng lúc, và có đường đi trên sông: `inject_mouse_click` của GoPeak **không có tác dụng** trên game này (ghi ở bộ nhớ dự án và Story 4.6); dùng script tạm trong scratchpad (`push_input` vào viewport gốc) hoặc `tools/chay.sh --dev` kèm tham số có sẵn nếu có, **không** sửa code game để tiện chụp.
  - [ ] 6.3 `tools/test.sh` xanh; `tools/build_web.sh`; ghi FPS trận 6 và dung lượng.
  - [ ] 6.4 Cập nhật Dev Agent Record, File List, `sprint-status.yaml` (`8-2-...: review`). Cập nhật `CREDITS.md` **không cần** (hình đã có dòng ở 8.1).

## Dev Notes

### Hiện trạng cần đọc trước khi code (đã kiểm 2026-11-01, commit `142292a`)

- `BoardView` (`src/battle/board_view.gd`, 560 dòng): mọi thứ vẽ bằng `_draw` của chính nó và vài node con; thứ tự con: `_telegraph` (ô đỏ mặt đất), `_terrain_labels`, `_world` (y-sort: `TerrainBlock` và `UnitToken`), `_preview`, `_target_layer`, `_damage_labels`, `_telegraph.numbers`. **Không đổi thứ tự này.**
- `_draw` hiện vẽ theo thứ tự: mép bàn (`draw_raised` màu cát) → từng ô sông (`_draw_river`) và hầm chông (`_draw_spikes`) → lưới → viền bàn → vòng lặp từng hàng: bệ ô ải (`draw_raised` xám), ô sáng (`REACH_COLOR`), vòng chọn → dấu tiếp viện → đường đi.
- `TerrainBlock` (`src/battle/terrain_block.gd`, 40 dòng): `position = cell_center - (0, TILE_SIZE/4)` để y-sort đúng (xem chú thích đầu file, **giữ nguyên** `position`); `_draw` hiện gọi `BoardView.draw_raised` với màu `TERRAIN_COLORS`.
- `TelegraphView.top_rect(cell)` tính mặt trên ô theo `BoardView.top_center(cell, kind)` (khối cao `BLOCK_HEIGHT` = 16, bệ cao 8). Ô đỏ của khối vẽ ở **lớp số** (trên khối) để khối không che. Giữ cách đó; hình khối cao hơn ô đỏ nhưng ô đỏ nửa trong suốt đè lên hình vẫn thấy.
- `terrain_at(cell)` **không** kiểm biên; luôn kiểm `in_bounds` trước (đã có dòng ghi chú trong `_draw_river`).
- Kho lương cháy: `Effects.burn_granary` đổi ô thành **đất trống**; sự kiện `GRANARY_BURNED` phát `_flash_burn` (event_player). Sau khi cháy, ô là đất trống. **Hình hố cháy trên ô đó là việc của 8.4**, vì cần nhớ ô nào từng là kho qua hoàn tác và F5.
- `Art.tex(path)` (`src/ui/art.gd`, Story 8.1) là cách duy nhất nạp hình. Đường dẫn tính từ `res://assets/textures/`, ví dụ `Art.tex("dia_hinh/tex_o_nen_5.png")`. Thiếu hình thì ra ô hồng đậm 64×64 và một dòng `[ERROR][hinh]` trong log. Test 8.1 (`test_assets.gd`) cấm `load("res://assets/textures...")` ngoài `art.gd`.
- Hình có sẵn ở `game/assets/textures/dia_hinh/`: `tex_o_nen_0..15` (64×64), `tex_ham_chong_0..3`, `tex_ho_bay_la_0..3`, `tex_o_ai_be_da_0..3`, `tex_rung_cay_ram`, `tex_rung_tre_truc` (64×96), `tex_kho_luong` (64×96), `tex_kho_chay`, `tex_lang_que` (64×96), `tex_lang_que_128` (64×128), `tex_lang_chay_khoi` (64×128), `tex_vien_rung_0..3`, `tex_o_co_le_0..3`, `tex_khung_*` (khung vàng 16 px, **chưa dùng**: khung là phong cách bảng giao diện, để 8.5).
- Đã **đo** vùng có hình thật trong ảnh 64×96: rừng `(1,4)–(63,92)`, rừng cây rậm `(1,4)–(63,92)`, kho `(3,9)–(62,87)`, làng `(1,14)–(63,81)`. Nên có khoảng trống 4–15 px ở đáy hình: dựa vào đó căn "đáy hình chạm đáy ô" bằng mắt.
- **Hình học cố định:** `AREA = Rect2(16, 52, 940, 612)`. Bàn 10×8 cao khoảng 550 px nên đã gần kín vùng; hình rừng ở hàng 0 thò lên thêm khoảng 30 px nhưng vẫn dưới tiêu đề (bàn trận 6 có đỉnh ô ở `y ≈ 108`).

### Cách ghép ô chuyển tiếp (đã xác minh trên hình)

Bộ `tex_o_nen_0..15` là bộ 16 ô **ghép theo góc** (dual-grid): mỗi ô ghép mô tả **một điểm giao** của bốn ô bàn, không phải một ô bàn. Vì vậy ảnh ghép rộng `(cols+1) × (rows+1)` ô và lệch `-32, -32` so với bàn. Sông rộng 1 ô vẫn ra thành dải liền.
Bit bật = **đất**: ô 0 = bốn góc nước, ô 15 = bốn góc cỏ, ô 3 = hai góc dưới là cỏ (cỏ ở nửa dưới), ô 12 = hai góc trên là cỏ (nước ở nửa dưới), ô 5 và 10 là dải dọc, ô 6 và 9 là hai góc chéo nhau. Mask = `NW<<3 | NE<<2 | SW<<1 | SE`.

### Rủi ro và việc cần xem bằng mắt (báo tác giả)

- **Lệch màu cỏ.** `tex_o_nen_15` (cỏ xanh xám) và `tex_ham_chong_*`, `tex_o_co_le_*` (nền vàng ô-liu) là hai bộ cỏ khác nhau; ô hầm chông có thể nhìn như một miếng đất lạ cạnh cỏ. Hiện bàn đã ghi nhận: "Ô hầm chông còn hơi lộ khung vuông" (`ban-giao-asset.md`). **Không tự sửa hình** (hình AI chưa sửa tay, tác giả sửa); ghi vào Completion Notes mức lệch và đề xuất.
- **Ô ải nằm giữa cỏ:** bệ đá vuông có thể nhìn như một tấm lát; chấp nhận.
- **Hình rừng, làng kiểu chếch** (đáy hình thoi, nghiêng kiểu isometric) trên bàn ô vuông nhìn từ trên: tác giả đã duyệt trên ảnh thử (`img/thu-nhom-a-tren-ban-phong-to.png`), không đổi hình ở story này.
- **60 FPS trận 6:** vẽ thêm khoảng 99 ô ghép, 80 ô nền, khoảng 240 ô nền rừng. Mọi thứ vẽ qua `draw_texture`, gộp lô được; vẫn **đo**, không đoán.
- **Cắt gọn ô ghép ở mép bàn:** dùng `draw_texture_rect_region`; nếu để thò ra thì ô ghép đè lên nền rừng quanh bàn và lộ viền xanh nước ngoài bàn.

### Luật dự án áp dụng (từ `project-context.md`)

- GDScript 4.7, **gõ kiểu tĩnh mọi nơi** (`untyped_declaration` = error); `Log.error/warn/info/debug("hinh", "...")`, không `print()`.
- `src/core/` là vùng cấm: **không đụng**. `GroundArt` đọc `BattleState` (lõi) chỉ để hỏi `terrain_at`, `size`; đặt ở `src/battle/` (hiển thị), không đặt trong `core`. `check_boundaries.sh` phải xanh.
- **Hoạt ảnh và hiển thị chỉ đọc bản chụp**, không sửa `BattleState`. `GroundView.show_state(state)` không giữ tham chiếu ghi.
- **Không lặp cứng cỡ bàn** (`range(7)`, `49`): luôn dùng `cols`, `rows`, `state.size`.
- **Tất định:** không `randi()`/`randf()` trong chọn hình; băm theo ô.
- Nạp sẵn toàn bộ asset (`Art.tex` nhớ hình). Web đơn luồng: không `Thread`.
- Bản nén ≤ 25 MB. 60 FPS ở trận 6.
- Xong một việc = `tools/test.sh` xanh rồi commit tiếng Việt. Không báo "xong" khi chưa chạy test.
- Nói với tác giả bằng tiếng Việt, các bước thử: `tools/chay.sh --dev --tran=N`, thấy gì là đúng.
- MCP chỉ để nhìn và thử. Không dùng `run_project` của GoPeak. `inject_*` không có tác dụng ở game này.

### Việc thuộc story khác (đừng làm ở đây)

Quân bằng hình (8.3). Hoạt ảnh, hiệu ứng, kho cháy, làng cháy khói, hố bẫy phủ lá (8.4). Khung, nút, theme, bảng giao diện, `tex_khung_*` (8.5). Màn hình chính, màn chuyển trận (8.6). Âm thanh (8.7). Trận biển (E7).
Sau khi 8.2 và 8.3 xong, cập nhật `game-architecture.md` (mục "Nạp asset", dòng "Đồng quân và ô cờ vẽ bằng code") và `project-context.md`; **không** làm ở 8.2.

### Project Structure Notes

- Thêm mới: `game/src/battle/ground_art.gd`, `game/src/battle/ground_view.gd` (+ `.uid`), `game/tests/test_ground_art.gd`. Sửa: `board_view.gd`, `terrain_block.gd`, có thể `test_board_view.gd` (chỉ thêm test). Thêm ảnh chụp ở `_bmad-output/implementation-artifacts/anh/`.
- Khớp kiến trúc: logic hiển thị ở `src/battle/` (cùng chỗ `board_view.gd`, `terrain_block.gd`, `telegraph_view.gd`).

### Previous Story Intelligence (8.1)

- `Art.tex()` đã có, mọi hình đã vào `assets/textures/` (415 file, đã nhập `.import`). `tools/nap_hinh.sh` chép lại khi tác giả vẽ lại hình.
- Test `test_assets.gd` kiểm bảng màu: mọi hình trong `dia_hinh/` đã đúng Resurrect 64.
- Bài học 8.1: test GUT coi **cảnh báo engine** là lỗi; đọc PNG thô khi cần, không `Image.load_from_file("res://...")`.
- Bài học bảng gợi ý (sửa 2026-11-01): `board_rect()` được dùng để đặt bảng gợi ý ở dải trống dưới hoặc trên bàn; **đổi `board_rect()` là phá cách đặt bảng**, nên 8.2 giữ nó nguyên (AC 6).
- Công cụ chụp: `tools/chay.sh --dev --tran=N` ở nền, chờ khoảng 5 giây, `capture_screenshot`, rồi tắt game (`pkill -f "Godot.*--path"`).

### Git Intelligence

Commit gần đây: `142292a` đóng 8.1; `d8f13ce` nạp 415 hình, `Art`, test; `c14713f` sửa vị trí bảng gợi ý. Mẫu test dùng `GutTest`, dựng `SubViewport` 1280×720 cho cảnh `main.tscn` (xem `tests/test_hint_panel.gd`).

### References

- `_bmad-output/planning-artifacts/epics.md` (Epic 8, Story 8.2)
- `_bmad-output/planning-artifacts/art-reference/ban-giao-asset.md` (bộ ô Tier 1, `lat_o.py`, bản thử gắn hình), `danh-sach-hinh-e8.md` (mục A)
- `img/pixellab-thu/cong-cu/lat_o.py` (công thức mask), `gan_hinh_vao_ban_thu_v2.patch` (cách đặt hình khối trong bản thử)
- `game/src/battle/board_view.gd`, `terrain_block.gd`, `telegraph_view.gd`, `src/ui/art.gd`, `tests/test_board_view.gd`, `tests/test_assets.gd`
- `_bmad-output/project-context.md`, `game-architecture.md` (mục tọa độ ô ↔ điểm màn hình, thứ tự vẽ)

## Câu hỏi cho tác giả

1. **Chữ trên ô** (Sông, Rừng, Làng, Kho, Hầm chông, Ải): bỏ khi đã có hình? _(Đề xuất: bỏ. Hình đã rõ; rê chuột vẫn hiện tên và hiệu ứng địa hình. Dev để một công tắc, bật lại bằng một dòng.)_
2. **Lưới ô:** giữ đường kẻ ô nhưng mờ để đếm ô? _(Đề xuất: giữ mờ, nét 1 px. Không lưới thì khó đếm "cách 2 ô" khi tính đòn.)_
3. **Nền quanh bàn:** lát rừng rậm tối kín cả màn hình lúc đánh trận (thay nền xám hiện tại)? _(Đề xuất: có. Bảng và nút bên phải sẽ nằm trên nền tối; chữ trắng vẫn đọc được. Khung vàng `tex_khung_*` để 8.5, không dùng ở đây.)_

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
