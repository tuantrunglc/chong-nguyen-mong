---
baseline_commit: 6fb4bef
---

# Story 8.3: Quân đứng yên

Status: done

## Story

Là người chơi,
tôi muốn thấy ba tướng và ba loại quân Nguyên bằng hình,
để phân biệt phe và loại quân ngay.

_Chốt 2026-11-01 (tác giả): Epic 8 chỉ đổi hình và tiếng, **không đổi luật**. Story này thay **đồng quân tròn có chữ** bằng hình quân đứng yên. Hoạt ảnh đi, đánh, trúng đòn, gục là Story 8.4. Ô đỏ báo đòn, số thứ tự, ô sáng, đường đi, vòng chọn, chấm máu vẫn vẽ bằng code (NFR9)._

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.3, `art-reference/danh-sach-hinh-e8.md` mục B, mã nguồn `unit_token.gd`, `board_view.gd`. Mục **[Chờ tác giả]** có đề xuất mặc định ở "Câu hỏi cho tác giả"; dev làm theo mặc định và để tác giả sửa sau khi xem hình.)

1. **Mỗi quân hiện bằng hình đứng yên theo loại.** 6 loại quân dùng 6 bộ hình có sẵn ở `game/assets/textures/quan/`:
   `UnitType.NGUYEN_KHOAI` → `tex_khoai_<hướng>.png`, `PHAM_NGU_LAO` → `tex_lao_*`, `TRAN_KHANH_DU` → `tex_du_*`, `BO_BINH` → `tex_bo_binh_*`, `KY_BINH` → `tex_ky_binh_*`, `CUNG_KY` → `tex_cung_ky_*`.
   Mỗi bộ có đủ 8 hướng: `south`, `south_east`, `east`, `north_east`, `north`, `north_west`, `west`, `south_west`, mỗi hình 64×64. Mọi hình nạp qua `Art.tex()` (Story 8.1), không `load()` riêng. Hình thiếu thì `Art` đã ghi `[ERROR][hinh]` và trả ô hồng, game không sập.
2. **Hướng đứng. [Đã chốt: Câu hỏi 1]** Mặc định: quân quay mặt về **quân địch gần nhất** (khoảng cách Manhattan; hòa thì lấy quân id nhỏ hơn), làm tròn về 1 trong 8 hướng. Không còn địch trên bàn thì giữ hướng cũ (hoặc mặc định: Đại Việt quay `north`, Nguyên quay `south`).
   - Chỉ là chuyện hiển thị: **không** thêm trường hướng vào `Unit`, `BattleState` hay lõi luật, không ghi vào file lưu, không đụng test luật. Hàm chọn hướng là hàm thuần tĩnh trong `src/battle/`, test được không cần cảnh.
   - Hướng tính lại mỗi lần `BoardView.show_state` (quân đi, quân bị đẩy, quân chết đổi địch gần nhất). Hướng **không** đổi giữa lúc hoạt ảnh pha địch đang chạy (đó là việc 8.4).
