#include "i2c_LCD.h"
#include "i2c.h"

// Private functions
//static UInt8_T I2C_LCD_SetCursor(UInt8_T row, UInt8_T col)
//{
//    if((col > LCD_COL_LIMIT) || (row > LCD_ROW_LIMIT))
//    {
//        return 0;
//    }
//    else
//    {
//        switch(row)
//        {
//            case 0:
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_HIGH | (((LCD_SET_CURSOR_POS + col) & 0xF0) >> 4)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_LOW  | (((LCD_SET_CURSOR_POS + col) & 0xF0) >> 4)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_HIGH | ((LCD_SET_CURSOR_POS + col) & 0x0F)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_LOW  | ((LCD_SET_CURSOR_POS + col) & 0x0F)));
//                break;
//            case 1:
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_HIGH | (((LCD_SET_CURSOR_POS + 0x40 + col) & 0xF0) >> 4)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_LOW  | (((LCD_SET_CURSOR_POS + 0x40 + col) & 0xF0) >> 4)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_HIGH | ((LCD_SET_CURSOR_POS + 0x40 + col) & 0x0F)));
//                (void)I2C_Master_Write((UInt8_T)(ENABLE_LOW  | ((LCD_SET_CURSOR_POS + 0x40 + col) & 0x0F)));
//                break;
//            default:
//                I2C_LCD_ClearLCD();
//                break;
//        }
//        return 1;
//    }
//}

// Public functions
/********************************************************************************************
 * 
 *    Function: I2C_LCD_Init
 * 
 * Description: Initializes LCD screen module
 * 
 *  Parameters: N/A
 * 
 *     Returns: N/A
 * 
 ********************************************************************************************/
void I2C_LCD_Init()
{
    (void)I2C_Master_Write((I2C_LCD_SLAVE_ADDRESS << 1) | I2C_WRITE_TO_BUS);     //7 bit address + Write
    
    // 4bit
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_FOUR_BIT & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_FOUR_BIT & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_FOUR_BIT & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_FOUR_BIT & 0x0F));
    
    // Clear screen
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CLEAR_SCREEN & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CLEAR_SCREEN & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CLEAR_SCREEN & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CLEAR_SCREEN & 0x0F));
    
    // Cursor ON
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CURSOR_ON & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CURSOR_ON & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CURSOR_ON & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CURSOR_ON & 0x0F));
    
    // Cursor Home
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CURSOR_HOME & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CURSOR_HOME & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CURSOR_HOME & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CURSOR_HOME & 0x0F));
    
    //(void)I2C_LCD_SetCursor(0, 3);                                   // Fix it, it does not work

}

/********************************************************************************************
 * 
 *    Function: I2C_LCD_ClearLCD
 * 
 * Description: Clears LCD screen module
 * 
 *  Parameters: N/A
 * 
 *     Returns: N/A
 * 
 ********************************************************************************************/
void I2C_LCD_ClearLCD()
{
    // Clear screen
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CLEAR_SCREEN & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CLEAR_SCREEN & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CLEAR_SCREEN & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CLEAR_SCREEN & 0x0F));
    
    // Cursor Home
    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CURSOR_HOME & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CURSOR_HOME & 0xF0) >> 4));
    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CURSOR_HOME & 0x0F));
    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CURSOR_HOME & 0x0F));
    
    
}

/********************************************************************************************
 * 
 *    Function: I2C_LCD_WriteByte
 * 
 * Description: Sends data to LCD via i2c bus
 * 
 *  Parameters: N/A
 * 
 *     Returns: N/A
 * 
 ********************************************************************************************/
//void I2C_LCD_WriteByte(UInt8_T data)
//{
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_HIGH | ((data & 0xF0) >> 4)));
//    __delay_ms(5);
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_LOW | ((data & 0xF0) >> 4)));
//    
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_HIGH | ((data & 0xF0) >> 4)));
//    __delay_ms(5);
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_LOW | ((data & 0xF0) >> 4)));
//    
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_HIGH | (data & 0x0F)));
//    __delay_ms(5);
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_LOW | (data & 0x0F)));
//    
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_HIGH | (data & 0x0F)));
//    __delay_ms(5);
//    (void)I2C_Master_Write((UInt8_T)(I2C_LCD_WRITE_DATA | ENABLE_LOW | (data & 0x0F)));
//    
//    
//    // Cursor ON
//    (void)I2C_Master_Write(ENABLE_HIGH | ((LCD_CURSOR_ON & 0xF0) >> 4));
//    (void)I2C_Master_Write(ENABLE_LOW  | ((LCD_CURSOR_ON & 0xF0) >> 4));
//    (void)I2C_Master_Write(ENABLE_HIGH | (LCD_CURSOR_ON & 0x0F));
//    (void)I2C_Master_Write(ENABLE_LOW  | (LCD_CURSOR_ON & 0x0F));
//  
//}
