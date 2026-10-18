# Story 1.6: F5 nạp lại dữ liệu

Status: ready-for-dev

## Story

Là tác giả,
tôi muốn sửa file trận hoặc chỉ số rồi thấy kết quả ngay,
để tự cân bằng game.

## Acceptance Criteria

1. **Đổi chỉ số rồi F5.** **Cho** trận 1 đang mở bằng `tools/chay.sh --dev`. **Khi** sửa `tam_di` của Nguyễn Khoái trong `game/data/chi_so.json` từ 3 thành 2, lưu file, bấm F5, **thì**:
   - trận khởi động lại từ đầu: "Hiệp 1", không tướng nào đang chọn, nút Hủy mờ;
   - bấm Khoái (phím `1`) chỉ còn **4** ô sáng: `0,4`, `0,5`, `1,5`, `1,6` (trước đó là 7 ô);
   - log có dòng `[INFO][dev] f5: nạp lại chi_so.json và file trận`, rồi `[INFO][battle] nạp trận tran_01`.
2. **File trận sai rồi sửa lại.** **Khi** sửa `game/data/tran/tran_01.json` cho sai (ví dụ đổi một ô `.` của `dia_hinh` thành `X`), lưu file, bấm F5, **thì** màn hình lỗi hiện ra như Story 1.1 (bật dev nên liệt kê đủ lỗi, có file, dòng, cột). **Khi** sửa lại cho đúng rồi bấm F5 lần nữa, **thì** màn hình lỗi biến mất, trận 1 chạy lại bình thường.
3. **Nạp lại trận đang chọn.** **Cho** game mở bằng `--dev --tran=thu_ba_tuong`. **Khi** bấm F5, **thì** nạp lại `thu_ba_tuong.json` (không quay về trận 1).
4. **Giữ những gì không thuộc trận.** Sau F5: tọa độ F1 đang bật thì vẫn bật; chữ "DEV · lần mở thứ N" **không** tăng số (F5 không phải mở game lại).
5. **F5 ở menu** **[Cần tác giả chốt, xem Câu hỏi 1; mặc định đề xuất]**. **Cho** đang ở menu tạm (bấm "Về menu" trên màn hình lỗi). **Khi** bấm F5, **thì** nạp lại dữ liệu và mở trận như lúc mở game.
6. **Không bật dev thì F5 không làm gì** (giữ luật Story 0.3): không nạp lại, không có dòng log nào.
7. **Khi** code xong, **thì** `tools/test.sh` xanh, có test cho: F5 đọc lại chỉ số đã sửa; F5 từ trận sang màn hình lỗi và ngược lại; F5 giữ trận đang chọn; F5 ở menu; F5 không làm gì khi tắt dev.

## Tasks / Subtasks

- [ ] **Task 1: `DevTools` phát `f5_pressed`** (AC: 1, 6)
  - [ ] 1.1 `game/src/debug/dev_tools.gd`: thêm `signal f5_pressed`. Trong `_unhandled_input`, F5 (index 4) phát `f5_pressed` thay cho ghi log, giống cách F1 (index 0) phát `f1_pressed`. `MESSAGES[4]` đổi thành `""`; sửa chú thích đầu file và chú thích của `MESSAGES` ("F1 và F5 đã có công cụ nên không có câu"; "F2–F4 mới chỉ ghi log").
  - [ ] 1.2 `game/tests/test_dev_tools.gd`:
    - `test_dev_on_shows_badge_and_logs_each_key`: thêm `assert_signal_emit_count(tools, "f5_pressed", 1)`; bỏ dòng log `f5: chưa có nạp lại dữ liệu (story 1.6)` khỏi danh sách mong đợi (còn 3 dòng F2–F4).
    - `test_dev_off_keys_do_nothing`: thêm `assert_signal_not_emitted(tools, "f5_pressed")`.
    - Sửa chú thích đầu file (dòng 3) cho khớp.
