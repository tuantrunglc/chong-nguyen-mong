---
baseline_commit: 3dbf023
---

# Story 4.3: Tự lưu

Status: done

## Story

Là người chơi,
tôi muốn game tự lưu sau mỗi trận,
để tắt trình duyệt rồi chơi tiếp được.

## Acceptance Criteria

1. **Khi** thắng một trận trong chuỗi (không phải trận cuối) **thì** game tự lưu ngay lúc hiện bảng "Thắng!" (không chờ bấm "Tiếp"; sửa sau code review theo epic "thắng một trận thì tự lưu") vào `user://save.json` (FR46): `{"phien_ban": 1, "tran_tiep": "<id trận kế>"}`; log `INFO [save]`. Không lưu giữa trận (kiến trúc "Lưu game").
2. **Khi** thắng trận cuối của chuỗi **thì** (cũng lúc hiện bảng "Thắng!") xóa file lưu (không còn gì để chơi tiếp); log `INFO [save]`.
3. **Cho** đã có file lưu hợp lệ (đúng phiên bản, `tran_tiep` là trận có trong `chien_dich.json`) **thì** màn hình chính có thêm nút **"Chơi tiếp"** nằm trên "Chơi mới" (FR45). Không có file lưu thì không có nút.
4. **Khi** tải lại trang (mở lại game) và bấm "Chơi tiếp" **thì** vào đúng trận `tran_tiep`, các tướng đủ máu như mọi lần vào trận.
5. **Khi** file lưu hỏng (JSON hỏng, không phải object, thiếu/sai `phien_ban`, khác phiên bản 1, thiếu/sai `tran_tiep`, hoặc `tran_tiep` không có trong chuỗi trận) **thì** không sập: màn hình chính hiện một dòng nhẹ "Không đọc được tiến độ đã lưu, hãy chơi mới." (khóa `menu.save_broken`), không có nút "Chơi tiếp", vẫn "Chơi mới" được; log `ERROR [save]` ghi rõ lỗi (câu tiếng Việt có tên file, như các bộ nạp khác). File hỏng không bị xóa; lần thắng kế tiếp ghi đè.
6. **Và** chạy đúng trong iframe của itch.io: `user://` là IndexedDB, đã kiểm ở Story 0.5 (`SaveProbe`). Kiểm lại trên bản deploy khi tác giả cho phép.
7. **Và** test GUT cho đọc/ghi/xóa file lưu, các ca hỏng (câu lỗi nguyên văn), nút "Chơi tiếp" và luồng thắng → lưu → mở lại → chơi tiếp. Test **không** được ghi vào file lưu thật của tác giả. `tools/test.sh` xanh; commit tiếng Việt kết `(Story 4.3)`.

## Tasks / Subtasks

- [x] **Task 1: `src/data/save_system.gd`** (AC: 1, 2, 5)
  - [x] 1.1 `class_name SaveSystem extends RefCounted`, `DEFAULT_PATH = "user://save.json"`, `FORMAT_VERSION = 1`, `static var path` (test đổi được, như `SaveProbe.path`).
  - [x] 1.2 `load_save() -> LoadResult`: không có file → `ok`, `data = null`; hợp lệ → `data` là `SaveSystem.SaveData` (`next_level`); hỏng → lỗi tiếng Việt dạng `<file>: ...` (dùng `JsonFile` như các bộ nạp; `JSON.new().parse` để không in ERROR của engine). Không ghi log (bên gọi ghi).
  - [x] 1.3 `save_next_level(level_id) -> bool` (ghi file, trả false nếu không mở được file), `clear()` (xóa nếu có).
