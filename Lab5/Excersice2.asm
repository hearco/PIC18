;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 20, 2016
; Title: I/O excercise 2
; Description:
;       - Attach 4 push buttons to select between increment or decrement and
;         to select between BCD or Gray counter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

DELAY1          EQU	0			; DELAY VARIABLE 1
DELAY2          EQU	1			; DELAY VARIABLE 2
DELAY3          EQU 3           ; DELAY VARIABLE 3
COUNTER         EQU 4           ; GENERAL PURPOSE COUNTER
MAX_BCD_COUNT   EQU 10          ; VALUE FOR THE MAX VALUE FOR BCD

; ----------- INITIALIZE REGISTERS ---------------------
;
;   We are using PORTB to show the result of the routines
;   and PORTC to read the push butons state.
;
;   CONSIDER THE NEXT STEPS AND PINOUT:
;
;   RC0 - BCD COUNTER
;   RC1 - GRAY COUNTER
;   RC2 - INCREMENTING COUNTER
;   RC6 - DECREMENTING COUNTER
; ------------------------------------------------------

MAIN:

        BCD_BUFFER: ; ADDRESS 0X1018
        ; --------------------- MEMORY CONTENT FOR BCD -------------------------
        ;
        ;          0,    1,    2,    3,    4,    5,    6,    7,    8,    9
        DB      0xBF, 0x86, 0xDB, 0xCF, 0xE6, 0xED, 0xFD, 0xC7, 0xFF, 0xEF,
        ;
        ; ----------------------------------------------------------------------

        ; --------------- LOAD VALUE MACRO -------------------
        ;
        ; THIS MACRO LOADS A CONSTANT  ARG1 TO THE SPECIFIED
        ; REGISTER ARG2
        ;
        ; ----------------------------------------------------

            LOADV   MACRO   ARG1, ARG2
                    MOVLW   ARG1
                    MOVWF   ARG2
                    ENDM

        ; -------------- INITIALIZATION -----------------
        ; -----------------------------------------------

        MOVLB   15                  ; SET BSR FOR BANKED SFR'S. BANK 15 IS FOR SPECIAL FUNCTION REGISTERS (LAT'S, PORT'S, etc)
        CLRF    ANSELC, BANKED      ; PORT C AS DIGITAL
        CLRF	ANSELB, BANKED      ; PORT B AS DIGITAL
		CLRF    TRISB               ; PORT B AS OUTPUT (EACH PIN CONNECTED TO A LED TO SHOW THE ROUTINES)
        SETF    TRISC               ; SET PORTC AS INPUT. HERE WE ATACH THE 3 PUSH BUTTONS

; ------------------- MAIN MENU --------------------
;
; THIS WILL CHECK WHICH TYPE OF COUNTER IS SELECTED
; CONSIDER RC0 FOR BCD AND RC1 FOR GRAY COUNTER
;
; --------------------------------------------------

CHECK_TYPE:
        CLRF    LATB

CHECK_TYPE1:
        BTFSS   PORTC, RC0          ; CHECK IF BCD IS SELECTED
        GOTO    BCD_CHECK
        BTFSS   PORTC, RC1          ; CHECK IF GRAY IS SELECTED
        CALL    GRAY_CHECK
        BRA     CHECK_TYPE1         ; LOOP UNTIL AN OPTION IS SELECTED

; ------------ CHECK BCD COUNTER TYPE -------------------
;
; CHECK IF INCRMENT OR DECREMENT COUNTER IS SELECTED.
; CONSIDER RC2 FOR INCREMENT AND RC6 FOR DECREMENT.
;
; -------------------------------------------------------

BCD_CHECK:
        CALL    DEBOUNCE
        SETF    LATB

BCD_CHECK1:
        BTFSS   PORTC, RC2          ; CHECK IF INCREMENT IS SELECTED
        GOTO    BCD_INC
        BTFSS   PORTC, RC6          ; CHECK IF DECREMENT IS SELECTED
        GOTO    BCD_DEC
        GOTO    BCD_CHECK1          ; LOOP UNTIL AN OPTION IS SELECTED

; ------------- BCD INCREMENTING COUNTER ---------------
;
; COUNT FROM 0 TO 9 IN BCD
;
; ------------------------------------------------------

BCD_INC:
        CALL    DEBOUNCE
        CLRF    LATB

BCD_INC1:
        LOADV   MAX_BCD_COUNT, COUNTER  ; COUNTER = 10
        CLRF    TBLPTRU                 ; THIS WILL MAKE
        MOVLW   0X10                    ; TABLAT POINT
        MOVWF   TBLPTRH                 ; TO ADDRESS 0X1018
        MOVLW   0X18                    ;
        MOVWF   TBLPTRL                 ; WHERE BCD IS STORED

NEXT_BCD1:
        TBLRD*+                         ; INCREMENT POSITION UP TO 9 (0X1021)
        MOVFF   TABLAT, LATB
        CALL    DELAY_1SEC
        BTFSS   PORTC, RC2              ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_CHECK_TYPE

        DECFSZ  COUNTER                 ; DECREMENT FROM 10 TO 0
        BRA     NEXT_BCD1               ; WHEN IT REACHES 0, IT RESETS
        BRA     BCD_INC1                ; TO START OVER FROM 0X1018 ADDRESS

