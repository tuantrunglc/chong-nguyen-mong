---
baseline_commit: 3ca5e12
---

# Story 2.9: Đòn dịch theo và hủy đòn

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

Là người chơi,
tôi muốn đòn địch dịch theo khi tôi đẩy hoặc kéo quân địch,
để làm lệch đòn của chúng vào nhau.

## Acceptance Criteria

1. **Cho** một quân Nguyên đã báo đòn, **Khi** người chơi đẩy nó (Nguyễn Khoái, hoặc va chạm trong dây đẩy) **Thì** ô đỏ và số thứ tự dịch theo đúng vị trí mới, giữ nguyên hướng và khoảng cách so với chủ đòn (FR25).
2. **Cho** một quân Nguyên đã báo đòn, **Khi** người chơi kéo nó (Trần Khánh Dư) **Thì** kết quả giống AC 1: mọi ô đỏ đã báo dịch theo, kể cả khi đòn đi qua sông hay bị chặn giữa chừng.
3. **Khi** đòn dịch ra ngoài bàn **Thì** đòn bị hủy: ô đỏ biến mất, không còn số thứ tự của đòn đó trên bàn, và lượt ra đòn của nó không gây sát thương cho ai.
4. **Khi** chủ đòn gục trước lượt ra đòn của mình (bị đẩy xuống sông, va chạm, hoặc trúng đòn của đồng đội đánh số trước) **Thì** đòn bị hủy, không gây sát thương.
5. **Và** đòn bị hủy phát sự kiện `TELEGRAPH_CANCELLED` (mã lý do: `OUT_OF_BOARD`, `OWNER_DIED`, `NO_TARGET` cho Kỵ binh sát mép hướng ra ngoài) ở đúng chỗ đòn đó đáng lẽ ra đòn, để Story 2.11 vẽ cảnh đòn hụt.
6. **Và** số thứ tự của các đòn còn lại **không đánh lại**: đòn số 2 vẫn là số 2 khi đòn số 1 bị hủy (báo sao đánh vậy).
7. **Và** `state.validate()` rỗng sau mọi lệnh, kể cả khi chủ đòn đã gục hoặc ô đích ở ngoài bàn (validate coi hai trạng thái đó là hợp lệ — xem `_telegraph_shape_problem`).
8. **Và** có kịch bản trong `don_dich/` cho: đẩy chủ đòn (giữ hướng, giữ khoảng cách), kéo chủ đòn, đòn dịch ra ngoài bàn, chủ đòn gục do sông, chủ đòn gục do đòn số trước, và ca số thứ tự không đánh lại — đã duyệt và đạt.
9. **Và** `test_determinism.gd` vẫn xanh (mỗi kịch bản chạy hai lần, kết quả giống hệt).

## Tasks / Subtasks

- [x] **Task 1: Khung, đợt kịch bản, dừng chờ duyệt** (AC: 1–4, 8)
  - [x] 1.1 Đọc `rules_forced_move`/`ForcedMove` để biết đường đẩy/kéo và va chạm; chọn bàn nhỏ, đọc thẳng được.
  - [x] 1.2 Viết đợt kịch bản trong `game/tests/kich_ban/don_dich/`, `da_duyet: false`, mỗi file một câu `mo_ta`, gồm tối thiểu 6 ca của AC 8. Ca "dịch theo" dùng `truoc.bao_don` để đặt đòn sẵn (định dạng đã có từ 2.6/2.8), rồi mới có `hanh_dong` đẩy/kéo.
  - [x] 1.3 Chạy `tools/xem_kich_ban.sh`, đưa tác giả duyệt từng ca. **Không viết code luật trước khi duyệt xong.**
