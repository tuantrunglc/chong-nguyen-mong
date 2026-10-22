# Bàn giao: làm hình (asset) cho E8

Cập nhật 2026-10-20. Đọc file này khi bắt đầu một phiên mới để làm tiếp phần hình.

## Đã chốt (tác giả quyết)

- **Ô 64×64 px**, nhìn chếch từ trên xuống, ô vuông. Khối nhô lên chỉ thấy mặt trên và mặt trước. Bàn cỡ từ 5×5 đến 10×8.
- **Bảng màu:** Resurrect 64. File để nạp vào phần mềm vẽ: `resurrect-64.gpl` cùng thư mục này.
- **Màu hai phe:** Đại Việt đỏ (đỏ sẫm, đen, đồng). Nguyên xám xanh (xám xanh, thép, nâu da). Quân Nguyên không dùng đỏ, vì đỏ tươi dành cho ô báo đòn.
- **Ảnh Gemini Bạch Đằng** (`img/Gemini_Generated_Image_4gulfe4gulfe4gul.png`) chỉ dùng làm mẫu không khí: màu dịu, bờ sông, bãi cọc. Không cắt ra làm hình trong game.

## Tác giả chốt thêm (2026-10-20, phiên 2)

- **Vũ khí:** Nguyễn Khoái cầm **mạch đao** (lúc đầu chốt đại đao, sau đổi theo truyện tác giả từng đọc; chưa thấy sử ghi); Trần Khánh Dư cầm **móc dài**. Đã ghi vào `danh-sach-hinh-e8.md` (B1, B3) và dòng prompt B1, B3 trong `prompt-tao-asset.md`.
- **Chốt kiểu Đại Việt** theo `tu-lieu-trang-phuc-dai-viet.md` (búi tóc, khăn đỏ, giáp ngực đen viền đồng, trần tay, chân đất; Dư đội nón Ma Lôi chóp nhọn). Ba tướng vẽ lại bằng v3 cho cùng nét.
- **Đồng ý cả hai đề xuất của AI:** hình không vẽ bóng đổ, game thêm bóng, ánh sáng từ trên bên trái; Phạm Ngũ Lão cầm giáo dựng đứng.

## Tác giả chốt thêm (2026-10-21)

- **Nền bàn cờ: trộn.** Trận trên đất liền và sông dùng ô ghép Tier 1 (`create_tiles_pro`, 15 lượt một bộ). Trận trên biển (như Vân Đồn) vẽ liền một tấm. Vật trên bàn (thuyền, kho, nhà) vẫn là hình rời. Mục 3 dưới đây coi như đã quyết.

## Tác giả chốt thêm (2026-10-21)

- Chân dung: Khoái phương án 3, Lão 2, Dư 2 (`img/chan_dung/chot_*.png`).
- **Bảng thông tin tướng gộp vào E8**, nội dung như ảnh mẫu `img/thu-bang-thong-tin-*.png`. Cách ghi chỉ số của Lão và giai thoại "ngồi đan sọt" tạm giữ, xét lại khi làm E8. Đã ghi vào `decision-log.md` của GDD.

## Còn chờ tác giả

1. **Có lưu ảnh Gemini thành `mau-03-bach-dang.png`** (kèm ghi chú như hai ảnh mẫu trước) không.
2. **Duyệt ba tướng v3** (`img/thu-dai-viet-v3-tren-ban-phong-to.png`, đủ 8 hướng ở `img/pixellab-thu/_ba_tuong_v3_8_huong.png`). Chỗ lệch so với bộ nhận diện:
   - ~~Khoái đi ủng, áo dài tay~~: đã vẽ lại với mạch đao, trần tay, chân đất (`img/pixellab-thu/khoai_mach_dao/`, 8 hướng ở `_khoai_mach_dao_8_huong.png`). Mạch đao cầm chéo ngang người, khác dáng hai tướng kia;
   - Dư mặc chủ yếu màu xám than, ít đỏ, nhìn xa khó nhận là phe Đại Việt;
   - ba tướng v3 nhỏ người hơn lính Nguyên v2 (Nguyên vẽ bằng standard, khác nét). Muốn đồng bộ thì vẽ lại lính Nguyên bằng v3 (2 lượt).
   Còn hình phiên 2 chờ duyệt: rừng, kho lương (`img/thu-pixellab-tren-ban-v2.png`).
   **Đối chiếu sử:** hai mục "cần đối chiếu" trong `tu-lieu-trang-phuc-dai-viet.md` (Thiên tử quân, ghi chép của Trần Phu).
