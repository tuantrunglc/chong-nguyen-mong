---
baseline_commit: 0994ad5
---

# Story 1.1: Nạp chỉ số và trận từ file, báo lỗi bằng tiếng Việt

Status: done

## Story

Là tác giả,
tôi muốn trận và chỉ số nằm trong file tôi tự sửa được, và được báo rõ khi sửa sai,
để khỏi phải nhờ AI mỗi lần sửa một con số.

## Acceptance Criteria

1. **Cho** `game/data/chi_so.json` và `game/data/tran/tran_01.json` hợp lệ, **khi** mở game với `--dev --tran=1`, **thì** game nạp trận không có lỗi **và** terminal in đúng dòng `[INFO][battle] nạp trận tran_01`.
   - Không có `--tran` (hoặc không bật dev, khi đó `tran` bị bỏ qua theo Story 0.3) thì game nạp **trận 1**, vì chưa có màn hình chính (Story 4.1). **[MẶC ĐỊNH, chờ tác giả xác nhận]**
   - `--dev --tran=9` (không có file `tran_09.json`) thì hiện màn hình lỗi `data/tran/tran_09.json: không đọc được file`, game không sập.
2. **Khi** đổi một ký hiệu trong lớp `dia_hinh` thành ký hiệu lạ (ví dụ `X`) rồi chạy `--dev`, **thì** màn hình lỗi ghi rõ file, dòng, cột và ký hiệu sai, ví dụ `data/tran/tran_01.json: "dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"`. Game không sập.
   - "dòng" và "cột" đếm từ 1 như người đếm trong file; "ô" là tọa độ trong game `cot,hang` đếm từ 0 (khớp với F1 ở Story 1.2). **[MẶC ĐỊNH, chờ tác giả xác nhận]**
3. **Khi** file có nhiều lỗi cùng lúc (kể cả lỗi ở cả `chi_so.json` lẫn file trận), **thì** màn hình liệt kê **tất cả** lỗi, không chỉ lỗi đầu tiên.
4. **Khi** `chi_so.json` thiếu một khóa, **thì** màn hình lỗi ghi tên khóa bị thiếu, ví dụ `data/chi_so.json: thiếu khóa "tuong.nguyen_khoai.tam_di"`.
5. **Và** khi **không** bật dev, màn hình lỗi chỉ hiện thông báo ngắn (`tr("error.data_short")`) kèm nút "Về menu" (`tr("error.back_to_menu")`), **không** hiện chi tiết lỗi. Chi tiết vẫn ghi vào log `[ERROR][data] ...`, xem bằng terminal hoặc F12.
   - Bấm "Về menu" thì về màn hình bàn cờ trống như hiện nay (menu tạm, tới Story 4.1 mới có menu thật). **[MẶC ĐỊNH, chờ tác giả xác nhận]**
   - Khi bật dev, màn hình lỗi cũng có nút này.
6. **Và** `game/tests/test_loaders.gd` kiểm từng loại lỗi trong bảng "Danh mục câu báo lỗi" (Dev Notes): mỗi loại phải ra **đúng nguyên văn** câu báo lỗi. Có test cho file thật `chi_so.json` và `tran_01.json` nạp được không lỗi. (FR2, FR4)
7. **Và** (bổ sung từ kiến trúc) nhãn phiên bản và chữ DEV vẫn hiện khi đang ở màn hình lỗi; `tools/test.sh` xanh; không có số cân bằng nào nằm trong code (ADR-006).

## Tasks / Subtasks

- [x] **Task 1: Kiểu dữ liệu trong lõi** (AC: 1, 6)
  - [x] 1.1 `game/src/core/unit_type.gd`: `class_name UnitType extends RefCounted`, enum không tên `enum { NGUYEN_KHOAI, PHAM_NGU_LAO, TRAN_KHANH_DU, BO_BINH, KY_BINH, CUNG_KY }` để viết được `UnitType.NGUYEN_KHOAI` đúng như bảng đặt tên của kiến trúc. Thêm `static func is_general(type: int) -> bool`.
  - [x] 1.2 `game/src/core/terrain.gd`: `class_name Terrain extends RefCounted`, `enum { PLAIN, RIVER, FOREST, SPIKES, GRANARY, VILLAGE, PASS }` (`.` `~` `#` `^` `L` `D` `A`). Thêm `static func is_walkable(t: int) -> bool` (PLAIN, SPIKES, PASS đi vào được; RIVER, FOREST, GRANARY, VILLAGE không).
  - [x] 1.3 `game/src/core/stats.gd`: `class_name Stats extends RefCounted`, chỉ đọc sau khi tạo. Giữ `Dictionary` (UnitType → Dictionary khóa → int). Hàm: `value(type: int, key: String) -> int`, `max_hp(type: int) -> int`, `move_range(type: int) -> int`. Hàm đòn (`damage`, `push_distance`…) để story E2 thêm khi dùng.
  - [x] 1.4 `game/src/core/level_data.gd`: `class_name LevelData extends RefCounted`. Trường: `format_version: int`, `name: String`, `mission: Mission` (`enum Mission { ELIMINATE, HOLD_PASS }`), `size: Vector2i`, `terrain: PackedInt32Array` (theo hàng, `index = hang * size.x + cot`), `units: Array[UnitPlacement]`. Hàm `terrain_at(cell: Vector2i) -> int`.
    - Lớp con `class UnitPlacement extends RefCounted` có `type: int`, `cell: Vector2i`, gán **chỉ trong `_init(p_type, p_cell)` và không có dấu chấm** (`cell = p_cell`), vì `check_boundaries.sh` bắt mọi `.cell =` ngoài `effects.gd`.
    - Thứ tự `units` cố định: tướng theo ký hiệu `1`, `2`, `3`; rồi quân Nguyên **theo `thu_tu_dich`**. Story 1.2/2.x cấp id (tướng 1–3, quân Nguyên từ 101) dựa trên thứ tự này.
  - [x] 1.5 Không file nào ở trên dùng `FileAccess`, `Log`, `Node`, `print`. Chỉ phụ thuộc file khác trong `src/core/`.

- [x] **Task 2: Bộ nạp trong `src/data/`** (AC: 1–4, 6)
  - [x] 2.1 `game/src/data/load_result.gd`: `class_name LoadResult extends RefCounted`. `var data: RefCounted` (Stats hoặc LevelData), `var errors: Array[String]`, `var warnings: Array[String]`, thuộc tính chỉ đọc `ok` (`get: return errors.is_empty()`), `add_error(msg)`, `add_warning(msg)`. `data` là `null` khi `ok` là false.
  - [x] 2.2 `game/src/data/json_file.gd` (hoặc hàm static trong `load_result.gd`, tùy dev; đừng chép mã đọc JSON hai lần): đọc file → bỏ BOM `﻿` ở đầu nếu có → `JSON.new().parse()` (**không** dùng `JSON.parse_string()`, nó tự in ERROR) → kiểm gốc là `Dictionary`. Trả lỗi theo danh mục (E-DOC, E-JSON, E-ROOT). Có hàm đọc số nguyên chung (`int` hoặc `float` không có phần lẻ đều nhận, rồi `int()`), dùng cho cả hai bộ nạp.
  - [x] 2.3 `game/src/data/board_text.gd`: `class_name BoardText extends RefCounted`, hàm static dùng chung (Story 1.3 kịch bản luật và Story 2.13 F2 sẽ dùng lại):
    - bảng ký hiệu `TERRAIN_SYMBOLS` (`.`→PLAIN … `A`→PASS) và `UNIT_SYMBOLS` (`1`,`2`,`3`,`B`,`K`,`C`; `.` là ô trống);
    - tách một dòng bàn cờ thành các ô: **đổi tab thành dấu cách**, rồi `split(" ", false)` (chịu được dấu cách thừa ở đầu, cuối, giữa);
    - `parse_cell("1,0") -> Vector2i` (chịu dấu cách quanh số, ví dụ `" 1 , 0 "`), báo không hợp lệ nếu không phải hai số nguyên.
  - [x] 2.4 `game/src/data/stats_loader.gd`: `class_name StatsLoader`. `static func load_stats(path: String) -> LoadResult` (đọc file rồi gọi hàm dưới) và `static func parse_stats(text: String, file_label: String) -> LoadResult` (thuần, để test). Kiểm đủ khóa theo bảng "Định dạng `chi_so.json`", mỗi giá trị là số nguyên đủ nhỏ nhất, `_gan` ≤ `_xa`. Gom **mọi** lỗi rồi mới trả về.
  - [x] 2.5 `game/src/data/level_loader.gd`: `class_name LevelLoader`. `static func load_level(path: String) -> LoadResult` và `static func parse_level(text: String, file_label: String) -> LoadResult`. Kiểm theo mục "Luật kiểm file trận". Gom **mọi** lỗi. Khóa lạ thì thêm cảnh báo (E-EXTRA), không phải lỗi.
  - [x] 2.6 `file_label` = đường dẫn bỏ `res://` (ví dụ `data/tran/tran_01.json`). Bộ nạp **không** gọi `Log`; bên gọi (main.gd) ghi log. Như vậy test không in hàng loạt dòng ERROR.