- [x] **Task 2: Màn hình chính** (AC: 3, 5) — `MainMenu.show_save(can_continue: bool, broken: bool)`: nút "Chơi tiếp" (`continue_pressed`, `FOCUS_NONE`, trên "Chơi mới"), dòng `menu.save_broken`. Khóa chữ `menu.continue`, `menu.save_broken`.
- [x] **Task 3: `main.gd`** (AC: 1–5)
  - [x] 3.1 `_show_menu` đọc file lưu (và chiến dịch để kiểm `tran_tiep` có trong chuỗi) rồi gọi `show_save`. Hỏng → `Log.error("save", ...)`.
  - [x] 3.2 Lúc hiện bảng Thắng! (`_on_playback_finished`, sau review; trước là `_show_transition`): thắng trận giữa chuỗi → `SaveSystem.save_next_level(next_id)` + log; trận cuối → `SaveSystem.clear()` + log. Ghi lỗi → `Log.error("save", ...)`, vẫn sang màn chuyển trận.
  - [x] 3.3 "Chơi tiếp" → `_level_id = tran_tiep`, `_start_battle()`.
- [x] **Task 4: Cô lập test** (AC: 7) — hook GUT chạy trước mọi test (`tests/pre_run.gd`, `-gpre_run_script` trong `tools/test.sh`) đặt `SaveSystem.path` sang file test và xóa file đó; test của story tự đặt đường dẫn riêng.
- [x] **Task 5: Test** (AC: 7) — `tests/test_save_system.gd` (đọc/ghi/xóa, mọi ca hỏng nguyên văn) + luồng trong `test_main.gd` (không file → không nút; thắng → file đúng; mở lại `main` → nút "Chơi tiếp" → đúng trận; trận cuối → xóa; file hỏng → dòng báo + log ERROR + không nút; `tran_tiep` ngoài chuỗi → hỏng).
- [x] **Task 6: Bàn giao** — `tools/test.sh` xanh; hướng dẫn thử tay; story, `sprint-status.yaml`; commit. Deploy itch chỉ khi tác giả cho phép.

### Review Findings

Code review 2026-10-31 (Blind Hunter, Edge Case Hunter, Acceptance Auditor). Tác giả dặn không cần hỏi lại, nên các điểm có cách sửa rõ đã sửa luôn.

- [x] [Review][Patch] Lưu ngay lúc thắng (hiện bảng Thắng!), không chờ bấm "Tiếp": thắng xong đóng tab vẫn còn tiến độ (epic: "thắng một trận thì tự lưu") [game/src/app/main.gd:258]
- [x] [Review][Patch] Ghi file lưu an toàn: ghi file tạm rồi đổi tên; kiểm `store_string`/`get_error`; trả mã lỗi thật cho log (trước dùng nhầm `get_open_error`) [game/src/data/save_system.gd:64]
- [x] [Review][Patch] `clear()` trả mã lỗi; xóa không được thì log ERROR thay vì báo "đã xóa" [game/src/data/save_system.gd:77]
- [x] [Review][Patch] File có mà không đọc được báo "không đọc được file", không báo nhầm "file lưu rỗng" [game/src/data/save_system.gd:28]
- [x] [Review][Patch] Lưu xong mà `user://` không bền (web chặn bộ nhớ, ẩn danh) thì log WARN [game/src/app/main.gd:327]
- [x] [Review][Patch] "Chơi tiếp" khi không có trận đã lưu thì không làm gì [game/src/app/main.gd:152]
- [x] [Review][Patch] Cô lập test: `test_battle_view`, `test_board_view`, `test_stratagem_view` đặt file lưu riêng (chạy GUT ngoài `tools/test.sh` cũng không đụng file thật); `test_main` trả lại đường dẫn cũ sau test [game/tests/test_main.gd:30]
- [x] [Review][Patch] Dọn test: chú thích gắn nhầm hằng `SAVE_FILE`, hằng trùng `F`, test file hỏng giải phóng `main` sau mỗi ca [game/tests/test_main.gd:14]
- [x] [Review][Patch] Thêm test: `phien_ban` 1.5/true/null/0, `tran_tiep` null/mảng, ghi đè, ghi hỏng (log ERROR, vẫn sang màn chuyển trận), thua không đụng file lưu, "Chơi tiếp" không có file lưu, đi qua "Chơi tiếp" vào trận cuối rồi thắng [game/tests/test_save_system.gd, game/tests/test_main.gd]
- [x] [Review][Defer] AC6: chưa kiểm tự lưu trên bản itch (iframe, IndexedDB) [—] — deferred, chờ tác giả cho phép deploy

