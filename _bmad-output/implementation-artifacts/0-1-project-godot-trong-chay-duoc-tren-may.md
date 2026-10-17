---
baseline_commit: 90aa4b48dfa1846e3958117c1ddad51a9aca4c3f
---

# Story 0.1: Project Godot trống chạy được trên máy

Status: review

## Story

Là tác giả,
tôi muốn có một project Godot chạy được bằng một lệnh,
để thấy game của mình tồn tại mà không cần mở editor.

## Acceptance Criteria

1. **Cho** repo mới clone về (đã chạy `tools/cai_dat.sh`), **khi** gõ `tools/chay.sh` từ gốc repo, **thì** cửa sổ game 1280×720 mở ra và hiện bàn cờ 7×7 trống, vẽ bằng code.
2. **Và** góc màn hình hiện số phiên bản (ví dụ `v0.1.0`) và mã commit ngắn (ví dụ `e223623`). Nếu không lấy được mã commit thì hiện `v0.1.0 · dev`, không báo lỗi.
3. **Khi** kéo giãn cửa sổ, **thì** bàn cờ co giãn theo, giữ đúng tỉ lệ, không bị méo (stretch `canvas_items`, aspect `keep`).
4. **Và** project nằm trong `game/`, dùng Godot 4.7.2 với renderer Compatibility; cảnh báo `untyped_declaration` ở mức **error**; `build/` có trong `.gitignore`.
5. **Và** gốc repo có file `CLAUDE.md` trỏ tới `_bmad-output/project-context.md` và `_bmad-output/planning-artifacts/game-architecture.md`, để mọi phiên AI đọc hai file này trước khi làm việc.
6. **Và** `tools/chay.sh` chạy bản desktop trên máy, nhận thêm `--dev` và `--tran=N`. Ở story này chỉ cần **chuyển tiếp** hai tham số đó vào game như user args; phần đọc và xử lý làm ở Story 0.3. `tools/chay.sh` là mục mới so với tài liệu kiến trúc (đã có trong cây thư mục).
7. **Cho** máy chưa có Godot, **khi** gõ `tools/cai_dat.sh`, **thì** script tải đúng Godot `4.7.2.stable` và export template `4.7.2.stable`, kiểm tra checksum SHA-512, và đặt vào một thư mục cố định trong repo (`.tools/`, có trong `.gitignore`).
8. **Và** mọi script trong `tools/` chỉ dùng bản Godot này (qua một file dùng chung), không dùng bản Godot nào khác có trên máy hay trong `PATH`.
9. **Và** chạy lại `tools/cai_dat.sh` khi đã cài thì không tải lại, chỉ in "Đã cài Godot 4.7.2" và thoát mã 0.

## Tasks / Subtasks

