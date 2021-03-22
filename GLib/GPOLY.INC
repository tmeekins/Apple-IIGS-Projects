**************************************************************************
*
* Frame a polygon. i.e. draw it's outline. Negative vertices indicate
* invisible line segments.
* Assumes integer polygons and coordinates
*
*  Entry Points:
*    GL_FramePoly    - Frame a polygon
*
*  Inputs:
*    PolyPtr         - Pointer to polygon structure
*    PointPtr        - Pointer to pixel table used by polygon (^integer)
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Unknown
*    ScanLinePtr     - Unknown
*
*  External Procedures:
*    GL_Line         - Draw a line
*    GL_Plot         - Plot a dot
*    GL_GetPolyPnt   - Get coordinates for polygon point
*    GL_PushXY       - Copy XCoord1,YCoord1 to XCoord2,YCoord2
*
*  Revision History:
*     2/21/89 - Original version written.
*     2/25/89 - Optimized polygon portion (>2 edges).
*     3/02/89 - Calls GetPolyPnt & PushXY
*     3/19/89 - Doesn't draw segments with negative vertices.
*     4/28/89 - Fixed a typo.
*
***************************************************************************
*
GL_FramePoly   START

               longa on
               longi on
;
; Check number of polygon points and do specific polygon
;
               lda   [PolyPtr]          ;Get number of polygon vertexes
               bne   Pl1
;
; There are no points, or polygon is flagged invisible so quit
;
done           rtl
;
; Polygon contains 1 point so simply plot a point
;
pl1            cmp   #1
               bne   pl2
               jsl   GL_GetPolyPnt
               bcs   done
               jml   GL_Plot
;
; Polygon contains 2 points so draw a line segment
;
pl2            cmp   #2
               bne   pl3
               jsl   GL_GetPolyPnt
               bcs   done
               jsl   GL_PushXY
               lda   #1
               jsl   GL_GetPolyPnt
               bcs   done
               jml   GL_Line
;
; Polygon contains more than 2 points so draw an actual polygon
;
pl3            jsl   GL_GetPolyPnt
               lda   #1
               sta   CurPoint
polyloop       jsl   GL_PushXY
               lda   CurPoint
               jsl   GL_GetPolyPnt
               bcs   nextseg
               jsl   GL_Line
nextseg        inc   CurPoint
               lda   CurPoint
               cmp   [PolyPtr]
               bcc   polyloop
               beq   polyloop
               rtl

CurPoint       ds    2

               END

**************************************************************************
*
* Frame a polygon without clipping. Also assume that it is a proper polygon
* with at least two points.
* Assumes integer coordinates
*
*  Entry Points:
*    GL_FramePoly2   - Frame a polygon w/o clipping
*
*  Inputs:
*    PolyPtr         - Pointer to polygon structure
*    PointPtr        - Pointer to pixel table used by polygon
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Unknown
*    ScanLinePtr     - Unknown
*
*  External Procedures:
*    GL_Line2        - Draw a line w/o clipping
*    GL_GetPolyPnt   - Get coordinates for polygon point
*    GL_PushXY       - Copy XCoord1,YCoord1 to XCoord2,YCoord2
*
*  Revision History:
*     5/05/89 - Original version written.
*
***************************************************************************
*
GL_FramePoly2  START

               longa on
               longi on

               lda   [PolyPtr]          ;Get number of polygon vertexes
               jsl   GL_GetPolyPnt
               lda   #1
               sta   CurPoint
polyloop       jsl   GL_PushXY
               lda   CurPoint
               jsl   GL_GetPolyPnt
               bcs   nextseg
               jsl   GL_Line2
nextseg        inc   CurPoint
               lda   CurPoint
               cmp   [PolyPtr]
               bcc   polyloop
               beq   polyloop
               rtl

CurPoint       ds    2

               END

