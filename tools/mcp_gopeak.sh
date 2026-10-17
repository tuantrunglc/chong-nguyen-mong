#!/usr/bin/env bash
# Claude Code tự chạy file này (qua .mcp.json), tác giả không gõ trực tiếp.
# Khởi động GoPeak 2.3.8 (profile compact), trỏ vào đúng bản Godot 4.7.2 trong .tools/.
# KHÔNG được in gì ra stdout: stdout là đường nói chuyện MCP, in chữ vào đó làm hỏng kết nối.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

if [[ ! -f "$MCP_DIR/.installed" ]]; then
	echo "Chưa có công cụ AI. Chạy tools/cai_dat.sh trước." >&2
	exit 1
fi

export GODOT_PATH="$GODOT"
export GOPEAK_TOOL_PROFILE="compact"
exec node "$MCP_DIR/node_modules/gopeak/build/cli.js"
