**************************************************************************
*
* ImageQuant
* by Tim Meekins
*
* Copyright (c) 1994 by Tim Meekins
*
**************************************************************************
*
* iqbw.asm
*
* ImageQuant B/W converters
*
**************************************************************************

	mcopy	m/iqbw.mac

;-------------------------------------------------------------------------
; doPlainBW
;    Gray Scale w/o dithering
;-------------------------------------------------------------------------

doPlainBW	START

	using	Globals
	using Tables

image	equ	1
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
paloffset	equ	width+2
pic	equ	paloffset+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	MkGrayPal
	jsl	Mk16SCB

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

	ldy	#0
	clc
xloop	lda	[<lineptr]
	tax
	ldy	#2
	lda	[<lineptr],y
	stx	<paloffset
	short	ai
	tay
	lda	!redtbl,x
	ldx	<paloffset+1
	adc	!greentbl,x
	adc	!bluetbl,y
               and	#$f0
	long	i
	ldy	<offset
	sta	[<pic],y
	long	a
	dec	<width
	beq	nexty
	ldy	#3
	lda	[<lineptr],y
	tax	
	ldy	#5
	lda	[<lineptr],y	
	stx	<paloffset
	short	ai
	tay
	lda	!redtbl,x
	ldx	<paloffset+1
	adc	!greentbl,x
	adc	!bluetbl,y
	long	ai
	and	#$f0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	inc	<offset
	lda	<lineptr
	adc	#6
	sta	<lineptr
	dec	<width
	bne	xloop

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

loadstr	dc	c'Gray Scale Conversion...',h'00'

	END
           
;-------------------------------------------------------------------------
; doOrder2BW
;    Gray Scale w/ Order-2 Dithering
;-------------------------------------------------------------------------

doOrder2BW	START

	using	Globals

image	equ	1
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
value	equ	width+2
dithoffset	equ	value+2
pic	equ	dithoffset+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	MkGrayPal
	jsl	Mk16SCB

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	stz	<dithoffset

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

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

	clc

	ldy	#0
xloop	lda	[<lineptr],y
	tax
	iny
	iny
	lda	[<lineptr],y
	iny
	jsr	RGB2Gray
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
	bcc	bw03
	lda	<value
	adc	#$10-1
	bra	bw03a

bw03	lda	<value
bw03a	tyx
	ldy	<offset
	sta	[<pic],y
	long	a
	txy
	dec	<width
	beq	nexty
	lda	[<lineptr],y
	tax
	iny
	iny
	lda	[<lineptr],y
	iny
	jsr	RGB2Gray
	tax
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
	bcc	bw04
               inc	<value
	clc
bw04	lda	<value
	tyx
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	txy
	inc	<offset
	dec	<width
	jne	xloop

nexty	clc
	lda	<image
	adc	#2
	sta	<image

	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2

	lda	<dithoffset
	adc	#4
	and	#8-1
	sta	<dithoffset

	jsl	AdvanceThermo
	jsl	TVMM_release

	dec	<height                     
	jne	yloop	

	jsl	CloseThermo

	jsl	TVMM_release
	jsl	TVMM_release

	return

dithtbl	dc	i2'1,3,4,2'

loadstr	dc	c'Gray Scale Conversion...',h'00'

	END

;-------------------------------------------------------------------------
; doError1BW
;    Gray Scale w/ Error Diffusion 1 Dithering
;-------------------------------------------------------------------------

doError1BW	START

	using	Globals
	using	Tables

nextptr	equ	1
curptr	equ	nextptr+2
image	equ	curptr+2
height	equ	image+4
offset	equ	height+2
lineptr	equ	offset+2
width	equ	lineptr+4
curline	equ	width+2
nextline	equ	curline+4
value	equ	nextline+4
actual	equ	value+2
pic	equ	actual+2
space	equ	pic+4

	subroutine (0:dummy),space

	ph4	#loadstr
	ph2	ImageHeight
	jsl	OpenThermo

	jsl	DisposePic
	jsl	AllocatePic
	jsl	MkGrayPal
	jsl	Mk16SCB

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<curline
	stx	<curline+2
	sta	<curptr

	pea	$C018
	pea	0
	lda	!ImageWidth
	inc	a
	asl	a
	pha
	jsl	TVMM_allocreal
	sta	<nextline
	stx	<nextline+2
	sta	<nextptr

	lda	!ImageWidth
	asl	a
	tay
	lda	#0
