---
stepsCompleted: ['step-01-document-discovery', 'step-02-gdd-analysis', 'step-03-epic-coverage-validation', 'step-04-ux-alignment', 'step-05-epic-quality-review', 'step-06-final-assessment']
filesIncluded:
  gdd: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md
  gdd_decision_log: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/decision-log.md
  gdd_epic_overview: _bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/epics.md
  architecture: _bmad-output/planning-artifacts/game-architecture.md
  epics: _bmad-output/planning-artifacts/epics.md
  reference: [_bmad-output/project-context.md, _bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/brief.md]
  ux: none
---
# Implementation Readiness Assessment Report

**Date:** 2026-10-17
**Project:** GameTest (Chống Nguyên Mông)

## Document Inventory

| Loại | File dùng để đánh giá | Ghi chú |
|---|---|---|
| GDD | `gdds/gdd-GameTest-2026-10-15/gdd.md` (39 KB, 16/10) | Kèm `decision-log.md`, `history-notes-1288.md` |
| Kiến trúc | `game-architecture.md` (68 KB, 17/10) | |
| Epic & Story | `epics.md` ở gốc planning-artifacts (54 KB, 17/10) | Bản chi tiết, là nguồn chính |
| Epic tổng quát | `gdds/gdd-GameTest-2026-10-15/epics.md` (4,6 KB, 16/10) | Chỉ dùng để đối chiếu, không phải bản trùng |
| UX | Không có | ⚠️ Cảnh báo: không có tài liệu UX riêng |
| Tham khảo | `project-context.md`, brief, addendum | |

## GDD Analysis

GDD không đánh số FR/NFR. Các yêu cầu dưới đây do người đánh giá trích ra và đánh số, chia theo phạm vi: **[P0]** = prototype (E0–E4), **[P1]** = giai đoạn 1 (chỉ dựng khung, chưa chia chi tiết).

### Functional Requirements

**Bàn cờ & di chuyển**
- FR1 [P0]: Bàn cờ lưới ô vuông 7×7, đọc từ file dữ liệu trận (bố cục địa hình, vị trí quân, lịch tiếp viện, thứ tự hành động của địch), không viết cứng trong code.
- FR2 [P0]: Di chuyển 4 hướng, không chéo, khoảng cách Manhattan; tướng đi tối đa 3 ô; quân Nguyên 2–3 ô tùy loại.
- FR3 [P0]: Không có chi phí địa hình: ô hoặc đi được, hoặc bị chặn. Sông, rừng, kho lương chặn đường đi.
- FR4 [P0]: Được đi xuyên qua quân mình, không xuyên qua quân địch; không có vùng khống chế, không có đòn khi rời ô kề.
- FR5 [P0]: Toàn bộ bàn luôn hiển thị (không có tầm nhìn, độ cao).
- FR6 [P0]: Khi chọn tướng, tô sáng ô đi được; rê chuột lên ô thì hiện đường đi.
- FR7 [P0]: Người chơi bấm ô đích, game tự chọn đường ít hầm chông nhất; hòa thì theo thứ tự hướng B→Đ→N→T. Ô sáng và đường đi hiện số máu sẽ mất. [MẶC ĐỊNH]

**Đơn vị**
- FR8 [P0]: 3 tướng, mỗi tướng 3 máu, đi 3 ô.
- FR9 [P0]: Nguyễn Khoái: đánh 1 ô kề, 2 sát thương, đẩy mục tiêu lùi 1 ô theo hướng đánh.
- FR10 [P0]: Phạm Ngũ Lão: phóng thẳng hàng, bay qua ô kề, trúng vật đầu tiên ở ô 2–4, 1 sát thương; rừng hoặc kho lương ở bất kỳ ô nào trên đường (kể cả ô kề) chặn lao; sông không chặn.
- FR11 [P0]: Trần Khánh Dư: kéo vật đầu tiên trên hàng trong vòng 3 ô về phía mình 2 ô (dừng sớm nếu bị chặn), 0 sát thương; chỉ kéo quân Nguyên; vật đầu tiên là tướng/rừng/kho lương thì không kéo được; mục tiêu đã đứng kề thì không có hiệu ứng.
- FR12 [P0]: Kỵ binh Mông Cổ: 2 máu, đi 3, xung phong thẳng hàng (đứng yên), 1 sát thương vào vật đầu tiên theo hướng đã báo; sông không chặn, rừng chặn; hàng trống tới mép bàn thì trượt.
- FR13 [P0]: Cung kỵ: 1 máu, đi 3, bắn ô thẳng hàng cách 2–3 ô, 1 sát thương; tên bay qua quân, chỉ rừng hoặc kho lương nằm giữa mới chặn.
- FR14 [P0]: Bộ binh Nguyên: 3 máu, đi 2, chém 1 ô kề, 1 sát thương.

**Trình tự hiệp & kinh tế hành động**
- FR15 [P0]: Bước 1, địch chuẩn bị: quân tiếp viện đã báo xuất hiện trước; nếu ô có người đứng (bất kể phe) thì quân tiếp viện bị hủy, người đứng mất 1 máu. Sau đó từng quân Nguyên (kể cả quân mới xuất hiện) di chuyển rồi báo đòn theo Enemy AI.
- FR16 [P0]: Báo trước đòn: ô bị nhắm tô đỏ; mỗi đòn có số thứ tự ra đòn (= thứ tự hành động) hiện trên bàn; Kỵ binh có mũi tên chỉ hướng.
- FR17 [P0]: Bước 2, lượt người chơi: mỗi tướng đi tối đa 3 ô rồi đánh 1 lần; có thể đánh mà không đi; đã đánh thì không đi được; thứ tự tướng tùy ý; nút "Kết thúc lượt".
- FR18 [P0]: Bước 3, địch ra đòn lần lượt theo đúng thứ tự đã báo.
- FR19 [P0]: Bước 4, cuối hiệp: quân Nguyên đứng kề kho lương hồi 1 máu (nếu kho còn và chưa dùng Vườn không nhà trống), không vượt máu tối đa; đánh dấu ô tiếp viện của hiệp sau.
- FR20 [P0]: Đòn địch gắn với ô (Kỵ binh gắn với hướng tính từ vị trí của nó); tướng rời ô thì né được.
- FR21 [P0]: Mọi đòn trúng mọi người đứng trên ô bị nhắm, không phân phe (kể cả đòn của tướng trúng tướng; địch trúng đồng đội).
- FR22 [P0]: Quân đang chuẩn bị đánh bị đẩy/kéo thì đòn dịch theo, giữ hướng và khoảng cách tương đối; dịch ra ngoài bàn thì hủy. [MẶC ĐỊNH]
- FR23 [P0]: Quân bị hạ trước lượt ra đòn thì đòn bị hủy.
- FR24 [P0]: Không có phản công, đòn khi rời ô kề, giới hạn thời gian mỗi lượt.

