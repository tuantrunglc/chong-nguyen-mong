# Edge Case Hunter findings (Story 2.11)

## high — F5 during playback: `stop()`'s flag is reset by the next `play()`, so the old coroutine keeps replaying the old log on the new board
- Where: `game/src/battle/battle_view.gd:199` + `game/src/battle/event_player.gd:26,54-64,68-69,205-208`
- Scenario: enemy phase in progress (up to ~3 s), dev presses F5 → `_start_battle()` → `_show_board(snapshot)` for the new battle → `_battle_view.start(new_controller)` (generation+1, `_player.stop()` → `_stopped = true`) → `begin_battle()` → new `events_resolved` → `await _player.play(new_events)` which begins with `_stopped = false`. The old playback's pending `_wait()` timer fires some frames later, sees `_stopped == false`, and runs the remaining OLD events against the NEW board's tokens (same ids → tokens are reused by `_sync_tokens`).
- Evidence:
  - `event_player.gd:56` `_stopped = false` (set at the top of every `play()`, no per-run identity)
  - `event_player.gd:59` `if _stopped: return` — the only cancellation point
  - `event_player.gd:68-69` `func stop() -> void: _stopped = true` — no generation, no tween kill
  - `battle_view.gd:199` `await _player.play(events)` — two of these run at once
  - `battle_view.gd:205-209` `_playing = false` / `_enemy_turn = false` **before** `if _controller == null or generation != _playback_generation: return`
- Why it fails: expected — the interrupted run aborts and the new battle animates alone. Observed — (a) the stale loop applies old MOVED/ATTACKED/DAMAGED/DIED events to the new board (tokens jump, wrong units move) while both loops tween the same `position` properties; (b) the stale `_finish_playback` clears `_playing`/`_enemy_turn` even though the generation check then returns, so the new battle's input lock and phase line are dropped at a nondeterministic moment inside the new enemy-phase animation. A command issued in that window starts a third concurrent `play()` and `playback_finished` can then be emitted with an older snapshot than the controller holds (board one command behind).
- Fix: give each playback a run id (token) and cancel/kill its tweens on `stop()`/`start()`, and move `_playing = false` / `_enemy_turn = false` inside `_finish_playback`'s generation check so a stale run cannot touch the new battle's flags.

## high — a DIED/DROWNED event from an interrupted playback hides a *new* battle's token permanently
- Where: `game/src/battle/event_player.gd:184` (and `:130`), `game/src/battle/unit_token.gd:75-86`, `game/src/battle/board_view.gd:359-363`
- Scenario: F5 (or any new battle) while a playback whose remaining log contains a `DIED`/`DROWNED` event. The new battle draws its board first → tokens for 101/102/103 are re-used via `_sync_tokens`; then the stale loop reaches `_sink_or_fade()` and executes `token.visible = false` and `modulate:a → 0` on the token that now belongs to the new battle's unit with that id.
- Evidence:
  - `event_player.gd:184` `token.visible = false`; `:130` same in `_apply_instant`; `:182` `tween_property(token, "modulate:a", 0.0, seconds)`
  - `unit_token.gd:75-86` `update()` writes only `cell`, `position`, `_hp_label.text`, `_moved`, `_attacked` — never `visible` or `modulate`
  - `board_view.gd:359-363` reuses the existing token when `old.unit_type == unit.type` (`old.update(unit, lift); continue`)
- Why it fails: expected — a unit that exists in the snapshot is drawn. Observed — the unit is invisible (and alpha 0, so a later `_flash` restores alpha 0) for the rest of that battle, yet still `pick_cell`-able and attackable: the player can click an apparently empty cell and hit/see an invisible Bộ binh. Nothing in `show_state`, `update()` or `_sync_tokens` ever restores visibility.
- Fix: make `BoardView._sync_tokens`/`UnitToken.update` reset `visible`/`modulate` to the snapshot's truth (`visible = true`, `modulate = Color.WHITE`), so token appearance can never outlive a playback.

## medium — the board shows PRE-command tokens while tooltip / highlight / path / round label read the POST-command state
- Where: `game/src/battle/battle_view.gd:235,242,253-255,318-320`
- Scenario: any command with events; e.g. press Space in `tran_01`, then move the mouse over the enemy that is about to strike. During the ~1-3 s enemy animation the tokens are still at their pre-phase cells and HP badges, but:
  - `_update_info()` → `_tooltip.show_text(_unit_text(unit, state))` prints the post-phase HP ("2/3") and the post-phase "đòn sắp đánh"/"không có đòn" for a token still drawn with 3 HP;
  - `_telegraph_view().highlight(...)` highlights post-phase telegraph cells against pre-phase red cells (a highlighted cell that is not red in `_cells` is silently not drawn, so the highlight appears to jump);
  - `_on_cell_hovered()` gates on the *pre-command* `_cells` but calls `_controller.path_to(_selected, cell)` on the post-command state, so right after a move a path line can be drawn from the old selection ring toward cells computed from the new position;
  - `_update_hud()` (called at the top of `_on_events_resolved`) shows the post-command round number and undo/end-turn enablement while the board is still the old round.
