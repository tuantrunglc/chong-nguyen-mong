# Thiết Kế Bản Đồ: Trận 4 – Làng Quanh Vạn Kiếp

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_04`
- **Tên hiển thị:** *Làng Quanh Vạn Kiếp*
- **Kiểu nhiệm vụ:** `tieu_diet` kết hợp bảo vệ
- **Giới hạn hiệp:** `6` hiệp
- **Chỉ số Lòng dân:** Khởi đầu `3` điểm. Nếu Lòng dân = 0 -> Thất bại ngay lập tức!
- **Tướng tham chiến:** 
  - `1`: Nguyễn Khoái
  - `2`: Phạm Ngũ Lão
  - `3`: Trần Khánh Dư
- **Quân Nguyên:** 
  - 2 Bộ binh Nguyên (`B1`, `B2`, 3 máu)
  - 1 Kỵ binh Mông Cổ (`K`, 2 máu)
- **Địa hình chính:** Cỏ (`.`), Làng quê (`D`), Rừng (`#`), Sông (`~`)
- **Kích thước sa bàn:** 7 cột × 6 hàng (7×6)
- **Sự kiện lịch sử:** 
  > Cuối tháng 12 năm Đinh Hợi, quân Nguyên tràn vào khu vực Vạn Kiếp, Chí Linh, Phả Lại cướp bóc, đốt phá xóm làng. Tướng sĩ Đại Việt ngày đêm chiến đấu bảo vệ thôn trang, yểm trợ nhân dân rút lui an toàn (*Đại Việt sử ký toàn thư*, *Việt Nam sử lược*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học
1. **Dạy cơ chế Bảo vệ Làng & Lòng dân:**
   - Làng (`D`) là mục tiêu thiêng liêng. Quân địch ưu tiên nhắm đòn vào Làng nếu kề bên hoặc trên đường xung phong.
   - Mỗi lần Làng bị trúng đòn hoặc bị quân cờ va chạm vào: **Lòng dân −1**.
2. **Kỹ thuật Chặn đường & Kéo giải vây:**
   - Khi Kỵ binh ngắm xung phong thẳng vào một ngôi làng, người chơi phải dùng Dư kéo lệch hướng Kỵ binh, hoặc dùng Khoái lấy thân mình đứng chắn trước làng (hoặc dùng rừng chắn).
   - Bộ binh đứng sát làng vung đao: Dư dùng roi kéo Bộ binh ra xa khỏi làng, hoặc Khoái chém đẩy văng Bộ binh ra hướng ngược lại.

---

## 3. Sa Bàn Bố Cục (7×6)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5  6
H0:   .  .  .  .  .  #  #
H1:   .  D  .  .  .  .  .   (Làng D1 tại [1,1])
H2:   .  .  .  #  .  .  .
H3:   .  .  .  .  .  D  .   (Làng D2 tại [5,3])
H4:   ~  ~  .  .  .  .  .   (Sông góc Tây Nam)
H5:   ~  ~  .  .  .  .  .
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5  6
H0:   .  .  K  .  .  .  .   (K tại [2,0] đang nhắm xuống phía Nam vào hàng làng)
H1:   .  .  .  B  .  .  .   (B1 tại [3,1] đang chuẩn bị tiến đánh D1 [1,1])
H2:   .  .  .  .  .  B  .   (B2 tại [5,2] đang vung đao nhắm vào D2 [5,3] ngay dưới!)
H3:   .  .  .  .  .  .  .
H4:   .  .  1  3  2  .  .   (Khoái [2,4], Dư [3,4], Lão [4,4])
H5:   .  .  .  .  .  .  .
```

- **Thứ tự hành động của địch (`thu_tu_dich`):** `["5,2", "3,1", "2,0"]`

---

## 4. Lời Giải Chuẩn Bảo Toàn Lòng Dân (Walkthrough)

### Nguy cơ ban đầu:
- B2 tại `(5,2)` đang nhắm đánh trực diện vào Làng D2 tại `(5,3)`. Nếu không can thiệp, D2 sẽ trúng đao và Lòng dân sẽ bị trừ ngay trong Hiệp 1!
- K tại `(2,0)` đang có đường chạy thẳng xuống Nam.

### Hiệp 1:
1. **Trần Khánh Dư:** Di chuyển từ `(3,4)` sang `(4,3)`. Dư đứng kề bên và phóng roi kéo B2 từ `(5,2)` sang Tây 2 ô về `(3,2)`. 
   -> Ngôi làng D2 hoàn toàn được giải nguy! Đòn chém của B2 đánh vào khoảng không ở `(5,3)` mà không trúng làng.
2. **Nguyễn Khoái:** Di chuyển từ `(2,4)` lên `(2,2)`. B2 lúc này vừa bị kéo đến `(3,2)` ngay kề bên Khoái. Khoái chém B2 gây 2 sát thương, đồng thời đẩy B2 va vào rừng rậm `(3,2) -> (4,2)` gây thêm va chạm, dứt điểm B2 ngay tại chỗ!
3. **Phạm Ngũ Lão:** Di chuyển từ `(4,4)` lên `(3,3)`. Lão ngắm bắn thẳng hàng lên B1 tại `(3,1)` (khoảng cách 2 ô), phóng lao gây 1 sát thương (B1 còn 2/3 máu).
- **Lượt địch:** 
  - B2 đã bị tiêu diệt, làng D2 an toàn tuyệt đối.
  - B1 tiến bước tìm cách tiếp cận làng D1.
  - K lao xuống nhưng bị chặn bởi chướng ngại vật hoặc dừng lại ngoài tầm nguy hiểm.

### Hiệp 2:
- Dư kéo K hoặc kéo B1 vào gần dòng sông phía Tây Nam `(1,4)` hoặc `(0,4)`.
- Khoái vung đao đẩy một tên rơi xuống sông chết chìm.
- Lão phóng lao kết liễu nốt tên còn lại.
- **Kết quả:** Thắng trọn vẹn, giữ vững 3/3 điểm Lòng Dân!
