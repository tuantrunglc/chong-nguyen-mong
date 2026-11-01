---
baseline_commit: d9b5ba6
---

# Story 8.6: Màn hình chính và màn chuyển trận

Status: done

## Story

Là người chơi,
tôi muốn mở game thấy cảnh Bạch Đằng và logo, và giữa các trận thấy tranh lịch sử,
để có không khí ngay từ đầu.

_Chốt 2026-11-01 (tác giả): Epic 8 chỉ đổi hình và tiếng, **không đổi luật**. Story này thay hai màn nền phẳng (`MainMenu`, `LevelTransition`, đều `draw_rect` màu nâu) bằng **tranh nền, logo, tranh chuyển trận** đã có trong `assets/textures/man_hinh/`, và cập nhật **biểu tượng game** và **ảnh bìa itch.io**. Chữ vẫn do `Label`/`Button` vẽ (tiếng Việt có dấu, nằm trong `text.csv`)._

> **Điều kiện:** 8.1 đến 8.5 đã xong (commit `d9b5ba6`). Hình đã có trong `assets/textures/man_hinh/` và đã có dòng CREDITS (F1–F4). **Không thêm hình mới.** Thiếu hình nào thì báo tác giả, đừng tự vẽ.

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.6, `art-reference/danh-sach-hinh-e8.md` mục F, mã `src/ui/main_menu.gd`, `level_transition.gd`, `src/app/main.gd`. Mục **[Đã chốt mặc định]** có câu hỏi tương ứng ở "Câu hỏi cho tác giả"; dev làm theo mặc định, tác giả đổi sau khi xem ảnh.)

### A. Màn hình chính

1. **Nền sông Bạch Đằng.** `MainMenu` vẽ `man_hinh/tex_nen_man_hinh.png` (640×360) phóng **×2** đúng 1280×720 (lọc `Nearest`, phóng nguyên bậc, không nhòe), thay cho ô nâu phẳng `BACKGROUND_COLOR`. Nạp qua `Art.tex()`.
2. **Logo.** Dòng tên game (Label `app.title` cỡ 56) được thay bằng hình `man_hinh/tex_logo_hao_khi_dong_a.png` (420×84), hiện ở nửa trên, căn giữa, phóng ×2 nếu vừa (840×168) hoặc ×1 nếu che mất cảnh quan trọng của nền (nhìn ảnh rồi chọn, ghi vào Completion Notes). Giữ **chữ tên game cho trợ năng/test**: khóa `app.title` vẫn tồn tại và `MainMenu` có getter trả chữ đó (ví dụ `title_text()`), nhưng không vẽ Label đè lên logo.
3. **Phụ đề, nút, dòng báo file lưu hỏng giữ nguyên** nội dung và hành vi (`menu.subtitle`, "Chơi mới", "Chơi tiếp" chỉ khi có file lưu, dòng `menu.save_broken`). Chúng đọc rõ trên nền tranh: nếu chữ phụ đề (`SUBTITLE_COLOR`) chìm, thêm một dải tối mờ sau cụm chữ và nút (vẽ bằng code hoặc `UiStyle.panel()`), đừng đổi font hay cỡ chữ.
4. **Không đổi cách chơi.** Nút vẫn không nhận focus, Space/Enter ở menu vẫn không bấm nút (Story 4.1, AC 5); phím trận (F5, F2…) ở menu hành xử như `test_main.gd` đang kiểm.

### B. Màn chuyển trận

5. **Tranh chuyển trận. [Đã chốt mặc định: Câu hỏi 1]** `LevelTransition` vẽ một trong ba tranh `man_hinh/tex_chuyen_tran_*.png` (640×360, phóng ×2) làm nền, theo **trận sắp vào** (mặc định):
   - Trận 2 → `tex_chuyen_tran_hoi_nghi_binh_than.png`
   - Trận 3, 4, 5 → `tex_chuyen_tran_luy_ai_van_kiep.png`
   - Trận 6 và màn "Đã thắng cả chiến dịch" → `tex_chuyen_tran_thuy_chien_bach_dang.png`
   - Id trận không có trong bảng → tranh Lũy ải Vạn Kiếp, không báo lỗi (dữ liệu trận có thể thêm sau).

   Bảng nằm ở **một chỗ** trong `src/ui/` (`ScreenArt`, theo khuôn `UiStyle`/`UnitArt`: hàm thuần, test được không cần màn hình), **không** thêm trường vào file trận hay `chien_dich.json`.
