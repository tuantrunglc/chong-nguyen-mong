# Thiết Kế Bản Đồ: Trận 3 – Phục Kích Ải Nội Bàng

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_03`
- **Tên hiển thị:** *Phục Kích Ải Nội Bàng*
- **Kiểu nhiệm vụ:** `tieu_diet`
- **Giới hạn hiệp:** `5` hiệp (Đoàn tiền trạm quân Nguyên đang vượt ải, phải tiêu diệt trước khi địch thoát ra)
- **Tướng tham chiến:** 
  - `1`: Nguyễn Khoái (Cận chiến, đẩy lùi 1 ô)
  - `2`: Phạm Ngũ Lão (Phóng lao 2–4 ô)
  - `3`: Trần Khánh Dư (Khống chế, kéo mục tiêu trong 3 ô về phía mình 2 ô)
- **Quân Nguyên:** 
  - 1 Bộ binh Nguyên (`B`, 3 máu)
  - 1 Kỵ binh Mông Cổ (`K`, 2 máu)
  - 1 Cung kỵ Nguyên (`C`, 1 máu, bắn xa 2–3 ô)
- **Địa hình chính:** Cỏ (`.`), Hầm chông tre (`^`), Rừng trúc (`#`), Sông nhỏ (`~`)
- **Kích thước sa bàn:** 6 cột × 6 hàng (6×6)
- **Sự kiện lịch sử:** 
  > Quân Nguyên tiến qua ải Nội Bàng hiểm trở, núi non chật hẹp. Quân Đại Việt ngầm cắm hầm chông, bố trí phục binh trên sườn núi kéo đứt đội hình giặc (*Việt Nam sử lược*).

---

## 2. Ý Đồ Chiến Thuật & Bài Học
1. **Giới thiệu Trần Khánh Dư & Đòn kéo cờ (`keo`):** Dư kéo địch về phía mình 2 ô mà không gây sát thương trực tiếp. Nhưng nếu kéo địch lướt qua hoặc rơi trúng hầm chông (`^`), địch sẽ bị đâm mất máu!
2. **Cơ chế Hầm chông tre (`^`):** Khác với Sông (chết ngay), Hầm chông là ô đi được, nhưng cứ mỗi lần di chuyển/bị đẩy/bị kéo qua hoặc rơi vào thì mất 1 máu.
3. **Đối phó Cung kỵ (`C`):** Cung kỵ chỉ có 1 máu nhưng tầm bắn xa 2–3 ô và đạn bay qua người. Cần dùng Lão phóng lao kết liễu ngay từ lượt 1 hoặc dùng Dư kéo lệch tầm ngắm.
4. **Phối hợp liên hoàn 3 tướng:**
   - Dư kéo địch vào bẫy chông hoặc kéo địch vào đúng tầm đao của Khoái / tầm lao của Lão.
   - Khoái đẩy địch tiếp vào chông hoặc vào tường rừng/địch khác để gây va chạm.

---

## 3. Sa Bàn Bố Cục (6×6)

### Địa hình (`dia_hinh`):
```text
Cột:  0  1  2  3  4  5
H0:   #  .  .  .  .  #
H1:   .  .  ^  .  .  .
H2:   .  ^  ^  .  .  .
H3:   .  .  .  .  #  .
H4:   .  .  .  ~  ~  .
H5:   .  .  .  .  .  .
```

### Quân cờ khởi đầu (`quan`):
```text
Cột:  0  1  2  3  4  5
H0:   .  .  C  .  K  .   (C tại [2,0] ngắm bắn Nam; K tại [4,0] ngắm xung phong Nam)
H1:   .  .  .  .  .  .
H2:   .  .  .  B  .  .   (B tại [3,2] vung đao ngắm Tây)
H3:   .  .  .  .  .  .
H4:   .  .  .  .  .  .
H5:   .  1  3  2  .  .   (Khoái [1,5], Dư [2,5], Lão [3,5])
```

- **Thứ tự hành động của địch (`thu_tu_dich`):** `["2,0", "4,0", "3,2"]` (Cung kỵ bắn trước, Kỵ binh phi sau, Bộ binh quét đao).

---

## 4. Lời Giải Chuẩn Hoàn Hảo (Walkthrough)

### Hiệp 1:
- Cung kỵ C tại `(2,0)` đang ngắm bắn thẳng xuống cột 2 (ô `(2,2)` và `(2,3)`).
- Kỵ binh K tại `(4,0)` đang nhắm xung phong xuống cột 4.
- Bộ binh B tại `(3,2)` đang chuẩn bị chém sang Tây `(2,2)`.
- **Nước đi:**
  1. **Phạm Ngũ Lão:** Bước sang `(4,5)`? Không, Kỵ binh đang nhắm cột 4! Lão bước sang `(3,4)` hoặc đứng nguyên phóng lao thẳng lên `(3,2)` trúng B (máu B còn 2/3), hoặc di chuyển sang `(0,5)` phóng lao chéo lên C? Cung kỵ chỉ có 1 máu: Lão di chuyển lên `(2,4)` (nằm ngoài ô đỏ của C vì C ngắm `2,2` và `2,3`) rồi phóng lao thẳng lên `(2,0)` dứt điểm ngay Cung kỵ C!
  2. **Trần Khánh Dư:** Di chuyển lên `(1,3)`. Kéo Bộ binh B tại `(3,2)` sang Tây. B bị kéo qua ô chông `(2,2)` (mất 1 máu) và rơi xuống ô `(1,2)` (trúng ô chông tiếp theo, mất thêm 1 máu)! Máu B tụt còn 1/3!
  3. **Nguyễn Khoái:** Di chuyển từ `(1,5)` lên `(1,3)` hoặc `(0,2)`. Chém B dứt điểm hoàn toàn.
- **Cuối Hiệp 1:** Kỵ binh K lao xuống theo cột 4 nhưng không có ai trên đường đi, K dừng lại ở cuối hàng.

### Hiệp 2:
- Cả 3 tướng quay sang quây Kỵ binh K:
  - Dư kéo K vào hầm chông `(2,2)` hoặc kéo K lại gần.
  - Khoái chém 2 sát thương đẩy K lọt xuống sông `(3,4)` hoặc dứt điểm ngay tại chỗ.
- **Kết quả:** Quét sạch toàn bộ 3 quân địch trong 2 hiệp, hoàn thành xuất sắc trước giới hạn 5 hiệp, 0 tướng chịu sát thương!
