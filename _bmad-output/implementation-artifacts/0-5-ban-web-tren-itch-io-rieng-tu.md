---
baseline_commit: 27b40d8
---

# Story 0.5: Bản web trên itch.io (riêng tư)

Status: in-progress

## Story

Là tác giả,
tôi muốn mở game qua một đường link,
để thấy game của mình thật sự có mặt trên mạng.

## Acceptance Criteria

1. **Việc tác giả tự làm** (AI hướng dẫn từng bước, không làm thay được):
   1. Tạo tài khoản itch.io (nếu chưa có).
   2. Tạo trang game, để chế độ **riêng tư** (Draft).
   3. Chạy `tools/cai_dat.sh` (cài thêm `butler`), rồi `tools/dang_nhap_itch.sh` **một lần** (mở trình duyệt để đăng nhập).
2. **Khi** gõ `tools/build_web.sh`, **thì**:
   - `build/web/` được tạo ra, có `index.html`;
   - script in dung lượng bản nén (MB);
   - script **báo trượt** (mã thoát khác 0) nếu bản nén vượt 25 MB.
3. **Khi** gõ `tools/deploy_itch.sh`, **thì** bản build được đẩy lên itch.io, trang vẫn ở chế độ **riêng tư**, và script in ra đường link.
4. **Khi** mở link trên Chrome, Firefox và Edge, **thì** cả 3 trình duyệt đều hiện:
   - bàn cờ trống;
   - tiêu đề tiếng Việt đủ dấu (không phải `app.title`), kể cả trình duyệt đặt ngôn ngữ tiếng Anh;
   - phiên bản và mã commit ở góc dưới phải, khớp commit đã build.
5. **Khi** game ghi một file thử vào `user://` rồi tải lại trang, **thì** file vẫn còn khi chạy trong iframe của itch.io (kiểm lúc bật dev).
6. **Và** dung lượng tải và thời gian tải lần đầu được ghi vào `NEXT-STEPS.md` (số đo NFR2 ban đầu). Thời gian tải đo bằng DevTools của Chrome, giới hạn mạng 20 Mbps, xóa bộ nhớ đệm trước khi đo.
7. **Và** preset export có filter `*.json`, loại trừ `tests/*` và `addons/gut/*`, xuất **đơn luồng**. `tools/test.sh` có test kiểm các điều này.
8. **Và** `tools/test.sh` xanh.

## Tasks / Subtasks

- [x] **Task 0: Hỏi tác giả trước khi làm** (AC: 1, 3, 5)
  - [x] 0.1 Hỏi các câu ở mục "Câu hỏi cho tác giả" (cuối Dev Notes). Ghi câu trả lời vào mục "Quyết định của tác giả". Chưa có tên tài khoản và tên trang itch.io thì vẫn làm được Task 1–4 và 6; Task 5 chờ.

- [x] **Task 1: Preset export Web** (AC: 2, 4, 7)
  - [x] 1.1 Tạo `game/export_presets.cfg`, viết tay. Mẫu đã chạy được trên Godot 4.7.2 (kiểm 2026-10-17, xem Ghi chú kỹ thuật):
    ```
    [preset.0]

    name="Web"
    platform="Web"
    runnable=true
    export_filter="all_resources"
    include_filter="*.json, assets/fonts/OFL.txt"
    exclude_filter="tests/*, addons/gut/*"
    export_path="../build/web/index.html"

    [preset.0.options]

    variant/extensions_support=false
    variant/thread_support=false
    vram_texture_compression/for_desktop=true
    vram_texture_compression/for_mobile=false
    html/canvas_resize_policy=2
    progressive_web_app/enabled=false
    ```
    - `variant/thread_support=false`: **đơn luồng** (template `web_nothreads_release.zip`). Không cần SharedArrayBuffer hay header COOP/COEP trên itch.io.
    - `include_filter`: `*.json` để có `build_info.json` (và sau này `data/*.json`); `assets/fonts/OFL.txt` để giấy phép font đi kèm (mục hoãn từ Story 0.4).
    - Chỉ có preset Web. Preset Windows để giai đoạn 2.
  - [x] 1.2 Commit `export_presets.cfg`. Kiểm `.gitignore` không bỏ qua file này (hiện không bỏ).
  - [x] 1.3 Không cần mở editor. Lệnh `--export-release` không viết lại file preset (đã kiểm).

