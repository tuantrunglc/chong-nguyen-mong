---
baseline_commit: 4285462
---

# Story 1.2: Hiện bàn cờ trận 1 (bố cục đầu tiên)

Status: review

## Story

Là tác giả,
tôi muốn thấy trận 1 hiện ra đúng như file dữ liệu,
để kiểm tra dữ liệu bằng mắt.

## Acceptance Criteria

1. **Cho** `game/data/tran/tran_01.json` như hiện nay (sông cột 3, Nguyễn Khoái ở `0,6`, Phạm Ngũ Lão ở `2,6`, 3 Bộ binh ở `1,0`, `5,0`, `5,4`, nhiệm vụ Tiêu diệt), **khi** chạy `tools/chay.sh --dev --tran=1` (hoặc không có `--tran`), **thì** bàn 7×7 hiện đúng từng ô địa hình và từng quân ở đúng ô ghi trong file (FR1, FR3).
2. **Và** mỗi loại ô có màu riêng: đất trống, sông, rừng, hầm chông, kho lương, làng, ô ải. Mọi ô khác đất trống còn có chữ ngắn ở góc dưới trái (Sông, Rừng, Chông, Kho, Làng, Ải). Màu và chữ theo bảng "Cách vẽ" trong Dev Notes. **[MẶC ĐỊNH, chờ tác giả xác nhận]**
3. **Và** mỗi quân là một đồng tròn có chữ: tướng là `Khoái`, `Lão`, `Dư`; quân Nguyên là `B`, `K`, `C`. Hai phe khác màu (bảng "Cách vẽ"). Chữ lấy từ `i18n/text.csv` qua `tr()`.
4. **Và** mỗi đồng quân hiện **số máu hiện tại** trong một chấm tròn nhỏ ở góc dưới phải đồng quân. Lúc mới vào trận, máu lấy từ `mau` trong `chi_so.json`: tướng 3, Bộ binh 3, Kỵ binh 2, Cung kỵ 1. **[MẶC ĐỊNH về chỗ đặt, chờ tác giả xác nhận]**
5. **Có** thêm file `game/data/tran/thu_ba_tuong.json`: đủ 3 tướng, đủ 3 loại quân Nguyên và đủ 7 loại ô (bố cục ở Dev Notes). File này chỉ mở được khi bật dev:
   - Desktop: `tools/chay.sh --dev --tran=thu_ba_tuong`. Web: `?dev=1&tran=thu_ba_tuong`.
   - Terminal in `[INFO][battle] nạp trận thu_ba_tuong`.
   - Không bật dev thì bỏ `tran` (luật Story 0.3) và mở trận 1.
6. **Khi** bật dev và bấm F1, **thì** mỗi ô hiện tọa độ `cot,hang` ở góc trên trái (gốc `0,0` ở góc trên trái bàn), và mỗi quân hiện id ở góc trên phải ô của nó (tướng 1–3 theo ký hiệu `1` `2` `3`, quân Nguyên từ 101 theo thứ tự `thu_tu_dich`). Bấm F1 lần nữa thì ẩn.
   - Log: `[DEBUG][dev] f1: hiện tọa độ` / `[DEBUG][dev] f1: ẩn tọa độ`.
   - Không bật dev thì F1 không làm gì (như cũ).
7. **Khi** sửa vị trí một quân trong file trận (lớp `quan` và `thu_tu_dich`) rồi chạy lại, **thì** quân hiện ở vị trí mới.
8. **Và** những gì đã có vẫn chạy như cũ:
   - Dữ liệu lỗi thì hiện màn hình lỗi như Story 1.1, bàn cờ ẩn.
   - Bấm "Về menu" thì về bàn cờ **trống**: không địa hình, không quân, không tọa độ F1.
   - Nhãn phiên bản và chữ DEV vẫn hiện.
   - `tools/test.sh` xanh. Không có số cân bằng nào trong code (ADR-006): máu lấy từ `Stats`.

## Tasks / Subtasks

- [x] **Task 1: Lõi trạng thái trận tối thiểu** (`src/core/`, AC: 1, 4, 6)
  - [x] 1.1 `unit.gd` (`class_name Unit extends RefCounted`):
    - Thuộc tính: `enum Side { DAI_VIET, NGUYEN }`; `id: int`, `side: Side`, `type: int` (UnitType), `cell: Vector2i`, `hp: int`.
    - Gán mọi thuộc tính **chỉ trong `_init(p_id, p_type, p_cell, p_hp)`**; `side` suy ra từ `UnitType.is_general`.
    - `check_boundaries.sh` cấm `.hp =` / `.cell =` ở mọi nơi ngoài `core/effects.gd`, kể cả trong `clone()`. Muốn sao chép thì gọi `Unit.new(...)`.
  - [x] 1.2 `unit_factory.gd` (`class_name UnitFactory`): `static func create(id: int, type: int, cell: Vector2i, stats: Stats) -> Unit`, với `hp = stats.max_hp(type)`. Đây là nơi duy nhất tạo quân (luật kiến trúc).
  - [x] 1.3 `battle_state.gd` (`class_name BattleState extends RefCounted`):
    - Thuộc tính: `size: Vector2i`, `terrain: PackedInt32Array` (cùng cách xếp với `LevelData`), `units: Array[Unit]`, `stats: Stats`.
    - `static func from_level(level: LevelData, stats: Stats) -> BattleState`. Id tướng = số ký hiệu (`NGUYEN_KHOAI` → 1, `PHAM_NGU_LAO` → 2, `TRAN_KHANH_DU` → 3). Quân Nguyên lấy id 101, 102… theo đúng thứ tự `level.units` (tức thứ tự `thu_tu_dich`). Mọi quân tạo qua `UnitFactory.create`.
    - `clone() -> BattleState`: sao chép sâu từng `Unit`; `stats` dùng chung (chỉ đọc).
    - `validate() -> Array[String]`: trả rỗng khi trạng thái đúng. Kiểm:
      - id không trùng;
      - quân nằm trong bàn;
      - không có hai quân chung một ô;
      - quân đứng trên ô đi vào được (`Terrain.is_walkable`);
      - `1 <= hp <= stats.max_hp(type)`.
      Câu báo tiếng Việt, có id và ô, ví dụ `quân 101 ở ô 3,0 đứng trên ô không đi vào được`.
    - Hàm tra cứu: `in_bounds(cell) -> bool`, `terrain_at(cell) -> int` (chỉ gọi với ô trong bàn), `unit_at(cell) -> Unit` (null nếu trống), `unit_by_id(id) -> Unit`.
    - Chưa có pha, hiệp, đòn hay cờ đã đi/đã đánh: các story sau sẽ thêm, và khi thêm phải thêm cả vào `clone()`.
  - [x] 1.4 Không thêm `Rules`, `Command`, `BattleEvent`, `Effects`: chúng thuộc Story 1.4/1.5.