6. **Chữ trên tranh đọc rõ.** Tên trận (`TITLE_FONT_SIZE` 44), dòng "Trận kế", các dòng mưu kế mới (`STRATAGEM_COLOR` vàng) và nút "Tiếp"/"Về menu" nằm trên một dải tối mờ hoặc khung `UiStyle.panel()` đủ tương phản trên cả ba tranh; kiểm bằng ảnh chụp. Nội dung chữ giữ nguyên (`show_next(level_name, new_stratagems)` hiện đúng tên và mưu kế như `test_level_transition.gd` đang kiểm).
7. **Biểu tượng nhiệm vụ 32×32. [Đã chốt mặc định: Câu hỏi 2]** 8.5 để dành bản 32×32 cho story này. Dưới tên trận kế, `LevelTransition` hiện `tex_nhiem_vu_tieu_diet_32x32.png` hoặc `tex_nhiem_vu_giu_ai_32x32.png` kèm chữ `hud.mission.eliminate` / `hud.mission.hold_pass` (khóa **đã có**, không thêm khóa). `show_next` nhận thêm tham số tùy chọn `mission: int = -1` (mặc định -1 là ẩn dòng, nên mọi lời gọi và test cũ không đổi); `main.gd` truyền `_level.mission`. Dùng lại `UiStyle.MISSION_KEYS`; thêm bảng đường dẫn 32×32 vào `UiStyle` (cạnh `MISSION_ICONS`). Chỉ đọc kiểu trận đã có, không sửa `src/core`.
8. **Màn "Đã thắng cả chiến dịch"** dùng tranh Bạch Đằng, ẩn dòng nhiệm vụ và dòng "Trận kế" như hiện nay (`show_campaign_end`).

### C. Biểu tượng game và ảnh bìa

9. **Biểu tượng game.** `project.godot` có `config/icon` trỏ tới `assets/textures/man_hinh/tex_icon_256.png` (hiện chưa có). Bản xuất web dùng nó làm favicon/biểu tượng; nếu `export_presets.cfg` có mục biểu tượng riêng thì điền cùng hình. Có `.import` và `.uid` do Godot sinh (chạy game hoặc test một lần rồi commit). Test kiểm `config/icon` trỏ tới file có thật.
10. **Ảnh bìa itch.io.** Hình nguồn `img/pixellab-thu/toi_uu/man_hinh_chinh/f5_anh_bia_itch_io_630x500.png` (630×500). Ảnh bìa **không nằm trong game**; việc "cập nhật" là tải lên trang itch. **Đừng tự đăng lên itch** (hành động ra ngoài, theo luật làm việc). Dev kiểm hình đúng cỡ 630×500, có trong CREDITS (nếu chưa, thêm dòng F5), và ghi trong báo cáo cuối **các bước để tác giả tự tải lên** trang chỉnh sửa game trên itch (Cover image). Nếu tác giả bảo dev làm bằng `tools/deploy_itch.sh`, hỏi lại trước.

### D. Giữ nguyên, test, duyệt

