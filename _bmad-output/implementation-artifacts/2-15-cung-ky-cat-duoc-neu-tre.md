---
baseline_commit: 47651f3
---

# Story 2.15: Cung kỵ (cắt được nếu trễ)

Status: ready-for-dev

## Story

Là người chơi,
tôi muốn có Cung kỵ yếu máu nhưng bắn xa,
để phải chọn hạ quân nào trước.

## Acceptance Criteria

1. **Cho** một Cung kỵ (1 máu, đi 3) **khi** pha địch chuẩn bị **thì** nó báo đòn vào một ô **thẳng hàng, cách 2–3 ô** (FR20).
2. **Khi** có quân đứng giữa **thì** tên bay qua, **chỉ trúng ô đã báo** — quân đứng giữa không mất máu.
3. **Và** có kịch bản luật và luật AI cho Cung kỵ: kịch bản do tác giả duyệt **trước khi viết luật** (quy trình M3). Phần mở định dạng kịch bản (Task 2) làm trước chỉ để tác giả xem được kịch bản — nó không làm Cung kỵ biết bắn.
4. **Và** nếu story này bị cắt (E2 trễ) thì trận 3 và trận 6 dùng Bộ binh thay Cung kỵ (Story 3.6); **không** cần cờ bật/tắt trong code.
5. **Và** phần "rừng, kho lương chặn tên" **không** làm ở story này — để E3 (Story 3.1). Tương tự, Cung kỵ chỉ nhắm tướng (không nhắm làng: Story 3.7).

## Tasks / Subtasks

- [x] **Task 1: Viết kịch bản luật, chờ tác giả duyệt** (AC: 1, 2, 3)
  - [x] 1.1 Tính **ô đứng + ô báo đòn mong đợi** bằng một script tạm mô phỏng *độc lập* luật trong Dev Notes (tự viết `can_hit_from` cho Cung kỵ trong script, không gọi code sắp sửa). Không tính tay (bài học 2.8/2.9: đáp án tay sai rất nhiều). Script dùng `BoardFixture.stats()` cho khớp chỉ số.
  - [x] 1.2 Viết các file kịch bản dưới đây với `"da_duyet": false`, `mo_ta` một câu tiếng Việt nói rõ đang chứng minh luật gì. Bàn 7×7, địa hình `.` trừ chỗ ghi.
  - [x] 1.3 Chạy `tools/xem_kich_ban.sh` (không tham số, hoặc `ai` rồi `don_dich`) cho tác giả xem; **dừng, chờ tác giả duyệt**. Ghi kết quả vào Debug Log.

  **Nhóm `ai/` — pha chuẩn bị (kết thúc bằng `ket_thuc_luot`, nên `sau` là bàn đầu hiệp 2: không ai bị đánh, chỉ có đòn mới báo):**

  | File | Bàn (`quan`) | Điều phải thấy |
  |---|---|---|
  | `ai/cung_ky_dung_yen_ban.json` | `C` ở (3,3), `1` ở (3,6) | Cung kỵ **không đi**, báo đòn #1 vào (3,6); `sau` hiệp 2, Khoái còn 3 máu |
  | `ai/cung_ky_di_toi_tam_ban.json` | `C` ở (3,0), `1` ở (3,6) | Cung kỵ đi tới **(3,3)** (ô duy nhất trong tầm đi bắn được), báo đòn #1 vào (3,6) |
  | `ai/cung_ky_dung_ke_khong_ban.json` | `C` ở (3,5), `1` ở (3,6), sông `~` ở (2,5), (4,5), (3,4) | Cung kỵ bị vây, cách 1 ô: **không báo đòn**; `sau.bao_don: []` |

  **Nhóm `don_dich/` — đòn đã báo rồi mới ra đòn:**

  | File | Bàn trước | Lệnh | Điều phải thấy |
  |---|---|---|---|
  | `ra_don_cung_ky_trung_tuong.json` | `C` (3,3), `1` (3,6), `bao_don` #1: quan 3,3 → o 3,6 | `ket_thuc_luot` | Khoái 3→2 máu; `sau` hiệp 2, đòn mới `bao_don` #1 (3,3) → (3,6) |
  | `ra_don_cung_ky_bay_qua_quan.json` | `C` (3,3), `B` (3,4) đứng giữa, `1` (3,6), `bao_don` #1: quan 3,3 → o 3,6 | `ket_thuc_luot` | **Bộ binh không mất máu**, Khoái 3→2; rồi chuẩn bị: Cung kỵ đòn #1 (3,6), Bộ binh đi lên (3,5) đòn #2 (3,6) — đối chiếu bằng bàn thật |
  | `o_do_cung_ky_khong_di_theo_tuong.json` | `C` (3,3), `1` (3,6), `bao_don` #1: quan 3,3 → o 3,6 | `di` tướng 1 tới `4,6` | `o_do` **chỉ** `{"3,6": [1]}`: ô đỏ gắn với ô, không đi theo tướng. Ô (3,4), (3,5) không đỏ |
  | `don_cung_ky_dich_theo_khi_keo.json` | `3` (Trần Khánh Dư) ở (3,0), `C` (3,3), `1` (3,6), `bao_don` #1: quan 3,3 → o 3,6 | `danh` tướng 3 vào `3,3` | Dư kéo Cung kỵ 2 ô về (3,1); ô đỏ **dịch theo** thành (3,4): `bao_don` #1 quan 3,1 → o 3,4, `o_do` `{"3,4": [1]}`, `da_danh: ["3"]` |
  | `huy_don_cung_ky_khi_chu_don_guc.json` (nên có) | `1` ở (3,2), `C` (3,3) 1 máu, `bao_don` #1: quan 3,3 → o 3,6 | `danh` tướng 1 vào `3,3`, rồi `ket_thuc_luot` | Cung kỵ gục vì đòn 2 sát thương; đòn #1 bị hủy (`OWNER_DIED`), không ai trúng |

  - [x] 1.4 Kiểm từng file: kịch bản `ai/` phải là bàn `sau` đúng như script tạm tính; nếu lệch, sửa **kịch bản** cho khớp luật đã viết trong Dev Notes, không sửa luật cho khớp kịch bản.

