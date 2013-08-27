; PIC18F6310 based LED hex display
; Version 0.1 Copyright (c) 2013 Jonathan Chapman
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
        movlw   B'11100010'
        movwf   OSCCON
        movlw   B'11100000'
        movwf   INTCON
        clrf    TRISB

        ; Fill the display buffer with test data
        setf    TRISC

        movlw   0x0F
        call    HEX
        movwf   chars + d'2'
        movlw   0x0F
        call    HEX
        movwf   chars + d'3'
        movlw   0x0E
        call    HEX
        movwf   chars + d'4'
        movlw   0x0E
        call    HEX
        movwf   chars + d'5'

        clrf    TRISE
        clrf    TRISA
        clrf    TRISG
        movlw   d'1'
        movwf   Current
        movlw   B'10001000'
        movwf   T0CON
        movlw   B'11111000'
        movwf   TMR0H
        clrf    TMR0L
NOPPER: nop
        movlw   0x0F
        andwf   PORTC, W
        call    HEX
        movwf   chars + d'0'

        swapf   PORTC, W
        andlw   0x0F
        call    HEX
        movwf   chars + d'1'
        goto    NOPPER

ISR:    movwf   W_temp
        movf    STATUS, W
        movwf   S_temp
        clrf    FSR0H
        movlw   chars + d'0'
        addwf   Current, W
        movwf   FSR0L
        call    BLANK
        movf    INDF0, W
        movwf   PORTB
        movf    Current, W
        call    DIGIT
        movf    Current, W
        xorlw   DIGITS
        btfsc   STATUS, Z
        goto    ISR1
        incf    Current, f
        goto    ISR2
ISR1:   clrf    Current
ISR2:   movlw   B'11111000'
        movwf   TMR0H
        clrf    TMR0L
        movf    W_temp, W
        movf    S_temp, W
        movwf   STATUS
        bcf     INTCON, 2
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
        bsf     PORTE, 3
        return
        bsf     PORTE, 4
        return
        bsf     PORTE, 5
        return
        bsf     PORTE, 6
        return
        bsf     PORTA, 6
        return
        bsf     PORTA, 7
        return
        bsf     PORTG, 3
        return
        bsf     PORTG, 4
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
        db  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
        db  0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71

    end