- [x] **Task 3: File dữ liệu** (AC: 1, 6)
  - [x] 3.1 `game/data/chi_so.json` đúng nội dung ở mục "Định dạng `chi_so.json`" (số lấy từ GDD, bảng Unit Types).
  - [x] 3.2 `game/data/tran/tran_01.json` bản đầu (Story 1.2 hiển thị, Story 2.14 hoàn thiện): Tiêu diệt, sông, 2 tướng Nguyễn Khoái và Phạm Ngũ Lão, 3 Bộ binh. Dùng nội dung ở mục "Nội dung `tran_01.json` bản đầu".
  - [x] 3.3 Không cần sửa `export_presets.cfg`: `include_filter` đã có `*.json` (Story 0.5). Không thêm `"da_duyet"` vào file dữ liệu.

- [x] **Task 4: Màn hình lỗi** (AC: 2, 3, 5, 7)
  - [x] 4.1 `game/src/ui/error_screen.gd`: `class_name ErrorScreen extends Control`, dựng toàn bộ bằng code (không `.tscn`). `setup(errors: Array[String], dev: bool)`. Signal `back_pressed` (thì quá khứ theo quy ước đặt tên signal), phát khi bấm nút.
    - Bật dev: tiêu đề `tr("error.data_title")`, rồi **mọi** lỗi, mỗi lỗi một dòng (Label `autowrap_mode` bật) trong `ScrollContainer` + `VBoxContainer` (nhiều lỗi vẫn cuộn được, không tràn màn hình), rồi nút "Về menu".
    - Không bật dev: tiêu đề, một dòng `tr("error.data_short")`, nút "Về menu". **Không** có chi tiết lỗi.
    - Đặt trong vùng bàn cờ (rộng ~616, giữa khung 1280×720, dưới tiêu đề game), không che nhãn phiên bản ở góc dưới phải và chữ DEV ở góc trên trái.
  - [x] 4.2 Thêm khóa vào `game/i18n/text.csv` (giữ dòng `app.title`):
    - `error.data_title` = `Dữ liệu bị lỗi`
    - `error.data_short` = `Không mở được trận vì file dữ liệu bị lỗi.`
    - `error.back_to_menu` = `Về menu`
    - Chạy `--import` (bước 3 của `tools/test.sh` tự chạy) để sinh lại `text.vi.translation`; commit cả file đó.
  - [x] 4.3 Câu báo lỗi của bộ nạp **không** đi qua `tr()`: đây là chi tiết cho tester và log, giống ví dụ `LevelLoader` trong kiến trúc. Chữ cố định của giao diện (tiêu đề, câu ngắn, nút) đi qua `tr()`.

- [x] **Task 5: Nối vào `main.gd`** (AC: 1, 3, 5, 7)
  - [x] 5.1 Thêm `enum Screen { MENU, BATTLE, TRANSITION, ERROR }` (đúng tên ở kiến trúc, mục Mẫu trạng thái) và `var _screen: Screen`.
  - [x] 5.2 Thêm biến thường (không static) `stats_path: String = "res://data/chi_so.json"` và `level_dir: String = "res://data/tran"`, để test đổi được **trước khi** `add_child` (sau `instantiate()`).
  - [x] 5.3 Hàm `_start_battle() -> void` (Story 1.6 F5 sẽ gọi lại hàm này): nạp `chi_so.json` **và** file trận (luôn nạp cả hai, gộp lỗi của cả hai) → ghi `Log.warn("data", w)` cho mỗi cảnh báo, `Log.error("data", e)` cho mỗi lỗi → có lỗi thì `_show_error(errors)`; không lỗi thì `AppState.stats = stats`, `Log.info("battle", "nạp trận %s" % level_id)`, `_screen = Screen.BATTLE`.
    - Số trận: `AppState.launch.tran` nếu > 0, ngược lại 1. Tên file `tran_%02d.json`; `level_id` là tên file bỏ `.json` (`tran_01`).
    - Ở story này màn BATTLE nhìn giống MENU (bàn cờ trống). Vẽ địa hình và quân là Story 1.2; **không** vẽ trước.
  - [x] 5.4 `_show_error(errors)`: ẩn `_board_view`, tạo `ErrorScreen`, `setup(errors, AppState.launch.dev)`, nối `back_pressed` trong code → `_show_menu()`. Thêm sao cho nhãn phiên bản và DevTools vẫn nằm **trên** màn hình lỗi (ví dụ `add_child` rồi `move_child` ngay sau `_board_view`).
  - [x] 5.5 `_show_menu()`: bỏ `ErrorScreen` (`queue_free`), hiện lại `_board_view` (7×7 trống), `_screen = Screen.MENU`, `Log.info("app", "về menu")`.
  - [x] 5.6 Gọi `_start_battle()` ở cuối `_ready()`, **sau** khi đã tạo DevTools và McpRuntime (để chữ DEV và MCP vẫn chạy khi dữ liệu lỗi). Giữ nguyên mọi thứ khác của `_ready()` (tiêu đề, `SaveProbe`, nhãn phiên bản).
  - [x] 5.7 `game/src/app/app_state.gd`: thêm `var stats: Stats` (null tới khi nạp xong). Sửa chú thích đầu file. Không nạp file trong `AppState._ready()` (autoload chạy cả khi GUT chạy).

