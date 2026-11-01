---
baseline_commit: b66d6fc
---

# Story 4.8: Gợi ý luật đầu trận

Status: review

## Story

Là người chơi lần đầu,
tôi muốn được nhắc ngắn gọn luật của trận và các phím,
để chơi được mà không cần ai giải thích.

_Đây là phần hướng dẫn của prototype (tác giả chốt 2026-10-18): trận 1–2 là trận dạy chơi, luật mới của mỗi trận được giới thiệu bằng gợi ý này. Không cắt._

## Acceptance Criteria

(Nguồn: `epics.md` Story 4.8, FR43 "mỗi trận dạy một luật mới", GDD "Controls and Input" và "Campaign Structure". Mục có chữ **[Chờ tác giả]** là chỗ epic chưa nói rõ: bản dưới đây là đề xuất, tác giả duyệt hoặc sửa ở "Câu hỏi cho tác giả" trước khi code.)

1. **Gợi ý theo trận.** File trận có khóa tùy chọn `"goi_y"`: mảng 1–2 **khóa dịch** (ví dụ `["hint.tran_01.1", "hint.tran_01.2"]`), không chứa chữ. Chữ nằm trong `i18n/text.csv`. `LevelLoader` đọc khóa này vào `LevelData` (thêm `goi_y` vào `KNOWN_KEYS`, kiểm kiểu: mảng chuỗi, 1–2 phần tử, không rỗng; sai thì lỗi nêu tên file và khóa như các khóa khác). Không có `goi_y` thì trận chạy như cũ, không hiện gì. Khóa dịch không có trong `text.csv` là lỗi **ở test dữ liệu** (không phải lỗi lúc chạy): test quét mọi file trận trong `chien_dich.json`.
2. **Hiện khi bắt đầu trận.** Trận có `goi_y` thì một bảng hiện giữa bàn cờ **ngay khi pha địch mở trận chạy xong** (người chơi bắt đầu lượt của mình), 1–2 dòng gợi ý, không che cột nút bên phải. **[Chờ tác giả: Câu hỏi 2]** Hiện cả khi "Đánh lại trận này" (nút thua/thắng) và khi `--dev --tran=N`; không hiện lại khi "Chơi lại hiệp" (R) hay F5 giữa trận.
3. **Tắt bằng một cú bấm.** Bấm chuột trái **ở bất cứ đâu** trong cửa sổ thì tắt bảng. Cú bấm đó **chỉ tắt bảng**, không chọn tướng, không đi, không đánh (bảng nuốt cú bấm). Trong lúc bảng đang hiện, phím tắt của trận (1 2 3, Z, R, Q, W, Space, T) **không có tác dụng**; chỉ `Esc`, `?` tắt bảng. **[Chờ tác giả: Câu hỏi 3]**
4. **Nút "?" và phím `?`.** Cột nút bên phải có nút **"?"** (cùng kiểu và `FOCUS_NONE` như các nút khác), phím tắt `?` (bấm Shift+`/`; nhận bằng ký tự `?` chứ không bằng vị trí phím, để đúng cả bàn phím Việt, Mỹ). Bấm thì hiện bảng gồm hai phần: (a) gợi ý của trận (nếu có), (b) **bảng thao tác và phím tắt** theo bảng Controls của GDD: Chọn tướng (bấm tướng, `1` `2` `3`), Đi (bấm ô sáng), Đánh (bấm mục tiêu trong tầm; đã đi rồi thì bấm thêm lần nữa để xác nhận), Xem thông tin (rê chuột), Mưu kế (`Q` `W`), Hủy nước đi (`Z`), Kết thúc lượt (`Space`), Chơi lại hiệp (`R`), Tua nhanh (`T`). Tắt như AC 3. Nút "?" bấm được cả khi đang phát hoạt ảnh pha địch (như nút Tua nhanh, để không phải chờ).
   - Bảng lúc **tự hiện đầu trận** (AC 2) chỉ có phần (a) gợi ý và một dòng nhắc "Bấm ? để xem phím tắt". Trận không có `goi_y` thì không tự hiện gì; bấm "?" thì chỉ có phần (b).
