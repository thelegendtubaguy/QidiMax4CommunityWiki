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

### DNS Resolution

QIDI is shipping `/etc/resolv.conf` as a static file with hardcoded public resolvers instead of a symlink to `resolvconf` output. In that state libc uses the static file directly, so DHCP DNS collected by `dhcpcd`/`resolvconf` is ignored.

Stock resolver path:

```text
glibc/nsswitch: files dns
        ↓
/etc/resolv.conf
        ↓
114.114.114.114 first, 8.8.8.8 fallback
```

The stock file also includes `options edns0 trust-ad`. `trust-ad` preserves the upstream resolver's Authenticated Data bit, which means the printer is trusting the recursive resolver's assertion.  And with `114.114.114.114` being a Chinese DNS server, this is sketchy.

To use DHCP/router DNS first, with Cloudflare and Google DNS as fallbacks:

```bash
sudo cp -a /etc/resolv.conf /etc/resolv.conf.qidi-static.backup
sudo cp -a /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.backup 2>/dev/null || true
sudo cp -a /etc/resolvconf/resolv.conf.d/tail /etc/resolvconf/resolv.conf.d/tail.backup 2>/dev/null || true

# Do not prepend DNS before DHCP-provided servers.
sudo sh -c ': > /etc/resolvconf/resolv.conf.d/head'

# Use public DNS only after DHCP-provided DNS.
sudo tee /etc/resolvconf/resolv.conf.d/tail >/dev/null <<'EOF'
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

# Regenerate resolver config and point libc at resolvconf.
sudo resolvconf -u
sudo ln -sfn /run/resolvconf/resolv.conf /etc/resolv.conf
```

Verify:

```bash
ls -l /etc/resolv.conf
cat /etc/resolv.conf
```

Expected result:

- `/etc/resolv.conf` points to `/run/resolvconf/resolv.conf`.
- DHCP-provided DNS servers appear first.
- `1.1.1.1` and `8.8.8.8` appear after DHCP DNS as fallbacks.
- `114.114.114.114` and `options edns0 trust-ad` are gone unless provided by DHCP or another `resolvconf` source.

Rollback:

```bash
sudo rm -f /etc/resolv.conf
sudo cp -a /etc/resolv.conf.qidi-static.backup /etc/resolv.conf

sudo cp -a /etc/resolvconf/resolv.conf.d/head.backup /etc/resolvconf/resolv.conf.d/head 2>/dev/null || true
sudo cp -a /etc/resolvconf/resolv.conf.d/tail.backup /etc/resolvconf/resolv.conf.d/tail 2>/dev/null || true

sudo resolvconf -u
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
