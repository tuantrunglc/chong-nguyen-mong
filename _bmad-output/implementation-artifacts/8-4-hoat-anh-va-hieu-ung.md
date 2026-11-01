---
baseline_commit: 6846d3d
---

# Story 8.4: Hoạt ảnh và hiệu ứng

Status: done

## Story

Là người chơi,
tôi muốn quân đi, đánh, trúng đòn, gục có chuyển động,
để thấy rõ chuyện gì vừa xảy ra.

_Chốt 2026-11-01 (tác giả): Epic 8 chỉ đổi hình và tiếng, **không đổi luật**. Story này gắn **khung hình chuyển động** (đi, đánh, trúng đòn, gục, chết đuối) và **hiệu ứng** (lao, tên, va chạm, nước bắn, chông, lửa kho, hào quang Sát Thát, dấu tiếp viện, hồi máu, khói làng) vào bộ phát lại sự kiện đã có (Story 2.11). Ô đỏ báo đòn, số thứ tự, ô sáng, đường đi, vòng chọn, chấm máu vẫn vẽ bằng code (NFR9)._

> **PHỤ THUỘC CỨNG: Story 8.3 phải xong trước.** Story này cắm vào `UnitToken` đã vẽ **hình đứng yên** (8.3): có `UnitArt`, `set_facing()`, `FOOT_DROP`, bóng bằng hình, màu nhân "đã đi/đã đánh". Hiện (commit `6846d3d`) `unit_token.gd` còn vẽ **đồng tròn có chữ**, `unit_art.gd` chưa tồn tại. Nếu khi bắt đầu mà `game/src/battle/unit_art.gd` chưa có thì **DỪNG và báo tác giả**, đừng tự làm lại 8.3 trong story này.

## Acceptance Criteria

(Nguồn: `epics.md` Story 8.4, `art-reference/danh-sach-hinh-e8.md` mục B và C, mã nguồn `event_player.gd`, `battle_event.gd`, `board_view.gd`. Mục **[Đã chốt mặc định]** có câu hỏi tương ứng ở "Câu hỏi cho tác giả"; dev làm theo mặc định, tác giả đổi sau khi xem ảnh.)

### A. Quân chuyển động

1. **Đi.** Sự kiện `MOVED` với `cause == WALK` phát khung `tex_<quân>_di_<hướng>_0..3.png` (hướng `north|east|south|west` theo ô đi: so `to_cell - from_cell`, trục có `|delta|` lớn hơn thắng, hòa thì `south/north` trước). Bốn khung trải đều trong thời lượng của sự kiện, **cùng lúc** với tween `position` hiện có. Hết sự kiện, quân dừng ở hình đứng yên của 8.3 **quay theo hướng vừa đi** (xem AC 6).
2. **Bị đẩy hoặc kéo. [Đã chốt mặc định: Câu hỏi 1]** `MOVED` với `cause` khác `WALK` (`PUSH`, `PULL`, `COLLISION`...) **không** phát khung đi: quân trượt giữ nguyên hình đứng, như hiện nay. Lý do: quân bị đẩy không tự bước.
3. **Đánh.** `ATTACKED` phát `tex_<quân>_danh_<east|south|west>_0..3.png`, chọn theo hướng từ quân tới `to_cell`. Bộ hình **không có hướng bắc**: đánh lên phía bắc thì dùng `east` nếu `dx >= 0`, ngược lại `west`. Tween `_lunge` (lao tới 12 px rồi về) **giữ nguyên** và chạy cùng lúc.
4. **Trúng đòn.** `DAMAGED` phát `tex_<quân>_trung_don_0..3.png` trên quân bị trúng, thay cho màu đỏ nháy `_flash`. Riêng `TELEGRAPHED` (báo đòn, không mất máu) **vẫn** nháy đỏ như cũ, không phát khung trúng đòn. Cung kỵ có bộ riêng `trung_don_east|west`: chọn `west` nếu hướng đứng hiện tại chứa `west`, ngược lại `east`; các quân khác dùng `trung_don` chung.
5. **Gục và chết đuối.** `DIED` phát `tex_<quân>_guc_0..3.png` (Cung kỵ: `guc_east|west` theo cùng quy tắc AC 4), rồi mờ dần ở 30% thời gian cuối rồi ẩn. `DROWNED` phát `tex_<quân>_chet_duoi_0..3.png` cho Bộ binh, Kỵ binh, Cung kỵ (tướng không có bộ này và **không bao giờ** chết đuối: luật coi như va chạm). Gặp quân không có bộ `chet_duoi` thì dùng lại cách cũ (chìm 10 px rồi mờ) và **không** ghi `ERROR`.
6. **Hướng đứng sau động tác. [Đã chốt mặc định: Câu hỏi 2]** Trong lúc phát nhật ký, mỗi động tác đặt hướng đứng của quân theo hướng của nó (đi: hướng đi; đánh: hướng tới ô trúng). Quân giữ hướng đó cho tới lần `BoardView.show_state` kế tiếp, lúc đó 8.3 tính lại hướng "nhìn địch gần nhất". **Không** thêm hướng vào `Unit`, `BattleState`, file lưu.
7. **Khung nào cũng qua `Art.tex()`.** Không `load()` riêng. Thiếu khung: `Art` đã ghi `[ERROR][hinh]` và trả ô hồng; game không sập, không kẹt `await`.
8. **Phát xong là sạch.** Sau mỗi sự kiện (và sau `EventPlayer.stop()`, `BoardView.show_state`, `UnitToken.update`), quân về hình đứng yên, `modulate` trắng, không còn khung chạy dở. Đổi trận hoặc F5 giữa lúc phát không để lại hiệu ứng treo trên bàn.

### B. Hiệu ứng

Mọi hiệu ứng là hình trong `assets/textures/hieu_ung/`, vẽ trên lớp riêng phía trên đồng quân và dưới viền mục tiêu/số thứ tự (không che ô đỏ báo đòn và số thứ tự, NFR9). Tâm hiệu ứng tính bằng `BoardView.cell_center(cell)` trừ độ cao ô (`surface_height`) khi hiệu ứng nằm trên bệ.

