# Ebb_n_Flow_Hydro_Controller
A digital hydroponic controller based on PIC16F648A microcontroller. Code was written exclusively in ASM a decade ago.

4-Bit control of an LCD 16x2 - HD44780 using a PCF8574 I2C expander. LCD contrast is digitaly adjusted through PWM modulation.

A fully functional multi line menu to navigate through the various functions.

Bit-bang I2C communication protocol implementation.

Keeping track of time and setting alarms by controlling the RTC DS1307.

Offers a cycle timer and ten absolute timers for scheduling flood and drain cycles.

Controls two separate inputs and outputs:

Inputs are connected to the water float switches.

Outputs utilize two 12v/220v - 10A DIN rail relays, for controlling the water pumps.

I/Os are optocoupled for extra protection.

Upload HEX file using Pickit2/Pickit3 through the onboard ICSP header.

Menu layout:

![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/e2949b570f0ded50d0145d5d1af71eb2ecad39cb/Pics/menu_layout.png)

Schematic:
![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/aaa3a61dfd625b33cdeaa33ab16f7a8a368f2810/PCB/shcematic.png)

