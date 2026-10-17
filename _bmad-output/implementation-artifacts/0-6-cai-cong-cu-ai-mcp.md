---
baseline_commit: a557bd4
---

# Story 0.6: Cài công cụ AI (MCP)

Status: done

## Story

Là tác giả,
tôi muốn AI tự nhìn thấy được game đang chạy,
để khi tôi báo lỗi, AI tự xem log và chụp màn hình được.

## Acceptance Criteria

1. **Việc tác giả tự làm** (AI hướng dẫn từng bước, không làm thay được):
   1. Chạy `tools/cai_dat.sh` (cài thêm GoPeak và Context7 vào `.tools/`).
   2. Thoát Claude Code rồi mở lại trong thư mục repo. Khi Claude Code hỏi có dùng 2 MCP server `gopeak` và `context7` của project không, chọn **đồng ý**.
2. **Khi** gõ `tools/cai_dat.sh`, **thì**:
   - GoPeak **2.3.8** và Context7 (`@upstash/context7-mcp`) **4.1.1** được cài vào `.tools/mcp/` từ file khóa phiên bản (`package-lock.json`) có trong repo, không tải bản khác;
   - chạy lại khi đã cài thì không cài lại, in `Đã cài GoPeak 2.3.8 và Context7 4.1.1`;
   - máy thiếu Node.js hoặc Node.js cũ hơn 20.18 thì in lỗi tiếng Việt và thoát khác 0.
3. **Cho** GoPeak (profile `compact`) và Context7 đã được cài và được duyệt, **khi** gõ `claude mcp list`, **thì** thấy `gopeak` và `context7` đều `✔ Connected`.
4. **Khi** AI được yêu cầu "chụp màn hình game", **thì** AI tự chạy `tools/chay.sh --dev`, chụp được ảnh qua GoPeak (công cụ `capture_screenshot`) và mô tả đúng cái đang thấy: tiêu đề "Hào Khí Đông A", bàn cờ 7×7, chữ DEV đỏ, nhãn phiên bản ở góc dưới phải.
5. **Khi** AI được yêu cầu "xem log game", **thì** AI đọc được các dòng `[INFO][...]` của game đang chạy (từ đầu ra của `tools/chay.sh`), kể cả dòng `[INFO][mcp] ...` báo đã mở cổng cho GoPeak.
6. **Khi** AI cần tra một API Godot, **thì** AI tra qua Context7 đúng bản 4.7 (thư viện `/godotengine/godot-docs`, nhánh 4.7) và trích được đoạn tài liệu.
7. **Và** phiên bản được ghim trong file cấu hình MCP của repo: `.mcp.json` **không** gọi `npx`, chỉ gọi script trong `tools/`; `tools/mcp/package.json` ghi đúng `2.3.8` và `4.1.1` (không `^`, không `~`, không `latest`). `tools/test.sh` có test kiểm các điều này.
8. **Và** phần GoPeak trong game chỉ chạy khi bật dev, trên bản desktop, có cửa sổ (không chạy khi test headless, không có trong bản web):
   - không thêm autoload thứ hai (`AppState` vẫn là autoload duy nhất);
   - cổng 7777 chỉ nghe trên `127.0.0.1` (máy khác trong mạng không vào được);
   - preset Web loại trừ `addons/godot_mcp_runtime/*`.
9. **Và** `tools/test.sh` xanh; `tools/build_web.sh` vẫn đạt, bản web không chứa file nào của GoPeak.

## Tasks / Subtasks

- [x] **Task 0: Hỏi tác giả trước khi làm** (AC: 1, 6)
  - [x] 0.1 Hỏi các câu ở mục "Câu hỏi cho tác giả" (cuối Dev Notes). Ghi câu trả lời vào mục "Quyết định của tác giả". Câu 1 chưa trả lời thì vẫn làm được Task 1–6.

- [x] **Task 1: Ghim phiên bản bằng file khóa** (AC: 2, 7)
  - [x] 1.1 Tạo `tools/mcp/package.json`:
    ```json
    {
      "name": "chong-nguyen-mong-mcp",
      "private": true,
      "description": "Công cụ AI (MCP) của repo. Cài bằng tools/cai_dat.sh vào .tools/mcp/.",
      "dependencies": {
        "gopeak": "2.3.8",
        "@upstash/context7-mcp": "4.1.1"
      }
    }
    ```
  - [x] 1.2 Sinh `tools/mcp/package-lock.json` **một lần** bằng `npm install --package-lock-only --ignore-scripts` chạy trong một thư mục tạm có bản sao `package.json`, rồi chép file khóa về `tools/mcp/`. Commit cả hai file. File khóa ghim cả thư viện phụ thuộc (kèm mã `integrity` SHA-512), giống cách repo ghim Godot/GUT/butler bằng checksum.
  - [x] 1.3 Không tạo `node_modules/` trong `tools/mcp/` (nếu lỡ tạo thì xóa; `.gitignore` không cần sửa vì cài vào `.tools/`).

- [x] **Task 2: `tools/cai_dat.sh` cài MCP** (AC: 2)
  - [x] 2.1 Thêm biến vào `tools/_godot.sh` (sau khối butler, cùng kiểu chú thích):
    ```bash
    # Công cụ AI (MCP): GoPeak và Context7. Phiên bản ghim trong tools/mcp/package.json + package-lock.json.
    GOPEAK_VERSION="2.3.8"
    CONTEXT7_VERSION="4.1.1"
    MCP_DIR="$REPO_ROOT/.tools/mcp"
    ```
    Cập nhật dòng "Biến đặt ra" ở đầu file.
  - [x] 2.2 Thêm khối cài MCP vào **cuối** `tools/cai_dat.sh` (sau butler). Thứ tự:
    1. Kiểm `node` có trên máy và bản ≥ 20.18 (Context7 4.1.1 đòi `>=20.18.1`; máy tác giả hiện có Node 26.8.1). Thiếu: `Lỗi: chưa có Node.js 20.18 trở lên (cần cho công cụ AI). Cài từ https://nodejs.org rồi chạy lại.` ra stderr, thoát 1. **Chú ý:** Godot và butler đã cài xong trước bước này, nên lỗi Node không làm hỏng phần đã cài.
    2. Đã cài thì bỏ qua: so mã SHA-256 của `tools/mcp/package-lock.json` với nội dung `$MCP_DIR/.installed`. Giống nhau → in `Đã cài GoPeak 2.3.8 và Context7 4.1.1` (lấy số từ biến), không làm gì nữa. Khác (file khóa đổi vì nâng phiên bản) → cài lại.
    3. Cài: xóa `$MCP_DIR`, tạo lại, chép `package.json` và `package-lock.json` vào, chạy `npm ci --ignore-scripts --no-audit --no-fund --prefix "$MCP_DIR"`. `--ignore-scripts` để không chạy `postinstall` của gói nào (GoPeak có `postinstall` cài hook vào shell nếu đặt biến môi trường; ta không muốn).
    4. Kiểm sau khi cài: có `$MCP_DIR/node_modules/gopeak/build/cli.js` và `$MCP_DIR/node_modules/@upstash/context7-mcp/dist/index.js`; đọc `version` trong `package.json` của từng gói phải đúng `$GOPEAK_VERSION` / `$CONTEXT7_VERSION`. Sai thì `Lỗi: ...` và thoát 1.
    5. Ghi SHA-256 của file khóa vào `$MCP_DIR/.installed`, in `Đã cài GoPeak 2.3.8 và Context7 4.1.1`.
  - [x] 2.3 Sửa chú thích đầu file `cai_dat.sh`: thêm "công cụ AI (GoPeak, Context7)".
  - [x] 2.4 **Giữ nguyên** mọi hành vi cũ: chạy lại khi đã cài thì in `Đã cài Godot 4.7.2` / `Đã cài butler 15.32.0`, không tải lại.

