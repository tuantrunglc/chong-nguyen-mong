---
title: 'Đề xuất thay đổi: bàn cờ nghiêng (isometric) tạm sau Epic 1'
date: '2026-10-18'
status: 'đã duyệt 2026-10-18, đã áp dụng'
mode: 'batch'
scope: 'Nhỏ (thêm 1 story vào E1, sửa GDD, kiến trúc, epics, sprint-status)'
---

# Đề xuất thay đổi: bàn cờ nghiêng (isometric) tạm sau Epic 1

## 1. Vấn đề

**Phát hiện khi nào:** 2026-10-18, khi đang làm Story 1.4. Tác giả xem bàn cờ và thấy "vẫn 2D quá".

**Vấn đề:** bàn cờ hiện vẽ nhìn thẳng từ trên xuống, ô vuông phẳng. Theo GDD, hình ảnh để E8 (giai đoạn 1). Tác giả muốn thấy chiều sâu sớm hơn, nhưng chưa cần tranh thật.

**Loại thay đổi:** yêu cầu mới từ người quyết spec (tác giả).

**Quyết định của tác giả (2026-10-18):**
1. Chèn **một story bàn cờ isometric tạm** ngay sau Story 1.6, trước Epic 2.
2. Phạm vi: bàn cờ nghiêng, ô hình thoi; quân **vẫn là đồng tròn khắc chữ**; địa hình bằng **hình khối và màu tạm**. Không dùng tranh AI.
3. Tranh thật, âm thanh, và hướng isometric bằng tranh 2D vẫn để **E8**. Không làm 3D thật.

## 2. Phân tích ảnh hưởng

### Epic
- **E1:** thêm Story 1.7. Ngân sách giờ E1 tăng từ ~18 lên ~21 giờ.
- **E2:** không đổi story. Các story vẽ thêm lên bàn (2.7 báo đòn, 2.10 rê chuột, 2.11 hoạt ảnh, 2.12 xem trước) sẽ vẽ thẳng trên bàn nghiêng. Làm bây giờ thì không phải vẽ lại những phần này sau.
- **E3, E4:** không đổi. Story 4.7 (hiệu năng) đo luôn bàn nghiêng.
- **E8 (giai đoạn 1):** chỉ còn thay hình khối tạm bằng tranh.

### Story
- 1.4 đang làm, 1.5 và 1.6 chưa làm. Không story nào phải làm lại. Story 1.7 làm sau cùng trong E1, khi mọi thao tác chuột của E1 đã có.

### Tài liệu cần sửa
- GDD, mục Art Style: ghi chú 2,5D đổi thành "bàn nghiêng tạm làm ở Story 1.7; tranh vẫn ở E8".
- GDD, decision-log: thêm dòng chốt.
- `epics.md`: thêm Story 1.7, sửa bảng giờ, mô tả E1, FR3.
- `game-architecture.md`: thêm quy ước phép chuyển tọa độ ô ↔ màn hình và thứ tự che khuất.
- `sprint-status.yaml`: thêm `1-7-ban-co-nghieng-isometric-tam: backlog`.

### Kỹ thuật
- **Luật không đổi.** `core/`, dữ liệu trận, kịch bản luật và tọa độ `cot,hang` trong file giữ nguyên. Đây chỉ là đổi cách vẽ.
- Phép đổi ô sang điểm trên màn hình (và ngược lại khi bấm chuột) hiện nằm gọn ở hai hàm trong `board_view.gd`. Story 1.7 sửa hai hàm này, phần vẽ ô, chữ địa hình và vị trí đồng quân.
- Thêm thứ tự che khuất: vật ở hàng gần người xem vẽ đè lên vật ở xa.
- Bản web vẫn nhẹ (chỉ vẽ hình 2D bằng code), không ảnh hưởng NFR1 (60 FPS).

## 3. Hướng đi đề xuất

**Điều chỉnh trực tiếp:** thêm 1 story vào cuối E1. Không cần quay lui, không cắt phạm vi.
- Công sức: thấp (~3 giờ). Rủi ro: thấp.
- Lịch: thêm khoảng 3 giờ vào tổng ~140 giờ của prototype.
- Có thể cắt: nếu E1 trễ, Story 1.7 là story cắt được, vì E2 chạy được trên bàn phẳng.

## 4. Chi tiết thay đổi

### 4.1 Spec bàn nghiêng

- Ô vuông của bàn 7×7 vẽ thành **hình thoi**, rộng gấp đôi cao (kiểu isometric 2:1).
- **Ô `0,0` (góc trên bên trái trong file) nằm ở đỉnh trên cùng** của bàn. Cột tăng thì đi xuống bên phải, hàng tăng thì đi xuống bên trái. Hướng Bắc trong file thành hướng chéo lên bên phải trên màn hình. *(Tác giả đã xác nhận 2026-10-18.)*
- **Địa hình:** đất trống phẳng; sông thấp hơn mặt đất một chút, màu nước; rừng, kho lương, làng, ô ải là **khối nhô lên** có mặt bên tối hơn; hầm chông phẳng, có ký hiệu. Vẫn giữ chữ hoặc ký hiệu nhỏ để phân biệt.
- **Quân:** đồng tròn khắc chữ như cũ, **đứng** trên ô và có bóng dưới chân. Vẫn hiện số máu.
- **Che khuất:** khối hoặc quân ở gần người xem vẽ đè lên vật ở xa.
- Các thứ đã có giữ nguyên ý nghĩa: ô sáng, đường đi, vòng chọn tướng, F1 hiện tọa độ và id, phím `1` `2` `3`, bấm chuột chọn ô.
- Bàn nằm gọn trong cửa sổ 1280×720, chừa chỗ cho HUD.

### 4.2 GDD (`gdds/gdd-GameTest-2026-10-15/gdd.md`, mục Art Style)

CŨ: "**Góc nhìn 2,5D** [HOÃN SANG E8] (ghi chú 2026-10-18): … Có thể làm sớm bằng một story nhỏ … khi đó chạy `bmad-correct-course`."

MỚI: "**Góc nhìn 2,5D** (chốt 2026-10-18): bàn cờ isometric, ô hình thoi, làm **sớm ở Story 1.7** với hình khối và màu tạm; quân vẫn là đồng tròn khắc chữ. [HOÃN SANG E8] thay hình khối tạm bằng tranh 2D vẽ theo góc nghiêng. Không làm 3D thật (chi phí, hiệu năng web, khó sửa trang phục thời Trần)."

Decision-log, thêm: "2026-10-18: CHỐT làm bàn cờ isometric tạm ở Story 1.7 (cuối E1): ô thoi, ô `0,0` ở đỉnh trên, địa hình bằng khối và màu tạm, quân vẫn là đồng tròn. Tranh vẫn ở E8. Luật không đổi."

### 4.3 Kiến trúc (`game-architecture.md`)

Thêm vào phần mẫu triển khai, mục tọa độ:
- Mọi phép đổi ô ↔ điểm màn hình chỉ nằm trong `board_view.gd` (`cell_center`, `cell_at`). Các view khác (`telegraph_view`, `preview_view`, `event_player`, `unit_token`) phải gọi hai hàm này, không tự tính.
- Thứ tự vẽ theo `cot + hang` (lớn hơn thì vẽ sau).
- Bổ sung chú thích cho dòng `board_view.gd`: "vẽ 49 ô thoi (isometric) bằng code".

### 4.4 Epics (`epics.md`)

- Bảng giờ: E1 `~18` → `~21`, số story `6` → `7`; tổng ≈ 143 giờ.
- Mô tả E1: thêm "… và thấy bàn cờ nghiêng (isometric) tạm".
- FR3, thêm cuối: "Bàn vẽ nghiêng kiểu isometric (Story 1.7)."
- Danh sách cắt được khi trễ: thêm Story 1.7.
- Thêm story mới sau Story 1.6:

> ### Story 1.7: Bàn cờ nghiêng (isometric) tạm
>
> Là tác giả,
> tôi muốn bàn cờ trông có chiều sâu,
> để game bớt phẳng ngay trong prototype, trước khi có tranh ở E8.
>
> **Tiêu chí nghiệm thu:**
>
> **Cho** trận 1 đang mở
> **Thì** bàn 7×7 hiện thành hình thoi lớn, mỗi ô là một hình thoi; ô `0,0` ở đỉnh trên cùng; bàn nằm gọn trong cửa sổ
> **Và** sông thấp hơn mặt đất; rừng, kho lương, làng, ô ải là khối nhô lên; mỗi loại ô vẫn phân biệt được bằng màu hoặc ký hiệu
> **Và** mỗi quân là đồng tròn khắc chữ đứng trên ô, có bóng, vẫn hiện số máu
> **Và** quân hoặc khối ở gần người xem che lên vật ở phía sau, không bị ngược
>
> **Khi** bấm vào bất kỳ ô nào, kể cả sát mép hình thoi
> **Thì** game chọn đúng ô đó (thử với cả 49 ô)
>
> **Khi** chọn tướng và rê chuột lên ô sáng
> **Thì** ô sáng, vòng chọn và đường đi hiện đúng trên bàn nghiêng như Story 1.4
>
> **Khi** bật dev và bấm F1
> **Thì** tọa độ `cot,hang` và id quân hiện đúng trên từng ô thoi
>
> **Và** `tools/test.sh` xanh; có test cho phép đổi ô ↔ điểm (đi rồi về đúng ô, điểm sát mép rơi đúng ô)
> **Và** bản web trên itch.io chạy mượt như trước
> **Và** không sửa gì trong `src/core/`, dữ liệu trận và kịch bản luật

### 4.5 `sprint-status.yaml`

Thêm sau `1-6-f5-nap-lai-du-lieu`:
`1-7-ban-co-nghieng-isometric-tam: backlog`

## 5. Bàn giao

- **Phạm vi:** Nhỏ. AI (vai Developer) sửa tài liệu ngay sau khi duyệt, rồi làm Story 1.7 theo thứ tự sau Story 1.6.
- **Tiêu chí thành công:** tác giả mở trận 1, thấy bàn nghiêng có khối nổi, bấm đúng ô ở mọi chỗ, mọi thao tác của E1 vẫn chạy; test xanh.

## 6. Tác giả đã xác nhận

- **Góc đặt ô `0,0`:** CHỐT đặt ở **đỉnh trên cùng**, nên hướng Bắc trong file thành hướng chéo lên phải. Cách khác là xoay bàn để hàng trên cùng của file nằm ở cạnh trên bên trái. Chọn cách nào cũng không đổi luật.