**Enemy AI**
- FR25 [P0]: AI tất định, đọc được. Thứ tự hành động theo file dữ liệu trận; quân tiếp viện hành động sau quân đã có trên bàn.
- FR26 [P0]: Mục tiêu là tướng gần nhất (theo số bước đi). Giữ ải: Kỵ binh và Bộ binh nhắm ô ải; Cung kỵ vẫn nhắm tướng gần nhất.
- FR27 [P0]: Chọn ô đứng trong tầm đi, ưu tiên ô đánh trúng được mục tiêu; nếu không có thì đi tới ô gần mục tiêu nhất. Hòa điểm theo B→Đ→N→T.
- FR28 [P0]: AI không tránh ô đỏ của đồng đội, không tránh địa hình nguy hiểm (kể cả hầm chông), không phối hợp.

**Đẩy/kéo, va chạm, địa hình**
- FR29 [P0]: Va chạm: đẩy/kéo vào quân khác hoặc vật cản (rừng, kho lương) thì quân bị đẩy đứng yên, cả hai mất 1 máu; mép bàn chỉ làm quân bị đẩy mất 1 máu.
- FR30 [P0]: Sông: quân Nguyên bị đẩy/kéo xuống sông thì chết ngay; tướng bị đẩy vào sông tính như va chạm (mất 1 máu, đứng yên). Sông không chặn lao, tên, xung phong.
- FR31 [P0]: Rừng: không đi vào được, chặn lao/tên/xung phong; bị đẩy vào là va chạm.
- FR32 [P0]: Hầm chông: đi vào được; bất kỳ quân nào vào ô (tự đi, bị đẩy, bị kéo, kể cả đi ngang qua) mất 1 máu mỗi ô; gục giữa đường thì dừng; đứng yên không mất thêm.
- FR33 [P0]: Kho lương: không đi vào được, chặn đường đánh; hồi máu cho quân Nguyên đứng kề (FR19); bị đốt bởi Vườn không nhà trống.
- FR34 [P0]: Thứ tự phân giải đầy đủ theo "Bảng thứ tự phân giải" trong `game-architecture.md`.

**Mưu kế**
- FR35 [P0]: Mỗi mưu kế dùng 1 lần mỗi trận, dùng bất cứ lúc nào trong lượt người chơi, không tốn hành động.
- FR36 [P0]: Sát Thát: trong lượt người chơi đó, mọi đòn có gây sát thương của tướng +1 sát thương; không cộng cho đòn kéo, va chạm, hầm chông, mép bàn.
- FR37 [P0]: Vườn không nhà trống: mọi kho lương thành ô trống đi vào được; mọi quân Nguyên mất 1 máu; từ đó đến hết trận quân Nguyên không hồi máu.
- FR38 [P0]: Mưu kế mở dần theo trận: Vườn không nhà trống từ trận 4, Sát Thát từ trận 5. [ASSUMPTION]

**Hoàn tác & xem trước**
- FR39 [P0]: Hủy nước đi gần nhất, chỉ khi tướng đó chưa đánh.
- FR40 [P0]: Chơi lại hiệp 1 lần mỗi trận: đưa bàn về trạng thái đầu lượt người chơi.
- FR41 [P0]: Xem trước kết quả đòn: rê chuột lên mục tiêu thì hiện bóng mờ vị trí cuối của các quân bị ảnh hưởng và số máu sau đòn; bản tối giản ở E2, trau chuốt ở E4.
- FR42 [P0]: Rê chuột lên quân hiện máu, đòn sắp đánh, thứ tự ra đòn; rê lên ô hiện loại địa hình.

**Thắng/thua & nhiệm vụ**
- FR43 [P0]: Nhiệm vụ Tiêu diệt: thắng khi hạ hết quân Nguyên (không có tiếp viện); thua khi cả 3 tướng gục.
- FR44 [P0]: Nhiệm vụ Giữ ải: thắng khi qua hết 5 hiệp mà không quân Nguyên nào vào ô ải; thua khi cả 3 tướng gục hoặc quân Nguyên vào ô ải bằng bất kỳ cách nào (kể cả bị kéo vào).
- FR45 [P0]: Tướng còn 0 máu thì gục, bị nhấc khỏi bàn, không chiếm ô. [MẶC ĐỊNH] [KIỂM TRA E4]
- FR46 [P0]: Kiểm tra thắng/thua sau mỗi lần có quân gục, cả trong lượt người chơi và pha địch; thắng và thua cùng lúc thì thắng được ưu tiên.
- FR47 [P0]: Sau mỗi trận, tướng hồi đầy máu (prototype).

**Điều khiển**
- FR48 [P0]: Điều khiển toàn bằng bấm chuột, không kéo thả. Đánh: bấm ô/mục tiêu trong tầm; tướng đã đi thì bấm thêm lần nữa để xác nhận.
- FR49 [P0]: Phím tắt: `1` `2` `3` chọn tướng, `Q` `W` mưu kế, `Z` hủy, `Space` kết thúc lượt, `R` chơi lại hiệp.

**Chuỗi trận prototype & tiến trình**
- FR50 [P0]: 5 trận cố định làm tay, mỗi trận dạy tối đa 1 luật mới, theo bảng Campaign Structure (trận 1–3 Tiêu diệt; 4–5 Giữ ải; thành phần quân và địa hình như bảng).
- FR51 [P0]: Mỗi trận: bàn 7×7, 3–6 quân Nguyên khởi đầu, có ít nhất 1 lời giải không mất tướng, do người thiết kế tìm và kiểm tra.
- FR52 [P0]: Quân tiếp viện theo lịch trong dữ liệu trận (trận 4: +1/hiệp; trận 5: +1–2/hiệp), được báo trước một hiệp.
- FR53 [P0]: Màn hình chuyển trận; tên tạm "Trận 1–5", không có chữ kể chuyện.
- FR54 [P0]: Nút tua nhanh pha địch.
- FR55 [P0]: Tự lưu cục bộ trong trình duyệt sau mỗi trận.
- FR56 [P0]: Toàn bộ chữ trong game tách ra file riêng (sẵn sàng thêm tiếng Anh).

