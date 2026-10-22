# Danh sách hình cần vẽ (E8)

Lập 2026-10-19. Dùng khi làm E8 (Hình ảnh & âm thanh). Danh sách âm thanh sẽ lập riêng khi tới E8.

## Thông số chung (chốt trước khi vẽ hoặc tải)

- **Góc nhìn:** pixel art nhìn chếch từ trên xuống, ô vuông (GDD, Art Style; ảnh mẫu ở thư mục này).
- **Ô:** **64×64 px**, hiện đúng tỉ lệ 1:1 (chốt 2026-10-20, thay cho 32×32). Godot đặt lọc `Nearest` để không nhòe.
- **Vật đứng** (quân, khối nhô lên): khung **64×64**. Chân hoặc đáy nằm trong ô; phần trên được phép che ô phía trên. Vũ khí dài không được thò quá nửa ô sang hai bên.
- **Bảng màu:** **Resurrect 64** (64 màu, Kerrie Lake, https://lospec.com/palette-list/resurrect-64), tác giả chốt 2026-10-20. File bảng màu để nạp vào phần mềm vẽ: `resurrect-64.gpl` cùng thư mục này. Mọi hình, kể cả hình tải về và hình AI, đều đổi về bảng này.
- **Màu hai phe** (tác giả chốt 2026-10-20): **Đại Việt đỏ** (đỏ sẫm, đen, đồng), **Nguyên xám xanh** (xám xanh, nâu da). Quân Nguyên không dùng đỏ để không lẫn với ô đỏ báo đòn.
- **Không có chữ trong hình.** Chữ (tên, số máu, nút) để game hiện bằng font.
- **Ô đỏ báo đòn, số thứ tự ra đòn, ô sáng, đường đi:** giữ vẽ bằng code để luôn nổi bật nhất (NFR9). Tranh địa hình phải dùng màu dịu, không dùng đỏ tươi.
- **Mỗi hình đưa vào game phải có một dòng trong `game/assets/CREDITS.md`.**

## Link nguồn để xem mẫu (tra 2026-10-20)

Đã mở từng trang để kiểm giấy phép và cỡ ô. Giấy phép có thể đổi: khi tải về thật thì đọc lại trang và ghi vào `game/assets/CREDITS.md`.

**Lưu ý cỡ ô:** game dùng ô 64×64. Gói 16×16 phải phóng ×4, gói 32×32 phóng ×2 (lọc `Nearest`, phóng theo bậc nguyên nên không nhòe), nhưng hình sẽ to hạt hơn hình vẽ thẳng ở 64 px. Dùng các gói này để xem phong cách, hoặc làm hình tạm cho E8 P1.

| Dùng cho | Gói | Link | Cỡ ô | Giấy phép | Ghi chú |
|---|---|---|---|---|---|
| A. Địa hình | Ninja Adventure | https://pixel-boy.itch.io/ninja-adventure-asset-pack | 16×16 | CC0 | Miễn phí (tự chọn giá). Có cả ô đất, nước, cây, nhà; kèm hơn 100 hiệu ứng âm thanh, 37 bản nhạc, giao diện, hiệu ứng hình, 2 font và project mẫu cho Godot 4 |
| A. Địa hình | Kenney – Tiny Town | https://kenney.nl/assets/tiny-town | 16×16 | CC0 | Làng, cỏ, cây, đường |
| A. Địa hình | Kenney – Roguelike/RPG Pack | https://kenney.nl/assets/roguelike-rpg-pack | 16×16 | CC0 | Khoảng 1700 file: địa hình, đồ vật, nút, khung giao diện |
| A. Địa hình | Ulerinn – Free Forest Tilesets | https://ulerinn.itch.io/free-forest-tilesets | 16, 32, 48 | CC0 | Một bộ rừng nhỏ. Không được bán lại hay chia sẻ lại nguyên gói. Tác giả ghi không dùng AI |
| A. Địa hình | Cainos – Pixel Art Top Down Basic | https://cainos.itch.io/pixel-art-top-down-basic | 32×32 | Riêng của tác giả: cho dùng thương mại, không bắt ghi tên, không được bán lại hay chia sẻ lại | Miễn phí. Làm cho Unity nhưng có ảnh PNG dùng được trong Godot. Không phải CC0: ghi đúng tên giấy phép vào CREDITS |
| A. Địa hình | (tìm thêm) Kenney theo chủ đề nhìn từ trên | https://kenney.nl/assets/tag:top-down | — | CC0 | Phần lớn là tàu, xe tăng, súng: ít hợp thời Trần |
| D. Giao diện | Kenney – UI Pack Pixel Adventure | https://kenney.nl/assets/ui-pack-pixel-adventure | — | CC0 | Nút, khung, thanh trượt kiểu pixel |
| Bảng màu | Resurrect 64 | https://lospec.com/palette-list/resurrect-64 | — | (bảng màu, dùng tự do) | 64 màu, của Kerrie Lake. **Đã chốt** (2026-10-20) |
| B. Quân | PixelLab | https://www.pixellab.ai | 64×64 (bản nháp Phạm Ngũ Lão) | Điều khoản: người dùng giữ quyền sở hữu hình tạo ra, được dùng thương mại; không thấy phân biệt gói trả phí và miễn phí; cấm dùng hình để huấn luyện AI khác | Điều khoản: https://www.pixellab.ai/termsofservice. Vẫn phải sửa tay (chính sách AI trong GDD) |

- Kenney: mọi gói trên trang là CC0, không bắt ghi tên (ghi "Kenney" nếu muốn), chỉ không được dùng logo Kenney (https://kenney.nl/support).
- Không dùng gói giấy phép CC-BY-SA (ví dụ bộ LPC trên OpenGameArt) nếu chưa hỏi (luật ở `game/assets/CREDITS.md`).

## Ưu tiên

- **P1:** thay toàn bộ hình tạm, chưa cần chuyển động. Xong P1 là game đã "có hình".
- **P2:** chuyển động và hiệu ứng.
- **P3:** chân dung, màn hình, hình quảng bá.

## A. Địa hình (P1)

**Tình trạng 2026-10-21:** đã có bản thử đủ A1–A8 (xem `ban-giao-asset.md`, mục Nhóm A). Chưa đổi về bảng màu, chưa sửa tay, chưa đưa vào `game/assets/`.

Nguồn đề xuất: gói CC0 (ví dụ "Ninja Adventure", Kenney), đổi màu theo bảng chung.

| # | Ô | Ký hiệu | Kích thước | Biến thể, trạng thái | Ghi chú |
|---|---|---|---|---|---|
| A1 | Đất trống | `.` | 64×64 | 3–4 biến thể (cỏ, đất, cỏ lẫn đất) | Màu dịu, lặp không lộ |
| A2 | Sông | `~` | 64×64 | nước + bộ bờ (4 cạnh, 4 góc ngoài, 4 góc trong) | Thấp hơn mặt đất, thấy bờ ở cạnh trên |
| A3 | Rừng | `#` | 64×64 | 2 biến thể | Khối nhô lên, chặn đi và chặn đòn |
| A4 | Hầm chông | `^` | 64×64 | 1 | Phẳng, nhìn ra là bẫy nhưng không nổi hơn ô đỏ |
| A5 | Kho lương | `L` | 64×64 | còn / đã đốt (tro, thành ô trống) | Đốt bởi *Vườn không nhà trống* |
| A6 | Làng | `D` | 64×64 | 2 biến thể; trạng thái bị trúng (khói) | Nhà tranh Đại Việt, không dùng nhà kiểu Nhật |
| A7 | Ô ải | `A` | 64×64 | 1 | Bệ đá thấp (chốt ở Story 1.7) |
| A8 | Nền quanh bàn | — | tùy | rừng, nước, đá | Trang trí, tối hơn bàn để bàn nổi lên |

## B. Quân (P1 hình đứng, P2 chuyển động)

Nguồn đề xuất: PixelLab hoặc AI vẽ nháp, rồi **sửa tay** theo tư liệu. Gói có sẵn thường sai trang phục.

| # | Quân | Phe | Vũ khí, dấu nhận diện | Lưu ý lịch sử |
|---|---|---|---|---|
| B1 | Nguyễn Khoái | Đại Việt | **mạch đao** (tác giả chốt 2026-10-20, thay đại đao), đòn đánh đẩy lùi | Đối chiếu trang phục tướng thời Trần |
| B2 | Phạm Ngũ Lão | Đại Việt | giáo, lao (phóng xa) | Giai thoại cầm giáo ngồi đan sọt  Bản nháp AI: `img/Pham_Ngu_Lao_muscular_13th/` (PixelLab, 64×64, 8 hướng, chỉ có tư thế đứng). Cần: đổi về bảng màu chung; kiểm tra áo choàng đỏ ở hướng đông và tây (prompt không yêu cầu); đối chiếu giáp sơn đen và khăn đỏ với tư liệu; xem lại ngọn giáo cầm ngang (61 px, thò sang ô bên cạnh). |
| B3 | Trần Khánh Dư | Đại Việt | móc dài (tác giả chốt 2026-10-20), đòn kéo | Tôn thất nhà Trần |
| B4 | Bộ binh | Nguyên | đao, khiên | Giáp da phiến, mũ lông |
| B5 | Kỵ binh | Nguyên | ngựa thảo nguyên nhỏ, giáo | Xung phong theo hàng |
| B6 | Cung kỵ | Nguyên | cung ngắn trên ngựa | |

Mỗi quân cần (khung 64×64, hai phe tách màu rõ: Đại Việt đỏ, Nguyên xám xanh):

| Trạng thái | Ưu tiên | Số khung gợi ý | Ghi chú |
|---|---|---|---|
| Đứng yên | P1 | 1 (P2: 2–4) | Đủ để thay đồng tròn |
| Đi | P2 | 4 | 2 hướng, lật ngang thành 4 hướng |
| Đánh | P2 | 3–4 | Lão: động tác phóng lao; Dư: động tác kéo |
| Trúng đòn | P2 | 1–2 | |
| Gục | P2 | 3 | |
| Chết đuối | P2 | 2–3 | Chỉ quân Nguyên (rơi sông) |

"Đã đi" và "đã đánh" làm bằng tô mờ trong code, không cần hình riêng.

## C. Hiệu ứng (P2)

| # | Hiệu ứng | Khi nào |
|---|---|---|
| C1 | Cây lao bay | Phạm Ngũ Lão phóng lao |
| C2 | Mũi tên bay | Cung kỵ bắn |
| C3 | Bụi, sao va chạm | Đẩy hoặc kéo va vào quân, vật cản, mép bàn |
| C4 | Nước bắn | Quân rơi xuống sông |
| C5 | Chông đâm | Quân đi qua hầm chông |
| C6 | Lửa cháy kho | *Vườn không nhà trống* |
| C7 | Hào quang đỏ trên tướng | *Sát Thát* đang có hiệu lực |
| C8 | Dấu báo quân tiếp viện | Ô sẽ có quân tiếp viện hiệp sau |
| C9 | Hồi máu | Quân Nguyên đứng kề kho lương |
| C10 | Khói, nhà trúng đòn | Làng bị trúng (Lòng dân −1) |

## D. Giao diện (P1 cơ bản, P2 trau chuốt)

| # | Thành phần | Ghi chú |
|---|---|---|
| D1 | Khung bảng (9-slice) | Dùng cho HUD, tooltip, ô nhiệm vụ, khung lời thoại |
| D2 | Nút: thường / rê chuột / nhấn / tắt | Hủy, Kết thúc lượt, Chơi lại hiệp |
| D3 | Biểu tượng 2 mưu kế | *Vườn không nhà trống*, *Sát Thát* |
| D4 | Biểu tượng máu | Hiện số máu trên quân |
| D5 | Biểu tượng Lòng dân | Thanh chung của trận có làng |
| D6 | Biểu tượng hiệp, nhiệm vụ | Tiêu diệt, Giữ ải |
| D7 | Con trỏ chuột | Thường, chọn được, đánh được |

## E. Chân dung (P3)

**Tình trạng 2026-10-21:** đã có bản thử 96×96 cho E1–E3 (`img/chan_dung/`). **Tác giả chọn:** Khoái phương án 3, Lão phương án 2, Dư phương án 2 (chép thành `chot_khoai.png`, `chot_lao.png`, `chot_du.png`).

| # | Nhân vật | Kích thước | Ghi chú |
|---|---|---|---|
| E1–E3 | Nguyễn Khoái, Phạm Ngũ Lão, Trần Khánh Dư | 64×64 hoặc 96×96 | Khung lời thoại (như ảnh mẫu) |
| E4 | Người dẫn chuyện | như trên | Chốt nhân vật khi làm E8b |

## F. Màn hình và quảng bá (P3)

| # | Hình | Kích thước | Nguồn |
|---|---|---|---|
| F1 | Nền màn hình chính | 640×360 (phóng ×2) | Tự làm hoặc thuê |
| F2 | Tranh chuyển trận | 1–3 bức | **Thuê vẽ** (GDD) |
| F3 | Chữ "Hào Khí Đông A" (logo) | tùy | Tự làm bằng font, sửa tay |
| F4 | Biểu tượng game, favicon web | 32, 64, 128, 256 px | |
| F5 | Ảnh bìa itch.io | 630×500 | |

## Kiểm tra trước khi đưa một hình vào game

1. Đúng kích thước, đúng lưới 64 px, không có điểm ảnh nhòe.
2. Chỉ dùng màu trong bảng màu chung.
3. Trang phục, vũ khí, cờ đã đối chiếu tư liệu thời Trần. Không có chữ quốc ngữ trên cờ; nếu cần chữ thì dùng chữ Hán (ví dụ 陳).
4. Không có chữ do AI vẽ.
5. Đã ghi một dòng trong `game/assets/CREDITS.md`: nguồn, giấy phép, có dùng AI hay không.
6. Ô đỏ báo đòn vẫn là thứ nổi bật nhất khi đặt hình lên bàn.