- [x] **Task 2: Mở định dạng cho đòn bắn xa** (AC: 1, 2) — *chỉ là định dạng/bất biến, KHÔNG phải luật*
  > Lý do có task này **trước** khi tác giả duyệt: bộ nạp đang từ chối `"o"` cách 2 ô, nên `tools/xem_kich_ban.sh` báo lỗi và tác giả không xem được kịch bản. Task này không làm Cung kỵ biết bắn — luật vẫn phải trượt (Task 4) trước khi viết (Task 5).
  - [x] 2.1 `game/src/core/stats.gd`: thêm `shoot_min_range(type)` đọc `"tam_ban_gan"` và `shoot_max_range(type)` đọc `"tam_ban_xa"`, cạnh `min_range`/`max_range` của Lão. Comment: tầm bắn của Cung kỵ, không dùng cho tướng.
  - [x] 2.2 `game/src/core/battle_state.gd::_telegraph_shape_problem`, nhánh `Telegraph.Kind.CELL`: cho phép **hai** hình dạng tuỳ chủ đòn.
    - Chủ đòn còn trên bàn, `type == UnitType.CUNG_KY`: offset phải **thẳng hàng** (`offset.x == 0` hoặc `offset.y == 0`, không phải (0,0)) và `Grid.distance(Vector2i.ZERO, offset)` trong `[stats.shoot_min_range(type), stats.shoot_max_range(type)]`. Sai: `"đánh ô cách %d,%d, Cung kỵ chỉ bắn thẳng hàng %d–%d ô"`.
    - Chủ đòn còn trên bàn, loại khác: giữ nguyên `|x|+|y| == 1` và câu cũ `"đánh ô cách %d,%d, cần đúng một ô kề"` (**test cũ đang so đúng câu này**).
    - Chủ đòn đã gục (không còn trên bàn): chấp nhận offset **thẳng hàng**, dài 1–3 (không biết loại quân, không được nổ assert). Ghi comment lý do.
    - Cập nhật comment đầu hàm: `CELL` = một ô kề (Bộ binh) hoặc ô thẳng hàng 2–3 (Cung kỵ).
  - [x] 2.3 `game/src/data/scenario_loader.gd::_read_telegraphs`, chỗ kiểm `"o"` kề `"quan"`: lấy ký hiệu quân ở ô `quan` (`BoardLayers.symbol(side.unit_rows, owner)`).
    - Là `"C"`: kiểm **hai** lỗi theo thứ tự, câu nguyên văn:
      - không thẳng hàng (`Grid.straight_dir(owner, target) == Vector2i.ZERO`): `'%s: "o" ô %s không thẳng hàng với "quan" ô %s (Cung kỵ chỉ bắn thẳng hàng)'`
      - thẳng hàng nhưng `Grid.distance(owner, target) < 2`: `'%s: "o" ô %s không cách "quan" ô %s từ 2 ô trở lên (Cung kỵ không bắn ô kề)'`
    - Là ký hiệu khác: giữ nguyên `Grid.is_adjacent` + câu cũ `'"o" ô %s không kề "quan" ô %s'`.
    - Không tra được ký hiệu (lớp quân đã có lỗi riêng): giữ nhánh kề như hiện tại, đừng thêm lỗi thứ hai.
    - **Không chặn trên ở bộ nạp**: số 3 nằm trong `chi_so.json`, bộ nạp không có `Stats`. Trần 3 do `BattleState.validate()` kiểm lúc chạy.
  - [x] 2.4 Test GUT cho hai chỗ trên (xem mục Testing): `test_scenario_loader.gd` (thêm ca Cung kỵ), `test_battle_state.gd` (hình dạng đòn). **Thêm `tam_ban_gan`/`tam_ban_xa` cho CUNG_KY trong `_stats()` của cả `test_battle_state.gd` lẫn `test_scenario_loader.gd`** — `validate()` gọi `Stats.value` nên thiếu khóa là assert nổ ngay.
  - [x] 2.5 Chạy `tools/test.sh`: phải **xanh** (kịch bản Task 1 lúc này còn `da_duyet: false` và chưa đạt — bình thường; điều cần là không còn lỗi "sai định dạng"). Commit riêng phần định dạng: `Mở định dạng đòn bắn xa (Story 2.15)`.

