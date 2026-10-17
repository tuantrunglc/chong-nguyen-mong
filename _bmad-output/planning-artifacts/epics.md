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
- FR2: Mỗi trận nạp từ file dữ liệu: địa hình, vị trí quân, thứ tự hành động của quân Nguyên, lịch tiếp viện, kiểu nhiệm vụ, mưu kế được dùng. Thêm hoặc sửa trận không cần sửa code.
- FR3: Hiển thị 5 loại ô (đất trống, sông, rừng, hầm chông, kho lương) và ô ải; quân là đồng tròn có chữ hoặc biểu tượng.
- FR4: Chỉ số (máu, tầm đi, tầm đánh, sát thương, độ đẩy, tầm kéo, tham số mưu kế) nạp từ `chi_so.json`; tác giả tự sửa được.

**Tướng và di chuyển**
- FR5: 3 tướng (Nguyễn Khoái, Phạm Ngũ Lão, Trần Khánh Dư), mỗi tướng 3 máu, đi tối đa 3 ô.
- FR6: Chọn tướng bằng chuột hoặc phím `1` `2` `3`; tô sáng các ô đi tới được; rê chuột lên ô thì hiện đường đi.
- FR7: Được đi xuyên quân mình, không đi xuyên quân địch; sông, rừng, kho lương chặn đường.
- FR8: Game chọn đường **ít hầm chông nhất**, hòa thì theo B→Đ→N→T. Ô sáng và đường đi hiện số máu sẽ mất. [MẶC ĐỊNH]
- FR9: Mỗi tướng đi rồi đánh một lần; có thể đánh mà không đi; đã đánh thì không đi được nữa; ba tướng hành động theo thứ tự tùy ý.
- FR10: Hủy **nước đi gần nhất** (nút Hủy, phím `Z`), chỉ khi tướng đó chưa đánh. [MẶC ĐỊNH]
- FR11: Kết thúc lượt bằng nút hoặc phím `Space`.

**Đòn của tướng**
- FR12: Nguyễn Khoái đánh 1 ô kề, 2 sát thương, rồi đẩy mục tiêu 1 ô theo hướng đánh. Mục tiêu gục vì sát thương thì không bị đẩy.
- FR13: Phạm Ngũ Lão phóng lao thẳng hàng, bay qua ô kề, trúng vật đầu tiên ở ô thứ 2–4, 1 sát thương. Rừng hoặc kho lương ở bất kỳ ô nào trên đường, kể cả ô kề, chặn lao [MẶC ĐỊNH]. Sông không chặn.
- FR14: Trần Khánh Dư kéo vật đầu tiên trên hàng trong vòng 3 ô về phía mình 2 ô, 0 sát thương. Vật đó phải là quân Nguyên; nếu là tướng, rừng hoặc kho lương thì không kéo được [MẶC ĐỊNH]. Mục tiêu đã đứng kề thì không có gì xảy ra.
- FR15: Đánh bằng cách bấm ô hoặc mục tiêu trong tầm. Tướng đã đi rồi thì phải bấm thêm lần nữa để xác nhận.
- FR16: Mọi đòn trúng mọi quân trên ô bị nhắm, không phân phe (kể cả đòn của tướng trúng tướng mình).

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
  - nhắm tướng gần nhất (Giữ ải: Kỵ binh và Bộ binh nhắm ô ải);
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
- FR34: Mỗi mưu kế dùng 1 lần mỗi trận, bất cứ lúc nào trong lượt người chơi, không tốn hành động của tướng. Dùng bằng nút hoặc phím `Q` `W`. Mở theo trận: Vườn không nhà trống từ trận 4, Sát Thát từ trận 5.

**Quân tiếp viện**
- FR35: Cuối hiệp, game báo trước ô tiếp viện của hiệp sau. Đầu hiệp sau, quân tiếp viện xuất hiện trước tiên, rồi báo đòn ngay trong hiệp đó. Nếu ô có quân đứng (bất kể phe nào), quân đứng đó mất 1 máu và quân tiếp viện bị hủy.

**Thắng, thua**
- FR36: Tiêu diệt: thắng khi hạ hết quân Nguyên; thua khi cả 3 tướng gục.
- FR37: Giữ ải: thắng khi hết bước cuối hiệp của hiệp 5; thua khi cả 3 tướng gục, hoặc khi quân Nguyên vào ô ải bằng bất kỳ cách nào [MẶC ĐỊNH].
- FR38: Kiểm tra thắng/thua sau mỗi lần có quân gục; thắng và thua xảy ra cùng lúc thì thắng được ưu tiên [MẶC ĐỊNH]. Tướng gục bị nhấc khỏi bàn [MẶC ĐỊNH, KIỂM TRA KHI PLAYTEST E4].

