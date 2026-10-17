#!/usr/bin/env bash
# Claude Code tự chạy file này (qua .mcp.json), tác giả không gõ trực tiếp.
# Khởi động Context7 4.1.1 (tra tài liệu Godot 4.7). Không dùng API key (quyết định của tác giả, Story 0.6);
# khi cần thì đặt biến môi trường CONTEXT7_API_KEY trên máy, Context7 tự đọc. Không ghi key vào repo.
# KHÔNG được in gì ra stdout: stdout là đường nói chuyện MCP, in chữ vào đó làm hỏng kết nối.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

if [[ ! -f "$MCP_DIR/.installed" ]]; then
	echo "Lỗi: chưa có công cụ AI. Chạy tools/cai_dat.sh trước." >&2
	exit 1
fi
if [[ "$(cat "$MCP_DIR/.installed")" != "$(ma_cai_mcp)" ]]; then
	echo "Lỗi: công cụ AI đã cài là bản cũ (tools/mcp/ vừa đổi). Chạy tools/cai_dat.sh rồi mở lại Claude Code." >&2
	exit 1
fi

exec node "$MCP_DIR/node_modules/@upstash/context7-mcp/dist/index.js"