- [x] **Task 3: Script khởi động MCP và `.mcp.json`** (AC: 3, 7)
  - [x] 3.1 Tạo `tools/mcp_gopeak.sh` (chmod +x):
    ```bash
    #!/usr/bin/env bash
    # Claude Code tự chạy file này (qua .mcp.json), tác giả không gõ trực tiếp.
    # Khởi động GoPeak 2.3.8 (profile compact), trỏ vào đúng bản Godot 4.7.2 trong .tools/.
    # KHÔNG được in gì ra stdout: stdout là đường nói chuyện MCP, in chữ vào đó làm hỏng kết nối.
    set -euo pipefail
    source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"
    ...kiểm $MCP_DIR/.installed, thiếu thì "Chưa có công cụ AI. Chạy tools/cai_dat.sh trước." ra stderr, thoát 1
    export GODOT_PATH="$GODOT"
    export GOPEAK_TOOL_PROFILE="compact"
    exec node "$MCP_DIR/node_modules/gopeak/build/cli.js"
    ```
    - `_godot.sh` chỉ in lỗi ra stderr và có thể thoát khi chưa cài Godot: chấp nhận được (Claude Code báo server không kết nối).
    - **Không** truyền tham số nào cho `cli.js` (tham số như `setup`, `star`, `check` là lệnh phụ của GoPeak, không phải server).
  - [x] 3.2 Tạo `tools/mcp_context7.sh` cùng mẫu: `exec node "$MCP_DIR/node_modules/@upstash/context7-mcp/dist/index.js"` (mặc định `--transport stdio`, đã kiểm trong `dist/index.js` của 4.1.1). Nếu Task 0 tác giả cho dùng API key: Context7 tự đọc biến môi trường `CONTEXT7_API_KEY` của máy, script **không** truyền `--api-key` (tham số dòng lệnh hiện ra trong `ps`), và không ghi key vào repo.
  - [x] 3.3 Tạo `.mcp.json` ở gốc repo (cấu hình MCP phạm vi project của Claude Code):
    ```json
    {
      "mcpServers": {
        "gopeak": { "command": "tools/mcp_gopeak.sh", "args": [] },
        "context7": { "command": "tools/mcp_context7.sh", "args": [] }
      }
    }
    ```
    - Không `npx`, không `env` chứa đường dẫn tuyệt đối của máy tác giả (đường dẫn do `_godot.sh` tự tính).
    - Đường dẫn tương đối tính từ thư mục mở Claude Code (gốc repo). Kiểm ở Task 7.2; nếu Claude Code không tìm được file thì thử `"command": "bash", "args": ["tools/mcp_gopeak.sh"]`, ghi lại cách chạy được vào Debug Log.
  - [x] 3.4 Thử tay trước khi nhờ tác giả khởi động lại: gửi một yêu cầu `initialize` của MCP vào stdin của từng script, đầu ra phải là JSON bắt đầu bằng `{"` (không có chữ lạ trước đó). Ví dụ:
    ```bash
    printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"thu","version":"0"}}}' \
      | tools/mcp_gopeak.sh 2>/dev/null | head -c 300
    ```
    macOS không có `timeout`: nếu lệnh treo vì server chờ thêm input thì chạy nền và `kill` sau vài giây. Ghi kết quả vào Debug Log.

- [x] **Task 4: Addon runtime của GoPeak trong game** (AC: 4, 8)
  - [x] 4.1 Chép **từ gói npm đã ghim** (`.tools/mcp/node_modules/gopeak/build/addon/godot_mcp_runtime/`), **không** dùng `install-addon.sh` trên GitHub (script đó lấy nhánh `main`, không ghim phiên bản). Chỉ chép:
    - `mcp_runtime_autoload.gd` → `game/addons/godot_mcp_runtime/mcp_runtime_autoload.gd`;
    - `LICENSE` của gói gopeak (MIT) → `game/addons/godot_mcp_runtime/LICENSE`.
    **Không** chép `plugin.cfg` và `godot_mcp_runtime.gd` (plugin editor, khi bật sẽ tự thêm autoload `MCPRuntime` vào `project.godot`, phạm luật một autoload). **Không** chép `godot_mcp_editor/` và `auto_reload/` (cần mở editor; dự án không mở editor).
  - [x] 4.2 Sửa **một dòng** trong bản chép để chỉ nghe trên máy này: dòng 65 `var error = _server.listen(_port)` → `var error = _server.listen(_port, "127.0.0.1")`. Mặc định Godot nghe mọi địa chỉ (`"*"`), tức máy khác cùng mạng Wi-Fi gọi được `set_property`/`call_method` vào game. Thêm chú thích ngay trên dòng: `# Sửa so với GoPeak 2.3.8: chỉ nghe 127.0.0.1 (Story 0.6).` Ngoài dòng này không sửa gì khác trong file (giữ nguyên `print()`, kiểu không tường minh: `exclude_addons=true` trong `project.godot` đã tắt cảnh báo cho `addons/`, và `check_boundaries.sh` chỉ quét `game/src/`).
  - [x] 4.3 Tạo `game/src/debug/mcp_runtime.gd`:
    ```gdscript
    class_name McpRuntime
    extends RefCounted
    ## Bật cổng 7777 cho GoPeak (công cụ AI chụp màn hình, bơm input) khi chạy bản desktop có bật dev.
    ## Không dùng autoload: gắn node làm con của màn hình gốc. Bản web không có addon (preset loại trừ).

    const SCRIPT_PATH: String = "res://addons/godot_mcp_runtime/mcp_runtime_autoload.gd"

    static func should_start(dev: bool, is_web: bool, is_headless: bool) -> bool:
        return dev and not is_web and not is_headless

    ## Gắn node runtime vào parent nếu đủ điều kiện. Trả về true nếu đã gắn.
    static func start_if_enabled(parent: Node, dev: bool) -> bool:
        ...should_start(dev, OS.has_feature("web"), DisplayServer.get_name() == "headless")
        ...không đủ điều kiện → return false (không log)
        ...không có file (ResourceLoader.exists) → Log.warn("mcp", "không thấy addon GoPeak: ...") rồi return false
        ...var script: GDScript = load(SCRIPT_PATH) as GDScript; var node: Node = script.new() as Node
        ...parent.add_child(node); Log.info("mcp", "mở cổng 7777 cho GoPeak (chỉ máy này)"); return true
    ```
    - Dùng `load()` lúc chạy, **không** `preload()` (bản web không có file, `preload` sẽ làm hỏng export).
    - Ép kiểu tường minh (`untyped_declaration` là error trong `src/`).
    - Không `print()`; chỉ `Log`.
  - [x] 4.4 Gọi trong `game/src/app/main.gd`, ngay sau `add_child(dev_tools)`:
    ```gdscript
    	# Công cụ AI (Story 0.6): chỉ khi bật dev trên desktop có cửa sổ.
    	McpRuntime.start_if_enabled(self, AppState.launch.dev)
    ```
    **Giữ nguyên** mọi thứ khác trong `main.gd` (tiêu đề, bàn cờ, nhãn phiên bản, `SaveProbe`, `DevTools`).
  - [x] 4.5 Thêm `addons/godot_mcp_runtime/*` vào `exclude_filter` của `game/export_presets.cfg`: `exclude_filter="tests/*, addons/gut/*, addons/godot_mcp_runtime/*"`.

