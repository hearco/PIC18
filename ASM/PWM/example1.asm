		PROCESSOR	18F45K50		; SET PROCESSOR TYPE
		#INCLUDE	<P18F45K50.INC>
;
;
;	VARIABLE'S DEFINITION SECTION
;
VAR1                EQU 3
VAR2                EQU 4
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
        CLRF	ANSELC, BANKED  ; SET ALL PINS AS DIGITAL
        BCF     TRISC,CCP1      ; Salida del PWM
        BSF     TRISC, 1
        MOVLW   199             ; Frecuencia de onda de 20kH
        MOVWF   PR2             ; PR2 = 199
        MOVLW   149             ; Duty cycle de 75%
        MOVWF   CCPR1L          ; CCPR1L = 149
        MOVWF   CCPR1H          ; CCPR1H = 149
        MOVLW   b'10000001'     ; Reset bit6 y bit3 en 00 para seleccionar timer2 como contador fuente
        MOVWF   T3CON           ; T3CON = 1000 0001
        CLRF    TMR2            ; TMR2 empieza a contar desde 0
        MOVLW   b'00000100'     ; Establece preescalador de 1 y bit2 para prender el timer2
        MOVWF   T2CON           ; T2CON = 0000 0101
        MOVLW   b'00001100'     ; Establece CCP1M3 - CCPM0 en 1100 para modo PWM
        MOVWF   CCP1CON         ; Habilita CCP1 en modo PWM
        GOTO    $

;LOOP:
        ;BTFSC   PORTC, 1
;        GOTO    LOOP
        ;GOTO    LedNormal

;LedNormal:
 ;       CALL    DELAY
  ;      MOVLW   199             ; Duty cycle de 100%
   ;     MOVWF   CCPR1L          ; CCPR1L = 149
    ;    MOVWF   CCPR1H          ; CCPR1H = 149
     ;   BTFSS   PORTC, 2
      ;  GOTO    LedNormal
       ; GOTO    LedSieteCinco

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
