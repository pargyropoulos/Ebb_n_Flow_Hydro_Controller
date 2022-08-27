LIST p=16F648A  ;tell assembler what chip we are using
#include "P16F648A.inc"  ;include the defaults for the chip
#include DataTables.asm

__config  _INTOSC_OSC_NOCLKOUT & _LVP_OFF & _WDT_OFF & _PWRTE_ON & _BOREN_OFF & _BODEN_OFF & _MCLRE_OFF & DATA_CP_ON & _CP_ON  

errorlevel 2
 ;ERRORLEVEL -224 ; suppress annoying message because of tris
 ;ERRORLEVEL -302 ; suppress message because of page change
   

Extern Hex2Dec 
Extern BCD
Extern LCD_cmd
Extern LCD_chr
Extern LCD_Init
;Extern LCD_Clear

Extern Delay
Extern BuildCustomChars
Extern PrintLCDVariable
Extern RefreshLCD
Extern ShowActiveAlarms


Extern Bcd2Hex
Extern ShowTimeAndStatus

;Extern Variables
Extern Tens,Ones

Extern CheckWaterStatus

;From ReadTables.asm
Extern ReadVarTable
Extern ReadExtMenuItem
Extern ReadCursorTbl
Extern ReadMenuTable

;From EEPROM.asm
Extern EEPROM_Read
Extern EEPROM_Write
Extern WriteDatatoEEPROM



Extern TimeValue
Extern ActiveTimer
Extern AlarmCHK

;From I2C
Extern Check_RTC
Extern Read_DS1307
Extern Initialize_RTC
Extern Write_DS1307
Extern I2C_Init
Extern SEC
Extern MIN
Extern HOUR

	Extern I2C_Start
	Extern I2C_Write
	Extern I2C_Stop


Global RelativeColumn
Global Column
Global CursorPos
Global EEPROM_Address  
Global EEPROM_Data 
Global EEPROM_DataType 
Global EEPROM_Min 		
Global EEPROM_Max 	
Global CursorPos 
Global ExtMenuItem

Global WaterStatus
Global OldWaterStatus


Global TMR1Delay
Global UFSwDelay
Global LFSwDelay

Global VarTbl_PCLATH
Global VarTbl_PCL
Global ExtMenuItem
Global ExtMenuItem_Offset
Global ExtMenuItem_Segment
Global CursorPos
Global MenuItem

Global MenuItemTbl;label
Global Blink


; ------------------------------------ 
; Menu Items Data Table
;Byte1: Menu Position
;Byte2: Menu on Enter
;Byte3: Routine One Enter
;Byte4: Pointer to Text String - PCL
;Byte5: Pointer to Text String - PCLATH
;Byte6: Pointer to Extended Variable Table - PCL
;Byte7: Pointer to Extended Variable Table - PCLATH
; ------------------------------------ 

#Define Menu_POS			MenuItem+0
#Define Menu_MenuOnEnter	MenuItem+1
#Define Menu_RoutineOnEnter	MenuItem+2
#Define Menu_TextOffset  	MenuItem+3
#Define Menu_TextSegment 	MenuItem+4
#Define Menu_ExtMenuOffset  MenuItem+5
#Define Menu_ExtMenuSegment MenuItem+6
#Define Menu_Reserved		MenuItem+7


#Define ExtMenu_VarNum				ExtMenuItem+0
#Define ExtMenu_VarOffset			ExtMenuItem+1
#Define ExtMenu_VarSegment			ExtMenuItem+2
#Define ExtMenu_TextOffset			ExtMenuItem+3
#Define ExtMenu_TextSegment   		ExtMenuItem+4
#Define ExtMenu_CursorTblOffset		ExtMenuItem+5
#Define ExtMenu_CursorTblSegment	ExtMenuItem+6
#Define ExtMenu_StateMachine  		ExtMenuItem+7



#Define Tmr0  0
#Define Tmr1  1

#Define FloodPump PORTA,7
#Define DrainPump PORTA,6




Temp_Variables Udata_OVR
i Res 1
c Res 1
tmp3 Res 1
W_Old Res 1
TmpVar Res 1
ExtMenuItem_Offset Res 1
ExtMenuItem_Segment Res 1


Bank0 udata 
	tmp  Res 1
	tmp2 Res 1

	Line  Res 1

	OldLine Res 4; Should be increased if menu depdth is increase (sub menus in a row)
	OldMenu Res 4; 
	OldStateMachine Res 1;	

	Menu  Res 1
	MenuItem  Res 0x08 ; Holds the Menu Item Table
	Column    Res 1
	MenuDepth Res 1
	ExtMenuItem Res 0x0A ; Holds the Extended menu Item Table
	RelativeColumn Res 1
	StateMachine   Res 1
	Counter  Res 1;Menu Variable
	KeyPressed  Res 1; Interrupt Variable! SOS dont touch!
	LCD_tmp  Res 1
	VarTbl_PCLATH  Res 1
	VarTbl_PCL  Res 1

	TextSegment Res 1
	TextOffset  Res 1

	ChangeFlag Res 1
	PCLATH_OLD res 1
	INTFlag res 1
	WaterStatus Res 1
	OldWaterStatus Res 1
	dx0 res 1
	dx1 res 1
	Flag res 1

