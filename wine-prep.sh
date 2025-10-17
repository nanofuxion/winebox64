#!/bin/bash
set -euxo pipefail

export WINEPREFIX=/home/gamer/.persist/wine64

echo "🍷 Initializing Wine prefix with Hangover..."
mkdir -p /home/gamer/.persist
wineboot --init
wine reg.exe add HKCU\\Software\\Wine\\Drivers /v Graphics /d wayland,x11

sleep 2s 

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip
rm -rf TestD3D.zip

echo "Checking Vulkan support..."
VULKAN_VERSION=""
if command -v vulkaninfo &> /dev/null; then
    VULKAN_VERSION=$(vulkaninfo 2>/dev/null | grep "apiVersion" | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "")
fi

if [ -z "$VULKAN_VERSION" ]; then
    echo "⚠️  Warning: Could not detect Vulkan version"
    VULKAN_MAJOR=0
    VULKAN_MINOR=0
else
    echo "Detected Vulkan version: $VULKAN_VERSION"
    VULKAN_MAJOR=$(echo "$VULKAN_VERSION" | cut -d. -f1)
    VULKAN_MINOR=$(echo "$VULKAN_VERSION" | cut -d. -f2)
fi

if [ "$VULKAN_MAJOR" -gt 1 ] || ([ "$VULKAN_MAJOR" -eq 1 ] && [ "$VULKAN_MINOR" -ge 3 ]); then
    echo "Vulkan 1.3+ detected, installing standard DXVK..."
    DXVK_DIR=$(ls -d /opt/dxvk-v* 2>/dev/null | head -1)
    if [ -n "$DXVK_DIR" ] && [ -d "$DXVK_DIR" ]; then
        echo "Found DXVK at: $DXVK_DIR"
        if [ -d "$DXVK_DIR/arm64ec" ]; then
            mkdir -p "$WINEPREFIX/drive_c/windows/system32"
            cp "$DXVK_DIR/arm64ec/"*.dll "$WINEPREFIX/drive_c/windows/system32/"
            echo "✅ Installed 64-bit ARM64EC DXVK files"
        fi
        
        if [ -d "$DXVK_DIR/x32" ]; then
            mkdir -p "$WINEPREFIX/drive_c/windows/syswow64"
            cp "$DXVK_DIR/x32/"*.dll "$WINEPREFIX/drive_c/windows/syswow64/"
            echo "✅ Installed 32-bit DXVK files"
        fi
    else
        echo "⚠️  Warning: DXVK not found in /opt/dxvk-v*"
    fi
else
    echo "Vulkan version < 1.3 detected, skipping standard DXVK (requires Vulkan 1.3+)"
    echo "⚠️  No DXVK variant installed, games may not have DirectX to Vulkan translation"
fi

echo "✅ Wine preparation completed!"
