---
baseline_commit: 6030532
---

# Story 2.13: F2 sao chép báo lỗi

Status: review

## Story

Là tester,
tôi muốn báo lỗi bằng một phím,
để dán thẳng cho AI mà không phải tả lại.

## Acceptance Criteria

1. **Cho** game đang chạy, đã bật dev, **khi** bấm F2 **thì** clipboard có: bàn hiện tại (dạng `truoc` của kịch bản), các lệnh trong hiệp, 200 dòng log, phiên bản build.
2. **Và** màn hình báo "Đã sao chép báo lỗi".
3. **Khi** dán nội dung đó cho AI **thì** AI chuyển được thành một kịch bản tái hiện lỗi (thử trên một lỗi cố tình tạo ra).

## Tasks / Subtasks

- [x] **Task 1: `BoardText` ghi được bàn cờ** (AC: 1)
  - [x] 1.1 Thêm `BoardText.unit_symbol(type: int) -> String` và `BoardText.terrain_symbol(kind: int) -> String` (chiều ngược của `UNIT_SYMBOLS`/`TERRAIN_SYMBOLS`); ký hiệu lạ trả `"?"`.
  - [x] 1.2 `game/tests/scenario_runner.gd`: `unit_symbol`/`terrain_symbol` gọi lại `BoardText`, bỏ bản sao (giữ chữ ký hàm để test 1.3 cũ không đổi).
  - [x] 1.3 Test trong `test_scenario_loader.gd` (đã có `assert_eq(ScenarioRunner.unit_symbol(...))`): thêm ca mọi ký hiệu của `BoardText.UNIT_SYMBOLS`/`TERRAIN_SYMBOLS` đi và về đúng, và ca ký hiệu lạ.

- [x] **Task 2: Nhật ký lệnh + bàn đầu hiệp trong `BattleController`** (AC: 1, 3)
  - [x] 2.1 `_round_start: BattleState` và `_round_commands: Array[Dictionary]`; mỗi mục `{"lenh": "...", "tuong": "1", "o": "3,3", "tu_choi": "..."}` — chỉ có khóa dùng được, đúng định dạng `hanh_dong` của kịch bản.
  - [x] 2.2 `submit()` ghi **mọi** lệnh: chạy được lẫn bị từ chối (kèm mã `tu_choi`), vì lệnh bị từ chối thường chính là lỗi đang báo. `undo()` ghi `{"lenh": "huy"}`.
  - [x] 2.3 Mốc "đầu hiệp": sau `BEGIN_BATTLE`/`END_TURN` chạy được, `_round_start = _state.clone()` và `_round_commands.clear()` — **trừ** khi báo cáo đang ở đúng cửa sổ "vừa kết thúc lượt": xem 2.4.
  - [x] 2.4 Giữ được pha địch: nếu F2 rơi vào lúc vừa `ket_thuc_luot` mà người chơi chưa ra lệnh nào ở hiệp mới, báo cáo phải dùng `_round_start` **cũ** + toàn bộ lệnh (gồm `ket_thuc_luot`), để phát lại ra đúng pha địch vừa xảy ra. Cách gọn: chỉ chốt mốc mới ở lệnh **đầu tiên sau** `BEGIN_BATTLE`/`END_TURN` (hoặc ở `END_TURN`, nhưng đẩy mốc cũ vào `_prev_round` và dùng `_prev_round` khi `_round_commands` rỗng). Chọn cách nào cũng phải có test cho cả hai cửa sổ.
  - [x] 2.5 Accessor chỉ đọc: `round_start_snapshot() -> BattleState` (clone), `round_commands() -> Array[Dictionary]` (chép sâu).
  - [x] 2.6 Test `test_battle_controller.gd`: (a) đi 1 nước rồi xem trước — `_round_start` không đổi, `round_commands()` có đúng lệnh đó; (b) từ chối lệnh → vẫn ghi kèm `tu_choi`, state không đổi; (c) `undo` ghi `huy`; (d) sau `ket_thuc_luot`, báo cáo vẫn phát lại được pha địch (so bàn sau khi phát lại với `snapshot()`).

