#!/bin/sh
set -euxo pipefail

# This script creates robust wrappers for a Wine WoW64 environment on a non-x86 system (e.g., ARM64).
# It correctly directs 32-bit applications to box86 and 64-bit applications to box64.

# --- Wrapper for 32-bit Wine (wine) ---
# This command runs 32-bit Windows applications using box86.
cat << EOF > /usr/local/bin/wine
#!/bin/sh
# Set a default WINEPREFIX but allow it to be overridden by an environment variable.
export WINEPREFIX=\${WINEPREFIX:="\$HOME/.wine64"}
# Use box86 to run the 32-bit wine executable.
box86 /opt/wine/bin/wine \$@
EOF

# --- Wrapper for 64-bit Wine (wine64) ---
# This command runs 64-bit Windows applications using box64.
cat << EOF > /usr/local/bin/wine64
#!/bin/sh
export WINEPREFIX=\${WINEPREFIX:="\$HOME/.wine64"}
# Use box64 to run the 64-bit wine64 executable.
box64 /opt/wine/bin/wine64 \$@
EOF

# --- Wrappers for Core Wine Tools ---
# These tools are also executables and must be run through box64.
cat << EOF > /usr/local/bin/wineserver
#!/bin/sh
export WINEPREFIX=\${WINEPREFIX:="\$HOME/.wine64"}
box64 /opt/wine/bin/wineserver \$@
EOF

cat << EOF > /usr/local/bin/winecfg
#!/bin/sh
export WINEPREFIX=\${WINEPREFIX:="\$HOME/.wine64"}
box64 /opt/wine/bin/winecfg \$@
EOF

cat << EOF > /usr/local/bin/wineboot
#!/bin/sh
export WINEPREFIX=\${WINEPREFIX:="\$HOME/.wine64"}
box64 /opt/wine/bin/wineboot \$@
EOF

# --- Make all new wrappers executable ---
chmod +x /usr/local/bin/wine \
           /usr/local/bin/wine64 \
           /usr/local/bin/wineserver \
           /usr/local/bin/winecfg \
           /usr/local/bin/wineboot

echo "✅ Wine WoW64 wrappers were created successfully!"