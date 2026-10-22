# Acceptance Auditor findings

Story: 2.10 Rê chuột xem thông tin · Diff `7790797..HEAD -- game/` (commit `b874ecd`)
Files in diff: `game/i18n/text.csv`, `game/i18n/text.vi.translation`, `game/src/app/main.gd`,
`game/src/battle/battle_view.gd`, `game/src/battle/telegraph_view.gd`, `game/src/ui/tooltip.gd` (+`.uid`),
`game/tests/test_battle_view.gd`. `src/core/` untouched (verified with `git diff --stat`).

## AC checklist

| AC | Verdict | Evidence |
|----|---------|----------|
| 1 | PASS | `battle_view.gd:192-207` builds 3 lines: full name (`Tooltip.UNIT_NAMES[unit.type]`), `tooltip.hp` → `Máu cur/max` via `state.stats.max_hp`, attack line with `t.order`. Test `test_battle_view.gd:625-643` asserts "Nguyễn Khoái", "Máu 3/3", "Đánh ô 2,1, đòn số 1". Kỵ binh gets `tooltip.attack_charge` + direction. *Readability caveat: see H1 (panel width).* |
| 2 | PASS | `_telegraph_cells_of` (`battle_view.gd:218-225`) only collects `TelegraphMarks.path_cells` for `t.owner_id == unit.id`; other owners' cells are left drawn by the normal path (`telegraph_view.gd:180-189`). `highlight()` (`:95-101`) no second overlay layer. Test `:652-660` asserts exactly `[(3,4)]` → `[(5,6)]` → `[]`. |
| 3 | PASS | All display text goes through `tr()` (`battle_view.gd:192-215`), keys in `text.csv:100-117`; no literal display strings in code. `text.vi.translation` regenerated (Bin 5543 → 6331) and contains the new values ("Không có đòn nào", "Nguyễn Khoái" found in the binary). Test asserts "Sông" + "chết đuối". |
| 4 | FAIL | Rời bàn → hides (`battle_view.gd:181-183`), and no empty box is ever left. But an **empty in-board cell shows the terrain panel** (`battle_view.gd:186`), not "ẩn đi". The story contradicts itself here: AC 3 / Task 3.1 / Task 5.1 / epics 2.10 all require terrain info on an empty cell. Diff follows AC 3; author must decide (M2). |
| 5 | PASS | `mouse_filter = MOUSE_FILTER_IGNORE` on panel and label (`tooltip.gd:52,62`); test `:664-670` hovers, then `KEY_1` + click still attacks (Bộ binh pushed to 3,2, hp 1). |
| 6 | PASS (position only) | `place_at` (`tooltip.gd:84-93`) offsets 18/14 px, flips left/up near the right/bottom edge, then clamps into `get_viewport_rect().size` with an 8 px margin. Not tested (fine: eyes-only), and the *size* half of this AC is at risk — see H1. |
| 7 | PASS | `HIGHLIGHT_FILL_COLOR (1.0,0.45,0.45,0.85)` + white border 5 px vs normal `FILL_COLOR (1.0,0.08,0.08,0.65)` + dark-red 3 px (`telegraph_view.gd:13-14,33-35,180-189`); still red, so not confused with the blue selection. Colour itself is not unit-tested, correct per AC 8. Visual confirmation never happened (6.1) — see H1. |
| 8 | PASS | 3 new tests run headless through the real `res://scenes/main.tscn` and inject `InputEventMouseMotion` via `BattleInput._unhandled_input` (`_hover_by_mouse`, `:112-116`), not by calling the private handler. No test asserts pixels/colours. (Suite count 569/569 not re-run — auditor forbidden; story claims it.) |

## high — Tooltip width is unconstrained: the 340 px cap is dead code and the only visual gate (6.1) was skipped

- Violates: AC 1 / AC 3 readability, AC 6 (size), Task 2.3
- Evidence: `game/src/ui/tooltip.gd:46` `const MAX_WIDTH: float = 340.0` is referenced nowhere in `game/src` or `game/tests` (grep). `show_text` (`:68-76`) only calls `reset_size()`; the `Label` has `autowrap_mode = AUTOWRAP_WORD_SMART` (`:63`) and no `custom_minimum_size`. Compare `hud.gd:28-31,38-40`, where the same label-in-container pattern works only because the panel/box width is set explicitly. Godot 4 reports a Label's minimum width as ~1 px once autowrap is on, so `PanelContainer` → `reset_size()` yields a narrow column, not the intended ≤340 px box. The Debug Log confirms the width path was abandoned: "tự đặt `size`/`custom_minimum_size` cho container, sinh lỗi engine; đã bỏ, chỉ `reset_size()`".
- Why: this is exactly the defect the skipped screenshot step exists to catch — the tests assert `text()` only, so nothing measures size or position, and Task 6.1 (the eye check) is the one task honestly left `[ ]`. Needs one look at the running game before this story can be accepted.

## medium — Task 1.1's mandated i18n keys were not used

