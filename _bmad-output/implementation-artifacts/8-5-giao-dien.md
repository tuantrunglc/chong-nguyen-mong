---
baseline_commit: 43f69fc
---

# Story 8.5: Giao diện

Status: review

## Story

Là người chơi,
tôi muốn khung, nút, biểu tượng đúng phong cách,
để game nhìn thống nhất.

_Chốt 2026-11-01 (tác giả): Epic 8 chỉ đổi hình và tiếng, **không đổi luật**. Story này thay các ô chữ nhật phẳng (`StyleBoxFlat`) và nút mặc định bằng **khung 9-slice, nút 4 trạng thái, biểu tượng, con trỏ chuột** đã có trong `assets/textures/giao_dien/`, và thêm **chân dung** vào khung thông tin tướng. Chữ vẫn do `Label`/`Button` vẽ (tiếng Việt có dấu, nằm trong `text.csv`)._

> **Điều kiện:** 8.1 đến 8.4 đã xong (commit `43f69fc`). Mọi hình đã có trong `assets/textures/` và đã có dòng trong `CREDITS.md` (D1–D7, E1–E3). **Không thêm hình mới.** Thiếu hình nào thì báo tác giả, đừng tự vẽ.

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.5, `art-reference/danh-sach-hinh-e8.md` mục D và E, mã `src/ui/*`. Mục **[Đã chốt mặc định]** có câu hỏi tương ứng ở "Câu hỏi cho tác giả"; dev làm theo mặc định, tác giả đổi sau khi xem ảnh.)

### A. Khung và nút

1. **Một chỗ lấy kiểu.** Tạo `UiStyle` (hàm tĩnh, `src/ui/ui_style.gd`) trả `StyleBoxTexture` dựng từ `Art.tex()`: `panel()` (khung bảng `tex_khung_bang_48x48.png`, lề 9-slice 8 px), `tooltip()` (`tex_khung_tooltip_32x32.png`, lề 6 px), `button(state)` (`tex_nut_9slice_{normal,hover,pressed,disabled}.png`, 32×24; đo ảnh để chọn lề, ghi số vào Completion Notes). Không `load()` riêng; thiếu hình thì `Art` ghi `[ERROR][hinh]` và game không sập.
2. **Nút 4 trạng thái.** Mọi `Button` do `Hud` dựng (Hủy, Chơi lại, mưu kế, Kết thúc lượt, Tua nhanh, "?") và nút của `HintPanel`, `ResultBanner`, `MainMenu`, `LevelTransition`, `ErrorScreen` dùng kiểu nút này: thường, rê chuột (viền vàng), nhấn (lún), mờ (`disabled`). Nút vẫn **không nhận focus** (`Hud` đã dặn: bấm chuột rồi gõ Space không được bấm lại nút). Màu chữ đủ tương phản trên nền nút ở cả 4 trạng thái.
3. **Khung bảng.** `Hud` (bảng bên phải), `HintPanel`, `ResultBanner`, `Notice`, `LevelTransition` thay `StyleBoxFlat` bằng `UiStyle.panel()`. Kích thước và vị trí chữ trong khung **không đổi** quá vài pixel (lề khung chỉ chỉnh để chữ không chạm viền). Bàn cờ (`BoardView.AREA`) không bị che.
4. **Khung thông tin (Tooltip)** dùng `UiStyle.tooltip()`. Giữ nguyên cách tự ngắt dòng và đo kích thước của Story 2.10 (`_fit_width`); **không** quay lại `autowrap` của `Label` (lỗi cột đen cao, commit `85d67c1`). `test_tooltip.gd` vẫn xanh.
5. **Lớp debug không đổi.** `FpsOverlay`, `AiIntentOverlay`, `CoordOverlay` (chỉ bật `--dev`) giữ `StyleBoxFlat` như cũ.

### B. Biểu tượng

6. **Mưu kế.** Nút mưu kế trên `Hud` có biểu tượng 32×32: `tex_ke_vuon_khong_nha_trong.png` cho Vườn không nhà trống, `tex_ke_sat_that.png` cho Sát Thát (gán qua `Button.icon`). Chữ nút (`hud.stratagem.*`) giữ nguyên, không đổi khóa. Nút đã dùng thì biểu tượng mờ theo nút.
7. **Máu.** Khung thông tin quân hiện `tex_icon_mau.png` (24×24) cạnh dòng "Máu x/y". Chấm máu trên quân (`UnitToken`) **vẫn vẽ bằng code** (NFR9), không đổi.
8. **Lòng dân.** Dòng "Lòng dân: x/y" trên `Hud` có `tex_icon_long_dan.png` (24×24) đứng trước chữ. Chỉ hiện khi trận có làng (như dòng chữ hiện nay).
9. **Hiệp. [Đã chốt: tác giả đã thêm hình 2026-11-01]** Dòng "Hiệp x" (hoặc "Hiệp x/y") trên `Hud` có `tex_hiep_24x24.png` (24×24) đứng trước chữ, như dòng Lòng dân. Chữ và màu nổi bật hiệp cuối (`FINAL_ROUND_COLOR`) giữ nguyên; `Hud.round_text()` vẫn trả đúng chữ để test cũ giữ nguyên.
10. **Nhiệm vụ. [Đã chốt mặc định: Câu hỏi 3]** `Hud` thêm một dòng nhiệm vụ dưới số hiệp: `tex_nhiem_vu_tieu_diet_24x24.png` hoặc `tex_nhiem_vu_giu_ai_24x24.png` (theo kiểu trận: `tieu_diet`, `giu_ai`) kèm chữ ngắn "Tiêu diệt" / "Giữ ải" (khóa mới trong `text.csv`). Đây là **chữ hiển thị mới**, không phải luật mới: chỉ đọc kiểu trận đã có trong `LevelData`/bản chụp, không sửa gì ở `src/core`. Bản 32×32 của hai biểu tượng này dành cho 8.6 (màn chuyển trận), **không dùng ở đây**.

