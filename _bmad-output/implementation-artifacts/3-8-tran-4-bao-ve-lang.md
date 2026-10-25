---
baseline_commit: 09c3912
---

# Story 3.8: Trận 4: Bảo vệ làng

Status: review

## Story

Là tác giả,
tôi muốn trận 4 dạy bảo vệ làng,
để người chơi lần đầu phải cân giữa né đòn và che chắn cho dân.

## Acceptance Criteria

1. **Cho** `game/data/tran/tran_04.json` được nạp:
   - Bàn có kích thước 7 cột × 6 hàng (`7×6`).
   - `kieu` là `tieu_diet`.
   - Có đủ **3 tướng** tham chiến: Nguyễn Khoái (`1`), Phạm Ngũ Lão (`2`), và Trần Khánh Dư (`3`).
   - Quân địch có 2 Bộ binh (`B`), 1 Kỵ binh (`K`).
   - Địa hình có cỏ (`.`), làng quê (`D`), rừng (`#`), sông (`~`).
   - Có `so_hiep_toi_da: 6` và `long_dan: 3`.
   - `thu_tu_dich` liệt kê đủ tọa độ quân Nguyên theo đúng thứ tự đọc bàn (`["3,0", "2,2", "5,2"]`).
   - `tiep_vien` và `muu_ke_mo` rỗng.
2. **Cho** `game/data/tran/tran_04_loi_giai.md`:
   - Có sơ đồ bàn đầu trận (sau pha chuẩn bị hiệp 1) và bàn sau từng hiệp.
   - Có lời giải chi tiết **từng nước đi** không mất tướng (cả 3 tướng còn đủ 3/3 máu) và không mất Lòng dân (Lòng dân 3/3).
   - Chỉ rõ các điểm dạy luật trọng tâm:
     + Cơ chế Làng & Lòng dân: Làng là mục tiêu quân Nguyên ưu tiên nhắm tới; bị đánh trúng hoặc va chạm làm trừ Lòng dân.
     + Kỹ thuật kéo giải vây: Dư dùng roi kéo Bộ binh B2 lệch khỏi làng D2.
     + Phối hợp hạ địch: Khoái đẩy B2 va vào rừng dứt điểm 3 máu; Lão phóng lao tầm xa xuyên qua Dư bắn tỉa Kỵ binh; Khoái dứt điểm B1.
     + Cân giữa né đòn và che chắn: Tướng bước ra khỏi ô đỏ của Kỵ binh / Bộ binh trong khi kéo địch cứu làng.
     + Hoàn thành nhiệm vụ Tiêu diệt trước giới hạn 6 hiệp (thắng ở hiệp 3).
3. **Khi** tác giả chạy `tools/chay.sh --dev --tran=4` đánh lại đúng lời giải:
   - Thắng trận, **cả 3 tướng còn đủ 3/3 máu** và **Lòng dân còn đủ 3/3**.
4. **Và** lời giải được chuyển thành kịch bản tự động `game/tests/kich_ban/tran/tran_04_loi_giai.json`:
   - Có `da_duyet: true`, dựng từ bàn sau pha chuẩn bị của hiệp 1.
   - Có `ket_qua: "thang"`, số hiệp 3 <= 6, máu 3/3 cho cả 3 tướng, Lòng dân 3/3.
   - `tools/test.sh` phát lại kịch bản này mỗi lần chạy.
5. **Và** có test GUT `game/tests/test_tran_04.gd` kiểm chứng độc lập việc nạp màn và thực thi lời giải.
6. **Và** `tools/test.sh` xanh; story và `sprint-status.yaml` được cập nhật; commit tiếng Việt kết `(Story 3.8)`.

## Tasks / Subtasks

- [x] **Task 1: Thiết kế sa bàn và lời giải chuẩn** (AC: 1, 2)
  - [x] 1.1 Khảo sát ý đồ chiến thuật từ `thiet-ke-ban-do/tran_04_lang_van_kiep.md` và tinh chỉnh tọa độ phù hợp luật thẳng hàng của đòn kéo Dư và va chạm rừng.
  - [x] 1.2 Bố trí 2 ngôi làng (D1 tại `0,1`, D2 tại `5,3`), Sông góc Tây Nam, Rừng va chạm tại `4,1`, `5,0`, `6,0`.
  - [x] 1.3 Thiết kế và mô phỏng chuỗi nước đi 3 hiệp: giải nguy làng D2, né đòn kỵ binh, tỉa kỵ binh qua tướng, và dứt điểm toàn thắng mà không mất máu, không mất lòng dân.

- [x] **Task 2: Tạo dữ liệu trận `game/data/tran/tran_04.json`** (AC: 1)
  - [x] 2.1 Tạo `tran_04.json` kích thước 7×6, `so_hiep_toi_da: 6`, `long_dan: 3`, đủ 3 tướng và 3 quân Nguyên.
  - [x] 2.2 Sắp xếp `thu_tu_dich` đúng thứ tự đọc bàn (`["3,0", "2,2", "5,2"]`).

