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
rm TestD3D.zip

echo "🎮 Setting up xinput DLL overrides..."
if [ -f "$WINEPREFIX/drive_c/windows/system32/xinput1_1.dll" ]; then
    box64 wine64 reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v xinput1_1 /t REG_SZ /d native /f
fi
if [ -f "$WINEPREFIX/drive_c/windows/system32/xinput1_2.dll" ]; then
    box64 wine64 reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v xinput1_2 /t REG_SZ /d native /f
fi
if [ -f "$WINEPREFIX/drive_c/windows/system32/xinput1_3.dll" ]; then
    box64 wine64 reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v xinput1_3 /t REG_SZ /d native /f
fi
if [ -f "$WINEPREFIX/drive_c/windows/system32/xinput1_4.dll" ]; then
    box64 wine64 reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v xinput1_4 /t REG_SZ /d native /f
fi
if [ -f "$WINEPREFIX/drive_c/windows/system32/xinput9_1_0.dll" ]; then
    box64 wine64 reg add 'HKEY_CURRENT_USER\Software\Wine\DllOverrides' /v xinput9_1_0 /t REG_SZ /d native /f
fi

echo "✅ Wine preparation completed!"
