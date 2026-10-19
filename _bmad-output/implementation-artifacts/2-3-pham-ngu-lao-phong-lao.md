---
baseline_commit: 055ab740f221d9c11ff8b5dcd05292a14f30b3d5
---

# Story 2.3: Phạm Ngũ Lão phóng lao

Status: done

## Story

Là người chơi,
tôi muốn Phạm Ngũ Lão phóng lao từ xa,
để kết liễu địch mà không phải đứng gần.

_Story luật thứ ba của E2, đòn thứ hai. Lao chỉ gây sát thương, không đẩy. Phần "rừng, kho lương, làng chặn lao" làm ở Story 3.1 (E3); trước đó lao bay qua mọi địa hình. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 8 kịch bản mới ở Dev Notes "Đợt kịch bản 5" (`da_duyet: false`) và phần khung ở Task 1.1 (mã từ chối mới `ngoai_tam`). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 28 đã duyệt · 8 chưa duyệt (8 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh lao`. Chưa duyệt xong thì không viết dòng code luật nào (`rules_attack.gd`, `grid.gd`, `stats.gd`).
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` **trượt** (kịch bản đã duyệt chưa đạt). Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 36 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh, `BattleState.validate()` rỗng.
4. **Phóng lao (FR13).** **Cho** Phạm Ngũ Lão và một quân Nguyên thẳng hàng (cùng hàng hoặc cùng cột), cách 3 ô, đường trống. **Khi** bấm vào quân đó, **thì** quân đó mất 1 máu và **không bị đẩy**. Sát thương lấy từ `sat_thuong` (1), tầm từ `tam_danh_gan` (2) và `tam_danh_xa` (4) trong `chi_so.json`, không ghi số trong code.
5. **Bay qua ô kề.** **Khi** có một quân (bất kể phe) đứng ở ô kề Lão trên hàng, **thì** lao bay qua quân đó, không ai ở ô kề mất máu.
6. **Trúng vật đầu tiên.** Lao trúng **quân đầu tiên** ở ô thứ 2–4 trên hàng, kể cả khi người chơi bấm vào quân Nguyên đứng xa hơn. Chỉ một quân mất máu.
7. **Trúng tướng mình.** **Khi** quân đầu tiên ở ô thứ 2–4 là tướng mình, **thì** tướng mình mất 1 máu, quân Nguyên đứng sau không bị gì. Tướng mình còn 0 máu thì gục, bị nhấc khỏi bàn.
8. **Sông không chặn.** **Khi** có sông nằm giữa, **thì** lao vẫn bay qua.
9. **Viền mục tiêu** (theo "Quyết định của tác giả", câu 1). **Khi** chọn Lão, **thì** chỉ quân Nguyên mới có viền trắng "đánh được". Mỗi hướng có nhiều nhất một viền: **quân Nguyên gần nhất** ở ô thứ 2–4. Không có quân Nguyên nào ở ô thứ 2–4 thì hướng đó không có viền và không bấm đánh được. Quân Nguyên đứng kề Lão không có viền.
10. **Từ chối.** Lệnh lao vào ô không thẳng hàng, ô kề, ô xa quá 4, ô ngoài bàn bị từ chối `ngoai_tam`. Ô trong tầm mà không phải mục tiêu có viền (ô trống, tướng mình, quân Nguyên đứng sau quân Nguyên khác) bị từ chối `khong_co_dich`. Bàn giữ nguyên.
11. **Như đòn Khoái.** Đi rồi phóng được; đã đi thì phải bấm xác nhận lần hai (FR15). Phóng rồi thì Lão mờ xám, không đi, không phóng được nữa; phóng xóa lịch sử hủy (FR10). Kết thúc lượt thì phóng lại được.
12. **Chờ xác nhận mà bấm tướng đã đánh** (mục hoãn từ review 2.1, giờ gặp được vì có hai tướng đánh được). **Khi** đang chờ xác nhận một mục tiêu mà bấm chuột vào (hoặc gõ phím số của) một tướng mình **đã đánh**, **thì** bỏ chờ xác nhận, dòng "Bấm lần nữa để đánh" mất, tướng đang chọn vẫn được chọn.
13. **Trận thử** (theo câu 2). `tools/chay.sh --dev --tran=thu_lao` mở trận "Thử lao". Tác giả làm được trong game: lao bay qua quân kề, bay qua sông, trúng tướng mình đứng chắn.
14. **Kịch bản.** Có kịch bản trong `lao/`, đã duyệt và đạt.

## Tasks / Subtasks

- [x] **Task 0: Tác giả chốt 3 câu hỏi** ở "Quyết định của tác giả" (2026-10-19, cả 3 câu chọn phương án (a)).
- [x] **Task 1: Khung, đợt kịch bản 5, dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Khung (không phải code luật, làm trước để file kịch bản nạp được):
    - `src/core/battle_event.gd`: thêm `NOT_IN_RANGE` vào **cuối** enum `Reject`.
    - `src/data/scenario_loader.gd`: `REJECT_CODES` thêm `"ngoai_tam": "scenario.viewer.reject_not_in_range"`; sửa `REJECT_LIST` cho đủ 10 mã; `COMMAND_REJECTS["danh"]` thêm `"ngoai_tam"`.
    - `tests/scenario_runner.gd`: `REJECT_EVENTS` thêm `"ngoai_tam": BattleEvent.Reject.NOT_IN_RANGE` (cùng thứ tự với `REJECT_CODES`; `test_scenario_loader.gd` kiểm hai bảng cùng khóa).
    - `i18n/text.csv`: `scenario.viewer.reject_not_in_range` = `ô đó không thẳng hàng hoặc ngoài tầm lao`; sửa `scenario.viewer.reject_no_target` thành `ô đó không có quân Nguyên đánh được` (câu cũ sai với ca "Bộ binh đứng sau Bộ binh"; chỉ là chữ của công cụ duyệt, không đổi file kịch bản nào).
    - `tests/test_scenario_loader.gd`: `danh` + `ngoai_tam` nạp được; `di` + `ngoai_tam` báo lỗi như các mã sai lệnh khác.
  - [x] 1.2 Viết 8 file đúng như Dev Notes "Đợt kịch bản 5", `"da_duyet": false`, thư mục mới `tests/kich_ban/lao/`. Không đụng 28 kịch bản đã duyệt.
  - [x] 1.3 `tools/xem_kich_ban.sh lao`: đọc lại từng bàn trước/sau, khớp `mo_ta`; dòng `tu_choi` của #7 hiện đúng câu tiếng Việt. `tools/test.sh`: xanh, `28 đã duyệt · 8 chưa duyệt (8 chưa đạt)`, lý do khớp bảng. Ghi Debug Log.
  - [x] 1.4 Commit: `Kịch bản phóng lao chờ duyệt (Story 2.3)`.
  - [x] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh lao`, đọc 8 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ hai điều:
    - #4: bấm Bộ binh mà lao trúng Khoái đứng chắn trước (luật "trúng vật đầu tiên"); trước Story 2.12 (xem trước) game chưa báo trước điều này.
    - Trước Story 3.1, lao bay qua rừng, kho lương, làng (chưa có kịch bản nào có rừng trên đường lao).
    Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì xử lý theo AC 2. `tools/test.sh` **phải trượt**. Ghi Debug Log. **Không commit** khi đang đỏ.
- [x] **Task 2: Lõi luật** (AC: 3–10)
  - [x] 2.1 `src/core/grid.gd`: `static func straight_dir(from: Vector2i, to: Vector2i) -> Vector2i`: cùng hàng hoặc cùng cột và khác ô thì trả một phần tử của `DIRECTIONS`, còn lại trả `Vector2i.ZERO`. `static func distance(a: Vector2i, b: Vector2i) -> int` (Manhattan; kiến trúc cây thư mục đã ghi "khoảng cách Manhattan"). `is_adjacent` dùng lại `distance`.
  - [x] 2.2 `src/core/stats.gd`: `min_range(type)` (`tam_danh_gan`), `max_range(type)` (`tam_danh_xa`). `StatsLoader` đã kiểm hai khóa này có mặt và `gan ≤ xa` (`RANGES`), không sửa bộ nạp.
  - [x] 2.3 `src/core/rules_attack.gd`:
    - `targets(state, unit)`: tách theo loại tướng. Khoái giữ nguyên code hiện tại (đưa vào `_khoai_targets`). Lão: `_lao_targets` theo "Viền mục tiêu của Lão" ở Dev Notes. Dư vẫn rỗng (Story 2.4).
    - `resolve`: theo "Bảng thứ tự kiểm của lệnh đánh" ở Dev Notes. Dòng "chưa có đòn" chỉ còn cho Dư, lý do đổi thành `quân %d chưa có đòn (Story 2.4)`. **Kiểm hết rồi mới sửa.** Hợp lệ thì `ATTACKED` → `lao_throw` → `unit.has_attacked = true`.
    - `static func lao_throw(state, lao, cell, events)`: theo "Đường lao" ở Dev Notes. Không gọi `ForcedMove` (lao không đẩy). Sát thương qua `Effects.damage(..., state.stats.damage(lao.type), BattleEvent.Cause.STRIKE, events)`; ghi chú "Sát Thát (+1) thêm ở Story 3.13" như `khoai_strike`.
    - Sửa chú thích đầu file (bỏ "Lão, Dư: Story 2.3, 2.4", thêm Lão).
  - [x] 2.4 `src/core/battle_event.gd`: chú thích `ATTACKED` ghi rõ `to_cell` là ô lao trúng (Lão) hoặc ô bị đánh (Khoái); chú thích `Cause.STRIKE` ghi "đòn có sát thương của tướng (Khoái, Lão)".
- [x] **Task 3: Test lõi luật** (AC: 3–11)
  - [x] 3.1 `tests/test_rules_attack.gd` thêm (dựng bằng `BoardFixture`, mỗi ca so **đúng dãy sự kiện** và `validate()` rỗng qua `_attack`):
    - lao trúng quân Nguyên ở ô thứ 2, 3, 4, thử đủ 4 hướng: `["ATTACKED 2 c,h", "DAMAGED 101 -1 STRIKE"]`, quân đứng yên, `has_attacked` của Lão bật, `has_moved` không bật;
    - bay qua quân Nguyên kề và bay qua tướng mình kề;
    - trúng quân gần nhất khi có hai quân Nguyên trên hàng (bấm con gần);
    - trúng tướng mình đứng chắn: bấm quân Nguyên đứng sau, sự kiện là `ATTACKED 2 <ô tướng>`, `DAMAGED 1 -1 STRIKE`; quân Nguyên giữ máu;
    - tướng mình 1 máu trúng lao: `DIED 1 c,h`, bị nhấc khỏi bàn;
    - quân Nguyên 1 máu (Cung kỵ) gục ở ô thứ 4: `DIED`; không có `MOVED` nào;
    - sông ở ô kề và ô thứ 2: vẫn trúng;
    - từ chối theo đủ bảng (mỗi dòng một ca, cho Lão): `NOT_IN_RANGE` với ô kề, ô chéo, ô cách 5, ô ngoài bàn; `NO_TARGET` với ô trống, ô tướng mình, quân Nguyên đứng sau quân Nguyên khác; `ALREADY_ATTACKED` khi phóng hai lần. State giữ nguyên (`BoardFixture.picture`), `has_attacked` không bật;
    - đi rồi phóng được; phóng rồi đi bị `ALREADY_ATTACKED`.
  - [x] 3.2 Sửa test cũ đang ghi "Lão chưa có đòn" (đọc từng chỗ, giữ ý của test):
    - `test_rejections_keep_state` (dòng 54): `[2, Vector2i(4, 3), "NO_TARGET"]` thành `"NOT_IN_RANGE"` (Lão ở `4,4` đánh ô kề `4,3`). Dòng của Dư giữ `NO_TARGET`;
    - `test_targets_are_adjacent_nguyen_units_in_direction_order` (dòng 97): Lão ở `4,3` giờ có `targets` là `[2,3]` (bay qua Khoái kề ở `3,3`, Bộ binh `4,4` kề không tính). Đổi câu thông báo cho đúng. Ca của Dư giữ nguyên;
    - `test_battle_controller.gd:242` và `test_battle_view.gd:564`: bố cục hiện tại không có quân Nguyên nào thẳng hàng với Lão (`0,6`), nên vẫn rỗng; chỉ đổi câu thông báo thành "Lão không có quân Nguyên thẳng hàng trong tầm";
    - `test_battle_view.gd:686` (`test_click_adjacent_ally_switches_selection`, câu "không còn viền mục tiêu"): Lão ở `2,4` không thẳng hàng với Bộ binh `3,3` và `6,6`, vẫn rỗng; giữ nguyên.
    Mọi chỗ sửa ghi vào "Lệch so với Tasks" nếu khác danh sách này.
  - [x] 3.3 `tests/test_rules_attack.gd`:
    - `targets` của Lão: đúng thứ tự B→Đ→N→T; mỗi hướng một ô; bỏ qua tướng mình để tìm quân Nguyên sau nó; không có ô kề; dừng ở mép bàn; rỗng khi đã phóng;
    - `test_grid_direction_helpers` thêm `straight_dir` (4 hướng, cách xa, ô chéo trả `ZERO`, cùng ô trả `ZERO`) và `distance`;
    - `test_stats_read_damage_and_push_distance` thêm `min_range`, `max_range` của Lão đọc đúng `chi_so.json` (2 và 4), `damage` của Lão là 1.
  - [x] 3.4 `tests/test_battle_controller.gd`: Lão phóng thì `can_undo()` false; `attack_targets(2)` đúng trên một bố cục có quân Nguyên thẳng hàng.
  - [x] 3.5 Phá thử, **mỗi lần sửa tạm một chỗ**, chạy `tools/test.sh`, ghi tên kịch bản và test GUT trượt vào Debug Log, trả lại ngay, `git diff --quiet game/src` sau mỗi lần:
    - lao bắt đầu tìm từ ô kề (ô thứ 1) → `lao/bay_qua_o_ke.json`, `lao/bay_qua_tuong_minh_ke.json` phải trượt;
    - lao trúng ô được bấm thay vì quân đầu tiên → `lao/trung_tuong_minh.json` phải trượt;
    - lao trúng mọi quân trong tầm (không dừng ở quân đầu tiên) → `lao/trung_vat_dau_tien.json`, `lao/trung_tuong_minh.json` phải trượt;
    - sông chặn lao (dừng khi gặp ô sông) → `lao/bay_qua_song.json` phải trượt;
    - tầm xa đọc thành 3 (`max_range` trừ 1) → `lao/guc_vi_lao.json` phải trượt;
    - lao đẩy mục tiêu như Khoái (gọi `ForcedMove.run`) → `lao/phong_lao_cach_3_o.json` phải trượt;
    - bỏ kiểm `NOT_IN_RANGE` (để rơi xuống `NO_TARGET`) → `lao/khong_phong_duoc.json` phải trượt.
- [x] **Task 4: Giao diện** (AC: 9, 11, 12)
  - [x] 4.1 `src/battle/battle_view.gd`: viền, chờ xác nhận, bỏ chọn sau khi đánh đã chạy chung cho mọi tướng qua `attack_targets` (Story 2.1); **không** viết nhánh riêng cho Lão. Chỉ sửa mục hoãn (AC 12):
    - `_on_cell_clicked`, nhánh tướng mình đã đánh (hiện là `return` không làm gì, dòng ~86–90): gọi `_set_pending(BoardView.NO_CELL)` trước `return`; tướng đang chọn giữ nguyên;
    - `_on_general_key`: phím số của tướng đã đánh cũng bỏ chờ như trên.
  - [x] 4.2 `tests/test_battle_view.gd` thêm trận thử `_make_lao_main()` qua `_make_level_main` (thư mục riêng `LAO_DIR`, xóa ở `after_each` như `ALLY_DIR`). Bố cục: Lão `2` ở `3,3`; Bộ binh `3,2` (kề Bắc), Bộ binh `3,1`; Khoái `1` ở `3,5`, Bộ binh `3,6`; Kỵ binh `6,3`; Bộ binh `0,0`; không có sông (sông đã có kịch bản). Các ca, mỗi ca kiểm cả điều kiện trước:
    - phím `2` thật: `_view(main).target_cells()` **đúng bằng** `[3,1, 6,3, 3,6]` (B→Đ→N→T; không có `3,2` kề; `3,6` có viền dù Khoái đứng chắn); `_board(main).target_cells()` giống hệt;
    - bấm chuột thật vào `3,1`: Bộ binh `3,1` còn 2 máu, Bộ binh `3,2` còn 3; đồng Lão `is_attacked()`; Lão bị bỏ chọn; `can_undo()` false;
    - bấm `3,6`: Khoái còn 2 máu, Bộ binh `3,6` còn 3 máu;
    - đi Lão rồi bấm mục tiêu: lần đầu `pending_cell()` đúng ô đó và dòng nhắc là `tr("hud.confirm_attack")`; lần hai mới trúng (đi `3,3` → `2,3`, lúc đó Kỵ binh `6,3` cách 4 ô ở hướng Đông và Bộ binh `3,2`, `3,1` không còn thẳng hàng; kiểm `target_cells()` sau khi đi trước khi bấm);
    - AC 12: Khoái đánh Bộ binh `3,6` trước (Khoái mờ), chọn Lão, đi `2,3`, bấm Kỵ binh `6,3` (chờ xác nhận), bấm Khoái → `pending_cell()` là `NO_CELL`, dòng nhắc rỗng, `selected_id()` vẫn 2, Kỵ binh còn 2 máu; làm lại với phím `1` thật thay cho bấm chuột.
  - [x] 4.3 Phá thử giao diện (ghi Debug Log): bỏ dòng `_set_pending` vừa thêm ở nhánh tướng đã đánh → ca AC 12 bằng chuột trượt; bỏ ở `_on_general_key` → ca bằng phím trượt.
- [x] **Task 5: Trận thử `thu_lao`** (AC: 13; theo câu 2)
  - [x] 5.1 `game/data/tran/thu_lao.json` (MỚI) đúng bố cục ở Dev Notes "Trận thử `thu_lao`". Không đổi `tran_01.json`, `thu_ba_tuong.json`, `thu_day.json`.
  - [x] 5.2 `tests/test_loaders.gd`: thêm `test_real_lance_trial_level_loads` theo mẫu `test_real_push_trial_level_loads` (đã sửa theo review 2.2): không lỗi, không cảnh báo, **so đủ ô và loại của mọi quân**, kiểm từng ô sông.
- [x] **Task 6: Tài liệu, kiểm bằng mắt, commit** (AC: 3–14)
  - [x] 6.1 `_bmad-output/planning-artifacts/game-architecture.md`: danh sách mã `tu_choi` (dòng ~341) thêm `ngoai_tam`; cây thư mục `data/tran/` thêm `thu_lao.json` vào dòng trận thử; cây `kich_ban/` thêm nhóm `lao/` nếu cây có liệt kê nhóm; bảng "Đòn của tướng", dòng Phạm Ngũ Lão, thêm câu viền mục tiêu theo câu 1.
  - [x] 6.2 GDD (`gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 151, cột luật của Phạm Ngũ Lão): thêm câu viền mục tiêu theo câu 1 (a) và "Chốt 2026-10-19". Không sửa chỗ nào khác của GDD.
  - [x] 6.3 `deferred-work.md`: mục hoãn "chờ xác nhận mà bấm tướng đã đánh" (review 2.1) ghi "đã làm ở Story 2.3".
  - [x] 6.4 _(Làm một phần: có 2 ảnh, thiếu ảnh "trúng Khoái"; ca này chờ tác giả kiểm tay, xem Lệch 5)_ Kiểm bằng mắt: chạy `tools/chay.sh --dev --tran=thu_lao` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action` cho phím (`select_general_2`, `end_turn`…), `inject_mouse_click` theo pixel `(486 + (cột − hàng)·64, 141 + (cột + hàng)·32 + 32)` (công thức Debug Log 2.2). Làm theo "Hướng dẫn tác giả tự test" ở Dev Notes, `capture_screenshot` sau mỗi bước chính, lưu `_bmad-output/implementation-artifacts/anh/2-3-*.png` (ít nhất: chọn Lão thấy 3 viền; sau khi lao bay qua quân kề; sau khi lao trúng Khoái). Tắt game. Log không có ERROR/WARN.
  - [x] 6.5 _(Chưa chụp được; chờ tác giả kiểm tay, xem Lệch 5)_ Trận 1 (`tools/chay.sh --dev`): Lão đi `2,6` → `2,4`, Bộ binh `5,4` có viền (sông ở `3,4` nằm giữa), bấm hai lần → Bộ binh còn 2 máu. Chụp `anh/2-3-*-tran-1.png`.
  - [x] 6.6 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, trận thử, tài liệu, `.uid` mới. Ví dụ: `Phạm Ngũ Lão phóng lao (Story 2.3)`.
  - [x] 6.7 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, dùng kết quả thật (số test thật).

### Review Findings

- [x] [Review][Patch] Bộ nạp chỉ số đòi `tuong.pham_ngu_lao.tam_danh_gan` ≥ 2, kèm test báo lỗi. Tác giả chốt 2026-10-19: "bay qua ô kề" là luật cố định, không để số 1 làm Lão đánh được quân kề [game/src/data/stats_loader.gd:26]
- [x] [Review][Patch] `lao_throw` không trúng ai thì vẫn tính là đã đánh, không báo gì: thêm `assert` sau vòng lặp [game/src/core/rules_attack.gd:108]
- [x] [Review][Patch] Task 6.4, 6.5 đánh [x] nhưng thiếu ảnh "trúng Khoái" và `anh/2-3-*-tran-1.png` (Lệch 5 đã ghi): bỏ dấu [x] hoặc ghi rõ "chờ tác giả kiểm tay" [_bmad-output/implementation-artifacts/2-3-pham-ngu-lao-phong-lao.md:116]
- [x] [Review][Patch] File List thiếu `game/i18n/text.vi.translation`; Lệch 2 nói `trung_vat_dau_tien.json` không bắt được "lao trúng mọi quân", nhưng phá thử kiểu "trúng mọi quân tới `max_range`" như Task 3.5 ghi thì kịch bản này trượt (chưa chạy thử) [_bmad-output/implementation-artifacts/2-3-pham-ngu-lao-phong-lao.md:383]
- [x] [Review][Patch] Test file thật chỉ kiểm `tam_danh_xa` của Lão; thêm `tam_danh_gan` = 2 và `sat_thuong` = 1 (Task 3.3) [game/tests/test_loaders.gd:464]
- [x] [Review][Patch] `test_lance_targets` thiếu ca "dừng ở mép bàn" (Task 3.3) [game/tests/test_rules_attack.gd:242]
- [x] [Review][Patch] `test_lance_flies_over_adjacent_unit`, `test_lance_hits_blocking_khoai` không kiểm điều kiện trước (máu ban đầu, ô có trong `target_cells()`) (Task 4.2) [game/tests/test_battle_view.gd:737]
- [x] [Review][Patch] `test_move_then_lance`, `test_lance_once_per_turn_and_no_move_after` không kiểm `validate()` sau lệnh đi (AC 3) [game/tests/test_rules_attack.gd:225]
- [x] [Review][Patch] Trận chép tay trong test giao diện thiếu sông ở `4,3`, `5,3` so với `thu_lao.json`: test giao diện không có ca lao bay qua sông, hai bản dễ lệch nhau [game/tests/test_battle_view.gd:714]
- [x] [Review][Defer] Bộ nạp kịch bản kiểm mã `tu_choi` theo lệnh, không theo tướng: Khoái + `ngoai_tam` hay Lão + `khong_ke` vẫn nạp được, chỉ trượt lúc chạy [game/src/data/scenario_loader.gd:40] — deferred, pre-existing

## Dev Notes

### Bối cảnh

- Story 2.1 làm xong khung đòn đánh: `Command.attack`, `RulesAttack`, `Effects.damage`, `has_attacked`, viền trắng, chờ xác nhận, đồng xám, `BattleController.attack_targets`. Story 2.2 thêm kịch bản sông và trúng quân mình. Story này **chỉ thêm đòn của Lão** vào khung đó; giao diện chạy chung, gần như không phải sửa.
- Lao **không đẩy**: không gọi `ForcedMove`, không có `MOVED`, không có va chạm.
- **Chưa có:** rừng, kho lương, làng chặn lao (3.1; làng chặn thì Lòng dân −1 ở 3.7); kéo (2.4); thắng/thua (2.5); AI và đòn địch (2.6–2.9); hoạt ảnh lao bay (2.11); xem trước (2.12, phải hiện rõ khi lao sẽ trúng tướng mình); Sát Thát (3.13).
- Tác giả không đọc code. Thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Luật (spec) **[FR13, FR15, FR16; GDD dòng 151, 195–196, 216; kiến trúc "Đòn của tướng"]**

- **Thẳng hàng:** cùng hàng hoặc cùng cột với Lão (4 hướng, không chéo).
- **Tầm:** ô thứ `tam_danh_gan` (2) tới `tam_danh_xa` (4) tính từ Lão. Ô thứ 1 (kề) lao bay qua.
- **Trúng vật đầu tiên:** đi từ ô thứ 2 ra xa, quân đầu tiên gặp được (bất kể phe) mất `sat_thuong` (1). Chỉ một quân trúng. Không đẩy.
- **Sông** không chặn (FR28). Sông không có quân đứng nên lao bay qua như ô trống.
- **Rừng, kho lương, làng** chặn lao ở bất kỳ ô nào, kể cả ô kề **(mặc định, GDD)**: làm ở **Story 3.1**. Ở story này lao bay qua chúng. Ghi chú trong `lao_throw` và `_lao_targets` chỗ 3.1 sẽ thêm.
- **Không chọn tướng mình làm mục tiêu** (chốt 2026-10-17): chỉ quân Nguyên có viền. Tướng mình chỉ trúng như hệ quả: đứng chắn trước quân Nguyên được bấm.
- **Tiết kiệm hành động, xác nhận, hủy:** như Khoái (Story 2.1). Không có gì mới.

### Viền mục tiêu của Lão (`_lao_targets`, theo câu 1 (a))

Với mỗi hướng theo thứ tự `Grid.DIRECTIONS` (B→Đ→N→T):

1. `d` chạy từ `min_range` tới `max_range`. `cell = lao.cell + dir * d`. Ra ngoài bàn thì dừng hướng này.
2. Ô có quân Nguyên: thêm `cell`, dừng hướng này.
3. Ô có tướng mình: đi tiếp (lao sẽ trúng tướng này nếu bấm quân Nguyên phía sau; viền vẫn ở quân Nguyên).
4. Ô trống (kể cả sông, rừng ở story này): đi tiếp.

Ô kề (`d = 1`) không xét. Story 3.1 sẽ thêm "gặp rừng, kho lương, làng ở bất kỳ ô nào từ `d = 1` thì dừng hướng này".

### Đường lao (`lao_throw`)

- `dir = Grid.straight_dir(lao.cell, cell)`. `d` chạy từ `min_range` tới `Grid.distance(lao.cell, cell)`; quân đầu tiên gặp được là quân trúng lao. `resolve` đã kiểm `cell` có trong `targets`, nên luôn có quân trúng (ít nhất là quân ở `cell`).
- Sự kiện: `ATTACKED(lao.id, <ô quân trúng>)`, `DAMAGED(<quân trúng>, 1, STRIKE)`, có thể `DIED`. Không có sự kiện nào khác.
- `ATTACKED` ghi trong `resolve` như Khoái, nhưng `to_cell` là **ô quân trúng**, không phải ô được bấm (cho hoạt ảnh lao bay ở 2.11). Ví dụ: bấm Bộ binh `3,3` mà Khoái đứng chắn ở `3,4`: `ATTACKED 2 3,4`, `DAMAGED 1 -1 STRIKE`. Vì vậy `resolve` tìm quân trúng trước khi ghi `ATTACKED` (hàm phụ `_lao_hit_cell` dùng chung cho `resolve` và `lao_throw`, hoặc `lao_throw` tự ghi `ATTACKED`; chọn một, ghi chú rõ).

### Bảng thứ tự kiểm của lệnh đánh (sau story này)

| Kiểm | `Reject` | Mã `tu_choi` | Lý do (cho dev và log, không qua `tr()`) |
|---|---|---|---|
| Không có quân id đó | `NO_UNIT` | `khong_co_quan` | `không có quân %d` |
| Quân không phải tướng | `NOT_GENERAL` | `khong_phai_tuong` | `quân %d không phải tướng` |
| Tướng đã đánh trong lượt này | `ALREADY_ATTACKED` | `da_danh_roi` | `quân %d đã đánh rồi trong lượt này` |
| Dư (chưa có đòn) | `NO_TARGET` | — (không có kịch bản) | `quân %d chưa có đòn (Story 2.4)` |
| **Khoái:** ô không kề cạnh (kể cả ô chéo, ngoài bàn) | `NOT_ADJACENT` | `khong_ke` | `ô c,h không kề quân %d` (không đổi) |
| **Khoái:** ô không có quân Nguyên | `NO_TARGET` | `khong_co_dich` | `ô c,h không có quân Nguyên để đánh` (không đổi) |
| **Lão:** ô ngoài bàn, không thẳng hàng, hoặc cách ngoài `min_range`–`max_range` | `NOT_IN_RANGE` (MỚI) | `ngoai_tam` (MỚI) | `ô c,h không thẳng hàng với quân %d trong tầm %d–%d` |
| **Lão:** ô không có trong `targets` (trống, tướng mình, quân Nguyên đứng sau quân Nguyên khác) | `NO_TARGET` | `khong_co_dich` | `ô c,h không phải quân Nguyên gần nhất trong tầm lao` |

Kiểm hết rồi mới sửa: không gọi `Effects` trước khi qua hết bảng. Không đổi thứ tự các dòng cũ (kịch bản đã duyệt của Khoái dựa vào đó).

### Đợt kịch bản 5

Quy ước như các đợt trước: `phien_ban_dinh_dang: 1`, bàn 7×7, mỗi ô cách nhau một dấu cách, `sau.dia_hinh` chép y `truoc.dia_hinh`. Tọa độ `cot,hang`; ô không nêu là đất trống, không có quân. Chỉ ghi `mau` cho quân không đủ máu. Mọi kịch bản ghi `sau.da_danh`. Không có `ket_thuc_luot`. Thư mục `lao/`.

| # | File | `mo_ta` | Bàn trước | `hanh_dong` | Bàn sau |
|---|---|---|---|---|---|
| 1 | `lao/phong_lao_cach_3_o.json` | `Phạm Ngũ Lão phóng lao trúng Bộ binh cách 3 ô cùng hàng: Bộ binh mất 1 máu, đứng yên tại chỗ.` | `2` ở 1,3; `B` ở 4,3 | `danh 2 → 4,3` | `2` ở 1,3; `B` ở 4,3, `mau 4,3: 2`; `da_danh: ["2"]` |
| 2 | `lao/bay_qua_o_ke.json` | `Lao bay qua Bộ binh đứng ngay trước Lão, trúng Bộ binh ở ô thứ 2. Bộ binh đứng kề không bị gì.` | `2` ở 3,5; `B` ở 3,4; `B` ở 3,3 | `danh 2 → 3,3` | như trước, `mau 3,3: 2`; `da_danh: ["2"]` |
| 3 | `lao/trung_vat_dau_tien.json` | `Hai Bộ binh cùng hàng ở ô thứ 2 và ô thứ 4: lao trúng con gần, con xa không bị gì.` | `2` ở 0,2; `B` ở 2,2; `B` ở 4,2 | `danh 2 → 2,2` | như trước, `mau 2,2: 2`; `da_danh: ["2"]` |
| 4 | `lao/trung_tuong_minh.json` | `Khoái đứng ở ô thứ 2, Bộ binh ở ô thứ 3: bấm Bộ binh thì lao trúng Khoái đứng chắn. Khoái mất 1 máu, Bộ binh không bị gì.` | `2` ở 3,6; `1` ở 3,4; `B` ở 3,3 | `danh 2 → 3,3` | như trước, `mau 3,4: 2`; `da_danh: ["2"]` |
| 5 | `lao/bay_qua_song.json` | `Sông nằm giữa Lão và Bộ binh: lao bay qua sông, trúng Bộ binh bên kia.` | `~` ở 2,5 và 3,5; `2` ở 1,5; `B` ở 4,5 | `danh 2 → 4,5` | như trước, `mau 4,5: 2`; `da_danh: ["2"]` |
| 6 | `lao/guc_vi_lao.json` | `Cung kỵ 1 máu ở ô thứ 4 (xa nhất) trúng lao thì gục, bị nhấc khỏi bàn.` | `2` ở 5,6; `C` ở 5,2; `B` ở 0,0 | `danh 2 → 5,2` | `2` ở 5,6; `B` ở 0,0; `da_danh: ["2"]` |
| 7 | `lao/khong_phong_duoc.json` | `Lão không phóng lao được vào: quân Nguyên đứng kề, đứng chéo, cách 5 ô; ô trống; tướng mình; Bộ binh đứng sau một Bộ binh khác.` | `2` ở 1,1; `B` ở 2,1, 3,1, 4,1; `B` ở 1,6; `K` ở 3,3; `1` ở 1,4 | `danh 2 → 2,1` **`ngoai_tam`**; `danh 2 → 3,3` **`ngoai_tam`**; `danh 2 → 1,6` **`ngoai_tam`**; `danh 2 → 1,3` **`khong_co_dich`**; `danh 2 → 1,4` **`khong_co_dich`**; `danh 2 → 4,1` **`khong_co_dich`** | giống trước; `da_danh: []` |
| 8 | `lao/bay_qua_tuong_minh_ke.json` | `Khoái đứng ngay trước Lão: lao bay qua Khoái, trúng Bộ binh ở ô thứ 3. Khoái không bị gì.` | `2` ở 5,5; `1` ở 4,5; `B` ở 2,5 | `danh 2 → 2,5` | như trước, `mau 2,5: 2`; `da_danh: ["2"]` |

Mỗi kịch bản thử đúng điều `mo_ta` nói (đã kiểm khi tạo story; dev kiểm lại, ghi Debug Log):

- **#1:** đường `2,3` (ô 1), `3,3` (ô 2), `4,3` (ô 3) trống tới Bộ binh. Lao mà đẩy thì Bộ binh sang `5,3`: trượt. Sát thương sai (2 như Khoái) thì Bộ binh còn 1: trượt.
- **#2:** `3,4` là ô kề (ô 1), `3,3` là ô 2. Lao tìm từ ô kề thì trúng `3,4`: trượt (và `3,3` không còn là mục tiêu, lệnh bị từ chối: trượt).
- **#3:** lao trúng mọi quân trên đường thì Bộ binh `4,2` cũng mất máu: trượt.
- **#4:** `3,5` ô 1 trống, `3,4` Khoái ô 2, `3,3` Bộ binh ô 3. Viền ở `3,3` (quân Nguyên gần nhất; Khoái là tướng mình). Lao trúng ô được bấm thì Bộ binh mất máu, Khoái đủ máu: trượt. Lao bỏ qua tướng mình cũng vậy: trượt.
- **#5:** `2,5` (ô 1) và `3,5` (ô 2) là sông, Bộ binh ở ô 3. Sông chặn lao thì bị từ chối hoặc không ai mất máu: trượt.
- **#6:** `5,5`, `5,4`, `5,3` trống, Cung kỵ ở ô 4 (đúng `tam_danh_xa`). Tầm đọc sai thành 3 thì bị từ chối: trượt. Bộ binh ở `0,0` (không thẳng hàng với Lão) để trận chưa thắng khi Story 2.5 thêm luật thắng/thua.
- **#7:** hàng 1: `2,1` kề; `3,1` ô 2; `4,1` ô 3 đứng sau `3,1`. Cột 1: `1,2` trống, `1,3` trống (ô 2), `1,4` Khoái (ô 3), `1,5` trống, `1,6` Bộ binh (ô 5). `3,3` chéo. Thứ tự lệnh: ba lệnh `ngoai_tam` trước, rồi ba lệnh `khong_co_dich`. Mục tiêu đúng duy nhất trên bàn là `3,1` (không bấm). Lệnh cuối phụ thuộc câu 1 (a); câu 1 chọn (b) thì lệnh này **không** bị từ chối: bỏ lệnh khỏi kịch bản này, chuyển thành kịch bản riêng.
- **#8:** như #2 nhưng quân kề là tướng mình. Lao tìm từ ô kề thì Khoái mất máu: trượt.

**Lý do chưa đạt** (sau Task 1.1, trước khi có code luật). Hiện Lão bị từ chối mọi lệnh đánh với `NO_TARGET` "chưa có đòn", nên:

| File | Lý do |
|---|---|
| #1–#6, #8 | `bước 1: luật từ chối ("khong_co_dich": quân 2 chưa có đòn (Story 2.3, 2.4)) mà kịch bản không ghi "tu_choi"` |
| #7 | `bước 1: luật từ chối vì "khong_co_dich" (quân 2 chưa có đòn (Story 2.3, 2.4)), kịch bản ghi "tu_choi": "ngoai_tam"` |

Câu chính xác lấy từ `ScenarioRunner._check_reject` (`tests/scenario_runner.gd:115`) với tiền tố bước của bộ chạy; dev kiểm lại và sửa bảng nếu câu thật khác. Ví dụ một lệnh: `{"lenh": "danh", "tuong": "2", "o": "2,1", "tu_choi": "ngoai_tam"}`. Không viết thêm kịch bản ngoài 8 cái này.

### Trận thử `thu_lao` (theo câu 2 (a))

`game/data/tran/thu_lao.json`, `"ten": "Thử lao"`, `"kieu": "tieu_diet"`. Bàn (hàng 0 ở trên):

```
dia_hinh                 quan
. . . . . . .            B . . . . . .
. . . . . . .            . . . B . . .
. . . . . . .            . . . B . . .
. . . . ~ ~ .            . . . 2 . . K
. . . . . . .            . . . . . . .
. . . . . . .            . . . 1 . . .
. . . . . . .            . . . B . . .
```

- `thu_tu_dich`: `["0,0", "3,1", "3,2", "6,3", "3,6"]`. `tiep_vien: []`, `muu_ke_mo: []`.
- Từ Lão `3,3`: Bắc `3,2` kề (bay qua), `3,1` ô 2 → viền; Đông `4,3`, `5,3` sông, `6,3` Kỵ binh ô 3 → viền; Nam `3,4` trống, `3,5` Khoái ô 2, `3,6` Bộ binh ô 3 → viền (lao sẽ trúng Khoái); Tây không có gì. Bộ binh `0,0` không thẳng hàng.
- Test giao diện ở Task 4.2 dùng bố cục gần giống (bỏ sông) trong `user://`: không đọc file này, để tác giả sửa trận thử thoải mái.