### C. Chân dung

11. **Bảng thông tin tướng có chân dung. [Đã chốt mặc định: Câu hỏi 1]** Khi rê chuột lên **tướng Đại Việt**, khung thông tin hiện chân dung 96×96 bên trái, nội dung chữ **giữ nguyên** hiện nay (tên đầy đủ, máu kèm biểu tượng, đòn sắp đánh): `tex_chan_dung_khoai.png`, `tex_chan_dung_lao.png`, `tex_chan_dung_du.png` (bản không khung; bản `_khung` để dành). Quân Nguyên và địa hình **không có** chân dung và khung giữ cỡ cũ. Khung có chân dung vẫn chừa mép màn hình và lật khi sát mép (`place_at`). Chân dung không nhận chuột.
12. **Chữ nội dung chờ tác giả.** Tiểu sử, câu thoại, chỉ số nâng cao trong bảng tướng: **không làm** ở story này; không thêm chữ nào ngoài khóa AC 10.

### D. Con trỏ chuột (BỎ khỏi 8.5, tác giả chốt 2026-11-01: ba hình `tex_con_tro_*` không phải con trỏ; để con trỏ hệ thống)

13. ~~**BỎ theo tác giả 2026-11-01**~~ **Ba con trỏ. [Đã chốt mặc định: Câu hỏi 4]** `tex_con_tro_mac_dinh.png` (mũi tên, điểm bấm ở góc trên trái), `tex_con_tro_chon_tuong.png` (vòng ngắm, điểm bấm ở tâm), `tex_con_tro_tan_cong.png` (mũi kiếm, điểm bấm ở tâm); cả ba 32×32. Quy tắc đổi: rê lên tướng Đại Việt có thể chọn → `chon_tuong`; đang chọn tướng và rê lên ô địch đánh được (ô nằm trong danh sách mục tiêu đang vẽ) → `tan_cong`; còn lại → `mac_dinh`. Chọn con trỏ là **hàm thuần** (`CursorArt.kind_for(...)`, test được không cần màn hình); đặt con trỏ bằng `Input.set_custom_mouse_cursor`.
14. ~~**BỎ theo tác giả 2026-11-01**~~ **Không đổi cách chơi.** Con trỏ chỉ là hiển thị: không đổi nơi bấm, `pick_cell`, `BattleInput`, luật chọn tướng. Mọi thao tác vẫn làm được bằng một cú bấm chuột (project-context). Trình duyệt không hỗ trợ con trỏ tùy chỉnh thì quay về con trỏ hệ thống, không báo lỗi.
15. ~~**BỎ theo tác giả 2026-11-01**~~ **Ngoài trận.** Màn hình chính, bảng gợi ý, bảng thắng/thua dùng con trỏ mặc định. Rời trận hoặc ẩn cửa sổ thì trả con trỏ hệ thống nếu cần (không để con trỏ "chọn tướng" kẹt).

### E. Giữ nguyên, test, duyệt

16. **Chữ vẫn đọc rõ.** Cỡ chữ, font Be Vietnam Pro, dấu tiếng Việt không đổi; chữ trên khung và nút đủ tương phản (kiểm bằng ảnh chụp, đặc biệt nút mờ và chữ vàng trên nền đen).
17. **Luật không đổi.** `src/core`, `Rules`, `BattleEvent`, `chi_so.json`, kịch bản `da_duyet: true`, `BattleController` **không bị sửa**. `EventPlayer`, `BoardView`, `UnitToken`, `FxLayer` (8.3, 8.4) **không bị sửa** (trừ nơi AC 7 và 13 buộc phải nối: nếu cần, chỉ thêm signal hoặc getter, ghi vào Completion Notes).
18. **Hiệu năng.** Không `_process` mới chạy mãi; con trỏ chỉ đặt lại khi **loại** con trỏ đổi, không mỗi khung hình. Không tạo `StyleBoxTexture` mới mỗi lần hiện khung: dựng một lần, dùng lại (hoặc nhớ trong `UiStyle`). 60 FPS (NFR1) giữ nguyên.
19. **Test.** `tools/test.sh` xanh; có test mới (Task 6). Không giảm số test cũ; test cũ chỉ sửa chỗ buộc phải sửa (ví dụ test kiểm `StyleBoxFlat`), ghi vào Completion Notes.
20. **Tác giả duyệt bằng mắt.** Chụp bằng GoPeak `capture_screenshot` (`tools/chay.sh --dev --tran=N`), lưu `_bmad-output/implementation-artifacts/anh/8-5-*.png`, ít nhất: bảng bên phải ở trận có làng và có mưu kế (nút bốn trạng thái: thường, rê, mờ), khung thông tin trên tướng (có chân dung) và trên quân Nguyên (không chân dung), bảng gợi ý (`?`), bảng thắng/thua, ba con trỏ. **Chỉ đánh `[x]` Task 7 khi đã lưu đủ ảnh.** Lưu ý: chụp con trỏ qua GoPeak có thể không thấy con trỏ hệ điều hành; nếu vậy ghi rõ "tác giả tự xem" thay vì tick.

