; PIC18F6310 based LED hex display
; Version 0.1.1 Copyright (c) 2014 Jonathan Chapman
; http://www.glitchwrks.com
;
; See LICENSE included in the project root for licensing information.

; PIC18F6310 Configuration Bit Settings
    #include <p18f6310.inc>

    CONFIG  WDT = OFF           ; Watchdog Timer disabled
    CONFIG  CP = OFF            ; Code Protect disabled
    CONFIG  MCLRE = ON          ; Master Clear Enable
    CONFIG  OSC = INTIO67       ; Internal oscillator block, port function on RA6 and RA7
    CONFIG  IESO = OFF          ; Oscillator Switchover mode disabled

    ORG 0
    goto Start

    ORG 8
    goto ISR

; Variable declarations
    cblock  0x20
        Current                 ; Current active digit
        chars:8                 ; Display buffer
        W_temp                  ; Temporary storage for ISR
        S_temp
    endc

DIGITS  EQU     d'8'

Start:
        ; Set up the internal oscillator
        movlw   B'11100010'
        movwf   OSCCON
        movlw   B'11100000'
        movwf   INTCON

        ; Set the ports required for display output to outputs
        clrf    TRISB
        clrf    TRISA
        clrf    TRISE
        clrf    TRISG

        ; Set the initial current digit to 0
        clrf    Current

        ; Fill the display buffer with test data
        movlw   0x0D
        call    HEX
        movwf   chars + d'0'
        movlw   0x0E
        call    HEX
        movwf   chars + d'1'
        movlw   0x0A
        call    HEX
        movwf   chars + d'2'
        movlw   0x0D
        call    HEX
        movwf   chars + d'3'
        movlw   0x0B
        call    HEX
        movwf   chars + d'4'
        movlw   0x0E
        call    HEX
        movwf   chars + d'5'
        movlw   0x0E
        call    HEX
        movwf   chars + d'6'
        movlw   0x0F
        call    HEX
        movwf   chars + d'7'

        ; Preload TIMER0 with the multiplex frequency and go
        movlw   B'10001000'
        movwf   T0CON
        movlw   B'11111100'
        movwf   TMR0H
        clrf    TMR0L
NOPPER: nop
        goto    NOPPER              ; Spin in a loop while the ISR works

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ISR -- Interrupt Service Routine
;
; This routine handles multiplexing under the control of TIMER0. Data is moved
; from the current element of the display buffer onto PORTB after the previous
; digit is switched off. The current digit is then turned on and TIMER0 is
; reset.
;
; pre:  Digit blanking masks are specified in this subroutine
; post: All digits are turned off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ISR:    movwf   W_temp              ; Save W, S
        movf    STATUS, W
        movwf   S_temp
        clrf    FSR0H
        movlw   chars + d'0'        ; Get the position of the current character
        addwf   Current, W          ; to be displayed
        movwf   FSR0L
        call    BLANK
        movf    INDF0, W
        movwf   PORTB
        movf    Current, W
        call    DIGIT
        movf    Current, W
        xorlw   DIGITS              ; Have we reached the last display char?
        btfsc   STATUS, Z
        goto    ISR1                ; Yes, reset the current character
        incf    Current, f          ; No, increment the current character
        goto    ISR2
ISR1:   clrf    Current
ISR2:   movlw   B'11111100'         ; Reset TIMER0
        movwf   TMR0H
        clrf    TMR0L
        movf    W_temp, W           ; Restore W, S
        movf    S_temp, W
        movwf   STATUS
        bcf     INTCON, 2           ; Turn interrupts on and return
        retfie

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BLANK -- Blank the display
;
; pre:  Digit blanking masks are specified in this subroutine
; post: All digits are turned off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BLANK:  movlw   B'10000111'
        andwf   PORTE, f
        movlw   B'00111111'
        andwf   PORTA, f
        movlw   B'11100111'
        andwf   PORTG, f
        return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIGIT -- Turn on the control line for a digit
;
; pre:  W register contains the number of the digit to turn on
;       Digit control bits are defined in this subroutine
;       All other digits are currently turned off
; post: The bit associated with the digit specified by W is set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIGIT:  mullw   d'4'
        movf    PRODL, W
        addwf   PCL, f
        bsf     PORTA, 6
        return
        bsf     PORTA, 7
        return
        bsf     PORTG, 4
        return
        bsf     PORTG, 3
        return
        bsf     PORTE, 6
        return
        bsf     PORTE, 5
        return
        bsf     PORTE, 4
        return
        bsf     PORTE, 3
        return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HEX -- Convert a Nybble to its 7-segment bit pattern
;
; pre:  W register contains masked nybble to convert
;       Bitmap table exists at 0x0400
; post: W contains 7-segment bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEX:    movwf   TBLPTRL
        movlw   0x00
        movwf   TBLPTRU
        movlw   0x04
        movwf   TBLPTRH
        tblrd*
        movf    TABLAT, W
        return

        org 0x0400
        db  B'11011101', B'01000001', B'01111100', B'01110101'
        db  B'11100001', B'10110101', B'10111101', B'01000101'
        db  B'11111101', B'11110101', B'11101101', B'10111001'
        db  B'10011100', B'01111001', B'10111100', B'10101100'

    end