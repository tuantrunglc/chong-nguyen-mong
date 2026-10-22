# Blind Hunter findings (Story 2.12)

Scope note: the only input was `.review/2-12-diff.patch`. Line numbers are for the post-image, reconstructed from the hunk headers (`@@ -a,b +c,d @@`); nothing outside the patch was opened. Anything the patch references but does not show (`_select`, `_resolve`, `BattleState.clone`, `UnitToken`, `BattleInput.refresh_hover`, `surface_height`, the telegraph layer placement) is unverifiable and is called out where it matters.

## medium — Preview cache is keyed on the cell only, and is marked "computed" before the computation is known to have succeeded

- Where: `game/src/battle/battle_view.gd:278-287`
- Evidence:
  ```
  	if cell == _preview_cell:
  		return
  	_preview_cell = cell
  	_preview_count += 1
  	var before: BattleState = _controller.snapshot()
  	var after: BattleState = _controller.preview(Command.attack(_selected, cell))
  	if after == null:
  		_board.preview_view().clear()
  		return
  ```
  The only resets are `_clear_preview()` (`_preview_cell = BoardView.NO_CELL`), `start()` (`_preview_cell = BoardView.NO_CELL`), `_finish_playback()` (`_preview_cell = BoardView.NO_CELL`), `_hide_info()` and `_deselect()` (both via `_clear_preview()`).
- Why it fails: the cached fact is "ghosts for `cell` are current", but the key says nothing about *which general and which state* produced them. Two consequences are visible in the patch text:
  1. Wrong general. Select general A, park the cursor on enemy E (hover computes, `_preview_cell = E`). Keyboard selection is the tested path (`_press_physical(main, KEY_1)`), and keyboard selection needs no mouse motion, so no hover event follows. `_update_preview` is new in this diff, so unchanged code (the `_select` path is not in the diff at all) cannot be calling it; nothing here invalidates the cache on a selection change. If the selection path does not go through `_deselect()`, the ghosts keep showing general A's result while a click on E issues `Command.attack(_selected /* = B */, E)`; if B cannot reach E, that command is rejected — the exact `after == null` branch above — so the screen promises damage that can never happen. (If the selection path *does* call `_deselect()`/`_input.refresh_hover()`, this branch is saved; the patch cannot settle it, but the diff adds no hook either way.)
  2. Poisoned cell. When `after == null`, only the layer is cleared; `_preview_cell` still equals `cell`. Every later hover on that same cell short-circuits at the `cell == _preview_cell` test, so a rejected preview is cached permanently for that cell and can never be retried without first hovering a different cell. The same line also increments `_preview_count` for a computation that produced nothing, so `preview_computations()` no longer means "previews computed" (AC 4 metric).
- Fix: invalidate the preview wherever `_selected`/`_targets` change (call `_clear_preview()` in the selection path), and assign `_preview_cell` only after `after != null` (clear it before the `return` on rejection).

## low — A unit that loses HP without changing cell gets a ghost drawn exactly on top of the live token

- Where: `game/src/battle/battle_view.gd:298-300`, `game/src/battle/preview_view.gd:42-52` and `70-77`
- Evidence:
  ```
  		if old.cell == unit.cell and old.hp == unit.hp:
  			continue
  		ghosts.append(_ghost(unit.cell, unit, after))
  ```
  ```
  	var center: Vector2 = pos + Vector2(0.0, -UnitToken.TOKEN_LIFT)
  ...
  	_add_label(str(hp), center + UnitToken.HP_OFFSET, HP_FONT_SIZE, Color(1.0, 1.0, 1.0, GHOST_ALPHA))
  ...
  		draw_circle(pos + Vector2(0.0, -UnitToken.TOKEN_LIFT), UnitToken.RADIUS, color)
  ```
- Why it fails: the code explicitly handles "same cell, different HP" and then draws the ghost with the token's own anchors (`TOKEN_LIFT`, `UnitToken.RADIUS`, `UnitToken.HP_OFFSET`). At an unchanged cell the ghost disc covers the live token and its HP label lands on the token's own HP label, so the player reads two numbers in the same pixels (one opaque, one at 50% alpha) plus a tinted disc over the unit. The ghost stops reading as "a result" and starts hiding the "before" value. Trigger: any damaged unit that does not move (blocked/edge push, or the attacker taking damage) — the rules that decide this are not in the patch.
- Fix: when the cell is unchanged, suppress/dim the live token's own HP label for that cell, or offset the ghost's HP text instead of stacking it on the token's.

## low — `_clear_labels()` defers deletion while replacements are added in the same call, so stale and new labels coexist for the rest of the frame

- Where: `game/src/battle/preview_view.gd:16-21` and `37-39`
- Evidence:
  ```
  func show_ghosts(ghosts: Array[Dictionary]) -> void:
  	_clear_labels()
  	_ghosts = ghosts.duplicate(true)
  	for ghost: Dictionary in _ghosts:
  		_add_labels(ghost)
  	queue_redraw()
  ```
  ```
  func _clear_labels() -> void:
  	for child: Node in get_children():
  		child.queue_free()
  ```