- [ ] **Task 2: `main.gd` nối F5 với `_start_battle()`** (AC: 1–5)
  - [ ] 2.1 Trong `_ready()`, khối `if AppState.launch.dev:` (cạnh dòng nối `f1_pressed`), nối `dev_tools.f5_pressed.connect(_reload_data)`. Chỉ nối khi bật dev, như F1.
  - [ ] 2.2 Thêm hàm `_reload_data()`: `Log.info("dev", "f5: nạp lại chi_so.json và file trận")` rồi gọi `_start_battle()`. Theo Câu hỏi 1, mặc định chạy ở **mọi màn hình** (trận, lỗi, menu). Tác giả chọn khác thì thêm điều kiện theo `_screen`.
  - [ ] 2.3 **Không** viết lại đường nạp. `_start_battle()` đã làm đủ (đọc từ Story 1.1–1.5, xem Dev Notes "Hiện trạng"): luôn đọc cả hai file, tạo `Stats`, `LevelData`, `BattleController` **mới**, lỗi thì xóa `AppState.stats`, `_level` và hiện màn hình lỗi, đúng thì bỏ màn hình lỗi. Sửa chú thích `## ... F5 (story 1.6) gọi lại hàm này.` thành câu hiện tại: `F5 gọi lại hàm này (_reload_data).`
  - [ ] 2.4 Không gọi lại `SaveProbe.bump` hay `McpRuntime.start_if_enabled` (chỉ chạy một lần lúc mở game, AC 4).
- [ ] **Task 3: Test trong `game/tests/test_main.gd`** (AC: 1–7)
  - [ ] 3.1 Hàm phụ `_write_stats(tam_di_khoai: int) -> String`: đọc `res://data/chi_so.json` thành `Dictionary`, đặt `["tuong"]["nguyen_khoai"]["tam_di"] = tam_di_khoai`, ghi ra `PROBE_DIR + "/chi_so_f5.json"`, trả đường dẫn. **Không bao giờ ghi vào `res://data/`** (tác giả được sửa file đó). Dọn file này trong `after_each` (theo mẫu `BROKEN_STATS`).
  - [ ] 3.2 Hàm phụ `_press_f5(main)`: `_dev_tools(main).f5_pressed.emit()` (đã có `_dev_tools()` cho F1).
  - [ ] 3.3 `test_f5_reads_edited_stats`: bật dev; `_make_main("", _write_stats(3))`; Khoái có 7 ô (`main._controller.reachable(1).size()`); đi một nước (`main._controller.submit(Command.move(1, Vector2i(0, 4)))`); `_write_stats(2)`; `_press_f5`; mong đợi: `reachable(1)` = `[Vector2i(0, 4), Vector2i(0, 5), Vector2i(1, 5), Vector2i(1, 6)]`, Khoái về `0,6`, `round_number == 1`, `can_undo()` false, controller là đối tượng mới (`assert_ne` với controller cũ), `_battle_view.selected_id() == BattleView.NONE`, có dòng log `[INFO][dev] f5: nạp lại chi_so.json và file trận`. Danh sách 4 ô tính tay theo luật đi Story 1.4 (đi xuyên Lão ở `2,6` nhưng không dừng trên đó); nếu code ra khác thì xem lại luật, **không** sửa test cho khớp mà chưa hỏi.
  - [ ] 3.4 `test_f5_shows_error_then_recovers`: bật dev; `_make_main()`; `main.level_dir = _broken_level_dir()`; `_press_f5` → `_screen == Screen.ERROR`, màn hình lỗi có đủ `BROKEN_ERRORS`; `main.level_dir = "res://data/tran"`; `_press_f5` → `_screen == Screen.BATTLE`, `_error_screen == null`, bàn cờ hiện, có 5 đồng quân.
  - [ ] 3.5 `test_f5_keeps_chosen_level`: bật dev, `AppState.launch.tran = "thu_ba_tuong"`; `_make_main()`; `_press_f5`; vẫn có quân id 3 (Trần Khánh Dư) và log `nạp trận thu_ba_tuong` xuất hiện hai lần.
  - [ ] 3.6 `test_f5_on_menu_opens_battle` (theo Câu hỏi 1): màn hình lỗi → bấm nút "Về menu" (`_find_button(main._error_screen).pressed.emit()`) → `level_dir` về đúng → `_press_f5` → `_screen == Screen.BATTLE`.
  - [ ] 3.7 `test_f5_keeps_coordinates_and_open_count`: bật dev; bấm F1; `_press_f5`; tọa độ vẫn hiện; chữ DEV vẫn đúng câu cũ (số lần mở không đổi); `SaveProbe` không ghi thêm lần nào (`SaveProbe._read(PROBE_FILE)` trước và sau F5 bằng nhau).
  - [ ] 3.8 `test_f5_needs_dev`: không bật dev; `_make_main()`; tìm `DevTools` (`_dev_tools`) và kiểm `f5_pressed` **không** có kết nối nào (`get_connections()` rỗng); gửi phím F5 thật (`InputEventKey`, `physical_keycode = KEY_F5`) vào `DevTools._unhandled_input` → controller không đổi (cùng đối tượng), không có dòng log `[INFO][dev]`.
  - [ ] 3.9 Xem `after_each` của `test_main.gd`: đã dọn `dev_f1`…`dev_f5` và `AppState.launch.tran`; thêm dọn `chi_so_f5.json`.
