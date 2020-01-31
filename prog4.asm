TITLE Program 4 - Composites	(prog4.asm)

; Author:					Andre Paul
; Last Modified:			11/10/2019
; OSU email address:		paula@oregonstate.edu
; Course number/section:	CS 271 / 400
; Project Number:			4
; Due Date:					11/10/2019
; Description:				This program asks the user to enter a number n
;							of composite numbers to be displayed. The program 
;							verifies the user input is an integer from 1 through 300.
;							Then the program calculates/displays all composite
;							numbers up to and including the nth composite number.

INCLUDE Irvine32.inc

; Upper / lower limit constants.
	MIN_VAL		EQU		1
	MAX_VAL		EQU		300

.data

	intro1		BYTE	"Welcome to the Composite Program",0
	intro2		BYTE	"programmed by Andre Paul",0
	intro3		BYTE	"This program calculates composite numbers and will show them to you.",0
	intro4		BYTE	"Please enter the amount of composites you'd like to see, from 1 through 300: ",0
	printError	BYTE	"Out of range. Please try again.",0
	bye			BYTE	"Thanks for using the Composite Program. Goodbye!",0

.data?
	numberIn	DWORD	?

.code
main PROC

	call introduction

	call getUserData

	exit	; exit to operating system
main ENDP

; Introduction procedure. This tells the user what
; the program does and gives them instructions
; for what the user should input.

introduction PROC

	mov		edx,OFFSET intro1
	call	WriteString
	call	CrLf

	mov		edx,OFFSET intro2
	call	WriteString
	call	CrLf
	
	mov		edx,OFFSET intro3
	call	WriteString
	call	CrLf
	
	mov		edx,OFFSET intro4
	call	WriteString
	call	CrLf
	
	ret
introduction ENDP

; getUserData procedure. This will take in the user's 
; input from 1 through 300. It will loop and print an error until 
; the input is valid. This procedure calls the sub-procedure "validate".

getUserData PROC
	
	call	ReadInt
	call	validate

	ret
getUserData ENDP

; validate sub-procedure. This is called by getUserData until the 
; entered data is within range [1, 300]. It calls getUserData
; if the data is invalid.

validate PROC

	cmp		eax,MIN_VAL
	jl		error
	cmp		eax,MAX_VAL
	jg		error
	jmp		goodData

error:
	mov		edx,OFFSET printError
	call	WriteString
	call	CrLf
	call	getUserData

goodData:
	mov		numberIn,eax

	ret
validate ENDP


END main
