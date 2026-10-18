---
title: 'Đề xuất thay đổi: tăng độ khó prototype (giới hạn hiệp, làng và Lòng dân)'
date: '2026-10-18'
status: 'đã duyệt 2026-10-18, đã áp dụng'
mode: 'batch'
scope: 'Vừa (sắp lại backlog E3–E4, sửa GDD và kiến trúc)'
---

# Đề xuất thay đổi: tăng độ khó prototype

## 1. Vấn đề

**Phát hiện khi nào:** 2026-10-17, khi tác giả nhờ đánh giá chiến thuật trên bàn 7×7. Chưa có story luật nào được làm; mới xong Story 0.1 và 0.2.

**Vấn đề:** ở trận Tiêu diệt, người chơi né đòn quá dễ, nên trận thiếu áp lực. Ba luật cộng lại gây ra điều này:
- tướng đi 3 ô và đi xuyên được quân mình (đứng giữa bàn thì tới được 25/49 ô);
- địch đánh vào ô, rời ô đỏ là né được;
- trận Tiêu diệt không giới hạn số hiệp và không có gì phải bảo vệ.

Kết quả là người chơi gần như hiệp nào cũng né được hết đòn rồi thong thả hạ địch. Dấu hiệu "dừng lại suy nghĩ trước nước đi" (Success Metrics) có nguy cơ không xuất hiện.

**Loại thay đổi:** yêu cầu mới từ người quyết spec (tác giả).

**Quyết định của tác giả (2026-10-17 và 2026-10-18):**
1. Trận Tiêu diệt có **giới hạn số hiệp**: hết hiệp mà chưa hạ hết quân Nguyên thì **thua**.
2. Thêm **ô Làng** và thanh **Lòng dân** chung của trận (ví dụ 3 điểm). Làng bị trúng đòn thì −1; hết Lòng dân thì **thua**.
3. **Bộ binh và Kỵ binh nhắm cái gần nhất** trong số tướng và làng. Cung kỵ vẫn chỉ nhắm tướng.
4. Người chơi đẩy hoặc kéo quân Nguyên **va vào làng cũng trừ Lòng dân**.
5. Hướng dẫn bằng **dòng gợi ý đầu trận** (Story gợi ý đã có). Trận 1–2 là trận dạy chơi: dễ, không giới hạn hiệp, không có làng.
6. **Thêm 1 trận mới** ("Bảo vệ làng"), chuỗi thành **6 trận**, để mỗi trận vẫn chỉ dạy một luật mới.
7. **Chấp nhận thêm khoảng 1 tuần**: prototype khoảng 140 giờ, 14 tuần.

## 2. Phân tích ảnh hưởng

### Epic
| Epic | Ảnh hưởng |
|---|---|
| E0 | Không đổi |
| E1 | Không đổi. Bộ nạp trận (Story 1.1) chưa cần biết khóa mới; khóa mới được thêm ở các story E3 |
| E2 | Không đổi. AI ở Story 2.6 vẫn nhắm tướng; luật nhắm làng thêm ở E3. Mốc tự chơi hết E2 giữ nguyên |
| E3 | Thêm 3 story, đánh số lại. Giờ: ~35 → **~45** |
| E4 | Trận 5 thành trận 6, chuỗi 6 trận. Story gợi ý luật **không còn trong danh sách cắt được**, vì nó là phần hướng dẫn |

### Story (chưa story nào trong số này bắt đầu)
- **Thêm:** Giới hạn hiệp (Tiêu diệt), Làng và Lòng dân, Trận 4 "Bảo vệ làng".
- **Sửa:** Trận 3 (thêm giới hạn hiệp), Trận Giữ ải đầu tiên (thành trận 5), Mưu kế (mở theo trận mới), Chuỗi trận, Trận cuối (thành trận 6), Tinh chỉnh, Gợi ý luật, Chơi thử.
- **Đánh số lại** E3 (3.5 → 3.14) và đổi tên khóa trong `sprint-status.yaml`. Chỉ có file story của 0.1 và 0.2, nên đánh số lại không ảnh hưởng file nào đã có.

