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
VAR1                EQU 3
VAR2                EQU 4
PrimerNumero        EQU 5
copiaDelNumero      EQU	6
TipoOper            EQU 7
ContDivision        EQU 8
ContMultiplicacion  EQU 9
MultTemporal        EQU 10
RotacionDelNumero   EQU 11
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
        CLRF    ANSELA, BANKED
		MOVLW   0xF0                ; PARTE ALTA ES ENTRADA (PUERTO B)
        MOVWF   TRISB               ; PARTE BAJA ES SALIDA  (PUERTO B)
        CLRF    TRISD               ; PUERTO D ES SALIDA
        CLRF    LATD                ; LATD = 0
        CLRF    TRISA
        CLRF    MultTemporal
        CALL    LCDinit
        BCF     INTCON2,7           ; SE ACTIVAN LAS RESISTENCIAS PULL-UP
        CLRF    TipoOper            ; Bandera para identificar operacion
        CLRF    ContDivision
        CLRF    ContMultiplicacion
        CLRF    RotacionDelNumero
        GOTO    ChecarRenglon1
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
        MOVLW   '0'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x00                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR3             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR UNO---------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
UNO:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   '1'                 ; Pone el caracter '1' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x01                ; LATD = 1
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 1
        CALL    CHECAR0             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR DOS---------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
DOS:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   '2'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x02                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR1             ; VERIFICO QUE YA NO SE PREIONE EL BOTON OTRA VEZ
        RETURN                      ; REGRESO A CONTINUAR CHECANDO LOS BOTONES
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR TRES--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
TRES:
        CALL    DELAY               ; RETRASO PARA EVITAR REBOTES
        MOVLW   '3'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x03                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR CUATRO------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CUATRO:
        CALL    DELAY
        MOVLW   '4'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x04                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR0
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR CINCO-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
CINCO:
        CALL    DELAY
        MOVLW   '5'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x05                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR1
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR SEIS--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
SEIS:
        CALL    DELAY
        MOVLW   '6'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x06                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR SIETE-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
SIETE:
        CALL    DELAY
        MOVLW   '7'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x07                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR0
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR OCHO--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
OCHO:
        CALL    DELAY
        MOVLW   '8'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x08                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA ESCRIBIR NUEVE-------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
NUEVE:
        CALL    DELAY
        MOVLW   '9'                 ; Pone el caracter '0' en W
        BSF     PORTA,LCD_EN        ; Se enciende la señal de enable
        BSF     PORTA,LCD_RS        ; Se especifica que la entrada serán datos
        MOVWF   LATD                ; Se pasan los datos a la pantalla
        BCF     PORTA,LCD_EN        ; Se apaga la señal de enable
        CALL    DELAY
        MOVLW   0x09                ; LATD = 0
        MOVWF   PrimerNumero        ; COPIO EL 0 EN UNA VARIABLE AUXILIAR, PrimerNumero = 0
        CALL    CHECAR2
        RETURN
;
; ------------------------------------------------------RUTINA PARA SUMAR----------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
AH:
        CALL    DELAY
        CALL    copiarNUMERO        ; Cambia el valor anteriormente almacenado en a
        BSF     TipoOper,7          ; a la variable b
        BCF     TipoOper,6          ; Y señala en f que se realizara una suma
        BCF     TipoOper,5          ; con el valor 0x80
        BCF     TipoOper,4
        BSF     PORTA,LCD_EN
        BSF     PORTA,LCD_RS        ; Se escribe el operador de suma en el LCD
        MOVLW   '+'
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CALL    CHECAR0
        RETURN

SUMA:
        MOVF    copiaDelNumero,0
        ADDWF   PrimerNumero,0      ; Sum a y b.
        DAW
        MOVWF   PrimerNumero        ; Y lo guarda en a        

MostrarSum:
        MOVFF   PrimerNumero, RotacionDelNumero
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
        GOTO    SumaDoble
        GOTO    SumaSimple

SumaSimple:
        MOVF    PrimerNumero, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    RotacionDelNumero
        GOTO    RegresarSum

SumaDoble:
        MOVF    RotacionDelNumero, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY

        MOVLW   0X0F
        ANDWF   PrimerNumero, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    RotacionDelNumero
        GOTO    RegresarSum        
;
; --------------------------------------------------------RUTINA PARA RESTAR-------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
B:
        CALL    DELAY
        CALL    copiarNUMERO        ; Cambia el valor anteriormente almacenado en a
        BCF     TipoOper,7          ; a la variable b
        BSF     TipoOper,6          ; Y señala en f que se realizara una resta
        BCF     TipoOper,5          ; con el valor 0x40
        BCF     TipoOper,4
        BSF     PORTA,LCD_EN
        BSF     PORTA,LCD_RS        ; Se escribe el operador de suma en el LCD
        MOVLW   '-'
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CALL    CHECAR1
        RETURN

