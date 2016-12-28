;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Author: Ariel Almendariz
; Date: December 28, 2016
; Title: LCD and Matrix keypad
; Description:
;       - Develop a calculator by using a matrix keypad and LCD to show the result
;       - All numbers and results are 8-bit numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RADIX       	DEC			; SET DECIMAL AS DEFAULT BASE
PROCESSOR	18F45K50            	; SET PROCESSOR TYPE
#INCLUDE	<P18F45K50.INC>     	; INCLUDE PIC18 LIBRARY


;	*** VECTORS NEEDED FOR SOFTWARE SIMULATION ***
; ------------------------------------------------

ORG	0					; RESET VECTOR
GOTO	0X1000

ORG	0X08				; HIGH INTERRUPT VECTOR
GOTO	0X1008

ORG	0X18				; LOW INTERRUPT VECTOR
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
DELAYCNT            EQU 0x20
XDELAYCNT           EQU 0x21
LCD_RS              EQU 0
LCD_RW              EQU 1
LCD_EN              EQU 2

sum_op              EQU 1       ; Identifier for sum
minus_op            EQU 2       ; Identifier for substraction
mul_op              EQU 4       ; Identifier for multiplication
div_op              EQU 8       ; Identifier for division

; VARIABLES (ADDRESSES)
first_number        EQU 0       ; It holds the last number pressed
VAR1                EQU 1       ; Variable for delay
VAR2                EQU 2       ; Variable for delay
second_number       EQU	3       ; Holds the first number pressed
operation           EQU 5       ; Holds the operation type to perform
COUNTER             EQU 6       ; General purpose counter


; ----------- INITIALIZE REGISTERS ---------------------
;
;   We are using PORTB to show the result of the routines
;   and PORTC to read the push butons state.
;
;   CONSIDER THE NEXT STEPS AND PINOUT:
;
;   PORTB - MATRIX KEYPAD
;   PORTD - LCD ATTACHED
; ------------------------------------------------------

MAIN:
        MOVLB   15                  ;

        ; PORT A CONFIGURATION, LCD CONFIGURATION BITS ARE CONNECTED HERE
        CLRF    ANSELA, BANKED      ; PORTA AS DIGITAL
        CLRF    TRISA               ; PORTA FOR OUTPUT
        CLRF    LATA                ; CLEAR ANY POSSIBLE DATA AS PART OF FIRST INITIALIZATION OF LCD

        ; PORT B CONFIGURATION, MATRIX KEYPAD IS ATTACHED HERE
        CLRF	ANSELB, BANKED		; PORTB AS DIGITAL
        MOVLW   b'11110000'         ; THE MSB OF PORTB AS INPUT
        MOVWF   TRISB               ; AND THE LSB AS OUTPUT
        BCF     INTCON2, RBPU       ; ACTIVATE PULL-UP RESISTORS OF PORTB (BIT 7 OF INTCON2)

        ; PORT D CONFIGURATION, THE MATH RESULTS ARE GOING TO BE SHOWED HERE
        CLRF	ANSELD, BANKED      ; PORTD AS DIGITAL
        CLRF    TRISD               ; PORTD AS OUTPUT
        CLRF    LATD                ; CLEAR PORTD VALUE

        ; INITIALIZATION OF VARIABLES
        CLRF    operation
        CLRF    COUNTER

; ----------------------------- LCD INITIALIZATION ROUTINE ----------------------------------
;
; MODEL USED: HD44780
;
; PIN Symbol Level I/0  Fucntion                                Physical pin connection
;   1   Vss     -    -  GND                                     GND (potentiometer)
;   2   Vcc     -    -  +5V                                     +5V (potentiometer)
;   3   Vee     -    -  Contrast adjust                         Middle pin (potentiometer)
;   4   Rs     0/1   I  0 = instruction input, 1 = data input   RA0
;   5   R/W    0/1   I  0 = write to LCD, 1 = read from LCD     RA1
;   6   E   1,1->0   I  Enable signal                           RA2
;   7   DB0    0/1 I/O  Data bus line 0 (LSB)                   RD0
;   8   DB1    0/1 I/O  Data bus line 1                         RD1
;   9   DB2    0/1 I/O  Data bus line 2                         RD2
;  10   DB3    0/1 I/O  Data bus line 3                         RD3
;  11   DB4    0/1 I/O  Data bus line 4                         RD4
;  12   DB5    0/1 I/O  Data bus line 5                         RD5
;  13   DB6    0/1 I/O  Data bus line 6                         RD6
;  14   DB7    0/1 I/O  Data bus line 7 (MSB)                   RD7
;
; -------------------------------------------------------------------------------------------