9. **Lao bay.** `ATTACKED` của Phạm Ngũ Lão (`PHAM_NGU_LAO`) vẽ `tex_lao_bay_<bac|dong|nam|tay>.png` bay từ quân tới `to_cell` (đường thẳng, trong khoảng đầu sự kiện), biến mất khi chạm. Hướng chọn theo trục chính của đường bay.
10. **Mũi tên.** `ATTACKED` của Cung kỵ (`CUNG_KY`) vẽ `tex_ten_bay_<bac|dong|nam|tay>.png` bay như AC 9.
11. **Va chạm.** `COLLIDED` vẽ `tex_va_cham.png` ở `to_cell` (ô bị va), hiện nhanh rồi tan (phóng nhẹ + mờ dần). Rung của hai quân (`_shake`) giữ nguyên.
12. **Nước bắn.** `DROWNED` vẽ `tex_nuoc_ban.png` ở `to_cell` (ô sông) cùng lúc quân chìm.
13. **Chông.** `DAMAGED` có `cause == SPIKES` vẽ `tex_chong_dam.png` tại vị trí quân đang đứng (ô hầm chông vừa bước vào).
14. **Vệt chém. [Đã chốt mặc định: Câu hỏi 3]** `ATTACKED` của Nguyễn Khoái (`NGUYEN_KHOAI`) và Bộ binh (`BO_BINH`) vẽ `tex_vet_chem_0..3.png` (4 khung) ở `to_cell`. Các quân khác không có vệt chém.
15. **Lửa kho.** `GRANARY_BURNED` vẽ `tex_lua_chay_kho.png` ở `to_cell`, cháy bập bùng (nhấp nháy độ sáng hoặc phóng nhẹ) rồi tắt dần trong sự kiện. Kho vẫn biến mất ở bản chụp cuối như hiện nay; `_flash_burn` (ô nháy màu lửa) **thay bằng** hiệu ứng này, hoặc giữ nhạt đi nếu thấy hình chưa đủ rõ.
16. **Hồi máu.** `HEALED` vẽ `tex_hoi_mau.png` trên quân, bay lên nhẹ rồi tan; `_flash_heal` (nháy xanh) giữ.
17. **Khói làng. [Đã chốt mặc định: Câu hỏi 4]** `VILLAGE_DAMAGED` vẽ `tex_lang_trung_don.png` ở `to_cell` trong lúc `_flash_village`. Chỉ phát **một lần theo sự kiện**, không giữ làng "đang cháy" ở các lần vẽ sau (trạng thái đó không có trong `BattleState`, đưa vào là đổi luật).
18. **Hào quang Sát Thát.** Khi `state.sat_that_active == true`, mỗi **tướng Đại Việt còn sống** hiện `tex_hao_quang_sat_that.png` sau lưng (dưới hình quân, trên bóng), nhịp thở nhẹ. Theo **bản chụp** (`show_state`), nên đúng cả sau hoàn tác, chơi lại hiệp, nạp lại. Tắt khi `sat_that_active == false`. Không vẽ lên quân Nguyên.
19. **Dấu tiếp viện.** Mỗi ô trong `state.reinforcement_warnings` vẽ `tex_dau_tiep_vien.png` ở giữa ô, **đè lên** nền vàng cam và viền hiện có (`_draw_reinforcement_marker`: viền, nền, ký hiệu mũi xuống). Giữ viền và nền cam vì chúng phân biệt với ô đỏ báo đòn (FR35); thay riêng ký hiệu mũi tên bằng dấu cờ. Bản chụp đổi thì dấu đổi theo.
20. **Dọn hiệu ứng.** Hiệu ứng xong tự gỡ (`queue_free` hoặc xóa khỏi danh sách vẽ). `EventPlayer.stop()` và `BoardView.show_state` xóa mọi hiệu ứng đang bay. Không rò node: sau một pha địch dài, số node con của lớp hiệu ứng về 0.

### C. Thời gian, hiệu năng, luật

21. **Không kéo dài pha địch (NFR3).** Hoạt ảnh nằm **trong** thời lượng sự kiện đã có; không thêm giây nào, không đổi `SECONDS_PER_EVENT`, `DAMAGE_SECONDS`, `DEATH_SECONDS`, `MAX_PHASE_SECONDS`, `MIN_EVENT_SECONDS`, `FAST_SPEED`, `_base_seconds`, `raw_seconds`. Các hiệu ứng của một sự kiện chạy **song song** với nhau, không nối đuôi. Test cũ `test_play_stays_under_three_seconds_on_the_clock`, `test_fast_speed_plays_every_event_under_one_second`, `test_hieu_nang_tran.gd` vẫn xanh, không sửa.
22. **Tua nhanh.** Khung hình và hiệu ứng chạy theo cùng đồng hồ với sự kiện (thời lượng truyền vào đã chia `_speed`), nên tua ×3 nhanh theo mà không bỏ khung nào lỗi, không bỏ sự kiện.
23. **Hết ngân sách thì áp ngay.** Khi `play()` hết ngân sách và gọi `_apply_instant`, **không** tạo hiệu ứng hay khung (chỉ đặt trạng thái cuối như hiện nay).
24. **Chế độ instant (test, headless).** `play_now` và `instant == true` không tạo node hiệu ứng, không tween khung; kết quả trạng thái và danh sách `played()` y như cũ.
25. **60 FPS (NFR1).** Không `_process` chạy khi không có hiệu ứng (đặt `set_process(false)` lúc rỗng). Không tạo `Texture2D` mới mỗi khung (dùng `Art.tex()` có nhớ). Trận 6, hiệp nhiều quân nhất, đo lại bằng cách của 4.7 (bộ đếm FPS `--dev`, mục đo trong `NEXT-STEPS.md`). **[Tác giả đo]** trên laptop card tích hợp; dev tự đo trên máy dev ghi số vào Completion Notes, không điền hộ số của tác giả.
26. **Luật không đổi.** `src/core`, `Rules`, `BattleEvent`, `chi_so.json`, kịch bản `da_duyet: true`, `BattleController` **không bị sửa**. Hoạt ảnh chỉ đọc `BattleEvent` và bản chụp (ADR-002), không sửa `BattleState`. `EventPlayer` không gọi `show_state` chen giữa.
27. **Hình học không đổi.** `pick_cell`, `cell_at`, `board_rect`, `TOKEN_LIFT`, `RADIUS`, `FOOT_DROP` (của 8.3) giữ nguyên. Khung chuyển động cùng cỡ 64×64 và cùng điểm chân với hình đứng yên (kiểm bằng ảnh chụp, xem AC 30).

### D. Bóng mờ xem trước