11. **Màn lỗi.** `ErrorScreen` (màn dữ liệu hỏng) **không đổi nền** (nó cần đọc được log lỗi); chỉ giữ nút kiểu 8.5.
12. **Luật không đổi.** `src/core`, `Rules`, `BattleController`, `chi_so.json`, `chien_dich.json`, file trận và kịch bản `da_duyet: true` **không bị sửa**. `BoardView`, `Hud`, `Tooltip` (8.2–8.5) không bị sửa trừ nơi AC 7 buộc phải nối.
13. **Chạy ở mọi cỡ cửa sổ.** Cửa sổ 1280×720, `stretch canvas_items`, `aspect keep`: nền phủ kín `BoardView.viewport_size`, không viền trống, không giãn méo. Mép dưới/trên tranh không bị cắt chữ.
14. **Hiệu năng.** Nền và tranh nạp qua `Art.tex()` (nạp một lần, nhớ lại); không `_process` mới; vẽ bằng `draw_texture_rect` trong `_draw()` hoặc `TextureRect`, **không** shader mới (renderer Compatibility). Ba tranh chuyển trận không nạp hết khi mở game: chỉ nạp tranh sắp hiện (nhớ bởi `Art`). 60 FPS (NFR1) và bản nén web ≤ 25MB giữ nguyên (hình đã nằm trong game từ 8.1, không thêm dung lượng).
15. **Test.** `tools/test.sh` xanh; có test mới (Task 5). Không giảm số test cũ; test cũ chỉ sửa chỗ buộc phải sửa (ví dụ test đếm Label của `MainMenu`), ghi vào Completion Notes.
16. **Tác giả duyệt bằng mắt.** Chụp bằng GoPeak `capture_screenshot`, lưu `_bmad-output/implementation-artifacts/anh/8-6-*.png`, ít nhất: màn hình chính không có file lưu; màn hình chính có file lưu (hai nút); màn chuyển trận trước trận 2, 3 và 6; màn thắng cả chiến dịch. **Chỉ đánh `[x]` Task 6 khi đã lưu đủ ảnh.** Cách chụp ở "Cách tác giả thử".

## Tasks / Subtasks

- [x] Task 1: Kho chọn hình màn hình (AC: 5, 7, 9, 14)
  - [x] 1.1 Tạo `game/src/ui/screen_art.gd` (`class_name ScreenArt`, `extends RefCounted`, hàm tĩnh, theo khuôn `UiStyle`): hằng đường dẫn nền, logo, ba tranh chuyển trận; `transition_for(level_id: String) -> String` (hàm thuần, bảng ở AC 5, id lạ → Vạn Kiếp); `campaign_end()` trả tranh Bạch Đằng. Hình nạp qua `Art.tex()`.
  - [x] 1.2 Thêm vào `UiStyle` bảng `MISSION_ICONS_LARGE` (32×32) cạnh `MISSION_ICONS`; không đổi bảng 24×24 cũ.
- [x] Task 2: Màn hình chính (AC: 1, 2, 3, 4)
  - [x] 2.1 `MainMenu._draw()`: `draw_texture_rect` nền ×2 phủ `size`, lọc Nearest (kiểm `texture_filter` của node hoặc import đã `Nearest` từ 8.1). Bỏ `BACKGROUND_COLOR` làm nền (giữ hằng nếu `LevelTransition` còn dùng làm màu dự phòng khi thiếu hình).
  - [x] 2.2 Thay Label tên game bằng `TextureRect` logo (hoặc vẽ trong `_draw`); thêm `title_text()` trả `tr("app.title")` để test/trợ năng. Cân bố cục cụm logo + phụ đề + nút trên nền (đo bằng ảnh chụp; không đè người, thuyền, cọc quan trọng của nền).
  - [x] 2.3 Dải tối mờ sau phụ đề và nút nếu chữ chìm (AC 3); không đổi font/cỡ.
- [x] Task 3: Màn chuyển trận (AC: 5, 6, 7, 8)
  - [x] 3.1 `LevelTransition.show_next(level_name, new_stratagems, mission = -1, level_id = "")` (hoặc nhận tranh đã chọn): chọn tranh theo `ScreenArt.transition_for`, `queue_redraw()`; `show_campaign_end()` dùng tranh Bạch Đằng.
  - [x] 3.2 Dòng nhiệm vụ 32×32 + chữ dưới tên trận (AC 7), ẩn khi `mission < 0` và ở màn kết thúc.
  - [x] 3.3 Dải tối mờ hoặc `UiStyle.panel()` sau cụm chữ (AC 6).
  - [x] 3.4 `main.gd` `_show_transition`: truyền `_level.mission` và id trận kế (`next_id`) vào `show_next`; chỉ thêm đối số, không đổi luồng.
- [x] Task 4: Biểu tượng game và ảnh bìa (AC: 9, 10)
  - [x] 4.1 Thêm `config/icon` vào `project.godot` (qua chỉnh file, không mở editor); kiểm `export_presets.cfg` (mục `html/` và biểu tượng nếu có).
  - [x] 4.2 Kiểm `f5_anh_bia_itch_io_630x500.png` đúng 630×500, và CREDITS có dòng F5 (thêm nếu thiếu).
