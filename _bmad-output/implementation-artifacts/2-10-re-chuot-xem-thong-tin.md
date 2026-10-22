---
baseline_commit: 7790797
---

# Story 2.10: Rê chuột xem thông tin

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

Là người chơi,
tôi muốn rê chuột lên quân và ô để xem thông tin,
để không phải nhớ chỉ số.

## Acceptance Criteria

1. **Khi** rê chuột lên một quân **Thì** hiện tên quân, máu hiện tại / máu tối đa, đòn sắp đánh của nó (nếu có) và số thứ tự ra đòn (FR40).
2. **Khi** rê chuột lên một quân Nguyên đã báo đòn **Thì** các ô đỏ của **chính quân đó** được làm nổi bật, ô đỏ của đòn khác giữ nguyên.
3. **Khi** rê chuột lên một ô **Thì** hiện tên loại địa hình và hiệu ứng của nó; mọi chữ lấy từ `game/i18n/text.csv` qua `tr()`, không viết chuỗi trong code.
4. **Khi** chuột rời khỏi bàn (hoặc ra khỏi cửa sổ) **Thì** khung thông tin ẩn đi, không để lại khung rỗng. Ô trống **trong bàn** vẫn hiện tên địa hình và hiệu ứng theo AC 3 (tác giả chốt 2026-10-22, sửa lại AC 4 vốn mâu thuẫn với AC 3).
5. **Và** khung thông tin không chặn bấm chuột: bấm vào ô vẫn ra đúng lệnh như trước.
6. **Và** khung nằm gọn trong màn hình 1280×720, không che quân đang trỏ khi còn chỗ khác.
7. **Và** màu/nét của ô đỏ nổi bật phải khác hẳn ô đỏ thường (NFR9: ô đỏ là thứ nổi bật nhất; nổi bật kép phải đọc được ngay).
8. **Và** test giao diện chạy được không cần màn hình qua `main.tscn` (như các test view hiện có), không thêm test cho phần chỉ nhìn thấy bằng mắt.

## Tasks / Subtasks

- [x] **Task 1: Chuỗi tiếng Việt** (AC: 1, 3)
  - [x] 1.1 Thêm vào `game/i18n/text.csv`: `unit.full.<loại>` (6 loại, tên đầy đủ), `tooltip.hp`, `tooltip.attack_cell`, `tooltip.attack_charge`, `tooltip.no_attack`, `terrain.plain`, `terrain.effect.<địa hình>` (7 địa hình). Số thứ tự ra đòn nằm luôn trong hai câu đòn, không tách khóa `tooltip.order` (review 2026-10-22 ghi lại tên khóa thật).
  - [x] 1.2 Chạy `--headless --import` để sinh lại `game/i18n/text.vi.translation`; kiểm file mới có trong git.
- [x] **Task 2: Khung thông tin** (AC: 1–6)
  - [x] 2.1 File mới `game/src/ui/tooltip.gd`: `PanelContainer` + `Label`, dựng bằng code (scene phẳng, không mở editor). API: `show_text(text: String)`, `hide_tooltip()`, `place_at(anchor: Vector2)`, `text()`, `visible_now()` cho test.
  - [x] 2.2 `main.gd` tạo khung và `add_child` sau bàn cờ/HUD, trước bảng Thắng/Thua (vẽ trên bàn, dưới bảng kết quả), `mouse_filter = IGNORE` để bấm xuyên qua. Không đặt trong `main.tscn` vì scene chỉ có node gốc.
  - [x] 2.3 Kẹp vị trí trong `get_viewport_rect().size` (1280×720) và lệch khỏi con trỏ một khoảng nhỏ; nếu sát mép phải/dưới thì lật sang trái/trên.
