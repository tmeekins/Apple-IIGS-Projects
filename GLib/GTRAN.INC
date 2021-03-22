***************************************************************************
*
*  Initialize a matrix by creating an identity matrix.
*
*  Entry Points:
*    GL_InitMatrix   - Initialize a matrix.
*
*  Inputs:
*    MatrixPtr       - Points to the matrix to initialize
*
*  Outputs:
*    MatrixPtr       - A newly initialized matrix
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/29/89 - Original version written.
*
***************************************************************************
*
GL_InitMatrix  START

               longa on
               longi off
               sep   #$10

;
; Initialize array to zeros
;
               lda   #0
               ldy   #vsize-2
ZeroLoop       sta   [MatrixPtr],y
               dey
               dey
               bpl   ZeroLoop
;
; Make the matrix an identity matrix by placing 1's in the main echelon.
;
               lda   #1
               ldy   #v11+2
               sta   [MatrixPtr],y
               ldy   #v22+2
               sta   [MatrixPtr],y
               ldy   #v33+2
               sta   [MatrixPtr],y

               longi on
               rep   #$10

               rtl

               END

***************************************************************************
*
*  Transform a point by using the transformation matrix.
*  Assumes fixed-point coordinates.
*
*  Entry Points:
*    GL_TransPoint   - Transform a point.
*
*  Inputs:
*    MatrixPtr       - Points to the transformation matrix.
*    XCoord1,YCoord1 - The point to transform. (fixed-point)
*
*  Outputs:
*    A,X,Y           - unknown.
*    XCoord1,YCoord1 - The transformed point. (fixed-point)
*    fArg1, fArg2,   - unknown.
*    fResult, Result - unknown.
*
*  External Procedures:
*    FI_SMult        - Fixed-Point signed multiplication
*
*  Revision History:
*     4/29/89 - Original version written.
*     4/30/89 - Minor optimizations.
*     9/27/89 - Now uses fixed-point coordinates.
*
***************************************************************************
*
GL_TransPoint  START

               longa on
               longi on

;
; x' = v11*x + v21*y + v31
;
               lda   [MatrixPtr]        ;<- v11
               sta   fArg1
               ldy   #v11+2
               lda   [MatrixPtr],y
               sta   fArg1+2
               lda   XCoord1
               sta   fArg2
               lda   XCoord1+2
               sta   fArg2+2
               jsl   FI_SMult
               lda   fResult
               sta   temp
               lda   fResult+2
               sta   temp+2

               ldy   #v21
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               lda   YCoord1
               sta   fArg2
               lda   YCoord1+2
               sta   fArg2+2
               jsl   FI_SMult
               clc
               lda   fResult
               adc   temp
               sta   temp
               lda   fResult+2
               adc   temp+2
               sta   temp+2
               ldy   #v31
               clc
               lda   [MatrixPtr],y
               adc   temp
               pha
               iny
               iny
               lda   [MatrixPtr],y
               adc   temp+2
               pha
;
; y' = v12*x + v22*y + v32
;
               ldy   #v12
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               lda   XCoord1
               sta   fArg2
               lda   XCoord1+2
               sta   fArg2+2
               jsl   FI_SMult
               lda   fResult
               sta   temp
               lda   fResult+2
               sta   temp+2

               ldy   #v22
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               lda   YCoord1
               sta   fArg2
               lda   YCoord1+2
               sta   fArg2+2
               jsl   FI_SMult
               clc
               lda   fResult
               adc   temp
               sta   temp
               lda   fResult+2
               adc   temp+2
               sta   temp+2
               ldy   #v32
               clc
               lda   [MatrixPtr],y
               adc   temp
               sta   YCoord1
               iny
               iny
               lda   [MatrixPtr],y
               adc   temp+2
               sta   YCoord1+2

               pla
               sta   XCoord1+2
               pla
               sta   XCoord1

               rtl

temp           ds    4

               END