- [x] **Task 3: `BugReport` dựng nội dung** (AC: 1, 3)
  - [x] 3.1 `game/src/debug/bug_report.gd` — `class_name BugReport extends RefCounted`, `static func build(state: BattleState, round_start: BattleState, commands: Array[Dictionary], log_lines: PackedStringArray, meta: Dictionary) -> String`. Không đọc autoload, không đọc `BattleController` — mọi thứ truyền vào, để test được.
  - [x] 3.2 `meta`: `phien_ban` (`"v0.1.0 · 6030532"`), `tran` (id trận), `hiep`, `luc` (giờ máy), `lan_mo` (SaveProbe), `dang_choi` (bool).
  - [x] 3.3 Dựng `truoc` từ `round_start`: `dia_hinh` (`BoardText.terrain_symbol`), `quan`, `mau` (chỉ quân thiếu máu, `{"cot,hang": máu}`), `thu_tu_dich` (ô quân Nguyên theo **id tăng dần**), `bao_don` (từ `telegraphs`, xếp theo `order`: CELL → `o` = ô chủ + `offset`; DIRECTION → `huong`). Đòn của chủ đã gục thì **bỏ** và ghi chú trong báo cáo (bộ nạp không nhận `quan` là ô không có quân Nguyên).
  - [x] 3.4 Dựng `hanh_dong` từ `commands` (đã đúng định dạng ở 2.1).
  - [x] 3.5 Khối JSON kịch bản: `{"phien_ban_dinh_dang": 1, "mo_ta": "Báo lỗi F2 …", "da_duyet": false, "truoc": {...}, "hanh_dong": [...]}`, in bằng `JSON.stringify(data, "  ")` để AI đọc được.
  - [x] 3.6 Phần "bàn hiện tại" (không phải kịch bản, chỉ để đối chiếu): `dia_hinh`, `quan`, `mau`, `hiep`, và với từng tướng `đã đi`/`chưa đi`, `đã đánh`/`chưa đánh`.
  - [x] 3.7 Đầu báo cáo: phiên bản build, trận, hiệp, giờ, lần mở; cuối báo cáo: 200 dòng log (cũ → mới) và một câu chỉ dẫn cho AI ("khối JSON ở trên là kịch bản tái hiện; chạy `tools/test.sh` sau khi thêm vào `game/tests/kich_ban/<nhóm>/`").
  - [x] 3.8 Test `game/tests/test_bug_report.gd`: đủ các mục; bàn `dia_hinh`/`quan` khớp state (đi từng ô); `mau` chỉ có quân thiếu máu; `thu_tu_dich` đúng thứ tự id; `bao_don` đúng cho cả CELL và DIRECTION; log cắt còn 200 dòng cũ nhất ở đầu; báo cáo không chứa ký tự điều khiển lạ.

- [x] **Task 4: Phím F2 + clipboard** (AC: 1, 2)
  - [x] 4.1 `game/src/debug/dev_tools.gd`: thêm `signal f2_pressed`; bấm F2 phát signal; xoá câu `"f2: chưa có sao chép báo lỗi (story 2.13)"` khỏi `MESSAGES`.
  - [x] 4.2 `game/src/app/main.gd`: nối `dev_tools.f2_pressed` trong nhánh bật dev (cùng chỗ với F1/F3/F5). `func _on_f2()`: lấy `_controller.round_start_snapshot()`, `round_commands()`, `Log.get_lines()`, dựng meta, gọi `BugReport.build`, rồi `clipboard_writer.call(text)`, hiện `Notice`.
  - [x] 4.3 Seam test: `var clipboard_writer: Callable` trên `main.gd`, mặc định `DisplayServer.clipboard_set`. Test thay bằng hàm bắt chuỗi — không đọc clipboard thật (chạy headless không có clipboard).
  - [x] 4.4 Không có trận (`_controller == null`: màn hình lỗi/menu): vẫn chép log + phiên bản, phần bàn ghi `(không có trận)` (Câu hỏi 2).
  - [x] 4.5 Test `test_main.gd`: bật dev → bấm F2 → `clipboard_writer` nhận chuỗi có `"phien_ban_dinh_dang"` và tên trận, `Notice` hiện đúng câu; **không** bật dev → F2 không làm gì (không gọi writer, không hiện notice); màn hình lỗi → vẫn chép được (không có khối `truoc`).