TMR1Delay res 1
UFSwDelay res 1
LFSwDelay res 1
Blink res 1
BlinkCnt res 1
tmpDelay res 1
ESC_Hold res 1

Bank1 udata
	EEPROM_Address  Res 0x08 
	EEPROM_Data 	Res 0x08
	EEPROM_DataType Res 0x08
	EEPROM_Min 		Res 0x08
	EEPROM_Max 		Res 0x08
	CursorPos 		Res 0x08

;Bank2 udata
;	ROM_Data res .70

SharedMem Udata
	W_TEMP Res 1
	STATUS_TEMP Res 1 ; Interrupt Variables


START Code   ;org sets the origin, 0x0000 for the 16F628,this is where the program starts running 	
goto main

INT_Handler Code 

	movwf W_TEMP	; movwf does not alter STATUS
 	swapf STATUS,W	; move Status to W without affecting flags. The saved value is swapped
 	BCF STATUS,RP0
 	movwf STATUS_TEMP
	movf PCLATH,W	;save PCLATH
	movwf PCLATH_OLD
	pagesel $
	clrf STATUS

	
	; Check which interrupt occured
	; RB7:4 Int occured?
 	BTFSS INTCON,RBIF
 	Goto CheckTMR0
	movf PORTB,W
	andlw 0xF0 ;check only RB4 to RB7
	movwf KeyPressed


	;movlw 0x04 ; Software Push buttons Debouncing. Wait for 40ms and recheck keys
	;call Delay ; then accept the ports state. 
	movlw 0x04
	movwf tmpDelay
DelayLoop
	movlw	0x1F
	movwf	dx0
	movlw	0x08
	movwf	dx1
XDelay_0
	decfsz	dx0, f
	goto	$+2
	decfsz	dx1, f
	goto	XDelay_0

			;2 cycles
	goto	$+1

	movf PORTB,W
	andlw 0xF0 ;check only RB4 to RB7
	xorwf KeyPressed,W
	btfsc STATUS,Z
	goto $+4
	decfsz tmpDelay
	goto DelayLoop
	clrf KeyPressed	


	bcf INTCON,RBIF ;clear int RB7:RB4 flag 
	goto ExitInt

CheckTMR0:
;Tmr0 Int Occured?
;Triggers the INTFlag to check if an alarm occured.
	BTFSS INTCON,T0IF
	goto CheckTMR1

	movlw 0x01
	movwf INTFlag

	decfsz BlinkCnt
	goto ExitTmr0

	decf Blink,W
	xorlw 0xFF
	movlw 0x4
	btfsc STATUS,Z
	movwf Blink
	decf Blink
	movlw 0x04 ; to reduce the small alarm font rotation to 1/4 sec
	movwf BlinkCnt
ExitTmr0:
	bcf INTCON,T0IF ;clear Tmr0 Flag
	goto ExitInt

CheckTMR1:
	;Tmr1 Int Occured?
 	BTFSS PIR1,TMR1IF
	goto ExitInt
	movlw 0xdB ;0xdf
	movwf TMR1L
	movlw 0x0B
	movwf TMR1H
	
	movf TMR1Delay,F
	btfss STATUS,Z
	decf TMR1Delay
	bcf PIR1,TMR1IF ;clear Tmr1 Flag


ExitInt
	movf PCLATH_OLD,W
	movwf PCLATH		;restore PCLATH
	swapf STATUS_TEMP,W ; swap back status to W
 	movwf STATUS 		; pop original value to status
 	swapf W_TEMP,F		;swap back W value
 	swapf W_TEMP,W 
retfie

PROG1 Code
main
; ------------------------------------ 
; initialization - set ports
; ------------------------------------ 
	movlw 0x07
 	movwf CMCON   ;turn comparators off and enable pins for I/O functions
    bsf  STATUS, RP0    ;select bank 1
    movlw  b'11110110'
    movwf  TRISB
    movlw  b'0'  
    movwf TRISA   ;set PortA all outputs
 	bcf STATUS,RP0   ;select bank 0
	clrf PORTA

