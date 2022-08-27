include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL Delay
GLOBAL MiliDelay
GLOBAL MicroDelay


Temp_Variables UDATA_OVR
;Bank0 UDATA
d1  res 1
d2	res 1
d3	res 1
dd1 res 1
dd2 res 1

PROG1 Code

; ------------------------------------ 
; Delay in 10ms multiples
; ------------------------------------ 
Delay
;return

	pagesel Delay
	movwf d3
Delay2
	movlw D'13'
	movwf d2
	clrf d1
Delay1
	decfsz	d1, f
	goto	Delay1
	decfsz	d2, f
	goto	Delay1
	decfsz	d3, f
	goto	Delay2
return



MiliDelay			

	movlw	0xF9
	movwf	dd1
	movlw	0x04
	movwf	dd2
Delay_0
	decfsz	dd1, f
	goto	$+2
	decfsz	dd2, f
	goto	Delay_0

			;2 cycles
	goto	$+1

return

MicroDelay
	movlw	0x35
	movwf	dd1
Mic_Delay
	decfsz	dd1, f
	goto	Mic_Delay
return

end