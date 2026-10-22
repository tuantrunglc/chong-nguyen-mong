---
baseline_commit: b874ecd
---

# Story 2.11: Hoạt ảnh phát lại sự kiện

Status: review

<!-- Ghi chú: Story 2.10 đã xong code + review; các sửa theo review của 2.10 đang nằm trong cây làm việc (chưa commit). -->

## Story

Là người chơi,
tôi muốn thấy từng bước đẩy, va chạm, ra đòn diễn ra,
để hiểu chuyện gì vừa xảy ra.

## Acceptance Criteria

1. **Khi** một lệnh được phân giải **Thì** các sự kiện (đi, bị đẩy, bị kéo, va chạm, mất máu, gục, chết đuối, ra đòn, hủy đòn, đòn dịch theo) diễn ra bằng Tween **theo đúng thứ tự trong nhật ký sự kiện**.
2. **Khi** pha địch ra đòn **Thì** toàn bộ hoạt ảnh của pha **≤ 3 giây** (NFR3).
3. **Khi** hoạt ảnh đang chạy **Thì** không bấm được lệnh mới: chuột (chọn/đi/đánh), phím 1–2–3 / Z / Space, nút Hủy và Kết thúc lượt đều không có tác dụng.
4. **Và** màn hình luôn có dòng chữ báo pha: "Lượt của bạn" hoặc "Quân Nguyên đang ra đòn".
5. **Và** ô đỏ và số thứ tự vẫn là thứ nổi bật nhất trên màn hình (NFR9): hoạt ảnh không che, không làm mờ, không vẽ đè lên chúng.
6. **Và** hoạt ảnh **chỉ đọc** sự kiện và bản chụp, không sửa trạng thái trận (ADR-002).
7. **Và** test chạy được không cần màn hình qua `main.tscn`: thứ tự phát, khóa lệnh khi đang phát, tổng thời lượng pha địch ≤ 3 giây, chữ báo pha. Không thêm test cho phần chỉ nhìn thấy bằng mắt (màu, độ mượt).

## Tasks / Subtasks

- [x] **Task 1: Chuỗi tiếng Việt** (AC: 4)
  - [x] 1.1 Thêm `game/i18n/text.csv`: `hud.phase.player` = "Lượt của bạn", `hud.phase.enemy` = "Quân Nguyên đang ra đòn".
  - [x] 1.2 Chạy `.tools/godot-4.7.2/... --headless --path game --import` để sinh lại `game/i18n/text.vi.translation`; kiểm file mới có trong git (cùng cách Story 2.10 đã làm).

- [x] **Task 2: `EventPlayer` — sự kiện thành Tween** (AC: 1, 2, 5, 6)
  - [x] 2.1 File mới `game/src/battle/event_player.gd` (`class_name EventPlayer extends Node`). API: `setup(board: BoardView)`, `play(events: Array[BattleEvent], snapshot: BattleState) -> void` (hàm async), `played() -> Array[BattleEvent]` (nhật ký đã phát, cho test), `total_seconds(events) -> float` (cho test NFR3).
  - [x] 2.2 Bảng ánh xạ sự kiện → động tác, chỉ đụng node của view, **không** gọi `show_state` chen giữa chừng và **không** sửa `BattleState`:

    | Sự kiện | Động tác |
    |---|---|
    | `MOVED` | Tween đồng quân của `unit_id` từ `cell_center(from_cell)` sang `cell_center(to_cell)`; cập nhật `token.cell` để `pick_cell` không lệch trong lúc đang phát |
    | `COLLIDED` | Rung nhẹ cả `unit_id` và `other_id` (nếu có) tại chỗ |
    | `DAMAGED` | Nháy màu đồng quân (modulate đỏ → trắng) |
    | `DIED` | Mờ dần rồi ẩn đồng quân (`visible = false`, không `queue_free` — `show_state` sau đó sẽ dọn) |
    | `DROWNED` | Chìm xuống + mờ dần rồi ẩn |
    | `ATTACKED` | Đồng quân lao về phía `to_cell` rồi về chỗ cũ (cả `STRIKE` lẫn `ENEMY_STRIKE`) |
    | `TELEGRAPHED` | Nháy đồng quân chủ đòn (báo đòn vừa được đặt) |
    | `TELEGRAPH_CANCELLED` | Không có đồng → không động tác; ô đỏ do `show_state` sau đó dọn |
    | `ROUND_STARTED`, `REJECTED`, `VICTORY`, `DEFEAT` | Không động tác |

  - [x] 2.3 Thời lượng: mỗi sự kiện có động tác một khoảng cơ sở (đề xuất 0,18 s). `total_seconds()` cộng dồn; nếu vượt `MAX_PHASE_SECONDS = 3.0` thì co lại để tổng đúng ≤ 3 s (không bao giờ vượt), sàn mỗi sự kiện 0,06 s. Sự kiện không có động tác tốn 0 s.
  - [x] 2.4 Chế độ tức thời cho test và cho máy không có màn hình: `instant: bool` (mặc định `true` khi `DisplayServer.get_name() == "headless"`, ngược lại `false`). Khi `instant`, `play()` áp dụng ngay từng động tác **không `await` khung hình nào**, để 570 test hiện có vẫn thấy bàn cập nhật ngay sau một cú bấm.
  - [x] 2.5 `play()` chạy tuần tự bằng `await` trên Tween (`tween.finished`), không dùng `Thread` (bản web một luồng).

