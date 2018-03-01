/* Microchip Technology Inc. and its subsidiaries.  You may use this software 
 * and any derivatives exclusively with Microchip products. 
 * 
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS".  NO WARRANTIES, WHETHER 
 * EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED 
 * WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A 
 * PARTICULAR PURPOSE, OR ITS INTERACTION WITH MICROCHIP PRODUCTS, COMBINATION 
 * WITH ANY OTHER PRODUCTS, OR USE IN ANY APPLICATION. 
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE, 
 * INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND 
 * WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS 
 * BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE.  TO THE 
 * FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS 
 * IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF 
 * ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *
 * MICROCHIP PROVIDES THIS SOFTWARE CONDITIONALLY UPON YOUR ACCEPTANCE OF THESE 
 * TERMS. 
 */

/* 
 * File:   
 * Author: 
 * Comments:
 * Revision history: 
 */

// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef ADC_H
#define	ADC_H

#include <xc.h> // include processor files - each processor file is guarded.

// Analog references
#define VREF_POS    0b00000100  // External positive voltage reference AN3 (RA3)
#define VREF_NEG    0b00000001  // External negative voltage reference AN2 (RA2)

// Analog pins PORTA
#define RA0     0b00000000      // AN0
#define RA1     0b00001000      // AN1
#define RA2     0b00010000      // AN2
#define RA3     0b00011000      // AN3
#define RA5     0b00100000      // AN4

// Analog pins PORTB
#define RB2     0b01000000      // AN8
#define RB3     0b01001000      // AN9
#define RB1     0b01010000      // AN10
#define RB4     0b01011000      // AN11
#define RB0     0b01100000      // AN12
#define RB5     0b01101000      // AN13

// Analog pins PORTC
#define RC2     0b01110000      // AN14
#define RC6     0b10010000      // AN18
#define RC7     0b10011000      // AN19

// Analog pins PORTD
#define RD0     0b10100000      // AN20
#define RD1     0b10101000      // AN21
#define RD2     0b10110000      // AN22
#define RD3     0b10111000      // AN23
#define RD4     0b11000000      // AN24
#define RD5     0b11001000      // AN25
#define RD6     0b11010000      // AN26
#define RD7     0b11011000      // AN27

// Analog pins PORTE
#define RE0     0b00101000      // AN5
#define RE1     0b00110000      // AN6
#define RE2     0b00111000      // AN7


