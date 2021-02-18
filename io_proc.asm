TITLE Designing Low Level I/O Procedures

; Author: Lindsay Goins
; Last Modified: 3/15/20
; Description: This program introduces the program and programmer and instructs the user to enter 10 signed integers. It then receives
; those values as strings and converts them to integers. Next, it calculates their sum 
; and average. It then converts those integers back to strings and prints them for the user to see. Lastly, the program wishes 
; the user goodbye.

INCLUDE Irvine32.inc

;*****************************************************************************************************************************
; Macro to display a string
; receives: address of specified string
; preconditions: none
; postconditions: none
; registers changed: none
; ****************************************************************************************************************************
displayString MACRO string_reference
	pushad
	mov		edx, string_reference
	call	WriteString
	popad
ENDM

;*****************************************************************************************************************************
; Macro to receive input from the user
; receives: address of user input, address of length of input
; preconditions: none
; postconditions: input and length are stored in memory
; registers changed: none
; ****************************************************************************************************************************
getString MACRO user_input, length
	pushad
	mov		edx, user_input
	mov		ecx, 12
	call	ReadString
	mov		length, eax
	popad
ENDM

LENGTH_OF = 10

.data

intro			BYTE	"Designing Low Level I/O Procedures by Lindsay Goins!",0
instruct_1		BYTE	"Please input 10 signed decimal integers.",0
instruct_2		BYTE	"Each number should be small enough to fit into a 32-bit register.",0
instruct_3		BYTE	"Once you are finished inputting your numbers, I will display a list of the integers, their sum, and their average value.",0
prompt			BYTE	"Please enter a signed number: ",0
error_msg		BYTE	"Error! You did not enter a signed number or your number did not fit inside a 32-bit register.",0
array_msg		BYTE	"You entered the following numbers: ",0
sum_msg			BYTE	"The sum of your numbers is: ",0
avg_msg			BYTE	"The rounded average is: ",0
good_bye		BYTE	"Thank you for using my program! I hope you have a great day!",0
user_num		BYTE	11 DUP(0)
char_length		BYTE	?
array			SDWORD	10 DUP(?)
sign_num		SDWORD	?
sum				SDWORD	?
avg				SDWORD	?


.code
main PROC

	push	OFFSET instruct_3
	push	OFFSET instruct_2
	push	OFFSET instruct_1
	push	OFFSET intro
	call	introduction
	
	push	OFFSET array
	push	OFFSET sign_num
	push	OFFSET error_msg
	push	OFFSET char_length
	push	OFFSET user_num
	push	OFFSET prompt
	call	getVals

	push	OFFSET avg
	push	OFFSET sum
	push	LENGTH_OF
	push	OFFSET array
	call	calculations

	push	LENGTH_OF
	push	OFFSET avg
	push	OFFSET avg_msg
	push	OFFSET sum
	push	OFFSET sum_msg
	push	OFFSET array
	push	OFFSET array_msg
	call	displayVals

	push	OFFSET good_bye
	call	goodbye

	exit	; exit to operating system
main ENDP

;*****************************************************************************************************************************
; Procedure to introduce the program and instruct the user
; receives: address of intro, instruct_1, instruct_2, and instruct_3
; preconditions: none
; postconditions: none
; registers changed: none
; ****************************************************************************************************************************
introduction PROC
	pushad
	mov		ebp, esp

;Introduce the program and instruct the user
	displayString [ebp + 36]
	call CrLf
	call CrLf

	displayString [ebp + 40]
	call CrLf

	displayString [ebp + 44]
	call CrLf

	displayString [ebp + 48]
	call CrLf
	
	popad
	ret		16
introduction ENDP

;*****************************************************************************************************************************
; Procedure to fill an array with signed integers
; receives: address of prompt, user_num, char_length, error_msg, sign_num, and array
; preconditions: readVal must be called to fill the array
; postconditions: array is filled
; registers changed: none
; ****************************************************************************************************************************
getVals PROC
	pushad
	mov		ebp, esp

	mov		esi, [ebp + 56]
	mov		ecx, 10

FillArray:
	push	[ebp + 52]
	push	[ebp + 48]
	push	[ebp + 44]
	push	[ebp + 40]
	push	[ebp + 36]
	call	readVal
	
	;mov		eax, [ebp + 52]						
	;mov		[esi], eax							
	;add		esi, 4
	loop	FillArray

	popad
	ret		24
getVals	ENDP

;*****************************************************************************************************************************
; Procedure to convert user input from a string into an integer
; receives: address of prompt, user_num, char_length, error_msg, and sign_num
; preconditions: Local variable num must be defined and procedure must be called by getVals
; postconditions: user input is stored in sign_num
; registers changed: none
; ****************************************************************************************************************************
num EQU DWORD PTR [ebp - 4]
readVal PROC
	pushad
	mov		ebp, esp
	sub		esp, 4 

