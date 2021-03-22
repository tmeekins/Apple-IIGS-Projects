***************************************************************************
*
* Create a new window (actually just redefining the old one.)
* Assumes fixed-point numbers.
*
*  Entry Points:
*    GL_SetWindow    - Create a new window definition
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Window rectangle to use
*
*  Outputs:
*    carry flag      - set if error in window rectangle
*    A,X,Y           - Unknown
*    WindXXX         - Window definition is updated
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/25/89 - Original version written.
*     4/26/89 - Bug Fix.
*     4/30/89 - Changed name from Window to SetWindow.
*     9/27/89 - Window is now defined as fixed-point coordinates.
*
***************************************************************************
*
GL_SetWindow   START

               using GL_Tables

               longa on
               longi on

               sec
               lda   XCoord2
               sbc   XCoord1
               tax
               lda   XCoord2+2
               sbc   XCoord1+2
               bmi   Error
               tay

               sec
               lda   YCoord2
               sbc   YCoord1
               pha
               lda   YCoord2+2
               sbc   YCoord1+2
               bmi   Error

               sta   WindHeight+2
               pla
               sta   WindHeight
               stx   WindWidth
               sty   WindWidth+2

               lda   XCoord1
               sta   WindLeft
               lda   XCoord1+2
               sta   WindLeft+2
               lda   XCoord2
               sta   WindRight
               lda   XCoord2+2
               sta   WindRight+2
               lda   YCoord1
               sta   WindTop
               lda   YCoord1+2
               sta   WindTop+2
               lda   YCoord2
               sta   WindBot
               lda   YCoord2+2
               sta   WindBot+2

               clc
               rtl

error          sec
               rtl

               END

***************************************************************************
*
* Create a new viewport (actually just redefining the old one.)
* Assumes integer coordinates.
*
*  Entry Points:
*    GL_SetViewport  - Create a new viewport definition
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Viewport rectangle to use
*
*  Outputs:
*    carry flag      - set if error in viewport rectangle
*    A,X,Y           - Unknown
*    ViewXXX         - Viewport definition is updated
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/25/89 - Original version written.
*     4/27/89 - Backwards viewports will not be allowed.
*     4/30/89 - Renamed from Viewport to SetViewport
*
***************************************************************************
*
GL_SetViewport START

               using GL_Tables

               longa on
               longi on

               lda   XCoord1
               bmi   error
               cmp   #320
               bcs   error
               lda   XCoord2
               bmi   error
               cmp   #320
               bcs   error
               lda   YCoord1
               bmi   error
               cmp   #200
               bcs   error
               lda   YCoord2
               bmi   error
               cmp   #200
               bcs   error

               sta   ViewBot
               sec
               sbc   YCoord1
               bmi   error
               sta   ViewHeight
               lda   YCoord1
               sta   ViewTop

               sec
               lda   XCoord2
               sta   ViewRight
               sbc   XCoord1
               bmi   error
               sta   ViewWidth
               lda   XCoord1
               sta   ViewLeft

               clc
               rtl

error          sec
               rtl

               END

***************************************************************************
*
* Copy the viewport to XCoord,YCoord etc.
* Assumes integer coordinates.
*
*  Entry Points:
*    GL_GetViewport  - Copy the viewport to XCoord, YCoord
*
*  Inputs:
*    ViewXXX         - Viewport
*
*  Outputs:
*    XCoord1,YCoord1 - Same as old ViewLeft,ViewTop
*    XCoord2,YCoord2 - Same as old ViewRight,ViewBot
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/17/89 - Original version written.
*     4/30/89 - Changed name from ViewXY to GetViewport.
*
***************************************************************************
*
GL_GetViewport START

               using GL_Tables

               longa on
               longi on

               lda   ViewLeft
               sta   XCoord1
               lda   ViewRight
               sta   XCoord2
               lda   ViewTop
               sta   YCoord1
               lda   ViewBot
               sta   YCoord2

               rtl

               END

***************************************************************************
*
* Copy the window to XCoord,YCoord etc.
* Assumes fixed-point coordinates.
*
*  Entry Points:
*    GL_GetWindow    - Copy the window to XCoord, YCoord
*
*  Inputs:
*    WindXXX         - Window
*
*  Outputs:
*    XCoord1,YCoord1 - Same as old WindLeft,WindTop
*    XCoord2,YCoord2 - Same as old WindRight,WindBot
*    A               - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     4/25/89 - Original version written.
*     4/30/89 - Changed name from WindXY to GetWindow.
*     9/27/89 - Modifies to work with fixed-point coordinates.
*
***************************************************************************
*
GL_GetWindow   START

               using GL_Tables

               longa on
               longi on

               lda   WindLeft
               sta   XCoord1
               lda   WindLeft+2
               sta   XCoord1+2
               lda   WindRight
               sta   XCoord2
               lda   WindRight+2
               sta   XCoord2+2
               lda   WindTop
               sta   YCoord1
               lda   WindTop+2
               sta   YCoord1+2
               lda   WindBot
               sta   YCoord2
               lda   WindBot+2
               sta   YCoord2+2

               rtl

               END