LCD_init:
        BSF     LATA, LCD_EN        ; EN = 1
        BCF     LATA, LCD_RS        ; RS = 0
        MOVLW   0x38                ; 8-bit interface, character de 5x8
        MOVWF   LATD
        BCF     LATA, LCD_EN        ; EN = 0
        CALL    LCDBUSY

        BSF     LATA,LCD_EN        ; EN = 1
        BCF     LATA,LCD_RS        ; RS = 0
        MOVLW   0x0F               ; LCD ON, Cursor ON
        MOVWF   LATD
        BCF     LATA,LCD_EN        ; EN = 0
        CALL    LCDBUSY

        BSF     LATA,LCD_EN        ; EN = 1
        BCF     LATA,LCD_RS        ; RS = 0
        MOVLW   0x02               ; cursor at home
        MOVWF   LATD
        BCF     LATA,LCD_EN        ; EN = 0
        CALL    LCDBUSY

        BSF     LATA,LCD_EN        ; EN = 1
        BCF     LATA,LCD_RS        ; RS = 0
        MOVLW   0x01               ; Clear screen
        MOVWF   LATD
        BCF     LATA,LCD_EN        ; EN = 0
        CALL    LCDBUSY

; ------ LOOP ROUTINE TO KEEP CHECKING FOR KEYPAD ROWS -------
;
;                        INPUTS
;                   RB4 RB5 RB6 RB7
;                  |---------------|
;   ROW 1 BUTTONS: | 1 | 2 | 3 | A | RB0
;   ROW 2 BUTTONS: | 4 | 5 | 6 | B | RB1  OUTPUTS
;   ROW 3 BUTTONS: | 7 | 8 | 9 | C | RB2
;   ROW 4 BUTTONS: | * | 0 | # | D | RB3
;                  |---------------|
; ------------------------------------------------------------

MATRIX_KEYPAD_LOOP:
CHECK_ROW_1:
        BCF     LATB, RB0           ; ACTIVATE
        BSF     LATB, RB1           ; ONLY ROW 1
        BSF     LATB, RB2           ;
        BSF     LATB, RB3           ;

        BTFSS   PORTB, RB4          ; CHECK FOR 1
	CALL    ONE
	BTFSS   PORTB, RB5          ; CHECK FOR 2
	CALL    TWO
	BTFSS   PORTB, RB6          ; CHECK FOR 3
	CALL    THREE
        BTFSS   PORTB, RB7          ; CHECK FOR A (SUM ROUTINE)
        CALL    A_function

CHECK_ROW_2:
        BSF     LATB, RB0           ; ACTIVATE
        BCF     LATB, RB1           ; ONLY ROW 2
        BSF     LATB, RB2           ;
        BSF     LATB, RB3           ;

        BTFSS   PORTB, RB4          ; CHECK FOR 4
	CALL    FOUR
	BTFSS   PORTB, RB5          ; CHECK FOR 5
	CALL    FIVE
	BTFSS   PORTB, RB6          ; CHECK FOR 6
	CALL    SIX
	BTFSS   PORTB, RB7          ; CHECK FOR B (SUBSTRACTION ROUTINE)
        CALL    B_function

CHECK_ROW_3:
        BSF     LATB, RB0           ; ACTIVATE
        BSF     LATB, RB1           ; ONLY ROW 3
        BCF     LATB, RB2           ;
        BSF     LATB, RB3           ;

        BTFSS   PORTB, RB4          ; CHECK FOR 7
	CALL    SEVEN
	BTFSS   PORTB, RB5          ; CHECK FOR 8
	CALL    EIGHT
	BTFSS   PORTB, RB6          ; CHECK FOR 9
	CALL    NINE
        BTFSS   PORTB, RB7          ; CHECK FOR C (MULTIPLICATION ROUTINE)
        CALL    C_function

CHECK_ROW_4:
        BSF     LATB, RB0              ; ACTIVATE
        BSF     LATB, RB1              ; ONLY ROW 4
        BSF     LATB, RB2              ;
        BCF     LATB, RB3              ;

        BTFSS   PORTB, RB4             ; CHECK FOR ASTHERISK
	CALL    ASTHERISK
	BTFSS   PORTB, RB5             ; CHECK FOR 0
	CALL    ZERO
	BTFSS   PORTB, RB6             ; CHECK FOR SHARP (PERFORM MATH OPERATION AND SHOW RESULT)
	CALL    SHARP
        BTFSS   PORTB, RB7             ; CHECK FOR D (DIVISION ROUTINE)
        CALL    D_function

        GOTO    MATRIX_KEYPAD_LOOP     ; SI NO SE PRESIONA NADA, REGRESO A CHECAR EL TECLADO ENTERO


