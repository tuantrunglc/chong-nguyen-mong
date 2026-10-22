# Acceptance Auditor findings (Story 2.12)

Story 2.12 "Xem trước kết quả đòn". Diff audited: `git diff ec9c3b8..HEAD -- game/` = single commit
`66c2108` (7 game files, +246/−1), plus the story file, `project-context.md`, `game-architecture.md`,
`epics.md`, and the sources/tests the diff touches. Read-only: no file was modified and neither the game
nor the suite was run; the story's `583/583` is therefore not reproduced here (a static count of
`func test_` across `game/tests/` is also 583, so it is at least consistent). "Provable" below means
provable from the repository as given.

## AC checklist

| AC | Verdict | Evidence |
|---|---|---|
| 1 — ghost at final position of every affected unit + HP after, on a hovered attackable target | **FAIL** (happy path correct; wrong ghost in a reachable flow) | Built from the preview diff: `battle_view.gd:273-289`, `_ghosts_of` `:299-312`, `_ghost` `:314-321`; test `test_battle_view.gd:1141-1150`. But `_update_preview` early-returns when the cell is unchanged (`:279-280`) and `_select` (`:393-402`) never resets `_preview_cell` (`:39`), so switching generals with the pointer parked on a cell that both can attack keeps the **old** general's ghost. `data/tran/thu_lao.json` — Khoái at 3,5 and Lão at 3,3 both target 3,6 (Khoái: `rules_attack.gd:29-36`; Lão: `test_battle_view.gd:891-898`). See HIGH-1. |
| 2 — real attack matches the preview; a test compares both results | PASS (caveat) | `battle_controller.gd:42-49` runs the same `_resolve` on a clone; `test_battle_controller.gd:366-372` compares `BoardFixture.picture(preview)` with `picture(snapshot)` after `submit`; `test_battle_view.gd:1169-1181` compares the ghost HP with the real pushed unit. Caveat: `picture` is units only (`board_fixture.gd:96-100`) and the view test checks only `ghosts[0].hp` — LOW-1; the AC-1 state above also breaks the on-screen promise. |
| 3 — ghost disappears when the pointer leaves the target | PASS | Clear branch `battle_view.gd:276-279` (called from `_on_cell_hovered` `:265`), `_hide_info` `:385-386`, `_deselect` `:419-421`; test `test_battle_view.gd:1149-1150`. |
| 4 — recompute only on a cell change, never per frame | PASS (caveat) | BattleView has no `_process`; guard `battle_view.gd:279-280`; counter `:122-123`; test `test_battle_view.gd:1154-1166` (documented to fail if the guard is removed). Caveat: the test calls `_view(main)._on_cell_hovered(...)` directly (`:1157-1163`), against the story's own Testing rule (`story:80`), and the same guard is what causes HIGH-1 — it is keyed on the cell only, not on the command/general. |
| 5 — preview on a clone, live state untouched, `src/core/` untouched (ADR-005) | PASS | `battle_controller.gd:42-49` (`_state.clone()` → `_resolve(copy, …)`); `battle_state.gd:51-65` deep-clones units/telegraphs/intents; `test_battle_controller.gd:355-363` (live picture unchanged, no undo, no signal). `git diff --stat` touches no `game/src/core/` file; the boundary rule `check_boundaries.sh:55-56` (`.hp/.cell` writes outside `effects.gd`) sees only reads/dictionary keys (`battle_view.gd:314-321`). |
| 6 — ghost above tokens, below order numbers (NFR9) | PASS (structural; unverified visually) | BoardView child order `board_view.gd:255-267`: `_world` (tokens) :259 → `_preview` :261-262 → `_target_layer` :266 → `_telegraph.numbers` :267 (topmost). Caveat: no test asserts z-order or appearance; `_draw` (`preview_view.gd:70-78`) never runs headless; Task 5.2 is open (MEDIUM-2). |
| 7 — headless tests through `main.tscn`: show/hide, match, recompute count | PASS (caveat) | `test_battle_view.gd:1141`, `:1154`, `:1169` all start at `_make_attack_main()` → `_make_main()` → `load("res://scenes/main.tscn")` (`:76-82`, `:576-587`). Caveat: they assert the `ghosts()` data model only, never the drawing/labels (MEDIUM-2). |

