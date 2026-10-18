---
baseline_commit: 33634bdd90e446446a571a6ad919d9ba58537615
---

# Story 2.2: Sông và đánh trúng quân mình

Status: review

## Story

Là người chơi,
tôi muốn đẩy quân Nguyên xuống sông, và biết đòn của mình cũng trúng tướng mình,
để vừa có vũ khí mạnh vừa phải cẩn thận khi đứng.

_Story luật thứ hai của E2. Phần lớn luật đã có code từ Story 2.1 (`ForcedMove`, `Effects.move` chết đuối, va tướng mình). Story này chủ yếu là **đợt kịch bản cho tác giả duyệt**, test giao diện cho FR16 và trận thử để tác giả thấy trong game. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả._

## Acceptance Criteria

1. **Đợt duyệt kịch bản (M3).** **Cho** 3 kịch bản mới ở Dev Notes "Đợt kịch bản 4" (`da_duyet: false`). **Khi** gõ `tools/test.sh`, **thì** test xanh, có dòng `Kịch bản luật: 25 đã duyệt · 3 chưa duyệt (0 chưa đạt)`. Luật đã có từ 2.1 nên kịch bản mới **đạt ngay**, không có bước "phải trượt": thay bằng **phá thử** ở AC 3 (xem "Quyết định mặc định").

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh`. Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại. Nếu lý do "sai" là **luật khác với code 2.1** thì AI dừng, hỏi tác giả, rồi sửa code theo luật mới (có test đi kèm). Không sửa kịch bản cho khớp code.
2. **Khi** tác giả duyệt hết, **thì** `tools/test.sh` xanh, có dòng `Kịch bản luật: 28 đã duyệt · 0 chưa duyệt (0 chưa đạt)`; kiểm ranh giới đạt; `BattleState.validate()` rỗng sau mỗi lệnh.
3. **Kịch bản bắt lỗi thật.** Mỗi kịch bản mới được phá thử ít nhất một lần (sửa tạm code luật, thấy kịch bản đó trượt, trả lại, ghi Debug Log). Danh sách ở Task 3.
4. **Sông (FR28).** **Khi** quân Nguyên bị đẩy xuống sông, **thì** nó chết đuối và bị nhấc khỏi bàn (sự kiện `MOVED` `PUSH` rồi `DROWNED`, không có `DAMAGED`, không có `DIED`).
5. **Tướng bị đẩy vào sông.** **Khi** tướng bị đẩy vào sông, **thì** tướng mất 1 máu, đứng yên. Hiện chưa đòn nào đẩy được tướng (xem "Quyết định của tác giả", câu 1). Ca này **chỉ có test GUT** (`test_forced_move.gd`, `test_general_pushed_into_river_collides`, đã có từ 2.1), không có kịch bản.
6. **Không chọn tướng mình làm mục tiêu (FR16).** **Cho** Nguyễn Khoái đang được chọn, đứng kề Phạm Ngũ Lão. **Khi** bấm vào Phạm Ngũ Lão, **thì** game chuyển sang chọn Phạm Ngũ Lão: không có đòn đánh nào, không ai mất máu, Lão không có viền mục tiêu. Đúng cả khi Khoái **đã đi** và đang chờ xác nhận một mục tiêu khác: chờ xác nhận bị bỏ, dòng "Bấm lần nữa để đánh" mất.
7. **Đẩy trúng tướng mình.** **Khi** Nguyễn Khoái đẩy một quân Nguyên va vào tướng mình, **thì** cả quân Nguyên và tướng mình đều mất 1 máu. Tướng còn 0 máu thì gục và bị nhấc khỏi bàn (mặc định của GDD, duyệt qua kịch bản `va_cham/tuong_minh_guc_vi_va.json`). Thắng/thua chưa có (Story 2.5).
8. **Trận thử** (tác giả chốt câu 2 (a)): `tools/chay.sh --dev --tran=thu_day` mở trận "Thử đẩy". Tác giả làm được trong game: đẩy Bộ binh xuống sông, đẩy Bộ binh va vào tướng mình, bấm tướng mình đứng kề thì chuyển chọn.
9. **Kịch bản.** Có kịch bản trong `dia_hinh/` (sông) và `va_cham/` (trúng quân mình), đã duyệt và đạt.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt 2 câu hỏi** ở "Quyết định của tác giả" (2026-10-18, cả 2 câu chọn (a)).
- [x] **Task 1: Viết đợt kịch bản 4, dừng chờ duyệt** (AC: 1)
  - [x] 1.1 Tạo thư mục `game/tests/kich_ban/dia_hinh/`. Viết 3 file đúng như Dev Notes "Đợt kịch bản 4", `"da_duyet": false`. Không đụng 25 kịch bản đã duyệt. Không cần sửa bộ nạp: `truoc.mau`, `sau.mau`, `sau.da_danh`, ô sông `~` đều đã đọc được.
  - [x] 1.2 `tools/xem_kich_ban.sh dia_hinh` và `tools/xem_kich_ban.sh va_cham`: đọc lại bàn trước/sau, khớp `mo_ta`; Lão 1 máu ở bàn trước của #3 hiện đúng. `tools/test.sh`: xanh, `25 đã duyệt · 3 chưa duyệt (0 chưa đạt)`. Ghi Debug Log.
  - [x] 1.3 Commit: `Kịch bản sông, trúng quân mình chờ duyệt (Story 2.2)`.
  - [x] 1.4 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh dia_hinh` rồi `tools/xem_kich_ban.sh va_cham`, đọc 3 kịch bản mới (`day_xuong_song`, `day_trung_tuong_minh`, `tuong_minh_guc_vi_va`), trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ ba điều:
    - Bộ binh trúng đòn còn 1 máu, nên xuống sông hay va bờ đều biến khỏi bàn: **bàn sau giống nhau**. Kịch bản #1 bắt được lỗi "quân đứng trên sông"; còn "chết đuối hay gục" thì test GUT kiểm (sự kiện khác nhau, cần cho hoạt ảnh 2.11).
    - Kịch bản #3 chốt luật mặc định "tướng gục bị nhấc khỏi bàn, không chiếm ô" (GDD, [KIỂM TRA KHI PLAYTEST E4]).
    - Bộ binh ở góc `6,6` chỉ để trận chưa thắng khi Story 2.5 thêm luật thắng/thua.
  - [x] 1.5 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì xử lý theo AC 1. Ghi Debug Log.