- [x] **Task 2: Bộ điều khiển trận tối thiểu** (`src/battle/battle_controller.gd`, AC: 1)
  - [x] 2.1 `class_name BattleController extends RefCounted`.
    - `start(level: LevelData, stats: Stats) -> void`: dựng `BattleState.from_level`. Nếu `validate()` không rỗng thì ghi `Log.error("battle", ...)` cho từng câu. Bộ nạp đã chặn các lỗi này, nên chỉ là lưới an toàn.
    - `snapshot() -> BattleState`: trả `clone()`.
    - Trạng thái sống nằm trong `_state` (riêng), không ai ngoài controller giữ tham chiếu.
  - [x] 2.2 Chưa có `submit()`, signal hay ngăn xếp hủy (Story 1.4/1.5).

- [x] **Task 3: Vẽ địa hình và đồng quân** (`src/battle/`, AC: 1–4, 7, 8)
  - [x] 3.1 `board_view.gd`: thêm `show_state(state: BattleState) -> void`.
    - `state == null` thì về bàn trống như hiện nay.
    - Có trạng thái thì `setup(size.x, size.y)`, vẽ màu từng ô trong `_draw()` (màu theo bảng "Cách vẽ") và đặt chữ ngắn của địa hình bằng `Label` con.
    - **Giữ nguyên** các hằng `CELL_SIZE` và `viewport_size` và cách đặt bàn ở giữa màn hình: `main.gd`, `ErrorScreen` và test tiêu đề đang dựa vào chúng.
  - [x] 3.2 Trong `_ready()`, `BoardView` tạo sẵn hai node con theo thứ tự: lớp chữ địa hình, rồi lớp đồng quân (`_units`). Overlay F1 do `main.gd` thêm vào sau cùng nên luôn nằm trên.
  - [x] 3.3 `static func cell_center(cell: Vector2i) -> Vector2` = `Vector2(cell) * CELL_SIZE + Vector2.ONE * CELL_SIZE / 2.0` (tọa độ trong `BoardView`). Đồng quân, F1 và các story sau đều dùng hàm này.
  - [x] 3.4 Đồng quân giữ theo id, theo mẫu `_sync_tokens` của kiến trúc:
    - quân mới thì tạo `UnitToken`;
    - quân không còn thì `queue_free`;
    - quân còn thì cập nhật vị trí và máu.
    Không dùng object pool.
  - [x] 3.5 `unit_token.gd` (`class_name UnitToken extends Node2D`):
    - `setup(unit: Unit)` và `update(unit: Unit)`.
    - Vẽ hình tròn bằng `_draw()`.
    - Chữ tên và số máu là `Label` con: theo theme chung, font Be Vietnam Pro, đủ dấu.
    - Tên lấy bằng `tr("unit.<ten>")`. Bảng `UnitType → khóa` để trong `unit_token.gd`. Đây là hiển thị, không phải luật.
  - [x] 3.6 Mọi số trong hai file này là kích thước và màu UI (hằng `UPPER_SNAKE_CASE`), không phải số cân bằng.

- [x] **Task 4: Chữ hiển thị** (`game/i18n/text.csv`, AC: 2, 3)
  - [x] 4.1 Thêm khóa (cột `vi`):
    - `unit.nguyen_khoai` = Khoái, `unit.pham_ngu_lao` = Lão, `unit.tran_khanh_du` = Dư;
    - `unit.bo_binh` = B, `unit.ky_binh` = K, `unit.cung_ky` = C;
    - `terrain.river` = Sông, `terrain.forest` = Rừng, `terrain.spikes` = Chông, `terrain.granary` = Kho, `terrain.village` = Làng, `terrain.pass` = Ải.
  - [x] 4.2 Chạy `--import` (bước GUT của `tools/test.sh` tự chạy) để sinh lại `text.vi.translation`, rồi commit file đó. `test_i18n.gd` tự kiểm mọi khóa mới đều dịch được.