RESTA:
        MOVF    PrimerNumero,0
        SUBWF   copiaDelNumero,0    ; Resta b de a
        MOVWF   PrimerNumero        ; Y lo guarda en a
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD                ; Depsliega el resultado en los LEDS
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CALL    DELAY
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
        BSF     PORTA,LCD_EN
        BSF     PORTA,LCD_RS        ; Se escribe el operador de suma en el LCD
        MOVLW   '*'
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CALL    CHECAR3
        RETURN

MULTIPLICACION:
        MOVLW   0                   ; W = 0
        CPFSGT  PrimerNumero        ; CHECO SI MI ULTIMO NUMERO TECLEADO ES 0
        GOTO    ResultadoCero
        CPFSGT  copiaDelNumero
        GOTO    ResultadoCero
        GOTO    SumaMultiple

SumaMultiple:
        MOVFF   copiaDelNumero, ContMultiplicacion
        MOVF    PrimerNumero, 0
        DAW
        MOVWF   PrimerNumero
        CLRF    WREG

Sum:
        ADDWF   PrimerNumero, 0
        DAW
        MOVWF   MultTemporal
        DECFSZ  ContMultiplicacion, 1
        GOTO    Sum
        GOTO    MostrarMult

ResultadoCero:
        CALL    CERO
        GOTO    RegresarMult

MostrarMult:
        MOVFF   MultTemporal, RotacionDelNumero
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
        MOVF    MultTemporal, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    ContMultiplicacion
        CLRF    RotacionDelNumero
        GOTO    RegresarMult

ResultadoDoble:
        MOVF    RotacionDelNumero, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY

        MOVLW   0X0F
        ANDWF   MultTemporal, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    ContMultiplicacion
        CLRF    RotacionDelNumero
        GOTO    RegresarMult
; --------------------------------------------------------RUTINA PARA DIVIDIR--------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
D:
        CALL    DELAY
        CALL    copiarNUMERO             ; Cambia el valor anteriormente almacenado en a
        BCF     TipoOper,7                 ;     a la variable b
        BCF     TipoOper,6                 ; Y señala en f que se realizara una suma
        BCF     TipoOper,5                 ;    con el valor 0x80
        BSF     TipoOper,4
        BSF     PORTA,LCD_EN
        BSF     PORTA,LCD_RS        ; Se escribe el operador de suma en el LCD
        MOVLW   '/'
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CALL    CHECAR0
        RETURN

DIVISION:
        MOVLW   0
        CPFSEQ  PrimerNumero
        GOTO    Bien
        GOTO    Equivocado
        
Bien:
        MOVF    PrimerNumero,0
        CPFSLT  copiaDelNumero
        GOTO    InContDiv                 ; Y posteriormente a la variable a
        GOTO    MostrarResultado

Equivocado:
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        MOVLW   b'11110011'
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY

        GOTO    KLP

MostrarResultado:
        MOVF    ContDivision, 0
        BSF     PORTA,LCD_EN        ; Y despliega el resultado en el LCD
        BSF     PORTA,LCD_RS
        ADDLW   0x30
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        CLRF    ContDivision
        RETURN

InContDiv:
        MOVF    PrimerNumero,0
        SUBWF   copiaDelNumero,1
        INCF    ContDivision, 1
        GOTO    DIVISION
;
; --------------------------------------------------------RUTINA PARA REALIZAR OPERACIONES-----------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
GATO:
        CALL    DELAY
        BSF     PORTA,LCD_EN
        BSF     PORTA,LCD_RS        ; Se escribe el signo de igualdad en el LCD
        MOVLW   '='
        MOVWF   LATD
        BCF     PORTA,LCD_EN
        CALL    DELAY
        BTFSC   TipoOper,7         ; Se verifica el valor de la bandera f
        GOTO    SUMA               ; y se llama a la rutina con la operacion adecuada
RegresarSum:
        BTFSC   TipoOper,6
        CALL    RESTA
        BTFSC   TipoOper,5
        GOTO    MULTIPLICACION

        RegresarMult:
            BTFSC   TipoOper,4
            CALL    DIVISION
        KLP:
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
        CALL    DELAY              ; Se utiliza esta rutina para limipar la pantalla
        BSF     PORTA,LCD_EN        ; EN = 1
        BCF     PORTA,LCD_RS        ; RS = 0
        MOVLW   0x01              ; Clear screen
        MOVWF   PORTD
        BCF     PORTA,LCD_EN        ; EN = 0
        CLRF    TipoOper            ; Bandera para identificar operacion
        CLRF    ContDivision
        CLRF    copiaDelNumero
        CLRF    PrimerNumero
        MOVLW   1
        MOVWF   ContMultiplicacion
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