- [x] **Task 5: Thông báo ngắn `Notice`** (AC: 2)
  - [x] 5.1 `game/src/ui/notice.gd` — `class_name Notice extends Control`: `show_text(text: String)`, tự ẩn sau `SHOW_SECONDS` (2,5 s) bằng `Tween` (theo luật hoạt ảnh của dự án); `text()`, `is_shown()` cho test; `mouse_filter = IGNORE`; đặt giữa bàn, phía trên đáy, không che HUD.
  - [x] 5.2 Chữ qua `tr()`: khóa mới `dev.copied` = "Đã sao chép báo lỗi", `dev.copied_no_battle` = "Đã sao chép báo lỗi (không có trận)" — thêm vào `game/i18n/text.csv`, chạy `--headless --import` để sinh lại `text.vi.translation`.
  - [x] 5.3 Test `game/tests/test_notice.gd`: `show_text` → `is_shown()` và đúng chữ; `await wait_seconds(SHOW_SECONDS + 0.5)` → đã ẩn; gọi liên tiếp hai lần không chồng chữ (chuỗi cuối thắng, một nhãn).

- [x] **Task 6: Phát lại đúng — test then chốt** (AC: 1, 3)
  - [x] 6.1 Test: dựng `BattleController` bằng trận `thu_lao`, chạy vài lệnh (đi, đánh, hủy, từ chối), dựng báo cáo, **tách khối JSON** ra, cho `ScenarioLoader` + `ScenarioRunner` chạy, so bàn cuối với `controller.snapshot()`: cùng ô, cùng máu, cùng `has_moved`/`has_attacked` cho từng quân. Đây là bằng chứng cho AC 3 ở mức dữ liệu.
  - [x] 6.2 Test riêng cho cửa sổ pha địch: đi 1 nước → `ket_thuc_luot` → (chưa ra lệnh gì) → báo cáo → phát lại phải ra đúng bàn sau pha địch (bàn, máu, đòn đã báo, thứ tự).
  - [x] 6.3 Test: báo cáo có `bao_don` thì phát lại phải còn đòn; báo cáo bỏ đòn của chủ đã gục thì phát lại vẫn chạy (không cần đòn đó để ra cùng bàn).

- [x] **Task 7: Kiểm bằng tay, tài liệu, commit** (AC: 1–3)
  - [x] 7.1 `tools/test.sh` xanh; ghi số test vào Debug Log.
  - [x] 7.2 `tools/chay.sh --dev --tran=thu_lao`: đi 1 nước, bấm F2, dán ra file; xác nhận có đủ 4 mục và bàn đầu hiệp + lệnh.
  - [x] 7.3 Lỗi cố tình: sửa tạm `data/chi_so.json` (ví dụ đẩy của Khoái từ 1 lên 2), chơi tới lúc đòn đẩy đi 2 ô, bấm F2, dán cho AI; AI trả về kịch bản; chạy kịch bản đó thấy tái hiện đúng lỗi. Ghi lại nguyên văn vào Debug Log (AC 3).
  - [x] 7.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, đúng những bước đã chạy.
  - [x] 7.5 Commit tiếng Việt kết `(Story 2.13)`, kèm `text.vi.translation` và mọi `.uid` mới.

## Dev Notes

### Hiện trạng liên quan (đọc trước khi sửa)