- [x] **Task 3: Nối chuột** (AC: 1–5)
  - [x] 3.1 `BattleView`: dùng `BattleInput.cell_hovered` sẵn có (đừng thêm signal mới). Trong `_on_cell_hovered`: nếu ô có quân → dựng chữ từ snapshot (`unit.name`, `hp/max_hp`, đòn đã báo của quân đó nếu có: ô đích hoặc hướng xung phong, số thứ tự); nếu ô trống nhưng trong bàn → tên địa hình + hiệu ứng; ngoài bàn → ẩn.
  - [x] 3.2 Ô đỏ của đòn đã báo của chính quân đang trỏ: lấy từ `TelegraphMarks.path_cells(state, t)` cho các `Telegraph` có `owner_id` = quân đó (một chỗ tính, không tự suy lại ô).
  - [x] 3.3 Ẩn khung khi: chuột ra ngoài bàn, trận kết thúc, hoặc `stop()`. Không để khung của trận cũ dính sang trận mới.
- [x] **Task 4: Làm nổi bật ô đỏ** (AC: 2, 7)
  - [x] 4.1 `TelegraphView`: thêm `highlight(cells: Array[Vector2i])`, `highlighted() -> Array[Vector2i]`; vẽ ô nổi bật bằng màu/nét khác (ví dụ nền sáng hơn + viền trắng dày hơn), giữ nguyên số thứ tự.
  - [x] 4.2 `BattleView` gọi `highlight` mỗi lần hover đổi; hover sang quân khác thì thay danh sách, hover ra ngoài thì rỗng.
- [x] **Task 5: Test giao diện** (AC: 1–5, 8)
  - [x] 5.1 `game/tests/test_battle_view.gd`: rê chuột lên tướng → khung hiện đúng tên + máu; rê lên quân Nguyên đã báo đòn → có số thứ tự và đúng đòn của nó; rê lên ô sông → hiện "Sông" và hiệu ứng; rê ra ngoài bàn → ẩn.
  - [x] 5.2 Test nổi bật: rê lên quân Nguyên có đòn → `highlighted()` đúng các ô của quân đó; rê sang quân khác → đổi; rê ra ngoài → rỗng.
  - [x] 5.3 Test bấm xuyên qua khung: khung đang hiện, bấm vào ô → lệnh vẫn tới (không bị khung nuốt).
- [ ] **Task 6: Kiểm bằng mắt, tài liệu, commit** (AC: 1–8)
  - [ ] 6.1 (chưa đánh [x]: không có ảnh, tác giả chốt done mà chưa kiểm bằng mắt) `tools/test.sh` xanh; `tools/chay.sh --dev --tran=thu_lao`, rê chuột lần lượt lên Khoái, lên Bộ binh đang báo đòn, lên ô sông, ra ngoài bàn. Chụp ảnh bằng `capture_screenshot` nếu chạy được (phiên trước lỗi lưu file), lưu `anh/2-10-*.png`; không có ảnh thì **không đánh [x]**.
  - [x] 6.2 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes. Phiên AI chưa chạy lại từng bước trên game (gộp vào 6.1 của tác giả) — review 2026-10-22 sửa lại câu chữ cho đúng.
  - [x] 6.3 Commit tiếng Việt kết `(Story 2.10)`.

## Dev Notes

### Hiện trạng liên quan (đọc trước khi sửa)

- `game/src/battle/battle_input.gd` đã có `signal cell_hovered(cell)` và `hovered_cell()`; `BattleView._on_cell_hovered` đang dùng nó để vẽ đường đi. **Chỉ mở rộng hàm này**, không thêm đường bắt chuột thứ hai.
- `game/src/battle/battle_view.gd`: `setup(board, input, hud)`, `start(controller)`, `stop()`, `_deselect()`. Khung thông tin nên do `BattleView` sở hữu (nó đã biết snapshot), hoặc `Hud` — chọn một chỗ, đừng cả hai.
- `game/src/battle/telegraph_view.gd`: `_cells` (ô → số thứ tự), `_draw_red` dùng `FILL_COLOR`/`BORDER_COLOR`. Thêm nổi bật ở đây, **không** vẽ lớp thứ hai chồng lên.
- `game/src/battle/board_view.gd`: `cell_at(local_pos)`, `pick_cell`, `cell_center`, `cell_rect`; `tokens()` để biết ô nào có quân.
- `game/src/ui/hud.gd`: mẫu dựng Control bằng code + `tr()`; bám theo cách làm đó (font, theme mặc định của project).
- `game/src/core/telegraph_marks.gd`: `path_cells(state, t)` và `hit_cell` là nơi duy nhất tính ô đỏ/ô trúng (Story 2.7, 2.9).

