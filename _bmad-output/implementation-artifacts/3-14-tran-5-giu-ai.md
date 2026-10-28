---
baseline_commit: 1b2416e
---

# Story 3.14: Trận 5 (Giữ ải)

Status: review

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
   - Sơ đồ bàn đầu trận (**sau** pha chuẩn bị hiệp 1, có ô đỏ), ô báo tiếp viện ở bàn của hiệp trước khi tiếp viện tới (tác giả chốt 2026-10-28), và bàn sau từng hiệp, tới hết hiệp 5.
   - Lời giải từng nước, **không mất tướng** — không tướng nào gục, được phép mất máu (tác giả chốt), không quân Nguyên nào vào ải.
   - Chỉ rõ điểm dạy: (a) kho lương hồi 1 máu cuối hiệp cho quân Nguyên bị thương đứng kề; (b) thời điểm dùng Vườn không nhà trống (đốt kho + trừ 1 máu mọi quân Nguyên) và vì sao lúc đó; (c) đọc ô báo tiếp viện và chặn/đón tiếp viện; (d) Giữ ải: diệt hết quân trên bàn không thắng sớm, phải qua hết hiệp 5.
3. **Khi** tác giả chạy `tools/chay.sh --dev --tran=5` đánh lại đúng lời giải **thì** thắng, không mất tướng.
4. **Và** lời giải thành kịch bản `game/tests/kich_ban/tran/tran_05_loi_giai.json` (`ket_qua: "thang"`), dựng từ bàn **sau** pha chuẩn bị hiệp 1; `tools/test.sh` phát lại mỗi lần chạy. Kịch bản để `da_duyet: false` cho tới khi tác giả đánh tay xong (AC 3) và nói duyệt.
5. **Và** test GUT `game/tests/test_tran_05.gd` theo mẫu `test_tran_04.gd` (sau review 3.8): so bàn thật với `truoc` của kịch bản (địa hình, quân, máu, `so_hiep_toi_da`, `tiep_vien`, `muu_ke_mo`), đọc `thu_tu_dich` thẳng từ JSON, chạy lời giải trên `BattleState.from_level` với `state.validate()` rỗng sau **mỗi** `Rules.resolve`, kiểm thắng ở hiệp 5 với cả 3 tướng còn sống.
6. **Và** bản web mới được build và đẩy lên itch (riêng tư): `tools/build_web.sh` rồi `tools/deploy_itch.sh`. Butler chưa đăng nhập thì ghi đúng lý do đó và hẹn tác giả chạy `tools/dang_nhap_itch.sh` (bài học 2.14), không tự đổi chế độ hiển thị trang.
7. **Và** `tools/test.sh` xanh; không sửa luật (`src/core/`) hay `data/chi_so.json`; commit tiếng Việt kết `(Story 3.14)`.

## Tasks / Subtasks

- [x] **Task 0: Tác giả trả lời Câu hỏi 1–3** (2026-10-27) — xem "Quyết định của tác giả".

- [x] **Task 1: Thiết kế sa bàn và tìm lời giải bằng luật thật** (AC: 1, 2)
  - [x] 1.1 Khởi điểm: `_bmad-output/planning-artifacts/thiet-ke-ban-do/tran_05_thang_long_bo_ngo.md`. Sửa theo quyết định tác giả và theo **luật thật hiện hành** (xem "Chỗ bản thiết kế sai luật" dưới).
  - [x] 1.2 Mô phỏng headless bằng luật thật (script tạm trong scratchpad, `extends SceneTree`, chạy `Rules.resolve` trên `BattleState.from_level` + `Command.begin_battle()`), **không** đoán bằng tay: AI Giữ ải nhắm ải, tiếp viện, hồi máu, va chạm khó tính nhẩm. Nên có (a) chế độ in bàn từng hiệp, (b) tìm lời giải DFS có nhớ trạng thái, (c) chơi ngẫu nhiên nhiều ván để đo độ khó (tỷ lệ thua, có thắng được khi không dùng mưu kế không).
  - [x] 1.3 *(Tác giả chốt 2026-10-27: trận giới thiệu, mưu kế không bắt buộc — xem Debug Log.)* Tiêu chí bàn tốt: lời giải phải **cần** ít nhất một trong hai — dùng Vườn không nhà trống, hoặc xử lý kho lương (không để địch hồi) — và phải có ít nhất một tiếp viện ảnh hưởng thật tới ván (không xuất hiện ở góc vô hại). Không có lời giải mất tướng "dễ hơn" lời giải chuẩn rõ rệt. Ghi số liệu mô phỏng vào Debug Log.
  - [x] 1.4 *(Tác giả chọn hướng qua câu hỏi; bàn + lời giải trình trong Completion Notes, tác giả duyệt bằng đánh tay — AC 3.)* Trình tác giả bàn cờ chữ + tóm tắt lời giải **trước** khi viết file chính thức (tác giả quyết spec).

