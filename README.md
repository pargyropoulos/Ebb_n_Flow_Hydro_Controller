# Ebb_n_Flow_Hydro_Controller
A digital hydroponic controller based on PIC16F648A, written exclusively in ASM.

A fully functional multi line menu to navigate through the various functions.

Bit bang I2C communication protocol implementation.

4-Bit control of an LCD 16x2 - HD44780 using a PCF8574 I2C expander.

Keeping track of time and setting alarms by controlling the RTC DS1307.

Controls two digitital I/Os:

Inputs are connected to the water float switches.

Outputs utilize two 12v/220v - 10A relays, for controlling the water pumps.

I/O are optocoupled for extra protection.

Upload HEX file uising Pickit2/Pickit3 through the onboard ICSP header.

Schematic:
![image](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/aaa3a61dfd625b33cdeaa33ab16f7a8a368f2810/PCB/shcematic.png)

Finished Project:

![alt text](https://github.com/pargyropoulos/Ebb_n_Flow_Hydro_Controller/blob/6df0419a8ad1f117804a3522efc8b418cdfc7c99/Pics/_All.jpg)
