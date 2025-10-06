#!/bin/bash
set -euo pipefail

# Setup gfxstream environment for Vulkan and OpenGL
echo "Setting up gfxstream environment..."

# Create weston environment file
cat << EOF > /home/gamer/weston.env
MESA_LOADER_DRIVER_OVERRIDE=zink
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
MESA_VK_WSI_DEBUG=sw,linear
XWAYLAND_NO_GLAMOR=1
EOF

# Set up environment variables
export MESA_LOADER_DRIVER_OVERRIDE=zink
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json
export MESA_VK_WSI_DEBUG=sw,linear
export XWAYLAND_NO_GLAMOR=1
export LIBGL_KOPPER_DRI2=1
export DISPLAY=:0

# Unset problematic variables
unset LIBGL_ALWAYS_SOFTWARE

echo "Environment setup complete!"
echo "MESA_LOADER_DRIVER_OVERRIDE=$MESA_LOADER_DRIVER_OVERRIDE"
echo "VK_ICD_FILENAMES=$VK_ICD_FILENAMES"
echo "DISPLAY=$DISPLAY"