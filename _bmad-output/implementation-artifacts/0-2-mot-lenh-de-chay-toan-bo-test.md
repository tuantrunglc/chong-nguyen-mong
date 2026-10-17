---
baseline_commit: 38ce3615abd4976b57869240811dcabfc5e8cd2f
---

# Story 0.2: Một lệnh để chạy toàn bộ test

Status: ready-for-dev

## Story

Là tác giả,
tôi muốn gõ một lệnh và biết ngay game có đang hỏng không,
để không bao giờ phải đọc code.

## Acceptance Criteria

1. **Cho** project từ Story 0.1, **khi** gõ `tools/test.sh` từ gốc repo, **thì** terminal in tóm tắt tiếng Việt (ví dụ "✅ 3/3 test đạt") **và** lệnh thoát với mã 0.
2. **Khi** AI cố tình đặt một test sai, **thì** dòng tóm tắt báo "❌ trượt", ghi tên test (tên file và tên hàm test), mã thoát khác 0.
3. **Khi** thêm một file vào `game/src/core/` có dùng `Node` hoặc `get_tree()`, hoặc có phép gán `.hp =` / `.hp +=` / `.cell =` nằm ngoài `effects.gd`, **thì** `tools/check_boundaries.sh` chạy **đầu tiên** và báo trượt, kèm file, dòng và lý do bằng tiếng Việt.
4. **Khi** một file JSON có `"da_duyet": true` bị sửa so với commit gần nhất, **thì** test báo trượt và ghi tên file.
5. **Và** GUT v9.7.1 nằm trong `game/addons/gut/`, chạy được `--headless`, không cần cửa sổ.
6. **Và** `tools/test.sh` **không bao giờ báo xanh giả**: repo mới clone (chưa import), file test bị lỗi cú pháp, hoặc không có test nào được chạy thì đều báo **trượt**, mã thoát khác 0, kèm lý do tiếng Việt. (AC bổ sung, xem Dev Notes "Ba bẫy xanh giả đã kiểm chứng".)

## Tasks / Subtasks

- [ ] **Task 0: Giữ phần sửa của review Story 0.1** (tiền đề)
  - [ ] 0.1 Lúc tạo story này, phần sửa theo code review Story 0.1 **chưa commit** (`tools/chay.sh`, `tools/_godot.sh`, `game/src/battle/board_view.gd`, `game/src/app/main.gd`, file story 0.1, `sprint-status.yaml`, `deferred-work.md`). Chạy `git status`. Nếu các file đó vẫn đang sửa dở thì **không được** `git checkout`/`git stash` làm mất chúng; hỏi tác giả có commit trước không (lời commit gợi ý: `Sửa theo code review Story 0.1`).
- [ ] **Task 1: Cài GUT v9.7.1 vào `game/addons/gut/`** (AC: 5)
  - [ ] 1.1 Bản release v9.7.1 trên GitHub **không có file đính kèm**; tải mã nguồn theo tag: `https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.tar.gz` (đã kiểm ngày 2026-10-17: SHA-256 `6da99c4e9228d9bec3fb4bd1730a487770a989f0f511dac82a2897a964613385`). Kiểm SHA-256 trước khi giải nén.
  - [ ] 1.2 Chỉ chép thư mục `Gut-9.7.1/addons/gut/` vào `game/addons/gut/` (khoảng 3,2 MB, đã gồm sẵn các file `.uid`). **Chép nguyên bản**, không sửa file nào trong đó, không dùng submodule. Kiểm `game/addons/gut/plugin.cfg` có `version="9.7.1"`.
  - [ ] 1.3 **Commit GUT vào repo** (kiến trúc: "chép nguyên bản release"). Không thêm bước tải GUT vào `cai_dat.sh`.
  - [ ] 1.4 **Không** bật plugin GUT trong `project.godot` (`[editor_plugins]`). Chạy dòng lệnh không cần plugin; tác giả không mở editor.
  - [ ] 1.5 Giữ `gdscript/warnings/exclude_addons=true` (đã có từ Story 0.1) để luật `untyped_declaration` = error không áp lên code của GUT. Đã kiểm: import và chạy GUT với cài đặt này không có `SCRIPT ERROR` nào.
