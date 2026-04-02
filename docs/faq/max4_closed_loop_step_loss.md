# Max 4 Closed-Loop X/Y Motors and Step Loss

Qidi advertises the Max 4's XY motion system as using `FOC closed-loop stepper motors`. The shipped config, custom Klipper modules, and runtime logs show the printer has host-visible XY closed-loop hardware, periodic status polling, coder-related values, and fault handling tied to those values. The Max 4 does **NOT** have position/step-loss correction/recovery.

On the Max 4, `FOC closed-loop` is best read as motor-level feedback and supervision for the X and Y motors.

## Reading `FOC Closed-Loop`

FOC stands for **field-oriented control**. It is a motor-control method that uses rotor-position feedback and current control to drive the motor phases more precisely. In practice, that usually means:

- smoother commutation
- quieter operation
- less vibration
- better torque use
- better behavior at higher speed

The key distinction is where the loop closes. On the Max 4, the available material is consistent with a loop that closes at the motor-controller level. The controller uses feedback to run the motor.  Klipper does not receive corrected cartesian position.

## Observed Capabilities

- the Max 4 has custom host-supervised XY closed-loop hardware
- the host talks to separate X and Y controller devices over a vendor-specific interface
- the host can poll those controllers periodically
- the host can read motor status and coder-related data
- the host can log a numeric coder value for each motor
- the host can trigger shutdown when a coder-related threshold is exceeded
- the system exposes a `motor position error` condition and a command to reset it

Runtime logs can show host-visible numeric coder output after running `COMP_CODER STEPPER=y`:

- `Stepper y coder value: -29300`
- `Transition to shutdown state: Stepper y coder value -29300 exceeds threshold 1000, please check the stepper status`

This means smarter motor drive behavior and host-visible fault supervision. It does not mean the machine is capable of correcting Klipper's cartesian XY position during a print.

## CoreXY Interpretation

The Max 4 is a CoreXY machine, so cartesian X and Y motion do not map 1:1 to individual motor motion.

An X-only cartesian move can still rotate the `stepper_y` motor. Because of that, a changed `Stepper y coder value` after mixed XY jogging is not, by itself, evidence of spontaneous Y drift or a false alarm. Motor-level coder deltas have to be interpreted through CoreXY motor mixing.

## Technical Basis

### Shipped config

The shipped config exposes more than plain `step/dir/enable` for X and Y. It contains dedicated X/Y closed-loop sections:

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

That supports three direct observations:

- the host talks to dedicated X/Y closed-loop controllers
- those controllers are separately addressable
- the host polls them on a regular interval

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

No standard `[tmc2209 stepper_x]` or `[tmc2209 stepper_y]` blocks were found. The only visible `tmc2209` sections are for the two Z steppers. That means X and Y are not exposed like a typical Klipper plus TMC setup where `DUMP_TMC` can read driver registers directly.

### Homing macros

The homing macros switch X and Y between homing and working states:

```ini
SET_HOMING_STATE STEPPER=y VALUE=2
SET_HOMING_STATE STEPPER=x VALUE=2
SET_HOMING_MODE  STEPPER=y VALUE=2
SET_HOMING_MODE  STEPPER=x VALUE=2
```

That shows Klipper can do more than send plain step pulses. It can supervise at least some X/Y closed-loop controller state during homing.

### Custom Klipper modules

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

This is custom Qidi functionality, most of which lives in compiled modules.

Symbol inspection of those compiled modules exposes names such as:

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

This likely means:

- the host can query motor status
- the system exposes coder or encoder-related commands and error handling
- the system exposes tolerance and stall handling
- the system exposes multiple alarm states
- the system exposes a distinct `motor position error` condition with an explicit reset command

Python introspection shows these classes:

```python
from klippy.extras import closed_loop_core
from klippy.extras import cl_interface_core

dir(closed_loop_core)
# ['ClosedLoop', 'ClosedLoopCurrentHelper', ...]

dir(cl_interface_core)
# ['CL_Interface_bitbang', 'MotorFirmwareUpgradeHelper', 'PrinterCLMutexes', ...]
```

The most relevant methods on `ClosedLoopCurrentHelper` are:

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

The most relevant methods on `CL_Interface_bitbang` are:

```text
cmd_RESET_MOTOR_POSITION_ERROR
get_status
msg_query_motor_status
msg_reset_motor_position_error
register_closedloop_addr
register_closedloop_name
send_command
```

### Runtime behavior

Recent runtime logs after running `COMP_CODER STEPPER=x`, `COMP_CODER STEPPER=y`, moving the head, and then running one of those commands again showed:

```text
Stepper y coder value: -29300
Transition to shutdown state: Stepper y coder value -29300 exceeds threshold 1000, please check the stepper status
cl_send oid=0 write=b'\xfa\x031.'
cl_idx_rx rx_data=b'\xfb\x031\xff\xff\xff\xff\x8d\x8cD'
```
`COMP_CODER` is a real vendor command path, the host can receive a numeric motor-level coder value, the closed-loop path is not limited to status bits alone, the firmware will force a shutdown when a coder-related threshold is exceeded

### Bus details

The X/Y closed-loop bus appears to use RS485 at `38400`, with `0xfa` request framing, `0xfb` response framing, `0x37` for motor-status queries, `0x40` for encoder-position queries, and commands such as `READ_MOTOR_CURRENT`, `READ_MOTOR_TEMP`, and `COMP_CODER`.

Live traffic shows `0xfa` request framing and `0xfb` response framing, the host logs numeric coder output, threshold-based shutdown is visible, and the `COMP_CODER`, `0x37`, and `0x40` paths fit the current runtime evidence.

## Details Still Unverified

The available material still does not establish these details:

- what fields `get_status()` returns at runtime
- the exact units, scaling, and sign conventions for the observed coder values
- how `COMP_CODER` compares commanded and measured motor position
- what threshold and hysteresis logic are used before shutdown
- what `READ_MOTOR_CURRENT` and `READ_MOTOR_TEMP` return in practice
- whether `M84` changes the X/Y controller current or only host-side state

Those unknowns affect implementation details and make it challenging to proceed further.

## Reference Commands

The observations above came from commands such as:

```bash
nm -C ~/klipper/klippy/extras/closed_loop_core.cpython-39-aarch64-linux-gnu.so | grep -Ei 'step|loss|error|alarm|encoder|position|follow|home|current|state|query'
nm -C ~/klipper/klippy/extras/cl_interface_core.cpython-39-aarch64-linux-gnu.so | grep -Ei 'step|loss|error|alarm|encoder|position|follow|home|current|state|query|addr|mode'

python3 -c "from klippy.extras import closed_loop_core; print(dir(closed_loop_core.ClosedLoopCurrentHelper))"
python3 -c "from klippy.extras import cl_interface_core; print(dir(cl_interface_core.CL_Interface_bitbang))"
```

The following probes were less revealing:

```bash
python3 -c "from klippy.extras import closed_loop_core; help(closed_loop_core.ClosedLoopCurrentHelper.get_status)"
python3 -c "from klippy.extras import cl_interface_core; help(cl_interface_core.CL_Interface_bitbang.get_status)"
```

Those `help()` calls only exposed the method signature:

```text
get_status(self, eventtime)
```

They did not expose return fields, docstrings, or other semantics.