- [ ] **Task 4: Kiểm bằng mắt trên desktop** (AC: 1–4)
  - [ ] 4.1 Chạy `tools/chay.sh --dev` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action select_general_1` → `capture_screenshot` (7 ô sáng).
  - [ ] 4.2 Sửa **tạm** `game/data/chi_so.json` (`nguyen_khoai.tam_di` = 2), `inject_action dev_f5`, `inject_action select_general_1`, chụp màn hình: 4 ô sáng, "Hiệp 1". Phải dùng `inject_action`, không dùng `inject_key` (`inject_key` không kích hoạt action gán theo phím vật lý, Debug Log Story 1.4).
  - [ ] 4.3 Sửa **tạm** `tran_01.json` (một ô thành `X`), `inject_action dev_f5`, chụp: màn hình lỗi. Trả `tran_01.json` về như cũ, `inject_action dev_f5`, chụp: trận chạy lại.
  - [ ] 4.4 **Trả cả hai file dữ liệu về như cũ** (`git checkout game/data/`), kiểm `git status` không còn thay đổi trong `game/data/`. Tắt game. Ghi Debug Log (kèm các dòng `[INFO][dev]`, `[INFO][battle]` trong log của `chay.sh`).
- [ ] **Task 5: Thử F5 trên bản web** (mục hoãn của Story 0.3 và 0.5 ở `deferred-work.md`) (AC: 6, Câu hỏi 2)
  - [ ] 5.1 `tools/build_web.sh`. Chạy server tạm: `python3 -m http.server 8060 -d build/web` (chế độ nền). AI không mở được trình duyệt: ghi vào hướng dẫn cho tác giả mở `http://localhost:8060/?dev=1` trong Chrome, bấm vào game rồi bấm F1, F5. Ghi rõ điều cần nhìn: trang có tải lại không (chữ "DEV · lần mở thứ N" tăng số là trang đã tải lại), hay game nhận phím (DevTools Console có `[INFO][dev] f5: ...`).
  - [ ] 5.2 Tắt server. **Không** chặn phím của trình duyệt bằng `JavaScriptBridge` trong story này trừ khi tác giả trả lời Câu hỏi 2 là "phải chặn".
  - [ ] 5.3 Cập nhật `deferred-work.md`: hai mục "F1/F5 trên web" (Story 0.3, 0.5) ghi "→ desktop xong ở Story 1.6; web chờ tác giả thử" hoặc kết quả tác giả báo.
