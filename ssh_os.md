# System Access and Information

## SSH Access
You can ssh to the machine by using the username `qidi` with a password `qiditech`.

## OS Information
```
qidi@qidi-max4:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Debian
Description:    Debian GNU/Linux 11 (bullseye)
Release:        11
Codename:       bullseye

qidi@qidi-max4:/usr/local/bin/algo_app$ cat /etc/debian_version
11.8

qidi@qidi-max4:~$ uname -a
Linux qidi-max4 5.10.160 #4 SMP PREEMPT Wed Sep 3 15:21:57 CST 2025 aarch64 GNU/Linux
```

## CPU Information
```
qidi@qidi-max4:~$ /usr/bin/cpufreq-info -c 0
cpufrequtils 008: cpufreq-info (C) Dominik Brodowski 2004-2009
Report errors and bugs to cpufreq@vger.kernel.org, please.
analyzing CPU 0:
  driver: cpufreq-dt
  CPUs which run at the same hardware frequency: 0 1 2 3
  CPUs which need to have their frequency coordinated by software: 0 1 2 3
  maximum transition latency: 290 us.
  hardware limits: 408 MHz - 1.10 GHz
  available frequency steps: 408 MHz, 600 MHz, 816 MHz, 1.01 GHz, 1.10 GHz
  available cpufreq governors: interactive, ondemand, userspace, performance
  current policy: frequency should be within 408 MHz and 1.10 GHz.
                  The governor "ondemand" may decide which speed to use
                  within this range.
  current CPU frequency is 1.01 GHz.
  cpufreq stats: 408 MHz:2.18%, 600 MHz:17.85%, 816 MHz:16.16%, 1.01 GHz:10.31%, 1.10 GHz:53.50 (38288)
  
  qidi@qidi-max4:~$ lscpu
  Architecture:                    aarch64
  CPU op-mode(s):                  32-bit, 64-bit
  Byte Order:                      Little Endian
  CPU(s):                          4
  On-line CPU(s) list:             0-3
  Thread(s) per core:              1
  Core(s) per socket:              4
  Socket(s):                       1
  Vendor ID:                       ARM
  Model:                           2
  Model name:                      Cortex-A35
  Stepping:                        r0p2
  CPU max MHz:                     1104.0000
  CPU min MHz:                     408.0000
  BogoMIPS:                        48.00
  Vulnerability Itlb multihit:     Not affected
  Vulnerability L1tf:              Not affected
  Vulnerability Mds:               Not affected
  Vulnerability Meltdown:          Not affected
  Vulnerability Mmio stale data:   Not affected
  Vulnerability Retbleed:          Not affected
  Vulnerability Spec store bypass: Not affected
  Vulnerability Spectre v1:        Mitigation; __user pointer sanitization
  Vulnerability Spectre v2:        Not affected
  Vulnerability Srbds:             Not affected
  Vulnerability Tsx async abort:   Not affected
  Flags:                           fp asimd aes pmull sha1 sha2 crc32 cpuid
  ```

## Process List
You can find the stock list of processes [here](./docs/stock_process_list.md).

## APT Sources
You can find the stock list of APT sources [here](./docs/stock_apt_sources.md).
