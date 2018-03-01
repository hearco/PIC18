RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
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
        SETF    ANSELA, BANKED     ;SE CONFIGURA EL PUERTO A COMO ENTRADA ANALOGICA
        SETF    ANSELC, BANKED     ;EL PUERTO C COMO DIGITAL
        CLRF    TRISC              ;EL PUERTO C COMO SALIDA
;
; ---------------------------------------------------CONFIGURACION DEL ADC---------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
        MOVLW   b'00000011'     ; ENTRADA AN0 Y ENCENDIENDO EL MODULO
        MOVWF   ADCON0          ;
        MOVLW   b'00101100'     ; JUSTIFICADO A LA IZQUIERDA Y TIEMPO DE ADQUISICION DE 12TD Y UN RELOJ DE FOSC/4
        MOVWF   ADCON2          ; 
        MOVLW   b'00001110'     ; SE CONFIGURAN COMO VOLTAJES DE REFERENCIA VDD Y VSS Y SOLO AN0 ANALOGICA
        MOVWF   ADCON1
;
; ---------------------------------------------------CONFIGURACION DEL PWM---------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
        MOVLW   b'11111111'
        MOVWF   PR2             ;SE CONFIGURA PR2 CON EL VALOR DESEADO
        MOVLW   b'01000000'     ;SE CONFIGURAN LOS REGISTROS QUE GUARDARAN LOS VALORES DE LA PARTE POSITIVA
        MOVWF   CCPR1L
        MOVWF   CCPR1H
        BCF     TRISC,CCP1      ;CCP1 como salida
        MOVLW   b'10000001'
        MOVWF   T3CON           ;SE CONFIGURA TMR3
        CLRF    TMR2
        MOVLW   b'00000110'
        MOVWF   T2CON           ;SE CONFIGURA TMR2
        MOVLW   b'00001100'     ;SE CONFIGURA EL MODULO CCP1CON PARA QUE TRABAJE COMO PWM
        MOVWF   CCP1CON


CONVERTIR:
        BTFSC   ADCON0, DONE     ;VERIFICA SI LA CONVERSION HA TERMINADO
        GOTO    CONVERTIR
        MOVFF   ADRESH, CCPR1L   ;MUEVE EL RESULTADO DE LA CONVERSION A LA PARTE BAJA DEL PWM
        BSF     ADCON0, DONE     ;LIMPIA EL STATUS DEL A/D
        GOTO    CONVERTIR

END
