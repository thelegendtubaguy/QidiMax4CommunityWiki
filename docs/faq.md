# FAQ
- [Does the Max 4 toolhead hit a wall when moving away from the waste chute like the Q2?](#max4-toolhead-wall-hit-q2)
- [How do I get root access?](#how-do-i-get-root-access)
- [How do I keep the polar cooler tube from rubbing the glass?](#how-do-i-keep-the-polar-cooler-tube-from-rubbing-the-glass)
- [Where can I find stock/vanilla Klipper configs after I messed with them?](#stock-klipper-configs)
- [Why are OTA updates not working on my new Max 4?](#new-max4-ota-updates)
- [Why don't I see my bed mesh in Fluidd?](#enable-fluidd-bed-mesh)

<a name="max4-toolhead-wall-hit-q2"></a>
## Does the Max 4 toolhead hit a wall when moving away from the waste chute like the Q2?

No, the design of the printer avoids this entirely.

![Waste Chute Parking](/assets/waste_chute_parking.jpg)

<a name="how-do-i-get-root-access"></a>
## How do I get root access?

See [this page](/docs/ssh_os.md#root-access).

<a name="how-do-i-keep-the-polar-cooler-tube-from-rubbing-the-glass"></a>
## How do I keep the polar cooler tube from rubbing the glass?

You can use the included cable ties wrapped around the highest points on the tube as Qidi instructs, or [see this](/mods/polar_cooler_things.md#tubing-rubs-on-glass).

<a name="new-max4-ota-updates"></a>
## Why are OTA updates not working on my new Max 4?

See [this page](./faq/initial_offline_firmware_update.md).

<a name="enable-fluidd-bed-mesh"></a>
## Why don't I see my bed mesh in Fluidd?

You need to check "Enable Full Display" in your Fluidd settings.

![Fluidd Full Display](/assets/fluidd_enable_full_display.png)

<a name="stock-klipper-configs"></a>
## I've messed with my Klipper configs and now I want to go back to stock, how do I do this?

You can reference the stock configurations at [this repository](https://github.com/thelegendtubaguy/Qidi-Max-4-Config-Files/tree/main)
