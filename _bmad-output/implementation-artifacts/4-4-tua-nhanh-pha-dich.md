---
baseline_commit: 1f1b36c
---


# Story 4.4: Tua nhanh pha địch

Status: review

## Story

Là người chơi,
tôi muốn tua nhanh hoạt ảnh của địch,
để không phải chờ khi đã hiểu chuyện gì sắp xảy ra.

## Acceptance Criteria

1. **Cho** đang trong trận **thì** bảng nút bên phải có nút **"Tua nhanh (T): tắt"** (dưới "Kết thúc lượt"), phím tắt **T**. Bấm (hoặc gõ T) thì bật/tắt: chữ đổi thành **"Tua nhanh (T): bật"** và ngược lại. Nút không giữ focus (`FOCUS_NONE`) như các nút HUD khác.
2. **Khi** tua nhanh đang bật **thì** hoạt ảnh pha địch (pha chuẩn bị lúc mở trận và pha ra đòn sau "Kết thúc lượt") chạy nhanh gấp **3** (`EventPlayer.FAST_SPEED`): mỗi động tác ngắn bằng 1/3, cả pha ≤ 1 giây (trần NFR3 3 giây chia 3). **Không bỏ sự kiện nào** (FR42): mọi sự kiện trong nhật ký vẫn được phát đúng thứ tự (`EventPlayer.played()` đủ). Hoạt ảnh lệnh của người chơi (đi, đánh, mưu kế) giữ tốc độ thường.
3. **Khi** đang phát pha địch (các nút khác đang khóa) **thì** nút/phím tua vẫn bấm được và có hiệu lực ngay cho phần còn lại của pha; tắt giữa chừng thì phần còn lại chạy tốc độ thường.
4. **Và** trạng thái tua lưu trong `user://settings.cfg` (ConfigFile, mục `[hoat_anh]`, khóa `toc_do`: `1.0` hoặc `3.0`) ngay khi bấm; mở lại game vẫn giữ (nút hiện đúng chữ, pha địch chạy đúng tốc độ). Log `INFO [settings]` khi đổi và khi nạp.
5. **Khi** `settings.cfg` hỏng (không đọc được) hoặc `toc_do` lạ (không phải 1 hay 3, hoặc không phải số) **thì** không sập: dùng tốc độ thường, log `WARN [settings]` có tên file; không báo gì cho người chơi. Lần bấm tua kế tiếp ghi đè file.
6. **Và** luật không đổi: tua chỉ đổi tốc độ Tween/thời gian chờ (project-context: "Tua nhanh bằng cách đổi tốc độ Tween, không bỏ qua sự kiện"); `BattleState`, nhật ký sự kiện, kịch bản luật giữ nguyên.
7. **Và** test GUT: đọc/ghi/hỏng `settings.cfg`; `EventPlayer` ở tốc độ 3 đo đồng hồ thật ≤ 1 s và đủ sự kiện; đổi tốc độ giữa chừng; nút/phím HUD (chữ, không bị khóa khi đang phát); pha địch dùng tốc độ tua còn lệnh người chơi thì không; mở lại `main` giữ cài đặt. Test **không** ghi vào `settings.cfg` thật. `tools/test.sh` xanh; commit tiếng Việt kết `(Story 4.4)`.

## Tasks / Subtasks

- [x] **Task 1: `src/data/player_settings.gd`** (AC: 4, 5)
  - [x] 1.1 `class_name PlayerSettings extends RefCounted`; `DEFAULT_PATH = "user://settings.cfg"`, `static var path` (test đổi được, như `SaveSystem.path`); `SECTION = "hoat_anh"`, `SPEED_KEY = "toc_do"`; `var animation_speed: float = 1.0`.
  - [x] 1.2 `static func load_settings() -> LoadResult`: không có file → ok, `data` mặc định; `ConfigFile.load` lỗi → warning `"<file>: không đọc được file cài đặt (mã lỗi N), dùng mặc định"`, `data` mặc định; `toc_do` không phải 1/3 → warning `'<file>: "toc_do" là X, dùng 1'`. Luôn có `data` (cài đặt hỏng không bao giờ chặn game). Không ghi log.
  - [x] 1.3 `func save() -> Error` (ConfigFile.save).
