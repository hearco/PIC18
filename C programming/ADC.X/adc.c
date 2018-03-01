/*
 * File:   adc.c
 * Author: usuario
 *
 * Created on 29 de julio de 2017, 01:06 AM
 */

#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>
#include <pic18f45k50.h>

#define _XTAL_FREQ      16000000
#define STAY_HERE       0x01
#define SOH             0x01
#define EOT             0x04

#include "LCD.h"
#include "adc.h"
#include "serial.h"

void interrupt high_isr(void){
    
    if (BYTE_AT_SERIAL_PORT){
        INTCONbits.PEIE = 0;
    }
}

void main( void ) {
    
    serial_config(9600);
    analogInit(RA0);
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    while(STAY_HERE){
        if(INTCONbits.PEIE == 0){
            ADCON0bits.GO = 1;
            while(ADCON0bits.DONE == 1);
            send_char(ADRESH);
            send_char(ADRESL);
            BYTE_AT_SERIAL_PORT = NO;
            INTCONbits.PEIE = 1;
        }
    }
}
