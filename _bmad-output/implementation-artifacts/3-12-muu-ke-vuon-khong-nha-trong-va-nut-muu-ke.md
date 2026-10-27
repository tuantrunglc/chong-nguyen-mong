---
baseline_commit: f1f443d
---

# Story 3.12: Mưu kế Vườn không nhà trống và nút mưu kế

Status: in-progress

## Story

Là người chơi,
tôi muốn tung mưu kế của Trần Hưng Đạo đúng lúc,
để lật thế trận.

## Acceptance Criteria

1. **Cho** trận có mưu kế Vườn không nhà trống (`"muu_ke_mo": ["vuon_khong_nha_trong"]`), đang ở lượt người chơi
   **Khi** bấm nút mưu kế (hoặc phím `Q`)
   **Thì** mọi ô kho lương `L` thành đất trống `.`, rồi mọi quân Nguyên trên bàn mất 1 máu theo thứ tự hành động (quân cũ theo `thu_tu_dich`, rồi quân tiếp viện theo thứ tự xuất hiện) (FR33).
   - Quân hết máu thì gục như mọi sát thương khác (Cung kỵ 1 máu gục ngay — GDD đã chốt giữ nguyên, [KIỂM TRA KHI PLAYTEST E4]).
   - Bàn không có kho lương thì vẫn trừ máu quân Nguyên.
2. **Và** từ đó đến hết trận, quân Nguyên không hồi máu (bước cuối hiệp không còn kho lương nào để hồi).
3. **Khi** đã dùng trong trận **thì** nút mờ đi, phím `Q` không có tác dụng; lệnh dùng lại bị luật từ chối (`muu_ke_da_dung`) (FR34).
4. **Và** dùng mưu kế **không tốn hành động của tướng**: cờ đã đi/đã đánh của mọi tướng giữ nguyên; tướng chưa đi vẫn đi và đánh được sau đó.
5. **Và** dùng mưu kế **xóa sạch lịch sử hủy**: bấm `Z` ngay sau đó không có tác dụng (FR10); có kịch bản cho ca này.
6. **Và** file trận quy định mưu kế nào được dùng (`muu_ke_mo`); mưu kế bị khóa thì **không hiện nút**, phím `Q` không có tác dụng, lệnh bị luật từ chối (`muu_ke_khoa`).
7. **Và** chơi lại hiệp (Story 3.2) trả lại mưu kế đã dùng **trong lượt đó** (FR39); mưu kế dùng ở hiệp trước thì không được trả lại.
8. **Và** dùng mưu kế làm gục quân Nguyên cuối cùng trong trận Tiêu diệt thì **thắng ngay** (luật chung "kiểm thắng/thua sau mỗi sự kiện gây gục"); trong trận Giữ ải thì không thắng sớm (Story 3.11).
9. **Và** quy trình M3: kịch bản trong `game/tests/kich_ban/muu_ke/` (`da_duyet: false`) được tác giả duyệt **trước** khi viết code luật; chạy test thấy trượt; viết code tới khi `tools/test.sh` xanh; commit tiếng Việt kết `(Story 3.12)`.

## Tasks / Subtasks

- [x] **Task 1: Mở rộng định dạng kịch bản (chưa có luật)** (AC: 9)
  - [x] 1.1 `ScenarioLoader`: lệnh mới `"muu_ke"` với khóa `"ten"` (bắt buộc) và `"tu_choi"`; `COMMAND_LIST`, `COMMAND_REJECTS["muu_ke"] = ["muu_ke_khoa", "muu_ke_da_dung", "tran_da_het"]`; mã từ chối mới `"muu_ke_khoa"`, `"muu_ke_da_dung"` trong `REJECT_CODES`/`REJECT_LIST` (+ khóa `scenario.viewer.reject_*` trong `i18n/text.csv`).
  - [x] 1.2 `ScenarioLoader`: `truoc.muu_ke_mo` (danh sách tên, không ghi = không mở mưu kế nào, giống file trận) và `truoc.muu_ke_da_dung` (danh sách tên, không bắt buộc); `sau.muu_ke_da_dung` (không bắt buộc, không ghi thì không kiểm). Tên lạ, trùng, hoặc "đã dùng" mà không có trong "mở" → câu lỗi tiếng Việt kèm file và giá trị.
  - [x] 1.3 *(Đổi cách: `test_scenario_loader.gd:775` đòi `PENDING_RULES` rỗng, nên nhánh `"muu_ke"` gửi `Command.use_stratagem` ngay; chưa có luật thì `Rules.resolve` không làm gì và kịch bản trượt ở bước so bàn.)* `ScenarioRunner`: chưa có luật thì để `"muu_ke"` trong `PENDING_RULES` (`"3.12"`) để kịch bản trượt rõ ràng; `REJECT_EVENTS` thêm 2 mã mới (ánh xạ `BattleEvent.Reject` mới — xem Task 4.2); `compare` kiểm `sau.muu_ke_da_dung` khi có ghi.
  - [x] 1.4 `tests/scenario_viewer.gd` (dòng ~376): in được lệnh `muu_ke` ("Dùng mưu kế Vườn không nhà trống").
  - [x] 1.5 Test bộ nạp trong `test_scenario_loader.gd` (lệnh mới, khóa mới, câu lỗi). Câu lỗi lệnh lạ ở `test_scenario_loader.gd:360` sẽ đổi theo `COMMAND_LIST`.

