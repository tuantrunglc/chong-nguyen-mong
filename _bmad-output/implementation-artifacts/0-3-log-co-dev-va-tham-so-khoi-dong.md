---
baseline_commit: 747f150
---

# Story 0.3: Log, cờ dev và tham số khởi động

Status: ready-for-dev

## Story

Là tác giả kiêm tester,
tôi muốn có một chế độ dev tách riêng,
để tôi có công cụ còn người thân chơi thử thì không thấy gì lạ.

## Acceptance Criteria

1. **Cho** game chạy với `--dev` (trên web là `?dev=1`), **thì** góc màn hình hiện chữ "DEV".
2. **Cho** game chạy không có cờ dev, **khi** bấm F1–F5, **thì** không có gì xảy ra: không có chữ "DEV", không có dòng log nào mới trong terminal.
3. **Khi** chạy với `?dev=1&tran=3` hoặc `--dev --tran=3`, **thì** game ghi nhận số trận 3. Ở E0 chỉ cần terminal in đúng dòng `[INFO][app] tran=3`. **Không** bật dev thì `tran` bị bỏ qua (tác giả chốt 2026-10-17): game chạy như không có tham số, terminal chỉ in `[WARN][app] bỏ qua tran=3 vì chưa bật dev`.
4. **Và** có lớp static `Log` với 4 cấp ERROR/WARN/INFO/DEBUG, giữ 200 dòng gần nhất trong bộ nhớ. DEBUG chỉ ghi khi bật dev. Không dùng `print()` ở chỗ khác: `tools/check_boundaries.sh` báo trượt nếu có lệnh `print*()` nằm ngoài `src/debug/log.gd`.
5. **Và** (bổ sung từ kiến trúc) tham số sai như `--tran=abc`, `--tran=0` hay `--xyz` **không** làm game dừng. Terminal in một dòng `[WARN][app] ...` bằng tiếng Việt, ghi rõ tham số sai, rồi game chạy như không có tham số đó.
6. **Và** `tools/test.sh` xanh, có test GUT cho `Log`, cho việc đọc tham số (`LaunchOptions.parse`) và cho việc phím F1–F5 bị khóa khi không bật dev.

## Tasks / Subtasks

- [ ] **Task 1: Lớp `Log`** (AC: 4)
  - [ ] 1.1 Tạo `game/src/debug/log.gd`: `class_name Log`, không `extends` (mặc định RefCounted), **chỉ có hàm và biến static**, **không phải autoload**.
    - `const MAX_LINES: int = 200`
    - `static var debug_enabled: bool = false`. `AppState` đặt giá trị này theo cờ dev (Task 3).
    - `static var _lines: PackedStringArray`
    - `static func error(system: String, message: String) -> void`, cùng `warn`, `info`, `debug`.
    - `static func get_lines() -> PackedStringArray`: trả **bản sao**, để F2 (Story 2.13) dùng sau này.
    - `static func clear() -> void`: dùng trong test.
  - [ ] 1.2 Định dạng dòng: `"[%s][%s] %s" % [cap, system, message]`, với `cap` là `ERROR`/`WARN`/`INFO`/`DEBUG`. Ví dụ `[INFO][app] tran=3`. Hàm `Log` **không** tự đổi chữ hoa/thường hay thêm bớt dấu chấm; người gọi tự viết thông điệp đúng mẫu "chữ thường, không chấm cuối câu" của kiến trúc.
  - [ ] 1.3 Nơi in: ERROR và WARN dùng `printerr()`, INFO và DEBUG dùng `print()`.
    - **Không** dùng `push_error()`/`push_warning()`. GUT coi `push_error` là lỗi engine và **làm trượt test**, nên mọi test đi qua đường ghi log ERROR (ví dụ bộ nạp ở Story 1.1) sẽ trượt oan.
    - Đã kiểm 2026-10-17 trên Godot 4.7.2 + GUT 9.7.1: test gọi `printerr` vẫn đạt.
  - [ ] 1.4 DEBUG khi `debug_enabled == false`: **không in và không lưu vào bộ nhớ**. Các cấp khác luôn in và luôn lưu.
  - [ ] 1.5 Bộ nhớ: thêm dòng vào cuối `_lines`; vượt `MAX_LINES` thì bỏ dòng cũ nhất (`remove_at(0)`). Đừng tối ưu bằng ring buffer: 200 dòng thì không đáng.
  - [ ] 1.6 Viết `game/tests/test_log.gd`. `before_each`: `Log.clear()` và `Log.debug_enabled = false`. `after_each`: trả lại y như vậy, vì biến static còn sống qua các file test. Các ca:
    - mỗi cấp ra đúng định dạng `[CẤP][he_thong] thông điệp`;
    - ghi 201 dòng thì còn đúng 200, dòng đầu tiên là dòng thứ 2 đã ghi;
    - DEBUG lúc tắt dev không có trong `get_lines()`; bật thì có;
    - sửa mảng do `get_lines()` trả về không làm đổi bộ nhớ của `Log`;
    - `clear()` làm rỗng bộ nhớ.

