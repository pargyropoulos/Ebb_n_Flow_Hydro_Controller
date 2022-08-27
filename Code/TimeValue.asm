include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
Global TimeValue
Global ActiveTimer
Global AlarmCHK

Extern MIN
Extern HOUR
Extern Bcd2Hex
Extern LCD_cmd
Extern LCD_chr
Extern EEPROM_Read



Bank0 udata 
Var1 res 1
Var2 res 1
Var3 res 1
Counter res 1
TmpVar Res 1

Bank1 udata
CT_H    res 1
CT_M    res 1
START_H res 1
START_M res 1
STOP_H  res 1
STOP_M  res 1
tmp 	res 2
M_FDelay res 1
H_DDelay res 1
M_DDelay res 1

SharedMem Udata
Cnt Res 1

PROG1 Code

ActiveTimer
banksel tmp
	MovLw .55 ; Adress of CycleTmrStatus
	Call EEPROM_Read
	BTFSC STATUS,Z
	Goto ReturnIdle

;Current Time
	banksel HOUR
	movf HOUR,W
	call Bcd2Hex
	banksel CT_H
	movwf CT_H

	banksel MIN
	movf MIN,W
	call Bcd2Hex
	banksel CT_M
	movwf CT_M

	bankisel CT_H
	movlw CT_H
	call TimeValue


	movlw START_H
	movwf FSR
	MovLw .56 ; Adress of CycleTmr Start Hour
	Call EEPROM_Read
	movwf INDF
	incf FSR
	MovLw .57 ; Adress of CycleTmr Start Minute
	Call EEPROM_Read
	movwf INDF
	movlw START_H
	Call TimeValue
	
	movlw STOP_H
	movwf FSR
	MovLw .58 ; Adress of CycleTmr Stop Hour
	Call EEPROM_Read
	movwf INDF
	incf FSR
	MovLw .59 ; Adress of CycleTmr Stop Minute
	Call EEPROM_Read
	movwf INDF
	movlw STOP_H
	Call TimeValue


	movlw M_FDelay
	movwf FSR
	MovLw .60 ; Adress of CycleTmr Flood Delay
	Call EEPROM_Read
	movwf INDF

	movlw H_DDelay
	movwf FSR
	MovLw .61 ; Adress of CycleTmr Drain Delay
	Call EEPROM_Read
	movwf INDF
	incf FSR; 
	MovLw .62 ; Adress of CycleTmr Drain Delay
	Call EEPROM_Read
	movwf INDF
	movlw H_DDelay
	Call TimeValue
	;Call ShowTimeValue

	
	banksel STOP_H ; Switch to Bank 1 - SOS

Check1
	BCF STATUS,C
	BCF STATUS,Z

	movf START_H,W
	subwf CT_H,W
	btfss STATUS,C ;if Current Time_H < Start_H (+Drain) then Exit and return Drain
	Goto ReturnDrain
	btfss STATUS,Z
	goto Check2
	movf START_M,W
	subwf CT_M,W
	btfss STATUS,C
	Goto ReturnDrain

Check2
	movf STOP_H,W
	subwf CT_H,W
	btfss STATUS,C ;if Current Time_H < Stop_H then CheckFlood
	Goto CheckFlood
	btfss STATUS,Z
	goto ReturnDrain
	movf STOP_M,W
	subwf CT_M,W
	btfss STATUS,C
	Goto CheckFlood
	Goto ReturnDrain

CheckFlood
	movf M_FDelay,W
;	movlw 0x02

	BtfSC STATUS,Z
	GOTO ReturnDrain


	addwf START_M,F
	btfsc STATUS,C
	incf START_H


	movf START_H,W
	subwf CT_H,W; Check CurrentTime -(StartTime+Flood Delay). 
				;If CurrentTime < StartTime+Flood Delay (...and CurrentTime > StartTime from previous check) then Return Flood
	btfss STATUS,C ;if Carry is zero then result is negative, if it is set then it is either greater or equal
	Goto ReturnFlood

	btfss STATUS,Z ; if the result is zero then check for the minutes
	goto CheckDrain ; else check if it is time for Drain
	movf START_M,W
	subwf CT_M,W
	btfss STATUS,C
	Goto ReturnFlood

CheckDrain

	movf M_DDelay,W
;	movlw 0x3e


	addwf START_M,F ; StartTime is now added with both Flood Delay and Drain Delay
	btfsc STATUS,C
	incf START_H

	movf H_DDelay,W
;	movlw 0x00

	addwf START_H,F ; StartTime is now added with both Flood Delay and Drain Delay

	movf START_H,W
	subwf CT_H,W
	btfss STATUS,C
	Goto ReturnDrain
	btfss STATUS,Z
	goto CheckFlood

	movf START_M,W
	subwf CT_M,W
	btfss STATUS,C
	goto ReturnDrain
	goto CheckFlood

ReturnFlood
	banksel 0
	RetlW Flood
ReturnDrain
	banksel 0
	Retlw Drain
ReturnIdle
	banksel 0
	Retlw Idle



TimeValue
	BCF STATUS,C
	BCF STATUS,Z

	movwf FSR
	movf INDF,W
	banksel 0
	;Call Bcd2Hex

	movwf Var1
	movwf Var3
	clrf Var2


