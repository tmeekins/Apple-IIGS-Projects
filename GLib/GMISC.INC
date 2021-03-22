***************************************************************************
*
* Save the integer coordinates XCoord1,YCoord1,XCoord2,YCoord2.
*
*  Entry Points:
*    GL_SaveXY       - Save integer Coordinates
*
*  Inputs:
*    XCoord1,2,YCoord1,2 - The coordinates to save
*
*  Outputs:
*    GL_X1,X2,Y1,Y2  - The saved coordinates
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/02/89 - Original version written.
*
***************************************************************************
*
GL_SaveXY      START

               using GL_Tables

               longa on
               longa on

               lda   XCoord1
               sta   GL_X1
               lda   XCoord2
               sta   GL_X2
               lda   YCoord1
               sta   GL_Y1
               lda   YCoord2
               sta   GL_Y2
               rtl

               end

***************************************************************************
*
* Save the fixed-point coordinates XCoord1,YCoord1,XCoord2,YCoord2.
*
*  Entry Points:
*    GL_SaveXYFi     - Save fixed-point Coordinates
*
*  Inputs:
*    XCoord1,2,YCoord1,2 - The coordinates to save
*
*  Outputs:
*    GL_X1,X2,Y1,Y2  - The saved coordinates
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/27/89 - Original version written.
*
***************************************************************************
*
GL_SaveXYFi    START

               using GL_Tables

               longa on
               longa on

               lda   XCoord1
               sta   GL_X1
               lda   XCoord1+2
               sta   GL_X1+2
               lda   XCoord2
               sta   GL_X2
               lda   XCoord2+2
               sta   GL_X2+2
               lda   YCoord1
               sta   GL_Y1
               lda   YCoord1+2
               sta   GL_Y1+2
               lda   YCoord2
               sta   GL_Y2
               lda   YCoord2+2
               sta   GL_Y2+2
               rtl

               end

***************************************************************************
*
* Restore the integer coordinates XCoord1,YCoord1,XCoord2,YCoord2.
*
*  Entry Points:
*    GL_RestoreXY    - Restore integer Coordinates
*
*  Inputs:
*    GL_X1,X2,Y1,Y2  - The saved coordinates
*
*  Outputs:
*    XCoord1,2,YCoord1,2 - The coordinates to restore
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/02/89 - Original version written.
*
***************************************************************************
*
GL_RestoreXY   START

               using GL_Tables

               longa on
               longa on

               lda   GL_X1
               sta   XCoord1
               lda   GL_X2
               sta   XCoord2
               lda   GL_Y1
               sta   YCoord1
               lda   GL_Y2
               sta   YCoord2
               rtl

               end

***************************************************************************
*
* Restore the fixed-point coordinates XCoord1,YCoord1,XCoord2,YCoord2.
*
*  Entry Points:
*    GL_RestoreXYFi  - Restore fixed-point Coordinates
*
*  Inputs:
*    GL_X1,X2,Y1,Y2  - The saved coordinates
*
*  Outputs:
*    XCoord1,2,YCoord1,2 - The coordinates to restore
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/27/89 - Original version written.
*
***************************************************************************
*
GL_RestoreXYFi START

               using GL_Tables

               longa on
               longa on

               lda   GL_X1
               sta   XCoord1
               lda   GL_X1+2
               sta   XCoord1+2
               lda   GL_X2
               sta   XCoord2
               lda   GL_X2+2
               sta   XCoord2+2
               lda   GL_Y1
               sta   YCoord1
               lda   GL_Y1+2
               sta   YCoord1+2
               lda   GL_Y2
               sta   YCoord2
               lda   GL_Y2+2
               sta   YCoord2+2
               rtl

               end

