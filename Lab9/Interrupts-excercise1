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
TimersCont  EQU 4
contador    EQU 5
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
        CLRF	ANSELB, BANKED		; SET ALL PINS AS DIGITAL
        CLRF	ANSELD, BANKED		; SET ALL PINS AS DIGITAL
        BSF     TRISB,0             ; Entrada de interrupcion
        BCF     TRISD,5             ; Salida al LED
        BCF     TRISD,7             ; Salida al LED
        BCF     LATD,5              ; Limpiar LED
        BCF     LATD,7              ; Limpiar LED
        MOVLW   b'11010000'
        MOVWF   INTCON
        BSF     RCON,7              ; Habilitar prioridades
        CLRF    contador
        CLRF    ContDelays
        GOTO    LOOP

LOOP:
        GOTO    LOOP                ;   y hacer un cambio

ISR_HIGH:
        CALL    EvitarRebotes
        BCF     INTCON,7            ; Apagar interrupciones
        GOTO    encargar_del_ruido

encargar_del_ruido:
        BSF     LATD,7              ; Prender señal "limpia" del boton
        CALL    EvitarRebotes
        BTFSS   PORTB,0             ; Esperar a que se suelte el boton
        GOTO    encargar_del_ruido
        BCF     LATD,7              ; Apagar señal "limpia" del boton
        BCF     INTCON,1            ; Apagar bandera de interrupcion
        INCF    contador, 1
        MOVLW   10
        CPFSEQ  contador
        GOTO    exit_ISR
        GOTO    ten
ten:
        BTG     LATD,5              ; Hacer toggle al LED
        CLRF    contador
        GOTO    exit_ISR
exit_ISR:
        BSF     INTCON,7            ; Encender interrupciones
        CALL    EvitarRebotes
        RETFIE  FAST                ; Regresar a ciclo principal

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
