#!/bin/bash
set -euxo pipefail

# Wine preparation script for gamer user
# This script initializes Wine prefix and installs essential packages

echo "🍷 Adding Wine to PATH..."

# Add Wine binary path to bashrc
echo 'export PATH=/opt/wine/bin:$PATH' >> ~/.bashrc

# Export PATH for current context
export PATH=/opt/wine/bin:$PATH

echo "🍷 Initializing Wine prefix..."

# Run wineboot to create the prefix properly
box64 wineboot --init

# echo "📦 Installing winetricks packages..."

# # Install winetricks if not available
# if ! command -v winetricks &> /dev/null; then
#     echo "Installing winetricks..."
#     wget -O /tmp/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
#     chmod +x /tmp/winetricks
#     sudo mv /tmp/winetricks /usr/local/bin/
# fi

# # Install essential packages
# winetricks -q dotnet48 vcrun2019

wget https://github.com/user-attachments/files/22665790/TestD3D.zip
unzip TestD3D.zip

echo "✅ Wine preparation completed!"
