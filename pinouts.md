Hex Display rev 0 Pinouts
-------------------------

### JP1 -- LED display module

JP1 pinouts correspond with 8/9 digit magnified 7-segment display modules I have on hand. Cathode 0 is not driven since the first digit is unpopulated on 8 digit displays. Segments map in order to Port B on the PIC.

```
1     NC
2     common cathode 0 (not driven)
3     segment C
4     common cathode 1
5     decimal point
6     common cathode 2
7     segment A
8     common cathode 3
9     segment E
10    common cathode 4
11    segment D
12    common cathode 5
13    segment G
14    common cathode 6
15    segment B
16    common cathode 7
17    segment F
18    common cathode 8
```

### PORTB -- Segment Control Port

```
RB0   segment C
RB1   decimal point
RB2   segment A
RB3   segment E
RB4   segment D
RB5   segment G
RB6   segment B
RB7   segment F
```

### Cathode Control Pins

Cathode control pins drive common cathodes through a ULN2803 octal NPN Darlington array.

```
RA6   common cathode 1
RA7   common cathode 2
RG4   common cathode 3
RG3   common cathode 4
RE6   common cathode 5
RE5   common cathode 6
RE4   common cathode 7
RE3   common cathode 8
```

### JP2 -- Application Connector

The application connector provides PIC ports C, D, and F as well as RE0, RE1, and RE2. Power and ground pins are provided as well.

```
Vcc      1   o o    2     Vcc
RD0      3   o o    4     RD1
RD2      5   o o    6     RD3
RD4      7   o o    8     RD5
RD6      9   o o   10     RD7
RE2     11   o o   12     NC
RE0     13   o o   14     RE1
RF0     15   o o   16     RF1
RF2     17   o o   18     RF3
RF4     19   o o   20     RF5
RF6     21   o o   22     RF7
NC      23   o o   24     NC
NC      25   o o   26     NC
RC0     27   o o   28     RC1
RC2     29   o o   30     RC3
RC4     31   o o   32     RC5
RC6     33   o o   34     RC7
GND     35   o o   36     GND
```
