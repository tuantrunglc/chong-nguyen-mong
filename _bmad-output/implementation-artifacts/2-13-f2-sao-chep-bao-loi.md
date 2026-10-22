---
baseline_commit: 6030532
---

# Story 2.13: F2 sao chép báo lỗi

Status: ready-for-dev

## Story

Là tester,
tôi muốn báo lỗi bằng một phím,
để dán thẳng cho AI mà không phải tả lại.

## Acceptance Criteria

1. **Cho** game đang chạy, đã bật dev, **khi** bấm F2 **thì** clipboard có: bàn hiện tại (dạng `truoc` của kịch bản), các lệnh trong hiệp, 200 dòng log, phiên bản build.
2. **Và** màn hình báo "Đã sao chép báo lỗi".
3. **Khi** dán nội dung đó cho AI **thì** AI chuyển được thành một kịch bản tái hiện lỗi (thử trên một lỗi cố tình tạo ra).

## Tasks / Subtasks

- [ ] **Task 1: `BoardText` ghi được bàn cờ** (AC: 1)
  - [ ] 1.1 Thêm `BoardText.unit_symbol(type: int) -> String` và `BoardText.terrain_symbol(kind: int) -> String` (chiều ngược của `UNIT_SYMBOLS`/`TERRAIN_SYMBOLS`); ký hiệu lạ trả `"?"`.
  - [ ] 1.2 `game/tests/scenario_runner.gd`: `unit_symbol`/`terrain_symbol` gọi lại `BoardText`, bỏ bản sao (giữ chữ ký hàm để test 1.3 cũ không đổi).
  - [ ] 1.3 Test trong `test_scenario_loader.gd` (đã có `assert_eq(ScenarioRunner.unit_symbol(...))`): thêm ca mọi ký hiệu của `BoardText.UNIT_SYMBOLS`/`TERRAIN_SYMBOLS` đi và về đúng, và ca ký hiệu lạ.

- [ ] **Task 2: Nhật ký lệnh + bàn đầu hiệp trong `BattleController`** (AC: 1, 3)
  - [ ] 2.1 `_round_start: BattleState` và `_round_commands: Array[Dictionary]`; mỗi mục `{"lenh": "...", "tuong": "1", "o": "3,3", "tu_choi": "..."}` — chỉ có khóa dùng được, đúng định dạng `hanh_dong` của kịch bản.
  - [ ] 2.2 `submit()` ghi **mọi** lệnh: chạy được lẫn bị từ chối (kèm mã `tu_choi`), vì lệnh bị từ chối thường chính là lỗi đang báo. `undo()` ghi `{"lenh": "huy"}`.
  - [ ] 2.3 Mốc "đầu hiệp": sau `BEGIN_BATTLE`/`END_TURN` chạy được, `_round_start = _state.clone()` và `_round_commands.clear()` — **trừ** khi báo cáo đang ở đúng cửa sổ "vừa kết thúc lượt": xem 2.4.
  - [ ] 2.4 Giữ được pha địch: nếu F2 rơi vào lúc vừa `ket_thuc_luot` mà người chơi chưa ra lệnh nào ở hiệp mới, báo cáo phải dùng `_round_start` **cũ** + toàn bộ lệnh (gồm `ket_thuc_luot`), để phát lại ra đúng pha địch vừa xảy ra. Cách gọn: chỉ chốt mốc mới ở lệnh **đầu tiên sau** `BEGIN_BATTLE`/`END_TURN` (hoặc ở `END_TURN`, nhưng đẩy mốc cũ vào `_prev_round` và dùng `_prev_round` khi `_round_commands` rỗng). Chọn cách nào cũng phải có test cho cả hai cửa sổ.
  - [ ] 2.5 Accessor chỉ đọc: `round_start_snapshot() -> BattleState` (clone), `round_commands() -> Array[Dictionary]` (chép sâu).
  - [ ] 2.6 Test `test_battle_controller.gd`: (a) đi 1 nước rồi xem trước — `_round_start` không đổi, `round_commands()` có đúng lệnh đó; (b) từ chối lệnh → vẫn ghi kèm `tu_choi`, state không đổi; (c) `undo` ghi `huy`; (d) sau `ket_thuc_luot`, báo cáo vẫn phát lại được pha địch (so bàn sau khi phát lại với `snapshot()`).

