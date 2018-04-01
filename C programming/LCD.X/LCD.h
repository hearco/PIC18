/* 
 * File: "LCD.h"
 * Author: Ariel Almendariz
 * Comments:
 * Revision history:
 *      1.0 <- Jul/20/2017
 * 
 */
#ifndef LCD_H
#define	LCD_H 

#include "hwconfig.h"

/*
 * Use the next Hardware connections to interface the LCD with the
 * microcontroller. Consider the next set up for an 4-bit interface.
 * and as default mode. If using 8-bit mode, read all comments to
 * correctly set-up the hardware.
 * 
 * Vss -> GND
 * Vdd -> 5volts
 * Vo  -> Potentiometer Output
 * RS  -> RA0
 * RW  -> RA1
 * E   -> RA2
 * D0  -> GND (If using 8-bit, connect to RD0)
 * D1  -> GND (If using 8-bit, connect to RD1)
 * D2  -> GND (If using 8-bit, connect to RD2)
 * D3  -> GND (If using 8-bit, connect to RD3)
 * D4  -> RD4
 * D5  -> RD5
 * D6  -> RD6
 * D7  -> RD7
 * A   -> 1kOhm resistor (1 terminal to 5volts)
 * K   -> GND
 * 
 */

#define LCD_RS              LATAbits.LATA0          // Instruction/Data pin
#define LCD_RW              LATAbits.LATA1          // Read/Write pin
#define LCD_EN              LATAbits.LATA2          // Enable signal
#define LCD_CTRL            LATA                    // CONTROL port for LCD
#define LCD_DATA            LATD                    // DATA port for LCD
#define LCD_CTRL_TRIS       TRISA                   // For use to set up CONTROL port as output
#define LCD_DATA_TRIS       TRISD                   // For use to set up DATA port as I/O
#define LCD_ANSEL_CTRL      ANSELA                  // For use to set up CONTROL port as digital
#define LCD_ANSEL_DATA      ANSELD                  // For use to set up DATA port as digital

#define LCD_FOUR_BIT        0x28                    // 4-bit interface, 2 lines, 5x7 dots
#define LCD_EIGHT_BIT       0x38                    // 8-bit interface
#define LCD_SET_CURSOR_POS  0x80                    // Base address to set cursor position
#define LCD_CURSOR_ON       0x0F                    // Display on, cursor on, cursor blinking
#define LCD_CURSOR_HOME     0x02                    // Cursor at home
#define LCD_CLEAR_SCREEN    0x01                    // Clear LCD screen

#define LCD_FIRST_ROW       0 
#define LCD_SECOND_ROW      1
#define LCD_COL_LIMIT       16
#define LCD_ROW_LIMIT       1
#define INIT_SUCCESS        1

//#define LCD_SETMODE_8BIT                            // Uncomment if using LCD in 8 bit mode, comment out when using the default 4bit mode

typedef enum {
    LCD_COMMAND_WRITE,
    LCD_DATA_WRITE
}LCDMODE_E;


void LCD_WriteByte(UInt8_T InputValue, LCDMODE_E CommandData);
UInt8_T LCD_WriteMsg(UInt8_T * msg);
UInt8_T LCD_Init(void);

#endif