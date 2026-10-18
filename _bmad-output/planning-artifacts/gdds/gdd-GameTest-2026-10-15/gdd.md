---
title: 'Chống Nguyên Mông (tên tạm): Game Design Document'
game_type: 'turn-based-tactics + roguelike'
platforms: ['web (HTML5)', 'itch.io', 'PC/Steam (về sau)']
status: final
created: '2026-10-15'
updated: '2026-10-18'
inputs:
  - _bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/brief.md
  - _bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/addendum.md
---

# Chống Nguyên Mông (tên tạm): Game Design Document

**Tác giả:** Trung.nguyen11
**Thể loại:** Tactics theo lượt kết hợp roguelite
**Nền tảng:** Web (HTML5) / itch.io → PC/Steam (về sau)

---

## Executive Summary

**Một câu:** Bạn là Trần Hưng Đạo, giải từng thế trận chống đại quân Nguyên Mông, trên đường dẫn tới Bạch Đằng.

### Vision and Core Feel
**Cảm giác cốt lõi là Hào khí Đông A.** Trong trận, người chơi cân não và thắng nhờ cái đầu. Hào khí không nằm ở cơ chế, nên không phải là trụ cột. Nó đến từ phần trình bày bao quanh trận đánh:
- tiếng trống trận;
- những câu trích *Hịch tướng sĩ* giữa các trận;
- cảm giác cả một dân tộc đứng sau lưng mình;
- trận Bạch Đằng ở cuối.

Prototype chưa cần có hào khí (chỉ kiểm chứng combat). Từ giai đoạn 1, hào khí do E8 (hình ảnh, âm thanh) và phần Narrative gánh.

### Core Concept
Game tactics roguelite 2D, đánh theo lượt. Người chơi vào vai Trần Hưng Đạo, đứng ngoài bàn cờ chỉ huy 2–3 tướng có thật. Mỗi trận là một bài toán: địch luôn báo trước nước đi, người chơi dùng địa hình (sông nước, cọc gỗ, vườn không nhà trống) và các mưu kế của Trần Hưng Đạo để phá thế trận. Một lượt chơi đi trọn một cuộc kháng chiến. Bản đầu tiên là cuộc kháng chiến 1288, kết thúc ở trận Bạch Đằng.

### Target Audience
- **Chính:** người Việt mê sử. Họ đã đọc về các cuộc kháng chiến chống Nguyên Mông, muốn tự tay đánh lại những trận đó, và khắt khe với chuyện sai sử. Tiếp cận chủ yếu qua bản web miễn phí và các cộng đồng lịch sử.
- **Phụ (về sau):** người chơi tactics quốc tế, cần có bản tiếng Anh và phát hành trên Steam.

### Unique Selling Points (USPs)
1. Game chiến thuật đầu tiên cho người Việt tự tay đánh lại các trận chống Nguyên Mông, với tướng thật và trận thật.
2. Có những luật và mưu kế chỉ thời Trần mới có: thủy triều kết hợp bãi cọc (giai đoạn 1), vườn không nhà trống (prototype dùng như mưu kế trong một trận; lớp roguelite có thể cho hiệu ứng kéo dài sang các trận sau, làm quân Nguyên yếu dần).
3. Combat tất định: địch báo trước nước đi, không có may rủi. Về độ sâu combat, game không định vượt Into the Breach.

---

## Goals and Context

### Project Goals
1. **Kiểm chứng (khoảng 3,5 tháng, khoảng 140 giờ):** làm prototype combat và trả lời câu hỏi "giải thế trận này có vui không?". Người thử là người thân.
2. **Phát hành (giai đoạn 1):** bản web miễn phí, trọn cuộc kháng chiến 1288, đưa lên itch.io và các cộng đồng mê sử.
3. **Mở rộng (giai đoạn 2):** thêm các cuộc kháng chiến 1258 và 1285, bản tiếng Anh, phát hành trên Steam.

### Background and Rationale
Đây là dự án đam mê của một lập trình viên web chưa từng làm game, không vẽ, không làm nhạc, mỗi tuần dành khoảng 10 giờ, ngân sách vài trăm USD. Engine là Godot. Research thị trường cho thấy tactics roguelite là thể loại hẹp nhưng có tỷ lệ thành công cao hơn mức trung bình, và chưa có game nào khai thác bối cảnh Trần–Nguyên. Nguồn: brief và addendum.

Mục tiêu là làm xong một game mình tự hào, không phải tối đa doanh thu. Steam chỉ có khoảng 0,25% người dùng tiếng Việt và bị chặn một phần ở Việt Nam, nên kênh chính cho khán giả Việt là bản web miễn phí.

### References
| Game | Lấy | Không lấy |
|---|---|---|
| *Into the Breach* | Địch báo trước đòn, combat tất định, bàn nhỏ, đẩy/kéo và va chạm | Độ sâu combat (không định vượt) |
| *Shogun Showdown* | Trận ngắn, ít đơn vị, bối cảnh lịch sử châu Á | — |
| *Slay the Spire* | Bản đồ nút chia chặng, phần thưởng chọn 1 trong 3 | Bộ bài, may rủi khi rút bài |


## Core Gameplay
### Game Pillars
1. **Thấy trước, tính được.** Địch luôn báo trước nước đi. Không có xúc xắc hay tỷ lệ trúng. Thua là do người chơi tính sai.
2. **Địa hình là vũ khí.** Cách đánh của nhà Trần (sông nước, cọc gỗ, vườn không nhà trống) là luật chơi, không phải hình nền. Phần lớn chiến thắng đến từ việc dùng địa hình, không chỉ từ sát thương trực tiếp.
3. **Tôn trọng lịch sử.** Tướng, trận và thời điểm đều có thật. Phần hư cấu được ghi rõ. Lịch sử kể ngắn giữa các trận.
4. **Nhỏ mà xong.** Tính năng nào không làm xong trong khoảng 10 giờ thì cắt bỏ hoặc chia nhỏ ra.
### Core Gameplay Loop
- **Trong trận (vài phút):** địch báo trước ý định → người chơi di chuyển và hành động với 2–3 tướng, dùng địa hình → chọn thời điểm tung mưu kế của Trần Hưng Đạo → địch thực hiện đúng ý định đã báo → lặp lại cho đến khi thắng hoặc thua.
- **Một lượt chơi (30–60 phút):** chọn đường trên bản đồ cuộc kháng chiến → đánh trận hoặc gặp sự kiện lịch sử → nhận thưởng (tướng, mưu kế, hồi phục) → trận cuối (Bạch Đằng với cuộc kháng chiến 1288).
- **Giữa các lượt chơi:** mở khóa tướng, mưu kế và cuộc kháng chiến tiếp theo (1258 → 1285 → 1288). Phần này *chi tiết hóa sau prototype*.
### Win/Loss Conditions