- [x] **Task 1: `tools/cai_dat.sh` và `tools/_godot.sh`** (AC: 7, 8, 9)
  - [x] 1.1 `tools/_godot.sh`: file dùng chung, được `source` bởi mọi script khác. Định nghĩa `REPO_ROOT`, `GODOT_VERSION="4.7.2-stable"`, `GODOT_DIR="$REPO_ROOT/.tools/godot-4.7.2"`, biến `GODOT` trỏ tới file chạy. Nếu chưa cài thì in "Chưa có Godot 4.7.2. Chạy tools/cai_dat.sh trước." và `exit 1`.
  - [x] 1.2 Nhận diện hệ điều hành bằng `uname -s` và `uname -m`. **Bắt buộc hỗ trợ macOS** (máy tác giả: macOS, Apple Silicon arm64). Hỗ trợ thêm Linux x86_64 nếu không tốn công. Hệ khác thì báo lỗi tiếng Việt rõ ràng.
  - [x] 1.3 Tải từ GitHub release `https://github.com/godotengine/godot/releases/download/4.7.2-stable/`:
    - macOS: `Godot_v4.7.2-stable_macos.universal.zip` → file chạy `Godot.app/Contents/MacOS/Godot`
    - Linux x86_64: `Godot_v4.7.2-stable_linux.x86_64.zip` → `Godot_v4.7.2-stable_linux.x86_64`
    - Export template: `Godot_v4.7.2-stable_export_templates.tpz`
    - Checksum: `SHA512-SUMS.txt`
  - [x] 1.4 Kiểm tra SHA-512 của từng file tải về với dòng tương ứng trong `SHA512-SUMS.txt` (`shasum -a 512` trên macOS, `sha512sum` trên Linux). Sai thì xóa file, báo lỗi tiếng Việt, thoát mã khác 0.
  - [x] 1.5 **Chế độ tự chứa (self-contained):** tạo file rỗng `._sc_` (hoặc `_sc_`) cạnh file chạy Godot. Trên macOS đặt trong `Godot.app/Contents/MacOS/`. Khi có file này, Godot ghi dữ liệu editor vào `editor_data/` cạnh file chạy, không đụng vào `~/Library/Application Support/Godot`. **Phải kiểm chứng** bằng `"$GODOT" --headless --version` rồi xem thư mục `editor_data/` có được tạo không. Nếu chế độ tự chứa không chạy trên macOS 4.7.2 thì lùi về cài template vào thư mục người dùng chuẩn và ghi rõ trong Completion Notes.
  - [x] 1.6 Giải nén template `.tpz` (thực chất là zip, bên trong có thư mục `templates/`) vào `<editor_data>/export_templates/4.7.2.stable/`. Tên thư mục phải đúng `4.7.2.stable` (dấu chấm, không phải gạch ngang).
  - [x] 1.7 macOS: chạy `xattr -dr com.apple.quarantine` trên `Godot.app` để Gatekeeper không chặn.
  - [x] 1.8 Ghi file đánh dấu `.tools/godot-4.7.2/.installed`. Lần chạy sau thấy file này thì in "Đã cài Godot 4.7.2" và thoát mã 0, không tải lại (AC 9).
  - [x] 1.9 **Không** cài `butler` ở story này; Story 0.5 sẽ thêm vào `cai_dat.sh`. Để sẵn một chỗ chú thích `# butler: thêm ở Story 0.5`.
- [x] **Task 2: Project Godot trong `game/`** (AC: 1, 3, 4)
  - [x] 2.1 Tạo `game/project.godot` bằng tay (viết file văn bản, không mở editor). Các mục bắt buộc:
    - `config/name="Chống Nguyên Mông"`, `config/version="0.1.0"`, `run/main_scene="res://scenes/main.tscn"`, `config/features=PackedStringArray("4.7")`
    - `[display]` `window/size/viewport_width=1280`, `window/size/viewport_height=720`, `window/stretch/mode="canvas_items"`, `window/stretch/aspect="keep"`
    - `[rendering]` `renderer/rendering_method="gl_compatibility"` và `renderer/rendering_method.mobile="gl_compatibility"`
    - `[debug]` `gdscript/warnings/untyped_declaration=2` (2 = error). Giữ `gdscript/warnings/exclude_addons=true` (mặc định) để GUT ở Story 0.2 không bị lỗi gõ kiểu.
  - [x] 2.2 Chưa khai báo autoload nào. `AppState` làm ở story sau, khi cần.
  - [x] 2.3 `game/scenes/main.tscn`: khung tối thiểu, chỉ một node gốc `Node2D` hoặc `Control` tên `Main`, gắn script `res://src/app/main.gd`. Mọi node con tạo bằng code (luật "scene nhỏ và phẳng"). **Không** viết tay UID trong `.tscn`, hoặc nếu có thì để Godot tự sinh khi import và commit file `.uid` đi kèm.
  - [x] 2.4 Sau khi tạo xong, chạy `"$GODOT" --headless --path game --import` (hoặc `--editor --quit` nếu `--import` không có) để Godot sinh thư mục `.godot/` và các file `.uid`. Kiểm tra output **không có** dòng `ERROR` hay `SCRIPT ERROR`.
