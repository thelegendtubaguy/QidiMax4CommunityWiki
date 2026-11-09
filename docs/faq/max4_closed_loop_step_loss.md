# Max 4 Closed-Loop X/Y Motors and Step Loss

Qidi advertises the Max 4's XY motion system as using `FOC closed-loop stepper motors`. Each X and Y motor has its own driver board with an encoder, and that driver does run field-oriented control. But the loop closes inside the driver, not in Klipper. A motor that slips stays behind and reports how far behind it is, and stock QIDI software never asks. **Stock firmware does not detect or recover from XY step loss**, though both are possible in principle.

Everything here applies to QIDI firmware `01.01.07.01`, with mainboard MCU `02.01.01.12` and closed-loop driver `03.01.10.15`. It comes from the decompiled driver and mainboard firmware, QIDI's Klipper modules, and tests on a Max 4.

## Summary

- **FOC is real and always on.** The driver measures both motor phase currents and steers the current vector from the encoder angle. QIDI's normal mode already does this; there is no FOC mode to switch on.
- **Slips are permanent.** A slipping motor falls behind by whole step cycles (4 full steps, 0.78 mm of belt each) and stays there. The driver doesn't move the motor back.
- **The driver knows, Klipper doesn't.** The driver keeps an exact position error. QIDI's software never reads it, so a slip shifts the rest of the print with no alarm.
- **Fast diagonals can slip.** Klipper limits toolhead speed, not motor speed. On a CoreXY a diagonal turns one motor about 1.41 times as fast as the toolhead, and back-and-forth diagonals at 800 mm/s made the X motor slip on a test printer.
- **Detection is possible.** [Valve Oil](https://github.com/thelegendtubaguy/Valve-Oil) adds an optional [step-loss monitor](https://github.com/thelegendtubaguy/Valve-Oil/blob/main/docs/tools.md#xy-step-loss-monitor). It reads the position error and pauses the print when a motor slips.
- **Recovery is theoretically possible.** A slip is a whole number of step cycles, and the driver reports exactly how many. So Klipper's position could be shifted by that amount and the print continued, without re-homing. The moves already queued before the slip is noticed still print out of place. Valve Oil's development branch is trying this.

## How the driver runs the motor

The driver is an STM32F3-class board. It reads step/dir pulses from the mainboard, like any stepper driver, plus commands over an RS-485 bus.

Each control tick, the driver does the following.

1. Works out the commanded motor angle from the step pulses it has received, and the measured angle from the encoder.
2. Picks the field angle, normally the measured angle plus a correction based on the position error.
3. Reads both phase currents from two ADCs, averaging 4 samples each.
4. Regulates each phase's current toward that angle and sets the PWM duty for both H-bridges.

That is encoder-commutated current control, the same thing MKS sells as FOC on its SERVO42D/57D drivers.

The target current isn't fixed at `run_current`. The driver scales it between a minimum and `run_current` as it runs.

The correction toward the commanded angle is limited to about a quarter of an electrical cycle. So the driver pushes the motor toward the nearest point where the commanded and measured angles line up. It doesn't unwind whole cycles it has already lost.

### Motor and encoder numbers

| Value | Number |
|---|---|
| Motor | 1.8°, 50 pole pairs |
| Encoder position (`0x31`) | 16384 counts per motor revolution, about 420 counts per mm of belt with `rotation_distance: 39` |
| Position error (`0x39`) | 51200 counts per revolution. 1024 counts is one electrical cycle, which is 4 full steps or 0.78 mm of belt. |

## Work modes

Driver command `0x82` selects one of six work modes. The mode is saved in the driver's flash, and changing it reboots the driver.

| Mode | Motion input | Loop | Notes |
|---|---|---|---|
| 0 | step/dir | open | Plain stepper, no encoder correction |
| 1 | step/dir | closed | **What the Max 4 runs** |
| 2 | step/dir | open | Extra alignment flag set |
| 3 | step/dir | closed | Extra alignment flag set; QIDI calls this "enforce mode" |
| 4 | serial commands | closed | |
| 5 | serial commands | closed | Extra alignment flag set |

- **What QIDI uses.** QIDI's `closed_loop.so` has `EXIT_ENFORCE_MODE` (mode 1) and `ENTER_ENFORCE_MODE` (mode 3). The stock homing macro runs `EXIT_ENFORCE_MODE` for X and Y at the start of every home, and nothing stock ever runs `ENTER_ENFORCE_MODE`. So the Max 4 always runs in mode 1. These two commands are the only `0x82` traffic in `klippy.log`.
- **The extra flag isn't an FOC switch.** Modes 1 and 3 use the same current control. The flag changes one threshold, which lets an encoder-alignment/search routine run further than it otherwise can.
- **Serial modes 4 and 5 can't work with Klipper.** In those modes the driver ignores step pulses and takes its motion from bus commands. Klipper plans motion as precisely timed step pulses, and this bus is a shared 38400-baud link where each command takes milliseconds.

## Step loss

**What a slip looks like.** On a test printer, the X axis was jogged into an obstacle. Within about 0.12 s of the blocked move, the position error jumped by whole electrical cycles, +14.03 on the X motor and +21.00 on the Y motor. The error then stayed there. That matched about 13.7 mm of X lost.

QIDI's software noticed nothing. The status query (`0x37`) kept reporting normal, nothing was logged, and Klipper didn't shut down.

**Normal motion isn't a slip.** During moves the error swings a little (about ±45 counts at 10 mm/s, up to about 140 counts at 100–300 mm/s) and returns exactly to its resting value afterwards.

**After homing.** Homing leaves a resting error of roughly `1024 × k` counts, where `k` is a small whole number that changes from one home to the next. Stall homing pushes the carriage against the frame while Klipper keeps stepping, and the motor settles a whole number of cycles off. Across five homes, the encoder position at the homed point varied by about 0.3 mm (X) and 0.9 mm (Y) of cartesian motion. That is the repeatability of stall homing.

**`RESET_MOTOR_POSITION_ERROR`.** This is a QIDI command that broadcasts `0x57` to both drivers. It redefines each driver's commanded position to match the encoder, so the error drops to under one microstep.

- **It doesn't move the motor**, and it doesn't change Klipper's position. It only clears the record of a slip.
- **It briefly cuts motor current to zero.** The cut lasts at least 30 ms, so only send it while the axis is at rest.

**CoreXY speed limit.** Klipper's `max_velocity` limits the toolhead. On a pure diagonal one motor turns 1.41 times as fast. At QIDI's 800 mm/s limit, that motor's belt runs at about 1130 mm/s. On the test printer, back-and-forth diagonals at 800 mm/s and 30000 mm/s² made the X motor slip by about 77 step cycles. At 500 mm/s nothing slipped.

## What stock QIDI software checks

| Check | What it does |
|---|---|
| Status poll | Every `query_cycle` seconds (10 in the stock config), sends `0x37` (status) and `0x40` (version) to each motor. |
| No reply | Three missed replies log a `No response` warning and mark the motor `not connect`. Klipper does **not** shut down, and one good reply clears it. |
| Status alarms | Overcurrent (`2`), phase loss (`3`), and overvoltage (`4`) shut Klipper down. The driver also has stall-trip (`6`) and over-temperature (`8`) codes. |
| `COMP_CODER` | Reads the encoder position (`0x31`) and shuts Klipper down if it moved more than `1000` counts (about 2.4 mm of belt) since the last read. It compares two encoder readings, not commanded vs. measured position, so any normal move between reads trips it. |

QIDI never reads the position error (`0x39`), so stock firmware can't see a slip.

**Driver stall trip.** The driver has its own stall trip. When it's enabled (`0x88`), it cuts the motor output if the position error reaches the stall tolerance (`0x89`, in full steps). QIDI sends `0x88` at startup. In the forced-slip test above, the trip didn't fire.

## Bus and protocol

### Wiring and framing

- **Physical bus.** The mainboard (STM32F407) runs a hardware UART (UART5) at 38400 baud, 8N1, with RS-485 direction control on PB13. X is address `1` and Y is address `3`. Address `0` is broadcast.
- **Requests.** `FA addr func data… sum`, where `sum` is the low byte of the sum of all preceding bytes.
- **Replies.** `FB addr func data… sum`. Broadcast and group-addressed frames get no reply.
- **Klipper side.** Klipper sends frames with `cl_send` and receives replies as `cl_idx_rx`. QIDI's modules allow one command in flight at a time, with a 0.5 s timeout.

### Mainboard reply delay

The stock mainboard firmware knows the reply lengths of only `0x37` and `0x40`, which arrive in about 6–7 ms. Every other reply, including position error, encoder position, temperature, and each write's acknowledgement, waits for 50 ms of bus silence and takes about 60–70 ms. The driver itself answers within about 1 ms.

Valve Oil includes an optional [mainboard firmware fix](https://github.com/thelegendtubaguy/Valve-Oil/blob/main/docs/firmware.md#mainboard-closed-loop-reply-fix) that brings those replies down to 7–8 ms.

### Function codes

Reply length is the whole frame.

| Code | Meaning | Reply bytes |
|---|---|---|
| `0x00 <code>` | Read the stored value of setting `<code>` (QIDI's `READ_MOTOR_CURRENT` sends `00 83`) | varies |
| `0x31` | Encoder position, signed 48-bit, relative to the last `0x92` zero | 10 |
| `0x33` | Step pulses received, relative to the last `0x92` zero | 8 |
| `0x37` | Status (`1` = normal) | 5 |
| `0x39` | Position error, signed 32-bit, 51200 per revolution | 8 |
| `0x3b` | Temperature, as a raw 12-bit thermistor count that rises with heat (see [Motor temperature](#motor-temperature)) | 6 |
| `0x40` | Firmware and hardware version | 8 |
| `0x47` / `0x48` | All settings / all status | 38 / 24 |
| `0x51` | Homing trigger thresholds (`sval`, `eval`) | 5 |
| `0x55` | `1` switches to homing current, `2` back to run current | 5 |
| `0x56` | `1` starts stall homing, `2` stops it | 5 |
| `0x57` | Reset position error (see [Step loss](#step-loss)) | 5, none on broadcast |
| `0x82` | Work mode (see [Work modes](#work-modes)) | 5 |
| `0x83` | Run current, mA (capped at 4000 or 5200 depending on board) | 5 |
| `0x84` | Microsteps | 5 |
| `0x88` | Stall-trip enable | 5 |
| `0x89` | Stall tolerance | 5 |
| `0x92` | Zero the `0x31`/`0x33` readouts (no motion, no effect on `0x39`) | 5 |
| `0x93` | Homing current, mA | 5 |

**Commands to avoid.** These write flash, reboot the driver, or lock it up.

| Code | What it does |
|---|---|
| `0x3f` | Factory reset, which erases the driver's settings |
| `0x41` | Reboots the driver. QIDI sends it at Klipper connect. |
| `0x50` | Data `1` rewrites the boot-flag page and reboots. Data `2` makes the driver ignore everything except `0x50`. |
| `0x61` | Reboots into the bootloader |
| `0x8a` | Permanently changes the driver's baud rate, so the mainboard can't reach it at 38400 any more |
| `0xe1` | Factory test loop. Disables the debug pins and blocks until `0xe8` arrives. |

### QIDI G-code commands

Each command takes `STEPPER=x` or `STEPPER=y` and sends one frame to that motor.

| Command | Sends |
|---|---|
| `READ_MOTOR_STATUS` | `0x37` |
| `READ_MOTOR_VERSION` | `0x40` |
| `READ_CODER_ERROR` | `0x39` |
| `READ_MOTOR_TEMP` | `0x3b` |
| `READ_MOTOR_CURRENT` | `0x00 0x83` |
| `COMP_CODER` | `0x31` |
| `CLEAR_CODER` | `0x92` |
| `OPEN_TLR_ERROR` / `CLOSE_TLR_ERROR` | `0x88` with `1` / `0` |
| `SET_STALL_TOLERANCE` | `0x89` |
| `SET_OPERATING_CURRENT` | `0x83` |
| `SET_MICROSTEPPING` | `0x84` |
| `SET_HOMING_CURRENT` | `0x93` |
| `SET_HOMING_STATE` | `0x55` |
| `SET_HOMING_MODE` | `0x56` |
| `ENTER_ENFORCE_MODE` / `EXIT_ENFORCE_MODE` | `0x82` with `3` / `1` |
| `SET_RESET_MOTOR` | `0x41` |
| `RESET_MOTOR_POSITION_ERROR` | `0x57` broadcast to both motors (takes no `STEPPER=`) |

Most replies show up in `klippy.log` only as markers such as `$0x39`. `READ_MOTOR_TEMP` also logs the value, as `Stepper x motor temp value: 2605`.

## Klipper modules

Firmware `01.01.07.01` ships the closed-loop code as compiled Cython modules in `~/klipper/klippy/extras/`.

```text
closed_loop.so     # [closed_loop x] / [closed_loop y]: per-motor commands, status polling, alarms
cl_interface.so    # [cl_interface]: shared bus, send queue, firmware upgrades
```

Older firmware shipped thin `closed_loop.py` and `cl_interface.py` wrappers around `closed_loop_core` and `cl_interface_core` modules.

This is the stock config.

```ini
[cl_interface]
mcu = mcu
addr = 0

[closed_loop x]
addr:1
run_current:1500
hold_current:800
home_current:700
microstep:32
query_cycle:10
homing_trigger_sval:400
homing_trigger_eval:4
trigger_current:400
trigger_time:2
trigger_speed:50

[closed_loop y]
addr = 3
# same values as X
```

`[stepper_x]` and `[stepper_y]` remain ordinary step/dir steppers, and there are no `[tmc2209 stepper_x]`/`[tmc2209 stepper_y]` sections, so `DUMP_TMC` can't read X or Y.

## Homing

QIDI homes X and Y by stall detection inside the driver.

1. `SET_HOMING_STATE VALUE=1` (`0x55`) switches to the homing current.
2. `SET_HOMING_MODE VALUE=1` (`0x56`) starts the driver's stall watch.
3. When the driver detects the stall (thresholds `homing_trigger_sval` and `homing_trigger_eval`, sent with `0x51`), the driver pulses its endstop output for 20 ms, and Klipper sees the endstop trigger.
4. `VALUE=2` on both commands puts the run current and normal mode back.

## CoreXY interpretation

The Max 4 is a CoreXY machine, so cartesian X and Y moves don't map 1:1 to the motors named `stepper_x` and `stepper_y`. An X-only move turns both motors. On the test printer, X+20 mm moved both motors' encoders by −8400 counts, and Y+20 mm moved them by −8400 and +8400. A changed encoder value or position error on one motor has to be read through that mixing; it doesn't mean that cartesian axis moved.

## Motor temperature

Each driver has a thermistor and reports it with `0x3b` (`READ_MOTOR_TEMP`). The value is a raw 12-bit ADC count, not degrees, and it rises as the driver heats up. A `0` means the driver has no sensor fitted.

The driver's own over-temperature table, and QIDI's warnings in `klippy.log`, use these counts.

| °C | Count |
|---|---|
| 60 | 3104 |
| 70 | 3360 |
| 80 | 3552 |
| 90 | 3696 |
| 100 | 3776 |
| 110 | 3872 |
| 120 | 3936 |

A cold, idle Max 4 in a 26 °C chamber reads 2600–2700. That doesn't fit any standard thermistor curve through the table above, so counts below 3104 can't be converted to °C yet.

## Open questions

- the control loop's rate and gains
- what the extra alignment flag in modes 2, 3 and 5 is for
- whether mode 3 behaves any differently from mode 1 on the printer
- which `0x88` stall-trip setting QIDI sends at startup
- the °C curve below 60 °C
