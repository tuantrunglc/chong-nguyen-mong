# Thiết Kế Bản Đồ: Trận 2 – Ải Lãnh Kinh

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_02`
- **Tên hiển thị:** *Ải Lãnh Kinh*
- **Kiểu nhiệm vụ:** `tieu_diet`
- **Giới hạn hiệp:** Không giới hạn (Trận dạy chơi cơ bản)
- **Tướng tham chiến:** Nguyễn Khoái (`1`), Phạm Ngũ Lão (`2`)
- **Quân Nguyên:** 2 Kỵ binh Mông Cổ (`K`), 1 Bộ binh Nguyên (`B`)
- **Địa hình chính:** Rừng rậm (`#`), Sông (`~`), Cỏ (`.`)
- **Kích thước sa bàn:** 6 cột × 7 hàng (6×7)
- **Sự kiện lịch sử:** 
  > Ngày 24 tháng 11 năm Đinh Hợi (1288), Hưng Đức hầu Quán chỉ huy cấm quân chặn đánh quân Nguyên ở ải Lãnh Kinh, lợi dụng địa hình rừng núi hiểm trở bắn tên độc và phục kích, buộc quân Nguyên phải lui về ải Vũ Cao (*Đại Việt sử ký toàn thư*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học
1. **Dạy cơ chế Kỵ binh xung phong:** Kỵ binh đe dọa toàn bộ một hàng thẳng theo hướng nó nhìn. Người chơi phải quan sát mũi tên báo đòn đỏ để tránh đứng trên hàng.
2. **Dạy cơ chế Rừng chặn đòn xung phong (Story 3.1):** Rừng đứng giữa chặn đứng mũi giáo xung phong của Kỵ binh, che chắn an toàn cho tướng phía sau.
3. **Dạy cơ chế Địch đánh trúng nhau (Friendly Fire):** Lừa Kỵ binh xung phong đâm trúng lưng Bộ binh đồng đội phía trước, hạ gục địch mà không tốn máu tướng.

---

## 3. Sa Bàn Bố Cục (6×7)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5
H0:  .  .  #  ~  .  .
H1:  .  .  .  ~  .  .
H2:  #  .  .  ~  .  #
H3:  .  .  #  .  .  .
H4:  .  .  .  ~  .  .
H5:  .  .  .  ~  .  .
H6:  .  .  .  ~  .  .
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5
H0:  .  .  .  .  .  .
H1:  .  .  K  .  .  .   (Kỵ binh 1 nhắm xuống phía Nam)
H2:  .  .  .  .  B  .   (Bộ binh đứng cạnh sông)
H3:  .  .  .  .  .  .
H4:  .  K  .  .  .  .   (Kỵ binh 2 nhắm sang Đông)
H5:  .  .  .  .  .  .
H6:  1  .  2  .  .  .   (Khoái tại 0,6; Lão tại 2,6)
```

- **Thứ tự hành động địch (`thu_tu_dich`):** `["2,1", "4,2", "1,4"]`
- **Mưu kế mở:** Chưa có.

---

## 4. Lời Giải Chuẩn Không Mất Tướng (Walkthrough)

### Hiệp 1:
1. **Nguyễn Khoái (1):** Di chuyển từ `(0, 6)` lên `(0, 4)`. Đứng né khỏi hàng xung phong của Kỵ binh 2.
2. **Phạm Ngũ Lão (2):** Tiến từ `(2, 6)` lên `(2, 4)`. Đứng sau khối rừng `(2, 3)` để che chắn đòn của Kỵ binh 1.
3. **Pha địch ra đòn:** 
   - Kỵ binh 1 xung phong theo cột 2 húc thẳng vào khối rừng `(2, 3)`, bị chặn đứng an toàn!
   - Kỵ binh 2 xung phong theo hàng 4 lao thẳng sang Đông, húc trúng Bộ binh, gây sát thương va chạm cho chính đồng đội!

### Hiệp 2:
1. Nguyễn Khoái tiến vào mép sườn Bộ binh, chém Mạch đao hất văng Bộ binh xuống dòng sông `~` tại `(3, 2)` -> Bộ binh chết đuối!
2. Phạm Ngũ Lão phóng lao tầm xa kết liễu Kỵ binh 1.
3. Thu dọn Kỵ binh 2 ở hiệp tiếp theo mà không mất một giọt máu.

---

## 5. Trạng Thái File Trận
- File JSON mẫu: [game/data/tran/tran_02.json](file:///home/trung.nguyen11/Documents/GameTest/game/data/tran/tran_02.json)
