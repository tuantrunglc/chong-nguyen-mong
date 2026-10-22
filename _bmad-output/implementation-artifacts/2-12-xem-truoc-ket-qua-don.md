---
baseline_commit: ec9c3b8
---

# Story 2.12: Xem trước kết quả đòn

Status: review

## Story

Là người chơi,
tôi muốn thấy trước kết quả của đòn trước khi bấm,
để tính đúng mà không phải hoàn tác.

## Acceptance Criteria

1. **Cho** một tướng đang chọn, **khi** rê chuột lên một mục tiêu đánh được **thì** hiện bóng mờ ở vị trí cuối của **mọi quân bị ảnh hưởng** và số máu sau đòn (FR41, bản tối giản E2).
2. **Khi** bấm đánh thật **thì** kết quả khớp đúng với bản xem trước — có test so sánh hai kết quả.
3. **Khi** rời chuột khỏi mục tiêu **thì** bóng mờ biến mất.
4. **Và** xem trước chỉ chạy lại khi **đổi ô trỏ chuột**, không chạy mỗi khung hình (và không chạy lại khi rê trong cùng một ô).
5. **Và** xem trước chạy trên **bản sao** trạng thái, không sửa trạng thái trận và không đụng `src/core/` (ADR-005).
6. **Và** bóng mờ không che ô đỏ + số thứ tự đòn (NFR9): nằm trên đồng quân nhưng dưới lớp số.
7. **Và** có test chạy không cần màn hình qua `main.tscn` cho: bóng hiện/ẩn, khớp kết quả thật, số lần tính lại.

## Tasks / Subtasks

- [x] **Task 1: `BattleController.preview`** (AC: 2, 5)
  - [x] 1.1 `preview(command: Command) -> BattleState`: clone trạng thái sống, chạy `_resolve` trên bản sao, trả bản sao; lệnh bị từ chối thì `null`. Không đụng `_state`, không đổi `_undo_snapshot`, không phát signal.
  - [x] 1.2 Test: `preview` không làm đổi `snapshot()`; kết quả xem trước của một đòn bằng đúng bản chụp sau khi `submit` đúng đòn đó (so `BoardFixture.picture`).
  - [x] 1.3 Test: lệnh bị từ chối (đánh ô ngoài tầm) → `preview` trả `null`.

- [x] **Task 2: `PreviewView` — bóng mờ** (AC: 1, 3, 6)
  - [x] 2.1 File mới `game/src/battle/preview_view.gd` (`class_name PreviewView extends Node2D`): `show_ghosts(ghosts: Array[Dictionary])`, `clear()`, `ghosts() -> Array[Dictionary]` (để test). Mỗi ghost: `{pos: Vector2, type: int, hp: int, faction: int}`.
  - [x] 2.2 Vẽ: đĩa mờ màu phe (alpha ~0.45), chữ tắt loại quân, số máu; dùng `UnitToken.RADIUS`/màu để giống đồng quân thật nhưng mờ.
  - [x] 2.3 `BoardView` tạo `PreviewView` ngay sau `_world` (trên đồng quân, dưới `_target_layer` và lớp số) và gọi `clear()` trong `show_state`; thêm `preview_view()`.

- [x] **Task 3: Nối chuột** (AC: 1, 3, 4)
  - [x] 3.1 `BattleView._on_cell_hovered`: nếu có tướng đang chọn và ô là mục tiêu đánh được → `preview(Command.attack(...))` rồi dựng ghost từ bản chụp hiện tại (`_controller.snapshot()`) và bản xem trước. Ngoài ra → `clear()`.
  - [x] 3.2 Nhớ ô đã xem trước (`_preview_cell`) và bộ đếm `preview_computations()` cho test: rê trong cùng ô không tính lại (AC 4).
  - [x] 3.3 Bóng mờ tắt khi: bỏ chọn, rê sang ô không đánh được, bắt đầu phát hoạt ảnh, `stop()`, hết trận (giống `_hide_info`).
  - [x] 3.4 Ghost dựng từ chênh lệch hai bản chụp: quân có ô/máu khác đi → ghost ở ô **sau** đòn với máu sau đòn; quân biến mất (gục/chết đuối) → ghost ở ô **trước** đòn với máu 0.

