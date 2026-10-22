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

- [x] **Task 5: Kiểm bằng mắt, tài liệu, commit** (AC: 1–7)
  - [x] 5.1 `tools/test.sh` xanh; ghi số test vào Debug Log.
  - [x] 5.2 `tools/chay.sh --dev --tran=thu_lao`: chọn Khoái, rê lên Bộ binh → thấy bóng mờ + máu sau đòn; rê ra → mất; bấm đánh → kết quả đúng như bóng. Chụp ảnh nếu lưu được (`anh/2-12-*.png`); không có ảnh thì **không đánh [x]**.
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

### Review Findings

Code review 2026-10-22 (Blind Hunter + Edge Case Hunter + Acceptance Auditor, diff `66c2108`). 8 phát hiện (1 HIGH, 2 MEDIUM, 5 LOW); mọi mục sửa được đã sửa trong cùng ngày, test `589/589` đạt. Bằng chứng thô ở `_bmad-output/implementation-artifacts/.review/2-12-*.md`.

- [x] [Review][Patch] HIGH-1: đổi tướng khi chuột đứng yên vẫn giữ bóng của tướng cũ — `_select` không xóa ô đã xem trước nên `_update_preview` thấy `cell == _preview_cell` và bỏ qua. Sửa: `_select` đặt `_preview_cell = NO_CELL` rồi mới chọn + gọi `_on_cell_hovered` để tính lại. Bằng chứng: bỏ dòng đó → `test_preview_follows_general_switch_without_moving_pointer` trượt (78/79). [game/src/battle/battle_view.gd:407-415]
- [x] [Review][Patch] MEDIUM-1: bóng chỉ tắt khi phát xong, còn nguyên trong lúc hoạt ảnh chạy trên bàn cũ — `_on_events_resolved` gọi `_clear_preview()` ngay khi bắt đầu phát. Bằng chứng: bỏ dòng đó → `test_preview_clears_when_attack_animation_starts` trượt. [game/src/battle/battle_view.gd:206-212]
- [x] [Review][Patch] MEDIUM-2: AC 1/AC 6 chưa có bằng chứng hình ảnh — chạy game thật ở 3 trận, lưu 13 ảnh `anh/2-12-*.png`, đo pixel (đĩa bóng trên ô trống tương phản 5,56:1 so với nền ô; hai ảnh rê cùng ô giống hệt từng pixel), thêm test thứ tự lớp cho AC 6. Tác giả vẫn cần nhìn để chốt độ mờ (xem Completion Notes).
- [x] [Review][Patch] LOW-1: test yếu — `BoardFixture.picture()` chỉ so `id@ô:máu`, `can_undo()` được khẳng định khi nó vốn đã false, test bóng chỉ có một quân. Thêm `test_preview_keeps_existing_undo_snapshot` (đi trước → xem trước → hủy → so cả bàn), siết `test_preview_matches_real_attack` (đúng 1 bóng, so ô + máu), thêm `test_preview_shows_every_affected_unit` (đòn đẩy va quân chắn: 2 bóng, 2 mức máu). [game/tests/test_battle_controller.gd:365-376]
- [x] [Review][Patch] LOW-2: thiếu test cho Q1 (quân chết: máu 0), Q3 (bóng còn khi chờ xác nhận) và ca "lao trúng tướng mình đứng chắn" — đã có trong 3 test mới: `test_preview_follows_general_switch_without_moving_pointer`, `test_preview_stays_while_waiting_for_confirmation`, `test_preview_shows_every_affected_unit`.
- [x] [Review][Patch] LOW-3: `add_child(Node2D.new())` rác trong `board_view.gd` — đã bỏ. [game/src/battle/board_view.gd:250-262]
- [x] [Review][Patch] LOW-4: Task 5.3 khai khống "đúng những bước đã chạy" khi 5.2 chưa chạy được — 5.2 giờ chạy thật, hướng dẫn dưới đây viết lại theo đúng 9 bước đã thực hiện (ghi cả trận và ô).
- [x] [Review][Patch] LOW-5: `game/.bak_preview_view.gd` còn sót — không còn trong cây làm việc.
- [x] [Review][Defer] Bóng của quân **bị đánh tại chỗ** vẽ đè lên tên quân thật (cùng cỡ chữ, alpha 0.5) nên tên đậm hơn một chút; số máu đã được đẩy lên trên đồng để không chồng số thật. Không tự sửa vì chưa biết tác giả thấy có khó đọc không — xem `anh/2-12-2` và `2-12-3` rồi quyết. Ghi vào `deferred-work.md`.

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- `tools/test.sh`: **589/589 đạt** (trước story: 577; đợt đầu 583; đợt sửa review thêm 6 test), 81 kịch bản đã duyệt, kiểm ranh giới + quét project đạt.
- Báo động oan (ghi lại để phiên sau khỏi mất thời gian): thêm script có `class_name` thì lần chạy đầu báo `resources still in use` + rò `FontAdvanced`; chạy `--headless --path game --import` một lần là sạch, không phải rò thật.
- Không dùng được công cụ `capture_screenshot` của GoPeak trong phiên này (nhóm `testing` không hiện). Đã bơm chuột qua cổng runtime 7777 của game (`inject_mouse_motion`, `inject_mouse_click`) và chụp bằng `capture_screenshot` của chính runtime (ra file PNG 1280×720). Bài học: `inject_key` của runtime chỉ đặt `keycode`, mà `BattleInput` so `physical_keycode` → phím chọn tướng phải bơm qua XTest (X11); nút HUD cần **cả press lẫn release**, thiếu release thì nút không kêu.
- Kiểm ngược hai bản sửa review (đã khôi phục nguyên trạng, chạy lại 589/589): bỏ `_clear_preview()` trong `_on_events_resolved` → 1 test trượt; bỏ `_preview_cell = NO_CELL` trong `_select` → 1 test trượt.
- Đo bằng ảnh (không chỉ bằng dữ liệu): rê trong cùng một ô 3 lần → `preview_computations` 1 → 1, ảnh giống hệt từng pixel; bóng trên ô trống: đĩa (89,85,78) trên nền ô (237,222,186); kết quả thật khớp bóng: Khoái còn 2 máu (thu_lao), Bộ binh ở (0,4) còn 1 máu (thu_ba_tuong), Bộ binh biến mất sau khi bị đẩy xuống sông (thu_day).