### Tài liệu cần sửa
- **GDD:** Win/Loss, Enemy AI, Terrain, Campaign Structure, Difficulty Curve, Level Design, Asset Requirements, Development Epics, Out of Scope, chỉ mục giả định; thêm dòng vào decision-log.
- **Kiến trúc:** bảng hệ thống, `BattleState`, định dạng file trận (khóa mới, ký hiệu `D`), danh sách sự kiện, Bảng thứ tự phân giải.
- **Epics:** FR mới (FR47, FR48), sửa FR3, FR23, FR34, FR36, FR43; bảng giờ; bản đồ phủ FR; story.
- **project-context.md:** không có luật trò chơi cụ thể cần sửa.
- **UX:** không có tài liệu UX riêng. Thêm tiêu chí HUD (số hiệp "2/4", thanh Lòng dân) vào story.
- **Trang giới thiệu (artifact):** đang ghi 5 trận; cập nhật sau khi duyệt nếu tác giả muốn.

### Kỹ thuật
Chưa có code luật, nên không phải sửa code. Bộ nạp, `BattleState`, AI và bảng phân giải chỉ cần thêm phần mới; không phá thiết kế hiện tại.

## 3. Hướng đi đề xuất

**Chọn: Điều chỉnh trực tiếp** (thêm và sửa story trong cấu trúc epic hiện có).
- Không cần quay lui: Story 0.1, 0.2 không liên quan.
- Không cần thu hẹp MVP: tác giả chấp nhận thêm khoảng 10 giờ.
- **Công sức:** thấp đến vừa (~10 giờ code + ~1 giờ sửa tài liệu). **Rủi ro:** thấp. Luật làng dùng lại cơ chế có sẵn: vật cản như rừng, va chạm, kiểm tra thua.
- **Phương án cắt nếu E3 trễ** (thêm vào danh sách cũ): bỏ trận 4 "Bảo vệ làng" và đặt làng vào trận 3. Giới hạn hiệp không cắt, vì tốn rất ít.

## 4. Chi tiết thay đổi

### 4.1 Luật mới (spec)

**Giới hạn hiệp (trận Tiêu diệt)**
- File trận có khóa `so_hiep_toi_da` (số nguyên). Không ghi thì không giới hạn (trận 1–2).
- Thua khi **kết thúc bước 4 (cuối hiệp) của hiệp cuối** mà còn quân Nguyên trên bàn. Vì vậy, nếu địch đánh trúng nhau trong pha ra đòn của hiệp cuối thì vẫn tính. **[MẶC ĐỊNH, duyệt qua kịch bản luật]**
- HUD hiện "Hiệp 2/4"; hiệp cuối có màu nổi bật.

**Làng và Lòng dân**
- Ký hiệu địa hình **`D`** (làng dân). Không đi vào được. Không có máu, không bị phá.
- Làng **chặn đường đi, lao, tên và xung phong như rừng**. Vật đầu tiên trên hàng của Trần Khánh Dư là làng thì không kéo được. **[MẶC ĐỊNH, duyệt qua kịch bản luật]**
- **Làng bị trúng** (mỗi lần −1 Lòng dân) khi:
  - đòn chém của Bộ binh nhắm vào ô làng;
  - Kỵ binh xung phong mà vật đầu tiên trên hàng là làng;
  - lao của Phạm Ngũ Lão hoặc tên của Cung kỵ bị làng chặn **[MẶC ĐỊNH, duyệt qua kịch bản luật]**;
  - một quân bị đẩy hoặc kéo va vào làng: quân đó mất 1 máu như va chạm với rừng, **và** Lòng dân −1.
- File trận có khóa `long_dan` (ví dụ 3). Chỉ bắt buộc khi bàn có ô `D`.
- Lòng dân về 0 thì **thua ngay**. Kiểm tra sau mỗi lần mất Lòng dân, cả trong lượt người chơi lẫn pha địch. Trùng với thắng thì **thắng được ưu tiên** (theo luật chung).
- "Chơi lại hiệp" trả lại cả Lòng dân như đầu lượt người chơi. Xem trước kết quả đòn hiện "−1 Lòng dân" nếu có.
- HUD hiện "Lòng dân 3/3".

**Enemy AI (sửa)**
- Trận Tiêu diệt: **Bộ binh và Kỵ binh** chọn mục tiêu gần nhất (theo số bước đi) **trong số tướng và làng**. Hòa giữa một tướng và một làng thì **ưu tiên làng**. **[MẶC ĐỊNH, duyệt qua kịch bản luật]**
- Cung kỵ vẫn chỉ nhắm tướng.
- Trận Giữ ải: không đổi (Kỵ binh và Bộ binh nhắm ô ải).

### 4.2 GDD (`gdds/gdd-GameTest-2026-10-15/gdd.md`)

