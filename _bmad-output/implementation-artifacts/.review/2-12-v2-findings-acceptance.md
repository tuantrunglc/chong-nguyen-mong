# Acceptance Auditor — Story 2.12, vòng 2 (diff ec9c3b8..f10d5d3)

Bản ghi rút gọn. 7 phát hiện (0 HIGH, 2 MEDIUM, 5 LOW). Đã chạy `tools/test.sh` (589/589), chạy riêng test_battle_view (79/79) và test_battle_controller (23/23), đo pixel trên 14 ảnh bằng PIL.

## A1 [MEDIUM] — Số đo ảnh trong Dev Agent Record không khớp ảnh đã lưu
Story dòng 123: "tương phản 5,56:1"; dòng 141: "đĩa (89,85,78) trên nền ô (237,222,186)".
Đo `anh/2-12-10`: 1297 px màu (140,136,129) = 0,5·NGUYEN + 0,5·CELL → tương phản thật **2,65:1**. `(89,85,78)` có đúng 1 px trong cả ảnh. `2-12-7`: đĩa (84,116,147) trên sông (125,181,222) → 2,22:1.
→ **SỬA**: đã sửa số ở dòng 123, 141 và "13 ảnh" → 14.

## A2 [MEDIUM] — Nhánh "quân chết đuối → bóng ở ô cuối" không có test
`battle_view.gd:306-311` + `:319-323`. 8 test xem trước chỉ dùng 3 bàn không có sông. Ảnh 2-12-7 xác nhận hành vi có thật nhưng chỉ là bằng chứng ảnh.
→ **SỬA**: thêm test (xem edge F1).

## A3 [LOW] — Tính lại 2 lần cho cùng một ô sau khi phát xong
`battle_view.gd:253-258`. → **SỬA** cùng edge F6.

## A4 [LOW] — Test AC 4 gọi thẳng `_on_cell_hovered`, trái ghi chú Testing của story
`test_battle_view.gd:1177-1189`; `BattleInput._set_hovered` đã lọc trùng ô. → **LOẠI**: cố ý, có comment giải thích; đường chuột thật đã có test khác.

## A5 [LOW] — Bóng của quân đứng tại chỗ không có đĩa nhìn thấy
0,5·C + 0,5·C = C khi bóng nằm trên đồng cùng màu phe. Đo 2-12-2: 0 px màu (111,42,52); chỉ có chữ trắng mờ + vòng sáng.
→ **QUYẾT ĐỊNH** (gộp với phát hiện vị trí số máu): tác giả chốt bỏ tên trên bóng, dời số máu vào trong ô.

## A6 [LOW] — AC 2 chỉ so quân, hai vế cùng do một `_resolve` sinh ra
`BoardFixture.picture()` không có phase/round/telegraphs. → **LOẠI**: test view so bóng với bàn thật sau khi đánh là bằng chứng độc lập.

## A7 [LOW] — Story ghi "13 ảnh" nhưng có 14 file
→ **SỬA** cùng A1.

## Bảng kết luận (trước khi sửa)
| AC | Kết quả | Lý do |
|---|---|---|
| 1 | ĐẠT MỘT PHẦN | đúng ô/máu; chết đuối thiếu test |
| 2 | ĐẠT | hai test so khớp |
| 3 | ĐẠT | rê ra là mất bóng |
| 4 | ĐẠT | có đếm; chỉ thừa một lần |
| 5 | ĐẠT | clone, không signal, core sạch |
| 6 | ĐẠT | thứ tự lớp có test |
| 7 | ĐẠT | ba nhóm test qua main.tscn |

## Đã kiểm và đạt
ADR-005 (clone, không signal, không đụng `_undo_snapshot` — có test), `src/core/` không bị sửa, ranh giới `.hp`/`.cell`, chữ qua `tr()`, typed GDScript, không `print`/`Thread`, không `_process`.
