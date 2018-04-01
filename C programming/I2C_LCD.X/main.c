#include <p18f45k50.h>
#include <xc.h>
#include <htc.h>
#include <stdio.h>
#include <string.h>

#define _XTAL_FREQ                 16000000                // 16MH Fosc
#define OFF                        0
#define I2C_LCD_SLAVE_ADDRESS      0x3F          // Slave addres for PCF8574A module goes from 0x38 to 0x3F
#define I2C_WRITE_TO_BUS           0b00000000
#define I2C_READ_FROM_BUS          0b00000001
#define I2C_ENABLE_SERIAL_PORT     0b00100000
#define I2C_MASTER_MODE            0b00001000
#define I2C_CLOCK_100KHZ           0x27
#define I2C_CLOCK_50KHZ            0x4F
#define I2C_STANDARD_SPEED         0b10000000
#define I2C_START_IN_PROGRESS      0b00000001
#define I2C_RESTART_IN_PROGRESS    0b00000010
#define I2C_STOP_IN_PROGRESS       0b00000100
#define I2C_RW_IN_PROGRESS         0b00000100
#define I2C_RECEIVE_EN             0b00001000
#define I2C_ACK_EN                 0b00010000
#define I2C_TRANSMIT_IN_PROGRESS   0b00000100
#define I2C_WAITING_TO_TRANSMIT    0b00001000
#define I2C_ACK_RECEIVED           (!SSP1CON2bits.ACKSTAT)
#define I2C_SDA_HOLD_TIME_300ns    0b00001000
#define I2C_SDA_PIN                TRISBbits.TRISB0
#define I2C_SCL_PIN                TRISBbits.TRISB1

/******************************************************************************************************************************************************
 * 
 *  i2c is enabled in the Master Serial Synchronous Port
 *  Registers associated with i2c operation (p. 259)
 * 
 *  REGISTERS:    Bits:                   Datasheet: Purpose: 
 *  ANSELB        ANSB1, ANSB0            155        Configuration of SDA and SCL pins
 *  INTCON        GIE/GIEH, PEIE/GIEL     120        Global interrupt, Peripheral interrupt enable
 *  IPR1          SSPIP                   129        MSSP Interrupt priority: 1 = High, 0 = Low
 *  IPR2          BCLIP                   130        MSSP Bus collision interrupt priority: 1 = High, 0 = Low
 *  PIE1          SSPIE                   126        MSSP interrupt enable: 1 = enabled, 0 = disabled
 *  PIE2          BCLIE                   127        MSSP collision interrupt enable: 1 = enabled, 0 = disabled
 *  PIR1          SSPIF                   123        MSSP interrupt flag: 1 = transmission/reception complete, 0 = waiting
 *  PIR2          BCLIF                   124        MSSP bus collision interrupt flag: 1 = bus collision, 0 = no collision
 *  PMD1          MSSPMD                  65         MSSP Peripheral module disable control, 1 = disabled, 0 = enabled
 *  SSP1ADD       -                       267        SSP1 Address in slave mode, Baud rate in master mode. SCL pin clock period = ((ADD<7:0> + 1) * 4) / Fosc
 *  SSP1BUF       -                       -          SSP1 Receive/Transmit buffer. Write/Read data to/from this register
 *  SSP1CON1      ALL                     262        i2c modes, check datasheet for specific functions
 *  SSP1CON2      ALL                     264        i2c modes, check datasheet for specific functions, check for ACKSTAT bit for ACK result
 *  SSP1CON3      ALL                     265        i2c modes, check datasheet for specific functions, includes hold time for SDA at SDAHT pin
 *  SSP1MSK       -                       266        -
 *  SSP1STAT      ALL                     261        i2c modes, check datasheet for specific functions
 *  TRISB         TRISB1, TRISB0          156        Configuration of SDA and SCL pins
 * 
 *  For i2c master mode transmission steps, check page 248 of datasheet
 * 
 ***************************************************************************************************************************************************/
unsigned char rotateByte(unsigned char x)
{    
    unsigned char newByte = 0;
    signed char i;                      // Keep it signed to meet the conditional exit of the for loop   
    for(i = 7; i >= 0; i--)          
    {                                
        newByte |= (unsigned char)((x & 0b10000000) >> i);  
        x = (unsigned char)(x << 1);                  
    }                                

    return newByte;
}


void I2C_Master_Init()
{
    SSP1CON1 = I2C_ENABLE_SERIAL_PORT | I2C_MASTER_MODE;                           // i2c mode configuration
    SSP1CON2 = OFF;                                                                       
    SSP1ADD = I2C_CLOCK_100KHZ;                                                    // i2c bit rate setup, check examples on page 260
    SSP1STAT = I2C_STANDARD_SPEED;                                                 // Slew rate control
    
    ANSELBbits.ANSB0 = 0;                                                          // Set as digital pin
    ANSELBbits.ANSB1 = 0;                                                          
    
    I2C_SDA_PIN = 1;                                                               // Set as input
    I2C_SCL_PIN = 1;                                                               
}

unsigned char I2C_Master_Start()
{
    
    SSP1CON2 |= I2C_START_IN_PROGRESS;              //Initiate start condition SSP1CON2bits.SEN = 1;
    while(SSP1CON2 & I2C_START_IN_PROGRESS);
    return 1;
}

unsigned char I2C_Master_Write(unsigned char data)
{   
    unsigned char newData = 0;
    newData = rotateByte(data);
    SSP1BUF = newData;    
    while(SSP1STAT & I2C_RW_IN_PROGRESS); 
    return 1;
}

void I2C_Master_Stop()
{
    SSP1CON2 |= I2C_STOP_IN_PROGRESS;
    while(SSP1CON2 & I2C_STOP_IN_PROGRESS);
}



void main(void)
{   
    I2C_Master_Init();                                                           //Initialize I2C Master with 100KHz clock
    (void)I2C_Master_Start();                                                    //Start condition
    (void)I2C_Master_Write((I2C_LCD_SLAVE_ADDRESS << 1) | I2C_WRITE_TO_BUS);     //7 bit address + Write   
    (void)I2C_Master_Write(0b00010011);
    I2C_Master_Stop();                                                           //Stop condition
    
    while(1)
    {
        ANSELBbits.ANSB4 = 0;
        TRISBbits.TRISB4 = 0;
        LATBbits.LATB4 = 1;
    }
}