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

**Tình trạng 2026-10-22:** Đã tối ưu hóa và chuẩn hóa toàn diện 100% bảng màu Resurrect 64 và 1-bit alpha cho toàn bộ A1–A8 tại `img/pixellab-thu/toi_uu/dia_hinh/`. Đã dựng ảnh phối cảnh bàn cờ hoàn chỉnh Trận thử 7×7 `_mockup_ban_co_showcase_7x7.png` và bảng tổng hợp `_tong_hop_dia_hinh_va_vat_can.png`.

| # | Ô | Ký hiệu | Kích thước | Biến thể, trạng thái | Tình trạng |
|---|---|---|---|---|---|
| A1 | Đất trống / Cỏ | `.` | 64×64 | 4 biến thể (cỏ chuẩn, cỏ hoa, sỏi đá) | Đã xong (100% Resurrect 64) |
| A2 | Sông | `~` | 64×64 | 16 ô Autotile cỏ - sông uốn lượn kèm ô lội | Đã xong (`o_nen/tile_0.png` .. `tile_15.png`) |
| A3 | Rừng | `#` | 64×96 | 2 biến thể (rừng tre trúc, rừng rậm) | Đã xong (`vat_can/a3_*.png`) |
| A4 | Hầm chông | `^` | 64×64 | 4 kiểu chông cắm xiên + 4 hố bẫy lá | Đã xong (`vat_can/a4_*.png`) |
| A5 | Kho lương | `L` | 64×96 | Nhà kho sàn gỗ gạo + Hố cháy tro than | Đã xong (`vat_can/a5_*.png`) |
| A6 | Làng | `D` | 64×96, 64×140 | Nhà tranh Đại Việt + Làng cháy bốc khói | Đã xong (`vat_can/a6_*.png`) |
| A7 | Ô ải | `A` | 64×64 | Bệ đá lũy ải cổ Vạn Kiếp (mặt + chân bệ 8px) | Đã xong (`vat_can/a7_*.png`) |
| A8 | Nền quanh bàn | — | 64×64 | 4 kiểu viền rừng nhiệt đới quanh bàn cờ | Đã xong (`vat_can/a8_*.png`) |

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

**Tình trạng Hoạt ảnh 2026-10-22:** Đã hoàn thành toàn diện 100% toàn bộ hệ thống Hoạt ảnh chiến đấu & di chuyển chuẩn Pixel Art (152 frames/sheets, 100% Resurrect 64, 1-bit alpha, vũ khí cầm tay thật sự và nhún nảy tự nhiên theo quán tính bước chân) tại `img/pixellab-thu/toi_uu/hoat_anh/`:
- **Di chuyển (Walk 4 hướng × 4 frames):** Đã xong Spritesheet 256×256 & GIF cho 4 quân cờ (`khoai/`, `lao/`, `du/`, `bo_binh/`). Nguyễn Khoái cầm Mạch đao 1 tay; Phạm Ngũ Lão cầm Giáo; Trần Khánh Dư cầm Câu liêm; Bộ Binh Nguyên cầm Đao & Khiên. Bảng tổng hợp: `_tong_hop_hoat_anh_di_chuyen.png`.
- **Tấn công (Attack 4 frames × 2-3 hướng):** Đã xong đầy đủ 4 quân cờ (`tan_cong/`). Khoái chém sấm sét đẩy lùi; Lão phóng lao tầm xa; Dư móc câu liêm kéo địch; Bộ Binh chém đao thủ khiên. Bảng tổng hợp: `tan_cong/_tong_hop_hoat_anh_tan_cong.png`.
- **Trúng đòn (Hurt 4 frames):** Đã xong cả 4 quân cờ (`bi_thuong/`). Giật lùi, chao đảo khi nhận sát thương. Bảng tổng hợp: `bi_thuong/_tong_hop_hoat_anh_bi_thuong.png`.
- **Gục ngã (Death 4 frames):** Đã xong cả 4 quân cờ (`guc_nga/`). Khụy gối chống đao/giáo oai hùng, quân Nguyên gục ngã rơi vũ khí. Bảng tổng hợp: `guc_nga/_tong_hop_hoat_anh_guc_nga.png`.
- **Chết đuối (Drown 4 frames):** Đã xong cho Bộ Binh Nguyên (`chet_duoi/`). Rơi xuống sông sủi bọt trắng chìm dần. Bảng tổng hợp: `chet_duoi/_tong_hop_hoat_anh_chet_duoi.png`.