;OPTION REG
;bits 2-0: 1:256 TMR0 Prescaler
;bit 5: 0=internal instruction cycle clock for TMR0 source
;bit 6: 1= RB0/int on rising edge
;bit 7: 1=portb pull ups are disabled
; TMR0 overflows every 256 cycles and since the prescaler is 256, Tmr0's frequency will 
; be 1 Mhz/256/256=15,25Hz thus it will trigger every 1 sec / 15,25times/sec = 0,06557 sec = 65,57 msec
; Then a countdown timer (BlinkCnt) is used from inside the interrupt, that sets a flag on every 4 ticks
; of the clock, thus in about 1/4 sec, to make the Clock Font to rotate.

	Movlw b'11000111'
    bsf  STATUS, RP0    ;select bank 1
    MOVWF OPTION_REG
 	bcf STATUS,RP0   ;select bank 0
	
	;enable Interrupts
 	CLRF INTCON 
 	bsf INTCON,GIE
 	bsf INTCON,RBIE
 	bsf INTCON,T0IE ; Tmr0
	bsf INTCON,PEIE; Enable Periferal Ints
	
	MOVLW 0x20;100 ms delay
	call Delay 
	Call I2C_Init
	Call LCD_Init
	MOVLW 0x0A;100 ms delay
	Call Delay 

	Pagesel BuildCustomChars
	Call BuildCustomChars ; Build custom characters
	Pagesel $	

	;If RTC is not initialized, then initialize it
	Call Check_RTC
	xorlw 0x00
	btfss STATUS,Z
	Call Initialize_RTC

	clrf WaterStatus
	clrf OldWaterStatus
	clrf TMR1Delay	


; Timer1 will overflow after FFFF-BDB =F424 = 62500 cycles.
; Since the prescaler is 8, then 1.000.000 hz / 62500 / 8 = 2 Hz 
; Thus is will trigger every 1sec/2 = 0.5 sec = 500 ms
; It is used to count down the float switches delay
 	movlw b'00110000'
	movwf T1CON ; enable TMR1, prescaler 8
	movlw 0xDB;
	movwf TMR1L;
	movlw 0x0B;
	movwf TMR1H; set TMR1 to trigger every 0,5 sec


;Set Tmr2 to drive LCD contrast
;using different duty cycles
	clrf	T2CON
	clrf	TMR2
	bsf	STATUS,RP0
	clrf	PIE1 ;clear all periferal ints
	bsf PIE1,TMR1IE ; enable only tmr1 int
	bcf	STATUS,RP0
	clrf	PIR1
	bsf	STATUS,RP0
	movlw	0x80
	movwf	PR2 	; compare with 255
	bcf	STATUS,RP0
	movlw	(3 * 0x0A)
	movwf	CCPR1L ; adjusts contrast
	movlw	0x04
	movwf	T2CON	 ; prescaler 1:16 and postscaler 1:1
	movlw	0x3C
	movwf	CCP1CON
	bsf	T2CON,TMR2ON



	Movlw 0x03
	Movwf StateMachine
	;movlw 0x0A
	;movwf UFSwDelay
	;movlw 0x06
	;movwf LFSwDelay
	;clrf WaterStatus
	clrf KeyPressed

	movlw 1
	movwf INTFlag
	movlw 3
	movwf Blink
	movlw 0x06
	movwf BlinkCnt







; ------------------------------------ 
; Endless Menu Loop
; ------------------------------------ 
Call I2C_Start

;Call LoadTime
;Call SaveTime
MenuLoop
	movf INTFlag,F
	btfsc STATUS,Z
	goto LoopCont
	;Disable Interrupts to do all checkings and mess with I2C
	bcf INTCON,GIE
	Call Read_DS1307

	Call ActiveTimer ;Checks Repeative Timer
	movwf WaterStatus
	Call AlarmCHK 
	
	xorlw Idle 
	btfsc STATUS,Z
	Goto ABS_Idle
ABSNotIDLE:
	xorlw Idle
	comf WaterStatus,F
	btfss STATUS,Z ;if zero then Cycle Tmr WaterStatus=IDLE
	Goto ORThem
;Cycle IDle then Return ABS
	movwf WaterStatus
	Goto ExitWaterStatusFlowChart
ORThem:
	; Give always priority to the Repetive timer.
	; WaterSatus set by the Rep timer Changes only when it's status is Drain
	; and the ABS timer sets the status to Flood. In every other case it
	; stays unchanged. That's why it is OR'ed
	comf WaterStatus,F
	iorwf WaterStatus,F 
	Goto ExitWaterStatusFlowChart
ABS_Idle:
	comf WaterStatus,F
	btfsc STATUS,Z ;if zero then Cycle Tmr WaterStatus=IDLE
	Goto Cycle_Idle 
	comf WaterStatus,F  ; Returns CycleTimer's original Water Status
	Goto ExitWaterStatusFlowChart
Cycle_Idle:
	;both are Idle
	movlw Idle
	movwf WaterStatus
ExitWaterStatusFlowChart:
	Clrf INTFlag		;
	bsf INTCON,GIE
	;Re-enable Interrupts