- [ ] **Task 3: `BugReport` dựng nội dung** (AC: 1, 3)
  - [ ] 3.1 `game/src/debug/bug_report.gd` — `class_name BugReport extends RefCounted`, `static func build(state: BattleState, round_start: BattleState, commands: Array[Dictionary], log_lines: PackedStringArray, meta: Dictionary) -> String`. Không đọc autoload, không đọc `BattleController` — mọi thứ truyền vào, để test được.
  - [ ] 3.2 `meta`: `phien_ban` (`"v0.1.0 · 6030532"`), `tran` (id trận), `hiep`, `luc` (giờ máy), `lan_mo` (SaveProbe), `dang_choi` (bool).
  - [ ] 3.3 Dựng `truoc` từ `round_start`: `dia_hinh` (`BoardText.terrain_symbol`), `quan`, `mau` (chỉ quân thiếu máu, `{"cot,hang": máu}`), `thu_tu_dich` (ô quân Nguyên theo **id tăng dần**), `bao_don` (từ `telegraphs`, xếp theo `order`: CELL → `o` = ô chủ + `offset`; DIRECTION → `huong`). Đòn của chủ đã gục thì **bỏ** và ghi chú trong báo cáo (bộ nạp không nhận `quan` là ô không có quân Nguyên).
  - [ ] 3.4 Dựng `hanh_dong` từ `commands` (đã đúng định dạng ở 2.1).
  - [ ] 3.5 Khối JSON kịch bản: `{"phien_ban_dinh_dang": 1, "mo_ta": "Báo lỗi F2 …", "da_duyet": false, "truoc": {...}, "hanh_dong": [...]}`, in bằng `JSON.stringify(data, "  ")` để AI đọc được.
  - [ ] 3.6 Phần "bàn hiện tại" (không phải kịch bản, chỉ để đối chiếu): `dia_hinh`, `quan`, `mau`, `hiep`, và với từng tướng `đã đi`/`chưa đi`, `đã đánh`/`chưa đánh`.
  - [ ] 3.7 Đầu báo cáo: phiên bản build, trận, hiệp, giờ, lần mở; cuối báo cáo: 200 dòng log (cũ → mới) và một câu chỉ dẫn cho AI ("khối JSON ở trên là kịch bản tái hiện; chạy `tools/test.sh` sau khi thêm vào `game/tests/kich_ban/<nhóm>/`").
  - [ ] 3.8 Test `game/tests/test_bug_report.gd`: đủ các mục; bàn `dia_hinh`/`quan` khớp state (đi từng ô); `mau` chỉ có quân thiếu máu; `thu_tu_dich` đúng thứ tự id; `bao_don` đúng cho cả CELL và DIRECTION; log cắt còn 200 dòng cũ nhất ở đầu; báo cáo không chứa ký tự điều khiển lạ.

- [ ] **Task 4: Phím F2 + clipboard** (AC: 1, 2)
  - [ ] 4.1 `game/src/debug/dev_tools.gd`: thêm `signal f2_pressed`; bấm F2 phát signal; xoá câu `"f2: chưa có sao chép báo lỗi (story 2.13)"` khỏi `MESSAGES`.
  - [ ] 4.2 `game/src/app/main.gd`: nối `dev_tools.f2_pressed` trong nhánh bật dev (cùng chỗ với F1/F3/F5). `func _on_f2()`: lấy `_controller.round_start_snapshot()`, `round_commands()`, `Log.get_lines()`, dựng meta, gọi `BugReport.build`, rồi `clipboard_writer.call(text)`, hiện `Notice`.
  - [ ] 4.3 Seam test: `var clipboard_writer: Callable` trên `main.gd`, mặc định `DisplayServer.clipboard_set`. Test thay bằng hàm bắt chuỗi — không đọc clipboard thật (chạy headless không có clipboard).
  - [ ] 4.4 Không có trận (`_controller == null`: màn hình lỗi/menu): vẫn chép log + phiên bản, phần bàn ghi `(không có trận)` (Câu hỏi 2).
  - [ ] 4.5 Test `test_main.gd`: bật dev → bấm F2 → `clipboard_writer` nhận chuỗi có `"phien_ban_dinh_dang"` và tên trận, `Notice` hiện đúng câu; **không** bật dev → F2 không làm gì (không gọi writer, không hiện notice); màn hình lỗi → vẫn chép được (không có khối `truoc`).

- [ ] **Task 5: Thông báo ngắn `Notice`** (AC: 2)
  - [ ] 5.1 `game/src/ui/notice.gd` — `class_name Notice extends Control`: `show_text(text: String)`, tự ẩn sau `SHOW_SECONDS` (2,5 s) bằng `Tween` (theo luật hoạt ảnh của dự án); `text()`, `is_shown()` cho test; `mouse_filter = IGNORE`; đặt giữa bàn, phía trên đáy, không che HUD.
  - [ ] 5.2 Chữ qua `tr()`: khóa mới `dev.copied` = "Đã sao chép báo lỗi", `dev.copied_no_battle` = "Đã sao chép báo lỗi (không có trận)" — thêm vào `game/i18n/text.csv`, chạy `--headless --import` để sinh lại `text.vi.translation`.
  - [ ] 5.3 Test `game/tests/test_notice.gd`: `show_text` → `is_shown()` và đúng chữ; `await wait_seconds(SHOW_SECONDS + 0.5)` → đã ẩn; gọi liên tiếp hai lần không chồng chữ (chuỗi cuối thắng, một nhãn).

