TITLE Program 6A     (prog6A.asm)

; Author:					Andre Paul
; Last Modified:			12/3/2019
; OSU email address:		paula@oregonstate.edu
; Course number/section:	CS 271 / 400
; Project Number:			6A
; Due Date:					12/8/2019
; Description:				This program will read ten integers from the user
;							and verify the input. It will then print the list back to the user,
;							print the sum of the list, and the average of the list. This program 
;							specifically utilizes MACROs getString and displayString and procedures
;							ReadVal and WriteVal. 

INCLUDE Irvine32.inc

; MACRO for getString.
; This saves the contents of edx and ecx.
; It then uses the Irvine ReadString procedure.
getString MACRO stringAddress
	push	edx
	push	ecx
	mov		edx,stringAddress
	mov		ecx,14
	call	ReadString
	pop		ecx
	pop		edx
ENDM

; MACRO for displayString.
; This saves the contents of edx.
; It then uses the Irvine WriteString procedure.
displayString MACRO stringAddress
	push	edx
	mov		edx,stringAddress
	call	WriteString
	pop		edx
ENDM

; For strings over 10 digits, we can simply not bother checking. So we have 
; a constant for the longest string acceptable, as well.
; We also have constants for the ASCII values of numeric ranges.

LO_ASCII	EQU		48d
HI_ASCII	EQU		57d

.data

intro1		BYTE	"Demonstrating low-level I/O procedures.",0
intro2		BYTE	"Programmed by Andre Paul.",0
intro3		BYTE	"Please provide 10 nonnegative decimal integers.",0
intro4		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
intro5		BYTE	"After you have finished inputting the raw numbers I will display a list",0
intro6		BYTE	"of the integers, their sum, and their average value.",0
prompt		BYTE	"Please enter a nonnegative integer number: ",0
error		BYTE	"ERROR: You did not enter an integer number or your number was too big. Try again: ",0
printList	BYTE	"You entered the following numbers: ",0
comma		BYTE	" , ",0
printSum	BYTE	"Their sum is: ",0
printAvg	BYTE	"Their average is: ",0
bye			BYTE	"Thanks for using my program. Bye!",0
outString	BYTE	12 DUP(' '),0

.data?
userString	BYTE	15 DUP(?)
arrayOfNums DWORD	10 DUP(?)
sum			DWORD	?
avg			DWORD	?


.code
main PROC

	displayString	OFFSET intro1
	call			CrLf	
	displayString	OFFSET intro2
	call			CrLf
	displayString	OFFSET intro3
	call			CrLf
	displayString	OFFSET intro4
	call			CrLf
	displayString	OFFSET intro5
	call			CrLf	
	displayString	OFFSET intro6
	call			CrLf

	push			OFFSET arrayOfNums
	push			OFFSET userString
	call			ReadVal

	push			OFFSET outString
	push			OFFSET arrayOfNums
	call			DisplayArray
	call			CrLf

	push			OFFSET sum
	push			OFFSET avg
	push			OFFSET arrayOfNums
	call			CalcSumAndAvg

	displayString OFFSET printSum
	push			OFFSET outString
	push			sum
	call			WriteVal
	call			CrLf
	
	displayString OFFSET printAvg
	push			OFFSET outString
	push			avg
	call			WriteVal
	call			CrLf

	exit	; exit to operating system
main ENDP

; ReadVal procedure.
; Description:			Validates that user entered an unsigned integer that can fit in a 32-bit register. It uses lodsb to put each byte
;						from the users input string into al, then it checks that byte is in desired ASCII range. When it calculates the full number,
;						it checks the carry flag to make sure the number is not too big for a 32-bit register.
; Receives:				@arrayOfNums, @userString.
; Returns:				Nothing.
; Preconditions:		Nothing.
; Registers Changed:	eax,ebx,ecx,edx,esi,edi
ReadVal PROC
	push		ebp
	mov			ebp,esp
	push		eax
	push		ebx
	push		ecx
	push		edx
	push		esi
	push		edi
; array indexing is done by edi.
	mov			edi,[ebp+12]
; Clear direction flag to use lodsb properly.	
	cld
; Clear carry flag to make sure incorrect jumps aren't made.
	clc
; Use edx as the counter for "successful" adds into the array.
	mov			edx,0
getNewNumber:
	mov			ebx,0
displayString	OFFSET prompt
	getString	[ebp+8]
	mov			esi,[ebp+8]
keepValidating:
	lodsb
; Now a character of input string should be in al register.
	cmp			al,0
	je			doneWithString
	cmp			al,LO_ASCII
	jl			invalid
	cmp			al,HI_ASCII
	jg			invalid
stillValid:
	sub			al,48
; annoyingly could not just mult. ebx by 10...
; so I'm looping adding to itself 10 times.
; using edx as a temp to hold the original value.
; If carry flag is set, number is too big.
	mov			ecx,9
	push		edx
	mov			edx,ebx
