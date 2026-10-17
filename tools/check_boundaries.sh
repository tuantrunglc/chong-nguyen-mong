#!/usr/bin/env bash
# Kiểm ranh giới giữa các tầng code (luật kiến trúc). tools/test.sh chạy script này đầu tiên.
# Cách dùng: tools/check_boundaries.sh [thư mục src]   (mặc định game/src)
# Có vi phạm thì in từng dòng "❌ file:dòng: lý do" và thoát mã 1.
set -euo pipefail

GODOT_BO_QUA_KIEM_TRA=1
source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

SRC="${1:-$REPO_ROOT/game/src}"
if [[ ! -d "$SRC" ]]; then
	echo "Lỗi: không thấy thư mục $SRC" >&2
	exit 2
fi
SRC="$(cd "$SRC" && pwd)"
# Đường dẫn in ra tính từ thư mục cha của src (với game/src là "src/core/...").
GOC="$(dirname "$SRC")"

so_loi=0

# In vi phạm cho mọi file .gd trong một thư mục (đệ quy). Phần chú thích sau # được bỏ qua.
# Tham số: thư mục, mẫu grep -E, lý do, [mẫu loại trừ], [file được miễn]
quet() {
	local thu_muc="$1" mau="$2" ly_do="$3" loai_tru="${4:-}" mien="${5:-}"
	[[ -d "$thu_muc" ]] || return 0
	local file so dong
	while IFS= read -r file; do
		[[ -n "$mien" && "$file" == "$mien" ]] && continue
		while IFS=: read -r so dong; do
			[[ -n "$loai_tru" ]] && grep -qE "$loai_tru" <<<"$dong" && continue
			echo "❌ ${file#"$GOC"/}:$so: $ly_do"
			so_loi=$((so_loi + 1))
		done < <(sed 's/#.*//' "$file" | grep -nE "$mau" || true)
	done < <(find "$thu_muc" -type f -name '*.gd' | sort)
}

# Luật 1: src/core chỉ là dữ liệu thuần (RefCounted): không Node, không I/O, không ngẫu nhiên.
CORE="$SRC/core"
quet "$CORE" '^[[:space:]]*extends[[:space:]]' "lõi luật chỉ được extends RefCounted" \
	'^[[:space:]]*extends[[:space:]]+RefCounted[[:space:]]*$'
quet "$CORE" '\bNode\w*\b' "lõi luật không được dùng Node"
quet "$CORE" 'get_tree\(|get_node\(|\$[A-Za-z_"%]' "lõi luật không được truy cập cây scene"
quet "$CORE" '\bInput\b' "lõi luật không được đọc Input"
quet "$CORE" '\bFileAccess\b|\bDirAccess\b' "lõi luật không được đọc/ghi file"
quet "$CORE" '\bTime\.' "lõi luật không được dùng thời gian thực"
quet "$CORE" '\brandi|\brandf|\brandomize\(|RandomNumberGenerator' "lõi luật không được dùng số ngẫu nhiên"
quet "$CORE" '\bprint(err|raw|t|_rich)?\(' "lõi luật không được dùng print"

# Luật 2: src/data không dùng Node (được dùng FileAccess).
DATA="$SRC/data"
quet "$DATA" '\bNode\w*\b|get_tree\(|\$[A-Za-z_"%]' "src/data không được dùng Node"

# Chỉ Effects được sửa máu và vị trí, ở mọi nơi trong src/.
quet "$SRC" '\.(hp|cell)[[:space:]]*(\+=|-=|=[^=])' "chỉ Effects được sửa máu và vị trí (.hp/.cell)" \
	'' "$SRC/core/effects.gd"

if (( so_loi > 0 )); then
	echo "Ranh giới: $so_loi lỗi"
	exit 1
fi
echo "Ranh giới: đạt"
