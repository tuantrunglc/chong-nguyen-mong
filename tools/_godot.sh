#!/usr/bin/env bash
# File dùng chung, không gõ trực tiếp. Mọi script trong tools/ đều `source` file này
# để dùng đúng một bản Godot 4.7.2 nằm trong .tools/, không dùng bản nào khác trên máy.
#
# Biến đặt ra: REPO_ROOT, GODOT_VERSION, GODOT_DIR, GODOT_OS, GODOT, GODOT_DATA_DIR,
# BUTLER_VERSION, BUTLER_DIR, BUTLER, GOPEAK_VERSION, CONTEXT7_VERSION, MCP_DIR. Hàm: ghi_build_info.
# GODOT_DATA_DIR: chế độ tự chứa, Godot ghi dữ liệu editor (gồm export template) vào đây.
# Đặt GODOT_BO_QUA_KIEM_TRA=1 trước khi source để không thoát khi chưa cài (dùng cho cai_dat.sh).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="4.7.2-stable"
GODOT_DIR="$REPO_ROOT/.tools/godot-4.7.2"

case "$(uname -s)-$(uname -m)" in
	Darwin-*)
		GODOT_OS="macos"
		GODOT="$GODOT_DIR/Godot.app/Contents/MacOS/Godot"
		# Trên macOS, file ._sc_ nằm trong Contents/MacOS nhưng Godot ghi editor_data/ cạnh Godot.app.
		GODOT_DATA_DIR="$GODOT_DIR/editor_data"
		;;
	Linux-x86_64)
		GODOT_OS="linux"
		GODOT="$GODOT_DIR/Godot_v${GODOT_VERSION}_linux.x86_64"
		GODOT_DATA_DIR="$GODOT_DIR/editor_data"
		;;
	*)
		echo "Lỗi: máy này ($(uname -s) $(uname -m)) chưa được hỗ trợ. Chỉ hỗ trợ macOS và Linux x86_64." >&2
		exit 1
		;;
esac

# butler: công cụ của itch.io để đẩy bản web lên (tools/deploy_itch.sh). Cài bằng tools/cai_dat.sh.
BUTLER_VERSION="15.32.0"
BUTLER_DIR="$REPO_ROOT/.tools/butler-$BUTLER_VERSION"
BUTLER="$BUTLER_DIR/butler"

# Công cụ AI (MCP): GoPeak và Context7. Phiên bản ghim trong tools/mcp/package.json + package-lock.json.
GOPEAK_VERSION="2.3.8"
CONTEXT7_VERSION="4.1.1"
MCP_DIR="$REPO_ROOT/.tools/mcp"

# Ghi mã commit vào game/build_info.json để game hiện ở góc màn hình. Có thay đổi chưa commit thì thêm "-sua".
ghi_build_info() {
	local commit="dev"
	if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --short HEAD >/dev/null 2>&1; then
		commit="$(git -C "$REPO_ROOT" rev-parse --short HEAD)"
		if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
			commit="$commit-sua"
		fi
	fi
	printf '{"commit": "%s"}\n' "$commit" > "$REPO_ROOT/game/build_info.json"
}

if [[ "${GODOT_BO_QUA_KIEM_TRA:-0}" != "1" ]]; then
	if [[ ! -f "$GODOT_DIR/.installed" || ! -x "$GODOT" ]]; then
		echo "Chưa có Godot 4.7.2. Chạy tools/cai_dat.sh trước." >&2
		exit 1
	fi
fi
