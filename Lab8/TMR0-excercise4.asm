;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 30, 2016
; Title: TIMER0 DELAY
; Description:
;       - Toggle a led after pressing a push button 10 times
;       - Use T0CKI pin as external counter
;       - Use RB0 as input for push button and RD7 as output for push button
;       - Use any pin to cinnect a led
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RADIX       DEC					; SET DECIMAL AS DEFAULT BASE
PROCESSOR	18F45K50            ; SET PROCESSOR TYPE
#INCLUDE	<P18F45K50.INC>     ; INCLUDE PIC18 LIBRARY


;	*** VECTORS NEEDED FOR SOFTWARE SIMULATION ***
; ------------------------------------------------

ORG		0					; RESET VECTOR
GOTO	0X1000

ORG		0X08				; HIGH INTERRUPT VECTOR
GOTO	0X1008

ORG		0X18				; LOW INTERRUPT VECTOR
GOTO	0X1018


;	*** VECTORS USED FOR JUMPING BETWEEN MEMORY LOCATIONS ***
; -----------------------------------------------------------

ORG		0X1000				; RESET VECTOR
GOTO	MAIN

ORG		0X1008				; HIGH INTERRUPT VECTOR
;GOTO	ISR_HIGH			; UNCOMMENT WHEN NEEDED
;
ORG		0X1018				; LOW INTERRUPT VECTOR
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

; CONSTANTS
TEN_SECONDS     EQU     2

; VARIABLES (ADDRESSES)
DELAY1          EQU     0
DELAY2          EQU     1
TIMES_TIMER0    EQU     2


; ----------- INITIALIZE REGISTERS ---------------------
; ------------------------------------------------------

MAIN:
        ; ----------- CONSIDERATIONS ---------------
        ;
        ; - CONNECT PUSH BUTTON TO RB0
        ; - CONNECT RD7 TO T0CKI (PIN 4) OF PORTA
        ; - CONNECT LED TO RD0
        ; ------------------------------------------

        MOVLB   15

        ; CONFIGURE BIT 0 OF PORTB AS INPUT FOR PUSH BUTTON
        CLRF	ANSELB, BANKED		; PORTB DIGITAL
        BSF     TRISB, RB0          ; BIT 0 FOR INPUT, WHERE PUSH BUTTON IS ATTACHED
        BCF     TRISB, RB7          ; BIT 7 AS OUTPUT

        ; CONFIGURE T1CKI PIN AS INPUT FOR COUNTING
        CLRF    ANSELC, BANKED      ; PORTC AS DIGITAL
        BSF     TRISC, 0            ; BIT 0 OF PORTC AS INPUT

        ; CONFIGURE PORTD AS OUTPUT TO SHOW RESULT OF PULSES
        CLRF    ANSELD, BANKED      ; PORTD DIGITAL
        CLRF    TRISD               ; LATD FOR OUTPUT
        CLRF    LATD                ; CLEAR PORTD

        ; CONFIGURE T0CON FOR TIMER0. CHECK PAGE 161 OF DATASHEET FOR FURTHER INFO
        ; TIMER0 WILL BE USED TO COUNT UP TO 10 SECONDS
        MOVLW   b'00000111'         ; TIMER = 16 BITS, INCREMENT ON Fosc/4, PRESCALE = 256
        MOVWF   T0CON               ;

        ; CHECK PAGE 120 OF DATASHEET FOR FURTHER INFO
        CLRF    INTCON              ; DISABLE ALL INTERRUPTS AS WE WILL NOT USE ISR ROUTINES
                                    ; INSTEAD, WE WILL KEEP CHECKING FOR TMR0 OVERFLOW FLAG

        ; CONFIGURE T1CON FOR TIMER1. CHECK PAGE 174 OF DATASHEET FOR FURTHER INFO
        ; TIMER1 WILL BE USED TO COUNT PULSES IN 10 SECONDS
        MOVLW   b'10000110'         ; NO SYNC, 16-BIT MODE
        MOVWF   T1CON               ; USE T1CKI AS EXTERNAL CLOCK, PRESCALE = 1, R/W TIMER1 IN 2 8-BIT OPERATIONS


; ----------------- TIMER1 --------------------
;
; USE THIS TIMER AS A COUNTER FOR PUSH BUTTON
;
; ---------------------------------------------

SET_UP_TIMER1:
        BCF     T1CON, TMR1ON
        MOVLW   TEN_SECONDS         ; LOADS HOW MANY TIMES TIMER0
        MOVWF   TIMES_TIMER0        ; WILL EXECUTE TO COMPLETE 10 SECONDS
        CLRF    TMR1H
        CLRF    TMR1L
        BSF     T1CON, TMR1ON