; --------------- WRITE TEXT TO LCD -------------------
;
; WRITES TO LATD THE VALUE OF WREG. IT IS RECOMMENDED
; TO WRITE THE VALUE TO BE WRITEN IN WREG BEFORE
; CALLING THIS ROUTINE
;
; -----------------------------------------------------

WR2LCD:
        BSF     LATA, LCD_EN    ; EN = 1
        BSF     LATA, LCD_RS    ; RS = 1
        MOVWF   LATD            ; LATD = CONSTANT_VALUE
        BCF     LATA, LCD_EN    ; EN = 0
        CALL    LCDBUSY
        RETURN

; ------------ ZERO ROUTINE ----------------
;
; WRITE ZERO TO PORT D
;
; ------------------------------------------

ZERO:
        CALL    DEBOUNCE_RB5        ; WAIT FOR BOUNCING
        MOVLW   '0'                 ; PARAMETER TO SEND TO WR2LCD
        CALL    WR2LCD
        CLRF    first_number        ; first number = 0
        RETURN                      ; BACK TO KEYPAD CHECK LOOP

; ------------ ONE ROUTINE ----------------
;
; WRITE ONE TO PORT D
;
; ------------------------------------------

ONE:
        CALL    DEBOUNCE_RB4        ; WAIT FOR BOUNCING
        MOVLW   '1'
        CALL    WR2LCD              ; WRITE CHARACTER 1 TO LCD
        MOVLW   1                   ; SEND 1 TO
        MOVWF   first_number        ; first number = 1
        RETURN                      ; BACK TO KEYPAD CHECK LOOP

; ------------ TWO ROUTINE ----------------
;
; WRITE TWO TO PORT D
;
; ------------------------------------------

TWO:
        CALL    DEBOUNCE_RB5
        MOVLW   '2'
        CALL    WR2LCD
        MOVLW   2
        MOVWF   first_number
        RETURN

; ------------ THREE ROUTINE ----------------
;
; WRITE THREE TO PORT D
;
; ------------------------------------------

THREE:
        CALL    DEBOUNCE_RB6
        MOVLW   '3'
        CALL    WR2LCD
        MOVLW   3
        MOVWF   first_number
        RETURN

; ------------ FOUR ROUTINE ----------------
;
; WRITE FOUR TO PORT D
;
; ------------------------------------------

FOUR:
        CALL    DEBOUNCE_RB4
        MOVLW   '4'
        CALL    WR2LCD
        MOVLW   4
        MOVWF   first_number
        RETURN

; ------------ FIVE ROUTINE ----------------
;
; WRITE FIVE TO PORT D
;
; ------------------------------------------

FIVE:
        CALL    DEBOUNCE_RB5
        MOVLW   '5'
        CALL    WR2LCD
        MOVLW   5
        MOVWF   first_number
        RETURN

; ------------ SIX ROUTINE ----------------
;
; WRITE SIX TO PORT D
;
; ------------------------------------------

SIX:
        CALL    DEBOUNCE_RB6
        MOVLW   '6'
        CALL    WR2LCD
        MOVLW   6
        MOVWF   first_number
        RETURN

; ------------ SEVEN ROUTINE ----------------
;
; WRITE SEVEN TO PORT D
;
; ------------------------------------------

SEVEN:
        CALL    DEBOUNCE_RB4
        MOVLW   '7'
        CALL    WR2LCD
        MOVLW   7
        MOVWF   first_number
        RETURN

; ------------ EIGHT ROUTINE ----------------
;
; WRITE EIGHT TO PORT D
;
; ------------------------------------------

EIGHT:
        CALL    DEBOUNCE_RB5
        MOVLW   '8'
        CALL    WR2LCD
        MOVLW   8
        MOVWF   first_number
        RETURN

; ------------ NINE ROUTINE ----------------
;
; WRITE NINE TO PORT D
;
; ------------------------------------------

NINE:
        CALL    DEBOUNCE_RB6
        MOVLW   '9'
        CALL    WR2LCD
        MOVLW   9
        MOVWF   first_number
        RETURN

