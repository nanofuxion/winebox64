# Winebox64 - Windows Gaming on ARM64

Docker container for playing Windows games on ARM64 hosts using Box64, Wine, and gfxstream Vulkan.

## Quick Start

```bash
docker-compose up -d
docker exec -it winebox64-gaming bash
launch-game
```

## Gamepad Support

Gamepad connects from host machine via UDP network.

### Setup (one-time)
```bash
python3 -m venv venv
source venv/bin/activate
pip install pygame
```

### Usage
```bash
# Start game in container first, then on host:
./run-gamepad-client.sh 10.0.0.15
# or localhost if running locally
```

## What's Inside

- **Box64**: x86-64 emulation on ARM64
- **Wine 10.0 WoW64**: Windows compatibility layer
- **DXVK-Sarek**: DirectX to Vulkan translation (supports Vulkan 1.1.305)
- **Gfxstream**: Host Vulkan/OpenGL passthrough
- **Wine-vpad**: Network-based XInput gamepad support

## Directory Structure

- `/mnt/shared` - Mount point for game files from host
- `~/.wine64` - Wine prefix (persistent volume)
- `/opt/wine` - Wine installation

## Requirements

- ARM64 host with gfxstream support
- libvulkan_gfxstream.so on host
- Vulkan 1.1.305 or compatible
