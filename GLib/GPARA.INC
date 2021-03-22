***************************************************************************
*
*  Draw the outline of a circle.
*
*  Entry Points:
*    GL_FrameCircle     - Draw the frame of a circle.
*
*  Inputs:
*    XCoord1,YCoord1    - Center of the circle.
*    GLParm             - Radius.
*
*  Outputs:
*    X,Y,A              - Unknown
*
*  External Procedures:
*    GL_Plot            - Plot a dot.
*    GL_RestoreXY       - Restore coordinates.
*    GL_SaveXY          - Save coordinates.
*
*  Revision History:
*     9/29/89 - Original version written.
*
***************************************************************************
*
GL_FrameCircle  START

                longa   on
                longi   on

                jsl     GL_SaveXY

                lda     XCoord1
                sta     cx
                lda     YCoord1
                sta     cy
                lda     GLParm
                sta     xp
                stz     yp
                sec
                lda     #1
                sbc     GLParm
                sta     delta

repeat          jsr     plot

                inc     yp
                lda     delta
                bpl     else

                inc     a
                clc
                adc     yp
                clc
                adc     yp
                sta     delta

                bra     until

else            dec     xp
                inc     a
                tax
                lda     xp
                asl     a
                sta     t1
                lda     yp
                asl     a
                sta     t2
                txa
                sec
                sbc     t1
                clc
                adc     t2
                sta     delta

until           lda     xp
                cmp     yp
                bpl     repeat

                jml     GL_RestoreXY

plot            clc
                lda     xp
                adc     cx
                sta     XCoord1
                pha
                clc
                lda     yp
                adc     cy
                sta     YCoord1
                jsl     GL_Plot         ;cx + xp, cy + yp

                sec
                lda     cx
                sbc     xp
                sta     XCoord1
                jsl     GL_Plot         ;cx - xp, cy + yp

                sec
                lda     cy
                sbc     yp
                sta     YCoord1
                jsl     GL_Plot         ;cx - xp, cy - yp

                pla
                sta     XCoord1
                jsl     GL_Plot         ;cx + xp, cy - yp

                clc
                lda     yp
                adc     cx
                sta     XCoord1
                pha
                clc
                lda     xp
                adc     cy
                sta     YCoord1
                jsl     GL_Plot         ;cx + yp, cy + xp

                sec
                lda     cx
                sbc     yp
                sta     XCoord1
                jsl     GL_Plot         ;cx - yp, cy + xp

                sec
                lda     cy
                sbc     xp
                sta     YCoord1
                jsl     GL_Plot         ;cx - yp, cy - xp

                pla
                sta     XCoord1
                jsl     GL_Plot         ;cx + yp, cy - xp

                rts

cx              ds      2               ;center of the circle
cy              ds      2

xp              ds      2               ;current plotting position
yp              ds      2

delta           ds      2               ;distance from circle

t1              ds      2               ;temporary locations
t2              ds      2

                END

***************************************************************************
*
*  Paint a solid circle.
*
*  Entry Points:
*    GL_PaintCircle     - Paint a solid circle.
*
*  Inputs:
*    XCoord1,YCoord1    - Center of the circle.
*    GLParm             - Radius.
*
*  Outputs:
*    A, X, Y            - Unknown
*
*  External Procedures:
*    GL_HLine           - Draw a horizontal line
*    GL_RestoreXY       - Restore coordinates.
*    GL_SaveXY          - Save coordinates.
*
*  Revision History:
*     9/29/89 - Original version written.
*
***************************************************************************
*
GL_PaintCircle  START

                longa   on
                longi   on

                jsl     GL_SaveXY

                lda     XCoord1
                sta     cx
                lda     YCoord1
                sta     cy
                lda     GLParm
                sta     xp
                stz     yp
                sec
                lda     #1
                sbc     GLParm
                sta     delta

repeat          jsr     plot

                inc     yp
                lda     delta
                bpl     else

                inc     a
                clc
                adc     yp
                clc
                adc     yp
                sta     delta

                bra     until

else            dec     xp
                inc     a
                tax
                lda     xp
                asl     a
                sta     t1
                lda     yp
                asl     a
                sta     t2
                txa
                sec
                sbc     t1
                clc
                adc     t2
                sta     delta

until           lda     xp
                cmp     yp
                bpl     repeat

                jml     GL_RestoreXY

