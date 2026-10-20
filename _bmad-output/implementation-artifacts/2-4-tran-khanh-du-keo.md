---
baseline_commit: baba5d3
---

# Story 2.4: Trần Khánh Dư kéo

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn Trần Khánh Dư kéo địch,
để kéo chúng vào ô đỏ, xuống sông hoặc ra khỏi vị trí đẹp.

_Story luật thứ tư của E2, đòn thứ ba (đòn cuối của ba tướng). Kéo **không gây sát thương**. Phần "rừng, kho lương, làng là vật đầu tiên thì không kéo được" làm ở Story 3.1 (E3); hầm chông trừ máu khi bị kéo ngang qua làm ở Story 3.4; trước đó kéo coi các ô này như ô thường. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code luật (M3).** **Cho** 7 kịch bản mới ở Dev Notes "Đợt kịch bản 6" (`da_duyet: false`) và phần khung ở Task 1.1 (nguyên nhân sự kiện mới `PULL`). **Khi** gõ `tools/test.sh`, **thì**:
   - test xanh, có dòng `Kịch bản luật: 37 đã duyệt · 7 chưa duyệt (7 chưa đạt)`;
   - mỗi kịch bản mới có lý do đúng như bảng "Lý do chưa đạt" ở Dev Notes.

   AI commit đợt này rồi **dừng lại chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh keo`. Chưa duyệt xong thì không viết dòng code luật nào (`rules_attack.gd`, `stats.gd`).
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` **trượt** (kịch bản đã duyệt chưa đạt). Kịch bản bị nói "sai" thì AI sửa kịch bản theo lý do của tác giả rồi cho duyệt lại, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh:
   - có dòng `Kịch bản luật: 44 đã duyệt · 0 chưa duyệt (0 chưa đạt)`;
   - kiểm ranh giới đạt;
   - sau mỗi lệnh, `BattleState.validate()` rỗng.
4. **Kéo (FR14).** **Cho** Trần Khánh Dư và một quân Nguyên thẳng hàng (cùng hàng hoặc cùng cột), cách 3 ô, đường trống. **Khi** bấm vào quân đó, **thì** quân đó bị kéo 2 ô về phía Dư (đứng kề Dư) và **không mất máu**. Tầm 3 lấy từ `tam_danh` và số ô kéo 2 lấy từ `tam_keo` trong `chi_so.json`, không ghi số trong code.
5. **Kéo vật đầu tiên trên hàng.** Mỗi hướng chỉ xét **vật đầu tiên** trong vòng `tam_danh` (3) ô tính từ Dư. Vật đó là **quân Nguyên** thì có thể kéo. Là **tướng mình** thì hướng đó không kéo được: không có viền, và bấm quân Nguyên đứng sau tướng bị từ chối.
6. **Mục tiêu kề.** **Khi** quân Nguyên đã đứng kề Dư, **thì** không có gì xảy ra, không ai mất máu **(theo câu 2 ở "Quyết định của tác giả": chờ chốt, mặc định (a): ô kề không có viền, bấm vào bị từ chối `ngoai_tam`, Dư không bị tính là đã đánh)**.
7. **Mục tiêu cách 2 ô** **(theo câu 1: chờ chốt, mặc định (a))**. Kéo 2 ô nhưng chỉ còn 1 ô trống giữa Dư và mục tiêu: quân bị kéo **dừng sát Dư** (1 ô), không ai mất máu, Dư vẫn tính là đã đánh.
8. **Kéo qua sông.** **Khi** đường kéo đi qua ô sông, **thì** quân Nguyên rơi xuống sông, chết đuối, bị nhấc khỏi bàn (`DROWNED`). Quân đã chết đuối không bị kéo tiếp.
9. **Đường kéo đi từng ô qua `ForcedMove.run`**, dùng chung với đòn đẩy: va chạm, vật cản và chết đuối đã có sẵn từ Story 2.1–2.2. Không viết lại cách đi từng ô. Mọi `MOVED` của đòn kéo ghi nguyên nhân mới `PULL`.
10. **Viền mục tiêu.** **Khi** chọn Dư, **thì** chỉ quân Nguyên là vật đầu tiên của hàng (ở ô thứ 2–3, theo câu 2) mới có viền trắng "đánh được". Mỗi hướng nhiều nhất một viền; không có thì hướng đó không bấm đánh được.
11. **Từ chối.** Lệnh kéo vào ô không thẳng hàng, ô kề, ô xa quá 3, ô ngoài bàn bị từ chối `ngoai_tam`. Ô trong tầm mà không có viền (ô trống, tướng mình, quân Nguyên đứng sau tướng hay sau quân Nguyên khác) bị từ chối `khong_co_dich`. Bàn giữ nguyên. Chữ của công cụ duyệt cho `ngoai_tam` đổi cho đúng cả lao lẫn kéo.
12. **Như đòn Khoái và Lão.** Đi rồi kéo được; đã đi thì phải bấm xác nhận lần hai (FR15). Kéo rồi thì Dư mờ xám, không đi, không kéo được nữa; kéo xóa lịch sử hủy (FR10). Kết thúc lượt thì kéo lại được. Mọi việc này chạy chung qua `attack_targets`: **không viết nhánh riêng cho Dư** trong `BattleView`.
13. **Trận thử** (theo câu 3, mặc định (a)). `tools/chay.sh --dev --tran=thu_keo` mở trận "Thử kéo". Tác giả làm được trong game: kéo cách 3 ô, kéo xuống sông, thấy tướng mình đứng chắn thì không kéo được, thấy quân kề không có viền.
14. **Kịch bản.** Có kịch bản trong `keo/`, đã duyệt và đạt.
15. **Không sửa luật khác.** Đòn của Khoái và Lão, bảng thứ tự kiểm của lệnh đánh với hai tướng này, giữ nguyên hành vi; 37 kịch bản đã duyệt hiện có vẫn đạt, không sửa file nào.

## Tasks / Subtasks