- [ ] **Task 6: Tài liệu, test, commit** (AC: 7)
  - [ ] 6.1 `game-architecture.md` bảng phím dev (`F5`): ghi rõ "chạy ở mọi màn hình (trận, lỗi, menu); bản web đọc lại dữ liệu đóng gói sẵn nên không thấy file đã sửa" (sửa theo câu trả lời của tác giả).
  - [ ] 6.2 `tools/test.sh` xanh. Commit một lần, lời commit tiếng Việt, ví dụ `F5 nạp lại chỉ số và file trận khi bật dev (Story 1.6)`.
  - [ ] 6.3 Ghi hướng dẫn tác giả tự test vào Completion Notes theo mẫu ở mục Testing, dùng kết quả thật.

## Dev Notes

### Bối cảnh

Story nhỏ: gần như mọi thứ đã có, chỉ thiếu dây nối từ phím F5 tới hàm nạp trận.

- Story 0.3 đăng ký sẵn phím `dev_f1`…`dev_f5` (chỉ khi bật dev). F5 hiện chỉ ghi log `f5: chưa có nạp lại dữ liệu (story 1.6)`.
- Story 1.1 viết `main._start_battle()` để nạp lại được nhiều lần: chú thích ghi sẵn "F5 (story 1.6) gọi lại hàm này"; đã có test `test_reload_after_fix_hides_error_screen`, `test_reload_with_error_drops_old_data`, `test_reload_with_error_clears_board`.
- Story 1.2 giữ trạng thái F1 qua các lần nạp lại (`test_f1_stays_on_after_reload`).
- Story 1.4, 1.5: nạp lại thì bỏ chọn tướng (`test_restart_battle_clears_selection`), controller mới nên hiệp về 1 và mất bản chụp hủy.

### Hiện trạng các file sẽ sửa

**`game/src/debug/dev_tools.gd`** (đọc cả file trước khi sửa)
- Hiện tại: `setup(enabled, opens)` đăng ký 5 action khi bật dev và thêm chữ DEV; `_ready()` tắt nhận phím khi không bật dev; `_unhandled_input` duyệt `KEYS`: F1 phát `f1_pressed`, F2–F5 ghi `Log.debug("dev", MESSAGES[i])`, rồi `set_input_as_handled()`.
- Đổi: F5 phát `f5_pressed`.
- Giữ nguyên: không bật dev thì không đăng ký phím, không nhận phím, không có log; không lặp phím (`allow_echo = false`); F2–F4 vẫn ghi log như cũ.

**`game/src/app/main.gd`**
- Hiện tại: `_ready()` dựng tiêu đề, bàn cờ, `BattleInput`, `Hud`, `BattleView`, nhãn phiên bản, đếm lần mở (`SaveProbe.bump`), tạo `DevTools`, khi bật dev thì tạo `CoordOverlay` và nối `f1_pressed` → `_toggle_coords`, khởi động MCP, rồi `_start_battle()`.
- `_start_battle()`: lấy `AppState.launch.level_id()` (trống thì `tran_01`), nạp `stats_path` và `level_dir/<id>.json`, gom lỗi của cả hai. Có lỗi: `AppState.stats = null`, `_level = null`, `_show_error(errors)`. Đúng: `AppState.stats` mới, `BattleController.new()`, `start()`, nối `events_resolved` → `_on_events_resolved` (trước BattleView), `_show_board`, `_battle_view.start(controller)`, `_hide_error()`, `_screen = BATTLE`.
- `_show_error` / `_show_menu` đều gọi `_battle_view.stop()` và `_controller = null`.
- Đổi: thêm `_reload_data()` và một dòng nối signal.
- Giữ nguyên: thứ tự nối `events_resolved` (main trước BattleView: đồng quân vẽ lại trước ô sáng, xem `deferred-work.md` mục code review 1.5); F1 chỉ chạy khi đang có trận.