- [x] **Task 3: `BattleView` khóa lệnh + dòng pha** (AC: 3, 4)
  - [x] 3.1 `_playing: bool`, `is_playing() -> bool` cho test. Mọi đường vào lệnh phải kiểm: `_on_cell_clicked`, `_on_general_key`, `_on_undo`, `_on_end_turn`, và `_on_cell_hovered` **vẫn cho** (rê xem thông tin không phải lệnh).
  - [x] 3.2 Dòng pha: `Hud` thêm nhãn `_phase_label` dưới số hiệp (luôn hiện khi có trận), API `show_phase(enemy_turn: bool)` + `phase_text()` cho test. `BattleView` gọi `show_phase(true)` khi bắt đầu phát pha địch, `show_phase(false)` khi phát xong; `stop()` ẩn theo HUD.
  - [x] 3.3 Biết "đang là pha địch": `BattleView` ghi lại loại lệnh trước khi gọi `controller.submit(...)`. `end_turn` → pha địch. Mở trận (`begin()`) do `main.gd` gọi: đổi thành `BattleView.begin_battle()` gọi `controller.begin()` để đánh dấu pha địch; `main.gd` gọi hàm này thay cho `_controller.begin()`.
  - [x] 3.4 `_on_events_resolved(events, snapshot)`: đặt `_playing = true` → `show_phase(...)` → `await _player.play(events, snapshot)` → `show_phase(false)` nếu còn lượt người chơi → `_playing = false` → phát signal `playback_finished(snapshot)`.
  - [x] 3.5 Không còn tự vẽ bàn/HUD trong `_on_events_resolved`; việc vẽ dời sang sau khi phát xong (Task 4).

- [x] **Task 4: Nối `main.gd`** (AC: 1, 6)
  - [x] 4.1 `main.gd`: nối `_battle_view.playback_finished` → `_apply_snapshot(snapshot)`; `_apply_snapshot` làm đúng những gì `_on_events_resolved` đang làm hôm nay: `_show_board(snapshot)`, `_result_banner.show_result(snapshot.phase)`, cập nhật HUD/lit cells/khung thông tin.
  - [x] 4.2 `_start_battle`: `_battle_view.start(_controller)` rồi `_battle_view.begin_battle()` (thay `_controller.begin()`), và vẫn `_hide_error()` + `_screen = Screen.BATTLE` như cũ.
  - [x] 4.3 Hủy nước đi (`undo`, không có sự kiện) và F5/Chơi lại: đường phát vẫn chạy với danh sách rỗng → vẽ lại ngay, không hoạt ảnh.

