include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2

#Define FloodPump PORTA,7
#Define DrainPump PORTA,6

#Define UFSW PORTB,RB1 	; upper float switch
#Define LFSW PORTB,RB2	; lower float switch

Extern WaterStatus
Extern OldWaterStatus

Extern TMR1Delay
Extern UFSwDelay
Extern LFSwDelay

Extern Delay

Global CheckWaterStatus


PROG1 Code


CheckWaterStatus
	movf WaterStatus,W
	btfsc STATUS,Z ;0=Drain 1=Flood FF=Idle
	Goto Draining
	comf WaterStatus,W
	btfsc STATUS,Z ;0=Drain 1=Flood FF=Idle
	Goto SetIdle
	Goto Flooding
Draining
	;Step 1 - Check Previous State
	Movf OldWaterStatus,W
	;Btfsc STATUS,Z
	skpnz STATUS,Z
	Goto $+3
	;Step 2 - Old State is Flood
	Bcf T1CON,TMR1ON ; Disable Tmr1
	clrf TMR1Delay
	;Step 3 - Old State is Drain (same state)
	BCF FloodPump
	clrf OldWaterStatus
	
	;Step 4 - Check Low Float Switch
	btfsc LFSW
	Goto DFloatswitch_OFF

	;Debounce the float switch
	movlw 0x01 ; wait for 10ms
	Call Delay ; and check the port again. If the result
	btfsc LFSW ; keeps the same then accept it.
	Goto DFloatswitch_OFF

	;Step 5 - LFSW is On
	BCF DrainPump
	movf LFSwDelay,W
	movwf TMR1Delay	
	rlf  TMR1Delay,F

	BSF T1CON,TMR1ON ; Enable Tmr1
	return
DFloatswitch_OFF
	;Step 6 - Is Delay-0?
	movf TMR1Delay,W
	btfss STATUS,Z
	return
SetDrainPumpOn
	;Step 7 - Set Drain Pump=ON
	BSF DrainPump
	return

Flooding
	;Step 1 - Check Previous State
	Movf OldWaterStatus,W
	Xorlw Flood
	Btfsc STATUS,Z
	;skpz STATUS,Z
	Goto $+3 ;last state=Flood
	;Step 2 - Old State is Drain
	Bcf T1CON,TMR1ON ; Disable Tmr1
	clrf TMR1Delay
	;Step 3 - Old State is Flood (same state)
	BCF DrainPump
	movlw Flood
	movwf OldWaterStatus
	
	;Step 4 - Check Upper Float Switch
	btfsc UFSW
	Goto UFloatswitch_OFF

	;Debounce the float switch
	movlw 0x01
	Call Delay
	btfsc UFSW
	Goto UFloatswitch_OFF


	;Step 5 - LFSW is On
	BCF FloodPump
	movf UFSwDelay,W
	movwf TMR1Delay	
	rlf  TMR1Delay,F

	BSF T1CON,TMR1ON ; Enable Tmr1
	return
UFloatswitch_OFF
	;Step 6 - Is Delay-0?
	movf TMR1Delay,W
	btfss STATUS,Z
	return
SetFloodPumpOn
	;Step 7 - Set Flood Pump=ON
	BSF FloodPump
return


SetIdle
	Bcf T1CON,TMR1ON ; Disable Tmr1
	clrf TMR1Delay
	BCF DrainPump ; Disable both pumps
	BCF FloodPump
	movlw Idle
	movwf OldWaterStatus ; Change OldWaterStatus
Return

end