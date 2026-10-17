#!/usr/bin/env bash
# Chạy game bản desktop trên máy. Ví dụ: tools/chay.sh --dev --tran=3
# Mọi tham số được chuyển nguyên vào game (--dev, --tran=N).
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

# Ghi mã commit để game hiện ở góc màn hình.
ghi_build_info

# game/.godot/ không có trong git: quét project trước để Godot biết mọi class_name (repo mới clone hoặc vừa thêm file).
if ! "$GODOT" --headless --path "$REPO_ROOT/game" --import >/dev/null 2>&1; then
	echo "Lỗi: Godot không quét được project trong game/." >&2
	exit 1
fi

exec "$GODOT" --path "$REPO_ROOT/game" -- "$@"