***************************************************************************
*
*  Transform a polygon by using the transformation matrix.
*  Assumes fixed-point coordinates.
*  NOTE: This doesn't actually transform the individual vertices of a
*  polygon, but instead it transforms EVERY point in a polygon point table.
*
*  Entry Points:
*    GL_TransPoly    - Transform a poly.
*
*  Inputs:
*    GLParm          - Points to the table of original vertices. (^fixed)
*    PointPtr        - Points to the table of transformed vertices. (^fixed)
*    MatrixPtr       - Points to the transformation matrix.
*
*  Outputs:
*    PointPtr        - Points to the table of transformed vertices. (^fixed)
*    A,X,Y           - unknown
*    XCoord1,YCoord1 - unknown
*    fArg1, fArg2,   - unknown
*    fResult, Result - unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/29/89 - Original version written.
*     4/30/89 - Interchanged the meaning of PointPtr and GLParm.
*     9/27/89 - Now uses fixed-point coordinates.
*
***************************************************************************
*
GL_TransPoly   START

               longa on
               longi on
;
; Copy table size
;
               lda   [GLParm]
               sta   [PointPtr]
;
; Transform each vertice
;
TransLoop      pha
               asl   a
               asl   a
               asl   a
               tay
               phy
               lda   [GLParm],y
               sta   XCoord1
               iny
               iny
               lda   [GLParm],y
               sta   XCoord1+2
               iny
               iny
               lda   [GLParm],y
               sta   YCoord1
               iny
               iny
               lda   [GLParm],y
               sta   YCoord1+2
               jsl   GL_TransPoint
               ply
               lda   XCoord1
               sta   [PointPtr],y
               iny
               iny
               lda   XCoord1+2
               sta   [PointPtr],y
               iny
               iny
               lda   YCoord1
               sta   [PointPtr],y
               iny
               iny
               lda   YCoord1+2
               sta   [PointPtr],y
               pla
               dec   a
               bne   TransLoop

               rtl

               END

***************************************************************************
*
*  Translate an object by modifying the transformation matrix.
*  Assumes fixed-point coordinates.
*
*  Entry Points:
*    GL_TranslateXY  - Translate an object by X,Y.
*
*  Inputs:
*    MatrixPtr       - Points to the matrix to translate.
*    XCoord1,YCoord1 - Relative distance to translate. (fixed-point)
*
*  Outputs:
*    MatrixPtr       - A newly translated matrix.
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/30/89 - Original version written.
*     9/27/89 - Now uses fixed-point coordinates.
*
***************************************************************************
*
GL_TranslateXY START

               longa on
               longi off

               sep   #$10

;
; v31' = v31 * tx
;
               clc
               ldy   #v31
               lda   [MatrixPtr],y
               adc   XCoord1
               sta   [MatrixPtr],y
               iny
               iny
               lda   [MatrixPtr],y
               adc   XCoord1+2
               sta   [MatrixPtr],y
;
; v32' = v32 * ty
;
               clc
               ldy   #v32
               lda   [MatrixPtr],y
               adc   YCoord1
               sta   [MatrixPtr],y
               iny
               iny
               lda   [MatrixPtr],y
               adc   YCoord1+2
               sta   [MatrixPtr],y

               longi on
               rep   #$10

               rtl

               END

***************************************************************************
*
*  Scale an object by modifying the transformation matrix.
*
*  Entry Points:
*    GL_Scale        - Scale an object.
*
*  Inputs:
*    MatrixPtr       - Points to the matrix to scale.
*    GLFix1          - X scaling factor (fixed-point).
*    GLFix2          - Y scaling factor (fixed-point).
*
*  Outputs:
*    MatrixPtr       - A newly scaled matrix.
*
*  External Procedures:
*    FI_SMult        - Fixed-Point signed multiplication.
*
*  Revision History:
*     4/30/89 - Original version written.
*
***************************************************************************
*
GL_Scale       START

               longa on
               longi on

               lda   GLFix1
               sta   fArg2
               lda   GLFix1+2
               sta   fArg2+2
;
; v11' = v11 * sx
;
               lda   [MatrixPtr]        ;<= v11
               sta   fArg1
               ldy   #v11+2
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   [MatrixPtr]
               ldy   #v11+2
               lda   fResult+2
               sta   [MatrixPtr],y
