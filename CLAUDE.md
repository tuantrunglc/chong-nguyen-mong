# Chống Nguyên Mông

## Đọc trước khi viết code (bắt buộc)

1. `_bmad-output/project-context.md`: luật và mẫu mọi phiên AI phải theo.
2. `_bmad-output/planning-artifacts/game-architecture.md`: kiến trúc, cây thư mục, thứ tự phân giải.

## Làm việc với tác giả

- Tác giả không đọc code. Nói bằng tiếng Việt, theo cách người test hiểu được: các bước để thử, thấy gì là đúng.
- Tác giả là người quyết spec. Luật chưa có trong tài liệu thì hỏi, không tự đoán.

## Lệnh chính (chạy từ gốc repo)

- `tools/cai_dat.sh`: cài Godot 4.7.2 vào `.tools/` (chỉ cần một lần).
- `tools/chay.sh`: chạy game. Nhận thêm `--dev`, `--tran=N`.
- `tools/test.sh`: chạy toàn bộ test, in tóm tắt tiếng Việt; mã thoát khác 0 là trượt.

## Nhìn game đang chạy (MCP)

- Chụp màn hình: chạy `tools/chay.sh --dev` ở chế độ nền, chờ khoảng 5 giây, rồi gọi `capture_screenshot` của GoPeak (chưa thấy công cụ thì gọi `tool_catalog` với từ khóa "screenshot" để bật nhóm `testing`). Xong thì tắt game.
- Xem log: đọc đầu ra của lệnh `tools/chay.sh` đang chạy nền (dòng `[INFO][...]`). Không dùng `run_project` của GoPeak: nó chạy `--headless`, không có cửa sổ, không có `--dev`.
- Bơm input (`inject_mouse_click`, `inject_key`…): tác giả cho phép, chỉ khi `--dev`, chỉ để thử. Tọa độ dạng `[x, y]`.
- Tra API Godot: Context7, thư viện `/godotengine/godot-docs`, nhánh 4.7.
- MCP chỉ để *nhìn* và *thử*. Luật và dữ liệu trận chỉ sửa trong code, có test đi kèm.

## Tiến độ

Theo dõi ở `_bmad-output/implementation-artifacts/sprint-status.yaml`.
