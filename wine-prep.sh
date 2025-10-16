#!/bin/bash
set -euxo pipefail

export WINEPREFIX=/home/gamer/.persist/wine64

echo "🍷 Initializing Wine prefix with Hangover..."
mkdir -p /home/gamer/.persist
wineboot --init

sleep 2s 

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip
rm -rf TestD3D.zip

echo "Installing DXVK from Hangover..."
if [ -d "/opt/dxvk-v2.7.1" ]; then
    if [ -d "/opt/dxvk-v2.7.1/arm64ec" ]; then
        mkdir -p "$WINEPREFIX/drive_c/windows/system32"
        cp /opt/dxvk-v2.7.1/arm64ec/*.dll "$WINEPREFIX/drive_c/windows/system32/"
        echo "✅ Installed 64-bit ARM64EC DXVK files"
    fi
    
    if [ -d "/opt/dxvk-v2.7.1/x32" ]; then
        mkdir -p "$WINEPREFIX/drive_c/windows/syswow64"
        cp /opt/dxvk-v2.7.1/x32/*.dll "$WINEPREFIX/drive_c/windows/syswow64/"
        echo "✅ Installed 32-bit DXVK files"
    fi
else
    echo "⚠️  Warning: DXVK not found at /opt/dxvk-v2.7.1"
fi

echo "✅ Wine preparation completed!"