***************************************************************************
*
* Paint a solid polygon.
* Assumes integer coordinates
*
*  Entry Points:
*    GL_PaintPoly    - Paint a polygon
*
*  Inputs:
*    PolyPtr         - Pointer to polygon structure
*    PointPtr        - Pointer to pixel table used by polygon
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Unknown
*    ScanLinePtr     - Unknown
*    Arg1,Arg2,Result- Unknown
*
*  External Procedures:
*    GL_Line         - Draw a line
*    GL_Plot         - Plot a dot
*    GL_HLine3       - Draw a horizontal line w/o clipping
*    GL_GetPolyPnt   - Get coordinates for polygon point
*    GL_PushXY       - Copy XCoord1,YCoord1 to XCoord2,YCoord2
*    IL_SMult        - Multiply two signed numbers
*    IL_SDiv         - Divide two signed numbers
*
*  Revision History:
*     2/26/89 - Original version written.
*     3/02/89 - Now calls GetPolyPnt & PushXY.
*     3/11/89 - Created delta table. Created a sorted edge list so that
*               concave and self-intersecting polygons will be drawn properly.
*     3/14/89 - Fixed bug. Now works properly with strange vertxes. Also
*               fixed to handle horizontal lines properly. Added EndList table.
*     3/15/89 - Bug fixes.
*     3/16/89 - More bug fixes. Lots of code optimizations
*     3/17/89 - Continued to optimize code.
*     4/25/89 - Now clips to the window instead of the viewport.
*     4/27/89 - Replaced viewport clipping.
*
***************************************************************************
*
GL_PaintPoly   START

               using GL_Tables

               longa on
               longi on
;
; Check number of polygon points and do specific polygon
;
               lda   [PolyPtr]          ;Get number of polygon vertexes
               sta   numvert
               bne   Pl1
;
; There are no points, or polygon is flagged invisible so quit
;
               rtl
;
; Polygon contains 1 point so simply plot a point
;
pl1            cmp   #1
               bne   pl2
               jsl   GL_GetPolyPnt
               jml   GL_Plot
;
; Polygon contains 2 points so draw a line segment
;
pl2            cmp   #2
               bne   pl3
               jsl   GL_GetPolyPnt
               jsl   GL_PushXY
               lda   #1
               jsl   GL_GetPolyPnt
               jml   GL_Line
;
; Polygon contains more than 2 points so draw an actual polygon
;
pl3            cmp   #32+1              ;Maximum 32 points
               bcc   pl4
               rtl
;
; build a delta table and find bounding scanlines
;
pl4            jsl   GL_GetPolyPnt
               sta   YMax
               sta   YMin
               ldx   #0
               lda   #1
delloop        sta   iv
               jsl   GL_PushXY
               jsl   GL_GetPolyPnt
               cmp   YMax
               bcc   fy1
               sta   YMax
fy1            cmp   YMin
               bcs   fy2
               sta   YMin
fy2            sec
               sbc   YCoord2
               sta   DeltaY,x
               sec
               lda   XCoord1
               sbc   XCoord2
               sta   DeltaX,x
               inx
               inx
               lda   iv
               inc   a
               cmp   numvert
               beq   delloop
               bcc   delloop
;
; Clip bounding scanlines, quit if invisible.
;
FindY          lda   YMax
               cmp   ViewTop
               bcs   fya
               rtl
fya            cmp   ViewBot
               bcc   fy4
               lda   ViewBot
               sta   YMax
fy4            lda   YMin
               cmp   ViewBot
               bcc   fyb
               beq   fyb
               rtl
fyb            cmp   ViewTop
               bcs   SLStart
               lda   ViewTop
               sta   YMin
;
;
SLStart        asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr
;
; Loop through each scan line find bounding X-coordinates for each scanline
;
SLLoop         stz   edges
               stz   index
               lda   numvert
               sta   iv
               lda   #1
;
; Loop through all line segments
;
XLoop          sta   nv
               jsl   GL_GetPolyPnt
               jsl   GL_PushXY
               lda   iv
               jsl   GL_GetPolyPnt
;
; Swap coordinates if necessary
;
               cmp   YCoord2
               bmi   NoSwap
               jsl   GL_SwapXY
               tya

NoSwap         cmp   YMin
               bpl   XL1
               lda   YCoord2
               cmp   YMin
               bmi   gonext
               lda   YCoord1
               cmp   YMin
               bmi   XL2
XL1            beq   XL2
               lda   YCoord2
               cmp   YMin
               bmi   XL2
               beq   XL2
gonext         jmp   Nextx
;
XL2            sec
               lda   YMin
               sbc   YCoord1
               sta   Arg1
               ldx   index
               lda   DeltaX,x
               beq   vert
               sta   Arg2
               lda   DeltaY,x
               beq   horz
               sta   DY
               jsl   IL_SMult
               sta   Arg1
               lda   DY
               sta   Arg2
               jsl   IL_SDiv
               clc
               adc   XCoord1
               bmi   nextx
               jmp   saveedge