GetVal:
	displayString [ebp + 36]
	getString [ebp + 40], [ebp + 44]

	cld
	mov		esi, [ebp + 40]
	mov		ecx, [ebp + 44]
	mov		eax, 0
	mov		ebx, 10
	mov		edx, 0

;Convert string to positive number
ValidLoop:
	imul	ebx
	mov		num, eax
	mov		edx, 0
	
	lodsb

	cmp		al, 43									;if the leading character is a +
	je		PosNum

	cmp		al, 45									;if the leading character is a -
	je		NegNum

	cmp		al, 48									;if a character is not a number
	jl		ErrorMsg
	
	cmp		al, 57									;if a character is not a number
	jg		ErrorMsg

	cbw
	cwd
	
	mov		edx, eax
	sub		edx, 48
	mov		eax, num
	add		eax, edx
	
	jo		ErrorMsg								;if the number doesn't fit in a 32-bit register
	loop	ValidLoop
	
	mov		edi, [ebp + 52]							
	mov		[edi], eax
	jmp		EndRet

PosNum:
	sub		eax, 43
	jmp		ValidLoop

NegNum:
	sub		eax, 45
	dec		ecx

;Convert string to negative number
NegValidLoop:
	imul	ebx
	mov		num, eax
	mov		edx, 0
	
	lodsb

	cmp		al, 48									;if a character is not a number
	jl		ErrorMsg
	
	cmp		al, 57									;if a character is not a number
	jg		ErrorMsg

	cbw
	cwd
	
	mov		edx, eax
	sub		edx, 48
	mov		eax, num
	add		eax, edx

	jo		ErrorMsg								;if the number doesn't fit in a 32-bit register
	loop	NegValidLoop
	
	mov		ebx, -1									;negate the number if it is negative
	imul	ebx

	mov		edi, [ebp + 52]							
	mov		[edi], eax
	jmp		EndRet

;Displays error message
ErrorMsg:
	displayString [ebp + 48]
	call	CrLf
	jmp		GetVal

EndRet:
	mov		esp, ebp
	popad
	ret		20
readVal ENDP

;*****************************************************************************************************************************
; Procedure to calculate the sum of the integers in the array and their average
; receives: address of array, sum, avg, and the value LENGTH_OF
; preconditions: array must be filled
; postconditions: sum and avg are initialized
; registers changed: none
; ****************************************************************************************************************************
calculations PROC
	pushad
	mov		ebp, esp

	mov		esi, [ebp + 36]
	mov		ecx, [ebp + 40]

;Calculates the sum of the array
SumLoop:
	mov		ebx, [esi]
	add		eax, ebx
	add		esi, 4
	loop	SumLoop
	mov		[ebp + 44], eax

;Calculates the average of the values in the array
	;mov		ebx, [ebp + 40]
	;idiv	ebx										
	;mov		[ebp + 48], eax

	popad
	ret		16
calculations ENDP

;*****************************************************************************************************************************
; Procedure to display values
; receives: address of array_msg, array, sum_msg, sum, avg_msg, avg, and value LENGTH_OF
; preconditions: array must be filled, and calculations must be made
; postconditions: none
; registers changed: none
; ****************************************************************************************************************************
displayVals PROC
	pushad
	mov		ebp, esp

	mov		ecx, [ebp + 60]

;Prints array
displayString [ebp + 36]
ArrayLoop:
	push	[ebp + 40]
	call	writeVal
	loop	ArrayLoop

;Prints sum
	displayString [ebp + 44]
	push	[ebp + 48]
	call	writeVal

;Prints average
	displayString [ebp + 52]
	push	[ebp + 56]
	call	writeVal

	popad
	ret		28
displayVals	ENDP

;*****************************************************************************************************************************
; Procedure to convert integers to strings
; receives: address of array, sum, and avg
; preconditions: procedure must be called by displayVals
; postconditions: array, sum, and avg are stored in memory
; registers changed: none
; ****************************************************************************************************************************
num EQU DWORD PTR [ebp - 4]
writeVal PROC
	pushad
	mov		ebp, esp
	sub		esp, 4

	cld
	mov		esi, [ebp + 36]
	mov		ecx, 10
	mov		eax, 10
	mov		ebx, 10
	mov		edx, 0
	;mov		edi, [ebp + 40]

;Converts integer to string
StringLoop:
	idiv	ebx
	mov		num, eax
	mov		edx, 0
	
	stosb

	cbw
	cwd
	
	mov		edx, eax
	add		edx, 48
	mov		eax, num
	add		eax, edx

	loop	StringLoop

	mov		esp, ebp
	popad
	ret		4
writeVal ENDP

;*****************************************************************************************************************************
; Procedure to say goodbye to the user
; receives: address of good_bye
; preconditions: none
; postconditions: none
; registers changed: none
; ****************************************************************************************************************************
goodbye PROC
	pushad	
	mov		ebp, esp

;Say goodbye to the user
	displayString [ebp + 36]

	popad
	ret		4
goodbye	ENDP

END main