- [x] **Task 6: Test** (AC: 6, 7)
  - [x] 6.1 `game/tests/test_loaders.gd`: mỗi mục trong "Danh mục câu báo lỗi" có ít nhất một test, so **nguyên văn** bằng `assert_eq(r.errors, [...])` (so cả mảng để bắt lỗi thừa). Dựng nội dung bằng `JSON.stringify()` từ một Dictionary hợp lệ mẫu rồi sửa một chỗ; ca cú pháp JSON thì viết chuỗi tay.
  - [x] 6.2 Test ca hợp lệ trên dữ liệu mẫu trong test (không dựa vào số trong file thật, vì tác giả được sửa): đúng `size`, `terrain_at`, thứ tự `units` (tướng 1, 2 rồi Bộ binh theo `thu_tu_dich`, **khác** thứ tự đọc từ trái sang phải), giá trị `Stats`.
  - [x] 6.3 Test file thật: `StatsLoader.load_stats("res://data/chi_so.json").ok` và `LevelLoader.load_level("res://data/tran/tran_01.json").ok` đều true, `errors` rỗng. Tác giả sửa sai file thật thì `tools/test.sh` báo đỏ, kèm câu lỗi.
  - [x] 6.4 Test biên: nhiều lỗi cùng lúc ra đủ, đúng thứ tự (AC 3); số dạng `3.0` được nhận; `2.5` bị từ chối; BOM đầu file; tab và dấu cách thừa trong dòng bàn cờ; `" 1 , 0 "` trong `thu_tu_dich`; khóa lạ ra cảnh báo chứ không ra lỗi; dấu phẩy thừa cuối object vẫn nạp được (Godot 4.7.2 cho phép).
  - [x] 6.5 `game/tests/test_main.gd` (thêm, giữ test cũ đạt):
    - mặc định nạp trận 1 và log có `[INFO][battle] nạp trận tran_01`; `AppState.stats` khác null;
    - `level_dir` trỏ tới thư mục tạm trong `user://` có file trận lỗi 2 chỗ, bật dev → có `ErrorScreen`, liệt kê đủ 2 lỗi, `_board_view` ẩn;
    - không bật dev → `ErrorScreen` không chứa câu lỗi chi tiết nào, có nút;
    - bấm nút (`emit_signal` hoặc `pressed.emit()` trên Button) → `ErrorScreen` bị bỏ, `_board_view` hiện, `_screen == MENU`;
    - `AppState.launch.tran = 9` → lỗi `không đọc được file`.
    - Nhớ trả `AppState.launch.tran`, `AppState.stats` về như cũ trong `after_each`; xóa file tạm.
  - [x] 6.6 Mỗi test có ít nhất một assert (`tools/test.sh` trượt nếu không). Không tạo file `test_*.gd` rỗng.
  - [x] 6.7 Chạy `tools/test.sh` → xanh. Commit kèm các file `.uid` mới, lời commit tiếng Việt.

- [x] **Task 7: Kiểm bằng mắt** (AC: 2, 5, 7)
  - [x] 7.1 Sửa tạm `tran_01.json` (ký hiệu `X` + một tọa độ sai trong `thu_tu_dich`), chạy `tools/chay.sh --dev` nền, chụp bằng GoPeak `capture_screenshot` (xem `CLAUDE.md`): thấy đủ 2 lỗi, chữ DEV, nhãn phiên bản. Chạy lại không `--dev`: chỉ có câu ngắn và nút. Bấm nút bằng `inject_mouse_click` (chỉ khi `--dev`) → về bàn cờ trống. **Trả `tran_01.json` về như cũ** rồi mới commit.
  - [x] 7.2 Ghi hướng dẫn tác giả tự test vào Completion Notes (mẫu ở mục Testing).

### Review Findings

Code review 2026-10-18, diff `0994ad5..58b6751`, gồm ba lớp: Blind Hunter, Edge Case Hunter và Acceptance Auditor.

- [x] [Review][Patch] Trận `giu_ai` phải có ít nhất một ô ải `A` trong `dia_hinh`, thiếu thì báo lỗi (tác giả chốt ngày 2026-10-18, chọn phương án 1; được phép có nhiều ô `A`, Story 3.11 quyết). Thêm câu vào danh mục câu báo lỗi, kèm test [game/src/data/level_loader.gd]
- [x] [Review][Patch] `_start_battle()` chưa gọi lại được: nạp thành công sau một lần lỗi thì màn hình lỗi vẫn còn, bàn cờ vẫn ẩn; nạp lỗi sau một lần thành công thì `AppState.stats` vẫn giữ chỉ số cũ (trái với chú thích "Null tới khi nạp xong") [game/src/app/main.gd:80]
- [x] [Review][Patch] Số quá lớn (`1e20`) được nhận thành 9223372036854775807; câu lỗi in con số đó thay cho giá trị tác giả gõ [game/src/data/json_file.gd:47]
- [x] [Review][Patch] Tọa độ quá dài trong `thu_tu_dich` (ví dụ `"99999999999999999999,0"`) in ERROR của engine ra console; giá trị trên 32 bit thì bị tràn khi đưa vào `Vector2i` và rơi đúng vào một ô hợp lệ [game/src/data/board_text.gd:44]
- [x] [Review][Patch] `phien_ban_dinh_dang` bằng 0 hoặc số âm báo E-INT thay cho E-VER, trong khi luật ghi "phải bằng 1" [game/src/data/level_loader.gd:43]
- [x] [Review][Patch] Chưa có test cho trường hợp `chi_so.json` và file trận cùng lỗi, màn hình phải liệt kê lỗi của cả hai (AC 3); `stats_path` chưa có test nào dùng [game/tests/test_main.gd]
- [x] [Review][Patch] Dấu cách không ngắt (U+00A0, U+3000) trong dòng bàn cờ không được coi là dấu cách, nên báo "ký hiệu lạ" kèm một ký tự vô hình; ký hiệu lạ và khóa lạ được in thô, không qua `JsonFile.show()` [game/src/data/board_text.gd:32]
- [x] [Review][Patch] Hằng `BOM` là một ký tự vô hình gõ thẳng vào code, trình soạn thảo có thể xóa mất; nên viết bằng `char(0xFEFF)` (trong test cũng vậy) [game/src/data/json_file.gd:6]
- [x] [Review][Patch] `test_tran_option_picks_level_file` sẽ hỏng ngay khi có file `tran_09.json` thật; nên dùng thư mục tạm [game/tests/test_main.gd:147]
- [x] [Review][Patch] `test_village_symbol_is_known` chỉ lặp lại `test_valid_level_loads`, không kiểm ô `D` thành `Terrain.VILLAGE` [game/tests/test_loaders.gd:208]
- [x] [Review][Defer] `LevelData.terrain_at` không kiểm ô ngoài bàn: x âm hoặc quá lớn thì đọc nhầm sang dòng khác [game/src/core/level_data.gd:30] — deferred, chưa có chỗ gọi (Story 1.2)
- [x] [Review][Defer] `Stats.value` trả 0 khi gõ sai khóa, không báo gì [game/src/core/stats.gd:15] — deferred, chưa có chỗ gọi (Story 2.x)

## Dev Notes

### Bối cảnh

- E0 xong (Story 0.1–0.6). Commit gần nhất `0994ad5`. Đây là story đầu tiên của E1 và là story đầu tiên có **dữ liệu trận** và **code trong `src/core/`, `src/data/`, `src/ui/`** (ba thư mục này chưa tồn tại).
- Game hiện tại: `main.gd` vẽ tiêu đề "Hào Khí Đông A", bàn 7×7 trống (`BoardView`), nhãn phiên bản, `DevTools` (F1–F5 chỉ ghi log), `SaveProbe`, `McpRuntime`.
- `LaunchOptions.tran` là số nguyên ≥ 1, chỉ còn giá trị khi bật dev (`require_dev_for_tran`, tác giả chốt 2026-10-17). `?tran=thu_ba_tuong` (chữ) là việc của Story 1.2, **đừng** sửa `LaunchOptions` ở đây.
- Ngân sách E1 ~18 giờ / 6 story. Story này khoảng 3–4 giờ.

### File sẽ sửa (đọc trước khi sửa)

**`game/src/app/main.gd`** (~60 dòng, `extends Node2D`, không `class_name`).
- `_ready()` hiện làm theo thứ tự: đặt tiêu đề cửa sổ → `_title_label` → `_board_view` (BoardView) → `_version_label` → `SaveProbe.bump` + log `[INFO][luu_thu]` → `DevTools` → `McpRuntime.start_if_enabled`.
- **Thay đổi:** thêm `Screen`, `stats_path`, `level_dir`, `_start_battle()`, `_show_error()`, `_show_menu()`; gọi `_start_battle()` cuối `_ready()`.
- **Giữ nguyên:** tên `_title_label`, `_board_view`, `_version_label` (`test_main.gd` đọc trực tiếp); nhãn phiên bản luôn hiện; `SaveProbe` luôn chạy; DevTools và MCP chạy trước khi nạp dữ liệu.

