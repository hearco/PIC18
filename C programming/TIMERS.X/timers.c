
#include "timers.h"

/**** Private variables ****/
static UInt8_T TMR0_PreescalerValue;
static UInt8_T TMR1_PreescalerValue;
static UInt8_T TMR3_PreescalerValue;

/**** Private functions ****/


/**** Public functions ****/
/***************************************************************************************
 * 
 *    Function: TMR0_Config
 * 
 * Description: This is a one time call function and Configures the Timer 0 module.
 *              Use this function before using TMR0_StartCount.
 * 
 *  Parameters: TMR0_CLOCK_SOURCE_VALUES_T clock_source
 *              TMR0_PREESCALER_VALUES_T   preescaler
 *              TMR0_RW_MODE_T             ReadWrite_Mode
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
void TMR0_Config(TMR0_CLOCK_SOURCE_VALUES_T clock_source, TMR0_PREESCALER_VALUES_T preescaler, TMR0_RW_MODE_T ReadWrite_Mode)
{
#if (INTERRUPT_ENABLE_TIMER0 == ON)
    INTCON |= TMR0_OVERFLOW_INTERRUPT_EN;
#else
    INTCONbits.TMR0IE = 0;
#endif
    
    // Keep track of preescaler value for use in other functions
    TMR0_PreescalerValue = (UInt8_T)preescaler;
    
    /* ******************************* INTCON register **********************************************
     * 
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
     * 
     * **********************************************************************************************/
    
    /* *********************** T0CON register ***********************************
     *                                                                          *
     *  b7      b6      b5      b4      b3      b2      b1      b0              *
     *  TMR0N   T08BIT  T0CS    T0SE    PSA     TOPS<2> TOPS<1> TOPS<0>         *
     *                                                                          *
     *     TMR0N:   1 -> TMR0 on                                                *
     *              0 -> TMR0 off                                               *
     *    T08BIT:   1 -> 8bit counter                                           *
     *              0 -> 16bit counter                                          *
     *      T0CS:   1 -> transition on T0CKI pin                                *
     *              0 -> Internal instruction                                   *
     *      T0SE:   1 -> Increment on falling edge transition on T0CKI pin      *
     *              0 -> Increment on rising edge transition on T0CKI pin       *
     *       PSA:   1 -> Preescaler OFF (equals 1)                              *
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
     ****************************************************************************/
    T0CON = (ReadWrite_Mode << 6) | (clock_source << 5) | preescaler;
}

/***************************************************************************************
 * 
 *    Function: TMR0_StartCount
 * 
 * Description: This function starts Timer 0 with the specified time in ms.
 * 
 *  Parameters: UInt16_T milliseconds
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
void TMR0_StartCount(UInt16_T milliseconds)
{
    UInt16_T temp_time;
    
    if (milliseconds > 4193)
    {
        TMR0H = 0;
        TMR0L = 0;
    }
    else
    {
        /*  MAX of 4194 milliseconds approx
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

/***************************************************************************************
 * 
 *    Function: TMR1_Config
 * 
 * Description: This is a one time call function and Configures the Timer 1 module.
 *              Use this function before using TMR1_StartCount.
 * 
 *  Parameters: TMR1_CLOCK_SOURCE_VALUES_T clock_source
 *              TMR1_PREESCALER_VALUES_T   preescaler
 *              TMR1_RW_MODE_T             ReadWrite_Mode
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
void TMR1_Config(TMR1_CLOCK_SOURCE_VALUES_T clock_source, TMR1_PREESCALER_VALUES_T preescaler, TMR1_RW_MODE_T ReadWrite_Mode)
{
#if (INTERRUPT_ENABLE_TIMER1 == ON)
        PIE1bits.TMR1IE = 1;
#else
        PIE1bits.TMR1IE = 0;
#endif
    
    // Keep track of preescaler value for use in other functions
    TMR1_PreescalerValue = (UInt8_T)preescaler;
    
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
    * -------------------------------------------------------------------------------------------------*/
    T1CON = (clock_source << 6) | (preescaler << 4) | (ReadWrite_Mode << 1);
}

/***************************************************************************************
 * 
 *    Function: TMR1_StartCount
 * 
 * Description: This function starts Timer 1 with the specified time in ms.
 * 
 *  Parameters: UInt16_T milliseconds
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
void TMR1_StartCount(UInt16_T milliseconds)
{
    UInt16_T temp_time;
    
    if (milliseconds > 130)
    {
        TMR1H = 0;
        TMR1L = 0;
    }
    else
    {
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

/***************************************************************************************
 * 
 *    Function: TMR3_Config
 * 
 * Description: This is a one time call function and Configures the Timer 3 module.
 *              Use this function before using TMR3_StartCount.
 * 
 *  Parameters: TMR3_CLOCK_SOURCE_VALUES_T clock_source
 *              TMR3_PREESCALER_VALUES_T   preescaler
 *              TMR3_RW_MODE_T             ReadWrite_Mode
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
void TMR3_Config(TMR3_CLOCK_SOURCE_VALUES_T clock_source, TMR3_PREESCALER_VALUES_T preescaler, TMR3_RW_MODE_T ReadWrite_Mode)
{
#if (INTERRUPT_ENABLE_TIMER3 == ON)
        PIE2bits.TMR3IE = 1;
#else
        PIE2bits.TMR3IE = 0;
#endif
    
    // Keep track of preescaler value for use in other functions
    TMR3_PreescalerValue = (UInt8_T)preescaler;
    
    /* -------------------------------------------------------------------------------------------------*
     *  b7          b6          b5          b4          b3      b2          b1      b0                  *
     *  TMR3CS<1>   TMR3CS<0>   T3CKPS<1>   T3CKPS<0>   SOSCEN  !(T3SYNC)   RD16    TMR3ON              *
     *                                                                                                  *
     *  TMR3CS<1:0>:    TIMER1 clock source select bits                                                 *
     *                  11 -> Reserved                                                                  *
     *                  10 -> Timer3 source is pin or oscillator                                        *
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
    //T3CON = 0b00110010;
    T3CON = (clock_source << 6) | (preescaler << 4) | (ReadWrite_Mode << 1);
}

/***************************************************************************************
 * 
 *    Function: TMR3_StartCount
 * 
 * Description: This function starts Timer 3 with the specified time in ms.
 * 
 *  Parameters: UInt16_T milliseconds
 * 
 *     Returns: N/A
 * 
 ***************************************************************************************/
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