3. **Có bóng dưới chân.** Bóng đặt dưới chân quân, dưới hình quân. Mặc định dùng `giao_dien/tex_bong_do_quan_32x16.png` (đã có trong `assets/`), thay cho hình elip vẽ bằng code. Bóng giữ nguyên khi quân đứng trên bệ ô ải (bóng và chân cùng nâng theo `lift`).
4. **Chấm máu giữ nguyên.** Chấm máu tròn trắng có số vẫn vẽ bằng code ở góc dưới phải thân quân (`HP_OFFSET`, `HP_RADIUS` hiện tại, hoặc chỉnh vị trí cho hợp thân hình, tối đa vài pixel). Số máu vẫn đọc rõ trên mọi hình quân, kể cả Kỵ binh, Cung kỵ (hình rộng nhất, xấp xỉ 60 px).
5. **Phân biệt phe bằng màu hình. [Chờ tác giả: không có câu hỏi, đã chốt 2026-10-20]** Đại Việt đỏ, Nguyên xám xanh, đã có sẵn trong hình. **Không** thêm vòng màu hay nền tròn dưới quân. Nhìn một cái phải biết phe và loại quân; tác giả xem ảnh chụp để duyệt.
6. **"Đã đi" và "đã đánh" vẫn là tô mờ bằng code, không đổi hình. [Đã chốt: Câu hỏi 3]** Mặc định, nhân màu hình quân (`modulate` của chính phần vẽ hình, không phải của cả `UnitToken`, vì hoạt ảnh `_flash` dùng `modulate` của token):
   - đã đi: nhân `Color(0.78, 0.70, 0.70)` (hơi xỉn, ngả đỏ nhạt);
   - đã đánh: nhân `Color(0.60, 0.60, 0.62)` (xám nhạt, rõ hơn "đã đi");
   - cả hai: dùng màu "đã đánh". Hai trạng thái phải **phân biệt được bằng mắt** với nhau và với quân còn nguyên lượt (tác giả chốt 2026-10-18: "đã đánh" khác hẳn "đã đi", không dùng độ trong suốt).
   - Hằng số ở đầu `unit_token.gd`, có bình luận tiếng Việt.
7. **Chữ tên trên quân. [Đã chốt: Câu hỏi 2]** Mặc định: **bỏ chữ tên** (hình đã đủ để nhận ra, như 8.2 bỏ chữ ô). Dùng công tắc `UnitToken.SHOW_NAMES: bool = false` tương tự `BoardView.SHOW_TERRAIN_LABELS` của 8.2: node nhãn tên vẫn được tạo (giữ `name_text()` cho test và để bật lại), chỉ ẩn (`visible = false`). Nhãn máu không có công tắc, luôn hiện.
8. **Luật và hình học không đổi.**
   - Mọi test luật, `Unit`, `BattleState`, `BattleEvent` không bị sửa; `src/core` không bị đụng.
   - `BoardView.pick_cell`, `UnitToken.hit()`, `TOKEN_LIFT`, `RADIUS` giữ nguyên nghĩa (vùng bấm vẫn là hình tròn quanh thân, vì hình quân cao ~60 px nên `hit` vẫn trúng thân); `cell_at`, `board_rect`, `cell_rect`, `cell_center` không đổi. Nếu dev cần đổi `TOKEN_LIFT` hoặc `_local_rect` để hình vừa khung thì **dừng và báo tác giả**, vì khung bàn xê dịch kéo theo bảng gợi ý, HUD.
   - Hình quân đứng, đầu cao nhất ~62 px so với chân. Chân hình đặt ở `position + Vector2(0, FOOT_DROP)` với `FOOT_DROP` mặc định **18 px** (chân vẫn nằm trong ô, đỉnh đầu không vượt đỉnh đồng tròn cũ nên `_local_rect` và `board_rect` giữ nguyên). Dev đo lại bằng ảnh chụp.
9. **Hoạt ảnh pha địch hiện có vẫn chạy đúng** (`event_player.gd`: bước đi tween `position`, `_lunge`, `_shake`, `_flash`, `_flash_heal`, chìm, mờ dần). Chúng tác động lên node `UnitToken` (vị trí, `modulate`, `visible`) nên hình quân đi theo mà không phải sửa `event_player.gd`. `UnitToken.update()` vẫn trả `visible = true` và `modulate = WHITE` như hiện nay.
10. **Xem trước đòn (PreviewView) vẫn là đồng tròn mờ. [Đã chốt: Câu hỏi 4]** Mặc định giữ nguyên `preview_view.gd` (bóng mờ vẽ bằng code theo `UnitToken.RADIUS`, `TOKEN_LIFT`, `HP_OFFSET`), để 8.4 xử lý cùng hoạt ảnh. Vì vậy **không** xóa các hằng `RADIUS`, `TOKEN_LIFT`, `HP_OFFSET`, `DAI_VIET_COLOR`, `NGUYEN_COLOR`.
11. **Tác giả duyệt bằng mắt.** Chụp màn hình (MCP `capture_screenshot`, `tools/chay.sh --dev --tran=N`) ít nhất: trận 1 (đủ 3 tướng + Bộ binh), trận 6 (Kỵ binh, Cung kỵ nếu có), một ảnh có quân "đã đi" và "đã đánh" cạnh quân nguyên lượt, một ảnh quân trên bệ ô ải (trận 5), một ảnh ô đỏ báo đòn và ô sáng nằm cạnh quân. Lưu vào `_bmad-output/implementation-artifacts/anh/8-3-*.png`.
12. **Test.** `tools/test.sh` xanh; có test mới (xem Task 4). Không giảm số test cũ; test cũ chỉ sửa chỗ buộc phải sửa vì đồng tròn không còn (ví dụ chữ tên), và ghi vào Completion Notes.

