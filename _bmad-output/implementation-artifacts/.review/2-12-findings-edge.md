# Edge Case Hunter findings (Story 2.12)

## HIGH — Preview cache survives a change of selected general, so the ghost shows the previous general's outcome
- Where: game/src/battle/battle_view.gd:279-280 (cache guard), with game/src/battle/battle_view.gd:393-402 (`_select`) and 133-144 (`_on_general_key`)
- Scenario: level `quan` = `row2 "2 . . B . . ."` (Lão id 2 at 0,2; Bộ binh at 3,2), `row3 ". . . 1 . . ."` (Khoái id 1 at 3,3). Press `1`, park the mouse on (3,2) — ghost appears at (4,2), HP 1 (2 damage + push east). Without moving the mouse press `2`. (3,2) is also a legal target for Lão, and `_preview_cell` still holds (3,2), so `_update_preview` returns at line 280. The ghost still shows the enemy at (4,2) with HP 1, but Lão's attack does 1 damage and no push — the correct ghost is (3,2) with HP 2. Clicking the other general's token reaches the same state (`_on_cell_clicked` → `_select`).
- Evidence: `if cell == _preview_cell: return` (279-280). `_select()` (393-402) neither clears `_preview_cell` nor calls `_clear_preview()`, and it calls `_on_cell_hovered(_input.hovered_cell())` at 402, which takes that early return. `_clear_preview()` (291-294) is only reached from `_deselect`, `_hide_info`, `start` and `_finish_playback`.
- Why it fails: observed = the previous general's ghost (wrong cell, wrong HP, wrong push), while the white target border was just recomputed for the new general — the board contradicts itself. Expected = the ghost of the attack the *currently selected* general would make (AC 1). Reachable any time two generals' target sets overlap, e.g. an enemy adjacent to Khoái that also stands 2–4 cells down Lão's or Dư's line; on Trận 1 this happens as soon as Khoái walks next to Lão's column (Khoái at 1,4 with an enemy at 2,4 is a target for both).
- Fix: reset `_preview_cell = BoardView.NO_CELL` at the top of `_select()` (or key the cache by `(_selected, cell)`).

## MEDIUM — Ghost is not cleared when playback starts, so it hangs over the pre-attack board for the whole animation
- Where: game/src/battle/battle_view.gd:206-223 (`_on_events_resolved`), 261-262 (`_on_cell_hovered`), game/src/battle/board_view.gd:278
- Scenario: hover an enemy to get a ghost, then click it with the real player (`EventPlayer.instant == false`). `_on_events_resolved` sets `_playing = true` and awaits `_player.play(...)`, but never touches the preview. `EventPlayer` deliberately does not call `show_state` mid-play; the board is redrawn only by `_on_playback_finished` → `_show_board` → `BoardView.show_state` → `_preview.clear()`, i.e. after the animation.
- Evidence: `_on_events_resolved` (206-223): `_playing = true`, `_hud.set_locked(true)`, `_hud.show_phase(...)`, `_player.play(...)` — no `_clear_preview()`. `_on_cell_hovered` (261-262) returns *before* `_update_preview`, so even a mouse move during playback cannot clear it. Ghost labels stay in `PreviewView` until `show_state`.
- Why it fails: observed = for the whole attack animation (~0.7–1 s: `EventPlayer.SECONDS_PER_EVENT = 0.18` × 4–5 events) the old board shows a ghost disc at the destination cell with the post-hit HP while the real token still stands on the source cell — two positions and two HP readings for the same unit, pre-echoing the move. Expected (Task 3.3): "bóng tắt khi … bắt đầu phát hoạt ảnh". The enemy phase escapes only by accident: `_on_end_turn` calls `_deselect()` at 202 immediately after `submit()` returns, in the same frame.
- Fix: call `_clear_preview()` at the top of `_on_events_resolved`, before starting the player.

