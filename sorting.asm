TITLE Sorting and Counting Random Integers with Median!     (sorting.asm)

; Author: Luwey Hon
; Description: This program starts with an inroduction that displays
;	the heading and program description. It then displays the user's unsorted
;	integers from [0 .. 200]. After that it counts the number of instance
;	of each number. After that it displays the count list, and then displays
;	the median. After the median, it then displays the sorted list that is
;	calculated using some sort of counting algorithim. This program is 
;	implemented by passing parameters onto the stack.

INCLUDE Irvine32.inc

; defined as constant
	ARRAY_SIZE = 200
	HI = 29
	LO = 10
	COUNT_ARRAY_SIZE = 20

.data

; introduction variables
 prog_title		BYTE	"Sorting and Counting Random Integers with Median!   ",0
 prog_author	BYTE	"              by Luwey Hon", 0
 instruction_1	BYTE	"This program generates 200 random integers in the range [10 .. 29]. It will",0
 instruction_2  BYTE	"use those random integers to present: an unsorted list, a counted list, ",0
 instruction_3  BYTE	"the median of the sorted number, and then finally the sorted list.",0
 ec_count		BYTE	"**EC: counts generated before sorting list and used to generate sorted list",0
 
 ;variables for fill_array
  array			DWORD	array_size	DUP(?)

  ; variables to display list
  inform_unsorted	BYTE	"Your unsorted random numbers: ",0
  spacing			BYTE	"  ",0
  inform_sorted		BYTE	"Your sorted random numbers: ",0
  inform_count		BYTE	"Your count of each instances of number: ",0

 ;variables for sort_list
 current_count	DWORD	10
 sort_array		DWORD	array_size DUP(?)

 ; variables to derive count
 count_array	DWORD	count_array_size DUP(?)

 ; variable for median
 inform_median	BYTE	"Median of sorted numbers: ",0

.code
main PROC
	
  ;for the introduction
	push	OFFSET	ec_count
	push	OFFSET	prog_title
	push	OFFSET	prog_author
	push	OFFSET	instruction_1
	push	OFFSET	instruction_2
	push	OFFSET	instruction_3
	call	introduction

 ;to fill the array
	push	OFFSET	array
	push	HI
	push	LO
	push	ARRAY_SIZE
	call	array_fill
	
; to display the unsorted list
	call	CrLf
	call	CrLf
	push	OFFSET	inform_unsorted
	push	OFFSET	spacing
	push	ARRAY_SIZE
	push	OFFSET	array
	call	display_list


; counting the array index
	push	ARRAY_SIZE
	push	OFFSET	array
	push	OFFSET	count_array
	call	count_list

; display the counted list
	call	CrLf
	push	OFFSET	inform_count
	push	OFFSET	spacing
	push	COUNT_ARRAY_SIZE
	push	OFFSET	count_array
	call	display_list

; to sort the list
	push	OFFSET sort_array
	push	ARRAY_SIZE
	push	OFFSET array
	call	sort_list

;to display the median
	push	OFFSET inform_median
	push	ARRAY_SIZE
	push	OFFSET sort_array
	call	display_median

;to display the sorted list
	call	CrLf
	push	OFFSET inform_sorted
	push	OFFSET spacing
	push	ARRAY_SIZE
	push	OFFSET sort_array
	call	display_list

	call	CrLf

	exit	; exit to operating system
main ENDP


; Procedure to introduce the program
; recieves: offset of prog_title, prog_author, and instructions 
; returns: strings presented for the introduction
; preconditions: none
; registers changed: ebp esp edx

introduction PROC
	push	ebp
	mov		ebp, esp
	mov		edx, [ebp + 24]		; prog_title
	call	WriteString
	mov		edx, [ebp + 20]		; prog_author
	call	WriteString
	call	CrLf
	mov		edx, [ebp + 28]		; ec_count
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp + 16]		; instruction_1
	call	WriteString
	call	CrLf
	mov		edx, [ebp + 12]		; instruction_2
	call	WriteString
	call	CrLf
	mov		edx, [ebp + 8]		; instruciton_3
	call	WriteString
	pop		ebp
	ret		24			; clear the stack

introduction ENDP


; Procedure to fill up the array with random integers
; recieves: spacing, array, inform_unsorted, HI, lo, array_size
; returns: fills the array and displays the number
; preconditions: none
; registers changed: ebp, esp, ecx, ebx, eax, esi

; STACK -----------------------------
; old ebp				| [ebp]
; return				| [ebp + 4]
; array_size			| [ebp + 8]
; LO					| [ebp + 12]
; HI					| [ebp + 16]
; array					| [ebp + 20]
;------------------------------------
array_fill PROC
	push	ebp
	mov		ebp, esp
	
