/*
 * File:   LCD.c
 * Author: usuario
 *
 * Created on 20 de julio de 2017, 12:41 AM
 */
#include "LCD.h"

// Private functions
/******************************************************************************
 * 
 *     Function: LCD_SetCursor
 * 
 *  Description: Sets LCD cursor to specific position
 * 
 *   Parameters: UInt8_T row
 *               UInt8_T col
 * 
 *      Returns: UInt8_T
 * 
 ******************************************************************************/
static UInt8_T LCD_SetCursor(UInt8_T row, UInt8_T col)
{
    if ((col > LCD_COL_LIMIT) || (row > LCD_ROW_LIMIT))
    {
        return (0);
    }
    
    else
    {
        switch(row)
        {
            case 0:
                LCD_WriteByte((UInt8_T)(LCD_SET_CURSOR_POS + col), LCD_COMMAND_WRITE);
                break;
            case 1:
                LCD_WriteByte((UInt8_T)(LCD_SET_CURSOR_POS + 0x40 + col), LCD_COMMAND_WRITE);
                break;
            default:
                LCD_WriteByte(LCD_CURSOR_HOME, LCD_COMMAND_WRITE);
                break;
        }
        
        return (1);
    }
}

// Public functions
/******************************************************************************
 * 
 *     Function: LCD_WriteByte
 * 
 *  Description: Writes data to LCD
 * 
 *   Parameters: UInt8_T InputValue
 *               LCDMODE_E CommandData
 * 
 *      Returns: N/A
 * 
 ******************************************************************************/
void LCD_WriteByte(UInt8_T InputValue, LCDMODE_E CommandData)
{
    switch (CommandData)
    {
        case LCD_COMMAND_WRITE:
            LCD_RS = 0;                        //0 = Command, 1 = Data
            break;
            
        case LCD_DATA_WRITE:
            LCD_RS = 1;                        //0 = Command, 1 = Data
            break;
        
        default:
            break;
    }
    
    R_W = 0;                        // 0 = Write, 1 = read

#ifdef LCD_SETMODE_8BIT
    LCD_DATA = (UInt8_T)InputValue;
    LCD_EN = 1;
    __delay_ms(5);
    LCD_EN = 0;
#else    
    LCD_DATA = (UInt8_T)(InputValue & 0xF0);
    LCD_EN = 1;
    __delay_ms(5);
    LCD_EN = 0;
    
    LCD_DATA = (UInt8_T)((InputValue << 4) & 0xF0);
    LCD_EN = 1;
    __delay_ms(5);
    LCD_EN = 0;
#endif // LCD_MODE_8BIT
}

/******************************************************************************
 * 
 *     Function: LCD_WriteMsg
 * 
 *  Description: Writes a message to LCD
 * 
 *   Parameters: UInt8_T * msg
 * 
 *      Returns: UInt8_T
 * 
 ******************************************************************************/
UInt8_T LCD_WriteMsg(UInt8_T * msg)
{
    UInt8_T i, j;
    UInt8_T msgSize;
    UInt8_T lcdRowPos;
    UInt8_T lcdColPos;
    UInt8_T charsLeft;
    UInt8_T status = 1;
    
    msgSize = (UInt8_T)strlen(msg);
    
    // Before writing to LCD, clear screen and set cursor home
    LCD_WriteByte(LCD_CURSOR_HOME,  LCD_COMMAND_WRITE);
    LCD_WriteByte(LCD_CLEAR_SCREEN, LCD_COMMAND_WRITE);
    
    lcdRowPos = 0;
    lcdColPos = 0;
    charsLeft = 0;
    for(i = 0; i <= LCD_ROW_LIMIT; i++)
    {
        if(LCD_SetCursor(i, 0))
        {
            for(j = 0; (charsLeft < msgSize) && (j < LCD_COL_LIMIT); j++)
            {
                LCD_WriteByte(*(msg + LCD_COL_LIMIT * i + j), LCD_DATA_WRITE);
                charsLeft++;
            }
        }
        
        // Something went wrong when accessing a position at LCD
        else
        {
            status = 0;
        }
    }
    
    return status;
}



/******************************************************************************
 * 
 *     Function: LCD_Init
 * 
 *  Description: Initializes and sets up LCD
 * 
 *   Parameters: N/A
 * 
 *      Returns: UInt8_T
 * 
 ******************************************************************************/
UInt8_T LCD_Init(void)
{
    LCD_ANSEL_CTRL = 0;
    LCD_ANSEL_DATA = 0;

    LCD_CTRL_TRIS = 0;
    LCD_CTRL = 0;

    LCD_DATA_TRIS = 0;
    LCD_DATA = 0;

#ifdef LCD_SETMODE_8BIT
    LCD_WriteByte(LCD_EIGHT_BIT,    LCD_COMMAND_WRITE);
#else    
    LCD_RS = 0;        //0 = Command, 1 = Data
    LCD_RW = 0;        // 0 = Write, 1 = read
    LCD_DATA = 0x20;
    LCD_EN = 1;
    __delay_ms(5);
    LCD_EN = 0;
    
    LCD_WriteByte(LCD_FOUR_BIT,     LCD_COMMAND_WRITE);
#endif //LCD_MODE_8BIT
    
    LCD_WriteByte(LCD_CURSOR_ON,    LCD_COMMAND_WRITE);
    LCD_WriteByte(LCD_CURSOR_HOME,  LCD_COMMAND_WRITE);
    LCD_WriteByte(LCD_CLEAR_SCREEN, LCD_COMMAND_WRITE);
    
    return INIT_SUCCESS;
}