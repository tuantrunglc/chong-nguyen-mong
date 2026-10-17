#!/usr/bin/env bash
# Xuất bản web (đơn luồng) vào build/web/. Ví dụ: tools/build_web.sh
# In dung lượng bản nén; vượt 25 MB thì báo trượt (mã thoát 1). Sau đó đẩy lên bằng tools/deploy_itch.sh.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

GAME="$REPO_ROOT/game"
BUILD="$REPO_ROOT/build"
WEB="$BUILD/web"
ZIP="$BUILD/web.zip"
IMPORT_LOG="$BUILD/web_import.log"
IMPORT_LOG_LAN1="$BUILD/web_import.lan1.log"
EXPORT_LOG="$BUILD/web_export.log"
# Chỉ có khi lần build cuối đạt; tools/deploy_itch.sh đòi file này và đọc mã commit từ đây.
DAU_BUILD="$BUILD/web_build_info.json"
GIOI_HAN_BYTE=25000000
LOI_SCRIPT='SCRIPT ERROR|Parse Error'

# In số byte theo MB (1 MB = 1 000 000 byte), một chữ số thập phân.
mb() {
	awk -v b="$1" 'BEGIN { printf "%.1f", b / 1000000 }'
}

TEMPLATE="$GODOT_DATA_DIR/export_templates/4.7.2.stable/web_nothreads_release.zip"
if [[ ! -f "$TEMPLATE" ]]; then
	echo "Lỗi: chưa có export template web. Chạy tools/cai_dat.sh." >&2
	exit 1
fi

mkdir -p "$BUILD"
rm -f "$DAU_BUILD"
ghi_build_info

# Quét project trước khi export. Repo mới clone: lần quét đầu báo lỗi oan (Theme nạp trước font),
# nên quét lại một lần; lỗi thật trong script vẫn còn ở lần hai.
echo "Đang quét project ..."
"$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1 || true
if grep -qE "$LOI_SCRIPT" "$IMPORT_LOG"; then
	mv "$IMPORT_LOG" "$IMPORT_LOG_LAN1"
	"$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1 || true
fi
if grep -qE "$LOI_SCRIPT" "$IMPORT_LOG"; then
	echo "❌ trượt: có script game lỗi (xem build/web_import.log):" >&2
	grep -A1 -E "$LOI_SCRIPT" "$IMPORT_LOG" | grep -vE '^--$' | head -10 >&2
	exit 1
fi

echo "Đang xuất bản web ..."
rm -rf "$WEB" "$ZIP"
mkdir -p "$WEB"
ma_export=0
"$GODOT" --headless --path "$GAME" --export-release "Web" "$WEB/index.html" >"$EXPORT_LOG" 2>&1 || ma_export=$?
# Chống xanh giả: Godot có thể thoát mã 0 mà vẫn ghi ERROR vào log.
if (( ma_export != 0 )) || grep -qE '^ERROR|SCRIPT ERROR' "$EXPORT_LOG"; then
	echo "❌ trượt: Godot không xuất được bản web (xem build/web_export.log):" >&2
	grep -A1 -E '^ERROR|SCRIPT ERROR' "$EXPORT_LOG" | grep -vE '^--$' | head -10 >&2 || true
	exit 1
fi
for f in index.html index.wasm index.pck index.js; do
	if [[ ! -f "$WEB/$f" ]]; then
		echo "❌ trượt: bản web thiếu file $f (xem build/web_export.log)" >&2
		exit 1
	fi
done

# Giấy phép font OFL phải đi kèm bản phát hành.
cp "$GAME/assets/fonts/OFL.txt" "$WEB/OFL.txt"

(cd "$WEB" && zip -qr -9 "$ZIP" .)
nen=$(wc -c <"$ZIP" | tr -d ' ')
chua_nen=$(find "$WEB" -type f -exec cat {} + | wc -c | tr -d ' ')
echo "Dung lượng bản nén: $(mb "$nen") MB (giới hạn $(mb "$GIOI_HAN_BYTE") MB); chưa nén: $(mb "$chua_nen") MB"
if (( nen > GIOI_HAN_BYTE )); then
	echo "❌ trượt: bản nén vượt $(mb "$GIOI_HAN_BYTE") MB" >&2
	exit 1
fi

phien_ban="$(sed -n 's/^config\/version="\(.*\)"$/\1/p' "$GAME/project.godot")"
commit="$(sed -n 's/.*"commit": "\(.*\)".*/\1/p' "$GAME/build_info.json")"
cp "$GAME/build_info.json" "$DAU_BUILD"
echo "✅ Đã build bản web vào build/web/ (v$phien_ban · $commit)"
