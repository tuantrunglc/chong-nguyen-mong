---
stepsCompleted: [1, 2, 3, 4]
status: 'complete'
inputDocuments:
  - '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md'
  - '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/epics.md'
  - '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/decision-log.md'
  - '_bmad-output/planning-artifacts/game-architecture.md'
  - '_bmad-output/project-context.md'
language: 'vi'
scope: 'Giai đoạn 0 (prototype). Giai đoạn 1–2 nằm ngoài phạm vi file này.'
---

# Chống Nguyên Mông (tên tạm): Chia epic và story

## Tổng quan

File này chia các yêu cầu trong GDD và tài liệu kiến trúc thành epic và story cho **prototype** (giai đoạn 0). Mỗi story có tiêu chí nghiệm thu để tác giả test được mà không cần đọc code.

## Danh mục yêu cầu

### Yêu cầu chức năng (FR)

**Bàn cờ và dữ liệu trận**
- FR1: Bàn 7×7 ô vuông, đi 4 hướng, không đi chéo; khoảng cách tính bằng số ô (Manhattan).
- FR2: Mỗi trận nạp từ file dữ liệu: địa hình, vị trí quân, tướng nào ra trận, thứ tự hành động của quân Nguyên, lịch tiếp viện, kiểu nhiệm vụ, mưu kế được dùng. Thêm hoặc sửa trận không cần sửa code.
- FR3: Hiển thị 6 loại ô (đất trống, sông, rừng, hầm chông, kho lương, làng) và ô ải; quân là đồng tròn có chữ hoặc biểu tượng. Bàn vẽ nhìn chếch từ trên xuống, ô vuông (Story 1.8; thay bàn isometric của Story 1.7).
- FR4: Chỉ số (máu, tầm đi, tầm đánh, sát thương, độ đẩy, tầm kéo, tham số mưu kế) nạp từ `chi_so.json`; tác giả tự sửa được.

**Tướng và di chuyển**
- FR5: Tối đa 3 tướng (Nguyễn Khoái, Phạm Ngũ Lão, Trần Khánh Dư), mỗi tướng 3 máu, đi tối đa 3 ô. File trận quy định tướng nào ra trận: trận 1–2 chỉ có Nguyễn Khoái và Phạm Ngũ Lão; Trần Khánh Dư từ trận 3.
- FR6: Chọn tướng bằng chuột hoặc phím `1` `2` `3`; tô sáng các ô đi tới được; rê chuột lên ô thì hiện đường đi.
- FR7: Được đi xuyên quân mình, không đi xuyên quân địch; sông, rừng, kho lương chặn đường.
- FR8: Game chọn đường **ít hầm chông nhất**, hòa thì theo B→Đ→N→T. Ô sáng và đường đi hiện số máu sẽ mất. [MẶC ĐỊNH]
- FR9: Mỗi tướng đi rồi đánh một lần; có thể đánh mà không đi; đã đánh thì không đi được nữa; ba tướng hành động theo thứ tự tùy ý.
- FR10: Hủy **nước đi gần nhất** (nút Hủy, phím `Z`), chỉ khi tướng đó chưa đánh [MẶC ĐỊNH]. Đánh hoặc dùng mưu kế thì xóa sạch lịch sử hủy (chốt 2026-10-17).
- FR11: Kết thúc lượt bằng nút hoặc phím `Space`.

**Đòn của tướng**
- FR12: Nguyễn Khoái đánh 1 ô kề, 2 sát thương, rồi đẩy mục tiêu 1 ô theo hướng đánh. Mục tiêu gục vì sát thương thì không bị đẩy.
- FR13: Phạm Ngũ Lão phóng lao thẳng hàng, bay qua ô kề, trúng vật đầu tiên ở ô thứ 2–4, 1 sát thương. Rừng hoặc kho lương ở bất kỳ ô nào trên đường, kể cả ô kề, chặn lao [MẶC ĐỊNH]. Sông không chặn.
- FR14: Trần Khánh Dư kéo vật đầu tiên trên hàng trong vòng 3 ô về phía mình 2 ô, 0 sát thương. Vật đó phải là quân Nguyên; nếu là tướng, rừng hoặc kho lương thì không kéo được [MẶC ĐỊNH]. Mục tiêu đã đứng kề thì không có gì xảy ra.
- FR15: Đánh bằng cách bấm ô hoặc mục tiêu trong tầm. Tướng đã đi rồi thì phải bấm thêm lần nữa để xác nhận.
- FR16: Mọi đòn trúng mọi quân trên ô bị nhắm, không phân phe. Không được chọn tướng mình làm mục tiêu: bấm vào tướng mình luôn là chọn tướng đó; tướng mình chỉ trúng đòn như hệ quả (lao trúng vật đầu tiên trên hàng, bị quân khác va vào) (chốt 2026-10-17).

**Đẩy, kéo, va chạm**
- FR17: Đẩy và kéo đi từng ô. Gặp mép bàn, rừng hoặc kho lương thì dừng và quân bị đẩy mất 1 máu; gặp quân khác thì dừng và cả hai mất 1 máu; qua mỗi ô hầm chông mất 1 máu; xuống sông thì quân Nguyên chết đuối, còn tướng tính như va chạm.

**Quân Nguyên**
- FR18: Bộ binh: 3 máu, đi 2, chém 1 ô kề, 1 sát thương.
- FR19: Kỵ binh: 2 máu, đi 3, xung phong theo hướng đã báo, đứng yên, trúng vật đầu tiên trên hàng, 1 sát thương. Rừng hoặc kho lương chặn (trúng vật cản thì không ai mất máu); sông không chặn; hàng trống tới mép thì trượt [MẶC ĐỊNH].
- FR20: Cung kỵ: 1 máu, đi 3, bắn ô thẳng hàng cách 2–3 ô [MẶC ĐỊNH], 1 sát thương. Tên bay qua quân; chỉ rừng hoặc kho lương nằm giữa mới chặn.
- FR21: Đòn của địch chỉ gây sát thương, không đẩy.

**Hiệp và pha địch**
- FR22: Mỗi hiệp có 4 pha: địch chuẩn bị → lượt người chơi → địch ra đòn → cuối hiệp.
- FR23: Enemy AI tất định:
  - quân hành động theo thứ tự trong file trận; quân tiếp viện hành động sau quân cũ;
  - nhắm tướng gần nhất (Giữ ải: Kỵ binh và Bộ binh nhắm ô ải; Tiêu diệt có làng: Kỵ binh và Bộ binh nhắm tướng hoặc làng gần nhất, hòa thì ưu tiên làng [MẶC ĐỊNH], Cung kỵ chỉ nhắm tướng);
  - ưu tiên ô đứng mà đòn trúng mục tiêu, không có thì đi tới ô gần mục tiêu nhất;
  - hòa thì theo B→Đ→N→T; không tránh hầm chông hay ô đỏ của đồng đội.
- FR24: Đòn được báo trước bằng ô đỏ (Kỵ binh thì có mũi tên hướng), kèm số thứ tự ra đòn hiển thị lớn trên bàn.
- FR25: Đòn đã báo dịch theo khi chủ đòn bị đẩy hoặc kéo. Đòn dịch ra ngoài bàn thì bị hủy [MẶC ĐỊNH]. Chủ đòn gục trước lượt ra đòn thì đòn bị hủy.
- FR26: Pha ra đòn thực hiện các đòn theo đúng số thứ tự đã báo.
- FR27: Quân Nguyên gục trên hầm chông khi đang đi thì không báo đòn.

**Địa hình**
- FR28: Sông: không đi vào được, không chặn lao và tên, nhấn chìm quân Nguyên bị đẩy hoặc kéo xuống.
- FR29: Rừng: không đi vào được, chặn lao, tên, xung phong và đường đi.
- FR30: Hầm chông: mỗi lần đi vào ô (tự đi, bị đẩy, bị kéo, kể cả chỉ đi ngang qua) mất 1 máu; gục giữa đường thì dừng tại đó.
- FR31: Kho lương: không đi vào được, chặn đòn. Cuối hiệp, quân Nguyên kề ít nhất một kho lương hồi 1 máu (tối đa 1 mỗi hiệp, không vượt máu tối đa).

**Mưu kế**
- FR32: Sát Thát: trong lượt người chơi này, đòn có sát thương của tướng được +1. Sát thương do va chạm, hầm chông, mép bàn không được cộng.
- FR33: Vườn không nhà trống: mọi kho lương thành đất trống; mọi quân Nguyên mất 1 máu theo thứ tự trong file trận; từ đó đến hết trận, quân Nguyên không hồi máu.
- FR34: Mỗi mưu kế dùng 1 lần mỗi trận, bất cứ lúc nào trong lượt người chơi, không tốn hành động của tướng. Dùng bằng nút hoặc phím `Q` `W`. Mở theo trận: Vườn không nhà trống từ trận 5, Sát Thát từ trận 6.

**Quân tiếp viện**
- FR35: Cuối hiệp, game báo trước ô tiếp viện của hiệp sau. Đầu hiệp sau, quân tiếp viện xuất hiện trước tiên, rồi báo đòn ngay trong hiệp đó. Nếu ô có quân đứng (bất kể phe nào), quân đứng đó mất 1 máu và quân tiếp viện bị hủy.

**Thắng, thua**
- FR36: Tiêu diệt: thắng khi hạ hết quân Nguyên; thua khi mọi tướng trên bàn đều gục, khi hết số hiệp tối đa (FR48) hoặc khi Lòng dân về 0 (FR47).
- FR37: Giữ ải: thắng khi hết bước cuối hiệp của hiệp 5; thua khi mọi tướng trên bàn đều gục, hoặc khi quân Nguyên vào ô ải bằng bất kỳ cách nào [MẶC ĐỊNH].
- FR38: Kiểm tra thắng/thua sau mỗi lần có quân gục; thắng và thua xảy ra cùng lúc thì thắng được ưu tiên [MẶC ĐỊNH]. Tướng gục bị nhấc khỏi bàn [MẶC ĐỊNH, KIỂM TRA KHI PLAYTEST E4].

