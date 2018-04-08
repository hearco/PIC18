/* *************************************************************************
 * 
 *        File: i2c_LCD.h
 * 
 *      Author: Ariel Almendariz
 * 
 *    Comments: This file contains the function prototypes and constant
 *              defines to handle the LCD via i2c. 
 * 
 * Last update: Apr / 8 / 18
 *
 **************************************************************************/

#ifndef I2C_LCD_H
#define	I2C_LCD_H

#include "hwconfig.h"


#define ENABLE_HIGH                0b00110000
#define ENABLE_LOW                 0b00010000
#define I2C_LCD_WRITE_DATA         0b10010000
#define I2C_LCD_WRITE_COMMAND      0b00010000
#define I2C_LCD_SLAVE_ADDRESS      0x3F          // Slave addres for PCF8574A module goes from 0x38 to 0x3F, change it as needed

/****   LCD instructions   *************/
#define LCD_FOUR_BIT        0x28                    // 4-bit interface, 2 lines, 5x7 dots
#define LCD_SET_CURSOR_POS  0x80                    // Base address to set cursor position
#define LCD_CURSOR_ON       0x0F                    // Display on, cursor on, cursor blinking
#define LCD_CURSOR_HOME     0x02                    // Cursor at home
#define LCD_CLEAR_SCREEN    0x01                    // Clear LCD screen

#define LCD_COL_LIMIT       16
#define LCD_ROW_LIMIT       1
#define LCD_SET_CURSOR_POS  0x80                    // Base address to set cursor position

typedef enum{
    I2C_LCD_SEND_DATA,
    I2C_LCD_SEND_COMMAND
}I2C_LCD_SEND_TYPE_T;

void I2C_LCD_WriteByte(UInt8_T data, I2C_LCD_SEND_TYPE_T dataOrCommand);
void I2C_LCD_Init();
void I2C_LCD_SendMsg(UInt8_T byte);
void I2C_LCD_ClearLCD();

// TODO: Add functions to read LCD status, and to write messages

#endif	// I2C_LCD_H