**Không phải sửa:** `BattleView.start()` đã tự bỏ chọn và vẽ lại bảng nút; `Hud` hiện "Hiệp 1" và nút Hủy mờ theo controller mới. Controller cũ là `RefCounted`, hết người giữ thì tự giải phóng cùng các kết nối signal.

### Vì sao sửa file rồi F5 thấy ngay (desktop)

`tools/chay.sh` chạy `godot --path game`, nên `res://` chính là thư mục `game/`. `JsonFile.read_text` dùng `FileAccess.get_file_as_string`, đọc thẳng file trên đĩa mỗi lần gọi, không có bộ nhớ đệm. Kiến trúc: "F5 nạp lại dữ liệu bằng cách tạo đối tượng mới rồi khởi động lại trận, không sửa đối tượng cũ" [game-architecture.md, "Mẫu truy cập dữ liệu"]. `_start_battle()` đã đúng như vậy.

**Bản web:** dữ liệu nằm trong `index.pck` lúc build, nên F5 trên web đọc lại đúng dữ liệu cũ. F5 là công cụ cho desktop. Tài liệu Godot 4.7 (Exporting for the Web) ghi rằng Godot "bắt" phím khi game đang nhận phím (ví dụ F12 không mở được DevTools), nên có thể F5 tới được game thay vì tải lại trang; chưa ai thử (Task 5).

### Ô đi của Khoái khi `tam_di` = 2 (trận 1)

```
      0 1 2 3
   3  . . . ~      ~ sông
   4  * . . ~      * ô sáng
   5  * * . ~
   6  1 * 2 ~      1 Khoái (0,6), 2 Lão (2,6)
```

Theo thứ tự đọc bàn: `0,4`, `0,5`, `1,5`, `1,6`. `2,6` là Lão (không dừng được); `2,5` cần 3 bước.

### Luật kiến trúc phải theo

- `src/debug/` là code chỉ chạy khi bật dev: F5 chỉ được nối khi `AppState.launch.dev` [project-context.md "Nền tảng và build": F1/F2/F3/F5 không có tác dụng khi không bật dev].
- Đi xuống thì gọi hàm, đi lên thì phát signal: `DevTools` phát `f5_pressed`, `main` (cha) nối và gọi `_start_battle()`. Không Event Bus, không `get_node("..")`.
- Log qua `Log.info/debug("dev", ...)`, không `print()`.
- Gõ kiểu tĩnh mọi nơi; `JSON.parse_string()` trả `Variant`, phải kiểm kiểu rồi ép (`as Dictionary`) trong hàm phụ test.
- Không sửa `res://data/` trong test. Test đọc file thật rồi ghi bản sửa vào `user://`.

### Testing

- Test chạy không cần màn hình, qua `main.tscn` thật như `test_main.gd` đang làm (`_make_main(level_dir, stats_path)`).
- Bấm F5 trong test bằng cách phát signal `f5_pressed` (như F1 trong `test_f1_toggles_coordinates_in_dev`). Ca "tắt dev" gửi phím thật vào `DevTools._unhandled_input` để chứng minh phím bị khóa.
- Hướng dẫn tác giả tự test (Completion Notes), mẫu:
  1. `tools/chay.sh --dev`, bấm `1`: 7 ô sáng.
  2. Mở `game/data/chi_so.json`, đổi `"tam_di": 3` của `nguyen_khoai` thành `2`, lưu. Quay lại game, bấm F5, bấm `1`: 4 ô sáng (`0,4`, `0,5`, `1,5`, `1,6`), bảng bên phải "Hiệp 1".
  3. Mở `game/data/tran/tran_01.json`, đổi ô đầu của `dia_hinh` thành `X`, lưu, bấm F5: màn hình lỗi. Đổi lại `.`, lưu, bấm F5: trận chạy lại.
  4. Trả `tam_di` về `3`. Không chạy `--dev` thì bấm F5 không có gì xảy ra.
  5. (Web) theo Task 5.1.

