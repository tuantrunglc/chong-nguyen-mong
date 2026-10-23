# Báo Cáo Phân Tích Cơ Chế, Độ Khó & Đánh Giá Đề Xuất Mở Rộng

- **Ngày cập nhật:** 23/10/2026
- **Trạng thái:** Tài liệu phản biện & Chuẩn hóa thiết kế (Design Review & Alignment)
- **Cơ sở đối chiếu:** Game Design Document (GDD 2026-10-15), Mã nguồn game (`game/src/`, `game/data/`), và Sử liệu kháng chiến lần 3 (1287–1288).

---

## 1. Đối Chiếu Hệ Thống Hiện Tại Với Luật Thật

### 1.1. Các điểm đã khớp đúng mã nguồn và chỉ số (`chi_so.json`)
- **Nguyễn Khoái:** Máu 3, Tầm đi 3, Đòn đánh cận chiến 1 ô kề: **2 sát thương**, **đẩy lùi 1 ô**.
- **Trần Khánh Dư:** Máu 3, Tầm đi 3, Đòn kéo cờ tầm xa: chọn mục tiêu trong vòng **3 ô**, kéo về phía mình **2 ô**, **0 sát thương trực tiếp**.
- **Phạm Ngũ Lão:** Máu 3, Tầm đi 3, Đòn phóng trường lao: tầm xa **2–4 ô** (bỏ qua ô kề), **1 sát thương**.
- **Sông (`~`):** Quân Nguyên bị đẩy xuống sông thì **chết đuối ngay lập tức** (Insta-kill). Tướng bị đẩy vào sông thì mất 1 máu và đứng yên tại bờ (hiện chưa có quân Nguyên nào có đòn đẩy tướng, quy tắc này được thiết lập sẵn trong engine).
- **Rừng trúc (`#`):** Vật cản cứng: chặn đòn phóng lao của Lão, đòn bắn tên của Cung kỵ, đòn xung phong của Kỵ binh, và **chặn cả đòn kéo của Dư** (`rung_chan_keo.json`). Đẩy quân va vào rừng gây 1 sát thương va chạm.

### 1.2. Các điểm đính chính & bổ sung chính xác theo luật game
- **Hầm chông tre (`^`):** Luật thực tế là **mất 1 máu mỗi khi di chuyển hoặc bị đẩy/kéo đi vào ô chông**. Quân cờ đứng yên trên ô chông ở các hiệp sau thì **không mất thêm máu**. *(Lưu ý: Hầm chông thuộc phạm vi Story 3.4, hiện đang trong lộ trình triển khai)*.
- **Kho lương (`L`):** Vật cản cứng không đi qua được, chặn đòn bắn/lao. Cuối hiệp, hồi 1 máu cho quân Nguyên đứng ở ô kề bên. Bị thiêu rụi khi kích hoạt mưu kế *Vườn không nhà trống*.
- **Làng quê (`D`):** Vật cản cứng không đi qua được. Mỗi khi làng bị trúng đòn hoặc bị quân va chạm vào: **Lòng dân −1**.
- **Kích thước bàn cờ:** Quy chuẩn dao động từ tối thiểu **5×5** (`BOARD_MIN`) đến tối đa **10×8** (`BOARD_MAX`). Bàn cờ Trận 6 (Bạch Đằng) trong GDD định hướng kích thước **10×8**.

---

## 2. Phân Tích Độ Khó: Game Có Bị Quá Dễ Không?

### 2.1. Đính chính về nhịp hành động (Action Economy)
- **Thực tế cơ chế kiểu *Into the Breach*:** Mỗi hiệp, quân Nguyên **di chuyển rồi báo trước ô sẽ ra đòn (Telegraph - hiện vệt đỏ cảnh báo)**. Toàn bộ đòn đánh của địch chỉ được thực thi vào **cuối lượt** (sau khi người chơi bấm "Kết thúc lượt").
- **Lợi thế thật của người chơi:** Không phải là "địch mất một nhịp", mà là **người chơi có thông tin tuyệt đối về ý định ra đòn của địch** để tìm cách né tránh, đẩy lệch hướng, hoặc triệt hạ kẻ phát đòn trước khi nó kịp vung đao.