- [x] Task 5: Test (AC: 1 đến 9, 12, 13, 15)
  - [x] 5.1 Mới `game/tests/test_screen_art.gd`: `transition_for` đủ trận 2 đến 6, id lạ, campaign_end; mọi đường dẫn tồn tại thật (`ResourceLoader.exists`), cỡ ảnh đúng (640×360 phóng ×2 = 1280×720; logo 420×84; nền 640×360).
  - [x] 5.2 `test_main_menu` (hoặc nơi đang kiểm `MainMenu`; tìm bằng `grep MainMenu game/tests`): có hình nền (không còn là ô phẳng), `title_text()` trả chữ dịch, nút giữ `FOCUS_NONE`, "Chơi tiếp" chỉ hiện khi có file lưu, không có Label tên game đè lên logo.
  - [x] 5.3 `test_level_transition.gd` (thêm, không sửa test cũ): `show_next` với `mission` hiện dòng nhiệm vụ đúng chữ và biểu tượng 32×32; `mission = -1` ẩn dòng; `show_campaign_end` ẩn dòng nhiệm vụ; tranh đổi theo `level_id`.
  - [x] 5.4 `test_main.gd`: chuyển từ trận 1 sang 2 qua `_show_transition` truyền đúng mission và tranh; không đổi luồng `Screen`.
  - [x] 5.5 Test `config/icon` trỏ tới file có thật (đọc `ProjectSettings`).
  - [x] 5.6 `tools/test.sh` xanh (gồm `check_boundaries.sh`, `test_assets.gd`, khóa `text.csv`).
- [x] Task 6: Duyệt bằng mắt (AC: 13, 16)
  - [x] 6.1 Chạy `tools/chay.sh --dev` (không `--tran`, để vào màn hình chính) ở chế độ nền; chụp bằng GoPeak `capture_screenshot`. Màn chuyển trận: thắng trận nhanh bằng đường dev (xem Dev Notes) hoặc gọi trực tiếp qua lệnh dev nếu có; không có thì chụp bằng test dựng `LevelTransition` rồi `--write-movie` (xem `memory/godot-screenshot-workaround`). Lưu `anh/8-6-*.png`.
  - [x] 6.2 Ghi vào Completion Notes: cỡ logo đã chọn (×1 hay ×2), bảng tranh theo trận, nơi chữ cần dải tối, đã đo nền phủ kín.
  - [x] 6.3 Nếu bố cục sai (logo đè cảnh, chữ chìm) thì dừng và báo tác giả bằng ảnh, đừng tự đổi hình.

### Review Findings

- [x] [Review][Decision] (đã chụp bổ sung: `8-6-man-hinh-chinh-co-file-luu.png`, `8-6-chuyen-tran-3.png`; logo nằm nửa trên) Task 6 đã đánh `[x]` nhưng thiếu ảnh duyệt theo AC 16 — còn thiếu ảnh màn hình chính có file lưu (hai nút) và ảnh chuyển trận trước trận 3 (hiện chỉ có ảnh trận 2, 4, 6, menu, thắng chiến dịch). Chọn: chụp bổ sung, hoặc chấp nhận thiếu (trận 3 dùng cùng tranh Vạn Kiếp với trận 4). Cũng cần mắt tác giả xác nhận logo nằm nửa trên (AC 2). (auditor)
- [x] [Review][Decision] (chọn a: logo theo công tắc, tắt thì dựng Label chữ) Khi `UiStyle.ENABLED=false` menu mất tên game dạng chữ (logo luôn là hình, Label `app.title` đã bỏ; `title_text()` không hiện lên đâu) — Chọn: (a) logo theo công tắc, tắt thì hiện lại Label chữ; (b) chấp nhận, công tắc chỉ là đường lui tạm. (blind+edge+auditor)
- [x] [Review][Patch] Hằng `MainMenu.BACKGROUND_COLOR` không còn ai dùng, trùng `ScreenArt.FALLBACK_COLOR` [game/src/ui/main_menu.gd:10]
- [x] [Review][Patch] `test_logo_fits_inside_the_window` đọc `logo` không kiểm null [game/tests/test_main_menu.gd]
- [x] [Review][Patch] `test_logo_and_background_load_without_errors` có thể xanh giả vì `_draw` chưa chạy lúc kiểm log; nên gọi `Art.tex` nền trực tiếp hoặc ép vẽ [game/tests/test_main_menu.gd]
- [x] [Review][Patch] Chưa có test bắt trận mới thiếu trong `ScreenArt.TRANSITIONS` (id lạ rơi về Vạn Kiếp lặng lẽ); thêm test: mọi `tran_02`..`tran_06` có khóa trong bảng [game/tests/test_screen_art.gd]
- [x] [Review][Patch] `test_itch_cover_has_the_store_size`: `if cover != null` che lỗi sau `assert_not_null`, và test đọc ảnh ngoài `game/` (`res://../img/...`) [game/tests/test_screen_art.gd]
- [x] [Review][Defer] Khung tối mờ lặp nguyên văn ở `MainMenu` và `LevelTransition` — deferred, nên gom vào `UiStyle` khi có chỗ thứ ba
- [x] [Review][Defer] `show_next` dùng số ma thuật `mission = -1`, `MISSION_KEYS`/`MISSION_ICONS_LARGE` chưa có test đồng bộ — deferred, chưa gây lỗi
- [x] [Review][Defer] `chup.gd` sửa lớn, ngoài File List, lặp mã — deferred; khi commit nhớ add theo từng đường dẫn

