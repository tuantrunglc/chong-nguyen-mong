---
baseline_commit: 5d07683
---

# Story 4.2: Chuỗi 6 trận và màn chuyển trận

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn đi qua các trận liên tiếp,
để cảm nhận một chiến dịch trọn vẹn.

## Acceptance Criteria

1. **Cho** `data/chien_dich.json` liệt kê các trận theo thứ tự (tác giả chốt 2026-10-30: **5 trận** `tran_01`…`tran_05`; Story 4.5 thêm `tran_06` bằng một dòng) **thì** game nạp file này cùng `chi_so.json` và file trận:
   - Định dạng: `{"phien_ban_dinh_dang": 1, "tran": ["tran_01", "tran_02", "tran_03", "tran_04", "tran_05"]}`.
   - File sai (JSON hỏng, thiếu `tran`, danh sách rỗng, phần tử không phải chuỗi, trùng tên, tên trận không có file trong `data/tran/`) thì báo lỗi tiếng Việt ghi rõ file và giá trị sai, hiện trên màn hình lỗi như lỗi chỉ số/trận; không sập.
   - "Chơi mới" mở trận **đầu tiên** của danh sách (không viết cứng `tran_01` nữa).
2. **Khi** thắng một trận có trong chuỗi, không phải trận cuối **thì** bảng "Thắng!" hiện như hôm nay nhưng nút là **"Tiếp"** (thay "Chơi lại trận"; tác giả chốt 2026-10-30). Bấm "Tiếp" thì sang **màn chuyển trận** (FR44):
   - Che bàn cờ, HUD, tiêu đề trận (như màn hình chính); nhãn phiên bản và chữ DEV vẫn nằm trên.
   - Ghi tên trận kế lấy từ khóa `"ten"` của file trận kế (vd. "Trận 2 — Ải Lãnh Kinh").
   - **Mưu kế vừa mở (nếu có):** mưu kế có trong `"muu_ke_mo"` của trận kế mà trận vừa thắng không có; mỗi mưu kế một dòng, tên lấy từ `stratagem.<ten>` (tác giả chốt 2026-10-30: mưu kế mở vẫn ghi trong file trận, `chien_dich.json` chỉ ghi thứ tự). Không có thì không có dòng nào.
   - Nút **"Tiếp"**: vào trận kế (pha địch chuẩn bị hiệp 1 chạy như mọi trận).
3. **Khi** vào trận mới **thì** các tướng hồi đầy máu: máu lấy từ `chi_so.json` như lúc mở trận lần đầu, không mang máu từ trận trước sang.
4. **Khi** thắng **trận cuối** của chuỗi **thì** nút "Tiếp" sang màn chuyển trận dạng **kết thúc**: dòng "Đã thắng cả chiến dịch" (chữ chính xác tác giả sửa trong CSV), chỉ có nút **"Về menu"** → màn hình chính (tác giả chốt 2026-10-30).
5. **Khi** thua **thì** bảng "Thua!" (kể cả "Thua: hết hiệp", "mất làng", "giặc vào ải") có hai nút **"Đánh lại trận này"** (mở lại trận đó từ đầu, như nút "Chơi lại trận" cũ) và **"Về menu"** (→ màn hình chính).
6. **Và** mưu kế mở dần theo trận (FR34) đúng như file trận đang ghi: trận 1–4 không có mưu kế, trận 5 có Vườn không nhà trống. Sát Thát mở ở trận 6 (Story 4.5) — story này không đổi dữ liệu mưu kế.
7. **Và** trận mở bằng dev (`--dev --tran=N` / `?dev=1&tran=N`):
   - Trận có trong chuỗi: thắng thì "Tiếp" đi tiếp chuỗi từ trận đó (vd. `--tran=3` thắng → trận 4).
   - Trận không có trong chuỗi (trận thử `thu_*`): thắng thì bảng có "Đánh lại trận này" và "Về menu" (như khi thua), không có "Tiếp".
