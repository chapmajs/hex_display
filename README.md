PIC Based Mutiplexed 7-segment LED Display
==========================================

A project to drive multiplexed 7-segment LED displays as hex displays using a Microchip PIC18F6310 with a minimum of external components. This is a work in progress!

### Current Status

Rev 0 PC board has been tested, sample firmware in this repository displays 'deadbeef'. Minor tweaks to the PC board layout are required for 0.1" perfboard compatibility. 24-bit port input has not yet been tested.

### Why?

"Intelligent" single-nybble hexadecimal displays like the TIL311 are available, as well as 7-segment hex decoders; however, these devices are no longer in production and they're expensive, when you can find them. The 7-segment hex decoders that are currently available handle single displays only and don't work with multi-character multiplexed displays.

### How?

This display project implements a multi-character bitmapped display using an interrupt-driven subroutine to handle multiplexing. A display buffer is used to simplify loading data for display. Character selection was delegated to a subroutine that enables the appropriate cathode driver pin based on an offset. This allows the size of the display to be changed with minimal firmware modification.

A PIC microcontroller with plenty of I/O was chosen to allow input of 24 bits of binary data in parallel (16 bit address + 8 bit data, a common arrangement with old 8-bit processors like the Intel 8080/8085, Zilog Z80, or MOS 6502). Using this device as a debugging tool was the primary goal; however, it was designed in such a way that the PIC's onboard devices can also act as data sources for the display. It's possible to display data from I2C, SPI, RS-232, parallel port, or ADC sources. Additionally, one could drive dot matrix displays with the same firmware.

An in-memory lookup table provides translation from single hex nybbles to appropriate bitmap patterns for 7-segment displays. A routine utilizing this table can be called from firmware to produce hex digits if bitmap characters are not desired.

### Who?

[The Glitch Works](http://www.glitchwrks.com/)

There's a thread on the [BinRev Forums](http://www.binrev.com/forums/index.php/topic/46160-hex-display-project/) for discussion

### Files

* display.asm: PIC18F6310 firmware for driving mutiplexed common cathode 7-segment displays
* schematic.sch: Eagle CAD schematic
* schematic.brd: Eagle CAD board layout
