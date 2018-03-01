#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>

#define _XTAL_FREQ  16000000
#define SOH         0x01
#define EOT         0x04
#define STAY_HERE   0x01

#include "serial.h"

signed char SERIAL_AVAILABLE = 0;
unsigned char *serial_buffer_ptr;

void interrupt high_isr(void){
    
    if (BYTE_AT_SERIAL_PORT){
        SERIAL_AVAILABLE = serial_read_msg(serial_buffer_ptr, SOH, EOT);
    }
}

void interrupt low_priority low_isr(void){
}

// -------------------------PROGRAMA PRINCIPAL---------------------------------------------

void main(void){
    
    serial_buffer_ptr = &SERIAL_BUFFER;
    serial_config(9600);
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    while(STAY_HERE){
        if (SERIAL_AVAILABLE > 0){
            SERIAL_AVAILABLE = serial_send_msg(serial_buffer_ptr, SOH, EOT);
        }
        else if (SERIAL_AVAILABLE == NO_SOH_ERROR){
            SERIAL_AVAILABLE = serial_send_string("NO SOH");
        }
        else if (SERIAL_AVAILABLE == NO_EOT_ERROR){
            SERIAL_AVAILABLE = serial_send_string("NO EOT");
        }
        else if (SERIAL_AVAILABLE == UNK_ERROR){
            SERIAL_AVAILABLE = serial_send_string("UNK ERROR");
        }
    }
}

