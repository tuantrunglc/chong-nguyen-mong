---
baseline_commit: 1fbbf6f
---

# Story 3.1: Rừng và vật cản chặn đòn

Status: done

## Story

Là người chơi,
tôi muốn rừng và kho lương che chắn được đòn đánh,
để dùng địa hình chặn Kỵ binh và Cung kỵ.

## Acceptance Criteria

1. **Cho** rừng hoặc kho lương nằm giữa Phạm Ngũ Lão và mục tiêu, **kể cả ở ô kề** **khi** phóng lao **thì** lao bị chặn, mục tiêu không mất máu (FR13).
2. **Khi** Kỵ binh xung phong vào rừng hoặc kho lương **thì** đòn dừng ở vật cản, không ai mất máu (FR19).
3. **Khi** có rừng hoặc kho lương nằm giữa Cung kỵ và ô đã báo **thì** tên bị chặn (FR20). Chỉ tính **lúc báo**: nếu chủ đòn bị đẩy/kéo sau đó làm vật cản rơi vào giữa thì đòn đã báo vẫn trúng ô (tác giả chốt 2026-10-23).
4. **Khi** vật đầu tiên trên hàng của Trần Khánh Dư là rừng hoặc kho lương **thì** không kéo được, không có viền "đánh được" về hướng đó (FR14).
5. **Và** có kịch bản trong `dia_hinh/` (rừng), tác giả duyệt **trước khi viết luật** (quy trình M3); `tools/test.sh` xanh.
6. **Và** làng (ô `D`) **không** thuộc story này: phần chặn lao/tên/kéo của làng và Lòng dân làm ở Story 3.7. Kỵ binh đã dừng ở làng từ Story 2.6 — giữ nguyên, không gỡ.

(Va chạm khi bị đẩy vào rừng hoặc kho lương đã có từ Story 2.1; story này chỉ thêm phần **chặn đòn**.)

## Tasks / Subtasks

- [x] **Task 1: Khảo sát hiện trạng và viết kịch bản chờ duyệt** (AC: 1–5)
  - [x] 1.1 Đọc và ghi lại hiện trạng vào Debug Log: cái gì **đã có** (Kỵ binh dừng ở rừng/kho lương từ 2.6, kịch bản `don_dich/ra_don_ky_binh_trung_rung.json` đã phủ), cái gì **thiếu** (lao, kéo, tên).
  - [x] 1.2 Viết các kịch bản dưới đây với `"da_duyet": false`. Bàn 7×7, địa hình `.` trừ chỗ ghi. Kỳ vọng phải tính bằng mô hình độc lập hoặc bằng tay từng ô, **không** chép từ code sắp sửa (bài học 2.8/2.9/2.15).
  - [x] 1.3 Chạy `tools/xem_kich_ban.sh dia_hinh` cho tác giả xem; **dừng, chờ duyệt**.

  **Nhóm `dia_hinh/`:**

  | File | Bàn trước | Lệnh | Điều phải thấy |
  |---|---|---|---|
  | `rung_chan_lao.json` | Lão `2` ở (3,6), Bộ binh `B` ở (3,2), rừng `#` ở (3,4) | `danh` tướng 2 vào `3,2`, `tu_choi: "khong_co_dich"` | Không có viền/không lao được vì rừng chắn giữa; Bộ binh vẫn **3 máu**; bàn không đổi |
  | `rung_chan_lao_o_ke.json` | Lão (3,6), Bộ binh (3,2), rừng ở **(3,5)** (ô kề Lão) | như trên | Rừng ở ô kề cũng chặn (AC 1 nói rõ "kể cả ở ô kề") |
  | `kho_luong_chan_lao.json` | Lão (3,6), Bộ binh (3,2), kho lương `L` ở (3,4) | như trên | Kho lương cũng chặn — không chỉ cài rừng |
  | `rung_chan_keo.json` | Dư `3` ở (3,6), Bộ binh `B` ở (3,3), rừng ở (3,5) và (3,4)? — **rừng ở (3,5)** là vật đầu tiên trên hàng | `danh` tướng 3 vào `3,3`, `tu_choi: "khong_co_dich"` | Không kéo được; Bộ binh đứng yên, **không mất máu**; Dư **không** tính đã đánh (`da_danh: []`) |
  | `rung_chan_ten.json` | Cung kỵ `C` ở (3,3), rừng ở (3,4), Khoái `1` ở (3,6) | `ket_thuc_luot` | Cung kỵ **không báo đòn** (`sau.bao_don: []`, `o_do: {}`); nó đi tới ô gần Khoái nhất (tính cụ thể khi làm); Khoái **3 máu** |
  | `rung_chan_xung_phong.json` | Kỵ binh `K` ở (0,3) xung phong hướng Đông, rừng ở (2,3), Khoái `1` ở (3,3) | `ket_thuc_luot` | Đòn dừng ở rừng: **không ai mất máu**; `sau` không có `mau` |

  - [x] 1.4 Đối chiếu: kịch bản `rung_chan_xung_phong` **có thể đạt ngay** (AC 2 đã có từ 2.6) — đó là điều mong đợi, là chốt hồi quy. Bốn ca còn lại phải trượt trước Task 4–5.
  - [x] 1.5 Không sửa `don_dich/ra_don_ky_binh_trung_rung.json` (đã duyệt) — nó là bằng chứng AC 2 có sẵn.

