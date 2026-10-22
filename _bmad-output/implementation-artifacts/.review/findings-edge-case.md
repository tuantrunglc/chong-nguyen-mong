# Edge Case Hunter findings

Scope: `git diff 7790797..HEAD -- game/` (Story 2.10 — hover info box + red-cell highlight). Files: `game/src/ui/tooltip.gd` (new), `game/src/battle/battle_view.gd`, `game/src/battle/telegraph_view.gd`, `game/src/app/main.gd`, `game/i18n/text.csv`, `game/tests/test_battle_view.gd`.
Read-only review: nothing was run, no project file was changed.

## high — Info box has no width: panel collapses to the label's minimum width, so a 3-line tooltip cannot render as three readable lines
- Where: `game/src/ui/tooltip.gd:61-64` (label with autowrap, no width), `game/src/ui/tooltip.gd:68-75` (`show_text` only calls `reset_size()`), `game/src/ui/tooltip.gd:46` (`MAX_WIDTH` declared and never used), `game/src/app/main.gd:56-57` (parent is a `Node2D`, so no Container ever gives it a width)
- Scenario: load any battle, hover Nguyễn Khoái (text = "Nguyễn Khoái\nMáu 3/3\nKhông có đòn nào"). The panel is a `PanelContainer` whose only child is an autowrap `Label`; nothing sets the panel's or the label's width before `reset_size()` measures it.
- Evidence:
  ```gdscript
  _label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # tooltip.gd:63
  _label = Label.new()                                    # no custom_minimum_size anywhere
  ...
  visible = true
  reset_size()                                            # tooltip.gd:73-74  -> set_size(get_combined_minimum_size())
  ```
  Godot 4 `Label::get_minimum_size()` (verified in `scene/gui/label.cpp`, 4.5): when `autowrap_mode != AUTOWRAP_OFF` and `clip_text` is false (the default) it returns
  `Size2(1, min_size.height) + min_style` — i.e. **minimum width is 1 px**, not the text width. `PanelContainer::get_minimum_size()` is max(child minimum) + panel stylebox margins, and `StyleBoxFlat` here has `set_content_margin_all(8)` + `set_border_width_all(2)` (`tooltip.gd:54-60`), so the panel measures ≈ 1 + 16 + border ≈ 17-21 px wide.
- Why it fails: `reset_size()` sets the panel to that minimum, and because the parent is a `Node2D` nothing ever grows it. Observed: a ~20 px wide strip, with the label laid out in a ~1 px content rect, so `AUTOWRAP_WORD_SMART` (which includes `BREAK_ADAPTIVE`) breaks the text into one word/character per line and, since `clip_text` is false, draws past the panel background. Expected (AC 1, AC 6): a small box of two or three lines next to the cursor, inside 1280×720. The clamp in `place_at` uses this wrong `size` too, so it cannot correct anything. No test can see it: all three tests read `Tooltip.text()` only, and task 6.1 (screenshot) is the one task left unchecked. `MAX_WIDTH = 340` shows the intended width limit was lost when the dev removed the explicit sizing (see the Debug Log "sinh lỗi engine" note).
- Fix: give the box a real width before measuring — e.g. `_label.custom_minimum_size.x = minf(longest_line_width, MAX_WIDTH)` (measure with `font.get_string_size`) or simply `custom_minimum_size = Vector2(MAX_WIDTH, 0)` on the panel — then `reset_size()` produces a 200-340 px box that actually wraps; confirm with the missing screenshot (task 6.1).

