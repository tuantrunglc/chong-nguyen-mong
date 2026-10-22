---
baseline_commit: 6195636
---

# Story 2.8: Địch ra đòn theo thứ tự

Status: done

## Story

Là người chơi,
tôi muốn đòn địch đánh đúng như đã báo,
để tin vào những gì mình thấy trên bàn.

_Story thứ tám của E2. Story 2.6 cho quân Nguyên đi và báo đòn (`BattleState.telegraphs`, lưu tương đối M1); Story 2.7 tính và vẽ ô đỏ (`TelegraphMarks`). Story này cho các đòn đó **đánh thật** khi người chơi bấm Kết thúc lượt: lần lượt theo số thứ tự, trúng ô `TelegraphMarks.hit_cell` lúc ra đòn, chỉ trừ máu, không đẩy. Sau story này trận 1 có hai phía đánh nhau thật và có thể thua._

_**Chưa có** (đừng làm ở đây): sự kiện hủy đòn `TELEGRAPH_CANCELLED` và kịch bản dịch theo/hủy (2.9; ở đây đòn của chủ đã gục chỉ **bị bỏ qua**, không phát sự kiện riêng); hoạt ảnh (2.11, bàn nhảy thẳng tới kết quả); xem trước (2.12); Lòng dân khi đánh trúng làng (3.7); tiếp viện, kho lương hồi máu cuối hiệp (3.9–3.10); Cung kỵ (2.15)._

## Acceptance Criteria

1. **Đợt duyệt kịch bản trước khi viết code (M3).** **Cho** 9 kịch bản ở Dev Notes "Đợt kịch bản 10" (`da_duyet: false`, thư mục `tests/kich_ban/don_dich/`, tên bắt đầu `ra_don_`) và phần khung ở Task 1.1 (khóa `bao_don` cho phần `truoc`). **Khi** gõ `tools/test.sh`, **thì** test xanh, có dòng `Kịch bản luật: 66 đã duyệt · 9 chưa duyệt (N chưa đạt)` với N khớp bảng "Lý do chưa đạt". AI commit rồi **dừng chờ tác giả duyệt** bằng `tools/xem_kich_ban.sh don_dich`.
2. **Khi** tác giả duyệt, **thì** `tools/test.sh` trượt ở các kịch bản ghi "trượt" trong bảng. Kịch bản bị nói "sai" thì sửa kịch bản theo lý do của tác giả, không sửa code để khớp.
3. **Khi** code xong, **thì** `tools/test.sh` xanh, `Kịch bản luật: 75 đã duyệt · 0 chưa duyệt (0 chưa đạt)`, 66 kịch bản cũ không sửa một chữ.
4. **Ra đòn theo thứ tự (FR21).** **Cho** các đòn đã báo, **khi** bấm Kết thúc lượt, **thì** trước khi sang hiệp mới, các đòn đánh lần lượt theo `order` tăng dần (duyệt `state.telegraphs`, đã xếp theo số thứ tự). Mỗi đòn trúng ô `TelegraphMarks.hit_cell(state, t)` tính **ngay lúc đòn đó ra**, theo bàn sau các đòn trước (đòn trước làm gục quân chắn đường thì Kỵ binh đi xa hơn).
5. **Chỉ sát thương, không đẩy (FR26).** Ô trúng có quân (**bất kỳ phe**) thì quân đó mất `Stats.damage(loại quân của chủ đòn)` máu (`chi_so.json`: Bộ binh 1, Kỵ binh 1). Không đẩy, không kéo, chủ đòn không di chuyển (Kỵ binh "đứng yên", kiến trúc "Pha địch").
6. **Ô trống, vật cản, trượt.** Tướng đã rời ô đỏ của đòn vào ô: đòn đánh vào ô trống, không ai mất máu. Kỵ binh trúng rừng/kho lương/làng: không ai mất máu (Lòng dân −1 khi trúng làng là Story 3.7, chưa làm). Kỵ binh xung phong vào hàng trống tới mép: đòn **trượt**, không ai mất máu.
7. **Quân Nguyên trúng đòn đồng đội.** Quân Nguyên đứng trong ô đòn trúng của đồng đội thì ăn đòn, kể cả gục (FR "đòn trúng mọi phe").
8. **Chủ đòn đã gục** (bị đánh trong lượt người chơi, hoặc bị đòn trước đó trong pha này giết): đòn **không ra** (`hit_cell` trả `NO_CELL`), không sự kiện, không lỗi. Đòn có ô đích ra ngoài bàn hoặc Kỵ binh sát mép hướng ra ngoài (`path_cells` rỗng): cũng không ra.
9. **Hết trận giữa pha.** Kiểm thắng/thua **sau từng đòn** (`RulesVictory.check` với sự kiện của riêng đòn đó). Trận hết (`WON`/`LOST`) thì **dừng ngay**: các đòn sau không ra, **không** sang hiệp mới (không `ROUND_STARTED`, `round_number` giữ nguyên), không chạy pha chuẩn bị. Thắng ưu tiên khi cùng lúc (đã có trong `check`).
10. **Sau khi ra hết đòn**, giữ nguyên luồng hiện có: sang hiệp mới, tướng đi/đánh lại được, pha chuẩn bị xóa đòn cũ rồi báo đòn mới.
11. **Sự kiện.** Mỗi đòn ra phát `ATTACKED` (`unit_id` = chủ đòn, `from_cell` = ô chủ đòn, `to_cell` = ô trúng; Kỵ binh trượt thì ô sát mép), rồi `DAMAGED` (nguyên nhân mới `Cause.ENEMY_STRIKE`) và `DIED` nếu có. Đủ để hoạt ảnh 2.11 phát lại; không thêm loại sự kiện khác.
12. **Tất định (NFR5).** `tests/test_determinism.gd` (MỚI) chạy **mỗi** kịch bản trong `tests/kich_ban/` hai lần, so cả bàn cuối (vị trí, máu, cờ đi/đánh, hiệp, `phase`, đòn đã báo) lẫn dãy sự kiện của từng bước: phải giống hệt.
13. **Trong game.** Bấm Kết thúc lượt: máu trên đồng quân giảm đúng, quân gục biến mất, tướng cuối gục thì hiện bảng thua (Story 2.5), không còn bấm được lệnh. Không lỗi trong log khi chạy `tran_01`, `thu_keo`, `thu_lao` và Kết thúc lượt vài lần.

## Tasks / Subtasks

