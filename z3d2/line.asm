	copy	z3d.h
	mcopy	line.mac

	keep	line

IMAGE	gequ	$012000

Swap	START

	using	LineData
	using	z3ddata

	phd
	phb
	phk
	plb
	lda	dpage
	tcd

	ldx	linesave
	lda	#-1
	sta	linebuf,x

	short	a
	lda	#0	;shadow on
	sta	>$E0C035
	long	a

	clc
	ldy	curline
loop1	ldx	linebuf,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+2,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+4,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+6,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+8,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+10,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+12,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+14,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+16,y
	bmi	next1
	lda	>IMAGE,x
	sta	>IMAGE,x
	tya
	adc	#18
	tay
	bra	loop1
next1	ldy	oldline
loop2	ldx	linebuf,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+2,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+4,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+6,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+8,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+10,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+12,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+14,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	ldx	linebuf+16,y
	bmi	next2
	lda	>IMAGE,x
	sta	>IMAGE,x
	tya      
	adc	#18
	tay
	bra	loop2
next2	anop
	
	short	a
	lda	#$1F	;shadow off
	sta	>$E0C035
	long	a

	lda	curline
	ldx	oldline
	sta	oldline
	stx	curline
	stx   linesave

	clc
	ldy	oldline
clrloop	ldx	linebuf,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x
	ldx	linebuf+2,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+4,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+6,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+8,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+10,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+12,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+14,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	ldx	linebuf+16,y
	bmi	clr0
	lda	>ground,x
	sta	>IMAGE,x 
	tya      
	adc	#18
	tay
	lda	#0
	bra	clrloop
clr0	anop

	plb
	pld
	rts

	END

ColorChange	START

	pha
	sta	ColorFFFF
	and	#$F0FF
	sta	ColorF0FF
	and	#$F00F
	sta	ColorF00F
	and	#$000F
	sta	Color000F
	lda	1,s
	and	#$FF0F
	sta	ColorFF0F
	pla
	and	#$00FF
	sta	Color00FF
	and	#$00F0
	sta	Color00F0
	rts

	END

**************************************************************************
*
* The Line Drawer
*
**************************************************************************

Line	START

	using	LineData

	lda	C1	; make line direction left to right
	cmp	C2                 ; (increasing along X)
	bcc	NO_I
	ldy	C2
	sta	C2
	sty	C1
	lda	L1
	ldy	L2
	sty	L1
	sta	L2
NO_I	anop

	bra	doline

	ldx	linecachelen
cache	txa
	sec
	sbc	#2*4
	bmi	putline
	tax
	lda	linecache,x
	cmp	C1
	bne	cache
	lda	linecache+2,x
               cmp	C2
	bne	cache
	lda	linecache+4,x
	cmp	L1
	bne	cache
	lda	linecache+6,x
	cmp	L2
	bne	cache
	rts

putline	ldx	linecachelen
	lda	C1
	sta	linecache,x
	lda	C2
	sta	linecache+2,x
	lda	L1
               sta	linecache+4,x
	lda	L2
	sta	linecache+6,x
	clc
	txa
	adc	#2*4
	sta	linecachelen	

doline	lda	L1-1	; calculate the base address for drawing
	lsr	a	; (who needs a table!)
	lsr	a
	clc
	adc	L1-1
	adc	C1
	tay

;	php
;	sei
	phb
	pea	$0101
	plb
	plb

	lda	C2	; calculate DX, vertical if DX=0
	sec
	sbc	C1
	beq	LV

	sta	DX
	lda	L1	; see if line is left & up or
	cmp	L2                 ; left & down
	bcs	LD
	jmp	LI
;
;  it's a vertical line
;
LV	lda	#1	
	sta	DX
	lda	L1
	sec
	sbc	L2
	bcs	LVD
;
; vertical line moving downwards
;
LVI	dec	a
	sta	UT
	tya
	lsr	a
	bcc	FIV0_C1	;branch if even
	clc
	tay
	ldx	linesave
	lda	UT
	jmp	FIV1_R

FIV0_C1	tay
	ldx	linesave
FIV0_C	lda	UT
	jmp	FIV0_R
;
; vertical line moving upwards
;
LVD	eor	#$FFFF
;	inc	a
;	dec	a
	sta	UT
	tya
	lsr	a
	bcc	FDV0_C1	;branch if even column
	clc
	tay
	ldx	linesave
	lda	UT
	jmp	FDV1_R

FDV0_C1	tay
	ldx	linesave
FDV0_C	lda	UT
	jmp	FDV0_R
;
; The line moves to left to right and upwards
;
LD	sbc	L2
	beq	LHH
	sta	DY
	cmp	DX
	bcc	LDH
	jmp	LDV
;
; it's a horizontal line
;
LHH	lda	#1
	sta	DY
	lda	DX
	eor	#$FFFF
;	inc	a
	sta	UT
	tya
	lsr	a
	bcc	FDH0_C1	;branch if even
	clc
	tay
	ldx	linesave
	lda	UT
	jmp	FDH1_R

FDH0_C1	tay
	ldx	linesave
FDH0_C	lda	UT
	jmp	FDH0_R
;
; upwards moving line with DX > DY
;
LDH	lda	DX
	dec	a
	lsr	a
	eor	#$FFFF
	sta	UT
	tya
	ldy	DY
	sty	Count
	lsr	a
	bcc	LDH0F
	clc
	tay
	ldx	linesave
	jmp	LDH1
;
; upwards moving line with DX > DY starting on even column
;                                  
LDH0F	tay
	ldx	linesave
LDH0	lda	UT
	adc	DY
	bpl	LDH0_P1
	adc	DY
	bpl	LDH0_P2
	adc	DY
	bpl	LDH0_P3
	adc	DY
	bpl	LDH0_P4
;
; XXXXo
;
LDH0_PM	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	bra	LDH0
;
; .o
; X.
;
LDH0_P1	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-160
	clc
	tay
	dec	Count
	bne	LDH1
	jmp	FDH1
;
; ..o
; XX.
;
LDH0_P2	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FF00
	ora	Color00FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-159
	clc
	tay
	dec	Count
	bne	LDH0
	jmp	FDH0
;
; ...o
; XXX.
;
LDH0_P3	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$0F00
	ora	ColorF0FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-159
	clc
	tay
	dec	Count
	bne	LDH1
	jmp	FDH1
;
; ....o
; XXXX.
;
LDH0_P4	sbc	DX
	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-158
	clc
	tay
	dec	Count
	bne	LDH0_G
	jmp	FDH0
LDH0_G	jmp	LDH0
;
; upwards moving line with DX > DY starting on odd column
;                                  
LDH1	lda	UT
	adc	DY
	bpl	LDH1_P1
	adc	DY
	bpl	LDH1_P2
	adc	DY
	bpl	LDH1_P3
;
; .XXXo
;
LDH1_PM	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	jmp	LDH0
;
; ..o
; .X.
;
LDH1_P1	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-159
	clc
	tay
	dec	Count
	beq	LDH_END0
	jmp	LDH0
;
; ...o
; .XX.
;
LDH1_P2	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$0FF0
	ora	ColorF00F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-159
	clc
	tay
	dec	Count
	beq	LDH_END1
	bra	LDH1

LDH_END0	jmp	FDH0
LDH_END1	jmp	FDH1
;
; ....o
; .XXX.
;
LDH1_P3	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-158
	clc
	tay
	dec	Count
	beq	LDH_END0
	jmp	LDH0
;
; upwards moving line with DY > DX
;
LDV	lda	DY
	lsr	a
	eor	#$FFFF
	sta	UT
	tya
	ldy	DX
	sty	Count
	lsr	a
	bcc	LDV0F
	clc
	tay
	ldx	linesave
	jmp	LDV1

LDV0F	tay
	ldx	linesave
LDV0	lda	UT
	adc	DX
	bpl	LDV0_P1
	adc	DX
	bpl   LDV0_P2
	adc	DX
	bmi	LDV0_PM
	jmp	LDV0_P3
;
; o.
; X.
; X.
; X.
;
LDV0_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#-160
	sta	>linebuf+2,x
	adc	#-161
	sta	>linebuf+4,x
	adc	#-161
	clc
	tay
	txa
	adc	#6
	tax
	bra	LDV0
