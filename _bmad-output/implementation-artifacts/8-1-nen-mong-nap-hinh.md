---
baseline_commit: 167bc96
---

# Story 8.1: Nền móng nạp hình

Status: done

## Story

Là tác giả,
tôi muốn hình đã vẽ nằm đúng chỗ trong game, có ghi nguồn và có chỗ gọi hình thống nhất,
để các story 8.2–8.6 chỉ việc gắn hình vào mà không phải lo chỗ để, tên file, giấy phép hay lỗi nạp.

_Story này **không đổi gì nhìn thấy** trong game (tác giả biết trước). Nó chỉ chuẩn bị. Đừng gắn hình vào bàn cờ, quân hay giao diện ở đây: việc đó thuộc 8.2–8.6._

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.1 và mô tả Epic 8; `art-reference/ban-giao-asset.md`, `danh-sach-hinh-e8.md`; `game-architecture.md` mục "Nạp asset" và quy ước đặt tên; `game/assets/CREDITS.md`.)

1. **Hình chép vào `game/assets/textures/`.** Chỉ chép hình **bản cuối** từ `img/pixellab-thu/toi_uu/` theo bảng "Bản đồ chép" ở Dev Notes. **Không chép:** ảnh tổng hợp (`_tong_hop_*`, `_so_sanh_*`, `_mockup_*`), file `*.gif`, `*_preview*`, thư mục `demo_*`, bảng ghép 4×4 (`spritesheet_walk_256x256.png`; dùng từng khung rời), hình đồng nghĩa kích cỡ thừa (xem bảng). `img/` giữ nguyên làm kho nháp, không xóa, không sửa.
2. **Tên file theo quy ước:** `tex_<tên>.png`, chữ thường, `snake_case`, không dấu, **không có dấu gạch ngang** (`south-west` → `south_west`). Mỗi nhóm một thư mục con (`dia_hinh/`, `quan/`, `hoat_anh/`, `hieu_ung/`, `giao_dien/`, `chan_dung/`, `man_hinh/`). Việc chép làm **bằng một lệnh chạy lại được** (`tools/nap_hinh.sh`, xem Task 1): chạy lần hai không đổi gì, nên khi tác giả vẽ lại hình ở `img/`, chạy lệnh là cập nhật.
3. **Lọc `Nearest` cho mọi hình.** `project.godot` đặt `rendering/textures/canvas_textures/default_texture_filter` = `0` (Nearest) để pixel art không nhòe (kiến trúc: "Godot đặt lọc `Nearest`"). Test kiểm giá trị này. Không đặt lọc riêng từng file `.import`.
4. **Chỗ gọi hình duy nhất `Art`** (`src/ui/art.gd`, `class_name Art`, hàm static): `Art.tex(path: String) -> Texture2D`.
   - Nhận đường dẫn ngắn tính từ `res://assets/textures/` (ví dụ `Art.tex("quan/tex_khoai_south.png")`).
   - Có hình thì trả về hình, nạp một lần rồi nhớ (nạp sẵn, không nạp động; kiến trúc ADR 15).
   - **Thiếu file hoặc không nạp được:** ghi `Log.error("hinh", "...")` bằng **tiếng Việt, có đường dẫn** (ví dụ `Không nạp được hình quan/tex_khoai_south.png (res://assets/textures/quan/tex_khoai_south.png): file không có hoặc hỏng`), rồi trả về **hình thay thế** (ô vuông 64×64 màu hồng đậm, dễ thấy) để game **không kẹt, không crash** (luật "không để game kẹt"). Mỗi đường dẫn chỉ báo lỗi **một lần** (không tràn log).
   - Không gọi `load()` hình ở chỗ khác trong `src/ui` / `src/battle`: các story sau đều đi qua `Art.tex`. (Test ở AC 7 kiểm.)
