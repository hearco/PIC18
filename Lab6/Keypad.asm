RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
VAR1                EQU 0
VAR2                EQU 1
PrimerNumero        EQU 2
copiaDelNumero      EQU	3
TipoOper            EQU 6
ContDivision        EQU 7
ContMultiplicacion  EQU 8
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
; ---------------------------------------INICIALIZACION DE LAS VARIABLES Y REGISTROS A UTILIZAR------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
        MOVLB   15                  ; ACTIVO EL ANSELD
        CLRF	ANSELD, BANKED      ; PUERTO D COMO DIGITAL
        CLRF	ANSELB, BANKED		; PUERTO B COMO DIGITAL
		MOVLW   0xF0                ; PARTE ALTA ES ENTRADA (PUERTO B)
        MOVWF   TRISB               ; PARTE BAJA ES SALIDA  (PUERTO B)
        CLRF    TRISD               ; PUERTO D ES SALIDA
        CLRF    LATD                ; LATD = 0
        BCF     INTCON2,7           ; SE ACTIVAN LAS RESISTENCIAS PULL-UP
        CLRF    TipoOper            ; Bandera para identificar operacion
        CLRF    ContDivision
        MOVLW   1
        MOVWF   ContMultiplicacion
;
; ------------------------------------------------------RUTINA PARA CHECAR RENGLONES-----------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
ChecarRenglon1:
        BCF     LATB,0              ; ACTIVO EL PRIMER RENGLON
        BSF     LATB,1              ; DESACTIVO EL SEGUNDO RENGLON
        BSF     LATB,2              ; DESACTIVO EL TERCER RENGLON
        BSF     LATB,3              ; DESACTIVO EL CUARTO RENGLON
        BTFSS   PORTB,4             ; COMPARO CON COLUMNA 1
		CALL    UNO                 ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 1
		BTFSS   PORTB,5             ; SI NO, COMPARO CON COLUMNA 2
		CALL    DOS                 ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 2
		BTFSS   PORTB,6             ; SI NO, COMPARO CON COLUMNA 3
		CALL    TRES                ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 3
        BTFSS   PORTB,7             ; COMPARO CON COLUMNA 4
        CALL    AH                  ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA PREPARAR UNA SUMA

ChecarRenglon2:
        BSF     LATB,0              ; DESACTIVO EL PRIMER RENGLON
        BCF     LATB,1              ; ACTIVO EL SEGUNDO RENGLON
        BSF     LATB,2              ; DESACTIVO EL TERCER RENGLON
        BSF     LATB,3              ; DESACTIVO EL CUARTO RENGLON
        BTFSS   PORTB,4             ; COMPARO CON COLUMNA 1
		CALL    CUATRO              ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 4
		BTFSS   PORTB,5             ; SI NO, COMPARO CON COLUMNA 2
		CALL    CINCO               ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 5
		BTFSS   PORTB,6             ; SI NO, COMPARO CON COLUMNA 3
		CALL    SEIS                ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 6
		BTFSS   PORTB,7             ; COMPARO CON COLUMNA 4
        CALL    B                   ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA PREPARAR UNA RESTA

ChecarRenglon3:
        BSF     LATB,0              ; DESACTIVO EL PRIMER RENGLON
        BSF     LATB,1              ; DESACTIVO EL SEGUNDO RENGLON
        BCF     LATB,2              ; ACTIVO EL TERCER RENGLON
        BSF     LATB,3              ; DESACTIVO EL CUARTO RENGLON
        BTFSS   PORTB,4             ; COMPARO CON COLUMNA 1
		CALL    SIETE               ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 7
		BTFSS   PORTB,5             ; SI NO, COMPARO CON COLUMNA 2
		CALL    OCHO                ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 8
		BTFSS   PORTB,6             ; SI NO, COMPARO CON COLUMNA 3
		CALL    NUEVE               ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 9
        BTFSS   PORTB,7             ; SI NO, COMPARO CON COLUMNA 4
        CALL    CH                  ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA PREPARAR UNA MULTIPLICACION