3. **Bản đồ vẽ liền một tấm (thử ở Vân Đồn)**: bàn 7×5 `img/thu-van-don-tren-ban-phong-to.png`; bàn 10×8 `img/thu-van-don-lon-tren-ban-phong-to.png`. Cần tác giả quyết (ảnh hưởng thiết kế E8):
   - **Vẽ liền một tấm cho từng trận** (như Vân Đồn): đẹp, mỗi trận một cảnh riêng; nhưng mỗi trận phải vẽ riêng, và luật ô (đi được, chặn) phải khớp tay với tranh.
   - **Ghép ô** (cách cũ): một bộ ô dùng cho mọi trận, đổi bàn dễ; nhưng muốn đẹp cần bộ ô chuyển tiếp (bờ, góc), PixelLab ô 64 px tốn 25 lượt một bộ.
   - Có thể trộn: nền vẽ liền, vật trên bàn (thuyền, kho, nhà) vẫn là hình rời.
   - Bố cục Vân Đồn (`img/pixellab-thu/van_don/van_don.json`) chỉ để thử hình, **không phải thiết kế trận**: biển, đảo đá, thuyền lương đang mượn luật ô sông, rừng, kho có sẵn.
4. **Hướng tiếp theo** (chưa chọn): ô nền (cỏ, nước) chuyển sang gói 64 px có sẵn hoặc tự vẽ; vẽ lại lính Nguyên bằng v3; kỵ binh, cung kỵ (B5, B6).
5. **Commit:** các thay đổi tài liệu và thư mục `img/` chưa được commit.

## Tài liệu liên quan (cùng thư mục)

- `danh-sach-hinh-e8.md`: danh sách mọi hình cần vẽ (A địa hình, B quân, C hiệu ứng, D giao diện, E chân dung, F quảng bá), thứ tự ưu tiên P1/P2/P3, link nguồn tải miễn phí, các bước kiểm tra trước khi đưa hình vào game.
- `tu-lieu-trang-phuc-dai-viet.md`: sử liệu về trang phục quân Trần, mức chắc chắn từng chi tiết, bộ nhận diện Đại Việt.
- `prompt-tao-asset.md`: bản mô tả thiết kế cho AI vẽ (phần 1) và dòng yêu cầu cho từng hình (phần 2).
- `game/assets/CREDITS.md`: mỗi hình đưa vào game phải có một dòng ở đây.

## PixelLab MCP

- **Cài:** đã chạy `claude mcp add pixellab https://api.pixellab.ai/mcp -t http -H "Authorization: Bearer …"` (cấu hình local của dự án, trong `~/.claude.json`). Từ phiên mới, các công cụ `mcp__pixellab__*` có sẵn. Nếu không thấy, tìm bằng ToolSearch với từ khóa "pixellab".
- **Tài khoản:** tác giả lên **Tier 1** ngày 2026-10-20: 2.000 lượt mỗi tháng, làm mới ngày 20 hằng tháng, chạy 8 việc cùng lúc. **Còn 1.825** sau khi tạo Bộ binh Nguyên v3 (2026-10-22). Kiểm bằng `get_balance`.
- **Chi phí đã đo:**
  - `create_character` mode standard: 1 lượt.
  - `create_image_pixen`: 1 lượt.
  - `create_tiles_pro`: 10–25 lượt và **cần gói trả phí** (bị từ chối "Tier 1 is required", không trừ lượt).
  - `create_topdown_tileset`: ô 64 px cần mode pro, tốn 25 lượt.
  - `create_1_direction_object`: 10–25 lượt.
  - `create_character` mode v3, size 64: 2 lượt. `create_image_pixflux`: 1 lượt (tối đa 400×400 điểm ảnh tổng diện tích).
  - `inpaint_image`: 10–25 lượt, cần gói trả phí.
  - **Luôn đọc chi phí trong mô tả công cụ trước khi gọi.**