**Hoàn tác và thông tin**
- FR39: Chơi lại hiệp (nút hoặc phím `R`), 1 lần mỗi trận, đưa bàn về đầu lượt người chơi.
- FR40: Rê chuột lên quân hiện máu, đòn sắp đánh, thứ tự ra đòn; rê lên ô hiện loại địa hình.
- FR41: Xem trước kết quả đòn: rê lên mục tiêu thì hiện bóng mờ vị trí cuối và số máu sau đòn (E2 bản tối giản, E4 trau chuốt).
- FR42: Tua nhanh hoạt ảnh pha địch.

**Chiến dịch và lưu game**
- FR43: Chuỗi 5 trận cố định theo bảng Campaign Structure; mỗi trận có ít nhất một cách thắng không mất tướng.
- FR44: Màn hình chuyển trận; tướng hồi đầy máu giữa các trận.
- FR45: Màn hình chính: chơi tiếp (nếu có file lưu) hoặc chơi mới.
- FR46: Tự lưu trong trình duyệt sau mỗi trận; mở lại thì chơi tiếp được.

### Yêu cầu phi chức năng (NFR)

- NFR1: 60 FPS ổn định trên trình duyệt desktop, trên laptop văn phòng có card đồ họa tích hợp.
- NFR2: Bản build ≤ 50MB; tải ≤ 10 giây ở mạng 20Mbps (bản nén ≤ 25MB).
- NFR3: Hoạt ảnh mỗi pha địch ra đòn ≤ 3 giây.
- NFR4: Chạy trên Chrome, Firefox, Edge bản desktop mới nhất. Safari và điện thoại không bắt buộc.
- NFR5: Combat tất định: không ngẫu nhiên, cùng thao tác thì cùng kết quả.
- NFR6: Không có lỗi làm kẹt trận trong cả 5 trận.
- NFR7: Toàn bộ chữ tiếng Việt, tách ra file dịch.
- NFR8: Mọi thao tác làm được bằng bấm chuột, không có kéo thả.
- NFR9: Ô đỏ báo đòn là thứ nổi bật nhất trên màn hình; số thứ tự ra đòn lớn, dễ đọc.

### Yêu cầu bổ sung (từ kiến trúc)

- **Không dùng starter template.** Story đầu tiên tạo project Godot 4.7.2 trống trong `game/`, renderer Compatibility, 1280×720 `canvas_items`, cảnh báo `untyped_declaration` ở mức error.
- **Test:** cài GUT v9.7.1. `tools/test.sh` là một lệnh duy nhất: kiểm tra ranh giới, khóa `da_duyet`, chạy GUT `--headless`, in tóm tắt tiếng Việt.
- **Kịch bản luật** (`tests/kich_ban/`) là spec. Mỗi story luật có một đợt duyệt nhỏ bằng `tools/xem_kich_ban.sh`.
- **Ranh giới:** `tools/check_boundaries.sh` kiểm tra `src/core` cấm Node, cấm I/O, cấm ngẫu nhiên; chỉ `Effects` được sửa máu và vị trí.
- **Lõi luật:** `BattleState` thuần dữ liệu có `clone()` và `validate()`; `Rules.resolve` trả về danh sách sự kiện; `BattleController` giữ trạng thái và ngăn xếp bản chụp; `EventPlayer` phát lại sự kiện.
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

Không có tài liệu UX riêng. Các yêu cầu giao diện lấy từ GDD (Controls and Input, Art Style) và đã nằm trong FR6, FR11, FR15, FR24, FR34, FR39–FR42, NFR8–NFR9.

### Bản đồ phủ FR