- [x] **Task 5: Chọn trận theo tên** (`src/app/launch_options.gd`, `app_state.gd`, `main.gd`; AC: 5)
  - [x] 5.1 Đổi `LaunchOptions.tran` từ `int` sang `String`, với `""` là không chọn trận. Giá trị hợp lệ:
    - số nguyên từ 1, lưu dạng đã chuẩn hóa (`"03"` → `"3"`);
    - hoặc tên file trận khớp `^[a-z][a-z0-9_]*$`, ví dụ `thu_ba_tuong`.
    Mẫu tên này chặn được `../`, dấu và chữ hoa.
  - [x] 5.2 Câu cảnh báo khi sai đổi thành: `tham số --tran không hợp lệ: "<v>", cần số từ 1 hoặc tên file trận (chữ thường không dấu, số, dấu _)` (với web là `?tran`).
    - `require_dev_for_tran()`: `bỏ qua tran=<v> vì chưa bật dev`, nguyên văn như cũ.
    - `app_state.gd`: `Log.info("app", "tran=%s" % launch.tran)`. Với số thì vẫn ra `tran=3` như cũ.
  - [x] 5.3 Thêm `func level_id() -> String`:
    - `""` thì trả `""`;
    - số N thì trả `"tran_%02d" % N`;
    - tên thì trả nguyên tên.
  - [x] 5.4 `main._start_battle()`: `level_id = AppState.launch.level_id()`, rỗng thì `"tran_%02d" % DEFAULT_TRAN`. File là `"%s/%s.json" % [level_dir, level_id]`. Log `nạp trận <level_id>` giữ nguyên.
  - [x] 5.5 Sửa `test_launch_options.gd`:
    - `abc` giờ là tên hợp lệ;
    - thêm ca sai: `Thu`, `../x`, `thu-ba`, `tên`, `1abc`, `0`, `-2`, `3.5`, `""`;
    - thêm ca `level_id()`.
    Sửa `test_main.gd` chỗ `AppState.launch.tran = 9` → `"9"`, và `after_each` đặt `tran = ""`.

- [x] **Task 6: Gắn vào `main.gd`** (AC: 1, 7, 8)
  - [x] 6.1 Nạp thành công thì:
    - `_controller = BattleController.new()`, rồi `_controller.start(_level, AppState.stats)`;
    - `_board_view.show_state(_controller.snapshot())`;
    - cập nhật overlay F1 (nếu có);
    - rồi `_hide_error()` như hiện nay.
    `_start_battle()` phải gọi lại được nhiều lần (F5 ở Story 1.6): mỗi lần tạo controller mới.
  - [x] 6.2 `_show_error()` và `_show_menu()` gọi `_board_view.show_state(null)`, đặt `_controller = null` và xóa nội dung overlay F1. Bàn cờ sau "Về menu" phải trống như AC 8.
  - [x] 6.3 Không thêm `battle_view.gd` / `battle.tscn` ở story này. `BoardView` vẫn là con trực tiếp của `main`; khi có HUD (Story 1.5) mới tách.

- [x] **Task 7: F1 tọa độ và id** (`src/debug/`, AC: 6)
  - [x] 7.1 `coord_overlay.gd` (`class_name CoordOverlay extends Node2D`): `show_state(state: BattleState)`.
    - `null` thì xóa hết.
    - Có trạng thái thì tạo `Label` tọa độ `"%d,%d"` cho mỗi ô (góc trên trái) và `Label` id cho mỗi quân (góc trên phải ô).
    - Ban đầu `visible = false`. `func toggle() -> bool` trả trạng thái mới.
  - [x] 7.2 `dev_tools.gd`: thêm `signal f1_pressed`. Bấm F1 thì `f1_pressed.emit()` thay cho dòng log "chưa có công cụ tọa độ"; F2–F5 giữ nguyên.
  - [x] 7.3 `main.gd`: **chỉ khi `AppState.launch.dev`**, tạo `CoordOverlay` làm con **cuối cùng** của `_board_view`, để nó nằm trên đồng quân và ẩn theo bàn cờ khi có màn hình lỗi. Nối `dev_tools.f1_pressed` vào hàm bật/tắt và ghi `Log.debug("dev", "f1: hiện tọa độ")` / `"f1: ẩn tọa độ"`. Đi lên bằng signal, đi xuống bằng gọi hàm.
  - [x] 7.4 Trên web, F1 có thể bị trình duyệt chiếm (mục đã hoãn trong `deferred-work.md`). Story này chỉ kiểm trên desktop; không thêm chặn phím qua `JavaScriptBridge`.

- [x] **Task 8: File trận thử ba tướng** (AC: 5)
  - [x] 8.1 Tạo `game/data/tran/thu_ba_tuong.json` đúng bố cục ở Dev Notes. Bố cục này đã được kiểm theo luật nạp của Story 1.1: không quân nào đứng trên ô chặn, `thu_tu_dich` đủ và đúng.

- [x] **Task 9: Test** (AC: tất cả)
  - [x] 9.1 `tests/test_battle_state.gd`:
    - `from_level` trên trận mẫu (`LevelLoader.parse_level`) cho ra đúng id, phe, loại, ô và máu.
      - Tướng: id 1, 2.
      - Quân Nguyên: id 101… theo `thu_tu_dich`, **khác** thứ tự đọc từ trái sang phải.
      - Máu bằng `max_hp`.
    - `clone()` sâu: đổi quân trên bản sao (dựng lại bằng `Unit.new` trong test) không làm đổi bản gốc. Hai `units` là hai mảng khác nhau.
    - `validate()` rỗng với `tran_01.json` và `thu_ba_tuong.json` thật.
    - `validate()` ra đúng câu cho từng loại sai: id trùng, ngoài bàn, chung ô, ô chặn, máu 0, máu vượt tối đa.
  - [x] 9.2 `test_loaders.gd`: `test_real_three_generals_level_loads` có 3 tướng, 4 quân Nguyên, `errors` và `warnings` đều rỗng.
  - [x] 9.3 `test_main.gd`:
    - Mở mặc định:
      - `_board_view` có 5 `UnitToken`;
      - token id 101 nằm ở `BoardView.cell_center(Vector2i(1, 0))`;
      - chữ token Nguyễn Khoái là `tr("unit.nguyen_khoai")`;
      - chữ máu là `"3"`.
    - `--tran=thu_ba_tuong` + dev → 7 token, có log `nạp trận thu_ba_tuong`.
    - Cùng tên đó mà **không** dev → `tran` bị bỏ, mở `tran_01`.
    - Màn hình lỗi rồi "Về menu" → 0 token.
    - Dev: F1 (gọi `dev_tools.f1_pressed.emit()`) → overlay hiện, có Label `"0,0"` và `"101"`; bấm lần hai thì ẩn; log đúng hai câu.
    - Không dev: không có `CoordOverlay`.
  - [x] 9.4 `test_dev_tools.gd`: F1 phát `f1_pressed` (`watch_signals`) và không ghi log; F2–F5 ghi log như cũ. Không dev thì không phát.
  - [x] 9.5 `test_core_types.gd` (hoặc `test_battle_state.gd`): `UnitFactory.create` lấy máu từ `Stats` (dùng `Stats.new` với số tự đặt, **không** dùng số trong file thật).
  - [x] 9.6 Chạy `tools/test.sh` → xanh. Commit kèm file `.uid` mới, lời commit tiếng Việt.