8. **Và** ở màn chuyển trận: phím tắt trận và chuột trên bàn không làm gì; F1/F3 không làm gì (chặn theo `_screen`); F2 chép báo lỗi "không có trận" và thông báo nhìn thấy được; F5 nạp lại dữ liệu và mở trận kế (trận màn đó sắp vào; màn kết thúc thì mở lại trận cuối). Mọi nút làm được bằng một cú bấm chuột, chữ qua `tr()`.
9. **Và** `tools/test.sh` xanh; test GUT mới cho bộ nạp chiến dịch, bảng kết quả, màn chuyển trận, luồng trận → chuyển trận → trận kế; commit tiếng Việt kết `(Story 4.2)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–4** — xong 2026-10-30, xem "Quyết định của tác giả".

- [ ] **Task 1: Dữ liệu và bộ nạp chiến dịch** (AC: 1)
  - [ ] 1.1 `game/data/chien_dich.json` theo định dạng AC1 (5 trận). Kiểm preset export đã có filter `*.json` (có rồi, chỉ soát).
  - [ ] 1.2 `src/core/campaign_data.gd`: `class_name CampaignData extends RefCounted`, chỉ đọc: `levels: Array[String]`; `first_level() -> String`; `next_after(level_id) -> String` (`""` khi là trận cuối **hoặc** không có trong chuỗi); `contains(level_id) -> bool`; `is_last(level_id) -> bool`. Không I/O (luật `src/core`). Kiến trúc gọi tên `campaign_progress.gd` cho "tiến độ, mưu kế đã mở": tiến độ để Story 4.3 (lưu), mưu kế đã mở nằm ở file trận theo quyết định 4 → story này chỉ cần `CampaignData`; ghi lý do trong Completion Notes.
  - [ ] 1.3 `src/data/campaign_loader.gd`: `CampaignLoader.load_campaign(path, level_dir) -> LoadResult` theo mẫu `StatsLoader` (`JsonFile.read_text/parse_object/missing_file`, gom mọi lỗi, không ghi log). Cảnh báo khóa lạ như `StatsLoader._warn_unknown`. Lỗi kiểm `phien_ban_dinh_dang` theo cách `LevelLoader` đang kiểm.
  - [ ] 1.4 Câu lỗi (test so nguyên văn), dạng `data/chien_dich.json: ...`: thiếu khóa `"tran"`; `"tran"` phải là danh sách tên trận; danh sách rỗng; phần tử thứ N không phải chuỗi; tên trận trùng; không có file `data/tran/<ten>.json`.

- [ ] **Task 2: Bảng kết quả** (AC: 2, 4, 5, 7) — `src/ui/result_banner.gd`
  - [ ] 2.1 Thay một nút `retry_pressed` bằng ba nút, đều `FOCUS_NONE`: **"Tiếp"** (`next_pressed`), **"Đánh lại trận này"** (`retry_pressed`), **"Về menu"** (`menu_pressed`). `show_result(phase, defeat_reason, can_continue: bool)`: WON + `can_continue` → chỉ "Tiếp"; WON + không `can_continue` (trận ngoài chuỗi) → "Đánh lại trận này" + "Về menu"; LOST → "Đánh lại trận này" + "Về menu".
  - [ ] 2.2 Khóa chữ: đổi `result.retry` thành "Đánh lại trận này"; thêm `result.next` "Tiếp", `result.menu` "Về menu". Khung vẫn bọc vừa nội dung (`_relayout`) với hai nút.
  - [ ] 2.3 Bỏ chú thích "Nút này bỏ khi có menu ở Story 4.2"; thêm hàm truy cập nút cho test (`next_button()`, `retry_button()`, `menu_button()`).

- [ ] **Task 3: Màn chuyển trận** (AC: 2, 4, 8) — `src/ui/level_transition.gd`
  - [ ] 3.1 `class_name LevelTransition extends Control`, dựng bằng code theo mẫu `MainMenu` (nền `MainMenu.BACKGROUND_COLOR`, `TitleLabel`, `CenterContainer`, nút `FOCUS_NONE`, cỡ `BoardView.viewport_size`). Không cần `.tscn` (như 4.1).
  - [ ] 3.2 `show_next(level_name: String, new_stratagems: Array[int])` → tiêu đề trận kế, các dòng mưu kế mới (`tr("transition.new_stratagem") % tr("stratagem.<ten>")`), nút "Tiếp" (`next_pressed`). `show_campaign_end()` → dòng `transition.campaign_won`, nút "Về menu" (`menu_pressed`).
  - [ ] 3.3 Khóa chữ `transition.*` mới; chạy lại bước sinh `text.vi.translation` như 4.1.

- [ ] **Task 4: `src/app/main.gd` nối chuỗi trận** (AC: 1–8)
  - [ ] 4.1 Nạp `chien_dich.json` trong `_start_battle()` cùng chỉ số và trận (biến test đổi được: `campaign_path`), gom lỗi của cả ba file; giữ dữ liệu ở `_campaign` (hoặc `AppState.campaign` nếu 4.3 cần — chọn một, ghi lý do). Lỗi thì màn hình lỗi như hiện nay. F5 nạp lại cả ba.
  - [ ] 4.2 `_on_new_game()` mở `_campaign.first_level()`. Lưu ý: `_campaign` có thể chưa nạp khi đang ở menu → nạp chiến dịch trước rồi lấy trận đầu; lỗi thì màn hình lỗi. Bỏ `FIRST_LEVEL_ID` hoặc chỉ giữ làm giá trị dự phòng khi F5 lúc chưa mở trận nào (ghi rõ).
  - [ ] 4.3 `_on_playback_finished`: truyền `can_continue = _campaign.contains(_level_id)` cho `show_result`. Nối `next_pressed` → `_show_transition()`, `retry_pressed` → `_start_battle`, `menu_pressed` → `_show_menu`.
  - [ ] 4.4 `_show_transition()`: dừng trận như `_show_menu` (controller null, `_battle_view.stop()`, ẩn bảng kết quả, xóa bàn, ẩn bàn cờ và tiêu đề), `_screen = Screen.TRANSITION`. Trận cuối → `show_campaign_end()`. Ngược lại nạp file trận kế bằng `LevelLoader` để lấy `name` và `stratagems` (lỗi → màn hình lỗi), đặt `_level_id` = trận kế, `show_next(...)`. Mưu kế mới = `next.stratagems` trừ `_level.stratagems`. Log `Log.info("app", "chuyển trận %s -> %s")`, màn kết thúc log `"thắng cả chiến dịch"`. Đây là chỗ duy nhất biết "vừa thắng trận X" → Story 4.3 sẽ gắn tự lưu ở đây (ghi chú trong code).
  - [ ] 4.5 Nút "Tiếp" của màn chuyển trận → `_start_battle()` (trận kế, `_level_id` đã đặt ở 4.4); "Về menu" → `_show_menu()`.
  - [ ] 4.6 Thứ tự con: màn chuyển trận nằm dưới `_notice`, nhãn phiên bản, chữ DEV; trên bàn cờ, HUD, tooltip, bảng kết quả; bảng F3 nằm dưới nó (bài học review 4.1). Ẩn màn chuyển trận khi vào trận, màn hình lỗi, menu (gom vào một hàm như `_set_menu_visible`).

- [ ] **Task 5: Sửa test cũ bị ảnh hưởng** (AC: 9)
  - [ ] 5.1 Test dùng `retry_button()` / `retry_pressed` của `ResultBanner` và test "Chơi mới" mở `tran_01`: `test_result_banner.gd`, `test_main.gd`, `test_battle_view.gd` (soát `grep -rn "retry\|FIRST_LEVEL_ID\|tran_01" game/tests`). Test dựng `main.tscn` với `level_dir` riêng (`user://test_main/tran`) cần `campaign_path` trỏ tới file chiến dịch hợp lệ cho thư mục đó, hoặc test chỉ kiểm lỗi trận.
  - [ ] 5.2 Không đổi ý nghĩa test cũ; test nào đổi ý nghĩa (vd. bảng Thắng! không còn "Chơi lại trận") thì ghi rõ trong Completion Notes.