***************************************************************************
*
* Map a fixed-point point from the window to the viewport. Result is an
* integer point. Also known as Window-to-Viewport transformations.
*
*  Entry Points:
*    GL_MapPoint     - Map a point to the current viewport.
*
*  Inputs:
*    XCoord1,YCoord1 - The point to be transformed (fixed-point)
*    WindXXX         - The world coordinates of the point (fixed-point)
*    ViewXXX         - The viewport to be mapped to (integer)
*
*  Outputs:
*    XCoord1,YCoord1 - The new mapped coordinate (integer)
*    A,X,Y           - Unknown
*    Arg1, Arg2, Result - Unknown
*
*  External Procedures:
*    FI_SDiv   - Signed fixed-point division
*    FI_Fi2In  - Convert a fixed-point number into integer
*    FI_SMult  - Signed fixed-point multiplication
*
*  Revision History:
*     4/26/89 - Original version written.
*     9/27/89 - Now maps a fixed-point coordinate to an integer coordinate.
*
***************************************************************************
*
GL_MapPoint    START

               using GL_Tables

               longa on
               longi on

;
; x' := (ViewWidth / WindWidth) * (x - WindLeft) + ViewLeft;
;
               lda   ViewWidth
               sta   fArg1+2
               stz   fArg1
               sec
               lda   XCoord1
               sbc   WindLeft
               sta   fArg2
               lda   XCoord1+2
               sbc   WindLeft+2
               sta   fArg2+2
               jsl   FI_SMult
               lda   fResult
               sta   fArg1
               lda   fResult+2
               sta   fArg1+2
               lda   WindWidth
               sta   fArg2
               lda   WindWidth+2
               sta   fArg2+2
               jsl   FI_SDiv
               lda   fResult
               sta   fArg1
               lda   fResult+2
               sta   fArg1+2
               jsl   FI_Fi2In
               clc
               adc   ViewLeft
               sta   XCoord1
;
; y' := (ViewHeight / WindHeight) * (y - WindTop) + ViewTop;
;
               lda   ViewHeight
               sta   fArg1+2
               stz   fArg1
               sec
               lda   YCoord1
               sbc   WindTop
               sta   fArg2
               lda   YCoord1+2
               sbc   WindTop+2
               sta   fArg2+2
               jsl   FI_SMult
               lda   fResult
               sta   fArg1
               lda   fResult+2
               sta   fArg1+2
               lda   WindHeight
               sta   fArg2
               lda   WindHeight+2
               sta   fArg2+2
               jsl   FI_SDiv
               lda   fResult
               sta   fArg1
               lda   fResult+2
               sta   fArg1+2
               jsl   FI_Fi2In
               clc
               adc   ViewTop
               sta   YCoord1

               rtl

               END

***************************************************************************
*
* Map a polygon to the current viewport.
* Input polygon is fixed-point and output is integer polygon
* NOTE: This doesn't actually map the vertices in a polygon, but it simply
* maps EVERY vertice in the Point table.
*
*  Entry Points:
*    GL_MapPoly      - Map a polygon to the current viewport.
*
*  Inputs:
*    WindXXX         - The world coordinates of the point (fixed)
*    ViewXXX         - The viewport to be mapped to (integer)
*    GLParm          - Points to the table of vertices (^fixed)
*    PointPtr        - Location of transformed table of vertices. (^integer)
*
*  Outputs:
*    PointPtr        - All transformed points are placed in this table (^int)
*    XCoord1,YCoord1 - Unknown
*    A,X,Y           - Unknown
*    Arg1, Arg2, Result - Unknown
*
*  External Procedures:
*    GL_MapPoint     - Map a point to the current viewport
*
*  Revision History:
*     4/26/89 - Original version written.
*     4/30/89 - Interchanged the roles of PointPtr and GLParm.
*     9/27/89 - Now transforms a fixed-point polygon to an integer polygon.
*
***************************************************************************
*
GL_MapPoly     START

               using GL_Tables

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
MapLoop        pha
               asl   a
               asl   a
               pha
               asl   a
               tay
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
               jsl   GL_MapPoint
               ply
               lda   XCoord1
               sta   [PointPtr],y
               iny
               iny
               lda   YCoord1
               sta   [PointPtr],y
               pla
               dec   a
               bne   MapLoop

               rtl

               END
