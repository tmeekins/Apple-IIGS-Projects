***********************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqtrucol.asm
*
* ImageQuant True Color converters
*
**************************************************************************

	mcopy	m/iqtrucol.mac

;-------------------------------------------------------------------------
; doPlainTrueColor
;    true color conversion w/o dithering
;-------------------------------------------------------------------------

doPlainTrueColor START

	using	Globals
	using Tables

image	equ	1
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
pic	equ	width+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePicTC
	jsl	MkTCPal
	jsl	MkTCSCB

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	!ImageHeight
	sta	<height

yloop	stz	<offset
	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

	ldy	#2
	clc
xloopr	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp1r+1
               and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ora	1,s
	ldy	<offset
	sta	[<pic],y
	iny
	pla
	sep	#$20
	sta	[<pic],y
	rep	#$20
	sty	<offset
temp1r	ldy	#0
	dec	<width
	beq	dogreen
	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp2r+1
	and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	pha
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	iny
	pla
	ora	1,s
	sep	#$20
	sta	[<pic],y
	rep	#$20
	pla
	iny
	sty	<offset
temp2r	ldy	#0
	dec	<width
	bne	xloopr

dogreen	jsl	TVMM_release

	clc

	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	stz	<offset

	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

	ldy	#0
	clc
xloopg	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp1g+1
               and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ora	1,s
	ldy	<offset
	sta	[<pic],y
	iny
	pla
	sep	#$20
	sta	[<pic],y
	rep	#$20
	sty	<offset
temp1g	ldy	#0
	dec	<width
	beq	doblue
	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp2g+1
	and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	pha
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	iny
	pla
	ora	1,s
	sep	#$20
	sta	[<pic],y
	rep	#$20
	pla
	iny
	sty	<offset
temp2g	ldy	#0
	dec	<width
	bne	xloopg

doblue	jsl	TVMM_release

	clc

	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	stz	<offset

	lda	[<image]
	pha
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	!ImageWidth
	sta	<width

	ldy	#1
	clc
xloopb	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp1b+1
               and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ora	1,s
	ldy	<offset
	sta	[<pic],y
	iny
	pla
	sep	#$20
	sta	[<pic],y
	rep	#$20
	sty	<offset
temp1b	ldy	#0
	dec	<width
	beq	nexty
	lda	[<lineptr],y
	iny
	iny
	iny
	sty	!temp2b+1
	and	#$f0
	pha
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	pha
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	iny
	pla
	ora	1,s
	sep	#$20
	sta	[<pic],y
	rep	#$20
	pla
	iny
	sty	<offset
temp2b	ldy	#0
	dec	<width
	bne	xloopb

nexty	jsl	TVMM_release

	inc	<image
	inc	<image

	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsl	AdvanceThermo

	dec	<height
	jne	yloop	

	jsl	CloseThermo

	jsl	TVMM_release
	jsl	TVMM_release

	return

loadstr	dc	c'True Color Conversion...',h'00'

	END
           
;-------------------------------------------------------------------------
; doOrder2TrueColor
;    true color conversion w/ order-2 dithering
;-------------------------------------------------------------------------

doOrder2TrueColor START

	using	Globals
	using Tables

value	equ	1
dithoffset	equ	value+2
col	equ	dithoffset+2
row	equ	col+2
image	equ	row+2
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
pic	equ	width+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePicTC
	jsl	MkTCPal
	jsl	MkTCSCB

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	#4
	sta	<row

	lda	!ImageHeight
	sta	<height

	stz	<dithoffset

yloop	jsr	getrow 
	stz	<offset

	lda	!ImageWidth
	asl	a
	adc	!ImageWidth
	sta	<width

	lda	#4
	sta	<col

xloopr	jsr	getpix
	txa
	short	a
	and	#$F0
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord01
	lda	<value
	adc	#$10-1
	beq	ord01
	sta	<value
ord01          lda	<value
	ldy	<offset
	sta	[<pic],y
	long	a

	dec	<width
	beq	dogreen

	jsr	getpix
	txa
	short	a
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord02
	lda	<value
	inc	a
	cmp	#16
	bcs	ord02
	sta	<value
ord02          lda	<value
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	long	a
	iny
	sty	<offset
	dec	<width
	bne	xloopr

dogreen	lda	[<image]
	pha
	jsl	TVMM_release

	clc
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsr	getrow
	stz	<offset

	lda	!ImageWidth
	asl	a
	adc	!ImageWidth
	sta	<width

	lda	#4
	sta	<col

xloopg	jsr	getpix
	tax
	short	a
	and	#$F0
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord03
	lda	<value
	adc	#$10-1
	beq	ord03
	sta	<value
ord03          lda	<value
	ldy	<offset
	sta	[<pic],y
	long	a

	dec	<width
	beq	doblue

	jsr	getpix
	tax
	short	a
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord04
	lda	<value
	inc	a
	cmp	#16
	bcs	ord04
	sta	<value
ord04          lda	<value
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	long	a
	iny
	sty	<offset

	dec	<width
	bne	xloopg

doblue	lda	[<image]
	pha
	jsl	TVMM_release

	clc
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsr	getrow
	stz	<offset

	lda	!ImageWidth
	asl	a
	adc	!ImageWidth
	sta	<width

	lda	#4
	sta	<col

xloopb	jsr	getpix
	xba
	tax
	short	a
	and	#$F0
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl,x
	bcc	ord05
	lda	<value
	adc	#$10-1
	beq	ord05
	sta	<value
ord05          lda	<value
	ldy	<offset
	sta	[<pic],y
	long	a

	dec	<width
	beq	nexty

	jsr	getpix
	xba
	tax
	short	a
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	<value
	txa
	and	#$0C
	lsr	a
	lsr	a
	ldx	<dithoffset
	cmp	!dithtbl+2,x
	bcc	ord06
	lda	<value
	inc	a
	cmp	#16
	bcs	ord06
	sta	<value
ord06          lda	<value
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	long	a
	iny
	sty	<offset

	dec	<width
	bne	xloopb

nexty	lda	[<image]
	pha
	jsl	TVMM_release

	clc
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	jsl	AdvanceThermo

	dec	<height
	jne	yloop	

	jsl	CloseThermo

	jsl	TVMM_release
	jsl	TVMM_release

	return

getrow	dec	<row
	bne	getrow2
	lda	#3
	sta	<row
	inc	<image
	inc	<image
getrow2	lda	[<image]
	pha
	jsl	TVMM_acquire
	sta	<lineptr
	stx	<lineptr+2

	lda	<dithoffset
	adc	#4
	and	#8-1
	sta	<dithoffset

	rts

getpix	dec	<col
	bne	getpix2
	lda	#3
	sta	<col
	clc
	lda	<lineptr
	adc	#3
	sta	<lineptr
getpix2	ldy	#2
	lda	[<lineptr],y
	tax
	lda	[<lineptr]
	rts

loadstr	dc	c'True Color Conversion...',h'00'

dithtbl	dc	i2'1,3,4,2'

	END             