| Mục | Cũ | Mới |
|---|---|---|
| Win/Loss Conditions | Tiêu diệt: thắng khi hạ hết, thua khi mọi tướng gục | Thêm: thua khi hết `so_hiep_toi_da` hiệp (nếu trận có), hoặc khi Lòng dân về 0 (nếu trận có làng). Thêm các luật ở 4.1 |
| Enemy AI, dòng Mục tiêu | Tướng gần nhất; Giữ ải: Kỵ binh và Bộ binh nhắm ô ải | Thêm luật nhắm làng ở 4.1 |
| Terrain | 5 loại ô | Thêm dòng `D` **Làng** |
| Out of Scope "Để sau prototype" | "...thuyền, làng cần bảo vệ, đồi..." | Bỏ "làng cần bảo vệ" (đã vào prototype) |
| Campaign Structure | 5 trận | 6 trận (bảng dưới) |
| Mưu kế mở dần | VKNT từ trận 4, Sát Thát từ trận 5 | VKNT từ **trận 5**, Sát Thát từ **trận 6** |
| Difficulty Curve | Trận 1–3 thắng được không mất tướng ngay lần đầu; trận 4–5 có thể phải chơi lại hiệp | **Trận 1–2** (dạy chơi) thắng được không mất tướng ngay lần đầu; **trận 3–6** có thể phải chơi lại hiệp |
| Level Design: Level Types | Tiêu diệt: không có tiếp viện, bài toán thuần túy | Thêm: từ trận 3 có giới hạn hiệp; có thể có làng |
| Asset Requirements | 5 loại ô + ô ải | 6 loại ô + ô ải; HUD số hiệp và Lòng dân |
| Development Epics | E3 ~35 giờ, tuần 7–10; E4 tuần 11–13; tổng 130 | E3 **~45 giờ, tuần 7–11**; E4 **tuần 12–14**; tổng **~140** |
| Phương án cắt khi E2 trễ | cắt trận 5 và Cung kỵ | cắt **trận 6** và Cung kỵ |

**Chuỗi 6 trận mới:**

| Trận | Kiểu | Luật được dạy | Quân Nguyên | Địa hình chính | Giới hạn | Làng |
|---|---|---|---|---|---|---|
| 1 | Tiêu diệt | Né ô đỏ, đẩy địch xuống sông | 3 Bộ binh | Sông | Không | Không |
| 2 | Tiêu diệt | Kỵ binh xung phong, rừng chặn, địch đánh trúng nhau | 2 Kỵ binh, 1 Bộ binh | Rừng, sông | Không | Không |
| 3 | Tiêu diệt | Trần Khánh Dư: đòn kéo, hầm chông, **giới hạn hiệp** | 2 Bộ binh, 2 Cung kỵ | Hầm chông, rừng | Có | Không |
| 4 (mới) | Tiêu diệt | **Làng và Lòng dân** | chốt khi thiết kế trận (gợi ý 2 Bộ binh, 1 Kỵ binh, 1 Cung kỵ) | Làng, sông, rừng | Có | Có |
| 5 | Giữ ải | Kho lương, Vườn không nhà trống, quân tiếp viện | 4 quân, +1 mỗi hiệp | Kho lương, sông | 5 hiệp | Không |
| 6 | Giữ ải | Tổng hợp, Sát Thát | 5 quân, +1–2 mỗi hiệp | Đủ các loại | 5 hiệp | Tùy |

Trận 1–2 là phần hướng dẫn: mỗi trận có dòng gợi ý đầu trận. Số hiệp cụ thể chốt khi thiết kế từng trận (kèm lời giải).

**decision-log.md:** thêm các dòng CHỐT tương ứng (ngày 2026-10-17 và 2026-10-18).