## MEDIUM — A ghost on a cell that still holds a unit overprints that unit's name and HP digit
- Where: game/src/battle/preview_view.gd:44, 50-51, 65-66 (against game/src/battle/unit_token.gd:10, 27, 62-71, 65)
- Scenario: Lão always damages without moving (the target keeps its cell); Khoái's push blocked by wall/edge/another unit keeps the target's cell; a dying unit is ghosted on its own cell. Hover any of these.
- Evidence: ghost centre = `pos + (0, -UnitToken.TOKEN_LIFT)`, which is exactly `UnitToken.position + coin`; the name label is centred there and the HP label at `centre + UnitToken.HP_OFFSET` — the same centre as the token's `_hp_label` (`coin + HP_OFFSET`, font 12). Ghost alpha 0.5. Additionally the ghost name uses the default `Label` font while the token sets `theme_type_variation = &"TitleLabel"` (bold).
- Why it fails: observed = the post-hit digit drawn on top of the pre-hit digit (e.g. "3" and "1" superimposed ~1 px apart) plus the unit name drawn twice in two weights; unreadable. Expected = one legible "máu sau đòn", which is the feature's whole output for Lão (a target that never moves). The tests only compare dict values, so they cannot see this; the story's eye check (Task 5.2) is still unchecked.
- Fix: offset same-cell ghosts (e.g. half a cell) or draw only the HP number for them, and hide/dim the live token's labels under a ghost.

## LOW — A unit removed by drowning is ghosted at the cell it was pushed FROM
- Where: game/src/battle/battle_view.gd:308-310, with game/src/core/effects.gd:8-15 and 33-34
- Scenario: Khoái hits a 1 HP-less Bộ binh that has a river behind it. `Effects.move` sets `unit.cell` to the river cell and then `_remove()` erases it, so `after.unit_by_id` is null; `_ghosts_of`'s second loop iterates `before.units` and ghosts it on the pre-push cell with HP 0.
- Evidence: `for unit: Unit in before.units: if after.unit_by_id(unit.id) == null: ghosts.append(_ghost(unit.cell, unit, before, 0))`
- Why it fails: observed = "it dies where it stands, the push does nothing"; expected = "it is pushed one cell and drowns". The ghost is drawn on the cell the unit will leave, so the most interesting part of the play (killing without damage) is invisible. Task 3.4 specifies "ô trước đòn", so this is spec-literal, but it conflicts with AC 1's "vị trí cuối". No test covers this branch at all.
- Fix: have `preview()` also return the events, and ghost the drowning cell (the last cell the unit held) instead of / in addition to the origin cell.

## LOW — `_preview_cell` is set even when the preview is rejected, poisoning the cache
- Where: game/src/battle/battle_view.gd:281-287
- Scenario: `_preview_cell = cell` and `_preview_count += 1` happen *before* `_controller.preview()`; if it returns null (286-287) only the view is cleared, but the cell stays cached. A later valid preview for the same cell is then skipped until the cursor moves.
- Evidence: lines 281-287 (`_preview_cell = cell` / `_preview_count += 1` / ... / `if after == null: _board.preview_view().clear(); return`).
- Why it fails: observed = no ghost and no retry while the cursor stays on the cell; expected = the next hover on a now-valid target shows the ghost. Currently only reachable if `attack_targets()` and `Rules.resolve` disagree (or a future rule adds a rejection that `_targets` does not model), so it is a latent trap rather than a live bug — and no test covers the `after == null` branch.
- Fix: assign `_preview_cell` only after a non-null preview, and reset it to `NO_CELL` in the null branch.

## LOW — `preview()` skips the invariant check that `submit()` performs
- Where: game/src/battle/battle_controller.gd:42-49 versus 56-70
- Scenario: `submit()` runs `_state.validate()` after resolve and rolls back + emits `rolled_back` if it fails; `preview()` returns the resolved copy unvalidated. The test double `BrokenController` (game/tests/test_battle_controller.gd:9-21) is a real `_resolve` override that produces an invalid state (two units in one cell, hp/round mismatched).
- Evidence: `var events: Array[BattleEvent] = _resolve(copy, command)` … `if _rejection(events) != null: return null` … `return copy` — no `copy.validate()`.
- Why it fails: a preview is a promise. On any rule path that yields a state `validate()` rejects, the ghost promises an outcome `submit()` then silently refuses (rollback + ERROR log only, no notice) — the player sees a ghost for an attack that does nothing. Invisible to the suite: no preview test validates the returned state, and no test overrides `_resolve` while previewing.
- Fix: `if not copy.validate().is_empty(): return null` in `preview()`.