| Kiểu nhiệm vụ | Thắng | Thua |
|---|---|---|
| **Tiêu diệt** | Hạ hết quân Nguyên trên bàn (không có tiếp viện) | Mọi tướng trên bàn đều gục; hoặc hết số hiệp tối đa mà còn quân Nguyên (trận có giới hạn hiệp); hoặc Lòng dân về 0 (trận có làng) |
| **Giữ ải** | Qua hết **5 hiệp** mà không quân Nguyên nào bước vào ô ải (đánh dấu ở mép bàn phía nhà Trần) | Mọi tướng trên bàn đều gục, hoặc một quân Nguyên bước vào ô ải |

- Tướng còn 0 máu thì gục và không hành động được nữa trong trận đó. Tướng gục bị nhấc khỏi bàn, không chiếm ô. [MẶC ĐỊNH, duyệt qua kịch bản luật] [KIỂM TRA KHI PLAYTEST E4] Phương án thay thế: để xác lại làm vật cản.
- Kiểm tra thắng/thua sau mỗi lần có quân gục, cả trong lượt người chơi lẫn trong pha địch. Nếu thắng và thua xảy ra cùng lúc thì **thắng được ưu tiên**. [MẶC ĐỊNH, duyệt qua kịch bản luật]
- Giữ ải: quân Nguyên vào ô ải **bằng bất kỳ cách nào** (kể cả bị người chơi kéo vào) thì thua ngay. [MẶC ĐỊNH, duyệt qua kịch bản luật]
- **Giới hạn hiệp** (trận Tiêu diệt, từ trận 3): file trận ghi số hiệp tối đa; không ghi thì không giới hạn. Thua khi kết thúc bước cuối hiệp của hiệp cuối mà còn quân Nguyên trên bàn; quân Nguyên chết vì đánh trúng nhau trong pha ra đòn của hiệp cuối vẫn tính. [MẶC ĐỊNH, duyệt qua kịch bản luật] Chốt 2026-10-17.
- **Lòng dân** (trận có làng, từ trận 4): điểm chung của cả trận, ghi trong file trận (ví dụ 3). Mỗi lần làng bị trúng thì −1 (xem Terrain). Về 0 thì thua ngay; trùng với thắng thì thắng được ưu tiên. "Chơi lại hiệp" trả lại cả Lòng dân. Chốt 2026-10-17.
- Trong prototype, sau mỗi trận các tướng được hồi đầy máu.
- Luật tướng gục trong lượt chơi roguelite: xem Permadeath and Progression.
- Một lượt chơi roguelite thắng khi hạ được trận cuối (Bạch Đằng), thua khi thua bất kỳ trận nào.

## Game Mechanics
### Primary Mechanics

| Cơ chế | Mô tả | Phục vụ trụ cột |
|---|---|---|
| **Báo trước đòn đánh** | Mọi đòn của quân Nguyên được hiển thị trước một pha: ô hoặc hướng bị nhắm, kèm số thứ tự ra đòn. | Thấy trước, tính được |
| **Đẩy, kéo, va chạm** | Đòn của Nguyễn Khoái đẩy, đòn của Trần Khánh Dư kéo. Va chạm với quân khác hoặc vật cản làm cả hai mất 1 máu. Đây là cách chính để dùng địa hình. | Địa hình là vũ khí |
| **Đánh vào ô** | Đòn địch gắn với ô, không gắn với người, nên có thể né, có thể làm lệch, và địch có thể đánh trúng nhau. | Thấy trước, tính được |
| **Địa hình gây hiệu ứng** | Sông, rừng, hầm chông, kho lương (xem phần Terrain). | Địa hình là vũ khí, Tôn trọng lịch sử |
| **Mưu kế của Trần Hưng Đạo** | Mỗi mưu kế dùng 1 lần mỗi trận, dùng được bất cứ lúc nào trong lượt người chơi, không tốn hành động của tướng. Prototype có 2 mưu kế (bảng dưới). | Tôn trọng lịch sử |
| **Hoàn tác** | Hủy **nước đi gần nhất**, khi tướng đó chưa đánh; đánh hoặc dùng mưu kế thì xóa lịch sử hủy. Chơi lại hiệp: 1 lần mỗi trận. | Thấy trước, tính được |
| **Xem trước kết quả đòn** | Khi rê chuột lên mục tiêu của một đòn, game hiện bóng mờ vị trí cuối của các quân bị ảnh hưởng và số máu sau đòn. Có từ E2 (bản tối giản), trau chuốt ở E4. Chốt 2026-10-16. | Thấy trước, tính được |

**Mưu kế trong prototype:**

| Mưu kế | Hiệu ứng | Cảm hứng lịch sử |
|---|---|---|
| **Sát Thát** | Trong **lượt người chơi** này, mọi đòn đánh *có gây sát thương* của tướng được **+1 sát thương**. Đòn kéo của Trần Khánh Dư không được cộng. Sát thương do va chạm, hầm chông, mép bàn cũng không được cộng. | Quân sĩ thích hai chữ "Sát Thát" lên cánh tay |
| **Vườn không nhà trống** | Đốt toàn bộ kho lương trên bàn: các ô kho lương thành ô trống, đi vào được. Mọi quân Nguyên trên bàn **mất 1 máu**. Từ đó đến hết trận, quân Nguyên không hồi máu được nữa. | Chiến lược vườn không nhà trống năm 1285 và 1288 |

[KIỂM TRA KHI PLAYTEST E4] Đã chốt giữ nguyên (2026-10-16). "Vườn không nhà trống" hạ ngay mọi Cung kỵ (chỉ có 1 máu). Nếu playtest thấy quá mạnh, đổi thành "mất 1 máu, nhưng không làm quân địch chết, tối thiểu còn 1 máu".