### 4.3 Kiến trúc (`game-architecture.md`)
- **Bảng hệ thống #8:** "sông, rừng, hầm chông, kho lương, ô ải" → thêm "làng (Lòng dân)". **#5 AI:** thêm "mục tiêu gồm tướng và làng".
- **`BattleState`:** thêm `long_dan` (hiện tại, tối đa) và `so_hiep_toi_da`.
- **File trận:** thêm khóa `so_hiep_toi_da`, `long_dan`; ký hiệu địa hình `D` làng. Bộ nạp báo lỗi khi bàn có `D` mà thiếu `long_dan`, hoặc `so_hiep_toi_da` ≤ 0.
- **Sự kiện:** thêm "làng bị trúng" (kèm Lòng dân còn lại) và "hết hiệp".
- **Bảng thứ tự phân giải:**
  - Di chuyển cưỡng bức, dòng mới: "Làng `D`: Dừng. Quân bị đẩy mất 1 máu. Lòng dân −1."
  - Đòn của tướng: lao bị làng chặn thì Lòng dân −1 **(mặc định)**. Trần Khánh Dư không kéo được nếu vật đầu tiên là làng **(mặc định)**.
  - Pha địch: Kỵ binh trúng làng thì Lòng dân −1; Cung kỵ bị làng chặn thì Lòng dân −1 **(mặc định)**; Bộ binh chém ô làng thì Lòng dân −1.
  - Gục, thắng, thua: thêm "Lòng dân về 0 thì thua ngay, kiểm tra sau mỗi lần mất Lòng dân" và "Tiêu diệt có `so_hiep_toi_da`: kết thúc bước 4 của hiệp cuối mà còn quân Nguyên thì thua **(mặc định)**".
- **Thư mục kịch bản luật:** thêm nhóm `lang/` và `gioi_han_hiep/`.

### 4.4 Epics (`epics.md`)

**FR:**
- FR3: "5 loại ô" → "6 loại ô (thêm làng)".
- FR23: thêm "Tiêu diệt có làng: Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất, hòa thì ưu tiên làng [MẶC ĐỊNH]; Cung kỵ chỉ nhắm tướng".
- FR34: "Vườn không nhà trống từ trận 4, Sát Thát từ trận 5" → "từ trận 5, từ trận 6".
- FR36: thêm "thua khi hết số hiệp tối đa (nếu có) hoặc Lòng dân về 0".
- FR43: "Chuỗi 5 trận" → "Chuỗi 6 trận".
- **FR47 (mới):** Làng và Lòng dân (theo 4.1).
- **FR48 (mới):** Giới hạn hiệp cho trận Tiêu diệt (theo 4.1).

**Bảng giờ:** E3 ~45 giờ, tuần 7–11, 14 story; E4 tuần 12–14. Tổng ~140.
**Danh sách cắt khi trễ:** Cung kỵ (2.15), trận 6 (4.5), trau chuốt xem trước (4.6), trận 4 "Bảo vệ làng" (3.8, dồn làng vào trận 3). **Bỏ gợi ý luật (4.8) khỏi danh sách cắt.**

**E3 sau khi đánh số lại:**

| Mới | Cũ | Story |
|---|---|---|
| 3.1 | 3.1 | Rừng và vật cản chặn đòn |
| 3.2 | 3.2 | Chơi lại hiệp |
| 3.3 | 3.3 | Trận 2 |
| 3.4 | 3.4 | Hầm chông |
| **3.5** | mới | **Giới hạn hiệp (Tiêu diệt)** |
| 3.6 | 3.5 | Trận 3 (thêm giới hạn hiệp) |
| **3.7** | mới | **Làng và Lòng dân** |
| **3.8** | mới | **Trận 4: Bảo vệ làng** |
| 3.9 | 3.6 | Kho lương |
| 3.10 | 3.7 | Quân tiếp viện |
| 3.11 | 3.8 | Nhiệm vụ Giữ ải |
| 3.12 | 3.9 | Mưu kế Vườn không nhà trống và nút mưu kế |
| 3.13 | 3.10 | Mưu kế Sát Thát |
| 3.14 | 3.11 | Trận 5 (Giữ ải) |

**Story mới 3.5: Giới hạn hiệp (Tiêu diệt)**
- Cho file trận Tiêu diệt có `so_hiep_toi_da: 4`, thì HUD hiện "Hiệp 1/4", hiệp cuối có màu nổi bật.
- Khi kết thúc bước cuối hiệp của hiệp 4 mà còn quân Nguyên, thì hiện "Thua: hết hiệp".
- Khi quân Nguyên cuối cùng gục trong pha ra đòn của hiệp 4 (địch đánh trúng nhau), thì thắng.
- Khi file trận không có `so_hiep_toi_da`, thì không giới hạn, HUD chỉ hiện "Hiệp 3".
- Và bộ nạp báo lỗi tiếng Việt nếu `so_hiep_toi_da` ≤ 0. Có kịch bản trong `gioi_han_hiep/`, đã duyệt và đạt.

