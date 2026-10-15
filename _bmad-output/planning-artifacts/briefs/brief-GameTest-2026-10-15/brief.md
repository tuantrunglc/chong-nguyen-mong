---
title: 'Game Brief: Chống Nguyên Mông (tên tạm)'
status: final
created: '2026-10-15'
updated: '2026-10-15'
inputs:
  - _bmad-output/planning-artifacts/research/market-game-lich-su-viet-nam-2026-10-15/research.md
---

# Game Brief: Chống Nguyên Mông (tên tạm)

## Tóm tắt

Đây là một game tactics roguelite 2D theo lượt về cuộc kháng chiến chống Nguyên Mông của nhà Trần. Người chơi vào vai Trần Hưng Đạo, trực tiếp chỉ huy 2–3 tướng có thật trên một bàn cờ nhỏ. Mỗi trận đánh là một bài toán: địch luôn báo trước nước đi của chúng, còn người chơi dùng địa hình (sông nước, cọc gỗ, vườn không nhà trống) cùng các mưu kế của Trần Hưng Đạo để phá thế trận. Khí thế "Hào khí Đông A" không nằm trong cơ chế combat mà nằm ở cách game được trình bày: trống trận, những câu trích từ *Hịch tướng sĩ*, và trận Bạch Đằng ở cuối.

Game được làm trước hết cho **người Việt mê sử**. Hiện chưa có game chiến thuật nào cho họ tự tay đánh lại những trận chống Nguyên Mông, với tướng thật, trận thật và luật chơi mô phỏng đúng cách đánh của nhà Trần.

Đây là **dự án đam mê do một người làm**. Tác giả là lập trình viên web, chưa từng làm game, không vẽ và không làm nhạc, mỗi tuần bỏ ra khoảng 10 giờ, ngân sách vài trăm USD. Kế hoạch có ba bước:
1. Làm một prototype trong 3 tháng để trả lời một câu hỏi duy nhất: giải thế trận có vui không.
2. Nếu vui, phát hành miễn phí trên web một bản trọn vẹn cuộc kháng chiến năm 1288.
3. Tính đến Steam sau.

## Tầm nhìn

**Một câu:** Bạn là Trần Hưng Đạo, giải từng thế trận chống đại quân Nguyên Mông, trên đường dẫn tới Bạch Đằng.

**Cảm giác cốt lõi là Hào khí Đông A.** Trong trận, người chơi cân não và thắng nhờ cái đầu. Hào khí không đến từ cơ chế mà từ những gì bao quanh trận đánh:
- tiếng trống trận
- những câu trong *Hịch tướng sĩ* giữa các trận
- cảm giác cả một dân tộc đứng sau lưng mình
- trận Bạch Đằng ở cuối

**Vai trò người chơi:** Trần Hưng Đạo không đứng trên bàn cờ. Ông là người cầm quân. Người chơi điều khiển 2–3 tướng hoặc đơn vị dưới quyền ông. Tài năng của ông thể hiện qua các *mưu kế*, mỗi trận chỉ dùng được một số lần.

## Người chơi mục tiêu & thị trường

**Khán giả chính: người Việt mê sử.** Đó là những người đã đọc về các cuộc kháng chiến chống Nguyên Mông và yêu hình tượng Trần Hưng Đạo. Họ muốn được *tự tay* đánh lại những trận ấy, và sẽ là những người bắt lỗi sai sử gay gắt nhất. Đây là dự án đam mê, nên game được làm trước hết cho nhóm này và cho chính tác giả. Mục tiêu không phải tối đa doanh thu.

**Khán giả phụ (về sau): người chơi tactics quốc tế.** Họ đến vì combat hay. Bối cảnh Đại Việt tiền hiện đại là thứ mới lạ với họ, vì người chơi nước ngoài hầu như chỉ biết đến Việt Nam qua chiến tranh với Mỹ.