- [x] **Task 2: `game/data/tran/tran_05.json`** (AC: 1) — `phien_ban_dinh_dang: 1`, mẫu như `tran_04.json`.

- [x] **Task 3: `game/data/tran/tran_05_loi_giai.md`** (AC: 2) — mẫu `tran_04_loi_giai.md`, có sơ đồ bàn sau hiệp cuối (bài học review 3.8).

- [x] **Task 4: Kịch bản và test** (AC: 4, 5)
  - [x] 4.1 `tests/kich_ban/tran/tran_05_loi_giai.json`: `truoc` là bàn sau chuẩn bị hiệp 1 (quân đã đi, `bao_don` đã có, `tiep_vien` còn lại, `muu_ke_mo`); `hanh_dong` gồm cả `{"lenh": "muu_ke", "ten": "vuon_khong_nha_trong"}`; `sau.ket_qua: "thang"`. Có thể dựng nhanh bằng F2 trong game rồi sửa (xem `BugReport.scenario_data`), nhưng F2 **không ghi** `kieu`/`tiep_vien`/`so_hiep_toi_da` (mục hoãn của 3.12) — phải thêm tay.
  - [x] 4.2 `tests/test_tran_05.gd` theo AC 5. Kiểm thêm: đầu hiệp có tiếp viện thì quân mới xuất hiện đúng ô; sau khi dùng mưu kế bàn không còn `L`.

- [ ] **Task 5: Kiểm tra, build, bàn giao** (AC: 3, 6, 7)
  - [x] 5.1 `tools/test.sh` xanh 4/4.
  - [x] 5.2 Chụp màn hình GoPeak (`tools/chay.sh --dev --tran=5`): bàn đầu trận, ô báo tiếp viện, nút Vườn không nhà trống.
  - [x] 5.3 Hướng dẫn tác giả đánh tay bằng tiếng Việt (từng nước, thấy gì là đúng) trong Completion Notes.
  - [ ] 5.4 Build web + deploy itch (AC 6). *Build xong (10,6 MB nén). Deploy chưa làm: lệnh đẩy itch bị chặn ở quyền của phiên AI — chờ tác giả cho phép hoặc tự chạy `tools/deploy_itch.sh`.*
  - [x] 5.5 Cập nhật story, `sprint-status.yaml`; commit.

### Review Findings

*Code review 2026-10-28 (Blind Hunter, Edge Case Hunter, Acceptance Auditor). Hai lớp đã chạy lại headless bằng luật thật: mọi bàn, máu trong `tran_05_loi_giai.md` khớp; `tools/test.sh` xanh 773/773.*