## Tasks / Subtasks

- [x] Task 1: Kho kiểu giao diện (AC: 1, 18)
  - [x] 1.1 Tạo `game/src/ui/ui_style.gd` (`class_name UiStyle`, `extends RefCounted`, hàm tĩnh, theo mẫu `Art`/`GroundArt`): `panel()`, `tooltip()`, `button(state)` với `enum ButtonState { NORMAL, HOVER, PRESSED, DISABLED }`, `apply_button(button: Button)` gắn đủ 4 stylebox (`normal`, `hover`, `pressed`, `disabled`) và bỏ viền focus. Nhớ kiểu đã dựng để không tạo lại.
  - [x] 1.2 Đo lề 9-slice của hình nút (32×24) và hai khung bằng cách nhìn ảnh; ghi lề đã chọn vào hằng, kèm bình luận, và vào Completion Notes.
  - [x] 1.3 Thêm `UiStyle.icon(name)` hoặc hằng đường dẫn biểu tượng (`tex_icon_mau`, `tex_icon_long_dan`, `tex_ke_*`, `tex_nhiem_vu_*`, `tex_chan_dung_*`) một chỗ, để tác giả thay hình dễ.
- [x] Task 2: Nút và khung bảng (AC: 2, 3, 4, 5)
  - [x] 2.1 `Hud._button()` gọi `UiStyle.apply_button`; áp cho nút của `HintPanel`, `ResultBanner`, `MainMenu`, `LevelTransition`, `ErrorScreen`.
  - [x] 2.2 Thay `StyleBoxFlat` bằng `UiStyle.panel()` ở `Hud`, `HintPanel`, `ResultBanner`, `Notice`, `LevelTransition`; `Tooltip` dùng `UiStyle.tooltip()`. Đo lại lề chữ trong khung (`CONTENT_MARGIN` của `Tooltip` phải ≥ lề 9-slice để chữ không đè viền).
  - [x] 2.3 Chạy `test_tooltip.gd`, `test_hint_panel.gd`, `test_result_banner.gd`, `test_main.gd`; sửa chỗ buộc phải sửa và ghi lại.
- [x] Task 3: Biểu tượng trên HUD và khung thông tin (AC: 6, 7, 8, 9, 10)
  - [x] 3.1 Nút mưu kế: `Button.icon` theo `Stratagem.Kind` (bảng kiểu → đường dẫn nằm ở `UiStyle`), `icon_alignment` bên trái, cỡ 32×32.
  - [x] 3.2a Dòng hiệp (AC 9): biểu tượng `tex_hiep_24x24.png` + chữ; `round_text()` giữ nguyên.
  - [x] 3.2 Dòng Lòng dân: biểu tượng + chữ (`HBoxContainer` nhỏ), ẩn cùng dòng như cũ; `Hud.morale_text()` vẫn trả đúng chữ để test cũ giữ nguyên.
  - [x] 3.3 Dòng nhiệm vụ mới dưới số hiệp (AC 10): khóa `hud.mission.tieu_diet`, `hud.mission.giu_ai` trong `i18n/text.csv`; lấy kiểu trận từ chỗ `Hud` đã nhận dữ liệu trận (xem `Hud.show_turn` và `BattleView`); **không** đọc trạng thái sống.
  - [x] 3.4 Khung thông tin: biểu tượng máu cạnh dòng "Máu" (Tooltip chuyển từ một `Label` sang `HBoxContainer` hoặc vẽ biểu tượng ở dòng đầu; chọn cách nào vẫn giữ `text()` trả đúng chuỗi cũ để test cũ giữ nguyên).
- [x] Task 4: Chân dung trong khung thông tin tướng (AC: 11, 12)
  - [x] 4.1 `Tooltip` nhận thêm `portrait: Texture2D` tùy chọn (`show_text(text, portrait = null)`): có thì hiện `TextureRect` 96×96 bên trái chữ, không thì ẩn và khung cỡ cũ. `TextureRect` đặt `mouse_filter = IGNORE`.
  - [x] 4.2 `BattleView._update_info`: tướng Đại Việt thì truyền chân dung theo `unit.type` (bảng `UnitType` → hình ở `UiStyle`/`Tooltip`, theo mẫu `UNIT_NAMES`); quân Nguyên và địa hình thì `null`. Không thêm chữ.
  - [x] 4.3 Kiểm `place_at` và `_fit_width` vẫn đúng khi khung rộng hơn (chân dung 96 + chữ); khung không tràn mép màn hình.