5. **Nội dung gợi ý cho 6 trận** (đề xuất; tác giả sửa chữ nếu muốn; ≤ 2 dòng mỗi trận, mỗi dòng ≤ khoảng 100 ký tự để vừa bảng):
   - Trận 1: "Ô đỏ là nơi địch sắp đánh. Nguyễn Khoái đẩy được địch xuống sông." (epic)
   - Trận 2: "Kỵ binh xung phong thẳng hàng: đứng ra khỏi hàng hoặc dùng rừng chặn đường. Địch đánh trúng nhau được."
   - Trận 3: "Trần Khánh Dư kéo địch về phía mình; hầm chông làm mất 1 máu." / "Hết số hiệp (hiện ở bảng bên phải) mà còn quân Nguyên là thua."
   - Trận 4: "Bảo vệ làng: mỗi lần làng bị đánh, Lòng dân giảm 1. Hết Lòng dân là thua." (epic)
   - Trận 5: "Giữ ải: sống hết hiệp cuối và không để quân Nguyên vào ô ải. Cuối hiệp có ô báo tiếp viện." / "Kho lương chặn đòn; Vườn không nhà trống (Q) đốt kho lương và trừ máu địch."
   - Trận 6: "Tổng hợp mọi luật đã học; quân tiếp viện đến mỗi hiệp." / "Sát Thát (W): đòn của tướng +1 sát thương trong lượt đó."
   Không viết cứng số hiệp, số quân hay chỉ số vào chữ gợi ý (ADR-006: con số do tác giả cân bằng trong `chi_so.json`, chữ không được lệch). Chữ chỉ nói luật, không nói con số chỉ số.
6. **Giao diện.** Bảng dựng bằng code như `ResultBanner`/`LevelTransition` (nền tối trong suốt nhẹ, viền, chữ sáng), nằm **trên** bàn cờ, HUD, tooltip và dưới `Notice` và bộ đếm FPS/nhãn phiên bản; chữ vừa đọc (≥ 18 pt cho gợi ý). Không che hẳn bàn cờ: bảng ở nửa dưới bàn. Chữ qua `tr()`, khóa `<màn>.<mục>` (`hint.*`, `help.*`). Không có kéo thả (NFR8).
7. **Không phá cái đã có.** Mọi test hiện có chạy `Main`/`BattleView` và bấm bàn cờ **không bị gợi ý chặn**: có một công tắc chung (đề xuất `AppState.hints_enabled`, mặc định `true`; `tests/pre_run.gd` đặt `false`, test của 4.8 tự bật lên) để test cũ giữ nguyên hành vi. Không sửa luật (`src/core/` chỉ thêm trường `goi_y` vào `LevelData` nếu cần), không sửa `chi_so.json`, không sửa kịch bản `da_duyet: true`.
8. **Và** test GUT và `tools/test.sh` xanh (kể cả `check_boundaries.sh`). Commit tiếng Việt kết `(Story 4.8)`. Tác giả thử tay (xem Task 5) rồi mới `done`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–4** (cuối file) và duyệt chữ gợi ý ở AC 5.
- [x] **Task 1: Dữ liệu `goi_y`** (AC: 1, 5)
  - [x] 1.1 `LevelData` thêm `hints: Array[String]` (khóa dịch). `LevelLoader`: `"goi_y"` vào `KNOWN_KEYS`, `_read_hints` kiểm mảng 1–2 chuỗi không rỗng, lỗi mẫu `'%s: "goi_y" ...'` như `_read_name`/`_read_max_rounds`. Không có khóa thì `hints = []`.
  - [x] 1.2 Thêm `goi_y` vào 6 file `data/tran/tran_01..06.json` (trận thử `thu_*` không cần). Thêm khóa `hint.tran_0N.M` vào `i18n/text.csv` đúng chữ AC 5 (sau khi tác giả duyệt). Nhớ chép lại `text.vi.translation` (như 4.7: chạy `tools/test.sh` hoặc `--import` sinh lại file).
  - [x] 1.3 Test loader: khóa hợp lệ, thiếu khóa, sai kiểu (chuỗi thay vì mảng, phần tử số, mảng rỗng, 3 phần tử). Test dữ liệu: mọi trận trong `chien_dich.json` có `goi_y` (theo Câu hỏi 1), mọi khóa có trong `text.csv` (`TranslationServer.translate(key) != key`), mỗi dòng ≤ 120 ký tự.