## medium — Terrain effects in the tooltip teach rules this build does not have (spikes, granary, village, pass)
- Where: `game/i18n/text.csv:104-107` (`terrain.effect.spikes/granary/village/pass`), `game/src/ui/tooltip.gd:25-33` (`TERRAIN_EFFECTS`)
- Scenario: start `tools/chay.sh --tran=thu_co_lon` (its map has `^ L D A`; every `thu_*` level except `thu_day`, `thu_keo`, `thu_lao`, `thu_thang`, `tran_01` does). Hover the spike cell → "Đi qua mất máu"; walk a general onto it → no HP lost. Hover the village → "Đánh vào làng thì mất Lòng dân"; attack it → nothing. Hover the granary → "Quân Nguyên đứng kề thì hồi máu"; stand an enemy next to it for a round → no heal. Hover the pass → "Quân Nguyên vào ải thì thua"; walk an enemy onto it → no defeat.
- Evidence: `Terrain.SPIKES/GRANARY/VILLAGE/PASS` are only referenced as walkability (`game/src/core/terrain.gd:8`), draw colours/labels (`game/src/battle/board_view.gd:36-53`), charge blockers (`game/src/core/enemy_ai.gd:12`) and push obstacles (`game/src/core/forced_move.gd:10`). There is no spike-damage code, no HP-gain code at all (`grep "hp ="` finds only construction), no "Lòng dân" anywhere (`game/src/core/rules_victory.gd:5` says it is Story 3.7; `game/src/data/level_loader.gd:15` says `long_dan` is not read yet), and no `HOLD_PASS` branch in `rules_victory.gd` (Story 3.11).
- Why it fails: the tooltip's purpose (FR40) is to save the player from memorising rules, and for 4 of the 7 terrain kinds it states rules the game does not enforce. Observed vs expected: "Đi qua mất máu" vs no damage, "mất Lòng dân" vs no such stat, "hồi máu" vs no heal, "thì thua" vs no loss.
- Fix: reword those four effects as not-yet-active (or omit them) until 3.4/3.7/3.9/3.11 land — author's call, since the wording is spec content.

## medium — Kỵ binh hover promises a charge the board has already dropped (DIRECTION branch skips the "does it still hit" check)
- Where: `game/src/battle/battle_view.gd:200-210` (`_attack_text`; the `DIRECTION` early return at 204-205 comes **before** the `hit_cell == NO_CELL` check at 206-208 that the CELL branch uses)
- Scenario: enemy phase — a Kỵ binh stands at (1,4) and telegraphs a west charge (order 2) at Khoái on (0,4); the board shows a red cell at (0,4) with "2". Player turn — move Khoái off (0,4), then hit the Kỵ binh with Lão from (2,4) so the push sends it west into the now-empty (0,4). `Telegraph.target_cell()` is now (0,4)+(-1,0) = (-1,4), out of bounds, so `TelegraphMarks.path_cells` is empty: the red cell and the "2" vanish from the board. Hover the Kỵ binh.
- Evidence:
  ```gdscript
  if t.kind == Telegraph.Kind.DIRECTION:
      return tr("tooltip.attack_charge") % [tr(Tooltip.DIRECTION_NAMES[t.offset] as String), t.order]
  var hit: Vector2i = TelegraphMarks.hit_cell(state, t)
  if hit == Telegraph.NO_CELL:
      return tr("tooltip.no_attack")
  ```
  `hit_cell` → `path_cells` returns `[]` when `target_cell` is out of bounds (`telegraph_marks.gd:44-52`); at end of turn `RulesEnemyPhase._strike_all` cancels exactly this case (`hit == NO_CELL` → `TELEGRAPH_CANCELLED`, `rules_enemy_phase.gd:29-36`).
- Why it fails: the tooltip still says "Xung phong hướng Tây, đòn số 2" while no red cell and no order-2 label exist anywhere on the board and the rules will cancel the charge. The CELL branch returns "Không có đòn nào" for the same situation, so the two kinds disagree. Hovering a unit is the only place a player could learn the charge is dead — and it says the opposite.
- Fix: check `TelegraphMarks.cancel_reason(state, t) != TelegraphCancel.NONE` (or `hit_cell == NO_CELL`) **before** branching on `kind`, and answer "Không có đòn nào" for both.