**`game/src/app/app_state.gd`**: autoload duy nhất, không `class_name`. Hiện chỉ có `var launch: LaunchOptions`. **Thêm** `var stats: Stats`. Không thêm autoload khác.

**`game/i18n/text.csv`**: hiện chỉ có `keys,vi` và `app.title,Hào Khí Đông A`. **Thêm** 3 khóa ở Task 4.2. `test_i18n.gd` tự kiểm mọi khóa dịch được trên máy tiếng Anh.

**`game/tests/test_main.gd`**: 6 test, `before_each` đặt `SaveProbe.path` sang `user://test_main/`, `after_each` trả `AppState.launch.dev`, xóa InputMap `dev_f*`. **Thêm** test ở Task 6.5; dọn thêm `AppState.launch.tran`, `AppState.stats`, file trận tạm. Từ story này, mỗi lần tạo `main` sẽ nạp file thật: `test_counts_each_open...` và `test_dev_badge...` vẫn phải đạt.

**Không sửa:** `tools/test.sh`, `tools/check_boundaries.sh`, `export_presets.cfg`, `project.godot`, `LaunchOptions`, `BoardView`, `DevTools`.

### Định dạng `chi_so.json`

Khóa tiếng Việt không dấu, `snake_case` (kể cả tên tướng: `nguyen_khoai`, không phải `NGUYEN_KHOAI`; chữ UPPER chỉ dùng trong code). Số lấy từ GDD (Unit Types and Classes):

```json
{
  "tuong": {
    "nguyen_khoai": { "mau": 3, "tam_di": 3, "sat_thuong": 2, "do_day": 1 },
    "pham_ngu_lao": { "mau": 3, "tam_di": 3, "sat_thuong": 1, "tam_danh_gan": 2, "tam_danh_xa": 4 },
    "tran_khanh_du": { "mau": 3, "tam_di": 3, "tam_danh": 3, "tam_keo": 2 }
  },
  "quan_nguyen": {
    "bo_binh": { "mau": 3, "tam_di": 2, "sat_thuong": 1 },
    "ky_binh": { "mau": 2, "tam_di": 3, "sat_thuong": 1 },
    "cung_ky": { "mau": 1, "tam_di": 3, "sat_thuong": 1, "tam_ban_gan": 2, "tam_ban_xa": 3 }
  }
}
```

| Khóa | Nghĩa | Nhỏ nhất |
|---|---|---|
| `mau` | Máu tối đa | 1 |
| `tam_di` | Số ô đi tối đa | 0 |
| `sat_thuong` | Sát thương đòn chính | 0 |
| `do_day` | Nguyễn Khoái: số ô đẩy | 0 |
| `tam_danh_gan`, `tam_danh_xa` | Phạm Ngũ Lão: lao trúng vật đầu tiên ở ô thứ 2–4 | 1 |
| `tam_danh` | Trần Khánh Dư: tìm vật đầu tiên trong vòng 3 ô | 1 |
| `tam_keo` | Trần Khánh Dư: kéo về 2 ô ("tầm kéo" theo kiến trúc, ví dụ "giảm từ 2 xuống 1") | 0 |
| `tam_ban_gan`, `tam_ban_xa` | Cung kỵ: ô đích cách 2–3 ô | 1 |

- Trần Khánh Dư **không** có `sat_thuong`: "0 sát thương" là luật (Sát Thát không cộng cho đòn kéo), không phải con số để chỉnh.
- Tham số va chạm, hầm chông, mưu kế, hồi máu kho lương: story E2/E3 tương ứng thêm khóa khi làm luật đó. Story này **không** thêm trước.
- Khóa lạ (ví dụ tác giả gõ `tam_dii`) → cảnh báo E-EXTRA **và** lỗi thiếu `tam_di`.
- Trong code, ánh xạ khóa → `UnitType` để trong `StatsLoader` (hằng `const`), không duyệt theo khóa Dictionary của JSON để quyết thứ tự: duyệt theo danh sách cố định trong code để lỗi luôn ra cùng thứ tự.

### Nội dung `tran_01.json` bản đầu

Lấy từ ví dụ trong kiến trúc, bỏ tướng `3` (trận 1–2 chỉ có 2 tướng, FR5):

```json
{
  "phien_ban_dinh_dang": 1,
  "ten": "Trận 1",
  "kieu": "tieu_diet",
  "dia_hinh": [
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . . . . .",
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . ~ . . ."
  ],
  "quan": [
    ". B . . . B .",
    ". . . . . . .",
    ". . . . . . .",
    ". . . . . . .",
    ". . . . . B .",
    ". . . . . . .",
    "1 . 2 . . . ."
  ],
  "thu_tu_dich": ["1,0", "5,0", "5,4"],
  "tiep_vien": [],
  "muu_ke_mo": []
}
```

Bố cục chỉ để có dữ liệu chạy được; Story 2.14 thiết kế lại trận 1 kèm lời giải.

### Luật kiểm file trận

**Khóa:**

| Khóa | Bắt buộc | Kiểm ở story này |
|---|---|---|
| `phien_ban_dinh_dang` | Có | Số nguyên, phải bằng 1 |
| `ten` | Có | Chuỗi không rỗng |
| `kieu` | Có | `"tieu_diet"` hoặc `"giu_ai"` |
| `dia_hinh` | Có | Danh sách 7 chuỗi, mỗi chuỗi 7 ô, ký hiệu trong `. ~ # ^ L D A` |
| `quan` | Có | Danh sách 7 chuỗi, mỗi chuỗi 7 ô, ký hiệu trong `. 1 2 3 B K C` |
| `thu_tu_dich` | Có | Danh sách tọa độ `"cot,hang"` |
| `tiep_vien`, `muu_ke_mo` | Không | **Biết tên nhưng chưa đọc** (Story 3.10, 3.12). Không cảnh báo |
| `so_hiep_toi_da`, `long_dan` | Không | **Biết tên nhưng chưa đọc** (Story 3.5, 3.7, theo `sprint-change-proposal-2026-10-18.md`: "Story 1.1 chưa cần biết khóa mới"). Không cảnh báo |
| Khóa khác | — | Cảnh báo E-EXTRA |

**Bàn cờ:**
- Bàn phải là 7×7 (`const BOARD_SIZE: Vector2i = Vector2i(7, 7)` trong `LevelLoader`; đây là quy cách định dạng, không phải số cân bằng). Giai đoạn 1 mới có bàn khác cỡ.
- Một dòng sai số ô thì báo E-ROWLEN cho dòng đó và **bỏ qua** kiểm ký hiệu của dòng đó; các dòng khác vẫn kiểm tiếp.
- Ký hiệu `D` (làng) được nhận như mọi ô khác. Kiểm `long_dan` khi có `D` là việc của Story 3.7.
- Một quân đứng trên ô không đi vào được (`~ # L D`) là lỗi E-BLOCKED. **[MẶC ĐỊNH, chờ tác giả xác nhận]** Chỉ kiểm khi cả hai lớp đều đọc được ở ô đó.
- Mỗi tướng (`1`, `2`, `3`) có nhiều nhất một lần (E-DUPGEN). Phải có ít nhất một tướng (E-NOGEN). Tướng nào có mặt do file quyết (trận 1 có `1`, `2`).
- Không bắt buộc có quân Nguyên.
- Trận `giu_ai` phải có ít nhất một ô ải `A` trong `dia_hinh` (E-NOPASS; tác giả chốt ở code review 2026-10-18). Có nhiều ô `A` được không là việc của Story 3.11. Chỉ kiểm khi cả lớp `dia_hinh` đọc được.

**`thu_tu_dich`:**
- Mỗi mục là chuỗi tọa độ hợp lệ, trong bàn, ô đó có quân Nguyên (`B K C`), không lặp.
- Mọi quân Nguyên trên lớp `quan` phải có mặt đúng một lần.

