#include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL BuildCustomChars
Extern LCD_cmd
Extern LCD_chr
Extern Delay

;Temp_Variables UDATA_ovr

Bank0 UDATA

i  res 1
tmp res 1

PROG2 Code



BuildCustomChars
	movlw 0x40
	pagesel LCD_cmd ;---
	call LCD_cmd
	clrf i
Loop
	pagesel ReadChrData ;---
	Call ReadChrData
	movwf tmp
	PageselW $+2
	movf tmp,W
	PageSel LCD_chr ;---
	call LCD_chr
	PageSel $
	;movlw 0x05
	;call Delay

	incf i
	movlw .40
	xorwf i,w
	btfss STATUS,Z
	goto Loop
return
ReadChrData
	pageselw ChrTbl
	movlw Low ChrTbl
	addwf i,W
	btfsc STATUS,C
	incf PCLATH
	movwf PCL

;PROG2 Code 

	ChrTbl
	;Ch0 dt 0x4,0xe,0xe,0xe,0x1f,0x0,0x4,0x0   		;Bell
	Ch1 dt 0x0,0xe,0x15,0x1d,0x11,0xe,0x0,0 ; clock
	Ch2 dt 0x0,0xe,0x11,0x1d,0x15,0xe,0x0,0 		;11 in one digit
	Ch3 dt 0x0,0xe,0x11,0x17,0x15,0xe,0x0,0 	;12 in one digit
	Ch4 dt 0x0,0xe,0x15,0x17,0x11,0xe,0x0,0
	Ch5 dt 0x4,0xe,0xe,0xe,0x1f,0x0,0x4,0x0   		;Bell

end