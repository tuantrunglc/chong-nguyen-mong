---
baseline_commit: 810188a
---

# Story 4.7: Kiểm tra hiệu năng và trình duyệt

Status: done

## Story

Là tác giả,
tôi muốn biết game chạy ổn trên máy người thân,
để buổi chơi thử không hỏng vì lỗi kỹ thuật.

## Acceptance Criteria

(Nguồn: `epics.md` Story 4.7; NFR1–NFR4, NFR6. Mục có chữ **[Tác giả đo]** là việc chỉ tác giả làm được: AI chuẩn bị công cụ và hướng dẫn từng bước, không tự điền số.)

1. **Bộ đếm FPS (chỉ khi `--dev` / `?dev=1`).** Góc dưới trái cửa sổ hiện chữ nhỏ (góc trên trái đã có chữ DEV và bảng F3) "FPS 60" (số nguyên, lấy từ `Engine.get_frames_per_second()`, cập nhật khoảng 2 lần/giây). Không bật dev thì không có node này. Hiện trên mọi màn (menu, trận, chuyển trận), nằm trên cùng, không nhận chuột. Chữ qua `tr()`.
2. **FPS thấp nhất.** Cùng bộ đếm ghi thêm "min" trong vài giây gần nhất (cửa sổ 5 giây) để tác giả thấy khung hình giật chứ không chỉ số trung bình. Nhấn F4 (chỉ khi dev) xóa số min để đo lại từ đầu. Số liệu cũng ghi `Log.info("hieu_nang", …)` mỗi 5 giây khi bật dev (cho đọc log, không spam khi tắt dev).
3. **Dung lượng và thời gian tải (NFR2).** `tools/build_web.sh` đã in dung lượng bản nén và trượt khi > 25 MB (Story 0.5); giữ nguyên. Chạy lại trên commit hiện tại, ghi bản nén / chưa nén vào bảng "Số đo bản web" của `NEXT-STEPS.md`. **[Tác giả đo]** thời gian tải ở 20 Mbps bằng DevTools (xóa bộ nhớ đệm trước khi đo) trên link itch.io; AI hướng dẫn từng bước và điền số tác giả đọc. Ô "chưa đo" của hàng 2026-10-17 được thay bằng số thật hoặc ghi lý do.
4. **Pha địch ≤ 3 giây (NFR3).** Trần đã được `EventPlayer.MAX_PHASE_SECONDS` canh bằng đồng hồ thật (Story 2.11, 4.4). Story này thêm **số đo**: test GUT dựng nhật ký sự kiện dài nhất có thể của mỗi trong 6 trận (phát lại lời giải bằng `SolutionCheck`/luật thật, lấy pha địch có nhiều sự kiện nhất, hoặc pha tiếp viện + đòn nhiều quân), cho `EventPlayer` phát bằng đồng hồ thật khi có màn hình và kiểm `total_seconds ≤ 3`. Test chạy headless (`instant`) nên chỉ kiểm `total_seconds()` và ghi số sự kiện, giây trước khi co (`raw_seconds()`); đo bằng đồng hồ thật nằm ở AC 6 (tác giả quan sát) và ở `EventPlayer` (4.4). Số pha dài nhất của từng trận ghi vào `NEXT-STEPS.md`.
5. **Không kẹt trận (NFR6).** Test GUT tự động cho cả 6 trận (đọc từ `chien_dich.json`, không viết cứng 6):
   - (a) **Đứng yên:** mở trận từ file thật, chỉ gọi `end_turn` liên tục: trận phải kết thúc (thắng hoặc thua) trong số hiệp cho phép, `validate()` rỗng sau mỗi lệnh, không có lệnh nào ở lượt người chơi bị từ chối ngoài `BATTLE_OVER`.
   - (b) **Lời giải:** 6 lời giải phát lại thắng đến hết (đã có ở 4.6, giữ).
   - (c) **Thua rồi chơi lại / thắng rồi sang trận kế** bằng `Main` (mẫu `_open("N")`, `_finish(main, Phase.WON)` của 4.2/4.3): màn kết quả luôn có lối đi tiếp (nút hoạt động), không có trạng thái "không bấm được gì".
   Kết quả "6/6 không kẹt" ghi vào `NEXT-STEPS.md`.