### Hướng dẫn tác giả tự test (mẫu, dev ghi lại bằng kết quả thật ở Completion Notes)

1. `tools/test.sh`: thấy `Kịch bản luật: 36 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ … test đạt`.
2. `tools/chay.sh --dev --tran=thu_lao`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
3. Gõ `2` chọn Lão: 3 viền trắng, ở Bộ binh xa phía trên (không phải con đứng sát Lão), Kỵ binh bên kia sông, Bộ binh dưới cùng (sau Khoái).
4. Bấm Bộ binh xa phía trên: nó còn 2 máu, con đứng sát Lão vẫn 3. Lão xám.
5. `Space`, gõ `2`, bấm Kỵ binh bên kia sông: Kỵ binh còn 1 máu.
6. `Space`, gõ `2`, bấm Bộ binh dưới cùng: **Khoái** mất 1 máu (còn 2), Bộ binh không bị gì.
7. Trận 1 (`tools/chay.sh --dev`): gõ `2`, bấm ô 2 ô phía trên Lão; Bộ binh bên phải sông có viền; bấm nó hai lần (lần đầu hiện "Bấm lần nữa để đánh"): nó còn 2 máu.
- Nhắc: trên Mac F1 là Fn+F1.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/rules_attack.gd`: `targets` (dòng 8–17) chỉ có Khoái; `resolve` (22–49) kiểm `NO_UNIT, NOT_GENERAL, ALREADY_ATTACKED`, rồi "không phải Khoái → NO_TARGET chưa có đòn", rồi `NOT_ADJACENT`, `NO_TARGET`; `khoai_strike` (53–61). Giữ nguyên hành vi của Khoái.
- `src/core/grid.gd`: `DIRECTIONS` (B, Đ, N, T), `is_adjacent`, `dir_between` (assert kề, review 2.1: đừng dùng cho lao, ô lao không kề).
- `src/core/stats.gd`: `value` (assert khóa có), `max_hp`, `move_range`, `damage`, `push_distance`. `chi_so.json`: `pham_ngu_lao` có `sat_thuong: 1`, `tam_danh_gan: 2`, `tam_danh_xa: 4`.
- `src/core/battle_event.gd`: `Reject` cuối là `NO_TARGET`; thêm `NOT_IN_RANGE` sau nó. `Cause { WALK, STRIKE, PUSH, COLLISION }`.
- `src/core/effects.gd`: `damage` trừ máu, ghi `DAMAGED`, hết máu thì nhấc khỏi bàn và ghi `DIED` (cả tướng). Không sửa.
- `src/battle/battle_controller.gd`: `attack_targets` gọi `RulesAttack.targets`; `submit` ATTACK xóa bản chụp hủy; `_describe` ATTACK chung. Không sửa.
- `src/battle/battle_view.gd`: `_on_general_key` (dòng 68–76), `_on_cell_clicked` (79–99): tướng mình → chọn / bỏ chọn / (đã đánh) không gì; mục tiêu → `_on_target_clicked` (chờ xác nhận nếu đã đi); ô sáng → đi; còn lại → bỏ chọn. `_select` (153) xóa chờ, gọi `refresh_hover`.
- `src/data/scenario_loader.gd` (dòng 21–41): `REJECT_CODES`, `REJECT_LIST`, `COMMAND_REJECTS`. `tests/scenario_runner.gd` (dòng 8–21): `PENDING_RULES` rỗng, `REJECT_EVENTS`.
- Test có câu "Lão chưa có đòn": `test_rules_attack.gd:54, 97`, `test_battle_controller.gd:242`, `test_battle_view.gd:564` (xem Task 3.2).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm.
- Một điểm vào: `Rules.resolve(state, command)`. Đòn Lão ở `rules_attack.gd`, không tạo file luật mới.
- Chỉ `Effects.damage` sửa máu và xử lý gục. Lao không đổi ô nào.
- Mọi hàm luật nhận `events` rồi `append`.
- Duyệt hướng theo `Grid.DIRECTIONS` (B→Đ→N→T), không theo khóa Dictionary. Không `float`.
- Con số (1 sát thương, tầm 2–4) chỉ đọc từ `chi_so.json` qua `Stats`.
- UI không sửa `BattleState`; gửi `Command` qua `submit()`, đọc bản chụp.
- Lý do từ chối là chữ cho dev, không qua `tr()`. Chữ của công cụ duyệt qua `tr()`.

### Testing

- `tools/test.sh` là lệnh duy nhất. Viết test trước, cho thấy đỏ, rồi mới code (ghi Debug Log).
- Lõi luật test thẳng (`BoardFixture` + `Rules.resolve`), mỗi ca so **dãy sự kiện** và `validate()` rỗng, không chỉ bàn sau (review 2.2: "chết đuối hay gục" chỉ sự kiện mới phân biệt; ở đây "trúng ô nào" chỉ `ATTACKED` mới cho thấy).
- Giao diện test qua `main.tscn` thật (`_make_level_main`), phím bằng `InputEventKey` có `physical_keycode`, chuột bằng sự kiện thật (`_click_by_mouse`). Trận thử viết vào `user://` rồi xóa ở `after_each`.
- Điều kiện trước phải kiểm **bằng đẳng thức**, không `has()` (review 2.2). Kiểm cả `_view()` lẫn `_board()`; kiểm "không có lệnh nào được gửi" bằng `can_undo()` khi cần.
- Phá thử **mỗi lần một chỗ** (review 2.2: một lần sửa hai chỗ thì không biết test nào bắt chỗ nào).