- `game/src/debug/dev_tools.gd`: F1–F5 đã đăng ký trong InputMap bằng code, chỉ khi bật dev; F2 hiện chỉ ghi log `"f2: chưa có sao chép báo lỗi (story 2.13)"` trong `MESSAGES`.
- `game/src/debug/log.gd`: `class_name Log`, `MAX_LINES = 200`, `get_lines()` trả bản sao cũ → mới. **Đã đủ cho AC "200 dòng log"** — không cần sửa.
- `game/src/app/main.gd`: `_read_version()` đọc `application/config/version`; nhãn góc màn hình là `"v%s · %s" % [version, BuildInfo.read_commit(BUILD_INFO_PATH)]`; `AppState.launch.dev` là cờ dev; `AppState.launch.level_id()` là id trận đang mở; `_level: LevelData` được giữ lại sau `_start_battle()`; `_controller: BattleController` là trạng thái sống.
- `game/src/battle/battle_controller.gd`: `submit()` là chỗ duy nhất nhận lệnh (gồm `undo()` riêng). Hiện **không** lưu lịch sử lệnh; `_undo_snapshot` chỉ giữ một bản. `_state.round_number` tăng trong `RulesEnemyPhase.end_player_turn`.
- `game/src/data/board_text.gd`: chỉ có chiều đọc (`UNIT_SYMBOLS`, `TERRAIN_SYMBOLS`, `split_row`, `parse_cell`, `cell_text`). `ScenarioRunner.unit_symbol/terrain_symbol` (trong `game/tests/`) đang làm chiều ngược nhưng **test không dùng được từ `src/`** — phải chuyển vào `BoardText`.
- `game/src/data/scenario_loader.gd`: khóa của `truoc` = `["dia_hinh", "quan", "mau", "thu_tu_dich", "bao_don"]` — **không có** `hiep`, `da_di`, `da_danh` (ba khóa đó chỉ có ở `sau`). Vì vậy `truoc` **không tả được** bàn giữa hiệp; xem Câu hỏi 1 và cách làm ở Task 2/3.
- `game/src/core/telegraph.gd`: `owner_id` + `kind` + `offset` (tương đối so với chủ đòn) + `order`. Bộ nạp chỉ nhận `o` **kề** ô chủ đòn, hoặc `huong` là một trong `B/D/N/T`.
- `game/src/core/battle_state.gd`: `units` (id 1–3 tướng theo `UnitType.GENERALS`, 101+ quân Nguyên), `terrain` (mảng phẳng theo `size.x`), `telegraphs`, `enemy_intents`, `round_number`, `phase`, `mission`, `stats`.
- `game/src/core/rules_enemy_phase.gd`: `end_player_turn` ra đòn → tăng hiệp → xoá `has_moved`/`has_attacked` → `prepare` (dựng lại `enemy_intents`, `telegraphs`). Nghĩa là **`enemy_intents` không cần đưa vào báo cáo** (mỗi pha địch dựng lại), nhưng `telegraphs` **phải** đưa (đòn đã báo còn treo).
- `game/src/data/level_loader.gd`: `thu_tu_dich` quyết định thứ tự append quân Nguyên vào `LevelData.units`, tức quyết định id 101, 102… — nên báo cáo phải ghi `thu_tu_dich` theo **id tăng dần** thì id mới khớp.
- `game/tests/scenario_runner.gd`: dựng state từ `truoc` (hiệp 1, mọi tướng `chưa đi/chưa đánh`) rồi chạy `hanh_dong` qua `BattleController` — dùng lại được để kiểm "báo cáo phát lại đúng" (Task 6).

### Luật kiến trúc phải theo