- [x] **Task 10: Kiểm bằng mắt** (AC: 1–6)
  - [x] 10.1 Chạy `tools/chay.sh --dev` ở chế độ nền, chờ khoảng 5 giây, chụp bằng GoPeak `capture_screenshot` (xem `CLAUDE.md`).
    - Thấy: sông ở cột giữa, 2 tướng ở hàng dưới, 3 Bộ binh, số máu, chữ DEV, nhãn phiên bản.
    - Bấm F1 bằng `inject_key` rồi chụp lại: thấy tọa độ và id.
  - [x] 10.2 Chụp `--dev --tran=thu_ba_tuong`: thấy đủ 7 loại ô, 3 tướng, B/K/C. Chữ có dấu không vỡ, chữ không tràn khỏi ô.
  - [x] 10.3 Ghi hướng dẫn tác giả tự test vào Completion Notes (mẫu ở mục Testing).

## Dev Notes

### Bối cảnh

- Story 1.1 nạp `chi_so.json` và file trận thành `Stats` và `LevelData`, nhưng màn hình vẫn là bàn cờ trống. Story này **vẽ** dữ liệu đó ra.
- Đây cũng là lúc lần đầu có `BattleState`, `Unit`, `UnitFactory`, `BattleController`. Story 1.4 (chọn tướng, tô ô đi được) và 1.5 (đi, hủy, kết thúc lượt) sẽ dựa vào chúng. Vì vậy chỉ làm phần **tối thiểu nhưng đúng mẫu kiến trúc**: thuần dữ liệu, `clone()` sâu, `validate()`, id theo luật.
- Story này **không có luật**: không đi, không đánh, không pha. Không viết kịch bản trong `tests/kich_ban/`; quy trình kịch bản bắt đầu từ Story 1.3/1.4.

### File sẽ sửa (đọc trước khi sửa)

| File | Hiện nay | Story này đổi | Phải giữ |
|---|---|---|---|
| `game/src/battle/board_view.gd` | `Node2D`, vẽ 7×7 ô màu be + lưới trong `_draw()`, `setup(cols, rows)` đặt bàn giữa màn hình; `CELL_SIZE = 88`, `static var viewport_size` | Thêm `show_state()`, màu địa hình, lớp chữ địa hình, lớp đồng quân, `cell_center()` | `CELL_SIZE`, `viewport_size`, `cols`/`rows`, vị trí bàn (y = 52), nét lưới và viền |
| `game/src/app/main.gd` | `_start_battle()` nạp 2 file → `AppState.stats`, `_level`; `_show_error()`, `_hide_error()`, `_show_menu()`; `stats_path`/`level_dir` cho test | Tạo `BattleController`, gọi `show_state`, overlay F1, chọn trận theo `level_id()` | Mọi hành vi Story 1.1 và các sửa từ code review: nạp lại được, lỗi thì bỏ dữ liệu cũ, gộp lỗi 2 file, thứ tự node (màn hình lỗi ngay sau `_board_view`, nhãn phiên bản và DevTools vẽ sau) |
| `game/src/app/launch_options.gd` | `tran: int`, `_set_tran` nhận số ≥ 1 | `tran: String`, nhận số hoặc tên, `level_id()` | Cách đọc `--dev`/`?dev=1`, cảnh báo tham số lạ, `require_dev_for_tran` |
| `game/src/app/app_state.gd` | Log `tran=%d` | `tran=%s` | Mọi thứ khác |
| `game/src/debug/dev_tools.gd` | F1–F5 chỉ ghi log `chưa có…` | F1 phát `f1_pressed` | Chữ DEV, đăng ký InputMap chỉ khi dev, F2–F5 |
| `game/i18n/text.csv` | 4 khóa | Thêm 12 khóa | Khóa cũ |
| `game/tests/test_main.gd`, `test_launch_options.gd`, `test_dev_tools.gd`, `test_loaders.gd` | — | Như Task 9 | Các test cũ khác vẫn đạt |

### Cách vẽ **[MẶC ĐỊNH, chờ tác giả xác nhận]**

Bàn: ô 88 px, bàn 616×616 ở giữa màn hình 1280×720 (như hiện nay).

| Ô | Ký hiệu | Màu (`Color`) | Chữ góc dưới trái |
|---|---|---|---|
| Đất trống | `.` | `Color(0.93, 0.87, 0.73)` (màu hiện tại) | (không) |
| Sông | `~` | `Color(0.49, 0.71, 0.87)` xanh nước | Sông |
| Rừng | `#` | `Color(0.33, 0.55, 0.31)` xanh lá đậm | Rừng |
| Hầm chông | `^` | `Color(0.80, 0.62, 0.45)` nâu nhạt | Chông |
| Kho lương | `L` | `Color(0.85, 0.70, 0.30)` vàng rơm | Kho |
| Làng | `D` | `Color(0.76, 0.52, 0.40)` đỏ gạch | Làng |
| Ô ải | `A` | `Color(0.70, 0.70, 0.72)` xám đá | Ải |

