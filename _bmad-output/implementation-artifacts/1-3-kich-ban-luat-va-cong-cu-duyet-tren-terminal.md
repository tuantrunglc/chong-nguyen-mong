---
baseline_commit: b8b1b6d
---

# Story 1.3: Kịch bản luật và công cụ duyệt trên terminal

Status: done

## Story

Là tác giả,
tôi muốn đọc và duyệt luật dưới dạng bàn cờ trước và sau,
để quyết spec mà không cần đọc code.

## Acceptance Criteria

1. **Cho** kịch bản mẫu `game/tests/kich_ban/di_chuyen/di_thang_3_o.json` (có `truoc`, `hanh_dong`, `sau`, `mo_ta`, `da_duyet: false`), **khi** gõ `tools/xem_kich_ban.sh` từ gốc repo, **thì** terminal in:
   - tên file (tính từ `kich_ban/`, ví dụ `di_chuyen/di_thang_3_o.json`) và trạng thái `[chưa duyệt]`;
   - dòng mô tả tiếng Việt (`mo_ta`);
   - các bước hành động viết bằng chữ (ví dụ `1. Nguyễn Khoái đi tới 3,6`);
   - bàn **TRƯỚC** và bàn **SAU** đặt cạnh nhau, có số cột và số hàng;
   - quân không đầy máu thì ghi thêm dưới bàn (ví dụ `Máu:  5,4 Bộ binh 1/3`, xem Dev Notes "Cách in").
   Mặc định chỉ in kịch bản **chưa duyệt**. Bố cục chi tiết ở Dev Notes "Cách in". **[Tác giả chốt 2026-10-18]**
2. **Khi** gõ `tools/xem_kich_ban.sh di_chuyen`, **thì** chỉ hiện kịch bản của nhóm `di_chuyen/`.
   - Gõ tên nhóm không có thì in `không có nhóm "xyz". Các nhóm đang có: di_chuyen` và thoát mã 1.
   - Thêm `--tat_ca` thì in cả kịch bản đã duyệt (ghi `[đã duyệt]`).
   - Không còn kịch bản nào chưa duyệt thì in `Không có kịch bản nào chờ duyệt.`
   **[Tác giả chốt 2026-10-18]**
3. **Khi** gõ `tools/test.sh`, **thì**:
   - mọi file `.json` trong `game/tests/kich_ban/` (mọi nhóm con) đều được nạp và chạy;
   - tóm tắt ghi riêng số kịch bản đã duyệt và chưa duyệt, ví dụ `Kịch bản luật: 0 đã duyệt · 1 chưa duyệt (1 chưa đạt)`.
4. **Và** luật đỏ/xanh của `tools/test.sh`: **[Tác giả chốt 2026-10-18]**
   - kịch bản **đã duyệt** mà trượt thì `tools/test.sh` **trượt**, ghi tên file và chỗ sai;
   - kịch bản **chưa duyệt** mà chưa đạt (luật chưa có code, hoặc kết quả khác `sau`) thì **không** làm `tools/test.sh` trượt. Nó chỉ được đếm và liệt kê (`⏳ di_chuyen/di_thang_3_o.json: chưa duyệt, chưa đạt`). Nhờ vậy AI commit được kịch bản để tác giả duyệt;
   - file kịch bản **sai định dạng** (thiếu khóa, ký hiệu lạ…) thì luôn trượt, dù đã duyệt hay chưa, kèm câu lỗi tiếng Việt có file, khóa, dòng, cột.
5. **Và** chỉ cần đổi `"da_duyet": false` thành `true` là duyệt xong. Từ lần commit sau, file bị khóa: sửa nữa thì `tools/test.sh` trượt (khóa của Story 0.2, giữ nguyên).
6. **Và** kịch bản mẫu `di_thang_3_o.json` hôm nay **chưa đạt**, vì luật đi chưa có (Story 1.4). Kết quả chạy ghi rõ `bước 1: lệnh "di" chưa có luật (Story 1.4)`. Đây là đúng quy trình M3: kịch bản mới phải trượt trước khi viết code.
7. **Và** những gì đã có vẫn chạy như cũ: `tools/test.sh` xanh; `test_loaders.gd` giữ nguyên mọi câu lỗi của file trận; game mở trận 1 như Story 1.2.

## Tasks / Subtasks

- [x] **Task 1: Tách phần đọc bàn cờ chữ dùng chung** (`src/data/`, AC: 3, 4, 7)
  - [x] 1.1 Tạo `src/data/board_layers.gd` (`class_name BoardLayers`, `extends RefCounted`). Chuyển **nguyên văn** các hàm sau từ `LevelLoader` sang đây, đổi thành hàm công khai:
    - `_read_layer` → `read_layer(root, key, shown, symbols, file, result)`. `key` là khóa trong object, `shown` là tên in trong câu lỗi (`"dia_hinh"` với file trận, `"truoc.dia_hinh"` với kịch bản);
    - `_symbol` → `symbol(rows, cell)`;
    - `_has_symbol` → `has_symbol(rows, symbol)`;
    - `_check_unit_cells` → `check_unit_cells(terrain_rows, unit_rows, shown, file, result)`, với `shown` là tên lớp quân trong câu lỗi;
    - `_read_enemy_order` → `read_enemy_order(root, key, shown, unit_rows, units_clean, file, result)`;
    - `_terrain_values` → `terrain_values(rows)`.
  - [x] 1.2 `BOARD_SIZE` chuyển sang `BoardLayers.BOARD_SIZE` (hôm nay chỉ `level_loader.gd` dùng hằng này). `LevelLoader` dùng `BoardLayers.BOARD_SIZE`.
  - [x] 1.3 `LevelLoader` gọi các hàm mới với `shown` = đúng tên cũ (`"dia_hinh"`, `"quan"`, `"thu_tu_dich"`). **Không đổi một chữ nào** trong câu lỗi: `test_loaders.gd` phải xanh mà không sửa test nào.
- [x] **Task 2: Máu ban đầu khác máu đầy** (`src/core/`, AC: 1, 3)
  - [x] 2.1 `LevelData.UnitPlacement` thêm `var hp: int` và tham số `p_hp: int = 0` trong `_init`. `0` nghĩa là máu đầy theo `chi_so.json`. File trận không có máu riêng, nên `LevelLoader` không đổi.
  - [x] 2.2 `UnitFactory.create(id, type, cell, stats, hp: int = 0)`: `hp` > 0 thì dùng `hp`, còn lại dùng `stats.max_hp(type)`. `BattleState.from_level` truyền `p.hp`.
  - [x] 2.3 Chỉ gán `hp` trong `_init` (dạng `hp = p_hp`). **Cấm** `placement.hp = …` ở chỗ khác: `check_boundaries.sh` bắt mọi `.hp =` trong `src/` ngoài `effects.gd`.
- [x] **Task 3: Dữ liệu kịch bản** (`src/data/scenario_data.gd`, AC: 1, 3)
  - [x] 3.1 `class_name ScenarioData extends RefCounted`, chỉ đọc. Thuộc tính:
    - `path: String` (đường `res://`), `id: String` (tính từ `kich_ban/`, ví dụ `di_chuyen/di_thang_3_o.json`), `group: String` (`di_chuyen`);
    - `description: String` (`mo_ta`), `approved: bool` (`da_duyet`);
    - `before: LevelData` (bàn trước; `mission` = `ELIMINATE`, `name` = `id`);
    - `steps: Array[ScenarioStep]`;
    - `after_terrain: PackedInt32Array`, `after_units: Array[ExpectedUnit]`.
  - [x] 3.2 Lớp con `ScenarioStep`: `kind: String` (`"di"`, `"danh"`, `"huy"`, `"ket_thuc_luot"`), `general: int` (UnitType, `-1` nếu lệnh không cần tướng), `cell: Vector2i` (`Vector2i(-1, -1)` nếu không cần ô). Story 1.4 đổi bước này thành `Command`.
  - [x] 3.3 Lớp con `ExpectedUnit`: `type: int`, `cell: Vector2i`, `hp: int` (đã đổi `0` thành máu đầy lúc nạp).
