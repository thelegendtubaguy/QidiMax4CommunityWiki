```
qidi@qidi-max4:~$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.5  2.0 165092 10024 ?        Ss   09:57   0:06 /sbin/init
root           2  0.0  0.0      0     0 ?        S    09:57   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        I<   09:57   0:00 [rcu_gp]
root           4  0.0  0.0      0     0 ?        I<   09:57   0:00 [rcu_par_gp]
root           5  2.0  0.0      0     0 ?        I    09:57   0:26 [kworker/0:0-events]
root           8  0.0  0.0      0     0 ?        I<   09:57   0:00 [mm_percpu_wq]
root           9  0.0  0.0      0     0 ?        S    09:57   0:00 [rcu_tasks_kthre]
root          10  0.0  0.0      0     0 ?        S    09:57   0:01 [ksoftirqd/0]
root          11  0.3  0.0      0     0 ?        R    09:57   0:04 [rcu_preempt]
root          12  0.0  0.0      0     0 ?        S    09:57   0:00 [migration/0]
root          13  0.0  0.0      0     0 ?        S    09:57   0:00 [cpuhp/0]
root          14  0.0  0.0      0     0 ?        S    09:57   0:00 [cpuhp/1]
root          15  0.0  0.0      0     0 ?        S    09:57   0:00 [migration/1]
root          16  0.0  0.0      0     0 ?        S    09:57   0:00 [ksoftirqd/1]
root          19  0.0  0.0      0     0 ?        S    09:57   0:00 [cpuhp/2]
root          20  0.0  0.0      0     0 ?        S    09:57   0:00 [migration/2]
root          21  0.4  0.0      0     0 ?        S    09:57   0:06 [ksoftirqd/2]
root          24  0.0  0.0      0     0 ?        S    09:57   0:00 [cpuhp/3]
root          25  0.0  0.0      0     0 ?        S    09:57   0:00 [migration/3]
root          26  0.0  0.0      0     0 ?        S    09:57   0:00 [ksoftirqd/3]
root          29  0.0  0.0      0     0 ?        S    09:57   0:00 [kdevtmpfs]
root          30  0.5  0.0      0     0 ?        I    09:57   0:06 [kworker/2:1-pm]
root          31  0.4  0.0      0     0 ?        I    09:57   0:06 [kworker/1:1-events]
root          32  0.0  0.0      0     0 ?        I    09:57   0:00 [kworker/0:1-cgroup_destroy]
root          33  1.7  0.0      0     0 ?        I    09:57   0:21 [kworker/3:1-events]
root          34  0.0  0.0      0     0 ?        S    09:57   0:00 [oom_reaper]
root          35  0.0  0.0      0     0 ?        I<   09:57   0:00 [writeback]
root          59  0.0  0.0      0     0 ?        I<   09:57   0:00 [kblockd]
root          60  0.0  0.0      0     0 ?        S    09:57   0:00 [kconsole]
root          61  0.0  0.0      0     0 ?        I<   09:57   0:00 [devfreq_wq]
root          62  0.0  0.0      0     0 ?        S    09:57   0:00 [watchdogd]
root          63  0.0  0.0      0     0 ?        S    09:57   0:00 [cfinteractive]
root          66  0.0  0.0      0     0 ?        I<   09:57   0:00 [cfg80211]
root          67  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/23-rockchip]
root          96  0.0  0.0      0     0 ?        S    09:57   0:01 [kswapd0]
root          98  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/43-rockchip]
root          99  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/44-rockchip]
root         100  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/45-rockchip]
root         101  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/46-rockchip]
root         103  0.0  0.0      0     0 ?        I<   09:57   0:00 [stmmac_wq]
root         106  0.2  0.0      0     0 ?        I    09:57   0:03 [kworker/u8:2-events_unbound]
root         110  0.0  0.0      0     0 ?        S    09:57   0:00 [irq/47-gt911]
root         111  0.0  0.0      0     0 ?        I<   09:57   0:00 [ipv6_addrconf]
root         112  0.0  0.0      0     0 ?        S<   09:57   0:00 [krfcommd]
root         116  0.0  0.0      0     0 ?        S    09:57   0:00 [card0-crtc0]
root         122  0.0  0.0      0     0 ?        I<   09:57   0:00 [mmc_complete]
root         127  0.1  0.0      0     0 ?        I<   09:57   0:02 [kworker/3:2H-kblockd]
root         128  1.3  0.0      0     0 ?        S    09:57   0:16 [jbd2/mmcblk0p6-]
root         129  0.0  0.0      0     0 ?        I<   09:57   0:00 [ext4-rsv-conver]
root         130  0.0  0.0      0     0 ?        I<   09:57   0:00 [kworker/u9:0-uvcvideo]
root         167  1.3  2.7  49104 13576 ?        Ss   09:57   0:16 /lib/systemd/systemd-journald
root         216  0.0  0.9  19164  4876 ?        Ss   09:57   0:01 /lib/systemd/systemd-udevd
root         536  0.4  0.0      0     0 ?        I<   09:57   0:05 [kworker/2:3H-mmc_complete]
root         760  0.0  0.1   1980   500 ?        Ss   09:57   0:00 /usr/sbin/acpid
message+     785  0.3  0.8   8228  4124 ?        Ss   09:57   0:03 /usr/bin/dbus-daemon --system --address=systemd: --nofork --
root         798  0.0  0.2  10784  1048 ?        Ssl  09:57   0:00 /usr/sbin/irqbalance --foreground --policyscript=/etc/irqbal
root         806  0.2  0.3   2440  1976 ?        SLs  09:57   0:02 /usr/local/bin/klipper_mcu -r -I /tmp/klipper_host_mcu
qidi         838 17.5  8.8 424084 43908 ?        Ssl  09:57   3:41 /home/qidi/klippy-env/bin/python /home/qidi/klipper/klippy/k
qidi         855  5.8 10.4 505744 51864 ?        Ssl  09:57   1:13 /home/qidi/moonraker-env/bin/python /home/qidi/moonraker/moo
root         868 55.6  7.0 1123108 35012 ?       Ssl  09:57  11:42 /home/qidi/QIDI_Client/bin/qidiclient
root         878  0.6  0.7 220876  3696 ?        Ssl  09:57   0:08 /usr/sbin/rsyslogd -n -iNONE
root         897  0.0  1.3  30732  6712 ?        Ss   09:57   0:01 /lib/systemd/systemd-logind
root         916  0.0  0.3   2520  1696 ?        Ss   09:58   0:00 /usr/sbin/dhcpcd
root         920  0.0  0.3   4180  1896 ?        Ss   09:58   0:00 /usr/sbin/thd --triggers /etc/triggerhappy/triggers.d/ --soc
root         938  0.0  2.0 388844 10464 ?        Ssl  09:58   0:00 /usr/libexec/udisks2/udisksd
root         964  0.0  0.0   2056   120 ?        S    09:58   0:00 /bin/sh /usr/bin/usbdevice start
root         970  0.0  0.0  38396     8 ?        Sl   09:58   0:00 /usr/bin/adbd
root        1017  0.0  0.0      0     0 ?        I    09:58   0:01 [kworker/u8:5-events_unbound]
root        1031  0.0  1.3  13624  6876 ?        Ss   09:58   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1065  0.4  0.0      0     0 ?        S    09:58   0:05 [RTW_XMIT_THREAD]
root        1067  0.4  0.0      0     0 ?        S    09:58   0:06 [RTW_RECV_THREAD]
root        1069  0.4  0.0      0     0 ?        S    09:58   0:06 [RTW_CMD_THREAD]
root        1071  0.2  0.0      0     0 ?        S    09:58   0:03 [RTWHALXT]
root        1097  0.0  0.2  52512  1320 ?        SNs  09:58   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_p
www-data    1102  0.8  0.7  53188  3756 ?        SN   09:58   0:10 nginx: worker process
www-data    1103  0.0  0.7  53188  3740 ?        SN   09:58   0:00 nginx: worker process
www-data    1106  0.0  0.5  52892  2948 ?        SN   09:58   0:00 nginx: worker process
www-data    1108  0.0  0.4  52892  2148 ?        SN   09:58   0:00 nginx: worker process
root        1139  0.0  0.0   2052   104 ?        Ss   09:58   0:00 /usr/sbin/xl2tpd
root        1146  0.5  0.6   8764  3120 ?        Ss   09:58   0:06 bash /root/.set_mac.sh
root        1148  0.0  1.6  13968  8192 ?        Ss   09:58   0:00 /sbin/wpa_supplicant -c/etc/wpa_supplicant/wpa_supplicant-wl
root        1154  0.0  1.6 235568  8208 ?        Ssl  09:58   0:00 /usr/libexec/polkitd --no-debug
root        1156  0.0  0.3   7204  1904 ttyFIQ0  Ss+  09:58   0:00 /sbin/agetty -o -p -- \u --keep-baud 115200,57600,38400,9600
qidi        1182  0.0  0.7   9280  3604 ?        Ss   09:58   0:00 /bin/bash /usr/local/bin/crowsnest -c /home/qidi/printer_dat
root        1250 10.3 21.3 658960 106524 ?       SNsl 09:58   2:09 /usr/local/bin/algo_app/main
systemd+    1487  0.0  1.2  88008  6160 ?        Ssl  09:58   0:00 /lib/systemd/systemd-timesyncd
qidi        1671  0.0  0.4   9152  2340 ?        S    09:58   0:00 /bin/bash /usr/local/bin/crowsnest -c /home/qidi/printer_dat
qidi        1901  0.0  0.0   7328   460 ?        SN   09:58   0:00 xargs /home/qidi/crowsnest/bin/ustreamer/ustreamer
qidi        1902  0.0  0.4   9152  2144 ?        S    09:58   0:00 /bin/bash /usr/local/bin/crowsnest -c /home/qidi/printer_dat
qidi        1903  2.1  0.7 164728  3872 ?        SNl  09:58   0:26 /home/qidi/crowsnest/bin/ustreamer/ustreamer --host 127.0.0.
root        1918  6.4  0.0      0     0 ?        I<   09:58   1:17 [kworker/u9:1-uvcvideo]
root        3739  0.0  0.0      0     0 ?        I<   10:03   0:00 [kworker/0:1H]
root        3740  0.1  0.0      0     0 ?        I<   10:03   0:01 [kworker/1:1H-kblockd]
root        3814  0.0  0.0      0     0 ?        I<   10:03   0:00 [kworker/3:0H-kblockd]
root        4345  0.0  0.0      0     0 ?        I    10:05   0:00 [kworker/2:0-cgroup_destroy]
root        4757  0.1  1.5  15968  7684 ?        Ss   10:06   0:00 sshd: qidi [priv]
root        4764  0.0  0.0      0     0 ?        I    10:06   0:00 [kworker/1:0-cgroup_destroy]
qidi        4787  0.0  1.6  16044  8368 ?        Ss   10:06   0:00 /lib/systemd/systemd --user
qidi        4794  0.0  0.6 168868  3044 ?        S    10:06   0:00 (sd-pam)
qidi        4807  0.0  1.6 164148  8192 ?        Ssl  10:06   0:00 /usr/bin/pulseaudio --daemonize=no --log-target=journal
root        4856  0.0  1.1  12424  5620 ?        Ss   10:06   0:00 /usr/libexec/bluetooth/bluetoothd
qidi        4904  0.0  0.8  15968  4452 ?        R    10:06   0:00 sshd: qidi@pts/2
qidi        4907  0.0  0.7   9028  3600 pts/2    Ss   10:06   0:00 -bash
root        5621  0.2  0.0      0     0 ?        I    10:08   0:01 [kworker/u8:0-events_unbound]
root        5817  1.2  0.0      0     0 ?        I    10:08   0:07 [kworker/3:0-events]
root        5821  0.0  0.0      0     0 ?        I<   10:08   0:00 [kworker/1:0H-kblockd]
root        5874  0.0  0.0      0     0 ?        I<   10:09   0:00 [kworker/2:1H-mmc_complete]
root        5878  0.0  0.0      0     0 ?        I<   10:09   0:00 [kworker/0:2H-kblockd]
root        5879  0.1  0.0      0     0 ?        I<   10:09   0:00 [kworker/3:1H-kblockd]
root        7827  1.7  0.0      0     0 ?        D    10:14   0:04 [kworker/3:2+events]
root        7851  0.0  0.0      0     0 ?        I<   10:14   0:00 [kworker/0:0H-kblockd]
root        7852  0.0  0.0      0     0 ?        I<   10:14   0:00 [kworker/1:2H]
root        7880  0.5  0.0      0     0 ?        I<   10:14   0:01 [kworker/2:0H-mmc_complete]
root        8088  0.0  0.0      0     0 ?        I    10:14   0:00 [kworker/0:2]
root        8310  0.0  0.0      0     0 ?        I    10:15   0:00 [kworker/1:2-events]
root        8523  0.0  0.0      0     0 ?        I    10:16   0:00 [kworker/2:2-events]
qidi        8833  0.0  0.0   7032   448 ?        S    10:17   0:00 sleep 120
root        9389  0.2  0.6   8896  3168 ?        Ss   10:18   0:00 bash /home/qidi/QIDI_Client/bin/tuning.sh start
root        9530  0.0  0.0   7032   484 ?        S    10:19   0:00 sleep 1
root        9564  0.0  0.2   8896  1360 ?        S    10:19   0:00 bash /home/qidi/QIDI_Client/bin/tuning.sh start
root        9565 12.0  0.5  11516  2868 ?        R    10:19   0:00 ps -eLf
root        9566  0.0  0.1   8112   668 ?        S    10:19   0:00 grep nginx
root        9567  0.0  0.1   8112   644 ?        S    10:19   0:00 grep -v grep
root        9568  0.0  0.1   6396   536 ?        S    10:19   0:00 awk {print $4}
qidi        9569  0.0  0.5  11516  2940 pts/2    R+   10:19   0:00 ps aux
```