;
; .o
; X.
;
LDV0_P1	sbc	DY
	sta	UT
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-160
	clc
	tay
	dec	Count
	bne	LDV0_P1a
	jmp	FDV1
LDV0_P1a	jmp	LDV1
;                    
; .o
; X.
; X.
;
LDV0_P2	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	long	a
	tya
	sta	>linebuf,x
	adc	#-160
	sta	>linebuf+2,x
	adc	#-161
	clc
	tay
	txa
	adc	#4
	tax
	dec	Count
	bne	LDV1
	jmp	FDV1

LDV0_P3	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#-160
	sta	>linebuf+2,x
	adc	#-161
	sta	>linebuf+4,x
	adc	#-161
	clc
	tay
	txa
	adc	#6
	tax
	dec	Count       
	bne	LDV1
	jmp	FDV1

LDV1	lda	UT
	adc	DX
	bpl	LDV1_P1
	adc	DX
	bpl	LDV1_P2
	adc	DX
	bmi	LDV1_PM
	jmp	LDV1_P3

LDV1_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#-160
	sta	>linebuf+2,x
	adc	#-161
	sta	>linebuf+4,x
	adc	#-161
	clc
	tay
	txa
	adc	#6
	tax
	bra	LDV1

LDV1_P1	sbc	DY
	sta	UT
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#-159
	clc
	tay
	dec	Count
	beq	LDV_END2
	jmp	LDV0

LDV1_P2	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-160,y
	long	a
	tya
	sta	>linebuf,x
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F+1
	clc
	tay
	txa
	adc	#4
	tax
	dec	Count
	beq	LDV_END2
	jmp	LDV0

LDV_END2	jmp	FDV0

LDV1_P3	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-$A0,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-$A0,y
               lda	|IMAGE-$140,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-$140,y
	long	a
	tya
	sta	>linebuf,x
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F
	sta	>linebuf+4,x
	adc	#$FF5F+1
	clc
	tay
	txa
	adc	#6
	tax
	dec	Count
	beq	LDV_END2
	jmp	LDV0
;
; move left to right and downwards
;
LI	lda	L2
	sec
	sbc	L1
	sta	DY
	cmp	DX
	bcc	LIH
	jmp	LIV

LIH	lda	DX
	dec	a
	lsr	a
	eor	#$FFFF
	sta	UT
	tya
	ldy	DY
	sty	Count
	lsr	a
	bcc	LIH0F
	clc
	tay
               ldx	linesave
	jmp	LIH1

LIH0F	tay
	ldx	linesave
LIH0	lda	UT
	adc	DY
	bpl	LIH0_P1
	adc	DY
	bpl	LIH0_P2
	adc	DY
	bpl	LIH0_P3
	adc	DY
	bpl	LIH0_P4	

LIH0_PM	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	bra	LIH0

LIH0_P1	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#160
	tay
	dec	Count        
	bne	LIH1
	jmp	FIH1

LIH0_P2	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FF00
	ora	Color00FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#161
	tay
	dec	Count
	bne	LIH0
	jmp	FIH0

LIH0_P3	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$0F00
	ora	ColorF0FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#161
	tay
	dec	Count
	bne	LIH1
	jmp	FIH1

LIH0_P4	sbc	DX
	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#162
	tay
	dec	Count
	bne	LIH0_G
	jmp	FIH0
LIH0_G	jmp	LIH0

LIH1	lda	UT
	adc	DY
	bpl	LIH1_P1
	adc	DY
	bpl	LIH1_P2
	adc	DY
	bpl	LIH1_P3

LIH1_PM	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	jmp	LIH0

LIH1_P1	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#161
	tay
	dec	Count
	beq	LIH_END0
	jmp	LIH0

LIH1_P2	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$0FF0
	ora	ColorF00F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#161
	tay
	dec	Count
	beq	LIH_END1
	bra	LIH1

LIH_END0	jmp	FIH0
LIH_END1	jmp	FIH1

LIH1_P3	sbc	DX
	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#162
	tay
	dec	Count
	beq	LIH_END0
	jmp	LIH0


LIV	lda	DY
	lsr	a
	eor	#$FFFF
	sta	UT
	tya
	ldy	DX
	sty	Count
	lsr	a
	bcc	LIV0F
	clc
	tay
               ldx	linesave
	jmp	LIV1

