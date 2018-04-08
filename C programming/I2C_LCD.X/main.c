#include "i2c_LCD.h"
#include "i2c.h"


void main(void)
{   
    UInt8_T data = 'A';
    
    I2C_Master_Init();                                                           //Initialize I2C Master with 100KHz clock
    (void)I2C_Master_Start();                                                    //Start condition
    
    I2C_LCD_Init();
    //I2C_LCD_SendMsg(data); //       <-- commented out as it is not working properly
    
    I2C_Master_Stop();                                                           //Stop condition
    
    while(1)
    {
        // Just putting some output to see that I am not getting stucked in any previous function
        ANSELBbits.ANSB4 = 0;
        TRISBbits.TRISB4 = 0;
        LATBbits.LATB4 = 1;
    }
}