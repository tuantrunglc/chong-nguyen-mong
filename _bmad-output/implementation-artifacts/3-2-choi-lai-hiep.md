---
baseline_commit: 28f60ee
---

# Story 3.2: Chơi lại hiệp

Status: review

## Story

Là người chơi,
tôi muốn chơi lại hiệp một lần khi tính sai,
để sửa sai mà không phải đánh lại cả trận.

## Acceptance Criteria

1. **Cho** đang ở lượt người chơi, đã đi và đánh vài nước **khi** bấm Chơi lại (hoặc phím `R`) **thì** bàn về đúng trạng thái **đầu lượt người chơi của hiệp này** (FR39) — tức bàn người chơi đã thấy khi hiệp bắt đầu: quân Nguyên đã đi, đòn đã báo, ô đỏ còn nguyên.
2. **Khi** đã dùng một lần trong trận **thì** nút mờ đi, phím `R` không còn tác dụng; **và** giao diện hiện **số lần còn lại** (1 → 0).
3. **Cho** đã dùng một mưu kế trong lượt này **khi** bấm Chơi lại **thì** mưu kế đó được trả lại, dùng lại được trong lượt chơi lại (FR39). *Chưa có mưu kế (Story 3.12–3.13): story này bảo đảm bản chụp là `clone()` sâu của toàn bộ `BattleState`, nên khi mưu kế nằm trong state thì tự đúng; ghi rõ cách kiểm sau.*
4. **Khi** đã chơi lại hiệp rồi bấm Hủy (`Z`) **thì** không quay về được nước đi nào trước lúc chơi lại; bản chụp hủy đã bị xóa.
5. **Và** `tools/test.sh` xanh; test GUT cho controller, HUD và phím `R`. Story này **không** đổi luật trong `src/core/` và **không** thêm lệnh kịch bản (đây là cơ chế điều khiển, không phải luật; đối chiếu Story 2.11).

## Tasks / Subtasks

- [x] **Task 1: Bản chụp đầu lượt người chơi + `replay_round`** (AC: 1, 3, 4)
  - [x] 1.1 `game/src/battle/battle_controller.gd`: thêm `_turn_start: BattleState` và `_replay_used: bool`; khởi tạo trong `start()` (`null`, `false`).
  - [x] 1.2 Chụp `_turn_start = _state.clone()` **sau khi lệnh `BEGIN_BATTLE` hoặc `END_TURN` chạy xong** (tức sau `_start_round(...)`), chỉ khi `_state.phase == BattleState.Phase.PLAYER`; ngược lại `null`. Đây là bàn người chơi thấy khi hiệp bắt đầu (quân Nguyên đã đi, đòn đã báo).
  - [x] 1.3 `can_replay() -> bool`: có state, **không** hết trận, `phase == PLAYER`, `_turn_start != null`, `not _replay_used`. `replay_left() -> int`: `0` nếu đã dùng, ngược lại `1`.
  - [x] 1.4 `replay_round() -> bool`: nếu `can_replay()` sai thì trả `false`, không đổi gì (im lặng, như nút mờ). Nếu đúng: `_state = _turn_start.clone()`, `_replay_used = true`, `_undo_snapshot = null`, gọi `_start_round(false)` (mốc F2 dời về bàn vừa khôi phục, xóa lệnh cũ), `events_resolved.emit([], _state.clone())`, trả `true`. Ghi `Log.debug("battle", "chơi lại hiệp")`.
  - [x] 1.5 Không ghi "chơi lại" vào `_round_commands` (định dạng kịch bản không có lệnh này); báo cáo F2 sau khi chơi lại phát lại từ bàn vừa khôi phục.