**Bối cảnh thị trường** (theo research):
- Chưa có game tactics hay roguelite thương mại nào lấy bối cảnh Trần–Nguyên.
- Tactics roguelite là một thể loại hẹp, nơi game nhỏ có bản sắc rõ ràng vẫn có cơ hội.
- Ngược lại, tiếng Việt chỉ chiếm 0,25% người dùng Steam. Steam lại đang bị chặn một phần ở Việt Nam. Vì vậy, kênh tiếp cận người Việt **không nên là Steam**.

## Nền tảng gameplay

**Thể loại:** Tactics roguelite 2D, đánh theo lượt trên bàn cờ chia ô nhỏ.

**Vòng lặp gameplay:**
- **Trong một trận (vài phút).** Địch báo trước nước đi. Người chơi di chuyển 2–3 tướng và tận dụng địa hình: sông, cọc, rừng, làng. Người chơi chọn thời điểm tung mưu kế của Trần Hưng Đạo. Sau đó địch hành động. Cứ thế lặp lại cho đến khi thắng hoặc thua.
- **Trong một lượt chơi roguelite (30–60 phút).** Người chơi chọn đường đi trên bản đồ của một cuộc kháng chiến. Dọc đường có các trận đánh và sự kiện lịch sử, qua đó thu nạp thêm tướng hoặc mưu kế. Lượt chơi kết thúc bằng trận cuối. Ở cuộc kháng chiến 1288, trận cuối là **Bạch Đằng**.
- **Giữa các lượt chơi.** Người chơi mở khóa thêm tướng, mưu kế và cuộc kháng chiến tiếp theo, theo thứ tự 1258 → 1285 → 1288.

**Trụ cột thiết kế:**
1. **Thấy trước, tính được.** Địch luôn báo trước nước đi. Game không có xúc xắc may rủi. Thua là do mình tính sai.
2. **Địa hình là vũ khí.** Cách đánh của nhà Trần (sông nước, cọc gỗ, vườn không nhà trống) là *luật chơi*, không chỉ là hình nền.
3. **Tôn trọng lịch sử.** Tướng, trận đánh và thời điểm đều có thật. Chỗ nào hư cấu (ví dụ phần gameplay cần) thì ghi rõ. Lịch sử được kể ngắn gọn giữa các trận, không dùng hội thoại dài.
4. **Nhỏ mà xong.** Tính năng nào không làm xong trong khoảng 10 giờ (một tuần làm việc) thì cắt bỏ, hoặc chia nhỏ ra.

## Tham chiếu & khác biệt

| Game | Lấy | Không lấy |
|---|---|---|
| **Into the Breach** | Địch báo trước nước đi. Bàn cờ nhỏ, khoảng 3 unit. Đẩy địch vào địa hình nguy hiểm. | Bối cảnh khoa học viễn tưởng. Độ trau chuốt khó đạt với người mới. |
| **Shogun Showdown** | Một người làm. Combat gần như tất định. Lượt chơi ngắn. Art tối giản nhưng có bản sắc. | Bàn cờ một hàng với một nhân vật duy nhất (game này để người chơi chỉ huy 2–3 tướng). |
| **Slay the Spire** | Bản đồ dạng node. Phần thưởng sau mỗi trận. | Thẻ bài và deckbuilding. |

**Đối thủ:**
- Trực tiếp: chưa có game tactics hay roguelite thương mại nào lấy bối cảnh Trần–Nguyên. Hiện chỉ có vài dự án sinh viên trên itch.io.
- Gián tiếp: các tactics roguelite nói chung. Ngoài ra còn phe Đại Việt nhà Trần trong một DLC của Civilization VII.

**Khác biệt, nói thẳng:** về độ sâu combat, game này *không* hơn Into the Breach. Cái riêng của nó gồm hai điều:
- Đây là game chiến thuật đầu tiên cho người Việt **tự tay đánh lại các trận chống Nguyên Mông**, với tướng thật và trận thật.
- Game có những **luật địa hình chỉ thời Trần mới có**: thủy triều và bãi cọc, vườn không nhà trống.

