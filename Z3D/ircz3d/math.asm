***************************************************************************
*                                                                         *
* MATH.ASM                                                                *
*                                                                         *
***************************************************************************

               copy  mat.h
               copy  pnt.h
               copy  z3d.h
               keep  math
               mcopy math.mac

***************************************************************************
*                                                                         *
* Variables used by math routines                                         *
*                                                                         *
***************************************************************************

MathData       DATA

SignFlag       ds    2

               END

***************************************************************************
*                                                                         *
* Initialize the multiplication tables and the sine table                 *
*                                                                         *
***************************************************************************

InitMath       START

	using	tabledata

;
; Create multiplication table
;
               ldx   #0
               stx   Scale
Loop1          lda   #0
               ldy   #$100
Loop2          short a
               sta   >MultTblL,x
               xba
               sta   >MultTblH,x
               xba
               long  a
               clc
               adc   Scale
               inx
               dey
               bne   Loop2
               inc   Scale
               txa
               bne   Loop1
;
; Create a sine table
;
               ldx   #0
               stz   Angle
               stz   Angle+2
SinLoop        phx
               pha
               pha
               pha
               pha
               ph4   Angle
               Tool  $160B              ;FracSin
               Tool  $1D0B              ;Frac2Fix
               pla
               ply
               plx
               sta   >SineTbl,x
               inx2
               tya
               sta   >SineTbl,x
               inx2
               add4  Angle,#$648,Angle
               cpx   #$400
               bcc   SinLoop

               rts

Scale          ds    2
Angle          ds    4

               END

***************************************************************************
*                                                                         *
* Create an Identity matrix                                               *
*                                                                         *
*  |  1  0  0  |                                                          *
*  |  0  1  0  |                                                          *
*  |  0  0  1  |                                                          *
*  |  0  0  0  |                                                          *
*                                                                         *
***************************************************************************

IdentityMat    START

               lda   #1

               stz   matrix+m11+0
               sta   matrix+m11+2
               stz   matrix+m12+0
               stz   matrix+m12+2
               stz   matrix+m13+0
               stz   matrix+m13+2

               stz   matrix+m21+0
               stz   matrix+m21+2
               stz   matrix+m22+0
               sta   matrix+m22+2
               stz   matrix+m23+0
               stz   matrix+m23+2

               stz   matrix+m31+0
               stz   matrix+m31+2
               stz   matrix+m32+0
               stz   matrix+m32+2
               stz   matrix+m33+0
               sta   matrix+m33+2

               rts

               END

***************************************************************************
*                                                                         *
* Rotate matrix about X.                                                  *
*                                                                         *
*  |  m11  m12*cos-m13*sin  m12*sin+m13*cos |                             *
*  |  m12  m22*cos-m23*sin  m22*sin+m23*cos |                             *
*  |  m13  m32*cos-m33*sin  m32*sin+m33*cos |                             *
*  |  m14  m42*cos-m43*sin  m42*sin+m43*cos |                             *
*                                                                         *
***************************************************************************

RotXMat        START

               using MathData

	mv4	matrix+m12,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m13,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m12,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m13,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m13
               pla
               adc   Result+4
	sta	matrix+m13+2

	mv4	tmp,matrix+m12

	mv4	matrix+m22,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m23,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m22,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m23,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m23
               pla
               adc   Result+4
	sta	matrix+m23+2

	mv4	tmp,matrix+m22

	mv4	matrix+m32,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m33,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m32,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m33,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m33
               pla
               adc   Result+4
	sta	matrix+m33+2

	mv4	tmp,matrix+m32

               rts

tmp            ds    4

               END

***************************************************************************
*                                                                         *
* Rotate matrix about Y                                                   *
*                                                                         *
*  |  m11*cos+m13*sin  m12  m13*cos-m11*sin |                             *
*  |  m21*cos+m23*sin  m22  m23*cos-m21*sin |                             *
*  |  m31*cos+m33*sin  m32  m33*cos-m31*sin |                             *
*  |  m41*cos+m43*sin  m42  m43*cos-m41*sin |                             *
*                                                                         *
***************************************************************************

