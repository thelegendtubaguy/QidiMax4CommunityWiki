# Making qidiclient suck less

`qidiclient` is the application that drives the touchscreen on the printer.  Its process is pinned to CPU 0 and it seems to regularly consume `50+%` of that core, even when doing "nothing".  That "nothing" is actually `qidiclient` repeatedly decoding GIF assets used for spinners in the UI.  This results in CPU and disk performance loss as that decoding is happening on repeat, with no stopping or delay.  Replacing the animated GIFs with single-frame GIFs reduced `qidiclient` CPU from roughly `55-60%` of one core to roughly `3-4%` of one core.

> [!WARNING]
> Running the script below will cause spinners in the screen's UI to no longer spin.

## Install static GIFs

SSH to the printer, then run:

```bash
curl -fsSL https://raw.githubusercontent.com/thelegendtubaguy/QidiMax4CommunityWiki/main/scripts/install_qidiclient_static_gifs.sh | sudo bash
```

The script downloads [`files/qidiclient-static-gifs.tar.gz`](../files/qidiclient-static-gifs.tar.gz) from this repository, backs up the current GIFs to `/home/qidi/QIDI_Client/access/.gif-backup-<timestamp>`, installs the replacements, and restarts `qidi-client.service`.

`sudo` may prompt for the printer password. The stock password is documented in [System Access and Information](./ssh_os.md).

Static replacement GIFs are stored in [`files/qidiclient-static-gifs`](../files/qidiclient-static-gifs/), with paths matching `/home/qidi/QIDI_Client/access` if you want to copy them yourself manually.
