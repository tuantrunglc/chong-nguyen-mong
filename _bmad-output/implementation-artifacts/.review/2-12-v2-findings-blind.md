# Blind Hunter — Story 2.12, vòng 2 (diff ec9c3b8..f10d5d3, code-only)

Bản ghi rút gọn từ kết quả lớp review mù (không spec, không context). 8 phát hiện.

1. [HIGH] `battle_view.gd` `_select`: chỉ đặt `_preview_cell = NO_CELL`, không `_clear_preview()`/`_update_preview()` → bóng cũ còn trên bàn. **LOẠI: sai** — `_select` gọi `_on_cell_hovered(_input.hovered_cell())` ở cuối (ngoài hunk diff), nên `_update_preview` chạy lại ngay.
2. [MEDIUM] `board_view.gd` `show_state` gọi `_preview.clear()` nhưng không reset `BattleView._preview_cell` → lần hover lại đúng ô bị guard chặn. **HOÃN** (không có đường nào chạm tới hôm nay; ghi deferred-work).
3. [MEDIUM] `_ghosts_of`/`_ghost`: cell của quân chết lấy từ MOVED/DROWNED `to_cell` không kiểm biên → `terrain_at` ngoài mảng khi bị đẩy khỏi mép bàn. **LOẠI: sai** — `Effects.move`/`ForcedMove` chỉ phát ô trong bàn; quân bị đẩy khỏi mép không có MOVED (COLLIDED trước), nên rơi về `unit.cell` trong bàn.
4. [MEDIUM] `preview_result` dùng lại `_resolve` mà không cô lập RNG/counter → hover làm lệch kết quả thật. **LOẠI: sai** — `src/core/` không có RNG (grep `randi|randf|rand_from_seed` rỗng), lõi không ghi log, state không có counter.
5. [MEDIUM] Test thứ tự lớp so `preview_index` (con của BoardView) với `board._telegraph.numbers.get_index()` (con của TelegraphView). **LOẠI: sai** — `board_view.gd:266` `add_child(_telegraph.numbers)` → `numbers` là con của BoardView, phép so hợp lệ.
6. [LOW] `test_preview_does_not_touch_live_state`: `_events_seen` chỉ canh `events_resolved`. **LOẠI: nhiễu** (hành vi đúng, test đủ ý).
7. [LOW] Test AC 4 không phân biệt "bỏ qua" với "gọi nhưng bị từ chối". **LOẠI: nhiễu** (nhánh từ chối đã có test controller).
8. [LOW] `_ghosts_of` coi mọi quân vắng mặt là chết hp 0. **LOẠI: suy đoán** — hiện chỉ `Effects.damage`/chết đuối nhấc quân khỏi bàn.
