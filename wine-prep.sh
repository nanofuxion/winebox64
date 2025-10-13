#!/bin/bash
set -euxo pipefail

export WINEPREFIX=/home/gamer/.wine64

echo "🍷 Initializing Wine prefix with Hangover..."
wineboot --init

sleep 2

wine64 wineboot --init
sleep 2

echo "📁 Ensuring Wine directory structure exists..."
mkdir -p "$WINEPREFIX/drive_c/windows/system32"
mkdir -p "$WINEPREFIX/drive_c/windows/syswow64"

echo "📁 Verifying directory structure..."
ls -la "$WINEPREFIX/drive_c/windows/"

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip

echo "✅ Wine preparation completed!"
