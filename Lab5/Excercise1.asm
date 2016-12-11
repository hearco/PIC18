; Created by: Ariel Almendáriz
;
; Lab 5: I/O ports
; Excersice 1
; Description:
;   - Select a push button to make a rotation to the left when pressed. When the most left led is reached, start over from the right.
;   - Select a push button to make a rotation to the right when pressed. When the most right led is reached, start over from the left.
;   - Select a push button to make a rotation to one side. When the end of that side is reached, now continue rotating to the other side.
;
; Consider the next:
;   - The led should be blinking all the time for one second.
;   - The led should be blinking in one position forever until a push button is pressed.
;   - To stop a routine, press the same push button that started it. Next, the led should be blinking in the last position it was.
;   - Routines are not preemtive. That is, when a push button was pressed, no other push button can affect the actual routine.
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
VarPORTB    EQU 2           ; VALOR DEL PUERTO ACTUAL
Vale1Seg    EQU 3           ; VARIABLE DE 1 SEGUNDO
ContDelays  EQU 4           ; CONTADOR DE DELAYS, SIRVE PARA SABER CUANDO YA PASO UN SEGUNDO
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
; ------------------------------------------------VARIABLES INITIALIZATION AND REGISTERS TO USE------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
        MOVLB   15
        CLRF    ANSELC, BANKED  ; PORT C AS DIGITAL
        CLRF	ANSELB, BANKED	; PORT B AS DIGITAL
		CLRF    TRISB           ; PORT B AS OUTPUT (EACH PIN CONNECTED TO A LED TO SHOW THE ROUTINES)
        BSF     TRISC, 0        ; PIN 0 (RC0) AS INPUT (PUSH BUTTON 1)
        BSF     TRISC, 1        ; PIN 1 (RC1) AS INPUT (PUSH BUTTON 2)
        BSF     TRISC, 2        ; PIN 2 (RC2) AS INPUT (PUSH BUTTON 3)
        CLRF    LATB            ; CLEAR PORT C FOR ANY POSSIBLE GARBIGE
        CLRF    LATC            ; CLEAR PORT C FOR ANY POSSIBLE GARBIGE
        CLRF    ContDelays      ; VARIABLE TO HOLD THE AMMOUNT OF DELAYS TO USE
        MOVLW   0X01            ;
        MOVWF   VarPORTB        ; VARIABLE TO BE USED AS A TEMPORAL BEFORE SHOWING THE RESULT TO PORT B