## LOW — Ghost is drawn above the flat red telegraph fill
- Where: game/src/battle/board_view.gd:253-266 (layer order), game/src/battle/telegraph_view.gd:183-190 (`_draw_red(self, cell)` for flat cells)
- Scenario: a friendly general standing on a red cell (enemies telegraph onto generals' cells) is also affected by the previewed attack — Lão spearing through it to reach the clicked enemy, or a push collision damaging it as the blocker. Hover the enemy: the ghost disc (r 24 in a 64 px cell, alpha 0.5) is drawn over that general's red cell.
- Evidence: `_telegraph` is added first (`add_child(_telegraph)`, 254), `_preview` after `_world` (261-262); flat-cell red is `_draw_red(self, cell)` inside `TelegraphView._draw`, i.e. below every later sibling. Block reds and all order numbers are on `_telegraph.numbers`, added last (267) → correctly above the ghost.
- Why it fails: AC 6 says the ghost must not cover "ô đỏ + số thứ tự đòn". The number labels and block reds are fine; flat reds are 50 % muted by the ghost while it is on them. No test looks at z-order, so nothing guards it.
- Fix: when a ghost cell is also a telegraph cell, draw the ghost as an outline only (no fill) so the red stays dominant.

## LOW — Dead `Node2D` child added to `BoardView._ready`
- Where: game/src/battle/board_view.gd:263
- Scenario: every `BoardView` instantiation (every `main.tscn` in tests, every battle start, every F5) adds an empty unnamed `Node2D` between `_preview` and `_target_layer`.
- Evidence: `add_child(Node2D.new())` — no reference kept, no draw, no signal; the comment right above lists only the layers that matter, and the file's header comment now omits it too.
- Why it fails: not a rendering bug, but it is unreachable state left in a file the story touched: it makes the documented child order false for anyone who later indexes `get_child(n)`, and it carries a per-instantiation allocation for nothing. This is the class of leftover a review should stop before it becomes load-bearing.
- Fix: delete the line.

## LOW — `_clear_labels` drops the project's `remove_child` + `queue_free` convention
- Where: game/src/battle/preview_view.gd:37-39 (compare game/src/battle/board_view.gd:330-336 and 386-390)
- Scenario: hover target A then target B within one frame (two mouse events), or call `show_ghosts` twice in one frame.
- Evidence: `for child: Node in get_children(): child.queue_free()` — labels stay children until the end of the frame, while both existing rebuild paths (`_rebuild_terrain`, `_remove_token`) do `remove_child(child)` before `queue_free()`.
- Why it fails: no visible artefact today (Godot flushes the delete queue before drawing), but for the rest of the frame `preview_view().get_child_count()` counts ghosts that are already gone; any future code/test that counts or lays out children sees stale labels, and repeated re-shows in one frame keep N dead labels alive until the flush. No test asserts label count at all, so a real accumulation regression would be invisible.
- Fix: `remove_child(child)` before `queue_free()`, and add a test asserting 2 labels per ghost after two hovers.

## LOW — Three state clones and a full rule pass per new hovered cell; two previews per playback finish
- Where: game/src/battle/battle_view.gd:281-284, 329 (`_update_info`'s `snapshot()`), 253-256
- Scenario: moving the mouse across adjacent targets; or any command, where `_finish_playback` computes the preview twice — once via `_select()` → `_on_cell_hovered()` (while `_preview_cell` still holds the old cell) and again after the reset at line 253.
- Evidence: `snapshot()` is `_state.clone()` and `preview()` clones a second time; `_update_info` clones a third time; `preview()` runs the whole `Rules.resolve` including `RulesVictory.check` and telegraph clearing.
- Why it fails: not a correctness bug at 7×7, but it is 3 full board clones + a full rule pass per hovered cell, and the cache reset *after* `_select` throws away the first of the two playback-end computations (AC 4 only forbids per-frame recomputation, which is respected). The double compute also means `preview_computations()` is 2 higher than a player would expect after a command, so a future count-based test will be off by one per playback.
- Fix: reset `_preview_cell` before `_select()` in `_finish_playback`, and pass the already-taken snapshot into `_update_info`/`_update_preview` instead of re-cloning.

## LOW — Test gaps: two of the six new tests cannot fail for the reason their name gives, and whole branches are unreached
- Where: game/tests/test_battle_controller.gd:355-362, 366-373, 376-378; game/tests/test_battle_view.gd:1141-1151, 1154-1166, 1169-1181
- Scenario / Evidence:
  - `test_preview_does_not_touch_live_state` asserts `assert_false(c.can_undo())` (361), but `_attack_controller()` (201) never creates an undo snapshot, so `can_undo()` is false before the preview too. The claim in its own name ("không tạo bản chụp hủy") cannot fail. To mean anything it must do `submit(move)` → `preview(attack)` → `assert_true(can_undo())`.
  - `test_preview_ghosts_show_on_attack_target` reads only `ghosts[0]`; it never asserts the count, so over-reporting (ghosting unaffected neighbours) passes. `ghosts[0]` is the first changed unit in `after.units`, i.e. the fixture's `thu_tu_dich` order (`"3,3"` first) — reordering that array silently changes which unit the assertions describe.
  - `test_preview_recomputes_only_when_target_changes` calls `_view(main)._on_cell_hovered(...)` directly, against the story's own rule (story file line 80: use `InputEventMouseMotion`, do not call private handlers), and it locks in the cache behaviour without ever testing invalidation after a selection change — the HIGH finding above is one keypress from this test.
  - No test enters `_ghosts_of`'s second loop (a unit erased from `after`): the only attack under test leaves the target at 1 HP, so the "máu 0" branch of AC 1 is dead code to the suite.
  - Nothing covers: Lão hitting a cell other than the clicked one (own general in the line) or Dư's pull (a ghost that only moves); a blocked push (two ghosts: pushee + collider, `forced_move.gd:27-36`); the `after == null` branch (285-287); the preview being cleared at playback start or refreshed at 253-256; `_preview_cell` reset by `start()` (F5 reload); a ghost surviving `stop()` / the error screen (Task 3.3); `PreviewView` in isolation (label count, `clear()` when already empty, `_draw`); and the ghost's `pos` / terrain lift — `pos` is never asserted, so a ghost floating above or below its token keeps the suite green.
- Why it fails: 583/583 green says nothing about the branch that shows HP 0, about label lifecycle, or about the cache across a change of general. The two most visible defects in this review (stale ghost, overprinted HP) sit exactly in those blind spots, and Task 5.2 (eye check) is still unchecked.
- Fix: add one can-fail test per bullet (duplicate target order + a death + label count + a key switch over a shared target cell).

## Covered cases (sound)

- `preview()` never mutates the live state, never emits `events_resolved`, never touches `_undo_snapshot`: `BattleState.clone()` deep-copies units and terrain (battle_state.gd:51-65), and `stats` is shared read-only. `BoardFixture.picture()` includes `has_moved`/`has_attacked`, so the controller tests compare flags too, not just HP/cell.
- Undo and the enemy phase both re-enter through `events_resolved` → `_on_events_resolved` → `_finish_playback`, which resets `_preview_cell` and recomputes at 253-256 — the ghost is refreshed after playback rather than left from before.
- Board reload / F5: main.gd shows the new state before `start()`, so `BoardView.show_state` clears (board_view.gd:278), `start()` resets `_preview_cell` (71) and `_deselect()` clears again. No ghost survives a reload.
- Error screen / menu / battle over: `stop()` (78-87) → `_deselect()` → `_clear_preview()` and `_hide_info()`; `_finish_playback`'s battle-over branch (236-240) deselects and hides before anything can redraw; `_show_error` additionally hides the board. A ghost cannot survive any of them.
- Pending-confirm (first click when `has_moved`) does not change the command, so the cached ghost is still the correct one.
- Rapid hover: `show_ghosts` always replaces `_ghosts` and rebuilds labels; the delete queue flushes at the end of the frame, so labels do not accumulate across frames; a second `queue_free` on an already-queued label is harmless. `clear()` when empty returns early and correctly does nothing.
- The diff shape handles every affect class the rules can produce: damage-only (same cell, new HP), push/pull (new cell, new or same HP), death (missing from `after` → HP 0 at the old cell), a push blocked by edge/forest/granary/village/another unit (pushee stays and takes 1, collider also takes 1 → both ghosted at their own cells, forced_move.gd:27-36), Lão spearing a friendly general standing in the line (the friendly is ghosted because the diff is over units, not over the clicked cell), Dư's 0-damage pull (moved, HP unchanged), and multiple affected units in one command (push collision).
- `_ghost` copies `cell`/`pos`/`type`/`hp`/`faction` into plain values, so `PreviewView` never holds a `Unit` reference — no live-state leak, and it respects the "only `Effects` writes `.hp`/`.cell`" boundary rule.
- Ghost geometry matches the token exactly (`cell_center - lift`, coin at `-TOKEN_LIFT`, `HP_OFFSET`), including raised terrain, because lift comes from the same `BoardView.surface_height`.
- `Label`s are `MOUSE_FILTER_IGNORE` with `auto_translate_mode` disabled and text passed through `tr()` — the ghost cannot eat clicks and cannot double-translate.
- Rejected commands (out of range, wrong unit) return null in both the controller and the view; `attack_targets` returns `[]` once the battle is over, so no ghost can appear after the result banner.
