include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
Global EEPROM_Read
Global EEPROM_Write
Global WriteDatatoEEPROM

;From Main.asm
Extern EEPROM_Data
Extern EEPROM_Address
Extern ExtMenuItem



Temp_Variables Udata_OVR
tmp Res 1

SharedMem Udata
BankStatus res 1

#Define ExtMenu_VarNum	ExtMenuItem+0

PROG1 Code
; ------------------------------------ 
; Read EEPROM Data 
; W should hold the EEPROM address to read
; On Exit, W hold the read Data
; ------------------------------------ 
EEPROM_Read
	m_SaveBank BankStatus
	BankSel EEADR ; Bank 1	
	movwf EEADR    ; address to read
	bsf EECON1,RD   ; enable EEPROM read
	movf EEDATA,W  ; put data in W
	m_RestoreBank BankStatus
	;Banksel 0x00
return

; ------------------------------------ 
; Write EEPROM Data 
; EEPROM address =EEADR  (bank 1)
; EEPROM data    =EEDATA (bank 1)
; ------------------------------------ 
EEPROM_Write
	
	BankSel EEADR ; Bank 1	
	bsf EECON1,WREN
	BCF INTCON,GIE
	btfsc INTCON,GIE
	goto $-2

	movlw 0x55
	movwf EECON2
	movlw 0xAA
	movwf EECON2
	BSF EECON1,WR
	btfsc EECON1,WR ; very Important! if WR is not
	goto $-1		;cleared then another write is not possible. Clearance is made on hardware only!!!

	BCF STATUS,RP0 ; Bank 0
	BCF STATUS,RP1 ; Bank 0
	
	bsf INTCON,GIE
return

; ------------------------------------ 
; Write to EEPROM data stored in Bank1 
; ExtMenu_VarNum should hold the number of variables to write
; EEPROM_Address & EEPROM_Data sould hold the proper values
; ------------------------------------ 
WriteDatatoEEPROM
	clrf tmp
WriteEEPROMLoop
	Bankisel EEPROM_Data

	movlw EEPROM_Data; Set FSR to point 
	addwf tmp,W		 ; on EEPROM_Data+tmp
	movwf FSR		 ;
	movf INDF,W
	
	Banksel EEDATA
	movwf EEDATA
	Banksel 0;tmp
	
	Bankisel EEPROM_Address
	movlw EEPROM_Address; Set FSR to point 
	addwf tmp,W		 ; on EEPROM_Data+tmp
	movwf FSR		 ;
	movf INDF,W
	BankSel EEADR
	movwf EEADR
	Banksel tmp
	Call EEPROM_Write
	incf tmp 
	movf ExtMenu_VarNum,W
	xorwf tmp,W
	BTFSC STATUS,Z
	GOTO $+2
goto WriteEEPROMLoop
	;bsf INTCON,GIE ;enable Interrupts
return

end