- [x] **Task 2: Giao diện và phím** (AC: 1, 2)
  - [x] 2.1 `game/src/battle/battle_input.gd`: thêm `REPLAY_ACTION = "replay_round"`, `KEY_R` trong `ACTION_KEYS`, signal `replay_pressed`, xử lý trong `_unhandled_input` (không nhận lặp phím, như `Z`/`Space`).
  - [x] 2.2 `game/src/ui/hud.gd`: thêm nút `_replay_button` (`hud.replay`) + nhãn `_replay_label` hiện số lần còn lại; signal `replay_pressed`; `show_turn(...)` nhận thêm `can_replay: bool, replay_left: int`; `_apply_disabled` mờ nút khi không chơi lại được/đã dùng/đang khóa/hết trận. Nhãn: `hud.replay.left` với `%d` khi còn, `hud.replay.used` khi đã dùng.
  - [x] 2.3 `game/src/battle/battle_view.gd`: nối `input.replay_pressed` và `hud.replay_pressed` vào `_on_replay()`; guard `_playing`/`_battle_over`; gọi `_controller.replay_round()`; nếu trả `true` thì `_deselect()`; `_update_hud()` truyền `can_replay`/`replay_left`.
  - [x] 2.4 `game/i18n/text.csv`: `hud.replay,Chơi lại (R)`, `hud.replay.left,Còn %d lần`, `hud.replay.used,Đã dùng`. Chạy import để cập nhật `text.vi.translation`.

- [x] **Task 3: Test GUT** (AC: 1–4)
  - [x] 3.1 `game/tests/test_battle_controller.gd`: chơi lại sau khi đi + đánh → bàn, máu, `telegraphs`, `enemy_intents`, `round_number`, `has_moved`/`has_attacked` y như đầu lượt; `can_undo()` false sau chơi lại; chơi lại lần hai trả `false`; trước `begin()` và khi trận đã hết trả `false`; `replay_left()` 1 → 0.
  - [x] 3.2 `game/tests/test_battle_view.gd`: nút Chơi lại sáng ở đầu lượt, bấm → bàn về đầu lượt và nút mờ + nhãn "Đã dùng"; phím `R` làm việc đó; sau khi chơi lại, `Z` không hủy được gì; nút mờ khi đang phát hoạt ảnh; hết trận thì mờ.
  - [x] 3.3 `game/tests/test_bug_report.gd` (hoặc test kịch bản F2): sau khi chơi lại rồi đi một nước, báo cáo F2 vẫn phát lại ra đúng bàn hiện tại.
  - [x] 3.4 Không thêm lệnh kịch bản; nếu review đòi, ghi thành việc sau.

