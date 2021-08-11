
CreateFruit		proto
DrawFruit		proto

FRUIT struct
	
	x	dword 	?
	y	dword 	?
	sprite	db	?
	reserv	db	?
FRUIT EndS

TIME_BLINK		equ 10


.data?
Fruit		FRUIT <>
blink		dd ?


.code
CreateFruit proc uses ebx esi edi
	LOCAL x:DWORD
	LOCAL y:DWORD
	
@@Do:
	invoke RangeRand,1,80
	mov dword ptr[x],eax
	invoke RangeRand,1,30
	mov dword ptr[y],eax
	
	invoke CheckPosition,x,y
	cmp al,20h
	jne @@Do
	
	mov eax,dword ptr[x]
	mov dword ptr[Fruit.x],eax
	mov eax,dword ptr[y]
	mov dword ptr[Fruit.y],eax
	
	mov byte ptr[Fruit.sprite],1
	mov blink, 0

	Ret
CreateFruit EndP

DrawFruit proc uses ebx esi edi

	inc blink
	.if blink >= TIME_BLINK
		
		.if byte ptr[Fruit.sprite] == 1
		
			mov byte ptr[Fruit.sprite],2
			
		.elseif	
			
			mov byte ptr[Fruit.sprite],1
			
		.endif
		mov blink,0
	.endif
	
	fn gotoxy,Fruit.x,Fruit.y
	
	fn SetColor,cDarkYellow
	
	movzx eax,Fruit.sprite
	fn crt_putchar,eax
	
	Ret
DrawFruit EndP