28. **Bóng mờ xem trước dùng hình quân. [Đã chốt mặc định: Câu hỏi 5; cắt được nếu trễ]** Với 8.3, `PreviewView` còn vẽ đồng tròn mờ. Ở story này thay bằng **hình đứng yên của quân, nhân alpha khoảng 0,55**, đặt đúng chỗ bóng mờ cũ (`ghost["pos"]`, cùng độ cao), vẫn phân biệt phe bằng màu sẵn trong hình. Số máu dự kiến và nhãn "−N" giữ nguyên (chữ vẫn bằng code). Nếu đổi cái này mà xem trước bị rối thì giữ đồng tròn cũ và ghi vào Completion Notes.

### E. Duyệt và test

29. **Test.** `tools/test.sh` xanh; có test mới (Task 6). Không giảm số test cũ; test cũ chỉ sửa chỗ buộc phải sửa (ví dụ test kiểm `modulate` đỏ sau `DAMAGED`), ghi vào Completion Notes.
30. **Tác giả duyệt bằng mắt.** Chụp bằng GoPeak `capture_screenshot` (`tools/chay.sh --dev --tran=N`, nhớ `inject_mouse_click` để chơi) ít nhất:
    - **ảnh chụp giữa hoạt ảnh**: quân đang đi (khung đi), đang đánh, đang trúng đòn, đang gục (nếu khó bắt đúng lúc, đặt tạm `EventPlayer.SECONDS_PER_EVENT` chậm để chụp rồi **trả lại**; ghi vào Completion Notes);
    - từng hiệu ứng: lao (trận 1 hoặc có Lão), tên (có Cung kỵ), va chạm, nước bắn (trận có sông), chông (trận 3 hoặc có hầm chông), lửa kho (mưu kế Vườn không nhà trống), hào quang Sát Thát, dấu tiếp viện, hồi máu (quân Nguyên kề kho), khói làng;
    - một ảnh trận 6 hiệp đông quân để xem có chồng hiệu ứng quá rối không.
    Lưu vào `_bmad-output/implementation-artifacts/anh/8-4-*.png`. Chỉ đánh `[x]` Task 7 khi đã lưu đủ ảnh.

## Tasks / Subtasks

- [x] Task 1: Chọn khung hình và hiệu ứng (hàm thuần, test được không cần cảnh) (AC: 1, 3, 4, 5, 6, 9, 10, 14)
  - [x] 1.1 Tạo `game/src/battle/unit_anim.gd` (`class_name UnitAnim`, `extends RefCounted`, chỉ hàm tĩnh, theo mẫu `GroundArt`/8.3 `UnitArt`):
    - `enum Clip { WALK, ATTACK, HURT, DIE, DROWN }`;
    - `walk_facing(from: Vector2i, to: Vector2i) -> String` trả `north|east|south|west`;
    - `attack_facing(from_pos: Vector2, to_pos: Vector2) -> String` trả `east|south|west` (luật phía bắc ở AC 3);
    - `frame_paths(unit_type: int, clip: int, facing: String) -> Array[String]`: 4 đường dẫn `hoat_anh/tex_<tiền_tố>_<…>_<0..3>.png`, tiền tố dùng lại bảng của 8.3 (`khoai, lao, du, bo_binh, ky_binh, cung_ky`). Trả `[]` khi quân đó **không có** bộ này (tướng + `DROWN`), để gọi cách dự phòng;
    - ngoại lệ Cung kỵ cho `HURT`/`DIE` (`_east|_west`) nằm gọn trong hàm này.
  - [x] 1.2 Tạo `game/src/battle/fx_art.gd` (`class_name FxArt`, `extends RefCounted`): hằng đường dẫn mọi hình hiệu ứng (một chỗ, để tác giả thay hình cho dễ); `static func plan(event: BattleEvent, state: BattleState) -> Array[Dictionary]` trả danh sách mô tả hiệu ứng cho một sự kiện, mỗi mục: `{ "kind": String, "path": String (hoặc "paths": Array[String] cho vệt chém), "from_cell": Vector2i, "to_cell": Vector2i, "travel": bool }`. `plan` đọc `event` và loại quân (qua `state.unit_by_id`; null thì trả `[]` an toàn), **không** sửa gì. Quy tắc theo AC 9 tới 17.
  - [x] 1.3 Hàm chọn hướng bay `bay_dir(from: Vector2, to: Vector2) -> String` trả `bac|dong|nam|tay` (hậu tố file `tex_lao_bay_*`, `tex_ten_bay_*`).
- [x] Task 2: `UnitToken` phát khung (AC: 1, 3, 4, 5, 6, 7, 8, 27)
  - [x] 2.1 Thêm `play_clip(frames: Array[Texture2D], seconds: float)`: giữ mảng khung và chỉ số khung hiện tại, dùng **Tween của chính token** (`create_tween`, không dùng `_active_tween` của `EventPlayer`, vì `_new_tween()` ở đó giết tween cũ mỗi sự kiện và sẽ cắt khung giữa chừng; tween vị trí và tween khung phải chạy song song). `_draw()` vẽ khung hiện tại thay hình đứng yên khi có khung; vẫn có bóng, chấm máu, màu nhân "đã đi/đã đánh" của 8.3.
  - [x] 2.2 Thêm `clear_clip()` (về hình đứng, `queue_redraw`); `update()` gọi `clear_clip()` cùng chỗ nó đặt lại `visible`/`modulate` (AC 8). `UnitToken` giữ `set_facing()` của 8.3, thêm `facing_name() -> String` nếu cần cho Cung kỵ (AC 4).
  - [x] 2.3 `set_aura(on: bool)`: vẽ `tex_hao_quang_sat_that.png` dưới hình quân, trên bóng, nhịp thở bằng `Tween` lặp hoặc `Time` trong `_process` (chỉ bật `_process` khi `on`); `update()`/`setup()` không tự bật, `BoardView` bật theo bản chụp (Task 4).
  - [x] 2.4 Giữ `hit()`, `TOKEN_LIFT`, `RADIUS`, `HP_OFFSET`, `name_text()`, `hp_text()`, `is_moved()`, `is_attacked()`.