**Tránh lỗi kéo theo** (một chỗ sai chỉ ra một lỗi):
- E-ORDEMPTY chỉ kiểm khi dòng tương ứng của lớp `quan` đọc được.
- E-NOGEN và E-ORDMISS chỉ kiểm khi lớp `quan` không có lỗi E-ROWS/E-ROWTYPE/E-ROWLEN/E-SYM nào (tướng hay quân có thể nằm ở dòng hỏng).
- E-BLOCKED chỉ kiểm ở ô mà cả hai lớp đều đọc được.

**Thứ tự lỗi** (để test so được cả mảng): lỗi file/JSON → khóa theo thứ tự cột "Khóa" ở bảng trên → trong một lớp bàn cờ, theo dòng rồi theo cột → `thu_tu_dich` theo mục → quân thiếu trong `thu_tu_dich` theo dòng rồi cột. Lỗi JSON (E-DOC, E-JSON, E-ROOT) thì dừng ngay, không kiểm tiếp.

### Danh mục câu báo lỗi (nguyên văn, test so đúng từng chữ)

`<f>` là `file_label` (ví dụ `data/tran/tran_01.json`). Dòng/cột đếm từ 1; "ô x,y" là tọa độ game đếm từ 0. `<giá trị>` in bằng `JSON.stringify(v)` (chuỗi có ngoặc kép, số nguyên in không có `.0`).

| Mã | Khi nào | Câu |
|---|---|---|
| E-DOC | Không đọc được file / file rỗng | `<f>: không đọc được file` |
| E-JSON | JSON sai cú pháp | `<f>, dòng <n>: JSON sai cú pháp (<get_error_message()>)` với `n = get_error_line() + 1` |
| E-ROOT | Gốc không phải object | `<f>: nội dung phải là một object JSON` |
| E-MISS | Thiếu khóa | `<f>: thiếu khóa "<khóa>"` (`chi_so.json` ghi đường đầy đủ: `tuong.nguyen_khoai.tam_di`) |
| E-INT | Không phải số nguyên đủ lớn | `<f>: "<khóa>" phải là số nguyên từ <min> trở lên, đang là <giá trị>` |
| E-TYPE | Sai kiểu (chuỗi/danh sách/object) | `<f>: "<khóa>" phải là <một chuỗi \| một danh sách \| một object>, đang là <giá trị>` |
| E-RANGE | `_gan` > `_xa` | `<f>: "<khóa_gan>" (<a>) lớn hơn "<khóa_xa>" (<b>)` |
| E-VER | Sai phiên bản | `<f>: "phien_ban_dinh_dang" là <v>, game chỉ đọc được bản 1` |
| E-KIND | Sai `kieu` | `<f>: "kieu" là <giá trị>, chỉ được "tieu_diet" hoặc "giu_ai"` |
| E-NAME | `ten` rỗng | `<f>: "ten" không được để trống` |
| E-ROWS | Sai số dòng | `<f>: "<lớp>" có <n> dòng, cần 7` |
| E-ROWTYPE | Dòng không phải chuỗi | `<f>: "<lớp>" dòng <r> phải là một chuỗi, đang là <giá trị>` |
| E-NOPASS | Trận `giu_ai` không có ô `A` | `<f>: trận "giu_ai" phải có ít nhất một ô ải "A" trong "dia_hinh"` |
| E-ROWLEN | Sai số ô trong dòng | `<f>: "<lớp>" dòng <r>: có <n> ô, cần 7` |
| E-SYM | Ký hiệu lạ | `<f>: "<lớp>" dòng <r>, cột <c> (ô <x>,<y>): ký hiệu lạ "<k>"` |
| E-BLOCKED | Quân trên ô chặn | `<f>: "quan" dòng <r>, cột <c> (ô <x>,<y>): quân "<k>" đứng trên ô không đi vào được "<địa hình>"` |
| E-DUPGEN | Tướng lặp | `<f>: "quan" dòng <r>, cột <c> (ô <x>,<y>): tướng "<k>" đã có ở ô <x0>,<y0>` |
| E-NOGEN | Không có tướng | `<f>: "quan" không có tướng nào (cần ít nhất một trong 1, 2, 3)` |
| E-ORDCELL | Mục không phải tọa độ | `<f>: "thu_tu_dich" mục <i>: <giá trị> không phải tọa độ "cot,hang"` |
| E-ORDOUT | Ngoài bàn | `<f>: "thu_tu_dich" mục <i>: ô <x>,<y> nằm ngoài bàn` |
| E-ORDEMPTY | Ô không có quân Nguyên | `<f>: "thu_tu_dich" mục <i>: ô <x>,<y> không có quân Nguyên` |
| E-ORDDUP | Lặp | `<f>: "thu_tu_dich" mục <i>: ô <x>,<y> đã ghi ở mục <j>` |
| E-ORDMISS | Quân thiếu trong thứ tự | `<f>: quân Nguyên "<k>" ở ô <x>,<y> không có trong "thu_tu_dich"` |
| E-EXTRA (cảnh báo) | Khóa lạ | `<f>: bỏ qua khóa lạ "<khóa>"` |

- "mục <i>" đếm từ 1.
- Câu lỗi **không** được chứa `SCRIPT ERROR` hay `Parse Error`: `tools/test.sh` thấy hai cụm này trong log là báo trượt.
- Chỉ dùng ký tự có trong font Be Vietnam Pro và đã có trong `test_font.gd`. **Không** dùng `≥`, `→`, `—`, `…`, ngoặc kép cong. Dùng "từ … trở lên", dấu `:` và ngoặc thường.
- Ví dụ AC 2 khi `X` nằm ở hàng 2 (dòng thứ 3), cột 3 (cột thứ 4): `data/tran/tran_01.json: "dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"`.

### Ghi chú kỹ thuật (đã thử trên Godot 4.7.2 ngày 2026-10-18)

