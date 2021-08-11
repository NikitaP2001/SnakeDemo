

GameInit					PROTO
Keyboard_check_pressed		PROTO
Keyboard_check				PROTO
Play_sound					PROTO :DWORD

GameController				PROTO

KeyEvent					PROTO
DrawLevel					PROTO :DWORD
DrawEvent					PROTO
DrawScore					PROTO
DrawPanel					PROTO
StepEvent					PROTO
GameUpdate					PROTO
DrawPanel					PROTO
DrawPauseMsg				PROTO :DWORD


.const
KEY_ENTER	equ 13
KEY_ESC		equ 27
MAX_STEP	equ	30

.data
bKey			db	30h
gameOver		db	0
closeConsole	db	0
nLevel			db  1
score			dd  0
score_old		dd  0
pauseState		dd  0

mapRedraw		dd  0	;Redraw after pause menu or etc

szLevel_1		db	'Res\Map.txt',0

.code

GameController	proc uses eax ebx esi edi
	
	fn KeyEvent	
	fn DrawEvent
	
	Ret
GameController EndP

GameUpdate	proc uses ebx esi edi 
	LOCAL      x:DWORD
	LOCAL      y:DWORD
	
	cmp pauseState,1
	je @@Ret
	
	inc spd_count
	
	mov eax, spd_count
	.if eax >= snake.speed

		mov eax, snake.x
		mov dword ptr[x], eax
		
		mov eax, snake.y
		mov dword ptr[y], eax
		
		.IF nTail > 0
			
			invoke MoveTail
			
		.endif
		
		fn gotoxy,snake.x,snake.y
		
		fn crt_putchar,20h
		
		.if snake.direction == 'w'
			
			mov eax,dword ptr[y]
			dec eax
			
			fn CheckPosition,x,eax
			
			.if eax == 20h || al == Fruit.sprite
			
				dec [snake.y]
				
			.elseif eax == '#'
			
				mov byte ptr[snake.direction], STOP
					
			.endif
			
			
		.endif
		
		.if snake.direction == 's'
		
			mov eax,dword ptr[y]
			inc eax
			
			fn CheckPosition,x,eax
			
			.if eax == 20h || al == Fruit.sprite
			
				inc [snake.y]
				
			.elseif eax == '#'
			
				mov byte ptr[snake.direction], STOP
					
			.endif			
			
		.endif
		
		.if snake.direction == 'a'
		
			mov eax,dword ptr[x]
			dec eax
			
			fn CheckPosition,eax,y
			
			.if eax == 20h || al == Fruit.sprite
			
				dec [snake.x]
				
			.elseif eax == '#'
			
				mov byte ptr[snake.direction], STOP
					
			.endif
		
		
		.endif
		
		.if snake.direction == 'd'
		
			mov eax,dword ptr[x]
			inc eax
			
			fn CheckPosition,eax,y
			
			.if eax == 20h || al == Fruit.sprite
			
				inc [snake.x]
				
			.elseif eax == '#'
			
				mov byte ptr[snake.direction], STOP
					
			.endif
		
		.endif
		
		
		
		mov spd_count, 0
	.endif
	
	;check fruit catch
	mov eax,snake.x
	mov ebx,snake.y
	
	.if eax == Fruit.x && ebx == Fruit.y
	
		call CreateFruit
		
		.if nTail < MAX_TAIL
		
			inc nTail
			inc nPickup
			
			add score,10
			
			fn Play_sound,offset szFruit
			
		.endif
		
	.endif
	
@@Ret:
	Ret
GameUpdate EndP

Keyboard_check_pressed PROC uses ebx esi edi
	fn FlushConsoleInputBuffer ,rv(GetStdHandle,-10)
	
@@:
	fn Sleep,1
	fn crt__kbhit
	or eax,eax
	je @B
	
	fn crt__getch
	mov byte ptr[bKey], al
	Ret
Keyboard_check_pressed EndP

Play_sound PROC uses ebx esi edi lpFile:DWORD  
	fn PlaySound,lpFile,0,SND_FILENAME or SND_ASYNC
	Ret
Play_sound EndP

GameInit PROC uses ebx esi edi
	
	invoke crt_srand,rv(crt_time,0)
	
	mov	pauseState,0
	mov mapRedraw,0
	
	movzx eax, byte ptr[nLevel]
	fn DrawLevel, eax
	or eax,eax
	jz @@Error
	
	fn CreateSnake

	fn DrawSnake,snake.x,snake.y
	
	fn CreateFruit
	
@@Ret:

	Ret
@@Error:
	mov byte ptr[gameOver], 0
	fn gotoxy,32,16
	fn SetColor,cRed
	fn crt_puts,"Load file failed"
	fn Sleep,2000
	jmp @@Ret
GameInit EndP

DrawLevel PROC uses ebx esi edi nLvl:DWORD
	LOCAL hFile:DWORD
	LOCAL buffer[256]:BYTE
	
	invoke gotoxy,0,0
	xor eax,eax
	.if nLvl == 1
		fn crt_fopen,addr szLevel_1,"r"
	.endif
		
		or eax,eax
		je @@Ret
		mov dword ptr[hFile], eax
		push eax
		fn SetColor,cYellow
		lea ebx, buffer