; ------------ A ROUTINE ----------------
;
; PREPARE FOR A SUM BETWEEN TWO NUMBERS
;
; ------------------------------------------

A_function:
        CALL    DEBOUNCE_RB7
        MOVLW   '+'
        CALL    WR2LCD
        MOVFF   first_number, second_number
        MOVLW   sum_op
        MOVWF   operation
        RETURN

; --------------- B ROUTINE ---------------------
;
; PREPARE FOR A SUBSTRACTION BETWEEN TWO NUMBERS
;
; -----------------------------------------------

B_function:
        CALL    DEBOUNCE_RB7
        MOVLW   '-'
        CALL    WR2LCD
        MOVFF   first_number, second_number
        MOVLW   minus_op
        MOVWF   operation
        RETURN

; ---------------- C ROUTINE ----------------------
;
; PREPARE FOR A MULTIPLICATION BETWEEN TWO NUMBERS
;
; -------------------------------------------------

C_function:
        CALL    DEBOUNCE_RB7
        MOVLW   '*'
        CALL    WR2LCD
        MOVFF   first_number, second_number
        MOVLW   mul_op
        MOVWF   operation
        RETURN

; ---------------- D ROUTINE ----------------------
;
; PREPARE FOR A DIVISION BETWEEN TWO NUMBERS
;
; -------------------------------------------------

D_function:
        CALL    DEBOUNCE_RB7
        MOVLW   '/'
        CALL    WR2LCD
        MOVFF   first_number, second_number
        MOVLW   div_op
        MOVWF   operation
        RETURN

; ---------------- SHARP ROUTINE ----------------------
;
; CHECK WHICH OPERATION WAS SELECTED
;
; -----------------------------------------------------

SHARP:
        CALL    DEBOUNCE_RB6
        MOVLW   '='
        CALL    WR2LCD

        BTFSC   operation, 0        ; CHECK FOR SUM             (b'0000 0001')
        CALL    SUM
        BTFSC   operation, 1        ; CHECK FOR MINUS           (b'0000 0010')
        CALL    MINUS
        BTFSC   operation, 2        ; CHECK FOR MULTIPLICATION  (b'0000 0100')
        CALL    MULTIPLICATION
        BTFSC   operation, 3        ; CHECK FOR DIVISION        (b'0000 1000')
        CALL    DIVISION
        RETURN

; ---------------- SUM ROUTINE ----------------------
;
; CHECK WHICH OPERATION WAS SELECTED
;
; -----------------------------------------------------

SUM:
        MOVF    second_number, W
        ADDWF   first_number, F
        MOVFF   first_number, LATD
        RETURN

; ---------------- MINUS ROUTINE ----------------------
;
; CHECK WHICH OPERATION WAS SELECTED
;
; -----------------------------------------------------

MINUS:
        MOVF    first_number, W
        SUBWF   second_number, W
        MOVWF   LATD
        MOVWF   first_number
        RETURN

; ---------------- MULTIPLICATION ROUTINE ----------------------
;
; PERFORM A MULTIPLICATION BETWEEN THE 2 NUMBERS SELECTED.
; THE RESULT IS A NUMBER OF 8-bits
;
; --------------------------------------------------------------

MULTIPLICATION:
        TSTFSZ  first_number                ; CHECK IF first_number = 0
        BRA     MULTIPLICATION1             ; IF SO, THEN RETURN ZERO
        CLRF    LATD                        ; ELSE, CHECK second_number
        RETURN

MULTIPLICATION1:
        TSTFSZ  second_number               ; CHECK IF second_number = 0
        GOTO    MULTIPLICATION2             ; IF BOTH ARE NUMBERS <> 0, THEN MULTIPLY THEM
        CLRF    LATD                        ; IF NOT, RETURN 0
        RETURN

MULTIPLICATION2:
        MOVF    first_number, W             ; LOAD first_number INTO COUNTER AND
        MOVWF   COUNTER                     ; second_number INTO WREG TO PERFORM
        MOVF    second_number, W            ; A SUM LATER ON

MULTIPLICATION3:
        DECFSZ  COUNTER                     ; WHILE COUNTER IS NOT ZERO, IT MEANS
        GOTO    MANUAL_MUL                  ; THERE ARE STILL SUMS TO PERFORM
        MOVFF   second_number, LATD         ;
        MOVFF   second_number, first_number ; STORE THE RESULT AS THE LAST DIGIT PRESSED
        RETURN