- [x] **Task 2: `EventPlayer`** (AC: 2, 3, 6) — `const FAST_SPEED: float = 3.0`; `var speed: float = 1.0` qua `set_speed(s)`: thời lượng mỗi sự kiện, sàn `MIN_EVENT_SECONDS` và ngân sách `MAX_PHASE_SECONDS` đều chia cho `speed`; đổi giữa chừng thì co/giãn phần ngân sách còn lại, có hiệu lực từ sự kiện kế tiếp (động tác đang chạy ≤ 0,22 s). Không bỏ sự kiện.
- [x] **Task 3: HUD + phím** (AC: 1, 3) — `Hud`: signal `fast_forward_pressed`, nút dưới "Kết thúc lượt", `show_fast_forward(on)`, không bị `set_locked` khóa; khóa chữ `hud.fast.off`/`hud.fast.on` trong `i18n/text.csv`. `BattleInput`: action `fast_forward` = `KEY_T`, signal `fast_forward_pressed`.
- [x] **Task 4: `BattleView`** (AC: 2, 3) — `set_fast_forward(on)`, `fast_forward()`; signal `fast_forward_changed(on)`; bấm nút/phím (cả khi `_playing`, chỉ cần có trận) → đổi cờ, cập nhật HUD, nếu đang phát pha địch thì `_player.set_speed(...)` ngay. Mỗi lần phát: `_player.set_speed(FAST_SPEED if _fast and _enemy_turn else 1.0)` trước khi phát (kể cả nhánh `instant`).
- [x] **Task 5: `main.gd` + `AppState`** (AC: 4, 5) — `AppState.settings: PlayerSettings`; `_ready` nạp cài đặt (log `INFO [settings] tốc độ hoạt ảnh N`, warning → `WARN [settings]`), gọi `_battle_view.set_fast_forward(...)`; `fast_forward_changed` → lưu file, log `INFO [settings] tua nhanh: bật/tắt`, lỗi ghi → `ERROR [settings]`.
- [x] **Task 6: Cô lập test** (AC: 7) — `tests/pre_run.gd` đặt `PlayerSettings.path` sang file test; các file test bấm tua tự đặt đường dẫn riêng và trả lại sau test.
- [x] **Task 7: Test** (AC: 7) — `tests/test_player_settings.gd`; thêm vào `test_event_player.gd`, `test_battle_view.gd` (hoặc `test_main.gd`) như AC 7.
- [x] **Task 8: Bàn giao** — `tools/test.sh` xanh; kiểm đột biến; hướng dẫn thử tay; story, `sprint-status.yaml`; commit. Deploy itch chỉ khi tác giả cho phép.

## Dev Notes

### Mặc định AI chọn (tác giả bảo không cần hỏi, 2026-10-31; sửa được)

1. Nút **bật/tắt** (không phải giữ để tua), vì epic nói "tốc độ lưu, mở lại vẫn giữ". Chữ "Tua nhanh (T): tắt" / "Tua nhanh (T): bật" (ghi phím như các nút HUD khác), phím **T** (chữ đầu "Tua"; Q, W là mưu kế, Z, R, Space, 1–3 đã dùng).
2. Nhanh gấp **3**: pha địch dài nhất 3 s còn 1 s, vẫn kịp nhìn ai đánh ai.
3. Chỉ tua **pha địch** (đúng tên story); lệnh của người chơi vốn ngắn, giữ nguyên.
4. Bấm được cả lúc đang phát (lúc cần tua nhất), có hiệu lực ngay.
5. File cài đặt hỏng: lặng lẽ dùng mặc định (chỉ log WARN), không có dòng báo như file lưu: mất cài đặt không mất gì của người chơi.

### Hiện trạng code (đọc trước khi sửa)

- `src/battle/event_player.gd`: `play(events, snapshot)` canh đồng hồ thật bằng `deadline` (≤ `MAX_PHASE_SECONDS` = 3 s), `_time_scale` co cả pha, sàn `MIN_EVENT_SECONDS`; `_wait` dùng timer (không chờ `Tween.finished`); `_new_tween()` giữ `_active_tween`. `instant` (headless/GUT) → `play_now`, không chờ. Test đồng hồ thật: `test_play_stays_under_three_seconds_on_the_clock` (đặt `instant = false`).
- `src/battle/battle_view.gd`: `_enemy_turn` đúng trong lúc phát pha địch (`_pending_enemy_turn` do `begin_battle()` và `_on_end_turn()` đặt); `_on_events_resolved` khóa HUD rồi phát; mọi handler bỏ qua khi `_playing` — handler tua thì **không**.
- `src/ui/hud.gd`: nút dựng bằng `_button()`, `FOCUS_NONE`; `_apply_disabled()` khóa theo `_locked` — nút tua không đi qua đây.
- `src/battle/battle_input.gd`: `ACTION_KEYS` + `_unhandled_input`, không nhận lặp phím.
- `src/app/app_state.gd`: autoload duy nhất; kiến trúc ghi "tiến độ, cài đặt" ở đây.
- `src/data/save_system.gd` (Story 4.3): mẫu `static var path` + hook `tests/pre_run.gd` + test giữ/trả `_old_path`.

### Điều phải giữ

