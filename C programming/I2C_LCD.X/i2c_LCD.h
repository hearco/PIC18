/* Microchip Technology Inc. and its subsidiaries.  You may use this software 
 * and any derivatives exclusively with Microchip products. 
 * 
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER 
 * EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED 
 * WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A 
 * PARTICULAR PURPOSE, OR ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION 
 * WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION. 
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE, 
 * INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND 
 * WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS 
 * BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.  TO THE 
 * FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS 
 * IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF 
 * ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *
 * MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE 
 * TERMS. 
 */

/* 
 * File:   
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef I2C_LCD_H
#define	I2C_LCD_H

#include "hwconfig.h"


#define ENABLE_HIGH                0b00110000
#define ENABLE_LOW                 0b00010000
#define I2C_LCD_WRITE_DATA         0b10010000
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

void I2C_LCD_Init();
void I2C_LCD_ClearLCD();
//void I2C_LCD_WriteByte(UInt8_T data);

// TODO: Add functions to read LCD status, and to write messages

#endif	// I2C_LCD_H