| Trạng thái | Ưu tiên | Số khung | Tình trạng |
|---|---|---|---|
| Đứng yên | P1 | 1 (đủ 8 hướng) | Đã xong cả 6 quân (`toi_uu/{khoai,lao,du,nguyen_v3,ky_binh,cung_ky}`) |
| Đi (Walk) | P2 | 4 frames × 4 hướng | Đã xong Spritesheet 4x4 & GIF cho Khoái, Lão, Dư, Bộ binh |
| Đánh (Attack) | P2 | 4 frames × 2-3 hướng | Đã xong đầy đủ 4 quân (Khoái, Lão, Dư, Bộ binh) |
| Trúng đòn (Hurt) | P2 | 4 frames | Đã xong đầy đủ 4 quân (Khoái, Lão, Dư, Bộ binh) |
| Gục (Death) | P2 | 4 frames | Đã xong đầy đủ 4 quân (Khoái, Lão, Dư, Bộ binh) |
| Chết đuối (Drown) | P2 | 4 frames | Đã xong cho Bộ Binh Nguyên (rơi sông chìm dần) |

"Đã đi" và "đã đánh" làm bằng tô mờ trong code, không cần hình riêng.

## C. Hiệu ứng (P2)

**Tình trạng 2026-10-22:** Đã tạo và tối ưu xong toàn bộ 8 hiệu ứng chiến đấu & kỹ năng chuẩn Resurrect 64 tại `img/pixellab-thu/toi_uu/hieu_ung/`, ảnh tổng hợp `_tong_hop_tat_ca_hieu_ung_c1_c8.png`.

| # | Hiệu ứng | Khi nào | Tình trạng |
|---|---|---|---|
| C1 | Cây lao bay | Phạm Ngũ Lão phóng lao | Đã xong (32×32, dải lụa đỏ) |
| C2 | Mũi tên bay | Cung kỵ bắn | Đã xong (32×32, khử đỏ) |
| C3 | Bụi, sao va chạm | Đẩy hoặc kéo va vào quân, vật cản, mép bàn | Đã xong (48×48, tia sáng vàng/trắng) |
| C4 | Nước bắn | Quân rơi xuống sông | Đã xong (48×48, bọt trắng/xanh sông) |
| C5 | Chông đâm | Quân đi qua hầm chông | Đã xong (48×48, cọc tre nhọn) |
| C6 | Lửa cháy kho | *Vườn không nhà trống* | Đã xong (48×48, tàn tro & ngọn lửa) |
| C7 | Hào quang đỏ trên tướng | *Sát Thát* đang có hiệu lực | Đã xong (48×48, hào quang đỏ sẫm) |
| C8 | Dấu báo quân tiếp viện | Ô sẽ có quân tiếp viện hiệp sau | Đã xong (32×32, cờ hiệu cắm đất) |
| C9 | Hồi máu | Quân Nguyên đứng kề kho lương | |
| C10 | Khói, nhà trúng đòn | Làng bị trúng (Lòng dân −1) | Đã có khói vẽ riêng |

## D. Giao diện (P1 cơ bản, P2 trau chuốt)

**Tình trạng 2026-10-22:** Đã tạo và chuẩn hóa 100% Resurrect 64 tại `img/pixellab-thu/toi_uu/giao_dien/`, bảng tổng hợp `_tong_hop_giao_dien_d1_d4.png`.