**Hoàn tác và thông tin**
- FR39: Chơi lại hiệp (nút hoặc phím `R`), 1 lần mỗi trận, đưa bàn về đầu lượt người chơi, trả lại cả mưu kế đã dùng trong lượt đó (chốt 2026-10-17).
- FR40: Rê chuột lên quân hiện máu, đòn sắp đánh, thứ tự ra đòn; rê lên ô hiện loại địa hình.
- FR41: Xem trước kết quả đòn: rê lên mục tiêu thì hiện bóng mờ vị trí cuối và số máu sau đòn (E2 bản tối giản, E4 trau chuốt).
- FR42: Tua nhanh hoạt ảnh pha địch.

**Chiến dịch và lưu game**
- FR43: Chuỗi 6 trận cố định theo bảng Campaign Structure; mỗi trận có ít nhất một cách thắng không mất tướng.
- FR44: Màn hình chuyển trận; tướng hồi đầy máu giữa các trận.
- FR45: Màn hình chính: chơi tiếp (nếu có file lưu) hoặc chơi mới.
- FR46: Tự lưu trong trình duyệt sau mỗi trận; mở lại thì chơi tiếp được.

**Áp lực trong trận** (thêm 2026-10-18, theo `sprint-change-proposal-2026-10-18.md`)
- FR47: Làng `D`: không đi vào được, chặn đường đi, lao, tên và xung phong như rừng [MẶC ĐỊNH]; không có máu, không bị phá. Lòng dân là điểm chung của trận (`long_dan` trong file trận). Mỗi lần làng bị trúng thì −1: Bộ binh chém ô làng, Kỵ binh xung phong trúng làng, lao hoặc tên bị làng chặn [MẶC ĐỊNH], quân bị đẩy/kéo va vào làng (quân đó mất 1 máu, kể cả khi người chơi gây ra). Trần Khánh Dư không kéo được nếu vật đầu tiên là làng [MẶC ĐỊNH]. Về 0 thì thua ngay. HUD hiện "Lòng dân 3/3".
- FR48: Trận Tiêu diệt có thể có `so_hiep_toi_da`. Kết thúc bước cuối hiệp của hiệp cuối mà còn quân Nguyên thì thua [MẶC ĐỊNH]. Không có khóa này thì không giới hạn. HUD hiện "Hiệp 2/4". Trận 1–2 không giới hạn, có từ trận 3.

### Yêu cầu phi chức năng (NFR)

- NFR1: 60 FPS ổn định trên trình duyệt desktop, trên laptop văn phòng có card đồ họa tích hợp.
- NFR2: Bản build ≤ 50MB; tải ≤ 10 giây ở mạng 20Mbps (bản nén ≤ 25MB).
- NFR3: Hoạt ảnh mỗi pha địch ra đòn ≤ 3 giây.
- NFR4: Chạy trên Chrome, Firefox, Edge bản desktop mới nhất. Safari và điện thoại không bắt buộc.
- NFR5: Combat tất định: không ngẫu nhiên, cùng thao tác thì cùng kết quả.
- NFR6: Không có lỗi làm kẹt trận trong cả 6 trận.
- NFR7: Toàn bộ chữ tiếng Việt, tách ra file dịch.
- NFR8: Mọi thao tác làm được bằng bấm chuột, không có kéo thả.
- NFR9: Ô đỏ báo đòn là thứ nổi bật nhất trên màn hình; số thứ tự ra đòn lớn, dễ đọc.

### Yêu cầu bổ sung (từ kiến trúc)

- **Không dùng starter template.** Story đầu tiên tạo project Godot 4.7.2 trống trong `game/`, renderer Compatibility, 1280×720 `canvas_items`, cảnh báo `untyped_declaration` ở mức error.
- **Test:** cài GUT v9.7.1. `tools/test.sh` là một lệnh duy nhất: kiểm tra ranh giới, khóa `da_duyet`, chạy GUT `--headless`, in tóm tắt tiếng Việt.
- **Kịch bản luật** (`tests/kich_ban/`) là spec. Mỗi story luật có một đợt duyệt nhỏ bằng `tools/xem_kich_ban.sh`.
- **Ranh giới:** `tools/check_boundaries.sh` kiểm tra `src/core` cấm Node, cấm I/O, cấm ngẫu nhiên; chỉ `Effects` được sửa máu và vị trí.
- **Lõi luật:** `BattleState` thuần dữ liệu có `clone()` và `validate()`; `Rules.resolve` trả về danh sách sự kiện; `BattleController` giữ trạng thái và một bản chụp hủy (chỉ hủy được nước gần nhất, tác giả chốt 2026-10-18); `EventPlayer` phát lại sự kiện.
- **Dữ liệu:** JSON hai lớp bàn cờ chữ (`dia_hinh`, `quan`), có số phiên bản; `LoadResult` gom mọi lỗi tiếng Việt; `test_loaders.gd`; `test_determinism.gd`.
- **Xử lý lỗi:** vi phạm bất biến thì ghi log ERROR, khôi phục bản chụp và báo người chơi. Lỗi dữ liệu thì hiện màn hình lỗi.
- **Log:** lớp static `Log`, giữ 200 dòng gần nhất.
- **Công cụ dev:** `?dev=1` / `--dev`; `?tran=N`; F1 tọa độ; F2 sao chép báo lỗi; F3 xem AI định làm gì; F5 nạp lại dữ liệu. Luôn hiện phiên bản và mã commit.
- **Build và deploy:** `tools/build_web.sh` (headless; báo trượt nếu bản nén > 25MB; preset có `*.json`, loại trừ `tests/`, `addons/gut/`); `tools/deploy_itch.sh` bằng butler, mặc định riêng tư.
- **MCP:** GoPeak 2.3.8 (profile `compact`) và Context7.
- **Bản địa hóa:** `i18n/text.csv`, mọi chữ đi qua `tr()`. Font tiếng Việt OFL.
- **Lưu game:** JSON trong `user://`, có trường phiên bản; phải chạy được trong iframe itch.io.
- **Git:** AI commit sau mỗi lần test xanh.
- **Một autoload duy nhất** (`AppState`). Màn hình: MENU, BATTLE, TRANSITION, ERROR.

### Yêu cầu UX

Không có tài liệu UX riêng. Các yêu cầu giao diện lấy từ GDD (Controls and Input, Art Style) và đã nằm trong FR6, FR11, FR15, FR24, FR34, FR39–FR42, NFR8–NFR9. Bổ sung sau bước readiness (2026-10-17), mỗi mục là tiêu chí nghiệm thu trong story tương ứng:
- tướng đã đi hoặc đã đánh có trạng thái nhìn thấy được (Story 1.5, 2.1);
- khi chọn tướng, các mục tiêu đánh được có viền màu riêng, khác ô đỏ của địch (Story 2.1, 2.3, 2.4);
- nhiều đòn cùng nhắm một ô thì hiện đủ các số thứ tự (Story 2.7);
- có dòng chữ báo pha hiện tại: "Lượt của bạn" / "Quân Nguyên đang ra đòn" (Story 2.11).
Khi sang giai đoạn 1 nên chạy `gds-ux`.

### Bản đồ phủ FR

| FR | Epic | Nội dung |
|---|---|---|
| FR1–FR4 | E1 | Bàn cờ, nạp trận, hiển thị ô và quân, `chi_so.json` |
| FR5–FR7 | E1 | Tướng, chọn tướng, tô sáng, đi xuyên quân mình |
| FR8 | E3 | Đường đi ít hầm chông nhất |
| FR9–FR11 | E1 | Đi rồi đánh, hủy nước đi gần nhất, kết thúc lượt |
| FR12–FR16 | E2 | Đòn 3 tướng (Trần Khánh Dư thử trên trận thử, ra trận thật từ trận 3), xác nhận đòn, trúng mọi phe (phần rừng/kho lương chặn đòn: E3) |
| FR17 | E2 | Đẩy/kéo từng ô, va chạm, sông (phần hầm chông: E3) |
| FR18–FR19, FR21 | E2 | Bộ binh, Kỵ binh, đòn địch không đẩy |
| FR20 | E2 (story cuối) | Cung kỵ, cắt được nếu trễ |
| FR22–FR26 | E2 | 4 pha, Enemy AI, báo đòn, đòn dịch theo, ra đòn theo thứ tự |
| FR27 | E3 | Gục trên hầm chông thì không báo đòn |
| FR28 | E2 | Sông |
| FR29–FR31 | E3 | Rừng, hầm chông, kho lương |
| FR32–FR34 | E3 | Mưu kế |
| FR35 | E3 | Quân tiếp viện |
| FR36 | E2 | Tiêu diệt |
| FR37 | E3 | Giữ ải |
| FR38 | E2 | Kiểm tra thắng/thua, tướng gục |
| FR39 | E3 | Chơi lại hiệp |
| FR47 | E3 | Làng và Lòng dân |
| FR48 | E3 | Giới hạn hiệp |
| FR40–FR41 | E2 | Rê chuột xem thông tin, xem trước kết quả đòn |
| FR42 | E4 | Tua nhanh |
| FR43 | E1–E4 | Trận 1 (E1 bố cục, E2 hoàn thiện), trận 2–5 (E3), trận 6 và tinh chỉnh (E4) |
| FR44–FR46 | E4 | Màn chuyển trận, màn hình chính, tự lưu |
| NFR1–NFR4 | E0 (đo lần đầu), E4 (đo đủ) | Hiệu năng, dung lượng, trình duyệt |
| NFR5–NFR9 | Mọi epic | Tất định, không kẹt, tiếng Việt, chỉ bấm chuột, ô đỏ nổi bật |

## Danh sách epic

**Ngân sách giờ** (chia lại 2026-10-17; E3 thêm ~10 giờ và E1 thêm ~3 giờ ngày 2026-10-18, E1 thêm ~3 giờ ngày 2026-10-19; tổng ≈ 146 giờ, khoảng 10 giờ/tuần):

| Epic | Giờ | Tuần (ước) | Số story |
|---|---|---|---|
| E0 Dựng nền | ~12 | 1–2 | 6 |
| E1 Bàn cờ và di chuyển | ~24 | 2–3 | 8 |
| E2 Combat cốt lõi | ~35 | 4–7 | 15 |
| E3 Địa hình và mưu kế | ~45 | 7–11 | 14 |
| E4 Sáu trận và chơi thử | ~30 | 12–14 | 9 |