- [x] **Task 1: Khung, đợt kịch bản 10, dừng chờ duyệt** (AC: 1, 2)
  - [x] 1.1 Khung (làm trước để kịch bản nạp và so được):
    - `src/data/scenario_loader.gd`: thêm `"bao_don"` vào `BEFORE_KEYS`; đọc bằng **chính** `_read_telegraphs` (tên hiện `truoc.bao_don`, lớp quân `truoc.quan`). Kiểm như `sau.bao_don`: thứ tự không trùng, ô `quan` có quân Nguyên, mỗi quân một đòn, `o` kề `quan`, `huong` hợp lệ. **Thêm cho `truoc`**: số thứ tự phải liền từ 1 (1, 2, 3…), vì `BattleState.validate` đòi vậy; câu lỗi tiếng Việt kèm file và giá trị sai.
    - `src/data/scenario_data.gd`: `before_telegraphs: Array[ExpectedTelegraph]` (rỗng khi không ghi).
    - `tests/scenario_runner.gd` `run`: sau `controller.start(...)`, dựng `Telegraph` từ `before_telegraphs` (chủ đòn = `unit_at(owner_cell).id`; CELL: `offset = target - owner_cell`; DIRECTION: `offset = target`) và đưa vào state của controller **trước** `validate()` "trước:". Cách đưa: thêm tham số không bắt buộc `telegraphs: Array[Telegraph] = []` cho `BattleController.start` (chép sâu vào `_state.telegraphs`), không mở đường sửa state sống nào khác.
    - `tests/scenario_viewer.gd`: phần `truoc` có `bao_don` thì in thêm bàn **"Ô ĐỎ"** cạnh bàn TRƯỚC (cùng cách in với bàn "Ô ĐỎ" của `sau`, Story 2.7), tính bằng `TelegraphMarks.cells` trên state dựng từ `truoc`; và in danh sách đòn dạng `Đòn 1: Bộ binh 3,3 đánh ô 3,4`, `Đòn 2: Kỵ binh 0,3 xung phong hướng Đông`. Chữ qua `tr()` (khóa `scenario.viewer.*`; sinh lại `text.vi.translation`).
    - `tests/test_scenario_loader.gd`: ca nạp `truoc.bao_don` đúng; ca sai (thứ tự không liền `[1, 3]`, ô `quan` không có quân Nguyên, `o` không kề); ca runner dựng đòn đúng chủ, đúng offset.
  - [x] 1.2 Viết 9 file đúng "Đợt kịch bản 10", `"da_duyet": false`. Chép cấu trúc từ `tests/kich_ban/don_dich/o_do_tuong_khac_buoc_vao.json`. Bàn `sau` đã tính bằng mô phỏng (xem Debug Log của story tạo); **chạy lại mô phỏng** (`BoardFixture` + `Rules.resolve(end_turn)` trên bàn đã trừ máu bằng tay) trước khi viết để chắc.
  - [x] 1.3 `tools/xem_kich_ban.sh don_dich`: đọc lại từng bàn, bàn "Ô ĐỎ" của TRƯỚC, khớp `mo_ta`. `tools/test.sh`: `66 đã duyệt · 9 chưa duyệt (N chưa đạt)`. Ghi Debug Log từng lý do trượt.
  - [x] 1.4 Commit: `Kịch bản quân Nguyên ra đòn chờ duyệt (Story 2.8)`.
  - [x] 1.5 **HALT.** Nhắn tác giả tiếng Việt: gõ `tools/xem_kich_ban.sh don_dich` (chỉ cần đọc 9 file `ra_don_*`), trả lời "đúng"/"sai: <lý do>" từng cái. Nói rõ: bàn "Ô ĐỎ" cạnh TRƯỚC là các đòn đã báo sẵn; bàn SAU là sau khi các đòn đánh **và** quân Nguyên đã đi, báo đòn cho hiệp 2 (luật 2.6), nên quân Nguyên có thể đổi chỗ.
  - [x] 1.6 Sau khi tác giả trả lời: đổi `da_duyet: true` cho kịch bản "đúng"; `tools/test.sh` phải trượt. Không commit khi đỏ.
- [x] **Task 2: Test GUT lõi viết trước** (AC: 4–11)
  - [x] 2.1 `tests/test_rules_enemy_phase.gd` (thêm, dùng `BoardFixture`, dựng `Telegraph` tay): dãy sự kiện đúng của một đòn Bộ binh trúng tướng (`ATTACKED`, `DAMAGED … ENEMY_STRIKE`) và trước `ROUND_STARTED`; Kỵ binh trúng kho lương và làng (không ai mất máu, có `ATTACKED` vào ô vật); Kỵ binh sát mép hướng ra ngoài (không sự kiện); chủ đòn đã gục trước pha (không sự kiện); đòn 1 giết chủ đòn 2 (đòn 2 không ra); đòn 1 giết quân chắn đường, đòn 2 Kỵ binh đi xa hơn; tướng cuối gục ở đòn 1 → `DEFEAT`, đòn 2 không ra, `round_number` giữ nguyên, không `ROUND_STARTED`, `telegraphs` còn nguyên (không chạy prepare); quân Nguyên giết nhau không thắng nhầm (B1 1 máu, đòn 1 vào ô B2 1 máu; B2 đòn 2 vào ô B1: đòn 1 giết B2, đòn 2 không ra vì chủ đã gục, còn B1 nên không `VICTORY`; ghi chú: ở story này không thể thắng trong pha địch, vì quân ra đòn cuối luôn còn sống — thắng giữa pha có từ hầm chông/tiếp viện về sau); máu không xuống dưới 0; bàn 10×8.
  - [x] 2.2 Chạy riêng file: trượt (ghi Debug Log số ca trượt).