- [x] **Task 4: Bộ nạp kịch bản** (`src/data/scenario_loader.gd`, AC: 3, 4)
  - [x] 4.1 `static func load_scenario(path: String, root_dir: String, stats: Stats) -> LoadResult`: đọc file như `LevelLoader.load_level` (dùng `JsonFile`), `id` = `path` bỏ tiền tố `root_dir + "/"`. Trả `LoadResult` có `data` là `ScenarioData`.
  - [x] 4.2 `static func list_files(root_dir: String) -> Array[String]`: mọi file `.json` trong `root_dir` và các thư mục con (đệ quy, dùng `DirAccess`), **sắp theo đường dẫn** để thứ tự chạy luôn giống nhau. Thư mục không có thì trả `[]`.
  - [x] 4.3 Định dạng và câu lỗi theo Dev Notes "Định dạng kịch bản". Gom mọi lỗi rồi mới trả, như `LevelLoader`. Khóa lạ là cảnh báo, không phải lỗi.
  - [x] 4.4 Không ghi log trong bộ nạp (bên gọi ghi), giống `LevelLoader`.
- [x] **Task 5: Chạy một kịch bản** (`tests/scenario_runner.gd`, AC: 3, 4, 6)
  - [x] 5.1 `class_name ScenarioRunner extends RefCounted`. `static func run(scenario: ScenarioData, stats: Stats) -> ScenarioResult`. `ScenarioResult` (lớp con): `passed: bool`, `problems: Array[String]`.
  - [x] 5.2 Dựng `BattleState.from_level(scenario.before, stats)`. Gọi `validate()`: có lỗi thì ghi vào `problems` (`trước: <lỗi>`) và dừng.
  - [x] 5.3 Chạy từng bước. Story này **chưa có luật nào**, nên mọi bước đều ra `bước N: lệnh "<kind>" chưa có luật (Story X)` rồi dừng. Bảng story theo lệnh: `di` → 1.4, `huy` và `ket_thuc_luot` → 1.5, `danh` → 2.1. Viết thành một `match` để Story 1.4 thay nhánh `"di"` bằng lệnh thật. Sau mỗi bước (khi đã có luật) gọi `validate()` (luật dự án).
  - [x] 5.4 Chạy hết các bước thì so với `sau`, theo Dev Notes "So kết quả". Mỗi chỗ khác là một câu trong `problems`.
  - [x] 5.5 File nằm trong `game/tests/` (không vào bản export). Không phải file test GUT nên **không** đặt tên `test_*`.
- [x] **Task 6: Test GUT chạy mọi kịch bản** (`tests/test_scenarios.gd`, AC: 3, 4)
  - [x] 6.1 Nạp `chi_so.json` thật (`StatsLoader.load_stats("res://data/chi_so.json")`). Kịch bản dùng chỉ số thật: sửa `chi_so.json` thì kịch bản chạy lại theo số mới (kiến trúc, mục "Chỉ số").
  - [x] 6.2 `test_every_scenario_loads`: thư mục `res://tests/kich_ban` phải có ít nhất một file. Mọi file phải nạp không lỗi; lỗi thì `assert` kèm nguyên văn câu lỗi.
  - [x] 6.3 `test_approved_scenarios_pass`: mỗi kịch bản đã duyệt phải `passed`. Trượt thì thông điệp gồm `id` và mọi câu trong `problems`. Chưa có kịch bản đã duyệt thì gọi `pass_test("chưa có kịch bản đã duyệt")`, vì `test.sh` coi test không có assert là trượt.
  - [x] 6.4 Kịch bản chưa duyệt cũng chạy, nhưng **không** assert kết quả (AC 4).
  - [x] 6.5 Ghi kết quả cho `test.sh`: nếu biến môi trường `KET_QUA_KICH_BAN` có giá trị (`OS.get_environment`) thì ghi file đó. Mỗi kịch bản một dòng `<da_duyet|chua_duyet>\t<dat|truot>\t<id>` (sau code review: thêm `sai_dinh_dang` và cột lý do thứ tư), theo thứ tự `list_files`. Biến rỗng thì không ghi gì (chạy GUT tay vẫn được).
- [x] **Task 7: Test cho bộ nạp và bộ chạy** (`tests/test_scenario_loader.gd`, AC: 3, 4)
  - [x] 7.1 Theo mẫu `test_main.gd`: viết file tạm vào `user://test_kich_ban/…`, xóa trong `after_each`.
  - [x] 7.2 Ca đúng: kịch bản tối thiểu nạp được; `id`, `group`, `approved`, `description` đúng; `truoc.mau` đổi máu đúng quân; thiếu `thu_tu_dich` thì id quân Nguyên theo thứ tự đọc (hàng trên xuống, trái sang phải).
  - [x] 7.3 Mỗi câu lỗi trong bảng Dev Notes có một ca, so **nguyên văn**. Thêm một ca có nhiều lỗi cùng lúc: phải liệt kê đủ.
  - [x] 7.4 Bộ chạy: (a) `hanh_dong: []` và `sau` giống `truoc` thì đạt; (b) `sau` khác máu, khác ô, thiếu quân, thừa quân, khác địa hình: mỗi ca ra đúng câu so sánh; (c) có lệnh `di` thì ra câu "chưa có luật (Story 1.4)" và không so `sau`.
  - [x] 7.5 `list_files`: sắp theo đường dẫn, đi vào thư mục con, bỏ qua file không phải `.json`.
  - [x] 7.6 Tách phần đọc file kết quả ở 6.5 nếu cần để test được; không bắt buộc test `test.sh`.
- [x] **Task 8: `tools/test.sh` in số kịch bản** (AC: 3, 4)
  - [x] 8.1 Trước bước 4, đặt `KET_QUA_KICH_BAN="$KET_QUA_DIR/kich_ban.txt"`, xóa file cũ, `export` cho Godot. Godot thừa hưởng biến môi trường của shell.
  - [x] 8.2 Sau dòng `[4/4] Test GUT: …`, đọc file đó và in `      Kịch bản luật: <a> đã duyệt · <b> chưa duyệt (<c> chưa đạt)`. Kịch bản chưa duyệt mà chưa đạt thì in thêm từng dòng `  ⏳ <id>: chưa duyệt, chưa đạt`. Kịch bản đã duyệt mà trượt đã làm GUT trượt, nên không cần đếm thêm.
  - [x] 8.3 GUT chạy xong mà không có file kết quả (ví dụ `test_scenarios.gd` lỗi) thì in `      Kịch bản luật: không đọc được kết quả` và **trượt**.
  - [x] 8.4 Giữ nguyên 4 bước và mọi chốt chống xanh giả. `set -euo pipefail`: mọi `grep` không khớp phải bọc (`|| true`), như phần còn lại của file.