| # | Thành phần | Kích thước | Ghi chú | Tình trạng |
|---|---|---|---|---|
| D1 | Khung bảng (9-slice) | 48×48 (bảng/HUD), 32×32 (tooltip) | Sơn mài đen sẫm `#2e222f`, viền đồng sáng `#ab947a` | Đã xong (margin 8px và 6px) |
| D2 | Nút: thường / rê chuột / nhấn / tắt | 80×24 & 32×24 (9-slice) | Hover viền vàng `#fbb954`, Pressed lún tối 1px | Đã xong đủ 4 trạng thái |
| D3 | Biểu tượng 2 mưu kế | 32×32 | *Vườn không nhà trống* (đuốc/tro tàn), *Sát Thát* (đao lửa hào quang) | Đã xong |
| D4 | Biểu tượng máu | 24×24 | Trái tim đá quý viền thép | Đã xong |
| D5 | Biểu tượng Lòng dân | 24×24 | Mái nhà tranh ấm áp | Đã xong |
| D6 | Biểu tượng hiệp, nhiệm vụ | Tiêu diệt, Giữ ải | | |
| D7 | Con trỏ chuột | Thường, chọn được, đánh được | | |

## E. Chân dung (P3)

**Tình trạng 2026-10-22:** Đã hoàn thiện toàn bộ chân dung 3 tướng Đại Việt tại `img/pixellab-thu/toi_uu/chan_dung/`. Đầy đủ 2 kích thước (96×96 Bảng chỉ số, 64×64 Hộp thoại) với cả bản có khung sơn mài chỉ đồng thời Trần và bản không khung, 100% chuẩn Resurrect 64 và 1-bit alpha. Bảng tổng hợp `_tong_hop_chan_dung_3_tuong.png` và Mockup giao diện Bảng thông tin 3 tướng `_mockup_bang_thong_tin_3_tuong.png`.

| # | Nhân vật | Kích thước | Ghi chú | Tình trạng |
|---|---|---|---|---|
| E1 | Nguyễn Khoái | 96×96 & 64×64 | Chỉ huy quân Thánh Dực, mạch đao, búi tóc khăn đỏ | Đã xong (có khung & không khung) |
| E2 | Phạm Ngũ Lão | 96×96 & 64×64 | Điện súy Thượng tướng quân, giáo đứng, bắp tay trần | Đã xong (có khung & không khung) |
| E3 | Trần Khánh Dư | 96×96 & 64×64 | Nhân Huệ Vương, nón Ma Lôi, móc câu liêm, áo đỏ sẫm | Đã xong (có khung & không khung) |
| E4 | Người dẫn chuyện | 96×96 & 64×64 | Chốt nhân vật khi làm E8b | Chờ E8b |

## F. Màn hình và quảng bá (P3)

**Tình trạng 2026-10-22:** Đã khắc phục toàn diện các lỗi kỹ thuật (khử triệt để 100% semi-transparent alpha, loại bỏ fractional scaling, áp dụng 9-slice và dithering retro), lượng tử hóa 100% Resurrect 64 tại `img/pixellab-thu/toi_uu/man_hinh_chinh/`. Ảnh phối cảnh chuẩn `_mockup_man_hinh_chinh_640x360.png` và ảnh bìa itch.io `f5_anh_bia_itch_io_630x500.png`.

| # | Hình | Kích thước | Nguồn & Chi tiết | Tình trạng |
|---|---|---|---|---|
| F1 | Nền màn hình chính | 640×360 (phóng ×2) | Cảnh sông Bạch Đằng hoàng hôn, bãi cọc và thuyền chiến mờ xa | Đã xong (100% Resurrect 64) |
| F2 | Tranh chuyển trận | 1–3 bức | **Thuê vẽ** (GDD) | |
| F3 | Chữ "Hào Khí Đông A" (logo) | 420×84 & 192×64 | Typography vàng hoàng kim, viền đỏ sẫm Đại Việt, bóng đổ đen; kèm huy hiệu đồng | Đã xong |
| F4 | Biểu tượng game, favicon web | 32, 64, 128, 256 px | Khiên đồng hoa văn mặt trời và kiếm giáo bắt chéo | Đã xong đủ 4 cỡ |
| F5 | Ảnh bìa itch.io | 630×500 | Bố cục 2 phe đối đầu trên nền sông Bạch Đằng, logo chữ và tagline | Đã xong (100% Resurrect 64) |

