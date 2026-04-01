# FAQ
- [Does the Max 4 toolhead hit a wall when moving away from the waste chute like the Q2?](#max4-toolhead-wall-hit-q2)
- [How do I get root access?](#how-do-i-get-root-access)
- [Is the chamber mostly air tight?](#is-the-chamber-mostly-air-tight)
- [How do I keep the polar cooler tube from rubbing the glass?](#how-do-i-keep-the-polar-cooler-tube-from-rubbing-the-glass)
- [I saw the Max 4 has closed-loop X/Y motors, can it recover from step loss?](#max4-closed-loop-step-loss)
- [Where can I find stock/vanilla Klipper configs after I messed with them?](#stock-klipper-configs)
- [Why are OTA updates not working on my new Max 4?](#new-max4-ota-updates)
- [Why don't I see my bed mesh in Fluidd?](#enable-fluidd-bed-mesh)

<a name="max4-toolhead-wall-hit-q2"></a>
## Does the Max 4 toolhead hit a wall when moving away from the waste chute like the Q2?

No, the design of the printer avoids this entirely.

![Waste Chute Parking](../assets/waste_chute_parking.jpg)

<a name="how-do-i-get-root-access"></a>
## How do I get root access?

See [this page](./ssh_os.md#root-access).

<a name="is-the-chamber-mostly-air-tight"></a>
## Is the chamber mostly air tight?

No. See [this page](./faq/chamber_air_leaks.md) for more information.

<a name="how-do-i-keep-the-polar-cooler-tube-from-rubbing-the-glass"></a>
## How do I keep the polar cooler tube from rubbing the glass?

You can use the included cable ties wrapped around the highest points on the tube as Qidi instructs, or [see this](./mods/polar_cooler_things.md#tubing-rubs-on-glass).

<a name="max4-closed-loop-step-loss"></a>
## I saw the Max 4 has closed-loop X/Y motors, can it recover from step loss?

`FOC closed-loop` on the Max 4 appears to mean feedback-based X/Y motor control for smoother, quieter, and more stable motion. The current evidence does not show printer-level detection and recovery from XY position loss such as skipped steps, belt slip, or collisions. See [this page](./faq/max4_closed_loop_step_loss.md) for more information.

<a name="new-max4-ota-updates"></a>
## Why are OTA updates not working on my new Max 4?

See [this page](./faq/initial_offline_firmware_update.md).

<a name="enable-fluidd-bed-mesh"></a>
## Why don't I see my bed mesh in Fluidd?

You need to check "Enable Full Display" in your Fluidd settings.

![Fluidd Full Display](../assets/fluidd_enable_full_display.png)

<a name="stock-klipper-configs"></a>
## I've messed with my Klipper configs and now I want to go back to stock, how do I do this?

You can reference the stock configurations at [this repository](https://github.com/thelegendtubaguy/Qidi-Max-4-Config-Files/tree/main)
