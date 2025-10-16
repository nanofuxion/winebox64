# Winebox64 - Windows Gaming on ARM64

Docker container for playing Windows games on ARM64 hosts using Hangover and gfxstream Vulkan.

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

- **Hangover 10.14**: Native ARM64 Wine implementation with x86/x64 Windows support (much faster than Box64+Wine)
- **DXVK-Sarek**: DirectX to Vulkan translation (supports Vulkan 1.1.305)
- **Gfxstream**: Host Vulkan/OpenGL passthrough
- **XinputBridge**: Network-based XInput gamepad support

## Directory Structure

- `/mnt/shared` - Mount point for game files from host
- `~/.persist/wine64` - Wine prefix (persistent volume)

## Requirements

- ARM64 host with gfxstream support
- libvulkan_gfxstream.so on host
- Vulkan 1.1.305 or compatible
