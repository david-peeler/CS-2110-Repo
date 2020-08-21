;;=======================================
;; CS 2110 - Spring 2019
;; HW6 - Recursive Multiplication
;;=======================================
;; Name: David Peeler
;;=======================================

;; In this file, you must implement the 'mult' subroutine.

;; Little reminder from your friendly neighborhood 2110 TA staff:
;; don't run this directly by pressing 'RUN' in complx, since there is nothing
;; put at address x3000. Instead, load it and use 'Debug' -> 'Simulate Subroutine
;; Call' and choose the 'mult' label.


.orig x3000
HALT

mult
;; See the PDF for more information on what this subroutine should do.
;;
;; Arguments of mult: integer a, integer b
;;
;; Psuedocode:
;; mult(int a, int b) {
;;     if (a == 0 || b == 0) {
;;         return 0;
;;     }
;;
;;     // Since one number might be negative, we will only decrement the larger number.
;;     // This ensures that one parameter will eventually become zero.
;;     if (a > b) {
;;         var result = b + mult(a - 1, b);
;;         return result;
;;     } else {
;;         var result = a + mult(a, b - 1);
;;         return result;
;;     }
;; }


;; IMPORTANT NOTE: we recommend following the pseudocode exactly. Part of the autograder checks that your implementation is recursive.
;; This means that your implementation might fail this test if, when calculating mult(6,4), you recursively calculated mult(6,3) instead of mult(5,4).
;; In particular, make sure that if a == b, you calculate mult(a,b-1) and not mult(a-1,b), as the psuedocode says.
;; If you fail a test that expects you to calculate mult(5,4) and you instead calculated mult(4,5), try switching the arguments around when recursively calling mult.


;; YOUR CODE HERE
;; Setting up the stack
ADD R6, R6, #-4 ;; R6 starts at first local
STR R5, R6, #1  ;; Store old frame pointer
STR R7, R6, #2  ;; Store return address
ADD R5, R6, #0  ;; New frame pointer
STR R0, R5, #-1 ;; Allocate space
STR R1, R5, #-2
STR R2, R5, #-3
STR R3, R5, #-4
STR R4, R5, #-5
ADD R6, R6, #-5

LDR R1, R5, #4 ;A
LDR R2, R5, #5 ;B

;;     if (a == 0 || b == 0) {
;;         return 0;
;;     }
ADD R1, R1, #0
BRz CASE1
ADD R2, R2, #0
BRz CASE1
AND R4, R4, #0
ADD R4, R2, #0
NOT R4, R4
ADD R4, R4, #1 ;; neg B
ADD R4, R1, R4 ;; A - B
BRnz CASE3
BRp CASE2


;;     if (a == 0 || b == 0) {
;;         return 0;
;;     }
CASE1
AND R4, R4, #0
STR R4, R5, #0
BR FIN


;;if (a > b) {
;;         var result = b + mult(a - 1, b);
;;         return result;
;;     }
CASE2
ADD R1, R1, #-1 ;a - 1
STR R2, R6, #-1 ;Push b to the stack
STR R1, R6, #-2 ;Push a - 1 to the stack
ADD R6, R6, #-2 ;Move stack pointer to first argument
JSR mult
LDR R3, R6, #0 ;Load data from the address in R6 into a register
ADD R6, R6, #3 ;Pop stack to original position to preserve recursive call
ADD R4, R3, R2 ;b + mult(a - 1, b)
STR R4, R5, #0 ;store in local variable spot
BR FIN


;;     } else {
;;         var result = a + mult(a, b - 1);
;;         return result;
;;     }
CASE3
ADD R2, R2, #-1 ;b - 1
STR R2, R6, #-1 ;Push b - 1
STR R1, R6, #-2 ;Push a
ADD R6, R6, #-2 ;Stack pointer pointing at first arg
JSR mult        ;Recursive call
LDR R3, R6, #0  ;Store return data
ADD R6, R6, #3  ;Move stack back to original position
ADD R4, R3, R1  ;a + mult(a, b - 1)
STR R4, R5, #0  ;Store our answer in the local variable spot
BR FIN



FIN
STR R4, R5, #3  ;Put R4 as the return value
LDR R7, R5, #2  ;load the old address of R7 back to R7
LDR R0, R5, #-1 ;Deallocate space
LDR R1, R5, #-2
LDR R2, R5, #-3
LDR R3, R5, #-4
LDR R4, R5, #-5
ADD R6, R5, #0  ;Pops stack to the frame pointer
LDR R5, R6, #1  ;Returns R5 to original value
ADD R6, R6, #3  ;Pops stack to the return value
RET

; Needed by Simulate Subroutine Call in complx
STACK .fill xF000
.end
