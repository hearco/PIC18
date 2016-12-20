
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 16, 2016
; Title: I/O excercise
; Description:
;       - To rotate to the left
;       - To rotate to the right
;       - To rotate to both sides
;       - Each routines should be activated with a push button
;       - If no push button is pressed, a led should be just blinking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RADIX       	DEC			; SET DECIMAL AS DEFAULT BASE
PROCESSOR	18F45K50            	; SET PROCESSOR TYPE
#INCLUDE	<P18F45K50.INC>     	; INCLUDE PIC18 LIBRARY


;	*** VECTORS NEEDED FOR SOFTWARE SIMULATION ***
; ------------------------------------------------

ORG	0				; RESET VECTOR
GOTO	0X1000

ORG	0X08				; HIGH INTERRUPT VECTOR
GOTO	0X1008

ORG	0X18				; LOW INTERRUPT VECTOR
GOTO	0X1018


;	*** VECTORS USED FOR JUMPING BETWEEN MEMORY LOCATIONS ***
; -----------------------------------------------------------

ORG	0X1000				; RESET VECTOR
GOTO	MAIN

ORG	0X1008				; HIGH INTERRUPT VECTOR
;GOTO	ISR_HIGH			; UNCOMMENT WHEN NEEDED
;
ORG	0X1018				; LOW INTERRUPT VECTOR
;GOTO	ISR_LOW				; UNCOMMENT WHEN NEEDED


