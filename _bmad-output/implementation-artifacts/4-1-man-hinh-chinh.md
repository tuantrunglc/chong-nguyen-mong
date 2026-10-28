---
baseline_commit: 0c484a2
---

# Story 4.1: Màn hình chính

Status: review

## Story

Là người chơi,
tôi muốn có màn hình chính để bắt đầu hoặc chơi tiếp,
để vào game như một game thật.

## Acceptance Criteria

1. **Khi** mở game (không có `tran` hợp lệ) **thì** hiện màn hình chính, không hiện bàn cờ, HUD hay tiêu đề trận (FR45):
   - Có tên game (`tr("app.title")`), dòng phụ đề "Kháng chiến chống Nguyên Mông, 1288", nút **"Chơi mới"**, nhãn phiên bản góc dưới phải như hiện nay. Không ảnh nền, không nút "Về menu" trong trận (tác giả chốt 2026-10-28).
   - Bấm "Chơi mới" thì vào trận 1 (`tran_01`), như cách trận 1 mở hôm nay (pha địch chuẩn bị hiệp 1 chạy, rồi tới lượt người chơi).
   - Chữ đi qua `tr()` (khóa mới trong `i18n/text.csv`), làm được chỉ bằng chuột (NFR8).
2. **Và** chưa có nút "Chơi tiếp": nút đó làm ở Story 4.3 (cần file lưu). Không dựng nút ẩn hay chỗ trống cho nó; chỉ để menu dễ thêm một nút phía trên "Chơi mới" sau này.
3. **Khi** chạy với `?tran=N` (web) hoặc `--tran=N` (desktop) **và** đã bật dev **thì** bỏ qua màn hình chính, vào thẳng trận N (tên file trận như `thu_muu_ke` cũng vậy).
   - Không bật dev thì `tran` đã bị bỏ (`LaunchOptions.require_dev_for_tran`, có cảnh báo trong log) → hiện màn hình chính.
   - Bật dev mà không có `tran` → hiện màn hình chính.