ChecarRenglon4:
        BSF     LATB,0              ; DESACTIVO EL PRIMER RENGLON
        BSF     LATB,1              ; DESACTIVO EL SEGUNDO RENGLON
        BSF     LATB,2              ; DESACTIVO EL TERCER RENGLON
        BCF     LATB,3              ; ACTIVO EL CUARTO RENGLON
        BTFSS   PORTB,4             ; COMPARO CON COLUMNA 1
		CALL    ASTERISCO           ; SI SE PRESIONA, NO REALIZA NADA
		BTFSS   PORTB,5             ; SI NO, COMPARO CON COLUMNA 2
		CALL    CERO                ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA ESCRIBIR UN 0
		BTFSS   PORTB,6             ; SI NO, COMPARO CON COLUMNA 3
		CALL    GATO                ; SI SE PRESIONA, SE LLEVA ACABO UNA SUMA, RESTA, MULTIPLICACION O DIVISON SEGUN CORRESPONDA
        BTFSS   PORTB,7             ; SI NO, COMPARO CON COLUMNA 4
        CALL    D                   ; SI SE PRESIONA, SE REALIZA LA RUTINA PARA PREPARAR UNA DIVISION

        GOTO ChecarRenglon1         ; SI NO SE PRESIONA NADA, REGRESO A CHECAR EL TECLADO ENTERO
;
; ---------------------------------------------------------RUTINA PARA ESCRIBIR CERO-----------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CERO:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        CLRF    LATD                ; LATD = 0
        MOVFF   LATD, PrimerNumero  ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR3             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR UNO---------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
UNO:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   0x01                ; W = 1
        MOVWF   LATD                ; LATD = 1
        MOVWF   PrimerNumero        ; COPIO EL 1 EN UNA VARIABLE AUXILIAR, PrimerNumero = 1
        CALL    CHECAR0             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR DOS---------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
DOS:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   0x02                ; W = 2
        MOVWF   LATD                ; LATD = 2
        MOVWF   PrimerNumero        ; COPIO EL 2 EN UNA VARIABLE AUXILIAR, PrimerNumero = 2
        CALL    CHECAR1             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR TRES--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
TRES:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   0x03                ; W = 3
        MOVWF   LATD                ; LATD = 3
        MOVWF   PrimerNumero        ; COPIO EL 3 EN UNA VARIABLE AUXILIAR, PrimerNumero = 3
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR CUATRO------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CUATRO:
        CALL    DELAY
        MOVLW   0x04
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR0
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR CINCO-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CINCO:
        CALL    DELAY
        MOVLW   0x05
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR1
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR SEIS--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
SEIS:
        CALL    DELAY
        MOVLW   0x06
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR SIETE-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
SIETE:
        CALL    DELAY
        MOVLW   0x07
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR0
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR OCHO--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
OCHO:
        CALL    DELAY
        MOVLW   0x08
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR NUEVE-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
NUEVE:
        CALL    DELAY
        MOVLW   0x09
        MOVWF   LATD
        MOVWF   PrimerNumero
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA SUMAR----------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
AH:
        CALL    DELAY
        CALL    copiarNUMERO             ; Cambia el valor anteriormente almacenado en a
        BSF     TipoOper,7                 ;     a la variable b
        BCF     TipoOper,6                 ; Y señala en f que se realizara una suma
        BCF     TipoOper,5                 ;    con el valor 0x80
        BCF     TipoOper,4
        CALL    CHECAR0
        RETURN

SUMA:
        MOVF    copiaDelNumero,0
        ADDWF   PrimerNumero,0               ; Sum a y b.
        MOVWF   LATD              ; Despliega el resultado en los LEDS
        MOVWF   PrimerNumero                 ; Y lo guarda en a
        RETURN
;
; --------------------------------------------------------RUTINA PARA RESTAR-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
B:
        CALL    DELAY
        CALL    copiarNUMERO              ; Cambia el valor anteriormente almacenado en a
        BCF     TipoOper,7                 ;     a la variable b
        BSF     TipoOper,6                 ; Y señala en f que se realizara una resta
        BCF     TipoOper,5                 ;    con el valor 0x40
        BCF     TipoOper,4
        CALL    CHECAR1
        RETURN

RESTA:
        MOVF    PrimerNumero,0
        SUBWF   copiaDelNumero,0               ; Resta b de a
        MOVWF   LATD              ; Depsliega el resultado en los LEDS
        MOVWF   PrimerNumero                 ; Y lo guarda en a
        RETURN
;
; --------------------------------------------------------RUTINA PARA MULTIPLICAR--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CH:
        CALL    DELAY
        CALL    copiarNUMERO              ; Cambia el valor anteriormente almacenado en a
        BCF     TipoOper,7                ;     a la variable b
        BCF     TipoOper,6                ; Y señala en f que se realizara una multiplicaion
        BSF     TipoOper,5                ;    con el valor 0x20
        BCF     TipoOper,4
        CALL    CHECAR3
        RETURN