- [x] **Task 3: Luật ra đòn** (AC: 4–11)
  - [x] 3.1 `BattleEvent`: thêm `Cause.ENEMY_STRIKE` (đòn của quân Nguyên; Sát Thát 3.x chỉ cộng cho `STRIKE` của tướng). Sửa chú thích `ATTACKED` (giờ cả quân Nguyên: ô trúng; Kỵ binh trượt: ô sát mép). Không thêm `Type` mới.
  - [x] 3.2 `RulesEnemyPhase.end_player_turn`: thay chú thích "Story 2.8" bằng `_strike_all(state, events)` (hàm riêng, cùng file): `state.phase = ENEMY_ACT`; với mỗi `t` trong `state.telegraphs` (theo thứ tự đã xếp): `hit = TelegraphMarks.hit_cell(state, t)`; `NO_CELL` thì bỏ qua; `ATTACKED`; quân ở `hit` (nếu có) mất `state.stats.damage(owner.type)` qua `Effects.damage(..., ENEMY_STRIKE, strike_events)`; nối `strike_events` vào `events`; `RulesVictory.check(state, strike_events)` rồi nối sự kiện kết cục; `Rules.is_battle_over(state)` thì **return** khỏi `end_player_turn` (không sang hiệp). Hết vòng thì làm tiếp phần sang hiệp như cũ (prepare tự đặt `PLAYER`).
  - [x] 3.3 **Không** tự tính ô trúng ở đây: chỉ `TelegraphMarks.hit_cell` (2.7 đã tách để ô đỏ và đòn thật không lệch nhau). Không duyệt khóa Dictionary. Không `Node`, `Log`.
  - [x] 3.4 `Rules.resolve` vẫn gọi `RulesVictory.check` ở cuối: trận đã hết thì `check` không làm gì (đã có), không sinh `VICTORY`/`DEFEAT` hai lần — có test.
  - [x] 3.5 `tools/test.sh`: kịch bản và test 2.1 đạt. **Phá thử** (mỗi lần một chỗ, chạy từng kịch bản, ghi Debug Log): đòn đẩy 1 ô (`ra_don_bo_binh_trung_tuong` trượt); dùng ô trúng tính lúc báo thay vì lúc ra (`ra_don_theo_thu_tu` trượt); ra đòn theo thứ tự ngược (`ra_don_theo_thu_tu` trượt); không dừng khi thua (`ra_don_tuong_cuoi_guc_thua` trượt); bỏ qua quân Nguyên trong ô trúng (`ra_don_bo_binh_trung_dong_doi`, `ra_don_ky_binh_trung_dong_doi` trượt).
- [x] **Task 4: Tất định** (AC: 12)
  - [x] 4.1 `ScenarioRunner.run` trả thêm bàn cuối và sự kiện từng bước trong `ScenarioResult` (ví dụ `final_state: BattleState` (clone) và `step_events: Array[Array]`), không đổi cách so hiện có.
  - [x] 4.2 `tests/test_determinism.gd` (MỚI): với **mọi** file `ScenarioLoader.list_files("res://tests/kich_ban")` nạp được (cả chưa duyệt), chạy hai lần, so `BoardFixture.picture`, `round_number`, `phase`, đòn (`owner_id`, `kind`, `offset`, `order`) và mô tả sự kiện (`BoardFixture.describe` hoặc tương đương đủ trường). Khác thì một câu tiếng Việt nêu kịch bản và chỗ khác.
  - [x] 4.3 Phá thử: chèn tạm một chỗ không tất định (ví dụ duyệt quân theo khóa Dictionary băm theo object) → test trượt; bỏ ra. Ghi Debug Log. Nếu không dựng được ca phá thử đáng tin, ghi rõ vì sao.
- [x] **Task 5: Giao diện và test qua `main.tscn`** (AC: 13)
  - [x] 5.1 Đọc `main.gd`, `battle_view.gd`: kiểm Kết thúc lượt có phase `LOST`/`WON` hiện bảng kết quả (2.5) và khóa bàn như khi thua/thắng trong lượt người chơi. Sửa nếu thiếu, không sửa nếu đã đúng (ghi lý do).
  - [x] 5.2 Test (`test_battle_view.gd`, trận thử viết vào `user://` như `_make_attack_main`): mở trận có Bộ binh kề Khoái → Space → Khoái mất 1 máu (`hp_text` của đồng), hiệp 2; trận một tướng 1 máu kề Bộ binh → Space → bảng thua, Hủy và phím đều không làm gì. Rà các test giao diện cũ có Kết thúc lượt: đòn giờ đánh thật, test nào giả định máu không đổi thì sửa test **có ghi lý do** (không sửa kịch bản đã duyệt).
  - [x] 5.3 Rà trận thử `data/tran/thu_*.json` và `tran_01`: sau Kết thúc lượt đòn đánh thật; `test_loaders.gd::_assert_enemies_stay_on_begin` vẫn đạt. Không đổi bố cục trận nếu không cần.
- [x] **Task 6: Kiểm bằng mắt, tài liệu, commit** (AC: 13)
  - [x] 6.1 Chạy `tools/chay.sh --dev --tran=thu_keo`, `thu_lao`, `tran_01`; bấm Kết thúc lượt vài lần. GoPeak `capture_screenshot` (CLAUDE.md "Nhìn game đang chạy"); GoPeak không kết nối thì dùng `img/pixellab-thu/cong-cu/chup.gd` trên bản chép của `game/` ở scratchpad (cách đã dùng ở 2.7, Debug Log 2.7). Lưu `_bmad-output/implementation-artifacts/anh/2-8-*.png` (ít nhất: trước và sau Kết thúc lượt, thấy máu giảm; bảng thua). Không có ảnh thì **không đánh [x]**. Log không ERROR/WARN (trừ WARN tham số lạ của công cụ chụp).
  - [x] 6.2 `game-architecture.md`: "Pha địch" bước 3 ghi cài đặt (`_strike_all`, `TelegraphMarks.hit_cell` lúc ra đòn, `Cause.ENEMY_STRIKE`, dừng khi hết trận, không sang hiệp); mục "Kịch bản luật" thêm `truoc.bao_don`; "Gục, thắng, thua" bỏ chữ "từ Story 2.8" thành đã làm. `deferred-work.md`: gạch mục 2.8 đã xong (dòng "Story 2.8 (đòn địch): phải gọi `RulesVictory.check`…", "Story 2.8 (ra đòn): chèn…", "Story 2.8 (ra đòn): dùng `TelegraphMarks.hit_cell`…") và ghi việc cho 2.9 (`TELEGRAPH_CANCELLED` cho đòn bị bỏ qua ở AC 8).
  - [x] 6.3 `tools/test.sh` xanh. Commit một lần (kịch bản đã duyệt, code, test, tài liệu, `.uid` mới, `text.vi.translation`, ảnh): `Quân Nguyên ra đòn theo thứ tự (Story 2.8)`.
  - [x] 6.4 Ghi "Hướng dẫn tác giả tự test" vào Completion Notes bằng kết quả thật (chạy lại từng bước trên game trước khi ghi; 2.7 từng ghi sai một bước vì viết theo suy đoán).