- [x] **Task 2: Viết kịch bản chờ duyệt** (AC: 1–6, 8, 9) — thư mục mới `game/tests/kich_ban/muu_ke/`, mọi file `"da_duyet": false`, `truoc.muu_ke_mo: ["vuon_khong_nha_trong"]` trừ ca bị khóa. Dùng bàn 7×5 hoặc nhỏ như các kịch bản `kho_luong/`. Đề xuất (tối đa ~8, một đợt):
  - [x] `vknt_dot_kho_tru_mau.json`: 2 kho lương, Bộ binh 3 máu, Kỵ binh 2 máu, Cung kỵ 1 máu → `L` thành `.`, Bộ binh 2, Kỵ binh 1, Cung kỵ gục; `sau.muu_ke_da_dung`.
  - [x] `vknt_khong_co_kho_van_tru_mau.json`: bàn không có `L` → quân Nguyên vẫn mất 1 máu.
  - [x] `vknt_het_hoi_mau.json`: Bộ binh 2 máu kề kho lương; dùng mưu kế rồi `ket_thuc_luot` → còn 1 máu (không hồi), `hiep: 2`. (So với `kho_luong/bo_binh_ke_kho_luong_hoi_mau.json`.)
  - [x] `vknt_khong_ton_hanh_dong.json`: Khoái chưa đi; dùng mưu kế, rồi Khoái đi và đánh được; `da_di`/`da_danh` đúng.
  - [x] `vknt_xoa_lich_su_huy.json`: Khoái đi, dùng mưu kế, `huy` → `tu_choi: "khong_con_nuoc_di"`, Khoái vẫn ở ô mới (ca AC bắt buộc).
  - [x] `vknt_dung_lan_hai_bi_tu_choi.json`: dùng 2 lần → lần 2 `tu_choi: "muu_ke_da_dung"`, máu chỉ trừ 1 lần.
  - [x] `vknt_bi_khoa_tu_choi.json`: không có `muu_ke_mo` → `tu_choi: "muu_ke_khoa"`, bàn không đổi.
  - [x] `vknt_diet_quan_cuoi_thang.json`: quân Nguyên cuối 1 máu (Tiêu diệt) → `ket_qua: "thang"`.
  - [x] (đã viết luôn trong đợt này) `vknt_ky_binh_xung_phong_qua_kho_cu.json`: Kỵ binh đã báo xung phong (`truoc.bao_don` hướng) bị kho lương chắn; đốt kho xong, kết thúc lượt → đòn đi tiếp trúng tướng phía sau. Đây là hệ quả của luật cũ (`TelegraphMarks.hit_cell` tính lúc ra đòn) — kịch bản chỉ khóa hành vi.
  - [x] 2.1 Chạy `tools/test.sh`: bộ nạp đọc được mọi file; kịch bản chưa duyệt chạy trượt vì `PENDING_RULES` — liệt kê trong Debug Log. Commit kịch bản riêng (như `1c04aa2` ở Story 3.11), lời commit tiếng Việt kết `(Story 3.12)`.
  - [x] 2.2 **Dừng, chờ tác giả duyệt** qua `tools/xem_kich_ban.sh muu_ke`. Tác giả bảo sai thì sửa kịch bản, không sửa code. Duyệt xong mới bật `da_duyet: true`.

- [x] **Task 3: Dữ liệu trận: `muu_ke_mo`** (AC: 6)
  - [x] 3.1 `src/core/stratagem.gd` (mới, `class_name Stratagem`, `RefCounted`): `enum Kind { VUON_KHONG_NHA_TRONG }` (Story 3.13 thêm `SAT_THAT`), bảng tên trong file ↔ `Kind` (`"vuon_khong_nha_trong"`), bảng phím (`VUON_KHONG_NHA_TRONG` ↔ action `stratagem_1` / `Q`). Đặt tên theo kiến trúc (`Stratagem.SAT_THAT`, dòng 683).
  - [x] 3.2 `LevelData.stratagems: Array[int]` (theo thứ tự trong file).
  - [x] 3.3 `LevelLoader`: đọc `muu_ke_mo` (không bắt buộc; thiếu = `[]`). Không phải danh sách, phần tử không phải chuỗi, tên lạ, tên trùng → lỗi tiếng Việt kiểu `tran_05.json: "muu_ke_mo" mục 1 là "sat_tat", chỉ được "vuon_khong_nha_trong"`. Xóa chú thích "biết tên nhưng chưa đọc (Story 3.12)" ở `level_loader.gd:15`. Test trong `test_loaders.gd`.
  - [x] 3.4 Mọi `data/tran/*.json` hiện có đều `"muu_ke_mo": []` → không đổi hành vi. **Không sửa** các trận đã có.
  - [x] 3.5 Thêm trận thử `data/tran/thu_muu_ke.json` (kho lương + vài quân Nguyên, trong đó một Cung kỵ, mở Vườn không nhà trống) để tác giả bấm tay: `tools/chay.sh --dev --tran=thu_muu_ke`.

