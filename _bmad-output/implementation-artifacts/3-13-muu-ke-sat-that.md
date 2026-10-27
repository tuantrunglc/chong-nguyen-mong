---
baseline_commit: 2545333
---

# Story 3.13: Mưu kế Sát Thát

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn tăng sức đánh của cả ba tướng trong một lượt,
để kết liễu nhiều địch cùng lúc.

## Acceptance Criteria

1. **Cho** trận có Sát Thát (`"muu_ke_mo": [..., "sat_that"]`), đang ở lượt người chơi
   **Khi** bấm nút Sát Thát (hoặc phím `W`)
   **Thì** từ lúc đó đến hết **lượt người chơi này**, đòn có sát thương của tướng được cộng thêm (`chi_so.json`: `muu_ke.sat_that.cong_sat_thuong`, mặc định 1) (FR32).
   - Nguyễn Khoái: sát thương 2 → 3. Mục tiêu gục vì sát thương thì không đẩy (luật cũ, kiến trúc M2).
   - Phạm Ngũ Lão: sát thương 1 → 2.
   - Đòn đánh **trước** khi dùng Sát Thát trong cùng lượt không được tính lại.
2. **Khi** quân bị đẩy hoặc kéo va chạm (vào quân khác, rừng, kho lương, làng, mép bàn), đi qua hầm chông, hoặc tướng bị đẩy vào sông
   **Thì** sát thương đó **không** được cộng (vẫn `ForcedMove.COLLISION_DAMAGE` = 1, hầm chông = 1).
   - Sát thương của Vườn không nhà trống cũng không được cộng (không phải đòn của tướng).
   - Đòn của quân Nguyên không bị ảnh hưởng.
3. **Khi** Trần Khánh Dư kéo **thì** vẫn 0 sát thương (đòn không có sát thương thì không cộng).
4. **Và** xem trước kết quả đòn (Story 2.12) hiện đúng số máu sau đòn đã cộng; khi chưa dùng thì vẫn như cũ.
5. **Và** sang hiệp sau thì hết hiệu lực: kết thúc lượt rồi, hiệp sau đòn tướng trở về sát thương thường.
6. **Và** luật chung mưu kế của Story 3.12 áp dụng y nguyên cho Sát Thát (FR34, FR10, FR39):
   - 1 lần mỗi trận; dùng rồi thì nút mờ, phím `W` im lặng, lệnh dùng lại bị từ chối `muu_ke_da_dung`.
   - Không tốn hành động của tướng.
   - Xóa sạch lịch sử hủy (bấm `Z` ngay sau đó không có tác dụng).
   - Trận không mở Sát Thát thì không hiện nút, `W` im lặng, lệnh bị từ chối `muu_ke_khoa`.
   - Chơi lại hiệp trả lại Sát Thát dùng **trong lượt đó**, và bàn về trạng thái chưa có hiệu lực.
7. **Và** nút xếp theo thứ tự phím: Vườn không nhà trống (Q) trên, Sát Thát (W) dưới, bất kể thứ tự trong `muu_ke_mo` (tác giả chốt 2026-10-27, `Stratagem.SLOTS`).
8. **Và** quy trình M3: kịch bản trong `game/tests/kich_ban/muu_ke/` (`da_duyet: false`) được tác giả duyệt **trước** khi viết code luật; chạy test thấy trượt; viết code tới khi `tools/test.sh` xanh; commit tiếng Việt kết `(Story 3.13)`.

## Tasks / Subtasks

