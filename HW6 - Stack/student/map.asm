;;=======================================
;; CS 2110 - Spring 2019
;; HW6 - Map Function to Array
;;=======================================
;; Name:
;;=======================================

;; In this file, you must implement the 'map' subroutine.

;; Little reminder from your friendly neighborhood 2110 TA staff:
;; don't run this directly by pressing 'RUN' in complx, since there is nothing
;; put at address x3000. Instead, load it and use 'Debug' -> 'Simulate Subroutine
;; Call' and choose the 'map' label.


.orig x3000
	LD R6, STACK        ; Initialize stack
  LEA R0, ARR; R0 = Starting address of array
  LD R1, LEN; R1 = len
	LEA R2, FUNC; R2 = function

  ADD R6, R6, -3; create 3 arguments for map stack frame
  STR R0, R6, 0; first param
  STR R1, R6, 1; second param
	STR R2, R6, 2; third param

	JSR map ;call map with params

  ; Store the return value in ANSWER
  LDR R0, R6, 0
  ST R0, ANSWER
  ADD R6, R6, 4
  HALT

ARR 				.fill x4000
LEN 				.fill 16
FUNC 				.fill x5100
ANSWER      		.blkw 1         ; Store ANSWER here

map
;; See the PDF for more information on what this subroutine should do.
;;
;; Arguments of map: Array A, int len, function func
;; Array A is a number representing the address of the first element in the array. If the array starts at x4000, then A will be the number x4000.
;; int len is the length of the array. Recall that arrays are not null-terminated like strings, so you must use the length to know when to stop modifying the array.
;; function func is the address of the function you should call. What function can you use to jump to a subroutine at this address?
;;
;; Psuedocode:
;; map(Array A, int len, function func) {
;;     for(i = 0; i < len; i++) {
;;         A[i] = func(A[i]);
;;     }
;;     return A;
;; }


	    ; Build the stack frame
	    ADD R6, R6, -3 ; Allocate space for core stack frame (RV, RA, OldFP)
	    STR R7, R6, 1  ; Save the Return Address
	    STR R5, R6, 0  ; Save old FP
	    ADD R5, R6, -1 ; Set new FP
	    ; Save the registers you are going to use
	    ADD R6, R6, -5
	    STR R0, R5, 0
	    STR R1, R5, -1
	    STR R2, R5, -2
	    STR R3, R5, -3
	    STR R4, R5, -4

    	; Get Arguments off the stack
			LDR R0, R5, 4					; R0 = Array A
			LDR R1, R5, 5					; R1 = len
	    LDR R2, R5, 6					; R2 = FUNC


			AND R3, R3, #0			; set R3 = 0 (counter)
LOOPY NOT R4, R1
			ADD R4, R4, #1			; negate len
			ADD R4, R3, R4			; R4 = i - len
			BRn FIN 						; if i - len < 0 we go to end

			LDR R4, R5, 4				; R4 = &A[]
			ADD R4, R3, R4 			; R4 = &A[i]
			LDR R4, R4, #0			; R4 = A[i]

			; Mapping time
			ADD R6, R6, -1			; create 1 argument for map_func stack frame
			STR R4, R6, 0				; first param A[i]
			JSRR R2							; jump to that function
  		LDR R4, R6, 0  			; R4 = new value for A[i]
			ADD R6, R6, 2				; cleanup crew

			LDR R0, R5, 4   		; R0 = Array A
			ADD R0, R3, R0 			; R0 = &A[i]
			STR R4, R0, 0				; set A[i] to new value

			ADD R3, R3, #1 			; increment counter by 1
			BR LOOPY


FIN 	LDR R0, R5, 4 			; R0 = addr of Array A
			STR R0, R5, 3				; RV = addr of Array A

    	LDR R0, R5, 0
	    	LDR R1, R5, -1
	    	LDR R2, R5, -2
	    	LDR R3, R5, -3
	    	LDR R4, R5, -4
	    	ADD R6, R6, 5
	    	LDR R7, R5, 2  ; Restore return address
	    	ADD R6, R5, 1  ; Move SP to old FP
	    	LDR R5, R5, 1  ; Restore old FP
	    	ADD R6, R6, 2  ; Move SP to point at the return value
    	RET


; Needed by Simulate Subroutine Call in complx
STACK .fill xF000
.end

;; The following block gives an example of what the passed-in array may look like.
;; Note that this will not necessarily be the location of the array in every test case.
;; The 'A' parameter will be the address of the first element in the array (for example, x4000).
.orig x4000
    .fill 6
	.fill 2
	.fill 5
	.fill 8
	.fill 3
.end

;; The following functions are possible functions that may be called by the map function.
;; Note that these functions do not do the full calling convention on the callee's side.
;; However, they will work perfectly fine as long as you follow the convention on the caller's side.
;; Do not edit these functions; they will be used by the autograder.
.orig x5000	;; double
	ADD R6, R6, -2
	STR R0, R6, 0
	LDR R0, R6, 2
	ADD R0, R0, R0
	STR R0, R6, 1
	LDR R0, R6, 0
	ADD R6, R6, 1
	RET
.end
.orig x5100 ;; negate
	ADD R6, R6, -2
	STR R0, R6, 0
	LDR R0, R6, 2
	NOT R0, R0
	ADD R0, R0, 1
	STR R0, R6, 1
	LDR R0, R6, 0
	ADD R6, R6, 1
	RET
.end
.orig x5200 ;; increment
	ADD R6, R6, -2
	STR R0, R6, 0
	LDR R0, R6, 2
	ADD R0, R0, 1
	STR R0, R6, 1
	LDR R0, R6, 0
	ADD R6, R6, 1
	RET
.end
.orig x5300 ;; isOdd
	ADD R6, R6, -2
	STR R0, R6, 0
	LDR R0, R6, 2
	AND R0, R0, 1
	STR R0, R6, 1
    LDR R0, R6, 0
	ADD R6, R6, 1
	RET
.end
.orig x5400 ;; decrement
	ADD R6, R6, -2
	STR R0, R6, 0
	LDR R0, R6, 2
	ADD R0, R0, -1
	STR R0, R6, 1
	LDR R0, R6, 0
	ADD R6, R6, 1
	RET
.end
