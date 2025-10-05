#!/bin/bash
set -euxo pipefail
# NOTE: Can only run on aarch64 (since box64 can only run on aarch64)
# box64 runs wine-amd64, box86 runs wine-i386.

# Download Wine 10.0 with WOW64 support from Kron4ek's builds
echo -e "Downloading Wine 10.0 with WOW64 support . . ."
cd /tmp
wget -O wine-10.0-amd64-wow64.tar.xz "https://github.com/Kron4ek/Wine-Builds/releases/download/10.0/wine-10.0-amd64-wow64.tar.xz"

echo -e "Extracting wine . . ."
tar -xf wine-10.0-amd64-wow64.tar.xz
echo -e "Installing wine . . ."
mv wine-10.0-amd64-wow64 /opt/wine

# Clean up
rm -f wine-10.0-amd64-wow64.tar.xz

# Install winetricks
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
mv winetricks /usr/local/bin/

# Clean up
apt-get -y autoremove 
apt-get clean autoclean 
rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists