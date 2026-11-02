#!/usr/bin/env bash
# Đẩy bản web lên VPS (45.77.174.70). Ví dụ: tools/deploy_vps.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Đang build bản web..."
"$REPO_ROOT/tools/build_web.sh"

echo "Đang đồng bộ lên VPS (saa-vps:/var/www/html/)..."
rsync -avz --delete "$REPO_ROOT/build/web/" saa-vps:/var/www/html/

echo "✅ Đã cập nhật xong bản web trên VPS!"
echo "👉 Mở thử: http://45.77.174.70/"