plot            clc
                lda     xp
                adc     cx
                sta     XCoord1
                clc
                lda     yp
                adc     cy
                sta     YCoord1
                sec
                lda     cx
                sbc     xp
                sta     XCoord2
                jsl     GL_HLine

                sec
                lda     cy
                sbc     yp
                sta     YCoord1
                jsl     GL_HLine

                clc
                lda     yp
                adc     cx
                sta     XCoord1
                clc
                lda     xp
                adc     cy
                sta     YCoord1
                sec
                lda     cx
                sbc     yp
                sta     XCoord2
                jsl     GL_HLine

                sec
                lda     cy
                sbc     xp
                sta     YCoord1
                jsl     GL_HLine

                rts

cx              ds      2               ;center of the circle
cy              ds      2

xp              ds      2               ;current plotting position
yp              ds      2

delta           ds      2               ;distance from circle

t1              ds      2               ;temporary locations
t2              ds      2

                END

***************************************************************************
*
*  Draw the outline of an ellipse.
*  NOTE: As of the last revision, this function does not work. Needs to
*  use long integer value instead of 16 bit integers.
*
*  Entry Points:
*    GL_FrameEllipse    - Draw the frame of an ellipse.
*
*  Inputs:
*    XCoord1,YCoord1    - Center of the ellipse.
*    XCoord2,YCoord2    - X & Y radii.
*
*  Outputs:
*    X,Y,A              - Unknown
*
*  External Procedures:
*    IL_UMult           - Unsigned integer multiplication.
*    GL_Plot            - Plot a dot.
*    GL_RestoreXY       - Restore coordinates.
*    GL_SaveXY          - Save coordinates.
*
*  Revision History:
*     9/30/89 - Original version written.
*
***************************************************************************
*
GL_FrameEllipse START

                longa   on
                longi   on

                jsl     GL_SaveXY

                lda     XCoord1
                sta     cx
                lda     YCoord1
                sta     cy
                stz     yp
                lda     XCoord2
                sta     xp
                sta     Arg1
                sta     Arg2
                jsl     IL_UMult
                sta     t1
                asl     a
                sta     t2
                asl     a
                sta     t3
                lda     YCoord2
                sta     Arg1
                sta     Arg2
                jsl     IL_UMult
                sta     t4
                asl     a
                sta     t5
                sta     Arg2
                asl     a
                sta     t6
                lda     XCoord2
                sta     Arg1
                jsl     IL_UMult
                sta     t7
                asl     a
                sta     t8
                stz     t9
                lda     t4
                lsr     a
                clc
                adc     t7
                clc
                adc     t2
                sta     delta1
                lda     t1
                lsr     a
                sec
                sbc     t8
                clc
                adc     t5

while           sta     delta2
                bpl     repeat

                jsr     plot

                inc     yp
                clc
                lda     t9
                adc     t3
                sta     t9

                lda     delta1
                bpl     else1

                clc
                adc     t9
                clc
                adc     t2
                sta     delta1
                clc
                lda     delta2
                adc     t9

                bra     while

else1           dec     xp
                sec
                lda     t8
                sbc     t6
                sta     t8
                lda     delta1
                sec
                sbc     t8
                clc
                adc     t9
                clc
                adc     t2
                sta     delta1
                sec
                lda     delta2
                sbc     t8
                clc
                adc     t5
                clc
                adc     t9

                bra     while

repeat          sta     delta2
                jsr     plot

                dec     xp
                sec
                lda     t8
                sbc     t6
                sta     t8

                lda     delta2
                bpl     else2

                inc     yp
                clc
                lda     t9
                adc     t3
                sta     t9
                sec
                lda     delta2
                sbc     t8
                clc
                adc     t5
                clc
                adc     t9
                bra     until

else2           sec
                sbc     t8
                clc
                adc     t5

until           ldx     xp
                bpl     repeat

                jml     GL_RestoreXY

plot            clc
                lda     xp
                adc     cx
                sta     XCoord1
                pha
                clc
                lda     yp
                adc     cy
                sta     YCoord1
                jsl     GL_Plot
                sec
                lda     cx
                sbc     xp
                sta     XCoord1
                jsl     GL_Plot
                sec
                lda     cy
                sbc     yp
                sta     YCoord1
                jsl     GL_Plot
                pla
                sta     XCoord1
                jsl     GL_Plot

                rts

t1              ds      2               ;temporary numbers
t2              ds      2
t3              ds      2
t4              ds      2
t5              ds      2
t6              ds      2
t7              ds      2
t8              ds      2
t9              ds      2

delta1          ds      2               ;distance from ellipse
delta2          ds      2

xp              ds      2               ;current point
yp              ds      2

cx              ds      2               ;center of ellipse
cy              ds      2

                END