## medium — The AC-5 test cannot fail: it never goes through GUI hit-testing, which is the only thing that could block a click
- Where: `game/tests/test_battle_view.gd:664-672` (test), helper `game/tests/test_battle_view.gd:244-249` (`_click_by_mouse`), `game/src/ui/tooltip.gd:52,62` (`mouse_filter`)
- Scenario: set `mouse_filter = MOUSE_FILTER_STOP` on the panel (the regression the test exists for), run the suite — `test_tooltip_does_not_block_click` still passes.
- Evidence:
  ```gdscript
  _battle_input(main)._unhandled_input(click)          # tests/test_battle_view.gd:249
  ```
  The event is handed straight to `BattleInput`, bypassing `Viewport::_gui_input_event` where a non-IGNORE Control would consume it (and where `_unhandled_input` would never be reached). In addition, `show_text` anchors the panel with `get_viewport().get_mouse_position()` (`tooltip.gd:75`), the real OS cursor (0,0 headless), not the injected event position, so the panel can never even be placed under the injected click.
- Why it fails: the test name claims AC 5 ("bấm xuyên qua khung"), but it only proves "BattleView still handles a click while the tooltip has text". The actual risk — a `Control` over a `Node2D` board with `_unhandled_input` — has no regression guard at all.
- Fix: either push the event through `get_viewport().push_input(event)` so GUI picking runs, or assert `mouse_filter == Control.MOUSE_FILTER_IGNORE` on both panel and label plus "`place_at` never puts the panel under the anchor" — the current code is correct here, but nothing will notice when it stops being.

## low — Task 3.3's "hide when the battle ends" is not implemented, and `start()` does not reset the box, so a restart re-opens with the previous hover
- Where: `game/src/battle/battle_view.gd:149-153` (battle-over branch **shows** the box), `game/src/battle/battle_view.gd:40-44` (`start()` only calls `_deselect()`)
- Scenario: rest the mouse on a Bộ binh, win the battle → the result banner appears while the tooltip stays visible for the hovered cell (and any further hover keeps re-showing it). Or: hover a cell, press "Chơi lại trận" → `_start_battle()` never calls `Tooltip.hide_tooltip()`; `_controller.begin()` → `_on_events_resolved` → `_update_info(_input.hovered_cell())` shows the box (and sets the highlight) for the cell that was last hovered in the **previous** battle, with no new hover in the new one.
- Evidence:
  ```gdscript
  if Rules.is_battle_over(snapshot):
      _deselect()
      _update_hud()
      _update_info(_input.hovered_cell() if _input != null else BoardView.NO_CELL)   # shows, never hides
      return
  ```
  Story 2.10 Task 3.3 (checked `[x]`): "Ẩn khung khi: chuột ra ngoài bàn, **trận kết thúc**, hoặc `stop()`. Không để khung của trận cũ dính sang trận mới." Only the first and third are implemented; `stop()` does the hiding, `start()` does not.
- Why it fails: observed = box keeps following the mouse over a finished board and reappears by itself in a fresh battle; expected per Task 3.3 = hidden at game end and at the start of a new battle. (The Dev Notes offer the softer "hide **or** show only unit/terrain", which the current content satisfies, so this is a spec-vs-implementation conflict that must be decided — the `[x]` on Task 3.3 is wrong either way.)
- Fix: in the battle-over branch and in `start()`, call `_tooltip.hide_tooltip()` and `_board.telegraph_view().highlight([] as Array[Vector2i])` (or have `start()` call the same reset as `stop()`), then keep or drop the battle-over `_update_info` per the author's decision.