- **Số nguyên trong JSON:** Godot 4.7.2 trả `3` về **`int`** (TYPE_INT), còn `3.0`, `1e2` về `float`. `project-context.md` ghi "JSON trả mọi số về float" là **cũ**. Cách an toàn: nhận cả `int` lẫn `float` có phần lẻ bằng 0, rồi `int()`; `2.5` hay chuỗi `"3"` là lỗi E-INT. Đừng so `typeof(v) == TYPE_FLOAT`.
- **`JSON.get_error_line()` đếm từ 0.** `'{\n"a" 1}'` cho 1, tức dòng 2 trong trình soạn thảo. Vì vậy câu lỗi dùng `+ 1`.
- `JSON.new().parse()` không in gì ra console; `JSON.parse_string()` in ERROR (đã biết từ Story 0.2).
- **Dấu phẩy thừa cuối** (`{"a": 1,}`) được Godot 4.7.2 chấp nhận. Không coi là lỗi.
- **BOM:** file lưu kèm BOM (Notepad trên Windows) làm `parse()` báo "Unexpected character" ở dòng 1. Bỏ ký tự `﻿` đầu chuỗi trước khi parse.
- **Khóa trùng** (`{"a": 1, "a": 2}`) không báo lỗi, giá trị sau thắng. Chấp nhận, không kiểm.
- `FileAccess.get_file_as_string()` với file không tồn tại trả `""`, không in ERROR, `FileAccess.get_open_error()` = 7 (`ERR_FILE_NOT_FOUND`). Gộp thành E-DOC.
- `"a . b".split(" ", false)` **không** tách tab: đổi `\t` thành dấu cách trước.
- Thông điệp `get_error_message()` là tiếng Anh của Godot (ví dụ `Expected '}' or ','`). Giữ nguyên trong ngoặc: tác giả thấy số dòng, AI đọc được chi tiết.
- `check_boundaries.sh`:
  - bắt `.hp =`, `.cell =`, `.hp +=`… ở **mọi** file trong `src/`, trừ `src/core/effects.gd`. Đừng đặt `p.cell = ...` trong loader hay test helper trong `src/` (test ở `game/tests/` không bị quét, nhưng vẫn nên gán qua `_init`);
  - `src/data/` cấm chữ `Node…`, `get_tree(`, `$` đứng trước chữ cái/`"`/`%`. Đừng đặt tên biến có `Node`, đừng dùng `$` trong chuỗi;
  - `src/core/` cấm thêm `FileAccess`, `Log.`, `Input…`, `Time.`, `rand…`, `print`, mọi `extends` khác `RefCounted`.
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` = error, áp cả lên test). Giá trị từ JSON là `Variant`: kiểm `is Dictionary/Array/String/int/float` rồi ép bằng `as`, không dùng `:=` trên nó. Vòng `for` có kiểu (`for row: Variant in rows`).
- Thuộc tính chỉ đọc trong GDScript 4: `var ok: bool:` xuống dòng `get: return errors.is_empty()`.
- `class_name` mới (`UnitType`, `Terrain`, `Stats`, `LevelData`, `LoadResult`, `BoardText`, `StatsLoader`, `LevelLoader`, `ErrorScreen`) chưa trùng lớp nào của Godot 4.7 (dev kiểm lại bằng `ClassDB.class_exists()` nếu nghi; `Terrain` không phải lớp có sẵn của Godot 4).
- `--import` sinh `.uid` cho mỗi `.gd` mới. Commit các file này.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Vẽ địa hình, đồng quân, số máu; F1 tọa độ; `thu_ba_tuong.json`, `?tran=thu_ba_tuong` | 1.2 |
| `BattleState`, `Unit`, `UnitFactory`, cấp id quân | 1.2 / 1.4 (story nào cần trước thì tạo) |
| `scenario_loader.gd`, kịch bản luật, `xem_kich_ban.sh` | 1.3 |
| F5 nạp lại | 1.6 (dùng lại `_start_battle()`) |
| Đọc `tiep_vien`, `muu_ke_mo`, `so_hiep_toi_da`, `long_dan`; kiểm `D` cần `long_dan` | 3.10, 3.12, 3.5, 3.7 |
| Khóa chỉ số cho va chạm, hầm chông, mưu kế, kho lương | E2, E3 |
| Màn hình chính thật, `chien_dich.json` | 4.1, 4.2 |
| Sửa `project-context.md` (dòng "JSON trả mọi số về float") | Đề xuất cho tác giả duyệt; ghi vào Completion Notes, không tự sửa |

### Luật kiến trúc phải theo

- **Tầng:** `src/core` (luật, thuần dữ liệu) → `src/data` (nạp file) → `src/battle` + `src/ui` → `src/app`. `src/data/` chỉ phụ thuộc `src/core/` và `src/debug/log.gd` (story này bộ nạp không cần cả `Log`). [Source: game-architecture.md#Ranh giới kiến trúc]
- **Xử lý lỗi dữ liệu:** bộ nạp trả `{ok, data, errors}`, mỗi lỗi một câu tiếng Việt có file, dòng, giá trị sai; gom **tất cả** lỗi rồi mới trả; không làm sập game; không `assert()` cho lỗi dữ liệu. Bật dev: màn hình lỗi liệt kê đủ. Bản phát hành: thông báo ngắn + nút "Về menu"; chi tiết vào log. [Source: game-architecture.md#Xử lý lỗi]
- **Mẫu truy cập dữ liệu:** file chỉ nạp một lần tại `src/data/`, thành đối tượng chỉ đọc (`Stats`, `LevelData`); lõi nhận dữ liệu qua tham số; UI lấy từ `AppState`; F5 tạo đối tượng mới chứ không sửa đối tượng cũ. [Source: game-architecture.md#Mẫu truy cập dữ liệu]
- **ADR-006 / quyết định #8:** mọi chỉ số trong `chi_so.json`; luật trong code. [Source: game-architecture.md#Architecture Decision Records]
- **Định dạng trận:** JSON, hai lớp bàn cờ chữ, có số phiên bản; ký hiệu và tọa độ như mục "Dữ liệu trận"; bộ nạp chịu dấu cách thừa, kiểm kích thước dòng, ký hiệu lạ, tọa độ ngoài bàn; `thu_tu_dich` đối chiếu lớp `quan`. [Source: game-architecture.md#Dữ liệu trận, chỉ số và kịch bản luật]
- **Đặt tên:** code và tên script tiếng Anh `snake_case`; `class_name` PascalCase; file dữ liệu và khóa JSON tiếng Việt không dấu; tên riêng lịch sử trong code UPPER (`UnitType.NGUYEN_KHOAI`); tọa độ `Vector2i(cot, hang)`, trong file `"cot,hang"`. [Source: game-architecture.md#Quy ước đặt tên]
- **Scene nhỏ và phẳng:** không thêm node vào `main.tscn`, không tạo `.tscn` cho màn hình lỗi; signal nối trong code. [Source: project-context.md#Luật riêng của Godot]
- **Đi xuống gọi hàm, đi lên phát signal:** `main` gọi `error_screen.setup(...)`; `ErrorScreen` báo lên bằng signal. [Source: game-architecture.md#Mẫu giao tiếp]
- **Màn hình:** `enum Screen { MENU, BATTLE, TRANSITION, ERROR }` trong `main.gd`. [Source: game-architecture.md#Mẫu trạng thái]
- **Tất định:** duyệt theo danh sách cố định trong code, không theo khóa Dictionary của JSON. [Source: project-context.md#Test]

### Cấu trúc file sau story

```
game/
├── data/                          # MỚI, tác giả sửa
│   ├── chi_so.json
│   └── tran/
│       └── tran_01.json
├── i18n/
│   ├── text.csv                   # + 3 khóa error.*
│   └── text.vi.translation        # sinh lại
├── src/
│   ├── app/
│   │   ├── main.gd                # + Screen, _start_battle, _show_error, _show_menu
│   │   └── app_state.gd           # + stats
│   ├── core/                      # MỚI
│   │   ├── unit_type.gd
│   │   ├── terrain.gd
│   │   ├── stats.gd
│   │   └── level_data.gd
│   ├── data/                      # MỚI
│   │   ├── load_result.gd
│   │   ├── json_file.gd           # (tùy dev, xem Task 2.2)
│   │   ├── board_text.gd
│   │   ├── stats_loader.gd
│   │   └── level_loader.gd
│   └── ui/                        # MỚI
│       └── error_screen.gd
└── tests/
    ├── test_loaders.gd            # MỚI
    └── test_main.gd               # + test nạp trận, màn hình lỗi