LoopCont:

	movlw High UFSwVar
	movwf PCLATH
	;pagesel UFSwVar
	Call UFSwVar
	Pagesel $
	Call EEPROM_Read
	;movlw 4
	movwf UFSwDelay

	movlw High LFSwVar
	movwf PCLATH
	Call LFSwVar
	Pagesel $
	Call EEPROM_Read
	;movlw 4
	movwf LFSwDelay

	Call CheckWaterStatus

	movf StateMachine,W
	xorlw 0x03
	btfsc STATUS,Z
	Call InitialSCR 


	movf KeyPressed,W
	btfSS STATUS,Z
	goto $+2
	goto MenuLoop

	movf KeyPressed,W ; Check For Esc & Up
	xorlw UpEsc
	BTFSC STATUS,Z
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call UpAndEsc
	Goto MenuLoop

	movf KeyPressed,W ; Check For Enter & UP
	xorlw UpEnter	
	BTFSC STATUS,Z
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call IncContrast
	Goto MenuLoop

	movf KeyPressed,W ; Check For Enter & Down
	xorlw DownEnter	
	BTFSC STATUS,Z
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call DecContrast
	Goto MenuLoop

	BTFSC KeyPressed,RB6
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call KeyDown
	Goto MenuLoop

	BTFSC KeyPressed,RB7
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call KeyUp
	Goto MenuLoop

	BTFSC KeyPressed,RB4
	goto $+2
	goto $+4
	Clrf KeyPressed
	Call KeyEnter
	Goto MenuLoop

	BTFSC KeyPressed,RB5
	goto $+2
	goto $+3
	Clrf KeyPressed
	Call KeyExit
goto MenuLoop



; ------------------------------------ 
; Key Down
; Choose routine to execute based on StateMachine
;
; Use of Pagesel & PageselW directives
; When a Call or Goto is performed, PCLATH bits 4:3 are loaded to indicate the memory page ( 00,01,10,11 : up to 4 memory  
; pages) and the rest 11 bits, bits 10:0 are loaded to PC (13 bit addressing). Pagesel,uses BSF and BCF commands to set bits 4:3 of PCLATH 
; so we can use it before any far call or far goto, to be sure that the Program Counter will be on the right memory page.
; If we want to make a computed jump (computed goto) by altering PCL register, then we need to also fix 3 more bits,
; PCLATH bits 2:0 (so all PCLATH). Thus we can not use Pagesel. Instead, we can manually set PCLATH either using Movwf
; instructions or by use of PageselW which does the same thing (uses WREG Commands istead of BCF/BSF) .
; Why this shit happens....
; Since PIC16 have 14 bit commands and Call & Goto commands, allocate 11 bits to hold the memory address and 3 bits to be self expressed 
; (see table 15-2), then we need additional 2 bits to create a 13-bit address. These 2 bits are PCLATH 4:3.
; 
; ------------------------------------ 
KeyDown
	PageselW KeyDownRoutineTable
	movlw Low KeyDownRoutineTable
	Addwf StateMachine,W
	Btfsc STATUS,C
	incf PCLATH
	movwf PCL
KeyDownRoutineTable
	Goto ScrollDown	;State Machine=0
	Goto MoveLeft 	;State Machine=1
	Goto DecVariable;State Machine=2
	Return 			;State Machine=3
	Goto BacktoMenu	;State Machine=4
	Goto MoveLeft 	;State Machine=5

; ------------------------------------ 
; Key Up
; Choose routine to execute based on StateMachine
; ------------------------------------ 
KeyUp
	PageselW KeyUpRoutineTable
	movlw Low KeyUpRoutineTable
	Addwf StateMachine,W
	Btfsc STATUS,C
	incf PCLATH
	movwf PCL
KeyUpRoutineTable
	Goto ScrollUp    ;State Machine=0
	Goto MoveRight   ;State Machine=1
	Goto IncVariable ;State Machine=2
	Return			 ;State Machine=3
	Goto BacktoMenu  ;State Machine=4
	Goto MoveRight   ;State Machine=5

; ------------------------------------ 
; Key Enter
; Choose routine to execute based on StateMachine
; ------------------------------------ 
KeyEnter
	PageselW KeyEnterRoutineTable
	movlw Low KeyEnterRoutineTable
	Addwf StateMachine,W
	Btfsc STATUS,C
	incf PCLATH
	movwf PCL
KeyEnterRoutineTable
	Goto EnterSub 		;State Machine=0
	Goto EnterVariable  ;State Machine=1
	Goto ExitVariable 	;State Machine=2
	Return 				;State Machine=3
	Goto BacktoMenu 	;State Machine=4
	Goto EnterVariable  ;State Machine=5

; ------------------------------------ 
; Key Esc
; Choose routine to execute based on StateMachine
; ------------------------------------ 
KeyExit
	Pageselw KeyExitRoutineTable
	movlw Low KeyExitRoutineTable
	Addwf StateMachine,W
	Btfsc STATUS,C
	incf PCLATH
	movwf PCL
KeyExitRoutineTable
	Goto ExitSub		;State Machine=0
	Goto BacktoMenu		;State Machine=1
	Goto ExitVariable	;State Machine=2
	Return  			;State Machine=3
	Goto BacktoMenu 	;State Machine=4
	Goto UpdateDS1307	;State Machine=5
	

