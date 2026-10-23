---
baseline_commit: f770d73
---

# Story 3.3: Trận 2

Status: done

## Story

Là tác giả,
tôi muốn trận 2 dạy dùng rừng chặn Kỵ binh và cho địch đánh trúng nhau,
để người chơi học luật mới từng bước.

## Acceptance Criteria

1. **Cho** `game/data/tran/tran_02.json` được nạp **thì** bàn đúng 6 cột × 7 hàng, `kieu` là `tieu_diet`, có đúng **2 tướng** Nguyễn Khoái (`1`) và Phạm Ngũ Lão (`2`), đúng **2 Kỵ binh** (`K`) + **1 Bộ binh** (`B`), có **cả rừng (`#`) và sông (`~`)**; `thu_tu_dich` liệt kê đủ ô quân Nguyên theo đúng thứ tự đọc bàn (hàng trên → dưới, trái → phải); `tiep_vien` và `muu_ke_mo` rỗng; **không** có `so_hiep_toi_da`, `long_dan`.
2. **Cho** `game/data/tran/tran_02_loi_giai.md` **thì** có sơ đồ bàn, lời giải không mất tướng (FR43) chi tiết **từng nước** như trận 1, và chỉ rõ ba chỗ dạy luật: Kỵ binh báo hướng rồi lao tới vật đầu tiên (né ô đỏ), rừng chặn đường lao (đâm vào rừng, không ai mất máu), và quân Nguyên đánh trúng nhau (Kỵ binh lao qua ô có quân Nguyên khác).
3. **Khi** tác giả đánh lại đúng lời giải **thì** thắng, **cả hai tướng còn đủ 3/3 máu** (không tướng nào gục, không tướng nào mất máu).
4. **Sau khi tác giả xác nhận**, lời giải được chuyển thành `game/tests/kich_ban/tran/tran_02_loi_giai.json` với `da_duyet: true`, dựng từ **bàn thật sau pha chuẩn bị của hiệp 1** (không chép tay), có `ket_qua: "thang"` và máu **3/3** cho cả hai tướng; `tools/test.sh` phát lại kịch bản này mỗi lần chạy.
5. **Và** trận chỉ giới thiệu đúng luật của dòng 2 bảng Campaign Structure: Kỵ binh xung phong, rừng chặn đường lao, địch đánh trúng nhau. **Không** dùng luật của trận sau: không hầm chông (`^`), không làng/Lòng dân (`D`), không kho lương (`L`), không giới hạn hiệp, không mưu kế, không tiếp viện. **Không** sửa `src/core/`, `chi_so.json`, hay kịch bản đã duyệt khác.
6. **Và** `tools/test.sh` xanh; story và `sprint-status.yaml` được cập nhật; commit tiếng Việt kết `(Story 3.3)`.

## Tasks / Subtasks

- [x] **Task 1: Chốt câu hỏi với tác giả** (AC: 1, 2, 5)
  - [x] 1.1 Hỏi 5 câu trước khi khoá bàn (tên trận, cỡ bàn, vai trò sông, mức chi tiết lời giải, kịch bản trận 1 đang chờ duyệt).
  - [x] 1.2 Chốt: tên **Trận 2 — Ải Lãnh Kinh**; bàn **6×7** (rộng 6, cao 7); sông **chỉ làm tường chắn**, không dùng chết đuối trong lời giải; lời giải **từng nước**; **không** đụng 2 kịch bản `da_duyet: false` của trận 1.

- [x] **Task 2: Thiết kế `tran_02.json` và tự chơi thử** (AC: 1, 3)
  - [x] 2.1 Dựng bàn 6×7: Khoái `1` ở `2,4`; Lão `2` ở `2,6`; rừng `#` ở `2,5`; sông `~` ở `4,5` và `5,5`.
  - [x] 2.2 Quân Nguyên: Kỵ binh `K` ở `2,0` và `5,4`; Bộ binh `B` ở `1,4`. `thu_tu_dich` theo thứ tự đọc bàn: `2,0`, `1,4`, `5,4`.
  - [x] 2.3 Tự chơi bằng `tools/chay.sh --dev --tran=2` (phiên AI: dựng bàn và chạy đúng luật thật bằng công cụ tạm, đã xoá sau khi dùng) tới khi thắng không mất tướng.
  - [x] 2.4 Kiểm ngược: bỏ ô rừng `2,5` rồi phát lại đúng lời giải → Kỵ binh `2,0` lao trúng Lão ở `2,6` ngay hiệp 1 (mất máu, và về sau Lão gục). Vậy rừng là **bắt buộc**, không phải trang trí.

