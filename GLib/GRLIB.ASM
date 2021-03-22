              title 'GrafLib v1.00 - Written by Tim Meekins'
***************************************************************************
*                                                                         *
* GrafLib v1.00                                                           *
* Written by Tim Meekins                                                  *
* Copyright (C) 1989 by Tim Meekins                                       *
*                                                                         *
* This library contains numerous graphics primitives. These routines were *
* written  with  speed in mind  and take  many short-cuts at times for an *
* increase in speed. Almost all parameters are passed through direct page *
* locations  for an  efficient  interface.  Stack interfaces are much too *
* slow and complicated. Using Direct page locations, you can pass a value *
* once and have several routines use it w/o having to repass them all.    *
*                                                                         *
* There  are also  alternate  entry  points for  many of the routines for *
* increased  performance.  If the scanline  (y-coordinate) hasn't changed *
* since the last call,  there is no need  to calculate  the address of it *
* in memory,  since we  still have the old address which is valid.  There *
* is also times when we know that a certain  point lies on the screen and *
* does not need to be clipped, so most clipping operations can be skipped.*
*                                                                         *
* All routines expect that all registers are long, the 65816 is in native *
* mode and that the direct page register is properly set.                 *
*                                                                         *
* Entry Points:                                                           *
*   GL_BoundPoly     - Find the bounding rectangle of a an integer poly   *
*   GL_BoundPolyFi   - Find the bounding rectangle of a fixed-point poly  *
*   GL_ClipLine      - Clip a line segment                                *
*   GL_ClrScrn       - Clear Screen to color 0                            *
*   GL_FrameCircle   - Draw the frame of a circle.                        *
*   GL_FrameEllipse  - Draw the frame of an ellipse.                      *
*   GL_FramePoly     - Frame a polygon                                    *
*   GL_FramePoly2    - Frame a polygon w/o clipping                       *
*   GL_FrameRect     - Frame a rectangle                                  *
*   GL_FrameRect2    - Frame a rectangle w/o clipping                     *
*   GL_GetPolyPnt    - Get coordinates for an integr polygon point        *
*   GL_GetPolyPntFi  - Get coordinates for a fixed-point polygon point    *
*   GL_GetViewport   - Move Viewport to XCoord, YCoord                    *
*   GL_GetWindow     - Copy the window to XCoord, YCoord                  *
*   GL_GraphOff      - Turn graphics off                                  *
*   GL_GraphOn       - Turn graphics on                                   *
*   GL_HLine         - Draw a horizontal line                             *
*   GL_HLine2        - Draw a horizontal line w/o clipping                *
*   GL_HLine3        - Draw a horz line w/o clipping or calc. scanline    *
*   GL_InitMatrix    - Initialize a matrix.                               *
*   GL_Line          - Draw a line from X1,Y1 to X2,Y2                    *
*   GL_Line2         - Draw a line w/o clipping                           *
*   GL_MapPoint      - Map a point to the current viewport.               *
*   GL_MapPoly       - Map a polygon to the current viewport.             *
*   GL_PaintCircle   - Paint a solid circle.                              *
*   GL_PaintPoly     - Paint a polygon                                    *
*   GL_PaintRect     - Paint a rectangle                                  *
*   GL_PaintRect2    - Paint a rectangle w/o clipping                     *
*   GL_Plot          - Plot a dot at XCoord1, YCoord1                     *
*   GL_Plot2         - Plot a dot w/o clipping                            *
*   GL_Plot3         - Plot a dot w/o clipping or calculating scanline    *
*   GL_Poly2Fi       - Convert poly from integer to fixed-point.          *
*   GL_Poly2In       - Convert poly from fixed point to integer.          *
*   GL_PushXY        - Copy XCoord1,YCoord1 to XCoord2,YCoord2            *
*   GL_RestoreXY     - Restore integer Coordinates                        *
*   GL_RestoreXYFi   - Restore fixed-point Coordinates                    *
*   GL_Rotate        - Rotate an object.                                  *
*   GL_SaveXY        - Save integer Coordinates                           *
*   GL_SaveXYFi      - Save fixed-point Coordinates                       *
*   GL_Scale         - Scale an object.                                   *
*   GL_SetDefault    - Set default values for GrLib                       *
*   GL_SetPalette    - Set the palette to palette at [GLParm]             *
*   GL_SetViewport   - Create a new viewport definition                   *
*   GL_SetWindow     - Create a new window definition                     *
*   GL_SwapXY        - Swap Integer Coordinates                           *
*   GL_SwapXYFi      - Swap Fixed-Point Coordinates                       *
*   GL_TranslateXY   - Translate an object by X,Y.                        *
*   GL_TransPoint    - Transform a point.                                 *
*   GL_TransPoly     - Transform a poly.                                  *
*   GL_VLine         - Draw a vertical line                               *
*   GL_VLine2        - Draw a vertical line w/o clipping                  *
*   GL_XY2Fi         - Convert Coordinates to fixed-point                 *
*   GL_XY2In         - Convert Coordinates to integer                     *
*                                                                         *
***************************************************************************
*                                                                         *
* ====== REVISION HISTORY ======================================          *
*                                                                         *
* V1.00                                                                   *
*   2/14/89    Begin development and implementation of the library        *
*              routines. Many of the initial functions are adapted from   *
*              my SuperGR ][ program (SuperGR I appeared in Feb 1988      *
*              Issue of Nibble magazine). Wrote GraphOn, GraphOff, and    *
*              ClrScrn.                                                   *
*   2/16/89    Fixed major bug in GraphOn. Now works properly. Wrote      *
*              ScanLine Address table.                                    *
*   2/17/89    Assigned direct page locations. GraphOn now initializes    *
*              specific default values for many of these global variables *
*              such as the viewport. Wrote pixel plotting routine and     *
*              line drawing routine.                                      *
*   2/18/89    Optimization of line drawing routine. Wrote HLine routine. *
*   2/19/89    Optimization of HLine clipping. Wrote VLine routine.       *
*   2/20/89    Wrote PaintRect routine.                                   *
*   2/21/89    PaintRect restores coordinates now. Wrote FrameRect.       *
*              Updated direct page. Wrote SetPalette and SetDefault.      *
*              Restructured GraphOn. Moved palette to GL_DPalette in      *
*              global data area. Wrote FramePoly.                         *
*   2/24/89    Added IntLib support. Wrote ClipLine segment routine.      *
*              Line now calls ClipLine first.                             *
*   2/25/89    Tested and optimized ClipLine. Added no clipping entry to  *
*              Line and did additonal optimization. Line also calls       *
*              HLine and VLine as special cases. Optimized FramePoly.     *
*   2/26/89    Reduced amount of code for ClipLine by 50%. Wrote          *
*              PaintPoly routine. Fixed bug in ClipLine.                  *
*   2/27/89    Fixed bug in ClipLine, invisble lines were being drawn.    *
*   3/02/89    Minor optimization in ClipLine. Began removing redundant   *
*              code. Created: SaveXY, RestoreXY, SwapXY, GetPolyPnt,      *
*              PushXY. Modified: Line, Line2, PaintRect, PaintRect2,      *
*              FrameRect, FrameRect2, ClipLine, FramePoly, PaintPoly.     *
*   3/09/89    Optimized overhead in Line.                                *
*   3/11/89    Fixed bug in VLine2. Added delta table to PaintPoly.       *
*              Created sotyed edge list to PaintPoly, will now draw       *
*              concave and self-intersecting polygons.                    *
*   3/14/89    Fixed bugs in PaintPoly.                                   *
*   3/15/89    Bug fixes in PaintPoly.                                    *
*   3/16/89    More bug fixes and code optimizations in PaintPoly.        *
*   3/17/89    Optimized PaintPoly.                                       *
*   3/19/89    Modified FramePoly and GetPolyPnt to allow invisible line- *
*              segments.                                                  *
*   4/24/89    Minor optimizations in line clipping routines.             *
*   4/25/89    Viewport coordinates are no longer accessible as direct    *
*              page locations. Moved to GL_Tables. All clipping is now    *
*              done in the window instead of the viewport. Modified Plot, *
*              ClipLine, HLine, VLine, PaintRect, and PaintPoly.          *
*              SetDefault now initializes the window. Wrote WindXY,       *
*              Window, and Viewport.                                      *
*   4/26/89    Wrote MapPoint and MapPoly. Fixed bug in Window.           *
*   4/27/89    Big Time BooBoo. Clipping is now done in the viewport as   *
*              it did originally. Backwards viewports will not be allowed *
*              modified Viewport. Wrote BoundPoly.                        *
*   4/28/89    Added matrix information to the equate file.               *
*   4/29/89    Wrote InitMatrix, TransPoint, TransPoly.                   *
*   4/30/89    Optimized TransPoint. Interchanged the meaning of GLParm   *
*              PointPtr in TransPoly. Renamed Window, Viewport, ViewXY,   *
*              and WindXY to SetWindow, SetViewport, GetViewport, and     *
*              GetWindow respectively. Wrote TranslateXY and Scale.       *
*   5/04/89    Wrote Rotate. Some bug fixes in ClipLine.                  *
*   5/05/89    Wrote FramePoly2.                                          *
*   9/04/89    Instead of always drawing to the graphics buffer in bank   *
*              $E1, GraphLib can draw to the buffer in any bank.          *
*   9/22/89    Fixed bug in GraphOn.                                      *
*   9/23/89    Removed code to draw in any bank. Too many problems.       *
*   9/27/89    Began work on adding additional routines for fixed-point   *
*              graphics. Changed variable storage space to 4 bytes. Wrote *
*              SwapXYFi, RestoreXYFi, SaveXYFi. Modified SetWindow,       *
*              GetWindow, MapPoint, MapPoly, TransPoint, TransPoly, &     *
*              TranslateXY. Wrote XY2Fi,XY2In                             *
*   9/28/89    Modifed SetDefault. Wrote Poly2In, Poly2Fi, BoundPolyFi,   *
*              GetPolyPntFi.                                              *
*   9/29/89    Wrote FrameCircle and PaintCircle.                         *
*   9/30/89    Wrote FrameEllipse but it does not work properly.          *
*                                                                         *
***************************************************************************

               copy  filib.equ
               copy  inlib.equ
               copy  grlib.equ

***************************************************************************
*
* Dummy segment. Contains version number and copyright information
*
***************************************************************************

GRLIB          DATA
               dc    c'GrLib v1.00 written by Tim Meekins Copyright 1989'
               END

***************************************************************************
*
*  Display the Super Hi-Res Display in 320 mode and initialize any necessary
*  Variables. Calls clear screen on exit.
*
*  Entry Points:
*    GL_GraphOn      - Display the graphics screen
*
*  Inputs:
*    none
*
*  Outputs:
*    A,X,Y registers - Unknown
*    Many global variables set to default variables
*
*  External Procedures:
*    GL_ClrScrn      - Clear the screen
*    GL_SetDefault   - Set default values
*
*  Revision History:
*     2/14/89 - Original version written.
*     2/16/89 - Fixed major bug.
*     2/21/89 - Moved palette initialization and direct page initialization
*               to separate routines. GraphOn simply make calls to them now.
*     9/04/89 - Now works with different banks.
*     9/22/89 - Fixed bug. ScanLinePtr was accessed before it was initialized.
*     9/23/89 - Removed code for different banks
*
***************************************************************************
*
GL_GraphOn     START

               longa on
               longi on
;
; Setup defualt values
;
               jsl   GL_SetDefault
;
;
               sep   #$30               ;Use short registers
               longa off
               longi off
;
;  Turn on the graphics screen. Note that I'm NOT following Apple's way of
;  doing things by not using TSB & TRB. This will need to be changed so as
;  to be compatible with future machines.
;
               lda   #$C1
               sta   $E0C029
;
;  Set up the Scan-Line Control Bytes (SCB) for each line. These bytes set
;  The resolution of each line to 320 pixels x 16 colors. We will be using
;  the default palette (#0). No interrupts generated.
;
               lda   #0
               ldx   #200
InitSCB        sta   $E19CFF,x
               dex
               bne   InitSCB

               rep   #$30               ;Go back to long registers
               longa on                 ; so that ClrScrn won't get mad
               longi on
;
; Clear screen and exit
;
               jml   GL_ClrScrn

               END

***************************************************************************
*
* Turn the Super Hi-Res screen off and return the computer display to its
* previous state. This DOES NOT necessarily mean you'll go back into text!!
*
*  Entry Points:
*    GL_GraphOff     - Return the computer to its previous display mode
*
*  Inputs:
*    none
*
*  Outputs:
*    Accumulator contains $1 in the least significant byte
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/14/89 - Original version written.
*
***************************************************************************
*
GL_GraphOff    START

               sep   #$20               ;Set short registers
               longa off
;
;  Turn the super hi-res screen off. NOTE: I'm not following Apple's
;  Recommendations on how to do this. This will need to be changed to a
;  TRB for future compatibility with Apple products.
;
               lda   #1
               sta   $E0C029

               rep   #$20               ;Reset to long registers
               longa on

               rtl

               END

***************************************************************************
*
* Setup default for graphics library
*
*  Entry Points:
*    GL_SetDefault   - Set default values for GrLib
*
*  Inputs:
*    none
*
*  Outputs:
*    A,X,Y registers - Unknown
*    GLParm          - Points to default palette
*    Other direct page locations set to default values
*
*  External Procedures:
*    GL_SetPalette   - Set palette
*
*  Revision History:
*     2/21/89 - Original version written.
*     4/25/89 - Now initializes the window.
*     9/04/89 - Modified to work with different banks.
*     9/23/89 - Removed code for different banks.
*     9/28/89 - Now uses fixed-point window definition.
*
***************************************************************************
*
GL_SetDefault  START

               using GL_Tables

               longa on
               longi on
;
; Initialize global variables
;
               lda   #$FFFF
               sta   Pattern
               stz   ViewLeft
               stz   WindLeft
               stz   WindLeft+2
               stz   ViewTop
               stz   WindTop
               stz   WindTop+2
               lda   #199
               sta   ViewBot
               stz   WindBot
               sta   WindBot+2
               sta   ViewHeight
               stz   WindHeight
               sta   WindHeight+2
               lda   #319
               sta   ViewRight
               stz   WindRight
               sta   WindRight+2
               sta   ViewWidth
               stz   WindWidth
               sta   WindWidth+2
               stz   XCoord1
               stz   XCoord1+2
               stz   YCoord1
               stz   YCoord1+2
               stz   XCoord2
               stz   XCoord2+2
               stz   YCoord2
               stz   YCoord2+2
               lda   #$2000
               sta   ScanLinePtr
               lda   #$00E1
               sta   ScanLinePtr+2
;
; initialize default palette
;
               lda   #<GL_DPalette
               sta   GLParm
               lda   #^GL_DPalette
               sta   GLParm+2
               jml   GL_SetPalette

               END

***************************************************************************
*
* Copy a palette into the pictures palette storage area
*
*  Entry Points:
*    GL_SetPalette   - Set the palette to palette at [GLParm]
*
*  Inputs:
*    GLParm          - Pointer to pallete
*
*  Outputs:
*    A,Y registers   - Unknown
*    X               - Unchanged
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/21/89 - Original version written.
*     9/04/89 - Modified to work with multiple banks.
*     9/23/89 - Removed code for different banks.
*
***************************************************************************
*
GL_SetPalette  START

               sep   #$30
               longa off
               longi off

               ldy   #$1F
               tyx
CopyPalette    lda   [GLParm],y
               sta   $E19E00,x
               dey
               dex
               bpl   CopyPalette

               rep   #$30
               rtl

               END

***************************************************************************
*
* Clear the entire screen to the color black
*
*  Entry Points:
*    GL_ClrScrn      - Clear the screen to black
*
*  Inputs:
*    none
*
*  Outputs:
*    x register      - unknown (actually $0-$2 = $FFFE)
*    accumulator     - buffer bank
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/14/89 - Original version written.
*     9/04/89 - Modified to work with multiple banks.
*     9/23/89 - Removed code for multiple banks.
*
***************************************************************************
*
GL_ClrScrn     START

               longa on
               longi on
;
;  Set the data bank to $E1 so we can avoid long addressing.
;  This will save us one machine cycle for every two bytes stored in the screen.
;  Also allows us to use an STZ instead of STA, so we save a couple of bytes of
;  code.
;
               phb                      ;Save data bank so we can change it
               pea   $E1E1
               plb                      ;I know it looks weird, but it
               plb                      ; really does work!
;
;  Put lots of zeros in the screen memory. We use multiple inline STZs
;  to help speed things up. For more speed, just add more STZs and decrease
;  the initial value of X.
;
               ldx   #$F9E
BigLoop        stz   $2000,x
               stz   $2FA0,x
               stz   $3F40,x
               stz   $4EE0,x
               stz   $5E80,x
               stz   $6E20,x
               stz   $7DC0,x
               stz   $8D60,x
               dex                      ;STZ is storing 2 bytes of zeros so
               dex                      ; we decrement by 2.
               bpl   BigLoop

               plb                      ;All done, so restore Data Bank Reg

               rtl

               END

***************************************************************************
*
* Plot a dot at XCoord1,YCoord1. Note: If you plot a dot w/o clipping and the
* pixel lies off of the screen, GL_Plot will still try to plot the dot, possibly
* corrupting the memory and picture.
* Assume integer coordinates
*
*  Entry Points:
*    GL_Plot         - Plot a dot at XCoord, YCoord
*    GL_Plot2        - Plot a dot w/o clipping
*    GL_Plot3        - Plot a dot w/o clipping or calculating scanline
*
*  Inputs:
*    XCoord1,YCoord1 - Coordinate of pixel to plot
*    Pattern         - Pattern to draw in
*    ScanLinePtr     - Scaline address if calling GL_Plot3
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    ScanLinePtr     - Points to scan line address of pixel
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/17/89 - Original version written.
*     4/25/89 - Point clipping is now done in the window instead of
*               the viewport.
*     4/27/89 - Now clips to the viewport again.
*
***************************************************************************
*
GL_Plot        START
               using GL_Tables

               longa on
               longi on
;
; First off, check and see if the pixel is in the viewport, and if it isn't
; then quit.
;
               lda   XCoord1
               cmp   ViewRight
               beq   PC1
               bcs   PExit
PC1            cmp   ViewLeft
               bmi   PExit
               bcc   PExit
               lda   YCoord1
               cmp   ViewBot
               beq   PC2
               bcs   PExit
PC2            cmp   ViewTop
               bcc   PExit
;
GL_Plot2       ENTRY
;
; Calculate the scanline address for this y coordinate
;
               lda   YCoord1
               asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr
;
GL_Plot3       ENTRY
;
; Check if scanline is odd or even then find offset into pattern
;
               lda   YCoord1
               and   #1
               tax
;
; Plot the dot
;
               ldy   XCoord1
               sep   #$20
               lda   Pattern,x
               and   GL_Mask,y
               sta   Color
               rep   #$20
               tya
               lsr   a
               tax
               sep   #$20
               lda   GL_Mask+1,y
               txy
               and   [ScanLinePtr],y
               ora   Color
               sta   [ScanLinePtr],y
               rep   #$20

PExit          rtl

color          ds    1

               END

***************************************************************************
*
* Draw a line from XCoord1,YCoord1 to XCoord2,YCoord2
* Assume integer coordinates.
*
*  Entry Points:
*    GL_Line         - Draw a line
*    GL_Line2        - Draw a line w/o clipping
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Starting and ending point of line
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    ScanLinePtr     - Unknown
*    GL_X1,X2,Y1,Y2  - Same XCoord,YCoord
*
*  External Procedures:
*    GL_ClipLine     - Clip the line segment
*    GL_Plot3        - Plot a dot
*    GL_HLine2       - Draw a horizontal line w/o clipping
*    GL_VLine2       - Draw a vertical line w/o clipping
*    GL_SaveXY       - Save coordinates
*    GL_RestoreXY    - Restore coordinates
*    GL_SwapXY       - Swap Coordinates
*
*  Revision History:
*     2/17/89 - Original version written.
*     2/18/89 - Optimized code.
*     2/24/89 - Now calls ClipLine
*     2/25/89 - Added new nonclipping entry point. More optimization, now
*               calls VLine if vertical line and HLine if it's horizontal
*     3/02/89 - Now calls GL_SaveXY, GL_RestoreXY, and GL_SwapXY.
*     3/09/89 - Removed call to Plot2 and directly calculated scanline addr.
*               Other optimizations done to overhead portion.
*
***************************************************************************
*
GL_Line        START

               using GL_Tables

               longa on
               longi on
;
; Save off our endpoints so that we can restore them later. The line routine
; may interchange their values and they may change throughtout the drawing
; process. We can also clip before plotting, yet return the original values;
; this may be very important for some applications.
;
               jsl   GL_SaveXY
;
; Clip the line segment
;
               jsl   GL_ClipLine
               bcc   OK
               jml   GL_RestoreXY              ;Invisible so don't draw, quit
;
; No Clipping entry point
;
GL_Line2       ENTRY

               jsl   GL_SaveXY
;
; This algorithm is based on the bresenham algorithm. This means we must write
; a section of code for a line appearing in each of 8 separate octants.
; If you study these lines well enough, you'll know that by swapping
; endpoints you'll be drawing a line in the opposite octant. Thus, by
; symmetry, we only need to implement the code for 4 of the 8 octants.
; the following section finds the other 4 octants and swaps their endpoints
; if necessary.
;
OK             sec
               lda   XCoord2
               sbc   XCoord1
               beq   vert
               bvs   Inv
               bmi   Swap
               jmp   L1a
vert           jsl   GL_VLine2
               jml   GL_RestoreXY
horz           jsl   GL_HLine2
               jml   GL_RestoreXY
Inv            bmi   L1a
Swap           jsl   GL_SwapXY
               sec
               lda   XCoord2
               sbc   XCoord1
L1a            sta   DX
               lda   YCoord1
               asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr
               sec
               lda   YCoord2
               sbc   YCoord1
               beq   horz
               sta   DY
               bmi   L2
               cmp   DX
               bcc   Oct10
               beq   Oct10
               jmp   Oct20
L2             eor   #$FFFF
               inc   a
               cmp   DX
               bcc   L7
               beq   L7
               jmp   Oct70
L7             jmp   Oct80
;
; Draw octant 1.
;   If error is negative, move +x and add DY to error
;   If error is positive, move +x +y diagonal and add DY-DX to error
;
Oct10          lda   DX
               sta   Count
               bmi   L3
               lsr   a
               eor   #$FFFF
               inc   a
               jmp   L3a
L3             eor   #$FFFF
               inc   a
               lsr   a
L3a            sta   Error
Oct11          jsl   GL_Plot3
               dec   Count
               bmi   Done
Oct12          inc   XCoord1
               clc
               lda   Error
               adc   DY
               bmi   L3a
               sec
               sbc   DX
               sta   Error
               inc   YCoord1
               lda   ScanLinePtr
               clc
               adc   #160
               sta   ScanLinePtr
               jmp   Oct11
;
; Draw octant 2.
;   If error is negative, move +x +y diagonal, and add DY-DX to error
;   If error is positive, move +y and subtract DX from error.
;
Oct20          lda   DY
               sta   Count
               bmi   L4
               lsr   a
               eor   #$FFFF
               inc   a
               jmp   L4a
L4             sec
               lda   #0
               sbc   Error
               lsr   a
L4a            sta   Error
Oct21          jsl   GL_Plot3
               dec   Count
               bmi   Done
Oct22          inc   YCoord1
               clc
               lda   ScanLinePtr
               adc   #160
               sta   ScanLinePtr
               clc
               lda   Error
               adc   DX
               bmi   L4a
               sec
               sbc   DY
               inc   XCoord1
               jmp   L4a
;
; Restore endpoints and quit.
;
done           jml   GL_RestoreXY
;
; Draw octant 7.
;   If error negative, move +x -y diagonal and subtract DY+DX from error
;   IF error positive, move -y and subtract DX from error
;
Oct70          sec
               lda   #0
               sbc   DY
               sta   Count
               lda   DY
               bmi   L5
               lsr   a
               jmp   L5a
L5             sec
               ror   a
L5a            sta   Error
Oct71          jsl   GL_Plot3
               dec   Count
               bmi   Done
Oct72          dec   YCoord1
               sec
               lda   ScanLinePtr
               sbc   #160
               sta   ScanLinePtr
               clc
               lda   Error
               adc   DX
               bmi   L5a
               clc
               adc   DY
               inc   XCoord1
               jmp   L5a
;
; Draw octant 8.
;    If error is negative, move +x and subtract DY from error
;    If error is positive, move +x -y diagonal and subtract DY+DX from error
;
Oct80          lda   DX
               sta   Count
               bmi   L6
               lsr   a
               eor   #$FFFF
               inc   a
               jmp   L6a
L6             eor   #$FFFF
               inc   a
               lsr   a
L6a            sta   Error
Oct81          jsl   GL_Plot3
               dec   Count
               bmi   Done
Oct82          inc   XCoord1
               sec
               lda   Error
               sbc   DY
               bmi   L6a
               sec
               sbc   DX
               sta   Error
               dec   YCoord1
               sec
               lda   ScanLinePtr
               sbc   #160
               sta   ScanLinePtr
               jmp   Oct81
;
; Variables used by line drawing routine
;
Error          ds    2
Count          ds    2
DX             ds    2
DY             ds    2

               END

***************************************************************************
*
* Clips a line segment within the current viewport.
* Assumes integer coordinates.
*
*  Entry Points:
*    GL_ClipLine     - Clip a line segment
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Starting and ending point of line
*    ViewXXX         - Viewport for clipping
*
*  Outputs:
*    Carry set if line is invisible
*    A,X,Y unknown
*    XCoord1,etc... are clipped
*    Arg1, Arg2, Result - unknown
*
*  External Procedures:
*    IL_SMult        - Signed Multiply
*    IL_SDiv         - Signed Division
*    GL_SwapXY       - Swap coordinates
*
*  Revision History:
*     2/24/89 - Original version written.
*     2/25/89 - Tested and optimized
*     2/26/89 - Reduced code by 50%
*     2/27/89 - Fixed, invisible lines weren't
*     3/02/89 - Minor optimization. Now makes call to GL_SwapXY
*     4/24/89 - Minor optimizations performed
*     4/25/89 - Now clips to the window instead of the viewport.
*     4/27/89 - Replaced clipping in the window.
*     5/04/89 - Modified comparison routines.
*
***************************************************************************
*
GL_ClipLine    START

               using GL_Tables

               longa on
               longi on

;
; dx = xcoord2-xcoord1; dy = ycoord2-ycoord1;
;
               sec
               lda   XCoord2
               tax
               sbc   XCoord1
               sta   DX
               sec
               lda   YCoord2
               tay
               sbc   YCoord1
               sta   DY

               sep   #$20
               longa off

               jsr   EndPoint
               sta   Code2

while          sep   #$20
               ldx   XCoord1
               ldy   YCoord1
               jsr   EndPoint
               sta   Code1
;
; while (code1 | code2) else line is visable and properly clipped
;
               ora   Code2
               bne   wh
               rep   #$21
               rtl
;
; if (code1 & code2) return;   line is invisible
;
wh             lda   Code1
               and   Code2
               beq   delta
               rep   #$20
               sec
               rtl
;
; if (code1)
;
delta          lda   Code1
               bne   cd1
               jsl   GL_SwapXY
               lda   Code2
               sta   Code1
               stz   Code2
;
; if (x1 < viewleft) { y1 += dy*(viewleft-x1)/dx; x1=viewleft; } else
;
               longa off
cd1            and   #%1000
               beq   cd2
               rep   #$20
               longa on
               sec
               lda   ViewLeft
               sbc   XCoord1
               sta   Arg2
               lda   DY
               sta   Arg1
               jsl   IL_SMult
               sta   Arg1
               lda   DX
               sta   Arg2
               jsl   IL_SDiv
               clc
               adc   YCoord1
               sta   YCoord1
               lda   ViewLeft
               sta   XCoord1
               jmp   while
;
; if (x1 > viewright) { y1 += dy*(viewright-x1)/dx; x1=viewright; } else
;
               longa off
cd2            lda   Code1
               and   #%0100
               beq   cd3
               rep   #$20
               longa on
               sec
               lda   ViewRight
               sbc   XCoord1
               sta   Arg2
               lda   DY
               sta   Arg1
               jsl   IL_SMult
               sta   Arg1
               lda   DX
               sta   Arg2
               jsl   IL_SDiv
               clc
               adc   YCoord1
               sta   YCoord1
               lda   ViewRight
               sta   XCoord1
               jmp   while
;
; if (y1 < viewtop) { x1 += dx*(viewtop-y1)/dy; y1=viewtop; } else
;
               longa off
cd3            lda   Code1
               and   #%0010
               beq   cd4
               rep   #$20
               longa on
               sec
               lda   ViewTop
               sbc   YCoord1
               sta   Arg2
               lda   DX
               sta   Arg1
               jsl   IL_SMult
               sta   Arg1
               lda   DY
               sta   Arg2
               jsl   IL_SDiv
               clc
               adc   XCoord1
               sta   XCoord1
               lda   ViewTop
               sta   YCoord1
               jmp   while
;
; if (y1 < viewbot) { x1 += dx*(viewbot-y1)/dy; y1=viewbot; } else
;
cd4            rep   #$20
               longa on
               sec
               lda   ViewBot
               sbc   YCoord1
               sta   Arg2
               lda   DX
               sta   Arg1
               jsl   IL_SMult
               sta   Arg1
               lda   DY
               sta   Arg2
               jsl   IL_SDiv
               clc
               adc   XCoord1
               sta   XCoord1
               lda   ViewBot
               sta   YCoord1
cd5            jmp   while
;
; Calculate the endpoint code for a pixel (X & Y Reg). Code is returned in A
; On entry, A is short and X,Y are long
;
EndPoint       longa off
               lda   #0
               cpx   ViewLeft
               bpl   EP1
               ora   #%1000
               bne   EP2
EP1            cpx   ViewRight
               bmi   EP2
               beq   EP2
               ora   #%0100

EP2            cpy   ViewTop
               bpl   EP3
               ora   #%0010
               bne   EP4
EP3            cpy   ViewBot
               bmi   EP4
               beq   EP4
               ora   #%0001
EP4            rts

DX             ds    2                  ;Change in X
DY             ds    2                  ;Change in Y
Code1          ds    1                  ;Code for point 1
Code2          ds    1                  ;Code for point 2

               END

***************************************************************************
*
* Draw a horizontal line from XCoord1 to XCoord2 at YCoord1
* Assumes integer coordinates.
*
*  Entry Points:
*    GL_HLine        - Draw a horizontal line
*    GL_HLine2       - Draw a horizontal line w/o clipping
*    GL_HLine3       - Draw a horizontal line w/o clipping or calc. scanline
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2         - Starting and ending point of line
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    XCoord1,XCoord2 - Modified if GL_HLine called, unchanged if
*                      GL_HLine2 or GL_HLine3 called
*    ScanLinePtr     - Address of scanline the line was on
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/18/89 - Original version written.
*     2/19/89 - Optimized clipping routine.
*     4/25/89 - Now clips to the window instead of the viewport.
*     4/27/89 - Clips in the viewport again.
*
***************************************************************************
*
GL_HLine       START
               using GL_Tables

               longa on
               longi on

               lda   XCoord1
               bmi   HL1B
               ldx   XCoord2
               cpx   XCoord1
               bcs   HL1
               stx   XCoord1
               sta   XCoord2
               txa
HL1            cmp   ViewRight
               beq   HL1A
               bcs   HLQuit
HL1A           cmp   ViewLeft
               bcs   HL2
HL1B           lda   ViewLeft
               sta   XCoord1
HL2            lda   XCoord2
               bmi   HLQuit
               cmp   ViewLeft
               bcc   HLQuit
               cmp   ViewRight
               bcc   HL3
               lda   ViewRight
               sta   XCoord2
               jmp   HL3
HLQuit         rtl
HL3            lda   YCoord1
               cmp   ViewTop
               bcc   HLQuit
               cmp   ViewBot
               beq   HL3A
               bcs   HLQuit

GL_HLine2      ENTRY

;
; Calculate scanline address
;
               lda   YCoord1
HL3A           asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr

GL_Hline3      ENTRY

;
; Calculate the left mask and byte offset
;
               lda   XCoord1
               tax
               lsr   a
               sta   LeftByte
               lda   GL_Mask,x
               ora   #%0000111100001111
               sta   LeftMask
;
; Calculate the right mask and byte offset
;
               lda   XCoord2
               tax
               lsr   a
               sta   RightByte
               lda   GL_Mask,x
               ora   #%1111000011110000
               sta   RightMask
;
; Find pattern offset
;
               lda   YCoord1
               and   #1
               tax
;
; Check if left and right byte offsets are the same
;
               ldy   RightByte
               cpy   LeftByte
               bne   DoLine
;
; Special case: Line is one pixel long
;
               sep   #$20
               longa off
               lda   LeftMask
               and   RightMask
               sta   LeftMask
               and   Pattern,x
               sta   PCol
               lda   LeftMask
               eor   #$FF
               and   [ScanLinePtr],y
               ora   PCol
               sta   [ScanLinePtr],y
               rep   #$20
               longa on
               rtl
;
; Draw the line
;
DoLine         sep   #$20
               longa off
               lda   [ScanLinePtr],y
               eor   Pattern,x
               and   RightMask
               eor   [ScanLinePtr],y
               bra   DoLine2
DoLine1        lda   Pattern,x
DoLine2        sta   [ScanLinePtr],y
               dey
               cpy   LeftByte
               bne   DoLine1
               lda   [ScanLinePtr],y
               eor   Pattern,x
               and   LeftMask
               eor   [ScanLinePtr],y
               sta   [ScanLinePtr],y
               rep   #$20
               longa on
               rtl
;
; Data used by HLine
;
LeftByte       ds    2
RightByte      ds    2
LeftMask       ds    2
RightMask      ds    2
PCol           ds    1

               END

***************************************************************************
*
* Draw a vertical line from YCoord1 to YCoord2 at XCoord1
* Assume integer coordinates.
*
*  Entry Points:
*    GL_VLine        - Draw a vertical line
*    GL_VLine2       - Draw a vertical line w/o clipping
*
*  Inputs:
*    XCoord1,YCoord1,
*    YCoord2         - Starting and ending point of line
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    YCoord1,YCoord2 - Modified if GL_VLine called, unchanged if
*                      GL_VLine2 called
*    ScanLinePtr     - Unknown
*
*  External Procedures:
*    none
*
*  Revision History:
*     2/19/89 - Original version written.
*     3/11/89 - If VLine2 was called with YCoord1 > YCoord2, now line
*               was drawn, VLine2 now swaps coordinates if nec.
*     4/25/89 - Now clips to the window instead of the viewport.
*     4/27/89 - Clips in the viewport again.
*
***************************************************************************
*
GL_VLine       START

               using GL_Tables
               longa on
               longi on

               lda   YCoord1
               bmi   VL1B
               ldx   YCoord2
               cpx   YCoord1
               bcs   VL1
               stx   YCoord1
               sta   YCoord2
               txa
VL1            cmp   ViewBot
               beq   VL1A
               bcs   VLQuit
VL1A           cmp   ViewTop
               bcs   VL2
VL1B           lda   ViewTop
               sta   YCoord1
VL2            lda   YCoord2
               cmp   ViewTop
               bcc   VLQuit
               cmp   ViewBot
               bcc   VL3
               lda   ViewBot
               sta   YCoord2
               jmp   VL3
VLQuit         rtl
VL3            lda   XCoord1
               cmp   ViewLeft
               bcc   VLQuit
               cmp   ViewRight
               beq   VL3A
               bcs   VLQuit

GL_Vline2      ENTRY

               sec
               lda   YCoord2
               tay
               sbc   YCoord1
               bpl   VL3B
               ldx   YCoord1
               stx   YCoord2
               sty   YCoord1

VL3A           sec
               lda   YCoord2
               sbc   YCoord1
VL3B           sta   Count

               lda   YCoord1
               asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr

               ldy   XCoord1
               lda   YCoord1
               and   #1
               tax

               sep   #$20
               longa off
               lda   Pattern,x
               and   GL_Mask,y
               sta   PCol
               rep   #$20
               longa on
               txa
               eor   #1
               tax
               sep   #$20
               longa off
               lda   Pattern,x
               and   GL_Mask,y
               sta   PCol+1
               rep   #$20
               tyx
               txa
               lsr   a
               tay

VLoop          sep   #$20
               lda   GL_Mask,x
               eor   #$FF
               and   [ScanLinePtr],y
               ora   PCol
               sta   [ScanLinePtr],y
               rep   #$20
               longa on
               lda   PCol
               xba
               sta   PCol
               clc
               lda   ScanLinePtr
               adc   #160
               sta   ScanLinePtr
               dec   Count
               bpl   VLoop
               rtl

Count          ds    2
PCol           ds    2

               END

***************************************************************************
*
* Paint a rectangle. Upper-left is X1,Y1 and lower-right is X2,Y2
* Assumes coordinates are integer.
*
*  Entry Points:
*    GL_PaintRect    - Paint a rectangle
*    GL_PaintRect2   - Paint a rectangle w/o clipping
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Boundary coordinates of rectangle
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    ScanLinePtr     - Unknown
*    GL_X1,X2,Y1,Y2  - Same XCoord...
*
*  External Procedures:
*    GL_HLine3       - Draw a horizontal line w/o clipping
*    GL_SaveXY       - Save coordinates
*    GL_RestoreXY    - Restores coordinates
*
*  Revision History:
*     2/20/89 - Original version written.
*     3/02/89 - Now calls GL_SaveXY & GL_RestoreXY.
*     4/25/89 - Now clips to the window instead of the viewport.
*     4/27/89 - Clips to the viewport again.
*
***************************************************************************
*
GL_PaintRect   START

               using GL_Tables
               longa on
               longi on

               jsl   GL_SaveXY
;
; Clip Y Coordinates
;
               lda   YCoord1
               bmi   VL1B
               ldx   YCoord2
               cpx   YCoord1
               bcs   VL1
               stx   YCoord1
               sta   YCoord2
               txa
VL1            cmp   ViewBot
               beq   VL1A
               bcs   VLQuit
VL1A           cmp   ViewTop
               bcs   VL2
VL1B           lda   ViewTop
               sta   YCoord1
VL2            lda   YCoord2
               cmp   ViewTop
               bcc   VLQuit
               cmp   ViewBot
               bcc   VL3
               lda   ViewBot
               sta   YCoord2
               jmp   VL3

VLQuit         jml   GL_RestoreXY
;
; Clip X Coordinates
;
VL3            lda   XCoord1
               bmi   HL1B
               ldx   XCoord2
               cpx   XCoord1
               bcs   HL1
               stx   XCoord1
               sta   XCoord2
               txa
HL1            cmp   ViewRight
               beq   HL1A
               bcs   VLQuit
HL1A           cmp   ViewLeft
               bcs   HL2
HL1B           lda   ViewLeft
               sta   XCoord1
HL2            lda   XCoord2
               bmi   VLQuit
               cmp   ViewLeft
               bcc   VLQuit
               cmp   ViewRight
               bcc   HL3
               lda   ViewRight
               sta   XCoord2
               jmp   HL3

GL_PaintRect2  ENTRY
               jsl   GL_SaveXY

;
; Calculate scanline address
;
HL3            lda   YCoord1
               asl   a
               tay
               lda   GL_SLAdr,y
               sta   ScanLinePtr
;
; Draw the rectangle
;
               sec
               lda   YCoord2
               sbc   YCoord1
               sta   Count

Loop           jsl   GL_Hline3
               clc
               lda   ScanLinePtr
               adc   #160
               sta   ScanLinePtr
               inc   YCoord1
               dec   Count
               bpl   Loop
               jml   GL_RestoreXY

Count          ds    2

               END

***************************************************************************
*
* Draw a rectangle frame. Upper-left is X1,Y1 and lower-right is X2,Y2
* Assumes integer coordinates.
*
*  Entry Points:
*    GL_FrameRect    - Frame a rectangle
*    GL_FrameRect2   - Frame a rectangle w/o clipping
*
*  Inputs:
*    XCoord1,YCoord1,
*    XCoord2,YCoord2 - Boundary coordinates of rectangle
*    Pattern         - Pattern to draw in
*    ViewXXX         - Viewport if using clipping
*
*  Outputs:
*    A,X,Y           - Unknown
*    ScanLinePtr     - Unknown
*    GL_X1,X2,Y1,Y2  - Same as XCoord...
*
*  External Procedures:
*     GL_HLine       - Draw a horizontal line
*     GL_HLine2      - Draw a horizontal line w/o clipping
*     GL_VLine       - Draw a vertical line
*     GL_VLine2      - Draw a vertical line w/o clipping
*     GL_SaveXY      - Save coordinates
*
*  Revision History:
*     2/21/89 - Original version written.
*     3/02/89 - Now calls GL_SaveXY.
*
***************************************************************************
*
GL_FrameRect   START

               using GL_Tables

               longa on
               longi on

               jsl   GL_SaveXY
;
; Draw horizontal lines in rectangle
;
               jsl   GL_HLine
               lda   YCoord2
               sta   YCoord1
               jsl   GL_HLine
;
; Restore some coordinates
;
               lda   GL_Y1
               sta   YCoord1
               lda   GL_X1
               sta   XCoord1
               lda   GL_X2
               sta   XCoord2
;
; Draw vertical bars in rectangle
;
               jsl   GL_VLine
               lda   XCoord2
               sta   XCoord1
               jsl   GL_Vline
;
; Restore coordinates
;
               lda   GL_X1
               sta   XCoord1
               lda   GL_Y1
               sta   YCoord1
               lda   GL_Y2
               sta   YCoord2

               rtl
;
; Draw the rectangle w/o any clipping
;
GL_FrameRect2  ENTRY

;
; Draw horizontal lines
;
               lda   XCoord1
               sta   GL_X1
               jsl   GL_HLine2
               lda   XCoord2
               sta   XCoord1
               jsl   GL_HLine2
               lda   GL_X1
               sta   XCoord1
;
; Draw vertical bars
;
               lda   YCoord1
               sta   GL_Y1
               jsl   GL_VLine2
               lda   YCoord2
               sta   YCoord1
               jsl   GL_VLine2
               lda   GL_Y1
               sta   YCoord1

               rtl

               END

               copy  gpara.inc
               copy  gpoly.inc
               copy  gwind.inc
               copy  gtran.inc
               copy  gmisc.inc

***************************************************************************
*
* Table of ScanLine Addresses used for finding the address of any random
* ScanLine and masks for plotting.
*
*  Entry Points:
*    GL_SLAdr        - A table of scanline addresses.
*    GL_Mask         - A table of masks for plotting.
*    GL_DPalette     - Default palette colors
*    GL_X1,Y1,X2,Y2  - Saved coordinates
*
*  Revision History:
*     2/16/89 - Original version written.
*     2/17/89 - Added mask table for plot routine.
*     2/21/89 - Added default palette table.
*     3/02/89 - Added saved coordinates.
*     9/27/89 - Adjusted some variable space to 4 bytes for fixed-point numbers
*
***************************************************************************
*
GL_Tables      DATA
;
; Scan Line Addresses
;
GL_SLAdr       anop
               lcla  &n1
&n1            seta  8192
.loop1
               dc    i'&n1'
&n1            seta  &n1+160
               aif   &n1<40448,^loop1
;
; Masks for plotting dots
;
GL_Mask        dc    161b'11110000 00001111'
;
; Default Palette
;
GL_DPalette    dc    i2'$000,$777,$841,$72C,$00F,$080,$F70,$D00'
               dc    i2'$FA9,$FF0,$0E0,$4DF,$DAF,$78F,$CCC,$FFF'
;
; Saved coordinates
;
GL_X1          ds    4
GL_Y1          ds    4
GL_X2          ds    4
GL_Y2          ds    4
;
; Current viewport
;
ViewLeft       ds    2
ViewRight      ds    2
ViewTop        ds    2
ViewBot        ds    2
ViewWidth      ds    2
ViewHeight     ds    2
;
; Current window
;
WindLeft       ds    4
WindRight      ds    4
WindTop        ds    4
WindBot        ds    4
WindWidth      ds    4
WindHeight     ds    4

               END