Mưu kế để dành cho lớp roguelite (chưa có trong prototype): Rút lui chiến thuật, Nghi binh.
### Controls and Input
**Nền tảng:** web trên máy tính, dùng chuột. Có phím tắt.

| Thao tác | Chuột | Phím tắt |
|---|---|---|
| Chọn tướng | Bấm vào tướng | `1` `2` `3` |
| Đi | Bấm vào ô sáng | — |
| Đánh | Bấm vào ô hoặc mục tiêu trong tầm. Tướng đã đi rồi thì bấm thêm lần nữa để xác nhận | — |
| Xem thông tin | Rê chuột lên quân (hiện máu, đòn sắp đánh, thứ tự ra đòn) hoặc lên ô (hiện địa hình) | — |
| Dùng mưu kế | Bấm nút mưu kế | `Q` `W` |
| Hủy nước đi | Nút Hủy | `Z` |
| Kết thúc lượt | Nút Kết thúc | `Space` |
| Chơi lại hiệp | Nút Chơi lại | `R` |

Không có thao tác kéo thả. Mọi thao tác đều là bấm, nên sau này làm bản cảm ứng sẽ không phải thiết kế lại.

## Turn-Based Tactics Specific Design
### Grid System and Movement
- **Lưới:** ô vuông, **7×7** (cho prototype; các trận về sau có thể khác kích thước).
- **Di chuyển:** 4 hướng, không đi chéo. Khoảng cách tính bằng số ô (Manhattan).
- **Tầm đi:** tướng **3 ô**, quân Nguyên **2–3 ô** tùy loại (xem Unit Types).
- **Chi phí địa hình:** không có. Mỗi ô hoặc đi được, hoặc bị chặn. Địa hình tác động bằng *hiệu ứng*, không bằng chi phí di chuyển.
- **Cản đường:** được đi xuyên qua ô có quân mình, không được đi xuyên qua ô có quân địch. Không có vùng khống chế, không có đòn đánh khi địch rời ô kề.
- **Độ cao, tầm nhìn:** không có. Toàn bộ bàn cờ luôn hiển thị.
- **Hiển thị đường đi:** khi chọn tướng, tô sáng các ô đi tới được. Khi rê chuột lên một ô, hiện đường đi.
- **Chọn đường của tướng:** người chơi bấm ô đích, game tự chọn đường **ít hầm chông nhất**; hòa thì theo thứ tự hướng B→Đ→N→T. Ô sáng và đường đi hiện số máu sẽ mất. [MẶC ĐỊNH, duyệt qua kịch bản luật]
- **Phạm vi prototype:** chỉ đánh trên bộ. Sông là ô bị chặn với mọi quân. Thuyền và thủy chiến để sau.
### Unit Types and Classes

**Tướng nhà Trần.** Người chơi điều khiển tối đa 3 tướng (trận 1–2 của prototype chỉ có 2 tướng, xem Campaign Structure). Mỗi tướng có 3 máu và đi được 3 ô. Mỗi tướng giữ một vai riêng, không trùng nhau.

| Tướng | Vai | Đòn chính | Ý đồ chiến thuật |
|---|---|---|---|
| **Nguyễn Khoái** | Tiên phong (cận chiến) | Đánh 1 ô kề, **2 sát thương**, đẩy mục tiêu lùi **1 ô** theo hướng đánh | Đẩy địch vào chướng ngại, vào bẫy hoặc vào nhau |
| **Phạm Ngũ Lão** | Phóng lao (đánh xa) | Phóng thẳng hàng, **bay qua ô kề**, trúng vật đầu tiên ở ô thứ **2–4**, **1 sát thương**. Rừng hoặc kho lương ở bất kỳ ô nào trên đường, kể cả ô kề, đều chặn lao [MẶC ĐỊNH, duyệt qua kịch bản luật]. Sông không chặn | Kết liễu từ xa. Gợi đến câu "Hoành sóc giang sơn" trong *Thuật hoài* |
| **Trần Khánh Dư** | Phục binh (khống chế) | Kéo **vật đầu tiên trên hàng** trong vòng **3 ô** về phía mình **2 ô** (dừng sớm nếu bị chặn), **0 sát thương**. Vật đó phải là quân Nguyên; nếu vật đầu tiên là tướng, rừng hoặc kho lương thì không kéo được [MẶC ĐỊNH, duyệt qua kịch bản luật] | Kéo địch khỏi vị trí đẹp hoặc kéo vào bẫy, làm lệch đòn địch đã báo trước |

**Nguồn sử của từng tướng** (chi tiết trong `history-notes-1288.md`):
- **Trần Khánh Dư:** *Toàn thư* chép rõ trận Vân Đồn, khi ông đánh tan đoàn thuyền lương.
- **Nguyễn Khoái:** *Toàn thư* chép ông chỉ huy quân Thánh dực ở Bạch Đằng.
- **Phạm Ngũ Lão:** *Toàn thư* không chép ông trong các năm 1287–1288. Trận phục kích ở ải Nội Bàng là **theo *Việt Nam sử lược***. Trong game phải ghi chú nguồn này.

[CHƯA KIỂM CHỨNG SỬ] Vai của từng tướng là trừu tượng hóa để phục vụ gameplay. Trước khi phát hành phải đối chiếu tiểu sử và vai trò năm 1287–1288 với tư liệu như *Đại Việt sử ký toàn thư*. Chi tiết nào thuộc truyền thuyết hay dã sử phải ghi rõ "theo truyền thuyết và dã sử".

[KIỂM TRA KHI PLAYTEST E4] Đã chốt tầm kéo 2 ô (2026-10-16). Nếu playtest thấy quá mạnh thì giảm xuống 1 ô.

**Quân Nguyên trong prototype.** Mọi đòn đánh của quân Nguyên đều được báo trước một lượt (xem Action Economy).

| Quân | Máu | Đi | Đòn đánh | Vai trò |
|---|---|---|---|---|
| **Kỵ binh Mông Cổ** | 2 | 3 | Xung phong thẳng hàng, **1 sát thương** vào vật đầu tiên trên đường. Hàng trống tới mép bàn thì trượt [MẶC ĐỊNH, duyệt qua kịch bản luật] | Đe dọa từ xa theo đường thẳng, buộc người chơi phải tránh khỏi hàng |
| **Cung kỵ** | 1 | 3 | Bắn vào ô đã nhắm, ô đó phải **thẳng hàng**, cách **2–3 ô** [MẶC ĐỊNH, duyệt qua kịch bản luật], **1 sát thương**. Tên bay qua quân; chỉ rừng hoặc kho lương nằm giữa mới chặn | Yếu máu, ưu tiên hạ trước |
| **Bộ binh Nguyên** | 3 | 2 | Chém 1 ô kề, **1 sát thương** | Trâu nhưng chậm. Thường phải xử lý bằng địa hình, khó hạ bằng sát thương |

