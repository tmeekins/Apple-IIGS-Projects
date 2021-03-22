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
; this is simpified to using the first 3 vertices to create a triangle.
;
               lda   (tptr)
               asl4  a
               adc   PntPtr
   	sta   vertex1
	pha
               ldy	#2
               lda   (tptr),y
               asl4  a
               adc   PntPtr
               sta   vertex2
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
               lda   Result
               sta   PolyNormZL
               lda   Result+2
               sta   PolyNormZH

	mv2	vertex2,vertex1
               ldy	#4
               lda   (tptr),y
               asl4  a
               adc   PntPtr
               sta   vertex2
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

	mv2	vertex2,vertex1
	pla
               sta   vertex2
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
	bra	CheckBF
;
; Ignore this polygon, go process the next polygon
;
Skip0	iny2
SkipPoly	lda	(tptr),y
	bpl	Skip0
Skip2	iny2
               tya
               add2  @a,tptr,tptr
               jmp   PolyLoop
;
; Check if the polygon is a backface
;
CheckBF        ldy	#6
	lda   PolyNormZH
               bmi   SkipPoly
               bne   DrawPoly      
               lda   PolyNormZL
;               cmp   #1
;               bcc   SkipPoly
	beq	SkipPoly
;
; Process each edge in the polygon
;
DrawPoly       anop

	lda	>$E1C034
	pha
	lda	#0
	sta	>$E1C034

wait           lda   drawflag
               bne   wait

	pla
	sta	>$E1C034

DrawLoop       lda   (tptr)           ;Get the first vertex
               inc2  tptr
               asl4  a
               adc   PntPtr
               tay

               lda   |pntwy+1,y
	sta	L1
               lda   |pntwx+1,y
	sta	C1

               lda   (tptr)
               bpl   PE0
               inc2  tptr
               jmp   PolyLoop

PE0            anop                     ;Get the second vertex
               asl4  a
               adc   PntPtr
               tay

               lda   |pntwy+1,y
	sta	L2
	lda   |pntwx+1,y
	sta	C2
	jsr	Line

               bra   DrawLoop   

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

               lda   |pntwy+1,y
	sta	L1
               lda   |pntwx+1,y
               sta	C1

               lda   (tptr)
               inc2  tptr
               asl4  a
               adc   PntPtr
               tay

               lda   |pntwy+1,y
	sta	L2
               lda   |pntwx+1,y
	sta	C2
               jsr   Line

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
               jsr   IntIntMul2
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
               jsr   IntIntMul2
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
