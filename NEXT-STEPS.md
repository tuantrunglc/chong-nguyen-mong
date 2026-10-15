# Ghi chú làm tiếp: Chống Nguyên Mông (tên tạm)

Cập nhật lần cuối: 2026-10-15

## Đang ở đâu

| Bước | Trạng thái | File |
|---|---|---|
| Nghiên cứu thị trường | ✅ Xong | `_bmad-output/planning-artifacts/research/market-game-lich-su-viet-nam-2026-10-15/research.md` |
| Game Brief | ✅ Xong (final) | `_bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/brief.md` |
| GDD | 🟡 Bản nháp đầy đủ, **chưa chốt** | `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` |
| Epics | 🟡 Bản nháp | `.../gdds/gdd-GameTest-2026-10-15/epics.md` |
| Ghi chú sử 1287–1288 | ✅ Tra cứu sơ bộ | `.../gdds/gdd-GameTest-2026-10-15/history-notes-1288.md` |
| Kiến trúc, Sprint, Code | ⏳ Chưa làm | — |

## Game đã chốt (tóm tắt)

- **Thể loại:** tactics roguelite 2D theo lượt. Người chơi là Trần Hưng Đạo, đứng ngoài bàn cờ chỉ huy 3 tướng: Nguyễn Khoái (tiên phong, đẩy), Phạm Ngũ Lão (phóng lao), Trần Khánh Dư (kéo).
- **4 trụ cột:**
  1. Thấy trước, tính được
  2. Địa hình là vũ khí
  3. Tôn trọng lịch sử
  4. Nhỏ mà xong
- **Combat:**
  - Bàn 7×7.
  - Địch báo trước đòn đánh. Đòn đánh vào **ô** chứ không đánh vào người.
  - Địa hình: sông, rừng, hầm chông, kho lương.
  - Mưu kế: Sát Thát, Vườn không nhà trống.
- **Khán giả và phát hành:** người Việt mê sử. Bản web hoặc itch.io trước, Steam sau.
- **Công cụ và nguồn lực:** Godot, làm một mình, 10 giờ mỗi tuần, ngân sách vài trăm USD.
- **Mục tiêu 3 tháng:** prototype gồm 5 trận làm tay, cho người thân chơi thử.

## Việc cần làm tiếp (theo thứ tự)

Mỗi bước chạy trong một **cửa sổ context mới** của Claude Code.

1. **Chốt GDD:** chạy `/gds-gdd`, chọn *update/finalize* trên GDD hiện có.
   - Xác nhận cách chia Epic E0–E4 (130 giờ). Hiện đang ghi tạm theo đề xuất.
   - Đối chiếu GDD với brief, rồi chạy validator theo checklist.
   - Xử lý các mục còn treo:
     - Tầm kéo của Trần Khánh Dư: 2 ô hay 1 ô?
     - Vườn không nhà trống có quá mạnh không?
     - Hình ảnh quân cờ: chữ hoặc biểu tượng thì "chưa đẹp lắm".
   - Chuyển trạng thái GDD sang `final`.
2. **(Tùy chọn) Cốt truyện:** `/gds-create-narrative`.
3. **Kiến trúc:** `/gds-game-architecture`. Bước này bắt buộc.
4. **Epics & Stories:** `/gds-create-epics-and-stories`, sau đó `/gds-check-implementation-readiness`.
5. **Sprint:** `/gds-sprint-planning`, rồi lặp `/gds-create-story` → `/gds-dev-story` → `/gds-code-review`.

Muốn đi nhanh: sau khi chốt GDD, có thể dùng `gds-agent-game-solo-dev` để dựng ngay prototype combat (E0–E2) trong Godot, chưa cần qua bước kiến trúc.

Không nhớ đang ở bước nào thì chạy `/bmad-help`.

## Lưu ý

- Toàn bộ quyết định và lý do nằm trong `decision-log.md` của GDD và `.decision-log.md` của brief.
- **Phạm Ngũ Lão không có tên trong *Toàn thư* các năm 1287–1288.** Thông tin về ông lấy theo *Việt Nam sử lược*, nên trong game phải ghi chú nguồn.
- Chưa rõ Nghị định 147/2024 có áp dụng cho bản web miễn phí hay không. Cần tìm hiểu trước khi phát hành công khai.
