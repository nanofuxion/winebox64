#!/bin/bash
set -euxo pipefail

export WINEPREFIX=/home/gamer/.persist/wine64

echo "🍷 Initializing Wine prefix with Hangover..."
wineboot --init

sleep 2

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip
rm -rf TestD3D.zip

echo "✅ Wine preparation completed!"