- **Cây kiến trúc đã có sẵn chỗ cho story này:** `src/debug/bug_report.gd` ("dựng nội dung F2") và `src/ui/notice.gd` ("thông báo ngắn") — `game-architecture.md` dòng ~590 và ~600. Không đặt code mới ở chỗ khác.
- `src/core/` là vùng cấm: báo cáo, clipboard, `Time`, `DisplayServer` đều nằm ngoài core. Story này **không sửa core**; nếu thấy cần thì dừng và hỏi tác giả.
- **Đi xuống gọi hàm, đi lên phát signal.** F2 đi từ `DevTools` (signal) → `main` (hàm). `Notice` nhận `show_text()`.
- Chữ hiển thị chỉ qua `tr()`; khóa mới vào `game/i18n/text.csv` rồi `--headless --import` sinh lại `game/i18n/text.vi.translation` (bắt buộc commit file này).
- Gõ kiểu tĩnh mọi nơi; Godot 4; không `print()` — dùng `Log`; không `Thread`; không `_process` cho việc một lần.
- JSON: dựng bằng Dictionary rồi `JSON.stringify(data, "  ")`; **mọi số máu, tọa độ, thứ tự phải là `int`**, không để `float`.
- Clipboard: `DisplayServer.clipboard_set(text)`. Trên web, trình duyệt chỉ cho ghi clipboard khi có thao tác người dùng — F2 là phím nên đủ điều kiện; nhưng phải kiểm trên bản web (Câu hỏi 3).
- `SaveProbe.path` là mẫu seam test của dự án (static var đổi được) — `clipboard_writer` trên `main` làm theo cùng tinh thần.

### Định dạng báo cáo (chốt trong story để dev không phải đoán)

Văn bản thuần, tiếng Việt, theo thứ tự:

```
Hào Khí Đông A — báo lỗi
phiên bản: v0.1.0 · 6030532
trận: tran_01 · hiệp 3 · lượt người chơi
lúc: 2026-10-22 15:04:11 · lần mở thứ 12

## Kịch bản tái hiện (dán vào game/tests/kich_ban/<nhóm>/<tên>.json)
{
  "phien_ban_dinh_dang": 1,
  "mo_ta": "Báo lỗi F2: ...",
  "da_duyet": false,
  "truoc": { "dia_hinh": [...], "quan": [...], "mau": {...}, "thu_tu_dich": [...], "bao_don": [...] },
  "hanh_dong": [ { "lenh": "di", "tuong": "1", "o": "3,4" }, ... ]
}

## Bàn hiện tại (để đối chiếu, không phải kịch bản)
hiep: 3 · Khoái: đã đi, chưa đánh · ...
dia_hinh / quan / mau như trên nhưng của trạng thái hiện tại

## Nhật ký (200 dòng gần nhất, cũ → mới)
[INFO][battle] ...
```

- `truoc` **không có** `mo_ta`/`da_duyet` bên trong — chúng ở cấp gốc của kịch bản.
- `mau` chỉ ghi quân có `hp < stats.max_hp(type)`; không có quân nào thiếu máu thì **bỏ khóa** `mau`.
- `thu_tu_dich` ghi **mọi** quân Nguyên còn sống, theo id tăng dần; không còn quân Nguyên thì `[]` (bộ nạp chấp nhận `[]`).
- `bao_don` sắp theo `order`; đòn của chủ đã gục thì bỏ (không serialize được) và thêm một dòng `bỏ 1 đòn của quân đã gục (số thứ tự N)` vào phần bàn hiện tại.
- `hanh_dong` giữ đúng thứ tự đã bấm, gồm cả lệnh bị từ chối (`"tu_choi": "<mã>"`) và `{"lenh": "huy"}`.

### Testing

- `tools/test.sh` là lệnh duy nhất; GUT qua `main.tscn`; trận thử ghi `user://`, xoá ở `after_each`.
- Trong phiên AI có sandbox: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`.
- Chạy một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_bug_report.gd -gexit`
- **Bẫy của story này:** (a) test so chuỗi báo cáo mà không chứng minh nó **phát lại được** — Task 6 là bắt buộc; (b) quên `mau`/`bao_don`/`thu_tu_dich` thì báo cáo vẫn "trông đúng" nhưng phát lại ra bàn khác; (c) ghi `float` vào JSON (máu, tọa độ) làm bộ nạp từ chối.
- Kiểm ngược (theo bài học 2.12): bỏ từng khóa (`mau`, `thu_tu_dich`, `bao_don`) → test phát lại phải trượt.
- Phần chỉ nhìn thấy (vị trí/hiệu ứng `Notice`) không test; test chuỗi và trạng thái hiện/ẩn.

