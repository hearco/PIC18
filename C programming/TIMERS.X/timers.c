/*
 * File:   timers.c
 * Author: Ariel Almendariz
 *
 * Created on July 22nd, 2017, 05:03 PM
 */


#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>

#define _XTAL_FREQ      16000000
#define STAY_HERE       0x01

#include "timers.h"

void interrupt high_isr(void){
    
    if (TMR1_OVERFLOW){
        RESET_TMR1;
        LATB ^= 1;
        start_TMR1ms(25);
    }
    
    if (TMR3_OVERFLOW){
        RESET_TMR3;
        LATB ^= (1 << 1);
        start_TMR3ms(100);
    }
    
    if (TMR0_OVERFLOW){
        RESET_TMR0;
        LATB ^= (1 << 2);
        start_TMR0ms(300);
    }
    
}

void interrupt low_priority low_isr(void){
}

void main(void) {
    
    ANSELB = TRISB = LATB = 0;
    
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
    config_TMR0(INTERRUPT, FOSC4);
    config_TMR1(INTERRUPT, FOSC4);
    config_TMR3(INTERRUPT, FOSC4);
    
    start_TMR0ms(300);
    start_TMR1ms(25);
    start_TMR3ms(100);
    
    while(STAY_HERE){ 
    }
}