- [x] **Task 2: Test giao diện FR16** (AC: 6)
  - [x] 2.1 `tests/test_battle_view.gd`: thêm trận thử `_make_ally_main()` viết vào `user://` theo mẫu `_make_attack_main()` (file khác trong `ATTACK_DIR`, hoặc thư mục riêng; xóa ở `after_each` như các trận thử hiện có). Bố cục: Khoái `3,4`, Lão `2,4` (kề Tây Khoái), Bộ binh `3,3` (kề Bắc Khoái), Bộ binh `6,6`; `thu_tu_dich` `["3,3", "6,6"]`. Ba ca:
    - **Không có viền ở tướng mình:** phím `1` thật → `target_cells()` là `[3,3]`, không có `2,4`.
    - **Bấm tướng mình kề bên là chuyển chọn (chưa đi):** phím `1`, kiểm trước `target_cells()` có `3,3`; bấm Lão bằng `_click_by_mouse` → `selected_id()` là 2; Bộ binh `3,3` vẫn 3 máu; Lão vẫn 3 máu; Khoái `has_attacked` false; `_board(main).target_cells()` rỗng (Lão chưa có đòn).
    - **Đang chờ xác nhận mà bấm tướng mình:** phím `1`, bấm `4,3` (Khoái đi 2 bước `3,4` → `4,4` → `4,3`, lúc đó Bộ binh `3,3` kề Tây); bấm Bộ binh một lần → kiểm trước `pending_cell()` là `3,3` và dòng nhắc là `tr("hud.confirm_attack")`; bấm Lão → `selected_id()` là 2, `_view(main).pending_cell()` và `_board(main).pending_cell()` là `BoardView.NO_CELL`, `_hud(main).hint_text()` rỗng, Bộ binh vẫn 3 máu.
  - [x] 2.2 Phá thử (ghi Debug Log): cho `_on_cell_clicked` gửi lệnh đánh khi bấm vào tướng mình có trong `_targets`, hoặc đưa ô tướng mình vào `RulesAttack.targets` → ca thứ nhất và thứ hai phải trượt (và `danh/khong_danh_duoc.json` trượt); bỏ `_set_pending(NO_CELL)` trong `_select` → ca thứ ba phải trượt.
- [x] **Task 3: Phá thử luật cho kịch bản mới** (AC: 3). Mỗi lần sửa tạm **một** chỗ, chạy `tools/test.sh`, ghi tên kịch bản và test GUT trượt vào Debug Log, trả lại ngay:
  - [x] 3.1 `Effects.move` bỏ nhánh chết đuối (quân Nguyên vào sông như ô trống) → `dia_hinh/day_xuong_song.json` trượt (Bộ binh 1 máu đứng trên sông, `validate()` báo, lệnh bị quay lại) và `test_nguyen_unit_drowns_in_river` trượt.
  - [x] 3.2 `ForcedMove.run` coi sông như vật cản với mọi quân (gọi `_hit_obstacle` cho cả quân Nguyên) → **kịch bản không trượt** (bàn sau giống nhau, xem Task 1.4); `test_nguyen_unit_drowns_in_river` phải trượt. Ghi đúng như vậy vào Debug Log.
  - [x] 3.3 Va quân khác chỉ trừ máu quân bị va khi nó là quân Nguyên (bỏ máu tướng) → `va_cham/day_trung_tuong_minh.json`, `va_cham/tuong_minh_guc_vi_va.json` và `test_collision_with_general_hurts_general` trượt.
  - [x] 3.4 `Effects.damage` không nhấc tướng gục khỏi bàn (chỉ nhấc quân Nguyên) → `va_cham/tuong_minh_guc_vi_va.json` trượt (hoặc `validate()` báo máu < 1). Ghi lại kịch bản nào và câu lỗi nào.
  - [x] 3.5 Sau cùng `tools/test.sh` xanh như AC 2.
