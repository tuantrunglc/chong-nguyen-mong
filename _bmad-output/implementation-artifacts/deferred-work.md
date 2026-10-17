## Deferred from: code review of 0-1-project-godot-trong-chay-duoc-tren-may (2026-10-17)

- Chưa có test tự động cho `_read_commit` trong `game/src/app/main.gd` (các trường hợp: thiếu file, JSON hỏng, không phải Dictionary, `commit` sai kiểu hoặc rỗng). Viết test GUT ở Story 0.2. → xong ở Story 0.2 (`BuildInfo.read_commit`, `game/tests/test_build_info.gd`).
- Chưa có test tự động cho việc canh giữa và kích thước trong `BoardView.setup` (7×7 cho vị trí (332, 52); bàn cờ không vuông). Story 0.2 không làm; làm khi có kích thước bàn thứ hai.
- Chưa có test cho logic commit/`-sua` trong `tools/chay.sh` và việc `kiem_tra` từ chối file sai checksum trong `tools/cai_dat.sh`. Xét lại khi có `tools/test.sh`.
- Chưa kiểm chứng: bản export có thể không chứa `res://build_info.json` (`.json` không nằm trong danh sách export mặc định), khi đó nhãn hiện `dev`. Story 0.5 cần thêm `*.json` vào bộ lọc include và kiểm tra lại.

## Deferred from: code review of 0-2-mot-lenh-de-chay-toan-bo-test (2026-10-17)

- Khóa `da_duyet` (bước 2 của `tools/test.sh`) chưa có tự kiểm tự động: nếu regex hoặc danh sách file hỏng thì vẫn ra "đạt (0 file)" giống hôm nay. Thêm khi có kịch bản đã duyệt đầu tiên (git repo tạm, commit file khóa, sửa, đòi trượt).
- Các nhánh chống xanh giả ở bước 4 của `tools/test.sh` (thiếu XML, lỗi cú pháp, lệch số file, 0 test, mã GUT ≠ 0) chỉ được kiểm bằng tay. Cần tách phần đọc XML/log thành hàm nhận file mẫu.
- Godot treo (import hoặc test `await` mãi) thì `tools/test.sh` không kết thúc. macOS không có sẵn `timeout`, cần cơ chế riêng.
- Luật core chưa chặn `OS.get_ticks_msec()`/`OS.get_unix_time()`, `Engine.get_main_loop()`, `rand_from_seed(`. Cần cập nhật luật trong game-architecture.md rồi mới thêm vào `tools/check_boundaries.sh`.

## Deferred from: Story 0.3 (2026-10-17)

- Chưa kiểm chứng: trên itch.io, game chạy trong iframe có địa chỉ riêng (`html5.itch.zone/...`). Thêm `?dev=1` vào link trang itch.io **có thể không** tới được game, vì `LaunchOptions` đọc `window.location.search` của chính iframe. Story 0.5 phải thử: (1) link trang + `?dev=1`; (2) mở thẳng địa chỉ iframe + `?dev=1`. Ghi lại cách nào chạy được.

## Deferred from: code review of 0-3-log-co-dev-va-tham-so-khoi-dong (2026-10-17)

- `LaunchOptions.read_current()` chưa có test: cả đường web (`JavaScriptBridge.eval("window.location.search")`) lẫn đường desktop. Story 0.5 kiểm cùng mục iframe itch.io ở trên. Nếu itch.io thêm khóa lạ vào URL của iframe thì mỗi lần mở game sẽ in một dòng WARN; khi đó cần quyết có bỏ qua các khóa đó không.
- Luật mới "lõi luật không được gọi `Log.`" (`check_boundaries.sh`) chưa ghi vào danh sách cấm của `src/core/` trong `project-context.md` và `game-architecture.md` (hai nơi vẫn chỉ ghi `print`). Cần tác giả duyệt rồi mới sửa tài liệu.
- Rủi ro cho Story 0.5 / 1.6: trên trình duyệt, F1 mở trợ giúp và F5 tải lại trang. Phím dev F1/F5 có thể không tới được game. Khi có bản web phải thử; nếu bị chiếm thì chặn mặc định của trình duyệt (qua `JavaScriptBridge`) hoặc hỏi tác giả đổi phím.
