
#include "timers.h"

/****************************************************
 * 
 *    Function: TMR0_Config
 * 
 * Description:
 * 
 *  Parameters:
 * 
 *     Returns: N/A
 * 
 ***************************************************/
void TMR0_Config(UInt8_T clock_source, T0CON_PREESCALER_VALUES_T preescaler)
{
    /* ---------------------------------------------------------------------------------------------*
     *  b7          b6          b5          b4          b3          b2          b1          b0      *
     *  GIE/GIEH    PEIE/GIEL   TMR0IE      INT0IE      IOCIE       TMR0IF      INT0IF      IOCIF   *
     *                                                                                              *
     *   GIE/GIEH:  When IPEN = 0                                                                   *
     *              1 -> Enables all unmasked interrupts                                            *
     *              0 -> Disables all interrupts including peripherals                              *
     *              When IPEN = 1                                                                   *
     *              1 -> Enables all high priority interrupts                                       *
     *              0 -> Disables all interrupts including low priority                             *
     *  PEIE/GIEL:  When IPEN = 0                                                                   *
     *              1 -> Enables all unmasked peripheral interrupts                                 *
     *              0 -> Disables all peripheral interrupts                                         *
     *              When IPEN = 1                                                                   *
     *              1 -> Enables all low priority interrupts                                        *
     *              0 -> Disables all low priority interrupts                                       *
     *     TMR0IE:  1 -> Enables the TMR0 overflow interrupt                                        *
     *              0 -> Disables the TMR0 overflow interrupt                                       *
     *     INT0IE:  1 -> Enables the INT0 external interrupt                                        *
     *              0 -> Disables the INT0 external interrupt                                       *
     *      IOCIE:  1 -> Enables the IOCx port change interrupt                                     *
     *              0 -> Disables the IOCx port change interrupt                                    *
     *     TMR0IF:  1 -> TMR0 register has overflowed (must be cleared by software)                 *
     *              0 -> TMR0 register did not overflow                                             *
     *     INT0IF:  1 -> The INT0 external interrupt occurred (must be cleared by software)         *
     *              0 -> The INT0 external interrupt did not occur                                  *
     *      IOCIF:  1 -> At least one of the IOC pins changed state (must be cleared by software)   *
     *              0 -> None of the IOC pins have changed state.                                   *
     * ---------------------------------------------------------------------------------------------*
     */
    //INTCON = 0;
#if (INTERRUPT_ENABLE_TIMER0 == ON)
    INTCON |= TMR0_OVERFLOW_INTERRUPT_EN;
#else
    INTCONbits.TMR0IE = 0;
#endif
    
    /* -------------------------------------------------------------------------*
     *  b7      b6      b5      b4      b3      b2      b1      b0              *
     *  TMR0N   T08BIT  T0CS    T0SE    PSA     TOPS<2> TOPS<1> TOPS<0>         *
     *                                                                          *
     *  TMR0N:      1 -> TMR0 on                                                *
     *              0 -> TMR0 off                                               *
     *  T08BIT:     1 -> 8bit counter                                           *
     *              0 -> 16bit counter                                          *
     *  T0CS:       1 -> transition on T0CKI pin                                *
     *              0 -> Internal instruction                                   *
     *  T0SE:       1 -> Increment on falling edge transition on T0CKI pin      *
     *              0 -> Increment on rising edge transition on T0CKI pin       *
     *  PSA:        1 -> Preescaler OFF (equals 1)                              *
     *              0 -> Preescaler ON                                          *
     *  TOPS<2:0>   Preescaler value as follows                                 *
     *              111 -> 1:256                                                *
     *              110 -> 1:128                                                *
     *              101 -> 1:64                                                 *
     *              100 -> 1:32                                                 *
     *              011 -> 1:16                                                 *
     *              010 -> 1:8                                                  *
     *              001 -> 1:4                                                  *
     *              000 -> 1:2                                                  *
     *                                                                          *
     * -------------------------------------------------------------------------*
     */
    T0CON = preescaler;
    
    if (clock_source)
    {
        T0CONbits.T0CS = 1;
    }
        
    else
    {
        T0CONbits.T0CS = 0;
    }
        
}

