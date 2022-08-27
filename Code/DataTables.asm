#Define UI 0x00	;Upper Item
#Define MI 0x01	;Middle Item
#Define LI 0x0ff;Lower Item
#Define ND 0x0ff; No Data


;Will be this in future version
; Menu Items Data Table
;Byte1: Menu Position - (Upper , Middle ,Lower)
;Byte2: Menu on Enter
;Byte3: Pointer to RoutineOneEntrer Table
;Byte4: Pointer to TextString Table
;Byte5: Pointer to SecondaryTextString Table
;Byte6: Pointer to Variable Table
;Byte7: Pointer to Cursor Table
;Byte8: Upper Nibble:State Machine - Lower Nibble: Number Of Variables

; comments
; menu position is not needed. State machine should change for upper & lower menu, to not allow further movement on button press
; so 'byte 1' should be "state machine to allow up to 256 state transitions.
;
;

PROG2 Code
; ------------------------------------ 
; Menu Items Data Table
;Byte1: Menu Position (Upper , Middle ,Lower)
;Byte2: Menu on Enter
;Byte3: Routine One Enter - Pointer to Table
;Byte4: Pointer to Text String - PCL
;Byte5: Pointer to Text String - PCLATH
;Byte6: Pointer to Extended Variable Table - PCL
;Byte7: Pointer to Extended Variable Table - PCLATH
;Byte8: Reserved
; ------------------------------------ 
MenuItemTbl
;Initial Menu
Menu1  dt	UI, ND, 3, low M1, High M1,Low Set_Time, High Set_Time,ND  	;Set Clock
Menu2  dt   MI, .6, 0, low M2, High M2,ND,ND,ND 						;Set Timers
Menu3  dt   MI,.53, 0, low M3, High M3,ND,ND,ND							;Set FS Delay
Menu4  dt   MI,.55, 0, low M4, High M4,ND,ND,ND   						;Manual Operation
Menu5  dt   LI,	ND, 5, low M5, High M5,ND,ND,ND		;Exit
;Menu666 dt  LI,ND, 5, low M666, High M666,ND,ND,ND		;Exit

;Timers
Menu6  dt  UI, .8 ,0 ,low M6,High M6,ND,ND,ND ; Cycle Timer
Menu7  dt  LI,.13 ,0 ,low M7,High M7,ND,ND,ND ; Absolute Timer

;Cycle Timer
Menu8  dt  UI,ND,0, low M8 ,High  M8,Low Cycle_Tmr_Status ,High Cycle_Tmr_Status,ND
Menu9  dt  MI,ND,0, low M9 ,High  M9,Low Cycle_Tmr_Start  ,High Cycle_Tmr_Start ,ND
Menu10 dt  MI,ND,0, low M10,High M10,Low Cycle_Tmr_Stop   ,High Cycle_Tmr_Stop  ,ND
Menu11 dt  MI,ND,0, low M11,High M11,Low Cycle_Tmr_Flood  ,High Cycle_Tmr_Flood ,ND
Menu12 dt  LI,ND,0, low M12,High M12,Low Cycle_Tmr_Drain  ,High Cycle_Tmr_Drain ,ND

;Absolute Timers
Menu13 dt	UI,.23,0, low M13 ,High M13 ,ND,ND,ND ;1
Menu14 dt	MI,.26,0, low M14 ,High M14 ,ND,ND,ND ;2
Menu15 dt 	MI,.29,0, low M15 ,High M15 ,ND,ND,ND ;3
Menu16 dt 	MI,.32,0, low M16 ,High M16 ,ND,ND,ND ;4
Menu17 dt 	MI,.35,0, low M17 ,High M17 ,ND,ND,ND ;5
Menu18 dt 	MI,.38,0, low M18 ,High M18 ,ND,ND,ND ;6
Menu19 dt 	MI,.41,0, low M19 ,High M19 ,ND,ND,ND ;7
Menu20 dt 	MI,.44,0, low M20 ,High M20 ,ND,ND,ND ;8
Menu21 dt 	MI,.47,0, low M21 ,High M21 ,ND,ND,ND ;9
Menu22 dt 	LI,.50,0, low M22 ,High M22 ,ND,ND,ND ;10