- [x] Task 3: Lớp hiệu ứng (AC: 9 tới 17, 20, 25)
  - [x] 3.1 Tạo `game/src/battle/fx_layer.gd` (`class_name FxLayer`, `extends Node2D`): danh sách hiệu ứng đang chạy; mỗi hiệu ứng là `{tex, pos, alpha, scale, ...}`, `_draw()` vẽ hết; `add(...)` thêm, tự gỡ khi xong; `_process` chỉ bật khi danh sách khác rỗng. Hàm `spawn_static(path, center, seconds, style)`, `spawn_frames(paths, center, seconds)`, `spawn_travel(path, from, to, seconds)`; `active_count() -> int`, `clear()`.
  - [x] 3.2 Hiệu ứng tính thời gian bằng `Tween` hoặc bằng `delta` với tổng thời lượng truyền vào (đã chia `_speed`); **không** dùng `Timer`/`create_timer` riêng.
  - [x] 3.3 `BoardView` thêm `_fx: FxLayer` trong `_ready()`, ngay sau `_world` và trước `_preview` (thứ tự con ghi vào bình luận đầu `_ready` như cũ); `fx_layer() -> FxLayer` để `EventPlayer` và test truy cập; `show_state` gọi `_fx.clear()`.
- [x] Task 4: `BoardView` bật hào quang và dấu tiếp viện theo bản chụp (AC: 18, 19)
  - [x] 4.1 Trong `_sync_tokens()`: sau `setup`/`update`, `token.set_aura(state.sat_that_active and unit.faction == Unit.Faction.DAI_VIET)`. Làm cả ở `add_reinforcement_token` (quân tiếp viện là Nguyên nên luôn `false`).
  - [x] 4.2 `_draw_reinforcement_marker(cell)`: thêm `draw_texture(Art.tex("hieu_ung/tex_dau_tiep_vien.png"), …)` căn giữa `_top_center(cell)`, thay cho đường chevron; giữ `draw_rect` nền và viền. Kiểm bằng ảnh chụp xem dấu có chìm trong nền cam không.
- [x] Task 5: `EventPlayer` nối sự kiện với khung và hiệu ứng (AC: 1 tới 6, 8 tới 17, 21 tới 24)
  - [x] 5.1 Trong `_play_one()`: ở mỗi nhánh, sau khi xác định `seconds`, gọi `_start_clip(token, clip, facing, seconds)` và `_spawn_fx(event, seconds, snapshot)` **trước** `await` của tween chính, để chúng chạy song song với tween `position`/`modulate` hiện có. Không thêm `await` mới; không đổi giá trị trả về/thời gian.
  - [x] 5.2 `_start_clip` dựng mảng `Texture2D` từ `UnitAnim.frame_paths` qua `Art.tex()`, rỗng thì không làm gì (AC 5, dự phòng). `_spawn_fx` gọi `FxArt.plan(event, snapshot)` rồi đẩy sang `board.fx_layer()`. `snapshot` có thể `null` (test): `plan` phải chịu được.
  - [x] 5.3 `DAMAGED`: phát khung `HURT` thay `_flash`; `TELEGRAPHED` vẫn `_flash` (AC 4). `DIED`: khung `DIE` + mờ 30% cuối (sửa `_sink_or_fade`: tách phần mờ ra khỏi phần khung, vẫn `token.visible = false` ở cuối). `DROWNED`: khung `DROWN` nếu có, không thì chìm 10 px như cũ.
  - [x] 5.4 Cập nhật hướng đứng của token theo động tác (AC 6): gọi `token.set_facing(...)` với chỉ số hướng tương ứng của 8.3 (hàm ánh xạ tên hướng → chỉ số nằm trong `UnitArt`, đừng nhân đôi bảng).
  - [x] 5.5 `_apply_instant`, `play_now`, `instant == true`: **không** gọi `_start_clip`/`_spawn_fx` (AC 23, 24).
  - [x] 5.6 `stop()`: thêm `clear_clip()` cho mọi token và `fx.clear()`.
- [x] Task 6: Test (AC: 1, 3 tới 7, 9 tới 21, 23 tới 26, 29)
  - [x] 6.1 Mới `game/tests/test_unit_anim.gd`: `walk_facing` đủ 4 hướng; `attack_facing` không bao giờ trả `north` và tuân luật dx của AC 3; `frame_paths` mọi `UnitType` × `WALK|ATTACK|HURT|DIE` × hướng hợp lệ trả đúng 4 đường dẫn và **mọi đường dẫn đều mở được** (`ResourceLoader.exists` hoặc `Art.tex` không ghi `[ERROR][hinh]`; nhớ `Art.reset_for_test()` đầu test, bài học review 8.2); `DROWN` của tướng trả `[]`; Cung kỵ ra đúng `_east|_west` (kiểm bằng tên tệp thật, không so hằng với hằng).
  - [x] 6.2 Mới `game/tests/test_fx_art.gd`: `plan` cho từng loại sự kiện ra đúng hiệu ứng (bảng AC 9 tới 17), kể cả **trường hợp không có hiệu ứng** (Bộ binh `ATTACKED` không có lao/tên, tướng Dư `ATTACKED` không có vệt chém, `DAMAGED` không phải `SPIKES` không có chông, `TELEGRAPHED` không có khung trúng đòn); `snapshot == null` và `unit_by_id == null` không ném lỗi; mọi đường dẫn hiệu ứng mở được.
  - [x] 6.3 `test_event_player.gd` (thêm, **không sửa** test cũ): đặt `player.instant = false` như các test hiện có; chạy một pha `MOVED + ATTACKED + DAMAGED + DIED` rồi kiểm (a) lúc đang phát, `fx_layer().active_count() > 0` ở sự kiện có hiệu ứng, (b) phát xong `active_count() == 0` và mọi token `modulate == WHITE`, không còn khung chạy dở, (c) tổng thời gian trên đồng hồ thật vẫn ≤ `MAX_PHASE_SECONDS` (dùng đúng cách đo của test hiện có), (d) `stop()` giữa chừng xóa sạch hiệu ứng.
  - [x] 6.4 `play_now` / `instant`: không tạo hiệu ứng (`active_count() == 0`) và `played()` giữ thứ tự cũ (AC 24).
  - [x] 6.5 `test_board_view.gd`: `show_state` với `sat_that_active = true` bật hào quang cho đúng tướng Đại Việt và **không** cho quân Nguyên; `false` thì tắt; `show_state` lần hai (bản chụp khác) tắt/bật lại đúng. Đừng kiểm bằng so hằng: đọc trạng thái thật của `UnitToken` (cần một getter `has_aura()`).
  - [x] 6.6 Kiểm tra `PreviewView` (nếu làm AC 28): ghost vẽ đúng hình quân (không còn dùng `draw_circle`), số máu dự kiến không đổi.
  - [x] 6.7 Sửa test cũ buộc phải sửa (nếu có test dựa vào `modulate` đỏ sau `DAMAGED`) và ghi vào Completion Notes.
  - [x] 6.8 `tools/test.sh` xanh (gồm `check_boundaries.sh`, `test_assets.gd`: mọi hình đã có dòng CREDITS từ 8.1, story này không thêm hình mới).