void TMR0_StartCount(UInt16_T milliseconds)
{
    UInt16_T temp_time;
    
    if (milliseconds > 4000)
    {
        TMR0H = 0;
        TMR0L = 0;
    }
    else{
        /*  MAX of 4000 milliseconds approx
         *  seconds = (4 / _XTAL_FREQ) * (TMR1H:TMR1L) * (Preescalador)
         *  or
         *  TMR0H:TMR0L = seconds / ((4 / _XTAL_FREQ) * Preescalador)
         * 
         */
        temp_time = (UInt16_T)(65536 - (milliseconds / 0.064));
        TMR0H = (UInt8_T)(temp_time / 256);
        TMR0L = (UInt8_T)temp_time;
    }
    
    T0CONbits.TMR0ON = 1;
}

void TMR1_Config(UInt8_T clock_source){
#if (INTERRUPT_ENABLE_TIMER1 == ON)
        PIE1bits.TMR1IE = 1;
#else
        PIE1bits.TMR1IE = 0;
#endif
    
    /* -------------------------------------------------------------------------------------------------*
     *  b7          b6          b5          b4          b3      b2          b1      b0                  *
     *  TMR1CS<1>   TMR1CS<0>   T1CKPS<1>   T1CKPS<0>   SOSCEN  !(T1SYNC)   RD16    TMR1ON              *
     *                                                                                                  *
     *  TMR1CS<1:0>:    TIMER1 clock source select bits                                                 *
     *                  11 -> Reserved                                                                  *
     *                  10 -> Timer1 source is pin or oscillator                                        *
     *                        If SOSCEN = 0: External clock from TxCKI pin (rising edge)                *
     *                        If SOSCEN = 1: Crystal oscillator on SOSCI/SOSCO pins                     *
     *                  01 -> Timer1 clock source is system clock (Fosc)                                *
     *                  00 -> Timer1 clock source is instruction clock (Fosc/4)                         *
     *  T1CKPS<1:0>:    TIMER1 input clock prescale select bits                                         *
     *                  11 -> 1:8                                                                       *
     *                  10 -> 1:4                                                                       *
     *                  01 -> 1:2                                                                       *
     *                  00 -> 1:1                                                                       *
     *  SOSCEN:         1 -> Dedicated secondary oscillator circuit enabled                             *
     *                  0 -> Dedicated secondary oscillator circuit disabled                            *
     *  !(T1SYNC):      TIMER1 external clock input synchronization control bit                         *
     *                      If TMR1CS = 1X:                                                             *
     *                          1 -> Do not synchronize external clock input                            *
     *                          0 -> Synchronize external clock input with Fosc                         *
     *                      If TMR1CS = 0x:                                                             *
     *                          This bit is ignored. Timer1 uses the internal clock when TMR1CS = 0X    *
     *  RD16:           1 -> Enables register read/write of Timer1 in one 16-bit operation              *
     *                  0 -> Enables register read/write of Timer1 in two 8-bit operation               *
     *  TMR1ON:         1 -> Enables Timer1                                                             *
     *                  0 -> Stops Timer1; clears Timer1 gate flip-flop                                 *
     * -------------------------------------------------------------------------------------------------*
     */
    T1CON = 0b00110010;
    
    if (clock_source){
        T1CONbits.TMR1CS1 = 1;
        T1CONbits.TMR1CS0 = 0;
    }
    else{
        T1CONbits.TMR1CS1 = 0;
        T1CONbits.TMR1CS0 = 0;
    }
}