- [ ] **Task 1: Tên mưu kế và dữ liệu (chưa có luật)** (AC: 1, 6, 7)
  - [ ] 1.1 `src/core/stratagem.gd`: `enum Kind { VUON_KHONG_NHA_TRONG, SAT_THAT }`; `NAMES["sat_that"] = Kind.SAT_THAT`; `SLOTS` thêm `[Kind.SAT_THAT, "stratagem_2", KEY_W]` (comment ở đầu `SLOTS` đã ghi sẵn dòng này). **Thêm cuối enum**, không chèn giữa: `Kind` là số nguyên, đổi thứ tự sẽ làm lệch mọi chỗ đã lưu số.
  - [ ] 1.2 Câu lỗi tên lạ lấy từ `Stratagem.name_list()`, nên sẽ thành `chỉ được "vuon_khong_nha_trong", "sat_that"`. Sửa đúng các câu mong đợi trong `test_loaders.gd:1085–1086` và `test_scenario_loader.gd:1347, 1351, 1372` (đây là test câu lỗi, không phải kịch bản đã duyệt).
  - [ ] 1.3 `data/chi_so.json`: `"muu_ke": { ..., "sat_that": { "cong_sat_thuong": 1 } }`. `StatsLoader.STRATAGEMS` thêm `["muu_ke", "sat_that", Stratagem.Kind.SAT_THAT, ["cong_sat_thuong"]]`; `MIN_VALUE["cong_sat_thuong"] = 1`. `Stats`: thêm `strike_bonus(kind) -> int` đọc `cong_sat_thuong` (cùng mẫu `stratagem_damage`, assert khi thiếu khóa). Test câu lỗi **đúng nguyên câu** trong `test_loaders.gd` (thiếu khóa, giá trị 0) — bài học review 3.12.
  - [ ] 1.4 `tests/board_fixture.gd:22` `stratagem_values()` thêm `Stratagem.Kind.SAT_THAT: {"cong_sat_thuong": 1}`.
  - [ ] 1.5 `i18n/text.csv`, đặt cạnh các khóa `hud.stratagem.*`/`stratagem.*` có sẵn (dòng 14–16): `hud.stratagem.sat_that` = "Sát Thát (W)", `stratagem.sat_that` = "Sát Thát", và `hud.stratagem.active` = "%s: đang +%d sát thương" (Quyết định 2). Chạy lại bước sinh `text.vi.translation` như Story 3.12.
  - [ ] 1.6 Trận thử: thêm `"sat_that"` vào `muu_ke_mo` của `data/tran/thu_muu_ke.json` (trận thử dev, không phải trận chiến dịch) để tác giả bấm tay cả Q và W. **Không sửa** `tran_0x.json` (Sát Thát mở ở trận 6 là việc của Story 4.2/4.5).

- [ ] **Task 2: Viết kịch bản chờ duyệt** (AC: 1–6, 8) — `game/tests/kich_ban/muu_ke/`, tiền tố `st_`, mọi file `"da_duyet": false`, bàn nhỏ (7×5) như `vknt_*`. Định dạng lệnh `{"lenh": "muu_ke", "ten": "sat_that"}` đã có từ 3.12, **không cần mở rộng bộ nạp kịch bản**. Đề xuất (một đợt):
  - [ ] `st_khoai_cong_mot_guc_khong_day.json`: Sát Thát, Khoái đánh Bộ binh 3 máu → gục (3 sát thương), không đẩy; `sau.muu_ke_da_dung: ["sat_that"]`.
  - [ ] `st_lao_cong_mot.json`: Sát Thát, Lão lao trúng Bộ binh 3 máu → còn 1.
  - [ ] `st_du_keo_qua_ham_chong_khong_cong.json`: Sát Thát, Dư kéo Bộ binh qua một ô `^` → chỉ mất 1 máu (hầm chông không cộng; kéo 0 sát thương).
  - [ ] `st_du_keo_va_cham_khong_cong.json`: Sát Thát, Dư kéo quân Nguyên bị quân khác chặn → mỗi bên mất 1, không phải 2.
  - [ ] `st_danh_truoc_khi_dung_khong_cong.json`: Khoái đánh Bộ binh (3 → 1, bị đẩy), **rồi** Sát Thát, rồi Lão lao trúng một Bộ binh khác (3 → 1). Đòn trước không tính lại.
  - [ ] `st_het_hieu_luc_hiep_sau.json`: Sát Thát, `ket_thuc_luot`, hiệp 2 Khoái đánh Bộ binh 3 máu → còn 1 (sát thương thường). Bàn phải dựng sao cho pha địch không làm lệch (quân Nguyên không có đường tới tướng thì đứng yên — xem `vknt_ky_binh_xung_phong_qua_kho_cu.json` và luật AI trong kiến trúc).
  - [ ] `st_ca_hai_muu_ke_vknt_khong_cong.json`: mở cả hai; Sát Thát rồi Vườn không nhà trống → quân Nguyên chỉ mất 1 máu (VKNT không được cộng).
  - [ ] `st_khong_ton_hanh_dong_xoa_huy.json`: Khoái đi, Sát Thát, `huy` → `tu_choi: "khong_con_nuoc_di"`, Khoái vẫn ở ô mới; rồi Khoái đánh với sát thương đã cộng.
  - [ ] `st_dung_lan_hai_bi_tu_choi.json`: dùng 2 lần → lần 2 `tu_choi: "muu_ke_da_dung"`; đòn sau đó chỉ cộng 1 (không cộng dồn).
  - [ ] `st_bi_khoa_tu_choi.json`: `muu_ke_mo: ["vuon_khong_nha_trong"]` → `sat_that` bị `tu_choi: "muu_ke_khoa"`, đòn sau đó không cộng.
  - [ ] `st_lao_trung_tuong_minh.json`: Sát Thát, Lão lao về quân Nguyên, tướng mình đứng chắn ở ô 2 → tướng mình mất 2 (Quyết định 1).
  - [ ] 2.1 Chạy `tools/test.sh`: bộ nạp đọc được mọi file; kịch bản mới **trượt** (chưa có luật) — liệt kê trong Debug Log. Commit kịch bản riêng, lời commit tiếng Việt kết `(Story 3.13)`.
  - [ ] 2.2 **Dừng, chờ tác giả duyệt** qua `tools/xem_kich_ban.sh muu_ke`. Tác giả bảo sai thì sửa kịch bản, không sửa code. Duyệt xong mới bật `da_duyet: true`.

