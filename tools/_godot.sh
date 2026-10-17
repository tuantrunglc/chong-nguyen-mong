#!/usr/bin/env bash
# File dùng chung, không gõ trực tiếp. Mọi script trong tools/ đều `source` file này
# để dùng đúng một bản Godot 4.7.2 nằm trong .tools/, không dùng bản nào khác trên máy.
#
# Biến đặt ra: REPO_ROOT, GODOT_VERSION, GODOT_DIR, GODOT_OS, GODOT, GODOT_DATA_DIR.
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

if [[ "${GODOT_BO_QUA_KIEM_TRA:-0}" != "1" ]]; then
	if [[ ! -f "$GODOT_DIR/.installed" || ! -x "$GODOT" ]]; then
		echo "Chưa có Godot 4.7.2. Chạy tools/cai_dat.sh trước." >&2
		exit 1
	fi
fi
