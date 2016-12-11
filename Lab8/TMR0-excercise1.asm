RADIX	DEC					; SET DECIMAL AS DEFAULT BASE
		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
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
;
; ---------------------------------------INICIALIZACION DE LAS VARIABLES Y REGISTROS A UTILIZAR------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
MAIN:
        MOVLB   15
        CLRF	ANSELB, BANKED		; SET ALL PINS AS DIGITAL
        CLRF    TRISB               ; Puerto B es salida
        CLRF    LATB                ; LIMPIO EL PUERTO B
       ;MOVLW   b'00000101'         
        MOVLW   b'00000001'         ; TIMER = 16 BITS, TRANSICION INTERNA, PREESCALADOR = 4
        MOVWF   T0CON               ; Valor de prescala es 128
        CLRF    INTCON              ; Se limpia bandera de timer OV

OtraVez:
       ;MOVLW   0x0B                
        MOVLW   0x15                ; Valor inicial para
        MOVWF   TMR0H               ; parte baja del timer
       ;MOVLW   0xDC                
        MOVLW   0xA0                ; Valor inicial para
        MOVWF   TMR0L               ; parte baja del timer
        BSF     T0CON, 7            ; ENCIENDO EL TIMER
;
; --------------------------------------------------------ESPERA DEL TIMER0--------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------------------
Espera:
        BTFSS   INTCON,2            ; Esperar hasta que la bandera de
        GOTO    Espera              ; timer OV este encendida,
        BTG     PORTB, 7            ; Cambiar de valor el pin conectado al LED
        BCF     INTCON,2            ; Limpiar bandera nuevamente
        BCF     T0CON, 7            ; APAGO EL TIMER
        GOTO    OtraVez             ; Regresar al loop
END
