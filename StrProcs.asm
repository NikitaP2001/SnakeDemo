include StrProcs.inc

.code

strConcat PROC USES esi edi ebx,
				target:PTR DWORD,
				source:PTR DWORD
	INVOKE str_Length, target		
	add eax, target	
	mov edi, eax
				
	INVOKE str_Length, source
	mov ecx, eax
	inc ecx
	mov esi, source
	
	rep movsb				
	ret			
		
strConcat ENDP

str_Length PROC uses ebx esi edi,strPtr:PTR BYTE

	mov ebx, strPtr
	mov edi, ebx
	
    or ecx, 0FFFFFFFFh
	cld
	xor eax, eax
	
	repne scasb
	
	mov eax, edi
	sub eax, ebx
    dec eax
	Ret
	
str_Length EndP

Itoa PROC uses ebx esi edi,num:DWORD,pString:PTR BYTE

    mov ebx,num

    xor ecx, ecx
@@cont:
    test ebx, ebx
    je @@out
    inc ecx
    mov eax, ebx
    mov edi, 10
    xor edx, edx
    div edi
    push edx  
    mov ebx, eax
    jmp @@cont
@@out:
	xor edi, edi
	mov esi, pString
@@rev:
    pop ebx
    add ebx, 30h
    mov byte ptr[esi+edi],bl
    inc edi
    LOOP @@rev
	mov byte ptr[esi+edi],0

    ret
Itoa ENDP

strCopyN PROC USES eax ecx esi edi,source:PTR BYTE,target:PTR DWORD,_size:DWORD

	INVOKE str_Length, source
	cmp eax, _size
	ja @@movs
	mov ecx, eax
	jmp @@copy
@@movs:
	mov ecx, _size
@@copy:
	inc ecx
	mov esi, source
	mov edi, target
	cld
	rep movsb
	ret
	
strCopyN ENDP













