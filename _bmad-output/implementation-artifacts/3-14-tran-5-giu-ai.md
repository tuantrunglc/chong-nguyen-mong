---
baseline_commit: 1b2416e
---

# Story 3.14: Trận 5 (Giữ ải)

Status: ready-for-dev

## Story

Là tác giả,
tôi muốn trận 5 dạy kho lương, Vườn không nhà trống và quân tiếp viện,
để người chơi chịu áp lực Giữ ải lần đầu.

## Acceptance Criteria

1. **Cho** `game/data/tran/tran_05.json` được nạp (`LevelLoader.load_level`, không lỗi, không cảnh báo):
   - `"kieu": "giu_ai"`, `"so_hiep_toi_da": 5`, có ít nhất một ô ải `A`, không quân Nguyên nào đặt sẵn trên `A`.
   - Đủ 3 tướng: Nguyễn Khoái (`1`), Phạm Ngũ Lão (`2`), Trần Khánh Dư (`3`).
   - Có kho lương `L`; quân Nguyên khởi đầu đứng kề kho lương để luật hồi máu có ý nghĩa.
   - `"muu_ke_mo": ["vuon_khong_nha_trong"]` (không mở Sát Thát — trận 6).
   - Có lịch `tiep_vien` (định dạng `{"hiep": N, "o": "cot,hang", "loai": "B|K|C"}`, `hiep` ≥ 2, ô đi được, không phải ô `A`).
   - Bàn **8×8**, có sông `~`, rừng `#`, kho lương `L`, ải `A`.
   - Quân Nguyên khởi đầu: 2 Bộ binh (`B`), 1 Cung kỵ (`C`); `tiep_vien`: 1 Kỵ binh (`K`) ở hiệp 3 (tác giả chốt 2026-10-27).
   - `thu_tu_dich` đúng thứ tự đọc bàn (hàng trên → dưới, trái → phải); `ten` là "Trận 5 — Thăng Long Bỏ Ngỏ".
2. **Cho** `game/data/tran/tran_05_loi_giai.md` (FR43):
   - Sơ đồ bàn đầu trận (**sau** pha chuẩn bị hiệp 1, có ô đỏ và ô báo tiếp viện) và bàn sau từng hiệp, tới hết hiệp 5.
   - Lời giải từng nước, **không mất tướng** — không tướng nào gục, được phép mất máu (tác giả chốt), không quân Nguyên nào vào ải.
   - Chỉ rõ điểm dạy: (a) kho lương hồi 1 máu cuối hiệp cho quân Nguyên bị thương đứng kề; (b) thời điểm dùng Vườn không nhà trống (đốt kho + trừ 1 máu mọi quân Nguyên) và vì sao lúc đó; (c) đọc ô báo tiếp viện và chặn/đón tiếp viện; (d) Giữ ải: diệt hết quân trên bàn không thắng sớm, phải qua hết hiệp 5.