- [x] Task 5 (BỎ theo tác giả, không làm): Con trỏ chuột (AC: 13, 14, 15, 18)
  - [x] 5.1 Tạo `game/src/ui/cursor_art.gd` (`class_name CursorArt`, `extends RefCounted`): `enum Kind { DEFAULT, SELECT, ATTACK }`, đường dẫn và điểm bấm từng loại, `kind_for(over_selectable_general: bool, has_selection: bool, over_target: bool) -> int` (hàm thuần), `apply(kind)` gọi `Input.set_custom_mouse_cursor(Art.tex(...), Input.CURSOR_ARROW, hotspot)`; nhớ loại hiện tại, chỉ gọi khi đổi.
  - [x] 5.2 Nối vào chỗ đã biết ô đang trỏ và mục tiêu (`BattleView._on_cell_hovered`/`_update_info`, `BattleInput`); tính ba cờ từ bản chụp và danh sách mục tiêu đang vẽ, không từ trạng thái sống. Rời trận, hết trận, ẩn cửa sổ: về `DEFAULT`.
  - [x] 5.3 Chạy không màn hình (GUT headless) không được ném lỗi: `Input.set_custom_mouse_cursor` phải gọi an toàn hoặc bỏ qua khi `DisplayServer.get_name() == "headless"`.
- [x] Task 6: Test (AC: 1 đến 15, 17, 19)
  - [x] 6.1 Mới `game/tests/test_ui_style.gd`: `panel()`, `tooltip()`, `button(state)` trả `StyleBoxTexture` đúng hình **có thật** (so với tên tệp viết tay, không so hằng với hằng) và lề dương; bốn trạng thái nút ra bốn kiểu khác nhau; mọi đường dẫn biểu tượng và chân dung mở được; **`Art.reset_for_test()` đầu test** (bài học review 8.2) và không có dòng `[ERROR][hinh]`.
  - [x] 6.2 (BỎ cùng Task 5) Mới `game/tests/test_cursor_art.gd`: `kind_for` đủ ba nhánh và thứ tự ưu tiên (tướng chọn được > ô địch đánh được > mặc định); ba hình con trỏ mở được và cỡ 32×32; `apply` không ném lỗi khi headless.
  - [x] 6.3 `test_hud` (hoặc `test_main.gd`, nơi đang kiểm `Hud`): mỗi nút của `Hud` có đủ 4 stylebox là `StyleBoxTexture`; nút mưu kế có `icon` đúng hình theo kiểu mưu kế; dòng Lòng dân có biểu tượng khi trận có làng và ẩn khi không; dòng nhiệm vụ đúng chữ theo kiểu trận. Kiểm hành vi thật (đọc `Button.icon`, `get_theme_stylebox`), không kiểm hằng.
  - [x] 6.4 `test_tooltip.gd` (thêm, không sửa test cũ): có chân dung thì khung rộng hơn và chân dung hiện; không có thì ẩn và cỡ như cũ; `text()` vẫn trả chuỗi gốc; khung vẫn nằm trong màn hình khi trỏ sát mép phải/dưới.
  - [x] 6.5 Test nối `BattleView`: rê lên tướng Đại Việt → tooltip có chân dung; rê lên quân Nguyên → không; rê lên địa hình → không.
  - [x] 6.6 Sửa test cũ buộc phải sửa (nếu có test kiểm `StyleBoxFlat`) và ghi vào Completion Notes.
  - [x] 6.7 `tools/test.sh` xanh (gồm `check_boundaries.sh`, `test_assets.gd`, khóa `text.csv`).
- [ ] Task 7: Duyệt bằng mắt (AC: 16, 20)
  - [ ] 7.1 Chạy `tools/chay.sh --dev --tran=N` ở chế độ nền (trận có làng, có mưu kế, trận có Cung kỵ), chụp bằng GoPeak `capture_screenshot`, lưu `anh/8-5-*.png`. Xong thì tắt game. Gợi ý từ 8.3 và 8.4: chuột giả bấm được khi gửi **cặp nhấn rồi nhả**; ảnh chụp chỉ cập nhật sau khi có một lần `inject_mouse_motion`; phím giả và việc bắt giữa lúc hoạt ảnh thì **không** làm được.
  - [ ] 7.2 Ghi vào Completion Notes: chữ nào đọc khó, khung nào lệch, chân dung có che chữ không, con trỏ nào lệch điểm bấm.
  - [ ] 7.3 Nếu khung hoặc nút làm bàn cờ bị che hay lệch bố cục (`BoardView.AREA`), **dừng và báo tác giả**, đừng đổi `PANEL_POSITION` của `Hud` tùy ý.

## Dev Notes

### Hiện trạng cần đọc trước khi code (kiểm 2026-11-01, commit `43f69fc`)

