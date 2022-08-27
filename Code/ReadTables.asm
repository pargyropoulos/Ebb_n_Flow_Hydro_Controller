include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2

Global ReadVarTable
Global ReadExtMenuItem
Global ReadCursorTbl
Global ReadMenuTable

;From Main.asm
Extern EEPROM_Data
Extern EEPROM_Read
Extern EEPROM_Address
Extern EEPROM_DataType
Extern EEPROM_Min
Extern EEPROM_Max
Extern VarTbl_PCLATH
Extern VarTbl_PCL
Extern ExtMenuItem
Extern ExtMenuItem_Offset
Extern ExtMenuItem_Segment
Extern CursorPos
Extern MenuItem

;From DataTables.asm
Extern MenuItemTbl

#Define VarTbl_EEPROM	 VarTbl_Data+0
#Define VarTbl_Datatype	 VarTbl_Data+1
#Define VarTbl_Min		 VarTbl_Data+2
#Define VarTbl_Max		 VarTbl_Data+3

#Define ExtMenu_VarNum				ExtMenuItem+0
#Define ExtMenu_VarOffset			ExtMenuItem+1
#Define ExtMenu_VarSegment			ExtMenuItem+2
#Define ExtMenu_TextOffset			ExtMenuItem+3
#Define ExtMenu_TextSegment   		ExtMenuItem+4
#Define ExtMenu_CursorTblOffset		ExtMenuItem+5
#Define ExtMenu_CursorTblSegment	ExtMenuItem+6
#Define ExtMenu_StateMachine  		ExtMenuItem+7




Bank0 udata 
	VarTbl_Cnt Res 1
	VarTbl_Data  Res 0x04 ; holds the Variables' table

Temp_Variables UDATA_OVR
	Counter Res 1
	tmp Res 1
	Menu_tmp Res 1

PROG1 code
; ------------------------------------ 
; Read VarTBL table  
; on call W must hold the number of variables to read
; First, the Variable Table is read and then
; it is populated with the appropriate EEPROM data
; ------------------------------------ 
ReadVarTable
	movwf VarTbl_Cnt
	clrf tmp
VarTBLLoop
	Call VarTbl_Read ; one row at a time

	movlw EEPROM_Data; Set FSR to point 
	addwf tmp,W		 ; on EEPROM_Data+tmp
	movwf FSR		 ;

	movf VarTbl_EEPROM,W ; Load EEPROM address to W
	Call EEPROM_Read
	movwf INDF

	Call MoveToRam	
	incf tmp 
	movf VarTbl_Cnt,W
	xorwf tmp,W
	BTFSC STATUS,Z
	GOTO $+2
	goto VarTBLLoop
return

;Copies Data from VarTbl.* to EEPROM.* in Bank 1
MoveToRam
	movlw EEPROM_Address
	addwf tmp,W
	movwf FSR
	movf VarTbl_EEPROM,W
	movwf INDF

	movlw EEPROM_DataType
	addwf tmp,W
	movwf FSR
	movf VarTbl_Datatype,W
	movwf INDF

	movlw EEPROM_Min
	addwf tmp,W
	movwf FSR
	movf VarTbl_Min,W
	movwf INDF

	movlw EEPROM_Max
	addwf tmp,W
	movwf FSR
	movf VarTbl_Max,W
	movwf INDF
return



; ------------------------------------ 
; Read Variables Table
; Called only from ReadVarTable routine
; Reads the Variables Table from flash memory to set Variables' Min,Max,Datatype,EEPROM Addr
; VarTbl_PCLATH and VarTbl_PCL should hold the address of the table
; Results are stored in VarTbl_Data
; ------------------------------------ 
VarTbl_Read
	clrf Counter
	Bankisel VarTbl_Loop
	movlw 0x04 ;Structure of Variable Table is 4 bytes long
	movwf Counter
	movlw VarTbl_Data ; Hold data in VarTbl_Data
	movwf FSR
	movlw High VarTbl_Loop

VarTbl_Loop	
	Call VarTBL
	Pagesel $
	bankisel VarTbl_Data
	movwf INDF

	Incf VarTbl_PCL		; If next byte changes memory page
	btfsc STATUS,Z		; then increase PCLATH. 
	incf VarTbl_PCLATH  ; Status.Z is set when VarTBL becomes 0x00 from 0xFF
	incf FSR
	decf Counter
	btfsc STATUS,Z
	return
	goto VarTbl_Loop