;
horz           ldx   edges
               lda   XCoord1
               sta   EdgeList,x
               stz   EndList,x
               inx
               inx
               stz   EndList,x
               lda   XCoord2
               sta   EdgeList,x
               bra   se5
;
vert           lda   XCoord1
;
saveedge       ldx   edges
               sta   EdgeList,x
               lda   YCoord1
               cmp   YCoord2
               bmi   se2
               ldy   YCoord2
               sty   YCoord1
               sta   YCoord2
se2            ldy   YMin
               lda   #3
               cpy   YCoord1
               bne   se3
               lda   #1
               beq   se4
se3            cpy   YCoord2
               bne   se4
               lda   #2
se4            sta   EndList,x
se5            inx
               inx
               stx   edges
;
Nextx          inc   index
               inc   index
               lda   nv
               sta   iv
               inc   a
               cmp   numvert
               beq   nx
               bcs   sort
nx             jmp   XLoop
;
; sort the edge list
;
sort           sep   #$10
               longi off
               ldy   #0
loop1          tyx
loop2          lda   EdgeList,x
               cmp   EdgeList,y
               bpl   nextsort
               sta   iv
               lda   EdgeList,y
               sta   EdgeList,x
               lda   iv
               sta   EdgeList,y
               lda   EndList,x
               sta   iv
               lda   EndList,y
               sta   EndList,x
               lda   iv
               sta   EndList,y
nextsort       inx
               inx
               cpx   edges
               bcc   loop2
               iny
               iny
               cpy   edges
               bcc   loop1
               rep   #$10
               longi on
;
; Draw the horizontal lines
;
               lda   YMin
               sta   YCoord1
               stz   iv
DrawLoop       ldx   iv
               cpx   edges
               bcs   NextSL
               ldy   EdgeList,x
               sty   XCoord1
               lda   EndList,x
drwlup         inx
               inx
               cpx   edges
               bcs   NextSL
               ldy   EdgeList,x
               cpy   XCoord1            ;test if two points are the same
               bne   drawem
               and   EndList,x
               beq   drwlup
drawem         sty   XCoord2
               inx
               inx
               stx   iv
               lda   XCoord1
               cmp   ViewRight
               beq   Xchk1
               bcs   NextSeg
Xchk1          cmp   ViewLeft
               bcs   Xchk2
               lda   ViewLeft
               sta   XCoord1
Xchk2          lda   XCoord2
               cmp   ViewLeft
               bcc   NextSeg
               cmp   ViewRight
               bcc   Xchk3
               beq   Xchk3
               lda   ViewRight
               sta   XCoord2
Xchk3          jsl   GL_HLine3
NextSeg        jmp   DrawLoop
NextSL         inc   YMin
               lda   YMin
               cmp   YMax
               bcc   OKSL
               beq   OKSL
               rtl
OKSL           clc
               lda   ScanLinePtr
               adc   #160
               sta   ScanLinePtr
               jmp   SLLoop

numvert        ds    2
YMin           ds    2
YMax           ds    2
iv             ds    2
nv             ds    2
i              ds    2
j              ds    2
index          ds    2
DY             ds    2
edges          ds    2
DeltaX         ds    32*2
DeltaY         ds    32*2
EdgeList       ds    32*2
EndList        ds    32*2

               END

***************************************************************************
*
* Get the coordinates for a point in a polygon.
* Assumes integer coordinates
*
*  Entry Points:
*    GL_GetPolyPnt   - Get coordinates for polygon point
*
*  Inputs:
*    A               - The point to get coordinates from
*    PolyPtr         - Point to the polygon
*    PointPtr        - Point to the vertice table
*
*  Outputs:
*    XCoord1,YCoord1 - The polygon coordinates
*    Y               - unknown
*    A               - Y polygon coordinate
*    Carry flag      - Set if line segment is invisible.
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/02/89 - Original version written.
*     3/19/89 - Now sets the carry flag if a line segment is invisible.
*
***************************************************************************
*
GL_GetPolyPnt  START

               longa on
               longi on

               asl   a
               tay
               lda   [PolyPtr],y
               clc
               bpl   gpp
               eor   #$FFFF
               inc   a
               sec
gpp            php
               asl   a
               asl   a
               tay
               lda   [PointPtr],y
               sta   XCoord1
               iny
               iny
               lda   [PointPtr],y
               sta   YCoord1
               plp
               rtl

               END