- [x] **Task 9: Công cụ duyệt** (`tools/xem_kich_ban.sh` + `game/tests/scenario_viewer.gd`, AC: 1, 2)
  - [x] 9.1 `tools/xem_kich_ban.sh [nhom] [--tat_ca]`: `source tools/_godot.sh`, rồi chạy `"$GODOT" --headless --path "$REPO_ROOT/game" -s res://tests/scenario_viewer.gd -- "$@"`. Bỏ dòng banner của Godot (`Godot Engine v…`) khỏi đầu ra. Giữ mã thoát của Godot.
  - [x] 9.2 `scenario_viewer.gd` `extends SceneTree`, làm việc trong `_initialize()`, xong thì `quit(ma)`. Đọc tham số bằng `OS.get_cmdline_user_args()`. Tham số lạ (không phải tên nhóm, không phải `--tat_ca`) thì in `bỏ qua tham số lạ: "<x>"`.
  - [x] 9.3 Nạp `chi_so.json` và mọi kịch bản qua `ScenarioLoader`. File sai định dạng thì in câu lỗi (kèm `id`) thay cho bàn cờ, rồi in tiếp file khác. Cuối cùng thoát mã 1 nếu có file sai.
  - [x] 9.4 In theo Dev Notes "Cách in". Chữ tên quân lấy qua `tr()` (khóa `unit.*` đã có từ Story 1.2), riêng tên đầy đủ của tướng dùng khóa mới (Task 10).
  - [x] 9.5 Đây là công cụ dòng lệnh: in bằng `print()` là đúng. Luật "chỉ Log được in" chỉ áp cho `src/` (`check_boundaries.sh` không quét `tests/`).
  - [x] 9.6 Không chạy luật trong công cụ duyệt. Tác giả duyệt **spec** (bàn sau mong đợi), không duyệt kết quả code.
- [x] **Task 10: Chữ hiển thị** (`i18n/text.csv`, AC: 1)
  - [x] 10.1 Thêm khóa cho tên đầy đủ dùng trong công cụ duyệt: `scenario.unit.nguyen_khoai` = `Nguyễn Khoái`, `scenario.unit.pham_ngu_lao` = `Phạm Ngũ Lão`, `scenario.unit.tran_khanh_du` = `Trần Khánh Dư`, `scenario.unit.bo_binh` = `Bộ binh`, `scenario.unit.ky_binh` = `Kỵ binh`, `scenario.unit.cung_ky` = `Cung kỵ`.
  - [x] 10.2 Chạy `--import` (bước 3 của `tools/test.sh` tự chạy) để sinh lại `text.vi.translation`, rồi commit file đó, như Story 1.2 Task 4.2. `test_i18n.gd` phải xanh.
  - [x] 10.3 Câu lỗi của bộ nạp và câu so sánh **không** đi qua `tr()`, giống câu lỗi của `LevelLoader` (test so nguyên văn, xem Story 1.1).
- [x] **Task 11: Kịch bản mẫu** (AC: 1, 6)
  - [x] 11.1 Tạo `game/tests/kich_ban/di_chuyen/di_thang_3_o.json` theo Dev Notes "Kịch bản mẫu", `"da_duyet": false`.
  - [x] 11.2 **Không** tạo kịch bản nào khác. Đợt `di_chuyen/` đầy đủ (5–8 kịch bản) là việc của Story 1.4.
  - [x] 11.3 Kiểm preset export: `tests/*` đã bị loại (Story 0.5), nên kịch bản không vào bản web. `test_export_preset.gd` phải xanh.
- [x] **Task 12: Kiểm và commit** (AC: 1–7)
  - [x] 12.1 `tools/test.sh` xanh, có dòng `Kịch bản luật: 0 đã duyệt · 1 chưa duyệt (1 chưa đạt)` và dòng `⏳ di_chuyen/di_thang_3_o.json`.
  - [x] 12.2 Chạy `tools/xem_kich_ban.sh`, `tools/xem_kich_ban.sh di_chuyen`, `tools/xem_kich_ban.sh xyz`, `tools/xem_kich_ban.sh --tat_ca`. Chép đầu ra thật vào Completion Notes để tác giả xem.
  - [x] 12.3 Thử khóa trên một **bản clone tạm** (không phải repo chính), theo cách của Story 0.2 Task 5.5: đổi mẫu thành `da_duyet: true`, commit trong bản clone, `tools/test.sh` phải **trượt** vì kịch bản đã duyệt chưa đạt (AC 4); sửa file thì có thêm dòng khóa. Ghi vào Debug Log. Không để lại gì trên `main`.
  - [x] 12.4 Commit kèm file `.uid` mới, lời commit tiếng Việt.
  - [x] 12.5 Ghi hướng dẫn tác giả tự test vào Completion Notes (mẫu ở mục Testing).

### Review Findings

- [x] [Review][Patch] Dòng máu in theo Dev Notes "Cách in": `Máu:` + hai dấu cách, `Máu:` bên phải thẳng dưới bàn SAU; sửa ví dụ ở AC 1 cho khớp. Tác giả chốt 2026-10-18 (trước đó AC 1 ghi `5,4 Bộ binh: 1/3 máu`, code in một dấu cách) [game/tests/scenario_viewer.gd]
- [x] [Review][Patch] Công cụ duyệt treo mãi khi script lỗi lúc chạy, và thoát mã 0 khi script lỗi cú pháp; lỗi quét project bị giấu hết [tools/xem_kich_ban.sh:12-27, game/tests/scenario_viewer.gd:33]
- [x] [Review][Patch] AC 6: lý do `bước 1: lệnh "di" chưa có luật (Story 1.4)` không hiện ở tóm tắt `tools/test.sh` cho kịch bản chưa duyệt (chỉ có `⏳ …: chưa duyệt, chưa đạt`) [game/tests/test_scenarios.gd, tools/test.sh]
- [x] [Review][Patch] Câu lỗi định dạng bị GUT cắt giữa câu (mất `1 tới 3, đa`), không đúng AC 4 "kèm câu lỗi tiếng Việt" — `test_every_scenario_loads` dùng `assert_eq(r.errors, [])`, nên nối câu như test kịch bản đã duyệt [game/tests/test_scenarios.gd]
- [x] [Review][Patch] Kịch bản sai định dạng biến mất khỏi số đếm và danh sách ⏳ trong tóm tắt; file kết quả không được ghi khi chi_so.json lỗi (thêm lý do trượt thừa) [game/tests/test_scenarios.gd:35-37, tools/test.sh]
- [x] [Review][Patch] Ghi chú dưới bàn (Máu, Dưới quân) bên phải bị đẩy lệch khi ghi chú bên trái dài hơn 24 ký tự (ví dụ tướng mất máu, quân đứng trên hầm chông) [game/tests/scenario_viewer.gd:12,131]
- [x] [Review][Patch] Hai khóa `mau` trỏ cùng một ô (`"0,6"` và `"00,6"`) được nhận im lặng, khóa sau đè khóa trước [game/src/data/scenario_loader.gd:190-210]
- [x] [Review][Patch] Khóa `mau` ngoài bàn (`"9,9"`, `"-1,0"`) báo "không có quân" thay vì "nằm ngoài bàn" [game/src/data/scenario_loader.gd:198-202]
- [x] [Review][Patch] Đầu ra công cụ duyệt mở đầu bằng một dòng trống (dòng trống sau banner Godot chưa bị lọc) [tools/xem_kich_ban.sh:24]
- [x] [Review][Patch] Nhãn của công cụ duyệt (`TRƯỚC`, `SAU`, `Hành động:`, `Máu:`, `Dưới quân:`, `Tổng:`, `Duyệt:`) viết cứng, chưa qua `tr()` như Dev Notes yêu cầu ("Chữ hiển thị qua tr()") [game/tests/scenario_viewer.gd]
- [x] [Review][Patch] `--tat_ca` khi không có kịch bản nào vẫn in "Không có kịch bản nào chờ duyệt."; file đặt thẳng trong `kich_ban/` tạo nhóm rỗng (`Các nhóm đang có: , di_chuyen`) [game/tests/scenario_viewer.gd:57-93]
- [x] [Review][Patch] File kịch bản rỗng (0 byte) báo "không đọc được file" thay vì báo file rỗng [game/src/data/scenario_loader.gd:58-60]
- [x] [Review][Patch] Bảng ký hiệu quân/địa hình trong bộ chạy chép tay ngược từ `BoardText`; thêm quân/địa hình mới mà quên sửa thì bộ chạy và công cụ duyệt lỗi lúc chạy (và công cụ duyệt treo). Nên lấy ngược tự động từ `BoardText` [game/tests/scenario_runner.gd:15-48]
- [x] [Review][Patch] Câu so sánh "sai loại quân" không ghi tên và máu, nên lệch máu đi kèm bị giấu [game/tests/scenario_runner.gd]
- [x] [Review][Patch] `UnitFactory` nhận máu âm thành đầy máu, máu quá tối đa thì giữ nguyên, không báo gì (chỉ bộ nạp kịch bản kiểm) [game/src/core/unit_factory.gd]
- [x] [Review][Defer] Khóa `da_duyet` trong `tools/test.sh` lách được: sửa rồi commit luôn thì khóa không thấy; `"da_duyet":` và `true` khác dòng thì grep bỏ sót; khóa trùng thì grep và Godot hiểu khác nhau [tools/test.sh:80-95] — deferred, pre-existing
- [x] [Review][Defer] Định dạng kịch bản luôn dựng trận kiểu ELIMINATE với mặc định của LevelData, chưa có khóa cho nhiệm vụ, số hiệp tối đa, tiếp viện [game/src/data/scenario_loader.gd `_build_level`] — deferred, chưa có kịch bản cần; làm khi viết kịch bản `ket_thuc_luot`/giữ ải (Story 1.5 trở đi)