**Tiến triển của unit:** chỉ có trong lượt chơi roguelite. Phần này *chi tiết hóa sau prototype*. Prototype không có lên cấp.
### Action Economy

**Trình tự một hiệp.** Hai bên đi luân phiên. Phe địch tách làm hai pha: chuẩn bị và ra đòn.
1. **Địch chuẩn bị.**
   - Quân tiếp viện đã báo ở hiệp trước xuất hiện trước tiên. Nếu ô đó có người đứng (**bất kể phe nào**), quân tiếp viện bị hủy và người đứng trên ô nhận **1 sát thương**.
   - Sau đó từng quân Nguyên (kể cả quân vừa xuất hiện) di chuyển rồi báo trước đòn đánh, theo luật ở mục *Enemy AI*. Ô bị nhắm được tô đỏ. Mỗi đòn có số thứ tự ra đòn (1, 2, 3…) hiển thị ngay trên bàn; số thứ tự là thứ tự các quân hành động.
2. **Lượt người chơi.**
   - Mỗi tướng được *đi* tối đa 3 ô, rồi *đánh* một lần. Có thể đánh mà không đi.
   - Tướng đã đánh thì không đi được nữa.
   - Ba tướng hành động theo thứ tự tùy ý.
   - Mưu kế của Trần Hưng Đạo dùng được bất cứ lúc nào trong lượt và không tốn hành động của tướng.
   - Bấm "Kết thúc lượt" để chuyển sang pha tiếp theo.
3. **Địch ra đòn.** Các đòn được thực hiện lần lượt theo đúng thứ tự đã báo.
4. **Cuối hiệp.**
   - Quân Nguyên đứng kề kho lương hồi 1 máu (nếu kho còn và chưa dùng *Vườn không nhà trống*).
   - Đánh dấu các ô sẽ có quân tiếp viện xuất hiện ở đầu hiệp sau.

**Luật then chốt: địch đánh vào ô, không đánh vào người.**
- Đòn đã báo gắn với một ô cố định. Riêng Kỵ binh gắn với một hướng cố định, tính từ vị trí của nó.
- Tướng rời khỏi ô bị nhắm thì né được đòn.
- Quân địch bị đẩy hoặc kéo vào ô bị nhắm sẽ ăn đòn của chính đồng đội.
- Quân đang chuẩn bị đánh mà bị đẩy sang ô khác thì đòn của nó dịch theo, giữ nguyên hướng và khoảng cách tương đối. Nếu đòn dịch ra ngoài bàn thì bị hủy. [MẶC ĐỊNH, duyệt qua kịch bản luật]
- Quân bị hạ trước lượt ra đòn của mình thì đòn đó bị hủy.
- **Mọi đòn trúng mọi người đứng trên ô bị nhắm**, không phân phe. Lao của Phạm Ngũ Lão, đòn đẩy của Nguyễn Khoái và đòn của địch đều có thể trúng tướng nhà Trần.
- **Không được chọn tướng mình làm mục tiêu.** Bấm vào tướng mình luôn là chọn tướng đó. Tướng mình chỉ trúng đòn như *hệ quả*: lao trúng vật đầu tiên trên hàng là tướng mình, hoặc quân bị đẩy/kéo va vào tướng mình. Chốt 2026-10-17.
- **Kỵ binh xung phong** thì đứng yên tại chỗ, đòn trúng vật đầu tiên trên hàng theo hướng đã báo. Sông không chặn đòn xung phong; rừng thì chặn.
- **Kéo mục tiêu đã đứng kề** Trần Khánh Dư thì mục tiêu đứng yên, không ai mất máu.

**Hoàn tác.**
- Chỉ hủy được **nước đi gần nhất**, và chỉ khi tướng đó chưa đánh. Muốn quay lại xa hơn thì dùng "chơi lại hiệp". [MẶC ĐỊNH, duyệt qua kịch bản luật]
- **Đánh hoặc dùng mưu kế thì xóa sạch lịch sử hủy.** Sau một đòn đánh hay một mưu kế, không hủy được nước đi nào trước đó. Chốt 2026-10-17.
- Được **"chơi lại hiệp này" 1 lần mỗi trận**: đưa bàn cờ về trạng thái đầu lượt người chơi, **kể cả trả lại mưu kế đã dùng trong lượt đó**. Chốt 2026-10-17.

**Không có:** đòn phản công, đòn đánh khi địch rời ô kề, giới hạn thời gian mỗi lượt.

### Enemy AI
AI phải tất định và đọc được: người chơi đoán được quân Nguyên sẽ làm gì mà không cần xem code.
- **Thứ tự hành động:** theo thứ tự cố định ghi trong file dữ liệu trận; quân tiếp viện hành động sau quân đã có trên bàn.
- **Mục tiêu:** tướng nhà Trần gần nhất (tính theo số bước đi). Trận *Giữ ải*: Kỵ binh và Bộ binh nhắm ô ải; Cung kỵ vẫn nhắm tướng gần nhất. Trận *Tiêu diệt* có làng: Kỵ binh và Bộ binh nhắm tướng **hoặc làng** gần nhất, hòa giữa tướng và làng thì ưu tiên làng [MẶC ĐỊNH, duyệt qua kịch bản luật]; Cung kỵ chỉ nhắm tướng. Chốt 2026-10-17.
- **Chọn ô đứng:** trong tầm đi, ưu tiên ô mà từ đó đòn trúng được mục tiêu. Không có ô như vậy thì đi tới ô gần mục tiêu nhất.
- **Hòa điểm:** chọn theo thứ tự hướng cố định Bắc → Đông → Nam → Tây.
- **Không có:** AI tránh ô đỏ của đồng đội, AI tránh địa hình nguy hiểm, AI phối hợp. Chính chỗ AI "ngây thơ" này tạo cơ hội cho người chơi dùng trụ cột *Địa hình là vũ khí*.
### Positioning and Tactics
- **Vị trí là tài nguyên chính.** Sát thương trực tiếp thấp (1–2), máu địch 1–3. Phần lớn quân địch bị hạ nhờ địa hình, va chạm, hoặc đòn của chính đồng đội chúng.
- **Thẳng hàng.** Lao, xung phong và kéo đều đi theo đường thẳng, nên việc đứng thẳng hàng hay lệch hàng mang ý nghĩa chiến thuật.
- **Không có:** đánh sườn, lợi thế độ cao, che chắn, đội hình, tầm nhìn. Quyết định này theo trụ cột *Nhỏ mà xong*.
### Terrain and Environmental Effects