- [ ] **Task 3: Tác giả xem và duyệt kịch bản** (AC: 3)
  - [ ] 3.1 `tools/xem_kich_ban.sh ai` rồi `tools/xem_kich_ban.sh don_dich`, đưa tác giả xem **bàn trước / bàn sau** cùng `mo_ta`. **Dừng, chờ tác giả duyệt.**
  - [ ] 3.2 Chỉ khi tác giả nói "duyệt": đổi `"da_duyet": true` cho đúng các file đã duyệt. Không đánh dấu file chưa được xem.
  - [ ] 3.3 Commit riêng phần kịch bản đã duyệt (mẫu commit của 2.8/2.9).

- [ ] **Task 4: Chứng minh kịch bản trượt đúng lý do** (AC: 1, 2)
  - [ ] 4.1 `tools/test.sh` (hoặc chỉ file `test_scenarios.gd`): **trước Task 5**, các ca `ai/cung_ky_*` phải trượt với lý do thiếu đòn (`sau: đòn 1 mong đợi quân ở 3,3 đánh ô 3,6, thực tế không có đòn 1`), không phải lỗi định dạng. Hai ca `don_dich/ra_don_cung_ky_trung_tuong` và `don_dich/ra_don_cung_ky_bay_qua_quan` cũng trượt vì phần chuẩn bị sau khi ra đòn chưa có đòn của Cung kỵ.
  - [ ] 4.2 Ba ca `o_do_cung_ky_khong_di_theo_tuong`, `don_cung_ky_dich_theo_khi_keo`, `huy_don_cung_ky_khi_chu_don_guc` **đạt ngay sau Task 2**. Đó là điều mong đợi: chúng chốt hành vi **đã có** của đòn `CELL` (ô đỏ gắn với ô, dịch theo chủ đòn, hủy khi chủ gục), không chờ luật mới. **Đừng sửa kịch bản cho nó trượt.**
  - [ ] 4.3 Ghi vào Debug Log dòng trượt đầu tiên của một kịch bản `ai/` và của một kịch bản `don_dich/`.

- [ ] **Task 5: Luật AI + báo đòn** (AC: 1, 2)
  - [ ] 5.1 `game/src/core/enemy_ai.gd`:
    - `_has_attack_rule`: thêm `UnitType.CUNG_KY`.
    - `can_hit_from`, nhánh `UnitType.CUNG_KY`: `Grid.straight_dir(cell, target) != Vector2i.ZERO` và `Grid.distance` trong `[stats.shoot_min_range, stats.shoot_max_range]`. **Không** xét quân hay địa hình ở giữa (tên bay qua; chặn tên là Story 3.1).
    - `telegraph_for`: **không sửa** — nhánh mặc định đã trả `CELL` với `target - stand`.
    - Cập nhật comment đầu file: bỏ câu "luật Cung kỵ (2.15) thêm nhánh ở đây", ghi luật Cung kỵ.
  - [ ] 5.2 `game/src/core/enemy_intent.gd`: comment `Reason.NO_ATTACK_RULE` — từ story này **không loại quân nào** dùng; giữ enum (F3 và bản dịch còn tham chiếu), đừng xoá.
  - [ ] 5.3 `game/src/core/telegraph.gd`: comment `CELL` đã đúng ("Bộ binh; Cung kỵ ở Story 2.15") — chỉ sửa nếu thấy sai.
  - [ ] 5.4 `TelegraphMarks` **không sửa**: `path_cells` của `CELL` chỉ trả ô đích, `hit_cell` = ô đích, nên "tên bay qua quân" và "ô đỏ chỉ ở ô đích" đã đúng sẵn. Nếu định sửa file này, dừng lại: đó là dấu hiệu hiểu sai luật.

- [ ] **Task 6: Sửa test cũ đang khẳng định "Cung kỵ đứng yên"** (AC: 1, 3)
  - [ ] 6.1 `game/tests/test_enemy_ai.gd::test_archer_has_no_attack_rule_yet` — thay bằng các test mới: đứng yên bắn (cách 3) → `CAN_HIT`; đi tới ô bắn được (cách 6) → `CAN_HIT` + ô đứng đúng; đứng kề → `CLOSEST`, không báo đòn; `can_hit_from` = true khi có quân đứng giữa.
  - [ ] 6.2 `game/tests/test_ai_intent_overlay.gd::test_no_enemy_and_archer` — dòng của Cung kỵ đổi từ "chưa có luật đòn cho loại quân này" sang "đứng đây vì đánh trúng được · đòn số 1" và ô đứng mới; lấy câu đúng bằng cách chạy test rồi dán, **không đoán**.
  - [ ] 6.3 `game/tests/test_battle_state.gd`: ca `(0,2)` với chủ đòn 101 là Bộ binh vẫn phải ra câu cũ; thêm ca Cung kỵ (xem Testing).
  - [ ] 6.4 Rà `grep -rn "chưa có luật đòn\|NO_ATTACK_RULE" game/` — chỗ nào còn nói Cung kỵ chưa có luật thì sửa.