- [ ] **Task 0: Tác giả chốt 3 câu hỏi** ở "Quyết định của tác giả". Mặc định đã ghi sẵn (phương án (a) mỗi câu); tác giả đổi thì sửa AC 6, 7, 10, 13 và kịch bản #2, #4 theo đó **trước Task 1**. Không làm Task 1 khi chưa có câu trả lời (kịch bản #2, #4 phụ thuộc câu 1, 2).
- [ ] **Task 1: Khung, đợt kịch bản 6, dừng chờ duyệt** (AC: 1, 2)
  - [ ] 1.1 Khung (không phải code luật, làm trước để file kịch bản nạp được):
    - `src/core/battle_event.gd`: thêm `PULL` vào **cuối** enum `Cause` (`WALK, STRIKE, PUSH, COLLISION, PULL`); sửa chú thích đầu enum. Kiểm mọi chỗ duyệt hay `match` trên `Cause` (`grep -rn "Cause" game/src game/tests`): chữ mô tả sự kiện của `BoardFixture.describe` và công cụ duyệt phải ra `PULL` hợp lý.
    - `i18n/text.csv`: `scenario.viewer.reject_not_in_range` đổi thành `ô đó không thẳng hàng hoặc ngoài tầm đánh`. Chỉ là chữ công cụ duyệt, không đổi file kịch bản nào. `scenario.viewer.reject_no_target` giữ `ô đó không có quân Nguyên đánh được` (đã đúng cho kéo). Nếu `text.vi.translation` sinh từ csv thì sinh lại (xem Story 2.3: file đó phải vào File List).
    - Bộ nạp kịch bản (`src/data/scenario_loader.gd`, `COMMAND_REJECTS["danh"]`) đã nhận `ngoai_tam`, `khong_co_dich`: **không** thêm mã từ chối mới.
    - `tests/test_scenario_loader.gd`: không cần thêm ca (không có mã mới); nếu có test liệt kê nguyên nhân sự kiện thì thêm `PULL`.
  - [ ] 1.2 Viết 7 file đúng như Dev Notes "Đợt kịch bản 6", `"da_duyet": false`, thư mục mới `tests/kich_ban/keo/`. Không đụng 37 kịch bản đã duyệt.
  - [ ] 1.3 `tools/xem_kich_ban.sh keo`: đọc lại từng bàn trước/sau, khớp `mo_ta`; dòng `tu_choi` của #6 hiện đúng câu tiếng Việt. `tools/test.sh`: xanh, `37 đã duyệt · 7 chưa duyệt (7 chưa đạt)`, lý do khớp bảng. Ghi Debug Log.
  - [ ] 1.4 Commit: `Kịch bản Trần Khánh Dư kéo chờ duyệt (Story 2.4)`.
  - [ ] 1.5 **HALT.** Nhắn tác giả bằng tiếng Việt: gõ `tools/xem_kich_ban.sh keo`, đọc 7 kịch bản, trả lời "đúng" hoặc "sai: <lý do>" cho từng cái. Nói rõ ba điều:
    - #2 (cách 2 ô) và #4 (quân kề) thể hiện hai câu trả lời của "Quyết định của tác giả";
    - trước Story 3.1, rừng, kho lương, làng nằm giữa đường kéo **không** chặn việc chọn mục tiêu (chưa có kịch bản nào có rừng trên đường kéo, vì 3.1 sẽ đổi luật này);
    - hầm chông trừ máu khi bị kéo ngang qua chờ Story 3.4.
    Không làm Task 2 trở đi khi chưa có câu trả lời.
  - [ ] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng" (chỉ đổi khóa đó). Kịch bản "sai" thì xử lý theo AC 2. `tools/test.sh` **phải trượt**. Ghi Debug Log. **Không commit** khi đang đỏ.
- [ ] **Task 2: Lõi luật** (AC: 3–11, 15)
  - [ ] 2.1 `src/core/stats.gd`: `pull_range(type)` (`tam_danh`), `pull_distance(type)` (`tam_keo`). `StatsLoader` đã bắt buộc hai khóa này (`tam_danh` ≥ 1, `tam_keo` ≥ 0), không sửa bộ nạp. Chú thích đầu file "Hàm đòn thêm ở story dùng nó" giữ nguyên.
  - [ ] 2.2 `src/core/rules_attack.gd`:
    - `targets`: thêm `UnitType.TRAN_KHANH_DU: return _du_targets(state, unit)`. `_du_targets` theo "Viền mục tiêu của Dư" ở Dev Notes.
    - `resolve`: nhánh Dư thay cho nhánh `_` "chưa có đòn" (nhánh `_` không còn loại tướng nào, giữ lại với `assert(false, ...)` hoặc bỏ nếu `match` đã phủ đủ ba tướng; chọn một, ghi Debug Log). Thứ tự kiểm theo "Bảng thứ tự kiểm của lệnh đánh" ở Dev Notes. **Kiểm hết rồi mới sửa.** Hợp lệ thì `ATTACKED` → `du_pull` → `unit.has_attacked = true`.
    - `static func du_pull(state, du, cell, events)`: theo "Đường kéo (`du_pull`)" ở Dev Notes. Không gọi `Effects.damage` (kéo 0 sát thương). Đi từng ô qua `ForcedMove.run(..., BattleEvent.Cause.PULL, events)`.
    - Sửa chú thích đầu file (bỏ "Dư: Story 2.4", thêm Dư).
  - [ ] 2.3 `src/core/battle_event.gd`: chú thích `ATTACKED` ghi `to_cell` là ô quân bị kéo (Dư) cùng với hai tướng kia.
