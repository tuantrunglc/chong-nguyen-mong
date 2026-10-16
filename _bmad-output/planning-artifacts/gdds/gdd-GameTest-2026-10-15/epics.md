---
title: 'Epics: Chống Nguyên Mông (prototype)'
created: '2026-10-15'
updated: '2026-10-15'
---

# Development Epics

Ngân sách: 13 tuần × 10 giờ ≈ 130 giờ. Các epic làm tuần tự.

## E0: Học Godot (tuần 1–3, khoảng 30 giờ)
- **Mục tiêu:** đủ vốn Godot để làm một game theo lượt trên lưới ô.
- **Có:** làm theo một hướng dẫn game lưới ô theo lượt (chọn ô, di chuyển, đổi lượt); thử xuất bản web.
- **Không có:** bất kỳ nội dung nào của game thật.
- **Chơi được khi xong:** một quân đi được trên lưới, chạy trên trình duyệt.
- **Phụ thuộc:** không có.

## E1: Bàn cờ & di chuyển (tuần 4–5, khoảng 20 giờ)
- **Mục tiêu:** dựng được bàn cờ thật từ dữ liệu.
- **Có:**
  - Đọc bàn 7×7 và vị trí các quân từ file dữ liệu trận.
  - Hiển thị các loại ô và quân dạng đồng tròn.
  - Chọn tướng, tô sáng các ô đi được trong 3 ô theo 4 hướng.
  - Đi xuyên qua quân mình, không đi xuyên qua quân địch.
  - Hủy nước đi.
  - Nút kết thúc lượt.
- **Không có:** đánh, AI địch.
- **Chơi được khi xong:** di chuyển 3 tướng trên bàn của trận 1.
- **Phụ thuộc:** E0.

## E2: Combat cốt lõi (tuần 6–8, khoảng 30 giờ) ⚠️ rủi ro cao nhất
- **Mục tiêu:** chạy đúng luật "đánh vào ô".
- **Có:**
  - Đòn của 3 tướng: Nguyễn Khoái đánh và đẩy, Phạm Ngũ Lão phóng lao, Trần Khánh Dư kéo.
  - Máu, tướng gục.
  - Quân Bộ binh, Kỵ binh, Cung kỵ.
  - Pha địch chuẩn bị (di chuyển, báo đòn kèm thứ tự) và pha địch ra đòn theo đúng ô hoặc hướng đã báo.
  - Đòn của địch dịch theo khi quân đó bị đẩy hoặc kéo.
  - Va chạm.
  - Sông nhấn chìm quân Nguyên.
  - Thắng và thua với kiểu nhiệm vụ Tiêu diệt.
  - Rê chuột xem máu, đòn sắp đánh, thứ tự ra đòn.
- **Không có:** rừng, chông, kho lương, mưu kế, quân tiếp viện.
- **Chơi được khi xong:** chơi trọn trận 1.
- **Mốc kiểm tra cuối tuần 8:** tác giả tự chơi. Nếu chán thì sửa luật trước khi làm tiếp.
- **Nếu trễ:** cắt Cung kỵ và trận 5.
- **Phụ thuộc:** E1.

## E3: Địa hình & mưu kế (tuần 9–10, khoảng 20 giờ)
- **Có:**
  - Rừng (chặn đường, chặn tầm đánh).
  - Hầm chông.
  - Kho lương (hồi máu cho quân Nguyên).
  - Mưu kế Sát Thát và Vườn không nhà trống.
  - Quân tiếp viện, kèm báo trước và luật chặn ô.
  - Kiểu nhiệm vụ Giữ ải: 5 hiệp, có ô ải.
  - Chơi lại hiệp, 1 lần mỗi trận.
- **Chơi được khi xong:** chơi được trận 4.
- **Phụ thuộc:** E2.

## E4: Năm trận & chơi thử (tuần 11–13, khoảng 30 giờ)
- **Có:**
  - Thiết kế 5 trận bằng dữ liệu, mỗi trận có ít nhất một lời giải không mất tướng.
  - Màn hình chuyển trận, hồi máu giữa các trận.
  - Mở mưu kế theo trận.
  - Nút tua nhanh pha địch.
  - Tự lưu sau mỗi trận.
  - Xuất bản web, chạy thử trên Chrome, Firefox, Edge.
  - Cho 3–5 người thân chơi thử, ghi lại các dấu hiệu trong Success Metrics.
- **Nếu trễ:** cắt trận 5.
- **Chơi được khi xong:** prototype hoàn chỉnh trên web.
- **Phụ thuộc:** E3.

## Giai đoạn 1 (chưa chia chi tiết)
- E5: Bản đồ roguelite
- E6: Phần thưởng & mở khóa
- E7: Trận Bạch Đằng
- E8: Hình ảnh & âm thanh
- E8b: Nội dung chữ: giới thiệu trận, sự kiện lịch sử, mô tả tướng, trích *Hịch tướng sĩ* (theo kết quả `gds-create-narrative`)
- E9: Phát hành web
  - Danh sách kiểm tra trước khi phát hành:
    - Đối chiếu tiểu sử, vai trò tướng và địa danh với *Toàn thư*, *Cương mục*, *Việt Nam sử lược*; ghi nguồn và ghi rõ chỗ hư cấu.
    - Kiểm tra trang phục, vũ khí thời Trần trong mọi hình ảnh; sửa tay hình AI.
    - Khai báo dùng AI theo quy định của itch.io (và Steam về sau).
    - Kiểm tra bản quyền nhạc và bản thu âm.
    - Tìm hiểu Nghị định 147/2024 có áp dụng cho bản web miễn phí không.
    - Cho người lạ (không phải người thân) chơi thử.
    - Chốt tên game (tiếng Việt, có thể kèm tên tiếng Anh).
    - Giới thiệu trong các cộng đồng mê sử.