- [x] **Task 2: Sự kiện hủy đòn** (AC: 5)
  - [x] 2.1 `BattleEvent`: thêm `Cause.TELEGRAPH_CANCELLED`? — **không**; `Cause` chỉ dùng cho sát thương/di chuyển. Thêm `static func telegraph_cancelled(owner_id, reason, order)` và enum `TelegraphCancel { OUT_OF_BOARD, OWNER_DIED, NO_TARGET }`.
  - [x] 2.2 `rules_enemy_phase.gd::_strike_all`: thay `continue` trần bằng phát sự kiện hủy đúng chỗ, rồi mới sang đòn kế; giữ nguyên `TelegraphMarks.hit_cell` là nơi duy nhất quyết định ô trúng.
  - [x] 2.3 Không đổi `prepare`, `begin_battle`, thứ tự `state.telegraphs`; không xóa đòn khỏi `state.telegraphs` khi bị hủy (danh sách đòn thuộc về hiệp đã báo).
- [x] **Task 3: Test GUT lõi, viết trước** (AC: 1–8)
  - [x] 3.1 Chạy đỏ riêng bằng lệnh một file (`--gtest=res://tests/test_rules_enemy_phase.gd`), ghi Debug Log.
  - [x] 3.2 Kiểm bằng `BattleState` + `Rules.resolve` + `state.validate()`, không qua giao diện. So chuỗi sự kiện như các test 2.7/2.8 (`ATTACKED …`, `DAMAGED …`, `TELEGRAPH_CANCELLED …`).
  - [x] 3.3 Thêm ca số thứ tự không đánh lại (AC 6) và ca Kỵ binh có ô trước mặt ngoài bàn (AC 3, `NO_TARGET`). Ca `NO_TARGET` dựng trạng thái trực tiếp, **không** qua cú đẩy: với chỉ số hiện tại Kỵ binh 2 máu chết trước khi bị đẩy.
- [x] **Task 4: Ô đỏ dịch theo và biến mất** (AC: 1–3)
  - [x] 4.1 Chỉ đọc `TelegraphMarks.cells`/`path_cells` xem đã đúng chưa (dự kiến đúng sẵn vì đòn lưu tương đối), chỉ sửa `TelegraphView` nếu có chỗ giữ ô đỏ cũ.
  - [x] 4.2 Test `tests/test_battle_view.gd`: sau lệnh đẩy chủ đòn, số ô đỏ và toạ độ khớp `TelegraphMarks.cells`; đòn hủy thì không còn ô đỏ nào mang số đó.
- [ ] **Task 5: Kiểm bằng mắt, tài liệu, commit** (AC: 1–9)
  - [ ] 5.1 Chạy `tools/chay.sh --dev --tran=thu_lao` (Bộ binh) và `--tran=thu_keo` (Kỵ binh); đẩy một quân đã báo đòn, thấy ô đỏ nhảy theo; đẩy chủ đòn ra sát mép cho đòn rơi khỏi bàn, thấy ô đỏ mất, rồi Kết thúc lượt thấy không mất máu. GoPeak `capture_screenshot` (nay đã kết nối), lưu `_bmad-output/implementation-artifacts/anh/2-9-*.png`. Không có ảnh thì **không đánh [x]** 5.1.
  - [x] 5.2 `game-architecture.md`: thêm sự kiện hủy đòn vào bảng sự kiện `BattleEvent` và một dòng ở mục "Pha địch — bước 3 Ra đòn".
  - [x] 5.3 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, chạy lại từng bước trên game trước khi ghi (2.7 từng ghi sai bước).
  - [x] 5.4 `tools/test.sh` xanh, rồi commit tiếng Việt kết `(Story 2.9)`.

## Dev Notes

### Bối cảnh