**"Trễ" nghĩa là:** một epic dùng quá số giờ trên 25% (ví dụ E2 quá 44 giờ). Khi đó áp dụng phương án cắt: bàn nhìn chếch (Story 1.8, khi cắt thì giữ bàn isometric của Story 1.7), Cung kỵ (Story 2.15), trận 6 (Story 4.5), trau chuốt xem trước (Story 4.6), trận 4 "Bảo vệ làng" (Story 3.8; khi cắt thì đặt làng vào trận 3). Không cắt luật lõi. Gợi ý luật (Story 4.8) là phần hướng dẫn, không cắt (chốt 2026-10-18).

Thứ tự bắt buộc: E0 → E1 → E2 → E3 → E4. Epic sau dùng kết quả của epic trước, không epic nào cần epic sau mới chạy được. Mỗi story luật có một đợt duyệt kịch bản nhỏ bằng `tools/xem_kich_ban.sh`, trước khi viết code.

### E0: Dựng nền
Tác giả mở link itch.io (riêng tư) và thấy bàn cờ 7×7 trống. Gõ `tools/test.sh` thì thấy kết quả tiếng Việt.
**Phủ:** các yêu cầu bổ sung từ kiến trúc (project, GUT, `tools/`, ranh giới, MCP, `Log`, cờ dev, hiển thị phiên bản, bản địa hóa, font, build và deploy); NFR2, NFR4 (đo lần đầu).

### E1: Bàn cờ và di chuyển
Tác giả mở trận 1 từ file dữ liệu, chọn tướng, đi, hủy nước đi, kết thúc lượt; tự sửa file trận rồi bấm F5 thì thấy thay đổi; bàn cờ vẽ nhìn chếch, ô vuông (hình khối tạm).
**Phủ:** FR1–FR7, FR9–FR11, FR43 (bố cục trận 1). Công cụ dev F1, F5, `?tran=N`.

### E2: Combat cốt lõi ⚠️ rủi ro cao nhất
Tác giả chơi trọn trận 1 (2 tướng): địch báo đòn, đẩy địch xuống sông, làm địch đánh trúng nhau, thắng hoặc thua, thấy trước kết quả đòn. Đòn kéo của Trần Khánh Dư làm xong ở E2 nhưng chỉ thử trên trận thử, ra trận thật từ trận 3.
**Thứ tự trong epic:** luật (kịch bản xanh) → **mốc "bản xấu chơi được"** (chưa có hoạt ảnh) → hoạt ảnh và xem trước → hoàn thiện trận 1, có lời giải ghi lại → **Cung kỵ (story cuối, cắt được)**. Kết thúc bằng mốc tự chơi hết E2 (khoảng tuần 7).
**Phủ:** FR12–FR26, FR28, FR36, FR38, FR40, FR41, FR43 (hoàn thiện trận 1). Công cụ dev F2, F3.

### E3: Địa hình và mưu kế
Tác giả chơi được trận 2, 3, 4 (Bảo vệ làng) và 5 (Giữ ải), với rừng, hầm chông, giới hạn hiệp, làng và Lòng dân, kho lương, quân tiếp viện, 2 mưu kế và chơi lại hiệp.
**Phủ:** FR8, FR27, FR29–FR35, FR37, FR39, FR43 (trận 2–5, mỗi trận có lời giải ghi lại), FR47, FR48.

### E4: Sáu trận và chơi thử
Tác giả chơi trọn chuỗi 6 trận trên web, có màn hình chính, màn chuyển trận, tự lưu, tua nhanh; rồi gửi link cho 3–5 người thân chơi thử.
**Phủ:** FR42, FR43 (trận 6, tinh chỉnh cả 6 trận), FR44–FR46; NFR1–NFR3 đo đủ trên 3 trình duyệt.

### Ngoài phạm vi (ghi chú)
- **Công cụ giải thử** (tự tìm lời giải không mất tướng cho mỗi trận): để sau E4. Đề xuất của phòng thảo luận, tác giả chưa quyết.
- Giai đoạn 1–2: xem GDD, mục Out of Scope.

---

_Tiêu chí nghiệm thu viết dạng **Cho / Khi / Thì / Và** (Given / When / Then / And). Tác giả tự làm theo các bước này để kiểm tra, không cần đọc code._

## Epic 0: Dựng nền

Tác giả mở link itch.io (riêng tư) và thấy bàn cờ 7×7 trống; gõ `tools/test.sh` thì thấy kết quả tiếng Việt.

### Story 0.1: Project Godot trống chạy được trên máy

Là tác giả,
tôi muốn có một project Godot chạy được bằng một lệnh,
để thấy game của mình tồn tại mà không cần mở editor.

**Tiêu chí nghiệm thu:**

**Cho** repo mới clone về
**Khi** gõ `tools/chay.sh`
**Thì** cửa sổ game 1280×720 mở ra, hiện bàn cờ 7×7 trống vẽ bằng code
**Và** góc màn hình có số phiên bản và mã commit ngắn

**Khi** kéo giãn cửa sổ
**Thì** bàn cờ co giãn theo, giữ đúng tỉ lệ, không bị méo

**Và** project nằm trong `game/`, dùng Godot 4.7.2 với renderer Compatibility, cảnh báo `untyped_declaration` ở mức error, `build/` có trong `.gitignore`
**Và** gốc repo có file `CLAUDE.md` trỏ tới `_bmad-output/project-context.md` và `game-architecture.md`, để mọi phiên AI đọc hai file này trước khi làm việc
**Và** `tools/chay.sh` là mục mới so với tài liệu kiến trúc: chạy bản desktop trên máy, nhận thêm `--dev` và `--tran=N`

**Cho** máy chưa có Godot
**Khi** gõ `tools/cai_dat.sh`
**Thì** script tải đúng Godot 4.7.2.stable và export template, kiểm tra checksum, đặt vào một thư mục cố định
**Và** mọi script trong `tools/` chỉ dùng bản Godot này, không dùng bản nào khác có trên máy
**Và** chạy lại `tools/cai_dat.sh` khi đã cài thì không tải lại

### Story 0.2: Một lệnh để chạy toàn bộ test

Là tác giả,
tôi muốn gõ một lệnh và biết ngay game có đang hỏng không,
để không bao giờ phải đọc code.

**Tiêu chí nghiệm thu:**

**Cho** project từ Story 0.1
**Khi** gõ `tools/test.sh`
**Thì** terminal in tóm tắt tiếng Việt (ví dụ "✅ 3/3 test đạt")
**Và** lệnh thoát với mã 0

**Khi** AI cố tình đặt một test sai
**Thì** dòng tóm tắt báo "❌ trượt", ghi tên test, mã thoát khác 0

**Khi** thêm một file vào `src/core/` có dùng `Node` hoặc `get_tree()`, hoặc có phép gán `.hp =` / `.hp +=` / `.cell =` nằm ngoài `effects.gd`
**Thì** `check_boundaries.sh` chạy đầu tiên và báo trượt, kèm file, dòng và lý do bằng tiếng Việt

**Khi** một file JSON có `"da_duyet": true` bị sửa so với commit gần nhất
**Thì** test báo trượt và ghi tên file

**Và** GUT v9.7.1 nằm trong `game/addons/gut/`, chạy được `--headless`, không cần cửa sổ

### Story 0.3: Log, cờ dev và tham số khởi động

Là tác giả kiêm tester,
tôi muốn có một chế độ dev tách riêng,
để tôi có công cụ còn người thân chơi thử thì không thấy gì lạ.

**Tiêu chí nghiệm thu:**

**Cho** game chạy với `--dev` (trên web là `?dev=1`)
**Thì** góc màn hình hiện chữ "DEV"

**Cho** game chạy không có cờ dev
**Khi** bấm F1–F5
**Thì** không có gì xảy ra

**Khi** chạy với `?tran=3` hoặc `--tran=3`
**Thì** game ghi nhận số trận 3 (ở E0 chỉ cần log `[INFO][app] tran=3`)

**Và** có lớp static `Log` với 4 cấp ERROR/WARN/INFO/DEBUG, giữ 200 dòng gần nhất trong bộ nhớ; DEBUG chỉ ghi khi bật dev; không dùng `print()` ở chỗ khác

### Story 0.4: Chữ tiếng Việt và font

Là tác giả,
tôi muốn mọi chữ trong game nằm trong một file riêng và hiện đủ dấu,
để sau này dịch sang tiếng Anh mà không phải sửa code.

**Tiêu chí nghiệm thu:**

**Cho** `i18n/text.csv` có khóa `app.title` = "Chống Nguyên Mông"
**Khi** mở game
**Thì** tiêu đề hiện đúng, đủ dấu (thử cả "ữ, ặ, ượ")

**Khi** sửa chữ trong file CSV rồi chạy lại game
**Thì** chữ trên màn hình đổi theo, không cần sửa code

**Và** font là Be Vietnam Pro hoặc Noto Sans (OFL), dùng chung một Theme cho toàn game (NFR7)

### Story 0.5: Bản web trên itch.io (riêng tư)

Là tác giả,
tôi muốn mở game qua một đường link,
để thấy game của mình thật sự có mặt trên mạng.

**Tiêu chí nghiệm thu:**

**Việc tác giả tự làm** (AI hướng dẫn từng bước, không làm thay được):
1. Tạo tài khoản itch.io (nếu chưa có).
2. Tạo trang game, để chế độ riêng tư (Draft/Restricted).
3. Cài `butler` (qua `tools/cai_dat.sh`) rồi chạy `butler login` một lần.

**Khi** gõ `tools/build_web.sh`
**Thì** `build/web/` được tạo ra, script in dung lượng bản nén
**Và** script báo trượt nếu bản nén vượt 25MB

**Khi** gõ `tools/deploy_itch.sh`
**Thì** bản build được đẩy lên itch.io ở chế độ **riêng tư** và script in ra đường link

**Khi** mở link trên Chrome, Firefox và Edge
**Thì** cả 3 trình duyệt đều hiện bàn cờ trống, kèm phiên bản và mã commit

**Khi** game ghi một file thử vào `user://` rồi tải lại trang
**Thì** file vẫn còn khi chạy trong iframe của itch.io (kiểm tra lúc bật `?dev=1`)