;tmr1
Menu23 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr1_Status ,High ExtMI_Tmr1_Status,ND
Menu24 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr1_Flood  ,High ExtMI_Tmr1_Flood,ND
Menu25 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr1_Drain  ,High ExtMI_Tmr1_Drain,ND
;tmr2
Menu26 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr2_Status ,High ExtMI_Tmr2_Status,ND
Menu27 dt 	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr2_Flood  ,High ExtMI_Tmr2_Flood,ND
Menu28 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr2_Drain  ,High ExtMI_Tmr2_Drain,ND
;tmr3
Menu29 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr3_Status ,High ExtMI_Tmr3_Status,ND
Menu30 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr3_Flood  ,High ExtMI_Tmr3_Flood,ND
Menu31 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr3_Drain  ,High ExtMI_Tmr3_Drain,ND
;tmr4
Menu32 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr4_Status ,High ExtMI_Tmr4_Status,ND
Menu33 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr4_Flood  ,High ExtMI_Tmr4_Flood,ND
Menu34 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr4_Drain  ,High ExtMI_Tmr4_Drain,ND
;tmr5
Menu35 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr5_Status ,High ExtMI_Tmr5_Status,ND
Menu36 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr5_Flood  ,High ExtMI_Tmr5_Flood,ND
Menu37 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr5_Drain  ,High ExtMI_Tmr5_Drain,ND
;tmr6
Menu38 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr6_Status ,High ExtMI_Tmr6_Status,ND
Menu39 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr6_Flood  ,High ExtMI_Tmr6_Flood,ND
Menu40 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr6_Drain  ,High ExtMI_Tmr6_Drain,ND
;tmr7
Menu41 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr7_Status ,High ExtMI_Tmr7_Status,ND
Menu42 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr7_Flood  ,High ExtMI_Tmr7_Flood,ND
Menu43 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr7_Drain  ,High ExtMI_Tmr7_Drain,ND
;tmr9
Menu44 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr8_Status ,High ExtMI_Tmr8_Status,ND
Menu45 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr8_Flood  ,High ExtMI_Tmr8_Flood,ND
Menu46 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr8_Drain  ,High ExtMI_Tmr8_Drain,ND
;tmr9
Menu47 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr9_Status ,High ExtMI_Tmr9_Status,ND
Menu48 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr9_Flood  ,High ExtMI_Tmr9_Flood,ND
Menu49 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr9_Drain  ,High ExtMI_Tmr9_Drain,ND
;tmr10
Menu50 dt	UI,ND,0, low StatusTxt,High StatusTxt,Low ExtMI_Tmr10_Status ,High ExtMI_Tmr10_Status,ND
Menu51 dt	MI,ND,0, low FloodTxt ,High FloodTxt ,Low ExtMI_Tmr10_Flood  ,High ExtMI_Tmr10_Flood,ND
Menu52 dt	LI,ND,0, low DrainTxt ,High DrainTxt ,Low ExtMI_Tmr10_Drain  ,High ExtMI_Tmr10_Drain,ND

;Set FS Delay
Menu53 dt	UI,ND,0,low M53,High M53,Low Set_UFSw,High Set_UFSw,ND
Menu54 dt	LI,ND,0,low M54,High M54,Low Set_LFSw,High Set_LFSw,ND

;Manually Operate
Menu55 dt	UI,ND,.6,low M55,High M55,ND,ND,ND
Menu56 dt	MI,ND,.7,low M56,High M56,ND,ND,ND
Menu57 dt	LI,ND,.8,low M57,High M57,ND,ND,ND

; ------------------------------------ 
; Extended Menu Item Table
; Byte1: Number of Variables
; Byte2: Variable Table Offset
; Byte3: Variable Table Segment
; Byte4: Text Offset
; Byte5: Text Segment
; Byte6: Cursor Table Offset
; Byte7: Cursor Table Segment
; Byte8: State Machine
; ------------------------------------ 