**Giai đoạn 1 (khung, chưa chia chi tiết, không thuộc phạm vi lần đánh giá này nhưng ghi lại để truy vết)**
- FR57 [P1]: Bản đồ roguelite 8–10 nút, 3 chặng, loại nút: trận thường, tinh nhuệ, sự kiện lịch sử, nghỉ quân; seed hiển thị được, cùng seed thì cùng bản đồ/trận/thưởng.
- FR58 [P1]: Thua một trận là hết lượt chơi; tướng gục trận trước vào trận sau còn 1 máu trừ khi qua nút Nghỉ quân.
- FR59 [P1]: Phần thưởng chọn 1 trong 3 (nâng cấp tướng, mưu kế mới tối đa 3, tướng mới); mở khóa meta tướng và mưu kế, không cộng chỉ số vĩnh viễn.
- FR60 [P1]: Trận Bạch Đằng: thủy triều, bãi cọc, thuyền.
- FR61 [P1]: Nội dung chữ: giới thiệu trận 1–2 dòng, sự kiện lịch sử, mô tả tướng, trích Hịch tướng sĩ kèm nguồn; ghi rõ hư cấu/dã sử.
- FR62 [P1]: Tranh minh họa, nhạc và âm thanh chất liệu truyền thống.

Tổng: **56 FR prototype [P0]** + **6 FR khung giai đoạn 1 [P1]** = 62.

### Non-Functional Requirements

- NFR1 (Hiệu năng): 60 FPS ổn định trên trình duyệt desktop, laptop văn phòng card tích hợp, suốt một trận 7×7.
- NFR2 (Kích thước): bản build tải về ≤ 50 MB.
- NFR3 (Thời gian tải): từ lúc mở link đến màn hình chính ≤ 10 giây ở mạng 20 Mbps.
- NFR4 (Nhịp độ): hoạt ảnh một pha địch ra đòn ≤ 3 giây (có tua nhanh, FR54).
- NFR5 (Nền tảng): Godot, xuất bản HTML5; chạy được trên Chrome, Firefox, Edge desktop bản mới nhất. Safari/di động không bắt buộc.
- NFR6 (Tất định): combat hoàn toàn tất định, không có xúc xắc hay tỷ lệ trúng; cùng trạng thái + cùng thao tác thì ra cùng kết quả.
- NFR7 (Dễ đọc): ô đỏ báo đòn là thứ nổi bật nhất trên màn hình; thứ tự ra đòn hiện bằng số lớn.
- NFR8 (Độ tin cậy): không có lỗi làm kẹt trận trong cả 5 trận.
- NFR9 (Lưu game): lưu cục bộ trong trình duyệt, tự lưu sau mỗi trận, dữ liệu lưu không hỏng.
- NFR10 (Bản địa hóa): tiếng Việt; chữ tách file riêng (trùng với FR56).
- NFR11 (Dữ liệu hóa): thêm hoặc sửa trận không cần lập trình.
- NFR12 (Khả năng chuyển cảm ứng): mọi thao tác là bấm, không kéo thả, để sau này làm bản cảm ứng không cần thiết kế lại.
- NFR13 (Tài sản prototype): 5 loại ô + ô ải, 3 tướng + 3 loại quân dạng đồng tròn chữ/biểu tượng; tối đa khoảng 10 SFX CC0, âm thanh là tùy chọn.

Tổng: **13 NFR**.

### Additional Requirements

- **Ngân sách và lịch:** 13 tuần × 10 giờ ≈ 130 giờ; E0 → E4 làm tuần tự bắt buộc.
- **Mốc kiểm tra hết tuần 8:** tác giả tự chơi trận 1; chán thì dừng lại sửa luật trước khi làm E3.
- **Phương án cắt khi E2 trễ:** cắt trận 5 và Cung kỵ; không cắt luật lõi (đánh vào ô, đẩy/kéo).
- **Duyệt luật [MẶC ĐỊNH]:** các luật gắn [MẶC ĐỊNH, duyệt qua kịch bản luật] phải được tác giả duyệt bằng kịch bản ở E2–E3.
- **Kiểm tra khi playtest E4:** tầm kéo của Trần Khánh Dư (dự phòng 1 ô), độ mạnh của Vườn không nhà trống (dự phòng: tối thiểu còn 1 máu), tướng gục bị nhấc khỏi bàn (dự phòng: để xác làm vật cản).
- **Playtest:** 3–5 người thân; quan sát 5 dấu hiệu hành vi; đạt ≥ 3/5 thì sang giai đoạn 1.
- **Chính sách AI tạo hình:** prototype chỉ dùng hình tạm; bản phát hành phải đối chiếu sử và sửa tay, khai báo dùng AI.
- **Đề xuất từ kiến trúc:** đổi E0 "Học Godot" thành "Dựng nền" (AI viết code). Bản epic tổng quát trong GDD vẫn là "Học Godot", cần kiểm tra bản `epics.md` chi tiết đã xử lý chưa.
- **Ràng buộc kỹ thuật:** engine Godot; mọi luật phân giải theo bảng trong `game-architecture.md`.

### GDD Completeness Assessment

- **Phần prototype (P0): đầy đủ và rõ.** Luật combat, trình tự hiệp, Enemy AI, địa hình, mưu kế, thắng/thua đều có con số cụ thể. Các trường hợp biên đã được chốt hoặc gắn nhãn [MẶC ĐỊNH] có cơ chế duyệt rõ (kịch bản luật E2–E3). GDD đã qua validator (G-1 Enemy AI đã xử lý).
- **Phần giai đoạn 1 (P1): chỉ có khung, có chủ đích.** Đánh dấu "chi tiết hóa sau prototype". Không chặn việc làm prototype.
- **Điểm cần theo dõi ở các bước sau:**
  1. Bảng Campaign Structure chỉ mô tả trận ở mức ý định (thành phần quân, địa hình chính). Bố cục ô cụ thể của 5 trận chưa có. Cần xem epics có story thiết kế trận và kiểm lời giải không.
  2. Không có tài liệu UX. Bố cục HUD (vị trí nút mưu kế, nút Hủy/Kết thúc/Chơi lại, thanh máu, màn hình chuyển trận, khi thắng/thua) chưa được mô tả ở đâu trong GDD.
  3. Bản epic tổng quát trong GDD (`updated: 2026-10-15`) chưa phản ánh các thay đổi ngày 16/10 (ví dụ: xem trước kết quả đòn ở E2, đổi tên E0). Cần đối chiếu với `epics.md` chi tiết.
  4. GDD không có chỉ số tải cho số lượng quân tối đa trên bàn (trận 5: 5 quân + tiếp viện 1–2/hiệp × 5 hiệp). Không chặn, nhưng nên xác định trần cho kiểm tra hiệu năng (NFR1).

## Epic Coverage Validation

`epics.md` có danh mục FR riêng (46 FR, 9 NFR) và bảng phủ FR → Epic. Số FR trong `epics.md` khác cách đánh số ở báo cáo này. Bảng dưới đối chiếu **từng FR trích từ GDD** (bước 2) với **story cụ thể** trong `epics.md`, không chỉ dựa vào bảng phủ của epics.

### Coverage Matrix (FR prototype P0)

