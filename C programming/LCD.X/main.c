/*
 * File:   main.c
 * Author: Ariel Almendariz
 *
 * Created on July 19th, 2017, 09:21 PM
 */

/****   LIBRARIES   ***************************/
#include "hwconfig.h"
#include "LCD.h"

/****   GLOBAL DEFINES   **********************/
#define STAY_HERE       0x01                    // For while loop only

void main(void) {
    LCD_Init();
    //set_cursor_pos(LCD_SECOND_ROW, 5);
    (void)LCD_WriteMsg("Hola Crayola jajejijoju");
    
    while(STAY_HERE);
}