- [ ] **Task 6: Test mới** (AC: 1–8)
  - [ ] 6.1 `test_loaders.gd` (hoặc `test_campaign_loader.gd`): file đúng → `levels` đúng thứ tự; mỗi câu lỗi ở 1.4 ra **nguyên văn**; file thật `data/chien_dich.json` nạp không lỗi, mọi trận trong đó nạp được bằng `LevelLoader`.
  - [ ] 6.2 `CampaignData`: `first_level`, `next_after` (giữa chuỗi, trận cuối, trận ngoài chuỗi), `is_last`.
  - [ ] 6.3 `ResultBanner`: WON + tiếp được → chỉ nút "Tiếp" hiện; WON ngoài chuỗi → "Đánh lại" + "Về menu"; LOST (mọi `defeat_reason`) → "Đánh lại" + "Về menu"; nút `FOCUS_NONE`; khung bọc hết nút.
  - [ ] 6.4 Luồng `main`: thắng trận 1 (dùng cách test hiện có đưa trận về WON, vd. kịch bản lời giải hoặc dựng `snapshot` WON qua `_on_playback_finished`) → bấm "Tiếp" → `_screen == TRANSITION`, tên trận 2, không có dòng mưu kế → bấm "Tiếp" → `_level_id == "tran_02"`, `_screen == BATTLE`, mọi tướng đủ máu theo `chi_so.json`.
  - [ ] 6.5 Trận 4 → trận 5: màn chuyển trận có dòng "Vườn không nhà trống". Trận cuối (5) thắng → màn kết thúc, chỉ nút "Về menu" → `_screen == MENU`.
  - [ ] 6.6 Thua → "Về menu" → `MENU`; "Đánh lại trận này" → cùng `_level_id`, trận mở lại từ đầu.
  - [ ] 6.7 Dev `--tran=thu_muu_ke` thắng → không có "Tiếp". Dev `--tran=3` thắng → "Tiếp" → trận 4.
  - [ ] 6.8 Ở màn chuyển trận: phím trận + chuột không làm gì (theo mẫu test 4.1 đã sửa: kiểm `BattleInput` có phát signal, rồi kiểm không có controller/không chọn quân/không log lỗi); F2 chép được và thông báo nằm trên màn chuyển trận; F5 mở trận kế; thứ tự con (4.6).
  - [ ] 6.9 `chien_dich.json` lỗi → "Chơi mới" ra màn hình lỗi có câu lỗi chiến dịch.
  - [ ] 6.10 Mọi test mới phải trượt được khi bỏ phần code tương ứng (bài học 3.12/3.13/4.1) — thử ít nhất một lần bằng cách tạm cất phần sửa code, ghi kết quả vào Debug Log.

