# Edge Case Hunter — Story 2.12, vòng 2 (diff ec9c3b8..f10d5d3)

Bản ghi rút gọn. 6 phát hiện; đã đọc thêm battle_view/controller/board_view/preview_view/unit_token/battle_input/battle_state/battle_event/telegraph_view/rules*/effects/forced_move + test. Không chạy test.

## F1 [MEDIUM] — Bóng quân chết ở ô khác ô xuất phát (chết đuối) không có test; nhánh DROWNED là code chết
`battle_view.gd:306-311`; test duy nhất về quân biến mất (`test_battle_view.gd:1259-1273`) chỉ là va chạm tại ô của chính nó. `Effects.move` phát MOVED trước rồi mới DROWNED, nên `elif DROWNED` không bao giờ đổi `last_cell`. Xoá nhánh MOVED thì 589 test vẫn xanh.
→ **SỬA**: thêm `test_preview_ghost_of_drowned_unit_sits_on_river_cell` + bỏ nhánh DROWNED thừa.

## F2 [MEDIUM] — Vị trí số máu của bóng `moved == false` không test nào chạm tới
`preview_view.gd` (dòng `hp_center`). Revert về góc dưới–phải thì 589 test vẫn xanh vì `ghosts()` chỉ trả dictionary, không có accessor cho `Label`.
→ **SỬA**: thêm `test_preview_hp_label_stays_inside_its_cell` (đọc tâm `Label`, đòi nằm trong `cell_rect`).

## F3 [LOW] — Lớp bóng nằm TRÊN ô đỏ, trái comment "ô đỏ + số vẫn nổi nhất"
`board_view.gd:253-266` (telegraph thêm trước, `_preview` sau `_world`); claim ở `preview_view.gd:5`. Đĩa alpha 0,5 tô đè giữa ô đỏ; số thứ tự vẫn trên cùng.
→ **SỬA**: sửa chú thích cho khớp (bóng trên ô đỏ, dưới viền mục tiêu và số).

## F4 [LOW] — `preview_result` nuốt lỗi bất biến, không log
`battle_controller.gd:50-51` so với `submit` (log ERROR từng problem). `clone()` thiếu field mới → mọi hover mất bóng, log sạch.
→ **SỬA**: log problems trước khi trả `{}`.

## F5 [LOW] — Một assert không thể fail
`test_battle_controller.gd:361` `assert_false(c.can_undo())` khi `_attack_controller()` chưa submit gì. → **LOẠI** (test kế tiếp đã phủ hành vi thật).

## F6 [LOW] — Sau mỗi lượt phát, cùng một ô bị tính 2 lần
`battle_view.gd:247` + `409/418` so với `255-258`: `_select` đã tính #1, dòng 255 xoá memo, dòng 258 tính #2.
→ **SỬA**: bỏ dòng 255.

## Đã kiểm, không thấy lỗi
Hover state machine (không có đường để bóng cũ nằm lại), clone/replay (stats chia sẻ nhưng read-only, không RNG, không đụng `_undo_snapshot`), ghost derivation (hai vòng lặp rời nhau, đúng cho quân vừa dời vừa mất máu / bị kéo / friendly-fire / quân chắn), rendering/lifecycle (position/lift khớp UnitToken, label gỡ khỏi cây trước `queue_free`).