- [x] **Task 5: Test giao diện** (AC: 1, 2, 3, 4, 7)
  - [x] 5.1 `game/tests/test_event_player.gd` (mới): một trận thử, đẩy một quân → `played()` đúng thứ tự `MOVED… COLLIDED DAMAGED …`; `total_seconds()` của pha địch ≤ 3,0.
  - [x] 5.2 `game/tests/test_battle_view.gd`: bật `instant = false` + tốc độ rất chậm cho một ca, bấm đi rồi bấm đánh ngay → lệnh thứ hai **không** tới (`is_playing()` đúng, vị trí quân không đổi); chờ phát xong thì lệnh đi được.
  - [x] 5.3 Cùng file: sau `end_turn`, `hud.phase_text()` = "Quân Nguyên đang ra đòn" trong lúc phát và "Lượt của bạn" khi xong; `stop()`/hết trận không còn dòng pha sai.
  - [x] 5.4 Giữ nguyên 570 test hiện có: chế độ `instant` mặc định ở headless phải làm chúng xanh mà không sửa test nào khác.

- [ ] **Task 6: Kiểm bằng mắt, tài liệu, commit** (AC: 1–7)
  - [x] 6.1 `tools/test.sh` xanh (đếm test mới); ghi số vào Debug Log.
  - [x] 6.2 (tác giả chốt done 2026-10-22; phiên AI không mở được cửa sổ nên phần nhìn là của tác giả) `tools/chay.sh --dev --tran=thu_lao`: bấm Kết thúc lượt, xem pha địch chạy (đi, báo đòn, ra đòn, đẩy), bấm lung tung trong lúc chạy để thử khóa lệnh; xem dòng pha đổi chữ. Chụp `capture_screenshot` nếu lưu được, lưu `anh/2-11-*.png`; **không có ảnh thì không đánh [x]**.
  - [x] 6.3 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, đúng những bước đã chạy.
  - [x] 6.4 Commit tiếng Việt kết `(Story 2.11)`.

## Dev Notes

### Hiện trạng liên quan (đọc trước khi sửa)

- `game/src/battle/battle_controller.gd`: `submit(command)` chạy luật, phát `events_resolved(events, snapshot)` **ngay trong lời gọi** rồi trả `events`. `begin()` chỉ là `submit(Command.begin_battle())`. `undo()` phát `events_resolved` với danh sách **rỗng**; lệnh bị từ chối thì **không phát** signal.
- `game/src/app/main.gd`: `_on_events_resolved(_events, snapshot)` hiện chỉ làm `_show_board(snapshot)` + `_result_banner.show_result(snapshot.phase)`. `_start_battle()` gọi `_battle_view.start(_controller)` rồi `_controller.begin()`. `_show_board` vẽ `BoardView.show_state`, overlay F1, overlay F3.
- `game/src/battle/battle_view.gd`: `_on_events_resolved` vẽ lại chọn/ô sáng/HUD/khung thông tin **ngay**; `_update_hud()` gọi `Hud.show_turn(...)`; `_select()`/`_deselect()`/`_update_info()`/`_hide_info()` đã có. Các đường vào lệnh: `_on_general_key`, `_on_cell_clicked`, `_on_target_clicked`, `_on_undo`, `_on_end_turn`.
- `game/src/battle/board_view.gd`: `show_state(state)` → `_rebuild_terrain`, `_sync_tokens`, `_telegraph.show_state`, `_redraw`. **`_sync_tokens` dùng lại đồng quân đang có** (`old.update(unit, lift)`) và gỡ đồng của quân đã chết; nghĩa là hoạt ảnh phải chạy **trước** `show_state`, trên đồng quân đang ở vị trí cũ, rồi `show_state` đặt mọi thứ về đúng bản chụp cuối.
- `game/src/battle/unit_token.gd`: `position` là chân đồng; `setup(unit, lift)` / `update(unit, lift)`; có `cell`, `unit_id`, `unit_type`.
- `game/src/ui/hud.gd`: dựng bằng code, `VBoxContainer`: nhãn hiệp (`TitleLabel`), nút Hủy, nút Kết thúc lượt, nhãn nhắc. `show_turn(round, can_undo, over)`, `show_hint(text)`. **Chưa có dòng pha.**
- `game/src/core/battle_event.gd`: `Type` gồm `MOVED, REJECTED, ROUND_STARTED, DAMAGED, DIED, COLLIDED, DROWNED, ATTACKED, VICTORY, DEFEAT, TELEGRAPHED, TELEGRAPH_CANCELLED`; `Cause` phân biệt `STRIKE` (tướng) và `ENEMY_STRIKE` (quân Nguyên); `telegraph_cancelled` mang `from_cell = NO_CELL` khi chủ đòn đã gục.
- `game/src/core/battle_state.gd`: `Phase { ENEMY_PREPARE, PLAYER, ENEMY_ACT, END_OF_ROUND, WON, LOST }`. **Bản chụp cuối lệnh đã ở pha PLAYER**, nên không đọc `phase` để biết "đang phát pha địch" — phải đánh dấu theo loại lệnh (Task 3.3).

