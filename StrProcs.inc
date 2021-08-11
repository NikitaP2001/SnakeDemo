
str_Length PROTO strPtr:PTR BYTE
strConcat PROTO target:PTR DWORD,source:PTR DWORD
Itoa PROTO num:DWORD,pString:PTR BYTE
strCopyN PROTO source:PTR BYTE,target:PTR DWORD,_size:DWORD