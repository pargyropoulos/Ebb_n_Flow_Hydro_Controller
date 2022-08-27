#include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2

Global ShowActiveAlarms
Global ShowTimeAndStatus

Extern EEPROM_Read
Extern LCD_cmd
Extern LCD_chr
Extern Bcd2Hex
Extern Hex2Dec

Extern SEC
Extern MIN
Extern HOUR
Extern BCD
Extern WaterStatus
Extern OldWaterStatus
Extern Blink

Temp_Variables UDATA_OVR
i		res 1
tmp		res 1


Bank0 udata 
Counter	res 1
TmpVar  res 1


PROG1 Code
ShowTimeAndStatus
	movlw LCD_Line1+.13
	call LCD_cmd


	movf WaterStatus,F
	btfsc STATUS,Z ;0=Drain 1=Flood FF=Idle
	Goto DRN
	comf WaterStatus,W
	btfss STATUS,Z ;0=Drain 1=Flood FF=Idle
	Goto FLD
IDL:
	movlw 'I'
	call LCD_chr
	movlw 'D'
	call LCD_chr
	movlw 'L'
	call LCD_chr
	goto XXX1
FLD:
	movlw 'F'
	call LCD_chr
	movlw 'L'
	call LCD_chr
	movlw 'D'
	call LCD_chr
	goto XXX1
DRN:
	movlw 'D'
	call LCD_chr
	movlw 'R'
	call LCD_chr
	movlw 'N'
	call LCD_chr

XXX1:
	movlw LCD_Line1+.11
	call LCD_cmd
	movlw 'S'
	call LCD_chr
	movlw '-'
	call LCD_chr

	movlw LCD_Line1
	call LCD_cmd
	movlw 'T'
	call LCD_chr
	movlw '-'
	call LCD_chr




	swapf HOUR,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
	movf HOUR,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
	movlw ':'
	call LCD_chr
	swapf MIN,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
	movf MIN,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
	movlw ':'
	call LCD_chr
	swapf SEC,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
	movf SEC,W
	andlw 0x0f
	addlw 0x30
	call LCD_chr
return

; ------------------------------------ 
; Check for Active Alarms
; ------------------------------------ 

ShowActiveAlarms
	clrf Counter
	clrf i
	clrf tmp
AlarmLoop
	movlw 0x04
	Addwf Counter,W
	Call EEPROM_Read
	btfsc STATUS,Z
	goto NoAlarm
	movlw LCD_Line2+5
	addwf i,W ; next column
	call LCD_cmd
	movf Blink,W
	call LCD_chr
	Goto NextAlarm
NoAlarm
	movlw LCD_Line2+5
	addwf i,W ; next column
	call LCD_cmd
	movlw 0x03
	call LCD_chr
NextAlarm
	incf i
	movf Counter,W
	addlw 0x05
	movwf Counter
	xorlw .50
	btfss STATUS,Z
	goto AlarmLoop

	movlw .55 ; Cycle timer alarm
	Call EEPROM_Read
	btfsc STATUS,Z
	goto NoAlarm2
	movlw LCD_Line2+1
	call LCD_cmd

	movf Blink,W
	call LCD_chr
	return
NoAlarm2:
	movlw LCD_Line2+1
	call LCD_cmd
	movlw 0x03
	call LCD_chr

	return



end