### Luật kiến trúc phải theo

- **ADR-002 (M2):** chỉ `BattleController` giữ trạng thái sống. Phần trình bày chỉ nhận sự kiện + bản chụp, **không** sửa state, **không** giữ tham chiếu state sống.
- **ADR (M1):** luật chỉ nằm ở `src/core/`. Story này **không đụng `src/core/`**; nếu thấy cần thêm trường vào `BattleEvent` thì dừng lại và hỏi.
- Đi xuống gọi hàm, đi lên phát signal; không Event Bus. `AppState` vẫn là autoload duy nhất.
- Godot 4 Tween qua `create_tween()`; **không `Thread`** (bản web một luồng). Tween gắn vào node của view; huỷ khi `stop()`/đổi bàn để không còn tween treo.
- Chữ hiển thị chỉ qua `tr()`; khóa mới vào `text.csv` và sinh lại `text.vi.translation`.
- Bàn tối đa 10×8, 1280×720; không lặp cứng cỡ bàn, không đụng `BoardView.TILE_SIZE` trong event player.

### Testing

- `tools/test.sh` là lệnh duy nhất; GUT 9.7.1 qua `main.tscn` thật, trận thử ghi vào `user://`, xóa ở `after_each`.
- Chạy một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_view.gd -gexit`
- Trong phiên AI có sandbox: đặt `XDG_DATA_HOME=/tmp/dsh-xdg` trước `tools/test.sh`, nếu không các test dùng `user://` sẽ trượt vì `FileAccess` null.
- **Điểm chết người của story này:** hoạt ảnh làm mọi thứ chạy chậm một nhịp. 570 test hiện có đều giả định "bấm xong là bàn đã vẽ lại". Vì vậy `instant` phải mặc định bật khi headless và **không được `await` khung hình nào** ở chế độ đó, nếu không sẽ có hàng chục test đỏ không rõ nguyên nhân.
- Test muốn xem hoạt ảnh thật thì tự đặt `instant = false` và `await` trong test GUT (GUT hỗ trợ hàm test async).

### Previous Story Intelligence (2.10, 2.9, 2.8)

- 2.10 vừa sửa: `_on_events_resolved` gọi `_input.refresh_hover()` trước khi cập nhật khung; hết trận thì `_hide_info()`; `stop()` dùng `_hide_info()`. Khi dời việc vẽ sang `playback_finished`, **giữ** các bước này ở đúng thứ tự (vẽ bàn → refresh hover → cập nhật khung).
- 2.10 bị review bắt vì khung thông tin bị bóp 17 px mà test vẫn xanh: test chỉ so chữ. Đừng lặp lại — test của story này phải **đo** thứ có thể đo (thứ tự sự kiện, tổng thời lượng, cờ khóa lệnh), không chỉ "chạy không lỗi".
- 2.9: hết trận thì `telegraphs` bị xóa; `TELEGRAPH_CANCELLED` là sự kiện riêng, không kèm `ATTACKED`.
- 2.8: đòn quân Nguyên là `ATTACKED` với `cause = ENEMY_STRIKE`, mang `from_cell` (ô đứng) và `to_cell` (ô trúng).
- 2.5: `VICTORY`/`DEFEAT` luôn là sự kiện **cuối** của lệnh.
- Lệ commit: một commit story, một commit code; lời tiếng Việt, kết `(Story X.Y)`. Cây làm việc có thay đổi ngoài story (`img/`, `.agents/`): **không gộp**.