LIV0F	tay
	ldx	linesave
LIV0	lda	UT
	adc	DX
	bpl	LIV0_P1
	adc	DX
	bpl	LIV0_P2
	adc	DX
	bmi	LIV0_PM
	jmp	LIV0_P3

LIV0_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160
	tay
	txa
	adc	#6
	tax
	bra	LIV0

LIV0_P1	sbc	DY
	sta	UT
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#160
	tay
	dec	Count
	bne	LIV1_G
	jmp	FIV1
LIV1_G	jmp	LIV1

LIV0_P2	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	tay
	txa
	adc	#4
	tax
	dec	Count
	bne	LIV1
	jmp	FIV1

LIV0_P3	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160
	tay
	txa
	adc	#6
	tax
	dec	Count
	bne	LIV1
	jmp	FIV1

LIV1	lda	UT
	adc	DX
	bpl	LIV1_P1
	adc	DX
	bpl	LIV1_P2
	adc   DX
	bmi	LIV1_PM
	jmp	LIV1_P3

LIV1_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160
	tay
	txa
	adc	#6
	tax
	bra	LIV1

LIV1_P1	sbc	DY
	sta	UT
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	adc	#161
	tay
	dec	Count
	beq	LIV_END2
	jmp	LIV0

LIV1_P2	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160	
	sta	>linebuf+2,x
	adc	#160+1
	tay
	txa
	adc	#4
	tax
	dec	Count
	beq	LIV_END2
	jmp	LIV0

LIV_END2	jmp	FIV0

LIV1_P3	sbc	DY
	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160+1
	tay
	txa
	adc	#6
	tax
	dec	Count
	beq	LIV_END2
	jmp	LIV0

**** Complement at end

;
; horizontal line starting on even column
;
FDH0	lsr	DX
	lda	UT
	clc
	adc	DX
FDH0_R	adc	DY
	bpl	FDH0_P1
	adc	DY
	bpl	FDH0_P2
	adc	DY
	bpl	FDH0_P3
	adc	DY
	bpl	FDH0_P4

FDH0_PM	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	lda	UT
	bra	FDH0_R

FDH0_P1	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDH0_P2	lda	|IMAGE,y
	and	#$FF00
	ora	Color00FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDH0_P3	lda	|IMAGE,y
	and	#$0F00
	ora	ColorF0FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDH0_P4	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL
;
; horizontal line starting on odd column
;
FDH1	lsr	DX
	lda	UT
	clc
	adc	DX
FDH1_R	adc	DY
	bpl	FDH1_P1
	adc	DY
	bpl	FDH1_P2
	adc	DY
	bpl	FDH1_P3

FDH1_PM	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	lda	UT
	jmp	FDH0_R

FDH1_P1	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDH1_P2	lda	|IMAGE,y
	and	#$0FF0
	ora	ColorF00F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDH1_P3	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL
;
; Vertical line moving upwards on even column
;
FDV0	lsr	DY
	lda	UT
	clc
	adc	DY
FDV0_R	adc	DX
	bpl	FDV0_P1
	adc	DX
	bpl	FDV0_P2
	adc	DX
	bmi	FDV0_PM
	jmp	FDV0_P3

FDV0_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F
	sta	>linebuf+4,x
	adc	#$FF5F
	clc
	tay
	txa
	adc	#6
	tax
	lda	UT
	bra	FDV0_R

FDV0_P1	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDV0_P2	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	long	a
	tya
	sta	>linebuf,x
	clc
	adc	#$FF60
	sta	>linebuf+2,x
	clc
	txa
	adc	#4
	tax
	jmp	FINAL

FDV0_P3	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	clc
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F
	sta	>linebuf+4,x
	clc
	txa
	adc	#6
	tax
	jmp	FINAL
;
; vertical line moving upwards on odd column
;
FDV1	lsr	DY
	lda	UT
	clc
	adc	DY
FDV1_R	adc	DX
	bpl	FDV1_P1
	adc	DX
	bpl	FDV1_P2
	adc	DX
	bmi	FDV1_PM
	jmp	FDV1_P3

