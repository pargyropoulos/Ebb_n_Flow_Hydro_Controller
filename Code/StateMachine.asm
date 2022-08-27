include "P16F648A.inc"  ;include the defaults for the chip
errorlevel 2
GLOBAL KeyDown
GLOBAL KeyUp
GLOBAL KeyEnter
GLOBAL KeyExit
GLOBAL KeyUpEsc

Extern StateMachine
Extern ScrollDown
Extern MoveLeft 
Extern DecVariable 
Extern IncContrast
Extern ScrollUp   
Extern MoveRight  
Extern IncVariable
Extern EnterSub
Extern EnterVariable
Extern ExitVariable 
Extern ExitSub
Extern BacktoMenu
Extern UpAndEsc

PROG1 code

end