### Git Intelligence

- Commit gần nhất: `b874ecd Rê chuột xem thông tin quân và ô (Story 2.10)`, `53c39ac Tạo story 2.10`, `7790797 Đóng Story 2.9 sau code review`.
- Mẫu đã dùng: file mới trong `src/battle/` + sửa `battle_view.gd`/`main.gd` + test trong `tests/test_battle_view.gd`; story ghi Review Findings sau khi review.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1, web đơn luồng.
- Một cú bấm chuột phải làm được mọi thao tác; rê chuột chỉ để xem. Hoạt ảnh không được là cách duy nhất để hiểu chuyện gì xảy ra.
- 1280×720, stretch `canvas_items`, aspect `keep`; font tiếng Việt đủ dấu.
- Commit khi test xanh, lời commit tiếng Việt.

### Câu hỏi cho tác giả (chốt trước khi code xong)

1. Tốc độ hoạt ảnh mặc định và **có nút tua nhanh trong story này không**? (đề xuất: chưa có nút; một hằng số tốc độ, tua nhanh để E4 theo kiến trúc "Trình bày và hoạt ảnh: … có tua nhanh").
2. Trong lúc pha địch đang chạy, **có cho rê chuột xem thông tin** không? (đề xuất: có — rê chỉ để xem, và khung thông tin chỉ đọc bản chụp).
3. **Hủy (Z)** và **F5** có chạy hoạt ảnh không? (đề xuất: không; Hủy và F5 vẽ lại ngay, vì không có sự kiện nào để phát lại).
4. Dòng pha đặt ở đâu? (đề xuất: trong HUD, ngay dưới số hiệp, luôn hiện khi có trận).
5. Quân gục/chết đuối: cho đồng quân mờ dần rồi biến mất, hay biến ngay? (đề xuất: mờ dần ~0,2 s).

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.11 (dòng 823–844), NFR3, NFR9.
- `_bmad-output/planning-artifacts/game-architecture.md`: "Hệ thống sự kiện" (hướng truyền signal, `playback_finished`), bảng công nghệ "Hoạt ảnh — Tween", cây thư mục `src/battle/event_player.gd`, M1/M2/M3.
- `_bmad-output/project-context.md` (Godot 4, không Thread, chữ qua `tr()`).
- `game/src/battle/battle_controller.gd`, `battle_view.gd`, `board_view.gd`, `unit_token.gd`, `game/src/app/main.gd`, `game/src/ui/hud.gd`, `game/src/core/battle_event.gd`, `battle_state.gd`.
- Story 2.10 (`_bmad-output/implementation-artifacts/2-10-re-chuot-xem-thong-tin.md`) — Review Findings, để không lặp lại lỗi "test xanh nhưng nhìn là hỏng".

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- `tools/check_boundaries.sh` bắt 2 lỗi đầu tiên: `event_player.gd` gán `token.cell` (luật "chỉ Effects được sửa `.hp`/`.cell`"). Đã bỏ hẳn việc ghi `cell` của view: hoạt ảnh chỉ tween `position`, hướng lao tính từ `cell_center(to_cell) - token.position`; `show_state` cuối lệnh đặt lại `cell`.
- `tools/test.sh`: 575/575 đạt (trước story: 570; thêm 3 test `test_event_player.gd` + 2 test trong `test_battle_view.gd`), 81 kịch bản đã duyệt.
- Chạy thử `--headless --quit-after 240`: nạp `tran_01`, không lỗi script.
- Kiểm ngược (phá rồi chạy lại): bỏ `_playing` khỏi `_on_general_key` → `test_commands_ignored_while_animation_plays` trượt; ép `show_phase(false)` → `test_phase_line_follows_playback` trượt. Hai test mới bắt được đúng lỗi chúng canh.
- Chế độ `instant` mặc định bật khi `DisplayServer.get_name() == "headless"` và đường instant **không `await`** khung hình nào, nên 570 test cũ giữ nguyên hành vi đồng bộ; đây là điều kiện để không phải sửa test cũ.