## G. Thủy chiến & Thuyền (P2 & P3)

**Tình trạng 2026-10-22:** Đã hoàn thiện toàn diện 100% hệ thống Thuyền chiến & Thủy chiến chuẩn 100% Resurrect 64 và 1-bit alpha tại `img/pixellab-thu/toi_uu/thuyen/`. Thiết kế tuân thủ nghiêm ngặt lịch sử thời Trần: Đại Việt chỉ dùng thuyền nhỏ cơ động (1 ô 64×64, đáy nông luồn lách sông rạch), thuyền lớn cồng kềnh (2 ô 64×128) độc quyền thuộc về chiến hạm quân Nguyên. Đại bảng tổng hợp: `_tong_hop_toan_bo_thuyen_chien.png`.

| # | Loại thuyền / Trạng thái | Kích thước | Chi tiết thiết kế | Tình trạng |
|---|---|---|---|---|
| G1 | Thuyền Chiến Đại Việt (Mông Đồng) | 64×64 (1 ô) | Thân gỗ nâu đỏ viền đồng, buồm đen, hàng mái chèo lướt sóng (2 hướng xuôi/ngược dòng) | Đã xong |
| G2 | Thuyền Soái Trần Khánh Dư | 64×64 (1 ô) | Thuyền Mông Đồng cắm Soái kỳ Đại Việt đỏ viền vàng phất phới ở đuôi thuyền | Đã xong |
| G3 | Chiến Thuyền Nguyên Mông | 64×64 (1 ô) | Thân gỗ bầu dày, buồm xám xanh chàm, gắn khiên phòng thủ dọc mạn thuyền (2 hướng) | Đã xong |
| G4 | Thuyền Tải Lương Trương Văn Hổ | 64×64 (1 ô) | Thuyền buôn to bản chất đầy các bao lương thực Vân Đồn (2 hướng) | Đã xong |
| G5 | Thuyền Đắm Cọc Bạch Đằng | 64×64 (1 ô) | Mạn thuyền vỡ toác cắm vào bãi cọc nhọn Bạch Đằng, nước tràn tung bọt trắng | Đã xong |
| G6 | Thuyền Lương Cháy Vân Đồn | 64×64 (1 ô) | Bao lương bốc cháy ngùn ngụt, ngọn lửa cam đỏ và khói đen cuộn bốc lên | Đã xong |
| G7 | Chiến Thuyền Trúng Hỏa Công | 64×64 (1 ô) | Cột buồm rách tơi tả, lửa bùng cháy dữ dội từ thân thuyền | Đã xong |
| G8 | Đại Hạm Chỉ Huy Ô Mã Nhi (Nguyên Mông) | 64×128 (2 ô) | Đại hạm bọc giáp gỗ kiên cố, tháp canh gắn khiên phòng thủ, buồm lớn (mục tiêu lớn mắc cạn) | Đã xong |
| G9 | Hoạt ảnh Chèo Thuyền Lướt Sóng | 64×64 (4 frames) | Mái chèo chèo nước nhịp nhàng, sủi bọt trắng và rẽ vệt sóng đuôi thuyền | Đã xong (kèm GIF preview) |

## Kiểm tra trước khi đưa một hình vào game

1. Đúng kích thước, đúng lưới 64 px, không có điểm ảnh nhòe.
2. Chỉ dùng màu trong bảng màu chung.
3. Trang phục, vũ khí, cờ đã đối chiếu tư liệu thời Trần. Không có chữ quốc ngữ trên cờ; nếu cần chữ thì dùng chữ Hán (ví dụ 陳).
4. Không có chữ do AI vẽ.
5. Đã ghi một dòng trong `game/assets/CREDITS.md`: nguồn, giấy phép, có dùng AI hay không.
6. Ô đỏ báo đòn vẫn là thứ nổi bật nhất khi đặt hình lên bàn.