RotYMat        START

               using MathData

	mv4	matrix+m11,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m13,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m13,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m11,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m13
               pla
               adc   Result+4
	sta	matrix+m13+2

	mv4	tmp,matrix+m11

	mv4	matrix+m21,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m23,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m23,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m21,Arg1
	lda	sin
               ldx   sin+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m23
               pla
               adc   Result+4
	sta	matrix+m23+2

	mv4	tmp,matrix+m21

	mv4	matrix+m31,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m33,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               sec
               pla
               sbc   Result+2
               sta   tmp
               pla
               sbc   Result+4
               sta   tmp+2

	mv4	matrix+m33,Arg1
               lda   cos
               ldx   cos+2
               jsr   FixFixMul
               ph4   Result+2

	mv4	matrix+m31,Arg1
               lda   sin
               ldx   sin+2
               jsr   FixFixMul

               clc
               pla
               adc   Result+2
	sta	matrix+m33
               pla
               adc   Result+4
	sta	matrix+m33+2

	mv4	tmp,matrix+m31

               rts             

tmp            ds    4

               END

**************************************************************************
*
* transform each vertex point from object space to world space
*
**************************************************************************

TransformObj   START

               ldy   PntPtr

TransformLoop  anop
               lda   |0,y
               and   #$FF               ;=0 if more vertices
               beq   TransPnt
               rts
TransPnt       phy
               jsr   TransformPnt
               pla
               add2  @a,#pntsize,@y
               bra   TransformLoop

               END

***************************************************************************
*                                                                         *
* Transform a coordinate using a transformation matrix.                   *
* Uses transformation matrix to transform from object space to world space*
*  coord = m11*x + m21*y + m31*z + m41                                    *
*                                                                         *
***************************************************************************

TransformPnt   START

               using MathData

               sty   pnts
;
; Save the object space coordinates
;
               mv2   "|pntox,y",oldx
               mv2   "|pntoy,y",oldy
               mv2   "|pntoz,y",oldz
;
; Transform X coordinate
;
	mv4	matrix+m11,Arg1
               lda   oldx
               jsr   FixIntMul

	mv4	Result,coord

	mv4	matrix+m21,Arg1
               lda   oldy
               jsr   FixIntMul

               add4  coord,Result,coord

	mv4	matrix+m31,Arg1
               lda   oldz
               jsr   FixIntMul

	clc
	lda	coord
	adc	Result
	lda	coord+2
	adc	Result+2

               ldy   pnts
	sta	|pntwx+1,y
;
; Transform Y coordinate
;
	mv4	matrix+m12,Arg1
               lda   oldx
               jsr   FixIntMul

	mv4	Result,coord

	mv4	matrix+m22,Arg1
               lda   oldy
               jsr   FixIntMul

               add4  coord,Result,coord

	mv4	matrix+m32,Arg1
               lda   oldz
               jsr   FixIntMul

	clc
	lda	coord
	adc	Result
	lda	coord+2
	adc	Result+2

               ldy   pnts
               sta   |pntwy+1,y
;
; Transform Z coordinate
;
	mv4	matrix+m13,Arg1
               lda   oldx
               jsr   FixIntMul

	mv4	Result,coord

	mv4	matrix+m23,Arg1
               lda   oldy
               jsr   FixIntMul

               add4  coord,Result,coord

	mv4	matrix+m33,Arg1
               lda   oldz
               jsr   FixIntMul

	clc
	lda	coord
	adc	Result
	lda	coord+2
	adc	Result+2

               ldy   pnts
               sta   |pntwz+1,y

               rts

pnts           ds    2
coord          ds    4
oldx           ds    2
oldy           ds    2
oldz           ds    2

               END

***************************************************************************
*                                                                         *
* Multiply two fixed-point numbers                                        *
*                                                                         *
***************************************************************************

