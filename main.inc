include /masm32/include/masm32rt.inc
include /masm32/include/winmm.inc
includelib /masm32/lib/winmm.lib
include mrand.asm

Main proto
SetConsoleSize proto :WORD,:WORD
HideCursor	   proto 
gotoxy		   proto :DWORD,:DWORD
ErrorMessage proto DWErrorCode:DWORD,lpszFunction:PTR BYTE
SetColor					PROTO :DWORD
CheckPosition				PROTO :DWORD, :DWORD


	cBlack			=	0	
	cBlue			=	9	
	cCyan			=	11	
	cDarkBlue		=	1	
	cDarkCyan		=	3	
	cDarkGray		=	8	
	cDarkGreen		=	2	
	cDarkMagenta	=	5	
	cDarkRed		=	4	
	cDarkYellow		=	6	
	cGray			=	7
	cGreen			=	10	
	cMagenta		=	13	
	cRed			=	12	
	cWhite			=	15	
	cYellow			=	14
	cPanel			=   48
	cPause			=	192

.const
	MAX_WIDTH			equ	82
	MAX_HEIGTH			equ 35
	
.data
;szClick					db "Snd_Click",0
szClick				db "Res\Click.wav",0
szFruit				db "Res\Treasure.wav",0