### Previous Story Intelligence (2.12, 2.11, 2.10)

- 2.12: `BattleController.preview_result` là "chạy thử trên bản sao" — cùng tinh thần: báo cáo **chỉ đọc**, không đụng `_state`, không phát signal.
- 2.12: đừng để test chỉ so dữ liệu cùng nguồn (gần tautology); AC 3 cần một đường **độc lập**: JSON → loader → runner → so bàn.
- 2.12: kiểm ngược từng bản sửa; ghi lại bằng chứng vào Debug Log. 14 ảnh cũ của 2.12 không dùng lại được.
- 2.11: F2 bấm giữa lúc phát hoạt ảnh thì `_state` **đã** là trạng thái sau lệnh — báo cáo vẫn nhất quán, không cần đọc `_playing`.
- 2.10: mọi hàm chỉ đọc trạng thái phải dùng `snapshot()` (bản sao), không giữ tham chiếu `Unit`.
- 2.7/2.6: chuỗi mới → `text.csv` + sinh lại `text.vi.translation`; commit kèm `.uid` mới.

### Git Intelligence

- `6030532 Sửa theo code review vòng 2: số máu của bóng nằm trong ô, bỏ tên trên bóng (Story 2.12)`
- `f10d5d3 Xem trước kết quả đòn: bóng mờ, sửa theo code review (Story 2.12)`
- `b874ecd Rê chuột xem thông tin quân và ô (Story 2.10)`

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1, web đơn luồng.
- Không bật dev thì F1/F2/F3/F5 **không có tác dụng**; code debug vẫn nằm trong bản phát hành.
- 1280×720, stretch `canvas_items`, aspect `keep`; font tiếng Việt đủ dấu.
- Commit khi `tools/test.sh` xanh, lời commit tiếng Việt.
- Tác giả không đọc code: hướng dẫn tự test phải là các bước bấm/phím và thấy gì.

### Câu hỏi cho tác giả — ĐÃ CHỐT 2026-10-22

1. **`truoc` là bàn nào?** → **Bàn đầu hiệp + toàn bộ lệnh trong hiệp**, kèm mục "bàn hiện tại" để đối chiếu. Không sửa định dạng kịch bản.
2. **F2 khi không có trận** (màn hình lỗi, menu)? → **Vẫn chép log + phiên bản**, phần bàn ghi `(không có trận)`.
3. **Clipboard trên web bị chặn?** → Story này **chỉ ghi thêm một dòng log** "đã sao chép N ký tự"; chưa làm khung xem báo cáo.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.13 (dòng 865–884), và dòng 124 (danh sách công cụ dev), dòng 199 (phạm vi E2).
- `_bmad-output/planning-artifacts/game-architecture.md`: dòng 439 (log 200 dòng), dòng 517 (bảng phím F2), dòng 522 (hiện phiên bản build), dòng 570 (`board_text.gd` đọc/ghi), dòng 590 (`notice.gd`), dòng 600 (`bug_report.gd`), dòng 797 (quy trình: báo lỗi F2 → kịch bản trước, sửa sau).
- `_bmad-output/project-context.md` (Godot 4, không Thread, chữ qua `tr()`, test một lệnh).
- `game/src/debug/dev_tools.gd`, `game/src/debug/log.gd`, `game/src/app/main.gd`, `game/src/data/board_text.gd`, `game/src/data/scenario_loader.gd`, `game/src/core/telegraph.gd`, `game/src/core/battle_state.gd`, `game/src/core/rules_enemy_phase.gd`, `game/tests/scenario_runner.gd`, `game/src/battle/battle_controller.gd`.