FixFixMul      START

               using tabledata
	using	MathData

               stz   Result
               stz   Result+2
               stz   Result+4
               stx   Arg2+2             ;If Arg2 = 0 then quit
               sta   Arg2
               ora   Arg2+2
               bne   ChkZero
MulQuit        anop
               rts
ChkZero        lda   Arg1               ;If Arg1 = 0 then quit
               ora   Arg1+2
               beq   MulQuit

               txa                      ;SignFlag = Arg1+2 xor Arg2+2
               eor   Arg1+2
               sta   SignFlag

               txy                      ;Arg2 = ||Arg2||
               bpl   AbsArg1
               tya
               eor   #$FFFF
               tay
               lda   Arg2
               eor   #$FFFF
               inc   a
               sta   Arg2
               bne   AbsArg2zz
               iny
AbsArg2zz      sty   Arg2+2

AbsArg1        lda   Arg1+2             ;Arg1 = ||Arg1||
               bpl   Mul1
               eor   #$FFFF
               tax
               lda   Arg1
               eor   #$FFFF
               inc   a
               sta   Arg1
               bne   AbsArg1zz
               inx
AbsArg1zz      stx   Arg1+2

Mul1           lda   Arg1-1
               and   #$FF00
               beq   Mul2

               short a
               tya                      ;Res(2,3) = Arg1(0)*Arg2(2)
               tax
               lda   >MultTblL,x
               sta   Result+2
               lda   >MultTblH,x
               sta   Result+3

               lda   Arg2+3             ;Arg1(0)*Arg2(3)
               tax
               lda   >MultTblL,x
               sta   Add1+1
               lda   >MultTblH,x
               sta   Add1+2

               lda   Arg2+1             ;Arg1(0)*Arg2(1)
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x

               rep   #$21                ;CLC & Long A
               longa on

               adc   Result+1           ;Res(1,2) = Res(1,2) + Arg1(0)*Arg2(1)
               sta   Result+1

               lda   Result+3           ;Res(3,4) = Res(3,4) + Arg1(0)*Arg2(3)
Add1           adc   #0
               sta   Result+3

Mul2           lda   Arg1
               and   #$FF00
               beq   Mul3

               short a

               lda   Arg2
               tax
               lda   >MultTblL,x
               sta   Add3+1
               lda   >MultTblH,x
               sta   Add3+2
               tya
               tax
               lda   >MultTblL,x
               sta   Add4+1
               lda   >MultTblH,x
               sta   Add4+2
               lda   Arg2+3
               tax
               lda   >MultTblL,x
               sta   Add2+1
               lda   >MultTblH,x
               sta   Add2+2
               lda   Arg2+1
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x

               rep   #$21               ;Long A & CLC
               longa on

               adc   Result+2
               sta   Result+2
               lda   Result+4
Add2           adc   #0
               sta   Result+4
               clc
               lda   Result+1
Add3           adc   #0
               sta   Result+1
               lda   Result+3
Add4           adc   #0
               sta   Result+3
               bcc   Mul3
               inc   Result+5

Mul3           lda   Arg1+1
               and   #$FF00
               beq   Mul4

               short a

               lda   Arg2
               tax
               lda   >MultTblL,x
               sta   Add6+1
               lda   >MultTblH,x
               sta   Add6+2
               tya
               tax
               lda   >MultTblL,x
               sta   Add7+1
               lda   >MultTblH,x
               sta   Add7+2
               lda   Arg2+3
               tax
               lda   >MultTblL,x
               sta   Add5+1
               lda   Arg2+1
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x

               rep   #$21               ;Long A & CLC
               longa on

               adc   Result+3
               sta   Result+3
               lda   Result+5
Add5           adc   #0
               sta   Result+5
               clc
               lda   Result+2
Add6           adc   #0
               sta   Result+2
               lda   Result+4
Add7           adc   #0
               sta   Result+4