- [ ] **Task 6: Phát lại đúng — test then chốt** (AC: 1, 3)
  - [ ] 6.1 Test: dựng `BattleController` bằng trận `thu_lao`, chạy vài lệnh (đi, đánh, hủy, từ chối), dựng báo cáo, **tách khối JSON** ra, cho `ScenarioLoader` + `ScenarioRunner` chạy, so bàn cuối với `controller.snapshot()`: cùng ô, cùng máu, cùng `has_moved`/`has_attacked` cho từng quân. Đây là bằng chứng cho AC 3 ở mức dữ liệu.
  - [ ] 6.2 Test riêng cho cửa sổ pha địch: đi 1 nước → `ket_thuc_luot` → (chưa ra lệnh gì) → báo cáo → phát lại phải ra đúng bàn sau pha địch (bàn, máu, đòn đã báo, thứ tự).
  - [ ] 6.3 Test: báo cáo có `bao_don` thì phát lại phải còn đòn; báo cáo bỏ đòn của chủ đã gục thì phát lại vẫn chạy (không cần đòn đó để ra cùng bàn).

- [ ] **Task 7: Kiểm bằng tay, tài liệu, commit** (AC: 1–3)
  - [ ] 7.1 `tools/test.sh` xanh; ghi số test vào Debug Log.
  - [ ] 7.2 `tools/chay.sh --dev --tran=thu_lao`: đi 1 nước, bấm F2, dán ra file; xác nhận có đủ 4 mục và bàn đầu hiệp + lệnh.
  - [ ] 7.3 Lỗi cố tình: sửa tạm `data/chi_so.json` (ví dụ đẩy của Khoái từ 1 lên 2), chơi tới lúc đòn đẩy đi 2 ô, bấm F2, dán cho AI; AI trả về kịch bản; chạy kịch bản đó thấy tái hiện đúng lỗi. Ghi lại nguyên văn vào Debug Log (AC 3).
  - [ ] 7.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, đúng những bước đã chạy.
  - [ ] 7.5 Commit tiếng Việt kết `(Story 2.13)`, kèm `text.vi.translation` và mọi `.uid` mới.

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

### Câu hỏi cho tác giả (chốt trước khi code xong)

1. **`truoc` là bàn nào?** Định dạng kịch bản không có `hiep`/`da_di`/`da_danh` cho `truoc`, nên không tả được bàn giữa hiệp. Đề xuất: `truoc` = **bàn đầu hiệp** + `hanh_dong` = mọi lệnh trong hiệp (phát lại ra đúng bàn hiện tại), kèm mục "bàn hiện tại" để đối chiếu. Cách khác: mở rộng định dạng `truoc` cho 3 khóa đó (sửa bộ nạp + runner, nhiều việc hơn, và `hanh_dong` khi đó chỉ còn để tham khảo vì lệnh sẽ bị từ chối khi phát lại).
2. **F2 khi không có trận** (màn hình lỗi nạp dữ liệu, menu): vẫn chép log + phiên bản (không có phần bàn) chứ? Đề xuất: có — lỗi nạp dữ liệu là lúc cần báo cáo nhất.
3. **Clipboard trên web**: nếu trình duyệt chặn, có cần đường dự phòng (in báo cáo ra Console F12, hay hiện khung để tự bôi đen) không? Đề xuất: story này chỉ ghi thêm một dòng log "đã sao chép N ký tự"; nếu tác giả thấy cần khung thì tách story sau.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.13 (dòng 865–884), và dòng 124 (danh sách công cụ dev), dòng 199 (phạm vi E2).
- `_bmad-output/planning-artifacts/game-architecture.md`: dòng 439 (log 200 dòng), dòng 517 (bảng phím F2), dòng 522 (hiện phiên bản build), dòng 570 (`board_text.gd` đọc/ghi), dòng 590 (`notice.gd`), dòng 600 (`bug_report.gd`), dòng 797 (quy trình: báo lỗi F2 → kịch bản trước, sửa sau).
- `_bmad-output/project-context.md` (Godot 4, không Thread, chữ qua `tr()`, test một lệnh).
- `game/src/debug/dev_tools.gd`, `game/src/debug/log.gd`, `game/src/app/main.gd`, `game/src/data/board_text.gd`, `game/src/data/scenario_loader.gd`, `game/src/core/telegraph.gd`, `game/src/core/battle_state.gd`, `game/src/core/rules_enemy_phase.gd`, `game/tests/scenario_runner.gd`, `game/src/battle/battle_controller.gd`.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

### Change Log