## Tasks / Subtasks

- [x] Task 1: Hàm chọn hình và hướng (AC: 1, 2)
  - [x] 1.1 Tạo `game/src/battle/unit_art.gd` (`class_name UnitArt`, `extends RefCounted`, chỉ hàm tĩnh): `facing_for(unit: Unit, state: BattleState) -> int` trả chỉ số 0..7 (hoặc enum) theo địch gần nhất; `sprite_path(unit_type: int, facing: int) -> String`.
  - [x] 1.2 Bảng `UnitType` → tiền tố (`khoai`, `lao`, `du`, `bo_binh`, `ky_binh`, `cung_ky`) và danh sách 8 hậu tố hướng, hằng ở đầu file. Quy ước: Bắc ở phía trên màn hình (`north`), Đông bên phải (`east`).
  - [x] 1.3 Tính hướng từ vec `(dx, dy)` tới địch: gộp theo góc 45°, dấu `dy` âm là lên (`north`). Làm tròn tất định, không dùng `randi`.
- [x] Task 2: `UnitToken` vẽ hình (AC: 1, 3, 4, 5, 6, 7, 8, 9)
  - [x] 2.1 `setup()` giữ `unit_type`; thêm `set_facing(facing)` (chỉ `queue_redraw` khi đổi). `_draw()`: bóng bằng `tex_bong_do_quan_32x16`, rồi `draw_texture` hình quân (chân ở `FOOT_DROP`, căn giữa theo bề ngang), rồi chấm máu như cũ. Bỏ vẽ đồng tròn.
  - [x] 2.2 Tô mờ "đã đi"/"đã đánh" bằng màu nhân khi `draw_texture` (tham số `modulate`), **không** đổi `self.modulate`.
  - [x] 2.3 Thêm `SHOW_NAMES` và ẩn nhãn tên; nhãn máu giữ; bỏ tô màu chữ tên theo "đã đánh" nếu nhãn ẩn (giữ được cũng không sao, nhưng không để lỗi).
  - [x] 2.4 Giữ `hit()`, `TOKEN_LIFT`, `RADIUS`, `HP_OFFSET`, `name_text()`, `hp_text()`, `is_moved()`, `is_attacked()`.
- [x] Task 3: `BoardView` cấp hướng cho đồng quân (AC: 2, 9)
  - [x] 3.1 Trong `_sync_tokens()` và `add_reinforcement_token()` gọi `UnitArt.facing_for` rồi `token.set_facing(...)` sau `setup`/`update`.
  - [x] 3.2 Không đổi thứ tự con, không đổi `y_sort`, không đổi `pick_cell`.
- [x] Task 4: Test (AC: 1, 2, 4, 6, 7, 8, 12)
  - [x] 4.1 Mới `game/tests/test_unit_art.gd`: mọi `UnitType` × 8 hướng → đường dẫn tồn tại (`ResourceLoader.exists` qua `Art.tex` không báo lỗi); `facing_for` đúng 8 hướng trên bàn nhỏ dựng tay (`BoardFixture`), địch gần nhất hòa thì id nhỏ, hết địch thì giữ mặc định.
  - [x] 4.2 `test_board_view.gd`: không dòng `[ERROR][hinh]` khi dựng bàn có đủ 6 loại quân (nhớ `Art.reset_for_test()` đầu test, bài học review 8.2); `pick_cell` vẫn trả đúng ô khi bấm vào thân hình quân; hai quân khác loại ra hai hình khác nhau.
  - [x] 4.3 Test màu: màu nhân "đã đi" ≠ "đã đánh" ≠ trắng, đủ cách biệt (tính khoảng cách RGB, không chỉ so hằng).
  - [x] 4.4 Sửa test cũ buộc phải sửa (`test_main.gd`: `name_text` chỉ còn đúng khi `SHOW_NAMES` đổi) giống cách 8.2 làm với `SHOW_TERRAIN_LABELS`; ghi vào Completion Notes.
  - [x] 4.5 `tools/test.sh` xanh.