## low — After a command the box/highlight can describe the cell the cursor is *not* over (`_on_events_resolved` skips `refresh_hover`)
- Where: `game/src/battle/battle_view.gd:163` (reads `_input.hovered_cell()`), compare `game/src/battle/battle_view.gd:236-237` (`_select` deliberately calls `_input.refresh_hover()` first), `game/src/battle/battle_input.gd:42-43,93-95`, `game/src/battle/board_view.gd:155-172` (`pick_cell` prefers a token/block over the ground cell)
- Scenario: the cursor sits at the top edge of the cell in front of a unit — the unit's coin is 48 px tall on a 64 px cell and `TOKEN_LIFT = 20`/`RADIUS = 24` make it stick ~12 px into the cell behind it (`unit_token.gd:9-12`), so `pick_cell` reports the unit's cell. Press Space (end turn); the unit walks away. `hovered_cell()` still reports the unit's old cell, so the tooltip keeps that cell's text and the highlight keeps that owner's red cells, although the cursor now points at a different cell — until the next `InputEventMouseMotion`.
- Evidence: `_select()` has the exact guard the new code lacks:
  ```gdscript
  # Đồng quân vừa dời có thể che ô đang trỏ: chọn lại ô dưới chuột trước.
  _input.refresh_hover()
  _on_cell_hovered(_input.hovered_cell())
  ```
  `_on_events_resolved` calls `_update_info(_input.hovered_cell())` without it, and `cell_hovered` only fires when the cell value changes, so nothing repairs it.
- Why it fails: observed = info and white-border highlight for a cell the pointer is not on (stale until any mouse move); expected = the cell under the pointer, as the hover path normally guarantees.
- Fix: `_input.refresh_hover()` before reading `hovered_cell()` in `_on_events_resolved` (it is a no-op when the last motion is null).

## low — AC 4's "rê sang ô trống thì khung ẩn" is implemented as "outside the board only"; a plain cell shows a box
- Where: `game/src/battle/battle_view.gd:181-189`, `game/src/battle/battle_view.gd:213-215`, test `game/tests/test_battle_view.gd:648-649`
- Scenario: hover any empty grass cell. The box shows "Đồng bằng / Không có hiệu ứng" (`Terrain.PLAIN` is in `TERRAIN_NAMES`/`TERRAIN_EFFECTS`, `text.csv:100-101`).
- Evidence: AC 4 says "Khi chuột rời khỏi bàn **hoặc rê sang ô trống** Thì khung thông tin ẩn đi", while AC 3 and Task 3.1 say an empty **in-board** cell shows terrain name + effect. The code follows AC 3/Task 3.1 (`if not state.in_bounds(cell): hide`), and the new test only asserts the river cell and `(-1,-1)`.
- Why it fails: the two acceptance criteria contradict each other; if "ô trống" was meant literally, the code does the opposite and no test would catch it.
- Fix: confirm with the author which reading wins (current behaviour is the documented Task 3.1 one); if AC 4 wins, hide for `Terrain.PLAIN`.