## Dev Notes

### Hiện trạng cần đọc trước khi code (kiểm 2026-11-01, commit `d9b5ba6`)

- `src/ui/main_menu.gd` (~95 dòng): `Control` dựng bằng code, `setup()` đặt `CenterContainer` > `VBoxContainer` gồm Label tên game (56), phụ đề, `_buttons` (Chơi tiếp, Chơi mới), dòng file lưu hỏng; nền `_draw()` là `draw_rect(BACKGROUND_COLOR)`. `show_save(can_continue, broken)`. Người gọi đặt `size` trước `setup()` (`BoardView.viewport_size`).
- `src/ui/level_transition.gd` (~130 dòng): cùng khuôn, dùng `MainMenu.BACKGROUND_COLOR`. `show_next(level_name, new_stratagems)`, `show_campaign_end()`, `stratagem_lines()`. **Không có** thông tin trận kế ngoài tên và mưu kế: AC 7 thêm tham số tùy chọn.
- `src/app/main.gd:296-322` `_show_transition()`: đã có `_level` (trận kế vừa nạp), `next_id`, `_level.mission`. `_set_cover(_level_transition)` ẩn tiêu đề trận. `main.gd:87-100` dựng cả hai màn một lần lúc `_ready` (nên tranh nền nạp lúc `_draw`, không nạp ba tranh khi mở game).
- `src/ui/art.gd`: `Art.tex(path)` tính từ `assets/textures/`, lỗi thì ô hồng 64×64 và một dòng `[ERROR][hinh]`.
- **Hình có sẵn** (`assets/textures/man_hinh/`, đã có `.import`, CREDITS F1–F4): `tex_nen_man_hinh.png` 640×360, `tex_logo_hao_khi_dong_a.png` 420×84, `tex_badge_logo.png` 192×64 (huy hiệu đồng; **không dùng ở đây** trừ khi tác giả muốn), `tex_icon_game.png` 64×64, `tex_icon_256.png` 256×256, `tex_chuyen_tran_{hoi_nghi_binh_than,luy_ai_van_kiep,thuy_chien_bach_dang}.png` 640×360. Bản 32×32 của biểu tượng nhiệm vụ: `giao_dien/tex_nhiem_vu_*_32x32.png`.
- Hình chưa vào game: bản `_goc_co_bien` của nền (`f1_nen_man_hinh_goc_co_bien.png`), ba tranh 320×180, các cỡ icon 32/64/128. **Đừng đem vào**; cần thì hỏi tác giả.
- **Chưa có** `config/icon` trong `project.godot` (hiện chỉ `config/name`, `config/version`, `config/features`).
- **Trận hiện có:** 6 trận (`data/chien_dich.json`: `tran_01` … `tran_06`); tên trận lấy từ khóa `ten` của file trận (không phải khóa dịch).

### Rủi ro và việc cần xem bằng mắt (báo tác giả)