- [x] **Task 3: Viết `tran_02_loi_giai.md`** (AC: 2)
  - [x] 3.1 Sơ đồ bàn đầu trận (sau pha chuẩn bị hiệp 1) + bàn sau từng hiệp, từng bước bấm như trận 1.
  - [x] 3.2 Giải thích rõ: vì sao Lão đứng sau rừng là an toàn; vì sao Kỵ binh `5,4` lao trúng Bộ binh `1,4` (địch đánh nhau); vì sao Khoái phải né ô đỏ trước khi hạ chủ đòn.
  - [x] 3.3 Trình tác giả bàn + từng bước + chỗ dạy luật; **dừng, chờ tác giả đánh lại và xác nhận**.

- [x] **Task 4: Tác giả đánh lại và xác nhận** (AC: 3)
  - [x] 4.1 Tác giả chạy `tools/chay.sh --dev --tran=2`, đánh đúng lời giải, thấy bảng Thắng và cả hai tướng 3/3.
  - [x] 4.2 Chưa xác nhận thì **không** tạo kịch bản `da_duyet: true`.

- [x] **Task 5: Chuyển lời giải thành kịch bản tự động** (AC: 4)
  - [x] 5.1 Dựng `tran_02_loi_giai.json` từ **bàn thật sau pha chuẩn bị hiệp 1**: `truoc.dia_hinh`, `truoc.quan`, `truoc.thu_tu_dich`, `truoc.bao_don` (đòn đã báo thật), rồi đúng chuỗi `hanh_dong` đã duyệt.
  - [x] 5.2 `sau` ghi bàn cuối: chỉ còn hai tướng ở ô cuối, `mau` 3/3 cho cả hai, `ket_qua: "thang"`, `da_di`/`da_danh` đúng.
  - [x] 5.3 `mo_ta` nói rõ "không mất tướng"; `da_duyet: true` **chỉ sau khi tác giả xác nhận**.
  - [x] 5.4 `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh` xanh, kịch bản mới tự chạy và đạt.

- [x] **Task 6: Chốt story, sprint, commit** (AC: 6)
  - [x] 6.1 Cập nhật story (Debug Log, Completion Notes, File List, Change Log), `sprint-status.yaml` 3-3 → `review`/`done`.
  - [x] 6.2 Commit từng phần, lời tiếng Việt, kết `(Story 3.3)`; không gộp `img/` hay việc của story khác.

## Dev Notes

### Hiện trạng trước story này (đọc trước khi sửa)

- **Luật Kỵ binh đã có từ Story 2.6:** `EnemyAI.plan` chọn ô đứng rồi báo đòn; Kỵ binh báo `Telegraph.Kind.DIRECTION`; `TelegraphMarks.path_cells` đi từ ô trước mặt tới **vật đầu tiên** (quân bất kỳ phe, `CHARGE_BLOCKERS` = rừng, kho lương, làng; sông không chắn); `RulesEnemyPhase._strike_all` gây sát thương cho quân ở ô trúng, **mọi phe**. Vì vậy "địch đánh trúng nhau" không cần luật mới — chỉ cần bàn đặt đúng tình huống.
- **Rừng chặn lao** (Story 3.1): `Terrain.ATTACK_BLOCKERS` = rừng, kho lương; `EnemyAI.can_hit_from` nhánh Kỵ binh cũng dừng ở `CHARGE_BLOCKERS`; `TelegraphMarks.path_cells` dừng ở rừng. **Không sửa code** cho story này.
- Kịch bản mẫu: `game/tests/kich_ban/don_dich/ra_don_ky_binh_trung_rung.json` (đã duyệt) — Kỵ binh lao vào rừng, không ai mất máu.
- Mẫu trận 1: `game/data/tran/tran_01.json`, `tran_01_loi_giai.md`, `game/tests/kich_ban/tran/tran_01_loi_giai.json` (`da_duyet: false` — **để nguyên**).
- Baseline lúc tạo story: `tools/test.sh` → 644/644 test, 96 kịch bản đã duyệt, 0 trượt (HEAD `04d4b27`); trong lúc làm, phiên khác commit thêm hoạt ảnh/demo, HEAD thành `f770d73`.
- Chưa có (đừng tự thêm): gợi ý luật đầu trận (4.8), làng/Lòng dân (3.7), giới hạn hiệp (3.5), hầm chông (3.4), mưu kế (3.12–3.13), kho lương/tiếp viện (3.9–3.10).

