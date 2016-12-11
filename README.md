# PIC18

Some PIC18 projects using the PIC18F45K50 and MPLAB for compiling all source codes.

Software used:
- MPLAB X IDE v2.20 (any newer version would work. To download it go to http://www.microchip.com/mplab/mplab-x-ide)
- XC8 compiler for compiling C code (download it from here: http://www.microchip.com/mplab/compilers)

Hardware used:
- PIC8F45K50

Creating a MPLAB project:
- Go to File/New Project/Microchip Embedded/Standalone Project/Next >
- Family: Advanced 8-bit MCUs (PIC18)/ Device: PIC18F45K50/Next >
- Select Simulator as Hardware tools, then click Next
- Select mpsasm (vx.xx) as the compiler toolchain (as most of the source codes here are in assembly), then click next.
- Give a name to the project and select a folder to save it, then click on finish.
- Go to "Source files" on the project window and then right click. Select New/Empty File.
- Name the file as you wish with .asm extension. Example: "helloworld.asm"