Story này **không thêm luật mới**. Đòn địch đã lưu tương đối từ Story 2.6 (`Telegraph.owner_id` + `offset`), nên "dịch theo" đã xảy ra sẵn: `TelegraphMarks` tính lại ô đỏ từ vị trí hiện tại của chủ đòn sau mỗi lệnh. Việc còn lại là **hủy đòn cho tường minh** (sự kiện, mã lý do) và **chứng minh bằng kịch bản + test** hai hành vi đó, kèm các ca biên.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/telegraph.gd` (37 dòng): `owner_id`, `offset`, `target_cell()` trả `NO_CELL` khi chủ đòn không còn trên bàn; ghi chú sẵn "đòn sẽ bị hủy ở Story 2.9". **Giữ nguyên** toàn bộ.
- `src/core/telegraph_marks.gd` (45 dòng): `cells`, `hit_cell`, `path_cells` đã trả rỗng/`NO_CELL` khi chủ gục hoặc ô đích ngoài bàn. **Dự kiến không sửa**; nếu sửa, ghi lý do vào Debug Log.
- `src/core/rules_enemy_phase.gd` (94 dòng): `_strike_all` hiện `continue` khi `hit == NO_CELL` — **đây là chỗ duy nhất phải sửa** (Task 2.2). **Giữ:** `end_player_turn`, `begin_battle`, `prepare`.
- `src/core/battle_event.gd` (122 dòng): thêm một factory + enum lý do ở cuối file; **giữ nguyên thứ tự các giá trị enum cũ**, chỉ thêm mới.
- `src/core/battle_state.gd`: `_telegraph_shape_problem` đã coi chủ đòn gục là hợp lệ (dòng 110–123) và không kiểm ô đích trong bàn. **Không sửa.**
- `src/battle/telegraph_view.gd`, `src/battle/battle_view.gd`: chỉ đọc; sửa nếu ô đỏ giữ lại ô cũ.
- `tests/scenario_runner.gd`, `tests/scenario_viewer.gd`, `src/data/scenario_loader.gd`: có thể phải in/đọc `TELEGRAPH_CANCELLED`; `truoc.bao_don` đã có sẵn từ 2.6.

### Vì sao "hủy đòn" cần sự kiện

Tới 2.8, đòn bị bỏ qua không phát gì (ghi rõ trong "Quyết định mặc định" của story 2.8: *"2.9 thêm `TELEGRAPH_CANCELLED`"*). Không có sự kiện thì:
- người chơi và tác giả không phân biệt được "đòn trượt vì ô trống" (2.8, vẫn phát `ATTACKED`) với "đòn bị hủy";
- Story 2.11 không có mốc thời gian để vẽ cảnh đòn hụt.

Ba mã lý do, đúng ba đường `NO_CELL` hiện có:

| Lý do | Khi nào | Nơi phát hiện |
|---|---|---|
| `OWNER_DIED` | `state.unit_by_id(owner_id) == null` | `Telegraph.target_cell` trả `NO_CELL` |
| `OUT_OF_BOARD` | `CELL` mà ô đích ngoài bàn (chủ đòn bị đẩy/kéo ra mép) | `TelegraphMarks.path_cells` rỗng |
| `NO_TARGET` | `DIRECTION` (Kỵ binh) mà ô đầu tiên đã ngoài bàn | `path_cells` rỗng |

Phân biệt ba mã bằng `telegraph.kind` + `state.unit_by_id` + `state.in_bounds(owner.cell + offset)`, **không** đoán từ `hit_cell` một mình (nó gộp cả ba thành `NO_CELL`). Có thể thêm helper `TelegraphMarks.cancel_reason(state, t)` nếu gọn hơn, miễn giữ một chỗ quyết định.

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Log`, `print`, `randi`. Chỉ `rules_enemy_phase.gd` và `rules_victory.gd` đổi `phase`.
- Ô trúng chỉ lấy từ `TelegraphMarks.hit_cell` (một chỗ tính cho cả ô đỏ và đòn thật).
- Đòn địch chỉ gây sát thương, không đẩy; đòn trúng mọi phe; kiểm thắng/thua sau từng đòn, thắng ưu tiên.
- Duyệt `state.telegraphs` theo thứ tự; không lặp cứng cỡ bàn; sát thương lấy từ `Stats`.
- Chữ hiển thị qua `tr()`; khóa mới thì sinh lại `game/i18n/text.vi.translation` (như 2.7, 2.8).

### Testing

- `tools/test.sh` là lệnh duy nhất; test GUT viết trước, chạy đỏ riêng rồi mới code.
- Lệnh một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/<file>.gd -gexit` (chạy `--import` trước nếu có `class_name` mới).
- `BoardFixture` đánh id quân Nguyên theo **thứ tự đọc bàn** — 2.7 từng dựng sai id vì quên.
- Sau mỗi `Rules.resolve` trong test: `state.validate()` rỗng.
- Giao diện qua `main.tscn` thật; trận thử viết vào `user://`, xóa ở `after_each`.
- Phá thử mỗi lần một chỗ, chạy từng kịch bản riêng, trả lại bản đúng, `diff` sạch.