4. **Và** các đường về menu có sẵn dẫn tới màn hình chính thật: nút "Về menu" của màn hình lỗi dữ liệu (`ErrorScreen.back_pressed` → `_show_menu`).
5. **Và** ở màn hình chính, phím tắt trận (`Space`, `Z`, `R`, `Q`, `W`, chuột trên bàn) không làm gì, không ghi lệnh, không có lỗi trong log. F1/F3 không làm gì (đã chặn theo `_screen`). F2 vẫn chép được báo lỗi "không có trận". F5 giữ hành vi kiến trúc đã chốt: nạp lại dữ liệu và mở lại trận từ đầu ở mọi màn hình (trận đang chọn, chưa có thì trận 1).
6. **Và** `tools/test.sh` xanh; test GUT mới cho màn hình chính; commit tiếng Việt kết `(Story 4.1)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–2** (2026-10-28) — xem "Quyết định của tác giả".

- [x] **Task 1: `src/ui/main_menu.gd`** (AC: 1, 2)
  - [x] 1.1 `class_name MainMenu extends Control`, **dựng bằng code** như `ErrorScreen`/`Hud`/`ResultBanner` (dự án chưa có scene UI nào ngoài `main.tscn`; kiến trúc liệt kê `main_menu.tscn` nhưng theo mẫu code hiện có thì không cần — ghi lý do trong Completion Notes).
  - [x] 1.2 `signal new_game_pressed`. Nút "Chơi mới" có hàm truy cập cho test (`new_game_button() -> Button`, như `Hud.end_turn_button()`).
  - [x] 1.3 Màu và chữ theo Theme chung (`assets/theme/main_theme.tres`, `TitleLabel`); màu nền theo bảng màu `ErrorScreen` (gỗ tối). Phủ vùng màn hình 1280×720 (`BoardView.viewport_size`).
  - [x] 1.4 Khóa chữ mới trong `i18n/text.csv` (`menu.new_game,Chơi mới`, `menu.subtitle,"Kháng chiến chống Nguyên Mông, 1288"` — có dấu phẩy nên phải để trong ngoặc kép), chạy lại bước sinh `text.vi.translation` như Story 3.12/3.13.

- [x] **Task 2: `src/app/main.gd` đổi màn** (AC: 1, 3, 4, 5)
  - [x] 2.1 `_ready()`: thay `_start_battle()` cuối hàm bằng: `AppState.launch.level_id()` khác rỗng → `_start_battle()`; rỗng → `_show_menu()`. (Dev đã được ép ở `AppState._ready` qua `require_dev_for_tran`, nên chỉ cần xét `level_id()`.)
  - [x] 2.2 `_start_battle()` nhận trận cần mở: bỏ `DEFAULT_TRAN` khỏi chỗ đọc `launch`; "Chơi mới" gọi mở `tran_01`. F5 (`_reload_data`) mở lại `_level_id` đang có, chưa có thì `tran_01`. Giữ nguyên thứ tự nạp (chỉ số + trận, liệt kê đủ lỗi của cả hai) và mọi log hiện có.
  - [x] 2.3 `_show_menu()`: dừng trận như hiện nay (`_controller = null`, `_battle_view.stop()`, ẩn bảng kết quả, xóa bàn), **ẩn** bàn cờ, tiêu đề trận, tooltip; hiện `MainMenu`. Rời menu (vào trận, màn hình lỗi) thì ẩn menu. Giữ log `"về menu"`.
  - [x] 2.4 Nhãn phiên bản và chữ DEV vẫn nằm trên mọi màn (thứ tự con: menu phải nằm dưới nhãn phiên bản).
  - [x] 2.5 Đổi chú thích "Menu tạm cho tới story 4.1" và comment `DEFAULT_TRAN`.

- [x] **Task 3: Sửa test cũ bị ảnh hưởng** (AC: 6)
  - [x] 3.1 Mọi test dựng `main.tscn` với `AppState.launch.tran = ""` mà chờ trận 1 mở ngay sẽ thấy menu thay vì trận: `test_main.gd`, `test_battle_view.gd`, `test_board_view.gd`, `test_stratagem_view.gd` (và soát `grep -rn "main.tscn" game/tests`). Cách sửa: đặt `AppState.launch.tran = "1"` trong `_make_main` (hoặc bấm nút "Chơi mới" khi test chính là đường vào trận). `after_each` đã trả `tran = ""`.
  - [x] 3.2 **Không** đổi ý nghĩa test cũ (chỉ đổi đường vào trận). Test nào khẳng định "không chọn trận thì mở trận 1" phải đổi thành khẳng định hiện menu — ghi rõ trong Completion Notes test nào đổi ý nghĩa.

- [x] **Task 4: Test mới** (AC: 1–5) — trong `test_main.gd` hoặc file mới `test_main_menu.gd`:
  - [x] 4.1 Không `tran`: `_screen == MENU`, có `MainMenu` hiện, bàn cờ và HUD ẩn, `_controller == null`, nút "Chơi mới" có chữ `tr("menu.new_game")`.
  - [x] 4.2 Bấm "Chơi mới" (`pressed.emit()`): `_screen == BATTLE`, `_level_id == "tran_01"`, menu ẩn, bàn cờ hiện, log có `"nạp trận tran_01"`.
  - [x] 4.3 Có `tran = "3"` (dev): vào thẳng trận 3, không dựng menu (hoặc menu ẩn).
  - [x] 4.4 Ở menu: gửi phím `Space`, `Z`, `R`, `Q`, `W` qua `BattleInput._unhandled_input` → không có lỗi/cảnh báo trong `Log.get_lines()`, vẫn ở menu.
  - [x] 4.5 Màn hình lỗi → "Về menu" → `MainMenu` hiện. Từ menu bấm "Chơi mới" sau khi trận lỗi đã sửa: vào được trận (bảo đảm không giữ dữ liệu cũ).
  - [x] 4.6 F5 ở menu (dev): mở trận 1 (hoặc `_level_id` cũ) như kiến trúc.

- [x] **Task 5: Kiểm tra và bàn giao** (AC: 6)
  - [x] 5.1 `tools/test.sh` xanh 4/4.
  - [x] 5.2 Chụp màn hình GoPeak: `tools/chay.sh --dev` (không `--tran`) → màn hình chính; bấm "Chơi mới" bằng `inject_mouse_click` → trận 1. `tools/chay.sh --dev --tran=3` → vào thẳng trận 3.
  - [x] 5.3 Hướng dẫn tác giả thử tay bằng tiếng Việt trong Completion Notes (desktop và bản web: mở link itch **không** có `?dev=1` phải thấy màn hình chính).
  - [x] 5.4 Cập nhật story, `sprint-status.yaml` (và `epic-4: in-progress`); commit. Deploy itch **chỉ khi tác giả cho phép** — chưa deploy.

## Dev Notes

### Nguồn

- Epics Story 4.1 (epics.md:1228–1243); FR45 (epics.md:95). Story 4.2 làm màn chuyển trận + nút "Về menu" khi thua; 4.3 làm "Chơi tiếp" + tự lưu. **Không** làm phần của 4.2/4.3 ở đây.
- Kiến trúc: quyết định 16 "Một scene chính, đổi giữa các màn: Menu, Trận, Chuyển trận. Tối đa 1 autoload" (game-architecture.md:254); `enum Screen { MENU, BATTLE, TRANSITION, ERROR }` trong `main.gd` (dòng 898); cây thư mục `src/ui/main_menu.gd` (dòng 588); F5 "chạy ở mọi màn hình (trận, lỗi, menu)" (dòng 519); lỗi dữ liệu bản phát hành "thông báo ngắn kèm nút Về menu" (dòng 392).

### Hiện trạng code (đọc trước khi sửa)

- `src/app/main.gd`: `enum Screen` đã có, `_screen` khởi đầu `MENU`. `_ready()` dựng tiêu đề, `BoardView`, `BattleInput`, `Hud`, `Tooltip`, `ResultBanner`, `Notice`, `BattleView`, nhãn phiên bản, `SaveProbe`, `DevTools` (F1/F2/F3/F5 khi dev), `McpRuntime`, rồi **luôn** gọi `_start_battle()`. `_start_battle()` lấy `AppState.launch.level_id()`, rỗng thì `"tran_%02d" % DEFAULT_TRAN`. `_show_menu()` hiện chỉ xóa bàn ("Menu tạm cho tới story 4.1"). `_show_error()` gắn `back_pressed` → `_show_menu`.
- `src/app/app_state.gd`: autoload duy nhất; `_ready` đọc `LaunchOptions.read_current()` rồi `require_dev_for_tran()`.
- `src/app/launch_options.gd`: `level_id()` → `"tran_0N"` hoặc tên file, `""` khi không chọn.
- `src/battle/battle_view.gd:85` `stop()`: bỏ controller, dừng hoạt ảnh, **ẩn HUD**; mọi hàm nhận input đã chặn `_controller == null` → phím ở menu không làm gì. Giữ nguyên.
- `src/ui/error_screen.gd`: mẫu UI dựng bằng code (VBox, `TitleLabel`, nền `BACKGROUND_COLOR`, viền) — dùng lại phong cách.
- `src/ui/result_banner.gd`: nút "Chơi lại trận" giữ nguyên (bỏ ở 4.2).
- Test dựng `main.tscn`: `test_main.gd` (đã có test khẳng định `_screen == MENU` sau "Về menu", dòng 280, 539), `test_battle_view.gd` (`_show_menu()` dòng 595), `test_board_view.gd`, `test_stratagem_view.gd`.

### Điều phải giữ

- `tools/chay.sh --dev --tran=N` và `?dev=1&tran=N` vào thẳng trận như hôm nay (tác giả và MCP dùng hằng ngày).
- F1/F2/F3/F5, báo lỗi F2 (kể cả "không có trận"), màn hình lỗi, nhãn phiên bản, `SaveProbe`, `McpRuntime`.
- Không đụng luật (`src/core/`), dữ liệu trận, kịch bản.

### Luật kiến trúc phải theo

- Chỉ `main.gd` đổi màn; tối đa 1 autoload (`AppState`) — không thêm autoload.
- UI không gửi lệnh luật; menu chỉ phát signal, `main.gd` xử lý.
- Chữ qua `tr()`; Theme chung; script tên tiếng Anh `snake_case`.
- Log qua `Log.*`, không `print()`.

### Bài học từ story trước

- 3.12/3.13 review: test giao diện phải trượt được khi bỏ chốt — vd. test 4.4 phải kiểm không có lệnh/ log lỗi, không chỉ kiểm `_screen`.
- 3.12/3.13: thêm khóa `text.csv` phải sinh lại `text.vi.translation`.
- 0.3/0.5: trên itch, `?dev=1` trên link trang có thể không tới iframe — người chơi thường luôn thấy menu, đúng ý story.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh mọi nơi.
- Cửa sổ 1280×720; GoPeak `inject_mouse_click` nhận `x`, `y` pixel; chỉ dùng khi `--dev`.
- MCP chỉ để nhìn và thử; nói với tác giả bằng tiếng Việt, các bước thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.1]
- [Source: _bmad-output/planning-artifacts/game-architecture.md] dòng 254, 392, 519, 588, 898
- [Source: _bmad-output/implementation-artifacts/0-3-log-co-dev-va-tham-so-khoi-dong.md] (tham số khởi động)
- [Source: _bmad-output/project-context.md]

### Quyết định của tác giả (chốt 2026-10-28)

1. **Màn hình chính:** tên game (`app.title`), một dòng phụ đề nhỏ "Kháng chiến chống Nguyên Mông, 1288" (khóa `menu.subtitle`), nút "Chơi mới". Chưa có ảnh nền (để Story 4.6 trau chuốt nếu cần).
2. **Trong trận chưa có nút "Về menu"**: Story 4.2 thêm "Về menu" khi thua. Không thêm nút nào vào HUD ở story này.

### Câu hỏi đã hỏi tác giả (đã trả lời ở trên)

1. **Trên màn hình chính có gì ngoài tên game và nút "Chơi mới"?**
2. **Đang trong trận có nút "Về menu" không?** (Epics chỉ yêu cầu "Về menu" khi thua, ở Story 4.2.)

## Dev Agent Record

### Agent Model Used

### Debug Log References

- Nền trước story: HEAD `0c484a2`; `tools/test.sh` 774/774 GUT.
- Đổi `main.gd` trước, chạy test: 111/774 trượt đúng dự kiến (test trận chờ trận 1 tự mở: `test_battle_view` 75, `test_main` 24, `test_stratagem_view` 9, `test_board_view` 3). Đặt `AppState.launch.tran = "1"` ở `before_each` bốn file → còn 3 test khẳng định hành vi cũ, đổi ý nghĩa theo spec (xem Completion Notes). Cuối: 780/780 GUT, 173 kịch bản đã duyệt.
- GoPeak: `tools/chay.sh --dev` → màn hình chính (tên game, phụ đề, nút "Chơi mới", nhãn phiên bản, chữ DEV); bấm nút (cần gửi cả nhấn và nhả chuột: nút Godot kích hoạt khi nhả) → log `chơi mới`, `nạp trận tran_01`, ảnh trận 1. `--dev --tran=3` → log `nạp trận tran_03`, không có `về menu` (GoPeak ngắt kết nối nên không chụp ảnh lần này).

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- `MainMenu` (`src/ui/main_menu.gd`) dựng bằng code như `ErrorScreen`/`Hud`, không tạo `main_menu.tscn`: dự án chưa có scene UI nào ngoài `main.tscn`, giữ một mẫu. Nút nằm trong hộp `_buttons` để Story 4.3 thêm "Chơi tiếp" phía trên.
- `main.gd`: `_ready` đọc `AppState.launch.level_id()` vào `_level_id`; rỗng → `_show_menu()`, có → `_start_battle()`. `_start_battle()` mở `_level_id` (rỗng thì `FIRST_LEVEL_ID = "tran_01"`), nên "Chơi lại trận", F5 ở mọi màn hình và "Chơi mới" đi chung một đường. Màn hình chính và tiêu đề trận không hiện cùng lúc (`_set_menu_visible`). Bỏ `DEFAULT_TRAN`.
- Test đổi ý nghĩa (theo spec 4.1): `test_level_name_without_dev_opens_level_1` → `test_level_name_without_dev_shows_menu`; `test_back_button_returns_to_menu` và `test_back_to_menu_leaves_empty_board` giờ khẳng định bàn cờ **ẩn** sau màn hình chính (trước: bàn cờ hiện). `test_loads_level_1_by_default` đổi tên `test_tran_1_loads_level_1` (nội dung giữ).
- Test mới trong `test_main.gd` (6): hiện màn hình chính khi không chọn trận; "Chơi mới" → trận 1; dev + `tran=3` bỏ qua màn hình chính; phím `Space Z R Q W 1 2 3` ở màn hình chính không làm gì (bật log DEBUG để bắt dòng "nhận lệnh"); lỗi → Về menu → Chơi mới vào được trận; F5 ở màn hình chính mở trận 1.

**Hướng dẫn tác giả thử tay:**
1. `tools/chay.sh` (không `--dev`): thấy màn hình nền nâu, tên "Hào Khí Đông A", dòng nhỏ "Kháng chiến chống Nguyên Mông, 1288", nút "Chơi mới". Không có bàn cờ.
2. Bấm "Chơi mới": vào trận 1 như trước (quân Nguyên đã đi, có ô đỏ).
3. Ở màn hình chính bấm Space, Z, R, Q, W: không có gì xảy ra.
4. `tools/chay.sh --dev --tran=3`: vào thẳng trận 3, không thấy màn hình chính.
5. Bản web (sau khi deploy): mở link itch → luôn thấy màn hình chính trước.

### File List

- `game/src/ui/main_menu.gd` (mới), `game/src/ui/main_menu.gd.uid` (mới)
- `game/src/app/main.gd`
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/test_main.gd`, `game/tests/test_battle_view.gd`, `game/tests/test_board_view.gd`, `game/tests/test_stratagem_view.gd`
- `_bmad-output/implementation-artifacts/4-1-man-hinh-chinh.md`, `_bmad-output/implementation-artifacts/sprint-status.yaml`