- [ ] **Task 7: Kiểm tra và bàn giao** (AC: 9)
  - [ ] 7.1 `tools/test.sh` xanh 4/4.
  - [ ] 7.2 Chụp màn hình GoPeak (`tools/chay.sh --dev --tran=4`): bảng "Thắng!" có nút "Tiếp" (đánh theo `tran_04_loi_giai.md` hoặc đưa trận về WON bằng cách có sẵn trong dev), màn chuyển trận sang trận 5 có dòng mưu kế; màn kết thúc sau trận 5. Ảnh nào không chụp được thì ghi rõ, **không** đánh `[x]` nói quá.
  - [ ] 7.3 Hướng dẫn tác giả thử tay bằng tiếng Việt trong Completion Notes (từng bước, thấy gì là đúng).
  - [ ] 7.4 Cập nhật story, `sprint-status.yaml`; commit. Deploy itch **chỉ khi tác giả cho phép**.

## Dev Notes

### Nguồn

- Epics Story 4.2 (epics.md:1244–1262); FR44 (epics.md:94), FR34 (epics.md:76). Story 4.3 làm tự lưu + "Chơi tiếp"; 4.5 làm trận 6 (thêm `tran_06` vào `chien_dich.json`, mở Sát Thát). **Không** làm phần của 4.3/4.5 ở đây.
- GDD Campaign Structure (gdds/gdd-GameTest-2026-10-15/gdd.md:242–259): 6 trận cố định; mưu kế mở dần (VKNT trận 5, Sát Thát trận 6).
- Kiến trúc: quyết định 16 "Một scene chính, đổi giữa các màn: Menu, Trận, Chuyển trận" (game-architecture.md:254); `enum Screen { MENU, BATTLE, TRANSITION, ERROR }` (dòng 898); cây thư mục `src/core/campaign_progress.gd`, `src/data/campaign_loader.gd`, `src/ui/level_transition.gd`, `data/chien_dich.json` (dòng 567–608); `CampaignData` là đối tượng chỉ đọc (dòng 914); `result_banner.gd` "bỏ nút khi có menu, 4.2" (dòng 587); F5 chạy ở mọi màn hình.

### Hiện trạng code (đọc trước khi sửa)

- `src/app/main.gd` (sau 4.1 + review): `_ready()` dựng tiêu đề, `BoardView`, `BattleInput`, `Hud`, `Tooltip`, `ResultBanner` (`retry_pressed` → `_start_battle`), **`MainMenu`**, `Notice`, `BattleView`, nhãn phiên bản, `DevTools`; dev thì `_ai_overlay` được `move_child` xuống dưới menu. Cuối `_ready`: có `level_id()` thì `_start_battle()`, không thì `_show_menu()`.
  - `_start_battle()`: `_level_id` rỗng → `FIRST_LEVEL_ID` (`"tran_01"`); nạp `StatsLoader` + `LevelLoader`, gom lỗi, lỗi → `_show_error`; ok → `BattleController.start`, `_battle_view.begin_battle()`, `_set_menu_visible(false)`, `_screen = BATTLE`.
  - `_on_playback_finished(snapshot)`: vẽ bàn cuối, `_result_banner.show_result(snapshot.phase, snapshot.defeat_reason)`.
  - `_show_menu()` / `_show_error()` / `_set_menu_visible()`: mẫu dừng trận và ẩn/hiện màn. `_toggle_coords`/`_toggle_ai_intents` chặn khi `_screen != BATTLE`. `_on_f2` khi `_controller == null` chép báo lỗi "không có trận".