- [x] **Task 2: Tác giả duyệt kịch bản** (AC: 5)
  - [x] 2.1 Khi tác giả nói "duyệt": đổi `"da_duyet": true` cho đúng file đã xem.
  - [x] 2.2 Commit riêng phần kịch bản.

- [x] **Task 3: Chứng minh trượt** (AC: 1–4)
  - [x] 3.1 `tools/test.sh`: 4 kịch bản mới phải trượt vì **chưa có luật chặn** (không phải lỗi định dạng); `rung_chan_xung_phong` đạt. Ghi dòng trượt đầu tiên vào Debug Log.
  - [x] 3.2 Nếu ca lao hiện **đạt** (tức code đã chặn sẵn) thì dừng, báo lại — có thể hiện trạng khác giả định.

- [x] **Task 4: Chặn lao của Phạm Ngũ Lão** (AC: 1)
  - [x] 4.1 `game/src/core/rules_attack.gd::_lao_targets`: quét từ **d=1** (ô kề) tới `max_range`; gặp `FOREST`/`GRANARY` thì **dừng hướng đó** (không thêm ô, kể cả quân Nguyên phía sau). Quân Nguyên phía trước vật cản mới có viền.
  - [x] 4.2 `lao_throw`: giữ nguyên vòng quét từ `min_range` tới ô đích, nhưng thêm kiểm phòng thủ: nếu gặp vật cản trước khi gặp quân thì **không gây sát thương** (dữ liệu lệch `targets` thì trả về, không `assert`). Ghi comment Story 3.1.
  - [x] 4.3 Hằng số dùng chung: đặt `BLOCKERS` ở một chỗ (ví dụ `Terrain` hoặc `RulesAttack`) gồm `FOREST`, `GRANARY` — **không** gồm `VILLAGE` (3.7). `EnemyAI.CHARGE_BLOCKERS` đã có `VILLAGE` từ 2.6, **không đổi**.
  - [x] 4.4 Test GUT: rừng ở ô kề / ở giữa / sau mục tiêu (không chặn); kho lương; sông **không** chặn.

- [x] **Task 5: Chặn kéo của Trần Khánh Dư và chặn tên của Cung kỵ** (AC: 3, 4)
  - [x] 5.1 `rules_attack.gd::_du_targets`: trong vòng quét d=1..`pull_range`, nếu ô là `FOREST`/`GRANARY` thì `break` hướng đó (vật đầu tiên không kéo được). `du_pull` không cần đổi: mục tiêu hợp lệ thì đường kéo đã sạch vật cản phía trước.
  - [x] 5.2 `game/src/core/enemy_ai.gd::can_hit_from` nhánh `CUNG_KY`: nếu có `FOREST`/`GRANARY` nằm giữa (không tính ô đứng, không tính ô đích) thì `false`. Dùng cùng hằng số với Task 4.3.
  - [x] 5.3 **Câu hỏi 1 chưa chốt:** tên có bị chặn **lúc ra đòn** khi Cung kỵ bị đẩy/kéo làm vật cản vào giữa đường không? Mặc định của story: **chỉ chặn lúc báo** (ô đỏ đã báo thì tên vẫn trúng), vì AC nói về lúc báo và đòn "gắn với ô". Nếu tác giả muốn chặn lúc ra đòn thì thêm kiểm trong `RulesEnemyPhase._strike_all` + kịch bản riêng (việc lớn hơn, phải hỏi trước).
  - [x] 5.4 Sửa test cũ `test_rules_attack.gd::test_pull_blocked_by_forest_collides_before_story_3_1`: đổi tên và kỳ vọng thành "rừng là vật đầu tiên → `NO_TARGET`, không ai mất máu", hoặc bỏ nếu kịch bản `rung_chan_keo` đã phủ (kịch bản là spec, test GUT giữ ca biên).
  - [x] 5.5 Test GUT: Dư với rừng ở d=1, d=2, sau mục tiêu; Cung kỵ với rừng/kho lương chắn giữa, và cùng đường nhưng vật cản **sau** ô đích (không chặn).

