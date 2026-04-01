# Internal components
### AP Board
![AP Board Location](../assets/ap_board_location.jpg)
![AP Board](../assets/ap_board.jpg)

The AP board is located in the top left of the printer and can be accessed by removing two screws on the top and bottom of the plastic trim.  You do not need to remove anything else to access it, but it is cramped inside.
* CPU: 4x ARM Cortex-A35 (aarch64), single socket, single thread per core
* Clock: 408 MHz min, 1104 MHz max
* Kernel: Linux 5.10.160 on aarch64
* RAM: 486 MiB total
* Swap: 255 MiB total, about 25 MiB in use
* Storage: 29.1G eMMC (mmcblk1), root uses about 7.7G

### Chamber Heat and Exhaust Fans
![Chamber Exhaust and Heater Fans](../assets/chamber_exhaust_heater_fan.jpg)

Fans for the chamber exhaust and the chamber heater are the same.
* Brand: [www.qx-cn.com](http://www.qx-cn.com)
* Model: QX12032B
* Power: DC 24V .5A

### Motherboard Fan
![Motherboard Fan](../assets/motherboard_fan.jpg)

* Brand: [www.qx-cn.com](http://www.qx-cn.com)
* Model: QX8025M24B
* Power: DC 24V 0.25A
* Could not locate exact match for specs, but found [document](../assets/QX8025.jpg) showing fans in the same family.
* Given same family fan only rated at .12A, this fan likely has over 100CFM

### Motherboard "Schematic"
![Motherboard Schematic](../assets/qidi_max4_mobo_schematic.png)

A previously posted version of this motherboard schematic on Qidi's wiki had the X and Y connectors flipped.  This is the latest version as of March 9th, 2026.

### Power Supply
![Power Supply](../assets/power_supply.jpg)

* Brand: [www.czchenglian.com](https://www.czchenglian.com)
* Model: CZL-150D-24E
* Input: 100-240V 3.4A Max
* Output: 24V 6.5A

### Relay Switching Board (SSR)
![Relay board](../assets/relay_board.jpg)

* H-4 V1.2.0
* Incoming power connections order (left to right):
    * Yellow (ground)
    * Black
    * Red
* Output connections to chamber heater (top to bottom):
    * Blue
    * Red
* Output connections to heated bed (left to right):
    * Black
    * Blue
    * Red
* Heated bed power wiring: 14 AWG

### Z Steppers
![Z Stepper Location](../assets/z_stepper_location.jpg)
![Z Stepper](../assets/z_stepper.jpg)

The Z axis steppers are located on the underside of the machine.
* Model: 42HD4027-98
* Brand: [www.mocotech.cn](http://www.mocotech.cn)
* Potential specs (could not locate exact model number)
    - body length: 40 mm
    - step angle: 1.8 deg
    - current/phase: 1.5 A
    - holding torque: 0.400 N.m
    - shaft: 5 mm D-shaft, 23 mm length
    - phases: 2
    - rated voltage: 3.3 V
    - wiring: coil pairs A-C and B-D