- [ ] **Task 2: Test mẫu đầu tiên (`game/tests/test_build_info.gd`)** (AC: 1, 2)
  - [ ] 2.1 Tách logic đọc mã commit ra khỏi `main.gd` thành `game/src/app/build_info.gd`: `class_name BuildInfo`, `extends RefCounted`, hàm `static func read_commit(path: String) -> String`. Giữ **nguyên hành vi** hiện tại của `main.gd::_read_commit()` (xem Dev Notes "File sẽ sửa"). `main.gd` gọi `BuildInfo.read_commit(BUILD_INFO_PATH)` và xóa `_read_commit()`.
  - [ ] 2.2 Viết `game/tests/test_build_info.gd` (`extends GutTest`, gõ kiểu tĩnh đầy đủ, mọi hàm có `-> void`). Ít nhất các ca:
    - file không tồn tại → `"dev"`;
    - JSON hỏng (ví dụ `{commit:`) → `"dev"`;
    - JSON là mảng (`[1, 2]`) → `"dev"`;
    - `{"commit": 123}` → `"dev"`;
    - `{"commit": ""}` → `"dev"`;
    - `{"commit": "abc1234-sua"}` → `"abc1234-sua"`.
  - [ ] 2.3 File thử ghi vào `user://test_build_info/` trong `before_each`, xóa trong `after_each` (`DirAccess.remove_absolute`). Không ghi file thử vào `res://`.
  - [ ] 2.4 Tên test viết tiếng Anh `snake_case` theo quy ước code (ví dụ `test_missing_file_returns_dev`). Thông điệp `assert_*` có thể viết tiếng Việt không dấu.
  - [ ] 2.5 Việc này đóng 1 trong 4 mục defer từ review Story 0.1 (`deferred-work.md`). Đánh dấu mục đó đã xử lý (thêm "→ xong ở Story 0.2"); **không** xóa các mục khác.
- [ ] **Task 3: `tools/check_boundaries.sh`** (AC: 3)
  - [ ] 3.1 Script bash, `#!/usr/bin/env bash` + `set -euo pipefail`, `source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"` để lấy `REPO_ROOT` (đặt `GODOT_BO_QUA_KIEM_TRA=1` trước khi source, vì script này không cần Godot). Nhận tham số tùy chọn là thư mục `src` cần quét (mặc định `"$REPO_ROOT/game/src"`), để Task 3.5 thử được.
  - [ ] 3.2 Quét **mọi `*.gd` trong `src/core/`** (đệ quy), bỏ qua phần chú thích sau `#` (cách đơn giản: cắt từ `#` đầu tiên của dòng; chấp nhận sai sót hiếm khi `#` nằm trong chuỗi). Báo vi phạm khi gặp:
    | Mẫu | Lý do in ra (tiếng Việt) |
    |---|---|
    | dòng `extends X` với X khác `RefCounted` | `lõi luật chỉ được extends RefCounted` |
    | `\bNode\w*\b` (Node, Node2D, NodePath…) | `lõi luật không được dùng Node` |
    | `get_tree\(`, `get_node\(`, `\$[A-Za-z_"%]` | `lõi luật không được truy cập cây scene` |
    | `\bInput\b` | `lõi luật không được đọc Input` |
    | `\bFileAccess\b`, `\bDirAccess\b` | `lõi luật không được đọc/ghi file` |
    | `\bTime\.` | `lõi luật không được dùng thời gian thực` |
    | `\brandi`, `\brandf`, `\brandomize\(`, `RandomNumberGenerator` | `lõi luật không được dùng số ngẫu nhiên` |
    | `\bprint(err|raw|t|_rich)?\(` | `lõi luật không được dùng print` |
  - [ ] 3.3 Quét **mọi `*.gd` trong `src/data/`**: chỉ luật `Node` (`\bNode\w*\b`, `get_tree\(`, `\$[A-Za-z_"%]`) với lý do `src/data không được dùng Node`. `FileAccess` được phép ở đây.
  - [ ] 3.4 Quét **mọi `*.gd` trong toàn bộ `src/`** trừ `src/core/effects.gd`: phép gán `\.(hp|cell)\s*(=|\+=|-=)` mà **không** phải so sánh `==` (ví dụ dùng regex `\.(hp|cell)[[:space:]]*(\+=|-=|=[^=])`). Lý do: `chỉ Effects được sửa máu và vị trí (.hp/.cell)`. Không bắt `unit.hp == 0`, `var hp = …`, `max_hp =`.
  - [ ] 3.5 Định dạng mỗi vi phạm một dòng: `❌ src/core/foo.gd:12: lõi luật không được dùng Node`. Đường dẫn tính từ `game/`. Có vi phạm thì in tổng số và `exit 1`; không có thì in `Ranh giới: đạt` và `exit 0`. Thư mục `src/core/`, `src/data/` chưa tồn tại thì coi như không có vi phạm (hiện **chưa có** hai thư mục này; không tạo chúng ở story này).
  - [ ] 3.6 Dùng `grep -nE` (có trên macOS và Linux). **Không** dùng `grep -P` (macOS không có). Đã kiểm trên grep của macOS ngày 2026-10-17: `\bNode\w*\b` bắt `Node`, `Node2D`, không bắt `get_node_x`; `\.(hp|cell)[[:space:]]*(\+=|-=|=[^=])` bắt `unit.hp = 0`, `u.cell=x`, không bắt `unit.hp == 0`.
  - [ ] 3.7 **Tự kiểm công cụ:** tạo thư mục mẫu `tools/mau_ranh_gioi/vi_pham/` và `tools/mau_ranh_gioi/hop_le/`, mỗi cái có cấu trúc `core/…`, `data/…` (đóng vai `src/`). `vi_pham/` chứa ít nhất: một file `core/` dùng `Node`, một dùng `get_tree()`, một gán `.hp +=`, một gán `.cell =` trong `battle/` (ngoài `effects.gd`). `hop_le/` chứa: `core/effects.gd` có `.hp -=` và `.cell =`, một file có `if unit.hp == 0`, một chú thích `# Node` (không được bắt). Các file mẫu nằm **ngoài `game/`** nên Godot không import. Task 4 dùng chúng.