; ------------- BCD DECREMENTING COUNTER ---------------
;
;   COUNT FROM9 TO 0
;
; ------------------------------------------------------
BCD_DEC:
        CALL    DEBOUNCE
        CLRF    LATB

BCD_DEC2:
        LOADV   MAX_BCD_COUNT, COUNTER  ; COUNTER = 10
        CLRF    TBLPTRU                 ; THIS WILL MAKE
        MOVLW   0X10                    ; TABLAT POINT
        MOVWF   TBLPTRH                 ; TO ADDRESS 0X1021
        MOVLW   0X21
        MOVWF   TBLPTRL                 ; WHERE LAST BCD IS STORED

NEXT_BCD2:
        TBLRD*-                         ; DECREMENT DOWN TO 0 (0X1018)
        MOVFF   TABLAT, LATB
        CALL    DELAY_1SEC
        BTFSS   PORTC, RC6              ; CHECK IF ROUTINE IS STOPPED
        GOTO    BACK_TO_CHECK_TYPE

        DECFSZ  COUNTER                 ; DECREMENT FROM 10 TO 0
        BRA     NEXT_BCD2               ; WHEN IT REACHES 0, IT STARTS
        BRA     BCD_DEC2                ; OVER FROM 0X1021 ADDRESS

; ------------- CHECK GRAY COUNTER TYPE ------------------
;
; CHECK IF INCREMENT OR DECREMENT IS SELECTED. CONSIDER
; RC2 AS INCREMENT AND RC6 AS DECREMENT
;
; --------------------------------------------------------

GRAY_CHECK:
        CALL    DEBOUNCE
        SETF    LATB

GRAY_CHECK1:
        BTFSS   PORTC, RC2      ; CHECK IF INCREMENT IS SELECTED
        GOTO    GRAY_INC
        BTFSS   PORTC, RC6      ; CHECK IF DECREMENT IS SELECTED
        GOTO    GRAY_DEC
        BRA     GRAY_CHECK1     ; LOOP UNTIL AN OPTION IS SELECTED

; ------------ GRAY INCREMENTING COUNTER ---------------
;
; ROUTINE TO COUNT UP TO 4 AND THEN RESTART FROM 0
;
; ------------------------------------------------------

GRAY_INC:
        CALL    DEBOUNCE                ;

GRAY_INC1:
        CLRF    LATB                    ;
        MOVLW   0X04                    ;
        MOVWF   COUNTER                 ;

GRAY_INC2:
        CALL    DELAY_1SEC              ;
        BTG     LATB, RB0               ; 1
        BTFSS   PORTC, RC2              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        CALL    DELAY_1SEC              ;
        BTG     LATB, RB1               ; 2
        BTFSS   PORTC, RC2              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        CALL    DELAY_1SEC              ;
        BTG     LATB, RB0               ; 3
        BTFSS   PORTC, RC2              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        CALL    DELAY_1SEC              ;
        BTG     LATB, RB2               ; 4
        BTFSS   PORTC, RC2              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        DECFSZ  COUNTER                 ;
        GOTO    GRAY_INC2               ;
        GOTO    GRAY_INC1               ;

; ------------ GRAY DECREMENTING COUNTER ---------------
;
; COUNTS DOWN FROM 4 TO 0
;
; ------------------------------------------------------

GRAY_DEC:
        CALL    DEBOUNCE                ;

GRAY_DEC1:
        CLRF    LATB                    ;
        BTG     LATB, RB2               ;

GRAY_DEC2:
        CALL    DELAY_1SEC              ;
        BTG     LATB, RB0               ; 4
        BTFSS   PORTC,RC6               ;
        GOTO    BACK_TO_CHECK_TYPE      ;
        
        CALL    DELAY_1SEC              ;
        BTG     LATB, RB1               ; 3
        BTFSS   PORTC, RC6              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        CALL    DELAY_1SEC              ;
        BTG     LATB, RB0               ; 2
        BTFSS   PORTC, RC6              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        CALL    DELAY_1SEC              ;
        BTG     LATB, RB2               ; 1
        BTFSS   PORTC, RC6              ;
        GOTO    BACK_TO_CHECK_TYPE      ;

        DECFSZ  COUNTER                 ;
        GOTO    GRAY_DEC2               ;
        GOTO    GRAY_DEC1               ;

; ---------------- DEBOUNCE ROUTINE ----------------------
;
; Avoid push button bouncing
;
; --------------------------------------------------------

DEBOUNCE:
        BTFSS   PORTC, RC0
        GOTO    DEBOUNCE
        BTFSS   PORTC, RC1
        GOTO    DEBOUNCE
        BTFSS   PORTC, RC2
        GOTO    DEBOUNCE
        BTFSS   PORTC, RC6
        GOTO    DEBOUNCE
        RETURN

; --------------------------------------------
;
; ROUTINE ACTIVATED AFTER EXITING A COUNTER
; THIS CALL DEBOUNCE AND GOES BACK TO MAIN MENU
;
; ---------------------------------------------

BACK_TO_CHECK_TYPE:
        CALL    DEBOUNCE
        GOTO    CHECK_TYPE

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

DELAY_1SEC:
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