- [x] **Task 3: Vẽ bàn cờ trống và nhãn phiên bản** (AC: 1, 2, 3)
  - [x] 3.1 `game/src/battle/board_view.gd` (`class_name BoardView`, `extends Node2D`): vẽ lưới 7×7 trong `_draw()` bằng `draw_rect` / `draw_line`. Kích thước ô là một **hằng số trình bày** (ví dụ `const CELL_SIZE: int = 88`), không phải con số cân bằng, nên được để trong code. Bàn đặt giữa khung 1280×720. Màu nền ô là màu giấy cổ nhạt, viền màu nâu sẫm. Chưa có địa hình, chưa có quân.
  - [x] 3.2 Kích thước bàn (7×7) để thành tham số `setup(cols: int, rows: int)` với mặc định 7, vì kiến trúc chừa chỗ cho bàn khác kích thước ở giai đoạn 1. **Không** tạo `BattleState` hay bất cứ thứ gì trong `src/core/` ở story này.
  - [x] 3.3 `game/src/app/main.gd` (`extends Node2D` hoặc `Control`, khớp với node gốc): trong `_ready()` tạo `BoardView.new()` và `Label` hiển thị phiên bản, thêm làm node con.
  - [x] 3.4 Nhãn phiên bản ở góc dưới phải, chữ nhỏ. Nội dung: `"v%s · %s" % [version, commit]`. `version` đọc từ `ProjectSettings.get_setting("application/config/version")`. `commit` đọc từ `res://build_info.json`, khóa `commit`. Không có file hoặc đọc lỗi thì dùng `"dev"`.
  - [x] 3.5 Font: chưa có font tiếng Việt (Story 0.4). Nhãn phiên bản chỉ có chữ số và ký tự ASCII nên dùng font mặc định được. **Không** hiển thị chữ có dấu nào ở story này.
- [x] **Task 4: `tools/chay.sh` và mã commit** (AC: 2, 6, 8)
  - [x] 4.1 `tools/chay.sh`: `source tools/_godot.sh`, rồi ghi `game/build_info.json` dạng `{"commit": "<git rev-parse --short HEAD>"}`. Không có git thì ghi `"dev"`. Có thay đổi chưa commit thì thêm hậu tố `-sua` (ví dụ `e223623-sua`), để tester biết đang chạy bản chưa commit.
  - [x] 4.2 Chạy `"$GODOT" --path "$REPO_ROOT/game" -- "$@"`. Tham số sau `--` là user args, game đọc bằng `OS.get_cmdline_user_args()` ở Story 0.3. Ví dụ `tools/chay.sh --dev --tran=3`.
  - [x] 4.3 `game/build_info.json` thêm vào `.gitignore` (sinh lúc chạy và lúc build, không commit).
  - [x] 4.4 Mọi script trong `tools/` bắt đầu bằng `#!/usr/bin/env bash` và `set -euo pipefail`, chạy được từ bất kỳ thư mục nào (tự tìm `REPO_ROOT` từ vị trí script), có quyền thực thi (`chmod +x`). Thông báo cho tác giả viết **tiếng Việt**.
- [x] **Task 5: `.gitignore` và `CLAUDE.md`** (AC: 4, 5)
  - [x] 5.1 Thêm vào `.gitignore` (giữ các dòng có sẵn): `build/`, `.tools/`, `game/.godot/`, `game/build_info.json`, `*.tmp`.
  - [x] 5.2 `CLAUDE.md` ở gốc repo, viết tiếng Việt, ngắn:
    - Trước khi viết code, **bắt buộc đọc** `_bmad-output/project-context.md` và `_bmad-output/planning-artifacts/game-architecture.md`.
    - Tác giả không đọc code; nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.
    - Lệnh chính: `tools/cai_dat.sh`, `tools/chay.sh`, và sau Story 0.2 là `tools/test.sh`.
    - Theo dõi tiến độ ở `_bmad-output/implementation-artifacts/sprint-status.yaml`.
- [x] **Task 6: Tự kiểm tra trước khi báo xong**
  - [x] 6.1 Chạy `tools/cai_dat.sh` hai lần: lần một tải và kiểm checksum; lần hai in "Đã cài Godot 4.7.2", không tải lại.
  - [x] 6.2 Chạy `"$GODOT" --headless --path game --quit-after 30` (hoặc tương đương): không có `ERROR` / `SCRIPT ERROR` trong output.
  - [x] 6.3 Chạy `tools/chay.sh`. Nếu đã có MCP (Story 0.6 chưa làm, nên có lẽ chưa có), chụp màn hình; nếu chưa thì nhờ tác giả xác nhận bằng mắt theo AC 1–3.
  - [x] 6.4 Thử viết một biến không gõ kiểu trong `main.gd` (ví dụ `var x = 1`), chạy lại và xác nhận Godot báo **lỗi**, không chỉ cảnh báo. Rồi xóa dòng thử.
  - [x] 6.5 Story này chưa có `tools/test.sh` (Story 0.2), nên "xong" nghĩa là: 6.1–6.4 đạt và tác giả đã xác nhận bằng mắt. Sau đó commit bằng lời tiếng Việt.