- [ ] **Task 4: `tools/test.sh`, một lệnh chạy hết** (AC: 1, 2, 3, 4, 5, 6)
  - [ ] 4.1 `#!/usr/bin/env bash`, `set -euo pipefail`, `source _godot.sh` (bắt buộc có Godot; chưa cài thì `_godot.sh` đã tự báo và thoát). `chmod +x`. Chạy được từ bất kỳ thư mục nào.
  - [ ] 4.2 Chạy **đủ 4 bước theo thứ tự**, bước sau **vẫn chạy** dù bước trước trượt (để tác giả thấy hết lỗi một lần), rồi in tóm tắt cuối và thoát mã 1 nếu có bất kỳ bước nào trượt:
    1. **Kiểm ranh giới:** tự kiểm công cụ trước (chạy `check_boundaries.sh` trên `tools/mau_ranh_gioi/vi_pham` phải thoát ≠ 0, trên `tools/mau_ranh_gioi/hop_le` phải thoát 0; sai thì báo `❌ công cụ kiểm ranh giới bị hỏng`), rồi chạy trên `game/src` thật.
    2. **Kiểm kịch bản đã duyệt** (Task 5).
    3. **Import project:** `"$GODOT" --headless --path "$REPO_ROOT/game" --import`. Thất bại thì báo trượt `không quét được project` và bỏ qua bước 4.
    4. **Chạy GUT:** `"$GODOT" --headless --path "$REPO_ROOT/game" -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit -gjunit_xml_file=<đường dẫn tuyệt đối>`. Ghi toàn bộ output vào `build/test/gut.log` (tạo `build/test/`; `build/` đã có trong `.gitignore`). JUnit XML ghi vào `build/test/ket_qua.xml`; xóa file cũ trước khi chạy.
  - [ ] 4.3 **Đọc kết quả GUT từ JUnit XML** bằng `awk`/`sed`/`grep` (không thêm phụ thuộc như python hay xmllint). Thẻ gốc có dạng `<testsuites name="GutTests" failures="1" tests="2" >`; mỗi test có `<testcase name="test_x" ... status="pass|fail" classname="tests/test_y.gd" ...>`. Lấy tổng số test, số trượt, và danh sách `classname › name` của các test `status="fail"`, kèm dòng đầu của thông điệp trong `<failure ...><![CDATA[...]]>`.
  - [ ] 4.4 **Chống xanh giả (AC 6)**, mỗi trường hợp là một lý do trượt riêng:
    - không có file `ket_qua.xml` sau khi chạy → `GUT không chạy xong (xem build/test/gut.log)`;
    - `gut.log` có dòng `SCRIPT ERROR` hoặc `Parse Error` → `có file lỗi cú pháp, GUT đã bỏ qua nó` + in các dòng đó (đã kiểm: GUT **bỏ qua** file test lỗi cú pháp và vẫn thoát 0);
    - số file `game/tests/**/test_*.gd` khác số `<testsuite` trong XML → `có file test không được chạy`;
    - tổng số test = 0 → `không có test nào được chạy`;
    - mã thoát của Godot ≠ 0 mà XML báo 0 trượt → trượt, lý do `GUT thoát mã <n>`.
  - [ ] 4.5 **Tóm tắt tiếng Việt** (mẫu, giữ đúng ý, có thể chỉnh chữ):
    ```
    [1/4] Kiểm ranh giới ........ đạt
    [2/4] Kịch bản đã duyệt ..... đạt (0 file)
    [3/4] Quét project .......... đạt
    [4/4] Test GUT .............. 7/7 đạt

    ✅ 7/7 test đạt
    ```
    Khi trượt:
    ```
    [4/4] Test GUT .............. 1/7 trượt
      ❌ tests/test_build_info.gd › test_missing_file_returns_dev
         [x] expected to equal [dev]
    [1/4] ...

    ❌ trượt: 1 test trượt, 1 lỗi ranh giới
    ```
    Dòng cuối luôn bắt đầu bằng `✅` hoặc `❌ trượt`. Không in toàn bộ log GUT ra terminal khi đạt; khi trượt chỉ in phần cần thiết và chỉ tới `build/test/gut.log`.
  - [ ] 4.6 Mã thoát: `0` khi mọi bước đạt, `1` khi có bất kỳ bước nào trượt.
