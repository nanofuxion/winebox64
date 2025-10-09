#!/bin/bash

TARGET="${1:-localhost}"
PORT="${2:-27015}"

echo "NetXI Gamepad Client"
echo "===================="
echo ""
echo "This script sends gamepad input to Wine running in the Docker container"
echo "Target: $TARGET:$PORT"
echo ""
echo "Requirements:"
echo "  - SDL2 (brew install sdl2 on macOS)"
echo "  - Game controller connected to this machine"
echo ""
echo "Press Ctrl+C to exit"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT="$SCRIPT_DIR/netxi/client/netxi-client"

if [ ! -f "$CLIENT" ]; then
    echo "Error: NetXI client not found at $CLIENT"
    echo "Build it with: cd $SCRIPT_DIR/netxi/client && ./build.sh"
    exit 1
fi

exec "$CLIENT" -server "$TARGET" -port "$PORT" -controller 0