addAgain:
	add			ebx,edx
	loop		addAgain
	pop			edx
	jc			invalid
; ebx now holds ebx*10.
; must extend al to ax then ax to eax 
; in order to add to ebx.
; If carry flag is set, number is too big.
	movzx		ax,al
	movzx		eax,ax
	add			ebx,eax
; Zero out eax to ensure no leftover contents.
	xor			eax,eax
	jc			invalid
	jmp			keepValidating
invalid:
	displayString OFFSET error
	call		CrLf
	jmp			getNewNumber
doneWithString:
; Now, the valid digit should be in ebx. So we can 
; put it in the array.
	mov			[edi],ebx
	add			edi,4
	inc			edx
	cmp			edx,10
	je			doneWithArray
	jmp			getNewNumber

doneWithArray:
	pop			edi
	pop			esi
	pop			edx
	pop			ecx
	pop			ebx
	pop			eax
	pop			ebp
	ret 8
ReadVal ENDP

; WriteVal procedure.
; Description:			This converts integers digit by digit to a string of characters. 
; Receives:				An unsigned integer (by value), @outString.
; Returns:				Nothing.
; Preconditions:		The numbers being passed have been initialized/set.
; Registers Changed:	eax,ebx,edx,edi
WriteVal PROC
	push		ebp
	mov			ebp,esp
	push		eax
	push		edx
	push		ebx
	push		edi
	push		ecx
	push		esi

	mov			eax,[ebp+8]
	mov			ebx,10
	mov			edi,[ebp+12]
; Clear the contents of the outString every time.
	mov			ecx,12
clearString:
; Note: 32d is ASCII for space.
	mov			BYTE PTR [edi],32d
	inc			edi
	loop		clearString
; Reset address.
	mov			edi,[ebp+12]
; Start at the END of outstring. Increment through
; end to beginning.
	add			edi,10
; Set direction flag to traverse string left-wards.
	std
keepGoing:
	mov			edx,0
	div			ebx
; Remainder in edx. Add 48 for ASCII value.
	add			edx,48

; BLOCK FOR USING STOSB.
; Since we need to get the remainder in al, we need to 
; push and pop these registers, then transfer from edx to al.
	push		edx
	push		eax

	mov			al,dl
	stosb

	pop			eax
	pop			edx
; BLOCK FOR USING STOSB END.

; keep going until each digit has been processed.
	cmp			eax,0
	jne			keepGoing
; Now, the string address in edi should have the new number in it.
	displayString edi

	pop			esi
	pop			ecx
	pop			edi
	pop			ebx
	pop			edx
	pop			eax
	pop			ebp
	ret 8
WriteVal ENDP

; DisplayArray procedure.
; Description:			This displays the users list that they put in.
; Receives:				@arrayOfNums, @outString.
; Returns:				Nothing.
; Preconditions:		The array has been filled.
; Registers Changed:	edi,eax,ecx
DisplayArray PROC
	push		ebp
	mov			ebp,esp
	push		edi
	push		eax
	push		ecx

; loop counter.
	mov			ecx,10
	call		CrLf
	displayString OFFSET printList
; @array goes in edi.
	mov			edi,[ebp+8]
keepPrinting:
; Use custom WriteVal instead of WriteDec.
	push		[ebp+12]
	push		[edi]
	call		WriteVal
	add			edi,4
	cmp			ecx,1
	jle			lastComma
	displayString OFFSET comma
	loop		keepPrinting
lastComma:
	pop			ecx
	pop			eax
	pop			edi
	pop			ebp
	ret 8
DisplayArray ENDP

; Calculate the sum and the average procedure.
; Description:			Goes through the passed in array and calculates the sum of it's contents. Uses sum to calc. avg.
; Receives:				@sum, @avg, @arrayOfNums.
; Returns:				Nothing.
; Preconditions:		The array has been filled.
; Registers Changed:	eax,edi,ecx,edx,ebx
CalcSumAndAvg PROC
	push		ebp
	mov			ebp,esp
	push		eax
	push		edi
	push		ecx
	push		edx
	push		ebx

	mov			edi,[ebp+8]
	mov			eax,0
	mov			ecx,10
addNums:
	add			eax,[edi]
	add			edi,4
	loop		addNums
; Now, sum is in eax. 
; Use ebx for double dereference.
	push		ebx
	mov			ebx,[ebp+16]
	mov			[ebx],eax
	pop			ebx
; Calc avg.
	mov			edx,0
	mov			ebx,10
	div			ebx
; Now, avg is in eax.
; Use ebx for double dereference.
	push		ebx
	mov			ebx,[ebp+12]
	mov			[ebx],eax
	pop			ebx

	pop			ebx
	pop			edx
	pop			ecx
	pop			edi
	pop			eax
	pop			ebp
	ret 12
CalcSumAndAvg ENDP

END main