| FR (báo cáo) | Yêu cầu GDD (rút gọn) | Story phủ | Trạng thái |
|---|---|---|---|
| FR1 | Bàn 7×7 từ file dữ liệu trận | 1.1, 1.2 | ✓ |
| FR2 | Đi 4 hướng, Manhattan, tầm 3 / 2–3 | 1.4, 2.6 | ✓ |
| FR3 | Ô đi được hoặc bị chặn | 1.4 | ✓ |
| FR4 | Xuyên quân mình, không xuyên quân địch | 1.4 | ✓ |
| FR5 | Không có tầm nhìn, độ cao | (mặc nhiên, không cần story) | ✓ |
| FR6 | Tô sáng ô đi được, hiện đường đi | 1.4 | ✓ |
| FR7 | Đường ít hầm chông nhất, hiện máu sẽ mất | 3.4 | ✓ |
| FR8 | 3 tướng, 3 máu, đi 3 | 1.4, 1.1 | ✓ |
| FR9 | Nguyễn Khoái đánh 2, đẩy 1 | 2.1 | ✓ |
| FR10 | Phạm Ngũ Lão phóng lao | 2.3, 3.1 | ✓ |
| FR11 | Trần Khánh Dư kéo | 2.4 (tướng chặn, đã kề, qua sông) | ⚠️ Một phần: chưa có AC cho "vật đầu tiên là **rừng hoặc kho lương** thì không kéo được". Story 3.1 chỉ nói rừng/kho chặn lao, xung phong, tên |
| FR12 | Kỵ binh xung phong, trượt khi hàng trống | 2.6, 2.7, 3.1 | ✓ |
| FR13 | Cung kỵ bắn 2–3 ô, tên bay qua quân | 2.13, 3.1 | ✓ |
| FR14 | Bộ binh | 2.6 | ✓ |
| FR15 | Tiếp viện xuất hiện đầu hiệp, chặn ô | 3.7 | ✓ |
| FR16 | Ô đỏ, số thứ tự, mũi tên | 2.6 | ✓ |
| FR17 | Lượt người chơi: đi rồi đánh, thứ tự tùy ý | 1.5, 2.1 | ✓ |
| FR18 | Địch ra đòn theo thứ tự | 2.7 | ✓ |
| FR19 | Cuối hiệp: kho lương hồi máu, đánh dấu tiếp viện | 3.6, 3.7 | ✓ |
| FR20 | Đòn gắn với ô/hướng, né được | 2.7 | ✓ |
| FR21 | Đòn trúng mọi phe | 2.2, 2.3, 2.7 | ✓ |
| FR22 | Đòn dịch theo, ra ngoài bàn thì hủy | 2.7 | ✓ |
| FR23 | Chủ đòn gục thì đòn hủy | 2.7 | ✓ |
| FR24 | Không phản công, không giới hạn thời gian | (không cần story) | ✓ |
| FR25 | AI tất định, thứ tự theo file trận | 2.6, 2.7 (`test_determinism`) | ✓ |
| FR26 | Mục tiêu tướng gần nhất; Giữ ải nhắm ô ải | 2.6, 3.8 | ✓ |
| FR27 | Chọn ô đứng, hòa B→Đ→N→T | 2.6 | ✓ |
| FR28 | AI không tránh ô đỏ, hầm chông | 2.7, 3.4 (kiến trúc ghi rõ đường đi của địch) | ✓ |
| FR29 | Va chạm | 2.1 | ✓ |
| FR30 | Sông nhấn chìm quân Nguyên, tướng tính va chạm | 2.2, 2.4 | ✓ |
| FR31 | Rừng | 3.1 | ✓ |
| FR32 | Hầm chông | 3.4 | ✓ |
| FR33 | Kho lương | 3.6, 3.9 | ✓ |
| FR34 | Bảng thứ tự phân giải | Quy trình kịch bản luật E2–E3 | ✓ |
| FR35 | Mưu kế 1 lần/trận, không tốn hành động | 3.9, 3.10 | ✓ |
| FR36 | Sát Thát | 3.10 | ✓ |
| FR37 | Vườn không nhà trống | 3.9 | ✓ |
| FR38 | Mở mưu kế theo trận | 3.9 (file trận quy định), 4.2 | ✓ |
| FR39 | Hủy nước đi gần nhất | 1.5 | ✓ |
| FR40 | Chơi lại hiệp 1 lần/trận | 3.2 | ✓ |
| FR41 | Xem trước kết quả đòn (E2 tối giản, **E4 trau chuốt**) | 2.10 | ⚠️ Một phần: có bản E2, **không có story trau chuốt ở E4** như GDD ghi |
| FR42 | Rê chuột xem thông tin quân và ô | 2.8 | ✓ |
| FR43 | Tiêu diệt | 2.5 | ✓ |
| FR44 | Giữ ải | 3.8 | ✓ |
| FR45 | Tướng gục bị nhấc khỏi bàn | 2.5 | ✓ |
| FR46 | Kiểm tra thắng/thua, thắng ưu tiên | 2.5 | ✓ |
| FR47 | Hồi đầy máu giữa trận | 4.2 | ✓ |
| FR48 | Chỉ bấm chuột, xác nhận khi đã đi | 1.5, 2.1 | ✓ |
| FR49 | Phím tắt 1/2/3, Q/W, Z, Space, R | 1.4, 1.5, 3.2, 3.9, 3.10 | ✓ |
| FR50 | Chuỗi 5 trận dạy luật | 1.2, 2.12, 3.3, 3.5, 3.11, 4.5 | ✓ |
| FR51 | Mỗi trận có lời giải không mất tướng | 2.12, 3.3, 3.5, 3.11, 4.5, 4.6 | ✓ (có kiểm tra tự động, tốt hơn GDD yêu cầu) |
| FR52 | Lịch tiếp viện trong dữ liệu trận | 3.7, 3.11, 4.5 | ✓ |
| FR53 | Màn chuyển trận, tên tạm "Trận 1–5" | 4.2 | ✓ |
| FR54 | Tua nhanh pha địch | 4.4 | ✓ |
| FR55 | Tự lưu sau mỗi trận | 4.3 | ✓ |
| FR56 | Chữ tách file riêng | 0.4 | ✓ |

### NFR Coverage