- **Gói trả phí** (PixelLab trả lời qua `search_help`, 2026-10-20):

  | Gói | Giá | Lượt mỗi tháng | Việc chạy cùng lúc |
  |---|---|---|---|
  | Dùng thử | 0 | 40, thêm 5 mỗi ngày (cộng dồn tối đa 20) | 1 |
  | Tier 1, Pixel Apprentice | 12 USD/tháng (99 USD/năm) | 2.000 | 8 |
  | Tier 2, Pixel Artisan | 24 USD/tháng (220 USD/năm) | 5.000 | 10 |
  | Tier 3, Pixel Architect | 50 USD/tháng (500 USD/năm) | 10.000 | 20 |

  Từ Tier 1 mở thêm: `create_tiles_pro` (bộ ô có chuyển tiếp), `inpaint_image` (vẽ lại một vùng; ảnh trên 256 px cần Tier 2), `create_path_tiles` (ô đường đi), `create_building_kit` (bộ ghép nhà), `transfer_outfit` (thay quần áo nhân vật). Cỡ ảnh tối đa của pixflux, pixen, pro **không tăng** theo gói. Được dùng thương mại ở mọi gói; cấm dùng hình để huấn luyện mô hình AI khác.
- **Thử ngày 2026-10-20** (hình gốc ở `img/pixellab-thu/`, gắn lên bàn ở `img/thu-pixellab-tren-ban.png`):

  | Hình | Cách làm | Kết quả |
  |---|---|---|
  | Lính Nguyên | `create_character`, standard, size 48, view high top-down, 4 hướng, id `87d78015-5cbd-4826-bfd4-b71b0d637fbc` | Màu đúng, nhưng giống lính châu Âu và nhỏ hơn Lão. Lần sau dùng size lớn hơn và mô tả rõ mũ viền lông, giáp phiến da |
  | Nhà làng | `create_image_pixen` 64×96, no_background | Đẹp nhất. Vẽ nghiêng thấy cả mặt bên |
  | Ô cỏ, ô sông | `create_image_pixen` 64×64 | Không đạt: cỏ lặp hoa văn chéo, sông giống đá rêu |