**Và** dung lượng tải và thời gian tải lần đầu được ghi vào `NEXT-STEPS.md` (số đo NFR2 ban đầu); thời gian tải đo bằng DevTools của Chrome, giới hạn mạng ở 20 Mbps, xóa bộ nhớ đệm trước khi đo
**Và** preset export có filter `*.json`, loại trừ `tests/*` và `addons/gut/*`, xuất đơn luồng

### Story 0.6: Cài công cụ AI (MCP)

Là tác giả,
tôi muốn AI tự nhìn thấy được game đang chạy,
để khi tôi báo lỗi, AI tự xem log và chụp màn hình được.

**Tiêu chí nghiệm thu:**

**Cho** GoPeak 2.3.8 (profile `compact`) và Context7 đã được cài
**Khi** AI được yêu cầu "chụp màn hình game"
**Thì** AI làm được qua GoPeak

**Khi** AI cần tra một API Godot
**Thì** AI tra qua Context7 đúng bản 4.7

**Và** phiên bản được ghim trong file cấu hình MCP của repo, không chạy `npx -y` mà không kèm phiên bản

## Epic 1: Bàn cờ và di chuyển

Tác giả mở trận 1 từ file dữ liệu, chọn tướng, đi, hủy nước đi, kết thúc lượt; tự sửa file trận rồi bấm F5 thì thấy thay đổi; bàn cờ vẽ nhìn chếch, ô vuông (hình khối tạm).

### Story 1.1: Nạp chỉ số và trận từ file, báo lỗi bằng tiếng Việt

Là tác giả,
tôi muốn trận và chỉ số nằm trong file tôi tự sửa được, và được báo rõ khi sửa sai,
để khỏi phải nhờ AI mỗi lần sửa một con số.

**Tiêu chí nghiệm thu:**

**Cho** `data/chi_so.json` và `data/tran/tran_01.json` hợp lệ
**Khi** mở game với `--tran=1`
**Thì** game nạp trận không có lỗi
**Và** log ghi `[INFO][battle] nạp trận tran_01`

**Khi** đổi một ký hiệu trong lớp `dia_hinh` thành ký hiệu lạ (ví dụ `X`)
**Thì** chế độ dev hiện màn hình lỗi ghi rõ file, dòng, cột và ký hiệu sai, game không sập

**Khi** file có nhiều lỗi cùng lúc
**Thì** màn hình liệt kê tất cả lỗi, không chỉ lỗi đầu tiên

**Khi** `chi_so.json` thiếu một khóa
**Thì** màn hình lỗi ghi tên khóa bị thiếu

**Và** khi không bật dev, chỉ hiện thông báo ngắn kèm nút "Về menu"
**Và** `test_loaders.gd` kiểm tra từng loại lỗi, mỗi loại phải ra đúng câu báo lỗi (FR2, FR4)

### Story 1.2: Hiện bàn cờ trận 1 (bố cục đầu tiên)

Là tác giả,
tôi muốn thấy trận 1 hiện ra đúng như file dữ liệu,
để kiểm tra dữ liệu bằng mắt.

**Tiêu chí nghiệm thu:**

**Cho** `tran_01.json` bản đầu (sông, 2 tướng Nguyễn Khoái và Phạm Ngũ Lão, 3 Bộ binh, nhiệm vụ Tiêu diệt)
**Khi** mở `--tran=1`
**Thì** bàn 7×7 hiện đúng từng ô địa hình và từng quân ở đúng vị trí trong file (FR1, FR3)
**Và** mỗi loại ô có màu hoặc ký hiệu riêng (đất trống, sông, rừng, hầm chông, kho lương, ô ải); mỗi quân là đồng tròn có chữ: Khoái, Lão, Dư; quân Nguyên là B, K, C
**Và** mỗi đồng quân hiện số máu hiện tại (để test tay các story luật ở E2 mà không cần chờ Story 2.5)
**Và** có thêm `data/tran/thu_ba_tuong.json` (đủ 3 tướng, chỉ mở được khi bật dev bằng `?tran=thu_ba_tuong`), dùng để thử Trần Khánh Dư trước trận 3

**Khi** bật dev và bấm F1
**Thì** mỗi ô hiện tọa độ `cot,hang` (gốc trên trái), mỗi quân hiện id (tướng 1–3, quân Nguyên từ 101); bấm lại thì ẩn

**Khi** sửa vị trí một quân trong file rồi chạy lại
**Thì** quân hiện ở vị trí mới

### Story 1.3: Kịch bản luật và công cụ duyệt trên terminal

Là tác giả,
tôi muốn đọc và duyệt luật dưới dạng bàn cờ trước và sau,
để quyết spec mà không cần đọc code.

**Tiêu chí nghiệm thu:**

**Cho** một kịch bản mẫu trong `tests/kich_ban/di_chuyen/` (có `truoc`, `hanh_dong`, `sau`, `mo_ta`, `da_duyet: false`)
**Khi** gõ `tools/xem_kich_ban.sh`
**Thì** terminal in bàn trước và bàn sau đặt cạnh nhau, kèm mô tả tiếng Việt và tên file

**Khi** gõ `tools/xem_kich_ban.sh di_chuyen`
**Thì** chỉ hiện kịch bản của nhóm đó

**Khi** gõ `tools/test.sh`
**Thì** mọi file trong `kich_ban/` đều được chạy; tóm tắt ghi riêng số kịch bản đã duyệt và chưa duyệt

**Và** chỉ cần đổi `da_duyet` thành `true` là duyệt xong; từ lúc đó file bị khóa (Story 0.2)

### Story 1.4: Chọn tướng và xem các ô đi được

Là người chơi,
tôi muốn chọn một tướng và thấy ngay nó đi được tới đâu,
để tính nước đi.

**Tiêu chí nghiệm thu:**

**Cho** AI đã viết các kịch bản `di_chuyen/` (tầm 3 ô; đi xuyên quân mình; bị quân địch chặn; bị sông, rừng, kho lương chặn; mép bàn)
**Khi** tác giả duyệt đợt 1 bằng `tools/xem_kich_ban.sh`
**Thì** mới bắt đầu viết code

**Khi** bấm vào Nguyễn Khoái (hoặc phím `1`)
**Thì** các ô đi tới được trong 3 bước sáng lên (FR5, FR6)
**Và** ô có quân mình thì đi xuyên qua được nhưng không dừng ở đó được; ô có quân Nguyên, sông, rừng, kho lương thì không đi qua được (FR7)

**Khi** rê chuột lên một ô sáng
**Thì** game vẽ đường đi tới ô đó

**Khi** bấm phím `2` hoặc `3`
**Thì** đổi sang tướng tương ứng; nếu tướng đó không có trong trận (ví dụ phím `3` ở trận 1) thì không có gì xảy ra

**Và** `tools/test.sh` xanh, mọi kịch bản `di_chuyen/` đã duyệt đều đạt

### Story 1.5: Đi, hủy nước đi, kết thúc lượt

Là người chơi,
tôi muốn đi, hủy nước vừa đi và kết thúc lượt,
để thử nhiều cách đứng mà không sợ bấm nhầm.

**Tiêu chí nghiệm thu:**

**Khi** bấm vào một ô sáng
**Thì** tướng di chuyển tới đó, không đi tiếp được nữa, nhưng vẫn còn lượt đánh (đánh có ở E2) (FR9)

**Khi** bấm Hủy (hoặc phím `Z`)
**Thì** chỉ nước đi gần nhất được hoàn tác, tướng về ô cũ và đi lại được (FR10)

**Khi** đã hủy hết các nước đi mà vẫn bấm `Z`
**Thì** không có gì xảy ra, game không lỗi

**Khi** bấm Kết thúc lượt (hoặc phím `Space`)
**Thì** số hiệp tăng thêm 1 và mọi tướng đi lại được (pha địch chèn vào đây ở E2) (FR11)

**Khi** một tướng đã đi
**Thì** đồng quân của tướng đó có dấu hiệu "đã đi" (ví dụ viền mờ), khác với tướng chưa hành động

**Và** sau mỗi lệnh, `BattleState.validate()` rỗng; có kịch bản cho hủy nước đi và kết thúc lượt
**Và** mọi thao tác đều làm được chỉ bằng bấm chuột; phím tắt chỉ là lối tắt, khai báo trong InputMap (NFR8)

### Story 1.6: F5 nạp lại dữ liệu

Là tác giả,
tôi muốn sửa file trận hoặc chỉ số rồi thấy kết quả ngay,
để tự cân bằng game.

**Tiêu chí nghiệm thu:**

**Cho** trận 1 đang mở, đã bật dev
**Khi** sửa tầm đi của tướng trong `chi_so.json` thành 2 rồi bấm F5
**Thì** trận khởi động lại và tướng chỉ còn đi được 2 ô

**Khi** sửa `tran_01.json` cho sai rồi bấm F5
**Thì** màn hình lỗi hiện ra như Story 1.1; sửa lại cho đúng, bấm F5 lần nữa thì trận chạy lại bình thường

### Story 1.7: Bàn cờ nghiêng (isometric) tạm

Là tác giả,
tôi muốn bàn cờ trông có chiều sâu,
để game bớt phẳng ngay trong prototype, trước khi có tranh ở E8.

_Thêm 2026-10-18 theo `sprint-change-proposal-2026-10-18-isometric.md`. Cắt được nếu E1 trễ._

**Tiêu chí nghiệm thu:**

**Cho** trận 1 đang mở
**Thì** bàn 7×7 hiện thành hình thoi lớn, mỗi ô là một hình thoi rộng gấp đôi cao; ô `0,0` ở đỉnh trên cùng (cột tăng thì xuống bên phải, hàng tăng thì xuống bên trái); bàn nằm gọn trong cửa sổ, chừa chỗ cho HUD
**Và** sông thấp hơn mặt đất; rừng, kho lương, làng, ô ải là khối nhô lên có mặt bên tối hơn; hầm chông phẳng có ký hiệu; mỗi loại ô vẫn phân biệt được bằng màu hoặc ký hiệu
**Và** mỗi quân là đồng tròn khắc chữ đứng trên ô, có bóng, vẫn hiện số máu
**Và** quân hoặc khối ở gần người xem che lên vật ở phía sau, không bị ngược

**Khi** bấm vào bất kỳ ô nào, kể cả sát mép hình thoi
**Thì** game chọn đúng ô đó (thử với cả 49 ô)

