/* 
 * File: "LCD.h"
 * Author: Ariel Almendariz
 * Comments:
 * Revision history:
 *      1.0 <- Jul/20/2017
 * 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef LCD_H
#define	LCD_H 

#include "hwconfig.h"
/*
 * Use the next Hardware connections to interface the LCD with the
 * microcontroller. Consider the next set up for an 4-bit interface
 * and also to consider it to be the last stable set up.
 * 
 * Vss -> GND
 * Vdd -> 5volts
 * Vo  -> Potentiometer Output
 * RS  -> LATCbits.LATC0
 * RW  -> LATCbits.LATC1
 * E   -> LATCbits.LATC2
 * D0  -> GND
 * D1  -> GND
 * D2  -> GND
 * D3  -> GND
 * D4  -> LATDbits.LATD4
 * D5  -> LATDbits.LATD5
 * D6  -> LATDbits.LATD6
 * D7  -> LATDbits.LATD7
 * A   -> 1kOhm resistor (1 terminal to 5volts)
 * K   -> GND
 * 
 */

/****   LCD BITS & PORTS DEFINES   *****/
#define LCD_RS              LATCbits.LATC0          // Instruction/Data pin
#define LCD_RW              LATCbits.LATC1          // Read/Write pin
#define LCD_EN              LATCbits.LATC2          // Enable signal
#define LCD_CTRL            LATC                    // CONTROL port for LCD
#define LCD_DATA            LATD                    // DATA port for LCD
#define LCD_CTRL_TRIS       TRISC                   // For use to set up CONTROL port as output
#define LCD_DATA_TRIS       TRISD                   // For use to set up DATA port as I/O
#define LCD_ANSEL_CTRL      ANSELC                  // For use to set up CONTROL port as digital
#define LCD_ANSEL_DATA      ANSELD                  // For use to set up DATA port as digital

/****   LCD instructions   *************/
#define LCD_FOUR_BIT        0x28                    // 4-bit interface, 2 lines, 5x7 dots
#define LCD_SET_CURSOR_POS  0x80                    // Base address to set cursor position
#define LCD_CURSOR_ON       0x0F                    // Display on, cursor on, cursor blinking
#define LCD_CURSOR_HOME     0x02                    // Cursor at home
#define LCD_CLEAR_SCREEN    0x01                    // Clear LCD screen

/****   LCD constants   ****************/
#define LCD_FIRST_ROW       0 
#define LCD_SECOND_ROW      1
#define LCD_COL_LIMIT       16
#define LCD_ROW_LIMIT       1
#define INIT_SUCCESS        1



typedef enum {
    LCD_COMMAND_WRITE,
    LCD_DATA_WRITE
}LCDMODE_E;


void LCD_WriteByte(UInt8_T InputValue, LCDMODE_E CommandData);
void LCD_WriteMsg(UInt8_T * msg);
UInt8_T LCD_Init(void);

#endif