3. **Khi** tác giả chạy `tools/chay.sh --dev --tran=5` đánh lại đúng lời giải **thì** thắng, không mất tướng.
4. **Và** lời giải thành kịch bản `game/tests/kich_ban/tran/tran_05_loi_giai.json` (`ket_qua: "thang"`), dựng từ bàn **sau** pha chuẩn bị hiệp 1; `tools/test.sh` phát lại mỗi lần chạy. Kịch bản để `da_duyet: false` cho tới khi tác giả đánh tay xong (AC 3) và nói duyệt.
5. **Và** test GUT `game/tests/test_tran_05.gd` theo mẫu `test_tran_04.gd` (sau review 3.8): so bàn thật với `truoc` của kịch bản (địa hình, quân, máu, `so_hiep_toi_da`, `tiep_vien`, `muu_ke_mo`), đọc `thu_tu_dich` thẳng từ JSON, chạy lời giải trên `BattleState.from_level` với `state.validate()` rỗng sau **mỗi** `Rules.resolve`, kiểm thắng ở hiệp 5 với cả 3 tướng còn sống.
6. **Và** bản web mới được build và đẩy lên itch (riêng tư): `tools/build_web.sh` rồi `tools/deploy_itch.sh`. Butler chưa đăng nhập thì ghi đúng lý do đó và hẹn tác giả chạy `tools/dang_nhap_itch.sh` (bài học 2.14), không tự đổi chế độ hiển thị trang.
7. **Và** `tools/test.sh` xanh; không sửa luật (`src/core/`) hay `data/chi_so.json`; commit tiếng Việt kết `(Story 3.14)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–3** (2026-10-27) — xem "Quyết định của tác giả".

- [ ] **Task 1: Thiết kế sa bàn và tìm lời giải bằng luật thật** (AC: 1, 2)
  - [ ] 1.1 Khởi điểm: `_bmad-output/planning-artifacts/thiet-ke-ban-do/tran_05_thang_long_bo_ngo.md`. Sửa theo quyết định tác giả và theo **luật thật hiện hành** (xem "Chỗ bản thiết kế sai luật" dưới).
  - [ ] 1.2 Mô phỏng headless bằng luật thật (script tạm trong scratchpad, `extends SceneTree`, chạy `Rules.resolve` trên `BattleState.from_level` + `Command.begin_battle()`), **không** đoán bằng tay: AI Giữ ải nhắm ải, tiếp viện, hồi máu, va chạm khó tính nhẩm. Nên có (a) chế độ in bàn từng hiệp, (b) tìm lời giải DFS có nhớ trạng thái, (c) chơi ngẫu nhiên nhiều ván để đo độ khó (tỷ lệ thua, có thắng được khi không dùng mưu kế không).
  - [ ] 1.3 Tiêu chí bàn tốt: lời giải phải **cần** ít nhất một trong hai — dùng Vườn không nhà trống, hoặc xử lý kho lương (không để địch hồi) — và phải có ít nhất một tiếp viện ảnh hưởng thật tới ván (không xuất hiện ở góc vô hại). Không có lời giải mất tướng "dễ hơn" lời giải chuẩn rõ rệt. Ghi số liệu mô phỏng vào Debug Log.
  - [ ] 1.4 Trình tác giả bàn cờ chữ + tóm tắt lời giải **trước** khi viết file chính thức (tác giả quyết spec).

- [ ] **Task 2: `game/data/tran/tran_05.json`** (AC: 1) — `phien_ban_dinh_dang: 1`, mẫu như `tran_04.json`.

- [ ] **Task 3: `game/data/tran/tran_05_loi_giai.md`** (AC: 2) — mẫu `tran_04_loi_giai.md`, có sơ đồ bàn sau hiệp cuối (bài học review 3.8).

- [ ] **Task 4: Kịch bản và test** (AC: 4, 5)
  - [ ] 4.1 `tests/kich_ban/tran/tran_05_loi_giai.json`: `truoc` là bàn sau chuẩn bị hiệp 1 (quân đã đi, `bao_don` đã có, `tiep_vien` còn lại, `muu_ke_mo`); `hanh_dong` gồm cả `{"lenh": "muu_ke", "ten": "vuon_khong_nha_trong"}`; `sau.ket_qua: "thang"`. Có thể dựng nhanh bằng F2 trong game rồi sửa (xem `BugReport.scenario_data`), nhưng F2 **không ghi** `kieu`/`tiep_vien`/`so_hiep_toi_da` (mục hoãn của 3.12) — phải thêm tay.
  - [ ] 4.2 `tests/test_tran_05.gd` theo AC 5. Kiểm thêm: đầu hiệp có tiếp viện thì quân mới xuất hiện đúng ô; sau khi dùng mưu kế bàn không còn `L`.

- [ ] **Task 5: Kiểm tra, build, bàn giao** (AC: 3, 6, 7)
  - [ ] 5.1 `tools/test.sh` xanh 4/4.
  - [ ] 5.2 Chụp màn hình GoPeak (`tools/chay.sh --dev --tran=5`): bàn đầu trận, ô báo tiếp viện, nút Vườn không nhà trống.
  - [ ] 5.3 Hướng dẫn tác giả đánh tay bằng tiếng Việt (từng nước, thấy gì là đúng) trong Completion Notes.
  - [ ] 5.4 Build web + deploy itch (AC 6).
  - [ ] 5.5 Cập nhật story, `sprint-status.yaml`; commit.

## Dev Notes

### Luật hiện hành (đã chốt, không đổi trong story này)

- **Giữ ải** (3.11, sau review): thắng khi qua hết bước cuối hiệp 5 mà không quân Nguyên nào vào ô `A` và còn ít nhất một tướng. **Diệt hết quân không thắng sớm.** Quân Nguyên vào `A` bằng mọi cách (tự đi, bị Khoái đẩy, bị Dư kéo, **tiếp viện xuất hiện trên `A`**) → thua ngay "Thua: giặc vào ải". Mọi tướng gục → thua.
- **AI Giữ ải**: Bộ binh/Kỵ binh nhắm ô ải gần nhất theo số bước; ưu tiên ô đứng mà đòn trúng ô ải, không có thì tới ô gần ải nhất; **không có đường tới ải thì nhắm tướng gần nhất** (tác giả chốt 2026-10-25). Cung kỵ luôn nhắm tướng gần nhất, bắn được tướng đứng trên ô ải. Giữ ải **không** nhắm làng. Xem kiến trúc dòng ~841.
- **Kho lương** (3.9): quân Nguyên bị thương kề trực giao một ô `L` hồi 1 máu ở bước cuối hiệp (tối đa 1/hiệp). Tướng không hồi. `L` là vật cản: không đi vào, va chạm 1 máu, chặn lao, tên, kéo và xung phong.
- **Vườn không nhà trống** (3.12): mọi `L` thành `.`, rồi mọi quân Nguyên mất 1 máu (Cung kỵ 1 máu gục). Không tốn hành động, xóa lịch sử hủy, 1 lần/trận. Trong Giữ ải không thắng sớm.
- **Tiếp viện** (3.10): đầu hiệp N quân mới xuất hiện ở ô đã báo; ô có quân (mọi phe) thì quân đó mất 1 máu và tiếp viện bị hủy — đây là cách **chặn tiếp viện** người chơi nên học. Ô tiếp viện hiệp sau được báo suốt lượt người chơi hiệp trước. Quân mới đi và báo đòn ngay trong hiệp xuất hiện.
- **Tướng**: Khoái đánh kề 2 sát thương + đẩy 1; Lão lao thẳng hàng, bay qua ô kề, trúng vật đầu ở ô 2–4, 1 sát thương; Dư kéo vật đầu tiên trong 3 ô về 2 ô, 0 sát thương. Chỉ số trong `data/chi_so.json`.

### Chỗ bản thiết kế `tran_05_thang_long_bo_ngo.md` sai luật hiện hành

- Ghi "hoặc tiêu diệt toàn bộ quân địch" → **sai**, Giữ ải không thắng sớm.
- Tiếp viện ghi `"toado": [3, 0]` → định dạng thật là `"o": "3,0"`.
- Lời giải trong bản thiết kế chưa mô phỏng (vd. Lão "bước lên `3,4` ném lao lên `3,2`" bỏ qua việc Cung kỵ đã đi trong pha chuẩn bị hiệp 1; quân trong `quan` là vị trí **trước** chuẩn bị). Coi như ý đồ, không phải lời giải.
- Bàn thiết kế đặt cả ba tướng ở hàng 5 sát ải hàng 6: kiểm xem có lời giải "đứng chắn ải không làm gì" quá dễ không (tiêu chí 1.3).

### Hiện trạng code (chỉ dùng, không sửa)

- `--tran=5` tự nạp `data/tran/tran_05.json` (`LaunchOptions`: số N → `tran_0N`). Chuỗi chiến dịch, màn chuyển trận là Epic 4 — không làm ở đây.
- `LevelLoader` nhận khóa: `phien_ban_dinh_dang, ten, kieu, dia_hinh, quan, thu_tu_dich, tiep_vien, muu_ke_mo, so_hiep_toi_da, long_dan`. `long_dan` chỉ khi có làng `D`.
- Mẫu đã chạy: `tran_04.json`, `tran_04_loi_giai.md`, `tests/kich_ban/tran/tran_04_loi_giai.json`, `tests/test_tran_04.gd`. Kịch bản luật Giữ ải/tiếp viện/mưu kế để tham khảo cách ghi `tiep_vien`, `muu_ke`: `tests/kich_ban/giu_ai/`, `tiep_vien/`, `muu_ke/vknt_*`.
- `tools/xem_kich_ban.sh tran` cho tác giả xem kịch bản.

### Điều phải giữ

- Không sửa `src/core/`, `data/chi_so.json`, kịch bản `da_duyet: true` nào. Thấy luật có vẻ sai khi thiết kế → dừng, hỏi tác giả, ghi lại; không "chỉnh luật cho vừa bàn".
- `test_tran_01..04` và mọi kịch bản cũ vẫn xanh.

### Bài học từ story trước

- 3.8 review: test phải so bàn thật với `truoc` (không chỉ nạp được), đọc `thu_tu_dich` từ JSON (không so mảng với chính nó), `validate()` sau mỗi lệnh, có sơ đồ bàn sau hiệp cuối, ghi rõ luật va chạm trong lời giải.
- 3.6 review: lời giải phải đánh lại bằng luật thật; kịch bản trận chỉ bật `da_duyet: true` khi tác giả đã đánh tay.
- 2.14: itch đã cấu hình (`tools/itch.cfg` = `tuantrunglc/hao-khi-dong-a`); chặn thật thường là butler chưa đăng nhập.
- 3.11 review: tiếp viện xuất hiện trên ô `A` là thua — đừng đặt ô tiếp viện trên ải.

### Project Context Rules

- Godot 4.7.2, GDScript gõ kiểu tĩnh; JSON số là `float` → `int()`; khóa JSON tiếng Việt không dấu.
- Tất định; `state.validate()` rỗng sau mỗi lần phân giải trong test.
- MCP chỉ để nhìn và thử (`--dev`); dữ liệu trận chỉ sửa trong file, có test.
- Nói với tác giả bằng tiếng Việt, bàn cờ chữ, các bước thử.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 3.14] (dòng 1207–1222); FR43 (dòng 93)
- [Source: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md#Campaign Structure] (dòng 242–259)
- [Source: _bmad-output/planning-artifacts/thiet-ke-ban-do/tran_05_thang_long_bo_ngo.md]
- [Source: _bmad-output/implementation-artifacts/3-8-tran-4-bao-ve-lang.md], `3-9-kho-luong.md`, `3-10-quan-tiep-vien.md`, `3-11-nhiem-vu-giu-ai.md`, `3-12-muu-ke-vuon-khong-nha-trong-va-nut-muu-ke.md`, `2-14-hoan-thien-tran-1-va-moc-tu-choi-het-e2.md`
- [Source: _bmad-output/project-context.md]

### Quyết định của tác giả (chốt 2026-10-27)

1. **Quân Nguyên theo bản thiết kế bàn:** khởi đầu 2 Bộ binh + 1 Cung kỵ; tiếp viện 1 Kỵ binh ở hiệp 3 (ô cụ thể chốt khi mô phỏng, không phải ô `A`). Không theo "4 quân, +1 mỗi hiệp" của GDD — sửa dòng trận 5 trong bảng Campaign Structure của GDD cho khớp khi làm story.
2. **Có sông, bàn 8×8** (theo GDD): thêm sông vào bản thiết kế 8×7, để đẩy/kéo địch xuống sông là một cách giữ ải.
3. **"Không mất tướng" = không tướng nào gục**: lời giải được phép mất máu (khác trận 1–4). Kịch bản và test kiểm cả 3 tướng còn sống, ghi máu thật cuối trận.

### Câu hỏi đã hỏi tác giả (đã trả lời ở trên)

1. **Cơ cấu quân và nhịp tiếp viện.** GDD/epics ghi "4 quân khởi đầu, +1 mỗi hiệp" (tức tiếp viện ở hiệp 2, 3, 4, 5 — tổng 8 quân). Bản thiết kế bàn ghi 3 quân khởi đầu (2 Bộ binh, 1 Cung kỵ) và chỉ 1 Kỵ binh tiếp viện ở hiệp 3. Theo bản nào?
2. **Sông và cỡ bàn.** GDD ghi "kho lương, sông", gợi ý 8×8. Bản thiết kế 8×7, có rừng, không sông. Có cần sông không?
3. **Mức "không mất tướng".** Trận 1–4 đòi cả 3 tướng còn đủ 3/3 máu. Trận 5 cũng vậy, hay chỉ cần không tướng nào gục (cho phép mất máu, vì Giữ ải là áp lực)?

## Dev Agent Record

### Agent Model Used

### Debug Log References

- Nền trước story: HEAD `1b2416e`; `tools/test.sh` 769/769 GUT, 173 kịch bản đã duyệt.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.

### File List
