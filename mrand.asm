RangeRand proto :DWORD,:DWORD

.data
rand_max dq 32768.0

.code

RangeRand proc uses ebx esi edi _min:DWORD,_max:DWORD
    LOCAL res:DWORD

    invoke crt_rand
    mov dword ptr[res],eax

    fild dword ptr[res]
    fld qword ptr[rand_max]  

    fdivp st(1),st
	
    mov eax,_max
    sub eax,_min
	
    mov dword ptr[res],eax
    fild dword ptr[res]
	
    fmulp st(1),st
	
    fild dword ptr[_min]
	
    faddp st(1),st
	
    fistp dword ptr[res]
    mov eax, dword ptr[res]

    Ret
RangeRand endp   


