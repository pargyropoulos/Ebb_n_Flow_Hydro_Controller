LIST p=16F648A  ;tell assembler what chip we are using
include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
ERRORLEVEL -224 ; suppress annoying message because of tris
ERRORLEVEL -302 ; suppress message because of page change



#define	SCL	RA0		; bus clock line
#define	SDA	RA1		; bus data line
#define I2C_TRIS TRISA
#define I2C_PORT PORTA

Global Read_DS1307
Global Initialize_RTC
Global Write_DS1307
Global I2C_Init
Global SEC
Global MIN
Global HOUR
Global I2C_Start
Global I2C_Stop
Global I2C_Write
Global Check_RTC

Bank0 UDATA
I2C_Data res 1

HOUR res 1
MIN res 1
SEC res 1


Counter res 1
I2Cflags res 1
OutputByte res 1

PROG1 code



;DS1307 Write Address= 0xD0
;DS1307 Read Address= 0xD1
; ------------------------------------ 
; Initialize DS1307
; Sets time to 05:59:55
; and SQW/OUT to pulse on 1 Hz by seting the Control Register (addr 07)
; ------------------------------------ 
Initialize_RTC
	Call I2C_Start
	movlw 0xD0
	Call I2C_Write
	movlw 0x0
	Call I2C_Write
	movlw 0x55
	Call I2C_Write
	movlw 0x59
	Call I2C_Write
	movlw 0x05 
	Call I2C_Write

	Call I2C_Stop

	Call I2C_Start
	movlw 0xD0
	Call I2C_Write
	movlw 0x7
	Call I2C_Write
	movlw 0x10
	Call I2C_Write
	Call I2C_Stop
	;bsf INTCON,GIE
return

; ------------------------------------ 
; Check if DS1307 is initialized
; If Bit 7 (CH bit) of SEC register (Address 00) is set, then the RTC internal oscillator is halted.
; if it is 0 then the clock is ticking.
; ------------------------------------ 

Check_RTC
	CLRF I2C_Data
	Call I2C_Start
	movlw 0xD0
	Call I2C_Write
	movlw 0x00
	Call I2C_Write
	Call I2C_Start
	movlw 0xD1
	Call I2C_Write
	Call I2C_Read
	Call SendNACK
	movwf I2Cflags
	Call I2C_Stop
	btfss I2Cflags,7
	retlw 0x00
	retlw 0x01

Write_DS1307
	;bcf INTCON,GIE
	Call I2C_Start
	movlw 0xD0
	Call I2C_Write
	;sec
	movlw 0x0
	Call I2C_Write
	movf SEC,W
	Call I2C_Write
	movf MIN,W
	Call I2C_Write
	movf HOUR,W
	Call I2C_Write
	Call I2C_Stop
	;bsf INTCON,GIE
return

Read_DS1307
	;bcf INTCON,GIE
	CLRF I2C_Data
	Call I2C_Start
	movlw 0xD0
	Call I2C_Write
	movlw 0x00
	Call I2C_Write
	Call I2C_Start
	movlw 0xD1
	Call I2C_Write
	Call I2C_Read
	Call SendACK
	andlw b'01111111'
	movwf SEC
	Call I2C_Read
	Call SendACK
	andlw b'01111111'
	movwf MIN
	Call I2C_Read
	Call SendNACK
	andlw b'00111111'
	movwf HOUR
	Call I2C_Stop
return

I2C_Init
	call HIGH_SDA
	call HIGH_SCL
return


I2C_Start
	call HIGH_SCL
	call HIGH_SDA
	call LOW_SDA		; bring SDA low while SCL is high
	call LOW_SCL
return

I2C_Stop
	call LOW_SCL
	call LOW_SDA
	call HIGH_SCL
	call HIGH_SDA		; bring SDA high while SCL is high
return

; ------------------------------------ 
; I2C Read
; W holds the data after reading is complete
; SDA should hold the DATA ans SCL should send the clock pulse
; Data can only been sent when SCL is low and kept stable when SCL is high
; ------------------------------------ 
I2C_Read
	call HIGH_SDA ; make sda an input (while sSCL is low)
	clrf I2C_Data
	movlw 0x08
	movwf Counter