### Previous Story Intelligence (Story 2.1, 2.2 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log giống nhau; mọi chỗ làm khác Tasks ghi vào "Lệch so với Tasks" (review 2.2 bắt: gom helper, phá thử hai chỗ cùng lúc mà ghi "không có lệch"); task chụp ảnh thì phải có file ảnh.
- **Test trận thử phải so chỗ đứng từng quân** (review 2.2): đếm số quân thì dời quân vẫn xanh.
- **Kiểm điều kiện trước đúng với AC** (review 2.2: ca "chờ xác nhận" từng cho Khoái đi xa khỏi Lão nên không thử đúng "Lão kề"). Ở Task 4.2 kiểm `target_cells()` sau khi Lão đi, trước khi bấm.
- **`sat_thuong` tối thiểu 1** (review 2.1): `Effects.damage` assert `amount > 0`.
- **`Grid.dir_between` assert hai ô kề** (review 2.1): lao cần hàm mới `straight_dir`.
- **Test ghi chữ qua `tr()`**, không ghi cứng tiếng Việt (review 2.1).
- **Phím thật:** `InputEventKey` với `physical_keycode`. GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node (`_input`…), GUT bỏ qua cả file.
- **Mục hoãn liên quan** (`deferred-work.md`): chờ xác nhận không bỏ khi bấm tướng đã đánh (làm ở story này, AC 12); bộ chạy kịch bản bỏ qua tướng đã gục khi so `da_danh` (không có kịch bản tướng gục vì lao ở đợt này; test GUT phủ); `_on_target_clicked` không kiểm tướng đang chọn còn trên bàn (Lão không tự trúng lao, vẫn chưa gặp được).

