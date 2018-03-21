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
#define I2C_NO_COLLISION           0b00000000
#define I2C_NO_OVERFLOW            0b00000000
#define I2C_ENABLE_SERIAL_PORT     0b00100000
#define I2C_MASTER_MODE            0b00001000
#define I2C_START_IDLE             0b00000000
#define I2C_RESTART_IDLE           0b00000000
#define I2C_STOP_IDLE              0b00000000
#define I2C_CLOCK_100KHZ           0x27
#define I2C_STANDARD_SPEED         0b10000000
#define I2C_STOPBIT_NOTDETECTED    0b00000000
#define I2C_STARTPBIT_NOTDETECTED  0b00000000
#define I2C_START_IN_PROGRESS      0b00000001
#define I2C_RESTART_IN_PROGRESS    0b00000010
#define I2C_STOP_IN_PROGRESS       0b00000100
#define I2C_RECEIVE_EN             0b00001000
#define I2C_ACK_EN                 0b00010000
#define I2C_TRANSMIT_IN_PROGRESS   0b00000100
#define I2C_WAITING_TO_TRANSMIT    0b00001000
#define I2C_ACK_RECEIVED           (!SSP1CON2bits.ACKSTAT)
#define I2C_SDA_HOLD_TIME_300ns    0b00001000
#define SWAP(x)                    ((((x) & 0x0F) << 4) | (((x) & 0xF0) >> 4))

// CONFIG
//#pragma config FOSC = XT   // Oscillator Selection bits (XT oscillator)
//#pragma config WDTE = OFF  // Watchdog Timer Enable bit (WDT disabled)
//#pragma config PWRTE = OFF // Power-up Timer Enable bit (PWRT disabled)
//#pragma config BOREN = OFF // Brown-out Reset Enable bit (BOR disabled)
//#pragma config LVP = OFF   // Low-Voltage In-Circuit Serial Programming Enable bit
//#pragma config CPD = OFF   // Data EEPROM Memory Code Protection bit 
//#pragma config WRT = OFF   // Flash Program Memory Write Enable bits 
//#pragma config CP = OFF    // Flash Program Memory Code Protection bit

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

void I2C_Master_Init(const unsigned long clockSpeed)
{
    SSP1CON1 = I2C_ENABLE_SERIAL_PORT | I2C_MASTER_MODE;
    SSP1CON2 = I2C_START_IDLE | I2C_RESTART_IDLE | I2C_STOP_IDLE;                                                                               // 
    SSP1CON3 |= I2C_SDA_HOLD_TIME_300ns;
    SSP1ADD = I2C_CLOCK_100KHZ;                                                           // 100 Khz, check p. 260 for examples
    SSP1STAT = I2C_STANDARD_SPEED;                                                        // SSP1STAT1 register
    ANSELBbits.ANSB0 = 0;                                                                 // Set as digital pin
    ANSELBbits.ANSB1 = 0;                                                                 // Set as digital pin
    
    TRISBbits.TRISB0 = 1;                                                                 // Set as input
    TRISBbits.TRISB1 = 1;                                                                 // Set as input
}

void I2C_Master_Wait()
{
    //
    while((SSP1STAT & I2C_TRANSMIT_IN_PROGRESS) || (SSP1CON2 & (I2C_ACK_EN | I2C_RECEIVE_EN | I2C_STOP_IN_PROGRESS | I2C_RESTART_IN_PROGRESS | I2C_START_IN_PROGRESS)));
}

unsigned char I2C_Master_Start()
{
    SSP1CON2 |= I2C_START_IN_PROGRESS;              //Initiate start condition SSP1CON2bits.SEN = 1;
    while(!(PIR1 & I2C_WAITING_TO_TRANSMIT));       // Waiting to transmit/receive
    
    PIR1bits.SSPIF = 0;           // Transmission has completed, clear flag
    //I2C_Master_Wait();
    return 1;
}

void I2C_Master_Stop()
{
    
    SSP1CON2 |= I2C_STOP_IN_PROGRESS;
    while(!(PIR1 & I2C_WAITING_TO_TRANSMIT));       // Waiting to transmit/receive
    //I2C_Master_Wait();
}

unsigned char I2C_Master_Write(unsigned char data)
{
    
    unsigned char temp;
    temp = (unsigned char)SWAP(data);
    //SSP1BUF = temp;        // Change data nibbles
    SSP1BUF = data; 
    
    //while(!(PIR1 & I2C_TRANSMISSION_COMPLETE)); // Waiting to transmit/receive
    while(!(PIR1 & I2C_WAITING_TO_TRANSMIT));       // Waiting to transmit/receive
    //I2C_Master_Wait();
            
    if(I2C_ACK_RECEIVED)
    {
        //Acknowledge was received
        return 1;
    }
    else
    {
        //Acknowledge was NOT received
        return 0;
    }
}

void main(void)
{
    ANSELB = ANSELD = 0;
    TRISD = 0;
    TRISBbits.TRISB7 = 0;
    LATBbits.LATB7 = 0;
    
    I2C_Master_Init(100000);      //Initialize I2C Master with 100KHz clock
    
    // Format of the message
    //
    // b7  b6  b5  b4  b3  b2  b1  b0
    // Rs  Rw  En  (1) D4  D5  D6  D7
    //
    
    // 
    (void)I2C_Master_Start();                                                    //Start condition
    (void)I2C_Master_Write((I2C_LCD_SLAVE_ADDRESS << 1) | I2C_WRITE_TO_BUS);     //7 bit address + Write
    
    // LCD 4 bit
    (void)I2C_Master_Write(0x0F);
    //(void)I2C_Master_Write(0x12);
    //(void)I2C_Master_Write(0x38);
    //(void)I2C_Master_Write(0x18);
    
    // LCD_CURSOR_ON
    //(void)I2C_Master_Write(0x30);
    //(void)I2C_Master_Write(0x10);
    //(void)I2C_Master_Write(0x3F);
    //(void)I2C_Master_Write(0x1F);
    
    // LCD_CURSOR_HOME
    //(void)I2C_Master_Write(0x30);
    //(void)I2C_Master_Write(0x10);
    //(void)I2C_Master_Write(0x32);
    //(void)I2C_Master_Write(0x12);
    
    // LCD_CLEAR_SCREEN
    //(void)I2C_Master_Write(0x30);
    //(void)I2C_Master_Write(0x10);
    //(void)I2C_Master_Write(0x31);
    //(void)I2C_Master_Write(0x11);
    
    
    
    I2C_Master_Stop();                                                           //Stop condition
    
    
    
    
    
    while(1)
    {
        LATD = 1;
    }
}