- [x] **Task 4: Trận thử `thu_day`** (AC: 8; tác giả chốt câu 2 (a))
  - [x] 4.1 `game/data/tran/thu_day.json` (MỚI) đúng bố cục ở Dev Notes "Trận thử `thu_day`". Không đổi `tran_01.json`, `thu_ba_tuong.json`.
  - [x] 4.2 `tests/test_loaders.gd`: thêm `test_real_push_trial_level_loads` theo mẫu `test_real_three_generals_level_loads` (không lỗi, không cảnh báo, 3 tướng, 3 quân Nguyên, ô `3,2` là sông).
  - [x] 4.3 Không cần sửa `launch_options.gd`: `--tran=<tên file>` đã mở được trận thử khi bật dev (Story 1.2). Kiểm `[INFO][battle] nạp trận thu_day` trong log.
- [x] **Task 5: Tài liệu, kiểm bằng mắt, commit** (AC: 2, 6–9)
  - [x] 5.1 Câu 1 (a): sửa `gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 223, thay "(chỉ xảy ra khi trúng đòn của Nguyễn Khoái)" bằng ghi chú "hiện chưa đòn nào đẩy được tướng (đòn địch không đẩy, không chọn được tướng mình làm mục tiêu); luật giữ sẵn trong code" và thêm "Chốt 2026-10-18". Không sửa chỗ nào khác của GDD.
  - [x] 5.2 `game-architecture.md`: cây thư mục `data/tran/` thêm `thu_day.json`  cạnh `tran_01.json …`. Nhóm `dia_hinh/` đã có trong cây `kich_ban/`.
  - [x] 5.3 Kiểm bằng mắt : chạy `tools/chay.sh --dev --tran=thu_day` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action` cho phím (`select_general_1`, `end_turn`…), `inject_mouse_click` theo pixel = vị trí bàn `(486, 141)` + `BoardView.cell_center` (cách tính như Debug Log 2.1). Làm theo "Hướng dẫn tác giả tự test" ở Dev Notes, `capture_screenshot` sau mỗi bước chính, lưu `_bmad-output/implementation-artifacts/anh/2-2-*.png` (ít nhất: chọn Khoái thấy viền ở Bộ binh, không có viền ở Lão; sau khi đẩy vào Dư; sau khi đẩy xuống sông). Tắt game. Log không có ERROR/WARN.
  - [x] 5.4 `tools/test.sh` xanh (AC 2). Commit một lần: kịch bản đã duyệt, test, trận thử, tài liệu. Ví dụ: `Sông và đánh trúng quân mình (Story 2.2)`.
  - [x] 5.5 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, dùng kết quả thật (số test thật).

## Dev Notes

### Bối cảnh

- Story 2.1 đã làm xong luật cho cả hai ca của story này (Dev Notes 2.1, "Va chạm với tướng mình, sông"):
  - `Effects.move` (`game/src/core/effects.gd:8`): quân Nguyên vào ô sông thì `_remove` rồi ghi `DROWNED`.
  - `ForcedMove.run` (`game/src/core/forced_move.gd:14`): ô kế là sông mà quân bị đẩy là tướng thì `_hit_obstacle` (đứng yên, `COLLIDED` other 0, `DAMAGED` 1). Ô kế có quân khác (mọi phe) thì `COLLIDED`, quân bị đẩy mất máu trước, quân bị va sau.
  - `RulesAttack.targets` chỉ lấy ô có quân Nguyên; đánh ô có tướng mình bị từ chối `NO_TARGET` (kịch bản `danh/khong_danh_duoc.json` đã duyệt).
  - `BattleView._on_cell_clicked` (`game/src/battle/battle_view.gd:79`): bấm tướng mình là chọn tướng đó, xét **trước** nhánh mục tiêu. `_select` xóa chờ xác nhận.
  - Test GUT đã có: `test_nguyen_unit_drowns_in_river`, `test_general_pushed_into_river_collides`, `test_collision_with_general_hurts_general`, `test_collision_can_kill_both` (`game/tests/test_forced_move.gd`); `test_click_on_lao_switches_to_him` (1.4, chưa có Khoái kề Lão, chưa có mục tiêu).
- Vì vậy story này **không viết code luật mới**, trừ khi tác giả nói kịch bản "sai" vì luật khác (AC 1). Việc chính: kịch bản cho tác giả duyệt, phá thử, test giao diện FR16, trận thử.
- **Chưa có:** lao (2.3), kéo (2.4; kéo qua sông cũng đi qua `ForcedMove.run`, sẽ chết đuối đúng bảng), thắng/thua (2.5), AI và đòn địch (2.6–2.9), hoạt ảnh chết đuối (2.11), xem trước (2.12).
- Tác giả không đọc code. Thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Luật (spec) **[FR16, FR17, FR28; GDD dòng 196, 223; kiến trúc "Bảng thứ tự phân giải"]**