- [x] **Task 6: Test cũ và hồi quy** (AC: 1–4)
  - [x] 6.1 `grep -rn "Story 3.1" game/` — mọi comment "Story 3.1" đang chờ phải khớp code sau khi làm (gồm `rules_attack.gd`, `telegraph.gd`, `telegraph_marks.gd`, `forced_move.gd`).
  - [x] 6.2 Chạy toàn bộ `tools/test.sh`: các kịch bản đã duyệt khác (lao, kéo, địa hình) không được đổi kết quả. Nếu có kịch bản cũ trượt vì luật mới → **dừng, báo tác giả** (có thể kịch bản cũ mâu thuẫn spec mới).

- [x] **Task 7: Xanh, kiểm ngược, chạy tay, commit** (AC: 1–6)
  - [x] 7.1 `tools/test.sh` xanh (phiên AI: `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh`).
  - [x] 7.2 Kiểm ngược: (a) bỏ kiểm vật cản trong `_lao_targets` → kịch bản lao trượt; (b) bỏ kiểm trong `_du_targets` → kịch bản kéo trượt; (c) bỏ kiểm trong `can_hit_from` → kịch bản tên trượt; (d) đổi `BLOCKERS` thành chỉ `FOREST` → kịch bản kho lương trượt. Khôi phục từng cái; **file chưa commit thì sao lưu trước, đừng `git checkout`** (bài học 2.15).
  - [x] 7.3 Chạy tay `tools/chay.sh --dev --tran=thu_ba_tuong` (bàn có rừng ở (1,1) và (1,4)? kiểm lại) hoặc `--tran=thu_lao`: xem viền mục tiêu của Lão biến mất khi rừng chắn; chụp cửa sổ game nếu GoPeak không nối (`DISPLAY=:1 import -window <id>`).
  - [x] 7.4 Commit kịch bản (sau duyệt) và code **riêng**; lời tiếng Việt, kết `(Story 3.1)`. Không gộp `img/` hay việc của story khác.

### Review Findings

_Code review 3 lớp (Blind Hunter, Edge Case Hunter, Acceptance Auditor) trên diff 11 file, 2026-10-23. Kết quả: 4 `decision_needed`, 7 `patch`, 3 `defer`, 3 bỏ. **Không AC nào KHÔNG ĐẠT.**_

**Đã chốt và sửa (2026-10-23, `ea5633a` + `726a8df` + kịch bản + tài liệu):**

- [x] [Review][Decision] Tên chỉ bị chặn **lúc báo** — tác giả chốt giữ; AC 3 ghi rõ; khóa bằng `test_reported_archer_shot_is_not_blocked_afterwards` (đòn đã báo vẫn trúng dù rừng ở giữa).
- [x] [Review][Decision] Lý do khi bị chặn — thêm `BattleEvent.Reject.BLOCKED`, mã kịch bản `bi_chan`, câu "đòn bị rừng hoặc kho lương chặn trước ô x,y"; cập nhật `ScenarioLoader` (REJECT_CODES, REJECT_LIST, COMMAND_REJECTS), `ScenarioRunner.REJECT_EVENTS`, `BugReport.REJECT_CODES`, bản dịch; 4 kịch bản đổi sang `bi_chan`.
- [x] [Review][Decision] Sửa kịch bản đã duyệt — trả lại `truoc.bao_don` cho `rung_chan_xung_phong` (đòn xung phong có thật) + sửa `mo_ta` "(2,2)"; thêm kịch bản dương `vat_can_sau_muc_tieu` (rừng sau mục tiêu, lao vẫn trúng); tooltip rừng/kho thêm "Chặn lao, tên, kéo".
- [x] [Review][Decision] Kiến trúc — `game-architecture.md` sửa làng chặn lao/tên/kéo sang Story 3.7.

