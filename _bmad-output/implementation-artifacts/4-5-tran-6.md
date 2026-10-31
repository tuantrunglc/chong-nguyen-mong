---
baseline_commit: 1334262
---

# Story 4.5: Trận 6

Status: ready-for-dev


## Story

Là tác giả,
tôi muốn trận 6 tổng hợp mọi luật,
để kết thúc prototype bằng một bài toán khó nhất.

_Cắt được nếu trễ (epics.md:184, 1305): khi cắt, `chien_dich.json` giữ 5 trận và Sát Thát mở từ trận 5._

## Acceptance Criteria

1. **Cho** `game/data/tran/tran_06.json` được nạp (`LevelLoader.load_level`, không lỗi, không cảnh báo):
   - `"kieu": "giu_ai"`, `"so_hiep_toi_da": 5`; có ít nhất một ô ải `A`, không quân Nguyên nào đặt sẵn trên `A` (tác giả chốt 2026-10-31).
   - Đủ 3 tướng: Nguyễn Khoái (`1`), Phạm Ngũ Lão (`2`), Trần Khánh Dư (`3`).
   - `"muu_ke_mo": ["vuon_khong_nha_trong", "sat_that"]` (tác giả chốt: mưu kế đã mở không lấy lại).
   - Quân Nguyên theo GDD (tác giả chốt): **5 quân khởi đầu**, có đủ Bộ binh `B`, Kỵ binh `K`, Cung kỵ `C`; `tiep_vien` **+1–2 quân mỗi hiệp từ hiệp 2 tới hiệp 5** (định dạng `{"hiep": N, "o": "cot,hang", "loai": "B|K|C"}`). Ô tiếp viện đi được, không phải `A`. Số cụ thể chốt khi mô phỏng.
   - Bàn **10×8** (10 cột, 8 hàng), có đủ địa hình đã dạy: sông `~`, rừng `#`, hầm chông `^`, kho lương `L`, ải `A`. **Không có làng** `D` (tác giả chốt).
   - `thu_tu_dich` đúng thứ tự đọc bàn (hàng trên → dưới, trái → phải); `ten` dạng "Trận 6 — <tên>" (đề xuất "Trận 6 — Phục Binh Bạch Đằng").
2. **Cho** `game/data/tran/tran_06_loi_giai.md` (FR43):
   - Sơ đồ bàn đầu trận (**sau** pha chuẩn bị hiệp 1, có ô đỏ), ô báo tiếp viện ở bàn của hiệp trước khi tiếp viện tới, bàn sau từng hiệp tới hiệp cuối (kể cả bàn sau hiệp cuối).
   - Lời giải từng nước, **không mất tướng** = không tướng nào gục, được phép mất máu (tác giả chốt, như trận 5); không quân Nguyên nào vào ải.
   - Chỉ rõ điểm dạy: thời điểm dùng **Sát Thát** và vì sao (Khoái 3 sát thương, Lão 2 sát thương, chỉ trong lượt người chơi đó); vì sao **không** thắng được nếu không dùng Sát Thát; các luật cũ được dùng (đẩy xuống sông, hầm chông, rừng chặn xung phong, địch đánh trúng nhau, kho lương, chặn tiếp viện, Vườn không nhà trống).
