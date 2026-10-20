---
title: 'Đề xuất thay đổi: mỗi trận một cỡ bàn; tranh E8 dùng ô 64 px'
date: '2026-10-20'
status: 'tác giả duyệt 2026-10-20, đã áp dụng'
mode: 'batch'
scope: 'Nhỏ đến vừa (thêm Story 1.9; sửa GDD, kiến trúc, epics, project-context, danh sách hình E8, CREDITS, sprint-status)'
---

# Mỗi trận một cỡ bàn; tranh E8 dùng ô 64 px

## 1. Vấn đề

Có hai thay đổi, đều do tác giả đưa ra ngày 2026-10-20.

**(1) Cỡ bàn.** Bàn đang khóa ở 7×7, nhưng tác giả muốn mỗi trận có cỡ bàn riêng, **dựa theo quy mô của trận đánh thật**.

**(2) Kích thước tranh.** Tác giả đã tạo bằng AI (PixelLab) bộ hình Phạm Ngũ Lão: 64×64 px, 8 hướng, chỉ có tư thế đứng (`img/Pham_Ngu_Lao_muscular_13th/`). Bộ hình này không khớp thông số E8 hiện tại (ô 32×32, quân 32×48):
- Người cao khoảng 55–58 px.
- Ngọn giáo cầm ngang dài khoảng 61 px.

**Bằng chứng:**
- Code: cỡ bàn là một hằng số duy nhất, `BOARD_SIZE = Vector2i(7, 7)` (`game/src/data/board_layers.gd:8`). Hằng số này được dùng ở `level_loader.gd` và `scenario_loader.gd`. Test lặp cứng `range(7)` ở 4 file.
- `deferred-work.md` (code review Story 1.7) đã ghi sẵn: *"bàn lớn hơn 7×7 sẽ tràn dưới HUD… khi cho phép bàn khác cỡ thì thêm `scale` hoặc báo lỗi"*.
- Kiến trúc đang xếp "bàn có kích thước khác 7×7" vào nhóm **ngoài phạm vi prototype** (`game-architecture.md:94`).

## 2. Ảnh hưởng

| Phần | Ảnh hưởng |
|---|---|
| **Luật** | Không đổi. Mọi luật đã tính trên `level.size`, chỉ việc nạp giá trị này từ file thay vì hằng số. Mép bàn, va chạm với mép bàn, tầm đi, tầm đánh đều giữ nguyên. |
| **Dữ liệu trận và kịch bản** | Cỡ bàn **suy ra từ chính bàn cờ chữ**: số dòng là số hàng, số ký hiệu trên một dòng là số cột. Không thêm trường mới. Mọi lớp phải cùng cỡ. Cỡ hợp lệ: từ **5×5** đến **10 cột × 8 hàng**; sai thì báo lỗi bằng tiếng Việt. Các file trận và kịch bản 7×7 hiện có vẫn hợp lệ, không cần sửa. |
| **Hiển thị** | Bàn tự canh giữa trong vùng chơi (chừa HUD). Mọi cỡ bàn đến 10×8 phải nằm gọn trong 1280×720, ô hiện 64 px. Nếu chưa đủ chỗ thì thu theo bậc nguyên để pixel art không nhòe. Lỗi tràn HUD ở `deferred-work.md` được giải quyết luôn. |
| **E1** | Thêm **Story 1.9** (khoảng 3 giờ). E1 thành khoảng 27 giờ, tổng thành khoảng 149 giờ. Story 1.9 làm **ngay sau Story 1.8, trước Story 2.4**, vì cả hai cùng sửa `board_view.gd`. |
| **E2–E4** | Các story thiết kế trận (2.14, 3.x, 4.5) phải chọn cỡ bàn theo bảng quy mô. Trận 1 hiện là 7×7. Có đổi sang 7×6 hay không sẽ quyết ở Story 2.14. |
| **E8** | Ô 64×64, quân trong khung 64×64, hiện 1:1 (lọc Nearest). Bộ hình Phạm Ngũ Lão dùng làm bản nháp B2, chưa phát hành được cho đến khi sửa tay và đổi bảng màu. |
| **Hiệu năng** | Tối đa 80 ô. Kết luận "không cần tối ưu" vẫn đúng. |