- `src/ui/result_banner.gd`: một nút "Chơi lại trận" (`retry_pressed`), `FOCUS_NONE`, `_relayout()` nới khung theo nội dung, `show_result(phase, defeat_reason)`.
- `src/ui/main_menu.gd`: mẫu màn toàn màn hình dựng bằng code (nền, `CenterContainer`, `TitleLabel`, nút `FOCUS_NONE`).
- `src/core/level_data.gd`: `name` (khóa `"ten"`), `stratagems: Array[int]` (khóa `"muu_ke_mo"`, `Stratagem.Kind`). Tên mưu kế hiển thị: khóa `stratagem.vuon_khong_nha_trong`, `stratagem.sat_that` (đã có trong `text.csv`); tra tên file của Kind qua `Stratagem` (xem `BoardLayers.read_stratagems` / `BugReport.stratagem_names`).
- `src/data/stats_loader.gd`, `json_file.gd`, `level_loader.gd`: mẫu bộ nạp (gom lỗi, câu lỗi tiếng Việt, `JsonFile.label`).
- Máu tướng: `UnitFactory.create` lấy máu từ `Stats` mỗi lần `BattleController.start` → hồi đầy máu là tự nhiên; AC3 chỉ cần test chốt lại (đừng thêm cơ chế mang máu).
- Dữ liệu: `tran_01`…`tran_05` có `"ten"` ("Trận 1", "Trận 2 — Ải Lãnh Kinh", …); chỉ `tran_05` có `"muu_ke_mo": ["vuon_khong_nha_trong"]`.

### Điều phải giữ

- `--dev --tran=N`, `?dev=1&tran=N` vào thẳng trận; menu 4.1; màn hình lỗi; F1/F2/F3/F5; nhãn phiên bản; `SaveProbe`; `McpRuntime`.
- Không đụng luật (`src/core/rules*`), dữ liệu trận, kịch bản.
- Lời giải `tests/kich_ban/tran/tran_0N_loi_giai.json` vẫn chạy như cũ.

### Luật kiến trúc phải theo

- Chỉ `main.gd` đổi màn; tối đa 1 autoload (`AppState`). UI chỉ phát signal.
- `src/core/campaign_data.gd` không I/O, không Node (bị `check_boundaries.sh` kiểm). Nạp file chỉ ở `src/data/`.
- Chữ qua `tr()`, khóa `<man>.<muc>`; log qua `Log.*`; gõ kiểu tĩnh.
- Lỗi dữ liệu trả `LoadResult`, không `assert()`.

### Bài học từ story trước

- Review 4.1: màn toàn màn hình phải nằm **dưới** `_notice` (F2) và **trên** bảng F3; nút `FOCUS_NONE`; test phím ở màn không-trận phải kiểm `BattleInput` thật có phát signal để test không đạt suông.
- 3.12/3.13/4.1: thêm khóa `text.csv` phải sinh lại `text.vi.translation`; khóa có dấu phẩy để trong ngoặc kép.
- 4.1: không đánh `[x]` cho việc chưa làm đủ (ảnh chụp).

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh mọi nơi.
- Mọi thao tác làm được bằng một cú bấm chuột; phím tắt khai báo trong InputMap.
- Cửa sổ 1280×720; GoPeak `inject_mouse_click` nhận `x`, `y` pixel, chỉ khi `--dev`.
- Nói với tác giả bằng tiếng Việt, các bước thử.

### Quyết định của tác giả (chốt 2026-10-30)

1. **Số trận:** chuỗi có 5 trận; Story 4.5 thêm trận 6 bằng một dòng trong `chien_dich.json`.
2. **Khi thắng:** bảng "Thắng!" có nút "Tiếp" (thay "Chơi lại trận"); bấm mới sang màn chuyển trận.
3. **Hết chuỗi:** màn kết thúc "Đã thắng cả chiến dịch" + nút "Về menu".
4. **Mưu kế mở:** vẫn ghi trong file trận (`"muu_ke_mo"`); `chien_dich.json` chỉ ghi thứ tự trận.

### Mặc định AI chọn (tác giả sửa được)

- Màn chuyển trận ghi tên trận kế từ `"ten"` của file trận.
- Trận dev ngoài chuỗi: thắng thì "Đánh lại trận này" + "Về menu".
- F5 ở màn chuyển trận mở trận kế.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.2]
- [Source: _bmad-output/planning-artifacts/game-architecture.md] dòng 254, 567–608, 898, 914
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Campaign Structure]
- [Source: _bmad-output/implementation-artifacts/4-1-man-hinh-chinh.md] (mẫu màn, review findings)
- [Source: _bmad-output/project-context.md]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
