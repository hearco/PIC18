;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 27, 2016
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


; VARIABLES (ADDRESSES)



; ----------- INITIALIZE REGISTERS ---------------------
;
; For Timer0 module configuration, consider the next information
;
; T0CON: TIMER0 CONTROL REGISTER
;
; bit   Description
;
;   7   TMR0ON: Timer0 On/Off control bit
;       1 = Enables Timer0
;       0 = Stops Timer0
;
;   6   T08BIT: Timer0 8-bit/16-bit control bit
;       1 = 8-bit timer counter
;       0 = 16-bit timer counter
;
;   5   T0CS: Timer0 clock source select bit
;       1 = Transition on T0CKI pin
;       0 = Internal instruction cycle clock (Fosc/4)
;
;   4   T0SE: Timer0 source edge select bit
;       1 = Increment on high-to-low transition on T0CKI pin
;       0 = Increment on low-to-high transition on T0CKI pin

;   3   PSA: Timer0 prescaler assignment bit
;       1 = Timer0 prescaler is NOT assigned
;       0 = Prescaler assigned
;
;   2   T0PS<2:0>: Timer0 prescaler value
;       111 = 1:256
;       110 = 1:128
;       101 = 1:64
;       100 = 1:32
;       011 = 1:16
;       010 = 1:8
;       001 = 1:4
;       000 = 1:2
;
; ------------------------------------------------------

MAIN:
        ; ----------- CONSIDERATIONS ---------------
        ;
        ; - CONNECT PUSH BUTTON TO RB0
        ; - CONNECT RD7 TO T0CKI (PIN 4) OF PORTA
        ; - CONNECT LED TO RD0
        ; ------------------------------------------

        MOVLB   15
        ; CONFIGURE T0CKI PIN AS INPUT FOR COUNTING
        CLRF    ANSELA, BANKED      ; PORTA AS DIGITAL
        BSF     TRISA, T0CKI        ; BIT 4 OF PORTA

        ; CONFIGURE BIT 0 OF PORTB AS INPUT FOR PUSH BUTTON
        CLRF	ANSELB, BANKED		; PORTB DIGITAL
        BSF     TRISB, RB0          ; BIT 0 FOR INPUT, WHERE PUSH BUTTON IS ATTACHED

        ; CONFIGURE BIT 0 OF PORTD AS OUTPUT TO TOGGLE A LED
        CLRF    ANSELD, BANKED      ; PORTD DIGITAL
        SETF    TRISD               ; LATD FOR OUTPUT

        ; CONFIGURE T0CON FOR TIMER0
        MOVLW   b'01111000'         ; TIMER = 8 BITS, T0CKI FALLING EDGE TRANSITION, NO PRESCALER
        MOVWF   T0CON               ;

        ; INTCON: Interrupt Control Register
        ;  bit  Description
        ;   7   GIE/GIEH:   Global Interrupt Enable bit
        ;                   When IPEN = 0:
        ;                       1 = Enables all unmasked interrupts
        ;                       0 = Disables all interrupts including peripherals
        ;                   When IPEN = 1:
        ;                       1 = Enables all high priority interrupts
        ;                       0 = Disables all interrupts including low priority
        ;   6   PEIE/GIEL:  Peripheral Interrupt Enable bit
        ;                   When IPEN = 0:
        ;                       1 = Enables all unmasked peripheral interrupts
        ;                       0 = Disables all peripheral interrupts
        ;                   When IPEN = 1:
        ;                       1 = Enables all low priority interrupts
        ;                       0 = Disables all low priority interrupts
        ;   5   TMR0IE:     TMR0 Overflow Interrupt Enable bit
        ;                       1 = Enables the TMR0 overflow interrupt
        ;                       0 = Disables the TMR0 overflow interrupt
        ;   4   INT0IE:     INT0 External Interrupt Enable bit
        ;                       1 = Enables the INT0 external interrupt
        ;                       0 = Disables the INT0 external interrupt
        ;   3   RBIE:       Interrupt-On-Change (RB PORT CHANGE) Interrupt Enable bit
        ;                       1 = Enables the RB port change interrupt
        ;                       0 = Disables the RB port change interrupt
        ;   2   TMR0IF:     TMR0 Overflow Interrupt Flag bit
        ;                       1 = TMR0 register has overflowed (must be cleared by software)
        ;                       0 = TMR0 register did not overflow
        ;   1   INT0IF:     INT0 External Interrupt Flag bit
        ;                       1 = The INT0 external interrupt occurred (must be cleared by software)
        ;                       0 = The INT0 external interrupt did not occur
        ;   0   IOCIF/RBIF: Interrupt-On-Change (RB) Interrupt Flag bit
        ;                       1 = At least one of the RB7:RB4 pins changed state (must be cleared by software)
        ;                       0 = None of the RB7:RB4 pins have changed state
        ;

        CLRF    INTCON              ; DISABLE ALL INTERRUPTS AS WE WILL NOT USE ISR ROUTINES
                                    ; INSTEAD, WE WILL KEEP CHECKING FOR TMR0 OVERFLOW FLAG

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

SET_UP_TIMER0:
        MOVLW   246                 ; LOAD THE 256-10 VALUE
        MOVWF   TMR0L               ; EQUIVALENT TO 60ms
        BSF     T0CON, TMR0ON       ;

; -------------- CHECK PUSH BUTON ------------------
;
; WHEN THE PUSH BUTTON IS PRESSED, INCREMENT COUNT
;
; --------------------------------------------------

BUTTON_STATUS:
        BTFSS   PORTB, RB0
        GOTO    INCREMENT_COUNT
        BRA     BUTTON_STATUS

; -------------- INCREMENT COUNTER --------------
;
; AFTER INCREMENTING COUNTER, CHECK FOR OVERFLOW
;
; -----------------------------------------------

INCREMENT_COUNT:
        BSF     LATD, RD7
        CALL    DEBOUNCE
        BCF     LATD, RD7
        GOTO    CHECK_OVERFLOW

; ------------- WAIT ROUTINE --------------
;
; WAIT UNTIL TIMER0 FINISHES TO TOGGLE LED
;
; -----------------------------------------

CHECK_OVERFLOW:
        BTFSS   INTCON, TMR0IF      ; LOOP UNTIL TMR0 OVERFLOW OCCURS
        GOTO    BUTTON_STATUS
        BCF     T0CON, TMR0ON       ; WHEN TMR0 FINISHES, TURN THE TIMER0 OFF
        BTG     LATD, RD0           ; AND THEN TOGGLES BIT 0 VALUE
        BCF     INTCON, TMR0IF      ; CLEAN TMR0 OVERFLOW FLAG
        GOTO    SET_UP_TIMER0       ; AND START OVER

; ------- DEBOUNCE ROUTINE -----------
; ------------------------------------

DEBOUNCE:
        BTFSS   PORTB, RB0
        GOTO    DEBOUNCE
        RETURN

END