| Lính Nguyên v2 | `create_character`, standard, size 64, preset `heroic`, high top-down, 4 hướng, id `47b317dd-b048-4c6e-99f8-378404ecab78`. Hình ở `img/pixellab-thu/nguyen_v2/` | Mũ vành lông, khiên tròn, áo xám xanh, cao ngang Lão. Thiếu: không thấy đao, áo giống áo vải hơn giáp phiến. Khung 92×92, nhân vật cao 66 px (Lão 55 px) |
| Rừng | `create_image_pixen` 64×96, no_background (`rung_v1.png`) | Đạt. Đáy hơi nghiêng kiểu isometric, cần sửa tay cho ra mặt trước phẳng |
| Kho lương lần 1 | như trên (`kho_v1.png`) | Không đạt: ra tháp canh cao |
| Kho lương lần 2 | như trên, mô tả "low wide … short stilts" (`kho_v2.png`) | Đạt hướng: nhà sàn mái tranh, bao gạo phía trước. Hơi nhỏ, nghiêng thấy mặt bên |
| Nguyễn Khoái v1 | `create_character`, như lính Nguyên v2, mô tả theo `tu-lieu-trang-phuc-dai-viet.md`, id `832d1823-98b8-48a0-881f-d387df7bc9be`. Hình ở `img/pixellab-thu/khoai_v1/` | Búi tóc, khăn đỏ, giáp ngực đen, quần đỏ, chân đất: đúng bộ nhận diện. Vũ khí ra giống giáo, lưỡi đao quá nhỏ |
| Trần Khánh Dư v1 | như trên, id `6e114743-c742-4c5d-9319-70b2ef1f3674`. Hình ở `img/pixellab-thu/du_v1/` | Nón rộng vành, áo đỏ, giáp đen, chân đất. Nón ra dẹt (chưa ra nón lá chóp). Móc ở đầu cán quá nhỏ, khó nhận ra |
| Ba tướng v3 | `create_character` mode **v3**, size 64, high top-down, 2 lượt mỗi tướng, ra 8 hướng khung 64×64 (không cần cắt). Khoái `2ec57be9-79fd-404a-9486-a66f10a6365b`, Lão `1835f646-6eb5-47f1-8d91-73136596cd86`, Dư `ae2a3750-9712-4d58-b2ce-0910e9180fb9`. Hình ở `img/pixellab-thu/{khoai,lao,du}_v3/` | Đạt nhất tới giờ. Vũ khí rõ khi viết hoa phần cần nhấn ("VERY LARGE … blade", "STRAIGHT VERTICAL"). Prompt đầy đủ ở `prompt-tao-asset.md` |
| Khoái mạch đao | v3, size 64, id `17c58452-574e-449b-ac07-313596d9d02e`, prompt B1 trong `prompt-tao-asset.md` | Lưỡi thẳng rất dài, cầm chéo qua người. Trần tay, chân đất đúng bộ nhận diện. Thay cho Khoái v3 đại đao trong ảnh bàn |
| Bản đồ Vân Đồn | Vẽ phác bố cục theo lưới ô (`cong-cu/phac_bo_cuc.py`, ra `van_don/phac_thao.png`), rồi `create_image_pixflux` 448×320 với `init_image_url` là bản phác, **`init_image_strength` 40**. Lần đầu để 110 thì ra gần như nguyên bản phác (mất 1 lượt). Prompt: "top-down pixel art game map of a Vietnamese bay with limestone karst islands (Ha Long bay style) … no boats". Hình ở `img/pixellab-thu/van_don/` | Đẹp nhất trong các lần thử địa hình: đảo đá vôi có vách, sóng trắng ven bờ, bãi cát, khớp lưới ô. AI tự thêm 2 thuyền nhỏ, đã xóa tay (`nen_sach.png`). Mặt nước hơi phẳng. pixflux giới hạn 400×400 điểm ảnh tổng diện tích, nên bàn tối đa khoảng 7×5 hoặc 6×6; bàn lớn hơn phải vẽ nhiều mảnh |
| Thuyền lương Nguyên | `create_image_pixen` 64×64, no_background (`van_don/thuyen_luong.png`) | Đạt: thân gỗ, buồm xám xanh, chất bao gạo. Nhìn chếch, hơi nghiêng |
| Vân Đồn 10×8, vẽ 4 mảnh | Chia bản phác 640×512 thành 4 mảnh 384×320 chồng mép 64 px, pixflux từng mảnh cùng seed 1288, strength 40 | **Không đạt** (mất 4 lượt): mỗi mảnh một màu nước, đảo lệch bố cục, đường nối lộ rõ (`van_don/_thu_ghep_4_manh_hong.png`). Lưu ý: base64 dán thẳng vào lệnh có lúc hỏng dữ liệu; dùng `get_upload_url` rồi truyền `upload:<id>` |
| Vân Đồn 10×8, ghép con dấu | `cong-cu/ghep_dao.py`: cắt đảo, bãi (kèm viền sóng) từ tranh 7×5 theo ô, nền nước lấy các khung 64×64 toàn nước trong tranh, rồi xếp theo `van_don/bo_cuc_lon.json`; in ra lưới địa hình tương ứng. **Không tốn lượt** | Đạt: cùng màu, khớp ô, đổi bố cục tùy ý. Hạn chế: chỉ có 1 kiểu đảo nhỏ (lật ngang để đỡ giống), nước có vài vệt vuông mờ. Muốn đa dạng thì vẽ thêm vài bức nhỏ (1 lượt mỗi bức) để có thêm con dấu |
| Thuyền chiến Đại Việt lần 1 | `create_image_pixen` 64×64 nhìn thẳng từ trên (`van_don/_thuyen_dai_viet_hong.png`) | Không đạt: mái chèo xanh như lông chim, khác góc nhìn thuyền lương |
| Thuyền chiến Đại Việt, chiến thuyền Nguyên | `create_image_pixflux` lấy **thuyền lương làm khuôn** (`init_image_url` = link tải thuyền lương, strength 90) (`van_don/thuyen_dai_viet.png`, `thuyen_chien_nguyen.png`) | Đạt: cùng góc nhìn, cùng nét với thuyền lương. Thuyền Đại Việt thân đỏ sẫm, buồm đen, mái chèo; thuyền Nguyên buồm xám xanh, khiên dọc mạn. Thuyền Đại Việt hơi mảnh, nhìn xa khó thấy màu đỏ. **Cách lấy hình có sẵn làm khuôn giữ đồng bộ tốt, nên dùng cho mọi biến thể** |
| Viền quanh bàn | `cong-cu/them_vien.py`: phản chiếu mép tranh ra ngoài 48 px rồi làm tối | Sửa được chỗ đầu quân hàng trên, vũ khí ở cột ngoài cùng lọt ra ngoài bàn. Phản chiếu nên viền lặp lại hình đảo ở mép; về sau nên thay bằng viền vẽ riêng (A8 trong `danh-sach-hinh-e8.md`) |
| **Tier 1:** bộ ô cỏ–sông, cát–biển | `create_tiles_pro`, `square_topdown`, size 64, view `top-down`, `tile_feature: tileset`, `outline_mode: segmentation`. **15 lượt mỗi bộ**, 16 ô ghép theo góc. Hình ở `img/pixellab-thu/o_tier1/`; lát lên bàn bằng `cong-cu/lat_o.py` (lưới lệch nửa ô) | **Cỏ–sông: đạt rất tốt** (`img/thu-tier1-co-song-tren-ban-phong-to.png`): bờ bùn uốn mềm, ô lội nối hai bờ tự nhiên, không lộ đường nối. **Cát–biển: bãi đẹp nhưng biển sâu quá tối, phẳng**; đảo đá đặt lên như khối thì thiếu viền sóng nên trông như dán (`img/thu-tier1-cat-bien-tren-ban.png`). Biển Vân Đồn vẫn nên dùng bản vẽ liền |
| **Tier 1:** ô lẻ | `create_tiles_pro` 6 loại đánh số, 15 lượt, ra 16 ô (`o_tier1/o_le/`) | Cỏ 3 kiểu, đất, ruộng lúa ngập nước, bùn, nước, hố chông. Đẹp, dùng làm ô nền và ô đặc biệt. Hố chông dán nguyên ô nên viền vuông |
| **Tier 1:** áo Dư | `inpaint_image` vùng thân (16,28, 30×20) trên hình hướng nam, 10 lượt (`du_v3/south_ao_do.png`) | Đạt: áo đỏ sẫm, thắt lưng đỏ, phần khác giữ nguyên. Mới sửa hướng nam; 7 hướng còn lại phải sửa từng hướng (10 lượt mỗi hướng) hoặc vẽ lại cả nhân vật bằng v3 (2 lượt) |
| **Nhóm A** (2026-10-21), hình ở `img/pixellab-thu/nhom_a/`, ảnh bàn `img/thu-nhom-a-tren-ban-phong-to.png` | Rừng 2, làng 2, kho cháy: `create_image_pixflux` lấy hình cũ làm khuôn (upload rồi `init_image_url`). Strength 60 ra lệch kiểu (làng thành nhà khung gỗ, rừng xanh tươi); **strength 110 giữ đúng kiểu**; kho cháy cần strength 25 mới bỏ được mái. Khói: `create_image_pixen` 64×96 vẽ riêng, đặt chồng lên nhà (pixflux có nền trong suốt xóa mất khói). Ô ải: `create_tiles_pro` view `top-down` (view `high top-down` ép mặt trên còn 32 px, sai tỉ lệ bàn). Hầm chông và viền: `create_tiles_pro` với `style_images` = ô cỏ của bộ cỏ–sông nên cùng màu. Ghép nền: `cong-cu/nen_dat_lien.py`; biến thể từng ô: `mock/o_rieng.json` | Đạt: rừng 2 (`rung_v2b`), làng 2 (`lang_v2b`, còn ống khói trên mái phải xóa tay), làng bị trúng (`lang_khoi_ghep` = làng + `khoi`), kho cháy (`kho_chay_b`), ô ải (`o_ai2/`, 4 kiểu: đá xếp, đất khung gỗ, đá phiến, có cọc rào), hầm chông viền cỏ và hố bẫy phủ lá (`vien_chong/` 0–3, 12–15), viền rừng rậm, đá, lau (`vien_chong/` 4–11). Ô hầm chông còn hơi lộ khung vuông |
| **Avatar ba tướng** (2026-10-21) | `create_image_pro` 160×160, 3 hình tham chiếu (3 tướng v3), 15 lượt, ra 4 phương án (`img/avatar/`, bản 640 px để làm avatar) | Đạt cả 4. Phương án 3 đẹp nhất (giáo dựng đứng, cờ đỏ, hoàng hôn); phương án 2 Lão cầm giáo chéo |
| **Chân dung E1–E3** (2026-10-21) | `create_image_pro` 96×96, tham chiếu = avatar phương án 3 (nét vẽ, mặt) + hình tướng v3 (trang phục), 10 lượt mỗi tướng, ra 4 phương án mỗi tướng (`img/chan_dung/`, bảng `_tat_ca.png`) | Đạt: cùng nét với avatar, nền nâu tối đồng bộ. **Tác giả chọn Khoái 3, Lão 2, Dư 2** (`img/chan_dung/chot_*.png`). Ảnh mẫu bảng thông tin khi bấm vào tướng: `img/thu-bang-thong-tin-{khoai,lao,du}.png` (chỉ ghép ảnh, chưa có trong game; nội dung bảng chờ tác giả chốt) |
| **Bộ binh Nguyên v3** (2026-10-22) | `create_character` mode **v3**, size 64, high top-down, 2 lượt, id `1d7e8b91-2b67-4c5f-aa61-beee8d934860`. Hình gốc ở `img/pixellab-thu/nguyen_v3/`, bản tối ưu ở `img/pixellab-thu/toi_uu/nguyen_v3/` | **Đạt rất tốt**: Đủ 8 hướng khung 64×64, chiều cao 59 px (đồng bộ tuyệt đối với 3 tướng), cầm đao cong Mông Cổ và khiên tròn, mũ viền lông, giáp phiến da nâu, không có màu đỏ. Đã lượng tử hóa 100% về Resurrect 64 và viền #2e222f. Thay thế hoàn toàn bản v2 cũ |