| FR | Epic | Nội dung |
|---|---|---|
| FR1–FR4 | E1 | Bàn cờ, nạp trận, hiển thị ô và quân, `chi_so.json` |
| FR5–FR7 | E1 | Tướng, chọn tướng, tô sáng, đi xuyên quân mình |
| FR8 | E3 | Đường đi ít hầm chông nhất |
| FR9–FR11 | E1 | Đi rồi đánh, hủy nước đi gần nhất, kết thúc lượt |
| FR12–FR16 | E2 | Đòn 3 tướng, xác nhận đòn, trúng mọi phe (phần rừng/kho lương chặn đòn: E3) |
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
| FR40–FR41 | E2 | Rê chuột xem thông tin, xem trước kết quả đòn |
| FR42 | E4 | Tua nhanh |
| FR43 | E1–E4 | Trận 1 (E1 bố cục, E2 hoàn thiện), trận 2–4 (E3), trận 5 và tinh chỉnh (E4) |
| FR44–FR46 | E4 | Màn chuyển trận, màn hình chính, tự lưu |
| NFR1–NFR4 | E0 (đo lần đầu), E4 (đo đủ) | Hiệu năng, dung lượng, trình duyệt |
| NFR5–NFR9 | Mọi epic | Tất định, không kẹt, tiếng Việt, chỉ bấm chuột, ô đỏ nổi bật |

## Danh sách epic

Thứ tự bắt buộc: E0 → E1 → E2 → E3 → E4. Epic sau dùng kết quả của epic trước, không epic nào cần epic sau mới chạy được. Mỗi story luật có một đợt duyệt kịch bản nhỏ bằng `tools/xem_kich_ban.sh`, trước khi viết code.

### E0: Dựng nền
Tác giả mở link itch.io (riêng tư) và thấy bàn cờ 7×7 trống. Gõ `tools/test.sh` thì thấy kết quả tiếng Việt.
**Phủ:** các yêu cầu bổ sung từ kiến trúc (project, GUT, `tools/`, ranh giới, MCP, `Log`, cờ dev, hiển thị phiên bản, bản địa hóa, font, build và deploy); NFR2, NFR4 (đo lần đầu).

### E1: Bàn cờ và di chuyển
Tác giả mở trận 1 từ file dữ liệu, chọn tướng, đi, hủy nước đi, kết thúc lượt; tự sửa file trận rồi bấm F5 thì thấy thay đổi.
**Phủ:** FR1–FR7, FR9–FR11, FR43 (bố cục trận 1). Công cụ dev F1, F5, `?tran=N`.

### E2: Combat cốt lõi ⚠️ rủi ro cao nhất
Tác giả chơi trọn trận 1: địch báo đòn, đẩy địch xuống sông, kéo địch vào ô đỏ, thắng hoặc thua, thấy trước kết quả đòn.
**Thứ tự trong epic:** luật (kịch bản xanh) → **mốc "bản xấu chơi được"** (chưa có hoạt ảnh) → hoạt ảnh và xem trước → hoàn thiện trận 1, có lời giải ghi lại → **Cung kỵ (story cuối, cắt được)**. Kết thúc bằng mốc tự chơi cuối tuần 8.
**Phủ:** FR12–FR26, FR28, FR36, FR38, FR40, FR41, FR43 (hoàn thiện trận 1). Công cụ dev F2, F3.

### E3: Địa hình và mưu kế
Tác giả chơi được trận 2, 3 và 4 (Giữ ải), với rừng, hầm chông, kho lương, quân tiếp viện, 2 mưu kế và chơi lại hiệp.
**Phủ:** FR8, FR27, FR29–FR35, FR37, FR39, FR43 (trận 2–4, mỗi trận có lời giải ghi lại).

### E4: Năm trận và chơi thử
Tác giả chơi trọn chuỗi 5 trận trên web, có màn hình chính, màn chuyển trận, tự lưu, tua nhanh; rồi gửi link cho 3–5 người thân chơi thử.
**Phủ:** FR42, FR43 (trận 5, tinh chỉnh cả 5 trận), FR44–FR46; NFR1–NFR3 đo đủ trên 3 trình duyệt.

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

**Và** dung lượng tải và thời gian tải lần đầu được ghi vào `NEXT-STEPS.md` (số đo NFR2 ban đầu)
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

Tác giả mở trận 1 từ file dữ liệu, chọn tướng, đi, hủy nước đi, kết thúc lượt; tự sửa file trận rồi bấm F5 thì thấy thay đổi.

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

**Cho** `tran_01.json` bản đầu (sông, 3 tướng, 3 Bộ binh, nhiệm vụ Tiêu diệt)
**Khi** mở `--tran=1`
**Thì** bàn 7×7 hiện đúng từng ô địa hình và từng quân ở đúng vị trí trong file (FR1, FR3)
**Và** mỗi loại ô có màu hoặc ký hiệu riêng (đất trống, sông, rừng, hầm chông, kho lương, ô ải); mỗi quân là đồng tròn có chữ: Khoái, Lão, Dư; quân Nguyên là B, K, C

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
**Thì** đổi sang tướng tương ứng

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
**Thì** số hiệp tăng thêm 1 và cả 3 tướng đi lại được (pha địch chèn vào đây ở E2) (FR11)

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

