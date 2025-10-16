#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Stopping uhid-server service..."
systemctl stop uhid-server.service || true

echo "Disabling uhid-server service..."
systemctl disable uhid-server.service || true

echo "Removing systemd service file..."
rm -f /etc/systemd/system/uhid-server.service

echo "Removing binary..."
rm -f /usr/local/bin/uhid-server-arm64

echo "Reloading systemd..."
systemctl daemon-reload

echo "✅ UHID server uninstalled!"

