               title 'IntLib v1.00 - Written by Tim Meekins'
***************************************************************************
*                                                                         *
* IntLib v1.00                                                            *
* Written by Tim Meekins                                                  *
* Copyright (C) 1989 by Tim Meekins                                       *
*                                                                         *
* This library contains numerous routines for dealing with integer        *
* numbers.                                                                *
*                                                                         *
* Routines contained herein:                                              *
*    IL_SDiv   - Signed division                                          *
*    IL_SMult  - Signed multiplication                                    *
*    IL_UDiv   - Unsigned division                                        *
*    IL_UMult  - Unsigned multiplication                                  *
*                                                                         *
***************************************************************************
*                                                                         *
* ========= REVISION HISTORY =====================================        *
*                                                                         *
* V1.00                                                                   *
*   2/22/89  Began writing original library. Wrote signed and unsigned    *
*            mulitplication routines.                                     *
*   2/23/89  Wrote signed and unsigned division.                          *
*   2/25/89  UMult and SMult always returned 0, fixed bug. Optimized      *
*            signed division routine.                                     *
*   3/16/89  SDiv now properly rounds.                                    *
*                                                                         *
***************************************************************************

               copy  inlib.equ

***************************************************************************
*
* Dummy segment.
*
***************************************************************************

InLib          DATA
               dc    c'InLib v1.00 written by Tim Meekins Copyright 1989'
               END

***************************************************************************
*
* Multiply two unsigned integers.
*
*  Entry Points:
*    IL_UMult  - Unsigned multiplication
*
*  Inputs:
*    Arg1      - Multiplier
*    Arg2      - Multiplicand
*
*  Outputs:
*    Result,A  - Product
*    x         - Unknown
*    Arg1,Arg2 - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/22/89 - Original verision written.
*     2/25/89 - Always returned 0, fixed bug.
*
***************************************************************************
*
IL_UMult       START

               longa on
               longi on

               stz   Result
               lda   #0
Loop           ldx   Arg1
               beq   DMult
               lsr   Arg1
               bcc   NoMult
               clc
               adc   Arg2
NoMult         asl   Arg2
               jmp   Loop

DMult          sta   Result

               rtl

               END

***************************************************************************
*
* Multiply two signed integers.
*
*  Entry Points:
*    IL_SMult  - Signed multiplication
*
*  Inputs:
*    Arg1      - Multiplier
*    Arg2      - Multiplicand
*
*  Outputs:
*    Arg1,Arg2 - Unknown
*    Result,A  - Product
*    X,Y       - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/22/89 - Original verision written.
*     2/25/89 - Always returned 0, fixed bug. Added special case so that
*               if the result is 0, it won't be negated.
*
***************************************************************************
*
IL_SMult       START

               longa on
               longi on

               ldx   #0
               lda   Arg1
               bpl   Sign2
               eor   #$FFFF
               inc   a
               sta   Arg1
               inx
Sign2          lda   Arg2
               bpl   DoMult
               eor   #$FFFF
               inc   a
               sta   Arg2
               dex

DoMult         stz   Result
               lda   #0

Loop           ldy   Arg1
               beq   DMult
               lsr   Arg1
               bcc   NoMult
               clc
               adc   Arg2
NoMult         asl   Arg2
               jmp   Loop

DMult          cmp   #0
               beq   Done
               cpx   #0
               beq   Done
               eor   #$FFFF
               inc   a

Done           sta   Result
               rtl

               END

***************************************************************************
*
* Divide two unsigned integers.
*
*  Entry Points:
*    IL_UDiv   - Unsigned division
*
*  Inputs:
*    Arg1      - Dividend
*    Arg2      - Divisor
*
*  Outputs:
*    Arg1,A    - Remainder
*    Result    - Quotient
*    Y,Arg2    - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/23/89 - Original verision written.
*
***************************************************************************
*
IL_UDiv        START

               sep   #$10
               longa on
               longi off

               stz   Result
               ldy   #1
               lda   Arg2
Div1           asl   a
               bcs   Div2
               iny
               cpy   #17
               bne   Div1
Div2           ror   a
               sta   Arg2
               lda   Arg1
Div4           sec
               sbc   Arg2
               bcs   Div3
               lda   Arg1
Div3           rol   Result
               lsr   Arg2
               dey
               bne   Div4
               sta   Arg1

               rep   #$10
               rtl

               END

***************************************************************************
*
* Divide two signed integers.
*
*  Entry Points:
*    IL_SDiv   - Signed division
*
*  Inputs:
*    Arg1      - Dividend
*    Arg2      - Divisor
*
*  Outputs:
*    Result,A   - Quotient
*    X,Y        - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/23/89 - Original verision written.
*     2/25/89 - Optimized code.
*     3/16/89 - Rewrote algorithm, now rounds properly. Based on Integer
*               toolset code, but it is actually more accurate than Apple's.
*
***************************************************************************
*
IL_SDiv        START

               longa on
               longi on

               ldy   #0
               lda   Arg1
               bpl   Sign2
               eor   #$FFFF
               inc   a
               iny
Sign2          tax
               lda   Arg2
               bpl   DoDiv
               eor   #$FFFF
               inc   a
               sta   Arg2
               dey

DoDiv          sty   Sign
               stx   Result
               ldy   #$11
               lda   #0
               sec
div1           rol   Result
               rol   a
               tax
               sec
               sbc   Arg2
               bcs   div2
               txa
div2           dey
               bne   div1
               bcc   rounded
               inc   Result

rounded        lda   Result
               ldx   Sign
               beq   Done
               eor   #$FFFF
               inc   a
               sta   Result

Done           rtl

Sign           ds    2

               END
