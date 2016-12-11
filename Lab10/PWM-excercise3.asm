RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
REG0    EQU 0
REG1    EQU 1
REG2    EQU 2
REG3    EQU 3
;
;
;	*** ONLY NEEDED FOR SOFTWARE SIMULATION ***
;
		ORG		0					; RESET VECTOR
		GOTO	0X1000
;
		ORG		0X08				; HIGH INTERRUPT VECTOR
		GOTO	0X1008
;
		ORG		0X18				; LOW INTERRUPT VECTOR
		GOTO	0X1018
;
;	*** END OF CODE FOR SOFTWARE SIMULATION ***
;
;
;	*** START OF PROGRAM ***
;
;	JUMP VECTORS
;
		ORG		0X1000				; RESET VECTOR
		GOTO	MAIN
;
		ORG		0X1008				; HIGH INTERRUPT VECTOR
;		GOTO	ISR_HIGH			; UNCOMMENT WHEN NEEDED
;
		ORG		0X1018				; LOW INTERRUPT VECTOR
;		GOTO	ISR_LOW				; UNCOMMENT WHEN NEEDED
;
;
;	RESOURCE INITIALIZATION
;
MAIN:
        MOVLB   15
        CLRF	ANSELC, BANKED  ; SET ALL PINS AS DIGITAL
        CLRF    ANSELD, BANKED
        CLRF    TRISD
        BSF     TRISC,CCP1      ; CCP1 como entrada
        MOVLW   b'10000001'     ; Selecciona Timer1 como reloj principal de CCP1-bits<6-3> 00

        MOVWF   T3CON, 0        ; Timer3 en modo de 16 bits
        MOVLW   b'10000001'     ; Habilitar timer1 en modo 16 bits, preescalador de 1

        MOVWF   T1CON, 0
        MOVLW   b'00000101'     ; CCP1 en modo captura de cada rising edge

        MOVWF   CCP1CON, 0
        BCF     PIE1, CCP1IE

        CALL    PULSE
        MOVFF   CCPR1L, REG0
        MOVFF   CCPR1H, REG1

        CALL    PULSE
        CLRF    CCP1CON
        MOVFF   CCPR1L, REG2

        MOVFF   CCPR1H, REG3

        CALL    RESULT
        GOTO    $


PULSE:
        BCF     PIR1, CCP1IF
CHECK:
        BTFSS   PIR1, CCP1IF
        GOTO    CHECK
        RETURN

RESULT:
        MOVF    REG0, W
        SUBWF   REG2, 1

        MOVF    REG1, W
        SUBWF   REG3, 1
        MOVFF   REG3, PORTD
        RETURN

END