- [x] [Patch] `lao_throw` quét từ d=1 (bay qua quân trước `min_range`, chặn mọi vật cản) — cùng biên với `_lao_targets` [game/src/core/rules_attack.gd]
- [x] [Patch] Comment `EnemyAI.can_hit_from` sửa: không xét quân, nhưng rừng/kho lương chặn [game/src/core/enemy_ai.gd]
- [x] [Patch] Comment `_lao_targets` sửa: "quân trước `min_range` bị bay qua", không viết cứng "ô kề" [game/src/core/rules_attack.gd]
- [x] [Patch] Thêm test "vật cản chỉ chặn hướng của nó" (lao + kéo, hướng Đông vẫn đánh được) [game/tests/test_rules_attack.gd]
- [x] [Patch] Thêm ca Dư bị kho lương chặn và tên bị chặn ở khoảng cách 2 [game/tests/test_rules_attack.gd, game/tests/test_enemy_ai.gd]
- [x] [Patch] Ca "vật cản sau mục tiêu" của lao đổi sang trong tầm (Lão `3,6` → B `3,4`, rừng `3,3`) [game/tests/test_rules_attack.gd]
- [x] [Patch] Comment "Tầm bắn đọc từ chi_so.json" trả về đúng test stats [game/tests/test_enemy_ai.gd]

- [x] [Review][Defer] Kéo qua **làng** vẫn gây 1 máu va chạm [game/src/core/rules_attack.gd] — deferred, Story 3.7 thêm làng + Lòng dân
- [x] [Review][Defer] Không có test khóa "làng KHÔNG chặn lao/tên/kéo" (AC 6) [game/src/core/terrain.gd] — deferred, 3.7 sẽ đổi hành vi làng
- [x] [Review][Defer] Nhánh va chạm khi kéo mất test trực tiếp [game/tests/test_rules_attack.gd] — deferred cùng 3.7

## Dev Notes

### Hiện trạng trước story này (đọc trước khi sửa)

- **Kỵ binh xung phong — AC 2 ĐÃ CÓ từ Story 2.6:** `EnemyAI.CHARGE_BLOCKERS = [FOREST, GRANARY, VILLAGE]` dùng ở `can_hit_from` (Kỵ binh) và `TelegraphMarks.path_cells` (dừng ở ô vật cản, `hit_cell` = ô vật cản; ô đó không có quân nên không ai mất máu). Kịch bản `game/tests/kich_ban/don_dich/ra_don_ky_binh_trung_rung.json` (đã duyệt) phủ đúng AC này. **Không sửa code Kỵ binh**; chỉ thêm kịch bản `dia_hinh/rung_chan_xung_phong.json` làm chốt hồi quy (ca rừng ở ô kề/giữa).
- **Lao — AC 1 THIẾU:** `RulesAttack._lao_targets` quét `d` từ `stats.min_range` (2) tới `max_range` (4), **không** kiểm địa hình; comment đầu hàm đã ghi "Story 3.1: gặp rừng, kho lương, làng … thì dừng hướng đó" nhưng code chưa làm. `lao_throw` cũng không kiểm: nó trúng quân đầu tiên trong tầm.
- **Kéo — AC 4 THIẾU:** `RulesAttack._du_targets` quét d=1..`pull_range`, chỉ quan tâm quân; rừng/kho lương hiện **không** phải vật chặn ở bước chọn mục tiêu, nên Dư vẫn kéo được quân đứng sau rừng — quân đó bị `ForcedMove` chặn giữa đường và **mất 1 máu**. Test `test_pull_blocked_by_forest_collides_before_story_3_1` đang khẳng định đúng hành vi cũ này; story này phải đổi nó.
- **Tên — AC 3 THIẾU:** `EnemyAI.can_hit_from` nhánh `CUNG_KY` (Story 2.15) chỉ kiểm thẳng hàng + tầm, **không** xét vật giữa. `TelegraphMarks.path_cells` của `CELL` chỉ trả ô đích nên phần vẽ/ô đỏ không có gì để sửa **nếu** chỉ chặn lúc báo.
- **Làng:** `ForcedMove.OBSTACLES` và `CHARGE_BLOCKERS` đã có `VILLAGE`; đó là va chạm/xung phong có từ trước. Story này **không** thêm làng vào chặn lao/tên/kéo — để Story 3.7 (Lòng dân).
- **Sông không chặn** lao/tên (GDD); `Terrain.RIVER` không nằm trong bất kỳ danh sách chặn nào.
- Baseline lúc tạo story: **626/626 test**, 89 kịch bản đã duyệt, 2 chưa duyệt (`tran/` của 2.14 — không phải việc của story này).