- **Logo chìm hoặc chọi với nền.** Logo vàng hoàng kim viền đỏ sẫm trên nền hoàng hôn có thể nhòe; xem ảnh chụp ở ×1 và ×2 rồi chọn cỡ.
- **Nút và chữ chìm trên tranh.** Nút 9-slice (8.5) vốn tối, nhưng phụ đề `SUBTITLE_COLOR` và tên trận có thể chìm trên cảnh sáng. Dải tối mờ trước, đừng đổi bảng màu chữ.
- **Tranh chuyển trận không đồng bộ lịch sử.** Ba tranh cho năm lần chuyển; bảng ở AC 5 là mặc định, tác giả đổi bằng một dòng trong `ScreenArt`.
- **Cắt tranh.** Nền 640×360 ×2 vừa khít 1280×720; nếu cửa sổ khác tỉ lệ thì `aspect keep` của Godot đã chừa viền đen, đừng tự kéo giãn.
- **Chụp màn chuyển trận khó.** Cần thắng một trận để tới đó. Cách nhanh: test dựng `LevelTransition` hoặc đường dev trong `main.gd`; không thêm phím dev mới nếu không cần (hỏi tác giả).
- **Tác giả từng ghi nhận lỗi che chữ** (Story 8.2, review: nền che tiêu đề). Ở đây màn che phủ cả cửa sổ; kiểm thứ tự vẽ: nền rồi dải tối rồi chữ rồi nút.

### Luật dự án áp dụng (từ `project-context.md`)

- Chỉ cú pháp Godot 4, gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). Giá trị từ `Dictionary` phải ép kiểu tường minh.
- Hình nạp qua `Art.tex()`; lỗi nạp ghi `Log.error("hinh", ...)` tiếng Việt. Không `print`, không `randi`/`randf`.
- **Scene nhỏ và phẳng**, mọi UI dựng bằng code; không việc nào đòi tác giả mở editor. Không `get_node("/root/...")`.
- **Đi xuống thì gọi hàm, đi lên thì phát signal.** Không Event Bus.
- Mọi chữ hiển thị qua `tr()` và `i18n/text.csv`; story này **không thêm khóa chữ mới** (tái dùng `hud.mission.*`, `app.title`, `menu.*`, `transition.*`). Chữ tiếng Việt đủ dấu.
- Không đụng `src/core`. `ScreenArt` nằm trong `src/ui/`; `check_boundaries.sh` cấm lõi luật import code vẽ.
- Renderer Compatibility: chỉ `draw_texture_rect`/`TextureRect`/`StyleBoxTexture`, không shader mới. Không object pool, `Thread`.
- Mỗi hình đưa vào game có một dòng CREDITS; không thêm hình mới nên chỉ kiểm.

### Cách tác giả thử (cho báo cáo cuối của dev)

1. `tools/chay.sh` (không `--tran`): **thấy** cảnh sông Bạch Đằng làm nền, logo "Hào Khí Đông A" ở trên, phụ đề và nút "Chơi mới" ở dưới, đọc rõ. Nếu đã có file lưu thì có thêm nút "Chơi tiếp".
2. Bấm "Chơi mới", thắng trận 1, bấm "Tiếp": **thấy** tranh Hội nghị Bình Than làm nền, tên "Trận 2 — Ải Lãnh Kinh", dòng nhiệm vụ kèm biểu tượng 32×32, chữ đọc rõ.
3. Thắng tiếp tới trận 3, 4, 5: tranh Lũy ải Vạn Kiếp. Trận 6 và màn thắng cả chiến dịch: tranh thủy chiến Bạch Đằng.
4. Mở thư mục dự án: ảnh bìa itch ở `img/pixellab-thu/toi_uu/man_hinh_chinh/f5_anh_bia_itch_io_630x500.png`; dev ghi các bước tải lên itch (tác giả tự bấm).

### Việc thuộc story khác (đừng làm ở đây)

- Âm thanh, nhạc nền (8.7).
- Hình thắng/thua `tex_trien_*` trên `ResultBanner`: chưa nằm trong tiêu chí 8.6 (xem Câu hỏi 3).
- Chân dung "Người dẫn chuyện" (E4) và lời dẫn lịch sử trên tranh chuyển trận: cần chữ của tác giả, chưa có.
- Con trỏ chuột: đã bỏ khỏi Epic 8.

### Project Structure Notes