- NFR3 (≤ 3 s mỗi pha ở tốc độ thường), mọi test hoạt ảnh hiện có; luật và kịch bản không đổi.
- Luồng 4.1–4.3 (menu, chuyển trận, tự lưu), F-phím dev, phím Q/W.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.4] (FR42)
- [Source: _bmad-output/planning-artifacts/game-architecture.md] dòng 80, 101, 202, 357, 467, 500, 583
- [Source: _bmad-output/project-context.md] dòng 52
- [Source: _bmad-output/implementation-artifacts/4-3-tu-luu.md] (mẫu đường dẫn file cho test, hook pre_run)

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Nền trước story: HEAD `1f1b36c`; `tools/test.sh` 843/843.
- `ConfigFile.load` file sai cú pháp: Godot tự in "ConfigFile parse error" ra console (không có cách đọc im lặng như `JSON.new().parse`). Test ca file hỏng dùng `assert_engine_error`. Trong game chỉ thấy dòng đó ở console, kèm `WARN [settings]`.
- Kiểm đột biến: bỏ chia cho tốc độ trong `EventPlayer.play` → `test_fast_speed_plays_every_event_under_one_second` trượt; bỏ `_apply_speed()` lúc bắt đầu phát → `test_fast_speed_only_for_enemy_phase`, `test_fast_forward_kept_after_reopen` trượt. Trả lại thì xanh.
- Sau khi chạy test, thư mục `user://` thật không có `settings.cfg`.
- Cuối: `tools/test.sh` 859/859 GUT, 173 kịch bản đã duyệt.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- `PlayerSettings` (`src/data/player_settings.gd`): `load_settings()` luôn ok và luôn có `data`; file hỏng/giá trị lạ chỉ là cảnh báo. Số nguyên `3` sửa tay vẫn được nhận. `save()` ghi đè cả file.
- `EventPlayer`: `FAST_SPEED = 3`, `set_speed()`/`speed()`; thời lượng, sàn và trần pha chia cho tốc độ; đổi giữa chừng co phần hạn chót còn lại. Không bỏ sự kiện.
- `BattleView`: `_fast`, `set_fast_forward()`, `fast_forward()`, signal `fast_forward_changed`; `_on_fast_forward` chạy cả khi đang phát; `_apply_speed()` mỗi lần phát (tua chỉ khi `_enemy_turn`).
- `Hud`: nút tua dưới "Kết thúc lượt", không qua `_apply_disabled` (không bị khóa). `BattleInput`: phím T.
- `main.gd`: `_load_settings()` lúc mở game (`AppState.settings`), `_on_fast_forward_changed` lưu + log; ghi hỏng → `ERROR [settings]`.
- Cô lập test: hook `pre_run.gd` trỏ `PlayerSettings.path` sang file test; `test_main.gd`, `test_player_settings.gd` dùng file riêng và trả lại đường dẫn.
- Test mới: `test_player_settings.gd` (7), `test_event_player.gd` (+2, đồng hồ thật), `test_main.gd` (+7; thêm phím T vào hai test "phím không làm gì" ở menu và màn chuyển trận).
- Chưa chụp ảnh nút trên màn hình: GoPeak không kết nối được trong phiên này. Bảng nút tính ra vẫn vừa (≈ 520 px trên 720).

**Hướng dẫn tác giả thử tay** (`tools/chay.sh --dev --tran=3`, trận có nhiều quân Nguyên):
1. Bảng nút bên phải có thêm "Tua nhanh (T): tắt" dưới "Kết thúc lượt".
2. Bấm "Kết thúc lượt": quân Nguyên ra đòn tốc độ thường (≈ 2–3 giây).
3. Gõ T (hoặc bấm nút): chữ thành "Tua nhanh (T): bật". Kết thúc lượt lần nữa: quân Nguyên ra đòn nhanh gấp 3, vẫn thấy đủ từng bước (đi, đánh, gục).
4. Đang lúc quân Nguyên ra đòn, gõ T: phần còn lại chuyển tốc độ ngay.
5. Đi/đánh bằng tướng của mình: tốc độ không đổi dù tua đang bật.
6. Tắt game, mở lại: nút vẫn "bật", pha địch vẫn nhanh.

### File List

- `game/src/data/player_settings.gd` (mới), `game/src/data/player_settings.gd.uid` (mới)
- `game/src/battle/event_player.gd`, `game/src/battle/battle_view.gd`, `game/src/battle/battle_input.gd`
- `game/src/ui/hud.gd`, `game/src/app/main.gd`, `game/src/app/app_state.gd`
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/tests/pre_run.gd`, `game/tests/test_player_settings.gd` (mới), `game/tests/test_player_settings.gd.uid` (mới), `game/tests/test_event_player.gd`, `game/tests/test_main.gd`
- `_bmad-output/implementation-artifacts/4-4-tua-nhanh-pha-dich.md`, `_bmad-output/implementation-artifacts/sprint-status.yaml`
