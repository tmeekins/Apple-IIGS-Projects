               copy  mat.h
               copy  pnt.h
               copy  z3d.h
               keep  'draw'
               mcopy 'draw.mac'

**************************************************************************
*
* Draw an object and remove backfaces
*
**************************************************************************

DrawObjLineBF  START

	using	drawdat

vertex1        equ   0
vertex2        equ   vertex1+2
PolyNormZL     equ   vertex2+2
PolyNormZH     equ   PolyNormZL+2

               mv2   ObjPtr,tptr
;
; Loop through each polygon
;
PolyLoop       lda   (tptr)           ;Are there any polygons left?
               bpl   DoPoly
               rts

DoPoly         anop

               stz   PolyNormZL
               stz   PolyNormZH
;
; Perform backface cullling. If normal.z < 0 then the polygon is a backface
; and can be ignored. We calculate the normal using Newell's method, since
; we can avoid numerous multiplications and we can do it for the z coordinate
; individually.
;
;   normal.z = sum(i=1..n-1): (x[i]-x[j+1])(y[i]+y[j+1])
;
; see Roger's PECG page 209 for details or [Sutherland74]
;

;
; initialize vertex 2 to the first vertex of the object
;
               ldy   #0

               lda   (tptr)
               asl4  a
               adc   PntPtr
               sta   vertex2
;
; traverse of the hull of the polygon. Let's get the next edge. Firstly,
; vertex 1 is the old vertex 2. Secondly, vertex 2 is the next vertex in the
; edge list.
;
BackfaceLoop   sta   vertex1
               iny2                     ;point to next vertex
               lda   (tptr),y
               bmi   CheckBF
               asl4  a
               adc   PntPtr
               sta   vertex2
;
; normal.z = normal.z + (v1.x - v2.x)*(v1.y + v2.y)
;
               phy
               ldy   #pntwx+1
               sec
               lda   (vertex1),y
               sbc   (vertex2),y
               tax
               ldy   #pntwy+1
               clc
               lda   (vertex1),y
               adc   (vertex2),y
               jsr   IntIntMul
               clc
               lda   Result
               adc   PolyNormZL
               sta   PolyNormZL
               lda   Result+2
               adc   PolyNormZH
               sta   PolyNormZH
;
; Continue looping through each edge
;
NextBF         ply
               lda   vertex2
               bra   BackfaceLoop
;
; Ignore this polygon, go process the next polygon
;
SkipPoly       anop
               iny2
               tya
               add2  @a,tptr,tptr
               jmp   PolyLoop
;
; Check if the polygon is a backface
;
CheckBF        lda   PolyNormZH
;               bmi   SkipPoly
               bpl   SkipPoly
               bne   DrawPoly      
               lda   PolyNormZL
               cmp   #1
               bcc   SkipPoly
;
; Process each edge in the polygon
;
DrawPoly       anop

wait           lda   drawflag
               bne   wait

DrawLoop       lda   (tptr)           ;Get the first vertex
               inc2  tptr
               asl4  a
               adc   PntPtr
               tay

               ldx   |pntwy+1,y
               lda   |pntwx+1,y
               jsr   LineStart

               lda   (tptr)
               bpl   PE0
               inc2  tptr
               jmp   PolyLoop

PE0            anop                     ;Get the second vertex
               asl4  a
               adc   PntPtr
               tay

               ldx   |pntwy+1,y
               lda   |pntwx+1,y
               jsr   DrawLine

               jmp   DrawLoop   

               END

**************************************************************************
*
* Draw a wire frame object
*
**************************************************************************

DrawObjLine    START

	using	drawdat

               mv2   EdgePtr,tptr

wait           lda   drawflag
               bne   wait
;
; Draw  the Edge
;
DrawEdge       lda   (tptr)           ;Get the first vertex
               inc2  tptr
               asl4  a
               adc   PntPtr
               tay

               ldx   |pntwy+1,y
               lda   |pntwx+1,y
               jsr   LineStart

               lda   (tptr)
               inc2  tptr
               asl4  a
               adc   PntPtr
               tay

               ldx   |pntwy+1,y
               lda   |pntwx+1,y
               jsr   DrawLine

               lda   (tptr)
               bpl   DrawEdge

               rts

               END

**************************************************************************
*
* transform each vertex point from object space to world space
*
**************************************************************************

PerspectObj    START

               mv2   PntPtr,tptr

persploop      lda   (tptr)
               and   #$FF               ;=0 if more vertices
	bne	done
;
; X = D*X/Z
;
               ldy   #pntwx+1
               lda   (tptr),y
               ldx   perspD
               jsr   IntIntMul
               ldx   Result
               ldy   #pntwz+1
               lda   (tptr),y
               clc
               adc   perspD
               beq   skip1
               jsr   SIntDiv
               ldy   #pntwx+1
               lda   Quotient
               sta   (tptr),y
;
; Y = D*Y/Z
;
skip1          ldy   #pntwy+1
               lda   (tptr),y
               ldx   perspD
               jsr   IntIntMul
               ldx   Result
               ldy   #pntwz+1
               lda   (tptr),y
               clc
               adc   perspD
               beq   skip2
               jsr   SIntDiv
               ldy   #pntwy+1
               lda   Quotient
               sta   (tptr),y

skip2          add2  tptr,#pntsize,tptr
               bra   persploop      

done	rts

               END

**************************************************************************
*
* map object to screen
*
**************************************************************************

MapObj         START

               ldy   PntPtr

maploop        lda   |0,y
               and   #$FF               ;=0 if more vertices
               bne   done

            	clc
               lda   |pntwx+1,y
               adc   cox
               sta   |pntwx+1,y

               clc
               lda   |pntwy+1,y
               adc   coy
               sta   |pntwy+1,y

               add2  @y,#pntsize,@y
               bra   maploop

done	rts

               END


drawdat        DATA

drawflag       dc    i'0'

               END