- [ ] **Task 2: Đọc tham số khởi động, `LaunchOptions`** (AC: 3, 5)
  - [ ] 2.1 Tạo `game/src/app/launch_options.gd`: `class_name LaunchOptions extends RefCounted`.
    - Trường: `var dev: bool = false`, `var tran: int = 0` (0 nghĩa là không chọn trận), `var warnings: Array[String] = []`.
  - [ ] 2.2 `static func parse(user_args: PackedStringArray, url_query: String) -> LaunchOptions`: **hàm thuần**, không đọc OS, không ghi log, để test được trực tiếp. Lỗi được trả trong `warnings`; người gọi tự ghi log.
    - Đọc `user_args` trước, rồi tới `url_query`.
    - Cùng một khóa xuất hiện nhiều lần thì **giá trị hợp lệ sau cùng** thắng.
  - [ ] 2.3 Luật cho tham số desktop (`user_args`):
    - `--dev` → `dev = true`.
    - `--tran=N`: N qua được `String.is_valid_int()` và `>= 1` thì `tran = N`.
    - Còn lại (`abc`, `0`, `-2`, `3.5`, rỗng) → `warnings` thêm `tham số --tran không hợp lệ: "<giá trị>", cần số nguyên từ 1`, và `tran` giữ giá trị cũ.
    - Mọi tham số khác (kể cả `--tran 3` có dấu cách, `--dev=1`) → `bỏ qua tham số lạ: "<tham số>"`.
  - [ ] 2.4 Luật cho chuỗi URL (`url_query`, ví dụ `?dev=1&tran=3`):
    - Bỏ dấu `?` đầu nếu có, tách theo `&`, mỗi cặp tách ở dấu `=` **đầu tiên**, giá trị qua `uri_decode()`. Chuỗi rỗng hoặc cặp rỗng (`&&`) thì bỏ qua, không báo.
    - `dev=1` → `dev = true`. `dev` có giá trị khác thì im lặng bỏ qua, coi như tắt.
    - `tran=N`: cùng luật như desktop; câu báo dùng `tham số ?tran không hợp lệ: ...`.
    - Khóa khác → `bỏ qua tham số lạ trên URL: "<khóa>"`.
    - **Chưa** kiểm N lớn hơn số trận: chưa có danh sách trận. Story 1.x (nạp trận theo `tran`) sẽ báo nếu trận không tồn tại.
  - [ ] 2.5 `static func read_current() -> LaunchOptions`:
    - Nếu `OS.has_feature("web")`: đọc `JavaScriptBridge.eval("window.location.search", true)`. Kết quả là `Variant`: kiểm `is String` rồi ép kiểu; không phải chuỗi thì dùng `""`. Gọi `parse(PackedStringArray(), query)`.
    - Ngược lại: gọi `parse(OS.get_cmdline_user_args(), "")`.
    - `OS.get_cmdline_user_args()` chỉ trả các tham số đứng **sau** `--`. `tools/chay.sh` đã chạy `"$GODOT" --path game -- "$@"`, và đã kiểm 2026-10-17: ra `["--dev", "--tran=3"]`.
  - [ ] 2.6 Viết `game/tests/test_launch_options.gd`, kiểm cả `dev`, `tran` và `warnings` (đúng câu, đúng thứ tự). Các ca:
    - rỗng;
    - `--dev`;
    - `--tran=3`;
    - `--dev --tran=3`;
    - `--tran=abc`, `--tran=0`, `--tran=-2`, `--tran=3.5`, `--tran=`;
    - `--tran=2 --tran=4` (ra 4);
    - `--tran=4 --tran=abc` (vẫn 4, có 1 cảnh báo);
    - `--xyz`;
    - `?dev=1&tran=3`;
    - `dev=1` (không có `?`);
    - `?dev=0`;
    - `?tran=x`;
    - `?foo=1`;
    - `?tran=%33` (uri_decode ra 3).