- [x] Task 7: Duyệt bằng mắt (AC: 8, 25, 27, 30)
  - [x] 7.1 Chạy `tools/chay.sh --dev --tran=N` ở chế độ nền (nhiều trận: 1, 3, 5, 6), chụp bằng GoPeak `capture_screenshot`, lưu `anh/8-4-*.png`. Xong thì tắt game.
  - [x] 7.2 Ghi vào Completion Notes: khung nào bị lệch chân hoặc giật so với hình đứng, hiệu ứng nào chìm hoặc che số máu / ô đỏ báo đòn, trận 6 có rối không, FPS dev đo được.
  - [x] 7.3 Nếu khung chuyển động lệch chân so với hình đứng (nhìn "nhảy" khi đổi khung), **dừng và báo tác giả** thay vì chỉnh `FOOT_DROP`/`TOKEN_LIFT`.

## Dev Notes

### Hiện trạng cần đọc trước khi code (kiểm 2026-11-01, commit `6846d3d`)

- **8.3 chưa làm.** `unit_token.gd` (141 dòng) đang vẽ đồng tròn (`draw_circle`, `RADIUS=24`, `TOKEN_LIFT=20`), bóng elip, chấm máu. Story 8.4 giả định 8.3 đã đổi `_draw()` sang hình, thêm `UnitArt`, `set_facing`, `FOOT_DROP`. **Đọc `unit_token.gd` và `unit_art.gd` bản đã làm 8.3 trước khi sửa**; tên hàm trong story này (`set_facing`, `FOOT_DROP`) lấy từ story 8.3, nếu 8.3 thực tế đặt tên khác thì theo code, ghi vào Completion Notes.
- `src/battle/event_player.gd` (349 dòng): `play()` canh đồng hồ thật (`_deadline`), mỗi sự kiện `await _play_one(event, seconds, snapshot)`. `_play_one` có `match event.type`, mỗi nhánh gọi `_tween_to`/`_lunge`/`_collide`/`_flash`/`_flash_heal`/`_sink_or_fade`/`_flash_cell`. **`_new_tween()` giết tween đang chạy**: mọi hoạt ảnh phải mượn một tween riêng (token hoặc lớp hiệu ứng), không dùng `_active_tween` cho khung hình. `_wait()` dùng `create_timer`, nên vòng phát không treo khi tween bị giết. `_apply_instant` đặt trạng thái cuối khi hết ngân sách hoặc `instant`.
- `src/core/battle_event.gd`: loại sự kiện dùng cho 8.4: `MOVED` (`unit_id`, `from_cell`, `to_cell`, `cause`), `ATTACKED` (tướng: `from_cell` = ZERO, chỉ có `to_cell`; quân Nguyên: có `from_cell`), `DAMAGED` (`unit_id`, `amount`, `cause`; **không có ô**, lấy vị trí từ `token.position`), `DIED` (`from_cell` là ô lúc gục), `DROWNED` (`to_cell`), `COLLIDED` (`unit_id` bị đẩy, `other_id`, `to_cell`), `HEALED` (`unit_id`, `to_cell`), `GRANARY_BURNED` (`to_cell`), `VILLAGE_DAMAGED` (`to_cell`), `REINFORCEMENT_SPAWNED/BLOCKED`, `TELEGRAPHED`, `STRATAGEM_USED`. `Cause`: `WALK, STRIKE, PUSH, COLLISION, PULL, ENEMY_STRIKE, SPIKES, HEAL, REINFORCEMENT, STRATAGEM`.
- Đáng nhớ về thứ tự sự kiện: hầm chông đi qua sinh `MOVED` rồi `DAMAGED(SPIKES)`; kéo/đẩy sinh `MOVED` mang `cause = PUSH/PULL`; một đòn Khoái/Lão/Dư có thể kéo theo `COLLIDED`, `DAMAGED`, `DIED`, `DROWNED`.
- `src/battle/board_view.gd` (534 dòng): `_ready()` dựng con theo thứ tự `_backdrop, _ground, _telegraph, _terrain_labels, _world(y_sort), _preview, _target_layer, _damage_labels, _telegraph.numbers`. Lớp hiệu ứng chen **sau `_world`, trước `_preview`**. `_sync_tokens()` (dòng ~417) tạo/cập nhật đồng quân; `add_reinforcement_token()` cho tiếp viện. `_draw_reinforcement_marker(cell)` (dòng ~509) hiện vẽ nền cam, viền cam, chevron.
- `src/core/battle_state.gd`: `sat_that_active: bool` (dòng 48) bật bởi `RulesStratagem` khi dùng Sát Thát và **giữ nguyên** (có `validate()` kiểm đã ghi dùng); `reinforcement_warnings` là mảng ô.
- `src/battle/preview_view.gd`: `_draw()` (dòng ~171) vẽ đồng tròn mờ theo `UnitToken.RADIUS/TOKEN_LIFT/DAI_VIET_COLOR/NGUYEN_COLOR`; `_add_labels` đặt số máu theo `HP_OFFSET`. Đã dặn ở 8.3: giữ nguyên cho tới 8.4.
- **Hình có sẵn** (`game/assets/textures/`): cỡ khung hình quân 64×64, mỗi động tác 4 khung `_0.._3`.

  | Quân | di (4 hướng) | danh | trung_don | guc | chet_duoi |
  |---|---|---|---|---|---|
  | Khoái, Lão, Dư | north east south west | **east south west** (không có north) | `trung_don` | `guc` | **không có** |
  | Bộ binh, Kỵ binh | north east south west | east south west | `trung_don` | `guc` | có |
  | Cung kỵ | north east south west | east south west | `trung_don`, `trung_don_east`, `trung_don_west` | `guc`, `guc_east`, `guc_west` | có |

  Cung kỵ có cả bản chung (`trung_don`, `guc`) lẫn bản `_east/_west`: dùng bản `_east/_west` theo AC 4 và 5. Tên tệp ví dụ: `hoat_anh/tex_khoai_di_east_0.png`, `hoat_anh/tex_bo_binh_chet_duoi_3.png`.