- **Chưa có chỗ nào dùng hình giao diện.** `grep` `tex_icon_*`, `tex_nut_*`, `tex_khung_*`, `tex_con_tro_*`, `tex_nhiem_vu_*`, `tex_chan_dung_*`, `tex_ke_*` trong `src/` không ra gì: 8.1 chỉ đặt hình vào kho. Mọi khung hiện là `StyleBoxFlat` dựng bằng code (`tooltip.gd:44`, `hint_panel.gd:65`, `result_banner.gd:39`, `notice.gd:28`); nút là `Button` mặc định theo `assets/theme/main_theme.tres` (chỉ khai font và `TitleLabel`, project setting `gui/theme/custom`).
- **`assets/theme/main_theme.tres`** chỉ có font (Be Vietnam Pro regular 16, bold cho `TitleLabel` cỡ 28). Cách làm khuyến nghị: gắn kiểu nút bằng `UiStyle.apply_button` ở chỗ dựng nút (đúng kiểu "dựng bằng code, không cần mở editor" của dự án). Nếu thấy gắn một lần vào `Theme` gọn hơn (Button/PanelContainer type variation), được phép, nhưng ghi lý do vào Completion Notes và đừng bắt tác giả mở editor.
- `src/ui/hud.gd` (268 dòng): bảng bên phải, `PANEL_POSITION = (972, 52)`, `PANEL_WIDTH = 260`, `BUTTON_HEIGHT = 44`; `_button(text, parent)` là chỗ tạo mọi nút; nút mưu kế tạo trong `show_stratagems`; nút phải vẫn **không nhận focus**. Dòng Lòng dân là `_morale_label` (ẩn khi trận không có làng); `morale_text()`, `round_text()` được test cũ dùng, giữ nguyên.
- `src/ui/tooltip.gd` (144 dòng): `PanelContainer` + một `Label`, tự ngắt dòng bằng `_fit_width` (đã sửa lỗi cột cao ở `85d67c1`), `place_at` lật khi sát mép, `text()` và `visible_now()` cho test. Nội dung tooltip do `BattleView._unit_text` tạo (tên, "Máu x/y" qua `tooltip.hp`, đòn sắp đánh).
- `src/battle/battle_view.gd` (531 dòng): `_update_info(cell)` gọi `_tooltip.show_text(...)`; `_unit_text`, `_attack_text`, `_terrain_text`. Đây là chỗ biết ô đang trỏ và quân ở đó, nên chỗ nối chân dung và con trỏ. `_playing` chặn rê chuột trong lúc phát hoạt ảnh; không đổi.
- **Hình có sẵn** (`assets/textures/giao_dien/`): `tex_khung_bang_48x48.png` (D1, lề 8), `tex_khung_tooltip_32x32.png` (lề 6), `tex_nut_9slice_{normal,hover,pressed,disabled}.png` (32×24), `tex_nut_{normal,hover,pressed,disabled}.png` (80×24, bản không 9-slice, **không dùng**), `tex_icon_mau.png` (24), `tex_icon_long_dan.png` (24), `tex_ke_vuon_khong_nha_trong.png`, `tex_ke_sat_that.png` (32), `tex_nhiem_vu_{tieu_diet,giu_ai}_{24x24,32x32}.png`, `tex_con_tro_{mac_dinh,chon_tuong,tan_cong}.png` (32), `tex_so_to_sheet_156x16.png`, `tex_so_nho_sheet_104x10.png` (bảng chữ số, **không dùng**: chữ số vẫn do `Label` vẽ). `tex_trien_*` (thắng/thua) và `tex_khung_chon_tuong_64x64`, `tex_khung_o_di_duoc_64x64`, `tex_khung_o_danh_duoc_64x64`, `tex_mui_ten_xung_phong_*` **không thuộc story này** (xem dưới). Chân dung: `assets/textures/chan_dung/tex_chan_dung_{khoai,lao,du}.png` (96×96, bản `_khung` để dành).
- **Hiệp**: tác giả đã thêm `tex_hiep_24x24.png` (kho `giao_dien/`, có `.import`); kiểm dòng CREDITS của D6 đã phủ hình này chưa. **Nhiệm vụ**: HUD hiện chưa có dòng nhiệm vụ nào (kiểu trận chỉ nằm trong file trận); AC 10 thêm một dòng nhỏ để biểu tượng có chỗ đứng.
- **Con trỏ**: Godot 4.7 `Input.set_custom_mouse_cursor(image, shape, hotspot)`; hình tối đa 256×256 (khuyến nghị ≤ 128 trên web); `hotspot` là điểm bấm trong hình. Tra Context7 `/godotengine/godot-docs/__branch__4.7` trước khi dùng (theo `CLAUDE.md`). Trên web con trỏ tùy chỉnh theo trình duyệt; không hỗ trợ thì quay về con trỏ hệ thống.

### Rủi ro và việc cần xem bằng mắt (báo tác giả)

- **Chữ chìm trên nền 9-slice.** Khung sơn mài đen viền đồng có thể làm chữ vàng/trắng nhìn khác `StyleBoxFlat` cũ (`Color(0.06,0.05,0.04,0.92)` và viền vàng). Xem bằng ảnh chụp; nếu khó đọc thì chỉnh màu chữ, đừng đổi font hay cỡ.
- **Khung 9-slice phình cỡ.** Lề texture cộng với `content_margin` có thể làm bảng cao hơn: bảng Hud có nhiều nút, cao tối đa tới `BOTTOM_LIMIT = 714`. Đo lại ở trận có cả hai mưu kế (nhiều nút nhất).
- **`Tooltip` cao như cột.** Đừng đổi `autowrap_mode` của `Label`; giữ `_fit_width`. Khi thêm `TextureRect` chân dung, chiều cao khung = max(chân dung, chữ), kiểm bằng test cỡ khung (bài học `85d67c1`).
- **Con trỏ lệch điểm bấm.** Mũi tên cần hotspot ở góc, vòng ngắm và mũi kiếm ở tâm. Nếu hình thật có mũi ở chỗ khác, nhìn ảnh rồi chỉnh hotspot; ghi số vào Completion Notes.
- **Con trỏ kẹt.** Đổi loại khi rê khỏi bàn, hết trận, mở bảng gợi ý; kiểm đủ các đường thoát.
- **Nút bị đổi cỡ.** 9-slice co giãn; nút cao 44 px (`BUTTON_HEIGHT`) từ hình 24 px: viền dày gấp ~1,8 lần. Nếu nhìn thô, thử chia `BUTTON_HEIGHT` theo bội 24 (48) và báo tác giả; đừng tự đổi bố cục.
- **Tên khóa dịch.** Chỉ thêm khóa cho AC 10 (`hud.mission.*`) vào `i18n/text.csv`; `test_i18n`/khóa dịch phải xanh.