;Multiply Hours x 60
;Hours = Hours x 64 - (Hours x 4)
;thus, 6 RLFs and 4 Subs
	movlw 0x6
	movwf Counter
MulLoop
	rlf Var1 
	rlf Var2
	btfsc STATUS,C
	incf Var2
	decfsz Counter
	goto MulLoop

	movlw 0x4
	movwf Counter
	movf Var3,W
SubLoop
	subwf Var1,F
	btfss STATUS,C
	decf Var2
	decfsz Counter
	goto SubLoop
	
	;movf MIN,W
	incf FSR
	movf INDF,W
	;Call Bcd2Hex
	addwf Var1,F
	btfsc STATUS,C
	incf Var2

	movf Var1,W
	movwf INDF
	decf FSR
	movf Var2,W
	movwf INDF
	
return

;ShowTimeValue
;	banksel CT_H
;	movf CT_H,W
;	banksel Var2
;	movwf Var2
;
;	banksel CT_M
;	movf CT_M,W
;	banksel Var1
;	movwf Var1
;
;	movlw LCD_Line1+.11
;	call LCD_cmd
;	movf Var2,W
;	addlw 0x30
;	call LCD_chr
;
;	swapf Var1,W
;	andlw 0x0f
;	movwf Var3		
;
;	movlw LCD_Line1+.12
;	call LCD_cmd
;
;	movf Var3,W
;	sublw 0x09
;	btfss STATUS,C
;	goto $+5
;	movf Var3,W
;	addlw 0x30
;	call LCD_chr
;	goto $+4
;	movf Var3,W
;	addlw 0x37
;	call LCD_chr
;
;
;	movf Var1,W
;	andlw 0x0f
;	movwf Var3		
;
;	movlw LCD_Line1+.13
;	call LCD_cmd
;
;	movf Var3,W
;	sublw 0x09
;	btfss STATUS,C
;	goto $+5
;	movf Var3,W
;	addlw 0x30
;	call LCD_chr
;	return
;	movf Var3,W
;	addlw 0x37
;	call LCD_chr
;return


AlarmCHK
	clrf Cnt
	clrf TmpVar
Loop
	;Check if Alarm is Active
	banksel Cnt
	movlw 0x04
	Addwf Cnt,W
	Call EEPROM_Read

	btfsc STATUS,Z
	;If not, check the next timer
	goto CheckNext

	Incf TmpVar ; if tmpvar stays 0 after all checks then no alarm is active and waterstatus is Idle

	movf HOUR,W
	call Bcd2Hex
	banksel CT_H
	movwf CT_H

	banksel MIN
	movf MIN,W
	call Bcd2Hex
	banksel CT_M
	movwf CT_M

	bankisel CT_H
	movlw CT_H
	call TimeValue


	movlw START_H
	movwf FSR
	;MovLw .5 ; Adress of CycleTmr Start Hour
	movf Cnt,W
	Call EEPROM_Read
	movwf INDF
	incf FSR
	;MovLw .06 ; Adress of CycleTmr Start Minute
	movf Cnt,W
	addlw 0x01
	Call EEPROM_Read
	movwf INDF

	movlw START_H
	Call TimeValue
	movlw STOP_H
	movwf FSR
	;MovLw .07 ; Adress of CycleTmr Stop Hour
	movf Cnt,W
	addlw 0x02
	Call EEPROM_Read
	movwf INDF
	incf FSR
	;MovLw .08 ; Adress of CycleTmr Stop Minute
	movf Cnt,W
	addlw 0x03
	Call EEPROM_Read
	movwf INDF
	movlw STOP_H
	Call TimeValue

	;Call ShowTimeValue

	banksel START_H
	;movlw 0x01
	;movwf START_H
	;movlw 0x68
	;movwf START_M
	;movlw 0x01
	;movwf STOP_H
	;movlw 0x6D
	;movwf STOP_M

	
	movf STOP_H,W
	subwf CT_H,W
	btfss STATUS,C ; if CT_H-STOP_H gives carry then CT_H<STOP_H. Note! os Subtraction, pollarity is reversed
	goto CheckFloodTime ; and CARRY is set when C = 0
	BTFSS STATUS,Z
	goto CheckNext
	;goto ReturnDrain

	movf STOP_M,W
	subwf CT_M,W
	btfss STATUS,C
	Goto $+2
	;Goto ReturnDrain
	goto CheckNext

CheckFloodTime:
	movf CT_H,W
	subwf START_H,W
	btfss STATUS,C
	Goto ReturnFlood

	btfss STATUS,Z
	goto CheckNext
	;Goto ReturnDrain
	movf CT_M,W
	subwf START_M,W
	btfss STATUS,C
	Goto ReturnFlood

	btfss STATUS,Z
	Goto CheckNext
	;Goto ReturnDrain
	Goto ReturnFlood


CheckNext
	movf Cnt,W
	addlw 0x05
	movwf Cnt
	xorlw .50
	btfss STATUS,Z
	goto Loop
				  ; After checking all 10 abs timers
	movf TmpVar,F ; if TmpVar=0 then no abs timer was ON thus return IDLE, If it is > 1 then one or more
	btfss STATUS,Z; timers were active but none is triggered, so Return Drain
	goto ReturnDrain
	goto ReturnIdle
	
return


end