; ------------------------------------ 
; Routines Table
; W must hold the Routine's Number
; ------------------------------------ 
Routines
	movwf tmp2
	Pageselw RoutinesTable
	movlw Low RoutinesTable
	Addwf tmp2,W
	Btfsc STATUS,C
	incf PCLATH
	movwf PCL
RoutinesTable
	Return				;0
	Return				;1
	Return				;2
	Goto LoadTime		;3
	Goto SaveTime		;4
	Goto Exit2Main		;5
	Goto ManualFlood	;6
	Goto ManualDrain	;7
	Goto ManualIdle		;8 


; ------------------------------------ 
; Up and Esc Key Strokes
; Enters to the Menu tree
; ------------------------------------ 
UpAndEsc
	Movlw 0x03
	xorwf StateMachine,W
	Btfss STATUS,Z
	return
	
	movlw 0x01
	movwf Menu
	movwf Line
	movwf OldLine
	movwf OldMenu
	clrf StateMachine
	clrf MenuDepth
	Call ReadMenuTable
	Call ScrollUp
return

;Info
;	clrf ESC_Hold
;KeyLoop:
;	BTFSC KeyPressed,RB5 ; Esc
;	goto ESC_Pressed
;	Return
;ESC_Pressed:
;	BCF STATUS,C
;	movlw .80
;	subwf ESC_Hold,W
;	btfss STATUS,C
;	goto KeyLoop	
;	Call ManualIdle	
;return


IncContrast
	Movlw 0x03
	xorwf StateMachine,W
	Btfss STATUS,Z
	return

	movf CCPR1L,W
	xorlw (15* 0x0A)
	btfsc STATUS,Z
	Return
	movlw 0x05
	addwf CCPR1L
return

DecContrast
	Movlw 0x03
	xorwf StateMachine,W
	Btfss STATUS,Z
	return

	movf CCPR1L,W
	btfsc STATUS,Z
	Return
	movlw 0x05
	subwf CCPR1L
return

InitialSCR
	Call ShowTimeAndStatus
	movlw LCD_Line2
	call LCD_cmd
	movlw '['
	Call LCD_chr
	;movlw 0x03
	;Call LCD_chr
	movlw LCD_Line2+.2
	call LCD_cmd
	movlw ']'
	Call LCD_chr
	movlw '-'
	Call LCD_chr
	movlw '['
	Call LCD_chr
	movlw LCD_Line2+.15
	call LCD_cmd
	movlw ']'
	Call LCD_chr
	
	Call ShowActiveAlarms

return


; ------------------------------------ 
; Scroll Down LCD Menu
; on 2x16 LCD Display
; ------------------------------------ 
ScrollDown
	Movf Line,W
	xorlw 0x02 ; MaxLines in LCD
	Btfss STATUS,Z
	incf Line


	movf Menu_POS,W
	addlw 0x01 ; if Menu_POS=FF (UI - Lower Item) then FF+1=0
	btfsc STATUS,Z
	decf Menu

	movf Menu,W
	Call ReadMenuTable
	movlw LCD_Line1
	call LCD_cmd
	call LCD_MenuMsg


	incf Menu
	movf Menu,W
	call ReadMenuTable
	movlw LCD_Line2
	call LCD_cmd
	call LCD_MenuMsg	
	
	
	call PrintArrowLine2
return

; ------------------------------------ 
; Scroll UP LCD Menu
; on 2x16 LCD Display
; ------------------------------------ 
ScrollUp
	Movf Line,W
	xorlw 0x01 ; Is it the first Line in LCD
	Btfss STATUS,Z
	decf Line ;if not, then dec Line

	movf Menu_POS,W
	btfsc STATUS,Z
	incf Menu


	movf Menu,W	
	Call ReadMenuTable
	movlw LCD_Line2
	call LCD_cmd
	call LCD_MenuMsg	
	
	movlw LCD_Line1
	call LCD_cmd
	decf Menu
	movf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg

	call PrintArrowLine1
return


; ------------------------------------ 
; Enter LCD submenu
; 
; ------------------------------------ 
EnterSub

	;check if there is a routine to call
	movf Menu_RoutineOnEnter,W
	Call Routines

	Incf Menu_ExtMenuSegment,W
	btfss STATUS,Z
	call PopulateExtendedMenu

	Incf Menu_MenuOnEnter,W ; if ND= 0xFF then FF+1=0, so returns
	btfsc STATUS,Z
	Return
	
	
	BankiSel OldLine
	movlw OldLine
	addwf MenuDepth,W
	movwf FSR
	movf Line,W 
	movwf INDF	;Save Old Line
	
	movlw OldMenu
	addwf MenuDepth,W
	movwf FSR
	movf Menu,W 
	movwf INDF	;Save Old Menu
	incf MenuDepth 


	movlw 0x01
	movwf Line
	movf Menu_MenuOnEnter,W
	movwf Menu

	movlw LCD_Line2
	call LCD_cmd
	
	incf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg

	movlw LCD_Line1
	call LCD_cmd
	movf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg

	call PrintArrowLine1

