# Story 2.7: Hiển thị báo đòn

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn nhìn bàn là biết ngay ô nào sắp bị đánh và theo thứ tự nào,
để tính trước được nước đi.

_Story thứ bảy của E2. Story 2.6 đã ghi đòn quân Nguyên vào `BattleState.telegraphs` (lưu tương đối, M1) nhưng chưa vẽ. Story này **vẽ** đòn lên bàn: ô đỏ, số thứ tự lớn, mũi tên của Kỵ binh. Phần "ô nào đỏ" là **dữ liệu tính trong lõi luật** (để kịch bản kiểm được), phần vẽ chỉ đọc dữ liệu đó từ bản chụp._

_**Chưa có** (đừng làm ở đây): ra đòn, trừ máu (2.8); hủy đòn khi chủ gục hay ra ngoài bàn (2.9); hoạt ảnh báo đòn (2.11); xem trước (2.12); Cung kỵ (2.15)._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code (M3).** **Cho** 7 kịch bản mới ở Dev Notes "Đợt kịch bản 9" (`da_duyet: false`, thư mục `tests/kich_ban/don_dich/`) và phần khung ở Task 1.1 (khóa `o_do` của `sau`, hàm `TelegraphMarks.cells` trả rỗng). **Khi** gõ `tools/test.sh`, **thì** test xanh, có dòng `Kịch bản luật: 59 đã duyệt · 7 chưa duyệt (7 chưa đạt)`, lý do khớp bảng "Lý do chưa đạt". AI commit rồi **dừng chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh don_dich`.
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` trượt. Kịch bản bị nói "sai" thì sửa kịch bản theo lý do của tác giả, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh, `Kịch bản luật: 66 đã duyệt · 0 chưa duyệt (0 chưa đạt)`, 59 kịch bản cũ không sửa một chữ.
4. **Ô đỏ của đòn vào ô (Bộ binh).** Ô đỏ là ô đích hiện tại (`Telegraph.target_cell`: ô chủ đòn + offset). Chủ đòn bị đẩy/kéo thì ô đỏ tự dịch theo (đã có nhờ lưu tương đối; story này chỉ vẽ theo bản chụp mới). Chủ đòn đã gục, hoặc ô đích ra ngoài bàn: không vẽ (hủy đòn là 2.9).
5. **Ô đỏ của Kỵ binh (tác giả chốt 2026-10-21).** Từ ô ngay trước mặt Kỵ binh theo hướng đã báo, đi từng ô tới **vật đầu tiên** trên hàng (quân bất kỳ phe nào, rừng, kho lương, làng; **sông không chắn**) và **gồm cả ô vật đó**; hàng trống thì tới ô cuối cùng trước mép bàn. **Tính lại theo bản chụp sau mỗi lệnh**: tướng rời hàng thì ô đỏ trải tới mép; quân khác bước vào hàng thì ô đỏ dừng ở quân đó.
6. **Số thứ tự (FR24).** Mỗi đòn có số thứ tự lớn trên bàn, ở **ô đòn sẽ trúng**: đòn vào ô thì ở ô đích; Kỵ binh thì ở ô cuối của đường đỏ (ô vật đầu tiên, hoặc ô sát mép nếu sẽ trượt). Kỵ binh có **mũi tên** chỉ hướng xung phong, vẽ ở ô đỏ đầu tiên (sát Kỵ binh).
7. **Hai đòn cùng một ô.** Ô đó hiện đủ các số, xếp tăng dần, nối bằng dấu `·` (ví dụ `1·3`). Số chỉ hiện ở ô đòn sẽ trúng; ô đỏ chỉ là đường đi của Kỵ binh (không phải ô trúng) không có số.
8. **Ô đỏ trùng ô có quân (FR24, NFR9).** Vẫn thấy rõ cả đồng quân, tên, chấm máu và số thứ tự: màu đỏ tô trên mặt đất (dưới đồng quân); số thứ tự vẽ trên lớp đồng quân, ở vùng ô không có đồng quân che (góc dưới của mặt ô), không đè chấm máu.
9. **Nổi bật nhất (NFR9).** Ô đỏ và số thứ tự là thứ nổi bật nhất trên bàn: đỏ đậm hơn hẳn ô sáng xanh, viền mục tiêu trắng và màu sông; số chữ lớn (≥ 28 px), viền tối, đọc được trên mọi nền (đất, sông, ô có quân). Ô đỏ trùng ô sáng xanh thì vẫn thấy đỏ.
10. **Cập nhật.** Sau mỗi lệnh (đi, đánh, kết thúc lượt, mở trận, hủy, F5, Chơi lại trận) bàn vẽ lại đòn theo bản chụp mới. Hết trận (thắng/thua) thì vẫn vẽ đòn còn lại (không cần ẩn).
11. **Dữ liệu trong lõi luật.** `TelegraphMarks.cells(state)` (MỚI, `src/core/`) trả ô → danh sách số thứ tự tăng dần; `TelegraphMarks.hit_cell(state, telegraph)` trả ô đòn sẽ trúng (NO_CELL nếu không có). Phần vẽ (`telegraph_view.gd`) chỉ gọi các hàm này trên bản chụp, không tự tính luật. Không giữ tham chiếu tới trạng thái sống.
12. **Không lỗi trong log** khi chạy `tran_01` và các trận thử, kết thúc lượt vài lần.