- [x] **Task 4: Luật (TDD Green)** (AC: 1–5, 8)
  - [x] 4.1 `BattleState`: `stratagems: Array[int]` (mưu kế mở trong trận) và `stratagems_used: Array[int]`. **Thêm vào `clone()`** (bài học: thiếu trường trong `clone()` làm hỏng hủy/xem trước/chơi lại âm thầm). `from_level` chép từ `level.stratagems`. `validate()`: mỗi mưu kế đã dùng phải nằm trong mưu kế mở, không trùng.
  - [x] 4.2 `Command`: `Kind.USE_STRATAGEM`, trường mới `stratagem: int` gán trong `_init` (tham số mặc định), hàm `Command.use_stratagem(kind)`. `BattleEvent`: `Reject.STRATAGEM_LOCKED`, `Reject.STRATAGEM_USED`; `Type.STRATAGEM_USED` (amount = `Stratagem.Kind`), `Type.GRANARY_BURNED` (to_cell = ô kho); `Cause.STRATAGEM` cho `DAMAGED`. Hàm tạo sự kiện kiểu `BattleEvent.healed`.
  - [x] 4.3 `src/core/rules_stratagem.gd` (mới, `class_name RulesStratagem`, đúng tên trong cây thư mục kiến trúc dòng 562): `resolve(state, command, events)`:
    1. chưa mở → `REJECTED(STRATAGEM_LOCKED)`; đã dùng → `REJECTED(STRATAGEM_USED)`; không đổi gì.
    2. Ghi `stratagems_used`, phát `STRATAGEM_USED`.
    3. Duyệt ô theo thứ tự đọc bàn (hàng rồi cột): ô `GRANARY` → đổi thành `PLAIN`, phát `GRANARY_BURNED`. Đổi địa hình: thêm một hàm trong `Effects` (vd. `Effects.burn_granary`) — `check_boundaries.sh` chỉ miễn `effects.gd` cho phép gán trạng thái; kiểm xem script có bắt `terrain[...] =` không và làm theo.
    4. Lấy **bản sao** danh sách quân Nguyên, xếp theo `id` tăng dần (id = thứ tự hành động: 101… theo `thu_tu_dich`, tiếp viện nhận id sau — xem `BattleState.from_level`, `next_enemy_id`), rồi `Effects.damage(state, unit, state.stats.<sát thương VKNT từ chi_so.json>, Cause.STRATAGEM, events)` cho quân còn trên bàn. Duyệt bản sao vì `Effects.damage` nhấc quân gục khỏi `state.units`.
    - Không đụng `has_moved`/`has_attacked`. Không dùng `randi`, không duyệt theo khóa Dictionary (test tất định).
  - [x] 4.4 `Rules.resolve`: nhánh `Command.Kind.USE_STRATAGEM → RulesStratagem.resolve`. `RulesVictory.check` cuối `resolve` đã lo thắng khi có `DIED` (AC 8, Giữ ải không thắng sớm — có sẵn từ 3.11). Hết trận thì `telegraphs.clear()` có sẵn.
  - [x] 4.5 AC 2: sau khi đốt, không còn ô `L`, nên `_heal_from_granaries` (`rules_enemy_phase.gd:73`) tự không hồi ai. **Không** thêm cờ chặn hồi máu riêng trừ khi có nguồn hồi máu khác (hiện không có); ghi chú ở `_heal_from_granaries` rằng VKNT xóa hết kho.
  - [x] 4.6 (Đã làm ở Task 1.3.) Thêm nhánh `"muu_ke"` trong `ScenarioRunner._run_step` gửi `Command.use_stratagem(...)` qua `controller.submit`.
  - [x] 4.7 `BattleController.submit`: `USE_STRATAGEM → _undo_snapshot = null` (thay chú thích "E3: mưu kế cũng xóa" ở dòng ~127). `_record`/`_command_code`/`_describe` biết lệnh `"muu_ke"` (ghi kèm tên mưu kế). Thêm `can_use_stratagem(kind) -> bool` (đang lượt người chơi, trận chưa hết, đã mở, chưa dùng) cho HUD.
  - [x] 4.8 Chơi lại hiệp (AC 7): **không cần code mới** — `_turn_start` là bản `clone()` có `stratagems_used` của đầu lượt. Chỉ cần test GUT: (a) dùng mưu kế trong lượt → chơi lại → dùng lại được; (b) dùng ở hiệp 1 → sang hiệp 2 → chơi lại → vẫn đã dùng.
  - [x] 4.9 F2 *(test nằm trong `test_stratagem.gd`, không phải `test_bug_report.gd`)* (`src/debug/bug_report.gd`): `before_layers` ghi `muu_ke_mo` (khi khác rỗng) và `muu_ke_da_dung` (khi khác rỗng); `after_layers` ghi `muu_ke_da_dung`; `command_entries` ghi `{"lenh": "muu_ke", "ten": "..."}`; `REJECT_CODES` của bug_report thêm 2 mã. Test trong `test_bug_report.gd`: báo cáo có lệnh mưu kế nạp lại được và chạy khớp.

