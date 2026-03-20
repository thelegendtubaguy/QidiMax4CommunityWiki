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

The first pass at the wrapper names suggested that `ClosedLoopCurrentHelper` might be mostly about state and current management, and that `CL_Interface_bitbang` might just be a transport layer to the XY controllers. Looking at the compiled modules shows more than that.

#### What symbol inspection found

Running `nm -C` against the two compiled modules exposed a large number of Cython symbol names. The most relevant ones were:

```text
closed_loop_core:
  cmd_READ_MOTOR_STATUS
  cmd_READ_CODER_ERROR
  cmd_SET_STALL_TOLERANCE
  cmd_CLOSE_TLR_ERROR
  cmd_OPEN_TLR_ERROR
  cmd_CLEAR_CODER
  cmd_COMP_CODER
  get_status
  msg_read_coder
  msg_read_coder_error
  msg_read_motor_status
  encoder_alarm
  phase_loss
  overcurrent
  high_temp_alarm
  stepper_out_of_tolerance_alarm
  reports_error_state
  No_response_from_stepper

cl_interface_core:
  msg_query_motor_status
  get_status
  cmd_RESET_MOTOR_POSITION_ERROR
  msg_reset_motor_position_error
```

That matters because it is much stronger evidence than the wrapper files alone. It shows host-visible support for:

- motor-status queries
- coder or encoder-related reads and error handling
- stall or tolerance configuration
- alarm and fault reporting
- a distinct `motor position error` state with an explicit reset command

This moves the evidence past the weaker claim of "probably just smoother FOC commutation."

#### What Python introspection found

Importing the modules inside the printer's Klipper environment exposed these Python-visible classes:

```python
from klippy.extras import closed_loop_core
from klippy.extras import cl_interface_core

dir(closed_loop_core)
# ['ClosedLoop', 'ClosedLoopCurrentHelper', ...]

dir(cl_interface_core)
# ['CL_Interface_bitbang', 'MotorFirmwareUpgradeHelper', 'PrinterCLMutexes', ...]
```

The most interesting methods on `ClosedLoopCurrentHelper` were:

```text
cmd_READ_MOTOR_STATUS
cmd_READ_CODER_ERROR
cmd_SET_STALL_TOLERANCE
cmd_SET_HOMING_MODE
cmd_SET_HOMING_STATE
cmd_SET_OPERATING_CURRENT
cmd_SET_QUERY_CYCLE
get_status
msg_read_motor_status
msg_read_coder
msg_read_coder_error
msg_set_the_stall_tolerance
```

The most interesting methods on `CL_Interface_bitbang` were:

```text
cmd_RESET_MOTOR_POSITION_ERROR
get_status
msg_query_motor_status
msg_reset_motor_position_error
register_closedloop_addr
register_closedloop_name
send_command
```

The import path also mattered. `cl_interface_core` does not import cleanly as a top-level module from `~/klipper/klippy/extras`, but it does import from the full Klipper package path:

```bash
python3 -c "from klippy.extras import cl_interface_core; print(dir(cl_interface_core))"
```

That is useful to future investigators because many quick one-liners will fail unless they run from `~/klipper` and import through `klippy.extras`.

#### What the binaries do and do not prove

The compiled-module evidence now supports these stronger technical claims:

- The Max 4 has custom host-supervised XY closed-loop support in Klipper.
- The host talks to separate addressable XY controller devices.
- The host polls motor status.
- The system exposes coder or encoder-related operations and error handling.
- The system exposes stall or tolerance handling.
- The system exposes multiple alarm states such as encoder alarm, phase loss, overcurrent, and high temperature.
- The system exposes a `motor position error` condition and a command to reset it.

That is still **not** the same as proving machine-level skipped-step recovery. The evidence currently does **not** show:

- a host-visible absolute XY position value
- a following-error value returned to the motion planner
- a code path that feeds corrected real-world XY position back into Klipper kinematics
- proof that the printer can resume correctly after a belt tooth jump, collision, or gantry displacement during a print

In other words, the binaries strongly suggest real fault and status supervision, including position- or tolerance-related error states, but they do not yet prove planner-level position correction or automatic print recovery.

### What is known so far

- The Max 4 has custom Klipper support for X/Y closed-loop hardware.
- The host appears to talk to separate addressable X/Y devices.
- The host appears to poll them periodically.
- The host appears to switch them between homing and working modes.
- The visible config does not show standard TMC-style direct driver access for X/Y.
- The compiled modules expose host-visible status, coder, tolerance, and alarm handling.
- The compiled modules expose a `motor position error` state and a reset path for it.

### What is not yet shown

The currently visible evidence does **not** show:

- host-visible encoder position that clearly maps to Klipper XY coordinates
- following-error data returned in a form that Klipper uses for planner correction
- a documented lost-step alarm path tied to print recovery logic
- a code path that feeds corrected real-world XY position back into Klipper's motion planner
- proof of print-time recovery after a belt skip, collision, or gantry displacement

### Current investigation status

The current evidence supports a stronger but still limited claim: the Max 4 has host-supervised XY closed-loop hardware with status, coder, tolerance, and fault handling, and it likely can detect at least some internal motor or controller mismatch conditions.

The current evidence still does **not** support the strongest claim that the printer can detect a real XY positional error at the machine level, correct Klipper's internal position, and recover a print automatically.

### Notes for future investigation

The next high-value step is to inspect runtime `get_status()` data from both `ClosedLoopCurrentHelper` and `CL_Interface_bitbang` during printer operation. The key question is whether those status objects contain only alarm bits and state flags, or whether they also include measured position, coder counts, following error, or commanded-vs-actual deltas.

Useful clues to look for next:

- `position`
- `error_count`
- `coder_error`
- `alarm`
- `tolerance`
- `stall`
- `state`
- any measured-versus-commanded position field

Useful commands that already worked during this investigation:

```bash
nm -C ~/klipper/klippy/extras/closed_loop_core.cpython-39-aarch64-linux-gnu.so | grep -Ei 'step|loss|error|alarm|encoder|position|follow|home|current|state|query'
nm -C ~/klipper/klippy/extras/cl_interface_core.cpython-39-aarch64-linux-gnu.so | grep -Ei 'step|loss|error|alarm|encoder|position|follow|home|current|state|query|addr|mode'

python3 -c "from klippy.extras import closed_loop_core; print(dir(closed_loop_core.ClosedLoopCurrentHelper))"
python3 -c "from klippy.extras import cl_interface_core; print(dir(cl_interface_core.CL_Interface_bitbang))"
```

Commands already tried during this investigation, but not very revealing:

```bash
python3 -c "from klippy.extras import closed_loop_core; help(closed_loop_core.ClosedLoopCurrentHelper.get_status)"
python3 -c "from klippy.extras import cl_interface_core; help(cl_interface_core.CL_Interface_bitbang.get_status)"
```

Those `help()` calls currently reveal only the method signatures:

```text
get_status(self, eventtime)
```

They do not expose return fields, docstrings, or any other useful semantics. Future work should therefore focus on runtime probing, decompilation, or tracing how Klipper consumes the returned status dictionaries or objects.