## Epic 2: Combat cốt lõi ⚠️

Tác giả chơi trọn trận 1: địch báo đòn, đẩy địch xuống sông, kéo địch vào ô đỏ, thắng hoặc thua, thấy trước kết quả đòn.

**Quy trình chung cho mọi story luật (2.1–2.7, 2.13):** AI viết kịch bản → tác giả duyệt bằng `tools/xem_kich_ban.sh` → kịch bản mới phải trượt → AI viết code tới khi `tools/test.sh` xanh. Phần 1 chưa có hoạt ảnh: bàn nhảy thẳng tới kết quả.

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

**Khi** ô bị Nguyễn Khoái đánh có tướng nhà Trần
**Thì** tướng đó cũng mất máu và bị đẩy (FR16)

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

### Story 2.5: Máu, gục, thắng và thua (Tiêu diệt)

Là người chơi,
tôi muốn thấy rõ máu từng quân và biết khi nào thắng, thua,
để biết mình đang đứng ở đâu trong trận.

**Tiêu chí nghiệm thu:**

**Cho** trận 1 đang chơi
**Thì** mỗi đồng quân hiện số máu hiện tại

**Khi** một quân còn 0 máu
**Thì** quân đó bị nhấc khỏi bàn (FR38)

**Khi** quân Nguyên cuối cùng gục
**Thì** hiện "Thắng" ngay lập tức (FR36)

**Khi** cả 3 tướng gục
**Thì** hiện "Thua"

**Khi** quân Nguyên cuối cùng và tướng cuối cùng gục trong cùng một đòn
**Thì** tính là thắng

**Và** kiểm tra thắng/thua sau mỗi lần có quân gục, cả trong lượt người chơi lẫn trong pha địch

### Story 2.6: Địch chuẩn bị: AI và báo đòn

Là người chơi,
tôi muốn thấy trước quân Nguyên sẽ đánh ô nào và theo thứ tự nào,
để tính trước được nước đi.

**Tiêu chí nghiệm thu:**

**Cho** đầu hiệp
**Khi** pha địch chuẩn bị chạy
**Thì** từng quân Nguyên (theo thứ tự trong file trận) đi rồi báo đòn (FR22, FR23)
**Và** ô bị nhắm tô đỏ; Kỵ binh có mũi tên chỉ hướng; mỗi đòn có số thứ tự lớn trên bàn (FR24)

**Khi** hai lựa chọn hòa điểm
**Thì** AI chọn theo thứ tự hướng B→Đ→N→T

**Khi** bật dev và bấm F3
**Thì** mỗi quân Nguyên hiện đang nhắm ai, chọn ô nào, vì sao

**Và** Bộ binh (3 máu, đi 2, chém 1 ô kề) và Kỵ binh (2 máu, đi 3, xung phong thẳng hàng) đúng chỉ số trong `chi_so.json` (FR18, FR19)
**Và** có kịch bản trong `ai/` và `don_dich/`

### Story 2.7: Địch ra đòn và đòn dịch theo

Là người chơi,
tôi muốn đòn địch đánh đúng như đã báo, và dịch theo khi tôi đẩy quân địch,
để làm lệch đòn của chúng vào nhau.

**Tiêu chí nghiệm thu:**

**Cho** các đòn đã báo
**Khi** bấm Kết thúc lượt
**Thì** các đòn đánh lần lượt theo đúng số thứ tự; đòn địch chỉ gây sát thương, không đẩy (FR21, FR26)

**Khi** người chơi đẩy hoặc kéo một quân đã báo đòn
**Thì** ô đỏ của nó dịch theo, giữ nguyên hướng và khoảng cách (FR25)

**Khi** đòn dịch ra ngoài bàn
**Thì** đòn bị hủy, ô đỏ biến mất

**Khi** chủ đòn gục trước lượt ra đòn của mình
**Thì** đòn bị hủy

**Khi** quân Nguyên đứng trong ô đỏ của đồng đội
**Thì** nó ăn đòn

**Khi** Kỵ binh xung phong vào hàng trống tới mép
**Thì** đòn trượt