void analogInit(unsigned char analog_pin){
    ANSELAbits.ANSA0 = 1;
    TRISAbits.TRISA0 = 1; // Input
    ADCON0bits.ADON = 0;
    
    /* ----------------------------------------------------------------------------------------*
     *  b7      b6      b5          b4          b3          b2          b1          b0         *
     *  ADFM    U-0     ACQT<2>     ACQT<1>     ACQT<0>     ACDS<2>     ACDS<1>     ACDS<0>    *
     *                                                                                         *
     *  ADFM:           1 -> Conversion result right justified                                 *
     *                  0 -> Conversion result Left justified                                  *
     *  Unimplemented:  Read as '0'                                                            *
     *  ACQT<2:0>:      A/D Acquisition time select bits.                                      *
     *                      000 - 0                                                            *
     *                      001 - 2 TAD                                                        *
     *                      010 - 4 TAD                                                        *
     *                      011 - 6 TAD                                                        *
     *                      100 - 8 TAD                                                        *
     *                      101 - 12 TAD                                                       *
     *                      110 - 16 TAD                                                       *
     *                      111 - 20 TAD                                                       *
     *  ADCS<2:0>:      A/D Conversion clock select bits                                       *
     *                      000 - FOSC/2                                                       *
     *                      001 - FOSC/8                                                       *
     *                      010 - FOSC/32                                                      *
     *                      011 - FRC                                                          *
     *                      100 - FOSC/4                                                       *
     *                      101 - FOSC/16                                                      *
     *                      110 - FOSC/64                                                      *
     *                      111 - FRC                                                          *
     * ----------------------------------------------------------------------------------------*
     */
    ADCON2 = 0b10110101;
    
    /* --------------------------------------------------------------------------------------*
     *  b7          b6      b5      b4      b3          b2          b1          b0           *
     *  TRIGSEL     U-0     U-0     U-0     PVCFG<1>    PVCFG<0>    NVCFG<1>    NVCFG<0>     *
     *                                                                                       *
     *  TRIGSEL:    1 -> Selects the special trigger from CTMU                               *
     *              0 -> Selects the special trigger from CCP2                               *
     *  U-0<2:0>:   Read as '0'                                                              *
     *  PVCFG<1:0>: Positive voltage reference configuration bits.                           *
     *                  00 - A/D VREF+ connected to internal signal, AVDD                    *
     *                  01 - A/D VREF+ connected to external pin, VREF+                      *
     *                  10 - A/D VREF+ connected to internal signal, FVR BUF2                *
     *                  11 - Reserved                                                        *
     *  NVCFG<1:0>: Negative voltage reference configuration bits                            *
     *                  00 - A/D VREF- connected to internal signal, AVSS                    *
     *                  01 - A/D VREF+ connected to external pin, VREF-                      *
     *                  10 - Reserved                                                        *
     *                  11 - Reserved                                                        *
     * --------------------------------------------------------------------------------------*
     */
    ADCON1 = 0b10000000; //
    
    /* ---------------------------------------------------------------------------------------------*
     *  b7      b6      b5          b4          b3          b2          b1          b0              *
     *  U-0     CHS<4>  CHS<3>      CHS<2>      CHS<1>      CHS<0>      GO/DONE     ADON            *
     *                                                                                              *
     *  U-0:        Read as '0'                                                                     *
     *  CHS<4:0>:   Analog channel select bits                                                      *
     *                  00000 - AN0                                                                 *
     *                  00001 - AN1                                                                 *
     *                  00010 - AN2                                                                 *
     *                  00011 - AN3                                                                 *
     *                  00100 - AN4                                                                 *
     *                  00101 - AN5                                                                 *
     *                  00110 - AN6                                                                 *
     *                  00111 - AN7                                                                 *
     *                  01000 - AN8                                                                 *
     *                  01001 - AN9                                                                 *
     *                  01010 - AN10                                                                *
     *                  01011 - AN11                                                                *
     *                  01100 - AN12                                                                *
     *                  01101 - AN13                                                                *
     *                  01110 - AN14                                                                *
     *                  01111 - AN15                                                                *
     *                  10000 - AN16                                                                *
     *                  10001 - AN17                                                                *
     *                  10010 - AN18                                                                *
     *                  10011 - AN19                                                                *
     *                  10100 - AN20                                                                *
     *                  10101 - AN21                                                                *
     *                  10110 - AN22                                                                *
     *                  10111 - AN23                                                                * 
     *                  11000 - AN24                                                                *
     *                  11001 - AN25                                                                *
     *                  11010 - AN26                                                                *
     *                  11011 - AN27                                                                *
     *                  11100 - Temperature diode                                                   *
     *                  11101 - CTMU                                                                *
     *                  11110 - DAC                                                                 *
     *                  11111 - FVR BUF2 (1.024V / 2.048V / 4.096V Fixed voltage reference)         *                                            *
     *  GO/DONE:    1 -> A/D conversion cycle in progress. Set this bit to start A/D                *
     *              0 -> A/D conversion completed. This bit is automatically cleared when A/D       *
     *                   finishes.                                                                  * 
     *  ADON:       1 -> ADC is enabled                                                             *
     *              0 -> ADC is disabled and consumes no operating current.                         *
     * ---------------------------------------------------------------------------------------------*
     */
    ADCON0 = 0b00000001;
}

unsigned int analog_read(unsigned char analog_pin){
    analogInit(analog_pin);
    
    unsigned int value;
    ADCON0bits.GO = 1;
    while(ADCON0bits.DONE == 1);
    value = (ADRESH << 8) | ADRESL;
    return value;
}


#endif	/* XC_HEADER_TEMPLATE_H */