Mul4           lda   Arg1+2
               and   #$FF00
               beq   Mul5

               short a

               lda   Arg2
               tax
               lda   >MultTblL,x
               sta   Add8+1
               lda   >MultTblH,x
               sta   Add8+2
               tya
               tax
               lda   >MultTblL,x
               sta   Add9+1
               lda   Arg2+1
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x

               rep   #$21               ;Long A & CLC
               longa on

               adc   Result+4
               sta   Result+4
               clc
               lda   Result+3
Add8           adc   #0
               sta   Result+3
               lda   Result+5
Add9           adc   #0
               sta   Result+5

Mul5           lda   SignFlag
               bpl   MulDone

               eor2  Result+4,#$FFFF,Result+4
               eor2  Result+2,#$FFFF,Result+2
               eor2  Result,#$FFFF,@a
               inc   a
               bne   sn0
               inc   Result+2
               bne   sn0
               inc   Result+4
sn0            sta   Result

MulDone        rts

               END

***************************************************************************
*                                                                         *
* Multiply a fixed-point number by an integer.                            *
*                                                                         *
***************************************************************************

FixIntMul      START

               using tabledata
	using	MathData

               stz   Result
               stz   Result+2
               stz   Result+4
               tax
               bne   ChkZero
MulByZero      rts
ChkZero        sta   Arg2
               lda   Arg1
               ora   Arg1+2
               beq   MulByZero

               txa
               eor   Arg1+2
               sta   SignFlag
               txa
               bpl   Neg1
               eor   #$FFFF
               inc   a
               sta   Arg2

Neg1           ldy   Arg1+2
               bpl   Mul1
               tya
               eor   #$FFFF
               tay
               lda   Arg1
               eor   #$FFFF
               inc   a
               sta   Arg1
               bne   Neg2
               iny
Neg2           sty   Arg1+2

Mul1           lda   Arg1+3
               and   #$FF00
               beq   Mul2

               short a
               lda   Arg1
               tax
               lda   >MultTblL,x
               sta   Result
               lda   >MultTblH,x
               sta   Result+1
               tya
               tax
               lda   >MultTblL,x
               sta   Result+2
               lda   >MultTblH,x
               sta   Result+3
               lda   Arg1+3
               tax
               lda   >MultTblL,x
               sta   Add1+1
               lda   >MultTblH,x
               sta   Add1+2
               lda   Arg1+1
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x
               long  a                  ;combine rep and clc??

               clc
               adc   Result+1
               sta   Result+1
               lda   Result+3
Add1           adc   #0
               sta   Result+3

Mul2           lda   Arg2
               and   #$FF00
               beq   Mul3

               short a
               lda   Arg1
               tax
               lda   >MultTblL,x
               sta   Add3+1
               lda   >MultTblH,x
               sta   Add3+2
               tya
               tax
               lda   >MultTblL,x
               sta   Add4+1
               lda   >MultTblH,x
               sta   Add4+2
               lda   Arg1+3
               tax
               lda   >MultTblL,x
               sta   Add2+1
               lda   >MultTblH,x
               sta   Add2+2
               lda   Arg1+1
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x
               long  a                  ;combine rep and clc??

               clc
               adc   Result+2
               sta   Result+2
               lda   Result+4
Add2           adc   #0
               sta   Result+4
               clc
               lda   Result+1
Add3           adc   #0
               sta   Result+1
               lda   Result+3
Add4           adc   #0
               sta   Result+3
               bcc   Mul3
               inc   Result+5

Mul3           lda   SignFlag
               bpl   MulDone

               eor2  Result+4,#$FFFF,Result+4
               eor2  Result+2,#$FFFF,Result+2
               eor2  Result,#$FFFF,@a
               inc   a
               bne   sn0
               inc   Result+2
               bne   sn0
               inc   Result+4
sn0            sta   Result

MulDone        rts

               END

***************************************************************************
*                                                                         *
* Multiply two integers                                                   *
*                                                                         *
***************************************************************************

IntIntMul      START

               using tabledata
	using	MathData

               stz   Result+2
               txy
               bne   Chk0