## Dev Notes

### Bối cảnh

- Story này dựng **đường ống** cho quy trình M3 (kiến trúc): định dạng kịch bản, bộ nạp, bộ chạy, công cụ duyệt, số liệu trong `test.sh`. **Chưa có luật nào.** Luật đi và đợt kịch bản `di_chuyen/` đầu tiên là Story 1.4.
- Tác giả không đọc code. Thứ tác giả nhìn là đầu ra của `tools/xem_kich_ban.sh` và dòng tóm tắt của `tools/test.sh`. Hai thứ này phải dễ đọc như bàn cờ trên giấy.
- Kịch bản dùng **cùng hai lớp bàn cờ chữ** với file trận (`dia_hinh`, `quan`), ký hiệu y hệt (`BoardText`). Tác giả đã quen định dạng này từ Story 1.1–1.2.

### File sẽ sửa (đọc trước khi sửa)

| File | Hôm nay | Story này đổi | Phải giữ |
|---|---|---|---|
| `src/data/level_loader.gd` | Đọc lớp, kiểm ô, đọc `thu_tu_dich` bằng hàm riêng `_read_layer`, `_check_unit_cells`, `_read_enemy_order`… | Chuyển các hàm đó sang `BoardLayers`, gọi lại với `shown` = tên cũ | **Mọi câu lỗi và thứ tự lỗi** (`test_loaders.gd` so nguyên văn). Thứ tự kiểm ghi ở đầu file |
| `src/core/level_data.gd` | `UnitPlacement(type, cell)` | Thêm `hp` (mặc định 0 = đầy) | `terrain_at`, thứ tự `units` (tướng theo ký hiệu, rồi quân Nguyên theo `thu_tu_dich`) |
| `src/core/unit_factory.gd` | `create(id, type, cell, stats)` lấy `max_hp` | Thêm `hp` tùy chọn | Mọi chỗ gọi cũ chạy như cũ |
| `src/core/battle_state.gd` | `from_level` cấp id tướng 1–3, quân Nguyên từ 101 | Truyền `p.hp` | Luật id (kiến trúc, "Mẫu tạo đối tượng") |
| `tools/test.sh` | 4 bước, tóm tắt tiếng Việt, nhiều chốt chống xanh giả | Thêm dòng "Kịch bản luật" sau bước 4, đặt biến `KET_QUA_KICH_BAN` | Mọi chốt cũ. Đọc phần chú thích về `pipefail` và `grep -q` trước khi sửa |
| `i18n/text.csv` | Khóa `app.*`, `error.*`, `terrain.*`, `unit.*` | Thêm `scenario.unit.*` | Khóa cũ |

`BattleController`, `BoardView`, `main.gd` **không** đổi.

### Định dạng kịch bản

```json
{
  "phien_ban_dinh_dang": 1,
  "mo_ta": "Nguyễn Khoái đi thẳng 3 ô sang phải trên đất trống.",
  "da_duyet": false,
  "truoc": {
    "dia_hinh": ["7 dòng, ký hiệu như file trận"],
    "quan": ["7 dòng, ký hiệu như file trận"],
    "mau": { "5,4": 1 },
    "thu_tu_dich": ["5,4"]
  },
  "hanh_dong": [
    { "lenh": "di", "tuong": "1", "o": "3,6" }
  ],
  "sau": {
    "dia_hinh": ["7 dòng"],
    "quan": ["7 dòng"],
    "mau": { "3,6": 2 }
  }
}
```

**Khóa gốc:**

| Khóa | Bắt buộc | Luật |
|---|---|---|
| `phien_ban_dinh_dang` | có | Số nguyên, chỉ nhận `1` (cùng câu lỗi với file trận) |
| `mo_ta` | có | Chuỗi khác rỗng sau `strip_edges()` |
| `da_duyet` | có | `true` hoặc `false` (kiểu bool của JSON, không nhận `"true"` hay `1`) |
| `truoc` | có | Object: `dia_hinh`, `quan` (bắt buộc); `mau`, `thu_tu_dich` (không bắt buộc) |
| `hanh_dong` | có | Danh sách, có thể rỗng |
| `sau` | có | Object: `dia_hinh`, `quan` (bắt buộc); `mau` (không bắt buộc). Không có `thu_tu_dich` |

**Trong `truoc` và `sau`:**
- `dia_hinh`, `quan`: kiểm như file trận (số dòng, số ô, ký hiệu lạ, quân trên ô không đi vào được, tướng lặp), qua `BoardLayers`. Tên trong câu lỗi có tiền tố: `"truoc.dia_hinh"`, `"sau.quan"`.
- `truoc` phải có ít nhất một quân (tướng hoặc Nguyên). `sau` được phép trống (mọi quân gục). **[MẶC ĐỊNH]**
- `mau`: object `{"cot,hang": số máu}`. Chỉ ghi quân **không đầy máu**; quân không có trong `mau` là đầy máu theo `chi_so.json`. Ô phải có quân ở lớp `quan` cùng phần; số máu là số nguyên từ 1 tới máu tối đa của loại quân đó. **[Tác giả chốt 2026-10-18]**
- `truoc.thu_tu_dich`: không bắt buộc. Có thì kiểm như file trận. Không có thì thứ tự quân Nguyên là **thứ tự đọc bàn**: hàng trên xuống dưới, mỗi hàng trái sang phải. **[Tác giả chốt 2026-10-18]**
- `sau` so theo **ô**, không theo id: ô nào có loại quân gì, bao nhiêu máu. Vì vậy `sau` không cần `thu_tu_dich`.