- [x] **Task 2: Bảng gợi ý** (AC: 2, 3, 4, 6)
  - [x] 2.1 Tạo `game/src/ui/hint_panel.gd` (`class_name HintPanel`, `Control` toàn cửa sổ, `mouse_filter = STOP`, ẩn mặc định; theo mẫu `result_banner.gd`/`level_transition.gd`, người gọi đặt `size`). API: `show_hint(keys: Array[String])` (phần gợi ý + dòng nhắc "?"), `show_help(keys: Array[String])` (gợi ý nếu có + bảng thao tác), `hide_panel()`, `is_open()`. Tín hiệu `closed`.
  - [x] 2.2 `_gui_input`: chuột trái bấm bất kỳ → đóng, `accept_event()`. Phím `Esc`/`?` đóng. Chữ bảng thao tác lấy từ khóa `help.*` trong `text.csv` (9 dòng của AC 4, mỗi dòng "Thao tác — chuột — phím").
  - [x] 2.3 Chặn phím trận khi đang mở: `BattleInput.set_process_unhandled_input(false)` (hoặc cờ `blocked`) khi `open`, bật lại khi `closed`; không đổi tên hay hành vi action đã có. Nhớ bật lại khi chuyển màn (menu, màn chuyển trận, màn lỗi): bảng đóng khi rời trận.
  - [x] 2.4 `Hud` thêm nút "?" (`hud.help`), tín hiệu `help_pressed`; không bị `set_locked` khóa (như nút Tua nhanh, `_fast_button`). Phím `?` nhận trong `BattleInput` (hoặc `main.gd` `_unhandled_input`) qua `InputEventKey.unicode == 63`, không echo; không dùng `physical_keycode` (layout).
- [x] **Task 3: Nối vào `main.gd`** (AC: 2, 3, 7)
  - [x] 3.1 Dựng `HintPanel` trong `main.tscn`/`_ready` (như `_result_banner`), thứ tự: trên `_board_view`, `_hud`, `_tooltip`, `_result_banner`, `_level_transition`; dưới `Notice` và `_version_label`, `FpsOverlay` (CanvasLayer). Cập nhật `test_transition_layer_order` nếu thứ tự lớp đổi (đã có test thứ tự lớp ở `test_main.gd`).
  - [x] 3.2 Hiện gợi ý khi pha địch mở trận phát xong (`_on_playback_finished` lần đầu của trận, xem `main.gd:266`): chỉ lần đầu của mỗi lần `_start_battle()`, không phải mỗi pha. `AppState.hints_enabled` false thì bỏ qua. Không hiện khi `Chơi lại hiệp`, F5 giữa trận. Đóng bảng khi `_stop_battle()`/`_show_menu()`/`_show_transition()`.
  - [x] 3.3 `tests/pre_run.gd` đặt `AppState.hints_enabled = false` (như `SaveSystem.path`), để test cũ không bị chặn; test mới tự bật.
- [x] **Task 4: Test GUT** (AC: 1–4, 7)
  - [x] 4.1 `tests/test_hint_panel.gd`: mở/đóng bằng bấm chuột (bấm xuyên không chọn tướng: kiểm sau bấm `_controller` không có lệnh mới), Esc, `?`; phím `Space` khi mở không kết thúc lượt; sau đóng thì phím lại hoạt động; chữ có đủ 9 thao tác; nút "?" bấm được khi `Hud.set_locked(true)`.
  - [x] 4.2 `test_main.gd`: mở trận 1 với `hints_enabled = true` → sau khi pha mở trận phát xong bảng hiện đúng chữ trận 1; "Chơi lại hiệp" (R) không hiện lại; "Đánh lại trận" hiện lại (theo Câu hỏi 2); trận không có `goi_y` thì không hiện; sang trận kế đóng bảng cũ.
  - [x] 4.3 Test phím `?` trên layout khác nhau: `InputEventKey` với `unicode = 63` và `physical_keycode` khác nhau đều mở.