**Và** `test_determinism.gd` chạy mỗi kịch bản hai lần, kết quả giống hệt (NFR5)

> 🎯 **Mốc "bản xấu chơi được":** sau Story 2.7, tác giả chơi được trận 1 từ đầu đến cuối (chưa có hoạt ảnh). Tác giả tự chơi, báo lỗi luật, rồi mới sang Phần 2.

### Story 2.8: Rê chuột xem thông tin

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

### Story 2.9: Hoạt ảnh phát lại sự kiện

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

**Và** ô đỏ và số thứ tự là thứ nổi bật nhất trên màn hình (NFR9)
**Và** hoạt ảnh chỉ đọc sự kiện và bản chụp, không sửa trạng thái

### Story 2.10: Xem trước kết quả đòn

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

### Story 2.11: F2 sao chép báo lỗi

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

### Story 2.12: Hoàn thiện trận 1 và mốc tuần 8

Là tác giả,
tôi muốn trận 1 đã có lời giải được kiểm chứng,
để biết trận này giải được và dạy đúng luật.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất bố cục cuối của trận 1 (dạy né ô đỏ và đẩy xuống sông)
**Thì** kèm theo một lời giải không mất tướng, ghi theo từng hiệp vào `data/tran/tran_01_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải đó
**Thì** thắng và không mất tướng nào
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** bản mới được deploy lên itch (riêng tư)
**Và** mốc tự chơi cuối tuần 8: nếu tác giả thấy chán thì sửa luật trước khi sang E3

### Story 2.13: Cung kỵ (cắt được nếu trễ)

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
**Và** tắt Cung kỵ bằng một cờ trong dữ liệu thì trận 1 vẫn chạy bình thường
**Và** phần "rừng, kho lương chặn tên" làm ở E3

## Epic 3: Địa hình và mưu kế

Tác giả chơi được trận 2, 3 và 4 (Giữ ải), với rừng, hầm chông, kho lương, quân tiếp viện, 2 mưu kế và chơi lại hiệp. Quy trình kịch bản luật như E2.

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

**Khi** quân bị đẩy vào rừng
**Thì** tính là va chạm: mất 1 máu, đứng yên (FR29)

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

**Khi** đã chơi lại hiệp rồi bấm Hủy (`Z`)
**Thì** không quay về được nước đi nào trước lúc chơi lại; ngăn xếp hủy nước đi đã bị xóa sạch

### Story 3.3: Trận 2

Là tác giả,
tôi muốn trận 2 dạy dùng rừng chặn Kỵ binh và cho địch đánh trúng nhau,
để người chơi học luật mới từng bước.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_02.json` (2 Kỵ binh, 1 Bộ binh, rừng và sông, Tiêu diệt)
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

### Story 3.5: Trận 3

Là tác giả,
tôi muốn trận 3 dạy đòn kéo và hầm chông,
để người chơi kéo địch vào bẫy.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_03.json` (2 Bộ binh, 2 Cung kỵ, hầm chông và rừng, Tiêu diệt)
**Thì** kèm lời giải không mất tướng trong `tran_03_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** nếu Cung kỵ đã bị cắt ở E2 thì thay bằng Bộ binh và viết lại lời giải

### Story 3.6: Kho lương

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

### Story 3.7: Quân tiếp viện

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

### Story 3.8: Nhiệm vụ Giữ ải

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

**Khi** cả 3 tướng gục
**Thì** thua

**Và** Kỵ binh và Bộ binh nhắm ô ải; Cung kỵ vẫn nhắm tướng gần nhất (FR23)

### Story 3.9: Mưu kế Vườn không nhà trống và nút mưu kế

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
**Và** file trận quy định mưu kế nào được dùng; mưu kế bị khóa thì không hiện nút

### Story 3.10: Mưu kế Sát Thát

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

### Story 3.11: Trận 4 (Giữ ải)

Là tác giả,
tôi muốn trận 4 dạy kho lương, Vườn không nhà trống và quân tiếp viện,
để người chơi chịu áp lực Giữ ải lần đầu.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_04.json` (4 quân khởi đầu, +1 mỗi hiệp, kho lương và sông, Giữ ải 5 hiệp, mở Vườn không nhà trống)
**Thì** kèm lời giải không mất tướng trong `tran_04_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

**Và** bản mới được deploy lên itch (riêng tư)

## Epic 4: Năm trận và chơi thử