### Git Intelligence

- Commit gần nhất: `055ab74 Sửa theo code review Story 2.2; xong Story 2.2`, `98aba3b Sông và đánh trúng quân mình (Story 2.2)`, `d8fc054 Kịch bản sông, trúng quân mình chờ duyệt (Story 2.2)`. Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- Mẫu 2 commit cho story luật: một commit "kịch bản … chờ duyệt", một commit code khi xanh.
- Tổng test hiện tại: 382/382; kịch bản 28 đã duyệt.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- Quy trình M3: AI viết kịch bản `da_duyet: false` → tác giả duyệt → test trượt → code. **Cấm** sửa hoặc xóa kịch bản đã duyệt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả, không tự đoán (câu 1–3 dưới đây).
- Không chọn được tướng mình làm mục tiêu; đòn trúng mọi phe như hệ quả.
- Con số cân bằng chỉ trong `data/chi_so.json`.
- Không `assert` cho lỗi dữ liệu; `assert` chỉ cho lỗi lập trình.
- Bật dev bằng `--dev`; `--tran=` chỉ có tác dụng khi bật dev.
- Commit khi xanh, lời commit tiếng Việt. Không `push --force`.

### Quyết định của tác giả (2026-10-19)

_Tác giả chốt 2026-10-19: cả 3 câu chọn phương án (a)._