- **Ảnh chụp bàn phiên 2:** `img/thu-pixellab-tren-ban-v2.png` (ô nền vẫn là hình tạm vẽ bằng code). Ảnh `img/thu-dai-viet-tren-ban.png` thêm `khoai.png`, `du.png` vào `mock/`; bản chép sửa `unit_token.gd` chọn hình theo `unit_type` (Khoái, Dư) rồi mới theo phe. Lính Nguyên cao hơn 64 px nên khi chụp, bản chép sửa `unit_token.gd` để neo chân hình theo đáy: `Vector2(-32, -58 - (tex.get_height() - 64))`; hình cắt ở `(16, 11, 80, 84)` của khung 92×92.
- **Đổi màu:** đổi về Resurrect 64 bằng cách thay mỗi màu bằng màu gần nhất làm hỏng màu (cỏ thành hồng xám). Nên thử `reduce_colors` của PixelLab (0,1 lượt, nhận `palette_image`) hoặc sửa tay.
- Bản nháp Phạm Ngũ Lão cũ: `img/Pham_Ngu_Lao_muscular_13th/`. Trong `metadata.json` có prompt gốc: size 64, view high top-down, template mannequin.

## Cách tạo ảnh "chụp từ game" với hình thử (không sửa repo)

Game chưa có chỗ nạp hình (phần đó thuộc E8). Để xem thử, chép game ra thư mục tạm, gắn hình vào bản chép rồi chụp. Công cụ nằm ở `img/pixellab-thu/cong-cu/`:

1. Chép `game/` ra thư mục scratchpad, rồi áp `gan_hinh_vao_ban_thu.patch` (`patch -p1` từ thư mục cha của bản chép). Patch tạo trên commit `a38f181`, nếu code đã đổi thì sửa tay theo patch. Patch làm 4 việc:
   - `board_view.gd`: vẽ ô cỏ, sông, chông bằng hình `res://mock/*.png`;
   - `terrain_block.gd`: vẽ rừng, làng, kho bằng hình;
   - `unit_token.gd`: vẽ quân bằng hình (`lao.png` cho Đại Việt, `nguyen.png` cho Nguyên), có bóng và chấm máu;
   - thêm rừng và làng vào `thu_ba_tuong.json`, đổi nền màn hình sang tối.
2. Đặt hình vào `<bản chép>/mock/`, gồm: `dat_0..2.png`, `song.png`, `song_bo.png`, `chong.png`, `rung.png`, `lang.png`, `kho.png`, `lao.png`, `nguyen.png`. `ve_hinh_tam.py` vẽ tạm đủ bộ này bằng code.
3. Chụp:
   ```
   godot --path <bản chép> --script chup.gd -- --dev --tran=thu_ba_tuong --out=<thư mục> "--steps=act:select_general_2,hover:1:5,shot:ten"
   ```
   Godot nằm ở `.tools/godot-4.7.2/`.
