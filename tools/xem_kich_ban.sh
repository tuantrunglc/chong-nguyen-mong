#!/usr/bin/env bash
# In kịch bản luật chưa duyệt: bàn trước và bàn sau cạnh nhau, kèm mô tả. Ví dụ:
#   tools/xem_kich_ban.sh               mọi nhóm
#   tools/xem_kich_ban.sh di_chuyen     chỉ nhóm di_chuyen
#   tools/xem_kich_ban.sh --tat_ca      in cả kịch bản đã duyệt
# Mã thoát 1 nếu có file sai định dạng hoặc tên nhóm không có.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

# game/.godot/ không có trong git: quét project trước để Godot biết mọi class_name.
if ! "$GODOT" --headless --path "$REPO_ROOT/game" --import >/dev/null 2>&1; then
	echo "Lỗi: Godot không quét được project trong game/." >&2
	exit 1
fi

# Tham số đi qua biến môi trường (mỗi dòng một tham số), không qua dòng lệnh của Godot:
# AppState đọc mọi tham số sau "--" và sẽ cảnh báo "tham số lạ".
XEM_KICH_BAN_THAM_SO="$(printf '%s\n' "$@")"
export XEM_KICH_BAN_THAM_SO

# Bỏ dòng giới thiệu của Godot ở đầu ra. Mã thoát lấy của Godot (phần tử đầu của PIPESTATUS).
set +e
"$GODOT" --headless --path "$REPO_ROOT/game" -s res://tests/scenario_viewer.gd 2>&1 \
	| { grep -v '^Godot Engine v' || true; }
ma="${PIPESTATUS[0]}"
set -e
exit "$ma"
