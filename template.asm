TITLE Program Template     (template.asm)

; Author:					Andre Paul
; Last Modified:
; OSU email address:		paula@oregonstate.edu
; Course number/section:	CS 271 / 400
; Project Number:			
; Due Date:
; Description:

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main

; TEMPLATE FOR PROC HEADER BLOCK

; Description: 
; Receives:
; Returns: 
; Preconditions: 
; Registers Changed:  

; displayMedian.
; Description: 
; Receives:
; Returns: 
; Preconditions: 
; Registers Changed:  
displayMedian PROC
	push		ebp
	mov			ebp,esp
	push		eax
	push		edx
	push		edi
	push		ebx

	push		[ebp+16]
	call		print

	mov			edi,[ebp+12]
	mov			eax,[ebp+8]
	mov			edx,0
	mov			ebx,2
	div			ebx
	cmp			edx,0
	jne			oddElements
; If not, we have even elements.
	mov			ebx,[edi+eax*TYPE DWORD]
	dec			eax
	add			ebx,[edi+eax*TYPE DWORD]
	mov			eax,ebx
	mov			ebx,2
	div			ebx
	call		WriteDec
	jmp			done

oddElements:
; Since eax was divided by 2 and there are odd 
; elements, we're now at the median already.
	mov			eax,[edi+eax*TYPE DWORD]
	call		WriteDec
done:

	pop			ebx
	pop			edi
	pop			edx
	pop			eax
	pop			ebp
	ret 16
displayMedian ENDP