# Fan Assignments

This page lists the current Qidi Max 4 fan mapping.

## `M106` mapped outputs

| Fan Index | Command | Fan Name | Location / Function | Notes |
| --- | --- | --- | --- | --- |
| `P0` | `M106 S255` | `cooling_fan` | Primary part-cooling fan | Default target when no `P` is given. `M107` only turns this fan off. |
| `P2` | `M106 P2 S255` | `auxiliary_cooling_fan` + `auxiliary_cooling_fan2` | Auxiliary part-cooling fans | One command drives both aux fans together at the same speed. |
| `P3` | `M106 P3 S25` | `chamber_circulation_fan` | Chamber airflow / cooldown / exhaust | The config object is named `chamber_circulation_fan`, but this is the chamber exhaust fan. |
| `P4` | `M106 P4 S255` | `Polar_cooler` | Polar cooler output | Not a `fan_generic`; it is an `output_pin`. Any non-zero `S` turns it on. |

## Direct commands

You can also control these fans directly, like this to turn them on:

* `SET_FAN_SPEED FAN=cooling_fan SPEED=1`
* `SET_FAN_SPEED FAN=auxiliary_cooling_fan SPEED=1`
* `SET_FAN_SPEED FAN=auxiliary_cooling_fan2 SPEED=1`
* `SET_FAN_SPEED FAN=chamber_circulation_fan SPEED=1`
* `SET_PIN PIN=Polar_cooler VALUE=1`

And this to turn them off:
* `SET_FAN_SPEED FAN=cooling_fan SPEED=0`
* `SET_FAN_SPEED FAN=auxiliary_cooling_fan SPEED=0`
* `SET_FAN_SPEED FAN=auxiliary_cooling_fan2 SPEED=0`
* `SET_FAN_SPEED FAN=chamber_circulation_fan SPEED=0`
* `SET_PIN PIN=Polar_cooler VALUE=0`


## Not controllable fans
These fans seem to not be controllable via the console.  If this is wrong, open a PR!

| Fan Name | Location / Function | Notes |
| --- | --- | --- |
| `hotend_fan` | Hotend heatsink fan | Defined as `[heater_fan hotend_fan]`, tied to `extruder`, with `heater_temp: 50.0`, so it comes on automatically. |
| `chamber_fan` | Chamber fan | Defined as `[controller_fan chamber_fan]`; automatic, tied to the chamber heater potentially. |
| `board_fan` | Electronics / board cooling fan | Defined as `[controller_fan board_fan]`; hardcoded to 60% by default, 90% in the Qidi Optimized Configs repo |