- [ ] **Task 3: Luật (TDD Green)** (AC: 1–6)
  - [ ] 3.1 `BattleState`: trường `sat_that_active: bool = false`. **Chép trong `clone()`** (bài học 3.2/3.12). `from_level`: `false`. `validate()`: `sat_that_active` mà `stratagems_used` không có `SAT_THAT` → lỗi. Thêm hàm `sat_that_bonus() -> int`: `stats.strike_bonus(Stratagem.Kind.SAT_THAT)` khi `sat_that_active`, ngược lại 0 (đúng tên kiến trúc dòng 777).
  - [ ] 3.2 Bật cờ phải đi qua `Effects` hay đặt trong `RulesStratagem`? `RulesStratagem` đã tự `append` vào `state.stratagems_used` (3.12), nên đặt `state.sat_that_active = true` cùng chỗ là đúng mẫu. Kiểm `check_boundaries.sh` vẫn xanh.
  - [ ] 3.3 `RulesStratagem.resolve`: nhánh `Stratagem.Kind.SAT_THAT: state.sat_that_active = true`. Không phát thêm sự kiện nào ngoài `STRATAGEM_USED` (đã có), không đụng `has_moved`/`has_attacked`.
  - [ ] 3.4 `RulesAttack.khoai_strike` và `lao_throw`: sát thương = `state.stats.damage(type) + state.sat_that_bonus()` (thay hai chú thích "Sát Thát (+1) thêm ở Story 3.13"). **Chỉ hai chỗ này.** Không cộng trong `Effects.damage`, `ForcedMove` (va chạm, mép bàn, sông), hầm chông, `_scorched_earth`, `_strike_all` (đòn địch). `du_pull` không gọi `Effects.damage` nên tự giữ 0 (AC 3) — viết test khóa lại.
  - [ ] 3.5 Tắt cờ: `RulesEnemyPhase.end_player_turn`, **dòng đầu tiên** (trước `_strike_all`): `state.sat_that_active = false`. Đặt ở đầu (không phải chỗ tăng `round_number`) để cả khi trận hết giữa pha địch, cờ cũng không nằm lại. Đây là file duy nhất đổi phase, hợp chỗ.
  - [ ] 3.6 Chơi lại hiệp (AC 6): **không cần code mới** — `_turn_start` là `clone()` lúc cờ còn `false`. Test GUT: dùng Sát Thát → chơi lại → đòn không cộng, nút dùng lại được.
  - [ ] 3.7 Xem trước (AC 4): **không cần code mới** — `BattleController.preview_result` chạy `Rules.resolve` trên `clone()`, nên tự cộng khi cờ bật. Test GUT trên `preview_result`: trước Sát Thát Bộ binh 3 → 1, sau Sát Thát → gục (không còn trong `state.units`).
  - [ ] 3.8 F2 (`bug_report.gd`): không cần khóa mới. Mốc đầu báo cáo là bản chụp đầu lượt (cờ luôn `false`), lệnh `muu_ke` "sat_that" đã được ghi và phát lại nhờ 3.12. Test GUT: dùng Sát Thát, đánh, dựng báo cáo, nạp lại và chạy khớp (cùng mẫu `test_bug_report_replays_stratagem` trong `test_stratagem.gd`).
  - [ ] 3.9 Test GUT (`tests/test_stratagem.gd` hoặc file mới `test_sat_that.gd`): Khoái bị đẩy va chạm khi Sát Thát bật — dùng `BoardFixture.stats_with(...)` hạ sát thương Khoái xuống 1 để mục tiêu 3 máu sống sót và bị đẩy → mục tiêu mất 2 (1+1), va chạm vẫn 1 cho mỗi bên. (Với chỉ số thật, Khoái 3 sát thương luôn hạ gục mọi quân Nguyên nên không có kịch bản nào đẩy được.) Cùng file: `state.validate()` rỗng sau mỗi lệnh; `clone()` giữ `sat_that_active`.