- [x] **Task 5: Test** (AC: 7, 8, 9)
  - [x] 5.1 Viết test trước, chạy `tools/test.sh` thấy **trượt**, rồi mới viết code (giống các story trước).
  - [x] 5.2 `game/tests/test_mcp_runtime.gd`:
    - `should_start`: chỉ `(true, false, false)` ra `true`; 7 tổ hợp còn lại ra `false`.
    - `start_if_enabled(parent, false)` trả `false` và không thêm con nào.
    - `start_if_enabled(parent, true)` khi chạy GUT (headless) trả `false` và không thêm con nào: chứng minh test không mở cổng 7777.
    - File `SCRIPT_PATH` tồn tại; nội dung có `listen(_port, "127.0.0.1")` và **không** còn `listen(_port)` trần.
    - Thư mục `res://addons/godot_mcp_runtime/` không có `plugin.cfg` (không ai bật được plugin tự thêm autoload).
    - `project.godot` chỉ có một autoload: đọc mục `[autoload]` bằng `ConfigFile` từ `res://project.godot`, danh sách khóa là đúng `["AppState"]`.
  - [x] 5.3 `game/tests/test_export_preset.gd`: trong `test_excludes_tests_and_gut` (hoặc test mới `test_excludes_gopeak_runtime`) kiểm `exclude_filter` có `addons/godot_mcp_runtime/*`.
  - [x] 5.4 `game/tests/test_mcp_config.gd` (đọc file ngoài `game/` bằng `ProjectSettings.globalize_path("res://").path_join("../.mcp.json")` rồi `simplify_path()`; `FileAccess` được dùng trong test):
    - `.mcp.json` parse được, có đúng 2 server `gopeak` và `context7`;
    - toàn bộ nội dung `.mcp.json` không chứa chữ `npx`;
    - `command` của mỗi server bắt đầu bằng `tools/` (hoặc `args[0]` bắt đầu bằng `tools/` nếu dùng cách `bash`);
    - `tools/mcp/package.json`: `dependencies.gopeak == "2.3.8"`, `dependencies["@upstash/context7-mcp"] == "4.1.1"`;
    - `tools/mcp/package-lock.json` tồn tại, mục `packages["node_modules/gopeak"].version == "2.3.8"` và `packages["node_modules/@upstash/context7-mcp"].version == "4.1.1"`, cả hai có `integrity`;
    - `tools/mcp_gopeak.sh` có `GOPEAK_TOOL_PROFILE="compact"`.
    - Giá trị từ `JSON.parse_string()` là `Variant`: kiểm kiểu rồi ép kiểu tường minh (luật project-context).
  - [x] 5.5 `test_main.gd` hiện có các ca bật dev: phải vẫn xanh và **không** mở cổng (GUT headless → `should_start` false). Không cần sửa nếu đúng vậy; nếu số con của `main` được test đếm thì kiểm lại.
  - [x] 5.6 `tools/test.sh` xanh. Ghi tổng số test vào Debug Log (trước story: 62).

- [x] **Task 6: Hướng dẫn cho AI các phiên sau** (AC: 4, 5, 6)
  - [x] 6.1 Thêm vào `CLAUDE.md` (gốc repo) một mục ngắn, viết tiếng Việt, ví dụ:
    ```markdown
    ## Nhìn game đang chạy (MCP)

    - Chụp màn hình: chạy `tools/chay.sh --dev` ở chế độ nền, chờ khoảng 5 giây, rồi gọi `capture_screenshot` của GoPeak (tìm bằng `tool_catalog` từ khóa "screenshot" nếu chưa thấy công cụ). Xong thì tắt game.
    - Xem log: đọc đầu ra của lệnh `tools/chay.sh` đang chạy nền (dòng `[INFO][...]`). Không dùng `run_project` của GoPeak: nó chạy `--headless`, không có cửa sổ, không có `--dev`.
    - Tra API Godot: Context7, thư viện `/godotengine/godot-docs`, nhánh 4.7.
    - MCP chỉ để *nhìn* và *thử*. Luật và dữ liệu trận chỉ sửa trong code, có test đi kèm.
    ```
    Dùng đúng ID thư viện và tên công cụ đã kiểm được ở Task 7 (sửa ví dụ trên nếu khác).
  - [x] 6.2 Ghi vào `NEXT-STEPS.md` một mục "Công cụ AI (MCP)": cài bằng `tools/cai_dat.sh`, lần đầu phải mở lại Claude Code và đồng ý 2 server; kiểm bằng `claude mcp list`.