### Previous Story Intelligence (Story 1.5 và code review)

- GoPeak: dùng `inject_action` cho phím gán theo phím vật lý; ảnh chụp ngay sau thao tác có thể chưa kịp vẽ lại, chờ một chút rồi chụp lại thay vì bấm thêm.
- Test bấm nút qua viewport thật phải đặt `main` trong `SubViewport` riêng (bảng kết quả của GUT đè lên viewport gốc). Story này không cần, vì F5 đi qua signal.
- Godot không màn hình không đưa Space/`ui_accept` tới nút đang focus; không dựa vào hành vi focus trong test.
- Mỗi test kiểm hành vi mới nên được thử "làm hỏng tạm" (bỏ dòng nối F5 → test phải trượt), ghi vào Debug Log như Story 1.5.
- Code review 1.5 để lại: `main.gd` nối `events_resolved` trước `BattleView.start`, đúng thứ tự nhờ chú thích. F5 đi qua cùng `_start_battle()` nên giữ được thứ tự này; đừng tách đường nạp riêng cho F5.

### Git Intelligence

- 5 commit gần nhất: Story 1.5 (đi, hủy, kết thúc lượt), code review 1.5 (`hiep`/`da_di` trong kịch bản), duyệt lại kịch bản. Không đụng `dev_tools.gd`. `main.gd` đổi ở 1.5 (thêm `Hud`, nối `events_resolved`).
- Mẫu lời commit: tiếng Việt, kết thúc bằng `(Story 1.6)`.

### Project Context Rules

- Godot 4.7.2, GDScript, GUT 9.7.1; cú pháp Godot 4 (`signal.connect(callable)`).
- `app_state.gd` là autoload duy nhất; `Log` là lớp static.
- Chữ hiển thị qua `tr()`. Story này không thêm chữ trên màn hình (chỉ log), nên không thêm khóa dịch.
- Xong một việc = `tools/test.sh` xanh rồi commit. Nói với tác giả bằng tiếng Việt, theo bước thử.
- Luật chưa có trong tài liệu thì hỏi tác giả: hai câu hỏi dưới đây.

### Câu hỏi cho tác giả

1. **F5 ở menu tạm** (sau khi bấm "Về menu" trên màn hình lỗi): (a) nạp lại và mở trận như lúc mở game **(đề xuất: menu này chỉ tạm tới Story 4.1)**, hay (b) không làm gì như F1?
2. **F5 trên bản web**: dữ liệu web đóng gói sẵn nên F5 không thấy file đã sửa. Nếu thử thấy trình duyệt tải lại trang khi bấm F5: (a) chấp nhận, F5 chỉ dùng trên desktop **(đề xuất)**, hay (b) phải chặn để F5 tới game?

### References

- `_bmad-output/planning-artifacts/epics.md` Story 1.6 (dòng 474–487); Epic 1 phủ "Công cụ dev F1, F5".
- `_bmad-output/planning-artifacts/game-architecture.md`: bảng công cụ dev (dòng 251, 516), cây thư mục `dev_tools.gd` (dòng 591), "F5 nạp lại dữ liệu bằng cách tạo đối tượng mới" (dòng 902).
- `_bmad-output/project-context.md`: "Nền tảng và build" (phím dev chỉ khi bật dev).
- `_bmad-output/implementation-artifacts/deferred-work.md`: rủi ro F1/F5 trên web (Story 0.3), chưa thử F1/F5 trên web (Story 0.5).
- `_bmad-output/implementation-artifacts/0-3-log-co-dev-va-tham-so-khoi-dong.md`: bảng phím F1–F5.
- Godot 4.7 docs, Exporting for the Web: Godot bắt phím của trình duyệt khi game nhận input.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List

### Change Log

- 2026-10-18: Tạo story.