- [x] **Task 2: `tools/build_web.sh`** (AC: 2, 4)
  - [x] 2.1 Đầu script: `source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"`, `set -euo pipefail`, chú thích đầu file tiếng Việt như các script khác.
  - [x] 2.2 Ghi `game/build_info.json` y như `tools/chay.sh` (mã commit, thêm `-sua` nếu cây có thay đổi chưa commit). **Chuyển đoạn này thành hàm `ghi_build_info` trong `tools/_godot.sh`** và cho cả `chay.sh` lẫn `build_web.sh` gọi, để chỉ có một chỗ.
  - [x] 2.3 Kiểm có export template web: `"$GODOT_DATA_DIR/export_templates/4.7.2.stable/web_nothreads_release.zip"`. Thiếu thì in `Lỗi: chưa có export template web. Chạy tools/cai_dat.sh.` và thoát 1.
  - [x] 2.4 Quét project trước (`--headless --path game --import`), giống bước 3 của `tools/test.sh`: repo vừa clone thì lần quét đầu có lỗi oan, nên quét lại một lần nếu log có `SCRIPT ERROR|Parse Error`. Lần hai còn lỗi thì báo trượt, in 10 dòng lỗi đầu, thoát 1.
  - [x] 2.5 Xóa và tạo lại `build/web/`. Chạy `"$GODOT" --headless --path "$REPO_ROOT/game" --export-release "Web" "$REPO_ROOT/build/web/index.html"`, log vào `build/web_export.log`. Mã khác 0, hoặc thiếu `build/web/index.html` / `index.wasm` / `index.pck`, thì báo trượt kèm đường dẫn log.
    - Log export có dòng `ERROR` thì cũng báo trượt (Godot có thể thoát 0 mà vẫn lỗi; cùng lý do "chống xanh giả" ở `test.sh`).
  - [x] 2.6 Chép `game/assets/fonts/OFL.txt` vào `build/web/OFL.txt` (giấy phép đi kèm bản phát hành, ai mở thư mục cũng thấy).
  - [x] 2.7 Đo bản nén: `(cd build/web && zip -qr -9 ../web.zip .)`, lấy dung lượng `build/web.zip`. In:
    - `Dung lượng bản nén: 10.4 MB (giới hạn 25 MB)` (1 MB = 1 000 000 byte, một chữ số thập phân);
    - kèm dung lượng chưa nén của `build/web/`.
    - Vượt 25 000 000 byte thì in `❌ trượt: bản nén vượt 25 MB` và thoát 1.
  - [x] 2.8 Dòng cuối khi đạt: `✅ Đã build bản web vào build/web/ (v<phiên bản> · <commit>)`. Lấy phiên bản bằng `grep` dòng `config/version` trong `game/project.godot`.
  - [x] 2.9 Không thêm `build_web.sh` vào `tools/test.sh` (chậm, cần template). `test.sh` chỉ kiểm preset (Task 6).

- [x] **Task 3: Cài `butler`** (AC: 1)
  - [x] 3.1 Thêm vào `tools/_godot.sh`: `BUTLER_VERSION="15.32.0"`, `BUTLER_DIR="$REPO_ROOT/.tools/butler-$BUTLER_VERSION"`, `BUTLER="$BUTLER_DIR/butler"`. Cập nhật dòng chú thích "Biến đặt ra".
  - [x] 3.2 Sửa `tools/cai_dat.sh`:
    - **Hiện script thoát sớm** (`exit 0`) khi Godot đã cài. Phải đổi để phần butler vẫn chạy: tách thành hai khối "cài Godot nếu chưa có" và "cài butler nếu chưa có".
    - Chạy lại khi đã có cả hai thì in `Đã cài Godot 4.7.2` và `Đã cài butler 15.32.0`, không tải gì.
    - Xóa dòng `# butler: thêm ở Story 0.5`.
  - [x] 3.3 Tải `https://broth.itch.zone/butler/<nền tảng>/15.32.0/archive/default` (file zip), **ghim phiên bản** và kiểm SHA-256 trước khi giải nén. Đã tải và đo 2026-10-17:

    | Nền tảng (`GODOT_OS` + `uname -m`) | `<nền tảng>` | SHA-256 | Dung lượng |
    |---|---|---|---|
    | macOS arm64 (máy tác giả) | `darwin-arm64` | `f1c460f08c02686b49f8da74344e5578ece9ea1a8bae1779445b5d98e0a794b3` | 10 041 882 byte |
    | macOS x86_64 | `darwin-amd64` | `a92947c9556c9bfb0cc9bdc3814f342b30e0ee7269efc418658894a916ca9584` | 10 981 715 byte |
    | Linux x86_64 | `linux-amd64` | `2335971394ef6596f95ded0833e85ee28755e13761716ef4c91d6b11f69162f5` | 10 734 695 byte |

    SHA khác thì xóa file, in lỗi tiếng Việt và thoát 1 (giống `kiem_tra` hiện có, nhưng dùng SHA-256 ghi cứng trong script vì broth không có file SHA-512).
  - [x] 3.4 Zip gồm 3 file: `butler`, `7z.so`, `libc7zip.dylib` (macOS). Giải nén **cả ba** vào `$BUTLER_DIR`, `chmod +x butler`. Trên macOS gỡ `com.apple.quarantine` như với Godot (`|| true`). Kiểm `"$BUTLER" --version` có chứa `v15.32.0`.
  - [x] 3.5 Dùng lại hàm `tai` có sẵn được thì dùng (nó ghép `$BASE_URL` của Godot, nên cần thêm tham số URL hoặc viết hàm `tai_url`). Giữ cách tải tiếp phần dở (`-C -`).