**Các story đã xong (0.1, 1.2, 1.7, …)** giữ nguyên tiêu chí nghiệm thu "7×7". Các tiêu chí đó đúng với thời điểm làm, nên không viết lại lịch sử.

## 3. Hướng đi đề xuất

**Điều chỉnh trực tiếp**: thêm một story, sửa tài liệu. Không quay lui story nào, không cắt phạm vi.
- **Rủi ro:** thấp. Cỡ bàn đã gom ở một chỗ, và luật đã đọc `level.size`.
- **Thời gian:** cộng khoảng 3 giờ.
- **Phương án cắt nếu trễ:** giữ 7×7, đặt trần cứng, bỏ co giãn. Luật không bị ảnh hưởng.

## 4. Thay đổi chi tiết

### 4.1 GDD (`gdds/gdd-GameTest-2026-10-15/gdd.md`)

**Grid System and Movement**

OLD:
> - **Lưới:** ô vuông, **7×7** (cho prototype; các trận về sau có thể khác kích thước).

NEW:
> - **Lưới:** ô vuông. **Mỗi trận một cỡ**, chọn theo quy mô của trận đánh thật, được phép không vuông. Nhỏ nhất **5×5**, lớn nhất **10 cột × 8 hàng** (để ô 64 px vừa màn hình 1280×720). Chốt 2026-10-20.
> - **Quy mô trận** thể hiện bằng ba thứ cùng lúc: cỡ bàn, số quân Nguyên, lượng tiếp viện. Người chơi vẫn có tối đa 3 tướng.
>
> | Quy mô | Cỡ bàn (cột × hàng) | Quân Nguyên khởi đầu | Dùng cho |
> |---|---|---|---|
> | Nhỏ: đụng độ, phục kích | 5×5 – 6×6 | 2–4 | Trận dạy chơi, phục kích |
> | Hẹp: ải, đèo | khoảng 5×8 hoặc 6×7 | 3–5 + tiếp viện | Giữ ải, quân Nguyên dồn vào lối hẹp |
> | Vừa: trận thường | 7×7 – 8×8 | 4–6 | Phần lớn các trận |
> | Lớn: trận then chốt | đến 10×8 | 6–9 + tiếp viện | Vạn Kiếp, Bạch Đằng |

**Campaign Structure:** thêm cột "Cỡ (gợi ý)" và "Sự kiện thật (gợi ý)" vào bảng 6 trận. Cả hai cột chỉ là gợi ý, sẽ chốt khi thiết kế từng trận.

| Trận | Cỡ (gợi ý) | Sự kiện thật (gợi ý, xem `history-notes-1288.md`) |
|---|---|---|
| 1 | 7×6 | Cửa Đại Than |
| 2 | 6×7 | Ải Lãnh Kinh |
| 3 | 6×6 | Phục kích ở ải Nội Bàng (theo *Việt Nam sử lược*) |
| 4 | 7×7 | Làng quanh Vạn Kiếp |
| 5 | 8×8 | Thăng Long bỏ ngỏ |
| 6 | 10×8 | Phục binh hai bờ Bạch Đằng |

**Level Progression**

OLD: `- Bàn 7×7.`
NEW: `- Cỡ bàn theo bảng quy mô (Grid System), từ 5×5 đến 10×8. 3–6 quân Nguyên khởi đầu là mức của trận nhỏ và vừa; trận lớn có thể nhiều hơn.`

**Performance Requirements**

OLD: `… trong suốt một trận 7×7.`
NEW: `… trong suốt một trận 10×8 (cỡ lớn nhất).`

**Art Style, mục "Góc nhìn"**

OLD: `(ô là bội số của 16 px, phóng to bằng lọc Nearest để không nhòe)`
NEW: `(ô **64×64 px**, quân trong khung 64×64, hiện 1:1, lọc Nearest; chốt 2026-10-20)`

**decision-log.md:** thêm 2 dòng ngày 2026-10-20, một cho cỡ bàn và một cho kích thước tranh.

### 4.2 Kiến trúc (`game-architecture.md`)