MulBy0         stz   Result
               rts
Chk0           stx   Arg2
               tay
               beq   MulBy0

               ldx   #0

               bpl   Neg1
               eor   #$FFFF
               inc   a
               inx
               tay

Neg1           lda   Arg2
               bpl   Neg2
               eor   #$FFFF
               inc   a
               dex
               sta   Arg2

Neg2           stx   SignFlag

               tya
               xba
               and   #$FF00
               beq   Mul1

               short a
               lda   Arg2
               tax
               lda   >MultTblL,x
               sta   Result
               lda   >MultTblH,x
               sta   Result+1

               lda   Arg2+1
               tax
               lda   >MultTblH,x
               sta   Result+2
               lda   >MultTblL,x
               clc
               adc   Result+1
               sta   Result+1
               bcc   Mul1a
               inc   Result+2
Mul1a          long  a

Mul1           tya
               and   #$FF00
               beq   Mul2

               short a
               lda   Arg2+1
               tax
               lda   >MultTblL,x
               sta   Add1+1
               lda   >MultTblH,x
               sta   Add1+2

               lda   Arg2
               tax
               lda   >MultTblH,x
               xba
               lda   >MultTblL,x
               long  a                  ;combine rep and clc??

               clc
               adc   Result+1
               sta   Result+1
               clc
               lda   Result+2
Add1           adc   #0
               sta   Result+2

Mul2           lda   SignFlag
               beq   MulDone

               eor2  Result+2,#$FFFF,Result+2
               eor2  Result,#$FFFF,@a
               inc   a
               bne   sn0
               inc   Result+2
sn0            sta   Result

MulDone        rts

               END

***************************************************************************
*                                                                         *
* Calculate the sine and cosine for an angle.                             *
* The (int) angle is in the msb and the (fract) part is in the lsb.       *
*  angle = msb.lsb                                                        *
*                                                                         *
***************************************************************************

FixSinCos      START

	using	tabledata

               pha
               and   #$FF               ; (angle mod 256)
               asl2  a
               tax
               lda   >SineTbl,x
               sta   sin
               lda   >SineTbl+2,x
               sta   sin+2

               pla
               add2  @a,#$40,@a         ;angle := angle + 90 (deg)
               and   #$FF               ; (angle mod 256)
               asl2  a
               tax
               lda   >SineTbl,x
               sta   cos
               lda   >SineTbl+2,x
               sta   cos+2

               rts

               END

***************************************************************************
*                                                                         *
* Signed Integer division                                                 *
*                                                                         *
***************************************************************************

SIntDiv        START

               using MathData

               sta   Divisor

               ldy   #0
               txa
               bpl   sign2
               eor   #$FFFF
               inc   a
               iny
sign2          sta   Quotient

               lda   Divisor
               bpl   dodiv
               eor   #$FFFF
               inc   a
               sta   Divisor
               dey

dodiv          lda   #0

;               cmp   Divisor
;               bcc   Div1
;               sbc   Divisor
Div1           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div2
               sbc   Divisor
Div2           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div3
               sbc   Divisor
Div3           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div4
               sbc   Divisor
Div4           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div5
               sbc   Divisor
Div5           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div6
               sbc   Divisor
Div6           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div7
               sbc   Divisor
Div7           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div8
               sbc   Divisor
Div8           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div9
               sbc   Divisor
Div9           rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div10
               sbc   Divisor
Div10          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div11
               sbc   Divisor
Div11          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div12
               sbc   Divisor
Div12          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div13
               sbc   Divisor
Div13          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div14
               sbc   Divisor
Div14          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div15
               sbc   Divisor
Div15          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div16
               sbc   Divisor
Div16          rol   Quotient
               rol   a
               cmp   Divisor
               bcc   Div17
               sbc   Divisor
Div17          rol   Quotient

               cpy   #0
               beq   done
               lda   Quotient
               eor   #$FFFF
               inc   a
               sta   Quotient

done           rts

               END
