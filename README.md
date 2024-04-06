# Ebb & Flow Hydroponic Controller
## A digital hydroponic controller based on PIC16F648A microcontroller clocked @ 4 Mhz.

Code was written exclusively in ASM a decade ago, making it a legacy project at the early beginning. Code is no longer maintained.

* Controls an LCD 16x2 - HD44780 through a PCF8574 I2C expander. LCD contrast is digitaly adjusted through PWM modulation.

* Offers a fully functional multi line menu to navigate through the various functions.

* Implements I2C communication protocol through bit-banging.

* Keeps track of time and sets alarms by controlling the RTC DS1307 through I2C.

* Offers a cycle timer and ten absolute timers for scheduling flood and drain cycles.

* Controls two separate optocoupled inputs and outputs:

  * Inputs are connected to the water float switches.

  * Outputs utilize two 12v/220v - 10A DIN rail relays, for controlling the water pumps.


Upload HEX file using Pickit2/Pickit3 through the onboard ICSP header.

Menu layout:

![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/e2949b570f0ded50d0145d5d1af71eb2ecad39cb/Pics/menu_layout.png)

Schematic:
![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/aaa3a61dfd625b33cdeaa33ab16f7a8a368f2810/PCB/shcematic.png)