- [x] **Task 5: Nút mưu kế, phím Q, hoạt ảnh** (AC: 1, 3, 6)
  - [x] 5.1 `Hud`: mỗi mưu kế **mở** trong trận một nút (chữ qua `tr()`, ví dụ `hud.stratagem.vuon_khong_nha_trong` = "Vườn không nhà trống (Q)"), đặt giữa Chơi lại và Kết thúc lượt; signal `stratagem_pressed(kind)`. Mưu kế không mở → không tạo nút. Đã dùng → nút mờ, chữ đổi thành "Vườn không nhà trống: đã dùng" (khóa `hud.stratagem.used`). Nút theo `_apply_disabled` (mờ khi `_locked`, `_over`). `focus_mode = FOCUS_NONE` như nút khác.
  - [x] 5.2 `BattleInput`: action `stratagem_1` ↔ `KEY_Q` trong `ACTION_KEYS`, signal `stratagem_key_pressed(index)`. (Story 3.13 thêm `stratagem_2` ↔ `KEY_W`.) Khai báo InputMap bằng code như các phím khác, không bắt phím trực tiếp.
  - [x] 5.3 `BattleView`: nối signal; `_on_stratagem(kind)`: bỏ qua khi `_controller == null`, `_playing`, `_battle_over()`, hoặc `not _controller.can_use_stratagem(kind)` (phím Q khi bị khóa/đã dùng im lặng); gửi `Command.use_stratagem(kind)`; tướng đang chọn **giữ nguyên** (tác giả chốt, Quyết định 3; `_finish_playback` đã giữ chọn khi tướng chưa đánh). `_update_hud` truyền thông tin mưu kế (mở/đã dùng/dùng được) vào `Hud.show_turn` hoặc một hàm riêng `show_stratagems`.
  - [x] 5.4 `EventPlayer`: `GRANARY_BURNED` → nháy ô kho (như `_flash_village`) và thời lượng `DAMAGE_SECONDS`; `STRATAGEM_USED` → `Notice` "Vườn không nhà trống!" (khóa chung `notice.stratagem` = "%s!" + tên `stratagem.<tên>`); `DAMAGED` cause `STRATAGEM` dùng nháy có sẵn. Tổng hoạt ảnh vẫn ≤ 3 giây (`MAX_PHASE_SECONDS` lo). Kho lương biến mất khi `BoardView.show_state` vẽ bản chụp cuối (`_rebuild_terrain`) — đủ cho story này.
  - [x] 5.5 Mọi chữ mới vào `i18n/text.csv`; `test_i18n.gd` phải xanh.
  - [x] 5.6 Test GUT cho phần hiển thị có thể test không màn hình (như `test_battle_view.gd`, `test_main.gd`): nút có/không theo `muu_ke_mo`; nút mờ sau khi dùng; phím Q gửi lệnh; Q khi bị khóa không làm gì.

- [x] **Task 6: Kiểm tra và bàn giao** (AC: 9)
  - [x] 6.1 `tools/test.sh` xanh 4/4 bước; `test_determinism.gd` tự chạy kịch bản mới hai lần.
  - [x] 6.2 Chụp màn hình qua GoPeak (`tools/chay.sh --dev --tran=thu_muu_ke`) xem nút và bàn sau khi đốt kho.
  - [x] 6.3 Hướng dẫn tác giả thử tay bằng tiếng Việt (các bước, thấy gì là đúng) trong Completion Notes.
  - [x] 6.4 Cập nhật `sprint-status.yaml`, commit tiếng Việt kết `(Story 3.12)`.

### Review Findings

Đã sửa cả 11 mục Patch (2026-10-27). `tools/test.sh` 756/756 GUT, 162 kịch bản đã duyệt. Kiểm đột biến mục 2: bỏ chốt `can_use_stratagem` trong `BattleView._on_stratagem` thì 2 test `test_stratagem_view.gd` trượt. Mục 1: bảng `Stratagem.SLOTS` = `[Kind, action, phím]`, `BattleInput` khai báo phím từ bảng, `Hud.show_stratagems` xếp theo `Stratagem.in_key_order`.