; intialize the loop
	mov		ecx, [ebp +8]   ; array_size
	mov		ebx, 0			; this will be the array pointer
	call	Randomize

fillArray:
; get random integer in range [10 .. 29]
	mov		eax, [ebp + 16]		; HI
	sub		eax, [ebp + 12]		; LO
	inc		eax
	call	RandomRange
	add		eax, [ebp + 12]		; LO.  eax in [10 .. 29]

; Fill up the array and prints it out
	mov		esi, [ebp + 20]			; cant move imm to imm so putting in reg
	add		esi, ebx
	mov		[esi], eax				; filling the array with random integer
	add		ebx, 4					; point to next element
	loop	fillArray

	pop		ebp
	ret		16
array_fill ENDP

; Procedure to count the list
; recieves: count_array, unsorted array, array size
; returns: a counted array
; preconditions: counts before sorted (for extra credit)
; registers changed: ebp, esp, ebx, edi, esi, eax

;STACK----------------------------
; old EBP			| [ebp]
; return			| [ebp + 4]
; count_array		| [ebp + 8]
; array				| [ebp + 12]
; array_size		| [ebp + 16]
;---------------------------------
count_list PROC
	push	ebp
	mov		ebp, esp

;intialize outter loop
	mov		ebx, 10				; the element being checked. starts at 10
	mov		ecx, 20				; since there's 20 numbers between [10 .. 29]
	mov		edi, 0				; pointer for counter array

next_number:
	push	ebx					; save outter loop number
	push	ecx					; save outter loop counter
	
;intialize the inner loop
	mov		ecx, [ebp + 16]		; array_size
	mov		esi, 0				; pointer for each unsorted array
	mov		eax, 0				; counts the register

; Looping up to the 200 elements
count_number:
	push	eax					; to save eax register (need register room)
	mov		eax, [ebp + 12]		; moving to reg since cant move imm to imm
	add		eax, esi
	cmp		[eax], ebx			; comparing the unsorted list element to current count
	pop		eax					; restore eax
	jne		dont_count

	count_the_element:
	inc		eax					; increase the count for the element
	
	dont_count:
	add		esi, 4				; move pointer for sorted array
	loop	count_number		; end of inner loop

; back to outter loop
	push	esi					; for an empty register room
	mov		esi, [ebp + 8]		; @ count_array
	add		esi, edi			
	mov		[esi], eax			; storing value in count array
	pop		esi					; retore register
	add		edi, 4				; move pointer for counting array
	pop		ecx					; restore the counters
	pop		ebx					; restore the outter loop number
	inc		ebx					; points to next count
	loop	next_number

	pop		ebp
	ret		12
count_list ENDP

; Procedure to sort the list in ascending order by counting
	; Implementation Note: uses a nested loop that iterates through the
	;  unsorted list and adds the number to sorted list. While doing this,
	;  it essentially counts how many numbers are in each list. It starts 
	;  at 10 and then goes up one by one up to 29 to add the new number to
	;  the sorted list. It should take 20 loops to get all sorted numbers.
	;  A TA told me this is like "count sort" algorithim, but not fully sure
	;  if I implemented that since I haven't learn or taken CS 261 yet.

; recieves: array, array_size, sort_array
; returns: the assorted array
; preconditions: must have the unsorted array
; registers changed: ebp, esp, ebx, ecx, edx, edi

; STACK---------------------------------
;	old ebp				| [ebp]
;	return				| [ebp + 4]
;	array				| [ebp + 8]
;   array size			| [ebp + 12]
;	sort_array			| [ebp + 16]
;---------------------------------------
sort_list PROC
	push	ebp
	mov		ebp, esp

;intialize outter loop
	mov		ebx, 10				; the element being checked. starts at 10
	mov		ecx, [ebp +12]		; array_size 
	mov		edx, 0				; pointer for sorted array

next_number:
	push	ebx					; save outter loop number
	push	ecx					; save outter loop counter
	
;intialize the inner loop
	mov		ecx, [ebp + 12]		; array_size
	mov		esi, 0				; pointer for each unsorted array