Cycle_Tmr_Status	dt 1,Low CycleTmrVarS , High CycleTmrVarS  ,Low StatusText , High StatusText ,Low CursorOnOff,High CursorOnOff,1
Cycle_Tmr_Start		dt 2,Low CycleTmrVarSR, High CycleTmrVarSR ,Low TimeText  , High TimeText  ,Low CursorTime ,High CursorTime ,1
Cycle_Tmr_Stop		dt 2,Low CycleTmrVarSP, High CycleTmrVarSP ,Low TimeText   , High TimeText   ,Low CursorTime ,High CursorTime ,1
Cycle_Tmr_Flood 	dt 1,Low CycleTmrVarF , High CycleTmrVarF  ,Low MinText , High MinText ,Low CursorCycle ,High CursorCycle ,1
Cycle_Tmr_Drain 	dt 2,Low CycleTmrVarD , High CycleTmrVarD  ,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr1_Status dt 1,Low VarTbl_Tmr1S, High VarTbl_Tmr1S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr1_Flood  dt 2,Low VarTbl_Tmr1F, High VarTbl_Tmr1F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr1_Drain  dt 2,Low VarTbl_Tmr1D, High VarTbl_Tmr1D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
 
ExtMI_Tmr2_Status dt 1,Low VarTbl_Tmr2S, High VarTbl_Tmr2S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr2_Flood  dt 2,Low VarTbl_Tmr2F, High VarTbl_Tmr2F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr2_Drain  dt 2,Low VarTbl_Tmr2D, High VarTbl_Tmr2D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr3_Status dt 1,Low VarTbl_Tmr3S, High VarTbl_Tmr3S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr3_Flood  dt 2,Low VarTbl_Tmr3F, High VarTbl_Tmr3F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr3_Drain  dt 2,Low VarTbl_Tmr3D, High VarTbl_Tmr3D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr4_Status dt 1,Low VarTbl_Tmr4S, High VarTbl_Tmr4S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr4_Flood  dt 2,Low VarTbl_Tmr4F, High VarTbl_Tmr4F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr4_Drain  dt 2,Low VarTbl_Tmr4D, High VarTbl_Tmr4D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr5_Status dt 1,Low VarTbl_Tmr5S, High VarTbl_Tmr5S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr5_Flood  dt 2,Low VarTbl_Tmr5F, High VarTbl_Tmr5F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr5_Drain  dt 2,Low VarTbl_Tmr5D, High VarTbl_Tmr5D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr6_Status dt 1,Low VarTbl_Tmr6S, High VarTbl_Tmr6S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr6_Flood  dt 2,Low VarTbl_Tmr6F, High VarTbl_Tmr6F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr6_Drain  dt 2,Low VarTbl_Tmr6D, High VarTbl_Tmr6D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr7_Status dt 1,Low VarTbl_Tmr7S, High VarTbl_Tmr7S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr7_Flood  dt 2,Low VarTbl_Tmr7F, High VarTbl_Tmr7F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr7_Drain  dt 2,Low VarTbl_Tmr7D, High VarTbl_Tmr7D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr8_Status dt 1,Low VarTbl_Tmr8S, High VarTbl_Tmr8S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr8_Flood  dt 2,Low VarTbl_Tmr8F, High VarTbl_Tmr8F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr8_Drain  dt 2,Low VarTbl_Tmr9D, High VarTbl_Tmr8D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr9_Status dt 1,Low VarTbl_Tmr9S, High VarTbl_Tmr9S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr9_Flood  dt 2,Low VarTbl_Tmr9F, High VarTbl_Tmr9F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr9_Drain  dt 2,Low VarTbl_Tmr9D, High VarTbl_Tmr9D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

ExtMI_Tmr10_Status dt 1,Low VarTbl_Tmr10S, High VarTbl_Tmr10S,Low StatusText, High StatusText,Low CursorOnOff,High CursorOnOff,1
ExtMI_Tmr10_Flood  dt 2,Low VarTbl_Tmr10F, High VarTbl_Tmr10F,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1
ExtMI_Tmr10_Drain  dt 2,Low VarTbl_Tmr10D, High VarTbl_Tmr10D,Low TimeText , High TimeText ,Low CursorTime ,High CursorTime ,1