### Completion Notes List

- `BattleController`: `preview_result(command) -> {state, events}` (clone → `_resolve` → trả cả nhật ký, để view dựng bóng cho quân chết đuối đúng ô cuối); `preview(command) -> BattleState` là vỏ mỏng cho test/controller. Lệnh bị từ chối → `{}` / `null`; không phát signal, không đổi `_undo_snapshot`.
- `PreviewView` (mới): đĩa mờ màu phe + vòng sáng + tên quân + số máu, alpha 0.5; `moved == false` (quân bị đánh tại chỗ) thì số máu đặt **trên** đồng để không chồng số thật. `_clear_labels` gỡ khỏi cây trước khi `queue_free` (nhãn cũ không kịp chồng lên nhãn mới khi rê nhanh).
- `BoardView`: tạo `PreviewView` ngay sau `_world`, trước viền mục tiêu và lớp số (AC 6) — có test so `get_index()`.
- `BattleView`: `_update_preview` chỉ tính lại khi **đổi ô** (AC 4), bỏ qua khi đang phát; `_ghosts_of` dựng bóng từ chênh lệch hai bản chụp, nhớ ô cuối từ `MOVED`/`DROWNED` cho quân biến mất; bóng tắt khi bỏ chọn, rê ra ngoài mục tiêu, bắt đầu phát, `_hide_info()`, `stop()`, hết trận.
- Câu hỏi Q1–Q3 (Dev Notes) đang chạy đúng như đề xuất: quân chết → bóng ở ô cuối, máu 0; có xem trước đòn đẩy; bóng vẫn hiện khi chờ xác nhận. Cả ba đã có test; **chờ tác giả xác nhận** khi chơi tay.
- **Đã kiểm bằng ảnh chụp, chưa có mắt người nhìn**: 13 ảnh trong `anh/2-12-*.png` chứng minh bóng hiện/đổi/mất, kết quả thật khớp bóng, không có bóng trong pha địch, rê cùng ô không nhấp nháy. Độ mờ/độ nổi và cảm giác "dễ đọc" thì tác giả chốt khi xem ảnh hoặc chơi.

