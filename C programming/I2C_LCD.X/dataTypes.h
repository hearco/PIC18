
// This is a guard condition so that contents of this file are not included
// more than once.  
#ifndef DATATYPES_HEADER
#define	DATATYPES_HEADER

#ifdef PIC18F45K50
typedef unsigned char           UInt8_T;
typedef unsigned short int      UInt16_T;
typedef unsigned long int       UInt32_T;
typedef unsigned long long int  UInt64_T;

typedef signed char             SInt8_T;
typedef signed short int        SInt16_T;
typedef signed long int         SInt32_T;
typedef signed long long int    SInt64_T;
#endif // PIC18F45K50

#endif	/* DATATYPES_HEADER */