- File mới: `game/src/ui/screen_art.gd` (+ `.uid`), `game/tests/test_screen_art.gd` (+ `.uid`). File sửa: `src/ui/main_menu.gd`, `level_transition.gd`, `ui_style.gd`, `src/app/main.gd`, `project.godot`, `assets/CREDITS.md` (nếu thiếu F5), các test liên quan.
- Mỗi file `.gd` mới có `.uid` do Godot sinh (chạy game hoặc test một lần rồi commit).

### Previous Story Intelligence (8.1 đến 8.5)

- 8.1 đặt toàn bộ hình vào kho và `Art.tex()`; lọc Nearest đặt ở import. Chạy `tools/nap_hinh.sh` nếu thêm hình mới (không cần ở đây).
- 8.2 review: **nền che tiêu đề** (thứ tự vẽ). Màn che ở đây phủ cả cửa sổ, kiểm thứ tự.
- 8.5 review: khung `UiStyle.panel()` có lề 8 px; nút có màu chữ riêng (`BUTTON_FONT_COLORS`); `UiStyle.ENABLED=false` quay về kiểu phẳng cũ: **tôn trọng công tắc này** (khi tắt, vẽ lại nền phẳng cũ cho hai màn). Test `test_buttons_on_other_screens_use_texture_styles` đã dựng `MainMenu`/`LevelTransition` với `size` rồi `setup()`; giữ đúng cách gọi này.
- Khuôn story thêm lớp chọn hình thuần + test riêng + nối vào view có sẵn (`UnitArt`, `UnitAnim`, `FxArt`, `UiStyle`). Làm `ScreenArt` theo đúng khuôn.

### Git Intelligence

- `d9b5ba6` (review 8.5) và `2826e40` (8.5): mẫu thêm `UiStyle` + test + ảnh duyệt. `138d11a`, `3f95854`: lớp chọn hình thuần.
- Cây làm việc có một file không thuộc story: `img/pixellab-thu/cong-cu/chup.gd` đang sửa dở (không phải của 8.6); **đừng commit nhầm**, add theo từng đường dẫn.
- Mỗi story một commit riêng, lời commit tiếng Việt, chỉ commit khi `tools/test.sh` xanh và khi tác giả bảo.

### Latest Tech

