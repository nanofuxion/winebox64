#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing UHID server..."
cp "$SCRIPT_DIR/../services/uhid-server-arm64" /usr/local/bin/
chmod +x /usr/local/bin/uhid-server-arm64

echo "Installing systemd service..."
cp "$SCRIPT_DIR/uhid-server.service" /etc/systemd/system/

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling uhid-server service..."
systemctl enable uhid-server.service

echo "Starting uhid-server service..."
systemctl start uhid-server.service

echo "Service status:"
systemctl status uhid-server.service --no-pager

echo ""
echo "✅ UHID server installed and started!"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status uhid-server    # Check status"
echo "  sudo systemctl restart uhid-server   # Restart service"
echo "  sudo systemctl stop uhid-server      # Stop service"
echo "  sudo journalctl -u uhid-server -f    # View logs"