- [x] Task 5: Duyệt bằng mắt (AC: 5, 11) — còn thiếu ảnh "đã đi/đã đánh" và ô ải, xem Completion Notes
  - [x] 5.1 (mới chụp trận 1 và 6, thiếu 3 ảnh còn lại) Chạy `tools/chay.sh --dev --tran=N` ở chế độ nền, chụp bằng GoPeak `capture_screenshot`, lưu vào `anh/8-3-*.png`. Xong thì tắt game.
  - [x] 5.2 Ghi vào Completion Notes: quân nào nhìn không rõ, hướng nào lạ, số máu chỗ nào bị chìm.
  - [x] 5.3 Nếu hình quân bị lệch (chân lơ lửng hoặc chìm xuống ô dưới), chỉnh `FOOT_DROP` trong khoảng 12 đến 24 px; không dời `TOKEN_LIFT`.

### Review Findings

- [x] [Review][Decision] Quân Nguyên cũng bị tô xỉn/xám khi `has_moved`/`has_attacked` — `tint()` không xét phe, trước đây quân Nguyên luôn một màu. Cờ chỉ reset ở đầu pha địch (`rules_enemy_phase.gd:20-21`), nên quân Nguyên đã đánh vẫn xám suốt lượt người chơi, dễ nhầm với quân Đại Việt hết lượt. Spec chỉ nói "tướng đã đi/đánh". Chọn: (a) chỉ tô cho Đại Việt (đề xuất), (b) tô cả hai phe. → ĐÃ CHỐT (tác giả chọn 1): chỉ tô cho Đại Việt; đã sửa `tint()` và thêm test.
- [x] [Review][Patch] AC11/Task 5 chưa xong: thiếu 3 ảnh (đã đi/đã đánh cạnh nguyên lượt; quân trên bệ ô ải trận 5; ô đỏ/ô sáng cạnh quân, kèm xem chấm máu Khoái–Kỵ binh sát nhau); bỏ tick 5.3 (`FOOT_DROP`) cho đến khi xem ảnh trận 5 [8-3-quan-dung-yen.md:Task 5] — MỞ: đã bỏ tick 5.3. Thử chụp lại 2026-11-01: được 1/3 (`anh/8-3-o-sang-o-do.png`: ô đỏ và ô sáng cạnh quân, trận 1). Chọn tướng bằng chuột giả được, nhưng bấm ô để đi thì hình không đổi nữa (màn chụp đứng), nên chưa có ảnh "đã đi/đã đánh" và ô ải trận 5. Tác giả tự xem hai cảnh này
- [x] [Review][Patch] Test màu chỉ so hằng với `Color.WHITE`; viết test dựng token, gọi `update()` với `has_moved`/`has_attacked`, kiểm `tint()` (kể cả cả hai cờ → màu đã đánh) [game/tests/test_unit_art.gd]
- [x] [Review][Patch] Test "địch gần nhất, hòa thì id nhỏ" tự tính `expected` bằng chính hàm đang thử; khẳng định hướng cụ thể [game/tests/test_unit_art.gd]
- [x] [Review][Patch] Test "đầu quân không vượt khung" dùng công thức tự đặt, không có ô ải, nhân `board.scale` cho `position` đã ở hệ `_world`; đo bằng token trên bệ ô ải hàng 0 và so khung `board_rect()` (khung hiện sát 44px, không dư) [game/tests/test_board_view.gd:~215]
- [x] [Review][Patch] `PREFIXES[unit_type]` không có khóa thì lỗi; thêm kiểm khóa/fallback [game/src/battle/unit_art.gd:sprite_path]
- [x] [Review][Patch] Tham số `facing` (set_facing) và `name` (facing_index) che tên khác; đổi `p_facing`, `p_name` theo quy ước dự án [game/src/battle/unit_token.gd, unit_art.gd]
- [x] [Review][Patch] `FACING_COUNT` lặp `FACING_NAMES.size()`; bỏ một [game/src/battle/unit_art.gd]
- [x] [Review][Defer] Hướng không cập nhật khi quân đi/tiếp viện xuất hiện giữa hoạt ảnh (chỉ đổi ở `show_state`) [board_view.gd:427,455] — deferred, khớp AC2 hiện tại; Story 8.4 xử lý chuyển động
- [x] [Review][Defer] `UnitToken.hit()` vẫn là vòng tròn tại tâm đồng cũ, lệch hình mới (đã dời `FOOT_DROP`) [unit_token.gd:hit] — deferred, xem lại khi 8.4/chạy thử
- [x] [Review][Defer] Hằng thừa sau khi bỏ đồng tròn (`NGUYEN_COLOR`, `DAI_VIET_COLOR`, `RADIUS`...) [unit_token.gd:61-75] — deferred, dọn khi chốt
- [x] [Review][Defer] `_name_label` đặt màu chữ Đại Việt cho cả quân Nguyên khi hết `_attacked` [unit_token.gd:101] — deferred, pre-existing, nhãn đang ẩn

