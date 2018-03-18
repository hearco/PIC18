/**
  Generated Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This is the main file generated using PIC10 / PIC12 / PIC16 / PIC18 MCUs 

  Description:
    This header file provides implementations for driver APIs for all modules selected in the GUI.
    Generation Information :
        Product Revision  :  PIC10 / PIC12 / PIC16 / PIC18 MCUs  - 1.45
        Device            :  PIC18F45K50
        Driver Version    :  2.00
    The generated drivers are tested against the following:
        Compiler          :  XC8 1.35
        MPLAB             :  MPLAB X 3.40
*/

/*
    (c) 2016 Microchip Technology Inc. and its subsidiaries. You may use this
    software and any derivatives exclusively with Microchip products.

    THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
    EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
    WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
    PARTICULAR PURPOSE, OR ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION
    WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION.

    IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
    INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
    WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
    BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
    FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
    ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
    THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.

    MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE
    TERMS.
*/

#include "mcc_generated_files/mcc.h"

#define SIZE_OF_MESSAGE_BYTES       18
#define SLAVE_I2C_GENERIC_RETRY_MAX 3

/*
                         Main application
 */
void main(void)
{
    // Initialize the device
    SYSTEM_Initialize();

    // If using interrupts in PIC18 High/Low Priority Mode you need to enable the Global High and Low Interrupts
    // If using interrupts in PIC Mid-Range Compatibility Mode you need to enable the Global and Peripheral Interrupts
    // Use the following macros to:

    // Enable high priority global interrupts
    //INTERRUPT_GlobalInterruptHighEnable();

    // Enable low priority global interrupts.
    //INTERRUPT_GlobalInterruptLowEnable();

    // Disable high priority global interrupts
    //INTERRUPT_GlobalInterruptHighDisable();

    // Disable low priority global interrupts.
    //INTERRUPT_GlobalInterruptLowDisable();

    // Enable the Global Interrupts
    //INTERRUPT_GlobalInterruptEnable();

    // Disable the Global Interrupts
    //INTERRUPT_GlobalInterruptDisable();

    // Enable the Peripheral Interrupts
    //INTERRUPT_PeripheralInterruptEnable();

    // Disable the Peripheral Interrupts
    //INTERRUPT_PeripheralInterruptDisable();
    
    
    // Format of the message
    //
    // b7  b6  b5  b4  b3  b2  b1  b0
    // Rs  Rw  En  (1) D4  D5  D6  D7
    //
    unsigned char i;
    unsigned short timeout;
    unsigned char LCD_commands[SIZE_OF_MESSAGE_BYTES] = {0x32, // Enable high, set 4 bit mode
                                                        // Add 5ms delay
                                                        0x12, // Enable low

                                                        0x32, // Enable high, set 4 bit mode HIGH
                                                        // Add 5ms delay
                                                        0x12, // Enable low

                                                        0x38, // Enable high, set 4 bit mode LOW
                                                        // Add 5ms delay
                                                        0x18, // Enable low

                                                        0x30, // Enable high, set Cursor ON HIGH
                                                        // Add 5ms delay
                                                        0x10, // Enable low 

                                                        0x3F, // Enable high, set Cursor ON LOW
                                                        // Add 5ms delay
                                                        0x1F, // Enable low

                                                        0x30, // Enable high, set Cursor Home HIGH
                                                        // Add 5ms delay
                                                        0x10, // Enable low

                                                        0x32, // Enable high, set Cursor Home LOW
                                                        // Add 5ms delay
                                                        0x12, // Enable low

                                                        0x30, // Enable high, set Clear Screen HIGH
                                                        // Add 5ms delay
                                                        0x10, // Enable low 

                                                        0x31, // Enable high, set Clear Screen LOW
                                                        // Add 5ms delay
                                                        0x11 // Enable low
                                                        };
    
    unsigned char data = 0xFF;
    unsigned char * pD;
    unsigned char writeBuffer[1];
    I2C1_MESSAGE_STATUS status = I2C1_MESSAGE_PENDING;
    
    pD = LCD_commands;
    for(i = 0; i < SIZE_OF_MESSAGE_BYTES; i++)
    {
        writeBuffer[0] = *(pD + i);
        timeout = 0;
        while((status != I2C1_MESSAGE_FAIL) && (status != I2C1_MESSAGE_COMPLETE) && (timeout < SLAVE_I2C_GENERIC_RETRY_MAX))
        {
            I2C1_MasterWrite(writeBuffer, 1, 0x40, &status);
            
            // wait for the message to be sent or status has changed.
            while(status == I2C1_MESSAGE_PENDING);
            
            timeout++;
        }
        
        __delay_ms(5);
    }

    while (1)
    {
        
    }
}
/**
 End of File
*/