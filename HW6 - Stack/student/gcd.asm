;;=======================================
;; CS 2110 - Spring 2019
;; HW6 - Recursive Greatest Common Denominator
;;=======================================
;; Name: David Peeler
;;=======================================

;; In this file, you must implement the 'gcd' subroutine.

;; Little reminder from your friendly neighborhood 2110 TA staff:
;; don't run this directly by pressing 'RUN' in complx, since there is nothing
;; put at address x3000. Instead, load it and use 'Debug' -> 'Simulate Subroutine
;; Call' and choose the 'gcd' label.


.orig x3000
HALT

gcd
;; See the PDF for more information on what this subroutine should do.
;;
;; Arguments of GCD: integer a, integer b
;;
;; Psuedocode:
;; gcd(int a, int b) {
;;     if (a == b) {
;;         return a;
;;     } else if (a < b) {
;;         return gcd(b, a);
;;     } else {
;;         return gcd(a - b, b);
;;     }
;; }


;; YOUR CODE HERE
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

;Check our conditions
ADD R3, R2, #0
NOT R3, R3
ADD R3, R3, #1
ADD R3, R3, R1  ; A - B
BRz CASE1
BRn CASE2
BRp CASE3

;;     if (a == b) {
;;         return a;
;;     }
CASE1
ADD R4, R1, #0
STR R4, R5, #0
BR FIN

;;     } else if (a < b) {
;;         return gcd(b, a);
;;     }
CASE2
STR R2, R6, #-2 ;Push b to the stack
STR R1, R6, #-1 ;Push a to the stack
ADD R6, R6, #-2 ;Stack pointer to first arg
JSR gcd
LDR R4, R6, #0  ;Store return data
ADD R6, R6, #3  ;Move stack back to original position
BR FIN

;;     } else {
;;         return gcd(a - b, b);
;;     }
CASE3
ADD R3, R2, #0
NOT R3, R3
ADD R3, R3, #1
ADD R3, R3, R1  ; a - b
STR R3, R6, #-2 ;Push a - b to the stack
STR R2, R6, #-1 ;Push b to the stack
ADD R6, R6, #-2 ;Stack pointer to first arg
JSR gcd
LDR R4, R6, #0 ;Store return data
ADD R6, R6, #3 ;Move stack back to original position
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