### Review Findings

- [x] [Review][Patch] Task 6.1 đánh `[x]` dù GoPeak không kết nối: ảnh chụp từ trận tạm `thu_thua` trên bản chép ngoài repo, không có bằng chứng đã chạy `thu_lao` và log của `tools/chay.sh --dev` trên repo. Bỏ `[x]`, ghi "chờ tác giả kiểm tay". [story: Task 6.1, Debug Log]
- [x] [Review][Patch] Task 5.2: test thua (`test_enemy_attacks_can_lose_the_battle`) chỉ kiểm nút Kết thúc lượt bị khóa và Space; chưa kiểm nút Hủy và phím Z không làm gì sau khi thua. Thêm vào test. [test_battle_view.gd]
- [x] [Review][Patch] Task 2.1: thiếu ca GUT "máu không xuống dưới 0" (Bộ binh/Kỵ binh sát thương lớn hơn máu còn lại của quân bị trúng). Thêm test. [test_rules_enemy_phase.gd]
- [x] [Review][Defer] Công cụ duyệt kịch bản: khi kịch bản có cả `truoc.bao_don` và `sau.o_do` thì cột bàn có thể lệch (`LEFT_WIDTH` cộng cứng cho tối đa 3 bàn) — deferred [scenario_viewer.gd]
- [x] [Review][Defer] Kỵ binh xung phong trúng tướng nhưng đứng yên ở ô cũ (đúng AC 5 "chủ đòn không đi"); hoạt ảnh 2.11 phải tự suy ra đường lao từ `ATTACKED.from_cell` tới `to_cell` — deferred, xử lý ở 2.11 [battle_event.gd]

## Dev Notes

### Bối cảnh

- **Đã có (2.6):** `Telegraph` (`owner_id`, `kind` CELL/DIRECTION, `offset`, `order`, `target_cell`, `clone`, `NO_CELL`), `BattleState.telegraphs` (theo số thứ tự, `validate` kiểm thứ tự liền từ 1, hình dạng, chủ đòn là quân Nguyên kể cả đã gục), `RulesEnemyPhase.prepare` (xóa đòn cũ, đi hết rồi mới báo đòn), `begin_battle`, `EnemyAI.CHARGE_BLOCKERS`, khóa kịch bản `sau.bao_don`, F3.
- **Đã có (2.7):** `TelegraphMarks.cells/hit_cell/path_cells` trong `src/core/telegraph_marks.gd` — Kỵ binh: từ ô trước mặt tới vật đầu tiên (quân bất kỳ phe, rừng/kho lương/làng; sông không chắn), gồm ô đó; hàng trống thì ô cuối là ô sát mép. Đòn vào ô: ô đích nếu chủ còn và ô trong bàn. Chủ gục hoặc ra ngoài bàn: rỗng/`NO_CELL`. `TelegraphView` vẽ lại theo bản chụp sau mỗi lệnh (nên sau ra đòn ô đỏ mới tự hiện).
- **Đang làm song song:** sửa theo code review 2.7 (chưa commit lúc tạo story này: `telegraph_view.gd` có `arrow_on_top`, chuỗi số tự giảm cỡ; `scenario_runner.gd`, `scenario_viewer.gd`). **Đọc lại các file này từ đĩa** trước khi sửa `scenario_runner.gd`/`scenario_viewer.gd`; 2.7 phải `done` (hoặc commit xong) trước khi bắt đầu Task 1.
- `Rules.resolve` → `RulesEnemyPhase.end_player_turn` (lệnh `END_TURN`): hiện chỉ sang hiệp và gọi `prepare`. Có chú thích chỗ chèn ra đòn ở dòng đầu hàm.
- `RulesVictory.check(state, events)` chỉ kiểm khi `events` có `DIED`/`DROWNED`; trận đã hết thì không làm gì. Gọi ở cuối `Rules.resolve`.
- `Effects.damage` trừ máu (không dưới 0), `DAMAGED` với số máu trừ thật, hết máu thì nhấc khỏi bàn và `DIED`. `assert(amount > 0)`: `sat_thuong` quân Nguyên luôn ≥ 1 (bộ nạp chặn).
- `Stats.damage(type)` đọc `sat_thuong`. `chi_so.json` thật: Bộ binh 3 máu đi 2 đánh 1; Kỵ binh 2 máu đi 3 đánh 1; tướng 3 máu. `BoardFixture.stats()` giống vậy.
- Phase có sẵn `ENEMY_ACT` (chưa dùng).
- Mọi kịch bản cũ có nhiều nhất một `ket_thuc_luot` và `truoc` không có đòn, nên 66 kịch bản cũ không đổi kết quả (đã kiểm khi tạo story: không file nào có hai `ket_thuc_luot`).
- Tác giả không đọc code; thứ tác giả nhìn: `tools/xem_kich_ban.sh`, `tools/test.sh`, game chạy bằng `tools/chay.sh`.

### Thuật toán ra đòn (AC 4–11)

```
end_player_turn(state, events):
    _strike_all(state, events)
    if Rules.is_battle_over(state): return          # thua/thắng giữa pha: không sang hiệp
    (phần cũ: round_number += 1, reset cờ, ROUND_STARTED, prepare)

_strike_all(state, events):
    state.phase = ENEMY_ACT
    for t in state.telegraphs:                      # đã theo order 1, 2, 3…
        hit = TelegraphMarks.hit_cell(state, t)     # tính lúc này, theo bàn hiện tại
        if hit == NO_CELL: continue                 # chủ gục / ngoài bàn / Kỵ binh sát mép (2.9 thêm sự kiện hủy)
        owner = state.unit_by_id(t.owner_id)
        strike = []
        strike.append(ATTACKED(owner.id, owner.cell, hit))
        victim = state.unit_at(hit)
        if victim != null: Effects.damage(state, victim, state.stats.damage(owner.type), ENEMY_STRIKE, strike)
        RulesVictory.check(state, strike)
        events.append_array(strike)
        if Rules.is_battle_over(state): return
```

- `BattleEvent.attacked` hiện chỉ nhận `(unit_id, cell)`, `cause = STRIKE`: thêm tham số `from_cell` (mặc định `Vector2i.ZERO` để không phải sửa lời gọi của tướng) hoặc hàm mới `enemy_attacked(unit_id, from, to)`; chọn một, ghi lý do.
- `RulesVictory.check` gọi với `strike` rồi mới nối vào `events`, để `VICTORY`/`DEFEAT` là sự kiện cuối (2.5: "luôn là sự kiện cuối của lệnh").
- Trận hết giữa pha: `phase` là `WON`/`LOST` (do `check` đặt), không quay về `PLAYER`. `telegraphs` còn nguyên (ô đỏ của đòn chưa ra vẫn vẽ; 2.7 AC 10: hết trận vẫn vẽ đòn còn lại).

