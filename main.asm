include main.inc
include obj_fruit.asm
include obj_snake.asm
include engine.asm
include StrProcs.asm
include interface.asm


.code
start:
	fn SetConsoleTitle, "Snake Demo"
	fn SetConsoleSize, MAX_WIDTH, MAX_HEIGTH
	fn HideCursor
	fn Main
	
	exit


Main proc
	fn MainMenu
	.while byte ptr[closeConsole] == 0
		fn GameInit
		.while byte ptr[gameOver] == 1
			
			fn GameUpdate
			
			fn GameController
			
		.endw
		
		.if closeConsole == 0
			call DeathScreen
		.endif
		
		fn MainMenu
	.endw
	
	fn gotoxy, 27, 34
	Ret
Main EndP

SetConsoleSize PROC uses ebx esi edi wd:WORD, ht: WORD
	LOCAL srect: SMALL_RECT
	fn GetStdHandle, -11
	push eax
	mov esi,eax
	mov word ptr [srect], 0
	mov word ptr [srect+2],0
	mov ax, wd
	dec ax
	mov word ptr[srect+4], ax
	mov ax, ht
	dec ax
	mov word ptr [srect+6], ax
	fn SetConsoleWindowInfo,esi,1,addr srect
	pop eax
	mov bx, ht
	shl ebx, 16
	or bx, wd
	fn SetConsoleScreenBufferSize, eax, ebx
	Ret
SetConsoleSize ENDP

HideCursor PROC uses ebx esi edi
	LOCAL ci: CONSOLE_CURSOR_INFO
	fn GetStdHandle, -11
	push eax
	mov ebx, eax
	fn GetConsoleCursorInfo,ebx,addr ci
	mov ci.bVisible, 0
	pop eax
	mov ebx,eax
	fn SetConsoleCursorInfo,ebx,addr ci
	Ret
HideCursor EndP
gotoxy PROC uses ebx esi edi x:DWORD,y:DWORD
	mov ebx,y
	shl ebx,16
	or ebx,x
	fn SetConsoleCursorPosition,rv(GetStdHandle,-11),ebx
	Ret
gotoxy EndP

.data
ErrorCaption BYTE "Error",0
ErrorMsg	 BYTE " failed with error ",0
.code
ErrorMessage PROC uses ebx esi edi, DWErrorCode:DWORD,lpszFunction:PTR BYTE
	LOCAL lpMsgBuf: LPVOID
	LOCAL lpDisplayBuf: LPVOID
	LOCAL dwerror: DWORD

	call GetLastError
	mov dwerror, eax
	
	mov ebx,FORMAT_MESSAGE_ALLOCATE_BUFFER
	or ebx,FORMAT_MESSAGE_FROM_SYSTEM
	or ebx,FORMAT_MESSAGE_IGNORE_INSERTS
	
	fn FormatMessage,ebx,0,dwerror,0,addr lpMsgBuf,0,0
	
	fn str_Length,lpszFunction
	mov ebx,eax
	fn str_Length,lpMsgBuf
	add ebx,eax
	add ebx,80
	
	fn LocalAlloc,LMEM_ZEROINIT,ebx
	mov lpDisplayBuf, eax
	
	fn strCopyN,lpszFunction,lpDisplayBuf,rv(str_Length,lpszFunction)
	
	fn strConcat,lpDisplayBuf,OFFSET ErrorMsg
	
	fn str_Length,lpDisplayBuf
	add eax,lpDisplayBuf
	fn Itoa,dwerror,eax
	
	fn str_Length,lpDisplayBuf
	add eax,lpDisplayBuf
	mov byte ptr[eax], ':'
	mov byte ptr[eax+1], ' '
	mov byte ptr[eax+2], 0
	
	fn strConcat,lpDisplayBuf, lpMsgBuf
	
	fn MessageBox,0,lpDisplayBuf,addr ErrorCaption,MB_OK
	
	fn LocalFree,lpMsgBuf
	fn LocalFree,lpDisplayBuf
	fn ExitProcess,dwerror

	Ret
ErrorMessage EndP

SetColor PROC uses ebx esi edi, cref:DWORD
	
	fn SetConsoleTextAttribute,rv(GetStdHandle,-11),cref
	
	Ret
SetColor EndP

.data
sym BYTE 2 DUP(0)

.code
CheckPosition PROC uses ebx esi edi x:DWORD, y:DWORD
	LOCAL chrNum: DWORD
	LOCAL HD: DWORD
	fn gotoxy,x,y
	
	mov edx, y						;dwReadCoord
	shl edx, 16
	or edx, x
	
	lea eax, [sym]					;lpCharacter

	fn GetStdHandle,-11				;hConsoleOutput
	mov HD, eax
	
	lea ebx,[chrNum]
	lea edi,[sym]
	fn ReadConsoleOutputCharacterA,HD,edi,2,edx,ebx
	
	test eax,eax
	je @@Error
	
	movzx eax,byte ptr[sym]
	jmp @@Ret
	
@@Error:
	fn ErrorMessage, eax,"CheckPosition"	;Output error
	jmp @@Ret
	
@@Ret:
	Ret
CheckPosition EndP

END start