- [x] **Task 4: Test giao diện** (AC: 1, 3, 7)
  - [x] 4.1 `game/tests/test_battle_view.gd`: chọn Khoái, rê lên Bộ binh trong tầm → `preview_view().ghosts()` không rỗng, có ô cuối và máu sau đòn; rê ra ô trống → rỗng.
  - [x] 4.2 Rê hai lần trong cùng một ô → `preview_computations()` tăng đúng 1; rê sang ô khác → tăng thêm 1.
  - [x] 4.3 Đánh thật đúng mục tiêu đó → bàn khớp với ghost đã hiện (so `ghosts()` trước khi bấm với trạng thái sau khi phát xong).
  - [x] 4.4 `game/tests/test_battle_controller.gd`: `preview` không đổi state; khớp kết quả thật; lệnh bị từ chối → null.

- [ ] **Task 5: Kiểm bằng mắt, tài liệu, commit** (AC: 1–7)
  - [x] 5.1 `tools/test.sh` xanh; ghi số test vào Debug Log.
  - [ ] 5.2 `tools/chay.sh --dev --tran=thu_lao`: chọn Khoái, rê lên Bộ binh → thấy bóng mờ + máu sau đòn; rê ra → mất; bấm đánh → kết quả đúng như bóng. Chụp ảnh nếu lưu được (`anh/2-12-*.png`); không có ảnh thì **không đánh [x]**.
  - [x] 5.3 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, đúng những bước đã chạy.
  - [x] 5.4 Commit tiếng Việt kết `(Story 2.12)`.

## Dev Notes

### Hiện trạng liên quan (đọc trước khi sửa)

- `game/src/battle/battle_controller.gd`: **chưa có `preview`**. `_resolve(state, command)` gọi `Rules.resolve`; `snapshot()` trả `clone()`; `events_resolved` phát trong `submit`.
- `game/src/core/rules.gd`: `resolve(state, command)` **sửa state tại chỗ** và trả `Array[BattleEvent]` — vì vậy xem trước bắt buộc chạy trên `clone()`.
- `game/src/battle/board_view.gd`: thứ tự con trong `_ready` (ô đỏ → chữ địa hình → `_world` đồng quân → viền mục tiêu → lớp số). `show_state` dựng lại bàn mỗi lệnh; `cell_center(cell)` là tâm mặt ô, `surface_height(kind)` là độ cao (ô ải/bướu); `UnitToken` đứng ở `cell_center - Vector2(0, lift)`.
- `game/src/battle/battle_view.gd`: `_on_cell_hovered` đã bị chặn khi `_playing` (2.11); `_selected`, `_targets`, `_cells`; `_deselect()`, `_hide_info()`, `_finish_playback()`, `stop()`.
- `game/src/battle/unit_token.gd`: màu/chữ/số máu để bóng mờ trông giống đồng thật (`RADIUS`, `DAI_VIET_COLOR`, `NGUYEN_COLOR`, `NAME_KEYS`, `HP_OFFSET`).
- `game/src/core/battle_state.gd`: `unit_by_id`, `units`, `terrain_at`, `in_bounds`; `Unit` có `cell`, `hp`, `type`, `faction`, `has_moved`, `has_attacked`.

### Luật kiến trúc phải theo

