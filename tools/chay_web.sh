#!/usr/bin/env bash
# Chạy bản web đã build (build/web/) bằng máy chủ cục bộ để đo FPS và thử trình duyệt (Story 4.7).
# Itch.io không bật được ?dev=1 trong iframe, nên đo FPS phải qua link cục bộ này. Ví dụ: tools/chay_web.sh
# Chỉ nghe ở 127.0.0.1 (máy khác không vào được). Ctrl+C để tắt.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB="$REPO_ROOT/build/web"
CONG="${CONG_WEB:-8060}"

if [[ ! -f "$WEB/index.html" ]]; then
	echo "Lỗi: chưa có build/web/. Chạy tools/build_web.sh trước." >&2
	exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
	echo "Lỗi: cần python3 để chạy máy chủ cục bộ." >&2
	exit 1
fi

echo "Bản web đang chạy. Mở bằng Chrome, Firefox hoặc Edge:"
echo "  Trận đầu (chế độ dev, có bộ đếm FPS): http://127.0.0.1:$CONG/index.html?dev=1"
echo "  Thẳng trận 6:                           http://127.0.0.1:$CONG/index.html?dev=1&tran=6"
echo "  Như người chơi (không dev):             http://127.0.0.1:$CONG/index.html"
echo "Ctrl+C để tắt."
exec python3 -m http.server "$CONG" --bind 127.0.0.1 --directory "$WEB"
