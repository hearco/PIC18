/* 
 * File:   
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef TIMERS_H
#define	TIMERS_H

#include "hwconfig.h" // include processor files - each processor file is guarded.  


#define TMR0_OVERFLOW               (INTCON & (1 << 2))
#define TMR1_OVERFLOW               (PIR1 & 1)
#define TMR3_OVERFLOW               (PIR2 & (1 << 1))

/** Clear flags **/
#define IOC_CLEAR_FLAG              (INTCON &~(1 << 0))
#define INT0_CLEAR_FLAG             (INTCON &~(1 << 1))

/** Set pins **/
#define INT0_INTERRUPT_EN           (INTCON | (1 << 4))
#define TMR0_OVERFLOW_INTERRUPT_EN  (1 << 5)
#define TMR0_ON                     (T0CON | (1 << 8))
#define T0CKI_PIN_TRANSITION_EN     (T0CON | (1 << 5))

/** Check for flags **/


#define RESET_TMR0        (INTCONbits.TMR0IF = T0CONbits.TMR0ON = 0)
#define RESET_TMR1        (PIR1bits.TMR1IF = T1CONbits.TMR1ON = 0)
#define RESET_TMR3        (PIR2bits.TMR3IF = T3CONbits.TMR3ON = 0)
#define MAX_TIMER         65535
#define TRUE              1
#define FALSE             0
#define POLLING           0
#define INTERRUPT         1
#define FOSC4             0
#define T0CKI             1

/** Advanced configurations **/
typedef enum{
    T0CON_PREESCALER_OF_2,
    T0CON_PREESCALER_OF_4,
    T0CON_PREESCALER_OF_8,
    T0CON_PREESCALER_OF_16,
    T0CON_PREESCALER_OF_32,
    T0CON_PREESCALER_OF_64,
    T0CON_PREESCALER_OF_128,
    T0CON_PREESCALER_OF_256
}T0CON_PREESCALER_VALUES_T;

void TMR0_Config(UInt8_T clock_source, T0CON_PREESCALER_VALUES_T preescaler);
void TMR0_StartCount(UInt16_T milliseconds);
void TMR1_Config(UInt8_T clock_source);
void TMR1_StartCount(UInt16_T milliseconds);
void TMR3_Config(UInt8_T clock_source);
void TMR3_StartCount(UInt16_T milliseconds);

#endif	/* XC_HEADER_TEMPLATE_H */