### Đợt kịch bản 10

Thư mục `tests/kich_ban/don_dich/`, tên `ra_don_*.json`. Bàn 7×7 toàn đất trống trừ khi ghi; chỉ số thật (`chi_so.json`). Không ghi `thu_tu_dich` (mặc định thứ tự đọc bàn). Mọi kịch bản có `truoc.bao_don` (đòn đã báo sẵn), lệnh cuối là `{"lenh": "ket_thuc_luot"}`. `sau` ghi `quan`, `mau`, `hiep`; **không** ghi `bao_don`/`o_do` (đòn hiệp 2 là luật 2.6, đã có kịch bản riêng) trừ khi ghi rõ.

Bàn `sau` đã tính khi tạo story: trừ máu bằng tay theo luật 2.8, rồi chạy `Rules.resolve(end_turn)` của code hiện tại (chưa ra đòn) để có chỗ đứng quân Nguyên sau pha chuẩn bị hiệp 2. Cột "Quân sau" là kết quả đó.

| # | Tên file | Trước (quân, máu, địa hình) | `truoc.bao_don` | Lệnh thêm (trước `ket_thuc_luot`) | Quân sau (hiệp 2) | Máu sau (khác tối đa) | Ý nghĩa | Chưa code thì |
|---|---|---|---|---|---|---|---|---|
| 1 | `ra_don_bo_binh_trung_tuong.json` | B `3,3`; Khoái `3,4` | 1: B `3,3` ô `3,4` | — | B `3,3`; Khoái `3,4` | Khoái 2 | Bộ binh chém trúng Khoái, mất 1 máu, không bị đẩy | trượt (Khoái 3 máu) |
| 2 | `ra_don_tuong_roi_o_do.json` | như #1 | như #1 | Khoái đi `3,6` | B `3,5`; Khoái `3,6` | — | Khoái rời ô đỏ: đòn chém ô trống, không ai mất máu (rồi Bộ binh đuổi tới `3,5`) | **đạt** (code cũ cũng không trừ máu) |
| 3 | `ra_don_bo_binh_trung_dong_doi.json` | B `3,2`; B `3,3`; Khoái `3,4` | 1: B `3,2` ô `3,3`; 2: B `3,3` ô `3,4` | — | B `3,2`; B `3,3`; Khoái `3,4` | B `3,3` 2; Khoái 2 | Bộ binh đứng trong ô đỏ của đồng đội thì ăn đòn; đòn 2 vẫn chém Khoái | trượt |
| 4 | `ra_don_ky_binh_trung_tuong.json` | K `0,3`; Khoái `4,3`; Lão `5,3` | 1: K `0,3` hướng `D` | — | K `0,3`; Khoái `4,3`; Lão `5,3` | Khoái 2 | Kỵ binh trúng vật đầu tiên (Khoái), không xuyên tới Lão phía sau, Kỵ binh đứng yên | trượt |
| 5 | `ra_don_ky_binh_trung_dong_doi.json` | K `0,3`; B `2,3`; Khoái `4,3` | 1: K `0,3` hướng `D` | — | B `2,3`; K `3,3`; Khoái `4,3` | B `2,3` 2 | Bộ binh đứng chắn đường xung phong: Bộ binh ăn đòn, Khoái không mất máu (hiệp 2 Kỵ binh đi tới `3,3`) | trượt |
| 6 | `ra_don_ky_binh_truot.json` | K `0,3`; Khoái `4,3` | 1: K `0,3` hướng `D` | Khoái đi `4,5` | K `0,5`; Khoái `4,5` | — | hàng trống tới mép: đòn trượt | **đạt** |
| 7 | `ra_don_ky_binh_trung_rung.json` | K `0,3`; Khoái `4,3`; rừng `2,3` | 1: K `0,3` hướng `D` | — | K `2,2`; Khoái `4,3` | — | Kỵ binh trúng rừng: không ai mất máu (hiệp 2 không đứng thẳng hàng được, đi tới `2,2`, không báo đòn) | **đạt** |
| 8 | `ra_don_theo_thu_tu.json` | B `2,2`; K `0,3`; B `2,3` (1 máu); Khoái `4,3` | 1: B `2,2` ô `2,3`; 2: K `0,3` hướng `D` | — | B `4,2`; K `0,3`; Khoái `4,3` | Khoái 2 | đòn 1 giết Bộ binh đang chắn đường, nên đòn 2 Kỵ binh xung phong tới Khoái (ô trúng tính lúc ra đòn, theo thứ tự) | trượt |
| 9 | `ra_don_tuong_cuoi_guc_thua.json` | B `3,3`; Khoái `3,4` (1 máu); B `5,5`; B `5,6`; chỉ một tướng | 1: B `3,3` ô `3,4`; 2: B `5,5` ô `5,6` | — | B `3,3`; B `5,5`; B `5,6` (Khoái gục) | — (B `5,6` vẫn 3) | tướng cuối gục ở đòn 1: thua ngay, đòn 2 không ra, không sang hiệp (`hiep: 1`, `ket_qua: "thua"`) | trượt |