### Luật phải cài, viết rõ để khỏi đoán

```
VẬT CHẶN của story này: RỪNG (#) và KHO LƯƠNG (L). Sông, hầm chông, ải, làng: không (làng ở 3.7).
LAO (Lão):
  - Quét từ ô KỀ (d=1) ra tới max_range.
  - Trong một hướng: vật chặn gặp TRƯỚC quân Nguyên đầu tiên → hướng đó không có mục tiêu.
  - Vật chặn nằm SAU quân Nguyên đầu tiên → không ảnh hưởng (lao trúng quân trước).
  - Bấm vào ô bị chặn → lệnh bị từ chối `khong_co_dich`; Lão không tính đã đánh.
KÉO (Dư):
  - Vòng quét d=1..pull_range: gặp vật chặn → dừng hướng, không có viền, không kéo.
  - Không có chuyện "kéo tới sát vật chặn rồi va chạm" nữa (đó là hành vi trước 3.1).
TÊN (Cung kỵ):
  - Khi chọn ô đứng/báo đòn: vật chặn nằm giữa ô đứng và ô đích → ô đó không bắn được.
  - "Giữa" là các ô từ ô sau lưng chủ đòn tới trước ô đích; không tính ô chủ đòn, không tính ô đích.
XUNG PHONG (Kỵ binh): đã đúng từ 2.6, chỉ kiểm lại.
LÝ DO TỪ CHỐI: địch đúng ô đích nhưng bị vật cản chặn trước → `Reject.BLOCKED`, mã kịch bản `bi_chan`,
câu "đòn bị rừng hoặc kho lương chặn trước ô x,y". Ô trống/không phải đích vẫn là `khong_co_dich`.

```

### Chỗ phải sửa, và chỗ KHÔNG được sửa

| File | Việc |
|---|---|
| `game/src/core/rules_attack.gd` | `_lao_targets`, `lao_throw` (phòng thủ), `_du_targets`; khai báo `BLOCKERS` dùng chung |
| `game/src/core/enemy_ai.gd` | `can_hit_from` nhánh `CUNG_KY` |
| `game/tests/test_rules_attack.gd` | đổi ca rừng chắn kéo; thêm ca biên lao/kéo |
| `game/tests/test_enemy_ai.gd` | ca Cung kỵ bị vật cản chắn |
| `game/tests/kich_ban/dia_hinh/` | 6 kịch bản mới |
| **Không sửa** | `telegraph.gd`, `telegraph_marks.gd`, `rules_enemy_phase.gd`, `forced_move.gd`, `grid.gd`, `chi_so.json`, `game/data/tran/*`, kịch bản đã duyệt khác |

Nếu thấy phải sửa `TelegraphMarks`/`_strike_all` để AC 3 chạy được thì **dừng, hỏi tác giả** — đó là Câu hỏi 1 (chặn lúc ra đòn), không phải mặc định của story.

### Testing

- Lệnh duy nhất `tools/test.sh`; chạy một file GUT:
  `.tools/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64 --headless --path game -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/test_rules_attack.gd -gexit`
- GUT cần thêm:
  - `test_rules_attack.gd`: lao bị rừng ở d=1, d=2, kho lương, rừng sau mục tiêu (không chặn), sông không chặn; kéo bị rừng ở d=1/d=2, rừng sau mục tiêu; kéo qua sông vẫn chết đuối (đã có, không đổi).
  - `test_enemy_ai.gd`: `can_hit_from` Cung kỵ với rừng/kho lương giữa; vật cản sau ô đích không chặn; khoảng cách 2 và 3 ô.
- Kịch bản mới tự được nhặt; `test_determinism` chạy lại 2 lần.

### Bẫy của story này