Bỏ qua (7): kiểm chuỗi trận bằng `DATA_LEVEL_DIR` (cố ý, có chú thích); "Chơi mới" ghi đè tiến độ xa hơn (mặc định 3); trận mở bằng `--tran` cũng lưu (mặc định 5, đã nhắc trong hướng dẫn thử tay); chuỗi trận hỏng thì ẩn "Chơi tiếp" không báo ("Chơi mới" báo lỗi chuỗi trận); file lưu trỏ vào trận có file hỏng (vào màn lỗi, nhất quán); `has_file()` chỉ test dùng; test trận cuối tự ghi file lưu (đã đổi sang đi qua "Chơi tiếp").

## Dev Notes

### Mặc định AI chọn (tác giả bảo không cần hỏi, 2026-10-31; sửa được)

1. File lưu chỉ ghi **trận kế tiếp** (`tran_tiep`). Mưu kế đã mở không cần lưu: nằm trong file trận (quyết định 4 của Story 4.2).
2. Thắng hết chuỗi thì **xóa** file lưu → màn hình chính chỉ còn "Chơi mới".
3. "Chơi mới" khi đã có file lưu: **không hỏi lại**, vào trận 1; file lưu giữ nguyên tới lần thắng kế tiếp (ghi đè).
4. File lưu hỏng: một dòng nhẹ trên màn hình chính, không có màn hình lỗi, không xóa file.
5. Trận mở bằng dev (`--tran=N` có trong chuỗi) thắng rồi "Tiếp" cũng lưu như chơi thường.

### Nguồn

- Epics Story 4.3 (epics.md:1265–1287), FR45, FR46. Kiến trúc: quyết định 14 "JSON trong `user://`, có trường phiên bản" (dòng 252); "Lưu game" (dòng 352–357: sau mỗi trận, không lưu giữa trận, phiên bản lạ/hỏng không sập); `src/data/save_system.gd` (dòng 575, 660); log `ERROR` cho file lưu hỏng, `INFO` cho lưu game (dòng 443–457).
- Hiện trạng: `SaveProbe` (`src/debug/save_probe.gd`) đếm lần mở ở `user://thu_luu.json` — giữ nguyên. `main.gd`: `_show_transition()` là chỗ duy nhất biết "vừa thắng trận X" (ghi chú của 4.2); `_show_menu(log_line)`; `MainMenu._buttons` để thêm "Chơi tiếp" phía trên.

### Điều phải giữ