3. **Khi** tác giả chạy `tools/chay.sh --dev --tran=6` đánh lại đúng lời giải **thì** thắng, không mất tướng.
4. **Và** lời giải thành kịch bản `game/tests/kich_ban/tran/tran_06_loi_giai.json` (`ket_qua: "thang"`), dựng từ bàn **sau** pha chuẩn bị hiệp 1; `tools/test.sh` phát lại mỗi lần chạy. Để `da_duyet: false` cho tới khi tác giả đánh tay xong (AC 3) và nói duyệt.
5. **Và** test GUT `game/tests/test_tran_06.gd` theo mẫu `test_tran_05.gd`: so bàn thật với `truoc` của kịch bản (địa hình, quân, máu, `so_hiep_toi_da`, `tiep_vien`, `muu_ke_mo`), kiểm thứ tự quân Nguyên trong `level.units` đúng thứ tự đọc bàn, đọc `thu_tu_dich` thẳng từ JSON, ô tiếp viện đi được và không phải `A`, chạy lời giải trên `BattleState.from_level` với `state.validate()` rỗng sau **mỗi** `Rules.resolve`, `match` bước có nhánh mặc định báo trượt, kiểm thắng ở hiệp 5 với cả 3 tướng còn sống; kiểm lời giải **có dùng** Sát Thát.
6. **Và** chuỗi chiến dịch có 6 trận: thêm `"tran_06"` vào `game/data/chien_dich.json` (story 4.2 đã chừa đúng một dòng). Thắng trận 5 → màn chuyển trận báo mở **Sát Thát** (chỉ Sát Thát, vì Vườn không nhà trống đã có từ trận 5); thắng trận 6 → màn "thắng cả chiến dịch", xóa file lưu. Sửa các test đang coi trận 5 là trận cuối (`test_campaign.gd:36`, `test_main.gd` ~908–930, ~1196–1206) và thêm test chuyển 5 → 6.
7. **Và** dòng trận 6 trong bảng Campaign Structure của GDD sửa cho khớp quyết định của tác giả.
8. **Và** bản web mới được build và đẩy lên itch (riêng tư) **chỉ khi tác giả cho phép**: `tools/build_web.sh` rồi `tools/deploy_itch.sh`. Butler chưa đăng nhập thì ghi đúng lý do và hẹn tác giả chạy `tools/dang_nhap_itch.sh`.
9. **Và** `tools/test.sh` xanh; không sửa luật (`src/core/`) hay `data/chi_so.json`; commit tiếng Việt kết `(Story 4.5)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–6** (2026-10-31) — xem "Quyết định của tác giả"; AC 1, 2 đã sửa cho khớp.

- [ ] **Task 1: Thiết kế sa bàn và tìm lời giải bằng luật thật** (AC: 1, 2)
  - [ ] 1.1 Khởi điểm: `_bmad-output/planning-artifacts/thiet-ke-ban-do/tran_06_bach_dang.md`, sửa theo quyết định tác giả và theo **luật thật hiện hành** (xem "Chỗ bản thiết kế sai luật" dưới).
  - [ ] 1.2 Mô phỏng headless bằng luật thật như 3.14 (script tạm trong scratchpad, `extends SceneTree`, `Rules.resolve` trên `BattleState.from_level` + `Command.begin_battle()`), **không** đoán bằng tay. Cần: (a) in bàn từng hiệp, (b) tìm lời giải (beam/DFS có nhớ trạng thái), (c) chơi ngẫu nhiên nhiều ván đo độ khó, (d) thử "không dùng Sát Thát" để xem Sát Thát có cần không.
  - [ ] 1.3 Tiêu chí bàn tốt (tác giả chốt 2026-10-31): trận khó nhất chuỗi; **bắt buộc Sát Thát** — mô phỏng tìm kiếm với mưu kế Sát Thát bị cấm phải **không** tìm được lối thắng mà không tướng nào gục; ít nhất một tiếp viện ảnh hưởng thật; mỗi luật đã dạy có ít nhất một chỗ dùng được. Ghi số liệu mô phỏng vào Debug Log. Được thay bố cục, cơ cấu quân, lịch tiếp viện trong khuôn AC 1. **Không** sửa `chi_so.json` hay luật để đạt tiêu chí; không đạt được thì **dừng**, báo tác giả bằng số liệu (tác giả chốt; bài học 3.14: Giữ ải với chỉ số hiện hành khó ép áp lực).
  - [ ] 1.4 Trình tác giả bàn cờ chữ + tóm tắt lời giải **trước** khi viết file chính thức.

- [ ] **Task 2: `game/data/tran/tran_06.json`** (AC: 1) — `phien_ban_dinh_dang: 1`, mẫu như `tran_05.json`.

- [ ] **Task 3: `game/data/tran/tran_06_loi_giai.md`** (AC: 2) — mẫu `tran_05_loi_giai.md` (sau review 3.14): ghi đúng thời điểm ô tiếp viện được báo (pha chuẩn bị của hiệp trước, hiện suốt lượt người chơi hiệp đó); lý do từng nước phải khớp mô phỏng.

- [ ] **Task 4: Kịch bản và test** (AC: 4, 5)
  - [ ] 4.1 `tests/kich_ban/tran/tran_06_loi_giai.json`: `truoc` là bàn sau chuẩn bị hiệp 1 (quân đã đi, `bao_don`, `tiep_vien` còn lại, `muu_ke_mo`, `kieu`, `so_hiep_toi_da`); `hanh_dong` có `{"lenh": "muu_ke", "ten": "sat_that"}`; `sau.ket_qua: "thang"`. F2 không ghi `kieu`/`tiep_vien`/`so_hiep_toi_da`: thêm tay.
  - [ ] 4.2 `tests/test_tran_06.gd` theo AC 5. Kiểm thêm: tiếp viện xuất hiện đúng ô đúng hiệp; trong lượt dùng Sát Thát, đòn của Khoái/Lão trừ đúng máu đã cộng.

- [ ] **Task 5: Chuỗi 6 trận** (AC: 6)
  - [ ] 5.1 `data/chien_dich.json`: thêm `"tran_06"`.
  - [ ] 5.2 `test_campaign.gd`: danh sách 6 trận. `test_main.gd`: `test_last_level_won_*` dùng trận 6; thêm `test_transition_to_level_6_lists_new_stratagem` (chỉ Sát Thát); `test_last_level_won_clears_save` dùng `"tran_tiep": "tran_06"`. Tìm thêm mọi chỗ coi `tran_05` là cuối (`grep -rn tran_05 game/tests game/src`).

- [ ] **Task 6: GDD** (AC: 7) — sửa dòng trận 6 trong `gdds/gdd-GameTest-2026-10-15/gdd.md` (Campaign Structure, ~dòng 253).

- [ ] **Task 7: Kiểm tra, build, bàn giao** (AC: 3, 8, 9)
  - [ ] 7.1 `tools/test.sh` xanh 4/4.
  - [ ] 7.2 Chụp GoPeak (`tools/chay.sh --dev --tran=6`): bàn đầu trận vừa màn hình (nếu 10×8), ô báo tiếp viện, nút Sát Thát.
  - [ ] 7.3 Hướng dẫn tác giả đánh tay (từng nước, thấy gì là đúng) và thử chuỗi: thắng trận 5 → màn chuyển trận báo Sát Thát → trận 6 → thắng → màn "thắng cả chiến dịch".
  - [ ] 7.4 Build web + deploy itch chỉ khi tác giả cho phép (AC 8).
  - [ ] 7.5 Cập nhật story, `sprint-status.yaml`; commit.

## Dev Notes

### Luật hiện hành (đã chốt, không đổi trong story này)

- **Sát Thát** (3.13): bấm nút/phím `W` trong lượt người chơi → tới hết **lượt người chơi đó**, đòn có sát thương của tướng +`muu_ke.sat_that.cong_sat_thuong` (1): Khoái 2 → 3 (gục vì sát thương thì không đẩy), Lão 1 → 2. Dư kéo vẫn 0. Va chạm, hầm chông, sông, Vườn không nhà trống, đòn địch **không** được cộng. Đòn đánh trước khi dùng không tính lại. 1 lần/trận, không tốn hành động, xóa lịch sử hủy; chơi lại hiệp trả lại mưu kế dùng trong lượt đó. Nút xếp Q (VKNT) trên, W (Sát Thát) dưới.
- **Sát Thát KHÔNG tăng tầm**: bản thiết kế ghi "+1 ô cự ly", "Khoái đẩy 2 ô", "Dư kéo 4 ô", "Lão ném 5 ô" là **sai luật**.
- **Giữ ải** (3.11): thắng khi qua hết hiệp cuối mà không quân Nguyên nào vào `A` và còn ít nhất một tướng; diệt hết quân **không** thắng sớm; quân Nguyên vào `A` bằng mọi cách (kể cả bị đẩy/kéo, tiếp viện xuất hiện trên `A`) là thua ngay.
- **AI Giữ ải**: Bộ binh/Kỵ binh nhắm ô ải gần nhất; không có đường tới ải thì nhắm tướng gần nhất. Cung kỵ luôn nhắm tướng gần nhất. Giữ ải **không** nhắm làng (`enemy_ai.gd:21`), nhưng đòn địch trúng ô làng vẫn trừ Lòng dân (`rules_enemy_phase.gd:43`).
- **Kho lương** (3.9): quân Nguyên bị thương kề `L` hồi 1 máu cuối hiệp. `L` là vật cản.
- **Vườn không nhà trống** (3.12): mọi `L` thành `.`, mọi quân Nguyên mất 1 máu.
- **Tiếp viện** (3.10): đầu hiệp N quân mới xuất hiện ở ô đã báo; ô có quân thì quân đó mất 1 máu và tiếp viện bị hủy (cách chặn).
- **Hầm chông** `^`: đi được, trừ 1 máu cả khi chỉ đi ngang qua (cả tướng lẫn địch, cả bị đẩy/kéo).
- **Tướng**: Khoái đánh kề 2 + đẩy 1; Lão lao thẳng hàng, bay qua ô kề, trúng vật đầu ở ô 2–4, 1 sát thương; Dư kéo vật đầu tiên trong 3 ô về 2 ô, 0 sát thương. Chỉ số trong `data/chi_so.json`.

### Chỗ bản thiết kế `tran_06_bach_dang.md` sai luật hoặc lệch epics/GDD

- Kiểu `tieu_diet`, 7 hiệp, không tiếp viện → tác giả chốt **Giữ ải** 5 hiệp, 5 quân + 1–2 mỗi hiệp.
- Bàn 8×8 → tác giả chốt **10×8**. Bản thiết kế thiếu kho lương, ải.
- Sát Thát "+1 ô cự ly", đẩy 2 / kéo 4 / lao 5 ô → sai luật (xem trên).
- Lời giải chưa mô phỏng; quân trong `quan` là vị trí **trước** chuẩn bị. Coi như ý đồ (bãi chông giữa sông, phục binh hai bờ), không phải lời giải.
- "Bãi cọc ngầm" = hầm chông `^` hiện có; thủy triều, thuyền **để sau prototype** (GDD dòng 240) — không thêm luật.

### Hiện trạng code (chỉ dùng, không sửa trừ chỗ ghi rõ)

- `--tran=6` tự nạp `data/tran/tran_06.json` (`LaunchOptions`: số N → `tran_0N`).
- `LevelLoader` nhận khóa: `phien_ban_dinh_dang, ten, kieu, dia_hinh, quan, thu_tu_dich, tiep_vien, muu_ke_mo, so_hiep_toi_da, long_dan`. Giữ ải không ghi `so_hiep_toi_da` thì mặc định 5 (`level_loader.gd:52`). `long_dan` bắt buộc khi có `D`, cấm khi không có.
- Cỡ bàn 5×5 đến 10×8; ở 1280×720 bàn nào cũng vẽ tỉ lệ 1 (`board_view.gd:277`). Không lặp cứng cỡ bàn.
- `data/chien_dich.json` hiện 5 trận; story 4.2 chốt "Story 4.5 thêm `tran_06` bằng một dòng". `main.gd:274, 350`: `_campaign.is_last(won_id)` → màn "thắng cả chiến dịch", xóa file lưu. Màn chuyển trận liệt kê mưu kế **mới** so với trận trước (xem `test_transition_to_level_5_lists_new_stratagem`).
- Mẫu đã chạy: `tran_05.json`, `tran_05_loi_giai.md`, `tests/kich_ban/tran/tran_05_loi_giai.json`, `tests/test_tran_05.gd` (đã sửa theo review 3.14). Kịch bản Sát Thát mẫu: `tests/kich_ban/muu_ke/st_*`.
- `tools/xem_kich_ban.sh tran` cho tác giả xem kịch bản.

### Điều phải giữ

- Không sửa `src/core/`, `data/chi_so.json`, kịch bản `da_duyet: true` nào. Thấy luật có vẻ sai khi thiết kế → dừng, hỏi tác giả; không "chỉnh luật cho vừa bàn".
- `test_tran_01..05`, mọi kịch bản cũ, mọi test chuỗi chiến dịch/tự lưu/tua nhanh vẫn xanh.

### Bài học từ story trước

- **3.14 (trận 5)**: mô phỏng ~105 bố cục cho thấy với chỉ số hiện hành, Giữ ải không ép được áp lực tới hiệp cuối (Bộ binh/Kỵ binh nhắm ải chứ không nhắm tướng; ba tướng gây ~3 sát thương/hiệp; giặc ít máu). Trận 6 nhiều quân hơn (+1–2/hiệp) có thể khác, nhưng phải **đo** sớm (Task 1.2) và báo tác giả nếu không ép được "khó nhất"/"cần Sát Thát" (Câu hỏi 6).
- **3.14 review**: lời giải phải khớp từng câu với mô phỏng (đã có câu lý do sai bị bắt); test so cả kiểu đòn đã báo (ô/hướng); kiểm quân vào ải đúng con.
- **3.8 review**: test so bàn thật với `truoc`, đọc `thu_tu_dich` từ JSON, `validate()` sau mỗi lệnh, có sơ đồ bàn sau hiệp cuối.
- **3.6 review**: kịch bản trận chỉ bật `da_duyet: true` khi tác giả đã đánh tay.
- **4.2/4.3**: test chuỗi chiến dịch dùng `_open("N")`, `_finish(main, Phase.WON)`, `_banner(main).next_button()`, `_transition(main)`; file lưu cô lập bằng `tests/pre_run.gd`.
- **2.14**: itch đã cấu hình (`tools/itch.cfg`); chặn thật thường là butler chưa đăng nhập.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh; JSON số là `float` → `int()`; khóa JSON tiếng Việt không dấu.
- Tất định; `state.validate()` rỗng sau mỗi lần phân giải trong test. Duyệt quân theo `thu_tu_dich`.
- MCP chỉ để nhìn và thử (`--dev`); dữ liệu trận chỉ sửa trong file, có test.
- Mỗi pha địch ≤ 3 s hoạt ảnh — trận nhiều quân nhất chuỗi: xem pha địch có bị co thời lượng quá mức không (EventPlayer tự co, chỉ cần nhìn).
- Nói với tác giả bằng tiếng Việt, bàn cờ chữ, các bước thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.5] (dòng 1299–1314); FR43 (dòng 93), FR34 (dòng 76); phương án cắt (dòng 184)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Campaign Structure] (dòng 242–259)
- [Source: _bmad-output/planning-artifacts/thiet-ke-ban-do/tran_06_bach_dang.md]
- [Source: _bmad-output/implementation-artifacts/3-14-tran-5-giu-ai.md], `3-13-muu-ke-sat-that.md`, `4-2-chuoi-6-tran-va-man-chuyen-tran.md`, `4-3-tu-luu.md`
- [Source: _bmad-output/implementation-artifacts/deferred-work.md] (mục code review 3.14: áp lực Giữ ải)
- [Source: _bmad-output/project-context.md]

### Câu hỏi đã hỏi tác giả (đã trả lời ở dưới)

1. **Kiểu trận.** Epics và GDD ghi trận 6 là **Giữ ải** (5 hiệp). Bản thiết kế bàn ghi **Tiêu diệt**, 7 hiệp. Theo bản nào?
2. **Số quân Nguyên.** GDD: 5 quân khởi đầu, +1–2 mỗi hiệp (tổng khoảng 9–13 quân). Bản thiết kế: 5 quân (2 Kỵ binh, 2 Bộ binh, 1 Cung kỵ), không tiếp viện. Theo bản nào, hay để AI chọn khi mô phỏng?
3. **Cỡ bàn và địa hình.** GDD gợi ý 10×8, bản thiết kế 8×8. "Đủ các loại địa hình" có gồm **làng** (thêm điều kiện thua Lòng dân) không, hay chỉ sông, rừng, hầm chông, kho lương, ải?
4. **Mưu kế.** Trận 6 mở cả Vườn không nhà trống lẫn Sát Thát, hay chỉ Sát Thát?
5. **Mức "không mất tướng".** Như trận 5 (không tướng nào gục, được mất máu)?
6. **Độ khó.** Lời giải có **bắt buộc** dùng Sát Thát không (không dùng thì không thắng được mà không mất tướng)? Nếu mô phỏng cho thấy không ép được với chỉ số hiện hành (như trận 5), thì: chấp nhận trận dễ hơn, tăng quân/tiếp viện, hay dừng để mở story cân bằng chỉ số?

### Quyết định của tác giả

Chốt 2026-10-31:

1. **Giữ ải**, 5 hiệp (theo epics/GDD, không theo bản thiết kế bàn).
2. **Quân theo GDD**: 5 quân khởi đầu, +1–2 quân mỗi hiệp từ hiệp 2; số cụ thể AI chốt khi mô phỏng.
3. **Bàn 10×8, không làng**: sông, rừng, hầm chông, kho lương, ải.
4. **Mở cả hai mưu kế**: Vườn không nhà trống và Sát Thát.
5. **"Không mất tướng" như trận 5**: không tướng nào gục, được mất máu.
6. **Bắt buộc Sát Thát**: không dùng thì không thắng được mà không mất tướng. Mô phỏng thấy không làm được với chỉ số hiện hành thì AI **dừng và báo** bằng số liệu, không tự sửa chỉ số hay luật.

## Dev Agent Record

### Agent Model Used

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
