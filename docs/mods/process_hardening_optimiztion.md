# Process Hardening and Optimizations

## Hardening

### APT Sources

By default APT sources are configured to the University of Science and Technology of China source mirrors. Suggested you update this to more standard mirrors for performance and less reliance on China. You can do that by editing `/etc/apt/sources.list` to:

```text
deb http://deb.debian.org/debian bullseye main contrib
deb-src http://deb.debian.org/debian bullseye main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
deb-src http://security.debian.org/debian-security bullseye-security main contrib
deb http://deb.debian.org/debian bullseye-updates main contrib
deb-src http://deb.debian.org/debian bullseye-updates main contrib
```

### Bluetooth

Easily able to disable bluetooth:

```bash
sudo systemctl disable --now bluetooth
```

### VPN Client

For some reason Qidi has left `xl2tpd` running. There's no reason for it to be running and potentially presents an attack surface. It is not configured to connect to anything, but it's there running.

To disable:

```bash
sudo systemctl disable --now xl2tpd
```

## Optimizations

### Algo App

Qidi ships an AI/video service as `algo_app.service`. If you do not use the detection features, disabling it reduces background activity and removes its LAN-exposed API from the running system.

For more information about how this works, see [AI Detection](../ai_detection.md).

To disable:

```bash
sudo systemctl disable --now algo_app.service
```

To check if it is running:

```bash
systemctl status algo_app.service
```

To re-enable later:

```bash
sudo systemctl enable --now algo_app.service
```

### Reduce qidiclient CPU usage

`qidiclient` can use a large amount of CPU repeatedly decoding animated GIF assets for touchscreen spinners. See [Making qidiclient suck less](./making_qidiclient_suck_less.md) to replace those animated GIFs with static GIFs.