### Luật dự án áp dụng (từ `project-context.md`)

- Chỉ cú pháp Godot 4, gõ kiểu tĩnh mọi nơi (`untyped_declaration` là error). Giá trị từ `Dictionary` phải ép kiểu tường minh.
- Hình nạp qua `Art.tex()`; lỗi nạp ghi `Log.error("hinh", ...)` tiếng Việt. Không `print`, không `randi`/`randf`.
- **Scene nhỏ và phẳng**, mọi UI dựng bằng code; không việc nào đòi tác giả mở editor. Không `get_node("/root/...")`.
- **Đi xuống thì gọi hàm, đi lên thì phát signal.** Không Event Bus. `app_state.gd` là autoload duy nhất.
- Input: mọi thao tác làm được bằng **một cú bấm chuột**; phím tắt qua InputMap. Con trỏ chỉ là hiển thị.
- Mọi chữ hiển thị qua `tr()` và `i18n/text.csv`, khóa dạng `<man>.<muc>`. Chữ tiếng Việt đủ dấu.
- Không đụng `src/core`. `check_boundaries.sh` cấm lõi luật import code vẽ; `UiStyle`, `CursorArt` nằm trong `src/ui/`.
- Không object pool, `Thread`, `WorkerThreadPool`. Renderer Compatibility: chỉ `StyleBoxTexture`, `draw_texture`, không shader mới.
- Không thêm thư viện, không đổi Godot (4.7.2 ghim), không đổi tên file hình. Mỗi file mới có `.uid` do Godot sinh (chạy game hoặc test một lần rồi commit).
- Nói với tác giả bằng tiếng Việt, theo cách người test hiểu được (xem "Cách tác giả thử").

### Cách tác giả thử (cho báo cáo cuối của dev)

1. `tools/chay.sh --tran=1`: **thấy** bảng bên phải có khung sơn mài viền đồng, các nút có nền nút mới; rê chuột lên nút thì viền vàng; nút Hủy mờ khi chưa có gì để hủy.
2. Rê chuột lên **Nguyễn Khoái**: **thấy** khung thông tin có chân dung bên trái, tên, biểu tượng máu cạnh dòng máu, dòng đòn sắp đánh. Rê lên **quân Nguyên**: khung không có chân dung.
3. Con trỏ: **thấy** mũi tên đồng khi ở ngoài; **vòng ngắm** khi rê lên tướng; chọn tướng rồi rê lên quân địch đánh được thì **mũi kiếm**.
4. Trận có làng (xem bàn của trận đó): **thấy** biểu tượng mái nhà cạnh "Lòng dân". Dưới số hiệp có dòng nhiệm vụ kèm biểu tượng (Tiêu diệt hoặc Giữ ải).
5. Trận có hai mưu kế (Q/W): **thấy** biểu tượng đuốc và biểu tượng Sát Thát trên hai nút mưu kế. Dùng một mưu kế: nút mờ.
6. Bấm `?`: bảng gợi ý có khung mới, chữ vẫn đọc rõ. Thắng hoặc thua: bảng kết quả có khung mới.
7. Bật dev (`--dev`): FPS không tụt rõ so với trước story này.

### Việc thuộc story khác (đừng làm ở đây)

- Màn hình chính (cảnh Bạch Đằng, logo), màn chuyển trận (biểu tượng nhiệm vụ 32×32, tranh chuyển cảnh), biểu tượng game, ảnh bìa itch.io: 8.6.
- Tiếng, nhạc, nút tắt tiếng: 8.7.
- Hình thắng/thua `tex_trien_*`: để 8.6 hoặc story riêng khi tác giả chốt (xem Câu hỏi 5). Ở đây `ResultBanner` chỉ đổi khung và nút.
- Ô sáng, ô đỏ báo đòn, số thứ tự, vòng chọn, đường đi, chấm máu: vẫn vẽ bằng code (NFR9), không đụng. Các khung ô `tex_khung_*_64x64` và mũi tên xung phong **không dùng** ở story này.
- Tiểu sử và chữ trong bảng tướng ngoài những gì đang có: chờ tác giả chốt.
- Thủy chiến, thuyền: Epic 7.

### Project Structure Notes

- Mới: `game/src/ui/ui_style.gd`, `game/src/ui/cursor_art.gd` (+ `.uid` mỗi file), `game/tests/test_ui_style.gd`, `game/tests/test_cursor_art.gd` (+ `.uid`).
- Sửa: `game/src/ui/hud.gd`, `tooltip.gd`, `hint_panel.gd`, `result_banner.gd`, `notice.gd`, `level_transition.gd`, `main_menu.gd`, `error_screen.gd`, `game/src/battle/battle_view.gd` (chân dung, con trỏ), `game/i18n/text.csv` (khóa `hud.mission.*`), `game/tests/test_tooltip.gd` (chỉ thêm) và test của `Hud`/`Main` nếu cần.
- Không sửa: `src/core/*`, `battle_controller.gd`, `event_player.gd`, `board_view.gd`, `unit_token.gd`, `fx_*`, `ground_*`, `data/*`, `assets/*` (không thêm hình).
- Theo mẫu `Art` (8.1), `GroundArt` (8.2), `UnitArt` (8.3), `UnitAnim`/`FxArt` (8.4): hàm tĩnh chọn hình nằm riêng để tác giả thay hình ở một chỗ.