## Dev Notes

### Hiện trạng cần đọc trước khi code (kiểm 2026-11-01, commit `6fb4bef`)

- `src/battle/unit_token.gd` (141 dòng): `Node2D` vẽ đồng tròn bán kính `RADIUS=24` ở `Vector2(0, -TOKEN_LIFT)` (`TOKEN_LIFT=20`), bóng elip `SHADOW_RADIUS=(22,8)`, chấm máu bán kính 9 ở `HP_OFFSET=(19,17)` tính từ tâm đồng. `position` là chân đồng = `BoardView.cell_center(cell)` trừ `lift` (bệ ô ải). Hai nhãn con: tên (`_name_label`, `NAME_KEYS`), máu (`_hp_label`). `_fill_color()` đổi theo phe và "đã đi"/"đã đánh". `hit(point)` kiểm trong bán kính `RADIUS` quanh tâm đồng.
- `src/battle/board_view.gd`: `_sync_tokens()` (dòng ~417) tạo/cập nhật đồng; `add_reinforcement_token()` cho quân tiếp viện; `pick_cell()` (dòng ~153) dùng `token.hit()` và `token.cell.y` để chọn vật gần người xem nhất; `_local_rect()` (dòng ~351) tính `token_top = PASS_HEIGHT + TOKEN_LIFT + RADIUS - TILE_SIZE/2` làm đỉnh khung bàn. **Hằng này quyết định `board_rect`**; đổi nó là đổi bố cục màn hình.
- `src/battle/event_player.gd`: dùng `UnitToken` qua `_board.tokens()`; tween `position`, `modulate`, `visible` của token; `_move_target` dùng cùng công thức vị trí với `UnitToken.update`. Không sửa file này ở 8.3.
- `src/battle/preview_view.gd`: vẽ bóng mờ xem trước bằng `UnitToken.RADIUS`, `TOKEN_LIFT`, `HP_OFFSET`, `DAI_VIET_COLOR`, `NGUYEN_COLOR`. Giữ nguyên (AC 10).
- `src/debug/coord_overlay.gd` dùng `RADIUS`, `TOKEN_LIFT` để đặt nhãn id. Giữ nguyên.
- `src/core/unit.gd`: `Unit` có `id, faction, type, cell, hp, has_moved, has_attacked`; **không có hướng**. Đừng thêm.
- Hình: `game/assets/textures/quan/tex_<quan>_<hướng>.png`, 6 quân × 8 hướng, 64×64, 1-bit alpha, bảng Resurrect 64, viền `#2e222f`. Đo hộp bao ở hướng `south`: Khoái (2,1)-(62,63), Lão (13,1)-(47,62), Dư (10,1)-(55,63), Bộ binh (5,2)-(55,61), Kỵ binh (1,1)-(60,62), Cung kỵ (5,1)-(58,63). Chân hình ở khoảng y=61..63 của khung 64. `CREDITS.md` đã có dòng B1..B6 (Story 8.1), không cần thêm.
- Bóng: `game/assets/textures/giao_dien/tex_bong_do_quan_32x16.png` (32×16, dither 1-bit). Đã có trong `assets/`, đã có dòng CREDITS.
- Hoạt ảnh (đi, đánh, trúng, gục) đã có hình ở `assets/textures/hoat_anh/` nhưng **chưa dùng**; để 8.4. Đừng nối ở đây.

