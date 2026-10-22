---
baseline_commit: 7790797
---

# Story 2.10: Rê chuột xem thông tin

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

Là người chơi,
tôi muốn rê chuột lên quân và ô để xem thông tin,
để không phải nhớ chỉ số.

## Acceptance Criteria

1. **Khi** rê chuột lên một quân **Thì** hiện tên quân, máu hiện tại / máu tối đa, đòn sắp đánh của nó (nếu có) và số thứ tự ra đòn (FR40).
2. **Khi** rê chuột lên một quân Nguyên đã báo đòn **Thì** các ô đỏ của **chính quân đó** được làm nổi bật, ô đỏ của đòn khác giữ nguyên.
3. **Khi** rê chuột lên một ô **Thì** hiện tên loại địa hình và hiệu ứng của nó; mọi chữ lấy từ `game/i18n/text.csv` qua `tr()`, không viết chuỗi trong code.
4. **Khi** chuột rời khỏi bàn hoặc rê sang ô trống **Thì** khung thông tin ẩn đi, không để lại khung rỗng.
5. **Và** khung thông tin không chặn bấm chuột: bấm vào ô vẫn ra đúng lệnh như trước.
6. **Và** khung nằm gọn trong màn hình 1280×720, không che quân đang trỏ khi còn chỗ khác.
7. **Và** màu/nét của ô đỏ nổi bật phải khác hẳn ô đỏ thường (NFR9: ô đỏ là thứ nổi bật nhất; nổi bật kép phải đọc được ngay).
8. **Và** test giao diện chạy được không cần màn hình qua `main.tscn` (như các test view hiện có), không thêm test cho phần chỉ nhìn thấy bằng mắt.

## Tasks / Subtasks

- [ ] **Task 1: Chuỗi tiếng Việt** (AC: 1, 3)
  - [ ] 1.1 Thêm vào `game/i18n/text.csv`: `tooltip.unit.<loại>` (6 loại, tên đầy đủ), `tooltip.hp`, `tooltip.attack`, `tooltip.attack_none`, `tooltip.order`, `tooltip.terrain`, `tooltip.effect.<địa hình>` (6 địa hình).
  - [ ] 1.2 Chạy `--headless --import` để sinh lại `game/i18n/text.vi.translation`; kiểm file mới có trong git.
- [ ] **Task 2: Khung thông tin** (AC: 1–6)
  - [ ] 2.1 File mới `game/src/ui/tooltip.gd`: `PanelContainer` + `Label`, dựng bằng code (scene phẳng, không mở editor). API: `show_text(text: String)`, `hide_tooltip()`, `move_to(pos: Vector2)`, `text()`, `visible_now()` cho test.
  - [ ] 2.2 Đặt khung trong `main.tscn` ở lớp trên cùng, `mouse_filter = IGNORE` để bấm xuyên qua; `show_behind_parent` không cần.
  - [ ] 2.3 Kẹp vị trí trong `get_viewport_rect().size` (1280×720) và lệch khỏi con trỏ một khoảng nhỏ; nếu sát mép phải/dưới thì lật sang trái/trên.
- [ ] **Task 3: Nối chuột** (AC: 1–5)
  - [ ] 3.1 `BattleView`: dùng `BattleInput.cell_hovered` sẵn có (đừng thêm signal mới). Trong `_on_cell_hovered`: nếu ô có quân → dựng chữ từ snapshot (`unit.name`, `hp/max_hp`, đòn đã báo của quân đó nếu có: ô đích hoặc hướng xung phong, số thứ tự); nếu ô trống nhưng trong bàn → tên địa hình + hiệu ứng; ngoài bàn → ẩn.
  - [ ] 3.2 Ô đỏ của đòn đã báo của chính quân đang trỏ: lấy từ `TelegraphMarks.path_cells(state, t)` cho các `Telegraph` có `owner_id` = quân đó (một chỗ tính, không tự suy lại ô).
  - [ ] 3.3 Ẩn khung khi: chuột ra ngoài bàn, trận kết thúc, hoặc `stop()`. Không để khung của trận cũ dính sang trận mới.
- [ ] **Task 4: Làm nổi bật ô đỏ** (AC: 2, 7)
  - [ ] 4.1 `TelegraphView`: thêm `highlight(cells: Array[Vector2i])`, `highlighted() -> Array[Vector2i]`; vẽ ô nổi bật bằng màu/nét khác (ví dụ nền sáng hơn + viền trắng dày hơn), giữ nguyên số thứ tự.
  - [ ] 4.2 `BattleView` gọi `highlight` mỗi lần hover đổi; hover sang quân khác thì thay danh sách, hover ra ngoài thì rỗng.
- [ ] **Task 5: Test giao diện** (AC: 1–5, 8)
  - [ ] 5.1 `game/tests/test_battle_view.gd`: rê chuột lên tướng → khung hiện đúng tên + máu; rê lên quân Nguyên đã báo đòn → có số thứ tự và đúng đòn của nó; rê lên ô sông → hiện "Sông" và hiệu ứng; rê ra ngoài bàn → ẩn.
  - [ ] 5.2 Test nổi bật: rê lên quân Nguyên có đòn → `highlighted()` đúng các ô của quân đó; rê sang quân khác → đổi; rê ra ngoài → rỗng.
  - [ ] 5.3 Test bấm xuyên qua khung: khung đang hiện, bấm vào ô → lệnh vẫn tới (không bị khung nuốt).
- [ ] **Task 6: Kiểm bằng mắt, tài liệu, commit** (AC: 1–8)
  - [ ] 6.1 `tools/test.sh` xanh; `tools/chay.sh --dev --tran=thu_lao`, rê chuột lần lượt lên Khoái, lên Bộ binh đang báo đòn, lên ô sông, ra ngoài bàn. Chụp ảnh bằng `capture_screenshot` nếu chạy được (phiên trước lỗi lưu file), lưu `anh/2-10-*.png`; không có ảnh thì **không đánh [x]**.
  - [ ] 6.2 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, chạy lại từng bước trên game trước khi ghi.
  - [ ] 6.3 Commit tiếng Việt kết `(Story 2.10)`.

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

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List