- **Hiệu ứng có sẵn** (`hieu_ung/`): `tex_lao_bay_{bac,dong,nam,tay}.png` (16×48 hoặc 48×16; có thêm `tex_lao_bay.png` không hậu tố, dùng dự phòng), `tex_ten_bay_{bac,dong,nam,tay}.png` (12×32 hoặc 32×12), `tex_va_cham.png`, `tex_nuoc_ban.png`, `tex_chong_dam.png`, `tex_lua_chay_kho.png`, `tex_hao_quang_sat_that.png`, `tex_hoi_mau.png`, `tex_lang_trung_don.png` (đều 48×48), `tex_dau_tiep_vien.png` (32×32), `tex_vet_chem_0..3.png` (48×48). **Tất cả là một khung tĩnh (trừ vệt chém 4 khung)**; chuyển động của chúng (phóng, mờ, bay, nhấp nháy) làm bằng code.
- `CREDITS.md` đã có dòng C1 đến C10 và B1 đến B6 (Story 8.1). **Không thêm hình mới** ở story này; nếu thiếu hình nào thì báo tác giả (đừng tự vẽ).
- `game/assets` hiện 3,7 MB (hoat_anh 1,9 MB); không thêm hình thì không đụng giới hạn 25 MB.

### Rủi ro và việc cần xem bằng mắt (báo tác giả)

- **Khung đi và hình đứng có cùng điểm chân không?** Nếu khung đi cao/thấp hơn vài pixel so với hình đứng, quân sẽ "giật" mỗi lần đổi. Chỉ xem và báo, đừng sửa `FOOT_DROP`.
- **Hiệu ứng chồng lên chấm máu hoặc số thứ tự.** Số thứ tự đòn (`_telegraph.numbers`) nằm trên cùng, nhưng hiệu ứng 48×48 có thể che chấm máu. Nếu thấy che, hạ `alpha` hoặc dời tâm, đừng đổi thứ tự lớp.
- **Pha dài nhiều sự kiện.** Pha địch dài bị co về 3 giây: mỗi sự kiện có thể chỉ còn khoảng 60 ms (`MIN_EVENT_SECONDS`), 4 khung trong 60 ms là 15 ms/khung, mắt thường không thấy. Chấp nhận: ưu tiên NFR3. Không tăng sàn thời gian.
- **Quân có hai việc liên tiếp** (`MOVED` rồi `DAMAGED(SPIKES)`): khung đi chưa xong thì khung trúng đòn đã tới. `play_clip` phải **thay** khung đang chạy (kill tween khung cũ của token), không chồng.
- **Quân đã ẩn** (`visible = false` sau `DIED`) nhưng `update()` của bản chụp sau lại bật: `update()` phải `clear_clip()` để khung gục không kẹt (bài học review 2.11).
- **Tween chạy song song** (`position` và khung) cần hai tween khác nhau. Tween khung thuộc token hoặc lớp hiệu ứng; nhớ giết nó khi token bị `queue_free` (`_remove_token`).
- **`TELEGRAPHED` tướng** có thể nhận ô có token là quân Nguyên chưa hiện: giữ `if token != null` như cũ.
- **`snapshot` có thể `null`** (test, `play_now` không truyền): `FxArt.plan` và `_move_target` chịu được.

### Luật dự án áp dụng (từ `project-context.md`)

- Chỉ cú pháp Godot 4, gõ kiểu tĩnh mọi nơi; `untyped_declaration` là error. Hoạt ảnh dùng `Tween` và chỉ phát lại `BattleEvent`; **không** đọc trạng thái sống, không sửa trạng thái.
- Hình nạp qua `Art.tex()`; lỗi nạp ghi `Log.error("hinh", ...)` tiếng Việt. Không `print`, không `randi`/`randf` (hiển thị cũng tất định để chụp ảnh lặp lại được; nhấp nháy dùng sóng `sin` theo thời gian hoặc chỉ số khung).
- Không đụng `src/core`. `tools/check_boundaries.sh` cấm lõi luật import code vẽ; `UnitAnim`, `FxArt`, `FxLayer` nằm trong `src/battle/`.
- Không dùng object pool, không `Thread`, không `WorkerThreadPool`. Hiệu ứng ít (tối đa vài chục node cùng lúc): tạo mới rồi gỡ là đủ.
- Mọi chữ hiển thị qua `tr()` và `text.csv`; story này không thêm chữ mới (lưu ý: `PreviewView` AC 28 giữ nhãn máu cũ).
- Không thêm thư viện, không đổi Godot, không đổi tên file hình.
- Mỗi file mới có `.uid` do Godot sinh (chạy game hoặc test một lần rồi commit `.uid`).
- Web đơn luồng, renderer Compatibility: chỉ dùng `draw_texture`/`Tween`, không shader mới, không `GPUParticles2D` (dùng `CPUParticles2D` nếu thật cần, nhưng bản này không cần).
- Nói với tác giả bằng tiếng Việt: các bước để thử, thấy gì là đúng (xem "Cách tác giả thử" dưới).

### Cách tác giả thử (cho báo cáo cuối của dev)

1. `tools/chay.sh --tran=1`, chọn Nguyễn Khoái, đi một ô: **thấy** quân bước chân (4 khung), không trượt đơ.
2. Bấm đánh vào quân Nguyên: **thấy** Khoái vung đao (và vệt chém ở ô trúng), quân Nguyên giật lùi (khung trúng đòn), gục thì ngã rồi mờ.
3. Kết thúc lượt, xem pha địch: Bộ binh/Kỵ binh bước tới, ra đòn; bấm nút tua nhanh: vẫn nhanh, không sót hiệu ứng.
4. Trận có Phạm Ngũ Lão (xem bàn cờ trận đó): đánh lao từ xa, **thấy** cây lao bay tới ô trúng. Trận có Cung kỵ: mũi tên bay.
5. `tools/chay.sh --tran=3`: kéo/đẩy quân vào hầm chông (**chông đâm**), đẩy xuống sông (**nước bắn**, quân chìm), đẩy vào quân khác (**va chạm**).
6. Dùng mưu kế (Q/W): Vườn không nhà trống thì kho **cháy**; Sát Thát thì ba tướng **có hào quang** đỏ và hào quang vẫn còn sau khi hoàn tác/ chơi lại hiệp.
7. Sang hiệp mới: ô tiếp viện có **dấu cờ** trên nền cam; quân Nguyên kề kho lương được **hồi máu** (ánh sáng ngọc); làng bị trúng thì **khói** bốc lên.
8. Bật dev (`--dev`): trận 6, hiệp nhiều quân nhất, xem góc dưới trái: FPS không tụt rõ so với trước story này.