- [ ] **Task 5: Khóa `da_duyet`** (AC: 4)
  - [ ] 5.1 Trong `tools/test.sh` (hoặc hàm riêng trong cùng file): lấy danh sách file JSON **đang được git theo dõi ở HEAD** trong `game/` (`git -C "$REPO_ROOT" ls-tree -r --name-only HEAD -- game | grep '\.json$'`). Với mỗi file, đọc nội dung **ở HEAD** (`git show HEAD:<file>`); nếu có `"da_duyet"[[:space:]]*:[[:space:]]*true` thì file đó bị khóa.
  - [ ] 5.2 File bị khóa mà khác HEAD (đã sửa, đã stage, hoặc đã xóa) → trượt, in `❌ <file>: kịch bản đã duyệt bị sửa so với commit gần nhất`. Cách kiểm: `git -C "$REPO_ROOT" diff --quiet HEAD -- "<file>"` (bắt cả sửa chưa stage, đã stage và xóa).
  - [ ] 5.3 Không có git hoặc repo chưa có commit → trượt với lý do `không kiểm được khóa da_duyet (không có git)` (tác giả đã chốt, xem Quyết định của tác giả).
  - [ ] 5.4 In số file đang bị khóa (`đạt (N file)`). Hiện repo **chưa có** file JSON nào có `da_duyet`, nên N = 0 là đúng.
  - [ ] 5.5 Kiểm bằng tay (ghi vào Debug Log): tạo tạm một file `game/tests/kich_ban/thu/khoa_thu.json` có `"da_duyet": true`, commit tạm **trên một nhánh thử** (không phải `main`), sửa file → `tools/test.sh` trượt và ghi tên file; hoàn tác → đạt. Xóa nhánh thử sau khi kiểm. **Không** để lại file thử hay commit thử trên `main`.
- [ ] **Task 6: Cập nhật tài liệu dự án**
  - [ ] 6.1 `CLAUDE.md`: dòng `tools/test.sh` đổi từ "(có từ Story 0.2)" thành mô tả ngắn: "chạy toàn bộ test, in tóm tắt tiếng Việt; mã thoát khác 0 là trượt".
  - [ ] 6.2 Không sửa `project-context.md` hay `game-architecture.md`. Nếu thấy cần bổ sung luật (ví dụ "luôn `--import` trước khi chạy GUT"), ghi vào Completion Notes làm đề xuất để tác giả duyệt.