- [ ] **Task 4: Nút, phím W, hiển thị** (AC: 1, 6, 7)
  - [ ] 4.1 Phím `W`: chỉ cần `SLOTS` (Task 1.1) — `BattleInput` đã khai báo InputMap và phát `stratagem_key_pressed` từ bảng. Kiểm `W` không trùng action nào khác trong `ACTION_KEYS`.
  - [ ] 4.2 `Hud.show_stratagems`: nút Sát Thát tự có nhờ `in_key_order`. Thêm trạng thái "đang hiệu lực" theo Quyết định 2 (truyền thêm `snapshot.sat_that_active` từ `BattleView._update_hud`, dòng 474).
  - [ ] 4.3 `EventPlayer`: `STRATAGEM_USED` đã hiện `Notice` "%s!" theo tên → "Sát Thát!" có sẵn. Không thêm hoạt ảnh trên bàn.
  - [ ] 4.4 Test GUT trong `test_stratagem_view.gd`: mở cả hai → nút Q trên nút W kể cả khi `muu_ke_mo` ghi `["sat_that", "vuon_khong_nha_trong"]`; phím `W` gửi lệnh; `W` khi bị khóa không gửi lệnh nào (kiểm `round_commands()` như bản sửa review 3.12); nút Sát Thát mờ sau khi dùng.

- [ ] **Task 5: Kiểm tra và bàn giao** (AC: 8)
  - [ ] 5.1 `tools/test.sh` xanh 4/4 bước; `test_determinism.gd` tự chạy kịch bản mới hai lần.
  - [ ] 5.2 Chụp màn hình qua GoPeak (`tools/chay.sh --dev --tran=thu_muu_ke`): hai nút đúng thứ tự, nút Sát Thát sau khi bấm. Phím bơm qua GoPeak không tới game (thiếu `physical_keycode`, ghi chú 3.12) → tác giả kiểm tay phím `W`.
  - [ ] 5.3 Hướng dẫn tác giả thử tay bằng tiếng Việt (các bước, thấy gì là đúng) trong Completion Notes.
  - [ ] 5.4 Cập nhật `sprint-status.yaml`, commit tiếng Việt kết `(Story 3.13)`.

## Dev Notes

### Luật (nguồn)

- **FR32** (epics.md:74): Sát Thát: trong lượt người chơi này, đòn có sát thương của tướng được +1. Sát thương do va chạm, hầm chông, mép bàn không được cộng.
- **FR34** (epics.md:76): 1 lần mỗi trận, bất cứ lúc nào trong lượt người chơi, không tốn hành động; nút hoặc phím `Q` `W`; Sát Thát mở từ trận 6 (việc mở theo chiến dịch là Story 4.2/4.5, story này chỉ đọc `muu_ke_mo`).
- **FR10**: đánh hoặc dùng mưu kế xóa sạch lịch sử hủy. **FR39**: chơi lại hiệp trả lại mưu kế dùng trong lượt.
- GDD (gdd.md:111): "mọi đòn đánh *có gây sát thương* của tướng được +1. Đòn kéo của Trần Khánh Dư không được cộng. Sát thương do va chạm, hầm chông, mép bàn cũng không được cộng."
- Kiến trúc, bảng phân giải "Mưu kế" (game-architecture.md:833): đòn **có sát thương > 0** của tướng được cộng 1, trong **lượt người chơi** (không phải hiệp). Mẫu code dòng 777: `state.stats.damage(khoai.type) + state.sat_that_bonus()`. Dòng 813: `ForcedMove.COLLISION_DAMAGE` cố định, Sát Thát không cộng.
- Thuật ngữ (project-context): *lượt người chơi* = chỉ pha `PLAYER`. Cờ phải tắt khi rời lượt người chơi, không đợi hết hiệp.

### Hiện trạng code (đọc trước khi sửa)