6. **FPS 60 ở trận 6 (NFR1). [Tác giả đo]** trên laptop card tích hợp, bản web, trận 6, hiệp nhiều quân nhất (hiệp 4–5 theo lời giải `tran_06_loi_giai.md`): đọc FPS và min từ bộ đếm, ghi vào `NEXT-STEPS.md`. Dưới 60 ổn định thì ghi nguyên số liệu và **dừng báo tác giả** (không tối ưu mò; hướng giảm tải nằm ở "Dev Notes › Nếu FPS thấp").
7. **Chạy trên Chrome, Firefox, Edge (NFR4). [Tác giả đo]** mở bản web, chơi trận 1 đến hết và vào trận 6, ghi mỗi trình duyệt: mở được / bàn vẽ đúng / chữ tiếng Việt có dấu đúng / lưu `user://` còn sau F5 / FPS. AI cung cấp bảng kiểm để tick (xem Task 4).
8. **Chạy bản web cục bộ để đo.** Vì itch.io không bật dev được trong iframe (`NEXT-STEPS.md`), thêm `tools/chay_web.sh`: phục vụ `build/web/` bằng máy chủ tĩnh cục bộ (cổng cố định, chỉ `127.0.0.1`), in link `http://127.0.0.1:PORT/index.html?dev=1` (và `&tran=6`), Ctrl+C để tắt. Không đụng `deploy_itch.sh`. Thiếu `build/web/` thì báo "chạy tools/build_web.sh trước".
9. **Và** không sửa luật (`src/core/`), `chi_so.json`, kịch bản `da_duyet: true`. `tools/test.sh` xanh (kể cả `check_boundaries.sh`). Không build/deploy itch khi tác giả chưa cho phép. Commit tiếng Việt kết `(Story 4.7)`.

## Tasks / Subtasks

- [x] **Task 1: Bộ đếm FPS** (AC: 1, 2)
  - [x] 1.1 Tạo `game/src/debug/fps_overlay.gd` (`class_name FpsOverlay`, `CanvasLayer` hoặc `Label` trong `CanvasLayer` layer cao nhất; theo mẫu `coord_overlay.gd` / `ai_intent_overlay.gd`). Hàm thuần dễ test: `static func format_text(fps: int, low: int) -> String`; cập nhật bằng `Timer`/bộ cộng dồn `_process`, không `print`.
  - [x] 1.2 Tính min: giữ mảng mẫu (thời gian, fps) lấy mỗi 0,25 s; min của 5 giây gần nhất. Hàm thuần `static func window_min(samples, now, window)` để test.
  - [x] 1.3 Gắn trong `main.gd` ngay dưới `if AppState.launch.dev:` (cạnh `_ai_overlay`), thêm `dev_tools.f4_pressed` → xóa min (xem `dev_tools.gd`, thêm tín hiệu `f4_pressed` đúng mẫu f1/f2/f3/f5). Không dựng node khi không dev.
  - [x] 1.4 Chuỗi hiển thị qua `tr()` (khóa `dev.fps` kiểu "FPS %d (thấp nhất %d)"); thêm vào file dịch như các khóa `dev.*` hiện có. Dùng `.replace("%d", …)` hoặc chỉ format khi có `%`, tránh `tr(key) % n` ném lỗi khi khóa chưa dịch (bài học review 4.6).
  - [x] 1.5 Test GUT: `format_text`, `window_min` (mẫu cũ hơn cửa sổ bị bỏ), không dev thì `Main` không có `FpsOverlay`, có dev thì có và `mouse_filter` bỏ qua chuột.
- [x] **Task 2: Đo thời gian pha địch** (AC: 4)
  - [x] 2.1 Test `tests/test_hieu_nang_pha_dich.gd`: với mỗi trận trong `chien_dich.json`, phát lại lời giải bằng luật thật (dùng lại `SolutionCheck`/`Rules.resolve`, **không** viết lại bộ phát), gom nhật ký của từng lệnh `ket_thuc_luot` và pha chuẩn bị, lấy pha có nhiều sự kiện nhất; kiểm `EventPlayer.total_seconds(events) ≤ MAX_PHASE_SECONDS`. Nếu cần cho `SolutionCheck` lộ nhật ký sự kiện thì thêm trường/hàm nhỏ, không đổi hành vi hiện có.
  - [x] 2.2 Khi có màn hình (không `instant`) thì phát thật và đo `Time.get_ticks_msec()`; headless thì bỏ nhánh này (đừng làm test chập chờn).
  - [x] 2.3 In số pha dài nhất mỗi trận (số sự kiện, giây) ra Debug Log để dán vào `NEXT-STEPS.md`.