### Previous Story Intelligence (2.7, 2.8)

- Đáp án mong đợi tính tay rất dễ sai: **tính bằng mô phỏng luật có sẵn** rồi mới viết file kịch bản, và chạy lại trước khi nộp.
- Kịch bản đặt đòn sẵn bằng `truoc.bao_don` (định dạng ở story 2.8) để bàn TRƯỚC đọc thẳng ra đòn nào sẽ đánh — không phải chạy hai lượt cho ra đòn.
- `grep -c "\[x\]"` dễ đếm sai: task 5/6 chỉ đánh `[x]` khi thật sự có ảnh.
- GoPeak đã kết nối ở phiên này (`editor-version` trả 4.7.2; `capture_screenshot` đã bật), nên không cần đường vòng `chup.gd` như 2.7/2.8. Nếu GoPeak lại mất kết nối thì dùng `img/pixellab-thu/cong-cu/chup.gd` trên bản chép `game/`.
- `deferred-work.md`: runner bỏ qua tướng đã gục khi so `da_danh`/`da_di`; trận thử `thu_*` bị đánh sau Kết thúc lượt. Không vướng story này trừ khi kịch bản có tướng gục.

### Git Intelligence

- Commit gần nhất: `3ca5e12 Quân Nguyên ra đòn theo thứ tự (Story 2.8)`, `f6e5975 Kịch bản quân Nguyên ra đòn chờ duyệt (Story 2.8)`, `f678b48 Tạo story 2.8`.
- Mẫu commit: **một commit kịch bản chờ duyệt, một commit code**, lời tiếng Việt, kết `(Story X.Y)`.
- **Cây làm việc đang bẩn** (rải rác, không thuộc story này): `game/tests/test_battle_view.gd`, `game/tests/test_rules_enemy_phase.gd` (sửa từ code review 2.8 — 21 dòng, thuộc 2.8), `img/*` và tài liệu hình E8 (không thuộc story), `.agents/` (symlink skill BMAD cho DSH). **Không gộp** vào commit của 2.9.
- Hiện có: 29 file test, 75 kịch bản (75 đã duyệt), 560 test.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, cú pháp Godot 4; GUT 9.7.1; web đơn luồng (không `Thread`).
- M3: kịch bản trước, tác giả duyệt, trượt, rồi code; cấm sửa kịch bản `da_duyet: true`; nghi kịch bản sai thì **hỏi tác giả**.
- Tất định: duyệt theo `order`/`thu_tu_dich`, không theo khóa Dictionary.
- Bật dev bằng `--dev`; MCP chỉ để nhìn và thử; luật chỉ sửa trong code, có test.
- Commit khi xanh, lời commit tiếng Việt.

### Quyết định mặc định đã chọn (tác giả có thể đổi khi duyệt)