- **Dòng 53 (tổng quan):** "trên bàn 7×7" → "trên bàn cỡ theo từng trận (5×5 đến 10×8)".
- **Dòng 94 (ngoài phạm vi):** bỏ dòng "bàn có kích thước khác 7×7".
- **Dòng 198 (Render), dòng 242 (Hoàn tác), dòng 363 (ADR-002):** "7×7" → "tối đa 10×8 (80 ô)". Kết luận giữ nguyên.
- **Dòng 574:** "vẽ 49 ô" → "vẽ mọi ô của bàn".
- **Định dạng file trận (sau ký hiệu tọa độ):** thêm mục **Cỡ bàn**:
  > Cỡ bàn suy ra từ lớp `dia_hinh`: số dòng là số hàng, số ký hiệu trên một dòng là số cột. Lớp `quan` và mọi lớp khác phải cùng cỡ. Hợp lệ khi số cột từ 5 đến 10 và số hàng từ 5 đến 8; sai thì báo lỗi tiếng Việt, ghi rõ file và cỡ đọc được. Hai giới hạn này là hằng số `BOARD_MIN` và `BOARD_MAX` trong `board_layers.gd`, thay cho `BOARD_SIZE`. Kịch bản luật dùng cùng luật này.
- **Bảng quy ước ô ↔ điểm (dòng 678):** thêm ý "`BoardView` canh giữa bàn theo `level.size` trong vùng chơi; cạnh ô hiện 64 px; nếu không vừa thì thu theo bậc nguyên (không thu lẻ)".

### 4.3 Epics (`epics.md`)

- **FR1:** "Bàn 7×7 ô vuông, …" → "Bàn ô vuông, cỡ theo từng trận (5×5 đến 10 cột × 8 hàng, có thể không vuông), đi 4 hướng, …".
- **FR2:** thêm ý "cỡ bàn suy ra từ bàn cờ chữ".
- **Ngân sách giờ:** E1 từ khoảng 24 lên khoảng 27 giờ; tổng từ khoảng 146 lên khoảng 149 giờ. Ghi chú "E1 thêm ~3 giờ ngày 2026-10-20".
- **Phương án cắt (dòng 184):** thêm "cỡ bàn theo trận (Story 1.9; khi cắt thì giữ 7×7)".
- **Mô tả E0 (dòng 189, 219):** giữ nguyên, vì E0 đã xong.
- **Mô tả E1 (dòng 193):** thêm "mỗi trận một cỡ bàn".
- **Story 1.9 mới**, chèn sau Story 1.8:

> ### Story 1.9: Cỡ bàn theo file trận
>
> Là tác giả,
> tôi muốn mỗi trận có cỡ bàn riêng theo quy mô trận thật,
> để trận phục kích nhỏ và trận Bạch Đằng lớn không phải cùng một bàn 7×7.
>
> _Thêm 2026-10-20 theo `sprint-change-proposal-2026-10-20-co-ban.md`. Làm ngay sau Story 1.8, trước Story 2.4. Cắt được: khi cắt thì giữ 7×7._
>
> **Tiêu chí nghiệm thu:**
>
> **Cho** một trận thử `thu_co_nho.json` cỡ 5×5 và một trận thử `thu_co_lon.json` cỡ 10×8 (chỉ mở được khi bật dev)
> **Khi** mở từng trận
> **Thì** bàn hiện đúng số cột và số hàng như trong file, nằm gọn trong cửa sổ, không đè lên HUD
> **Và** ô hiện 64 px; nếu phải thu nhỏ thì thu theo bậc nguyên, không nhòe
> **Và** trận 1 và mọi trận thử 7×7 cũ hiện y như trước
>
> **Khi** sửa một file trận cho có một dòng thiếu ký hiệu, lớp `quan` khác cỡ lớp `dia_hinh`, hoặc bàn 11×8
> **Thì** game báo lỗi tiếng Việt, ghi rõ file, dòng và cỡ đọc được
>
> **Khi** ở trận 10×8, chọn tướng, đi, đánh đẩy vào mép bàn, bấm F1
> **Thì** ô sáng, đường đi, viền mục tiêu, va chạm với mép bàn và tọa độ F1 đều đúng ở cả cột 9 và hàng 7
> **Và** bấm vào mọi ô (thử các góc và mép) thì chọn đúng ô đó
>
> **Và** kịch bản luật viết được trên bàn khác 7×7 (thêm ít nhất một kịch bản mép bàn trên bàn 5×6)
> **Và** `tools/test.sh` xanh; test không còn lặp cứng `range(7)`, mà lặp theo cỡ bàn của trận thử
> **Và** mục "tràn dưới HUD" trong `deferred-work.md` được đánh dấu xong ở Story 1.9
> **Và** không sửa luật trong `src/core/`, ngoài việc đọc cỡ bàn từ `level.size`