| NFR | Story phủ | Trạng thái |
|---|---|---|
| NFR1 60 FPS | 4.7 | ✓ (chưa có trần số quân để đo, xem bước 2) |
| NFR2 ≤ 50 MB | 0.5, 4.7 (trần chặt hơn: bản nén ≤ 25 MB) | ✓ |
| NFR3 Tải ≤ 10 giây | 0.5, 4.7 | ✓ |
| NFR4 Pha địch ≤ 3 giây | 2.9, 4.7 | ✓ |
| NFR5 HTML5, 3 trình duyệt | 0.5, 4.7 | ✓ |
| NFR6 Tất định | 2.7 (`test_determinism.gd`) | ✓ |
| NFR7 Ô đỏ nổi bật | 2.6, 2.9 | ✓ |
| NFR8 Không kẹt trận | 4.7, kiểm tra bất biến (kiến trúc) | ✓ |
| NFR9 Lưu không hỏng | 4.3 (file hỏng hoặc khác phiên bản) | ✓ |
| NFR10 Tiếng Việt, tách file | 0.4 | ✓ |
| NFR11 Sửa trận không cần code | 1.1, 1.6 | ✓ |
| NFR12 Không kéo thả | 1.5 | ✓ |
| NFR13 Tài sản prototype | 1.2 | ✓ |

### Missing Requirements

**Không có FR nào bị bỏ sót hoàn toàn.** Có 2 FR chỉ được phủ một phần:

**Mức trung bình**
- **FR11 (Trần Khánh Dư kéo): thiếu AC cho trường hợp vật đầu tiên là rừng hoặc kho lương.**
  - Ảnh hưởng: đây là luật [MẶC ĐỊNH] cần duyệt bằng kịch bản. Không có AC thì có thể không ai viết kịch bản cho ca này. Ở E2 chưa có rừng/kho lương trên bàn, nên ca này rơi vào khe giữa Story 2.4 và 3.1.
  - Đề xuất: thêm một AC vào Story 3.1: "Khi vật đầu tiên trên hàng của Trần Khánh Dư là rừng hoặc kho lương, thì không kéo được."

**Mức thấp**
- **FR41 (Xem trước kết quả đòn): không có bước trau chuốt ở E4.**
  - Ảnh hưởng: GDD và ADR-005 hứa bản trau chuốt ở E4. Nếu bỏ thì phải ghi rõ là đã cắt.
  - Đề xuất: hoặc thêm một AC vào Story 4.6 hoặc 4.8 (ví dụ: xem trước hiện cả đòn dịch theo, chết đuối, va chạm dây chuyền), hoặc ghi vào GDD là bản E2 đã đủ.

**Yêu cầu có trong epics nhưng không có trong GDD** (không phải lỗi; cần tác giả biết đây là phạm vi thêm):
- `chi_so.json` cho tác giả tự sửa chỉ số (từ kiến trúc).
- Màn hình chính "Chơi mới / Chơi tiếp" (Story 4.1). GDD chỉ nói đến tự lưu.
- **Story 4.8 Gợi ý luật đầu trận và bảng phím tắt.** GDD ghi prototype "không có chữ kể chuyện". Gợi ý luật là chữ hướng dẫn, không phải kể chuyện, nên hợp lý cho playtest với người thân. Nhưng nó là phạm vi thêm trong E4 (epic đã chật).
- Các luật chi tiết suy ra từ kiến trúc: mục tiêu gục vì sát thương thì không bị đẩy; kho lương hồi tối đa 1 máu mỗi hiệp; Vườn không nhà trống trừ máu theo thứ tự trong file trận; quân gục trên hầm chông khi đang đi thì không báo đòn. Đã có trong kiến trúc, nhất quán với GDD.
- Công cụ dev (F1, F2, F3, F5, `?dev=1`, `?tran=N`) và MCP (Story 0.6).

**FR giai đoạn 1 (FR57–FR62):** ngoài phạm vi `epics.md` một cách có chủ đích (`scope: Giai đoạn 0`). Không tính vào tỷ lệ phủ.

### Coverage Statistics

- Tổng FR prototype trong GDD: **56**
- Phủ đầy đủ: **54**
- Phủ một phần: **2** (FR11, FR41)
- Không phủ: **0**
- Tỷ lệ phủ: **96% đầy đủ, 100% có ít nhất một story**
- NFR: **13/13** có story phủ

## UX Alignment Assessment

### UX Document Status

**Không có.** Không tìm thấy `*ux*.md` trong planning-artifacts. `epics.md` ghi rõ: "Không có tài liệu UX riêng. Các yêu cầu giao diện lấy từ GDD (Controls and Input, Art Style)".

**UX có cần không?** Có. Đây là game cho người chơi, và GDD có nhiều yếu tố giao diện:
- HUD trong trận: nút mưu kế, Hủy, Kết thúc lượt, Chơi lại, thanh máu, số hiệp "2/5";
- lớp phủ trên bàn: ô đỏ, số thứ tự ra đòn, mũi tên xung phong, ô sáng chỉ chỗ đi được, đường đi, số máu sẽ mất, dấu tiếp viện, bóng mờ xem trước;
- tooltip khi rê chuột;
- các màn hình: chính, chuyển trận, thắng/thua, lỗi, gợi ý luật.

Với một prototype nhỏ, một người làm, có thể chấp nhận không có tài liệu UX riêng. **Nhưng một số quyết định giao diện hiện chưa được ghi ở đâu**, và AI viết code sẽ phải tự đoán.

### Những gì kiến trúc đã đỡ cho UI