- [ ] **Task 7: Xanh, kiểm ngược, chạy thử** (AC: 1, 2, 3, 5)
  - [ ] 7.1 `tools/test.sh` xanh; trong phiên AI dùng `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`.
  - [ ] 7.2 Kiểm ngược: (a) đổi `tam_ban_gan` thành 3 trong một bản sao `chi_so.json` → kịch bản bắn phải trượt; (b) đổi `o` của một kịch bản sang ô kề → bộ nạp phải báo lỗi; (c) bỏ `_has_attack_rule` CUNG_KY → kịch bản `ai/` trượt. Khôi phục, ghi Debug Log.
  - [ ] 7.3 Chạy tay: `tools/chay.sh --tran=thu_ba_tuong --dev` (bàn này **đã có** `C` ở (5,2)) — Cung kỵ phải đi và báo đòn; vẽ ô đỏ đúng, số thứ tự đúng. Chụp màn hình nếu GoPeak nối được; không thì ghi "chưa chụp".
  - [ ] 7.4 Ghi vào Completion Notes: story này **không** đụng trận 3/trận 6 (chưa có), nên AC 4 chỉ là ghi chú; và **không** thêm chặn tên (AC 5).

- [ ] **Task 8: Commit** (AC: 3)
  - [ ] 8.1 Commit kịch bản đã duyệt (Task 3) và phần luật (Task 5–7) **riêng**; phần định dạng đã commit ở Task 2.5. Lời tiếng Việt, kết `(Story 2.15)`. Không gộp `img/` và thay đổi của story khác.

## Dev Notes

### Hiện trạng trước story này (đọc trước khi sửa)

- `game/data/chi_so.json` **đã có** `quan_nguyen.cung_ky`: `mau 1, tam_di 3, sat_thuong 1, tam_ban_gan 2, tam_ban_xa 3`. `StatsLoader` đã bắt buộc và kiểm cặp `tam_ban_gan ≤ tam_ban_xa`; `test_loaders.gd` đã kiểm `max_hp(CUNG_KY) == 1`. **Không sửa số cân bằng.**
- AI hiện coi Cung kỵ là loại **chưa có luật đòn**: `EnemyAI._has_attack_rule` chỉ nhận `BO_BINH`, `KY_BINH`; `plan()` trả `Reason.NO_ATTACK_RULE` và `RulesEnemyPhase.prepare` không tạo `Telegraph`. Vì vậy story này **không phải viết luồng mới**, chỉ mở hai điều kiện và một hàm kiểm tầm.
- `Telegraph` (`CELL`) đã đúng cho "đánh vào ô": offset lưu **tương đối** so với chủ đòn; `TelegraphMarks.path_cells` với `CELL` trả **duy nhất ô đích**; `hit_cell` = ô đích. Nghĩa là "tên bay qua quân" và "chỉ trúng ô đã báo" **đã đúng sẵn** khi offset dài 2–3. Không sửa `TelegraphMarks`, `telegraph_view.gd`, `RulesEnemyPhase._strike_all`.
- `EnemyAI.telegraph_for` trả `CELL` với `target - stand` cho mọi loại không phải Kỵ binh — Cung kỵ dùng nguyên nhánh đó.
- **Hai chỗ đang chặn offset 2–3** (đây là phần lớn công việc):
  1. `battle_state.gd::_telegraph_shape_problem` — `CELL` đòi `absi(x)+absi(y) == 1`.
  2. `scenario_loader.gd::_read_telegraphs` — `"o"` phải kề `"quan"`.
  Không sửa hai chỗ này thì mọi kịch bản Cung kỵ bị coi là **sai định dạng** (trượt vì lý do sai, không phải vì thiếu luật), và `tools/xem_kich_ban.sh` cũng báo lỗi nên **tác giả không xem được kịch bản**. Vì vậy Task 2 (mở định dạng) đứng trước Task 3 (duyệt) — nhưng nó **không** phải là luật Cung kỵ: luật vẫn phải trượt ở Task 4 trước khi viết ở Task 5.