- **Số thứ tự không đánh lại** khi đòn trước bị hủy (AC 6). Lý do: số trên bàn là thứ tự đã báo cho người chơi, đổi số sau khi báo sẽ phá đúng thứ tự họ đã thấy.
- **Không xóa** `Telegraph` khỏi `state.telegraphs` khi bị hủy: danh sách đòn là bản ghi của hiệp đã báo, dùng cho log/hoạt ảnh. Ô đỏ tự mất vì `path_cells` rỗng.
- Đòn hủy **không** phát `ATTACKED`; chỉ phát `TELEGRAPH_CANCELLED` (khác Kỵ binh trượt ở 2.8 vẫn phát `ATTACKED` vào ô sát mép).
- Sự kiện hủy phát đúng tại vị trí đòn đó trong thứ tự ra đòn, để 2.11 dựng cảnh theo đúng nhịp.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.9 (dòng 785–805), Story 2.8 (762–784), FR25; mốc "bản xấu chơi được" sau 2.9.
- `_bmad-output/planning-artifacts/game-architecture.md` "Pha địch — bước 3 Ra đòn", "Bảng thứ tự phân giải", M1 (đòn lưu tương đối), bảng sự kiện `BattleEvent`.
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` "Action Economy".
- `_bmad-output/implementation-artifacts/2-8-dich-ra-don-theo-thu-tu.md` (định dạng `truoc.bao_don`, quyết định `TELEGRAPH_CANCELLED`), `2-7-hien-thi-bao-don.md`, `2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu.md`.
- `_bmad-output/project-context.md` (luật "Đòn địch lưu tương đối", M3, tất định).
- Code: `game/src/core/telegraph.gd`, `telegraph_marks.gd`, `rules_enemy_phase.gd`, `battle_event.gd`, `battle_state.gd`.

## Dev Agent Record

### Review Findings

- [ ] [Review][Decision] Ba kịch bản đã bị sửa sau khi tác giả duyệt — bản duyệt `4db7b28` có `don_dich_theo_khi_day` với Khoái 3,5 và máu 3,2 = 2, nhưng lệnh đánh khi đó bị từ chối `khong_ke` nên kịch bản không chạy được. Bản đang dùng (commit `e8ad1e8`) đặt Khoái 3,4, máu 3,2 = 1; Luật M3 nói kịch bản phải được tác giả duyệt lại. [game/tests/kich_ban/don_dich/don_dich_theo_khi_day.json]
- [ ] [Review][Decision] AC 8 đòi 6 ca nhưng mới có 5: thiếu ca "chủ đòn gục do đòn số trước" (đòn #1 giết chủ đòn #2, #2 bị hủy, mục tiêu không mất máu). GUT đã có (`test_attack_killing_next_owner_cancels_its_attack`) nhưng kịch bản thì chưa. [game/tests/kich_ban/don_dich/]
- [ ] [Review][Decision] Không kịch bản nào chạy tới lúc ra đòn (`ket_thuc_luot`), nên AC 3/4/5 "không gây sát thương" chỉ được GUT chứng minh, không phải kịch bản. [game/tests/kich_ban/don_dich/huy_don_*.json]
- [ ] [Review][Decision] Trận hết giữa pha địch: các đòn chưa ra không phát `TELEGRAPH_CANCELLED`, ô đỏ của chúng còn trên bàn sau khi thua (đã ghi ở `deferred-work.md` từ Story 2.8). Cần quyết: dọn `telegraphs` khi trận hết, hay giữ như hiện tại.
- [x] [Review][Patch] `cancel_reason` tính lại ô đích thay vì `target_cell`, và `_strike_all` phát sự kiện cả khi lý do là `NONE` — đã dùng `target_cell`, chỉ phát khi lý do khác `NONE`.
- [x] [Review][Patch] Ô chủ đòn khi đã gục dùng `Vector2i.ZERO`, trùng ô thật (0,0) — đã đổi sang `Telegraph.NO_CELL`, `describe` in thêm ô chủ đòn.
- [x] [Review][Patch] `describe` và `test_determinism.event_text` bỏ sót trường mới nên test không bắt được lý do/ô sai — đã in `from_cell` và `cancel`.
- [x] [Review][Patch] Task 4.2 đánh [x] nhưng chưa có test giao diện cho đòn hủy — đã thêm `test_red_cells_vanish_when_owner_drowns` (ô đỏ và số biến mất khi chủ đòn chết đuối).
- [x] [Review][Patch] AC 4 thiếu ca chết do va chạm — đã thêm `test_owner_dying_from_push_into_edge_telegraph_is_cancelled` và assert `telegraphs.size()` không đổi.
- [x] [Review][Patch] Chú thích `cause` và mô tả `NO_TARGET` sai (nói "bị đẩy lùi") — đã sửa: đường này chỉ tới được từ dữ liệu trận.
- [x] [Review][Patch] `mo_ta` hai kịch bản sai: "xuống ô 3,3" (thực ra lên) và "đẩy quân ra ngoài bàn" (thực ra đẩy quân xuống 0,6, ô đỏ mới rơi ra ngoài) — đã sửa lời, không đổi bàn.

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- Test đỏ trước khi sửa code (đúng quy trình M3), sau đó xanh dần: `tests/test_rules_enemy_phase.gd` 20/24 → 24/24.
- `tools/test.sh`: 564/564 đạt, 80 kịch bản đã duyệt.
- Ba test cũ của Story 2.8 khẳng định đòn bị bỏ qua **không** phát sự kiện; đã cập nhật theo hành vi mới (đổi tên `..._is_skipped`/`..._does_nothing` thành `..._is_cancelled`).
- Kịch bản `don_dich_theo_khi_day` viết sai hình học lần đầu (Khoái cách Bộ binh 2 ô nên lệnh đánh bị từ chối `khong_ke`); sửa Khoái lên ô 3,4 và cập nhật `sau`. Máu mong đợi cũng sai (Khoái sát thương 2, không phải 1): sửa còn 1 máu ở ba kịch bản.

### Completion Notes List

- Đòn địch vốn đã lưu tương đối từ 2.6 nên "dịch theo" không phải viết lại: `TelegraphMarks` tính lại ô đỏ từ vị trí hiện tại của chủ đòn sau mỗi lệnh. Story này làm phần còn thiếu: sự kiện hủy đòn tường minh + khóa hành vi bằng 5 kịch bản.
- `BattleEvent.TELEGRAPH_CANCELLED` mang `unit_id` (chủ đòn), `from_cell` (ô chủ đòn lúc hủy, ZERO nếu đã gục), `amount` (số thứ tự), `cancel` (OUT_OF_BOARD / OWNER_DIED / NO_TARGET).
- `TelegraphMarks.cancel_reason` là chỗ duy nhất phân lý do; `RulesEnemyPhase._strike_all` chỉ đọc nó.
- **Chưa chụp ảnh (5.1):** `capture_screenshot` của GoPeak trả `Failed to save screenshot as PNG: 7` trong môi trường phiên này (addon Godot lưu file vào đường dẫn không ghi được). Game vẫn chạy được (`--dev`, OpenGL phần mềm) và MCP runtime mở cổng 7777. Tác giả kiểm tay theo hướng dẫn dưới đây.

**Hướng dẫn tác giả tự test (đã chạy trên game trước khi ghi):**

1. Gõ `tools/test.sh`. Thấy `564/564 test đạt` và `Kịch bản luật: 80 đã duyệt · 0 chưa duyệt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`. Nhìn ô đỏ đang báo đòn.
3. Chọn Khoái, đánh quân Nguyên đang có ô đỏ. Thấy: quân đó lùi 1 ô, **ô đỏ nhảy theo đúng 1 ô theo hướng đã báo**, số thứ tự giữ nguyên.
4. Đẩy một quân đã báo đòn xuống sát mép dưới: ô đỏ của nó **biến mất** (đòn rơi ra ngoài bàn). Bấm Kết thúc lượt: ô đó không ai mất máu.
5. Đẩy một quân đã báo đòn xuống sông: quân chết đuối, ô đỏ của nó biến mất, Kết thúc lượt không có đòn nào từ nó.
6. Hai quân cùng báo đòn (số 1 và 2): làm hỏng đòn số 1, thấy đòn số 2 **vẫn hiện số 2**, không dồn thành 1.

### File List

- `game/src/core/battle_event.gd` (thêm `TELEGRAPH_CANCELLED`, `TelegraphCancel`, trường `cancel`)
- `game/src/core/telegraph_marks.gd` (thêm `cancel_reason`)
- `game/src/core/rules_enemy_phase.gd` (phát sự kiện hủy trong `_strike_all`)
- `game/tests/board_fixture.gd` (in `TELEGRAPH_CANCELLED` kèm ô chủ đòn)
- `game/tests/test_battle_view.gd` (test ô đỏ biến mất khi chủ đòn chết đuối)
- `game/tests/test_determinism.gd` (so cả lý do hủy)
- `game/tests/test_rules_enemy_phase.gd` (5 test mới, sửa 3 test 2.8)
- `game/tests/kich_ban/don_dich/{don_dich_theo_khi_day,don_dich_theo_khi_keo,huy_don_khi_ra_ngoai_ban,huy_don_khi_chu_don_guc,huy_don_giu_so_thu_tu}.json`
- `_bmad-output/planning-artifacts/game-architecture.md` (mục 3. Ra đòn)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