MULTIPLICACION:
        MOVLW   0                   ; W = 0
        CPFSEQ  PrimerNumero        ; CHECO SI MI ULTIMO NUMERO TECLEADO ES 0
        GOTO    ConfirmarCero        ; SI NO, SUMO LAS VECES NECESARIAS
        CALL    MostrarCero                ; SI ES ASI, MI RESULTADO ES 0
        RETURN

ConfirmarCero:
        MOVLW   0
        CPFSEQ  copiaDelNumero
        GOTO    SumaMultiple
        CALL    MostrarCero
        GOTO    KL

SumaMultiple:
        MOVF    PrimerNumero, 0
        CPFSLT  ContMultiplicacion
        GOTO    MostrarMult
        MOVF    copiaDelNumero, 0
        Suma2:
                ADDWF   copiaDelNumero, 1
                INCF    ContMultiplicacion
                MOVF    PrimerNumero, 0
                CPFSLT  ContMultiplicacion
                GOTO    MostrarMult
                GOTO    Suma2

MostrarMult:
        MOVFF   copiaDelNumero, LATD
        MOVLW   1
        MOVWF   ContMultiplicacion
        GOTO    KL

MostrarCero:
        CLRF    LATD
        RETURN

;
; --------------------------------------------------------RUTINA PARA DIVIDIR--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
D:
        CALL    DELAY
        CALL    copiarNUMERO             ; Cambia el valor anteriormente almacenado en a
        BCF     TipoOper,7                 ;     a la variable b
        BCF     TipoOper,6                 ; Y señala en f que se realizara una suma
        BCF     TipoOper,5                 ;    con el valor 0x80
        BSF     TipoOper,4
        CALL    CHECAR0
        RETURN

DIVISION:
        MOVF    PrimerNumero,0
        CPFSLT  copiaDelNumero        
        GOTO    InContDiv                 ; Y posteriormente a la variable a
        GOTO    MostrarResultado

MostrarResultado:
        MOVFF   ContDivision, LATD
        CLRF    ContDivision
        RETURN

InContDiv:
        MOVF    PrimerNumero,0
        SUBWF   copiaDelNumero,1          ; Multiplica a y b
        INCF    ContDivision, 1
        GOTO    DIVISION
;
; --------------------------------------------------------RUTINA PARA REALIZAR OPERACIONES-----------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
GATO:
        CALL    DELAY
        BTFSC   TipoOper,7         ; Se verifica el valor de la bandera f
        CALL    SUMA               ; y se llama a la rutina con la operacion adecuada
        BTFSC   TipoOper,6
        CALL    RESTA
        BTFSC   TipoOper,5
        CALL    MULTIPLICACION

        KL:
            BTFSC   TipoOper,4
            CALL    DIVISION
            CALL    CHECAR2
            RETURN
;
; --------------------------------------------------------RUTINA PARA COPIAR EL PRIMER NUMERO INGRESADO----------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
copiarNUMERO:
        MOVFF    PrimerNumero, copiaDelNumero              ; Mueve el valor de a al
        RETURN
;
; --------------------------------------------------------RUTINA PARA EL ASTERISC--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
ASTERISCO:
        CALL    DELAY              ; No tiene utilidad esta rutina
        CALL    CHECAR0
        RETURN
;
; ----------------------------------RUTINAS PARA CHECAR SI SE SOTARON LOS BOTONES--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CHECAR0:
        CALL    DELAY
        BTFSC   PORTB,4           ; En estas rutinas se verifica que los
        RETURN                  ; botones correspondientes hayan sido soltados
        GOTO    CHECAR0

CHECAR1:
        CALL    DELAY
        BTFSC   PORTB,5
        RETURN
        GOTO    CHECAR1

CHECAR2:
        CALL    DELAY
        BTFSC   PORTB,6
        RETURN
        GOTO    CHECAR2

CHECAR3:
        CALL    DELAY
        BTFSC   PORTB,7
        RETURN
        GOTO    CHECAR3
;
; ---------------------------------------------------RUTINA GENERICA DE DELAYS-----------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
DELAY:
        MOVLW   0XFF            ; CARGO EL VLOR MAX POSIBLE EN W
        MOVWF   VAR1            ; VAR1 = 0XFF
        MOVWF   VAR2            ; VAR2 = 0XFF

 LOOP1:
            DECFSZ  VAR2        ; DECREMENTO LA VARIABLE 2
            GOTO    LOOP1       ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            DECFSZ  VAR1        ; SI ES 0, DECREMENTO VARIANLE 1
            GOTO    LOOP1       ; SI ES DIFERENTE DE 0, SIGUE DECREMENTANDO
            RETURN              ; SI ES 0, TERMINO EL DELAY

END