- [x] [Review][Patch] Chuyển bảng `Kind ↔ action ↔ phím` vào `Stratagem` (Task 3.1), `BattleInput` đọc từ bảng, HUD xếp nút theo thứ tự phím (Q, W) chứ không theo `muu_ke_mo` — tác giả chốt 2026-10-27 [game/src/core/stratagem.gd]
- [x] [Review][Patch] Test giao diện vẫn qua dù bỏ chốt `can_use_stratagem` trong `_on_stratagem` (luật đã từ chối nên trạng thái không đổi); cần kiểm thêm là không có lệnh bị từ chối nào trong `round_commands()` [game/tests/test_stratagem_view.gd:63]
- [x] [Review][Patch] `validate()` báo lỗi "mưu kế bị ghi đã dùng hai lần" lặp theo số lần trùng, và chưa có test cho luật trùng này [game/src/core/battle_state.gd:168]
- [x] [Review][Patch] Gõ sai tên trong `truoc.muu_ke_mo` sinh thêm lỗi thứ hai gây hiểu nhầm ("muu_ke_mo không mở") cho `muu_ke_da_dung`; cần bỏ qua bước so chéo khi `muu_ke_mo` đã có lỗi [game/src/data/scenario_loader.gd:363]
- [x] [Review][Patch] Nhánh `STRATAGEM_USED` trong `_play_one` không bao giờ chạy (thời lượng 0 nên luôn đi qua `_apply_instant`); xóa nhánh thừa [game/src/battle/event_player.gd:154]
- [x] [Review][Patch] Test lỗi `muu_ke.vuon_khong_nha_trong.sat_thuong` < 1 chỉ kiểm có tên khóa, chưa kiểm đúng nguyên câu lỗi kèm giá trị như các test lỗi loader khác [game/tests/test_loaders.gd]
- [x] [Review][Patch] `match kind:` thiếu nhánh mặc định: một mưu kế mới có tên nhưng chưa có luật sẽ bị đánh dấu đã dùng mà không làm gì; thêm `assert` ở nhánh `_` [game/src/core/rules_stratagem.gd:19]
- [x] [Review][Patch] Chưa có test cho ca trận Tiêu diệt: mưu kế diệt hết quân trên bàn nhưng vẫn còn tiếp viện chưa ra thì chưa thắng (thêm test GUT, không thêm kịch bản mới chưa duyệt) [game/tests/test_stratagem.gd]
- [x] [Review][Patch] `BattleEvent.Reject.STRATAGEM_USED` trùng tên với `BattleEvent.Type.STRATAGEM_USED` mà nghĩa ngược nhau; đổi tên Reject thành `STRATAGEM_ALREADY_USED` [game/src/core/battle_event.gd:71]
- [x] [Review][Patch] `BattleController.stratagems()` không ai gọi (HUD đọc từ bản chụp); xóa [game/src/battle/battle_controller.gd:160]
- [x] [Review][Patch] Khóa `stratagem.vuon_khong_nha_trong` nằm lẫn trong khối `scenario.viewer.*`; chuyển cạnh các khóa `hud.stratagem.*`/`notice.stratagem` [game/i18n/text.csv:87]
- [x] [Review][Defer] `Stats.new(values)` cho bỏ trống tham số mưu kế (giá trị mặc định `{}`), nhiều test cũ vẫn tạo `Stats` một tham số; nếu test sau này dùng mưu kế thì assert ở debug, ở bản phát hành trừ 0 máu [game/src/core/stats.gd:12] — deferred, chỉ ảnh hưởng test; bộ nạp đã bắt buộc nhóm `muu_ke`
- [x] [Review][Defer] Báo lỗi F2 `before_layers` không ghi `kieu`, `tiep_vien`, `long_dan`, `so_hiep_toi_da`: kịch bản sinh ra từ trận Giữ ải hoặc trận còn tiếp viện sẽ chạy lại sai kết quả [game/src/debug/bug_report.gd:103] — deferred, pre-existing
- [x] [Review][Defer] Ô nháy khi đốt kho có thể nằm thấp hơn mặt khối kho lương khoảng 16px (dùng `cell_rect` mặt đất, giống nháy làng) [game/src/battle/event_player.gd:204] — deferred, chưa kiểm trên màn hình; tác giả xem khi thử tay

## Dev Notes

### Luật (nguồn)

- **FR33** (epics.md:75): Vườn không nhà trống: mọi kho lương thành đất trống; mọi quân Nguyên mất 1 máu theo thứ tự trong file trận; từ đó đến hết trận, quân Nguyên không hồi máu.
- **FR34** (epics.md:76): 1 lần mỗi trận, bất cứ lúc nào trong lượt người chơi, không tốn hành động của tướng; nút hoặc `Q` `W`; mở theo trận (VKNT từ trận 5 — việc mở theo chiến dịch là Story 4.2, story này chỉ đọc `muu_ke_mo` của file trận).
- **FR10**: đánh **hoặc dùng mưu kế** xóa sạch lịch sử hủy (chốt 2026-10-17).
- **FR39**: chơi lại hiệp trả lại mưu kế dùng trong lượt.
- Kiến trúc, bảng phân giải "Mưu kế" (game-architecture.md:832–834): **mọi ô `L` thành `.`, rồi** mọi quân Nguyên mất 1 máu theo `thu_tu_dich`. Thứ tự này phải giữ trong sự kiện (đốt trước, trừ máu sau).
- GDD (gdd.md:112–114): ô kho lương sau khi đốt **đi vào được**; VKNT hạ ngay mọi Cung kỵ — chốt giữ nguyên, kiểm khi playtest E4.