;
; v21' = v21 * sx
;
               ldy   #v21
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v21
               lda   fResult
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sta   [MatrixPtr],y
;
; v31' = v31 * sx
;
               ldy   #v31
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v31
               lda   fResult
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sta   [MatrixPtr],y
;
;
               lda   GLFix2
               sta   fArg2
               lda   GLFix2+2
               sta   fArg2+2
;
; v12' = v12 * sy
;
               ldy   #v12
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v12
               lda   fResult
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sta   [MatrixPtr],y
;
; v22' = v22 * sy
;
               ldy   #v22
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v22
               lda   fResult
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sta   [MatrixPtr],y
;
; v32' = v32 * sy
;
               ldy   #v32
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v32
               lda   fResult
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sta   [MatrixPtr],y

               rtl

               END

***************************************************************************
*
*  Rotate an object by modifying the transformation matrix.
*
*  Entry Points:
*    GL_Rotate       - Rotate an object.
*
*  Inputs:
*    MatrixPtr       - Points to the matrix to rotate.
*    Arg1            - Angle of rotation
*
*  Outputs:
*    MatrixPtr       - A newly rotated matrix.
*
*  External Procedures:
*    FI_Cos          - Fixed-Point cosine
*    FI_Sin          - Fixed-Point sine
*    FI_SMult        - Fixed-Point signed multiplication.
*
*  Revision History:
*     5/04/89 - Original version written.
*
***************************************************************************
*
GL_Rotate      START

               longa on
               longi on
;
; farg2 = sin
;
               jsl   FI_Sin
               lda   fResult
               sta   fArg2
               lda   fResult+2
               sta   fArg2+2
;
; va = v12*sin
;
               ldy   #v12
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   va
               lda   fResult+2
               sta   va+2
;
; vb = v22*sin
;
               ldy   #v22
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   vb
               lda   fResult+2
               sta   vb+2
;
; vc = v32*sin
;
               ldy   #v32
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   vc
               lda   fResult+2
               sta   vc+2
;
; vd = v11*sin
;
               lda   [MatrixPtr]        ;v11
               sta   fArg1
               ldy   #v11+2
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   vd
               lda   fResult+2
               sta   vd+2
;
; ve = v21*sin
;
               ldy   #v21
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   ve
               lda   fResult+2
               sta   ve+2
;
; vf = v31*sin
;
               ldy   #v31
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               lda   fResult
               sta   vf
               lda   fResult+2
               sta   vf+2
;
; farg2 = cos
;
               jsl   FI_Cos
               lda   fResult
               sta   fArg2
               lda   fResult+2
               sta   fArg2+2
;
; v11' = v11*cos - va
;
               ldy   #v11
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v11
               sec
               lda   fResult
               sbc   va
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sbc   va+2
               sta   [MatrixPtr],y
;
; v21' = v21*cos - vb
;
               ldy   #v21
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v21
               sec
               lda   fResult
               sbc   vb
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sbc   vb+2
               sta   [MatrixPtr],y
;
; v31' = v31*cos - vc
;
               ldy   #v31
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v31
               sec
               lda   fResult
               sbc   vc
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               sbc   vc+2
               sta   [MatrixPtr],y
;
; v12' = v12*cos + vd
;
               ldy   #v12
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v12
               clc
               lda   fResult
               adc   vd
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               adc   vd+2
               sta   [MatrixPtr],y
;
; v22' = v22*cos + ve
;
               ldy   #v22
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v22
               clc
               lda   fResult
               adc   ve
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               adc   ve+2
               sta   [MatrixPtr],y
;
; v32' = v32*cos + vf
;
               ldy   #v32
               lda   [MatrixPtr],y
               sta   fArg1
               iny
               iny
               lda   [MatrixPtr],y
               sta   fArg1+2
               jsl   FI_SMult
               ldy   #v32
               clc
               lda   fResult
               adc   vf
               sta   [MatrixPtr],y
               iny
               iny
               lda   fResult+2
               adc   vf+2
               sta   [MatrixPtr],y

               rtl

va             ds    4
vb             ds    4
vc             ds    4
vd             ds    4
ve             ds    4
vf             ds    4

               END