- [x] **Task 4: Đăng nhập và đẩy lên itch.io** (AC: 1, 3)
  - [x] 4.1 Tạo `tools/itch.cfg` (commit), một dòng: `ITCH_TARGET=<tài khoản>/<tên trang>` theo câu trả lời Task 0. Chú thích đầu file nói tác giả sửa dòng này khi đổi trang.
  - [x] 4.2 Tạo `tools/dang_nhap_itch.sh`: kiểm `$BUTLER` đã cài (chưa thì bảo chạy `tools/cai_dat.sh`), rồi chạy `"$BUTLER" login`. butler mở trình duyệt để tác giả bấm đồng ý, sau đó lưu khóa trên máy (ngoài repo). In câu tiếng Việt giải thích trước khi chạy.
  - [x] 4.3 Tạo `tools/deploy_itch.sh`:
    1. Đọc `ITCH_TARGET` từ `tools/itch.cfg`. Rỗng hoặc vẫn là chữ mẫu thì báo lỗi tiếng Việt, thoát 1.
    2. Thiếu `build/web/index.html` thì in `Chưa có bản build. Chạy tools/build_web.sh trước.`, thoát 1.
    3. Đọc mã commit từ `game/build_info.json`. Có đuôi `-sua` thì in cảnh báo "bản này có thay đổi chưa commit" (vẫn đẩy).
    4. `"$BUTLER" push "$REPO_ROOT/build/web" "$ITCH_TARGET:html5" --userversion "<phiên bản>-<commit>"`. Kênh tên `html5`.
    5. Lỗi chưa đăng nhập thì in gợi ý chạy `tools/dang_nhap_itch.sh`.
    6. **Kiểm riêng tư:** `curl -s -o /dev/null -w '%{http_code}' https://<tài khoản>.itch.io/<tên trang>` không kèm đăng nhập. Mã `404` nghĩa là trang đang Draft (người lạ không xem được) → in `🔒 Trang đang riêng tư`. Mã khác thì in cảnh báo lớn `⚠️ Trang có thể đang CÔNG KHAI`, kèm hướng dẫn chuyển về Draft. **Phải kiểm thật** hành vi này (Draft trả 404) khi làm, ghi vào Debug Log; nếu khác thì sửa cách kiểm và ghi lại.
    7. In đường link `https://<tài khoản>.itch.io/<tên trang>` và nhắc: trang Draft chỉ xem được khi đã đăng nhập itch.io bằng tài khoản của tác giả.
  - [x] 4.4 Không bao giờ đổi trang sang công khai bằng script. butler không đổi chế độ hiển thị của trang; giữ như vậy.

- [x] **Task 5: Thử lưu `user://` trong iframe** (AC: 5)
  - [x] 5.1 Tạo `game/src/debug/save_probe.gd` (`class_name SaveProbe`, `extends RefCounted`). Hàm static `bump(path: String) -> int`:
    - đọc file JSON `{"so_lan_mo": N}` ở `path` (thiếu hoặc hỏng thì coi N = 0, dùng `JSON.new().parse()` như `BuildInfo` để không in ERROR);
    - ghi lại `N + 1`, trả về `N + 1`;
    - ép kiểu tường minh, `int()` giá trị đọc được (JSON trả `float`).
  - [x] 5.2 Hằng đường dẫn thật: `user://thu_luu.json`. Không dùng `user://save.json` (để dành cho lưu game thật ở E4).
  - [x] 5.3 Gọi ở đâu và hiện thế nào: **theo câu trả lời câu hỏi 3**. Mặc định đề xuất:
    - `DevTools.setup(true)` gọi `SaveProbe.bump(...)`; chữ DEV đổi thành `DEV · lần mở thứ N`;
    - ghi `Log.info("luu_thu", "lần mở thứ %d, user:// bền: %s" % [n, OS.is_userfs_persistent()])` (cũng chỉ khi bật dev).
    - Tải lại trang mà N tăng lên là đạt AC 5. N luôn là 1 là `user://` không bền.
  - [x] 5.4 Không bật dev thì không ghi file nào.

- [x] **Task 6: Test** (AC: 7, 8)
  - [x] 6.1 `game/tests/test_export_preset.gd`: đọc `res://export_presets.cfg` bằng `ConfigFile` (file nằm trong `game/`, đọc được ở chế độ headless). Kiểm:
    - có đúng một preset `platform="Web"`, tên `Web`;
    - `include_filter` chứa `*.json`;
    - `exclude_filter` chứa `tests/*` và `addons/gut/*`;
    - `[preset.0.options] variant/thread_support == false`;
    - `export_path` là `../build/web/index.html`.
  - [x] 6.2 `game/tests/test_save_probe.gd`: dùng thư mục `user://test_save_probe/` (tạo ở `before_each`, xóa ở `after_each`, theo mẫu `test_build_info.gd`):
    - chưa có file → `bump` trả 1;
    - gọi hai lần → trả 2;
    - file hỏng (`{so_lan_mo:`) → trả 1, không in ERROR;
    - file có `so_lan_mo` là chuỗi → trả 1.
  - [x] 6.3 Sửa `test_dev_tools.gd` nếu chữ DEV đổi (Task 5.3). Test DevTools phải dùng đường dẫn thử, **không** ghi vào `user://thu_luu.json` thật: cho `setup()` nhận đường dẫn file probe làm tham số tùy chọn, hoặc hằng có thể ghi đè trong test.
  - [x] 6.4 Mỗi test có ít nhất một assert.

- [x] **Task 7: Kiểm trên máy (AI làm)** (AC: 2, 4, 7)
  - [x] 7.1 Viết test trước (Task 6), chạy `tools/test.sh`, thấy **trượt**. Ghi vào Debug Log.
  - [x] 7.2 Làm Task 1–5 tới khi `tools/test.sh` **xanh**. Hiện có 50 test; ghi số thật.
  - [x] 7.3 Chạy `tools/build_web.sh`. Ghi dung lượng bản nén vào Debug Log (dự kiến khoảng 10.4 MB).
  - [x] 7.4 Thử trượt 25 MB trên **bản sao tạm**: tạm hạ giới hạn (hoặc thêm một file lớn vào `build/web/` trước bước đo) → script thoát 1 và in câu trượt. Ghi lại.
  - [x] 7.5 Mở bản build bằng Chrome headless trên máy (cách ở Ghi chú kỹ thuật), có `?dev=1`, `--lang=en-US`. Đọc ảnh: bàn cờ, tiêu đề tiếng Việt, DEV, phiên bản và commit.
  - [x] 7.6 Chạy lại `tools/cai_dat.sh` khi đã cài đủ: không tải lại gì. Trên bản sao `.tools/` tạm (hoặc xóa riêng thư mục butler) thì cài butler được và kiểm SHA đúng.