- Why it fails: `queue_free()` removes the node at the end of the current frame, not at the call. `show_ghosts()` immediately `add_child`s the new labels, so until the deferred queue flushes the layer owns both sets: several mouse-motion events can deliver more than one hovered cell in a single frame, and each one rebuilds the labels; for that frame the old ghosts' name/HP labels are still children at their old positions alongside the new ones. The node also reports inflated `get_child_count()` for any same-frame check.
- Fix: detach synchronously (`remove_child(child)` then `queue_free()`, or `child.free()` here) before adding the replacements.

## low — `preview()` skips the invariant check/rollback that `submit()` documents, so it can return a state the game will discard

- Where: `game/src/battle/battle_controller.gd:42-49` (against the `submit()` contract at `:52-54`)
- Evidence:
  ```
  func preview(command: Command) -> BattleState:
  	if _state == null:
  		return null
  	var copy: BattleState = _state.clone()
  	var events: Array[BattleEvent] = _resolve(copy, command)
  	if _rejection(events) != null:
  		return null
  	return copy
  ```
  ```
  ## Chạy lệnh. Bị từ chối: state không đổi, bản chụp hủy giữ nguyên, không phát signal.
  ## Làm hỏng bất biến: ghi log ERROR, quay về trước lệnh, phát rolled_back, trả [].
  ```
- Why it fails: `submit()` has two rejected outcomes — a rejection event, and a broken invariant that is rolled back and returns `[]`. `preview()` only tests `_rejection(events)`, so a command that resolves but breaks an invariant returns a mutated copy; the view then shows ghosts for a result `submit()` would throw away. Reachability for a normal attack is not shown in the patch (the invariant predicate is not visible), so this is a divergence between the two entry points rather than a demonstrated wrong ghost.
- Fix: run the same invariant validation `submit()` uses and return `null` (no ghosts) when it fails.

## low — Stray unnamed `Node2D` created in the preview layer stack

- Where: `game/src/battle/board_view.gd:260-266`
- Evidence:
  ```
  	# Bóng mờ xem trước đòn (Story 2.12): trên đồng quân, dưới viền mục tiêu và lớp số thứ tự đòn.
  	_preview = PreviewView.new()
  	add_child(_preview)
  	add_child(Node2D.new())
  	_target_layer = Node2D.new()
  	_target_layer.draw.connect(_draw_targets)
  	add_child(_target_layer)
  ```
- Why it fails: an unnamed, unreferenced `Node2D` is created between the ghost layer and the target layer. It draws nothing, sorts nothing and is referenced by nothing — it only adds a node to every `BoardView` and makes the sibling order look deliberate when it is not. It also means the order promised by the comment ("dưới viền mục tiêu và lớp số thứ tự đòn") is not established by anything in the patch: if the attack-order number layer lives inside `_telegraph` (declared as "Ô đỏ báo đòn (dưới đồng quân) và lớp số thứ tự của nó (trên cùng…)"), a ghost layer added after `_telegraph` would paint over those numbers — where `_telegraph` is added cannot be seen here.
- Fix: delete the empty node and place `_preview` relative to a named layer whose order is explicit (or verify `_telegraph`'s insertion point before relying on the comment).

## Verified-clean areas

- **No live-state mutation or aliasing through the preview.** `preview()` clones, resolves on the copy, and returns the copy; `_ghosts_of`/`_ghost` only read `before`/`after` and build fresh dictionaries of primitives (`cell`, `pos`, `type`, `hp`, `faction`), which `show_ghosts()` deep-duplicates. Nothing in the new view code holds a `BattleState`/`Unit` reference, so the ghost layer cannot write back into the live battle.
- **Ghost lifetime across battles and commands.** `start()` (`battle_view.gd:71`), `_finish_playback()` (`:253`), `_hide_info()` (`:385`), `_deselect()` (`:418`) and `BoardView.show_state()` (`board_view.gd:278`) all clear the layer and/or reset `_preview_cell`, so on those paths ghosts cannot leak from the previous battle, from a previously selected general after a command, or from a re-synced board. Labels are children of `PreviewView`, so a freed board cannot orphan them.
- **Guard coverage for empty/null inputs in `_update_preview`.** `_board == null`, `_controller == null`, `_selected == NONE`, non-target cells and `_playing` all take the `_clear_preview()` branch (and `_clear_preview` itself null-checks `_board`), so hovering with nothing selected or before a controller exists cannot compute or crash.
- **Ghost computation is skipped, not performed, on every non-target hover.** The `_targets.has(cell)` test runs before `snapshot()`/`preview()`, so the two full state clones plus `_resolve` happen only when the hovered cell actually changes to a valid target — no per-frame cost, and no preview is computed while an animation plays.