1. **Quân Nguyên nào có viền khi chọn Lão.** GDD: "trúng vật đầu tiên ở ô thứ 2–4"; epics: "chỉ quân Nguyên mới có viền; lao trúng tướng mình chỉ xảy ra khi tướng mình là vật đầu tiên trên đường tới quân Nguyên được chọn". Chưa nói khi có **hai quân Nguyên** trên một hàng thì con xa có viền không.
   - (a) **ĐÃ CHỐT:** Mỗi hướng một viền: **quân Nguyên gần nhất** ở ô 2–4. Tướng mình đứng chắn trước thì quân Nguyên sau nó vẫn có viền, bấm vào thì lao trúng tướng mình. Bấm con Nguyên xa hơn (đứng sau con Nguyên khác) bị từ chối.
   - (b) Mọi quân Nguyên ở ô 2–4 đều có viền; bấm con xa thì lao vẫn trúng con gần (nhiều viền hơn nhưng dễ hiểu nhầm là đánh được con xa).
   - (c) Chỉ có viền khi **quân đầu tiên** ở ô 2–4 là quân Nguyên: tướng mình đứng chắn thì hướng đó không có viền, lao không bao giờ trúng tướng mình (trái với epics, phải sửa epics và GDD dòng 196).
2. **Thử trong game.** Trận 1 thử được "bay qua sông" (Lão đi lên 2 ô) nhưng không thử được "bay qua quân kề" và "trúng tướng mình".
   - (a) **ĐÃ CHỐT:** Thêm trận thử `thu_lao` (chỉ mở khi `--dev`, bố cục ở Dev Notes).
   - (b) Chỉ thử trong trận 1 và duyệt kịch bản; các ca còn lại xem qua kịch bản.