### Rủi ro và việc cần xem bằng mắt (báo tác giả)

- **Kích thước khung bàn.** Đỉnh đầu hình (khoảng 62 px trên chân) phải không vượt đỉnh đồng tròn cũ (44 px trên tâm ô khi `lift = 0`). Với `FOOT_DROP = 18` thì vừa đủ. Nếu thấy đầu quân hàng 0 bị cắt hoặc đè tiêu đề, **đừng** dịch bàn; báo tác giả.
- **Hình rộng ở hai bên.** Kỵ binh và Cung kỵ rộng ~60 px, sát mép ô. Kiểm hai quân đứng cạnh nhau không đè lên nhau quá nhiều, và không che chấm máu của quân bên cạnh.
- **Thứ tự vẽ.** Quân đã y-sort theo `y` (`_world.y_sort_enabled`). Hình quân cao hơn đồng cũ, đầu có thể che chân quân hàng trên; xem ảnh trận đông quân (trận 6).
- **Chấm máu có thể chìm trên hình.** Chấm trắng viền tối, đặt ở góc dưới phải thân; xem trên hình Khoái (rộng nhất).
- **Test cũ phụ thuộc đồng tròn.** `test_main.gd` (dòng ~349-416) và `test_battle_view.gd` kiểm `name_text()`, `hp_text()`, vị trí; kiểm từng cái, đừng sửa bừa.

### Luật dự án áp dụng (từ `project-context.md`)

- Chỉ cú pháp Godot 4, gõ kiểu tĩnh mọi nơi; `untyped_declaration` là error.
- Hình nạp qua `Art.tex()`; lỗi nạp ghi `Log.error("hinh", ...)` tiếng Việt. Không `print`, không `randi` (luật tất định, hiển thị cũng nên tất định).
- Không đụng `src/core`. Kiểm ranh giới (`tools/test.sh` bước 1) cấm lõi luật import code vẽ; `UnitArt` nằm trong `src/battle/`.
- Mọi chữ hiển thị qua `tr()` và `text.csv`; story này không thêm chữ mới.
- Không thêm thư viện, không đổi Godot, không đổi tên file hình (tên `tex_*` cố định từ 8.1).
- Mỗi file mới có `.uid` do Godot sinh (chạy game hoặc test một lần rồi commit `.uid`).

### Việc thuộc story khác (đừng làm ở đây)

- Hoạt ảnh đi, đánh, trúng đòn, gục, kho lương cháy, làng cháy khói: Story 8.4.
- Bóng mờ xem trước bằng hình quân: Story 8.4.
- Bảng thông tin tướng, chân dung, giao diện: Story 8.5.
- Hướng quân thay đổi theo hành động (quay mặt lúc đánh/đi): 8.4. Ở 8.3 hướng chỉ là "nhìn địch gần nhất".

### Project Structure Notes

- Mới: `game/src/battle/unit_art.gd` (+ `.uid`), `game/tests/test_unit_art.gd` (+ `.uid`).
- Sửa: `game/src/battle/unit_token.gd`, `game/src/battle/board_view.gd`, `game/tests/test_board_view.gd`, `game/tests/test_main.gd` (nếu buộc phải).
- Không sửa: `src/core/*`, `event_player.gd`, `preview_view.gd`, `telegraph_view.gd`, `ground_*`.