return


; ------------------------------------ 
; Exit LCD SubMenu
; 
; ------------------------------------ 
ExitSub
	movf MenuDepth,W
	BTFSC STATUS,Z
	return
	decf MenuDepth 
	
	bankisel OldLine
	movlw OldLine
	addwf MenuDepth,W
	movwf FSR
	movf INDF,W
	movwf Line ;Restore Old Line

	movlw OldMenu
	addwf MenuDepth,W
	movwf FSR
	movf INDF,W
	movwf Menu ;Restore Old Menu
	call ReadMenuTable
	Goto RefreshScreen
return

RefreshScreen
	movlw 0x01
	xorwf Line,W
	btfsc STATUS,Z
	goto LastLine1
	goto LastLine2

LastLine1
	movlw LCD_Line2
	call LCD_cmd
	incf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg

	movlw LCD_Line1
	call LCD_cmd
	movf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg
	call PrintArrowLine1
	return

LastLine2
	movlw LCD_Line1
	call LCD_cmd
	decf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg

	movlw LCD_Line2
	call LCD_cmd
	movf Menu,W
	call ReadMenuTable
	call LCD_MenuMsg
	call PrintArrowLine2
return

PrintArrowLine1
	movlw LCD_Line1 + 0x0f
	call LCD_cmd
	movlw b'01111111'
	call LCD_chr
return

PrintArrowLine2
	movlw LCD_Line2 + 0x0f
	call LCD_cmd
	movlw b'01111111'
	call LCD_chr
return


; ------------------------------------ 
; Enter Variable
; Changes Cursor to Blinking and allows user
; to change variables values
; Changes State Machine to 2
; ------------------------------------ 
EnterVariable
	movf StateMachine,W
	movwf OldStateMachine
	movlw 0x02
	movwf StateMachine
	movlw LCD_Blinc	
	call LCD_cmd
return

; ------------------------------------ 
; Exit Variable
; Changes Cursor to Underlined and allows user
; to move accross variables
; Changes State Machine to 1
; ------------------------------------ 
ExitVariable
	movf OldStateMachine,W
	movwf StateMachine
	movlw LCD_Underline
	call LCD_cmd
return

; ------------------------------------ 
; Back to Menu tree
; If data are changed then save Data to EEPROM
; and return to menu tree
; changes StateMachine to 0
; ------------------------------------ 
BacktoMenu
	movf ChangeFlag,F
	btfss STATUS,Z	
	call WriteDatatoEEPROM

	
	movlw b'00001100'
	call LCD_cmd

	movlw LCD_CursorHome
	call LCD_cmd

	movlw LCD_DisOn
	call LCD_cmd

	clrf StateMachine
	Call ExitSub
	clrf ChangeFlag
return
	
UpdateDS1307
	movlw LCD_DisOn
	call LCD_cmd

	Call SaveTime
	clrf StateMachine
	Call ExitSub
	clrf ChangeFlag
	
return



; ------------------------------------ 
; Increase Variables
; Works when StateMachine=1
; ------------------------------------ 
IncVariable
	movlw 0x01
	movwf ChangeFlag

	movlw EEPROM_Data
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf i; holds the last value

	movlw EEPROM_Max
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	xorwf i,W
	btfss STATUS,Z ;check if i=Max
	Goto IncVar 
	
	movlw EEPROM_Min
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf i ; i holds the min value
	goto $+2
IncVar
	incf i
	movlw EEPROM_Data
	addwf RelativeColumn,W
	movwf FSR
	movf i,W
	movwf INDF
	Call PrintLCDVariable ; w holds the value to be displayed
return

; ------------------------------------ 
; Decrease Variables
; Works when StateMachine=1
; ------------------------------------ 
DecVariable
	movlw 0x01
	movwf ChangeFlag

	movlw EEPROM_Data
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf i; holds the last value

	movlw EEPROM_Min
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	xorwf i,W
	btfss STATUS,Z ;check if i=Max
	Goto DecVar ;

	movlw EEPROM_Max
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf i ; i holds the maxn value
	goto $+2
DecVar
	decf i
	movlw EEPROM_Data
	addwf RelativeColumn,W
	movwf FSR
	movf i,W
	movwf INDF
	
	Call PrintLCDVariable
return

; ------------------------------------ 
; Move cursor right
; RelativeColumn should hold the proper value
; CursorPos should hold the cursor places on line 1 eg. {1,3,6)
; RelativeColumn is used like an index for the CursorPos
; ------------------------------------ 
MoveRight
	incf RelativeColumn
	movf ExtMenu_VarNum,W
	clrf STATUS
	xorwf RelativeColumn,W
	btfsc STATUS,Z 
	clrf RelativeColumn

	banksel CursorPos
	movlw CursorPos; W holds the address of CursorPos
	Banksel RelativeColumn
	addwf RelativeColumn,W ; CursorPos=+RelativeColumn
	movwf FSR
	movf INDF,W
	movwf Column
	call LCD_cmd
	movlw LCD_Underline
	call LCD_cmd