- **Sông `~`:** không đi vào được, không chặn lao và tên. Quân Nguyên bị đẩy hoặc kéo xuống sông thì **chết ngay** (bị nhấc khỏi bàn). Tướng bị đẩy vào sông: tính như va chạm, **mất 1 máu, đứng yên**.
- **Đòn trúng mọi phe (FR16):** không được chọn tướng mình làm mục tiêu. Bấm vào tướng mình luôn là chọn tướng đó. Tướng mình chỉ trúng đòn như hệ quả: bị quân khác va vào (story này), lao trúng vật đầu tiên trên hàng (2.3).
- **Va chạm:** quân bị đẩy gặp quân khác (bất kể phe) thì dừng, cả hai mất 1 máu, quân bị đẩy mất trước. Máu về 0 thì gục, bị nhấc khỏi bàn, **cả tướng** (mặc định GDD dòng 85, [KIỂM TRA KHI PLAYTEST E4]; phương án thay thế: để xác lại làm vật cản).
- Với chỉ số hiện tại: Bộ binh 3 máu trúng đòn Khoái (2) còn 1 rồi bị đẩy; xuống sông thì chết đuối, va gì cũng gục. Tướng 3 máu bị va còn 2.

### Đợt kịch bản 4

Quy ước như đợt 1–3: `phien_ban_dinh_dang: 1`, bàn 7×7, ô cách nhau một dấu cách, `sau.dia_hinh` chép y `truoc.dia_hinh`. Tọa độ `cot,hang`; ô không nêu là đất trống `.`, không có quân. Chỉ ghi `mau` cho quân không đủ máu. Mọi kịch bản ghi `sau.da_danh`. Không có `ket_thuc_luot`. Mỗi kịch bản có thêm **Bộ binh ở `6,6`** không ai đụng tới, để Story 2.5 (thắng khi hết quân Nguyên) không làm đổi ý nghĩa kịch bản.

| # | File | `mo_ta` | Bàn trước | `hanh_dong` | Bàn sau |
|---|---|---|---|---|---|
| 1 | `dia_hinh/day_xuong_song.json` | `Nguyễn Khoái đánh Bộ binh đứng cạnh sông: Bộ binh còn 1 máu, bị đẩy xuống sông, chết đuối, biến khỏi bàn.` | địa hình: `~` ở 4,3; quân: `1` ở 2,3; `B` ở 3,3; `B` ở 6,6 | `danh 1 → 3,3` | địa hình như trước; quân: `1` ở 2,3; `B` ở 6,6; `da_danh: ["1"]` |
| 2 | `va_cham/day_trung_tuong_minh.json` | `Bộ binh bị đẩy va vào Phạm Ngũ Lão: cả hai mất 1 máu. Bộ binh gục, Lão còn 2 máu.` | `2` ở 3,2; `B` ở 3,3; `1` ở 3,4; `B` ở 6,6 | `danh 1 → 3,3` | `2` ở 3,2, `mau 3,2: 2`; `1` ở 3,4; `B` ở 6,6; `da_danh: ["1"]` |
| 3 | `va_cham/tuong_minh_guc_vi_va.json` | `Phạm Ngũ Lão chỉ còn 1 máu bị Bộ binh va vào: cả hai gục, Lão bị nhấc khỏi bàn.` | `2` ở 3,2, `truoc.mau 3,2: 1`; `B` ở 3,3; `1` ở 3,4; `B` ở 6,6 | `danh 1 → 3,3` | `1` ở 3,4; `B` ở 6,6; `da_danh: ["1"]` |

Ví dụ lớp quân bàn trước của #2 (hàng 0 ở trên):

```
. . . . . . .
. . . . . . .
. . . 2 . . .
. . . B . . .
. . . 1 . . .
. . . . . . .
. . . . . . B
```

Mỗi kịch bản thử đúng điều `mo_ta` nói (đã kiểm khi tạo story, dev kiểm lại và ghi Debug Log):
- **#1:** hướng đánh `2,3` → `3,3` là Đông, nên đẩy sang `4,3` (sông). Quân Nguyên vào sông mà không chết đuối thì Bộ binh 1 máu đứng trên sông: `validate()` báo "đứng trên ô không đi vào được", lệnh bị quay lại, bàn sau khác: trượt. Coi sông như vật cản thì Bộ binh cũng gục: **bàn sau giống**, không trượt (test GUT bắt, Task 3.2).
- **#2:** đẩy lên Bắc vào Lão ở `3,2`. Không trừ máu tướng bị va thì Lão còn 3 máu: trượt. Chỉ trừ máu Lão mà quên Bộ binh thì Bộ binh còn 1 máu ở `3,3`: trượt.
- **#3:** như #2 nhưng Lão chỉ còn 1 máu. Tướng gục mà không bị nhấc khỏi bàn thì `validate()` báo máu < 1 hoặc Lão còn trên bàn: trượt.
- Không viết thêm kịch bản ngoài 3 cái này. Ca "Khoái không đánh được tướng mình" đã có ở `danh/khong_danh_duoc.json` (đã duyệt).

### Hiện trạng các file liên quan (đọc cả file trước khi sửa)

