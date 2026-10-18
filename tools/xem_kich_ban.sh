#!/usr/bin/env bash
# In kịch bản luật chưa duyệt: bàn trước và bàn sau cạnh nhau, kèm mô tả. Ví dụ:
#   tools/xem_kich_ban.sh               mọi nhóm
#   tools/xem_kich_ban.sh di_chuyen     chỉ nhóm di_chuyen
#   tools/xem_kich_ban.sh --tat_ca      in cả kịch bản đã duyệt
# Mã thoát 1 nếu có file sai định dạng, tên nhóm không có, hoặc script của game bị lỗi.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

# Godot gặp lỗi script vẫn thoát mã 0, chỉ in ra các dòng này (như tools/test.sh).
LOI_SCRIPT='SCRIPT ERROR|Parse Error|Failed to load script'
NHAT_KY="$(mktemp)"
trap 'rm -f "$NHAT_KY"' EXIT

in_loi_script() {
	grep -A1 -E "$LOI_SCRIPT" "$NHAT_KY" | grep -vE '^--$' | head -10 >&2
}

# game/.godot/ không có trong git: quét project trước để Godot biết mọi class_name.
# Repo mới clone: lần quét đầu có thể báo lỗi oan (Theme nạp trước font), nên có lỗi thì quét lại một lần.
quet() {
	"$GODOT" --headless --path "$REPO_ROOT/game" --import >"$NHAT_KY" 2>&1 && ! grep -qE "$LOI_SCRIPT" "$NHAT_KY"
}
if ! quet && ! quet; then
	echo "Lỗi: Godot không quét được project trong game/:" >&2
	in_loi_script
	exit 1
fi

# Tham số đi qua biến môi trường (mỗi dòng một tham số), không qua dòng lệnh của Godot:
# AppState đọc mọi tham số sau "--" và sẽ cảnh báo "tham số lạ".
XEM_KICH_BAN_THAM_SO="$(printf '%s\n' "$@")"
export XEM_KICH_BAN_THAM_SO

# --quit-after: script lỗi giữa chừng thì không tới được quit(), Godot sẽ chạy mãi nếu không có giới hạn.
set +e
"$GODOT" --headless --path "$REPO_ROOT/game" --quit-after 600 -s res://tests/scenario_viewer.gd >"$NHAT_KY" 2>&1
ma=$?
set -e

# Bỏ dòng giới thiệu của Godot và dòng trống ngay sau nó.
awk 'NR == 1 && /^Godot Engine v/ { bo = 1; next } bo && /^$/ { bo = 0; next } { bo = 0; print }' "$NHAT_KY"
if grep -qE "$LOI_SCRIPT" "$NHAT_KY"; then
	echo "Lỗi: script của công cụ duyệt bị lỗi (các dòng SCRIPT ERROR ở trên)." >&2
	exit 1
fi
exit "$ma"
