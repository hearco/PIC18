/*
 * File:   main.c
 * Author: Ariel Almendariz
 *
 * Created on July 19th, 2017, 09:21 PM
 */

/****   LIBRARIES   ***************************/
#include "LCD.h"

void main(void) {
    LCD_Init();
    (void)LCD_WriteMsg("Hello world");
    
    while(1)
    {
        
    }
}