### Luật kiến trúc phải theo

- **Không đụng `src/core/`**: story này chỉ hiển thị. Nếu thấy cần thêm hàm vào core, dừng lại và hỏi.
- Chữ hiển thị chỉ qua `tr()`; khóa mới vào `text.csv`, sinh lại `text.vi.translation`.
- Đi xuống gọi hàm, đi lên phát signal; không Event Bus. `AppState` vẫn là autoload duy nhất.
- Khung thông tin **chỉ đọc** snapshot; không giữ tham chiếu state sống, không sửa gì.
- Bật dev bằng `--dev`; F1/F2/F3/F5 vẫn không có tác dụng khi không bật dev (không liên quan nhưng đừng nới).
- Bàn tối đa 10×8; không lặp cứng cỡ bàn.

### Testing

- `tools/test.sh` là lệnh duy nhất; test GUT qua `main.tscn` thật, trận thử ghi vào `user://`, xóa ở `after_each`.
- Chạy một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_battle_view.gd -gexit`.
- Trong môi trường phiên AI có sandbox: phải đặt `XDG_DATA_HOME=/tmp/dsh-xdg` (hoặc thư mục ghi được) trước `tools/test.sh`, nếu không 64 test dùng `user://` sẽ trượt vì `FileAccess` null. Không phải lỗi code.
- Rê chuột trong test: dùng `InputEventMouseMotion` như các test hiện có (`_press_physical`, `_click_by_mouse`), không gọi thẳng hàm private để test còn bắt được lỗi nối dây.

### Previous Story Intelligence (2.9, 2.7)

- 2.9 vừa đổi luật: **hết trận thì `telegraphs` bị xóa**, nên lúc thắng/thua không còn ô đỏ để nổi bật. Khung thông tin phải ẩn hoặc chỉ hiện phần quân/địa hình khi trận đã hết.
- `TelegraphView.show_state` dựng lại nhãn số mỗi lệnh; `highlight` phải sống qua `show_state` hoặc được gọi lại sau mỗi lệnh, nếu không sẽ mất khi bấm.
- 2.7 từng ghi sai `mo_ta` và sai hình học kịch bản; 2.9 bị code review bắt vì đánh [x] khống. Đừng đánh [x] task chụp ảnh khi chưa có file ảnh.
- GoPeak `capture_screenshot` trả `Failed to save screenshot as PNG: 7` trong phiên AI (addon lưu file vào đường dẫn không ghi được), dù game chạy được. Tác giả tự chụp được.

### Git Intelligence

- Commit gần nhất: `7790797 Đóng Story 2.9 sau code review`, `edf9f49 Sửa theo code review Story 2.9`, `e8ad1e8 Đòn địch dịch theo và hủy đòn (Story 2.9)`.
- Mẫu: một commit story/kịch bản, một commit code; lời tiếng Việt, kết `(Story X.Y)`.
- Cây làm việc có thay đổi ngoài story (hình E8 trong `img/`, `.agents/` symlink skill BMAD): **không gộp** vào commit.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, cú pháp Godot 4; GUT 9.7.1; web đơn luồng (không `Thread`).
- `src/core` là vùng cấm với story này; chỉ `Effects.damage`/`Effects.move` đổi máu/vị trí.
- Một cú bấm chuột phải làm được mọi thao tác; rê chuột chỉ để xem, không được là cách duy nhất để chơi.
- Độ phân giải 1280×720, stretch `canvas_items`, aspect `keep`; font tiếng Việt đủ dấu.
- Commit khi test xanh, lời commit tiếng Việt.