```

Kèm các file `.uid` do Godot sinh.

**Lệch nhỏ so với cây thư mục trong kiến trúc** (ghi vào Completion Notes):
- `unit_type.gd`, `terrain.gd`, `level_data.gd` trong `src/core/` chưa có trong cây. `LevelData` phải ở `core` (không ở `data`) vì `BattleState` (core) sẽ dựng từ nó, mà `core` chỉ được phụ thuộc `core`. Hai enum tách file riêng để `Stats`, `LevelData`, `BoardText` dùng chung mà không phụ thuộc `Unit` (chưa có).
- `json_file.gd` (nếu dev tạo) chưa có trong cây.

### Testing

- `test_loaders.gd`: mọi ca chạy không cần màn hình, dùng `parse_*()` trên chuỗi; chỉ 2 test đọc file thật, 1 test đọc file không tồn tại.
- `test_main.gd`: tạo `main.tscn` thật, kiểm trạng thái node (`_screen`, `ErrorScreen` có hay không, chữ trong các Label). Không kiểm vị trí pixel.
- Không có test tự động cho việc màn hình lỗi trông thế nào. Kiểm bằng ảnh GoPeak (Task 7.1) và bằng mắt tác giả.
- **Hướng dẫn tác giả tự test** (chép vào Completion Notes, sửa số test cho đúng):
  1. Gõ `tools/test.sh` → dòng cuối `✅ N/N test đạt`.
  2. Gõ `tools/chay.sh --dev --tran=1` → bàn cờ trống như cũ, terminal có dòng `[INFO][battle] nạp trận tran_01`.
  3. Mở `game/data/tran/tran_01.json`, ở dòng thứ 3 của `"dia_hinh"` đổi dấu `~` thành `X`, lưu. Gõ lại lệnh ở bước 2 → màn hình lỗi ghi `"dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"`. Game không tắt.
  4. Sửa thêm `"5,4"` trong `"thu_tu_dich"` thành `"9,9"`, lưu, chạy lại → màn hình liệt kê **cả ba** lỗi: ký hiệu lạ `X`; `mục 3: ô 9,9 nằm ngoài bàn`; `quân Nguyên "B" ở ô 5,4 không có trong "thu_tu_dich"`.
  5. Gõ `tools/chay.sh` (không `--dev`) → chỉ thấy "Không mở được trận vì file dữ liệu bị lỗi." và nút **Về menu**. Bấm nút → về bàn cờ trống.
  6. Trả `tran_01.json` về như cũ (hoặc nhờ AI). Mở `game/data/chi_so.json`, đổi chữ `"tam_di"` của Nguyễn Khoái thành `"tam_dii"`, lưu, chạy `tools/chay.sh --dev` → màn hình lỗi có `thiếu khóa "tuong.nguyen_khoai.tam_di"`. Trả lại như cũ.
  7. Gõ `tools/test.sh` lần nữa → xanh (file thật đã đúng lại).

### Previous Story Intelligence (E0)

- **Bẫy xanh giả đã chặn trong `tools/test.sh`:** script lỗi cú pháp (qua `import.log`), test không có assert, lệch số file test, 0 test. Mỗi test phải có assert.
- **`push_error()` làm GUT báo trượt**; `printerr()` thì không. Chỉ log qua `Log`. Bộ nạp không log.
- **`JSON.new().parse()`**, không `JSON.parse_string()` (Story 0.2, `BuildInfo`, `SaveProbe` đã theo mẫu này: đọc `json.data`, kiểm `is Dictionary`, ép kiểu).
- **`SaveProbe`/`BuildInfo` là mẫu lớp chỉ có hàm static** trả giá trị an toàn khi file hỏng; bộ nạp theo cùng kiểu nhưng trả `LoadResult`.
- **Mẫu test đổi đường dẫn:** `SaveProbe.path` (static var) đổi trong `before_each`, trả lại trong `after_each`; tạo thư mục trong `user://` bằng `DirAccess.make_dir_recursive_absolute`. Dùng cùng cách cho file trận tạm.
- **Font:** `allow_system_fallback=false` (Story 0.4): ký tự ngoài font hiện ô vuông. Xem lưu ý ký tự ở danh mục câu lỗi.
- **Theme:** `main_theme.tres` có kiểu `TitleLabel` (đậm, cỡ 28). Dùng nó cho tiêu đề màn hình lỗi.
- **Chụp màn hình:** `tools/chay.sh --dev` ở chế độ nền, chờ ~5 giây, `capture_screenshot` của GoPeak; không dùng `run_project` (headless). `inject_mouse_click` nhận `x`, `y` riêng, chỉ khi `--dev`. Fallback: `--write-movie`. `screencapture` bị chặn trên máy này.
- **F1/F5 trên web** có thể bị trình duyệt chiếm (deferred). Không liên quan story này.
- **Deferred từ 0.3:** "Kiểm `tran` lớn hơn số trận: E1" → story này xử lý bằng E-DOC trên màn hình lỗi (AC 1).
- Lời commit tiếng Việt; chỉ commit khi `tools/test.sh` xanh.

### Git Intelligence

- 5 commit gần nhất: `0994ad5` ghim BMAD tiếng Việt; `bfd8b48` áp dụng đề xuất tăng độ khó (sửa tài liệu, không sửa code); `b569fd7` sửa theo review 0.6; `7bf467b`, `c60d7c3` Story 0.6.
- Mẫu code đã có: chú thích `##` tiếng Việt ở đầu file; tên tiếng Anh; gõ kiểu đủ; hằng `UPPER_SNAKE_CASE`; lớp static (`BuildInfo`, `SaveProbe`, `LaunchOptions.parse`) có hàm thuần để test; test dùng `assert_eq` trên cả mảng thông điệp (xem `test_launch_options.gd`, `_assert_options`).

### Project Context Rules

- Đọc `_bmad-output/project-context.md` và `game-architecture.md` trước khi viết code (CLAUDE.md).
- Godot **4.7.2.stable**, GUT **9.7.1**, chỉ GDScript, không tự nâng phiên bản. Tra API lạ qua Context7 ID `/godotengine/godot-docs/__branch__4.7`.
- Gõ kiểu tĩnh mọi nơi; giá trị JSON là `Variant`, kiểm kiểu rồi ép.
- `src/core/` chỉ `RefCounted`, không Node, không I/O, không log, không ngẫu nhiên.
- `app_state.gd` là autoload duy nhất; `Log` là lớp static.
- Con số cân bằng chỉ trong `data/chi_so.json`. Chữ giao diện qua `tr()`, khóa `<man>.<muc>`.
- Lỗi dữ liệu trả `LoadResult` với câu tiếng Việt; không `assert()`.
- Scene nhỏ và phẳng; lấy node bằng `%Tên` nếu có scene, ở đây tạo bằng code và giữ tham chiếu trong biến.
- Mọi thao tác bằng một cú bấm chuột (nút "Về menu" bấm được bằng chuột; không cần phím).
- MCP chỉ để nhìn và thử; dữ liệu trận sửa trong file, có test đi kèm.
- "Xong" nghĩa là `tools/test.sh` xanh rồi commit. Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### Quyết định mặc định trong story này (chờ tác giả xác nhận, không chặn việc làm)

1. Không có `--tran` (hoặc không bật dev) thì mở trận 1.
2. Nút "Về menu" về bàn cờ trống cho tới khi có menu thật (Story 4.1).
3. Vị trí lỗi ghi "dòng/cột" đếm từ 1, kèm "ô cot,hang" đếm từ 0.
4. Quân đứng trên sông, rừng, kho lương, làng là lỗi dữ liệu.
5. Tên khóa trong `chi_so.json` như bảng ở trên (`tam_danh_gan/xa`, `tam_danh`, `tam_keo`, `tam_ban_gan/xa`, `do_day`).

