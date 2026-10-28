---
baseline_commit: 0c484a2
---

# Story 4.1: Màn hình chính

Status: ready-for-dev

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

- [ ] **Task 1: `src/ui/main_menu.gd`** (AC: 1, 2)
  - [ ] 1.1 `class_name MainMenu extends Control`, **dựng bằng code** như `ErrorScreen`/`Hud`/`ResultBanner` (dự án chưa có scene UI nào ngoài `main.tscn`; kiến trúc liệt kê `main_menu.tscn` nhưng theo mẫu code hiện có thì không cần — ghi lý do trong Completion Notes).
  - [ ] 1.2 `signal new_game_pressed`. Nút "Chơi mới" có hàm truy cập cho test (`new_game_button() -> Button`, như `Hud.end_turn_button()`).
  - [ ] 1.3 Màu và chữ theo Theme chung (`assets/theme/main_theme.tres`, `TitleLabel`); màu nền theo bảng màu `ErrorScreen` (gỗ tối). Phủ vùng màn hình 1280×720 (`BoardView.viewport_size`).
  - [ ] 1.4 Khóa chữ mới trong `i18n/text.csv` (`menu.new_game,Chơi mới`, `menu.subtitle,"Kháng chiến chống Nguyên Mông, 1288"` — có dấu phẩy nên phải để trong ngoặc kép), chạy lại bước sinh `text.vi.translation` như Story 3.12/3.13.

- [ ] **Task 2: `src/app/main.gd` đổi màn** (AC: 1, 3, 4, 5)
  - [ ] 2.1 `_ready()`: thay `_start_battle()` cuối hàm bằng: `AppState.launch.level_id()` khác rỗng → `_start_battle()`; rỗng → `_show_menu()`. (Dev đã được ép ở `AppState._ready` qua `require_dev_for_tran`, nên chỉ cần xét `level_id()`.)
  - [ ] 2.2 `_start_battle()` nhận trận cần mở: bỏ `DEFAULT_TRAN` khỏi chỗ đọc `launch`; "Chơi mới" gọi mở `tran_01`. F5 (`_reload_data`) mở lại `_level_id` đang có, chưa có thì `tran_01`. Giữ nguyên thứ tự nạp (chỉ số + trận, liệt kê đủ lỗi của cả hai) và mọi log hiện có.
  - [ ] 2.3 `_show_menu()`: dừng trận như hiện nay (`_controller = null`, `_battle_view.stop()`, ẩn bảng kết quả, xóa bàn), **ẩn** bàn cờ, tiêu đề trận, tooltip; hiện `MainMenu`. Rời menu (vào trận, màn hình lỗi) thì ẩn menu. Giữ log `"về menu"`.
  - [ ] 2.4 Nhãn phiên bản và chữ DEV vẫn nằm trên mọi màn (thứ tự con: menu phải nằm dưới nhãn phiên bản).
  - [ ] 2.5 Đổi chú thích "Menu tạm cho tới story 4.1" và comment `DEFAULT_TRAN`.

- [ ] **Task 3: Sửa test cũ bị ảnh hưởng** (AC: 6)
  - [ ] 3.1 Mọi test dựng `main.tscn` với `AppState.launch.tran = ""` mà chờ trận 1 mở ngay sẽ thấy menu thay vì trận: `test_main.gd`, `test_battle_view.gd`, `test_board_view.gd`, `test_stratagem_view.gd` (và soát `grep -rn "main.tscn" game/tests`). Cách sửa: đặt `AppState.launch.tran = "1"` trong `_make_main` (hoặc bấm nút "Chơi mới" khi test chính là đường vào trận). `after_each` đã trả `tran = ""`.
  - [ ] 3.2 **Không** đổi ý nghĩa test cũ (chỉ đổi đường vào trận). Test nào khẳng định "không chọn trận thì mở trận 1" phải đổi thành khẳng định hiện menu — ghi rõ trong Completion Notes test nào đổi ý nghĩa.

- [ ] **Task 4: Test mới** (AC: 1–5) — trong `test_main.gd` hoặc file mới `test_main_menu.gd`:
  - [ ] 4.1 Không `tran`: `_screen == MENU`, có `MainMenu` hiện, bàn cờ và HUD ẩn, `_controller == null`, nút "Chơi mới" có chữ `tr("menu.new_game")`.
  - [ ] 4.2 Bấm "Chơi mới" (`pressed.emit()`): `_screen == BATTLE`, `_level_id == "tran_01"`, menu ẩn, bàn cờ hiện, log có `"nạp trận tran_01"`.
  - [ ] 4.3 Có `tran = "3"` (dev): vào thẳng trận 3, không dựng menu (hoặc menu ẩn).
  - [ ] 4.4 Ở menu: gửi phím `Space`, `Z`, `R`, `Q`, `W` qua `BattleInput._unhandled_input` → không có lỗi/cảnh báo trong `Log.get_lines()`, vẫn ở menu.
  - [ ] 4.5 Màn hình lỗi → "Về menu" → `MainMenu` hiện. Từ menu bấm "Chơi mới" sau khi trận lỗi đã sửa: vào được trận (bảo đảm không giữ dữ liệu cũ).
  - [ ] 4.6 F5 ở menu (dev): mở trận 1 (hoặc `_level_id` cũ) như kiến trúc.

- [ ] **Task 5: Kiểm tra và bàn giao** (AC: 6)
  - [ ] 5.1 `tools/test.sh` xanh 4/4.
  - [ ] 5.2 Chụp màn hình GoPeak: `tools/chay.sh --dev` (không `--tran`) → màn hình chính; bấm "Chơi mới" bằng `inject_mouse_click` → trận 1. `tools/chay.sh --dev --tran=3` → vào thẳng trận 3.
  - [ ] 5.3 Hướng dẫn tác giả thử tay bằng tiếng Việt trong Completion Notes (desktop và bản web: mở link itch **không** có `?dev=1` phải thấy màn hình chính).
  - [ ] 5.4 Cập nhật story, `sprint-status.yaml` (và `epic-4: in-progress`); commit. Deploy itch **chỉ khi tác giả cho phép**.

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

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