**Khi** chọn tướng và rê chuột lên ô sáng
**Thì** ô sáng, vòng chọn và đường đi hiện đúng trên bàn nghiêng như Story 1.4

**Khi** bật dev và bấm F1
**Thì** tọa độ `cot,hang` và id quân hiện đúng trên từng ô thoi

**Và** `tools/test.sh` xanh; có test cho phép đổi ô ↔ điểm (đi rồi về đúng ô, điểm sát mép rơi đúng ô)
**Và** bản web trên itch.io chạy mượt như trước
**Và** không sửa gì trong `src/core/`, dữ liệu trận và kịch bản luật

### Story 1.8: Bàn cờ nhìn chếch, ô vuông (thay bàn isometric)

Là tác giả,
tôi muốn bàn cờ theo kiểu pixel art nhìn chếch từ trên xuống như ảnh mẫu,
để hình tạm bây giờ đã đúng hướng tranh sẽ làm ở E8.

_Thêm 2026-10-19: tác giả đổi hướng hình ảnh (xem decision-log, ảnh mẫu ở `art-reference/`). Làm trước Story 2.3. Cắt được: khi cắt thì giữ bàn isometric._

**Tiêu chí nghiệm thu:**

**Cho** trận 1 đang mở
**Thì** bàn 7×7 là các ô vuông; ô `0,0` ở góc trên bên trái, cột tăng sang phải, hàng tăng xuống dưới, giống hệt cách viết trong file trận; bàn nằm gọn trong cửa sổ, chừa chỗ cho HUD
**Và** kích thước ô là bội số của 16 px (để E8 thay bằng pixel art không bị nhòe)
**Và** sông thấp hơn mặt đất, thấy bờ ở cạnh trên; rừng, kho lương, làng là khối nhô lên, thấy được mặt trước tối hơn; ô ải là bệ đá thấp; hầm chông phẳng có ký hiệu; mỗi loại ô vẫn phân biệt được bằng màu hoặc ký hiệu
**Và** mỗi quân là đồng tròn khắc chữ đứng trên ô, có bóng, vẫn hiện số máu; quân và khối cao có thể che một phần ô phía trên, vật ở hàng dưới che vật ở hàng trên, không bị ngược

**Khi** bấm vào bất kỳ ô nào, kể cả sát mép ô
**Thì** game chọn đúng ô đó (thử với cả 49 ô)
**Và** bấm vào phần thân quân hoặc khối nhô lên ô phía trên thì vẫn chọn đúng quân hoặc ô của khối đó (như Story 1.7)

**Khi** chọn tướng, rê chuột lên ô sáng, xem viền mục tiêu đánh (Story 2.1, 2.2)
**Thì** ô sáng, vòng chọn, đường đi và viền mục tiêu hiện đúng trên bàn mới

**Khi** bật dev và bấm F1
**Thì** tọa độ `cot,hang` và id quân hiện đúng trên từng ô

**Và** `tools/test.sh` xanh; test đổi ô ↔ điểm cập nhật theo bàn mới (đi rồi về đúng ô, điểm sát mép rơi đúng ô, bấm vào thân quân chọn đúng quân)
**Và** bản web trên itch.io chạy mượt như trước
**Và** không sửa gì trong `src/core/`, dữ liệu trận và kịch bản luật

## Epic 2: Combat cốt lõi ⚠️

Tác giả chơi trọn trận 1 (2 tướng): địch báo đòn, đẩy địch xuống sông, làm địch đánh trúng nhau, thắng hoặc thua, thấy trước kết quả đòn.

**Quy trình chung cho mọi story luật (2.1–2.9, 2.15):** AI viết kịch bản → tác giả duyệt bằng `tools/xem_kich_ban.sh` → kịch bản mới phải trượt → AI viết code tới khi `tools/test.sh` xanh. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả.

### Story 2.1: Nguyễn Khoái đánh, đẩy và va chạm

Là người chơi,
tôi muốn Nguyễn Khoái đánh và đẩy địch vào mép bàn, vào vật cản, vào nhau,
để dùng vị trí làm vũ khí.

**Tiêu chí nghiệm thu:**

**Cho** Nguyễn Khoái đứng kề một Bộ binh 3 máu
**Khi** bấm vào Bộ binh
**Thì** Bộ binh còn 1 máu và bị đẩy 1 ô theo hướng đánh (FR12)

**Khi** quân bị đẩy vào mép bàn, rừng hoặc kho lương
**Thì** quân đứng yên và mất 1 máu
**Khi** quân bị đẩy vào quân khác
**Thì** cả hai mất 1 máu (FR17)

**Khi** mục tiêu gục vì sát thương
**Thì** không có bước đẩy

**Khi** tướng đã đi rồi mới đánh
**Thì** phải bấm vào mục tiêu thêm một lần để xác nhận (FR15)

**Khi** chọn một tướng
**Thì** các mục tiêu đánh được trong tầm có viền màu riêng, khác hẳn ô đỏ của địch; áp dụng cho mọi đòn tướng về sau

**Khi** một tướng đã đánh
**Thì** đồng quân của tướng đó mờ hẳn, không chọn để đi hay đánh được nữa

**Cho** tướng A vừa đi, rồi tướng B đánh
**Khi** bấm Hủy (`Z`)
**Thì** không có gì xảy ra: đòn đánh đã xóa sạch lịch sử hủy (FR10); có kịch bản cho ca này

**Và** đẩy đi từng ô qua `ForcedMove.run`, dùng chung cho mọi đòn đẩy/kéo về sau
**Và** có kịch bản trong `day/`, `va_cham/`, đã duyệt và đạt

### Story 2.2: Sông và đánh trúng quân mình

Là người chơi,
tôi muốn đẩy quân Nguyên xuống sông, và biết đòn của mình cũng trúng tướng mình,
để vừa có vũ khí mạnh vừa phải cẩn thận khi đứng.

**Tiêu chí nghiệm thu:**

**Khi** quân Nguyên bị đẩy xuống sông
**Thì** nó chết đuối và bị nhấc khỏi bàn (FR28)

**Khi** tướng bị đẩy vào sông
**Thì** tướng mất 1 máu, đứng yên

**Cho** Nguyễn Khoái đang được chọn, đứng kề Phạm Ngũ Lão
**Khi** bấm vào Phạm Ngũ Lão
**Thì** game chuyển sang chọn Phạm Ngũ Lão, không có đòn đánh nào (không được chọn tướng mình làm mục tiêu) (FR16)

**Khi** Nguyễn Khoái đẩy một quân Nguyên va vào tướng mình
**Thì** cả quân Nguyên và tướng mình đều mất 1 máu

**Và** có kịch bản trong `dia_hinh/` (sông) và `va_cham/` (trúng quân mình), đã duyệt và đạt

### Story 2.3: Phạm Ngũ Lão phóng lao

Là người chơi,
tôi muốn Phạm Ngũ Lão phóng lao từ xa,
để kết liễu địch mà không phải đứng gần.

**Tiêu chí nghiệm thu:**

**Cho** Phạm Ngũ Lão và một quân Nguyên thẳng hàng, cách 3 ô
**Khi** bấm vào quân đó
**Thì** quân đó mất 1 máu (FR13)

**Khi** có một quân đứng ở ô kề trên hàng
**Thì** lao bay qua quân đó, trúng vật đầu tiên ở ô thứ 2–4

**Khi** vật đầu tiên ở ô thứ 2–4 là tướng mình
**Thì** tướng mình mất 1 máu

**Khi** có sông nằm giữa
**Thì** lao vẫn bay qua

**Khi** không có vật nào ở ô thứ 2–4
**Thì** không bấm đánh được về hướng đó

**Và** chỉ quân Nguyên mới có viền "đánh được"; lao trúng tướng mình chỉ xảy ra khi tướng mình là vật đầu tiên trên đường tới quân Nguyên được chọn, và bản xem trước (Story 2.12) phải hiện rõ điều đó

**Và** phần "rừng, kho lương chặn lao" làm ở E3

### Story 2.4: Trần Khánh Dư kéo

Là người chơi,
tôi muốn Trần Khánh Dư kéo địch,
để kéo chúng vào ô đỏ, xuống sông hoặc ra khỏi vị trí đẹp.

**Tiêu chí nghiệm thu:**

**Cho** Trần Khánh Dư và một quân Nguyên thẳng hàng, cách 3 ô, đường trống
**Khi** bấm vào quân đó
**Thì** quân đó bị kéo 2 ô về phía Trần Khánh Dư, không mất máu (FR14)

**Khi** đường kéo bị chặn giữa chừng
**Thì** quân dừng sớm và xử lý va chạm theo bảng di chuyển cưỡng bức

**Khi** vật đầu tiên trên hàng là tướng
**Thì** không kéo được

**Khi** mục tiêu đã đứng kề
**Thì** không có gì xảy ra, không ai mất máu

**Khi** đường kéo đi qua sông
**Thì** quân Nguyên rơi xuống sông và chết đuối

**Và** thử trong game bằng trận thử `thu_ba_tuong` (Story 1.2); trận 1–2 không có Trần Khánh Dư

### Story 2.5: Máu, gục, thắng và thua (Tiêu diệt)

Là người chơi,
tôi muốn thấy rõ máu từng quân và biết khi nào thắng, thua,
để biết mình đang đứng ở đâu trong trận.

**Tiêu chí nghiệm thu:**

**Cho** trận 1 đang chơi
**Thì** mỗi đồng quân hiện số máu hiện tại (đã có từ Story 1.2), máu tụt thì số đổi ngay

**Khi** một quân còn 0 máu
**Thì** quân đó bị nhấc khỏi bàn (FR38)

**Khi** quân Nguyên cuối cùng gục
**Thì** hiện "Thắng" ngay lập tức (FR36)

**Khi** mọi tướng trên bàn đều gục (trận 1–2 là 2 tướng)
**Thì** hiện "Thua"

**Khi** quân Nguyên cuối cùng và tướng cuối cùng gục trong cùng một đòn
**Thì** tính là thắng

**Và** kiểm tra thắng/thua sau mỗi lần có quân gục, cả trong lượt người chơi lẫn trong pha địch

### Story 2.6: Địch chuẩn bị: AI đi và chọn mục tiêu

Là người chơi,
tôi muốn quân Nguyên đi theo luật mà tôi đoán trước được,
để tính được nước đi của chúng mà không cần xem code.

