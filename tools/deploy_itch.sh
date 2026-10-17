#!/usr/bin/env bash
# Đẩy bản web trong build/web/ lên itch.io bằng butler. Ví dụ: tools/deploy_itch.sh
# Cần: tools/build_web.sh đã chạy, tools/itch.cfg đã điền, đã đăng nhập (tools/dang_nhap_itch.sh).
# Script không bao giờ đổi trang sang công khai; chế độ hiển thị chỉ đổi trên trang itch.io.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

CFG="$REPO_ROOT/tools/itch.cfg"
WEB="$REPO_ROOT/build/web"
KENH="html5"

if [[ ! -x "$BUTLER" ]]; then
	echo "Lỗi: chưa có butler. Chạy tools/cai_dat.sh trước." >&2
	exit 1
fi

target="$(sed -n 's/^ITCH_TARGET=//p' "$CFG" | tr -d '[:space:]')"
if [[ ! "$target" =~ ^[A-Za-z0-9_-]+/[A-Za-z0-9_-]+$ ]]; then
	echo "Lỗi: chưa điền tài khoản itch.io. Sửa dòng ITCH_TARGET trong tools/itch.cfg thành <tài khoản>/<tên trang>." >&2
	exit 1
fi
tai_khoan="${target%%/*}"
ten_trang="${target#*/}"
link="https://$tai_khoan.itch.io/$ten_trang"

if [[ ! -f "$WEB/index.html" ]]; then
	echo "Lỗi: chưa có bản build. Chạy tools/build_web.sh trước." >&2
	exit 1
fi

# Khóa đăng nhập: butler lưu ở đường dẫn mặc định của --identity (khác nhau theo máy), hoặc biến BUTLER_API_KEY.
khoa="$("$BUTLER" --help 2>&1 | sed -n 's/.*--identity="\([^"]*\)".*/\1/p' | head -1)"
if [[ -z "${BUTLER_API_KEY:-}" && ( -z "$khoa" || ! -f "$khoa" ) ]]; then
	echo "Lỗi: butler chưa đăng nhập itch.io. Chạy tools/dang_nhap_itch.sh (một lần) rồi chạy lại." >&2
	exit 1
fi

phien_ban="$(sed -n 's/^config\/version="\(.*\)"$/\1/p' "$REPO_ROOT/game/project.godot")"
commit="$(sed -n 's/.*"commit": "\(.*\)".*/\1/p' "$REPO_ROOT/game/build_info.json" 2>/dev/null || true)"
commit="${commit:-dev}"
if [[ "$commit" == *-sua ]]; then
	echo "⚠️  Bản build này có thay đổi chưa commit ($commit). Vẫn đẩy lên."
fi

echo "Đang đẩy bản v$phien_ban · $commit lên $target:$KENH ..."
"$BUTLER" push "$WEB" "$target:$KENH" --userversion "$phien_ban-$commit"

# Kiểm riêng tư: trang Draft trả 404 cho người chưa đăng nhập.
ma="$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$link" || true)"
if [[ "$ma" == "404" ]]; then
	echo "🔒 Trang đang riêng tư (người lạ không xem được)."
else
	echo "⚠️  CẢNH BÁO: trang có thể đang CÔNG KHAI (mã $ma). Vào $link/edit, mục Visibility & access, chọn Draft rồi Save."
fi

echo "✅ Đã đẩy lên itch.io. Link (đăng nhập itch.io bằng tài khoản của bạn để xem): $link"