- [ ] **Task 3: Autoload `AppState`** (AC: 1, 3, 5)
  - [ ] 3.1 Tạo `game/src/app/app_state.gd`: `extends Node`, **không có `class_name`**. Godot báo lỗi nếu `class_name` trùng tên autoload. Đây là **autoload duy nhất** của dự án (kiến trúc, luật 4).
    - Có `var launch: LaunchOptions`.
    - Trong `_ready()`:
      - `launch = LaunchOptions.read_current()`;
      - `Log.debug_enabled = launch.dev`;
      - mỗi câu trong `launch.warnings` → `Log.warn("app", câu)`;
      - nếu `launch.dev` thì `Log.info("app", "dev=1")`;
      - nếu `launch.tran > 0` và `launch.dev` thì `Log.info("app", "tran=%d" % launch.tran)`;
      - nếu `launch.tran > 0` mà **không** `launch.dev` thì `Log.warn("app", "bỏ qua tran=%d vì chưa bật dev" % launch.tran)` rồi đặt `launch.tran = 0`, để mọi chỗ đọc `AppState.launch.tran` sau này (E1) thấy 0. `LaunchOptions.parse` vẫn đọc `tran` bình thường, không biết luật này: luật nằm ở `AppState`.
    - **Không** ghi gì khi không có tham số nào.
  - [ ] 3.2 Thêm vào `game/project.godot`, viết bằng tay, giữ nguyên các phần khác:
    ```
    [autoload]

    AppState="*res://src/app/app_state.gd"
    ```
  - [ ] 3.3 Autoload **cũng chạy khi GUT chạy test** (đã kiểm 2026-10-17). Lúc đó không có tham số người dùng (các cờ `-gdir=...` không phải user args), nên `AppState` im lặng. Đừng để `AppState` đọc file hay làm gì khác: E1 mới thêm `stats`, tiến độ, cài đặt.

- [ ] **Task 4: `DevTools` và chữ "DEV"** (AC: 1, 2)
  - [ ] 4.1 Tạo `game/src/debug/dev_tools.gd`: `class_name DevTools extends Node2D`. Code debug chỉ nằm trong `src/debug/` (kiến trúc, luật 5).
  - [ ] 4.2 `func setup(enabled: bool) -> void`:
    - `enabled == false`: đặt `_enabled = false`, `set_process_unhandled_input(false)`, rồi `return`. Không tạo chữ, không đăng ký phím.
    - `enabled == true`:
      - đăng ký 5 action `dev_f1`…`dev_f5` vào `InputMap` bằng code, mỗi action một `InputEventKey` với `physical_keycode = KEY_F1`…`KEY_F5`. Chỉ thêm khi `not InputMap.has_action(...)`.
      - tạo `Label` "DEV" ở góc **trên trái** (lề 8px), cỡ chữ 20, màu đỏ `Color(0.85, 0.1, 0.1)`. Bàn cờ bắt đầu ở x=332 nên không đè lên.
    - **Vì sao đăng ký bằng code:** project-context yêu cầu phím tắt đi qua InputMap. Viết `InputEventKey` tay vào `project.godot` thì dài và dễ sai. Không bật dev thì action không tồn tại, nên chắc chắn không phím nào có tác dụng.
  - [ ] 4.3 `_unhandled_input(event)`:
    - Dòng đầu tiên là `if not _enabled: return`. Kiến trúc yêu cầu luôn kiểm cờ dev trước khi chạy, kể cả khi đã tắt xử lý input.
    - Với mỗi action, `event.is_action_pressed(action, false, true)` thì `Log.debug("dev", ...)` rồi `get_viewport().set_input_as_handled()`.
    - Câu log theo bảng dưới, chữ thường, không chấm cuối:

    | Phím | Câu log | Story làm thật |
    |---|---|---|
    | F1 | `f1: chưa có công cụ tọa độ (story 1.2)` | 1.2 |
    | F2 | `f2: chưa có sao chép báo lỗi (story 2.13)` | 2.13 |
    | F3 | `f3: chưa có xem ý định ai (story 2.6)` | 2.6 |
    | F4 | `f4: không dùng` | — |
    | F5 | `f5: chưa có nạp lại dữ liệu (story 1.6)` | 1.6 |

  - [ ] 4.4 Sửa `game/src/app/main.gd`: trong `_ready()`, **sau** khi thêm `_board_view` và `_version_label`:
    - `var dev_tools: DevTools = DevTools.new()`
    - `dev_tools.setup(AppState.launch.dev)`
    - `add_child(dev_tools)`

    Giữ nguyên bàn cờ, nhãn phiên bản, `BUILD_INFO_PATH`, `_read_version()`.
  - [ ] 4.5 Viết `game/tests/test_dev_tools.gd`. Tạo `DevTools` bằng `add_child_autofree(DevTools.new())`, gọi `setup(...)`, rồi gọi thẳng `_unhandled_input(ev)` với `InputEventKey` (`physical_keycode = KEY_F1`, `pressed = true`). Các ca:
    - **tắt dev:** `Log.get_lines()` không thêm dòng nào, không có node con `Label`, `InputMap.has_action("dev_f1")` là false;
    - **bật dev:** có đúng dòng `[DEBUG][dev] f1: chưa có công cụ tọa độ (story 1.2)`, và có `Label` chữ "DEV".

    `before_each`/`after_each`: `Log.clear()`, đặt lại `Log.debug_enabled`, và xóa 5 action nếu có (`InputMap.erase_action`), để các test không ảnh hưởng nhau. Bật dev trong test thì tự đặt `Log.debug_enabled = true`, vì test không chạy qua `AppState`.

    Đây là test logic khóa phím, chạy được không cần màn hình. Phần nhìn chữ "DEV" vẫn do tác giả test bằng mắt.