- Violates: Task 1.1 (marked `[x]`)
- Evidence: story mandates `tooltip.unit.<loại>` (6), `tooltip.hp`, `tooltip.attack`, `tooltip.attack_none`, `tooltip.order`, `tooltip.terrain`, `tooltip.effect.<địa hình>` (6). Delivered (`text.csv:100-117`): `unit.full.<loại>`, `tooltip.hp`, `tooltip.attack_cell`, `tooltip.attack_charge`, `tooltip.no_attack`, `terrain.plain` + pre-existing `terrain.<loại>` (`:19-24`), `terrain.effect.<địa hình>`. **`tooltip.order` does not exist** — the order number is baked into the attack strings instead.
- Why: a task marked done delivers a different key contract; `unit.full.*` at least avoids clashing with the existing short labels `unit.nguyen_khoai` ("Khoái") / `unit.bo_binh` ("B"), but the story's mandated `tooltip.unit.*` and `tooltip.order` are simply absent, so any later story/QA script keyed on them will miss.

## medium — AC 4 contradicts the rest of the story, and the diff silently picked the other side

- Violates: AC 4
- Evidence: `battle_view.gd:181-190` — out-of-bounds hides, but an in-board empty cell calls `show_text(_terrain_text(...))`. Task 3.1 ("ô trống nhưng trong bàn → tên địa hình + hiệu ứng"), Task 5.1 ("rê lên ô sông → hiện Sông") and the epics AC all demand the opposite of AC 4's "rê sang ô trống Thì khung thông tin ẩn đi".
- Why: AC 4 cannot be satisfied together with AC 3; the code chose the coherent reading, but the AC is literally unmet and only the author can retire or reword it — otherwise the next review will flag this again.

## medium — Task 3.3's "hide when the battle ends" is not delivered, and the commit message claims it is

- Violates: Task 3.3 (marked `[x]`)
- Evidence: `battle_view.gd:149-153` — on `Rules.is_battle_over` the view calls `_deselect()`, `_update_hud()` and then `_update_info(hovered_cell)`, i.e. it **shows** the unit/terrain panel after the battle ends instead of hiding it. `stop()` (`:48-55`) only runs from the error screen. Commit `b874ecd` says "ẩn khi ra ngoài bàn hoặc hết trận". No test covers the battle-over case.
- Why: Task 3.3 is marked done but the branch does the explicit opposite; the Dev Notes (2.9 intelligence: "phải ẩn **hoặc** chỉ hiện phần quân/địa hình khi trận đã hết") makes the code defensible, so this is either a fix-to-hide or a task/message that must be corrected — as written the record is inaccurate.

## low — Task 2.1 / 2.2 deliver a different API and a different placement

- Violates: Task 2.1, Task 2.2 (both marked `[x]`)
- Evidence: Task 2.1 requires `move_to(pos: Vector2)`; the code exposes `place_at(anchor: Vector2)` (`tooltip.gd:84`). Task 2.2 requires the panel to be placed in `main.tscn` on the top layer; it is created in `main.gd:56-57`, before `_result_banner`/`_battle_view` (draw order verified: `main.tscn` holds only the root `Main`, and `BattleView extends Node`, so the panel is above the board and below the result banner — i.e. correctly on top in practice).
- Why: no behaviour is lost, but two `[x]` claims do not match the implementation they describe, which is the failure mode this project keeps hitting.

## low — Task 6.2 marked `[x]` while the Completion Notes hand the walkthrough to the author

- Violates: Task 6.2
- Evidence: Task 6.2 requires the guide plus "chạy lại từng bước trên game trước khi ghi". The Completion Notes contain the guide but also say "GoPeak `capture_screenshot` vẫn lỗi lưu file… **tác giả kiểm tay**" — i.e. steps 3–7 have not been run by the implementer; the only evidence recorded is `tools/test.sh: 569/569`. Task 6.1 is correctly left `[ ]` (honest, per "không có ảnh thì không đánh `[x]`"), and Task 6.3 is correct (`b874ecd … (Story 2.10)`, Vietnamese body, story + code split across two commits, unrelated `img/` + `.agents/` left out).
- Why: the `[x]` on 6.2 asserts a manual pass that the same document says has not happened, so no one has actually seen the panel or the highlighted red cells (AC 6, AC 7, H1).

## Open questions declared at lines 101-105 — all three defaults honoured

| Question | Declared default | Implemented |
|---|---|---|
| Unit with no reported attack: "không có đòn" or omit the line? | write "không có đòn" | `tooltip.no_attack` is always the third line (`battle_view.gd:207,211`) — honoured |
| Panel follows cursor or fixed corner? | follow cursor, flip at edges | `CURSOR_OFFSET` + flip + clamp (`tooltip.gd:84-93`) — honoured |
| Highlight: lighter fill or white border? | thicker white border + slightly lighter fill, keep red | `HIGHLIGHT_FILL_COLOR` + 5 px white border (`telegraph_view.gd:33-35,182-185`) — honoured |

Also verified against the code (no finding): no `src/core/` change; all visible text via `tr()` with new keys in `text.csv` and the compiled `.translation` regenerated; panel reads `_controller.snapshot()` per hover and keeps no live state; `_on_cell_hovered` was only extended, no second mouse path (the extra `_update_info` calls sit in `_on_events_resolved`/`stop`, not input); `highlight` survives `show_state` (state kept in `_highlight`, recomputed after each command); no hard-coded board size; no new test for anything eyes-only.
