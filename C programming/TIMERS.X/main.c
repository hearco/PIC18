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
    
    TMR0_Start(300);
    TMR1_Start(25);
    TMR3_Start(100);
    
    while(1)
    { 
        if (TMR1_OVERFLOW)
        {
            LATB ^= 1;
            TMR1_Restart();
        }

        if (TMR3_OVERFLOW)
        {
            LATB ^= (1 << 1);
            TMR3_Restart();
        }

        if (TMR0_OVERFLOW)
        {
            LATB ^= (1 << 2);
            TMR0_Restart();
        }
    }
}