Set_Time dt 3,Low TimeVar, High TimeVar,Low ClockText , High ClockText ,Low CursorFullTime ,High CursorFullTime ,5
Set_UFSw dt 1,Low UFSwVar, High UFSwVar,Low DecText , High DecText ,Low CursorFSw ,High CursorFSw ,1
Set_LFSw dt 1,Low LFSwVar, High LFSwVar,Low DecText , High DecText ,Low CursorFSw ,High CursorFSw ,1



; ------------------------------------ 
; Variables Data Table
;Byte1: EEPROM address
;Byte2: Datatype
;Byte3: Min Value
;Byte4: Max Value
; ------------------------------------ 
VarTable
VarTbl_Tmr1F  	dt  .0,Decimal,0x00,0x17;hh
				dt  .1,Decimal,0x00,0x3b;mm
VarTbl_Tmr1D  	dt  .2,Decimal,0x00,0x17;hh
				dt  .3,Decimal,0x00,0x3b;mm
VarTbl_Tmr1S  	dt  .4,OnOff,0x00,0x01; On/Off

VarTbl_Tmr2F  	dt  .5,Decimal,0x00,0x17;hh
				dt  .6,Decimal,0x00,0x3b;mm
VarTbl_Tmr2D	dt  .7,Decimal,0x00,0x17;hh
				dt  .8,Decimal,0x00,0x3b;mm
VarTbl_Tmr2S  	dt  .9,OnOff,0x00,0x01; On/Off

VarTbl_Tmr3F  	dt  .10,Decimal,0x00,0x17;hh
				dt  .11,Decimal,0x00,0x3b;mm
VarTbl_Tmr3D	dt  .12,Decimal,0x00,0x17;hh
				dt  .13,Decimal,0x00,0x3b;mm
VarTbl_Tmr3S  	dt  .14,OnOff,0x00,0x01; On/Off

VarTbl_Tmr4F	dt  .15,Decimal,0x00,0x17;hh
				dt  .16,Decimal,0x00,0x3b;mm
VarTbl_Tmr4D  	dt  .17,Decimal,0x00,0x17;hh
				dt  .18,Decimal,0x00,0x3b;mm
VarTbl_Tmr4S  	dt  .19,OnOff,0x00,0x01; On/Off

VarTbl_Tmr5F  	dt  .20,Decimal,0x00,0x17;hh
				dt  .21,Decimal,0x00,0x3b;mm
VarTbl_Tmr5D  	dt  .22,Decimal,0x00,0x17;hh
				dt  .23,Decimal,0x00,0x3b;mm
VarTbl_Tmr5S  	dt  .24,OnOff,0x00,0x01; On/Off

VarTbl_Tmr6F  	dt  .25,Decimal,0x00,0x17;hh
				dt  .26,Decimal,0x00,0x3b;mm
VarTbl_Tmr6D	dt  .27,Decimal,0x00,0x17;hh
				dt  .28,Decimal,0x00,0x3b;mm
VarTbl_Tmr6S	dt  .29,OnOff,0x00,0x01; On/Off

VarTbl_Tmr7F 	dt  .30,Decimal,0x00,0x17;hh
				dt  .31,Decimal,0x00,0x3b;mm
VarTbl_Tmr7D 	dt  .32,Decimal,0x00,0x17;hh
				dt  .33,Decimal,0x00,0x3b;mm
VarTbl_Tmr7S  	dt  .34,OnOff,0x00,0x01; On/Off

VarTbl_Tmr8F  	dt  .35,Decimal,0x00,0x17;hh
				dt  .36,Decimal,0x00,0x3b;mm
VarTbl_Tmr8D  	dt  .37,Decimal,0x00,0x17;hh
				dt  .38,Decimal,0x00,0x3b;mm
VarTbl_Tmr8S	dt  .39,OnOff,0x00,0x01; On/Off

VarTbl_Tmr9F 	dt  .40,Decimal,0x00,0x17;hh
				dt  .41,Decimal,0x00,0x3b;mm