- `game/data/tran/thu_ba_tuong.json` đã có `C` ở (5,2) trong bàn thử; `test_loaders` chỉ nạp file, `test_battle_state` chỉ dựng bàn, không test nào khẳng định Cung kỵ đứng yên. Sau story, bàn này đổi hành vi — kiểm tay ở Task 7.3.
- Baseline lúc tạo story: **618/618 test đạt**, **81 kịch bản đã duyệt**, 2 chưa duyệt (`tran_01_loi_giai.json`, `tran_01_ne_o_do.json` của Story 2.14 — không phải việc của story này; đừng sửa, đừng đánh dấu duyệt).
- `EnemyAI.plan` chọn mục tiêu là **tướng gần nhất theo số bước** (hòa: ít máu hơn, rồi Bắc, rồi Đông); ô đứng là ô ít bước nhất mà từ đó đòn trúng. Cung kỵ dùng **nguyên** logic này, không thêm ưu tiên "hạ quân yếu máu" (đó là quyết định của người chơi, không phải AI).

### Luật phải cài, viết rõ để khỏi đoán

```
Cung kỵ báo đòn khi, và chỉ khi, ô đích:
  - thẳng hàng với ô đứng (cùng cột hoặc cùng hàng), và
  - cách 2 hoặc 3 ô (Manhattan = số ô, vì đã thẳng hàng), và
  - KHÔNG xét vật gì ở giữa: quân (phe nào cũng vậy) và địa hình đều không chặn ở story này.
Đòn ra: trúng đúng ô đích tại thời điểm ra đòn; ai đứng đó (bất kỳ phe) mất `sat_thuong` = 1; không đẩy.
Ô đích đi theo **chủ đòn** (offset tương đối): Cung kỵ bị đẩy/kéo thì ô đỏ dịch theo, ra ngoài bàn thì đòn bị hủy.
Ô đỏ: chỉ ô đích (không tô các ô trên đường).
```

Hệ quả cần nhớ: Cung kỵ **không** bắn được ô kề (cách 1) và **không** bắn quá 3 ô; đứng kề tướng thì nó chỉ đi/đứng và không báo đòn. Nếu mọi ô trong tầm đi đều không bắn được, nó đi tới ô gần tướng nhất (nhánh `CLOSEST` có sẵn).

### Kịch bản: định dạng và cách kiểm

- `bao_don` (có từ 2.8) nhận `{"thu_tu": n, "quan": "cột,hàng", "o": "cột,hàng"}` cho đòn vào ô, hoặc `"huong": "B|D|N|T"` cho xung phong. Story này dùng `"o"` cho Cung kỵ.
- `truoc.bao_don` = đòn đã báo sẵn lúc bắt đầu; `sau.bao_don` = đòn sau khi chạy lệnh; `sau.o_do` = **toàn bộ** ô đỏ (ô nào không ghi là phải không đỏ). `sau.mau` ghi theo **ô**.
- `ScenarioRunner.before_telegraphs` dựng `Telegraph` từ `truoc.bao_don` bằng `owner.id` (tìm quân ở ô `quan`), offset = ô đích − ô chủ đòn.
- Bộ nạp kiểm `"quan"` phải có **quân Nguyên** (ký hiệu `B`, `K`, `C`) trong `truoc.quan`/`sau.quan` tương ứng.
- **Thứ tự quân quyết định số thứ tự đòn:** id quân Nguyên theo thứ tự đọc bàn (trên→dưới, trái→phải) trừ khi có `thu_tu_dich`; `prepare` duyệt theo id tăng dần. Kịch bản nhiều quân (`ra_don_cung_ky_bay_qua_quan`) phải để `C` ở hàng **trên** `B` như bảng, hoặc ghi `thu_tu_dich` để cố định — sai thứ tự là sai số đòn (`#1`/`#2`).
- Trong kịch bản `don_dich/`, sau `ket_thuc_luot` là **cả** pha ra đòn **và** pha chuẩn bị hiệp mới → `sau` thường có thêm đòn mới; đừng quên (bài học 2.8).

### Nơi phải sửa, và nơi KHÔNG được sửa

| File | Việc |
|---|---|
| `game/src/core/stats.gd` | thêm `shoot_min_range`, `shoot_max_range` |
| `game/src/core/enemy_ai.gd` | `_has_attack_rule`, `can_hit_from` nhánh CUNG_KY, comment đầu file |
| `game/src/core/battle_state.gd` | `_telegraph_shape_problem` nhánh CELL |
| `game/src/data/scenario_loader.gd` | kiểm `"o"` theo ký hiệu quân |
| `game/src/core/enemy_intent.gd` | chỉ comment `NO_ATTACK_RULE` |
| `game/tests/…` | test cũ + test mới (Task 6, Testing) |
| **Không sửa** | `telegraph.gd`, `telegraph_marks.gd`, `rules_enemy_phase.gd`, `rules_*.gd` khác, `telegraph_view.gd`, `unit_token.gd`, `chi_so.json`, `game/data/tran/*` |

Nếu thấy phải sửa `RulesEnemyPhase` hay `TelegraphMarks` để Cung kỵ chạy được thì **dừng, báo lại**: gần như chắc chắn là hiểu sai luật (đòn `CELL` đã tổng quát).