- [ ] **Task 5: Luật "không `print()` ngoài `Log`"** (AC: 4)
  - [ ] 5.1 Trong `tools/check_boundaries.sh`:
    - **bỏ** luật core `\bprint(err|raw|t|_rich)?\(` ("lõi luật không được dùng print");
    - **thêm** luật cho toàn `src/`, miễn đúng file `"$SRC/debug/log.gd"` (tham số thứ 5 của `quet`), mẫu `'\bprint(err|raw|s|t|_rich|_debug|_verbose)?\('`, lý do `"chỉ Log được in ra console (dùng Log.info/warn/error/debug)"`.
  - [ ] 5.2 Thêm luật core: mẫu `'\bLog\.'`, lý do `"lõi luật không được ghi log"`. Lý do: kiến trúc nói lõi chỉ được phụ thuộc vào `src/core/`, và không ghi log trong vòng phân giải. `src/data/` **được** dùng `Log` (luật 2), nên không chặn ở đó.
  - [ ] 5.3 Cập nhật bộ mẫu `tools/mau_ranh_gioi/` theo cơ chế `# mong_doi:` có sẵn từ review Story 0.2 (xem `README.md` trong thư mục đó):
    - `vi_pham/core/in_ra.gd`: đổi dòng `# mong_doi:` sang lý do mới;
    - thêm `vi_pham/battle/in_ra.gd` (`extends Node2D`, có `prints("x")`): lý do mới;
    - thêm `vi_pham/core/ghi_log.gd` (`extends RefCounted`, có `Log.info("x", "y")`): `lõi luật không được ghi log`;
    - thêm `hop_le/debug/log.gd` (có `print(line)` và `printerr(line)`): phải đạt.
  - [ ] 5.4 Chạy `tools/check_boundaries.sh tools/mau_ranh_gioi/vi_pham`: mỗi file mẫu mới phải hiện đúng lý do. Chạy `hop_le` phải đạt. Sau đó `tools/test.sh` bước 1 phải "đạt".

- [ ] **Task 6: Dọn chú thích và ghi chú** (AC: —)
  - [ ] 6.1 `tools/chay.sh` dòng 3: bỏ "(game đọc ở Story 0.3)". Câu mới: `# Mọi tham số được chuyển nguyên vào game (--dev, --tran=N).` Không sửa gì khác trong file.
  - [ ] 6.2 Thêm vào `_bmad-output/implementation-artifacts/deferred-work.md` một mục cho Story 0.5:
    - **Nội dung mục:** "Chưa kiểm chứng: trên itch.io, game chạy trong iframe có địa chỉ riêng (`html5.itch.zone/...`). Thêm `?dev=1` vào link trang itch.io **có thể không** tới được game. Story 0.5 phải thử: (1) link trang + `?dev=1`; (2) mở thẳng địa chỉ iframe + `?dev=1`. Ghi lại cách nào chạy được."
    - **Lý do:** `LaunchOptions` đọc `window.location.search` của chính iframe.