VarTbl_Tmr9D	dt  .42,Decimal,0x00,0x17;hh
				dt  .43,Decimal,0x00,0x3b;mm
VarTbl_Tmr9S 	dt  .44,OnOff,0x00,0x01; On/Off

VarTbl_Tmr10F	dt  .45,Decimal,0x00,0x17;hh
			    dt  .46,Decimal,0x00,0x3b;mm
VarTbl_Tmr10D	dt  .47,Decimal,0x00,0x17;hh
				dt  .48,Decimal,0x00,0x3b;mm
VarTbl_Tmr10S	dt  .49,OnOff,0x00,0x01; On/Off

TimeVar			dt  .50,Decimal,0x00,0x17   ;hh
			    dt  .51,Decimal,0x00,0x3b	;mm
			    dt  .52,Decimal,0x00,0x3b	;ss

UFSwVar			dt  .53,Decimal,0x00,.99	;sec
LFSwVar			dt  .54,Decimal,0x00,.99	;sec

CycleTmrVarS	dt	.55,OnOff  ,0x00,0x01;On/Off
CycleTmrVarSR	dt  .56,Decimal,0x00,0x17;hh
				dt  .57,Decimal,0x00,0x3b;mm
CycleTmrVarSP	dt  .58,Decimal,0x00,0x17;hh
				dt  .59,Decimal,0x00,0x3b;mm
CycleTmrVarF	dt  .60,Decimal,0x00,.99;
CycleTmrVarD	dt  .61,Decimal,0x00,.12; hh
				dt  .62,Decimal,0x00,.59; mm
; ------------------------------------ ;
; Cursor Position Table
; each byte refers to X position on line 1. Should end with 0xFF
; ------------------------------------ 
CursorTable
CursorTime 		dt 0xc2,0xc5
CursorFullTime 	dt 0xc2,0xc5,0xc8
CursorCycle
CursorFSw
CursorOnOff 	dt 0xc3
		

; ------------------------------------ 
; Text Table. Each text line must be terminated with 0 
; ------------------------------------ 
Text	
M1	dt "Set Clock",0
M2	dt "Set Timers",0
M3	dt "Set FSw Delay",0
M4	dt "Man. Operation",0
M5	dt "Exit",0
M6	dt "Set Cycle Timer",0
M7	dt "Set ABS Timers",0
M8 	dt "Set Status",0
M9	dt "Set Timer Start",0
M10	dt "Set Timer Stop",0
M11	dt "Set Flood Cycle",0
M12	dt "Set Drain Cycle",0
M13	dt "Set Timer 1",0
M14	dt "Set Timer 2",0
M15	dt "Set Timer 3",0
M16	dt "Set Timer 4",0
M17	dt "Set Timer 5",0
M18	dt "Set Timer 6",0
M19	dt "Set Timer 7",0
M20	dt "Set Timer 8",0
M21	dt "Set Timer 9",0
M22	dt "Set Timer 10",0
M53	dt "Set UFSw Delay",0
M54	dt "Set LFSw Delay",0
M55	dt "Manually Flood",0
M56	dt "Manually Drain",0
M57 dt "Set Idle",0

StatusTxt	dt "Set Status",0
FloodTxt	dt "Set Flood Time",0
DrainTxt	dt "Set Drain Time",0
TimeText	dt "%",0xc0,"[HH:MM]",0
DecText		dt "%",0xc0,"[000] Sec",0
MinText		dt "%",0xc0,"[000] Min",0
ClockText 	dt "%",0xc0,"[HH:MM:SS]",0
StatusText	dt "%",0xC0,"[ On]",0
FloodingText dt "%",0x80, "Flooding...",0
DrainingText dt "%",0x80, "Draining...",0
IdlingText dt "%",0x80, "Idling...",0

;M665	dt "Hydro+",0
;M666	dt "Firmware v4.40",0



BlancLine dt " ",0 ; dt produces multiple RETLW with byte -> retlw 'L', retlw 'E',retlw	'N'...
MYes 	dt "Yes",0
MNo 	dt "No",0
MOn		dt "ON",0
MOff	dt "OFF",0