- [x] **Task 7: Kiểm thật cùng tác giả** (AC: 1, 3, 4, 5, 6, 9)
  - [x] 7.1 Chạy `tools/cai_dat.sh` (AI chạy được, không cần tác giả): lần đầu cài MCP; lần hai in `Đã cài …` cho cả 3 phần. Thử Node thiếu: chạy khối kiểm Node với `PATH` không có `node` (bản sao tạm của đoạn kiểm, giống cách Story 0.5 thử trượt 25 MB), thấy lỗi tiếng Việt, mã 1.
  - [x] 7.2 Commit phần đã xong (test xanh). Hướng dẫn tác giả (theo "Hướng dẫn cho tác giả" ở Dev Notes): thoát Claude Code, mở lại, đồng ý 2 server, gõ `claude mcp list`. Cả hai phải `✔ Connected`. **Phiên AI hiện tại không dùng được MCP mới cho tới khi mở lại**: phần kiểm 7.3–7.5 làm ở phiên mới (tác giả gọi lại `/gds-dev-story` cho story này, AI đọc Debug Log để biết đang ở đâu).
  - [x] 7.3 AC 4: chạy `tools/chay.sh --dev` nền, gọi `capture_screenshot`, mô tả ảnh. Nếu `capture_screenshot` không hiện trong danh sách công cụ, gọi `tool_catalog` với từ khóa "screenshot" (nhóm `testing` tự bật). Nếu Claude Code không làm mới danh sách công cụ sau khi bật nhóm, ghi lại và thử gọi thẳng công cụ; vẫn không được thì **hỏi tác giả** (không tự đổi profile `compact`, vì đó là quyết định #23).
  - [x] 7.4 AC 5: đọc đầu ra của lệnh nền, thấy `[INFO][mcp] mở cổng 7777 cho GoPeak (chỉ máy này)` và `[INFO][luu_thu] ...`. Thử thêm `inject_mouse_click` vào giữa bàn cờ (không cần kết quả gì, chỉ cần không lỗi) để biết bơm input dùng được cho E1.
  - [x] 7.5 AC 6: tra Context7 một API Godot dự án sẽ dùng (ví dụ `Tween` hoặc `TranslationServer`), ghi ID thư viện và nhánh đã dùng vào Debug Log.
  - [x] 7.6 AC 8: khi game đang chạy `--dev`, `lsof -nP -iTCP:7777 -sTCP:LISTEN` phải cho thấy `127.0.0.1:7777` (không phải `*:7777`). Chạy `tools/chay.sh` **không** `--dev`: `lsof` không thấy cổng 7777.
  - [x] 7.7 AC 9: `tools/build_web.sh` đạt; kiểm bản web không có addon: `strings build/web/index.pck | grep -c godot_mcp` ra `0` (hoặc cách khác chắc hơn, ghi vào Debug Log). Dung lượng bản nén không đổi đáng kể (≈ 10.4 MB).
  - [x] 7.8 Ghi kết quả vào Debug Log, cập nhật Completion Notes (kèm hướng dẫn tác giả tự test), File List, Change Log. Commit.

### Review Findings

Code review 2026-10-18 (Blind Hunter, Edge Case Hunter, Acceptance Auditor), diff `a557bd4..HEAD` (bỏ file khóa và thân addon chép nguyên; addon so với bản gốc chỉ khác dòng `listen`).

- [x] [Review][Decision] Chưa chặn bản phát hành — `should_start` chỉ xét dev/web/headless. Hiện chỉ có preset Web (đã loại addon) nên chưa sao; nếu sau này thêm preset desktop mà quên loại addon thì bản phát hành chạy với `--dev` sẽ mở cổng 7777 điều khiển được game. Có thêm điều kiện `OS.is_debug_build()` (chỉ bản chạy bằng `chay.sh`/editor mới mở cổng) không? **Tác giả chọn (2026-10-18): thêm `OS.is_debug_build()`** → thành Patch bên dưới.
- [x] [Review][Patch] Thêm điều kiện bản debug (`OS.is_debug_build()`) để bản phát hành không bao giờ mở cổng 7777 [game/src/debug/mcp_runtime.gd:125]
- [x] [Review][Patch] Cổng 7777 bận (mở game 2 lần) mà log vẫn báo "mở cổng 7777" và trả true; GoPeak âm thầm nói chuyện với cửa sổ kia [game/src/debug/mcp_runtime.gd:139]
- [x] [Review][Patch] Không kiểm null sau `load()` addon: addon lỗi biên dịch thì `--dev` báo lỗi runtime trong `main._ready` thay vì cảnh báo [game/src/debug/mcp_runtime.gd:137]
- [x] [Review][Patch] Kiểm Node cho qua 20.18.0 nhưng Context7 4.1.1 đòi `>=20.18.1`; thiếu npm mà thông báo chỉ nói thiếu Node [tools/cai_dat.sh:369]
- [x] [Review][Patch] `CLAUDE.md` ghi sai dạng tọa độ (`[x, y]` là của giao thức TCP; công cụ GoPeak nhận `x`, `y` riêng) và chưa ghi ID Context7 đã kiểm `/godotengine/godot-docs/__branch__4.7` [CLAUDE.md:25]
- [x] [Review][Patch] Script khởi động MCP chỉ kiểm có file `.installed`, không kiểm khớp file khóa hiện tại (kéo bản mới về mà chưa chạy `cai_dat.sh` thì vẫn chạy bản cũ); lỗi thiếu tiền tố `Lỗi:` [tools/mcp_gopeak.sh:8]
- [x] [Review][Patch] Dấu `.installed` chỉ băm file khóa, sửa `package.json` mà không sửa khóa thì `cai_dat.sh` vẫn báo đã cài [tools/cai_dat.sh:378]
- [x] [Review][Patch] Test bảng chân trị tính `expected` bằng đúng biểu thức của code (test lặp lại code) [game/tests/test_mcp_runtime.gd:9]
- [x] [Review][Patch] Phiên bản ghi ở 3 nơi (`_godot.sh`, `package.json`/khóa, test) mà không test nào nối `_godot.sh` và gốc file khóa với `package.json` [game/tests/test_mcp_config.gd]
- [x] [Review][Patch] Đổi yêu cầu Node 18+ (kiến trúc) thành 20.18.1+ chưa ghi vào mục lệch kiến trúc [_bmad-output/implementation-artifacts/0-6-cai-cong-cu-ai-mcp.md]
- [x] [Review][Defer] Nâng phiên bản mà mất mạng: `rm -rf .tools/mcp` chạy trước `npm ci` nên mất luôn bản cũ đang chạy được [tools/cai_dat.sh:385] — deferred, ít gặp
- [x] [Review][Defer] Context7 không cần Godot nhưng script vẫn source `_godot.sh` (chưa cài Godot hoặc máy không hỗ trợ thì Context7 cũng không chạy) [tools/mcp_context7.sh:7] — deferred, ít gặp
- [x] [Review][Defer] Claude Code mở từ chỗ PATH không có `node`, hoặc `node_modules` bị xóa một phần: server chỉ báo "failed", không có lời nhắc tiếng Việt [tools/mcp_gopeak.sh:15] — deferred, ít gặp
- [x] [Review][Defer] `.mcp.json` dùng đường tương đối, phụ thuộc thư mục Claude Code khởi động [.mcp.json:3] — deferred, đã chạy được từ gốc repo

## Dev Notes

### Bối cảnh

- Story 0.1–0.5 đã xong. Game desktop chạy bằng `tools/chay.sh` (nhận `--dev`, `--tran=N`), có tiêu đề "Hào Khí Đông A", bàn cờ 7×7, nhãn `v0.1.0 · <commit>`, chữ DEV khi bật dev. Bản web ở `https://tuantrunglc.itch.io/hao-khi-dong-a` (Draft).
- **Chưa có MCP nào cho project:** `claude mcp list` chỉ có các connector claude.ai (Docs, Trends, Drive); `~/.claude.json` không có `mcpServers` cho repo này; repo chưa có `.mcp.json`.
- Máy tác giả có Node `v26.8.1`, `npm`, `npx` ở `/opt/homebrew/bin/` (kiểm 2026-10-18).
- Các phiên trước chụp màn hình bằng `--write-movie` (vì `screencapture` bị chặn) và Chrome headless cho bản web. GoPeak chụp từ **bên trong game** (`viewport.get_texture().get_image()`), không cần quyền chụp màn hình của macOS.
- Ngân sách E0 khoảng 12 giờ cho 6 story. Story này khoảng 1.5–2 giờ.

### Cách GoPeak 2.3.8 chạy (đã đọc mã nguồn gói npm, 2026-10-18)

- Gói `gopeak@2.3.8` (MIT, mới nhất trên npm, phát hành khoảng 4 tháng trước). `bin`: `gopeak` / `godot-mcp` → `build/cli.js`. Không tham số thì chạy MCP server qua stdio. Phụ thuộc: `@modelcontextprotocol/sdk ^1.27.1`, `fs-extra`, `ws` (file khóa ghim cụ thể).
- Biến môi trường: `GODOT_PATH` (đường dẫn Godot), `GOPEAK_TOOL_PROFILE` (`compact` mặc định), `GOPEAK_RUNTIME_TIMEOUT_MS` (mặc định 10000).
- Profile `compact` chỉ hiện nhóm lõi: `tool_catalog`, `manage_tool_groups`, `run_project`, `stop_project`, `get_debug_output`, `get_runtime_status`, `list_export_presets`… **`capture_screenshot`, `inject_*` nằm trong nhóm `testing`** (bật động: gọi `tool_catalog` với từ khóa, nhóm khớp tự bật).
- **`run_project` của GoPeak chạy `godot --headless -d --path <project>`**: không có cửa sổ (ảnh chụp sẽ trống hoặc lỗi), không có `--dev` (nên addon không bật). **Không dùng `run_project`** để chụp. Dùng `tools/chay.sh --dev` chạy nền; `get_debug_output` chỉ đọc được tiến trình do `run_project` mở, nên log đọc từ đầu ra của `chay.sh`.
- Chụp màn hình: server GoPeak mở TCP tới `127.0.0.1:7777`, gửi `{"command":"capture_screenshot","params":{"output_path":<file tạm>}}`. Addon trong game lưu PNG vào file tạm đó rồi trả `screenshot_file`; GoPeak đọc file, trả ảnh cho AI.
- Addon runtime (`mcp_runtime_autoload.gd`, 671 dòng, `extends Node`): `_ready()` mở `TCPServer` cổng 7777, `_process` nhận lệnh JSON: `get_tree`, `get_node`, `set_property`, `call_method`, `get_metrics`, `capture_screenshot`, `capture_viewport`, `inject_action`, `inject_key`, `inject_mouse_click`, `inject_mouse_motion`, `watch_signal`… Có `print()`, có biến không ghi kiểu (`var client = ...`): chấp nhận được vì nằm trong `addons/` (cảnh báo bị `exclude_addons=true` tắt; `check_boundaries.sh` chỉ quét `game/src/`). **Phải kiểm** bước `--import` của `test.sh` không báo `SCRIPT ERROR`/`Parse Error` cho file này trên Godot 4.7.2.
- `_start_server()` gọi `_server.listen(_port)`: Godot mặc định `bind_address = "*"` (mọi địa chỉ). Lệnh `set_property`/`call_method` không có xác thực → phải sửa thành `"127.0.0.1"` (Task 4.2).
- Nếu cổng 7777 đang bận (mở game 2 lần), addon `push_error` và tắt; game vẫn chạy bình thường.
- `postinstall.mjs` của GoPeak chỉ cài hook shell khi đặt `GOPEAK_SETUP_HOOKS=1`; ta vẫn dùng `--ignore-scripts` cho chắc.

### Context7 (đã kiểm 2026-10-18)

- Gói `@upstash/context7-mcp`. Bản mới nhất 4.4.2 (2026-10-15), ra liên tục nhiều bản trong tháng 10. **Ghim 4.1.1** (2026-09-14): bản mới nhất đã ra hơn 2 tuần, tránh bản vừa phát hành. `bin`: `context7-mcp` → `dist/index.js`. Đòi Node `>=20.18.1`.
- API `context7.com` có thư viện **`/godotengine/godot-docs`** (tài liệu chính thức, 45 772 đoạn, cập nhật 2026-10-16), có các bản `__branch__4.5`, `__branch__4.7`. Cũng có `/godotengine/godot` (mã nguồn, ít đoạn hơn). Dùng `godot-docs` nhánh 4.7. Cú pháp chỉ định phiên bản trong Context7 thường là `/<org>/<project>/<phiên bản>`; kiểm bằng công cụ `resolve-library-id` ở Task 7.5 và ghi lại ID dùng được.
- Không có API key vẫn dùng được (giới hạn lượt tra thấp hơn). Xem câu hỏi 1.
- Bản server từ xa (`https://mcp.context7.com/mcp`) **không** ghim được phiên bản: không dùng (AC 7).

### File sẽ sửa (đọc trước khi sửa)

**`tools/_godot.sh`**: đặt `REPO_ROOT`, biến Godot, biến butler, hàm `ghi_build_info`; kiểm Godot đã cài trừ khi `GODOT_BO_QUA_KIEM_TRA=1`.
- **Thay đổi:** thêm `GOPEAK_VERSION`, `CONTEXT7_VERSION`, `MCP_DIR`; sửa dòng "Biến đặt ra".
- **Giữ nguyên:** mọi biến, hàm và thông báo hiện có. `test.sh`, `chay.sh`, `build_web.sh`, `deploy_itch.sh`, `check_boundaries.sh`, `cai_dat.sh` đều source file này. **Không** in gì ra stdout ở cấp file (script MCP cũng source nó).

**`tools/cai_dat.sh`**: cài Godot (SHA-512), export template, butler (SHA-256); mỗi phần có `.installed` riêng, chạy lại không tải lại.
- **Thay đổi:** thêm khối MCP ở cuối (Task 2.2), sửa chú thích đầu file.
- **Giữ nguyên:** hàm `tai`, `kiem_tra`, `sha256`, `sha512`, thứ tự Godot → butler, xóa `.tools/tai_ve`.

**`game/src/app/main.gd`**: dựng tiêu đề, `BoardView`, nhãn phiên bản, `SaveProbe.bump`, `DevTools.setup(AppState.launch.dev, opens)`.
- **Thay đổi:** thêm một dòng gọi `McpRuntime.start_if_enabled(self, AppState.launch.dev)` sau `add_child(dev_tools)`.
- **Giữ nguyên:** tất cả phần còn lại; `test_main.gd` phải vẫn xanh.

**`game/export_presets.cfg`**: preset Web đơn luồng (Story 0.5).
- **Thay đổi:** thêm `addons/godot_mcp_runtime/*` vào `exclude_filter`.
- **Giữ nguyên:** mọi khóa khác (`include_filter`, `thread_support=false`, `export_path`…). `test_export_preset.gd` hiện có phải vẫn xanh.

**`game/tests/test_export_preset.gd`**: 5 test (một preset Web, có `*.json`, loại `tests/*` + `addons/gut/*`, đơn luồng, `export_path`).
- **Thay đổi:** thêm kiểm `addons/godot_mcp_runtime/*`.

**`CLAUDE.md`**: hiện có 3 mục (đọc trước khi viết code, làm việc với tác giả, lệnh chính, tiến độ).
- **Thay đổi:** thêm mục "Nhìn game đang chạy (MCP)" (Task 6.1). Giữ ngắn, giữ các mục cũ.

### Những gì KHÔNG làm ở story này

| Việc | Story / lý do |
|---|---|
| Addon editor của GoPeak (`godot_mcp_editor`), `auto_reload` | Không làm: dự án không mở editor |
| Dùng MCP để sửa scene, script, dữ liệu trận | Cấm (game-architecture: MCP chỉ để nhìn và thử) |
| LSP (cổng 6005), DAP (cổng 6006) của GoPeak | Không làm: cần editor chạy |
| Chụp màn hình bản web qua GoPeak | Không làm: bản web không có addon; vẫn dùng Chrome headless như Story 0.5 |
| Test tự động cho `cai_dat.sh`, script MCP | Hoãn, giống các script `tools/` khác (deferred-work); kiểm tay ở Task 7 |
| Tự đổi profile GoPeak sang `full` | Không làm khi chưa hỏi tác giả (quyết định #23) |
| GitHub Actions / CI | Không làm |

### Luật kiến trúc phải theo

- **GoPeak 2.3.8, profile `compact`; Context7.** Ghim phiên bản, không `npx -y gopeak` trần. [Source: game-architecture.md#Công cụ AI (MCP), quyết định #23; project-context.md#Công nghệ và phiên bản]
- **MCP chỉ để nhìn (log, chụp màn hình) và thử (bơm input).** Luật chỉ sửa trong code, có test. Không dùng MCP sửa luật hay dữ liệu trận rồi bỏ qua test. [Source: game-architecture.md#Công cụ AI (MCP)]
- **Một autoload duy nhất (`AppState`).** Addon runtime gắn làm node con lúc chạy, không đăng ký autoload. [Source: project-context.md#Luật riêng của Godot; epics.md#Yêu cầu bổ sung]
- **`src/debug/` chứa code chỉ chạy khi bật dev.** `McpRuntime` kiểm cờ dev (khác `SaveProbe`, ngoại lệ đã ghi ở review 0.5). [Source: project-context.md#Tổ chức code]
- **Mọi script trong `tools/` chỉ dùng Godot 4.7.2 trong `.tools/`.** GoPeak nhận `GODOT_PATH` từ `_godot.sh`, không tự dò Godot khác trên máy. [Source: epics.md#Story 0.1]
- **Tài nguyên bên ngoài: ghim phiên bản, kiểm checksum** (Godot SHA-512, GUT, font, butler SHA-256). Với gói npm: `package-lock.json` có `integrity` SHA-512 cho từng gói, `npm ci` tự kiểm.
- **Preset Web** loại trừ thứ không chạy trên web: `tests/*`, `addons/gut/*`, nay thêm `addons/godot_mcp_runtime/*`. [Source: project-context.md#Nền tảng và build]
- **Gõ kiểu tĩnh mọi nơi** trong `src/` và `tests/`; `JSON.parse_string()` trả `Variant`, kiểm kiểu rồi ép. Không `print()`, dùng `Log`. Lấy node bằng code, không `/root/...`.
- **Lệnh cho tác giả nằm trong `tools/`**, chạy từ gốc repo, thông báo tiếng Việt, lỗi ra stderr bắt đầu bằng `Lỗi:`, mã thoát khác 0 là lỗi.

### Lệch so với tài liệu kiến trúc (ghi vào Completion Notes)

- game-architecture ghi "addon editor/runtime cài vào project" và "(addon của GoPeak) cài bằng script của GoPeak". Story này chỉ cài **runtime**, chép từ gói npm đã ghim, sửa 1 dòng (`127.0.0.1`), không cài addon editor. Lý do: script cài trên GitHub lấy nhánh `main` (không ghim); addon editor cần mở editor; plugin runtime tự thêm autoload thứ hai.
- Thêm thư mục `game/addons/godot_mcp_runtime/` (cây thư mục kiến trúc ghi chung là "addon của GoPeak").
- Thêm `tools/mcp/`, `tools/mcp_gopeak.sh`, `tools/mcp_context7.sh`, `.mcp.json`: mục mới so với cây thư mục kiến trúc (giống `tools/chay.sh` ở Story 0.1).
- Node.js: kiến trúc ghi "18+", thực tế cần **20.18.1+** (Context7 4.1.1 đòi `>=20.18.1`). `cai_dat.sh` kiểm đúng 20.18.1 (sau code review).
- Đề xuất (không tự sửa tài liệu): ghi vào project-context "GoPeak: chụp bằng `tools/chay.sh --dev` + `capture_screenshot`, không dùng `run_project`". Tác giả duyệt rồi mới ghi.

### Hướng dẫn cho tác giả (AI đọc lại cho tác giả ở Task 7.2)

1. AI đã chạy `tools/cai_dat.sh` và commit. Tác giả không cần gõ gì thêm ở bước này.
2. Trong ô chat Claude Code, gõ `/exit` (hoặc đóng cửa sổ). Mở lại Claude Code **trong thư mục repo** (`cd` vào `chong-nguyen-mong` rồi gõ `claude`).
3. Claude Code hỏi có dùng MCP server của project (`gopeak`, `context7`) không: chọn **đồng ý / dùng cả hai**. Chỉ hỏi một lần.
4. Gõ `! claude mcp list` (dấu `!` để chạy lệnh ngay trong ô chat). Thấy `gopeak` và `context7` đều có `✔ Connected` là đúng.
5. Gõ `/gds-dev-story` và chỉ vào story 0.6 để AI làm tiếp phần kiểm 7.3–7.8.
6. **Tự test sau khi xong:** nói với AI "chụp màn hình game" → AI gửi lại ảnh có bàn cờ, chữ DEV đỏ, nhãn phiên bản. Nói "xem log game" → AI kể lại các dòng log. Nói "tra Context7 cách dùng Tween trong Godot 4.7" → AI trích tài liệu, có ghi nguồn là bản 4.7.

### Cấu trúc file sau story

```
.mcp.json                                  # MỚI: 2 server, gọi script trong tools/
CLAUDE.md                                  # sửa: + mục "Nhìn game đang chạy (MCP)"
NEXT-STEPS.md                              # sửa: + mục "Công cụ AI (MCP)"
tools/
├── _godot.sh                              # + GOPEAK_VERSION, CONTEXT7_VERSION, MCP_DIR
├── cai_dat.sh                             # + cài MCP bằng npm ci (file khóa)
├── mcp_gopeak.sh                          # MỚI
├── mcp_context7.sh                        # MỚI
└── mcp/
    ├── package.json                       # MỚI: gopeak 2.3.8, @upstash/context7-mcp 4.1.1
    └── package-lock.json                  # MỚI
game/
├── export_presets.cfg                     # sửa: loại addons/godot_mcp_runtime/*
├── addons/godot_mcp_runtime/
│   ├── mcp_runtime_autoload.gd            # MỚI: chép từ gopeak 2.3.8, sửa 1 dòng
│   └── LICENSE                            # MỚI: MIT của GoPeak
├── src/app/main.gd                        # sửa: gọi McpRuntime
├── src/debug/mcp_runtime.gd               # MỚI
└── tests/
    ├── test_mcp_runtime.gd                # MỚI
    ├── test_mcp_config.gd                 # MỚI
    └── test_export_preset.gd              # sửa
```

Kèm các file `.uid` do Godot sinh (commit cả `.uid` như các story trước). Addon runtime có thể sinh `mcp_runtime_autoload.gd.uid`: commit cùng.

### Testing

- Test GUT mới: `test_mcp_runtime.gd`, `test_mcp_config.gd`; sửa `test_export_preset.gd`. Chạy không cần màn hình; **không** mở cổng 7777 (GUT chạy headless, `should_start` trả `false`).
- `cai_dat.sh`, `mcp_gopeak.sh`, `mcp_context7.sh` không có test tự động; kiểm tay ở Task 3.4 và 7.1, ghi Debug Log.
- Phần chụp màn hình, log, Context7 (AC 3–6) chỉ kiểm được ở phiên Claude Code mới sau khi tác giả duyệt server.
- **Hướng dẫn tác giả tự test** (ghi vào Completion Notes): bước 4 và 6 của "Hướng dẫn cho tác giả", cộng `tools/test.sh` → `✅ N/N test đạt`.

### Previous Story Intelligence (Story 0.5 và review)

- Script `tools/` theo mẫu: chú thích đầu file tiếng Việt, `set -euo pipefail`, source `_godot.sh`, tên biến/hàm tiếng Việt không dấu, lỗi ra stderr bắt đầu bằng `Lỗi:`, mỗi công cụ có `.installed` riêng để chạy lại không cài lại.
- Lệnh tương tác không chạy được trong ô chat (`butler login`: "stdin is not a terminal") → việc cần tác giả làm thì ghi rõ từng bước, dùng `! lệnh` khi được.
- "Chống xanh giả": Godot có thể thoát 0 mà vẫn lỗi; `test.sh` đọc log tìm `SCRIPT ERROR|Parse Error`. File addon mới bị quét trong bước `--import`: phải không có lỗi.
- Trạng thái toàn cục sống qua các file test (`Log`, `InputMap`, `TranslationServer`): test mới không để lại node hay trạng thái (dùng `autofree`/`add_child_autofree` của GUT cho node cha giả).
- Thử nghiệm làm trên bản sao tạm hoặc thư mục scratchpad, không trên repo thật; thử xong thì dọn (ví dụ tắt server, `kill` tiến trình nền, `pkill -f "http.server 8765"`).
- Commit sau mỗi lần `test.sh` xanh, lời commit tiếng Việt, kết thúc bằng dòng `Co-Authored-By` của phiên.
- Story 0.5 để lại: `SaveProbe` là ngoại lệ chạy không cần dev (đừng "sửa" nó ở story này).

### Git Intelligence

- 5 commit gần nhất:
  - `a557bd4 Sửa theo code review Story 0.5` (baseline của story này)
  - `ebd46e2 Đưa bản web lên itch.io riêng tư, ghi kết quả thử (Story 0.5)`
  - `4d60947 Thử lưu user:// luôn ghi log, cả khi không bật dev (Story 0.5)`
  - `c9cc5a6 Điền trang itch.io tuantrunglc/hao-khi-dong-a`
  - `54fffe0 Thêm build web, butler và lệnh đẩy lên itch.io (Story 0.5, phần trên máy)`
- Mẫu chia commit của 0.5: phần làm trên máy một commit, phần kiểm cùng tác giả một commit. Story này cũng vậy (trước và sau khi mở lại Claude Code).

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- Godot **4.7.2.stable**, GUT **v9.7.1**, GoPeak **2.3.8** profile `compact`, Context7 để tra API Godot 4.7 trước khi dùng API lạ. Không tự nâng phiên bản.
- `app_state.gd` là **autoload duy nhất**; `Log` là lớp static.
- `src/debug/` chỉ chạy khi bật dev. Không `print()` trong `src/`.
- Gõ kiểu tĩnh mọi nơi; `untyped_declaration` là error (trừ `addons/`).
- Web đơn luồng; preset loại trừ thứ không dùng trên web.
- "Xong" nghĩa là `tools/test.sh` xanh rồi commit. Lời commit tiếng Việt. Không `push --force`.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được: các bước để thử, thấy gì là đúng.

### Câu hỏi cho tác giả (hỏi ở Task 0)

1. **Context7 có dùng API key không?** Không có key vẫn tra được nhưng bị giới hạn số lượt. Có key (đăng ký miễn phí ở context7.com) thì tra nhiều hơn; key đặt trong biến môi trường của máy, không ghi vào repo. Đề xuất: **chưa cần key**, khi nào bị chặn lượt thì thêm.
2. **Cho AI tự bơm input (bấm chuột, bấm phím) vào game đang chạy khi bật dev không?** Đây là một phần của GoPeak (nhóm `testing`), giúp AI tự thử thao tác ở E1 trở đi. Đề xuất: **cho phép** (chỉ trên máy tác giả, chỉ khi `--dev`, chỉ để thử; luật vẫn kiểm bằng test).
3. **Phiên bản Context7:** ghim **4.1.1** (bản đã ra hơn 2 tuần) thay vì 4.4.2 mới nhất (ra 3 ngày trước). Đồng ý không?

### Quyết định của tác giả

Hỏi ngày 2026-10-18:

1. Context7: **chưa cần API key**. Khi bị chặn lượt thì thêm key vào biến môi trường máy (không ghi vào repo).
2. Bơm input: **cho phép** (chỉ máy tác giả, chỉ khi `--dev`, chỉ để thử).
3. Phiên bản Context7: **ghim 4.1.1**.

### References

- `_bmad-output/planning-artifacts/epics.md#Story 0.6`; #Yêu cầu bổ sung (MCP, một autoload)
- `_bmad-output/planning-artifacts/game-architecture.md`: #Công cụ AI (MCP); quyết định #23; #Cây thư mục (`addons/`); #Môi trường phát triển (Node.js 18+, bảng MCP)
- `_bmad-output/project-context.md`: #Công nghệ và phiên bản, #Luật riêng của Godot, #Tổ chức code
- `_bmad-output/implementation-artifacts/0-5-ban-web-tren-itch-io-rieng-tu.md`: Debug Log, Review Findings
- `_bmad-output/implementation-artifacts/deferred-work.md`: các mục test script `tools/`
- `_bmad-output/planning-artifacts/implementation-readiness-report-2026-10-17.md`: vấn đề 🟡-8 (thứ tự story 0.6)
- GoPeak: `https://www.npmjs.com/package/gopeak` (2.3.8), `https://github.com/HaD0Yun/Gopeak-godot-mcp`; mã đã đọc: `build/index.js` (`handleRunProject`, `handleRuntimeCommand`), `build/tool-groups.js`, `build/addon/godot_mcp_runtime/mcp_runtime_autoload.gd`
- Context7: `https://www.npmjs.com/package/@upstash/context7-mcp` (4.1.1); `https://context7.com/api/v1/search?query=godot`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (`claude-opus-5-5`)

### Debug Log References

**Phiên 1 (2026-10-18), làm trên máy, trước khi mở lại Claude Code:**

- Task 0: tác giả chốt 3 câu (xem "Quyết định của tác giả").
- 1.2: file khóa sinh trong scratchpad bằng `npm install --package-lock-only --ignore-scripts` (Node v26.8.1): 134 mục `packages`; `gopeak` 2.3.8 và `@upstash/context7-mcp` 4.1.1 đều có `integrity` sha512.
- 7.1 `tools/cai_dat.sh`: lần 1 `added 133 packages in 3s` → `Đã cài GoPeak 2.3.8 và Context7 4.1.1`, mã 0. Lần 2: in `Đã cài Godot 4.7.2` / `Đã cài butler 15.32.0` / `Đã cài GoPeak 2.3.8 và Context7 4.1.1`, không cài lại, mã 0.
- 7.1 kiểm Node (bản sao hàm `kiem_node` trong scratchpad, chạy bằng `/bin/bash` 3.2): `PATH` không có node → lỗi tiếng Việt, mã 1; node giả 20.17.9 → lỗi, mã 1; 18.0.0 → lỗi, mã 1; 20.18.1 → đạt.
- 3.4 gửi `initialize` vào stdin: `tools/mcp_gopeak.sh` trả `{"result":{..."serverInfo":{"name":"gopeak","version":"2.3.8"}}...}`; `tools/mcp_context7.sh` trả `{"result":{..."serverInfo":{"name":"Context7","version":"4.1.1"...`. Không có chữ lạ trước JSON; mọi chữ khác ra stderr. Ghi chú: GoPeak tự mở thêm cầu nối editor ở `127.0.0.1:6505` (chỉ máy này; không dùng vì không mở editor).
- 3.3 `.mcp.json` dùng `"command": "tools/mcp_gopeak.sh"` (đường tương đối). `claude mcp list` từ gốc repo đã thấy `gopeak: tools/mcp_gopeak.sh - ⏸ Pending approval` và `context7` tương tự → Claude Code đọc được file, chờ tác giả duyệt.
- 4.1–4.2: file gốc trong gói dùng xuống dòng CRLF; bản chép giữ nguyên CRLF, `diff` với bản gốc chỉ khác dòng 65 (thêm chú thích + `listen(_port, "127.0.0.1")`). Bước quét `--import` của `test.sh` không báo lỗi cho file này. Godot sinh `mcp_runtime_autoload.gd.uid`.
- 5.1 RED: `tools/test.sh` trượt: `test_excludes_gopeak_runtime` trượt + `Identifier "McpRuntime" not declared` trong `test_mcp_runtime.gd`. GREEN sau 4.3–4.5: **77/77 đạt**. Thêm 13 test: 6 `test_mcp_runtime`, 6 `test_mcp_config`, 1 `test_export_preset`. Trước story là 64 (story ghi 62; review Story 0.5 đã thêm test).
- 5.5 `test_main.gd` không cần sửa: GUT headless → `should_start` false → không thêm con, không mở cổng.
- Thử thật (trước 7.3): `tools/chay.sh --dev` nền → log `[INFO][app] dev=1`, `[INFO][luu_thu] lần mở thứ 1, user:// bền: true`, `[MCP Runtime] Server listening on port 7777`, `[INFO][mcp] mở cổng 7777 cho GoPeak (chỉ máy này)`. Gửi thẳng lệnh `capture_screenshot` qua TCP (Python, giống cách GoPeak gửi) → `{"type":"screenshot_file","width":1280,"height":720,...}`; ảnh đúng: tiêu đề "Hào Khí Đông A", bàn 7×7, "DEV · lần mở thứ 1" đỏ góc trên trái, `v0.1.0 · a557bd4-sua` góc dưới phải. `inject_mouse_click` với `position: [640, 380]` → `input_injected` (dạng `{"x","y"}` bị từ chối: "position must be Vector2 or [x, y]").
- 7.6: khi `--dev`: `lsof -nP -iTCP:7777 -sTCP:LISTEN` → `TCP 127.0.0.1:7777 (LISTEN)`. Không `--dev`: không có cổng 7777, log không có dòng `[INFO][mcp]`.
- 7.7: `tools/build_web.sh` đạt, bản nén 10.4 MB (không đổi). `strings build/web/index.pck | grep -c godot_mcp` → 0; chuỗi "MCP Runtime"/`_start_server`/`inject_mouse` → 0. Chỉ có `src/debug/mcp_runtime.gd` (file bọc, trên web `should_start` trả false). `addons/gut` → 0.
- 7.2: đã commit `ce32126` (77/77 xanh). **Dừng ở đây chờ tác giả** mở lại Claude Code và duyệt 2 server. Phiên sau: làm 7.2 (kiểm `claude mcp list` ✔ Connected) → 7.3 → 7.4 → 7.5 → 7.8.

**Phiên 2 (2026-10-18), sau khi tác giả mở lại Claude Code và duyệt 2 server:**

- 7.2: tác giả gõ `claude mcp list` → `gopeak: tools/mcp_gopeak.sh - ✔ Connected`, `context7: tools/mcp_context7.sh - ✔ Connected`.
- 7.3: `tools/chay.sh --dev` nền. Profile `compact` không có `capture_screenshot`; gọi `tool_catalog` với `query: "screenshot"` → `newlyActivated: ["testing"]`. Claude Code thấy ngay công cụ mới (tên `mcp__gopeak__capture-screenshot`, phải nạp qua ToolSearch), không cần khởi động lại, không đổi profile. Ảnh 1280×720: tiêu đề "Hào Khí Đông A", bàn 7×7 màu be viền nâu, "DEV · lần mở thứ 3" đỏ góc trên trái, `v0.1.0 · c60d7c3` góc dưới phải. Đạt AC 4.
- 7.4: log đọc từ đầu ra lệnh nền: `[INFO][app] dev=1`, `[INFO][luu_thu] lần mở thứ 3, user:// bền: true`, `[INFO][mcp] mở cổng 7777 cho GoPeak (chỉ máy này)`, kèm `[MCP Runtime] Client connected/disconnected` mỗi lần GoPeak gọi. `inject_mouse_click` qua GoPeak (`x: 640, y: 380`, công cụ nhận `x`/`y` riêng, server tự đổi sang `[x, y]`) → `input_injected`, game không báo lỗi. Đạt AC 5.
- 7.5: `resolve-library-id` "Godot" → `/godotengine/godot-docs` (45 772 đoạn, bản `__branch__4.5`, `__branch__4.7`). ID dùng được: **`/godotengine/godot-docs/__branch__4.7`**. Tra "Tween create_tween/tween_property" → trích `class_tween.rst` và `class_node.rst`, nguồn ghi `github.com/godotengine/godot-docs/blob/4.7/...`. Không cần API key. Đạt AC 6.
- Tắt game bằng `pkill` (mã 143 là do tắt, không phải lỗi). `tools/test.sh` lại: 77/77 đạt.

**Sửa theo code review (2026-10-18):**

- RED: thêm/sửa test trước → `Too many arguments for "should_start()"` (test 4 tham số). GREEN: **80/80 đạt** (thêm `test_release_build_never_starts_even_with_dev`, `test_package_lock_root_matches_package_json`, `test_godot_sh_versions_match_pinned`; bảng chân trị viết thẳng tổ hợp duy nhất được mở).
- `should_start` thêm `is_debug` (`OS.is_debug_build()`): bản phát hành không mở cổng. `chay.sh` dùng Godot editor (debug) nên vẫn mở.
- Mở game 2 lần `--dev`: cửa sổ 1 `[INFO][mcp] mở cổng 7777`; cửa sổ 2 `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` rồi `[WARN][mcp] không mở được cổng 7777 (có game khác đang mở?)...`, node addon bị gỡ. `lsof` chỉ thấy 1 tiến trình ở `127.0.0.1:7777`. Chụp qua GoPeak ra cửa sổ 1 ("lần mở thứ 4").
- `sha256` chuyển sang `_godot.sh`; thêm `ma_cai_mcp` (băm `package.json` + file khóa). Dấu cũ → `tools/mcp_gopeak.sh` báo `Lỗi: công cụ AI đã cài là bản cũ ...`, mã 1. `cai_dat.sh` lần 1 cài lại (`added 133 packages`), lần 2 in `Đã cài ...` cả 3 phần. Gửi `initialize` vào 2 script: trả JSON đúng.
- `kiem_node` (bản sao, `/bin/bash` 3.2, node giả): 20.17.9 lỗi, **20.18.0 lỗi**, 20.18.1/22.0.0/26.8.1 đạt; có node thiếu npm → `Lỗi: có Node.js nhưng thiếu npm ...`; không node → lỗi, mã 1.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Đạt AC 1–9. GoPeak 2.3.8 và Context7 4.1.1 ghim bằng `tools/mcp/package-lock.json`, cài vào `.tools/mcp/` bằng `tools/cai_dat.sh`; `.mcp.json` chỉ gọi script trong `tools/`.
- Addon runtime GoPeak chép từ gói npm đã ghim, sửa 1 dòng để chỉ nghe `127.0.0.1`; chỉ bật khi dev + desktop + có cửa sổ (`game/src/debug/mcp_runtime.gd`), không thêm autoload, không có trong bản web.
- Cách AI chụp màn hình (đã ghi trong `CLAUDE.md`): `tools/chay.sh --dev` nền → `tool_catalog` "screenshot" → `capture_screenshot`. Không dùng `run_project` (chạy headless).
- Lệch kiến trúc: xem mục "Lệch so với tài liệu kiến trúc" ở Dev Notes (chỉ cài runtime, không cài addon editor; thêm `tools/mcp/`, 2 script, `.mcp.json`). Đề xuất ghi vào project-context quy tắc chụp bằng `chay.sh --dev`: chờ tác giả duyệt.
- Test: 80 (thêm 16 so với 64 trước story; 3 test thêm sau code review).
- Sau code review: bản phát hành không bao giờ mở cổng 7777 (tác giả chọn); mở game 2 lần thì cửa sổ sau báo `[WARN][mcp]`; script MCP từ chối chạy bản cài cũ; Node cần 20.18.1+.
- **Tác giả tự test:** mở Claude Code trong thư mục repo, nói "chụp màn hình game" → AI gửi ảnh có bàn cờ, chữ DEV đỏ, nhãn phiên bản. Nói "xem log game" → AI kể các dòng `[INFO][...]`, có dòng `[INFO][mcp] mở cổng 7777`. Nói "tra Context7 cách dùng Tween trong Godot 4.7" → AI trích tài liệu, nguồn có `blob/4.7`.

### File List

- `.mcp.json` (mới)
- `CLAUDE.md`
- `NEXT-STEPS.md`
- `tools/_godot.sh`
- `tools/cai_dat.sh`
- `tools/mcp_gopeak.sh` (mới)
- `tools/mcp_context7.sh` (mới)
- `tools/mcp/package.json` (mới)
- `tools/mcp/package-lock.json` (mới)
- `game/addons/godot_mcp_runtime/mcp_runtime_autoload.gd` (mới, chép từ gopeak 2.3.8, sửa 1 dòng)
- `game/addons/godot_mcp_runtime/mcp_runtime_autoload.gd.uid` (mới)
- `game/addons/godot_mcp_runtime/LICENSE` (mới)
- `game/src/debug/mcp_runtime.gd` (mới)
- `game/src/debug/mcp_runtime.gd.uid` (mới)
- `game/src/app/main.gd`
- `game/export_presets.cfg`
- `game/tests/test_mcp_runtime.gd` (mới)
- `game/tests/test_mcp_runtime.gd.uid` (mới)
- `game/tests/test_mcp_config.gd` (mới)
- `game/tests/test_mcp_config.gd.uid` (mới)
- `game/tests/test_export_preset.gd`
- `_bmad-output/implementation-artifacts/0-6-cai-cong-cu-ai-mcp.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-18: Phần trên máy (Task 0–6, 7.1, 7.6, 7.7): ghim GoPeak 2.3.8 + Context7 4.1.1, `cai_dat.sh` cài MCP, `.mcp.json`, addon runtime chỉ nghe `127.0.0.1`, 13 test mới (tổng 77).
- 2026-10-18: Kiểm cùng tác giả (7.2–7.5): 2 server ✔ Connected, chụp màn hình qua GoPeak, đọc log, bơm click, tra Context7 `/godotengine/godot-docs/__branch__4.7`. Chuyển sang review.
- 2026-10-18: Sửa theo code review: chặn bản phát hành (`OS.is_debug_build()`), báo cổng bận, kiểm null khi nạp addon, Node 20.18.1+ và báo thiếu npm, script MCP kiểm bản cài khớp `tools/mcp/`, sửa `CLAUDE.md` (tọa độ `x`/`y`, ID Context7). 3 test mới (tổng 80). 4 mục hoãn vào `deferred-work.md`. Story xong.