***************************************************************************
*
* Get the coordinates for a point in a fixed-point polygon.
* Assumes fixed-point coordinates
*
*  Entry Points:
*    GL_GetPolyPntFi - Get coordinates for a fixed-point polygon point
*
*  Inputs:
*    A               - The point to get coordinates from
*    PolyPtr         - Point to the polygon
*    PointPtr        - Point to the vertice table
*
*  Outputs:
*    XCoord1,YCoord1 - The polygon coordinates
*    Y               - unknown
*    A               - Y polygon coordinate
*    Carry flag      - Set if line segment is invisible.
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/28/89 - Original version written.
*
***************************************************************************
*
GL_GetPolyPntFi START

               longa on
               longi on

               asl   a
               tay
               lda   [PolyPtr],y
               clc
               bpl   gpp
               eor   #$FFFF
               inc   a
               sec
gpp            php
               asl   a
               asl   a
               asl   a
               tay

               lda   [PointPtr],y
               sta   XCoord1
               iny
               iny
               lda   [PointPtr],y
               sta   XCoord1+2
               iny
               iny
               lda   [PointPtr],y
               sta   YCoord1
               iny
               iny
               lda   [PointPtr],y
               sta   YCoord1+2

               plp
               rtl

               END

***************************************************************************
*
* Copy integer XCoord1,YCoord1 to XCoord2,YCoord2
*
*  Entry Points:
*    GL_PushXY       - Copy XCoord1,YCoord1 to XCoord2,YCoord2
*
*  Inputs:
*    XCoord1,YCoord1 - Coordinates to copy from
*
*  Outputs:
*    XCoord2,YCoord2 - Coordinate to copy to
*    Y               - unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     3/02/89 - Original version written.
*     3/16/89 - Now modifies Y register instead of accumulator
*
***************************************************************************
*
GL_PushXY      START

               longa on
               longi on

               ldy   XCoord1
               sty   XCoord2
               ldy   YCoord1
               sty   YCoord2
               rtl

               END

***************************************************************************
*
* Find the bounding rectangle of a polygon.
* Assumes integer coordinates
*
*  Entry Points:
*    GL_BoundPoly    - Find the bounding rectangle of a polygon.
*
*  Inputs:
*    PolyPtr         - Pointer to polygon structure
*    PointPtr        - Pointer to pixel table used by polygon
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Bounding rectangle
*
*  External Procedures:
*    GL_GetPolyPnt   - Get coordinates for polygon point
*
*  Revision History:
*     4/27/89 - Original version written.
*     9/28/89 - Now works better with negative coordinates.
*
***************************************************************************
*
GL_BoundPoly   START

               longa on
               longi on

               lda   [PolyPtr]
               sta   v
               jsl   GL_GetPolyPnt
               sta   ymax
               sta   ymin
               lda   XCoord1
               sta   xmax
               sta   xmin
loop           dec   v
               beq   done
               lda   v
               jsl   GL_GetPolyPnt
               cmp   ymax
               bmi   y1
               sta   ymax
y1             cmp   ymin
               bpl   y2
               sta   ymin
y2             lda   XCoord1
               cmp   xmax
               bmi   x1
               sta   xmax
x1             cmp   xmin
               bpl   x2
               sta   xmin
x2             jmp   loop

done           lda   xmin
               sta   XCoord1
               lda   xmax
               sta   XCoord2
               lda   ymin
               sta   YCoord1
               lda   ymax
               sta   YCoord2

               rtl

ymax           ds    2
ymin           ds    2
xmax           ds    2
xmin           ds    2
v              ds    2

               END

***************************************************************************
*
* Find the bounding rectangle of a fixed-point polygon.
* Assumes fixed-point coordinates
*
*  Entry Points:
*    GL_BoundPolyFi  - Find the bounding rectangle of a fixed-point polygon.
*
*  Inputs:
*    PolyPtr         - Pointer to polygon structure
*    PointPtr        - Pointer to pixel table used by polygon
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2,
*    YCoord1,YCoord2 - Bounding rectangle
*
*  External Procedures:
*    GL_GetPolyPntFi - Get coordinates for fixed-point polygon point
*
*  Revision History:
*     9/28/89 - Original version written.
*
***************************************************************************
*
GL_BoundPolyFi START

               longa on
               longi on

               lda   [PolyPtr]
               sta   v
               jsl   GL_GetPolyPntFi
               lda   YCoord1
               sta   ymax
               sta   ymin
               lda   YCoord1+2
               sta   ymax+2
               sta   ymin+2
               lda   XCoord1
               sta   xmax
               sta   xmin
               lda   XCoord1+2
               sta   xmax+2
               sta   xmin+2

