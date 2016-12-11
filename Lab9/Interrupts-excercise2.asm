RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
contador  EQU 0
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
;	JUMP VECTORS
;
		ORG		0X1000				; RESET VECTOR
		GOTO	MAIN
;
		ORG		0X1008				; HIGH INTERRUPT VECTOR
		GOTO	ISR_HIGH			; UNCOMMENT WHEN NEEDED
;
		ORG		0X1018				; LOW INTERRUPT VECTOR
;		GOTO	ISR_LOW				; UNCOMMENT WHEN NEEDED
;	RESOURCE INITIALIZATION

MAIN:
        MOVLB   15
        CLRF	ANSELD, BANKED		; SET ALL PINS AS DIGITAL
        BCF     TRISD,5             ; Salida de la señal
        BCF     LATD,5

        MOVLW   11000000b
        MOVWF   INTCON
        BSF     RCON,7

        BSF     PIE1,0              ; Habilita desborde del Timer1
        BSF     IPR1,0              ; Alta prioridad a la interrupcion del Timer1
        BCF     PIR1,0              ; Limpia la bandera de overflow del Timer1
        MOVLW   b'00110011'
        MOVWF   T1CON               ; Se usa el instruction clock (Fosc/4), Preescalador de 8, Oscilador secundario deshabilitado, Timer1 en 16 bit, se habilita timer1
        BCF     T1GCON,7            ; El timer1 cuenta sin importar el gate function
        MOVLW   0x0B
        MOVWF   TMR1H
        MOVLW   0xDC
        MOVWF   TMR1L

        CLRF    contador

LOOP:
        GOTO    LOOP

ISR_HIGH:
        BCF     INTCON,7            ; Deshabilitar interrupciones
        INCF    contador,1
        MOVLW   0x01
        CPFSEQ  contador
        GOTO    exit_ISR
        BTG     LATD,5              ; Cambiar valor de señal
        MOVLW   0xC2                ; Regresar a valor original
        MOVWF   TMR0H
        MOVLW   0xF7
        MOVWF   TMR0L
        CLRF    contador

exit_ISR:
        BCF     PIR1,0              ; Apagar bandera
        BSF     INTCON,7            ; Habilitar interrupciones
        RETFIE  FAST

END