### Việc thuộc story khác (đừng làm ở đây)

- Hình đứng yên, bóng, hướng "nhìn địch gần nhất": 8.3.
- Khung 9-slice, nút, biểu tượng, con trỏ chuột, chân dung: 8.5.
- Màn hình chính, màn chuyển trận: 8.6.
- Tiếng đánh, đẩy, nước, nhạc nền, nút tắt tiếng: 8.7. (Hiệu ứng ở đây **không phát âm thanh**.)
- Thủy chiến, thuyền: Epic 7.

### Project Structure Notes

- Mới: `game/src/battle/unit_anim.gd`, `game/src/battle/fx_art.gd`, `game/src/battle/fx_layer.gd` (+ `.uid` mỗi file), `game/tests/test_unit_anim.gd`, `game/tests/test_fx_art.gd` (+ `.uid`).
- Sửa: `game/src/battle/event_player.gd`, `game/src/battle/unit_token.gd`, `game/src/battle/board_view.gd`, `game/src/battle/preview_view.gd` (AC 28), `game/tests/test_event_player.gd` (chỉ thêm), `game/tests/test_board_view.gd`, và `game/src/battle/unit_art.gd` (chỉ thêm hàm ánh xạ tên hướng → chỉ số nếu 8.3 chưa có).
- Không sửa: `src/core/*`, `battle_controller.gd`, `telegraph_view.gd`, `ground_*`, `data/*`, `i18n/*`, `assets/*`.
- Theo mẫu `GroundArt` (8.2) và `UnitArt` (8.3): hàm tĩnh chọn đường dẫn nằm riêng, lớp vẽ riêng, để tác giả thay hình ở một chỗ.

### Previous Story Intelligence (8.1, 8.2, 8.3)

- **Review 8.2 bắt 5 lỗi, tránh lặp lại:** (1) thứ tự `add_child` làm lớp phủ che tiêu đề: lớp hiệu ứng mới **không** được che tiêu đề, số thứ tự đòn, ô đỏ; kiểm trong ảnh chụp. (2) Test tautology: so hằng với hằng. Test hướng/đường dẫn phải so với **tên tệp có thật** và hành vi (số node hiệu ứng thật sự đổi). (3) `Art._cache` và `_reported` là static: **luôn `Art.reset_for_test()` đầu test**. (4) Thiếu kiểm null cho lớp con tạo trong `_ready` khi `show_state`/`setup` gọi sớm (`_fx` có thể `null`): kiểm null trước khi dùng. (5) Task chụp ảnh đánh `[x]` khi chưa chụp đủ.
- **Cách làm đáng bắt chước:** công tắc hằng ở đầu file (như `SHOW_TERRAIN_LABELS`, `SHOW_NAMES`) để tắt tính năng mà không xóa code; ảnh chụp lưu `anh/8-N-*.png`; "Câu hỏi cho tác giả" với mặc định rõ ràng. Đề xuất cho 8.4: `EventPlayer.ANIMATE_CLIPS: bool = true` và `FxLayer.ENABLED: bool = true` để tắt nhanh khi nghi hoạt ảnh gây lỗi.
- **Bài học review 2.11** (nằm trong comment `UnitToken.update`): hoạt ảnh gục/chết đuối làm mờ hoặc ẩn đồng quân; `update()` phải trả lại `visible`/`modulate`. Giờ thêm khung chạy dở vào danh sách phải trả lại.
- **Tác giả hay đổi hình sau khi xem ảnh** (8.2 đổi 4 hình nền rừng ngay trong review). Giữ đường dẫn hình hiệu ứng ở một chỗ (`FxArt`) và đường dẫn khung ở `UnitAnim`.

### Git Intelligence

- `6846d3d` (review 8.2) và `6fb4bef` (8.2): mẫu tạo lớp vẽ mới (`ground_view.gd`, `backdrop_view.gd`) + hàm tĩnh chọn hình (`ground_art.gd`) + test riêng (`test_ground_art.gd`). Làm 8.4 theo đúng khuôn này.
- `85d67c1`: sửa khung thông tin (tooltip) kéo cao; liên quan khi rê chuột lên quân trong lúc hoạt ảnh (`_playing` chặn `_on_cell_hovered`). Hoạt ảnh mới không được đổi cờ `_playing`.
- Cây làm việc hiện có ảnh nền rừng chưa commit (`tex_vien_rung_*`) và nhiều ảnh nháp ở gốc repo (`canopy_*.png`, v.v.): **không thuộc story này**, đừng `git add` chung.

### Latest Tech