### Hiện trạng code (đọc trước khi sửa)

- `src/core/command.gd`: `enum Kind { MOVE, END_TURN, ATTACK, BEGIN_BATTLE }`, trường `kind`, `unit_id`, `cell` gán trong `_init` (check_boundaries bắt gán ngoài `_init`/Effects).
- `src/core/rules.gd`: `match command.kind` → `RulesMove`/`RulesAttack`/`RulesEnemyPhase`; sau đó `RulesVictory.check` nếu không bị từ chối; hết trận thì xóa `telegraphs`.
- `src/core/battle_state.gd`: chưa có cờ mưu kế. `clone()` chép tay từng trường. `validate()` đã có nhiều bất biến; thêm bất biến mưu kế ở đây.
- `src/core/effects.gd`: `damage`, `heal`, `damage_morale`, `move`. Chỉ file này được đổi máu/vị trí. Đốt kho là đổi `state.terrain` — đặt vào đây.
- `src/core/rules_enemy_phase.gd:73` `_heal_from_granaries`: chỉ hồi quân kề ô `GRANARY`; đốt hết kho thì không ai hồi.
- `src/battle/battle_controller.gd`: `submit` xóa `_undo_snapshot` theo `match command.kind` (dòng ~122–131); `_turn_start` là bản chụp đầu lượt dùng cho chơi lại; `_record` + `_command_code` cho F2.
- `src/ui/hud.gd`: nút dựng bằng code (`_button`), `show_turn(...)` nhận nhiều tham số, `_apply_disabled()` khóa nút theo `_over`/`_locked`.
- `src/battle/battle_input.gd`: `ACTION_KEYS` khai báo InputMap bằng code; `_unhandled_input` phát signal.
- `src/battle/battle_view.gd`: `_on_undo`/`_on_replay`/`_on_end_turn` (dòng 193–217) là mẫu cho `_on_stratagem`; `_update_hud` (dòng 459).
- `src/data/level_loader.gd:15–19`: `muu_ke_mo` nằm trong `KNOWN_KEYS` nhưng chưa đọc.
- `src/data/scenario_loader.gd:13–60`: `ROOT_KEYS`, `BEFORE_KEYS`, `AFTER_KEYS`, `COMMANDS`, `REJECT_CODES`, `COMMAND_REJECTS` — lệnh và mã mới thêm ở đây.
- `tests/scenario_runner.gd`: `PENDING_RULES`, `REJECT_EVENTS`, `_run_step`, `compare`.
- `src/debug/bug_report.gd:101–253`: `before_layers`, `after_layers`, `command_entries` — phải biết mưu kế, nếu không báo cáo F2 phát lại sai.
- `data/chi_so.json`: chỉ có chỉ số theo loại quân; `Stats` hỏi theo `UnitType`. Tham số mưu kế thêm vào đây (Quyết định 1): cần mở rộng `Stats`/`StatsLoader` cho mục `muu_ke`, kèm test câu lỗi trong `test_loaders.gd`.

### Điều phải giữ (không làm vỡ)

- Kịch bản `kho_luong/` (Story 3.9) vẫn xanh: không có `muu_ke_mo` → không đổi gì.
- Hủy nước đi: đi → hủy vẫn chạy; đánh xóa hủy như cũ.
- Chơi lại hiệp: test 3.2 (`test_battle_controller.gd`) vẫn xanh.
- F2: báo cáo cũ (không có mưu kế) nạp lại được như trước — khóa mới đều **không bắt buộc**.
- Trận Giữ ải: VKNT diệt hết quân Nguyên không thắng sớm (`diet_het_dich_chua_thang_som` của 3.11 đã khóa luật này).
- Xem trước đòn (Story 2.12) không chạy cho mưu kế ở story này.

### Luật kiến trúc phải theo

- Lõi luật `src/core/` chỉ `RefCounted`, không `Node`/`Input`/`print`/`randi`; `check_boundaries.sh` kiểm.
- Điểm vào duy nhất `Rules.resolve`; luật mưu kế nằm trong `rules_stratagem.gd`.
- Chỉ `Effects` đổi máu/vị trí/địa hình; UI chỉ gửi `Command` qua `BattleController.submit`.
- Phím tắt khai báo trong InputMap; mọi thao tác làm được bằng một cú bấm chuột.
- Chữ hiển thị qua `tr()`, khóa dạng `<man>.<muc>`; khóa JSON tiếng Việt không dấu; code tiếng Anh.
- Tất định: duyệt quân theo `id`/thứ tự, không theo khóa Dictionary.
- Kịch bản `da_duyet: true` không được sửa để test xanh. Nghi kịch bản sai thì hỏi tác giả.

