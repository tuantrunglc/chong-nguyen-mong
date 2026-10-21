---
title: 'Kiến trúc game'
project: 'GameTest (Chống Nguyên Mông, tên tạm)'
date: '2026-10-16'
author: 'Trung.nguyen11'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Godot 4.7.2.stable (GDScript)'
platform: 'Web HTML5 (itch.io); giai đoạn 2: Windows/Steam'
language: 'vi'

# Tài liệu nguồn
gdd: '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md'
epics: '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/epics.md'
brief: '_bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/brief.md'
supporting:
  - '_bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/addendum.md'
  - '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/decision-log.md'
  - '_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/history-notes-1288.md'
narrative: null
---

# Kiến trúc game

## Tóm tắt

**Chống Nguyên Mông (tên tạm)** dùng **Godot 4.7.2** (chỉ GDScript, renderer Compatibility). Bản đầu là **web đơn luồng trên itch.io**; bản Windows/Steam làm ở giai đoạn 2.

**Quyết định then chốt:**
- **Luật chỉ nằm ở một chỗ:** `BattleState` là dữ liệu thuần. `Rules.resolve` nhận lệnh rồi trả về danh sách sự kiện. Phần hiển thị chỉ phát lại các sự kiện đó. Hoàn tác, xem trước kết quả đòn, tua nhanh và test đều dựa trên cơ chế này.
- **Kịch bản luật là spec:** kịch bản là các bàn cờ chữ trước/sau. AI viết, tác giả duyệt trên terminal. Kịch bản đã duyệt thì bị khóa. Code phải làm cho kịch bản đạt, không được sửa kịch bản để khớp với code.
- **Dữ liệu tách khỏi code:** trận và chỉ số nằm trong file JSON. Tác giả tự sửa và tự cân bằng mà không cần đụng code.

**Cấu trúc:** tổ chức theo tầng (`core` / `data` / `battle` / `ui` / `app` / `debug`); có 19 hệ thống cốt lõi. `tools/check_boundaries.sh` tự kiểm tra ranh giới giữa các tầng.

**Mẫu triển khai:** 3 mẫu riêng của dự án và 6 mẫu chuẩn, để mọi phiên AI viết code giống nhau.

**Sẵn sàng cho:** chia epic và bắt đầu E0 "Dựng nền".

## Trạng thái tài liệu

Tài liệu đã hoàn tất qua GDS Architecture Workflow. Đây là luật bắt buộc cho mọi phiên AI.

**Đã xong:** 9/9 bước. Hoàn tất ngày 2026-10-16.

---

## Bối cảnh dự án

### Tổng quan game

**Chống Nguyên Mông (tên tạm)**: tactics roguelite 2D theo lượt. Người chơi là Trần Hưng Đạo, đứng ngoài bàn cờ, chỉ huy 2–3 tướng có thật trên bàn có cỡ riêng cho từng trận, từ 5×5 đến 10×8 (file trận quy định cỡ bàn và tướng nào ra trận). Địch luôn báo trước đòn đánh vào ô. Người chơi dùng đẩy/kéo, va chạm, địa hình và mưu kế để phá thế trận. Combat hoàn toàn tất định.

### Phạm vi kỹ thuật

- **Nền tảng:** Web HTML5 trên desktop (Chrome, Firefox, Edge), phát hành trên itch.io. Giai đoạn 2 thêm PC Windows/Steam. Safari và điện thoại không bắt buộc. Mọi thao tác đều là bấm, để sau này làm cảm ứng được.
- **Engine:** Godot 4.7.2.stable (chi tiết ở phần Engine và framework).
- **Thể loại:** turn-based tactics (lõi) + roguelite (khung, làm ở giai đoạn 1).
- **Mô hình phát triển:** một người, khoảng 10 giờ/tuần. **Code do AI viết.** Tác giả là người quyết định spec (luật chơi) và người test. Tác giả không đọc và không review code.
- **Quy mô:** prototype khoảng 140 giờ (E0–E4). Đã chia lại 2026-10-17: E0 Dựng nền ~12, E1 ~18, E2 ~35, E3 ~35, E4 ~30. Ngày 2026-10-18 E3 tăng lên ~45 (giới hạn hiệp, làng, trận 4 mới).
- **Mạng:** không có. Không multiplayer, không backend.

### Các hệ thống cốt lõi

| # | Hệ thống | Độ phức tạp | Tham chiếu GDD | Epic |
|---|---|---|---|---|
| 1 | Trạng thái trận (dữ liệu thuần, sao chép được: lưới, quân, máu, đòn đã báo, cờ mưu kế) | Cao | Action Economy, Grid System | E1–E2 |
| 2 | Bộ phân giải luật: đánh vào ô, đẩy/kéo, va chạm, đòn dịch theo, trúng mọi phe, hủy đòn của quân bị hạ | Cao | Action Economy, Terrain | E2 |
| 3 | Nhật ký sự kiện: bộ phân giải trả về danh sách sự kiện, phần trình bày phát lại. Tua nhanh, test và chơi lại dùng chung danh sách này | Trung bình | (kiến trúc) | E2 |
| 4 | Trình tự hiệp: máy trạng thái 4 pha (chuẩn bị → người chơi → địch ra đòn → cuối hiệp) | Trung bình | Action Economy | E2–E3 |
| 5 | Enemy AI tất định: BFS theo số bước, chọn ô đứng, hòa điểm theo B→Đ→N→T, thứ tự lấy từ dữ liệu trận; trận có làng thì mục tiêu gồm tướng và làng | Trung bình | Enemy AI | E2 |
| 6 | Báo trước đòn: ô đỏ, số thứ tự, mũi tên xung phong; đòn gắn với ô hoặc với hướng | Trung bình | Primary Mechanics | E2 |
| 7 | Xem trước kết quả đòn của tướng: chạy bộ phân giải trên bản sao **đã chốt: có từ E2, bản tối giản** (ADR-005) | Thấp–TB | (cần bổ sung vào GDD) | E2 |
| 8 | Địa hình và hiệu ứng: sông, rừng, hầm chông, kho lương, ô ải, làng (Lòng dân) | Trung bình | Terrain | E2–E3 |
| 9 | Mưu kế: Sát Thát, Vườn không nhà trống; 1 lần mỗi trận, mở dần theo trận | Thấp–TB | Primary Mechanics | E3–E4 |
| 10 | Quân tiếp viện: báo trước; bị chặn ô thì người đứng chặn mất 1 máu | Trung bình | Action Economy | E3 |
| 11 | Hoàn tác và chơi lại hiệp: chụp và khôi phục trạng thái | Trung bình | Action Economy | E1, E3 |
| 12 | Dữ liệu trận: bố cục, quân, thứ tự hành động, lịch tiếp viện, kiểu nhiệm vụ, số hiệp tối đa, Lòng dân. Sửa trận không cần code | Trung bình | Level Design Framework | E1, E4 |
| 13 | Trình bày và hoạt ảnh: phát lại sự kiện; mỗi pha địch ≤ 3 giây; có tua nhanh | Trung bình | Performance, E4 | E2, E4 |
| 14 | Input và HUD: bấm/rê chuột, phím tắt 1-2-3, Q/W, Z, Space, R; tooltip | Trung bình | Controls and Input | E1–E2 |
| 15 | Kịch bản luật dạng bàn cờ chữ (trước → hành động → sau). Tác giả đọc và duyệt được; test tự động chạy chính các file này bằng một lệnh, in kết quả tiếng Việt | Trung bình | (kiến trúc) | E1 trở đi |
| 16 | Công cụ dev cho tester: mở thẳng trận N, nạp lại file trận, overlay tọa độ ô | Thấp | (kiến trúc) | E1 |
| 17 | Chuỗi chiến dịch: 6 trận, màn chuyển trận, hồi máu giữa các trận | Thấp | Campaign Structure | E4 |
| 18 | Lưu game cục bộ trong trình duyệt, tự lưu sau mỗi trận | Thấp | Platform-Specific | E4 |
| 19 | Bản địa hóa: mọi chữ để trong file riêng; tiếng Việt trước, tiếng Anh ở giai đoạn 2 | Thấp | Platform-Specific | E1 trở đi |

**Giai đoạn 1.** Kiến trúc không được chặn các phần này, nhưng prototype cũng không làm sẵn:
- bản đồ nút roguelite sinh theo seed;
- phần thưởng chọn 1 trong 3;
- nâng cấp tướng (đổi chỉ số và luật đòn);
- mở khóa giữa các lượt chơi;
- trận Bạch Đằng (thủy triều làm địa hình đổi theo hiệp, bãi cọc, thuyền);
- tranh, nhạc, chữ kể chuyện.

### Yêu cầu kỹ thuật