**Summary: 6 PASS (4 with caveats) and 1 FAIL.** The fail is a real-behaviour gap in AC 1, not a missing
implementation: the preview is correct on the normal hover path and wrong after a general switch.

## Task checklist (every `[x]` the story claims)

| Task | `[x]` | Delivered? | Evidence |
|---|---|---|---|
| 1.1 `preview()` on a clone, null on rejection, no signal/undo change | x | YES | `battle_controller.gd:42-49` |
| 1.2 state unchanged + preview == post-`submit` picture | x | YES (undo half weak — LOW-1) | `test_battle_controller.gd:355-363` |
| 1.3 rejected command → null | x | YES | `test_battle_controller.gd:376-379` |
| 2.1 `PreviewView` with `show_ghosts/clear/ghosts` | x | YES | `preview_view.gd:16-34` |
| 2.2 fog disc in faction colour + label + HP, `UnitToken` constants | x | YES | `preview_view.gd:7`, `:42-78` |
| 2.3 BoardView creates it after tokens, before target/numbers; `show_state` clears; `preview_view()` | x | YES, plus stray node (LOW-3) | `board_view.gd:259-267`, `:271-279`, `:291-293` |
| 3.1 hover wiring to `preview()` + clear elsewhere | x | YES | `battle_view.gd:258-269`, `:273-289` |
| 3.2 remember cell + `preview_computations()` | x | YES, but the guard causes HIGH-1 | `battle_view.gd:39`, `:122-123`, `:279-282` |
| 3.3 hide on deselect / non-target / **playback start** / `stop()` / battle over | x | **NO** — playback start missing | MEDIUM-1 |
| 3.4 ghosts from the snapshot diff (final cell + HP; dead at old cell, HP 0) | x | YES | `battle_view.gd:299-321` |
| 4.1–4.4 view/controller tests (show/hide, count, match, null, state) | x | YES | `test_battle_view.gd:1141-1181`, `test_battle_controller.gd:355-379` |
| 5.1 `tools/test.sh` green, number in Debug Log | x | Claim only — not reproduced; static count is consistent (583) | `story:131` |
| 5.2 visual check in `chay.sh --dev --tran=thu_lao`, screenshot | — (correctly not `[x]`) | **Not done**; no `anh/` dir | `story:51`, `:140` |
| 5.3 author test guide "exactly the steps run" | x | **FALSE** — guide steps 2–7 were never run | `story:52`, `:142-150`; LOW-4 |
| 5.4 Vietnamese commit ending `(Story 2.12)` | x | YES — `66c2108 "Xem trước kết quả đòn (Story 2.12)"`; one commit also carries the spec, as 2.11 did | `git show --stat 66c2108` |