### Thiết kế bàn (đã chốt với tác giả 2026-10-23)

```
     0 1 2 3 4 5
  0  . . K . . .      Kỵ binh 1 (2,0)
  1  . . . . . .
  2  . . . . . .
  3  . . . . . .
  4  . B 1 . . K      Bộ binh (1,4), Khoái (2,4), Kỵ binh 2 (5,4)
  5  . . # . ~ ~      rừng (2,5), sông (4,5) và (5,5)
  6  . . 2 . . .      Lão (2,6)
```

- Cỡ 6×7; `thu_tu_dich`: `["2,0", "1,4", "5,4"]` (đọc bàn: hàng 0 trước, rồi hàng 4 trái→phải).
- **Vì sao bàn dạy đúng:**
  - Kỵ binh `2,0` lao thẳng cột 2 xuống Khoái `2,4`; Bộ binh `1,4` đánh ô kề; Kỵ binh `5,4` lao ngang hàng 4 sang trái. Cả ba cùng nhắm Khoái ở `2,4` — người chơi buộc phải đọc ô đỏ và né.
  - Lão `2,6` đứng **sau rừng** `2,5`: Kỵ binh `2,0` không thể lao xuyên rừng. Khi Khoái né khỏi cột 2, đường lao của Kỵ binh `2,0` đi tiếp và **dừng ở rừng** — Lão không mất máu. Bỏ rừng đi thì đòn đó trúng Lão ngay hiệp 1.
  - Khi Khoái né khỏi hàng 4, đường lao của Kỵ binh `5,4` đi tiếp và **trúng Bộ binh `1,4`** — địch đánh trúng nhau, Bộ binh mất 1 máu.
- **Lời giải đã chơi thử (15 lệnh, 6 hiệp, thắng, hai tướng 3/3):** xem `tran_02_loi_giai.md`. Không dùng chết đuối, không đẩy ai xuống sông; sông chỉ là tường.

### Chỗ phải sửa, và chỗ KHÔNG được sửa

| File | Việc |
|---|---|
| `game/data/tran/tran_02.json` | bàn mới |
| `game/data/tran/tran_02_loi_giai.md` | lời giải tay |
| `game/tests/kich_ban/tran/tran_02_loi_giai.json` | kịch bản tự động (chỉ sau khi tác giả xác nhận) |
| `_bmad-output/implementation-artifacts/3-3-tran-2.md` | story |
| `_bmad-output/implementation-artifacts/sprint-status.yaml` | trạng thái |
| **Không sửa** | `src/core/*`, `game/data/chi_so.json`, `tran_01*`, 2 kịch bản `tran/tran_01_*` (`da_duyet: false`), mọi kịch bản đã duyệt khác |

Nếu thấy phải sửa `src/core/` thì **dừng, hỏi tác giả**: trận 2 chỉ dùng luật đã có.

### Testing

- `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh` — lệnh duy nhất; kịch bản `tran/tran_02_loi_giai.json` tự được nhặt.
- `tools/chay.sh --dev --tran=2` — chơi tay trận 2; đúng lời giải phải ra bảng Thắng, hai tướng 3/3.
- `tools/xem_kich_ban.sh tran` — xem bàn kịch bản trận.
- Kịch bản `tran/` chạy qua `BattleController` như game thật (kể cả `sau.mau`).

### Bẫy của story này