**Tiêu chí nghiệm thu:**

**Cho** đầu hiệp
**Khi** pha địch chuẩn bị chạy
**Thì** từng quân Nguyên (theo thứ tự trong file trận) chọn mục tiêu là tướng gần nhất theo số bước đi, rồi đi tới ô đứng mà từ đó đòn trúng được mục tiêu; không có ô như vậy thì đi tới ô gần mục tiêu nhất (FR22, FR23)

**Khi** hai lựa chọn hòa điểm
**Thì** AI chọn theo thứ tự hướng B→Đ→N→T

**Khi** bật dev và bấm F3
**Thì** mỗi quân Nguyên hiện đang nhắm ai, chọn ô nào, vì sao

**Và** Bộ binh (3 máu, đi 2, chém 1 ô kề) và Kỵ binh (2 máu, đi 3, xung phong thẳng hàng) đúng chỉ số trong `chi_so.json` (FR18, FR19)
**Và** có kịch bản trong `ai/`, đã duyệt và đạt
**Và** ở story này đòn của địch đã được ghi vào `BattleState` nhưng chưa cần vẽ; tác giả kiểm bằng F3 và kịch bản

### Story 2.7: Hiển thị báo đòn

Là người chơi,
tôi muốn nhìn bàn là biết ngay ô nào sắp bị đánh và theo thứ tự nào,
để tính trước được nước đi.

**Tiêu chí nghiệm thu:**

**Cho** pha địch chuẩn bị đã chạy (Story 2.6)
**Thì** ô bị nhắm tô đỏ; Kỵ binh có mũi tên chỉ hướng; mỗi đòn có số thứ tự lớn trên bàn (FR24)

**Khi** hai đòn cùng nhắm một ô
**Thì** ô đó hiện đủ cả hai số thứ tự (ví dụ "1·3")

**Khi** ô đỏ trùng với ô có quân
**Thì** vẫn thấy rõ cả quân, máu và số thứ tự

**Và** ô đỏ và số thứ tự là thứ nổi bật nhất trên màn hình (NFR9)
**Và** có kịch bản trong `don_dich/` cho dữ liệu báo đòn (ô, hướng, thứ tự)

### Story 2.8: Địch ra đòn theo thứ tự

Là người chơi,
tôi muốn đòn địch đánh đúng như đã báo,
để tin vào những gì mình thấy trên bàn.

**Tiêu chí nghiệm thu:**

**Cho** các đòn đã báo
**Khi** bấm Kết thúc lượt
**Thì** các đòn đánh lần lượt theo đúng số thứ tự; đòn địch chỉ gây sát thương, không đẩy (FR21, FR26)

**Khi** tướng đã rời khỏi ô đỏ
**Thì** đòn đánh vào ô trống, không ai mất máu

**Khi** quân Nguyên đứng trong ô đỏ của đồng đội
**Thì** nó ăn đòn

**Khi** Kỵ binh xung phong vào hàng trống tới mép
**Thì** đòn trượt

**Và** `test_determinism.gd` chạy mỗi kịch bản hai lần, kết quả giống hệt (NFR5)

### Story 2.9: Đòn dịch theo và hủy đòn

Là người chơi,
tôi muốn đòn địch dịch theo khi tôi đẩy hoặc kéo quân địch,
để làm lệch đòn của chúng vào nhau.

**Tiêu chí nghiệm thu:**

**Khi** người chơi đẩy hoặc kéo một quân đã báo đòn
**Thì** ô đỏ của nó dịch theo, giữ nguyên hướng và khoảng cách (FR25)

**Khi** đòn dịch ra ngoài bàn
**Thì** đòn bị hủy, ô đỏ biến mất

**Khi** chủ đòn gục trước lượt ra đòn của mình
**Thì** đòn bị hủy

**Và** có kịch bản trong `don_dich/` cho dịch theo và hủy đòn, đã duyệt và đạt

> 🎯 **Mốc "bản xấu chơi được":** sau Story 2.9, tác giả chơi được trận 1 từ đầu đến cuối (chưa có hoạt ảnh). Tác giả tự chơi, báo lỗi luật, rồi mới sang Phần 2.

### Story 2.10: Rê chuột xem thông tin

Là người chơi,
tôi muốn rê chuột lên quân và ô để xem thông tin,
để không phải nhớ chỉ số.

**Tiêu chí nghiệm thu:**

**Khi** rê chuột lên một quân
**Thì** hiện tên, máu, đòn sắp đánh và số thứ tự ra đòn (FR40)

**Khi** rê chuột lên một quân Nguyên
**Thì** ô đỏ của chính quân đó được làm nổi bật

**Khi** rê chuột lên một ô
**Thì** hiện tên loại địa hình và hiệu ứng (chữ lấy từ `text.csv`)

### Story 2.11: Hoạt ảnh phát lại sự kiện

Là người chơi,
tôi muốn thấy từng bước đẩy, va chạm, ra đòn diễn ra,
để hiểu chuyện gì vừa xảy ra.

**Tiêu chí nghiệm thu:**

**Khi** một lệnh được phân giải
**Thì** các sự kiện (đi, bị đẩy, bị kéo, va chạm, mất máu, gục, chết đuối, ra đòn, hủy đòn, đòn dịch theo) diễn ra bằng Tween theo đúng thứ tự trong nhật ký sự kiện

**Khi** pha địch ra đòn
**Thì** toàn bộ hoạt ảnh của pha ≤ 3 giây (NFR3)

**Khi** hoạt ảnh đang chạy
**Thì** không bấm được lệnh mới

**Và** màn hình luôn có dòng chữ báo pha: "Lượt của bạn" hoặc "Quân Nguyên đang ra đòn"

**Và** ô đỏ và số thứ tự là thứ nổi bật nhất trên màn hình (NFR9)
**Và** hoạt ảnh chỉ đọc sự kiện và bản chụp, không sửa trạng thái

### Story 2.12: Xem trước kết quả đòn

Là người chơi,
tôi muốn thấy trước kết quả của đòn trước khi bấm,
để tính đúng mà không phải hoàn tác.

**Tiêu chí nghiệm thu:**

**Cho** một tướng đang chọn
**Khi** rê chuột lên một mục tiêu đánh được
**Thì** hiện bóng mờ ở vị trí cuối của mọi quân bị ảnh hưởng và số máu sau đòn (FR41)

**Khi** bấm đánh thật
**Thì** kết quả khớp đúng với bản xem trước (có test so sánh hai kết quả)

**Khi** rời chuột khỏi mục tiêu
**Thì** bóng mờ biến mất

**Và** xem trước chỉ chạy lại khi đổi ô trỏ chuột, không chạy mỗi khung hình

### Story 2.13: F2 sao chép báo lỗi

Là tester,
tôi muốn báo lỗi bằng một phím,
để dán thẳng cho AI mà không phải tả lại.

**Tiêu chí nghiệm thu:**

**Cho** game đang chạy, đã bật dev
**Khi** bấm F2
**Thì** clipboard có: bàn hiện tại (dạng `truoc` của kịch bản), các lệnh trong hiệp, 200 dòng log, phiên bản build
**Và** màn hình báo "Đã sao chép báo lỗi"

**Khi** dán nội dung đó cho AI
**Thì** AI chuyển được thành một kịch bản tái hiện lỗi (thử trên một lỗi cố tình tạo ra)

### Story 2.14: Hoàn thiện trận 1 và mốc tự chơi hết E2