### Câu hỏi cho tác giả (chốt trước khi code xong)

- Rê lên quân **chưa báo đòn** thì dòng "đòn sắp đánh" ghi "không có đòn" hay ẩn hẳn dòng đó? (mặc định: ghi "không có đòn")
- Khung thông tin hiện **theo con trỏ** hay cố định một góc màn hình? (mặc định: theo con trỏ, lật khi sát mép)
- Ô đỏ nổi bật: đổi màu nền sáng hơn hay thêm viền trắng? (mặc định: viền trắng dày hơn + nền sáng hơn một chút, giữ đỏ)

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.10 (dòng 806–818), FR40, NFR9.
- `_bmad-output/planning-artifacts/game-architecture.md` "UI và HUD", "Pha địch", M1/M3.
- `_bmad-output/project-context.md` (Input, độ phân giải, chữ qua `tr()`).
- `game/src/battle/battle_input.gd`, `battle_view.gd`, `board_view.gd`, `telegraph_view.gd`, `game/src/ui/hud.gd`, `game/i18n/text.csv`.

## Dev Agent Record

> Sau code review 2026-10-22: 6 mục Patch đã sửa, test 570/570 đạt. Tác giả chốt `done` cùng ngày. Task 6.1 (kiểm bằng mắt) **vẫn để trống** cho đúng sự thật: phiên AI không chụp được ảnh (`capture_screenshot` lỗi lưu file) và không có ảnh `anh/2-10-*.png`; khung đã được đo bằng Godot headless (162×85 px cho 3 dòng, 340×157 px cho dòng dài) nhưng chưa ai nhìn tận mắt.

### Review Findings

Code review 2026-10-22 (Blind Hunter + Edge Case Hunter + Acceptance Auditor, diff `7790797..b874ecd`).
Cả 6 mục Patch đã sửa trong cùng ngày; `tools/test.sh` 570/570 đạt sau khi sửa. Còn lại: tác giả kiểm bằng mắt (Task 6.1).

