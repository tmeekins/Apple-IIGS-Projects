               title 'FixLib v1.00 - Written by Tim Meekins'
***************************************************************************
*                                                                         *
* FixLib v1.00                                                            *
* Written by Tim Meekins                                                  *
* Copyright (C) 1989 by Tim Meekins                                       *
*                                                                         *
* This library contains numerous routines for dealing with fixed-point    *
* numbers.                                                                *
*                                                                         *
* Routines contained herein:                                              *
*    FI_Cos    - Find the cosine of an angle.                             *
*    FI_Fi2In  - Convert fixed to integer                                 *
*    FI_SDiv   - Signed division                                          *
*    FI_Sin    - Find the sine of an angle.                               *
*    FI_SMult  - Signed multiplication                                    *
*    FI_UDiv   - Unsigned division                                        *
*    FI_UMult  - Unsigned multiplication                                  *
*                                                                         *
***************************************************************************
*                                                                         *
* ========= REVISION HISTORY =====================================        *
*                                                                         *
* V1.00                                                                   *
*   3/12/89  Began writing original library. This first version is a      *
*            quick hack, it simply calls the integer library toolset.     *
*            Custom routines will be written soon.                        *
*   3/15/89  Wrote Fi2In conversion routine.                              *
*   5/04/89  Wrote a program that generates a table of sine values which  *
*            can be assembled and included with this library as a look up *
*            table. All sine values in the table are fixed-point. Wrote   *
*            sin and cos.                                                 *
*                                                                         *
***************************************************************************

               copy  filib.equ
               copy  inlib.equ
               mcopy filib.mac

***************************************************************************
*
* Dummy segment.
*
***************************************************************************

FiLib          DATA
               dc    c'FiLib v1.00 written by Tim Meekins Copyright 1989'
               END

***************************************************************************
*
* Multiply two unsigned fixed-point integers.
*
*  Entry Points:
*    FI_UMult  - Unsigned multiplication
*
*  Inputs:
*    fArg1     - Multiplier
*    fArg2     - Multiplicand
*
*  Outputs:
*    fResult   - Product
*    A,X,Y     - unknown
*
*  External Procedures:
*    F_SMult   - signed multiplication
*
*  Revision History:
*     3/12/89 - Original verision written. Calls SMult and does a signed
*               multiplication. To be fixed in the future.
*
***************************************************************************
*
FI_UMult       START

               longa on
               longi on

               jml   FI_SMult

               END

***************************************************************************
*
* Multiply two signed fixed-point integers.
*
*  Entry Points:
*    FI_SMult  - Signed multiplication
*
*  Inputs:
*    fArg1     - Multiplier
*    fArg2     - Multiplicand
*
*  Outputs:
*    fResult   - Product
*    A,X,Y     - unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/12/89 - Original verision written. For now it simply calls the
*               integer toolset equivalent.
*
***************************************************************************
*
FI_SMult       START

               longa on
               longi on

               pha
               pha
               ph4   fArg1
               ph4   fArg2
               _FixMul
               pl4   fResult

               rtl

               END

***************************************************************************
*
* Divide two unsigned fixed-point integers.
*
*  Entry Points:
*    FI_UDiv   - Unsigned division
*
*  Inputs:
*    fArg1     - Dividend
*    fArg2     - Divisor
*
*  Outputs:
*    fResult   - Quotient
*    A,X,Y     - unknown
*
*  External Procedures:
*    FI_SDiv
*
*  Revision History:
*     3/12/89 - Original verision written. For now it simply calls the signed
*               division routine.
*
***************************************************************************
*
FI_UDiv        START

               longa on
               longi on

               jml   FI_SDiv

               END

***************************************************************************
*
* Divide two signed fixed-point integers.
*
*  Entry Points:
*    FI_SDiv   - Signed division
*
*  Inputs:
*    fArg1     - Dividend
*    fArg2     - Divisor
*
*  Outputs:
*    fResult    - Quotient
*    A,X,Y      - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/12/89 - Original verision written. For now it simply calls the
*               integer toolbox equivalent.
*
***************************************************************************
*
FI_SDiv        START

               longa on
               longi on

               pha
               pha
               ph4   fArg1
               ph4   fArg2
               _FixDiv
               pl4   fResult

               rtl

               END

***************************************************************************
*
* Convert a fixed-point integer to an integer. Performs rounding if
* necessary.
*
*  Entry Points:
*    FI_Fi2In  - Convert fixed to integer
*
*  Inputs:
*    fArg1     - fixed-point integer
*
*  Outputs:
*    Result,A  - integer result of conversion
*    X         - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/15/89 - Original verision written.
*
***************************************************************************
*
FI_Fi2In       START

               longa on
               longi on

               lda   fArg1+2
               ldx   fArg1
               bpl   done
               inc   a
               cmp   #$8000
               bne   done
               dec   a
done           sta   Result

               rtl

               END

***************************************************************************
*
*  Calculate the sine of an angle given in degrees.
*
*  Entry Points:
*    FI_Sin    - Find the sine of an angle (degrees).
*
*  Inputs:
*    Arg1      - Angle in integer degrees.
*
*  Outputs:
*    fResult   - fixed-point result of sine
*    a,x       - unknown.
*
*  External Procedures:
*    none
*
*  Revision History:
*     5/04/89 - Original verision written.
*
***************************************************************************
*
FI_Sin         START

               using FI_Data

               longi on
               longa on

               lda   Arg1
s1             bpl   s2
               clc
               adc   #360
               jmp   s1
s2             cmp   #360
               bcc   s3
               sec
               sbc   #360
               jmp   s2
s3             asl   a
               asl   a
               tax
               lda   FI_SineTbl,x
               sta   fResult
               inx
               inx
               lda   FI_SineTbl,x
               sta   fResult+2

               rtl

               END

***************************************************************************
*
*  Calculate the cosine of an angle given in degrees.
*
*  Entry Points:
*    FI_Cos    - Find the cosine of an angle (degrees).
*
*  Inputs:
*    Arg1      - Angle in integer degrees.
*
*  Outputs:
*    fResult   - fixed-point result of cosine
*    a,x       - unknown.
*
*  External Procedures:
*    none
*
*  Revision History:
*     5/04/89 - Original verision written.
*
***************************************************************************
*
FI_Cos         START

               using FI_Data

               longa on
               longi on

               lda   Arg1
               clc
               adc   #90
s1             bpl   s2
               clc
               adc   #360
               jmp   s1
s2             cmp   #360
               bcc   s3
               sec
               sbc   #360
               jmp   s2
s3             asl   a
               asl   a
               tax
               lda   FI_SineTbl,x
               sta   fResult
               inx
               inx
               lda   FI_SineTbl,x
               sta   fResult+2

               rtl

               END

***************************************************************************
*
*  Data used by FixLib.
*
*  Entry Points:
*    FI_SineTbl - Table of sine values in fixed-point.
*
*  Revision History:
*     5/04/89 - Original verision written.
*
***************************************************************************
*
FI_DATA        DATA

FI_SineTbl     anop
               copy  sinetbl.inc

               END