### Quyết định của tác giả (chốt 2026-10-27)

1. **Số máu trừ của Vườn không nhà trống** để cố định là 1 trong code (như va chạm), hay đưa vào `chi_so.json` để tác giả tự chỉnh khi playtest? Kiến trúc (ADR 8) ghi "tham số mưu kế" nằm trong `chi_so.json`; epics 4.9 có mục kiểm độ mạnh VKNT. **Tác giả chốt: đưa vào `chi_so.json`** (khóa `muu_ke.vuon_khong_nha_trong.sat_thuong: 1`), `StatsLoader` kiểm số nguyên ≥ 1, có câu lỗi tiếng Việt.
2. **Bấm nút một lần là dùng ngay**, hay bấm hai lần như đánh ("Bấm lần nữa để dùng")? Mưu kế không hủy được bằng `Z`, chỉ cứu được bằng Chơi lại hiệp. **Tác giả chốt: bấm một lần là dùng** (FR34 "dùng bằng nút").
3. Sau khi dùng mưu kế, **tướng đang chọn giữ nguyên hay bỏ chọn**? **Tác giả chốt: giữ nguyên** nếu tướng còn trên bàn và chưa đánh (mưu kế không tốn hành động; `_finish_playback` đã có nhánh này).

### Kiểm thử

- Lõi: kịch bản luật (spec) + GUT `tests/test_stratagem.gd` (mới): thứ tự sự kiện (`STRATAGEM_USED` → các `GRANARY_BURNED` theo thứ tự đọc bàn → `DAMAGED`/`DIED` theo id), tiếp viện bị trừ sau quân cũ, `state.validate()` rỗng sau mỗi lệnh, `clone()` giữ cờ mưu kế, chơi lại hiệp (AC 7), từ chối không đổi bàn.
- Bộ nạp: `test_loaders.gd` (`muu_ke_mo`), `test_scenario_loader.gd` (lệnh/khóa mới), `test_bug_report.gd` (F2).
- UI: phần không cần màn hình trong `test_battle_view.gd`/`test_main.gd`; phần nhìn (nháy ô, thông báo) tác giả thử tay.
- `tools/test.sh` là lệnh duy nhất; xong việc chỉ khi xanh.

### Bài học từ story trước

- 3.11: commit kịch bản **riêng, trước** code (M3) — giữ cách này. Review bắt được nhánh `elif` chết trong `ScenarioLoader` và thiếu câu lỗi cho dữ liệu sai — viết test câu lỗi cho mọi nhánh mới.
- 3.10/3.9: sự kiện mới phải có thời lượng trong `EventPlayer._base_seconds` và nhánh trong `_play_one`, không thì hoạt ảnh im lặng.
- 3.2: chơi lại dựa vào `clone()`; quên chép trường mới vào `clone()` là lỗi âm thầm (đã ghi ở đầu `battle_state.gd`).
- 2.13: lệnh mới phải đi qua `_record` để F2 phát lại được.

### Project Structure Notes

- Mới: `game/src/core/stratagem.gd`, `game/src/core/rules_stratagem.gd`, `game/tests/test_stratagem.gd`, `game/tests/kich_ban/muu_ke/*.json`, `game/data/tran/thu_muu_ke.json`.
- Sửa: `command.gd`, `battle_event.gd`, `battle_state.gd`, `effects.gd`, `rules.gd`, `level_data.gd`, `level_loader.gd`, `scenario_loader.gd`, `scenario_runner.gd`, `scenario_viewer.gd`, `battle_controller.gd`, `bug_report.gd`, `hud.gd`, `battle_input.gd`, `battle_view.gd`, `event_player.gd`, `i18n/text.csv`; `stats.gd`, `stats_loader.gd`, `data/chi_so.json` (Quyết định 1).
- Kiến trúc dự kiến `hud.gd` chứa nút mưu kế (dòng 586) — khớp.

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh mọi nơi; JSON số là `float` → `int()` khi nạp.
- Không `Thread`; không object pool; không lặp cứng cỡ bàn (dùng `state.size`).
- Log qua `Log.*`, không `print()`; lõi luật không log trong vòng phân giải.
- MCP chỉ để nhìn và thử (`--dev`); luật và dữ liệu chỉ sửa trong code, có test.
- Nói với tác giả bằng tiếng Việt, bàn cờ chữ, các bước thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.12] (dòng 1166–1184)
- [Source: _bmad-output/planning-artifacts/epics.md] FR10, FR33, FR34, FR39 (dòng 36, 75–76, 87)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Quản lý trạng thái] (dòng 264–284)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#Bảng thứ tự phân giải — Mưu kế] (dòng 832–834)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md] dòng 103–114, 126, 194, 210–211, 234
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/3-11-nhiem-vu-giu-ai.md], [3-2-choi-lai-hiep.md], [3-9-kho-luong.md]

