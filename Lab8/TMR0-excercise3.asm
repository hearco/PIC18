RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
VAR1        EQU	0			; VARIABLE PARA EL DELAY
VAR2        EQU	1			; VARIABLE PARA EL DELAY
ContDelays  EQU 2           ; CONTADOR DE DELAYS, SIRVE PARA SABER CUANDO YA PASO UN SEGUNDO


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
;		GOTO	ISR_HIGH			; UNCOMMENT WHEN NEEDED
;
		ORG		0X1018				; LOW INTERRUPT VECTOR
;		GOTO	ISR_LOW				; UNCOMMENT WHEN NEEDED
;	RESOURCE INITIALIZATION

;
; ---------------------------------------INICIALIZACION DE LAS VARIABLES Y REGISTROS A UTILIZAR------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
        MOVLB   15
        CLRF    ANSELA, BANKED
        CLRF	ANSELB, BANKED		; SET ALL PINS AS DIGITAL
        CLRF    TRISB               ; Puerto B es salida
        CLRF    LATB                ; LIMPIO EL PUERTO B
        CLRF    TRISD
        CLRF    LATD
        BSF     TRISC, 0            ; RA4 como enrada
        CLRF    ContDelays          ; ContDelays = 0
        MOVLW   b'01101000'         ; TIMER = 8 BITS, TRANSICION EXTERNA, PREESCALADOR = 256
        MOVWF   T0CON               ; Valor de prescala es 128
        CLRF    INTCON              ; Se limpia bandera de timer OV

OtraVez:
        MOVLW   0xF6                ; Valor inicial para
        MOVWF   TMR0L               ; parte baja del timer
        MOVWF   LATD
        BSF     T0CON, 7            ; ENCIENDO EL TIMER
;
; --------------------------------------------------------CHECA BOTON--------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
LOOP:
        BTFSS   PORTC, 0
        CALL    Boton
        BTFSS   INTCON,2            ; Esperar hasta que la bandera de
        GOTO    LOOP
        GOTO    Overflow

Boton:
        CALL    EvitarRebotes
        BTFSS   PORTC, 0
        GOTO    Boton
        INCF    TMR0L, 1
        MOVFF   TMR0L, LATD
        GOTO    CHECAROverflow
  QW:   RETURN

CHECAROverflow:
        MOVLW   0X00
        CPFSEQ  TMR0L
        GOTO    QW
        GOTO    PRENDER

PRENDER:
        BSF     INTCON, 2
        GOTO    QW

Overflow:
        BTG     LATB, 6            ; Cambiar de valor el pin conectado al LED
        BCF     INTCON,2            ; Limpiar bandera nuevamente
        BCF     T0CON, 7            ; APAGO EL TIMER
        GOTO    OtraVez             ; Regresar al loop
;
; ------------------------------------------------RUTINA PARA EVITAR REBOTES-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
EvitarRebotes:
        CALL    Delay               ; Retraso
        INCF    ContDelays, 1       ; CONTADOR PARA MEDIR LOS SEGUNDOS QUE HAN PASADO
        MOVLW   4                   ; W = 1
        CPFSEQ  ContDelays          ; CHECO SI YA PASO UN SEGUNDO
        GOTO    EvitarRebotes       ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador     ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                      ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR

Delay:
        MOVLW   0XFF                ; CARGO EL VLOR MAX POSIBLE EN W
        MOVWF   VAR1                ; VAR1 = 0XFF
        MOVWF   VAR2                ; VAR2 = 0XFF

 LOOP1:
            DECFSZ  VAR2            ; DECREMENTO LA VARIABLE 2
            GOTO    LOOP1           ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            DECFSZ  VAR1            ; SI ES 0, DECREMENTO VARIANLE 1
            GOTO    LOOP1           ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            RETURN                  ; SI ES 0, TERMINO EL DELAY
; ------------------------------------------------RUTINA PARA LIMPIAR EL CONTADOR DE DELAYS----------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
LimpiarContador:
        CLRF    ContDelays
        RETURN
;
;
END