Là tác giả,
tôi muốn trận 1 đã có lời giải được kiểm chứng,
để biết trận này giải được và dạy đúng luật.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất bố cục cuối của trận 1 (2 tướng; dạy né ô đỏ và đẩy xuống sông)
**Thì** kèm theo một lời giải không mất tướng, ghi theo từng hiệp vào `data/tran/tran_01_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải đó
**Thì** thắng và không mất tướng nào
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** bản mới được deploy lên itch (riêng tư)
**Và** mốc tự chơi hết E2 (khoảng tuần 7): nếu tác giả thấy chán thì sửa luật trước khi sang E3

### Story 2.15: Cung kỵ (cắt được nếu trễ)

Là người chơi,
tôi muốn có Cung kỵ yếu máu nhưng bắn xa,
để phải chọn hạ quân nào trước.

**Tiêu chí nghiệm thu:**

**Cho** một Cung kỵ (1 máu, đi 3)
**Khi** pha địch chuẩn bị
**Thì** nó báo đòn vào một ô thẳng hàng cách 2–3 ô (FR20)

**Khi** có quân đứng giữa
**Thì** tên bay qua, chỉ trúng ô đã báo

**Và** có kịch bản và luật AI cho Cung kỵ
**Và** nếu story này bị cắt (E2 trễ), trận 3 và trận 6 dùng Bộ binh thay Cung kỵ (xem Story 3.6); không cần cờ bật/tắt trong code
**Và** phần "rừng, kho lương chặn tên" làm ở E3

## Epic 3: Địa hình và mưu kế

Tác giả chơi được trận 2, 3, 4 (Bảo vệ làng) và 5 (Giữ ải), với rừng, hầm chông, giới hạn hiệp, làng và Lòng dân, kho lương, quân tiếp viện, 2 mưu kế và chơi lại hiệp. Quy trình kịch bản luật như E2.

### Story 3.1: Rừng và vật cản chặn đòn

Là người chơi,
tôi muốn rừng và kho lương che chắn được đòn đánh,
để dùng địa hình chặn Kỵ binh và Cung kỵ.

**Tiêu chí nghiệm thu:**

**Cho** rừng hoặc kho lương nằm giữa Phạm Ngũ Lão và mục tiêu, kể cả ở ô kề
**Khi** phóng lao
**Thì** lao bị chặn, mục tiêu không mất máu (FR13)

**Khi** Kỵ binh xung phong vào rừng hoặc kho lương
**Thì** đòn dừng ở vật cản, không ai mất máu (FR19)

**Khi** có rừng hoặc kho lương nằm giữa Cung kỵ và ô đã báo
**Thì** tên bị chặn (FR20)

**Khi** vật đầu tiên trên hàng của Trần Khánh Dư là rừng hoặc kho lương
**Thì** không kéo được, không có viền "đánh được" về hướng đó (FR14)

(Va chạm khi bị đẩy vào rừng hoặc kho lương đã có từ Story 2.1; story này chỉ thêm phần chặn đòn.)

**Và** có kịch bản trong `dia_hinh/` (rừng)

### Story 3.2: Chơi lại hiệp

Là người chơi,
tôi muốn chơi lại hiệp một lần khi tính sai,
để sửa sai mà không phải đánh lại cả trận.

**Tiêu chí nghiệm thu:**

**Cho** đang ở lượt người chơi, đã đi và đánh vài nước
**Khi** bấm Chơi lại (hoặc phím `R`)
**Thì** bàn về đúng trạng thái đầu lượt người chơi của hiệp này (FR39)

**Khi** đã dùng một lần trong trận
**Thì** nút mờ đi, phím `R` không còn tác dụng
**Và** giao diện hiện số lần còn lại

**Cho** đã dùng một mưu kế trong lượt này
**Khi** bấm Chơi lại
**Thì** mưu kế đó được trả lại, dùng lại được trong lượt chơi lại (FR39)

**Khi** đã chơi lại hiệp rồi bấm Hủy (`Z`)
**Thì** không quay về được nước đi nào trước lúc chơi lại; bản chụp hủy nước đi đã bị xóa

### Story 3.3: Trận 2

Là tác giả,
tôi muốn trận 2 dạy dùng rừng chặn Kỵ binh và cho địch đánh trúng nhau,
để người chơi học luật mới từng bước.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_02.json` (2 tướng: Nguyễn Khoái và Phạm Ngũ Lão; 2 Kỵ binh, 1 Bộ binh, rừng và sông, Tiêu diệt)
**Thì** kèm lời giải không mất tướng trong `tran_02_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** trận chỉ giới thiệu luật mới theo đúng bảng Campaign Structure

### Story 3.4: Hầm chông

Là người chơi,
tôi muốn hầm chông làm đau mọi quân đi qua,
để kéo và đẩy địch qua bẫy.

**Tiêu chí nghiệm thu:**

**Cho** một ô hầm chông
**Khi** bất kỳ quân nào đi vào ô (tự đi, bị đẩy, bị kéo, kể cả chỉ đi ngang qua)
**Thì** quân đó mất 1 máu cho mỗi ô hầm chông đi qua (FR30)

**Khi** quân gục giữa đường
**Thì** dừng tại ô đó, bị nhấc khỏi bàn

**Khi** quân Nguyên gục trên hầm chông lúc đang đi trong pha chuẩn bị
**Thì** không báo đòn (FR27)

**Khi** tướng tự đi tới một ô đích
**Thì** game chọn đường ít hầm chông nhất, hòa thì theo B→Đ→N→T (FR8)
**Và** ô sáng và đường đi hiện số máu sẽ mất ("−1", "−2")

**Và** đứng yên trên ô hầm chông thì không mất thêm máu

### Story 3.5: Giới hạn hiệp (Tiêu diệt)

Là người chơi,
tôi muốn trận Tiêu diệt có số hiệp tối đa,
để không thể chỉ né đòn mãi mà phải chủ động tính đường hạ địch.

**Tiêu chí nghiệm thu:**

**Cho** file trận Tiêu diệt có `so_hiep_toi_da: 4`
**Thì** HUD hiện "Hiệp 1/4"; hiệp cuối có màu nổi bật (FR48)

**Khi** kết thúc bước cuối hiệp của hiệp 4 mà còn quân Nguyên trên bàn
**Thì** hiện "Thua: hết hiệp"

**Khi** quân Nguyên cuối cùng gục trong pha ra đòn của hiệp 4 (địch đánh trúng nhau)
**Thì** tính là thắng

**Khi** file trận không có `so_hiep_toi_da`
**Thì** không giới hạn hiệp, HUD chỉ hiện "Hiệp 3"

**Khi** `so_hiep_toi_da` không phải số nguyên dương
**Thì** bộ nạp báo lỗi tiếng Việt, ghi rõ file và giá trị sai

**Và** chơi lại hiệp không làm đổi số hiệp
**Và** có kịch bản trong `gioi_han_hiep/`, đã duyệt và đạt (gồm ca MẶC ĐỊNH: hết hiệp tính ở cuối hiệp cuối)

### Story 3.6: Trận 3

Là tác giả,
tôi muốn trận 3 dạy đòn kéo, hầm chông và giới hạn hiệp,
để người chơi kéo địch vào bẫy.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_03.json` (3 tướng, Trần Khánh Dư ra trận lần đầu; 2 Bộ binh, 2 Cung kỵ, hầm chông và rừng, Tiêu diệt, có `so_hiep_toi_da`)
**Thì** kèm lời giải không mất tướng, thắng trong số hiệp cho phép, trong `tran_03_loi_giai.md` (FR43, FR48)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** nếu Cung kỵ đã bị cắt ở E2 thì thay bằng Bộ binh và viết lại lời giải

### Story 3.7: Làng và Lòng dân

Là người chơi,
tôi muốn có làng phải bảo vệ,
để né đòn không còn là cách an toàn duy nhất: né thì làng có thể bị đánh.

**Tiêu chí nghiệm thu:**

**Cho** bàn có ô `D` và file trận có `long_dan: 3`
**Thì** làng hiện như một loại ô riêng, HUD hiện "Lòng dân 3/3" (FR3, FR47)

**Khi** Bộ binh chém vào ô làng, Kỵ binh xung phong trúng làng, hoặc lao/tên bị làng chặn
**Thì** Lòng dân −1, có hoạt ảnh và dòng chữ báo

**Khi** đẩy hoặc kéo quân Nguyên va vào làng
**Thì** quân đó mất 1 máu như va chạm, và Lòng dân −1

**Khi** Lòng dân về 0
**Thì** thua ngay; nếu cùng lúc quân Nguyên cuối cùng gục thì tính là thắng

**Khi** pha địch chuẩn bị trong trận Tiêu diệt có làng
**Thì** Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất (theo số bước đi), hòa thì ưu tiên làng; Cung kỵ chỉ nhắm tướng (FR23)
**Và** bật dev, bấm F3 thì thấy rõ quân nào đang nhắm làng

**Khi** chơi lại hiệp
**Thì** Lòng dân về đúng như đầu lượt người chơi

**Khi** rê chuột xem trước một đòn làm làng bị trúng
**Thì** bản xem trước hiện "−1 Lòng dân"

**Và** làng không đi vào được, chặn đường đi, lao, tên và xung phong; Trần Khánh Dư không kéo được nếu vật đầu tiên trên hàng là làng
**Và** bộ nạp báo lỗi tiếng Việt nếu bàn có `D` mà thiếu `long_dan`
**Và** có kịch bản trong `lang/`, đã duyệt và đạt (gồm các ca MẶC ĐỊNH: làng chặn lao/tên và bị trừ Lòng dân; hòa thì ưu tiên làng)

### Story 3.8: Trận 4: Bảo vệ làng

Là tác giả,
tôi muốn trận 4 dạy bảo vệ làng,
để người chơi lần đầu phải cân giữa né đòn và che chắn cho dân.

_Cắt được nếu trễ: khi cắt, đặt làng vào trận 3 và chuỗi còn 5 trận._

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_04.json` (3 tướng; Tiêu diệt; có làng, `long_dan` và `so_hiep_toi_da`; gợi ý 2 Bộ binh, 1 Kỵ binh, 1 Cung kỵ; làng, sông, rừng)
**Thì** kèm lời giải không mất tướng và không mất Lòng dân trong `tran_04_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng, Lòng dân còn đầy
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được

**Và** trận chỉ giới thiệu một luật mới (làng); nếu Cung kỵ đã bị cắt ở E2 thì thay bằng Bộ binh và viết lại lời giải

### Story 3.9: Kho lương

Là người chơi,
tôi muốn quân Nguyên đứng gần kho lương được hồi máu,
để có lý do ưu tiên đẩy địch ra xa kho.

**Tiêu chí nghiệm thu:**

**Cho** một quân Nguyên bị thương đứng kề ít nhất một kho lương
**Khi** tới bước cuối hiệp
**Thì** quân đó hồi 1 máu, tối đa 1 mỗi hiệp, không vượt máu tối đa (FR31)

**Khi** quân kề hai kho lương
**Thì** vẫn chỉ hồi 1 máu

**Và** kho lương không đi vào được; đẩy quân vào kho lương là va chạm

### Story 3.10: Quân tiếp viện

Là người chơi,
tôi muốn biết trước quân tiếp viện sẽ xuất hiện ở đâu,
để đứng chặn ô đó hoặc chuẩn bị đối phó.

**Tiêu chí nghiệm thu:**

**Cho** file trận có lịch tiếp viện
**Khi** tới bước cuối hiệp
**Thì** các ô tiếp viện của hiệp sau được đánh dấu bằng ký hiệu riêng, khác ô đỏ (FR35)

**Khi** đầu hiệp sau
**Thì** quân tiếp viện xuất hiện trước tiên, rồi báo đòn ngay trong hiệp đó (sau các quân cũ)

**Khi** ô tiếp viện có quân đứng (bất kể phe)
**Thì** quân đứng đó mất 1 máu, quân tiếp viện bị hủy

**Và** có kịch bản trong `tiep_vien/`

### Story 3.11: Nhiệm vụ Giữ ải

Là người chơi,
tôi muốn có kiểu trận phải cầm cự,
để chịu áp lực khác với trận tiêu diệt.

**Tiêu chí nghiệm thu:**

**Cho** trận Giữ ải
**Thì** ô ải được đánh dấu ở mép bàn phía nhà Trần, màn hình hiện số hiệp "2/5"

**Khi** quân Nguyên vào ô ải bằng bất kỳ cách nào (kể cả bị người chơi kéo vào)
**Thì** thua ngay (FR37)

**Khi** qua hết bước cuối hiệp của hiệp 5
**Thì** thắng

**Khi** mọi tướng trên bàn đều gục
**Thì** thua

**Và** Kỵ binh và Bộ binh nhắm ô ải; Cung kỵ vẫn nhắm tướng gần nhất (FR23)

### Story 3.12: Mưu kế Vườn không nhà trống và nút mưu kế

Là người chơi,
tôi muốn tung mưu kế của Trần Hưng Đạo đúng lúc,
để lật thế trận.

**Tiêu chí nghiệm thu:**