ReadLoop
	call HIGH_SCL
	goto $+1
	goto $+1
	btfss I2C_PORT,SDA
	Goto BitZero
	Goto BitOne
BitZero
	bcf STATUS,C
	rlf I2C_Data,F
	Goto Cont
BitOne
	bsf STATUS,C
	rlf I2C_Data,F
	goto Cont
Cont
	call LOW_SCL
	goto $+1
	goto $+1
	decfsz Counter,F
goto ReadLoop
	movf I2C_Data,W
return

SendACK
	call 	LOW_SDA
	call 	Clock_Pulse

return

SendNACK
	call 	HIGH_SDA
	call 	Clock_Pulse
return


; ------------------------------------ 
; I2C Write (MSB -> LSB)
; W should hold the byte to write
; SDA should hold the DATA ans SCL should send the clock pulse
; Data can only been sent when SCL is low and kept stable when SCL is high
; ------------------------------------ 
I2C_Write
	movwf 	OutputByte
	movlw 	0x08
	movwf 	Counter
	CALL	LOW_SCL
Out_Bit:
	bcf 	STATUS,		C	; clear carry
	rlf 	OutputByte, f	; left shift, most sig bit is now in carry
	btfss 	STATUS, 	C	; if one, send a one
	goto 	Out_Zero
	goto 	Out_One

Out_Zero:
	call 	LOW_SDA			; SDA at zero
	call 	Clock_Pulse		;Clock_Pulse
	goto 	Out_Cont
Out_One:
	call 	HIGH_SDA		; SDA at logic one
	call 	Clock_Pulse
	goto 	$+1
Out_Cont:
	decfsz 	Counter,		F	; decrement index
	goto 	Out_Bit

;Check for Acknowledgent
	;call 	LOW_SCL
	call 	HIGH_SDA		; 9th clock pulse to test for ACK
	call 	HIGH_SCL		; Practically, SDA can never go High if the the slave-receiver has received
	clrf	Counter			; data properly and Acknowledges the reception by holding it low.
WaitForACK	
	incf	Counter, f		; increase timeout counter each time ACK is not received
	btfsc	STATUS, Z
	goto	No_ACK_Received
	btfsc	I2C_PORT,	SDA	; If receiver Keeps SDA low then it means that
	goto	WaitForACK		; he acknowledges the transfer. 
	bcf	I2Cflags, 0			;
	call 	LOW_SCL
return
No_ACK_Received
	bsf	I2Cflags, 0		; set flag bit
	call 	LOW_SCL
return	


; ------------------------------------ 
; Make SDA High
; Since SDA is pulled up, to become high should be configured as input (having high impedance thus floats)
; ------------------------------------ 
HIGH_SDA		
	Banksel I2C_TRIS
	bsf 	I2C_TRIS,SDA	; make SDA pin an input
	Banksel 0

return

; ------------------------------------ 
; Make SDA Low
; Since SDA is pulled up, to become Low the pin 
; should be configured as output with state=0
; ------------------------------------ 
LOW_SDA
	bcf 	I2C_PORT,SDA	; send 0
	banksel I2C_TRIS		; bank 1
	bcf 	I2C_TRIS,SDA	; make SDA pin an output
	Banksel 0				; back to bank 0

return

HIGH_SCL
	Banksel I2C_TRIS
	bsf 	I2C_TRIS,SCL	; make SDA pin an input
	Banksel 0

return

LOW_SCL
	bcf 	I2C_PORT,SCL	; send 0
	banksel I2C_TRIS		; bank 1
	bcf 	I2C_TRIS,SCL	; make SDL pin an output
	Banksel 0				; back to bank 0

return

Clock_Pulse					; SCL momentarily to logic one
	;call 	HIGH_SCL
	Banksel I2C_TRIS
	bsf 	I2C_TRIS,SCL	; make SDA pin an input
	Banksel 0
	goto $+1
	goto $+1
	;goto $+1
	;goto $+1
	;call 	LOW_SCL
	bcf 	I2C_PORT,SCL	; send 0
	banksel I2C_TRIS		; bank 1
	bcf 	I2C_TRIS,SCL	; make SDL pin an output
	Banksel 0				; back to bank 0
	goto $+1
	goto $+1
	;goto $+1
	;goto $+1

return	

end