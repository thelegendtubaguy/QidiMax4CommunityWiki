# Max 4 Closed-Loop X/Y Motors and Step Loss

Short answer: probably not in the way most people mean.

Qidi does advertise the Max 4's XY motion system as using `FOC Closed-loop Stepper Motor`, but that does not automatically mean the printer can detect lost position and recover from it mid-print. Based on Qidi's own product pages, support material, and the shipped Klipper config, the safer assumption is that this feature is about smarter XY motor control, not proven recovery after a serious skipped step, belt tooth jump, or collision.

## What FOC means

FOC stands for **field-oriented control**. It is a motor-control method that uses rotor position feedback and current control to drive the motor phases more precisely. In plain English, that usually means:

- smoother commutation
- better torque use for a given motor and current
- quieter operation
- less vibration and better behavior at higher speed

In a system like this, the relevant parts are usually:

- the XY stepper motor itself
- some form of rotor-position feedback device, often discussed as an encoder or angle sensor
- a motor driver or control stage that uses that feedback to time phase current correctly
- the printer mainboard and host firmware, which still send motion commands

The important distinction is where the feedback loop is closed. For FOC, that loop is typically closed locally at the motor-control or driver level. The feedback is used to control motor phase current and commutation, not necessarily to publish a corrected machine position back to Klipper or the higher-level motion planner.

That is why questions about "where the shaft encoder data shows up" can be misleading. In many closed-loop motor systems, that information never appears as a host-visible XY position signal at all. It may stay inside the motor-control path and only be used to make the motor run more smoothly and efficiently.

That is useful, and it can help a printer run faster and cleaner. It does **not** by itself mean the machine knows the absolute toolhead position at all times.

## What closed-loop likely does here

The most reasonable reading is that the XY steppers use feedback for commutation and torque control, and that Klipper can supervise some operating and homing behavior through Qidi's custom closed-loop interface. In practice, that would show up as smoother motion, quieter operation, better high-speed behavior, and smarter homing behavior rather than as an obvious "recovered from a crash" feature.

## What it probably does not do

`FOC closed-loop` should not be assumed to mean recovery from:

- belt tooth jumps or belt slip
- a hard nozzle collision with the print
- a big external bump to the toolhead
- any event where the gantry's real position no longer matches the motion planner's assumed position

That kind of recovery needs more than better motor commutation or mode switching. It usually requires a system that can reliably detect a position mismatch at the machine level and then decide how to recover without ruining the print. Qidi does not appear to make that claim for the Max 4, and the config evidence seen so far does not prove it.

There is or was a vendor claiming step loss recovery for the Max 4, but that appears to be their interpretation of what "closed-loop" meant from Qidi.

## Technical details

The main answer above is still the current conclusion. The details below show why.

### What the config shows

The Max 4 does appear to expose more than plain `step/dir/enable` for X and Y.

The shipped config contains dedicated X/Y closed-loop sections:

```ini
[cl_interface]
mcu = mcu
addr = 0

[closed_loop x]
addr = 1
run_current = 1200
hold_current = 800
home_current = 700
microstep: 32
query_cycle: 5

[closed_loop y]
addr = 3
run_current = 1200
hold_current = 800
home_current = 700
microstep: 32
query_cycle: 5
```

That strongly suggests the host talks to dedicated X/Y closed-loop controllers over a vendor-specific interface. The `addr` values imply separate addressable devices, and `query_cycle` implies the host polls them periodically.

At the same time, the normal kinematics still include standard X/Y stepper definitions:

```ini
[stepper_x]
step_pin: PC14
dir_pin: !PC13
enable_pin: !PC15
microsteps: 32
rotation_distance: 39
full_steps_per_rotation: 200
```

No standard `[tmc2209 stepper_x]` or `[tmc2209 stepper_y]` blocks were found. The only visible `tmc2209` sections are for the two Z steppers.

That means X and Y are not exposed like a typical Klipper + TMC setup where `DUMP_TMC` can read driver registers directly.

### What the homing macros show

The homing macros switch X and Y between homing and working states:

```ini
SET_HOMING_STATE STEPPER=y VALUE=2
SET_HOMING_STATE STEPPER=x VALUE=2
SET_HOMING_MODE  STEPPER=y VALUE=2
SET_HOMING_MODE  STEPPER=x VALUE=2
```

That is stronger evidence for "Klipper talks to the XY closed-loop hardware" than the plain `[stepper_x]` and `[stepper_y]` blocks alone. It suggests the host can at least supervise state, current, or behavior changes for the X/Y controllers during homing.

### What the Klipper modules show

The Max 4's Klipper tree includes custom extras for the closed-loop system:

```text
closed_loop.py
cl_interface.py
closed_loop_core.cpython-39-aarch64-linux-gnu.so
cl_interface_core.cpython-39-aarch64-linux-gnu.so
```

The visible Python wrappers are minimal:

```python
from . import closed_loop_core

def load_config_prefix(config):
    return closed_loop_core.ClosedLoopCurrentHelper(config)
```

```python
from . import cl_interface_core

def load_config(config):
    return cl_interface_core.CL_Interface_bitbang(config)
```

That tells us two useful things:

- this is definitely custom Qidi functionality, not stock Klipper behavior
- most of the interesting logic lives in compiled modules, not plain Python

The class names are also suggestive. `ClosedLoopCurrentHelper` sounds more like state and current management than host-side kinematic correction. `CL_Interface_bitbang` sounds like a custom communication path to the XY closed-loop controllers.

### What is known so far

- The Max 4 has custom Klipper support for X/Y closed-loop hardware.
- The host appears to talk to separate addressable X/Y devices.
- The host appears to poll them periodically.
- The host appears to switch them between homing and working modes.
- The visible config does not show standard TMC-style direct driver access for X/Y.

### What is not yet shown

The currently visible evidence does **not** show:

- host-visible encoder position
- following-error data
- lost-step alarms
- a code path that feeds corrected real-world XY position back into Klipper's motion planner
- proof of print-time recovery after a belt skip, collision, or gantry displacement

### Current investigation status

The current evidence supports this narrower claim: the Max 4 has smart, host-supervised XY closed-loop hardware.

The current evidence does **not** yet support the stronger claim that the printer can detect a real XY positional error during a print and recover automatically.
