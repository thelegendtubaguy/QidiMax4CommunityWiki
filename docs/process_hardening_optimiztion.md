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