- [ ] **Task 7: Tự kiểm tra trước khi báo xong** (AC: 1–6)
  - [ ] 7.1 `tools/test.sh` trên repo hiện tại → `✅ N/N test đạt`, mã 0 (`echo $?`).
  - [ ] 7.2 Thêm tạm một test sai (`assert_eq(1, 2)`) → dòng cuối `❌ trượt`, có tên file và tên test, mã ≠ 0. Xóa test tạm.
  - [ ] 7.3 Thêm tạm `game/src/core/thu.gd` có `extends Node` và một dòng `unit.hp += 1` → bước 1 báo trượt với file, dòng, lý do tiếng Việt; bước 1 chạy **trước** các bước khác. Xóa file tạm (và file `.uid` nếu Godot đã sinh).
  - [ ] 7.4 Task 5.5 (khóa `da_duyet`).
  - [ ] 7.5 Ba bẫy xanh giả: (a) clone repo sang thư mục tạm, symlink `.tools/godot-4.7.2`, chạy `tools/test.sh` → phải đạt (vì có bước import); (b) thêm tạm file test có `var x = 1` → trượt, lý do lỗi cú pháp; (c) tạm đổi tên `game/tests` → trượt, lý do không có test. Hoàn tác hết.
  - [ ] 7.6 `tools/chay.sh` vẫn mở game bình thường (bàn cờ + nhãn phiên bản) sau khi tách `BuildInfo`.
  - [ ] 7.7 `git status` sạch ngoài các file của story; các file `.uid` do Godot sinh cho `build_info.gd` và `test_build_info.gd` được commit. Commit bằng lời tiếng Việt, ví dụ `Thêm tools/test.sh, GUT 9.7.1 và kiểm ranh giới (Story 0.2)`.

## Dev Notes

### Bối cảnh

- Story 0.1 đã xong: `game/` có `project.godot`, `scenes/main.tscn`, `src/app/main.gd`, `src/battle/board_view.gd`; `tools/` có `_godot.sh`, `cai_dat.sh`, `chay.sh`. Godot 4.7.2 nằm trong `.tools/godot-4.7.2/` (chế độ tự chứa).
- Repo **chưa có** `game/src/core/`, `game/src/data/`, `game/tests/`, `game/addons/`. Story này tạo `game/addons/gut/` và `game/tests/`, **không** tạo `src/core/` hay `src/data/`.
- Tác giả không đọc code, không mở editor, không tự dùng git. `tools/test.sh` là cách duy nhất tác giả biết game còn chạy đúng hay không, nên **một lần báo xanh giả là hỏng niềm tin của cả quy trình M3**.
- Ngân sách E0 khoảng 12 giờ cho 6 story. Story này khoảng 2–3 giờ.

### Ba bẫy xanh giả đã kiểm chứng (2026-10-17, GUT 9.7.1 + Godot 4.7.2, trên bản clone tạm)

| Tình huống | GUT làm gì | Mã thoát | `test.sh` phải |
|---|---|---|---|
| Chưa `--import` (repo mới clone, `game/.godot/` bị gitignore) | In `ERROR: Some GUT class_names have not been imported` rồi **thoát luôn**, không chạy test | **0** | Luôn import trước (bước 3); không có XML thì trượt |
| File test có lỗi cú pháp (ví dụ `var x = 1` vi phạm `untyped_declaration`) | In `SCRIPT ERROR: Parse Error`, **bỏ qua file đó**, chạy các file khác | **0** | Bắt `SCRIPT ERROR`/`Parse Error` trong log; so số file test với số `<testsuite` |
| Không có file test nào | XML `tests="0"` | **0** | Tổng = 0 thì trượt |
| Có test trượt (đúng như mong đợi) | XML `failures="1"`, `status="fail"` | **1** | Báo trượt, liệt kê test |

Cùng nguyên nhân với lỗi review Story 0.1 (`BoardView` không được biết trên repo mới clone): `game/.godot/` không có trong git, nên mọi lệnh chạy Godot phải `--import` trước. `chay.sh` đã làm việc này từ lần sửa sau review.

### File sẽ sửa (đọc trước khi sửa)