**Lệnh trong `hanh_dong`** (`lenh` bắt buộc; lệnh khác thêm ở story của nó):

| `lenh` | Khóa thêm | Kiểm khi nạp |
|---|---|---|
| `di` | `tuong` (`"1"`/`"2"`/`"3"`), `o` (`"cot,hang"`) | Tướng có trên `truoc.quan`; ô trong bàn |
| `danh` | `tuong`, `o` | Như `di` |
| `huy` | không | — |
| `ket_thuc_luot` | không | — |

Kiểm tướng "có trên bàn" theo `truoc`, không theo bàn sau từng bước (bộ nạp không chạy luật). Tướng gục giữa chừng thì bộ chạy báo khi chạy.

**Câu lỗi** (theo mẫu của `LevelLoader`; `<f>` là đường dẫn file như `JsonFile.label`, ví dụ `tests/kich_ban/di_chuyen/di_thang_3_o.json`):

| Lỗi | Câu |
|---|---|
| Thiếu khóa | `<f>: thiếu khóa "mo_ta"` (với khóa con: `"truoc.quan"`) |
| `mo_ta` rỗng | `<f>: "mo_ta" không được để trống` |
| Sai kiểu | `JsonFile.type_error`, ví dụ `<f>: "da_duyet" phải là true hoặc false, đang là "true"`; `<f>: "truoc" phải là một object, đang là []`; `<f>: "hanh_dong" phải là một danh sách, đang là {}` |
| Lớp bàn cờ | Câu của file trận, đổi tên lớp: `<f>: "truoc.dia_hinh" dòng 1, cột 1 (ô 0,0): ký hiệu lạ "X"` |
| `truoc` không có quân | `<f>: "truoc.quan" không có quân nào` |
| `mau` ô không có quân | `<f>: "truoc.mau" ô 4,4 không có quân` |
| `mau` khóa không phải tọa độ | `<f>: "truoc.mau" có khóa "abc" không phải tọa độ "cot,hang"` |
| `mau` số sai | `<f>: "sau.mau" ô 3,6: máu phải là số nguyên từ 1 tới 3, đang là 0` |
| Lệnh không phải object | `<f>: "hanh_dong" mục 2 phải là một object, đang là "di"` |
| Thiếu `lenh` | `<f>: "hanh_dong" mục 1: thiếu khóa "lenh"` |
| Lệnh lạ | `<f>: "hanh_dong" mục 1: lệnh lạ "chay", chỉ được "di", "danh", "huy", "ket_thuc_luot"` |
| Thiếu `tuong`/`o` | `<f>: "hanh_dong" mục 1 (di): thiếu khóa "o"` |
| Tướng sai | `<f>: "hanh_dong" mục 1 (di): "tuong" là "4", chỉ được "1", "2", "3"` |
| Tướng không có trên bàn | `<f>: "hanh_dong" mục 1 (di): tướng "3" không có trong "truoc.quan"` |
| Ô sai | `<f>: "hanh_dong" mục 1 (di): "o" là "9,9", không phải ô trong bàn` |
| Khóa lạ (cảnh báo) | `<f>: bỏ qua khóa lạ "ghi_chu"` (như file trận; ở mọi cấp: gốc, `truoc`, `sau`, từng lệnh) |

Dev được chỉnh câu cho tự nhiên hơn, nhưng phải giữ đủ: file, khóa, vị trí, giá trị sai. Câu cuối cùng ghi vào Completion Notes.

### So kết quả (bộ chạy)

So `BattleState` sau khi chạy với `sau`, theo thứ tự cố định: địa hình (hàng trên xuống, trái sang phải), rồi quân (cùng thứ tự ô). Câu (tên quân bằng ký hiệu và tên đầy đủ):

| Khác | Câu |
|---|---|
| Địa hình | `sau: ô 2,3 mong đợi "." (đất trống), thực tế "L" (kho lương)` |
| Thiếu quân | `sau: ô 3,6 mong đợi 1 (Nguyễn Khoái, 3 máu), thực tế trống` |
| Thừa quân | `sau: ô 0,6 mong đợi trống, thực tế 1 (Nguyễn Khoái, 3 máu)` |
| Khác loại | `sau: ô 5,4 mong đợi B, thực tế K` |
| Khác máu | `sau: ô 5,4 B mong đợi 1 máu, thực tế 2 máu` |

Tên đầy đủ trong câu so sánh lấy từ bảng hằng trong `scenario_runner.gd`, không qua `tr()` (câu cho dev và log, giống câu lỗi). Công cụ duyệt dùng `tr()` vì đó là chữ cho tác giả đọc.

### Cách in (công cụ duyệt) **[Tác giả chốt 2026-10-18]**

```
━━━ di_chuyen/di_thang_3_o.json  [chưa duyệt]
Nguyễn Khoái đi thẳng 3 ô sang phải trên đất trống.

Hành động:
  1. Nguyễn Khoái đi tới 3,6

      TRƯỚC                   SAU
      0 1 2 3 4 5 6           0 1 2 3 4 5 6
   0  . . . ~ . . .        0  . . . ~ . . .
   1  . . . ~ . . .        1  . . . ~ . . .
   2  . . . ~ . . .        2  . . . ~ . . .
   3  . . . . . . .        3  . . . . . . .
   4  . . . ~ . B .        4  . . . ~ . B .
   5  . . . ~ . . .        5  . . . ~ . . .
   6  1 . . . . . .        6  . . . 1 . . .

  Máu:  5,4 Bộ binh 1/3     Máu:  5,4 Bộ binh 1/3

Tổng: 1 kịch bản chờ duyệt.
Duyệt: thấy đúng thì đổi "da_duyet": false thành true trong file, hoặc nhắn AI "đúng"/"sai: <lý do>".
```

- Mỗi ô in **một ký hiệu**: có quân thì in ký hiệu quân, không có thì in ký hiệu địa hình.
- Quân đứng trên ô có ký hiệu riêng (hầm chông `^`, ô ải `A`) thì địa hình bị che. Dưới bàn ghi thêm `Dưới quân: 2,3 ^ (hầm chông)`.
- Dòng "Máu" chỉ liệt kê quân không đầy máu. Không có quân nào như vậy thì bỏ dòng đó.
- Lệnh viết bằng chữ: `di` → `<tên tướng> đi tới c,h`; `danh` → `<tên tướng> đánh ô c,h`; `huy` → `Hủy nước đi gần nhất`; `ket_thuc_luot` → `Kết thúc lượt (chạy pha địch)`.
- Không dùng màu terminal (chạy được mọi nơi, chép dán được cho AI).
- Kịch bản sắp theo `id`.

### Kịch bản mẫu

`game/tests/kich_ban/di_chuyen/di_thang_3_o.json`:

```json
{
  "phien_ban_dinh_dang": 1,
  "mo_ta": "Nguyễn Khoái đi thẳng 3 ô sang phải trên đất trống. Bộ binh 1 máu đứng yên.",
  "da_duyet": false,
  "truoc": {
    "dia_hinh": [
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . . . . .",
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . . . . ."
    ],
    "quan": [
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . B .",
      ". . . . . . .",
      "1 . . . . . ."
    ],
    "mau": { "5,4": 1 }
  },
  "hanh_dong": [
    { "lenh": "di", "tuong": "1", "o": "3,6" }
  ],
  "sau": {
    "dia_hinh": [
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . . . . .",
      ". . . ~ . . .",
      ". . . ~ . . .",
      ". . . . . . ."
    ],
    "quan": [
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . . .",
      ". . . . . B .",
      ". . . . . . .",
      ". . . 1 . . ."
    ],
    "mau": { "5,4": 1 }
  }
}
```

- Dùng hàng 6 không có sông (ô `3,6` là `.`), để kịch bản chỉ thử "đi 3 ô", không dính luật sông.
- Bộ binh có `mau` để kịch bản mẫu cho thấy cách ghi máu.
- Tầm đi 3 của tướng lấy từ `chi_so.json`, không ghi trong kịch bản.

### Vì sao chọn luật đỏ/xanh ở AC 4

- Quy trình M3: AI viết kịch bản → tác giả duyệt → kịch bản **phải trượt** → viết code tới khi xanh. Mẫu git: chỉ commit khi `test.sh` xanh.
- Nếu kịch bản chưa duyệt mà trượt cũng làm `test.sh` đỏ, AI không commit được kịch bản để tác giả duyệt. Tác giả lại duyệt trên file chưa commit, nên khóa `da_duyet` (so với HEAD) không bảo vệ được gì.
- Với AC 4: kịch bản chưa duyệt được commit (xanh, có dòng ⏳). Tác giả đổi `da_duyet: true`. `test.sh` đỏ (kịch bản đã duyệt trượt). AI viết code tới khi xanh, rồi commit cả kịch bản đã duyệt lẫn code. Từ commit đó, khóa có tác dụng.
- Chỗ hở còn lại: từ lúc tác giả đổi `true` tới lúc commit, AI có thể sửa file mà khóa không biết. Luật dự án đã cấm việc này ("Cấm xóa hoặc sửa kịch bản `da_duyet: true` để test đạt"). Không thêm cơ chế mới ở story này.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Luật đi (`Rules.resolve`, `Command`, BFS) và đợt kịch bản `di_chuyen/` đầy đủ | 1.4 |
| Hủy nước đi, kết thúc lượt trong bộ chạy | 1.5 |
| Đánh, đẩy, sự kiện trong `sau` (`su_kien`, ví dụ `chet_duoi`) | 2.1 trở đi (thêm khóa vào định dạng khi cần, kèm câu lỗi) |
| `test_determinism.gd` (chạy mỗi kịch bản hai lần) | E2, khi có luật |
| F2 xuất trạng thái theo dạng `truoc` | 2.13 (dùng lại `BoardLayers`/`BoardText`) |
| Tự kiểm tự động cho khóa `da_duyet` (mục hoãn của Story 0.2) | Vẫn hoãn: cần một kịch bản đã duyệt thật trong repo. Ghi lại ở Completion Notes nếu Task 12.3 cho thấy cách làm |
| Màu chữ trong terminal | Không làm |

### Luật kiến trúc phải theo

- `src/data/` không dùng Node; được dùng `FileAccess`, `DirAccess`. Chỉ phụ thuộc `src/core/` và `Log`. `BoardLayers`, `ScenarioLoader`, `ScenarioData` nằm ở đây.
- `src/core/` không I/O. Chỉ thêm tham số `hp` vào `UnitPlacement` và `UnitFactory`.
- Bộ chạy và công cụ duyệt nằm trong `game/tests/`: không vào bản export, không bị `check_boundaries.sh` quét.
- Quân chỉ tạo qua `UnitFactory.create`. Máu chỉ gán trong `_init`.
- Gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). Giá trị JSON là `Variant`: kiểm kiểu rồi ép kiểu, không dùng `:=` trên nó. JSON trả số về `float`: dùng `JsonFile.is_whole` / `int()`.
- Dùng `JSON.new().parse()` (qua `JsonFile.parse_object`), không dùng `JSON.parse_string()` (tự in ERROR).
- Tất định: duyệt file theo đường dẫn đã sắp, duyệt ô theo hàng rồi cột. Không duyệt theo khóa Dictionary khi thứ tự có ý nghĩa (ví dụ khi in `mau`, sắp theo ô).

### Ghi chú kỹ thuật Godot 4.7.2

- Chạy script dòng lệnh: `godot --headless --path game -s res://tests/scenario_viewer.gd -- di_chuyen`. Script phải `extends SceneTree` (hoặc `MainLoop`); làm việc trong `_initialize()` rồi `quit(code)`. Tham số sau `--` đọc bằng `OS.get_cmdline_user_args()`. Tra Context7 (`/godotengine/godot-docs/__branch__4.7`) nếu cần: `SceneTree._initialize`, `OS.get_cmdline_user_args`.
- Autoload (`AppState`) và bản dịch (`tr()`) có sẵn khi chạy `-s` (GUT cũng chạy kiểu này và test đã dùng `tr()`). Kiểm lại khi làm; nếu `tr()` chưa có thì gọi `TranslationServer.translate()`.
- `DirAccess.open(dir)` trả `null` nếu thư mục không có. Dùng `get_files()` và `get_directories()` (trả `PackedStringArray`), rồi tự sắp.
- `--headless` vẫn in dòng banner `Godot Engine v4.7.2…` ra stdout: lọc trong `xem_kich_ban.sh` (`grep -v '^Godot Engine'`, bọc `|| true`).
- `OS.get_environment("KET_QUA_KICH_BAN")` trả `""` khi không có biến.
- Đọc `KET_QUA_DIR` trong `test.sh`: đường tuyệt đối, ngoài `game/`. Ghi file bằng `FileAccess.open(path, FileAccess.WRITE)` với đường tuyệt đối là được.

### Cấu trúc file sau story

```
game/
├── src/
│   ├── core/
│   │   ├── level_data.gd        # UnitPlacement có hp (0 = đầy)
│   │   └── unit_factory.gd      # create(..., hp = 0)
│   └── data/
│       ├── board_layers.gd      # MỚI: đọc lớp bàn cờ, kiểm ô, thu_tu_dich (dùng chung)
│       ├── level_loader.gd      # gọi BoardLayers, câu lỗi không đổi
│       ├── scenario_data.gd     # MỚI
│       └── scenario_loader.gd   # MỚI
├── i18n/text.csv                # + scenario.unit.*
└── tests/
    ├── kich_ban/
    │   └── di_chuyen/
    │       └── di_thang_3_o.json  # MỚI, da_duyet: false
    ├── scenario_runner.gd       # MỚI (không phải test GUT)
    ├── scenario_viewer.gd       # MỚI (công cụ duyệt)
    ├── test_scenarios.gd        # MỚI
    └── test_scenario_loader.gd  # MỚI
tools/
├── test.sh                      # + dòng "Kịch bản luật"
└── xem_kich_ban.sh              # MỚI
```

Nhớ commit file `.uid` của mọi script mới.

### Testing

- `tools/test.sh` là lệnh duy nhất. Mọi test chạy `--headless`.
- Câu lỗi so **nguyên văn** (như `test_loaders.gd`). Test không so chữ đã dịch cụ thể (tác giả được sửa CSV), mà so với `tr(khóa)`.
- Không có test tự động cho đầu ra của `xem_kich_ban.sh` (công cụ cho người). Có thể tách hàm dựng chuỗi (`ScenarioViewer.render(scenario) -> String`) để test một ca, không bắt buộc.