- [x] [Review][Decision] AC 4 mâu thuẫn với AC 3 và Task 3.1 — AC 4 nói "rê sang ô trống thì khung ẩn", nhưng AC 3 / Task 3.1 / Task 5.1 đòi ô trống **trong bàn** hiện tên địa hình và hiệu ứng; code đang theo AC 3 (`battle_view.gd:186`). **Tác giả chốt 2026-10-22:** viết lại AC 4 thành "rời khỏi bàn thì khung ẩn"; giữ hành vi đang có. → việc sửa lời nằm trong mục Patch về ghi chép.
- [x] [Review][Decision] Bốn trong bảy dòng hiệu ứng địa hình dạy luật bản này chưa có — "Đi qua mất máu" (hầm chông, Story 3.4), "Quân Nguyên đứng kề thì hồi máu" (kho lương, 3.9), "Đánh vào làng thì mất Lòng dân" (3.7), "Quân Nguyên vào ải thì thua" (3.11). Hôm nay hầm chông chỉ đi được mà không mất máu, kho lương/làng không hồi máu hay trừ Lòng dân, `rules_victory.gd:35` chỉ xét `ELIMINATE`. **Tác giả chốt 2026-10-22:** giữ lời thiết kế; ghi vào `deferred-work.md` để rà lại khi 3.4/3.7/3.9/3.11 xong.
- [x] [Review][Decision] Hết trận thì khung vẫn hiện — Task 3.3 ghi "ẩn khi trận kết thúc" và lời commit `b874ecd` cũng nói vậy, nhưng nhánh `Rules.is_battle_over` lại gọi `_update_info(hovered_cell)` (`battle_view.gd:149-153`), tức là hiện khung sau khi thắng/thua; Dev Notes lại cho phép "ẩn **hoặc** chỉ hiện phần quân/địa hình". **Tác giả chốt 2026-10-22:** ẩn hẳn khi hết trận. → thành mục Patch bên dưới.
- [x] [Review][Patch] Khung thông tin bị bóp còn 17 px — đo bằng Godot 4.7.2 headless: `show_text("Quân Nguyên đứng kề thì hồi máu")` cho `PANEL size=(17.0, 637.0)`, `LABEL size=(1.0, 621.0)`, 26 dòng, mỗi dòng một ký tự. Nguyên nhân: `Label` bật `autowrap_mode` mà không có bề rộng, `Label.get_minimum_size()` trả width 1, `MAX_WIDTH = 340.0` khai mà không dùng (`tooltip.gd:46`), cha là `Node2D` nên không Container nào cấp bề rộng. [game/src/ui/tooltip.gd:46,68-76]
- [x] [Review][Patch] Kỵ binh vẫn báo "Xung phong hướng …, đòn số N" khi đường xung phong đã rỗng — `_attack_text` trả về ở nhánh `DIRECTION` trước khi kiểm `hit_cell == NO_CELL`; bị đẩy cho ô đầu ra ngoài bàn thì `path_cells` rỗng nên không còn ô đỏ, nhưng khung vẫn hứa đòn (và luật sẽ hủy đòn đó). [game/src/battle/battle_view.gd:200-210]
- [x] [Review][Patch] Test AC 5 không thể trượt — `_click_by_mouse` gọi thẳng `_battle_input._unhandled_input(click)`, bỏ qua bước Godot chia sự kiện cho GUI, nên khung `MOUSE_FILTER_STOP` vẫn "đạt"; thêm assert `mouse_filter == IGNORE` hoặc đẩy sự kiện qua `get_viewport().push_input`. [game/tests/test_battle_view.gd:664]
- [x] [Review][Patch] `_on_events_resolved` không `refresh_hover()` trước khi cập nhật khung — sau lệnh đẩy/kéo, `pick_cell` tính theo bàn cũ nên khung có thể tả ô không còn nằm dưới chuột; `_select` đã làm đúng ở `:236-237`. [game/src/battle/battle_view.gd:163]
- [x] [Review][Patch] Hết trận vẫn hiện khung — nhánh `Rules.is_battle_over` gọi `_update_info(hovered_cell)` thay vì ẩn; sửa thành ẩn khung + xóa nổi bật (tác giả chốt 2026-10-22). [game/src/battle/battle_view.gd:149-153]
- [x] [Review][Patch] Story ghi không khớp code: Task 1.1 đòi `tooltip.unit.*` + `tooltip.order` nhưng code dùng `unit.full.*` và gộp số thứ tự vào `tooltip.attack_cell/attack_charge`; Task 2.1 đòi `move_to(pos)` nhưng code là `place_at(anchor)`; Task 2.2 đòi đặt khung trong `main.tscn` nhưng code tạo trong `main.gd:56-57` (thứ tự vẽ vẫn đúng); Task 6.2 đánh [x] trong khi Completion Notes giao bước 3–7 cho tác giả; file có hai heading `## Dev Agent Record`. [story]
- [x] [Review][Defer] Không test nào đọc kích thước/vị trí khung, chỉ test chữ — AC 8 cấm test phần chỉ nhìn thấy bằng mắt, nên giữ kiểm tay. — deferred, giữ theo lệ AC 8.

### Agent Model Used

deepseek-flash (DeepSeek Harness), phiên 2026-10-22.

### Debug Log References