1. **Quét lao từ `min_range`** thay vì d=1 → bỏ sót rừng ở ô kề (đúng ca AC nói rõ).
2. **Cho vật cản chặn cả khi nó ở sau mục tiêu** → Lão mất mục tiêu oan.
3. **Thêm `VILLAGE` vào `BLOCKERS`** → lấn Story 3.7 (Lòng dân), và làm sai kịch bản hiện có.
4. **Sửa `CHARGE_BLOCKERS`** (Kỵ binh) — nó đã đúng từ 2.6, gồm cả làng; đụng vào là hồi quy.
5. **Nghĩ "tên bị chặn lúc ra đòn" là mặc định** — story chốt chỉ chặn lúc báo; muốn khác phải hỏi (Câu hỏi 1).
6. **Đổi test cũ bằng cách nới kỳ vọng** thay vì đổi theo luật mới: test `test_pull_blocked_by_forest_collides_before_story_3_1` phải thành "không kéo được", không phải xoá.
7. **Quên `da_duyet`**: kịch bản phải được duyệt trước khi viết luật (M3), và sau khi commit thì `test.sh` bước 2 khóa file.
8. **Dùng `git checkout` để khôi phục sau kiểm ngược khi file chưa commit** — mất luật vừa viết (đã xảy ra ở 2.15). Sao lưu ra `/tmp` trước.

### Previous Story Intelligence (2.15, 2.14, 2.9)

- 2.15: kịch bản viết bằng mô hình tạm độc lập rồi mới viết luật; 4 ca đạt ngay vì chốt hành vi có sẵn — ở story này `rung_chan_xung_phong` là ca như vậy.
- 2.15: `_read_side` đã có `Stats`; bộ nạp kiểm tầm bắn đúng theo `chi_so.json`. Không hard-code số cân bằng.
- 2.15: sau khi sửa file đã `da_duyet`, phải commit thì `test.sh` bước 2 mới hết báo "kịch bản đã duyệt bị sửa".
- 2.9/2.8: `sau` của kịch bản kết thúc bằng `ket_thuc_luot` thường có thêm đòn mới của pha chuẩn bị; nhớ ghi `hiep` khi muốn khóa số hiệp.
- 2.6: `prepare` chạy cả hiệp 1; `truoc` của kịch bản là bàn sau pha chuẩn bị.

### Git Intelligence

- Commit gần nhất: `1fbbf6f` (ghi kết quả 2.14), `db3610c` (chốt review 2.15), `690d5a9`, `47a02b2`.
- Mẫu: commit kịch bản đã duyệt riêng, commit code riêng; lời tiếng Việt, kết `(Story X.Y)`.
- Cây làm việc có thay đổi `img/` của phiên E8/khác — **không gộp**.

### Project Context Rules

- Godot 4.7.2, GDScript tĩnh kiểu, GUT 9.7.1; `src/core/` chỉ `RefCounted`, không `print`/`Node`/`Input`.
- Điểm vào luật duy nhất `Rules.resolve`; chỉ `Effects.damage`/`Effects.move` đổi máu/vị trí; đẩy/kéo qua `ForcedMove`.
- Con số cân bằng chỉ trong `data/chi_so.json`; chặn địa hình là luật cố định (không phải số cân bằng), đặt làm hằng số có tên.
- Kịch bản luật là spec; `da_duyet` chỉ do tác giả chốt; `tools/test.sh` xanh rồi mới commit.

### Câu hỏi cho tác giả

1. **Tên bị chặn lúc ra đòn?** Nếu Cung kỵ bị đẩy/kéo sau khi báo, và rừng/kho lương rơi vào giữa nó với ô đỏ, tên có bị chặn không? Story đang mặc định **chỉ chặn lúc báo** (đòn đã báo vẫn trúng ô), theo câu chữ AC 3 và luật "đòn gắn với ô". Muốn chặn cả lúc ra đòn thì phải sửa `_strike_all` + thêm kịch bản, nói trước khi làm.
2. **Làng:** xác nhận làng **không** chặn lao/tên/kéo trong story này, để dành Story 3.7 (Lòng dân). Kỵ binh vẫn dừng ở làng như từ 2.6.

## Dev Agent Record

### Agent Model Used

DeepSeek Harness (deepseek-flash), 2026-10-23.

### Debug Log References