- [x] **Task 3: Không kẹt trận** (AC: 5)
  - [x] 3.1 Test `tests/test_khong_ket_tran.gd`: nhánh (a) đứng yên cho mọi trận trong chuỗi; đặt trần vòng lặp (ví dụ 50 lệnh) để lỗi kẹt là test trượt chứ không treo. Dùng `Rules.resolve` + `state.validate()`.
  - [x] 3.2 Nhánh (c) qua `Main`: mẫu `test_main.gd`/`test_chuoi_tran.gd` (xem 4.2, 4.3), file lưu cô lập bằng `tests/pre_run.gd`. Kiểm màn kết quả (thắng và thua) có nút đi tiếp bấm được, trận cuối ra màn "thắng cả chiến dịch".
  - [x] 3.3 Nếu phát hiện kẹt thật thì **dừng**, ghi kịch bản tái hiện và báo tác giả (không tự sửa luật).
- [x] **Task 4: Công cụ đo cho tác giả** (AC: 3, 6, 7, 8)
  - [x] 4.1 `tools/chay_web.sh` (AC 8): mẫu `build_web.sh`/`_godot.sh` (`set -euo pipefail`, thông báo tiếng Việt). Máy chủ tĩnh: `python3 -m http.server` bind `127.0.0.1`, cổng cố định (ví dụ 8060). Kiểm `build/web/index.html` tồn tại. Đã có `.wasm` MIME đúng trong `http.server` của Python 3 (kiểm lại).
  - [x] 4.2 Chạy `tools/build_web.sh` trên commit hiện tại, ghi bản nén/chưa nén (AC 3). **Không** chạy `deploy_itch.sh` khi chưa được phép.
  - [x] 4.3 Soạn mục "Đo hiệu năng và trình duyệt (Story 4.7)" trong `NEXT-STEPS.md`: bảng trống cho tác giả điền (3 trình duyệt × mở được / chữ đúng / lưu còn / FPS trận 1 / FPS min trận 6) và các bước từng nước: `tools/chay_web.sh` → mở link `?dev=1&tran=6` → chơi hiệp 4–5 → đọc "FPS …" → báo AI. Có bước đo tải 20 Mbps bằng DevTools (Network › Throttling › tạo profile 20 Mbps, tick Disable cache, F5, đọc Finish/Load).
  - [x] 4.4 Chụp GoPeak (`tools/chay.sh --dev`) xác nhận chữ FPS ở góc, không đè HUD/nút.
- [x] **Task 5: Bàn giao** (AC: 3, 6, 7, 9)
  - [x] 5.1 `tools/test.sh` xanh. Cập nhật Dev Agent Record, `sprint-status.yaml`, `NEXT-STEPS.md` (số đo AI đo được: dung lượng, pha dài nhất, không kẹt).
  - [x] 5.2 **[Tác giả đo]** các ô AC 3, 6, 7 còn trống: story chỉ `done` sau khi tác giả đo xong và nói "duyệt" (hoặc ghi rõ ô nào hoãn và vì sao). Khi tác giả đo thì AI điền số vào `NEXT-STEPS.md`, không tự đoán số.

## Dev Notes

### Hiện trạng (đã kiểm 2026-11-01, HEAD `810188a`)