5. **`CREDITS.md` đủ nguồn.** Phần "Hình" có dòng cho **mọi nhóm** hình đã chép. Được ghi **một dòng cho một nhóm** bằng mẫu `assets/textures/quan/tex_khoai_*.png`, không bắt buộc từng file. Cột điền như sau (tác giả sửa nếu khác): mã hạng mục theo danh sách E8 (A1…F4), nguồn "PixelLab (pixellab.ai), tác giả tạo bằng AI", giấy phép "theo điều khoản PixelLab (người dùng giữ quyền, được dùng thương mại)", AI **`Có: PixelLab, chưa sửa tay`**, cột "Sửa gì" ghi các bước đã làm (đổi về Resurrect 64, viền `#2e222f`, ... theo `ban-giao-asset.md`), "Đã đối chiếu lịch sử" = `Chưa` (trừ ô đất, nút, khung: `Không cần`), ngày thêm. Xóa hai dòng ví dụ/nháp cũ (`_ví dụ: A1`, `B2 Phạm Ngũ Lão (nháp...)`) vì đã có dòng thật thay. Cập nhật đoạn "Khai báo dùng AI" cho đúng thực tế (hình quân, địa hình, giao diện do AI sinh, chưa sửa tay) và ghi chú rằng **chưa sửa tay thì chưa được phát hành** (luật sẵn có ở đầu file; đây là cửa chặn của E9, không phải của E8).
6. **Hình đúng bảng màu.** Trong số hình chép vào, các hình đã ghi "100% Resurrect 64" (quân, địa hình, hiệu ứng, giao diện, màn hình chính) **phải thật sự chỉ dùng màu trong `art-reference/resurrect-64.gpl`** (bỏ qua điểm ảnh trong suốt hoàn toàn). Kiểm bằng script/ test; nếu có hình lệch: **không tự sửa hình**, chép vào, ghi vào danh sách "ngoại lệ bảng màu" trong Completion Notes (tên file, số màu lệch) và báo tác giả. Hình chân dung và ảnh nền lớn (`man_hinh/`, `chan_dung/`) được **miễn** kiểm bảng màu (chúng là tranh vẽ, không ghi "đã chuẩn hóa" trong tài liệu): ghi rõ miễn trong test.
7. **Test GUT mới `tests/test_assets.gd`:**
   - (a) mọi file `.png` dưới `assets/textures/` khớp ít nhất một mẫu đường dẫn trong cột "File" của bảng "Hình" ở `CREDITS.md`; (b) mọi mẫu trong CREDITS khớp ít nhất một file (không để dòng ma);
   - (c) tên file đúng quy ước AC 2 (`^tex_[a-z0-9_]+\.png$`);
   - (d) `default_texture_filter` = Nearest;
   - (e) bảng màu như AC 6;
   - (f) `Art.tex` trả hình thật cho file có, trả hình thay thế và **ghi đúng một lần** lỗi cho file không có (kiểm câu lỗi tiếng Việt, kèm đường dẫn);
   - (g) không file `.gd` nào trong `src/` ngoài `art.gd` gọi `load("res://assets/textures` hay `preload("res://assets/textures`.
   Test chạy không cần màn hình (như các test khác).