### 2.2. Đánh giá lối chơi "Thả diều" (Lùi lại tỉa dần)
Nguy cơ người chơi lùi tướng an toàn để tỉa máu từ xa là có thật, nhưng bị hạn chế bởi các yếu tố thực tế:
1. **Không gian sa bàn hẹp:** Bàn cờ 6×6 rất chật, lùi 1–2 bước là chạm mép bàn hoặc vướng sông/rừng.
2. **Tốc độ quân giặc:** Kỵ binh và Cung kỵ có tầm đi 3 ô (nhanh bằng tướng Đại Việt), người chơi không thể dễ dàng bỏ chạy.
3. **Sát thương lao có hạn:** Lao của Ngũ Lão chỉ gây 1 sát thương, trong khi Bộ binh Nguyên có tới 3 máu. Nếu chỉ đứng tỉa từng máu một thì tiến độ tiêu diệt rất chậm.

### 2.3. Xác nhận các cơ chế siết độ khó đã chốt trong GDD (17–18/10)
Các yếu tố sau không phải đề xuất mới mà là **xác nhận lại hướng đi đã chốt**:
- **Giới hạn số hiệp (từ Trận 3):** Khóa chặt lối chơi câu giờ, ép người chơi phải dứt điểm mục tiêu trong số hiệp quy định.
- **Bảo vệ Làng & Lòng dân (từ Trận 4):** Địch ưu tiên chém phá làng, tước bỏ quyền tự do lùi bước của người chơi.
- **Thứ tự ra đòn của địch (`thu_tu_dich`):**
  - *Lợi thế:* Đẩy một tên giặc vào ô đồng đội nó sắp đánh sẽ khiến địch tự chém nhau.
  - *Rủi ro thật sự của thứ tự:* Nếu người chơi tiêu diệt (hoặc dời chỗ) một quân cờ đang đứng chắn đường Kỵ binh, khoảng trống mở ra sẽ làm đòn xung phong của Kỵ binh phía sau **phóng xa hơn dọc theo hàng/cột và đâm trúng tướng Đại Việt**!

---

## 3. Đánh Giá Đề Xuất Mở Rộng Quân Đại Việt

### 3.1. Phạm vi kiến trúc & Tiến độ
- **Phạm vi Prototype:** Cố định đúng **3 tướng** (Nguyễn Khoái, Phạm Ngũ Lão, Trần Khánh Dư).
- **Chọn tướng dự bị (Roster Selection) & Chế độ Roguelite:** Thuộc phạm vi **Giai đoạn 1 (Sau khi prototype chứng minh combat vui)**, không đưa vào prototype hiện tại để tránh phình to phạm vi (scope creep).

### 3.2. Chuẩn hóa sử liệu (Trụ cột "Tôn trọng lịch sử")
- ❌ **Trần Quốc Toản:** Theo chính sử (*Đại Việt sử ký toàn thư*), Hoài Văn hầu Trần Quốc Toản đã hy sinh anh dũng trong cuộc kháng chiến lần 2 (năm 1285 tại trận Như Nguyệt/Tây Kết). Do đó, **không thể đưa Trần Quốc Toản vào chiến dịch kháng chiến lần 3 (1287–1288)**.
- ❌ **"Yết Kiêu / Dã Tượng":** Đây là hai danh tướng, hai con người hoàn toàn khác nhau:
  - **Dã Tượng:** Quản tượng tài ba, chuyên chỉ huy đội hình voi chiến bộ binh.
  - **Yết Kiêu:** Danh tướng thủy binh thiện nghệ, tài lặn biển đục thuyền giặc.
- ❌ **Hiệu ứng mới:** Không đưa các hiệu ứng như Trói chân (Root) hay tính điểm Lòng dân vào quân lính, vì Lòng dân chỉ gắn liền với Làng và game không nên thêm trạng thái làm phức tạp hóa logic cốt lõi.

---

## 4. Đánh Giá Đề Xuất Mở Rộng Quân Phe Nguyên

