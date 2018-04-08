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

#define TMR0_MAX_TIME               4193
#define TMR1_MAX_TIME               131
#define TMR3_MAX_TIME               131
#define TMR2_MIN_FREQ               61
#define TMR2_MAX_FREQ               4000000
#define TIMERS_MAX_VALUE_16bits     65536
#define TIMERS_MAX_VALUE_8bits      256
#define MAX_TIMER                   65535
#define TRUE                        1
#define FALSE                       0

/** Clear flags **/
#define IOC_CLEAR_FLAG              (INTCON &~(1 << 0))
#define INT0_CLEAR_FLAG             (INTCON &~(1 << 1))
#define TMR0_OFF                    (~(1 << 7))
#define TMR1_OFF                    (~ (1))
#define TMR3_OFF                    (~ (1))

/** Set pins **/
#define INT0_INTERRUPT_EN           (INTCON | (1 << 4))
#define TMR0_OVERFLOW_INTERRUPT_EN  (1 << 5)
#define T0CKI_PIN_TRANSITION_EN     (T0CON | (1 << 5))
#define TMR0_ON                     (1 << 7)
#define TMR1_ON                     (1)
#define TMR3_ON                     (1)

/** Check for flags **/
#define TMR0_OVERFLOW               (INTCON & (1 << 2))
#define TMR1_OVERFLOW               (PIR1 & 1)
#define TMR3_OVERFLOW               (PIR2 & (1 << 1))



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
    TMR0_INC_TOCKI_ON_RISING,
    TMR0_INC_TOCKI_ON_FALLING
}TMR0_INC_ON_TOCKI_MODE_T;

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
    TMR1_CLOCK_SOURCE_PIN_OSC  // If value of SOSCEN pin is 0, clock source is TOCKI, else, clock source is secondary oscillator circuit
}TMR1_CLOCK_SOURCE_VALUES_T;

typedef enum{
    TMR1_RW_MODE_8BIT,
    TMR1_RW_MODE_16BIT
}TMR1_RW_MODE_T;

/* Timer 2 */
typedef enum{
    TMR2_PREESCALER_OF_1,
    TMR2_PREESCALER_OF_4,
    TMR2_PREESCALER_OF_16
}TMR2_PREESCALER_VALUES_T;

typedef enum{
    TMR2_POSTSCALER_OF_1,
    TMR2_POSTSCALER_OF_2,
    TMR2_POSTSCALER_OF_3,
    TMR2_POSTSCALER_OF_4,
    TMR2_POSTSCALER_OF_5,
    TMR2_POSTSCALER_OF_6,
    TMR2_POSTSCALER_OF_7,
    TMR2_POSTSCALER_OF_8,
    TMR2_POSTSCALER_OF_9,
    TMR2_POSTSCALER_OF_10,
    TMR2_POSTSCALER_OF_11,
    TMR2_POSTSCALER_OF_12,
    TMR2_POSTSCALER_OF_13,
    TMR2_POSTSCALER_OF_14,
    TMR2_POSTSCALER_OF_15,
    TMR2_POSTSCALER_OF_16
}TMR2_POSTSCALER_VALUES_T;

typedef enum{
    TMR2_FREQ_SPEED_LOW,
    TMR2_FREQ_SPEED_HIGH
}TMR2_FREQ_SPEED_MODE_T;

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
void TMR0_Start(UInt16_T milliseconds);
void TMR0_Restart(void);
void TMR0_Stop(void);

void TMR1_Config(TMR1_CLOCK_SOURCE_VALUES_T clock_source);
void TMR1_Start(UInt16_T milliseconds);
void TMR1_Restart(void);
void TMR1_Stop(void);

// TODO: Implement functions for Timer 2
//void TMR2_Config(TMR2_FREQ_SPEED_MODE_T freqSpeedMode);
//void TMR2_Start(UInt32_T frequency);
//void TMR2_Stop(void);

void TMR3_Config(TMR3_CLOCK_SOURCE_VALUES_T clock_source);
void TMR3_Start(UInt16_T milliseconds);
void TMR3_Restart(void);
void TMR3_Stop(void);

#endif	/* XC_HEADER_TEMPLATE_H */

