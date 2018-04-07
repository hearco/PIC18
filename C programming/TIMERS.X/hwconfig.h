/* 
 * File:   
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef HWCONFIG_HEADER
#define	HWCONFIG_HEADER

#define CPU PIC18F45K50

#if (CPU == PIC18F45K50)
    #include <p18f45k50.h>
    #include <xc.h>
    #include <htc.h>
    #include <stdio.h>
    #include <string.h>
#endif // PIC18F45K50

#define ON 1
#define OFF 0


#define GLOBAL_INTERRUPT_ENABLE   // ON, OFF
#ifdef GLOBAL_INTERRUPT_ENABLE
        #define INTERRUPT_PRIORITY_ENABLE OFF
    #endif

    #if (INTERRUPT_PRIORITY_ENABLE == ON)
        #define HIGH_PRIORITY_ENABLE
        #define LOW_PRIORITY_ENABLE

    #else // Normal priority
        #define INTERRUPT_ENABLE_TIMER0 ON
        #define INTERRUPT_ENABLE_TIMER1 ON
        #define INTERRUPT_ENABLE_TIMER3 ON
    #endif // 

#include "dataTypes.h"

#if (CPU == PIC18F45K50)
    #define _XTAL_FREQ      16000000                // 16MH Fosc
#endif // PIC18F45K50

#endif	/* HWCONFIG_HEADER */

