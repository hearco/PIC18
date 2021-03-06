/* *************************************************************************
 * 
 *        File: i2c.h
 * 
 *      Author: Ariel Almendariz
 * 
 *    Comments: This file contains the function prototypes and constant
 *              defines to configure the i2c module. 
 * 
 * Last update: Apr / 8 / 18
 *
 **************************************************************************/

#ifndef I2C_HEADER_H
#define	I2C_HEADER_H

#include "hwconfig.h"

#define _XTAL_FREQ                 16000000      // 16MH Fosc
#define OFF                        0
#define I2C_WRITE_TO_BUS           0b00000000    
#define I2C_READ_FROM_BUS          0b00000001    
#define I2C_ENABLE_SERIAL_PORT     0b00100000
#define I2C_MASTER_MODE            0b00001000
#define I2C_CLOCK_100KHZ           0x27
#define I2C_CLOCK_50KHZ            0x4F
#define I2C_STANDARD_SPEED         0b10000000    // Default max speed for i2c is 100Khz; however, some devices are capable of supporting high speed (up to 400Khz)
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
#define I2C_SDA_PIN                (TRISBbits.TRISB0)
#define I2C_SCL_PIN                (TRISBbits.TRISB1)


void I2C_Master_Init();
UInt8_T I2C_Master_Start();
UInt8_T I2C_Master_Write(UInt8_T data);
void I2C_Master_Stop();

// TODO: Add functions to read data from i2c bus and for error checking


#endif	// I2C_HEADER_H

