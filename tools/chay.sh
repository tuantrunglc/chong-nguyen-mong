#!/usr/bin/env bash
# Chạy game bản desktop trên máy. Ví dụ: tools/chay.sh --dev --tran=3
# Mọi tham số được chuyển nguyên vào game (game đọc ở Story 0.3).
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

# Ghi mã commit để game hiện ở góc màn hình. Có thay đổi chưa commit thì thêm "-sua".
commit="dev"
if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --short HEAD >/dev/null 2>&1; then
	commit="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
	if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
		commit="$commit-sua"
	fi
fi
printf '{"commit": "%s"}\n' "$commit" > "$REPO_ROOT/game/build_info.json"

exec "$GODOT" --path "$REPO_ROOT/game" -- "$@"
