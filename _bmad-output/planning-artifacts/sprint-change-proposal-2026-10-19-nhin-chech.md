---
title: 'Đề xuất thay đổi: đổi bàn isometric sang nhìn chếch, ô vuông'
date: '2026-10-19'
status: 'tác giả chốt 2026-10-19, đã áp dụng'
mode: 'batch'
scope: 'Nhỏ (thêm Story 1.8, sửa GDD, kiến trúc, epics, sprint-status)'
---

# Đổi bàn isometric sang nhìn chếch, ô vuông

## 1. Vấn đề
Tác giả gửi 2 ảnh mẫu (pixel art, nhìn chếch từ trên xuống, ô vuông) và chốt theo kiểu này. Bàn isometric của Story 1.7 (`sprint-change-proposal-2026-10-18-isometric.md`) không còn đúng hướng tranh E8.

## 2. Ảnh hưởng
- **E1:** thêm Story 1.8, ~3 giờ (E1 ~24 giờ, tổng ≈ 146 giờ). Story 1.7 giữ trạng thái xong; phần vẽ của nó được thay.
- **E2:** 2.1, 2.2 đã xong và vẽ qua `cell_center` / `cell_at` / `pick_cell`, nên chỉ cần kiểm lại viền mục tiêu. Story 1.8 làm **trước 2.3** để các story vẽ sau (2.3 trở đi) dựng thẳng trên bàn mới.
- **Luật, dữ liệu trận, kịch bản:** không đổi.
- **E8:** tranh pixel art, ô bội số của 16 px, lọc Nearest.

## 3. Thay đổi đã áp dụng
- GDD, Art Style: mục "Góc nhìn" viết lại theo hướng mới; decision-log thêm dòng 2026-10-19.
- `epics.md`: bảng giờ, mô tả E1, FR3, danh sách cắt, Story 1.8 mới.
- `game-architecture.md`: quy ước ô ↔ điểm và thứ tự vẽ theo `hang`.
- `sprint-status.yaml`: `1-8-ban-co-nhin-chech-o-vuong: backlog`.
- Ảnh mẫu và ghi chú dùng/không dùng: `art-reference/`.

## 4. Bàn giao
AI (vai Developer) tạo và làm Story 1.8 trước Story 2.3. Tác giả thử theo tiêu chí nghiệm thu trong `epics.md`.