- **Hiệu năng:** 60 FPS ổn định trên trình duyệt desktop, đo trên laptop văn phòng có card đồ họa tích hợp.
- **Dung lượng:** bản build ≤ 50MB.
- **Thời gian tải:** ≤ 10 giây ở mạng 20Mbps. Như vậy lượng tải thực tế phải dưới khoảng 25MB, nên cần nén.
- **Nhịp hoạt ảnh:** mỗi pha địch ra đòn ≤ 3 giây, có nút tua nhanh.
- **Tính tất định:** combat không dùng số ngẫu nhiên, thứ tự duyệt cố định. Giai đoạn 1: mọi phần ngẫu nhiên đi qua một bộ sinh số có seed.
- **Kiểm chứng:** bộ phân giải luật có test tự động chạy không cần màn hình, dựa trên kịch bản luật. UI và hoạt ảnh không có test tự động; tác giả test bằng tay.
- **Lưu trữ:** lưu cục bộ trong trình duyệt, không có server.
- **Độ phân giải:** 1280×720, stretch `canvas_items` (quyết định #13).
- **Chất lượng:** không có lỗi làm kẹt trận trong cả 6 trận.

### Ràng buộc thiết kế

- Luật combat chỉ nằm ở **một chỗ**: trạng thái trận và bộ phân giải. Node, Scene và hoạt ảnh không chứa luật.
- Không dùng ECS, không tự làm framework, giữ ít tầng nhất có thể.
- Tài liệu kiến trúc này là **luật bắt buộc cho mọi phiên AI**.

### Các yếu tố tạo độ phức tạp

**Cao:**
- **Phân giải luật theo chuỗi:** đẩy → va chạm → rơi xuống sông hoặc hầm chông → đòn dịch theo → hủy đòn của quân bị hạ. Thứ tự áp dụng phải rõ ràng và tất định.
- **Tách luật khỏi hiển thị:** là điều kiện bắt buộc cho hoàn tác, chơi lại hiệp, tua nhanh, xem trước kết quả và test.

**Mới (không có mẫu chuẩn trong Godot):**
- Đòn "đánh vào ô": gắn với ô (hoặc với hướng, ở Kỵ binh), dịch theo khi quân bị đẩy, trúng mọi phe.
- Quân tiếp viện bị chặn ô thì gây sát thương cho người đứng chặn.
- Mưu kế đổi luật giữa trận.

**Trung bình:**
- Enemy AI tất định, "ngây thơ" có chủ ý, người chơi đoán trước được.
- Dữ liệu trận phải biểu diễn được hai kiểu nhiệm vụ và lịch tiếp viện, và mở rộng được cho thủy triều.

### Rủi ro kỹ thuật

1. **Nhiều phiên AI làm lệch kiến trúc.** Mỗi phiên có thể tự xây theo kiểu riêng, ví dụ nhét luật vào Node, và tác giả không đọc code nên không thấy. *Cách giảm:* tài liệu kiến trúc là luật bắt buộc; luật chỉ ở một chỗ; chạy test sau mỗi lần sửa.
2. **AI lẫn API Godot 3 với Godot 4** (ví dụ `yield` thay cho `await`). *Cách giảm:* chốt phiên bản Godot, cấm cú pháp cũ.
3. **GDD còn khe hở về thứ tự phân giải.** Các ca đã thấy: kéo xuyên qua hầm chông; đẩy quân vào ô sắp có tiếp viện; Kỵ binh bị kéo sang hàng khác, sát mép bàn. Đây là **quyết định spec của tác giả**. Chốt ở bước Patterns bằng một bảng thứ tự phân giải và các kịch bản luật; có thể phải bổ sung vào GDD.
4. **E2 rủi ro cao nhất:** luật sai hoặc không tất định thì trụ cột "Thấy trước, tính được" sụp đổ.
5. **Xuất bản web:**
   - dung lượng và thời gian tải;
   - dùng renderer Compatibility;
   - nên xuất đơn luồng để tránh yêu cầu SharedArrayBuffer và header trên itch.io;
   - chỉ dùng GDScript (C# không xuất được web; đã xác nhận ở bước 3);
   - trình duyệt chặn âm thanh tự phát;
   - lưu trữ cục bộ khi game chạy trong iframe của itch.io.
6. **Phạm vi phình ra:** giai đoạn 1 chỉ được "chừa chỗ", không làm sẵn.

---

## Engine và framework

### Engine đã chọn

**Godot 4.7.2.stable**: bản standard, chỉ dùng GDScript, không dùng bản .NET.

**Lý do:**
- GDD đã chốt Godot. Engine miễn phí, giấy phép MIT, xuất được bản web và bản PC.
- 4.7.2 là bản stable mới nhất (ra ngày 18/08/2026).
- Từ Godot 4.3, xuất web đơn luồng là mặc định, hợp với itch.io.
- C# không xuất được bản web, nên dự án **chỉ dùng GDScript**.

**Ghim phiên bản:**
- Mọi phiên AI và mọi bản build đều dùng đúng `4.7.2.stable`.
- Chỉ nâng lên bản 4.7.x mới hơn khi tác giả đồng ý và toàn bộ test luật vẫn đạt.

**Lối thoát:** nếu trong E0 xảy ra một trong hai việc sau thì lùi về **Godot 4.6.3**. Tác giả là người quyết.
- AI liên tục viết sai API của 4.7.
- GUT chạy trên 4.7 không ổn định.

**Phương án đã loại: Phaser/TypeScript.** Lý do loại:
- GDD đã chốt Godot.
- Lên Steam bằng Godot dễ hơn.
- Godot có sẵn editor, công cụ debug và hệ thống bản địa hóa.

Rủi ro chính của Godot với cách làm vibe code là AI sửa file `.tscn` kém. Rủi ro này được xử lý bằng luật "scene nhỏ và phẳng" ở dưới. **Các phiên AI không được đề xuất đổi engine.**

### Khởi tạo dự án

- **Không dùng starter template.** Các template hiện có (Grid Tactics Foundation, EZ-Chess, hướng dẫn của GDQuest) đặt logic trong Node hoặc TileMap, trái với ràng buộc "luật chỉ nằm ở một chỗ".
- Tạo project trống bằng Godot 4.7.2, chọn renderer **Compatibility**. Cấu trúc thư mục chốt ở bước 6.

**Luật cho AI: scene nhỏ và phẳng**
- Mỗi file `.tscn` chỉ là bộ khung vài node.
- Ô, quân, ô đỏ và các thành phần lặp lại khác được **sinh bằng code**.
- Kết nối signal viết trong code, không viết trong file scene.
- Phần lớn dự án là file `.gd`.
- Giả định tác giả **không mở Godot editor**, nên không công việc nào được phụ thuộc vào thao tác tay trong editor.

**Việc đầu tiên của E0: thử ống dẫn web**
1. Xuất bản web của project rỗng.
2. Đưa lên itch.io (chế độ riêng tư).
3. Đo dung lượng và thời gian tải.
4. Kiểm tra lưu `user://` khi game chạy trong iframe.

Bước này là save point đầu tiên, phải xong trước khi viết luật.

### Phần kiến trúc engine lo sẵn

| Thành phần | Giải pháp | Ghi chú |
|---|---|---|
| Render | Renderer Compatibility (WebGL 2), 2D | Bắt buộc cho web. Đủ cho bàn tối đa 10×8 (80 ô) ở 60 FPS |
| Vật lý | Không dùng | Mọi va chạm là luật trên lưới, nằm trong bộ phân giải |
| Âm thanh | AudioStreamPlayer có sẵn | Trình duyệt chỉ cho phát âm thanh sau lần bấm đầu tiên |
| Input | InputMap (chuột + phím tắt) | Các phím 1-2-3, Q/W, Z, Space, R khai báo trong InputMap |
| Quản lý scene | Scene tree, `change_scene_to_packed` | Chỉ lo màn hình và phần hiển thị, không chứa luật |
| Hoạt ảnh | Tween (Godot 4) | Phát lại nhật ký sự kiện. Tua nhanh bằng cách đổi tốc độ |
| Bản địa hóa | TranslationServer + file CSV/PO | Tiếng Việt trước, tiếng Anh ở giai đoạn 2 |
| Lưu trữ | `user://` (trên web nằm trong IndexedDB) | Kiểm tra trong iframe của itch.io ở bước E0 |
| Build | Export template Web (đơn luồng) + Windows | Bản Windows làm ở giai đoạn 2 |
| Test | GUT **v9.7.1** (quyết định #11), chép vào `addons/`, chạy với `--headless` | Chỉ test bộ luật, chạy bằng một lệnh |

### Công cụ AI (MCP)

**GoPeak** (`HaD0Yun/Gopeak-godot-mcp`)
- Ghim phiên bản **`gopeak@2.3.8`** (quyết định #23), không chạy `npx -y gopeak` không kèm phiên bản.
- Dùng profile `compact`. Cần Node.js 18+. Addon editor/runtime cài vào project.
- **Quy ước:** MCP dùng để *nhìn* (log, chẩn đoán, chụp màn hình) và để thử (bơm input). **Luật chỉ được sửa trong code, có test đi kèm.** Không dùng MCP để sửa luật hay sửa dữ liệu trận rồi bỏ qua test.

**Context7**
- AI tra tài liệu Godot 4.7 hiện hành, tránh dùng API của Godot 3.

### Quyết định kiến trúc còn lại (đã chốt hết ở bước 4–7)

1. Mô hình dữ liệu trạng thái trận, và cách chụp/khôi phục trạng thái cho hoàn tác
2. Hợp đồng của bộ phân giải luật và định dạng sự kiện trong nhật ký
3. Bảng thứ tự phân giải luật (gồm 3 ca còn mở ở bước 2)
4. Định dạng file dữ liệu trận: JSON, Resource `.tres` hay văn bản bàn cờ chữ
5. Định dạng file kịch bản luật, và cách chạy toàn bộ test bằng một lệnh
6. Máy trạng thái hiệp, và ranh giới giữa luật với phần trình bày
7. Độ phân giải gốc và cách co giãn (stretch mode)
8. Định dạng file lưu, có đánh số phiên bản file lưu hay không
9. Cấu trúc thư mục và quy ước đặt tên (luật bắt buộc cho AI)
10. Quy trình build và đưa lên itch.io

---

## Quyết định kiến trúc

### Bảng tổng hợp

| # | Hạng mục | Quyết định | Phiên bản | Lý do |
|---|---|---|---|---|
| 1 | Trạng thái trận | `BattleState` thuần dữ liệu (RefCounted), có `clone()`, không tham chiếu tới Node | — | Hoàn tác, xem trước, test và tính tất định đều cần luật chạy được mà không cần màn hình |
| 2 | Chủ giữ trạng thái | Chỉ `BattleController` giữ trạng thái đang sống. Phần trình bày chỉ nhận sự kiện và bản chụp | — | Tránh lỗi hoạt ảnh nhìn thấy dữ liệu bị đổi giữa lúc đang diễn |
| 3 | Hoàn tác | Bản chụp trạng thái (hủy nước đi giữ một bản; chơi lại hiệp giữ bản đầu lượt) | — | Bàn tối đa 10×8 (80 ô) nên chụp rất rẻ; đơn giản hơn lệnh đảo ngược |
| 4 | Bộ phân giải luật | Hàm thuần: nhận trạng thái và lệnh, áp dụng luật, trả về danh sách sự kiện | — | Một chỗ duy nhất chứa luật. Nhật ký sự kiện dùng chung cho hoạt ảnh, test và tua nhanh |
| 5 | Trình tự hiệp | Biến pha nằm trong `BattleState`; chuyển pha bằng hàm của lõi luật | — | Không dùng StateMachine kiểu Node, để luật không lọt vào scene |
| 6 | Enemy AI | Hàm thuần trong lõi luật, BFS tự viết, duyệt hướng cố định B→Đ→N→T | — | Tất định. Luật "đi xuyên quân mình" không khớp với AStarGrid2D |
| 7 | Xem trước kết quả đòn | **Có, từ E2, bản tối giản**: bóng mờ ở vị trí cuối và số máu sau đòn. Trau chuốt ở E4 | — | Tác giả chốt 2026-10-16. Cần bổ sung vào GDD |
| 8 | Chỉ số và tham số luật | **Mọi** chỉ số nằm trong `chi_so.json` (máu, tầm đi, tầm đánh, sát thương, độ đẩy, tầm kéo, tham số mưu kế). Luật vẫn nằm trong code | — | Tác giả tự cân bằng game sau playtest mà không cần sửa code |
| 9 | Dữ liệu trận | JSON gồm hai lớp bàn cờ chữ (địa hình, quân), có số phiên bản định dạng | — | Tác giả sửa bằng trình soạn thảo bất kỳ; Godot đọc JSON có sẵn |
| 10 | Kịch bản luật | Cùng định dạng với dữ liệu trận: trước → hành động → sau. **AI viết, tác giả duyệt** | — | Kịch bản là spec mà tác giả đọc được; test chạy đúng các file này |
| 11 | Test | GUT chạy `--headless`, một lệnh chạy hết, in tóm tắt tiếng Việt | **GUT v9.7.1** | Bản release dành cho Godot 4.7 (10/07/2026) |
| 12 | Công cụ dev | Tham số URL `?tran=N&dev=1` trên bản web. Khi bật dev: F1 tọa độ ô, F2 sao chép báo lỗi, F3 xem AI định làm gì, F5 nạp lại file trận | — | Đồ nghề của tester. Link gửi người thân thì bỏ `dev` |
| 13 | Độ phân giải | 1280×720, stretch mode `canvas_items`, aspect `keep` | — | Vừa iframe itch.io và laptop; chữ, đồng quân vẫn nét khi phóng to |
| 14 | Lưu game | JSON trong `user://`, có trường phiên bản. Cài đặt lưu bằng `ConfigFile` | — | Không có server. Có phiên bản thì nâng cấp file lưu được |
| 15 | Nạp asset | Nạp sẵn toàn bộ | — | Asset rất ít; bản web chạy đơn luồng |
| 16 | Cấu trúc scene | Một scene chính, đổi giữa các màn: Menu, Trận, Chuyển trận. Tối đa 1 autoload | — | Đơn giản, ít trạng thái toàn cục |
| 17 | UI | Control node, một Theme dùng chung; HUD dựng bằng code | — | Theo luật "scene nhỏ và phẳng" |
| 18 | Font | Font tiếng Việt đủ dấu, giấy phép OFL (ví dụ Be Vietnam Pro hoặc Noto Sans) | — | Quân cờ và giao diện đều là chữ có dấu |
| 19 | Âm thanh | AudioStreamPlayer có sẵn, 2 bus (Nhạc, Hiệu ứng); chỉ bật sau lần bấm đầu tiên | — | Prototype có thể chưa có âm thanh |
| 20 | Bản địa hóa | File CSV dịch; mọi chữ hiển thị đi qua `tr()` | — | Giai đoạn 2 chỉ cần thêm một cột tiếng Anh |
| 21 | Số ngẫu nhiên | Prototype không dùng. Giai đoạn 1 dùng một nguồn `RandomNumberGenerator` duy nhất, có seed | — | Combat tất định; bản đồ dựng lại được theo seed |
| 22 | Build và deploy | Export bằng dòng lệnh `--headless`, đẩy lên itch.io bằng `butler` | Godot 4.7.2 | Không cần mở editor để build |
| 23 | Công cụ AI | GoPeak (profile `compact`) và Context7 | **gopeak 2.3.8** | Ghim phiên bản, không dùng `npx -y` khi chưa ghim |

### Quản lý trạng thái

**Cách làm:** lõi luật thuần dữ liệu, tách hẳn khỏi Node.

- **`BattleState` chứa:**
  - kích thước bàn và lớp địa hình;
  - danh sách quân: id, phe, loại, vị trí, máu, đã đi hay đã đánh;
  - các đòn đã báo: ô hoặc hướng, kèm thứ tự;
  - các ô tiếp viện đã báo;
  - cờ mưu kế, số hiệp, số hiệp tối đa (nếu có), Lòng dân hiện tại và tối đa (nếu có), pha hiện tại, cờ "đã dùng chơi lại hiệp".
- **Lệnh của người chơi:** `Move`, `Attack`, `UseStratagem`, `EndTurn`.
- **`BattleController` là nơi duy nhất giữ trạng thái đang sống.** Nó chụp trạng thái trước lệnh, gọi bộ phân giải, giữ bản chụp để hủy nước đi, rồi gửi danh sách sự kiện và bản chụp sau cùng cho phần trình bày.
- **Bộ phân giải** sửa trực tiếp trên trạng thái được truyền vào và trả về danh sách sự kiện. Muốn giữ bản gốc (hoàn tác, xem trước) thì phải `clone()` trước khi gọi.
- **Sự kiện** gồm một trường loại và dữ liệu đi kèm. Các loại dự kiến: đi, bị đẩy, bị kéo, va chạm, mất máu, gục, chết đuối, báo đòn, ra đòn, hủy đòn, đòn dịch theo, tiếp viện xuất hiện, tiếp viện bị chặn, hồi máu, đốt kho lương, làng bị trúng (kèm Lòng dân còn lại), hết hiệp, dùng mưu kế, đổi pha, thắng, thua. Danh sách chính thức chốt ở bước Patterns.
- **Hoàn tác:**
  - "Hủy nước đi" quay về bản chụp ngay trước khi tướng đó đi.
  - **Chỉ giữ một bản chụp**: hủy được đúng một nước (nước đi gần nhất); hủy xong phải đi nước mới mới hủy tiếp được (tác giả chốt 2026-10-18).
  - Lệnh `Attack`, `UseStratagem` (chốt 2026-10-17) và `EndTurn` **xóa bản chụp hủy**.
  - "Chơi lại hiệp" quay về bản chụp đầu lượt người chơi, **kể cả cờ mưu kế** (mưu kế dùng trong lượt được trả lại), rồi xóa bản chụp hủy. Riêng cờ "đã dùng chơi lại hiệp" được đặt thành đã dùng sau khi khôi phục.
- **Xem trước:** clone trạng thái, chạy lệnh trên bản sao, rồi hiển thị kết quả dạng mờ. Ở E2 chỉ hiện vị trí cuối và số máu.

**Phần trình bày** (Node, Tween, HUD) chỉ đọc bản chụp để vẽ và phát lại sự kiện. Phần này **không bao giờ** sửa trạng thái và **không giữ tham chiếu** tới trạng thái đang sống.

### Dữ liệu trận, chỉ số và kịch bản luật

**Dữ liệu trận:** JSON, mỗi trận một file.

```json
{
  "phien_ban_dinh_dang": 1,
  "ten": "Trận 1",
  "kieu": "tieu_diet",
  "dia_hinh": [
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . . . . .",
    ". . . ~ . . .",
    ". . . ~ . . .",
    ". . . ~ . . ."
  ],
  "quan": [
    ". B . . . B .",
    ". . . . . . .",
    ". . . . . . .",
    ". . . . . . .",
    ". . . . . B .",
    ". . . . . . .",
    "1 . 2 . 3 . ."
  ],
  "thu_tu_dich": ["1,0", "5,0", "5,4"],
  "tiep_vien": [],
  "muu_ke_mo": []
}
```

- **Ký hiệu địa hình** (theo GDD): `.` đất trống, `~` sông, `#` rừng, `^` hầm chông, `L` kho lương, `D` làng, `A` ô ải.
- **Ký hiệu quân:** `1` Nguyễn Khoái, `2` Phạm Ngũ Lão, `3` Trần Khánh Dư, `B` Bộ binh, `K` Kỵ binh, `C` Cung kỵ.
- **Tọa độ:** `cột,hàng`, gốc `0,0` ở góc trên bên trái, hướng Bắc ở phía trên.
- **Cỡ bàn** (thêm 2026-10-20):
  - Cỡ bàn suy ra từ lớp `dia_hinh`: số dòng là số hàng, số ký hiệu trên một dòng là số cột.
  - Lớp `quan` và mọi lớp khác phải cùng cỡ với lớp `dia_hinh`.
  - Cỡ hợp lệ: số cột từ 5 đến 10, số hàng từ 5 đến 8. Cỡ sai thì báo lỗi tiếng Việt, ghi rõ file và cỡ đọc được.
  - Hai giới hạn này là hằng số `BOARD_MIN` và `BOARD_MAX` trong `board_layers.gd`, thay cho `BOARD_SIZE`. `NO_SIZE` là "chưa biết cỡ" (lớp `dia_hinh` hỏng): khi đó không kiểm chéo lớp khác và không kiểm ô ngoài bàn.
  - Kịch bản luật dùng cùng luật cỡ bàn này.
  - Không lặp cứng cỡ bàn: luôn dùng `level.size`.
- **`thu_tu_dich`:** chỉ ghi tọa độ. Bộ nạp đối chiếu với lớp `quan`; ô nào không có quân Nguyên thì báo lỗi.
- **`tiep_vien`:** mỗi mục có dạng `{"hiep": 2, "o": "3,0", "loai": "K"}`.
- **`so_hiep_toi_da`** (không bắt buộc, chỉ dùng cho `"kieu": "tieu_diet"`): số nguyên dương. Không có thì không giới hạn hiệp. (thêm 2026-10-18)
- **`long_dan`** (bắt buộc khi lớp `dia_hinh` có ô `D`): số nguyên dương, là Lòng dân ban đầu và tối đa. (thêm 2026-10-18)
- **Bộ nạp:**
  - chịu được dấu cách thừa;
  - kiểm tra kích thước dòng, ký hiệu lạ và tọa độ ngoài bàn;
  - báo lỗi khi có ô `D` mà thiếu `long_dan`, hoặc khi `so_hiep_toi_da`, `long_dan` không phải số nguyên dương;
  - báo lỗi bằng tiếng Việt, chỉ rõ file, dòng và ký hiệu sai.
- **Ngôn ngữ của khóa:** file dữ liệu dùng khóa tiếng Việt không dấu, vì tác giả là người đọc. Code dùng tên tiếng Anh. Quy ước chi tiết chốt ở bước Patterns.

**Chỉ số (`chi_so.json`):** chứa mọi con số cân bằng, gồm máu, tầm đi, tầm đánh, sát thương, độ đẩy, tầm kéo và tham số mưu kế. Ví dụ: giảm tầm kéo của Trần Khánh Dư từ 2 xuống 1 thì chỉ cần sửa một số trong file này, rồi chạy lại kịch bản luật.

**Kịch bản luật:** dùng cùng hai lớp bàn cờ chữ, chia ba phần:

| Phần | Nội dung |
|---|---|
| `truoc` | Bàn cờ và máu ban đầu |
| `hanh_dong` | Danh sách lệnh dạng object, ví dụ `{"tuong": "3", "lenh": "danh", "o": "4,2"}`. Lệnh `{"lenh": "ket_thuc_luot"}` chạy luôn pha địch. Lệnh luật phải từ chối thì ghi thêm `"tu_choi": "<mã lý do>"` (`khong_co_quan`, `khong_phai_tuong`, `da_dung_o_do`, `khong_toi_duoc`, `da_di_roi`, `khong_con_nuoc_di`, `da_danh_roi`, `khong_ke`, `khong_co_dich`, `ngoai_tam`, `tran_da_het`; lệnh `huy` cũng nhận `tu_choi`; mỗi lệnh chỉ nhận mã của luật lệnh đó; `tran_da_het` (trận đã thắng hoặc thua, Story 2.5) nhận ở `di`, `danh`, `huy`); lệnh bị từ chối mà không ghi, hoặc ghi mà không bị từ chối, là kịch bản trượt |
| `sau` | Bàn cờ và máu mong đợi. Không bắt buộc: `"hiep": 2` (hiệp mong đợi) và `"da_di": ["1"]` (các tướng đã đi trong lượt; `[]` là chưa tướng nào đi, tướng không ghi phải chưa đi), `"da_danh": ["1"]` (như `da_di`, các tướng đã đánh; Story 2.1), `"ket_qua": "dang_choi" | "thang" | "thua"` (kết cục của trận, Story 2.5), `"bao_don": [{"thu_tu": 1, "quan": "3,3", "o": "3,4"}, {"thu_tu": 2, "quan": "0,3", "huong": "D"}]` (đòn quân Nguyên đã báo: ô chủ đòn ở bàn sau, ô bị nhắm hoặc hướng xung phong B/D/N/T; `[]` là không quân nào báo đòn; Story 2.6); không ghi thì không kiểm (tác giả chốt 2026-10-18). Có thể ghi thêm vài sự kiện chính (ví dụ `chet_duoi`) khi đó chính là điều cần kiểm |

Mỗi khi chốt một luật, AI viết kịch bản, tác giả đọc rồi trả lời "đúng" hoặc "sai". Một lệnh chạy toàn bộ kịch bản và in kết quả đạt/trượt bằng tiếng Việt.

### Lưu game

- **Prototype:** sau mỗi trận, lưu tiến độ chiến dịch (đang ở trận nào, mưu kế nào đã mở). Không lưu giữa trận.
- **Giai đoạn 1:** lưu thêm bản chụp lượt chơi roguelite và seed.
- **File lưu có trường `phien_ban`.** Gặp phiên bản lạ hoặc file hỏng thì không làm sập game: báo lỗi và cho bắt đầu lại.
- **Cài đặt** (âm lượng, tốc độ hoạt ảnh) nằm riêng trong `user://settings.cfg`.

### Nạp asset

Nạp sẵn toàn bộ khi mở game. Asset của prototype chỉ gồm font, khoảng 10 âm thanh CC0 và vài texture nền. Đồng quân và ô cờ vẽ bằng code.

### Architecture Decision Records

- **ADR-001: Luật là dữ liệu thuần, tách khỏi Node.**
  - *Bối cảnh:* cần hoàn tác, chơi lại hiệp, xem trước, tua nhanh, test; nhiều phiên AI cùng viết code.
  - *Quyết định:* mọi luật nằm trong lõi thuần dữ liệu. Chỉ `BattleController` giữ trạng thái đang sống. Node chỉ vẽ và phát lại sự kiện.
  - *Hệ quả:* phải viết thêm một lớp nối giữa lõi và phần hiển thị; đổi lại, test chạy được mà không cần màn hình.
- **ADR-002: Hoàn tác bằng bản chụp, không dùng lệnh đảo ngược.** Bàn tối đa 10×8 (80 ô) nên chụp lại gần như miễn phí và ít lỗi.
- **ADR-003: Dữ liệu trận là JSON có bàn cờ chữ.**
  - *Lý do:* tác giả không mở editor và tự thiết kế trận; Godot có sẵn bộ đọc JSON nên AI ít viết sai.
  - *Đã loại:* `.tres` (phải dùng editor), định dạng chữ tự chế (thêm bộ đọc, thêm chỗ sinh lỗi).
- **ADR-004: Kịch bản luật là spec.** Tác giả không đọc code, nên kịch bản là cách để tác giả kiểm luật. AI viết, tác giả duyệt. Hành động viết dạng object JSON; không tự chế ngôn ngữ lệnh.
- **ADR-005: Có xem trước kết quả đòn từ E2, bản tối giản.**
  - *Lý do:* phục vụ trụ cột "Thấy trước, tính được"; làm rẻ nhờ ADR-001.
  - *Phạm vi E2:* bóng mờ vị trí cuối và số máu. Trau chuốt ở E4.
  - *Việc kèm theo:* bổ sung vào GDD.
- **ADR-006: Con số thuộc về người thiết kế.** Mọi chỉ số nằm trong `chi_so.json`, luật nằm trong code. Các mục [KIỂM TRA KHI PLAYTEST] trong GDD được chỉnh bằng dữ liệu, không cần sửa code.

---

## Các vấn đề xuyên suốt

Mọi hệ thống phải tuân theo các mẫu dưới đây. Đây là luật bắt buộc cho mọi phiên AI.

### Xử lý lỗi

**Chiến lược:** GDScript không có try/catch. Lỗi được xử lý bằng **đối tượng kết quả** (result object) và **kiểm tra bất biến**. Lỗi chia làm ba loại, mỗi loại một cách xử lý.

| Loại | Ví dụ | Cách xử lý | Người chơi thấy gì |
|---|---|---|---|
| **Lỗi dữ liệu** | File trận sai ký hiệu, `chi_so.json` thiếu khóa, file lưu hỏng | Bộ nạp trả về `{ok, data, errors}`. Mỗi lỗi là một câu tiếng Việt, ghi rõ file, dòng và giá trị sai. Không làm sập game | Bật dev: màn hình lỗi liệt kê đủ các lỗi. Bản phát hành: chỉ thông báo ngắn kèm nút "Về menu"; chi tiết vẫn ghi vào log |
| **Lệnh không hợp lệ** | Bấm đi vào ô bị chặn, đánh ngoài tầm | Bộ phân giải từ chối lệnh, trả về lý do. Đây **không phải lỗi**, không ghi log ERROR | Không có gì thay đổi; ô hoặc nút không sáng lên |
| **Vi phạm bất biến** (bug) | Quân ra ngoài bàn, máu âm, hai quân chung một ô, đòn không có chủ | Sau mỗi lần phân giải, chạy `BattleState.validate()` (bắt buộc trong test và khi bật dev). Phát hiện thì ghi log ERROR và **khôi phục bản chụp trước lệnh** | Thông báo "Có lỗi, đã quay lại nước trước", game vẫn chạy tiếp |

**Luật:**
- Không bao giờ để game kẹt. Bản chụp trước mỗi lệnh chính là cơ chế cứu trận.
- Không dùng `assert()` cho lỗi dữ liệu, vì `assert()` bị bỏ qua trong bản phát hành.

**Ví dụ:**

```gdscript
# Bộ nạp dữ liệu: trả kết quả, không bao giờ crash
static func load_level(path: String) -> LoadResult:
    var result := LoadResult.new()
    var text := FileAccess.get_file_as_string(path)
    if text.is_empty():
        result.add_error("Không đọc được file %s" % path)
        return result
    var data = JSON.parse_string(text)
    if data == null:
        result.add_error("%s: JSON sai cú pháp" % path)
        return result
    # ... kiểm tra từng dòng dia_hinh/quan, gom TẤT CẢ lỗi rồi mới trả về
    return result

# BattleController: kiểm tra bất biến sau mỗi lần phân giải
func _apply(command: Command) -> void:
    var before := _state.clone()
    var events := Rules.resolve(_state, command)
    var problems := _state.validate()
    if not problems.is_empty():
        Log.error("rules", "Vi phạm bất biến: %s" % problems)
        _state = before
        notice_requested.emit(tr("error.rolled_back"))
        return
    _undo_stack.push_back(before)
    events_resolved.emit(events, _state.clone())
```

### Ghi log

**Cách làm:** dùng một lớp tĩnh `Log` (`class_name Log`, chỉ có hàm static). Lớp này **không phải autoload**, nên vẫn giữ được giới hạn tối đa 1 autoload.

**Định dạng:** `[CẤP][hệ_thống] thông điệp`, chữ thường, không có dấu chấm cuối câu.

**Nơi ghi:**
- console (bản web là Console của trình duyệt, mở bằng F12);
- **200 dòng gần nhất** giữ trong bộ nhớ để đưa vào báo lỗi.

| Cấp | Dùng khi | Có trong bản phát hành |
|---|---|---|
| `ERROR` | Vi phạm bất biến, file lưu hỏng, nạp asset thất bại | Có |
| `WARN` | Dữ liệu lạ nhưng vẫn xử lý được, ví dụ khóa thừa trong JSON | Có |
| `INFO` | Mốc quan trọng: nạp trận, thắng hoặc thua, lưu game, đổi màn | Có |
| `DEBUG` | Chi tiết khi phát triển: lệnh nhận vào, AI chọn ô nào | Chỉ khi bật dev |

**Luật:**
- Lõi luật **không ghi log trong vòng lặp phân giải**. Nhật ký sự kiện đã là bản ghi đầy đủ.
- Không dùng `print()` trực tiếp. Mọi log đi qua `Log`.

**Ví dụ:**

```gdscript
Log.info("battle", "nạp trận %s, %d quân nguyên" % [level_id, enemy_count])
Log.debug("ai", "kỵ binh #%d chọn ô %s, nhắm tướng %s" % [id, cell, target])
Log.error("save", "file lưu phiên bản %d không hỗ trợ" % version)
```

### Cấu hình

| Tầng | Nơi lưu | Ai sửa | Ví dụ |
|---|---|---|---|
| Hằng số luật | Code (`enum`, `const`) | AI, khi luật đổi | Hướng B/Đ/N/T, loại địa hình, loại sự kiện |
| Chỉ số cân bằng | `data/chi_so.json` | **Tác giả** | Máu, tầm đi, tầm kéo, sát thương mưu kế |
| Dữ liệu trận | `data/tran/*.json` | **Tác giả** | Bàn cờ, quân, tiếp viện |
| Cài đặt người chơi | `user://settings.cfg` (ConfigFile) | Người chơi | Âm lượng, tốc độ hoạt ảnh |
| Nền tảng và build | `project.godot`, `export_presets.cfg` | AI | Độ phân giải, renderer, export web |

**Luật:**
- Không có "số ma thuật" về cân bằng trong code. Người thiết kế có thể muốn chỉnh con số nào thì con số đó nằm trong `chi_so.json`.
- Không có cấu hình từ xa.

### Hệ thống sự kiện

**Mẫu:** signal có kiểu của Godot, kết nối trực tiếp. **Không dùng Event Bus toàn cục.**

| Hướng | Cách truyền |
|---|---|
| Lõi luật → `BattleController` | Danh sách sự kiện (dữ liệu, giá trị trả về). Lõi luật **không phát signal** |
| `BattleController` → trình bày | Signal `events_resolved(events: Array[BattleEvent], snapshot: BattleState)` |
| UI → `BattleController` | Gọi hàm trực tiếp: `controller.submit(command)`, `controller.preview(command)` |
| Trình bày → `BattleController` | Signal `playback_finished` khi phát hết hoạt ảnh, để mở khóa input |

**Đặt tên:**
- Signal: `snake_case`, thì quá khứ (`events_resolved`, `battle_won`, `level_loaded`).
- Loại sự kiện: enum `BattleEvent.Type`, viết hoa (`PUSHED`, `COLLIDED`, `DROWNED`). Không dùng chuỗi tự do.

**Ví dụ:**

```gdscript
# battle_controller.gd
signal events_resolved(events: Array[BattleEvent], snapshot: BattleState)
signal playback_finished

# battle_view.gd
func _ready() -> void:
    controller.events_resolved.connect(_on_events_resolved)

func _on_events_resolved(events: Array[BattleEvent], snapshot: BattleState) -> void:
    _input_locked = true
    for e in events:
        await _play(e)          # Tween; tua nhanh = tăng tốc độ phát của view
    _redraw(snapshot)
    _input_locked = false
    controller.playback_finished.emit()
```

### Công cụ debug

**Kích hoạt:**
- Bản web: thêm `?dev=1` vào URL.
- Bản desktop: chạy với tham số `--dev`.

Khi không bật dev, mọi phím debug đều không có tác dụng. **Code debug vẫn nằm trong bản phát hành** nhưng bị khóa, nên tester và người thân chơi cùng một bản build.

| Phím | Công cụ | Dùng để |
|---|---|---|
| `F1` | Overlay tọa độ ô và id quân | Báo lỗi chính xác ("trận 3, ô 4,2") |
| `F2` | **Sao chép báo lỗi:** trạng thái trận hiện tại (theo dạng `truoc` của kịch bản luật), các lệnh trong hiệp, 200 dòng log, phiên bản build | Dán thẳng cho AI. Lỗi trở thành **kịch bản luật mới**, nên không quay lại được nữa |
| `F3` | Overlay ý định AI: mỗi quân Nguyên nhắm ai, chọn ô nào, vì sao | Kiểm tra Enemy AI có đúng spec không |
| `F5` | Nạp lại file trận và `chi_so.json`, mở lại trận từ đầu. Chạy ở mọi màn hình (trận, lỗi, menu) | Sửa số rồi thử ngay, không cần build lại. Chỉ dùng trên desktop: bản web đọc lại dữ liệu đóng gói sẵn, trình duyệt có tải lại trang cũng chấp nhận (tác giả chốt 2026-10-18) |
| `?tran=N` | Mở thẳng trận N | Không phải chơi lại từ trận 1 |

**Hiển thị phiên bản build:** góc màn hình luôn hiện số phiên bản và mã commit ngắn, kể cả khi không bật dev. Khi báo lỗi, tester luôn biết mình đang chơi bản nào.

---

## Cấu trúc dự án

### Cách tổ chức

**Mẫu:** phân theo tầng ở cấp trên cùng, theo tính năng bên trong mỗi tầng.

**Lý do:**
- Ranh giới "lõi luật thuần dữ liệu" (ADR-001) phải nhìn thấy được ngay trên cây thư mục.
- Ranh giới đó phải kiểm tra được bằng script, vì tác giả không đọc code.

### Cây thư mục

```
chong-nguyen-mong/                    # repo
├── game/                             # PROJECT GODOT (project.godot ở đây)
│   ├── project.godot
│   ├── export_presets.cfg            # Web (đơn luồng) + Windows; filter thêm *.json; loại trừ tests/, addons/gut/
│   ├── addons/
│   │   ├── gut/                      # GUT v9.7.1, chép nguyên bản release (không dùng submodule)
│   │   └── (addon của GoPeak)        # cài bằng script của GoPeak
│   ├── src/
│   │   ├── core/                     # ★ LÕI LUẬT: không Node, không scene, không I/O
│   │   │   ├── grid.gd               # Vector2i, 4 hướng B/Đ/N/T, khoảng cách Manhattan, trong/ngoài bàn
│   │   │   ├── battle_state.gd       # BattleState: clone(), validate()
│   │   │   ├── unit.gd               # quân: id, phe, loại, vị trí, máu, cờ đã đi/đã đánh
│   │   │   ├── telegraph.gd          # đòn đã báo: ô hoặc hướng, thứ tự, chủ đòn
│   │   │   ├── command.gd            # Move / Attack / UseStratagem / EndTurn
│   │   │   ├── battle_event.gd       # BattleEvent + enum Type
│   │   │   ├── stats.gd              # chỉ số đã nạp từ chi_so.json (chỉ đọc)
│   │   │   ├── rules.gd              # ĐIỂM VÀO DUY NHẤT: resolve(state, command) -> events
│   │   │   ├── rules_move.gd         # đi, tầm đi, đi xuyên quân mình
│   │   │   ├── rules_attack.gd       # đòn 3 tướng
│   │   │   ├── forced_move.gd        # ForcedMove.run: đẩy, kéo từng ô, va chạm (Story 2.1)
│   │   │   ├── rules_terrain.gd      # sông, rừng, hầm chông, kho lương, mép bàn
│   │   │   ├── rules_enemy_phase.gd  # chuẩn bị, ra đòn theo thứ tự, cuối hiệp, tiếp viện
│   │   │   ├── rules_stratagem.gd    # Sát Thát, Vườn không nhà trống
│   │   │   ├── rules_victory.gd      # Tiêu diệt, Giữ ải
│   │   │   ├── enemy_ai.gd           # chọn mục tiêu, chọn ô đứng, hòa điểm B→Đ→N→T
│   │   │   ├── enemy_intent.gd       # ý định một quân Nguyên (mục tiêu, ô đứng, lý do), F3 đọc (Story 2.6)
│   │   │   ├── pathfinding.gd        # BFS tự viết
│   │   │   └── campaign_progress.gd  # tiến độ chiến dịch, mưu kế đã mở
│   │   ├── data/                     # NẠP VÀ KIỂM TRA DỮ LIỆU: không Node; được dùng FileAccess
│   │   │   ├── load_result.gd        # {ok, data, errors}
│   │   │   ├── board_text.gd         # đọc/ghi bàn cờ chữ (dùng chung cho trận, kịch bản, F2)
│   │   │   ├── level_loader.gd
│   │   │   ├── stats_loader.gd
│   │   │   ├── campaign_loader.gd
│   │   │   ├── scenario_loader.gd
│   │   │   └── save_system.gd        # user://save.json, có trường phien_ban
│   │   ├── battle/                   # CẦU NỐI + TRÌNH BÀY TRẬN (Node)
│   │   │   ├── battle_controller.gd  # giữ trạng thái sống, bản chụp hủy, xem trước
│   │   │   ├── battle_view.gd        # gốc phần hiển thị trận
│   │   │   ├── board_view.gd         # vẽ mọi ô của bàn (cỡ theo trận) nhìn chếch bằng code (Story 1.8); nơi duy nhất đổi ô ↔ điểm
│   │   │   ├── unit_token.gd         # đồng quân tròn khắc chữ
│   │   │   ├── telegraph_view.gd     # ô đỏ, số thứ tự, mũi tên xung phong
│   │   │   ├── preview_view.gd       # bóng mờ vị trí cuối + máu
│   │   │   ├── event_player.gd       # BattleEvent -> Tween; tua nhanh
│   │   │   └── battle_input.gd       # chuột + phím tắt -> Command
│   │   ├── ui/
│   │   │   ├── hud.gd                # nút mưu kế, Hủy, Kết thúc lượt, Chơi lại hiệp; tooltip
│   │   │   ├── result_banner.gd      # bảng "Thắng!"/"Thua!" + nút Chơi lại trận (bỏ nút khi có menu, 4.2)
│   │   │   ├── main_menu.gd
│   │   │   ├── level_transition.gd
│   │   │   ├── notice.gd             # thông báo ngắn ("đã quay lại nước trước")
│   │   │   └── error_screen.gd
│   │   ├── app/
│   │   │   ├── main.gd               # scene chính, đổi màn
│   │   │   ├── app_state.gd          # AUTOLOAD DUY NHẤT: tiến độ, cài đặt, cờ dev
│   │   │   └── launch_options.gd     # đọc ?tran=N&dev=1 (web) / --dev (desktop)
│   │   └── debug/
│   │       ├── log.gd                # class_name Log (static, không autoload)
│   │       ├── dev_tools.gd          # F1/F2/F3/F5, chỉ chạy khi bật dev
│   │       ├── ai_intent_overlay.gd  # F3: bảng ý định quân Nguyên (Story 2.6)
│   │       └── bug_report.gd         # dựng nội dung F2
│   ├── scenes/                       # scene nhỏ và phẳng: chỉ là khung
│   │   ├── main.tscn
│   │   ├── battle.tscn
│   │   ├── main_menu.tscn
│   │   └── level_transition.tscn
│   ├── data/                         # ★ TÁC GIẢ SỬA
│   │   ├── chi_so.json
│   │   ├── chien_dich.json           # thứ tự 6 trận, mưu kế mở theo trận
│   │   └── tran/
│   │       ├── tran_01.json … tran_05.json
│   │       ├── thu_ba_tuong.json, thu_day.json, thu_lao.json, thu_keo.json, thu_thang.json   # trận thử, chỉ mở bằng --dev --tran=<tên>
│   ├── assets/
│   │   ├── fonts/
│   │   ├── audio/sfx/  audio/music/
│   │   ├── textures/
│   │   └── theme/main_theme.tres
│   ├── i18n/
│   │   └── text.csv                  # cột: keys, vi (sau này thêm en)
│   └── tests/
│       ├── kich_ban/                 # ★ TÁC GIẢ DUYỆT: kịch bản luật
│       │   ├── di_chuyen/  day/  keo/  va_cham/  dia_hinh/  lao/
│       │   ├── don_dich/  ai/  tiep_vien/  muu_ke/  hiep/  ket_thuc/  lang/  gioi_han_hiep/
│       ├── test_scenarios.gd         # chạy mọi file trong kich_ban/
│       ├── test_loaders.gd           # dữ liệu sai -> báo lỗi đúng
│       └── test_<khu_vuc>.gd         # test GUT bổ sung do AI viết
├── tools/                            # LỆNH CHO TÁC GIẢ (chạy từ gốc repo)
│   ├── cai_dat.sh                    # tải Godot 4.7.2 + export template (kiểm checksum), butler
│   ├── chay.sh                       # chạy bản desktop trên máy (--dev, --tran=N)
│   ├── test.sh                       # ★ MỘT LỆNH: kiểm ranh giới + chạy toàn bộ test, in tóm tắt tiếng Việt
│   ├── check_boundaries.sh           # quét src/core, src/data tìm vi phạm ranh giới
│   ├── xem_kich_ban.sh               # in kịch bản chưa duyệt (bàn trước | bàn sau) để tác giả duyệt
│   ├── build_web.sh                  # export web bằng --headless -> build/web/; trượt nếu bản nén > 25MB
│   └── deploy_itch.sh                # đẩy build/web lên itch.io bằng butler
├── build/                            # (gitignore) bản build
├── _bmad/  _bmad-output/  .claude/   # tài liệu BMAD, không thuộc project Godot
└── NEXT-STEPS.md
```

### Bản đồ hệ thống → vị trí

| # | Hệ thống (bước 2) | Vị trí | Trách nhiệm |
|---|---|---|---|
| 1 | Trạng thái trận | `src/core/battle_state.gd`, `unit.gd`, `telegraph.gd` | Dữ liệu, `clone()`, `validate()` |
| 2 | Bộ phân giải luật | `src/core/rules*.gd` | Mọi luật; điểm vào duy nhất là `Rules.resolve()` |
| 3 | Nhật ký sự kiện | `src/core/battle_event.gd` (tạo), `src/battle/event_player.gd` (phát) | Hợp đồng giữa lõi và trình bày |
| 4 | Trình tự hiệp | `src/core/rules_enemy_phase.gd` + pha trong `BattleState` | 4 pha, chuyển pha |
| 5 | Enemy AI | `src/core/enemy_ai.gd`, `pathfinding.gd` | Tất định |
| 6 | Báo trước đòn | `src/core/telegraph.gd` (dữ liệu), `src/battle/telegraph_view.gd` (vẽ) | — |
| 7 | Xem trước kết quả | `BattleController.preview()`, `src/battle/preview_view.gd` | Chạy trên bản sao |
| 8 | Địa hình | `src/core/rules_terrain.gd` | — |
| 9 | Mưu kế | `src/core/rules_stratagem.gd` | — |
| 10 | Tiếp viện | `src/core/rules_enemy_phase.gd` | — |
| 11 | Hoàn tác, chơi lại hiệp | `src/battle/battle_controller.gd` | Bản chụp trạng thái |
| 12 | Dữ liệu trận | `data/tran/`, `src/data/level_loader.gd` | — |
| 13 | Trình bày, hoạt ảnh | `src/battle/*_view.gd`, `event_player.gd` | Chỉ đọc bản chụp |
| 14 | Input, HUD | `src/battle/battle_input.gd`, `src/ui/hud.gd` | Input → `Command` |
| 15 | Kịch bản luật | `tests/kich_ban/`, `src/data/scenario_loader.gd`, `tests/test_scenarios.gd` | — |
| 16 | Công cụ dev | `src/debug/`, `src/app/launch_options.gd` | Chỉ chạy khi bật dev |
| 17 | Chuỗi chiến dịch | `data/chien_dich.json`, `src/core/campaign_progress.gd` | — |
| 18 | Lưu game | `src/data/save_system.gd` | — |
| 19 | Bản địa hóa | `i18n/text.csv` | Mọi chữ hiển thị đi qua `tr()` |
| — | Chỉ số | `data/chi_so.json`, `src/data/stats_loader.gd`, `src/core/stats.gd` | — |
| — | Log | `src/debug/log.gd` | — |

### Quy ước đặt tên

#### File
- Script và scene: `snake_case`, **tiếng Anh** (`battle_controller.gd`, `main_menu.tscn`).
- File dữ liệu do tác giả sửa: `snake_case`, **tiếng Việt không dấu** (`chi_so.json`, `tran_03.json`).
- Kịch bản luật: `<luat>_<truong_hop>.json`, tiếng Việt không dấu (`keo_xuyen_ham_chong.json`, `day_xuong_song.json`).
- Test GUT: `test_<khu_vuc>.gd`.
- Asset: tiền tố theo loại, `snake_case` (`sfx_push.ogg`, `tex_board_bg.png`, `font_be_vietnam_pro_bold.ttf`).

#### Thành phần code
| Thành phần | Quy ước | Ví dụ |
|---|---|---|
| Class (`class_name`) | PascalCase, tiếng Anh | `BattleState`, `EnemyAI`, `LoadResult` |
| Hàm, biến | `snake_case` | `resolve()`, `move_range` |
| Thành viên riêng | tiền tố `_` | `_undo_stack` |
| Hằng số | `UPPER_SNAKE_CASE` | `MAX_UNDO` |
| Enum | Tên PascalCase, giá trị UPPER | `BattleEvent.Type.DROWNED` |
| Signal | `snake_case`, thì quá khứ | `events_resolved` |
| Tên riêng lịch sử trong code | Tiếng Việt không dấu, UPPER | `UnitType.NGUYEN_KHOAI`, `Stratagem.SAT_THAT` |
| Tọa độ | `Vector2i(cot, hang)`; trong file dữ liệu là `"cot,hang"` | `Vector2i(4, 2)` ↔ `"4,2"` |
| Ô ↔ điểm màn hình | Chỉ `BoardView.cell_center()`, `BoardView.cell_rect()` và `BoardView.cell_at()` (từ Story 1.8: ô vuông nhìn chếch, cạnh ô `TILE_SIZE` = 64 px; từ Story 1.9: `BoardView` canh giữa bàn theo `level.size` trong vùng chơi, chừa chỗ cho HUD. Nếu bàn không vừa thì thu nhỏ theo bậc nguyên `1/k` (`BoardView.fit_scale`), không thu lẻ; ô `0,0` ở góc trên bên trái, Bắc ở trên; trước đó là isometric 2:1 của Story 1.7). View khác gọi các hàm này, không tự tính. Chuột dùng `BoardView.pick_cell()`: ô **nhìn thấy** (đồng quân, khối nhô lên che ô phía sau), không trúng gì thì như `cell_at`. Thứ tự vẽ theo `hang` (từ Story 1.8; Story 1.7 dùng `cot + hang`), lớn hơn vẽ sau: khối địa hình và đồng quân là con của `BoardView._world` (`y_sort_enabled`); khối đặt cao hơn tâm ô `TILE_SIZE / 4` để không bằng y với quân ô bên cạnh. Ô sáng, đường đi, vòng chọn, sông, hầm chông, bệ ô ải vẽ trên mặt đất (`_draw` của `BoardView`), luôn dưới khối và quân (Story 1.7) | `cell_at(cell_center(c)) == c`; `pick_cell(cell_center(c)) == c` |
| Khóa dịch | `<man>.<muc>` | `hud.end_turn`, `error.rolled_back` |
| Khóa JSON dữ liệu | tiếng Việt không dấu, `snake_case` | `thu_tu_dich`, `tiep_vien` |

#### Cú pháp bắt buộc (Godot 4)
- **Gõ kiểu tĩnh ở mọi nơi.** Bật cảnh báo `untyped_declaration` ở mức **error** trong `project.godot`.
- **Chỉ dùng cú pháp Godot 4:** `await`, `@export`, `@onready`, `signal.connect(callable)`.
- **Cấm:** `yield`, `export var`, `onready var`, `connect("tên", obj, "hàm")`.

### Ranh giới kiến trúc

1. **`src/core/` là vùng cấm Node.**
   - Chỉ được `extends RefCounted` (hoặc không extends).
   - Không dùng `Node`, `get_tree()`, `$`, `Input`, `FileAccess`, `Time`, `randi`/`randf`, `print`.
   - Chỉ được phụ thuộc vào các file khác trong `src/core/`.
2. **`src/data/` không dùng Node.** Được dùng `FileAccess`. Chỉ được phụ thuộc vào `src/core/` và `src/debug/log.gd`.
3. **`src/battle/` và `src/ui/` không bao giờ sửa `BattleState`.** Mọi thay đổi đi qua `BattleController.submit()`.
4. **`app_state.gd` là autoload duy nhất.**
5. **Code debug chỉ nằm trong `src/debug/`** và luôn kiểm tra cờ dev trước khi chạy.
6. **Không file nào ngoài `data/` chứa con số cân bằng.**
7. **Kiểm tra tự động:** `tools/check_boundaries.sh` quét các vi phạm của luật 1 và 2 (theo các từ khóa bị cấm). Script này chạy đầu tiên trong `tools/test.sh`. Có vi phạm thì toàn bộ lệnh test báo **trượt**, kèm thông báo tiếng Việt chỉ rõ file và dòng.
8. **Export web:** preset phải có filter `*.json` cho file không phải resource, và loại trừ `tests/*`, `addons/gut/*`. Thiếu filter `*.json` thì bản web sẽ không có dữ liệu trận.

---


## Mẫu triển khai

Mọi phiên AI phải theo các mẫu dưới đây.

**Thuật ngữ (bắt buộc, không dùng thay nhau):**
- **Hiệp:** trọn 4 pha: địch chuẩn bị → lượt người chơi → địch ra đòn → cuối hiệp.
- **Lượt người chơi:** chỉ pha `PLAYER` trong một hiệp.
- **Lượt chơi** (giai đoạn 1): một lần chơi roguelite từ đầu tới cuối. Trong code gọi là `run`.

### Mẫu mới

#### M1. Đòn gắn vào ô (Telegraph tương đối)

**Vấn đề cần giải quyết:** đòn đã báo phải gắn với một ô cố định. Nhưng nếu chủ đòn bị đẩy hoặc kéo, đòn phải dịch theo, giữ nguyên hướng và khoảng cách tương đối.

**Cách làm:** đòn **không lưu ô tuyệt đối**. Đòn lưu **độ lệch so với chủ đòn**. Như vậy, khi chủ đòn bị đẩy, đòn tự dịch theo mà không cần đoạn code nào để "dời đòn".

| Trường | Ý nghĩa |
|---|---|
| `owner_id` | Quân ra đòn |
| `kind` | `CELL` (Bộ binh, Cung kỵ) hoặc `DIRECTION` (Kỵ binh xung phong) |
| `offset: Vector2i` | `CELL`: ô đích = vị trí chủ đòn + offset. `DIRECTION`: vector hướng (B/Đ/N/T) |
| `order: int` | Số thứ tự ra đòn hiển thị trên bàn |

**Luồng dữ liệu:**
1. Pha chuẩn bị: AI chọn ô đứng, rồi tạo `Telegraph`.
2. Người chơi đẩy hoặc kéo chủ đòn. Ô đích tự dịch theo, và lõi luật phát sự kiện `TELEGRAPH_SHIFTED` để phần trình bày vẽ lại.
3. Nếu ô đích mới nằm ngoài bàn, đòn bị hủy (sự kiện `TELEGRAPH_CANCELLED`).
4. Pha ra đòn: đòn được tính theo vị trí **lúc ra đòn**.

```gdscript
# src/core/telegraph.gd
class_name Telegraph
extends RefCounted

enum Kind { CELL, DIRECTION }

var owner_id: int
var kind: Kind
var offset: Vector2i
var order: int

func target_cell(state: BattleState) -> Vector2i:
    return state.unit_by_id(owner_id).cell + offset    # chỉ dùng cho CELL
```

#### M2. Ống phân giải luật (resolution pipeline)

**Vấn đề cần giải quyết:** một đòn có thể gây ra cả một chuỗi hệ quả: sát thương → đẩy → va chạm → rơi xuống sông hoặc dẫm hầm chông → đòn dịch theo → gục → kiểm tra thắng/thua. Mọi phiên AI phải áp dụng chuỗi này **theo cùng một thứ tự**.

**Luật cứng:**
- **Chỉ có 2 hàm được phép đổi máu và vị trí:**
  - `Effects.damage(state, unit, amount, cause, events)` là nơi **duy nhất** được sửa máu và xử lý gục.
  - `Effects.move(state, unit, to_cell, cause, events)` là nơi **duy nhất** được sửa vị trí. Hàm này áp luôn hiệu ứng của ô vừa đi vào (hầm chông, sông).
- **Di chuyển cưỡng bức** (đẩy, kéo) đi **từng ô một**, qua hàm `ForcedMove.run(...)`. Không được nhảy thẳng tới ô đích.
- Mọi hàm luật nhận `events: Array[BattleEvent]` rồi `append` vào đó. Không hàm nào tự tạo danh sách sự kiện riêng.
- Đòn đi từng ô qua mọi ô trên đường; đẩy một ô hay kéo nhiều ô đều dùng chung một vòng lặp.

```gdscript
# src/core/rules_attack.gd (trích)
static func khoai_strike(state: BattleState, khoai: Unit, cell: Vector2i, events: Array[BattleEvent]) -> void:
    var target := state.unit_at(cell)
    if target == null:
        return
    var dmg := state.stats.damage(khoai.type) + state.sat_that_bonus()
    Effects.damage(state, target, dmg, BattleEvent.Cause.STRIKE, events)
    if target.is_alive():
        ForcedMove.run(state, target, Grid.dir_between(khoai.cell, cell),
                state.stats.push_distance(khoai.type), BattleEvent.Cause.PUSH, events)
```

#### M3. Kịch bản luật là spec (quy trình)

Mọi luật đều đi qua đúng quy trình này. Không có ngoại lệ.

1. Luật được chốt (từ GDD hoặc từ quyết định của tác giả).
2. AI viết **kịch bản** trong `tests/kich_ban/<nhóm>/`: ít nhất một ca thường và mọi ca biên đã biết.
3. **Tác giả duyệt**, trả lời đúng hoặc sai. Kịch bản sai thì sửa kịch bản, không sửa code.
   - Duyệt bằng `tools/xem_kich_ban.sh` trên terminal: script in các kịch bản chưa duyệt, mỗi kịch bản có bàn trước và bàn sau đặt cạnh nhau, kèm một dòng mô tả tiếng Việt.
   - Duyệt theo đợt nhỏ, mỗi story luật một đợt (5–8 kịch bản), trước khi viết code.
4. Chạy `tools/test.sh`. Kịch bản mới phải **trượt** (vì luật chưa có code).
5. AI viết code cho tới khi `tools/test.sh` đạt toàn bộ.
6. **Không bao giờ xóa hay sửa kịch bản đã duyệt** để làm cho test đạt. Muốn đổi luật thì quay lại bước 1.
   - Kịch bản đã duyệt có cờ `"da_duyet": true`. `tools/test.sh` so với commit trước: file đã duyệt bị thay đổi thì báo **trượt**, ghi rõ tên file.
7. Khi tác giả gửi báo lỗi F2, việc đầu tiên là viết kịch bản tái hiện lỗi, rồi mới sửa.

### Bảng thứ tự phân giải (spec luật, bổ sung cho GDD)

**Di chuyển cưỡng bức (đẩy, kéo).** Lặp từng ô, cho tới khi đi hết khoảng cách hoặc bị dừng:

| Ô tiếp theo là | Kết quả |
|---|---|
| Ngoài bàn (mép) | Dừng. Quân bị đẩy **mất 1 máu** |
| Rừng `#` hoặc kho lương `L` | Dừng. Quân bị đẩy **mất 1 máu** (vật cản không có máu) |
| Làng `D` | Dừng. Quân bị đẩy **mất 1 máu**, và **Lòng dân −1** (kể cả khi người chơi gây ra). Phần "dừng, mất 1 máu" có từ Story 2.1; Lòng dân −1 thêm ở Story 3.7 |
| Có quân khác (bất kể phe) | Dừng. **Cả hai mất 1 máu**: quân bị đẩy mất máu trước, quân bị va sau (thứ tự sự kiện) |
| Sông `~` | Quân Nguyên: vào ô và **chết đuối**. Tướng: tính như va chạm, dừng, mất 1 máu |
| Hầm chông `^` | Vào ô, **mất 1 máu** (kể cả khi chỉ đi ngang qua). Gục thì dừng tại đó |
| Ô trống | Vào ô, đi tiếp |

- "Mất 1 máu" khi va là luật cố định của GDD: hằng số `ForcedMove.COLLISION_DAMAGE`, không nằm trong `chi_so.json` (tác giả chốt 2026-10-18). Sát Thát không cộng vào.
- Kéo một mục tiêu đã đứng kề Trần Khánh Dư: không có gì xảy ra (theo GDD).
- Sau khi di chuyển xong, đòn của quân đó tự dịch theo (M1). Ô đích nằm ngoài bàn thì đòn bị hủy. **(mặc định)**

**Tự đi (tướng và quân Nguyên):**
- Đi vào **mọi ô hầm chông** trên đường đều mất 1 máu. Gục giữa đường thì dừng tại đó.
- Tướng: người chơi bấm ô đích, game chọn đường **ít hầm chông nhất**; hòa thì chọn theo thứ tự hướng B→Đ→N→T. Ô sáng và đường đi phải hiện số máu sẽ mất. **(mặc định)**
- Quân Nguyên: đi đường ngắn nhất, **không tránh hầm chông**, hòa thì theo B→Đ→N→T (theo GDD: AI "ngây thơ").

**Đòn của tướng.** Thứ tự xử lý: kiểm tra hợp lệ → sát thương → nếu mục tiêu còn sống thì đẩy hoặc kéo → kiểm tra thắng/thua.

| Tướng | Luật |
|---|---|
| Nguyễn Khoái | Đánh 1 ô kề có quân Nguyên, gây sát thương rồi đẩy 1 ô theo hướng đánh. Mục tiêu gục vì sát thương thì không đẩy |
| Phạm Ngũ Lão | Thẳng hàng. **Bay qua ô kề**, rồi trúng vật đầu tiên ở các ô từ thứ 2 đến thứ 4. Rừng, kho lương hoặc làng **ở bất kỳ ô nào trên đường, kể cả ô kề**, đều chặn lao **(mặc định)**; lao bị làng chặn thì **Lòng dân −1** **(mặc định)**. Sông không chặn. Viền "đánh được": mỗi hướng một viền, ở **quân Nguyên gần nhất** trong ô 2–4; tướng mình đứng chắn trước thì quân Nguyên sau nó vẫn có viền, bấm vào thì lao trúng tướng mình (tác giả chốt 2026-10-19) |
| Trần Khánh Dư | Chỉ kéo **vật đầu tiên trên hàng** trong vòng 3 ô, và vật đó phải là quân Nguyên. Vật đầu tiên là tướng, rừng, kho lương hoặc làng thì không kéo được **(mặc định; rừng, kho lương, làng làm ở Story 3.1)**. Kéo 2 ô theo bảng di chuyển cưỡng bức (`ForcedMove.run`, nguyên nhân `Cause.PULL`). 0 sát thương. Quân Nguyên **kề** Dư không có viền, bấm bị từ chối `ngoai_tam`, Dư không tính là đã đánh; quân **cách 2 ô** chỉ bị kéo 1 ô, dừng sát Dư, không va Dư (tác giả chốt 2026-10-20) |

**Chọn mục tiêu:** không được chọn tướng mình làm mục tiêu của đòn (chốt 2026-10-17). Bấm vào tướng mình luôn là lệnh chọn tướng. Tướng mình vẫn trúng đòn như hệ quả: lao trúng vật đầu tiên trên hàng, hoặc bị quân khác va vào.

**Mưu kế:**
- **Sát Thát:** trong **lượt người chơi** này, đòn **có sát thương > 0** của tướng được cộng 1. Sát thương do va chạm, hầm chông, mép bàn **không** được cộng.
- **Vườn không nhà trống:** mọi ô `L` thành `.`, rồi mọi quân Nguyên mất 1 máu, theo thứ tự `thu_tu_dich`. Từ đó đến hết trận, quân Nguyên không hồi máu.

**Pha địch:**

| Bước | Luật |
|---|---|
| 1a. Tiếp viện | Xử lý theo thứ tự trong file trận. Ô có quân đứng (**bất kể phe nào**): quân đó mất 1 máu, quân tiếp viện bị hủy |
| 1b. Chuẩn bị | Chạy cả ở hiệp 1, trước lượt đầu của người chơi (lệnh nội bộ `BEGIN_BATTLE`, Story 2.6). Từng quân theo thứ tự (quân cũ theo `thu_tu_dich`, rồi tới quân tiếp viện theo thứ tự xuất hiện): đi, rồi báo đòn. Gục trên hầm chông khi đang đi thì không báo đòn. **Mục tiêu:** tướng gần nhất theo số bước đi (đi xuyên quân Nguyên khác; sông, rừng, kho lương, làng, tướng khác chặn); hòa thì tướng **ít máu hơn**, rồi phía Bắc hơn, rồi phía Đông hơn; tướng không có đường tới thì bỏ qua. **Ô đứng:** trong tầm đi (kể cả đứng yên), ô mà từ đó đòn trúng mục tiêu, cần **ít bước nhất**; hòa thì Bắc, rồi Đông. Bộ binh: ô kề; Kỵ binh: cùng hàng/cột, giữa không có quân, rừng, kho lương, làng (sông không chắn), không giới hạn xa. **Không có ô như vậy:** đi tới ô gần mục tiêu nhất (số bước; hòa thì ít bước đi hơn, Bắc, Đông) và **không báo đòn**; số thứ tự chỉ đếm quân có đòn. Không có đường tới tướng nào: đứng yên (tác giả chốt 2026-10-21). Trận Tiêu diệt có làng: Bộ binh và Kỵ binh nhắm tướng hoặc làng gần nhất, hòa thì ưu tiên làng **(mặc định)**; Cung kỵ chỉ nhắm tướng |
| 3. Ra đòn | Theo số thứ tự đã báo. Chủ đòn đã gục thì đòn bị hủy. Đòn địch chỉ gây sát thương, không đẩy |
| Kỵ binh | Đứng yên, trúng vật đầu tiên theo hướng đã báo. Rừng/kho lương chặn (trúng vật cản thì không ai mất máu). Trúng làng thì **Lòng dân −1**. Sông không chặn. Hàng trống tới mép thì **trượt** **(mặc định)** |
| Cung kỵ | Ô đích phải **thẳng hàng**, cách 2–3 ô **(mặc định)**. Tên bay qua quân; chỉ rừng, kho lương hoặc làng nằm giữa mới chặn. Bị làng chặn thì **Lòng dân −1** **(mặc định)** |
| Bộ binh | Đánh 1 ô kề. Ô đó là làng thì **Lòng dân −1** |
| 4. Cuối hiệp | Quân Nguyên kề **ít nhất một** kho lương hồi 1 máu (tối đa 1 mỗi hiệp, không vượt máu tối đa). Sau đó báo tiếp viện cho hiệp sau. Trận có `so_hiep_toi_da`: nếu đây là hiệp cuối mà còn quân Nguyên thì **thua** **(mặc định)** |

**Hủy nước đi:**
- Chỉ hủy được **nước đi gần nhất**, đúng **một** nước: hủy xong phải đi nước mới mới hủy tiếp được (tác giả chốt 2026-10-18). Chỉ khi tướng đó **chưa đánh**. Muốn quay lại xa hơn thì dùng "Chơi lại hiệp". Kết thúc lượt cũng xóa bản chụp hủy.

**Gục, thắng, thua:**
- Quân Nguyên gục thì bị nhấc khỏi bàn. **Tướng gục cũng bị nhấc khỏi bàn**, không chiếm ô. **(mặc định)** **[KIỂM TRA KHI PLAYTEST E4]**: phương án thay thế là để xác lại làm vật cản.
- Kiểm tra thắng/thua **sau mỗi sự kiện gây gục**, cả trong lượt người chơi lẫn trong pha địch. Cài đặt (Story 2.5): `RulesVictory.check` gọi ở **cuối `Rules.resolve`** (và từ Story 2.8 sau từng đòn địch), chỉ khi lệnh có `DIED` hoặc `DROWNED`; kết cục xét theo trạng thái cuối lệnh; ghi vào `BattleState.phase` (`WON`/`LOST`) và sự kiện `VICTORY`/`DEFEAT`.
- Trận Tiêu diệt phải có ít nhất một quân Nguyên trong `quan`, nếu không `LevelLoader` báo lỗi (tác giả chốt 2026-10-20, review Story 2.5): bàn trống quân Nguyên thì lần gục đầu tiên cho thắng ngay.
- **Hết trận thì khóa** (tác giả chốt 2026-10-20): khi `phase` là `WON`/`LOST`, mọi lệnh và cả Hủy bị từ chối với `Reject.BATTLE_OVER` (mã kịch bản `tran_da_het`).
- Thắng và thua xảy ra cùng lúc (ví dụ quân Nguyên cuối cùng và tướng cuối cùng cùng gục vì va chạm): **thắng được ưu tiên**. **(mặc định)**
- Giữ ải: quân Nguyên vào ô ải **bằng bất kỳ cách nào**, kể cả do bị người chơi kéo vào, thì thua ngay. **(mặc định)**
- Giữ ải: thắng khi kết thúc bước 4 của hiệp 5.
- Lòng dân về 0 thì **thua ngay**. Kiểm tra **sau mỗi lần mất Lòng dân**, cả trong lượt người chơi lẫn pha địch; trùng với thắng thì thắng được ưu tiên.
- Tiêu diệt có `so_hiep_toi_da`: kết thúc bước 4 của hiệp cuối mà còn quân Nguyên thì thua. Quân Nguyên chết vì đánh trúng nhau trong pha ra đòn của hiệp cuối vẫn tính. **(mặc định)**

### Mẫu giao tiếp

- **Đi xuống thì gọi hàm trực tiếp, đi lên thì phát signal.** Cha gọi hàm của con; con báo lên cha bằng signal.
- Lõi luật không phát signal và không gọi autoload.
- Không dùng đường dẫn node tuyệt đối (`/root/...`). Node trong scene lấy bằng `%TênDuyNhất`.

```gdscript
# battle_view.gd (cha) gọi xuống con:
%Board.highlight_cells(reachable)
# battle_input.gd (con) báo lên:
signal command_requested(command: Command)
```

### Mẫu tạo đối tượng

- **Quân (dữ liệu):** chỉ tạo qua `UnitFactory.create(type, cell, stats)` trong `src/core/`. Id được cấp theo thứ tự: tướng 1–3; quân Nguyên từ 101 theo `thu_tu_dich`; quân tiếp viện lấy id tiếp theo.
- **Đồng quân (hiển thị):** `BoardView` tạo `UnitToken.new()` bằng code và giữ theo id. Mỗi lần vẽ lại thì so với bản chụp mới: thêm token cho quân mới, bỏ token của quân đã gục, giữ nguyên token còn lại. Không dùng object pool.

```gdscript
func _sync_tokens(snapshot: BattleState) -> void:
    for unit in snapshot.units:
        if not _tokens.has(unit.id):
            var t := UnitToken.new()
            t.setup(unit)
            %Units.add_child(t)
            _tokens[unit.id] = t
    for id in _tokens.keys():
        if snapshot.unit_by_id(id) == null:
            _tokens[id].queue_free()
            _tokens.erase(id)
```

### Mẫu trạng thái

- **Pha trận:** `enum Phase { ENEMY_PREPARE, PLAYER, ENEMY_ACT, END_OF_ROUND, WON, LOST }` nằm trong `BattleState`. Chỉ `rules_enemy_phase.gd` và `rules_victory.gd` được đổi pha.
- **Màn hình:** `enum Screen { MENU, BATTLE, TRANSITION, ERROR }` nằm trong `main.gd`.
- Không dùng StateMachine dạng Node, không dùng behavior tree.

```gdscript
static func end_player_turn(state: BattleState, events: Array[BattleEvent]) -> void:
    assert(state.phase == BattleState.Phase.PLAYER)
    _set_phase(state, BattleState.Phase.ENEMY_ACT, events)
    _execute_telegraphs(state, events)
    if state.phase in [BattleState.Phase.WON, BattleState.Phase.LOST]:
        return
    _end_of_round(state, events)
    _enemy_prepare(state, events)     # mở hiệp mới; xong thì về PLAYER
```

### Mẫu truy cập dữ liệu

- File chỉ được nạp **một lần**, tại `src/data/`, rồi biến thành đối tượng chỉ đọc (`Stats`, `LevelData`, `CampaignData`).
- Lõi luật **nhận dữ liệu qua tham số** (`state.stats`). Lõi không bao giờ tự đọc file hay hỏi autoload.
- UI lấy dữ liệu từ `AppState` (autoload duy nhất).
- F5 nạp lại dữ liệu bằng cách tạo đối tượng mới rồi khởi động lại trận, không sửa đối tượng cũ.

```gdscript
var r := LevelLoader.load_level("res://data/tran/tran_03.json", AppState.stats)
if not r.ok:
    main.show_error(r.errors)
    return
battle_controller.start(r.data)
```

### Mẫu git

Tác giả không dùng git trực tiếp. AI lo toàn bộ phần git:
- **Chỉ commit khi `tools/test.sh` xanh**, và commit **sau mỗi lần xanh**. Không bao giờ commit khi test đang đỏ.
- Lời commit viết tiếng Việt, ghi rõ luật hoặc tính năng vừa xong (ví dụ: `Thêm luật kéo của Trần Khánh Dư (kịch bản keo/01–05)`).
- Mỗi commit là một điểm "còn chạy được". Khi tác giả nói "quay về bản trước", AI quay về commit xanh gần nhất.
- Khóa `da_duyet` (M3) so với commit gần nhất, nên mẫu này là điều kiện để khóa có tác dụng.

### Luật nhất quán

| Mẫu | Quy ước | Kiểm tra bằng |
|---|---|---|
| Ranh giới lõi | `src/core/` không Node, không I/O, không ngẫu nhiên | `tools/check_boundaries.sh` |
| Sửa máu, vị trí | Chỉ qua `Effects.damage` / `Effects.move` | `check_boundaries.sh` bắt `=`, `+=`, `-=` trên `.hp` / `.cell`, và mọi chỗ sửa trực tiếp `units`, nằm ngoài `effects.gd` |
| Tất định | Duyệt quân theo `order`, không duyệt theo khóa Dictionary; luật không dùng `float` | Kịch bản chạy hai lần phải ra cùng kết quả (`test_determinism.gd`) |
| Đòn đã báo | Luôn lưu tương đối (M1) | Kịch bản trong `don_dich/` |
| Sự kiện | Mọi thay đổi trạng thái đều sinh sự kiện; dùng enum, không dùng chuỗi | Review + kịch bản |
| Con số cân bằng | Chỉ nằm trong `chi_so.json` | Review |
| Chữ hiển thị | Chỉ qua `tr()` | Review |
| Kịch bản đã duyệt | Không xóa, không sửa để test đạt | Cờ `da_duyet`, kiểm tra bởi `tools/test.sh` |
| Gõ kiểu | Bắt buộc ở mọi nơi | Cảnh báo `untyped_declaration` = error |
| Commit | Chỉ khi test xanh, sau mỗi lần xanh | Mẫu git |
| Dung lượng web | Bản nén ≤ 25MB | `tools/build_web.sh` báo trượt nếu vượt |
| Thuật ngữ | *Hiệp* ≠ *lượt người chơi* | Review |

### Việc kèm theo
- **Cập nhật GDD:** thêm các luật trong bảng thứ tự phân giải (4 luật tác giả đã chốt ngày 2026-10-16 và các mục **(mặc định)** sau khi được duyệt), cùng tính năng xem trước kết quả đòn (ADR-005).

## Kiểm tra kiến trúc

### Tóm tắt kết quả

| Hạng mục | Kết quả | Ghi chú |
|---|---|---|
| Các quyết định khớp nhau | Đạt | Godot 4.7.2, GDScript, web đơn luồng, lõi luật thuần dữ liệu và test bằng kịch bản không mâu thuẫn |
| Phủ GDD | Đạt | 19/19 hệ thống có vị trí trong cây thư mục |
| Đủ các mẫu triển khai | Đạt | Tạo đối tượng, giao tiếp, trạng thái, xử lý lỗi, truy cập dữ liệu, sự kiện, git, thuật ngữ |
| Mỗi epic có chỗ trong kiến trúc | Đạt, kèm ghi chú | E1–E4 khớp. E0 cần đổi tên và nội dung (xem dưới) |
| Tài liệu đầy đủ | Đạt | Đã sửa 4 chỗ chữ lỗi thời; không còn chỗ trống |

### Số liệu

- **Hệ thống được phủ:** 19/19
- **Quyết định:** 23 (ADR-001 đến ADR-006)
- **Mẫu triển khai:** 3 mẫu mới (M1 đòn tương đối, M2 ống phân giải, M3 kịch bản là spec) + 6 mẫu chuẩn (giao tiếp, tạo đối tượng, trạng thái, truy cập dữ liệu, git, thuật ngữ)

### Vấn đề đã xử lý

1. Sửa chữ lỗi thời: phiên bản engine, độ phân giải, trạng thái tính năng xem trước, danh sách phím dev (F2, F3).
2. Thêm **mẫu git**: AI commit sau mỗi lần `tools/test.sh` xanh; không commit khi đỏ. Đây là điều kiện để khóa `da_duyet` có tác dụng.
3. `tools/build_web.sh` báo trượt nếu bản nén vượt 25MB.
4. Thêm **thuật ngữ**: *hiệp* ≠ *lượt người chơi*. Sửa câu Sát Thát cho rõ.

### Ghi chú cho bước làm epics

- **E0 đổi từ "Học Godot" thành "Dựng nền":** tạo project, cài GUT, viết các script trong `tools/`, cài MCP, xuất thử web lên itch.io.
  - **Xong khi:** `tools/test.sh` chạy được; link itch.io mở được bàn cờ trống trên trình duyệt; bản để **riêng tư** cho tới khi tác giả quyết công khai.
- **E1 "Hủy nước đi":** theo luật đã chốt, chỉ hủy nước đi gần nhất của tướng chưa đánh. Từ E2: đánh hoặc dùng mưu kế thì xóa bản chụp hủy.
- **Còn treo, đã có chỗ xử lý:** các luật **(mặc định)** được duyệt qua `tools/xem_kich_ban.sh` ở đợt kịch bản E2–E3; "tướng gục bị nhấc khỏi bàn" kiểm tra khi playtest E4.

### Ngày kiểm tra

2026-10-16

## Môi trường phát triển

### Cần cài
- Godot **4.7.2.stable** (bản standard) và export template 4.7.2
- Node.js 18+ (cho GoPeak)
- git
- `butler` và tài khoản itch.io (dùng để đẩy bản web lên)

### Công cụ AI (MCP)

| MCP | Dùng để | Cài |
|---|---|---|
| GoPeak 2.3.8 (profile `compact`) | Xem log, chẩn đoán, chụp màn hình, bơm input vào game đang chạy | npm (ghim phiên bản) + addon trong `game/addons/` |
| Context7 | Tra tài liệu Godot 4.7 | MCP server |

### Bước đầu tiên (E0)
1. AI tạo project trống trong `game/`, cài GUT v9.7.1 và viết các script trong `tools/`.
2. AI cài GoPeak và Context7.
3. Chạy `tools/test.sh`: phải in ra được kết quả tiếng Việt, lúc này 0 test.
4. Chạy `tools/build_web.sh`, rồi `tools/deploy_itch.sh`: link itch.io (riêng tư) mở được bàn cờ trống.