return

; ------------------------------------ 
; Move cursor Left
; RelativeColumn should hold the proper value
; CursorPos should hold the cursor places on line 1 eg. {1,3,6)
; RelativeColumn is used like an index for the CursorPos
; ------------------------------------ 
MoveLeft
	movf RelativeColumn,W
	btfss STATUS,Z ; check if=0
	Goto MoveBack
	decf ExtMenu_VarNum,W
	movwf RelativeColumn
	goto $+2
MoveBack
	decf RelativeColumn

	banksel CursorPos
	movlw CursorPos; W holds the address of CursorPos
	Banksel RelativeColumn
	addwf RelativeColumn,W ; CursorPos=+RelativeColumn
	movwf FSR
	movf INDF,W
	movwf Column
	call LCD_cmd
	movlw LCD_Underline
	call LCD_cmd
return


; ------------------------------------ 
; Exit to Main Screen
; ------------------------------------ 
Exit2Main
	clrf KeyPressed
	movlw 0x03
	movwf StateMachine
	;clrf WaterStatus
	movlw LCD_Clear
	call LCD_cmd
return



LoadTime
	;Read Current Time
	Call Read_DS1307

	;Store Current Hour in EEPROM
	movf HOUR,W
	Call Bcd2Hex
	Banksel EEDATA
	movwf EEDATA
	movlw .50
	movwf EEADR
	Banksel 0
	Call EEPROM_Write

	;Store Current Min in EEPROM
	movf MIN,W
	Call Bcd2Hex
	Banksel EEDATA
	movwf EEDATA
	movlw .51
	movwf EEADR
	Banksel 0
	Call EEPROM_Write

	;Store Current SEC in EEPROM
	movf SEC,W
	Call Bcd2Hex
	Banksel EEDATA
	movwf EEDATA
	movlw .52
	movwf EEADR
	Banksel 0
	Call EEPROM_Write
return

SaveTime
	movf ChangeFlag,f
	btfss STATUS,Z	
	goto $+2
	return

	bankisel EEPROM_Data
	movlw EEPROM_Data; Set FSR to point 
	movwf FSR		 ;
	movf INDF,W
	Call Hex2Dec
	movf BCD,W
	movwf HOUR

	incf FSR
	movf INDF,W		
	Call Hex2Dec
	movf BCD,W
	movwf MIN

	incf FSR
	movf INDF,W
	Call Hex2Dec
	movf BCD,W
	movwf SEC
	Call Write_DS1307
return



; ------------------------------------ 
; Manual Flood
; Sets Flood Pump On
; and stays in loop until keypressed
; ------------------------------------ 
ManualFlood
	;clear LCD
	movlw LCD_Clear
	call LCD_cmd
	movlw Low FloodingText
	movwf TextOffset
	movlw High FloodingText
	movwf TextSegment
	call LCD_msg
FloodLoop
	bcf DrainPump
	nop
	nop
	nop
	nop
	bsf FloodPump
FloodLoop2:
;	movf KeyPressed,W
BTFSs KeyPressed,RB5
	;btfSC STATUS,Z
	goto FloodLoop2
	movlw 0x10 
	call Delay ;

	movlw LCD_Clear
	call LCD_cmd
	Call ClearPumps
	clrf KeyPressed
	goto RefreshScreen

; ------------------------------------ 
; Manual Drain
; Sets Drain Pump On
; and stays in loop until keypressed
; ------------------------------------ 
ManualDrain
	;clear LCD
	movlw LCD_Clear
	call LCD_cmd
	movlw Low DrainingText
	movwf TextOffset
	movlw High DrainingText
	movwf TextSegment
	call LCD_msg
	clrf KeyPressed
DrainLoop
	bcf FloodPump
	nop
	nop
	nop
	nop
	bsf DrainPump
DrainLoop2:
;	movf KeyPressed,W
BTFSs KeyPressed,RB5
	;btfSC STATUS,Z
	goto DrainLoop2

	movlw 0x10 
	call Delay ;

	movlw LCD_Clear
	call LCD_cmd
	Call ClearPumps
	clrf KeyPressed
	goto RefreshScreen


; ------------------------------------ 
; Manual Idle
; Sets Drain Pump On
; and stays in loop until keypressed
; ------------------------------------ 
ManualIdle
	;clear LCD
	movlw LCD_Clear
	call LCD_cmd
	movlw Low IdlingText
	movwf TextOffset
	movlw High IdlingText
	movwf TextSegment
	call LCD_msg
	clrf KeyPressed

	bcf FloodPump
	Goto $+1
	Goto $+1
	bcf DrainPump