### Previous Story Intelligence (8.2)

- **Review 8.2 bắt được 5 lỗi đáng nhớ, tránh lặp lại:**
  1. Lớp vẽ nền che mất tiêu đề vì thứ tự `add_child`. Ở 8.3 không thêm lớp phủ mới, nhưng kiểm tiêu đề vẫn hiện trong ảnh chụp.
  2. Test tautology: so hằng với hằng, hoặc đảo ngược chính công thức. Test màu "đã đi/đã đánh" phải đo hành vi (khoảng cách màu thật), không so hằng.
  3. Test "không thiếu hình" xanh giả vì `Art._cache` và `_reported` là static: **luôn gọi `Art.reset_for_test()` đầu test** và đừng chỉ dựa vào log.
  4. Thiếu kiểm null cho lớp con tạo trong `_ready` khi `show_state`/`setup` gọi sớm. Kiểm null trước khi dùng.
  5. Task chụp ảnh đánh `[x]` khi chưa chụp đủ. Chỉ đánh khi đã lưu ảnh.
- **Cách làm của 8.2 đáng bắt chước:** công tắc hằng (`SHOW_TERRAIN_LABELS`) để bỏ chữ mà không xóa node; ảnh chụp lưu ở `anh/8-2-*.png`; mục "Câu hỏi cho tác giả" với mặc định rõ ràng.
- Tác giả hay đổi hình thay thế sau khi xem ảnh (đã thay 4 hình nền rừng ngay trong lúc review). Giữ đường dẫn hình ở một chỗ (`UnitArt`) để dễ thay.

### Git Intelligence

