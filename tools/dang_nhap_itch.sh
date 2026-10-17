#!/usr/bin/env bash
# Đăng nhập itch.io cho butler, chỉ cần làm một lần trên mỗi máy. Ví dụ: tools/dang_nhap_itch.sh
# Khóa đăng nhập được lưu trên máy (ngoài repo), không bao giờ vào git.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

if [[ ! -x "$BUTLER" ]]; then
	echo "Lỗi: chưa có butler. Chạy tools/cai_dat.sh trước." >&2
	exit 1
fi

echo "butler sẽ mở trình duyệt tới trang itch.io. Đăng nhập (nếu cần) rồi bấm đồng ý cho butler."
echo "Xong thì quay lại đây, butler tự báo đã lưu khóa."
"$BUTLER" login