**Story mới 3.7: Làng và Lòng dân**
- Cho bàn có ô `D` và `long_dan: 3`, thì làng hiện như một ô riêng, HUD hiện "Lòng dân 3/3".
- Khi Bộ binh chém ô làng, Kỵ binh xung phong trúng làng, hoặc lao/tên bị làng chặn, thì Lòng dân −1.
- Khi đẩy hoặc kéo quân Nguyên va vào làng, thì quân đó mất 1 máu và Lòng dân −1.
- Khi Lòng dân về 0, thì thua ngay; trùng với thắng thì thắng.
- Khi pha địch chuẩn bị, thì Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất, hòa thì ưu tiên làng; Cung kỵ chỉ nhắm tướng. F3 hiện rõ quân nào đang nhắm làng.
- Khi chơi lại hiệp, thì Lòng dân về như đầu lượt người chơi. Xem trước kết quả đòn hiện "−1 Lòng dân".
- Và làng chặn đường đi, lao, tên, xung phong; Trần Khánh Dư không kéo được nếu vật đầu tiên là làng. Bộ nạp báo lỗi nếu có `D` mà thiếu `long_dan`. Có kịch bản trong `lang/`, đã duyệt và đạt.

**Story mới 3.8: Trận 4: Bảo vệ làng**
- Cho AI đề xuất `tran_04.json` (3 tướng; Tiêu diệt; có làng, `long_dan` và `so_hiep_toi_da`), thì kèm lời giải không mất tướng và không mất Lòng dân trong `tran_04_loi_giai.md`.
- Khi tác giả đánh lại đúng lời giải, thì thắng; lời giải thành kịch bản tự động trong `tests/kich_ban/tran/`.
- Và trận chỉ giới thiệu một luật mới (làng). Có dòng gợi ý đầu trận về làng.

**Story sửa:**
- **3.6 Trận 3:** thêm "file trận có `so_hiep_toi_da`; lời giải thắng trong số hiệp đó".
- **3.12 VKNT:** "trận có mưu kế" giữ nguyên; tham chiếu trận 5.
- **3.14 Trận 5 (Giữ ải):** đổi tên file `tran_04.json` → `tran_05.json`, `tran_04_loi_giai.md` → `tran_05_loi_giai.md`.
- **4.2 Chuỗi trận:** "5 trận" → "6 trận"; mưu kế mở từ trận 5 và 6.
- **4.5 Trận 6:** đổi từ "Trận 5", file `tran_06.json`; khi cắt thì chuỗi còn 5 trận và Sát Thát mở từ trận 5.
- **4.6 Tinh chỉnh 6 trận:** "cả 5 lời giải" → "cả 6 lời giải" (từ 2.14, 3.3, 3.6, 3.8, 3.14, 4.5).
- **4.7:** "trận 5" → "trận 6"; "5 trận" → "6 trận".
- **4.8 Gợi ý luật đầu trận:** bỏ dòng "cắt được nếu trễ"; ghi rõ đây là phần hướng dẫn; thêm ví dụ gợi ý cho trận 3 ("Phải hạ hết quân Nguyên trong 4 hiệp.") và trận 4 ("Bảo vệ làng: mỗi lần làng bị đánh, Lòng dân giảm 1.").
- **4.9 Chơi thử:** "thắng trận 1–3 không mất tướng ngay lần đầu" → "trận 1–2"; thêm mục quan sát "người chơi có thua vì hết hiệp hoặc mất Lòng dân không, và có chơi lại không".

### 4.5 `sprint-status.yaml`
Đổi khóa E3 theo bảng đánh số mới; thêm `3-5-gioi-han-hiep-tieu-diet`, `3-7-lang-va-long-dan`, `3-8-tran-4-bao-ve-lang`; đổi `4-5-tran-5` → `4-5-tran-6`, `4-6-tinh-chinh-5-tran` → `4-6-tinh-chinh-6-tran`, `3-11-tran-4-giu-ai` → `3-14-tran-5-giu-ai`. Mọi story mới ở trạng thái `backlog`.

## 5. Bàn giao

- **Phạm vi:** Vừa. Sắp lại backlog và sửa tài liệu, không cần lập lại kế hoạch.
- **Sau khi tác giả duyệt:** AI (vai Developer/PO) sửa GDD, decision-log, kiến trúc, epics và sprint-status đúng như mục 4.
- **Tác giả:** duyệt các luật **[MẶC ĐỊNH]** qua kịch bản luật khi tới Story 3.5 và 3.7.
- **Tiêu chí xong:** mọi tài liệu khớp nhau về 6 trận, FR47–FR48, giờ E3 ~45; `sprint-status.yaml` có đúng các khóa mới; `tools/test.sh` vẫn đạt (không đổi code).