- [x] [Review][Defer] Áp lực Giữ ải tới hiệp 5 và mưu kế có lợi rõ: không làm được với quân + chỉ số đã chốt — deferred, tác giả chốt 2026-10-28 giữ bàn cũ (trận giới thiệu). Mô phỏng ~105 bố cục (9 thử tay, 96 sinh ngẫu nhiên theo khuôn AC 1, tìm chùm bằng luật thật): bàn thắng được thì lối tốt nhất luôn 9/9 máu cả khi không dùng mưu kế; còn lại là bàn không thắng nổi. Bàn hiện tại cũng có lối thắng 9/9 (lời giải chuẩn giữ 2/3 cho Dư để dạy chặn tiếp viện). Nguyên nhân: Bộ binh/Kỵ binh Giữ ải nhắm ô ải chứ không nhắm tướng, tướng gây ~3 sát thương/hiệp + Dư kéo/đẩy xuống sông, giặc tổng 9 máu. Cần story cân bằng (luật/chỉ số) hoặc trận 6+.
- [x] [Review][Patch] Sửa chữ AC 2: "ô báo tiếp viện" nằm ở bàn của hiệp trước khi tiếp viện tới, không phải bàn đầu trận (tác giả chốt 2026-10-28) [_bmad-output/implementation-artifacts/3-14-tran-5-giu-ai.md:27]
- [x] [Review][Patch] Lý do dùng mưu kế ở hiệp 1 có câu sai ("Cung kỵ cũng còn sống để bắn tiếp": Lão hạ được Cung kỵ từ `3,5`); tên mục "Né tên" và bước Dư→`5,7` dạy sai ý (Cung kỵ gục ngay ở bước 2; thật ra Dư đi để kịp tới `7,7` ở hiệp 2) [game/data/tran/tran_05_loi_giai.md:43]
- [x] [Review][Patch] "cuối hiệp trước, ô quân mới được đánh dấu" sai thời điểm: ô được báo ở pha chuẩn bị của hiệp trước, hiện suốt lượt người chơi hiệp đó (dòng 72 đã đúng) [game/data/tran/tran_05_loi_giai.md:16]
- [x] [Review][Patch] `thu_tu_dich` của level chỉ so với chuỗi chép tay; thiếu kiểm thứ tự quân Nguyên trong `level.units` đúng thứ tự đọc bàn như `test_tran_04.gd:40-45` [game/tests/test_tran_05.gd:86]
- [x] [Review][Patch] Test đứng yên chỉ kiểm lý do thua, không kiểm quân vào ải là Kỵ binh tiếp viện ở `4,7` [game/tests/test_tran_05.gd:170]
- [x] [Review][Patch] `match step.kind` không có nhánh mặc định: bước lạ làm `command` null, test sập thay vì trượt rõ ràng [game/tests/test_tran_05.gd:141]
- [x] [Review][Patch] So đòn đã báo bỏ qua kiểu đòn (ô/hướng) [game/tests/test_tran_05.gd:115]
- [x] [Review][Patch] Test dữ liệu chưa kiểm ô tiếp viện đi được và không phải `A` (AC 1) [game/tests/test_tran_05.gd:80]
- [x] [Review][Defer] Test chập chờn `test_battle_view.gd › test_preview_clears_when_attack_animation_starts` trượt 1 lần rồi xanh [game/tests/test_battle_view.gd] — deferred, pre-existing

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
- Mô phỏng headless bằng luật thật (script tạm `sim5.gd` trong scratchpad, không thuộc repo): chế độ đứng yên, tìm chùm (beam 30–60, chấm điểm sau pha địch), không dùng mưu kế, đánh ngẫu nhiên.
  - Bản nháp `tran_05.json` (08:28, tướng hàng 5): thắng dễ cả khi **không** dùng mưu kế; Cung kỵ + 1 Bộ binh gục ngay hiệp 1; ngẫu nhiên 300 ván thắng 10.
  - Ba bố cục khác (v2–v4) và hai phương án tăng quân (GDD gốc 4 + 1/hiệp = 8 quân; 3 + tiếp viện hiệp 2/3/4): **tất cả đều thắng được không cần mưu kế**, tướng còn 8–9/9 máu. Kết luận: với chỉ số hiện hành, 5 hiệp Giữ ải không ép được mưu kế bắt buộc → hỏi tác giả; tác giả chốt **trận giới thiệu** (mưu kế giúp, không bắt buộc), giữ quân đã chốt.
  - Bố cục chọn (v4): Kỵ binh tiếp viện ở `7,7` cùng hàng ải → đứng yên thì **thua ở hiệp 3** (Kỵ binh phi vào ải `4,7`), nên tiếp viện ảnh hưởng thật và người chơi phải học chặn ô tiếp viện. Bộ binh khởi đầu kề kho; không dùng mưu kế ở hiệp 1 thì Bộ binh vừa bị lao trúng hồi lại 3 máu (đã chạy thử).
  - Lời giải: beam tìm, rút gọn hiệp 3–5 còn "kết thúc lượt", phát lại bằng luật thật: thắng hiệp 5, Khoái 3/3, Lão 3/3, Dư 2/3, 0 lỗi validate.
- Chụp GoPeak (`--dev --tran=5`): bàn đầu trận khớp sơ đồ; bấm tay hiệp 1 → 2 đúng từng ô như lời giải, ô báo tiếp viện `7,7` hiện ô vàng có mũi tên. Nút mưu kế bị khóa trong lúc hoạt ảnh đi chạy (đúng thiết kế 2.11) — bấm lại sau khi đồng quân dừng.
- `tools/test.sh` 773/773 GUT (+4 `test_tran_05.gd`), 173 kịch bản đã duyệt, 2 chưa duyệt (`tran_01_ne_o_do`, `tran_05_loi_giai`), 0 chưa đạt.

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Trận 5 là **trận giới thiệu** (tác giả chốt 2026-10-27): Vườn không nhà trống và chặn tiếp viện là cách thắng gọn được dạy trong lời giải, không phải cách duy nhất.
- GDD dòng trận 5 (Campaign Structure) sửa theo Quyết định 1: "2 Bộ binh, 1 Cung kỵ; +1 Kỵ binh hiệp 3".
- **Tác giả đánh tay** (AC 3): `tools/chay.sh --dev --tran=5`, làm theo `game/data/tran/tran_05_loi_giai.md`. Thấy bảng **Thắng** ở cuối hiệp 5, Khoái 3/3, Lão 3/3, Dư 2/3 là đúng. Xong thì nói "duyệt" để bật `da_duyet: true` cho `tran/tran_05_loi_giai.json`.
- Deploy itch chưa làm (xem Task 5.4).

### File List

- `game/data/tran/tran_05.json` (mới)
- `game/data/tran/tran_05_loi_giai.md` (mới)
- `game/tests/kich_ban/tran/tran_05_loi_giai.json` (mới, `da_duyet: false`)
- `game/tests/test_tran_05.gd` (mới)
- `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` (dòng trận 5)
- `_bmad-output/implementation-artifacts/3-14-tran-5-giu-ai.md`, `sprint-status.yaml`