- Evidence: `battle_view.gd:242` `var state: BattleState = _controller.snapshot()` (post), `:320` `_hud.show_turn(snapshot.round_number, _controller.can_undo(), over)`, `:235` `_board.show_path(_controller.path_to(_selected, cell))` with `_cells`/`_selected` still pre-command.
- Why it fails: expected — during the replay the player only sees the old board, so any info panel must describe the old board (or be frozen/hidden). Observed — two different states are on screen at once; hovering a cell where an enemy just died shows terrain text while the token is still there.
- Fix: short-circuit `_on_cell_hovered`/`_update_info` while `_playing` (freeze the info panel and highlight), and pass the pre-command snapshot/round to the HUD during playback.

## medium — the "≤ 3 s per phase" cap is arithmetic, not wall clock: every event costs at least one frame
- Where: `game/src/battle/event_player.gd:38-42,61-64,73-79,194-197`
- Scenario: 5-enemy phase of `thu_keo`/`thu_lao` (5 enemies, up to 3-step moves + 5 strikes + 5 telegraphs ≈ 30 events, nominal sum ≈ 5 s → scale ≈ 0.6 → ~0.08-0.13 s per event). Each event ends with `await get_tree().create_timer(seconds).timeout`, which fires no earlier than the next frame, so the phase takes `Σ ceil(seconds·fps)/fps ≥ N/fps` extra: +0.5 s at 60 FPS, +1 s at 30 FPS on top of the scaled 3.0 s.
- Evidence: `event_player.gd:194-197` `await get_tree().create_timer(seconds).timeout` (one timer per event, frame-quantised); `:61` `var seconds: float = _base_seconds(event) * scale`; `:73-79` the scale is computed from nominal seconds only. Also `total_seconds()` (`:38-42`) is never called by production code — `play()` uses `_time_scale`, and for a token-less event `_play_one` waits only `seconds*0.5` (`:102,118`), so the two functions disagree.
- Why it fails: expected (AC 2/NFR3) — no enemy phase exceeds 3.0 s. Observed — a full 5-enemy log runs ~3.5 s at 60 FPS, more on a slow/iframe frame rate; the only test of the cap (`test_event_player.gd:31-46`) calls the dead `total_seconds()` and measures no real time.
- Fix: compute the scale from measured time (`elapsed` since playback start, or subtract the frame budget per event) and stop the phase at a deadline, and assert the cap against real elapsed time in a test.

