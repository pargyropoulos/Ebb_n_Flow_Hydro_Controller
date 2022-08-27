include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL Hex2Dec
Global Tens
Global Ones
Global BCD

Temp_Variables UDATA_OVR
Var1 res 1
;Var2 res 1

Bank0 UDATA
Tens res 1
Ones res 1
BCD res 1


PROG1 Code

Hex2Dec
	clrf Tens
	clrf Ones
	movwf Var1
	movlw 0x0A
Loop
	subwf Var1
	incf Tens
	btfss STATUS,C
	goto $+2
goto Loop

	decf Tens
	addwf Var1
	movf Var1,W
	movwf Ones

	movwf Var1
	movf Tens,W
	;movwf Var2
	movwf BCD

	movlw 0xf0
	xorwf Var1,F
	;swapf Var2,F
	swapf BCD,F
	
	movlw 0x0f
	;xorwf Var2,W
	xorwf BCD,W
	andwf Var1,W
	movwf BCD


return


end