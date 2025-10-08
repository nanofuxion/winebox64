#!/bin/bash
set -euxo pipefail

export PATH=/opt/wine/bin:$PATH
export WINEPREFIX=/home/gamer/.wine64

echo "🍷 Adding Wine to PATH..."
echo 'export PATH=/opt/wine/bin:$PATH' >> ~/.bashrc

echo "🍷 Initializing Wine prefix..."
box64 wineboot --init

sleep 2

box64 wine64 wineboot --init
sleep 2

echo "📁 Ensuring Wine directory structure exists..."
mkdir -p "$WINEPREFIX/drive_c/windows/system32"
mkdir -p "$WINEPREFIX/drive_c/windows/syswow64"

echo "📁 Verifying directory structure..."
ls -la "$WINEPREFIX/drive_c/windows/"

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip

echo "✅ Wine preparation completed!"