Nếu tác giả đổi ý trước khi dev bắt đầu, sửa story; nếu sau, sửa code + test.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.1; #Yêu cầu chức năng FR2, FR4; #Yêu cầu bổ sung (từ kiến trúc)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Dữ liệu trận, chỉ số và kịch bản luật; #Xử lý lỗi; #Ghi log; #Cấu hình; #Cây thư mục; #Ranh giới kiến trúc; #Quy ước đặt tên; #Mẫu truy cập dữ liệu; #Mẫu trạng thái; #Mẫu tạo đối tượng]
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Unit Types and Classes; #Terrain and Environmental Effects; #Campaign Structure]
- [Source: _bmad-output/planning-artifacts/sprint-change-proposal-2026-10-18.md#2. Phân tích ảnh hưởng (E1 không đổi)]
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md#Story 0.3]
- [Source: _bmad-output/implementation-artifacts/0-3-log-co-dev-va-tham-so-khoi-dong.md; 0-4; 0-5; 0-6 (Completion Notes, Review Findings)]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Bước đỏ: viết `test_loaders.gd`, `test_core_types.gd` trước; `tools/test.sh` trượt vì `UnitType` chưa có (`Parse Error`, 11/13 file chạy).
- **Sửa ghi chú kỹ thuật của story:** Godot 4.7.2 **vẫn trả mọi số JSON về `float`** (lần thử lúc tạo story đọc nhầm mã kiểu 3 = TYPE_FLOAT thành int). `project-context.md` ("JSON trả mọi số về float") là **đúng**, không cần sửa. Hệ quả: câu lỗi in giá trị qua `JsonFile.show()`, đổi số không phần lẻ về int để in `5` chứ không `5.0` (9 test trượt trước khi sửa).
- Thông điệp Godot cho `'{\n"ten" "a"\n}'` là `Expected ':'`, dòng 2 (sau `+ 1`).
- Kiểm bằng mắt (Task 7.1): sửa tạm `tran_01.json` (`X` ở dòng 3 cột 4, `"5,4"` thành `"9,9"`).
  - `chay.sh --dev` + GoPeak `capture_screenshot`: màn hình "Dữ liệu bị lỗi" liệt kê đủ 3 lỗi; chữ DEV góc trên trái và nhãn `v0.1.0 · ac98e37-sua` vẫn hiện.
  - `inject_mouse_click` vào nút (640, 629) → về bàn cờ trống.
  - Không `--dev` (chụp bằng `--write-movie`): chỉ có "Không mở được trận vì file dữ liệu bị lỗi." và nút "Về menu"; terminal vẫn có 3 dòng `[ERROR][data]`.
  - Trả `tran_01.json` về như cũ; `--dev --tran=1` in `[INFO][battle] nạp trận tran_01`.
- `tools/test.sh` cuối: ✅ 152/152 (trước story 80 + các test của đề xuất; thêm 64 test bộ nạp, 2 test kiểu lõi, 6 test main).

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Lõi (`src/core/`): `UnitType`, `Terrain` (enum không tên, `is_general`, `is_walkable`), `Stats` (chỉ đọc; `value`, `max_hp`, `move_range`), `LevelData` (+ `UnitPlacement`, `terrain_at`). Không Node, không I/O, không log.
- Dữ liệu (`src/data/`): `LoadResult` (`ok`, `data`, `errors`, `warnings`), `JsonFile` (đọc file, bỏ BOM, parse, đọc số nguyên, in giá trị), `BoardText` (ký hiệu, tách dòng chịu dấu cách/tab, `parse_cell`), `StatsLoader`, `LevelLoader`. Gom mọi lỗi, đúng nguyên văn danh mục trong story; bộ nạp không ghi log.
- `ErrorScreen` (`src/ui/`): dev liệt kê mọi lỗi (cuộn được); không dev chỉ câu ngắn; luôn có nút "Về menu" phát `back_pressed`. Câu lỗi tắt tự dịch (`auto_translate_mode`).
- `main.gd`: `enum Screen`, `stats_path`/`level_dir`, `_start_battle()` (nạp cả hai file, gộp lỗi, log), `_show_error()`, `_show_menu()`. `AppState.stats`.
- Dữ liệu: `game/data/chi_so.json`, `game/data/tran/tran_01.json` (bản đầu). 3 khóa dịch `error.*`.
- **Thứ tự lỗi đã chốt trong code** (khớp danh mục, chi tiết hơn story): file/JSON → `phien_ban_dinh_dang`, `ten`, `kieu` → lớp `dia_hinh` (lỗi từng dòng rồi E-ROWS) → lớp `quan` → kiểm từng ô của `quan` (E-BLOCKED rồi E-DUPGEN) → E-NOGEN → `thu_tu_dich` → E-ORDMISS. Cảnh báo khóa lạ đứng riêng trong `warnings`.
- **Lệch nhỏ so với cây thư mục kiến trúc:** thêm `src/core/unit_type.gd`, `terrain.gd`, `level_data.gd` (LevelData phải ở core vì BattleState sẽ dựng từ nó) và `src/data/json_file.gd` (phần dùng chung của hai bộ nạp). `ErrorScreen` có nút ở cả chế độ dev.
- **Còn chờ tác giả xác nhận** (5 mặc định ghi trong Dev Notes): mở trận 1 khi không chọn trận; "Về menu" về bàn cờ trống; cách ghi dòng/cột/ô; quân đứng trên ô chặn là lỗi; tên khóa `chi_so.json`.
- **Hướng dẫn tác giả tự test:**
  1. Gõ `tools/test.sh` → dòng cuối `✅ 152/152 test đạt`.
  2. Gõ `tools/chay.sh --dev --tran=1` → bàn cờ trống như cũ, terminal có dòng `[INFO][battle] nạp trận tran_01`. Đóng game.
  3. Mở `game/data/tran/tran_01.json`, ở dòng thứ 3 của `"dia_hinh"` đổi dấu `~` thành `X`, lưu. Gõ lại lệnh bước 2 → màn hình "Dữ liệu bị lỗi" ghi `"dia_hinh" dòng 3, cột 4 (ô 3,2): ký hiệu lạ "X"`. Game không tắt.
  4. Sửa thêm `"5,4"` trong `"thu_tu_dich"` thành `"9,9"`, lưu, chạy lại → màn hình liệt kê cả ba lỗi: ký hiệu lạ `X`; `mục 3: ô 9,9 nằm ngoài bàn`; `quân Nguyên "B" ở ô 5,4 không có trong "thu_tu_dich"`.
  5. Gõ `tools/chay.sh` (không `--dev`) → chỉ thấy "Không mở được trận vì file dữ liệu bị lỗi." và nút **Về menu**. Bấm nút → về bàn cờ trống.
  6. Trả `tran_01.json` về như cũ (hoặc nhờ AI). Trong `game/data/chi_so.json` đổi chữ `"tam_di"` của Nguyễn Khoái thành `"tam_dii"`, lưu, chạy `tools/chay.sh --dev` → màn hình lỗi có `thiếu khóa "tuong.nguyen_khoai.tam_di"`. Trả lại như cũ.
  7. Gõ `tools/test.sh` lần nữa → xanh. (Nếu quên trả file về như cũ, test `test_real_level_1_loads` / `test_real_stats_file_loads` sẽ báo đỏ kèm câu lỗi.)

### File List

- game/data/chi_so.json (mới)
- game/data/tran/tran_01.json (mới)
- game/i18n/text.csv
- game/i18n/text.vi.translation
- game/src/app/app_state.gd
- game/src/app/main.gd
- game/src/core/unit_type.gd (mới) + .uid
- game/src/core/terrain.gd (mới) + .uid
- game/src/core/stats.gd (mới) + .uid
- game/src/core/level_data.gd (mới) + .uid
- game/src/data/load_result.gd (mới) + .uid
- game/src/data/json_file.gd (mới) + .uid
- game/src/data/board_text.gd (mới) + .uid
- game/src/data/stats_loader.gd (mới) + .uid
- game/src/data/level_loader.gd (mới) + .uid
- game/src/ui/error_screen.gd (mới) + .uid
- game/tests/test_loaders.gd (mới) + .uid
- game/tests/test_core_types.gd (mới) + .uid
- game/tests/test_main.gd
- _bmad-output/implementation-artifacts/1-1-nap-chi-so-va-tran-tu-file-bao-loi-bang-tieng-viet.md
- _bmad-output/implementation-artifacts/sprint-status.yaml

### Change Log

- 2026-10-18: Làm Story 1.1: nạp `chi_so.json` và file trận, báo lỗi tiếng Việt, màn hình lỗi; 152/152 test đạt.
- 2026-10-18: Sửa theo code review: nạp lại sau lỗi dọn màn hình lỗi và bỏ dữ liệu cũ; chặn số quá lớn và tọa độ quá dài; phiên bản 0/âm báo E-VER; thêm E-NOPASS (trận `giu_ai` phải có ô `A`); chịu dấu cách không ngắt; BOM viết bằng `\uFEFF`; thêm test gộp lỗi hai file (AC 3); 161/161 test đạt.