## Phạm vi & MVP

**Đội ngũ và ràng buộc.**
- Một người làm, nền tảng là lập trình web.
- Chưa từng làm game, không vẽ, không làm nhạc.
- Khoảng 10 giờ mỗi tuần.
- Ngân sách cho art và nhạc khoảng vài trăm USD.
- Engine: **Godot** (GDScript), miễn phí, xuất được bản HTML5.

**Nền tảng phát hành, theo thứ tự ưu tiên.**
1. Web (HTML5) và itch.io, miễn phí, nhắm người Việt.
2. Steam trên PC, kèm bản tiếng Anh. Chỉ làm khi game đã được chứng minh là hay.

**Giai đoạn 0: prototype combat (MVP), khoảng 3 tháng, khoảng 130 giờ.**
- Tuần 1–3: học Godot qua một hướng dẫn làm game theo lượt trên lưới ô.
- Tuần 4–13, nội dung cần làm:
  - 1 bàn cờ nhỏ
  - 2 tướng
  - 2–3 loại quân Nguyên
  - 1–2 mưu kế của Trần Hưng Đạo
  - 1–2 luật địa hình
  - 3–5 trận thiết kế tay
- Đồ họa chỉ là khối hình hoặc hình tạm do AI vẽ. **Chưa có lớp roguelite.**
- Kiểm chứng: cho người thân chơi thử và **quan sát hành vi**, không hỏi ý kiến. Dấu hiệu tốt là họ tự chơi lại sau khi thua, dừng lại suy nghĩ trước khi đi một nước, hay hỏi "còn trận nữa không?".
- Chưa tiêu đồng nào vào art.

**Giai đoạn 1: bản web đầu tiên.** Chỉ làm nếu prototype vui.
- Trọn vẹn cuộc kháng chiến **năm 1288**: bản đồ roguelite, các sự kiện lịch sử, và trận cuối là **Bạch Đằng**.
- Thuê vẽ 1–3 tranh minh họa chủ đạo.
- Phát hành miễn phí trên itch.io và giới thiệu trong các cộng đồng mê sử.

**Giai đoạn 2: để sau.**
- Hai cuộc kháng chiến năm 1258 và 1285.
- Bản tiếng Anh.
- Phát hành trên Steam.

**Ngoài phạm vi:** multiplayer, cốt truyện rẽ nhánh, hội thoại dài, bản mobile.

## Nội dung & định hướng

**Thế giới.** Đại Việt thời Trần, giai đoạn 1258–1288. Game tập trung vào cuộc kháng chiến năm 1288 và đi đến trận Bạch Đằng.

**Cách kể chuyện.** Mỗi lần chỉ vài dòng ngắn: giữa các trận, ở các sự kiện trên bản đồ, và trong phần mô tả tướng. Trích dẫn tư liệu thật như *Hịch tướng sĩ*. Không có đoạn hội thoại dài. Chỗ nào hư cấu thì ghi rõ.

**Khối lượng nội dung** (bản 1288, ước lượng):
- Một lượt chơi kéo dài 30–60 phút.
- Khoảng 4–6 tướng có thể thu nạp.
- Khoảng 4–6 loại quân Nguyên.
- Khoảng 6–10 mưu kế.
- Vài luật địa hình đặc trưng.
- Độ chơi lại đến từ bản đồ ngẫu nhiên và các tổ hợp tướng với mưu kế.