; ------------------------ TIMER0 MAX SETUP --------------------------
;
; It's simple. Because we are using an external counter, we don't
; need to calculate any time value. Just keep in the counts and the
; number TMR0L is going to count from. In this case, we need to count
; 10 times to turn on a led, then another 10 timer to turn it off.
; So, it's simple enough to load a value of 246. When it reaches 10
; counts, i will overflow.
;
; --------------------------------------------------------------------

SET_UP_TIMER0_1sec:
        BCF     T0CON, TMR0ON
        CLRF    TMR0H               ; LOAD THE MAX VALUE
        CLRF    TMR0L               ; EQUIVALENT TO 4.2s
        BSF     T0CON, TMR0ON       ;

; -------------- CHECK PUSH BUTON ------------------
;
; WHEN THE PUSH BUTTON IS PRESSED, INCREMENT COUNT
;
; --------------------------------------------------

BUTTON_STATUS:
        BTFSS   PORTB, RB0          ; KEEP CHECKING FOR PUSH BUTTON
        CALL    INCREMENT_COUNT     ;
        BTFSS   INTCON, TMR0IF      ; AND KEEP CHECKING FOR OVERFLOW
        BRA     BUTTON_STATUS       ;

CHECK_OVERFLOW:
        BCF     INTCON, TMR0IF      ;
        BTFSC   TIMES_TIMER0, 7     ; CHECK IF 10 SECONDS HAVE PASSED
        GOTO    SHOW_COUNTS         ;
        DECFSZ  TIMES_TIMER0        ; THIS WILL MAKE TIMER0 EXECUTE 2 TIMES
        GOTO    SET_UP_TIMER0_1sec  ; AND AT 3RD TIME, IT WILL EXECUTE LESS TIME

; ------------------------ LAST_TIMER0 ---------------------------
;
; THIS PART OF CODE WILL EXECUTE AFTER 8.4s. NOW, WE HAVE
; TO EXECUTE 1.6s MORE TO COMPLETE THE 10 SECONDS. SO WE
; CONSIDER THE NEXT:
;
; TMR0value = 65536 - ( Time_needed / (4 * Tosc * Prescaler) )
; TMR0value = 65536 - ( 1.612 / ( 4 * (1/16M) * 256) )
; TMR0value = 40,347 -> 0x9D9B
;
; ----------------------------------------------------------------

LAST_TIMER0:
        BCF     T0CON, TMR0ON       ; LOAD VALUE EQUIVALENT TO
        MOVLW   0x9E                ; 1.612s
        MOVWF   TMR0H               ;
        MOVLW   0x58                ;
        MOVWF   TMR0L               ;
        BSF     T0CON, TMR0ON       ; 
        BSF     TIMES_TIMER0, 7     ; TELL THE PROGRAM THIS IS THE LAST TIME TO EXECUTE TIMER0
        GOTO    BUTTON_STATUS       ;

; -------------- INCREMENT COUNTER --------------
;
; AFTER INCREMENTING COUNTER, CHECK FOR OVERFLOW
;
; -----------------------------------------------

INCREMENT_COUNT:
        CALL    DEBOUNCE            ; TOGGLE A LED EACH TIME
        BSF     LATB, RB7           ; THE PUSH BUTTON IS PRESSED
        BSF     LATD, RD0           ; SO WE CAN SEE THE COUNTING

RELEASE_BUTTON:                     ; AS BOUNCING OCCURS WHEN THE PUSH
        BTFSS   PORTB, RB0          ; BUTTON IS PRESSED AND RELEASED, THERE
        GOTO    RELEASE_BUTTON      ; ARE TO SITUATIONS WHERE A DEBOUNCE ROUTINE
        CALL    DEBOUNCE            ; HAS TO BE ADDED
        BCF     LATB, RB7           ;
        BCF     LATD, RD0           ;
        RETURN

; ----------------------------
;
; SHOW RESULT ROUTINE
;
; ----------------------------

SHOW_COUNTS:
        MOVLW   6                   ; AFTER COUNTING 10 SECONDS, SHOW
        MULWF   TMR1L               ; HOW MANY TIMES THE PUSH BUTTON WAS
        MOVFF   PRODL, LATD         ; PRESSED TIMES 6
        GOTO    SET_UP_TIMER1       ;

; -------- DEBOUNCE ROUTINE ----------
;
; WAITS ABOUT 15.25ms
;
; ------------------------------------

DEBOUNCE:
        MOVLW   200
        MOVWF   DELAY2

DELAY_2:
        MOVLW   100
        MOVWF   DELAY1

DELAY_1:
        DECFSZ  DELAY1
        GOTO    DELAY_1
        DECFSZ  DELAY2
        GOTO    DELAY_2
        RETURN

END
