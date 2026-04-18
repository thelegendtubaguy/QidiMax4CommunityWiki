# Process Hardening and Optimizations
## APT Sources
By default APT sources are configured to the University of Science and Technology of China source mirrors.  Suggested you update this to more standard mirrors for performance and less reliance on China.  You can do that by editing `/etc/apt/sources.list` to:
```
deb http://deb.debian.org/debian bullseye main contrib
deb-src http://deb.debian.org/debian bullseye main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
deb-src http://security.debian.org/debian-security bullseye-security main contrib
deb http://deb.debian.org/debian bullseye-updates main contrib
deb-src http://deb.debian.org/debian bullseye-updates main contrib
```

## Bluetooth
Easily able to disable bluetooth:
```
sudo systemctl disable --now bluetooth
```

## VPN Client
For some reason Qidi has left `xl2tpd` running.  There's no reason for it to be running and potentially presents an attack surface.  It is not configured to connect to anything, but it's there running.

To disable:
```
sudo systemctl disable --now xl2tpd
```

## Algo App
Qidi ships an AI/video service as `algo_app.service`. If you do not use the detection features, disabling it reduces background activity and removes its LAN-exposed API from the running system.

To disable:
```
sudo systemctl disable --now algo_app.service
```

To check if it is running:
```
systemctl status algo_app.service
```

To re-enable later:
```
sudo systemctl enable --now algo_app.service
```