## Dev Agent Record

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- `tools/test.sh`: **612/612 đạt** (trước story: 591; +21 test: 12 `test_bug_report`, 4 `test_notice`, 3 `test_main`, 2 `test_battle_controller`), 81 kịch bản đã duyệt, kiểm ranh giới + quét project đạt.
- Kiểm trong game thật (`tools/chay.sh --dev --tran=thu_lao`): gọi `_on_f2` qua cổng runtime GoPeak (7777) → log `[DEBUG][dev] f2: đã sao chép báo lỗi (2915 ký tự)`, `Notice` hiện đúng câu "Đã sao chép báo lỗi" (đọc qua runtime), tự ẩn sau ~3 giây. **Không bơm được phím F2 thật**: `inject_key` của GoPeak chỉ đặt `keycode`, còn `DevTools` khớp `physical_keycode` (nhánh phím đã có test `test_dev_tools` với `InputEventKey` đủ `physical_keycode`). Máy không có `xclip`/`xdotool` nên không đọc lại được clipboard thật.
- Báo cáo thật in từ trận `thu_lao` (script tạm, đã xoá): 2915 ký tự, khối JSON hợp lệ; `truoc` có 3 đòn báo, `sau` còn 2, `mau` chỉ ghi quân thiếu máu (`3,3=1`), `hanh_dong` là `danh` + `ket_thuc_luot`; phần bàn hiện tại ghi cờ đã đi/đã đánh của tướng.
- AC 3 (lỗi cố tình): dựng stats "đẩy 2 ô" thay vì 1 → lấy báo cáo → tách khối JSON → cho chính bộ nạp + bộ chạy kịch bản của game phát lại: ra đúng bàn đang thấy (`101@4,1`); chạy lại **cùng kịch bản** với stats đúng (đẩy 1) ra `101@3,1` — kịch bản phân biệt được lỗi. Script tạm đã xoá.
- **Chưa làm:** dán báo cáo cho một AI ngoài game (ChatGPT/Claude) — tác giả tự thử; phần chuyển JSON → kịch bản đã kiểm tự động.
- **Bẫy đã gặp khi tác giả thử bước 5:** lưu **cả báo cáo** vào `bao_loi.json` → `tests/test_scenarios.gd` báo `JSON sai cú pháp (Expected 'true', 'false', or 'null', got 'H')` và cả bộ trượt. Đã làm rõ ngay trong báo cáo (tiêu đề mục + ghi chú: cả báo cáo là .txt, chỉ khối json là .json) và trong hướng dẫn bước 5. Báo cáo gốc giữ ở `game/tests/kich_ban/thu/bao_loi.txt` (không commit); `bao_loi.json` đã tách đúng khối JSON.

### Completion Notes List

- `BoardText`: thêm `unit_symbol` / `terrain_symbol` / `direction_code` (chiều ngược của các bảng ký hiệu); `ScenarioRunner` gọi lại, bỏ bản sao.
- `BattleController`: `_round_start` + `_round_commands` ghi **mọi** lệnh (chạy được, bị từ chối kèm mã lý do, và `huy`). `round_start_snapshot()` / `round_commands()` trả bản sao. Cửa sổ ngay sau `ket_thuc_luot` (chưa ra lệnh nào ở hiệp mới) dùng bàn đầu hiệp **trước** + lệnh gồm `ket_thuc_luot`, để phát lại được cả pha địch.
- `BugReport` (mới): dựng báo cáo — khối JSON là **kịch bản hợp lệ** (`truoc` + `hanh_dong` + `sau` = bàn đang thấy), phần bàn hiện tại để đối chiếu, 200 dòng log, phiên bản, ghi chú cho AI. Chỉ đọc dữ liệu truyền vào, không đọc autoload, không phát signal.
- `Notice` (mới): bảng thông báo giữa bàn, tự mờ và ẩn sau 2,5 s, không nhận chuột.
- `DevTools`: thêm `f2_pressed`; `main`: nối F2 trong nhánh bật dev, `clipboard_writer` là seam để test bắt chuỗi (máy test không có clipboard), ghi log số ký tự đã chép.
- Chữ mới `dev.copied`, `dev.copied_no_battle` trong `text.csv`; đã chạy `--headless --import` sinh lại `text.vi.translation`.
- Ba câu hỏi đã chốt trước khi code: (1) `truoc` = bàn đầu hiệp + lệnh trong hiệp; (2) F2 vẫn chép được khi không có trận; (3) chưa làm khung dự phòng cho clipboard trên web.
- **Khác story một chỗ:** khối JSON có thêm `sau` (bàn hiện tại) để kịch bản hợp lệ ngay và chạy được bằng `tools/test.sh`; nếu là lỗi thì sửa `sau` thành điều đúng trước khi sửa code (quy trình M3) — báo cáo có ghi câu này.