- [ ] **Task 7: Kiểm tra** (AC: 1–6)
  - [ ] 7.1 Viết test trước (Task 1.6, 2.6, 4.5), chạy `tools/test.sh` thấy **trượt** vì chưa có class. Ghi vào Debug Log. Lỗi `Identifier not declared` được báo trượt chứ không xanh giả: đây là điều review 0.2 đã sửa.
  - [ ] 7.2 Viết code tới khi `tools/test.sh` **xanh**. Số test dự kiến khoảng 7 + 6 + 19 + 2 ≈ 34. Ghi số thật vào Debug Log.
  - [ ] 7.3 `tools/chay.sh --dev --tran=3`, chạy headless bằng `--quit-after` nếu được, hoặc đọc output terminal: phải thấy `[INFO][app] dev=1` và `[INFO][app] tran=3`.
  - [ ] 7.4 `tools/chay.sh --tran=3` (không dev): thấy `[WARN][app] bỏ qua tran=3 vì chưa bật dev`, không có `[INFO][app] tran=3`. `tools/chay.sh --dev --tran=abc --xyz`: phải thấy 2 dòng `[WARN][app] ...` đúng câu ở Task 2.3, và game vẫn mở.
  - [ ] 7.5 Chụp khung hình bằng `--write-movie <file>.png --quit-after N` (máy **không** cho `screencapture`):
    - có `--dev`: chữ "DEV" đỏ ở góc trên trái, bàn cờ và nhãn phiên bản vẫn đúng chỗ;
    - không có `--dev`: không có chữ "DEV".

    Mở ảnh xem rồi ghi kết quả vào Debug Log. Lưu ý: `--write-movie` truyền **trước** `--`, tham số game để sau `--`.
  - [ ] 7.6 Thử vi phạm: tạm thêm `print("x")` vào `game/src/app/main.gd` → bước 1 của `tools/test.sh` trượt, ghi `src/app/main.gd:<dòng>: chỉ Log được in ra console...`. Gỡ ra rồi chạy lại cho xanh.
  - [ ] 7.7 Commit khi xanh. Lời commit gợi ý: `Thêm Log, cờ dev và tham số khởi động (Story 0.3)`. Chuyển story sang `review`.

## Dev Notes

### Bối cảnh

- Story 0.1 và 0.2 đã xong (commit `747f150`).
- `game/` có:
  - `project.godot` (chưa có `[autoload]`, chưa có `[input]`);
  - `scenes/main.tscn`;
  - `src/app/main.gd`, `src/app/build_info.gd`;
  - `src/battle/board_view.gd`;
  - `tests/test_build_info.gd` (7 test);
  - `addons/gut/` (GUT 9.7.1).
- `tools/` có `_godot.sh`, `cai_dat.sh`, `chay.sh`, `test.sh`, `check_boundaries.sh`, `mau_ranh_gioi/`.
- Repo **chưa có** `game/src/debug/`. Story này tạo nó.
- Chưa có màn hình trận, chưa có trận nào. `tran` chỉ được ghi nhận và log, chưa mở trận (E1).
- Ngân sách E0 khoảng 12 giờ cho 6 story. Story này khoảng 2 giờ.

### File sẽ sửa (đọc trước khi sửa)

**`game/src/app/main.gd`** (hiện tại, 30 dòng): `extends Node2D`.
- `_ready()` tạo `BoardView` rồi `add_child`.
- Sau đó tạo `Label` có text `"v%s · %s" % [_read_version(), BuildInfo.read_commit(BUILD_INFO_PATH)]`, cỡ chữ 14, canh phải và canh dưới, `size = (400, 40)`, đặt ở `BoardView.viewport_size - size - (8, 8)`.
- `_read_version()` đọc `application/config/version` (đang là `0.1.0`).
- **Thay đổi:** chỉ thêm 3 dòng tạo `DevTools` ở cuối `_ready()` (Task 4.4).
- **Giữ nguyên:** mọi thứ khác. Nhãn phiên bản **luôn** hiện, kể cả khi không bật dev.