## medium — undo / end-turn look enabled during playback and do nothing (dead clicks)
- Where: `game/src/battle/battle_view.gd:320` + `game/src/ui/hud.gd:61-64`
- Scenario: press Space → the enemy phase animates for up to 3 s. `_on_events_resolved` calls `_update_hud()` with the POST snapshot, which is not battle-over, so `show_turn(..., over=false)` leaves "Kết thúc lượt (Space)" enabled (and "Hủy (Z)" enabled during a move's own playback, where `_undo_snapshot` is non-null). Clicking either button emits `undo_pressed`/`end_turn_pressed` → `_on_undo`/`_on_end_turn` → `if ... _playing ...: return`, with no visual or audio feedback.
- Evidence: `hud.gd:63-64` `disabled = over or not can_undo` / `disabled = over`; `battle_view.gd:180-181` the `_playing` guard silently returns; `_update_hud` never passes `_playing` into `show_turn`.
- Why it fails: expected (AC 3) — the board is locked, so it should look locked. Observed — the two most-clicked controls advertise availability for a 3 s window and swallow the click.
- Fix: disable both HUD buttons while `_playing` (add a `playing` parameter to `show_turn` or call a `set_locked` on the HUD).

## medium — the whole suite runs the instant branch; the async replay is covered by 2 tests and only partially
- Where: `game/src/battle/event_player.gd:20,195`; `game/tests/test_battle_view.gd:1145,1160`
- Scenario: `tools/test.sh` runs `--headless`, so `DisplayServer.get_name() == "headless"` → `instant = true` for every `BattleView` in the 575 existing tests → `play_now()` and no `await` at all. Only `test_commands_ignored_while_animation_plays` and `test_phase_line_follows_playback` set `instant = false`.
- Evidence: `event_player.gd:20` `var instant: bool = DisplayServer.get_name() == "headless"`; `battle_view.gd:195` `if _player.instant or events.is_empty(): ... return`.
- Why it fails: expected — the shipped animation path is exercised. Observed — nothing tests: `stop()`/new battle mid-playback (the two high findings above), `_sink_or_fade` (DIED/DROWNED) and `_shake` (COLLIDED) in async mode (the attack fixture leaves the target at 1 HP, and the enemy phase kills nobody), tween/timer cancel, `play()` ordering vs `_played`, and 4 of the 5 command entry points under lock (`test_commands_ignored_while_animation_plays` only presses KEY_2; cell click, Z, Space and the HUD buttons are untested under `_playing`).
- Fix: add headless-but-async tests by setting `event_player().instant = false` for one test per concern: interruption (F5/`stop()` mid-log, asserting a single live playback), DIED/DROWNED replay, and all five command paths while playing.

## low — `_enemy_turn` is latched before the command is accepted, so a submit that emits nothing leaves the wrong phase line
- Where: `game/src/battle/battle_view.gd:182` (and `:101`)
- Scenario: `_on_end_turn()` / `begin_battle()` set `_enemy_turn = true` and *then* submit. If `submit()` returns without emitting `events_resolved` (the invariant-rollback path: `BattleController.submit` → `_state.validate()` fails → `rolled_back`, returns `[]`; the "cứu trận" test overrides `_resolve` for exactly this), nothing ever clears the flag. The next command that does play (a player move) then shows "Quân Nguyên đang ra đòn" during a player action.
- Evidence: `battle_view.gd:182-183` `_enemy_turn = true` then `_controller.submit(...)`; only `_finish_playback` (`:206`) clears it; `battle_controller.gd:50-56` returns `[]` without emitting.
- Why it fails: expected — the phase line reflects what is animating. Observed — a latched enemy flag leaks into a player move's animation, and no code path resets it.
- Fix: set `_enemy_turn` from the command that produced the events (e.g. pass it through `_submit`/`begin_battle` and only latch after `submit()` emitted), or reset it in `_on_events_resolved` from a stored "pending command kind".

## low — the phase line disappears exactly during the animation that ends the battle
- Where: `game/src/ui/hud.gd:66-68` + `game/src/battle/battle_view.gd:211-215`
- Scenario: the enemy phase delivers the killing blow that empties the player's generals (LOST). `_on_events_resolved` calls `_update_hud()` with the POST snapshot, `over == true`, so `show_turn` calls `hide_phase()` while the ~0.5 s strike animation is still running and before the "Thua!" banner appears. Same for the player's winning blow.
- Evidence: `hud.gd:66-68` `if over: hide_phase()`; `battle_view.gd:322-323` `if not over: _hud.show_phase(...)`.
- Why it fails: expected (AC 4: the line is always present while playing) — the line should say "Quân Nguyên đang ra đòn" while that animation plays. Observed — the HUD drops to round label + greyed buttons for the final animation, so the player loses the explanation of the last action.
- Fix: base `over` for the HUD on the snapshot at `playback_finished` (pass `_playing` through and keep the phase line while animating).

## low — `stop()`/`start()` never kill the in-flight tweens
- Where: `game/src/battle/event_player.gd:68-69,152,160,170,178`
- Scenario: F5 or the error screen (`main._show_error` → `_battle_view.stop()` → `_show_board(null)`) mid-animation. `stop()` only sets a flag; the tween created on `_player` keeps writing `position`/`modulate` to its token. For F5 the token was just re-synced by `show_state`, so the tween immediately drags it off its square again (in addition to the stale-log issue above). For the error/menu path `_sync_tokens` removes every token via `remove_child` + `queue_free`, so the tween's target is freed → Godot "Tween: Target object was freed" errors in the console.
- Evidence: `event_player.gd:152/160/170/178` `create_tween()` bound to `_player` (which lives as long as `BattleView`); `board_view.gd:374-377` `_remove_token` only queued-frees.
- Why it fails: expected — a stopped replay leaves the board alone. Observed — motion continues after `stop()`/after the board was rebuilt, plus engine errors on the error-screen path.
- Fix: keep the active `Tween` and `kill()` it in `stop()`/`start()` (or bind it to the token's lifetime and cancel per generation).

## low — `_delta()` ignores the ô ải lift, so a token drawn 8 px off whenever a move crosses a PASS tile
- Where: `game/src/battle/event_player.gd:139-141`
- Scenario: a unit steps onto or off a `Terrain.PASS` cell (`chi_so.json` levels with `ô ải`; `BoardView.surface_height(PASS) = PASS_HEIGHT = 8`). The real resting position is `cell_center - Vector2(0, lift)` (`unit_token.gd:77`), but `_delta()` is the plain difference of ground centres, and `_play_one` only adds it to the current position, so the token floats 8 px above (or sinks into) the pass tile for that step and snaps back at the final `show_state`.
- Evidence: `event_player.gd:140-141` `return BoardView.cell_center(event.to_cell) - BoardView.cell_center(event.from_cell)`; `board_view.gd:118-128` `top_center`/`surface_height`; `unit_token.gd:77` applies the lift.
- Why it fails: expected — the animation lands where the snapshot will draw the token. Observed — a visible vertical pop on pass tiles (and the same in `_apply_instant`, which is test-only).
- Fix: tween to `BoardView.top_center(to_cell, state.terrain_at(to_cell))` instead of accumulating ground-centre deltas (or add the lift delta per step).

## Covered cases (sound)

- **Input lock, all entry points**: production submits only from `BattleView` (`grep _controller.submit` → `battle_view.gd:150,162,183` plus `undo`). Cell click (`:132`), keys 1-3 (`:118`), Z (`:173`), Space/end-turn (`:180`) and both HUD buttons (connected to `_on_undo`/`_on_end_turn` in `setup`) all check `_playing` before touching the controller; `DevTools` F1/F3 only toggle overlays and F2/F4 only log. A second command inside one battle is impossible, so `play()` is never re-entered within a battle.
- **"Chơi lại trận" cannot interrupt playback**: `ResultBanner` is only shown from `_on_playback_finished` (`main.gd:145-147`), i.e. after `_playing` is already false, so the retry button is never clickable during an animation.
- **Error screen / menu during playback**: `stop()` (`battle_view.gd:68-77`) nulls the controller and bumps the generation; `_finish_playback` then returns before `playback_finished.emit`, so no old snapshot is drawn onto the blank board and `_update_hud` is never called with a null controller (checked: `_finish_playback` returns before `_update_hud`, `_on_events_resolved` returns at `:189`, `start()` always has a controller).
- **No permanent lock**: `_playing` is always cleared when the coroutine resumes; `_wait()` re-checks `is_inside_tree()` and each event advances the loop, so no event mix can hang the coroutine (tree paused is irrelevant — `create_timer` defaults to `process_always = true`).
- **Generation guard on drawing**: `_finish_playback:208` does stop a stale run from emitting `playback_finished`/drawing an old snapshot, and `main._on_playback_finished` is the only `show_state` for the post-command snapshot (correct single draw per command).
- **Event order and state isolation**: `play()` awaits each event sequentially, `_played` preserves log order, `EventPlayer` only touches `UnitToken` nodes (never `BattleState`), and `_lunge/_shake/_flash` read `token.position`/`token.modulate` at start so a push after a lunge/charge starts from the right place.
- **Post-command redraw order**: `playback_finished` fires before `_select`/`_deselect`, so `BoardView.show_state` syncs tokens/cells first and then `_select` recomputes `show_selection`/`_select` path from the fresh snapshot; a dead selected general (`unit == null`) is deselected.
- **HUD phase basics**: player ↔ enemy transitions across `begin_battle`, `_on_events_resolved`, `_finish_playback` all pass through `_update_hud`, so the normal (non-battle-ending) case shows "Lượt của bạn" when idle and "Quân Nguyên đang ra đòn" for the whole enemy animation; `test_phase_line_follows_playback` exercises both directions.
- **Empty-event paths** (undo, rejected begin): `events.is_empty()` takes the same-frame branch, emits `playback_finished` with the restored snapshot and clears both flags; `play_now([])` is a no-op.
- **Godot specifics**: `set_parallel(true)` is used only for DROWNED's position+alpha pair (correct); `"modulate:a"` and `"position"` are valid paths and `normal.a` is preserved by `_flash`; `Vector2(Vector2i)` is not used by the new code; `Array[BattleEvent].duplicate()` is the same typed-array pattern as the existing `lit_cells()` (`battle_view.gd:85`) and is valid; `_board.tokens().get(id) as UnitToken` is null-safe; `create_tween()` is always called from `_player`, which is in the tree.
- **i18n**: both new keys are in `text.csv` and are covered by `test_i18n.test_every_key_translates_on_english_machine` (`assert_ne(tr(key), key)`), so a missing binary translation would fail the suite.
- **2.10 review fixes do not regress**: `_attack_text` now asks `TelegraphMarks.hit_cell` before reporting a DIRECTION charge — for a DIRECTION telegraph `path_cells` is only empty when `target_cell` is `NO_CELL` (owner dead / first cell off-board), so a valid "Xung phong hướng Bắc" is still reported and the invalid case matches the (empty) red path; `_hide_info` in `stop()` is equivalent to the replaced inline code and also clears the highlight; the `_fit_width`/`place_at` viewport guards only add null-safety.