## low — Missing dictionary key aborts the hover handler and leaves the previous text on screen
- Where: `game/src/battle/battle_view.gd:194`, `:205`, `:214-215`
- Scenario: add one `Terrain` or `UnitType` member (M3 reinforcements / more terrain) without adding it to `Tooltip.*_NAMES`; hover it.
- Evidence: `tr(Tooltip.UNIT_NAMES[unit.type] as String)` — a `Dictionary` read with a missing key returns `null`, `null as String` stays `null`, and `tr(null)` raises a runtime error; `_update_info` then aborts *before* `_board.telegraph_view().highlight(...)`. Today the coverage is complete (6/6 unit types, 7/7 terrains, 4/4 directions), so this is not live — the failure mode is just unfriendly and silent (the box keeps the old cell's text, the highlight freezes).
- Why it fails: a data/enum addition turns a display path into a script error instead of a fallback.
- Fix: use `Dictionary.get(key, "")` plus `assert` (or a `Tooltip.text_for_unit(type)` helper with a default), so a missing entry shows nothing rather than erroring.

## low — New `unit.full.*` translations duplicate the existing `scenario.unit.*` full names
- Where: `game/i18n/text.csv:108-113` vs `game/i18n/text.csv:25-30` (`scenario.unit.*`), used at `game/src/ui/tooltip.gd:8-15`
- Scenario: a unit is renamed (or one table is edited). The tooltip and the scenario viewer (`game/src/tools/scenario_viewer.gd` uses `scenario.unit.*`) silently disagree.
- Evidence: the same six Vietnamese names already exist as `scenario.unit.nguyen_khoai … cung_ky`; the diff adds a parallel `unit.full.*` block instead of reusing them. Task 1.1 had also sketched different key names (`tooltip.unit.*`, `tooltip.terrain`, `tooltip.effect.*`), so there are now three naming schemes for the same concepts (`unit.*` short, `scenario.unit.*`, `unit.full.*`).
- Why it fails: two sources of truth for one string; nothing links them.
- Fix: reuse `scenario.unit.*` from `Tooltip.UNIT_NAMES` (or rename that block to `unit.full.*` and update the viewer), and drop the duplicate rows.

## Covered edge cases (sound)

- **Hover outside the board / window exit**: `state.in_bounds(cell)` is false for `BoardView.NO_CELL` and any out-of-board pick, and `BattleInput._on_mouse_exited` emits `cell_hovered(NO_CELL)` (`battle_input.gd:57-60`), so the box hides and the highlight is cleared; no empty frame can appear because both text builders always return text (`show_text("")` is only reachable from nothing).
- **Hover an in-board empty cell**: terrain name + effect from the snapshot, highlight set to `[]`.
- **Hover a friendly general with no telegraph**: `_telegraph_cells_of` returns `[]` and the text is "Không có đòn nào" (the author's chosen default).
- **Hover an enemy whose telegraph was cancelled/removed** (e.g. owner drowned): `TelegraphMarks.cells` and `_telegraph_cells_of` are recomputed from the fresh snapshot, so no red cell, no order label and no highlight survive; for a CELL telegraph the text also degrades to "Không có đòn nào".
- **Two enemies aiming at the same cell**: each owner's hover highlights only its own `path_cells` (verified with the fixture where (3,4) is covered by orders 1 and 2); the other's red cell keeps its normal look, as AC 2 asks.
- **Two enemies on one cell**: unreachable — `BattleState.validate()` reports "đứng chung ô" and the controller rolls the command back; `unit_at` returns the first anyway.
- **Board edge**: `top_rect` + `face.grow(-HIGHLIGHT_BORDER_WIDTH / 2)` keeps the 5 px ring inside the cell face; nothing is clipped and no index is taken from a neighbour cell.
- **Cursor still while a command resolves**: `events_resolved` → `_update_info` recomputes from the new snapshot, so a cell whose occupant died/moved switches to terrain text and its old owner's red cells stop being highlighted.
- **`_controller == null`** (menu/error after `stop()`): `_update_info` returns before touching the state, and `stop()` has already hidden the box and cleared the highlight (`battle_view.gd:48-55`); hovering the empty board does nothing.
- **`stop()` then a new battle** (error → menu → reload): `stop()` hides/clears, and a subsequent `_update_info(NO_CELL)` keeps it hidden; only the retry path leaks (finding above).
- **Keyboard-only play**: hover state is never created (`_hovered` stays `NO_CELL`), so the box stays hidden; keys 1/2/3 go through `_select` → `_on_cell_hovered(hovered)` and Space/Z through `events_resolved`, both of which refresh the box instead of leaving it stale.
- **Z-order, box vs board**: both are CanvasItems in the root viewport's default canvas and draw in tree order; `_board_view` is child 1 and `_tooltip` child 4 of `Main` (`main.gd:49-63`), so the box is painted after the board and after **all** of its descendants (`_telegraph`, terrain labels, `_world` tokens, `_target_layer`, the `numbers` labels, the F1 `CoordOverlay`), and after the HUD (child 3). Only `_result_banner` (child 5) and the dev F3 `AiIntentOverlay` (added later) paint above it — which is why the battle-over box would sit behind the result banner (see the low finding).
- **Z-order, white highlight vs unit tokens**: the highlight is drawn inside `TelegraphView`, BoardView's **first** child (`board_view.gd:252-262`), so it is under `_world` tokens and under the white target border layer. It is still visible because a token is a 48 px coin (`RADIUS = 24`) inside a 64 px cell and the ring spans 0-5 px inside the cell edge (27-32 px from the centre), never reaching the coin; on block cells (forest/granary/village) the red fill — and therefore the highlight — is drawn on the `numbers` layer above the block, while the number labels are children of that layer and still draw on top, so AC 7 and "giữ nguyên số thứ tự" hold.
- **`Array[Vector2i]` equality in `highlight()`**: `cells == _highlight` compares contents element-wise, which is what the no-op fast path wants; `_highlight = cells.duplicate()` copies, so the caller's freshly built array cannot alias the view's state, and `[] as Array[Vector2i]` compares equal to an empty `_highlight`. `_telegraph_cells_of` always returns a fresh array, so no aliasing there either.
- **`%` formats vs the CSV literals**: `tooltip.hp` "Máu %d/%d" gets exactly two ints (hp, `stats.max_hp`), `tooltip.attack_cell` "Đánh ô %s, đòn số %d" gets cell text then order, `tooltip.attack_charge` "Xung phong hướng %s, đòn số %d" gets direction name then order — counts and order match for all three; the three comma-bearing rows are quoted, so the comma cannot truncate the format (the dev log records the unquoted version and the fix).
- **Direction names**: `Tooltip.DIRECTION_NAMES` keys are exactly `Grid.DIRECTIONS` (B/D/N/T = (0,-1)/(1,0)/(0,1)/(-1,0)); enemy telegraph offsets come from `Grid.straight_dir` and `BattleState.validate` rejects anything else, so the lookup cannot miss for AI or scenario-supplied telegraphs.
- **Enum coverage of the name tables**: 6/6 `UnitType`, 7/7 `Terrain` — no live missing-key path (only the future-addition risk above).
- **Highlight survives a board rebuild**: `TelegraphView.show_state` rebuilds `_cells` but keeps `_highlight`, and `_on_events_resolved` re-derives it after every command (main's `_show_board` handler is connected before `BattleView.start`, so the new `_cells` exist before the highlight is computed) — the highlight cannot point at a cell that is no longer red for the hovered owner.
- **Accessor convention**: `highlighted()` returns the internal array, matching the pre-existing `red_cells()`/`arrows()` style; no caller mutates it.
- **Compile-level details**: the new code is fully typed (the project treats `untyped_declaration` as an error) — `var state: BattleState`, `for t: Telegraph in …`, `var cells: Array[Vector2i]`, no `as` misuse on non-null values; `Tooltip` builds its label in `_init` and sets `mouse_filter` on both panel and label, so it cannot eat clicks while the panel is IGNORE.

## Test coverage notes (the three new tests)

- `test_tooltip_shows_unit_and_terrain` (`test_battle_view.gd:625`) does check the four texts and the outside-board hide, but it never asserts `visible_now()` for the three *shown* cases — a regression that sets the text but never shows the panel would still pass (the final assertion is `assert_false(visible_now())`). It also asserts an AI-produced telegraph ("Đánh ô 2,1, đòn số 1"), so it fails for enemy-AI changes unrelated to hover info.
- `test_hover_enemy_highlights_only_its_own_red_cells` (`:652`) covers two CELL telegraph owners and a friendly general; it does **not** cover the DIRECTION/Kỵ binh branch, a multi-cell charge path, the highlight surviving a command (`show_state` + `events_resolved`), or `stop()` clearing it.
- `test_tooltip_does_not_block_click` (`:664`) is vacuous for AC 5, as described above.
- Behaviour with **no test at all**: the Kỵ binh path (`attack_charge` text + `DIRECTION_NAMES` + multi-cell highlight), the box after battle end / after "Chơi lại trận" (Task 3.3), hovering a plain cell, hovering an enemy whose telegraph was just cancelled, and — because every assertion reads `text()` — the panel's actual size, visibility and on-screen position (AC 6, where the high finding lives).