VarTBL
	movf VarTbl_PCLATH,W  ; get the segment 
	movwf PCLATH          ; set the segment
	movf VarTbl_PCL,W	  ; get the offset
	movwf PCL
return


; ------------------------------------ 
; Read Extended Menu Table
; ------------------------------------ 
ReadExtMenuItem
	clrf Counter
	Bankisel ExtMenuItem
	movlw 0x08 ;Structure of ExtMenuItem Table is 8 bytes long
	movwf Counter
	movlw ExtMenuItem ; Hold data in ExtMenuItem
	movwf FSR
	movlw High ExtMenuItem_Loop
ExtMenuItem_Loop
	Call ExtMenuItemTbl
	pagesel $
	movwf INDF
	Incf ExtMenuItem_Offset	 ; If next byte changes memory page
	btfsc STATUS,Z		     ; then increase PCLATH. 
	incf ExtMenuItem_Segment  ; Status.Z is set when VarTBL becomes 0x00 from 0xFF
	incf FSR
	decf Counter
	btfsc STATUS,Z
	return
	goto ExtMenuItem_Loop
ExtMenuItemTbl
	movf ExtMenuItem_Segment,W  ; get the segment 
	movwf PCLATH          	   ; set the segment
	movf ExtMenuItem_Offset,W   ; get the offset
	movwf PCL
return

; ------------------------------------ 
; Read Cursor Table
; W should hold the offset of the CursorSet
; ------------------------------------ 
ReadCursorTbl
	clrf Counter
CursorLoop
	movlw CursorPos
	addwf Counter,W
	movwf FSR
	Call ReadCursorData
	Pagesel $
	movwf INDF

	movf INDF,W
	incf Counter
	movf ExtMenu_VarNum,W
	xorwf Counter,W
	btfsc STATUS,Z
	Goto $+2
	goto CursorLoop
return
ReadCursorData
	movf ExtMenu_CursorTblSegment,W
	movwf PCLATH
	movf ExtMenu_CursorTblOffset,W
	addwf Counter,W
	btfsc STATUS,C
	incf PCLATH
	movwf PCL

; ------------------------------------ 
; Read LCD Menu Table
; W = the menu item which corresponds to an 8 byte record on the MenuItemTbl, so 256/8=32 items in each memory block
; First we divide the menuitem by 32 to calculate PCLATH
; e.g. MenuItem=35 thus 35/32=1. So PCLATH will be increase by one memory block from the initial MenuItemTbl
; Then 35*8=280 and since we only use 1 byte to store data, then the new offset will be 24 (0001 1000).
; So new address = MenuItemTbl_PCLATH + 1 : MenuItemTbl_PCL + 24
; Max number of menus should be 0xff = 256. (because 256 x 8 = 2048 bytes = one memory page)
; ------------------------------------ 
ReadMenuTable
	Movwf Menu_tmp  ;hold the number of the menu
	Movwf tmp
	decf Menu_tmp,F ; decrease it by one
	decf tmp
	BCF STATUS,C
	rrf tmp 	; divide by 2
	BCF STATUS,C
	rrf tmp 	; divide by 4
	BCF STATUS,C
	rrf tmp 	; divide by 8
	BCF STATUS,C
	rrf tmp 	; divide by 16
	BCF STATUS,C
	rrf tmp		; divide by 32 (5 right rotations)
	BCF STATUS,C
	rlf Menu_tmp ; multiply by 8 to find the real offset (3 left rotations)
	BCF STATUS,C
	rlf Menu_tmp
	BCF STATUS,C
	rlf Menu_tmp
	Bankisel MenuItem 
	movlw MenuItem	; addr of Menuitem
	movwf FSR		; to FSR
	movlw 0x08		; 8 bytes to RAM
	movwf Counter
Mtbl_Loop
	Call ReadMenuItem
	movwf INDF ; indirrect RAM write!
	incf FSR
	incf Menu_tmp
	Pagesel $ ; fix PCLATH
	decfsz Counter
	goto Mtbl_Loop
return

ReadMenuItem
	Movlw High MenuItemTbl
	addwf tmp,W
	movwf PCLATH
	movlw Low MenuItemTbl
	addwf Menu_tmp,W
 	btfsc STATUS,C
	incf PCLATH
	movwf PCL
end