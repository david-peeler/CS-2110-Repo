;; =============================================================
;; CS 2110 - Spring 2020
;; HW6 - Replace Values in Linked List
;; =============================================================
;; Name: David Peeler
;; ============================================================

;; In this file, you must implement the 'mult' subroutine.

;; Little reminder from your friendly neighborhood 2110 TA staff:
;; don't run this directly by pressing 'RUN' in complx, since there is nothing
;; put at address x3000. Instead, load it and use 'Debug' -> 'Simulate Subroutine
;; Call' and choose the 'replaceValueLL' label.

.orig x3000
HALT

replaceValueLL
;; See the PDF for more information on what this subroutine should do.
;;
;; Arguments of replaceValueLL: Node head, int r
;;
;; Psuedocode:
;; replaceValueLL(Node head, int r) {
;;     if (head == null) {
;;         return head;
;;     }
;;     if (head.data == r) {
;;         head.data = 0;
;;     } else {
;;         head.data = head.data * r;
;;     }
;;     replaceValueLL(head.next, r);
;;     return head;
;; }

;; NOTE: if you need to calculate head.data * r using the mult subroutine, please make head.data be the first parameter and r be the second parameter.
;; The autograder will check if you are calling mult at appropriate times.
;; If the autograder fails you for not calling mult even though you did, try switching the arguments around.


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

LDR R2, R5, #5 ;R
LDR R1, R5, #4 ;head

;Check our conditions
BRz CASE1
ADD R3, R1, #1
LDR R3, R3, #0 ; head.data
AND R4, R4, #0
ADD R4, R2, #0
NOT R4, R4
ADD R4, R4, #1
ADD R4, R3, R4 ; head.data - r
BRz CASE2
BRnp CASE3


;;     if (head == null) {
;;         return head;
;;     }
CASE1
ADD R4, R4, #0
BR FIN


;;     if (head.data == r) {
;;         head.data = 0;
;;     }
CASE2
AND R4, R4, #0
STR R4, R1, #1 ;; Head.data = 0
BR NOTFIN


;;     } else {
;;         head.data = head.data * r;
;;     }
CASE3
ADD R6, R6, #-1 ;move stack pointer
STR R2, R6, #0  ;push r into the stack
ADD R6, R6, #-1 ;move stack pointer
STR R3, R6, #0  ;push head.data into stack
JSR mult        ;multiply those
LDR R4, R6, #0
STR R4, R1, #1  ;head.data = head.data * r;
BR NOTFIN


NOTFIN
ADD R6, R6, #-1
STR R2, R6, #0      ;push r into the stack
ADD R6, R6, #-1
LDR R3, R1, #0
STR R3, R6, #0      ;push Head.next into stack
JSR replaceValueLL
ADD R6, R6, #3
ADD R4, R1, #0
STR R4, R5, #0
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







STACK .fill xF000

;; This is a mult subroutine that you can call to multiply numbers.
;; Note that this is not the same as the one you need to implement for Part 1 of this homework;
;; the one you implement there needs to be recursive, and must support negative numbers.
;; However, you can use this subroutine for this homework question.
;; Note that this subroutine does not follow the full calling convention; however, it will work fine if you properly follow the convention on the caller's side.
mult
;; Arguments: int a, int b
ADD R6, R6, -4
STR R0, R6, 0
STR R1, R6, 1
STR R2, R6, 2
AND R0, R0, 0
LDR R1, R6, 4
LDR R2, R6, 5
BRz 3
ADD R0, R0, R1
ADD R2, R2, -1
BRp -3
STR R0, R6, 3
LDR R0, R6, 0
LDR R1, R6, 1
LDR R2, R6, 2
ADD R6, R6, 3
RET
.end


;; The following is an example of a small linked list that starts at x4000.
;; The first number (offset 0) contains the address of the next node in the linked list, or zero if this is the final node.
;; The second number (offset 1) contains the data of this node.
.orig x4000
.fill x4008
.fill 5
.end

.orig x4008
.fill 0
.fill 12
.end