### Previous Story Intelligence (8.1 đến 8.4)

- **Test tautology bị bắt ở 8.2 và 8.3:** so hằng với hằng, tự tính kết quả mong đợi bằng chính hàm đang thử. Test phải so với **tên tệp thật viết tay** và **hành vi** (đọc `Button.icon`, `get_theme_stylebox`, `Tooltip.size`).
- **`Art._cache` và `_reported` là static:** luôn `Art.reset_for_test()` đầu test.
- **Kiểm null** cho thứ dựng trong `_ready` khi hàm được gọi sớm (`_tooltip` có thể `null` trong test; `Hud` dựng nút trong `_ready`).
- **Task chụp ảnh đánh `[x]` khi chưa chụp đủ** là lỗi lặp lại ở 8.2, 8.3: chỉ tick khi có ảnh; không chụp được thì ghi "tác giả tự xem".
- **Chụp ảnh qua GoPeak (kinh nghiệm 8.3/8.4):** `inject_mouse_click` phải gửi cặp `pressed: true` rồi `pressed: false`; ảnh chụp có thể cũ cho tới khi có thêm một `inject_mouse_motion`; phím giả (Space) không có tác dụng; ảnh lệch vài giây nên không bắt được giữa hoạt ảnh.
- **Bài học `85d67c1`:** đừng dùng `autowrap` của `Label` trong `PanelContainer` tự co; khung thông tin phải tự ngắt dòng.
- **Công tắc hằng ở đầu file** (`SHOW_NAMES`, `ANIMATE_CLIPS`, `FxLayer.ENABLED`): đề xuất cho 8.5 `UiStyle.ENABLED: bool = true` (false thì quay về `StyleBoxFlat` cũ) và `CursorArt.ENABLED: bool = true`, để tắt nhanh khi nghi giao diện mới gây lỗi.
- **Tác giả hay đổi hình sau khi xem ảnh:** giữ đường dẫn hình giao diện ở một chỗ (`UiStyle`, `CursorArt`).

### Git Intelligence

- `138d11a` (8.4) và `3f95854` (8.3): mẫu thêm lớp chọn hình thuần (`UnitArt`, `UnitAnim`, `FxArt`) + test riêng + nối vào view hiện có. Làm 8.5 theo đúng khuôn.
- `85d67c1`: sửa khung thông tin tự ngắt dòng; đọc `test_tooltip.gd` trước khi đụng `Tooltip`.
- Cây làm việc sạch sau `43f69fc`. Mỗi story một commit riêng, lời commit tiếng Việt, chỉ commit khi `tools/test.sh` xanh và khi tác giả bảo.

### Latest Tech

