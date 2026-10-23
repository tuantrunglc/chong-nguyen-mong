# Thiết Kế Bản Đồ: Trận 1 – Cửa Đại Than

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_01`
- **Tên hiển thị:** *Cửa Đại Than*
- **Kiểu nhiệm vụ:** `tieu_diet` (Tiêu diệt toàn bộ quân Nguyên)
- **Giới hạn hiệp:** Không giới hạn (Màn mở đầu dạy cơ bản)
- **Tướng tham chiến:** 
  - `1`: Nguyễn Khoái (Đao khiên, cận chiến đẩy lùi 1 ô)
  - `2`: Phạm Ngũ Lão (Phóng lao tầm 2–4 ô)
- **Quân Nguyên:** 3 Bộ binh Nguyên (`B`), mỗi tên 3 máu, đánh cận chiến 1 sát thương.
- **Địa hình chính:** Cỏ (`.`), Dải sông ngắt quãng (`~`)
- **Kích thước sa bàn:** 7 cột × 7 hàng (7×7)
- **Sự kiện lịch sử:** 
  > Ngày 16 đến 26 tháng 12 năm Đinh Hợi (khoảng tháng 1/1288), Minh tự Nguyễn Thức đem quân Thánh dực dũng nghĩa đến giữ cửa Đại Than, chặn đánh các đạo quân thủy bộ của Ô Mã Nhi và Thoát Hoan (*Đại Việt sử ký toàn thư*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học
1. **Dạy vùng đe dọa (Threat Zone):** Khi bắt đầu hiệp, quân Nguyên vung đao nhắm vào các ô lân cận (hiện vệt đỏ cảnh báo). Người chơi học cách không đứng vào ô đỏ.
2. **Dạy đòn Phóng lao tầm xa:** Phạm Ngũ Lão đứng ở khoảng cách 2–4 ô để tỉa bớt máu quân địch mà không sợ bị phản đòn.
3. **Dạy cơ chế Đẩy rơi sông (Insta-kill):** Nguyễn Khoái chém đẩy lùi 1 ô. Đẩy quân địch rơi xuống dòng sông (`~`) khiến địch chết đuối ngay lập tức bất kể lượng máu còn lại, mở mắt cho người chơi về sức mạnh của địa hình.

---

## 3. Sa Bàn Bố Cục (7×7)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5  6
H0:   .  .  .  ~  .  .  .
H1:   .  .  .  ~  .  .  .
H2:   .  .  .  ~  .  .  .
H3:   .  .  .  .  .  .  .   <- Lối qua sông ở giữa hàng 3
H4:   .  .  .  ~  .  .  .
H5:   .  .  .  ~  .  .  .
H6:   .  .  .  ~  .  .  .
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5  6
H0:   .  .  .  .  .  B  .   (B3: [5,0])
H1:   .  .  .  .  .  .  .
H2:   .  .  .  .  .  .  .
H3:   .  .  .  .  .  .  .
H4:   .  .  B  .  .  B  .   (B1: [2,4] - đứng sát bờ sông tây; B2: [5,4])
H5:   .  .  .  .  .  .  .
H6:   1  .  2  .  .  .  .   (1: Khoái [0,6]; 2: Lão [2,6])
```

- **Thứ tự hành động của địch (`thu_tu_dich`):** `["2,4", "5,0", "5,4"]`

---

## 4. Lời Giải Chuẩn Không Mất Tướng (Walkthrough)

### Hiệp 1:
- B1 tại `(2,4)` đang nhắm đánh ô `(2,3)` phía Bắc.
- **Nguyễn Khoái:** Di chuyển từ `(0,6)` lên `(1,4)`. Đánh ô `(2,4)`. Đòn chém gây 2 sát thương và đẩy B1 sang ô `(3,4)` — đúng vào dòng sông `~`! B1 rơi xuống nước chết chìm ngay lập tức.
- **Phạm Ngũ Lão:** Di chuyển từ `(2,6)` lên `(2,5)`. B2 tại `(5,4)` đang ở cùng hàng ngang cách 3 ô. Lão phóng lao vào `(5,4)`, gây 1 sát thương lên B2 (máu B2 còn 2/3).
- **Lượt địch:** B2 và B3 tiến lại gần tìm mục tiêu tiếp theo.

### Hiệp 2:
- **Phạm Ngũ Lão:** Phóng thêm một mũi lao vào B2 đang áp sát qua dải đất `(3,3)` hoặc kề bờ sông, rút máu B2 còn 1.
- **Nguyễn Khoái:** Di chuyển chặn đường, vung đao chém dứt điểm B2 hoặc đẩy B2 xuống sông.

### Hiệp 3:
- Hai tướng phối hợp tiêu diệt nốt B3 (đẩy rơi sông hoặc lao + chém dứt điểm).
- **Kết quả:** Toàn thắng, không mất máu nào.