MANUAL_MUL:
        ADDWF   second_number, F            ; LOOP FOR ADDING second_number to itself
        GOTO    MULTIPLICATION3             ;

; ---------------- DIVISION ROUTINE ----------------------
;
; PERFORM A DIVISION BETWEEN THE 2 NUMBERS SELECTED
; THE DIVISION GOES THIS WAY:
;
; second_number / first_number = COUNTER
;
; Example:  5 / 2 = 2
;           4 / 2 = 2
;           1 / 2 = 0
;           3 / 0 = 0
;
; --------------------------------------------------------

DIVISION:
        TSTFSZ  first_number                ; CHECK IF first_number IS 0
        BRA     DIVISION1                   ; IF SO, JUST RETURN
        CLRF    LATD                        ; A ZERO AND FINISH OPERATION
        RETURN                              ; IF NOT, JUMP TO DIVISION1

DIVISION1:
        MOVF    first_number, W             ; CHECK IF second_number IS
        CPFSLT  second_number               ; LESS THAN first_number. IF SO
        BRA     DIVISION2                   ; RETURN ZERO. IF NOT, JUMP TO
        MOVFF   COUNTER, LATD               ; DIVISION2 AND PERFORM THE OPERATION

DIVISION2:
        SUBWF   second_number, F            ; SUBSTRACT first_number FROM second_number
        INCF    COUNTER, F                  ; UNTIL THE RESULT IS LESS THAN first_number
        BRA     DIVISION1                   ; THEN RETURN COUNTER VALUE WHICH HOLDS THE ACTUAL RESULT

;--------------- ASTHERISK ROUTINE -------------
;
; CLEARS EVERYTHING
;
; ----------------------------------------------

ASTHERISK:
        CALL    DEBOUNCE_RB4                    ; CLEARS EVERYTHING
        CLRF    first_number
        CLRF    second_number
        CLRF    WREG
        BSF     LATA, LCD_EN
        BCF     LATA, LCD_RS
        MOVLW   1
        MOVWF   LATD
        BCF     LATA, LCD_EN
        CALL    LCDBUSY
        RETURN

; ------------ DEBOUNCE ROUTINE -------------------
;
; ROUTINE TO SKIP ANY BUTTON BOUNCING
;
; -------------------------------------------------

DEBOUNCE_RB4:
        BTFSS   PORTB, RB4
        GOTO    DEBOUNCE_RB4
        RETURN

DEBOUNCE_RB5:
        BTFSS   PORTB, RB5
        GOTO    DEBOUNCE_RB5
        RETURN

DEBOUNCE_RB6:
        BTFSS   PORTB, RB6
        GOTO    DEBOUNCE_RB6
        RETURN

DEBOUNCE_RB7:
        BTFSS   PORTB, RB7
        GOTO    DEBOUNCE_RB7
        RETURN

; ------------------------------ GET LCD STATUS -------------------------------------
;
; AS SUGGESTED, IT IS BETTER TO CHECK DIRECTLY IF THE LCD IS BUSY RATHER
; THAN JUST WAITING A FIXED AMMOUNT OF CYCLES BY EXECUTING A SOFTWARE DELAY.
; THE DB7 BIT PROVIDES THE INFORMATION ABOUT THE STATUS OF THE LCD. THE LCD RETURNS
; A HIGH LEVEL ON DB7 IF THE LCD IS STILL BUSY. THE LCD RETURNS A LOW LEVEL IF THE
; LCD IS NO LONGER BUSY AND READY TO RECEIVE AND EXECUTE A NEW COMMAND.
;
; -----------------------------------------------------------------------------------

LCDBUSY:
        SETF    TRISD           ; SET PORT D FOR INPUT
        BCF     LATA, LCD_RS
        BSF     LATA, LCD_RW    ; SET LCD FOR COMMAND MODE
        BSF     LATA, LCD_EN    ; SETUP TO READ BUSY FLAG
        MOVF    LATD, W         ; LCD E-LINE HIGH
        BCF     LATA, LCD_EN    ; READ BUSY FLAG + DDRAM ADDRESS
        ANDLW   b'10000000'     ; LCD E-LINE LOW
        BTFSS   STATUS, Z       ; CHECK BUSY FLAG, HIGH = BUSY
        GOTO    LCDBUSY

LCDNOTBUSY:
        BCF     LATA, LCD_RW
        CLRF    TRISD           ; SET PORTD FOR OUTPUT
        RETURN

END