| Ký hiệu | Địa hình | Đi vào được | Chặn đường đánh | Hiệu ứng |
|---|---|---|---|---|
| `.` | Đất trống | Có | Không | Không có |
| `~` | **Sông** | Không | Không (lao và tên bay qua được) | Quân Nguyên bị đẩy hoặc kéo xuống sông thì **chết ngay**. Tướng nhà Trần bị đẩy vào sông (chỉ xảy ra khi trúng đòn của Nguyễn Khoái) thì tính như va chạm: mất 1 máu, đứng yên. |
| `#` | **Rừng** | Không | **Có** (chặn lao, tên, xung phong) | Bị đẩy vào rừng là va chạm: mất 1 máu, đứng yên tại chỗ |
| `^` | **Hầm chông** | Có | Không | Bất kỳ quân nào đi vào ô, **kể cả chỉ đi ngang qua** (tự đi, bị đẩy hoặc bị kéo), đều **mất 1 máu** mỗi ô hầm chông. Gục giữa đường thì dừng tại đó. Đứng yên trên ô thì không mất thêm. Quân Nguyên không tránh hầm chông. |
| `L` | **Kho lương** | Không | Có | Cuối mỗi hiệp, mỗi quân Nguyên đứng kề (4 hướng) kho lương hồi **1 máu**, không vượt máu tối đa. Bị đốt bởi mưu kế *Vườn không nhà trống*. |
| `D` | **Làng** | Không | Có (chặn lao, tên, xung phong) [MẶC ĐỊNH] | Không có máu, không bị phá. Mỗi lần làng bị trúng thì **Lòng dân −1**: Bộ binh chém vào ô làng; Kỵ binh xung phong trúng làng; lao hoặc tên bị làng chặn [MẶC ĐỊNH]; một quân bị đẩy hoặc kéo va vào làng (quân đó mất 1 máu như va chạm), kể cả khi người chơi gây ra. Trần Khánh Dư không kéo được nếu vật đầu tiên trên hàng là làng [MẶC ĐỊNH]. Chốt 2026-10-17. |

**Luật va chạm:** đẩy hoặc kéo một quân vào quân khác hay vào vật cản (rừng, kho lương, làng, mép bàn) thì quân bị đẩy đứng yên, và **cả hai bên va chạm đều mất 1 máu**. Riêng mép bàn chỉ làm quân bị đẩy mất máu. Va vào làng thì Lòng dân −1.

**Thứ tự phân giải đầy đủ** (đẩy/kéo từng ô, pha địch, mưu kế, gục/thắng/thua) nằm trong `game-architecture.md`, mục *Bảng thứ tự phân giải*. Các mục gắn [MẶC ĐỊNH, duyệt qua kịch bản luật] sẽ được tác giả duyệt bằng kịch bản ở E2–E3.

**Để sau prototype:** thủy triều và bãi cọc (Bạch Đằng), thuyền, đồi, ải, thời tiết.
### Campaign Structure

**Prototype: chuỗi 6 trận cố định, làm tay.** Mỗi trận dạy một luật mới. (Thêm trận 4 "Bảo vệ làng" ngày 2026-10-18; trận Giữ ải cũ thành trận 5–6.)

| Trận | Kiểu | Luật được dạy | Quân Nguyên | Địa hình chính |
|---|---|---|---|---|
| 1 | Tiêu diệt | Né ô đỏ, đẩy địch xuống sông | 3 Bộ binh | Sông |
| 2 | Tiêu diệt | Kỵ binh xung phong, dùng rừng chặn đường, địch đánh trúng nhau | 2 Kỵ binh, 1 Bộ binh | Rừng, sông |
| 3 | Tiêu diệt | Trần Khánh Dư ra trận: đòn kéo, hầm chông; **giới hạn hiệp** | 2 Bộ binh, 2 Cung kỵ | Hầm chông, rừng |
| 4 | Tiêu diệt | **Bảo vệ làng**: làng và Lòng dân (vẫn có giới hạn hiệp) | Chốt khi thiết kế trận (gợi ý 2 Bộ binh, 1 Kỵ binh, 1 Cung kỵ) | Làng, sông, rừng |
| 5 | Giữ ải | Kho lương, *Vườn không nhà trống*, quân tiếp viện | 4 quân khởi đầu, +1 mỗi hiệp | Kho lương, sông |
| 6 | Giữ ải | Tổng hợp mọi luật, *Sát Thát* | 5 quân khởi đầu, +1–2 mỗi hiệp | Đủ các loại |

- **Tướng ra trận theo nhịp dạy chơi:** trận 1–2 chỉ có Nguyễn Khoái và Phạm Ngũ Lão; Trần Khánh Dư ra trận từ trận 3. File trận quy định tướng nào có mặt. Chốt 2026-10-17.
- **Trận 1–2 là phần hướng dẫn:** dễ, không giới hạn hiệp, không có làng. Luật mới của mỗi trận được giới thiệu bằng dòng gợi ý đầu trận. Giới hạn hiệp có từ trận 3, làng từ trận 4; số hiệp cụ thể chốt khi thiết kế từng trận. Chốt 2026-10-18.
- Mưu kế mở dần theo trận: *Vườn không nhà trống* có từ trận 5, *Sát Thát* có từ trận 6. [ASSUMPTION: mở mưu kế theo nhịp dạy chơi]
- Tên trận và địa danh: prototype dùng tên tạm "Trận 1–6". Bản phát hành phải gắn mỗi trận với một địa danh hoặc sự kiện có thật trong năm 1287–1288, kèm 1–2 dòng giới thiệu trước trận.