- [ ] **Task 8: Cùng tác giả đưa lên itch.io** (AC: 1, 3, 4, 5, 6)
  - [ ] 8.1 Hướng dẫn tác giả từng bước AC 1 (xem "Hướng dẫn cho tác giả" ở Dev Notes). Chờ tác giả làm xong.
  - [ ] 8.2 Chạy `tools/deploy_itch.sh`. Lần đẩy **đầu tiên**, tác giả phải vào trang Edit game, ở file `html5` vừa đẩy, tích **"This file will be played in the browser"** và đặt Embed options (xem hướng dẫn). Sau đó các lần đẩy sau tự dùng lại.
  - [ ] 8.3 Tác giả mở link trên Chrome, Firefox, Edge. Ghi kết quả từng trình duyệt vào Debug Log (AC 4). Ít nhất một trình duyệt đặt ngôn ngữ tiếng Anh.
  - [ ] 8.4 Thử dev trên itch.io (mục hoãn từ Story 0.3), ghi cách nào chạy được:
    1. link trang + `?dev=1`;
    2. mở thẳng địa chỉ iframe (chuột phải vào game → mở khung trong tab mới, hoặc lấy `src` của iframe) + `?dev=1`.
    - Cách 2 chạy ngoài iframe của itch, nên **không** chứng minh được AC 5. Nếu chỉ cách 2 chạy được, báo tác giả và hỏi lại câu 3 (ghi probe ra console cả khi không bật dev).
  - [ ] 8.5 AC 5: bật dev được trong iframe thì tải lại trang 2 lần, số "lần mở thứ N" phải tăng. Thử trên Chrome và Firefox. Ghi lại.
  - [ ] 8.6 Khi bật dev trên web, thử F1 và F5 (mục hoãn từ Story 0.3): trình duyệt có chiếm phím không (F1 mở trợ giúp, F5 tải lại trang). **Chỉ ghi lại**, không sửa; sửa ở Story 1.6 nếu cần.
  - [ ] 8.7 AC 6: tác giả đo theo hướng dẫn, AI ghi vào `NEXT-STEPS.md` một mục mới "Số đo bản web (NFR2)": ngày, commit, dung lượng bản nén, dung lượng tải thật (cột Transferred của DevTools), thời gian tải tới khi hiện bàn cờ. Vượt 10 giây thì ghi rõ và báo tác giả; **không** tự tối ưu (E4 đo đủ).
  - [ ] 8.8 Commit khi `tools/test.sh` xanh. Lời commit gợi ý: `Thêm build web, butler và đẩy lên itch.io riêng tư (Story 0.5)`. Chuyển story sang `review`.

## Dev Notes

### Bối cảnh

- Story 0.1–0.4 đã xong. Màn hình chính có tiêu đề, bàn cờ 7×7, nhãn phiên bản `v0.1.0 · <commit>`, chữ DEV khi bật dev.
- `LaunchOptions.read_current()` đã đọc `window.location.search` trên web (Story 0.3), **chưa từng chạy trên web**.
- Export template 4.7.2 **đã cài** trong `.tools/godot-4.7.2/editor_data/export_templates/4.7.2.stable/` (Story 0.1), có `web_nothreads_release.zip`.
- Repo **chưa có**: `game/export_presets.cfg`, `tools/build_web.sh`, `tools/deploy_itch.sh`, butler.
- `build/` đã nằm trong `.gitignore`.
- Ngân sách E0 khoảng 12 giờ cho 6 story. Story này khoảng 2–3 giờ, phần lớn là chờ tác giả làm trên itch.io.

### File sẽ sửa (đọc trước khi sửa)

**`tools/cai_dat.sh`**: source `_godot.sh` với `GODOT_BO_QUA_KIEM_TRA=1`.
- Hiện tại: nếu `$GODOT_DIR/.installed` có thì `echo "Đã cài Godot 4.7.2"; exit 0`. Sau đó tải `SHA512-SUMS.txt`, Godot, template; kiểm SHA-512; giải nén; gỡ quarantine; tạo `._sc_`; cài template; `touch .installed`; xóa `.tools/tai_ve`.
- **Thay đổi:** bỏ `exit 0` sớm, thêm khối cài butler. Khối Godot giữ nguyên hành vi.
- **Giữ nguyên:** hàm `tai` (tải tiếp phần dở), `kiem_tra`, thứ tự cài Godot.

**`tools/_godot.sh`**: đặt `REPO_ROOT`, `GODOT_VERSION`, `GODOT_DIR`, `GODOT_OS`, `GODOT`, `GODOT_DATA_DIR`; kiểm Godot đã cài trừ khi `GODOT_BO_QUA_KIEM_TRA=1`.
- **Thay đổi:** thêm biến butler, thêm hàm `ghi_build_info`.
- **Giữ nguyên:** mọi biến và thông báo hiện có. `test.sh`, `chay.sh`, `check_boundaries.sh` đều source file này.

**`tools/chay.sh`**: ghi `build_info.json`, `--import`, chạy game.
- **Thay đổi:** thay đoạn ghi `build_info.json` bằng lời gọi `ghi_build_info`. Kết quả phải giống hệt.