**`game/src/app/main.gd`** (hiện tại):
- `_ready()` tạo `BoardView`, tạo `Label` với text `"v%s · %s" % [_read_version(), _read_commit()]`, đặt nhãn ở góc dưới phải theo `BoardView.viewport_size`.
- `_read_commit()`: `FileAccess.file_exists(BUILD_INFO_PATH)` sai → `"dev"`; đọc chuỗi; `JSON.new().parse(text)` (**không** dùng `JSON.parse_string()` vì hàm này tự in `ERROR` khi JSON hỏng); `json.data` không phải `Dictionary` → `"dev"`; `info.get("commit", "")` không phải `String` hoặc rỗng → `"dev"`; còn lại trả chuỗi commit.
- **Thay đổi:** chuyển nguyên thân `_read_commit()` sang `BuildInfo.read_commit(path)`, thay hằng `BUILD_INFO_PATH` bằng tham số `path`. `main.gd` giữ hằng `BUILD_INFO_PATH` và gọi `BuildInfo.read_commit(BUILD_INFO_PATH)`.
- **Giữ nguyên:** nhãn, vị trí, `_read_version()`, mọi hành vi hiển thị. Nhãn trên repo đang sửa dở vẫn phải ra `v0.1.0 · <sha>-sua`.

**`CLAUDE.md`**: chỉ sửa dòng `tools/test.sh` (Task 6.1).

**`tools/_godot.sh`**: **không sửa**. Đã có `set -euo pipefail` (thêm sau review 0.1) và biến `GODOT_BO_QUA_KIEM_TRA`. Lưu ý: vì `_godot.sh` có `set -euo pipefail`, trong `test.sh` mọi lệnh có thể thoát ≠ 0 mà bạn muốn bắt (Godot, `check_boundaries.sh`, `git diff --quiet`, `grep` không khớp) phải bọc bằng `if ...; then` hoặc `|| ma=$?`, nếu không script sẽ dừng ngang và không in tóm tắt.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| `tools/xem_kich_ban.sh`, `tests/test_scenarios.gd`, `scenario_loader.gd`, thư mục `tests/kich_ban/<nhóm>/` thật | 1.3 |
| `test_loaders.gd`, `test_determinism.gd` | 1.1 / E2 |
| `src/core/`, `src/data/`, `effects.gd` thật | E1, E2 |
| Loại trừ `tests/*` và `addons/gut/*` khỏi bản export | 0.5 (preset export) |
| `Log`, bỏ `print()` | 0.3 |
| Test cho `BoardView.setup` | khi có kích thước bàn thứ hai (UI không có test tự động theo project-context) |
| Test shell cho `cai_dat.sh` / `chay.sh` | chưa lên lịch (vẫn để trong `deferred-work.md`) |

### Luật kiến trúc phải theo