4. **Bản mới** `gan_hinh_vao_ban_thu_v2.patch` (tạo trên commit `7c4cfaa`, gộp mọi sửa ở trên): thêm chọn hình theo tướng (`khoai.png`, `du.png`), neo chân hình cao hơn 64 px, và nền vẽ liền: có `mock/nen.png` thì vẽ ảnh đó làm nền, bỏ ô cỏ, ô sông và hình rừng (đảo đá đã có trong tranh). Kèm `data/tran/van_don.json`. Chụp Vân Đồn: `--tran=van_don` (đặt `van_don/nen_sach.png` làm `mock/nen.png`) hoặc `--tran=van_don_lon` (chạy `them_vien.py van_don/nen_lon.png mock/nen.png`, chép `thuyen_dai_viet.png` thành `mock/thuyen_dv.png`, `thuyen_chien_nguyen.png` thành `mock/thuyen_nguyen.png`, `trang_tri_lon.json` thành `mock/trang_tri.json`). Nền có viền thì tự canh giữa quanh bàn.
5. `pl.py` và `run.py` gọi PixelLab qua HTTP, đọc key từ `~/.claude.json`. Chỉ cần khi MCP chưa hiện trong phiên.

## Lưu ý

- Thư mục `img/` là chỗ để bản nháp và ảnh thử, chưa phải asset của game. Asset thật vào `game/assets/` khi làm E8, theo quy ước đặt tên `tex_*.png`.
- MCP chỉ để nhìn và thử. Code game thật chỉ sửa trong story E8, có test đi kèm.