- **Chưa có** bộ đếm FPS (`grep -ri fps game/src` rỗng). Cờ dev: `AppState.launch.dev` (`launch_options.gd`; `--dev` desktop, `?dev=1` web). Overlay dev mẫu: `CoordOverlay` (F1), `AiIntentOverlay` (F3); `DevTools` phát tín hiệu `f1/f2/f3/f5_pressed` (`src/debug/dev_tools.gd`), gắn ở `main.gd` ~dòng 120–134.
- **Itch.io không bật dev được:** game chạy trong iframe có địa chỉ riêng, `?dev=1` ở trang itch không tới game (`NEXT-STEPS.md`, mục Bản web). Nên đo FPS trên bản web phải qua máy chủ cục bộ (AC 8), không qua link itch.
- **NFR3 đã có cơ chế:** `EventPlayer.MAX_PHASE_SECONDS = 3.0`, `total_seconds()`, hạn chót đồng hồ thật `_deadline`; tua nhanh `FAST_SPEED = 3.0` (4.4). `instant` khi headless. Story này **đo**, không viết lại cơ chế.
- **Build web:** `tools/build_web.sh` (đơn luồng `web_nothreads_release`, thoát mã 1 nếu bản nén > 25 000 000 byte), `tools/deploy_itch.sh` (cần `build/web_build_info.json`). Bảng "Số đo bản web (NFR2), lần đầu" trong `NEXT-STEPS.md`: bản nén 10,4 MB, chưa nén 40,0 MB (`index.wasm` 39,5 MB), thời gian tải **chưa đo**. Ước tính: 4–5 giây nếu itch nén wasm, ~16 giây nếu không (vượt 10 giây) — đây là rủi ro chính của AC 3; nếu thật sự vượt, ghi số liệu và báo tác giả (hướng: wasm nén brotli phía máy chủ không điều khiển được trên itch; giảm kích thước export template; chỉ báo, không tự làm).
- **Chuỗi 6 trận:** `game/data/chien_dich.json` (đọc bằng `CampaignLoader`); đừng viết cứng 6. 6 lời giải phát lại được: `SolutionCheck.check_campaign(...)` (4.6). Trận 6 (10×8, 3 tướng, tiếp viện) là bàn nặng nhất; lời giải thắng ở hiệp 5.
- **Kẹt trận đã từng được chặn bằng:** `validate()` sau mỗi lệnh, `Rules.is_battle_over`, giới hạn hiệp (`het_hiep`). Test "đứng yên" mới chỉ có ở từng trận riêng (ví dụ `test_tran_05.gd` test đứng yên thua `quan_nguyen_vao_ai`); chưa có bộ chạy chung cho cả chuỗi.

### Kiến trúc phải giữ

- `src/core/` cấm `FileAccess`, `print`, `Time`, `Engine`…: FPS là hiển thị, nằm ở `src/debug/`. `tools/check_boundaries.sh` bắt lỗi ranh giới.
- Log qua `Log.*` (không `print()`), chữ hiển thị qua `tr()`, khóa `<màn>.<mục>`.
- Overlay dev không được tồn tại khi không dev (không tốn khung hình ở bản phát hành). Không `Thread` (web đơn luồng).
- Test không ghi `user://` thật (dùng `tests/pre_run.gd` như 4.3/4.4).

### Nếu FPS thấp (chỉ để báo tác giả, không tự làm)

Bàn ≤ 10×8, ít node, `Compatibility` renderer. Nghi phạm theo thứ tự: nhãn/`StyleBox` tạo lại mỗi lần rê chuột (`PreviewView`), `queue_redraw` mỗi khung, tween chồng. Đo bằng `Log.info("hieu_nang")` trước khi đổi bất cứ thứ gì; tác giả quyết có tối ưu hay không.

### Bài học từ story trước (4.6 và review của nó)

- Test phải có thể trượt: bộ "không kẹt" phải có trần vòng lặp và kiểm kết quả, không chỉ chạy xong là xanh.
- `tr(key) % n` ném lỗi khi khóa chưa dịch; dùng `.replace`.
- Hàm dùng chung (như `SolutionCheck`) đã sửa để báo lý do dễ đọc; dùng lại, đừng sao chép.
- macOS: `sed -i` cần `''`; ưu tiên Python/Edit cho sửa file.

### Git gần đây