- **Một lệnh duy nhất** `tools/test.sh`, chạy từ gốc repo: (1) `check_boundaries.sh`, (2) khóa `da_duyet`, (3) GUT `--headless`, (4) tóm tắt tiếng Việt. Mã thoát ≠ 0 là trượt. [Source: project-context.md#Test; game-architecture.md#Ranh giới kiến trúc mục 7]
  - Story thêm bước "quét project" giữa (2) và (3); đây là điều kiện để GUT chạy được, không phải đổi thứ tự.
- **Ranh giới `src/core/`:** chỉ `RefCounted`; cấm `Node`, `get_tree()`, `$`, `Input`, `FileAccess`, `Time`, `randi`/`randf`, `print`. **`src/data/`** không Node, được `FileAccess`. **Chỉ `Effects.damage`/`Effects.move` sửa máu và vị trí**; `check_boundaries.sh` bắt `=`, `+=`, `-=` trên `.hp`/`.cell` ngoài `effects.gd`. [Source: game-architecture.md#Ranh giới kiến trúc; #Luật nhất quán]
  - Kiến trúc còn nói "mọi chỗ sửa trực tiếp `units`". Story này **chưa** bắt mẫu đó (chưa có `BattleState`, dễ bắt nhầm). Ghi vào Completion Notes là việc cho E1.
- **Khóa `da_duyet`:** so với commit gần nhất; file đã duyệt bị đổi thì trượt, ghi tên file. [Source: game-architecture.md#M3 bước 6; #Mẫu git]
- **GUT v9.7.1** chép nguyên bản vào `game/addons/gut/`, không submodule, chạy `--headless`. [Source: game-architecture.md#Cây thư mục; quyết định #11]
- **Test GUT** đặt tên `test_<khu_vuc>.gd`, nằm trong `game/tests/`. [Source: game-architecture.md#Quy ước đặt tên]
- **Gõ kiểu tĩnh mọi nơi**, kể cả file test. `untyped_declaration` = error áp lên `game/tests/` (chỉ `addons/` được miễn). Một file test thiếu kiểu sẽ bị GUT bỏ qua âm thầm, nên bẫy ở Task 4.4 rất quan trọng.
- **Script trong `tools/`:** `#!/usr/bin/env bash`, `set -euo pipefail`, chạy từ thư mục bất kỳ, `chmod +x`, mọi thông báo tiếng Việt, chỉ dùng Godot qua `_godot.sh`. [Source: Story 0.1 Task 4.4, AC 8]

### Ghi chú kỹ thuật GUT 9.7.1 (đọc trực tiếp mã nguồn tag v9.7.1)

- Điểm vào dòng lệnh: `-s res://addons/gut/gut_cmdln.gd`. Cờ cần dùng: `-gdir=res://tests`, `-ginclude_subdirs`, `-gexit`, `-gjunit_xml_file=<path>`. Tiền tố mặc định `test_`, hậu tố `.gd`.
- `-gconfig` mặc định đọc `res://.gutconfig.json` nếu có. **Không** tạo file này; truyền hết bằng cờ trong `test.sh` để chỉ có một nơi cấu hình.
- Mã thoát (`gui/GutRunner.gd::_handle_quit`): có test trượt → `1`; còn lại `0`. Ở chế độ headless GUT tự thoát.
- Cờ không hợp lệ → in `Unknown arguments` và thoát `1`.
- Ghi chú lỗi: GUT mặc định **làm trượt test** nếu test gây `push_error` hoặc lỗi engine (`-gfailure_error_types`). `BuildInfo.read_commit` không được in lỗi với file hỏng (đã dùng `JSON.new().parse()`), nên test ca JSON hỏng sẽ đạt. Nếu một ca trượt vì lỗi engine được in ra thì đó là lỗi code, không phải lỗi test.
- Đường dẫn `-gjunit_xml_file` dùng **đường dẫn tuyệt đối của hệ điều hành** (đã kiểm, chạy được).
- Mẫu XML thật (đã chạy thử):
  ```xml
  <testsuites name="GutTests" failures="1" tests="2" >
    <testsuite name="tests/test_mau.gd" tests="2" failures="1" skipped="0" time="0.00045" >
        <testcase name="test_dat" assertions="1" status="pass" classname="tests/test_mau.gd" time="0.000303" >
        </testcase>
        <testcase name="test_truot" assertions="1" status="fail" classname="tests/test_mau.gd" time="0.000147" >
        <failure message="failed"><![CDATA[[1] expected to equal [2]:  co tinh sai
              at line 9]]></failure></testcase>
    </testsuite>
  </testsuites>
  ```
- `--import` lần đầu sinh file `.uid` cho mỗi `.gd` mới (ví dụ `tests/test_build_info.gd.uid`). Commit các file này, giống Story 0.1. Import **không** sửa `project.godot`.
- Import khoảng 2–3 giây; chạy GUT với vài test dưới 1 giây.

### Cấu trúc file sau story

```
chong-nguyen-mong/
├── CLAUDE.md                          # SỬA: dòng tools/test.sh
├── tools/
│   ├── test.sh                        # MỚI: một lệnh chạy hết
│   ├── check_boundaries.sh            # MỚI
│   └── mau_ranh_gioi/                 # MỚI: file mẫu để tự kiểm check_boundaries.sh
│       ├── vi_pham/{core,data,battle}/*.gd
│       └── hop_le/{core,battle}/*.gd
├── build/test/                        # (gitignore) gut.log, ket_qua.xml
└── game/
    ├── addons/gut/                    # MỚI: GUT 9.7.1 nguyên bản (đã có .uid)
    ├── src/app/
    │   ├── main.gd                    # SỬA: gọi BuildInfo.read_commit
    │   └── build_info.gd              # MỚI: class_name BuildInfo
    └── tests/
        └── test_build_info.gd         # MỚI
```

`tools/mau_ranh_gioi/` không có trong cây thư mục của kiến trúc. Lý do: `check_boundaries.sh` là thứ giữ ranh giới lõi luật cho cả dự án, mà tác giả không đọc code; nếu chính nó hỏng (regex sai trên macOS) thì ranh giới mất mà không ai biết. File mẫu nằm ngoài `game/` nên không bị Godot import hay export.

### Testing

- Story này **tạo ra** khung test. Bằng chứng xong: Task 7 đạt hết, các lần kiểm bằng tay ghi vào Debug Log (lệnh đã chạy, dòng cuối in ra, mã thoát).
- **Hướng dẫn tác giả tự test** (ghi vào Completion Notes):
  1. Gõ `tools/test.sh` → thấy 4 dòng `[1/4]…[4/4]` và dòng cuối `✅ N/N test đạt`.
  2. Gõ `echo $?` ngay sau đó → thấy `0`.
  3. Nhờ AI "đặt tạm một test sai rồi chạy test" → dòng cuối `❌ trượt` kèm tên test; `echo $?` ra `1`. Nhờ AI gỡ test sai.

### Previous Story Intelligence (Story 0.1)

- **`--import` trước mọi lần chạy Godot** trên repo có thể mới clone. Lỗi này lọt qua dev và chỉ bị code review bắt.
- `set -euo pipefail` có trong `_godot.sh` → ảnh hưởng mọi script `source` nó (xem "File sẽ sửa").
- Chế độ tự chứa: dữ liệu editor ở `.tools/godot-4.7.2/editor_data/`. Không ảnh hưởng tới test.
- Không có quyền `screencapture`; muốn chụp khung hình thì dùng `--write-movie <file>.png --quit-after N`. Story này không cần chụp.
- `JSON.parse_string()` tự in `ERROR` khi JSON hỏng; dùng `JSON.new().parse()`.
- Review 0.1 để lại 4 mục trong `_bmad-output/implementation-artifacts/deferred-work.md`; story này đóng mục `_read_commit`, các mục khác giữ nguyên.
- Lời commit tiếng Việt. Tác giả xác nhận bằng mắt trước khi đổi trạng thái.

### Git Intelligence

- 5 commit gần nhất: `4eed812 Story 0.1: project Godot trống chạy được trên máy`, `90aa4b4 Tạo sprint-status và story 0.1`, `e223623 Kiểm tra sẵn sàng triển khai và chốt 4 luật còn treo`, `182de06 Add game architecture, project context and epic/story breakdown`, `f5e2c6c Fix date in decision log`.
- Mẫu đã có: script `tools/` source `_godot.sh`; tên biến và thông báo trong shell viết tiếng Việt không dấu (`tai`, `kiem_tra`, `TAI_VE`); code GDScript tiếng Anh, chú thích tiếng Việt.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- Godot **4.7.2.stable**, GUT **v9.7.1**. Không tự nâng phiên bản.
- Gõ kiểu tĩnh mọi nơi (kể cả test); giá trị từ JSON là `Variant`, phải kiểm kiểu rồi ép tường minh.
- "Xong một việc" nghĩa là `tools/test.sh` xanh, sau đó commit. Từ story này trở đi, **không bao giờ báo "xong" khi chưa chạy `tools/test.sh`**.
- Cấm xóa hoặc sửa kịch bản `da_duyet: true` để test đạt.
- Mọi test chạy không cần màn hình. Không có test tự động cho UI và hoạt ảnh.
- Không dùng `Thread`. Không dùng `print()` trong code game (test GUT dùng `gut.p()` nếu cần in).
- Git: chỉ commit khi test xanh; lời commit tiếng Việt; không `push --force`, không viết lại lịch sử.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### Quyết định của tác giả (2026-10-17)

1. Máy không có git, hoặc repo chưa có commit: `tools/test.sh` **báo trượt** (Task 5.3).
2. Một bước trượt thì **vẫn chạy tiếp** các bước sau, rồi báo trượt ở dòng cuối (Task 4.2).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.2: Một lệnh để chạy toàn bộ test]
- [Source: _bmad-output/planning-artifacts/epics.md#Yêu cầu bổ sung (từ kiến trúc), mục Test]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Phần kiến trúc engine lo sẵn (Test)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Cây thư mục]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Ranh giới kiến trúc]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#M3. Kịch bản luật là spec]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Mẫu git; #Luật nhất quán]
- [Source: _bmad-output/project-context.md#Test; #Tổ chức code; #Luật riêng của Godot]
- [Source: _bmad-output/implementation-artifacts/0-1-project-godot-trong-chay-duoc-tren-may.md#Review Findings]
- [Source: _bmad-output/implementation-artifacts/deferred-work.md]
- [Source: https://github.com/bitwes/Gut/releases/tag/v9.7.1 (phát hành 2026-07-10; mã nguồn tag đọc ngày 2026-10-17: `addons/gut/cli/gut_cli.gd`, `gui/GutRunner.gd`, `version_conversion.gd`, `junit_xml_export.gd`)]

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