### 4.4 `project-context.md`

**Dòng 48:** "Bàn 7×7 nên hiệu năng **không phải vấn đề**" → "Bàn tối đa 10×8 (80 ô) nên hiệu năng **không phải vấn đề**". Thêm một luật: "Không lặp cứng cỡ bàn (`range(7)`, `49`); luôn dùng `level.size` hoặc cỡ của trận thử."

### 4.5 Danh sách hình E8 (`art-reference/danh-sach-hinh-e8.md`)

- **Thông số chung:**
  - "Ô 32×32 px, phóng to ×2 hoặc ×3" → "Ô **64×64 px**, hiện 1:1".
  - "Vật đứng khung rộng 32 px, cao tới 48 px" → "Vật đứng và quân: khung **64×64**. Chân hoặc đáy nằm trong 64 px dưới cùng của ô. Vũ khí dài không thò quá nửa ô sang hai bên."
- **Bảng A:** đổi các kích thước 32×32 thành 64×64, và 32×48 hoặc 32×40 thành 64×64.
- **Mục B2 (Phạm Ngũ Lão):** thêm "Bản nháp AI: `img/Pham_Ngu_Lao_muscular_13th/` (PixelLab, 64×64, 8 hướng, chỉ có tư thế đứng). Cần: đổi về bảng màu chung; kiểm tra áo choàng đỏ ở hướng đông và tây (prompt không yêu cầu); đối chiếu giáp sơn đen và khăn đỏ với tư liệu; xem lại ngọn giáo cầm ngang (61 px, thò sang ô bên cạnh)."
- **Kiểm tra trước khi đưa hình vào game, mục 1:** "đúng lưới 32 px" → "đúng lưới 64 px".

### 4.6 `game/assets/CREDITS.md`

Thêm một dòng vào bảng Hình. Đánh dấu là bản nháp, chưa đưa vào `game/assets/`:

| B2 Phạm Ngũ Lão (nháp) | `img/Pham_Ngu_Lao_muscular_13th/` (chưa vào game) | PixelLab | tác giả tạo bằng AI | theo điều khoản PixelLab (cần kiểm tra quyền dùng thương mại) | Có: PixelLab, chưa sửa | chưa sửa | Chưa | 2026-10-19 |

### 4.7 `sprint-status.yaml`

Thêm `1-9-co-ban-theo-file-tran: backlog  # làm ngay sau 1-8, trước 2-4`.

## 5. Bàn giao

- **Phạm vi:** nhỏ đến vừa. Developer làm trực tiếp, không cần lập lại kế hoạch.
- **Thứ tự:**
  1. Story 1.8 (nhìn chếch).
  2. **Story 1.9 (cỡ bàn).**
  3. Story 2.4.
  4. Khi làm 1.8, có thể đặt sẵn cạnh ô 64 px cho khớp E8.
- **Tiêu chí thành công:**
  - Trận 5×5 và trận 10×8 đều hiện gọn, chọn đúng ô.
  - Trận cũ không đổi.
  - Lỗi cỡ bàn được báo bằng tiếng Việt.
  - `tools/test.sh` xanh.
- **Việc của tác giả:**
  - Duyệt kịch bản mép bàn trên bàn 5×6.
  - Chọn cỡ bàn thật cho từng trận khi thiết kế trận (Story 2.14, 3.x, 4.5).
  - Sửa tay và đổi bảng màu cho bộ hình Phạm Ngũ Lão ở E8.
  - Kiểm tra quyền dùng thương mại của PixelLab trước khi phát hành.
