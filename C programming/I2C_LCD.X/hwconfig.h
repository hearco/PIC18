/* *************************************************************************
 * 
 *        File: hwconfig.h
 * 
 *      Author: Ariel Almendariz
 * 
 *    Comments: This file contains some configurations for specified uC. 
 * 
 * Last update: Apr / 8 / 18
 *
 **************************************************************************/

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

