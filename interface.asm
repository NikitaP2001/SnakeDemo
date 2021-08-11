
MainMenu proto
DeathScreen proto

.data

szCls	db "cls", 0
szLevel_D db "Res\Death.txt",0

.code


MainMenu PROC uses ebx esi edi
	LOCAL hout:DWORD
	LOCAL choice:DWORD
	LOCAL cStart:DWORD
	LOCAL cExit:DWORD
	
	mov cStart, cWhite
	mov cExit, cRed
	fn SetColor,cStart
	fn crt_system, offset szCls
	mov hout,rv(GetStdHandle,-11)
	mov dword ptr[choice], 1
	mov byte ptr[bKey], 30h
	mov byte ptr[closeConsole],0
	mov byte ptr[gameOver],0
	.WHILE closeConsole == 0 && gameOver == 0
		.WHILE	byte ptr[bKey] != KEY_ENTER
			fn gotoxy,38,15
			fn SetColor,cStart
			fn crt_printf,"START"
			fn SetColor,cExit
			fn gotoxy,38,17
			fn crt_printf,"EXIT"
			call Keyboard_check_pressed
			.if	al == 'w' && choice == 2
				dec dword ptr[choice]
				mov dword ptr[cExit],cRed
				mov dword ptr[cStart],cWhite
				push offset szClick
				call Play_sound
			.elseif al == 's'&& choice == 1
				inc dword ptr[choice]
				mov dword ptr[cExit],cWhite
				mov dword ptr[cStart],cRed	
				push offset szClick
				call Play_sound
			.endif
		.ENDW
		.IF	choice == 1
			mov byte ptr[gameOver],1
		.ELSEIF choice == 2
			mov byte ptr[closeConsole],1
		.ENDIF
		fn crt_system,offset szCls
		mov byte ptr[bKey], 30h
	.ENDW	
	Ret
MainMenu EndP

DeathScreen PROC uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL buffer[256]:BYTE
	
	invoke gotoxy,0,0
	fn crt_fopen,addr szLevel_D,"r"
	
	or eax,eax
	je @@Ret
	mov dword ptr[hFile], eax
	push eax
	fn SetColor,cPause
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
	
	push 3000
	invoke crt__sleep
	
@@Ret:
	Ret
DeathScreen EndP