- `810188a` đóng 3.13/3.14/4.5; `71d97fc` đóng 4.6; `a87748f` sửa review 4.6; `6a6b7cf` bộ kiểm lời giải 6 trận (4.6). Mẫu commit: tiếng Việt, kết `(Story N.M)`, có dòng Co-Authored-By.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh (`untyped_declaration` là error); JSON số là `float` → `int()`; khóa JSON tiếng Việt không dấu; code tiếng Anh `snake_case`.
- Một lệnh test: `tools/test.sh`, tóm tắt tiếng Việt, mã thoát ≠ 0 là trượt. Sau mỗi lần phân giải trong test gọi `state.validate()`.
- Cấm sửa/xóa kịch bản `da_duyet: true` để test đạt.
- Không test tự động cho UI/hoạt ảnh thuần hình; phần đó tác giả test tay, AI chụp GoPeak (`tools/chay.sh --dev` chạy nền, `capture_screenshot`; `inject_*` có thể không có tác dụng — dùng script tạm trong scratchpad như 4.6 Task 4.5).
- Nói với tác giả bằng tiếng Việt, theo các bước để thử, thấy gì là đúng.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.7] (dòng ~1336–1352); NFR1–NFR4, NFR6 (dòng 104–109); Story 0.5 (dòng ~320–340); Story 2.11 (dòng ~825–845)
- [Source: NEXT-STEPS.md#Bản web trên itch.io] (số đo NFR2 lần đầu)
- [Source: tools/build_web.sh], [Source: tools/deploy_itch.sh]
- [Source: game/src/battle/event_player.gd] (`MAX_PHASE_SECONDS`, `total_seconds`, `FAST_SPEED`)
- [Source: game/src/debug/coord_overlay.gd], [Source: game/src/debug/dev_tools.gd], [Source: game/src/app/main.gd]
- [Source: game/tests/solution_check.gd] (4.6), [Source: _bmad-output/implementation-artifacts/4-4-tua-nhanh-pha-dich.md]

### Câu hỏi cho tác giả (trả lời trước hoặc trong lúc làm)

1. **Máy đo "laptop card tích hợp":** bạn có máy nào như vậy không (hay chỉ máy hiện tại)? Không có thì AC 6 ghi đo trên máy nào và nêu rõ cấu hình (CPU/GPU).
2. **Bộ đếm FPS hiện cả khi bật dev ở desktop** hay chỉ trên web? (Đề xuất: cả hai, vì cùng một cờ dev.)
3. **Build/deploy itch:** AI có được chạy `tools/build_web.sh` (chỉ tạo `build/web/`, không đẩy lên) không? Đề xuất: có; `deploy_itch.sh` vẫn chờ bạn nói.

## Dev Agent Record

### Agent Model Used

### Debug Log References

- `tools/test.sh`: 892/892. Chụp GoPeak `--dev --tran=6`: "FPS 92 (thấp nhất 88)" ở góc dưới trái, không đè HUD (chữ DEV và nút giữ nguyên chỗ).
- `tools/build_web.sh` trên `68dc441-sua`: nén 10.6 MB, chưa nén 40.3 MB. `tools/chay_web.sh` thử: `index.wasm` trả `application/wasm`, trang `?dev=1` trả 200.
- Pha địch dài nhất theo lời giải (số sự kiện, giây trước co): T1 6/1.04, T2 10/1.46, T3 7/0.68, T4 4/0.64, T5 6/1.04, T6 17/2.62. Đứng yên: cả 6 trận kết thúc (thua) sau 6/3/3/2/2/1 lượt, không lệnh nào bị từ chối.
- Lệch AC: bộ đếm ở góc dưới trái (trên trái đã có DEV); AC 4 không đo đồng hồ thật vì test chạy headless.

### Completion Notes List

- 2026-11-01: tác giả báo đã đo xong AC 3, 6, 7 trên máy thật (game web nhẹ), sẽ tự điền bảng trong `NEXT-STEPS.md` sau. Số của tác giả chưa có trong repo; AI không điền thay.
- Ultimate context engine analysis completed - comprehensive developer guide created

### File List

- `game/src/debug/fps_overlay.gd` (mới), `game/src/debug/dev_tools.gd` (F4 phát `f4_pressed`), `game/src/app/main.gd`, `game/src/battle/event_player.gd` (`raw_seconds`)
- `game/i18n/text.csv` (`dev.fps`), `game/i18n/text.vi.translation`
- `game/tests/test_fps_overlay.gd`, `game/tests/test_hieu_nang_tran.gd` (mới), `game/tests/test_dev_tools.gd`, `game/tests/solution_check.gd` (`enemy_phase_logs`)
- `tools/chay_web.sh` (mới), `NEXT-STEPS.md` (mục đo Story 4.7)