IdleLoop:
;	movf KeyPressed,W
BTFSs KeyPressed,RB5
	;btfSC STATUS,Z
	goto IdleLoop

	movlw 0x10 
	call Delay ;

	movlw LCD_Clear
	call LCD_cmd
	Call ClearPumps
	clrf KeyPressed
	goto RefreshScreen



; ------------------------------------ 
; Clear Pumps
; Sets Flood Pump Off
; Sets Drain Pump Off
; it is called only from Manual Drain & Flood
; ------------------------------------ 
ClearPumps
	movf WaterStatus,W
	btfss STATUS,Z ;0=Drain 1=Flood
	Goto $+3
	bcf FloodPump
	return
	bcf DrainPump	
return

; ------------------------------------ 
; Populate Extended Menu
;
; ------------------------------------ 
PopulateExtendedMenu
	;Load Extended Menu Table in ExtMenuItem Variable
	movf Menu_ExtMenuOffset,W
	movwf ExtMenuItem_Offset
	movf Menu_ExtMenuSegment,W
	movwf ExtMenuItem_Segment
	Call ReadExtMenuItem

	;Set StateMachine
	movf ExtMenu_StateMachine,W
	movwf StateMachine

	;Fix the restore point for when ESC is pressed. Same a in EnterSub
	BankiSel OldLine
	movlw OldLine
	addwf MenuDepth,W
	movwf FSR
	movf Line,W 
	movwf INDF	;Save Old Line
	movlw OldMenu
	addwf MenuDepth,W
	movwf FSR
	movf Menu,W 
	movwf INDF	;Save Old Menu
	incf MenuDepth 
	Banksel 0

	;Read Variables Table
	movf ExtMenu_VarSegment,W
	movwf VarTbl_PCLATH
	movf ExtMenu_VarOffset,W
	movwf VarTbl_PCL
	movf ExtMenu_VarNum,W
	Call ReadVarTable

	;Read Cursor Position Table
	Call ReadCursorTbl

	;clear LCD
	movlw LCD_Clear
	call LCD_cmd
	;Print Again Menu Line
	movlw LCD_Line1
	call LCD_cmd
	movf Menu,W
	call LCD_MenuMsg

	;Print Extended Menus Text
	movf ExtMenu_TextOffset,W
	movwf TextOffset
	movf ExtMenu_TextSegment,W
	movwf TextSegment
	call LCD_msg
	

	clrf RelativeColumn
	Call RefreshLCD

	movlw 0xFF
	movwf RelativeColumn
	call MoveRight
return


;SetUFSwDelay
;	bankisel EEPROM_Data
;	movlw EEPROM_Data; Set FSR to point 
;	movwf FSR
;	movf INDF,W
;	movwf UFSwDelay
;return

;SetLFSwDelay
;	bankisel EEPROM_Data
;	movlw EEPROM_Data; Set FSR to point 
;	movwf FSR
;	movf INDF,W
;	movwf LFSwDelay
;return

; ------------------------------------ 
; LCD Menu Message / Lcd Message
; Before been called, MenuItem should be adjusted
; ------------------------------------ 
LCD_MenuMsg
	Movf Menu_TextOffset,W
	movwf TextOffset	
	Movf Menu_TextSegment,W
	movwf TextSegment	
LCD_msg
	Movf TextOffset,W
	Movwf LCD_tmp  ;hold the offset of the text label in Lcd_tmp
	movlw High LCD_MenuMsg_Loop
	movlw 0x0
	movwf Counter
	clrf Flag
LCD_MenuMsg_Loop	
	Call LCD_Text
	pagesel $
	movwf W_Old

	movf Flag,F
	btfss STATUS,Z
	Goto SetCursor	

	movf W_Old,W
	xorlw '%';is it a zero?
	btfss STATUS, Z
	Goto PrintCHR
	Goto FlagOn

SetCursor
	movf W_Old,W
	call LCD_cmd
	clrf Flag
	goto NextCHR

FlagOn
	movlw 1
	movwf Flag
	goto NextCHR

PrintCHR
	movf W_Old,W
	btfsc STATUS, Z
	goto $+7
	call LCD_chr

NextCHR
	incf Counter
	incf LCD_tmp, F ; check if LCD_tmp exceed the page limit
	btfsc STATUS,Z	; if so then increase TextSegment by 
	incf TextSegment
	
	goto LCD_MenuMsg_Loop	
;Send blanc chars to fill screen, in case message < 16 characters
	clrf STATUS
	movlw 0x10
	subwf Counter,W
    btfss STATUS, C
	goto $+2
	Return
	incf Counter	
	movlw 0x20
	call LCD_chr
	goto $-8
LCD_Text
	movf TextSegment,W  ; get the segment of the Text block (address H700:Hxxxx)
	movwf PCLATH ;set the segment
	movf LCD_tmp,W
	movwf PCL
return




end