## Dev Notes

### Bối cảnh

- Đây là **story đầu tiên** của dự án. Repo hiện chỉ có tài liệu: `_bmad/`, `_bmad-output/`, `.claude/`, `NEXT-STEPS.md`, `.gitignore` (gồm `.DS_Store`, `*.log`, `__pycache__/`, `.venv/`). **Chưa có** `game/`, `tools/` hay `CLAUDE.md`. Máy chưa cài Godot (`godot` không có trong `PATH`). Có sẵn Node.js, npm, python3 và git.
- Máy tác giả: **macOS, Apple Silicon (arm64)**. Bản Godot macOS là universal nên chạy được trên arm64.
- Tác giả **không đọc code** và **không mở Godot editor**. Mọi thứ phải chạy bằng lệnh trong `tools/`. Mọi thông báo của script viết tiếng Việt.
- E0 có ngân sách khoảng 12 giờ cho 6 story. Story này nên gọn, khoảng 2 giờ. Không làm thêm việc của các story sau.

### Những gì KHÔNG làm ở story này (thuộc story khác)

| Việc | Story |
|---|---|
| GUT, `tools/test.sh`, `check_boundaries.sh` | 0.2 |
| `Log`, cờ dev, đọc `--dev` / `--tran=N`, `launch_options.gd`, `AppState` | 0.3 |
| `i18n/text.csv`, font tiếng Việt, Theme | 0.4 |
| `export_presets.cfg`, `build_web.sh`, `deploy_itch.sh`, butler | 0.5 |
| GoPeak, Context7 | 0.6 |
| `BattleState`, mọi thứ trong `src/core/` | E1 trở đi |

### Luật kiến trúc phải theo ngay từ story này