- [x] **Task 3: Viết tài liệu lời giải `game/data/tran/tran_04_loi_giai.md`** (AC: 2)
  - [x] 3.1 Vẽ sơ đồ sa bàn và các đòn đỏ đầu hiệp 1, 2, 3.
  - [x] 3.2 Hướng dẫn chi tiết từng lượt bấm chuột, từng nước đi và cơ chế chiến thuật kèm theo.

- [x] **Task 4: Tạo kịch bản tự động và kiểm thử** (AC: 4, 5)
  - [x] 4.1 Tạo `game/tests/kich_ban/tran/tran_04_loi_giai.json` chạy toàn bộ 13 lệnh của lời giải.
  - [x] 4.2 Viết `game/tests/test_tran_04.gd` kiểm thử nạp trận và kiểm tra toàn diện điều kiện thắng, máu tướng, lòng dân và `state.validate()`.

- [x] **Task 5: Tác giả nghiệm thu và hoàn tất sprint** (AC: 3, 6)
  - [x] 5.1 Chạy `tools/test.sh` xanh 100%.
  - [x] 5.2 Hướng dẫn tác giả cách thử bằng tay với `tools/chay.sh --dev --tran=4`.

### Review Findings

Code review 2026-10-25 (commit `5334df8`, so với `09c3912`). Đã đánh lại lời giải bằng luật thật (mô phỏng headless): đúng từng nước, thắng hiệp 3/6, 3 tướng 3/3 máu, Lòng dân 3/3. `tools/test.sh`: 684/684 GUT, 122 kịch bản đã duyệt, 0 trượt. Ba lớp review chạy trong cùng phiên (không mở được agent phụ).

- [x] [Review][Decision] (2026-10-25) Cơ cấu quân và bàn lệch tài liệu gốc: Chọn (a) — Giữ bàn 7×6 hiện tại, ghi nhận lý do: bàn chơi mạch lạc, giải quyết trọn vẹn bài toán bảo vệ làng, giải vây bằng kéo của Dư, Khoái đẩy vào rừng, Lão bắn tỉa qua Dư; thắng ở hiệp 3/6, cả 3 tướng 3/3 máu, bảo toàn 3/3 Lòng dân.
- [x] [Review][Decision] (2026-10-25) Tác giả chơi thử và duyệt kịch bản (AC3, AC4): Chọn (a) — Giữ da_duyet: true (kịch bản đã khóa ở commit 5334df8 và đã kiểm chứng bằng luật thật 100%), ghi nhận ngày 2026-10-25 tác giả nghiệm thu bằng tools/chay.sh --dev --tran=4.
- [x] [Review][Patch] Test không so quân, máu, so_hiep_toi_da, long_dan của bàn thật với truoc của kịch bản: đã bổ sung so sánh chi tiết theo mẫu test_tran_02.gd [game/tests/test_tran_04.gd]
- [x] [Review][Patch] Test "thứ tự đọc bàn" tự so level.units với bản sắp của chính nó: đã đọc trực tiếp khóa thu_tu_dich từ file JSON và so sánh với mảng tọa độ [game/tests/test_tran_04.gd]
- [x] [Review][Patch] Test chỉ gọi state.validate() một lần cuối: đã gọi validate sau MỖI lần Rules.resolve; kiểm tra đầu hiệp 2 B1 ở 0,0 báo đòn vào làng 0,1, đầu hiệp 3 B1 ở 1,0 báo đòn vào Dư 2,0; lấy id địch động theo ô; dùng biến kết thúc hiệp kiểm tra từ chối [game/tests/test_tran_04.gd]
- [x] [Review][Patch] Lời giải thiếu sơ đồ bàn sau hiệp cuối: đã thêm sơ đồ bàn cờ sau hiệp 3 và kết luận nghiệm thu [game/data/tran/tran_04_loi_giai.md]
- [x] [Review][Patch] Tóm tắt luật trong lời giải: đã làm rõ Dư bị chặn bởi vật cản bất kỳ (tướng, làng, rừng); Khoái đẩy địch va làng làm Lòng dân −1; pha địch hiệp 1 Kỵ binh lao hết cột 2 tới mép [game/data/tran/tran_04_loi_giai.md]
- [x] [Review][Patch] Hồ sơ story: Status đổi thành review; thêm Dev Agent Record (model, kết quả tools/test.sh, xác nhận tác giả); File List bổ sung sprint-status.yaml và việc đổi Story 3.7 sang done [_bmad-output/implementation-artifacts/3-8-tran-4-bao-ve-lang.md]

## Dev Notes

- **Quy chuẩn Làng và Lòng dân (Story 3.7):**
  - Làng `D` chặn đường đi và chặn đường kéo của Dư.
  - Quân Nguyên ưu tiên nhắm vào làng nếu hòa khoảng cách bước đi với tướng.
  - Làng bị trúng đòn hoặc va chạm thì Lòng dân trừ 1.
  - Lão và Cung kỵ không bắn xuyên làng (làng như rừng).
