/*
 * File:   main.c
 * Author: Ariel Almendariz
 *
 * Created on July 19th, 2017, 09:21 PM
 */

/****   SYSTEM INCLUDES   *********************/
#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>

/****   GLOBAL DEFINES   **********************/
#define _XTAL_FREQ      16000000                // 16MH Fosc
#define STAY_HERE       0x01                    // For while loop only

/****   LIBRARIES   ***************************/
#include "LCD.h"


void main(void) {
    if (LCD_init()){
        set_cursor_pos(SECOND_ROW, 5);
        LCD_msg("Ok");
    }
    
    while(STAY_HERE);
}