## Tasks / Subtasks

- [ ] **Task 0: Tác giả chốt 1 câu hỏi** ở "Quyết định của tác giả" (2026-10-21: Kỵ binh tô đường tới vật đầu tiên).
- [ ] **Task 1: Khung, đợt kịch bản 9, dừng chờ duyệt** (AC: 1, 2)
  - [ ] 1.1 Khung (làm trước để kịch bản nạp và so được):
    - `src/core/telegraph_marks.gd` (MỚI, `class_name TelegraphMarks`, `RefCounted`, hàm `static`): `cells(state) -> Dictionary` và `hit_cell(state, telegraph) -> Vector2i`, `path_cells(state, telegraph) -> Array[Vector2i]`. **Chưa có luật**: `cells` trả `{}`, `hit_cell` trả `Telegraph.NO_CELL`, `path_cells` trả `[]` (kịch bản phải trượt).
    - `src/data/scenario_loader.gd`: khóa mới `o_do` của `sau` (không bắt buộc, thêm vào `AFTER_KEYS`): object `{"cot,hang": [số thứ tự, …]}`. Kiểm: khóa là ô trong bàn, không ghi một ô hai lần (như `mau`); giá trị là danh sách số nguyên ≥ 1, không rỗng, không trùng. Câu lỗi tiếng Việt kèm file, ô và giá trị sai. `{}` là "không ô nào đỏ" (vẫn kiểm). Lưu đã xếp tăng dần.
    - `src/data/scenario_data.gd`: `checks_marks: bool`, `after_marks: Dictionary` (ô → `Array[int]`).
    - `tests/scenario_runner.gd` `compare`: khi `checks_marks`, so `TelegraphMarks.cells(state)` với mong đợi theo thứ tự đọc bàn; mỗi chỗ khác một câu: `sau: ô 3,4 mong đợi đỏ (đòn 1·2), thực tế không đỏ`, `sau: ô 5,3 mong đợi không đỏ, thực tế đỏ (đòn 1)`, `sau: ô 3,3 mong đợi đỏ (đòn 1·2), thực tế đỏ (đòn 1)`.
    - `tests/scenario_viewer.gd`: in thêm bàn thứ ba **"Ô ĐỎ"** cạnh bàn SAU (cùng khung số cột/hàng): ô đỏ ghi số thứ tự (một chữ số); ô có từ hai đòn ghi `*`, rồi dưới bàn một dòng mỗi ô `*`: `3,3: đòn 1·2`. `{}` in "không ô nào đỏ". Chữ qua `tr()` (khóa `scenario.viewer.*`; sinh lại `text.vi.translation`).
    - `tests/test_scenario_loader.gd`: ca nạp `o_do` đúng (một ô, nhiều đòn một ô, `{}`), ca sai (ô ngoài bàn, khóa không phải tọa độ, ô ghi hai lần như `"3,4"` và `"03,4"`, danh sách rỗng, số 0, số trùng, không phải danh sách), ca runner so khác.
  - [ ] 1.2 Viết 7 file đúng "Đợt kịch bản 9", `"da_duyet": false`. Chép cấu trúc từ `tests/kich_ban/ai/ky_binh_xung_phong_thang_hang.json` (một lệnh `ket_thuc_luot`, `sau.hiep: 2`); kịch bản #5, #6 có thêm lệnh `di` sau `ket_thuc_luot`. Có thể ghi kèm `bao_don` cho người đọc (không bắt buộc).
  - [ ] 1.3 `tools/xem_kich_ban.sh don_dich`: đọc lại từng bàn và bàn "Ô ĐỎ", khớp `mo_ta`. `tools/test.sh`: `59 đã duyệt · 7 chưa duyệt (7 chưa đạt)`. Ghi Debug Log.
  - [ ] 1.4 Commit: `Kịch bản ô đỏ báo đòn chờ duyệt (Story 2.7)`.
  - [ ] 1.5 **HALT.** Nhắn tác giả tiếng Việt: gõ `tools/xem_kich_ban.sh don_dich`, trả lời "đúng"/"sai: <lý do>" từng cái. Nói rõ: bàn "Ô ĐỎ" là đúng những ô sẽ tô đỏ trong game; số trong ô là số thứ tự đòn; với Kỵ binh, chỉ ô cuối đường đỏ mới có số trong game (bàn "Ô ĐỎ" của công cụ duyệt ghi số ở mọi ô đỏ để dễ đọc đòn nào phủ ô nào).
  - [ ] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng"; `tools/test.sh` phải trượt. Không commit khi đỏ.