void TMR1_StartCount(UInt16_T milliseconds){
    UInt16_T temp_time;
    
    if (milliseconds > 130){
        TMR1H = 0;
        TMR1L = 0;
    }
    else{
        /*  MAX of 131.072 milliseconds approx
         *  seconds = (4 / _XTAL_FREQ) * (TMR1H:TMR1L) * (Preescalador)
         *  or
         *  TMR0H:TMR0L = seconds / ((4 / _XTAL_FREQ) * Preescalador)
         * 
         */
        temp_time = (UInt16_T)(65536 - (milliseconds / 0.002));
        TMR1H = (UInt8_T)(temp_time / 256);
        TMR1L = (UInt8_T)temp_time;
    }
    
    T1CONbits.TMR1ON = 1;
}

void TMR3_Config(UInt8_T clock_source){
#if (INTERRUPT_ENABLE_TIMER3 == ON)
        PIE2bits.TMR3IE = 1;
#else
        PIE2bits.TMR3IE = 0;
#endif
    
    /* -------------------------------------------------------------------------------------------------*
     *  b7          b6          b5          b4          b3      b2          b1      b0                  *
     *  TMR3CS<1>   TMR3CS<0>   T3CKPS<1>   T3CKPS<0>   SOSCEN  !(T3SYNC)   RD16    TMR3ON              *
     *                                                                                                  *
     *  TMR3CS<1:0>:    TIMER1 clock source select bits                                                 *
     *                  11 -> Reserved                                                                  *
     *                  10 -> Timer1 source is pin or oscillator                                        *
     *                        If SOSCEN = 0: External clock from TxCKI pin (rising edge)                *
     *                        If SOSCEN = 1: Crystal oscillator on SOSCI/SOSCO pins                     *
     *                  01 -> Timer1 clock source is system clock (Fosc)                                *
     *                  00 -> Timer1 clock source is instruction clock (Fosc/4)                         *
     *  T3CKPS<1:0>:    TIMER1 input clock prescale select bits                                         *
     *                  11 -> 1:8                                                                       *
     *                  10 -> 1:4                                                                       *
     *                  01 -> 1:2                                                                       *
     *                  00 -> 1:1                                                                       *
     *  SOSCEN:         1 -> Dedicated secondary oscillator circuit enabled                             *
     *                  0 -> Dedicated secondary oscillator circuit disabled                            *
     *  !(T3SYNC):      TIMER1 external clock input synchronization control bit                         *
     *                      If TMR1CS = 1X:                                                             *
     *                          1 -> Do not synchronize external clock input                            *
     *                          0 -> Synchronize external clock input with Fosc                         *
     *                      If TMR1CS = 0x:                                                             *
     *                          This bit is ignored. Timer1 uses the internal clock when TMR1CS = 0X    *
     *  RD16:           1 -> Enables register read/write of Timer1 in one 16-bit operation              *
     *                  0 -> Enables register read/write of Timer1 in two 8-bit operation               *
     *  TMR3ON:         1 -> Enables Timer1                                                             *
     *                  0 -> Stops Timer1; clears Timer1 gate flip-flop                                 *
     * -------------------------------------------------------------------------------------------------*
     */
    T3CON = 0b00110010;
    
    if (clock_source){
        T3CONbits.TMR3CS1 = 1;
        T3CONbits.TMR3CS0 = 0;
    }
    else{
        T3CONbits.TMR3CS1 = 0;
        T3CONbits.TMR3CS0 = 0;
    }
}

void TMR3_StartCount(UInt16_T milliseconds){
    UInt16_T temp_time;
    
    if (milliseconds > 130){
        TMR3H = 0;
        TMR3L = 0;
    }
    else{
        /*  MAX of 131.072 milliseconds approx
         *  seconds = (4 / _XTAL_FREQ) * (TMR1H:TMR1L) * (Preescalador)
         *  or
         *  TMR0H:TMR0L = seconds / ((4 / _XTAL_FREQ) * Preescalador)
         * 
         */
        temp_time = (UInt16_T)(65536 - (milliseconds / 0.002));
        TMR3H = (UInt8_T)(temp_time / 256);
        TMR3L = (UInt8_T)temp_time;
    }
    
    T3CONbits.TMR3ON = 1;
}
