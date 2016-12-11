RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;

DELAYCNT            EQU 0x20
XDELAYCNT           EQU 0x21
LCD_RS              EQU 0
LCD_RW              EQU 1
LCD_EN              EQU 2
VAR1                EQU	3			; VARIABLE PARA EL DELAY
VAR2                EQU	4			; VARIABLE PARA EL DELAY
ContDelays          EQU 5           ; CONTADOR DE DELAYS, SIRVE PARA SABER CUANDO YA PASO UN SEGUNDO
ContPulsos          EQU 6
TimersCont          EQU 7
PrimerNumero        EQU 8
copiaDelNumero      EQU	9
TipoOper            EQU 10
ContDivision        EQU 11
ContMultiplicacion  EQU 12
MultTemporal        EQU 13
RotacionDelNumero   EQU 14
BitStat             EQU 15


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
        CLRF    ANSELD, BANKED
      ;  CLRF	ANSELB, BANKED		; SET ALL PINS AS DIGITAL
      ;  CLRF    TRISB               ; Puerto B es salida
      ;  CLRF    LATB                ; LIMPIO EL PUERTO B
        CLRF    TRISA
        CLRF    TRISD
        CALL    LCDinit
      ;  BCF     LATB, 6
        CLRF    LATD
        BSF     TRISC, 0            ; RA4 como enrada
        CLRF    ContDelays          ; ContDelays = 0
        MOVLW   b'00000111'         ; TIMER = 8 BITS, TRANSICION EXTERNA, PREESCALADOR = 256
        MOVWF   T0CON               ; Valor de prescala es 128
        CLRF    INTCON              ; Se limpia bandera de timer OV
        CLRF    BitStat
AB:     CLRF    TimersCont
        CLRF    ContPulsos
        CLRF    RotacionDelNumero
        CLRF    LATD

OtraVez:
        MOVLW   0x00                ; Valor inicial para
        MOVWF   TMR0H               ; parte baja del timer
        MOVLW   0x00                ; Valor inicial para
        MOVWF   TMR0L               ; parte baja del timer
        BSF     T0CON, 7            ; ENCIENDO EL TIMER
        GOTO    LOOP
   ;     GOTO    OtraVez
;
; ------------------------------------------------------INICIALIZACION DEL LCD----------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
LCDinit:
        CLRF    PORTA
        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x38                ; 8-bit interface, character de 5x8
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CALL    DELAY

        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x0F                ; LCD ON, Cursor ON
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CALL    DELAY

        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x02                ; cursor at home
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CALL    DELAY

        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x01                ; Clear screen
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CALL    DELAY

        RETURN

;
; --------------------------------------------------------CHECA BOTON--------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
LOOP:
        BTFSS   PORTC, 0
        CALL    Boton
        BTFSC   BitStat, 0
        CALL    ChecoStatus
        BTFSS   INTCON,2            ; Esperar hasta que la bandera de
        GOTO    LOOP
        GOTO    IncCont

Timer3:
        MOVLW   0x9E
        MOVWF   TMR0H
        MOVLW   0x58
        MOVWF   TMR0L
        BSF     T0CON, 7
        GOTO    LOOP2

LOOP2:
        BTFSS   PORTC, 0
        CALL    Boton
        BTFSC   BitStat, 0
        CALL    ChecoStatus
        BTFSS   INTCON,2            ; Esperar hasta que la bandera de
        GOTO    LOOP2
        GOTO    Overflow

IncCont:
        BCF     INTCON, 2
        BCF     T0CON, 7
        INCF    TimersCont, 0
        DAW
        MOVWF   TimersCont
        MOVLW   2
        CPFSEQ  TimersCont
        GOTO    OtraVez
        GOTO    Timer3

Boton:
        CALL    EvitarRebotes
        BTFSS   PORTC, 0
        GOTO    Boton
        BSF     BitStat, 0
     ;   MOVFF   ContPulsos, LATD
   ;     GOTO    CHECAROverflow
  QW:   RETURN

ChecoStatus:
        BTFSC   BitStat, 0
        INCF    ContPulsos, 0
        DAW
        MOVWF   ContPulsos
        BCF     BitStat, 0
        RETURN

Overflow:
        BCF     INTCON,2            ; Limpiar bandera nuevamente
        BCF     T0CON, 7            ; APAGO EL TIMER
        BTG     LATB, 6
        CALL    Mul6func
        GOTO    MostrarRes
RegresarRES:
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        CALL    EvitarRebotes
        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x01                ; Clear screen
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CALL    DELAY
        GOTO    AB            ; Regresar al loop

Mul6func:
        MOVF    ContPulsos, 0
        DAW
        ADDWF   ContPulsos, 0
        DAW
        ADDWF   ContPulsos, 0
        DAW
        ADDWF   ContPulsos, 0
        DAW
        ADDWF   ContPulsos, 0
        DAW
        ADDWF   ContPulsos, 0
        DAW
        MOVWF   ContPulsos
        RETURN

MostrarRes:
        MOVFF   ContPulsos, RotacionDelNumero
        BCF     STATUS, C
        RRCF    RotacionDelNumero, 1
        BCF     STATUS, C
        RRCF    RotacionDelNumero, 1
        BCF     STATUS, C
        RRCF    RotacionDelNumero, 1
        BCF     STATUS, C
        RRCF    RotacionDelNumero, 1
        CLRF    WREG
        CPFSEQ  RotacionDelNumero
        GOTO    ResultadoDoble
        GOTO    ResultadoSimple

ResultadoSimple:
        MOVF    ContPulsos, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    RotacionDelNumero
        GOTO    RegresarRES

ResultadoDoble:
        MOVF    RotacionDelNumero, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY

        MOVLW   0X0F
        ANDWF   ContPulsos, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    RotacionDelNumero
        GOTO    RegresarRES
;
; ------------------------------------------------RUTINA PARA EVITAR REBOTES-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
EvitarRebotes:
        CALL    DELAY               ; Retraso
        INCF    ContDelays, 1       ; CONTADOR PARA MEDIR LOS SEGUNDOS QUE HAN PASADO
        MOVLW   4                   ; W = 1
        CPFSEQ  ContDelays          ; CHECO SI YA PASO UN SEGUNDO
        GOTO    EvitarRebotes       ; SI NO, VUELVO A LLAMAR LA FUNCION
        CALL    LimpiarContador     ; LIMPIO EL CONTADOR DE DELAYS PARA PODER VOLVERLO A USAR
        Return                      ; SI ES ASI, REGRESO A LA FUNCION QUE LA MANDO A LLAMAR

DELAY:
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
