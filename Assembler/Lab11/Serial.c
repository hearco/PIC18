#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>

#define _XTAL_FREQ 16000000

void interrupt high_isr(void){ // funcion de interrupciones de alta prioridad
}

void interrupt low_priority low_isr(void){ // funcion de interrupciones de baja prioridad
}

delay1seg(){
    for(int i=0;i<100;i++){
        __delay_ms(10);
    }
}

// -------------------------PROGRAMA PRINCIPAL---------------------------------------------

void main(void){
    ANSELB = 0;                         //  PortD digital
    ANSELC = 0;                         //  PortC digital
    TRISB = 0;                          //  PortD como salida

    SPBRGH1 = 0;                        //  EUSART Baud rate generator, High Byte = 0
    SPBRG1 = 25;                        //  EUSART Baud rate generator, Low Byte = 0001 1001
    TRISCbits.TRISC6 = 1;               //  TX/CK entrada
    TRISCbits.TRISC7 = 1;               //  RX/DT entrada
    TXSTA1bits.SYNC = 0;                //  Transmit status and control register, Modo asincrono
    BAUDCON1bits.TXCKP = 0;             //  Baud rate control register, BAUDCON1,4 = 0 (Clock/trnasmit polarity select bit) Idle state for transmit (TX) is low
    RCSTA1bits.SPEN = 1;                //  Receive status and control register, Serial port enabled
    TXSTA1bits.TXEN = 1;                //  Transmit status and control register, transmit enabled
    TXREG1 = 0;                         //  EUSART transmit register

    BAUDCON1bits.RXDTP = 0;             //  Baud rate control register, Data/Receive polarity, Receive data (RX) is active-low
    RCSTA1bits.CREN = 1;                //  Receive status and control register, enables receiver

    while(1){                           //  Ciclo del programa principal
        if (PIR1bits.RCIF){             //  PERIPHERAL INTERRUPT REQUEST, the EUSART receive buffer is full?
            TXREG1 = RCREG1;            //  EUSART transmit register = EUSART receive register
            LATB = RCREG1;              //  PUERTO B = EUSART receive register
            while(!TXSTA1bits.TRMT);    //  Mientras Transmit status and control register, Transmit Shift Register este lleno
                PIR1bits.RCIF = 0;      //  PERIPHERAL INTERRUPT REQUEST, EUSART receive buffer vacio
        }
    }
}