- [ ] **Task 3: Test lõi luật** (AC: 3–12, 15)
  - [ ] 3.1 `tests/test_rules_attack.gd` thêm (dựng bằng `BoardFixture`, mỗi ca so **đúng dãy sự kiện** và `validate()` rỗng qua `_attack`):
    - kéo quân Nguyên ở ô thứ 3, đủ 4 hướng: `["ATTACKED 3 c,h", "MOVED 101 a>b PULL", "MOVED 101 b>c PULL"]`, máu không đổi, Dư `has_attacked` bật, `has_moved` không bật;
    - cách 2 ô (theo câu 1): một `MOVED ... PULL`, đứng sát Dư, không `DAMAGED`;
    - kéo xuống sông ở ô thứ 2 hoặc ô kề: `MOVED ... PULL`, `DROWNED 101 c,h`, quân bị nhấc khỏi bàn, không `DAMAGED`;
    - Cung kỵ 1 máu bị kéo: còn 1 máu (không có `DAMAGED`);
    - kéo quân Nguyên khi đường kéo có **quân thứ hai đứng sau mục tiêu** (không ở giữa): quân sau đứng yên;
    - tướng mình đứng chắn ở ô thứ 2 (hoặc kề): bấm quân Nguyên đứng sau bị từ chối `NO_TARGET`, state giữ nguyên;
    - từ chối theo đủ bảng (mỗi dòng một ca, cho Dư): `NOT_IN_RANGE` với ô kề (theo câu 2), ô chéo, ô cách 4, ô ngoài bàn; `NO_TARGET` với ô trống, ô tướng mình, quân Nguyên đứng sau tướng mình, quân Nguyên đứng sau quân Nguyên khác; `ALREADY_ATTACKED` khi kéo hai lần. State giữ nguyên (`BoardFixture.picture`), `has_attacked` không bật;
    - đi rồi kéo được; kéo rồi đi bị `ALREADY_MOVED`... (kiểm đúng mã luật đi đang trả khi tướng đã đánh, như ca của Lão trong `test_lance_once_per_turn_and_no_move_after`);
    - rừng nằm giữa Dư và mục tiêu (**trước 3.1**): mục tiêu vẫn có viền, kéo thì quân dừng trước rừng và mất 1 máu (va chạm `ForcedMove`). Ghi chú trong test: 3.1 đổi ca này (rừng là vật đầu tiên thì không kéo được); đây là ca duy nhất 3.1 phải sửa, vì thế nó nằm trong test GUT chứ **không** thành kịch bản đã duyệt.
  - [ ] 3.2 Sửa test cũ đang ghi "Dư chưa có đòn" (đọc từng chỗ, giữ ý của test):
    - `test_rejections_keep_state` (dòng 54): ca `[3, Vector2i(4, 3), "NO_TARGET"]` với Dư ở `5,3`, mục tiêu `4,3` kề: theo câu 2 thành `"NOT_IN_RANGE"` (giữ ca, đổi mã);
    - `test_targets_are_adjacent_nguyen_units_in_direction_order` (dòng 101): đổi ca Dư (`du_state`: Dư `3,3`, Bộ binh `3,2` kề) thành kết quả mới: kề thì `targets` rỗng (theo câu 2); thêm một `du_state` thứ hai có Bộ binh cách 2 và cách 3. Đổi câu thông báo cho đúng;
    - `test_battle_controller.gd`, `test_battle_view.gd`, `test_main.gd`: tìm mọi ca dùng Dư (grep `"3"` trên bàn dựng tay, `KEY_3`); chỉ đổi ca nào ghi "Dư chưa có đòn". Mọi chỗ sửa ghi vào "Lệch so với Tasks" nếu khác danh sách này.
  - [ ] 3.3 `tests/test_rules_attack.gd`:
    - `targets` của Dư: đúng thứ tự B→Đ→N→T; mỗi hướng một ô; **không** bỏ qua tướng mình (tướng mình đứng chắn thì hướng đó rỗng, khác Lão); không có ô kề; dừng ở mép bàn; rỗng khi đã kéo;
    - `test_stats_read_damage_and_push_distance` thêm `pull_range` và `pull_distance` của Dư đọc đúng `chi_so.json` (3 và 2).
  - [ ] 3.4 `tests/test_battle_controller.gd`: Dư kéo thì `can_undo()` false; `attack_targets(3)` đúng trên một bố cục có quân Nguyên thẳng hàng.
  - [ ] 3.5 Phá thử, **mỗi lần sửa tạm một chỗ**, chạy `tools/test.sh`, ghi tên kịch bản và test GUT trượt vào Debug Log, trả lại ngay, `git diff --quiet game/src` sau mỗi lần:
    - kéo không đi (`du_pull` rỗng) → `keo/keo_cach_3_o.json` phải trượt;
    - kéo 1 ô thay vì `tam_keo` → `keo/keo_cach_3_o.json` phải trượt;
    - kéo gây 1 sát thương → `keo/keo_cach_3_o.json`, `keo/keo_quan_1_mau.json` phải trượt;
    - kéo cách 2 ô mà không dừng sát Dư (kéo đủ 2 ô, va Dư) → `keo/keo_cach_2_o.json` phải trượt (nếu câu 1 chọn (a));
    - kéo theo hướng ngược (đẩy ra xa) → `keo/keo_cach_3_o.json`, `keo/keo_qua_song.json` phải trượt;
    - bỏ qua tướng mình khi tìm vật đầu tiên (như Lão) → `keo/tuong_chan_khong_keo.json` phải trượt;
    - cho phép kéo quân kề → `keo/muc_tieu_ke_khong_keo.json`, `keo/khong_keo_duoc.json` phải trượt (nếu câu 2 chọn (a));
    - tầm đọc thành 2 (`pull_range` trừ 1) → `keo/keo_cach_3_o.json` phải trượt;
    - bỏ kiểm `NOT_IN_RANGE` (để rơi xuống `NO_TARGET`) → `keo/khong_keo_duoc.json` phải trượt.
- [ ] **Task 4: Giao diện** (AC: 10, 12)
  - [ ] 4.1 Đọc `src/battle/battle_view.gd`. Viền, chờ xác nhận, bỏ chọn sau khi đánh đã chạy chung cho mọi tướng qua `attack_targets`; phím `3` (hoặc phím chọn tướng thứ ba) chọn Dư. **Không** viết nhánh riêng cho Dư. Có gì phải sửa thì ghi vào "Lệch so với Tasks".
  - [ ] 4.2 `tests/test_battle_view.gd` thêm trận thử `_make_keo_main()` qua `_make_level_main` (thư mục riêng `KEO_DIR`, xóa ở `after_each` như `LAO_DIR`). Bố cục: Dư `3` ở `3,3`; Bộ binh `3,0` (ô thứ 3 hướng Bắc); Kỵ binh `6,3` (hướng Đông, có sông `4,3`, `5,3`); Khoái `1` ở `3,4` kề Nam, Bộ binh `3,6` sau Khoái; Bộ binh `2,3` kề Tây, Bộ binh `1,3` sau nó. Các ca, mỗi ca kiểm cả điều kiện trước:
    - phím `3` thật: `_view(main).target_cells()` **đúng bằng** `[3,0, 6,3]` (B→Đ→N→T; không có `3,4`, `3,6`, `2,3`, `1,3`); `_board(main).target_cells()` giống hệt;
    - bấm chuột thật vào `3,0`: Bộ binh về `3,2` (kề Dư), còn 3 máu; đồng Dư `is_attacked()`; Dư bị bỏ chọn; `can_undo()` false;
    - bấm `6,3`: Kỵ binh bị nhấc khỏi bàn (rơi xuống sông `5,3`);
    - đi Dư rồi bấm mục tiêu: lần đầu `pending_cell()` đúng ô đó và dòng nhắc là `tr("hud.confirm_attack")`; lần hai mới kéo (đi sang ô giữ nguyên hướng thẳng hàng với một Bộ binh; kiểm `target_cells()` sau khi đi, trước khi bấm);
    - bấm quân kề `2,3`: không có lệnh nào được gửi (`can_undo()` giữ nguyên) và Dư không xám (theo câu 2).
  - [ ] 4.3 Phá thử giao diện (ghi Debug Log): nếu `4.1` phải sửa `battle_view.gd` thì phá thử đúng chỗ đó; không sửa thì ghi "không phải sửa giao diện" và bỏ mục này.
- [ ] **Task 5: Trận thử `thu_keo`** (AC: 13; theo câu 3)
  - [ ] 5.1 `game/data/tran/thu_keo.json` (MỚI) đúng bố cục ở Dev Notes "Trận thử `thu_keo`". Không đổi `tran_01.json`, `thu_ba_tuong.json`, `thu_day.json`, `thu_lao.json`.
  - [ ] 5.2 `tests/test_loaders.gd`: thêm `test_real_pull_trial_level_loads` theo mẫu `test_real_lance_trial_level_loads`: không lỗi, không cảnh báo, **so đủ ô và loại của mọi quân**, kiểm từng ô sông.