- Godot 4.7.2 (ghim, không nâng). `StyleBoxTexture`: `texture`, `texture_margin_left/top/right/bottom` (hoặc `set_texture_margin_all`), `content_margin_*`, `axis_stretch_horizontal/vertical`, `region_rect`. `Button.icon`, `icon_alignment`, `expand_icon`, `Button.add_theme_stylebox_override("normal"|"hover"|"pressed"|"disabled"|"focus", ...)`. `Input.set_custom_mouse_cursor(image: Resource, shape: CursorShape, hotspot: Vector2)`. Nếu API lạ thì tra Context7 `/godotengine/godot-docs/__branch__4.7` trước khi dùng (theo `CLAUDE.md`).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 8.5]
- [Source: _bmad-output/planning-artifacts/art-reference/danh-sach-hinh-e8.md#D. Giao diện, #E. Chân dung]
- [Source: _bmad-output/planning-artifacts/art-reference/ban-giao-asset.md]
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/8-4-hoat-anh-va-hieu-ung.md]
- [Source: _bmad-output/implementation-artifacts/8-3-quan-dung-yen.md#Review Findings]
- [Source: game/src/ui/hud.gd, tooltip.gd, hint_panel.gd, result_banner.gd, notice.gd, level_transition.gd, art.gd]
- [Source: game/src/battle/battle_view.gd#_update_info, #_unit_text]
- [Source: game/assets/theme/main_theme.tres]

## Câu hỏi cho tác giả

Dev làm theo mặc định; tác giả đổi được sau khi xem ảnh.

1. **Chân dung hiện ở đâu?** Mặc định: trong **khung thông tin khi rê chuột lên tướng Đại Việt** (chân dung 96×96 bên trái, chữ giữ như hiện nay). Cách khác: một bảng riêng cố định bên phải khi chọn tướng (to hơn, có thể thêm tiểu sử), hoặc dùng bản có khung `_khung`. Nội dung chữ thêm (tiểu sử, câu thoại, chỉ số) đang chờ tác giả: story này **không** thêm.
2. **Biểu tượng hiệp.** ~~Kho không có~~ Đã chốt 2026-11-01: tác giả thêm `tex_hiep_24x24.png`, dùng ở AC 9.
3. **Dòng nhiệm vụ trên bảng bên phải.** Hiện chưa có. Mặc định: thêm một dòng nhỏ dưới số hiệp ("Tiêu diệt" hoặc "Giữ ải" kèm biểu tượng) để có chỗ dùng biểu tượng nhiệm vụ, lấy từ kiểu trận đã có (không đổi luật). Cách khác: không thêm dòng, để biểu tượng nhiệm vụ cho màn chuyển trận (8.6).
4. **Con trỏ chuột.** Mặc định: ba con trỏ theo ngữ cảnh (mũi tên, vòng ngắm khi rê lên tướng, mũi kiếm khi rê lên địch đánh được). Cách khác: chỉ đổi con trỏ mặc định, bỏ hai cái còn lại cho gọn.
5. **Hình thắng/thua (`tex_trien_*`).** Kho có sẵn nhưng không nằm trong tiêu chí 8.5. Mặc định: bảng thắng/thua chỉ đổi khung và nút, giữ chữ. Cách khác: dùng hình thắng/thua trong story này (thêm khoảng nửa ngày) hoặc để 8.6.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5

### Debug Log References

- `tools/test.sh`: 987/987 đạt (973 cũ + 14 mới). Chạy game `--dev --tran=4`: log 0 dòng ERROR, FPS 96 đến 99.

### Completion Notes List

- **Làm xong:** `UiStyle` (khung bảng, khung tooltip, nút 4 trạng thái, đường dẫn biểu tượng và chân dung ở một chỗ, công tắc `UiStyle.ENABLED`). Nút của `Hud`, `HintPanel`... `ResultBanner`, `MainMenu`, `LevelTransition`, `ErrorScreen` dùng nút 9-slice; khung bảng ở `Hud` (khung mới nhô 12 px quanh cột nút), `HintPanel`, `ResultBanner`, `Notice`; `Tooltip` dùng khung tooltip. HUD có biểu tượng hiệp, Lòng dân, nhiệm vụ (dòng mới "Tiêu diệt"/"Giữ ải", khóa `hud.mission.*`), nút mưu kế có biểu tượng. Khung thông tin: chân dung 96×96 cho tướng Đại Việt, biểu tượng máu trước dòng "Máu" (quân và tướng).
- **Lề 9-slice đã chọn (đo ảnh):** khung bảng 8, tooltip 6, nút 4 (viền nút 2 px), lề trong nút 8.
- **Quyết định nhỏ:** `Hud` chưa từng có khung nên thêm `Panel` phía sau cột (AC 3 viết "thay" nhưng chỗ đó không có gì để thay). `Tooltip` đặt biểu tượng máu bằng cách chừa dấu cách đầu dòng "Máu" và đặt `TextureRect` đúng dòng; `text()` vẫn trả chuỗi gốc. `Hud.show_turn` thêm tham số cuối `mission` (mặc định -1, test cũ không đổi), `BattleView` truyền `snapshot.mission`.
- **Test cũ:** không sửa test nào. Test mới: `test_ui_style.gd` (14 test: khung, nút, biểu tượng, HUD, tooltip) và 1 test nối `BattleView` trong `test_battle_view.gd` (rê tướng có chân dung, quân Nguyên và địa hình không).
- **Task 5 (con trỏ chuột) BỎ theo tác giả 2026-11-01** (chọn bỏ khỏi 8.5, giữ con trỏ hệ thống). Lý do: ba hình `tex_con_tro_*` **không phải con trỏ**: `mac_dinh` là một bàn tay cầm kiếm đỏ chéo, `chon_tuong` là huy hiệu tròn có hình con thú, `tan_cong` là cả một chiến binh cầm kiếm (32×32). Không khớp mô tả D7 (mũi tên đồng, vòng ngắm, mũi kiếm chữ thập). Dùng làm con trỏ sẽ không rõ điểm bấm. Không viết `CursorArt`, không làm 6.2. Ba hình vẫn nằm trong kho, chờ vẽ lại ở story khác nếu tác giả muốn.
- **Ảnh chụp đã lưu:** `anh/8-5-hud-tran4.png` (bảng bên phải: khung, nút, hiệp, nhiệm vụ, Lòng dân), `anh/8-5-thong-tin-tuong.png` (khung thông tin Nguyễn Khoái: chân dung, biểu tượng máu). **Chưa chụp:** nút mưu kế có biểu tượng (cần trận mở mưu kế), bảng gợi ý `?`, bảng thắng/thua, khung thông tin quân Nguyên, nút ở trạng thái rê chuột. Task 7 để mở: còn thiếu ảnh nêu trên, tác giả xem trong game.

### File List

- Mới: `game/src/ui/ui_style.gd` (+ `.uid`), `game/tests/test_ui_style.gd` (+ `.uid`), `_bmad-output/implementation-artifacts/anh/8-5-hud-tran4.png`, `8-5-thong-tin-tuong.png`
- Sửa: `game/src/ui/hud.gd`, `tooltip.gd`, `hint_panel.gd`, `result_banner.gd`, `notice.gd`, `level_transition.gd`, `main_menu.gd`, `error_screen.gd`, `game/src/battle/battle_view.gd`, `game/i18n/text.csv` (+ `text.vi.translation` do Godot sinh), `game/tests/test_battle_view.gd`

## Change Log

- 2026-11-01: Tạo story 8.5 (Ultimate context engine).
- 2026-11-01: Tác giả bỏ con trỏ khỏi 8.5; chuyển `review`, Task 7 còn mở (thiếu vài ảnh).
- 2026-11-01: Làm Task 1 đến 4 và phần lớn Task 6 (khung, nút, biểu tượng, chân dung). Dừng ở Task 5 vì ba hình con trỏ không phải con trỏ; Task 7 chưa đủ ảnh.