- **Cây thư mục** theo đúng `game-architecture.md` mục *Cấu trúc dự án*: project Godot nằm trong `game/`, script trong `game/src/<tầng>/`, scene trong `game/scenes/`, lệnh cho tác giả trong `tools/` ở gốc repo. [Source: game-architecture.md#Cây thư mục]
- **Scene nhỏ và phẳng:** `.tscn` chỉ là khung; ô cờ vẽ bằng code; signal nối trong code. [Source: game-architecture.md#Khởi tạo dự án]
- **Gõ kiểu tĩnh mọi nơi**, `untyped_declaration` = error. Chỉ cú pháp Godot 4 (`await`, `@onready`, `signal.connect(callable)`); cấm `yield`, `onready var`, `export var`. [Source: project-context.md#Luật riêng của Godot]
- **Không dùng `print()`**. Story này chưa có `Log` (Story 0.3), nên đơn giản là không ghi log. Lỗi đọc `build_info.json` thì lặng lẽ dùng `"dev"`.
- **Đặt tên:** script `snake_case` tiếng Anh (`board_view.gd`); `class_name` PascalCase (`BoardView`); file dữ liệu tiếng Việt không dấu. [Source: game-architecture.md#Quy ước đặt tên]
- **Lấy node bằng `%TênDuyNhất`** nếu cần, không dùng `/root/...`. Story này tạo node bằng code nên giữ tham chiếu bằng biến có kiểu.
- **Độ phân giải 1280×720, stretch `canvas_items`, aspect `keep`** (quyết định #13). **Renderer Compatibility** (bắt buộc cho web).
- **Ghim phiên bản Godot `4.7.2.stable`.** Không tự nâng. Lối thoát duy nhất là lùi về 4.6.3, và chỉ khi tác giả đồng ý. Không đề xuất đổi engine. [Source: game-architecture.md#Engine đã chọn]

### Ghi chú kỹ thuật (Godot 4.7.2)

- Release: `4.7.2-stable`, ngày 18/08/2026. Danh sách file đã kiểm trên GitHub ngày 2026-10-17: có `Godot_v4.7.2-stable_macos.universal.zip`, `Godot_v4.7.2-stable_linux.x86_64.zip`, `Godot_v4.7.2-stable_export_templates.tpz`, `SHA512-SUMS.txt`. **Không** dùng các file có chữ `mono` (bản .NET; dự án chỉ dùng GDScript).
- Mã phiên bản trong thư mục template là `4.7.2.stable` (dấu chấm). Sai tên thì Story 0.5 export sẽ báo thiếu template.
- `ProjectSettings.get_setting("application/config/version")` trả về `Variant`: ép sang `String` tường minh (`str(...)` hoặc `as String` sau khi kiểm tra kiểu).
- `JSON.parse_string()` trả về `Variant`: kiểm tra `is Dictionary` rồi mới đọc khóa `commit`, không dùng `:=` trực tiếp trên kết quả. [Source: project-context.md#Luật riêng của Godot]
- `res://build_info.json` đọc được khi chạy từ thư mục project. Ở Story 0.5 cần nhớ thêm `*.json` vào filter export (đã có trong kiến trúc) và để `build_web.sh` sinh file này trước khi export.
- `OS.get_cmdline_user_args()` trả về các tham số sau `--`. Story này chỉ cần `chay.sh` chuyển tiếp đúng.
- Với `canvas_items` + `keep`, Godot tự co giãn toàn bộ khung 1280×720 và thêm viền đen khi tỉ lệ cửa sổ khác 16:9. Không cần code co giãn riêng cho bàn cờ.

### Cấu trúc file sau story

```
chong-nguyen-mong/
├── CLAUDE.md                     # MỚI
├── .gitignore                    # SỬA: thêm build/, .tools/, game/.godot/, game/build_info.json
├── .tools/                       # MỚI, gitignore: Godot 4.7.2 + editor_data/export_templates
├── tools/
│   ├── _godot.sh                 # MỚI: biến GODOT dùng chung
│   ├── cai_dat.sh                # MỚI
│   └── chay.sh                   # MỚI
└── game/
    ├── project.godot             # MỚI
    ├── scenes/main.tscn          # MỚI
    └── src/
        ├── app/main.gd           # MỚI
        └── battle/board_view.gd  # MỚI
```

`tools/_godot.sh` là file mới, không có trong cây thư mục của kiến trúc. Lý do: AC 8 yêu cầu mọi script dùng cùng một bản Godot; một file dùng chung tránh lặp code trong 7 script của `tools/`. Tên có dấu `_` ở đầu để tác giả biết đây không phải lệnh để gõ.

### Testing

- Story này chưa có khung test (GUT đến ở Story 0.2). Kiểm tra bằng Task 6: chạy lệnh headless không có lỗi, kiểm tra luật gõ kiểu, tác giả xác nhận bằng mắt.
- Hướng dẫn cho tác giả tự test, viết vào Completion Notes:
  1. `tools/cai_dat.sh` → đợi tải xong, thấy chữ báo đã cài.
  2. `tools/cai_dat.sh` lần nữa → thấy "Đã cài Godot 4.7.2" ngay.
  3. `tools/chay.sh` → thấy bàn 7×7 và chữ phiên bản ở góc.
  4. Kéo giãn cửa sổ → bàn không méo.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết bất kỳ dòng code nào.
- Godot **4.7.2.stable**, chỉ GDScript, renderer Compatibility, không tự nâng phiên bản.
- Gõ kiểu tĩnh mọi nơi; `untyped_declaration` = error; giá trị từ JSON và ProjectSettings là `Variant`, phải kiểm kiểu và ép tường minh.
- Scene nhỏ và phẳng; không việc nào đòi mở editor.
- `app_state.gd` là autoload duy nhất (chưa tạo ở story này). Không tạo autoload khác.
- Không dùng `Thread` (web đơn luồng). Không dùng vật lý, TileMap, `AStarGrid2D`.
- Git: chỉ commit khi kiểm tra đạt; lời commit tiếng Việt; không `push --force`.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 0.1]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Engine và framework]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Khởi tạo dự án]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Cây thư mục]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Bảng tổng hợp (quyết định #13, #16, #17, #22)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Công cụ debug (hiển thị phiên bản build)]
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Môi trường phát triển]
- [Source: _bmad-output/project-context.md#Công nghệ và phiên bản, #Luật riêng của Godot, #Nền tảng và build]
- [Source: https://github.com/godotengine/godot/releases/tag/4.7.2-stable (danh sách file kiểm ngày 2026-10-17)]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- `--headless --path game --import` và `--quit-after 30`: 0 dòng `ERROR`.
- `--headless --editor --quit --verbose`: Godot nạp `.tools/godot-4.7.2/editor_data/editor_settings-4.7.tres` → chế độ tự chứa hoạt động.
- Thử `var x = 1` trong `main.gd`: `SCRIPT ERROR: Parse Error: Variable "x" has no static type. (Warning treated as error.)`. Đã xóa dòng thử.
- Ảnh khung hình xuất bằng `--write-movie` (không có quyền `screencapture`): bàn 7×7 giữa khung, nhãn `v0.1.0 · 90aa4b4-sua`; không có / hỏng `build_info.json` → `v0.1.0 · dev`.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- **Chế độ tự chứa trên macOS (lệch so với Task 1.5):** file `._sc_` đặt trong `Godot.app/Contents/MacOS/` thì có tác dụng, nhưng Godot ghi `editor_data/` **cạnh `Godot.app`** (`.tools/godot-4.7.2/editor_data/`), không phải trong `Contents/MacOS/`. `_godot.sh` đặt `GODOT_DATA_DIR` theo đường đúng; template nằm ở `.tools/godot-4.7.2/editor_data/export_templates/4.7.2.stable/`. Không cần lùi về thư mục người dùng chuẩn. Story 0.5 dùng `$GODOT_DATA_DIR`.
- `user://` của game (khi chạy) vẫn nằm ở `~/Library/Application Support/Godot/app_userdata/Chống Nguyên Mông/`; đây là dữ liệu game, không phải dữ liệu editor.
- `cai_dat.sh`: thêm thử lại (`--retry 5`) và tải tiếp phần dở (`-C -`, giữ file `.tmp`) vì file template 1,28 GB bị ngắt mạng hai lần khi cài. Đã kiểm: tải tiếp ra file khớp SHA-512. File tải tạm `.tools/tai_ve/` bị xóa sau khi cài xong. Đã kiểm file hỏng → báo lỗi tiếng Việt, xóa file, thoát mã 1.
- `main.gd` dùng `JSON.new().parse()` thay cho `JSON.parse_string()` vì hàm sau tự in `ERROR` khi file hỏng, trái với yêu cầu "lặng lẽ dùng `dev`".
- `_godot.sh` nhận `GODOT_BO_QUA_KIEM_TRA=1` để `cai_dat.sh` dùng chung biến mà không bị thoát khi chưa cài.
- Đã kiểm `tools/chay.sh --dev --tran=3`: tiến trình Godot nhận `-- --dev --tran=3`; chạy được từ thư mục khác gốc repo.
- **Hướng dẫn tác giả tự test:**
  1. `tools/cai_dat.sh` → đợi tải xong, thấy "Đã cài xong Godot 4.7.2".
  2. `tools/cai_dat.sh` lần nữa → thấy "Đã cài Godot 4.7.2" ngay.
  3. `tools/chay.sh` → thấy bàn 7×7 và chữ phiên bản ở góc dưới phải.
  4. Kéo giãn cửa sổ → bàn không méo, ô vẫn vuông, có viền đen khi cửa sổ khác tỉ lệ 16:9.
- Tác giả đã xác nhận bằng mắt AC 1–3 (bàn 7×7, nhãn phiên bản, co giãn không méo) ngày 2026-10-17: "đạt".

### File List

- `.gitignore` (sửa)
- `CLAUDE.md` (mới)
- `tools/_godot.sh` (mới)
- `tools/cai_dat.sh` (mới)
- `tools/chay.sh` (mới)
- `game/project.godot` (mới)
- `game/scenes/main.tscn` (mới)
- `game/src/app/main.gd` (mới)
- `game/src/app/main.gd.uid` (mới, Godot sinh)
- `game/src/battle/board_view.gd` (mới)
- `game/src/battle/board_view.gd.uid` (mới, Godot sinh)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (sửa trạng thái)

### Change Log

- 2026-10-17: Tạo project Godot trống trong `game/`, bàn 7×7 vẽ bằng code, nhãn phiên bản; `tools/cai_dat.sh`, `tools/chay.sh`, `tools/_godot.sh`; `CLAUDE.md`; cập nhật `.gitignore`.
