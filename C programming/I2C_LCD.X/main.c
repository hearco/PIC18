#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>
#include <string.h>
#include "i2c.h"


void main(void)
{   
    I2C_Master_Init();                                                           //Initialize I2C Master with 100KHz clock
    (void)I2C_Master_Start();                                                    //Start condition
    (void)I2C_Master_Write((I2C_LCD_SLAVE_ADDRESS << 1) | I2C_WRITE_TO_BUS);     //7 bit address + Write   
    (void)I2C_Master_Write(0b11010011);
    I2C_Master_Stop();                                                           //Stop condition
    
    while(1)
    {
        ANSELBbits.ANSB4 = 0;
        TRISBbits.TRISB4 = 0;
        LATBbits.LATB4 = 1;
    }
}