**Bản 1288 (giai đoạn 1):** chuỗi trận do bản đồ roguelite tạo ra (xem Roguelike Specific Design). Trận cuối là Bạch Đằng.

## Roguelike Specific Design
### Run Structure
*Phần này chỉ là khung. Sẽ chi tiết hóa sau khi prototype chứng minh được combat vui.*
- Mỗi lượt chơi tương ứng **một cuộc kháng chiến**. Bản 1288 kéo dài 30–60 phút.
- Bản đồ có **8–10 nút**, chia 3 chặng theo diễn biến lịch sử: rút lui và vườn không nhà trống → phản công → **Bạch Đằng** (trận cuối).
- Lượt chơi bắt đầu với 3 tướng (Nguyễn Khoái, Phạm Ngũ Lão, Trần Khánh Dư) và 2 mưu kế.
- Độ khó tăng dần theo chặng: thêm quân, thêm loại quân, thêm quân tiếp viện.
- Thắng lượt chơi khi hạ được trận Bạch Đằng.
- Loại nút: trận thường, trận tinh nhuệ, sự kiện lịch sử, nghỉ quân.
### Procedural Generation
- **Phần sinh ngẫu nhiên:** bố cục bản đồ nút, việc chọn trận cho từng nút (lấy từ kho trận làm tay, chia theo chặng), nội dung phần thưởng.
- **Phần không ngẫu nhiên:** combat. Mọi trận đều tất định.
- **Trận vẫn làm tay:** không sinh bàn cờ ngẫu nhiên, để đảm bảo trận nào cũng có lời giải.
- **Seed:** mỗi lượt chơi có một seed hiển thị được. Cùng seed thì ra cùng bản đồ, cùng trận, cùng phần thưởng.
### Permadeath and Progression
- **Thua bất kỳ trận nào thì hết lượt chơi.**
- Tướng gục trong trận vẫn theo quân, nhưng vào trận sau chỉ còn **1 máu**, trừ khi đi qua nút Nghỉ quân.
- **Giữ lại giữa các lượt chơi:** mở khóa thêm tướng và mưu kế (Rút lui chiến thuật, Nghi binh…). Không cộng chỉ số vĩnh viễn, để giữ trụ cột "thua là do tính sai".
- Điều kiện mở khóa cụ thể: *chi tiết hóa sau prototype*.
### Item and Upgrade System
- **Phần thưởng sau mỗi trận:** chọn 1 trong 3 phương án.
  - **Nâng cấp tướng:** ví dụ +1 máu tối đa, +1 tầm đánh, đẩy 2 ô thay vì 1 ô.
  - **Mưu kế mới:** tối đa 3 mưu kế trong một lượt chơi.
  - **Tướng mới:** thay một tướng đang có.
- Không có vật phẩm tiêu hao, không có độ hiếm, không có lời nguyền. Theo trụ cột *Nhỏ mà xong*.
- Danh sách nâng cấp cụ thể: *chi tiết hóa sau prototype*.

**Chỉ tiêu nội dung bản 1288** (theo brief, ước lượng): 4–6 tướng có thể thu nạp (mỗi trận ra trận 3), 4–6 loại quân Nguyên, 6–10 mưu kế, vài luật địa hình đặc trưng. Độ chơi lại đến từ bản đồ theo seed và tổ hợp tướng với mưu kế.
### Difficulty Modifiers
Không có trong prototype hay bản 1288 đầu tiên. Sẽ cân nhắc sau, ví dụ thêm các mức khó tăng dần như Ascension của Slay the Spire.

## Progression and Balance

### Player Progression
Thứ người chơi tiến bộ chủ yếu là **kỹ năng đọc bàn cờ**. Trong một lượt chơi, đội quân mạnh lên nhờ nâng cấp và mưu kế. Giữa các lượt chơi chỉ mở thêm *lựa chọn* chứ không cộng thêm sức mạnh.

### Difficulty Curve
- Prototype gồm 6 trận, mỗi trận thêm một luật mới (xem Campaign Structure).
- Trận 1–2 (dạy chơi) phải thắng được mà không mất tướng nào ngay ở lần chơi đầu, nếu người chơi đọc kỹ đòn báo trước.
- Trận 3–6 có giới hạn hiệp, làng hoặc Giữ ải, nên có thể khiến người chơi phải dùng "chơi lại hiệp".

### Economy and Resources
- Tài nguyên trong trận: máu của tướng, số lần dùng mưu kế (mỗi cái 1 lần mỗi trận), 1 lần "chơi lại hiệp".
- Không có tiền tệ trong prototype. Kinh tế của lượt chơi roguelite: *chi tiết hóa sau prototype*.

## Level Design Framework

### Level Types
- **Trận Tiêu diệt:** số quân địch cố định, không có tiếp viện. Là bài toán thuần túy. Từ trận 3 có giới hạn số hiệp; từ trận 4 có thể có làng cần bảo vệ (Lòng dân).
- **Trận Giữ ải:** 5 hiệp, có quân tiếp viện. Là bài toán chịu áp lực.
- **Trận cuối Bạch Đằng** (giai đoạn 1): luật riêng về thủy triều và bãi cọc. *Chi tiết hóa sau prototype.*

### Level Progression
**Quy tắc thiết kế mỗi trận:**
- Bàn 7×7.
- 3–6 quân Nguyên khởi đầu.
- Ít nhất **một cách thắng không mất tướng nào** (trận có làng: và không mất Lòng dân), do người thiết kế tự tìm ra và kiểm tra.
- Mỗi trận chỉ giới thiệu tối đa **một** luật mới.
- Trận thứ *n* dùng lại các luật của những trận trước.

**Các trận viết dưới dạng dữ liệu** (bố cục địa hình, vị trí quân, lịch tiếp viện), không viết trong code. Như vậy thêm hay sửa trận không cần lập trình.

## Narrative and Presentation
*Khung theo brief. Chi tiết làm bằng `gds-create-narrative` sau khi chốt GDD.*
- **Cách kể:** mỗi lần chỉ vài dòng ngắn: trước mỗi trận (1–2 dòng giới thiệu địa danh hoặc sự kiện), ở các nút sự kiện lịch sử trên bản đồ, và trong mô tả tướng.
- **Trích dẫn tư liệu thật**, ví dụ *Hịch tướng sĩ*, kèm tên nguồn.
- **Không có** hội thoại dài, cốt truyện rẽ nhánh.
- **Hư cấu và dã sử ghi rõ.** Chỗ nào là truyền thuyết hay dã sử thì ghi "theo truyền thuyết và dã sử"; chỗ nào chỉ có ở một nguồn thì ghi nguồn (ví dụ Phạm Ngũ Lão: "theo *Việt Nam sử lược*").
- Prototype chỉ cần tên tạm "Trận 1–6", không có chữ kể chuyện.