### Testing

- Lệnh duy nhất: `tools/test.sh` (trong phiên AI: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`). Chạy một file:
  `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_enemy_ai.gd -gexit`
- GUT cần thêm trong Task 2/6:
  - `test_scenario_loader.gd`: `truoc.bao_don`/`sau.bao_don` với `C` + `o` thẳng hàng **2** và **3** ô → không lỗi; `C` + `o` **1** ô → lỗi; `C` + `o` chéo → lỗi; **`C` + `o` 4 ô → bộ nạp CHẤP NHẬN** (trần do `validate`, viết test đúng như vậy, đừng "sửa" cho ra lỗi).
  - `test_battle_state.gd`: `CUNG_KY` + `CELL (0,2)` và `(0,3)` hợp lệ; `(0,4)` sai với câu nêu tầm 2–3; `(0,1)` sai; `(1,1)` sai; chủ đòn đã gục + `(0,3)` hợp lệ; `BO_BINH` + `(0,2)` vẫn ra câu cũ `"… cần đúng một ô kề"`. Nhớ thêm `tam_ban_gan`/`tam_ban_xa` vào `_stats()` (và của `test_scenario_loader.gd`).
  - `test_enemy_ai.gd`: 4 ca ở Task 6.1.
  - `test_rules_enemy_phase.gd`: một ca `prepare` có cả Bộ binh và Cung kỵ → số thứ tự liền và đúng thứ tự id.
- Sau mỗi lần phân giải trong test: `state.validate()` phải rỗng.
- Ba ca `don_dich` (`o_do_cung_ky_khong_di_theo_tuong`, `don_cung_ky_dich_theo_khi_keo`, `huy_don_cung_ky_khi_chu_don_guc`) chốt hành vi **đã có** của `CELL` nên đạt ngay sau Task 2 — đúng chủ ý, không phải test yếu. Chúng bảo vệ AC 2 khỏi hồi quy khi E3 thêm chặn tên.
- Kịch bản mới tự được `ScenarioLoader.list_files()` nhặt; `test_determinism` tự chạy lại hai lần.

### Bẫy của story này

1. **Sửa luật trước khi tác giả duyệt kịch bản** — sai quy trình M3. Task 1–4 xong mới sang Task 5. (Task 2 chỉ là định dạng, không phải luật.)
2. **`da_duyet: true` khi tác giả chưa xem** — `test.sh` bước 2 sẽ khóa file đó ở commit, về sau không sửa được.
3. **Quên `BattleState.validate`** → kịch bản Cung kỵ trượt với câu "đòn của quân 101 đánh ô cách 0,2, cần đúng một ô kề", tưởng là lỗi luật.
4. **Quên khóa `tam_ban_*` trong `_stats()` của test** (`test_battle_state.gd`, `test_scenario_loader.gd`) → `Stats.value` assert nổ khi validate đọc tầm bắn.
5. **Hard-code số 3 trong bộ nạp hoặc trong `can_hit_from`** — số cân bằng phải đi qua `chi_so.json`.
6. **Cho tên bị chặn bởi quân ở giữa** (dễ nhầm với Kỵ binh): sai AC 2. Chặn bởi rừng/kho lương là Story 3.1, cũng chưa làm.
7. **Tô ô đỏ cả đường bay**: sai — chỉ ô đích.
8. **Dùng `Grid.distance` mà quên `straight_dir`**: ô chéo có Manhattan 2–3 sẽ bị coi là bắn được.
9. **Sửa kịch bản đã duyệt để test xanh**: cấm. Kịch bản đúng mà code sai thì sửa code; nghi kịch bản sai thì hỏi tác giả.

### Dùng lại, không viết lại

- **Lấy lớp chữ của `truoc`/`sau` bằng `BugReport.before_layers(snapshot)` / `after_layers(snapshot)`** (Story 2.13) chứ đừng chép tay 7 dòng × 7 cột — đây là cách 2.14 dựng kịch bản `tran/`.
- Không thêm chữ UI, không thêm khóa dịch: đòn Cung kỵ dùng đúng `TELEGRAPHED`/`ATTACKED`/`DAMAGED` có sẵn; F3 đọc `enemy_intents` có sẵn (chỉ đổi nội dung dòng, không đổi mã). `dev.ai.no_rule` giữ nguyên trong CSV dù từ story này không còn dùng.
- Không thêm API Godot mới — toàn bộ là GDScript thuần trong `RefCounted`; không cần tra Context7.
- `test_determinism` tự chạy mọi kịch bản hai lần; kịch bản Cung kỵ phải tất định (không `randi`, không duyệt Dictionary).

### Tài liệu tham chiếu

- Story nguồn: `_bmad-output/planning-artifacts/epics.md` § "Story 2.15: Cung kỵ (cắt được nếu trễ)" (dòng ~899).
- Luật Cung kỵ + AI: `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` bảng quân Nguyên (dòng ~176) và § Enemy AI (dòng ~218).
- Bảng thứ tự phân giải: `_bmad-output/planning-artifacts/game-architecture.md` (dòng ~841 bước 1b, ~844 dòng "Cung kỵ") và M1 Telegraph (dòng ~720).
- Mẫu đòn vào ô: `game/src/core/telegraph.gd`, `game/src/core/telegraph_marks.gd`, `game/src/core/rules_enemy_phase.gd`.

### Previous Story Intelligence (2.6–2.9, 2.14)

- 2.8/2.9: **đáp án mong đợi tính tay sai rất nhiều** — luôn tính bằng mô phỏng (script tạm) rồi mới viết file, và mô phỏng đó phải viết **độc lập** với code đang sửa (nếu không, kịch bản chỉ chép lại lỗi của code).
- 2.8: `prepare` chạy **cả** ở hiệp 1 (`begin_battle`), nên `truoc` của kịch bản phải là bàn **sau** pha chuẩn bị nếu kịch bản mở đầu bằng lượt người chơi.
- 2.8/2.9: commit **tách nhịp** — kịch bản chờ duyệt, rồi code. Story này ba nhịp: mở định dạng (Task 2), kịch bản đã duyệt (Task 3), luật (Task 5–7). Test `test.sh` đếm "chưa duyệt (chưa đạt)" nên khi kịch bản đã đúng luật mà chưa duyệt, con số "chưa đạt" về 0 dù chưa duyệt.
- 2.9: `_compare_telegraphs` chỉ so theo **số thứ tự** (ô chủ đòn + ô đích); đòn thừa cũng là lỗi → kịch bản `ai/` phải ghi đủ mọi đòn, kể cả đòn của quân khác.
- 2.9: `huy_don_*` dùng `TELEGRAPH_CANCELLED` + `BoardFixture.describe`; ca "chủ đòn gục" đã có mẫu cho Bộ binh — Cung kỵ chỉ cần cùng dạng.
- 2.6: F3 (`AiIntentOverlay`) đọc `enemy_intents` của bản chụp; đổi chữ thì sửa test chứ không nới test.
- 2.14 (đang dở): 2 kịch bản `tran/` **chưa duyệt** thuộc 2.14; không đụng, không đánh dấu duyệt, không gộp vào commit.

### Git Intelligence

- Commit gần nhất: `47651f3` (E8, hoạt ảnh — không thuộc story này), `e5c8a81` (review 2.14), `25cf3a0` (2.14), `d84518f` (tạo story 2.14).
- Mẫu lời commit: tiếng Việt, kết `(Story X.Y)`, có `Co-Authored-By`; nhịp **kịch bản chờ duyệt** rồi **code**.
- Cây làm việc chỉ có `img/pixellab-thu/toi_uu/thuyen/` chưa theo dõi — **không gộp**.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1; `src/core/` chỉ `RefCounted`, không `print`/`Node`/`Input`.
- Điểm vào luật duy nhất `Rules.resolve`; chỉ `Effects.damage`/`Effects.move` đổi máu/vị trí; đòn Cung kỵ **không** đẩy nên không gọi `ForcedMove`.
- Code + tên file tiếng Anh `snake_case`; dữ liệu/kịch bản tiếng Việt không dấu; log qua `Log.*` (không log trong vòng phân giải).
- Kịch bản luật là **spec**; `da_duyet` chỉ do tác giả chốt; `tools/test.sh` là lệnh duy nhất, xanh rồi mới commit.
- Nói với tác giả bằng tiếng Việt, chỉ các bước bấm và thấy gì; không bắt đọc code.

### Câu hỏi cho tác giả (không chặn code — luật đã có trong GDD, hỏi để chốt lại)

1. **Ô đích trống lúc đòn ra** (tướng đã đi khỏi ô đỏ): đòn vẫn "ra" vào ô đó, không ai mất máu, đúng không? Story đang làm vậy (luật "đánh vào ô").
2. **Tướng mình đứng giữa** Cung kỵ và ô đích: tên bay qua, tướng mình **không** trúng; nhưng nếu tướng mình **bị đẩy vào ô đỏ** thì trúng như mọi quân. Story đang làm vậy.

## Dev Agent Record

### Agent Model Used

DeepSeek Harness (deepseek-flash), 2026-10-22.

### Debug Log References

- **Nền trước story:** 618/618 test, 81 kịch bản đã duyệt, 2 chưa duyệt (từ 2.14).
- **Tính bàn bằng mô hình độc lập** (`game/tests/tmp_sim_215.gd`, đã xoá): tự viết `_can_hit`/`_plan`/`_prepare` theo luật trong story, không gọi `EnemyAI.plan` hay `RulesEnemyPhase.prepare`. Lần chạy đầu sai: áp luật "thẳng hàng 2–3 ô" cho **cả Bộ binh** → kịch bản `ra_don_cung_ky_bay_qua_quan` ra Bộ binh đứng yên và bắn 2 ô. Sửa: `_can_hit` theo `unit.type` (Bộ binh kề, Cung kỵ 2–3, Kỵ binh xuyên hàng). Chạy lại khớp tay từng ca.
- **Kịch bản hủy đòn sai thiết kế lần đầu:** bàn chỉ có 1 quân Nguyên nên hạ Cung kỵ là **thắng ngay**, lệnh `ket_thuc_luot` bị từ chối `tran_da_het` và `telegraphs` bị xoá — không còn gì để hủy. Sửa: thêm Bộ binh ở (0,0) để trận tiếp diễn; ca này đạt ngay sau Task 2 (hành vi `CELL` có sẵn).
- **Trước Task 2**, 8 kịch bản bị bộ nạp coi là sai định dạng (`"o" ... không kề "quan"`) — đúng như story dự đoán; `tools/xem_kich_ban.sh` cũng không chạy được.
- **Sau Task 2**, `tools/test.sh`: **620/620 đạt**, 81 đã duyệt · 10 chưa duyệt · **4 chưa đạt** — cả 4 trượt vì *chưa có luật Cung kỵ*, đúng lý do:
  - `ai/cung_ky_di_toi_tam_ban`: "sau: ô 3,0 mong đợi trống, thực tế C".
  - `ai/cung_ky_dung_yen_ban`: "sau: đòn 1 mong đợi quân ở 3,3 đánh ô 3,6, thực tế không có đòn 1".
  - `don_dich/ra_don_cung_ky_trung_tuong`: "… thực tế không có đòn 1".
  - `don_dich/ra_don_cung_ky_bay_qua_quan`: "… thực tế quân ở 3,5 đánh ô 3,6" (Bộ binh chiếm số 1 vì Cung kỵ chưa báo đòn).
- **4 kịch bản đạt ngay sau Task 2** (đúng chủ ý, chốt hành vi có sẵn): `o_do_cung_ky_khong_di_theo_tuong`, `don_cung_ky_dich_theo_khi_keo`, `huy_don_cung_ky_khi_chu_don_guc`, `ai/cung_ky_dung_ke_khong_ban`.
- 2 test GUT mới (định dạng + bất biến) đã chạy: `test_battle_state.gd` 109 test cùng `test_scenario_loader.gd` đều đạt.

### Completion Notes List

- Story đang dừng ở **cổng duyệt kịch bản (Task 3)**: 8 kịch bản đã viết, đã đưa tác giả xem bằng `tools/xem_kich_ban.sh ai` và `don_dich`, chờ trả lời "đúng"/"sai: …". Chưa viết luật Cung kỵ.
- Phần định dạng (Task 2) **không phải luật**: chưa làm Cung kỵ biết bắn; 4 kịch bản vẫn trượt đúng vì thiếu luật.
- `Truoc.bao_don` của 5 kịch bản `don_dich` do mô hình tạm sinh, đã đối chiếu `xem_kich_ban.sh`: cột "Ô ĐỎ" hiện đúng ô 3,6 trước khi chạy lệnh.
- `thu_ba_tuong.json` có `C` ở (5,2): chưa kiểm tay (Task 7.3), sẽ làm sau khi có luật.

### File List

Đã sửa:
- `game/src/core/stats.gd` — `shoot_min_range`, `shoot_max_range`.
- `game/src/core/battle_state.gd` — `_cell_telegraph_problem` cho `CELL` (Bộ binh kề / Cung kỵ 2–3 / chủ đòn đã gục).
- `game/src/data/scenario_loader.gd` — `_check_telegraph_target` kiểm `"o"` theo ký hiệu quân.
- `game/tests/test_battle_state.gd` — khóa `tam_ban_*` + `test_validate_accepts_archer_long_shot_only`.
- `game/tests/test_scenario_loader.gd` — khóa `tam_ban_*` + `test_archer_telegraph_target_is_straight_and_far`.

Thêm mới (kịch bản, `da_duyet: false`):
- `game/tests/kich_ban/ai/cung_ky_dung_yen_ban.json`
- `game/tests/kich_ban/ai/cung_ky_di_toi_tam_ban.json`
- `game/tests/kich_ban/ai/cung_ky_dung_ke_khong_ban.json`
- `game/tests/kich_ban/don_dich/ra_don_cung_ky_trung_tuong.json`
- `game/tests/kich_ban/don_dich/ra_don_cung_ky_bay_qua_quan.json`
- `game/tests/kich_ban/don_dich/o_do_cung_ky_khong_di_theo_tuong.json`
- `game/tests/kich_ban/don_dich/don_cung_ky_dich_theo_khi_keo.json`
- `game/tests/kich_ban/don_dich/huy_don_cung_ky_khi_chu_don_guc.json`

### Change Log

- 2026-10-22: Viết 8 kịch bản Cung kỵ bằng mô hình tạm độc lập; mở định dạng đòn bắn xa (Stats, `BattleState.validate`, `ScenarioLoader`) + 2 test GUT. Dừng chờ tác giả duyệt kịch bản.