3. **Báo trước khi lao sẽ trúng tướng mình.** Epics giao việc này cho xem trước (Story 2.12). Trước đó người chơi bấm Bộ binh có viền mà Khoái mất máu, không có gì báo.
   - (a) **ĐÃ CHỐT:** Chờ Story 2.12, story này không thêm gì.
   - (b) Thêm ngay một dòng nhắc trên bảng bên phải khi đang chờ xác nhận mục tiêu mà lao sẽ trúng tướng mình (chỉ báo được khi Lão đã đi, vì chưa đi thì bấm một lần là phóng luôn).

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- `ATTACKED` của lao ghi ô quân trúng, không phải ô được bấm.
- Lao dùng `Cause.STRIKE` như đòn Khoái (Sát Thát cộng cho mọi đòn tướng có sát thương; hoạt ảnh 2.11 phân biệt bằng loại tướng).
- Mã từ chối mới `ngoai_tam` cho ô không thẳng hàng, ô kề, ô xa quá tầm, ô ngoài bàn (một mã cho cả bốn, như `khong_ke` của Khoái gộp ô chéo và ngoài bàn).
- Câu của công cụ duyệt cho `khong_co_dich` đổi thành "ô đó không có quân Nguyên đánh được".
- Chờ xác nhận mà bấm (hoặc gõ phím) tướng đã đánh: bỏ chờ, giữ tướng đang chọn (AC 12; theo AC 10 của 2.1 "bấm chỗ khác thì bỏ chờ").
- Trước Story 3.1, lao bay qua rừng, kho lương, làng.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.3 (dòng 583–609), FR13, FR15, FR16 (dòng 41–44), Story 2.12 (dòng 787–805), Story 3.1 (dòng 864–885).
- `_bmad-output/planning-artifacts/game-architecture.md` "Đòn của tướng" (dòng 813–821), M2 (dòng 750–771), mã `tu_choi` (dòng 341), cây thư mục (dòng 545–555, 599–604).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 151 (Phạm Ngũ Lão), 195–196 (trúng mọi phe, không chọn tướng mình), 216 (thẳng hàng), 223 (sông không chặn lao).
- `_bmad-output/project-context.md` (luật bắt buộc, test).
- `_bmad-output/implementation-artifacts/2-1-nguyen-khoai-danh-day-va-va-cham.md` (bảng kiểm lệnh đánh, bấm chuột khi đang chọn tướng), `2-2-song-va-danh-trung-quan-minh.md` (review: test chặt, phá thử từng chỗ), `deferred-work.md`.

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5)