## Art and Audio Direction

### Art Style
- **Bàn cờ và quân cờ** (tạm thời): theo phong cách cờ tướng. Mỗi quân là một đồng tròn khắc chữ hoặc biểu tượng, đặt trên nền bản đồ cổ. Tác giả tự làm được bằng code và font chữ.
  [HOÃN SANG E8] Prototype dùng chữ hoặc biểu tượng đơn giản (chốt 2026-10-16). Ở E8 thử viền sơn mài, hoặc đặt hình bóng tướng lên đồng tròn.
- **Góc nhìn 2,5D** (chốt 2026-10-18): bàn cờ isometric, ô hình thoi, ô `0,0` ở đỉnh trên. Làm **sớm ở Story 1.7** với hình khối và màu tạm; quân vẫn là đồng tròn khắc chữ. [HOÃN SANG E8] thay hình khối tạm bằng tranh 2D vẽ theo góc nghiêng. Không làm 3D thật (chi phí, hiệu năng web, khó sửa trang phục thời Trần). Xem `sprint-change-proposal-2026-10-18-isometric.md`.
- **Ô đỏ báo đòn** phải nổi bật nhất trên màn hình. Thứ tự ra đòn hiện bằng số lớn.
- **Tranh minh họa giữa các trận và cảnh Bạch Đằng:** phong cách sơn mài hoặc Đông Hồ. Thuê vẽ 1–3 bức chủ đạo ở giai đoạn 1.
- **Chính sách AI:**
  - Giai đoạn prototype: chỉ dùng AI để thử ý tưởng và làm hình tạm.
  - Bản phát hành: mọi hình ảnh phải đối chiếu với tư liệu lịch sử (kể cả trang phục thời Trần) và sửa tay. Tranh chủ đạo thì thuê vẽ.
  - Khai báo việc dùng AI trên itch.io và Steam.

### Audio and Music
- **Prototype:** có thể không có âm thanh, hoặc dùng âm thanh miễn phí bản quyền (CC0).
- **Bản phát hành:** dùng nhạc có bản quyền hoặc thuê làm, lấy chất liệu truyền thống như trống trận, kèn bầu, đàn đáy.
  - Lưu ý: tác phẩm cổ có thể đã hết hạn bảo hộ, nhưng *bản thu âm* thì vẫn có bản quyền.
- Âm thanh gánh phần lớn "hào khí", nên đây là khoản đáng chi nhất sau tranh chủ đạo.

## Technical Specifications

### Performance Requirements
- Chạy **60 FPS** ổn định trên trình duyệt desktop, đo trên laptop văn phòng có card đồ họa tích hợp, trong suốt một trận 7×7.
- File tải về **≤ 50MB**.
- Từ lúc mở link đến màn hình chính **≤ 10 giây** với mạng 20Mbps.
- Hoạt ảnh một pha địch ra đòn **≤ 3 giây**. Có nút tua nhanh.

### Platform-Specific Details
- **Engine:** Godot, xuất bản HTML5.
- **Trình duyệt:** Chrome, Firefox, Edge bản desktop mới nhất. Safari và trình duyệt điện thoại không bắt buộc.
- **Lưu game:** lưu cục bộ trong trình duyệt, tự lưu sau mỗi trận.
- **Ngôn ngữ:** tiếng Việt. Toàn bộ chữ tách ra file riêng để sau này thêm tiếng Anh.
- **Steam (giai đoạn 2):** bản PC Windows. Yêu cầu chi tiết sẽ xác định sau.

### Asset Requirements (prototype)
- Bàn cờ: 6 loại ô (đất trống, sông, rừng, hầm chông, kho lương, làng), cộng ô ải.
- Quân: 3 tướng và 3 loại quân Nguyên, dạng đồng tròn.
- Giao diện: ô đỏ báo đòn, số thứ tự ra đòn, mũi tên chỉ hướng xung phong, ô sáng chỉ chỗ đi được, thanh máu, số hiệp (ví dụ "Hiệp 2/4"), Lòng dân (ví dụ "Lòng dân 3/3"), nút bấm.
- Âm thanh: tùy chọn, tối đa khoảng 10 hiệu ứng âm thanh CC0.

## Development Epics

### Epic Structure
Mỗi epic đều kết thúc bằng một thứ chơi được. Chi tiết (story, tiêu chí nghiệm thu) xem `_bmad-output/planning-artifacts/epics.md`; file `epics.md` trong thư mục GDD này là bản tổng quát cũ, đã được thay thế.

**Giai đoạn 0: Prototype (14 tuần × 10 giờ ≈ 140 giờ)**

| Epic | Tuần | Giờ | Chơi được khi xong |
|---|---|---|---|
| E0 Dựng nền | 1–2 | ~12 | Bàn cờ trống chạy trên itch.io (riêng tư); một lệnh chạy toàn bộ test |
| E1 Bàn cờ & di chuyển | 2–3 | ~18 | Di chuyển các tướng trên bàn của trận 1 |
| E2 Combat cốt lõi ⚠️ | 4–7 | ~35 | Chơi trọn trận 1 |
| E3 Địa hình & mưu kế | 7–11 | ~45 | Chơi được trận 2–5 |
| E4 Sáu trận & chơi thử | 12–14 | ~30 | Prototype hoàn chỉnh chạy trên web, có người thân chơi thử |

Chia lại giờ ngày 2026-10-17: E0 đổi từ "Học Godot" thành "Dựng nền" vì code do AI viết, nên bớt giờ E0 để bù cho E2 và E3.

Ngày 2026-10-18: thêm giới hạn hiệp, làng và trận 4 "Bảo vệ làng" (xem `sprint-change-proposal-2026-10-18.md`). E3 tăng khoảng 10 giờ, prototype thành khoảng 14 tuần.

**Thứ tự làm:** E0 → E1 → E2 → E3 → E4, bắt buộc tuần tự.

