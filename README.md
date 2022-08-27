# Ebb_n_Flow_Hydro_Controller
A digital hydroponic controller based on PIC16F648A, written exclusively in ASM a decade ago.

4-Bit control of an LCD 16x2 - HD44780 using a PCF8574 I2C expander.

A fully functional multi line menu to navigate through the various functions.

Bit-bang I2C communication protocol implementation.

Keeping track of time and setting alarms by controlling the RTC DS1307.

Controls two separate inputs and outputs:

Inputs are connected to the water float switches.

Outputs utilize two 12v/220v - 10A DIN rail relays, for controlling the water pumps.

I/Os are optocoupled for extra protection.

Upload HEX file using Pickit2/Pickit3 through the onboard ICSP header.

Menu layout:

![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/e2949b570f0ded50d0145d5d1af71eb2ecad39cb/Pics/menu_layout.png)

Schematic:
![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/aaa3a61dfd625b33cdeaa33ab16f7a8a368f2810/PCB/shcematic.png)

Finished Project:

![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/6df0419a8ad1f117804a3522efc8b418cdfc7c99/Pics/_All.jpg)


Buckets and Tank Layout:

![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/77c5ad3ff5428256734e4bb2434e1d09b99e3ed1/Pics/Buckets_Layout.jpg)