**Định hướng hình ảnh** (tạm thời, sẽ xem lại ở bước GDD/UX):
- Bàn cờ dùng **phong cách quân cờ tướng**: mỗi quân là một đồng tròn khắc chữ hoặc biểu tượng, đặt trên nền bản đồ cổ. Cách này gần như không cần vẽ, tác giả tự làm được bằng code và font chữ.
- Tranh minh họa giữa các trận theo phong cách **sơn mài hoặc Đông Hồ**.
- **Chính sách AI:**
  - Ở giai đoạn prototype, AI chỉ được dùng để thử ý tưởng và làm hình tạm.
  - Ở bản phát hành, mọi hình ảnh phải được đối chiếu với tư liệu lịch sử và sửa tay. Tranh chủ đạo thì thuê vẽ.
  - Có khai báo việc dùng AI theo quy định của itch.io và Steam.

**Định hướng âm thanh.**
- Prototype có thể không có nhạc, hoặc dùng âm thanh miễn phí.
- Bản phát hành dùng nhạc có bản quyền hoặc thuê làm, lấy chất liệu truyền thống: trống trận, kèn bầu, đàn đáy. Lưu ý: bản nhạc cổ có thể đã hết bản quyền, nhưng *bản thu âm* thì vẫn còn bản quyền.
- Âm thanh phải gánh phần lớn "hào khí", nên đây là chỗ đáng chi tiền nhất sau tranh chủ đạo.

## Rủi ro & câu hỏi mở

**Rủi ro:**
1. **Năng lực (lớn nhất).** Tác giả chưa từng làm game, không vẽ, không làm nhạc, mà "hào khí" lại phụ thuộc vào phần trình bày.
   *Cách giảm:* chọn phong cách quân cờ tướng để giảm tối đa việc vẽ; chỉ chi tiền cho tranh chủ đạo và nhạc; prototype trước rồi mới chi tiền.
2. **Phạm vi phình ra.** Đây là lý do số 1 khiến game đầu tay không bao giờ xong.
   *Cách giảm:* trụ cột "Nhỏ mà xong"; mỗi giai đoạn đều có điểm dừng rõ ràng.
3. **Combat không vui.** Đây là giả thuyết cốt lõi và chưa được kiểm chứng.
   *Cách giảm:* toàn bộ giai đoạn 0 chỉ nhằm kiểm chứng điều này.
4. **Người thử thiên vị.** Người thân thường hay khen.
   *Cách giảm:* quan sát hành vi thay vì hỏi ý kiến; từ giai đoạn 1 thì thêm người lạ chơi thử.
5. **Sai sử hoặc AI vẽ sai trang phục.** Khán giả chính lại là nhóm khắt khe nhất về chuyện này.
   *Cách giảm:* trụ cột "Tôn trọng lịch sử"; đối chiếu tư liệu trước khi phát hành.
6. **Mất động lực vì làm một mình, 10 giờ mỗi tuần, kéo dài nhiều tháng.**
   *Cách giảm:* chia mốc ngắn và cho người thật chơi sớm.

**Câu hỏi mở cho GDD:**
- Kích thước bàn cờ, ví dụ 6×6 hay 8×8?
- Chính xác những luật địa hình nào sẽ có?
- Danh sách tướng thật và kỹ năng của từng người.
- Danh sách mưu kế của Trần Hưng Đạo.
- Trình bày quân cờ. Phong cách quân cờ tướng mới chỉ được chấp nhận tạm thời, vì tác giả thấy chữ hoặc biểu tượng trên quân cờ "chưa đẹp lắm". Cần tìm cách đẹp hơn mà không phải vẽ nhiều, ví dụ quân cờ có viền sơn mài, hoặc hình bóng (silhouette) tướng trên đồng xu.
- Cấu trúc bản đồ của cuộc kháng chiến 1288.
- Trận Bạch Đằng được thiết kế như một trận boss như thế nào?

**Câu hỏi mở ngoài thiết kế:**
- Nghị định 147/2024 có áp dụng cho bản web miễn phí phát hành tới người Việt hay không? Đây không phải tư vấn luật, cần tìm hiểu thêm.
- Có nên làm tên game bằng tiếng Việt kèm một tên tiếng Anh không?
