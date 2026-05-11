# Making qidiclient suck less

## Summary

`/home/qidi/QIDI_Client/bin/qidiclient` is the QIDI touchscreen application. The stock service starts it through `/home/qidi/QIDI_Client/bin/start.sh`, which pins the process to CPU 0 with `taskset -c 0`.

A live trace showed the hot thread as `UI_Thread`. The thread was repeatedly decoding LVGL GIF assets from `/home/qidi/QIDI_Client/access`, including `block_popup/loading.gif`, `filament/rfid.gif`, `network/wifi_scan.gif`, and `set_filament/refresh.gif`.

Replacing the animated GIFs with single-frame GIFs reduced observed `qidiclient` CPU from roughly `55-60%` of one Cortex-A35 core to roughly `3-4%` of one core after `qidi-client.service` restarted.

Static replacement GIFs are stored in [`files/qidiclient-static-gifs`](../files/qidiclient-static-gifs/), with paths matching `/home/qidi/QIDI_Client/access`.

## Install static GIFs

SSH to the printer, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/thelegendtubaguy/QidiMax4CommunityWiki/main/scripts/install_qidiclient_static_gifs.sh | sudo bash
```

The script downloads only [`files/qidiclient-static-gifs.tar.gz`](../files/qidiclient-static-gifs.tar.gz) from this repository, backs up the current GIFs to `/home/qidi/QIDI_Client/access/.gif-backup-<timestamp>`, installs the replacements, and restarts `qidi-client.service`.

`sudo` may prompt for the printer password. The stock password is documented in [System Access and Information](./ssh_os.md).