**Cho** trận có mưu kế Vườn không nhà trống, đang ở lượt người chơi
**Khi** bấm nút mưu kế (hoặc phím `Q`)
**Thì** mọi kho lương thành đất trống, mọi quân Nguyên mất 1 máu theo thứ tự trong file trận (FR33)
**Và** từ đó đến hết trận, quân Nguyên không hồi máu

**Khi** đã dùng trong trận
**Thì** nút mờ đi, không dùng lại được (FR34)

**Và** dùng mưu kế không tốn hành động của tướng
**Và** dùng mưu kế xóa sạch lịch sử hủy: bấm `Z` ngay sau đó không có tác dụng (FR10); có kịch bản cho ca này
**Và** file trận quy định mưu kế nào được dùng; mưu kế bị khóa thì không hiện nút

### Story 3.13: Mưu kế Sát Thát

Là người chơi,
tôi muốn tăng sức đánh của cả ba tướng trong một lượt,
để kết liễu nhiều địch cùng lúc.

**Tiêu chí nghiệm thu:**

**Cho** trận có Sát Thát, đang ở lượt người chơi
**Khi** bấm nút (hoặc phím `W`)
**Thì** trong lượt người chơi này, đòn có sát thương của tướng được +1 (FR32)

**Khi** quân bị đẩy va chạm, đi qua hầm chông hoặc bị đẩy vào mép bàn
**Thì** sát thương đó không được cộng

**Khi** Trần Khánh Dư kéo
**Thì** vẫn 0 sát thương

**Và** xem trước kết quả đòn hiện đúng số sát thương đã cộng
**Và** sang hiệp sau thì hết hiệu lực

### Story 3.14: Trận 5 (Giữ ải)

Là tác giả,
tôi muốn trận 5 dạy kho lương, Vườn không nhà trống và quân tiếp viện,
để người chơi chịu áp lực Giữ ải lần đầu.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_05.json` (4 quân khởi đầu, +1 mỗi hiệp, kho lương và sông, Giữ ải 5 hiệp, mở Vườn không nhà trống)
**Thì** kèm lời giải không mất tướng trong `tran_05_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** bản mới được deploy lên itch (riêng tư)

## Epic 4: Sáu trận và chơi thử

Tác giả chơi trọn chuỗi 6 trận trên web, có màn hình chính, màn chuyển trận, tự lưu, tua nhanh; rồi gửi link cho 3–5 người thân chơi thử.

### Story 4.1: Màn hình chính

Là người chơi,
tôi muốn có màn hình chính để bắt đầu hoặc chơi tiếp,
để vào game như một game thật.

**Tiêu chí nghiệm thu:**

**Khi** mở game
**Thì** hiện màn hình chính với nút "Chơi mới", bấm vào thì vào trận 1 (FR45)

**Và** nút "Chơi tiếp" làm ở Story 4.3 (cần có file lưu trước)

**Khi** chạy với `?tran=N` và đã bật dev
**Thì** bỏ qua màn hình chính, vào thẳng trận N

### Story 4.2: Chuỗi 6 trận và màn chuyển trận

Là người chơi,
tôi muốn đi qua 6 trận liên tiếp,
để cảm nhận một chiến dịch trọn vẹn.

**Tiêu chí nghiệm thu:**

**Cho** `data/chien_dich.json` liệt kê 6 trận theo thứ tự
**Khi** thắng một trận
**Thì** hiện màn chuyển trận: tên tạm "Trận N", mưu kế vừa mở (nếu có), nút "Tiếp" (FR44)

**Khi** vào trận mới
**Thì** các tướng hồi đầy máu

**Khi** thua
**Thì** có nút "Đánh lại trận này" và "Về menu"

**Và** mưu kế mở dần: Vườn không nhà trống từ trận 5, Sát Thát từ trận 6 (FR34)

### Story 4.3: Tự lưu

Là người chơi,
tôi muốn game tự lưu sau mỗi trận,
để tắt trình duyệt rồi chơi tiếp được.

**Tiêu chí nghiệm thu:**

**Khi** thắng một trận
**Thì** game tự lưu tiến độ vào `user://` (JSON, có trường phiên bản) (FR46)

**Cho** đã có file lưu
**Thì** màn hình chính có thêm nút "Chơi tiếp" (FR45)

**Khi** tải lại trang và bấm "Chơi tiếp"
**Thì** vào đúng trận kế tiếp

**Khi** file lưu hỏng hoặc khác phiên bản
**Thì** game báo nhẹ nhàng và cho chơi mới, không sập; log ghi ERROR

**Và** chạy đúng trong iframe của itch.io

### Story 4.4: Tua nhanh pha địch

Là người chơi,
tôi muốn tua nhanh hoạt ảnh của địch,
để không phải chờ khi đã hiểu chuyện gì sắp xảy ra.

**Tiêu chí nghiệm thu:**

**Khi** bấm nút tua trong pha địch
**Thì** hoạt ảnh chạy nhanh hơn, không bỏ sự kiện nào (FR42)

**Và** tốc độ hoạt ảnh lưu trong `user://settings.cfg`, mở lại game vẫn giữ

### Story 4.5: Trận 6

Là tác giả,
tôi muốn trận 6 tổng hợp mọi luật,
để kết thúc prototype bằng một bài toán khó nhất.

_Cắt được nếu trễ: khi cắt, `chien_dich.json` chỉ còn 5 trận và Sát Thát mở từ trận 5._

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_06.json` (5 quân khởi đầu, +1–2 mỗi hiệp, đủ loại địa hình, Giữ ải, mở Sát Thát)
**Thì** kèm lời giải không mất tướng trong `tran_06_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

### Story 4.6: Tinh chỉnh 6 trận

Là tác giả,
tôi muốn cả 6 trận vẫn giải được sau mỗi lần tôi chỉnh chỉ số,
để cân bằng game mà không phá trận.

**Tiêu chí nghiệm thu:**

**Cho** cả 6 lời giải đã là kịch bản tự động (từ các story trận 2.14, 3.3, 3.6, 3.8, 3.14, 4.5)

**Khi** sửa `chi_so.json` rồi chạy `tools/test.sh`
**Thì** cả 6 lời giải được chạy lại; lời giải nào không còn thắng mà không mất tướng thì báo trượt

**Và** "trận 1–2 thắng được không mất tướng ngay lần đầu" không kiểm ở đây (tác giả đã biết lời giải); chuyển thành mục quan sát trong Story 4.9

**Trau chuốt xem trước kết quả đòn** (FR41, cắt được nếu trễ):
**Khi** rê chuột lên mục tiêu
**Thì** bản xem trước hiện cả chuỗi hệ quả: va chạm, chết đuối, đòn địch dịch theo hoặc bị hủy, đòn địch sẽ trúng đồng đội

### Story 4.7: Kiểm tra hiệu năng và trình duyệt

Là tác giả,
tôi muốn biết game chạy ổn trên máy người thân,
để buổi chơi thử không hỏng vì lỗi kỹ thuật.

**Tiêu chí nghiệm thu:**

**Khi** chơi bản web trên laptop dùng card tích hợp, ở trận 6, hiệp có nhiều quân nhất
**Thì** giữ 60 FPS (NFR1); chế độ dev hiện bộ đếm FPS ở góc màn hình để đo

**Và** bản nén ≤ 25MB, tải ≤ 10 giây ở mạng 20Mbps, đo như Story 0.5 (NFR2)
**Và** mỗi pha địch ra đòn ≤ 3 giây (NFR3)
**Và** chạy đủ trên Chrome, Firefox, Edge (NFR4)
**Và** chơi hết 6 trận không có lỗi kẹt trận (NFR6)
**Và** kết quả đo ghi vào `NEXT-STEPS.md`

### Story 4.8: Gợi ý luật đầu trận

Là người chơi lần đầu,
tôi muốn được nhắc ngắn gọn luật của trận và các phím,
để chơi được mà không cần ai giải thích.

_Đây là phần hướng dẫn của prototype (chốt 2026-10-18): trận 1–2 là trận dạy chơi, luật mới của mỗi trận được giới thiệu bằng gợi ý này. Không cắt._

**Tiêu chí nghiệm thu:**

**Khi** bắt đầu mỗi trận
**Thì** hiện 1–2 dòng gợi ý luật mới của trận đó (ví dụ trận 1: "Ô đỏ là nơi địch sắp đánh. Nguyễn Khoái đẩy được địch xuống sông.")
**Và** bấm vào đâu cũng tắt được gợi ý; bấm nút "?" thì xem lại
**Và** có gợi ý cho trận 3 (ví dụ "Phải hạ hết quân Nguyên trong 4 hiệp.") và trận 4 (ví dụ "Bảo vệ làng: mỗi lần làng bị đánh, Lòng dân giảm 1. Hết Lòng dân là thua.")

**Khi** bấm phím `?` hoặc nút "?"
**Thì** hiện bảng thao tác và phím tắt (theo bảng Controls của GDD)

**Và** mọi chữ gợi ý nằm trong `text.csv`; file trận trỏ tới khóa gợi ý

### Story 4.9: Chơi thử với người thân

Là tác giả,
tôi muốn quan sát 3–5 người thân chơi,
để trả lời câu hỏi "giải thế trận có vui không?".

**Tiêu chí nghiệm thu:**

**Cho** bản web hoàn chỉnh trên itch (link bí mật, vẫn riêng tư)
**Thì** AI chuẩn bị phiếu quan sát theo 5 dấu hiệu trong Success Metrics của GDD

**Khi** tác giả xem từng người chơi
**Thì** đánh dấu các dấu hiệu lên phiếu, không hỏi ý kiến

**Và** phiếu có thêm một mục: người chơi có thắng trận 1–2 mà không mất tướng ngay lần đầu không (theo Difficulty Curve của GDD)
**Và** phiếu có thêm một mục: người chơi có thua vì hết hiệp hoặc mất Lòng dân không, và thua rồi có tự chơi lại không
**Và** ghi nhận xét cho các mục [KIỂM TRA KHI PLAYTEST E4]: tầm kéo Trần Khánh Dư, độ mạnh Vườn không nhà trống, luật tướng gục bị nhấc khỏi bàn
**Và** đạt ≥ 3/5 dấu hiệu thì quyết định chuyển sang giai đoạn 1