loop           dec   v
               bne   ll
               jmp   done
ll             lda   v
               jsl   GL_GetPolyPntFi

               ldy   YCoord1
               ldx   YCoord1+2
               cpx   ymax+2
               bmi   y1
               bne   y0
               cpy   ymax
               bmi   y1
y0             sty   ymax
               stx   ymax+2

y1             cpx   ymin+2
               beq   y2
               bpl   y3
               bra   yy
y2             cpy   ymin
               bpl   y3
yy             sty   ymin
               stx   ymin+2

y3             ldy   XCoord1
               ldx   XCoord1+2
               cpx   xmax+2
               bmi   x1
               bne   x0
               cpy   xmax
               bmi   x1
x0             sty   xmax
               stx   xmax+2

x1             cpx   xmin+2
               beq   x2
               bpl   x3
               bra   xx
x2             cpy   xmin
               bpl   x3
xx             sty   xmin
               stx   xmin+2

x3             jmp   loop

done           lda   xmin
               sta   XCoord1
               lda   xmin+2
               sta   XCoord1+2
               lda   xmax
               sta   XCoord2
               lda   xmax+2
               sta   XCoord2+2
               lda   ymin
               sta   YCoord1
               lda   ymin+2
               sta   YCoord1+2
               lda   ymax
               sta   YCoord2
               lda   ymax+2
               sta   YCoord2+2

               rtl

ymax           ds    4
ymin           ds    4
xmax           ds    4
xmin           ds    4
v              ds    2

               END

***************************************************************************
*
*  Convert a fixed-point polygon to an integer polygon.
*
*  Entry Points:
*    GL_Poly2In      - Convert poly from fixed point to integer.
*
*  Inputs:
*    GLParm          - Points to the table of vertices (^fixed)
*    PointPtr        - Location of converted vertices. (^integer)
*
*  Outputs:
*    PointPtr        - All transformed points are placed in this table (^int)
*    A,X             - Unknown
*    XCoord1         - Unknown
*    fArg1, Result   - Unknown
*
*  External Procedures:
*    FI_Fi2In        - Convert fixed-point to integer.
*
*  Revision History:
*     9/28/89 - Original version written.
*
***************************************************************************
*
GL_Poly2In     START

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
Loop           pha
               asl   a
               asl   a
               pha
               asl   a
               tay
               lda   [GLParm],y
               sta   fArg1
               iny
               iny
               lda   [GLParm],y
               sta   fArg1+2
               jsl   FI_Fi2In
               sta   XCoord1
               iny
               iny
               lda   [GLParm],y
               sta   fArg1
               iny
               iny
               lda   [GLParm],y
               sta   fArg1+2
               jsl   FI_Fi2In
               tax
               ply
               lda   XCoord1
               sta   [PointPtr],y
               iny
               iny
               txa
               sta   [PointPtr],y
               pla
               dec   a
               bne   Loop

               rtl

               END

***************************************************************************
*
*  Convert an integer polygon to a fixed-point polygon.
*
*  Entry Points:
*    GL_Poly2Fi      - Convert poly from integer to fixed-point.
*
*  Inputs:
*    GLParm          - Points to the table of vertices (^fixed)
*    PointPtr        - Location of converted vertices. (^integer)
*
*  Outputs:
*    PointPtr        - All transformed points are placed in this table (^int)
*    A,X             - Unknown
*    XCoord1,YCoord1 - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     9/28/89 - Original version written.
*
***************************************************************************
*
GL_Poly2Fi     START

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
Loop           pha
               asl   a
               asl   a
               tax
               tay
               lda   [GLParm],y
               sta   XCoord1
               iny
               iny
               lda   [GLParm],y
               sta   YCoord1
               txa
               asl   a
               tay
               lda   #0
               sta   [PointPtr],y
               iny
               iny
               lda   XCoord1
               sta   [PointPtr],y
               iny
               iny
               lda   #0
               sta   [PointPtr],y
               iny
               iny
               lda   YCoord1
               sta   [PointPtr],y
               pla
               dec   a
               bne   Loop

               rtl

               END