- Ghi lại `id` thứ tự đọc bàn khi dựng (`#8`: B `2,2` = 101, K `0,3` = 102, B `2,3` = 103; `#3`: B `3,2` = 101, B `3,3` = 102).
- `#2`, `#6` lệnh `di` trước `ket_thuc_luot`: Khoái đi 2 ô (`3,4`→`3,6`; `4,3`→`4,5`), trong tầm 3.
- `#9` là kịch bản "thua" đầu tiên của dự án (`deferred-work.md` 2.5 đã hẹn).
- `mo_ta` mỗi file một câu tiếng Việt, nhắc chuyện quân Nguyên đi lại ở hiệp 2 khi bàn SAU có quân đổi chỗ (#2, #5, #6, #7, #8).
- **Lý do chưa đạt:** 6 kịch bản trượt (#1, #3, #4, #5, #8, #9) vì code chưa ra đòn: dạng `sau: ô 3,4 mong đợi Nguyễn Khoái 2 máu, thực tế Nguyễn Khoái 3 máu` (câu thật lấy từ runner); #9 thêm `ket_qua`/`hiep`. 3 kịch bản đạt sẵn (#2, #6, #7): là ca "đòn không trúng ai", code cũ cũng không trừ máu; vẫn giữ vì là spec. Dòng tóm tắt mong đợi: `66 đã duyệt · 9 chưa duyệt (6 chưa đạt)`.

### Định dạng `truoc.bao_don`

Giống hệt `sau.bao_don` (Story 2.6): `[{"thu_tu": 1, "quan": "3,3", "o": "3,4"}, {"thu_tu": 2, "quan": "0,3", "huong": "D"}]`. `quan` là ô chủ đòn ở bàn **trước**; `o` là ô bị nhắm (phải kề `quan`); `huong` là `B`/`D`/`N`/`T`. Thêm: thứ tự phải liền từ 1. Không ghi thì trước không có đòn (như mọi kịch bản cũ).

### Hiện trạng các file sẽ sửa (đọc cả file trước khi sửa)

- `src/core/rules_enemy_phase.gd` (~70 dòng): `end_player_turn` (sang hiệp, reset cờ, `ROUND_STARTED`, `prepare`), `begin_battle`, `prepare`. Story này thêm `_strike_all` và lối ra sớm khi hết trận. **Giữ:** toàn bộ `prepare`, `begin_battle`.
- `src/core/battle_event.gd`: `Cause` thêm `ENEMY_STRIKE`; `attacked` (xem Thuật toán). **Giữ:** thứ tự các giá trị enum cũ (kịch bản/test có thể in tên, không in số; vẫn thêm vào **cuối**).
- `src/core/rules.gd`: không cần sửa (kiểm cuối lệnh không làm gì khi đã hết trận). Nếu sửa, ghi lý do.
- `src/battle/battle_controller.gd`: `start(level, stats)` thêm tham số đòn (Task 1.1). **Giữ:** hoàn tác (`END_TURN` xóa bản chụp hủy), `rolled_back`.
- `src/data/scenario_loader.gd` (`BEFORE_KEYS`, `_read_side`, `_read_telegraphs`), `scenario_data.gd`, `tests/scenario_runner.gd` (`run`, `compare`, `ScenarioResult`), `tests/scenario_viewer.gd` (in "Ô ĐỎ" của `sau` từ 2.7).
- `src/app/main.gd`, `src/battle/battle_view.gd`: chỉ đọc để kiểm luồng thua sau `END_TURN` (Task 5.1).

### Luật kiến trúc phải theo

- `src/core/` chỉ `RefCounted`, gõ kiểu tĩnh; không `Node`, `Log`, `print`, `randi`. Chỉ `Effects.damage` đổi máu. Chỉ `rules_enemy_phase.gd` và `rules_victory.gd` đổi `phase`.
- Ô trúng chỉ lấy từ `TelegraphMarks.hit_cell` (một chỗ tính cho cả ô đỏ và đòn thật).
- Duyệt `state.telegraphs` theo thứ tự; không lặp cứng cỡ bàn; số sát thương lấy từ `Stats`, không viết số 1.
- Đòn địch chỉ gây sát thương, không đẩy (project-context "Những điều không được quên"). Đòn trúng mọi phe.
- Kiểm thắng/thua sau mỗi sự kiện gây gục; thắng ưu tiên.
- Chữ hiển thị qua `tr()`; khóa `scenario.viewer.*` mới thì sinh lại `text.vi.translation` (như 2.7).

### Testing

- `tools/test.sh` là lệnh duy nhất. Test GUT viết trước, chạy đỏ riêng rồi mới code (ghi Debug Log). Lệnh chạy một file: `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/<file>.gd -gexit` (chạy `--import` trước nếu có `class_name` mới).
- `BoardFixture` đánh id quân Nguyên theo **thứ tự đọc bàn** (2.7 từng dựng test sai id vì quên điều này).
- Sau mỗi `Rules.resolve` trong test: `state.validate()` rỗng.
- Giao diện qua `main.tscn` thật; trận thử viết vào `user://`, xóa ở `after_each`. Mở trận chạy pha chuẩn bị (2.6): bố cục để quân Nguyên đứng sẵn kề tướng nó nhắm.
- Phá thử mỗi lần một chỗ, chạy từng kịch bản riêng; trả lại bản đúng, `diff` sạch.

### Previous Story Intelligence (2.7)

- Đáp án mong đợi tính tay dễ sai: tính bằng mô phỏng luật có sẵn rồi mới viết (đã làm cho bảng trên; chạy lại trước khi viết file).
- Ước lượng hình học chữ bằng `get_string_size` gồm cả khoảng dấu tiếng Việt; đo glyph thật bằng TextServer nếu cần (không liên quan trực tiếp story này).
- Hướng dẫn tự test phải chạy lại trên game trước khi ghi (2.7 ghi sai bước 3 lần đầu).
- GoPeak không kết nối được ở phiên 2.7; `chup.gd` trên bản chép game chạy tốt (`--steps=key:Space,shot:ten`).
- Task chụp ảnh chỉ đánh [x] khi có file ảnh. File List đủ `.uid` mới và `game/i18n/text.vi.translation`.
- Mục hoãn liên quan (`deferred-work.md`): runner bỏ qua tướng đã gục khi so `da_danh`/`da_di` (dòng ~105) — kịch bản #9 có tướng gục, không ghi `da_di`/`da_danh` nên không vướng; trận thử `thu_*` sẽ bị đánh sau Kết thúc lượt (dòng ~139).

### Git Intelligence

- Commit gần nhất: `6195636 Vẽ ô đỏ và số thứ tự báo đòn (Story 2.7)`, `5153f7d Kịch bản ô đỏ báo đòn chờ duyệt (Story 2.7)`, `f575cfa Tạo story 2.7…`. Mẫu: commit kịch bản chờ duyệt riêng, rồi một commit code; lời commit tiếng Việt, kết `(Story X.Y)`, có `Co-Authored-By`.
- Cây làm việc có thay đổi hình E8 (`img/`, `ban-giao-asset.md`, `danh-sach-hinh-e8.md`, GDD `decision-log.md`, `gdd.md`) không thuộc story: **không gộp** vào commit. Có thay đổi review 2.7 của phiên khác: không gộp trừ khi đã thuộc 2.7 và 2.7 đã commit xong.
- Hiện có 539 test (543 sau review 2.7), 66 kịch bản đã duyệt.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh, cú pháp Godot 4; GUT 9.7.1; web đơn luồng (không `Thread`).
- M3: kịch bản trước, tác giả duyệt, trượt, rồi code; cấm sửa kịch bản đã duyệt; nghi kịch bản sai thì hỏi tác giả.
- Tất định: duyệt theo `order`/`thu_tu_dich`, không theo khóa Dictionary; `test_determinism.gd` chạy mỗi kịch bản hai lần (story này tạo file đó).
- Pha địch ≤ 3 giây hoạt ảnh là việc của 2.11; story này không có hoạt ảnh.
- Bật dev bằng `--dev`; GoPeak chỉ để nhìn và thử. Commit khi xanh, lời commit tiếng Việt.

### Quyết định mặc định đã chọn (tác giả có thể đổi khi duyệt)

- Thua/thắng giữa pha địch: dừng ngay, **không sang hiệp mới** (bộ đếm hiệp giữ nguyên, kịch bản #9 `hiep: 1`). Kiến trúc chỉ ghi "dừng pha địch", chưa ghi về số hiệp.
- Đòn bị bỏ qua (chủ gục, ngoài bàn) không phát sự kiện ở story này; 2.9 thêm `TELEGRAPH_CANCELLED`.
- Kỵ binh trượt vẫn phát `ATTACKED` vào ô sát mép (để 2.11 vẽ cú xung phong hụt).
- Kịch bản đặt đòn sẵn bằng `truoc.bao_don` thay vì chạy hai lần Kết thúc lượt, để bàn TRƯỚC đọc thẳng ra đòn nào sẽ đánh.

### References

- `_bmad-output/planning-artifacts/epics.md` Story 2.8 (dòng 762–784), 2.9 (785–805), FR21, FR26, NFR5.
- `_bmad-output/planning-artifacts/game-architecture.md` "Pha địch" (bước 3 Ra đòn, Kỵ binh, Bộ binh), "Gục, thắng, thua", M1, M3, "Kịch bản luật" (khóa `sau`).
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` "Action Economy" (đòn gắn ô/hướng, chỉ sát thương).
- `_bmad-output/implementation-artifacts/2-7-hien-thi-bao-don.md` (TelegraphMarks, Debug Log), `2-6-dich-chuan-bi-ai-di-va-chon-muc-tieu.md`, `deferred-work.md` (mục 2.5, 2.6, 2.7).
- `_bmad-output/project-context.md`.

## Dev Agent Record

### Agent Model Used

Claude Opus 5.5 (claude-opus-5-5[1m])

### Debug Log References

- 2026-10-21 (tạo story): bàn `sau` của "Đợt kịch bản 10" tính bằng script tạm (`BoardFixture.state` với máu đã trừ tay theo luật 2.8, rồi `Rules.resolve(Command.end_turn())` của code ở `6195636`, chưa ra đòn): in bàn cuối, máu, đòn hiệp 2. #9 không cần mô phỏng (hết trận, không chạy pha chuẩn bị). Đã kiểm 66 kịch bản cũ: không file nào có hai `ket_thuc_luot`, `truoc` không có đòn, nên ra đòn không đổi kết quả của chúng.

- 2026-10-21 Task 1.1–1.3: `truoc.bao_don` (loader dùng chung `_read_telegraphs`, thêm kiểm số thứ tự liền từ 1), `ScenarioData.before_telegraphs`, `BattleController.start(level, stats, telegraphs = [])`, `ScenarioRunner.before_telegraphs` (viewer dùng chung). Viewer: bàn "Ô ĐỎ" của bàn trước đứng giữa TRƯỚC và SAU, danh sách "Đòn đã báo sẵn", dòng `Ô đỏ c,h: đòn 1·2`; ghi chú máu của bàn SAU dời thẳng cột với SAU. 1 khóa mới `scenario.viewer.before_telegraphs`. Test cũ `test_after_telegraph_errors` khẳng định `truoc.bao_don` là khóa lạ: đổi thành không cảnh báo (khóa giờ hợp lệ theo story). 9 kịch bản `don_dich/ra_don_*.json` sinh bằng script từ bảng. `tools/test.sh`: 547/547 đạt, `66 đã duyệt · 9 chưa duyệt (6 chưa đạt)`; 6 lý do trượt khớp bảng (#1, #3, #4, #5: máu 3 thay vì 2; #8: `ô 0,3 mong đợi K, thực tế trống` vì Bộ binh chắn chưa gục nên Kỵ binh đi chỗ khác; #9: Khoái còn ở 3,4).

- 2026-10-21 Task 1.5–1.6: tác giả duyệt "tất cả đúng" 9 kịch bản. Đổi `da_duyet: true`; `tools/test.sh` trượt (`test_approved_scenarios_pass`).
- Task 2: 9 ca mới trong `test_rules_enemy_phase.gd`; chạy riêng: 7 trượt, 2 ca "không có gì xảy ra" (Kỵ binh sát mép hướng ra ngoài, chủ đòn đã gục trước pha) đạt sẵn vì code cũ cũng không làm gì. Ca "Kỵ binh đi xa hơn khi quân chắn gục" để kịch bản `ra_don_theo_thu_tu` lo (không chép thành GUT).
- Task 3: `Cause.ENEMY_STRIKE`, `BattleEvent.enemy_attacked(id, from, to)` (hàm riêng thay vì thêm tham số cho `attacked`, để lời gọi của tướng giữ nguyên `from_cell = ZERO`, `cause = STRIKE`), `RulesEnemyPhase._strike_all`. `tools/test.sh`: 556/556, `75 đã duyệt · 0 chưa duyệt`. Không cần sửa `rules.gd` (`check` cuối lệnh không làm gì khi đã hết trận; test `test_last_general_falls_mid_phase_stops_everything` kiểm `DEFEAT` đúng một lần). Phá thử, mỗi lần một chỗ, chạy `test_scenarios.gd`, trả lại bản đúng (`diff` sạch):
  - đẩy nạn nhân 1 ô → `bo_binh_trung_tuong`, `bo_binh_trung_dong_doi`, `ky_binh_trung_dong_doi`, `theo_thu_tu` trượt;
  - ô trúng tính một lần lúc bắt đầu pha (như lúc báo) → `theo_thu_tu` trượt (Khoái 3 máu);
  - ra đòn theo thứ tự ngược → `theo_thu_tu`, `tuong_cuoi_guc_thua` trượt;
  - không dừng khi thua → `tuong_cuoi_guc_thua` trượt (Bộ binh 5,6 mất máu);
  - bỏ qua quân Nguyên trong ô trúng → `bo_binh_trung_dong_doi`, `ky_binh_trung_dong_doi`, `theo_thu_tu` trượt.
- Task 4: `ScenarioResult.final_state`, `step_events`; `_run_step` nhận mảng sự kiện (kể cả lệnh bị từ chối). `test_determinism.gd` so bàn cuối (quân, máu, cờ, hiệp, pha, đòn, ý định AI), mọi trường của từng sự kiện, và câu so sánh. Phá thử: biến đếm `static` trong `_strike_all` đảo thứ tự ra đòn ở lần gọi chẵn → test trượt ở `ra_don_bo_binh_trung_dong_doi`, `ra_don_theo_thu_tu`, `ra_don_tuong_cuoi_guc_thua`; trả lại bản đúng.
- Task 5: `main.gd` (`_result_banner.show_result(snapshot.phase)`) và `battle_view.gd` (`Rules.is_battle_over(snapshot)`) đã đọc pha của bản chụp sau mọi lệnh, nên thua sau Kết thúc lượt tự hiện bảng và khóa bàn: không sửa. Thêm 2 test giao diện. Không test giao diện cũ nào phải sửa: các trận thử cũ ở hiệp 1 không có test nào kiểm máu sau Space. `_assert_enemies_stay_on_begin` vẫn đạt.
- Task 6.1: GoPeak không kết nối được; chụp bằng `img/pixellab-thu/cong-cu/chup.gd` trên bản chép `game/` ở scratchpad (trận tạm `thu_thua` chỉ có trong bản chép, bố cục như `_make_lose_main`). Log không ERROR; WARN duy nhất là tham số lạ của công cụ chụp.
- `tools/test.sh` cuối: 559/559 đạt, `Kịch bản luật: 75 đã duyệt · 0 chưa duyệt (0 chưa đạt)`.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Ra đòn nằm ở đầu `end_player_turn`; trận hết giữa pha thì `return` trước phần sang hiệp, nên `phase` giữ `LOST`/`WON`, hiệp giữ nguyên, đòn còn lại vẫn trong `state.telegraphs` (ô đỏ vẫn vẽ, 2.7 AC 10).
- Kịch bản dùng khóa mới `truoc.bao_don` để đặt đòn sẵn; công cụ duyệt in bàn "Ô ĐỎ" của bàn trước giữa TRƯỚC và SAU.
- Ảnh: `anh/2-8-thu-keo-truoc.png`, `anh/2-8-thu-keo-sau.png` (hiệp 2: Lão 2 máu, Dư 1 máu), `anh/2-8-thu-keo-hiep-3.png` (Dư đã gục, Lão 1 máu), `anh/2-8-thu-keo-thua.png` (bảng "Thua!" ở hiệp 4), `anh/2-8-tran-01-hiep-5.png` (Lão 1 máu), `anh/2-8-thua-truoc.png`, `anh/2-8-thua-sau.png` (trận tạm: ba quân chém Khoái, thua ở hiệp 1), `anh/2-8-lao-ne-don.png` (bước 5 của hướng dẫn).

**Hướng dẫn tác giả tự test** (đã chạy từng bước trên game trước khi ghi):

1. Gõ `tools/test.sh`. Thấy `559/559 test đạt` và `Kịch bản luật: 75 đã duyệt · 0 chưa duyệt (0 chưa đạt)` là đúng.
2. Gõ `tools/chay.sh --dev --tran=thu_keo`. Ô Lão có số `1`, ô Dư có `2·3`. Bấm Kết thúc lượt (Space), không làm gì khác. Thấy hiệp 2: chấm máu của Lão còn `2`, của Dư còn `1` (Dư trúng hai đòn); Khoái vẫn `3`; không quân nào bị đẩy.
3. Bấm Space lần nữa: sang hiệp 3, Dư biến mất (gục), Lão còn `1`.
4. Bấm Space thêm: tới hiệp 4 hiện bảng **"Thua!"**, nút Kết thúc lượt và Hủy mờ đi, bấm Space không còn tác dụng. Bấm "Chơi lại trận" để chơi lại.
5. Thử né đòn: mở lại `thu_keo`, chọn Lão (phím 2), bấm ô 1,1 (chéo xuống trái của Lão) cho Lão rời ô đỏ, rồi Space. Thấy hiệp 2: Lão vẫn `3` máu (Bộ binh chém vào ô trống); Dư còn `1`, ô Dư giờ mang `1·2·3`.
6. Gõ `tools/chay.sh --dev` (trận 1), bấm Kết thúc lượt vài lần: Bộ binh tới kề Lão rồi chém, máu Lão giảm dần mỗi hiệp.

### File List

- `game/src/core/rules_enemy_phase.gd`, `game/src/core/battle_event.gd`
- `game/src/battle/battle_controller.gd`
- `game/src/data/scenario_loader.gd`, `game/src/data/scenario_data.gd`
- `game/tests/scenario_runner.gd`, `game/tests/scenario_viewer.gd`
- `game/tests/test_scenario_loader.gd`, `game/tests/test_rules_enemy_phase.gd`, `game/tests/test_battle_view.gd`
- `game/tests/test_determinism.gd`, `.uid` (mới)
- `game/tests/kich_ban/don_dich/ra_don_*.json` (9 file mới)
- `game/i18n/text.csv`, `game/i18n/text.vi.translation`
- `_bmad-output/planning-artifacts/game-architecture.md`, `_bmad-output/implementation-artifacts/deferred-work.md`
- `_bmad-output/implementation-artifacts/anh/2-8-*.png` (8 ảnh)
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- 2026-10-21 (code review): thêm test thua kiểm cả nút Hủy và phím Z, test "sát thương lớn hơn máu còn lại". `tools/test.sh`: 560/560 đạt, 75 kịch bản đã duyệt. Task 6.1 bỏ `[x]`: còn chờ tác giả kiểm tay `thu_keo`, `thu_lao`, `tran_01` qua `tools/chay.sh --dev` (ảnh cũ chụp từ trận tạm `thu_thua` ngoài repo).
- 2026-10-22: tác giả báo đã tự kiểm tay bằng `tools/chay.sh --dev` và đồng ý bỏ bước chụp ảnh; đánh dấu Task 6.1 xong, story sang done.