- `src/core/stratagem.gd`: `enum Kind { VUON_KHONG_NHA_TRONG }`, `NAMES`, `SLOTS` (bảng `[Kind, action, phím]`, BattleInput khai báo phím từ đây, HUD xếp nút theo đây — bản sửa review 3.12), `name_of`, `name_list`, `in_key_order`.
- `src/core/rules_stratagem.gd`: kiểm khóa → kiểm đã dùng → ghi `stratagems_used` + `STRATAGEM_USED` → `match kind` (nhánh `_` là `assert(false)`, thêm nhánh `SAT_THAT`).
- `src/core/rules_attack.gd`: chỉ hai chỗ gây sát thương của tướng: `khoai_strike` (dòng 147) và `lao_throw` (dòng 187), đều `state.stats.damage(type)`. `du_pull` không gây sát thương. Mọi sát thương khác đi qua `ForcedMove`/`Effects` với hằng số riêng.
- `src/core/rules_enemy_phase.gd:10` `end_player_turn`: `_strike_all` → `_end_of_round` → tăng hiệp, reset `has_moved`/`has_attacked` → `prepare`. Đây là nơi lượt người chơi kết thúc.
- `src/core/battle_state.gd`: `stratagems`/`stratagems_used` (dòng 44–45), `clone()` (dòng ~92), `validate()` (dòng ~166).
- `src/core/stats.gd`: `stratagem_damage(kind)` đọc `_stratagems[kind]["sat_thuong"]`. `src/data/stats_loader.gd:21` bảng `STRATAGEMS`, `MIN_VALUE`.
- `src/battle/battle_controller.gd`: `preview_result` (dòng 62) chạy luật trên `clone()`; `submit` đã xóa `_undo_snapshot` cho `USE_STRATAGEM`; `can_use_stratagem` dùng chung; `_turn_start` cho chơi lại.
- `src/ui/hud.gd:130` `show_stratagems(open_kinds, used)`; `src/battle/battle_view.gd:212` `_on_stratagem`, dòng 474 gọi `show_stratagems`.
- `src/battle/preview_view.gd`: bóng mờ hiện **máu sau đòn** lấy từ bản chụp xem trước — đúng số tự động khi luật đúng.
- `tests/board_fixture.gd:22` `stratagem_values()`; `data/tran/thu_muu_ke.json` (trận thử 7×7, 2 kho, B/K/C, 3 tướng).

### Điều phải giữ (không làm vỡ)

- 10 kịch bản `muu_ke/vknt_*` và mọi kịch bản `danh/`, `lao/`, `keo/`, `day/`, `va_cham/` vẫn xanh: không mở Sát Thát → cờ luôn `false` → sát thương y cũ.
- Câu lỗi tên mưu kế đổi theo `name_list()` — chỉ sửa test câu lỗi (Task 1.2), không sửa kịch bản đã duyệt nào.
- Báo cáo F2 cũ nạp lại được như trước (không thêm khóa bắt buộc).
- Hủy, chơi lại hiệp, xem trước, VKNT chạy như sau review 3.12.

### Luật kiến trúc phải theo

- Lõi luật `src/core/` chỉ `RefCounted`; điểm vào duy nhất `Rules.resolve`; luật mưu kế trong `rules_stratagem.gd`.
- Chỉ `Effects` đổi máu/vị trí/địa hình. Cờ mưu kế (`stratagems_used`, `sat_that_active`) do `RulesStratagem` ghi, cờ lượt do `RulesEnemyPhase` tắt.
- UI chỉ gửi `Command` qua `BattleController.submit`; phím khai báo trong InputMap (qua `Stratagem.SLOTS`).
- Con số cân bằng chỉ trong `data/chi_so.json`; chữ qua `tr()`; khóa JSON tiếng Việt không dấu.
- Kịch bản `da_duyet: true` không được sửa để test xanh. Nghi kịch bản sai thì hỏi tác giả.

### Quyết định của tác giả (chốt 2026-10-27)

1. **Lão lao trúng tướng mình** đứng chắn (luật 2026-10-19): **có +1**. GDD ghi "mọi đòn đánh có gây sát thương của tướng", không phân biệt trúng ai; cộng ở `lao_throw` cho mọi mục tiêu. Viết kịch bản `st_lao_trung_tuong_minh.json` (tướng mình mất 2).
2. **Trong lượt Sát Thát đang có hiệu lực**: nút mờ, chữ "Sát Thát: đang +1 sát thương" (khóa `hud.stratagem.active`, dạng "%s: đang +%d sát thương", số lấy từ `chi_so.json`); sang hiệp sau chữ đổi thành "Sát Thát: đã dùng" như VKNT.
3. **Dùng Sát Thát khi mọi tướng đã đánh**: **cho dùng** (FR34 "bất cứ lúc nào trong lượt người chơi"), không chặn, không cần kịch bản riêng.