***************************************************************************
*
* Swap integer coordinates XCoord1,YCoord1 with XCoord2,YCoord2.
*
*  Entry Points:
*    GL_SwapXY       - Swap Integer Coordinates
*
*  Inputs:
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Coordinates to be swapped
*
*  Outputs:
*    XCoord1,YCoord1 - Same as old XCoord2,YCoord2
*    XCoord2,YCoord2 - Same as old XCoord1,YCoord1
*    X,Y             - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/02/89 - Original version written.
*
***************************************************************************
*
GL_SwapXY      START

               longa on
               longi on

               ldx   XCoord1
               ldy   XCoord2
               stx   XCoord2
               sty   XCoord1

               ldx   YCoord1
               ldy   YCoord2
               stx   YCoord2
               sty   YCoord1

               rtl

               END

***************************************************************************
*
* Swap fixed-point coordinates XCoord1,YCoord1 with XCoord2,YCoord2.
*
*  Entry Points:
*    GL_SwapXYFi     - Swap Fixed-Point Coordinates
*
*  Inputs:
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Coordinates to be swapped
*
*  Outputs:
*    XCoord1,YCoord1 - Same as old XCoord2,YCoord2
*    XCoord2,YCoord2 - Same as old XCoord1,YCoord1
*    X,Y             - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/27/89 - Original version written.
*
***************************************************************************
*
GL_SwapXYFi    START

               longa on
               longi on

               ldx   XCoord1
               ldy   XCoord2
               stx   XCoord2
               sty   XCoord1
               ldx   XCoord1+2
               ldy   XCoord2+2
               stx   XCoord2+2
               sty   XCoord1+2

               ldx   YCoord1
               ldy   YCoord2
               stx   YCoord2
               sty   YCoord1
               ldx   YCoord1+2
               ldy   YCoord2+2
               stx   YCoord2+2
               sty   YCoord1+2

               rtl

               END

***************************************************************************
*
* Convert coordinates from integer to fixed-point.
*
*  Entry Points:
*    GL_XY2Fi        - Convert Coordinates to fixed-point
*
*  Inputs:
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Coordinates to be converted (integer)
*
*  Outputs:
*    XCoord1,YCoord1
*    XCoord2,YCoord2 - Converted coordinates (fixed-point)
*    A               - unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/27/89 - Original version written.
*
***************************************************************************
*
GL_XY2Fi       START

               longa on
               longi on

               lda   XCoord1
               sta   XCoord1+2
               stz   XCoord1

               lda   XCoord2
               sta   XCoord2+2
               stz   XCoord2

               lda   YCoord1
               sta   YCoord1+2
               stz   YCoord1

               lda   YCoord2
               sta   YCoord2+2
               stz   YCoord2

               rtl

               END

***************************************************************************
*
* Convert coordinates from fixed-point to integer.
*
*  Entry Points:
*    GL_XY2In        - Convert Coordinates to integer
*
*  Inputs:
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Coordinates to be converted (fixed-point)
*
*  Outputs:
*    XCoord1,YCoord1
*    XCoord2,YCoord2 - Converted coordinates (integer)
*    A,X             - unknown
*    fArg1,Result    - unknown
*
*  External Procedures:
*    FI_Fi2In        - Convert fixed-point to integer
*
*  Revision History:
*     9/27/89 - Original version written.
*
***************************************************************************
*
GL_XY2In       START

               longa on
               longi on

               lda   XCoord1
               sta   fArg1
               lda   XCoord1+2
               sta   fArg1+2
               jsl   FI_Fi2In
               sta   XCoord1
               stz   XCoord1+2

               lda   XCoord2
               sta   fArg1
               lda   XCoord2+2
               sta   fArg1+2
               jsl   FI_Fi2In
               sta   XCoord2
               stz   XCoord2+2

               lda   YCoord1
               sta   fArg1
               lda   YCoord1+2
               sta   fArg1+2
               jsl   FI_Fi2In
               sta   YCoord1
               stz   YCoord1+2

               lda   YCoord2
               sta   fArg1
               lda   YCoord2+2
               sta   fArg1+2
               jsl   FI_Fi2In
               sta   YCoord2
               stz   YCoord2+2

               rtl

               END
