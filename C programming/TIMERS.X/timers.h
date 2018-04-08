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

#define TMR0_MAX_TIME               4193
#define TMR1_MAX_TIME               131
#define TMR3_MAX_TIME               131

#define TIMERS_MAX_VALUE_16bits     65536
#define TIMERS_MAX_VALUE_8bits      256

/** Clear flags **/
#define IOC_CLEAR_FLAG              (INTCON &~(1 << 0))
#define INT0_CLEAR_FLAG             (INTCON &~(1 << 1))

/** Set pins **/
#define INT0_INTERRUPT_EN           (INTCON | (1 << 4))
#define TMR0_OVERFLOW_INTERRUPT_EN  (1 << 5)
#define TMR0_ON                     (T0CON | (1 << 8))
#define T0CKI_PIN_TRANSITION_EN     (T0CON | (1 << 5))
#define TMR1_ON                     (1)

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

/**** Advanced configurations ****/
/* Timer 0 */
typedef enum{
    TMR0_PREESCALER_OF_2,
    TMR0_PREESCALER_OF_4,
    TMR0_PREESCALER_OF_8,
    TMR0_PREESCALER_OF_16,
    TMR0_PREESCALER_OF_32,
    TMR0_PREESCALER_OF_64,
    TMR0_PREESCALER_OF_128,
    TMR0_PREESCALER_OF_256
}TMR0_PREESCALER_VALUES_T;

typedef enum{
    TMR0_CLOCK_SOURCE_INTERNAL,
    TMR0_CLOCK_SOURCE_T0CKI_PIN
}TMR0_CLOCK_SOURCE_VALUES_T;

typedef enum{
    TMR0_RW_MODE_16BIT,
    TMR0_RW_MODE_8BIT
}TMR0_RW_MODE_T;

/* Timer 1 */
typedef enum{
    TMR1_PREESCALER_OF_1,
    TMR1_PREESCALER_OF_2,
    TMR1_PREESCALER_OF_4,
    TMR1_PREESCALER_OF_8
}TMR1_PREESCALER_VALUES_T;

typedef enum{
    TMR1_CLOCK_SOURCE_FOSC4,
    TMR1_CLOCK_SOURCE_FOSC,
    TMR1_CLOCK_SOURCE_PIN_OSC
}TMR1_CLOCK_SOURCE_VALUES_T;

typedef enum{
    TMR1_RW_MODE_8BIT,
    TMR1_RW_MODE_16BIT
}TMR1_RW_MODE_T;

/* Timer 3 */
typedef enum{
    TMR3_PREESCALER_OF_1,
    TMR3_PREESCALER_OF_2,
    TMR3_PREESCALER_OF_4,
    TMR3_PREESCALER_OF_8
}TMR3_PREESCALER_VALUES_T;

typedef enum{
    TMR3_CLOCK_SOURCE_FOSC4,
    TMR3_CLOCK_SOURCE_FOSC,
    TMR3_CLOCK_SOURCE_PIN_OSC
}TMR3_CLOCK_SOURCE_VALUES_T;

typedef enum{
    TMR3_RW_MODE_8BIT,
    TMR3_RW_MODE_16BIT
}TMR3_RW_MODE_T;

/** Function prototypes **/
void TMR0_Config(TMR0_CLOCK_SOURCE_VALUES_T clock_source);
void TMR0_StartCount(UInt16_T milliseconds);
void TMR1_Config(TMR1_CLOCK_SOURCE_VALUES_T clock_source);
void TMR1_StartCount(UInt16_T milliseconds);
void TMR3_Config(TMR3_CLOCK_SOURCE_VALUES_T clock_source);
void TMR3_StartCount(UInt16_T milliseconds);

// TODO: Implement functions for Timer 2

#endif	/* XC_HEADER_TEMPLATE_H */

