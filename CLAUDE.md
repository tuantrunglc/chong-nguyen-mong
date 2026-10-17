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

## Tiến độ

Theo dõi ở `_bmad-output/implementation-artifacts/sprint-status.yaml`.
