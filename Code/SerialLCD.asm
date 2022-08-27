include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL LCD_cmd
GLOBAL LCD_chr
GLOBAL LCD_Init
Extern I2C_Start
Extern I2C_Stop
Extern I2C_Write
Extern Delay
Extern MiliDelay
Extern MicroDelay

Bank0 UDATA 
SData  	res 1

PROG1 Code



;PCF8574  [0 1 0 0 A2 A1 A0]0 - 7 bits addr. From bit 1 to 7 
;PCF8574A [0 1 1 1 A2 A1 A0 0]- 8 bits addr. From bit 0 to bit 7 thus 0x70


; ------------------------------------ 
; Send COMMANDS from PCF8574A to HD44780
; Data are send serialy using I2C to 8574 and from there parallely to LCD.
; Data are sent 4bit per time. 
; Upper 4 bits is the command for the LCD and lower for Bits is the actual data.
; This is done 2 times because in order to insert the data to the LCD , the LCE_E pin much change from 1 to 0 (pulse)
; First UPPER Nibble is sent and then the LOWER Nibble
; 1-> Rs=0,RW=0,E=1 + Upper Nibble
; 2-> Rs=0,RW=0,E=0 + Upper Nibble
; 3-> Rs=0,RW=0,E=1 + Lower Nibble
; 4-> Rs=0,RW=0,E=0 + Lower Nibble
; ------------------------------------ 
LCD_cmd

	movwf SData
	Call I2C_Start
	;movlw 0x70 ; PCF8574A adddress
	movlw 0x40 ; PCF8574 adddress
	Call I2C_Write

	swapf SData,W
	andlw 0x0f 
	addlw b'10010000'
	Call I2C_Write

	swapf SData,W
	andlw 0x0f 
	addlw b'10000000'
	Call I2C_Write
	;call MiliDelay

	movf SData,W
	xorlw LCD_4bit 
	BTFSC STATUS,Z
	goto Exit_Cmd

	movf SData,W
	andlw 0x0f 
	addlw b'10010000'
	Call I2C_Write

	movf SData,W
	andlw 0x0f 
	addlw b'10000000'
	Call I2C_Write

Exit_Cmd
	Call I2C_Stop

	movf SData,W
	xorlw LCD_Clear 
	BTFSC STATUS,Z
	call MiliDelay
	;Call MicroDelay


return

; ------------------------------------ 
; Send CHARACTERS from PCF8574A to HD44780
; Rs=1,RW=0,E=1 -> Characters
; ------------------------------------ 

LCD_chr
	movwf SData
	Call I2C_Start

	;movlw 0x70 ; PCF8574A adddress
	movlw 0x40 ; PCF8574 adddress
	Call I2C_Write

	swapf SData,W
	andlw 0x0f 
	addlw b'11010000'
	Call I2C_Write

	swapf SData,W
	andlw 0x0f 
	addlw b'11000000'
	Call I2C_Write
	;call MiliDelay


	movf SData,W
	andlw 0x0f 
	addlw b'11010000'
	Call I2C_Write

	movf SData,W
	andlw 0x0f 
	addlw b'11000000'
	Call I2C_Write
	Call I2C_Stop
	;call MicroDelay

return



LCD_Init
	movlw LCD_4bit
	call LCD_cmd
	MOVLW 0x15;100 ms delay
	Call Delay

	movlw LCD_4bit
	call LCD_cmd
	MOVLW 0x15;100 ms delay
	Call Delay

	movlw LCD_4bit
	call LCD_cmd
	MOVLW 0x15;100 ms delay
	Call Delay

	movlw LCD_DisOn
	call LCD_cmd
	MOVLW 0x01;100 ms delay
	Call Delay

	movlw LCD_2Lines
	call LCD_cmd
	MOVLW 0x01;100 ms delay
	Call Delay

	movlw LCD_Clear
	call LCD_cmd
	MOVLW 0x01;100 ms delay
	Call Delay

	movlw LCD_CursorHome
	call LCD_cmd
	MOVLW 0x01;100 ms delay
	Call Delay

return


end