- **Nền trước story:** 626/626 test, 89 kịch bản đã duyệt, 2 chưa duyệt (của 2.14).
- **Hiện trạng khảo sát:** Kỵ binh xung phong **đã** dừng ở rừng/kho lương/làng từ Story 2.6 (`EnemyAI.CHARGE_BLOCKERS` + `TelegraphMarks.path_cells`; kịch bản `don_dich/ra_don_ky_binh_trung_rung.json` đã duyệt) → AC 2 chỉ cần kịch bản chốt hồi quy. **Thiếu:** lao (`_lao_targets`/`lao_throw` không kiểm địa hình), kéo (`_du_targets`), tên (`can_hit_from` CUNG_KY).
- **Trước khi có luật:** 5 kịch bản mới trượt đúng lý do — 3 ca lao và ca kéo báo "kịch bản ghi `tu_choi: khong_co_dich` nhưng luật cho chạy"; `rung_chan_ten` báo "ô 3,3 mong đợi trống, thực tế C" (Cung kỵ báo đòn xuyên rừng). `rung_chan_xung_phong` **đạt ngay** đúng như dự kiến (AC 2 có sẵn).
- **Lỗi kịch bản bắt được khi làm luật:** bàn `rung_chan_ten` đã duyệt vây Cung kỵ bằng 3 ô sông + rừng, nên nó **không có đường tới tướng** (`NO_PATH`) — đứng yên vì lý do khác, không chứng minh tên bị chặn. Đã báo và được tác giả duyệt bỏ 3 ô sông (giữ rừng ở `3,4`); bàn sau tính lại bằng mô hình tạm độc lập: Cung kỵ đi tới **(4,5)**, không báo đòn, Khoái đủ máu.
- **Luật:** hằng số `Terrain.ATTACK_BLOCKERS = [FOREST, GRANARY]` (làng để 3.7). `_lao_targets` quét từ **d=1** để bắt vật cản ở ô kề nhưng vẫn bay qua quân ở ô kề; vật cản **sau** mục tiêu không chặn. `lao_throw` thêm kiểm phòng thủ. `_du_targets` dừng hướng khi vật đầu tiên là vật cản. `EnemyAI.can_hit_from` nhánh CUNG_KY kiểm vật cản giữa (không tính ô đứng/ô đích).
- **Test cũ:** `test_pull_blocked_by_forest_collides_before_story_3_1` đổi thành `test_pull_blocked_by_forest_is_not_a_target` (`REJECTED NO_TARGET`, mục tiêu đứng yên, không mất máu, Dư không tính đã đánh). Thêm ca GUT: lao (ô kề, kho lương, sau mục tiêu, sông), kéo (ô kề, sau mục tiêu), tên (rừng, kho lương, ngay sau chủ đòn, sau ô đích, sông).
- **Kiểm ngược 4 đường (khôi phục bằng bản sao `/tmp`, không `git checkout`):** (a) bỏ chặn lao → `rung_chan_lao`, `rung_chan_lao_o_ke`, `kho_luong_chan_lao` trượt; (b) bỏ chặn kéo → `rung_chan_keo` trượt; (c) bỏ chặn tên → `rung_chan_ten` trượt ("thừa đòn 1", ô đỏ 3,6); (d) `ATTACK_BLOCKERS` chỉ còn `FOREST` → `kho_luong_chan_lao` trượt. Cả 4 khôi phục, xanh lại.
- **Kiểm tay:** bàn tạm `thu_rung_31` (đã xoá, không commit): **có rừng** ở (3,4) → Cung kỵ đi tới (4,5), **không có ô đỏ**; **bỏ rừng** → Cung kỵ đứng (3,3), ô đỏ "1" trên Khoái. Ảnh: `build/test/shot_31_co_rung.png`, `build/test/shot_31_khong_rung.png` (`build/` bị gitignore).
- **Xanh cuối:** `tools/test.sh` → **629/629**, 95 kịch bản đã duyệt, 0 chưa đạt.
- **Code review 3 lớp (2026-10-23):** 4 `decision_needed` + 7 `patch`; không AC nào không đạt. Phát hiện nặng: (a) kịch bản `rung_chan_xung_phong` mất `truoc.bao_don` nên **không có đòn xung phong** — đã trả lại và sửa `mo_ta`; (b) AC 3 mơ hồ "chặn lúc nào" — tác giả chốt **chỉ lúc báo**, có test khóa; (c) lý do từ chối `khong_co_dich` sai khi bị địa hình chắn — thêm `bi_chan`.
- **Sửa kèm khi thêm `bi_chan`:** `REJECT_LIST`, `COMMAND_REJECTS["danh"]`, `BugReport.REJECT_CODES`, `ScenarioRunner.REJECT_EVENTS`, CSV `scenario.viewer.reject_blocked`; 4 kịch bản đổi `tu_choi`; 2 test kỳ vọng danh sách mã.
- **Biến cố môi trường:** một phiên khác `git checkout` xoá các thay đổi **chưa commit** (rules_attack, battle_event, test_rules_attack, …) lúc ~09:53; đã áp lại và commit ngay từng phần (`ea5633a`, `726a8df`, kịch bản). Bài học: trong phiên có nhiều người, commit ngay sau mỗi phần.
- **Xanh cuối:** `tools/test.sh` → **632/632**, 96 kịch bản đã duyệt, 0 chưa đạt.