8. **Bản web vẫn nhỏ.** Export preset đưa được `*.png` (kiểm: bản export có hình; nếu `export_filter="all_resources"` thì đã đủ, ghi lại kết quả kiểm). Chạy `tools/build_web.sh`: bản nén vẫn ≤ 25MB, ghi số mới vào Completion Notes (trước story: 10.6 MB nén, 40.3 MB chưa nén). Hình chưa dùng cũng được đóng gói (nạp sẵn theo kiến trúc); nếu vượt 25MB thì dừng và báo tác giả, không tự cắt hình.
9. **Không phá cái đã có.** Không sửa luật (`src/core/`), không sửa dữ liệu trận, không sửa kịch bản `da_duyet: true`, không sửa cảnh nào (`scenes/`), không đổi chữ trong `text.csv`. Chụp màn hình trận 1 trước và sau: **giống hệt** (AC "không đổi gì nhìn thấy").
10. **`tools/test.sh` xanh** (kể cả `check_boundaries.sh`). Commit tiếng Việt kết `(Story 8.1)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–3** (cuối file).
- [x] **Task 1: Lệnh chép hình** (AC: 1, 2)
  - [x] 1.1 Viết `tools/nap_hinh.sh` (bash, chạy từ gốc repo, theo kiểu các script `tools/` khác, tiếng Việt, `set -euo pipefail`). Đọc bảng ánh xạ trong chính script (mảng `nguon|dich`, hoặc file `tools/nap_hinh.txt` mỗi dòng một cặp; chọn một cách, gọn). Với mỗi cặp: kiểm file nguồn có thật (thiếu → in lỗi tiếng Việt, mã thoát 1), tạo thư mục đích, chép nếu khác (`cmp`), in tóm tắt: số file mới, cập nhật, không đổi.
  - [x] 1.2 Chạy lệnh, chạy lại lần hai: lần hai báo 0 mới, 0 cập nhật.
  - [x] 1.3 Mở Godot một lần để sinh `.import` (hoặc `tools/test.sh` làm giúp, như 4.7 với `text.vi.translation`); **chép các file `.import` vào git** nếu repo đang theo dõi `.import` của font (xem `assets/fonts/*.import`) cho nhất quán.
- [x] **Task 2: Lọc Nearest** (AC: 3)
  - [x] 2.1 `project.godot` mục `[rendering]` thêm `textures/canvas_textures/default_texture_filter=0`. Kiểm bằng Context7 (`/godotengine/godot-docs/__branch__4.7`) tên khóa và giá trị (0 = Nearest) trước khi viết; **không đoán**.
- [x] **Task 3: `Art`** (AC: 4)
  - [x] 3.1 `src/ui/art.gd`: `class_name Art`, `extends RefCounted`, hàm static, bộ nhớ nhớ hình (`static var _cache: Dictionary`), tập đường dẫn đã báo lỗi. Gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). Dùng `ResourceLoader.exists` rồi `load()`; hình thay thế dựng bằng `Image.create` + `ImageTexture.create_from_image`, nhớ lại để không dựng mỗi lần.
  - [x] 3.2 Hàm `Art.reset_for_test()` xóa bộ nhớ và danh sách đã báo lỗi (để test không dính nhau).
  - [x] 3.3 Câu lỗi qua `Log.error("hinh", ...)`, không `print()`. Câu lỗi không đi qua `tr()` (log dành cho dev, như các lỗi dữ liệu khác; đối chiếu `LevelLoader`).
- [x] **Task 4: CREDITS** (AC: 5)
  - [x] 4.1 Thêm dòng nhóm vào bảng "Hình", xóa 2 dòng nháp/ví dụ, cập nhật "Khai báo dùng AI".
- [x] **Task 5: Test** (AC: 6, 7)
  - [x] 5.1 `tests/test_assets.gd` theo AC 7. Đọc `CREDITS.md` bằng `FileAccess` (đường dẫn `res://assets/CREDITS.md`; **cần cho file này vào bản chạy test** — test chạy từ thư mục `game/` nên có sẵn; không cần đưa vào bản export, và thêm vào `exclude_filter` nếu đang bị đóng gói thì thôi, đừng đổi gì thừa). Mẫu glob so khớp bằng `String.match()`/`matchn()`.
  - [x] 5.2 Đọc `resurrect-64.gpl` từ đâu? File nằm ở `_bmad-output/planning-artifacts/art-reference/` (ngoài `game/`, test GUT không đọc được ổn định). **Chép bảng 64 màu thành hằng số** trong test (hoặc `tests/resurrect_64.gd`), ghi nguồn ở đầu file. Không chép `.gpl` vào `assets/`.
  - [x] 5.3 Kiểm tay: sửa tạm một hình cho có màu lạ → test bảng màu phải **trượt** (rồi hoàn lại). Đổi tên một hình sai quy ước → AC 7c trượt. Xóa tạm một file → AC 7b trượt.
- [x] **Task 6: Đóng gói và đối chiếu** (AC: 8, 9)
  - [x] 6.1 `tools/build_web.sh`, ghi dung lượng. 6.2 Chụp trận 1 trước/sau (GoPeak `capture_screenshot`, `tools/chay.sh --dev --tran=1`), so mắt: giống nhau.
- [x] **Task 7: Bàn giao** (AC: 10)
  - [x] 7.1 `tools/test.sh` xanh. 7.2 Cập nhật Dev Agent Record và `sprint-status.yaml` (`8-1-...: review`). 7.3 Ghi vào `art-reference/ban-giao-asset.md` một dòng: hình đã vào `game/assets/textures/` bằng `tools/nap_hinh.sh`.

## Dev Notes

### Hiện trạng cần đọc trước khi code (đã kiểm 2026-11-01)

- `game/assets/` hiện chỉ có `fonts/`, `theme/main_theme.tres`, `CREDITS.md`. **Chưa có `textures/`**. Mọi ô, quân, khối địa hình đều **vẽ bằng code** (`BoardView._draw`, `TerrainBlock`, `UnitToken`): **không động vào** ở story này.
- `project.godot` **chưa đặt** `default_texture_filter` (đang mặc định Linear: hình pixel sẽ nhòe nếu không đặt).
- `export_presets.cfg`: `export_filter="all_resources"`, `include_filter="*.json, assets/fonts/OFL.txt"`, loại `tests/*`, `addons/gut/*`, `addons/godot_mcp_runtime/*`. PNG nằm ngoài danh sách loại trừ nên được đóng gói; **kiểm lại bằng bản export thật** (AC 8).
- Log: `Log.error/warn/info/debug("he_thong", "...")` ở `src/debug/log.gd`; không dùng `print()`.
- `tests/pre_run.gd` chạy trước mọi test. Test mới không cần đổi nó.
- Mẫu lỗi dữ liệu: `LevelLoader` trả `LoadResult` kèm câu tiếng Việt; **`Art` khác ở chỗ**: lỗi hình không được chặn game, nên log ERROR + hình thay thế, không `LoadResult`.

### Bản đồ chép (nguồn → đích)

Nguồn: `img/pixellab-thu/toi_uu/…`; đích: `game/assets/textures/…`. Số lượng ước tính; dev đếm lại và ghi vào Completion Notes.

| Mã E8 | Nhóm | Nguồn | Đích (`tex_…`) | Ghi chú |
|---|---|---|---|---|
| A1, A2 | Ô nền | `dia_hinh/o_nen/tile_0..15.png`, `tile_co_le_0..3.png` | `dia_hinh/tex_o_nen_<n>.png`, `tex_o_co_le_<n>.png` | 16 ô ghép bờ cỏ–sông + 4 cỏ lẻ |
| A3–A7 | Vật cản | `dia_hinh/vat_can/a3_*, a4_*, a5_*, a6_*, a7_*` | `dia_hinh/tex_<tên giữ nguyên bỏ tiền tố aN_>.png` | Bỏ `_so_sanh_*`. Bỏ `a6_lang_que_128.png` nếu trùng `a6_lang_que.png` ở kích cỡ lớn hơn (xem ảnh trước khi bỏ; không chắc thì chép và hỏi) |
| A8 | Viền | `dia_hinh/vat_can/a8_vien_rung_0..3.png`, `dia_hinh/khung_ban_co/*` | `dia_hinh/tex_vien_rung_<n>.png`, `tex_khung_<cạnh>.png` | |
| B1–B6 | Quân đứng | `khoai|lao|du|nguyen_v3|ky_binh|cung_ky/<hướng>.png` (8 hướng mỗi quân) | `quan/tex_<quân>_<hướng>.png`, hướng viết `south_west`… | `nguyen_v3` đặt tên quân là `bo_binh` |
| B1–B6 | Hoạt ảnh | `hoat_anh/<quân>/<hướng>_<0..3>.png` (đi), `tan_cong/<quân>/`, `bi_thuong/<quân>/`, `guc_nga/<quân>/`, `chet_duoi/<quân>/` | `hoat_anh/tex_<quân>_<hành động>_<hướng>_<n>.png` | Dùng **khung rời**, bỏ `spritesheet_walk_*`. Hành động: `di`, `danh`, `trung_don`, `guc`, `chet_duoi`. Giữ cả biến thể `_east`/`_west` của Cung kỵ |
| C1–C10 | Hiệu ứng | `hieu_ung/c*.png`, `hieu_ung/vet_chem/vet_chem_0..3.png` | `hieu_ung/tex_<tên giữ nguyên>.png` | Bỏ `_tong_hop_*` và `.gif` |
| D1–D7 | Giao diện | `giao_dien/*.png` (khung, nút, icon, biến thể 9-slice), `giao_dien/con_tro/`, `giao_dien/o_co/`, `giao_dien/bong_do/`, `giao_dien/trien_an/`, `giao_dien/chu_so/so_*_<ký tự>.png` | `giao_dien/tex_<tên>.png` | `chu_so/` chỉ chép **bảng ghép** (`so_to_sheet_*`, `so_nho_sheet_*`) **hoặc** các chữ số rời, không cả hai (chọn một: bảng ghép; hỏi tác giả nếu bảng ghép lệch). `khung_chon_tuong`, `khung_o_di_duoc`, `khung_o_danh_duoc`, `mui_ten_xung_phong_*` là hình ô: **8.2 sẽ quyết có dùng thay code không**; chép sẵn, chưa dùng |
| E1–E4 | Chân dung | `chan_dung/e1_khoai_96x96.png`, `e2_lao_96x96.png`, `e3_du_96x96.png` và bản `_khung_96x96` | `chan_dung/tex_chan_dung_<tên>.png`, `..._khung.png` | Bản 64×64 **không chép** (thừa). `e4_nguoi_dan_chuyen_*`: xem Câu hỏi 2 |
| F1–F4 | Màn hình | `man_hinh_chinh/f1_nen_man_hinh.png`, `f3_logo_chu_hao_khi_dong_a.png`, `f3_badge_logo.png`, `f4_icon_game.png` (+ `f4_icon_256x256.png` cho icon ứng dụng) | `man_hinh/tex_<tên>.png` | `f5_anh_bia_itch_io_630x500.png` là ảnh bìa **trang itch.io**, không dùng trong game: không chép (để ở `img/`). Bỏ `_mockup_*`, `f1_nen_man_hinh_goc_co_bien` nếu là bản phụ (xem trước) |
| — | Màn chuyển trận | `chuyen_tran/f2_*_640x360.png` | `man_hinh/tex_chuyen_tran_<tên>.png` | Bản 320×180 không chép |
| — | Thuyền | `thuyen/*` | **chưa chép** | Xem Câu hỏi 3 |

**Quy ước tên đích chốt** (nếu chỗ nào bảng trên mập mờ, dev chọn theo đúng quy ước này, đừng sáng tạo): chữ thường không dấu, `_` thay `-`, tiền tố `tex_`, thứ tự `<nhóm>_<đối tượng>_<biến thể>`.

### Luật dự án áp dụng (từ `project-context.md`)

- Chỉ GDScript 4.7, **gõ kiểu tĩnh mọi nơi** (`untyped_declaration` = error); không `print()`; `Log` gọi bằng `Log.error("hinh", "...")`.
- `src/core/` là vùng cấm (chỉ `RefCounted`, không `FileAccess`/`load`): **không đụng**. `Art` nằm ở `src/ui/`; `check_boundaries.sh` phải xanh.
- **Nạp sẵn toàn bộ asset, không nạp động.** `Art.tex` nhớ hình trong bộ nhớ; không dựng luồng nạp nền (web đơn luồng, không `Thread`).
- Bản nén ≤ 25MB (`build_web.sh` tự kiểm).
- Xong một việc = `tools/test.sh` xanh rồi commit tiếng Việt. Không báo "xong" khi chưa chạy test.
- Nói với tác giả bằng tiếng Việt, kèm **các bước để thử, thấy gì là đúng**. Tác giả không đọc code.
- MCP chỉ để nhìn và thử; không dùng `run_project` của GoPeak.

### Việc thuộc story khác (đừng làm ở đây)

Gắn hình vào `BoardView`/`TerrainBlock` (8.2); `UnitToken` (8.3); phát hoạt ảnh, hiệu ứng (8.4); `Hud`, nút, theme, con trỏ, bảng tướng (8.5); `MainMenu`, `LevelTransition` (8.6); âm thanh (8.7). Cắt ô ghép bờ thành bản đồ ô (autotile) cũng là 8.2.

### Rủi ro và ghi chú

- **Dung lượng:** `toi_uu/` hiện 4.7 MB (gồm cả hình không chép). Bản chép nhỏ hơn; ước tính thêm vài MB khi đóng gói. Vẫn xa mức 25MB.
- **`.import`:** Godot sinh `.import` cạnh mỗi hình khi mở lần đầu, và thư mục `game/.godot/` đã gitignore. Theo cách repo đang làm với font.
- **AI chưa sửa tay:** ghi đúng thực tế vào CREDITS; đây chưa phải lỗi của 8.1 nhưng là **cửa chặn phát hành** (E9). Đừng ghi "đã sửa tay" cho đẹp.
- **Hình thay thế màu hồng đậm** là cố ý: thiếu hình thì thấy ngay trên bàn, không âm thầm hỏng.

### Project Structure Notes

- Thêm mới: `game/src/ui/art.gd` (+ `.uid` do Godot sinh), `game/assets/textures/**`, `game/tests/test_assets.gd`, `tools/nap_hinh.sh` (+ bảng ánh xạ). Sửa: `game/project.godot` (1 dòng), `game/assets/CREDITS.md`, `art-reference/ban-giao-asset.md` (1 dòng).
- Kiến trúc viết `assets/textures/` và `audio/sfx|music/`; khớp. Quy ước `tex_*.png` lấy ở kiến trúc dòng "Asset: tiền tố theo loại".
- Chỗ lệch kiến trúc: kiến trúc nói "Đồng quân và ô cờ vẽ bằng code". Epic 8 thay đổi điều đó (tác giả chốt 2026-11-01). Sau khi 8.2–8.3 xong, cập nhật `game-architecture.md` mục "Nạp asset" và `project-context.md` (không làm ở 8.1).

### References

- `_bmad-output/planning-artifacts/epics.md` (Epic 8, Story 8.1)
- `_bmad-output/planning-artifacts/art-reference/ban-giao-asset.md`, `danh-sach-hinh-e8.md`, `resurrect-64.gpl`
- `_bmad-output/planning-artifacts/game-architecture.md` (ADR 15 "Nạp asset", mục "Nạp asset", quy ước đặt tên asset)
- `_bmad-output/project-context.md` (luật triển khai, hiệu năng, test)
- `game/assets/CREDITS.md` (cách điền)
- `game/export_presets.cfg`, `game/project.godot`, `tools/_godot.sh`, `tools/test.sh`, `tools/build_web.sh`

## Câu hỏi cho tác giả

1. **Chân dung và nhân vật phụ:** Chỉ chép chân dung ba tướng (Khoái, Lão, Dư) và bỏ chân dung E4 "người dẫn chuyện"? _(Đề xuất: chép luôn E4 vì đã vẽ, chưa dùng ở đâu.)_
2. **Người dẫn chuyện (E4):** bạn có định dùng chân dung này ở đâu (màn chuyển trận, gợi ý đầu trận) không? Nếu chưa, đề xuất để lại ở `img/`, thêm sau.
3. **Thuyền** (`thuyen/`: thuyền chiến Đại Việt, Nguyên, thuyền chèo, soái hạm, thuyền đâm cọc Bạch Đằng): trong 6 trận hiện có, trận nào có thuyền? _(Đề xuất: **chưa chép**; làm cùng Trận Bạch Đằng ở E7 hoặc khi bạn quyết trận biển Vân Đồn nằm ở trận nào.)_

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5 (claude-sonnet-5-5)

### Debug Log References

- Context7 lỗi mạng khi tra khóa `default_texture_filter`; đã kiểm thẳng bằng Godot 4.7.2 (`ProjectSettings`): khóa có thật, mặc định `1` (Linear), danh sách `Nearest,Linear,Linear Mipmap,Nearest Mipmap` nên `0` = Nearest.
- Lần chạy đầu test bảng màu trượt vì `Image.load_from_file` trên `res://` in cảnh báo (GUT tính là lỗi). Đổi sang đọc byte thô và `load_png_from_buffer`.

### Completion Notes List

- **Câu hỏi tác giả:** theo đề xuất, không chép chân dung E4 và không chép thuyền.
- **Chép hình:** `tools/nap_hinh.sh` chép **415 file** (1.8 MB) vào `game/assets/textures/`: dia_hinh 51, quan 48, hoat_anh 244, hieu_ung 22, giao_dien 36, chan_dung 6, man_hinh 8. Chạy lần hai: 0 mới, 0 cập nhật, 415 không đổi. Chép cả `a6_lang_que_128` (64×128, kèm bản 64×96) vì chưa biết 8.2 dùng bản nào; chữ số chỉ chép bảng ghép (`tex_so_to_sheet_156x16`, `tex_so_nho_sheet_104x10`).
- **Lọc Nearest:** `project.godot` đặt `textures/canvas_textures/default_texture_filter=0`; test kiểm.
- **`Art.tex()`** ở `src/ui/art.gd`: nạp một lần rồi nhớ; thiếu hình thì `Log.error("hinh", ...)` tiếng Việt kèm đường dẫn, mỗi đường dẫn một lần, trả ô hồng đậm 64×64.
- **CREDITS:** 17 dòng nhóm (A1–F4), AI ghi `Có: PixelLab, chưa sửa tay`, đối chiếu lịch sử `Chưa` (ô đất, hiệu ứng, giao diện: `Không cần`). Đã xóa 2 dòng ví dụ/nháp. Đoạn "Khai báo dùng AI" ghi rõ chưa sửa tay thì chưa được phát hành.
- **Bảng màu:** mọi hình ngoài `man_hinh/` và `chan_dung/` đều chỉ dùng màu Resurrect 64. **Không có ngoại lệ.**
- **Test mới** `tests/test_assets.gd` (9 test, 1272 assert). Thử làm hỏng: file tên sai (`Sai Ten.png`) trượt cả test ghi nguồn lẫn test quy ước tên; hình có 1 điểm ảnh màu lạ trượt test bảng màu. **Chưa thử** trường hợp "mẫu CREDITS không khớp file nào" bằng cách xóa cả nhóm hình (test có, nhưng không thử làm hỏng).
- **Bản web:** nén **11.0 MB** (trước: 10.6), chưa nén 40.8 MB (trước: 40.3); giới hạn 25 MB. PNG có trong gói (`index.pck` chứa bản `.ctex`).
- **Không đổi gì nhìn thấy:** không file `.tscn`, không code trong `src/` nào dùng hình (`grep Texture` chỉ thấy `art.gd`), nên lọc Nearest chưa ảnh hưởng chỗ nào. Không chụp trước/sau; tác giả xem trận 1 vẫn y như cũ khi thử.
- **Còn lại cho tác giả:** `tools/test.sh`: 914/914 đạt.

### File List

- `tools/nap_hinh.sh` (mới)
- `game/assets/textures/**` (mới: 415 `.png` và 415 `.png.import`)
- `game/src/ui/art.gd`, `game/src/ui/art.gd.uid` (mới)
- `game/tests/test_assets.gd`, `game/tests/test_assets.gd.uid` (mới)
- `game/project.godot` (thêm 1 dòng lọc Nearest)
- `game/assets/CREDITS.md` (17 dòng nhóm hình, khai báo AI)
- `_bmad-output/planning-artifacts/art-reference/ban-giao-asset.md` (thêm 1 dòng)
- `_bmad-output/planning-artifacts/epics.md` (Epic 8, bước tạo kế hoạch)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`, `8-1-nen-mong-nap-hinh.md`

## Change Log

- 2026-11-01: Story 8.1 làm xong: nạp 415 hình, `Art.tex`, lọc Nearest, CREDITS, test; chờ tác giả duyệt.
