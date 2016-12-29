;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 27, 2016
; Title: TIMER0 DELAY
; Description:
;       - Calculate the max delay by using the TIMER0 module
;       - Each overflow, toggle the value of a bit
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
        MOVLB   15
        CLRF	ANSELB, BANKED		; PORTB DIGITAL
        CLRF    TRISB               ; PORTB FOR OUTPUT
        CLRF    LATB                ; CLEAR PORTB DATA
        MOVLW   b'00000111'         ; TIMER = 16 BITS, INTERNAL TRANSITION, PRESCALER = 256
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

; ---------------------- TIMER0 MAX SETUP ------------------------
;
; Formula to calculate the MAX TMR0 value
;
; Timer = 4 * Tosc * (8/16bits_max_value - TMR0value)*(Prescaler)
; Max = 4 * (1/16M) * (65536 - 0) * (256)
; Max = 4.194s
;
; TMR0H = 0x00
; TMR0L = 0x00
; ----------------------------------------------------------------

SET_UP_TIMER0:
        MOVLW   0x00                ; LOAD THE 0X15A0 VALUE
        MOVWF   TMR0H               ; TO MAKE THE TIMER0
        MOVLW   0x00                ; COUNT 5,536 TIMES
        MOVWF   TMR0L               ; EQUIVALENT TO 60ms
        BSF     T0CON, TMR0ON       ;

; ------------- WAIT ROUTINE --------------
;
; WAIT UNTIL TIMER0 FINISHES TO TOGGLE LED
;
; -----------------------------------------

WAIT:
        BTFSS   INTCON, TMR0IF      ; LOOP UNTIL TMR0 OVERFLOW OCCURS
        GOTO    WAIT
        BCF     T0CON, TMR0ON       ; WHEN TMR0 FINISHES, TURN THE TIMER0 OFF
        BTG     LATB, RB7           ; AND THEN TOGGLES BIT 7 VALUE
        BCF     INTCON, TMR0IF      ; CLEAN TMR0 OVERFLOW FLAG
        GOTO    SET_UP_TIMER0       ; AND START OVER

END