- **ADR-005:** xem trước = clone trạng thái, chạy lệnh trên bản sao, hiển thị kết quả. **Không** sửa trạng thái sống, không phát signal, không đụng `_undo_snapshot`.
- **Không đụng `src/core/`.** Nếu thấy cần thêm hàm vào core thì dừng và hỏi.
- **Luật ranh giới:** `check_boundaries.sh` cấm mọi chỗ ngoài `effects.gd` gán `.hp`/`.cell`. Bóng mờ là **dữ liệu hiển thị** (pos/type/hp/faction), không tạo `Unit` rồi sửa `hp`.
- Chữ hiển thị chỉ qua `tr()`; khóa mới vào `text.csv` và sinh lại `text.vi.translation` nếu cần chữ mới (bản này có thể không cần khóa mới).
- Đi xuống gọi hàm, đi lên phát signal; không Event Bus. `AppState` vẫn là autoload duy nhất.
- Không `Thread`; 1280×720; không lặp cứng cỡ bàn.

### Testing

- `tools/test.sh` là lệnh duy nhất; GUT qua `main.tscn` thật, trận thử ghi `user://`, xóa ở `after_each`.
- Trong phiên AI có sandbox: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`.
- Chạy một file: `.tools/godot-4.7.2/... --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_view.gd -gexit`
- Rê chuột trong test: dùng `InputEventMouseMotion` như các test hiện có (`_hover_by_mouse`), không gọi thẳng hàm private.
- **Bẫy của story này:** rất dễ tính lại xem trước mỗi lần `cell_hovered` phát (kể cả trong cùng ô), hoặc tính lại trong lúc phát hoạt ảnh (bản chụp đã đổi). Test đếm số lần tính là bắt buộc, nếu không AC 4 chỉ là lời nói.

### Previous Story Intelligence (2.11, 2.10)

- 2.11: `_on_cell_hovered` bị chặn khi `_playing`; `_finish_playback` mới là chỗ cập nhật lại mọi thứ theo ô đang trỏ. Đặt phần xem trước **cùng chỗ** với `_update_info` để không lệch nhịp.
- 2.11: `_hide_info()` đã gom "ẩn khung + bỏ nổi bật"; thêm `clear()` bóng mờ vào đó thay vì rải rác.
- 2.10: khung thông tin phải đứng yên trong lúc phát; bóng mờ cũng vậy (đừng đọc bản chụp sau lệnh khi đang phát).
- 2.9/2.8: đòn địch và đòn của tướng đều đi qua `Rules.resolve`; xem trước chỉ dùng cho **đòn của tướng đang chọn** (FR41), không xem trước pha địch.
- Lệ commit: một commit story, một commit code; lời tiếng Việt, kết `(Story X.Y)`.

### Git Intelligence

- Commit gần nhất: `ec9c3b8 Sửa theo code review Story 2.11`, `1195039 Hoạt ảnh phát lại sự kiện (Story 2.11)`, `b874ecd Rê chuột xem thông tin quân và ô (Story 2.10)`.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1, web đơn luồng.
- Một cú bấm chuột phải làm được mọi thao tác; rê chuột chỉ để xem.
- 1280×720, stretch `canvas_items`, aspect `keep`; font tiếng Việt đủ dấu.
- Commit khi test xanh, lời commit tiếng Việt.

### Câu hỏi cho tác giả (chốt trước khi code xong)

1. Quân **gục** trong bản xem trước: hiện bóng ở ô cũ với **máu 0**, hay không hiện gì? (đề xuất: bóng ở ô cũ, máu 0 — người chơi thấy rõ "nó chết").
2. Có xem trước cả **đòn đẩy** (quân bị đẩy sang ô khác) không? (đề xuất: có — đó là "vị trí cuối của mọi quân bị ảnh hưởng").
3. Bóng mờ có hiện khi **đang chờ xác nhận** (tướng đã đi, bấm lần đầu) không? (đề xuất: có, vì vẫn là rê lên mục tiêu).

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.12 (dòng 845–858), FR41.
- `_bmad-output/planning-artifacts/game-architecture.md`: ADR-005, "Xem trước" (dòng 282), cây `src/battle/preview_view.gd` (dòng 582), bảng công nghệ dòng 649.
- `_bmad-output/project-context.md` (Godot 4, không Thread, chữ qua `tr()`).
- `game/src/battle/battle_controller.gd`, `battle_view.gd`, `board_view.gd`, `unit_token.gd`, `game/src/core/rules.gd`, `game/src/core/battle_state.gd`, `game/tests/test_battle_controller.gd`, `game/tests/test_battle_view.gd`.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- `tools/test.sh`: 583/583 đạt (trước story: 577; thêm 3 test `test_battle_controller.gd` + 3 test trong `test_battle_view.gd`), 81 kịch bản đã duyệt, kiểm ranh giới đạt.
- Báo động oan: sau khi thêm `preview_view.gd`, chạy `--headless --quit-after` thấy `1 resources still in use at exit` + rò `FontAdvanced`. Truy ra KHÔNG phải rò thật: cache lớp toàn cục chưa có `PreviewView` nên script được nạp nửa vời. Chạy `--headless --path game --import` một lần là sạch; các lần sau cũng sạch. Ghi lại để phiên sau không mất thời gian: **thêm script có `class_name` thì phải `--import` trước khi chạy thử**.
- Kiểm ngược: bỏ `if cell == _preview_cell` → `test_preview_recomputes_only_when_target_changes` trượt (2 lần tính thay vì 1); đổi `_state.clone()` thành `_state` trong `preview` → `test_preview_does_not_touch_live_state` trượt (máu quân bị trừ vào trạng thái sống).

### Completion Notes List

- `BattleController.preview(command)`: clone trạng thái, chạy `Rules.resolve` trên bản sao, trả bản sao; lệnh bị từ chối thì `null`. Không phát signal, không đổi bản chụp hủy.
- `game/src/battle/preview_view.gd` (mới): vẽ đĩa mờ màu phe + chữ tắt + số máu cho danh sách ghost `{cell, pos, type, hp, faction}`; không đọc trạng thái, không tạo `Unit` (tránh luật "chỉ Effects sửa `.hp`/`.cell`). BoardView tạo nó **sau lớp đồng quân, trước viền mục tiêu và lớp số** để ô đỏ + số vẫn nổi nhất (NFR9); `show_state` xóa bóng cũ.
- `BattleView`: `_update_preview(cell)` tính lại **chỉ khi đổi ô** (AC 4), bỏ qua khi đang phát hoạt ảnh; bóng tắt khi bỏ chọn, rê ra ngoài mục tiêu, `_hide_info()`, `stop()`, hết trận. Bóng dựng từ chênh lệch hai bản chụp: quân đổi ô/mất máu → ô cuối + máu sau đòn; quân biến mất → ô cũ + máu 0.
- **Chưa kiểm bằng mắt (5.2)**: phiên AI không mở cửa sổ; bóng mờ đã đo bằng dữ liệu (đúng ô, đúng máu) nhưng chưa ai nhìn độ mờ/độ nổi.

**Hướng dẫn tác giả tự test:**

1. Gõ `tools/test.sh` → `583/583 test đạt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`.
3. Bấm `1` chọn Khoái, rê chuột lên một Bộ binh kề bên: thấy **bóng mờ** ở ô quân đó sẽ bị đẩy tới, kèm **số máu sau đòn**.
4. Rê sang quân khác: bóng đổi theo. Rê ra ô trống: bóng biến mất.
5. Bấm đánh: kết quả đúng như bóng đã chỉ (ô và máu).
6. Rê trong cùng một ô nhiều lần: bóng đứng yên, không nhấp nháy.
7. Trong lúc quân Nguyên đang ra đòn: không có bóng xem trước nào hiện.

### File List

- `game/src/battle/preview_view.gd` (mới) + `.uid`
- `game/src/battle/battle_controller.gd` (`preview`)
- `game/src/battle/board_view.gd` (tạo `PreviewView`, `preview_view()`, xóa bóng khi đổi bàn)
- `game/src/battle/battle_view.gd` (xem trước theo ô trỏ, đếm số lần tính)
- `game/tests/test_battle_controller.gd`, `game/tests/test_battle_view.gd`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