; ------------ SET UP THE CONSTANTS ----------------
;
;   RAM memory space goes from 0x00 to 0xFFF. By default,
;   we can use the access bank (from 0x00 to 0x7F of bank 0
;   to 0x80 to 0xFF of bank 15)
;
;   RAM data memory MAP
;
;   BANK 0          0x00 (0x00 to 0x7F Access RAM)
;                        (0x80 to 0xFF start of GPR's)
;   BANK 1          0x01 (0x00 to 0xFF)
;   BANK 2          0x02 (0x00 to 0xFF)
;   BANK 3          0x03 (0x00 to 0xFF)
;   BANK 4          0x04 (0x00 to 0xFF)
;   BANK 5          0x05 (0x00 to 0xFF)
;   ...
;   BANK 6 TO 14    (UNUSED, READ 0x00)
;   ...
;   BANK 15         0xFF (0x00 to 0x7F UNUSED)
;                        (0x80 to 0xFF SFR's)
;
;---------------------------------------------------

DELAY1          EQU	0	; DELAY VARIABLE 1
DELAY2          EQU	1	; DELAY VARIABLE 2
DELAY3          EQU 	3       ; DELAY VARIABLE 3
LATB_TEMP       EQU 	4       ; TEMPORAL FOR LATB

; ----------- INITIALIZE REGISTERS ---------------------
;
;   We are using PORTB to show the result of the routines
;   and PORTC to read the push butons state.
;
; ------------------------------------------------
MAIN:
        MOVLB   15              ; SET BSR FOR BANKED SFR'S
        CLRF    ANSELC, BANKED  ; PORT C AS DIGITAL
        CLRF	ANSELB, BANKED  ; PORT B AS DIGITAL
	CLRF    TRISB           ; PORT B AS OUTPUT (EACH PIN CONNECTED TO A LED TO SHOW THE ROUTINES)
        SETF    TRISC           ; SET PORTC AS INPUT. HERE WE ATACH THE 3 PUSH BUTTONS
        MOVLW   0X01            ;
        MOVWF   LATB_TEMP       ; INITIALIZE PORTB WITH 1

; ---------------- BLINK ROUTINE -----------------
; ------------------------------------------------

BLINK:
        MOVFF   LATB_TEMP, LATB ; SHOW VALUE ON LATB
        CALL    TESTS           ; CHECK IF ANY BUTTON IS PRESSED
        CALL    Delay1Sec       ; WAIT 1 SECOND
        CLRF    LATB            ; CLEAR LATB
        CALL    TESTS           ; CHECK IF ANY BUTTON IS PRESSED
        CALL    Delay1Sec       ; WAIT 1 SECOND
        GOTO    BLINK           ; REPEAT AGAIN

; -------------- EVALUACION DE BOTONES----------------
; ----------------------------------------------------

TESTS:
        BTFSS   PORTC, RC0          ; CHECK IF ROTATE-TO-THE-LEFT BUTTON IS PRESSED
        GOTO    Rotate_Left         ;
        BTFSS   PORTC, RC1          ; CHECK IF ROTATE-TO-THE-RIGHT BUTTON IS PRESSED
        GOTO    Rotate_Right        ;
        BTFSS   PORTC, RC2          ; CHECK IF ROTATE-TO-BOTH-SIDES BUTTON IS PRESSED
        GOTO    Rotate_LeftRight    ;
        RETURN                      ; FINISH ROUTINE CALL

; ---------------------- ROTATE TO THE LEFT ---------------------------
;
; Make a rotate to the left by keeping the led blinking too. Consider
; that this routine asks twice if the push button is pressed so we
; try to not miss any user button hit.
;
; ---------------------------------------------------------------------

Rotate_Left:
        CALL    Delay1Sec           ; WAIT 1 SECOND
        RLNCF   LATB_TEMP           ; ROTATE TO THE LEFT
        MOVFF   LATB_TEMP, LATB     ; SHOW RESULT ON PORT B
        
        BTFSS   PORTC, RC0          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK       ; IF SO, GO BACK TO BLINK ROUTINE
        CALL    Delay1Sec           ; ELSE, WAIT 1 SECOND
        CLRF    LATB                ; CLEAR PORT B
        
        BTFSS   PORTC, RC0          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK       ; IF SO, GO BACK TO BLINK ROUTINE
        GOTO    Rotate_Left         ; ELSE, REPEAT ALL

; ---------------------- ROTATE TO THE RIGHT ---------------------------
;
; Make a rotate to the right by keeping the led blinking too. Consider
; that this routine asks twice if the push button is pressed so we
; try to not miss any user button hit.
;
; ----------------------------------------------------------------------

Rotate_Right:
        CALL    Delay1Sec           ; WAIT 1 SECOND
        RRNCF   LATB_TEMP           ; ROTATE TO THE RIGHT
        MOVFF   LATB_TEMP, LATB     ; SHOW RESULT ON PORT B
        
        BTFSS   PORTC, RC1          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK       ; SI ES ASI, REGRESO A PARPADEO
        CALL    Delay1Sec           ; ELSE, WAIT 1 SECOND
        CLRF    LATB                ; CLEAR PORT B
        
        BTFSS   PORTC, RC1          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK       ; IF SO, GO BACK TO BLINK ROUTINE
        GOTO    Rotate_Right        ; ELSE, REPEAT ALL

; ------------------- ROTATE TO THE LEFT THEN RIGHT -------------------------
;
;
;
; ---------------------------------------------------------------------------

Rotate_LeftRight:
        BTFSS   LATB, RB0           ; CHECK IF RB0 IS OFF
        GOTO    Right_case          ; IF SO, ROTATE TO THE RIGHT

Left_case:                          ; IF NOT, ROTATE TO THE LEFT
        CALL    Delay1Sec           ; WAIT 1 SECOND
        CLRF    LATB                ; CLEAR PORT B
        
        BTFSS   PORTC, RC2          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK       ; IF SO, GO BACK TO BLINK ROUTINE
        CALL    Delay1Sec           ; WAIT 1 SECOND
        RLNCF   LATB_TEMP           ; ROTATE TO THE LEFT
        MOVFF   LATB_TEMP, LATB     ; SHOW RESULT ON PORT B
        
        BTFSC   LATB, RB7           ; CHECK IF CHANGE IN DIRECTION IS NEEDED
        GOTO    Right_case          ; IF SO, ROTATES TO THE RIGHT
        
        BTFSS   PORTC, RC2          ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_BLINK
        GOTO    Left_case

Right_case:
        CALL    Delay1Sec
        CLRF    LATB
        
        BTFSS   PORTC, RC2
        GOTO    BACK_TO_BLINK
        CALL    Delay1Sec
        RRNCF   LATB_TEMP            ; HACE UN CORRIMMIENTO DEL PUERTO B A LA DERECHA
        MOVFF   LATB_TEMP, LATB
        
        BTFSC   LATB, RB0
        GOTO    Left_case

        BTFSS   PORTC, 2
        GOTO    BACK_TO_BLINK
        GOTO    Right_case         ; SI NO, HAGO CORIMIENTO A LA DERECHA

; ---------------- BACK TO BLINK ROUTINE ---------------------
; -----------------------------------------------------------

BACK_TO_BLINK:
        CALL    DEBOUNCE
        GOTO    BLINK

; ----------------- SKIP PUSH-BUTTON BOUNCING ----------------------
; ------------------------------------------------------------------

DEBOUNCE:
        BTFSS   PORTC, RC0
        GOTO    DEBOUNCE
        BTFSS   PORTC, RC1
        GOTO    DEBOUNCE
        BTFSS   PORTC, RC2
        GOTO    DEBOUNCE
        RETURN

; ------------------------ DELAY 1 second --------------------------
;
; Remember that the PIC184550 clock is 16MHz, so each instruction
; takes 0.25us. The formula is:
;
; 1 cycle = 4 (1/(16M))s
; 1 cycle = 0.25us
;
; Total cycles = 3,999,996 (999.999ms)
;
; -----------------------------------------------------------------

Delay1Sec:
        
        MOVLW   0XF8
        MOVWF   DELAY1
CYCLE3:
        MOVLW   0X3A
        MOVWF   DELAY2
CYCLE2:
        MOVLW   0X5B
        MOVWF   DELAY3
CYCLE1:
        DECFSZ  DELAY3
        GOTO    CYCLE1
        DECFSZ  DELAY2
        GOTO    CYCLE2
        DECFSZ  DELAY1
        GOTO    CYCLE3
        RETURN

END