- `6fb4bef` (8.2): thêm `ground_view.gd`, `backdrop_view.gd`, `ground_art.gd`; mẫu `GroundArt` (hàm tĩnh chọn đường dẫn hình) là mẫu cho `UnitArt`. Thay `terrain_block.gd` vẽ bằng hình.
- `85d67c1`: sửa khung thông tin (tooltip) bị kéo cao; liên quan khi rê chuột lên quân. Kiểm tooltip vẫn đúng chỗ khi hình quân cao hơn.
- Chưa commit (cây làm việc): sửa của review 8.2 (thứ tự tiêu đề, `tile_range`, test). Story này làm trên cây đó.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 8.3]
- [Source: _bmad-output/planning-artifacts/art-reference/danh-sach-hinh-e8.md#B. Quân]
- [Source: _bmad-output/planning-artifacts/art-reference/ban-giao-asset.md]
- [Source: _bmad-output/project-context.md]
- [Source: game/src/battle/unit_token.gd]
- [Source: game/src/battle/board_view.gd#_sync_tokens, #pick_cell, #_local_rect]
- [Source: game/src/battle/event_player.gd]
- [Source: _bmad-output/implementation-artifacts/8-2-o-nen-va-dia-hinh.md#Review Findings]

## Câu hỏi cho tác giả

**Đã chốt 2026-11-01 (tác giả): cả 4 câu theo đề xuất. Câu 2: bỏ chữ tên vì đã có bảng thông tin của quân (Story 4.x), nên dev không cần kiểm lại.** Dev làm theo mặc định; tác giả vẫn đổi được sau khi xem ảnh.

1. **Quân quay mặt hướng nào?** Hình có 8 hướng nhưng luật không có "hướng". Mặc định: mỗi quân quay về **địch gần nhất** (ra dáng đối đầu, đổi khi quân di chuyển). Cách khác: Đại Việt luôn quay lên (`north`), Nguyên luôn quay xuống (`south`), đơn giản hơn nhưng thấy lưng tướng. Hoặc Đại Việt luôn quay về phía địch, Nguyên về phía tướng gần nhất.
2. **Bỏ chữ tên trên quân?** Mặc định: bỏ (hình đủ nhận ra; tác giả chốt: đã có phần thông tin của quân). Nếu thấy khó nhận Bộ binh/Kỵ binh/Cung kỵ lúc đầu, bật lại bằng `SHOW_NAMES`.
3. **"Đã đi", "đã đánh" tô mờ mức nào?** Mặc định: đã đi hơi xỉn ngả đỏ, đã đánh xám nhạt rõ hơn. Có thể cần chỉnh khi nhìn trên hình quân thật.
4. **Bóng mờ xem trước đòn** (hiện khi rê chuột lên ô đánh) còn là đồng tròn mờ. Mặc định giữ đến 8.4. Nếu thấy chướng, đổi sang hình quân mờ ở story này (thêm khoảng nửa ngày).

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5

### Debug Log References

### Completion Notes List

- Đã làm: `UnitArt` (chọn hình theo loại + hướng, hướng quay về địch gần nhất, hòa thì id nhỏ, hết địch thì Đại Việt quay lên, Nguyên quay xuống); `UnitToken` vẽ hình đứng yên + bóng bằng hình + chấm máu giữ nguyên, tô "đã đi" `MOVED_TINT` / "đã đánh" `ATTACKED_TINT` bằng màu nhân của hình (không đụng `modulate` của token), `SHOW_NAMES = false` (nhãn tên vẫn có để test và bật lại); `BoardView` đặt hướng ở `_sync_tokens` và `add_reinforcement_token`. `FOOT_DROP = 18`, `SPRITE_FEET_Y = 62`; không đổi `TOKEN_LIFT`, `RADIUS`, `pick_cell`, `board_rect`.
- Đã bỏ các hằng không còn dùng: `DAI_VIET_MOVED_COLOR`, `ATTACKED_COLOR`, `SHADOW_*`, `BORDER_WIDTH` của `UnitToken` (kiểm grep, không nơi nào dùng). Giữ `DAI_VIET_COLOR`, `NGUYEN_COLOR` cho `PreviewView`.
- Test: thêm `test_unit_art.gd` và 5 test trong `test_board_view.gd`; không phải sửa test cũ nào (`name_text()` vẫn đúng vì nhãn chỉ ẩn). `tools/test.sh`: 947/947 đạt, ranh giới và kịch bản đạt.
- Ảnh chụp: `anh/8-3-tran1.png`, `anh/8-3-tran6.png`. Trận 6 thấy đủ 3 tướng, Kỵ binh, Cung kỵ; đầu quân hàng 0 không bị cắt, tiêu đề vẫn hiện, chấm máu đọc rõ, ô đỏ báo đòn vẫn nổi.
- **CHƯA chụp được:** quân "đã đi"/"đã đánh" cạnh quân nguyên lượt, quân trên bệ ô ải (trận 5), ô sáng cạnh quân. Lý do: chuột/phím giả của GoPeak không tác động vào game (ảnh không đổi dù đã bấm), nên không chọn được tướng. Tác giả cần tự kiểm các cảnh này (xem ghi chú bên dưới). Vì vậy Task 5 chưa tick.
- Chưa kiểm bằng mắt: Kỵ binh/Cung kỵ đứng sát nhau có đè chấm máu nhau không (trận 6 chỉ có hai quân này cách xa).
- Cách tác giả thử: `tools/chay.sh --tran=6`, chọn một tướng đi một ô, thấy tướng xỉn ngả đỏ nhẹ; cho đánh thì xám nhạt rõ hơn; trận 5 xem quân đứng trên bệ đá không lơ lửng.

### File List

- game/src/battle/unit_art.gd (+ .uid)
- game/src/battle/unit_token.gd
- game/src/battle/board_view.gd
- game/tests/test_unit_art.gd (+ .uid)
- game/tests/test_board_view.gd
- _bmad-output/implementation-artifacts/anh/8-3-tran1.png, 8-3-tran6.png

## Change Log

- 2026-11-01: Tạo story 8.3 (Ultimate context engine).
- 2026-11-01: Làm xong code và test (947/947), chuyển review; còn thiếu vài ảnh chụp (xem Completion Notes).
