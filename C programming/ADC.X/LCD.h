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

#include <xc.h> // include processor files - each processor file is guarded.  


/****   LCD BITS & PORTS DEFINES   *****/
#define R_S             LATCbits.LATC0          // Instruction/Data pin
#define R_W             LATCbits.LATC1          // Read/Write pin
#define enable_pin      LATCbits.LATC2          // Enable signal
#define busy_bit        PORTDbits.RD3           // Busy status pin
#define LCD_CTRL        LATC                    // CONTROL port for LCD
#define LCD_DATA        LATD                    // DATA port for LCD
#define LCD_CTRL_TRIS   TRISC                   // For use to set up CONTROL port as output
#define LCD_DATA_TRIS   TRISD                   // For use to set up DATA port as I/O
#define ANSEL_CTRL      ANSELC                  // For use to set up CONTROL port as digital
#define ANSEL_DATA      ANSELD                  // For use to set up DATA port as digital

/****   LCD instructions   *************/
#define FOUR_BIT        0x28                    // 4-bit interface, 2 lines, 5x7 dots
#define SET_CURSOR_POS  0x80                    // Base address to set cursor position
#define LCD_CURSOR_ON   0x0F                    // Display on, cursor on, cursor blinking
#define CURSOR_HOME     0x02                    // Cursor at home
#define CLEAR_SCREEN    0x01                    // Clear LCD screen

/****   LCD constants   ****************/
#define FIRST_ROW       0 
#define SECOND_ROW      1
#define LCD_COL_LIMIT   15
#define INIT_SUCCESS    1

/****   Program variables   **************/
unsigned char lcd_pos = 0;

/*
 *  Function prototype:
 *      void LCD_char(unsigned char)
 *
 *  Description:
 *      Write character to LCD
 *
 *  Parameters:
 *      unsigned char a: Character to write
 *
 *  Returns:
 *      Nothing
 */
void LCD_char(unsigned char a){
    R_S = 1;                        //0 = Command, 1 = Data
    R_W = 0;                        // 0 = Write, 1 = read
    
    LCD_DATA = ((a >> 4) & 0x0F);
    enable_pin = 1;
    __delay_ms(5);
    enable_pin = 0;
    
    LCD_DATA = a;
    enable_pin = 1;
    __delay_ms(5);
    enable_pin = 0;
}

/*
 *  Function prototype:
 *      void LCD_msg(unsigned char a[])
 *
 *  Description:
 *      Write string to LCD
 *
 *  Parameters:
 *      unsigned char a[]: Array of characters to write
 *
 *  Returns:
 *      Nothing
 */
void LCD_msg(unsigned char a[]){
    unsigned char i = 0;
    while (a[i] != '\0'){
        if (lcd_pos > (LCD_COL_LIMIT - 1))
            break;
        
        LCD_char(a[i]);
        i++;
        lcd_pos++;
    }
}

/*
 *  Function prototype:
 *      void LCD_setup(unsigned char a)
 *
 *  Description:
 *      Sends command to LCD
 *
 *  Parameters:
 *      unsigned char a: Command to send to LCD
 *
 *  Returns:
 *      Nothing
 */
void LCD_setup(unsigned char a){
    R_S = 0;                        //0 = Command, 1 = Data
    R_W = 0;                        // 0 = Write, 1 = read
    
    LCD_DATA = ((a >> 4) & 0x0F);
    enable_pin = 1;
    __delay_ms(5);
    enable_pin = 0;
    
    LCD_DATA = a;
    enable_pin = 1;
    __delay_ms(5);
    enable_pin = 0;
}

/*
 *  Function prototype:
 *      void set_cursor_pos(unsigned char row, unsigned char col)
 *
 *  Description:
 *      Set LCD cursor at user-defined position
 *
 *  Parameters:
 *      unsigned char row: Row where the cursor is desired (0 or 1)
 *      unsigned char col: Column where the cursor is desired (0 to 15)
 *
 *  Returns:
 *      Nothing
 */
void set_cursor_pos(unsigned char row, unsigned char col){
    if ((col > LCD_COL_LIMIT) || col < 0){
        LCD_setup(CLEAR_SCREEN);
        LCD_msg("ERR");
    }
    
    else{
        lcd_pos = col;
        switch(row){
            case 0: LCD_setup((unsigned char)(SET_CURSOR_POS + col));
                break;
            case 1: LCD_setup((unsigned char)(SET_CURSOR_POS + 0x40 + col));
                break;
            default: LCD_setup(CURSOR_HOME);
                break;
        }
    }
}

/*
 *  Function prototype:
 *      bool LCD_init(void)
 *
 *  Description:
 *      Set everithing up to use LCD
 *
 *  Parameters:
 *      None
 *
 *  Returns:
 *      TRUE when done
 */
unsigned char LCD_init(void){
    ANSEL_CTRL = 0;
    ANSEL_DATA = 0;

    LCD_CTRL_TRIS = 0;
    LCD_CTRL = 0;

    LCD_DATA_TRIS = 0;
    LCD_DATA = 0;
    
    R_S = 0;        //0 = Command, 1 = Data
    R_W = 0;        // 0 = Write, 1 = read
    LCD_DATA = 0x02;
    enable_pin = 1;
    __delay_ms(5);
    enable_pin = 0;

    LCD_setup(FOUR_BIT);
    LCD_setup(LCD_CURSOR_ON);
    LCD_setup(CURSOR_HOME);
    LCD_setup(CLEAR_SCREEN);
    
    return INIT_SUCCESS;
}

#endif