- [ ] **Task 6: Tài liệu, kiểm bằng mắt, commit** (AC: 3–15)
  - [ ] 6.1 `_bmad-output/planning-artifacts/game-architecture.md`: cây thư mục `data/tran/` thêm `thu_keo.json`; cây `kich_ban/` thêm nhóm `keo/` nếu cây có liệt kê nhóm; bảng "Đòn của tướng", dòng Trần Khánh Dư, ghi các câu trả lời 1–2 và "kề không có viền"; danh sách `Cause` (nếu kiến trúc liệt kê) thêm `PULL`.
  - [ ] 6.2 GDD (`gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 160 cột luật của Trần Khánh Dư và dòng 206): ghi câu trả lời 1–2 và "Chốt <ngày>". Không sửa chỗ nào khác của GDD.
  - [ ] 6.3 Kiểm bằng mắt: chạy `tools/chay.sh --dev --tran=thu_keo` ở chế độ nền, chờ ~5 giây. GoPeak: `inject_action` cho phím, `inject_mouse_click` theo pixel `(486 + (cột − hàng)·64, 141 + (cột + hàng)·32 + 32)` hoặc công thức hiện hành trong Debug Log 2.3 (bàn 7×7 giữ `board.position = (262, 139)`; **tính lại từ Debug Log 2.3, không đoán**). Làm theo "Hướng dẫn tác giả tự test", `capture_screenshot` sau mỗi bước chính, lưu `_bmad-output/implementation-artifacts/anh/2-4-*.png` (ít nhất: chọn Dư thấy 2 viền; sau khi kéo cách 3 ô; sau khi kéo xuống sông). Tắt game. Log không có ERROR/WARN. Task nào không làm được thì **bỏ dấu [x] và ghi rõ chờ tác giả kiểm tay** (review 2.3 đã bắt lỗi ghi [x] mà thiếu ảnh).
  - [ ] 6.4 `tools/test.sh` xanh (AC 3). Commit một lần: kịch bản đã duyệt, code, test, trận thử, tài liệu, `.uid` mới, `game/i18n/text.vi.translation` nếu đổi. Ví dụ: `Trần Khánh Dư kéo (Story 2.4)`.
  - [ ] 6.5 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes, dùng kết quả thật (số test thật).

## Dev Notes

### Bối cảnh

- Story 2.1 làm xong khung đòn đánh: `Command.attack`, `RulesAttack`, `Effects.damage`, `ForcedMove.run`, `has_attacked`, viền trắng, chờ xác nhận, đồng xám, `BattleController.attack_targets`. Story 2.2 thêm sông và trúng quân mình. Story 2.3 thêm đòn của Lão (nhánh `match` theo loại tướng, `Grid.straight_dir`, `Grid.distance`, mã `ngoai_tam`, `NOT_IN_RANGE`). Story này **chỉ thêm đòn của Dư** vào khung đó, theo đúng mẫu của Lão; giao diện chạy chung, gần như không phải sửa.
- Kéo **không gây sát thương**: không gọi `Effects.damage`. Chỉ `ForcedMove.run` (di chuyển từng ô, va chạm, chết đuối).
- **Chưa có:** rừng, kho lương, làng là vật đầu tiên thì không kéo được (3.1); hầm chông trừ máu khi bị kéo ngang qua (3.4, `Effects.move` có ghi chú); quân Nguyên bị kéo vào ô ải thì thua (3.11); thắng/thua (2.5); AI và đòn địch (2.6–2.9), kể cả "đòn địch dịch theo khi quân đó bị kéo" (2.9); hoạt ảnh kéo (2.11); xem trước (2.12); Sát Thát không cộng cho kéo (3.13).
- Trận 1 và 2 không có Dư (chốt 2026-10-17: Dư ra trận từ trận 3), nên story này thử bằng trận thử.
- Tác giả không đọc code. Thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Luật (spec) **[FR14, FR15, FR16, FR17, FR28; GDD dòng 160, 169, 206, 231, 237; kiến trúc "Đòn của tướng"]**

- **Thẳng hàng:** cùng hàng hoặc cùng cột với Dư (4 hướng, không chéo).
- **Tầm:** vật đầu tiên trên hàng trong vòng `tam_danh` (3) ô tính từ Dư.
- **Vật đó phải là quân Nguyên.** Tướng mình là vật đầu tiên thì hướng đó không kéo được. Rừng, kho lương, làng là vật đầu tiên thì không kéo được: **làm ở Story 3.1**, trước đó coi là ô thường.
- **Kéo `tam_keo` (2) ô về phía Dư**, đi từng ô qua `ForcedMove.run`, 0 sát thương. Dừng sớm nếu bị chặn (va chạm theo bảng di chuyển cưỡng bức, FR17).
- **Sông:** quân Nguyên bị kéo xuống sông thì chết đuối (FR28). Mục tiêu của Dư luôn là quân Nguyên nên không có ca "tướng bị kéo vào sông".
- **Mục tiêu kề Dư:** không có hiệu ứng (GDD dòng 206, "Chốt 2026-10-16"). Câu 2 làm rõ viền và từ chối cho ca này.
- **Không chọn tướng mình làm mục tiêu** (chốt 2026-10-17). Dư không bao giờ kéo tướng mình.
- **Tiết kiệm hành động, xác nhận, hủy:** như Khoái và Lão (Story 2.1, 2.3). Không có gì mới.
- Tầm 3 và kéo 2 là **số tạm chốt 2026-10-16**, xem lại ở playtest E4 (phương án dự phòng: kéo 1 ô). Chỉ đọc từ `chi_so.json`, để dễ đổi.

### Viền mục tiêu của Dư (`_du_targets`)

Với mỗi hướng theo thứ tự `Grid.DIRECTIONS` (B→Đ→N→T), `d` chạy từ **1** tới `pull_range` (3). `cell = du.cell + dir * d`. Ra ngoài bàn thì dừng hướng này. Nếu ô có quân:
- là quân Nguyên và `d ≥ 2` (theo câu 2 (a); ô kề không viền): thêm `cell`, dừng hướng này;
- là quân Nguyên ở `d = 1`, hoặc là tướng mình: dừng hướng này, **không** thêm viền (vật đầu tiên không kéo được, nên các quân sau nó không được xét);
Ô không có quân: đi tiếp (kể cả sông, rừng, kho lương, làng ở story này).

Khác Lão: **tướng mình đứng chắn thì hướng đó rỗng**, không đi tiếp (Lão bay qua; kéo thì chỉ kéo vật đầu tiên).

Story 3.1 sẽ thêm "gặp rừng, kho lương, làng ở bất kỳ ô nào từ ô kề thì dừng hướng này, không viền".

### Đường kéo (`du_pull`)

- `to_du = Grid.straight_dir(cell, du.cell)` (hướng từ mục tiêu về Dư).
- Số ô kéo = `pull_distance` (2); **theo câu 1 (a): `mini(pull_distance, Grid.distance(du.cell, cell) - 1)`** để quân không bao giờ kéo vào chính ô Dư. Theo câu 1 (b) thì không có `mini` và quân va Dư (cả hai mất 1 máu, qua `ForcedMove.run` có sẵn).
- `ForcedMove.run(state, target, to_du, <số ô>, BattleEvent.Cause.PULL, events)`.
- Sự kiện: `ATTACKED(du.id, cell)` (ô mục tiêu trước khi kéo, cho hoạt ảnh 2.11), rồi `MOVED` từng ô với nguyên nhân `PULL`, có thể `DROWNED`. Không có `DAMAGED` (trừ ca va chạm của câu 1 (b) hoặc rừng giữa đường trước 3.1).
- `resolve` đã kiểm `cell` có trong `targets`, nên luôn có quân Nguyên ở `cell`.

### Bảng thứ tự kiểm của lệnh đánh (sau story này)

| Kiểm | `Reject` | Mã `tu_choi` | Lý do (cho dev và log, không qua `tr()`) |
|---|---|---|---|
| Không có quân id đó | `NO_UNIT` | `khong_co_quan` | `không có quân %d` |
| Quân không phải tướng | `NOT_GENERAL` | `khong_phai_tuong` | `quân %d không phải tướng` |
| Tướng đã đánh trong lượt này | `ALREADY_ATTACKED` | `da_danh_roi` | `quân %d đã đánh rồi trong lượt này` |
| **Khoái:** ô không kề cạnh | `NOT_ADJACENT` | `khong_ke` | (không đổi) |
| **Khoái:** ô không có quân Nguyên | `NO_TARGET` | `khong_co_dich` | (không đổi) |
| **Lão:** ngoài bàn, không thẳng hàng, ngoài `min_range`–`max_range` | `NOT_IN_RANGE` | `ngoai_tam` | (không đổi) |
| **Lão:** ô không có trong `targets` | `NO_TARGET` | `khong_co_dich` | (không đổi) |
| **Dư (MỚI):** ô ngoài bàn, không thẳng hàng, ô kề, hoặc cách quá `pull_range` | `NOT_IN_RANGE` | `ngoai_tam` | `ô %s không thẳng hàng với quân %d trong tầm 2–%d` |
| **Dư (MỚI):** ô không có trong `targets` (trống, tướng mình, quân Nguyên đứng sau vật khác) | `NO_TARGET` | `khong_co_dich` | `ô %s không phải quân Nguyên đầu tiên trên hàng trong tầm kéo` |

Kiểm hết rồi mới sửa: không gọi `Effects` hay `ForcedMove` trước khi qua hết bảng. Không đổi thứ tự các dòng cũ.

### Đợt kịch bản 6

Quy ước như các đợt trước: `phien_ban_dinh_dang: 1`, bàn 7×7, mỗi ô cách nhau một dấu cách, `sau.dia_hinh` chép y `truoc.dia_hinh`. Tọa độ `cot,hang`; ô không nêu là đất trống, không có quân. Chỉ ghi `mau` cho quân không đủ máu. Mọi kịch bản ghi `sau.da_danh`. Không có `ket_thuc_luot`. Thư mục `keo/`. Mọi ví dụ dưới đây theo mặc định (a) của câu 1, 2.

| # | File | `mo_ta` | Bàn trước | `hanh_dong` | Bàn sau |
|---|---|---|---|---|---|
| 1 | `keo/keo_cach_3_o.json` | `Trần Khánh Dư kéo Bộ binh cách 3 ô cùng cột: Bộ binh bị kéo 2 ô về phía Dư, đứng kề Dư, không mất máu.` | `3` ở 3,5; `B` ở 3,2 | `danh 3 → 3,2` | `3` ở 3,5; `B` ở 3,4; `da_danh: ["3"]` |
| 2 | `keo/keo_cach_2_o.json` | `Bộ binh cách Dư 2 ô: chỉ còn 1 ô trống nên bị kéo 1 ô, dừng sát Dư, không ai mất máu.` | `3` ở 1,3; `B` ở 3,3 | `danh 3 → 3,3` | `3` ở 1,3; `B` ở 2,3; `da_danh: ["3"]` |
| 3 | `keo/keo_qua_song.json` | `Đường kéo đi qua sông: Kỵ binh bị kéo xuống sông ở ô thứ 2, chết đuối, bị nhấc khỏi bàn.` | `~` ở 3,3; `3` ở 1,3; `K` ở 4,3; `B` ở 6,6 | `danh 3 → 4,3` | `~` ở 3,3; `3` ở 1,3; `B` ở 6,6 (Kỵ binh mất khỏi bàn); `da_danh: ["3"]` |
| 4 | `keo/muc_tieu_ke_khong_keo.json` | `Bộ binh đã đứng kề Dư: không bấm kéo được, không ai mất máu, Dư chưa đánh.` | `3` ở 3,3; `B` ở 3,4 | `danh 3 → 3,4` **`ngoai_tam`** | giống trước; `da_danh: []` |
| 5 | `keo/tuong_chan_khong_keo.json` | `Khoái đứng ở ô thứ 2, Bộ binh ở ô thứ 3 phía sau: vật đầu tiên là tướng mình nên không kéo được Bộ binh đó. Hướng khác vẫn kéo được Bộ binh cách 3 ô.` | `3` ở 3,5; `1` ở 3,3; `B` ở 3,2; `B` ở 6,5 | `danh 3 → 3,2` **`khong_co_dich`**; `danh 3 → 6,5` | `3` ở 3,5; `1` ở 3,3; `B` ở 3,2; `B` ở 4,5; `da_danh: ["3"]` |
| 6 | `keo/khong_keo_duoc.json` | `Dư không kéo được: ô kề, ô chéo, ô cách 4, ô trống, tướng mình, quân đứng sau tướng mình, Bộ binh đứng sau Bộ binh khác.` | xem dưới bảng | 7 lệnh bị từ chối (xem dưới bảng) | giống trước; `da_danh: []` |
| 7 | `keo/keo_quan_1_mau.json` | `Cung kỵ 1 máu bị kéo vẫn còn 1 máu: kéo không gây sát thương.` | `3` ở 3,5; `C` ở 3,2; `B` ở 0,0 | `danh 3 → 3,2` | `3` ở 3,5; `C` ở 3,4; `B` ở 0,0; `da_danh: ["3"]` (Cung kỵ giữ 1 máu, không cần ghi `mau`) |

Bàn của #6 (7×7, hàng 0 ở trên; mọi dòng `dia_hinh` là `. . . . . . .`):

```
quan
. . . . . . .
. . . . . . .
. . . . . . .
B 3 . 2 B B .
. . K . . . .
. B . . . . .
. B . . . . .
```

Dư `3` ở 1,3; Lão `2` ở 3,3 (tướng mình); Bộ binh ở 0,3, 4,3, 5,3, 1,5, 1,6; Kỵ binh ở 2,4. Chỉ có **một** ô có viền: `1,5` (Bộ binh ô thứ 2 hướng Nam, không bấm). Bảy lệnh, theo thứ tự:

| Lệnh | Mã | Vì sao |
|---|---|---|
| `danh 3 → 0,3` | `ngoai_tam` | Bộ binh kề |
| `danh 3 → 2,4` | `ngoai_tam` | ô chéo |
| `danh 3 → 5,3` | `ngoai_tam` | cách 4 ô |
| `danh 3 → 1,1` | `khong_co_dich` | ô trống trong tầm |
| `danh 3 → 3,3` | `khong_co_dich` | tướng mình |
| `danh 3 → 4,3` | `khong_co_dich` | Bộ binh đứng sau tướng mình |
| `danh 3 → 1,6` | `khong_co_dich` | Bộ binh đứng sau Bộ binh `1,5` |

Mỗi kịch bản thử đúng điều `mo_ta` nói (đã kiểm khi tạo story; dev kiểm lại, ghi Debug Log):

- **#1:** `3,4` (ô 1) và `3,3` (ô 2) trống, `3,2` (ô 3) Bộ binh. Bộ binh kéo về `3,4`. Kéo 1 ô thì Bộ binh ở `3,3`: trượt. Kéo mà gây sát thương thì còn 2 máu: trượt. Đẩy thay vì kéo thì Bộ binh sang `3,1`: trượt.
- **#2:** Dư `1,3`, ô 1 `2,3` trống, ô 2 `3,3` Bộ binh. Kéo đủ 2 ô: va Dư, cả hai mất máu: trượt (theo câu 1 (a)). Nếu câu 1 chọn (b), file này **đổi** thành `Bộ binh cách 2 ô: bị kéo 1 ô rồi va Dư, cả hai mất 1 máu` với `mau 3,3...` (dev sửa trước khi nhờ duyệt, ghi Debug Log).
- **#3:** Dư `1,3`, `2,3` (ô 1) trống, `3,3` (ô 2) sông, Kỵ binh ở `4,3` (ô 3). Kéo bước đầu `4,3 → 3,3` là sông: chết đuối ngay, không kéo tiếp. Sông chặn thì Kỵ binh còn trên bàn: trượt.
- **#4:** `3,4` kề Dư. Kề mà kéo thì `ATTACKED`, Dư xám: trượt (kịch bản chỉ ghi `ngoai_tam`).
- **#5:** `3,4` (ô 1) trống, `3,3` Khoái (ô 2, vật đầu tiên), `3,2` Bộ binh (ô 3). Bỏ qua tướng mình như Lão thì lệnh đầu không bị từ chối: trượt. Lệnh thứ hai: hướng Đông `4,5`, `5,5` trống, Bộ binh `6,5` ở ô 3, bị kéo về `4,5`. Kịch bản có lệnh thứ hai để **trượt ngay từ đầu** (nếu chỉ có lệnh bị từ chối đúng mã thì kịch bản đạt luôn, trái M3).
- **#6:** thử tay bằng `Rules.resolve` trên đúng bàn này: hướng Bắc rỗng, Tây (`0,3` kề) rỗng, Đông (`2,3` trống, `3,3` Lão là vật đầu tiên) rỗng, Nam chỉ có `1,5` có viền. Nếu `targets` ra khác thì dựng bàn sai.
- **#7:** `3,4`, `3,3` trống; Cung kỵ 1 máu ở `3,2` (ô 3). Bộ binh `0,0` không thẳng hàng với Dư để trận chưa thắng khi Story 2.5 thêm luật thắng/thua. Sát thương sai thì Cung kỵ gục: trượt.

**Lý do chưa đạt** (sau Task 1.1, trước khi có code luật). Hiện Dư bị từ chối mọi lệnh đánh với `NO_TARGET` ("khong_co_dich") lý do "quân 3 chưa có đòn (Story 2.4)", nên:

| File | Lý do |
|---|---|
| #1, #2, #3, #7 | `bước 1: luật từ chối ("khong_co_dich": quân 3 chưa có đòn (Story 2.4)) mà kịch bản không ghi "tu_choi"` |
| #4 | `bước 1: luật từ chối vì "khong_co_dich" (quân 3 chưa có đòn (Story 2.4)), kịch bản ghi "tu_choi": "ngoai_tam"` |
| #5 | lệnh 1 đúng mã (`khong_co_dich`); `bước 2: luật từ chối ("khong_co_dich": quân 3 chưa có đòn (Story 2.4)) mà kịch bản không ghi "tu_choi"` |
| #6 | `bước 1: luật từ chối vì "khong_co_dich" (quân 3 chưa có đòn (Story 2.4)), kịch bản ghi "tu_choi": "ngoai_tam"` |

Câu chính xác lấy từ `ScenarioRunner._check_reject` (`tests/scenario_runner.gd:115`) với tiền tố bước của bộ chạy; dev kiểm lại và sửa bảng nếu câu thật khác. Ví dụ một lệnh: `{"lenh": "danh", "tuong": "3", "o": "3,4", "tu_choi": "ngoai_tam"}`. Không viết thêm kịch bản ngoài 7 cái này.

### Trận thử `thu_keo` (theo câu 3 (a))

`game/data/tran/thu_keo.json`, `"ten": "Thử kéo"`, `"kieu": "tieu_diet"`. Bàn (hàng 0 ở trên):

```
dia_hinh                 quan
. . . . . . .            . . . B . . .
. . . . . . .            . . . . . . .
. . . . . . .            . . . . . . .
. . . . ~ ~ .            . B B 3 . . K
. . . . . . .            . . . 1 . . .
. . . . . . .            . . . . . . .
. . . . . . .            . . . B . . .
```

- `thu_tu_dich`: `["3,0", "1,3", "2,3", "6,3", "3,6"]`. `tiep_vien: []`, `muu_ke_mo: []`, `long_dan: 3` nếu trận thử khác có (như `thu_lao.json`; dev chép đúng khóa bắt buộc từ `thu_lao.json`).
- Từ Dư `3,3`: Bắc `3,2`, `3,1` trống, `3,0` Bộ binh ô 3 → viền; Đông `4,3`, `5,3` sông, `6,3` Kỵ binh ô 3 → viền (bị kéo là rơi sông `5,3`); Nam `3,4` Khoái (vật đầu tiên là tướng mình) → không viền, Bộ binh `3,6` đứng sau không bấm được; Tây `2,3` Bộ binh kề → không viền, `1,3` sau nó không bấm được.
- Dư đi 1 ô rồi thử lại được: ví dụ Dư sang `3,2`: Bộ binh `3,0` cách 2 ô (thử luật "cách 2 ô").
- Test giao diện ở Task 4.2 dùng bố cục gần giống (bỏ sông) trong `user://`: không đọc file này, để tác giả sửa trận thử thoải mái.

### Hướng dẫn tác giả tự test (mẫu, dev ghi lại bằng kết quả thật ở Completion Notes)

1. `tools/test.sh`: thấy `Kịch bản luật: 44 đã duyệt · 0 chưa duyệt (0 chưa đạt)` và `✅ … test đạt`.
2. `tools/chay.sh --dev --tran=thu_keo`. (Tắt bộ gõ VNI/Telex trước khi gõ phím.)
3. Gõ `3` chọn Dư: 2 viền trắng: Bộ binh xa phía trên, Kỵ binh bên kia sông. Quân kề bên trái, Khoái phía dưới và Bộ binh sau Khoái **không** có viền.
4. Bấm Bộ binh phía trên: nó nhảy về sát Dư, vẫn đủ máu. Dư xám.
5. `Space`, gõ `3`, bấm Kỵ binh bên kia sông: Kỵ binh rơi xuống sông và biến mất.
6. `Space`, gõ `3`: chỉ còn viền nếu có quân thẳng hàng; thử bấm quân kề: không có gì xảy ra.
7. Nhắc: trên Mac F1 là Fn+F1.

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/rules_attack.gd`: `targets` (có nhánh `NGUYEN_KHOAI`, `PHAM_NGU_LAO`, còn lại rỗng); `resolve` (kiểm `NO_UNIT, NOT_GENERAL, ALREADY_ATTACKED`, rồi `match` Khoái, Lão, `_` = "chưa có đòn (Story 2.4)"); `khoai_strike`; `lao_throw`. Giữ nguyên hành vi Khoái, Lão.
- `src/core/forced_move.gd`: `run(state, unit, dir, distance, cause, events)` đi từng ô; `OBSTACLES` (rừng, kho, làng) va thì −1; quân khác va thì cả hai −1; sông + tướng → va. **Không sửa.** Chỉ truyền nguyên nhân `PULL`.
- `src/core/effects.gd`: `move` chết đuối quân Nguyên ở ô sông (có ghi chú hầm chông ở 3.4). Không sửa.
- `src/core/grid.gd`: `straight_dir`, `distance`, `DIRECTIONS`. Không sửa.
- `src/core/stats.gd`: `value`, `max_hp`, `move_range`, `damage`, `push_distance`, `min_range`, `max_range`. Thêm `pull_range`, `pull_distance`. `chi_so.json`: `tran_khanh_du` đã có `mau 3`, `tam_di 3`, `tam_danh 3`, `tam_keo 2`. **Không sửa `chi_so.json`.**
- `src/core/battle_event.gd`: `Cause { WALK, STRIKE, PUSH, COLLISION }` (thêm `PULL` **cuối**); `Reject` đã có `NOT_IN_RANGE`.
- `src/data/stats_loader.gd`: đã bắt buộc `tam_danh`, `tam_keo` cho Dư. Không sửa.
- `src/battle/battle_controller.gd`, `src/battle/battle_view.gd`: chạy chung `attack_targets`; đọc để chắc không có nhánh nào còn viết cứng "chỉ Khoái, Lão". Không sửa nếu không cần.
- `src/data/scenario_loader.gd` (`REJECT_CODES`, `COMMAND_REJECTS`) đã có `ngoai_tam`, `khong_co_dich`: không sửa.
- Test có câu "Dư chưa có đòn": `test_rules_attack.gd:54` (ca `[3, Vector2i(4, 3), "NO_TARGET"]`), `test_rules_attack.gd:101` (xem Task 3.2).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Input`, `FileAccess`, `Log`, `print`, `randi`, `Time`. `check_boundaries.sh` kiểm.
- Một điểm vào: `Rules.resolve(state, command)`. Đòn Dư ở `rules_attack.gd`, không tạo file luật mới.
- Chỉ `Effects.damage` / `Effects.move` đổi máu và vị trí; đẩy, kéo đi qua `ForcedMove.run`, từng ô một. **Không tự dời `unit.cell`** trong `du_pull`.
- Mọi hàm luật nhận `events` rồi `append`.
- Duyệt hướng theo `Grid.DIRECTIONS` (B→Đ→N→T), không theo khóa Dictionary. Không `float`.
- Con số (tầm 3, kéo 2) chỉ đọc từ `chi_so.json` qua `Stats`. Hằng "ô kề không kéo" (nếu câu 2 (a) cần số 2 làm ô gần nhất) là luật cố định của GDD, như `ForcedMove.COLLISION_DAMAGE`: đặt thành hằng có tên và chú thích nguồn (GDD dòng 206, chốt <ngày>).
- UI không sửa `BattleState`; gửi `Command` qua `submit()`, đọc bản chụp.
- Lý do từ chối là chữ cho dev, không qua `tr()`. Chữ của công cụ duyệt qua `tr()`.

### Testing

- `tools/test.sh` là lệnh duy nhất. Viết test trước, cho thấy đỏ, rồi mới code (ghi Debug Log).
- Lõi luật test thẳng (`BoardFixture` + `Rules.resolve`), mỗi ca so **dãy sự kiện** và `validate()` rỗng, không chỉ bàn sau (review 2.2).
- Giao diện test qua `main.tscn` thật (`_make_level_main`), phím bằng `InputEventKey` có `physical_keycode`, chuột bằng sự kiện thật (`_click_by_mouse`). Trận thử viết vào `user://` rồi xóa ở `after_each`.
- Điều kiện trước phải kiểm **bằng đẳng thức**, không `has()` (review 2.2). Kiểm cả `_view()` lẫn `_board()`; kiểm "không có lệnh nào được gửi" bằng `can_undo()` khi cần.
- Phá thử **mỗi lần một chỗ**.
- Review 2.3 (bài học trực tiếp cho story này): test phải phủ điều kiện trước của AC (máu ban đầu, ô có trong `target_cells()`); test sau lệnh đi cũng gọi `validate()`; trận chép tay trong test giao diện không được lệch `thu_keo.json` (cùng sông, cùng quân); ca "dừng ở mép bàn" của `targets` phải có; test file trận thật kiểm đủ `tam_danh`, `tam_keo` của Dư.

### Previous Story Intelligence (Story 2.1, 2.2, 2.3 và code review)

- **Ghi chép phải khớp:** số test ở Debug Log, Completion Notes, Change Log giống nhau; mọi chỗ làm khác Tasks ghi vào "Lệch so với Tasks"; task chụp ảnh thì phải có file ảnh, không thì bỏ [x] (review 2.3 bắt lại lần nữa).
- **File List đủ:** `game/i18n/text.vi.translation` phải có nếu `text.csv` đổi (review 2.3 sót).
- **`ForcedMove.run` đã chạy chung đẩy**, nay thêm kéo: truyền `Cause.PULL`, không nhân bản vòng đi từng ô.
- **Test trận thử phải so chỗ đứng từng quân** (review 2.2): đếm số quân thì dời quân vẫn xanh.
- **`Grid.straight_dir` có sẵn** (Story 2.3): dùng, không viết lại. `Grid.dir_between` assert hai ô kề: **không dùng cho kéo** (mục tiêu cách 2–3 ô).
- **Tướng mình không phải mục tiêu** (review 2.1–2.2): viền của Dư không bao giờ ở tướng mình.
- **Phím thật:** `InputEventKey` với `physical_keycode`. GoPeak `inject_key` không kích hoạt action: dùng `inject_action`.
- **GUT:** không đặt tên hàm phụ trùng hàm có sẵn của Node, GUT bỏ qua cả file.
- **Mục hoãn liên quan** (`deferred-work.md`): bộ nạp kịch bản kiểm mã `tu_choi` theo lệnh, không theo tướng (Khoái + `ngoai_tam`, Lão + `khong_ke` vẫn nạp được): xem lại khi Dư có đòn nếu tác giả muốn báo sớm; **Dư không thêm mã mới nên chưa cần**. Bộ chạy kịch bản bỏ qua tướng đã gục khi so `da_danh`: không có kịch bản tướng gục ở đợt này.

### Git Intelligence

- Commit gần nhất: `baba5d3 Sửa theo code review Story 1.9; xong Story 1.9`, `cee5a31 Cỡ bàn theo file trận (Story 1.9)`, `1195efb Sửa theo code review Story 2.3; xong Story 2.3`, `aeae68d Phạm Ngũ Lão phóng lao (Story 2.3)`. Mẫu commit: tiếng Việt, kết bằng `(Story X.Y)`, có dòng `Co-Authored-By`.
- Mẫu 2 commit cho story luật: một commit "kịch bản … chờ duyệt", một commit code khi xanh.
- Tổng test hiện tại: 427/427; kịch bản 37 đã duyệt.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh (`untyped_declaration` là error). Cú pháp Godot 4.
- Quy trình M3: AI viết kịch bản `da_duyet: false` → tác giả duyệt → test trượt → code. **Cấm** sửa hoặc xóa kịch bản đã duyệt. Nghi kịch bản sai thì hỏi tác giả.
- Luật không có trong GDD hay bảng thứ tự phân giải thì hỏi tác giả, không tự đoán (câu 1–3 dưới đây).
- Không chọn được tướng mình làm mục tiêu; đòn trúng mọi phe như hệ quả.
- Đẩy/kéo đi từng ô qua `ForcedMove.run`. Chỉ `Effects.damage` / `Effects.move` đổi máu và vị trí.
- Con số cân bằng chỉ trong `data/chi_so.json`.
- Không `assert` cho lỗi dữ liệu; `assert` chỉ cho lỗi lập trình.
- Không lặp cứng cỡ bàn (`range(7)`); dùng `level.size`. Mỗi trận có cỡ riêng (1.9).
- Bật dev bằng `--dev`; `--tran=` chỉ có tác dụng khi bật dev.
- Commit khi xanh, lời commit tiếng Việt. Không `push --force`.

### Quyết định của tác giả (chờ chốt)

_Ba câu dưới đây là chỗ GDD và epics chưa nói rõ. Mặc định (a) đã được dùng để viết kịch bản và AC. Tác giả đổi thì sửa theo trước Task 1 (Task 0)._

1. **Mục tiêu cách Dư 2 ô** (chỉ còn 1 ô trống giữa Dư và mục tiêu). GDD: "kéo 2 ô (dừng sớm nếu bị chặn)"; "kéo mục tiêu đã đứng kề thì không có hiệu ứng". Chưa nói ca cách 2 ô: kéo ô thứ hai sẽ đi vào chính ô Dư đứng.
   - (a) **MẶC ĐỊNH:** Quân bị kéo **dừng sát Dư** (1 ô), không ai mất máu. Nhất quán với ca "kề thì không có hiệu ứng": Dư không bao giờ tự làm mình mất máu khi kéo.
   - (b) Quân bị kéo 1 ô rồi **va vào Dư**: theo luật va chạm, cả quân Nguyên và Dư đều mất 1 máu (Dư tự chịu giá khi kéo gần).
2. **Quân Nguyên đã đứng kề Dư thì có viền và bấm được không.** Epics: "mục tiêu đã đứng kề thì không có gì xảy ra, không ai mất máu".
   - (a) **MẶC ĐỊNH:** Kề thì **không có viền**, bấm vào bị từ chối `ngoai_tam`, Dư **không** bị tính là đã đánh (như ô kề của Lão: bay qua, không viền). Quân kề cũng chặn hướng đó (vật đầu tiên là quân Nguyên kề thì các quân sau không kéo được).
   - (b) Kề có viền, bấm được: lệnh hợp lệ nhưng không đổi gì, Dư **bị tính là đã đánh** (mờ xám) mà không ai bị gì. Dễ làm người chơi tốn lượt nhầm.
3. **Thử trong game.** Epics ghi "thử bằng `thu_ba_tuong`". Ở đó Dư ở `4,6`; **không** có quân Nguyên thẳng hàng trong tầm 3 nếu chưa đi, và cần đi nhiều bước mới kéo thử được; không có ca "tướng mình đứng chắn" hay "quân kề".
   - (a) **MẶC ĐỊNH:** Thêm trận thử `thu_keo` (chỉ mở khi `--dev`, bố cục ở Dev Notes), như `thu_lao` ở Story 2.3. Không sửa `thu_ba_tuong.json`.
   - (b) Chỉ thử trong `thu_ba_tuong` (Dư đi sang `5,6` thì Bộ binh `5,4` cách 2 ô: thử được ca cách 2 ô và qua sông cần thêm chỉnh tay); các ca còn lại xem qua kịch bản.

### Quyết định mặc định đã chọn (tác giả có thể đổi)

- Nguyên nhân sự kiện mới `Cause.PULL` (thêm cuối enum) cho mọi `MOVED` của đòn kéo, để hoạt ảnh 2.11 và xem trước 2.12 phân biệt kéo với đẩy.
- `ATTACKED` của kéo ghi **ô mục tiêu trước khi kéo**.
- Không thêm mã từ chối mới: `ngoai_tam` (ô kề, chéo, quá tầm, ngoài bàn) và `khong_co_dich` (ô không có viền).
- Chữ công cụ duyệt cho `ngoai_tam` đổi thành `ô đó không thẳng hàng hoặc ngoài tầm đánh` (đúng cả lao và kéo).
- Trước Story 3.1, rừng, kho lương, làng giữa đường kéo **không** chặn chọn mục tiêu; kéo thật thì `ForcedMove` làm quân va vào và mất 1 máu. Ca này chỉ có test GUT, không có kịch bản đã duyệt, vì 3.1 sẽ đổi luật.
- Hầm chông trừ máu khi bị kéo ngang qua: chờ Story 3.4 (chưa có hầm chông trong `Effects.move`).

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.4 (dòng 669–693), FR14, FR15, FR16, FR17, FR28; Story 3.1 (dòng 922–945, phần kéo bị rừng chặn); Story 3.11 (kéo vào ô ải); Story 3.13 (kéo 0 sát thương không cộng Sát Thát).
- `_bmad-output/planning-artifacts/game-architecture.md` "Đòn của tướng" (dòng 819–827), M2 (bảng thứ tự phân giải), mã `tu_choi`, cây thư mục.
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` dòng 160 (Trần Khánh Dư), 169 (tầm kéo, kiểm tra playtest E4), 206 (kéo mục tiêu kề), 231, 233, 237 (sông, hầm chông, luật va chạm); `decision-log.md` (2026-10-16 tầm kéo 2 ô, kéo mục tiêu kề; 2026-10-18 làng chặn kéo).
- `_bmad-output/project-context.md` (luật bắt buộc, test, đẩy/kéo đi từng ô).
- `_bmad-output/implementation-artifacts/2-3-pham-ngu-lao-phong-lao.md` (mẫu story, review findings), `2-1-nguyen-khoai-danh-day-va-va-cham.md`, `2-2-song-va-danh-trung-quan-minh.md`, `deferred-work.md`.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

### File List

### Change Log

- 2026-10-20: Tạo story. Ba câu hỏi chờ tác giả chốt (cách 2 ô, quân kề, trận thử), mặc định (a) đã ghi.