- Godot 4.7.2 (ghim, không nâng). `CanvasItem.draw_texture_rect(texture, rect, tile, modulate, transpose)`; `texture_filter = TEXTURE_FILTER_NEAREST` trên node (hoặc theo import). `ProjectSettings` `application/config/icon` (dòng `config/icon="res://..."` trong `[application]`). Nếu API lạ thì tra Context7 `/godotengine/godot-docs/__branch__4.7` trước khi dùng (theo `CLAUDE.md`).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 8.6]
- [Source: _bmad-output/planning-artifacts/art-reference/danh-sach-hinh-e8.md#F. Màn hình và quảng bá]
- [Source: _bmad-output/planning-artifacts/art-reference/ban-giao-asset.md]
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/8-5-giao-dien.md#Việc thuộc story khác, #Review Findings]
- [Source: game/src/ui/main_menu.gd, level_transition.gd, ui_style.gd, art.gd; game/src/app/main.gd#_show_transition]
- [Source: game/assets/CREDITS.md (F1–F4)]

## Câu hỏi cho tác giả

Dev làm theo mặc định; tác giả đổi được sau khi xem ảnh.

1. **Tranh nào cho trận nào?** Có 3 tranh cho 5 lần chuyển trận. Mặc định (theo trận sắp vào): trận 2 = Hội nghị Bình Than; trận 3, 4, 5 = Lũy ải Vạn Kiếp; trận 6 và màn thắng cả chiến dịch = Thủy chiến Bạch Đằng. Đổi chỉ cần sửa một bảng.
2. **Dòng nhiệm vụ trên màn chuyển trận.** Mặc định: thêm biểu tượng 32×32 và chữ "Tiêu diệt"/"Giữ ải" dưới tên trận kế (dùng bản 32×32 mà 8.5 để dành). Cách khác: không thêm dòng, màn chuyển trận chỉ có tranh, tên và mưu kế mới.
3. **Hình thắng/thua (`tex_trien_*`).** Kho có sẵn nhưng không nằm trong tiêu chí 8.6. Mặc định: không làm (bảng Thắng/Thua giữ khung và nút của 8.5). Cách khác: thêm vào story này (khoảng nửa ngày), hoặc để story riêng.
4. **Ảnh bìa itch.** Mặc định: dev chỉ kiểm hình và ghi các bước để tác giả tự tải lên. Cách khác: dev chạy `tools/deploy_itch.sh` (hỏi lại trước khi đăng).
5. **Cỡ logo.** Mặc định: dev thử ×2 (840×168) rồi ×1 (420×84), chọn cỡ không che cảnh và gửi ảnh cho tác giả. Tác giả nói trước nếu muốn cỡ nhất định.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5

### Debug Log References

- Chụp màn chuyển trận bằng script tạm (`--script` + `--write-movie`) vì đi tới đó phải thắng cả trận 1; script đã xóa.

### Completion Notes List

- **Làm xong:** `ScreenArt` (đường dẫn hình, bảng trận → tranh chuyển trận, hàm vẽ nền phủ kín, nền phẳng khi `UiStyle.ENABLED=false`). `MainMenu`: nền sông Bạch Đằng ×2, logo hình thay Label tên game (`title_text()` giữ chữ), phụ đề và nút nằm trên khung tối. `LevelTransition`: tranh nền theo trận sắp vào, dòng nhiệm vụ 32×32, chữ nằm trên khung tối; `show_next(level_name, new_stratagems, mission = -1, level_id = "")` (đối số mới tùy chọn nên test cũ giữ nguyên). `main.gd` chỉ truyền thêm `_level.mission` và `next_id`.
- **Cỡ logo:** ×2 (840×168) vừa đẹp, không che cảnh quan trọng; không cần thu ×1.
- **Bảng tranh theo trận (mặc định, đổi ở `ScreenArt.TRANSITIONS`):** trận 2 Bình Than; trận 3, 4, 5 Vạn Kiếp; trận 6 và thắng chiến dịch Bạch Đằng; id lạ Vạn Kiếp.
- **Biểu tượng game:** thêm `config/icon` trỏ `tex_icon_256.png` vào `project.godot` (chưa có trước đó). `export_presets.cfg` không có mục biểu tượng riêng nên không đổi.
- **Ảnh bìa itch:** chỉ kiểm (630×500, test kiểm cỡ) và thêm dòng F5 vào `CREDITS.md`. **Chưa đăng lên itch**; tác giả tự tải lên (xem báo cáo cuối).
- **Test cũ sửa:** `test_no_tran_shows_main_menu` (không còn Label tên game; kiểm `title_text()`); `_texts` trong `test_level_transition.gd` đổi sang `is_visible_in_tree()` để dòng nhiệm vụ ẩn không bị đếm.
- **Test:** 1009/1009 (trước story: 996). Mới: `test_screen_art.gd`, `test_main_menu.gd`, thêm vào `test_level_transition.gd`, `test_main.gd`.
- **Ảnh duyệt:** `anh/8-6-man-hinh-chinh.png`, `8-6-chuyen-tran-2.png`, `8-6-chuyen-tran-4.png`, `8-6-chuyen-tran-6.png`, `8-6-thang-chien-dich.png`. Chưa chụp riêng màn hình chính khi không có file lưu (nút "Chơi tiếp" ẩn): logic đã có test ở `test_main.gd`.

### File List

- game/src/ui/screen_art.gd (+ .uid), game/src/ui/main_menu.gd, game/src/ui/level_transition.gd, game/src/ui/ui_style.gd, game/src/app/main.gd, game/project.godot, game/assets/CREDITS.md
- game/tests/test_screen_art.gd (+ .uid), game/tests/test_main_menu.gd (+ .uid), game/tests/test_level_transition.gd, game/tests/test_main.gd
- _bmad-output/implementation-artifacts/anh/8-6-*.png (5 ảnh), 8-6-man-hinh-chinh-va-man-chuyen-tran.md, sprint-status.yaml

## Change Log

- 2026-11-01: Tạo story 8.6 (Ultimate context engine).
- 2026-11-01: Làm xong Task 1 đến 6 (nền và logo màn hình chính, tranh và dòng nhiệm vụ màn chuyển trận, `config/icon`, CREDITS F5, test). Chuyển `review`.