@@while:
		fn crt_fgets,ebx,256,hFile
		or eax,eax
		je @@CloseFile
		fn crt_printf,eax
		jmp @@while
		
@@CloseFile:
		pop eax
		fn crt_fclose,eax
		inc eax
		push eax
	
	.if nLvl > 0
		fn DrawPanel	
		fn SetColor,cGreen
		fn gotoxy,1,32
		fn crt_printf,"Score: "
		print ustr$(score)
	.endif
	
	pop eax
@@Ret:	 
	Ret
DrawLevel EndP

DrawEvent proc uses ebx esi edi

	mov ebx,mapRedraw
	
	;Redraw level after or before pause
	.if mapRedraw == 1
		
		movzx eax, byte ptr[nLevel]
		fn DrawLevel, eax
		or eax,eax
		jz @@Error
		
		mov ebx,0					;map redraw
		
	.endif
	
	;if not on pause draw all objects, othervise
	;no sense to redraw them
	.if pauseState == 0 || mapRedraw == 1
	
		.if nTail > 0
			
			fn DrawTail	
			
		.endif
		
		fn DrawSnake,snake.x,snake.y
		fn DrawFruit
		fn DrawScore
		fn StepEvent
	
	.endif
	
	.if mapRedraw == 1
	
		fn DrawPauseMsg,pauseState
		
	.endif
	
	mov mapRedraw,ebx
@@:
	Ret
	
@@Error:	
	mov byte ptr[gameOver], 0
	fn gotoxy,32,16
	fn SetColor,cRed
	fn crt_puts,"Load file failed"
	fn Sleep,2000
	jmp @B
	
DrawEvent EndP

DrawScore proc uses ebx esi edi
	
	mov ebx,score
	cmp ebx,score_old
	ja	@f
	jmp @ret
	
@@:
	fn gotoxy,8,32
	fn SetColor,cGreen
	print ustr$(ebx)			;Itoa can be also		
	
	mov dword ptr[score_old],ebx
	
@ret:	
	Ret
DrawScore EndP

DrawPanel PROC uses ebx esi edi
	
	fn SetColor,cPanel
	
	fn gotoxy,21,32
	
	fn crt_printf,"Esc - back to menu, p - pause the game"
	
	Ret
DrawPanel EndP

DrawPauseMsg PROC uses ebx esi edi drawFlag:DWORD
	
	cmp drawFlag,1
	jne @F

	fn SetColor,cPause
	
	fn gotoxy,38,15
	
	fn crt_printf,"PAUSE"
	
@@:
	Ret
DrawPauseMsg EndP

StepEvent proc uses ebx esi edi
	
	.if nPickup == SPD_STEP
		
		mov nPickup,0
		dec snake.speed
		
		.if snake.speed <= 0
			
			mov snake.speed,MAX_SPEED
			
		.endif
		
	.endif
	
	.if snake.direction == STOP
	@@GameOver:
		mov byte ptr[gameOver], 0
		jmp @@Ret
	.endif
	
	;Check tail catch
	.if nTail > 0
		
		lea esi,tail
		xor ebx,ebx
		jmp @@For
	@@In:
		mov eax,dword ptr[esi]
		mov edx,dword ptr[esi+4]
		
		.if eax ==snake.x && edx == snake.y
		
			jmp @@GameOver
		
		.endif
		
		inc ebx
		add esi,sizeof TAIL
	@@For:
		cmp ebx,nTail
		jb @@In
	.endif
	
@@Ret:
	fn Sleep,MAX_STEP
	Ret
StepEvent EndP

KeyEvent	proc uses ebx esi edi

	fn Keyboard_check
	.if byte ptr[bKey] == KEY_ESC
		
		mov byte ptr[gameOver],0
		mov byte ptr[closeConsole],1
		
	.elseif	byte ptr[bKey] == 'p'
	
		mov ebx,pauseState
		xor ebx,1
		mov pauseState,ebx
		
		mov mapRedraw,1
	
	.elseif byte ptr[bKey] == 'w' || byte ptr[bKey] == 'a' || byte ptr[bKey] == 's' || byte ptr[bKey] == 'd'
	
		mov byte ptr[snake.direction], al
	
	.endif

	Ret
KeyEvent EndP

Keyboard_check	proc uses ebx esi edi

	mov byte ptr[bKey],31h
	
	fn crt__kbhit
	or eax,eax
	je @@Ret
	fn crt__getch
	mov byte ptr[bKey], al
@@Ret:

	Ret
Keyboard_check EndP

comment *

CONSOLE_FONT_INFOEX cfi;
cfi.cbSize = sizeof(cfi);
cfi.nFont = 0;
cfi.dwFontSize.X = 0;                   // Width of each character in the font
cfi.dwFontSize.Y = 24;                  // Height
cfi.FontFamily = FF_DONTCARE;
cfi.FontWeight = FW_NORMAL;
std::wcscpy(cfi.FaceName, L"Consolas"); // Choose your font
SetCurrentConsoleFontEx(GetStdHandle(STD_OUTPUT_HANDLE), FALSE, &cfi); 
*


