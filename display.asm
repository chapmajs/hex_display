
; PIC18F6310 Configuration Bit Settings

    #include <p18f6310.inc>

    CONFIG WDT = OFF            ; Watchdog Timer disabled
    CONFIG  CP = OFF            ; Code Protect disabled
    CONFIG  MCLRE = ON          ; Master Clear Enable
    CONFIG  OSC = INTIO67       ; Internal oscillator block, port function on RA6 and RA7
    CONFIG  IESO = OFF          ; Oscillator Switchover mode disabled

    ORG 0
    GOTO Start

    ORG 8
    GOTO ISR

    cblock  0x20
        Current
        chars:8
        W_temp
        S_temp
        count
    endc

DIGITS  EQU     d'4'

Start:
        movlw B'11100010'
        movwf OSCCON
        movlw B'11100000'
        movwf INTCON
        CLRF TRISB
        ; Start table read
        movlw   0x0B
        call    HEX
        movwf   chars + d'0'
        movlw   0x0E
        call    HEX
        movwf   chars + d'1'
        movlw   0x0E
        call    HEX
        movwf   chars + d'2'
        movlw   0x0F
        call    HEX
        movwf   chars + d'3'
        nop
        ; End table read
        CLRF TRISE
        movlw   d'1'
        movwf   Current
        nop
        movlw B'10001000'
        movwf T0CON
        movlw B'11111000'
        movwf TMR0H
        clrf  TMR0L
NOPPER: nop
        goto  NOPPER

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
        goto    Inc
        incf    Current, f
        goto    ISR1
Inc     clrf    Current

ISR1:   movlw B'11111000'
        movwf TMR0H
        clrf  TMR0L
        movf    W_temp, W
        movf    S_temp, W
        movwf   STATUS
        bcf  INTCON, 2
        retfie

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BLANK -- Blank the display
;
; pre:  Digit blanking masks are specified in this subroutine
; post: All digits are turned off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BLANK:  movlw   B'10000111'
        andwf   PORTE, f
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HEX -- Convert a Nybble to its 7-segment bit pattern
;
; pre:  W register contains masked nybble to convert
;       Bitmap table exists at 0x0400
; post: W contains 7-segment bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEX:    movwf    TBLPTRL
        movlw   0x00
        movwf   TBLPTRU
        movlw   0x04
        movwf   TBLPTRH
        TBLRD*
        movf    TABLAT, W
        return

        org 0x0400
        db  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
        db  0x7f, 0x6f, 0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71

    end