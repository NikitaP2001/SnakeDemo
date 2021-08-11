
DrawSnake	PROTO	:DWORD,:DWORD
ClearTail	PROTO	
DrawTail	PROTO
CreateSnake PROTO

SNAKE struct

	x		dword ?
	y		dword ?
	direction  db ?
			   db ?
	speed	dword ?

SNAKE EndS

TAIL struct
	
	x	dword ?
	y	dword ?	
	
	
TAIL EndS


.const
	MAX_SPEED	equ		10
	STOP 		equ 	0
	MAX_TAIL	equ		500
	SPD_STEP	equ		10

.data?

snake 			SNAKE <>
tail			TAIL MAX_TAIL dup(<>)

spd_count	DWORD	?
nTail		DWORD	?
nPickup		DWORD	?

.code

DrawSnake	proc	uses ebx esi edi x:DWORD,y:DWORD
	
	fn gotoxy,x,y
	fn SetColor,cGreen
	
	fn crt_putchar,'0'
	
	ret
	
DrawSnake EndP

DrawTail PROC uses ebx esi edi edx

	fn SetColor,cGreen
	
	lea esi,tail
	xor ebx,ebx
	jmp @@For
@@In:
	mov eax,dword ptr[esi]
	mov edx,dword ptr[esi+4]
	
	.if eax == 0 || edx == 0
		jmp @@Ret
	.endif
	
	fn gotoxy,eax,edx
	
	fn crt_putchar,'o'
	
	inc ebx
	add esi,sizeof TAIL
@@For:
	cmp ebx,nTail
	jb @@In
@@Ret:

	Ret
DrawTail EndP

MoveTail proc uses ebx esi edi
	LOCAL	x:DWORD
	LOCAL	y:DWORD
	LOCAL  xprev:DWORD
	LOCAL  yprev:DWORD
	LOCAL  xtemp:DWORD
	LOCAL  ytemp:DWORD

	mov eax, snake.x
	mov dword ptr[x], eax
	
	mov eax, snake.y
	mov dword ptr[y], eax

	lea esi,tail
	mov eax,dword ptr[esi]
	mov dword ptr[xprev],eax
	mov eax,dword ptr[esi+4]
	mov dword ptr[yprev],eax		
	
	mov eax,dword ptr[x]
	mov dword ptr[esi],eax
	mov eax,dword ptr[y]
	mov dword ptr[esi+4],eax
	
	fn gotoxy,xprev,yprev
	fn crt_putchar,20h
	
	xor ebx,ebx
	inc ebx
	add esi,sizeof TAIL
	
	jmp @@For
@@In:
	mov eax,dword ptr[esi]
	mov dword ptr[xtemp],eax
	mov eax,dword ptr[esi+4]
	mov dword ptr[ytemp],eax
	
	fn gotoxy,xtemp,ytemp
	fn crt_putchar,20h
	
	mov eax,dword ptr[xprev]
	mov dword ptr[esi],eax
	mov eax,dword ptr[yprev]
	mov dword ptr[esi+4],eax
	
	mov eax,dword ptr[xtemp]
	mov dword ptr[xprev],eax
	mov eax,dword ptr[ytemp]
	mov dword ptr[yprev],eax
				
	add esi,sizeof TAIL
	inc ebx
@@For:
	cmp ebx,nTail
	jb @@In

	Ret
MoveTail EndP

ClearTail PROC uses ecx esi edi 
	
	lea edi,tail
	
	mov ecx,nTail
	imul ecx,TYPE tail
	
	xor eax, eax
	
	cld
	rep STOSB
	
	Ret
ClearTail EndP

CreateSnake proc uses ebx esi edi

	mov dword ptr[snake.x],40
	mov dword ptr[snake.y],17
	mov byte ptr[snake.direction],31h
	mov dword ptr[snake.speed],10
	mov dword ptr[spd_count], 0
	
	mov dword ptr[score], 0
	mov dword ptr[score_old], 0
	
	fn ClearTail
	
	mov dword ptr[nPickup],0
	mov dword ptr[nTail],0

	Ret
CreateSnake EndP







