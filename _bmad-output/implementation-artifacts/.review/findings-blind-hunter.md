# Blind Hunter findings

## medium — Six of the seven terrain-name keys are missing from the CSV that this table depends on
- Where: `game/i18n/text.csv:100` (with `game/src/ui/tooltip.gd:16-24` and `game/src/battle/battle_view.gd:158`)
- Evidence: the CSV hunk adds only `terrain.plain,Đồng bằng` next to seven effect rows (`terrain.effect.plain|river|forest|spikes|granary|village|pass`), while `TERRAIN_NAMES` has seven entries (`Terrain.RIVER: "terrain.river"`, `Terrain.FOREST: "terrain.forest"`, `Terrain.SPIKES`, `Terrain.GRANARY`, `Terrain.VILLAGE`, `Terrain.PASS`).
- Why it fails: `tr("terrain.river")` with no matching row returns the key itself, so hovering a river/forest/spikes/granary/village/pass cell renders `terrain.river` / `terrain.forest` … in the panel (and the new test's `.contains("Sông")` assertion fails). Either those six rows already exist earlier in `text.csv` (then this is a no-op) or six of seven terrains are broken on screen — the asymmetry between "all 7 effect keys added" and "1 name key added" needs one look at the file to settle.
- Fix: add `terrain.river|forest|spikes|granary|village|pass` rows alongside `terrain.plain` (or confirm they already exist).

## medium — Tooltip text and highlighted cells come from two different filters, so they can contradict each other
- Where: `game/src/battle/battle_view.gd:200-210` vs `game/src/battle/battle_view.gd:162-169`
- Evidence: `_attack_text` returns on the first matching telegraph (`for t: Telegraph in state.telegraphs: if t.owner_id != unit.id: continue ... return tr("tooltip.attack_cell") ...`) and it gates on `if hit == Telegraph.NO_CELL: return tr("tooltip.no_attack")`, while `_telegraph_cells_of` loops all telegraphs (`if t.owner_id == unit.id: cells.append_array(TelegraphMarks.path_cells(state, t))`) with no `hit_cell`/`NO_CELL` gate.
- Why it fails: (a) if a unit owns two telegraphs, the panel quotes only one cell/order — whichever happens to come first in `state.telegraphs` — while both sets light up, so the number in the text need not match the lit cells; (b) when `TelegraphMarks.hit_cell` returns `Telegraph.NO_CELL`, the panel says "Không có đòn nào" while `path_cells` still fills the highlight and the board shows the unit's red cells lit in white-bordered red. The two halves of one feature disagree on the same hover.
- Fix: collect the owner's telegraphs once, use the same list for both the text and the highlight, and share the `NO_CELL` gate.

## low — `MAX_WIDTH` is declared and never used, so autowrap never wraps and the panel cannot be kept on screen
- Where: `game/src/ui/tooltip.gd:46` (and `:63`, `:84-93`)
- Evidence: `const MAX_WIDTH: float = 340.0` appears nowhere else in the new file; `_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART` is set, but nothing ever constrains the label's width (`custom_minimum_size`, `size.x`, or a `fit_content` cap).
- Why it fails: a `Label` with autowrap but no width limit is never forced to wrap, so the panel grows to the longest line. Once `size.x + 2 * SCREEN_MARGIN > screen.x`, `pos.x = clampf(pos.x, SCREEN_MARGIN, maxf(SCREEN_MARGIN, screen.x - size.x - SCREEN_MARGIN))` degenerates: the upper bound is `maxf(8, negative) == 8`, so the panel is pinned to x=8 and still overflows the right edge. A long unit/effect line puts the panel across the board instead of beside the cursor.
- Fix: apply `custom_minimum_size.x`/explicit width capped at `MAX_WIDTH` before `reset_size()`, or set `_label.size.x`/`custom_minimum_size.x = MAX_WIDTH`.

## low — Unguarded `Dictionary[...]` lookups on enum-derived values: one unlisted value is a runtime error and a blank panel
- Where: `game/src/battle/battle_view.gd:194`, `:205`, `:214-215` (tables at `game/src/ui/tooltip.gd:8-14`, `:16-24`, `:35-40`)
- Evidence: `tr(Tooltip.UNIT_NAMES[unit.type] as String)`, `tr(Tooltip.DIRECTION_NAMES[t.offset] as String)`, `tr(Tooltip.TERRAIN_NAMES[terrain] as String)`.
- Why it fails: `Dictionary` indexing with a missing key is not a null return in GDScript — it raises `Invalid access to property or key … on a base object of type 'Dictionary'`, so adding an eighth `Terrain`, a seventh `UnitType`, or a direction telegraph with a non-cardinal/zero `offset` makes every hover on that cell error out and the panel come up empty (`as String` of the failed access). These tables are the only place the enum is enumerated, so nothing catches the omission at parse time.
- Fix: use `Tooltip.UNIT_NAMES.get(unit.type, "…")`-style lookups with a fallback string so an unknown value degrades instead of erroring.

## low — Inconsistent null/lifecycle contract: `stop()` guards what `_update_info` dereferences, and only `stop()` clears the panel
- Where: `game/src/battle/battle_view.gd:51-54` vs `:184`, `:189`, `:169`
- Evidence: `stop()` writes `if _board != null: _board.telegraph_view().highlight([] as Array[Vector2i])`, but `_update_info` calls `_board.telegraph_view().highlight(...)` unguarded, `_on_cell_hovered` calls `_board.show_path([])` unguarded, and no null check is made on the `telegraph_view()` result anywhere.
- Why it fails: either `_board`/`telegraph_view()` can be null (then `_on_cell_hovered`/`_update_info` null-deref during teardown, i.e. exactly when `stop()` runs) or they cannot (then the guard is dead code that misleads the next caller). Separately, tooltip/highlight reset lives only in `stop()`; `start()` neither hides the panel nor clears `_highlight`, so any restart path that goes through `start()` without `stop()` shows the previous battle's HP/attack text and red highlight until the first hover.
- Fix: pick one contract — assert non-null in the update paths and drop the guard, or guard all three sites — and clear the tooltip/highlight at the top of `start()` as well.

## low — The result screen keeps the tooltip and highlight live instead of clearing them
- Where: `game/src/battle/battle_view.gd:152`
- Evidence: in the `if Rules.is_battle_over(snapshot):` branch the code calls `_update_info(_input.hovered_cell() if _input != null else BoardView.NO_CELL)` and returns, while `stop()` is the only place that calls `_tooltip.hide_tooltip()` / `highlight([])`.
- Why it fails: after the last unit dies, `_hud.visible = false` removes the HUD but hovering the board still pops a full info panel and re-lights the hovered unit's red cells next to the result banner; the panel is drawn before `_result_banner` in `main.gd`, so it sits under the banner and can peek out around it. End-of-battle is the one moment the author's own cleanup (`stop()`) says the overlay should be gone.
- Fix: hide the tooltip and clear the highlight in the battle-over branch instead of refreshing them.

## Verified-clean areas
- Click pass-through (AC 5): `mouse_filter = Control.MOUSE_FILTER_IGNORE` is set on both the `PanelContainer` and its `Label` in `_init`, so the panel cannot swallow the board click; the added test also presses a general key and clicks through the shown panel.
- Highlight/redraw mechanics: `highlight()` copies the caller's array (`cells.duplicate()`), short-circuits on an unchanged list, and redraws both layers (`queue_redraw()` + `numbers.queue_redraw()`), so the highlight cannot desync the order-number overlay; `_draw_red` re-derives everything from `_highlight` on each draw, so a plain redraw after undo/restart/F5 reproduces it.
- Hiding path: `hide_tooltip()` sets both `visible = false` and `_label.text = ""`, and `_update_info`'s out-of-bounds branch hides before returning — so `visible_now()` cannot report a hidden-but-stale panel, and the `(-1,-1)` hover in the test genuinely clears it.
- Format-string arity: `tooltip.hp` (`%d/%d`), `tooltip.attack_cell` (`%s`,`%d`), `tooltip.attack_charge` (`%s`,`%d`) each match their argument arrays in `_unit_text`/`_attack_text`, so the `%` operator cannot raise an argument-count error on these paths.