- Luồng 4.1/4.2 (menu, chuyển trận, F2/F5, dev `--tran`), `SaveProbe`, mọi test hiện có.
- Không lưu giữa trận; không đụng luật.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.3]
- [Source: _bmad-output/planning-artifacts/game-architecture.md] dòng 252, 352–357, 443–457, 575, 660
- [Source: _bmad-output/implementation-artifacts/4-2-chuoi-6-tran-va-man-chuyen-tran.md]
- [Source: _bmad-output/project-context.md]

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Nền trước story: HEAD `3dbf023`; `tools/test.sh` 826/826 GUT.
- Lần chạy đầu: lỗi cú pháp vì `LoadResult.data` là `RefCounted` (không nhận String) → thêm lớp con `SaveSystem.SaveData`.
- Kiểm đột biến: thay `_save_progress(next_id)` bằng `pass` → 3 test trượt (`test_winning_saves_next_level`, `test_continue_after_reopen_opens_saved_level`, `test_back_to_menu_after_save_shows_continue`); trả lại thì xanh.
- Sau khi chạy test, thư mục `user://` thật của game không có `save.json` (hook `pre_run.gd` và `SAVE_FILE` của `test_main.gd` cô lập đúng).
- Cuối: `tools/test.sh` 838/838 GUT, 173 kịch bản đã duyệt.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- `SaveSystem` (`src/data/save_system.gd`): `load_save()` trả `LoadResult` (không file → ok, `data` null; hợp lệ → `SaveData.next_level`; hỏng → câu lỗi tiếng Việt có tên file, dùng `JsonFile` như các bộ nạp); `save_next_level()`, `clear()`. Không ghi log; `main.gd` ghi `INFO/ERROR [save]`.
- `main.gd`: `_show_transition` lưu trận kế (`_save_progress`) hoặc xóa file khi thắng trận cuối; `_show_menu` gọi `_refresh_save()` (đọc file lưu + kiểm `tran_tiep` có trong `chien_dich.json`), rồi `MainMenu.show_save(...)`; "Chơi tiếp" → `_on_continue()`.
- `MainMenu`: nút "Chơi tiếp" trên "Chơi mới" (`FOCUS_NONE`), dòng `menu.save_broken`. Gom tạo nút vào `_add_button`.
- Cô lập test: `tests/pre_run.gd` (hook GUT, thêm `-gpre_run_script` trong `tools/test.sh`) trỏ `SaveSystem.path` sang `user://test_luu_game.json` cho mọi test; `test_main.gd` dùng file riêng và xóa trước/sau mỗi test. Sau review: các file test khác dựng `main.tscn` (`test_battle_view`, `test_board_view`, `test_stratagem_view`) cũng tự đặt file lưu riêng, nên chạy GUT trong editor (không có hook) cũng không đụng file lưu thật.
- Test mới: `test_save_system.gd` (6) + 6 test luồng trong `test_main.gd` (không file; thắng → lưu; mở lại → Chơi tiếp → đúng trận, đủ máu; về menu thấy Chơi tiếp; trận cuối → xóa; 4 kiểu file hỏng → dòng báo, log ERROR, không xóa, Chơi mới vẫn vào trận 1).
- Chưa thử trên itch (AC 6): cần tác giả cho phép deploy.

**Hướng dẫn tác giả thử tay** (`tools/chay.sh`, không cần `--dev`):
1. Lần đầu: màn hình chính chỉ có "Chơi mới".
2. "Chơi mới" → thắng trận 1 → thấy bảng "Thắng!" là đã lưu (không cần bấm "Tiếp"). Tắt game ngay.
3. Mở lại game: có nút **"Chơi tiếp"** phía trên "Chơi mới". Bấm → vào thẳng **trận 2**, tướng đủ máu.
4. Muốn đi nhanh: `tools/chay.sh --dev --tran=4`, thắng → tắt → mở `tools/chay.sh` → "Chơi tiếp" vào trận 5.
5. Thắng trận 5 → "Về menu": không còn "Chơi tiếp".
6. Bản web (sau deploy): làm bước 2–3 nhưng thay "tắt game" bằng tải lại trang.
7. Lưu ý: chơi bằng `--tran=N` thắng cũng ghi đè file lưu thật (`--tran=5` thắng thì xóa).

### File List

- `game/src/data/save_system.gd` (mới), `game/src/data/save_system.gd.uid` (mới)
- `game/src/app/main.gd`, `game/src/ui/main_menu.gd`
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/pre_run.gd` (mới), `game/tests/pre_run.gd.uid` (mới nếu Godot sinh), `game/tests/test_save_system.gd` (mới), `game/tests/test_main.gd`
- `tools/test.sh`
- Sau review: `game/tests/test_battle_view.gd`, `game/tests/test_board_view.gd`, `game/tests/test_stratagem_view.gd`
- `_bmad-output/implementation-artifacts/4-3-tu-luu.md`, `_bmad-output/implementation-artifacts/sprint-status.yaml`

## Change Log

- 2026-10-31: Code review: lưu ngay lúc thắng (không chờ "Tiếp"), ghi file lưu an toàn (file tạm + đổi tên), báo lỗi ghi/xóa/đọc đúng, cô lập file lưu ở mọi file test dựng main. `tools/test.sh` 843/843. Status → done.