- [ ] **Task 5: Chụp và bàn giao** (AC: 6, 8)
  - [x] 5.1 Chụp GoPeak `tools/chay.sh --dev --tran=1` (và 4, 6): bảng đầu trận, bảng "?" có bảng thao tác; kiểm chữ có dấu, không che cột nút, không tràn khung. (`inject_*` có thể không có tác dụng như 4.6: dùng script tạm trong scratchpad đẩy chuột bằng `root.push_input`.)
  - [x] 5.2 `tools/test.sh` xanh. Cập nhật Dev Agent Record, `sprint-status.yaml`.
  - [ ] 5.3 **Tác giả thử tay** (Cho/Khi/Thì): (a) `tools/chay.sh`, Chơi mới: thấy bảng trận 1 sau khi địch đi xong; bấm bất kỳ đâu → tắt, không có tướng nào bị chọn. (b) Gõ Space khi bảng đang hiện: không kết thúc lượt. (c) Bấm "?" hoặc gõ Shift+`/`: thấy bảng thao tác. (d) Qua trận 3, 4: bảng đúng chữ. Story chỉ `done` sau khi tác giả duyệt.

## Dev Notes

### Hiện trạng (đã kiểm 2026-11-01, HEAD `b66d6fc`)

- **Chưa có** gợi ý, bảng phím, nút "?". `grep -ri "hint"` chỉ ra `Hud.show_hint` (dòng nhắc "Bấm lần nữa để đánh", **khác**: đó là `_hint_label` nhỏ dưới nút; đừng nhầm hay dùng lại tên) và `GDD`.
- **Cột nút (HUD):** `src/ui/hud.gd`, dựng bằng code: Hủy (Z), Chơi lại (R) + nhãn "Còn 1 lần", mưu kế Q/W (chỉ trận mở), Kết thúc lượt (Space), Tua nhanh (T, `_fast_button` **không** bị `set_locked` khóa, mẫu cho nút "?"). Panel ở `(972, 52)`, rộng 260; bàn cờ nằm `x 16–956`.
- **Phím:** `src/battle/battle_input.gd` khai báo action bằng code (`ACTION_KEYS`, `_declare`), nhận ở `_unhandled_input` (nên một `Control` có `mouse_filter = STOP` nuốt cú bấm trước khi tới bàn cờ, như `ResultBanner`/`LevelTransition`). `?` không là action vì phụ thuộc layout: dùng `event.unicode`.
- **Mở trận:** `main.gd` `_start_battle()` (dòng ~172): nạp file trận → `_controller.start` → `_battle_view.begin_battle()` (pha địch mở trận có hoạt ảnh) → `_on_playback_finished(snapshot)` (dòng ~266) báo phát xong. Màn chuyển trận/menu dùng `_set_cover(...)`. `AppState` (autoload) giữ `launch`, `stats`, `settings`.
- **Dữ liệu trận:** `LevelLoader.KNOWN_KEYS` (`level_loader.gd:15`) liệt kê khóa hợp lệ; khóa lạ chỉ cảnh báo. File trận hiện có: `ten`, `kieu`, `dia_hinh`, `quan`, `thu_tu_dich`, `tiep_vien`, `muu_ke_mo`, `so_hiep_toi_da`, `long_dan`.
- **Luật mỗi trận dạy (GDD Campaign Structure, dòng 246–253):** T1 né ô đỏ, đẩy địch xuống sông; T2 Kỵ binh xung phong, rừng chặn, địch đánh trúng nhau; T3 Trần Khánh Dư, kéo, hầm chông, giới hạn hiệp; T4 làng và Lòng dân; T5 Giữ ải, kho lương, Vườn không nhà trống, tiếp viện; T6 tổng hợp, Sát Thát. Epic nói "mỗi trận dạy một luật mới": gợi ý 5–6 nên nhắc đúng mưu kế mở ở trận đó (`muu_ke_mo` T5 = Vườn không nhà trống; T6 = cả hai).
- **Lớp phủ khác đang có:** `Notice` (báo ngắn), `ResultBanner`, `LevelTransition`, `MainMenu`, `ErrorScreen`, và (dev) `FpsOverlay` (CanvasLayer 100), `CoordOverlay`, `AiIntentOverlay`.

### Rủi ro chính: test cũ bị bảng chặn (đọc trước khi code)

