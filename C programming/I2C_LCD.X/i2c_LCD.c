#include "i2c_LCD.h"
#include "i2c.h"

// Private functions
/********************************************************************************************
 * 
 *    Function: rotateByte
 * 
 * Description: Left-rotate byte to correct data transfer. This function may not be needed
 *              if i2c slave module has a different hardware layout.
 * 
 *  Parameters: UInt8_T byte
 * 
 *     Returns: UInt8_T rotatedByte
 * 
 ********************************************************************************************/
static UInt8_T rotateByte(UInt8_T byte)
{    
    UInt8_T rotatedByte = 0;
    SInt8_T i;                      // Keep it signed to meet the conditional exit of the for loop   
    for(i = 7; i >= 0; i--)          
    {                                
        rotatedByte |= (UInt8_T)((byte & 0b10000000) >> i);  
        byte = (UInt8_T)(byte << 1);                  
    }                                

    return rotatedByte;
}

// Public functions
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
void I2C_LCD_WriteByte(UInt8_T data, I2C_LCD_SEND_TYPE_T dataOrCommand)
{
    UInt8_T byteToSend = 0;
    UInt8_T newByteToSend = 0;
    UInt8_T rotatedByte = 0;
    
    switch (dataOrCommand)
    {
        case I2C_LCD_SEND_DATA:
            byteToSend = (UInt8_T)I2C_LCD_WRITE_DATA;
            break;
        case I2C_LCD_SEND_COMMAND:
            byteToSend = (UInt8_T)I2C_LCD_WRITE_COMMAND;
            break;
        default:
            break;
    }
    // Send high nibble
    newByteToSend = byteToSend | ENABLE_HIGH | ((data & 0xF0) >> 4);
    rotatedByte = rotateByte(newByteToSend);
    (void)I2C_Master_Write(rotatedByte);
    newByteToSend = byteToSend | ENABLE_LOW | ((data & 0xF0) >> 4);
    rotatedByte = rotateByte(newByteToSend);
    (void)I2C_Master_Write(rotatedByte);
    
    // Send low nibble
    newByteToSend = byteToSend | ENABLE_HIGH | (data & 0x0F);
    rotatedByte = rotateByte(newByteToSend);
    (void)I2C_Master_Write(rotatedByte);
    newByteToSend = byteToSend | ENABLE_LOW | (data & 0x0F);
    rotatedByte = rotateByte(newByteToSend);
    (void)I2C_Master_Write(rotatedByte);
}

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
    // Set I2C slave address
    (void)I2C_Master_Write((I2C_LCD_SLAVE_ADDRESS << 1) | I2C_WRITE_TO_BUS);     //7 bit address + Write
    
    // 4bit
    I2C_LCD_WriteByte(LCD_FOUR_BIT, I2C_LCD_SEND_COMMAND);
    
    // Clear screen
    I2C_LCD_WriteByte(LCD_CLEAR_SCREEN, I2C_LCD_SEND_COMMAND);
    
    // Cursor ON
    I2C_LCD_WriteByte(LCD_CURSOR_ON, I2C_LCD_SEND_COMMAND);
    
    // Cursor Home
    I2C_LCD_WriteByte(LCD_CURSOR_HOME, I2C_LCD_SEND_COMMAND);
}

/********************************************************************************************
 * 
 *    Function: I2C_LCD_SendMsg
 * 
 * Description: Sends a message to display at LCD.
 * 
 *  Parameters: UInt8_T byte
 * 
 *     Returns: N/A
 * 
 *       NOTES: This function is currently not working properly
 * 
 ********************************************************************************************/
void I2C_LCD_SendMsg(UInt8_T byte)
{
    I2C_LCD_WriteByte(byte, I2C_LCD_SEND_DATA);
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
    I2C_LCD_WriteByte(LCD_CLEAR_SCREEN, I2C_LCD_SEND_COMMAND);
    
    // Cursor Home
    I2C_LCD_WriteByte(LCD_CURSOR_HOME, I2C_LCD_SEND_COMMAND);
}