- [ ] **Task 2: Lõi luật `TelegraphMarks`** (AC: 4–7, 11)
  - [ ] 2.1 `hit_cell`: `CELL` → `target_cell` nếu chủ còn và ô trong bàn, không thì NO_CELL. `DIRECTION` → ô cuối của `path_cells` (rỗng thì NO_CELL: Kỵ binh đứng sát mép, hướng ra ngoài).
  - [ ] 2.2 `path_cells`: `CELL` → `[hit_cell]` (hoặc `[]`). `DIRECTION` → đi từ ô chủ đòn + hướng, từng ô trong bàn; thêm ô; dừng **sau khi thêm** ô có quân hoặc rừng/kho lương/làng. **Dùng chung** danh sách địa hình chắn với `EnemyAI.CHARGE_BLOCKERS` (không chép), để AI chọn ô và ô đỏ không lệch nhau; Story 2.8 ra đòn cũng dùng `hit_cell` này.
  - [ ] 2.3 `cells`: với mỗi đòn theo `order`, mỗi ô của `path_cells` thêm `order`; danh sách mỗi ô xếp tăng dần. Duyệt `state.telegraphs` (đã theo thứ tự), không duyệt khóa Dictionary để quyết thứ tự.
  - [ ] 2.4 Không đổi state; không phát sự kiện; không `Node`, `Log`.
  - [ ] 2.5 Chạy `tools/test.sh`: 7 kịch bản mới đạt. **Phá thử** (mỗi lần một chỗ, ghi Debug Log, chạy từng kịch bản): sông chắn đường xung phong (#4 trượt); dừng trước vật đầu tiên thay vì gồm nó (#3 trượt); không tính lại theo vị trí mới, ví dụ dùng ô đích lúc báo (#5 hoặc #6 trượt); không xếp số tăng dần (#7 trượt).
- [ ] **Task 3: Test GUT lõi** (AC: 4–7)
  - [ ] 3.1 `tests/test_telegraph_marks.gd` (MỚI), dùng `BoardFixture`: đòn vào ô có chủ đã gục (bỏ) và ô đích ngoài bàn (bỏ); Kỵ binh đứng sát mép, hướng ra ngoài (rỗng, NO_CELL); rừng chặn (gồm ô rừng, dừng); kho lương, làng chặn; quân Nguyên khác chắn (gồm ô đó); bàn 10×8 (không lặp cứng cỡ); ba đòn trùng một ô (`[1, 2, 3]`); `cells` không đổi `BoardFixture.picture` và `telegraphs`.
- [ ] **Task 4: Vẽ** (AC: 6–10)
  - [ ] 4.1 `src/battle/telegraph_view.gd` (MỚI, như kiến trúc "Cây thư mục"): hai lớp vẽ do `BoardView` tạo và giữ:
    - **lớp mặt đất** (vẽ trong `BoardView._draw` hoặc một `Node2D` con đứng **trước** `_world`): tô đỏ mặt trên mỗi ô của `TelegraphMarks.cells` (dùng `_top_rect`, ô ải nâng theo bệ); mũi tên Kỵ binh trên ô đầu của `path_cells`. Tô sau ô sáng xanh để ô đỏ vẫn thấy khi trùng (AC 9), hoặc viền đỏ dày nếu ô vừa sáng vừa đỏ: chọn cách nào vẫn thấy cả hai, ghi lý do.
    - **lớp số** (trên `_world`, cạnh `_target_layer`): ở mỗi ô `hit_cell`, chuỗi các số của đòn trúng ô đó (`1·3`), cỡ ≥ 28 px, chữ trắng viền tối (outline của `Label` hoặc vẽ chữ hai lần), đặt ở **góc dưới trái** mặt ô (đồng quân đứng giữa, chấm máu ở góc dưới phải). Không nhận chuột (`MOUSE_FILTER_IGNORE`), bấm xuyên xuống bàn.
    - Lớp F1 (`CoordOverlay`, góc dưới trái mỗi ô) đè lên vị trí số: dời nhãn tọa độ F1 lên **góc trên trái** của ô, hoặc dời số; chọn một, ghi lý do, sửa test F1 nếu dời.
  - [ ] 4.2 `BoardView.show_state` vẽ lại cả hai lớp theo bản chụp (không thêm hàm `show_telegraphs` riêng mà UI phải nhớ gọi). Hằng màu, cỡ chữ đặt trong `telegraph_view.gd` (màu UI, không phải số cân bằng). Đỏ báo đòn khác đỏ đồng Đại Việt (`UnitToken.DAI_VIET_COLOR`): dùng đỏ tươi, trong suốt một phần để thấy chữ địa hình bên dưới.
  - [ ] 4.3 `pick_cell` không đổi: lớp đỏ và lớp số không ảnh hưởng chọn ô.
  - [ ] 4.4 Test `tests/test_board_view.gd` (hoặc file mới): `show_state` với bản chụp có đòn → lớp đỏ có đúng các ô, lớp số có đúng chữ ở đúng ô (`1`, `1·2`), Kỵ binh có mũi tên; bản chụp không đòn → không vẽ gì; vẽ lại sau khi tướng rời hàng (đường đỏ dài ra); số không trùng vùng chấm máu (so khung chữ với `UnitToken.HP_OFFSET`). Test qua `main.tscn` thật (`_make_level_main` như `test_battle_view.gd`): mở trận có Bộ binh kề Khoái → có ô đỏ ở ô Khoái, số `1`.
- [ ] **Task 5: Kiểm bằng mắt, tài liệu** (AC: 8–10, 12)
  - [ ] 5.1 Chạy `tools/chay.sh --dev --tran=thu_keo` và `thu_lao` (có cả Bộ binh và Kỵ binh báo đòn sẵn từ hiệp 1), `tran_01` kết thúc lượt vài lần. GoPeak `capture_screenshot` (CLAUDE.md "Nhìn game đang chạy"), lưu `_bmad-output/implementation-artifacts/anh/2-7-*.png` (ít nhất: Bộ binh đỏ trên ô có tướng; Kỵ binh đường đỏ có mũi tên; một ô hai số). GoPeak không kết nối được thì **không đánh [x]**, ghi "chờ tác giả kiểm tay". Log không ERROR/WARN.
  - [ ] 5.2 `game-architecture.md`: M1 thêm "ô đỏ: `TelegraphMarks`" (Kỵ binh: đường tới vật đầu tiên, gồm ô đó, sông không chắn, tính lại theo bản chụp); mục "Kịch bản luật" thêm khóa `o_do`; cây thư mục thêm `telegraph_marks.gd`. `deferred-work.md`: 2.8 dùng `TelegraphMarks.hit_cell` khi ra đòn; 2.9 hủy đòn thì `cells` tự bỏ (chủ gục, ra ngoài bàn đã bỏ sẵn).
  - [ ] 5.3 `tools/test.sh` xanh. Commit một lần (kịch bản đã duyệt, code, test, tài liệu, `.uid` mới, `text.vi.translation`): `Vẽ ô đỏ và số thứ tự báo đòn (Story 2.7)`.
  - [ ] 5.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes bằng kết quả thật.

## Dev Notes

### Bối cảnh

- **Đã có (Story 2.6):** `Telegraph` (`owner_id`, `kind` CELL/DIRECTION, `offset`, `order`, `target_cell`, `clone`, `NO_CELL`), `BattleState.telegraphs` (theo số thứ tự, clone sâu, `validate` kiểm số thứ tự và hình dạng), pha chuẩn bị chạy đầu mỗi hiệp kể cả hiệp 1, `EnemyAI.CHARGE_BLOCKERS = [FOREST, GRANARY, VILLAGE]`, `EnemyAI.can_hit_from`, khóa kịch bản `bao_don`, bảng F3.
- Sau review 2.6: mọi quân Nguyên **đi hết rồi mới báo đòn** theo bàn cuối (Kỵ binh bị quân đi sau chắn thì không báo; tác giả chọn a) — đọc lại `RulesEnemyPhase.prepare` trước khi viết; `BEGIN_BATTLE` chỉ chạy được một lần; `validate` kiểm `DIRECTION` có offset là một hướng, `CELL` có offset kề, chủ đòn là quân Nguyên (cho phép đã gục).
- Đòn vẫn chưa đánh: đòn báo ở hiệp này bị xóa đầu pha chuẩn bị hiệp sau. Ô đỏ chỉ là thông tin.
- Tác giả không đọc code; thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Đợt kịch bản 9

Thư mục mới `tests/kich_ban/don_dich/`. Bàn 7×7 toàn đất trống trừ khi ghi; tướng 3 máu; `B` đi 2, `K` đi 3. Mọi kịch bản bắt đầu bằng `{"lenh": "ket_thuc_luot"}` (pha chuẩn bị chạy, quân Nguyên đã đứng sẵn chỗ đánh được nên **không đi**), `sau.hiep: 2`, khóa `o_do`.

| # | Tên file | Trước | Thêm lệnh | `o_do` mong đợi | Ý nghĩa |
|---|---|---|---|---|---|
| 1 | `o_do_bo_binh.json` | B `3,3`; Khoái `3,4` | — | `{"3,4": [1]}` | Bộ binh kề Khoái: ô Khoái đỏ, số 1 |
| 2 | `o_do_hai_bo_binh_mot_o.json` | B `3,0`; B `5,2`; Khoái `3,3`; `thu_tu_dich: ["3,0", "5,2"]` | — | `{"3,3": [1, 2]}` | hai Bộ binh (đi tới `3,2` và `4,3`, như kịch bản `ai/thu_tu_theo_file_tran`) cùng nhắm ô Khoái: một ô, hai số `1·2` |
| 3 | `o_do_ky_binh_toi_tuong.json` | K `0,3`; Khoái `4,3` | — | `1,3`, `2,3`, `3,3`, `4,3` đều `[1]` | Kỵ binh: đường đỏ từ ô trước mặt tới Khoái, gồm ô Khoái |
| 4 | `o_do_ky_binh_qua_song.json` | như #3, sông ở `2,3` | — | như #3 (gồm ô sông `2,3`) | sông không chắn xung phong |
| 5 | `o_do_tuong_roi_hang.json` | như #3 | Khoái đi `4,5` | `1,3` … `6,3` đều `[1]` | tướng rời hàng: đường đỏ trải tới mép (đòn sẽ trượt) |
| 6 | `o_do_tuong_khac_buoc_vao.json` | K `0,3`; Khoái `5,3`; Lão `2,6` | Lão đi `2,3` | `{"1,3": [1], "2,3": [1]}` | Kỵ binh nhắm Khoái (cùng 5 bước với Lão, cùng máu, Khoái phía Bắc hơn); Lão bước vào hàng: đường đỏ dừng ở Lão |
| 7 | `o_do_ky_binh_va_bo_binh.json` | K `0,3`; B `4,2`; Khoái `4,3`; `thu_tu_dich: ["0,3", "4,2"]` | — | `1,3`, `2,3`, `3,3` `[1]`; `4,3` `[1, 2]` | đường của Kỵ binh (đòn 1) và Bộ binh (đòn 2) cùng trúng ô Khoái: `1·2` |

- Kiểm lại từng bàn bằng tay (AI 2.6 và AC 5) trước khi viết `sau`; nếu AI dời quân khác bảng thì **dừng, ghi lại, hỏi**. #6: Lão từ `2,6` tới `2,3` là 3 bước (đúng tầm đi). #5: Khoái từ `4,3` tới `4,5` là 2 bước.
- **Lý do chưa đạt:** khung trả `cells = {}`, nên cả 7 trượt dạng `sau: ô … mong đợi đỏ (đòn …), thực tế không đỏ`.

### Định dạng `o_do`

```json
"sau": { "dia_hinh": [...], "quan": [...], "hiep": 2,
  "o_do": { "1,3": [1], "2,3": [1], "3,3": [1], "4,3": [1, 2] } }
```

- Ghi đủ **mọi** ô đỏ; ô không ghi là ô không được đỏ. Danh sách là các đòn phủ ô đó (đòn vào ô: ô đích; Kỵ binh: mọi ô của đường đỏ).
- Ô nào có **số** trong game thì không ghi trong kịch bản (suy ra được: ô `hit_cell`); test GUT kiểm phần số.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/battle/board_view.gd` (~460 dòng): `_ready` tạo `_terrain_labels`, `_world` (y-sort: khối, đồng quân), `_target_layer` (viền trắng trên đồng quân). `_draw` vẽ mặt đất, sông, chông, lưới, bệ ô ải, ô sáng (`REACH_COLOR`), vòng chọn, đường đi. `show_state(state)` dựng lại địa hình, đồng quân, vẽ lại. Story này thêm lớp đỏ (mặt đất) và lớp số (trên đồng quân). **Giữ:** `pick_cell`, `cell_center`, `_top_rect`, hình học, thứ tự lớp hiện có.
- `src/debug/coord_overlay.gd`: nhãn tọa độ ở góc dưới trái mỗi ô (Task 4.1 xử lý chồng với số).
- `src/battle/unit_token.gd`: `RADIUS 24`, `TOKEN_LIFT 20` (tâm đồng cao hơn chân 20 px), chấm máu `HP_OFFSET (19, 17)` từ tâm đồng, tức góc dưới phải. Không sửa.
- `src/data/scenario_loader.gd`, `scenario_data.gd`, `tests/scenario_runner.gd`, `tests/scenario_viewer.gd`: như Task 1.1 (mẫu: khóa `bao_don`, `mau`).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Log`, `print`, `randi`. Luật "ô đỏ" ở lõi, phần vẽ chỉ đọc (kiến trúc: "Phần trình bày chỉ đọc bản chụp").
- Một danh sách địa hình chắn xung phong (`EnemyAI.CHARGE_BLOCKERS`), không chép.
- Không lặp cứng cỡ bàn. Duyệt theo `state.telegraphs`, không theo khóa Dictionary.
- Scene nhỏ và phẳng: lớp vẽ sinh bằng code, không sửa `.tscn` nếu không cần.
- Chữ hiển thị qua `tr()` (số thứ tự là số, không cần khóa dịch; dấu `·` là ký tự, không phải chữ).
- Màu UI là hằng trong code, không vào `chi_so.json`.

### Testing

- `tools/test.sh` là lệnh duy nhất. Test GUT viết trước, chạy đỏ riêng rồi mới code (ghi Debug Log).
- Lõi test thẳng bằng `BoardFixture` + `RulesEnemyPhase.prepare` hoặc dựng `Telegraph` tay (cho ca chủ gục, ngoài bàn).
- Giao diện test qua `main.tscn` thật; trận thử viết vào `user://` rồi xóa ở `after_each`. Nhớ: mở trận giờ chạy pha chuẩn bị (2.6), dựng bố cục sao cho quân Nguyên đứng kề tướng nó nhắm (không dời), như các bố cục ở `test_battle_view.gd`.
- Phá thử mỗi lần một chỗ, chạy từng kịch bản riêng.

### Previous Story Intelligence (2.6 và review)

- Số liệu mong đợi của kịch bản/test AI dễ tính tay sai (2.6: 7 chỗ sai); đối chiếu bằng cách chạy thử luật trước khi viết mong đợi cuối, và ghi rõ trong Debug Log cách đã kiểm.
- Task chụp ảnh chỉ đánh [x] khi có file ảnh (review 2.3–2.6 bắt nhiều lần).
- File List đủ `.uid` mới và `game/i18n/text.vi.translation`.
- Mục hoãn liên quan: F3 dùng `UnitType.GENERALS[target_id - 1]` (3.7); `main._start_battle` bỏ qua kết quả `begin()` (E4). Không đụng ở story này.
- Mở trận chạy pha chuẩn bị: mọi test giao diện mới phải tính tới việc quân Nguyên đi lúc mở trận.

### Git Intelligence

- Commit gần nhất: `c49e7ac Sửa theo code review Story 2.6; xong Story 2.6`, `f99c0e6 Quân Nguyên đi và báo đòn (Story 2.6)`, `adf407e Kịch bản AI quân Nguyên chờ duyệt (Story 2.6)`. Mẫu commit tiếng Việt, kết `(Story X.Y)`, có `Co-Authored-By`.
- Cây làm việc có thay đổi hình E8 (`img/`, `ban-giao-asset.md`) không thuộc story: không gộp vào commit.
- Hiện có 519 test, 59 kịch bản đã duyệt.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh, cú pháp Godot 4. Lấy node bằng code tạo, không `/root/...`.
- M3: kịch bản trước, tác giả duyệt, trượt, rồi code; cấm sửa kịch bản đã duyệt.
- Ô đỏ báo đòn phải nổi bật nhất màn hình; số thứ tự lớn (GDD "Art Style", NFR9).
- Bật dev bằng `--dev`; GoPeak chỉ để nhìn và thử.
- Commit khi xanh, lời commit tiếng Việt.

### Quyết định của tác giả (2026-10-21)

1. **Kỵ binh tô đỏ ô nào?** **ĐÃ CHỐT: đường tới vật đầu tiên** (từ ô trước mặt Kỵ binh tới vật đầu tiên trên hàng, gồm ô đó; hàng trống thì tới mép), tính lại sau mỗi nước đi; số thứ tự ở ô sẽ bị trúng. (Phương án khác: chỉ ô vật đầu tiên; cả hàng tới mép.)

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Vật đầu tiên là rừng/kho lương/làng thì ô đó cũng đỏ và có số (đòn trúng vật cản, không ai mất máu: 2.8).
- Kỵ binh hàng trống: số ở ô sát mép (đòn sẽ trượt, nhưng người chơi vẫn thấy đòn và thứ tự).
- Đòn của chủ đã gục hoặc ô đích ngoài bàn: không vẽ (2.9 sẽ hủy hẳn).
- Số đặt ở góc dưới trái mặt ô; chấm máu ở góc dưới phải đồng quân.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.7 (dòng 742–760), FR24, NFR9; Story 2.8, 2.9 (dùng ô đích lúc ra đòn, hủy đòn).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` "Action Economy" (luật Kỵ binh, đòn gắn ô/hướng), giao diện (ô đỏ, số thứ tự lớn, mũi tên xung phong; dòng ~340, 371).
- `_bmad-output/planning-artifacts/game-architecture.md` M1, "Pha địch" (Kỵ binh: vật đầu tiên, sông không chắn), cây thư mục (`telegraph_view.gd`).
- `_bmad-output/implementation-artifacts/2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu.md` (Telegraph, review findings), `deferred-work.md`.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