**Can the six new tests fail?** Yes, all six have a realistic failure mode: live-state mutation
(`test_battle_controller.gd:355-363`, the story's own negative check at `story:133`), a wrong/missing
preview result (`:366-372`), a non-null rejection (`:376-379`), absent/wrong ghost data
(`test_battle_view.gd:1141-1150`), removing the same-cell guard (`:1154-1166`), and a ghost HP that does
not match the pushed unit (`:1169-1181`). Their failure surface is still narrower than their names claim —
see LOW-1 and LOW-2.

## HIGH-1 — Ghost survives a general switch: stale preview from the previous general's attack

- Violates: AC 1 (and thus AC 2's promise on screen); Task 3.2.
- Evidence: `game/src/battle/battle_view.gd:279-280` (`if cell == _preview_cell: return`), `:39`
  (`_preview_cell`), `:393-402` (`_select` never resets it), `:181-184` (`_set_pending` does not clear),
  `:133-145` (keys 1/2/3 go straight to `_select`). Fixture: `game/tests/test_battle_view.gd:876-888`
  and target assertion `:891-898`; real level `game/data/tran/thu_lao.json`.
- Why: in `thu_lao` (the exact level Task 5.2 tells the author to open), Khoái at 3,5 can attack the Bộ
  binh (3,6), and Lão at 3,3 also targets 3,6. Reproduce: press `1`, hover 3,6 → ghost shows the Bộ
  binh at 3,6 with 0 HP (2 damage then pushed off the bottom edge); **keep the pointer there** and press `2` (Lão) → `_select` (393) re-targets but
  `_preview_cell` is still 3,6, `refresh_hover()` emits nothing because the cell did not change
  (`battle_input.gd:102-105`), and `_on_cell_hovered(3,6)` → `_update_preview` returns at 279 — the Bộ
  binh ghost stays on screen. Lão's lance at 3,6 actually hits Khoái (3,5) for 1 (`rules_attack.gd:39-40`,
  confirmed by `test_battle_view.gd:915-923`). The player then attacks with Lão and the result does not
  match what the ghost said — the story's purpose ("tính đúng mà không phải hoàn tác") is defeated, and
  AC 2's promise is broken on screen. No test covers it; worse, the AC-4 test at `test_battle_view.gd:1154-1166`
  locks in the same guard without covering the general-switch case. A one-line reset of `_preview_cell`
  (or keying on `_selected` + cell) in `_select` fixes it.

## MEDIUM-1 — Ghost is not cleared when the attack animation starts (Task 3.3 not delivered)

- Violates: Task 3.3 (`[x]`, but "bóng mờ tắt khi … bắt đầu phát hoạt ảnh" is absent); the spirit of AC 3.
- Evidence: `game/src/battle/battle_view.gd:206-226` — `_on_events_resolved` sets `_playing = true` and
  awaits `_player.play`, with no `_clear_preview()`; `_on_cell_hovered` returns at `:261-262` before
  `_update_preview`, so nothing clears during playback; the only reset is `:253-256` inside
  `_finish_playback`, i.e. after the animation, plus `_hide_info` `:385-386` and `_deselect` `:419-421`.
  `main.gd:145-182` redraws the board only on `playback_finished`.
- Why: with real animation (headless is `instant`, `event_player.gd:22`) the ghost of the post-attack
  position stays on the board for the whole attack clip while the tokens still show the pre-attack
  positions — exactly the moment the task says it must hide. The suite cannot catch it: all preview tests
  run instant, and the existing non-instant test (`test_battle_view.gd:1189`) does not look at the preview.
  `_on_end_turn`'s `_deselect()` hides it for enemy-phase playback; only the player's own attack is affected.

## MEDIUM-2 — AC 1 / AC 6 visual acceptance is open and cannot be closed by the suite

- Violates: AC 1 and AC 6 acceptance (Task 5.2 is correctly left unchecked, but the story therefore cannot
  be accepted as done).
- Evidence: `story:51` (5.2 `[ ]`), `story:140` (admitted), `story:142-150` (guide steps 3–7 never run);
  no `anh/` directory and no `anh/2-12-*.png`; rendering lives in `preview_view.gd:42-78` (`_add_labels`
  builds Labels, `_draw` draws the disc/ring) and headless never calls `_draw`.
- Why: a `PreviewView` whose `_draw` is blank, or whose labels are misplaced, would still pass all 583
  tests — they assert `ghosts()` (`test_battle_view.gd:1145-1148`, `:1162-1165`, `:1174-1176`), never the
  rendered node. The Completion Note is honest about this, but AC 1 ("hiện bóng mờ") and AC 6 (legibility
  over red cells / under numbers) remain unproven until a human runs 5.2.

## LOW-1 — AC 2's comparison is narrower than the claim, and one task assertion cannot fail

- Violates: Task 4.3 / AC 2 test strength (not the AC).
- Evidence: `game/tests/board_fixture.gd:96-100` — `picture()` strings only `id@cell:hp:has_moved:has_attacked`;
  `test_battle_view.gd:1175-1180` compares only `ghosts[0]["hp"]` and hard-codes the destination cell
  (no comparison against `ghosts[0]["cell"]`, no extra-ghost check); `test_battle_controller.gd:361`
  asserts `can_undo()` is false when it was already false before the preview, so a `preview` that cleared
  `_undo_snapshot` would still pass.
- Why: a preview that diverges in telegraphs/round/phase, or that emits a wrong extra ghost, passes; and
  the "does not touch the undo snapshot" part of Task 1.1 is not actually exercised.

## LOW-2 — Declared defaults Q1/Q3 and the epics-required lance case have no test

- Violates: AC 1 coverage; the story's three open questions; `epics.md:665` ("bản xem trước (Story 2.12)
  phải hiện rõ" that the lance can hit your own general).
- Evidence: Q1 (dead unit → ghost at old cell, HP 0) exists at `battle_view.gd:308-310` + `:314-320` but is
  never asserted; Q3 (ghost visible while waiting for the confirmation click) exists only implicitly —
  nothing clears it in `_set_pending` (`:181-184`) or `_select` (`:393-402`) — and is untested; the
  lance-hits-own-general case would work through the diff (`_ghosts_of` sees Khoái lose HP at his own
  cell) but the only preview tests are the Khoái push (`test_battle_view.gd:1141-1150`, `:1169-1181`).
- Why: the three decisions the story asked the author to settle are implemented (Q1/Q2 explicitly, Q3 as a
  side effect) but the author's answers are recorded nowhere, and two of them plus a cross-story acceptance
  line have no test.

## LOW-3 — A stray unnamed `Node2D` is added to every board

- Violates: Task 2.3 / project rule "scene nhỏ và phẳng" (`project-context.md:40`).
- Evidence: `game/src/battle/board_view.gd:263` — `add_child(Node2D.new())` sits between `_preview`
  (:261-262) and `_target_layer` (:266); committed in `66c2108`; no reference anywhere; not in the story's
  File List.
- Why: dead node in every battle's scene tree; no visual effect, but it is accidental code committed
  unreviewed (the File List and Completion Notes do not mention it).

## LOW-4 — Task 5.3 is marked `[x]` while the author guide contains steps never run

- Violates: Task 5.3 ("đúng những bước đã chạy").
- Evidence: `story:52` (`[x]`); `story:142-150` — step 1 is `tools/test.sh`, steps 2–7 are the 5.2 manual
  checks (open the game, hover, see the ghost, click, compare); `story:140` says 5.2 was not done and there
  are no screenshots.
- Why: the guide is the author's deliverable and is fine as a guide, but the task's `[x]` claims it matches
  what was executed; only step 1 was executed. Same class of over-claim as the project's earlier false-`[x]` history.

## LOW-5 — Leftover `game/.bak_preview_view.gd` duplicates `class_name PreviewView`

- Violates: housekeeping (not in the File List, outside the commit).
- Evidence: untracked file (`git status`), 78 lines, first line `class_name PreviewView` — the same global
  class as `game/src/battle/preview_view.gd:1`; timestamp 22 s before the real file, commit `66c2108` at
  12:01:06. Also `story:132`'s "the leak was only a stale import cache" is a hypothesis with no evidence
  recorded.
- Why: not part of the diff, so it does not fail acceptance, but a duplicate global class is sitting in
  `game/`; if it is ever scanned, staged, or loaded it is a duplicate-class script error, and it is the
  simplest alternative explanation for the import trouble reported in the Debug Log.

**Findings: 1 HIGH, 2 MEDIUM, 5 LOW.**