**Mẫu hướng dẫn tác giả tự test** (ghi vào Completion Notes, theo kết quả thật):
1. Gõ `tools/test.sh`. Đúng là: `✅ … test đạt`, có dòng `Kịch bản luật: 0 đã duyệt · 1 chưa duyệt (1 chưa đạt)` và dòng `⏳ di_chuyen/di_thang_3_o.json`.
2. Gõ `tools/xem_kich_ban.sh`. Đúng là: thấy kịch bản mẫu, bàn trước và bàn sau cạnh nhau, Nguyễn Khoái từ `0,6` sang `3,6`.
3. Gõ `tools/xem_kich_ban.sh di_chuyen`: thấy giống bước 2. Gõ `tools/xem_kich_ban.sh xyz`: thấy câu "không có nhóm".
4. Mở file kịch bản mẫu, đổi `mau` của Bộ binh thành `5`, gõ `tools/test.sh`. Đúng là: trượt, có câu báo máu phải từ 1 tới 3. Sửa lại như cũ.
5. **Không** đổi `da_duyet` của kịch bản mẫu: luật đi chưa có, nên đổi là `test.sh` đỏ. Đợt duyệt thật đầu tiên ở Story 1.4.

### Previous Story Intelligence (Story 1.2 và code review)

- Code review 1.2 bắt lỗi "đúng sẵn" trong test: test mở trận lỗi nên không kiểm được gì. Ở đây: test bộ chạy phải có ca **trượt thật** (khác máu, khác ô), không chỉ ca đạt.
- Regex `^…$` của PCRE để lọt `\n` ở cuối: dùng `\A…\z` nếu cần regex (ví dụ kiểm tên nhóm).
- Số rất dài làm `to_int()` in ERROR: dùng `BoardText.parse_cell` (đã chặn bằng `MAX_CELL_DIGITS`) cho mọi tọa độ, kể cả khóa trong `mau`.
- Queue_free không gỡ node ngay: không liên quan story này (không có UI).
- Enum phe là `Unit.Faction` (không phải `Side`: trùng enum có sẵn của Godot).
- GoPeak có lúc mất kết nối: story này không cần chụp màn hình.

### Git Intelligence

- 5 commit gần nhất: `3d1a664` (sửa theo review 1.2), `06beb1d` (Story 1.2), `4285462` (sửa theo review 1.1), `58b6751` (Story 1.1), `ac98e37` (tạo story 1.1).
- Mẫu: mỗi story một commit chính, rồi một commit "Sửa theo code review Story X". Lời commit tiếng Việt, gạch đầu dòng theo thay đổi.
- `test.sh` có nhiều chốt chống xanh giả (Story 0.2, 0.4): đếm file test theo file `.gd`, test không assert là trượt, lỗi script trong log là trượt. `test_scenarios.gd` và `test_scenario_loader.gd` phải được đếm đúng.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- M3 không ngoại lệ: kịch bản `da_duyet: true` không bao giờ bị sửa hay xóa để test đạt. Nghi kịch bản sai thì hỏi tác giả.
- Kịch bản luật là spec, đặt ở `game/tests/kich_ban/<nhóm>/<luat>_<truong_hop>.json`, tên tiếng Việt không dấu.
- Sau mỗi lần phân giải trong test gọi `state.validate()` (bộ chạy làm việc này).
- Câu cho tác giả bằng tiếng Việt. Chữ hiển thị qua `tr()`; câu lỗi dữ liệu không qua `tr()` (theo Story 1.1).
- Commit chỉ khi `tools/test.sh` xanh.
- Lệnh cho tác giả nằm trong `tools/`, chạy từ gốc repo.

### Quyết định trong story này (tác giả đồng ý cả 6 mục, 2026-10-18)