## Dev Agent Record

### Agent Model Used

### Debug Log References

- Nền trước story: `tools/test.sh` 727/727 GUT, 152 kịch bản đã duyệt, 1 chưa duyệt (`tran/tran_01_ne_o_do.json`) (HEAD `f1f443d`).
- 2026-10-27 (Task 1–2, commit `0697924`): định dạng kịch bản có lệnh `muu_ke`, khóa `muu_ke_mo`/`muu_ke_da_dung`; `LevelLoader` đọc `muu_ke_mo`; thêm `Stratagem`, `Command.USE_STRATAGEM`, `Reject.STRATAGEM_LOCKED/USED`, cờ mưu kế trong `BattleState` (+`clone`, `validate`). 733/733 GUT. 10 kịch bản `muu_ke/` (+1 kịch bản 3.12 cũ chưa duyệt): **10/10 trượt** vì chưa có luật (Red). Kiểm chéo bằng một bản luật tạm (không commit): cả 10 đạt, tức kịch bản khớp các luật cũ (AI đứng yên khi không có đường, Kỵ binh xung phong tính ô trúng lúc ra đòn). Lưu ý cho Task 4.3: `check_boundaries.sh` không bắt `state.terrain[i] = ...` ngoài `Effects` — vẫn đặt hàm đốt kho trong `Effects` theo luật kiến trúc.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- 2026-10-27: tác giả duyệt cả 10 kịch bản `muu_ke/` (commit `a61b1b9`). Red: 10 kịch bản đã duyệt trượt (`test_approved_scenarios_pass`). Green: `rules_stratagem.gd` + `Effects.burn_granary` (`12eb0a6`); UI (`2aacafd`). `tools/test.sh` 752/752 GUT, 162 kịch bản đã duyệt.
- Chụp màn hình GoPeak (`--dev --tran=thu_muu_ke`): nút "Vườn không nhà trống (Q)" hiện giữa Chơi lại và Kết thúc lượt; bấm nút → 2 kho biến mất, Bộ binh 3→2, Kỵ binh 2→1, Cung kỵ gục (ô đỏ của nó mất theo), nút mờ "Vườn không nhà trống: đã dùng". Phím `Q` bơm qua GoPeak **không** tới game (sự kiện bơm không có `physical_keycode`, InputMap khai báo theo phím vật lý); phím Q thật đã có test GUT `test_q_key_uses_stratagem` — **tác giả kiểm tay phím Q**.
- Lệch so với story: (1) không dùng `PENDING_RULES` (test 1.3 ở trên); (2) chữ nút đã dùng là khóa riêng `hud.stratagem.used`; (3) test F2 đặt trong `test_stratagem.gd`.

**Hướng dẫn tác giả thử tay** (`tools/chay.sh --dev --tran=thu_muu_ke`):
1. Mở trận: thấy 2 ô "Kho" ở hàng trên, Bộ binh (3 máu), Kỵ binh (2), Cung kỵ (1); bên phải có nút **Vườn không nhà trống (Q)**.
2. Bấm Khoái, đi một ô, rồi bấm phím **Q**: hiện dòng "Vườn không nhà trống!", 2 kho nháy màu lửa rồi biến mất, B còn 2, K còn 1, Cung kỵ gục. Nút mờ, ghi "đã dùng". Khoái vẫn đang được chọn.
3. Bấm **Z**: không có gì xảy ra (mưu kế đã xóa lịch sử hủy).
4. Bấm **Q** lần nữa: không có gì.
5. Bấm **Chơi lại (R)**: bàn về đầu lượt, kho lương trở lại, nút mưu kế sáng lại, dùng được lần nữa.
6. Mở trận 1 (`tools/chay.sh --dev --tran=1`): **không** có nút mưu kế; bấm Q không có gì.

### File List

- `game/data/chi_so.json` (nhóm `muu_ke`)
- `game/data/tran/thu_muu_ke.json` (mới)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `game/src/core/stratagem.gd` (mới), `game/src/core/rules_stratagem.gd` (mới)
- `game/src/core/battle_event.gd`, `battle_state.gd`, `command.gd`, `effects.gd`, `level_data.gd`, `rules.gd`, `rules_enemy_phase.gd`, `stats.gd`
- `game/src/data/board_layers.gd`, `level_loader.gd`, `scenario_data.gd`, `scenario_loader.gd`, `stats_loader.gd`
- `game/src/debug/bug_report.gd`
- `game/src/battle/battle_controller.gd`, `battle_input.gd`, `battle_view.gd`, `event_player.gd`
- `game/src/ui/hud.gd`
- `game/tests/kich_ban/muu_ke/*.json` (10 kịch bản, đã duyệt)
- `game/tests/board_fixture.gd`, `scenario_runner.gd`, `scenario_viewer.gd`, `test_loaders.gd`, `test_scenario_loader.gd`, `test_stratagem.gd` (mới), `test_stratagem_view.gd` (mới)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