**`game/project.godot`** (viết tay, không mở editor): có `[application]`, `[debug]` (`untyped_declaration=2`, `exclude_addons=true`), `[display]`, `[rendering]`.
- **Thay đổi:** thêm khối `[autoload]`. Godot thường đặt khối này ngay sau `[application]`, nhưng thứ tự không quan trọng.
- Không thêm `[input]`, vì phím dev đăng ký bằng code.
- Sau khi sửa, chạy `--import` không được làm hỏng hay tự viết lại file.

**`tools/check_boundaries.sh`**: hàm `quet thu_muc mau ly_do [loai_tru] [mien]` đã có sẵn tham số miễn một file (đang dùng cho `effects.gd`). Luật mới dùng đúng tham số đó. Thứ tự các luật quyết định thứ tự dòng in ra. Không quan trọng, nhưng nên đặt luật print toàn `src/` cạnh luật `.hp/.cell`.

**`tools/test.sh`**: **không sửa**. Bước 1 tự kiểm bộ mẫu bằng các dòng `# mong_doi:`, nên chỉ cần thêm hoặc sửa file mẫu (Task 5.3).

**`tools/chay.sh`**: chỉ sửa chú thích dòng 3. Đã có `--import` trước khi chạy và `exec "$GODOT" --path game -- "$@"`.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Công cụ thật của F1 (tọa độ), F5 (nạp lại), F2 (báo lỗi), F3 (ý định AI) | 1.2, 1.6, 2.13, 2.6 |
| Mở thẳng trận N theo `tran` | E1 (khi có `LevelLoader`) |
| Kiểm `tran` lớn hơn số trận | E1 |
| Đưa chữ qua `tr()`, file `i18n/text.csv` | 0.4 |
| Build web và thử `?dev=1` thật trên trình duyệt / itch.io | 0.5 (xem Task 6.2) |
| Ghi log ra file | Không làm. Kiến trúc chỉ yêu cầu console + 200 dòng trong bộ nhớ |
| `AppState` chứa `stats`, tiến độ, cài đặt | E1, E4 |

### Luật kiến trúc phải theo

