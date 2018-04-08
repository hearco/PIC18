
// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef HWCONFIG_HEADER
#define	HWCONFIG_HEADER

#define PIC18F45K50

#ifdef PIC18F45K50
    #include <p18f45k50.h>
    #include <xc.h>
    #include <htc.h>
    #include <stdio.h>
    #include <string.h>
#endif // PIC18F45K50

#include "dataTypes.h"

#ifdef PIC18F45K50
    #define _XTAL_FREQ      16000000                // 16MH Fosc
#endif // PIC18F45K50

#endif	/* HWCONFIG_HEADER */

