; AddTwo.asm - adds two 32-bit integers
; example from page 65-66 in the book

.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO,dwExitCode:DWORD

.code
main PROC
	mov eax,5
	add eax,6

	INVOKE ExitProcess,0
main ENDP
END main