**Hướng dẫn tác giả tự test (đúng 9 bước đã chạy):**

1. Gõ `tools/test.sh` → `589/589 test đạt`, `81 đã duyệt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`.
3. Bấm `1` chọn Khoái, rê lên **Bộ binh ở mép dưới (cột 4, hàng 7)**: hiện **bóng mờ** ngay trên đồng quân đó kèm số **0** — nghĩa là nó sẽ chết vì bị đẩy khỏi bàn (`2-12-2`).
4. **Giữ nguyên chuột**, bấm `2` đổi sang Lão: bóng phải **đổi ngay** sang Khoái (ô trên, số **2**) — lao của Lão trúng tướng mình đứng chắn, không phải Bộ binh (`2-12-3`). Đây là lỗi HIGH-1 đã sửa.
5. Rê ra ô trống: bóng biến mất (`2-12-4`). Rê lại vào Bộ binh rồi rê quanh trong **cùng ô**: bóng đứng yên, không nhấp nháy (`2-12-13`, `2-12-14`).
6. Bấm đánh: Khoái còn **2 máu**, đúng như bóng đã chỉ (`2-12-5`).
7. `tools/chay.sh --dev --tran=thu_ba_tuong`: bấm `1`, rê lên Bộ binh bên trái (cột 1, hàng 6) → bóng nằm ở **ô trống** phía trên, số **1** (`2-12-10`); bấm đánh → Bộ binh đứng đúng ô đó với **1 máu** (`2-12-12`).
8. `tools/chay.sh --dev --tran=thu_day`: Khoái đẩy Bộ binh xuống sông → bóng ở ô sông với số **0** (`2-12-7`); bấm đánh → quân biến mất khỏi bàn (`2-12-8`).
9. Bấm **Kết thúc lượt (Space)**: trong lúc quân Nguyên đi/đánh **không còn bóng xem trước nào** (`2-12-11`).

**Cần tác giả chốt:** nhìn `2-12-2` và `2-12-3` (bóng vẽ đè lên quân bị đánh tại chỗ) — tên quân có bị đậm/nhòe khó đọc không? Nếu khó đọc thì em bỏ tên trên bóng, chỉ giữ số máu.

### File List

- `game/src/battle/preview_view.gd` (mới) + `.uid`
- `game/src/battle/battle_controller.gd` (`preview_result`, `preview`)
- `game/src/battle/board_view.gd` (tạo `PreviewView`, `preview_view()`, xóa bóng khi đổi bàn, bỏ `Node2D` rác)
- `game/src/battle/battle_view.gd` (xem trước theo ô trỏ, đếm số lần tính, xóa bóng khi đổi tướng / bắt đầu phát)
- `game/tests/test_battle_controller.gd` (+2 test: không đụng state/undo, khớp kết quả thật, null khi bị từ chối)
- `game/tests/test_battle_view.gd` (+7 test: hiện/ẩn, đếm lần tính, khớp kết quả thật, đổi tướng khi chuột đứng yên, tắt khi bắt đầu phát, còn khi chờ xác nhận, đủ mọi quân bị ảnh hưởng, thứ tự lớp)
- `_bmad-output/implementation-artifacts/anh/2-12-*.png` (13 ảnh kiểm bằng mắt)
- `_bmad-output/implementation-artifacts/deferred-work.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-22: sửa 8 phát hiện code review (HIGH-1, MEDIUM-1/2, LOW-1..5), thêm 6 test, kiểm bằng mắt bằng 13 ảnh chụp thật; test 583 → 589.
