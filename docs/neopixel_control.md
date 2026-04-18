# NeoPixel Control

The Max 4 ships with a Qidi-modified fork of Klipper's upstream `neopixel.py` module for the RGB light under the heated bed. On stock firmware, that RGB strip is also tied into Qidi's touchscreen app (`qidiclient`), which controls the automatic effects.

That automatic control includes:

- The idle breathing effect.
- The print progress bar that fills white from left to right.
- Other state-based effects such as print start and pause.

## Disable the automatic modes

If you want manual control, first disable the touchscreen-controlled status light. Otherwise the Qidi Client screen app may overwrite whatever you set:

1. On the printer screen, open `Settings`.
2. Turn off `Status Indicator Light`.

With that disabled, the Qidi Client app should stop taking over the RGB strip under the bed, and your own Klipper commands will stick.

## Can I control it through G-code?

Yes. All of the commands on this page are normal Klipper G-code commands.

You can use them from:

- The Fluidd console.
- A saved macro.
- Slicer start G-code.
- Slicer end G-code.
- Any other G-code file sent to the printer.

For example, this is valid G-code you can issue directly in the console:

```gcode
NEOPIXEL_ENABLE ENABLE=0
NEOPIXEL_MODE M=4 PERIOD=3000 TICK=20
```

And this could go in slicer end G-code to return to a breathing effect after a print:

```gcode
NEOPIXEL_ENABLE ENABLE=0
NEOPIXEL_MODE M=2 RED=0 GREEN=80 BLUE=255 PERIOD=4000 TICK=20
```

You can also put these commands inside your own Klipper macros.

## What is available

The stock Max 4 config exposes a `[neopixel RGB]` object and Qidi's Klipper module adds these commands:

- `SET_LED`
- `NEOPIXEL_ENABLE`
- `NEOPIXEL_BREATH_ON`
- `NEOPIXEL_BREATH_OFF`
- `NEOPIXEL_MODE`

In stock config, the NeoPixel object name is `RGB`, so solid colors use `LED=RGB`.

## Basic manual control

Set to solid red:

```gcode
SET_LED LED=RGB RED=1 GREEN=0 BLUE=0
```

Set to solid green:

```gcode
SET_LED LED=RGB RED=0 GREEN=1 BLUE=0
```

Set to solid blue:

```gcode
SET_LED LED=RGB RED=0 GREEN=0 BLUE=1
```

Set to solid white:

```gcode
SET_LED LED=RGB RED=1 GREEN=1 BLUE=1
```

More solid color examples:

```gcode
SET_LED LED=RGB RED=1 GREEN=0.5 BLUE=0
SET_LED LED=RGB RED=0.4 GREEN=0 BLUE=1
```

Turn the strip off:

```gcode
SET_LED LED=RGB RED=0 GREEN=0 BLUE=0
```

Set only one pixel:

```gcode
SET_LED LED=RGB INDEX=1 RED=1 GREEN=1 BLUE=1
```

Set the first five pixels red:

```gcode
SET_LED LED=RGB INDEX=1 RED=1 GREEN=0 BLUE=0
SET_LED LED=RGB INDEX=2 RED=1 GREEN=0 BLUE=0
SET_LED LED=RGB INDEX=3 RED=1 GREEN=0 BLUE=0
SET_LED LED=RGB INDEX=4 RED=1 GREEN=0 BLUE=0
SET_LED LED=RGB INDEX=5 RED=1 GREEN=0 BLUE=0
```

## Built-in effect modes

Qidi's custom module exposes these `NEOPIXEL_MODE` presets:

| Mode | Command | Effect |
| --- | --- | --- |
| `0` | `NEOPIXEL_MODE M=0` | Off |
| `1` | `NEOPIXEL_MODE M=1` | Steady on |
| `2` | `NEOPIXEL_MODE M=2` | Breathing |
| `3` | `NEOPIXEL_MODE M=3` | Flowing effect |
| `4` | `NEOPIXEL_MODE M=4` | Rainbow |
| `5` | `NEOPIXEL_MODE M=5` | Hazard flash |
| `6` | `NEOPIXEL_MODE M=6` | Comet |
| `7` | `NEOPIXEL_MODE M=7` | Center spread / converge |

## Customizing the built-in modes

`NEOPIXEL_MODE` accepts these extra parameters:

- `RED`
- `GREEN`
- `BLUE`
- `WHITE`
- `PERIOD`
- `TICK`
- `COUNT`
- `START`
- `DIR`

What they do:

- `RED`, `GREEN`, `BLUE`, `WHITE`: override the mode color.
- `PERIOD`: total animation time. Lower is faster. Higher is slower.
- `TICK`: update interval in milliseconds.
- `COUNT`: number of active LEDs.
- `START`: starting LED index for the effect.
- `DIR`: direction. Useful for reversing some animations.

### Rainbow examples

Default rainbow:

```gcode
NEOPIXEL_MODE M=4
```

Faster rainbow:

```gcode
NEOPIXEL_MODE M=4 PERIOD=3000 TICK=20
```

Slower rainbow:

```gcode
NEOPIXEL_MODE M=4 PERIOD=10000 TICK=40
```

Rainbow on only half the strip:

```gcode
NEOPIXEL_MODE M=4 COUNT=12 START=0
```

## Comet examples

Default comet:

```gcode
NEOPIXEL_MODE M=6
```

Faster comet:

```gcode
NEOPIXEL_MODE M=6 PERIOD=700 TICK=15
```

Slower comet:

```gcode
NEOPIXEL_MODE M=6 PERIOD=3000 TICK=50
```

Green comet:

```gcode
NEOPIXEL_MODE M=6 RED=0 GREEN=255 BLUE=0
```

Purple comet:

```gcode
NEOPIXEL_MODE M=6 RED=180 GREEN=0 BLUE=255
```

Reverse comet direction:

```gcode
NEOPIXEL_MODE M=6 DIR=0
NEOPIXEL_MODE M=6 DIR=1
```

## Flow examples

Default flowing effect:

```gcode
NEOPIXEL_MODE M=3
```

Faster flow:

```gcode
NEOPIXEL_MODE M=3 PERIOD=1200 TICK=15
```

Slower flow:

```gcode
NEOPIXEL_MODE M=3 PERIOD=5000 TICK=40
```

Blue flow:

```gcode
NEOPIXEL_MODE M=3 RED=0 GREEN=80 BLUE=255
```

Reverse the flow direction:

```gcode
NEOPIXEL_MODE M=3 DIR=0
NEOPIXEL_MODE M=3 DIR=1
```

## Center spread / converge examples

Default center effect:

```gcode
NEOPIXEL_MODE M=7
```

Faster center effect:

```gcode
NEOPIXEL_MODE M=7 PERIOD=1200 TICK=20
```

Slower center effect:

```gcode
NEOPIXEL_MODE M=7 PERIOD=5000 TICK=50
```

Red center effect:

```gcode
NEOPIXEL_MODE M=7 RED=255 GREEN=0 BLUE=0
```

Try both directions to switch between spread and converge:

```gcode
NEOPIXEL_MODE M=7 DIR=0
NEOPIXEL_MODE M=7 DIR=1
```

## Breathing examples

Default breathing effect:

```gcode
NEOPIXEL_MODE M=2
```

Blue breathing:

```gcode
NEOPIXEL_MODE M=2 RED=0 GREEN=80 BLUE=255
```

Slower breathing:

```gcode
NEOPIXEL_MODE M=2 PERIOD=8000 TICK=30
```

Faster breathing:

```gcode
NEOPIXEL_MODE M=2 PERIOD=1500 TICK=10
```

You can also use the dedicated breathing commands:

```gcode
NEOPIXEL_BREATH_ON R=0 G=255 B=255 P=2000 T=20
NEOPIXEL_BREATH_OFF
```

## Automatic mode toggle

Qidi's custom module also exposes an automatic mode switch:

```gcode
NEOPIXEL_ENABLE ENABLE=0
```

That disables the state-driven NeoPixel logic in Klipper.

To turn it back on:

```gcode
NEOPIXEL_ENABLE ENABLE=1
```

## Notes

- If your manual commands do not seem to stick, check the touchscreen first and make sure `Status Indicator Light` is off.
- `SET_LED` uses `0.0` to `1.0` values for colors.
- `NEOPIXEL_MODE` uses `0` to `255` values for `RED`, `GREEN`, `BLUE`, and `WHITE`.
- The stock Max 4 config uses `chain_count: 25`, which corresponds to 25 controllable pixels or segments on the under-bed RGB strip.
- Some direction and partial-strip behaviors may need a little experimentation because Qidi's module is custom.