- Chữ địa hình: cỡ 12, màu `LINE_COLOR` hiện có, cách mép ô 4 px.
- Đồng quân: hình tròn bán kính 34 px ở giữa ô, viền 3 px.
  - Phe Đại Việt: nền `Color(0.70, 0.13, 0.13)` (đỏ), chữ `Color(1.0, 0.95, 0.80)`.
  - Phe Nguyên: nền `Color(0.17, 0.20, 0.28)` (xanh than), chữ trắng.
  - Viền: `LINE_COLOR`.
  - Chữ tên cỡ 18, đậm (`TitleLabel` hoặc font bold), căn giữa.
- Máu: chấm tròn trắng bán kính 11 px, tâm lệch `(+24, +24)` so với tâm đồng quân, số màu tối cỡ 14.
- F1:
  - tọa độ cỡ 12 ở góc trên trái ô, nền đen mờ để đọc được trên mọi màu ô;
  - id quân cỡ 12 ở góc trên phải ô.
  Hai chỗ này không đè lên chữ địa hình (dưới trái) hay chấm máu (dưới phải).
- Tác giả đổi màu thì chỉ sửa hằng trong `board_view.gd` / `unit_token.gd`. Đây là màu UI, không phải số cân bằng, nên **không** đưa vào `chi_so.json`.

### Bố cục `thu_ba_tuong.json` **[MẶC ĐỊNH, chờ tác giả xác nhận]**

```json
{
  "phien_ban_dinh_dang": 1,
  "ten": "Thử ba tướng",
  "kieu": "tieu_diet",
  "dia_hinh": [
    ". . . ~ . . .",
    ". # . ~ . L .",
    ". . . ~ . . .",
    ". ^ . . . . A",
    ". . . ~ D . .",
    ". . . ~ . . .",
    ". . . ~ . . ."
  ],
  "quan": [
    ". B . . . K .",
    ". . . . . . .",
    ". . . . . C .",
    ". . . . . . .",
    ". . . . . B .",
    ". . . . . . .",
    "1 . 2 . 3 . ."
  ],
  "thu_tu_dich": ["1,0", "5,0", "5,2", "5,4"],
  "long_dan": 3,
  "tiep_vien": [],
  "muu_ke_mo": []
}
```

- Có đủ 7 loại ô để tác giả nhìn hết màu trong một lần chạy, đủ 3 tướng và đủ B, K, C. Id:
  - tướng: 1 (`0,6`), 2 (`2,6`), 3 (`4,6`);
  - quân Nguyên: 101 B (`1,0`), 102 K (`5,0`), 103 C (`5,2`), 104 B (`5,4`).
- Có ô làng `D` nên ghi sẵn `"long_dan": 3`. Story 1.1 biết tên khóa này nhưng chưa đọc. Story 3.7 sẽ bắt buộc có `long_dan` khi có `D`, nên ghi ngay để sau này file không đỏ.
- `kieu` là `tieu_diet`: có ô `A` vẫn hợp lệ. Luật E-NOPASS chỉ áp cho `giu_ai`.
- Kiểm theo luật nạp: không quân nào đứng trên `~ # L D`; `thu_tu_dich` liệt kê đúng 4 quân Nguyên, không thừa, không lặp.

### Luật id quân (kiến trúc, "Mẫu tạo đối tượng")

- Tướng: id 1–3 **theo ký hiệu**, không theo thứ tự có mặt. Trận 1 có `1` `2` nên id 1 và 2; trận thử có cả 3.
- Quân Nguyên: id từ 101 theo `thu_tu_dich` (`LevelData.units` đã xếp sẵn: tướng theo 1, 2, 3, rồi quân Nguyên theo `thu_tu_dich`). Quân tiếp viện (Story 3.10) sẽ lấy id tiếp theo.
- `tran_01.json`: 1 = Nguyễn Khoái `0,6`; 2 = Phạm Ngũ Lão `2,6`; 101 = B `1,0`; 102 = B `5,0`; 103 = B `5,4`.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Chọn tướng, tô ô đi được, đường đi | 1.4 |
| Đi, hủy, kết thúc lượt, dấu "đã đi", `Command`, `Rules`, `Effects` | 1.5 |
| F5 nạp lại | 1.6 (`_start_battle()` đã gọi lại được) |
| HUD (số hiệp, Lòng dân), tooltip rê chuột | E2/E3 |
| `battle_view.gd`, `battle.tscn`, `EventPlayer`, hoạt ảnh | 1.5 / E2 |
| Sửa `terrain_at` ngoài bàn của `LevelData` (mục hoãn từ review 1.1) | 1.4, khi bắt đầu xét ô kề. `BattleState.in_bounds()` có sẵn từ story này |
| Chặn F1/F5 của trình duyệt trên web | Mục đã hoãn, thử khi làm 1.6 |

### Luật kiến trúc phải theo