### Debug Log References

- Task 1.1 (2026-10-19): `Reject.NOT_IN_RANGE`, mã `ngoai_tam` (bộ nạp, bộ chạy, chữ công cụ duyệt), chữ `reject_no_target` đổi thành "ô đó không có quân Nguyên đánh được". `test_scenario_loader.gd`: `test_step_reject_code_errors` (danh sách 10 mã), `test_attack_reject_codes_fit_command` thêm `danh` + `ngoai_tam` nạp được, `di` + `ngoai_tam` báo lỗi. `tools/test.sh`: 382/382.
- Task 1.2–1.3: 8 file trong `tests/kich_ban/lao/`, `da_duyet: false`. `tools/xem_kich_ban.sh lao`: bàn trước/sau khớp `mo_ta`; #4 bàn sau hiện `Máu: 3,4 Nguyễn Khoái 2/3`; #7 sáu dòng từ chối hiện đúng câu (3 câu "không thẳng hàng hoặc ngoài tầm lao", 3 câu "không có quân Nguyên đánh được"). `tools/test.sh`: xanh 382/382, `Kịch bản luật: 28 đã duyệt · 8 chưa duyệt (8 chưa đạt)`, lý do đúng bảng (7 file "luật từ chối ("khong_co_dich": quân 2 chưa có đòn (Story 2.3, 2.4)) mà kịch bản không ghi "tu_choi""; `khong_phong_duoc.json` "luật từ chối vì "khong_co_dich" (…), kịch bản ghi "tu_choi": "ngoai_tam"").

