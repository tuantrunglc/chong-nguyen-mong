#!/usr/bin/env bash
# Khởi động pixel-mcp (Aseprite MCP Server) nếu máy đã cài Aseprite.
# Tự động tìm Aseprite trong /Applications hoặc đường dẫn hệ thống.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ASEPRITE_BIN=""
if command -v aseprite &>/dev/null; then
    ASEPRITE_BIN="$(command -v aseprite)"
elif [[ -f "/Applications/Aseprite.app/Contents/MacOS/aseprite" ]]; then
    ASEPRITE_BIN="/Applications/Aseprite.app/Contents/MacOS/aseprite"
elif [[ -f "$HOME/Applications/Aseprite.app/Contents/MacOS/aseprite" ]]; then
    ASEPRITE_BIN="$HOME/Applications/Aseprite.app/Contents/MacOS/aseprite"
fi

CONFIG_DIR="$HOME/.config/pixel-mcp"
CONFIG_FILE="$CONFIG_DIR/config.json"
mkdir -p "$CONFIG_DIR"

if [[ -n "$ASEPRITE_BIN" && ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
{
  "aseprite_path": "$ASEPRITE_BIN",
  "temp_dir": "/tmp/pixel-mcp",
  "timeout": 30,
  "log_level": "info"
}
EOF
fi

export PIXEL_MCP_CONFIG="$CONFIG_FILE"
exec "$PROJECT_ROOT/.tools/pixel-mcp/pixel-mcp" "$@"