1. **`truoc` của kịch bản là bàn SAU pha chuẩn bị hiệp 1**, không phải bàn trong `tran_02.json`: quân Nguyên đã đi, `bao_don` đã có. Lệch một ô là kịch bản đỏ.
2. **`thu_tu_dich` sai thứ tự** → quân đi khác, lời giải hỏng. Phải đúng thứ tự đọc bàn.
3. **Kịch bản đã duyệt bị khoá theo commit** (`tools/test.sh` bước 2): sửa file `da_duyet: true` phải có tác giả duyệt lại.
4. **Không chép tay bàn `truoc` từ trí nhớ** — dựng từ bàn thật sau `begin()`.
5. **Phiên khác có thể `git checkout` xoá thay đổi chưa commit** — commit ngay từng phần (bài học 3.1).
6. **Đừng thêm luật mới** (hầm chông, làng, kho lương, giới hạn hiệp, mưu kế, tiếp viện) để "cho khó": trận 2 chỉ dạy 3 luật của dòng 2.

### Previous Story Intelligence (3.1, 3.2, 2.14)

- 3.1: commit ngay sau mỗi phần; kiểm ngược bằng bản sao `/tmp`, không `git checkout`.
- 3.2: kịch bản/`validate()`/`clone()` là lưới an toàn; đừng tạo cơ chế mới khi đã có.
- 2.14: `tran_01` có lời giải 3 hiệp + nhánh né ô đỏ; mẫu trình bày lời giải (sơ đồ, từng bước, "vì sao trận này dạy đúng bài").

### Git Intelligence

- HEAD lúc tạo story: `b7d1f60`; trong lúc làm, phiên khác commit thêm 3 commit hoạt ảnh/demo, HEAD thành `f770d73`. Trước khi commit story, chạy lại toàn bộ test trên HEAD mới.
- Mẫu commit: tiếng Việt, kết `(Story X.Y)`; không gộp `img/`.

### Project Context Rules

- Không sửa `src/core/`; con số cân bằng chỉ trong `chi_so.json`; dữ liệu trận chỉ trong `game/data/tran/`.
- Kịch bản luật là spec; `da_duyet` chỉ do tác giả chốt; `tools/test.sh` xanh rồi mới commit.
- Nói với tác giả bằng tiếng Việt, bằng bàn cờ chữ và các bước bấm.

### Câu hỏi cho tác giả (đã chốt 2026-10-23)

1. **Tên trận:** chốt **Trận 2 — Ải Lãnh Kinh** (theo gợi ý GDD).
2. **Cỡ bàn:** chốt **6×7** (rộng 6, cao 7).
3. **Sông:** chốt **chỉ làm tường chắn**, không dạy lại chết đuối; lời giải không đẩy ai xuống sông.
4. **Mức chi tiết:** chốt **từng nước** như trận 1.
5. **2 kịch bản trận 1 đang `da_duyet: false`:** chốt **không đụng**, việc riêng.

## Dev Agent Record

### Agent Model Used

DeepSeek Harness (deepseek-flash), 2026-10-23.

### Debug Log References

- **Nền trước story:** `tools/test.sh` 644/644, 96 kịch bản đã duyệt, 0 trượt (HEAD `04d4b27`); phiên khác thêm 3 commit hoạt ảnh/demo trong lúc làm, cần xác nhận lại test trên `f770d73`.
- **Dựng bàn:** thử nhiều bố cục bằng công cụ tạm chạy đúng `Rules`/`BattleController` (headless); bàn chốt là bàn duy nhất buộc cả ba luật cùng lộ ra trong một hiệp đầu.
- **Bàn sau pha chuẩn bị hiệp 1 (đúng như game):**
  - Kỵ binh `2,0` → Khoái `2,4` (đòn 1, hướng Nam, đỏ cột 2 từ `2,1` tới `2,4`).
  - Bộ binh `1,4` → ô `2,4` (đòn 2).
  - Kỵ binh `5,4` → Khoái `2,4` (đòn 3, hướng Tây, đỏ `3,4`, `4,4`, `2,4`).
- **Lời giải (15 lệnh, 6 hiệp):** xem `tran_02_loi_giai.md`; kết thúc `THẮNG`, Khoái `3/3`, Lão `3/3`.
- **Kiểm ngược rừng:** bỏ `#` ở `2,5` rồi phát lại đúng lời giải → hiệp 1 Kỵ binh `2,0` lao trúng Lão `2,6` (Lão còn 2 máu), về sau Lão gục, không thắng. Vậy rừng **bắt buộc**.
- **Kiểm ngược địch đánh nhau:** hiệp 1, sau khi Khoái né, đường lao `5,4` đi tiếp tới `1,4` và Bộ binh mất 1 máu (sự kiện `MẤT MÁU` của quân 102).
- **Tác giả xác nhận (2026-10-23):** đã chạy `tools/chay.sh --dev --tran=2`, đánh đúng 15 nước, thắng, Khoái 3/3, Lão 3/3.
- **Kịch bản tự động:** sinh từ bàn thật sau `begin()` (đọc bàn + `state.telegraphs`, không chép tay); tự kiểm bằng `ScenarioRunner` → ĐẠT; đặt `da_duyet: true`.
- **Xanh cuối:** `tools/test.sh` → 644/644 test, **97 kịch bản đã duyệt**, 0 trượt; bước 2 khoá `da_duyet` đạt (97 file).