- `src/core/` chỉ có `RefCounted`: không Node, I/O, `Log` hay ngẫu nhiên. `check_boundaries.sh` quét tự động. [Source: game-architecture.md#Ranh giới kiến trúc]
- `.hp`/`.cell` chỉ được gán trong `core/effects.gd`, nên mọi chỗ khác dựng quân qua `_init`. Đây là bẫy dễ dính nhất khi viết `clone()` và test. [Source: tools/check_boundaries.sh]
- `clone()` tự viết, sao chép sâu từng `Unit`. `Array.duplicate(true)` **không** sao chép object `RefCounted` bên trong. [Source: project-context.md#Luật riêng của Godot]
- Chỉ `BattleController` giữ trạng thái sống. `BoardView` chỉ nhận **bản chụp** và không giữ tham chiếu tới `_state` của controller. [Source: game-architecture.md#Quản lý trạng thái]
- Đồng quân sinh bằng code, giữ theo id, đồng bộ theo bản chụp. Không object pool. [Source: game-architecture.md#Mẫu tạo đối tượng]
- Code debug chỉ nằm trong `src/debug/` và chỉ tạo khi bật dev. [Source: game-architecture.md#Ranh giới kiến trúc, luật 5]
- Mọi chữ hiển thị qua `tr()`, khóa `<man>.<muc>`. Ngoại lệ là tọa độ và id ở F1: đó là số, không cần dịch. [Source: project-context.md#Tổ chức code]
- Không scene mới. Không lấy node bằng `/root/...`. Signal nối trong code. [Source: project-context.md#Luật riêng của Godot]
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` = error). Ví dụ: `var t: UnitToken = UnitToken.new()`, không dùng `:=` với `Variant`.

### Ghi chú kỹ thuật Godot 4.7.2

- `Label` đặt trong `Node2D` vẫn nhận theme của project (`gui/theme/custom` = `main_theme.tres`, font Be Vietnam Pro). `ErrorScreen` và tiêu đề đã dùng cách này.
- Muốn căn chữ giữa đồng quân: đặt `size`, rồi `position = -size / 2`, `horizontal_alignment` / `vertical_alignment` = CENTER.
- `draw_circle(position, radius, color)` vẽ hình tròn đặc; viền thì gọi thêm với `filled = false, width = 3.0`. Tra lại tham số bằng Context7 (`/godotengine/godot-docs/__branch__4.7`) trước khi dùng.
- `queue_free()` chạy trễ một khung hình. Đếm token trong test thì đếm theo `_tokens` (Dictionary id → token) hoặc bỏ qua node `is_queued_for_deletion()`.
- GUT `watch_signals(obj)` + `assert_signal_emitted(obj, "f1_pressed")` dùng cho test DevTools.
- Đổi `LaunchOptions.tran` sang `String` thì kiểm số bằng `is_valid_int()`. Tên thì dùng `RegEx.create_from_string("^[a-z][a-z0-9_]*$")`; `RegEx` có sẵn, không cần addon.

### Cấu trúc file sau story

```
game/
├── data/tran/
│   ├── tran_01.json            # không đổi
│   └── thu_ba_tuong.json       # MỚI
├── i18n/text.csv               # +12 khóa (text.vi.translation sinh lại)
├── src/
│   ├── core/
│   │   ├── unit.gd             # MỚI
│   │   ├── unit_factory.gd     # MỚI
│   │   └── battle_state.gd     # MỚI
│   ├── battle/
│   │   ├── board_view.gd       # SỬA
│   │   ├── unit_token.gd       # MỚI
│   │   └── battle_controller.gd# MỚI
│   ├── app/
│   │   ├── main.gd             # SỬA
│   │   ├── launch_options.gd   # SỬA
│   │   └── app_state.gd        # SỬA (1 dòng log)
│   └── debug/
│       ├── dev_tools.gd        # SỬA
│       └── coord_overlay.gd    # MỚI
└── tests/
    ├── test_battle_state.gd    # MỚI
    ├── test_main.gd            # SỬA
    ├── test_launch_options.gd  # SỬA
    ├── test_dev_tools.gd       # SỬA
    └── test_loaders.gd         # SỬA (+1 test)
```

### Testing

- Theo project-context: không có test tự động cho **hình dáng** UI. Nhưng test được **trạng thái node**: số token, chữ trong Label, vị trí token bằng `cell_center()`, overlay hiện/ẩn. `test_main.gd` của Story 1.1 đã làm kiểu này.
- Lõi (`BattleState`, `UnitFactory`) test trực tiếp, không cần màn hình. Sau khi dựng trạng thái, gọi `validate()` và kiểm rỗng.
- Không dựa vào con số trong file thật, trừ test "file thật nạp được" (tác giả được sửa file). Ví dụ: test máu = `stats.max_hp(type)`, không viết cứng `3`. Riêng `test_main.gd` được so `"3"` vì nó kiểm cả đường đi từ file thật; nếu tác giả đổi máu thì test này đỏ kèm câu rõ ràng. Dev có thể đổi thành so với `str(AppState.stats.max_hp(...))` để khỏi đỏ.
- **Hướng dẫn tác giả tự test** (chép vào Completion Notes, sửa số test cho đúng):
  1. Gõ `tools/test.sh` → dòng cuối `✅ N/N test đạt`.
  2. Gõ `tools/chay.sh --dev` → bàn cờ có cột sông xanh ở giữa (trừ ô ở hàng thứ 4), hai đồng đỏ `Khoái` (góc dưới trái) và `Lão`, ba đồng xanh than `B`; mỗi đồng có số `3`. Terminal có `[INFO][battle] nạp trận tran_01`.
  3. Bấm **F1** → mỗi ô hiện `cot,hang` (ô góc trên trái là `0,0`), mỗi quân hiện id (Khoái `1`, Lão `2`, ba B `101` `102` `103`). Bấm F1 lần nữa → ẩn.
  4. Đóng game. Gõ `tools/chay.sh --dev --tran=thu_ba_tuong` → thấy đủ 7 màu ô (có chữ Sông, Rừng, Chông, Kho, Làng, Ải), 3 tướng `Khoái` `Lão` `Dư`, và `B` `K` `C` với máu 3, 2, 1.
  5. Gõ `tools/chay.sh --tran=thu_ba_tuong` (không `--dev`) → mở trận 1 như bước 2; terminal có `bỏ qua tran=thu_ba_tuong vì chưa bật dev`.
  6. Mở `game/data/tran/tran_01.json`, ở dòng cuối của `"quan"` đổi `"1 . 2 . . . ."` thành `". 1 2 . . . ."`, lưu, chạy lại bước 2 → `Khoái` dịch sang ô `1,6`. Trả lại như cũ.
  7. Gõ `tools/test.sh` lần nữa → xanh.

### Previous Story Intelligence (Story 1.1 và code review)

- Bộ nạp không ghi log; `main.gd` ghi. Giữ nguyên: `BattleController` ghi log lỗi `validate()`, lõi thì không.
- `LevelData.units` đã xếp theo id (tướng 1, 2, 3 rồi `thu_tu_dich`). `from_level` chỉ cần đi theo thứ tự đó.
- `JsonFile`/`BoardText` dùng chung giữa các bộ nạp; đừng viết lại cách đọc JSON. `BoardText.cell_text(cell)` cho ra `"x,y"`, dùng được cho F1 và câu `validate()`.
- Code review 1.1 đã làm `_start_battle()` gọi lại được (`_hide_error()`, bỏ `AppState.stats`/`_level` khi lỗi). Khi thêm `_controller`, cũng đặt nó về `null` ở nhánh lỗi.
- Test `test_main.gd` dùng `level_dir`/`stats_path` trỏ vào `user://test_main/`. Test chọn trận theo tên dùng `res://data/tran` thật (file `thu_ba_tuong.json` có thật).
- Bẫy đã gặp: ký tự vô hình gõ thẳng trong code (BOM). Dùng `\uXXXX` nếu cần.
- `UnitPlacement` gán `cell` chỉ trong `_init` vì `check_boundaries.sh`. `Unit` làm y như vậy.

### Git Intelligence

- 5 commit gần nhất: `4285462` (sửa theo review 1.1), `58b6751` (Story 1.1), `ac98e37`, `0994ad5`, `bfd8b48`. Mẫu: một commit cho story, một commit cho sửa theo review; lời commit tiếng Việt, kèm `.uid` mới và `text.vi.translation`.

### Project Context Rules

- Godot 4.7.2, GDScript, gõ kiểu tĩnh; GUT 9.7.1 `--headless` qua `tools/test.sh`.
- Tầng: `core` → `data` → `battle`/`ui` → `app`; `debug` chỉ khi dev.
- Chỉ `BattleController` giữ trạng thái sống; UI không sửa `BattleState`.
- Quân chỉ tạo qua `UnitFactory.create`; id tướng 1–3, quân Nguyên từ 101.
- Số cân bằng chỉ ở `chi_so.json`; chữ chỉ qua `tr()`; log qua `Log.*`, không `print`.
- Scene nhỏ và phẳng, node sinh bằng code; một autoload (`AppState`).
- Input: phím dev đăng ký InputMap bằng code, chỉ khi dev; F1–F5 không có tác dụng khi không dev.
- Xong việc = `tools/test.sh` xanh rồi commit.
- MCP: GoPeak chỉ để chụp màn hình/bơm phím khi `--dev`; Context7 để tra API.

### Quyết định mặc định trong story này (chờ tác giả xác nhận, không chặn việc làm)

1. Màu từng loại ô và chữ ngắn ở góc ô (bảng "Cách vẽ").
2. Màu đồng quân: Đại Việt đỏ, Nguyên xanh than.
3. Số máu hiện trong chấm tròn trắng ở góc dưới phải đồng quân.
4. F1: tọa độ góc trên trái ô, id quân góc trên phải ô.
5. Bố cục `thu_ba_tuong.json` (đủ 7 loại ô, 3 tướng, B/K/C).
6. `--tran` / `?tran` nhận cả tên file trận (chữ thường không dấu, số, `_`), vẫn chỉ khi bật dev.

Nếu tác giả đổi ý trước khi dev bắt đầu, sửa story; nếu sau, sửa code + test.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.2]
- [Source: _bmad-output/planning-artifacts/epics.md#Danh mục yêu cầu] (FR1, FR3, FR5, FR43)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Quản lý trạng thái, #Mẫu tạo đối tượng, #Mẫu truy cập dữ liệu, #Công cụ debug, #Cây thư mục, #Ranh giới kiến trúc]
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/1-1-nap-chi-so-va-tran-tu-file-bao-loi-bang-tieng-viet.md]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md] (F1 trên web, `terrain_at` ngoài bàn)
- [Source: tools/check_boundaries.sh]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- **Lệch tên so với Task 1.1:** enum phe đặt tên `Unit.Faction` (thuộc tính `faction`), không phải `Side`. Godot đã có sẵn một `enum Side` chung (`SIDE_LEFT`…). Bên trong lớp, `var side: Side` trỏ nhầm sang enum đó, nên báo lỗi "Value of type Unit.Side cannot be assigned to a variable of type Side".
- `tools/test.sh`: đỏ lúc mới viết `test_battle_state.gd` (chưa có lớp), xanh 172/172 sau Task 1, xanh **181/181** khi xong story.
- Kiểm bằng mắt: GoPeak đã ngắt kết nối trong phiên này. Mình chụp bằng `--write-movie` (trận 1 và `thu_ba_tuong`, đều với `--dev`). Ảnh F1 chụp bằng một script tạm ở `/tmp`: script mở `main.tscn` rồi phát `f1_pressed`; đã xóa sau khi chụp. Thấy đủ 7 màu ô và chữ địa hình, đồng `Khoái` `Lão` `Dư` đỏ, `B` `K` `C` xanh than, máu 3/3/3/3/2/1/3, tọa độ `0,0`…`6,6`, id 1 2 3 101–104, chữ DEV và nhãn phiên bản. Chữ có dấu không vỡ; chữ "Khoái" vừa khít trong đồng quân.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Lõi (`src/core/`):
  - `Unit`: id, `faction`, type, cell, hp; chỉ gán trong `_init`.
  - `UnitFactory.create`: máu lấy từ `Stats`.
  - `BattleState`:
    - `from_level`: id tướng theo ký hiệu, quân Nguyên từ 101 theo `thu_tu_dich`;
    - `clone()` sâu, `validate()` 5 loại lỗi có câu tiếng Việt;
    - `in_bounds`, `terrain_at`, `unit_at`, `unit_by_id`.
  - Không Node, không log.
- `BattleController` (`src/battle/`): `start(level, stats)` (ghi `Log.error` nếu `validate()` không rỗng), `snapshot()`.
- `BoardView`:
  - `show_state(state | null)`, màu 7 loại ô, chữ ngắn ở góc dưới trái;
  - lớp đồng quân giữ theo id (`_sync_tokens`), `cell_center()`, `tokens()`.
  - `CELL_SIZE`, vị trí bàn và lưới giữ nguyên.
- `UnitToken`: đồng tròn hai màu phe, tên qua `tr("unit.*")`, chấm máu ở góc dưới phải.
- `LaunchOptions.tran` thành `String`: số (chuẩn hóa) hoặc tên `^[a-z][a-z0-9_]*$`; thêm `level_id()`. `app_state` log `tran=%s`.
- `main.gd`:
  - nạp xong thì tạo `BattleController` rồi vẽ bản chụp;
  - lỗi hoặc "Về menu" thì bàn trống, `_controller = null`;
  - chỉ khi dev: tạo `CoordOverlay` (con cuối của `BoardView`), nối `DevTools.f1_pressed`.
- `DevTools`: F1 phát `f1_pressed` thay cho dòng log cũ; F2–F5 như cũ.
- `CoordOverlay` (`src/debug/`): tọa độ mỗi ô (góc trên trái), id quân (góc trên phải), nền đen mờ, bật/tắt.
- `thu_ba_tuong.json`: đúng bố cục trong story. 12 khóa dịch `unit.*` và `terrain.*`.
- Test mới hoặc sửa:
  - `test_battle_state.gd` (11 test);
  - `test_main.gd` (+7: bàn trận 1, trận theo tên, không dev, về menu, nạp lại lỗi, F1, không có F1 khi không dev);
  - `test_launch_options.gd` (viết lại cho `String`, thêm tên hợp lệ/sai, `level_id`);
  - `test_dev_tools.gd` (F1 phát signal);
  - `test_loaders.gd` (+1 file thật `thu_ba_tuong`).
- **Hướng dẫn tác giả tự test:**
  1. Gõ `tools/test.sh` → dòng cuối `✅ 181/181 test đạt`.
  2. Gõ `tools/chay.sh --dev` → bàn cờ có cột sông xanh ở giữa (hàng thứ 4 không có sông), chữ "Sông" ở góc ô. Hai đồng đỏ `Khoái` (góc dưới trái) và `Lão`, ba đồng xanh than `B`; mỗi đồng có chấm trắng số `3`. Terminal có `[INFO][battle] nạp trận tran_01`.
  3. Bấm **F1** → mỗi ô hiện `cot,hang` (ô góc trên trái là `0,0`), mỗi quân hiện id ở góc trên phải ô (Khoái `1`, Lão `2`, ba B `101` `102` `103`). Bấm F1 lần nữa → ẩn.
  4. Đóng game. Gõ `tools/chay.sh --dev --tran=thu_ba_tuong` → đủ 7 màu ô (chữ Sông, Rừng, Chông, Kho, Làng, Ải), 3 tướng `Khoái` `Lão` `Dư`, và `B` `K` `C` với máu 3, 2, 1.
  5. Gõ `tools/chay.sh --tran=thu_ba_tuong` (không `--dev`) → mở trận 1 như bước 2; terminal có `bỏ qua tran=thu_ba_tuong vì chưa bật dev`.
  6. Mở `game/data/tran/tran_01.json`, ở dòng cuối của `"quan"` đổi `"1 . 2 . . . ."` thành `". 1 2 . . . ."`, lưu, chạy lại bước 2 → `Khoái` dịch sang ô `1,6`. Trả lại như cũ.
  7. Gõ `tools/test.sh` lần nữa → xanh.

### File List

- _bmad-output/implementation-artifacts/1-2-hien-ban-co-tran-1-bo-cuc-dau-tien.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- game/data/tran/thu_ba_tuong.json (mới)
- game/i18n/text.csv
- game/i18n/text.vi.translation
- game/src/core/unit.gd, unit.gd.uid (mới)
- game/src/core/unit_factory.gd, unit_factory.gd.uid (mới)
- game/src/core/battle_state.gd, battle_state.gd.uid (mới)
- game/src/battle/battle_controller.gd, battle_controller.gd.uid (mới)
- game/src/battle/unit_token.gd, unit_token.gd.uid (mới)
- game/src/battle/board_view.gd
- game/src/debug/coord_overlay.gd, coord_overlay.gd.uid (mới)
- game/src/debug/dev_tools.gd
- game/src/app/main.gd
- game/src/app/launch_options.gd
- game/src/app/app_state.gd
- game/tests/test_battle_state.gd, test_battle_state.gd.uid (mới)
- game/tests/test_main.gd
- game/tests/test_launch_options.gd
- game/tests/test_dev_tools.gd
- game/tests/test_loaders.gd

### Change Log

- 2026-10-18: Làm Story 1.2: vẽ địa hình và đồng quân theo file trận, số máu, F1 tọa độ/id, trận thử `thu_ba_tuong` mở bằng tên; thêm `BattleState`/`Unit`/`UnitFactory`/`BattleController` tối thiểu; 181/181 test đạt.
