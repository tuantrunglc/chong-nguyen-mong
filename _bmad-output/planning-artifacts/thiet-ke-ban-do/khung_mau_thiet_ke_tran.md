# Khung Mẫu Thiết Kế Trận Đấu (Battle Design Template)

Dùng khung mẫu này mỗi khi tác giả hoặc game designer thiết kế một màn chơi mới.

---

## 1. Thông Tin Chung
- **Mã trận:** `tran_XX` (ví dụ: `tran_02`)
- **Tên hiển thị:** Tên trận gắn với địa danh lịch sử năm 1288 (ví dụ: *Ải Lãnh Kinh*)
- **Kiểu nhiệm vụ:** `tieu_diet` (Tiêu diệt toàn bộ quân Nguyên) hoặc `giu_ai` (Bảo vệ ô ải)
- **Giới hạn hiệp:** Không giới hạn (Trận 1–2) hoặc X hiệp (Trận 3 trở đi)
- **Điểm Lòng dân:** Mặc định 0 (nếu không có làng) hoặc 3 (nếu có làng)
- **Mưu kế mở:** Không có / `vuon_khong_nha_trong` / `sat_that`
- **Sự kiện lịch sử bám sát:** Trích từ *Đại Việt sử ký toàn thư* hoặc *Việt Nam sử lược*.

---

## 2. Ý Đồ Chiến Thuật & Luật Được Dạy
- **Bài học cốt lõi:** Người chơi học được quy tắc gì mới ở trận này?
- **Khắc chế then chốt:** Cạm bẫy hoặc đòn phối hợp chính để giải thế cờ.

---

## 3. Sa Bàn Thiết Kế (Grid Layout)
- **Kích thước:** `Cột x Hàng` (từ 5×5 đến 10×8)

### Bản đồ Địa hình:
```text
Cột:  0  1  2  3  4  5
H0:  .  .  .  ~  .  .
H1:  .  #  .  ~  .  .
...
```

### Bản đồ Quân cờ khởi đầu:
```text
Cột:  0  1  2  3  4  5
H0:  .  .  .  .  .  .
H1:  .  B  .  .  K  .
...
```

- **Tướng tham chiến:** 1 (Khoái), 2 (Lão), 3 (Dư)
- **Quân Nguyên & Thứ tự hành động (`thu_tu_dich`):** Danh sách tọa độ `"Cột,Hàng"` theo thứ tự AI hành động.
- **Lịch tiếp viện (`tiep_vien`):** (nếu có) Hiệp xuất hiện, loại quân, tọa độ.

---

## 4. Lời Giải Chuẩn Không Mất Tướng (Walkthrough)

### Hiệp 1:
- **Tướng A:** Đi đến `(x, y)`, Đánh ô `(x, y)`.
- **Tướng B:** ...
- **Kết thúc lượt:** Địch ra đòn như thế nào? (Ai dính đòn của ai, ai bị chặn?)

### Hiệp 2:
- ...

---

## 5. Danh Sách Kiểm Tra Nghiệm Thu (Acceptance Checklist)
- [ ] File dữ liệu `.json` hợp lệ, nạp được qua `LevelLoader`.
- [ ] Không có quân Nguyên bị kẹt ở ô không hợp lệ (trên sông/rừng).
- [ ] Đủ điều kiện thắng khi tiêu diệt hết địch / giữ vững số hiệp.
- [ ] Đã chuyển lời giải thành kịch bản tự động trong `game/tests/kich_ban/tran/`.
- [ ] Chạy `tools/test.sh` đạt 100% Pass.