; Looping up to the 200 elements
count_sort:
	push	eax
	mov		eax, [ebp + 8]		; moving to reg since cant move imm to imm
	add		eax, esi			; indirect addressing
	cmp		[eax], ebx			; comparing the list element to current count
	pop		eax

	jne		dont_save_element

	store_the_element:
	push	edi
	mov		edi, [ebp + 16]		; sorted array address. (can't move imm to imm)
	add		edi, edx			; for indirect addressing
	mov		[edi], ebx			; storing the sorted array value
	pop		edi
	add		edx, 4				; move to next array pointer
	inc		eax					; increase the count for the element
	
	dont_save_element:
	add		esi, 4				; move pointer for sorted array
	loop	count_sort			; end of inner loop

; back to outter loop
	pop		ecx					; restore the counters
	pop		ebx					; restore the outter loop number
	inc		ebx					; points to next count
	loop	next_number

	pop		ebp
	ret		12
sort_list ENDP

; Procedure to display the median
; recieves: sorted array, array size
; returns: the median
; preconditions: none
; registers changed:

;STACK-------------------------
; old ebp			| [ebp]
; return			| [ebp + 4]
; sort_array		| [ebp + 8]
; array_size		| [ebp + 12]
; inform_median		| [ebp + 16]
;-------------------------------

display_median PROC
	push	ebp
	mov		ebp, esp

; multiply by 4 to convert into DWORD size position
	mov		eax, [ebp + 12]		; array size
	mov		ebx, 4				
	imul	ebx
					
; divide by 2 to get the half way point
	cdq
	mov		ebx,2			
	idiv	ebx				; largest middle number in eax
	mov		ebx, eax		
	sub		ebx, 4			; smaller middle number in ebx

; find the average of the two midde number
	mov		esi, [ebp + 8]		; @ sort array
	add		esi, eax			; adding half way number for indirect addressing
	mov		eax, [esi]			; moving larger middle number
	mov		ecx, eax			; save the larger middle number in ecx
	mov		esi, [ebp + 8]
	add		esi, ebx			
	mov		ebx, [esi]			; moving smaller middle number
	add		eax, ebx
	cdq
	mov		edi, ebx			; save the small middle number in edi
	mov		ebx, 2
	idiv	ebx				; eax now holds average of two middle number
	push	eax				; save the old average number
	
; multiply the sum of two middle number by 2
	add		ecx, edi		; the sum of to two old number
	mov		eax, ecx
	mov		ebx, 2
	imul	ebx

; divide by 4 ( since thats twice the number being tested)
	cdq
	mov		ebx, 4
	idiv	ebx
	
	pop		eax					; restore the old average number

; if the remainder is not >= 2, then it don't round. (remainder 2 is half way point)
	cmp		edx, 2
	jnge	dont_round

	inc		eax			; rounds the averaged median number up

	dont_round:
	
	call	CrLf
	mov		edx, [ebp + 16]		; inform_median
	call	WriteString
	call	WriteDec			; median of sorted numbers
	
	pop ebp
	ret 12

display_median ENDP



; Procedure to display the list
; recieves: (some array), array_size, spacing, (some title)
; returns: displays the list
; preconditions: none
; registers changed: ebp, esp, edx, ecx, eax, esi

;STACK-------------------------
; old ebp			| [ebp]
; return			| [ebp + 4]
; some array		| [ebp + 8]
; array size		| [ebp + 12]
; spacing			| [ebp + 16]
; title				| [ebp + 20]
;-------------------------------
display_list PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, 0			; this will be counter for new line

; title to inform user about unsort / count / sort
	mov		edx, [ebp + 20]
	call	WriteString
	call	CrLf

; intialize the loop
	mov		ecx, [ebp + 12]		; loop counter is array size
	mov		edi, [ebp + 8]		; some array address
	mov		esi, 0				; pointer for next element

; loops to display the numbers
display_nums:
	push	edi
	add		edi, esi			; for indirect addressing
	mov		eax, [edi]			; pointed to the current number in array
	pop		edi
	call	WriteDec			; prints the element
	inc		ebx
	mov		edx, [ebp + 16]
	call	WriteString			; prints the spacing
	push	ebx					; passing by parameter to sub procedure
	call	new_line			; prints a new line every number 20 numbers
	add		esi, 4				; point to next element
	loop	display_nums

	pop ebp
	ret 16

display_list ENDP

; Procedure to print a new line every 20 number
; recieves: ebx
; returns: a new line
; preconditions: ebx = 20 to print a new line
; registers changed: ebp, esp, ebx

;STACK---------------------------
; old ebp			| [ebp]
; return			| [ebp + 4]
; ebx				| [ebp + 8]  ; this hold the counter
;------------------------------
new_line PROC
	push	ebp
	mov		ebp, esp
	
; see if the counter is divisible by 20
	mov		eax, [ebp + 8]		; @ ebx - counter for new line
	cdq
	push	ebx					; to save old ebx value
	mov		ebx, 20
	idiv	ebx					; divide by 20
	pop		ebx					; restore old ebx value
	
	cmp		edx, 0				; if the remainder is 0 = divisible by 20
	jne		no_new_line			; not divisible by 20
	call	CrLf

	no_new_line:

	pop		ebp
	ret		4
new_line	ENDP


END main