clear	sta	[nextline],y
	dey
	dey
	bpl	clear

	lda	!PicHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<pic
	stx	<pic+2

	lda	!ImageHandle
	pha
	pha
	jsl	TVMM_acquire
	sta	<image
	stx	<image+2

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

	lda	!ImageWidth
	asl	a
	tay
copy	lda	[<nextline],y
	sta	[<curline],y
	lda	#0
	sta	[<nextline],y
	dey
	dey
	bpl	copy

xloop	ldy	#2
	lda	[<lineptr]
	tax
	lda	[<lineptr],y
	jsr	RGB2Gray
	and	#$FF
	clc
	adc	[<curline]
	bpl	clip0
	lda	#0
	bra	clip1
clip0	cmp	#$100
	bcc	clip1
	lda	#$FF
clip1	sta	<actual
	clc
	adc	#8	;round up if >.5
	cmp	#$100
	bcc	clip2
	lda	#$FF
clip2	and	#$F0
	sta	<value
               sec
	lda	<actual
	sbc	<value
	bmi	minus1
	tax
	lda	!three8tbl1,x
	and	#$FF
	clc
	adc	[<nextline]
	sta	[<nextline]
	ldy	#2
	lda	!three8tbl2,x
	and	#$FF
	clc
	adc	[<curline],y
	sta	[<curline],y
	lda	!one4tbl,x
	and	#$FF
	clc
	adc	[<nextline],y
	sta	[<nextline],y
	bra	fini1        
minus1	eor	#$FFFF
	inc	a
	tax
	lda	!three8tbl1,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextline]
	sta	[<nextline]
	ldy	#2
	lda	!three8tbl2,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<curline],y
	sta	[<curline],y
	lda	!one4tbl,x
	and	#$FF
	eor	#$FFFF
	sec
	adc	[<nextline],y
	sta	[<nextline],y

fini1	inc	<nextline
	inc	<nextline
	inc	<curline	
	inc	<curline

	lda	<value
	ldy	<offset
	short	a
	sta	[<pic],y
	rep	#$21
	longa	on
	lda	<lineptr
	adc	#3
	sta	<lineptr
	dec	<width
	jeq	nexty

	ldy	#2
	lda	[<lineptr]
	tax
	lda	[<lineptr],y
	jsr	RGB2Gray
	and	#$FF
	clc
	adc	[<curline]
	bpl	clip5
	lda	#0
	bra	clip3
clip5	cmp	#$100
	bcc	clip3
	lda	#$FF
clip3	sta	<actual
	clc
	adc	#8	;round up if >.5
	cmp	#$100
	bcc	clip4
	lda	#$FF
clip4	and	#$F0
	sta	<value
               sec
	lda	<actual
	sbc	<value
	bmi	minus2
	tax
	clc
	lda	!three8tbl1,x
	and	#$FF
	adc	[<nextline]
	sta	[<nextline]
	ldy	#2
	lda	!three8tbl2,x
	and	#$FF
	adc	[<curline],y
	sta	[<curline],y
	lda	!one4tbl,x
	and	#$FF
	adc	[<nextline],y
	sta	[<nextline],y
	bra	fini2        
minus2	eor	#$FFFF
	inc	a
	tax
	clc
	lda	!three8tbl1,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[<nextline]
	sta	[<nextline]
	ldy	#2
	lda	!three8tbl2,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[<curline],y
	sta	[<curline],y
	lda	!one4tbl,x
	and	#$FF
	eor	#$FFFF
	inc	a
	adc	[<nextline],y
	sta	[<nextline],y

fini2	inc	<nextline
	inc	<nextline
	inc	<curline	
	inc	<curline

	lda	<value
	and	#$F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	ldy	<offset
	ora	[<pic],y
	sta	[<pic],y
	clc
	lda	<lineptr
	adc	#3
	sta	<lineptr
	inc	<offset
	dec	<width
	jne	xloop

nexty	clc
	lda	<image
	adc	#2
	sta	<image
	lda	<pic
	adc	!PicWidth
	sta	<pic
	lda	<pic+2
	adc	#0
	sta	<pic+2
	lda	<curptr
	sta	<curline
	lda	<nextptr
	sta	<nextline

	jsl	TVMM_release
	jsl	AdvanceThermo
	dec	<height            
	jne	yloop	

	jsl	TVMM_release
	jsl	TVMM_release

	FindHandle curptr,@ax
	DisposeHandle @xa
	FindHandle nextptr,@ax
	DisposeHandle @xa

	jsl	CloseThermo

	return

loadstr	dc	c'Gray Scale Conversion...',h'00'

	END                     