FDV1_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-160,y
	lda	|IMAGE-320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F
	sta	>linebuf+4,x
	adc	#$FF5F
	clc
	tay
	txa
	adc	#6
	tax
	lda	UT
	bra	FDV1_R

FDV1_P1	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDV1_P2	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-160,y
	long	a
	tya
	sta	>linebuf,x
	inx
	inx
	clc
	adc	#$FF60
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FDV1_P3	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE-160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-160,y
               lda	|IMAGE-320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE-320,y
	long	a
	tya
	sta	>linebuf,x
	clc         
	adc	#$FF60
	sta	>linebuf+2,x
	adc	#$FF5F
	sta	>linebuf+4,x
	clc
	txa
	adc	#6
	tax
	jmp	FINAL

FIH0	lsr	DX
	lda	UT
	clc
	adc	DX
FIH0_R	adc	DY
	bpl	FIH0_P1
	adc	DY
	bpl	FIH0_P2
	adc	DY
	bpl	FIH0_P3
	adc	DY
	bpl	FIH0_P4

FIH0_PM	sta	UT
	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	lda	UT
	bra	FIH0_R

FIH0_P1	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH0_P2	lda	|IMAGE,y
	and	#$FF00
	ora	Color00FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH0_P3	lda	|IMAGE,y
	and	#$0F00
	ora	ColorF0FF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH0_P4	lda	ColorFFFF
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH1	lsr	DX
	lda	UT
	clc
	adc	DX
	adc	DY
	bpl	FIH1_P1
	adc	DY
	bpl	FIH1_P2
	adc	DY
	bpl	FIH1_P3

FIH1_PM	sta	UT
	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	iny
	iny
	lda	UT
	jmp	FIH0_R

FIH1_P1	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH1_P2	lda	|IMAGE,y
	and	#$0FF0
	ora	ColorF00F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIH1_P3	lda	|IMAGE,y
	and	#$00F0
	ora	ColorFF0F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL
;
; vertical line moving downwards on even column
;
FIV0	lsr	DY
	lda	UT
	clc
	adc	DY
FIV0_R	adc	DX
	bpl	FIV0_P1
	adc	DX
	bpl	FIV0_P2
	adc	DX
	bmi	FIV0_PM
	jmp	FIV0_P3

FIV0_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160
	tay
	clc
	txa
	adc	#6
	tax
	lda	UT
	bra	FIV0_R

FIV0_P1	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIV0_P2	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	long	a
	tya
               clc
	sta	>linebuf,x
	inx
	inx
	adc	#160
	sta	>linebuf,x
	inx
	inx
	jmp	FINAL

FIV0_P3	short	a
	lda	|IMAGE,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FF0F
	ora	Color00F0
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	clc
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	clc
	txa
	adc	#6
	tax
	jmp	FINAL
;
; vertical line moving downward on odd column
;
FIV1	lsr	DY
	lda	UT
	clc
	adc	DY
FIV1_R	adc	DX
	bpl	FIV1_P1
	adc	DX
	bpl	FIV1_P2
	adc   DX
	bmi	FIV1_PM
	jmp	FIV1_P3

FIV1_PM	sta	UT
	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	adc	#160
	tay
	clc
	txa
	adc	#6
	tax
	lda	UT
	bra	FIV1_R

FIV1_P1	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	tya
	sta	>linebuf,x
	inx
	inx
	bra	FINAL

FIV1_P2	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	long	a
	tya
	sta	>linebuf,x
	inx
	inx
               clc 
	adc	#160	
	sta	>linebuf,x
	inx
	inx
	bra	FINAL

FIV1_P3	short	a
	lda	|IMAGE,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE,y
	lda	|IMAGE+160,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+160,y
	lda	|IMAGE+320,y
	and	#$FFF0
	ora	Color000F
	sta	|IMAGE+320,y
	long	a
	tya
	sta	>linebuf,x
               clc   
	adc	#160
	sta	>linebuf+2,x
	adc	#160
	sta	>linebuf+4,x
	clc
	txa
	adc	#6
	tax

FINAL	stx	linesave

	plb
;	plp
	rts

	END

LineData	DATA

LineBuf	ds	8000
	ds	8000
LineCache	ds	256*4*2


	END