;
; ---------------------------------------------------CICLO DE PARPADEO-------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
PARPADEO:
        MOVFF   VarPORTB, LATB  ; LATB = VarPORT (SOLO CUANDO ENTRA EL CICLO POR PRIMERA VEZ VALE 0X01
        CALL    TESTS           ; LLAMO LA RUTINA PARA CHECAR BOTONES
        CALL    Delay1Seg       ; ESPERO UN SEGUNDO ANTES DE APAGAR EL LED
        CLRF    LATB            ; LATB = 0
        CALL    TESTS           ; LLAMO LA RUTINA PARA CHECAR BOTONES
        CALL    Delay1Seg       ; ESPERO UN SEGUNDO ANTES DE ENCENDER EL LED
        GOTO    PARPADEO        ; REGRESA A HACER EL PARPADEO
;
; -----------------------------------------------EVALUACION DE BOTONES-------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
TESTS:
        BTFSS   PORTC, 0        ; CHECAR SI SE PRESIONO RC0
        GOTO    CorrimientoIzq  ; SI ES ASI, EMPIEZA EL CORRIMIENTO HACIA LA IZQUIERDA
        BTFSS   PORTC, 1        ; SI NO, CHECA SI SE PRESIONO RC1
        GOTO    CorrimientoDer  ; SI ES ASI, EMPIZA EL CORRIMIENTO HACIA LA DERECHA
        BTFSS   PORTC, 2        ; CHECAR SI SE PRESIONO RC2
        GOTO    IzqDer          ; SI ES ASI HACE CORRIMIENTO DE IZQ - DER Y VICEVERSA
        RETURN
;
; ---------------------------------------------------CORRIMIENTO HACIA LA IZQUIERDA------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CorrimientoIzq:
        CALL    Delay1Seg       ; RETRASO PARA ELIMINAR REBOTES
        RLNCF   VarPORTB        ; HAGO CORRIMIENTO SOBRE LA VARIABLE
        MOVFF   VarPORTB, LATB  ; MUESTRO LA VARIABLE EN EL PUERTO B
        BTFSS   PORTC, 0        ; CHECA SI SE PRESIONO EL BOTON
        GOTO    RETARDO         ; SI ES ASI, REGRESO A PARPADEO
        CALL    Delay1Seg       ; SI NO, MANDO A LLAMAR UN DELAY DE 1 SEGUNDO
        CLRF    LATB            ; APAGO EL BIT
        BTFSS   PORTC, 0        ; CHECO EL BOTON
        GOTO    RETARDO         ; SI SE PRESIONO, VOY A PARPADEO
        GOTO    CorrimientoIzq  ; SI NO, SIGO HACIENDO CORRIMIENTO
;
; ---------------------------------------------------CORRIMIENTO HACIA LA DERECHA--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CorrimientoDer:
        CALL    Delay1Seg       ; RETRASO PARA ELIMINAR REBOTES
        RRNCF   VarPORTB        ; HAGO CORRIMIENTO SOBRE LA VARIABLE
        MOVFF   VarPORTB, LATB  ; MUESTRO LA VARIABLE EN EL PUERTO B
        BTFSS   PORTC, 1        ; CHECA SI SE PRESIONO EL BOTON
        GOTO    RETARDO         ; SI ES ASI, REGRESO A PARPADEO
        CALL    Delay1Seg       ; SI NO, MANDO A LLAMAR UN DELAY DE 1 SEGUNDO
        CLRF    LATB            ; APAGO EL BIT
        BTFSS   PORTC, 1        ; CHECO EL BOTON
        GOTO    RETARDO         ; SI SE PRESIONO, VOY A PARPADEO
        GOTO    CorrimientoDer  ; SI NO, SIGO HACIENDO CORRIMIENTO
;
; ---------------------------------------------------CORRIMIENTO IZQ / DER / IZQ--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
IzqDer:
        BTFSS   LATB, 0         ; CHECO SI EL LED PRENDIDO SE ENCUENTRA EN RB0
        GOTO    Derecha         ; SI ES ASI, AHORA HACE CORRIMIENTO HACIA LA DERECHA

Izquierda:
        CALL    Delay1Seg
        CLRF    LATB
        BTFSS   PORTC, 2
        GOTO    RETARDO
        CALL    Delay1Seg
        RLNCF   VarPORTB        ; IF NOT, ROTATES TO THE LEFT
        MOVFF   VarPORTB, LATB  ;
        BTFSC   LATB, 7         ; CHECKS IF CHANGE IN DIRECTION IS NEEDED
        GOTO    Derecha         ; IF SO, ROTATES TO THE RIGHT
        BTFSS   PORTC, 2
        GOTO    RETARDO
        GOTO    Izquierda          ; SI NO, CONTINUO EL CORRIMIENTO
;
Derecha:
        CALL    Delay1Seg
        CLRF    LATB
        BTFSS   PORTC, 2
        GOTO    RETARDO
        CALL    Delay1Seg
        RRNCF   VarPORTB            ; HACE UN CORRIMMIENTO DEL PUERTO B A LA DERECHA
        MOVFF   VarPORTB, LATB      
        BTFSC   LATB, 0
        GOTO    Izquierda
        BTFSS   PORTC, 2
        GOTO    RETARDO
        GOTO    Derecha         ; SI NO, HAGO CORIMIENTO A LA DERECHA
;
; ---------------------------------------------------RUTINA PARA ELMINAS REBOTES---------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
RETARDO:
        CALL    EvitarRebotes
        GOTO    PARPADEO

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
        MOVLW   12              ; W = 19 segundo
        CPFSEQ  ContDelays      ; CHECO SI YA PASO UN SEGUNDO
        GOTO    Delay1Seg       ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                  ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR
;
; ------------------------------------------------RUTINA PARA LIMPIAR EL CONTADOR DE DELAYS----------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
EvitarRebotes:
        CALL    Delay           ; Retraso
        INCF    ContDelays, 1   ; CONTADOR PARA MEDIR LOS SEGUNDOS QUE HAN PASADO
        MOVLW   1               ; W = 1
        CPFSEQ  ContDelays      ; CHECO SI YA PASO UN SEGUNDO
        GOTO    EvitarRebotes         ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                  ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR

; ------------------------------------------------RUTINA PARA LIMPIAR EL CONTADOR DE DELAYS----------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
LimpiarContador:
        CLRF    ContDelays
        RETURN
;
;
	END