### Kiểm thử

- Lõi: kịch bản luật (spec) + GUT (`test_stratagem.gd` hoặc `test_sat_that.gd`): cờ bật/tắt đúng lượt; `clone()`/`validate()`; Khoái bị đẩy va chạm với chỉ số hạ (Task 3.9); Dư 0 sát thương; đòn địch không cộng; chơi lại hiệp; xem trước; F2.
- Bộ nạp: `test_loaders.gd` (`muu_ke.sat_that.cong_sat_thuong`, `muu_ke_mo` có `sat_that`), câu lỗi đúng nguyên câu.
- UI: `test_stratagem_view.gd` (thứ tự nút, phím W, W khi khóa). Phần nhìn tác giả thử tay.
- `tools/test.sh` là lệnh duy nhất; xong việc chỉ khi xanh.

### Bài học từ story trước

- 3.12: bảng phím đã chuyển vào `Stratagem.SLOTS` theo review — Sát Thát chỉ thêm một dòng bảng, **không** viết lại chuỗi `"stratagem_2"` ở `BattleInput`.
- 3.12 review: test giao diện phải trượt được khi bỏ chốt `can_use_stratagem` (kiểm `round_commands()` rỗng, không chỉ kiểm trạng thái); test câu lỗi phải so **nguyên câu**; `match kind` có nhánh `_` assert.
- 3.12: lệnh mưu kế xóa bản chụp hủy ở `BattleController.submit` — đã có, Sát Thát dùng chung.
- 3.2/3.12: thiếu trường trong `clone()` làm hỏng hủy/xem trước/chơi lại âm thầm — `sat_that_active` phải vào `clone()`.
- 3.11/3.12: commit kịch bản **riêng, trước** code (M3).

### Project Structure Notes

- Mới: `game/tests/kich_ban/muu_ke/st_*.json`; có thể `game/tests/test_sat_that.gd` (hoặc gộp vào `test_stratagem.gd`).
- Sửa: `stratagem.gd`, `rules_stratagem.gd`, `rules_attack.gd`, `rules_enemy_phase.gd`, `battle_state.gd`, `stats.gd`, `stats_loader.gd`, `data/chi_so.json`, `data/tran/thu_muu_ke.json`, `hud.gd`, `battle_view.gd` (truyền cờ cho HUD), `i18n/text.csv`, `tests/board_fixture.gd`, `test_loaders.gd`, `test_scenario_loader.gd`, `test_stratagem_view.gd`.
- Không có file luật mới: Sát Thát nằm trong `rules_stratagem.gd` đúng cây thư mục kiến trúc (dòng 562).

### Project Context Rules

- Godot 4.7.2, chỉ GDScript, gõ kiểu tĩnh mọi nơi; JSON số là `float` → `int()` khi nạp.
- Không lặp cứng cỡ bàn; tất định (duyệt theo `id`/thứ tự, không theo khóa Dictionary).
- Log qua `Log.*`, không `print()`; lõi luật không log trong vòng phân giải.
- Sau mỗi lần phân giải trong test, `state.validate()` phải rỗng.
- MCP chỉ để nhìn và thử (`--dev`); luật và dữ liệu chỉ sửa trong code, có test.
- Nói với tác giả bằng tiếng Việt, bàn cờ chữ, các bước thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.13] (dòng 1186–1204)
- [Source: _bmad-output/planning-artifacts/epics.md] FR10, FR32, FR34, FR39 (dòng 36, 74, 76, 87)
- [Source: _bmad-output/planning-artifacts/game-architecture.md#M2] (dòng 760–780), #Bảng thứ tự phân giải (dòng 800–834)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md] dòng 111, 253, 259
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/decision-log.md] dòng 21, 53, 65
- [Source: _bmad-output/project-context.md]
- [Source: _bmad-output/implementation-artifacts/3-12-muu-ke-vuon-khong-nha-trong-va-nut-muu-ke.md] (luật chung mưu kế, review findings)

## Dev Agent Record

### Agent Model Used

### Debug Log References

- Nền trước story: HEAD `2545333` (Story 3.12 done).

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