- Task 1.5–1.6 (2026-10-19): tác giả trả lời "ok", hỏi lại thì xác nhận "Đúng, duyệt cả 8". Đổi `da_duyet: true` (chỉ khóa đó). `tools/test.sh` trượt đúng như AC 2: `test_approved_scenarios_pass` "kịch bản đã duyệt lao/bay_qua_o_ke.json: bước 1: luật từ chối ("khong_co_dich": quân 2 chưa có đòn (Story 2.3, 2.4)) mà kịch bản không ghi "tu_choi"", `36 đã duyệt · 0 chưa duyệt`. Không commit khi đỏ.
- Task 3.1–3.3 viết trước: `test_rules_attack.gd` thêm 11 test lao, sửa `test_rejections_keep_state` (Lão đánh ô kề → `NOT_IN_RANGE`), `test_targets_are_adjacent_nguyen_units_in_direction_order` (Lão `4,3` có `[2,3]`), `test_stats_read_damage_and_push_distance`, `test_grid_direction_helpers`. Chạy: lỗi script "Static function "straight_dir()" not found in base "Grid"" (đỏ đúng chỗ).
- Task 2: `Grid.distance`, `Grid.straight_dir`; `Stats.min_range`, `max_range`; `RulesAttack` tách `_khoai_targets`, `_lao_targets`, `lao_throw` (tự ghi `ATTACKED` với ô quân trúng); chú thích `ATTACKED`, `Cause.STRIKE`. `tools/test.sh`: 393/393, `36 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.
- Task 3.2, 3.4, 4: `test_battle_controller.gd` thêm `_controller_for(units)` (gom từ `_attack_controller`), `test_lance_targets_and_clears_undo`; câu "Lão chưa có đòn" ở controller và view đổi thành "Lão không có quân Nguyên thẳng hàng trong tầm". `battle_view.gd`: nhánh tướng đã đánh (chuột và phím) gọi `_set_pending(NO_CELL)`. `test_battle_view.gd`: `LAO_DIR`, `_make_lao_main()`, 6 test (viền 3 ô, bay qua quân kề, trúng Khoái chắn, đi rồi phải xác nhận, bấm/gõ phím tướng đã đánh bỏ chờ). `tools/test.sh`: 400/400.
- **Sự cố khi phá thử:** script phá thử lần đầu trả code về bằng `git checkout -q game/src`, nhưng code lao chưa commit nên bị xóa (`rules_attack.gd`, `grid.gd`, `stats.gd`, chú thích `battle_event.gd`, `battle_view.gd`). Test và kịch bản không mất. Viết lại đúng nội dung vừa làm; `tools/test.sh` 400/400 như trước. Sau đó `git add game/src` và sửa script: lưu bản sao file trước khi sửa, trả lại từ bản sao, kiểm `git diff --quiet game/src` sau mỗi lần.
- Task 3.5, 4.3 phá thử (mỗi lần một chỗ, trả lại ngay):
  - R1 lao tìm từ ô kề (cả `_lao_targets` và `lao_throw`) → 6 trượt: `test_selecting_lao_outlines_nearest_enemy_each_way`, `test_lance_flies_over_adjacent_unit`, `test_targets_are_adjacent_nguyen_units_in_direction_order`, `test_lance_flies_over_adjacent_unit_of_any_side`, `test_lance_targets`, kịch bản `lao/bay_qua_o_ke.json` ("luật từ chối ("khong_co_dich": ô 3,3 không phải quân Nguyên gần nhất trong tầm lao)…") và `lao/bay_qua_tuong_minh_ke.json` ("ô 2,5 B mong đợi 2 máu, thực tế 3 máu").
  - R2 lao trúng ô được bấm → `test_lance_hits_blocking_khoai`, `test_lance_hits_blocking_general`, `test_lance_can_kill_blocking_general`, kịch bản `lao/trung_tuong_minh.json` ("ô 3,3 B mong đợi 3 máu, thực tế 2 máu").
  - R3 lao trúng mọi quân (bỏ `return` sau khi trúng) → 3 test trúng tướng chắn và `lao/trung_tuong_minh.json`. `lao/trung_vat_dau_tien.json` **không** trượt: lao chỉ bay tới ô được bấm, bấm con gần thì không tới con xa (xem "Lệch so với Tasks").
  - R4 sông chặn lao → `test_lance_flies_over_river`, `lao/bay_qua_song.json` ("ô 4,5 B mong đợi 2 máu, thực tế 3 máu").
  - R5 `max_range` trừ 1 → 7 trượt, có `test_lance_kills_at_max_range_without_moving_anyone`, `test_stats_read_damage_and_push_distance`, 3 test giao diện dùng Kỵ binh cách 4 ô, `lao/guc_vi_lao.json` ("luật từ chối ("ngoai_tam": ô 5,2 không thẳng hàng với quân 2 trong tầm 2–3)…").
  - R6 lao đẩy 1 ô → 11 trượt, có 6 kịch bản lao (ví dụ `lao/phong_lao_cach_3_o.json` "ô 4,3 mong đợi B (Bộ binh, 2 máu), thực tế trống").
  - R7 bỏ kiểm `NOT_IN_RANGE` (`if false:`) → `test_rejections_keep_state`, `test_lance_rejections_keep_state`, `lao/khong_phong_duoc.json` ("bước 1: luật từ chối vì "khong_co_dich" (ô 2,1 …), kịch bản ghi "tu_choi": "ngoai_tam""). Lần đầu viết sai (`if false and A or B…` chỉ tắt vế ngoài bàn, chỉ 1 test trượt), làm lại.
  - U1 bỏ `_set_pending` ở nhánh chuột → chỉ `test_click_spent_general_cancels_confirm`. U2 bỏ ở `_on_general_key` → chỉ `test_key_of_spent_general_cancels_confirm`.
- Task 5: `game/data/tran/thu_lao.json` đúng bố cục Dev Notes; `test_real_lance_trial_level_loads` so đủ 7 ô quân và 2 ô sông. `tools/test.sh`: 401/401.
- Task 6.4 kiểm bằng mắt: `tools/chay.sh --dev --tran=thu_lao` chạy nền; log `[INFO][battle] nạp trận thu_lao`, không ERROR/WARN. `inject_action` phải gửi cả bấm (`pressed` true) lẫn nhả (false), không thì lần bấm sau không ăn; ảnh chụp trễ một nhịp, chụp hai lần. Ảnh `anh/2-3-1-chon-lao-ba-vien.png`: vòng vàng ở Lão, viền trắng ở Bộ binh `3,1`, Kỵ binh `6,3` (bên kia sông), Bộ binh `3,6` (sau Khoái); Bộ binh `3,2` kề không viền. Ảnh `anh/2-3-2-lao-bay-qua-quan-ke.png`: Bộ binh `3,1` còn 2 máu, `3,2` còn 3, Lão xám. Sau đó cả hai lần chạy, mọi thao tác GoPeak không còn tác dụng (bàn đứng yên dù gửi `end_turn`, chọn tướng, bấm chuột); không chụp được ca trúng Khoái và trận 1 (xem "Lệch so với Tasks").
- Task 6.6: `tools/test.sh` 401/401, `Kịch bản luật: 36 đã duyệt · 0 chưa duyệt (0 chưa đạt)`, kiểm ranh giới đạt.
- Ghi chú: trong lúc làm story này có 2 commit của phiên khác (`e60f5eb`, `8b681b0`: đổi bàn sang nhìn chếch, Story 1.8 làm ngay sau 2.3). Không đụng file của story này; Task 6.1 sửa `game-architecture.md` sau các commit đó.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created
- Phạm Ngũ Lão phóng lao: thẳng hàng, bay qua ô kề, trúng quân đầu tiên ở ô 2–4 (đọc từ `chi_so.json`), 1 sát thương, không đẩy; viền ở quân Nguyên gần nhất mỗi hướng; tướng mình đứng chắn thì trúng tướng mình. Mã từ chối mới `ngoai_tam`. Giao diện chạy chung với đòn Khoái; thêm "bấm/gõ phím tướng đã đánh thì bỏ chờ xác nhận" (mục hoãn 2.1). Trận thử `thu_lao`.
- Tổng test: 382 → 401 (11 test luật lao, 1 test controller, 6 test giao diện, 1 test nạp trận). Kịch bản: 28 → 36 đã duyệt.
- Lệch so với Tasks:
  1. Task 3.3: test chỉ số của Lão đọc `BoardFixture.stats()` như test của Khoái đang có, không đọc `chi_so.json` (số giống nhau; `test_loaders.gd` đã kiểm file thật).
  2. Task 3.5: phá thử "lao trúng mọi quân" chỉ bỏ `return` trong `lao_throw` (lao vẫn dừng ở ô được bấm), nên `lao/trung_vat_dau_tien.json` không trượt. Phá thử đúng như Task ghi (trúng mọi quân tới `tam_danh_xa`) thì Bộ binh `4,2` của kịch bản này mất máu và kịch bản trượt; chưa chạy lại phá thử này (review 2.3). Ca bỏ `return` do `lao/trung_tuong_minh.json` và 3 test GUT bắt.
  3. Task 3.5 R7: lần phá thử đầu viết sai điều kiện, làm lại (Debug Log).
  4. Task 5.2: viết `thu_lao.json` trước test nạp trận, không thấy test đỏ trước.
  5. Task 6.4–6.5: chỉ có 2 ảnh (viền 3 ô, bay qua quân kề). Ca "trúng Khoái" và trận 1 không chụp được vì thao tác GoPeak ngừng có tác dụng sau vài giây ở cả hai lần chạy. Hai ca này có test giao diện (`test_lance_hits_blocking_khoai`, `test_lance_after_move_needs_confirm`); tác giả kiểm bằng tay theo hướng dẫn dưới đây.
  6. Sự cố phá thử xóa code chưa commit, đã viết lại (Debug Log).
  7. Task 3.4: thêm hàm phụ `_controller_for(units)` trong `test_battle_controller.gd` (gom từ `_attack_controller`).
- **Hướng dẫn tác giả tự test:**
  1. `tools/test.sh`: thấy `Kịch bản luật: 36 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ 401/401 test đạt`.
  2. `tools/chay.sh --dev --tran=thu_lao`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
  3. Gõ `2` chọn Lão: 3 viền trắng, ở Bộ binh xa phía trên Lão (không phải con đứng sát Lão), Kỵ binh bên kia sông, Bộ binh dưới cùng (sau Khoái). So với ảnh `anh/2-3-1-chon-lao-ba-vien.png`.
  4. Bấm Bộ binh xa phía trên: nó còn 2 máu, con đứng sát Lão vẫn 3. Lão xám. So với `anh/2-3-2-lao-bay-qua-quan-ke.png`.
  5. `Space`, gõ `2`, bấm Kỵ binh bên kia sông: Kỵ binh còn 1 máu.
  6. `Space`, gõ `2`, bấm Bộ binh dưới cùng: **Khoái** còn 2 máu, Bộ binh không bị gì.
  7. `Space`. Gõ `1`, bấm Bộ binh dưới cùng (Khoái đánh, Khoái xám). Gõ `2`, bấm ô `2,3` (Fn+F1 hiện tọa độ ô; Lão đi 1 ô), bấm Kỵ binh (hiện "Bấm lần nữa để đánh"), rồi bấm Khoái: dòng nhắc mất, Lão vẫn được chọn, Kỵ binh không mất máu.
  8. Trận 1 (`tools/chay.sh --dev`): gõ `2`, bấm ô `2,4` (Lão đi 2 ô); Bộ binh `5,4` bên kia sông có viền; bấm nó hai lần (lần đầu hiện "Bấm lần nữa để đánh"): nó còn 2 máu.
  - Nhắc: trên Mac F1 là Fn+F1.

### File List

- `game/src/core/rules_attack.gd`, `grid.gd`, `stats.gd`, `battle_event.gd` (sửa)
- `game/src/battle/battle_view.gd` (sửa)
- `game/src/data/scenario_loader.gd`, `game/tests/scenario_runner.gd`, `game/i18n/text.csv`, `game/i18n/text.vi.translation` (sửa, Task 1.1)
- `game/src/data/stats_loader.gd` (sửa, review 2.3: tầm gần của Lão từ 2 trở lên)
- `game/tests/kich_ban/lao/` 8 file (mới)
- `game/tests/test_rules_attack.gd`, `test_battle_controller.gd`, `test_battle_view.gd`, `test_loaders.gd`, `test_scenario_loader.gd` (sửa)
- `game/data/tran/thu_lao.json` (mới)
- `_bmad-output/planning-artifacts/game-architecture.md`, `gdds/gdd-GameTest-2026-10-15/gdd.md` (sửa)
- `_bmad-output/implementation-artifacts/anh/2-3-1-chon-lao-ba-vien.png`, `2-3-2-lao-bay-qua-quan-ke.png` (mới)
- `_bmad-output/implementation-artifacts/2-3-pham-ngu-lao-phong-lao.md`, `sprint-status.yaml`, `deferred-work.md` (sửa)

### Change Log

- 2026-10-19: Tạo story. Tác giả chốt cả 3 câu chọn (a): viền ở quân Nguyên gần nhất mỗi hướng, thêm trận thử `thu_lao`, báo trước khi lao trúng tướng mình để Story 2.12.
- 2026-10-19: Kịch bản đợt 5 (8 cái) tác giả duyệt; luật lao, mã `ngoai_tam`, bỏ chờ xác nhận khi bấm tướng đã đánh, trận thử `thu_lao`, sửa GDD dòng 151 và kiến trúc. Test 382 → 401, kịch bản 36 đã duyệt. Chuyển sang review.
- 2026-10-19: Sửa theo code review: bộ nạp đòi tầm gần của Lão ≥ 2 (tác giả chốt), `lao_throw` assert khi không trúng ai, thêm test (mép bàn, chỉ số thật của Lão, điều kiện trước, `validate` sau lệnh đi, sông trong trận test giao diện), sửa ghi chép. Test 401 → 402. Chuyển sang done.