**Mốc kiểm tra: hết E2 (khoảng tuần 7).** Tác giả tự chơi trận 1. Nếu thấy chán thì dừng lại và sửa luật trước khi làm E3.

**Nếu E2 trễ:** cắt trận 6 và loại quân Cung kỵ. Không cắt luật lõi (đánh vào ô, đẩy và kéo).

**Giai đoạn 1: chỉ làm nếu prototype vui.** Chưa chia chi tiết.
- E5 Bản đồ roguelite
- E6 Phần thưởng & mở khóa
- E7 Trận Bạch Đằng (thủy triều, bãi cọc, thuyền)
- E8 Hình ảnh & âm thanh
- E8b Nội dung chữ (giới thiệu trận, sự kiện, mô tả tướng)
- E9 Phát hành web

## Success Metrics

### Technical Metrics
- Đạt các mục tiêu trong Technical Specifications: ≤50MB, tải ≤10 giây, 60 FPS.
- Không có lỗi làm kẹt trận trong cả 6 trận.

### Gameplay Metrics (prototype, quan sát người thân chơi thử)
Mục tiêu là trả lời câu hỏi: **giải thế trận có vui không?** Không hỏi người chơi có thích không. Quan sát hành vi của họ:
- **Tự chơi lại sau khi thua**, không cần ai nhắc. Đạt nếu ≥ 2 trong 3–5 người làm vậy.
- **Dừng lại suy nghĩ trước nước đi**, nhìn ô đỏ trước khi đánh. Đây là dấu hiệu trụ cột *Thấy trước, tính được* đang có tác dụng.
- **Dùng địa hình để hạ địch** (sông, va chạm, đòn của đồng đội) chứ không chỉ đánh thẳng. Dấu hiệu trụ cột *Địa hình là vũ khí*.
- **Hỏi "còn trận nữa không?"** khi xong trận 6.
- **Tác giả tự thấy vui** ở mốc hết E2.

Đạt ≥3 trong 5 dấu hiệu trên thì chuyển sang giai đoạn 1.

## Out of Scope

**Không có trong prototype (để dành cho giai đoạn 1):**
- Bản đồ roguelite, phần thưởng, mở khóa
- Thủy chiến, thuyền, thủy triều, bãi cọc
- Trận Bạch Đằng
- Tranh minh họa, nhạc
- Tên trận gắn với sự kiện thật

**Để dành cho giai đoạn 2:**
- Cuộc kháng chiến năm 1258 và năm 1285
- Bản tiếng Anh
- Phát hành trên Steam
- Các mức độ khó

**Không làm:**
- Multiplayer
- Cốt truyện rẽ nhánh, hội thoại dài
- Bản cho điện thoại di động
- Hệ thống đánh sườn, chiếm vùng cao, nấp sau vật cản, đội hình, tầm nhìn
- Tỷ lệ trúng đòn, may rủi trong combat

## Assumptions and Dependencies

**Giả định:**
- Tác giả là lập trình viên web, học được Godot trong khoảng 30 giờ đủ để làm game theo lượt trên lưới.
- Dành đều 10 giờ mỗi tuần trong 14 tuần.
- Cách vẽ quân cờ kiểu cờ tướng đủ rõ ràng để chơi thử.
- Người thân sẵn sàng chơi thử và để tác giả quan sát.
- Mưu kế mở dần theo từng trận (xem Campaign Structure).

**Phụ thuộc:**
- Godot hỗ trợ xuất bản web (HTML5).
- Các nguồn sử: *Đại Việt sử ký toàn thư*, *Việt Nam sử lược*, *Cương mục*. Xem `history-notes-1288.md`.
- Ngân sách vài trăm USD cho tranh minh họa và nhạc. Chỉ dùng từ giai đoạn 1.

**Rủi ro ngoài thiết kế:** Nghị định 147/2024 có áp dụng cho bản web miễn phí hay không. Cần tìm hiểu trước khi phát hành công khai ở giai đoạn 1. Đây không phải tư vấn luật.

### Risks
| # | Rủi ro | Cách giảm |
|---|---|---|
| 1 | **Năng lực (lớn nhất):** chưa từng làm game, không vẽ, không làm nhạc, mà hào khí phụ thuộc vào phần trình bày | Quân cờ kiểu cờ tướng; chỉ chi tiền cho tranh chủ đạo và nhạc; prototype trước rồi mới chi |
| 2 | **Phạm vi phình ra** | Trụ cột *Nhỏ mà xong*; mỗi giai đoạn có điểm dừng; phương án cắt khi E2 trễ |
| 3 | **Combat không vui** | Toàn bộ giai đoạn 0 để kiểm chứng; mốc tự chơi hết E2 |
| 4 | **Người thử thiên vị** (người thân hay khen) | Quan sát hành vi thay vì hỏi ý kiến (Success Metrics); từ giai đoạn 1 thêm người lạ chơi thử |
| 5 | **Sai sử, AI vẽ sai trang phục** | Trụ cột *Tôn trọng lịch sử*; đối chiếu tư liệu trước khi phát hành (E9) |
| 6 | **Mất động lực** (một mình, 10 giờ/tuần, nhiều tháng) | Mốc ngắn, mỗi epic kết thúc bằng thứ chơi được; cho người thật chơi sớm |

### Open Questions (không chặn prototype)
- Tên game: dùng tên tiếng Việt kèm một tên tiếng Anh? Quyết trước khi phát hành giai đoạn 1.
- Trận Bạch Đằng thiết kế như trận boss thế nào: quyết ở E7.

### Chỉ mục giả định và ghi chú
- [ASSUMPTION] Mưu kế mở dần theo trận (Campaign Structure).
- [KIỂM TRA KHI PLAYTEST E4] Tầm kéo của Trần Khánh Dư: chốt 2 ô (Unit Types).
- [KIỂM TRA KHI PLAYTEST E4] Độ mạnh của Vườn không nhà trống: chốt giữ nguyên (Primary Mechanics).
- [HOÃN SANG E8] Hình ảnh quân cờ (Art Style).
- [CHƯA KIỂM CHỨNG SỬ] Vai gameplay của các tướng (Unit Types).
- [MẶC ĐỊNH] Luật làng, Lòng dân và giới hạn hiệp (Win/Loss, Terrain, Enemy AI): duyệt qua kịch bản luật ở Story 3.5 và 3.7.