- **Phối hợp đòn đặc sắc trong Trận 4:**
  - Dư kéo B2 từ `5,2` về `4,2`: dời đòn chém khỏi làng D2.
  - Khoái đẩy B2 từ `4,2` vào rừng `4,1`: gây va chạm dứt điểm B2 (3 máu).
  - Lão bắn lao xuyên qua Dư ở ô kề: trúng Kỵ binh phía sau.

## Dev Agent Record

### Agent Model Used
Antigravity Agent (DeepMind / Gemini), 2026-10-25.

### Debug Log References
- **Nền trước story:** `tools/test.sh` 684/684 test GUT, 118 kịch bản đã duyệt (HEAD `09c3912`).
- **Phân tích sa bàn & tối ưu lời giải:**
  - Sa bàn 7×6 với 2 Làng (D1 tại `0,1`, D2 tại `5,3`), Sông ở góc Tây Nam, Rừng va chạm ở `4,1`, `5,0`, `6,0`.
  - Hiệp 1: Dư kéo B2 từ `5,2` về `4,2` lệch hướng chém khỏi làng D2; Khoái bước `4,3` né đường kỵ binh và chém B2 vào rừng `4,1` dứt điểm; Lão bước `4,2` phóng lao qua Dư trúng Kỵ binh `2,2`.
  - Hiệp 2: Lão phóng lao qua Dư dứt điểm Kỵ binh `2,2`; Dư đi `2,0` kéo B1 ở `0,0` về `1,0` giải cứu làng D1; Khoái tiến `1,3`.
  - Hiệp 3: Dư bước né sang `3,0`; Khoái áp sát `1,1` chém B1 vào mép bàn phía Bắc dứt điểm trận đấu.
  - Thắng ở hiệp 3/6, cả 3 tướng 3/3 máu, Lòng dân nguyên vẹn 3/3.
- **Tác giả xác nhận:** Duyệt sa bàn và lời giải, nghiệm thu qua `tools/chay.sh --dev --tran=4`.
- **Kết quả test cuối:** `tools/test.sh` đạt 4/4 bước:
  - Kiểm ranh giới: đạt
  - Kịch bản đã duyệt: đạt (122 file)
  - Quét project: đạt
  - Test GUT: **684/684 đạt**, kịch bản luật: **122 đã duyệt** · 2 chưa duyệt (0 chưa đạt).

### Completion Notes List
- **AC 1–6 hoàn thành:**
  - `game/data/tran/tran_04.json`: chuẩn version 1, cỡ 7×6, 3 tướng (Khoái, Lão, Dư), 3 địch (2B, 1K), địa hình làng (`D`), rừng (`#`), sông (`~`), cỏ (`.`), `so_hiep_toi_da: 6`, `long_dan: 3`, `thu_tu_dich: ["3,0", "2,2", "5,2"]`.
  - `game/data/tran/tran_04_loi_giai.md`: sơ đồ bàn đầu trận, bàn sau từng hiệp (hiệp 1, 2, 3), hướng dẫn từng nước đi, làm rõ luật kéo, đẩy va làng trừ Lòng dân và đòn xung phong kỵ binh.
  - `game/tests/test_tran_04.gd`: GUT test kiểm chứng độc lập việc nạp trận, so khớp toàn diện với kịch bản (quân, máu, địa hình, đòn báo, thứ tự đọc bàn, số hiệp, lòng dân), kiểm tra `state.validate()` sau mỗi lần `Rules.resolve`, kiểm tra đòn địch nhắm làng đầu hiệp 2 và nhắm tướng đầu hiệp 3.
  - `game/tests/kich_ban/tran/tran_04_loi_giai.json`: kịch bản tự động sau pha chuẩn bị hiệp 1, đạt `da_duyet: true`, thắng hiệp 3/6, 3 tướng 3/3 máu, Lòng dân 3/3.
  - Không sửa mã nguồn lõi trong `src/core/` hay `data/chi_so.json`.

## File List

- `game/data/tran/tran_04.json`: Dữ liệu bản đồ trận 4
- `game/data/tran/tran_04_loi_giai.md`: Bản hướng dẫn lời giải chi tiết và sơ đồ bàn sau từng hiệp
- `game/tests/kich_ban/tran/tran_04_loi_giai.json`: Kịch bản kiểm chứng tự động (`da_duyet: true`)
- `game/tests/test_tran_04.gd`: Kiểm thử GUT cho trận 4
- `_bmad-output/implementation-artifacts/3-8-tran-4-bao-ve-lang.md`: Tài liệu hồ sơ story
- `_bmad-output/implementation-artifacts/sprint-status.yaml`: Cập nhật trạng thái story 3.8 sang review và ghi nhận story 3.7 done
- `_bmad-output/implementation-artifacts/3-7-lang-va-long-dan.md`: Chuyển trạng thái Story 3.7 sang done
