# Thiết Kế Bản Đồ: Trận 6 – Đại Thắng Bạch Đằng Giang

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_06`
- **Tên hiển thị:** *Quyết Chiến Bạch Đằng Giang*
- **Kiểu nhiệm vụ:** `tieu_diet` (Đại tiễu sát – tiêu diệt toàn bộ thủy bộ quân Nguyên)
- **Giới hạn hiệp:** `7` hiệp
- **Mưu kế mở:** `sat_that` (Sát Thát: Bừng bừng hào khí Đông A – tăng +1 sát thương và +1 ô cự ly cho tất cả kỹ năng của 3 tướng trong 1 hiệp quyết định)
- **Tướng tham chiến:** 
  - `1`: Nguyễn Khoái (Tiên phong xung kích quân Thánh dực)
  - `2`: Phạm Ngũ Lão (Phục binh trên bờ ném lao bách phát bách trúng)
  - `3`: Trần Khánh Dư (Thủy sư đô đốc kéo lật thuyền giặc)
- **Quân Nguyên:** 
  - 2 Kỵ binh Mông Cổ (`K1`, `K2`)
  - 2 Bộ binh Nguyên (`B1`, `B2`)
  - 1 Cung kỵ Nguyên (`C`)
- **Địa hình chính:** Dòng sông Bạch Đằng (`~`), Bãi cọc chông ngầm (`^`), Bãi bồi / Cù lao cỏ (`.`), Rừng rậm ven sông (`#`)
- **Kích thước sa bàn:** 8 cột × 8 hàng (8×8)
- **Sự kiện lịch sử:** 
  > Ngày 8 tháng 3 năm Mậu Tý (1288), thủy quân giặc kéo đến sông Bạch Đằng. Hưng Đạo Vương đón đánh giả thua rút lui. Khi nước thủy triều rút mạnh, thuyền giặc vướng vào bãi cọc nhọn. Quân mai phục hai bên bờ cùng quân Thánh dực của Nguyễn Khoái, đạo quân của Trần Khánh Dư, Phạm Ngũ Lão đồng loạt xông ra đánh lớn, bắt sống Ô Mã Nhi, Phàn Tiếp, chém chết vô số quân thù (*Đại Việt sử ký toàn thư*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học Đỉnh Cao
1. **Đỉnh cao phối hợp cơ chế (Grand Finale):** 
   - Trận chiến đỉnh cao kết hợp mọi cơ chế đã học: Sông sâu (chết đuối ngay), Bãi cọc nhọn (mất máu liên tục khi va/rơi vào), Rừng rậm che chắn tầm bắn, và Địch va chạm nhau.
2. **Kích hoạt Mưu kế *Sát Thát*:**
   - Trong hiệp mang tính then chốt (thường là Hiệp 2 hoặc 3 khi địch đang tập trung đông nhất giữa bãi cọc và bờ sông), mở mưu kế *Sát Thát* để tạo cú quét sạch liên hoàn.
   - Khoái đẩy lùi 2 ô (hất địch xuyên qua bãi cọc xuống sông sâu), Dư kéo xa 4 ô kéo địch từ tít xa cắm đầu vào hàng cọc, Lão ném lao xa 5 ô gây 2 sát thương dứt điểm tướng giặc!
3. **Thế trận Gọng kìm Hào Khí Đông A:**
   - Lừa Kỵ binh Nguyên xung phong xuyên vào bãi cọc chông tre để tự chịu sát thương, rồi dùng đòn kéo của Dư và đòn chém của Khoái dọn sạch tàn quân.

---

## 3. Sa Bàn Bố Cục (8×8)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5  6  7
H0:   #  .  .  .  .  .  .  #
H1:   .  .  .  ~  ~  .  .  .   (Dòng sông sâu Bạch Đằng)
H2:   .  .  ^  ^  ^  ^  .  .   (Bãi cọc nhọn đóng ngầm giữa lòng sông)
H3:   .  .  ^  ^  ^  ^  .  .
H4:   .  .  .  ~  ~  .  .  .
H5:   .  #  .  .  .  .  #  .   (Bờ nam, cồn cát ven sông)
H6:   .  .  .  .  .  .  .  .
H7:   .  .  .  .  .  .  .  .
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5  6  7
H0:   .  K  .  C  .  K  .  .   (K1 [1,0], Cung kỵ C [3,0], K2 [5,0])
H1:   .  .  B  .  B  .  .  .   (B1 [2,1], B2 [4,1] dàn đội hình bộ binh)
H2:   .  .  .  .  .  .  .  .   (Bãi cọc chông)
H3:   .  .  .  .  .  .  .  .
H4:   .  .  .  .  .  .  .  .
H5:   .  .  .  .  .  .  .  .
H6:   .  .  1  3  2  .  .  .   (Ba danh tướng dàn trận: Khoái [2,6], Dư [3,6], Lão [4,6])
H7:   .  .  .  .  .  .  .  .
```

- **Thứ tự hành động của địch (`thu_tu_dich`):** `["3,0", "1,0", "5,0", "2,1", "4,1"]`

---

## 4. Lời Giải Chuẩn Đại Thắng Bạch Đằng (Walkthrough)

### Hiệp 1 (Dụ địch vào bãi cọc):
- Cung kỵ C và 2 Kỵ binh nhắm xuống phía Nam.
- Dư bước lên `(3,5)` kéo Bộ binh B1 hoặc B2 lướt vào bãi cọc `(3,3)`, chông tre đâm xuyên mất 1 máu.
- Lão di chuyển góc sườn phóng lao tỉa bớt máu quân kỵ hoặc dứt điểm Cung kỵ C.
- Khoái di chuyển giữ vị trí đón đầu các mũi xung phong của giặc.

### Hiệp 2 (Khai mở Mưu Kế *Sát Thát*):
- Kích hoạt **Hào Khí Đông A: SÁT THÁT**! Toàn quân được búp sức mạnh vũ bão.
- Trần Khánh Dư vung xích sắt kéo Kỵ binh giặc từ mé bờ sông lôi thẳng xộc qua hai hàng cọc nhọn `(2,2)` và `(2,3)`, cọc nhọn xé toạc chiến mã giặc tan tác!
- Nguyễn Khoái hô vang khẩu hiệu xung trận, cầm đao đại phá, chém một đòn đẩy bật tên tướng giặc văng 2 ô rơi thẳng vào dòng xoáy nước sâu `~` chết chìm!
- Phạm Ngũ Lão tung ngọn trường lao thần tốc bay xuyên qua 5 ô bàn cờ găm thẳng vào ngực tên giặc cuối cùng.

### Hiệp 3:
- Quét sạch toàn bộ tàn dư quân Nguyên trước khi thủy triều dâng lên trở lại.
- **Kết quả:** Đại thắng vẻ vang, bảo toàn nguyên vẹn 3 tướng, lưu danh muôn đời sử sách Đại Việt!
