/* 
 * File: serial.h
 * Author: Ariel Almendariz
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef SERIAL_H
#define SERIAL_H

#include <xc.h> // include processor files - each processor file is guarded.  

/**** Serial  ****************/
#define BUFF_SIZE_LIMIT         70
#define SENDING_BYTE            !TXSTA1bits.TRMT
#define BYTE_AT_SERIAL_PORT     PIR1bits.RCIF
#define MSG_TRANSMITTED         0
#define NO_SOH_ERROR            -1
#define NO_EOT_ERROR            -2
#define UNK_ERROR               -3

unsigned char SERIAL_BUFFER[BUFF_SIZE_LIMIT];

/*! \fn void serial_config( unsigned int baud_rate )
*   \brief   initialize serial port interface and prepare for receive
             data at serial port by using interrupts
*   \param   baud_rate value to set up serial port speed transfer
*/
void serial_config(unsigned int baud_rate){
    
    unsigned char val_high, val_low;
    unsigned int temp;
    temp = val_high = val_low = 0;
    
    temp = ((16000000 / baud_rate) / 64) - 1;
    
    ANSELC = 0;
    
    TRISCbits.TRISC6 = 0;               //  TX/CK output
    TRISCbits.TRISC7 = 1;               //  RX/DT input
    
    BAUDCON1bits.TXCKP = 0;             //  Idle state for transmit (TX) is high
    BAUDCON1bits.RXDTP = 0;             //  Receive data (RX) is active-high
    BAUDCON1bits.BRG16 = 0;             //  16-bit Baud rate generator (SPBRGHx:SPBRGx)
    
    TXSTA1bits.BRGH = 0;                //  High Speed enable
    TXSTA1bits.SYNC = 0;                //  Transmit status and control register, Modo asincrono
    TXSTA1bits.TXEN = 1;                //  Transmit status and control register, transmit enabled
    
    SPBRGH1 = temp / 256;               //  EUSART Baud rate generator, High Byte = 0
    SPBRG1 = temp;                      //  EUSART Baud rate generator, Low Byte = 0001 1001
    
    RCSTA1bits.CREN = 1;                //  Receive status and control register, enables receiver
    RCSTA1bits.SPEN = 1;                //  Receive status and control register, Serial port enabled
    
    PIE1bits.RCIE = 1;
    PIE1bits.TXIE = 0;
    
}

/*! \fn void serial_echo( void )
*   \brief   read byte at serial port and send it back. This function
*            is mainly for debugging porpuses
*/
void serial_echo(){
        TXREG1 = RCREG1;
        while(!TXSTA1bits.TRMT);
        PIR1bits.RCIF = 0;
}

/*! \fn unsigned char serial_read_msg( unsigned char *msg_to_receive, unsigned char soh, unsigned char eot )
*   \brief   Read all bytes coming between soh and eot bytes, and store them together
*            at msg_to_receive
*   \param   msg_to_receive pointer to serial buffer to store all bytes received
*   \param   soh Start of header of message. Defines when to start storing bytes
*            at buffer. This typically is a constant value defined by the user.
*   \param   eot End of transmission of message. Defines when to stop storing bytes
*            at buffer. This typically is a constant value defined by the user.
*   \return  message status : i > Returns the byte count of the message.
*                             -1 (MSG_NO_SOH) > No SOH in received message.
*                             -2 (MSG_NO_EOT) > No EOT in received message.
*/
signed char serial_read_msg(unsigned char *msg_to_receive, unsigned char soh, unsigned char eot){
    
    unsigned char i, temp_soh, temp_eot;
    i = temp_soh = temp_eot = 0;
    
    // Keeps reading serial port
    while (i < BUFF_SIZE_LIMIT){
       
        // Check for byte at serial
        if (BYTE_AT_SERIAL_PORT){
            *msg_to_receive = RCREG1;
            
            // Check for start of transmission
            if((*msg_to_receive == soh) && !(temp_soh)){
                temp_soh = 1;
            }
            
            // Check for end of transmission
            else if(*msg_to_receive == eot){
                temp_eot = 1;
                INTCONbits.GIE = 0;
                break;
            }
            
            //Byte count
            i++;
            *(msg_to_receive++);
        }
    }
    if (temp_soh && temp_eot)
        //Return byte count
        return i;
    
    else if (!temp_soh)
        return (signed char)NO_SOH_ERROR;
    
    else if (!temp_eot)
        return (signed char)NO_EOT_ERROR;
    
    else
        return (signed char)UNK_ERROR;
}

/*! \fn unsigned char serial_send_msg(unsigned char *msg_to_send, unsigned char soh, unsigned char eot)
*   \brief   Send all bytes between soh and eot, that are store
*            at msg_to_send
*   \param   msg_to_send pointer to serial buffer to send all bytes stored
*   \param   soh Start of header of message. Defines when to start storing bytes
*            at buffer. This typically is a constant value defined by the user.
*   \param   eot End of transmission of message. Defines when to stop storing bytes
*            at buffer. This typically is a constant value defined by the user.
*   \return  MSG_TRANSMITTED : 0 > success
*/
unsigned char serial_send_msg(unsigned char *msg_to_send, unsigned char soh, unsigned char eot){
    
    unsigned char i = 0;
    
    while((*msg_to_send != soh) && (i < BUFF_SIZE_LIMIT)){
        *(msg_to_send++);
        i++;
    }
    *(msg_to_send++);
    i++;
    
    while (*msg_to_send != eot && i < BUFF_SIZE_LIMIT){
        TXREG1 = *msg_to_send;
        while(SENDING_BYTE);
        *(msg_to_send++);
        i++;
    }
    PIR1bits.RCIF = 0;
    INTCONbits.GIE = 1;
    return MSG_TRANSMITTED;
}

/*! \fn unsigned char serial_send_string( unsigned char *string_to_send )
*   \brief   Send an array of characters until end of line ('\0') is found.
*   \param   string_to_send string constant which is composed by an array of characters
*   \return  MSG_TRANSMITTED : 0 > success
*/
unsigned char serial_send_string(unsigned char *string_to_send){
    
    while (*string_to_send != '\0'){
        TXREG1 = *string_to_send;
        while(SENDING_BYTE);
        *(string_to_send++);
    }
    PIR1bits.RCIF = 0;
    INTCONbits.GIE = 1;
    return MSG_TRANSMITTED;
}

//TODO: currently not supported, mmaybe add later
//void serial_timeout( unsigned char seconds );

#endif  /* XC_HEADER_TEMPLATE_H */