Rất nhiều test (`test_main.gd`, `test_battle_view.gd`, `test_stratagem_view.gd`, …) tạo `Main`, mở trận thật (`tran_01`…) rồi bấm bàn cờ hoặc gõ phím. Nếu bảng tự hiện và nuốt cú bấm/phím đầu thì hàng chục test đỏ vì lý do không liên quan. Vì vậy AC 7 đòi **công tắc chung** tắt mặc định trong test (`pre_run.gd`) và chỉ test của 4.8 mới bật. Đừng sửa từng test cũ. Đừng làm bảng "không chặn" để né: AC 3 đòi nuốt cú bấm.

### Kiến trúc phải giữ

- ADR-006: không viết con số chỉ số vào chữ gợi ý; chữ nói luật, không nói số (máu, sát thương, tầm). Epic cho phép nói "trong 4 hiệp" nhưng số hiệp có thể đổi trong file trận: dùng "hết số hiệp (hiện ở bảng bên phải)".
- UI chỉ **đọc**: bảng không biết luật, không gọi `Rules`; `src/core/` chỉ nhận thêm dữ liệu `goi_y` (không `FileAccess`, không `tr()`). `tools/check_boundaries.sh` bắt lỗi ranh giới.
- Chữ qua `tr()`, khóa `<màn>.<mục>`, bản địa hóa vào `i18n/text.csv` (NFR7). Log qua `Log.*`, không `print()`.
- NFR8: mọi thao tác bằng bấm chuột, không kéo thả; bảng này đóng bằng một cú bấm.
- Web đơn luồng: không `Thread`. Bảng không có hoạt ảnh nặng (một `show/hide`).

### Bài học từ story trước (4.4, 4.6, 4.7)

- **Test phải có thể trượt**: mỗi hành vi (đóng bằng bấm, nuốt cú bấm, chặn phím) cần một test mà bỏ dòng code đó thì trượt (kiểm đột biến: tạm bỏ `accept_event()` thì test "bấm xuyên" phải đỏ).
- `tr(key) % n` ném lỗi khi khóa chưa dịch: ở đây không format số, nhưng đừng viết `tr("…") % …`; kiểm khóa có dịch bằng test dữ liệu.
- Màn che/lớp: có sẵn `test_transition_layer_order` ở `test_main.gd` kiểm thứ tự lớp; thêm bảng gợi ý vào đúng chỗ rồi cập nhật test đó.
- macOS: `sed -i` cần `''`; ưu tiên Edit/Python. Khi sửa `i18n/text.csv`, file `text.vi.translation` được sinh lại khi nạp project (có trong commit).
- Dữ liệu trận đang `da_duyet` ở mức kịch bản, **không** ở file trận: thêm `goi_y` vào `data/tran/*.json` không đụng kịch bản nào; nhưng `tools/test.sh` bước 2 khóa theo `da_duyet: true` chỉ với file JSON có cờ đó, kiểm lại bằng chạy.

### Git gần đây

- `b66d6fc` đóng 4.7; `3c77ecc` bộ đếm FPS + đo; `810188a` đóng 3.13/3.14/4.5; `71d97fc` đóng 4.6. Mẫu commit: tiếng Việt, kết `(Story N.M)`, có dòng Co-Authored-By.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh (`untyped_declaration` là error); JSON số là `float` → `int()`; khóa JSON tiếng Việt không dấu (`goi_y`); code tiếng Anh `snake_case`.
- `Array.filter()` trả `Array` không kiểu: gán vào `Array[String]` lỗi, dùng vòng lặp `append`.
- Một lệnh test: `tools/test.sh`, tóm tắt tiếng Việt, mã thoát ≠ 0 là trượt. Cấm sửa kịch bản `da_duyet: true` để test đạt.
- Không test tự động cho phần chỉ là hình (căn lề, màu); test hành vi (mở/đóng, nuốt bấm, chặn phím, chữ). AI chụp GoPeak, tác giả thử tay.
- Nói với tác giả bằng tiếng Việt, theo các bước để thử, thấy gì là đúng.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.8] (dòng ~1352–1370); FR40, FR43; NFR7, NFR8; dòng 184 (4.8 không cắt)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md] "Controls and Input" (dòng 117–131), "Campaign Structure" (dòng 242–253)
- [Source: game/src/ui/hud.gd], [Source: game/src/ui/result_banner.gd], [Source: game/src/ui/level_transition.gd]
- [Source: game/src/battle/battle_input.gd], [Source: game/src/app/main.gd] (`_start_battle`, `_on_playback_finished`, `_set_cover`)
- [Source: game/src/data/level_loader.gd] (`KNOWN_KEYS`, `_read_name`, `_read_max_rounds`), [Source: game/src/core/level_data.gd]
- [Source: game/tests/pre_run.gd] (mẫu cô lập cho test), [Source: _bmad-output/implementation-artifacts/4-4-tua-nhanh-pha-dich.md] (mẫu nút HUD không bị khóa)