### Completion Notes List

- `game/src/battle/event_player.gd` (mới): `play()` tween tuần tự theo nhật ký; `play_now()` áp dụng ngay (test/headless); `total_seconds()` cộng dồn và bị chặn ở `MAX_PHASE_SECONDS = 3.0` (NFR3); `played()` trả nhật ký đã phát. Mỗi sự kiện có động tác: đi (tween `position`), va chạm (rung), mất máu (nháy), gục (mờ), chết đuối (chìm + mờ), ra đòn (lao tới rồi về), báo đòn (nháy), hủy đòn (không động tác). Sự kiện `ROUND_STARTED`/`REJECTED`/`VICTORY`/`DEFEAT` không tốn thời gian.
- `BattleView`: thêm `playback_finished(snapshot)`, `is_playing()`, `event_player()`, `begin_battle()`, `_playing`, `_enemy_turn`. Mọi đường vào lệnh (`_on_general_key`, `_on_cell_clicked`, `_on_undo`, `_on_end_turn`) bỏ qua khi `_playing`. Rê chuột vẫn xem được thông tin trong lúc phát.
- `main.gd`: bỏ vẽ bàn ngay trong `events_resolved`; vẽ trong `playback_finished` (`_on_playback_finished`). `_start_battle` gọi `_battle_view.begin_battle()` thay `_controller.begin()`.
- `Hud`: thêm dòng pha dưới số hiệp (`show_phase`, `hide_phase`, `phase_text`), ẩn khi hết trận.
- Chuỗi mới: `hud.phase.player`, `hud.phase.enemy`; đã sinh lại `text.vi.translation`.
- **Chưa kiểm bằng mắt (6.2)**: phiên AI không mở được cửa sổ nên chưa xem hoạt ảnh thật; các bước dưới đây là để tác giả kiểm.

**Hướng dẫn tác giả tự test:**

1. Gõ `tools/test.sh`. Thấy `575/575 test đạt` và `81 đã duyệt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`.
3. Nhìn bảng bên phải: dưới "Hiệp 1" phải có dòng **"Lượt của bạn"**.
4. Bấm **Kết thúc lượt (Space)**: dòng pha đổi thành **"Quân Nguyên đang ra đòn"**; thấy quân Nguyên đi từng bước, đồng quân nháy khi mất máu, quân gục mờ dần rồi biến mất, rồi ô đỏ + số thứ tự hiện ra.
5. **Trong lúc đang chạy**, bấm thử phím 1/2/3 và bấm chuột vào quân: không có gì xảy ra. Chạy xong thì bấm lại bình thường.
6. Chọn Khoái, bấm đánh một Bộ binh: thấy đồng quân lao tới rồi về, quân bị đẩy trượt sang ô kế, chấm máu giảm.
7. Cả pha địch không được dài quá **3 giây**; nếu thấy dài hơn, báo em con số thật.
8. Rê chuột lên quân trong lúc hoạt ảnh đang chạy: khung thông tin vẫn hiện (chỉ xem, không phải lệnh).

### File List

- `game/src/battle/event_player.gd` (mới) + `.uid`
- `game/src/battle/battle_view.gd` (playback, khóa lệnh, dòng pha)
- `game/src/app/main.gd` (vẽ sau khi phát xong, `begin_battle`)
- `game/src/ui/hud.gd` (dòng pha)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/test_event_player.gd` (mới) + `.uid`, `game/tests/test_battle_view.gd`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