- `game/src/data/scenario_loader.gd`: `BEFORE_KEYS` có `mau`; `_read_hp` cho máu từ 1 tới máu tối đa, ô phải có quân. `sau` không bắt buộc đủ tướng: tướng gục không có trong `sau.quan` là đúng. `da_danh` chỉ được ghi tướng có trong `sau.quan`.
- `game/tests/scenario_runner.gd:177`: so `da_danh` bỏ qua tướng không còn trên bàn (mục hoãn của review 2.1). Với #3 thì đúng: Lão đã gục, không có gì để so; ô `3,2` vẫn được so là trống.
- `game/tests/test_battle_view.gd`: `_make_attack_main()` (dòng ~525) là mẫu trận thử viết vào `user://`; `_click_by_mouse`, `_press_physical(main, KEY_1)`, `_view(main).selected_id()`, `target_cells()`, `pending_cell()`, `_board(main).pending_cell()`, `_hud(main).hint_text()` đều đã có.
- `game/src/battle/battle_view.gd`: `_on_cell_clicked` xét tướng mình trước mục tiêu; `_select` gọi `_set_pending(NO_CELL)`. Không cần sửa, chỉ thêm test. Mục hoãn review 2.1: bấm **tướng đã đánh** khi đang chờ xác nhận thì không bỏ chờ (chưa gặp được vì chỉ Khoái có đòn; không làm ở story này).
- `game/data/tran/`: `tran_01.json` (2 tướng, sông cột 3 trừ hàng 3), `thu_ba_tuong.json` (3 tướng). Không trận nào cho Khoái đẩy Bộ binh xuống sông ngay từ đầu: Bộ binh nào kề sông cũng không có ô cho Khoái đứng đẩy về phía sông, còn quân Nguyên chưa biết đi (AI ở 2.6). Vì vậy cần câu 2.
- `game/tests/test_loaders.gd:600`: `test_real_three_generals_level_loads` là mẫu cho Task 4.2.

### Trận thử `thu_day` (tác giả chốt câu 2 (a))

`game/data/tran/thu_day.json`, `"ten": "Thử đẩy"`, `"kieu": "tieu_diet"`, `"tiep_vien": []`, `"muu_ke_mo": []`, `"thu_tu_dich": ["2,2", "1,4", "6,6"]`.

```
dia_hinh                quan
. . . . . . .           . . . . . . .
. . . ~ . . .           . . . . . . .
. . . ~ . . .           . . B . . . .
. . . . . . .           2 1 . . . . .
. . . . . . .           . B . . . . .
. . . . . . .           . 3 . . . . .
. . . . . . .           . . . . . . B
```

- Khoái `1,3`: kề Bắc là ô trống, kề Tây là Lão `0,3` (tướng mình, không viền), kề Nam là Bộ binh `1,4` (có viền). Bộ binh `2,2` đứng **chéo** Khoái nên chưa có viền.
- Lượt 1: đánh Bộ binh `1,4` (chưa đi, một cú bấm) → bị đẩy xuống Nam, va Dư `1,5` → Bộ binh gục, Dư còn 2 máu.
- Lượt 2: Khoái đi `1,3` → `1,2` (1 bước), đánh Bộ binh `2,2` (đã đi: bấm hai lần) → bị đẩy sang Đông vào sông `3,2` → chết đuối.
- Bộ binh `6,6` để trận chưa kết thúc khi có Story 2.5.
- Dev kiểm bằng `LevelLoader` (Task 4.2) và chạy game thật (Task 5.3). Bố cục sai so với bảng trên thì báo lại, không tự đổi.

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm.
- Chỉ `Effects.damage` sửa máu và xử lý gục; chỉ `Effects.move` sửa ô; nhấc quân khỏi bàn cũng chỉ ở `Effects`. Đẩy, kéo chỉ qua `ForcedMove.run`.
- Chỉ `BattleController` giữ state sống; UI gửi `Command` qua `submit()`, đọc bản chụp.
- Chữ hiện lên màn hình qua `tr()`. Test so chữ trên màn hình thì so với `tr("<khóa>")`, không ghi cứng câu tiếng Việt (review 2.1).
- File trận là dữ liệu do tác giả sửa: tên `snake_case` tiếng Việt không dấu; chỉ mở được bằng `--tran=` khi bật dev.

### Testing

- `tools/test.sh` là lệnh duy nhất. Kịch bản mới chạy qua bộ chạy kịch bản như cũ; không thêm test riêng cho từng kịch bản.
- Test giao diện qua `main.tscn` thật (`_make_main`), phím gửi bằng `InputEventKey` có `physical_keycode`, chuột bằng sự kiện thật qua `_unhandled_input` (`_click_by_mouse`). Trận thử viết vào `user://` rồi xóa ở `after_each`.
- Test giao diện phải kiểm **cả điều kiện trước** (Khoái đang chọn, Bộ binh có viền, đang chờ xác nhận) rồi mới bấm Lão, để test không đạt "nhờ may" (review 1.5, 1.7).
- Mỗi test hành vi mới phải phá thử (Task 2.2, Task 3): sửa tạm, thấy trượt, trả lại, ghi Debug Log.
- Mẫu hướng dẫn tác giả tự test (Completion Notes):
  1. `tools/test.sh`: thấy `Kịch bản luật: 28 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ … test đạt`.
  2. `tools/chay.sh --dev --tran=thu_day`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
  3. Gõ `1` chọn Khoái: viền trắng quanh Bộ binh ở dưới Khoái; Lão bên trái Khoái **không** có viền; Bộ binh chéo phía trên phải không có viền.
  4. Bấm Lão: game chuyển sang chọn Lão (vòng vàng ở Lão, ô xanh của Lão), không ai mất máu.
  5. Gõ `1`, bấm Bộ binh dưới Khoái: Bộ binh biến khỏi bàn; Dư (dưới Bộ binh) còn **2** máu.
  6. Gõ `Space`. Gõ `1`, bấm ô ngay trên Khoái (Khoái đi lên). Bấm Bộ binh bên phải Khoái **hai lần** (lần đầu hiện "Bấm lần nữa để đánh"): Bộ binh bị đẩy xuống sông, biến khỏi bàn.
  - Nhắc: trên Mac F1 là Fn+F1.