- Lỗi đầu tiên: `tooltip.attack_cell` khai trong `text.csv` có dấu phẩy không bọc ngoặc, nên CSV cắt mất phần "đòn số %d"; `%` thiếu tham số sinh "Method/function failed" và 3 test báo Unexpected Errors. Sửa bằng bọc ngoặc kép cho 3 dòng có dấu phẩy.
- `Tooltip.show_text` bản đầu tự đặt `size`/`custom_minimum_size` cho container, sinh lỗi engine; đã bỏ, chỉ `reset_size()`.
- `tools/test.sh`: 569/569 đạt, 81 kịch bản.

### Completion Notes List

- Khung thông tin: `game/src/ui/tooltip.gd` (PanelContainer dựng bằng code, `mouse_filter = IGNORE`), `main.gd` tạo và truyền vào `BattleView.setup`.
- Rê chuột: mở rộng `BattleView._on_cell_hovered` (dùng `cell_hovered` sẵn có). Quân: tên đầy đủ, máu hiện tại/tối đa, đòn đã báo + số thứ tự (ô đích hoặc hướng xung phong). Ô: tên địa hình + hiệu ứng. Ngoài bàn: ẩn.
- Nổi bật: `TelegraphView.highlight(cells)`, viền trắng + nền sáng hơn; chỉ ô của chính chủ đòn đang trỏ. Tính lại sau mỗi lệnh để đòn dịch theo / bị hủy không để lại ô sáng sai.
- **Chưa chụp ảnh (6.1)**: GoPeak `capture_screenshot` vẫn lỗi lưu file như Story 2.9; tác giả kiểm tay theo hướng dẫn dưới đây.

**Hướng dẫn tác giả tự test:**

1. Gõ `tools/test.sh`. Thấy `569/569 test đạt` và `81 đã duyệt`.
2. Gõ `tools/chay.sh --dev --tran=thu_lao`.
3. Rê chuột lên Khoái: khung hiện "Nguyễn Khoái", "Máu 3/3", "Không có đòn nào".
4. Rê lên một Bộ binh đang có ô đỏ: khung hiện tên, máu, "Đánh ô …, đòn số 1"; **ô đỏ của nó sáng hơn, viền trắng**; ô đỏ của đòn khác giữ nguyên.
5. Rê sang quân khác: ô sáng đổi theo. Rê ra ngoài bàn: khung ẩn.
6. Rê lên ô sông / rừng / kho: hiện tên và hiệu ứng.
7. Vẫn bấm đánh bình thường khi khung đang hiện.

**Sau code review (2026-10-22):**

- Khung thông tin trước đây bị bóp còn 17×637 px (chữ một ký tự một dòng) vì `Label` bật autowrap mà không có bề rộng. Nay `Tooltip._fit_width` đặt bề rộng theo dòng dài nhất, chặn ở `MAX_WIDTH` 340; đo lại: 3 dòng = 162×85, dòng dài = 340×157 (xuống 3 dòng).
- Kỵ binh: chỉ báo "xung phong" khi `TelegraphMarks.hit_cell` còn ô (đòn chưa bị hủy).
- Hết trận: `_update_info` ẩn khung + bỏ nổi bật; `stop()` dùng chung `_hide_info()`.
- `_on_events_resolved` gọi `refresh_hover()` trước khi cập nhật khung.
- Test AC 5 giờ đẩy cú bấm qua `Viewport` và đặt khung đè lên ô bấm (đã thử phá: đổi `mouse_filter` sang STOP thì test trượt). Thêm `test_tooltip_hidden_when_battle_ends` (đã thử phá: bỏ kiểm hết trận thì test trượt).

### File List

- `game/src/ui/tooltip.gd`, `.uid` (mới)
- `game/src/app/main.gd` (tạo và truyền `Tooltip`)
- `game/src/battle/battle_view.gd` (dựng chữ, nổi bật, ẩn khi `stop`)
- `game/src/battle/telegraph_view.gd` (`highlight`, `highlighted`, màu nổi bật)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation` (chuỗi mới)
- `game/tests/test_battle_view.gd` (3 test)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
