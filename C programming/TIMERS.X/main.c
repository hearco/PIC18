/*
 * File:   timers.c
 * Author: Ariel Almendariz
 *
 * Created on July 22nd, 2017, 05:03 PM
 */
#include "hwconfig.h"
#include "timers.h"

#ifdef GLOBAL_INTERRUPT_ENABLE
void interrupt high_isr(void){
    
}
#endif

//#if (INTERRUPT_PRIORITY_ENABLE == ON)
//void interrupt low_priority low_isr(void){
//}
//#endif

void main(void) {
    
    ANSELB = TRISB = LATB = 0;

//#ifdef GLOBAL_INTERRUPT_ENABLE
//    INTCONbits.PEIE = 1;
//    INTCONbits.GIE = 1;
//#endif
    
    TMR0_Config(TMR0_CLOCK_SOURCE_INTERNAL);
    TMR1_Config(TMR1_CLOCK_SOURCE_FOSC4);
    TMR3_Config(TMR3_CLOCK_SOURCE_FOSC4);
    
    TMR0_StartCount(300);
    TMR1_StartCount(25);
    TMR3_StartCount(100);
    
    while(1)
    { 
        if (TMR1_OVERFLOW)
        {
            RESET_TMR1;
            LATB ^= 1;
            TMR1_StartCount(25);
        }

        if (TMR3_OVERFLOW)
        {
            RESET_TMR3;
            LATB ^= (1 << 1);
            TMR3_StartCount(100);
        }

        if (TMR0_OVERFLOW)
        {
            RESET_TMR0;
            LATB ^= (1 << 2);
            TMR0_StartCount(300);
        }
    }
}