### Previous Story Intelligence (Story 2.1 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log phải giống nhau; mọi chỗ làm khác Tasks ghi vào "Lệch so với Tasks"; task chụp ảnh thì phải có file ảnh.
- **Review 2.1 bắt được:** test ghi cứng chữ tiếng Việt (dùng `tr()`); thiếu ca cho Dư khi Tasks đòi "Lão và Dư"; so trạng thái mà bỏ sót cờ (`has_attacked`). Story này: test FR16 phải so máu **và** cờ `has_attacked` của Khoái.
- **`sat_thuong` tối thiểu 1** (review 2.1, tác giả chốt): `Effects.damage` assert `amount > 0`; đừng gọi `Effects.damage` với 0 trong test.
- **`Grid.dir_between` assert hai ô kề** (review 2.1).
- **Phím thật:** test phải gửi `InputEventKey` với `physical_keycode`. GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node (`_input`…), GUT bỏ qua cả file.
- **Chuột đứng yên:** sau khi bàn đổi, ô dưới chuột phải chọn lại (`BattleInput.refresh_hover`); `_select` đã gọi.
- **Mục hoãn liên quan** (`deferred-work.md`, review 2.1): pha chờ xác nhận không bỏ khi bấm tướng đã đánh (không làm ở đây); bộ chạy bỏ qua tướng đã gục khi so `da_danh` (đúng cho #3, xem trên); `rolled_back` chưa báo người chơi (Task 3.1 sẽ thấy lệnh bị quay lại chỉ trong log).

### Git Intelligence

- Commit gần nhất: `33634bd Sửa theo code review Story 2.1; xong Story 2.1`, `449b381 Nguyễn Khoái đánh, đẩy, va chạm (Story 2.1)`, `6e3966e Kịch bản đánh, đẩy, va chạm chờ duyệt (Story 2.1)`. Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- Mẫu 2 commit cho story luật: một commit "kịch bản … chờ duyệt", một commit code khi xanh.
- Tổng test hiện tại: 376/376; kịch bản 25 đã duyệt.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- JSON trả số là `float`: bộ nạp đã `int()` máu và tọa độ.
- Quy trình M3: AI viết kịch bản `da_duyet: false` → tác giả duyệt → test → code. **Cấm** sửa hoặc xóa kịch bản đã duyệt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả, không tự đoán.
- Không chọn được tướng mình làm mục tiêu; đòn trúng mọi phe như hệ quả.
- Không `assert` cho lỗi dữ liệu (file trận, chỉ số); bộ nạp trả `LoadResult` với câu lỗi tiếng Việt.
- Bật dev bằng `--dev`; `--tran=` chỉ có tác dụng khi bật dev.
- Commit khi xanh, lời commit tiếng Việt. Không `push --force`.

### Quyết định của tác giả (2026-10-18)

_Tác giả chốt 2026-10-18: câu 1 chọn (a), câu 2 chọn (a)._

1. **"Tướng bị đẩy vào sông" hiện không xảy ra được trong game.** GDD dòng 223 ghi "chỉ xảy ra khi trúng đòn của Nguyễn Khoái", nhưng từ 2026-10-17 Khoái không chọn được tướng mình làm mục tiêu; đòn địch không đẩy (FR21); Dư không kéo được tướng. Code 2.1 đã có nhánh này và có test GUT.
   - (a) **ĐÃ CHỐT:** giữ luật trong code và test GUT (để sẵn cho mưu kế hoặc tướng mở khóa về sau), không viết kịch bản; sửa câu ở GDD dòng 223 cho đúng (Task 5.1).
   - (b) Bỏ nhánh này khỏi code (tướng không bao giờ bị đẩy); viết lại khi có đòn đẩy được tướng.
2. **Thử trong game.** Trận 1 và `thu_ba_tuong` không cho Khoái đẩy Bộ binh xuống sông ngay (quân Nguyên chưa biết đi tới khi có AI ở 2.6).
   - (a) **ĐÃ CHỐT:** thêm trận thử mới `thu_day` (chỉ mở khi `--dev`, bố cục ở Dev Notes): thử được đẩy xuống sông, đẩy va tướng mình, bấm tướng mình đứng kề. Dùng lại cho 2.3, 2.4 nếu cần.
   - (b) Sửa bố cục `thu_ba_tuong` (hướng dẫn tự test của 2.1 sẽ không còn đúng).
   - (c) Không thử trong game ở story này: chỉ duyệt kịch bản; thấy trong game từ 2.6.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Kịch bản mới đạt ngay (luật đã có từ 2.1), nên bước "kịch bản mới phải trượt" của M3 thay bằng **phá thử** từng kịch bản (Task 3). Lý do: không xóa code đã duyệt chỉ để thấy đỏ.
- Mỗi kịch bản có một Bộ binh ở `6,6` để Story 2.5 không biến chúng thành ca "thắng".
- Tướng gục vì va chạm bị nhấc khỏi bàn như quân Nguyên (mặc định GDD), duyệt qua kịch bản #3.
- Quân Nguyên chết đuối: chỉ có `DROWNED`, không có `DAMAGED`, `DIED` (như code 2.1). Story 2.5 kiểm thắng sau cả `DIED` lẫn `DROWNED`.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.2 (dòng 560–581), FR16 (dòng 44), FR17 (dòng 47), FR21 (dòng 53), FR28 (dòng 68).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 85 (tướng gục), 196 (không chọn tướng mình), 223 (sông).
- `_bmad-output/planning-artifacts/game-architecture.md` "Bảng thứ tự phân giải" (dòng 788–845), cây thư mục (dòng 603, 612–613).
- `_bmad-output/implementation-artifacts/2-1-nguyen-khoai-danh-day-va-va-cham.md` (Dev Notes "Di chuyển cưỡng bức", "Va chạm với tướng mình, sông", "Bấm chuột khi đang chọn tướng"; Review Findings), `deferred-work.md` (mục review 2.1).
- `_bmad-output/project-context.md` (M3, test, những điều không được quên).

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1.1–1.2 (2026-10-18): viết 3 kịch bản đợt 4 (`dia_hinh/day_xuong_song.json`, `va_cham/day_trung_tuong_minh.json`, `va_cham/tuong_minh_guc_vi_va.json`), `da_duyet: false`. `tools/xem_kich_ban.sh dia_hinh` và `va_cham`: bàn trước/sau khớp `mo_ta`; #1 sông ở `4,3`, Khoái `2,3` đánh Đông; #2 Lão ở bàn sau hiện `3,2 Phạm Ngũ Lão 2/3`; #3 bàn trước hiện `Máu: 3,2 Phạm Ngũ Lão 1/3`, bàn sau không còn Lão. `tools/test.sh`: xanh 376/376, `Kịch bản luật: 25 đã duyệt · 3 chưa duyệt (0 chưa đạt)`.

- Task 1.4–1.5 (2026-10-18): tác giả trả lời "đúng" cho cả 3 kịch bản. Đổi `da_duyet: true` (chỉ khóa đó). `tools/test.sh`: 376/376, `Kịch bản luật: 28 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Task 2.1: thêm `_make_ally_main()` (thư mục riêng `ALLY_DIR = user://test_battle_view/tran_dong_minh`, xóa ở `after_each`) và 3 test: `test_ally_next_to_khoai_has_no_outline`, `test_click_adjacent_ally_switches_selection`, `test_click_ally_while_confirming_cancels_confirm`. Gom phần ghi file trận thử vào `_make_level_main(dir, path, level)`, `_make_attack_main()` dùng lại. `tools/test.sh`: 379/379.
- Task 2.2 phá thử:
  - (a) `RulesAttack.targets` lấy mọi quân kề (bỏ điều kiện phe) **và** `_on_cell_clicked` xét mục tiêu trước tướng mình → 5 trượt: `test_ally_next_to_khoai_has_no_outline`, `test_click_adjacent_ally_switches_selection` (Lão bị đánh, bị đẩy khỏi `2,4` nên có thêm SCRIPT ERROR `hp` trên Nil ở dòng kiểm máu Lão), `test_rules_attack.gd › test_rejections_keep_state`, `test_targets_are_adjacent_nguyen_units_in_direction_order`, và kịch bản `danh/khong_danh_duoc.json` ("kịch bản ghi tu_choi khong_co_dich nhưng luật cho chạy"). Trả lại.
  - (b) Bỏ `_set_pending(BoardView.NO_CELL)` trong `_select` → chỉ `test_click_ally_while_confirming_cancels_confirm` trượt. Trả lại.
- Task 3 phá thử luật (mỗi lần một chỗ, trả lại ngay, `git diff --quiet game/src` sau mỗi lần):
  - 3.1 `Effects.move` bỏ nhánh chết đuối → 2 trượt: `test_nguyen_unit_drowns_in_river`; kịch bản `dia_hinh/day_xuong_song.json`: "vi phạm bất biến: quân 101 ở ô 4,3 đứng trên ô không đi vào được".
  - 3.2 `ForcedMove.run` coi sông là vật cản với mọi quân → 1 trượt: `test_nguyen_unit_drowns_in_river`. Kịch bản **không** trượt (bàn sau giống nhau, đúng như Task 1.4 đã báo tác giả).
  - 3.3 Chỉ trừ máu quân bị va khi nó là quân Nguyên → 2 trượt: `test_collision_with_general_hurts_general`; `test_approved_scenarios_pass` với cả hai kịch bản (`build/test/kich_ban.txt`): `va_cham/day_trung_tuong_minh.json` "ô 3,2 mong đợi 2 máu, thực tế 3 máu" và `va_cham/tuong_minh_guc_vi_va.json` "ô 3,2 mong đợi trống, thực tế 2 (Phạm Ngũ Lão, 1 máu)". Tóm tắt `tools/test.sh` chỉ in câu lỗi đầu tiên của test đó.
  - 3.4 `Effects.damage` chỉ nhấc quân Nguyên gục → 1 trượt: kịch bản `va_cham/tuong_minh_guc_vi_va.json` "vi phạm bất biến: quân 2 ở ô 3,2 có máu 0, cần từ 1 tới 3".
  - 3.5 Sau khi trả lại: 379/379 xanh.
- Task 4: viết `test_real_push_trial_level_loads` trước → trượt (chưa có file). Tạo `game/data/tran/thu_day.json` đúng bố cục Dev Notes → 380/380.
- Task 5.3 kiểm bằng mắt: `tools/chay.sh --dev --tran=thu_day` chạy nền; pixel = `(486 + (cột − hàng)·64, 141 + (cột + hàng)·32 + 32)`. Log: `[INFO][battle] nạp trận thu_day`, không ERROR/WARN. Ảnh `anh/2-2-1` … `2-2-5`: (1) phím 1: viền trắng chỉ ở Bộ binh `1,4`, Lão và Bộ binh `2,2` không viền; (2) bấm Lão: vòng vàng chuyển sang Lão, ô xanh của Lão, không ai mất máu; (3) phím 1, bấm Bộ binh `1,4`: Bộ binh biến mất, Dư 2 máu, Khoái xám; (4) Space, phím 1, đi `1,2`, bấm Bộ binh `2,2`: viền chờ xác nhận, dòng "Bấm lần nữa để đánh"; (5) bấm lần hai: Bộ binh xuống sông, biến khỏi bàn. Tắt game (mã thoát 143 do mình tắt).
- Task 5.4: `tools/test.sh` 380/380, `Kịch bản luật: 28 đã duyệt · 0 chưa duyệt (0 chưa đạt)`, kiểm ranh giới đạt.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Story 2.2 không viết code luật mới: luật sông và va tướng mình đã có từ 2.1. Thêm 3 kịch bản (tác giả duyệt cả 3), 3 test giao diện FR16, 1 test nạp trận, trận thử `thu_day`, sửa GDD dòng 223 và cây thư mục kiến trúc.
- Tổng test: 376 → 380 (3 test giao diện + 1 test nạp trận). Kịch bản: 25 → 28 đã duyệt.
- Lệch so với Tasks: không có. Ghi thêm: Task 2.2 phá thử (a) làm trượt thêm 2 test của `test_rules_attack.gd` ngoài các ca đã nêu; Task 3.3 thấy cả hai kịch bản trượt trong `build/test/kich_ban.txt`, còn tóm tắt chỉ in câu đầu.
- **Hướng dẫn tác giả tự test:**
  1. `tools/test.sh`: thấy `Kịch bản luật: 28 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ 380/380 test đạt`.
  2. `tools/chay.sh --dev --tran=thu_day`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
  3. Gõ `1` chọn Khoái: viền trắng quanh Bộ binh ở dưới Khoái; Lão bên trái Khoái **không** có viền; Bộ binh chéo phía trên phải không có viền.
  4. Bấm Lão: game chuyển sang chọn Lão (vòng vàng ở Lão, ô xanh của Lão), không ai mất máu.
  5. Gõ `1`, bấm Bộ binh dưới Khoái: Bộ binh biến khỏi bàn; Dư (dưới Bộ binh) còn **2** máu.
  6. Gõ `Space`. Gõ `1`, bấm ô ngay trên Khoái (Khoái đi lên). Bấm Bộ binh bên phải Khoái **hai lần** (lần đầu hiện "Bấm lần nữa để đánh"): Bộ binh bị đẩy xuống sông, biến khỏi bàn.
  - Ảnh mẫu: `_bmad-output/implementation-artifacts/anh/2-2-1` … `2-2-5`.

### File List

- `game/tests/kich_ban/dia_hinh/day_xuong_song.json` (mới)
- `game/tests/kich_ban/va_cham/day_trung_tuong_minh.json` (mới)
- `game/tests/kich_ban/va_cham/tuong_minh_guc_vi_va.json` (mới)
- `game/tests/test_battle_view.gd` (sửa)
- `game/tests/test_loaders.gd` (sửa)
- `game/data/tran/thu_day.json` (mới)
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` (sửa dòng 223)
- `_bmad-output/planning-artifacts/game-architecture.md` (sửa cây thư mục)
- `_bmad-output/implementation-artifacts/anh/2-2-1-chon-khoai-vien-bo-binh.png`, `2-2-2-bam-lao-chuyen-chon.png`, `2-2-3-day-va-du.png`, `2-2-4-cho-xac-nhan-canh-song.png`, `2-2-5-day-xuong-song.png` (mới)
- `_bmad-output/implementation-artifacts/2-2-song-va-danh-trung-quan-minh.md`, `sprint-status.yaml` (sửa)

### Change Log

- 2026-10-18: Tạo story. Tác giả chốt: giữ luật "tướng bị đẩy vào sông" trong code, không kịch bản, sửa GDD dòng 223; thêm trận thử `thu_day`.
- 2026-10-18: Kịch bản đợt 4 (3 cái) tác giả duyệt; test giao diện FR16, trận thử `thu_day`, sửa GDD dòng 223. Test 376 → 380, kịch bản 28 đã duyệt. Chuyển sang review.