- [x] **Task 4: Xanh, kiểm ngược, chạy tay, commit** (AC: 1–5)
  - [x] 4.1 `tools/test.sh` xanh (phiên AI: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`).
  - [x] 4.2 Kiểm ngược: (a) bỏ gọi `_start_round(false)` trong `replay_round` → test F2 trượt; (b) không xóa `_undo_snapshot` → test Hủy-sau-chơi-lại trượt; (c) bỏ `_replay_used = true` → test dùng-hai-lần trượt; (d) bỏ capture `_turn_start` → test chơi lại trượt. Khôi phục từng cái, **sao lưu ra `/tmp` trước, không `git checkout`** (bài học 3.1).
  - [x] 4.3 Chạy tay `tools/chay.sh --dev --tran=1`: đi 1–2 nước rồi bấm Chơi lại/R — bàn về đầu lượt, ô đỏ còn, nút mờ, nhãn "Đã dùng"; bấm R lần nữa không gì xảy ra. Chụp cửa sổ game (`DISPLAY=:1 import -window <id>`) nếu GoPeak không nối.
  - [x] 4.4 Commit riêng phần code + test; lời tiếng Việt, kết `(Story 3.2)`. Không gộp `img/`.

## Dev Notes

### Hiện trạng trước story này (đọc trước khi sửa)

- `BattleController` (RefCounted) là **nơi duy nhất giữ trạng thái sống**. Đã có `_undo_snapshot` (hủy nước gần nhất) và `_round_start`/`_round_commands` cho báo cáo F2.
- `submit()` xóa `_undo_snapshot` khi `ATTACK`, `END_TURN`, `BEGIN_BATTLE`; hủy thành công cũng xóa. **Chơi lại phải xóa nốt** (AC 4).
- `_start_round(keep_previous)` dời mốc F2. Sau `BEGIN_BATTLE`/`END_TURN` nó chạy trong `submit()`; `BEGIN_BATTLE` không giữ hiệp trước.
- `BattleState.clone()` **sao chép sâu** Unit, Telegraph, EnemyIntent (đã kiểm ở 2.13); mọi trạng thái mới thêm sau này phải vào `clone()` — đó là điều kiện để AC 3 tự đúng khi có mưu kế.
- UI: `Hud.show_turn(round_number, can_undo, over)` dựng nút Hủy/Kết thúc; `BattleInput` khai báo phím bằng code trong `ACTION_KEYS`; `BattleView._on_events_resolved` khóa nút khi phát hoạt ảnh (`set_locked`).
- `_battle_over()` trong view và `Rules.is_battle_over(state)` đã có; dùng lại, đừng viết cờ mới.
- Không có mưu kế trong code hiện tại (3.12–3.13). AC 3 chỉ kiểm được phần "khôi phục mọi thứ trong state"; ghi rõ trong Completion Notes là **chưa kiểm được** cho tới khi có mưu kế.

### Thiết kế phải theo

```
"Đầu lượt người chơi của hiệp này" = trạng thái SAU pha chuẩn bị của địch
  (quân Nguyên đã đi xong, telegraphs/enemy_intents đã có, phase = PLAYER).
  Hiệp 1: sau BEGIN_BATTLE. Hiệp sau: sau END_TURN.
Chơi lại: _state = _turn_start.clone(); KHÔNG chạy lại luật, không phát hoạt ảnh
  (events rỗng); view vẽ lại bàn chụp và tính lại ô sáng.
Một lần mỗi trận: cờ _replay_used; dùng rồi thì nút mờ + phím R im lặng.
Hủy sau chơi lại: _undo_snapshot = null, nên Z báo NOTHING_TO_UNDO.
F2 sau chơi lại: _round_start = bàn vừa khôi phục, _round_commands = []; báo cáo vẫn
  phát lại được từ đó (đòn đã báo nằm trong bàn chụp).
```

### Chỗ phải sửa, và chỗ KHÔNG được sửa

| File | Việc |
|---|---|
| `game/src/battle/battle_controller.gd` | `_turn_start`, `_replay_used`, `can_replay`, `replay_left`, `replay_round` |
| `game/src/battle/battle_input.gd` | action `replay_round` + KEY_R + signal |
| `game/src/ui/hud.gd` | nút + nhãn số lần + `show_turn` |
| `game/src/battle/battle_view.gd` | nối signal, `_on_replay`, `_update_hud` |
| `game/i18n/text.csv` (+ `.translation`) | 3 khóa `hud.replay*` |
| `game/tests/test_battle_controller.gd`, `test_battle_view.gd`, `test_bug_report.gd` | test |
| **Không sửa** | `src/core/*` (không đổi luật), `Rules`, `Effects`, `ForcedMove`, `chi_so.json`, `game/data/tran/*`, kịch bản đã duyệt |

Nếu thấy phải sửa `src/core/` thì **dừng, hỏi tác giả**: chơi lại là cơ chế của controller, không phải luật.

### Testing

- `tools/test.sh`; chạy một file GUT:
  `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_controller.gd -gexit`
- Test controller không cần màn hình (dựng `LevelData` + `BoardFixture.stats()` như các test cũ).
- Test view dùng `main.gd`/`_hud(main)` như `test_battle_view.gd` hiện có; bấm nút bằng `_click_button`.
- Báo cáo F2: `BugReport.build(state, round_start, commands)` — kiểm bằng cách phát lại đúng như `test_bug_report.gd` đang làm.

### Bẫy của story này

1. **Chụp `_turn_start` trước pha chuẩn bị** (ở đầu `END_TURN`) — sai: người chơi phải về bàn đã thấy, tức sau khi quân Nguyên đi và báo đòn.
2. **Chụp cả khi trận đã hết** (thua trong pha địch) — `can_replay` phải chặn bằng `Rules.is_battle_over`.
3. **Quên xóa `_undo_snapshot`** — Z sẽ quay về trước lúc chơi lại (AC 4).
4. **Quên `_start_round(false)`** — F2 phát lại từ bàn cũ + lệnh cũ, ra bàn khác hiện tại.
5. **Ghi "chơi lại" vào `_round_commands`** — định dạng kịch bản không có lệnh này; báo cáo F2 sẽ hỏng.
6. **Nút vẫn bấm được khi đang phát hoạt ảnh** — dùng `_playing`/`set_locked`, đừng tạo cờ mới.
7. **Phím R nhận lặp** — dùng `is_action_pressed(action, false, true)` như Z/Space.
8. **Đổi chữ mà quên import** — `text.vi.translation` phải được cập nhật và commit.

### Previous Story Intelligence (3.1, 2.15, 2.11, 2.13)

- 3.1: commit ngay sau mỗi phần vì có phiên khác `git checkout` xoá thay đổi chưa commit.
- 2.13: `BattleState.clone()` đã sâu; thêm trường mới thì phải thêm vào `clone()`.
- 2.11: view khóa nút bằng `_playing`/`set_locked`; hoạt ảnh chỉ phát lại `BattleEvent`, không đọc trạng thái sống.
- 2.15: khi thêm khóa dịch/CSV, nhớ `text.vi.translation` và test i18n.

### Git Intelligence

- HEAD lúc tạo story: `28f60ee` (dọn asset E8 của phiên khác) trên `0878a53` (chốt review 3.1).
- Mẫu commit: tiếng Việt, kết `(Story X.Y)`; code và test cùng commit, không gộp `img/`.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1; `src/core/` không bị đụng.
- Chỉ `BattleController` giữ trạng thái sống; UI gửi lệnh qua `submit()`/hàm controller, không sửa `BattleState`.
- Chữ hiển thị qua `tr()`, khóa dạng `<màn>.<mục>`; input qua InputMap khai báo bằng code.
- `tools/test.sh` là lệnh duy nhất; xanh rồi mới commit.

### Câu hỏi cho tác giả

1. **Chơi lại khi chưa đi nước nào** (vừa vào lượt, bấm R ngay) — có tính là "đã dùng một lần" không? Story đang làm **có** (đúng câu "đã dùng một lần trong trận"), vì đơn giản và tránh bấm thử làm mất lượt chơi lại.
2. **Có cần lệnh `choi_lai` trong kịch bản luật** (như `huy`) không? Story đang **không** thêm, vì đây là cơ chế điều khiển; nếu tác giả muốn kiểm bằng bàn cờ chữ thì mở việc riêng.

## Dev Agent Record

### Agent Model Used

DeepSeek Harness (deepseek-flash), 2026-10-23.

### Debug Log References

- **Nền trước story:** 632/632 test, 96 kịch bản đã duyệt, 0 trượt.
- **Bản chụp đầu lượt:** `_turn_start` chụp **sau** `BEGIN_BATTLE`/`END_TURN` (sau `_start_round`), chỉ khi `phase == PLAYER`. Hiệp 1 chụp sau `begin()`, nên bàn chơi lại có đủ quân Nguyên đã đi + đòn đã báo.
- **`replay_round`:** `_state = _turn_start.clone()`, `_replay_used = true`, `_undo_snapshot = null`, `_start_round(false)`, phát `events_resolved` với danh sách rỗng (view vẽ lại, không hoạt ảnh). Không ghi lệnh vào `_round_commands` (định dạng kịch bản không có lệnh này).
- **Giao diện:** nút "Chơi lại (R)" + nhãn "Còn 1 lần"/"Đã dùng"; phím `R` khai báo trong `ACTION_KEYS`; nút mờ khi đang phát hoạt ảnh/đã dùng/hết trận; `Hud.show_turn` nhận thêm `can_replay, replay_left`.
- **Test:** controller (chơi lại khôi phục ô, `has_moved`, `telegraphs`, `enemy_intents`, hiệp; hủy sau chơi lại không tác dụng; chơi lại lần hai/hết trận/chưa mở trận bị từ chối; báo cáo F2 dựng lại từ bàn vừa khôi phục); view (nút + phím R, nhãn, mờ sau dùng).
- **Kiểm ngược 4 đường (sao lưu `/tmp`, không `git checkout`):** (a) bỏ `_start_round(false)` → test F2 trượt ("2 lệnh, cần 1"); (b) không xóa `_undo_snapshot` → "Hủy không quay về trước lúc chơi lại" trượt; (c) không đặt `_replay_used` → "chỉ một lần mỗi trận"/"dùng rồi thì mờ" trượt; (d) không chụp `_turn_start` → "về ô đầu lượt"/"đi lại được" trượt. Khôi phục, xanh lại.
- **Kiểm tay:** chạy `main.tscn` bằng script chụp tạm (`game/tests/chup_tmp.gd`, đã xoá): ảnh `build/test/rl_01..04.png`. `rl_02`: Khoái đã đi (0,6)→(0,4), ô đỏ của Lão còn, nút Chơi lại sáng, nhãn "Còn 1 lần". `rl_03`: bấm `R` → Khoái về (0,6), ô đỏ còn, nút Chơi lại mờ + nhãn "Đã dùng", nút Hủy mờ. `rl_04`: bấm `R` lần hai không đổi gì.
- **Xanh cuối:** `tools/test.sh` → **638/638**, 96 kịch bản đã duyệt, 0 trượt.

### Completion Notes List

- **AC 1, 2, 4 xong** (bàn về đầu lượt người chơi, một lần mỗi trận + số lần còn lại trên HUD, Hủy sau chơi lại không tác dụng).
- **AC 3 chưa kiểm được:** chưa có mưu kế (Story 3.12–3.13). `BattleState.clone()` sao chép sâu mọi trường hiện có; khi mưu kế được thêm vào state (và `clone()`), chơi lại sẽ tự trả lại. Ghi thành việc kiểm ở 3.12/3.13.
- **Không sửa** `src/core/`, `chi_so.json`, `game/data/tran/*`, kịch bản đã duyệt. Không thêm lệnh kịch bản `choi_lai` (Câu hỏi 2 giữ "không").
- **Câu hỏi 1:** bấm Chơi lại ngay khi chưa đi nước nào **vẫn tính** đã dùng (theo câu "đã dùng một lần trong trận"); nút vẫn sáng tới lần bấm đầu.
- Ảnh kiểm tay nằm trong `build/` (gitignore), không commit.

### File List

- `game/src/battle/battle_controller.gd` — `_turn_start`, `_replay_used`, `can_replay`, `replay_left`, `replay_round`.
- `game/src/battle/battle_input.gd` — action `replay_round` + KEY_R + signal.
- `game/src/ui/hud.gd` — nút Chơi lại, nhãn số lần, `show_turn` mới.
- `game/src/battle/battle_view.gd` — nối signal, `_on_replay`, `_update_hud`.
- `game/i18n/text.csv` + `game/i18n/text.vi.translation` — 3 khóa `hud.replay*`.
- `game/tests/test_battle_controller.gd` — 4 test chơi lại + `_level_with_enemy`, `_stats` mở rộng.
- `game/tests/test_battle_view.gd` — 2 test nút/phím R.
- `_bmad-output/implementation-artifacts/3-2-choi-lai-hiep.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-23: thêm chơi lại hiệp (controller + HUD + phím R + nhãn số lần), 6 test GUT; kiểm ngược 4 đường; kiểm tay bằng ảnh trước/sau khi bấm R. `tools/test.sh` xanh 638/638. Story → `review`. AC 3 (trả lại mưu kế) chờ Story 3.12–3.13.
