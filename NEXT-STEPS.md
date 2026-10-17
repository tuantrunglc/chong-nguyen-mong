# Ghi chú làm tiếp: Chống Nguyên Mông (tên tạm)

Cập nhật lần cuối: 2026-10-17

## Đang ở đâu

| Bước | Trạng thái | File |
|---|---|---|
| Nghiên cứu thị trường | ✅ Xong | `_bmad-output/planning-artifacts/research/market-game-lich-su-viet-nam-2026-10-15/research.md` |
| Game Brief | ✅ Xong (final) | `_bmad-output/planning-artifacts/briefs/brief-GameTest-2026-10-15/brief.md` |
| GDD | ✅ **Final** (2026-10-16) | `_bmad-output/planning-artifacts/gdds/gdd-GameTest-2026-10-15/gdd.md` |
| Epics (mức GDD) | ✅ Chốt E0–E4 | `.../gdds/gdd-GameTest-2026-10-15/epics.md` |
| Ghi chú sử 1287–1288 | ✅ Tra cứu sơ bộ | `.../gdds/gdd-GameTest-2026-10-15/history-notes-1288.md` |
| Kiến trúc game | ✅ Xong (9/9 bước) | `_bmad-output/planning-artifacts/game-architecture.md` |
| Luật cho AI (project context) | ✅ Xong (57 luật) | `_bmad-output/project-context.md` |
| Epic & story (chi tiết) | ✅ Xong: 5 epic, 45 story | `_bmad-output/planning-artifacts/epics.md` |
| Kiểm tra sẵn sàng, Sprint, Code | ⏳ Chưa làm | — |

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
- **Công cụ và nguồn lực:** Godot 4.7.2 (chỉ GDScript, web đơn luồng), GUT 9.7.1, làm một mình, 10 giờ mỗi tuần, ngân sách vài trăm USD.
- **Cách làm:** AI viết toàn bộ code; tác giả quyết luật và test. Luật được viết thành **kịch bản bàn cờ chữ**, tác giả duyệt bằng `tools/xem_kich_ban.sh` trước khi AI code. Một lệnh kiểm tra tất cả: `tools/test.sh`.
- **Mục tiêu 3 tháng:** prototype gồm 5 trận làm tay, cho người thân chơi thử.

## Việc cần làm tiếp (theo thứ tự)

Mỗi bước chạy trong một **cửa sổ context mới** của Claude Code (`/clear`).

1. ~~Chốt GDD~~ (2026-10-16).
2. ~~Kiến trúc~~, ~~project context~~, ~~epic & story~~ (2026-10-16/17). GDD đã được bổ sung các luật chốt trong lúc làm kiến trúc.
3. **Kiểm tra sẵn sàng:** `/gds-check-implementation-readiness`. Bước này bắt buộc, làm tiếp theo.
4. **Sprint:** `/gds-sprint-planning`.
5. **Làm từng story, bắt đầu từ Story 0.1:** `/gds-create-story` → `/gds-dev-story` → (tùy chọn) `/gds-code-review`. Sau mỗi story: chạy `tools/test.sh` và làm theo các bước Cho/Khi/Thì của story.
6. **(Tùy chọn, giai đoạn 1) Cốt truyện:** `/gds-create-narrative`.

Không nhớ đang ở bước nào thì chạy `/bmad-help`.

## Bản web trên itch.io

- Trang: https://tuantrunglc.itch.io/hao-khi-dong-a (Draft, chỉ xem được khi đăng nhập tài khoản `tuantrunglc`).
- Build: `tools/build_web.sh`. Đẩy lên: `tools/deploy_itch.sh`. Đăng nhập butler (một lần mỗi máy): mở app Terminal, chạy `tools/dang_nhap_itch.sh` (không chạy được trong ô chat của Claude Code).
- Bật dev trên itch.io: thêm `?dev=1` vào link trang **không** có tác dụng (game chạy trong iframe có địa chỉ riêng). Dòng thử lưu `[INFO][luu_thu]` luôn có trong Console (F12).

### Số đo bản web (NFR2), lần đầu

Đơn vị: 1 MB = 1 000 000 byte. butler in theo MiB (1 MiB = 1 048 576 byte), đổi ra MB để so được.

| Ngày | Commit | Bản nén (zip) | Chưa nén | butler đẩy lên | Tải thật (Transferred) | Thời gian tải ở 20 Mbps |
|---|---|---|---|---|---|---|
| 2026-10-17 | zip đo ở `4c39723-sua`; đẩy lên ở `c9cc5a6` | 10.4 MB | 40.0 MB (`index.wasm` 39.5 MB) | 38.16 MiB ≈ 40.0 MB | **chưa đo** (tác giả hoãn; đo ở E4) | **chưa đo** (tác giả hoãn; đo ở E4) |

- Ước tính: nếu itch.io nén `index.wasm` khi gửi thì tải khoảng 10 MB → 4–5 giây; nếu không nén thì khoảng 40 MB → 16 giây, vượt mục tiêu 10 giây.

## Lưu ý

- Toàn bộ quyết định và lý do nằm trong `decision-log.md` của GDD và `.decision-log.md` của brief.
- **Phạm Ngũ Lão không có tên trong *Toàn thư* các năm 1287–1288.** Thông tin về ông lấy theo *Việt Nam sử lược*, nên trong game phải ghi chú nguồn.
- Chưa rõ Nghị định 147/2024 có áp dụng cho bản web miễn phí hay không. Cần tìm hiểu trước khi phát hành công khai.
- **Tên game đã chốt: "Hào Khí Đông A"** (2026-10-17). Repo vẫn tên `chong-nguyen-mong`.
- **Còn treo, tác giả chưa quyết:** công cụ giải thử (để sau E4); có công khai bản web hay không (mặc định riêng tư).
- Các luật gắn **[MẶC ĐỊNH]** trong GDD sẽ được duyệt qua kịch bản luật ở từng story.