- Độ phân giải 1280×720, `canvas_items`, aspect `keep` (quyết định #13). Story 0.1 kiểm tra co giãn.
- UI bằng Control node, một Theme chung, HUD dựng bằng code (#17). Có `src/ui/hud.gd`.
- Phần trình bày chỉ đọc bản chụp, không sửa trạng thái. `controller.preview(command)` có sẵn cho xem trước.
- 4 màn hình: MENU, BATTLE, TRANSITION, ERROR.
- Mọi chữ qua `tr()`, khóa dạng `hud.end_turn`.
- Nhịp hoạt ảnh ≤ 3 giây, có tua nhanh, khóa input khi hoạt ảnh chạy (Story 2.9).

→ **Kiến trúc đủ sức chứa mọi yêu cầu UI trong GDD.** Không có xung đột UX ↔ Kiến trúc.

### Alignment Issues (khe hở giao diện chưa có ai quyết)

1. **Hiển thị tầm đánh của tướng chưa được quy định.** GDD và epics nói rõ tô sáng ô *đi được*, nhưng không nói game có tô các ô/mục tiêu *đánh được* hay không, và bằng màu gì để không lẫn với ô đỏ của địch. Story 2.3 chỉ ghi "không bấm đánh được về hướng đó". Đây là thông tin then chốt cho trụ cột *Thấy trước, tính được*.
2. **Xung đột thao tác bấm khi mục tiêu là tướng mình.** Luật cho phép đòn của tướng trúng tướng mình (FR21). Nhưng bấm vào ô có tướng mình thì là *chọn tướng đó* (FR48). Với Nguyễn Khoái: người chơi có được cố ý đánh ô kề có tướng mình không? Nếu được thì bấm thế nào? Nếu không được thì cần ghi rõ: "đòn chỉ trúng tướng mình như hệ quả (đẩy, lao trúng vật đầu tiên), không được chọn tướng mình làm mục tiêu".
3. **Trạng thái của từng tướng không được hiển thị rõ.** Chưa story nào yêu cầu hiện tướng nào *đã đi*, *đã đánh*, *còn hành động* (ví dụ làm mờ đồng quân). Có 3 tướng, thứ tự tùy ý, nên người chơi cần biết ai còn lượt.
4. **Không có chỉ báo pha.** Không có AC cho việc hiện "Lượt của bạn" và "Quân Nguyên đang ra đòn". Story 2.9 khóa input khi hoạt ảnh chạy, nhưng người chơi không được báo vì sao không bấm được.
5. **Nhiều đòn cùng nhắm một ô.** Chưa quy định cách hiện số thứ tự khi hai đòn nhắm cùng một ô (ví dụ "1,3"), hay khi ô đỏ trùng với dấu tiếp viện.
6. **Bố cục HUD chưa có.** Nút nằm ở đâu, thanh máu trên đồng quân hay ở panel bên, số lần chơi lại hiệp còn lại hiện ở đâu. Với tác giả kiêm tester thì chấp nhận được: AI tự đặt, tác giả duyệt bằng mắt. Nhưng nên có một AC tối thiểu.

### Warnings

- ⚠️ **Không có tài liệu UX, trong khi game có nhiều UI.** Mức độ: **thấp đến trung bình** với prototype. Không chặn E0–E1. **Nên xử lý trước E2**, vì Story 2.6–2.10 là lúc các lớp phủ trên bàn (ô đỏ, số thứ tự, tầm đánh, xem trước) chồng lên nhau.
- **Đề xuất nhẹ (không bắt buộc chạy `gds-ux`):** bổ sung khoảng 5 AC vào các story có sẵn:
  - Story 1.4: tướng đã hành động thì đồng quân mờ đi;
  - Story 2.1, 2.3, 2.4: khi chọn tướng, các mục tiêu đánh được có viền màu riêng, khác ô đỏ;
  - Story 2.6: nhiều đòn cùng nhắm một ô thì hiện đủ các số thứ tự;
  - Story 2.9: có dòng chữ báo pha hiện tại;
  - ghi quyết định về việc chọn tướng mình làm mục tiêu (mục 2) vào GDD và Story 2.1.
- Khi sang giai đoạn 1 (bản đồ roguelite, phần thưởng, E8 hình ảnh), **nên chạy `gds-ux`**, vì lúc đó số màn hình và luồng người chơi tăng nhiều.

## Epic Quality Review

Tổng cộng 5 epic, 45 story (E0: 6, E1: 6, E2: 13, E3: 11, E4: 9). Tiêu chí nghiệm thu viết dạng Cho/Khi/Thì/Và, nhất quán, phần lớn test được bằng tay mà không cần đọc code. Đây là điểm mạnh lớn của bộ epic.

### Kiểm tra từng epic

| Epic | Giá trị cho người dùng | Độc lập | Phụ thuộc ngược chiều | Ghi chú |
|---|---|---|---|---|
| E0 Dựng nền | ⚠️ Kỹ thuật, nhưng có kết quả nhìn thấy (link itch.io, `test.sh`) | ✓ | Không | Xem 🟠-1 |
| E1 Bàn cờ & di chuyển | ✓ Di chuyển 3 tướng trên trận 1 | ✓ Chỉ cần E0 | Không | |
| E2 Combat cốt lõi | ✓ Chơi trọn trận 1 | ✓ Chỉ cần E0–E1 | Không | Epic lớn nhất (13 story) |
| E3 Địa hình & mưu kế | ✓ Chơi được trận 2–4 | ✓ | Không | 11 story trong khoảng 20 giờ |
| E4 Năm trận & chơi thử | ✓ Prototype hoàn chỉnh, có playtest | ✓ | Không | |

**Phụ thuộc giữa các story:** đã dò từng story, **không có phụ thuộc vào story sau**. Các chỗ nhắc tới epic sau đều là *hoãn có chủ đích* và ghi rõ: "phần rừng chặn lao làm ở E3" (2.3), "pha địch chèn vào đây ở E2" (1.5), "nút Chơi tiếp làm ở Story 4.3" (4.1). Story nào cũng chạy được với kết quả của các story trước.

**Tạo dữ liệu đúng lúc:** ✓. `chi_so.json` và `tran_01.json` tạo ở 1.1–1.2; mỗi file trận tạo ở story của trận đó; `chien_dich.json` ở 4.2; file lưu ở 4.3. Không có story "tạo hết cấu trúc dữ liệu".

**Starter template / dự án mới:** kiến trúc ghi "không dùng starter template". Story 0.1 tạo project Godot trống với cấu hình cụ thể, có `cai_dat.sh` để cài môi trường; build và deploy có từ Story 0.5. ✓ Đúng chuẩn cho dự án làm từ đầu.

### 🔴 Critical Violations

**Không có.**

### 🟠 Major Issues

**🟠-1. Ngân sách giờ chưa được chia lại sau khi đổi E0 thành "Dựng nền".**
- GDD: E0 30 giờ, E1 20, E2 30, E3 20, E4 30. `epics.md` **không ghi số giờ hay số tuần** cho epic nào.
- E0 không còn là "học Godot 30 giờ" mà là 6 story hạ tầng do AI làm. Trong khi đó E3 có 11 story (4 luật mới, 2 mưu kế, Giữ ải, 3 trận) mà GDD chỉ cho 20 giờ. E4 thêm Story 4.1 và 4.8, không có trong GDD.
- Mốc "hết tuần 8" và phương án "nếu E2 trễ" phụ thuộc vào lịch này. Không có lịch thì không biết khi nào là "trễ".
- **Đề xuất:** thêm một bảng giờ vào `epics.md`, ví dụ E0 ~12 giờ, E1 ~18, E2 ~35, E3 ~35, E4 ~30. Cập nhật mốc tuần 8 theo bảng mới (ví dụ thành "hết E2"), và cập nhật bảng epic trong GDD cho khớp.
- E0 là epic kỹ thuật. Bình thường đây là vi phạm, nhưng chấp nhận được vì: tác giả là người dùng của E0 (tester), E0 có kết quả nhìn thấy được, và kiến trúc bắt buộc có test và ranh giới trước khi viết luật. **Không cần sửa cấu trúc, chỉ cần giữ E0 thật gọn.**

**🟠-2. Hủy nước đi chưa quy định khi xen giữa có đòn đánh hoặc mưu kế.**
- Kiến trúc: "Hủy nước đi quay về bản chụp ngay trước khi tướng đó đi", "vào sau ra trước". Ví dụ: tướng A đi → tướng B đánh (đẩy địch) → bấm `Z`. Nếu khôi phục bản chụp trước khi A đi thì đòn của B cũng bị xóa. Kết quả là `Z` thành "chơi lại hiệp" miễn phí, phá giới hạn 1 lần mỗi trận.
- Tương tự: A đi → dùng Vườn không nhà trống → `Z`.
- Story 1.5 viết ở E1 khi chưa có đòn đánh, nên không có AC cho ca này. Trong E2 cũng không story nào bổ sung.
- **Đề xuất (cần tác giả chốt):** "Mọi lệnh Đánh hoặc Dùng mưu kế đều xóa ngăn xếp hủy nước đi". Thêm AC và kịch bản vào Story 2.1 (đánh) và 3.9 (mưu kế).

**🟠-3. Chơi lại hiệp chưa quy định với mưu kế đã dùng trong lượt.**
- Bản chụp đầu lượt có "cờ mưu kế", nên về lý thuyết chơi lại hiệp sẽ trả lại mưu kế đã dùng trong lượt đó. Nhưng chưa AC nào nói rõ đây là chủ ý.
- **Đề xuất:** thêm AC vào Story 3.2: "Khi đã dùng mưu kế trong lượt rồi chơi lại hiệp, mưu kế được trả lại (hoặc không), theo quyết định của tác giả."

**🟠-4. Story 2.6 và 2.7 quá lớn so với rủi ro.**
- 2.6 gom: AI chọn mục tiêu, AI chọn ô đứng, đường đi của địch, báo đòn (ô đỏ, mũi tên, số thứ tự), chỉ số 2 loại quân, công cụ F3.
- 2.7 gom: thứ tự ra đòn, đòn dịch theo, hủy đòn, trúng đồng đội, Kỵ binh trượt, test tất định.
- Đây là phần "rủi ro cao nhất" của dự án. Một story mà đỏ lâu thì mốc "bản xấu chơi được" lùi theo.
- **Đề xuất:** tách 2.6 thành (a) AI đi và chọn mục tiêu, kèm F3; (b) hiển thị báo đòn. Tách 2.7 thành (a) ra đòn theo thứ tự và trúng đồng đội; (b) đòn dịch theo và hủy đòn.

**🟠-5. Một số tiêu chí nghiệm thu không đo được.**
- Story 4.6: "trận 1–3 thắng được mà không mất tướng ngay lần đầu nếu đọc kỹ ô đỏ". Tác giả đã biết lời giải nên không tự kiểm được. → Chuyển thành dấu hiệu quan sát trong Story 4.9.
- Story 4.7: "giữ 60 FPS" nhưng không nói đo bằng gì. → Thêm: chế độ dev hiện bộ đếm FPS; đo trên trận 5 ở hiệp có nhiều quân nhất.
- Story 0.5 và 4.7: "tải ≤ 10 giây ở mạng 20 Mbps" nhưng không nói cách giả lập mạng. → Ghi: dùng DevTools, chế độ throttle hoặc preset mạng tương đương.

### 🟡 Minor Concerns

1. **Hiện máu muộn.** Máu trên đồng quân đến Story 2.5. Khi test tay Story 2.1–2.4, tác giả không thấy máu trên màn hình (chỉ thấy qua kịch bản). → Đưa phần "mỗi đồng quân hiện số máu" vào 1.2 hoặc 2.1.
2. **Lặp giữa 2.1 và 3.1.** Story 2.1 đã có "đẩy vào rừng hoặc kho lương thì va chạm"; Story 3.1 lặp lại "bị đẩy vào rừng thì va chạm". Không sai, nhưng nên ghi 3.1 chỉ bổ sung phần *chặn đòn*. Thêm vào 3.1 AC kéo bị rừng/kho lương chặn (xem FR11 ở bước 3).
3. **AC lạ ở Story 2.13:** "tắt Cung kỵ bằng cờ thì trận 1 vẫn chạy". Trận 1 vốn không có Cung kỵ. Ý đúng có lẽ là "tắt cờ thì các trận có Cung kỵ được thay bằng Bộ binh". → Sửa lại cho đúng ý, nối với Story 3.5.
4. **Phương án cắt trận 5 chưa có trong story.** GDD: "nếu trễ thì cắt trận 5". Story 4.2 và 4.6 vẫn cố định 5 trận. → Thêm ghi chú vào 4.5: "cắt được; khi cắt, `chien_dich.json` chỉ còn 4 trận".
5. **Phạm vi thêm trong E4:** Story 4.1 (màn hình chính) và 4.8 (gợi ý luật) không có trong GDD. Hợp lý cho playtest, nhưng nên ghi vào GDD hoặc đánh dấu "cắt được nếu trễ".
6. **Mâu thuẫn nhẹ trong GDD về nhịp dạy luật:** bảng Campaign Structure ghi trận 3 dạy "đòn kéo của Trần Khánh Dư". Nhưng cả 3 tướng có mặt từ trận 1, và Story 2.4 cùng mô tả E2 ("kéo địch vào ô đỏ") cho thấy đòn kéo dùng được ngay trận 1. → Tác giả chọn: hoặc trận 1–2 chỉ có 2 tướng, hoặc sửa bảng thành "trận 3 dạy kéo địch vào hầm chông".
7. **Bản epic tổng quát trong thư mục GDD đã cũ:** vẫn ghi "E0 Học Godot" và thiếu xem trước kết quả đòn. → Cập nhật hoặc ghi chú "đã thay bằng `planning-artifacts/epics.md`".
8. **Story 0.6 (MCP) đặt cuối E0.** MCP giúp AI tự xem log và chụp màn hình, nên nếu làm sớm hơn (sau 0.1) thì có ích cho cả 0.2–0.5. Không bắt buộc.

### Best Practices Compliance Checklist

| Tiêu chí | E0 | E1 | E2 | E3 | E4 |
|---|---|---|---|---|---|
| Có giá trị cho người dùng | ⚠️ | ✓ | ✓ | ✓ | ✓ |
| Chạy độc lập với epic sau | ✓ | ✓ | ✓ | ✓ | ✓ |
| Story vừa cỡ | ✓ | ✓ | ⚠️ (2.6, 2.7) | ✓ | ✓ |
| Không phụ thuộc story sau | ✓ | ✓ | ✓ | ✓ | ✓ |
| Tạo dữ liệu khi cần | ✓ | ✓ | ✓ | ✓ | ✓ |
| AC rõ ràng | ✓ | ✓ | ⚠️ (hủy nước đi) | ⚠️ (chơi lại hiệp) | ⚠️ (4.6, 4.7) |
| Truy vết được về FR | ✓ | ✓ | ✓ | ✓ | ✓ |

## Summary and Recommendations

### Overall Readiness Status

**NEEDS WORK (nhẹ): E0 bắt đầu được ngay. Cần xử lý trước khi vào E2.**

Bộ tài liệu ở mức tốt cho một prototype một người làm:
- GDD chốt luật đến từng trường hợp biên.
- Kiến trúc có bảng thứ tự phân giải, và luật nằm riêng một chỗ, tách khỏi phần hiển thị.
- Không FR nào bị bỏ sót hoàn toàn.
- Không có phụ thuộc vào story sau.
- Tiêu chí nghiệm thu tác giả tự test được.

**Không có lỗi 🔴.** Các vấn đề còn lại tập trung ở 3 chỗ: lịch giờ, các ca biên của hoàn tác và chơi lại hiệp, và hiển thị trên bàn cờ ở E2.

### Critical Issues Requiring Immediate Action

Không có vấn đề nào chặn việc bắt đầu E0. Những việc dưới đây **phải xong trước khi bắt đầu E2**, vì đó là epic rủi ro cao nhất:

1. **Chia lại ngân sách giờ** cho E0–E4 sau khi E0 đổi thành "Dựng nền", ghi vào `epics.md`. Đặt lại mốc tự chơi (🟠-1).
2. **Chốt luật hủy nước đi khi xen giữa có đòn đánh hoặc mưu kế.** Đề xuất: Đánh hoặc Dùng mưu kế thì xóa ngăn xếp hủy. Nếu không chốt, `Z` có thể thành "chơi lại hiệp" không giới hạn, phá trụ cột *Thấy trước, tính được* (🟠-2).
3. **Quyết định hiển thị tầm đánh của tướng và cách xử lý khi bấm vào tướng mình làm mục tiêu** (UX mục 1–2).

### Recommended Next Steps

1. **Tác giả quyết 4 câu hỏi spec** (khoảng 15 phút), rồi ghi vào GDD và kiến trúc:
   - (a) Đánh hoặc mưu kế có xóa ngăn xếp hủy nước đi không?
   - (b) Chơi lại hiệp có trả lại mưu kế đã dùng trong lượt không?
   - (c) Có được chọn tướng mình làm mục tiêu không?
   - (d) Trận 1–2 có đủ 3 tướng không, hay bảng dạy luật cần sửa?
2. **Sửa `epics.md`** (có thể dùng `gds-correct-course` hoặc sửa trực tiếp):
   - thêm bảng giờ;
   - thêm AC cho FR11 (kéo bị rừng/kho lương chặn) vào 3.1;
   - thêm AC hủy nước đi vào 2.1 và 3.9, AC chơi lại hiệp vào 3.2;
   - tách 2.6 và 2.7;
   - đưa phần hiện máu lên sớm;
   - thêm khoảng 5 AC giao diện (tầm đánh, trạng thái tướng, chỉ báo pha, nhiều đòn cùng ô);
   - sửa AC của 2.13, 4.6, 4.7;
   - đánh dấu 4.5 và 4.8 "cắt được".
3. **Cập nhật hoặc ghi chú bản epic tổng quát trong thư mục GDD** là đã được thay thế. Quyết định số phận "trau chuốt xem trước ở E4" (FR41).
4. **Chạy `gds-sprint-planning`** để tạo file theo dõi sprint, rồi `gds-create-story` cho Story 0.1. Việc này làm được **song song** với bước 1–2, vì E0 không bị ảnh hưởng bởi các vấn đề trên.
5. Trước giai đoạn 1: chạy `gds-ux`.

### Final Note

Lần đánh giá này tìm thấy **21 vấn đề trong 3 nhóm**:
- phủ FR: 2 vấn đề;
- UX: 6 vấn đề, kèm 1 cảnh báo;
- chất lượng epic: 5 vấn đề 🟠 và 8 vấn đề 🟡.

Không có vấn đề 🔴. Hãy xử lý 3 vấn đề nêu ở mục "Critical Issues" trước khi vào E2. Có thể dùng các phát hiện này để sửa tài liệu, hoặc chọn đi tiếp như hiện tại và sửa dần theo từng epic.

---

**Người đánh giá:** Game Producer / Scrum Master (AI), workflow `gds-check-implementation-readiness`
**Ngày:** 2026-10-17

---

## Cập nhật sau đánh giá (2026-10-17)

Tác giả đã chốt 4 câu hỏi spec. Đã ghi vào GDD, decision-log, kiến trúc, `project-context.md` và `epics.md`:

| # | Quyết định | Xử lý vấn đề |
|---|---|---|
| a | Đánh hoặc dùng mưu kế thì xóa sạch lịch sử hủy | 🟠-2 |
| b | Chơi lại hiệp trả lại cả mưu kế đã dùng trong lượt | 🟠-3 |
| c | Không được chọn tướng mình làm mục tiêu (phương án A) | UX mục 2 |
| d | Trận 1–2 chỉ có 2 tướng; Trần Khánh Dư ra trận từ trận 3. Thua khi mọi tướng trên bàn gục | 🟡-6 |

Các chỉnh sửa khác đã áp vào `epics.md`:
- Thêm bảng giờ: E0 ~12, E1 ~18, E2 ~35, E3 ~35, E4 ~30 (đây là đề xuất, tác giả chỉnh được). Định nghĩa "trễ" là vượt 25% số giờ. Mốc tự chơi chuyển thành hết E2 (🟠-1).
- Tách 2.6 → 2.6 (AI) và 2.7 (hiển thị báo đòn). Tách 2.7 cũ → 2.8 (ra đòn) và 2.9 (dịch theo, hủy đòn). Đánh số lại 2.10–2.15 (🟠-4).
- Sửa tiêu chí không đo được ở 0.5, 4.6, 4.7 và chuyển một mục sang 4.9 (🟠-5).
- Thêm AC cho FR11 (kéo bị rừng/kho lương chặn) vào 3.1. Thêm bước trau chuốt xem trước (FR41) vào 4.6, cắt được.
- Thêm 4 AC giao diện: trạng thái tướng (1.5, 2.1), viền mục tiêu đánh được (2.1), nhiều đòn cùng ô (2.7), chỉ báo pha (2.11).
- Hiện máu từ 1.2. Thêm trận thử `thu_ba_tuong` để thử Trần Khánh Dư ở E2.
- Sửa AC của 2.15 (Cung kỵ). Đánh dấu 4.5 và 4.8 là cắt được.
- Đánh dấu bản epic tổng quát trong thư mục GDD là đã được thay thế.

**Trạng thái sau cập nhật: READY.** Đã xử lý hết các vấn đề 🟠 và các vấn đề UX chặn E2. Vấn đề còn lại: 🟡-8 (thứ tự Story 0.6 MCP), không bắt buộc.
