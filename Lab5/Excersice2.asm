;CREADOR POR:
;Ariel Almendáriz
;PRACTICA NO. 5 ejercicio 2
;
;
RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
VAR1        EQU	0			; VARIABLE PARA EL DELAY
VAR2        EQU	1			; VARIABLE PARA EL DELAY
VarCERO     EQU	2			; VARIABLE DE COMPARACION
VarPORTB    EQU 3           ; VALOR DEL PUERTO ACTUAL
ContDelays  EQU 5           ; CONTADOR DE DELAYS, SIRVE PARA SABER CUANDO YA PASO UN SEGUNDO
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
;
;
; ---------------------------------------INICIALIZACION DE LAS VARIABLES Y REGISTROS A UTILIZAR------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
        MOVLB   15
        CLRF	ANSELC, BANKED  ; PUERTO C COMO DIGITAL
        CLRF	ANSELB, BANKED	; PUERTO B COMO DIGITAL
		CLRF    TRISB           ; CONFIGURO EL PUERTO B COMO SALIDA
        SETF    TRISC           ; PUERTO C COMO ENTRADA
        CLRF    LATB            ; LIMPIO LA INFORMACION DEL PUERTO B
        CLRF    ContDelays      ; ContDelays = 0
;
; ---------------------------------------------------CICLO DE INICIO---------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
INICIO:
        CLRF    LATB            ; LATB = 0
        GOTO    TESTS           ; HAGO UNA SUBRUTINA PARA VER SI SE PRESIONO UN BOTON
        GOTO    INICIO          ; VUELVO AL INICIO
;
; ---------------------------------------------------CHEQUEO DE BOTONES------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
TESTS:
        BTFSS   PORTC, 0        ; CHECAR SI SE PRESIONO RC0
        GOTO    ConfirmarBCD    ; SI ES ASI, VERIFICA SI ES INCREMENTO O DECREMENTO EN BCD
        BTFSS   PORTC, 1        ; SI NO, CHECA SI SE PRESIONO RC1
        GOTO    ConfirmarGRAY   ; SI ES ASI, VERIFICA SI ES INCREMENTO O DECREMENTO EN GRAY
        GOTO    INICIO          ; SI NO SE PRESIONO NADA, REGRESA AL INICIO
;
; ----------------------------------------------VERIFICAR EL TIPO DE CONTADOR BCD--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
ConfirmarBCD:
        CALL    EvitarRebotes   ; ELIMINO REBOTES
        BTFSS   PORTC, 2        ; CHECO SI SE PRESIONO RC2
        GOTO    incBCD          ; SI ES ASI, HAGO INCREMENTO EN BCD
        BTFSS   PORTC, 6        ; SI NO, CHECO SI SE PRESIONO RC6
        GOTO    decBCD          ; SI ES ASI, HAGO DECREMENTO EN BCD
        GOTO    TESTS           ; SI NO SE PRESIONO NADA, REGRESO CHECAR LOS BOTONES
;
; ----------------------------------------------VERIFICAR EL TIPO DE CONTADOR GRAY-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
ConfirmarGRAY:
        CALL    EvitarRebotes
        BTFSS   PORTC, 2
        GOTO    incGRAY
        BTFSS   PORTC, 6
        GOTO    decGRAY
        GOTO    TESTS
;
; ----------------------------------------------------INCREMENTO EN GRAY-----------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
incGRAY:
        CALL    Delay1Seg
        BTG     LATB, 0
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 1
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 0
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 2
        MOVLW   4
        CPFSEQ  LATB
        GOTO    incGRAY
        GOTO    LimpiarGRAY

LimpiarGRAY:
        CLRF    LATB
        GOTO    incGRAY
;
; ----------------------------------------------------DECREMENTO EN GRAY-----------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
decGRAY:
        MOVLW   4
        MOVWF   LATB
decGRAY2:
        CALL    Delay1Seg
        BTFSC   PORTC,6
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 0
        CALL    Delay1Seg
        BTFSC   PORTC,6
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 1
        CALL    Delay1Seg
        BTFSC   PORTC,6
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 0
        CALL    Delay1Seg
        BTFSC   PORTC,6
        GOTO    INICIO
        BTFSC   PORTC, 1
        GOTO    INICIO
        BTG     LATB, 2
        CLRF    WREG
        CPFSEQ  LATB
        GOTO    decGRAY2
        GOTO    LimpiarGRAY2

LimpiarGRAY2:
        CLRF    LATB
        GOTO    decGRAY
;
; ----------------------------------------------------INCREMENTO EN BCD------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
incBCD:
        MOVLW   252
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   96
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   218
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   242
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   102
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   182
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   190
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   224
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   254
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   230
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   238
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   62
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   156
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   122
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   158
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   142
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 2
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        GOTO    incBCD
;
; ----------------------------------------------------DECREMENTO EN BCD------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
decBCD:
        MOVLW   142
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   158
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   122
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   156
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   62
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   238
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   230
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   254
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   224
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   190
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   182
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   102
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   242
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   218
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   96
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        MOVLW   252
        MOVWF   LATB
        CALL    Delay1Seg
        BTFSC   PORTC, 6
        GOTO    INICIO
        BTFSC   PORTC, 0
        GOTO    INICIO
        GOTO    decBCD
;
; ------------------------------------------------------------Delay generico-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
Delay:
        MOVLW   0XFF            ; CARGO EL VLOR MAX POSIBLE EN W
        MOVWF   VAR1            ; VAR1 = 0XFF
        MOVWF   VAR2            ; VAR2 = 0XFF

 LOOP1:
            DECFSZ  VAR2        ; DECREMENTO LA VARIABLE 2
            GOTO    LOOP1       ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            DECFSZ  VAR1        ; SI ES 0, DECREMENTO VARIANLE 1
            GOTO    LOOP1       ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            RETURN              ; SI ES 0, TERMINO EL DELAY
;
; ------------------------------------------------------RETRASO DE 1 SEGUNDO-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
Delay1Seg:
        CALL    Delay           ; Retraso
        INCF    ContDelays, 1   ; CONTADOR PARA MEDIR LOS SEGUNDOS QUE HAN PASADO
        MOVLW   40
        CPFSEQ  ContDelays      ; CHECO SI YA PASO UN SEGUNDO
        GOTO    Delay1Seg       ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                  ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR

LimpiarContador:
        CLRF    ContDelays
        RETURN
;
; -----------------------------------------------------RUTINA PARA EVITAR REBOTES--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
EvitarRebotes:
        CALL    Delay           ; Retraso
        INCF    ContDelays, 1   ; CONTADOR PARA MEDIR LOS SEGUNDOS QUE HAN PASADO
        MOVLW   2
        CPFSEQ  ContDelays      ; CHECO SI YA PASO UN SEGUNDO
        GOTO    EvitarRebotes         ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                  ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR

	END
