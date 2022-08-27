#include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL Bcd2Hex

Temp_Variables UDATA_OVR
Var1 res 1
Var2 res 1

PROG1 Code

; ------------------------------------ 
; Binary to Hex Conversion
; W should hold the data to convert
; On exit W holds the converted Data
; ------------------------------------ 

Bcd2Hex
	movwf Var1		;Var1 = BCD eg bcd'49'
	swapf Var1,W	;Var1= '94'
	andlw 0x0f
	movwf Var2
	bcf STATUS,C
	rlf Var2
	rlf Var2
	rlf Var2
	addwf Var2,F
	addwf Var2,F

	bcf STATUS,C
	movf Var1,W
	andlw 0x0f
	addwf Var2,W
return


end