### 4.1. Điểm cần quyết định về Trận 6 (Bạch Đằng) trong GDD
Hiện tại GDD đang có điểm cần chốt rõ ràng:
- Một mặt, GDD ghi: *Thủy triều, bãi cọc và thủy chiến là ngoài phạm vi prototype (quyết ở Epic 7)*.
- Mặt khác, GDD vẫn xếp Trận 6 trong chuỗi 6 trận prototype là: *Phục binh hai bờ Bạch Đằng (10×8)*.
- **Đề xuất thống nhất:** Trong khuôn khổ Prototype, Trận 6 nên là trận đánh **bờ sông / cồn bãi trên bộ** phối hợp đầy đủ 3 tướng và các chướng ngại vật cơ bản (Sông, Hầm chông, Rừng, Làng), trước khi đưa cơ chế thủy triều/thuyền chiến vào giai đoạn sau.

### 4.2. Chuẩn hóa nhân vật lịch sử
- **Ô Mã Nhi:** Ô Mã Nhi (Omar / Omad) là tướng gốc Hồi Hột (người Semu/Trung Á) phục vụ triều Nguyên, giữ chức *Tham tri chính sự* kiêm Đô chỉ huy thủy quân, không phải tước hiệu "Vạn hộ" hay "Chiến tướng Mông Cổ".

### 4.3. Đánh giá các ý tưởng quân địch dưới lăng kính luật game
1. **Thuẫn binh (Có Giáp):**
   - *Phân tích:* Đơn vị Bộ binh hiện tại (3 máu) vốn đã đóng vai trò "trâu bò, khó hạ bằng sát thương thuần, nên giải quyết bằng đẩy xuống sông/chông". Nếu đưa thêm quân có Giáp, vai trò giải đố sẽ bị trùng lặp với Bộ binh và làm phát sinh câu hỏi phức tạp (Giáp trừ 1 hay chặn hết? Khoái đánh 2 thì trừ mấy? Chông tre có xuyên giáp không?). -> **Kết luận: Chưa cần thiết, Bộ binh 3 máu đã đáp ứng đủ vai trò.**
2. **Hỏa tiễn binh (Đốt ô):**
   - Ý tưởng đốt Kho lương là phi lý vì kho lương là nơi tiếp tế của chính quân Nguyên. Ngoài ra, việc tạo "ô lửa cháy tồn tại qua nhiều hiệp" tạo thêm trạng thái môi trường mới, làm nặng hệ thống.
3. **Boss chém 3 ô bán nguyệt:**
   - Game hiện tại **hoàn toàn không có khái niệm hướng mặt (Facing direction) của quân cờ**, nên không thể định nghĩa "3 ô trước mặt" nếu không đại tu toàn bộ mã nguồn. Đòn đánh chỉ nên dựa trên tọa độ tương đối (ô kề, hàng thẳng, hoặc bán kính).
4. **Mưu kế *Sát Thát*:**
   - Luật game quy định rõ: *Sát Thát* tăng +1 sát thương đòn đánh trực tiếp của tướng, **không cộng vào sát thương va chạm địa hình**.

---

## 5. Kết Luận & Kế Hoạch Triển Khai Thực Tế

| Nội dung | Hiện trạng | Hành động tiếp theo |
|---|---|---|
| **Bộ 3 tướng Đại Việt** | Hoàn thiện 100% trong code | Giữ nguyên, không thêm tướng mới vào prototype. |
| **Tiến độ chiến dịch** | Mới xong **Trận 1 & Trận 2** (Story 3.3) | Tập trung hiện thực hóa **Trận 3 (Hầm chông, Cung kỵ, Giới hạn hiệp)** theo đúng kế hoạch Story 3.4. |
| **Bàn cờ** | 5×5 đến 10×8 | Đã đủ chuẩn, giữ nguyên theo quy cách kỹ thuật hiện tại. |
| **Trận 6 Bạch Đằng** | Cần chốt phạm vi | Thống nhất triển khai Trận 6 trên bờ sông/bãi cồn với luật cờ bộ binh cơ bản, chưa thêm thủy triều phức tạp. |
