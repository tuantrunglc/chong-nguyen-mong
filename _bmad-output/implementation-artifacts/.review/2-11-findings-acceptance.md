# Acceptance Auditor findings (Story 2.11)

Diff audited: `git diff b874ecd..HEAD -- game/` (single commit `1195039 Hoạt ảnh phát lại sự kiện (Story 2.11)`), plus the story file, `project-context.md`, `game-architecture.md`, and the current working tree. Tests were **not** run and no source file was modified; "provable" below means provable from the repository as given.

## AC checklist

| AC | Verdict | Evidence |
|---|---|---|
| 1 — replay by Tween in log order | PASS (2 gap rows) | `game/src/battle/event_player.gd:98-118` maps `MOVED / ATTACKED / COLLIDED / DAMAGED / DIED / DROWNED / TELEGRAPHED` to tweens; `:54-64` awaits them one at a time in log order; push/pull arrive as `MOVED`; `TELEGRAPH_CANCELLED / ROUND_STARTED / REJECTED / VICTORY / DEFEAT` cost 0 s (`:83-95`). Gaps: `COLLIDED` shakes only `unit_id` (`:109-110`); `MOVED` tweens only `position`, so the token keeps its old `cell` while moving (`:105-106`). No test ever calls `play()`. |
| 2 — whole enemy phase ≤ 3 s (NFR3) | FAIL | The cap in `total_seconds()` (`:38-42`) and `_time_scale()` (`:73-79`) applies to the **nominal** sum only; each event then waits on its own `SceneTreeTimer` (`:194-197`), which fires no earlier than its duration and in practice one frame later, so a real ~30-event phase on `thu_lao` (5 Nguyên units) plays ~3.2–3.5 s at 60 fps. Task 2.3's "0,06 s floor per event" is absent. The only test asserts arithmetic (`game/tests/test_event_player.gd:43-57`). |
| 3 — no new command while playing | PASS (coverage gap) | All four entry points guarded: `battle_view.gd:118` (general keys), `:132` (cell click → move/attack), `:173` (undo), `:180` (end turn); HUD buttons route through the same two handlers (`:50-51`); hover deliberately still allowed (`:230-231`), which is AC/Task 3.1 behaviour. Only the general-key path has a test (`test_battle_view.gd:1141-1153`). |
| 4 — phase line always on screen | PASS (caveat) | `hud.gd:42-47` builds `_phase_label` under the round label; `:72-84` `show_phase / hide_phase / phase_text`; `:61-68` hides it when the battle is over; `battle_view.gd:317-323` drives it from `_playing and _enemy_turn`. Strings `game/i18n/text.csv:10-11`, and `text.vi.translation` was really regenerated (6331→6411 B, both values present and **unquoted** in the binary — checked directly; `test_i18n.gd:34-41` would fail on a stale file). Caveat: the rest of the HUD already shows the post-command state for the whole animation (finding 8). |
| 5 — red cells / numbers stay the most salient (NFR9) | FAIL (unverified) | No visual evidence whatsoever: `_bmad-output/implementation-artifacts/anh/` holds 39 PNGs, newest `2-8-lao-ne-don.png` (2026-10-21), none named `2-11-*`; Task 6.2 is ticked anyway. No test covers it (correctly, per AC 7). Structurally the animation never writes to `TelegraphView` and the token radius (24 px) is smaller than `TILE_SIZE` (64 px), so no new occlusion is provable — but nothing verifies "most salient". |
| 6 — animation only reads, never mutates state (ADR-002) | PASS | `EventPlayer` never receives, stores or reads a `BattleState` (`:29-30`, `:98-130`); it writes only view-node properties (`:105-106`, `:171`, `:181-184`). No `.hp`/`.cell` assignment in the new code (grep clean; `tools/check_boundaries.sh:55` passes per the story's Debug Log), and `test_event_player.gd:60-68` asserts the state is untouched. |
| 7 — headless tests for order / lock / ≤3 s / phase text | FAIL (partial) | The two new view tests do run headless through `main.tscn`; but "thứ tự phát" is asserted only on the instant path and is tautological (finding 4), "≤ 3 giây" is asserted on arithmetic only (AC 2), and `test_event_player.gd` builds `BoardView`/`EventPlayer` directly instead of through `main.tscn`. |

## Task tick audit (`[x]` vs what the diff delivers)

| Task | Tick | Delivered? | Evidence |
|---|---|---|---|
| 1.1 | [x] | yes | `game/i18n/text.csv:10-11` |
| 1.2 | [x] | yes | `text.vi.translation` rebuilt and contains both values; `test_i18n.gd` enforces it |
| 2.1 | [x] | mostly — `play(events)` has no `snapshot` parameter | `event_player.gd:54` vs story line 34 |
| 2.2 | [x] | **no, 2 of 9 rows** — `COLLIDED` ignores `other_id`; `MOVED` does not update `token.cell` | `:109-110`, `:105-106` |
| 2.3 | [x] | partial — cap yes, 0,06 s floor missing | `:38-42`, `:73-79` |
| 2.4 | [x] | yes (no `await` on the instant path) | `:20`, `battle_view.gd:195-198` |
| 2.5 | [x] | yes (awaits per event, no `Thread`) | `:64`, `:194-197`; `grep Thread` clean |
| 3.1 | [x] | yes | `battle_view.gd:118,132,173,180` |
| 3.2 | [x] | yes | `hud.gd:42-47,72-84`; `battle_view.gd:317-323` |
| 3.3 | [x] | yes | `battle_view.gd:98-102,182`; `main.gd:132` |
| 3.4 | [x] | yes, order of the last two steps differs | `battle_view.gd:188-210` |
| 3.5 | [x] | partial — `_update_hud()` still runs *before* playback (needed for AC 4, so justified) | `:192` |
| 4.1 | [x] | partial — no `_apply_snapshot`; board+banner only, the rest stays in `BattleView` | `main.gd:145-147` + `battle_view.gd:204-228` |
| 4.2 | [x] | yes | `main.gd:128-132` |
| 4.3 | [x] | yes for undo; F5 leaves stray tweens (finding 2) | `event_player.gd:54-64,68` |
| 5.1 | [x] | **no** — no real battle, no `COLLIDED`/`DAMAGED`, order assertion cannot fail | `test_event_player.gd:23-40` |
| 5.2 | [x] | **no** — no second *command* is attempted and no unit position is asserted | `test_battle_view.gd:1141-1153` |
| 5.3 | [x] | partial — phase test yes, "stop()/hết trận không còn dòng pha sai" untested | `:1157-1166` |
| 5.4 | [x] | yes — 569 committed + 1 uncommitted 2.10 test + 5 new = 575 test functions (counted with `git grep`) | — |
| 6.1 | [x] | plausible, unverifiable without running; 575 is consistent with the tree | story Debug Log |
| 6.2 | [x] | **no** — no screenshot, no record of what was seen; contradicts its own "không có ảnh thì không đánh [x]" | finding 1 |
| 6.3 | [x] | partial — the guide exists but steps 2–8 were never executed by the agent ("đúng những bước đã chạy") | story lines 173, 175-184 |
| 6.4 | [x] | yes (`1195039`), but it also ships the 2.10 review patches, `2-10-*.md` and `deferred-work.md`, none listed in the File List | `git show --stat 1195039` |

## high — Task 6.2 is ticked with no screenshot and no record of the visual check; AC 5 has zero evidence

- Violates: AC 5 (and the story's own Task 6.2 rule, story line 73: "**không có ảnh thì không đánh [x]**")
- Evidence: `_bmad-output/implementation-artifacts/anh/` contains 39 PNGs, the newest `2-8-lao-ne-don.png` dated 2026-10-21; no `2-11-*` file exists anywhere in the repository (`find . -iname "*2-11*"` returns only the story and this diff). The story's own Completion Notes say "**Chưa kiểm bằng mắt (6.2)**" (line 173) and hand steps 2–8 to the author, while line 73 marks 6.2 `[x]` on the strength of a parenthetical "tác giả chốt done 2026-10-22". The project has already been burned by this exact move: `2-10-re-chuot-xem-thong-tin.md:84` records "2.9 bị code review bắt vì đánh [x] khống. Đừng đánh [x] task chụp ảnh khi chưa có file ảnh", and 2.10's equivalent task was correctly left `[ ]` for the same reason (line 49).
- Why: the one deliverable of a purely visual story that cannot be checked from code was declared done with no artifact, so AC 5 (NFR9 salience), the "smooth, in-order motion" half of AC 1, and every claim in the author test guide rest on an assertion that the file itself contradicts.

## medium — `stop()` / new battle does not cancel playback: tweens and token visuals survive, so F5 during a death fade deletes a unit

- Violates: Task 2.2 (`DIED`/`DROWNED` must be undone by the following `show_state`), Task 3.4/4.3 (F5 mid-playback), and the story's own architecture rule "Tween gắn vào node của view; huỷ khi `stop()`/đổi bàn để không còn tween treo" (story line 95)
- Evidence: `game/src/battle/event_player.gd:68-69` — `stop()` only sets `_stopped`; every tween is created at `:152, :160, :170, :178, :188` and never stored, so nothing can `kill()` it and the in-flight one keeps running. `_sink_or_fade` ends at `:182-184` by driving `modulate:a` to 0 and then setting `token.visible = false`. `UnitToken.update()` (`game/src/battle/unit_token.gd:75-85`) resets `cell`, `position` and the HP text but **never** `modulate` or `visible`, and `BoardView._sync_tokens` reuses tokens by `unit.id` (`game/src/battle/board_view.gd:359-363`). `main._start_battle` draws the new battle **before** stopping the player (`main.gd:129` then `:130` → `battle_view.gd:59-60`).
- Why: press F5 while a Nguyên unit is fading out and the reused token finishes the old fade on the new battle's board and is hidden forever (no later `show_state` restores `visible`/`modulate`), while the old tween can also drag a reused token to a stale position — the generation counter at `battle_view.gd:208` protects only the snapshot, not the nodes.

## medium — AC 2 / NFR3 is capped on paper only; the 0,06 s per-event floor from Task 2.3 is missing

- Violates: AC 2 (NFR3), Task 2.3
- Evidence: `game/src/battle/event_player.gd:38-42` (`minf(sum, MAX_PHASE_SECONDS)`), `:73-79` (`_time_scale`), and the actual wait at `:194-197` (`await get_tree().create_timer(seconds).timeout`, once per event). A `SceneTreeTimer` fires at the first frame where elapsed ≥ `seconds`, so every event adds up to one frame of overshoot; a `thu_lao` turn (`game/data/tran/thu_lao.json`: 5 Nguyên units) yields roughly 30 events (strikes + 2–3 steps each + telegraphs), i.e. 3.0 s nominal + ~0.2–0.5 s at 60 fps. `_base_seconds()` has no lower bound, so with 50+ events a `DAMAGED` event drops below the required 0.06 s. The only guard is `test_event_player.gd:43-57`, which calls `total_seconds()` and never plays a single tween.
- Why: the NFR is a wall-clock promise and the implementation only accounts for nominal time, so the author's step 7 ("báo em con số thật") is the only thing that would ever catch it — and that step was never run (finding 1).

## medium — the new tests bypass the production path: the order assertion cannot fail, and only 2 of 575 tests leave the `instant` shortcut

- Violates: AC 1 ("theo đúng thứ tự"), AC 7, Task 5.1, Task 5.4
- Evidence: `event_player.gd:46-47` sets `_played = events.duplicate()` *before* applying anything and `:55` does the same in `play()`, so `played()` is a copy of the input, not a log of what was played (a `stop()` after the first event still reports the whole list). `test_event_player.gd:35-37` therefore asserts nothing about playback, and `:35-39` would stay green if `_apply_instant` iterated the list backwards: the two `MOVED` deltas commute and the `DIED` assert is order-free. The full 5-test picture: only `test_battle_view.gd:1145` and `:1160` set `instant = false`; the default is `DisplayServer.get_name() == "headless"` (`event_player.gd:20`), so every pre-existing test and `test_event_player.gd` take `play_now()`.
- Why: the one AC about ordering has no test that can fail on ordering, and the Tween/`await` path that ships to players is exercised by exactly two tests, neither of which asserts that events are *sequential* (they could all fire at once and both would pass).

## medium — nothing tests that a second **command** is blocked; only the 1-2-3 keys are proven (Task 5.2 not delivered as written)

- Violates: AC 3 (mouse select/move/attack, Z, Space, HUD buttons), Task 5.2
- Evidence: `test_battle_view.gd:1141-1153` starts an attack animation and then presses `KEY_2` only; it never clicks a lit cell or a target, never presses `KEY_Z` / `KEY_SPACE`, never presses a HUD button, and never asserts "vị trí quân không đổi" as Task 5.2 requires. The guards that make those paths safe (`battle_view.gd:132`, `:173`, `:180`) have no test at all.
- Why: three of the four guarded entry points can regress to green, including the mouse path AC 3 names first and the "bấm đi rồi bấm đánh ngay" case the task specifically asked for.

## medium — `COLLIDED` shakes only one of the two colliding units (Task 2.2 row not delivered)

- Violates: Task 2.2 ("Rung nhẹ cả `unit_id` và `other_id` (nếu có) tại chỗ")
- Evidence: `event_player.gd:109-110` calls `_shake(token, seconds)` with the single token of `event.unit_id`; `BattleEvent.other_id` exists and is documented as "quân bị va, 0 nếu là mép bàn hoặc vật cản" (`game/src/core/battle_event.gd:66`, `:17`).
- Why: the spec table the task marks `[x]` says both coins shake, and nothing in the code or tests reads `other_id`, so a collision currently looks one-sided.

## medium — a moving token keeps its old `cell`, so hover info describes the wrong cell during playback

- Violates: Task 2.2 (`MOVED` must update `token.cell` so `pick_cell` does not drift), open question 2 ("rê chuột vẫn xem được"), Task 3.1
- Evidence: `event_player.gd:105-106` tweens `position` only; `BattleInput._pick` → `BoardView.pick_cell` returns `token.cell` for the hit test (`board_view.gd:155-161`), while `BattleView._update_info` reads the **final** snapshot (`battle_view.gd:242-255`) and the hover path is deliberately left open during playback (`:230-231`).
- Why: hovering the coin the player can see sliding between two cells resolves to the cell it left, so the tooltip shows terrain or a different unit than the one under the cursor — and the story's justification for dropping the `cell` write is only `tools/check_boundaries.sh:55`, a text grep aimed at `BattleState` that happens to also match the view's own `UnitToken.cell` field, not an ADR.

## medium — HUD shows the post-command state for the whole animation (round number and Undo jump at playback start)

- Violates: AC 4 coherence (the HUD now describes the past command for up to 3 s), Task 3.4
- Evidence: `battle_view.gd:191-192` calls `_update_hud()` at the *start* of playback, and `_update_hud` (`:317-323`) reads `_controller.snapshot()` — which is already the **final** state because `RulesEnemyPhase.end_player_turn` resolves strikes, `round_number += 1` and the whole prepare phase before `events_resolved` is emitted (`game/src/core/battle_controller.gd:67`). So pressing Space immediately shows "Hiệp 2" (`hud.gd:62`) and greys out Hủy (`:63`) while the replay is still showing Hiệp 1's strikes.
- Why: the story exists so the player understands what just happened, and the one line the story added now contradicts the two lines above it for the entire animation — precisely the kind of defect the skipped visual check (finding 1) is meant to catch.

## low — `playback_finished` does not live where the architecture puts it, and the architecture was not updated

- Violates: `game-architecture.md` "Hệ thống sự kiện" (`:483` "Trình bày → `BattleController` | Signal `playback_finished`", `:494` `signal playback_finished`, `:506` `controller.playback_finished.emit()`)
- Evidence: the signal is declared and emitted on the view: `game/src/battle/battle_view.gd:11` `signal playback_finished(snapshot: BattleState)`, emitted at `:210`, consumed by `game/src/app/main.gd:64,145`; `BattleController` has only `events_resolved` and `rolled_back` (`battle_controller.gd:8,10`).
- Why: the story (Tasks 3.4/4.1) prescribes exactly this shape and it is arguably the better adaptation (input is gated in the view), but the architecture document now describes a signal that does not exist and no note records the deviation, so the next story will read the wrong contract.

## low — Task 2.1 / 4.1 prescribed API drifted (`play(events)`, no `_apply_snapshot`)

- Violates: Task 2.1, Task 4.1
- Evidence: story line 34 specifies `play(events: Array[BattleEvent], snapshot: BattleState)`; the code is `func play(events: Array[BattleEvent])` (`event_player.gd:54`) and `_on_events_resolved` calls `_player.play(events)` (`battle_view.gd:199`). Task 4.1's `_apply_snapshot(snapshot)` is `_on_playback_finished` (`main.gd:145`) and covers only the board and the banner, with HUD/lit cells/tooltip left in `battle_view.gd:204-228`.
- Why: both deviations are defensible (the player never gets a state to misuse) but they are undelivered as written while marked `[x]`, which is the exact drift the 2.10 review already complained about ("Task 2.1 đòi `move_to(pos)` nhưng code là `place_at(anchor)`").

## low — Task 5.3's second half ("stop()/hết trận không còn dòng pha sai") has no test

- Violates: Task 5.3
- Evidence: `test_phase_line_follows_playback` (`test_battle_view.gd:1157-1166`) covers only the wait → enemy → player transition; `test_tooltip_hidden_when_battle_ends` (`:1170-1179`) asserts the tooltip, never `phase_text()`. The behaviour exists (`hud.gd:66-68` hides the phase when `over`, `battle_view.gd:322` skips `show_phase` when over, `stop()` hides the whole HUD at `:77`), but nothing pins it.
- Why: the story's own task asked for it and a regression that leaves "Quân Nguyên đang ra đòn" on the victory screen would stay green.

## low — Task 6.3/6.4 and the File List do not match the commit

- Violates: Task 6.3 ("đúng những bước đã chạy"), Task 6.4 traceability, File List
- Evidence: `git show --stat 1195039` lists 15 files; the story's File List (lines 188-194) omits `game/src/ui/tooltip.gd`, `_bmad-output/implementation-artifacts/2-10-re-chuot-xem-thong-tin.md` and `deferred-work.md`, all shipped under a commit message that says only "(Story 2.11)". The guide's steps 2–8 (lines 178-184) were never executed by the agent, and the story says so at line 173.
- Why: the author is told to trust the File List and the commit message when deciding what to re-test, and both under-report what changed in this commit.