### Câu hỏi cho tác giả (trả lời trước khi code)

1. **Trận nào có gợi ý?** Epic bắt buộc trận 1, 3, 4 và nêu ví dụ; GDD nói "mỗi trận dạy một luật mới". Đề xuất: **cả 6 trận** (AC 5 đã soạn chữ). Hay chỉ 1, 3, 4 (trận 2, 5, 6 không gợi ý)?
2. **Khi nào hiện lại?** Đề xuất: hiện ở đầu mỗi lần mở trận (kể cả "Đánh lại trận này", `--dev --tran=N`), không hiện khi "Chơi lại hiệp" hay F5. Hay chỉ hiện **một lần đầu** cho mỗi trận (ghi vào file lưu), để người chơi lại không phải tắt nhiều lần?
3. **Trong lúc bảng đang hiện, phím trận (Space, Z, Q…) có làm gì không?** Đề xuất: không (chỉ Esc/`?` tắt), để người mới gõ nhầm không mất lượt. Hay phím vẫn chạy và đồng thời tắt bảng?
4. **Bảng thao tác bấm "?" có hiện cả gợi ý trận không?** Đề xuất: có (gợi ý ở trên, bảng phím ở dưới). Epic nói "bấm nút ? thì xem lại [gợi ý]" **và** "bấm phím ? hoặc nút ? thì hiện bảng thao tác", nên gộp thành một bảng. Hay hai nút riêng?

## Dev Agent Record

### Agent Model Used

### Debug Log References

- Tác giả chốt "theo đề xuất hết" (2026-11-01): cả 6 trận có gợi ý; hiện ở đầu mỗi lần mở trận (kể cả "Đánh lại trận này", `--dev --tran=N`), không hiện khi Chơi lại hiệp hay F5; phím trận bị nuốt khi bảng mở (chỉ Esc, ? tắt); bấm "?" hiện cả gợi ý và bảng thao tác.
- `tools/test.sh`: 905/905 (+13: `test_hint_panel` 8, `test_hints_data` 5). Đột biến: đổi `mouse_filter` bảng sang IGNORE và bỏ nuốt phím thì 5 assert của `test_hint_panel` trượt (bấm xuyên xuống tướng, Space kết thúc lượt).
- Lỗi thật tìm ra khi chụp GoPeak: nhãn tự xuống dòng không có bề rộng sẵn nên bảng cao 2439 px (nằm ngoài màn, test không thấy vì chỉ kiểm `is_open`). Sửa bằng `custom_minimum_size.x` cho nhãn. Chụp lại: bảng đầu trận trận 1 và bảng "?" (gợi ý + 9 thao tác) hiển thị đúng chữ, không che cột nút.
- Bảng đầu trận nằm nửa dưới bàn và có thể che hàng tướng ở bàn nhỏ (trận 1); chấp nhận vì bấm là tắt.
- F5 (dev) gọi `_start_battle(false)`; nút Đánh lại/Tiếp gọi `_start_battle()` mặc định hiện gợi ý.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created

### File List

- `game/src/ui/hint_panel.gd` (mới), `game/src/ui/hud.gd` (nút "?"), `game/src/app/main.gd`, `game/src/app/app_state.gd` (`hints_enabled`)
- `game/src/core/level_data.gd` (`hints`), `game/src/data/level_loader.gd` (`goi_y`)
- `game/data/tran/tran_01..06.json` (`goi_y`), `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/pre_run.gd`, `game/tests/test_hint_panel.gd` (mới), `game/tests/test_hints_data.gd` (mới)
