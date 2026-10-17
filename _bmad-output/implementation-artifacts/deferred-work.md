## Deferred from: code review of 0-1-project-godot-trong-chay-duoc-tren-may (2026-10-17)

- Chưa có test tự động cho `_read_commit` trong `game/src/app/main.gd` (các trường hợp: thiếu file, JSON hỏng, không phải Dictionary, `commit` sai kiểu hoặc rỗng). Viết test GUT ở Story 0.2.
- Chưa có test tự động cho việc canh giữa và kích thước trong `BoardView.setup` (7×7 cho vị trí (332, 52); bàn cờ không vuông). Làm ở Story 0.2.
- Chưa có test cho logic commit/`-sua` trong `tools/chay.sh` và việc `kiem_tra` từ chối file sai checksum trong `tools/cai_dat.sh`. Xét lại khi có `tools/test.sh`.
- Chưa kiểm chứng: bản export có thể không chứa `res://build_info.json` (`.json` không nằm trong danh sách export mặc định), khi đó nhãn hiện `dev`. Story 0.5 cần thêm `*.json` vào bộ lọc include và kiểm tra lại.