**Hướng dẫn tác giả tự test (đúng những bước đã chạy):**

1. Gõ `tools/test.sh` → `612/612 test đạt`, `81 đã duyệt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`.
3. Bấm **F2**: giữa bàn, sát đáy, hiện bảng "Đã sao chép báo lỗi" khoảng 3 giây rồi tự mất.
4. Mở trình soạn thảo, **Ctrl+V**: thấy tiêu đề (phiên bản, trận, hiệp, giờ), khối JSON của kịch bản, bàn hiện tại, 200 dòng log, ghi chú cho AI. Báo cáo thật dài cỡ 2.900 ký tự.
5. Lưu cả báo cáo thành một tệp **.txt** (không phải .json). Chép **chỉ phần giữa hai dòng ` ```json ` và ` ``` `** (bắt đầu bằng `{`, kết thúc bằng `}` ở cột đầu) vào `game/tests/kich_ban/thu/bao_loi.json` rồi chạy `tools/test.sh`: kịch bản mới hiện **1 chưa duyệt (0 chưa đạt)** và cả bộ vẫn xanh. Lưu cả báo cáo vào .json là **sai**: bộ nạp đọc dòng đầu "Hào Khí Đông A…" và báo "JSON sai cú pháp".
6. Muốn thấy nó bắt lỗi: sửa `data/chi_so.json` cho Khoái `do_day` 1 → 2, chơi lại tới lúc đẩy quân, bấm F2, lặp bước 5 → `tools/test.sh` **trượt** vì kịch bản mới "chưa đạt" (bàn phát lại khác `sau` đã ghi). Trả `chi_so.json` về như cũ sau khi thử.
7. Bấm F2 ở màn hình **lỗi** (làm hỏng `data/tran/tran_01.json` rồi mở game): vẫn chép được, phần bàn ghi "(không có trận)".
8. `tools/chay.sh` **không** có `--dev`: bấm F2 **không có gì xảy ra**.
9. Bản web: chưa thử trong phiên này; nếu trình duyệt chặn clipboard thì chỉ mất phần sao chép, game không hỏng.

### File List

- `game/src/debug/bug_report.gd` (mới) + `.uid`
- `game/src/ui/notice.gd` (mới) + `.uid`
- `game/src/battle/battle_controller.gd` (nhật ký lệnh theo hiệp, mốc bàn đầu hiệp)
- `game/src/data/board_text.gd` (`unit_symbol`, `terrain_symbol`, `direction_code`)
- `game/src/debug/dev_tools.gd` (`f2_pressed`)
- `game/src/app/main.gd` (nối F2, `clipboard_writer`, `notice()`)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/test_bug_report.gd` (mới) + `.uid`
- `game/tests/test_notice.gd` (mới) + `.uid`
- `game/tests/test_battle_controller.gd` (+2 test nhật ký hiệp)
- `game/tests/test_main.gd` (+3 test F2)
- `game/tests/test_dev_tools.gd` (F2 phát signal)
- `game/tests/scenario_runner.gd` (ký hiệu gọi lại `BoardText`)

### Change Log

- 2026-10-22: F2 sao chép báo lỗi (Story 2.13) — `BugReport`, `Notice`, nhật ký lệnh theo hiệp, 21 test; test 591 → 612.