1. **Kịch bản chưa duyệt mà chưa đạt không làm `test.sh` đỏ** (AC 4). Lý do ở mục "Vì sao chọn luật đỏ/xanh".
2. **Cách in của công cụ duyệt** (AC 1): một ký hiệu mỗi ô, quân che địa hình, chú thích "Dưới quân" và "Máu" dưới bàn.
3. **Mặc định chỉ in kịch bản chưa duyệt**, `--tat_ca` để in hết (AC 2).
4. **Máu trong kịch bản**: chỉ ghi quân không đầy máu, theo ô (`"mau": {"5,4": 1}`).
5. **`thu_tu_dich` trong kịch bản không bắt buộc**; không ghi thì theo thứ tự đọc bàn.
6. **`sau` so theo ô**, không theo id quân.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.3]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Dữ liệu trận, chỉ số và kịch bản luật]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#M3. Kịch bản luật là spec (quy trình)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Mẫu git]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Cây thư mục] (`scenario_loader.gd`, `test_scenarios.gd`, `xem_kich_ban.sh`)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Ranh giới kiến trúc]
- [Source: _bmad-output/project-context.md#Test]
- [Source: _bmad-output/implementation-artifacts/0-2-mot-lenh-de-chay-toan-bo-test.md] (khóa `da_duyet`, chốt chống xanh giả)
- [Source: _bmad-output/implementation-artifacts/1-1-nap-chi-so-va-tran-tu-file-bao-loi-bang-tieng-viet.md] (câu lỗi, `LoadResult`)
- [Source: _bmad-output/implementation-artifacts/1-2-hien-ban-co-tran-1-bo-cuc-dau-tien.md] (id quân, `BattleState`, review findings)

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1: tách hàm sang `BoardLayers`, chạy `tools/test.sh` ngay sau đó: 188/188 xanh, `test_loaders.gd` không sửa dòng nào.
- Kiểm test bắt lỗi thật: cố ý làm hỏng hai chỗ (bộ chạy bỏ so máu, bộ nạp bỏ ghi `mau`) thì đúng 2 test trượt (`test_hp_overrides_one_unit_and_others_are_full`, `test_runner_reports_hp_difference`). Đã trả code về như cũ.
- Task 8.3: tạm đổi tên biến môi trường trong `test_scenarios.gd` thì `test.sh` in `Kịch bản luật: không đọc được kết quả` và trượt. Đã trả lại.
- Task 12.3 (khóa, trên bản clone tạm, nhánh `thu_khoa`, đã xóa): đổi mẫu thành `da_duyet: true` rồi commit thì `test.sh` trượt với `kịch bản đã duyệt di_chuyen/di_thang_3_o.json: bước 1: lệnh "di" chưa có luật (Story 1.4)`. Sửa file thì thêm dòng `❌ game/tests/kich_ban/di_chuyen/di_thang_3_o.json: kịch bản đã duyệt bị sửa so với commit gần nhất`. Repo chính không bị đụng.
- Lần đầu chạy, thông điệp trượt của kịch bản đã duyệt có nhiều dòng nên tóm tắt `test.sh` chỉ hiện dòng đầu, không thấy lý do. Đã gộp lý do vào một dòng (nối bằng `; `).
- Công cụ duyệt in thêm `[WARN][app] bỏ qua tham số lạ: "di_chuyen"`, vì `AppState` (autoload) đọc mọi tham số sau `--`. Đã đổi sang truyền tham số qua biến môi trường `XEM_KICH_BAN_THAM_SO`.
- Thử tay công cụ duyệt: không tham số, `di_chuyen`, `xyz` (mã 1), `--tat_ca`, `--abc` (in `bỏ qua tham số lạ`). Tạm đổi mẫu thành đã duyệt thì in `Không có kịch bản nào chờ duyệt.`. Tạm sửa máu thành 5 thì in `[sai định dạng]` kèm 2 câu lỗi và thoát mã 1. Mọi thay đổi tạm đã trả lại.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Đã làm đủ Task 1–12. `tools/test.sh`: 221/221 đạt (thêm 33 test), ranh giới đạt.
- **Lệch so với story (ghi để review):**
  - Tham số của công cụ duyệt đi qua biến môi trường `XEM_KICH_BAN_THAM_SO`, không qua `OS.get_cmdline_user_args()` như Task 9.2 (lý do ở Debug Log).
  - Lớp con trong bộ nạp tên `Section`, không đặt `Side` (trùng enum có sẵn của Godot, như bài học Story 1.2).
  - Thêm 2 khóa dịch ngoài Task 10.1: `scenario.terrain.spikes` (hầm chông), `scenario.terrain.pass` (ô ải), dùng cho dòng "Dưới quân".
  - Thêm `BoardLayers.reading_order()` (thứ tự đọc bàn), dùng chung cho `thu_tu_dich` mặc định của kịch bản và cho việc tìm quân Nguyên thiếu trong `thu_tu_dich` của file trận (cùng thứ tự như code cũ).
  - Khóa lạ lồng nhau được cảnh báo kèm tiền tố cho dễ tìm: `bỏ qua khóa lạ "truoc.ghi_chu"`; trong lệnh: `"hanh_dong" mục 1 (huy): bỏ qua khóa lạ "tuong"`.
  - `JSON.stringify` (chỉ dùng trong test) sắp khóa theo chữ cái, nên trong test lỗi `mau` ra theo thứ tự chữ cái. File thật giữ thứ tự như trong file.
- **Câu lỗi cuối cùng:** đúng như bảng ở Dev Notes "Định dạng kịch bản". Từng câu có test so nguyên văn trong `game/tests/test_scenario_loader.gd`.
- Tự kiểm tự động cho khóa `da_duyet` (mục hoãn của Story 0.2) **vẫn hoãn**. Task 12.3 cho thấy cách làm: clone tạm, commit file khóa, sửa, đòi trượt. Nên làm khi có kịch bản đã duyệt đầu tiên (Story 1.4).

**Đầu ra thật của `tools/xem_kich_ban.sh`:**

```
━━━ di_chuyen/di_thang_3_o.json  [chưa duyệt]
Nguyễn Khoái đi thẳng 3 ô sang phải trên đất trống. Bộ binh 1 máu đứng yên.

Hành động:
  1. Nguyễn Khoái đi tới 3,6

      TRƯỚC                   SAU
      0 1 2 3 4 5 6           0 1 2 3 4 5 6
   0  . . . ~ . . .        0  . . . ~ . . .
   1  . . . ~ . . .        1  . . . ~ . . .
   2  . . . ~ . . .        2  . . . ~ . . .
   3  . . . . . . .        3  . . . . . . .
   4  . . . ~ . B .        4  . . . ~ . B .
   5  . . . ~ . . .        5  . . . ~ . . .
   6  1 . . . . . .        6  . . . 1 . . .

  Máu: 5,4 Bộ binh 1/3    Máu: 5,4 Bộ binh 1/3

Tổng: 1 kịch bản chờ duyệt.
Duyệt: thấy đúng thì đổi "da_duyet": false thành true trong file, hoặc nhắn AI "đúng"/"sai: <lý do>".
```

`tools/xem_kich_ban.sh xyz` → `không có nhóm "xyz". Các nhóm đang có: di_chuyen` (mã thoát 1).

**Tóm tắt của `tools/test.sh`:**

```
[4/4] Test GUT: 221/221 đạt
      Kịch bản luật: 0 đã duyệt · 1 chưa duyệt (1 chưa đạt)
  ⏳ di_chuyen/di_thang_3_o.json: chưa duyệt, chưa đạt

✅ 221/221 test đạt
```

**Hướng dẫn tác giả tự test:**
1. Gõ `tools/test.sh`. Đúng là: `✅ 221/221 test đạt`, có dòng `Kịch bản luật: 0 đã duyệt · 1 chưa duyệt (1 chưa đạt)` và dòng `⏳ di_chuyen/di_thang_3_o.json`.
2. Gõ `tools/xem_kich_ban.sh`. Đúng là: thấy kịch bản mẫu như khung trên, Nguyễn Khoái từ `0,6` sang `3,6`.
3. Gõ `tools/xem_kich_ban.sh di_chuyen`: thấy giống bước 2. Gõ `tools/xem_kich_ban.sh xyz`: thấy câu "không có nhóm".
4. Mở `game/tests/kich_ban/di_chuyen/di_thang_3_o.json`, đổi `"5,4": 1` (trong `truoc`) thành `5`, gõ `tools/test.sh`. Đúng là: trượt, có câu `"truoc.mau" ô 5,4: máu phải là số nguyên từ 1 tới 3, đang là 5`. Sửa lại như cũ.
5. **Không** đổi `da_duyet` của kịch bản mẫu: luật đi chưa có, nên đổi là `test.sh` đỏ. Đợt duyệt thật đầu tiên ở Story 1.4.

### File List

- `_bmad-output/implementation-artifacts/1-3-kich-ban-luat-va-cong-cu-duyet-tren-terminal.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `game/i18n/text.csv`
- `game/i18n/text.vi.translation`
- `game/src/core/battle_state.gd`
- `game/src/core/level_data.gd`
- `game/src/core/unit_factory.gd`
- `game/src/data/board_layers.gd` (mới) + `.uid`
- `game/src/data/level_loader.gd`
- `game/src/data/scenario_data.gd` (mới) + `.uid`
- `game/src/data/scenario_loader.gd` (mới) + `.uid`
- `game/tests/kich_ban/di_chuyen/di_thang_3_o.json` (mới)
- `game/tests/scenario_runner.gd` (mới) + `.uid`
- `game/tests/scenario_viewer.gd` (mới) + `.uid`
- `game/tests/test_battle_state.gd`
- `game/tests/test_scenario_loader.gd` (mới) + `.uid`
- `game/tests/test_scenarios.gd` (mới) + `.uid`
- `tools/test.sh`
- `tools/xem_kich_ban.sh` (mới)

### Change Log

- 2026-10-18: Tạo story.
- 2026-10-18: Làm story: định dạng kịch bản luật, bộ nạp, bộ chạy, công cụ duyệt `tools/xem_kich_ban.sh`, số kịch bản trong `tools/test.sh`, kịch bản mẫu `di_chuyen/di_thang_3_o.json`.
- 2026-10-18: Sửa theo code review. Công cụ duyệt: không treo khi script lỗi, thoát mã 1 khi script lỗi, bỏ dòng trống đầu, chữ qua bản dịch (`scenario.viewer.*`), dòng `Máu:` theo mẫu "Cách in" (tác giả chốt), ghi chú bàn sau luôn thẳng cột và cùng loại cùng dòng, `--tat_ca` khi không có kịch bản in `Chưa có kịch bản nào.`, không còn nhóm rỗng. `tools/test.sh`: in lý do chưa đạt (AC 6), câu lỗi định dạng đủ câu, file sai định dạng vẫn được đếm. Bộ nạp: báo file rỗng, ô `mau` ngoài bàn, một ô ghi hai lần. Bộ chạy: ký hiệu lấy ngược từ `BoardText`, câu sai loại quân có tên và máu. `UnitFactory`: máu không quá máu đầy.
