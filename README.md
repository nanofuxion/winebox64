# WineBox64 Gaming Edition

Docker image for playing Windows games on ARM64 VMs with gfxstream Vulkan support. This enhanced version includes DXVK-Sarek for Vulkan 1.1.305 compatibility, XinputBridge for gamepad support, and Wine 10.0 with WOW64 support.

## Features

- **Wine 10.0 with WOW64**: Reduces prefix management complexity between 32-bit and 64-bit games
- **gfxstream Vulkan Support**: Configured for Vulkan 1.1.305 and OpenGL Zink via gfxstream
- **DXVK-Sarek**: DirectX to Vulkan translation layer supporting older Vulkan versions
- **XinputBridge**: Gamepad/controller support with UDP proxy
- **Box64/Box86**: x86/x64 emulation on ARM64
- **Shared Directory Mount**: Access to `/mnt/shared` from host

## Prerequisites

- ARM64 host with gfxstream support
- Docker and Docker Compose installed
- Host must have `/usr/lib/aarch64-linux-gnu/libvulkan_gfxstream.so`
- Host must mount `/mnt/shared` directory

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up -d

# Attach to the container
docker attach winebox64-gaming
```

### Using Docker directly

```bash
# Build the image
docker build -t winebox64-gaming .

# Run the container
docker run -it --name winebox64-gaming \
  -v /mnt/shared:/mnt/shared:ro \
  -v wine_prefix:/root/.wine64 \
  -e MESA_LOADER_DRIVER_OVERRIDE=zink \
  -e VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json \
  -e MESA_VK_WSI_DEBUG=sw,linear \
  -e XWAYLAND_NO_GLAMOR=1 \
  -e LIBGL_KOPPER_DRI2=1 \
  -e DISPLAY=:0 \
  --device /dev/dri:/dev/dri \
  --privileged \
  winebox64-gaming
```

## Usage

### Basic Game Launch

```bash
# Launch a game from the shared directory
launch-game.sh /mnt/shared/games/MyGame.exe

# Launch with additional arguments
launch-game.sh /mnt/shared/games/MyGame.exe --fullscreen --no-splash
```

### Manual Wine Setup

```bash
# Initialize Wine prefix
wine64 wineboot --init
wine wineboot --init

# Install additional Windows components
winetricks vcrun2019 directx11

# Run a game manually
wine64 /mnt/shared/games/MyGame.exe
```

### Environment Setup

The container automatically sets up the gfxstream environment. You can manually run:

```bash
# Setup gfxstream environment
setup-gfxstream.sh

# Check Vulkan support
vulkaninfo

# Check OpenGL support
glxinfo | grep "OpenGL"
```

## Configuration

### gfxstream Vulkan ICD

The container includes a pre-configured Vulkan ICD file at `/usr/share/vulkan/icd.d/gfxstream_vk_icd.json`:

```json
{
    "ICD": {
        "api_version": "1.1.305",
        "library_path": "libvulkan_gfxstream.so"
    },
    "file_format_version": "1.0.0"
}
```

### Environment Variables

- `MESA_LOADER_DRIVER_OVERRIDE=zink`: Use Zink for OpenGL
- `VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/gfxstream_vk_icd.json`: Vulkan ICD path
- `MESA_VK_WSI_DEBUG=sw,linear`: Mesa Vulkan debugging
- `XWAYLAND_NO_GLAMOR=1`: Disable Wayland glamor
- `LIBGL_KOPPER_DRI2=1`: Enable Kopper DRI2
- `DISPLAY=:0`: X11 display

## Components

### DXVK-Sarek

- **Location**: `/opt/dxvk-sarek/`
- **Purpose**: DirectX to Vulkan translation supporting Vulkan 1.1.305
- **Auto-installation**: Automatically installed to Wine prefix when using `launch-game.sh`

### XinputBridge

- **Wine files**: `/opt/xinput-bridge/`
- **UDP proxy**: `/opt/udp-proxy/udp_proxy`
- **Purpose**: Gamepad/controller support
- **Auto-installation**: Automatically installed to Wine prefix when using `launch-game.sh`

### Wine 10.0

- **Location**: `~/wine/`
- **Architecture**: Both 32-bit and 64-bit support via WOW64
- **Wrappers**: `wine`, `wine64`, `wineserver`, `wineboot`, `winecfg`

## Troubleshooting

### Vulkan Issues

```bash
# Check if Vulkan is working
vulkaninfo

# Check ICD files
ls -la /usr/share/vulkan/icd.d/

# Test with a simple Vulkan app
vkcube
```

### Wine Issues

```bash
# Check Wine version
wine64 --version

# Check Wine prefix
ls -la ~/.wine64/

# Reset Wine prefix
rm -rf ~/.wine64
wine64 wineboot --init
```

### Graphics Issues

```bash
# Check OpenGL support
glxinfo | grep -E "(OpenGL|Mesa)"

# Check if Zink is being used
glxinfo | grep "OpenGL renderer"
```

### Gamepad Issues

```bash
# Check if UDP proxy is running
ps aux | grep udp_proxy

# Start UDP proxy manually
/opt/udp-proxy/udp_proxy &

# Check XinputBridge installation
ls -la ~/.wine64/drive_c/windows/system32/xinput*.dll
```

## File Structure

```
/opt/
├── dxvk-sarek/           # DXVK-Sarek files
│   ├── x64/             # 64-bit DXVK files
│   └── x32/             # 32-bit DXVK files
├── xinput-bridge/        # XinputBridge wine files
│   ├── 64/              # 64-bit XinputBridge files
│   └── 32/              # 32-bit XinputBridge files
└── udp-proxy/           # UDP proxy for XinputBridge
    └── udp_proxy        # UDP proxy binary

/usr/share/vulkan/icd.d/
└── gfxstream_vk_icd.json # gfxstream Vulkan ICD config

/usr/local/bin/
├── setup-gfxstream.sh   # Environment setup script
└── launch-game.sh       # Game launcher script

/mnt/shared/             # Host shared directory (read-only)
```

## Examples

### Running a Steam Game

```bash
# Download and install Steam
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip
unzip steamcmd.zip
wine64 steamcmd.exe +login anonymous +app_update 123456 +quit

# Launch the game
launch-game.sh ~/.wine64/drive_c/Steam/steamapps/common/MyGame/MyGame.exe
```

### Running a DirectX Game

```bash
# Install DirectX runtime
winetricks directx11

# Launch the game
launch-game.sh /mnt/shared/games/MyDirectXGame.exe
```

## Notes

- The container runs with `--privileged` for better gaming compatibility
- GPU access is provided via `/dev/dri` device mounting
- Wine prefix is persisted in a Docker volume
- Shared directory is mounted read-only for security
- All environment variables are pre-configured for gfxstream

## Support

For issues related to:
- **gfxstream**: Check host gfxstream installation and Vulkan drivers
- **Wine**: Check Wine logs with `WINEDEBUG=+all wine64 yourgame.exe`
- **DXVK**: Check DXVK logs in Wine prefix
- **XinputBridge**: Check UDP proxy logs and network connectivity