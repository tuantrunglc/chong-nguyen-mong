# File mẫu cho tools/check_boundaries.sh

`tools/test.sh` dùng hai thư mục này để tự kiểm công cụ kiểm ranh giới trước khi kiểm code thật:

- `vi_pham/`: mỗi file vi phạm một luật; công cụ phải báo trượt. Mỗi file ghi lý do mong đợi ở dòng `# mong_doi: <lý do>` (có thể nhiều dòng), chép đúng chữ lý do trong `check_boundaries.sh`. Thêm luật mới thì thêm một file mẫu chỉ vi phạm luật đó.
- `hop_le/`: không vi phạm gì; công cụ phải báo đạt.

Mỗi thư mục đóng vai `game/src/`. Các file nằm ngoài `game/` nên Godot không nạp chúng.