- Godot 4.7.2 (ghim, không nâng). `Tween.tween_method(callable, from, to, duration)` dùng được để chạy chỉ số khung 0 đến 3; `Node.create_tween()` gắn tween vào node, node bị xóa thì tween tự dừng (dùng cho token và `FxLayer`). `Tween.kill()` an toàn khi gọi lại. Nếu API lạ thì tra Context7 `/godotengine/godot-docs/__branch__4.7` trước khi dùng (theo `CLAUDE.md`).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 8.4]
- [Source: _bmad-output/planning-artifacts/art-reference/danh-sach-hinh-e8.md#B. Quân, #C. Hiệu ứng]
- [Source: _bmad-output/planning-artifacts/art-reference/ban-giao-asset.md]
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/8-3-quan-dung-yen.md]
- [Source: _bmad-output/implementation-artifacts/8-2-o-nen-va-dia-hinh.md#Review Findings]
- [Source: _bmad-output/implementation-artifacts/4-7-kiem-tra-hieu-nang-va-trinh-duyet.md]
- [Source: game/src/battle/event_player.gd#_play_one, #_apply_instant, #_new_tween]
- [Source: game/src/core/battle_event.gd]
- [Source: game/src/battle/board_view.gd#_ready, #_sync_tokens, #_draw_reinforcement_marker]
- [Source: game/src/battle/preview_view.gd#_draw]
- [Source: game/src/core/battle_state.gd#sat_that_active, #reinforcement_warnings]

## Câu hỏi cho tác giả

Dev làm theo mặc định; tác giả đổi được sau khi xem ảnh.

1. **Quân bị đẩy/kéo có bước chân không?** Mặc định: **không**, quân trượt giữ hình đứng (nó bị lôi đi, không tự bước). Cách khác: phát khung đi theo hướng bị đẩy cho mượt hơn, nhưng nhìn như quân tự đi.
2. **Quân đứng quay về đâu sau khi đánh/đi?** Mặc định: giữ hướng vừa làm cho tới lần vẽ lại bàn kế tiếp, rồi 8.3 quay lại "nhìn địch gần nhất". Cách khác: quay lại ngay sau mỗi động tác.
3. **Vệt chém (`tex_vet_chem`) cho ai?** Mặc định: Nguyễn Khoái và Bộ binh (hai quân dùng đao chém). Danh sách C1 đến C10 không có vệt chém nhưng hình đã có sẵn. Cách khác: bỏ, hoặc cho cả Kỵ binh.
4. **Khói làng bị trúng.** Mặc định: bốc khói **một lần** khi làng trúng đòn rồi hết. Cách khác ("làng cháy khói liên tục" như 8.2 từng nhắc) cần ghi nhớ "làng đã bị đánh" trong trận, tức thêm trạng thái vào luật: **không làm nếu chưa có lệnh của tác giả**.
5. **Bóng mờ xem trước đòn** (hiện khi rê chuột lên ô đánh): mặc định đổi từ đồng tròn mờ sang **hình quân mờ** (8.3 hẹn dời sang đây). Cách khác: giữ đồng tròn cho dễ phân biệt với quân thật.
6. **Nhịp khung hình.** Mặc định: 4 khung trải đều trong thời lượng sự kiện (khoảng 0,18 s với đi/đánh, 22 khung/giây), tua nhanh thì nhanh theo. Nếu thấy vội, tăng thời lượng sự kiện là **đổi NFR3**, nên hỏi trước.

## Dev Agent Record

### Agent Model Used

Claude Sonnet 5.5

### Debug Log References

- `tools/test.sh`: 973/973 đạt (949 cũ + 24 mới). Chạy game `--dev --tran=1`, chơi một hiệp có pha địch: log 0 dòng ERROR, FPS 93 đến 102 (máy dev).

### Completion Notes List

- **Làm xong (Task 1 đến 6):** `UnitAnim` (chọn khung đi/đánh/trúng đòn/gục/chết đuối), `FxArt` (chọn hiệu ứng theo sự kiện, mọi đường dẫn hình hiệu ứng ở một chỗ), `FxLayer` (lớp vẽ hiệu ứng, `_process` chỉ chạy khi còn hiệu ứng). `UnitToken` thêm `play_clip`, `clear_clip`, `set_aura`, `has_clip`, `has_aura`, `facing_name`. `BoardView` thêm lớp hiệu ứng (giữa `_world` và `_preview`), hào quang Sát Thát theo bản chụp, dấu cờ tiếp viện đè lên nền cam. `EventPlayer` gắn khung và hiệu ứng vào từng sự kiện, không thêm `await`, không đổi hằng thời gian. `PreviewView` vẽ bóng bằng hình quân mờ.
- **Công tắc tắt nhanh:** `EventPlayer.ANIMATE_CLIPS`, `FxLayer.ENABLED` (đặt false thì chỉ còn tween như trước).
- **Quyết định nhỏ (theo mặc định của story):** bị đẩy/kéo không phát khung đi; hướng đứng giữ tới lần `show_state` kế; vệt chém cho Khoái và Bộ binh; khói làng một lần theo sự kiện; `_flash_burn` giữ nhạt (alpha 0,35) dưới hình lửa kho.
- **Hướng bay lao/tên** tính lúc phát từ vị trí token đang vẽ tới ô trúng (không dùng `from_cell` vì tướng có `from_cell` = ZERO).
- **Test cũ:** không sửa test nào. Test mới: `test_unit_anim.gd`, `test_fx_art.gd`, 4 test trong `test_event_player.gd` (phát thật có hiệu ứng rồi sạch, `stop()`, `show_state`, `play_now`/instant), 1 test hào quang trong `test_board_view.gd`.
- **6.6 chưa làm (để mở):** không có cách kiểm tra bóng xem trước vẽ đúng hình khi chạy không màn hình (`_draw` chỉ chạy khi render); cần xem bằng mắt. Chụp hover thật ở trận 1 chỉ mới thấy đường đi, chưa thấy bóng mờ.
- **Task 7 chưa làm (cần tác giả hoặc cách chụp tốt hơn):** chuột giả của GoPeak bấm được (chọn tướng, đi một ô, bấm nút Kết thúc lượt, pha địch chạy), nhưng ảnh chụp trễ hơn cả hoạt ảnh nên không bắt được giữa lúc phát, và phím giả (Space) không có tác dụng. Chưa có ảnh `anh/8-4-*.png` nào; chưa kiểm khung đi có lệch chân so với hình đứng không; chưa kiểm FPS trận 6. Tác giả xem theo mục "Cách tác giả thử"; thấy khung lệch chân thì báo (AC 27: không tự chỉnh `FOOT_DROP`).

- **Duyệt:** tác giả xem bằng mắt trong game (2026-11-01) và báo ổn, đóng story. Không có ảnh `anh/8-4-*.png` (chụp không bắt được giữa hoạt ảnh).

### File List

- Mới: `game/src/battle/unit_anim.gd`, `game/src/battle/fx_art.gd`, `game/src/battle/fx_layer.gd`, `game/tests/test_unit_anim.gd`, `game/tests/test_fx_art.gd` (+ `.uid`)
- Sửa: `game/src/battle/event_player.gd`, `game/src/battle/unit_token.gd`, `game/src/battle/board_view.gd`, `game/src/battle/preview_view.gd`, `game/tests/test_event_player.gd`, `game/tests/test_board_view.gd`

## Change Log

- 2026-11-01: Tạo story 8.4 (Ultimate context engine).
- 2026-11-01: Làm Task 1 đến 6 (khung chuyển động, hiệu ứng, hào quang, dấu tiếp viện, bóng xem trước bằng hình, test). Task 7 và 6.6 do tác giả xem bằng mắt rồi báo ổn.
