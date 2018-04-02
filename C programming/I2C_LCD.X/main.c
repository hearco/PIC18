//#include <p18f45k50.h>
//#include <xc.h>
//#include <htc.h>
//#include <stdio.h>
//#include <string.h>
#include "i2c_LCD.h"
#include "i2c.h"


void main(void)
{   
    I2C_Master_Init();                                                           //Initialize I2C Master with 100KHz clock
    (void)I2C_Master_Start();                                                    //Start condition
    
    I2C_LCD_Init();
    I2C_LCD_ClearLCD();
    
    I2C_Master_Stop();                                                           //Stop condition
    
    while(1)
    {
        ANSELBbits.ANSB4 = 0;
        TRISBbits.TRISB4 = 0;
        LATBbits.LATB4 = 1;
    }
}