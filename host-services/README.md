# Host Services

This directory contains systemd service files for running components on the host system rather than inside the Docker container.

## UHID Server (XinputBridge)

The UHID server enables controller input for games running in the container.

### Installation

Run on the host system:

```bash
sudo ./install-uhid-service.sh
```

This will:
- Copy `uhid-server-arm64` to `/usr/local/bin/`
- Install the systemd service
- Enable and start the service

### Management

```bash
# Check service status
sudo systemctl status uhid-server

# View logs
sudo journalctl -u uhid-server -f

# Restart service
sudo systemctl restart uhid-server

# Stop service
sudo systemctl stop uhid-server

# Start service
sudo systemctl start uhid-server
```

### Uninstallation

```bash
sudo ./uninstall-uhid-service.sh
```