Tác giả chơi trọn chuỗi 5 trận trên web, có màn hình chính, màn chuyển trận, tự lưu, tua nhanh; rồi gửi link cho 3–5 người thân chơi thử.

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

### Story 4.2: Chuỗi 5 trận và màn chuyển trận

Là người chơi,
tôi muốn đi qua 5 trận liên tiếp,
để cảm nhận một chiến dịch trọn vẹn.

**Tiêu chí nghiệm thu:**

**Cho** `data/chien_dich.json` liệt kê 5 trận theo thứ tự
**Khi** thắng một trận
**Thì** hiện màn chuyển trận: tên tạm "Trận N", mưu kế vừa mở (nếu có), nút "Tiếp" (FR44)

**Khi** vào trận mới
**Thì** các tướng hồi đầy máu

**Khi** thua
**Thì** có nút "Đánh lại trận này" và "Về menu"

**Và** mưu kế mở dần: Vườn không nhà trống từ trận 4, Sát Thát từ trận 5 (FR34)

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

### Story 4.5: Trận 5

Là tác giả,
tôi muốn trận 5 tổng hợp mọi luật,
để kết thúc prototype bằng một bài toán khó nhất.

**Tiêu chí nghiệm thu:**

**Cho** AI đề xuất `tran_05.json` (5 quân khởi đầu, +1–2 mỗi hiệp, đủ loại địa hình, Giữ ải, mở Sát Thát)
**Thì** kèm lời giải không mất tướng trong `tran_05_loi_giai.md` (FR43)

**Khi** tác giả đánh lại đúng lời giải
**Thì** thắng, không mất tướng
**Và** lời giải được chuyển ngay thành kịch bản tự động trong `tests/kich_ban/tran/`; từ đó mỗi lần chạy `tools/test.sh` đều kiểm tra trận này còn giải được không mất tướng

### Story 4.6: Tinh chỉnh 5 trận

Là tác giả,
tôi muốn cả 5 trận vẫn giải được sau mỗi lần tôi chỉnh chỉ số,
để cân bằng game mà không phá trận.

**Tiêu chí nghiệm thu:**

**Cho** cả 5 lời giải đã là kịch bản tự động (từ các story trận 2.12, 3.3, 3.5, 3.11, 4.5)

**Khi** sửa `chi_so.json` rồi chạy `tools/test.sh`
**Thì** cả 5 lời giải được chạy lại; lời giải nào không còn thắng mà không mất tướng thì báo trượt

**Khi** tác giả chơi lại cả 5 trận từ đầu theo thứ tự
**Thì** trận 1–3 thắng được mà không mất tướng ngay lần đầu nếu đọc kỹ ô đỏ

### Story 4.7: Kiểm tra hiệu năng và trình duyệt

Là tác giả,
tôi muốn biết game chạy ổn trên máy người thân,
để buổi chơi thử không hỏng vì lỗi kỹ thuật.

**Tiêu chí nghiệm thu:**

**Khi** chơi bản web trên laptop dùng card tích hợp
**Thì** giữ 60 FPS trong suốt một trận (NFR1)

**Và** bản nén ≤ 25MB, tải ≤ 10 giây ở mạng 20Mbps (NFR2)
**Và** mỗi pha địch ra đòn ≤ 3 giây (NFR3)
**Và** chạy đủ trên Chrome, Firefox, Edge (NFR4)
**Và** chơi hết 5 trận không có lỗi kẹt trận (NFR6)
**Và** kết quả đo ghi vào `NEXT-STEPS.md`

### Story 4.8: Gợi ý luật đầu trận

Là người chơi lần đầu,
tôi muốn được nhắc ngắn gọn luật của trận và các phím,
để chơi được mà không cần ai giải thích.

**Tiêu chí nghiệm thu:**

**Khi** bắt đầu mỗi trận
**Thì** hiện 1–2 dòng gợi ý luật mới của trận đó (ví dụ trận 1: "Ô đỏ là nơi địch sắp đánh. Nguyễn Khoái đẩy được địch xuống sông.")
**Và** bấm vào đâu cũng tắt được gợi ý; bấm nút "?" thì xem lại

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

**Và** ghi nhận xét cho các mục [KIỂM TRA KHI PLAYTEST E4]: tầm kéo Trần Khánh Dư, độ mạnh Vườn không nhà trống, luật tướng gục bị nhấc khỏi bàn
**Và** đạt ≥ 3/5 dấu hiệu thì quyết định chuyển sang giai đoạn 1