**`game/src/debug/dev_tools.gd`**: `setup(enabled)` đăng ký F1–F5 và tạo Label "DEV" (cỡ 20, đỏ, ở (8, 8)).
- **Thay đổi:** theo Task 5.3 (chữ DEV có thêm số lần mở).
- **Giữ nguyên:** phím, thông điệp, `_ready()` tắt `set_process_unhandled_input` khi không bật dev.

### Những gì KHÔNG làm ở story này

| Việc | Story |
|---|---|
| Preset Windows, bản Steam | Giai đoạn 2 |
| Lưu game thật (`user://save.json`) | E4 (FR46) |
| Tối ưu dung lượng hoặc thời gian tải | E4 (đo đủ NFR1–NFR4) |
| Chặn phím F1/F5 của trình duyệt | 1.6 (story này chỉ ghi lại) |
| Công khai trang itch.io | Khi tác giả nói |
| HTML shell riêng, màn hình chờ riêng | Chưa lên lịch |
| GitHub Actions / CI | Không làm |

### Luật kiến trúc phải theo

- **Web đơn luồng**, renderer Compatibility (WebGL 2), không SharedArrayBuffer/COOP/COEP. Không `Thread`, không `WorkerThreadPool`. [Source: project-context.md#Nền tảng và build; game-architecture.md#Rủi ro kỹ thuật 5]
- **Build bằng dòng lệnh** `--headless --export-release`, không mở editor. [Source: game-architecture.md quyết định #22]
- **Preset:** filter `*.json`; loại trừ `tests/*`, `addons/gut/*`. Thiếu `*.json` thì bản web không có dữ liệu. [Source: game-architecture.md#Luật nhất quán 8]
- **Dung lượng:** bản nén ≤ 25 MB, `build_web.sh` tự kiểm. [Source: game-architecture.md#Số liệu; NFR2]
- **Deploy** bằng `tools/deploy_itch.sh` (butler), mặc định **riêng tư**; chỉ công khai khi tác giả nói. [Source: project-context.md]
- **Lưu trữ:** `user://` trên web là IndexedDB, phải chạy được trong iframe itch.io; kiểm ở E0. [Source: game-architecture.md#Phần kiến trúc engine lo sẵn]
- **Lệnh cho tác giả nằm trong `tools/`**, chạy từ gốc repo, thông báo tiếng Việt, mã thoát khác 0 là lỗi. [Source: game-architecture.md#Cây thư mục]
- **Tài nguyên bên ngoài: ghim phiên bản, kiểm checksum** (mẫu của Godot ở Story 0.1, GUT ở 0.2, font ở 0.4). project-context ghi "butler bản mới nhất"; story này ghim `15.32.0` (mới nhất ngày 2026-10-17) để giữ đúng mẫu. Nâng thì sửa số và SHA.
- **`src/debug/`** chứa code chỉ chạy khi bật dev. `SaveProbe` đặt ở đây. `check_boundaries.sh` cho phép `FileAccess` ngoài `src/core`.
- **Không `print()`**: dùng `Log`. Gõ kiểu tĩnh mọi nơi, kể cả test.

### Ghi chú kỹ thuật (đã kiểm trên Godot 4.7.2, ngày 2026-10-17, trên bản sao tạm)

- Preset ở Task 1.1 chạy được với `--headless --path game --export-release "Web" ../build/web/index.html`, thoát 0, không có dòng `ERROR`. Godot **không** viết lại `export_presets.cfg`. Khóa không ghi trong file thì Godot lấy mặc định.
- Kết quả `build/web/`: `index.html`, `index.js` (280 KB), `index.wasm` (39.5 MB), `index.pck` (161 KB), `index.png`, `index.icon.png`, `index.apple-touch-icon.png`, `index.audio.worklet.js`, `index.audio.position.worklet.js`.
- **Bản nén zip `-9` của `build/web/`: 10 351 804 byte (≈ 10.4 MB)**, dưới 25 MB nhiều. Riêng `index.wasm` nén gzip `-9` còn khoảng 10.05 MB.
- `index.pck` có `build_info.json`, `assets/fonts/OFL.txt`, `i18n/text.vi.translation`, font, theme, script đã biên dịch. **Không có** file nào trong `tests/` hay `addons/gut/`.
- `index.html` có `<title>Chống Nguyên Mông</title>` (lấy từ `config/name` lúc export). Lúc chạy, `get_window().title` đổi tiêu đề tab.
- **Chạy thử bằng Chrome headless** (Chrome có sẵn trên máy tác giả):
  ```
  cd build/web && python3 -m http.server 8765 &
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new \
    --use-angle=swiftshader --enable-unsafe-swiftshader --user-data-dir=<thư mục tạm> \
    --window-size=1280,720 --timeout=25000 --lang=en-US \
    --screenshot=<ảnh>.png "http://localhost:8765/index.html?dev=1"
  ```
  - Dùng `--timeout=25000` (chờ thật). `--virtual-time-budget` chỉ chụp được màn hình logo Godot vì wasm chưa kịp chạy.
  - Ảnh đã chụp: bàn cờ đúng, tiêu đề "Chống Nguyên Mông" đủ dấu dù trình duyệt là `en-US`, chữ DEV đỏ (tức `?dev=1` tới được game khi **không** có iframe), nhãn `v0.1.0 · abc1234`.
  - Nhớ tắt server sau khi chụp (`pkill -f "http.server 8765"`). macOS không có lệnh `timeout`.
- butler 15.32.0 (`darwin-arm64`) chạy được: `butler --version` → `v15.32.0, built on Oct  6 2026`. Danh sách bản: `https://broth.itch.zone/butler/<nền tảng>`; bản mới nhất: `.../LATEST`.
- **Chưa kiểm được (cần tài khoản itch.io):**
  - trang Draft trả HTTP 404 cho người chưa đăng nhập (Task 4.3 bước 6);
  - địa chỉ thật của iframe itch.io (trước đây là `html5.itch.zone/...` hoặc `html-classic.itch.zone/...`);
  - itch.io có nén gzip/brotli `index.wasm` khi gửi không (ảnh hưởng thời gian tải: 39.5 MB chưa nén ở 20 Mbps mất khoảng 16 giây, nén thì khoảng 4–5 giây);
  - lần đẩy đầu có cần tích tay "played in the browser" không (theo hiểu biết hiện tại là cần).

### Hướng dẫn cho tác giả (AI đọc lại cho tác giả khi tới Task 8)

1. **Tạo tài khoản:** vào `https://itch.io/register`, đăng ký (miễn phí).
2. **Tạo trang game:** `https://itch.io/game/new`.
   - Title: Hào Khí Đông A. Project URL: tên trang (chữ không dấu, ví dụ `hao-khi-dong-a`).
   - Kind of project: **HTML**.
   - Visibility & access: **Draft**. Bấm Save.
3. **Cài và đăng nhập:** gõ `tools/cai_dat.sh`, rồi `tools/dang_nhap_itch.sh`. Trình duyệt mở trang itch.io, bấm đồng ý. Chỉ làm một lần trên máy này.
4. **Đẩy bản đầu:** gõ `tools/build_web.sh`, rồi `tools/deploy_itch.sh`.
5. **Chỉ lần đầu:** vào trang Edit game. Ở mục Uploads, file `html5`: tích **This file will be played in the browser**. Mục Embed options:
   - Viewport dimensions: **1280 × 720**;
   - tích **Fullscreen button**;
   - không tích SharedArrayBuffer (bản này đơn luồng, không cần).
   Bấm Save. Vẫn để **Draft**.
6. **Xem:** mở link script in ra (đăng nhập itch.io trước). Thấy nút Run game, bấm vào thì hiện bàn cờ.
7. **Đo thời gian tải (AC 6), trên Chrome:**
   - mở link, bấm F12 để mở DevTools, chọn tab **Network**;
   - tích **Disable cache**;
   - ở ô "No throttling", chọn **Add…** → **Add custom profile**: Download 20000 kbit/s, Upload 20000 kbit/s, Latency 0. Đặt tên "20 Mbps", chọn profile đó;
   - tải lại trang, bấm Run game, đếm tới khi hiện bàn cờ (hoặc xem số **Finish** và **transferred** ở dòng dưới cùng của tab Network);
   - đọc hai số cho AI ghi: tổng MB đã tải, số giây.

### Cấu trúc file sau story

```
game/
├── export_presets.cfg                  # MỚI: preset Web đơn luồng
├── src/debug/
│   ├── save_probe.gd                   # MỚI: thử lưu user:// (chỉ khi bật dev)
│   └── dev_tools.gd                    # sửa: gọi SaveProbe, chữ DEV kèm số lần mở
└── tests/
    ├── test_export_preset.gd           # MỚI
    ├── test_save_probe.gd              # MỚI
    └── test_dev_tools.gd               # sửa nếu chữ DEV đổi
tools/
├── _godot.sh                           # + biến butler, + hàm ghi_build_info
├── cai_dat.sh                          # + cài butler 15.32.0 (kiểm SHA-256)
├── chay.sh                             # dùng ghi_build_info
├── build_web.sh                        # MỚI
├── deploy_itch.sh                      # MỚI
├── dang_nhap_itch.sh                   # MỚI
└── itch.cfg                            # MỚI: ITCH_TARGET=<tài khoản>/<tên trang>
NEXT-STEPS.md                           # + mục "Số đo bản web (NFR2)"
```

Kèm các file `.uid` do Godot sinh.

### Testing

- Test GUT: `test_export_preset.gd`, `test_save_probe.gd`, sửa `test_dev_tools.gd`. Chạy không cần màn hình.
- `build_web.sh`, `deploy_itch.sh`, `cai_dat.sh` không có test tự động (giống các script `tools/` khác, xem `deferred-work.md`). Kiểm bằng tay theo Task 7, ghi vào Debug Log.
- Phần trên itch.io (AC 3–6) do tác giả kiểm bằng mắt, AI ghi lại.
- **Hướng dẫn tác giả tự test** (ghi vào Completion Notes):
  1. Gõ `tools/test.sh` → dòng cuối `✅ N/N test đạt`.
  2. Gõ `tools/build_web.sh` → thấy dòng `Dung lượng bản nén: … MB (giới hạn 25 MB)` và `✅ Đã build bản web …`.
  3. Gõ `tools/deploy_itch.sh` → thấy `🔒 Trang đang riêng tư` và đường link.
  4. Mở link trên Chrome, Firefox, Edge → bàn cờ, tiêu đề tiếng Việt, góc dưới phải có phiên bản và mã commit giống dòng `✅ Đã build …`.
  5. Mở bản có dev (cách ghi trong Completion Notes), tải lại trang 2 lần → chữ DEV ghi "lần mở thứ 1", rồi 2, rồi 3.

### Previous Story Intelligence (Story 0.4 và review)

- Repo vừa clone: lần `--import` đầu nạp Theme trước khi quét font → `Parse Error` oan. `test.sh` bước 3 quét lại một lần, giữ log lần đầu ở `import.lan1.log`. `build_web.sh` cần cùng cách xử lý (Task 2.4).
- `--import` có thể thoát 0 mà vẫn lỗi; phải đọc log ("chống xanh giả").
- Font đã tắt `allow_system_fallback` (tác giả chốt): trên web cũng như trên máy, thiếu chữ thì hiện ô vuông.
- Mục hoãn cần xử lý ở story này (`deferred-work.md`):
  - bản web hiện tiêu đề tiếng Việt trên trình duyệt tiếng Anh → AC 4;
  - `OFL.txt` đi kèm bản phát hành → Task 1.1, 2.6;
  - `?dev=1` trong iframe itch.io → Task 8.4;
  - `LaunchOptions.read_current()` đường web → Task 7.5 (chạy thật trên Chrome) và 8.4;
  - F1/F5 bị trình duyệt chiếm → Task 8.6 (chỉ ghi lại);
  - `config/name` viết cứng → câu hỏi 4.
- Trạng thái toàn cục sống qua các file test (`Log`, `InputMap`, `TranslationServer`). Test DevTools phải dọn sạch, và không được ghi `user://thu_luu.json` thật.
- Chụp màn hình bản desktop: `--write-movie`, không `screencapture`. Bản web: Chrome headless (Ghi chú kỹ thuật).
- Thay đổi thử nghiệm làm trên bản sao tạm (`git archive HEAD game | tar -x`), không trên repo thật.

### Git Intelligence

- 5 commit gần nhất:
  - `baddfc1 Thêm file dịch, font Be Vietnam Pro và Theme chung (Story 0.4)`
  - `d1eff8b Tạo story 0.4 (chữ tiếng Việt và font)`
  - `bec53eb Sửa theo code review Story 0.3`
  - `e460c96 Thêm Log, cờ dev và tham số khởi động (Story 0.3)`
  - `bedf0fe Tạo story 0.3 (log, cờ dev và tham số khởi động)`
- `27b40d8 Sửa theo code review Story 0.4` (tắt mượn font, `test_main.gd`, `test.sh` giữ log lần đầu) là `baseline_commit` của story này.
- Mẫu script `tools/`: chú thích đầu file tiếng Việt, `set -euo pipefail`, source `_godot.sh`, tên biến và hàm tiếng Việt không dấu (`tai`, `kiem_tra`, `ghi_buoc`, `bao_cao`), lỗi in ra stderr bắt đầu bằng `Lỗi:`.

### Project Context Rules

- Đọc `_bmad-output/project-context.md` trước khi viết code.
- Godot **4.7.2.stable**, GUT **v9.7.1**. Không tự nâng phiên bản.
- Chỉ làm bản web (Chrome, Firefox, Edge desktop). Không làm riêng cho Safari hay điện thoại.
- Export đơn luồng; preset có `*.json`, loại `tests/*`, `addons/gut/*`.
- Deploy mặc định riêng tư; chỉ công khai khi tác giả nói.
- Bật dev bằng `?dev=1` (web). Phiên bản và mã commit luôn hiện ở góc màn hình.
- Không `print()`: dùng `Log`. Gõ kiểu tĩnh mọi nơi.
- "Xong" nghĩa là `tools/test.sh` xanh rồi commit. Lời commit tiếng Việt. Không `push --force`.
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được.

### Câu hỏi cho tác giả (hỏi ở Task 0)

1. **Tên tài khoản và tên trang itch.io** (ví dụ `trungnguyen/hao-khi-dong-a`)? Chưa có tài khoản thì tạo theo "Hướng dẫn cho tác giả" bước 1–2.
2. **Chế độ riêng tư:** để **Draft** (đề xuất: chỉ tác giả xem được khi đăng nhập; khi cần cho người khác xem thì dùng Secret URL hoặc chuyển Restricted có mật khẩu) hay **Restricted** ngay từ đầu?
3. **Hiện kết quả thử lưu `user://` ở đâu?** Đề xuất: chỉ khi bật dev, chữ DEV đổi thành `DEV · lần mở thứ N` và ghi một dòng log. Nếu trên itch.io không bật được dev trong iframe (Task 8.4), thì có cho phép ghi dòng log này cả khi không bật dev (xem bằng F12 → Console) không?
4. **Tên game trong cài đặt project** (`config/name`, mục hoãn từ review 0.4): giữ viết cứng "Chống Nguyên Mông" (đề xuất; tên tab trình duyệt vẫn theo `text.csv` sau khi game chạy), hay muốn đồng bộ theo `text.csv`?

### Quyết định của tác giả (2026-10-17)

1. **Chưa có tài khoản itch.io.** Làm Task 1–3, 5–7 trước. `tools/itch.cfg` để chữ mẫu `ITCH_TARGET=<tai-khoan>/<ten-trang>`; `deploy_itch.sh` thấy chữ mẫu thì báo "chưa điền tài khoản itch.io" và thoát 1. Khi tới Task 8, hướng dẫn tác giả đăng ký rồi hỏi lại tên.
2. **Draft** (theo đề xuất). Cần cho người khác xem thì dùng Secret URL hoặc chuyển Restricted, việc đó để sau.
3. **Theo đề xuất:** khi bật dev, chữ DEV thành `DEV · lần mở thứ N` kèm một dòng log. **Đồng ý thêm:** nếu trên itch.io không bật được dev trong iframe (Task 8.4) thì được ghi dòng log thử lưu ra Console cả khi không bật dev (và khi đó probe chạy cả khi không bật dev). Chữ trên màn hình vẫn chỉ hiện khi bật dev.
4. **Tên game chốt là "Hào Khí Đông A"** (đã đổi `config/name` và `app.title` ở commit đổi tên, trước khi làm story). Giữ `config/name` viết cứng, không đồng bộ với `text.csv`; đổi tên sau này thì sửa cả hai chỗ. Ghi chú kỹ thuật bên trên chụp lúc tên còn là "Chống Nguyên Mông". Repo và thư mục vẫn tên `chong-nguyen-mong`, không đổi.

### References

- `_bmad-output/planning-artifacts/epics.md#Story 0.5`
- `_bmad-output/planning-artifacts/game-architecture.md`: #Rủi ro kỹ thuật 5; #Việc đầu tiên của E0; #Phần kiến trúc engine lo sẵn; quyết định #22; #Cây thư mục; #Luật nhất quán 8; #Môi trường phát triển
- `_bmad-output/project-context.md`: #Nền tảng và build, #Hiệu năng
- `_bmad-output/implementation-artifacts/deferred-work.md`: mục Story 0.3, review 0.3, Story 0.4, review 0.4
- `_bmad-output/implementation-artifacts/0-4-chu-tieng-viet-va-font.md`: Debug Log, Review Findings
- butler: `https://broth.itch.zone/butler/darwin-arm64/15.32.0`; tài liệu `https://itch.io/docs/butler/`

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Đỏ trước khi viết code: `test.sh` trượt — 3 test DevTools trượt, `test_save_probe.gd` lỗi `SaveProbe` chưa có, `test_export_preset.gd` lỗi (hàm `_get` trùng `Object._get`, đã đổi tên thành `_preset_value`).
- Sau khi viết code: `✅ 61/61 test đạt` (50 cũ + 5 preset + 5 probe + 1 DevTools đếm lần mở).
- `tools/build_web.sh`: `Dung lượng bản nén: 10.4 MB (giới hạn 25 MB); chưa nén: 40.0 MB`, `✅ Đã build bản web vào build/web/ (v0.1.0 · 4c39723-sua)`, mã 0. `build/web/` có `OFL.txt`.
- Thử trượt 25 MB: bản sao script hạ giới hạn xuống 5 MB → `❌ trượt: bản nén vượt 25 MB`, mã 1 (chữ trong thông báo viết cứng 25, chỉ số giới hạn bị hạ). Đã xóa bản sao.
- `tools/cai_dat.sh`: lần đầu cài butler 15.32.0, SHA-256 khớp, `butler --version` = v15.32.0; chạy lại → `Đã cài Godot 4.7.2` / `Đã cài butler 15.32.0`, không tải. Thử file hỏng (ghi chữ "hong" vào zip trong `.tools/tai_ve`, xóa `.installed` của butler) → `Lỗi: … sai mã SHA-256`, mã 1; chạy lại cài đúng.
- `tools/deploy_itch.sh`: `itch.cfg` còn chữ mẫu → `Lỗi: chưa điền tài khoản itch.io…`, mã 1. Điền tạm `thu/thu-nghiem` → `Lỗi: butler chưa đăng nhập itch.io…`, mã 1 (khóa mặc định của butler trên macOS: `~/Library/Application Support/itch/butler_creds`, lấy từ `butler --help`). Đã trả `itch.cfg` về chữ mẫu.
- itch.io: trang không tồn tại (`leafo.itch.io/khong-co-trang-nay-xyz`) trả 404 cho người chưa đăng nhập. Trang Draft trả 404 hay không: **chưa kiểm** (chờ tài khoản, Task 8).
- Chrome headless (`en-US`, `?dev=1`, cùng một hồ sơ trình duyệt, mở 3 lần): tiêu đề "Hào Khí Đông A" đủ dấu, `DEV · lần mở thứ 1` rồi `DEV · lần mở thứ 2` (lần mở giữa chụp lúc còn màn hình tải), nhãn `v0.1.0 · 4c39723-sua`. `user://` bền trên Chrome khi **không** có iframe.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List

- `game/export_presets.cfg` (mới)
- `game/src/debug/save_probe.gd`, `.uid` (mới)
- `game/src/debug/dev_tools.gd` (sửa: thử lưu, chữ DEV kèm số lần mở)
- `game/tests/test_export_preset.gd`, `.uid` (mới)
- `game/tests/test_save_probe.gd`, `.uid` (mới)
- `game/tests/test_dev_tools.gd` (sửa)
- `tools/_godot.sh` (sửa: biến butler, hàm `ghi_build_info`)
- `tools/cai_dat.sh` (sửa: cài butler 15.32.0)
- `tools/chay.sh` (sửa: dùng `ghi_build_info`)
- `tools/build_web.sh`, `tools/deploy_itch.sh`, `tools/dang_nhap_itch.sh`, `tools/itch.cfg` (mới)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (trạng thái)
- `_bmad-output/implementation-artifacts/0-5-ban-web-tren-itch-io-rieng-tu.md` (story này)

### Change Log

- 2026-10-17: Phần làm trên máy (Task 0–7): preset Web đơn luồng, `build_web.sh` (kiểm 25 MB), butler 15.32.0 ghim SHA-256, `deploy_itch.sh` + `dang_nhap_itch.sh` + `itch.cfg`, thử lưu `user://` khi bật dev. 11 test mới (tổng 61). Còn Task 8 (cần tài khoản itch.io của tác giả).