- **Log:** lớp static `Log` (`class_name Log`, chỉ hàm static), **không phải autoload**. Định dạng `[CẤP][hệ_thống] thông điệp`, chữ thường, không chấm cuối. Nơi ghi là console (trên web là Console của trình duyệt) và 200 dòng gần nhất trong bộ nhớ. DEBUG chỉ khi bật dev. Không dùng `print()` trực tiếp. Lõi luật không ghi log trong vòng phân giải. [Source: game-architecture.md#Ghi log]
- **Công cụ debug:** bật bằng `?dev=1` (web) hoặc `--dev` (desktop). Không bật dev thì mọi phím debug không có tác dụng. **Code debug vẫn nằm trong bản phát hành** nhưng bị khóa, để tester và người thân chơi cùng một bản. Nhãn phiên bản luôn hiện. [Source: game-architecture.md#Công cụ debug; quyết định #12]
- **Một autoload duy nhất:** `app_state.gd` (tiến độ, cài đặt, cờ dev). [Source: game-architecture.md#Ranh giới kiến trúc mục 4; #Cây thư mục]
- **Vị trí file:** `src/debug/log.gd`, `src/debug/dev_tools.gd`, `src/app/app_state.gd`, `src/app/launch_options.gd`. [Source: game-architecture.md#Cây thư mục; #Bản đồ hệ thống → vị trí, mục 16]
- **Code debug chỉ nằm trong `src/debug/`** và luôn kiểm cờ dev trước khi chạy. [Source: game-architecture.md#Ranh giới kiến trúc mục 5]
- **`src/data/` được phụ thuộc vào `src/debug/log.gd`**. Lõi (`src/core/`) thì không. [Source: game-architecture.md#Ranh giới kiến trúc mục 1–2]
- **Phím tắt khai báo trong InputMap**, không bắt phím trực tiếp. [Source: project-context.md#Nền tảng và build]
- **Đi xuống thì gọi hàm, đi lên thì phát signal; UI lấy dữ liệu từ `AppState`.** `main.gd` đọc `AppState.launch.dev` rồi gọi `dev_tools.setup(...)` là đúng mẫu. [Source: game-architecture.md#Mẫu giao tiếp; #Mẫu truy cập dữ liệu]
- **Gõ kiểu tĩnh mọi nơi**, kể cả test. `JavaScriptBridge.eval` trả `Variant`: kiểm `is String` rồi ép. Vòng `for` cũng phải có kiểu (`for a: String in ...`). [Source: project-context.md#Luật riêng của Godot]

### Ghi chú kỹ thuật (đã kiểm trên Godot 4.7.2 + GUT 9.7.1, ngày 2026-10-17, trên bản sao tạm)

- `class_name Log` hợp lệ, không trùng lớp nào có sẵn. Hàm toán `log()` viết thường nên không đụng.
- Lớp chỉ có `static var` + `static func` chạy được. `static var` sống suốt phiên chạy, nên test phải tự `clear()`.
- Autoload khai báo trong `[autoload]` **được nạp khi GUT chạy** (`-s res://addons/gut/gut_cmdln.gd`): `_ready()` của nó chạy, log của nó nằm trong `build/test/gut.log`.
- Lúc chạy GUT, `OS.get_cmdline_user_args()` trả `[]`. Lúc chạy `--path game -- --dev --tran=3`, nó trả `["--dev", "--tran=3"]`.
- `ClassDB.class_exists("JavaScriptBridge")` là true trên desktop, nên code gọi `JavaScriptBridge` vẫn biên dịch được. Chỉ **gọi** nó khi `OS.has_feature("web")`.
- `printerr()` trong test **không** làm GUT báo trượt. `push_error()` thì có (mặc định `-gfailure_error_types`), xem Task 1.3.
- `tools/test.sh` bắt chuỗi `SCRIPT ERROR|Parse Error` trong `gut.log`. **Đừng** viết câu log nào chứa hai cụm này, nếu không test sẽ báo trượt oan.
- `--import` lần đầu sinh file `.uid` cho mỗi `.gd` mới. Commit các file này.
- Trình duyệt có phím riêng cho F1 (trợ giúp) và F5 (tải lại trang). Story này chưa build web nên chưa gặp. **Rủi ro cho Story 1.6 / 0.5:** trên web, F5 có thể tải lại trang thay vì tới game. Đây là việc của story đó; ở đây đừng đổi phím.

### Cấu trúc file sau story

```
game/
├── project.godot                 # + [autoload] AppState
├── src/
│   ├── app/
│   │   ├── main.gd               # + tạo DevTools
│   │   ├── app_state.gd          # MỚI (autoload, không class_name)
│   │   └── launch_options.gd     # MỚI
│   └── debug/
│       ├── log.gd                # MỚI
│       └── dev_tools.gd          # MỚI
└── tests/
    ├── test_log.gd               # MỚI
    ├── test_launch_options.gd    # MỚI
    └── test_dev_tools.gd         # MỚI
tools/
├── chay.sh                       # sửa chú thích
├── check_boundaries.sh           # luật print toàn src/, luật Log trong core
└── mau_ranh_gioi/
    ├── vi_pham/core/in_ra.gd     # đổi mong_doi
    ├── vi_pham/core/ghi_log.gd   # MỚI
    ├── vi_pham/battle/in_ra.gd   # MỚI
    └── hop_le/debug/log.gd       # MỚI
```

Kèm theo các file `.uid` do Godot sinh.

### Testing

- Test GUT: `test_log.gd`, `test_launch_options.gd`, `test_dev_tools.gd`. Đều chạy không cần màn hình.
- Không có test tự động cho việc nhìn thấy chữ "DEV" (UI). Kiểm bằng khung hình `--write-movie` (Task 7.5) và bằng mắt tác giả.
- **Hướng dẫn tác giả tự test** (ghi vào Completion Notes):
  1. Gõ `tools/test.sh` → dòng cuối là `✅ N/N test đạt`.
  2. Gõ `tools/chay.sh --dev --tran=3` → góc trên trái có chữ **DEV** màu đỏ. Terminal có `[INFO][app] dev=1` và `[INFO][app] tran=3`. Bấm F1 → terminal thêm `[DEBUG][dev] f1: chưa có công cụ tọa độ (story 1.2)`. Đóng game.
  3. Gõ `tools/chay.sh` (không có gì thêm) → **không** có chữ DEV. Bấm F1–F5 → terminal **không** thêm dòng nào.
  4. Gõ `tools/chay.sh --tran=3` (không có `--dev`) → **không** có `[INFO][app] tran=3`; chỉ có dòng `[WARN][app] bỏ qua tran=3 vì chưa bật dev`.
  5. Gõ `tools/chay.sh --dev --tran=abc` → terminal có `[WARN][app] tham số --tran không hợp lệ: "abc", cần số nguyên từ 1`, game vẫn mở.

### Previous Story Intelligence (Story 0.2 và review)

- **Bẫy xanh giả:** GUT thoát mã 0 khi file test lỗi cú pháp hoặc chưa import. `tools/test.sh` đã chặn các bẫy này, và sau review còn chặn thêm:
  - script game lỗi cú pháp, qua `import.log`;
  - test không có assert nào. **Mỗi test phải có ít nhất một assert**, nếu không sẽ trượt.
- **Bộ mẫu ranh giới** dùng dòng `# mong_doi: <lý do>`, chép **đúng chữ** lý do trong `check_boundaries.sh`. Đổi chữ lý do mà quên đổi mẫu thì bước 1 báo "công cụ kiểm ranh giới bị hỏng". Đó là cố ý.
- Đếm file test: `test.sh` so số file `test_*.gd` với số file thật sự chạy. Đừng tạo file `test_*.gd` rỗng.
- `_godot.sh` có `set -euo pipefail`. Mọi lệnh có thể thoát ≠ 0 trong script phải bọc lại. Story này chỉ sửa chú thích `chay.sh` và luật trong `check_boundaries.sh`, nên ít đụng.
- `JSON.parse_string()` tự in ERROR; dùng `JSON.new().parse()`. Story này không đọc JSON.
- Chụp màn hình: dùng `--write-movie`, **không** dùng `screencapture` (bị chặn trên máy này).
- Lời commit tiếng Việt. Chỉ commit khi `tools/test.sh` xanh.

### Git Intelligence

- 5 commit gần nhất:
  - `747f150 Sửa theo code review Story 0.2`
  - `271e529 Thêm tools/test.sh, GUT 9.7.1 và kiểm ranh giới (Story 0.2)`
  - `0a8b7c8 Story 0.2: đặt baseline_commit về commit tạo story`
  - `38ce361 Tạo story 0.2`
  - `03e6007 Sửa theo code review Story 0.1`
- Mẫu đã có:
  - GDScript: tên tiếng Anh, chú thích `##` tiếng Việt ở đầu file, gõ kiểu đủ, hằng `UPPER_SNAKE_CASE`.
  - Shell: biến và thông báo tiếng Việt không dấu.
  - `BuildInfo` là ví dụ lớp chỉ có hàm static (`static func read_commit`). `Log` và `LaunchOptions.parse` theo cùng kiểu.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- Godot **4.7.2.stable**, GUT **v9.7.1**. Không tự nâng phiên bản.
- Gõ kiểu tĩnh mọi nơi; `untyped_declaration` là error, áp cả lên `game/tests/`.
- `app_state.gd` là autoload duy nhất; `Log` là lớp static.
- Log qua `Log.error/warn/info/debug("he_thong", "...")`; không `print()`. Từ story này, `check_boundaries.sh` bắt lỗi này trên toàn `src/`.
- F1–F5 không có tác dụng khi không bật dev. Phiên bản và mã commit luôn hiện.
- Không dùng `Thread`. Scene nhỏ và phẳng: không thêm node vào `main.tscn`, mọi thứ tạo bằng code.
- "Xong" nghĩa là `tools/test.sh` xanh rồi commit.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### Quyết định của tác giả (2026-10-17)

1. **`tran` chỉ dùng được khi bật dev.** Không có `--dev` / `?dev=1` thì `tran` bị bỏ qua, chỉ có một dòng WARN trong console (người thân không thấy gì).
2. **Chữ "DEV" không qua `tr()`**, giống nhãn phiên bản: nhãn kỹ thuật, không dịch.

### References

- `_bmad-output/planning-artifacts/epics.md#Story 0.3`
- `_bmad-output/planning-artifacts/game-architecture.md`: #Ghi log, #Công cụ debug, #Ranh giới kiến trúc, #Cây thư mục, #Bản đồ hệ thống → vị trí, #Mẫu giao tiếp, #Mẫu truy cập dữ liệu, quyết định #12 và #16
- `_bmad-output/project-context.md`: #Luật riêng của Godot, #Tổ chức code, #Test, #Nền tảng và build
- `_bmad-output/implementation-artifacts/0-2-mot-lenh-de-chay-toan-bo-test.md`: Dev Notes, Review Findings
- `tools/mau_ranh_gioi/README.md` (cơ chế `# mong_doi:`)

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List
