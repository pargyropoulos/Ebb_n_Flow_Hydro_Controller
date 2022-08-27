include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
Extern LCD_cmd
Extern LCD_chr
Extern Hex2Dec

;Extern Variables
Extern RelativeColumn
Extern Column
Extern CursorPos
Extern Ones
Extern Tens
Extern EEPROM_Data
Extern EEPROM_DataType
Extern ExtMenuItem
Global PrintLCDVariable
Global RefreshLCD

Bank0 UDATA
c res 1
i res 1
tmp res 1

#Define ExtMenu_VarNum				    ExtMenuItem+0

PROG1 code
; ------------------------------------ 
; Print Variable to LCD 
; W holds the value to be displayed
; ------------------------------------ 
PrintLCDVariable
	movwf i ; save W - i has data to print

	;check datatype
	movlw EEPROM_DataType
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	xorlw Decimal
	btfsc STATUS,Z
	Goto DecDataType
	movf INDF,W
	xorlw YesNo 
	btfsc STATUS,Z
	Goto YesNoDataType
	Goto OnOffDataType


DecDataType
	movlw CursorPos
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf c ; holds the current column
	call LCD_cmd
	movf i,W
	call Hex2Dec 
	movlw 0x30
	addwf Ones,W
	call LCD_chr; print Ones
	
	decf c
	movf c,W
	call LCD_cmd
	movlw 0x30
	addwf Tens,W; Print Tens
	call LCD_chr
	return

YesNoDataType
return


OnOffDataType
	clrf STATUS
	movf i,W
	btfss STATUS,Z
	goto ReturnOn
	goto ReturnOff

ReturnOn
	movlw CursorPos
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf c ; holds the current column
	call LCD_cmd
	movlw 'N'
	call LCD_chr
	decf c
	movf c,W
	call LCD_cmd
	movlw 'O'
	call LCD_chr
	decf c
	movf c,W
	call LCD_cmd
	movlw ' '
	call LCD_chr
	movlw 0x02
	addwf c,W
	call LCD_cmd

return

ReturnOff
	movlw CursorPos
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	movwf c ; holds the current column
	call LCD_cmd
	movlw 'F'
	call LCD_chr
	decf c
	movf c,W
	call LCD_cmd
	movlw 'F'
	call LCD_chr
	decf c
	movf c,W
	call LCD_cmd
	movlw 'O'
	call LCD_chr
	movlw 0x02
	addwf c,W
	call LCD_cmd

return
; ------------------------------------ 
; Refreshes LCD print all variable values 
; ------------------------------------ 
RefreshLCD
	movf ExtMenu_VarNum,W
	btfsc STATUS,Z ; Check if there are any variables to load
	return

	clrf tmp
	movf RelativeColumn,W
	movwf tmp ; tmp holds the RelativeColumn
	clrf RelativeColumn

Loop
	movf ExtMenu_VarNum,W
	xorwf RelativeColumn,W
	btfsc STATUS,Z
	Goto RestoreRelativeColumn

	movlw CursorPos
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W 

	movlw EEPROM_Data
	addwf RelativeColumn,W
	movwf FSR
	movf INDF,W
	Call PrintLCDVariable
	incf RelativeColumn
	goto Loop
RestoreRelativeColumn
	movf tmp,W
	movwf RelativeColumn

return

end