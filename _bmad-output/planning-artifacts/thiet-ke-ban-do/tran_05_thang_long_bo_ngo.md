# Thiết Kế Bản Đồ: Trận 5 – Thăng Long Bỏ Ngỏ

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_05`
- **Tên hiển thị:** *Thăng Long Bỏ Ngỏ*
- **Kiểu nhiệm vụ:** `giu_ai` (Bảo vệ cổng thành/ô Ải `A` trong 5 hiệp, hoặc tiêu diệt toàn bộ quân địch)
- **Giới hạn hiệp:** `5` hiệp
- **Mưu kế mở:** `vuon_khong_nha_trong` (Kích hoạt một lần duy nhất: thiêu rụi toàn bộ Kho lương `L`, tước đoạt khả năng hồi máu của địch)
- **Tướng tham chiến:** 
  - `1`: Nguyễn Khoái
  - `2`: Phạm Ngũ Lão
  - `3`: Trần Khánh Dư
- **Quân Nguyên khởi đầu:** 
  - 2 Bộ binh Nguyên (`B1`, `B2`, 3 máu)
  - 1 Cung kỵ Nguyên (`C`, 1 máu)
- **Lịch Tiếp viện (`tiep_vien`):**
  - Hiệp 3: 1 Kỵ binh Mông Cổ (`K`) xuất hiện từ cổng Bắc `(3,0)`.
- **Địa hình chính:** Cỏ (`.`), Kho lương (`L`), Ô Ải cửa thành (`A`), Rừng tre (`#`)
- **Kích thước sa bàn:** 8 cột × 7 hàng (8×7)
- **Sự kiện lịch sử:** 
  > Đầu năm 1288, Thoát Hoan kéo quân vào chiếm kinh thành Thăng Long nhưng chỉ thấy vườn không nhà trống, lương thực cất giấu sạch sẽ. Quân Nguyên đóng trong thành thiếu thốn, khốn đốn vì dịch bệnh và đói khát (*Việt Nam sử lược*, *Đại Việt sử ký toàn thư*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học
1. **Dạy cơ chế Kho lương (`L`) & Mưu kế *Vườn không nhà trống*:**
   - Quân Nguyên đứng kề kho lương sẽ được hồi 1 máu mỗi cuối hiệp. Nếu người chơi chém dở mà không dứt điểm, địch sẽ liên tục hồi phục.
   - Sử dụng thẻ Mưu kế *Vườn không nhà trống*: Đốt cháy toàn bộ kho lương trên bản đồ, chấm dứt khả năng tiếp tế của giặc.
2. **Dạy cơ chế Giữ Ải (`A`):**
   - Ô Ải nằm ở phía Nam sa bàn đại diện cho lối vào hành cung. Nếu quân Nguyên bước được vào ô `A`, phòng tuyến sụp đổ và người chơi thua trận.
   - Người chơi phải dàn đội hình phòng ngự chẹn họng, sử dụng kỹ năng đẩy và kéo để hất địch văng ra xa khỏi ô `A`.
3. **Đối phó quân Tiếp viện (`tiep_vien`):**
   - Người chơi phải căn nhịp thời gian: không chỉ tiêu diệt đợt 1 mà phải sẵn sàng thế cờ đón đầu Kỵ binh tiếp viện phi xuống ở Hiệp 3.

---

## 3. Sa Bàn Bố Cục (8×7)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5  6  7
H0:   #  .  .  .  .  .  .  #
H1:   .  .  L  .  .  L  .  .   (Kho lương L1 [2,1], L2 [5,1])
H2:   .  .  .  .  .  .  .  .
H3:   .  #  .  .  .  .  #  .
H4:   .  .  .  .  .  .  .  .
H5:   .  .  .  .  .  .  .  .
H6:   .  .  .  A  A  .  .  .   (Cửa Ải thành Thăng Long A tại [3,6] và [4,6])
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5  6  7
H0:   .  .  .  .  .  .  .  .
H1:   .  B  .  .  .  .  B  .   (B1 [1,1] cạnh L1; B2 [6,1] cạnh L2)
H2:   .  .  .  C  .  .  .  .   (Cung kỵ C [3,2])
H3:   .  .  .  .  .  .  .  .
H4:   .  .  .  .  .  .  .  .
H5:   .  .  1  3  2  .  .  .   (Khoái [2,5], Dư [3,5], Lão [4,5] chặn trước ải)
H6:   .  .  .  .  .  .  .  .
```

- **Thứ tự hành động của địch (`thu_tu_dich`):** `["3,2", "1,1", "6,1"]`
- **Tiếp viện (`tiep_vien`):** `[{"hiep": 3, "loai": "K", "toado": [3, 0]}]`

---

## 4. Lời Giải Chuẩn Giữ Ải Thành Công (Walkthrough)

### Hiệp 1:
- Cung kỵ C tại `(3,2)` ngắm bắn thẳng xuống hướng ải. B1 và B2 đứng gần kho lương chuẩn bị tràn xuống.
- **Lão:** Bước lên `(3,4)` ném lao thẳng lên `(3,2)` dứt điểm ngay Cung kỵ C (1 máu).
- **Kích hoạt Mưu kế *Vườn không nhà trống*:** L1 và L2 bốc cháy, xóa sổ khả năng hồi máu của B1 và B2!
- **Dư & Khoái:** Dàn hàng ngang vững chắc tại Hàng 4, sẵn sàng nghênh tiếp hai cánh của B1 và B2.

### Hiệp 2:
- B1 và B2 tiến xuống Hàng 2 và Hàng 3.
- Dư kéo B1 vào giữa bẫy vây hãm. Khoái chém đẩy lùi B1 vào rừng hoặc đồng đội gây va chạm. Lão ném lao hỗ trợ.

### Hiệp 3 (Kỵ binh địch tăng viện):
- Kỵ binh K xuất hiện từ `(3,0)` phi thẳng xuống trung lộ.
- Nhờ đường tiến bị cây rừng `(1,3)` và `(6,3)` bóp hẹp, Dư đứng góc an toàn kéo K chệch hướng, Khoái kết liễu B1/B2, Lão phóng lao tỉa máu K.

### Hiệp 4–5:
- Dứt điểm toàn bộ quân giặc trước cổng ải.
- **Kết quả:** Ô Ải `A` không một tên giặc nào chạm tới, kinh thành toàn vẹn!