### Completion Notes List

- **AC 1–6 xong.** Bàn `tran_02.json`: 6×7, đúng 2 tướng (Khoái `1` ở `2,4`, Lão `2` ở `2,6`), 2 Kỵ binh (`2,0`, `5,4`) + 1 Bộ binh (`1,4`), rừng `2,5`, sông `4,5` + `5,5`, `kieu: tieu_diet`, `thu_tu_dich` đúng thứ tự đọc bàn, `tiep_vien`/`muu_ke_mo` rỗng, không `so_hiep_toi_da`/`long_dan`.
- **Lời giải 15 lệnh, 6 hiệp, thắng, Khoái 3/3, Lão 3/3.** Ba bài lộ ra ngay trong hiệp 1: né ba ô đỏ; Kỵ binh `2,0` lao vào rừng `2,5` (Lão đứng sau rừng); Kỵ binh `5,4` lao trúng Bộ binh `1,4` của nó (địch đánh nhau).
- **Tác giả đã đánh lại và xác nhận thắng, hai tướng 3/3** (2026-10-23) trước khi kịch bản được đặt `da_duyet: true`.
- **Kịch bản** `game/tests/kich_ban/tran/tran_02_loi_giai.json` sinh từ **bàn thật sau pha chuẩn bị hiệp 1** (đọc `state` + `state.telegraphs`, không chép tay), `da_duyet: true`, `ket_qua: "thang"`, `mau` 3/3 cho `4,4` và `1,4`, `da_danh: ["1"]`, `da_di: []`.
- **Không sửa** `src/core/`, `chi_so.json`, `tran_01*`, 2 kịch bản `tran/tran_01_*` (`da_duyet: false`), kịch bản đã duyệt khác. Không thêm luật mới (không hầm chông/làng/kho lương/giới hạn hiệp/mưu kế/tiếp viện).
- **Kiểm ngược rừng:** bỏ `#` ở `2,5` rồi phát lại đúng 15 lệnh → hiệp 1 Kỵ binh `2,0` lao trúng Lão `2,6` (Lão còn 2 máu), về sau Lão gục, không thắng. Rừng là **bắt buộc**.
- **Kiểm ngược địch đánh nhau:** hiệp 1, sau khi Khoái né, đường lao `5,4` đi tiếp tới `1,4`; sự kiện `MẤT MÁU` của quân 102 (Bộ binh) chứng minh B mất 1 máu vì đòn của Kỵ binh cùng phe.
- **Xanh cuối:** `XDG_DATA_HOME=/tmp/dsh-xdg tools/test.sh` → **644/644 test**, **97 kịch bản đã duyệt**, 0 trượt; bước 2 khoá `da_duyet` đạt với 97 file.

### File List

- `game/data/tran/tran_02.json` (mới)
- `game/data/tran/tran_02_loi_giai.md` (mới)
- `game/tests/kich_ban/tran/tran_02_loi_giai.json` (mới, `da_duyet: true`)
- `_bmad-output/implementation-artifacts/3-3-tran-2.md` (mới)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (3-3 → done)

### Change Log

- 2026-10-23: chốt 5 câu hỏi; dựng `tran_02.json` (6×7, Ải Lãnh Kinh); viết lời giải 15 lệnh thắng 3/3; kiểm ngược rừng bắt buộc. Chờ tác giả đánh lại.
- 2026-10-23 (sau xác nhận): tác giả đánh lại đúng lời giải → thắng, hai tướng 3/3. Sinh kịch bản từ bàn thật, đặt `da_duyet: true`; `tools/test.sh` xanh 644/644, 97 kịch bản đã duyệt. Story → `done`.