### Completion Notes List

- **AC 1–5 xong.** AC 6 chỉ là ràng buộc phạm vi: **không** thêm làng vào chặn lao/tên/kéo (để Story 3.7); Kỵ binh vẫn dừng ở làng như từ 2.6.
- **Không sửa** `TelegraphMarks`, `RulesEnemyPhase`, `ForcedMove`, `chi_so.json`, `game/data/tran/*`, kịch bản đã duyệt khác.
- **Câu hỏi 1 giữ mặc định:** tên chỉ bị chặn **lúc báo**; đòn đã báo vẫn trúng ô dù Cung kỵ bị đẩy/kéo sau đó. Muốn chặn cả lúc ra đòn thì là việc riêng, cần tác giả yêu cầu.
- **Câu hỏi 2:** làng chưa chặn lao/tên/kéo — để 3.7.
- Đã xoá bàn thử tạm `game/data/tran/thu_rung_31.json` sau khi chụp ảnh; `git status` sạch ngoài các file của story.
- **Sau code review:** tên chỉ chặn lúc báo (có test khóa); lý do bị chặn có mã riêng `bi_chan`; kịch bản xung phong đã có đòn thật; thêm ca dương `vat_can_sau_muc_tieu`; tooltip nói rõ chặn đòn; kiến trúc sửa làng → 3.7. 3 `defer` ghi trong `deferred-work.md`.

### File List

- `game/src/core/terrain.gd` — `ATTACK_BLOCKERS` (rừng, kho lương).
- `game/src/core/rules_attack.gd` — chặn lao (`_lao_targets`, `lao_throw`), chặn kéo (`_du_targets`).
- `game/src/core/enemy_ai.gd` — `can_hit_from` nhánh CUNG_KY kiểm vật cản giữa.
- `game/tests/test_rules_attack.gd` — đổi ca kéo-qua-rừng; thêm ca lao/kéo biên.
- `game/tests/test_enemy_ai.gd` — `test_archer_arrow_blocked_by_terrain` (thêm ca cách 2).
- `game/src/core/battle_event.gd` — `Reject.BLOCKED`.
- `game/src/debug/bug_report.gd` — ánh xạ `BLOCKED` → `bi_chan`.
- `game/i18n/text.csv` — `scenario.viewer.reject_blocked`, tooltip rừng/kho nói chặn đòn.
- `game/tests/test_rules_enemy_phase.gd` — khóa "tên chỉ chặn lúc báo".
- `game/tests/test_scenario_loader.gd` — kỳ vọng danh sách mã có `bi_chan`.
- `game/tests/kich_ban/dia_hinh/vat_can_sau_muc_tieu.json` (mới).
- `game/tests/kich_ban/dia_hinh/rung_chan_lao.json`, `rung_chan_lao_o_ke.json`, `kho_luong_chan_lao.json`, `rung_chan_keo.json`, `rung_chan_ten.json`, `rung_chan_xung_phong.json` (mới, đã duyệt).
- `_bmad-output/planning-artifacts/game-architecture.md` — làng chặn lao/tên/kéo sang Story 3.7.
- `_bmad-output/implementation-artifacts/deferred-work.md` — 3 mục hoãn của review 3.1.
- `_bmad-output/implementation-artifacts/3-1-rung-va-vat-can-chan-don.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Change Log

- 2026-10-23: 6 kịch bản `dia_hinh/` (5 trượt đúng lý do, ca xung phong đạt ngay), tác giả duyệt; sửa bàn `rung_chan_ten` sau khi phát hiện nó vây kín Cung kỵ (được tác giả duyệt). Viết luật chặn lao/kéo/tên; kiểm ngược 4 đường; kiểm tay bằng ảnh có/không rừng. `tools/test.sh` xanh 629/629. Story → `review`.
- 2026-10-23 (sau code review): tác giả chốt 4 điểm (tên chỉ chặn lúc báo; thêm mã `bi_chan`; sửa kịch bản + thêm ca dương + tooltip; sửa kiến trúc). Sửa 7 patch + 4 quyết định; `tools/test.sh` xanh 632/632, 96 kịch bản đã duyệt. Story → `done`.
